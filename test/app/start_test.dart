import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mordakte/app/app.dart';
import 'package:mordakte/app/app_state.dart';
import 'package:mordakte/app/router.dart';
import 'package:mordakte/detektei/akte_bausteine.dart';
import 'package:mordakte/detektei/akten.dart';
import 'package:mordakte/meta/meta_store.dart';
import 'package:mordakte/party/daten.dart';
import 'package:mordakte/stil/stil.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(() async {
    // Die echten Schriften der App, damit Textbreiten wie auf dem Gerät gemessen werden.
    final elite = FontLoader('SpecialElite')..addFont(rootBundle.load('assets/fonts/SpecialElite-Regular.ttf'));
    final inter = FontLoader('Inter')
      ..addFont(rootBundle.load('assets/fonts/Inter-Regular.ttf'))
      ..addFont(rootBundle.load('assets/fonts/Inter-SemiBold.ttf'))
      ..addFont(rootBundle.load('assets/fonts/Inter-Bold.ttf'));
    final playfair = FontLoader('Playfair')..addFont(rootBundle.load('assets/fonts/PlayfairDisplay-Variabel.ttf'));
    final lora = FontLoader('Lora')
      ..addFont(rootBundle.load('assets/fonts/Lora-Variabel.ttf'))
      ..addFont(rootBundle.load('assets/fonts/Lora-Kursiv-Variabel.ttf'));
    final courier = FontLoader('CourierPrime')..addFont(rootBundle.load('assets/fonts/CourierPrime-Regular.ttf'));
    final caveat = FontLoader('Caveat')..addFont(rootBundle.load('assets/fonts/Caveat-Variabel.ttf'));
    for (final l in [elite, inter, playfair, lora, courier, caveat]) {
      await l.load();
    }
  });
  setUp(() => SharedPreferences.setMockInitialValues({}));

  AppState app() => AppState(meta: MetaStore.memory()..name = 'Test', scenarios: const {});

  /// Bildschirm eines Handys (Breite, Schriftgröße); wird nach dem Test zurückgesetzt.
  void handy(WidgetTester tester, double breite, double schrift) {
    tester.view.physicalSize = Size(breite, 844);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = schrift;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  }

  /// Lässt Ladevorgänge (echte Zeit) und Übergänge ablaufen, bis [finder] etwas findet.
  Future<void> warten(WidgetTester tester, [Finder? finder]) async {
    for (var i = 0; i < 100; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
      await tester.pump(const Duration(milliseconds: 50));
      if (finder == null || finder.evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 500));
  }

  /// Startet die App. Die Detektei liest die Akten über rootBundle; der Zwischenspeicher
  /// wird deshalb vorab im echten Laufzeitmodus gefüllt, wie beim Start auf dem Gerät.
  Future<AppState> starte(WidgetTester tester, {String ort = Routes.start}) async {
    final state = app();
    await tester.runAsync(() async {
      await AktenKatalog.laden();
      await tester.pumpWidget(MordakteApp(app: state, initialLocation: ort));
    });
    await warten(tester);
    return state;
  }

  test('App und Router starten in der Detektei', () {
    final state = app();
    final router = buildRouter(state);
    expect(Routes.start, '/');
    expect(MordakteApp(app: state).initialLocation, Routes.start);
    expect(router.routeInformationProvider.value.uri.path, Routes.start);
    router.dispose();
    state.dispose();
  });

  for (final breite in [320.0, 390.0]) {
    for (final schrift in [1.0, 2.0]) {
      testWidgets('Detektei: $breite px, Schrift $schrift, ohne Überlauf', (tester) async {
        final semantik = tester.ensureSemantics();
        try {
          handy(tester, breite, schrift);
          final state = await starte(tester);
          for (final text in [
            'MORDAKTE',
            'Neuer Abend',
            'Beitreten',
            'Mit Raumcode oder QR-Code einem Abend beitreten.',
            'KAMPAGNE',
            'Spuk im Schlosskeller',
            'Das Buffet hinter dicken Mauern',
            'Spuk im Gewölbe',
            'Sammlung',
            'Profil',
          ]) {
            expect(find.text(text), findsOneWidget, reason: text);
          }
          // Fünf Akten der Kampagne: zwei Spuk (Schlosskeller, Gewölbe, je 4 bis 20 Personen),
          // drei Noir (Ravensmoor, Nachtexpress, Blue Palm, je 4 bis 8 Personen).
          expect(find.text('Spuk'), findsNWidgets(2), reason: 'Spuk-Tonschild je Spuk-Akte');
          expect(find.text('Noir'), findsNWidgets(3), reason: 'Noir-Tonschild je Noir-Akte');
          expect(find.text('4 bis 20 Personen'), findsNWidgets(2));
          expect(find.text('4 bis 8 Personen'), findsNWidgets(3));
          final beitreten = tester.widget<MKnopf>(find.ancestor(of: find.text('Beitreten'), matching: find.byType(MKnopf)));
          expect(beitreten.onPressed, isNotNull, reason: 'Beitreten ist offen');
          expect(find.bySemanticsLabel(RegExp(r'^Profil von Test, .+, \d+ Erfahrungspunkte$')), findsOneWidget);
          expect(find.bySemanticsLabel(RegExp(r'Spuk im Schlosskeller[\s\S]*Das Buffet hinter dicken Mauern')), findsOneWidget);
          // Unter der Mappe mit Druckfassung (nur der Schlosskeller) der zweite Weg zur Druckmappe,
          // als eigener Knopf: Sein Name nennt die Akte nicht, die Mappe nennt ihn nicht.
          expect(find.text('PDFs zum Ausdrucken'), findsOneWidget);
          expect(find.bySemanticsLabel('PDFs zum Ausdrucken'), findsOneWidget);
          expect(find.bySemanticsLabel(RegExp(r'Schlosskeller[\s\S]*PDFs|PDFs[\s\S]*Schlosskeller')), findsNothing);
          for (final alt in ['Andere Abende & Fälle', 'Klassische Fälle', 'Fallakten', 'bald']) {
            expect(find.text(alt), findsNothing, reason: alt);
          }
          if (schrift == 1) {
            final titel = tester.renderObject<RenderParagraph>(find.text('Spuk im Schlosskeller'));
            final boxen = titel.getBoxesForSelection(const TextSelection(baseOffset: 8, extentOffset: 21));
            expect(boxen.map((box) => box.top.round()).toSet(), hasLength(1),
                reason: 'Schlosskeller darf am kleinen Handy nicht mitten im Wort umbrechen.');
          }
          expect(tester.takeException(), isNull);
          await tester.pumpWidget(const SizedBox.shrink());
          state.dispose();
        } finally {
          semantik.dispose();
        }
      });
    }
  }

  testWidgets('Neuer Abend öffnet den Assistenten', (tester) async {
    handy(tester, 390, 1);
    final state = await starte(tester);
    await tester.tap(find.text('Neuer Abend'));
    await warten(tester, find.text('Welche Akte spielt ihr?'));
    expect(find.text('Welche Akte spielt ihr?'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    state.dispose();
  });

  testWidgets('Die Akte öffnet ihre Seite mit „Diese Akte spielen“', (tester) async {
    handy(tester, 390, 1);
    final state = await starte(tester);
    // Neu am Schreibtisch liegt „Dein erster Fall“ obenauf; die Akten folgen darunter.
    await tester.ensureVisible(find.text('Spuk im Schlosskeller'));
    await tester.pump();
    await tester.tap(find.text('Spuk im Schlosskeller'));
    await warten(tester, find.text('Diese Akte spielen'));
    expect(find.text('Diese Akte spielen'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    state.dispose();
  });

  testWidgets('„PDFs zum Ausdrucken“ unter der Mappe öffnet die Druckmappe', (tester) async {
    handy(tester, 390, 1);
    // Die Druckmappe liest die Akte aus dem Bündel: vorab in echter Zeit laden, ohne
    // Ladevorgänge, die frühere Tests begonnen und nicht abgewartet haben.
    await tester.runAsync(() async {
      rootBundle.clear();
      await PartyDaten.laden(rootBundle);
    });
    final state = await starte(tester);
    final knopf = find.text('PDFs zum Ausdrucken');
    await tester.ensureVisible(knopf);
    await tester.pump();
    // Er liegt unter der Mappe des Schlosskellers.
    final mappe = find.ancestor(of: find.text('Spuk im Schlosskeller'), matching: find.byType(MAktenmappe));
    expect(tester.getRect(knopf).top, greaterThan(tester.getRect(mappe).bottom));
    await tester.tap(knopf);
    await warten(tester, find.text('Druckmappe vorbereiten'));
    expect(find.text('Druckmappe vorbereiten'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    state.dispose();
  });

  testWidgets('Detektei auf breitem Bildschirm (800 px) ohne Ausnahme', (tester) async {
    handy(tester, 800, 1);
    final state = await starte(tester);
    expect(find.text('Sammlung'), findsOneWidget);
    expect(find.text('Profil'), findsOneWidget);
    // Zwei Spalten: Der Knopf steht in der Spalte seiner Mappe, unter ihr.
    final knopf = find.text('PDFs zum Ausdrucken');
    final karte = tester.getRect(find.ancestor(of: find.text('Spuk im Schlosskeller'), matching: find.byType(AkteKarte)));
    final mappe = tester.getRect(find.ancestor(of: find.text('Spuk im Schlosskeller'), matching: find.byType(MAktenmappe)));
    expect(tester.getRect(knopf).left, greaterThanOrEqualTo(karte.left));
    expect(tester.getRect(knopf).right, lessThanOrEqualTo(karte.right));
    expect(tester.getRect(knopf).top, greaterThan(mappe.bottom));
    expect(karte.width, lessThan(400), reason: 'Zwei Mappen nebeneinander');
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    state.dispose();
  });

  testWidgets(
    'Online erklärt die fehlende öffentliche Adresse auf einem kleinen Handy',
    (tester) async {
      handy(tester, 320, 2);
      final state = app();
      await tester.pumpWidget(
        MordakteApp(app: state, initialLocation: Routes.online),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(
        find.textContaining('Der öffentliche Spielserver'),
        findsOneWidget,
      );
      expect(find.textContaining('localhost'), findsNothing);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      state.dispose();
    },
  );
}
