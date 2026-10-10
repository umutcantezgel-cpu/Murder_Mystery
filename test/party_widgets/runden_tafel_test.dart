import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mordakte/party/bildschirme/karte.dart';
import 'package:mordakte/party/bildschirme/zug_tafel.dart';
import 'package:mordakte/party/bildschirme/npc_karte.dart';
import 'package:mordakte/party/sitzung.dart';
import 'package:mordakte_core/mordakte_core.dart';
import 'package:mordakte_core/runden.dart';

import 'hilfe.dart';

Future<void> zeige(WidgetTester t, PartySitzung s, double breite, double schrift) async {
  t.view.physicalSize = Size(breite, 844);
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.resetPhysicalSize);
  addTearDown(t.view.resetDevicePixelRatio);
  await t.pumpWidget(MaterialApp(
    theme: ThemeData.dark(),
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(schrift), disableAnimations: true),
      child: child!,
    ),
    home: Scaffold(body: KartenBildschirm(sitzung: s)),
  ));
  await t.pump();
}

void main() {
  for (final breite in [320.0, 390.0]) {
    for (final schrift in [1.0, 2.0]) {
      testWidgets('Wurf und Tischruf ohne Überlauf bei $breite px und Schrift $schrift', (t) async {
        final s = neueSitzung(rollen: 20, wuerfel: const FesterWuerfel.pech());
        spieleBis(s, PartyPhase.entscheidungen, runde: 2);
        s.schlageVor(s.laufendeEntscheidung!.optionen.first.id);
        s.bestaetigen();
        s.aktionFertig(s.zug!.aktion);
        await zeige(t, s, breite, schrift);
        expect(find.byType(WuerfelTafel), findsOneWidget);
        expect(find.text('42 %'), findsOneWidget);
        expect(find.text('30 %'), findsOneWidget);
        expect(find.text('28 %'), findsOneWidget);
        expect(find.text(s.ui('ui.karte.fertig')), findsNothing);
        expect(t.takeException(), isNull);
        await t.ensureVisible(find.text(s.ui('ui.zug.werfen')));
        await t.tap(find.text(s.ui('ui.zug.werfen')));
        await t.pump();
        expect(find.byType(TischrufTafel), findsOneWidget);
        expect(find.byType(FundKarte), findsNothing);
        expect(s.letzterFund, isNull);
        expect(t.takeException(), isNull);
        await t.ensureVisible(find.text(s.ui('ui.zug.umweg_knopf')));
        await t.tap(find.text(s.ui('ui.zug.umweg_knopf')));
        await t.pump();
        expect(s.zug!.phase, RundenZugPhase.aktion);
        expect(find.text(s.ui('ui.karte.fertig')), findsNothing);
        expect(t.takeException(), isNull);
        await t.pumpWidget(const SizedBox());
      });
    }
  }

  testWidgets('erste Runde zeigt Auftakt statt eines verfrühten Runde-fertig-Dialogs', (t) async {
    final s = neueSitzung(rollen: 4);
    while (s.phase != PartyPhase.entscheidungen) { s.weiter(); }
    await zeige(t, s, 320, 2);
    expect(find.text(s.ui('ui.zug.auftakt')), findsOneWidget);
    expect(find.text(s.ui('ui.karte.fertig')), findsNothing);
    expect(s.laufendeEntscheidung, isNull);
    expect(t.takeException(), isNull);
    await t.pumpWidget(const SizedBox());
  });
}
