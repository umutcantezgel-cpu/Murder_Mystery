import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:mordakte_core/mordakte_core.dart';
import 'package:mordakte_core/runden.dart';

import '../game/szenen_erweiterung.dart';
import '../game/welt_szene.dart';
import '../l10n/gen/app_localizations_de.dart';
import 'karten_aktion.dart';
import 'karten_quelle.dart';
import 'sitzung.dart';

/// Speist den vorhandenen Renderer mit der Party-Karte (F4-ORCH-01, E-030).
///
/// Ermittlung: Detektiv als eigene Figur, alle Personen an ihren
/// Ermittlungsorten, offen sind nur die Ziele der laufenden Entscheidung.
/// `Interact` wählt nicht direkt, sondern macht einen Vorschlag; die Sitzung
/// fragt „Das ist endgültig“. Rückblende (erst nach dem Finale): Zeitraffer
/// der Tatmatrix mit dem Licht im Stromausfall (B-04). Was jede Szene auf der
/// Karte zeigt (Figuren, Hotspots, Licht, Sicht, Glanz, Kamera), kommt aus
/// [WeltSzene]; hier bleiben der geführte Weg, Vorschlag, Gespräch und
/// Rückblende.
final _de = LDe();

class PartyKartenSession extends WeltSzene implements GefuehrteSzene, SzenenGespraech {
  PartyKartenSession(this.sitzung, {this.rueckblendeModus = false, this.zeitraffer = 25})
      : super(sitzung.daten, SitzungsKartenQuelle(sitzung)) {
    // Akten ohne Simulation erzählen ihre Rückblende nur (Text); es gibt keine Szene.
    if (rueckblendeModus && sitzung.hatRueckblende) {
      _rb = sitzung.rueckblende;
      zeit.value = _rb!.schritte.first;
    }
    sitzung.addListener(zeigeFall);
    zeigeFall();
    zeigeWelt();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (_) => zeigeWelt());
  }

  final PartySitzung sitzung;

  /// Rückblende statt Ermittlung.
  final bool rueckblendeModus;

  /// Spielsekunden je echter Sekunde in der Rückblende.
  final double zeitraffer;

  /// Aktuelle Uhrzeit der Rückblende (für die Anzeige).
  final ValueNotifier<Uhrzeit?> zeit = ValueNotifier(null);

  /// Rückblende zu Ende?
  final ValueNotifier<bool> fertig = ValueNotifier(false);

  late final Timer _timer;
  Rueckblende? _rb;
  RueckblendeBild? _bild;
  double _rbSekunden = 0;

  /// Echte Zeit seit dem Start der Rückblende: Unter Last fallen Ticks aus,
  /// der Zeitraffer folgt trotzdem der Uhr.
  final Stopwatch _uhr = Stopwatch();

  /// Ersatz für die Wanduhr der Rückblende (Sekunden seit dem Start), damit
  /// Tests Bild für Bild prüfen können.
  @visibleForTesting
  double Function()? testUhr;
  KartenAktion? _aktion;
  int? _aktionsNummer;

  /// Ein Abstecher, zu dem es keinen begehbaren Weg gibt: die Erkundung läuft
  /// dann ohne Laufweg weiter (nie eine blockierte Würfelbühne).
  bool _abstecherOhneWeg = false;

  /// Ziel des laufenden Wegs in Kachelkoordinaten (für die Kamera).
  Offset? _aktionsZiel;

  final ValueNotifier<double> aktionsFortschritt = ValueNotifier(0);
  final ValueNotifier<bool> aktionsFehler = ValueNotifier(false);

  /// Lesbarer Laufplan für Kartenansicht und Geometrie-/Pfadgleichheitsbelege.
  KartenAktion? get kartenAktion => _aktion;

  @override
  bool get eingabeGesperrt => rueckblendeModus || sitzung.phase != PartyPhase.entscheidungen ||
      sitzung.zug != null || sitzung.vorschlag != null || sitzung.letzterFund != null || sitzung.gespraech != null;

  /// Position der Figur im laufenden Randgespräch (Kachelkoordinaten).
  Offset? get _gespraechsOrt {
    final g = sitzung.gespraech;
    if (g == null) return null;
    for (final f in sitzung.karte.figuren) {
      if (f.id == g.gespraech.figur) return Offset(f.x, f.y);
    }
    return null;
  }

  @override
  ({String npc, SzenenGeste geste})? get gespraechsGeste {
    final g = sitzung.gespraech;
    final npc = g == null ? null : sitzung.daten.npcKennung[g.gespraech.figur];
    if (g == null || npc == null) return null;
    final geste = switch (g.verlauf.last.geste) {
      'abwehr' => SzenenGeste.abwehr,
      'nachdenken' => SzenenGeste.nachdenken,
      _ => SzenenGeste.zuhoeren,
    };
    return (npc: npc, geste: geste);
  }

  @override
  SzenenPose? get figurenPose {
    if (sitzung.gespraech != null) return SzenenPose.befragen;
    final a = _aktion;
    if (a == null) return null;
    return a.geht ? SzenenPose.gehen : a.suchen ? SzenenPose.suchen : SzenenPose.befragen;
  }

  @override
  double get posenFortschritt => _aktion?.posenFortschritt ?? 0;

  @override
  Offset? get handlungsZiel {
    final ort = _gespraechsOrt;
    if (ort != null) return ort;
    final a = _aktion;
    if (a == null || a.geht) return null;
    return Offset(a.zielX, a.zielY);
  }

  void _synchronisiereAktion() {
    final z = sitzung.zug;
    if (rueckblendeModus || z == null || z.phase != RundenZugPhase.aktion) {
      _aktion = null;
      _aktionsNummer = null;
      _abstecherOhneWeg = false;
      return;
    }
    if (_aktionsNummer == z.aktion) return;
    _aktionsNummer = z.aktion;
    final ziel = sitzung.karte.ziele[z.option];
    double zx = detektivX, zy = detektivY;
    String? raum = raster.roomAtPos(detektivX, detektivY)?.id;
    final ort = z.istAbstecher ? sitzung.abstecherLaufend : null;
    final stelle = ort == null ? null : sitzung.kanon.graph.orte[ort.ort];
    if (stelle != null) {
      // Erkundung: der sichtbare Weg führt zum Ort des Abstechers.
      zx = stelle.x;
      zy = stelle.y;
      raum = stelle.raum;
    } else if (ziel != null) {
      raum = ziel.raum;
      if (ziel.person case final person?) {
        final f = sitzung.karte.figuren.firstWhere((f) => f.id == person);
        zx = f.x;
        zy = f.y;
      } else {
        zx = ziel.x! + 0.5;
        zy = ziel.y! + 0.5;
      }
    }
    _aktion = raum == null ? null : KartenAktion.planen(
      raster: raster, startX: detektivX, startY: detektivY, facing: detektivBlick,
      zielX: zx, zielY: zy, raum: raum, suchen: z.suche, umweg: z.ruf == Tischruf.umweg,
      personen: [for (final f in sitzung.karte.figuren) (f.x, f.y)],
    );
    _aktionsZiel = Offset(zx, zy);
    _abstecherOhneWeg = z.istAbstecher && _aktion == null;
    aktionsFehler.value = _aktion == null && !z.istAbstecher;
    aktionsFortschritt.value = 0;
    if (bewegungReduziert) _aktion?.abkuerzen();
  }

  @override
  void szenenSchritt(double sekunden) {
    if (entsorgt) return;
    // Rückblende: jedes Frame ein Bild, damit die Figuren auf ihren Linien
    // bleiben (der 100-ms-Takt allein ist bei Zeitraffer 25 zu grob).
    if (_rb != null) {
      zeigeWelt();
      return;
    }
    _synchronisiereAktion();
    final a = _aktion;
    final nr = _aktionsNummer;
    if (a == null && nr != null && _abstecherOhneWeg) {
      sitzung.aktionFertig(nr);
      return;
    }
    if (a == null || nr == null) return;
    a.schritt(sekunden);
    detektivX = a.x;
    detektivY = a.y;
    detektivBlick = a.facing;
    aktionsFortschritt.value = a.fortschritt;
    zeigeWelt();
    if (a.fertig) sitzung.aktionFertig(nr);
  }

  /// Bewusste Abkürzung, nie ein versteckter E2E-/Zeitgeber-Automatismus.
  void aktionAbkuerzen() {
    _aktion?.abkuerzen();
  }

  /// Rückblende von vorn.
  void neuStarten() {
    _rbSekunden = 0;
    _uhr
      ..reset()
      ..start();
    fertig.value = false;
  }

  // ---------------------------------------------------------------------------
  // WeltSzene: was diese Szene zeigt

  @override
  bool get zeigtErmittlung => !rueckblendeModus;

  @override
  Offset? get laufZiel => _aktionsZiel;

  @override
  String get detektivName => sitzung.personAmTisch('detective');

  @override
  bool get detektivGeht => _aktion?.geht ?? false;

  @override
  ChannelView? get detektivKanal {
    final a = _aktion;
    if (a == null || a.geht) return null;
    return ChannelView(kind: a.suchen ? 'search' : 'talk', target: sitzung.zug?.option ?? sitzung.zug?.id ?? 'auftakt', progress: posenFortschritt);
  }

  @override
  bool sprichtMit(String figur) =>
      figurenPose == SzenenPose.befragen &&
      (sitzung.karte.ziele[sitzung.zug?.option]?.person == figur || sitzung.gespraech?.gespraech.figur == figur);

  @override
  void vorDemZeigen() => _synchronisiereAktion();

  /// Rückblende: die Personen der Tatmatrix zur Uhr des Zeitraffers, sonst
  /// alle an ihren Ermittlungsorten.
  @override
  ({List<NpcView> npcs, Set<String> gehend}) figurenAnsicht() {
    final rb = _rb;
    if (rb == null) return super.figurenAnsicht();
    final dauer = rb.schritte.last.minus(rb.schritte.first).toDouble();
    if (!_uhr.isRunning) _uhr.start();
    final echt = testUhr?.call() ?? _uhr.elapsedMicroseconds / 1e6;
    _rbSekunden = math.min(dauer, echt * zeitraffer);
    if (_rbSekunden >= dauer) fertig.value = true;
    // Die Uhr zeigt ganze Sekunden; die Figuren stehen auf dem Bruchteil.
    final ganz = _rbSekunden.floor();
    final t = rb.schritte.first.plus(ganz);
    if (zeit.value != t) zeit.value = t;
    sitzung.rueckblendeZeit = t;
    final b = _bild = rb.bild(t, bruch: _rbSekunden - ganz);
    final gehend = <String>{};
    for (final e in b.personen.entries) {
      if (e.value.bewegtSich) {
        if (sitzung.daten.npcKennung[e.key] case final id?) gehend.add(id);
      }
    }
    return (
      npcs: [
        for (final e in b.personen.entries)
          if (sitzung.daten.npcKennung[e.key] case final id?) NpcView(id: id, x: e.value.x, y: e.value.y, alive: true),
      ],
      gehend: gehend,
    );
  }

  // ---------------------------------------------------------------------------
  // GameSession

  @override
  void move(double x, double y, double facing) {
    if (eingabeGesperrt || entsorgt || !x.isFinite || !y.isFinite || !facing.isFinite) return;
    detektivX = x;
    detektivY = y;
    detektivBlick = facing;
  }

  @override
  void send(Command command) {
    if (eingabeGesperrt || command is! Interact) return;
    final kennung = sitzung.daten.kanonKennung[command.target] ?? command.target;
    if (sitzung.laufendeEntscheidung != null && kartenZustand.ansprechbar[kennung] != null) {
      sitzung.schlageVorAn(kennung);
    } else if (!sitzung.randgespraechBeginnen(kennung)) {
      sitzung.schlageVorAn(kennung);
    }
  }

  @override
  Future<void> dispose() async {
    if (entsorgt) return;
    sitzung.removeListener(zeigeFall);
    _timer.cancel();
    aktionsFortschritt.dispose();
    aktionsFehler.dispose();
    zeit.dispose();
    fertig.dispose();
    await super.dispose();
  }

  // ---------------------------------------------------------------------------
  // SzenenErweiterung

  @override
  String? npcAktion(String npcId) {
    if (eingabeGesperrt) return null;
    final kanon = sitzung.daten.kanonKennung[npcId];
    if (sitzung.laufendeEntscheidung != null) {
      final art = kartenZustand.ansprechbar[kanon];
      if (art != null) return sitzung.ui('ui.karte.aktion.${art.name}');
    }
    // Unbesetzte Zeugen lassen sich am Rande ansprechen (Gespräche mit Wahl).
    if (kanon != null && sitzung.randgespraechMoeglich(kanon)) return _de.gespraech_ansprechen;
    return null;
  }

  @override
  bool npcUntersuchen(String npcId) => !eingabeGesperrt && kartenZustand.ansprechbar[sitzung.daten.kanonKennung[npcId]] == ZielArt.gegenstand;

  @override
  String? hotspotAktion(String hotspotId) {
    if (eingabeGesperrt) return null;
    final art = kartenZustand.offen[hotspotId];
    return art == null ? null : sitzung.ui('ui.karte.aktion.${art.name}');
  }

  /// Rückblende: Licht im Stromausfall (B-04), sonst das Licht der Ermittlung.
  @override
  SzenenLicht? get licht {
    final b = _bild;
    if (!rueckblendeModus || b == null) return super.licht;
    final strom = b.helleRaeume.contains('thekensaal');
    return SzenenLicht(
      dunkel: strom ? 0.66 : 0.85,
      taschenlampe: false,
      helleRaeume: const {},
      punkte: [
        if (strom) ...dekoKerzen,
        for (final l in b.lichter)
          SzenenLichtpunkt(l.x, l.y, radius: math.max(0.8, l.radius), farbe: WeltSzene.lichtFarbe(l.farbe), flackern: l.flackern),
      ],
    );
  }

  @override
  double? hervorhebung(String npcId) {
    final rb = _rb;
    if (rb == null) return null;
    return rb.hervorgehoben.contains(sitzung.daten.kanonKennung[npcId]) ? 1 : 0;
  }

  @override
  bool get exakteFiguren => _rb != null;

  @override
  Offset? get kamera {
    final b = _bild;
    if (!rueckblendeModus || b == null) return null;
    final p = b.personen[_rb!.pfad];
    return p == null ? null : Offset(p.x, p.y);
  }
}
