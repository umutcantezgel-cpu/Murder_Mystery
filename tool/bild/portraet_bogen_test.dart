// Bildwerkstatt: Porträts (Fotoabzug der Oberfläche) aller Figuren einer Akte
// als PNG. Keine Behauptungen; nur zum Ansehen.
// Aufruf: flutter test tool/bild/portraet_bogen_test.dart  →  build/bild/portraets.png
// GROSS=1: vier Porträts in 320 px (build/bild/portraets_gross.png).
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mordakte/ui/widgets/portrait.dart';
import 'package:mordakte_core/mordakte_core.dart';

void main() {
  test('Porträtbogen', () async {
    final figuren = (jsonDecode(File('content/party/schlosskeller/figuren.json').readAsStringSync())['figuren'] as List).cast<Map<String, dynamic>>();
    final gross = Platform.environment['GROSS'] == '1';
    final looks = [for (final f in figuren.take(gross ? 4 : 12)) LookDef.fromJson(renderLook(f.cast<String, Object?>()))];
    final g = gross ? 320.0 : 160.0;
    const rand = 12.0;
    final spalten = gross ? 4 : 6;
    final zeilen = (looks.length / spalten).ceil();
    final rec = ui.PictureRecorder();
    final c = Canvas(rec);
    c.drawRect(Rect.fromLTWH(0, 0, spalten * (g + rand) + rand, zeilen * (g + rand) + rand), Paint()..color = const Color(0xFF2A2630));
    for (var i = 0; i < looks.length; i++) {
      c.save();
      c.translate(rand + (i % spalten) * (g + rand), rand + (i ~/ spalten) * (g + rand));
      PortraitPainter(look: looks[i]).paint(c, Size.square(g));
      c.restore();
    }
    final bild = await rec.endRecording().toImage((spalten * (g + rand) + rand).round(), (zeilen * (g + rand) + rand).round());
    final png = await bild.toByteData(format: ui.ImageByteFormat.png);
    Directory('build/bild').createSync(recursive: true);
    File(gross ? 'build/bild/portraets_gross.png' : 'build/bild/portraets.png').writeAsBytesSync(png!.buffer.asUint8List());
  });
}
