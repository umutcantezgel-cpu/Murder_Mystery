import 'dart:typed_data';
import 'dart:ui';

/// Mittlere relative Luminanz (0 schwarz bis 1 weiß, Gewichte nach BT.709) der
/// Pixel von [roh] (RGBA, [breite] × [hoehe]) im Rechteck [r]; was außerhalb
/// des Bildes liegt, zählt nicht.
double mittlereLuminanz(ByteData roh, int breite, int hoehe, Rect r) {
  final x0 = r.left.floor().clamp(0, breite), x1 = r.right.ceil().clamp(0, breite);
  final y0 = r.top.floor().clamp(0, hoehe), y1 = r.bottom.ceil().clamp(0, hoehe);
  var summe = 0.0;
  var n = 0;
  for (var y = y0; y < y1; y++) {
    for (var x = x0; x < x1; x++) {
      final i = (y * breite + x) * 4;
      summe += 0.2126 * roh.getUint8(i) + 0.7152 * roh.getUint8(i + 1) + 0.0722 * roh.getUint8(i + 2);
      n++;
    }
  }
  return n == 0 ? 0 : summe / n / 255;
}
