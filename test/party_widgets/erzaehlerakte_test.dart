// Finale Schlosskeller (A-063, SPEZIFIKATION §2): die Erzählerakte an einem
// Gerät. Sie gehört nur dem Erzähler-Platz: reihum über die Rollenphase („Gib
// das Gerät an …“) und das offene Pult; nie im Solo, nie ohne Erzähler, nie ab
// dem Finale. Reiter „Figuren“ (besetzte zuerst, dann ohne Spieler) und „Netz“
// (Ring mit Herrn Schneider in der Mitte, öffentlich durchgezogen, heimlich
// gestrichelt, antippbar). Die Ziele kommen mit der Schicht aus ihren Sternen.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mordakte/l10n/gen/app_localizations_de.dart';
import 'package:mordakte/party/bildschirme/intro.dart';
import 'package:mordakte/party/bildschirme/rollen.dart';
import 'package:mordakte/party/erzaehlerakte_ansicht.dart';
import 'package:mordakte/party/sitzung.dart';
import 'package:mordakte_core/mordakte_core.dart';

import 'erzaehl_hilfe.dart';
import 'hilfe.dart';
import 'rundgang_hilfe.dart' show rundgangDaten;

final _de = LDe();

/// Die Liste des Reiters „Figuren“.
Finder get _figurenListe => find.descendant(of: find.byKey(const ValueKey('erzaehlerakte-figuren')), matching: find.byType(Scrollable)).first;

/// Handyformat mit reduzierter Bewegung.
Future<void> _zeige(WidgetTester t, Widget kind, {Size groesse = const Size(390, 844), double schrift = 1}) async {
  t.view.physicalSize = groesse;
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.resetPhysicalSize);
  addTearDown(t.view.resetDevicePixelRatio);
  await t.pumpWidget(rahmen(MediaQuery(data: MediaQueryData(disableAnimations: true, size: groesse, textScaler: TextScaler.linear(schrift)), child: kind)));
  await t.pump();
}

void main() {
  test('Daten: die Akte des Schlosskellers mit den Sternen der Schicht als Ziele; ohne Zusatz und Datei keine', () {
    final a = erzaehlDaten.erzaehlerakte!;
    expect(a.figuren.length, erzaehlDaten.kanon.figuren.length);
    for (final f in a.figuren) {
      expect(f.ziele.length, 2, reason: '${f.figur}: zwei Sterne');
    }
    expect(a.netz, isNotEmpty);
    expect(partyDaten.erzaehlerakte, isNull, reason: 'Ohne Eintrag in akten.json');
    expect(rundgangDaten.erzaehlerakte, isNull, reason: 'Ohne Datei');
    for (final fall in ['gewoelbe', 'ravensmoor', 'nachtexpress', 'blue_palm']) {
      expect(akteDaten(fall).erzaehlerakte, isNull, reason: fall);
    }
  });

  test('Sichtbar nur dem Erzähler am Tisch, bis zum Finale; nie im Solo, nie ohne Erzähler, nie ohne Akte', () {
    expect(erzaehlSitzung(solo: true).erzaehlerakteSichtbar, isFalse);
    expect(erzaehlSitzung().erzaehlerakteSichtbar, isFalse, reason: 'Ohne Erzähler');
    final ohneAkte = PartySitzung(rundgangDaten)..einrichten(rollen: 4, detektiv: 'w', erzaehlerName: 'Mia');
    expect(ohneAkte.erzaehlerakteSichtbar, isFalse);
    final s = erzaehlSitzung(erzaehler: 'Mia', einstimmung: false);
    expect(s.erzaehlerakteSichtbar, isTrue);
    spieleBis(s, PartyPhase.anklage);
    expect(s.erzaehlerakteSichtbar, isTrue);
    spieleBis(s, PartyPhase.finale);
    expect(s.erzaehlerakteSichtbar, isFalse, reason: 'Nie ab dem Finale');
  });

  testWidgets('Rollenphase: Eintrag, „Gib das Gerät an Mia“, dann die Akte; besetzte Figuren zuerst; Netz antippbar', (t) async {
    final s = erzaehlSitzung(rollen: 5, erzaehler: 'Mia', namen: const {'ahmet': 'Ben'}, einstimmung: false);
    await _zeige(t, RollenBildschirm(sitzung: s));
    expect(find.byKey(const ValueKey('erzaehlerakte-eintrag')), findsOneWidget);
    expect(find.text(_de.erzaehlerakte_fuer('Mia')), findsOneWidget);
    await t.ensureVisible(find.byKey(const ValueKey('erzaehlerakte-eintrag')));
    await t.tap(find.byKey(const ValueKey('erzaehlerakte-eintrag')));
    await t.pump();
    expect(find.byKey(const ValueKey('erzaehlerakte-zwischenstufe')), findsOneWidget);
    expect(find.text(s.ui('ui.verdeckt.weitergeben', {'name': 'Mia'})), findsOneWidget);
    expect(find.byType(ErzaehlerakteSeite), findsNothing, reason: 'Erst wenn Mia das Gerät hat');
    await t.ensureVisible(find.byKey(const ValueKey('erzaehlerakte-zeigen')));
    await t.tap(find.byKey(const ValueKey('erzaehlerakte-zeigen')));
    await t.pumpAndSettle();
    expect(find.byType(ErzaehlerakteSeite), findsOneWidget);
    expect(find.text(_de.erzaehlerakte_titel), findsWidgets);
    // Figuren: „Heute gespielt“ vor „Ohne Spieler“; Emine (Platz sechs) steht unter den Gästen ohne Spieler.
    final besetzt = find.byKey(const ValueKey('akte-besetzt')), ohne = find.byKey(const ValueKey('akte-ohne'));
    await t.scrollUntilVisible(besetzt, 300, scrollable: _figurenListe);
    await t.scrollUntilVisible(find.byKey(const ValueKey('akte-figur-ahmet')), 300, scrollable: _figurenListe);
    expect(find.text(_de.einstimmung_gespielt_von('Ben')), findsOneWidget);
    await t.scrollUntilVisible(ohne, 300, scrollable: _figurenListe);
    await t.scrollUntilVisible(find.byKey(const ValueKey('akte-figur-emine')), 300, scrollable: _figurenListe);
    expect(t.getTopLeft(find.byKey(const ValueKey('akte-figur-emine'))).dy, greaterThan(t.getTopLeft(ohne).dy));
    expect(find.byKey(const ValueKey('akte-besetzt')).evaluate().isEmpty || t.getTopLeft(besetzt).dy < t.getTopLeft(ohne).dy, isTrue);
    await t.scrollUntilVisible(find.byKey(const ValueKey('akte-figur-ahmet')), -300, scrollable: _figurenListe);
    // Aufklappen: alle Abschnitte, Bindungen als Chips.
    await t.tap(find.byKey(const ValueKey('akte-figur-ahmet')));
    await t.pump();
    final ahmet = erzaehlDaten.erzaehlerakte!.figur('ahmet')!;
    for (final k in ['hintergrund', 'bindungen', 'zu_schneider', 'motiv', 'geheimnis', 'nebendelikt', 'ziele', 'stimme']) {
      expect(find.text(s.ui('ui.druck.akte.$k')), findsWidgets, reason: k);
    }
    expect(find.text(ahmet.motiv!), findsOneWidget);
    expect(find.text(ahmet.ziele.first.text), findsOneWidget);
    final kante = erzaehlDaten.erzaehlerakte!.kantenVon('ahmet').first;
    expect(find.byKey(ValueKey('bindung-ahmet-${kante.anderer('ahmet')}-${kante.sichtbar}')), findsOneWidget);
    // Netz: Ring mit Herrn Schneider in der Mitte, Knoten antippbar.
    await t.tap(find.text(_de.erzaehlerakte_reiter_netz));
    await t.pump();
    expect(find.byKey(const ValueKey('netz-ring')), findsOneWidget);
    expect(find.byWidgetPredicate((w) => w is CustomPaint && w.painter is NetzMaler), findsOneWidget);
    expect(find.byKey(ValueKey('netz-knoten-${erzaehlDaten.erzaehlerakte!.schneider.person}')), findsOneWidget);
    for (final f in erzaehlDaten.erzaehlerakte!.figuren) {
      expect(find.byKey(ValueKey('netz-knoten-${f.figur}')), findsOneWidget, reason: f.figur);
    }
    NetzMaler maler() => t.widget<CustomPaint>(find.byWidgetPredicate((w) => w is CustomPaint && w.painter is NetzMaler)).painter! as NetzMaler;
    expect(maler().wahl, isNull);
    expect(maler().kanten.any((k) => k.oeffentlich) && maler().kanten.any((k) => !k.oeffentlich), isTrue, reason: 'Öffentliche und heimliche Kanten');
    await t.tap(find.byKey(const ValueKey('netz-knoten-ahmet')));
    await t.pump();
    expect(maler().wahl, 'ahmet');
    expect(find.byKey(const ValueKey('netz-alle')), findsOneWidget);
    await t.ensureVisible(find.byKey(const ValueKey('netz-alle')));
    await t.pump();
    await t.tap(find.byKey(const ValueKey('netz-alle')));
    await t.pump();
    expect(find.byKey(const ValueKey('netz-alle')), findsNothing, reason: 'Auswahl aufgehoben');
    expect(t.takeException(), isNull);
    // Schließen: zurück zur neutralen Rollenliste.
    await t.tap(find.byKey(const ValueKey('erzaehlerakte-schliessen')));
    await t.pumpAndSettle();
    expect(find.byType(ErzaehlerakteSeite), findsNothing);
    expect(find.byKey(const ValueKey('erzaehlerakte-eintrag')), findsOneWidget);
  });

  testWidgets('Ohne Erzähler und im Solo gibt es keinen Eintrag; am offenen Pult liegt die Akte bereit, zugedeckt nicht', (t) async {
    await _zeige(t, RollenBildschirm(sitzung: erzaehlSitzung(einstimmung: false)));
    expect(find.byKey(const ValueKey('erzaehlerakte-eintrag')), findsNothing);
    await _zeige(t, RollenBildschirm(sitzung: erzaehlSitzung(solo: true, einstimmung: false)));
    expect(find.byKey(const ValueKey('erzaehlerakte-eintrag')), findsNothing);
    final s = erzaehlSitzung(rollen: 4, erzaehler: 'Mia', einstimmung: false);
    spieleBis(s, PartyPhase.intro);
    await _zeige(t, ListenableBuilder(listenable: s, builder: (_, _) => IntroBildschirm(sitzung: s)));
    expect(find.byKey(const ValueKey('erzaehlerakte-knopf')), findsNothing, reason: 'Zugedeckt sieht der Tisch nichts');
    s.pultZeigen();
    await t.pump();
    await t.ensureVisible(find.byKey(const ValueKey('erzaehlerakte-knopf')));
    expect(find.byKey(const ValueKey('erzaehlerakte-knopf')), findsOneWidget);
    expect(find.byKey(const ValueKey('erzaehlerpult-zudecken')), findsOneWidget);
    final solo = erzaehlSitzung(rollen: 4, solo: true, einstimmung: false);
    spieleBis(solo, PartyPhase.intro);
    await _zeige(t, IntroBildschirm(sitzung: solo));
    expect(find.byKey(const ValueKey('erzaehlerakte-knopf')), findsNothing);
  });

  testWidgets('Die Akte schließt sich selbst, sobald das Finale beginnt', (t) async {
    final s = erzaehlSitzung(rollen: 4, erzaehler: 'Mia', einstimmung: false);
    spieleBis(s, PartyPhase.anklage);
    await _zeige(t, Builder(builder: (c) => TextButton(onPressed: () => erzaehlerakteZeigen(c, s), child: const Text('x'))));
    await t.tap(find.byType(TextButton));
    await t.pumpAndSettle();
    expect(find.byType(ErzaehlerakteSeite), findsOneWidget);
    if (s.angeklagt == null) s.anklagen(s.spiel.pfad);
    s.weiter();
    expect(s.phase, PartyPhase.finale);
    await t.pumpAndSettle();
    expect(find.byType(ErzaehlerakteSeite), findsNothing);
  });

  testWidgets('Schmal und mit doppelter Schrift ohne Überlauf, beide Reiter', (t) async {
    final s = erzaehlSitzung(rollen: 20, erzaehler: 'Mia', einstimmung: false);
    await _zeige(
      t,
      ErzaehlerakteSeite(daten: s.daten, besetzt: s.besetzt, spieler: (f) => s.namen[f]),
      groesse: const Size(320, 640),
      schrift: 2,
    );
    await t.scrollUntilVisible(find.byKey(const ValueKey('akte-figur-ahmet')), 300, scrollable: _figurenListe);
    await t.tap(find.byKey(const ValueKey('akte-figur-ahmet')));
    await t.pump();
    expect(t.takeException(), isNull);
    await t.ensureVisible(find.text(_de.erzaehlerakte_reiter_netz));
    await t.pump();
    await t.tap(find.text(_de.erzaehlerakte_reiter_netz));
    await t.pump();
    expect(find.byKey(const ValueKey('erzaehlerakte-netz')), findsOneWidget);
    final netz = find.descendant(of: find.byKey(const ValueKey('erzaehlerakte-netz')), matching: find.byType(Scrollable)).first;
    await t.scrollUntilVisible(find.byKey(const ValueKey('netz-knoten-leyla')), 200, scrollable: netz);
    await t.tap(find.byKey(const ValueKey('netz-knoten-leyla')));
    await t.pump();
    expect(t.takeException(), isNull);
  });
}
