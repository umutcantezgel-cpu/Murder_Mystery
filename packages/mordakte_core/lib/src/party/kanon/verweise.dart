import '../../util/geom.dart';
import 'kanon.dart';

/// Prüft alle Querverweise des Kanons (F-01: 0 offene Verweise).
///
/// Liefert eine Liste lesbarer Befunde; leer heißt: jeder Verweis zeigt auf
/// etwas, das existiert, und jede Kennung ist eindeutig.
List<String> kanonVerweise(Kanon k) {
  final f = <String>[];
  final g = k.graph;
  final personen = k.personen.toSet();
  final raeume = g.raeume.keys.toSet();
  final orte = g.orte.keys.toSet();
  final einrichtung = g.einrichtung.keys.toSet();
  final gegenstaende = {for (final x in k.gegenstaende) x['id'] as String};
  final nebendelikte = {for (final n in (k.gegenstaendeJson['nebendelikte'] as List? ?? const [])) (n as Map)['id'] as String};
  final zeitleiste = {for (final z in k.zeitleiste) z['id'] as String};
  final luegen = <String>{};

  void eindeutig(String bereich, Iterable<String> ids) {
    final gesehen = <String>{};
    for (final id in ids) {
      if (!gesehen.add(id)) f.add('$bereich: Kennung $id doppelt');
    }
  }

  void person(String wo, Object? id) {
    if (id != null && !personen.contains(id)) f.add('$wo: unbekannte Person $id');
  }

  void ort(String wo, Object? id) {
    if (id != null && !orte.contains(id)) f.add('$wo: unbekannter Ort $id');
  }

  // Raumgraph
  eindeutig('Räume', g.raeume.keys);
  eindeutig('Orte', [for (final o in (k.json['raeume.json']!['orte'] as List)) (o as Map)['id'] as String]);
  for (final o in g.orte.values) {
    if (!raeume.contains(o.raum)) f.add('Ort ${o.id}: unbekannter Raum ${o.raum}');
    final r = g.raumAn(o.x, o.y);
    if (r?.id != o.raum) f.add('Ort ${o.id}: liegt nicht im Raum ${o.raum} (sondern ${r?.id})');
    if (!g.raster.walkable(o.x.floor(), o.y.floor())) f.add('Ort ${o.id}: nicht begehbar');
  }
  for (final t in g.tueren.values) {
    for (final r in [t.von, t.nach]) {
      if (r != 'draussen' && !raeume.contains(r)) f.add('Tür ${t.id}: unbekannter Raum $r');
    }
  }
  for (final l in g.lichtquellen.values) {
    ort('Licht ${l.id}', l.ort);
    person('Licht ${l.id}', l.traeger);
    for (final r in l.raeume) {
      if (!raeume.contains(r)) f.add('Licht ${l.id}: unbekannter Raum $r');
    }
  }
  for (final l in g.luftzug) {
    for (final r in l.weg) {
      if (!raeume.contains(r)) f.add('Luftzug: unbekannter Raum $r');
    }
  }
  for (final (a, b) in [...g.nachbarn, ...g.geschlosseneNachbarn]) {
    if (!raeume.contains(a) || !raeume.contains(b)) f.add('Geräusch: unbekanntes Raumpaar $a/$b');
  }

  // Figuren
  final alleFiguren = [
    (k.figurenJson['detektiv'] as Map).cast<String, Object?>(),
    (k.figurenJson['opfer'] as Map).cast<String, Object?>(),
    ...k.figuren,
  ];
  eindeutig('Figuren', [for (final x in alleFiguren) x['id'] as String]);
  eindeutig('Besetzungsplätze', [for (final x in k.figuren) '${x['besetzungsplatz']}']);
  for (final x in alleFiguren) {
    final id = x['id'];
    final eo = x['ermittlungsOrt'] as String?;
    ort('Figur $id', eo);
    if (!raeume.contains(x['startRoom'])) f.add('Figur $id: unbekannter Startraum ${x['startRoom']}');
    final o = eo == null ? null : g.orte[eo];
    if (o != null) {
      if (o.raum != x['startRoom']) f.add('Figur $id: Ermittlungsort $eo liegt nicht im Startraum ${x['startRoom']}');
      final c = x['coordinates'] as Map?;
      if (c != null && dist((c['x'] as num).toDouble(), (c['y'] as num).toDouble(), o.x, o.y) > 0.01) {
        f.add('Figur $id: Koordinaten passen nicht zum Ermittlungsort $eo');
      }
    }
    final loy = x['loyalitaet'] as Map?;
    if (loy != null) person('Figur $id (Loyalität)', loy['zu']);
    final nd = x['nebendelikt'] as Map?;
    if (nd != null && !nebendelikte.contains(nd['id'])) f.add('Figur $id: unbekanntes Nebendelikt ${nd['id']}');
    if (x['minPlayers'] != null && x['minPlayers'] != x['besetzungsplatz']) f.add('Figur $id: minPlayers ≠ Besetzungsplatz');
    for (final l in (x['luegen'] as List? ?? const [])) {
      if (!luegen.add((l as Map)['id'] as String)) f.add('Lüge ${l['id']} doppelt');
    }
  }
  for (final p in k.kernverdaechtige) {
    final x = k.figur(p);
    if (x == null || x['isPotentialKiller'] != true) f.add('Fall: Kernverdächtige $p ist keine mögliche Täterfigur');
  }
  for (final x in k.figuren) {
    if (x['isPotentialKiller'] == true && !k.kernverdaechtige.contains(x['id'])) f.add('Figur ${x['id']}: möglicher Täter, aber nicht im Fall');
  }

  // Setting
  for (final l in (k.json['setting.json']!['lacher'] as List? ?? const [])) {
    final m = l as Map;
    person('Lacher ${m['id']}', m['wer']);
    ort('Lacher ${m['id']}', m['ort']);
  }

  // Zeitleiste
  eindeutig('Zeitleiste', [for (final z in k.zeitleiste) z['id'] as String]);
  for (final z in k.zeitleiste) {
    ort('Zeitleiste ${z['id']}', z['ort']);
    for (final w in (z['wer'] as List)) {
      if (w != 'alle') person('Zeitleiste ${z['id']}', w);
    }
  }

  // Gegenstände
  eindeutig('Gegenstände', gegenstaende);
  final spurIds = <String>[];
  void lage(String wo, Map? l) {
    if (l == null) return;
    ort(wo, l['ort']);
    person(wo, l['traeger']);
    if (l['einrichtung'] != null && !einrichtung.contains(l['einrichtung'])) f.add('$wo: unbekannte Einrichtung ${l['einrichtung']}');
  }

  for (final x in k.gegenstaende) {
    final id = x['id'];
    lage('Gegenstand $id', x['lage'] as Map?);
    final versteck = x['versteckJePfad'] as Map?;
    if (versteck != null) {
      for (final p in k.pfade) {
        if (versteck[p] == null) f.add('Gegenstand $id: Versteck für Pfad $p fehlt');
        lage('Gegenstand $id ($p)', versteck[p] as Map?);
      }
    }
    for (final s in (x['spuren'] as List? ?? const [])) {
      final m = s as Map;
      spurIds.add(m['id'] as String);
      if (m['nebendelikt'] != null && !nebendelikte.contains(m['nebendelikt'])) f.add('Spur ${m['id']}: unbekanntes Nebendelikt ${m['nebendelikt']}');
      for (final b in (m['belastet'] as List? ?? const [])) {
        person('Spur ${m['id']}', b);
      }
      for (final l in (m['widerlegt'] as List? ?? const [])) {
        if (!luegen.contains(l)) f.add('Spur ${m['id']}: unbekannte Lüge $l');
      }
      final e = m['entstehtWenn'] as Map;
      final gegriffen = e['kerzenstaenderGegriffenVon'];
      if (gegriffen != null && !k.kernverdaechtige.contains(gegriffen)) f.add('Spur ${m['id']}: $gegriffen ist keine Kernperson');
      final endet = e['bundEndetBei'];
      if (endet != null && !orte.contains(endet) && !einrichtung.contains(endet)) f.add('Spur ${m['id']}: unbekanntes Versteck $endet');
      for (final r in ((m['rolle'] as Map?) ?? const {}).keys) {
        if (r != 'alle' && !k.pfade.contains(r)) f.add('Spur ${m['id']}: unbekannter Pfad $r in rolle');
      }
      final harmlos = m['harmlos'];
      if (e['immer'] != true && (harmlos == null || (harmlos as String).isEmpty)) f.add('Spur ${m['id']}: pfadabhängig ohne harmlose Fassung');
    }
  }
  eindeutig('Spuren', spurIds);
  for (final n in (k.gegenstaendeJson['nebendelikte'] as List? ?? const [])) {
    person('Nebendelikt ${(n as Map)['id']}', n['person']);
  }

  // Beobachtungen
  eindeutig('Beobachtungen', [for (final b in k.beobachtungen) b['id'] as String]);
  final ereignisIds = <String>{};
  final matrixPfade = [for (final p in ['basis', ...k.pfade]) if (k.json.containsKey('tatmatrix/$p.json')) p];
  for (final p in matrixPfade) {
    for (final e in (k.json['tatmatrix/$p.json']!['ereignisse'] as List? ?? const [])) {
      ereignisIds.add((e as Map)['id'] as String);
    }
  }
  for (final b in k.beobachtungen) {
    final id = b['id'];
    person('Beobachtung $id', b['wer']);
    for (final feld in ['belastet', 'entlastet']) {
      for (final p in (b[feld] as List? ?? const [])) {
        person('Beobachtung $id ($feld)', p);
      }
    }
    for (final l in (b['widerlegt'] as List? ?? const [])) {
      if (!luegen.contains(l)) f.add('Beobachtung $id: unbekannte Lüge $l');
    }
    final beleg = b['beleg'] as Map;
    for (final z in (beleg['zeitleiste'] as List? ?? const [])) {
      if (!zeitleiste.contains(z)) f.add('Beobachtung $id: unbekannter Zeitleisten-Eintrag $z');
    }
    for (final x in (beleg['gegenstand'] as List? ?? const [])) {
      if (!gegenstaende.contains(x)) f.add('Beobachtung $id: unbekannter Gegenstand $x');
    }
    for (final e in (beleg['ereignis'] as List? ?? const [])) {
      if (!ereignisIds.contains(e)) f.add('Beobachtung $id: unbekanntes Ereignis $e');
    }
    final muster = [
      ...(beleg['alle'] as List? ?? const []),
      ...(beleg['keine'] as List? ?? const []),
      ...(beleg['reihenfolge'] as List? ?? const []),
    ];
    for (final m in muster) {
      final q = (m as Map)['quelle'] as String;
      final teil = q.contains(':') ? q.split(':').last : q;
      if (teil.endsWith('*')) continue;
      if (!personen.contains(teil) && !ereignisIds.contains(teil)) f.add('Beobachtung $id: Quelle $q unbekannt');
    }
    final auf = beleg['aufenthalt'] as Map?;
    if (auf != null) {
      person('Beobachtung $id', auf['person']);
      ort('Beobachtung $id', auf['ort']);
    }
  }

  // Tatmatrix (nur Akten mit Simulation)
  for (final p in matrixPfade) {
    final j = k.json['tatmatrix/$p.json']!;
    if (p != 'basis' && j['pfad'] != p) f.add('Tatmatrix $p: Feld pfad ist ${j['pfad']}');
    for (final e in (j['plaene'] as Map).entries) {
      person('Tatmatrix $p', e.key);
      for (final s in e.value as List) {
        final m = s as Map;
        ort('Tatmatrix $p/${e.key}', m['ort']);
        ort('Tatmatrix $p/${e.key}', m['nach']);
        for (final u in (m['ueber'] as List? ?? const [])) {
          ort('Tatmatrix $p/${e.key}', u);
        }
        if (m['licht'] != null && !g.lichtquellen.containsKey(m['licht'])) f.add('Tatmatrix $p/${e.key}: unbekanntes Licht ${m['licht']}');
      }
    }
    for (final e in (j['ereignisse'] as List? ?? const [])) {
      final m = e as Map;
      ort('Tatmatrix $p/${m['id']}', m['ort']);
      person('Tatmatrix $p/${m['id']}', m['person']);
      person('Tatmatrix $p/${m['id']}', m['ziel']);
      if (m['tuer'] != null && !g.tueren.containsKey(m['tuer'])) f.add('Tatmatrix $p/${m['id']}: unbekannte Tür ${m['tuer']}');
    }
    for (final x in (j['gegenstaende'] as List? ?? const [])) {
      final m = x as Map;
      if (!gegenstaende.contains(m['id'])) f.add('Tatmatrix $p: unbekannter Gegenstand ${m['id']}');
      for (final s in m['spur'] as List) {
        lage('Tatmatrix $p/${m['id']}', s as Map);
      }
    }
  }
  // Entscheidungen (E-024)
  final spuren = <String>{
    for (final x in k.gegenstaende)
      for (final sp in (x['spuren'] as List? ?? const [])) (sp as Map)['id'] as String,
  };
  final beobachtungen = {for (final b in k.beobachtungen) b['id'] as String};
  final ej = k.entscheidungenJson;
  final faktIds = <String>[for (final x in ej['fakten'] as List) (x as Map)['id'] as String];
  eindeutig('Fakten', faktIds);
  for (final x in ej['fakten'] as List) {
    final m = x as Map;
    final q = m['quelle'] as Map;
    if (q['beobachtung'] != null && !beobachtungen.contains(q['beobachtung'])) f.add('Fakt ${m['id']}: unbekannte Beobachtung ${q['beobachtung']}');
    if (q['spur'] != null && !spuren.contains(q['spur'])) f.add('Fakt ${m['id']}: unbekannte Spur ${q['spur']}');
    for (final p in m['personen'] as List) {
      person('Fakt ${m['id']}', p);
    }
  }
  final optionIds = <String>[];
  for (final x in ej['entscheidungen'] as List) {
    final e = x as Map;
    final eigene = <String>{};
    for (final o in e['optionen'] as List) {
      final m = o as Map;
      optionIds.add(m['id'] as String);
      eigene.add(m['id'] as String);
      for (final fa in m['fakten'] as List) {
        if (!faktIds.contains(fa)) f.add('Option ${m['id']}: unbekannter Fakt $fa');
      }
      final z = m['ziel'] as Map;
      person('Option ${m['id']}', z['person']);
      if (z['gegenstand'] != null && !gegenstaende.contains(z['gegenstand'])) f.add('Option ${m['id']}: unbekannter Gegenstand ${z['gegenstand']}');
      if (z['raum'] != null && !raeume.contains(z['raum'])) f.add('Option ${m['id']}: unbekannter Raum ${z['raum']}');
      ort('Option ${m['id']}', z['ort']);
    }
    for (final r in (e['richtig'] as Map).entries) {
      if (!k.pfade.contains(r.key)) f.add('Entscheidung ${e['id']}: unbekannter Pfad ${r.key}');
      if (!eigene.contains(r.value)) f.add('Entscheidung ${e['id']}: richtige Option ${r.value} gehört nicht dazu');
    }
  }
  eindeutig('Entscheidungen', [for (final x in ej['entscheidungen'] as List) (x as Map)['id'] as String]);
  eindeutig('Optionen', optionIds);

  // Bonus-Hinweise
  eindeutig('Hinweise', [for (final h in k.bonusJson['hinweise'] as List) (h as Map)['id'] as String]);
  for (final h in k.bonusJson['hinweise'] as List) {
    final m = h as Map;
    person('Hinweis ${m['id']}', (m['wirkung'] as Map)['person']);
    for (final q in (m['quelle'] as List? ?? const [])) {
      final t = (q as String).split(':');
      final ok = switch (t[0]) {
        'beobachtung' => beobachtungen.contains(t[1]),
        'zeitleiste' => zeitleiste.contains(t[1]),
        'spur' => spuren.contains(t[1]),
        _ => false,
      };
      if (!ok) f.add('Hinweis ${m['id']}: unbekannte Quelle $q');
    }
    for (final o in (m['widerlegtDurch'] as List? ?? const [])) {
      if (!optionIds.contains(o)) f.add('Hinweis ${m['id']}: unbekannte Option $o');
    }
  }

  // Gruppenwahl
  eindeutig('Gruppenwahl', [for (final w in k.gruppenwahlJson['wahlen'] as List) (w as Map)['id'] as String]);
  for (final w in k.gruppenwahlJson['wahlen'] as List) {
    final m = w as Map;
    person('Gruppenwahl ${m['id']}', m['rolle']);
    for (final teil in ['a', 'b', 'bTaeter']) {
      final o = m[teil] as Map?;
      if (o == null) continue;
      for (final kn in [o['kosten'] as Map, o['nutzen'] as Map]) {
        final b = kn['bezug'];
        if (b == null || b == 'persoenlichesZiel') continue;
        if (!personen.contains(b) && !nebendelikte.contains(b)) f.add('Gruppenwahl ${m['id']}.$teil: unbekannter Bezug $b');
      }
    }
  }

  // Besetzung: Ersatzpartner
  for (final e in ((k.besetzungJson['ersatzpartner'] as Map?) ?? const {}).entries) {
    person('Ersatzpartner', e.key);
    for (final r in e.value as List) {
      person('Ersatzpartner ${e.key}', r);
    }
  }

  // Alte Namen (vor der Namensbalance) kommen in keinem Kanon-Text mehr vor.
  final alteNamen = <String>{
    for (final x in k.figuren)
      if (x['quelle'] is Map) ((x['quelle'] as Map)['name'] as String),
  };
  void texte(String datei, Object? o, String pfad) {
    if (o is Map) {
      for (final e in o.entries) {
        if (e.key == 'quelle') continue;
        texte(datei, e.value, '$pfad.${e.key}');
      }
    } else if (o is List) {
      for (var i = 0; i < o.length; i++) {
        texte(datei, o[i], '$pfad[$i]');
      }
    } else if (o is String) {
      for (final n in alteNamen) {
        if (RegExp('\\b$n\\b').hasMatch(o)) f.add('$datei$pfad: alter Name „$n“');
      }
    }
  }

  for (final e in k.json.entries) {
    texte(e.key, e.value, '');
  }
  return f;
}
