// Profil (/profile) als Personalakte: Dienstausweis, Dienstakte, Klassen als Karteikarten,
// Garderobe, Erfolge und Ton; der Name lässt sich auf der Karteikarte ändern. Kein Überlauf
// bei 320 und 390 px, auch mit doppelter Schrift.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mordakte/app/app.dart';
import 'package:mordakte/app/app_state.dart';
import 'package:mordakte/app/router.dart';
import 'package:mordakte/klang/klang.dart';
import 'package:mordakte/meta/meta_store.dart';
import 'package:mordakte/stil/stil.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<(AppState, MetaStore)> oeffnen(WidgetTester tester, {double breite = 390, double schrift = 1}) async {
    tester.view.physicalSize = Size(breite, 844);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = schrift;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final meta = MetaStore.memory()..name = 'Test';
    final state = AppState(meta: meta, scenarios: const {});
    await tester.pumpWidget(MordakteApp(app: state, initialLocation: Routes.profile));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    return (state, meta);
  }

  for (final breite in [320.0, 390.0]) {
    for (final schrift in [1.0, 2.0]) {
      testWidgets('Profil: $breite px, Schrift $schrift, ohne Überlauf', (tester) async {
        final (state, _) = await oeffnen(tester, breite: breite, schrift: schrift);
        for (final text in ['Profil', 'Dienstausweis', 'Test', 'Dienstakte', 'Klassen', 'Hüte', 'Mäntel', 'Erfolge', 'Ton', 'Geräusche', 'Atmosphäre']) {
          expect(find.text(text, skipOffstage: false), findsOneWidget, reason: text);
        }
        expect(find.text('Zurück'), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
        state.dispose();
      });
    }
  }

  testWidgets('Ton: die Regler stellen Geräusche und Atmosphäre, aus sperrt sie', (tester) async {
    final (state, _) = await oeffnen(tester);
    final k = Klang.instanz;
    final vorher = k.lautstaerke.value;
    addTearDown(() => k.setzeLautstaerke(effekte: vorher.$1, atmosphaere: vorher.$2));
    final regler = find.byType(Slider, skipOffstage: false);
    expect(regler, findsNWidgets(2));
    await tester.ensureVisible(regler.first);
    await tester.pump(const Duration(milliseconds: 300));
    // Ganz nach links: die Geräusche verstummen, die Atmosphäre bleibt.
    await tester.drag(regler.first, const Offset(-600, 0));
    await tester.pump();
    expect(k.lautstaerke.value.$1, 0);
    expect(k.lautstaerke.value.$2, vorher.$2);
    await tester.drag(regler.last, const Offset(600, 0));
    await tester.pump();
    expect(k.lautstaerke.value.$2, 1);
    expect(tester.widget<Slider>(regler.first).onChanged, isNotNull);
    await k.schalten(false);
    await tester.pump();
    expect(tester.widget<Slider>(regler.first).onChanged, isNull, reason: 'Ton aus: Regler gesperrt');
    await k.schalten(true);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    state.dispose();
  });

  testWidgets('Eine Klasse antippen wählt sie und stempelt sie „Gewählt“', (tester) async {
    final (state, meta) = await oeffnen(tester);
    final gewaehlt = find.byWidgetPredicate((w) => w is MStempel && w.text == 'Gewählt', skipOffstage: false);
    expect(meta.loadout.cls, 'forensic');
    expect(gewaehlt, findsOneWidget, reason: 'Die gewählte Klasse trägt den Stempel');
    final profiler = find.text('Profiler', skipOffstage: false);
    await tester.ensureVisible(profiler);
    await tester.tap(profiler);
    await tester.pump(const Duration(milliseconds: 600));
    expect(meta.loadout.cls, 'profiler');
    expect(gewaehlt, findsOneWidget, reason: 'Der Stempel wandert mit der Wahl');
    expect((tester.getRect(gewaehlt).center.dy - tester.getRect(profiler.last).center.dy).abs(), lessThan(60), reason: 'Der Stempel liegt auf der Karte des Profilers');
    expect(profiler, findsNWidgets(2), reason: 'Auch der Dienstausweis nennt jetzt die Klasse');
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    state.dispose();
  });

  testWidgets('Name antippen öffnet die Karteikarte; Speichern ändert den Namen', (tester) async {
    final (state, meta) = await oeffnen(tester, breite: 320, schrift: 2);
    await tester.tap(find.text('Test'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('Name ändern'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Marlowe');
    await tester.tap(find.text('Speichern'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(meta.name, 'Marlowe');
    expect(find.text('Name ändern'), findsNothing);
    expect(find.text('Marlowe'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    state.dispose();
  });
}
