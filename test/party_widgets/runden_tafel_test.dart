import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mordakte/party/bildschirme/karte.dart';
import 'package:mordakte/party/bildschirme/zug_tafel.dart';
import 'package:mordakte/party/bildschirme/npc_karte.dart';
import 'package:mordakte/party/sitzung.dart';
import 'package:mordakte/party/karte_session.dart';
import 'package:mordakte/game/game_view.dart';
import 'package:mordakte_core/mordakte_core.dart';
import 'package:mordakte_core/runden.dart';

import 'hilfe.dart';

Future<void> zeige(WidgetTester t, PartySitzung s, double breite, double schrift, {bool ruhig = true, bool bildschirmleser = false}) async {
  t.view.physicalSize = Size(breite, 844);
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.resetPhysicalSize);
  addTearDown(t.view.resetDevicePixelRatio);
  await t.pumpWidget(MaterialApp(
    theme: ThemeData.dark(),
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(schrift), disableAnimations: ruhig, accessibleNavigation: bildschirmleser),
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

  testWidgets('Bildschirmleser schaltet sichtbare Wege nicht ungefragt ab', (t) async {
    final s = neueSitzung(rollen: 4);
    spieleBis(s, PartyPhase.entscheidungen);
    s.schlageVor(s.laufendeEntscheidung!.optionen.first.id);
    s.bestaetigen();
    await zeige(t, s, 390, 1, ruhig: false, bildschirmleser: true);
    final k = t.widget<GameView>(find.byType(GameView)).session as PartyKartenSession;
    expect(k.bewegungReduziert, isFalse);
    expect(s.zug!.phase, RundenZugPhase.aktion);
    expect(k.kartenAktion!.fertig, isFalse);
    expect(t.takeException(), isNull);
    await t.pumpWidget(const SizedBox());
  });

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

  testWidgets('Pech: Tischruf und Marke nennen keine alten Begriffe (Seifenblasen, Handy, Kellerwürfel)', (t) async {
    // Pech bringt eine Marke. Der Tischruf erzählt die Szene neutral; „Nochmal“ bringt die Würfeltafel
    // mit dem Marken-Häkchen zurück. (Die Browser-Probe abbrechen.mjs erreicht nur den Auftakt.)
    const verboten = ['Seifenblasen', 'Handy', 'Kellerwürfel'];
    final s = neueSitzung(rollen: 20, wuerfel: const FesterWuerfel.pech());
    spieleBis(s, PartyPhase.entscheidungen, runde: 2);
    s.schlageVor(s.laufendeEntscheidung!.optionen.first.id);
    s.bestaetigen();
    s.aktionFertig(s.zug!.aktion);
    await zeige(t, s, 390, 1);
    await t.ensureVisible(find.text(s.ui('ui.zug.werfen')));
    await t.tap(find.text(s.ui('ui.zug.werfen')));
    await t.pump();
    expect(find.byType(TischrufTafel), findsOneWidget);
    expect(s.marken, greaterThan(0), reason: 'Pech bringt eine Marke');
    expect(find.text(s.ui('ui.zug.pech_szene')), findsOneWidget);
    expect(find.textContaining(s.ui('ui.zug.marken', {'zahl': '${s.marken}'})), findsWidgets, reason: 'Die Marken-Zeile zählt neutral');
    for (final wort in verboten) {
      expect(find.textContaining(wort), findsNothing, reason: 'Tischruf ohne „$wort“');
    }

    await t.ensureVisible(find.text(s.ui('ui.zug.nochmal')));
    await t.tap(find.text(s.ui('ui.zug.nochmal')));
    await t.pump();
    expect(s.zug!.phase, RundenZugPhase.aktion, reason: 'Nochmal wiederholt die Untersuchung');
    s.aktionFertig(s.zug!.aktion);
    await t.pump();
    expect(s.zug!.phase, RundenZugPhase.wurf);
    expect(find.byType(WuerfelTafel), findsOneWidget);
    expect(find.text(s.ui('ui.zug.wuerfel')), findsOneWidget);
    expect(find.text(s.ui('ui.zug.marke_einsetzen')), findsOneWidget, reason: 'Die Marke wird angeboten');
    for (final wort in verboten) {
      expect(find.textContaining(wort), findsNothing, reason: 'Würfeltafel ohne „$wort“');
    }
    expect(t.takeException(), isNull);
    await t.pumpWidget(const SizedBox());
  });
}
