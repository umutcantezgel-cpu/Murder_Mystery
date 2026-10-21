/// Vorspiel und Morgen des langen Abends (M7b, `content/welt/<akte>/vorspiel_morgen.json`,
/// Format `vorspiel_morgen/1`): zwei Rundgänge auf den Welt-Ebenen ([WeltEbenen]).
///
/// - Das **Vorspiel** (18:00) ist ein Unterzustand der Einleitung: Der Detektiv
///   kommt draußen an und geht über Außenwelt, Schlosshof und Garten in den
///   Keller, bis Herr Schneider um zehn vor sieben die Tore schließt.
/// - Der **Morgen** (07:00) ist ein Unterzustand des Endes: Die Kollegin
///   schließt mit dem Torschlüssel auf, und der Detektiv geht draußen im
///   Tageslicht herum, bevor das Schlussbild kommt.
///
/// Je Station geht der Detektiv an einen Ort einer Ebene. Die Uhrzeit der
/// Station stellt die Tore ([WeltLage]); auf dem Weg dorthin gilt die Uhrzeit
/// der Station davor ([Rundgang.wegLage]). Dazu stehen Figuren ohne Verdacht an
/// Orten der Ebene, und es gibt eine Karte nach R17 (Titel, höchstens drei
/// Stichpunkte zu je höchstens acht Wörtern) mit dem Vorlesetext des Erzählers.
/// Am Morgen darf eine Station je Ende verschieden sein ([RundgangStation.jeEnde]).
///
/// Ein Rundgang ändert nichts am Abend: Er kennt weder Partie noch Würfel,
/// Nachtminuten, Punkte oder Ende (das Ende liest er nur für den Text).
library;

import '../karten/sperrwoerter.dart';
import '../party/enden.dart';
import '../party/steckbriefe.dart' show fuenfWortFolgen, geheimeFelder;
import '../party/texte.dart' show stichpunktWoerter;
import '../party/textpruefer.dart';
import '../party/zeit.dart';
import '../scenario/grid.dart';
import '../util/geom.dart';
import 'ebenen.dart';

/// Kennung des Dateiformats.
const vorspielMorgenFormat = 'vorspiel_morgen/1';

/// So viele Stationen hat ein Rundgang (Auftrag M7b: vier bis sechs Karten).
const rundgangStationenMin = 4, rundgangStationenMax = 6;

/// Kartenformat R17: höchstens so viele Stichpunkte zu je höchstens so vielen Wörtern.
const rundgangPunkteMax = 3, rundgangPunktWorte = 8;

/// Höchstens so viele Wörter hat der Titel einer Karte.
const rundgangTitelWorte = 4;

/// Höchstens so viele Figuren stehen an einer Station.
const rundgangFigurenMax = 4;

/// Wortbudget für Vorspiel und Morgen zusammen (Plan: etwa 1,4k Wörter).
const rundgangWorteGesamt = 1500;

/// Die beiden Rundgänge des langen Abends.
enum RundgangTeil {
  /// Vor dem Abend (Unterzustand der Einleitung).
  vorspiel,

  /// Nach der Auflösung (Unterzustand des Endes).
  morgen;

  /// Teil zum Namen (`vorspiel`, `morgen`), sonst `null`.
  static RundgangTeil? lesen(Object? name) => values.where((t) => t.name == name).firstOrNull;
}

/// Karte und Vorlesetext einer Station.
class RundgangText {
  const RundgangText({required this.titel, required this.punkte, required this.vorlesen});

  /// Titel der Karte (höchstens [rundgangTitelWorte] Wörter).
  final String titel;

  /// Stichpunkte der Karte (R17).
  final List<String> punkte;

  /// Prosa für den Vorleser-Sitz (Erzähler, sonst Detektiv bzw. Gastgebergerät).
  final String vorlesen;

  /// Die Karte als JSON (öffentlich im Online-Abend): Titel und Stichpunkte, nie der Vorlesetext.
  Map<String, Object?> karteJson() => {'titel': titel, 'punkte': [...punkte]};

  /// Alle Wörter von Karte und Vorlesetext.
  int get woerter => stichpunktWoerter(titel) + punkte.fold<int>(0, (n, p) => n + stichpunktWoerter(p)) + stichpunktWoerter(vorlesen);

  factory RundgangText._aus(Map j, String wo) {
    _nur(j, const {'titel', 'punkte', 'vorlesen'}, wo);
    return RundgangText(
      titel: j['titel'] as String,
      punkte: List.unmodifiable([for (final p in j['punkte'] as List) p as String]),
      vorlesen: j['vorlesen'] as String,
    );
  }
}

/// Eine Figur an einer Station: Kanon-Person an einem Ort der Ebene der Station.
class RundgangFigur {
  const RundgangFigur({required this.figur, required this.ort});

  final String figur;
  final String ort;
}

/// Eine Station eines Rundgangs.
class RundgangStation {
  const RundgangStation({
    required this.id,
    required this.zeit,
    required this.ebene,
    required this.ort,
    this.figuren = const [],
    this.text,
    this.jeEnde = const {},
  });

  final String id;

  /// Uhrzeit der Station: Sie stellt die Tore, sobald der Detektiv dort ist.
  final Uhrzeit zeit;

  /// Wohin der Detektiv geht.
  final String ebene, ort;

  /// Figuren ohne Verdacht an Orten der [ebene].
  final List<RundgangFigur> figuren;

  /// Text für jedes Ende, sonst `null` (dann [jeEnde]).
  final RundgangText? text;

  /// Text je Ende-Kennung (nur am Morgen); leer, wenn [text] gilt.
  final Map<String, RundgangText> jeEnde;

  /// Lage dieser Station (immer der lange Abend).
  WeltLage get lage => WeltLage(lang: true, uhr: zeit);

  /// Text zum gezogenen Ende [ende] (Morgen), sonst der gemeinsame.
  RundgangText textFuer(String? ende) => jeEnde[ende] ?? text ?? jeEnde.values.first;

  /// Alle Texte der Station (gemeinsam und je Ende).
  Iterable<(String, RundgangText)> get texte sync* {
    if (text case final t?) yield (id, t);
    for (final e in jeEnde.entries) {
      yield ('$id/${e.key}', e.value);
    }
  }
}

/// Ein Rundgang: Startpunkt und Stationen in Reihenfolge.
class Rundgang {
  const Rundgang({required this.teil, required this.startEbene, required this.startOrt, required this.startZeit, required this.stationen});

  final RundgangTeil teil;
  final String startEbene, startOrt;
  final Uhrzeit startZeit;
  final List<RundgangStation> stationen;

  /// Lage beim Start.
  WeltLage get startLage => WeltLage(lang: true, uhr: startZeit);

  /// Lage der Station [i], vor der ersten die des Starts.
  WeltLage lageBei(int i) => i < 0 ? startLage : stationen[i].lage;

  /// Lage, in der der Weg zur Station [i] läuft: die der Station davor (vor der
  /// ersten die des Starts). So schließt Herr Schneider erst ab, wenn der
  /// Detektiv im Keller ist.
  WeltLage wegLage(int i) => lageBei(i - 1);

  factory Rundgang._aus(RundgangTeil teil, Map j) {
    final wo = teil.name;
    _nur(j, const {'start', 'stationen'}, wo);
    final s = j['start'] as Map;
    _nur(s, const {'ebene', 'ort', 'zeit'}, '$wo.start');
    return Rundgang(
      teil: teil,
      startEbene: s['ebene'] as String,
      startOrt: s['ort'] as String,
      startZeit: Uhrzeit.parse(s['zeit'] as String),
      stationen: List.unmodifiable([
        for (final (i, e) in (j['stationen'] as List).indexed) _station(e as Map, '$wo.stationen[$i]'),
      ]),
    );
  }

  static RundgangStation _station(Map j, String wo) {
    _nur(j, const {'id', 'zeit', 'ebene', 'ort', 'figuren', 'text', 'jeEnde'}, wo);
    return RundgangStation(
      id: j['id'] as String,
      zeit: Uhrzeit.parse(j['zeit'] as String),
      ebene: j['ebene'] as String,
      ort: j['ort'] as String,
      figuren: List.unmodifiable([
        for (final f in (j['figuren'] as List? ?? const []).cast<Map>())
          () {
            _nur(f, const {'figur', 'ort'}, '$wo.figuren');
            return RundgangFigur(figur: f['figur'] as String, ort: f['ort'] as String);
          }(),
      ]),
      text: j['text'] == null ? null : RundgangText._aus(j['text'] as Map, '$wo.text'),
      jeEnde: Map.unmodifiable({
        for (final e in ((j['jeEnde'] as Map?) ?? const {}).entries) e.key as String: RundgangText._aus(e.value as Map, '$wo.jeEnde.${e.key}'),
      }),
    );
  }
}

/// Vorspiel und Morgen einer Akte, unveränderlich.
class VorspielMorgen {
  const VorspielMorgen._(this.akte, this.vorspiel, this.morgen);

  final String akte;
  final Rundgang vorspiel, morgen;

  /// Der Rundgang [teil].
  Rundgang rundgang(RundgangTeil teil) => teil == RundgangTeil.vorspiel ? vorspiel : morgen;

  /// Liest `{"format": "vorspiel_morgen/1", "akte": …, "vorspiel": …, "morgen": …}`.
  /// Unbekannte Felder sind ein Fehler.
  factory VorspielMorgen.ausJson(Map<String, Object?> j) {
    if (j['format'] != vorspielMorgenFormat) throw FormatException('Vorspiel und Morgen: Format ${j['format']} statt $vorspielMorgenFormat');
    _nur(j, const {'format', 'akte', 'hinweis', 'vorspiel', 'morgen'}, 'Vorspiel und Morgen');
    return VorspielMorgen._(
      j['akte'] as String,
      Rundgang._aus(RundgangTeil.vorspiel, j['vorspiel'] as Map),
      Rundgang._aus(RundgangTeil.morgen, j['morgen'] as Map),
    );
  }
}

void _nur(Map m, Set<String> erlaubt, String wo) {
  final fremd = m.keys.where((k) => !erlaubt.contains(k));
  if (fremd.isNotEmpty) throw FormatException('$wo: unbekanntes Feld ${fremd.join(', ')}');
}

// ---------------------------------------------------------------- Prüfen

final _wortRe = RegExp(r'[\p{L}]+(?:-[\p{L}]+)*', unicode: true);
final _ziffer = RegExp(r'\p{N}', unicode: true);

/// Wortanfänge, die Urteil oder Auflösung verraten. Gemeinsame Texte (Vorspiel
/// und jede Station ohne [RundgangStation.jeEnde]) sind damit ende-neutral:
/// Sie passen zu jedem Ende und jedem Täterpfad.
const urteilsWoerter = [
  'gesteh', 'gestand', 'geständ', 'schuld', 'unschuld', 'anklag', 'angeklagt', 'verhaft', 'polizei', 'überführ', 'entlarv',
  'festgenommen', 'gelöst', 'aufgeklärt', 'lösung', 'falsch',
];

/// Kachel, auf der der Detektiv am Ort ([x], [y]) steht: die des Orts oder,
/// steht dort ein Möbelstück, die nächste begehbare Nachbarkachel.
Pt? _standkachel(TileGrid r, double x, double y) {
  final k = Pt(x.floor(), y.floor());
  if (r.walkable(k.x, k.y)) return k;
  Pt? best;
  var bestD = double.infinity;
  for (var dy = -1; dy <= 1; dy++) {
    for (var dx = -1; dx <= 1; dx++) {
      if (!r.walkable(k.x + dx, k.y + dy)) continue;
      final d = dist(k.x + dx + 0.5, k.y + dy + 0.5, x, y);
      if (d < bestD) {
        bestD = d;
        best = Pt(k.x + dx, k.y + dy);
      }
    }
  }
  return best;
}

/// Prüft [v] gegen die Welt-Ebenen [w] und deren Kanon. Liefert Befunde als
/// Sätze; leer heißt in Ordnung.
///
/// - Aufbau: [rundgangStationenMin] bis [rundgangStationenMax] Stationen je
///   Rundgang, eindeutige Kennungen, die weder dem Kanon noch den Ebenen
///   gehören. Jede Station hat genau einen gemeinsamen Text oder Texte je
///   Ende; je Ende nur am Morgen und dann für genau die Enden der Akte.
/// - Zeit und Tore: Das Vorspiel beginnt draußen vor der Sperre und endet mit
///   der Station zur Sperre (Kanon-Zeitleiste) im Keller; ihr Text nennt jedes
///   Tor, das dann zugeht. Der Morgen beginnt im Keller zur Morgenzeit, seine
///   erste Station liegt genau dort und nennt jedes Tor, das dann aufgeht.
///   Die Uhrzeiten steigen nie.
/// - Erreichbarkeit: Jeder Ort steht auf seiner Ebene; die Ebene ist in der
///   Lage der Station zugänglich, und der Detektiv kommt vom Ort davor in der
///   Lage des Wegs ([Rundgang.wegLage]) über offene Türen und Portale dorthin.
///   Im Keller ist nur der Ermittlungsort des Detektivs ein Ort (dort läuft der
///   Abend weiter), Figuren stehen nur auf den neuen Ebenen.
/// - Figuren: bekannte Kanon-Personen, nie der Detektiv und nie ein
///   Kernverdächtiger, höchstens [rundgangFigurenMax], jede einmal, an einem
///   freien Ort der Ebene, aber nicht dort, wohin der Detektiv geht.
/// - Karten nach R17: Titel mit höchstens [rundgangTitelWorte] Wörtern, ein bis
///   [rundgangPunkteMax] Stichpunkte mit höchstens [rundgangPunktWorte] Wörtern.
/// - Keine Fallhinweise (R15): keine Ziffern, kein Geburtstag, kein
///   Spoilerwort ([spoilerWoerter] außer dem Namen des Opfers), kein
///   Gegenstand, kein Name und keine Kennung eines Kernverdächtigen, keine
///   Fünf-Wort-Folge aus den geheimen Feldern ([geheimeFelder]) oder aus
///   [geschuetzt] (meist `steckbriefGeschuetzt`: Dossiers, Täterfassungen,
///   Finale und Auflösung). Gemeinsame Texte sind ende-neutral
///   ([urteilsWoerter], kein Wort aus dem Namen eines Endes).
/// - Ton ([ton]): Tonregeln wie alle Spielertexte, Vorlesetexte als
///   Vorlesetext (keine Ziffern, Abkürzungen, Klammern), Mittelwert der
///   Satzlängen über alle Vorlesetexte; Raumwörter nur für Räume des Kanons,
///   der Ebenen oder aus `raumAusnahmen` in [regeln].
/// - Höchstens [rundgangWorteGesamt] Wörter in Vorspiel und Morgen zusammen.
List<String> pruefeVorspielMorgen(VorspielMorgen v, WeltEbenen w, {Textpruefer? ton, Map<String, Object?>? regeln, Map<String, String> geschuetzt = const {}}) {
  final f = <String>[];
  final kanon = w.kanon;
  if (v.akte != w.akte) f.add('Akte ${v.akte} passt nicht zu den Ebenen von ${w.akte}');
  final detektivOrt = (kanon.figur((kanon.figurenJson['detektiv'] as Map)['id'] as String)!)['ermittlungsOrt'] as String;
  final detektiv = (kanon.figurenJson['detektiv'] as Map)['id'] as String;
  final verdaechtig = {...kanon.kernverdaechtige};
  final enden = [for (final r in Enden(kanon).regeln) r.id];

  // Kennungen: eindeutig, weder Kanon noch Ebenen.
  final kanonIds = <String>{...kanon.graph.orte.keys};
  void sammle(Object? x) {
    if (x is Map) {
      for (final e in x.entries) {
        if (e.key == 'id' && e.value is String) kanonIds.add(e.value as String);
        sammle(e.value);
      }
    } else if (x is List) {
      x.forEach(sammle);
    }
  }

  kanon.json.values.forEach(sammle);
  final ebenenIds = {for (final (_, id) in w.kennungen) id};
  final gesehen = <String>{};
  for (final r in [v.vorspiel, v.morgen]) {
    for (final s in r.stationen) {
      if (!gesehen.add(s.id)) f.add('${r.teil.name}: Station ${s.id} kommt doppelt vor');
      if (kanonIds.contains(s.id) || ebenenIds.contains(s.id)) f.add('${r.teil.name}: Kennung ${s.id} gehört dem Kanon oder den Ebenen');
    }
  }

  for (final r in [v.vorspiel, v.morgen]) {
    f.addAll(_pruefeRundgang(r, w, detektivOrt: detektivOrt, detektiv: detektiv, verdaechtig: verdaechtig, enden: enden));
  }
  f.addAll(_pruefeTore(v, w));
  f.addAll(_pruefeTexte(v, w, ton: ton, regeln: regeln, geschuetzt: geschuetzt));
  return f;
}

/// Aufbau, Zeiten, Erreichbarkeit und Figuren eines Rundgangs.
List<String> _pruefeRundgang(Rundgang r, WeltEbenen w,
    {required String detektivOrt, required String detektiv, required Set<String> verdaechtig, required List<String> enden}) {
  final f = <String>[];
  final wo = r.teil.name;
  final z = w.zeiten;
  final n = r.stationen.length;
  if (n < rundgangStationenMin || n > rundgangStationenMax) f.add('$wo: $n Stationen (erlaubt $rundgangStationenMin–$rundgangStationenMax)');
  if (n == 0) return f;

  // Zeiten: Vorspiel vor der Sperre bis zur Sperre, Morgen ab der Morgenzeit; nie zurück.
  if (r.teil == RundgangTeil.vorspiel) {
    if (!(r.startZeit < z.sperre)) f.add('$wo: Start ${r.startZeit} liegt nicht vor der Sperre ${z.sperre}');
    if (r.startEbene == kellerEbene) f.add('$wo: beginnt im Keller statt draußen');
    if (r.stationen.last.zeit != z.sperre) f.add('$wo: letzte Station ${r.stationen.last.id} liegt nicht bei der Sperre ${z.sperre}');
    if (r.stationen.last.ebene != kellerEbene) f.add('$wo: endet nicht im Keller');
    for (final s in r.stationen.take(n - 1)) {
      if (!(s.zeit < z.sperre)) f.add('$wo: Station ${s.id} um ${s.zeit} liegt nicht vor der Sperre');
    }
  } else {
    if (r.startZeit != z.morgen) f.add('$wo: Start ${r.startZeit} liegt nicht bei der Morgenzeit ${z.morgen}');
    if (r.startEbene != kellerEbene) f.add('$wo: beginnt nicht im Keller');
    if (r.stationen.first.zeit != z.morgen) f.add('$wo: erste Station ${r.stationen.first.id} liegt nicht bei der Morgenzeit ${z.morgen}');
  }
  var vorher = r.startZeit;
  for (final s in r.stationen) {
    if (s.zeit < vorher) f.add('$wo: Station ${s.id} um ${s.zeit} liegt vor der Station davor');
    vorher = s.zeit;
  }

  // Orte und Erreichbarkeit.
  Pt? kachel(String ebene, String ort, String was) {
    final e = w.ebenen[ebene];
    if (e == null) {
      f.add('$wo: $was nennt unbekannte Ebene $ebene');
      return null;
    }
    final o = e.graph.orte[ort];
    if (o == null) {
      f.add('$wo: $was nennt unbekannten Ort $ort auf $ebene');
      return null;
    }
    if (ebene == kellerEbene && ort != detektivOrt) f.add('$wo: $was führt im Keller an $ort statt an den Ermittlungsort $detektivOrt');
    final k = _standkachel(w.raster(ebene, WeltLage(lang: true, uhr: w.zeiten.morgen)), o.x, o.y);
    if (k == null) f.add('$wo: $was: am Ort $ort steht kein Platz frei');
    return k;
  }

  var hier = kachel(r.startEbene, r.startOrt, 'Start');
  var hierEbene = r.startEbene;
  if (!w.zugangOffen(r.startEbene, r.startLage)) f.add('$wo: Start auf ${r.startEbene} ist um ${r.startZeit} nicht zugänglich');
  for (final (i, s) in r.stationen.indexed) {
    final k = kachel(s.ebene, s.ort, 'Station ${s.id}');
    if (!w.ebenen.containsKey(s.ebene)) continue;
    if (!w.zugangOffen(s.ebene, s.lage)) f.add('$wo: Station ${s.id}: ${s.ebene} ist um ${s.zeit} nicht zugänglich');
    if (k != null && hier != null) {
      final weg = r.wegLage(i);
      if (!(w.erreichbar(weg, von: (hierEbene, hier))[s.ebene]?.contains(k) ?? false)) {
        f.add('$wo: Station ${s.id} (${s.ebene}/${s.ort}) ist um ${weg.uhr} vom Ort davor nicht erreichbar');
      }
    }
    hier = k;
    hierEbene = s.ebene;

    // Texte: gemeinsam oder je Ende.
    if ((s.text == null) == s.jeEnde.isEmpty) f.add('$wo: Station ${s.id} braucht genau einen gemeinsamen Text oder Texte je Ende');
    if (s.jeEnde.isNotEmpty) {
      if (r.teil != RundgangTeil.morgen) f.add('$wo: Station ${s.id}: Texte je Ende gibt es nur am Morgen');
      final soll = enden.toSet(), ist = s.jeEnde.keys.toSet();
      if (soll.length != ist.length || !soll.containsAll(ist)) f.add('$wo: Station ${s.id}: Texte je Ende für ${ist.join(', ')} statt für ${soll.join(', ')}');
    }

    // Figuren.
    if (s.figuren.length > rundgangFigurenMax) f.add('$wo: Station ${s.id}: ${s.figuren.length} Figuren (höchstens $rundgangFigurenMax)');
    final figuren = <String>{};
    for (final x in s.figuren) {
      if (!figuren.add(x.figur)) f.add('$wo: Station ${s.id}: ${x.figur} steht doppelt da');
      if (w.kanon.figur(x.figur) == null) f.add('$wo: Station ${s.id}: Figur ${x.figur} gibt es nicht');
      if (x.figur == detektiv) f.add('$wo: Station ${s.id}: Der Detektiv ist keine Figur einer Station');
      if (verdaechtig.contains(x.figur)) f.add('$wo: Station ${s.id}: ${x.figur} ist kernverdächtig (R15)');
      if (s.ebene == kellerEbene) {
        f.add('$wo: Station ${s.id}: Im Keller stehen die Figuren an ihren Ermittlungsorten, nicht an Stationen');
        continue;
      }
      final o = w.ebenen[s.ebene]?.graph.orte[x.ort];
      if (o == null) {
        f.add('$wo: Station ${s.id}: Figur ${x.figur} steht an unbekanntem Ort ${x.ort}');
      } else if (x.ort == s.ort) {
        f.add('$wo: Station ${s.id}: Figur ${x.figur} steht dort, wohin der Detektiv geht');
      } else if (!w.raster(s.ebene, s.lage).canStand(o.x, o.y, 0.28)) {
        f.add('$wo: Station ${s.id}: Figur ${x.figur} steht bei ${x.ort} nicht frei');
      }
    }
  }
  if (!r.stationen.any((s) => _draussen(w, s.ebene, s.ort))) f.add('$wo: keine Station liegt unter freiem Himmel');
  return f;
}

/// Liegt der Ort [ort] der Ebene [ebene] in einem Raum unter freiem Himmel ([Ebene.aussen])?
bool _draussen(WeltEbenen w, String ebene, String ort) {
  final e = w.ebenen[ebene];
  final o = e?.graph.orte[ort];
  if (e == null || o == null) return false;
  return e.aussen.contains(e.graph.raumAn(o.x, o.y)?.id);
}

/// Tore, die zwischen zwei Lagen auf- oder zugehen, mit dem Namen ihrer Tür
/// auf der neuen Ebene (Hoftür, Einfahrtstor, Außentor).
Set<String> _toreZwischen(WeltEbenen w, WeltLage vorher, WeltLage nachher, {required bool auf}) => {
      for (final p in w.portale)
        if (w.offen(p.offen, vorher) != w.offen(p.offen, nachher) && w.offen(p.offen, nachher) == auf)
          for (final s in [p.a, p.b])
            if (w.ebenen[s.ebene] case final e? when !e.ausKanon)
              for (final t in e.graph.tueren.values)
                if (t.kacheln.any(s.kacheln.contains)) t.name,
    };

/// Die Sperre nennt jedes Tor, das um zehn vor sieben zugeht; die erste
/// Station am Morgen jedes, das um sieben aufgeht (Kanon-Zeitleiste).
List<String> _pruefeTore(VorspielMorgen v, WeltEbenen w) {
  final f = <String>[];
  final z = w.zeiten;
  final zu = _toreZwischen(w, WeltLage(lang: true, uhr: z.sperre.plus(-1)), WeltLage(lang: true, uhr: z.sperre), auf: false);
  final auf = _toreZwischen(w, WeltLage(lang: true, uhr: z.morgen.plus(-1)), WeltLage(lang: true, uhr: z.morgen), auf: true);
  if (zu.isEmpty) f.add('Zur Sperre geht kein Tor zu');
  if (auf.isEmpty) f.add('Am Morgen geht kein Tor auf');
  void nennt(RundgangStation? s, Set<String> tore, String was) {
    if (s == null) return;
    for (final (id, t) in s.texte) {
      for (final tor in tore) {
        if (!t.vorlesen.contains(tor)) f.add('$id: Der Vorlesetext $was nennt das $tor nicht');
      }
    }
  }

  nennt(v.vorspiel.stationen.lastOrNull, zu, 'zur Sperre');
  nennt(v.morgen.stationen.firstOrNull, auf, 'am Morgen');
  return f;
}

/// R17, Ton, Raumwörter, R15 und Ende-Neutralität aller Texte.
List<String> _pruefeTexte(VorspielMorgen v, WeltEbenen w, {Textpruefer? ton, Map<String, Object?>? regeln, required Map<String, String> geschuetzt}) {
  final f = <String>[];
  final kanon = w.kanon;
  final opfer = ((kanon.figurenJson['opfer'] as Map)['name'] as String).split(' ').last.toLowerCase();
  // Spoilerwörter und Gegenstände (R15), außer dem Namen des Opfers: Herr Schneider gehört zum Rahmen.
  final sperren = <RegExp>[
    for (final s in spoilerWoerter)
      if (!s.startsWith(opfer)) wortAnfang(s),
    for (final g in kanon.gegenstaende)
      for (final k in kennwoerter(g['name'] as String))
        if (!k.startsWith(opfer)) wortAnfang(k),
  ];
  final verdaechtige = <RegExp>[
    for (final id in kanon.kernverdaechtige) ...[
      RegExp('(?<!\\p{L})${RegExp.escape(id)}(?!\\p{L})', unicode: true, caseSensitive: false),
      if (kanon.figur(id)?['name'] case final String name) RegExp('(?<!\\p{L})${RegExp.escape(name)}(?!\\p{L})', unicode: true, caseSensitive: false),
    ],
  ];
  final geheim = <String, String>{};
  for (final e in {...geheimeFelder(kanon), ...geschuetzt}.entries) {
    for (final folge in fuenfWortFolgen(e.value)) {
      geheim.putIfAbsent(folge, () => e.key);
    }
  }
  final endeWoerter = {
    for (final r in Enden(kanon).regeln)
      for (final m in _wortRe.allMatches(r.name))
        if (m.group(0)!.length >= 5) m.group(0)!.toLowerCase(),
  };
  final endungen = [for (final x in (regeln?['raumwortEndungen'] as List? ?? const [])) (x as String).toLowerCase()];
  final raumworte = <String>{
    for (final n in [
      for (final r in kanon.graph.raeume.values) ...[r.name, r.anzeigename],
      for (final e in w.ebenen.values)
        if (!e.ausKanon)
          for (final r in e.graph.raeume.values) ...[r.name, r.anzeigename],
      ...((regeln?['raumAusnahmen'] as List?) ?? const []).cast<String>(),
    ])
      for (final m in _wortRe.allMatches(n)) m.group(0)!.toLowerCase(),
  };

  var worte = 0;
  final vorlesen = <TextQuelle>[];
  for (final r in [v.vorspiel, v.morgen]) {
    for (final s in r.stationen) {
      for (final (id, t) in s.texte) {
        final wo = '${r.teil.name}/$id';
        final gemeinsam = s.jeEnde.isEmpty;
        worte += t.woerter;
        // R17
        final tw = stichpunktWoerter(t.titel);
        if (tw == 0 || tw > rundgangTitelWorte) f.add('$wo: Titel mit $tw Wörtern (1 bis $rundgangTitelWorte): ${t.titel}');
        if (t.punkte.isEmpty || t.punkte.length > rundgangPunkteMax) f.add('$wo: ${t.punkte.length} Stichpunkte statt 1 bis $rundgangPunkteMax (R17)');
        for (final p in t.punkte) {
          final pw = stichpunktWoerter(p);
          if (pw == 0 || pw > rundgangPunktWorte) f.add('$wo: Stichpunkt mit $pw Wörtern statt höchstens $rundgangPunktWorte (R17): $p');
        }
        if (t.vorlesen.trim().isEmpty) f.add('$wo: Vorlesetext fehlt');
        final quellen = [
          TextQuelle(ort: '$wo.titel', text: t.titel, vorlesen: false),
          for (final (i, p) in t.punkte.indexed) TextQuelle(ort: '$wo.punkte[$i]', text: p, vorlesen: false),
          TextQuelle(ort: '$wo.vorlesen', text: t.vorlesen, vorlesen: true),
        ];
        vorlesen.add(quellen.last);
        for (final q in quellen) {
          if (ton != null) {
            for (final b in ton.pruefe(q)) {
              f.add('${b.ort}: ${b.regel}: ${b.auszug}');
            }
          }
          if (_ziffer.hasMatch(q.text)) f.add('${q.ort}: Ziffern verraten Zeiten oder Mengen: ${q.text}');
          if (q.text.toLowerCase().contains('geburtstag')) f.add('${q.ort}: Geburtstag (A-061): ${q.text}');
          for (final re in sperren) {
            final m = re.firstMatch(q.text);
            if (m != null) f.add('${q.ort}: „${m.group(0)}“ gehört nicht in Vorspiel oder Morgen (R15)');
          }
          for (final re in verdaechtige) {
            final m = re.firstMatch(q.text);
            if (m != null) f.add('${q.ort}: nennt ${m.group(0)} (R15)');
          }
          for (final folge in fuenfWortFolgen(q.text)) {
            final quelle = geheim[folge];
            if (quelle != null) f.add('${q.ort}: „$folge“ stammt aus $quelle');
          }
          for (final m in _wortRe.allMatches(q.text)) {
            final wort = m.group(0)!.toLowerCase();
            if (endungen.any(wort.endsWith) && !raumworte.contains(wort)) f.add('${q.ort}: Raumwort „${m.group(0)}“ ist kein Raum');
            if (gemeinsam && (urteilsWoerter.any(wort.startsWith) || endeWoerter.contains(wort))) {
              f.add('${q.ort}: „${m.group(0)}“ passt nicht zu jedem Ende');
            }
          }
        }
      }
    }
  }
  if (ton != null) {
    for (final b in ton.pruefeMittel('vorspiel_morgen.json', vorlesen)) {
      f.add('${b.ort}: ${b.regel}: ${b.auszug}');
    }
  }
  if (worte > rundgangWorteGesamt) f.add('Vorspiel und Morgen haben $worte Wörter (höchstens $rundgangWorteGesamt)');
  return f;
}
