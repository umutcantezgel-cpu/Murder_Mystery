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

const _verboten = ['Kellerwürfel', 'Handy', 'Lupe', 'Gespenst', 'Seifenblase'];

/// Texte aller Text-Widgets unterhalb von [finder].
List<String> _texteIn(WidgetTester tester, Finder finder) => [
      for (final t in tester.widgetList<Text>(find.descendant(of: finder, matching: find.byType(Text)))) t.data ?? '',
    ];

void main() {
  testWidgets('Würfeltafel der Gewölbe-Akte: neutrale Texte, kein Kellerwürfel und kein Handy', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final daten = await tester.runAsync(() => PartyDaten.laden(rootBundle, fall: 'gewoelbe'));
    // Pech auf jeden Wurf: Der Auftakt bringt eine Marke (die Marken-Zeile erscheint),
    // der Suchwurf am Ende ebenfalls Pech (Tischruf mit Pechszene).
    final s = PartySitzung(daten!, wuerfel: const FesterWuerfel.pech());
    s.einrichten(rollen: 4, detektiv: 'w', solo: true);
    spieleBis(s, PartyPhase.entscheidungen);
    // Befragungen durchspielen, bis eine Suche im Wurf-Abschnitt steht.
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
    expect(s.marken, 1, reason: 'Der Auftakt-Pech hat eine Marke gebracht');

    await tester.pumpWidget(rahmen(WuerfelTafel(sitzung: s)));
    await tester.pump();
    final tafel = find.byType(WuerfelTafel);
    expect(tafel, findsOneWidget);
    expect(find.text(s.ui('ui.zug.wuerfel')), findsOneWidget);
    expect(find.text(s.ui('ui.zug.erfolg')), findsOneWidget);
    expect(find.text(s.ui('ui.zug.teilerfolg')), findsOneWidget);
    expect(find.text(s.ui('ui.zug.pech')), findsOneWidget);
    // Teilerfolg-Symbol ist die Glühbirne, nicht das Handy.
    expect(find.descendant(of: tafel, matching: find.byIcon(Icons.lightbulb_outline_rounded)), findsOneWidget);
    expect(find.descendant(of: tafel, matching: find.byIcon(Icons.phone_android_rounded)), findsNothing);
    // Mit einer Marke im Bestand erscheint die Marken-Checkbox mit dem neutralen Text.
    expect(find.text(s.ui('ui.zug.marke_einsetzen')), findsOneWidget);

    final texte = _texteIn(tester, tafel);
    expect(texte, isNotEmpty);
    for (final wort in _verboten) {
      expect(texte.where((t) => t.contains(wort)), isEmpty, reason: 'In der Würfeltafel steht „$wort“');
    }
    expect(tester.takeException(), isNull);

    // Pech öffnet den Tischruf; die Pechszene ist neutral wie die übrige Würfelbühne.
    s.wuerfeln();
    expect(s.zug!.phase, RundenZugPhase.tischruf, reason: 'Pech öffnet den Tischruf');
    await tester.pumpWidget(rahmen(TischrufTafel(sitzung: s)));
    await tester.pump();
    expect(find.text(s.ui('ui.zug.pech_szene')), findsOneWidget);
    expect(find.text(s.ui('ui.zug.pech_folge')), findsOneWidget);
    final tischruf = _texteIn(tester, find.byType(TischrufTafel));
    for (final wort in _verboten) {
      expect(tischruf.where((t) => t.contains(wort)), isEmpty, reason: 'Im Tischruf steht „$wort“');
    }
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
