// Bildwerkstatt für das Druckpaket: je Figur des Schlosskellers und für den Detektiv
// (w und m) ein Porträt als PNG (720 px, Brustbild auf ruhigem, hellem Atelierhintergrund),
// aus demselben Zeichner wie im Spiel ([PortraitPainter], Aussehen aus `renderLook`).
// Die Druck-CLI (`party_druck.dart --paket`) liest die Bilder aus build/druck/portraets/.
// Aufruf: flutter test tool/bild/druck_portraets_test.dart  →  build/druck/portraets/<figur>.png
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mordakte/game/scene/figure_painter.dart';
import 'package:mordakte/ui/widgets/portrait.dart';
import 'package:mordakte_core/mordakte_core.dart';

import '../../test/party_widgets/portraet_merkmale.dart';

/// Kantenlänge der Porträts in Pixeln.
const groesse = 720.0;

void main() {
  test('Porträts für das Druckpaket', () async {
    final json = jsonDecode(File('content/party/schlosskeller/figuren.json').readAsStringSync()) as Map<String, dynamic>;
    final figuren = (json['figuren'] as List).cast<Map<String, dynamic>>();
    final detektiv = (json['detektiv'] as Map).cast<String, Object?>();
    final looks = <String, LookDef>{
      for (final f in figuren) f['id'] as String: LookDef.fromJson(renderLook(f.cast<String, Object?>())),
      for (final g in ['w', 'm']) 'detektiv-$g': detektivLook(detektiv, g),
    };
    final aus = Directory('build/druck/portraets')..createSync(recursive: true);
    for (final e in looks.entries) {
      final png = await portraetPng(e.value);
      File('${aus.path}/${e.key}.png').writeAsBytesSync(png);
      final a = aussehenAus(FigureLook.fromLook(e.value));
      // ignore: avoid_print
      print('${e.key.padRight(12)} ${merkmale(a)}');
    }
    expect(aus.listSync().whereType<File>().where((f) => f.path.endsWith('.png')).length, greaterThanOrEqualTo(looks.length));
  });
}

/// Porträt als PNG: heller, warmer Atelierhintergrund mit sanfter Vignette, darauf die Büste.
Future<List<int>> portraetPng(LookDef look) async {
  final rec = ui.PictureRecorder();
  final c = Canvas(rec);
  const r = Rect.fromLTWH(0, 0, groesse, groesse);
  c.drawRect(
    r,
    Paint()
      ..shader = const RadialGradient(
        center: Alignment(-0.25, -0.35),
        radius: 1.05,
        colors: [Color(0xFFF4EDE0), Color(0xFFE2D6C1), Color(0xFFC9B99E)],
        stops: [0, 0.55, 1],
      ).createShader(r),
  );
  PortraitPainter(look: look, background: false).paint(c, const Size.square(groesse));
  final bild = await rec.endRecording().toImage(groesse.round(), groesse.round());
  final png = await bild.toByteData(format: ui.ImageByteFormat.png);
  return png!.buffer.asUint8List();
}
