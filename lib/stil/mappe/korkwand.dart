import 'package:flutter/material.dart';

import '../tokens.dart';
import 'material.dart';
import 'zeichen.dart';

/// Ein Zettel an der Korkwand: Inhalt, Lage (0–1 in der Wand) und Neigung.
class Pinnzettel {
  const Pinnzettel({required this.id, required this.kind, required this.lage, this.neigung = 0, this.breite = 150});

  final String id;
  final Widget kind;

  /// Mittelpunkt relativ zur Wand (0,0 oben links bis 1,1 unten rechts).
  final Offset lage;
  final double neigung;
  final double breite;
}

/// Ein roter Faden zwischen zwei Zetteln.
class Faden {
  const Faden(this.von, this.zu, {this.farbe = const Color(0xFFB0202C)});

  final String von;
  final String zu;
  final Color farbe;
}

/// Korkwand mit angepinnten Zetteln und roten Fäden: die Pinnwand der Ermittler.
class MKorkwand extends StatelessWidget {
  const MKorkwand({super.key, required this.zettel, this.faeden = const [], this.hoehe = 360});

  final List<Pinnzettel> zettel;
  final List<Faden> faeden;
  final double hoehe;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: hoehe,
        child: LayoutBuilder(
          builder: (context, b) {
            final groesse = Size(b.maxWidth, hoehe);
            Offset mitte(Pinnzettel z) => Offset(z.lage.dx * groesse.width, z.lage.dy * groesse.height);
            final nachId = {for (final z in zettel) z.id: z};
            return DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: MRoh.korkDunkel, width: 8),
                boxShadow: const [BoxShadow(color: Color(0x88000000), blurRadius: 16, offset: Offset(0, 8))],
              ),
              child: ClipRect(
                child: CustomPaint(
                  painter: const KorkMaler(),
                  foregroundPainter: _FadenMaler([
                    for (final f in faeden)
                      if (nachId[f.von] != null && nachId[f.zu] != null) (mitte(nachId[f.von]!) - const Offset(0, 0), mitte(nachId[f.zu]!), f.farbe),
                  ]),
                  child: Stack(
                    children: [
                      for (final z in zettel)
                        Positioned(
                          left: (mitte(z).dx - z.breite / 2).clamp(4, groesse.width - z.breite - 4),
                          top: (mitte(z).dy - 40).clamp(6, groesse.height - 40),
                          width: z.breite,
                          child: Transform.rotate(
                            angle: z.neigung,
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                z.kind,
                                const Positioned(top: -6, left: 0, right: 0, child: Center(child: MReissnagel(groesse: 14))),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      );
}

class _FadenMaler extends CustomPainter {
  _FadenMaler(this.linien);

  final List<(Offset, Offset, Color)> linien;

  @override
  void paint(Canvas canvas, Size size) {
    for (final (a, b, farbe) in linien) {
      final mitte = Offset((a.dx + b.dx) / 2, (a.dy + b.dy) / 2 + 14); // leicht durchhängend
      final pfad = Path()
        ..moveTo(a.dx, a.dy - 34)
        ..quadraticBezierTo(mitte.dx, mitte.dy - 34, b.dx, b.dy - 34);
      canvas.drawPath(
        pfad.shift(const Offset(1.5, 2.5)),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = Colors.black.withValues(alpha: 0.35)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5),
      );
      canvas.drawPath(
        pfad,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.8
          ..color = farbe,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _FadenMaler alt) => alt.linien.length != linien.length || !_gleich(alt.linien, linien);

  static bool _gleich(List<(Offset, Offset, Color)> a, List<(Offset, Offset, Color)> b) {
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
