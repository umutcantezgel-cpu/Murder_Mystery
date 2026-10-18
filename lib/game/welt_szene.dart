import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:mordakte_core/mordakte_core.dart';
import 'package:mordakte_core/runden.dart' hide KartenQuelle;

import '../party/daten.dart';
import '../party/karten_quelle.dart';
import '../session/game_session.dart';
import 'szenen_erweiterung.dart';

/// Gemeinsame Grundlage der Szenen auf der Karte einer Partyakte (M1.5).
///
/// Sie speist den Renderer: den Detektiv und alle Personen an ihren
/// Ermittlungsorten, die Hotspots und Kameraziele der laufenden Entscheidung,
/// das Licht der Ermittlung, die Sicht nach Räumen und den Glanz offener
/// Abstecher. Phase, Runde, Wahl und Zug liest sie nur aus der
/// [KartenQuelle]. Geführte Wege, Vorschläge, Gespräche und die Rückblende
/// gehören den Unterklassen (am Tisch: `PartyKartenSession`).
abstract class WeltSzene implements GameSession, SzenenErweiterung, SzenenGlanz, SzenenKamera {
  WeltSzene(this.daten, this.quelle) {
    final kanon = daten.kanon;
    final d = kanon.figur((kanon.figurenJson['detektiv'] as Map)['id'] as String)!;
    final ort = kanon.graph.orte[d['ermittlungsOrt'] as String]!;
    detektivX = ort.x;
    detektivY = ort.y;
    _aussehen = LookDef.fromJson(renderLook(d));
    _offeneTueren = {
      for (final t in kanon.graph.tueren.values)
        if (t.zustand == 'offen') ...[(t.von, t.nach), (t.nach, t.von)],
    };
  }

  final PartyDaten daten;

  /// Woher die Karte Phase, Runde, Wahl, Zug und Abstecher kennt.
  final KartenQuelle quelle;

  late final LookDef _aussehen;
  late final Set<(String, String)> _offeneTueren;
  final _world = ValueNotifier<WorldSnapshot?>(null);
  final _case = ValueNotifier<CaseView?>(null);
  final _events = StreamController<GameEvent>.broadcast();
  final _connected = ValueNotifier<bool>(true);
  double? _korrekturX, _korrekturY;
  int _t = 0;
  int _version = 0;
  String? _letzterRaum;
  bool _entsorgt = false;

  /// Punkte, die im Bild bleiben sollen; wird mit dem Zustand der Karte neu gesetzt.
  List<Offset> _kameraZiele = const [];

  /// Raster der Karte: Kollision der Wege und freie Plätze zum Beiseiterücken.
  late final TileGrid raster = TileGrid(daten.szenario.map);

  /// Pose des eigenen Detektivs in Kachelkoordinaten.
  @protected
  double detektivX = 0, detektivY = 0, detektivBlick = 0.8;

  /// Schon entsorgt? Dann zeigt die Szene nichts mehr.
  bool get entsorgt => _entsorgt;

  /// Bewegung reduziert (Bedienungshilfe): kein Flackern, keine Ruhe-Animation.
  bool bewegungReduziert = false;

  /// Zeigt die Karte gerade die Ermittlung? Sonst (Rückblende) gibt es keine
  /// Hotspots, keinen Glanz, keine Sicht nach Räumen und keine kleinen Effekte.
  @protected
  bool get zeigtErmittlung => true;

  /// Ziel des laufenden Wegs (für die Kamera), sonst `null`.
  @protected
  Offset? get laufZiel => null;

  /// Name des Detektivs am Tisch (Namensschild).
  @protected
  String get detektivName;

  /// Läuft der Detektiv gerade?
  @protected
  bool get detektivGeht => false;

  /// Handlung des Detektivs am Ziel (Suchen, Befragen), sonst `null`.
  @protected
  ChannelView? get detektivKanal => null;

  /// Spricht der Detektiv gerade mit der Kanon-Figur [figur]?
  @protected
  bool sprichtMit(String figur) => false;

  /// Wird vor jedem neuen Fall-Stand aufgerufen (etwa um einen Lauf zu planen).
  @protected
  void vorDemZeigen() {}

  /// Kartenzustand der Ermittlung aus der Quelle (Phase, Runde, Wahl).
  KartenZustand get kartenZustand => daten.karte.zustandBei(quelle.phase, quelle.runde, quelle.gewaehlt);

  // ---------------------------------------------------------------------------
  // Fall und Welt an den Renderer

  /// Neuer Fall-Stand: Hotspots und Kameraziele der laufenden Entscheidung,
  /// danach ein neues Bild der Welt.
  void zeigeFall() {
    if (_entsorgt) return;
    vorDemZeigen();
    final hotspots = <String, String>{};
    final ziele = <Offset>[];
    if (zeigtErmittlung) {
      final z = kartenZustand;
      for (final h in z.erledigt) {
        hotspots[h] = HotspotState.searched;
      }
      if (quelle.laufendeEntscheidung != null) {
        for (final h in z.offen.keys) { hotspots[h] = HotspotState.open; }
        if (quelle.zug == null) {
          // Die Ziele der laufenden Entscheidung bleiben im Bild.
          for (final h in z.offen.keys) {
            if (daten.szenario.hotspotById[h] case final d?) ziele.add(Offset(d.x + 0.5, d.y + 0.5));
          }
          for (final id in z.ansprechbar.keys) {
            for (final f in daten.karte.figuren) {
              if (f.id == id) ziele.add(Offset(f.x, f.y));
            }
          }
        }
      }
      final lauf = laufZiel;
      if (quelle.zug?.phase == RundenZugPhase.aktion && lauf != null) ziele.add(lauf);
      final ziel = daten.karte.ziele[quelle.zug?.option];
      if (ziel != null && ziel.person == null && quelle.zug?.phase != RundenZugPhase.fund) {
        hotspots[ziel.hotspot] = HotspotState.open;
      }
    }
    _kameraZiele = ziele;
    _case.value = CaseView(
      version: ++_version,
      roomCode: 'PARTY',
      hostId: 'me',
      scenarioId: daten.szenario.id,
      mode: 'story',
      seed: 0,
      bots: 0,
      lobby: const [],
      phase: Phase.investigation,
      chapter: quelle.runde.clamp(1, 3),
      notebook: const [],
      board: const [],
      deductions: const [],
      contradictions: 0,
      hotspots: hotspots,
      openDoors: const [],
      items: const [],
      inventory: const [],
      leadOptions: const [],
      leadVotes: const {},
      chosenLeads: const [],
      accusations: const {},
      heard: const {},
      deadNpcs: const [],
      abilityCooldownMs: 0,
      abilityCharges: 0,
      pingsLeft: 0,
      ending: null,
    );
    zeigeWelt();
  }

  /// Figuren der Szene und wer von ihnen gerade geht. Vorgabe: alle Personen
  /// an ihren Ermittlungsorten, niemand geht.
  @protected
  ({List<NpcView> npcs, Set<String> gehend}) figurenAnsicht() => (
        npcs: [
          for (final f in daten.karte.figuren)
            NpcView(id: daten.npcKennung[f.id]!, x: f.x, y: f.y, alive: true, talkingTo: sprichtMit(f.id) ? 'me' : null),
        ],
        gehend: const <String>{},
      );

  /// Neues Bild der Welt: Detektiv und Figuren (nebeneinander gerückt).
  void zeigeWelt() {
    if (_entsorgt) return;
    _t += 100;
    final figuren = figurenAnsicht();
    final npcs = _nebeneinander(figuren.npcs, gehend: figuren.gehend);
    _world.value = WorldSnapshot(
      t: _t,
      phase: Phase.investigation,
      chapter: quelle.runde.clamp(1, 3),
      phaseRemainingMs: 0,
      phaseTotalMs: 0,
      detectives: [
        DetectiveView(
          id: 'me', name: detektivName, cls: 'forensic', coat: 0, hat: 'fedora', bot: false, connected: true,
          x: detektivX, y: detektivY, facing: detektivBlick, life: LifeState.alive, hp: 3, maxHp: 3, nerves: 100, hidden: false,
          moving: detektivGeht,
          channel: detektivKanal,
          effects: const [], downedLeftMs: 0,
        ),
      ],
      npcs: npcs,
      shadow: null,
      signals: const [],
      ackSeq: 0,
      correctX: _korrekturX,
      correctY: _korrekturY,
    );
    _korrekturX = _korrekturY = null;
  }

  /// Detektiv an eine Stelle setzen (Entwickler-Skript, Kamera).
  void setzeDetektiv(double x, double y, {double facing = 0.8}) {
    if (quelle.zug != null || _entsorgt) return;
    detektivX = x;
    detektivY = y;
    detektivBlick = facing;
    _korrekturX = x;
    _korrekturY = y;
    zeigeWelt();
  }

  /// Figuren auf demselben Fleck rücken nebeneinander, damit keine eine andere
  /// verdeckt (in der Rückblende stehen manchmal zwei auf einem Platz). Eine
  /// hervorgehobene Figur bleibt stehen; die anderen weichen zur Seite, aber
  /// nur auf freien Boden. Wer gerade geht ([gehend]), bleibt auf seiner Linie,
  /// sonst springt er beim Vorbeigehen.
  List<NpcView> _nebeneinander(List<NpcView> npcs, {Set<String> gehend = const {}}) {
    const versatz = [(0.42, 0.0), (0.0, 0.42), (-0.42, 0.0), (0.0, -0.42), (0.3, 0.3), (-0.3, -0.3)];
    final gruppen = <(int, int), List<int>>{};
    for (var i = 0; i < npcs.length; i++) {
      (gruppen[((npcs[i].x * 4).round(), (npcs[i].y * 4).round())] ??= []).add(i);
    }
    final aus = [...npcs];
    for (final g in gruppen.values.where((g) => g.length > 1)) {
      g.sort((a, b) => (hervorhebung(npcs[b].id) ?? 0).compareTo(hervorhebung(npcs[a].id) ?? 0));
      final vergeben = <int>{};
      for (var k = 1; k < g.length; k++) {
        final n = npcs[g[k]];
        if (gehend.contains(n.id)) continue;
        // Der übliche Platz zuerst, dann der nächste freie, der noch frei ist.
        for (var v = 0; v < versatz.length; v++) {
          final i = (k - 1 + v) % versatz.length;
          final (dx, dy) = versatz[i];
          if (vergeben.contains(i) || !raster.canStand(n.x + dx, n.y + dy, Tuning.playerRadius)) continue;
          vergeben.add(i);
          aus[g[k]] = NpcView(id: n.id, x: n.x + dx, y: n.y + dy, alive: n.alive, talkingTo: n.talkingTo);
          break;
        }
      }
    }
    return aus;
  }

  // ---------------------------------------------------------------------------
  // GameSession

  @override
  String get playerId => 'me';

  @override
  String get roomCode => 'PARTY';

  @override
  bool get isOnline => false;

  @override
  ValueListenable<WorldSnapshot?> get world => _world;

  @override
  ValueListenable<CaseView?> get caseView => _case;

  @override
  Stream<GameEvent> get events => _events.stream;

  @override
  ValueListenable<bool> get connected => _connected;

  @override
  Map<String, ScenarioDef> get scenarios => {daten.szenario.id: daten.szenario};

  @override
  ScenarioDef? get scenario => daten.szenario;

  @override
  @mustCallSuper
  Future<void> dispose() async {
    if (_entsorgt) return;
    _entsorgt = true;
    _world.dispose();
    _case.dispose();
    _connected.dispose();
    await _events.close();
  }

  // ---------------------------------------------------------------------------
  // SzenenKamera: Ziele der Entscheidung und des Wegs bleiben im Bild

  @override
  List<Offset> get kameraZiele => _kameraZiele;

  // ---------------------------------------------------------------------------
  // SzenenGlanz: offene Abstecher funkeln an ihrem Ort

  @override
  List<SzenenGlanzPunkt> get glanzpunkte {
    if (!zeigtErmittlung || _entsorgt || quelle.zug != null || quelle.phase != PartyPhase.entscheidungen) return const [];
    final orte = daten.kanon.graph.orte;
    return [
      for (final a in quelle.abstecherOffen)
        if (orte[a.ort] case final o?) SzenenGlanzPunkt(a.id, o.x, o.y),
    ];
  }

  // ---------------------------------------------------------------------------
  // SzenenErweiterung: Licht, Sicht und Vorgaben der Darstellung

  static const _warm = Color(0xFFFF9329);

  /// Warme Lichtpunkte der elektrischen Deko-Kerzen (B-04, E-019).
  @protected
  List<SzenenLichtpunkt> get dekoKerzen => [
        for (final (x, y) in daten.karte.dekoKerzen) SzenenLichtpunkt(x, y, z: 0.9, radius: 1.5, farbe: _warm, flackern: bewegungReduziert ? 0 : 0.45),
      ];

  /// Licht der Ermittlung: Deko-Kerzen und die Lichtquellen, die nach der Tat
  /// noch brennen.
  @override
  SzenenLicht? get licht {
    final g = daten.kanon.graph;
    return SzenenLicht(
      dunkel: 0.58,
      punkte: [
        ...dekoKerzen,
        for (final id in daten.karte.ermittlungsLichter)
          if (g.lichtquellen[id] case final l?)
            if (g.orte[l.ort] case final o?) SzenenLichtpunkt(o.x, o.y, z: 1.6, radius: l.radius, farbe: lichtFarbe(l.farbe ?? '#FFF1C9'), flackern: bewegungReduziert ? 0 : l.flackern),
      ],
    );
  }

  /// Farbe aus `#rrggbb`.
  static Color lichtFarbe(String hex) => Color(int.parse(hex.substring(1), radix: 16) | 0xFF000000);

  @override
  Set<String>? sichtbareRaeume(double x, double y) {
    if (!zeigtErmittlung) return null;
    final raum = daten.kanon.graph.raumAn(x, y)?.id ?? _letzterRaum;
    if (raum == null) return null;
    _letzterRaum = raum;
    return {raum, for (final (a, b) in _offeneTueren) if (a == raum) b};
  }

  @override
  double? hervorhebung(String npcId) => null;

  @override
  bool get ruheAnimation => !bewegungReduziert;

  @override
  bool get exakteFiguren => false;

  @override
  bool get kleineEffekte => zeigtErmittlung && !bewegungReduziert;

  @override
  LookDef? get detektivAussehen => _aussehen;

  @override
  Offset? get kamera => null;
}
