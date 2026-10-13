import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../tokens.dart';
import 'material.dart';

/// Gummistempel mit doppeltem Rahmen und abgenutzter Farbe.
///
/// Der Text wird gemalt (Versalien sind Teil des Bildes); für den Bildschirmleser
/// steht er unverändert in [semantik] bzw. [text]. Mit [aufschlagen] knallt der
/// Stempel beim ersten Aufbau auf das Papier, außer bei „Bewegung reduzieren“.
class MStempel extends StatefulWidget {
  const MStempel({
    super.key,
    required this.text,
    this.farbe = MRoh.stempelRot,
    this.groesse = 18,
    this.winkel = -0.12,
    this.aufschlagen = false,
    this.semantik,
  });

  final String text;
  final Color farbe;

  /// Schriftgröße des Stempeltexts.
  final double groesse;

  /// Drehung in Bogenmaß.
  final double winkel;

  /// Aufschlag-Animation (Maßstab 2,4 → 1, Deckkraft 0 → 1).
  final bool aufschlagen;

  /// Beschriftung für den Bildschirmleser (sonst [text]).
  final String? semantik;

  @override
  State<MStempel> createState() => _MStempelState();
}

class _MStempelState extends State<MStempel> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 420));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!widget.aufschlagen || MBewegung.ruhig(context)) {
      _c.value = 1;
    } else if (_c.status == AnimationStatus.dismissed) {
      _c.forward();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stil = TextStyle(
      fontFamily: MRohSchrift.maschine,
      fontSize: widget.groesse,
      letterSpacing: widget.groesse * 0.14,
      color: widget.farbe,
    );
    final tp = TextPainter(text: TextSpan(text: widget.text.toUpperCase(), style: stil), textDirection: TextDirection.ltr)..layout();
    final pad = EdgeInsets.symmetric(horizontal: widget.groesse * 0.65, vertical: widget.groesse * 0.3);
    final groesse = Size(tp.width + pad.horizontal + 8, tp.height + pad.vertical + 8);
    return Semantics(
      label: widget.semantik ?? widget.text,
      excludeSemantics: true,
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, kind) {
          final t = Curves.easeOutBack.transform(_c.value.clamp(0.0, 1.0));
          final skala = 2.4 - 1.4 * t;
          return Opacity(
            opacity: _c.value.clamp(0.0, 1.0),
            child: Transform.rotate(angle: widget.winkel, child: Transform.scale(scale: skala, child: kind)),
          );
        },
        child: SizedBox.fromSize(size: groesse, child: CustomPaint(painter: _StempelMaler(tp, widget.farbe))),
      ),
    );
  }
}

class _StempelMaler extends CustomPainter {
  _StempelMaler(this.tp, this.farbe);

  final TextPainter tp;
  final Color farbe;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.saveLayer(rect, Paint());
    final aussen = RRect.fromRectAndRadius(rect.deflate(1.5), const Radius.circular(4));
    final innen = RRect.fromRectAndRadius(rect.deflate(5), const Radius.circular(2));
    final p = Paint()
      ..color = farbe.withValues(alpha: 0.92)
      ..style = PaintingStyle.stroke;
    canvas.drawRRect(aussen, p..strokeWidth = 2.6);
    canvas.drawRRect(innen, p..strokeWidth = 1.1);
    tp.paint(canvas, Offset((size.width - tp.width) / 2, (size.height - tp.height) / 2 + 1));
    // Abnutzung: ungleichmäßig fehlende Farbe.
    final z = MaterialZufall(tp.plainText.codeUnits.fold(17, (a, b) => (a * 31 + b) & 0xffffff));
    final weg = Paint()..blendMode = BlendMode.dstOut;
    final n = (size.width * size.height / 26).clamp(0, 1000).toInt();
    for (var i = 0; i < n; i++) {
      weg.color = Color.fromRGBO(0, 0, 0, z.zwischen(0.3, 0.95));
      canvas.drawCircle(Offset(z.naechste() * size.width, z.naechste() * size.height), z.zwischen(0.3, 1.2), weg);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _StempelMaler alt) => alt.tp.plainText != tp.plainText || alt.farbe != farbe;
}

/// Siegel aus Wachs mit zwei Buchstaben (z. B. das Kürzel einer Akte).
class MSiegel extends StatelessWidget {
  const MSiegel({super.key, required this.kuerzel, this.farbe = MRoh.stempelRot, this.groesse = 46, this.semantik});

  final String kuerzel;
  final Color farbe;
  final double groesse;
  final String? semantik;

  @override
  Widget build(BuildContext context) => Semantics(
        label: semantik,
        excludeSemantics: true,
        child: SizedBox.square(dimension: groesse, child: CustomPaint(painter: _SiegelMaler(kuerzel, farbe))),
      );
}

class _SiegelMaler extends CustomPainter {
  _SiegelMaler(this.kuerzel, this.farbe);

  final String kuerzel;
  final Color farbe;

  @override
  void paint(Canvas canvas, Size size) {
    final m = size.center(Offset.zero);
    final r = size.shortestSide / 2;
    final z = MaterialZufall(kuerzel.codeUnits.fold(5, (a, b) => a * 37 + b));
    // Unregelmäßiger Wachsrand.
    final rand = Path();
    const zacken = 22;
    for (var i = 0; i <= zacken; i++) {
      final w = i / zacken * math.pi * 2;
      final rr = r * (0.9 + z.naechste() * 0.1);
      final p = m + Offset(math.cos(w) * rr, math.sin(w) * rr);
      i == 0 ? rand.moveTo(p.dx, p.dy) : rand.lineTo(p.dx, p.dy);
    }
    rand.close();
    canvas.drawShadow(rand, Colors.black, 3, false);
    canvas.drawPath(
      rand,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.35, -0.4),
          colors: [Color.lerp(farbe, Colors.white, 0.25)!, farbe, Color.lerp(farbe, Colors.black, 0.45)!],
          stops: const [0, 0.55, 1],
        ).createShader(Rect.fromCircle(center: m, radius: r)),
    );
    // Eingeprägter Ring.
    canvas.drawCircle(
      m,
      r * 0.66,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.07
        ..color = Colors.black.withValues(alpha: 0.28),
    );
    canvas.drawCircle(
      m.translate(0.6, 0.8),
      r * 0.66,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.03
        ..color = Colors.white.withValues(alpha: 0.18),
    );
    final tp = TextPainter(
      text: TextSpan(
        text: kuerzel,
        style: TextStyle(
          fontFamily: MRohSchrift.anzeige,
          fontSize: r * 0.62,
          fontWeight: FontWeight.w800,
          fontVariations: const [FontVariation('wght', 800)],
          color: Colors.black.withValues(alpha: 0.38),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, m - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant _SiegelMaler alt) => alt.kuerzel != kuerzel || alt.farbe != farbe;
}

/// Gezeichnete Büroklammer aus Stahl.
class MBueroklammer extends StatelessWidget {
  const MBueroklammer({super.key, this.farbe = const Color(0xFF9AA3AD), this.hoehe = 42});

  final Color farbe;
  final double hoehe;

  @override
  Widget build(BuildContext context) =>
      ExcludeSemantics(child: SizedBox(width: hoehe * 0.4, height: hoehe, child: CustomPaint(painter: _KlammerMaler(farbe))));
}

class _KlammerMaler extends CustomPainter {
  _KlammerMaler(this.farbe);

  final Color farbe;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final pfad = Path()
      ..moveTo(w * 0.3, h * 0.75)
      ..lineTo(w * 0.3, h * 0.2)
      ..arcToPoint(Offset(w * 0.75, h * 0.2), radius: Radius.circular(w * 0.23))
      ..lineTo(w * 0.75, h * 0.9)
      ..arcToPoint(Offset(w * 0.1, h * 0.9), radius: Radius.circular(w * 0.33))
      ..lineTo(w * 0.1, h * 0.12);
    canvas.drawPath(
      pfad.shift(const Offset(1.2, 1.6)),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.2),
    );
    canvas.drawPath(
      pfad,
      Paint()
        ..color = farbe
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.3
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawPath(
      pfad.shift(const Offset(-0.5, -0.5)),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.7,
    );
  }

  @override
  bool shouldRepaint(covariant _KlammerMaler alt) => alt.farbe != farbe;
}

/// Ein Stück Klebestreifen (halb durchsichtig, gerissene Enden).
class MKlebestreifen extends StatelessWidget {
  const MKlebestreifen({super.key, this.breite = 78, this.winkel = -0.05});

  final double breite;
  final double winkel;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
        child: Transform.rotate(
          angle: winkel,
          child: SizedBox(width: breite, height: 22, child: const CustomPaint(painter: _StreifenMaler())),
        ),
      );
}

class _StreifenMaler extends CustomPainter {
  const _StreifenMaler();

  @override
  void paint(Canvas canvas, Size size) {
    final z = MaterialZufall(size.width.round());
    final p = Path()..moveTo(0, 0);
    for (var y = 0.0; y <= size.height; y += 3) {
      p.lineTo(z.zwischen(0, 3), y);
    }
    for (var y = size.height; y >= 0; y -= 3) {
      p.lineTo(size.width - z.zwischen(0, 3), y);
    }
    p.close();
    canvas.drawPath(p, Paint()..color = const Color(0x8CEDE6C8));
    canvas.drawPath(
      p,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.6
        ..color = const Color(0x40FFFFFF),
    );
  }

  @override
  bool shouldRepaint(covariant _StreifenMaler alt) => false;
}

/// Reißzwecke mit rotem Kopf (für die Korkwand).
class MReissnagel extends StatelessWidget {
  const MReissnagel({super.key, this.farbe = const Color(0xFFC0313B), this.groesse = 16});

  final Color farbe;
  final double groesse;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
        child: Container(
          width: groesse,
          height: groesse,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              center: const Alignment(-0.4, -0.45),
              colors: [Color.lerp(farbe, Colors.white, 0.55)!, farbe, Color.lerp(farbe, Colors.black, 0.5)!],
              stops: const [0, 0.5, 1],
            ),
            boxShadow: const [BoxShadow(color: Color(0x80000000), blurRadius: 3, offset: Offset(1.5, 2.5))],
          ),
        ),
      );
}
