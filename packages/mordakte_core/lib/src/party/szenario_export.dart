import 'dart:convert';

import '../scenario/scenario_def.dart';
import 'kanon/kanon.dart';
import 'karte.dart';

/// Baut aus dem Party-Kanon ein Szenario im Format des Mordakte-Renderers
/// (`ScenarioDef`-JSON). Grundlage ist ein vorhandenes Szenario als Vorlage,
/// damit alle Pflichtfelder gefüllt sind; Karte, Thema und Figuren kommen aus
/// dem Kanon. Spiellogik der Vorlage wird nicht benutzt: Hotspots sind die
/// Ziele der neun Entscheidungen ([PartyKarte]), Gegenstände sind leer.
///
/// [welt] ist die optionale Darstellungsschicht `content/welt/<akte>/welt.json`
/// (nur Bild, keine Spiellogik): `aussen` nennt Räume unter freiem Himmel
/// (Fassaden, Wetter), `wetter` ersetzt das Wetter der Akte, `kulisse` wählt
/// die Umgebung jenseits der Karte (`ThemeDef.backdrops`). Böden kommen aus
/// `raeume.json` (`boden`).
Map<String, dynamic> partySzenarioJson(Kanon kanon, Map<String, dynamic> vorlage, {String id = 'party_schlosskeller', Map<String, Object?>? welt}) {
  final aussen = {...((welt?['aussen'] as List?) ?? const []).cast<String>()};
  final j = jsonDecode(jsonEncode(vorlage)) as Map<String, dynamic>;
  final g = kanon.graph;
  final karte = g.karte;
  final setting = kanon.json['setting.json']!;
  final fall = kanon.fall;
  final spawnOrt = g.orte[(kanon.figurenJson['detektiv'] as Map)['ermittlungsOrt'] as String]!;

  j['id'] = id;
  j['title'] = {'de': fall['titel']};
  j['tagline'] = {'de': fall['untertitel']};
  j['synopsis'] = {'de': setting['schauplatz']};
  // Darstellung je Akte (`setting.darstellung`); fehlend: Schlosskeller-Gewölbe.
  final darstellung = ((setting['darstellung'] as Map?) ?? const {}).cast<String, Object?>();
  j['theme'] = {
    'palette': (darstellung['palette'] as Map?)?.cast<String, Object?>() ?? {
      'background': '#070608',
      'floor': '#4f4842',
      'floorAlt': '#454039',
      'wall': '#2b2521',
      'wallTop': '#4a4038',
      'trim': '#7d6242',
      'accent': '#ff9329',
      'light': '#ffc27a',
      'danger': '#b3263a',
      'text': '#f1ede4',
      'fog': '#15120f',
    },
    'weather': welt?['wetter'] ?? darstellung['wetter'] ?? 'none',
    'lightning': darstellung['blitze'] ?? false,
    'backdrop': welt?['kulisse'] ?? 'none',
    'dayAmbient': darstellung['tagLicht'] ?? 0.62,
    'nightAmbient': darstellung['nachtLicht'] ?? 0.06,
  };
  j['map'] = {
    'rows': karte.rows,
    'rooms': [
      for (final r in g.raeume.values)
        {
          'id': r.id,
          'name': {'de': r.anzeigename},
          'x': r.x,
          'y': r.y,
          'w': r.b,
          'h': r.l,
          'floor': r.boden.isEmpty ? 'stone' : r.boden,
          if (aussen.contains(r.id)) 'outdoor': true,
        },
    ],
    'props': partyProps(kanon),
    'spawn': [
      [spawnOrt.x.floor(), spawnOrt.y.floor()],
    ],
    'councilRoom': darstellung['ratsraum'] ?? 'thekensaal',
  };
  j['hotspots'] = PartyKarte(kanon).hotspotJson();
  j['items'] = <Object>[];
  final vorlageVerdaechtige = [for (final s in (vorlage['suspects'] as List)) s as Map<String, dynamic>];
  final figuren = _kartenFiguren(kanon);
  final suspects = <Map<String, dynamic>>[];
  for (var i = 0; i < figuren.length; i++) {
    final f = figuren[i];
    final ort = g.orte[f['ermittlungsOrt'] as String]!;
    // Die ersten Plätze übernehmen Kennungen der Vorlage, damit deren Querverweise gültig bleiben.
    final idVorlage = i < vorlageVerdaechtige.length ? vorlageVerdaechtige[i]['id'] as String : null;
    suspects.add({
      'id': idVorlage ?? f['id'],
      'name': {'de': f['name']},
      'role': {'de': f['roleTitle']},
      'bio': {'de': f['motiveAndConflict'] ?? ''},
      'look': renderLook(f),
      'x': ort.x.floor(),
      'y': ort.y.floor(),
      'traits': idVorlage != null ? vorlageVerdaechtige[i]['traits'] : <String, String>{},
      'candidate': f['isPotentialKiller'] == true,
      'motives': idVorlage != null ? vorlageVerdaechtige[i]['motives'] : <String>[],
      'weapons': idVorlage != null ? (vorlageVerdaechtige[i]['weapons'] ?? <String>[]) : <String>[],
      'witness': true,
      'lines': <String, Object>{},
    });
  }
  j['suspects'] = suspects;
  return j;
}

/// Möbel des Partymodus für den Renderer (F4-ORCH-06): dieselben Kacheln und
/// dieselbe Begehbarkeit wie das Kanon-Raster, aber eigene Darstellungen ohne
/// Flaschen; dazu der Ascheneimer und der umgestoßene Kerzenständer vor der
/// Vorratstür als begehbares Dekor (Kanon: gegenstaende.json).
List<Map<String, Object?>> partyProps(Kanon kanon) {
  final g = kanon.graph;
  final anStelle = {for (final e in g.einrichtung.values) (e.x, e.y): e};
  String typ(PropDef p) {
    final e = anStelle[(p.x, p.y)];
    final id = e?.id ?? '';
    if (id.startsWith('linkes_buffet') || id.startsWith('rechtes_buffet')) return 'party_buffet';
    if (p.type == 'table') return 'party_tafel';
    return switch (id) {
      'teekocher' => 'party_teekocher',
      'kaffeemaschine' => 'party_kaffee',
      'anrichte' || 'anrichte_ost' => 'party_anrichte',
      'kamin' => 'party_kamin',
      'wendeltreppe' => 'party_wendeltreppe',
      'ruestung' => 'party_ruestung',
      'jackenstaender' => 'party_jackenstaender',
      _ when id.startsWith('theke_') => 'party_theke',
      _ => p.type,
    };
  }

  // Den umgestoßenen Kerzenständer gibt es nur im Schlosskeller.
  final ks = kanon.gegenstaende.where((x) => x['id'] == 'kerzenstaender').firstOrNull;
  final ksOrt = ks == null ? null : (ks['lage'] as Map?)?['ort'] as String?;
  final liegt = ksOrt == null ? null : g.orte[ksOrt];
  final eimer = g.einrichtung['ascheneimer'];
  return [
    for (final p in g.karte.props) {'type': typ(p), 'x': p.x, 'y': p.y},
    if (eimer != null) {'type': 'party_ascheneimer', 'x': eimer.x, 'y': eimer.y},
    if (liegt != null) {'type': 'party_kerzenstaender', 'x': liegt.x.floor(), 'y': liegt.y.floor()},
  ];
}

List<Map<String, Object?>> _kartenFiguren(Kanon kanon) => [
      (kanon.figurenJson['opfer'] as Map).cast<String, Object?>(),
      ...kanon.figuren,
    ];

/// Renderer-Kennung je Kanon-Person (Opfer und Rollen). Die ersten Plätze
/// tragen Kennungen der Vorlage (siehe [partySzenarioJson]).
Map<String, String> partyNpcKennungen(Kanon kanon, Map<String, dynamic> vorlage) {
  final v = [for (final s in (vorlage['suspects'] as List)) (s as Map)['id'] as String];
  final figuren = _kartenFiguren(kanon);
  return {for (var i = 0; i < figuren.length; i++) figuren[i]['id'] as String: i < v.length ? v[i] : figuren[i]['id'] as String};
}

/// Renderer-Aussehen einer Figur aus den Kanon-Feldern (`look`), mit
/// Farbcode als Mantelfarbe.
Map<String, String> renderLook(Map<String, Object?> f) {
  final look = (f['look'] as Map?)?.cast<String, Object?>() ?? const {};
  return {
    'coat': f['colorCode'] as String,
    'skin': look['haut'] as String? ?? '#d9b08c',
    'hair': look['haar'] as String? ?? '#3b2a20',
    'hat': switch (look['kopf'] as String?) {
      null || 'detektivhut' => 'fedora',
      final k => k,
    },
    'build': look['statur'] as String? ?? 'normal',
    'outfit': look['schnitt'] as String? ?? 'suit',
    if (look['kopftuchFarbe'] != null) 'headColor': look['kopftuchFarbe'] as String,
    if (f['geschlecht'] is String) 'gender': f['geschlecht'] as String,
  };
}
