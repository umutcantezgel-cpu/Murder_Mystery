import 'dart:collection';

import '../engine/case_generator.dart';
import '../model/rules.dart';
import '../util/geom.dart';
import 'catalog.dart';
import 'grid.dart';
import 'scenario_def.dart';

/// Ergebnis der Szenario-Prüfung.
class ValidationReport {
  final List<String> errors = [];
  final List<String> warnings = [];
  bool get ok => errors.isEmpty;
}

/// Prüft ein Szenario auf Format-, Karten- und Lösbarkeitsfehler.
ValidationReport validateScenario(ScenarioDef s) {
  final r = ValidationReport();
  void err(String m) => r.errors.add(m);
  void warn(String m) => r.warnings.add(m);

  // --- Theme
  for (final k in ThemeDef.paletteKeys) {
    final v = s.theme.palette[k];
    if (v == null || !RegExp(r'^#[0-9a-fA-F]{6}$').hasMatch(v)) err('theme.palette.$k fehlt/ungültig');
  }
  if (!ThemeDef.weathers.contains(s.theme.weather)) err('theme.weather ungültig: ${s.theme.weather}');
  if (!ThemeDef.backdrops.contains(s.theme.backdrop)) err('theme.backdrop ungültig: ${s.theme.backdrop}');

  // --- Karte
  final m = s.map;
  if (m.rows.isEmpty) err('map.rows leer');
  final w = m.width;
  for (var y = 0; y < m.rows.length; y++) {
    if (m.rows[y].length != w) err('map.rows[$y] hat Länge ${m.rows[y].length}, erwartet $w');
    for (final ch in m.rows[y].split('')) {
      if (!const ['#', 'W', '.', '+', 'L', ' '].contains(ch)) err('map.rows[$y]: unbekanntes Zeichen "$ch"');
    }
  }
  if (w > 30 || m.height > 30) err('Karte größer als 30×30 ($w×${m.height})');
  final grid = TileGrid(m);
  final lockedDoors = <Pt>[];
  for (var y = 0; y < m.height; y++) {
    for (var x = 0; x < w; x++) {
      if (m.charAt(x, y) == TileChar.lockedDoor) lockedDoors.add(Pt(x, y));
    }
  }
  grid.setOpenDoors(lockedDoors);

  final roomIds = <String>{};
  final owner = <Pt, String>{};
  for (final room in m.rooms) {
    if (!roomIds.add(room.id)) err('Raum-ID doppelt: ${room.id}');
    if (!floorStyles.contains(room.floor)) err('Raum ${room.id}: Bodenstil ${room.floor} unbekannt');
    for (var y = room.y; y < room.y + room.h; y++) {
      for (var x = room.x; x < room.x + room.w; x++) {
        final c = m.charAt(x, y);
        if (c != TileChar.floor) err('Raum ${room.id}: Kachel ($x,$y) ist "$c", nicht Boden');
        final prev = owner[Pt(x, y)];
        if (prev != null) err('Räume ${room.id} und $prev überlappen bei ($x,$y)');
        owner[Pt(x, y)] = room.id;
      }
    }
  }
  final council = m.roomById[m.councilRoom];
  if (council == null) {
    err('councilRoom ${m.councilRoom} existiert nicht');
  } else if (!council.lit) {
    warn('councilRoom ${council.id} sollte lit sein');
  }
  if (!m.rooms.any((x) => x.lit)) warn('kein lit-Raum (Schutzraum)');

  for (final p in m.props) {
    if (!propCatalog.containsKey(p.type)) err('Prop-Typ unbekannt: ${p.type} bei (${p.x},${p.y})');
    if (m.charAt(p.x, p.y) != TileChar.floor) err('Prop ${p.type} bei (${p.x},${p.y}) liegt nicht auf Boden');
  }
  final propTiles = <Pt>{};
  for (final p in m.props) {
    if (!propTiles.add(Pt(p.x, p.y))) err('Zwei Props auf (${p.x},${p.y})');
  }

  if (m.spawn.isEmpty) err('map.spawn leer');
  for (final sp in m.spawn) {
    if (!grid.walkable(sp.x, sp.y)) err('Spawn $sp nicht begehbar');
    if (council != null && m.roomAt(sp.x, sp.y)?.id != council.id) warn('Spawn $sp liegt nicht im councilRoom');
  }
  if (m.spawn.length < 6) warn('weniger als 6 Spawn-Punkte');

  // Erreichbarkeit
  final reach = <Pt>{};
  if (m.spawn.isNotEmpty && grid.walkable(m.spawn.first.x, m.spawn.first.y)) {
    final q = Queue<Pt>()..add(m.spawn.first);
    reach.add(m.spawn.first);
    while (q.isNotEmpty) {
      final c = q.removeFirst();
      for (final d in const [(1, 0), (-1, 0), (0, 1), (0, -1)]) {
        final n = Pt(c.x + d.$1, c.y + d.$2);
        if (!reach.contains(n) && grid.walkable(n.x, n.y)) {
          reach.add(n);
          q.add(n);
        }
      }
    }
  }
  var unreachable = 0;
  final examples = <Pt>[];
  for (var y = 0; y < m.height; y++) {
    for (var x = 0; x < w; x++) {
      if (grid.walkable(x, y) && !reach.contains(Pt(x, y))) {
        unreachable++;
        if (examples.length < 5) examples.add(Pt(x, y));
      }
    }
  }
  if (unreachable > 0) err('$unreachable begehbare Kacheln nicht vom Spawn erreichbar, z. B. ${examples.join(' ')}');
  for (var y = 0; y < m.height; y++) {
    for (var x = 0; x < w; x++) {
      if (!grid.isDoor(x, y)) continue;
      final ns = grid.walkable(x, y - 1) && grid.walkable(x, y + 1);
      final ew = grid.walkable(x - 1, y) && grid.walkable(x + 1, y);
      if (!ns && !ew) err('Tür ($x,$y) ist nicht auf beiden Seiten begehbar (Prop/Wand im Weg?)');
    }
  }

  bool usable(int x, int y) {
    if (reach.contains(Pt(x, y))) return true;
    for (final d in const [(1, 0), (-1, 0), (0, 1), (0, -1), (1, 1), (1, -1), (-1, 1), (-1, -1)]) {
      if (reach.contains(Pt(x + d.$1, y + d.$2))) return true;
    }
    return false;
  }

  bool freeTile(int x, int y) => reach.contains(Pt(x, y));

  // --- Spuren
  final leadIds = <String>{};
  final unlockedByLead = <String>{};
  if (s.chapters.length != 3) err('Es müssen genau 3 Kapitel sein (${s.chapters.length})');
  for (var i = 0; i < s.chapters.length; i++) {
    final ch = s.chapters[i];
    if (i == s.chapters.length - 1 && ch.leads.isNotEmpty) err('Letztes Kapitel darf keine Spuren haben');
    if (i < s.chapters.length - 1 && ch.leads.where((l) => !l.hidden).length < 2) {
      warn('Kapitel ${i + 1}: weniger als 2 sichtbare Spuren');
    }
    for (final l in ch.leads) {
      if (!leadIds.add(l.id)) err('Spur-ID doppelt: ${l.id}');
      for (final h in l.unlock.hotspots) {
        if (!s.hotspotById.containsKey(h)) err('Spur ${l.id}: Hotspot $h unbekannt');
        unlockedByLead.add(h);
      }
      for (final d in l.unlock.doors) {
        if (m.charAt(d.x, d.y) != TileChar.lockedDoor) err('Spur ${l.id}: Tür $d ist keine L-Tür');
      }
      for (final it in l.unlock.items) {
        if (!s.itemById.containsKey(it)) err('Spur ${l.id}: Item $it unbekannt');
      }
      if (l.requiresClue != null && !s.clueById.containsKey(l.requiresClue)) {
        err('Spur ${l.id}: requiresClue ${l.requiresClue} unbekannt');
      }
    }
  }
  for (final d in lockedDoors) {
    if (!s.leadById.values.any((l) => l.unlock.doors.contains(d))) warn('L-Tür $d wird von keiner Spur geöffnet');
  }

  // --- Hotspots
  final hsIds = <String>{};
  for (final h in s.hotspots) {
    if (!hsIds.add(h.id)) err('Hotspot-ID doppelt: ${h.id}');
    if (!HotspotKind.all.contains(h.kind)) err('Hotspot ${h.id}: kind ${h.kind} unbekannt');
    if (!m.charAt(h.x, h.y).contains(RegExp(r'[.+]'))) err('Hotspot ${h.id} liegt nicht auf Boden');
    if (!usable(h.x, h.y)) err('Hotspot ${h.id} (${h.x},${h.y}) nicht erreichbar');
    final lead = h.requires.lead;
    if (lead != null && !leadIds.contains(lead)) err('Hotspot ${h.id}: Spur $lead unbekannt');
    if (lead != null && !unlockedByLead.contains(h.id)) warn('Hotspot ${h.id} braucht Spur $lead, steht aber in keiner unlock.hotspots-Liste');
    final cls = h.requires.cls;
    if (cls != null && !detectiveClasses.containsKey(cls)) err('Hotspot ${h.id}: Klasse $cls unbekannt');
    if (h.fromChapter < 1 || h.fromChapter > 3) err('Hotspot ${h.id}: fromChapter ungültig');
  }
  final bodies = s.hotspots.where((h) => h.kind == HotspotKind.body).toList();
  if (bodies.length != 1) err('Genau 1 body-Hotspot nötig (${bodies.length})');
  if (s.hotspotById[s.victim.hotspot]?.kind != HotspotKind.body) err('victim.hotspot muss der body-Hotspot sein');
  for (final b in bodies) {
    if (!freeTile(b.x, b.y)) err('Leiche ${b.id} muss auf einer freien, erreichbaren Kachel liegen');
  }
  final labs = s.hotspots.where((h) => h.kind == HotspotKind.lab).length;
  if (labs != 1) err('Genau 1 lab-Hotspot nötig ($labs)');
  if (s.hotspots.where((h) => h.kind == HotspotKind.hide).length < 2) warn('weniger als 2 Verstecke');

  // --- Items
  for (final it in s.items) {
    if (!ItemType.all.contains(it.type)) err('Item ${it.id}: Typ ${it.type} unbekannt');
    if (!freeTile(it.x, it.y)) err('Item ${it.id} (${it.x},${it.y}) liegt nicht auf freier, erreichbarer Kachel');
    if (it.chapter < 1 || it.chapter > 3) err('Item ${it.id}: chapter ungültig');
  }

  // --- Merkmale & Verdächtige
  for (final t in s.traits.values) {
    if (t.values.length < 2) err('Merkmal ${t.id} braucht ≥2 Werte');
  }
  final susIds = <String>{};
  for (final sus in s.suspects) {
    if (!susIds.add(sus.id)) err('Verdächtigen-ID doppelt: ${sus.id}');
    if (!freeTile(sus.x, sus.y)) err('Verdächtige ${sus.id} (${sus.x},${sus.y}) steht nicht auf freier, erreichbarer Kachel');
    for (final t in s.traits.keys) {
      final v = sus.traits[t];
      if (v == null || !s.traits[t]!.values.containsKey(v)) err('Verdächtige ${sus.id}: Merkmal $t fehlt/ungültig ($v)');
    }
    for (final mo in sus.motives) {
      if (!s.motiveById.containsKey(mo)) err('Verdächtige ${sus.id}: Motiv $mo unbekannt');
    }
    if (sus.candidate && sus.motives.isEmpty) err('Kandidat ${sus.id} hat kein Motiv');
    for (final w in sus.weapons) {
      if (!s.weaponById.containsKey(w)) err('Verdächtige ${sus.id}: Waffe $w unbekannt');
    }
    // Eine Waffe darf den Täter nicht allein verraten: mindestens eine weitere Person braucht Zugang.
    if (sus.candidate) {
      for (final w in s.weapons.where((w) => sus.canAccessWeapon(w.id))) {
        if (!s.suspects.any((o) => o.id != sus.id && o.canAccessWeapon(w.id))) {
          err('Waffe ${w.id}: nur ${sus.id} hat Zugang – der Hinweis entlarvt den Täter');
        }
      }
      if (!s.weapons.any((w) => sus.canAccessWeapon(w.id))) err('Kandidat ${sus.id} hat Zugang zu keiner Waffe');
    }
    for (final k in const ['greet', 'alibi', 'alibiLie', 'victim', 'observation', 'rumor', 'nervous', 'annoyed']) {
      if (sus.line(k).isEmpty) err('Verdächtige ${sus.id}: Zeile $k fehlt');
    }
    if (!LookDef.hats.contains(sus.look.hat)) err('Verdächtige ${sus.id}: Hut ${sus.look.hat} unbekannt');
    if (!LookDef.builds.contains(sus.look.build)) err('Verdächtige ${sus.id}: build ${sus.look.build} unbekannt');
    if (!LookDef.outfits.contains(sus.look.outfit)) err('Verdächtige ${sus.id}: outfit ${sus.look.outfit} unbekannt');
  }
  final cands = s.candidates;
  if (cands.length < 2) err('Mindestens 2 Kandidaten nötig');
  final story = s.story;
  final storyCulprit = s.suspectById[story.culprit];
  if (storyCulprit == null || !storyCulprit.candidate) err('story.culprit ist kein Kandidat');
  if (storyCulprit != null && !storyCulprit.motives.contains(story.motive)) err('story.motive passt nicht zum Täter');
  if (!s.weaponById.containsKey(story.weapon)) err('story.weapon unbekannt');
  if (storyCulprit != null && !storyCulprit.canAccessWeapon(story.weapon)) err('story.weapon: Täter hatte keinen Zugang');

  // --- Hinweise
  final clueIds = <String>{};
  for (final c in s.clues) {
    if (!clueIds.add(c.id)) err('Hinweis-ID doppelt: ${c.id}');
    if (!ClueKind.authored.contains(c.kind)) err('Hinweis ${c.id}: kind ${c.kind} unbekannt');
    if (!Evolve.all.contains(c.evolve)) err('Hinweis ${c.id}: evolve ${c.evolve} unbekannt');
    if (c.found.isEmpty) err('Hinweis ${c.id}: found fehlt');
    switch (c.kind) {
      case ClueKind.trait:
        if (!s.traits.containsKey(c.trait)) err('Hinweis ${c.id}: trait ${c.trait} unbekannt');
        if (!c.reveal.resolve().contains('{value}')) err('Hinweis ${c.id}: reveal braucht {value}');
      case ClueKind.alibi:
        final sub = s.suspectById[c.subject];
        if (sub == null) err('Hinweis ${c.id}: subject ${c.subject} unbekannt');
        if (c.reveal.isEmpty || c.revealFalse.isEmpty) err('Hinweis ${c.id}: reveal und revealFalse nötig');
    }
    final src = c.source;
    if ((src.hotspot == null) == (src.npc == null)) err('Hinweis ${c.id}: genau eine Quelle (hotspot ODER npc) nötig');
    if (src.hotspot != null) {
      final h = s.hotspotById[src.hotspot];
      if (h == null) {
        err('Hinweis ${c.id}: Hotspot ${src.hotspot} unbekannt');
      } else {
        if (h.kind == HotspotKind.lab || h.kind == HotspotKind.hide) err('Hinweis ${c.id}: Quelle ist lab/hide');
        if (c.ghost != h.ghost) err('Hinweis ${c.id}: ghost-Flag passt nicht zum Hotspot ${h.id}');
        if (h.fromChapter > c.chapter) warn('Hinweis ${c.id}: chapter ${c.chapter} < Hotspot fromChapter ${h.fromChapter}');
      }
    }
    if (src.npc != null) {
      if (!s.suspectById.containsKey(src.npc)) err('Hinweis ${c.id}: npc ${src.npc} unbekannt');
      if (!Topic.all.contains(src.topic)) err('Hinweis ${c.id}: topic ${src.topic} ungültig');
    }
    if (c.chapter < 1 || c.chapter > 3) err('Hinweis ${c.id}: chapter ungültig');
    if (c.expires != null && c.expires! < c.chapter) err('Hinweis ${c.id}: expires < chapter');
    final cls = c.requires.cls;
    if (cls != null && !detectiveClasses.containsKey(cls)) err('Hinweis ${c.id}: Klasse $cls unbekannt');
    final lead = c.requires.lead;
    if (lead != null && !leadIds.contains(lead)) err('Hinweis ${c.id}: Spur $lead unbekannt');
  }
  if (s.clues.where((c) => c.secret).length != 1) warn('Es sollte genau 1 geheimen Hinweis geben');
  if (!s.clues.any((c) => c.ghost)) warn('Kein Geister-Hinweis');

  // --- Kombinationen
  for (final k in s.combos) {
    if (!s.clueById.containsKey(k.a) || !s.clueById.containsKey(k.b)) err('Kombi ${k.id}: Hinweis unbekannt');
    for (final x in k.reveals) {
      if (!s.clueById.containsKey(x)) err('Kombi ${k.id}: reveals $x unbekannt');
    }
    if (k.lead != null && !leadIds.contains(k.lead)) err('Kombi ${k.id}: Spur ${k.lead} unbekannt');
  }
  for (final l in s.leadById.values.where((l) => l.hidden)) {
    if (!s.combos.any((k) => k.lead == l.id)) warn('Versteckte Spur ${l.id} wird von keiner Kombi freigeschaltet');
  }

  // --- Enden
  for (final k in EndingsDef.verdictKeys) {
    if (s.endings.verdict[k] == null) err('endings.verdict.$k fehlt');
  }
  for (final k in EndingsDef.teamKeys) {
    if (s.endings.team[k] == null) err('endings.team.$k fehlt');
  }
  for (final c in cands) {
    final e = s.endings.culprit[c.id];
    if (e == null || e['caught'] == null || e['escaped'] == null) err('endings.culprit.${c.id} caught/escaped fehlt');
  }
  if (s.endings.secret.isEmpty) warn('endings.secret fehlt');

  // --- Lösbarkeit
  bool dependable(ClueDef c) => c.expires == null && !c.secret && !c.ghost;
  final traitClues = s.clues.where((c) => c.kind == ClueKind.trait && dependable(c)).toList();
  final ungated = traitClues.where((c) => c.requires.isNone).toList();
  for (final cand in cands) {
    List<SuspectDef> remaining(List<ClueDef> clues) {
      final traits = clues.map((c) => c.trait).toSet();
      return s.suspects
          .where((o) => traits.every((t) => o.traits[t] == cand.traits[t]))
          .toList();
    }

    final rem = remaining(traitClues);
    if (rem.length != 1) {
      err('Lösbarkeit: Mit ${cand.id} als Täter bleiben ${rem.map((e) => e.id).join(', ')} übrig');
    } else if (remaining(ungated).length != 1) {
      warn('Lösbarkeit: ${cand.id} nur mit Spur-/Klassen-Hinweisen eindeutig');
    }
    if (!s.clues.any((c) => c.kind == ClueKind.alibi && c.subject == cand.id)) warn('Kein Alibi-Hinweis für ${cand.id}');
  }
  for (final t in s.traits.keys) {
    final n = traitClues.where((c) => c.trait == t).length;
    if (n < 2) warn('Merkmal $t hat nur $n verlässliche Hinweisquelle(n)');
  }
  if (s.clues.where((c) => c.kind == ClueKind.motive && dependable(c)).length < 2) warn('Weniger als 2 Motiv-Hinweise');
  if (s.clues.where((c) => c.kind == ClueKind.weapon && dependable(c)).length < 2) warn('Weniger als 2 Waffen-Hinweise');
  final truths = CaseGenerator.allTruths(s);
  if (truths.isEmpty) err('Keine gültige Fall-Variante');

  return r;
}
