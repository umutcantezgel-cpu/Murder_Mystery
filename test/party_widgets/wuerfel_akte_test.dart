// Würfeltafel in einer anderen Akte als dem Schlosskeller: Die Stufen und Überschriften
// sind neutral, ohne „Kellerwürfel“, Handy, Lupe oder Gespenst als Text.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mordakte/party/bildschirme/zug_tafel.dart';
import 'package:mordakte/party/daten.dart';
import 'package:mordakte/party/sitzung.dart';
import 'package:mordakte_core/mordakte_core.dart';
import 'package:mordakte_core/runden.dart';

import 'hilfe.dart';

void main() {
  testWidgets('Würfeltafel der Gewölbe-Akte: neutrale Texte, kein Kellerwürfel und kein Handy', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final daten = await tester.runAsync(() => PartyDaten.laden(rootBundle, fall: 'gewoelbe'));
    final s = PartySitzung(daten!, wuerfel: const FesterWuerfel.neutral());
    s.einrichten(rollen: 4, detektiv: 'w', solo: true);
    spieleBis(s, PartyPhase.entscheidungen);
    // Befragungen durchspielen, bis eine Suche im Wurf-Abschnitt steht (ohne selbst zu würfeln).
    for (var schritt = 0; ; schritt++) {
      if (schritt > 400) fail('Kein Suchwurf in der Gewölbe-Akte');
      final z = s.zug;
      if (z != null) {
        if (z.phase == RundenZugPhase.wurf && !z.istAuftakt) break;
        switch (z.phase) {
          case RundenZugPhase.aktion: s.aktionFertig(z.aktion);
          case RundenZugPhase.wurf: s.wuerfeln();
          case RundenZugPhase.tischruf: s.tischruf(Tischruf.umweg);
          case RundenZugPhase.fund: s.fundGelesen();
        }
      } else if (s.laufendeEntscheidung case final e?) {
        s.schlageVor(e.optionen.first.id);
        s.bestaetigen();
      } else {
        expect(s.kannWeiter, isTrue, reason: 'Der Abend kommt ohne Suche nicht weiter');
        s.weiter();
      }
    }
    expect(s.zug!.phase, RundenZugPhase.wurf, reason: 'Der Suchwurf steht an');

    await tester.pumpWidget(rahmen(WuerfelTafel(sitzung: s)));
    await tester.pump();
    expect(find.byType(WuerfelTafel), findsOneWidget);
    expect(find.text(s.ui('ui.zug.wuerfel')), findsOneWidget);
    expect(find.text(s.ui('ui.zug.erfolg')), findsOneWidget);
    expect(find.text(s.ui('ui.zug.teilerfolg')), findsOneWidget);
    expect(find.text(s.ui('ui.zug.pech')), findsOneWidget);

    final texte = [
      for (final t in tester.widgetList<Text>(find.descendant(of: find.byType(WuerfelTafel), matching: find.byType(Text))))
        t.data ?? '',
    ];
    expect(texte, isNotEmpty);
    for (final wort in ['Kellerwürfel', 'Handy', 'Lupe', 'Gespenst', 'Seifenblase']) {
      expect(texte.where((t) => t.contains(wort)), isEmpty, reason: 'In der Würfeltafel steht „$wort“');
    }
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
