// M8 Teilen: Karte und Text eines beendeten Abends verraten nie den Täter, nennen
// Akte, Ende und Punkte und laden mit dem Fall-Code zum selben Fall ein. Der Knopf
// am Ende teilt ein PNG und den Text über das System.
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mordakte/l10n/gen/app_localizations.dart';
import 'package:mordakte/party/bildschirme/aufloesung.dart';
import 'package:mordakte/party/sitzung.dart';
import 'package:mordakte/party/teilen.dart';
import 'package:mordakte_core/mordakte_core.dart';
import 'package:mordakte_core/runden.dart';
import 'package:share_plus/share_plus.dart';

import 'hilfe.dart';

PartySitzung _beendet(String akte, String pfad, {bool richtig = true}) {
  final s = PartySitzung(akteDaten(akte), wuerfel: const FesterWuerfel.neutral());
  s.einrichten(rollen: 6, detektiv: 'w', code: FallCode.fuerPfad(pfad, s.kanon.pfade).code, namen: {pfad: 'Zoe Zett'});
  spieleBis(s, PartyPhase.anklage);
  s.anklagen(richtig ? pfad : s.kernverdaechtige.firstWhere((k) => k != pfad));
  spieleBis(s, PartyPhase.ende);
  return s;
}

void main() {
  setUpAll(echteSchriften);

  for (final akte in ['schlosskeller', 'ravensmoor', 'gewoelbe', 'nachtexpress', 'blue_palm']) {
    test('$akte: Text und Karte nennen Akte, Ende und Punkte, nie den Täter', () {
      final pfade = akteDaten(akte).kanon.pfade;
      for (final pfad in pfade) {
        for (final richtig in [true, false]) {
          final s = _beendet(akte, pfad, richtig: richtig);
          final text = teilText(s);
          final karte = teilKarteFuer(s);
          expect(text, contains(s.kanon.fall['titel'] as String));
          expect(text, contains(s.ende.name));
          for (final verraeterisch in [s.figurName(pfad), 'Zoe Zett', s.figurTitel(pfad)]) {
            expect(text.contains(verraeterisch), isFalse, reason: '$akte/$pfad: $verraeterisch im Text');
            expect([karte.akte, karte.ende, karte.punkte, karte.urteil].any((t) => t.contains(verraeterisch)), isFalse);
          }
          if (s.daten.kanon.festeLoesung) {
            expect(karte.code, isNull);
          } else {
            expect(text, contains(s.fallCode.code));
            expect(karte.code, s.fallCode.code);
          }
          s.dispose();
        }
      }
    });
  }

  testWidgets('Am Ende teilt der Knopf ein PNG und den Text', (tester) async {
    final s = _beendet('ravensmoor', 'butler');
    ShareParams? geteilt;
    final vorher = teilenUeber;
    teilenUeber = (p) async {
      geteilt = p;
      return const ShareResult('ok', ShareResultStatus.success);
    };
    addTearDown(() => teilenUeber = vorher);
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: L.localizationsDelegates,
      supportedLocales: L.supportedLocales,
      home: Scaffold(body: AufloesungBildschirm(sitzung: s)),
    ));
    await tester.pump(const Duration(milliseconds: 800));
    final knopf = find.text('Teilen');
    expect(knopf, findsOneWidget);
    await tester.ensureVisible(knopf);
    await tester.tap(knopf);
    for (var i = 0; i < 50 && geteilt == null; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
      await tester.pump();
    }
    expect(geteilt, isNotNull);
    expect(geteilt!.text, teilText(s));
    final png = await tester.runAsync(() => geteilt!.files!.single.readAsBytes());
    expect(png!.length, greaterThan(10000), reason: 'ein echtes Bild');
    expect(png.sublist(0, 4), Uint8List.fromList([0x89, 0x50, 0x4E, 0x47]), reason: 'PNG');
    expect(tester.takeException(), isNull);
    s.dispose();
  });
}
