import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart' show FocusNode, KeyEventResult;
import 'package:mordakte_core/mordakte_core.dart';

import '../session/game_session.dart';
import 'iso_math.dart';
import 'scene/figure_painter.dart';
import 'scene/lighting.dart';
import 'szenen_erweiterung.dart';
import 'scene/markers.dart';
import 'scene/nebel.dart';
import 'scene/palette.dart';
import 'scene/prop_painter.dart';
import 'scene/static_scene.dart';
import 'scene/weather.dart';

/// Ziel des Aktionsknopfs.
class ActionTarget {
  /// Hotspot-, Verdächtigen-, Item- oder Spieler-ID; leer bei `cancel`.
  final String id;
  final String label;

  /// `search`, `lab`, `hide`, `body`, `blood`, `npc`, `item`, `trace`, `revive`, `cancel`.
  final String kind;
  final double x, y, z;
  final String name;

  /// Ziel ist eine Figur (Namensschild über dem Kopf), auch wenn [kind] die
  /// Lupe zeigt, weil die Figur untersucht wird (Partymodus, E-038).
  final bool figur;

  const ActionTarget({
    required this.id,
    required this.label,
    required this.kind,
    required this.x,
    required this.y,
    this.z = 0,
    this.name = '',
    this.figur = false,
  });

  bool get isCancel => kind == 'cancel';

  bool sameAs(ActionTarget? o) => o != null && o.id == id && o.label == label && o.kind == kind;
}

class _Sample {
  final double t, x, y, f;
  const _Sample(this.t, this.x, this.y, this.f);
}

/// Interpolierte Position einer fremden Figur (~120 ms Puffer).
class _Track {
  final List<_Sample> samples = [];
  double x = 0, y = 0;
  double facing = math.pi / 4;
  double walk = 0;
  double move = 0;
  bool init = false;

  void add(double t, double x, double y, double f) {
    samples.add(_Sample(t, x, y, f));
    if (samples.length > 12) samples.removeAt(0);
  }

  void step(double rt, double dt, {bool useReportedFacing = true}) {
    if (samples.isEmpty) return;
    double nx, ny, nf;
    if (rt <= samples.first.t) {
      nx = samples.first.x;
      ny = samples.first.y;
      nf = samples.first.f;
    } else if (rt >= samples.last.t) {
      nx = samples.last.x;
      ny = samples.last.y;
      nf = samples.last.f;
    } else {
      var i = 0;
      while (i < samples.length - 2 && samples[i + 1].t < rt) {
        i++;
      }
      final a = samples[i], b = samples[i + 1];
      final k = ((rt - a.t) / math.max(1e-6, b.t - a.t)).clamp(0.0, 1.0);
      nx = a.x + (b.x - a.x) * k;
      ny = a.y + (b.y - a.y) * k;
      nf = k < 0.5 ? a.f : b.f;
    }
    if (!init) {
      x = nx;
      y = ny;
      facing = useReportedFacing ? nf : facing;
      init = true;
      return;
    }
    final dx = nx - x, dy = ny - y;
    final d = math.sqrt(dx * dx + dy * dy);
    if (d > 3) {
      // Teleport
      x = nx;
      y = ny;
      return;
    }
    final speed = dt > 0 ? d / dt : 0.0;
    final moving = speed > 0.3;
    move += ((moving ? 1.0 : 0.0) - move) * math.min(1.0, dt * 10);
    walk += d * 7.5;
    if (moving) {
      facing = _lerpAngle(facing, math.atan2(dy, dx), math.min(1.0, dt * 12));
    } else if (useReportedFacing) {
      facing = _lerpAngle(facing, nf, math.min(1.0, dt * 8));
    }
    x = nx;
    y = ny;
  }
}

double _lerpAngle(double a, double b, double t) {
  var d = (b - a) % (math.pi * 2);
  if (d > math.pi) d -= math.pi * 2;
  if (d < -math.pi) d += math.pi * 2;
  return a + d * t;
}

/// Teilchen der kleinen Effekte (Seifenblasen, Staub, Ruß) in Szenen-Pixeln.
class _Teilchen {
  _Teilchen(this.x, this.y, this.vx, this.vy, this.max, this.r, this.farbe, {this.blase = false, this.wachsen = 0});
  double x, y, vx, vy, r, life = 0;
  final double max, wachsen;
  final Color farbe;
  final bool blase;
}

class _Nebel {
  _Nebel(this.sicht)
      : offen = sicht > 0.5,
        erinnert = sicht > 0.5;
  double sicht;
  bool offen;

  /// Der Raum war schon einmal im Sichtfeld: Sein Schleier ist dann leichter.
  bool erinnert;
  Offset? ursprung;
}

class _Smoke {
  double x, y, vx, vy, life, max, r;
  _Smoke(this.x, this.y, this.vx, this.vy, this.max, this.r) : life = 0;
}

class _LocalPing {
  final double x, y;
  final bool ok;
  double age = 0;
  _LocalPing(this.x, this.y, this.ok);
}

/// Die isometrische Spielszene. Liest `session.world.value` direkt pro Frame.
class MordakteGame extends Game with KeyboardEvents {
  MordakteGame({required this.session});

  GameSession session;

  /// Fokus der Szene (für Tastatur).
  FocusNode? focusNode;

  /// Joystick-Vektor in Bildschirmrichtung, Länge 0..1.
  Offset stick = Offset.zero;

  /// Benutzer-Zoom (Pinch/Mausrad).
  double userZoom = debugInitialZoom;

  /// Nur für Entwicklungs-Vorschau/Screenshots.
  static double debugInitialZoom = 1;

  /// Aktuelles Ziel für den Aktionsknopf.
  final ValueNotifier<ActionTarget?> target = ValueNotifier(null);

  /// Fortschritt der eigenen Kanal-Aktion (0..1), für den Aktionsknopf.
  final ValueNotifier<double> channelProgress = ValueNotifier(0);

  /// Farben des aktuellen Szenarios.
  ScenePalette get palette => _pal;

  // --- Szene ---
  StaticScene? _scene;
  String? _scenarioId;
  bool _buildFailed = false;
  TileGrid? _grid;
  ScenePalette _pal = ScenePalette.fallback;
  final FigurePainter _fig = FigurePainter();
  final TextCache _text = TextCache();
  MarkerPainter? _markers;
  LightingRenderer? _lighting;
  WeatherSystem? _weather;

  double _time = 0;
  double _lastDt = 1 / 60;

  // --- Kamera ---
  Offset _cam = Offset.zero;
  bool _camInit = false;
  double _zoom = 1;
  static const double _camY = 0.5;

  // --- eigener Spieler ---
  double _px = 0, _py = 0, _pf = math.pi / 4;
  bool _hasPos = false;
  double _walk = 0, _moveAmt = 0;
  double _lastSendT = -1;
  double _sentX = double.nan, _sentY = double.nan, _sentF = double.nan;
  double _farTimer = 0;

  // --- Netzwerkdaten ---
  WorldSnapshot? _lastWorld;
  double _worldRecvT = 0;
  final Map<String, _Track> _tracks = {};
  Set<Pt> _openDoors = {};
  int _caseVersion = -1;

  // --- Effekte ---
  final List<_Smoke> _smoke = [];
  final List<_LocalPing> _localPings = [];
  final math.Random _rnd = math.Random(3);
  double _nextFlash = 6;
  double _flashT = -1;
  double _flash = 0;
  double _actionPulse = 0;

  @override
  Color backgroundColor() => _pal.background;

  // ---------------------------------------------------------------------------
  // Öffentliche API für GameView

  void triggerAction() {
    if (_fuehrung?.eingabeGesperrt == true) return;
    final t = target.value;
    if (t == null) return;
    if (t.isCancel) {
      session.send(const CancelAction());
    } else {
      // Aktuelle Position zuerst senden, sonst startet der Server den Kanal an
      // einer veralteten Stelle und bricht ihn beim nächsten Move sofort ab.
      _flushPose();
      session.send(Interact(t.id));
    }
    _actionPulse = 1;
  }

  /// Bildschirmpunkt (lokal im Widget) → Welt-Kachelkoordinaten.
  Offset screenToWorld(Offset local) {
    final ws = (local - Offset(size.x / 2, size.y * _camY)) / _zoom + _cam;
    return Iso.toWorld(ws.dx, ws.dy);
  }

  /// Langes Drücken → Ping. Gibt `false` zurück, wenn keine Pings übrig sind.
  bool ping(Offset local) {
    if (_scene == null || _fuehrung?.eingabeGesperrt == true) return false;
    final w = screenToWorld(local);
    final cv = session.caseView.value;
    final ok = cv == null || cv.pingsLeft > 0;
    _localPings.add(_LocalPing(w.dx, w.dy, ok));
    if (ok) {
      session.send(Signal(kind: 'ping', value: 'look', x: (w.dx * 100).round() / 100, y: (w.dy * 100).round() / 100));
    }
    return ok;
  }

  void dispose() {
    _scene?.dispose();
    _scene = null;
    _text.dispose();
    target.dispose();
    channelProgress.dispose();
  }

  // ---------------------------------------------------------------------------
  // Tastatur

  static final _moveKeys = {
    LogicalKeyboardKey.keyW,
    LogicalKeyboardKey.keyA,
    LogicalKeyboardKey.keyS,
    LogicalKeyboardKey.keyD,
    LogicalKeyboardKey.arrowUp,
    LogicalKeyboardKey.arrowDown,
    LogicalKeyboardKey.arrowLeft,
    LogicalKeyboardKey.arrowRight,
  };

  @override
  KeyEventResult onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    final k = event.logicalKey;
    if (k == LogicalKeyboardKey.keyE || k == LogicalKeyboardKey.space || k == LogicalKeyboardKey.enter) {
      if (event is KeyDownEvent) triggerAction();
      return KeyEventResult.handled;
    }
    if (_moveKeys.contains(k)) return KeyEventResult.handled;
    return KeyEventResult.ignored;
  }

  Offset _keyboardDir() {
    final node = focusNode;
    if (node != null && !node.hasFocus) return Offset.zero;
    final keys = HardwareKeyboard.instance.logicalKeysPressed;
    if (keys.isEmpty) return Offset.zero;
    var dx = 0.0, dy = 0.0;
    if (keys.contains(LogicalKeyboardKey.keyW) || keys.contains(LogicalKeyboardKey.arrowUp)) dy -= 1;
    if (keys.contains(LogicalKeyboardKey.keyS) || keys.contains(LogicalKeyboardKey.arrowDown)) dy += 1;
    if (keys.contains(LogicalKeyboardKey.keyA) || keys.contains(LogicalKeyboardKey.arrowLeft)) dx -= 1;
    if (keys.contains(LogicalKeyboardKey.keyD) || keys.contains(LogicalKeyboardKey.arrowRight)) dx += 1;
    final l = math.sqrt(dx * dx + dy * dy);
    return l < 1e-6 ? Offset.zero : Offset(dx / l, dy / l);
  }

  // ---------------------------------------------------------------------------
  // Update

  @override
  void update(double dt) {
    // Nur gegen Hänger begrenzen (wie die Engine mit 250 ms). Die eigene Figur
    // läuft in Teilschritten ≤ 50 ms, damit sie auch bei < 20 fps volle
    // Geschwindigkeit hat und die Wandkollision pro Schritt greift.
    final frameDt = dt.clamp(0.0, 0.25);
    dt = math.min(frameDt, 0.05);
    _lastDt = dt;
    _time += frameDt;
    _syncScenario();
    if (_scene == null) return;
    _fuehrung?.szenenSchritt(frameDt);
    _ingestWorld();
    _syncCase();
    var rem = frameDt;
    do {
      final s = math.min(rem, 0.05);
      _updatePlayer(s);
      rem -= s;
    } while (rem > 1e-9);
    _updateTracks(dt);
    _updateCamera(dt);
    _updateNebel(frameDt);
    _updateTarget();
    _updateEffects(dt);
  }

  void _syncScenario() {
    final s = session.scenario;
    if (s == null) return;
    if (s.id == _scenarioId && (_scene != null || _buildFailed)) return;
    _scene?.dispose();
    _buildFailed = false;
    try {
      _scene = StaticScene.build(s);
    } catch (e, st) {
      debugPrint('Mordakte: Szene konnte nicht gebaut werden: $e\n$st');
      _scene = null;
      _scenarioId = s.id;
      _buildFailed = true;
      return;
    }
    _scenarioId = s.id;
    _pal = _scene!.pal;
    _grid = TileGrid(s.map);
    _openDoors = {};
    _caseVersion = -1;
    _markers = MarkerPainter(_pal, _text);
    _lighting = LightingRenderer(_pal);
    _weather = WeatherSystem(ThemeDef.weathers.contains(s.theme.weather) ? s.theme.weather : 'none', _pal);
    _tracks.clear();
    _hasPos = false;
    _camInit = false;
    _playerRoom = null;
  }

  WorldSnapshot? get _world => session.world.value;

  DetectiveView? get _me => _world?.detective(session.playerId);

  void _ingestWorld() {
    final w = _world;
    if (w == null || identical(w, _lastWorld)) return;
    _lastWorld = w;
    _worldRecvT = _time;
    if (w.ackSeq != _ackSeen) {
      _ackSeen = w.ackSeq;
      _unackedSince = null;
    }
    final present = <String>{};
    for (final d in w.detectives) {
      if (d.id == session.playerId) continue;
      final key = 'd:${d.id}';
      present.add(key);
      (_tracks[key] ??= _Track()).add(_time, d.x, d.y, d.facing);
    }
    for (final n in w.npcs) {
      final key = 'n:${n.id}';
      present.add(key);
      (_tracks[key] ??= _Track()).add(_time, n.x, n.y, 0);
    }
    final sh = w.shadow;
    if (sh != null) {
      present.add('shadow');
      (_tracks['shadow'] ??= _Track()).add(_time, sh.x, sh.y, 0);
    }
    // Nur entfernen, was im Snapshot fehlt – bei Funkstille bleibt die letzte Pose stehen.
    _tracks.removeWhere((k, _) => !present.contains(k));
    // Eigene Position: Start, Korrektur, Teleport.
    final me = w.detective(session.playerId);
    if (me != null) {
      if (!_hasPos) {
        _px = me.x;
        _py = me.y;
        _pf = me.facing;
        _hasPos = true;
        _sentX = _px;
        _sentY = _py;
        _sentF = _pf;
      }
    }
    if (w.correctX != null && w.correctY != null) {
      _px = w.correctX!;
      _py = w.correctY!;
      _sentX = _px;
      _sentY = _py;
      _hasPos = true;
    }
  }

  void _syncCase() {
    final cv = session.caseView.value;
    if (cv == null || cv.version == _caseVersion) return;
    _caseVersion = cv.version;
    final open = <Pt>{
      for (final d in cv.openDoors)
        if (d.length >= 2) Pt(d[0], d[1]),
    };
    if (open.length != _openDoors.length || !open.containsAll(_openDoors)) {
      _openDoors = open;
      _grid?.setOpenDoors(open);
      _scene?.setOpenDoors(open);
    }
  }

  Phase? get _phase => _world?.phase ?? session.caseView.value?.phase;

  /// Interaktionen sind nur in Ermittlung und Nacht erlaubt (wie in der Engine).
  bool get _actionPhase {
    final p = _phase;
    return p == Phase.investigation || p == Phase.night;
  }

  bool get _canMovePhase {
    final p = _phase;
    return p == Phase.investigation || p == Phase.council || p == Phase.night || p == Phase.accusation;
  }

  double _effectMul(DetectiveView? d, double Function(Modifiers) f) {
    if (d == null) return 1;
    var m = 1.0;
    for (final e in d.effects) {
      final def = effectCatalog[e];
      if (def != null) m *= f(def.mods);
    }
    return m;
  }

  void _updatePlayer(double dt) {
    final me = _me;
    final grid = _grid;
    if (!_hasPos || grid == null) {
      _moveAmt = 0;
      return;
    }
    // Geführte Partyaktionen besitzen ihre Pose. Joystick, Vorhersage und
    // _sendPose dürfen den A*-Lauf weder überschreiben noch zurückmelden.
    if (_fuehrung?.eingabeGesperrt == true && me != null) {
      _walk += dist(_px, _py, me.x, me.y) * 7.5;
      _px = _sentX = me.x;
      _py = _sentY = me.y;
      _pf = _sentF = me.facing;
      _moveAmt = me.moving && _fuehrung?.bewegungReduziert != true ? 1 : 0;
      _following = false;
      _farTimer = _idleT = _followT = 0;
      _unackedSince = null;
      final raum = grid.roomAtPos(_px, _py);
      if (raum != null && !_isDoorTile(_px, _py)) _playerRoom = raum.id;
      return;
    }
    // Die Serverposition gilt nur, wenn der Snapshot frisch ist und der Server
    // unsere letzten Moves bestätigt hat – sonst zieht ein Funkloch uns zurück.
    final w = _world;
    final unacked = _unackedSince;
    final meTrusted =
        w != null && _time - _worldRecvT < 0.5 && (w.ackSeq == 0 || unacked == null || _time - unacked < 0.8);
    if (!meTrusted) {
      _farTimer = 0;
      _followT = 0;
    }
    // Sicherheitsnetz: Server sieht uns ganz woanders (Teleport ohne Korrektur).
    if (me != null && meTrusted) {
      final far = dist(me.x, me.y, _px, _py) > 4;
      _farTimer = far ? _farTimer + dt : 0;
      if (_farTimer > 1.2) {
        _px = me.x;
        _py = me.y;
        _farTimer = 0;
      }
    }
    var input = stick;
    if (input.distance < 0.05) input = _keyboardDir();
    final mag = math.min(1.0, input.distance);
    final canMove = me != null && _canMovePhase && me.life != LifeState.downed && !me.hidden;
    var moved = 0.0;
    // Folgemodus: Ohne eigene Eingabe übernimmt der Client die Serverposition
    // (Autopilot, Versetzen in der Beratung), ohne sie zurückzusenden.
    final idle = mag <= 0.05;
    _idleT = idle ? _idleT + dt : 0;
    if (!idle) {
      _following = false;
      _followT = 0;
    } else if (me != null && meTrusted && _idleT > 0.25) {
      final d = dist(me.x, me.y, _px, _py);
      _followT = d > 0.12 ? _followT + dt : 0;
      if (_followT > 0.45) _following = true;
      if (_following && d > 0.001) {
        final k = math.min(1.0, dt * 10);
        final nx = _px + (me.x - _px) * k, ny = _py + (me.y - _py) * k;
        moved = dist(nx, ny, _px, _py);
        if (moved > 0.004) _pf = _lerpAngle(_pf, math.atan2(ny - _py, nx - _px), math.min(1.0, dt * 12));
        _px = nx;
        _py = ny;
        _sentX = _px;
        _sentY = _py;
        _sentF = _pf;
      }
    }
    if (canMove && mag > 0.05) {
      final dir = Iso.screenDirToWorld(input.dx, input.dy);
      final dl = dir.distance;
      if (dl > 1e-6) {
        // Geister sind wie in der Engine (PlayerState.speedMul) 10 % schneller.
        final speed = Tuning.playerSpeed * (me.life == LifeState.ghost ? 1.1 : _effectMul(me, (m) => m.speed)) * mag;
        final step = speed * dt;
        final dx = dir.dx / dl * step, dy = dir.dy / dl * step;
        double nx, ny;
        if (grid.canStand(_px, _py, Tuning.playerRadius)) {
          (nx, ny) = grid.slide(_px, _py, dx, dy, Tuning.playerRadius);
        } else {
          nx = _px + dx;
          ny = _py + dy;
        }
        moved = dist(nx, ny, _px, _py);
        _px = nx;
        _py = ny;
        _pf = _lerpAngle(_pf, math.atan2(dir.dy, dir.dx), math.min(1.0, dt * 16));
      }
    }
    final r = grid.roomAtPos(_px, _py);
    if (r != null && !_isDoorTile(_px, _py)) _playerRoom = r.id;
    _walk += moved * 7.5;
    _moveAmt += ((moved > 1e-4 ? 1.0 : 0.0) - _moveAmt) * math.min(1.0, dt * 12);
    // Senden: ≤ 15 Hz und nur bei Änderung.
    if (me != null && _time - _lastSendT >= 1 / 15) {
      final changed = (_px - _sentX).abs() > 0.004 || (_py - _sentY).abs() > 0.004 || (_angleDiff(_pf, _sentF)) > 0.05;
      if (changed || _sentX.isNaN) _sendPose();
    }
  }

  void _sendPose() {
    if (_fuehrung?.eingabeGesperrt == true) return;
    session.move(_px, _py, _pf);
    _sentX = _px;
    _sentY = _py;
    _sentF = _pf;
    _lastSendT = _time;
    _unackedSince ??= _time;
  }

  /// Sendet die vorhergesagte Position sofort (ohne 15-Hz-Drossel), falls sie sich geändert hat.
  void _flushPose() {
    final me = _me;
    if (!_hasPos || me == null || me.life == LifeState.downed || me.hidden) return;
    final changed = (_px - _sentX).abs() > 0.004 || (_py - _sentY).abs() > 0.004 || (_angleDiff(_pf, _sentF)) > 0.05;
    if (changed || _sentX.isNaN) _sendPose();
  }

  String? _playerRoom;
  int _ackSeen = -1;
  double? _unackedSince;
  double _idleT = 0, _followT = 0;
  bool _following = false;

  bool _isDoorTile(double x, double y) {
    final c = _scene?.map.charAt(x.floor(), y.floor());
    return c == TileChar.door || c == TileChar.lockedDoor;
  }

  double _angleDiff(double a, double b) {
    if (a.isNaN || b.isNaN) return 10;
    var d = (a - b) % (math.pi * 2);
    if (d > math.pi) d = math.pi * 2 - d;
    return d.abs();
  }

  void _updateTracks(double dt) {
    final rt = _time - 0.12;
    for (final e in _tracks.entries) {
      final isNpc = e.key.startsWith('n:');
      e.value.step(rt, dt, useReportedFacing: !isNpc && e.key != 'shadow');
      if (isNpc && e.value.move < 0.3) {
        // NPCs schauen Spieler in der Nähe an, sonst in die Kamera.
        final t = e.value;
        final d = dist(t.x, t.y, _px, _py);
        final want = d < 4 && _hasPos ? math.atan2(_py - t.y, _px - t.x) : math.pi / 4;
        t.facing = _lerpAngle(t.facing, want, math.min(1.0, dt * 4));
      }
    }
  }

  void _updateCamera(double dt) {
    if (size.x <= 0 || size.y <= 0) return;
    final short = math.min(size.x, size.y);
    final base = (short / (10.5 * Iso.tileW)).clamp(0.42, 2.4);
    _zoom = base * userZoom.clamp(0.6, 1.8);
    Offset targetCam;
    final festeKamera = _ext?.kamera;
    if (festeKamera != null) {
      targetCam = Iso.toScreen(festeKamera.dx, festeKamera.dy, 0.6);
    } else if (_hasPos) {
      targetCam = Iso.toScreen(_px, _py, 0.6);
    } else {
      final m = _scene!.map;
      final sp = m.spawn.isNotEmpty ? m.spawn.first : Pt(m.width ~/ 2, m.height ~/ 2);
      targetCam = Iso.toScreen(sp.x + 0.5, sp.y + 0.5, 0.6);
    }
    if (!_camInit || _fuehrung?.bewegungReduziert == true) {
      _cam = targetCam;
      _camInit = true;
    } else {
      final k = 1 - math.exp(-dt * 7);
      _cam = Offset.lerp(_cam, targetCam, k)!;
    }
  }

  static const _itemNames = {
    'coffee': 'Kaffee',
    'battery': 'Batterie',
    'salts': 'Riechsalz',
    'antidote': 'Gegengift',
    'medkit': 'Verbandskasten',
    'flare': 'Leuchtfackel',
    'trace': 'Spur des Schattens',
  };

  void _updateTarget() {
    final prog = _me?.channel?.progress ?? 0.0;
    if ((prog - channelProgress.value).abs() > 0.005) channelProgress.value = prog;
    final t = _computeTarget();
    final cur = target.value;
    if (t == null) {
      if (cur != null) target.value = null;
    } else if (!t.sameAs(cur)) {
      target.value = t;
    } else if (cur != null && (cur.x != t.x || cur.y != t.y)) {
      // gleiche Aktion, neue Position (NPC läuft) – ohne Benachrichtigung aktualisieren
      _targetPos = Offset(t.x, t.y);
      return;
    }
    _targetPos = t == null ? null : Offset(t.x, t.y);
  }

  Offset? _targetPos;

  ActionTarget? _computeTarget() {
    if (_fuehrung?.eingabeGesperrt == true) return null;
    final me = _me;
    final cv = session.caseView.value;
    final s = session.scenario;
    if (me == null || cv == null || s == null || !_hasPos) return null;
    if (!_actionPhase) return null;
    final ch = me.channel;
    if (ch != null) {
      return ActionTarget(id: '', label: 'Abbrechen', kind: 'cancel', x: _px, y: _py, name: '');
    }
    if (me.life == LifeState.downed) return null;
    const range = Tuning.interactRange;
    ActionTarget? best;
    var bestD = double.infinity;
    void consider(ActionTarget t, double d, [double bias = 0]) {
      if (d > range) return;
      if (d + bias < bestD) {
        bestD = d + bias;
        best = t;
      }
    }

    final ghost = me.life == LifeState.ghost;
    for (final e in cv.hotspots.entries) {
      final h = s.hotspotById[e.key];
      if (h == null) continue;
      if (me.hidden && h.kind != HotspotKind.hide) continue;
      if (e.value == HotspotState.searched && h.kind != HotspotKind.lab && h.kind != HotspotKind.hide) continue;
      if (_nebelSicht(h.x + 0.5, h.y + 0.5) < 0.5) continue;
      final label = _ext?.hotspotAktion(h.id) ?? switch (h.kind) {
        HotspotKind.search => 'Durchsuchen',
        HotspotKind.lab => 'Analysieren',
        HotspotKind.hide => me.hidden ? 'Rauskommen' : 'Verstecken',
        HotspotKind.body => 'Untersuchen',
        HotspotKind.blood => 'Untersuchen',
        _ => 'Untersuchen',
      };
      final prop = _scene?.propAt[Pt(h.x, h.y)]?.prop;
      final z = prop != null ? PropPainter.topZ(prop) : 0.0;
      final hx = h.x + 0.5, hy = h.y + 0.5;
      final d = dist(_px, _py, hx, hy);
      consider(
        ActionTarget(id: h.id, label: label, kind: h.kind, x: hx, y: hy, z: z, name: h.name.resolve()),
        me.hidden ? math.min(d, range - 0.01) : d,
      );
    }
    if (me.hidden) return best;
    if (!ghost) {
      final dead = cv.deadNpcs.toSet();
      final held = <String>{for (final c in cv.notebook) c.id, for (final c in cv.board) c.id};
      for (final n in _world?.npcs ?? const <NpcView>[]) {
        if (!n.alive || dead.contains(n.id)) {
          // Leiche durchsuchen (Engine: Suche nach den Hinweisen dieses NPCs),
          // solange er noch Hinweise hat, die wir nicht kennen.
          if (me.life != LifeState.alive) continue;
          if (!s.clues.any((d) => d.source.npc == n.id && !held.contains(d.id))) continue;
          final tr = _tracks['n:${n.id}'];
          final nx = tr?.x ?? n.x, ny = tr?.y ?? n.y;
          final sus = s.suspectById[n.id];
          consider(
            ActionTarget(
              id: n.id,
              label: 'Durchsuchen',
              kind: 'search',
              x: nx,
              y: ny,
              z: 0.2,
              name: sus?.name.resolve() ?? n.id,
            ),
            dist(_px, _py, nx, ny),
          );
          continue;
        }
        final ext = _ext;
        final aktion = ext == null ? 'Befragen' : ext.npcAktion(n.id);
        if (aktion == null) continue;
        final tr = _tracks['n:${n.id}'];
        final nx = tr?.x ?? n.x, ny = tr?.y ?? n.y;
        final sus = s.suspectById[n.id];
        consider(
          ActionTarget(
            id: n.id,
            label: aktion,
            // Eine Figur, die untersucht wird, bekommt die Lupe statt der Sprechblase (E-038).
            kind: ext != null && ext.npcUntersuchen(n.id) ? HotspotKind.search : 'npc',
            figur: true,
            x: nx,
            y: ny,
            z: 1.5,
            name: sus?.name.resolve() ?? n.id,
          ),
          dist(_px, _py, nx, ny),
          -0.05,
        );
      }
      for (final it in cv.items) {
        final isTrace = it.type == 'trace';
        consider(
          ActionTarget(
            id: it.id,
            label: isTrace ? 'Spur untersuchen' : 'Aufheben',
            kind: isTrace ? 'trace' : 'item',
            x: it.x,
            y: it.y,
            z: isTrace ? 0.1 : 0.5,
            name: _itemNames[it.type] ?? it.type,
          ),
          dist(_px, _py, it.x, it.y),
        );
      }
      if (me.life == LifeState.alive) {
        for (final d in _world?.detectives ?? const <DetectiveView>[]) {
          if (d.id == me.id || d.life != LifeState.downed) continue;
          final tr = _tracks['d:${d.id}'];
          final dx = tr?.x ?? d.x, dy = tr?.y ?? d.y;
          consider(
            ActionTarget(id: d.id, label: 'Wiederbeleben', kind: 'revive', x: dx, y: dy, z: 0.4, name: d.name),
            dist(_px, _py, dx, dy),
            -0.3,
          );
        }
      }
    }
    return best;
  }

  // --- kleine Effekte (Partymodus) ---
  final List<_Teilchen> _teilchen = [];
  double _stillT = 0, _blasenT = 0;
  final Map<String, double> _gagSperre = {};

  void _updateKleineEffekte(double dt) {
    final scene = _scene;
    if (scene == null || _ext?.kleineEffekte != true || !_hasPos) return;
    // Seifenblasen aus der Pfeife, wenn das Geburtstagskind kurz stillsteht.
    _stillT = _moveAmt < 0.08 ? _stillT + dt : 0;
    if (_stillT > 1.4 && _ext?.kamera == null) {
      _blasenT -= dt;
      if (_blasenT <= 0) {
        _blasenT = 0.35 + _rnd.nextDouble() * 0.5;
        final o = Iso.toScreen(_px, _py).translate(9 + _rnd.nextDouble() * 4, -40);
        _teilchen.add(_Teilchen(o.dx, o.dy, 4 + _rnd.nextDouble() * 8, -16 - _rnd.nextDouble() * 10, 2.2 + _rnd.nextDouble(), 2.2 + _rnd.nextDouble() * 2.4, const Color(0xFFE8F4FF), blase: true));
      }
    }
    // Gags an Rüstung und Kamin, höchstens alle 10 s je Stück.
    for (final p in scene.scenario.map.props) {
      if (p.type != 'party_ruestung' && p.type != 'party_kamin') continue;
      final k = '${p.type}@${p.x},${p.y}';
      _gagSperre[k] = math.max(0, (_gagSperre[k] ?? 0) - dt);
      if (_gagSperre[k]! > 0 || dist(_px, _py, p.x + 0.5, p.y + 0.5) > 1.7) continue;
      _gagSperre[k] = 10;
      if (p.type == 'party_ruestung') {
        // Das Visier klappert: Staub rieselt vom Helm, ein kurzes Blitzen.
        final o = Iso.toScreen(p.x + 0.5, p.y + 0.5, 1.45);
        for (var i = 0; i < 9; i++) {
          _teilchen.add(_Teilchen(o.dx + (_rnd.nextDouble() - 0.5) * 10, o.dy, (_rnd.nextDouble() - 0.5) * 14, 6 + _rnd.nextDouble() * 18, 1.2 + _rnd.nextDouble() * 0.6, 1.2, const Color(0xFFBFB8AA)));
        }
        _teilchen.add(_Teilchen(o.dx + 4, o.dy - 2, 0, 0, 0.45, 6, const Color(0xFFFFFFFF), wachsen: 18));
      } else {
        // Aus dem kalten Kamin pufft eine Rußwolke.
        final o = Iso.toScreen(p.x + 0.5, p.y + 0.9, 0.3);
        for (var i = 0; i < 14; i++) {
          _teilchen.add(_Teilchen(o.dx + (_rnd.nextDouble() - 0.5) * 18, o.dy, (_rnd.nextDouble() - 0.5) * 22, -10 - _rnd.nextDouble() * 22, 1.4 + _rnd.nextDouble() * 0.8, 3 + _rnd.nextDouble() * 3, const Color(0xFF3B3632), wachsen: 7));
        }
      }
    }
    for (var i = _teilchen.length - 1; i >= 0; i--) {
      final t = _teilchen[i];
      t.life += dt;
      t.x += t.vx * dt + (t.blase ? math.sin(t.life * 3 + i) * 6 * dt : 0);
      t.y += t.vy * dt;
      t.r += t.wachsen * dt;
      if (t.life >= t.max) _teilchen.removeAt(i);
    }
  }

  void _zeichneKleineEffekte(Canvas c) {
    for (final t in _teilchen) {
      final a = (1 - t.life / t.max).clamp(0.0, 1.0);
      final o = Offset(t.x, t.y);
      if (t.blase) {
        c.drawCircle(o, t.r, Paint()..color = withAlpha(t.farbe, 0.10 * a));
        c.drawCircle(
          o,
          t.r,
          Paint()
            ..color = withAlpha(t.farbe, 0.65 * a)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.7,
        );
        c.drawCircle(o.translate(-t.r * 0.35, -t.r * 0.35), t.r * 0.25, Paint()..color = withAlpha(const Color(0xFFFFFFFF), 0.8 * a));
      } else {
        c.drawCircle(o, t.r, Paint()..color = withAlpha(t.farbe, 0.75 * a));
      }
    }
  }

  void _updateEffects(double dt) {
    _updateKleineEffekte(dt);
    _actionPulse = math.max(0, _actionPulse - dt * 3);
    for (var i = _localPings.length - 1; i >= 0; i--) {
      _localPings[i].age += dt;
      if (_localPings[i].age > 1.6) _localPings.removeAt(i);
    }
    // Rauch des Schattens
    final sh = _tracks['shadow'];
    final shadowVisible = sh != null && _world?.shadow != null;
    if (shadowVisible) {
      final o = Iso.toScreen(sh.x, sh.y);
      final n = (dt * 26).ceil();
      for (var i = 0; i < n && _smoke.length < 42; i++) {
        _smoke.add(
          _Smoke(
            o.dx + (_rnd.nextDouble() - 0.5) * 26,
            o.dy - _rnd.nextDouble() * 10,
            (_rnd.nextDouble() - 0.5) * 10,
            -12 - _rnd.nextDouble() * 18,
            0.9 + _rnd.nextDouble() * 0.9,
            4 + _rnd.nextDouble() * 5,
          ),
        );
      }
    }
    for (var i = _smoke.length - 1; i >= 0; i--) {
      final p = _smoke[i];
      p.life += dt;
      p.x += p.vx * dt;
      p.y += p.vy * dt;
      p.r += dt * 6;
      if (p.life >= p.max) _smoke.removeAt(i);
    }
    // Blitze
    final theme = _scene!.scenario.theme;
    if (theme.lightning && _phase == Phase.night) {
      _nextFlash -= dt;
      if (_nextFlash <= 0) {
        _flashT = 0;
        _nextFlash = 6 + _rnd.nextDouble() * 9;
      }
    }
    if (_flashT >= 0) {
      _flashT += dt;
      final t = _flashT;
      _flash = t < 0.07
          ? 1.0
          : t < 0.14
          ? 0.25
          : t < 0.22
          ? 0.85
          : math.max(0.0, 0.85 * (1 - (t - 0.22) / 0.5));
      if (t > 0.75) {
        _flashT = -1;
        _flash = 0;
      }
    }
    // Wetter
    final room = _hasPos ? _grid?.roomAtPos(_px, _py) : null;
    final outdoor = room?.outdoor ?? false;
    final wk = _weather?.kind ?? 'none';
    final want = switch (wk) {
      'dust' => outdoor ? 1.0 : 0.55,
      'neon' => outdoor ? 1.0 : 0.35,
      _ => outdoor ? 1.0 : 0.0,
    };
    final camBefore = _lastCamForWeather;
    _lastCamForWeather = _cam;
    final pan = camBefore == null ? Offset.zero : (_cam - camBefore) * _zoom;
    _weather?.update(dt, Size(size.x, size.y), want, pan);
  }

  Offset? _lastCamForWeather;

  // ---------------------------------------------------------------------------
  // Render

  Offset _toView(Offset worldScreen) => (worldScreen - _cam) * _zoom + Offset(size.x / 2, size.y * _camY);

  @override
  void render(Canvas canvas) {
    final scene = _scene;
    final viewSize = Size(size.x, size.y);
    if (scene == null || viewSize.isEmpty) return;
    final markers = _markers!;
    final w = _world;
    final cv = session.caseView.value;
    final s = scene.scenario;
    final t = _time;
    final phase = _phase;

    canvas.save();
    canvas.translate(size.x / 2, size.y * _camY);
    canvas.scale(_zoom);
    canvas.translate(-_cam.dx, -_cam.dy);
    final view = Rect.fromCenter(
      center: _cam.translate(0, (0.5 - _camY) * size.y / _zoom),
      width: size.x / _zoom,
      height: size.y / _zoom,
    );
    final cull = view.inflate(48);

    // 1) Böden
    final floorPaint = Paint()..filterQuality = FilterQuality.medium;
    for (final f in scene.floors) {
      if (!f.dst.overlaps(cull)) continue;
      final img = f.image;
      if (img != null) {
        canvas.drawImageRect(img, Rect.fromLTWH(0, 0, img.width.toDouble(), img.height.toDouble()), f.dst, floorPaint);
      } else if (f.picture != null) {
        canvas.drawPicture(f.picture!);
      }
    }

    // 2) Bodendekor: Leichen, Niedergeschlagene, Spuren, Zielring
    _renderGround(canvas, scene, cv, cull);

    // 3) Tiefensortierte Objekte
    _renderSorted(canvas, scene, cv, cull);

    // 4) Licht
    final szLicht = _ext?.licht;
    if (szLicht != null) {
      _renderSzenenLicht(canvas, view, scene, szLicht, cull, t);
    } else {
      _renderPhasenLicht(canvas, view, scene, phase, s, cull, t);
    }

    // 4b) Nebel des Krieges (Partymodus)
    _renderNebel(canvas, scene);

    // 5) Über der Dunkelheit: Augen, Pings, Notsignale
    _renderPostLight(canvas, scene, w, cv, cull);
    canvas.restore();

    // 6) Wetter (Bildschirm)
    _weather?.render(canvas, viewSize, t);

    // 7) Bildschirm-Overlays: Namen, Blasen, Ringe, Ziel
    _renderOverlays(canvas, scene, w, markers);

    // 8) Vignette + Blitz
    final vr = Rect.fromLTWH(0, 0, size.x, size.y);
    final night = szLicht != null || phase == Phase.night;
    canvas.drawRect(
      vr,
      Paint()
        ..shader = Gradient.radial(
          vr.center,
          vr.longestSide * 0.72,
          [const Color(0x00000000), withAlpha(const Color(0xFF000000), night ? 0.62 : 0.38)],
          const [0.45, 1.0],
        ),
    );
    if (_flash > 0.01) {
      canvas.drawRect(vr, Paint()..color = withAlpha(const Color(0xFFE6EEFF), 0.22 * _flash));
    }
  }

  void _renderPhasenLicht(Canvas canvas, Rect view, StaticScene scene, Phase? phase, ScenarioDef s, Rect cull, double t) {
    final lightMode = phase == Phase.night
        ? LightMode.night
        : (phase == Phase.council || phase == Phase.accusation)
        ? LightMode.council
        : LightMode.day;
    _lighting!.render(
      canvas,
      view.inflate(4),
      mode: lightMode,
      darkness: lightMode == LightMode.night ? (1 - s.theme.nightAmbient).clamp(0.3, 0.97) : 0.42,
      lights: _lights(lightMode),
      litRooms: lightMode == LightMode.day
          ? const []
          : [
              for (final r in s.map.rooms)
                if (r.lit) r,
            ],
      glows: _glows(scene, cull, t),
      flash: _flash,
      dayTint: ((1 - s.theme.dayAmbient) * 0.55).clamp(0.0, 0.5),
    );
  }

  // ---------------------------------------------------------------------------
  // Szenen-Erweiterung (Partymodus, E-030): Licht nach Master 7.13, Nebel des
  // Krieges je Raum, Umrisse in der Rückblende. Ohne Erweiterung ungenutzt.

  GefuehrteSzene? get _fuehrung {
    final s = session;
    return s is GefuehrteSzene ? s as GefuehrteSzene : null;
  }

  SzenenErweiterung? get _ext {
    final s = session;
    return s is SzenenErweiterung ? s as SzenenErweiterung : null;
  }

  void _renderSzenenLicht(Canvas canvas, Rect view, StaticScene scene, SzenenLicht l, Rect cull, double t) {
    final lights = <SceneLight>[];
    if (l.taschenlampe && _hasPos) {
      lights.add(SceneLight(_px, _py, Tuning.nightLightRadius, cone: _pf));
      lights.add(SceneLight(_px, _py, 1.2, strength: 0.75));
    }
    final glows = _glows(scene, cull, t);
    for (final p in l.punkte) {
      final seed = (p.x * 3 + p.y * 7).round();
      final fl = 1 - p.flackern * 0.3 * (0.5 + 0.5 * math.sin(t * 7 + seed) * math.sin(t * 4.1 + seed * 2));
      lights.add(SceneLight(p.x, p.y, p.radius * fl, strength: 0.85));
      glows.add(GlowLight(p.x, p.y, p.z, p.radius * 0.55 * fl, p.farbe, fl));
    }
    _lighting!.render(
      canvas,
      view.inflate(4),
      mode: LightMode.night,
      darkness: l.dunkel.clamp(0.0, 1.0),
      lights: lights,
      litRooms: [
        for (final r in scene.scenario.map.rooms)
          if (l.helleRaeume.contains(r.id)) r,
      ],
      glows: glows,
      flash: 0,
      dayTint: 0,
    );
    // Umrisse und Hervorhebungen über der Dunkelheit (Rückblende)
    final ext = _ext!;
    for (final n in _world?.npcs ?? const <NpcView>[]) {
      final h = ext.hervorhebung(n.id);
      if (h == null) continue;
      final tr = _tracks['n:${n.id}'];
      if (tr == null || _nebelSicht(tr.x, tr.y) < 0.5) continue;
      final o = Iso.toScreen(tr.x, tr.y);
      if (!cull.contains(o)) continue;
      final sus = scene.scenario.suspectById[n.id];
      final look = sus != null ? FigureLook.fromLook(sus.look) : FigureLook.fromLook(const LookDef());
      if (h > 0) {
        canvas.save();
        canvas.translate(o.dx, o.dy);
        Iso.applyGround(canvas);
        final ph = 0.5 + 0.5 * math.sin(t * 3);
        canvas.drawCircle(
          Offset.zero,
          0.42 + 0.06 * ph,
          Paint()
            ..color = withAlpha(_pal.accent, 0.55 + 0.35 * ph)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.07,
        );
        canvas.restore();
      }
      canvas.saveLayer(Rect.fromCenter(center: o.translate(0, -30), width: 80, height: 90), Paint()..color = Color.fromRGBO(0, 0, 0, h > 0 ? 0.92 : 0.2));
      _fig.standing(canvas, o, look, facing: tr.facing, walk: tr.walk, moveAmt: tr.move, shadow: false);
      canvas.restore();
    }
  }

  /// Sichtbarkeit je Raum (0 schwarz … 1 sichtbar) mit radialem Aufblenden.
  final Map<String, _Nebel> _nebel = {};
  Set<String>? _sichtbar;

  void _updateNebel(double dt) {
    final ext = _ext;
    final scene = _scene;
    if (ext == null || scene == null || !_hasPos) {
      _sichtbar = null;
      return;
    }
    final sicht = ext.sichtbareRaeume(_px, _py);
    _sichtbar = sicht;
    if (sicht == null) return;
    for (final r in scene.scenario.map.rooms) {
      final n = _nebel.putIfAbsent(r.id, () => _Nebel(sicht.contains(r.id) ? 1 : 0));
      final soll = sicht.contains(r.id);
      if (soll) n.erinnert = true;
      if (soll && !n.offen) {
        n.offen = true;
        n.ursprung = Offset(_px, _py);
      } else if (!soll && n.offen) {
        n.offen = false;
        n.ursprung = null;
      }
      // 0,4 s bis zur vollen Sicht (Master 7.13).
      n.sicht = (n.sicht + (n.offen ? dt : -dt) / 0.4).clamp(0.0, 1.0);
    }
  }

  /// Sichtbarkeit an einer Kachelposition (1 ohne Nebel).
  double _nebelSicht(double x, double y) {
    if (_sichtbar == null) return 1;
    final s = session.scenario;
    if (s == null) return 1;
    for (final r in s.map.rooms) {
      if (x >= r.x && x < r.x + r.w && y >= r.y && y < r.y + r.h) return _nebel[r.id]?.sicht ?? 1;
    }
    return 1;
  }

  /// Weicher Schleier statt schwarzer Fläche: unbekannte Räume liegen zu
  /// höchstens 62 % im Dunst, bekannte zu 38 % ([nebelDeckkraft]).
  void _renderNebel(Canvas c, StaticScene scene) {
    if (_sichtbar == null) return;
    const wand = 1.6;
    final schleier = nebelSchleier(_pal);
    for (final r in scene.scenario.map.rooms) {
      final n = _nebel[r.id];
      if (n == null || n.sicht >= 0.999) continue;
      final deckkraft = nebelDeckkraft(n.sicht, erinnert: n.erinnert);
      if (deckkraft < 0.01) continue;
      // Boden randgenau, nur die hinteren Kanten (eigene Rückwände) angehoben.
      final x0 = r.x.toDouble(), y0 = r.y.toDouble(), x1 = (r.x + r.w).toDouble(), y1 = (r.y + r.h).toDouble();
      final a = Iso.toScreen(x0, y0), b = Iso.toScreen(x1, y0), d = Iso.toScreen(x1, y1), e = Iso.toScreen(x0, y1);
      final ah = Iso.toScreen(x0, y0, wand), bh = Iso.toScreen(x1, y0, wand), eh = Iso.toScreen(x0, y1, wand);
      final path = Path()
        ..moveTo(ah.dx, ah.dy)
        ..lineTo(bh.dx, bh.dy)
        ..lineTo(b.dx, b.dy)
        ..lineTo(d.dx, d.dy)
        ..lineTo(e.dx, e.dy)
        ..lineTo(eh.dx, eh.dy)
        ..close();
      // Weicher Rand statt harter Kante zwischen Schleier und sichtbarem Raum.
      final paint = Paint()..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      final u = n.ursprung;
      if (n.offen && u != null) {
        // Radialer Übergang von der Stelle, an der der Raum ins Sichtfeld kam.
        final o = Iso.toScreen(u.dx, u.dy);
        final weit = (a - d).distance + (b - e).distance;
        final rad = math.max(1.0, weit * n.sicht);
        final klar = schleier.withValues(alpha: 0);
        final voll = schleier.withValues(alpha: nebelDeckkraft(0, erinnert: n.erinnert));
        paint.shader = Gradient.radial(o, rad, [klar, klar, voll], const [0.0, 0.7, 1.0]);
      } else {
        paint.color = schleier.withValues(alpha: deckkraft);
      }
      c.drawPath(path, paint);
    }
  }

  void _renderGround(Canvas c, StaticScene scene, CaseView? cv, Rect cull) {
    final s = scene.scenario;
    final w = _world;
    // Opfer
    final vh = s.hotspotById[s.victim.hotspot];
    if (vh != null) {
      final o = Iso.toScreen(vh.x + 0.5, vh.y + 0.5);
      if (cull.contains(o)) {
        _fig.lying(c, vh.x + 0.5, vh.y + 0.5, FigureLook.fromLook(s.victim.look), rot: 0.5, chalk: true, scale: 1.35);
      }
    }
    // Tote NPCs
    final deadIds = <String>{...?cv?.deadNpcs};
    for (final n in w?.npcs ?? const <NpcView>[]) {
      if (!n.alive) deadIds.add(n.id);
    }
    final npcPos = {for (final n in w?.npcs ?? const <NpcView>[]) n.id: n};
    for (final id in deadIds) {
      final sus = s.suspectById[id];
      if (sus == null) continue;
      final tr = _tracks['n:$id'];
      final nv = npcPos[id];
      final x = tr?.x ?? nv?.x ?? sus.x + 0.5, y = tr?.y ?? nv?.y ?? sus.y + 0.5;
      if (!cull.contains(Iso.toScreen(x, y))) continue;
      _fig.lying(c, x, y, FigureLook.fromLook(sus.look), rot: 2.2 + (id.length % 3) * 0.7, scale: 1.25);
    }
    // Niedergeschlagene Detektive
    for (final d in w?.detectives ?? const <DetectiveView>[]) {
      if (d.life != LifeState.downed) continue;
      final isMe = d.id == session.playerId;
      final tr = _tracks['d:${d.id}'];
      final x = isMe ? _px : (tr?.x ?? d.x), y = isMe ? _py : (tr?.y ?? d.y);
      if (!cull.contains(Iso.toScreen(x, y))) continue;
      final pulse = 0.5 + 0.5 * math.sin(_time * 5);
      _fig.lying(
        c,
        x,
        y,
        FigureLook.detective(d.coat, d.hat, d.id),
        rot: 0.9,
        scale: 1.25,
        glow: withAlpha(_pal.danger, 0.35 + 0.35 * pulse),
      );
    }
    // Spuren des Schattens
    for (final it in cv?.items ?? const <ItemView>[]) {
      if (it.type != 'trace') continue;
      if (!cull.contains(Iso.toScreen(it.x, it.y))) continue;
      _markers!.traceGround(c, it.x, it.y, _time, it.id.hashCode % 7);
    }
    // Zielring
    final tp = _targetPos;
    final tg = target.value;
    if (tp != null && tg != null && !tg.isCancel) {
      _markers!.targetRing(c, tp.dx, tp.dy, _time);
    }
  }

  void _renderSorted(Canvas c, StaticScene scene, CaseView? cv, Rect cull) {
    final s = scene.scenario;
    final w = _world;
    final items = <(double, int, void Function())>[];
    // Verdeckungsrechteck des eigenen Spielers
    Rect? meRect;
    double meDepth = 0;
    if (_hasPos) {
      final o = Iso.toScreen(_px, _py);
      meRect = Rect.fromLTRB(o.dx - 13, o.dy - 58, o.dx + 13, o.dy + 2);
      meDepth = _px + _py;
    }
    final fade = math.min(1.0, _lastDt * 10);
    final cutK = math.min(1.0, _lastDt * 7);
    final room = _playerRoom;
    for (final d in scene.drawables) {
      if (!d.bounds.overlaps(cull)) continue;
      if (d.lowPicture != null) {
        final want = room != null && d.backRooms.contains(room) ? 1.0 : 0.0;
        d.cut += (want - d.cut) * cutK;
        if ((d.cut - want).abs() < 0.01) d.cut = want;
      }
      var targetAlpha = 1.0;
      if (d.tall && d.cut < 0.5 && meRect != null && d.depth > meDepth + 0.05 && d.occludes(meRect)) targetAlpha = 0.32;
      d.alpha += (targetAlpha - d.alpha) * fade;
      if ((d.alpha - targetAlpha).abs() < 0.01) d.alpha = targetAlpha;
      items.add((d.depth, 0, () => _drawStatic(c, d, scene)));
    }
    // Hotspots
    for (final e in cv?.hotspots.entries ?? const <MapEntry<String, String>>[]) {
      final h = s.hotspotById[e.key];
      if (h == null) continue;
      if (_nebelSicht(h.x + 0.5, h.y + 0.5) < 0.5) continue;
      final prop = scene.propAt[Pt(h.x, h.y)];
      final z = prop != null ? PropPainter.topZ(prop.prop!) + 0.22 : 0.42;
      final o = Iso.toScreen(h.x + 0.5, h.y + 0.5, z);
      if (!cull.contains(o)) continue;
      final seed = h.id.hashCode % 13;
      items.add((
        h.x + h.y + 1.0 + (prop != null ? 0.01 : 0),
        1,
        () => _markers!.hotspot(c, o, e.value, h.kind, _time, seed),
      ));
    }
    // Items (Spuren: nur der Rauchfaden steht im Raum)
    for (final it in cv?.items ?? const <ItemView>[]) {
      if (it.type == 'trace') {
        if (cull.contains(Iso.toScreen(it.x, it.y))) {
          items.add((it.x + it.y, 1, () => _markers!.traceSmoke(c, it.x, it.y, _time, it.id.hashCode % 7)));
        }
        continue;
      }
      final o = Iso.toScreen(it.x, it.y);
      if (!cull.contains(o)) continue;
      final seed = it.id.hashCode % 11;
      items.add((it.x + it.y, 1, () => _markers!.item(c, o, it.type, _time, seed)));
    }
    // NPCs
    final deadIds = <String>{...?cv?.deadNpcs};
    for (final n in w?.npcs ?? const <NpcView>[]) {
      if (!n.alive || deadIds.contains(n.id)) continue;
      final sus = s.suspectById[n.id];
      final tr = _tracks['n:${n.id}'];
      if (tr == null) continue;
      final o = Iso.toScreen(tr.x, tr.y);
      if (!cull.contains(o)) continue;
      if (_nebelSicht(tr.x, tr.y) < 0.02) continue;
      final look = sus != null ? FigureLook.fromLook(sus.look) : FigureLook.fromLook(const LookDef());
      final ruhe = _ext?.ruheAnimation == true && tr.move < 0.3 ? _time * (1.1 + (n.id.hashCode % 7) * 0.08) + n.id.hashCode % 13 : 0.0;
      items.add((tr.x + tr.y, 2, () => _fig.standing(c, o, look, facing: tr.facing, walk: tr.walk, moveAmt: tr.move, ruhe: ruhe)));
    }
    // Detektive
    for (final d in w?.detectives ?? const <DetectiveView>[]) {
      if (d.life == LifeState.downed) continue;
      final isMe = d.id == session.playerId;
      if (d.hidden && !isMe) continue;
      final tr = _tracks['d:${d.id}'];
      if (!isMe && tr == null) continue;
      if (isMe && _ext?.kamera != null) continue;
      final x = isMe ? _px : tr!.x, y = isMe ? _py : tr!.y;
      final o = Iso.toScreen(x, y);
      if (!cull.contains(o)) continue;
      final eigenesAussehen = isMe ? _ext?.detektivAussehen : null;
      final look = eigenesAussehen != null ? FigureLook.fromLook(eigenesAussehen) : FigureLook.detective(d.coat, d.hat, d.id);
      final facing = isMe ? _pf : tr!.facing;
      final walk = isMe ? _walk : tr!.walk;
      final move = isMe ? _moveAmt : tr!.move;
      final ghost = d.life == LifeState.ghost;
      items.add((
        x + y,
        2,
        () => _drawDetective(c, o, look, facing, walk, move, ghost: ghost, hidden: d.hidden, isMe: isMe),
      ));
    }
    // Schatten
    final sh = w?.shadow;
    final st = _tracks['shadow'];
    if (sh != null && st != null) {
      final o = Iso.toScreen(st.x, st.y);
      if (cull.contains(o)) {
        final alpha = sh.mode == 'flee' ? 0.3 + 0.15 * math.sin(_time * 9) : 1.0;
        items.add((
          st.x + st.y,
          2,
          () {
            _drawSmoke(c, alpha);
            _fig.shadowFigure(c, o, _time, facing: st.facing, mode: sh.mode, alpha: alpha);
          },
        ));
      }
    }
    items.sort((a, b) {
      final r = a.$1.compareTo(b.$1);
      return r != 0 ? r : a.$2.compareTo(b.$2);
    });
    for (final it in items) {
      it.$3();
    }
  }

  void _drawStatic(Canvas c, StaticDrawable d, StaticScene scene) {
    final pic = d.picture;
    if (pic == null) return;
    final faded = d.alpha < 0.99;
    if (faded) {
      c.saveLayer(d.bounds, Paint()..color = Color.fromRGBO(0, 0, 0, d.alpha));
    }
    final low = d.lowPicture;
    if (low != null && d.cut > 0.01) {
      c.drawPicture(low);
      if (d.cut < 0.99) {
        c.saveLayer(d.bounds, Paint()..color = Color.fromRGBO(0, 0, 0, 1 - d.cut));
        c.drawPicture(pic);
        c.restore();
      }
    } else {
      c.drawPicture(pic);
    }
    final p = d.prop;
    if (p != null && PropPainter.dynamicTypes.contains(p.type)) {
      scene.propPainter.paintDynamic(c, p, _time, east: d.east, night: _phase == Phase.night ? 1 : 0);
    }
    final wall = d.wall;
    if (wall != null && wall.hasWindowFace && d.cut < 0.5) {
      scene.wallPainter.paintWindowWeather(c, wall, scene.scenario.theme.weather, _time, _flash);
    }
    if (faded) c.restore();
  }

  void _drawDetective(
    Canvas c,
    Offset o,
    FigureLook look,
    double facing,
    double walk,
    double move, {
    required bool ghost,
    required bool hidden,
    required bool isMe,
  }) {
    if (isMe && !ghost && !hidden) {
      // dezenter Ring unter dem eigenen Detektiv
      c.save();
      c.translate(o.dx, o.dy);
      Iso.applyGround(c);
      c.drawCircle(
        Offset.zero,
        0.36,
        Paint()
          ..color = withAlpha(_pal.accent, 0.55)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.035,
      );
      c.restore();
    }
    if (ghost) {
      final float = math.sin(_time * 2.2) * 3 - 6;
      final rect = Rect.fromLTRB(o.dx - 30, o.dy - 90, o.dx + 30, o.dy + 10);
      c.saveLayer(
        rect,
        Paint()
          ..colorFilter = const ColorFilter.matrix([
            0.25, 0.25, 0.25, 0, 30, //
            0.3, 0.3, 0.3, 0, 50,
            0.35, 0.35, 0.35, 0, 90,
            0, 0, 0, 0.5, 0,
          ]),
      );
      c.drawCircle(
        o.translate(0, -30 + float),
        26,
        Paint()
          ..shader = Gradient.radial(o.translate(0, -30 + float), 26, [
            const Color(0x557FA8FF),
            const Color(0x007FA8FF),
          ]),
      );
      _fig.standing(c, o.translate(0, float), look, facing: facing, walk: walk, moveAmt: move * 0.3, ghost: true);
      c.restore();
      return;
    }
    if (hidden) {
      final rect = Rect.fromLTRB(o.dx - 30, o.dy - 80, o.dx + 30, o.dy + 10);
      c.saveLayer(rect, Paint()..color = const Color.fromRGBO(0, 0, 0, 0.32));
      _fig.standing(c, o, look, facing: facing, walk: walk, moveAmt: 0);
      c.restore();
      return;
    }
    final pose = isMe ? _fuehrung?.figurenPose : null;
    _fig.standing(c, o, look, facing: facing, walk: walk, moveAmt: move,
      suchen: pose == SzenenPose.suchen, befragen: pose == SzenenPose.befragen,
      handlungsZeit: _fuehrung?.bewegungReduziert == true ? 0 : _time,
    );
  }

  void _drawSmoke(Canvas c, double alpha) {
    final p = Paint();
    for (final s in _smoke) {
      final k = s.life / s.max;
      p.color = withAlpha(const Color(0xFF0A0812), (1 - k) * 0.55 * alpha);
      c.drawCircle(Offset(s.x, s.y), s.r, p);
    }
  }

  List<SceneLight> _lights(LightMode mode) {
    if (mode == LightMode.day) return const [];
    final out = <SceneLight>[];
    final w = _world;
    for (final d in w?.detectives ?? const <DetectiveView>[]) {
      final isMe = d.id == session.playerId;
      if (d.hidden && !isMe) continue;
      final tr = _tracks['d:${d.id}'];
      if (!isMe && tr == null) continue;
      final x = isMe ? _px : tr!.x, y = isMe ? _py : tr!.y;
      final f = isMe ? _pf : tr!.facing;
      if (mode == LightMode.council) {
        out.add(SceneLight(x, y, 5.5));
        continue;
      }
      switch (d.life) {
        case LifeState.alive:
          if (d.hidden) {
            out.add(SceneLight(x, y, 1.6, strength: 0.8));
          } else {
            final r = Tuning.nightLightRadius * _effectMul(d, (m) => m.light);
            out.add(SceneLight(x, y, math.max(0.8, r), cone: f));
          }
        case LifeState.downed:
          out.add(SceneLight(x, y, 1.3, strength: 0.7));
        case LifeState.ghost:
          if (isMe) out.add(SceneLight(x, y, 3.2, strength: 0.85));
      }
    }
    for (final lp in _localPings) {
      out.add(SceneLight(lp.x, lp.y, 1.0 * (1 - lp.age / 1.6), strength: 0.6));
    }
    return out;
  }

  List<GlowLight> _glows(StaticScene scene, Rect cull, double t) {
    final out = <GlowLight>[];
    for (final p in scene.lightProps) {
      final o = Iso.toScreen(p.x + 0.5, p.y + 0.5);
      if (!cull.inflate(200).contains(o)) continue;
      final l = scene.propPainter.light(p);
      if (l == null) continue;
      final seed = p.x * 3 + p.y * 7;
      final fl = 1 - l.flicker * 0.25 * (0.5 + 0.5 * math.sin(t * 9 + seed) * math.sin(t * 5.3 + seed * 2));
      out.add(GlowLight(p.x + 0.5, p.y + 0.5, l.z, l.radius * fl, l.color, fl));
    }
    return out;
  }

  void _renderPostLight(Canvas c, StaticScene scene, WorldSnapshot? w, CaseView? cv, Rect cull) {
    if (_teilchen.isNotEmpty) _zeichneKleineEffekte(c);
    // Augen des Schattens
    final sh = w?.shadow;
    final st = _tracks['shadow'];
    if (sh != null && st != null) {
      final o = Iso.toScreen(st.x, st.y);
      if (cull.contains(o) &&
          !_occluded(scene, Rect.fromCenter(center: o.translate(0, -51), width: 10, height: 6), st.x + st.y)) {
        final alpha = sh.mode == 'flee' ? 0.35 : 1.0;
        _fig.shadowEyes(c, o, _time, facing: st.facing, mode: sh.mode, alpha: alpha);
      }
    }
    // Glimmen der Spuren (nachts, wenn nicht verdeckt)
    if (_phase == Phase.night) {
      for (final it in cv?.items ?? const <ItemView>[]) {
        if (it.type != 'trace') continue;
        final o = Iso.toScreen(it.x, it.y);
        if (!cull.contains(o) || _occluded(scene, Rect.fromCenter(center: o, width: 8, height: 6), it.x + it.y)) {
          continue;
        }
        _markers!.traceGlow(c, it.x, it.y, _time, it.id.hashCode % 7);
      }
    }
    // Niedergeschlagene: roter Puls, auch im Dunkeln sichtbar
    for (final d in w?.detectives ?? const <DetectiveView>[]) {
      if (d.life != LifeState.downed) continue;
      final isMe = d.id == session.playerId;
      final tr = _tracks['d:${d.id}'];
      final x = isMe ? _px : (tr?.x ?? d.x), y = isMe ? _py : (tr?.y ?? d.y);
      final o = Iso.toScreen(x, y);
      if (!cull.contains(o)) continue;
      final ph = (_time * 0.8) % 1.0;
      c.save();
      c.translate(o.dx, o.dy);
      Iso.applyGround(c);
      c.drawCircle(
        Offset.zero,
        0.3 + ph * 0.6,
        Paint()
          ..color = withAlpha(_pal.danger, (1 - ph) * 0.8)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.05,
      );
      c.restore();
    }
    // Pings
    final recvAge = _time - _worldRecvT;
    for (final sg in w?.signals ?? const <SignalView>[]) {
      if (sg.kind != 'ping' || sg.x == null || sg.y == null) continue;
      final age = sg.ageMs / 1000 + recvAge;
      const life = Tuning.signalLifetimeMs / 1000;
      if (age > life) continue;
      if (!cull.contains(Iso.toScreen(sg.x!, sg.y!))) continue;
      _markers!.ping(c, sg.x!, sg.y!, age, life, _coatOf(sg.by) ?? _pal.accent);
    }
    for (final lp in _localPings) {
      final col = lp.ok ? _pal.accent : const Color(0xFF8A8A8A);
      c.save();
      final o = Iso.toScreen(lp.x, lp.y);
      c.translate(o.dx, o.dy);
      Iso.applyGround(c);
      final k = lp.age / 1.6;
      c.drawCircle(
        Offset.zero,
        0.2 + k * 1.1,
        Paint()
          ..color = withAlpha(col, (1 - k) * 0.9)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.06,
      );
      c.restore();
    }
  }

  /// Wird [r] (Bildschirm) von einem hohen statischen Objekt vor [depth] verdeckt?
  bool _occluded(StaticScene scene, Rect r, double depth) {
    for (final d in scene.drawables) {
      if (!d.tall || d.cut > 0.5 || d.depth <= depth + 0.05) continue;
      if (d.occludes(r)) return true;
    }
    return false;
  }

  Color? _coatOf(String id) {
    final d = _world?.detective(id);
    if (d == null) return null;
    return parseHex(detectiveCoats[d.coat.abs() % detectiveCoats.length]);
  }

  void _renderOverlays(Canvas c, StaticScene scene, WorldSnapshot? w, MarkerPainter m) {
    final headPx = 54.0 * _zoom;
    // Namensschilder und Kanal-Ringe; merkt sich die Oberkante für Sprechblasen.
    final stackTop = <String, Offset>{};
    final placed = <Rect>[];
    // Zielbeschriftung zuerst vermessen, damit Namensschilder darüber ausweichen
    // statt vom Banner verdeckt zu werden (gezeichnet wird sie zuletzt).
    final tg = target.value;
    final tp = _targetPos;
    Offset? targetAnchor;
    if (tg != null && tp != null && !tg.isCancel && tg.kind != 'revive' && tg.name.isNotEmpty) {
      final figur = tg.kind == 'npc' || tg.figur;
      final z = figur ? 0.0 : tg.z;
      final a = _toView(Iso.toScreen(tp.dx, tp.dy, z));
      targetAnchor = a.translate(0, figur ? -headPx - 10 : -18 * _zoom - 10);
      placed.add(m.targetLabelRect(targetAnchor, tg.name).inflate(1));
    }
    for (final d in w?.detectives ?? const <DetectiveView>[]) {
      final isMe = d.id == session.playerId;
      if (d.hidden && !isMe) continue;
      final tr = _tracks['d:${d.id}'];
      if (!isMe && tr == null) continue;
      final x = isMe ? _px : tr!.x, y = isMe ? _py : tr!.y;
      final feet = _toView(Iso.toScreen(x, y));
      if (feet.dx < -60 || feet.dy < -60 || feet.dx > size.x + 60 || feet.dy > size.y + 100) continue;
      final down = d.life == LifeState.downed;
      final ghostLift = d.life == LifeState.ghost ? 8 * _zoom : 0.0;
      var top = down
          ? feet.translate(0, -16 * _zoom)
          : feet.translate(0, -headPx - (d.hat == 'top' ? 12 : 4) * _zoom - ghostLift);
      if (!isMe) {
        final col = parseHex(detectiveCoats[d.coat.abs() % detectiveCoats.length]) ?? _pal.accent;
        // Überlappende Schilder nach oben schieben.
        var anchor = top.translate(0, -4);
        for (var guard = 0; guard < 4; guard++) {
          final r = Rect.fromCenter(center: anchor.translate(0, -9), width: 70, height: 18);
          final hit = placed.where((p) => p.overlaps(r)).toList();
          if (hit.isEmpty) break;
          anchor = Offset(anchor.dx, hit.map((h) => h.top).reduce(math.min) - 2);
        }
        placed.add(Rect.fromCenter(center: anchor.translate(0, -9), width: 70, height: 18));
        m.nameTag(c, anchor, d.name, col, alpha: d.life == LifeState.ghost ? 0.5 : (d.connected ? 1 : 0.55));
        top = Offset(top.dx, anchor.dy - 20);
      }
      final ch = d.channel;
      if (ch != null) {
        m.channelRing(c, top.translate(0, -12), ch.progress, _pal.accent);
        top = top.translate(0, -26);
      }
      stackTop[d.id] = top;
    }
    // Sprechende NPCs
    for (final n in w?.npcs ?? const <NpcView>[]) {
      if (n.talkingTo == null || !n.alive) continue;
      final tr = _tracks['n:${n.id}'];
      if (tr == null) continue;
      final top = _toView(Iso.toScreen(tr.x, tr.y)).translate(0, -headPx - 6 * _zoom);
      m.bubble(c, top, 'quick', '...', 0.9, 0.75);
    }
    // Emotes / Schnellchat
    final recvAge = _time - _worldRecvT;
    for (final sg in w?.signals ?? const <SignalView>[]) {
      if (sg.kind != 'emote' && sg.kind != 'quick') continue;
      final age = sg.ageMs / 1000 + recvAge;
      const life = Tuning.signalLifetimeMs / 1000;
      if (age > life) continue;
      final top = stackTop[sg.by];
      if (top == null) continue;
      var anchor = top.translate(0, -2);
      for (var guard = 0; guard < 4; guard++) {
        final r = Rect.fromLTRB(anchor.dx - 18, anchor.dy - 36, anchor.dx + 18, anchor.dy);
        final hit = placed.where((p) => p.overlaps(r)).toList();
        if (hit.isEmpty) break;
        anchor = Offset(anchor.dx, hit.map((h) => h.top).reduce(math.min) - 2);
      }
      placed.add(Rect.fromLTRB(anchor.dx - 18, anchor.dy - 36, anchor.dx + 18, anchor.dy));
      final alpha = (life - age).clamp(0.0, 1.0);
      final pop = age < 0.25 ? _easeOutBack(age / 0.25) : 1.0;
      m.bubble(c, anchor, sg.kind, sg.value, alpha, pop);
    }
    // Zielbeschriftung
    if (tg != null && targetAnchor != null) m.targetLabel(c, targetAnchor, tg.name, 1);
  }

  double _easeOutBack(double x) {
    const c1 = 1.70158, c3 = c1 + 1;
    return 1 + c3 * math.pow(x - 1, 3) + c1 * math.pow(x - 1, 2);
  }
}
