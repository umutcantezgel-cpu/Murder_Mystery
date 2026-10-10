import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mordakte/party/bildschirme/einrichtung.dart';
import 'package:mordakte/party/bildschirme/gruppenwahl.dart';
import 'package:mordakte/party/bildschirme/karte.dart';
import 'package:mordakte/party/bildschirme/rollen.dart';
import 'package:mordakte/party/bildschirme/solo_gespraeche.dart';
import 'package:mordakte/party/party_seite.dart';
import 'package:mordakte_core/mordakte_core.dart';
import 'package:mordakte_core/runden.dart';

import 'hilfe.dart';

Future<void> zeigen(WidgetTester t, Widget child, double breite, double schrift) async {
  t.view.physicalSize = Size(breite, 844);
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.resetPhysicalSize);
  addTearDown(t.view.resetDevicePixelRatio);
  await t.pumpWidget(MaterialApp(theme: ThemeData.dark(), builder: (context, child) => MediaQuery(
    data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(schrift)), child: child!,
  ), home: Scaffold(body: child)));
  await t.pump();
}

Future<void> tippen(WidgetTester t, String text) async {
  final f = find.text(text);
  await t.ensureVisible(f);
  await t.tap(f);
  await t.pump();
}

void main() {
  test('Solo schützt Bot-Karten auch auf Sitzungsebene und lehnt den Druckmodus ab', () {
    final s = neueSitzung();
    expect(() => s.einrichten(rollen: 4, detektiv: 'w', solo: true, druck: true), throwsArgumentError);
    expect(s.phase, PartyPhase.titel);
    s.einrichten(rollen: 4, detektiv: 'w', solo: true, geburtstagskind: 'Mira');
    expect(s.solo, isTrue);
    expect(s.mitWuerfel, isTrue);
    expect(s.wuerfelPate, 'Mira');
    for (final r in s.besetzt) {
      expect(() => s.zeigeVerdeckt(r), throwsStateError);
      expect(() => s.dossier(r), throwsStateError);
      expect(() => s.istTaeter(r), throwsStateError);
      expect(() => s.wahl(r), throwsStateError);
    }
    expect(s.verdeckt, isNull);
    s.dispose();
  });

  test('Fortschritt vertauscht Gesprächsnummer und Gesamtzahl nicht', () {
    final s = neueSitzung();
    expect(s.ui('ui.solo.fortschritt', {'nr': '2', 'gesamt': '15'}), 'Gespräch 2 von 15');
    s.dispose();
  });

  test('Gespräche sperren die nächste Entscheidung, sind öffentlich und bleiben in den Notizen', () {
    final s = neueSitzung(rollen: 4, solo: true);
    spieleBis(s, PartyPhase.gespraeche);
    expect(s.kannWeiter, isFalse);
    expect(() => s.weiter(), throwsStateError);
    expect(() => s.soloGespraechGelesen('g_ahmet_3_1'), throwsStateError);
    expect(s.soloNotizen, isEmpty);
    for (final g in s.soloGespraeche) { s.soloGespraechGelesen(g.id); }
    expect(s.kannWeiter, isTrue);
    expect(s.soloNotizen, hasLength(s.soloGespraeche.length));
    final notizen = s.soloNotizen;
    expect(() => notizen.clear(), throwsUnsupportedError);
    s.weiter();
    expect(s.phase, PartyPhase.entscheidungen);
    expect(s.soloNotizen, notizen);
    expect(() => s.soloGespraechGelesen(notizen.first.id), throwsStateError);
    s.dispose();
  });

  test('Solo mit dauerhaftem Pech: 4–20 Rollen und alle Pfade vollständig lösbar', () {
    for (final pfad in partyDaten.kanon.pfade) {
      for (var n = 4; n <= 20; n++) {
        final s = neueSitzung(rollen: n, pfad: pfad, solo: true, salz: 'solo-probe', wuerfel: const FesterWuerfel.pech());
        spieleBis(s, PartyPhase.ende);
        expect(s.ende.id, 'ende_meister', reason: '$pfad / $n');
        expect(s.spiel.punkte, 9);
        expect(s.spiel.restmenge(), {pfad});
        expect(s.soloNotizen, isNotEmpty);
        for (var r = 1; r <= 3; r++) {
          final stimmen = {for (final rolle in s.besetzt) rolle: botKooperativ(salz: 'solo-probe', rolle: rolle, runde: r)};
          final q = s.spiel.gruppe.auswerten(rollen: n,
            kooperativ: stimmen.entries.where((e) => e.key != pfad && e.value).length,
            taeterSabotiert: stimmen[pfad] == false);
          expect(s.spiel.qualitaeten[r], q);
        }
        s.dispose();
      }
    }
  });

  test('Gleiche Wahlen liefern in Party und Solo dasselbe Würfelprotokoll und dieselben Funde', () {
    for (final pfad in partyDaten.kanon.pfade) {
      final solo = neueSitzung(rollen: 4, pfad: pfad, solo: true, salz: 'gleich', wuerfel: SalzWuerfel('gleich'));
      final party = neueSitzung(rollen: 4, pfad: pfad, salz: 'gleich', wuerfel: SalzWuerfel('gleich'));
      spieleBis(solo, PartyPhase.ende);
      spieleBis(party, PartyPhase.ende);
      expect(solo.wuerfe.map((w) => w.toJson()), party.wuerfe.map((w) => w.toJson()));
      expect(solo.spiel.bekannteFakten(), party.spiel.bekannteFakten());
      expect(solo.funde.map((k, v) => MapEntry(k, v.map((f) => f.text).toList())),
        party.funde.map((k, v) => MapEntry(k, v.map((f) => f.text).toList())));
      solo.dispose(); party.dispose();
    }
  });

  testWidgets('Einrichtung bietet Solo ohne Spielernamen oder Druckbogen und startet echte Bot-Rollen', (t) async {
    final s = neueSitzung()..zurEinrichtung();
    await zeigen(t, EinrichtungBildschirm(sitzung: s), 390, 1);
    await tippen(t, s.ui('ui.solo.solo'));
    expect(find.byKey(const ValueKey('name-ahmet')), findsNothing);
    expect(find.text(s.ui('ui.einrichtung.spiel_druck')), findsNothing);
    expect(find.text(s.ui('ui.solo.name').toUpperCase()), findsOneWidget);
    await tippen(t, s.ui('ui.einrichtung.start'));
    expect(s.solo, isTrue);
    expect(s.phase, PartyPhase.rollen);
    expect(s.besetzt, hasLength(7));
    expect(s.einstellungen.druck, isFalse);
    expect(t.takeException(), isNull);
    await t.pumpWidget(const SizedBox());
    s.dispose();
  });

  testWidgets('Bot-Rollen sind keine aufdeckbaren Karten', (t) async {
    final s = neueSitzung(rollen: 4, solo: true);
    await zeigen(t, RollenBildschirm(sitzung: s), 320, 2);
    await tippen(t, s.figurName('ahmet'));
    expect(s.verdeckt, isNull);
    expect(find.text(s.ui('ui.verdeckt.frage', {'name': s.spielerName('ahmet')})), findsNothing);
    expect(find.text(s.ui('ui.rollen.verbirgt_titel')), findsNothing);
    expect(t.takeException(), isNull);
    await t.pumpWidget(const SizedBox());
    s.dispose();
  });

  for (final breite in [320.0, 390.0]) {
    for (final schrift in [1.0, 2.0]) {
      testWidgets('Solo-Sprechblasen und automatische Wahl bei $breite px / Schrift $schrift', (t) async {
        final s = neueSitzung(rollen: 20, solo: true);
        spieleBis(s, PartyPhase.gespraeche);
        await zeigen(t, bildschirm(s), breite, schrift);
        expect(find.byType(SoloGespraecheBildschirm), findsOneWidget);
        expect(find.byType(BotSprechblase), findsOneWidget);
        expect(find.text('Gespräch 1 von ${s.soloGespraeche.length}'), findsOneWidget);
        expect(find.text(s.ui('ui.runde.weiter')), findsNothing);
        expect(find.text(s.ui('ui.rollen.verbirgt_titel')), findsNothing);
        for (final g in s.soloGespraeche) {
          expect(find.byKey(ValueKey(g.id)), findsOneWidget);
          await tippen(t, s.ui('ui.solo.gehoert'));
          expect(t.takeException(), isNull);
        }
        expect(find.text(s.ui('ui.solo.fertig')), findsOneWidget);
        expect(find.text(s.ui('ui.runde.weiter')), findsOneWidget);
        await tippen(t, s.ui('ui.solo.vorheriges'));
        expect(find.byType(BotSprechblase), findsOneWidget);
        expect(s.soloNotizen.length, s.soloGespraeche.length);
        await t.pumpWidget(const SizedBox());
        spieleBis(s, PartyPhase.gruppenwahl);
        expect(s.alleGestimmt, isTrue);
        expect(s.kannWeiter, isTrue);
        await zeigen(t, GruppenwahlBildschirm(sitzung: s), breite, schrift);
        expect(find.text(s.ui('ui.solo.gruppenwahl')), findsOneWidget);
        expect(find.text(s.ui('ui.verdeckt.frage', {'name': s.spielerName('ahmet')})), findsNothing);
        expect(t.takeException(), isNull);
        await t.pumpWidget(const SizedBox());
        s.dispose();
      });
    }
  }

  testWidgets('Notizbuch zeigt gehörte Sprechblasen, keine Bot-Dossiers', (t) async {
    final s = neueSitzung(rollen: 4, solo: true);
    spieleBis(s, PartyPhase.entscheidungen);
    await zeigen(t, KartenBildschirm(sitzung: s), 390, 1);
    await tippen(t, s.ui('ui.karte.notizbuch'));
    expect(find.byType(BotSprechblase), findsNWidgets(s.soloNotizen.length));
    expect(find.text(s.ui('ui.rollen.verbirgt_titel')), findsNothing);
    expect(find.text(s.ui('ui.karte.notizbuch_leer')), findsNothing);
    expect(t.takeException(), isNull);
    await t.pumpWidget(const SizedBox());
    s.dispose();
  });
}
