// Sammlung (/sammlung) und Deck-Bau (/sammlung/deck) in der echten App: Fortschritt,
// verdeckte Karten, Tipp aufs Blatt, Ersetzen gleicher Art und die Grenzen des Decks.
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mordakte/app/app.dart';
import 'package:mordakte/app/app_state.dart';
import 'package:mordakte/app/router.dart';
import 'package:mordakte/detektei/akten.dart';
import 'package:mordakte/karten/widgets/karten_ansicht.dart';
import 'package:mordakte/meta/meta_store.dart';
import 'package:mordakte_core/runden.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Alle `content/karten/*.json` ohne Schemata, wie der Lader der App sie findet.
KartenKatalog echterKatalog() {
  final dateien = Directory('content/karten').listSync().whereType<File>()
      .where((f) => f.path.endsWith('.json') && !f.path.endsWith('.schema.json'))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));
  return KartenKatalog.ausDateien([for (final f in dateien) jsonDecode(f.readAsStringSync()) as Map<String, Object?>]);
}

const koefferchen = 'mordakte:forensic:koefferchen'; // Werkzeug, Startset
const zweiter = 'mordakte:profiler:zweiter_blick'; // Gründlich, Startset
const presseausweis = 'mordakte:journalist:presseausweis'; // Abstecher, Startset
const streifenplan = 'mordakte:excop:streifenplan'; // Umweg, Startset
const notfalltasche = 'mordakte:medic:notfalltasche'; // Zeit, Startset
const stirnlampe = 'schlosskeller:tim:stirnlampe'; // Werkzeug, 1 Ladung
const zoomfinger = 'schlosskeller:johanna:zoomfinger'; // Gründlich, 2 Ladungen
const ertappt = 'schlosskeller:olli:ertappt'; // Werkzeug, 2 Ladungen

/// Gerät mit gespeichertem Kartenkonto: Besitz (Anzahl), NEU-Karten und Deck.
Future<MetaStore> konto({Map<String, int> besitz = const {}, Set<String> neu = const {}, List<String> deck = const []}) {
  SharedPreferences.setMockInitialValues({
    'mordakte.karten': jsonEncode({
      'v': 1,
      'besitz': {for (final e in besitz.entries) e.key: {'n': e.value, 'neu': neu.contains(e.key)}},
      'deck': deck,
    }),
  });
  return MetaStore.load();
}

/// Startet die App an [ort] auf einem Handy und wartet, bis [bereit] gefunden wird.
Future<void> oeffnen(WidgetTester t, MetaStore meta, String ort, Finder bereit) async {
  t.view.physicalSize = const Size(390, 844);
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.resetPhysicalSize);
  addTearDown(t.view.resetDevicePixelRatio);
  final state = AppState(meta: meta, scenarios: const {});
  await t.runAsync(() async {
    await AktenKatalog.laden();
    await t.pumpWidget(MordakteApp(app: state, initialLocation: ort));
  });
  for (var i = 0; i < 100 && bereit.evaluate().isEmpty; i++) {
    await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
    await t.pump(const Duration(milliseconds: 50));
  }
  await t.pump(const Duration(milliseconds: 300));
}

Future<void> tippen(WidgetTester t, Finder f) async {
  await t.ensureVisible(f);
  await t.tap(f);
  for (var i = 0; i < 10; i++) {
    await t.pump(const Duration(milliseconds: 100)); // Schritte: der Übergang startet erst im ersten Bild
  }
}

Key schluessel(String id) => ValueKey(id);

void main() {
  late KartenKatalog katalog;
  setUpAll(() => katalog = echterKatalog());

  testWidgets('Sammlung: Fortschritt, verdeckte Karten, Tipp öffnet das Blatt und nimmt NEU', (t) async {
    final gesamt = katalog.vonAkte('schlosskeller').length;
    final meta = (await t.runAsync(() => konto(
          besitz: {for (final id in [koefferchen, zweiter, presseausweis, streifenplan, notfalltasche]) id: 1, stirnlampe: 1, ertappt: 2},
          neu: {ertappt},
        )))!;
    await oeffnen(t, meta, Routes.sammlung, find.text('2 von $gesamt Karten'));

    expect(find.text('2 von $gesamt Karten'), findsOneWidget, reason: 'Stirnlampe und Ertappt aus der Akte besessen');
    expect(find.byType(UnbekannteKarte), findsNWidgets(gesamt - 2), reason: 'alle übrigen Karten liegen verdeckt');
    expect(find.byKey(schluessel('karte-$stirnlampe')), findsOneWidget);
    expect(find.text('NEU'), findsOneWidget, reason: 'Ertappt ist neu');
    expect(find.text('2×'), findsOneWidget, reason: 'zwei Exemplare zeigen die Anzahl');

    await tippen(t, find.byKey(schluessel('karte-$ertappt')));
    expect(find.text('Du besitzt 2 Exemplare.'), findsOneWidget);
    expect(find.text('Schließen'), findsOneWidget);
    await tippen(t, find.text('Schließen'));
    expect(find.text('Du besitzt 2 Exemplare.'), findsNothing);
    expect(meta.neueKarten, isEmpty, reason: 'angesehen nimmt die NEU-Marke');
    expect(t.takeException(), isNull);
  });

  testWidgets('Deck: gleiche Art ersetzt, Ladungs- und Platzgrenze melden sich', (t) async {
    final meta = (await t.runAsync(() => konto(
          besitz: {for (final id in [koefferchen, zweiter, presseausweis, streifenplan, notfalltasche]) id: 1, stirnlampe: 1, zoomfinger: 1, ertappt: 1},
          deck: [koefferchen, zweiter, presseausweis],
        )))!;
    await oeffnen(t, meta, Routes.sammlungDeck, find.byKey(schluessel('deck-karte-$stirnlampe')));
    expect(find.text('Ladungen 3 von 4'), findsOneWidget);

    // Werkzeug ersetzt Werkzeug, die Karte bleibt auf ihrem Platz.
    await tippen(t, find.byKey(schluessel('deck-karte-$stirnlampe')));
    expect(meta.deck, [stirnlampe, zweiter, presseausweis]);
    expect(find.byKey(schluessel('deck-platz-$stirnlampe')), findsOneWidget);
    expect(find.byKey(schluessel('deck-platz-$koefferchen')), findsNothing);

    // Gründlich mit zwei Ladungen: 4 von 4 ist erlaubt.
    await tippen(t, find.byKey(schluessel('deck-karte-$zoomfinger')));
    expect(meta.deck, [stirnlampe, zoomfinger, presseausweis]);
    expect(find.text('Ladungen 4 von 4'), findsOneWidget);

    // Werkzeug mit zwei Ladungen würde auf 5 kommen: abgelehnt, Deck unverändert.
    await tippen(t, find.byKey(schluessel('deck-karte-$ertappt')));
    expect(find.text('Zu viele Ladungen für das Deck.'), findsOneWidget);
    expect(meta.deck, [stirnlampe, zoomfinger, presseausweis]);

    // Vierte Art bei vollem Deck: abgelehnt.
    await tippen(t, find.byKey(schluessel('deck-karte-$streifenplan')));
    expect(find.text('Das Deck ist voll. Nimm zuerst eine Karte heraus.'), findsOneWidget);
    expect(meta.deck, hasLength(TischVorrat.maxKarten));

    // Herausnehmen macht Platz; danach passt die Umweg-Karte.
    await tippen(t, find.byKey(schluessel('deck-platz-$presseausweis')));
    expect(meta.deck, [stirnlampe, zoomfinger]);
    expect(find.text('Ladungen 3 von 4'), findsOneWidget);
    await tippen(t, find.byKey(schluessel('deck-karte-$streifenplan')));
    expect(meta.deck, [stirnlampe, zoomfinger, streifenplan]);
    expect(t.takeException(), isNull);
  });
}
