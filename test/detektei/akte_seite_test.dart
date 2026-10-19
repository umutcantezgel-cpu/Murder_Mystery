// Seite einer Akte (/akte/:id) als Fallakte: Deckblatt mit Stempel, „Die Lage“ aus
// setting.json, „Personen“ aus figuren.json. Nur öffentliche Felder, alle Rollen in
// derselben Gestalt, kein Überlauf auf kleinen Handys mit großer Schrift.
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mordakte/app/app.dart';
import 'package:mordakte/app/app_state.dart';
import 'package:mordakte/app/router.dart';
import 'package:mordakte/detektei/akten.dart';
import 'package:mordakte/meta/meta_store.dart';
import 'package:mordakte/stil/stil.dart';
import 'package:shared_preferences/shared_preferences.dart';

Map<String, dynamic> _json(String pfad) => jsonDecode(File(pfad).readAsStringSync()) as Map<String, dynamic>;

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  /// Öffnet die Akte [id] auf einem Handy und wartet, bis ihre Blätter geladen sind.
  Future<AppState> oeffnen(WidgetTester tester, String id, {double breite = 390, double schrift = 1}) async {
    tester.view.physicalSize = Size(breite, 844);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = schrift;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final state = AppState(meta: MetaStore.memory()..name = 'Test', scenarios: const {});
    await tester.runAsync(() async {
      // Echte Ladezeit für das Bündel (siehe start_test): Kampagne und Auszug vorab.
      await AktenKatalog.laden();
      await AkteAuszug.laden(id);
      await tester.pumpWidget(MordakteApp(app: state, initialLocation: Routes.akteVon(id)));
    });
    for (var i = 0; i < 100 && find.text('Die Lage').evaluate().isEmpty; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
      await tester.pump(const Duration(milliseconds: 50));
    }
    await tester.pump(const Duration(milliseconds: 600));
    return state;
  }

  test('Auszug: Lage und Besetzung aus den öffentlichen Feldern, das Opfer getrennt', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final a = await AkteAuszug.laden('schlosskeller');
    final figuren = _json('content/party/schlosskeller/figuren.json');
    final setting = _json('content/party/schlosskeller/setting.json');
    expect(a.lage?.schauplatz, setting['schauplatz']);
    expect(a.lage?.anlass, setting['anlass']);
    expect(a.lage?.datum, setting['datum']);
    expect(a.lage?.atmosphaere, setting['atmosphaere']);
    expect([for (final p in a.personen) p.name], [for (final f in figuren['figuren'] as List) (f as Map)['name']]);
    expect([for (final p in a.personen) p.titel], [for (final f in figuren['figuren'] as List) (f as Map)['roleTitle']]);
    expect(a.opfer?.name, (figuren['opfer'] as Map)['name']);
    expect(a.personen.every((p) => p.look != null && p.farbe != null), isTrue);
  });

  testWidgets('Fallakte: Deckblatt, Lage, Personen; keine geheimen Felder', (tester) async {
    final semantik = tester.ensureSemantics();
    final state = await oeffnen(tester, 'schlosskeller');
    final figuren = _json('content/party/schlosskeller/figuren.json');
    final setting = _json('content/party/schlosskeller/setting.json');
    expect(find.text('Akte Nr. 01'), findsOneWidget);
    expect(find.text('Spuk im Schlosskeller'), findsOneWidget);
    expect(find.bySemanticsLabel('Ungelöst'), findsOneWidget, reason: 'Auf einem neuen Gerät ist die Akte ungelöst');
    expect(find.text('Diese Akte spielen'), findsOneWidget);
    // M5: Steckbriefe & Übersicht mit einem Tipp, ohne Einrichtung.
    expect(find.text('Steckbriefe & Übersicht'), findsOneWidget);
    for (final text in ['Die Lage', 'Schauplatz', 'Anlass', 'Zeitpunkt', 'Personen', 'Das Opfer']) {
      expect(find.text(text), findsOneWidget, reason: text);
    }
    expect(find.text(setting['schauplatz'] as String), findsOneWidget);
    for (final z in setting['atmosphaere'] as List) {
      expect(find.text(z as String), findsOneWidget, reason: 'Randnotiz $z');
    }
    final rollen = figuren['figuren'] as List;
    for (final f in rollen) {
      final m = f as Map;
      expect(find.text(m['name'] as String, skipOffstage: false), findsOneWidget, reason: m['name'] as String);
      // Was nur die Rolle selbst wissen darf, steht nirgends.
      for (final geheim in ['motiveAndConflict', 'roleSecret', 'blackoutAlibi']) {
        final wert = m[geheim];
        if (wert is String && wert.isNotEmpty) expect(find.textContaining(wert, skipOffstage: false), findsNothing, reason: '$geheim von ${m['name']}');
      }
    }
    // Gleiche Gestalt (K-22): alle Rollen als gleich große Fotoabzüge, das Opfer extra.
    final abzuege = tester.widgetList<MFotoabzug>(find.byType(MFotoabzug, skipOffstage: false)).toList();
    expect(abzuege, hasLength(rollen.length + 1));
    final rollenAbzuege = abzuege.where((a) => !a.gedaempft).toList();
    expect(rollenAbzuege, hasLength(rollen.length));
    expect(rollenAbzuege.map((a) => a.groesse).toSet(), hasLength(1));
    expect(rollenAbzuege.every((a) => a.stempel == null && !a.klammer), isTrue);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    state.dispose();
    semantik.dispose();
  });

  for (final breite in [320.0, 390.0]) {
    testWidgets('Fallakte Blue Palm: $breite px, Schrift 2.0, ohne Überlauf', (tester) async {
      final state = await oeffnen(tester, 'blue_palm', breite: breite, schrift: 2);
      expect(find.text('Blue Palm Motel'), findsOneWidget);
      expect(find.text('Die Lage'), findsOneWidget);
      // Steckbriefe gibt es nur bei Akten mit dem Zusatz steckbriefe.
      expect(find.text('Steckbriefe & Übersicht'), findsNothing);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      state.dispose();
    });
  }

  testWidgets('Fallakte auf breitem Bildschirm (800 px) ohne Ausnahme', (tester) async {
    final state = await oeffnen(tester, 'ravensmoor', breite: 800);
    expect(find.text('Ravensmoor'), findsOneWidget);
    expect(find.text('Lady Constance', skipOffstage: false), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    state.dispose();
  });

  test('Bündel enthält die gelesenen Dateien', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    for (final id in ['schlosskeller', 'gewoelbe', 'ravensmoor', 'nachtexpress', 'blue_palm']) {
      final a = await AkteAuszug.laden(id, rootBundle);
      expect(a.lage, isNotNull, reason: id);
      expect(a.personen, isNotEmpty, reason: id);
      expect(a.opfer, isNotNull, reason: id);
    }
  });
}
