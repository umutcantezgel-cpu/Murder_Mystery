// Kartenprüfer (A-017): prüft die Sammelkarten unter content/karten/ und die Abstecher unter content/party/zusatz/.
// Aufruf (im Paketordner): dart run bin/karten_pruefen.dart [--wurzel <repo>]
//
// Geprüft wird:
// - jede Kartendatei gegen content/karten/karte.schema.json (SchemaPruefer), dann KartenKatalog.pruefe()
// - jeder Kartentext beschreibt genau die Wirkung seiner Art, in einem Satz, ohne Versprechen von Wissen
// - Titel und Texte gegen die Wortlisten aus content/party/textregeln.json (Alkohol, Drogen, Rauchen)
// - jede Figur jeder Akte aus content/party/akten.json hat mindestens zwei Karten, davon eine gewöhnliche Rollenkarte
// - jede Akte hat mindestens eine Meisterkarte, jede Pfad-Person eine Täterkarte
// - jede Abstecher-Quelle verweist auf einen Ort in content/party/zusatz/<akte>/abstecher.json, dessen Ort im Raumplan steht
// - Abstecher-Texte nennen weder Beweisstücke noch Verdächtige noch Geheimnisse
// - jede Detektivklasse hat eine Startkarte
// Alle Befunde stehen auf der Konsole, Ausgang 1 bei jedem Befund.
import 'dart:convert';
import 'dart:io';

import 'package:mordakte_core/src/karten/abstecher.dart';
import 'package:mordakte_core/src/karten/karte.dart';
import 'package:mordakte_core/src/model/rules.dart';
import 'package:mordakte_core/src/party/kanon/schema.dart';
import 'package:mordakte_core/src/party/textpruefer.dart';

/// Kennung der Akte, unter der die Karten der Detektivklassen stehen.
const _klassenAkte = 'mordakte';

/// Schlüsselwort je Art. Es steht im Text seiner Art und in keinem anderen.
const _schluesselwort = {
  KartenArt.werkzeug: 'Suchwurf',
  KartenArt.marke: 'Seifenblasen-Marke',
  KartenArt.gruendlich: 'Gründlich',
  KartenArt.nochmal: 'Nochmal',
  KartenArt.umweg: 'Umweg',
  KartenArt.abstecher: 'Abstecher',
  KartenArt.erinnerung: 'Sprechblasen',
  KartenArt.kosmetik: 'Aussehen',
};

/// Arten, deren Text Nachtminuten nennen darf (Zeit, Kostenfreiheit).
const _mitNachtminuten = {KartenArt.zeit, KartenArt.nochmal, KartenArt.umweg, KartenArt.abstecher};

/// Wörter, mit denen ein Kartentext Wissen oder Einfluss auf Wahl, Anklage und Wertung versprechen würde.
const _versprechen = [
  'hinweis', 'beweis', 'indiz', 'spur', 'verrät', 'verrat', 'wissen', 'wahrheit', 'lösung', 'fakt', 'geheimnis',
  'täter', 'mörder', 'verdacht', 'verdächtig', 'alibi', 'anklage', 'stimme', 'abstimm', 'wahl', 'punkt', 'ende',
];

/// Wörter, die in Abstecher-Texten nie vorkommen (Beweise, Schlüsselbund, Kerzenständer, Alibis, Geheimnisse).
const _spoilerwoerter = [
  'beweis', 'indiz', 'spur', 'alibi', 'täter', 'mörder', 'verdächtig', 'geheimnis', 'tatort', 'mordwaffe',
  'schlüssel', 'kerze', 'kerzenständer', 'wachs', 'kurzschluss', 'stromausfall', 'blackout', 'opfer', 'schneider',
];

/// Gegenstandsnamen, die zu allgemein sind, um sie in Abstecher-Texten zu sperren.
const _allgemeineWoerter = {'breiter', 'linker', 'rechter', 'braunem', 'schwarze', 'schaden', 'bündel', 'turmgang'};

final _buchstaben = RegExp(r'[\p{L}]+', unicode: true);

void main(List<String> args) {
  final f = <String>[];
  final wurzel = _wert(args, '--wurzel') ?? _wurzel();

  Map<String, Object?>? lies(String pfad) {
    try {
      return jsonDecode(File(pfad).readAsStringSync()) as Map<String, Object?>;
    } on FileSystemException {
      f.add('${_kurz(wurzel, pfad)}: Datei fehlt oder ist nicht lesbar');
    } on FormatException catch (e) {
      f.add('${_kurz(wurzel, pfad)}: kein gültiges JSON (${e.message})');
    } on TypeError {
      f.add('${_kurz(wurzel, pfad)}: Wurzel ist kein Objekt');
    }
    return null;
  }

  final schema = lies('$wurzel/content/karten/karte.schema.json');
  final abstecherSchema = lies('$wurzel/content/party/zusatz/abstecher.schema.json');
  final regeln = lies('$wurzel/content/party/textregeln.json');
  final akten = lies('$wurzel/content/party/akten.json');
  if (schema == null || abstecherSchema == null || regeln == null || akten == null) {
    _ende(f, 'Karten');
    return;
  }
  final kartenPruefer = SchemaPruefer(schema);
  final textPruefer = Textpruefer(regeln);
  final akteIds = [for (final a in akten['akten'] as List) (a as Map)['id'] as String];

  // 1. Kartendateien laden und gegen das Schema prüfen.
  final dateien = <String, Map<String, Object?>>{};
  final ordner = Directory('$wurzel/content/karten');
  final namen = [
    if (ordner.existsSync())
      for (final e in ordner.listSync())
        if (e is File && e.path.endsWith('.json') && !e.path.endsWith('.schema.json')) e.path,
  ]..sort();
  if (namen.isEmpty) f.add('content/karten: keine Kartendatei gefunden');
  for (final pfad in namen) {
    final j = lies(pfad);
    if (j == null) continue;
    final fehler = kartenPruefer.pruefe(j);
    for (final x in fehler) {
      f.add('${_kurz(wurzel, pfad)}: Schema: $x');
    }
    if (fehler.isEmpty) dateien[pfad] = j;
  }
  if (f.isNotEmpty) {
    // Ohne gültiges Schema sind die übrigen Prüfungen nur Folgefehler.
    _ende(f, 'Karten');
    return;
  }

  // 2. Katalog bauen und Katalogregeln prüfen.
  final katalog = KartenKatalog.ausDateien(dateien.values);
  var roh = 0;
  for (final e in dateien.entries) {
    final akte = e.value['akte'];
    for (final k in e.value['karten'] as List) {
      roh++;
      if ((k as Map)['akte'] != akte) f.add('${_kurz(wurzel, e.key)}: ${k['id']} gehört zu Akte ${k['akte']}, die Datei aber zu $akte');
    }
  }
  if (roh != katalog.karten.length) f.add('Katalog: ${roh - katalog.karten.length} doppelte Kartenkennung(en)');
  f.addAll(katalog.pruefe());
  final titel = <String, String>{};
  for (final k in katalog.alle) {
    final alt = titel[k.titel];
    if (alt != null) f.add('${k.id}: Titel „${k.titel}“ steht schon bei $alt');
    titel[k.titel] = k.id;
    _pruefeKarte(k, textPruefer, f);
  }
  for (final e in dateien.entries) {
    final texte = [
      for (final k in e.value['karten'] as List)
        TextQuelle(ort: (k as Map)['id'] as String, text: k['text'] as String, vorlesen: false),
    ];
    for (final b in textPruefer.pruefeMittel(_kurz(wurzel, e.key), texte)) {
      f.add('${b.ort}: ${b.regel}: ${b.auszug}');
    }
  }

  // 3. Karten der Detektivklassen.
  for (final klasse in detectiveClasses.keys) {
    final karten = katalog.vonFigur(_klassenAkte, 'klasse:$klasse');
    if (karten.length < 2) f.add('Klasse $klasse: nur ${karten.length} Karte(n), erwartet mindestens 2');
    if (!karten.any((k) => k.hatQuelle('start'))) f.add('Klasse $klasse: keine Startkarte (Quelle start)');
    if (!karten.any((k) => k.hatQuelle('rolle'))) f.add('Klasse $klasse: keine Karte mit Quelle rolle');
  }
  for (final k in katalog.vonAkte(_klassenAkte)) {
    final klasse = k.figur.startsWith('klasse:') ? k.figur.substring(7) : null;
    if (klasse == null || !detectiveClasses.containsKey(klasse)) f.add('${k.id}: Figur ${k.figur} ist keine Detektivklasse');
  }

  // 4. Akten aus content/party/akten.json.
  var abstecherZahl = 0;
  for (final id in akteIds) {
    final ordnerAkte = '$wurzel/content/party/$id';
    final figuren = lies('$ordnerAkte/figuren.json');
    final fall = lies('$ordnerAkte/fall.json');
    final raeume = lies('$ordnerAkte/raeume.json');
    final gegenstaende = lies('$ordnerAkte/gegenstaende.json');
    if (figuren == null || fall == null || raeume == null || gegenstaende == null) continue;

    final rollen = [for (final x in figuren['figuren'] as List) (x as Map)['id'] as String];
    final bekannt = {
      ...rollen,
      (figuren['opfer'] as Map)['id'] as String,
      (figuren['detektiv'] as Map)['id'] as String,
    };
    for (final r in rollen) {
      final karten = katalog.vonFigur(id, r);
      if (karten.length < 2) f.add('Akte $id: Figur $r hat ${karten.length} Karte(n), erwartet mindestens 2');
      if (!karten.any((k) => k.seltenheit == Seltenheit.gewoehnlich && k.hatQuelle('rolle'))) {
        f.add('Akte $id: Figur $r hat keine gewöhnliche Karte mit Quelle rolle');
      }
    }
    for (final k in katalog.vonAkte(id)) {
      if (!bekannt.contains(k.figur)) f.add('${k.id}: Figur ${k.figur} gibt es in Akte $id nicht');
    }
    if (!katalog.vonAkte(id).any((k) => k.hatQuelle('meister'))) f.add('Akte $id: keine Meisterkarte (Quelle meister)');
    for (final pfad in (fall['pfade'] as List).cast<String>()) {
      if (!katalog.vonFigur(id, pfad).any((k) => k.hatQuelle('taeter'))) f.add('Akte $id: Pfad-Person $pfad hat keine Täterkarte (Quelle taeter)');
    }

    // Abstecher dieser Akte.
    final orte = {for (final o in raeume['orte'] as List) (o as Map)['id'] as String};
    final abPfad = '$wurzel/content/party/zusatz/$id/abstecher.json';
    final verlangt = [
      for (final k in katalog.vonAkte(id))
        for (final q in k.quellen)
          if (q.art == 'abstecher') (k, q),
    ];
    final spots = <String, AbstecherOrt>{};
    if (File(abPfad).existsSync()) {
      final j = lies(abPfad);
      if (j != null) {
        final fehler = SchemaPruefer(abstecherSchema).pruefe(j);
        for (final x in fehler) {
          f.add('${_kurz(wurzel, abPfad)}: Schema: $x');
        }
        if (fehler.isEmpty) {
          if (j['akte'] != id) f.add('${_kurz(wurzel, abPfad)}: akte ist ${j['akte']}, erwartet $id');
          final sperren = _sperrregeln(figuren, gegenstaende);
          for (final a in AbstecherOrt.liste(j)) {
            abstecherZahl++;
            if (spots.containsKey(a.id)) f.add('Abstecher ${a.id}: Kennung doppelt');
            spots[a.id] = a;
            if (!orte.contains(a.ort)) f.add('Abstecher ${a.id}: Ort ${a.ort} steht nicht in $id/raeume.json');
            for (final e in {'name': a.name, 'erfolg': a.erfolg, 'teilerfolg': a.teilerfolg, 'pech': a.pech}.entries) {
              _pruefeAbstecherText('Abstecher ${a.id}.${e.key}', e.value, sperren, textPruefer, f);
            }
          }
          final raeumeMitSpot = {for (final a in spots.values) _raumVon(raeume, a.ort)};
          if (raeumeMitSpot.length < 3) f.add('Abstecher in $id: nur ${raeumeMitSpot.length} Raum/Räume, erwartet mindestens 3');
        }
      }
    } else if (verlangt.isNotEmpty) {
      f.add('Akte $id: Karten verweisen auf Abstecher, aber ${_kurz(wurzel, abPfad)} fehlt');
    }
    for (final (k, q) in verlangt) {
      final spot = q.abstecher;
      if (spot == null) {
        f.add('${k.id}: Quelle abstecher ohne Feld abstecher');
      } else if (!spots.containsKey(spot)) {
        f.add('${k.id}: Abstecher $spot steht nicht in zusatz/$id/abstecher.json');
      }
    }
  }
  for (final akte in {for (final k in katalog.alle) k.akte}) {
    if (akte != _klassenAkte && !akteIds.contains(akte)) f.add('Karten für Akte $akte, die nicht in content/party/akten.json steht');
  }

  _ende(f, 'Karten', zusatz: '${katalog.karten.length} Karten, ${akteIds.length} Akten, ${detectiveClasses.length} Klassen, $abstecherZahl Abstecher');
}

/// Prüft eine einzelne Karte: Kennung zur Figur, Quellen, Wirkungstext und Wortlisten.
void _pruefeKarte(KartenDef k, Textpruefer textPruefer, List<String> f) {
  final teile = k.id.split(':');
  final figurTeil = k.figur.startsWith('klasse:') ? k.figur.substring(7) : k.figur;
  if (teile.length == 3 && teile[1] != figurTeil) f.add('${k.id}: Figurteil der Kennung passt nicht zur Figur ${k.figur}');
  if (k.figur.startsWith('klasse:') != (k.akte == _klassenAkte)) {
    f.add('${k.id}: Klassenkarten stehen in Akte $_klassenAkte, Figurenkarten in ihrer Akte');
  }
  for (final q in k.quellen) {
    if (!const {'rolle', 'taeter', 'meister', 'abstecher', 'start'}.contains(q.art)) f.add('${k.id}: unbekannte Quelle ${q.art}');
    if (q.art != 'abstecher' && q.abstecher != null) f.add('${k.id}: Feld abstecher nur bei Quelle abstecher');
  }
  if (k.hatQuelle('meister') && k.seltenheit != Seltenheit.legendaer) f.add('${k.id}: Meisterkarte ist nicht legendär');
  if (k.seltenheit == Seltenheit.legendaer && !k.hatQuelle('meister')) f.add('${k.id}: legendäre Karte ohne Quelle meister');

  // Wirkungstext: genau die Wirkung der Art, in einem Satz, ohne Versprechen.
  final t = k.text;
  final ort = '${k.id}.text';
  final eigenes = _schluesselwort[k.art];
  if (eigenes != null && !t.contains(eigenes)) f.add('$ort: nennt die Wirkung nicht („$eigenes“ fehlt)');
  for (final e in _schluesselwort.entries) {
    if (e.key != k.art && t.contains(e.value)) f.add('$ort: Text einer ${k.art.name}-Karte nennt „${e.value}“ (Wirkung ${e.key.name})');
  }
  if (k.art == KartenArt.werkzeug && !t.contains('+1')) f.add('$ort: Werkzeug-Text nennt „+1“ nicht');
  if (k.art == KartenArt.zeit && !t.contains('+${k.wert} Nachtminuten')) f.add('$ort: Zeit-Text nennt „+${k.wert} Nachtminuten“ nicht');
  if (!_mitNachtminuten.contains(k.art) && t.contains('Nachtminuten')) f.add('$ort: nennt Nachtminuten, die diese Art nicht gibt');
  if (textPruefer.saetze(t).length != 1) f.add('$ort: mehr oder weniger als ein Satz');
  for (final w in _versprechen) {
    if (_wortAnfang(w).hasMatch(t)) f.add('$ort: „$w“ verspricht Wissen oder Einfluss, Karten sind nur Komfort');
  }
  for (final b in [
    ...textPruefer.pruefe(TextQuelle(ort: '${k.id}.titel', text: k.titel, vorlesen: false)),
    ...textPruefer.pruefe(TextQuelle(ort: ort, text: t, vorlesen: false)),
  ]) {
    f.add('${b.ort}: ${b.regel}: ${b.auszug}');
  }
}

/// Sperrregeln für Abstecher-Texte: feste Wörter, Gegenstandsnamen und Figurennamen der Akte.
List<RegExp> _sperrregeln(Map<String, Object?> figuren, Map<String, Object?> gegenstaende) {
  final woerter = <String>{..._spoilerwoerter};
  for (final g in gegenstaende['gegenstaende'] as List) {
    for (final m in _buchstaben.allMatches((g as Map)['name'] as String)) {
      final w = m.group(0)!.toLowerCase();
      if (w.length >= 6 && !_allgemeineWoerter.contains(w)) woerter.add(w);
    }
  }
  final regeln = [for (final w in woerter) _wortAnfang(w)];
  final namen = <String>{
    for (final x in [...(figuren['figuren'] as List), figuren['detektiv'] as Map, figuren['opfer'] as Map])
      if ((x as Map)['id'] != 'detective') (x['name'] as String? ?? x['id'] as String).toLowerCase(),
    for (final x in figuren['figuren'] as List) (x as Map)['id'] as String,
  };
  return [
    ...regeln,
    for (final n in namen) RegExp('(?<!\\p{L})${RegExp.escape(n)}(?!\\p{L})', unicode: true, caseSensitive: false),
  ];
}

RegExp _wortAnfang(String wort) => RegExp('(?<!\\p{L})${RegExp.escape(wort)}', unicode: true, caseSensitive: false);

void _pruefeAbstecherText(String ort, String text, List<RegExp> sperren, Textpruefer textPruefer, List<String> f) {
  if (text.trim().isEmpty) f.add('$ort: leer');
  if (ort.endsWith('.name')) {
    if (text.length > 32) f.add('$ort: Name länger als 32 Zeichen');
  } else if (textPruefer.saetze(text).length > 2) {
    f.add('$ort: mehr als zwei Sätze');
  }
  for (final re in sperren) {
    final m = re.firstMatch(text);
    if (m != null) f.add('$ort: „${m.group(0)}“ gehört nicht in einen pfadgleichen Abstecher-Text');
  }
  for (final b in textPruefer.pruefe(TextQuelle(ort: ort, text: text, vorlesen: false))) {
    f.add('${b.ort}: ${b.regel}: ${b.auszug}');
  }
}

/// Raum eines Ortes (für die Streuung der Abstecher über die Räume).
String _raumVon(Map<String, Object?> raeume, String ort) {
  for (final o in raeume['orte'] as List) {
    if ((o as Map)['id'] == ort) return o['raum'] as String;
  }
  return '?';
}

void _ende(List<String> f, String name, {String zusatz = ''}) {
  for (final x in f) {
    stdout.writeln(x);
  }
  stdout.writeln(f.isEmpty ? '$name: OK${zusatz.isEmpty ? '' : ' ($zusatz)'}' : '$name: ${f.length} Befund(e)');
  exitCode = f.isEmpty ? 0 : 1;
}

String? _wert(List<String> args, String name) {
  final i = args.indexOf(name);
  return i >= 0 && i + 1 < args.length ? args[i + 1] : null;
}

String _kurz(String wurzel, String pfad) => pfad.startsWith('$wurzel/') ? pfad.substring(wurzel.length + 1) : pfad;

/// Wurzel des Repositorys: der erste Ordner nach oben mit content/party/akten.json.
String _wurzel() {
  var d = Directory.current;
  while (!File('${d.path}/content/party/akten.json').existsSync()) {
    final p = d.parent;
    if (p.path == d.path) break;
    d = p;
  }
  return d.path;
}
