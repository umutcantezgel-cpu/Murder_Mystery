import 'package:flutter/material.dart';

import '../mappe/material.dart';
import '../tokens.dart';

/// Hintergrund des Spiels: der Schreibtisch der Detektei bei Nacht.
///
/// Dunkles Leder mit Körnung im Tinten-Violett der Akte, warmer Schein der
/// Schreibtischlampe von oben, eine weiche Vignette. Nichts darin bewegt sich.
class MHintergrund extends StatelessWidget {
  const MHintergrund({super.key, required this.child, this.koernung = true});

  final Widget child;

  /// Lederkörnung ein; sie wird nur einmal gezeichnet und gecacht.
  final bool koernung;

  @override
  Widget build(BuildContext context) {
    final f = MFarben.von(context);
    final unten = Color.lerp(MRoh.leder, f.grund, 0.55)!;
    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color.lerp(f.nachtOben, MRoh.leder, 0.35)!, unten, Color.lerp(unten, MRoh.schwarz, 0.4)!],
              stops: const [0, 0.55, 1],
            ),
          ),
        ),
        if (koernung) RepaintBoundary(child: CustomPaint(painter: LederMaler(schein: f.schein))),
        // Weiche Vignette.
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              radius: 1.1,
              colors: [MRoh.schwarz.withValues(alpha: 0), MRoh.schwarz.withValues(alpha: 0.6)],
              stops: const [0.55, 1],
            ),
          ),
        ),
        child,
      ],
    );
  }
}
