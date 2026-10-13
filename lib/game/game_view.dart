import 'dart:async';
import 'dart:math' as math;

import 'package:flame/game.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../session/game_session.dart';
import 'input/action_button.dart';
import 'input/joystick.dart';
import 'mordakte_game.dart';
import 'szenen_erweiterung.dart' show SzenenRand, SzenenUmgebung;

/// Die 2.5D-Spielszene (Flame) inkl. Joystick, Aktionsknopf und Tastatur.
///
/// Vertrag für die UI: `GameView(session: s)` füllt den verfügbaren Platz.
/// Interaktionen laufen ausschließlich über [GameSession.send]/[GameSession.move];
/// Dialoge, Beweiswand usw. öffnet die UI als Reaktion auf Session-Ereignisse.
///
/// Reservierte Zonen: Joystick = linke 45 % der unteren 60 % (Ursprung dort,
/// wo der Daumen aufsetzt), Aktionsknopf = unten rechts (88 px, 24 px Rand).
/// Langes Drücken auf die Karte außerhalb des Joysticks setzt einen Ping.
class GameView extends StatefulWidget {
  const GameView({
    super.key,
    required this.session,
    this.steuerung = true,
    this.kameraPassend = false,
    this.sichtRand = SzenenRand.keiner,
    this.umgebung,
  });

  final GameSession session;

  /// Zoom und Ausschnitt folgen Detektiv und Zielen (Partykarte); die Sitzung
  /// braucht dafür [SzenenKamera]. Pinch-Zoom wirkt weiter darauf.
  final bool kameraPassend;

  /// Vom Bedienfeld verdeckter Teil des Bildes (Pixel); der Ausschnitt liegt im Rest.
  final SzenenRand sichtRand;

  /// Hintergrund außerhalb der Karte statt reinem Schwarz.
  final SzenenUmgebung? umgebung;

  /// Joystick, Aktionsknopf und Eingabe; `false` für reine Ansichten
  /// (Rückblende im Partymodus).
  final bool steuerung;

  @override
  State<GameView> createState() => _GameViewState();
}

class _GameViewState extends State<GameView> {
  late MordakteGame _game;
  final FocusNode _focus = FocusNode(debugLabel: 'MordakteScene');
  final JoystickState _joy = JoystickState();

  // Nicht-Joystick-Finger: Ping (langes Drücken) und Pinch-Zoom.
  final Map<int, Offset> _touches = {};
  final Map<int, Offset> _touchStart = {};
  Timer? _longPress;
  double? _pinchStartDist;
  double _pinchStartZoom = 1;

  // Tippen erkennen: kurzer Druck ohne nennenswerte Bewegung (auch in der Joystick-Zone).
  final Map<int, DateTime> _downZeit = {};
  final Map<int, double> _weiteste = {};
  Offset? _joyStart;

  static const double _buttonSize = 88;
  static const double _buttonMargin = 24;

  @override
  void initState() {
    super.initState();
    _game = _createGame(widget.session);
    _joy.addListener(_onJoy);
  }

  MordakteGame _createGame(GameSession s) => MordakteGame(session: s)
    ..focusNode = _focus
    ..kameraPassend = widget.kameraPassend
    ..sichtRand = widget.sichtRand
    ..umgebung = widget.umgebung;

  @override
  void didUpdateWidget(GameView old) {
    super.didUpdateWidget(old);
    _game
      ..kameraPassend = widget.kameraPassend
      ..sichtRand = widget.sichtRand
      ..umgebung = widget.umgebung;
    if (!identical(old.session, widget.session)) {
      final prev = _game;
      _game = _createGame(widget.session);
      WidgetsBinding.instance.addPostFrameCallback((_) => prev.dispose());
    }
  }

  @override
  void dispose() {
    _longPress?.cancel();
    _joy.removeListener(_onJoy);
    _joy.dispose();
    _game.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _onJoy() => _game.stick = _joy.vector;

  bool _inJoystickZone(Offset p, Size size) => p.dx < size.width * 0.45 && p.dy > size.height * 0.4;

  void _onDown(PointerDownEvent e, Size size) {
    if (!_focus.hasFocus) _focus.requestFocus();
    final p = e.localPosition;
    _downZeit[e.pointer] = DateTime.now();
    _weiteste[e.pointer] = 0;
    if (!_joy.active && _inJoystickZone(p, size)) {
      _joy.start(e.pointer, p);
      _joyStart = p;
      return;
    }
    _touches[e.pointer] = p;
    _touchStart[e.pointer] = p;
    if (_touches.length == 1) {
      _longPress?.cancel();
      final id = e.pointer;
      _longPress = Timer(const Duration(milliseconds: 520), () {
        final at = _touches[id];
        if (at == null || _touches.length != 1) return;
        final ok = _game.ping(at);
        HapticFeedback.mediumImpact();
        if (!ok) HapticFeedback.lightImpact();
      });
    } else if (_touches.length == 2) {
      _longPress?.cancel();
      final pts = _touches.values.toList();
      _pinchStartDist = (pts[0] - pts[1]).distance;
      _pinchStartZoom = _game.userZoom;
    }
  }

  void _onMove(PointerMoveEvent e) {
    if (e.pointer == _joy.pointer) {
      final s = _joyStart;
      if (s != null) _weiteste[e.pointer] = math.max(_weiteste[e.pointer] ?? 0, (e.localPosition - s).distance);
      // Der Joystick greift erst, wenn der Finger wirklich zieht; ein Tipp bleibt ein Tipp.
      if ((_weiteste[e.pointer] ?? 0) > 12) _joy.move(e.localPosition);
      return;
    }
    final start0 = _touchStart[e.pointer];
    if (start0 != null) _weiteste[e.pointer] = math.max(_weiteste[e.pointer] ?? 0, (e.localPosition - start0).distance);
    if (!_touches.containsKey(e.pointer)) return;
    _touches[e.pointer] = e.localPosition;
    final start = _touchStart[e.pointer];
    if (start != null && (e.localPosition - start).distance > 14) _longPress?.cancel();
    final d0 = _pinchStartDist;
    if (_touches.length >= 2 && d0 != null && d0 > 10) {
      final pts = _touches.values.toList();
      final d = (pts[0] - pts[1]).distance;
      _game.userZoom = (_pinchStartZoom * d / d0).clamp(0.6, 1.8);
    }
  }

  /// War der Druck [pointer] ein kurzer Tipp ohne Ziehen?
  bool _warTipp(int pointer) {
    final t = _downZeit.remove(pointer);
    final weit = _weiteste.remove(pointer) ?? 0;
    return t != null && weit <= 12 && DateTime.now().difference(t) < const Duration(milliseconds: 380) && _touches.length <= 1;
  }

  void _onUp(int pointer, [Offset? wo]) {
    final tipp = _warTipp(pointer);
    if (pointer == _joy.pointer) {
      _joy.end();
      final start = _joyStart;
      _joyStart = null;
      if (tipp && start != null) _game.tippen(wo ?? start);
      return;
    }
    if (tipp && wo != null && _pinchStartDist == null) {
      _longPress?.cancel();
      _game.tippen(wo);
    }
    _touches.remove(pointer);
    _touchStart.remove(pointer);
    if (_touches.length < 2) _pinchStartDist = null;
    if (_touches.isEmpty) _longPress?.cancel();
  }

  void _onSignal(PointerSignalEvent e) {
    if (e is PointerScrollEvent) {
      _game.userZoom = (_game.userZoom * math.exp(-e.scrollDelta.dy * 0.0015)).clamp(0.6, 1.8);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.paddingOf(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        final rest = Offset(
          _buttonMargin + pad.left + JoystickState.radius + 14,
          size.height - _buttonMargin - pad.bottom - JoystickState.radius - 14,
        );
        return Stack(
          fit: StackFit.expand,
          children: [
            GameWidget(
              key: ObjectKey(_game),
              game: _game,
              focusNode: _focus,
              autofocus: widget.steuerung,
            ),
            if (widget.steuerung) Listener(
              behavior: HitTestBehavior.opaque,
              onPointerDown: (e) => _onDown(e, size),
              onPointerMove: _onMove,
              onPointerUp: (e) => _onUp(e.pointer, e.localPosition),
              onPointerCancel: (e) {
                _downZeit.remove(e.pointer);
                _weiteste.remove(e.pointer);
                _onUp(e.pointer);
              },
              onPointerSignal: _onSignal,
              child: CustomPaint(
                painter: JoystickPainter(_joy, rest, _game.palette.accent),
                size: size,
              ),
            ),
            if (widget.steuerung)
              Positioned(
                right: _buttonMargin + pad.right,
                bottom: _buttonMargin + pad.bottom,
                width: _buttonSize,
                height: _buttonSize,
                child: ActionButton(game: _game, size: _buttonSize),
              ),
          ],
        );
      },
    );
  }
}
