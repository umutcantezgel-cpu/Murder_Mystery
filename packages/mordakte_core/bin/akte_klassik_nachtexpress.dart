// Konverter der klassischen Akte „Nachtexpress“ in ein Bündel im Party-Kanonformat.
//
// Liest content/scenarios/nachtexpress.json (unverändert) und das Autoren-Overlay
// content/party/nachtexpress/_autor/*.json und schreibt die generierten Dateien
// des Bündels content/party/nachtexpress/ deterministisch:
//
//   raeume.json                        Karte aus map.rows, rooms, props, hotspots, suspects
//   figuren.json                       Figuren, Aussehen und Standorte (Szenario + Overlay)
//   fall.json                          Titel, Enden, Runden (Szenario + Overlay)
//   setting.json                       Schauplatz, Darstellung (Palette, Wetter) (Szenario + Overlay)
//   texte/erzaehler-finale-<pfad>.json Finale und Rückblende (Urteile und Epiloge des Szenarios + Overlay)
//
// Jede erzeugte Datei trägt den Kopf "generiert": "akte_klassik".
//
// Aufruf (im Paketordner):
//   dart run bin/akte_klassik_nachtexpress.dart            schreibt die Dateien
//   dart run bin/akte_klassik_nachtexpress.dart --pruefen  schreibt nichts, Exitcode 1 bei Abweichung (Drift)
import 'dart:convert';
import 'dart:io';

import 'package:mordakte_core/mordakte_core.dart' show propCatalog;

const _akte = 'nachtexpress';
const _kopf = 'akte_klassik';

typedef J = Map<String, Object?>;

void main(List<String> args) {
  final pruefen = args.contains('--pruefen');
  final wurzel = _wurzel();
  final ordner = '$wurzel/content/party/$_akte';
  final szenario = _lies('$wurzel/content/scenarios/$_akte.json');
  J overlay(String n) => _lies('$ordner/_autor/$n.json');

  final k = _Konverter(szenario, overlay('raeume'), overlay('figuren'), overlay('luegen'), overlay('fall'), overlay('setting'), overlay('finale'));
  final dateien = <String, J>{
    'raeume.json': k.raeume(),
    'figuren.json': k.figuren(),
    'fall.json': k.fall(),
    'setting.json': k.setting(),
    ...k.finalen(),
  };

  var abweichungen = 0;
  for (final e in dateien.entries) {
    final pfad = '$ordner/${e.key}';
    final soll = '${const JsonEncoder.withIndent('  ').convert(e.value)}\n';
    final datei = File(pfad);
    final ist = datei.existsSync() ? datei.readAsStringSync() : null;
    if (pruefen) {
      if (ist != soll) {
        stdout.writeln('Abweichung: ${e.key}');
        abweichungen++;
      }
    } else {
      datei.parent.createSync(recursive: true);
      datei.writeAsStringSync(soll);
      stdout.writeln('geschrieben: ${e.key}');
    }
  }
  if (pruefen) {
    stdout.writeln(abweichungen == 0 ? 'Konverter: keine Abweichung (${dateien.length} Dateien)' : 'Konverter: $abweichungen Abweichungen');
    exitCode = abweichungen == 0 ? 0 : 1;
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

J _lies(String pfad) => jsonDecode(File(pfad).readAsStringSync()) as J;

List<J> _liste(Object? o) => [for (final x in (o as List)) (x as Map).cast<String, Object?>()];

String _de(Object? lt) => (lt as Map)['de'] as String;

class _Ort {
  final String id, raum, name;
  final double x, y;
  _Ort(this.id, this.raum, this.x, this.y, this.name);
  J get json => {'id': id, 'raum': raum, 'x': x, 'y': y, 'name': name};
}

class _Konverter {
  final J szenario, raeumeOverlay, figurenOverlay, luegenOverlay, fallOverlay, settingOverlay, finaleOverlay;
  _Konverter(this.szenario, this.raeumeOverlay, this.figurenOverlay, this.luegenOverlay, this.fallOverlay, this.settingOverlay, this.finaleOverlay);

  late final J _karte = (szenario['map'] as Map).cast<String, Object?>();
  late final List<String> _zeilen = [for (final z in _karte['rows'] as List) z as String];
  late final List<J> _raeume = _liste(_karte['rooms']);
  late final List<J> _props = _liste(_karte['props']);
  late final List<J> _hotspots = _liste(szenario['hotspots']);
  late final List<J> _verdaechtige = _liste(szenario['suspects']);

  String _zeichen(int x, int y) => (y < 0 || y >= _zeilen.length || x < 0 || x >= _zeilen[y].length) ? ' ' : _zeilen[y][x];

  /// Raum einer Bodenkachel, sonst null.
  String? _raumAn(int x, int y) {
    for (final r in _raeume) {
      final rx = r['x'] as int, ry = r['y'] as int, w = r['w'] as int, h = r['h'] as int;
      if (x >= rx && y >= ry && x < rx + w && y < ry + h) return r['id'] as String;
    }
    return null;
  }

  /// Blockiert ein Prop die Kachel (Möbel, nicht Dekor)?
  bool _propBlockiert(int x, int y) {
    for (final p in _props) {
      if (p['x'] == x && p['y'] == y) return propCatalog[p['type']]?.blocks ?? true;
    }
    return false;
  }

  bool _frei(int x, int y) => _zeichen(x, y) == '.' && _raumAn(x, y) != null && !_propBlockiert(x, y);

  // ---------------------------------------------------------------- Standorte

  late final List<_Ort> _orte = _baueOrte();

  List<_Ort> _baueOrte() {
    final o = (raeumeOverlay['orte'] as Map).cast<String, Object?>();
    final hs = (o['hotspots'] as Map).cast<String, Object?>();
    final vs = (o['verdaechtige'] as Map).cast<String, Object?>();
    final aus = <_Ort>[];

    _Ort mitte(String id, String name, int x, int y) {
      final raum = _raumAn(x, y);
      if (raum == null) throw StateError('Ort $id: Kachel ($x, $y) liegt in keinem Raum');
      if (!_frei(x, y)) throw StateError('Ort $id: Kachel ($x, $y) ist nicht begehbar');
      return _Ort(id, raum, x + 0.5, y + 0.5, name);
    }

    for (final h in _hotspots) {
      final m = hs[h['id']];
      if (m == null) continue;
      final id = (m as Map)['id'] as String, name = m['name'] as String;
      final x = h['x'] as int, y = h['y'] as int;
      if (_frei(x, y)) {
        aus.add(mitte(id, name, x, y));
        continue;
      }
      // Hotspot auf einem Möbel: erste freie Nachbarkachel im selben Raum (Süd, Nord, Ost, West).
      final raum = _raumAn(x, y);
      _Ort? gefunden;
      for (final (dx, dy) in [(0, 1), (0, -1), (1, 0), (-1, 0)]) {
        if (_frei(x + dx, y + dy) && _raumAn(x + dx, y + dy) == raum) {
          gefunden = mitte(id, name, x + dx, y + dy);
          break;
        }
      }
      if (gefunden == null) throw StateError('Hotspot ${h['id']}: keine freie Nachbarkachel');
      aus.add(gefunden);
    }
    for (final v in _verdaechtige) {
      final m = vs[v['id']];
      if (m == null) continue;
      aus.add(mitte((m as Map)['id'] as String, m['name'] as String, v['x'] as int, v['y'] as int));
    }
    for (final w in _liste(o['weitere'])) {
      final x = (w['x'] as num).toDouble(), y = (w['y'] as num).toDouble();
      final ort = mitte(w['id'] as String, w['name'] as String, x.floor(), y.floor());
      if ((ort.x - x).abs() > 0.01 || (ort.y - y).abs() > 0.01) throw StateError('Ort ${w['id']}: Koordinaten sind keine Kachelmitte');
      if (ort.raum != w['raum']) throw StateError('Ort ${w['id']}: liegt im Raum ${ort.raum}, nicht in ${w['raum']}');
      aus.add(ort);
    }
    final ids = <String>{};
    for (final x in aus) {
      if (!ids.add(x.id)) throw StateError('Ort ${x.id} doppelt');
    }
    return aus;
  }

  _Ort _ort(String id) => _orte.firstWhere((o) => o.id == id, orElse: () => throw StateError('unbekannter Ort $id'));

  // ------------------------------------------------------------------ Räume

  J raeume() {
    final r = (raeumeOverlay['raeume'] as Map).cast<String, Object?>();
    final breite = _zeilen.map((z) => z.length).reduce((a, b) => a > b ? a : b);
    final raeumeJson = <J>[];
    for (final x in _raeume) {
      final id = x['id'] as String;
      final m = (r[id] as Map?)?.cast<String, Object?>() ?? (throw StateError('Overlay fehlt für Raum $id'));
      raeumeJson.add({
        'id': id,
        'name': m['name'],
        'anzeigename': m['anzeigename'],
        'widthMeters': x['w'],
        'rechteck': {'x': x['x'], 'y': x['y'], 'b': x['w'], 'l': x['h']},
        'boden': x['floor'],
        'features': m['features'],
        'beschreibung': m['beschreibung'],
      });
    }
    String anzeige(String id) => (r[id] as Map)['anzeigename'] as String;

    // Türen aus den Kacheln '+' (offen) und 'L' (zu, nicht abgesperrt).
    final tuerOverlay = (raeumeOverlay['tueren'] as Map).cast<String, Object?>();
    final tueren = <J>[];
    final nachbarn = <String>{};
    final geschlossen = <String>{};
    for (var y = 0; y < _zeilen.length; y++) {
      for (var x = 0; x < _zeilen[y].length; x++) {
        final c = _zeichen(x, y);
        if (c != '+' && c != 'L') continue;
        var von = _raumAn(x - 1, y), nach = _raumAn(x + 1, y);
        if (von == null || nach == null) {
          von = _raumAn(x, y - 1);
          nach = _raumAn(x, y + 1);
        }
        if (von == null || nach == null) throw StateError('Tür ($x, $y) verbindet keine zwei Räume');
        final m = (tuerOverlay['$x,$y'] as Map?)?.cast<String, Object?>() ?? const {};
        final zu = c == 'L';
        tueren.add({
          'id': m['id'] ?? 'tuer_${x}_$y',
          'name': m['name'] ?? 'Tür zwischen ${anzeige(von)} und ${anzeige(nach)}',
          'von': von,
          'nach': nach,
          'kacheln': [
            [x, y],
          ],
          'art': m['art'] ?? 'Waggontür',
          'zustand': m['zustand'] ?? (zu ? 'zu, nicht abgesperrt' : 'offen'),
          'quietscht': m['quietscht'] ?? false,
        });
        final paar = von.compareTo(nach) <= 0 ? '$von|$nach' : '$nach|$von';
        nachbarn.add(paar);
        if (zu) geschlossen.add(paar);
      }
    }
    List<List<String>> paare(Set<String> s) => [
          for (final p in (s.toList()..sort())) p.split('|'),
        ];

    // Einrichtung aus den Props; Dekor (Läufer, Papiere) ist nicht blockierend.
    final alias = (raeumeOverlay['einrichtung'] as Map).cast<String, Object?>();
    const namen = {
      'table': 'Tisch', 'chair': 'Stuhl', 'armchair': 'Sessel', 'sofa': 'Sofa', 'bed': 'Bett', 'desk': 'Schreibtisch',
      'bookshelf': 'Bücherregal', 'cabinet': 'Schrank', 'wardrobe': 'Kleiderschrank', 'piano': 'Klavier', 'fireplace': 'Ofen',
      'plant': 'Pflanze', 'lamp': 'Lampe', 'clock': 'Uhr', 'crate': 'Kiste', 'barrel': 'Tonne', 'bathtub': 'Wanne',
      'sink': 'Spüle', 'toilet': 'Toilette', 'counter': 'Anrichte', 'stove': 'Herd', 'fridge': 'Kühlschrank', 'seat': 'Sitzbank',
      'luggage': 'Koffer', 'statue': 'Statue', 'vending': 'Automat', 'neon_sign': 'Leuchtschild', 'pool_table': 'Spieltisch',
      'bar_stool': 'Hocker', 'tv': 'Gerät', 'bush': 'Busch', 'tree': 'Baum', 'car': 'Wagen', 'candles': 'Kerzenleuchter',
      'rug': 'Läufer', 'bloodstain': 'Fleck', 'papers': 'Papiere', 'puddle': 'Pfütze',
    };
    final einrichtung = <J>[];
    for (final p in _props) {
      final x = p['x'] as int, y = p['y'] as int, typ = p['type'] as String;
      final m = (alias['$x,$y'] as Map?)?.cast<String, Object?>();
      einrichtung.add({
        'id': m?['id'] ?? '${typ}_${x}_$y',
        'name': m?['name'] ?? namen[typ] ?? typ,
        'typ': typ,
        'x': x,
        'y': y,
        'blockiert': propCatalog[typ]?.blocks ?? true,
      });
    }

    // Licht: jeder beleuchtete Raum (lit) ist ein Schutzraum mit elektrischem Licht.
    final licht = (((raeumeOverlay['lichtquellen'] as Map)['raumlicht']) as Map).cast<String, Object?>();
    final lichtquellen = <J>[
      for (final x in _raeume)
        if (x['lit'] == true)
          {
            'id': 'licht_${x['id']}',
            'art': 'elektrisch',
            'name': licht[x['id']] ?? 'Elektrisches Licht',
            'raeume': [x['id']],
            'an': [
              ['18:00', '23:59:59'],
              ['00:00', '10:00'],
            ],
          },
      ..._liste((raeumeOverlay['lichtquellen'] as Map)['weitere']),
    ];

    return {
      'generiert': _kopf,
      'settingId': _akte,
      'massstab': raeumeOverlay['massstab'],
      'raster': {'breite': breite, 'hoehe': _zeilen.length},
      'rooms': raeumeJson,
      'tueren': tueren,
      'einrichtung': einrichtung,
      'orte': [for (final o in _orte) o.json],
      'lichtquellen': lichtquellen,
      'luftzug': <Object?>[],
      'geraeusch': {
        'regel': (raeumeOverlay['geraeusch'] as Map)['regel'],
        'nachbarn': paare(nachbarn),
        'geschlossen': paare(geschlossen),
      },
    };
  }

  // ---------------------------------------------------------------- Figuren

  static String _hex(String h) => h.toUpperCase();

  J _look(Map l) => {
        'haut': l['skin'] ?? l['haut'],
        'haar': l['hair'] ?? l['haar'],
        'kopf': l['hat'] ?? l['kopf'] ?? 'none',
        'statur': l['build'] ?? l['statur'] ?? 'normal',
        'schnitt': l['outfit'] ?? l['schnitt'] ?? 'suit',
      };

  J figuren() {
    final luegen = (luegenOverlay['luegen'] as Map).cast<String, Object?>();
    final nd = (luegenOverlay['nebendelikte'] as Map).cast<String, Object?>();
    final det = (figurenOverlay['detektiv'] as Map).cast<String, Object?>();
    final opfer = (figurenOverlay['opfer'] as Map).cast<String, Object?>();
    final v = (szenario['victim'] as Map).cast<String, Object?>();

    J koord(_Ort o) => {'x': o.x, 'y': o.y};

    final detOrt = _ort(det['ort'] as String);
    final detJson = <String, Object?>{
      'id': det['id'],
      'title': det['title'],
      'selectableGenders': det['selectableGenders'],
      'colorCode': det['colorCode'],
      'farbname': det['farbname'],
      'startRoom': detOrt.raum,
      'ermittlungsOrt': detOrt.id,
      'coordinates': koord(detOrt),
      'visualSpecs': det['visualSpecs'],
      'tatnacht': det['tatnacht'],
      'auftrag': det['auftrag'],
      'nieVerdaechtig': det['nieVerdaechtig'],
      'look': det['look'],
    };

    // Opfer: Position am Leichen-Hotspot, Aussehen aus victim.look.
    final koerper = _hotspots.firstWhere((h) => h['kind'] == 'body');
    final opferOrt = _ort(opfer['ort'] as String);
    if ((koerper['x'] as int) + 0.5 != opferOrt.x || (koerper['y'] as int) + 0.5 != opferOrt.y) {
      throw StateError('Opfer-Ort liegt nicht am Leichen-Hotspot ${koerper['id']}');
    }
    final vlook = (v['look'] as Map).cast<String, Object?>();
    final opferJson = <String, Object?>{
      'id': opfer['id'],
      'name': opfer['name'],
      'age': opfer['age'],
      'geschlecht': opfer['geschlecht'],
      'roleTitle': opfer['roleTitle'],
      'isNpc': opfer['isNpc'],
      'colorCode': _hex(vlook['coat'] as String),
      'farbname': opfer['farbname'],
      'startRoom': opferOrt.raum,
      'ermittlungsOrt': opferOrt.id,
      'coordinates': koord(opferOrt),
      'status': opfer['status'],
      'visualSpecs': opfer['visualSpecs'],
      'motiveAndConflict': opfer['motiveAndConflict'],
      'warmeSeite': opfer['warmeSeite'],
      'erinnerung': opfer['erinnerung'],
      'look': _look(vlook),
    };

    final liste = <J>[];
    for (final f in _liste(figurenOverlay['figuren'])) {
      final id = f['id'] as String;
      final quelle = f['quelle'] as String?;
      String farbe;
      J look;
      _Ort ort;
      if (quelle != null) {
        final s = _verdaechtige.firstWhere((x) => 'suspect:${x['id']}' == quelle, orElse: () => throw StateError('Quelle $quelle unbekannt'));
        final sl = (s['look'] as Map).cast<String, Object?>();
        farbe = _hex(sl['coat'] as String);
        look = _look(sl);
        final vo = (((raeumeOverlay['orte'] as Map)['verdaechtige'] as Map)[s['id']] as Map)['id'] as String;
        ort = _ort(vo);
      } else {
        farbe = _hex(f['colorCode'] as String);
        look = _look((f['look'] as Map).cast<String, Object?>());
        ort = _ort(f['ort'] as String);
      }
      final platz = f['besetzungsplatz'];
      final ndKey = f['nebendelikt'] as String?;
      final j = <String, Object?>{
        'id': id,
        'name': f['name'],
        'vollerName': f['vollerName'],
        'aussprache': f['aussprache'],
        'age': f['age'],
        'geschlecht': f['geschlecht'],
        'herkunft': f['herkunft'],
        'tier': f['tier'],
        'besetzungsplatz': platz,
        'minPlayers': platz,
        'roleTitle': f['roleTitle'],
        'isPotentialKiller': f['isPotentialKiller'],
        'colorCode': farbe,
        'farbname': f['farbname'],
        'startRoom': ort.raum,
        'ermittlungsOrt': ort.id,
        'coordinates': koord(ort),
        'visualSpecs': f['visualSpecs'],
        'motiveAndConflict': f['motiveAndConflict'],
        'blackoutAlibi': f['blackoutAlibi'],
        'roleSecret': f['roleSecret'],
        'persoenlichesZiel': f['persoenlichesZiel'],
        'nebendelikt': ndKey == null ? null : nd[ndKey],
        'loyalitaet': f['loyalitaet'],
        'luegen': luegen[id] ?? const <Object?>[],
        if (f['innocentProfile'] != null) 'innocentProfile': f['innocentProfile'],
        if (f['killerProfile'] != null) 'killerProfile': f['killerProfile'],
        'look': look,
        'alltag': f['alltag'],
      };
      liste.add(j);
    }
    liste.sort((a, b) => (a['besetzungsplatz'] as int).compareTo(b['besetzungsplatz'] as int));

    return {
      'generiert': _kopf,
      'settingId': _akte,
      'hinweis': figurenOverlay['hinweis'],
      'detektiv': detJson,
      'opfer': opferJson,
      'figuren': liste,
      'lookHinweis': figurenOverlay['lookHinweis'],
    };
  }

  // ------------------------------------------------------------------- Fall

  J fall() {
    final verdict = (((szenario['endings'] as Map)['verdict']) as Map).cast<String, Object?>();
    final matrix = <J>[];
    for (final e in _liste(fallOverlay['enden'])) {
      matrix.add({
        'id': e['id'],
        'name': _de((verdict[e['urteil']] as Map)['title']),
        'anklage': e['anklage'],
        'punkteVon': e['punkteVon'],
        'punkteBis': e['punkteBis'],
      });
    }
    return {
      'generiert': _kopf,
      'settingId': fallOverlay['settingId'],
      'kanonVersion': fallOverlay['kanonVersion'],
      'titel': _de(szenario['title']),
      'untertitel': _de(szenario['tagline']),
      'simulation': fallOverlay['simulation'],
      'pfade': fallOverlay['pfade'],
      'kernverdaechtige': fallOverlay['kernverdaechtige'],
      'personen': fallOverlay['personen'],
      'runden': fallOverlay['runden'],
      'finaleUhrzeit': fallOverlay['finaleUhrzeit'],
      'morgenUhrzeit': fallOverlay['morgenUhrzeit'],
      'rundendauerMinuten': fallOverlay['rundendauerMinuten'],
      'schwellen': fallOverlay['schwellen'],
      'enden': {'matrix': matrix},
      'regeln': fallOverlay['regeln'],
    };
  }

  // ---------------------------------------------------------------- Setting

  J setting() {
    final theme = (szenario['theme'] as Map).cast<String, Object?>();
    return {
      'generiert': _kopf,
      'settingId': _akte,
      'schauplatz': settingOverlay['schauplatz'],
      'anlass': settingOverlay['anlass'],
      'datum': settingOverlay['datum'],
      'essen': settingOverlay['essen'],
      'getraenke': settingOverlay['getraenke'],
      'empfang': settingOverlay['empfang'],
      'atmosphaere': settingOverlay['atmosphaere'],
      'brandschutz': settingOverlay['brandschutz'],
      'lacher': settingOverlay['lacher'],
      'ton': settingOverlay['ton'],
      'darstellung': {
        'palette': theme['palette'],
        'wetter': theme['weather'],
        'blitze': theme['lightning'],
        'tagLicht': theme['dayAmbient'],
        'nachtLicht': theme['nightAmbient'],
        'ratsraum': _karte['councilRoom'],
        'vorlage': 'content/scenarios/$_akte.json',
      },
    };
  }

  // ----------------------------------------------------------------- Finale

  Map<String, J> finalen() {
    final enden = (szenario['endings'] as Map).cast<String, Object?>();
    final verdict = (enden['verdict'] as Map).cast<String, Object?>();
    final culprit = (enden['culprit'] as Map).cast<String, Object?>();
    final rahmen = (finaleOverlay['rahmen'] as Map).cast<String, Object?>();
    final pfade = (finaleOverlay['pfade'] as Map).cast<String, Object?>();
    final waffenTexte = ((finaleOverlay['waffenTexte'] as Map?) ?? const {}).cast<String, Object?>();
    final motive = {for (final m in _liste(szenario['motives'])) m['id'] as String: _de(m['reveal'])};
    final waffen = {for (final w in _liste(szenario['weapons'])) w['id'] as String: _de(w['reveal'])};
    String urteil(String k) => _de((verdict[k] as Map)['text']);
    String epilog(String p, String k) => _de(((culprit[p] as Map)[k] as Map));
    String letzterSatz(String t) {
      final teile = RegExp(r'[^.!?]+[.!?]+').allMatches(t).map((m) => m.group(0)!.trim()).toList();
      return teile.last;
    }

    // Wahrheit des Szenarios: Die Täterfigur der Story trägt Story-Motiv und Story-Waffe; jede andere
    // Kandidatin ihr erstes Motiv. Waffen sind frei wählbar, müssen aber im Szenario vorkommen.
    final story = (szenario['story'] as Map).cast<String, Object?>();
    final aus = <String, J>{};
    for (final p in (fallOverlay['pfade'] as List).cast<String>()) {
      final o = (pfade[p] as Map).cast<String, Object?>();
      final verdaechtige = _verdaechtige.firstWhere((x) => x['id'] == p, orElse: () => throw StateError('Pfad $p ist kein Verdächtiger'));
      final soll = p == story['culprit'] ? story['motive'] : (verdaechtige['motives'] as List).first;
      if (o['motiv'] != soll) throw StateError('Pfad $p: Motiv ${o['motiv']}, das Szenario verlangt $soll');
      if (p == story['culprit'] && o['waffe'] != story['weapon']) throw StateError('Pfad $p: Waffe ${o['waffe']}, die Story verlangt ${story['weapon']}');
      if (!motive.containsKey(o['motiv']) || !waffen.containsKey(o['waffe'])) throw StateError('Pfad $p: Motiv oder Waffe unbekannt');
      final motivText = motive[o['motiv']]!;
      final waffenText = (waffenTexte[o['waffe']] as String?) ?? waffen[o['waffe']]!;
      String r(String k) => (rahmen[k] as String).replaceAll('{name}', o['name'] as String);
      String satz(List<String> teile) => teile.join(' ');
      final eintraege = <J>[
        {
          'id': 'finale.$p.ende_meister',
          'text': satz([r('meister'), o['gesteht'] as String, motivText, o['beweis'] as String, waffenText, urteil('perfect'), epilog(p, 'caught')]),
        },
        {
          'id': 'finale.$p.ende_teilerfolg',
          'text': satz([r('teilerfolg'), o['gesteht'] as String, motivText, urteil('partial'), epilog(p, 'caught')]),
        },
        {
          'id': 'finale.$p.ende_justizirrtum',
          'text': satz([r('justizirrtum'), urteil('wrong'), epilog(p, 'escaped')]),
        },
        {
          'id': 'finale.$p.ende_eskalation',
          'text': satz([r('eskalation'), letzterSatz(urteil('unsolved')), epilog(p, 'escaped')]),
        },
        {'id': 'rueckblende.$p', 'text': o['rueckblende']},
      ];
      aus['texte/erzaehler-finale-$p.json'] = {
        'generiert': _kopf,
        'settingId': _akte,
        'bereich': 'erzaehler',
        'hinweis': 'Finale im Pfad $p: finale.$p.<ende> (4) und rueckblende.$p.',
        'eintraege': eintraege,
      };
    }
    return aus;
  }
}
