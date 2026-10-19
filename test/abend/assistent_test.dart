// Assistent für einen neuen Abend (/abend/neu): „Weiter“ erst nach einer Spielweise,
// Solo- und Reihum-Abend bis in die Rollenphase, gesperrte Spielweise, /abend ohne Abend,
// Zurück-Taste im Assistenten, „Abend abbrechen“ mit Rückfrage auf dem Solo-Abend.
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mordakte/abend/abend_halter.dart';
import 'package:mordakte/abend/abend_seite.dart';
import 'package:mordakte/abend/einrichtung/abschnitte.dart';
import 'package:mordakte/abend/einrichtung/klasse_zeile.dart';
import 'package:mordakte/app/app.dart';
import 'package:mordakte/app/app_state.dart';
import 'package:mordakte/app/router.dart';
import 'package:mordakte/detektei/akten.dart';
import 'package:mordakte/detektei/detektei_seite.dart';
import 'package:mordakte/karten/katalog_laden.dart';
import 'package:mordakte/meta/meta_store.dart';
import 'package:mordakte/party/daten.dart';
import 'package:mordakte/stil/stil.dart';
import 'package:mordakte_core/mordakte_core.dart' show PartyPhase;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Startet die App auf einem Handy. Akte und Daten lädt die App über rootBundle;
/// der Zwischenspeicher wird vorab gefüllt, damit die Schritte ohne Wartezeit laufen.
Future<AppState> oeffnen(WidgetTester tester, {String ort = Routes.abendNeu}) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  SharedPreferences.setMockInitialValues({});
  final state = AppState(meta: MetaStore.memory()..name = 'Test', scenarios: const {});
  await tester.runAsync(() async {
    // rootBundle merkt sich jede Textdatei samt Ladevorgang (CachingAssetBundle). Was der
    // Assistent braucht, lädt deshalb hier in echter Zeit: ein Vorgang, der erst in der
    // Testuhr startet und endet, hängte sonst jeden späteren Test am gemerkten Ergebnis.
    await AktenKatalog.laden();
    await PartyDaten.laden(rootBundle, fall: 'schlosskeller');
    await ladeAbstecher('schlosskeller');
    await PartyDaten.laden(rootBundle, fall: 'gewoelbe');
    await ladeAbstecher('gewoelbe');
    await ladeKartenKatalog();
    await tester.pumpWidget(MordakteApp(app: state, initialLocation: ort));
  });
  await warten(tester);
  return state;
}

/// Ladeanzeige des Assistenten, solange die Akte (Daten, Erkundungsorte) gelesen wird.
const _laedt = 'Die Akte wird vorbereitet …';

/// Lässt die echten Ladevorgänge der Akte ablaufen, bis die Ladeanzeige weg ist (und
/// [bis], falls angegeben, erscheint), danach Übergänge und Bilder. Die Wartezeit ist
/// echte Zeit: Dateien aus dem Bündel kommen über Kanäle, die die Testuhr nicht vorstellt.
Future<void> warten(WidgetTester tester, {Finder? bis}) async {
  for (var i = 0; i < 400; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 10)));
    await tester.pump(const Duration(milliseconds: 16));
    final fertig = find.text(_laedt).evaluate().isEmpty && (bis == null || bis.evaluate().isNotEmpty);
    if (fertig && i >= 3) break;
  }
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
}

/// Tippt auf den Text und wartet den Schritt ab.
Future<void> tippen(WidgetTester tester, String text) async {
  await tester.tap(find.text(text));
  await warten(tester);
}

/// Der Knopf mit diesem Text. Ohne `onPressed` ist er gesperrt.
MKnopf knopf(WidgetTester tester, String text) =>
    tester.widget<MKnopf>(find.ancestor(of: find.text(text), matching: find.byType(MKnopf)).first);

/// Phase und Solo-Schalter des laufenden Abends (nach „Abend beginnen“).
({PartyPhase phase, bool solo}) abendNach(WidgetTester tester) {
  final s = tester.element(find.byType(AbendSeite)).read<AbendHalter>().sitzung!;
  return (phase: s.phase, solo: s.solo);
}

/// [f] innerhalb der Karteikarte „Deine Ermittlerklasse“.
Finder _inKlasse(Finder f) => find.descendant(of: find.byType(KlasseZeile), matching: f);

/// Akte (vorgewählt), Spielweise, Einstellungen (Standard) und Start.
Future<void> bisZumStart(WidgetTester tester, String weise) async {
  await tippen(tester, 'Weiter');
  await tippen(tester, weise);
  await tippen(tester, 'Weiter');
  await tester.tap(find.text('Weiter'));
  await warten(tester, bis: find.text('Bereit?'));
  expect(find.text('Bereit?'), findsOneWidget);
}

void main() {
  testWidgets('Weiter bleibt ohne Spielweise gesperrt', (tester) async {
    final state = await oeffnen(tester);
    expect(find.text('SCHRITT 1 VON 4'), findsOneWidget);
    expect(find.text('Welche Akte spielt ihr?'), findsOneWidget);
    expect(knopf(tester, 'Weiter').onPressed, isNotNull, reason: 'Die Akte ist vorgewählt');
    await tippen(tester, 'Weiter');
    expect(find.text('Wie spielt ihr?'), findsOneWidget);
    expect(knopf(tester, 'Weiter').onPressed, isNull, reason: 'Ohne Spielweise kein Weiter');
    await tippen(tester, 'Solo mit Bots');
    expect(knopf(tester, 'Weiter').onPressed, isNotNull);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    state.dispose();
  });

  testWidgets('Solo mit Bots beginnt den Abend in der Phase rollen', (tester) async {
    final state = await oeffnen(tester);
    await bisZumStart(tester, 'Solo mit Bots');
    await tippen(tester, 'Abend beginnen');
    final abend = abendNach(tester);
    expect(abend.phase, PartyPhase.rollen);
    expect(abend.solo, isTrue);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    state.dispose();
  });

  testWidgets('Ein Gerät reihum beginnt den Abend ohne Solo', (tester) async {
    final state = await oeffnen(tester);
    await bisZumStart(tester, 'Ein Gerät reihum');
    await tippen(tester, 'Abend beginnen');
    final abend = abendNach(tester);
    expect(abend.phase, PartyPhase.rollen);
    expect(abend.solo, isFalse);
    await tester.pumpWidget(const SizedBox.shrink());
    state.dispose();
  });

  testWidgets('Jeder am eigenen Gerät ist wählbar, ohne Personenzahl bis zum Raum öffnen', (tester) async {
    final semantik = tester.ensureSemantics();
    try {
      final state = await oeffnen(tester);
      await tippen(tester, 'Weiter');
      final knoten = tester.getSemantics(find.bySemanticsLabel('Jeder am eigenen Gerät'));
      expect(knoten.getSemanticsData().flagsCollection.isEnabled, isNot(ui.Tristate.isFalse), reason: 'Die Spielweise ist offen');
      expect(knopf(tester, 'Weiter').onPressed, isNull, reason: 'Ohne Spielweise kein Weiter');
      await tippen(tester, 'Jeder am eigenen Gerät');
      expect(knopf(tester, 'Weiter').onPressed, isNotNull, reason: 'Gewählt: Weiter ist offen');
      await tippen(tester, 'Weiter');
      // Online legt die Lobby die Rollen fest: der Einstellungsschritt zeigt keine Personenzahl.
      expect(find.byType(PersonenAbschnitt), findsNothing);
      await tester.tap(find.text('Weiter'));
      await warten(tester, bis: find.text('Raum öffnen'));
      expect(find.text('Raum öffnen'), findsOneWidget, reason: 'Der Startknopf öffnet den Raum');
      expect(find.text('Abend beginnen'), findsNothing);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      state.dispose();
    } finally {
      semantik.dispose();
    }
  });

  testWidgets('Gewölbe hat eine feste Lösung: Hinweis statt Fall-Code', (tester) async {
    final state = await oeffnen(tester);
    await tippen(tester, 'Spuk im Gewölbe');
    await tippen(tester, 'Weiter');
    await tippen(tester, 'Solo mit Bots');
    await tippen(tester, 'Weiter');
    expect(find.byKey(const ValueKey('feste-loesung')), findsOneWidget, reason: 'Der Hinweis zur festen Lösung');
    expect(find.text('Code eingeben'), findsNothing, reason: 'Ohne Fall-Code keine Eingabe');
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    state.dispose();
  });

  testWidgets('Die Ermittlerklasse im Start wird gewählt und gespeichert', (tester) async {
    final state = await oeffnen(tester);
    await bisZumStart(tester, 'Solo mit Bots');
    await tester.ensureVisible(find.text('Profiler'));
    await tippen(tester, 'Profiler');
    expect(state.meta.loadout.cls, 'profiler', reason: 'Die gewählte Klasse liegt in der Ausrüstung');
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    state.dispose();
  });

  testWidgets('Im Start erklärt die Klasse ihre Wirkung auf der Karte und ihre drei Karten (M6)', (tester) async {
    final state = await oeffnen(tester);
    await bisZumStart(tester, 'Solo mit Bots');
    // Vorgewählt ist die Forensikerin: Spurenblick im Schlosskeller.
    final wirkung = find.text('Spurenblick: Suchstellen und Erkundungsorte leuchten schon von weitem.');
    await tester.ensureVisible(wirkung);
    expect(wirkung, findsOneWidget);
    expect(find.text('Ändert nie Fakten, Punkte oder Würfel.'), findsOneWidget);
    for (final titel in ['Forensik-Köfferchen', 'Der zweite Abdruck', 'Die große Lupe']) {
      expect(_inKlasse(find.textContaining(titel, findRichText: true)), findsOneWidget, reason: titel);
    }
    await tester.ensureVisible(find.text('Profiler'));
    await tippen(tester, 'Profiler');
    expect(find.text('Menschenkenner: Du siehst Gesprächspartner und ihre Stimmung sofort.'), findsOneWidget, reason: 'Die Erklärung folgt der Wahl');
    expect(_inKlasse(find.textContaining('Der Gedankenpalast', findRichText: true)), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    state.dispose();
  });

  testWidgets('Gewölbe kennt keine Klassen auf der Karte: nur Karten und Belohnung', (tester) async {
    final state = await oeffnen(tester);
    await tippen(tester, 'Spuk im Gewölbe');
    await bisZumStart(tester, 'Solo mit Bots');
    await tester.ensureVisible(find.text('Profiler'));
    expect(find.textContaining('Spurenblick'), findsNothing);
    expect(find.text('Ändert nie Fakten, Punkte oder Würfel.'), findsNothing);
    expect(_inKlasse(find.textContaining('Forensik-Köfferchen', findRichText: true)), findsOneWidget);
    expect(find.text('Dein Abend bringt dir immer eine Sammelkarte deiner Klasse.'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    state.dispose();
  });

  testWidgets('/abend ohne laufenden Abend führt in die Detektei', (tester) async {
    final state = await oeffnen(tester, ort: Routes.abend);
    expect(find.byType(DetekteiSeite), findsOneWidget);
    expect(find.byType(AbendSeite), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
    state.dispose();
  });

  testWidgets('Android-Zurück im Assistenten geht einen Schritt zurück, statt die App zu schließen', (tester) async {
    final state = await oeffnen(tester);
    await tippen(tester, 'Weiter');
    await tippen(tester, 'Solo mit Bots');
    await tippen(tester, 'Weiter');
    expect(find.text('SCHRITT 3 VON 4'), findsOneWidget);
    await tester.binding.handlePopRoute();
    await warten(tester);
    expect(find.text('SCHRITT 2 VON 4'), findsOneWidget, reason: 'Ein Schritt zurück: zur Spielweise');
    expect(find.text('Wie spielt ihr?'), findsOneWidget);
    await tester.binding.handlePopRoute();
    await warten(tester);
    expect(find.text('SCHRITT 1 VON 4'), findsOneWidget, reason: 'Ein weiterer Schritt: zur Akte');
    expect(find.byType(DetekteiSeite), findsNothing);
    await tester.binding.handlePopRoute();
    await warten(tester, bis: find.byType(DetekteiSeite));
    expect(find.byType(DetekteiSeite), findsOneWidget, reason: 'Auf dem ersten Schritt führt Zurück in die Detektei');
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    state.dispose();
  });

  testWidgets('Android-Zurück auf der Beitritts-Seite führt in die Detektei, die App bleibt offen', (tester) async {
    final state = await oeffnen(tester, ort: '${Routes.beitreten}?raum=ABC-DEF');
    expect(find.byType(DetekteiSeite), findsNothing);
    await tester.binding.handlePopRoute();
    await warten(tester, bis: find.byType(DetekteiSeite));
    expect(find.byType(DetekteiSeite), findsOneWidget, reason: 'Zurück geht in die Detektei');
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    state.dispose();
  });

  testWidgets('Solo-Abend: „Abend abbrechen“ fragt nach und führt nach Ja in die Detektei', (tester) async {
    final state = await oeffnen(tester);
    await bisZumStart(tester, 'Solo mit Bots');
    await tippen(tester, 'Abend beginnen');
    expect(find.byType(AbendSeite), findsOneWidget);
    final halter = tester.element(find.byType(AbendSeite)).read<AbendHalter>();
    expect(halter.laeuft, isTrue);

    await tester.tap(find.text('Abend abbrechen'));
    await warten(tester, bis: find.byType(MKarteikartenDialog));
    expect(find.text('Abend abbrechen?'), findsOneWidget, reason: 'Die Rückfrage');
    expect(find.byType(AbendSeite), findsOneWidget, reason: 'Vor der Antwort bleibt der Abend stehen');

    await tippen(tester, 'Weiterspielen');
    expect(find.byType(MKarteikartenDialog), findsNothing);
    expect(find.byType(AbendSeite), findsOneWidget);
    expect(halter.laeuft, isTrue, reason: 'Weiterspielen lässt den Abend unberührt');
    expect(
      GoRouter.of(tester.element(find.byType(AbendSeite))).routeInformationProvider.value.uri.path,
      Routes.abend,
      reason: 'Weiterspielen navigiert nicht: die Adresse bleibt die des Abends',
    );

    await tester.tap(find.text('Abend abbrechen'));
    await warten(tester, bis: find.byType(MKarteikartenDialog));
    await tester.tap(find.descendant(of: find.byType(MKarteikartenDialog), matching: find.text('Abend abbrechen')));
    await warten(tester, bis: find.byType(DetekteiSeite));
    expect(find.byType(DetekteiSeite), findsOneWidget, reason: 'Nach Ja geht es in die Detektei');
    expect(find.byType(AbendSeite), findsNothing);
    expect(halter.laeuft, isFalse, reason: 'Der Abend ist freigegeben und lässt sich nicht fortsetzen');
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    state.dispose();
  });

  testWidgets('Solo-Abend: die Leiste öffnet die Detektivkarte, auch bei 320 px und doppelter Schrift (M6)', (tester) async {
    final state = await oeffnen(tester);
    await bisZumStart(tester, 'Solo mit Bots');
    await tippen(tester, 'Abend beginnen');
    tester.view.physicalSize = const Size(320, 844);
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await warten(tester);
    expect(tester.takeException(), isNull, reason: 'Die Leiste läuft nicht über');
    // Der Knopf der Leiste (der Eintrag der Rollenphase heißt „Deine Detektivkarte“).
    await tester.tap(find.text('Detektivkarte'));
    await warten(tester, bis: find.byType(MKarteikartenDialog));
    expect(find.text('Deine Detektivkarte'), findsWidgets);
    expect(find.text('So laufen Befragungen', skipOffstage: false), findsOneWidget);
    await tippen(tester, 'Schließen');
    expect(find.byType(MKarteikartenDialog), findsNothing);
    expect(find.byType(AbendSeite), findsOneWidget, reason: 'Der Abend läuft weiter');
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    state.dispose();
  });

  testWidgets('Android-Zurück auf dem Solo-Abend fragt ebenso nach', (tester) async {
    final state = await oeffnen(tester);
    await bisZumStart(tester, 'Solo mit Bots');
    await tippen(tester, 'Abend beginnen');
    await tester.binding.handlePopRoute();
    await warten(tester, bis: find.byType(MKarteikartenDialog));
    expect(find.text('Abend abbrechen?'), findsOneWidget);
    await tippen(tester, 'Weiterspielen');
    expect(find.byType(AbendSeite), findsOneWidget, reason: 'Die App bleibt auf dem Abend');
    expect(
      GoRouter.of(tester.element(find.byType(AbendSeite))).routeInformationProvider.value.uri.path,
      Routes.abend,
      reason: 'Weiterspielen navigiert nicht: die Adresse bleibt die des Abends',
    );
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    state.dispose();
  });
}
