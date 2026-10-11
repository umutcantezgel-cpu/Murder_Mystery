import 'package:flutter/material.dart';

import '../tokens.dart';

/// Tafel: dunkle Schieferfläche für zusammengehörige Inhalte, mit einer
/// Pergament-Haarlinie am Rand und einem hellen Glanz innen am oberen Rand.
class MTafel extends StatelessWidget {
  const MTafel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.akzent,
    this.hervorgehoben = false,
  });

  final Widget child;
  final EdgeInsets padding;

  /// Farbiger linker Rand (z. B. Farbcode einer Figur).
  final Color? akzent;

  /// Hellere Fläche und stärkere Linie (z. B. gewählte Karte).
  final bool hervorgehoben;

  @override
  Widget build(BuildContext context) {
    final f = MFarben.von(context);
    final flaeche = hervorgehoben ? f.flaecheHoch : f.flaeche;
    final Widget inhalt = akzent == null
        ? Padding(padding: padding, child: child)
        : IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(width: 6, color: akzent),
                Expanded(child: Padding(padding: padding, child: child)),
              ],
            ),
          );
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [flaeche, Color.lerp(flaeche, f.grund2, 0.5)!],
        ),
        borderRadius: BorderRadius.circular(MMass.r14),
        border: Border.all(color: hervorgehoben ? f.linieStark : f.linie),
        boxShadow: const [BoxShadow(color: Color(0x66000000), blurRadius: 18, offset: Offset(0, 6))],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          inhalt,
          // Heller Glanz innen am oberen Rand.
          Positioned(
            top: 0,
            left: MMass.r14,
            right: MMass.r14,
            height: 1,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [f.papier.withValues(alpha: 0), f.papier.withValues(alpha: 0.22), f.papier.withValues(alpha: 0)]),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
