import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:mordakte_core/mordakte_core.dart';
import 'package:mordakte_core/runden.dart';

import '../game/szenen_erweiterung.dart';
import '../l10n/gen/app_localizations_de.dart';
import '../session/game_session.dart';
import 'karten_aktion.dart';
import 'sitzung.dart';

/// Speist den vorhandenen Renderer mit der Party-Karte (F4-ORCH-01, E-030).
///
/// Ermittlung: Detektiv als eigene Figur, alle Personen an ihren
/// Ermittlungsorten, offen sind nur die Ziele der laufenden Entscheidung.
/// `Interact` wählt nicht direkt, sondern macht einen Vorschlag; die Sitzung
/// fragt „Das ist endgültig“. Rückblende (erst nach dem Finale): Zeitraffer
/// der Tatmatrix mit dem Licht im Stromausfall (B-04).
final _de = LDe();

class PartyKartenSession implements GameSession, SzenenErweiterung, SzenenGlanz, SzenenKamera, GefuehrteSzene, SzenenGespraech {
  PartyKartenSession(this.sitzung, {this.rueckblendeModus = false, this.zeitraffer = 25}) {
    final d = sitzung.kanon.figur((sitzung.kanon.figurenJson['detektiv'] as Map)['id'] as String)!;
    final ort = sitzung.kanon.graph.orte[d['ermittlungsOrt'] as String]!;
    _x = ort.x;
    _y = ort.y;
    _aussehen = LookDef.fromJson(renderLook(d));
    _offeneTueren = {
      for (final t in sitzung.kanon.graph.tueren.values)
        if (t.zustand == 'offen') ...[(t.von, t.nach), (t.nach, t.von)],
    };
    // Akten ohne Simulation erzählen ihre Rückblende nur (Text); es gibt keine Szene.
    if (rueckblendeModus && sitzung.hatRueckblende) {
      _rb = sitzung.rueckblende;
      zeit.value = _rb!.schritte.first;
    }
    sitzung.addListener(_publishCase);
    _publishCase();
    _tick();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (_) => _tick());
  }

  final PartySitzung sitzung;

  /// Rückblende statt Ermittlung.
  final bool rueckblendeModus;

  /// Spielsekunden je echter Sekunde in der Rückblende.
  final double zeitraffer;

  /// Aktuelle Uhrzeit der Rückblende (für die Anzeige).
  final ValueNotifier<Uhrzeit?> zeit = ValueNotifier(null);

  /// Rückblende zu Ende?
  final ValueNotifier<bool> fertig = ValueNotifier(false);

  late final Timer _timer;
  late final LookDef _aussehen;
  late final Set<(String, String)> _offeneTueren;
  Rueckblende? _rb;
  RueckblendeBild? _bild;
  double _rbSekunden = 0;

  /// Echte Zeit seit dem Start der Rückblende: Unter Last fallen Ticks aus,
  /// der Zeitraffer folgt trotzdem der Uhr.
  final Stopwatch _uhr = Stopwatch();

  /// Ersatz für die Wanduhr der Rückblende (Sekunden seit dem Start), damit
  /// Tests Bild für Bild prüfen können.
  @visibleForTesting
  double Function()? testUhr;
  final _world = ValueNotifier<WorldSnapshot?>(null);
  final _case = ValueNotifier<CaseView?>(null);
  final _events = StreamController<GameEvent>.broadcast();
  final _connected = ValueNotifier<bool>(true);
  double _x = 0, _y = 0, _f = 0.8;
  double? _korrekturX, _korrekturY;
  int _t = 0;
  int _version = 0;
  String? _letzterRaum;
  bool _entsorgt = false;
  KartenAktion? _aktion;
  int? _aktionsNummer;

  /// Ein Abstecher, zu dem es keinen begehbaren Weg gibt: die Erkundung läuft
  /// dann ohne Laufweg weiter (nie eine blockierte Würfelbühne).
  bool _abstecherOhneWeg = false;
  late final TileGrid _raster = TileGrid(sitzung.daten.szenario.map);

  /// Ziel des laufenden Wegs in Kachelkoordinaten (für die Kamera).
  Offset? _aktionsZiel;

  /// Punkte, die im Bild bleiben sollen; wird mit dem Zustand der Sitzung neu gesetzt.
  List<Offset> _kameraZiele = const [];

  final ValueNotifier<double> aktionsFortschritt = ValueNotifier(0);
  final ValueNotifier<bool> aktionsFehler = ValueNotifier(false);

  /// Lesbarer Laufplan für Kartenansicht und Geometrie-/Pfadgleichheitsbelege.
  KartenAktion? get kartenAktion => _aktion;

  @override
  bool bewegungReduziert = false;

  @override
  bool get eingabeGesperrt => rueckblendeModus || sitzung.phase != PartyPhase.entscheidungen ||
      sitzung.zug != null || sitzung.vorschlag != null || sitzung.letzterFund != null || sitzung.gespraech != null;

  /// Position der Figur im laufenden Randgespräch (Kachelkoordinaten).
  Offset? get _gespraechsOrt {
    final g = sitzung.gespraech;
    if (g == null) return null;
    for (final f in sitzung.karte.figuren) {
      if (f.id == g.gespraech.figur) return Offset(f.x, f.y);
    }
    return null;
  }

  @override
  ({String npc, SzenenGeste geste})? get gespraechsGeste {
    final g = sitzung.gespraech;
    final npc = g == null ? null : sitzung.daten.npcKennung[g.gespraech.figur];
    if (g == null || npc == null) return null;
    final geste = switch (g.verlauf.last.geste) {
      'abwehr' => SzenenGeste.abwehr,
      'nachdenken' => SzenenGeste.nachdenken,
      _ => SzenenGeste.zuhoeren,
    };
    return (npc: npc, geste: geste);
  }

  @override
  SzenenPose? get figurenPose {
    if (sitzung.gespraech != null) return SzenenPose.befragen;
    final a = _aktion;
    if (a == null) return null;
    return a.geht ? SzenenPose.gehen : a.suchen ? SzenenPose.suchen : SzenenPose.befragen;
  }

  @override
  double get posenFortschritt => _aktion?.posenFortschritt ?? 0;

  @override
  Offset? get handlungsZiel {
    final ort = _gespraechsOrt;
    if (ort != null) return ort;
    final a = _aktion;
    if (a == null || a.geht) return null;
    return Offset(a.zielX, a.zielY);
  }

  void _synchronisiereAktion() {
    final z = sitzung.zug;
    if (rueckblendeModus || z == null || z.phase != RundenZugPhase.aktion) {
      _aktion = null;
      _aktionsNummer = null;
      _abstecherOhneWeg = false;
      return;
    }
    if (_aktionsNummer == z.aktion) return;
    _aktionsNummer = z.aktion;
    final ziel = sitzung.karte.ziele[z.option];
    double zx = _x, zy = _y;
    String? raum = _raster.roomAtPos(_x, _y)?.id;
    final ort = z.istAbstecher ? sitzung.abstecherLaufend : null;
    final stelle = ort == null ? null : sitzung.kanon.graph.orte[ort.ort];
    if (stelle != null) {
      // Erkundung: der sichtbare Weg führt zum Ort des Abstechers.
      zx = stelle.x;
      zy = stelle.y;
      raum = stelle.raum;
    } else if (ziel != null) {
      raum = ziel.raum;
      if (ziel.person case final person?) {
        final f = sitzung.karte.figuren.firstWhere((f) => f.id == person);
        zx = f.x;
        zy = f.y;
      } else {
        zx = ziel.x! + 0.5;
        zy = ziel.y! + 0.5;
      }
    }
    _aktion = raum == null ? null : KartenAktion.planen(
      raster: _raster, startX: _x, startY: _y, facing: _f,
      zielX: zx, zielY: zy, raum: raum, suchen: z.suche, umweg: z.ruf == Tischruf.umweg,
      personen: [for (final f in sitzung.karte.figuren) (f.x, f.y)],
    );
    _aktionsZiel = Offset(zx, zy);
    _abstecherOhneWeg = z.istAbstecher && _aktion == null;
    aktionsFehler.value = _aktion == null && !z.istAbstecher;
    aktionsFortschritt.value = 0;
    if (bewegungReduziert) _aktion?.abkuerzen();
  }

  @override
  void szenenSchritt(double sekunden) {
    if (_entsorgt) return;
    // Rückblende: jedes Frame ein Bild, damit die Figuren auf ihren Linien
    // bleiben (der 100-ms-Takt allein ist bei Zeitraffer 25 zu grob).
    if (_rb != null) {
      _tick();
      return;
    }
    _synchronisiereAktion();
    final a = _aktion;
    final nr = _aktionsNummer;
    if (a == null && nr != null && _abstecherOhneWeg) {
      sitzung.aktionFertig(nr);
      return;
    }
    if (a == null || nr == null) return;
    a.schritt(sekunden);
    _x = a.x;
    _y = a.y;
    _f = a.facing;
    aktionsFortschritt.value = a.fortschritt;
    _tick();
    if (a.fertig) sitzung.aktionFertig(nr);
  }

  /// Bewusste Abkürzung, nie ein versteckter E2E-/Zeitgeber-Automatismus.
  void aktionAbkuerzen() {
    _aktion?.abkuerzen();
  }

  /// Detektiv an eine Stelle setzen (Entwickler-Skript, Kamera).
  void setzeDetektiv(double x, double y, {double facing = 0.8}) {
    if (sitzung.zug != null || _entsorgt) return;
    _x = x;
    _y = y;
    _f = facing;
    _korrekturX = x;
    _korrekturY = y;
    _tick();
  }

  /// Rückblende von vorn.
  void neuStarten() {
    _rbSekunden = 0;
    _uhr
      ..reset()
      ..start();
    fertig.value = false;
  }

  void _tick() {
    if (_entsorgt) return;
    _t += 100;
    final rb = _rb;
    List<NpcView> npcs;
    final gehend = <String>{};
    if (rb != null) {
      final dauer = rb.schritte.last.minus(rb.schritte.first).toDouble();
      if (!_uhr.isRunning) _uhr.start();
      final echt = testUhr?.call() ?? _uhr.elapsedMicroseconds / 1e6;
      _rbSekunden = math.min(dauer, echt * zeitraffer);
      if (_rbSekunden >= dauer) fertig.value = true;
      // Die Uhr zeigt ganze Sekunden; die Figuren stehen auf dem Bruchteil.
      final ganz = _rbSekunden.floor();
      final t = rb.schritte.first.plus(ganz);
      if (zeit.value != t) zeit.value = t;
      sitzung.rueckblendeZeit = t;
      final b = _bild = rb.bild(t, bruch: _rbSekunden - ganz);
      for (final e in b.personen.entries) {
        if (e.value.bewegtSich) {
          if (sitzung.daten.npcKennung[e.key] case final id?) gehend.add(id);
        }
      }
      npcs = [
        for (final e in b.personen.entries)
          if (sitzung.daten.npcKennung[e.key] case final id?) NpcView(id: id, x: e.value.x, y: e.value.y, alive: true),
      ];
    } else {
      npcs = [
        for (final f in sitzung.karte.figuren) NpcView(
          id: sitzung.daten.npcKennung[f.id]!, x: f.x, y: f.y, alive: true,
          talkingTo: figurenPose == SzenenPose.befragen &&
                  (sitzung.karte.ziele[sitzung.zug?.option]?.person == f.id || sitzung.gespraech?.gespraech.figur == f.id)
              ? 'me'
              : null,
        ),
      ];
    }
    npcs = _nebeneinander(npcs, gehend: gehend);
    _world.value = WorldSnapshot(
      t: _t,
      phase: Phase.investigation,
      chapter: sitzung.runde.clamp(1, 3),
      phaseRemainingMs: 0,
      phaseTotalMs: 0,
      detectives: [
        DetectiveView(
          id: 'me', name: sitzung.personAmTisch('detective'), cls: 'forensic', coat: 0, hat: 'fedora', bot: false, connected: true,
          x: _x, y: _y, facing: _f, life: LifeState.alive, hp: 3, maxHp: 3, nerves: 100, hidden: false,
          moving: _aktion?.geht ?? false,
          channel: _aktion != null && !_aktion!.geht ? ChannelView(
            kind: _aktion!.suchen ? 'search' : 'talk', target: sitzung.zug?.option ?? sitzung.zug?.id ?? 'auftakt', progress: posenFortschritt,
          ) : null,
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

  void _publishCase() {
    if (_entsorgt) return;
    _synchronisiereAktion();
    final hotspots = <String, String>{};
    final ziele = <Offset>[];
    if (!rueckblendeModus) {
      final z = sitzung.karte.zustand(sitzung.spiel);
      for (final h in z.erledigt) {
        hotspots[h] = HotspotState.searched;
      }
      if (sitzung.laufendeEntscheidung != null) {
        for (final h in z.offen.keys) { hotspots[h] = HotspotState.open; }
        if (sitzung.zug == null) {
          // Die Ziele der laufenden Entscheidung bleiben im Bild.
          for (final h in z.offen.keys) {
            if (sitzung.daten.szenario.hotspotById[h] case final d?) ziele.add(Offset(d.x + 0.5, d.y + 0.5));
          }
          for (final id in z.ansprechbar.keys) {
            for (final f in sitzung.karte.figuren) {
              if (f.id == id) ziele.add(Offset(f.x, f.y));
            }
          }
        }
      }
      if (sitzung.zug?.phase == RundenZugPhase.aktion && _aktionsZiel != null) ziele.add(_aktionsZiel!);
      final ziel = sitzung.karte.ziele[sitzung.zug?.option];
      if (ziel != null && ziel.person == null && sitzung.zug?.phase != RundenZugPhase.fund) {
        hotspots[ziel.hotspot] = HotspotState.open;
      }
    }
    _kameraZiele = ziele;
    _case.value = CaseView(
      version: ++_version,
      roomCode: 'PARTY',
      hostId: 'me',
      scenarioId: sitzung.daten.szenario.id,
      mode: 'story',
      seed: 0,
      bots: 0,
      lobby: const [],
      phase: Phase.investigation,
      chapter: sitzung.runde.clamp(1, 3),
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
    _tick();
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
  Map<String, ScenarioDef> get scenarios => {sitzung.daten.szenario.id: sitzung.daten.szenario};

  @override
  ScenarioDef? get scenario => sitzung.daten.szenario;

  @override
  void move(double x, double y, double facing) {
    if (eingabeGesperrt || _entsorgt || !x.isFinite || !y.isFinite || !facing.isFinite) return;
    _x = x;
    _y = y;
    _f = facing;
  }

  @override
  void send(Command command) {
    if (eingabeGesperrt || command is! Interact) return;
    final kennung = sitzung.daten.kanonKennung[command.target] ?? command.target;
    if (sitzung.laufendeEntscheidung != null && _zustand.ansprechbar[kennung] != null) {
      sitzung.schlageVorAn(kennung);
    } else if (!sitzung.randgespraechBeginnen(kennung)) {
      sitzung.schlageVorAn(kennung);
    }
  }

  @override
  Future<void> dispose() async {
    if (_entsorgt) return;
    _entsorgt = true;
    sitzung.removeListener(_publishCase);
    _timer.cancel();
    aktionsFortschritt.dispose();
    aktionsFehler.dispose();
    zeit.dispose();
    fertig.dispose();
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
    if (rueckblendeModus || _entsorgt || sitzung.zug != null || sitzung.phase != PartyPhase.entscheidungen) return const [];
    final orte = sitzung.kanon.graph.orte;
    return [
      for (final a in sitzung.abstecherOffen)
        if (orte[a.ort] case final o?) SzenenGlanzPunkt(a.id, o.x, o.y),
    ];
  }

  // ---------------------------------------------------------------------------
  // SzenenErweiterung

  KartenZustand get _zustand => sitzung.karte.zustand(sitzung.spiel);

  @override
  String? npcAktion(String npcId) {
    if (eingabeGesperrt) return null;
    final kanon = sitzung.daten.kanonKennung[npcId];
    if (sitzung.laufendeEntscheidung != null) {
      final art = _zustand.ansprechbar[kanon];
      if (art != null) return sitzung.ui('ui.karte.aktion.${art.name}');
    }
    // Unbesetzte Zeugen lassen sich am Rande ansprechen (Gespräche mit Wahl).
    if (kanon != null && sitzung.randgespraechMoeglich(kanon)) return _de.gespraech_ansprechen;
    return null;
  }

  @override
  bool npcUntersuchen(String npcId) => !eingabeGesperrt && _zustand.ansprechbar[sitzung.daten.kanonKennung[npcId]] == ZielArt.gegenstand;

  @override
  String? hotspotAktion(String hotspotId) {
    if (eingabeGesperrt) return null;
    final art = _zustand.offen[hotspotId];
    return art == null ? null : sitzung.ui('ui.karte.aktion.${art.name}');
  }

  static const _warm = Color(0xFFFF9329);

  @override
  SzenenLicht? get licht {
    final g = sitzung.kanon.graph;
    final kerzen = [
      for (final (x, y) in sitzung.karte.dekoKerzen) SzenenLichtpunkt(x, y, z: 0.9, radius: 1.5, farbe: _warm, flackern: bewegungReduziert ? 0 : 0.45),
    ];
    final b = _bild;
    if (rueckblendeModus && b != null) {
      final strom = b.helleRaeume.contains('thekensaal');
      return SzenenLicht(
        dunkel: strom ? 0.66 : 0.85,
        taschenlampe: false,
        helleRaeume: const {},
        punkte: [
          if (strom) ...kerzen,
          for (final l in b.lichter)
            SzenenLichtpunkt(l.x, l.y, radius: math.max(0.8, l.radius), farbe: _farbe(l.farbe), flackern: l.flackern),
        ],
      );
    }
    return SzenenLicht(
      dunkel: 0.58,
      punkte: [
        ...kerzen,
        for (final id in sitzung.karte.ermittlungsLichter)
          if (g.lichtquellen[id] case final l?)
            if (g.orte[l.ort] case final o?) SzenenLichtpunkt(o.x, o.y, z: 1.6, radius: l.radius, farbe: _farbe(l.farbe ?? '#FFF1C9'), flackern: bewegungReduziert ? 0 : l.flackern),
      ],
    );
  }

  static Color _farbe(String hex) => Color(int.parse(hex.substring(1), radix: 16) | 0xFF000000);

  @override
  Set<String>? sichtbareRaeume(double x, double y) {
    if (rueckblendeModus) return null;
    final raum = sitzung.kanon.graph.raumAn(x, y)?.id ?? _letzterRaum;
    if (raum == null) return null;
    _letzterRaum = raum;
    return {raum, for (final (a, b) in _offeneTueren) if (a == raum) b};
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
          if (vergeben.contains(i) || !_raster.canStand(n.x + dx, n.y + dy, Tuning.playerRadius)) continue;
          vergeben.add(i);
          aus[g[k]] = NpcView(id: n.id, x: n.x + dx, y: n.y + dy, alive: n.alive, talkingTo: n.talkingTo);
          break;
        }
      }
    }
    return aus;
  }

  @override
  double? hervorhebung(String npcId) {
    final rb = _rb;
    if (rb == null) return null;
    return rb.hervorgehoben.contains(sitzung.daten.kanonKennung[npcId]) ? 1 : 0;
  }

  @override
  bool get ruheAnimation => !bewegungReduziert;

  @override
  bool get exakteFiguren => _rb != null;

  @override
  bool get kleineEffekte => !rueckblendeModus && !bewegungReduziert;

  @override
  LookDef? get detektivAussehen => _aussehen;

  @override
  Offset? get kamera {
    final b = _bild;
    if (!rueckblendeModus || b == null) return null;
    final p = b.personen[_rb!.pfad];
    return p == null ? null : Offset(p.x, p.y);
  }
}
