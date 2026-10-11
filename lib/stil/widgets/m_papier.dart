import 'package:flutter/material.dart';

import '../tokens.dart';

/// Pergamentkarte mit Tinte in Schreibmaschinenschrift, wie ein Aktenblatt.
/// Mit [stempel] liegt ein schräger roter Stempel auf der oberen Kante.
class MPapier extends StatelessWidget {
  const MPapier({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(MMass.s16),
    this.stempel,
    this.neigung = 0,
  });

  final Widget child;
  final EdgeInsets padding;

  /// Text des Stempels (wird in Großbuchstaben gesetzt).
  final String? stempel;

  /// Drehung des ganzen Blatts in Bogenmaß (klein halten, z. B. −0,02).
  final double neigung;

  @override
  Widget build(BuildContext context) {
    final f = MFarben.von(context);
    Widget blatt = Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [f.papier, Color.lerp(f.papier, f.papierLeise, 0.4)!],
        ),
        borderRadius: BorderRadius.circular(MMass.r6),
        border: Border.all(color: f.tinte.withValues(alpha: 0.25)),
        boxShadow: const [BoxShadow(color: Color(0x66000000), blurRadius: 14, offset: Offset(0, 6))],
      ),
      child: DefaultTextStyle.merge(
        style: TextStyle(fontFamily: MRohSchrift.anzeige, fontSize: 16, height: 1.45, letterSpacing: 0.2, color: f.tinte),
        child: child,
      ),
    );
    if (stempel != null) {
      blatt = Stack(
        clipBehavior: Clip.none,
        children: [
          blatt,
          Positioned(top: -8, right: MMass.s12, child: _Stempel(text: stempel!, farbe: f.gefahr)),
        ],
      );
    }
    return neigung == 0 ? blatt : Transform.rotate(angle: neigung, child: blatt);
  }
}

class _Stempel extends StatelessWidget {
  const _Stempel({required this.text, required this.farbe});

  final String text;
  final Color farbe;

  @override
  Widget build(BuildContext context) => Transform.rotate(
        angle: -0.14,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: const Color(0x14000000),
            border: Border.all(color: farbe.withValues(alpha: 0.85), width: 2),
            borderRadius: BorderRadius.circular(MMass.r6 / 2),
          ),
          child: Text(
            text.toUpperCase(),
            style: TextStyle(
              fontFamily: MRohSchrift.anzeige,
              fontSize: 12,
              letterSpacing: 2,
              color: farbe.withValues(alpha: 0.85),
            ),
          ),
        ),
      );
}
