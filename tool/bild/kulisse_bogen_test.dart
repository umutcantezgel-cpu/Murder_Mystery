// Bildwerkstatt: zeichnet je Akte die ganze Karte samt Kulisse als PNG
// (Boden, Kulisse, Wände und Requisiten, ohne Licht). Keine Behauptungen.
// Aufruf: flutter test tool/bild/kulisse_bogen_test.dart  →  build/bild/kulisse_<akte>.png
// Mit AKTE=<id> nur eine Akte, SKALA=<f> für den Maßstab (Vorgabe 0,5),
// TUER=<winkel> für die Türblätter (Vorgabe 0,32 = Ruhestellung).
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mordakte/game/scene/static_scene.dart';
import 'package:mordakte/game/scene/wall_painter.dart';
import 'package:mordakte/party/daten.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('Kulissenbogen', () async {
    final nur = Platform.environment['AKTE'];
    for (final fall in ['schlosskeller', 'gewoelbe', 'ravensmoor', 'nachtexpress', 'blue_palm']) {
      if (nur != null && nur != fall) continue;
      final d = await PartyDaten.laden(rootBundle, fall: fall);
      final uhr = Stopwatch()..start();
      final scene = StaticScene.build(d.szenario);
      final ms = uhr.elapsedMilliseconds;
      final k = scene.kulisse;
      var welt = scene.worldBounds;
      for (final s in k?.stuecke ?? const []) {
        welt = welt.expandToInclude(s.dst);
      }
      final skala = double.tryParse(Platform.environment['SKALA'] ?? '') ?? 0.5;
      final tuer = double.tryParse(Platform.environment['TUER'] ?? '') ?? 0.32;
      final rec = ui.PictureRecorder();
      final c = Canvas(rec);
      c.drawRect(Rect.fromLTWH(0, 0, welt.width * skala, welt.height * skala), Paint()..color = scene.pal.background);
      c.scale(skala);
      c.translate(-welt.left, -welt.top);
      k?.zeichne(c, welt);
      final p = Paint()..filterQuality = FilterQuality.medium;
      for (final f in scene.floors) {
        final img = f.image;
        if (img != null) {
          c.drawImageRect(img, Rect.fromLTWH(0, 0, img.width.toDouble(), img.height.toDouble()), f.dst, p);
        } else if (f.picture != null) {
          c.drawPicture(f.picture!);
        }
      }
      final ds = [...scene.drawables]..sort((a, b) => a.depth.compareTo(b.depth));
      for (final dr in ds) {
        if (dr.picture != null) c.drawPicture(dr.picture!);
        final t = dr.door;
        if (t != null && !t.locked) scene.wallPainter.paintDoorLeaf(c, t, tuer, t.tall ? kDoorTop : 0.6);
      }
      final bild = await rec.endRecording().toImage((welt.width * skala).round(), (welt.height * skala).round());
      final png = await bild.toByteData(format: ui.ImageByteFormat.png);
      Directory('build/bild').createSync(recursive: true);
      File('build/bild/kulisse_$fall.png').writeAsBytesSync(png!.buffer.asUint8List());
      // ignore: avoid_print
      print('$fall: Szene ${ms}ms, ${k?.stuecke.length ?? 0} Stücke, ${k?.lichter.length ?? 0} Laternen');
      scene.dispose();
    }
  });
}
