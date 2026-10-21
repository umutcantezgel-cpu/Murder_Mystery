import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mordakte_core/mordakte_core.dart';

import '../game/game_view.dart';
import '../stil/mappe/material.dart' show PapierMaler;
import '../stil/stil.dart';
import 'daten.dart';
import 'dia_session.dart';

/// Ein Bild der Diashow zur Einleitung (Langer Abend M4) als großer
/// Fotoabzug: weißer Rand, leicht schräg, darin die Szene aus der Engine
/// ([DiaSession], eine einzige GameView für alle Bilder). Aufbau wie die
/// Rückblende (`rueckblende_ansicht.dart`): dunkle Fläche, die Szene im
/// ClipRect, keine Steuerung.
///
/// - Ein neues Bild blendet über Schwarz über; die Kamera fährt in der Blende
///   zum neuen Ort.
/// - Während des Bildes fährt die Kamera langsam heran, zurück oder schwenkt
///   (Fahrt des Dias). Mit „Bewegung reduzieren“ steht alles still, der
///   Wechsel ist ein Schnitt.
/// - Rückblicke sind sepiagetönt. Steht der Detektiv im Bild, steckt sein
///   Fotoabzug am Rand (er hat keine Figur in der Szene).
/// - Kein Text im Bild; [beschriftung] liest nur der Bildschirmleser.
class DiashowAnsicht extends StatefulWidget {
  const DiashowAnsicht({super.key, required this.daten, required this.nr, this.beschriftung, this.testUhr});

  /// Akte mit Diashow ([PartyDaten.diashow] gesetzt).
  final PartyDaten daten;

  /// Bild (ab 0).
  final int nr;

  /// Für den Bildschirmleser, etwa „Bild 2 von 6“.
  final String? beschriftung;

  /// Feste Uhr der Fahrt (Kontaktbogen, Tests).
  final double Function()? testUhr;

  @override
  State<DiashowAnsicht> createState() => _DiashowAnsichtState();
}

class _DiashowAnsichtState extends State<DiashowAnsicht> with TickerProviderStateMixin {
  late final Diashow _show = widget.daten.diashow!;
  late final DiaSession _session = DiaSession(widget.daten, _show, nr: widget.nr, testUhr: widget.testUhr);

  /// Blende zwischen zwei Bildern: 0 klar, 1 schwarz.
  late final AnimationController _blende = AnimationController(vsync: this);

  /// Langsame Fahrt während eines Bildes (Zoom), 0 bis 1.
  late final AnimationController _fahrt = AnimationController(vsync: this, duration: Duration(milliseconds: (DiaSession.fahrtSekunden * 1000).round()));

  late int _gezeigt = widget.nr.clamp(0, _show.dias.length - 1);
  int _lauf = 0;
  bool _ruhig = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _ruhig = MBewegung.ruhig(context);
    _session.bewegungReduziert = _ruhig;
    if (_ruhig) {
      _fahrt.value = 0;
    } else if (!_fahrt.isAnimating && _fahrt.value == 0 && widget.testUhr == null) {
      unawaited(_fahrt.forward());
    }
  }

  @override
  void didUpdateWidget(DiashowAnsicht alt) {
    super.didUpdateWidget(alt);
    final nr = widget.nr.clamp(0, _show.dias.length - 1);
    if (nr != _gezeigt) unawaited(_wechsle(nr));
  }

  /// Zum Bild [nr]: über Schwarz (oder als Schnitt bei „Bewegung reduzieren“).
  /// Kommt währenddessen ein weiteres Bild, gilt das jüngste.
  Future<void> _wechsle(int nr) async {
    final lauf = ++_lauf;
    if (!_ruhig) {
      await _blende.animateTo(1, duration: const Duration(milliseconds: 220), curve: Curves.easeIn).orCancel.catchError((Object _) {});
      if (!mounted || lauf != _lauf) return;
    }
    setState(() => _gezeigt = nr);
    _session.zeige(nr);
    if (_ruhig) {
      _blende.value = 0;
      return;
    }
    _fahrt.value = 0;
    if (widget.testUhr == null) unawaited(_fahrt.forward());
    await _blende.animateTo(0, duration: const Duration(milliseconds: 380), curve: Curves.easeOut).orCancel.catchError((Object _) {});
  }

  @override
  void dispose() {
    _blende.dispose();
    _fahrt.dispose();
    unawaited(_session.dispose());
    super.dispose();
  }

  /// Vergrößerung zur Fahrt [t]: der Zoom des Dias, heran oder zurück um ein Achtel.
  static double _skala(DiaKamera k, double t) => k.zoom * switch (k.fahrt) {
        DiaFahrt.heran => 1 + 0.12 * t,
        DiaFahrt.zurueck => 1.12 - 0.12 * t,
        _ => 1.0,
      };

  /// Sepia für den Rückblick, zu drei Vierteln über dem Original.
  static const _sepia = ColorFilter.matrix(<double>[
    0.545, 0.577, 0.142, 0, 0, //
    0.262, 0.765, 0.126, 0, 0,
    0.204, 0.401, 0.348, 0, 0,
    0, 0, 0, 1, 0,
  ]);

  @override
  Widget build(BuildContext context) {
    final dia = _show.dias[_gezeigt];
    final kanon = widget.daten.kanon;
    final detektiv = (kanon.figurenJson['detektiv'] as Map)['id'] as String;
    final mitDetektiv = dia.figuren.contains(detektiv);
    final neigung = _gezeigt.isEven ? -0.012 : 0.01;

    Widget szene = AnimatedBuilder(
      animation: _fahrt,
      builder: (context, kind) {
        final t = widget.testUhr != null ? (widget.testUhr!() / DiaSession.fahrtSekunden).clamp(0.0, 1.0) : _fahrt.value;
        return Transform.scale(scale: _skala(dia.kamera, _ruhig ? 0 : t), child: kind);
      },
      child: GameView(key: const ValueKey('dia-szene'), session: _session, steuerung: false),
    );
    if (dia.stimmung == DiaStimmung.rueckblick) szene = ColorFiltered(colorFilter: _sepia, child: szene);
    final bild = ClipRect(
      child: Stack(
        fit: StackFit.expand,
        children: [
          const ColoredBox(color: Color(0xFF0B0A0E)),
          szene,
          // Die Blende liegt über der Szene, nie über dem Rand des Abzugs.
          IgnorePointer(
            child: AnimatedBuilder(
              animation: _blende,
              builder: (context, _) => ColoredBox(color: Colors.black.withValues(alpha: _blende.value)),
            ),
          ),
        ],
      ),
    );

    final abzug = DecoratedBox(
      decoration: const BoxDecoration(boxShadow: [BoxShadow(color: Color(0x99000000), blurRadius: 16, offset: Offset(0, 8))]),
      child: CustomPaint(
        painter: const PapierMaler(art: PapierArt.foto, flecken: false),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 22),
          child: AspectRatio(
            aspectRatio: 3 / 2,
            child: DecoratedBox(
              position: DecorationPosition.foreground,
              decoration: BoxDecoration(border: Border.all(color: Colors.black.withValues(alpha: 0.22))),
              child: MFlaeche.dunkel(child: bild),
            ),
          ),
        ),
      ),
    );

    return Semantics(
      key: const ValueKey('diashow'),
      container: true,
      image: true,
      label: widget.beschriftung,
      excludeSemantics: true,
      child: Padding(
        // Platz für die Schräge und den gesteckten Abzug.
        padding: const EdgeInsets.fromLTRB(6, 6, 6, 14),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Transform.rotate(angle: neigung, child: abzug),
            if (mitDetektiv)
              Positioned(
                right: 4,
                bottom: -6,
                child: MFotoabzug(
                  look: LookDef.fromJson(renderLook(kanon.figur(detektiv)!)),
                  groesse: 64,
                  neigung: 0.09,
                  klammer: true,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
