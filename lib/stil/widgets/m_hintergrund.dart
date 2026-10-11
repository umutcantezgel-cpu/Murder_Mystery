import 'package:flutter/material.dart';

import '../../ui/widgets/noir_backdrop.dart' show GrainPainter;
import '../tokens.dart';

/// Hintergrund des Spiels: Nachtverlauf in Tinten-Violett, warmer Kerzenschein
/// am oberen Rand, feine Körnung und eine weiche Vignette. Nichts darin
/// bewegt sich, auch nicht ohne „Bewegung reduzieren“.
class MHintergrund extends StatelessWidget {
  const MHintergrund({super.key, required this.child, this.koernung = true});

  final Widget child;

  /// Körnung ein; sie wird nur einmal gezeichnet und gecacht.
  final bool koernung;

  @override
  Widget build(BuildContext context) {
    final f = MFarben.von(context);
    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [f.nachtOben, f.grund, f.grund],
              stops: const [0, 0.6, 1],
            ),
          ),
        ),
        // Warmer Kerzenschein oben.
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(0, -1.2),
              radius: 1.05,
              colors: [f.schein.withValues(alpha: 0.17), f.schein.withValues(alpha: 0)],
            ),
          ),
        ),
        if (koernung) const RepaintBoundary(child: CustomPaint(painter: GrainPainter(opacity: 0.035, density: 0.0018))),
        // Weiche Vignette.
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              radius: 1.1,
              colors: [MRoh.schwarz.withValues(alpha: 0), MRoh.schwarz.withValues(alpha: 0.55)],
              stops: const [0.6, 1],
            ),
          ),
        ),
        child,
      ],
    );
  }
}
