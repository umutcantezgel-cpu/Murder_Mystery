// M8 Einstieg: Wer noch keinen Abend gespielt hat, sieht in der Detektei „Dein
// erster Fall“; ein Tipp öffnet sofort einen Solo-Abend im Schlosskeller. Nach
// dem ersten gebuchten Abend oder mit einem abgelegten Abend ist die Akte weg.
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mordakte/abend/abend_halter.dart';
import 'package:mordakte/abend/abend_seite.dart';
import 'package:mordakte/abend/abend_speicher.dart';
import 'package:mordakte/app/app.dart';
import 'package:mordakte/app/app_state.dart';
import 'package:mordakte/app/router.dart';
import 'package:mordakte/detektei/akten.dart';
import 'package:mordakte/karten/katalog_laden.dart';
import 'package:mordakte/meta/meta_store.dart';
import 'package:mordakte/party/daten.dart';
import 'package:mordakte/party/sitzung.dart';
import 'package:mordakte_core/mordakte_core.dart';
import 'package:mordakte_core/runden.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../party_widgets/hilfe.dart';

Future<AppState> _oeffnen(WidgetTester tester, MetaStore meta, {Map<String, Object> ablage = const {}}) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  SharedPreferences.setMockInitialValues(ablage);
  final state = AppState(meta: meta, scenarios: const {});
  await tester.runAsync(() async {
    await AktenKatalog.laden();
    await PartyDaten.laden(rootBundle, fall: 'schlosskeller');
    await ladeAbstecher('schlosskeller');
    await ladeKartenKatalog();
    await tester.pumpWidget(MordakteApp(app: state, initialLocation: Routes.start));
  });
  await _warten(tester);
  return state;
}

Future<void> _warten(WidgetTester tester, {Finder? bis}) async {
  for (var i = 0; i < 400; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 10)));
    await tester.pump(const Duration(milliseconds: 16));
    if ((bis == null || bis.evaluate().isNotEmpty) && i >= 3) break;
  }
  await tester.pump(const Duration(milliseconds: 500));
}

KartenKatalog get _katalog {
  final dateien = Directory('content/karten').listSync().whereType<File>()
      .where((f) => f.path.endsWith('.json') && !f.path.endsWith('.schema.json'))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));
  return KartenKatalog.ausDateien([for (final f in dateien) jsonDecode(f.readAsStringSync()) as Map<String, Object?>]);
}

void main() {
  testWidgets('Neu in der Detektei: „Sofort ermitteln“ öffnet einen Solo-Abend im Schlosskeller', (tester) async {
    final state = await _oeffnen(tester, MetaStore.memory()..name = 'Ada');
    expect(find.text('Dein erster Fall'), findsOneWidget);
    await tester.tap(find.text('Sofort ermitteln'));
    await _warten(tester, bis: find.byType(AbendSeite));
    final s = tester.element(find.byType(AbendSeite)).read<AbendHalter>().sitzung!;
    expect(s.daten.fall, 'schlosskeller');
    expect(s.solo, isTrue);
    expect(s.phase, PartyPhase.rollen, reason: 'Ohne Assistent direkt in den Abend');
    expect(s.geburtstagskind, 'Ada');
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    state.dispose();
  });

  testWidgets('Nach dem ersten Abend und mit abgelegtem Abend gibt es keinen „ersten Fall“', (tester) async {
    final meta = MetaStore.memory()..name = 'Ada';
    final s = neueSitzung();
    spieleBis(s, PartyPhase.ende);
    meta.verbucheAbend(abendId: s.abendId, ergebnis: s.abendErgebnis(rolle: 'klasse:forensic'), katalog: _katalog);
    var state = await _oeffnen(tester, meta);
    expect(find.text('Dein erster Fall'), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
    state.dispose();

    final stand = PartySitzung(partyDaten, salz: 'abcdabcdabcdabcd')..einrichten(rollen: 4, detektiv: 'w', solo: true);
    state = await _oeffnen(tester, MetaStore.memory()..name = 'Bo', ablage: {AbendSpeicher.schluessel: jsonEncode(stand.abendstand)});
    expect(find.text('Dein erster Fall'), findsNothing, reason: 'Erst den abgelegten Abend fortsetzen');
    expect(find.text('Abend fortsetzen'), findsOneWidget);
    // Wer den abgelegten Abend verwirft, findet den ersten Fall wieder.
    await tester.tap(find.text('Abend verwerfen'));
    await _warten(tester, bis: find.text('Dein erster Fall'));
    expect(find.text('Dein erster Fall'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    state.dispose();
  });
}
