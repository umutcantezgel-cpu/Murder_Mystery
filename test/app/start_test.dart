import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mordakte/abend/abend_speicher.dart';
import 'package:mordakte/app/app.dart';
import 'package:mordakte/app/app_state.dart';
import 'package:mordakte/app/router.dart';
import 'package:mordakte/detektei/akte_bausteine.dart';
import 'package:mordakte/detektei/akten.dart';
import 'package:mordakte/detektei/dienstausweis.dart';
import 'package:mordakte/detektei/schreibtisch.dart' show MordakteWortmarke;
import 'package:mordakte/meta/meta_store.dart';
import 'package:mordakte/party/daten.dart';
import 'package:mordakte/party/sitzung.dart';
import 'package:mordakte/stil/stil.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Die Test-Assets wie `flutter test` sie liefert (`UNIT_TEST_ASSETS`, auch mit Paketpräfix,
/// synchron): Damit gibt ein Test, der einzelne Assets ersetzt, das Bündel unverändert zurück.
Future<ByteData?> _testAsset(ByteData? nachricht) {
  final wurzel = Platform.environment['UNIT_TEST_ASSETS']!;
  final praefix = 'packages/${Platform.environment['APP_NAME']}/';
  final key = utf8.decode(nachricht!.buffer.asUint8List());
  for (final k in [key, if (key.startsWith(praefix)) key.substring(praefix.length)]) {
    final f = File('$wurzel/$k');
    if (f.existsSync()) return SynchronousFuture(ByteData.sublistView(f.readAsBytesSync()));
  }
  return SynchronousFuture(null);
}

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

  /// Bildschirm eines Handys (Breite, Schriftgröße, Höhe); wird nach dem Test zurückgesetzt.
  void handy(WidgetTester tester, double breite, double schrift, {double hoehe = 844}) {
    tester.view.physicalSize = Size(breite, hoehe);
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
          // Zwei Wege zur Druckmappe, je als eigener Knopf: ganz oben unter der Wortmarke und unter
          // der Mappe mit Druckfassung (nur der Schlosskeller). Ihr Name nennt die Akte nicht, die
          // Mappe nennt sie nicht.
          expect(find.text('PDFs zum Ausdrucken'), findsNWidgets(2));
          expect(find.bySemanticsLabel('PDFs zum Ausdrucken'), findsNWidgets(2));
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

  /// Plätze in zwei Online-Abenden (Gast und Gastgeber) und mit [abgelegt] ein abgelegter Abend:
  /// Rückkehr-Karten über „Neuer Abend“. Mit abgelegtem Abend fehlt „Dein erster Fall“.
  Map<String, Object> rueckkehrAblage({required bool abgelegt}) => {
        if (abgelegt)
          AbendSpeicher.schluessel: jsonEncode({'format': PartySitzung.abendstandFormat, 'fall': 'schlosskeller', 'titel': 'Spuk im Schlosskeller', 'runde': 2}),
        'mordakte.netz.gast.sitzung': jsonEncode({'code': 'ACDEFH', 'name': 'Ada'}),
        'mordakte.netz.mordakte.relay.host': jsonEncode({'code': 'HJKLMN'}),
      };

  // Der kurze Weg zu den PDFs liegt im ersten Bildschirm: unter der Wortmarke, vor dem Ausweis,
  // ganz im Bild, ohne zu rollen. Am kleinsten Handy (320 × 568) und am üblichen (390 × 844), mit
  // „Dein erster Fall“ (neu am Schreibtisch) und ohne, immer mit Rückkehr-Karten, bei Schrift 1 und 2.
  for (final (breite, hoehe) in [(320.0, 568.0), (390.0, 844.0)]) {
    for (final schrift in [1.0, 2.0]) {
      for (final ersterFall in [true, false]) {
        final lage = ersterFall ? 'mit „Dein erster Fall“ und zwei Rückkehr-Karten' : 'mit drei Rückkehr-Karten';
        testWidgets('„PDFs zum Ausdrucken“ oben: $breite × $hoehe, Schrift $schrift, $lage, ganz im Bild ohne Rollen', (tester) async {
          final semantik = tester.ensureSemantics();
          try {
            handy(tester, breite, schrift, hoehe: hoehe);
            SharedPreferences.setMockInitialValues(rueckkehrAblage(abgelegt: !ersterFall));
            final state = await starte(tester);
            await warten(tester, find.text(ersterFall ? 'Dein erster Fall' : 'Abend fortsetzen'));
            await warten(tester, find.byKey(const ValueKey('rueckkehr-gastgeber')));
            expect(find.text('Dein erster Fall'), ersterFall ? findsOneWidget : findsNothing);
            expect(find.text('Abend fortsetzen'), ersterFall ? findsNothing : findsOneWidget);
            expect(find.byKey(const ValueKey('rueckkehr-gast')), findsOneWidget);
            expect(find.byKey(const ValueKey('rueckkehr-gastgeber')), findsOneWidget);
            final rolle = tester.state<ScrollableState>(find.descendant(of: find.byType(RollFlaeche), matching: find.byType(Scrollable)).first);
            expect(rolle.position.pixels, 0, reason: 'Nichts gerollt');
            final text = find.text('PDFs zum Ausdrucken').first;
            final knopf = tester.getRect(find.ancestor(of: text, matching: find.byType(MKnopf)));
            // Ganz im Bild, über dem Verlauf, der unten „mehr“ anzeigt (18 px).
            expect(knopf.top, greaterThanOrEqualTo(0));
            expect(knopf.left, greaterThanOrEqualTo(0));
            expect(knopf.right, lessThanOrEqualTo(breite));
            expect(knopf.bottom, lessThanOrEqualTo(hoehe - 20), reason: 'Unterkante ${knopf.bottom} bei $hoehe px Höhe');
            expect(knopf.height, greaterThanOrEqualTo(MMass.tippflaeche));
            // Unter der Wortmarke, vor dem Ausweis und vor „Neuer Abend“, mittig.
            expect(knopf.top, greaterThan(tester.getRect(find.byType(MordakteWortmarke)).bottom));
            expect(knopf.bottom, lessThan(tester.getRect(find.byType(Dienstausweis)).top));
            expect(knopf.bottom, lessThan(tester.getRect(find.text('Neuer Abend')).top));
            expect(knopf.center.dx, closeTo(breite / 2, 1));
            // Kein Wort bricht mitten durch.
            final absatz = tester.renderObject<RenderParagraph>(text);
            for (final m in RegExp(r'\S+').allMatches(absatz.text.toPlainText())) {
              final zeilen = absatz.getBoxesForSelection(TextSelection(baseOffset: m.start, extentOffset: m.end)).map((b) => b.top.round()).toSet();
              expect(zeilen, hasLength(1), reason: '„${m.group(0)}“ bricht mitten im Wort um');
            }
            // Für den Bildschirmleser ein Knopf mit genau diesem Namen, ohne die Akte.
            expect(tester.getSemantics(text), isSemantics(label: 'PDFs zum Ausdrucken', isButton: true, hasTapAction: true, isEnabled: true));
            expect(find.bySemanticsLabel('PDFs zum Ausdrucken'), findsNWidgets(2));
            expect(tester.takeException(), isNull);
            await tester.pumpWidget(const SizedBox.shrink());
            state.dispose();
          } finally {
            semantik.dispose();
          }
        });
      }
    }
  }

  for (final (breite, hoehe, schrift) in [(390.0, 844.0, 1.0), (320.0, 568.0, 2.0)]) {
    testWidgets('„PDFs zum Ausdrucken“ oben öffnet ohne Rollen die Druckmappe ($breite × $hoehe, Schrift $schrift)', (tester) async {
      handy(tester, breite, schrift, hoehe: hoehe);
      // Die Druckmappe liest die Akte aus dem Bündel: vorab in echter Zeit laden, ohne
      // Ladevorgänge, die frühere Tests begonnen und nicht abgewartet haben.
      await tester.runAsync(() async {
        rootBundle.clear();
        await PartyDaten.laden(rootBundle);
      });
      final state = await starte(tester);
      await tester.tap(find.text('PDFs zum Ausdrucken').first);
      await warten(tester, find.text('Druckmappe vorbereiten'));
      expect(find.text('Druckmappe vorbereiten'), findsOneWidget);
      // Die Druckmappe der ersten Akte mit Druckfassung: des Schlosskellers.
      expect(find.text('Spuk im Schlosskeller'), findsOneWidget);
      expect(find.text('Druckmappe'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      state.dispose();
    });
  }

  testWidgets('„PDFs zum Ausdrucken“ unter der Mappe öffnet die Druckmappe', (tester) async {
    handy(tester, 390, 1);
    // Die Druckmappe liest die Akte aus dem Bündel: vorab in echter Zeit laden, ohne
    // Ladevorgänge, die frühere Tests begonnen und nicht abgewartet haben.
    await tester.runAsync(() async {
      rootBundle.clear();
      await PartyDaten.laden(rootBundle);
    });
    final state = await starte(tester);
    // Der zweite der beiden Knöpfe; der erste liegt ganz oben.
    final knopf = find.text('PDFs zum Ausdrucken').last;
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
    final knopf = find.text('PDFs zum Ausdrucken').last;
    final karte = tester.getRect(find.ancestor(of: find.text('Spuk im Schlosskeller'), matching: find.byType(AkteKarte)));
    final mappe = tester.getRect(find.ancestor(of: find.text('Spuk im Schlosskeller'), matching: find.byType(MAktenmappe)));
    expect(tester.getRect(knopf).left, greaterThanOrEqualTo(karte.left));
    expect(tester.getRect(knopf).right, lessThanOrEqualTo(karte.right));
    expect(tester.getRect(knopf).top, greaterThan(mappe.bottom));
    expect(karte.width, lessThan(400), reason: 'Zwei Mappen nebeneinander');
    // Der Knopf oben steht mittig über Ausweis und Knöpfen, unter der Wortmarke.
    final oben = tester.getRect(find.ancestor(of: find.text('PDFs zum Ausdrucken').first, matching: find.byType(MKnopf)));
    expect(oben.center.dx, closeTo(400, 1));
    expect(oben.top, greaterThan(tester.getRect(find.byType(MordakteWortmarke)).bottom));
    expect(oben.bottom, lessThan(tester.getRect(find.byType(Dienstausweis)).top));
    expect(oben.bottom, lessThan(tester.getRect(find.text('Neuer Abend')).top));
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

  testWidgets('Ohne Akte mit Druckfassung gibt es keinen Knopf zu den PDFs, auch oben nicht', (tester) async {
    final semantik = tester.ensureSemantics();
    try {
      handy(tester, 390, 1);
      // Attrappen-Katalog: dieselben Akten, keine mit „druckspiel“. Alle übrigen Assets wie sonst.
      final katalog = jsonDecode(File(AktenKatalog.pfad).readAsStringSync()) as Map<String, dynamic>;
      for (final a in katalog['akten'] as List) {
        ((a as Map)['faehigkeiten'] as List?)?.remove('druckspiel');
      }
      final bytes = utf8.encode(jsonEncode(katalog));
      final m = tester.binding.defaultBinaryMessenger;
      m.setMockMessageHandler('flutter/assets', (n) {
        if (utf8.decode(n!.buffer.asUint8List()) == AktenKatalog.pfad) return SynchronousFuture(ByteData.sublistView(bytes));
        return _testAsset(n);
      });
      addTearDown(() {
        m.setMockMessageHandler('flutter/assets', _testAsset);
        rootBundle.clear();
      });
      rootBundle.clear();
      final state = await starte(tester);
      await warten(tester, find.text('Spuk im Schlosskeller'));
      expect(find.text('Spuk im Schlosskeller'), findsOneWidget, reason: 'Die Mappen sind da');
      expect(find.text('PDFs zum Ausdrucken'), findsNothing);
      expect(find.bySemanticsLabel('PDFs zum Ausdrucken'), findsNothing);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      state.dispose();
    } finally {
      semantik.dispose();
    }
  });
}
