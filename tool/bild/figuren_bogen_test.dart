// Bildwerkstatt: zeichnet einen Bogen mit Figuren (Rig) in acht Blickrichtungen, im Gang
// und in den Gesten sowie bei Tätigkeiten im Stand als PNG. Keine Behauptungen; nur zum Ansehen.
// Aufruf: flutter test tool/bild/figuren_bogen_test.dart  →  build/bild/figuren.png
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mordakte/game/scene/figure_painter.dart';
import 'package:mordakte_core/mordakte_core.dart';

void main() {
  test('Figurenbogen', () async {
    final figuren = (jsonDecode(File('content/party/schlosskeller/figuren.json').readAsStringSync())['figuren'] as List).cast<Map<String, dynamic>>();
    final nah = Platform.environment['NAH'] == '1';
    final looks = [for (final f in figuren.take(nah ? 3 : 10)) FigureLook.fromLook(LookDef.fromJson(renderLook(f.cast<String, Object?>())))];
    final skala = nah ? 7.0 : 3.0;
    const spalte = 64.0, zeile = 84.0;
    final spalten = nah ? 6 : 20;
    final breite = spalte * spalten * skala, hoehe = zeile * looks.length * skala + 40;
    final rec = ui.PictureRecorder();
    final c = Canvas(rec);
    c.drawRect(Rect.fromLTWH(0, 0, breite, hoehe), Paint()..color = const Color(0xFF2A2630));
    final fig = FigurePainter();
    for (var r = 0; r < looks.length; r++) {
      for (var k = 0; k < spalten; k++) {
        c.save();
        c.scale(skala);
        final fuss = Offset(spalte * k + spalte / 2, zeile * r + zeile - 10);
        c.drawLine(fuss.translate(-26, 0), fuss.translate(26, 0), Paint()..color = const Color(0x22FFFFFF));
        if (k < 8) {
          // Acht Blickrichtungen im Stand.
          fig.standing(c, fuss, looks[r], facing: k * math.pi / 4, ruhe: 1.0 + r);
        } else if (k < 12) {
          // Gang, seitlich (vier Phasen).
          fig.standing(c, fuss, looks[r], facing: math.pi / 4, walk: (k - 8) * math.pi / 2, moveAmt: 1);
        } else if (k == 12) {
          fig.standing(c, fuss, looks[r], facing: -math.pi / 4, walk: 1.2, moveAmt: 1);
        } else if (k == 13) {
          fig.standing(c, fuss, looks[r], facing: math.pi / 2, suchen: true, handlungsZeit: 0.4);
        } else if (k == 14) {
          fig.standing(c, fuss, looks[r], facing: math.pi / 4 * 3, befragen: true, handlungsZeit: 0.4);
        } else {
          // Tätigkeiten im Stand (NPC-Leben), abwechselnd frontal und seitlich.
          final tat = const [Taetigkeit.uhr, Taetigkeit.notiz, Taetigkeit.tasse, Taetigkeit.verschraenkt, Taetigkeit.tasse][k - 15];
          fig.standing(c, fuss, looks[r], facing: r.isEven ? math.pi / 4 : 0, ruhe: 1.0 + r, taetigkeit: tat, taetigkeitsGrad: 1, taetigkeitsZeit: k == 19 ? 0.8 : 3);
        }
        c.restore();
      }
    }
    final bild = await rec.endRecording().toImage(breite.round(), hoehe.round());
    final png = await bild.toByteData(format: ui.ImageByteFormat.png);
    Directory('build/bild').createSync(recursive: true);
    File(nah ? 'build/bild/figuren_nah.png' : 'build/bild/figuren.png').writeAsBytesSync(png!.buffer.asUint8List());
  });
}
