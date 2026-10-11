// Konverter der klassischen Echtzeit-Akte „Blue Palm Motel“ in ein Akten-Bündel
// im Party-Kanonformat (content/party/blue_palm/).
//
// Eingabe: content/scenarios/blue_palm.json (unverändert) und das Autoren-Overlay
// content/party/blue_palm/_autor/*.json (Namen, Texte, Figuren). Der Konverter
// erzeugt deterministisch vier Dateien mit Kopffeld "generiert": "akte_klassik":
//
// - raeume.json  mechanisch aus der Karte: Räume (x/y/b/l), Türen aus '+' und 'L',
//                Möbel aus den Props, Orte aus Hotspots und Standorten der Figuren,
//                Lichtquellen aus den hellen Räumen
// - figuren.json Aussehen, Farben und Standorte aus den Verdächtigen; Texte aus dem Overlay
// - setting.json Texte aus dem Overlay, Darstellung (Palette, Wetter) aus dem Thema
// - fall.json    Titel und Untertitel aus dem Szenario; der Rest aus dem Overlay
//
// Alle anderen Dateien des Bündels (Gegenstände, Beobachtungen, Entscheidungen,
// Texte …) sind von Hand verfasst und werden nicht erzeugt.
//
// Aufruf (im Repo-Wurzelordner oder im Paketordner):
//   dart run bin/akte_klassik_blue_palm.dart            schreibt die Dateien
//   dart run bin/akte_klassik_blue_palm.dart --pruefen  meldet Abweichungen (Exit 1), schreibt nichts
import 'dart:convert';
import 'dart:io';

const _kopf = 'akte_klassik';
const _akte = 'blue_palm';

/// Möbel, die man betreten kann (Dekor); alles andere blockiert (wie propCatalog).
const _dekor = {'rug', 'bloodstain', 'papers', 'puddle'};

const _typNamen = {
  'table': 'Tisch',
  'chair': 'Stuhl',
  'armchair': 'Sessel',
  'sofa': 'Sofa',
  'bed': 'Bett',
  'desk': 'Schreibtisch',
  'bookshelf': 'Regal',
  'cabinet': 'Schrank',
  'wardrobe': 'Kleiderschrank',
  'piano': 'Klavier',
  'fireplace': 'Kamin',
  'plant': 'Zimmerpflanze',
  'lamp': 'Stehlampe',
  'clock': 'Standuhr',
  'crate': 'Kiste',
  'barrel': 'Tonne',
  'bathtub': 'Badewanne',
  'sink': 'Waschbecken',
  'toilet': 'Toilette',
  'counter': 'Theke',
  'stove': 'Herd',
  'fridge': 'Kühlschrank',
  'seat': 'Sitz',
  'luggage': 'Koffer',
  'statue': 'Statue',
  'vending': 'Automat',
  'neon_sign': 'Neonschild',
  'pool_table': 'Billardtisch',
  'bar_stool': 'Hocker',
  'tv': 'Fernseher',
  'bush': 'Busch',
  'tree': 'Palme',
  'car': 'Auto',
  'candles': 'Kerzen',
  'rug': 'Teppich',
  'bloodstain': 'Fleck',
  'papers': 'Papiere',
  'puddle': 'Pfütze',
};

Map<String, Object?> _lies(String pfad) => (jsonDecode(File(pfad).readAsStringSync()) as Map).cast<String, Object?>();

String _json(Map<String, Object?> j) => '${const JsonEncoder.withIndent('  ').convert(j)}\n';

String _wurzel() {
  var d = Directory.current;
  while (!File('${d.path}/content/scenarios/blue_palm.json').existsSync()) {
    final p = d.parent;
    if (p.path == d.path) throw StateError('Repo-Wurzel mit content/scenarios/blue_palm.json nicht gefunden');
    d = p;
  }
  return d.path;
}

void main(List<String> args) {
  final pruefen = args.contains('--pruefen');
  final wurzel = _wurzel();
  final szenario = _lies('$wurzel/content/scenarios/blue_palm.json');
  final ordner = '$wurzel/content/party/$_akte';
  final raumAutor = _lies('$ordner/_autor/raeume.json');
  final figAutor = _lies('$ordner/_autor/figuren.json');
  final settingAutor = _lies('$ordner/_autor/setting.json');
  final fallAutor = _lies('$ordner/_autor/fall.json');
  final settingId = fallAutor['settingId'] as String;

  final karte = _Karte(szenario, raumAutor, figAutor);
  final dateien = <String, Map<String, Object?>>{
    'raeume.json': karte.raeumeJson(settingId),
    'figuren.json': karte.figurenJson(settingId, figAutor),
    'setting.json': _setting(szenario, settingAutor, settingId),
    'fall.json': _fall(szenario, fallAutor, settingId),
  };

  var abweichungen = 0;
  for (final e in dateien.entries) {
    final neu = _json(e.value);
    final datei = File('$ordner/${e.key}');
    final alt = datei.existsSync() ? datei.readAsStringSync() : null;
    if (pruefen) {
      if (alt != neu) {
        stdout.writeln('Abweichung: ${e.key} weicht vom Konverter ab');
        abweichungen++;
      }
    } else if (alt != neu) {
      datei.writeAsStringSync(neu);
      stdout.writeln('geschrieben: content/party/$_akte/${e.key}');
    } else {
      stdout.writeln('unverändert: content/party/$_akte/${e.key}');
    }
  }
  if (pruefen) {
    stdout.writeln(abweichungen == 0 ? 'Konverter: Bündel stimmt (4 Dateien)' : 'Konverter: $abweichungen Abweichungen');
    exitCode = abweichungen == 0 ? 0 : 1;
  }
}

Map<String, Object?> _setting(Map<String, Object?> sz, Map<String, Object?> autor, String settingId) {
  final theme = (sz['theme'] as Map).cast<String, Object?>();
  final karte = (sz['map'] as Map).cast<String, Object?>();
  return {
    'generiert': _kopf,
    'settingId': settingId,
    for (final e in autor.entries)
      if (e.key != 'settingId' && e.key != 'darstellung') e.key: e.value,
    'darstellung': {
      'palette': (theme['palette'] as Map).cast<String, Object?>(),
      'wetter': theme['weather'],
      'blitze': theme['lightning'],
      'tagLicht': theme['dayAmbient'],
      'nachtLicht': theme['nightAmbient'],
      'ratsraum': karte['councilRoom'],
      'vorlage': 'content/scenarios/$_akte.json',
    },
  };
}

Map<String, Object?> _fall(Map<String, Object?> sz, Map<String, Object?> autor, String settingId) {
  String de(Object? t) => ((t as Map)['de'] as String);
  final kandidaten = [
    for (final s in sz['suspects'] as List)
      if ((s as Map)['candidate'] == true) s['id'] as String,
  ];
  var untertitel = de(sz['tagline']);
  if (untertitel.endsWith('.')) untertitel = untertitel.substring(0, untertitel.length - 1);
  return {
    'generiert': _kopf,
    'settingId': settingId,
    'kanonVersion': autor['kanonVersion'],
    'titel': de(sz['title']),
    'untertitel': untertitel,
    'pfade': kandidaten,
    'kernverdaechtige': kandidaten,
    for (final e in autor.entries)
      if (!const {'settingId', 'kanonVersion', 'titel', 'untertitel', 'pfade', 'kernverdaechtige'}.contains(e.key)) e.key: e.value,
  };
}

/// Ein Standort auf einer begehbaren Kachel.
class _Ort {
  final String id, name, raum;
  final int x, y;
  _Ort(this.id, this.name, this.raum, this.x, this.y);

  Map<String, Object?> toJson() => {'id': id, 'raum': raum, 'x': x + 0.5, 'y': y + 0.5, 'name': name};
}

class _Tuer {
  final String von, nach;
  final String zeichen;
  final List<List<int>> kacheln = [];
  _Tuer(this.von, this.nach, this.zeichen);
  String get id => '${von}_$nach';
}

class _Karte {
  final Map<String, Object?> sz;
  final Map<String, Object?> raumAutor;
  final Map<String, Object?> figAutor;
  late final List<String> rows = [for (final r in (sz['map'] as Map)['rows'] as List) r as String];
  late final int breite = rows.first.length;
  late final int hoehe = rows.length;
  late final List<Map<String, Object?>> raeume = [for (final r in (sz['map'] as Map)['rooms'] as List) (r as Map).cast<String, Object?>()];
  late final List<Map<String, Object?>> props = [for (final p in (sz['map'] as Map)['props'] as List) (p as Map).cast<String, Object?>()];
  late final Map<String, Map<String, Object?>> propAn = {for (final p in props) '${p['x']},${p['y']}': p};
  late final List<Map<String, Object?>> hotspots = [for (final h in sz['hotspots'] as List) (h as Map).cast<String, Object?>()];
  late final Map<String, Map<String, Object?>> verdaechtige = {
    for (final s in sz['suspects'] as List) (s as Map)['id'] as String: s.cast<String, Object?>(),
  };

  _Karte(this.sz, this.raumAutor, this.figAutor) {
    _orteBauen();
    _tuerenBauen();
  }

  String? raumAn(int x, int y) {
    for (final r in raeume) {
      final rx = r['x'] as int, ry = r['y'] as int, w = r['w'] as int, h = r['h'] as int;
      if (x >= rx && y >= ry && x < rx + w && y < ry + h) return r['id'] as String;
    }
    return null;
  }

  bool _blockiert(int x, int y) {
    final p = propAn['$x,$y'];
    return p != null && !_dekor.contains(p['type']);
  }

  /// Begehbare Kachel in einem Raum (Boden ohne blockierendes Möbel).
  bool frei(int x, int y) {
    if (x < 0 || y < 0 || x >= breite || y >= hoehe) return false;
    return rows[y][x] == '.' && raumAn(x, y) != null && !_blockiert(x, y);
  }

  /// Stehplatz für ein Ziel: die Kachel selbst oder die nächste freie Nachbarkachel im selben Raum.
  (int, int) stehplatz(int x, int y, String wer) {
    if (frei(x, y)) return (x, y);
    final raum = raumAn(x, y);
    for (final d in const [(0, 1), (0, -1), (1, 0), (-1, 0)]) {
      final nx = x + d.$1, ny = y + d.$2;
      if (frei(nx, ny) && raumAn(nx, ny) == raum) return (nx, ny);
    }
    throw StateError('$wer: keine begehbare Kachel bei $x,$y');
  }

  final List<_Ort> orte = [];
  final Map<String, _Ort> orteNachId = {};
  final Map<String, _Ort> hotspotOrt = {};
  final Map<String, _Ort> personOrt = {};

  void _ort(_Ort o) {
    if (orteNachId.containsKey(o.id)) throw StateError('Ort ${o.id} doppelt');
    if (!frei(o.x, o.y)) throw StateError('Ort ${o.id}: Kachel ${o.x},${o.y} nicht begehbar');
    orte.add(o);
    orteNachId[o.id] = o;
  }

  void _orteBauen() {
    final namen = (raumAutor['orte'] as Map).cast<String, Object?>();
    for (final h in hotspots) {
      final id = h['id'] as String;
      final n = (namen[id] as Map?)?.cast<String, Object?>() ?? (throw StateError('Overlay: Ort für Hotspot $id fehlt'));
      final (x, y) = stehplatz(h['x'] as int, h['y'] as int, id);
      final o = _Ort(n['id'] as String, n['name'] as String, raumAn(x, y)!, x, y);
      _ort(o);
      hotspotOrt[id] = o;
    }
    for (final e in (raumAutor['orteExtra'] as List? ?? const [])) {
      final m = (e as Map).cast<String, Object?>();
      final x = m['x'] as int, y = m['y'] as int;
      _ort(_Ort(m['id'] as String, m['name'] as String, raumAn(x, y) ?? (throw StateError('Ort ${m['id']} liegt in keinem Raum')), x, y));
    }
    // Standorte der Figuren (Detektiv, Rollen). Das Opfer liegt beim Hotspot des Toten.
    final detektiv = (figAutor['detektiv'] as Map).cast<String, Object?>();
    final dOrt = (detektiv['ort'] as Map).cast<String, Object?>();
    final spawn = ((sz['map'] as Map)['spawn'] as List)[dOrt['spawn'] as int] as List;
    _person('detective', dOrt, spawn[0] as int, spawn[1] as int);
    for (final f in figAutor['figuren'] as List) {
      final m = (f as Map).cast<String, Object?>();
      final s = verdaechtige[m['szenario']];
      final x = s != null ? s['x'] as int : m['x'] as int;
      final y = s != null ? s['y'] as int : m['y'] as int;
      _person(m['id'] as String, (m['ort'] as Map).cast<String, Object?>(), x, y);
    }
  }

  void _person(String id, Map<String, Object?> ort, int x, int y) {
    final o = _Ort(ort['id'] as String, ort['name'] as String, raumAn(x, y) ?? (throw StateError('$id steht in keinem Raum')), x, y);
    _ort(o);
    personOrt[id] = o;
  }

  final Map<String, _Tuer> tueren = {};

  void _tuerenBauen() {
    for (var y = 0; y < hoehe; y++) {
      for (var x = 0; x < breite; x++) {
        final c = rows[y][x];
        if (c != '+' && c != 'L') continue;
        String? von, nach;
        final n = raumAn(x, y - 1), s = raumAn(x, y + 1), w = raumAn(x - 1, y), e = raumAn(x + 1, y);
        if (n != null && s != null && n != s) {
          von = n;
          nach = s;
        } else if (w != null && e != null && w != e) {
          von = w;
          nach = e;
        } else {
          throw StateError('Tür bei $x,$y verbindet keine zwei Räume');
        }
        final t = tueren.putIfAbsent('${von}_$nach', () => _Tuer(von!, nach!, c));
        t.kacheln.add([x, y]);
      }
    }
  }

  Map<String, Object?> raeumeJson(String settingId) {
    final ra = (raumAutor['raeume'] as Map).cast<String, Object?>();
    final ta = (raumAutor['tueren'] as Map).cast<String, Object?>();
    final ea = (raumAutor['einrichtung'] as Map).cast<String, Object?>();
    final la = (raumAutor['lichtquellen'] as Map).cast<String, Object?>();
    final ids = <String>{};

    final rooms = <Map<String, Object?>>[];
    for (final r in raeume) {
      final id = r['id'] as String;
      final a = (ra[id] as Map?)?.cast<String, Object?>() ?? (throw StateError('Overlay: Raum $id fehlt'));
      final name = (r['name'] as Map)['de'] as String;
      rooms.add({
        'id': id,
        'name': name,
        'anzeigename': a['anzeigename'] ?? name,
        'widthMeters': r['w'],
        'rechteck': {'x': r['x'], 'y': r['y'], 'b': r['w'], 'l': r['h']},
        'boden': r['floor'],
        'features': a['features'],
        'beschreibung': a['beschreibung'],
      });
    }

    final tueren = <Map<String, Object?>>[];
    for (final t in this.tueren.values) {
      final a = (ta[t.id] as Map?)?.cast<String, Object?>() ?? (throw StateError('Overlay: Tür ${t.id} fehlt'));
      tueren.add({
        'id': t.id,
        'name': a['name'],
        'von': t.von,
        'nach': t.nach,
        'kacheln': t.kacheln,
        'art': a['art'],
        'zustand': a['zustand'],
        'quietscht': a['quietscht'],
      });
    }

    final einrichtung = <Map<String, Object?>>[];
    for (final p in props) {
      final typ = p['type'] as String;
      final x = p['x'] as int, y = p['y'] as int;
      final a = (ea['$x,$y'] as Map?)?.cast<String, Object?>();
      final id = a?['id'] as String? ?? '${typ}_${x}_$y';
      if (!ids.add(id)) throw StateError('Möbel $id doppelt');
      einrichtung.add({
        'id': id,
        'name': a?['name'] ?? _typNamen[typ] ?? typ,
        'typ': typ,
        'x': x,
        'y': y,
        'blockiert': !_dekor.contains(typ),
      });
    }
    for (final k in ea.keys) {
      if (!propAn.containsKey(k)) throw StateError('Overlay: Möbel bei $k gibt es im Szenario nicht');
    }

    final lichtquellen = <Map<String, Object?>>[];
    for (final r in raeume) {
      if (r['lit'] != true) continue;
      final a = (la[r['id']] as Map?)?.cast<String, Object?>() ?? (throw StateError('Overlay: Licht für ${r['id']} fehlt'));
      lichtquellen.add({
        'id': a['id'],
        'art': a['art'],
        'name': a['name'],
        'raeume': [r['id']],
        'an': a['an'],
        'hinweis': a['hinweis'],
      });
    }

    final nachbarn = [
      for (final t in this.tueren.values) [t.von, t.nach],
    ];
    final geraeusch = (raumAutor['geraeusch'] as Map).cast<String, Object?>();

    return {
      'generiert': _kopf,
      'settingId': settingId,
      'massstab': raumAutor['massstab'],
      'raster': {'breite': breite, 'hoehe': hoehe},
      'rooms': rooms,
      'tueren': tueren,
      'einrichtung': einrichtung,
      'orte': [for (final o in orte) o.toJson()],
      'lichtquellen': lichtquellen,
      'luftzug': <Object?>[],
      'geraeusch': {'regel': geraeusch['regel'], 'nachbarn': nachbarn, 'geschlossen': <Object?>[]},
    };
  }

  Map<String, Object?> _look(Map<String, Object?> s) {
    final l = (s['look'] as Map).cast<String, Object?>();
    return {
      'haut': l['skin'],
      'haar': l['hair'],
      'kopf': l['hat'],
      'statur': l['build'],
      'schnitt': l['outfit'] ?? 'suit',
      if (l['headColor'] != null) 'kopftuchFarbe': l['headColor'],
    };
  }

  Map<String, Object?> figurenJson(String settingId, Map<String, Object?> autor) {
    final d = (autor['detektiv'] as Map).cast<String, Object?>();
    final dOrt = personOrt['detective']!;
    final detektiv = <String, Object?>{
      'id': d['id'],
      'title': d['title'],
      'selectableGenders': d['selectableGenders'],
      'colorCode': d['colorCode'],
      'farbname': d['farbname'],
      'startRoom': dOrt.raum,
      'ermittlungsOrt': dOrt.id,
      'coordinates': {'x': dOrt.x + 0.5, 'y': dOrt.y + 0.5},
      'visualSpecs': d['visualSpecs'],
      'tatnacht': d['tatnacht'],
      'auftrag': d['auftrag'],
      'nieVerdaechtig': true,
      'look': d['look'],
    };

    final o = (autor['opfer'] as Map).cast<String, Object?>();
    final victim = (sz['victim'] as Map).cast<String, Object?>();
    final body = hotspotOrt[victim['hotspot']]!;
    final vl = (victim['look'] as Map).cast<String, Object?>();
    final opfer = <String, Object?>{
      'id': o['id'],
      'name': o['name'],
      'age': o['age'],
      'geschlecht': o['geschlecht'],
      'roleTitle': o['roleTitle'],
      'isNpc': true,
      'colorCode': vl['coat'],
      'farbname': o['farbname'],
      'startRoom': body.raum,
      'ermittlungsOrt': body.id,
      'coordinates': {'x': body.x + 0.5, 'y': body.y + 0.5},
      'status': o['status'],
      'visualSpecs': o['visualSpecs'],
      'motiveAndConflict': o['motiveAndConflict'],
      'warmeSeite': o['warmeSeite'],
      'erinnerung': o['erinnerung'],
      'look': {
        'haut': vl['skin'],
        'haar': vl['hair'],
        'kopf': vl['hat'],
        'statur': vl['build'],
        'schnitt': vl['outfit'] ?? 'suit',
      },
    };

    final figuren = <Map<String, Object?>>[];
    for (final f in autor['figuren'] as List) {
      final m = (f as Map).cast<String, Object?>();
      final s = verdaechtige[m['szenario']];
      final ort = personOrt[m['id']]!;
      figuren.add({
        'id': m['id'],
        'name': m['name'],
        'vollerName': m['vollerName'],
        'aussprache': m['aussprache'],
        'age': m['age'],
        'geschlecht': m['geschlecht'],
        'herkunft': m['herkunft'],
        'tier': m['tier'],
        'besetzungsplatz': m['besetzungsplatz'],
        'minPlayers': m['besetzungsplatz'],
        'roleTitle': m['roleTitle'],
        'isPotentialKiller': s != null ? s['candidate'] == true : false,
        'colorCode': s != null ? (s['look'] as Map)['coat'] : m['colorCode'],
        'farbname': m['farbname'],
        'startRoom': ort.raum,
        'ermittlungsOrt': ort.id,
        'coordinates': {'x': ort.x + 0.5, 'y': ort.y + 0.5},
        'visualSpecs': m['visualSpecs'],
        'motiveAndConflict': m['motiveAndConflict'],
        'blackoutAlibi': m['blackoutAlibi'],
        'roleSecret': m['roleSecret'],
        'persoenlichesZiel': m['persoenlichesZiel'],
        'nebendelikt': m['nebendelikt'],
        'loyalitaet': m['loyalitaet'],
        'luegen': m['luegen'],
        if (m['innocentProfile'] != null) 'innocentProfile': m['innocentProfile'],
        if (m['killerProfile'] != null) 'killerProfile': m['killerProfile'],
        'look': s != null ? _look(s) : m['look'],
        'alltag': m['alltag'],
      });
    }

    return {
      'generiert': _kopf,
      'settingId': settingId,
      'hinweis': autor['hinweis'],
      'lookHinweis': autor['lookHinweis'],
      'detektiv': detektiv,
      'opfer': opfer,
      'figuren': figuren,
    };
  }
}
