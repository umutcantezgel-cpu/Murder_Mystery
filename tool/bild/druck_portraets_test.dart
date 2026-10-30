// Bildwerkstatt für das Druckpaket: je Figur des Schlosskellers und für den Detektiv
// (w und m) ein Porträt als PNG (720 px, Brustbild auf ruhigem, hellem Atelierhintergrund),
// aus demselben Zeichner wie im Spiel ([PortraitPainter], Aussehen aus `renderLook`).
// Die Bilder zeichnet dieselbe Funktion wie in der App (`lib/party/druck_portraets.dart`),
// dort in 360 px für die Erzählerakte.
// Die Druck-CLI (`party_druck.dart --paket`) liest die Bilder aus build/druck/portraets/.
// Aufruf: flutter test tool/bild/druck_portraets_test.dart  →  build/druck/portraets/<figur>.png
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mordakte/game/scene/figure_painter.dart';
import 'package:mordakte/party/druck_portraets.dart';
import 'package:mordakte_core/mordakte_core.dart';

import '../../test/party_widgets/portraet_merkmale.dart' show merkmale;

/// Kantenlänge der Porträts in Pixeln.
const groesse = 720.0;

void main() {
  test('Porträts für das Druckpaket', () async {
    final kanon = Kanon.lade((p) => jsonDecode(File('content/party/schlosskeller/$p').readAsStringSync()) as Map<String, Object?>);
    final looks = druckLooks(kanon);
    final bilder = await druckPortraets(kanon, groesse: groesse);
    expect(bilder.keys, looks.keys);
    final aus = Directory('build/druck/portraets')..createSync(recursive: true);
    for (final e in bilder.entries) {
      File('${aus.path}/${e.key}.png').writeAsBytesSync(e.value);
      final a = aussehenAus(FigureLook.fromLook(looks[e.key]!));
      // ignore: avoid_print
      print('${e.key.padRight(12)} ${merkmale(a)}');
    }
    expect(aus.listSync().whereType<File>().where((f) => f.path.endsWith('.png')).length, greaterThanOrEqualTo(looks.length));
  });
}
