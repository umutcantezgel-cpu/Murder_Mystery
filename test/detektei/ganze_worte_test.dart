// Kein Wort bricht mitten im Wort um: Detektei, Fallakte, Druckmappe, Profil und die
// Aktenmappen im Assistenten am kleinsten Handy (320 px) mit doppelter Schrift, gemessen
// mit den echten Schriften. Dazu GanzeWorte selbst (misst mit dem wirksamen Stil) und der
// unveränderte Name der Akte-Knöpfe für den Bildschirmleser.
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mordakte/app/app.dart';
import 'package:mordakte/app/app_state.dart';
import 'package:mordakte/app/router.dart';
import 'package:mordakte/detektei/akte_bausteine.dart';
import 'package:mordakte/detektei/akten.dart';
import 'package:mordakte/detektei/schreibtisch.dart';
import 'package:mordakte/meta/meta_store.dart';
import 'package:mordakte/stil/stil.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Prüft jeden Absatz unter [bereich]: Jedes Wort steht in einer einzigen Zeile.
void keinWortGeteilt(WidgetTester tester, Finder bereich) {
  final absaetze = tester.renderObjectList<RenderParagraph>(find.descendant(of: bereich, matching: find.byType(RichText), skipOffstage: false));
  expect(absaetze, isNotEmpty);
  for (final p in absaetze) {
    if (p.didExceedMaxLines) continue;
    final text = p.text.toPlainText();
    for (final m in RegExp(r'[^\s-]+-?').allMatches(text)) {
      final zeilen = p.getBoxesForSelection(TextSelection(baseOffset: m.start, extentOffset: m.end)).map((b) => b.top.round()).toSet();
      expect(zeilen.length, lessThanOrEqualTo(1), reason: '„${m.group(0)}“ in „$text“ bricht mitten im Wort um');
    }
  }
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

  /// Öffnet [ort] auf einem Handy (320 px, doppelte Schrift) und wartet, bis [bereit] da ist.
  Future<AppState> oeffnen(WidgetTester tester, String ort, {Finder? bereit, double breite = 320, double schrift = 2, int xp = 0}) async {
    tester.view.physicalSize = Size(breite, 844);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = schrift;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final meta = MetaStore.memory()
      ..name = 'Test'
      ..debugSetXp(xp);
    final state = AppState(meta: meta, scenarios: const {});
    await tester.runAsync(() async {
      await AktenKatalog.laden();
      for (final id in ['schlosskeller', 'blue_palm']) {
        await AkteAuszug.laden(id);
      }
      await tester.pumpWidget(MordakteApp(app: state, initialLocation: ort));
    });
    for (var i = 0; i < 100; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
      await tester.pump(const Duration(milliseconds: 50));
      if (bereit == null || bereit.evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 600));
    return state;
  }

  Future<void> schliessen(WidgetTester tester, AppState state) async {
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    state.dispose();
  }

  testWidgets('GanzeWorte misst mit dem wirksamen Stil (Laufweite des DefaultTextStyle)', (tester) async {
    // Breite knapp über dem Wort ohne Laufweite: Mit der geerbten Laufweite passt es nicht mehr.
    const stil = TextStyle(fontFamily: 'Caveat', fontSize: 34);
    final ohne = TextPainter(text: const TextSpan(text: 'Melone', style: stil), textDirection: TextDirection.ltr)..layout();
    final breite = ohne.width + 1;
    ohne.dispose();
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: DefaultTextStyle(
          style: const TextStyle(letterSpacing: 1.5),
          child: Center(child: SizedBox(width: breite, child: const GanzeWorte('Melone', style: stil))),
        ),
      ),
    );
    final absatz = tester.renderObject<RenderParagraph>(find.text('Melone'));
    expect(absatz.getBoxesForSelection(const TextSelection(baseOffset: 0, extentOffset: 6)).map((b) => b.top.round()).toSet(), hasLength(1));
  });

  testWidgets('Detektei: 320 px, doppelte Schrift, kein Wort geteilt (auch „Sammlung“ auf der Karteikarte)', (tester) async {
    final state = await oeffnen(tester, Routes.start, bereit: find.text('Blue Palm Motel'));
    expect(find.text('Sammlung'), findsOneWidget);
    keinWortGeteilt(tester, find.byType(RollFlaeche));
    await schliessen(tester, state);
  });

  for (final id in ['schlosskeller', 'blue_palm']) {
    testWidgets('Fallakte $id: 320 px, doppelte Schrift, kein Wort geteilt', (tester) async {
      final state = await oeffnen(tester, Routes.akteVon(id), bereit: find.text('Personen'));
      expect(find.text('Die Lage'), findsOneWidget);
      keinWortGeteilt(tester, find.byType(RollFlaeche));
      await schliessen(tester, state);
    });
  }

  testWidgets('Druckmappe: 320 px, doppelte Schrift, der Deckel teilt kein Wort', (tester) async {
    final state = await oeffnen(tester, Routes.druckmappeVon('schlosskeller'), bereit: find.text('Spuk im Schlosskeller'));
    expect(find.text('Druckmappe'), findsWidgets);
    keinWortGeteilt(tester, find.byType(MAktenmappe));
    await schliessen(tester, state);
  });

  testWidgets('Profil: 320 px, doppelte Schrift, kein Wort geteilt (Klassen, Hüte, Erfolge)', (tester) async {
    // Mit Erfahrung, damit die Hüte ihre Namen tragen (gesperrte nennen den Rang).
    final state = await oeffnen(tester, Routes.profile, xp: 1450);
    for (final text in ['Forensikerin', 'Melone', 'Meisterkombinierer']) {
      expect(find.text(text, skipOffstage: false), findsWidgets, reason: text);
    }
    keinWortGeteilt(tester, find.byType(RollFlaeche));
    await schliessen(tester, state);
  });

  testWidgets('Assistent: die Aktenmappen teilen bei 320 px und doppelter Schrift kein Wort', (tester) async {
    final state = await oeffnen(tester, Routes.abendNeu, bereit: find.byType(AkteKarte));
    keinWortGeteilt(tester, find.byType(AkteKarte));
    await schliessen(tester, state);
  });

  testWidgets('Akte-Knopf der Kampagne: derselbe Name für den Bildschirmleser wie vor der Mappe, ohne Reiter', (tester) async {
    final semantik = tester.ensureSemantics();
    final state = await oeffnen(tester, Routes.start, bereit: find.text('Blue Palm Motel'), breite: 390, schrift: 1);
    expect(find.text('Akte Nr. 01'), findsOneWidget, reason: 'Der Reiter ist sichtbar');
    expect(find.bySemanticsLabel('Spuk im Schlosskeller\nDas Buffet hinter dicken Mauern\nSpuk\n4 bis 20 Personen'), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('Akte Nr')), findsNothing);
    await schliessen(tester, state);
    semantik.dispose();
  });
}
