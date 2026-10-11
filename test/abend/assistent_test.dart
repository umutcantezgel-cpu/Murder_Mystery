// Assistent für einen neuen Abend (/abend/neu): „Weiter“ erst nach einer Spielweise,
// Solo- und Reihum-Abend bis in die Rollenphase, gesperrte Spielweise, /abend ohne Abend.
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mordakte/abend/abend_halter.dart';
import 'package:mordakte/abend/abend_seite.dart';
import 'package:mordakte/abend/einrichtung/abschnitte.dart';
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

  testWidgets('/abend ohne laufenden Abend führt in die Detektei', (tester) async {
    final state = await oeffnen(tester, ort: Routes.abend);
    expect(find.byType(DetekteiSeite), findsOneWidget);
    expect(find.byType(AbendSeite), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
    state.dispose();
  });
}
