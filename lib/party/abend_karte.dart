import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:mordakte_core/mordakte_core.dart';
import 'package:mordakte_core/runden.dart' hide KartenQuelle;

import '../game/szenen_erweiterung.dart';
import '../game/welt_szene.dart';
import 'daten.dart';
import 'karten_quelle.dart';

/// Die Karte des langen Abends (M7b, Naht für Streifzug, Vorspiel und Morgen):
/// der Keller der Akte und die Welt-Ebenen (Erdgeschoss mit Hof und Garten,
/// Turm, Außenwelt) in einer Szene. Der Detektiv geht frei über die Ebene, auf
/// der er steht; Portale (Wendeltreppe, Hoftür, Außentor, Einfahrtstor)
/// wechseln die Ebene, aber nur, wenn sie in der [lage] offen sind
/// ([WeltEbenen.offen], [WeltEbenen.portaleAuf]).
///
/// - Tippen und Laufen wie im Keller: Der Renderer plant den Weg (A*, freie
///   Bahn mit Körperkasten) auf dem Raster der gezeigten Ebene; ein Portal ist
///   ein Hotspot, und `Interact` wechselt die Ebene ([wechsle]). Die Szene
///   blendet beim Wechsel über (`MordakteGame`, [SzenenEbenen]).
/// - Geführte Wege: [laufeZu] plant über Portale bis zu einem Ort, auch über
///   mehrere Ebenen; [zurueckInDenKeller] bringt den Detektiv an seinen
///   Ermittlungsort und endet sicher (ohne offenen Weg oder ohne laufenden
///   Renderer mit einer Kurzblende).
/// - [onAnkunft] meldet, wenn der Detektiv an einen Ort der gezeigten Ebene
///   kommt (geführt oder getippt), einmal je Ankunft.
/// - Licht: im Keller das der Ermittlung, auf den Ebenen ihre Stimmung und
///   Lichtquellen; am Morgen draußen Tageslicht ([SzenenLicht.tag]).
///
/// Die Karte hat keine Wirkung auf den Abend: Sie liest Phase, Runde und
/// Entscheidung nur aus ihrer [quelle] (im Keller die Ziele der laufenden
/// Entscheidung wie am Tisch), sie kennt weder Partie noch Zugschicht,
/// Nachtminuten oder Würfel. Unterklassen (Streifzug, Vorspiel, Morgen)
/// ergänzen Figuren ([figurenAufEbene]), Handlungen ([npcAktion],
/// [hotspotAktion]) und Interaktionen ([onInteraktion]).
class AbendKarte extends WeltSzene implements SzenenEbenen, GefuehrteSzene {
  /// [szenarien] sind die Renderer-Szenarien je Ebene (`partyEbenenSzenarien`,
  /// siehe [laden]); [start] ist der Startpunkt auf [ebene], ohne Angabe der
  /// Ermittlungsort des Detektivs im Keller ([kellerStart]).
  AbendKarte(
    PartyDaten daten,
    this.welt,
    Map<String, ScenarioDef> szenarien, {
    required WeltLage lage,
    KartenQuelle? quelle,
    String ebene = kellerEbene,
    (double, double)? start,
    super.klasse,
    this.detektivName = '',
    this.onAnkunft,
    this.onInteraktion,
  })  : _jeEbene = Map.unmodifiable(szenarien),
        _jeId = {for (final s in szenarien.values) s.id: s},
        _stand = lage,
        _ebene = szenarien.containsKey(ebene) ? ebene : kellerEbene,
        super(daten, quelle ?? const _OhneFall()) {
    if (!szenarien.containsKey(kellerEbene)) throw ArgumentError('Die Abend-Karte braucht das Szenario des Kellers');
    final p = start ?? (_ebene == kellerEbene ? kellerStart : _ersterAnkunftspunkt(_ebene));
    detektivX = p.$1;
    detektivY = p.$2;
    zeigeFall();
    stelleDetektiv(p.$1, p.$2, facing: detektivBlick);
  }

  /// Lädt die Welt-Ebenen der Akte (`welt.json` → `langfassung`) und baut die
  /// Szenarien je Ebene wie die Vorschau (M7a).
  static Future<AbendKarte> laden(
    AssetBundle bundle,
    PartyDaten daten, {
    required WeltLage lage,
    KartenQuelle? quelle,
    String ebene = kellerEbene,
    (double, double)? start,
    SzenenKlasse? klasse,
    String detektivName = '',
    void Function(String ebene, String ort)? onAnkunft,
    void Function(String ziel)? onInteraktion,
  }) async {
    final (welt, szenarien) = await ladeWelt(bundle, daten);
    return AbendKarte(daten, welt, szenarien,
        lage: lage, quelle: quelle, ebene: ebene, start: start, klasse: klasse, detektivName: detektivName, onAnkunft: onAnkunft, onInteraktion: onInteraktion);
  }

  /// Welt-Ebenen und Szenarien je Ebene der Akte aus den Assets.
  static Future<(WeltEbenen, Map<String, ScenarioDef>)> ladeWelt(AssetBundle bundle, PartyDaten daten) async {
    final fall = daten.fall;
    final weltJson = jsonDecode(await bundle.loadString('content/welt/$fall/welt.json')) as Map<String, Object?>;
    final datei = weltJson['langfassung'];
    if (datei is! String) throw StateError('Die Akte $fall hat keine Langfassung');
    final lang = jsonDecode(await bundle.loadString('content/welt/$fall/$datei')) as Map<String, Object?>;
    final welt = WeltEbenen.ausJson(lang, daten.kanon);
    final darstellung = (daten.kanon.json['setting.json']?['darstellung'] as Map?) ?? const {};
    final vorlage = jsonDecode(await bundle.loadString(darstellung['vorlage'] as String? ?? 'content/scenarios/ravensmoor.json')) as Map<String, dynamic>;
    return (welt, partyEbenenSzenarien(daten.kanon, vorlage, welt, id: daten.szenario.id, welt: weltJson));
  }

  /// Die Ebenen der Akte mit Portalen und Öffnungszeiten.
  final WeltEbenen welt;

  /// Der Detektiv kommt an einen Ort der gezeigten Ebene (Ebene, Ort-Kennung):
  /// beim Tippen, sobald er in [ankunftsRadius] um den Ort steht, geführt am
  /// Ziel von [laufeZu]. Einmal je Ankunft; erst wer sich entfernt, kommt
  /// wieder an.
  void Function(String ebene, String ort)? onAnkunft;

  /// `Interact` an einem Ziel, das kein Portal ist (Figur, Hotspot einer
  /// Unterklasse); die Karte selbst tut damit nichts.
  void Function(String ziel)? onInteraktion;

  /// Abstand (Kacheln), ab dem der Detektiv an einem Ort angekommen ist.
  static const ankunftsRadius = 1.0;

  /// Längste Zeit ohne Bild, bevor ein geführter Weg mit einer Kurzblende endet
  /// (der Renderer läuft nicht, etwa weil die Karte nicht zu sehen ist).
  @visibleForTesting
  Duration wachhundFrist = const Duration(milliseconds: 1500);

  final Map<String, ScenarioDef> _jeEbene;
  final Map<String, ScenarioDef> _jeId;
  WeltLage _stand;
  String _ebene;
  final Map<String, TileGrid> _raster = {};
  String? _amOrt;
  String? _letzterRaumHier;
  _Lauf? _lauf;

  /// Wacht über einen geführten Weg, nur solange einer läuft ([_wache]).
  Timer? _wachhund;

  /// Die gezeigte Ebene (`keller`, `erdgeschoss`, `turm`, `aussen`).
  String get aktuelleEbene => _ebene;

  /// Zeitpunkt des Abends, nach dem Portale und Türen offen sind.
  WeltLage get lage => _stand;

  /// Läuft gerade ein geführter Weg ([laufeZu], [zurueckInDenKeller])?
  bool get laeuft => _lauf != null;

  /// Startpunkt im Keller: der Ermittlungsort des Detektivs (Kanon).
  (double, double) get kellerStart {
    final kanon = daten.kanon;
    final d = kanon.figur((kanon.figurenJson['detektiv'] as Map)['id'] as String)!;
    final o = kanon.graph.orte[d['ermittlungsOrt'] as String]!;
    return (o.x, o.y);
  }

  /// Kennung des Ermittlungsorts im Keller (Ziel von [zurueckInDenKeller]).
  String get ermittlungsOrt {
    final kanon = daten.kanon;
    return kanon.figur((kanon.figurenJson['detektiv'] as Map)['id'] as String)!['ermittlungsOrt'] as String;
  }

  (double, double) _ersterAnkunftspunkt(String ebene) {
    final s = welt.portaleAuf(ebene).first.$2;
    return (s.ankunftX, s.ankunftY);
  }

  /// Raster der Ebene [ebene] in der aktuellen [lage]: das Raster, das auch der
  /// Renderer nutzt (Karte des Szenarios mit Requisiten), mit den offenen
  /// Türen und Portalkacheln der Lage.
  TileGrid rasterVon(String ebene) =>
      _raster.putIfAbsent(ebene, () => TileGrid(_jeEbene[ebene]!.map)..setOpenDoors(welt.offeneKacheln(ebene, _stand)));

  /// Graph der Ebene [ebene] (im Keller der Kanon-Graph).
  RaumGraph graphVon(String ebene) => welt.ebenen[ebene]!.graph;

  // ---------------------------------------------------------------------------
  // Lage und Ebenen

  /// Neue Lage (Uhrzeit, Fassung): Portale und Türen folgen ihr sofort. Ein
  /// laufender geführter Weg endet mit einer Kurzblende; steht der Detektiv
  /// auf einer Ebene, die jetzt zu ist, kehrt er mit einer Kurzblende in den
  /// Keller zurück.
  void wechsleLage(WeltLage lage) {
    if (entsorgt) return;
    _stand = lage;
    _raster.clear();
    // Erst Portale und Türen der neuen Lage, dann ein Sprung: Das letzte Bild
    // der Welt trägt die Korrektur für den Renderer.
    zeigeFall();
    if (_lauf != null) _kurzblende(_lauf!);
    if (!welt.zugangOffen(_ebene, lage)) _setze(kellerEbene, kellerStart, ort: ermittlungsOrt);
  }

  /// Portal [id] mit seiner Seite auf der gezeigten Ebene.
  (Portal, PortalSeite)? _portalHier(String id) => welt.portaleAuf(_ebene).where((e) => e.$1.id == id).firstOrNull;

  /// Ist das Portal [p] in der [lage] passierbar (offen und die Ebene dahinter zugänglich)?
  bool _passierbar(Portal p, PortalSeite von) => welt.offen(p.offen, _stand) && welt.zugangOffen(p.gegenueber(von).ebene, _stand);

  /// Geht durch das Portal [id] auf die andere Ebene, wenn es von hier aus
  /// erreichbar und in der [lage] offen ist; der Detektiv steht dann am
  /// Ankunftspunkt der anderen Seite.
  bool wechsle(String id) {
    final hier = _portalHier(id);
    if (entsorgt || hier == null || !_passierbar(hier.$1, hier.$2)) return false;
    final dort = hier.$1.gegenueber(hier.$2);
    _setze(dort.ebene, (dort.ankunftX, dort.ankunftY));
    return true;
  }

  /// Setzt den Detektiv auf [ebene] an [p] (Wechsel oder Kurzblende); mit
  /// [ort] ist er dort angekommen, sonst zählt der nächste Ort in Reichweite.
  void _setze(String ebene, (double, double) p, {String? ort}) {
    final neu = ebene != _ebene;
    _ebene = ebene;
    _letzterRaumHier = null;
    _amOrt = null;
    if (neu) zeigeFall();
    stelleDetektiv(p.$1, p.$2, facing: detektivBlick);
    if (ort != null) {
      _melde(ebene, ort);
    } else {
      _pruefeAnkunft();
    }
  }

  // ---------------------------------------------------------------------------
  // Geführte Wege

  /// Läuft zum Ort [ort] auf der Ebene [ebene], über offene Portale auch auf
  /// eine andere Ebene. `true`, sobald der Detektiv dort steht; `false` ohne
  /// offenen Weg (dann bleibt er stehen) oder wenn ein neuer Weg diesen
  /// ablöst. Unbekannte Ebene oder unbekannter Ort: [ArgumentError].
  Future<bool> laufeZu(String ebene, String ort) {
    final o = welt.ebenen[ebene]?.graph.orte[ort] ?? (throw ArgumentError('Ort $ort auf $ebene unbekannt'));
    return _laufe(ebene, (o.x, o.y), ort: ort)?.fertig.future ?? Future.value(false);
  }

  /// Läuft wie [laufeZu] zu einer Stelle ([punkt], Kachelkoordinaten) auf
  /// [ebene], die kein Ort des Raumgraphen ist (Erkundung des Streifzugs: eine
  /// Einrichtung oder Kachel). Am Ziel meldet [onAnkunft] die Kennung [ziel].
  /// Unbekannte Ebene: [ArgumentError].
  Future<bool> laufeZuPunkt(String ebene, (double, double) punkt, {required String ziel}) {
    if (!welt.ebenen.containsKey(ebene)) throw ArgumentError('Ebene $ebene unbekannt');
    return _laufe(ebene, punkt, ort: ziel)?.fertig.future ?? Future.value(false);
  }

  /// Bringt den Detektiv zurück an seinen Ermittlungsort im Keller ([kellerStart]),
  /// vor jeder Entscheidung. Führt kein offener Weg dorthin (ein Portal ist in
  /// der Lage zu), steht er nach einer Kurzblende dort. Endet immer.
  Future<void> zurueckInDenKeller() async {
    if (entsorgt) return;
    final l = _laufe(kellerEbene, kellerStart, ort: ermittlungsOrt);
    if (l != null) {
      // Löst ein neuer Weg diesen ab, gilt der neue.
      await l.fertig.future;
      return;
    }
    // Kein offener Weg (ein Portal ist zu): Kurzblende an den Ermittlungsort.
    _setze(kellerEbene, kellerStart, ort: ermittlungsOrt);
  }

  /// Beendet einen laufenden geführten Weg sofort am Ziel (Kurzblende).
  void abkuerzen() {
    final l = _lauf;
    if (l != null) _kurzblende(l);
  }

  /// Beginnt einen geführten Weg; `null` ohne offenen Weg (dann bleibt alles stehen).
  _Lauf? _laufe(String ebene, (double, double) ziel, {required String ort}) {
    if (entsorgt) return null;
    final plan = planeWeg(ebene, ziel);
    if (plan == null) return null;
    final alt = _lauf;
    _lauf = null;
    alt?.beenden(false);
    final lauf = _Lauf(plan, ebene: ebene, ziel: ziel, ort: ort, tempo: Tuning.playerSpeed * tempoFaktor);
    _lauf = lauf;
    if (bewegungReduziert || plan.every((a) => a.punkte.isEmpty && a.portal == null)) {
      _kurzblende(lauf);
    } else {
      _ohneSchritt = Duration.zero;
      _wachhund ??= Timer.periodic(_wachTakt, (_) => _wache());
      zeigeFall();
    }
    return lauf;
  }

  /// Weg von der Stelle des Detektivs zum Punkt [ziel] auf [ebene]: je Ebene
  /// ein Abschnitt mit geglätteten Wegpunkten (A*, freie Bahn mit Körperkasten)
  /// und dem Portal am Ende. Über Ebenen hinweg der kürzeste Weg durch offene
  /// Portale (Weglänge plus Treppenlauf). `null` ohne offenen Weg.
  @visibleForTesting
  List<LaufAbschnitt>? planeWeg(String ebene, (double, double) ziel) {
    if (!welt.ebenen.containsKey(ebene) || !welt.zugangOffen(ebene, _stand)) return null;
    final zielPunkt = _standpunkt(ebene, ziel);
    if (zielPunkt == null) return null;
    // Knoten: Start, Ziel und die Ankunftspunkte aller passierbaren Portale.
    final knoten = <_Knoten>[
      _Knoten(_ebene, Offset(detektivX, detektivY)),
      _Knoten(ebene, zielPunkt),
      for (final p in welt.portale)
        for (final s in [p.a, p.b])
          if (_passierbar(p, s)) _Knoten(s.ebene, Offset(s.ankunftX, s.ankunftY), portal: p, seite: s),
    ];
    final wege = <(int, int), List<Offset>?>{};
    List<Offset>? weg(int a, int b) => wege.putIfAbsent((a, b), () => _wegAufEbene(knoten[a].ebene, knoten[a].punkt, knoten[b].punkt));
    // Dijkstra über die wenigen Knoten.
    final dist = List<double>.filled(knoten.length, double.infinity);
    final vor = List<(int, bool)?>.filled(knoten.length, null);
    final fertig = List<bool>.filled(knoten.length, false);
    dist[0] = 0;
    while (true) {
      var u = -1;
      for (var i = 0; i < knoten.length; i++) {
        if (!fertig[i] && dist[i].isFinite && (u < 0 || dist[i] < dist[u])) u = i;
      }
      if (u < 0 || u == 1) break;
      fertig[u] = true;
      for (var v = 0; v < knoten.length; v++) {
        if (fertig[v] || v == u) continue;
        double? kosten;
        var durch = false;
        final ku = knoten[u], kv = knoten[v];
        if (ku.portal != null && kv.portal == ku.portal && kv.seite != ku.seite) {
          // Durch das Portal auf die andere Seite.
          kosten = ku.portal!.weg + 1;
          durch = true;
        } else if (ku.ebene == kv.ebene && v != 0) {
          final w = weg(u, v);
          if (w != null) kosten = _laenge(ku.punkt, w);
        }
        if (kosten != null && dist[u] + kosten < dist[v]) {
          dist[v] = dist[u] + kosten;
          vor[v] = (u, durch);
        }
      }
    }
    if (!dist[1].isFinite) return null;
    // Rückwärts zu Abschnitten je Ebene.
    final kette = <(int, bool)>[];
    for (var k = 1; k != 0;) {
      final (u, durch) = vor[k]!;
      kette.insert(0, (k, durch));
      k = u;
    }
    final abschnitte = <LaufAbschnitt>[];
    var punkte = <Offset>[];
    var hier = 0;
    for (final (k, durch) in kette) {
      if (durch) {
        abschnitte.add(LaufAbschnitt(knoten[hier].ebene, punkte, portal: knoten[hier].portal!.id));
        punkte = <Offset>[];
      } else {
        punkte = [...punkte, ...weg(hier, k)!];
      }
      hier = k;
    }
    abschnitte.add(LaufAbschnitt(ebene, punkte));
    return abschnitte;
  }

  static double _laenge(Offset von, List<Offset> punkte) {
    var l = 0.0;
    var a = von;
    for (final p in punkte) {
      l += (p - a).distance;
      a = p;
    }
    return l;
  }

  /// Ein Punkt, an dem der Detektiv bei [ziel] auf [ebene] frei steht: das
  /// Ziel selbst oder die nächste freie Kachelmitte daneben (ein Ort an einem
  /// Möbelstück).
  Offset? _standpunkt(String ebene, (double, double) ziel) {
    final r = rasterVon(ebene);
    final (x, y) = ziel;
    if (r.canStand(x, y, Tuning.playerRadius)) return Offset(x, y);
    final raum = graphVon(ebene).raumAn(x, y)?.id;
    Offset? best;
    var bestD = double.infinity;
    for (var dy = -2; dy <= 2; dy++) {
      for (var dx = -2; dx <= 2; dx++) {
        final mx = x.floor() + dx + 0.5, my = y.floor() + dy + 0.5;
        if (!r.canStand(mx, my, Tuning.playerRadius)) continue;
        // Lieber im Raum des Ziels als hinter der Wand daneben.
        final d = dist(mx, my, x, y) + (raum != null && graphVon(ebene).raumAn(mx, my)?.id != raum ? 10 : 0);
        if (d < bestD) {
          bestD = d;
          best = Offset(mx, my);
        }
      }
    }
    return best;
  }

  /// Geglätteter Weg auf einer Ebene von [von] zu [nach] (beide frei): erst die
  /// eigene Kachelmitte, dann A* über Kachelmitten, dann genau der Zielpunkt;
  /// abgekürzt nur, wo der ganze Körper frei durchkommt. `null` ohne Weg.
  List<Offset>? _wegAufEbene(String ebene, Offset von, Offset nach) {
    final r = rasterVon(ebene);
    final start = Pt(von.dx.floor(), von.dy.floor()), ende = Pt(nach.dx.floor(), nach.dy.floor());
    final kacheln = start == ende ? const <Pt>[] : r.findPath(start, ende);
    if (kacheln == null) return null;
    final punkte = [
      if (start != ende) Offset(start.x + 0.5, start.y + 0.5),
      for (final k in kacheln) Offset(k.x + 0.5, k.y + 0.5),
      nach,
    ];
    bool frei(Offset a, Offset b) => r.freieBahn(a.dx, a.dy, b.dx, b.dy, Tuning.playerRadius);
    final glatt = <Offset>[];
    var a = von;
    var i = 0;
    while (i < punkte.length) {
      var j = punkte.length - 1;
      while (j > i && !frei(a, punkte[j])) {
        j--;
      }
      glatt.add(punkte[j]);
      a = punkte[j];
      i = j + 1;
    }
    glatt.removeWhere((p) => p == von);
    return glatt;
  }

  /// Zeit seit dem letzten Bild des Renderers, in Takten des Wachhunds.
  Duration _ohneSchritt = Duration.zero;
  static const _wachTakt = Duration(milliseconds: 250);

  /// Ohne Bilder des Renderers endet ein geführter Weg nach [wachhundFrist]
  /// mit einer Kurzblende: So hängt kein Abend an einem Weg, den niemand sieht.
  void _wache() {
    final l = _lauf;
    _ohneSchritt += _wachTakt;
    if (l != null && !entsorgt && _ohneSchritt >= wachhundFrist) _kurzblende(l);
    if (_lauf == null || entsorgt) {
      _wachhund?.cancel();
      _wachhund = null;
    }
  }

  /// Springt ans Ziel des Wegs [l] (Kurzblende): auf die Zielebene, wenn sie
  /// offen ist, sonst an den Ermittlungsort im Keller.
  void _kurzblende(_Lauf l) {
    if (!identical(_lauf, l)) return;
    _lauf = null;
    final offen = welt.zugangOffen(l.ebene, _stand);
    final punkt = offen ? (_standpunkt(l.ebene, l.ziel) ?? Offset(l.ziel.$1, l.ziel.$2)) : null;
    if (punkt != null) {
      _setze(l.ebene, (punkt.dx, punkt.dy), ort: l.ort);
      l.beenden(true);
    } else {
      _setze(kellerEbene, kellerStart, ort: ermittlungsOrt);
      l.beenden(false);
    }
  }

  // ---------------------------------------------------------------------------
  // GefuehrteSzene: geführte Wege besitzen die Figur

  @override
  bool get eingabeGesperrt => _lauf != null;

  @override
  SzenenPose? get figurenPose => _lauf == null ? null : SzenenPose.gehen;

  @override
  double get posenFortschritt => 0;

  @override
  Offset? get handlungsZiel => null;

  @override
  void szenenSchritt(double sekunden) {
    final l = _lauf;
    if (l == null || entsorgt || !sekunden.isFinite || sekunden <= 0) return;
    _ohneSchritt = Duration.zero;
    var rest = math.min(sekunden, 0.25) * l.tempo;
    while (rest > 1e-9 && identical(_lauf, l)) {
      final a = l.abschnitte[l.abschnitt];
      if (l.punkt < a.punkte.length) {
        final z = a.punkte[l.punkt];
        final d = dist(detektivX, detektivY, z.dx, z.dy);
        final s = math.min(d, rest);
        final nx = s >= d ? z.dx : detektivX + (z.dx - detektivX) * s / d;
        final ny = s >= d ? z.dy : detektivY + (z.dy - detektivY) * s / d;
        if (!rasterVon(_ebene).canStand(nx, ny, Tuning.playerRadius)) {
          // Eine Tür ist inzwischen zu: lieber eine Kurzblende als durch die Wand.
          _kurzblende(l);
          return;
        }
        if (d > 1e-6) detektivBlick = math.atan2(z.dy - detektivY, z.dx - detektivX);
        detektivX = nx;
        detektivY = ny;
        rest -= s;
        if (s >= d) l.punkt++;
        continue;
      }
      if (a.portal != null) {
        // Am Portal: durch auf die andere Ebene, der nächste Abschnitt beginnt dort.
        if (!wechsle(a.portal!)) {
          _kurzblende(l);
          return;
        }
        l.abschnitt++;
        l.punkt = 0;
        continue;
      }
      // Am Ziel: Der Renderer übernimmt genau diese Stelle (Korrektur), dann ist die Eingabe wieder frei.
      _lauf = null;
      stelleDetektiv(detektivX, detektivY, facing: detektivBlick);
      _melde(l.ebene, l.ort);
      l.beenden(true);
      return;
    }
    zeigeWelt();
    _pruefeAnkunft();
  }

  // ---------------------------------------------------------------------------
  // Ankunft an Orten

  /// Meldet die Ankunft an [ort] (auch ohne Abstand, am Ziel eines Wegs).
  void _melde(String ebene, String ort) {
    if (_amOrt == ort) return;
    _amOrt = ort;
    onAnkunft?.call(ebene, ort);
  }

  /// Steht der Detektiv in [ankunftsRadius] um einen Ort der Ebene, kommt er
  /// dort an (einmal); entfernt er sich, ist er wieder unterwegs.
  void _pruefeAnkunft() {
    if (_lauf != null) return;
    String? naechster;
    var bestD = ankunftsRadius;
    for (final o in graphVon(_ebene).orte.values) {
      final d = dist(o.x, o.y, detektivX, detektivY);
      if (d <= bestD) {
        bestD = d;
        naechster = o.id;
      }
    }
    if (naechster == null) {
      _amOrt = null;
    } else {
      _melde(_ebene, naechster);
    }
  }

  // ---------------------------------------------------------------------------
  // WeltSzene: was die Karte zeigt

  /// Name des Detektivs am Tisch (Namensschild).
  @override
  final String detektivName;

  @override
  bool get detektivGeht => _lauf != null;

  @override
  Offset? get laufZiel => _lauf == null ? null : Offset(_lauf!.ziel.$1, _lauf!.ziel.$2);

  @override
  TileGrid get raster => rasterVon(_ebene);

  @override
  String get fallSzenarioId => _jeEbene[_ebene]!.id;

  /// Im Keller die laufende Entscheidung wie am Tisch, auf den Ebenen nicht.
  @override
  bool get mitKellerFall => _ebene == kellerEbene;

  /// Offene Portale der gezeigten Ebene (passierbar in der Lage).
  @override
  Map<String, String> get zusatzHotspots => {
        for (final (p, s) in welt.portaleAuf(_ebene))
          if (_passierbar(p, s)) p.id: HotspotState.open,
      };

  @override
  List<List<int>> get offeneTuerKacheln => [
        for (final k in welt.offeneKacheln(_ebene, _stand)) [k.x, k.y],
      ];

  /// Figuren der gezeigten Ebene: im Keller alle Personen an ihren
  /// Ermittlungsorten, sonst [figurenAufEbene].
  @override
  ({List<NpcView> npcs, Set<String> gehend}) figurenAnsicht() =>
      _ebene == kellerEbene ? super.figurenAnsicht() : (npcs: figurenAufEbene(_ebene), gehend: const <String>{});

  /// Figuren auf einer Ebene außer dem Keller; Vorgabe: niemand (lebendige
  /// Figuren bringen Streifzug und M8).
  @protected
  List<NpcView> figurenAufEbene(String ebene) => const [];

  @override
  List<SzenenGlanzPunkt> get glanzpunkte => _ebene == kellerEbene ? super.glanzpunkte : const [];

  /// Tageslicht: im langen Abend ab dem Morgen (sieben Uhr) unter freiem
  /// Himmel (Hof, Garten, Wehrgang, Außenwelt); der Keller und die Räume
  /// drinnen bleiben beim Licht der Nacht.
  bool get tageslicht {
    if (_ebene == kellerEbene || !welt.offen(Oeffnung.nieInRunden, _stand)) return false;
    final e = welt.ebenen[_ebene]!;
    final raum = e.graph.raumAn(detektivX, detektivY)?.id ?? _letzterRaumHier;
    if (raum != null) _letzterRaumHier = raum;
    return raum != null && e.aussen.contains(raum);
  }

  /// Licht: im Keller das der Ermittlung, auf den Ebenen Grunddunkel der
  /// Stimmung, Raumlicht und Lichtpunkte der Lichtquellen, die zur Uhrzeit der
  /// Lage brennen; am Morgen draußen Tageslicht ([SzenenLicht.tag]).
  @override
  SzenenLicht? get licht {
    if (_ebene == kellerEbene) return super.licht;
    final e = welt.ebenen[_ebene]!;
    final g = e.graph;
    final brennt = [for (final l in g.lichtquellen.values) if (l.traeger == null && l.brennt(_stand.uhr)) l];
    return SzenenLicht(
      dunkel: e.dunkel,
      tag: tageslicht,
      helleRaeume: {for (final l in brennt) ...l.raeume},
      punkte: [
        for (final l in brennt)
          if (g.orte[l.ort] case final o?)
            SzenenLichtpunkt(o.x, o.y, z: 1.6, radius: l.radius, farbe: WeltSzene.lichtFarbe(l.farbe ?? '#FFF1C9'), flackern: bewegungReduziert ? 0 : l.flackern),
      ],
    );
  }

  /// Sicht nach Räumen: im Keller wie am Tisch, auf den Ebenen der eigene Raum
  /// und die Räume hinter offenen Türen.
  @override
  Set<String>? sichtbareRaeume(double x, double y) {
    if (_ebene == kellerEbene) return super.sichtbareRaeume(x, y);
    final g = graphVon(_ebene);
    final raum = g.raumAn(x, y)?.id ?? _letzterRaumHier;
    if (raum == null) return null;
    _letzterRaumHier = raum;
    final offen = welt.offeneKacheln(_ebene, _stand);
    return {
      raum,
      for (final t in g.tueren.values)
        if (!t.verschlossen || t.kacheln.every(offen.contains))
          if (t.von == raum) t.nach else if (t.nach == raum) t.von,
    };
  }

  // ---------------------------------------------------------------------------
  // GameSession

  @override
  Map<String, ScenarioDef> get scenarios => _jeId;

  @override
  ScenarioDef? get scenario => _jeEbene[_ebene];

  @override
  void move(double x, double y, double facing) {
    if (eingabeGesperrt || entsorgt || !x.isFinite || !y.isFinite || !facing.isFinite) return;
    detektivX = x;
    detektivY = y;
    detektivBlick = facing;
    _pruefeAnkunft();
  }

  /// `Interact` an einem Portal wechselt die Ebene (wenn es offen ist), jedes
  /// andere Ziel geht an [onInteraktion].
  @override
  void send(Command command) {
    if (eingabeGesperrt || entsorgt || command is! Interact) return;
    if (_portalHier(command.target) != null) {
      wechsle(command.target);
    } else {
      onInteraktion?.call(command.target);
    }
  }

  @override
  Future<void> dispose() async {
    if (entsorgt) return;
    _wachhund?.cancel();
    _wachhund = null;
    final l = _lauf;
    _lauf = null;
    l?.beenden(false);
    await super.dispose();
  }

  // ---------------------------------------------------------------------------
  // SzenenEbenen und SzenenErweiterung

  @override
  Set<String> get ebenenSzenarien => _jeId.keys.toSet();

  @override
  String? npcAktion(String npcId) => null;

  @override
  bool npcUntersuchen(String npcId) => false;

  /// Beschriftung eines Portals der gezeigten Ebene („Die Wendeltreppe hinauf“).
  @override
  String? hotspotAktion(String hotspotId) {
    if (eingabeGesperrt) return null;
    final hier = _portalHier(hotspotId);
    return hier == null || !_passierbar(hier.$1, hier.$2) ? null : hier.$2.aktion;
  }
}

/// Ein Abschnitt eines geführten Wegs auf einer Ebene: Wegpunkte und, wenn der
/// Weg dort weitergeht, das Portal an seinem Ende.
@immutable
class LaufAbschnitt {
  const LaufAbschnitt(this.ebene, this.punkte, {this.portal});

  final String ebene;
  final List<Offset> punkte;
  final String? portal;
}

/// Ein laufender geführter Weg.
class _Lauf {
  _Lauf(this.abschnitte, {required this.ebene, required this.ziel, required this.ort, required this.tempo});

  final List<LaufAbschnitt> abschnitte;
  final String ebene;
  final (double, double) ziel;
  final String ort;

  /// Kacheln je Sekunde.
  final double tempo;
  final Completer<bool> fertig = Completer<bool>();
  int abschnitt = 0, punkt = 0;

  void beenden(bool angekommen) {
    if (!fertig.isCompleted) fertig.complete(angekommen);
  }
}

/// Knoten der Wegplanung über Ebenen.
class _Knoten {
  _Knoten(this.ebene, this.punkt, {this.portal, this.seite});

  final String ebene;
  final Offset punkt;
  final Portal? portal;
  final PortalSeite? seite;
}

/// Quelle ohne Abend: keine Entscheidung, kein Zug (Vorspiel, Morgen, Tests).
class _OhneFall implements KartenQuelle {
  const _OhneFall();

  @override
  PartyPhase get phase => PartyPhase.intro;

  @override
  int get runde => 0;

  @override
  Entscheidung? get laufendeEntscheidung => null;

  @override
  Map<String, String> get gewaehlt => const {};

  @override
  RundenZug? get zug => null;

  @override
  List<AbstecherOrt> get abstecherOffen => const [];
}
