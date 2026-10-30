// Porträts der Druckfassung in der App (Erzählerakte, A-063): je Figur des Schlosskellers
// und für den Detektiv (w und m) ein lesbares PNG in der verlangten Größe, das Opfer ohne.
// Dieselbe Funktion zeichnet in der Bildwerkstatt (tool/bild) die 720-px-Bilder der
// Kommandozeile.
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';
import 'package:mordakte/party/druck_portraets.dart';

import 'hilfe.dart';

/// Breite und Höhe aus dem Kopf (IHDR) eines PNG.
(int, int) _masse(Uint8List png) {
  final d = ByteData.sublistView(png);
  return (d.getUint32(16), d.getUint32(20));
}

void main() {
  testWidgets('22 lesbare PNGs mit 48 px: 20 Figuren, Detektivin und Detektiv, kein Opfer', (t) async {
    final kanon = partyDaten.kanon;
    final bilder = (await t.runAsync(() => druckPortraets(kanon, groesse: 48)))!;
    final figuren = [for (final f in kanon.figuren) f['id'] as String];
    expect(figuren, hasLength(20));
    expect(bilder.keys, [...figuren, 'detektiv-w', 'detektiv-m']);
    expect(bilder.keys, isNot(contains((kanon.figurenJson['opfer'] as Map)['id'])));
    for (final e in bilder.entries) {
      expect(e.value.take(8), [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A], reason: '${e.key}: PNG-Kennung');
      expect(_masse(e.value), (48, 48), reason: e.key);
      final bild = (await t.runAsync(() async {
        final codec = await ui.instantiateImageCodec(e.value);
        final frame = await codec.getNextFrame();
        codec.dispose();
        return frame.image;
      }))!;
      expect((bild.width, bild.height), (48, 48), reason: '${e.key}: lesbar');
      bild.dispose();
    }
    // Detektivin und Detektiv sind verschiedene Bilder.
    expect(bilder['detektiv-w'], isNot(bilder['detektiv-m']));
  });
}
