import 'package:barcode/barcode.dart';
import 'package:flutter/material.dart';

/// QR-Code als Zeichnung: schwarze Module auf weißem Grund mit Ruhezone (ein
/// QR-Code braucht hellen Rand und Kontrast, auch im dunklen Spiel). Die Module
/// kommen aus dem Paket `barcode` ([Barcode.qrCode]); gemalt wird mit
/// [CustomPainter], ohne Bild und ohne Netz.
class QrBild extends StatefulWidget {
  const QrBild({super.key, required this.daten, required this.semantik, this.groesse = 220});

  /// Was der Code enthält (Beitrittsadresse oder Raumcode).
  final String daten;

  /// Beschriftung für den Bildschirmleser.
  final String semantik;

  /// Größte Seitenlänge; auf schmalen Bildschirmen schrumpft das Bild.
  final double groesse;

  @override
  State<QrBild> createState() => _QrBildState();
}

class _QrBildState extends State<QrBild> {
  List<Rect> _module = const [];

  @override
  void initState() {
    super.initState();
    _berechne();
  }

  @override
  void didUpdateWidget(QrBild alt) {
    super.didUpdateWidget(alt);
    if (alt.daten != widget.daten) _berechne();
  }

  /// Schwarze Rechtecke auf einer Fläche von 1 × 1.
  void _berechne() {
    try {
      final teile = Barcode.qrCode(errorCorrectLevel: BarcodeQRCorrectionLevel.medium).make(widget.daten, width: 1, height: 1, drawText: false);
      _module = [
        for (final e in teile)
          if (e is BarcodeBar && e.black) Rect.fromLTWH(e.left, e.top, e.width, e.height),
      ];
    } catch (_) {
      // Zu lange Daten: lieber kein Bild als ein falsches.
      _module = const [];
    }
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, box) {
          final seite = box.maxWidth.isFinite ? (box.maxWidth < widget.groesse ? box.maxWidth : widget.groesse) : widget.groesse;
          return Semantics(
            label: widget.semantik,
            image: true,
            child: ExcludeSemantics(
              child: SizedBox.square(
                dimension: seite,
                child: CustomPaint(painter: _QrMaler(_module)),
              ),
            ),
          );
        },
      );
}

class _QrMaler extends CustomPainter {
  const _QrMaler(this.module);

  final List<Rect> module;

  @override
  void paint(Canvas canvas, Size size) {
    final flaeche = Offset.zero & size;
    canvas.drawRRect(RRect.fromRectAndRadius(flaeche, const Radius.circular(8)), Paint()..color = Colors.white);
    final rand = size.width * 0.07;
    final inner = size.width - 2 * rand;
    // Ohne Kantenglättung und auf ganze Pixel gerundet: keine hellen Nähte zwischen Modulen.
    final tinte = Paint()
      ..color = Colors.black
      ..isAntiAlias = false;
    for (final m in module) {
      final l = (rand + m.left * inner).floorToDouble();
      final t = (rand + m.top * inner).floorToDouble();
      final r = (rand + m.right * inner).ceilToDouble();
      final b = (rand + m.bottom * inner).ceilToDouble();
      canvas.drawRect(Rect.fromLTRB(l, t, r, b), tinte);
    }
  }

  @override
  bool shouldRepaint(_QrMaler alt) => !identical(alt.module, module);
}
