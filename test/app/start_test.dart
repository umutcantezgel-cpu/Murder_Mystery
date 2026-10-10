import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mordakte/app/app.dart';
import 'package:mordakte/app/app_state.dart';
import 'package:mordakte/app/router.dart';
import 'package:mordakte/meta/meta_store.dart';
import 'package:mordakte/party/daten.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(() async {
    final font = FontLoader('SpecialElite')
      ..addFont(rootBundle.load('assets/fonts/SpecialElite-Regular.ttf'));
    await font.load();
  });
  setUp(() => SharedPreferences.setMockInitialValues({}));

  AppState app() =>
      AppState(meta: MetaStore.memory()..name = 'Test', scenarios: const {});

  test('App und Router verwenden denselben Schlosskeller-Standard', () {
    final state = app();
    final router = buildRouter(state);
    expect(MordakteApp(app: state).initialLocation, Routes.party);
    expect(router.routeInformationProvider.value.uri.path, Routes.party);
    router.dispose();
    state.dispose();
  });

  for (final width in [320.0, 390.0]) {
    for (final scale in [1.0, 2.0]) {
      testWidgets(
        'Start im Schlosskeller: $width px, Schrift $scale, ohne Überlauf',
        (tester) async {
          tester.view.physicalSize = Size(width, 844);
          tester.view.devicePixelRatio = 1;
          tester.platformDispatcher.textScaleFactorTestValue = scale;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
          final state = app();
          await tester.runAsync(() async {
            await tester.pumpWidget(MordakteApp(app: state));
            await PartyDaten.laden(rootBundle);
          });
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 500));
          expect(find.text('Spuk im Schlosskeller'), findsOneWidget);
          if (scale == 1) {
            final title = tester.renderObject<RenderParagraph>(find.text('Spuk im Schlosskeller'));
            final boxes = title.getBoxesForSelection(const TextSelection(baseOffset: 8, extentOffset: 21));
            expect(boxes.map((box) => box.top.round()).toSet(), hasLength(1),
                reason: 'Schlosskeller darf am kleinen Handy nicht mitten im Wort umbrechen.');
          }
          expect(find.text('Abend vorbereiten'), findsOneWidget);
          expect(find.text('Andere Abende & Fälle'), findsOneWidget);
          expect(tester.takeException(), isNull);
          await tester.pumpWidget(const SizedBox.shrink());
          state.dispose();
        },
      );
    }
  }

  testWidgets('Das Schlosskeller-Menü erreicht Gewölbe und klassische Fälle', (
    tester,
  ) async {
    final state = app();
    await tester.runAsync(() async {
      await tester.pumpWidget(MordakteApp(app: state));
      await PartyDaten.laden(rootBundle);
    });
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tap(find.text('Andere Abende & Fälle'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('Spuk im Gewölbe'), findsOneWidget);
    expect(find.text('Klassische Fälle'), findsOneWidget);
    expect(find.text('Fallakten'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    state.dispose();
  });

  testWidgets(
    'Online erklärt die fehlende öffentliche Adresse auf einem kleinen Handy',
    (tester) async {
      tester.view.physicalSize = const Size(320, 844);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
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
