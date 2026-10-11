// Konverter der Akte Ravensmoor (M5): Das klassische Szenario wird mechanisch zu den Kanon-Dateien
// raeume.json, figuren.json, setting.json und fall.json. Alles, was das Szenario nicht kennt
// (Namen, Texte, Zusatzorte, Rollen ohne Szenario-Figur), kommt aus dem Autoren-Overlay
// `content/party/ravensmoor/_autor/*.json`. Die Ausgabe ist deterministisch; jede erzeugte Datei
// trägt in der Kopfzeile `"generiert": "akte_klassik"`.
//
//   dart run bin/akte_klassik_ravensmoor.dart            schreibt die vier Dateien
//   dart run bin/akte_klassik_ravensmoor.dart --pruefen  vergleicht nur (Drift); Exitcode 1 bei Abweichung
//
// Quellen (unverändert, A-002): content/scenarios/ravensmoor.json.
// Ziel: content/party/ravensmoor/{raeume,figuren,setting,fall}.json.
import 'dart:convert';
import 'dart:io';

import 'package:mordakte_core/mordakte_core.dart';

const _akte = 'ravensmoor';
const _marke = 'akte_klassik';

typedef _Json = Map<String, Object?>;

String _wurzel() {
  var d = Directory.current;
  while (!Directory('${d.path}/content/party').existsSync()) {
    final p = d.parent;
    if (p.path == d.path) throw StateError('content/party nicht gefunden');
    d = p;
  }
  return d.path;
}

_Json _lies(String pfad) => (jsonDecode(File(pfad).readAsStringSync()) as Map).cast<String, Object?>();

List<T> _liste<T>(Object? o) => [for (final x in (o as List? ?? const [])) x as T];

_Json _karte(Object? o) => ((o as Map?) ?? const {}).cast<String, Object?>();

/// Ein Raum des Szenarios (Kachelrechteck).
class _Raum {
  final String id, name, boden;
  final int x, y, b, l;
  final bool hell, aussen;
  const _Raum(this.id, this.name, this.boden, this.x, this.y, this.b, this.l, this.hell, this.aussen);

  bool enthaelt(int tx, int ty) => tx >= x && ty >= y && tx < x + b && ty < y + l;
}

class _Quelle {
  final List<String> rows;
  final List<_Raum> raeume;
  final List<({String typ, int x, int y})> props;
  final List<_Json> hotspots;
  final List<_Json> verdaechtige;
  final _Json szenario;

  _Quelle(this.szenario)
      : rows = _liste<String>(_karte(szenario['map'])['rows']),
        raeume = [
          for (final r in _liste<Map>(_karte(szenario['map'])['rooms']))
            _Raum(
              r['id'] as String,
              (r['name'] as Map)['de'] as String,
              r['floor'] as String,
              r['x'] as int,
              r['y'] as int,
              r['w'] as int,
              r['h'] as int,
              r['lit'] == true,
              r['outdoor'] == true,
            ),
        ],
        props = [
          for (final p in _liste<Map>(_karte(szenario['map'])['props'])) (typ: p['type'] as String, x: p['x'] as int, y: p['y'] as int),
        ],
        hotspots = [for (final h in _liste<Map>(szenario['hotspots'])) h.cast<String, Object?>()],
        verdaechtige = [for (final s in _liste<Map>(szenario['suspects'])) s.cast<String, Object?>()];

  _Raum? raumAn(int x, int y) {
    for (final r in raeume) {
      if (r.enthaelt(x, y)) return r;
    }
    return null;
  }

  String zeichen(int x, int y) => y < 0 || y >= rows.length || x < 0 || x >= rows[y].length ? ' ' : rows[y][x];

  bool blockiertProp(int x, int y) {
    for (final p in props) {
      if (p.x == x && p.y == y && (propCatalog[p.typ]?.blocks ?? true)) return true;
    }
    return false;
  }

  /// Begehbar: im Raum und nicht von einem blockierenden Möbel besetzt (Türkacheln gehören keinem Raum).
  bool begehbar(int x, int y) => raumAn(x, y) != null && zeichen(x, y) == '.' && !blockiertProp(x, y);

  /// Nächste begehbare Kachel im selben Raum (Breitensuche, feste Richtungsfolge Nord, Ost, Süd, West).
  (int, int) freiNahe(int x, int y) {
    if (begehbar(x, y)) return (x, y);
    final raum = raumAn(x, y) ?? (throw StateError('Hotspot ($x,$y) liegt in keinem Raum'));
    final warte = <(int, int)>[(x, y)];
    final gesehen = <(int, int)>{(x, y)};
    const rich = [(0, -1), (1, 0), (0, 1), (-1, 0)];
    for (var i = 0; i < warte.length; i++) {
      final (cx, cy) = warte[i];
      for (final (dx, dy) in rich) {
        final n = (cx + dx, cy + dy);
        if (gesehen.contains(n) || !raum.enthaelt(n.$1, n.$2)) continue;
        if (begehbar(n.$1, n.$2)) return n;
        gesehen.add(n);
        warte.add(n);
      }
    }
    throw StateError('Keine begehbare Kachel bei ($x,$y)');
  }
}

/// Fester Schlüsselsatz für deterministische Ausgabe (Reihenfolge wie hier eingefügt).
String _json(_Json j) => '${const JsonEncoder.withIndent('  ').convert(j)}\n';

_Json _kopf([String? hinweis]) => {'generiert': _marke, 'settingId': _akte, 'hinweis': ?hinweis};

// ---------------------------------------------------------------------------------------------
// raeume.json
// ---------------------------------------------------------------------------------------------

class _Raeume {
  final _Json json;
  final Map<String, ({String raum, double x, double y, String name})> orte;
  _Raeume(this.json, this.orte);
}

_Raeume _baueRaeume(_Quelle q, _Json overlay, _Json figurOverlay) {
  final raumInfo = _karte(overlay['raeume']);
  final namen = _karte(overlay['einrichtungNamen']);
  final sonder = _karte(overlay['einrichtungSonder']);
  final tuerInfo = _karte(overlay['tueren']);
  final hotspotOrte = _karte(overlay['hotspotOrte']);
  final figurOrte = _karte(overlay['figurOrte']);

  final breite = q.rows.fold<int>(0, (m, r) => r.length > m ? r.length : m);
  final hoehe = q.rows.length;

  final rooms = <_Json>[
    for (final r in q.raeume)
      {
        'id': r.id,
        'name': r.name,
        'anzeigename': _karte(raumInfo[r.id])['anzeigename'] ?? r.name,
        'widthMeters': r.b,
        'rechteck': {'x': r.x, 'y': r.y, 'b': r.b, 'l': r.l},
        'boden': r.boden,
        'features': _liste<String>(_karte(raumInfo[r.id])['features']),
        'beschreibung': _karte(raumInfo[r.id])['beschreibung'] as String,
      },
  ];

  // Türen: jede Kachel `+` oder `L` zwischen zwei Räumen.
  final tueren = <_Json>[];
  final nachbarn = <String>{};
  for (var y = 0; y < q.rows.length; y++) {
    for (var x = 0; x < q.rows[y].length; x++) {
      final c = q.rows[y][x];
      if (c != '+' && c != 'L') continue;
      var von = q.raumAn(x - 1, y), nach = q.raumAn(x + 1, y);
      if (von == null || nach == null || von.id == nach.id) {
        von = q.raumAn(x, y - 1);
        nach = q.raumAn(x, y + 1);
      }
      if (von == null || nach == null || von.id == nach.id) throw StateError('Tür ($x,$y) verbindet keine zwei Räume');
      final id = 'tuer_${von.id}_${nach.id}';
      final info = _karte(tuerInfo[id]);
      if (info.isEmpty) throw StateError('Overlay: Tür $id fehlt in tueren');
      final zustand = info['zustand'] as String;
      tueren.add({
        'id': id,
        'name': info['name'],
        'von': von.id,
        'nach': nach.id,
        'kacheln': [
          [x, y],
        ],
        'art': info['art'],
        'zustand': zustand,
        'quietscht': info['quietscht'] == true,
      });
      if (!zustand.startsWith('verschlossen')) {
        final a = von.id, b = nach.id;
        nachbarn.add(a.compareTo(b) <= 0 ? '$a|$b' : '$b|$a');
      }
    }
  }

  // Einrichtung: jedes Prop der Karte. `blockiert` heißt hier: steht auf der Karte; ob es den Weg
  // sperrt, entscheidet der Prop-Katalog (Teppiche und Pfützen sind begehbar).
  final einrichtung = <_Json>[
    for (final p in q.props)
      {
        'id': '${p.typ}_${p.x}_${p.y}',
        'name': (sonder['${p.x},${p.y}'] ?? namen[p.typ] ?? (throw StateError('Overlay: kein Name für ${p.typ}'))) as String,
        'typ': p.typ,
        'x': p.x,
        'y': p.y,
        'blockiert': true,
      },
  ];

  // Orte: Hotspots (auf eine begehbare Kachel gerückt), Figuren, Zusatzorte.
  final orte = <String, ({String raum, double x, double y, String name})>{};
  final ortJson = <_Json>[];
  void ort(String id, String name, int tx, int ty) {
    final r = q.raumAn(tx, ty) ?? (throw StateError('Ort $id liegt in keinem Raum'));
    if (!q.begehbar(tx, ty)) throw StateError('Ort $id ($tx,$ty) ist nicht begehbar');
    if (orte.containsKey(id)) {
      final alt = orte[id]!;
      if (alt.x != tx + 0.5 || alt.y != ty + 0.5) throw StateError('Ort $id doppelt mit anderer Lage');
      return;
    }
    orte[id] = (raum: r.id, x: tx + 0.5, y: ty + 0.5, name: name);
    ortJson.add({'id': id, 'raum': r.id, 'x': tx + 0.5, 'y': ty + 0.5, 'name': name});
  }

  for (final h in q.hotspots) {
    final info = _liste<String>(hotspotOrte[h['id']]);
    if (info.length != 2) throw StateError('Overlay: Ort für Hotspot ${h['id']} fehlt');
    final (tx, ty) = q.freiNahe(h['x'] as int, h['y'] as int);
    ort(info[0], info[1], tx, ty);
  }
  for (final z in _liste<Map>(overlay['zusatzOrte'])) {
    ort(z['id'] as String, z['name'] as String, z['x'] as int, z['y'] as int);
  }
  // Figuren stehen auf ihrer Szenario-Kachel; neue Rollen auf der Kachel aus dem Overlay.
  final positionen = _figurPositionen(q, figurOverlay, overlay);
  for (final e in positionen.entries) {
    final info = _liste<String>(figurOrte[e.key]);
    if (info.length != 2) throw StateError('Overlay: Ort für Figur ${e.key} fehlt');
    ort(info[0], info[1], e.value.$1, e.value.$2);
  }

  // Licht: helle Räume des Szenarios plus Zusatzquellen.
  final licht = <_Json>[];
  final lit = _karte(overlay['lichtLitRaeume']);
  for (final r in q.raeume.where((r) => r.hell)) {
    final i = _karte(lit[r.id]);
    if (i.isEmpty) throw StateError('Overlay: Licht für hellen Raum ${r.id} fehlt');
    licht.add({
      'id': 'licht_${r.id}',
      'art': i['art'],
      'name': i['name'],
      'raeume': [r.id],
      'an': i['an'],
      'hinweis': i['hinweis'],
    });
  }
  for (final l in _liste<Map>(overlay['lichtZusatz'])) {
    final m = l.cast<String, Object?>();
    licht.add({
      'id': m['id'],
      'art': m['art'],
      'name': m['name'],
      if (m['raeume'] != null) 'raeume': m['raeume'],
      if (m['ort'] != null) 'ort': m['ort'],
      if (m['farbe'] != null) 'farbe': m['farbe'],
      if (m['radius'] != null) 'radius': m['radius'],
      if (m['flackern'] != null) 'flackern': m['flackern'],
      'an': m['an'],
      'hinweis': m['hinweis'],
    });
  }

  final paare = nachbarn.toList()..sort();
  final json = <String, Object?>{
    ..._kopf(),
    'massstab': overlay['massstab'],
    'raster': {'breite': breite, 'hoehe': hoehe},
    'rooms': rooms,
    'tueren': tueren,
    'einrichtung': einrichtung,
    'orte': ortJson,
    'lichtquellen': licht,
    'luftzug': <Object>[],
    'geraeusch': {
      'regel': _karte(overlay['geraeusch'])['regel'],
      'nachbarn': [for (final p in paare) p.split('|')],
      'geschlossen': <Object>[],
    },
  };
  return _Raeume(json, orte);
}

/// Kachel je Figur-Kennung: Szenario-Verdächtige, Rollen aus `positionNeu`, Detektiv und Opfer.
Map<String, (int, int)> _figurPositionen(_Quelle q, _Json figurOverlay, _Json raeumeOverlay) {
  final out = <String, (int, int)>{};
  final neu = _karte(figurOverlay['positionNeu']);
  for (final f in _liste<Map>(figurOverlay['figuren'])) {
    final id = f['id'] as String;
    final s = q.verdaechtige.where((v) => v['id'] == id).firstOrNull;
    if (s != null) {
      out[id] = (s['x'] as int, s['y'] as int);
    } else {
      final n = _karte(neu[id]);
      if (n.isEmpty) throw StateError('Overlay: Position für Rolle $id fehlt');
      out[id] = (n['x'] as int, n['y'] as int);
    }
  }
  final platz = _karte(raeumeOverlay['detektivPlatz']);
  out['detective'] = (platz['x'] as int, platz['y'] as int);
  final opfer = q.hotspots.firstWhere((h) => h['kind'] == 'body');
  out['edmund'] = (opfer['x'] as int, opfer['y'] as int);
  return out;
}

// ---------------------------------------------------------------------------------------------
// figuren.json
// ---------------------------------------------------------------------------------------------

_Json _baueFiguren(_Quelle q, _Json overlay, _Raeume raeume, _Json raeumeOverlay) {
  final positionen = _figurPositionen(q, overlay, raeumeOverlay);
  final figurOrte = _karte(raeumeOverlay['figurOrte']);

  _Json standort(String id) {
    final (tx, ty) = positionen[id]!;
    final ortId = _liste<String>(figurOrte[id])[0];
    final o = raeume.orte[ortId]!;
    return {
      'startRoom': o.raum,
      'ermittlungsOrt': ortId,
      'coordinates': {'x': tx + 0.5, 'y': ty + 0.5},
    };
  }

  final detektiv = _karte(overlay['detektiv']);
  final detektivJson = <String, Object?>{
    'id': detektiv['id'],
    'title': detektiv['title'],
    'selectableGenders': detektiv['selectableGenders'],
    'colorCode': detektiv['colorCode'],
    'farbname': detektiv['farbname'],
    ...standort('detective'),
    'visualSpecs': detektiv['visualSpecs'],
    'tatnacht': detektiv['tatnacht'],
    'auftrag': detektiv['auftrag'],
    'nieVerdaechtig': detektiv['nieVerdaechtig'],
    'look': detektiv['look'],
  };

  final opfer = _karte(overlay['opfer']);
  final v = _karte(q.szenario['victim']);
  final opferJson = <String, Object?>{
    'id': opfer['id'],
    'name': (v['name'] as Map)['de'],
    'age': opfer['age'],
    'geschlecht': opfer['geschlecht'],
    'roleTitle': opfer['roleTitle'],
    'isNpc': opfer['isNpc'],
    'colorCode': opfer['colorCode'],
    'farbname': opfer['farbname'],
    ...standort('edmund'),
    'status': opfer['status'],
    'visualSpecs': opfer['visualSpecs'],
    'motiveAndConflict': opfer['motiveAndConflict'],
    'warmeSeite': opfer['warmeSeite'],
    'erinnerung': opfer['erinnerung'],
    'schluesselbund': opfer['schluesselbund'],
    'gedaechtnisLueckeAb': opfer['gedaechtnisLueckeAb'],
    'look': opfer['look'],
    'schluesselbundMaterial': opfer['schluesselbundMaterial'],
  };

  final figuren = <_Json>[];
  for (final f in (_liste<Map>(overlay['figuren']).map((m) => m.cast<String, Object?>()).toList()
    ..sort((a, b) => (a['besetzungsplatz'] as int).compareTo(b['besetzungsplatz'] as int)))) {
    final id = f['id'] as String;
    final s = q.verdaechtige.where((x) => x['id'] == id).firstOrNull;
    final platz = f['besetzungsplatz'] as int;
    final farbe = (f['colorCode'] ?? ((s?['look'] as Map?)?['coat'])) as String?;
    if (farbe == null) throw StateError('Rolle $id: keine Farbe');
    figuren.add({
      'id': id,
      'name': f['name'],
      'vollerName': s == null ? f['vollerName'] : (s['name'] as Map)['de'],
      'aussprache': f['aussprache'],
      'age': f['age'],
      'geschlecht': f['geschlecht'],
      'herkunft': f['herkunft'],
      'tier': f['tier'],
      'besetzungsplatz': platz,
      'minPlayers': platz,
      'roleTitle': s == null ? f['roleTitle'] : (s['role'] as Map)['de'],
      'isPotentialKiller': f['isPotentialKiller'],
      'colorCode': farbe.toUpperCase(),
      'farbname': f['farbname'],
      ...standort(id),
      'visualSpecs': f['visualSpecs'],
      'motiveAndConflict': f['motiveAndConflict'] ?? s?['bio'],
      'blackoutAlibi': f['blackoutAlibi'],
      'roleSecret': f['roleSecret'],
      'persoenlichesZiel': f['persoenlichesZiel'],
      'nebendelikt': f['nebendelikt'],
      'loyalitaet': f['loyalitaet'],
      'luegen': f['luegen'],
      if (f['innocentProfile'] != null) 'innocentProfile': f['innocentProfile'],
      if (f['killerProfile'] != null) 'killerProfile': f['killerProfile'],
      'look': f['look'],
      'alltag': f['alltag'],
    });
  }

  return {
    ..._kopf(overlay['hinweis'] as String),
    'lookHinweis': overlay['lookHinweis'],
    'detektiv': detektivJson,
    'opfer': opferJson,
    'figuren': figuren,
  };
}

// ---------------------------------------------------------------------------------------------
// setting.json, fall.json
// ---------------------------------------------------------------------------------------------

_Json _baueSetting(_Quelle q, _Json overlay) {
  final theme = _karte(q.szenario['theme']);
  final map = _karte(q.szenario['map']);
  return {
    ..._kopf(),
    'schauplatz': overlay['schauplatz'],
    'anlass': overlay['anlass'],
    'datum': overlay['datum'],
    'essen': overlay['essen'],
    'getraenke': overlay['getraenke'],
    'empfang': overlay['empfang'],
    'atmosphaere': overlay['atmosphaere'],
    'brandschutz': overlay['brandschutz'],
    'ton': overlay['ton'],
    'darstellung': {
      'palette': theme['palette'],
      'wetter': theme['weather'],
      'blitze': theme['lightning'],
      'tagLicht': theme['dayAmbient'],
      'nachtLicht': theme['nightAmbient'],
      'ratsraum': map['councilRoom'],
      'vorlage': 'content/scenarios/${q.szenario['id']}.json',
    },
  };
}

_Json _baueFall(_Quelle q, _Json overlay) => {
      ..._kopf(),
      'kanonVersion': overlay['kanonVersion'],
      'simulation': overlay['simulation'],
      'titel': (q.szenario['title'] as Map)['de'],
      'untertitel': (q.szenario['tagline'] as Map)['de'],
      'pfade': overlay['pfade'],
      'kernverdaechtige': overlay['kernverdaechtige'],
      'personen': overlay['personen'],
      'runden': overlay['runden'],
      'finaleUhrzeit': overlay['finaleUhrzeit'],
      'morgenUhrzeit': overlay['morgenUhrzeit'],
      'rundendauerMinuten': overlay['rundendauerMinuten'],
      'schwellen': overlay['schwellen'],
      'enden': overlay['enden'],
      'regeln': overlay['regeln'],
    };

// ---------------------------------------------------------------------------------------------

void main(List<String> args) {
  final wurzel = _wurzel();
  final ziel = '$wurzel/content/party/$_akte';
  final szenario = _lies('$wurzel/content/scenarios/$_akte.json');
  final q = _Quelle(szenario);

  final raeumeOverlay = _lies('$ziel/_autor/raeume.json');
  final figurOverlay = _lies('$ziel/_autor/figuren.json');
  final settingOverlay = _lies('$ziel/_autor/setting.json');
  final fallOverlay = _lies('$ziel/_autor/fall.json');

  final raeume = _baueRaeume(q, raeumeOverlay, figurOverlay);
  final ausgabe = <String, String>{
    'fall.json': _json(_baueFall(q, fallOverlay)),
    'setting.json': _json(_baueSetting(q, settingOverlay)),
    'raeume.json': _json(raeume.json),
    'figuren.json': _json(_baueFiguren(q, figurOverlay, raeume, raeumeOverlay)),
  };

  final pruefen = args.contains('--pruefen');
  var abweichungen = 0;
  for (final e in ausgabe.entries) {
    final datei = File('$ziel/${e.key}');
    final alt = datei.existsSync() ? datei.readAsStringSync() : null;
    if (pruefen) {
      if (alt != e.value) {
        stdout.writeln('Abweichung: ${e.key}');
        abweichungen++;
      }
    } else if (alt != e.value) {
      datei.writeAsStringSync(e.value);
      stdout.writeln('geschrieben: content/party/$_akte/${e.key}');
    }
  }
  if (pruefen) {
    stdout.writeln(abweichungen == 0 ? 'Konverter: bündelgleich (${ausgabe.length} Dateien)' : 'Konverter: $abweichungen Dateien weichen ab');
    exitCode = abweichungen == 0 ? 0 : 1;
  } else {
    stdout.writeln('Konverter: ${ausgabe.length} Dateien erzeugt');
  }
}
