// Akten-Umsetzer: Kanon plus Autoren-Überlagerung ergibt das Bündel einer Akte.
//
// Aufruf (Repo-Wurzel oder Paketordner):
//   dart run packages/krimidinner_kanon/bin/akte_export.dart [--akte gewoelbe] [--pruefen] [--ausgabe <ordner>]
//
// Eingabe
//   Kanon        krimidinner/spuk-im-gewoelbe/10_kanon/K*.md (Datensätze `@ID [O|G|L] | Feld: Wert`, gelesen mit KrimiKanon)
//   Überlagerung content/party/<akte>/_autor/*.json (von Hand geschriebene Fassung für Spielende: Text, Karte, Beweise,
//                Entscheidungen; gleiche Form wie das Bündel, nur ohne das, was der Kanon schon sagt)
// Ausgabe
//   content/party/<akte>/*.json und texte/*.json, jede erzeugte Datei mit "generiert": "akte_export".
//
// Aus dem Kanon kommen: Namen, Aussprache, Alter, Geschlecht, Herkunft, Besetzungsplatz, Tarn-Alibi und Beziehung zum
// Burgwart jeder Rolle (K2), Pfade, Verdächtigenkreis und Endenmatrix (K6), Kanon-Version (VERSION.md), Zeit und
// Beteiligte der Zeitleiste (K1, Z-Datensätze), Partner-Vorgabe der Pflichtgespräche und Ersatzpartner (K4).
//
// Die Ausgabe ist deterministisch: gleiche Eingabe, gleiche Bytes. Mit --pruefen wird nichts geschrieben; der Befehl
// vergleicht nur und endet mit Status 1, wenn eine Datei vom Erzeugnis abweicht (Drift).
//
// Prüfung der Akte danach: dart run packages/mordakte_core/bin/akte_pruefen.dart --fall <akte>
import 'dart:convert';
import 'dart:io';

import 'package:krimidinner_kanon/krimidinner_kanon.dart';

const marke = 'akte_export';
const _kanonOrdner = 'krimidinner/spuk-im-gewoelbe/10_kanon';

typedef Karte = Map<String, Object?>;

void main(List<String> args) {
  String? wert(String name) {
    final i = args.indexOf(name);
    return i >= 0 && i + 1 < args.length ? args[i + 1] : null;
  }

  final akte = wert('--akte') ?? 'gewoelbe';
  final nurPruefen = args.contains('--pruefen');
  final wurzel = _wurzel();
  final ausgabe = wert('--ausgabe') ?? '$wurzel/content/party/$akte';
  try {
    final dateien = Umsetzer(wurzel: wurzel, akte: akte).erzeuge();
    var drift = 0;
    for (final e in dateien.entries) {
      final ziel = File('$ausgabe/${e.key}');
      if (nurPruefen) {
        final ist = ziel.existsSync() ? ziel.readAsStringSync() : null;
        if (ist != e.value) {
          stdout.writeln('Abweichung: ${e.key}${ist == null ? ' fehlt' : ''}');
          drift++;
        }
      } else {
        ziel.parent.createSync(recursive: true);
        ziel.writeAsStringSync(e.value);
      }
    }
    if (nurPruefen) {
      stdout.writeln(drift == 0 ? 'Akte $akte: ${dateien.length} Dateien stimmen mit dem Erzeugnis überein' : 'Akte $akte: $drift Dateien weichen ab');
      exitCode = drift == 0 ? 0 : 1;
    } else {
      stdout.writeln('Akte $akte: ${dateien.length} Dateien nach $ausgabe geschrieben');
    }
  } on UmsetzerFehler catch (e) {
    stderr.writeln('akte_export: ${e.meldung}');
    exitCode = 1;
  }
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

class UmsetzerFehler implements Exception {
  UmsetzerFehler(this.meldung);
  final String meldung;
  @override
  String toString() => meldung;
}

/// Rollenplätze je Stufe der Besetzung (Plätze von bis).
const _stufen = [
  (1, 1, 4),
  (2, 5, 8),
  (3, 9, 12),
  (4, 13, 16),
  (5, 17, 20),
];

int _stufeVon(int platz) => _stufen.firstWhere((s) => platz >= s.$2 && platz <= s.$3).$1;

class Umsetzer {
  Umsetzer({required this.wurzel, required this.akte});

  final String wurzel;
  final String akte;

  late final String _autor = '$wurzel/content/party/$akte/_autor';
  late final KrimiKanon _k = _liesKanon();

  // ------------------------------------------------------------------ Eingabe

  KrimiKanon _liesKanon() {
    final ordner = Directory('$wurzel/$_kanonOrdner');
    if (!ordner.existsSync()) throw UmsetzerFehler('Kanon-Ordner fehlt: ${ordner.path}');
    final inhalt = <String, String>{
      for (final f in ordner.listSync().whereType<File>())
        if (istKanonDatei(f.path)) f.path.split('/').last: f.readAsStringSync(),
    };
    final k = KrimiKanon.ausText(inhalt);
    if (k.lesefehler.isNotEmpty) throw UmsetzerFehler('Kanon unlesbar: ${k.lesefehler.first}');
    return k;
  }

  Karte _lies(String name) {
    final f = File('$_autor/$name');
    if (!f.existsSync()) throw UmsetzerFehler('Überlagerung fehlt: _autor/$name');
    return (jsonDecode(f.readAsStringSync()) as Map).cast<String, Object?>();
  }

  KanonDatensatz _d(String id) => _k.datensaetze[id] ?? (throw UmsetzerFehler('Kanon: Datensatz $id fehlt'));

  String _f(String id, String feld) {
    final v = _d(id).feld(feld);
    if (v == null || v.isEmpty) throw UmsetzerFehler('Kanon: $id hat kein Feld „$feld“');
    return v;
  }

  /// Gesprächsdatensätze `G<runde>-<nr>` des Kanons in Reihenfolge (Runde, dann Nummer).
  List<KanonDatensatz> _gespraeche({int? runde}) {
    final re = RegExp(r'^G([1-3])-(\d+)$');
    final l = [
      for (final d in _k.datensaetze.values)
        if (re.hasMatch(d.id) && (runde == null || int.parse(re.firstMatch(d.id)!.group(1)!) == runde)) d,
    ];
    int schluessel(KanonDatensatz d) {
      final m = re.firstMatch(d.id)!;
      return int.parse(m.group(1)!) * 1000 + int.parse(m.group(2)!);
    }

    return l..sort((a, b) => schluessel(a).compareTo(schluessel(b)));
  }

  // ------------------------------------------------------------------ Ausgabe

  /// Alle Bündeldateien: relativer Pfad → Inhalt.
  Map<String, String> erzeuge() {
    final out = <String, String>{};
    final setting = _lies('setting.json');
    final settingId = setting['settingId'] as String? ?? 'spuk_im_$akte';
    final raeume = _lies('raeume.json');
    final figuren = _figuren(raeume);
    final ids = _rollenIds(figuren);

    void datei(String pfad, Karte inhalt) {
      final m = <String, Object?>{'settingId': settingId};
      for (final e in inhalt.entries) {
        if (e.key == 'settingId' || e.key == 'generiert') continue;
        m[e.key] = e.value;
      }
      m['generiert'] = marke;
      out[pfad] = '${const JsonEncoder.withIndent('  ').convert(m)}\n';
    }

    datei('setting.json', setting);
    datei('raeume.json', raeume);
    datei('wahrnehmung.json', _lies('wahrnehmung.json'));
    datei('figuren.json', figuren);
    datei('gegenstaende.json', _lies('gegenstaende.json'));
    datei('beobachtungen.json', _lies('beobachtungen.json'));
    datei('zeitleiste.json', _zeitleiste(ids));
    datei('entscheidungen.json', _lies('entscheidungen.json'));
    datei('bonus.json', _lies('bonus.json'));
    datei('fall.json', _fall(ids));
    datei('besetzung.json', _besetzung(figuren, ids));
    datei('gruppenwahl.json', _gruppenwahl(figuren));
    _texte(out, datei, settingId, figuren, ids);
    return out;
  }

  // ------------------------------------------------------------------ Figuren

  /// Rolle (Kanon R05) → Figurenkennung (paulina), nach Besetzungsplatz.
  Map<String, String> _rollenIds(Karte figuren) => {
        for (final f in (figuren['figuren'] as List).cast<Karte>()) 'R${(f['besetzungsplatz'] as int).toString().padLeft(2, '0')}': f['id'] as String,
      };

  Karte _figuren(Karte raeume) {
    final ov = _lies('figuren.json');
    final orte = {for (final o in (raeume['orte'] as List).cast<Karte>()) o['id'] as String: o};
    Karte koord(String ort) {
      final o = orte[ort] ?? (throw UmsetzerFehler('Figuren: unbekannter Ermittlungsort $ort'));
      return {'x': o['x'], 'y': o['y']};
    }

    const herkunftKanon = {'deutsch', 'türkisch', 'kurdisch', 'polnisch', 'bosnisch'};
    final figuren = <Karte>[];
    final ovFiguren = (ov['figuren'] as Map).cast<String, Object?>();
    for (final e in ovFiguren.entries) {
      final x = (e.value as Map).cast<String, Object?>();
      final r = x['kanon'] as String? ?? (throw UmsetzerFehler('Figur ${e.key}: Feld kanon (Rolle R..) fehlt'));
      final platz = int.parse(r.substring(1));
      final voll = _f('$r-STAMM', 'Name');
      final wurzeln = _f('$r-STAMM', 'Wurzeln').split(RegExp(r'[\s,;(]')).first.toLowerCase();
      if (!herkunftKanon.contains(wurzeln)) throw UmsetzerFehler('$r: Wurzeln „$wurzeln“ nicht in $herkunftKanon');
      final m = <String, Object?>{
        'id': e.key,
        'name': voll.split(' ').first,
        'vollerName': voll,
        'aussprache': _f('$r-STAMM', 'Aussprache'),
        'age': int.parse(_f('$r-STAMM', 'Alter')),
        'geschlecht': _f('$r-STAMM', 'Geschlecht'),
        'herkunft': wurzeln,
        'tier': _stufeVon(platz),
        'besetzungsplatz': platz,
        'minPlayers': platz,
        'roleTitle': x['roleTitle'],
        'isPotentialKiller': platz <= 4,
        'colorCode': x['colorCode'],
        'farbname': x['farbname'],
        'startRoom': x['startRoom'],
        'ermittlungsOrt': x['ermittlungsOrt'],
        'coordinates': koord(x['ermittlungsOrt'] as String),
        'visualSpecs': x['visualSpecs'],
        'motiveAndConflict': _f('$r-ÖFFENTLICH', 'Beziehung zum Burgwart (bekannt)'),
        'blackoutAlibi': _f('$r-ÖFFENTLICH', 'Behauptetes Alibi'),
        'roleSecret': x['roleSecret'] ?? _f('$r-GEHEIM', 'Geheimnis'),
        'persoenlichesZiel': x['persoenlichesZiel'],
        'nebendelikt': x['nebendelikt'],
        'loyalitaet': x['loyalitaet'],
        'luegen': x['luegen'],
      };
      for (final opt in ['innocentProfile', 'killerProfile']) {
        if (x[opt] != null) m[opt] = x[opt];
      }
      m['look'] = x['look'];
      if (x['beweisFarbe'] != null) m['beweisFarbe'] = x['beweisFarbe'];
      m['alltag'] = x['alltag'];
      figuren.add(m);
    }
    figuren.sort((a, b) => (a['besetzungsplatz'] as int).compareTo(b['besetzungsplatz'] as int));
    final plaetze = figuren.map((f) => f['besetzungsplatz']).toList();
    for (var i = 0; i < plaetze.length; i++) {
      if (plaetze[i] != i + 1) throw UmsetzerFehler('Figuren: Besetzungsplätze lückenhaft ($plaetze)');
    }

    final det = (ov['detektiv'] as Map).cast<String, Object?>();
    final opfer = (ov['opfer'] as Map).cast<String, Object?>();
    final detektiv = <String, Object?>{
      'id': 'detective',
      'title': det['title'],
      'selectableGenders': det['selectableGenders'],
      'colorCode': det['colorCode'],
      'farbname': det['farbname'],
      'startRoom': det['startRoom'],
      'ermittlungsOrt': det['ermittlungsOrt'],
      'coordinates': koord(det['ermittlungsOrt'] as String),
      'visualSpecs': det['visualSpecs'],
      'tatnacht': det['tatnacht'],
      'auftrag': det['auftrag'],
      'nieVerdaechtig': det['nieVerdaechtig'],
      'look': det['look'],
    };
    final stamm = _d('BW-STAMM');
    final opferM = <String, Object?>{
      'id': opfer['id'] ?? 'burgwart',
      'name': opfer['name'],
      'age': opfer['age'],
      'geschlecht': opfer['geschlecht'],
      'roleTitle': opfer['roleTitle'],
      'isNpc': opfer['isNpc'],
      'colorCode': opfer['colorCode'],
      'farbname': opfer['farbname'],
      'startRoom': opfer['startRoom'],
      'ermittlungsOrt': opfer['ermittlungsOrt'],
      'coordinates': koord(opfer['ermittlungsOrt'] as String),
      'status': opfer['status'],
      'visualSpecs': opfer['visualSpecs'],
      'motiveAndConflict': opfer['motiveAndConflict'],
      'warmeSeite': opfer['warmeSeite'],
      'erinnerung': opfer['erinnerung'],
      'schluesselbund': opfer['schluesselbund'],
      'gedaechtnisLueckeAb': opfer['gedaechtnisLueckeAb'],
      'look': opfer['look'],
      if (opfer['schluesselbundMaterial'] != null) 'schluesselbundMaterial': opfer['schluesselbundMaterial'],
    };
    // Name und Alter des Burgwarts stehen im Kanon (BW-STAMM); die Überlagerung darf nicht abweichen.
    if (opferM['name'] != stamm.feld('Name') || '${opferM['age']}' != stamm.feld('Alter')) {
      throw UmsetzerFehler('Burgwart: Name oder Alter weicht vom Kanon ab (${stamm.feld('Name')}, ${stamm.feld('Alter')})');
    }
    return {
      'hinweis': ov['hinweis'] ?? 'Die Figuren des Falls: Detektiv, Opfer und 20 Rollen. Name, Alter, Herkunft, Besetzungsplatz und Tarn-Alibi stammen aus dem Kanon (K2), alles andere aus der Überlagerung.',
      'lookHinweis': ov['lookHinweis'] ?? 'Look: Farben als Hex, Kopfform und Statur aus festen Listen. Die Farbe jeder Rolle unterscheidet sich im selben Raum deutlich von den anderen.',
      'detektiv': detektiv,
      'opfer': opferM,
      'figuren': figuren,
    };
  }

  // ------------------------------------------------------------------ Fall

  Karte _fall(Map<String, String> ids) {
    final ov = _lies('fall.json');
    final version = RegExp(r'v(\d+)\.(\d+)').firstMatch(File('$wurzel/$_kanonOrdner/VERSION.md').readAsStringSync());
    if (version == null) throw UmsetzerFehler('VERSION.md ohne Versionsnummer');
    // Verdächtigenkreis (VK-1): „immer genau R01 Adnan, R02 Rojda, R03 Merle, R04 Jonas“.
    final kreis = RegExp(r'R(\d\d)').allMatches(_f('VK-1', 'Verdächtigenkreis')).map((m) => ids['R${m.group(1)}']!).toList();
    // Täterpfad: die Rolle, deren Anklage im Meisterende (EM-1) richtig ist.
    final enden = <Karte>[];
    final namen = (ov['endenNamen'] as Map).cast<String, String>();
    final endenIds = namen.keys.toList();
    String? taeter;
    for (var i = 1; i <= 4; i++) {
      final bed = _f('EM-$i', 'Bedingung');
      final punkte = RegExp(r'(\d+) bis (\d+) Punkte').firstMatch(bed) ?? (throw UmsetzerFehler('EM-$i: Punkte nicht lesbar'));
      final richtig = RegExp(r'angeklagt R\d\d und').hasMatch(bed);
      if (richtig) taeter ??= ids[RegExp(r'angeklagt (R\d\d) und').firstMatch(bed)!.group(1)!];
      enden.add({
        'id': endenIds[i - 1],
        'name': namen[endenIds[i - 1]],
        'anklage': richtig ? 'richtig' : 'falsch',
        'punkteVon': int.parse(punkte.group(1)!),
        'punkteBis': int.parse(punkte.group(2)!),
      });
    }
    return {
      'kanonVersion': '${version.group(1)}.${version.group(2)}.0',
      'titel': ov['titel'],
      'untertitel': ov['untertitel'],
      'pfade': [taeter],
      'kernverdaechtige': kreis,
      'personen': ov['personen'],
      'runden': [
        for (final r in (ov['runden'] as List).cast<Karte>()) {'nr': r['nr'], 'name': r['name'], 'uhrzeit': r['uhrzeit'], 'kern': r['kern']},
      ],
      'finaleUhrzeit': ov['finaleUhrzeit'],
      'morgenUhrzeit': ov['morgenUhrzeit'],
      'rundendauerMinuten': ov['rundendauerMinuten'],
      'schwellen': ov['schwellen'],
      'enden': {'matrix': enden},
      'regeln': ov['regeln'],
      if (ov['simulation'] != null) 'simulation': ov['simulation'],
      if (ov['pruefprofil'] != null) 'pruefprofil': ov['pruefprofil'],
      if (ov['zug'] != null) 'zug': ov['zug'],
    };
  }

  // ------------------------------------------------------------------ Zeitleiste

  Karte _zeitleiste(Map<String, String> ids) {
    final ov = _lies('zeitleiste.json');
    List<String> wer(String s) {
      if (s.trim().isEmpty) return const [];
      return [
        for (final t in s.split(',').map((x) => x.trim()))
          if (RegExp(r'^R\d\d$').hasMatch(t))
            ids[t] ?? (throw UmsetzerFehler('Zeitleiste: Rolle $t unbekannt'))
          else if (t == 'BW')
            'burgwart'
          else if (t == 'DET')
            'detective'
          else
            'alle',
      ];
    }

    final eintraege = <Karte>[];
    for (final e in (ov['eintraege'] as List).cast<Karte>()) {
      final z = _d(e['kanon'] as String);
      final zeit = RegExp(r'\d{1,2}:\d\d(?::\d\d)?').firstMatch(z.feld('Zeit') ?? '')?.group(0) ?? (throw UmsetzerFehler('${z.id}: keine Zeit'));
      final wen = {...wer(z.feld('Wer') ?? '')}.toList();
      eintraege.add({
        'id': e['id'],
        'zeit': zeit,
        'ort': e['ort'],
        'wer': e['wer'] ?? wen,
        'text': e['text'],
        'pfade': 'alle',
      });
    }
    return {'hinweis': ov['hinweis'], 'eintraege': eintraege};
  }

  // ------------------------------------------------------------------ Besetzung

  Karte _besetzung(Karte figuren, Map<String, String> ids) {
    final ov = _lies('besetzung.json');
    final liste = (figuren['figuren'] as List).cast<Karte>();
    final reihenfolge = [for (final f in liste) f['id'] as String];
    final bilanz = <Karte>[];
    for (var n = 4; n <= 20; n++) {
      final m = liste.take(n).where((f) => f['geschlecht'] == 'm').length;
      bilanz.add({'rollen': n, 'm': m, 'w': n - m});
    }
    // Ersatzpartner: die Ersatz-Rolle, die der Kanon (K4) für den Fall nennt, dass ein Gesprächsziel nicht besetzt ist.
    final ersatz = <String, List<String>>{};
    for (final g in _gespraeche()) {
      final ziel = g.feld('Ziel') ?? '';
      final er = g.feld('Ersatz') ?? '';
      if (er.isEmpty || !ids.containsKey(ziel) || !ids.containsKey(er)) continue;
      final l = ersatz[ids[ziel]!] ??= [];
      if (!l.contains(ids[er]!)) l.add(ids[er]!);
    }
    final extra = (ov['ersatzpartner'] as Map?)?.cast<String, Object?>() ?? const {};
    for (final e in extra.entries) {
      final l = ersatz[e.key] ??= [];
      for (final r in (e.value as List).cast<String>()) {
        if (!l.contains(r)) l.add(r);
      }
    }
    return {
      'hinweis': ov['hinweis'],
      'minRollen': 4,
      'maxRollen': 20,
      'reihenfolge': reihenfolge,
      'stufen': [
        for (final s in _stufen) {'stufe': s.$1, 'plaetze': [s.$2, s.$3]},
      ],
      'geschlechterBilanz': bilanz,
      'regeln': ov['regeln'],
      'ersatzpartner': {for (final id in reihenfolge) if (ersatz.containsKey(id)) id: ersatz[id]},
    };
  }

  // ------------------------------------------------------------------ Gruppenwahl

  Karte _gruppenwahl(Karte figuren) {
    final ov = _lies('gruppenwahl.json');
    final wahlen = <Karte>[];
    for (final f in (figuren['figuren'] as List).cast<Karte>()) {
      final id = f['id'] as String;
      final nd = f['nebendelikt'] as Map?;
      final loy = f['loyalitaet'] as Map?;
      final geheimnis = nd != null ? nd['id'] as String : 'persoenlichesZiel';
      for (var r = 1; r <= 3; r++) {
        // Runde 1 und 3 kosten das Geheimnis, Runde 2 die Loyalität (wo es eine gibt).
        final lo = r == 2 && loy != null;
        final w = <String, Object?>{
          'id': 'gw_${id}_$r',
          'rolle': id,
          'runde': r,
          'quelle': lo ? 'loyalitaet' : 'geheimnis',
          'a': lo
              ? {'kosten': {'art': 'freund', 'bezug': loy['zu']}, 'nutzen': {'art': 'gruppe'}}
              : {'kosten': {'art': 'geheimnis', 'bezug': geheimnis}, 'nutzen': {'art': 'gruppe'}},
          'b': lo
              ? {'kosten': {'art': 'gruppe'}, 'nutzen': {'art': 'freund', 'bezug': loy['zu']}}
              : {'kosten': {'art': 'gruppe'}, 'nutzen': {'art': 'ziel', 'bezug': 'persoenlichesZiel'}},
        };
        // Sabotage gibt es nur in der Täterfassung einer Kernrolle (hier: der Täterpfad).
        if (f['isPotentialKiller'] == true && (ov['sabotage'] as List).contains(id)) {
          w['bTaeter'] = {'art': 'sabotage', 'kosten': {'art': 'gruppe'}, 'nutzen': {'art': 'tarnung'}};
        }
        wahlen.add(w);
      }
    }
    return {
      'hinweis': ov['hinweis'],
      'wertung': {'kooperativ': 1, 'eigennuetzig': 0, 'sabotage': -1},
      'wahlen': wahlen,
    };
  }

  // ------------------------------------------------------------------ Texte

  void _texte(Map<String, String> out, void Function(String, Karte) datei, String settingId, Karte figuren, Map<String, String> ids) {
    final liste = (figuren['figuren'] as List).cast<Karte>();
    final stufeVon = {for (final f in liste) f['id'] as String: f['tier'] as int};
    final dateien = <({String name, String bereich})>[];

    void textdatei(String name, String bereich, String hinweis, List<Object?> eintraege) {
      dateien.add((name: name, bereich: bereich));
      datei('texte/$name.json', {'bereich': bereich, 'hinweis': hinweis, 'eintraege': eintraege});
    }

    String plaetze(int stufe) {
      final s = _stufen.firstWhere((x) => x.$1 == stufe);
      return 'Besetzungsplätze ${s.$2} bis ${s.$3}';
    }

    // Erzähler: nach Schlüssel in feste Dateien sortiert.
    final erz = (_lies('erzaehler.json')['eintraege'] as Map).cast<String, String>();
    List<Object?> eintragsliste(Iterable<MapEntry<String, String>> es) => [for (final e in es) {'id': e.key, 'text': e.value}];
    Iterable<MapEntry<String, String>> wo(bool Function(String) f) => erz.entries.where((e) => f(e.key));
    final pfad = (_fall(ids)['pfade'] as List).first as String;
    final belegt = <String>{};
    void erzaehlerDatei(String name, String hinweis, bool Function(String) f) {
      final es = wo(f).toList();
      belegt.addAll(es.map((e) => e.key));
      if (es.isNotEmpty) textdatei(name, 'erzaehler', hinweis, eintragsliste(es));
    }

    erzaehlerDatei('erzaehler-intro', 'Intro: intro.start, intro.lacher.<id>.<besetzt|npc>, intro.auftrag.<m|w>.', (k) => k.startsWith('intro.'));
    erzaehlerDatei('erzaehler-runden', 'Runden: runde.N.start, bonus.rahmen, resuemee.gruppe.N, resuemee.rest.*, resuemee.lage.N.*, anklage.start.',
        (k) => k.startsWith('runde.') || k == 'bonus.rahmen' || k.startsWith('resuemee.') || k == 'anklage.start');
    erzaehlerDatei('erzaehler-npc', 'Wissen unbesetzter Gäste: npc.<figur>.<runde>.', (k) => k.startsWith('npc.'));
    erzaehlerDatei('erzaehler-finale-$pfad', 'Finale im Pfad $pfad: finale.$pfad.<ende> und rueckblende.$pfad.', (k) => k.startsWith('finale.') || k.startsWith('rueckblende.'));
    erzaehlerDatei('erzaehler-aufloesung', 'Auflösung: aufloesung.gruppe.N und aufloesung.<rolle>.', (k) => k.startsWith('aufloesung.'));
    final rest = erz.keys.where((k) => !belegt.contains(k)).toList();
    if (rest.isNotEmpty) throw UmsetzerFehler('Erzähler-Schlüssel ohne Datei: $rest');

    // Dossiers je Stufe.
    final dossiers = (_lies('dossiers.json')['eintraege'] as Map).cast<String, Object?>();
    for (final f in liste) {
      if (!dossiers.containsKey(f['id'])) throw UmsetzerFehler('Dossier für ${f['id']} fehlt');
    }
    for (final s in _stufen) {
      final es = [
        for (final f in liste)
          if (f['tier'] == s.$1)
            {
              'rolle': f['id'],
              ...(dossiers[f['id']] as Map).cast<String, Object?>(),
            },
      ];
      textdatei('dossiers-b${s.$1}', 'dossier', 'Dossiers der ${plaetze(s.$1)}.', [
        for (final e in es) _ordne(e, ['rolle', 'wer', 'weiss', 'verbirgt', 'ziel', 'besetzung']),
      ]);
    }

    // Täterfassung.
    final taeter = (_lies('taeter.json')['eintraege'] as Map).cast<String, Object?>();
    for (final e in taeter.entries) {
      textdatei('taeter-${e.key}', 'taeter', 'Täterfassung ${e.key}.', [
        _ordne({'rolle': e.key, ...(e.value as Map).cast<String, Object?>()}, ['rolle', 'tarnung', 'tatwissen', 'verbirgt', 'ziel']),
      ]);
    }

    // Detektiv-Bogen.
    final det = (_lies('detektiv.json')['eintraege'] as Map).cast<String, String>();
    textdatei('detektiv', 'detektiv', 'Detektiv-Bogen (m und w) und Ermittlungsbogen.', eintragsliste(det.entries));

    // Pflichtgespräche je Runde und Stufe. Partner: Überlagerung, sonst der Kanon (K4, Ziel des n-ten Gesprächs).
    final gesp = (_lies('gespraeche.json')['eintraege'] as List).cast<Karte>();
    final vorgabe = <String, String>{};
    for (final f in liste) {
      final r = 'R${(f['besetzungsplatz'] as int).toString().padLeft(2, '0')}';
      for (var runde = 1; runde <= 3; runde++) {
        final eigene = [for (final g in _gespraeche(runde: runde)) if (g.feld('Von') == r) g];
        for (var i = 0; i < eigene.length; i++) {
          final z = eigene[i].feld('Ziel') ?? '';
          vorgabe['g_${f['id']}_${runde}_${i + 1}'] = ids[z] ?? 'detective';
        }
      }
    }
    final gesehen = <String>{};
    final nachDatei = <String, List<Object?>>{};
    for (final g in gesp) {
      final id = g['id'] as String;
      final m = RegExp(r'^g_([a-z0-9_]+)_([1-3])_([1-3])$').firstMatch(id) ?? (throw UmsetzerFehler('Gespräch $id: Kennung unlesbar'));
      if (!gesehen.add(id)) throw UmsetzerFehler('Gespräch $id doppelt');
      final rolle = m.group(1)!, runde = int.parse(m.group(2)!), nr = int.parse(m.group(3)!);
      final stufe = stufeVon[rolle] ?? (throw UmsetzerFehler('Gespräch $id: Rolle $rolle unbekannt'));
      final partner = g['partner'] as String? ?? vorgabe[id] ?? (throw UmsetzerFehler('Gespräch $id: kein Partner'));
      (nachDatei['gespraeche-r$runde-b$stufe'] ??= []).add({
        'id': id,
        'rolle': rolle,
        'runde': runde,
        'nr': nr,
        'partner': partner,
        'thema': g['thema'],
        'ziel': g['ziel'],
        'preisgabe': g['preisgabe'] ?? const <String>[],
        'text': g['text'],
      });
    }
    final namen = nachDatei.keys.toList()..sort();
    for (final n in namen) {
      final rolleVon = n.replaceFirst('gespraeche-r', '');
      textdatei(n, 'gespraech', 'Pflichtgespräche Runde ${rolleVon.substring(0, 1)}, ${plaetze(int.parse(rolleVon.substring(3)))}.', nachDatei[n]!);
    }

    // Rundenwahl: Kernrollen mit Sabotage, die übrigen je Stufe.
    final wahlen = (_lies('wahlen.json')['eintraege'] as Map).cast<String, Object?>();
    for (final s in _stufen) {
      final es = <Object?>[];
      for (final f in liste) {
        if (f['tier'] != s.$1) continue;
        for (var r = 1; r <= 3; r++) {
          final id = 'gw_${f['id']}_$r';
          final w = (wahlen[id] as Map?) ?? (throw UmsetzerFehler('Wahltext $id fehlt'));
          es.add(_ordne({'id': id, ...w.cast<String, Object?>()}, ['id', 'a', 'b', 'sabotage']));
        }
      }
      textdatei(s.$1 == 1 ? 'wahlen-kern' : 'wahlen-b${s.$1}', 'wahl', s.$1 == 1 ? 'Rundenwahl der vier Kernrollen mit Sabotage der Täterfassung.' : 'Rundenwahl der ${plaetze(s.$1)}.', es);
    }

    final index = {
      'hinweis': 'Alle Dateien der Textsammlung. Jede Kennung kommt genau einmal vor; Verweise auf Kanon-Tatsachen statt Abschrift.',
      'dateien': [for (final d in dateien) {'datei': '${d.name}.json', 'bereich': d.bereich}],
    };
    datei('texte/index.json', index);
  }

  /// Schlüssel in fester Reihenfolge; unbekannte Schlüssel fallen auf (Schema schlägt an).
  Karte _ordne(Karte m, List<String> reihenfolge) => {
        for (final k in reihenfolge)
          if (m.containsKey(k)) k: m[k],
        for (final e in m.entries)
          if (!reihenfolge.contains(e.key)) e.key: e.value,
      };
}
