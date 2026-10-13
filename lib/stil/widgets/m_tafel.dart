import 'package:flutter/material.dart';

import '../mappe/blatt.dart';
import '../mappe/material.dart';
import '../tokens.dart';

/// Tafel: zusammengehörige Inhalte.
///
/// - Standard: ein dunkler, gekörnter Aktendeckel mit eingeprägter Messinglinie.
///   Helle Schrift auf dunklem Karton für Bedienelemente und Listen.
/// - [papier]: ein helles Blatt ([MBlatt]) für Dokumente. Darunter gelten Tintenfarben.
class MTafel extends StatelessWidget {
  const MTafel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.akzent,
    this.hervorgehoben = false,
    this.papier = false,
  });

  final Widget child;
  final EdgeInsets padding;

  /// Farbiger linker Rand (z. B. Farbcode einer Figur).
  final Color? akzent;

  /// Hellere Fläche und stärkere Linie (z. B. gewählte Karte).
  final bool hervorgehoben;

  /// Als Blatt Papier statt als dunkler Deckel.
  final bool papier;

  @override
  Widget build(BuildContext context) {
    if (papier) {
      return MBlatt(padding: padding, randFarbe: akzent, hervorgehoben: hervorgehoben, child: child);
    }
    final f = MFarben.von(context);
    final flaeche = hervorgehoben ? f.flaecheHoch : f.flaeche;
    final Widget inhalt = akzent == null
        ? Padding(padding: padding, child: child)
        : IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 6,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [akzent!, Color.lerp(akzent, Colors.black, 0.35)!]),
                  ),
                ),
                Expanded(child: Padding(padding: padding, child: child)),
              ],
            ),
          );
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(MMass.r6),
        boxShadow: const [
          BoxShadow(color: Color(0x88000000), blurRadius: 18, offset: Offset(0, 8)),
          BoxShadow(color: Color(0x55000000), blurRadius: 2, offset: Offset(0, 1)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(MMass.r6),
        child: CustomPaint(
          painter: _DeckelMaler(
            oben: Color.lerp(flaeche, MRoh.lederHell, 0.25)!,
            unten: Color.lerp(flaeche, f.grund, 0.55)!,
            linie: hervorgehoben ? f.akzent.withValues(alpha: 0.7) : MRoh.messingMitte.withValues(alpha: 0.28),
          ),
          child: inhalt,
        ),
      ),
    );
  }
}

/// Dunkler Karton: Verlauf, feine Körnung, eingeprägte Doppellinie.
class _DeckelMaler extends CustomPainter {
  _DeckelMaler({required this.oben, required this.unten, required this.linie});

  final Color oben;
  final Color unten;
  final Color linie;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [oben, unten]).createShader(rect),
    );
    final z = MaterialZufall(size.width.round() * 3 + size.height.round());
    final p = Paint();
    final n = (size.width * size.height / 160).clamp(30, 1600).toInt();
    for (var i = 0; i < n; i++) {
      p.color = (z.naechste() < 0.5 ? Colors.black : Colors.white).withValues(alpha: z.zwischen(0.03, 0.07));
      canvas.drawCircle(Offset(z.naechste() * size.width, z.naechste() * size.height), z.zwischen(0.4, 1.2), p);
    }
    // Eingeprägte Linie: dunkle Kerbe, darunter ein Lichtsaum.
    final innen = RRect.fromRectAndRadius(rect.deflate(5), const Radius.circular(3));
    canvas.drawRRect(
      innen,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = linie,
    );
    canvas.drawRRect(
      innen.shift(const Offset(0, 1)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.6
        ..color = Colors.black.withValues(alpha: 0.35),
    );
    // Glanz an der Oberkante.
    canvas.drawLine(
      const Offset(8, 0.5),
      Offset(size.width - 8, 0.5),
      Paint()
        ..shader = LinearGradient(colors: [Colors.white.withValues(alpha: 0), Colors.white.withValues(alpha: 0.18), Colors.white.withValues(alpha: 0)])
            .createShader(Rect.fromLTWH(0, 0, size.width, 1)),
    );
  }

  @override
  bool shouldRepaint(covariant _DeckelMaler alt) => alt.oben != oben || alt.unten != unten || alt.linie != linie;
}
