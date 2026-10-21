// Akten-Prüfer: ein Befehl für alles, was eine Akte (Bündel unter content/party/<akte>/) erfüllen muss.
// Aufruf (Repo-Wurzel oder Paketordner):  dart run packages/mordakte_core/bin/akte_pruefen.dart --fall <akte>
//
// Geprüft wird (jeder Befund wird mit Bereich ausgegeben, Status 1 bei mindestens einem Befund):
//   Schema      alle Kanon- und Textdateien gegen content/party/schema-akte
//   Verweise    kanonVerweise (Kennungen eindeutig, jeder Verweis zeigt auf Vorhandenes)
//   Simulator   Simulator.pruefe und pruefeSchwellen (alle Optionsfolgen, alle Pfade, alle Enden)
//   Beweise     Beweise.pruefe (und bei Akten mit Simulation die Plausibilität der Tatnacht)
//   Karte       Ziele der Optionen, Figuren an ihren Orten, Türen, Erreichbarkeit, Szenario-Export
//   Texte       textVerweise, textLuecken, Textprüfer (Sätze, Fachwörter, Verbote, Vorlesezeichen), Textlint,
//               Tonregeln (kein Schlag als Handlung, Rahmen ohne Qualität, Résumé ohne Namen)
//   Besetzung   je Rollenzahl: Gespräche je Runde nach Gesprächsmodell (legacy drei, befragung eins plus
//               Befragungsplan: Größe, Last, Zustellung jedes Kettenglieds), Partner, Namen, Last, Quellen der Ketten
//   Figuren     Herkunftsmatrix, Farbabstand im selben Startraum
//   Partie      vollständiger Abend mit bestem Spiel je Rollenzahl (RundenPartie, Salz- und Pech-Würfel)
//   Gerüchte    nur mit content/welt/<akte>/geruechte.json (in welt.json genannt): Schema und pruefeGeruechte (R15, R17, Fünf-Wort-Regel, Ton)
//   Steckbriefe nur mit steckbriefe.json (Zusatz steckbriefe in akten.json): Schema und pruefeSteckbriefe (K3: R17, ohne Fallbezug,
//     nichts aus Dossiers, Täterfassungen, Finale und Auflösung, Ton)
//   Langfassung nur mit content/welt/<akte>/langfassung.json (in welt.json genannt): Schema und pruefeEbenen (Raster, Portale,
//     Erreichbarkeit, Außentor in den Runden zu, Hoftür erst mit dem Ersatzschlüssel, keine Kanon-Kennung, Ton)
//   Diashow     nur mit content/welt/<akte>/diashow.json (Zusatz diashow in akten.json): Schema und pruefeDiashow (M4: ein Bild je
//     Abschnitt des Intros, 20–60 Wörter je Baustein, nur bekannte Orte und Figuren, keine Fallhinweise, kein Text)
//   Vorspiel/Morgen nur mit content/welt/<akte>/vorspiel_morgen.json (in welt.json als vorspielMorgen genannt, nur mit Langfassung
//     und Zusatz langfassung): Schema und pruefeVorspielMorgen (M7b: Stationen erreichbar in ihrer Lage, Tore der Zeitleiste, R17,
//     keine Fallhinweise, Fünf-Wort-Regel, Morgen ende-neutral oder je Ende, Ton)
//
// Fehlende Oberflächentexte (ui.*) kommen wie in der App aus dem Schlosskeller.
import 'dart:convert';
import 'dart:io';

import 'package:mordakte_core/mordakte_core.dart';
import 'package:mordakte_core/runden.dart';

/// Gesammelte Befunde mit Bereich.
class Befunde {
  final List<String> zeilen = [];
  final Map<String, int> je = {};

  void add(String bereich, Iterable<String> befunde) {
    for (final b in befunde) {
      zeilen.add('[$bereich] $b');
      je[bereich] = (je[bereich] ?? 0) + 1;
    }
  }

  bool get leer => zeilen.isEmpty;
}

void main(List<String> args) {
  String? wert(String name) {
    final i = args.indexOf(name);
    return i >= 0 && i + 1 < args.length ? args[i + 1] : null;
  }

  final fall = wert('--fall');
  if (fall == null) {
    stderr.writeln('Aufruf: dart run packages/mordakte_core/bin/akte_pruefen.dart --fall <akte>');
    exitCode = 2;
    return;
  }
  final b = Befunde();
  try {
    _pruefeAlles(fall, b);
  } catch (e, s) {
    b.add('Abbruch', ['$e', ...s.toString().split('\n').take(6)]);
  }
  for (final z in b.zeilen) {
    stdout.writeln(z);
  }
  if (b.leer) {
    stdout.writeln('Akte $fall: 0 Befunde');
  } else {
    stdout.writeln('Akte $fall: ${b.zeilen.length} Befunde (${b.je.entries.map((e) => '${e.key} ${e.value}').join(', ')})');
  }
  exitCode = b.leer ? 0 : 1;
}

String _wurzel() {
  var d = Directory.current;
  while (!Directory('${d.path}/content/party').existsSync()) {
    final p = d.parent;
    if (p.path == d.path) throw StateError('content/party nicht gefunden');
    d = p;
  }
  return d.path;
}

Map<String, Object?> _lies(String pfad) => jsonDecode(File(pfad).readAsStringSync()) as Map<String, Object?>;

const _schemaJeBereich = {
  'erzaehler': 'texte-bausteine',
  'detektiv': 'texte-bausteine',
  'ui': 'texte-bausteine',
  'dossier': 'texte-dossier',
  'taeter': 'texte-taeter',
  'gespraech': 'texte-gespraech',
  'befragung': 'texte-befragung',
  'kurzfassung': 'texte-kurzfassung',
  'wahl': 'texte-wahl',
};

void _pruefeAlles(String fall, Befunde b) {
  final wurzel = _wurzel();
  final ordner = '$wurzel/content/party/$fall';
  final schemaOrdner = '$wurzel/content/party/schema-akte';
  if (!Directory(ordner).existsSync()) throw StateError('Akte $fall nicht gefunden: $ordner');
  Map<String, Object?> leseAkte(String p) => _lies('$ordner/$p');

  final kanon = Kanon.lade(leseAkte);
  // Textlint und Vollständigkeit prüfen nur, was die Akte selbst mitbringt.
  final roh = Textsammlung.lade(leseAkte);
  final sammlung = Textsammlung.lade(leseAkte);
  if (fall != 'schlosskeller') {
    // Wie die App: fehlende Oberflächentexte aus der eingefrorenen Basis (A-061).
    sammlung.ergaenzeUi(Textsammlung.lade((p) => _lies('$wurzel/content/party/basis-ui/$p')));
  }

  _schema(b, kanon, roh, schemaOrdner, ordner);
  b.add('Verweise', kanonVerweise(kanon));

  final sim = Simulator(kanon);
  b.add('Simulator', sim.pruefe());
  b.add('Simulator', sim.pruefeSchwellen());

  if (kanon.hatSimulation) {
    final plausibel = Plausibilitaet(kanon);
    b.add('Beweise', Beweise(kanon, plausibel).pruefe());
    b.add('Plausibilität', [for (final v in plausibel.pruefe()) v.toString()]);
  } else {
    b.add('Beweise', Beweise(kanon).pruefe());
  }

  final erm = Ermittlung(kanon);
  final karte = PartyKarte(kanon, ermittlung: erm);
  _karte(b, kanon, karte, wurzel);

  final texte = Texte(kanon, sammlung);
  _texte(b, kanon, roh, texte, wurzel);
  _besetzung(b, kanon, erm, karte, texte);
  _figuren(b, kanon);
  _partien(b, kanon, erm, texte, fall);
  _geruechte(b, kanon, roh, wurzel, fall);
  _steckbriefe(b, kanon, texte, ordner, wurzel, fall);
  _langfassung(b, kanon, wurzel, fall);
  _erkundung(b, kanon, roh, wurzel, fall);
  _diashow(b, kanon, sammlung, wurzel, fall);
  _vorspielMorgen(b, kanon, texte, wurzel, fall);
}

// ---------------------------------------------------------------- Schema

void _schema(Befunde b, Kanon kanon, Textsammlung sammlung, String schemaOrdner, String ordner) {
  SchemaPruefer schema(String name) => SchemaPruefer(_lies('$schemaOrdner/$name.schema.json'));
  for (final e in kanon.json.entries) {
    final datei = e.key.split('/').last.replaceAll('.json', '');
    final name = e.key.startsWith('tatmatrix/') ? 'tatmatrix' : datei;
    b.add('Schema', [for (final f in schema(name).pruefe(e.value)) '${e.key}: $f']);
  }
  // Steckbriefe (K3) liegen neben dem Kanon; kein Spielzustand liest sie.
  final steckbriefe = File('$ordner/steckbriefe.json');
  if (steckbriefe.existsSync()) {
    b.add('Schema', [for (final f in schema('steckbriefe').pruefe(_lies(steckbriefe.path))) 'steckbriefe.json: $f']);
  }
  b.add('Schema', [for (final f in schema('texte-index').pruefe(sammlung.index)) 'texte/index.json: $f']);
  for (final d in sammlung.dateien.entries.where((d) => d.key != 'texte/index.json')) {
    final bereich = _schemaJeBereich[d.value['bereich']];
    if (bereich == null) {
      b.add('Schema', ['${d.key}: unbekannter Bereich ${d.value['bereich']}']);
      continue;
    }
    b.add('Schema', [for (final f in schema(bereich).pruefe(d.value)) '${d.key}: $f']);
  }
  // Jede Datei der Akte trägt dieselbe settingId.
  final id = kanon.settingId;
  for (final e in [...kanon.json.entries, ...sammlung.dateien.entries]) {
    final s = e.value['settingId'];
    if (s != null && s != id) b.add('Schema', ['${e.key}: settingId $s statt $id']);
  }
}

// ---------------------------------------------------------------- Karte

void _karte(Befunde b, Kanon kanon, PartyKarte karte, String wurzel) {
  final f = <String>[];
  final g = kanon.graph;
  final opt = [for (final e in karte.ermittlung.entscheidungen) for (final o in e.optionen) o.id];
  if (karte.ziele.keys.toSet().difference(opt.toSet()).isNotEmpty || opt.toSet().difference(karte.ziele.keys.toSet()).isNotEmpty) {
    f.add('nicht jede Option hat genau ein Ziel');
  }
  if (karte.ermittlung.entscheidungen.length != 9) f.add('${karte.ermittlung.entscheidungen.length} statt 9 Entscheidungen');
  for (final e in karte.ermittlung.entscheidungen) {
    if (e.optionen.length < 2 || e.optionen.length > 3) f.add('${e.id}: ${e.optionen.length} Optionen');
    final ziele = karte.zieleVon(e.id);
    final kennungen = {for (final z in ziele) z.person ?? z.hotspot};
    if (kennungen.length != ziele.length) f.add('${e.id}: zwei Optionen am selben Ziel');
  }
  for (final z in karte.ziele.values) {
    if (z.person != null) {
      if (kanon.figur(z.person!) == null) f.add('${z.option}: Person ${z.person} unbekannt');
    } else if (g.raumAn(z.x! + 0.5, z.y! + 0.5)?.id != z.raum) {
      f.add('${z.option} liegt nicht im Raum ${z.raum}');
    }
    if (z.name.isEmpty) f.add('${z.option}: Ziel ohne Namen');
  }
  final hotspots = karte.hotspotJson();
  if ({for (final x in hotspots) x['id']}.length != karte.ziele.values.where((z) => z.person == null).length) f.add('Hotspots und Ziele ohne Person weichen ab');

  // Figuren: eigener Standort, im Startraum, keine zwei auf derselben Stelle.
  final stellen = <String, String>{};
  for (final fg in karte.figuren) {
    if (g.raumAn(fg.x, fg.y)?.id != fg.raum) f.add('Figur ${fg.id}: steht nicht im Raum ${fg.raum}');
    final alt = stellen['${fg.x},${fg.y}'];
    if (alt != null) f.add('Figur ${fg.id} teilt die Stelle mit $alt');
    stellen['${fg.x},${fg.y}'] = fg.id;
    if (!g.raster.walkable(fg.x.floor(), fg.y.floor())) f.add('Figur ${fg.id}: Standort nicht begehbar');
  }
  if (karte.figuren.length != kanon.personen.length - 1) f.add('Figuren der Karte: ${karte.figuren.length} statt ${kanon.personen.length - 1}');

  // Türen: beide Seiten begehbar (Türen nach draußen ausgenommen); Raster vollständig.
  final (rows, breite, hoehe) = (g.karte.rows, g.breite, g.hoehe);
  if (rows.length != hoehe || rows.any((r) => r.length != breite)) f.add('Raster ist nicht ${breite}x$hoehe');
  for (final t in g.tueren.values) {
    if (t.von == 'draussen' || t.nach == 'draussen') continue;
    for (final k in t.kacheln) {
      final ns = g.raumAn(k.x + 0.5, k.y - 0.5) != null && g.raumAn(k.x + 0.5, k.y + 1.5) != null;
      final ow = g.raumAn(k.x - 0.5, k.y + 0.5) != null && g.raumAn(k.x + 1.5, k.y + 0.5) != null;
      if (!ns && !ow) f.add('Tür ${t.id} (${k.x},${k.y}) liegt nicht zwischen zwei Räumen');
      final paare = [
        if (ns) [Pt(k.x, k.y - 1), Pt(k.x, k.y + 1)],
        if (ow) [Pt(k.x - 1, k.y), Pt(k.x + 1, k.y)],
      ];
      if (paare.isNotEmpty && !paare.any((p) => g.raster.walkable(p[0].x, p[0].y) && g.raster.walkable(p[1].x, p[1].y))) {
        f.add('Tür ${t.id} (${k.x},${k.y}): beide Seiten brauchen freie Kacheln');
      }
      if (g.raumAn(k.x + 0.5, k.y + 0.5) != null) f.add('Tür ${t.id} (${k.x},${k.y}) liegt auf Bodenkacheln statt in der Wand');
    }
  }

  // Erreichbarkeit vom Startpunkt des Detektivs: alle Ziele und Figuren (Türen ohne Schlüssel).
  final det = (kanon.figurenJson['detektiv'] as Map)['ermittlungsOrt'] as String;
  final start = g.orte[det];
  if (start == null) {
    f.add('Detektiv: Ermittlungsort $det fehlt');
  } else {
    final von = Pt(start.x.floor(), start.y.floor());
    // Ein Ziel auf einem blockierenden Möbel (Vitrine, Kamin) gilt als erreicht, wenn eine Nachbarkachel erreichbar ist.
    void erreichbar(String wer, Pt nach) {
      final kandidaten = g.raster.walkable(nach.x, nach.y)
          ? [nach]
          : [for (final d in const [(1, 0), (-1, 0), (0, 1), (0, -1)]) Pt(nach.x + d.$1, nach.y + d.$2)];
      final ok = kandidaten.any((k) => g.raster.walkable(k.x, k.y) && (k == von || g.raster.findPath(von, k) != null));
      if (!ok) f.add('$wer ist vom Startpunkt des Detektivs nicht erreichbar');
    }

    for (final z in karte.ziele.values) {
      if (z.person == null) erreichbar('Ziel ${z.option}', Pt(z.x!, z.y!));
    }
    for (final fg in karte.figuren) {
      erreichbar('Figur ${fg.id}', Pt(fg.x.floor(), fg.y.floor()));
    }
    for (final o in g.orte.values) {
      erreichbar('Ort ${o.id}', Pt(o.x.floor(), o.y.floor()));
    }
  }
  final unerreichbar = [for (final o in g.orte.values) if (!g.raster.walkable(o.x.floor(), o.y.floor())) o.id];
  if (unerreichbar.isNotEmpty) f.add('Orte auf blockierten Kacheln: ${unerreichbar.join(', ')}');

  // Renderer-Szenario aus dem Kanon: Vorlage aus setting.darstellung.vorlage (sonst Ravensmoor).
  final setting = kanon.json['setting.json']!;
  final darstellung = ((setting['darstellung'] as Map?) ?? const {}).cast<String, Object?>();
  final vorlagePfad = '$wurzel/${darstellung['vorlage'] ?? 'content/scenarios/ravensmoor.json'}';
  try {
    final vorlage = jsonDecode(File(vorlagePfad).readAsStringSync()) as Map<String, dynamic>;
    final j = jsonDecode(jsonEncode(partySzenarioJson(kanon, vorlage))) as Map<String, dynamic>;
    final karteJ = j['map'] as Map;
    final raeumeIds = [for (final r in karteJ['rooms'] as List) (r as Map)['id']];
    if (!raeumeIds.contains(karteJ['councilRoom'])) f.add('Szenario: councilRoom ${karteJ['councilRoom']} ist kein Raum');
    final spawn = (karteJ['spawn'] as List).first as List;
    if (!g.raster.walkable(spawn[0] as int, spawn[1] as int)) f.add('Szenario: Spawn ${spawn.join(',')} nicht begehbar');
    final theme = j['theme'] as Map;
    if (!ThemeDef.weathers.contains(theme['weather'])) f.add('Szenario: Wetter ${theme['weather']} unbekannt');
    for (final k in ThemeDef.paletteKeys) {
      if (!RegExp(r'^#[0-9a-fA-F]{6}$').hasMatch(((theme['palette'] as Map)[k] ?? '') as String)) f.add('Szenario: Palette.$k fehlt oder ist keine Hex-Farbe');
    }
    if ((j['suspects'] as List).length != kanon.personen.length - 1) f.add('Szenario: ${(j['suspects'] as List).length} Figuren statt ${kanon.personen.length - 1}');
  } catch (e) {
    f.add('Szenario-Export scheitert: $e');
  }
  b.add('Karte', f);
}

// ---------------------------------------------------------------- Texte

/// Beschreibt ein Text den Schlag als Handlung? (TON §1: nur Schatten und Geräusch.)
final _schlagVerb = RegExp(r'\b(schlägst|schlägt|schlage|schlug|schlugen|zugeschlagen|zuschlagen|zuzuschlagen|niedergeschlagen)\b', caseSensitive: false);

/// Wörter, die eine Qualität des Hinweises verraten (Rahmen darf sie nicht nennen).
final _verraetRe = RegExp(r'(?<!\p{L})(wahr|falsch|gelogen|lüge|gerücht|sicher|richtig)\p{L}*|(?<!\p{L})genau\s+gemerkt\p{L}*', unicode: true);

Iterable<String> _alleTexte(Object? o) sync* {
  if (o is String) yield o;
  if (o is Map) {
    for (final v in o.values) {
      yield* _alleTexte(v);
    }
  }
  if (o is List) {
    for (final v in o) {
      yield* _alleTexte(v);
    }
  }
}

void _texte(Befunde b, Kanon kanon, Textsammlung sammlung, Texte texte, String wurzel) {
  b.add('Texte', textVerweise(kanon, sammlung));
  b.add('Texte', textLuecken(kanon, sammlung));
  b.add('Texte', texte.lastVerstoesse());

  final regeln = _lies('$wurzel/content/party/textregeln.json');
  final pruefer = Textpruefer(regeln);
  final quellen = textQuellen(kanon, sammlung);
  final befunde = <TextBefund>[for (final q in quellen) ...pruefer.pruefe(q)];
  final bereiche = <String, List<TextQuelle>>{};
  for (final q in quellen) {
    (bereiche[q.ort.split('#').first] ??= []).add(q);
  }
  for (final e in bereiche.entries) {
    befunde.addAll(pruefer.pruefeMittel(e.key, e.value));
  }
  befunde.addAll(textLint(kanon, quellen, regeln: regeln));
  b.add('Texte', [for (final t in befunde) '${t.ort}: ${t.regel}: ${t.auszug}']);

  // Kein Spielertext beschreibt den Schlag als Handlung (TON §1).
  for (final d in sammlung.dateien.entries) {
    for (final t in _alleTexte(d.value)) {
      final m = _schlagVerb.firstMatch(t);
      if (m != null) b.add('Texte', ['${d.key}: Schlag als Handlung („${m[0]}“): ${t.length > 80 ? '${t.substring(0, 77)}…' : t}']);
    }
  }

  // Der Rahmen verrät keine Qualität; bei nur einer Restperson steht kein Name.
  for (final k in ['bonus.rahmen', 'resuemee.gruppe.1', 'resuemee.gruppe.2', 'resuemee.gruppe.3']) {
    final t = sammlung.bausteine[k];
    if (t == null) continue;
    for (final m in _verraetRe.allMatches(t.toLowerCase())) {
      b.add('Texte', ['$k verrät die Qualität: „${m.group(0)}“']);
    }
  }
  final eins = sammlung.bausteine['resuemee.rest.eins']?.toLowerCase();
  if (eins != null) {
    final namen = {
      for (final f in kanon.figuren) f['name'] as String,
      for (final f in kanon.figuren)
        if (f['vollerName'] is String) f['vollerName'] as String,
      ((kanon.figurenJson['opfer'] as Map)['name'] as String).split(' ').last,
    };
    for (final n in namen) {
      if (RegExp(r'(?<!\p{L})' + RegExp.escape(n.toLowerCase()), unicode: true).hasMatch(eins)) {
        b.add('Texte', ['resuemee.rest.eins nennt den Namen $n']);
      }
    }
  }
  // Preisgaben am Tisch und in Befragungen gelten in allen Pfaden (S-1).
  final beob = {for (final x in kanon.beobachtungen) x['id'] as String: x};
  for (final (id, preisgabe) in [
    for (final g in sammlung.gespraeche) (g.id, g.preisgabe),
    for (final x in sammlung.befragungen.values) (x.id, x.preisgabe),
  ]) {
    for (final p in preisgabe) {
      if (p.startsWith('beobachtung:') && beob[p.substring('beobachtung:'.length)]?['pfade'] != 'alle') {
        b.add('Texte', ['$id: $p gilt nicht in allen Pfaden']);
      }
    }
  }
  // Jede Rolle hat Dossier, Täterfassung nur bei Pfadpersonen, Wahltexte für jede Runde.
  for (final t in sammlung.taeter.keys) {
    if (!kanon.pfade.contains(t)) b.add('Texte', ['Täterfassung $t: keine Pfadperson']);
  }
}

// ---------------------------------------------------------------- Gerüchte

/// Gerüchte der Klassenfähigkeit (A-055), nur wenn die Akte welche hat: Schema,
/// dann pruefeGeruechte. Geschützt sind zusätzlich Täterfassungen, Finale und
/// Auflösung.
void _geruechte(Befunde b, Kanon kanon, Textsammlung sammlung, String wurzel, String fall) {
  final welt = File('$wurzel/content/welt/$fall/welt.json');
  final genannt = welt.existsSync() ? _lies(welt.path)['geruechte'] : null;
  final datei = File('$wurzel/content/welt/$fall/${genannt is String ? genannt : 'geruechte.json'}');
  // Die App lädt nur, was welt.json nennt: Datei und Eintrag gehören zusammen.
  if (datei.existsSync() != (genannt is String)) {
    b.add('Gerüchte', [genannt is String ? 'welt.json nennt $genannt, die Datei fehlt' : 'geruechte.json fehlt in welt.json (Feld geruechte)']);
  }
  if (!datei.existsSync()) return;
  final j = _lies(datei.path);
  final schema = SchemaPruefer(_lies('$wurzel/content/welt/geruechte.schema.json')).pruefe(j);
  b.add('Gerüchte', [for (final f in schema) 'geruechte.json: $f']);
  if (schema.isNotEmpty) return;
  if (j['akte'] != fall) b.add('Gerüchte', ['geruechte.json: akte ${j['akte']} statt $fall']);
  final geschuetzt = [
    for (final d in sammlung.dateien.entries)
      if (RegExp(r'texte/(taeter-|erzaehler-finale|erzaehler-aufloesung)').hasMatch(d.key)) ..._alleTexte(d.value),
  ];
  final ton = Textpruefer(_lies('$wurzel/content/party/textregeln.json'));
  b.add('Gerüchte', pruefeGeruechte(Geruechte.ausJson(j), kanon, ton: ton, geschuetzt: geschuetzt));
}

// ---------------------------------------------------------------- Langfassung

/// Welt-Ebenen des langen Abends (M7a), nur wenn welt.json `langfassung`
/// nennt: Die Datei muss es dann geben, danach Schema und pruefeEbenen mit den
/// Tonregeln.
void _langfassung(Befunde b, Kanon kanon, String wurzel, String fall) {
  final welt = File('$wurzel/content/welt/$fall/welt.json');
  final genannt = welt.existsSync() ? _lies(welt.path)['langfassung'] : null;
  if (genannt is! String) return;
  final datei = File('$wurzel/content/welt/$fall/$genannt');
  if (!datei.existsSync()) {
    b.add('Langfassung', ['welt.json nennt $genannt, die Datei fehlt']);
    return;
  }
  final j = _lies(datei.path);
  final schema = SchemaPruefer(_lies('$wurzel/content/welt/langfassung.schema.json')).pruefe(j);
  b.add('Langfassung', [for (final f in schema) '$genannt: $f']);
  if (schema.isNotEmpty) return;
  if (j['akte'] != fall) b.add('Langfassung', ['$genannt: akte ${j['akte']} statt $fall']);
  final regeln = _lies('$wurzel/content/party/textregeln.json');
  b.add('Langfassung', pruefeEbenen(WeltEbenen.ausJson(j, kanon), ton: Textpruefer(regeln), regeln: regeln));
}

// ---------------------------------------------------------------- Erkundung

/// Erkundung des langen Abends (M7b, Streifzug), nur wenn welt.json
/// `erkundung` nennt: Datei und Langfassung müssen es dann geben, danach
/// Schema und pruefeErkundung mit den Tonregeln. Geschützt sind wie bei den
/// Gerüchten zusätzlich Täterfassungen, Finale und Auflösung.
void _erkundung(Befunde b, Kanon kanon, Textsammlung sammlung, String wurzel, String fall) {
  final welt = File('$wurzel/content/welt/$fall/welt.json');
  final w = welt.existsSync() ? _lies(welt.path) : const <String, Object?>{};
  final genannt = w['erkundung'];
  if (genannt is! String) return;
  final datei = File('$wurzel/content/welt/$fall/$genannt');
  final lang = w['langfassung'];
  if (!datei.existsSync() || lang is! String) {
    b.add('Erkundung', [!datei.existsSync() ? 'welt.json nennt $genannt, die Datei fehlt' : 'welt.json nennt $genannt ohne langfassung']);
    return;
  }
  final j = _lies(datei.path);
  final schema = SchemaPruefer(_lies('$wurzel/content/welt/erkundung.schema.json')).pruefe(j);
  b.add('Erkundung', [for (final f in schema) '$genannt: $f']);
  if (schema.isNotEmpty) return;
  if (j['akte'] != fall) b.add('Erkundung', ['$genannt: akte ${j['akte']} statt $fall']);
  final ebenen = WeltEbenen.ausJson(_lies('$wurzel/content/welt/$fall/$lang'), kanon);
  final geschuetzt = [
    for (final d in sammlung.dateien.entries)
      if (RegExp(r'texte/(taeter-|erzaehler-finale|erzaehler-aufloesung)').hasMatch(d.key)) ..._alleTexte(d.value),
  ];
  final regeln = _lies('$wurzel/content/party/textregeln.json');
  b.add('Erkundung', pruefeErkundung(Erkundung.ausJson(j), ebenen, ton: Textpruefer(regeln), regeln: regeln, geschuetzt: geschuetzt));
}

// ---------------------------------------------------------------- Steckbriefe

/// Steckbriefe und Charakterübersicht (K3, A-059), nur wenn die Akte den Zusatz
/// `steckbriefe` hat: Datei und Eintrag in `akten.json` gehören zusammen, dann
/// pruefeSteckbriefe mit den Tonregeln. Geschützt sind zusätzlich Dossiers,
/// Täterfassungen, Finale und Auflösung (steckbriefGeschuetzt). Das Schema prüft [_schema].
void _steckbriefe(Befunde b, Kanon kanon, Texte texte, String ordner, String wurzel, String fall) {
  final datei = File('$ordner/steckbriefe.json');
  final akte = [
    for (final a in _lies('$wurzel/content/party/akten.json')['akten'] as List)
      if ((a as Map)['id'] == fall) a,
  ].firstOrNull;
  final faehig = ((akte?['faehigkeiten'] as List?) ?? const []).contains('steckbriefe');
  if (datei.existsSync() != faehig) {
    b.add('Steckbriefe', [faehig ? 'akten.json nennt steckbriefe, steckbriefe.json fehlt' : 'steckbriefe.json ohne Zusatz steckbriefe in akten.json']);
  }
  if (!datei.existsSync()) return;
  final j = _lies(datei.path);
  if (j['settingId'] != kanon.settingId) b.add('Steckbriefe', ['steckbriefe.json: settingId ${j['settingId']} statt ${kanon.settingId}']);
  final ton = Textpruefer(_lies('$wurzel/content/party/textregeln.json'));
  b.add('Steckbriefe', pruefeSteckbriefe(Steckbriefe.ausJson(j), kanon, ton: ton, geschuetzt: steckbriefGeschuetzt(texte)));
}

// ---------------------------------------------------------------- Diashow

/// Diashow zur Einleitung (M4), nur wenn die Akte den Zusatz `diashow` hat:
/// Datei und Eintrag in `akten.json` gehören zusammen, dann Schema und
/// pruefeDiashow gegen die Erzähltexte der Akte.
void _diashow(Befunde b, Kanon kanon, Textsammlung sammlung, String wurzel, String fall) {
  final datei = File('$wurzel/content/welt/$fall/diashow.json');
  final akte = [
    for (final a in _lies('$wurzel/content/party/akten.json')['akten'] as List)
      if ((a as Map)['id'] == fall) a,
  ].firstOrNull;
  final faehig = ((akte?['faehigkeiten'] as List?) ?? const []).contains('diashow');
  if (datei.existsSync() != faehig) {
    b.add('Diashow', [faehig ? 'akten.json nennt diashow, content/welt/$fall/diashow.json fehlt' : 'diashow.json ohne Zusatz diashow in akten.json']);
  }
  if (!datei.existsSync()) return;
  final j = _lies(datei.path);
  final schema = SchemaPruefer(_lies('$wurzel/content/welt/diashow.schema.json')).pruefe(j);
  b.add('Diashow', [for (final f in schema) 'diashow.json: $f']);
  if (schema.isNotEmpty) return;
  if (j['akte'] != fall) b.add('Diashow', ['diashow.json: akte ${j['akte']} statt $fall']);
  b.add('Diashow', pruefeDiashow(Diashow.ausJson(j), kanon, (k) => sammlung.bausteine[k]));
}

// ---------------------------------------------------------------- Besetzung

String _nennt(String name, String text) =>
    RegExp('(?<!\\p{L})${RegExp.escape(name)}(?!\\p{L})', unicode: true).hasMatch(text) ? name : '';

void _besetzung(Befunde b, Kanon kanon, Ermittlung erm, PartyKarte karte, Texte texte) {
  final f = <String>[];
  final bes = texte.besetzung;
  final erz = Erzaehler(kanon);
  final alleRollen = [for (final x in kanon.figuren) x['id'] as String];
  if (bes.reihenfolge.length != alleRollen.length || bes.reihenfolge.toSet().difference(alleRollen.toSet()).isNotEmpty) {
    f.add('Besetzung: reihenfolge und figuren stimmen nicht überein');
  }
  for (var i = 0; i < bes.reihenfolge.length; i++) {
    final platz = kanon.figur(bes.reihenfolge[i])?['besetzungsplatz'];
    if (platz != i + 1) f.add('Besetzung: ${bes.reihenfolge[i]} steht auf Platz ${i + 1}, Figur sagt $platz');
  }
  if (bes.reihenfolge.take(4).toSet().difference(kanon.kernverdaechtige.toSet()).isNotEmpty) {
    f.add('Besetzung: die ersten vier Plätze sind nicht die Kernverdächtigen');
  }
  final bil = (kanon.besetzungJson['geschlechterBilanz'] as List?) ?? const [];
  for (final z in bil.cast<Map>()) {
    final n = z['rollen'] as int;
    final m = bes.reihenfolge.take(n).where((id) => kanon.figur(id)!['geschlecht'] == 'm').length;
    if (z['m'] != m || z['w'] != n - m) f.add('Besetzung: Bilanz bei $n Rollen stimmt nicht (m $m, w ${n - m})');
    if (n >= 5 && (m - (n - m)).abs() > 1) f.add('Besetzung: bei $n Rollen unterscheiden sich Frauen und Männer um mehr als eine Rolle');
  }
  final stufen = (kanon.besetzungJson['stufen'] as List?) ?? const [];
  for (final s in stufen.cast<Map>()) {
    final pl = (s['plaetze'] as List).cast<int>();
    if (pl[0] > pl[1] || pl[1] > bes.maxRollen) f.add('Besetzung: Stufe ${s['stufe']} hat Plätze $pl');
  }

  for (var n = bes.minRollen; n <= bes.maxRollen; n++) {
    final besetzt = bes.besetzt(n);
    final unbesetzt = bes.npc(n);
    for (final p in kanon.pfade) {
      // Gespräche, wie das Dossier sie liefert.
      final zeilen = <({String rolle, int runde, int nr, String partner, Gespraech g})>[];
      for (final r in besetzt) {
        final d = texte.dossier(r, p, n);
        for (final runde in d.gespraeche.keys) {
          for (final (g, partner) in d.gespraeche[runde]!) {
            zeilen.add((rolle: r, runde: runde, nr: g.nr, partner: partner, g: g));
          }
        }
      }
      // Nummern 1 bis tischJeRolle (legacy 1,2,3; Modell befragung genau ein Tischgespräch).
      final soll = [for (var i = 1; i <= bes.tischJeRolle; i++) i].join(',');
      for (final r in besetzt) {
        for (var runde = 1; runde <= 3; runde++) {
          final nrs = [for (final x in zeilen) if (x.rolle == r && x.runde == runde) x.nr]..sort();
          if (nrs.join(',') != soll) f.add('$n Rollen, $p: $r, Runde $runde hat Gespräche $nrs statt $soll');
        }
      }
      for (final x in zeilen) {
        if (!bes.istBesetzt(x.partner, n)) f.add('$n Rollen, $p: ${x.rolle} Runde ${x.runde} Nr ${x.nr}: Partner ${x.partner} unbesetzt');
        if (x.partner == x.rolle) f.add('$n Rollen, $p: ${x.rolle} Runde ${x.runde} Nr ${x.nr}: Partner ist die Rolle selbst');
        if (bes.befragungsmodell && x.partner == Besetzung.detektiv) f.add('$n Rollen, $p: ${x.rolle} Runde ${x.runde} Nr ${x.nr}: der Detektiv sitzt nicht am Tisch');
        final felder = {'Thema': x.g.thema, 'Ziel': x.g.ziel, 'Text': x.g.text, 'Stichpunkte': x.g.stichpunkte.join(' / ')};
        for (final u in unbesetzt) {
          final name = kanon.figur(u)!['name'] as String;
          for (final fe in felder.entries) {
            if (_nennt(name, fe.value).isNotEmpty) f.add('$n Rollen, $p: Gespräch ${x.g.id}, ${fe.key} nennt die unbesetzte Figur $u ($name)');
          }
        }
      }
      // Lösbarkeit mit bestem Spiel und Quellen der Ketten.
      final s = _bisAnklage(kanon, erm, n, p, beste: true);
      final rest = s.restmenge();
      if (rest.length != 1 || !rest.contains(p)) f.add('$n Rollen, $p: Restmenge $rest statt {$p}');
      s.anklagen(p);
      if (s.ende.id != 'ende_meister') f.add('$n Rollen, $p: bestes Spiel endet mit ${s.ende.id}');
      final sf = _bisAnklage(kanon, erm, n, p, beste: false);
      sf.anklagen(p);
      if (sf.ende.id == 'ende_meister') f.add('$n Rollen, $p: lauter falsche Antworten enden als Meister');
      for (final e in erm.entscheidungen) {
        final bis = [for (final y in erm.entscheidungen) if (y.runde < e.runde || (y.runde == e.runde && y.nr <= e.nr)) y];
        final optionen = [for (final y in bis) ...y.optionen];
        final ziele = {for (final o in optionen) if (karte.ziele[o.id]?.person != null) karte.ziele[o.id]!.person!};
        final fakten = {for (final o in optionen) ...o.fakten};
        for (final k in e.begruendungFuer(p)!.kette) {
          if (!k.startsWith('beobachtung:')) continue;
          final id = k.substring('beobachtung:'.length);
          final bj = erm.beobachtungJson(id);
          if (bj == null) continue; // meldet der Simulator
          final wer = bj['wer'] as String;
          if (bes.istBesetzt(wer, n)) continue;
          // Modell legacy: Die Zielfigur spricht als NPC selbst. Modell befragung: Ihr Wissen bringt der Erzähler (E-044).
          final alsZiel = !bes.befragungsmodell && ziele.contains(wer);
          final alsFakt = fakten.any((fid) => erm.fakten[fid]!.beobachtung == id && erm.gibtEs(fid, p));
          final alsErzaehler = [
            for (var r = 1; r <= e.runde; r++) ...erz.npcWissen(r, besetzt: (x) => bes.istBesetzt(x, n)),
          ].any((x) => x.startsWith('npc.$wer.') && (erz.npcPlan[int.parse(x.split('.').last)]![wer] ?? const []).contains(id));
          if (!alsZiel && !alsFakt && !alsErzaehler) f.add('$n Rollen, $p, ${e.id}: $k stammt von $wer (unbesetzt) und erreicht den Detektiv nicht');
        }
      }
    }
  }

  // Modell befragung (A-051): Befragungsplan je Rollenzahl (Größe 3 bis 5, Last höchstens 3, jedes
  // Kettenglied rechtzeitig in allen Pfaden, Kernrollen befragt, keine unbesetzten Namen), ein Tischgespräch
  // je Bot und Runde, und jede Antwort entsteht nur aus öffentlichen Preisgaben.
  if (bes.befragungsmodell) {
    try {
      f.addAll(Befragungsplan(texte).verstoesse());
      for (var n = bes.minRollen; n <= bes.maxRollen; n++) {
        for (var runde = 1; runde <= 3; runde++) {
          final liste = botGespraeche(texte, rollen: n, runde: runde);
          if (liste.length != n * bes.tischJeRolle) f.add('Bots: $n Rollen, Runde $runde: ${liste.length} Sprechblasen statt ${n * bes.tischJeRolle}');
        }
      }
      for (final x in texte.sammlung.befragungen.values) {
        botAntwort(texte, x);
      }
    } catch (e) {
      f.add('Befragung: $e');
    }
    b.add('Besetzung', f);
    return;
  }

  // Sprechblasen der Bots: nur freigegebene Quellen, alle Tisch-Glieder einer Kette rechtzeitig erreichbar.
  try {
    for (var n = bes.minRollen; n <= bes.maxRollen; n++) {
      for (var runde = 1; runde <= 3; runde++) {
        final liste = botGespraeche(texte, rollen: n, runde: runde);
        if (liste.length != n * 3) f.add('Bots: $n Rollen, Runde $runde: ${liste.length} Sprechblasen statt ${n * 3}');
      }
    }
    for (final p in kanon.pfade) {
      for (final e in erm.entscheidungen) {
        final erreichbar = {
          for (var r = 1; r <= e.runde; r++)
            for (final g in botGespraeche(texte, rollen: bes.maxRollen, runde: r)) for (final z in g.preisgaben) z.quelle,
        };
        for (final q in e.begruendungFuer(p)!.kette) {
          final tisch = q.startsWith('luege:') ||
              (q.startsWith('beobachtung:') && erm.beobachtungJson(q.substring('beobachtung:'.length))?['kanal'] == 'pflichtgespraech');
          if (tisch && !erreichbar.contains(q)) f.add('Bots: ${e.id} / $p: $q kommt in keiner Sprechblase bis Runde ${e.runde} vor');
        }
      }
    }
  } catch (e) {
    f.add('Bots: $e');
  }
  b.add('Besetzung', f);
}

/// Spielt ohne Würfel bis zur Anklage: je Entscheidung die richtige Option ([beste]) oder die erste falsche.
Spiel _bisAnklage(Kanon kanon, Ermittlung erm, int n, String pfad, {required bool beste}) {
  final s = Spiel(kanon, ermittlung: erm)..einrichten(Einstellungen(rollen: n, detektiv: 'm', code: FallCode.fuerPfad(pfad, kanon.pfade)));
  while (s.phase != PartyPhase.anklage) {
    if (s.phase == PartyPhase.entscheidungen) {
      for (final x in erm.runde(s.runde)) {
        final richtig = x.richtig[pfad]!;
        s.waehle(x.id, beste ? richtig : x.optionen.firstWhere((o) => o.id != richtig).id);
      }
    }
    if (s.phase == PartyPhase.gruppenwahl) s.abstimmen(kooperativ: n - 1, taeterSabotiert: false);
    s.weiter();
  }
  return s;
}

// ---------------------------------------------------------------- Figuren

void _figuren(Befunde b, Kanon kanon) {
  final f = <String>[];
  f.addAll(herkunftsVerstoesse(herkunftsMatrix(kanon)));
  final personen = [for (final id in kanon.personen) kanon.figur(id)!];
  for (var i = 0; i < personen.length; i++) {
    for (var j = i + 1; j < personen.length; j++) {
      final a = personen[i], c = personen[j];
      if (a['startRoom'] != c['startRoom']) continue;
      final d = deltaE2000(a['colorCode'] as String, c['colorCode'] as String);
      if (d < 10) f.add('Farbe ${a['id']} / ${c['id']} (Startraum ${a['startRoom']}): ΔE2000 ${d.toStringAsFixed(1)} unter 10');
      if (a['colorCode'] != c['colorCode'] && '${a['farbname']}'.toLowerCase() == '${c['farbname']}'.toLowerCase()) {
        f.add('Farbname „${a['farbname']}“ bei ${a['id']} und ${c['id']} trotz verschiedener Farbe');
      }
    }
  }
  for (final x in kanon.figuren) {
    final look = (x['look'] as Map).cast<String, Object?>();
    if (x['isPotentialKiller'] == true && !kanon.kernverdaechtige.contains(x['id'])) f.add('Figur ${x['id']}: möglicher Täter, aber kein Kernverdächtiger');
    if (look['haut'] == null || look['haar'] == null) f.add('Figur ${x['id']}: look ohne haut oder haar');
  }
  b.add('Figuren', f);
}

// ---------------------------------------------------------------- Partien

void _partien(Befunde b, Kanon kanon, Ermittlung erm, Texte texte, String fall) {
  final f = <String>[];
  final bes = texte.besetzung;
  for (final pfad in kanon.pfade) {
    final folge = [for (final e in erm.entscheidungen) e.richtig[pfad]!];
    for (var n = bes.minRollen; n <= bes.maxRollen; n++) {
      for (final (name, quelle) in <(String, WuerfelQuelle)>[
        ('Salz', SalzWuerfel('akte:$fall:$pfad:$n')),
        ('Pech', const FesterWuerfel.pech()),
      ]) {
        try {
          f.addAll(_abend(kanon, erm, texte, pfad, n, folge, quelle, name));
        } catch (e, s) {
          f.add('$pfad, $n Rollen, $name: ${e.toString().split('\n').first} ${s.toString().split('\n').take(2).join(' | ')}');
        }
      }
    }
  }
  b.add('Partie', f);
}

/// Spielt einen Abend mit [RundenPartie] (Würfel, Kartenaktionen, Tischruf) und vergleicht ihn Schritt für Schritt
/// mit dem reinen [Spiel] ohne Würfel.
List<String> _abend(Kanon kanon, Ermittlung erm, Texte texte, String pfad, int n, List<String> folge, WuerfelQuelle quelle, String name) {
  final f = <String>[];
  String wo() => '$pfad, $n Rollen, $name';
  final e = Einstellungen(rollen: n, detektiv: n.isEven ? 'm' : 'w', code: FallCode.fuerPfad(pfad, kanon.pfade));
  final p = RundenPartie(kanon, quelle: quelle, ermittlung: erm)..einrichten(e);
  final referenz = Spiel(kanon, ermittlung: erm)..einrichten(e);
  var index = 0, schritte = 0;
  while (p.phase != PartyPhase.ende) {
    if (++schritte > 200) return [...f, '${wo()}: Sackgasse im Ablauf'];
    if (p.zug != null) {
      var zuege = 0;
      while (p.zug != null) {
        if (++zuege > 15) return [...f, '${wo()}: Zug ${p.zug?.id} hat eine Sackgasse'];
        switch (p.zug!.phase) {
          case RundenZugPhase.aktion:
            p.aktionFertig(p.zug!.aktion);
          case RundenZugPhase.wurf:
            p.wuerfeln();
          case RundenZugPhase.tischruf:
            p.tischruf(n.isEven ? Tischruf.umweg : Tischruf.nochmal);
          case RundenZugPhase.fund:
            p.fundGelesen();
        }
      }
    } else if (p.naechsteEntscheidung case final entscheidung?) {
      final option = folge[index++];
      if (!entscheidung.optionen.any((o) => o.id == option)) return [...f, '${wo()}: Option $option gehört nicht zu ${entscheidung.id}'];
      p.waehle(option, gruendlich: istSuche(entscheidung) && n.isEven);
      var zuege = 0;
      while (p.zug != null) {
        if (++zuege > 15) return [...f, '${wo()}: Zug ${p.zug?.id} hat eine Sackgasse'];
        switch (p.zug!.phase) {
          case RundenZugPhase.aktion:
            p.aktionFertig(p.zug!.aktion);
          case RundenZugPhase.wurf:
            p.wuerfeln();
          case RundenZugPhase.tischruf:
            p.tischruf(n.isEven ? Tischruf.umweg : Tischruf.nochmal);
          case RundenZugPhase.fund:
            p.fundGelesen();
        }
      }
      referenz.waehle(entscheidung.id, option);
      if (!_gleich(p.fakten, referenz.bekannteFakten())) f.add('${wo()}: Fakten nach ${entscheidung.id} weichen vom reinen Spiel ab');
    } else {
      if (p.phase == PartyPhase.gruppenwahl) {
        final a = p.abstimmen(kooperativ: n - 1, taeterSabotiert: false);
        final r = referenz.abstimmen(kooperativ: n - 1, taeterSabotiert: false);
        if (a != r) f.add('${wo()}: Gruppenwahl weicht ab');
      }
      if (p.phase == PartyPhase.anklage) {
        p.anklagen(pfad);
        referenz.anklagen(pfad);
      }
      p.weiter();
      referenz.weiter();
      if (p.phase != referenz.phase || p.runde != referenz.runde) f.add('${wo()}: Ablauf weicht vom reinen Spiel ab');
    }
  }
  if (p.spiel.punkte != erm.entscheidungen.length) f.add('${wo()}: ${p.spiel.punkte} Punkte statt ${erm.entscheidungen.length}');
  if (!_gleich(p.spiel.restmenge(), {pfad})) f.add('${wo()}: Restmenge ${p.spiel.restmenge()} statt {$pfad}');
  if (p.spiel.ende.id != 'ende_meister') f.add('${wo()}: Ende ${p.spiel.ende.id} statt ende_meister');
  if (p.restJeRunde.length != 3 || p.restJeRunde.any((r) => r < 0)) f.add('${wo()}: Nachtminuten reichen nicht: ${p.restJeRunde}');
  // Jeder gesprochene Baustein existiert.
  for (final k in p.spiel.bausteine) {
    try {
      texte.baustein(k);
    } on ArgumentError {
      f.add('${wo()}: Baustein $k fehlt');
    }
  }
  return f;
}

bool _gleich(Set<String> a, Set<String> b) => a.length == b.length && a.containsAll(b);

// ---------------------------------------------------------------- Vorspiel und Morgen

/// Vorspiel und Morgen des langen Abends (M7b), nur wenn welt.json
/// `vorspielMorgen` nennt: Die Datei muss es dann geben, dazu die Langfassung
/// (Ebenen) und den Zusatz `langfassung` in akten.json (ohne langen Abend gibt
/// es keinen Rundgang). Danach Schema und pruefeVorspielMorgen mit Tonregeln;
/// geschützt sind Dossiers, Täterfassungen, Finale und Auflösung.
void _vorspielMorgen(Befunde b, Kanon kanon, Texte texte, String wurzel, String fall) {
  final welt = File('$wurzel/content/welt/$fall/welt.json');
  final weltJson = welt.existsSync() ? _lies(welt.path) : const <String, Object?>{};
  final genannt = weltJson['vorspielMorgen'];
  if (genannt is! String) return;
  final datei = File('$wurzel/content/welt/$fall/$genannt');
  if (!datei.existsSync()) {
    b.add('Vorspiel/Morgen', ['welt.json nennt $genannt, die Datei fehlt']);
    return;
  }
  final akte = [
    for (final a in _lies('$wurzel/content/party/akten.json')['akten'] as List)
      if ((a as Map)['id'] == fall) a,
  ].firstOrNull;
  if (!((akte?['faehigkeiten'] as List?) ?? const []).contains('langfassung')) {
    b.add('Vorspiel/Morgen', ['$genannt ohne Zusatz langfassung in akten.json']);
  }
  final lang = weltJson['langfassung'];
  if (lang is! String || !File('$wurzel/content/welt/$fall/$lang').existsSync()) {
    b.add('Vorspiel/Morgen', ['$genannt braucht die Langfassung (welt.json: langfassung)']);
    return;
  }
  final j = _lies(datei.path);
  final schema = SchemaPruefer(_lies('$wurzel/content/welt/vorspiel_morgen.schema.json')).pruefe(j);
  b.add('Vorspiel/Morgen', [for (final f in schema) '$genannt: $f']);
  if (schema.isNotEmpty) return;
  if (j['akte'] != fall) b.add('Vorspiel/Morgen', ['$genannt: akte ${j['akte']} statt $fall']);
  final regeln = _lies('$wurzel/content/party/textregeln.json');
  final ebenen = WeltEbenen.ausJson(_lies('$wurzel/content/welt/$fall/$lang'), kanon);
  b.add('Vorspiel/Morgen', pruefeVorspielMorgen(VorspielMorgen.ausJson(j), ebenen, ton: Textpruefer(regeln), regeln: regeln, geschuetzt: steckbriefGeschuetzt(texte)));
}
