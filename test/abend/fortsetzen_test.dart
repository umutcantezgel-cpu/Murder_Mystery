// M8 „Abend fortsetzen“: Ein Solo- oder Reihum-Abend liegt nach jedem Schritt auf
// dem Gerät. Nach dem Neuladen zeigt die Detektei „Abend fortsetzen“ mit Akte
// und Runde, und der Abend geht genau dort weiter. Abbrechen oder Verwerfen
// löscht den Stand. (Das Abspielen selbst prüft test/party_widgets/abendstand_test.dart.)
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mordakte/abend/abend_halter.dart';
import 'package:mordakte/abend/abend_seite.dart';
import 'package:mordakte/abend/belohnung_seite.dart';
import 'package:mordakte/abend/abend_speicher.dart';
import 'package:mordakte/app/app.dart';
import 'package:mordakte/app/app_state.dart';
import 'package:mordakte/app/router.dart';
import 'package:mordakte/detektei/akten.dart';
import 'package:mordakte/detektei/detektei_seite.dart';
import 'package:mordakte/karten/katalog_laden.dart';
import 'package:mordakte/meta/meta_store.dart';
import 'package:mordakte/party/daten.dart';
import 'package:mordakte/stil/stil.dart';
import 'package:mordakte_core/mordakte_core.dart' show Abendfassung, PartyPhase;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../party_widgets/hilfe.dart' show spieleBis;

const _laedt = 'Die Akte wird vorbereitet …';

/// Startet die App auf einem Handy an [ort]; [ablage] ist der Gerätespeicher
/// (bleibt über ein „Neuladen“ erhalten).
Future<AppState> _oeffnen(WidgetTester tester, String ort, {Map<String, Object> ablage = const {}}) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  SharedPreferences.setMockInitialValues(ablage);
  final state = AppState(meta: MetaStore.memory()..name = 'Test', scenarios: const {});
  await tester.runAsync(() async {
    // Was die Seiten laden, in echter Zeit vorab (siehe assistent_test.dart).
    await AktenKatalog.laden();
    await PartyDaten.laden(rootBundle, fall: 'schlosskeller');
    await ladeAbstecher('schlosskeller');
    await ladeKartenKatalog();
    await tester.pumpWidget(MordakteApp(app: state, initialLocation: ort));
  });
  await _warten(tester);
  return state;
}

Future<void> _warten(WidgetTester tester, {Finder? bis}) async {
  for (var i = 0; i < 400; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 10)));
    await tester.pump(const Duration(milliseconds: 16));
    final fertig = find.text(_laedt).evaluate().isEmpty && (bis == null || bis.evaluate().isNotEmpty);
    if (fertig && i >= 3) break;
  }
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
}

Future<void> _tippen(WidgetTester tester, String text, {Finder? bis}) async {
  await tester.tap(find.text(text).first);
  await _warten(tester, bis: bis);
}

/// Assistent bis „Abend beginnen“ (Akte vorgewählt, Standardeinstellungen;
/// [lang]: der lange Abend, M7b).
Future<void> _soloAbend(WidgetTester tester, {bool lang = false}) async {
  await _tippen(tester, 'Weiter');
  await _tippen(tester, 'Solo mit Bots');
  await _tippen(tester, 'Weiter');
  if (lang) {
    await tester.ensureVisible(find.text('Langer Abend'));
    await _tippen(tester, 'Langer Abend');
  }
  await tester.tap(find.text('Weiter'));
  await _warten(tester, bis: find.text('Bereit?'));
  await _tippen(tester, 'Abend beginnen', bis: find.byType(AbendSeite));
}

AbendHalter _halter(WidgetTester tester) => tester.element(find.byType(AbendSeite)).read<AbendHalter>();

/// Der abgelegte Stand im Gerätespeicher (roh).
Future<String?> _ablage(WidgetTester tester) =>
    tester.runAsync(() async => (await SharedPreferences.getInstance()).getString(AbendSpeicher.schluessel)).then((v) => v);

void main() {
  testWidgets('Nach dem Neuladen setzt die Detektei den Solo-Abend an derselben Stelle fort', (tester) async {
    var state = await _oeffnen(tester, Routes.abendNeu);
    await _soloAbend(tester);
    final s = _halter(tester).sitzung!;
    expect(s.phase, PartyPhase.rollen);
    s.weiter();
    s.weiter();
    await _warten(tester);
    final phase = s.phase;
    final code = s.fallCode.code;
    expect(phase.index, greaterThan(PartyPhase.rollen.index));
    final roh = await _ablage(tester);
    expect(roh, isNotNull, reason: 'Nach jedem Schritt liegt der Abend auf dem Gerät');
    expect((jsonDecode(roh!) as Map)['phase'], phase.name);

    // Neuladen: Der Speicher bleibt, alles andere beginnt von vorn.
    await tester.pumpWidget(const SizedBox.shrink());
    state.dispose();
    // Das Neuladen auf /abend landet in der Detektei, dort liegt der Abend bereit.
    state = await _oeffnen(tester, Routes.abend, ablage: {AbendSpeicher.schluessel: roh});
    expect(find.byType(DetekteiSeite), findsOneWidget);
    expect(find.text('Abend fortsetzen'), findsOneWidget);
    await _tippen(tester, 'Abend fortsetzen', bis: find.byType(AbendSeite));
    final weiter = _halter(tester).sitzung;
    expect(weiter, isNotNull, reason: 'Der Abend ist wieder da');
    expect(weiter!.phase, phase);
    expect(weiter.solo, isTrue);
    expect(weiter.fallCode.code, code, reason: 'Derselbe Fall');
    expect(find.byType(DetekteiSeite), findsNothing);
    expect(await _ablage(tester), isNotNull, reason: 'Er liegt weiter ab');
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    state.dispose();
  });

  testWidgets('Ein langer Abend bleibt nach dem Neuladen lang (M7b)', (tester) async {
    var state = await _oeffnen(tester, Routes.abendNeu);
    await _soloAbend(tester, lang: true);
    final s = _halter(tester).sitzung!;
    expect(s.fassung, Abendfassung.lang);
    s.weiter();
    await _warten(tester);
    final roh = (await _ablage(tester))!;
    final einrichten = ((jsonDecode(roh) as Map)['befehle'] as List).cast<Map<String, Object?>>().firstWhere((b) => b['b'] == 'einrichten');
    expect(einrichten['fassung'], 'lang', reason: 'Der lange Abend steht im Journal');
    final samen = s.weltSamen;
    await tester.pumpWidget(const SizedBox.shrink());
    state.dispose();
    state = await _oeffnen(tester, Routes.abend, ablage: {AbendSpeicher.schluessel: roh});
    await _tippen(tester, 'Abend fortsetzen', bis: find.byType(AbendSeite));
    final weiter = _halter(tester).sitzung!;
    expect([weiter.fassung, weiter.weltSamen, weiter.phase], [Abendfassung.lang, samen, s.phase]);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    state.dispose();
  });

  testWidgets('Ein kurzer Abend legt keine Fassung ab (bytegleich wie vor M7b)', (tester) async {
    final state = await _oeffnen(tester, Routes.abendNeu);
    await _soloAbend(tester);
    expect(_halter(tester).sitzung!.fassung, Abendfassung.kurz);
    final roh = (await _ablage(tester))!;
    expect(roh.contains('fassung'), isFalse);
    await tester.pumpWidget(const SizedBox.shrink());
    state.dispose();
  });

  testWidgets('Die Detektei zeigt „Abend fortsetzen“; Verwerfen löscht den Stand', (tester) async {
    var state = await _oeffnen(tester, Routes.abendNeu);
    await _soloAbend(tester);
    final roh = (await _ablage(tester))!;
    await tester.pumpWidget(const SizedBox.shrink());
    state.dispose();

    state = await _oeffnen(tester, Routes.start, ablage: {AbendSpeicher.schluessel: roh});
    expect(find.text('Abend fortsetzen'), findsOneWidget);
    expect(find.textContaining('Spuk im Schlosskeller'), findsWidgets);
    await _tippen(tester, 'Abend verwerfen');
    expect(find.text('Abend fortsetzen'), findsNothing);
    expect(await _ablage(tester), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    state.dispose();

    state = await _oeffnen(tester, Routes.start, ablage: {AbendSpeicher.schluessel: roh});
    await _tippen(tester, 'Abend fortsetzen', bis: find.byType(AbendSeite));
    expect(_halter(tester).sitzung?.phase, PartyPhase.rollen, reason: 'Fortsetzen über die Detektei');
    await tester.pumpWidget(const SizedBox.shrink());
    state.dispose();
  });

  testWidgets('Auf dem Schlussbild bleibt der Abend liegen, bis die Belohnung gebucht ist', (tester) async {
    var state = await _oeffnen(tester, Routes.abendNeu);
    await _soloAbend(tester);
    final s = _halter(tester).sitzung!;
    spieleBis(s, PartyPhase.ende);
    await _warten(tester);
    final roh = await _ablage(tester);
    expect(roh, isNotNull, reason: 'Wer die App auf dem Schlussbild schließt (etwa beim Teilen), verliert nichts');
    expect((jsonDecode(roh!) as Map)['phase'], 'ende');

    // Neustart auf dem Schlussbild: fortsetzen und die Belohnung doch noch abholen.
    await tester.pumpWidget(const SizedBox.shrink());
    state.dispose();
    state = await _oeffnen(tester, Routes.start, ablage: {AbendSpeicher.schluessel: roh});
    await _tippen(tester, 'Abend fortsetzen', bis: find.byType(AbendSeite));
    expect(_halter(tester).sitzung?.phase, PartyPhase.ende);
    await tester.ensureVisible(find.text('Belohnung ansehen'));
    await _tippen(tester, 'Belohnung ansehen', bis: find.byType(BelohnungSeite));
    expect(find.byType(BelohnungSeite), findsOneWidget);
    await _warten(tester, bis: find.text('Zur Detektei'));
    expect(state.meta.gebuchteAbende, hasLength(1), reason: 'Die Belohnung ist gebucht');
    expect(await _ablage(tester), isNull, reason: 'Nach der Buchung ist der Stand weg');
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    state.dispose();
  });

  testWidgets('Ein neuer Abend fragt, bevor er einen abgelegten ersetzt', (tester) async {
    var state = await _oeffnen(tester, Routes.abendNeu);
    await _soloAbend(tester);
    final roh = (await _ablage(tester))!;
    await tester.pumpWidget(const SizedBox.shrink());
    state.dispose();

    state = await _oeffnen(tester, Routes.abendNeu, ablage: {AbendSpeicher.schluessel: roh});
    await _tippen(tester, 'Weiter');
    await _tippen(tester, 'Ein Gerät reihum');
    await _tippen(tester, 'Weiter');
    await tester.tap(find.text('Weiter'));
    await _warten(tester, bis: find.text('Bereit?'));
    await _tippen(tester, 'Abend beginnen', bis: find.byType(MKarteikartenDialog));
    expect(find.text('Abend ersetzen?'), findsOneWidget);
    await _tippen(tester, 'Zurück');
    expect(find.byType(AbendSeite), findsNothing, reason: 'Zurück lässt den abgelegten Abend in Ruhe');
    expect(await _ablage(tester), roh);
    await _tippen(tester, 'Abend beginnen', bis: find.byType(MKarteikartenDialog));
    await _tippen(tester, 'Neuen Abend beginnen', bis: find.byType(AbendSeite));
    expect(_halter(tester).sitzung?.solo, isFalse, reason: 'Der neue Abend läuft');
    expect(await _ablage(tester), isNot(roh), reason: 'Der neue Abend hat den alten ersetzt');
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    state.dispose();
  });

  testWidgets('Abbrechen löscht den Stand; ein kaputter Stand führt in die Detektei', (tester) async {
    var state = await _oeffnen(tester, Routes.abendNeu);
    await _soloAbend(tester);
    expect(await _ablage(tester), isNotNull);
    await tester.tap(find.text('Abend abbrechen'));
    await _warten(tester, bis: find.byType(MKarteikartenDialog));
    await tester.tap(find.descendant(of: find.byType(MKarteikartenDialog), matching: find.text('Abend abbrechen')));
    await _warten(tester, bis: find.byType(DetekteiSeite));
    expect(await _ablage(tester), isNull, reason: 'Abgebrochen ist abgebrochen');
    expect(find.text('Abend fortsetzen'), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
    state.dispose();

    final kaputt = jsonEncode({'format': 'abendstand/2', 'fall': 'schlosskeller', 'salz': 'aa', 'titel': 'X', 'befehle': [{'b': 'zaubern'}]});
    state = await _oeffnen(tester, Routes.start, ablage: {AbendSpeicher.schluessel: kaputt});
    await _tippen(tester, 'Abend fortsetzen');
    expect(find.byType(DetekteiSeite), findsOneWidget);
    expect(find.text('Abend fortsetzen'), findsNothing);
    expect(await _ablage(tester), isNull, reason: 'Ein Stand, der sich nicht abspielen lässt, ist verworfen');
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    state.dispose();
  });

  testWidgets('Ein Schlosskeller-Abend aus der Fassung vor den Befragungen wird mit Hinweis verworfen', (tester) async {
    final alt = jsonEncode({
      'format': 'abendstand/1',
      'fall': 'schlosskeller',
      'salz': '00aa11bb22cc33dd',
      'titel': 'Spuk im Schlosskeller',
      'phase': 'gespraeche',
      'runde': 1,
      'befehle': [
        {'b': 'titel'},
        {'b': 'einrichten', 'rollen': 4, 'detektiv': 'w', 'solo': true},
        {'b': 'gelesen', 'id': 'g_ahmet_1_1'},
      ],
    });
    final state = await _oeffnen(tester, Routes.start, ablage: {AbendSpeicher.schluessel: alt});
    expect(find.text('Abend fortsetzen'), findsOneWidget, reason: 'Die Detektei zeigt den alten Stand zunächst an');
    await _tippen(tester, 'Abend fortsetzen');
    expect(find.byType(DetekteiSeite), findsOneWidget);
    expect(find.byType(AbendSeite), findsNothing);
    expect(find.text('Dieser Abend stammt aus einer älteren Fassung der Akte. Er lässt sich nicht fortsetzen.'), findsOneWidget);
    expect(find.text('Abend fortsetzen'), findsNothing);
    expect(await _ablage(tester), isNull, reason: 'Der alte Stand ist verworfen');
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    state.dispose();
  });
}
