/// Erkundung des langen Abends (M7b, Streifzug): Orte im Schloss, die der
/// Detektiv in den Runden frei besuchen kann, und benannte Treffpunkte für
/// seine Befragungen (`content/welt/<akte>/erkundung.json`, Format
/// `erkundung/1`).
///
/// Die Erkundung ist reine Stimmung: Schloss, Nacht, Wetter, Alltag der Gäste.
/// Sie kostet keine Nachtminuten, würfelt nicht, liest weder Partie noch
/// Zugschicht und ist in allen Pfaden gleich. Kosmetischer Zufall (Variante
/// eines Orts, Treffpunkt einer Befragung) zieht nur aus
/// `Rng(Rng.hashString('lang:$weltSamen:…'))`, nie aus dem Würfelstrom.
library;

import '../karten/geruechte.dart';
import '../karten/sperrwoerter.dart';
import '../party/kanon/kanon.dart';
import '../party/raumgraph.dart';
import '../party/textpruefer.dart';
import '../party/zeit.dart';
import '../scenario/grid.dart';
import '../util/geom.dart';
import '../util/rng.dart';
import 'ebenen.dart';

/// Kennung des Dateiformats.
const erkundungFormat = 'erkundung/1';

/// So viele Erkundungsorte hat eine Akte mit Langfassung.
const erkundungAnzahl = 15;

/// Grenzen der Treffpunkte für die Befragungen.
const treffpunkteMindestens = 8, treffpunkteHoechstens = 12;

/// Kartenformat R17: höchstens drei Stichpunkte zu je höchstens acht Wörtern.
const erkundungPunkte = 3, erkundungWorte = 8;

/// Höchstens so viele Wörter haben der Titel eines Orts und die Anzeige eines
/// Treffpunkts („am Brunnen“).
const erkundungTitelWorte = 5, treffpunktWorte = 6;

/// Höchstens so viele Varianten neben den Stichpunkten hat ein Ort.
const erkundungVarianten = 3;

/// Reihum (ein Gerät, mehrere Menschen) läuft der Detektiv je Runde höchstens
/// so viele freie Erkundungen; danach gehört die Zeit dem Tisch. Solo und
/// online gibt es keinen Deckel.
const streifzugDeckelReihum = 5;

/// Samen der Welt des langen Abends aus dem Salz eines Abends (Gerät oder
/// Raum): Quelle allen kosmetischen Zufalls (`lang:$weltSamen:…`). Er berührt
/// den Würfelstrom nie und verlässt weder Raum noch Gastgebergerät.
int weltSamenAus(String salz) => Rng.hashString('welt:$salz');

/// Abstand (Kacheln), den ein Erkundungsort im Keller zu jedem Sperrort hält.
const kellerRandAbstand = 3.0;

/// Ziel eines Erkundungsorts auf seiner Ebene: ein Ort des Raumgraphen, ein
/// Möbelstück (Einrichtung) oder eine Kachel. Genau eines ist gesetzt.
class ErkundungsZiel {
  const ErkundungsZiel({this.ort, this.ding, this.kachel});

  final String? ort;
  final String? ding;
  final Pt? kachel;

  factory ErkundungsZiel._aus(Map j) => ErkundungsZiel(
        ort: j['ort'] as String?,
        ding: j['ding'] as String?,
        kachel: j['kachel'] == null ? null : Pt.fromJson(j['kachel']),
      );

  int get _gesetzt => [ort, ding, kachel].where((x) => x != null).length;

  @override
  String toString() => ort != null ? 'Ort $ort' : ding != null ? 'Einrichtung $ding' : 'Kachel $kachel';
}

/// Ein Erkundungsort: Titel, Stichpunkte (R17) und kosmetische Varianten.
class ErkundungsOrt {
  const ErkundungsOrt({required this.id, required this.ebene, required this.ziel, required this.titel, required this.stichpunkte, this.varianten = const []});

  final String id;
  final String ebene;
  final ErkundungsZiel ziel;
  final String titel;
  final List<String> stichpunkte;

  /// Weitere Fassungen der Stichpunkte; welche gilt, wählt [stichpunkteFuer].
  final List<List<String>> varianten;

  /// Fassung dieses Abends: 0 die Stichpunkte, sonst die Variante davor,
  /// gewählt mit `Rng(Rng.hashString('lang:$weltSamen:erkundung:<id>'))`.
  int fassungFuer(int weltSamen) =>
      varianten.isEmpty ? 0 : Rng(Rng.hashString('lang:$weltSamen:erkundung:$id')).nextInt(varianten.length + 1);

  /// Die Stichpunkte der Fassung [i] ([fassungFuer]); unbekannte Fassungen sind die Grundfassung.
  List<String> stichpunkteDer(int i) => i <= 0 || i > varianten.length ? stichpunkte : varianten[i - 1];

  /// Die Stichpunkte dieses Abends: Grundfassung oder eine Variante ([fassungFuer]).
  List<String> stichpunkteFuer(int weltSamen) => stichpunkteDer(fassungFuer(weltSamen));
}

/// Ein benannter Treffpunkt für Befragungen („Triff Ahmet am Brunnen“).
class Treffpunkt {
  const Treffpunkt({required this.id, required this.ebene, required this.ort, required this.anzeige});

  final String id;
  final String ebene;

  /// Ort des Raumgraphen der Ebene, an dem der Detektiv ankommt.
  final String ort;

  /// Anzeigeform nach „Triff X …“, etwa „am Brunnen“.
  final String anzeige;
}

/// Die Erkundung einer Akte, unveränderlich.
class Erkundung {
  Erkundung._(this.akte, this.orte, this.treffpunkte);

  final String akte;

  /// Erkundungsorte in Dateireihenfolge.
  final List<ErkundungsOrt> orte;

  /// Treffpunkte in Dateireihenfolge.
  final List<Treffpunkt> treffpunkte;

  /// Liest `{"format": "erkundung/1", "akte": …, "orte": […], "treffpunkte": […]}`.
  factory Erkundung.ausJson(Map<String, Object?> j) {
    if (j['format'] != erkundungFormat) throw FormatException('Erkundung: Format ${j['format']} statt $erkundungFormat');
    List<String> zeilen(Object? l) => List.unmodifiable([for (final z in l as List) z as String]);
    return Erkundung._(
      j['akte'] as String,
      List.unmodifiable([
        for (final o in (j['orte'] as List).cast<Map>())
          ErkundungsOrt(
            id: o['id'] as String,
            ebene: o['ebene'] as String,
            ziel: ErkundungsZiel._aus(o['ziel'] as Map),
            titel: o['titel'] as String,
            stichpunkte: zeilen(o['stichpunkte']),
            varianten: List.unmodifiable([for (final v in (o['varianten'] as List? ?? const [])) zeilen(v)]),
          ),
      ]),
      List.unmodifiable([
        for (final t in (j['treffpunkte'] as List).cast<Map>())
          Treffpunkt(id: t['id'] as String, ebene: t['ebene'] as String, ort: t['ort'] as String, anzeige: t['anzeige'] as String),
      ]),
    );
  }

  /// Erkundungsort [id], sonst `null`.
  ErkundungsOrt? ort(String id) => orte.where((o) => o.id == id).firstOrNull;

  /// Treffpunkt [id], sonst `null`.
  Treffpunkt? treffpunkt(String id) => treffpunkte.where((t) => t.id == id).firstOrNull;

  /// Treffpunkte der Befragungen einer Runde, in deren Reihenfolge
  /// ([befragungen], Kennungen `bf_<rolle>_<runde>`). Jede Befragung zieht mit
  /// `Rng(Rng.hashString('lang:$weltSamen:treff:<befragungId>'))` einen
  /// Treffpunkt; ist er in dieser Runde schon vergeben, gilt der nächste freie
  /// in Dateireihenfolge. Erst wenn alle vergeben sind, teilen sich zwei
  /// Befragungen einen Treffpunkt. Gleich auf jedem Gerät mit demselben Samen.
  Map<String, Treffpunkt> treffpunkteFuer(int weltSamen, List<String> befragungen) {
    final aus = <String, Treffpunkt>{};
    final vergeben = <int>{};
    for (final b in befragungen) {
      var i = Rng(Rng.hashString('lang:$weltSamen:treff:$b')).nextInt(treffpunkte.length);
      if (vergeben.length < treffpunkte.length) {
        while (vergeben.contains(i)) {
          i = (i + 1) % treffpunkte.length;
        }
      }
      vergeben.add(i);
      aus[b] = treffpunkte[i];
    }
    return aus;
  }
}

// ---------------------------------------------------------------- Lage und Stelle

/// Lagen der Runden im langen Abend: je Runde ihre Uhrzeit aus dem Kanon
/// (`fall.json`, Feld `uhrzeit`). Gespräche und Entscheidungen einer Runde
/// teilen sie (der Streifzug).
List<WeltLage> rundenLagen(Kanon kanon) => [
      for (final r in (kanon.fall['runden'] as List).cast<Map>()) WeltLage(lang: true, uhr: Uhrzeit.parse(r['uhrzeit'] as String)),
    ];

/// Raumgraph einer Ebene (im Keller der Kanon-Graph).
RaumGraph _graph(WeltEbenen w, String ebene) => w.ebenen[ebene]!.graph;

/// Stelle (Kachelkoordinaten), an der der Detektiv das Ziel von [o] erreicht:
/// der Ort selbst, bei einer Kachel ihre Mitte, bei einem Möbelstück die
/// erste freie Nachbarkachel im selben Raum (Reihenfolge Süd, Ost, West,
/// Nord, dann die Ecken). `null`, wenn es keine gibt. [raster] ist das
/// Raster der Ebene in der Lage (Vorgabe: alles offen).
(double, double)? erkundungsStelle(WeltEbenen w, ErkundungsOrt o, {TileGrid? raster}) {
  final e = w.ebenen[o.ebene];
  if (e == null || o.ziel._gesetzt != 1) return null;
  final g = e.graph;
  final r = raster ?? w.raster(o.ebene, WeltLage(lang: true, uhr: w.zeiten.morgen));
  if (o.ziel.ort case final id?) {
    final ort = g.orte[id];
    return ort == null ? null : (ort.x, ort.y);
  }
  if (o.ziel.kachel case final k?) return (k.x + 0.5, k.y + 0.5);
  final d = g.einrichtung[o.ziel.ding];
  if (d == null) return null;
  final raum = g.raumAn(d.x + 0.5, d.y + 0.5)?.id;
  if (!d.blockiert && r.canStand(d.x + 0.5, d.y + 0.5, 0.28)) return (d.x + 0.5, d.y + 0.5);
  for (final (dx, dy) in const [(0, 1), (1, 0), (-1, 0), (0, -1), (1, 1), (-1, 1), (1, -1), (-1, -1)]) {
    final x = d.x + dx + 0.5, y = d.y + dy + 0.5;
    if (r.canStand(x, y, 0.28) && g.raumAn(x, y)?.id == raum) return (x, y);
  }
  return null;
}

/// Stelle eines Treffpunkts: sein Ort auf der Ebene.
(double, double)? treffpunktStelle(WeltEbenen w, Treffpunkt t) {
  final o = w.ebenen[t.ebene]?.graph.orte[t.ort];
  return o == null ? null : (o.x, o.y);
}

// ---------------------------------------------------------------- Prüfen

/// Gruppen, über die sich die Erkundung verteilt: Keller-Rand, Erdgeschoss
/// drinnen, Hof und Garten (Außenräume des Erdgeschosses), Turm.
String? erkundungsGruppe(WeltEbenen w, ErkundungsOrt o, (double, double) stelle) {
  final e = w.ebenen[o.ebene];
  if (e == null) return null;
  if (e.ausKanon) return 'keller';
  if (o.ebene == 'erdgeschoss') {
    final raum = e.graph.raumAn(stelle.$1, stelle.$2)?.id;
    return raum != null && e.aussen.contains(raum) ? 'hof_garten' : 'erdgeschoss';
  }
  return o.ebene;
}

/// Gruppen, die jede Erkundung abdeckt.
const erkundungsGruppen = ['keller', 'erdgeschoss', 'hof_garten', 'turm'];

/// Beinamen, die eine Erkundung zusätzlich nennen darf: Der Turm ist im
/// langen Abend eine eigene Ebene (Turmzimmer, Wehrgang). Der Turmgang selbst
/// bleibt über die Ziel-Räume gesperrt (auch das bloße Wort „Turm“).
const _erkundungOhneBeinamen = {'turm'};

/// Prüft [e] gegen die Welt-Ebenen [w] und ihren Kanon. Liefert Befunde als
/// Sätze; leer heißt in Ordnung.
///
/// - Genau [erkundungAnzahl] Orte und [treffpunkteMindestens] bis
///   [treffpunkteHoechstens] Treffpunkte, alle Kennungen eindeutig und keine
///   aus dem Kanon oder den Ebenen.
/// - Jeder Ort liegt auf einer Ebene, die in jeder Runde ([rundenLagen])
///   zugänglich ist, nie in der Außenwelt; sein Ziel ist genau eines von
///   Ort, Einrichtung oder Kachel der Ebene. Seine Stelle
///   ([erkundungsStelle]) steht frei und ist in jeder Runde vom Keller aus
///   über offene Türen und Portale erreichbar; zwei Orte liegen nie im
///   Ankunftsradius voneinander. Die Orte decken [erkundungsGruppen] ab.
/// - Im Keller (Keller-Rand) nur Orte des Kanons, kein Sperrort, kein
///   Ziel-Raum einer Entscheidung und mindestens [kellerRandAbstand] Kacheln
///   von jedem Sperrort entfernt.
/// - Treffpunkte liegen im Erdgeschoss oder Turm (Hof, Garten, Halle, Küche,
///   Turmzimmer, Wehrgang) an einem Ort der Ebene, der in jeder Runde
///   erreichbar ist; zwei Treffpunkte liegen nicht auf demselben Ort.
/// - Texte: Titel höchstens [erkundungTitelWorte] Wörter, ein bis
///   [erkundungPunkte] Stichpunkte zu je höchstens [erkundungWorte] Wörtern
///   und je einem Satz (R17), höchstens [erkundungVarianten] Varianten in
///   derselben Form, Anzeigen höchstens [treffpunktWorte] Wörter. Kein
///   Sperrwort, kein Name, kein Gegenstand, kein Sperrort, keine Suchstelle,
///   kein Beiname und kein Fünf-Wort-Leck aus geschützten Kanonstellen
///   ([PfadgleichRegeln], wie bei den Gerüchten), kein Geburtstag, Raumwörter
///   nur für Räume des Kanons und der Ebenen oder aus `raumAusnahmen` in
///   [regeln], Tonregeln über [ton].
List<String> pruefeErkundung(Erkundung e, WeltEbenen w, {Textpruefer? ton, Map<String, Object?>? regeln, Iterable<String> geschuetzt = const []}) {
  final f = <String>[];
  final kanon = w.kanon;
  if (e.akte != w.akte) f.add('akte ${e.akte} statt ${w.akte}');
  if (e.orte.length != erkundungAnzahl) f.add('${e.orte.length} Erkundungsorte statt $erkundungAnzahl');
  if (e.treffpunkte.length < treffpunkteMindestens || e.treffpunkte.length > treffpunkteHoechstens) {
    f.add('${e.treffpunkte.length} Treffpunkte (erlaubt $treffpunkteMindestens–$treffpunkteHoechstens)');
  }

  // Kennungen: eindeutig, keine aus dem Kanon oder den Ebenen.
  final fremd = <String>{
    for (final (_, id) in w.kennungen) id,
    ...kanon.graph.orte.keys,
    ...kanon.graph.raeume.keys,
    ...kanon.graph.einrichtung.keys,
    ...kanon.graph.tueren.keys,
    for (final f in kanon.figuren) f['id'] as String,
    for (final g in kanon.gegenstaende) g['id'] as String,
  };
  final gesehen = <String>{};
  for (final id in [for (final o in e.orte) o.id, for (final t in e.treffpunkte) t.id]) {
    if (!gesehen.add(id)) f.add('Kennung $id kommt doppelt vor');
    if (fremd.contains(id)) f.add('Kennung $id gehört dem Kanon oder den Ebenen');
  }

  final lagen = rundenLagen(kanon);
  final erreicht = [for (final l in lagen) w.erreichbar(l)];
  final raster = {
    for (final id in w.ebenen.keys) id: [for (final l in lagen) w.raster(id, l)],
  };
  bool inJederRunde(String ebene, (double, double) p) {
    for (var i = 0; i < lagen.length; i++) {
      if (!w.zugangOffen(ebene, lagen[i])) return false;
      if (!raster[ebene]![i].canStand(p.$1, p.$2, 0.28)) return false;
      if (!erreicht[i][ebene]!.contains(Pt(p.$1.floor(), p.$2.floor()))) return false;
    }
    return true;
  }

  final sperrorte = _sperrorte(kanon);
  final zielRaeume = _zielRaeume(kanon);
  final stellen = <String, (double, double)>{};
  final gruppen = <String>{};
  for (final o in e.orte) {
    final eb = w.ebenen[o.ebene];
    if (eb == null) {
      f.add('${o.id}: Ebene ${o.ebene} gibt es nicht');
      continue;
    }
    if (o.ebene == 'aussen' || lagen.any((l) => !w.zugangOffen(o.ebene, l))) {
      f.add('${o.id}: Ebene ${o.ebene} ist nicht in jeder Runde zugänglich');
      continue;
    }
    if (o.ziel._gesetzt != 1) {
      f.add('${o.id}: Ziel braucht genau eines von ort, ding oder kachel');
      continue;
    }
    final g = _graph(w, o.ebene);
    if (o.ziel.ort != null && !g.orte.containsKey(o.ziel.ort)) f.add('${o.id}: Ort ${o.ziel.ort} gibt es auf ${o.ebene} nicht');
    if (o.ziel.ding != null && !g.einrichtung.containsKey(o.ziel.ding)) f.add('${o.id}: Einrichtung ${o.ziel.ding} gibt es auf ${o.ebene} nicht');
    if (o.ziel.kachel case final k? when k.x < 0 || k.y < 0 || k.x >= g.breite || k.y >= g.hoehe) f.add('${o.id}: Kachel $k liegt nicht auf ${o.ebene}');
    if (eb.ausKanon) {
      // Keller-Rand: nur Orte des Kanons, fern von allem, was der Fall untersucht.
      final ort = o.ziel.ort == null ? null : g.orte[o.ziel.ort];
      if (ort == null) {
        f.add('${o.id}: im Keller nur ein Ort des Kanons als Ziel');
      } else {
        if (sperrorte.contains(ort.id)) f.add('${o.id}: ${ort.id} ist ein Sperrort');
        if (zielRaeume.contains(ort.raum)) f.add('${o.id}: ${ort.raum} ist Ziel-Raum einer Entscheidung');
        for (final s in sperrorte) {
          final so = g.orte[s];
          if (so != null && dist(so.x, so.y, ort.x, ort.y) < kellerRandAbstand) f.add('${o.id}: liegt näher als $kellerRandAbstand Kacheln am Sperrort $s');
        }
      }
    }
    final stelle = erkundungsStelle(w, o, raster: raster[o.ebene]!.first);
    if (stelle == null) {
      f.add('${o.id}: Ziel ${o.ziel} hat keine freie Stelle');
      continue;
    }
    if (!inJederRunde(o.ebene, stelle)) f.add('${o.id}: Stelle (${stelle.$1}, ${stelle.$2}) auf ${o.ebene} ist nicht in jeder Runde frei und erreichbar');
    for (final MapEntry(key: id, value: p) in stellen.entries) {
      final a = e.ort(id)!;
      if (a.ebene == o.ebene && dist(p.$1, p.$2, stelle.$1, stelle.$2) < 1.0 + 1e-9) f.add('${o.id}: liegt im Ankunftsradius von $id');
    }
    stellen[o.id] = stelle;
    if (erkundungsGruppe(w, o, stelle) case final gr?) gruppen.add(gr);
  }
  for (final gr in erkundungsGruppen) {
    if (!gruppen.contains(gr)) f.add('kein Erkundungsort in der Gruppe $gr');
  }

  final treffOrte = <String>{};
  for (final t in e.treffpunkte) {
    if (t.ebene != 'erdgeschoss' && t.ebene != 'turm') {
      f.add('${t.id}: Treffpunkte liegen im Erdgeschoss oder im Turm, nicht auf ${t.ebene}');
      continue;
    }
    final stelle = treffpunktStelle(w, t);
    if (stelle == null) {
      f.add('${t.id}: Ort ${t.ort} gibt es auf ${t.ebene} nicht');
      continue;
    }
    if (!treffOrte.add('${t.ebene}/${t.ort}')) f.add('${t.id}: Ort ${t.ort} ist schon ein Treffpunkt');
    if (!inJederRunde(t.ebene, stelle)) f.add('${t.id}: ${t.ort} ist nicht in jeder Runde erreichbar');
  }

  f.addAll(_pruefeTexte(e, w, ton: ton, regeln: regeln, geschuetzt: geschuetzt));
  return f;
}

/// Alle Texte der Erkundung mit Fundstelle.
List<TextQuelle> erkundungsTexte(Erkundung e) => [
      for (final o in e.orte) ...[
        TextQuelle(ort: 'erkundung.json#${o.id}.titel', text: o.titel, vorlesen: false),
        for (final (i, z) in o.stichpunkte.indexed) TextQuelle(ort: 'erkundung.json#${o.id}.stichpunkte[$i]', text: z, vorlesen: false),
        for (final (v, liste) in o.varianten.indexed)
          for (final (i, z) in liste.indexed) TextQuelle(ort: 'erkundung.json#${o.id}.varianten[$v][$i]', text: z, vorlesen: false),
      ],
      for (final t in e.treffpunkte) TextQuelle(ort: 'erkundung.json#${t.id}.anzeige', text: t.anzeige, vorlesen: false),
    ];

final _wortRe = RegExp(r'[\p{L}\p{N}]+', unicode: true);
final _buchstabenRe = RegExp(r'[\p{L}]+(?:-[\p{L}]+)*', unicode: true);

List<String> _pruefeTexte(Erkundung e, WeltEbenen w, {Textpruefer? ton, Map<String, Object?>? regeln, Iterable<String> geschuetzt = const []}) {
  final f = <String>[];
  final kanon = w.kanon;
  int worte(String t) => _wortRe.allMatches(t).length;

  // Formen: Titel, Stichpunkte und Varianten (R17), Anzeigen.
  for (final o in e.orte) {
    if (o.titel.trim().isEmpty || worte(o.titel) > erkundungTitelWorte) f.add('${o.id}: Titel mit ${worte(o.titel)} Wörtern (1–$erkundungTitelWorte)');
    if (o.varianten.length > erkundungVarianten) f.add('${o.id}: ${o.varianten.length} Varianten (höchstens $erkundungVarianten)');
    for (final (v, liste) in [('Stichpunkte', o.stichpunkte), for (final (i, l) in o.varianten.indexed) ('Variante ${i + 1}', l)]) {
      if (liste.isEmpty || liste.length > erkundungPunkte) f.add('${o.id}: $v mit ${liste.length} Zeilen (1–$erkundungPunkte, R17)');
      for (final z in liste) {
        if (z.trim().isEmpty) f.add('${o.id}: $v: leere Zeile');
        if (worte(z) > erkundungWorte) f.add('${o.id}: $v: „$z“ hat ${worte(z)} Wörter (höchstens $erkundungWorte, R17)');
        if (ton != null && ton.saetze(z).length != 1) f.add('${o.id}: $v: „$z“ ist mehr oder weniger als ein Satz');
      }
    }
  }
  for (final t in e.treffpunkte) {
    if (t.anzeige.trim().isEmpty || worte(t.anzeige) > treffpunktWorte) f.add('${t.id}: Anzeige mit ${worte(t.anzeige)} Wörtern (1–$treffpunktWorte)');
  }

  // Inhalt: R15 wie bei den Gerüchten, kein Geburtstag, Raumwörter, Ton.
  final pfadgleich = PfadgleichRegeln(
    kanon,
    geschuetzt: geschuetzt,
    art: 'eine pfadgleiche Erkundung',
    beinamen: [for (final b in pfadBeinamen) if (!_erkundungOhneBeinamen.contains(b)) b],
  );
  final geburtstag = wortAnfang('geburtstag');
  final endungen = [for (final x in (regeln?['raumwortEndungen'] as List? ?? const [])) (x as String).toLowerCase()];
  final raumworte = <String>{
    for (final n in [
      for (final r in kanon.graph.raeume.values) ...[r.name, r.anzeigename],
      for (final eb in w.ebenen.values)
        if (!eb.ausKanon)
          for (final r in eb.graph.raeume.values) ...[r.name, r.anzeigename],
      ...((regeln?['raumAusnahmen'] as List?) ?? const []).cast<String>(),
    ])
      for (final m in _buchstabenRe.allMatches(n)) m.group(0)!.toLowerCase(),
  };
  for (final q in erkundungsTexte(e)) {
    if (pfadgleich.r15(q.text) case final b?) f.add('${q.ort}: $b');
    if (pfadgleich.leck(q.text) case final l?) f.add('${q.ort}: übernimmt „$l“ aus einer geschützten Kanonstelle');
    if (geburtstag.firstMatch(q.text) case final m?) f.add('${q.ort}: „${m.group(0)}“ gehört nicht in den Schlosskeller (A-061)');
    for (final m in _buchstabenRe.allMatches(q.text)) {
      final wort = m.group(0)!.toLowerCase();
      if (endungen.any(wort.endsWith) && !raumworte.contains(wort)) f.add('${q.ort}: Raumwort „${m.group(0)}“ ist kein Raum');
    }
    if (ton != null) {
      for (final b in ton.pruefe(q)) {
        f.add('${b.ort}: ${b.regel}: ${b.auszug}');
      }
    }
  }
  return f;
}

/// Kennungen der Sperrorte: Fundorte der Gegenstände, Ziel-Orte der
/// Entscheidungen und Orte der Lacher.
Set<String> _sperrorte(Kanon kanon) => {
      for (final g in kanon.gegenstaende)
        if ((g['lage'] as Map?)?['ort'] case final String o) o,
      for (final e in kanon.entscheidungenJson['entscheidungen'] as List)
        for (final o in (e as Map)['optionen'] as List)
          if (((o as Map)['ziel'] as Map?)?['ort'] case final String ort) ort,
      for (final l in (kanon.json['setting.json']?['lacher'] as List? ?? const []))
        if ((l as Map)['ort'] case final String o) o,
    };

/// Räume, auf die eine Entscheidung zielt.
Set<String> _zielRaeume(Kanon kanon) => {
      for (final e in kanon.entscheidungenJson['entscheidungen'] as List)
        for (final o in (e as Map)['optionen'] as List)
          if (((o as Map)['ziel'] as Map?)?['raum'] case final String raum) raum,
    };
