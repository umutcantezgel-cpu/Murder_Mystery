// Bildbogen der Teilkarten (M8): je Akte die Karte eines beendeten Abends als PNG
// unter tool/e2e/fotos/teilkarte/ (nur zum Ansehen, keine Behauptungen außer
// „ohne Überlauf“). Aufruf: flutter test tool/bild/teilkarte_bogen_test.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mordakte/party/sitzung.dart';
import 'package:mordakte/party/teilen.dart';
import 'package:mordakte_core/mordakte_core.dart';
import 'package:mordakte_core/runden.dart';

import '../../test/party_widgets/hilfe.dart';

void main() {
  setUpAll(echteSchriften);

  for (final (akte, richtig) in [('schlosskeller', true), ('ravensmoor', false), ('gewoelbe', true), ('blue_palm', true)]) {
    testWidgets('Teilkarte $akte', (tester) async {
      final s = PartySitzung(akteDaten(akte), wuerfel: const FesterWuerfel.neutral());
      final pfad = s.kanon.pfade.first;
      s.einrichten(rollen: 6, detektiv: 'w', code: FallCode.fuerPfad(pfad, s.kanon.pfade).code);
      spieleBis(s, PartyPhase.anklage);
      s.anklagen(richtig ? pfad : s.kernverdaechtige.firstWhere((k) => k != pfad));
      spieleBis(s, PartyPhase.ende);
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: Center(child: teilKarteFuer(s)))));
      await tester.pump();
      expect(tester.takeException(), isNull);
      final kontext = tester.element(find.byType(TeilKarte));
      final png = await tester.runAsync(() => widgetAlsPng(kontext, teilKarteFuer(s), groesse: TeilKarte.groesse, pixel: 2));
      final datei = File('tool/e2e/fotos/teilkarte/$akte.png')..createSync(recursive: true);
      datei.writeAsBytesSync(png!);
      s.dispose();
    });
  }
}
