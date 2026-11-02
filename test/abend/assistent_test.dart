// Assistent für einen neuen Abend (/abend/neu): „Weiter“ erst nach einer Spielweise,
// Solo- und Reihum-Abend bis in die Rollenphase, gesperrte Spielweise, /abend ohne Abend,
// Zurück-Taste im Assistenten, „Abend abbrechen“ mit Rückfrage auf dem Solo-Abend.
// „Zum Drucken“ (E17) richtet keinen Abend ein: Der Startknopf „Zur Druckmappe“ öffnet
// die Druckmappe der Akte.
import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mordakte/abend/abend_halter.dart';
import 'package:mordakte/abend/abend_seite.dart';
import 'package:mordakte/abend/abend_speicher.dart';
import 'package:mordakte/abend/einrichtung/abend_neu_seite.dart';
import 'package:mordakte/abend/einrichtung/abschnitte.dart';
import 'package:mordakte/abend/einrichtung/klasse_zeile.dart';
import 'package:mordakte/app/app.dart';
import 'package:mordakte/app/app_state.dart';
import 'package:mordakte/app/router.dart';
import 'package:mordakte/detektei/akten.dart';
import 'package:mordakte/detektei/detektei_seite.dart';
import 'package:mordakte/detektei/druckmappe_seite.dart';
import 'package:mordakte/karten/katalog_laden.dart';
import 'package:mordakte/karten/widgets/deck_zeile.dart';
import 'package:mordakte/l10n/gen/app_localizations_de.dart';
import 'package:mordakte/meta/meta_store.dart';
import 'package:mordakte/party/daten.dart';
import 'package:mordakte/party/kammer_laden.dart';
import 'package:mordakte/stil/stil.dart';
import 'package:mordakte_core/mordakte_core.dart' show Abendfassung, PartyPhase, abendEinstimmungMinuten, abendMinutenCa;
import 'package:mordakte/party/sitzung.dart';

import '../party_widgets/erzaehl_hilfe.dart' show erzaehlDaten;
import '../party_widgets/hilfe.dart' show partyDaten;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Startet die App auf einem Handy. Akte und Daten lädt die App über rootBundle;
/// der Zwischenspeicher wird vorab gefüllt, damit die Schritte ohne Wartezeit laufen.
Future<AppState> oeffnen(WidgetTester tester, {String ort = Routes.abendNeu, MetaStore? meta}) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  SharedPreferences.setMockInitialValues({});
  final state = AppState(meta: meta ?? (MetaStore.memory()..name = 'Test'), scenarios: const {});
  await tester.runAsync(() async {
    // rootBundle merkt sich jede Textdatei samt Ladevorgang (CachingAssetBundle). Was der
    // Assistent braucht, lädt deshalb hier in echter Zeit: ein Vorgang, der erst in der
    // Testuhr startet und endet, hängte sonst jeden späteren Test am gemerkten Ergebnis.
    await AktenKatalog.laden();
    await PartyDaten.laden(rootBundle, fall: 'schlosskeller');
    await ladeAbstecher('schlosskeller');
    await PartyDaten.laden(rootBundle, fall: 'gewoelbe');
    await ladeAbstecher('gewoelbe');
    await ladeKartenKatalog();
    await tester.pumpWidget(MordakteApp(app: state, initialLocation: ort));
  });
  await warten(tester);
  return state;
}

final _de = LDe();

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

/// [f] innerhalb der Karteikarte „Deine Ermittlerklasse“.
Finder _inKlasse(Finder f) => find.descendant(of: find.byType(KlasseZeile), matching: f);

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

  testWidgets('Die Gästeliste der Steckbrief-Seite füllt reihum Personenzahl und Namen vor, auch den des Detektivs (M5)', (tester) async {
    final meta = MetaStore.memory()
      ..name = 'Test'
      ..setzeGaesteliste(
        'schlosskeller',
        const GaesteListe(personen: 5, gaeste: [Gast('Ayla', 'fatma'), Gast('Bo', 'tugba'), Gast('Cem'), Gast('Dana', 'detective')]),
      );
    final state = await oeffnen(tester, ort: Routes.abendNeuMit('schlosskeller'), meta: meta);
    await tippen(tester, 'Ein Gerät reihum');
    await tippen(tester, 'Weiter');
    expect(find.text('5 Personen sitzen am Tisch'), findsOneWidget);
    final fatma = tester.widget<TextField>(find.byKey(const ValueKey('name-fatma')));
    expect(fatma.controller!.text, 'Ayla');
    final ahmet = tester.widget<TextField>(find.byKey(const ValueKey('name-ahmet')));
    expect(ahmet.controller!.text, isEmpty);
    // Tugba ist bei fünf Personen nicht dabei; ihr Name taucht nirgends auf.
    expect(find.byKey(const ValueKey('name-tugba')), findsNothing);
    await tester.tap(find.text('Weiter'));
    await warten(tester, bis: find.text('Bereit?'));
    await tippen(tester, 'Abend beginnen');
    final s = tester.element(find.byType(AbendSeite)).read<AbendHalter>().sitzung!;
    expect(s.einstellungen.rollen, 5);
    expect(s.spielerName('fatma'), 'Ayla');
    expect(s.spielerName('ahmet'), 'Ahmet');
    expect(s.detektivName, 'Dana', reason: 'Der Detektiv-Eintrag füllt das Namensfeld des Detektivs');
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

  testWidgets('Gewölbe hat eine feste Lösung: Hinweis statt Fall-Code', (tester) async {
    final state = await oeffnen(tester);
    await tippen(tester, 'Spuk im Gewölbe');
    await tippen(tester, 'Weiter');
    await tippen(tester, 'Solo mit Bots');
    await tippen(tester, 'Weiter');
    expect(find.byKey(const ValueKey('feste-loesung')), findsOneWidget, reason: 'Der Hinweis zur festen Lösung');
    expect(find.text('Code eingeben'), findsNothing, reason: 'Ohne Fall-Code keine Eingabe');
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    state.dispose();
  });

  group('Zum Drucken (E17)', () {
    /// Die Abschnitte eines Abends in der App (Schlosskeller reihum); zum Drucken entfallen sie alle.
    const abendAbschnitte = [
      PersonenAbschnitt,
      DetektivNameAbschnitt,
      RollenAmTischAbschnitt,
      DetektivAbschnitt,
      FallAbschnitt,
      FassungAbschnitt,
      EinstimmungAbschnitt,
      MomentAbschnitt,
      DauerAbschnitt,
      StimmeAbschnitt,
    ];

    /// Akte (Schlosskeller, vorgewählt), „Ein Gerät reihum“, Einstellungen; gibt deren Werte zurück.
    Future<EinrichtungsWerte> bisZuDenEinstellungen(WidgetTester tester) async {
      await tippen(tester, 'Weiter');
      await tippen(tester, 'Ein Gerät reihum');
      await tippen(tester, 'Weiter');
      return tester.widget<EinrichtungsAbschnitte>(find.byType(EinrichtungsAbschnitte)).werte;
    }

    /// Tippt eine Spielart an („Am Bildschirm“ oder „Zum Drucken“), wo immer sie im Formular steht.
    Future<void> spielart(WidgetTester tester, String text) async {
      await tester.ensureVisible(find.text(text));
      await tippen(tester, text);
    }

    testWidgets('Der Startknopf heißt „Zur Druckmappe“ und öffnet die Druckmappe der Akte; es beginnt kein Abend', (tester) async {
      final state = await oeffnen(tester);
      // Ein abgelegter Abend: Zum Drucken fragt nicht und ersetzt ihn nicht.
      final abgelegt = jsonEncode({'format': PartySitzung.abendstandFormate.first, 'fall': 'schlosskeller'});
      await tester.runAsync(() async {
        // Die Druckmappe liest das Kammerspiel aus dem Bündel: vorab in echter Zeit laden.
        await kammerGrundlageLaden();
        await (await SharedPreferences.getInstance()).setString(AbendSpeicher.schluessel, abgelegt);
      });
      final werte = await bisZuDenEinstellungen(tester);
      final s = werte.sitzung;
      final druck = s.ui('ui.einrichtung.spiel_druck'), bildschirm = s.ui('ui.einrichtung.spiel_bildschirm');
      expect(tester.widget<EinrichtungsAbschnitte>(find.byType(EinrichtungsAbschnitte)).zurDruckmappe, isTrue);

      // Am Bildschirm (Vorgabe): alle Abschnitte wie bisher, ohne Hinweis zum Drucken.
      for (final typ in abendAbschnitte) {
        expect(find.byType(typ), findsOneWidget, reason: '$typ am Bildschirm');
      }
      expect(find.byType(SpielartAbschnitt), findsOneWidget);
      expect(find.text(s.ui('ui.einrichtung.hinweis')), findsOneWidget, reason: 'Untertitel der Einrichtung');
      expect(find.byKey(const ValueKey('druck-mappe-hinweis')), findsNothing);
      // Ein falscher Fall-Code sperrt „Weiter“ am Bildschirm.
      await tester.ensureVisible(find.text('Code eingeben'));
      await tippen(tester, 'Code eingeben');
      await tester.enterText(find.byKey(const ValueKey('code')), 'AB');
      await warten(tester);
      expect(werte.codeOk, isFalse);
      expect(knopf(tester, 'Weiter').onPressed, isNull, reason: 'Falscher Fall-Code');

      // Zum Drucken: nur die Spielart mit dem Hinweis auf die Druckmappe.
      await spielart(tester, druck);
      expect(werte.druck, isTrue);
      for (final typ in abendAbschnitte) {
        expect(find.byType(typ), findsNothing, reason: '$typ zum Drucken');
      }
      expect(find.byType(SpielartAbschnitt), findsOneWidget);
      expect(find.byType(TextField), findsNothing, reason: 'Keine Namen und kein Fall-Code');
      expect(find.byKey(const ValueKey('druck-mappe-hinweis')), findsOneWidget);
      expect(find.text(_de.abend_druck_mappe_hinweis), findsOneWidget);
      expect(find.text(_de.abend_einstellungen_druck_hinweis), findsOneWidget, reason: 'Untertitel zum Drucken');
      expect(find.text(s.ui('ui.einrichtung.hinweis')), findsNothing);
      // Die alten Hinweise passen nicht mehr: Der Bildschirm führt nicht durch den Abend.
      expect(find.text(s.ui('ui.einrichtung.druck_hinweis')), findsNothing);
      expect(find.byKey(const ValueKey('nur-pdfs-hinweis')), findsNothing);
      expect(find.text(_de.abend_druck_nur_pdfs), findsNothing);
      expect(find.text(druck).hitTestable(), findsOneWidget, reason: 'Die Wahl bleibt im Bild');
      expect(knopf(tester, 'Weiter').onPressed, isNotNull, reason: 'Zum Drucken zählt kein Fall-Code');

      // Zurück zu „Am Bildschirm“: alles wieder da, samt Eingaben; der falsche Code sperrt wieder.
      await spielart(tester, bildschirm);
      expect(werte.druck, isFalse);
      for (final typ in abendAbschnitte) {
        expect(find.byType(typ), findsOneWidget, reason: '$typ wieder am Bildschirm');
      }
      expect(find.text(bildschirm).hitTestable(), findsOneWidget, reason: 'Die Seite rollt zur Wahl zurück');
      expect(tester.widget<TextField>(find.byKey(const ValueKey('code'))).controller!.text, 'AB');
      expect(knopf(tester, 'Weiter').onPressed, isNull);

      // Wieder zum Drucken und weiter zum Start: Akte und Spielart, kein Abend in der App.
      await spielart(tester, druck);
      await tester.tap(find.text('Weiter'));
      await warten(tester, bis: find.text('Bereit?'));
      expect(find.text('SCHRITT 4 VON 4'), findsOneWidget);
      expect(find.text(_de.abend_start_druck_hinweis), findsOneWidget);
      expect(find.text(_de.abend_start_hinweis), findsNothing, reason: 'Es beginnt keine Rollenverteilung');
      expect(find.byWidgetPredicate((w) => w is MFeld && w.name == _de.abend_start_spielweise && w.wert == druck), findsOneWidget);
      expect(find.byType(MFeld), findsOneWidget, reason: 'Personen, Dauer und Fassung stellt die Druckmappe ein oder gibt es nicht');
      expect(find.byType(KlasseZeile), findsNothing, reason: 'Klasse und Belohnung gehören zu einem Abend in der App');
      expect(find.byType(DeckZeile), findsNothing);
      expect(find.text(_de.abend_start), findsNothing);
      expect(find.text(_de.abend_zur_druckmappe), findsOneWidget);
      final start = knopf(tester, _de.abend_zur_druckmappe);
      expect([start.onPressed, start.icon], [isNotNull, Icons.print_outlined]);

      // „Zur Druckmappe“: die Druckmappe der Akte; „Zurück“ führt von dort auf die Akte.
      await tester.tap(find.text(_de.abend_zur_druckmappe));
      await warten(tester, bis: find.text(_de.detektei_druck_vorbereiten));
      expect(find.byType(AbendNeuSeite), findsNothing);
      final mappe = tester.widget<DruckmappeSeite>(find.byType(DruckmappeSeite));
      expect([mappe.akteId, mappe.zurueck], ['schlosskeller', Routes.akteVon('schlosskeller')]);
      final ort = tester.element(find.byType(DruckmappeSeite));
      expect(GoRouter.of(ort).routeInformationProvider.value.uri.toString(), Routes.druckmappeVon('schlosskeller'));
      expect(find.text(_de.detektei_druck_vorbereiten), findsOneWidget, reason: 'Die Druckmappe ist geladen');
      expect(find.byType(MKarteikartenDialog), findsNothing, reason: 'Keine Rückfrage: es beginnt kein Abend');
      expect(find.byType(AbendSeite), findsNothing);
      expect(ort.read<AbendHalter>().laeuft, isFalse, reason: 'Kein Abend läuft');
      final danach = await tester.runAsync(() async => (await SharedPreferences.getInstance()).getString(AbendSpeicher.schluessel));
      expect(danach, abgelegt, reason: 'Der abgelegte Abend bleibt, wie er war');
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      state.dispose();
    });

    testWidgets('Am Bildschirm beginnt der Abend wie bisher, ohne Druckfassung', (tester) async {
      final state = await oeffnen(tester);
      final werte = await bisZuDenEinstellungen(tester);
      final s = werte.sitzung;
      // Einmal zum Drucken und zurück: Der Abend am Bildschirm bleibt, wie er war.
      await spielart(tester, s.ui('ui.einrichtung.spiel_druck'));
      await spielart(tester, s.ui('ui.einrichtung.spiel_bildschirm'));
      await tester.tap(find.text('Weiter'));
      await warten(tester, bis: find.text('Bereit?'));
      expect(find.text(_de.abend_start_hinweis), findsOneWidget);
      expect(find.text(_de.abend_zur_druckmappe), findsNothing);
      expect(find.byType(KlasseZeile), findsOneWidget);
      expect(find.byType(DeckZeile), findsOneWidget);
      expect(knopf(tester, _de.abend_start).icon, Icons.play_arrow_rounded);
      await tippen(tester, _de.abend_start);
      final abend = tester.element(find.byType(AbendSeite)).read<AbendHalter>().sitzung!;
      expect([abend.phase, abend.solo, abend.einstellungen.druck], [PartyPhase.rollen, false, false]);
      expect(find.byType(DruckmappeSeite), findsNothing);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      state.dispose();
    });

    testWidgets('Nur reihum: Solo und online wählen „Zum Drucken“ ab, der Raum öffnet sich wie bisher', (tester) async {
      final state = await oeffnen(tester);
      final werte = await bisZuDenEinstellungen(tester);
      final druck = werte.sitzung.ui('ui.einrichtung.spiel_druck');
      await spielart(tester, druck);
      expect(werte.druck, isTrue);
      // Online: Die Lobby richtet den Abend ein; ein früheres „Zum Drucken“ gilt dort nicht.
      await tippen(tester, 'Zurück');
      await tippen(tester, 'Jeder am eigenen Gerät');
      expect([werte.spielart, werte.druck], [Spielart.bildschirm, false]);
      await tippen(tester, 'Weiter');
      expect(find.byType(SpielartAbschnitt), findsNothing);
      expect(find.text(druck), findsNothing);
      expect(find.byType(FassungAbschnitt), findsOneWidget, reason: 'Online wie am Bildschirm');
      expect(find.byType(MomentAbschnitt), findsOneWidget);
      expect([werte.einstimmung, werte.einflussAn], [true, true], reason: 'Vorgaben eines Abends am Bildschirm');
      expect(find.text(_de.online_einstellungen_hinweis), findsOneWidget);
      await tester.tap(find.text('Weiter'));
      await warten(tester, bis: find.text('Raum öffnen'));
      expect(find.text('Raum öffnen'), findsOneWidget);
      expect(find.text(_de.abend_zur_druckmappe), findsNothing);
      // Solo: kein Druck, keine Wahl der Spielart.
      await tippen(tester, 'Zurück');
      await tippen(tester, 'Zurück');
      await tippen(tester, 'Ein Gerät reihum');
      await tippen(tester, 'Weiter');
      await spielart(tester, druck);
      expect(werte.druck, isTrue);
      await tippen(tester, 'Zurück');
      await tippen(tester, 'Solo mit Bots');
      expect([werte.spielart, werte.druck], [Spielart.bildschirm, false]);
      await tippen(tester, 'Weiter');
      expect(find.byType(SpielartAbschnitt), findsNothing);
      await tester.tap(find.text('Weiter'));
      await warten(tester, bis: find.text('Bereit?'));
      expect(find.text(_de.abend_start), findsOneWidget);
      expect(find.text(_de.abend_zur_druckmappe), findsNothing);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      state.dispose();
    });

    testWidgets('Eine Akte ohne Druckmappe bietet „Zum Drucken“ nicht an', (tester) async {
      final state = await oeffnen(tester);
      await tippen(tester, 'Spuk im Gewölbe');
      await tippen(tester, 'Weiter');
      await tippen(tester, 'Ein Gerät reihum');
      await tippen(tester, 'Weiter');
      final werte = tester.widget<EinrichtungsAbschnitte>(find.byType(EinrichtungsAbschnitte)).werte;
      expect(werte.druckbar, isFalse);
      expect(find.byType(SpielartAbschnitt), findsNothing);
      await tester.tap(find.text('Weiter'));
      await warten(tester, bis: find.text('Bereit?'));
      expect(find.text(_de.abend_start), findsOneWidget);
      expect(find.text(_de.abend_zur_druckmappe), findsNothing);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      state.dispose();
    });

    testWidgets('320 px und doppelte Schrift: Einstellungen und Start zum Drucken ohne Überlauf, der Knopf im Bild', (tester) async {
      final state = await oeffnen(tester);
      tester.view.physicalSize = const Size(320, 568);
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await warten(tester);
      await tippen(tester, 'Weiter');
      await tester.ensureVisible(find.text('Ein Gerät reihum'));
      await tippen(tester, 'Ein Gerät reihum');
      await tippen(tester, 'Weiter');
      final werte = tester.widget<EinrichtungsAbschnitte>(find.byType(EinrichtungsAbschnitte)).werte;
      await spielart(tester, werte.sitzung.ui('ui.einrichtung.spiel_druck'));
      expect(find.text(werte.sitzung.ui('ui.einrichtung.spiel_druck')).hitTestable(), findsOneWidget, reason: 'Die Wahl bleibt im Bild');
      expect(find.byKey(const ValueKey('druck-mappe-hinweis')), findsOneWidget);
      expect(tester.takeException(), isNull, reason: 'Einstellungen zum Drucken');
      await tester.tap(find.text('Weiter'));
      await warten(tester, bis: find.text('Bereit?'));
      expect(find.text(_de.abend_zur_druckmappe).hitTestable(), findsOneWidget, reason: 'Der Startknopf liegt im Bild');
      expect(tester.takeException(), isNull, reason: 'Start zum Drucken');
      await tester.pumpWidget(const SizedBox.shrink());
      state.dispose();
    });
  });

  group('Zeitbudget (M7b)', () {
    /// Die Schätzung unter der Rundendauer, als Zahl (`null`: keine Schätzung).
    int? ca(WidgetTester tester) {
      final f = find.byKey(const ValueKey('abend-ca'));
      if (f.evaluate().isEmpty) return null;
      return int.parse(RegExp(r'ca\. (\d+) Min\.').firstMatch(tester.widget<Text>(f).data!)!.group(1)!);
    }

    /// Wählt die Rundendauer [minuten] und gibt die Schätzung zurück.
    Future<int> mitDauer(WidgetTester tester, int minuten) async {
      final option = find.text('$minuten Minuten');
      await tester.ensureVisible(option);
      await tippen(tester, '$minuten Minuten');
      return ca(tester)!;
    }

    Future<void> fassung(WidgetTester tester, String beschriftung) async {
      await tester.ensureVisible(find.text(beschriftung));
      await tippen(tester, beschriftung);
    }

    bool feld(String name, String wert) => find.byWidgetPredicate((w) => w is MFeld && w.name == name && w.wert == wert).evaluate().isNotEmpty;

    testWidgets('Schlosskeller: kurz ca. 100 Min. (Vorgabe 15), lang ca. 120 Min. (Vorgabe 20); jede lange Schätzung über jeder kurzen', (tester) async {
      final state = await oeffnen(tester);
      await tippen(tester, 'Weiter');
      await tippen(tester, 'Ein Gerät reihum');
      await tippen(tester, 'Weiter');
      // Die Zeiten des Abends ohne Einstimmung (A-063); mit ihr prüft „Einstimmung“ unten.
      final werte = tester.widget<EinrichtungsAbschnitte>(find.byType(EinrichtungsAbschnitte)).werte..setzeEinstimmung(false);
      await tester.pump();
      expect(find.byType(FassungAbschnitt), findsOneWidget);
      expect(find.text('Kurzer Abend · ca. 100 Min.'), findsOneWidget);
      expect(find.text('Langer Abend · ca. 120 Min.'), findsOneWidget);
      expect([werte.fassung, werte.minuten, werte.minutenOptionen], [Abendfassung.kurz, 15, [10, 15, 20]]);
      await tester.ensureVisible(find.byKey(const ValueKey('abend-ca')));
      expect(find.text('Ganzer Abend: ca. 100 Min.'), findsOneWidget);
      expect(find.text('30 Minuten'), findsNothing, reason: 'Kurz: 10, 15 oder 20 Minuten');
      final kurz = [for (final m in [10, 15, 20]) await mitDauer(tester, m)];
      expect(kurz, [85, 100, 115]);

      await fassung(tester, 'Langer Abend · ca. 120 Min.');
      expect([werte.fassung, werte.minuten], [Abendfassung.lang, 20], reason: '20 passt, die Dauer bleibt');
      await tester.ensureVisible(find.byKey(const ValueKey('abend-ca')));
      expect(find.text('Ganzer Abend: ca. 120 Min.'), findsOneWidget);
      expect(find.byKey(const ValueKey('dauer-lang-hinweis')), findsOneWidget);
      final lang = [for (final m in [20, 25, 30, 40]) await mitDauer(tester, m)];
      expect(lang, [120, 135, 150, 180]);
      for (final l in lang) {
        for (final k in kurz) {
          expect(l, greaterThan(k), reason: 'lang $l gegen kurz $k');
        }
      }
      // Zurück zu kurz: 40 Minuten gibt es dort nicht, es gilt die Vorgabe 15.
      await fassung(tester, 'Kurzer Abend · ca. 100 Min.');
      expect([werte.fassung, werte.minuten], [Abendfassung.kurz, 15]);
      await fassung(tester, 'Langer Abend · ca. 120 Min.');
      expect(werte.minuten, 20);

      await tester.tap(find.text('Weiter'));
      await warten(tester, bis: find.text('Bereit?'));
      expect(feld('Abend', 'Langer Abend'), isTrue);
      expect(feld('Länge', 'ca. 120 Min.'), isTrue);
      expect(feld('Rundendauer', '20 Min.'), isTrue);
      await tippen(tester, 'Abend beginnen');
      final s = tester.element(find.byType(AbendSeite)).read<AbendHalter>().sitzung!;
      expect([s.fassung, s.rundendauer], [Abendfassung.lang, const Duration(minutes: 20)]);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      state.dispose();
    });

    testWidgets('Schlosskeller kurz bleibt kurz bis in den Abend; im Solo die Wahl ohne Zahl', (tester) async {
      final state = await oeffnen(tester);
      await tippen(tester, 'Weiter');
      await tippen(tester, 'Solo mit Bots');
      await tippen(tester, 'Weiter');
      expect(find.byType(FassungAbschnitt), findsOneWidget, reason: 'Auch im Solo');
      expect(find.text('Kurzer Abend'), findsOneWidget);
      expect(find.text('Langer Abend'), findsOneWidget);
      expect(find.textContaining('ca.'), findsNothing, reason: 'Die Schätzung gilt dem Abend am Tisch');
      await tester.tap(find.text('Weiter'));
      await warten(tester, bis: find.text('Bereit?'));
      expect(feld('Abend', 'Kurzer Abend'), isTrue);
      expect(find.byWidgetPredicate((w) => w is MFeld && w.name == 'Länge'), findsNothing);
      await tippen(tester, 'Abend beginnen');
      final s = tester.element(find.byType(AbendSeite)).read<AbendHalter>().sitzung!;
      expect(s.fassung, Abendfassung.kurz);
      await tester.pumpWidget(const SizedBox.shrink());
      state.dispose();
    });

    testWidgets('Online sieht der Gastgeber die Fassungswahl wie reihum', (tester) async {
      final state = await oeffnen(tester);
      await tippen(tester, 'Weiter');
      await tippen(tester, 'Jeder am eigenen Gerät');
      await tippen(tester, 'Weiter');
      tester.widget<EinrichtungsAbschnitte>(find.byType(EinrichtungsAbschnitte)).werte.setzeEinstimmung(false);
      await tester.pump();
      expect(find.byType(FassungAbschnitt), findsOneWidget);
      expect(find.text('Langer Abend · ca. 120 Min.'), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
      state.dispose();
    });

    testWidgets('Einstimmung (A-063): Schalter an, Schätzung mit Vorgeschichte und Vorstellung, Zeile im Start, an bis in den Abend', (tester) async {
      final state = await oeffnen(tester);
      await tippen(tester, 'Weiter');
      await tippen(tester, 'Ein Gerät reihum');
      await tippen(tester, 'Weiter');
      final werte = tester.widget<EinrichtungsAbschnitte>(find.byType(EinrichtungsAbschnitte)).werte;
      expect(find.byType(EinstimmungAbschnitt), findsOneWidget);
      expect([werte.hatEinstimmung, werte.einstimmung, werte.einstimmungAn, werte.einstimmungRollen], [true, true, true, werte.rollen], reason: 'Vorgabe an');
      final mit = abendMinutenCa(Abendfassung.kurz, 15, einstimmungRollen: werte.rollen), ohne = abendMinutenCa(Abendfassung.kurz, 15);
      expect(mit, greaterThan(ohne));
      await tester.ensureVisible(find.byKey(const ValueKey('einstimmung-dauer')));
      expect(find.text('Dauert etwa ${abendEinstimmungMinuten(werte.rollen).round()} Minuten.'), findsOneWidget);
      expect(find.text('Kurzer Abend · ca. $mit Min.'), findsOneWidget);
      await tester.ensureVisible(find.byKey(const ValueKey('abend-ca')));
      expect(ca(tester), mit);
      // Mehr Personen, längere Vorstellung.
      werte.setzeRollen(20);
      await tester.pump();
      expect(ca(tester), abendMinutenCa(Abendfassung.kurz, 15, einstimmungRollen: 20));
      werte.setzeRollen(7);
      await tester.pump();
      // Aus: die Zeiten wie ohne Einstimmung.
      await tester.ensureVisible(find.byKey(const ValueKey('einstimmung-schalter')));
      await tippen(tester, 'Vorgeschichte und Vorstellung');
      expect([werte.einstimmung, werte.einstimmungAn], [false, false]);
      expect(find.byKey(const ValueKey('einstimmung-dauer')), findsNothing);
      await tester.ensureVisible(find.byKey(const ValueKey('abend-ca')));
      expect(ca(tester), ohne);
      await tester.ensureVisible(find.byKey(const ValueKey('einstimmung-schalter')));
      await tippen(tester, 'Vorgeschichte und Vorstellung');
      expect(werte.einstimmungAn, isTrue);
      await tester.tap(find.text('Weiter'));
      await warten(tester, bis: find.text('Bereit?'));
      expect(feld('Einstimmung', 'Vorgeschichte und Vorstellung'), isTrue);
      expect(feld('Länge', 'ca. $mit Min.'), isTrue);
      await tippen(tester, 'Abend beginnen');
      final s = tester.element(find.byType(AbendSeite)).read<AbendHalter>().sitzung!;
      expect(s.mitEinstimmung, isTrue);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      state.dispose();
    });

    test('Einstimmung im Druckspiel: Vorgabe aus, bleibt aber schaltbar; ohne Akte mit Einstimmung kein Schalter', () {
      final werte = EinrichtungsWerte(PartySitzung(erzaehlDaten));
      expect(werte.einstimmungAn, isTrue);
      werte.setzeSpielart(Spielart.druck);
      expect([werte.druck, werte.einstimmung, werte.einstimmungAn, werte.einstimmungRollen], [true, false, false, null]);
      werte.setzeEinstimmung(true);
      expect(werte.einstimmungAn, isTrue, reason: 'Wer ihn umlegt, entscheidet');
      werte.setzeSpielart(Spielart.bildschirm);
      expect(werte.einstimmungAn, isTrue);
      final ohne = EinrichtungsWerte(PartySitzung(partyDaten));
      expect([ohne.hatEinstimmung, ohne.einstimmungAn, ohne.einstimmungRollen], [false, false, null]);
      werte.dispose();
      ohne.dispose();
    });

    testWidgets('Altakte (Gewölbe): keine Fassungswahl, keine Schätzung, Rundendauer wie bisher', (tester) async {
      final state = await oeffnen(tester);
      await tippen(tester, 'Spuk im Gewölbe');
      await tippen(tester, 'Weiter');
      await tippen(tester, 'Ein Gerät reihum');
      await tippen(tester, 'Weiter');
      expect(find.byType(FassungAbschnitt), findsNothing);
      expect(find.byType(EinstimmungAbschnitt), findsNothing, reason: 'Ohne Einstimmung kein Schalter');
      final werte = tester.widget<EinrichtungsAbschnitte>(find.byType(EinrichtungsAbschnitte)).werte;
      expect([werte.langfassung, werte.minuten, werte.minutenOptionen, werte.abendMinutenCa], [false, 30, [20, 30, 45, 60], null]);
      expect([werte.hatEinstimmung, werte.einstimmungAn], [false, false]);
      await tester.ensureVisible(find.text('60 Minuten'));
      for (final m in [20, 30, 45, 60]) {
        expect(find.text('$m Minuten'), findsOneWidget);
      }
      expect(find.byKey(const ValueKey('abend-ca')), findsNothing);
      expect(find.textContaining('ca.'), findsNothing);
      werte.setzeFassung(Abendfassung.lang);
      expect(werte.fassung, Abendfassung.kurz, reason: 'Ohne Langfassung bleibt der Abend kurz');
      await tester.tap(find.text('Weiter'));
      await warten(tester, bis: find.text('Bereit?'));
      expect(find.byWidgetPredicate((w) => w is MFeld && (w.name == 'Abend' || w.name == 'Länge')), findsNothing);
      expect(feld('Rundendauer', '30 Min.'), isTrue);
      await tester.pumpWidget(const SizedBox.shrink());
      state.dispose();
    });
  });

  testWidgets('Die Ermittlerklasse im Start wird gewählt und gespeichert', (tester) async {
    final state = await oeffnen(tester);
    await bisZumStart(tester, 'Solo mit Bots');
    await tester.ensureVisible(find.text('Profiler'));
    await tippen(tester, 'Profiler');
    expect(state.meta.loadout.cls, 'profiler', reason: 'Die gewählte Klasse liegt in der Ausrüstung');
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    state.dispose();
  });

  testWidgets('Im Start erklärt die Klasse ihre Wirkung auf der Karte und ihre drei Karten (M6)', (tester) async {
    final state = await oeffnen(tester);
    await bisZumStart(tester, 'Solo mit Bots');
    // Vorgewählt ist die Forensikerin: Spurenblick im Schlosskeller.
    final wirkung = find.text('Spurenblick: Suchstellen und Erkundungsorte leuchten schon von weitem.');
    await tester.ensureVisible(wirkung);
    expect(wirkung, findsOneWidget);
    expect(find.text('Diese Fähigkeit ändert nie Fakten, Punkte oder Würfel.'), findsOneWidget);
    for (final titel in ['Forensik-Köfferchen', 'Der zweite Abdruck', 'Die große Lupe']) {
      expect(_inKlasse(find.textContaining(titel, findRichText: true)), findsOneWidget, reason: titel);
    }
    await tester.ensureVisible(find.text('Profiler'));
    await tippen(tester, 'Profiler');
    expect(find.text('Menschenkenner: Du siehst Gesprächspartner und ihre Stimmung sofort.'), findsOneWidget, reason: 'Die Erklärung folgt der Wahl');
    expect(_inKlasse(find.textContaining('Der Gedankenpalast', findRichText: true)), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    state.dispose();
  });

  testWidgets('Der faire Satz gilt der Fähigkeit; die Karten der Klasse sind Sammelkarten, besessene markiert (M6)', (tester) async {
    final state = await oeffnen(tester);
    await bisZumStart(tester, 'Solo mit Bots');
    final fair = find.text('Diese Fähigkeit ändert nie Fakten, Punkte oder Würfel.');
    await tester.ensureVisible(fair);
    expect(fair, findsOneWidget, reason: 'Der Satz nennt die Fähigkeit auf der Karte, nicht die Sammelkarten');
    expect(_inKlasse(find.text('SAMMELKARTEN DIESER KLASSE')), findsOneWidget);
    expect(find.text('DEINE DREI KLASSENKARTEN'), findsNothing, reason: 'Nicht jede Karte der Klasse ist schon deine');
    // Das Köfferchen gehört zum Startset; Abdruck und Lupe bringt erst ein Abend.
    expect(_inKlasse(find.textContaining('in deiner Sammlung', findRichText: true)), findsOneWidget);
    expect(_inKlasse(find.textContaining(RegExp('Forensik-Köfferchen.*in deiner Sammlung'), findRichText: true)), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    state.dispose();
  });

  testWidgets('Gewölbe kennt keine Klassen auf der Karte: nur Karten und Belohnung', (tester) async {
    final state = await oeffnen(tester);
    await tippen(tester, 'Spuk im Gewölbe');
    await bisZumStart(tester, 'Solo mit Bots');
    await tester.ensureVisible(find.text('Profiler'));
    expect(find.textContaining('Spurenblick'), findsNothing);
    expect(find.text('Diese Fähigkeit ändert nie Fakten, Punkte oder Würfel.'), findsNothing);
    expect(_inKlasse(find.textContaining('Forensik-Köfferchen', findRichText: true)), findsOneWidget);
    expect(find.text('Dein Abend bringt dir immer eine Sammelkarte deiner Klasse.'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    state.dispose();
  });

  testWidgets('/abend ohne laufenden Abend führt in die Detektei', (tester) async {
    final state = await oeffnen(tester, ort: Routes.abend);
    expect(find.byType(DetekteiSeite), findsOneWidget);
    expect(find.byType(AbendSeite), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
    state.dispose();
  });

  testWidgets('Android-Zurück im Assistenten geht einen Schritt zurück, statt die App zu schließen', (tester) async {
    final state = await oeffnen(tester);
    await tippen(tester, 'Weiter');
    await tippen(tester, 'Solo mit Bots');
    await tippen(tester, 'Weiter');
    expect(find.text('SCHRITT 3 VON 4'), findsOneWidget);
    await tester.binding.handlePopRoute();
    await warten(tester);
    expect(find.text('SCHRITT 2 VON 4'), findsOneWidget, reason: 'Ein Schritt zurück: zur Spielweise');
    expect(find.text('Wie spielt ihr?'), findsOneWidget);
    await tester.binding.handlePopRoute();
    await warten(tester);
    expect(find.text('SCHRITT 1 VON 4'), findsOneWidget, reason: 'Ein weiterer Schritt: zur Akte');
    expect(find.byType(DetekteiSeite), findsNothing);
    await tester.binding.handlePopRoute();
    await warten(tester, bis: find.byType(DetekteiSeite));
    expect(find.byType(DetekteiSeite), findsOneWidget, reason: 'Auf dem ersten Schritt führt Zurück in die Detektei');
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    state.dispose();
  });

  testWidgets('Android-Zurück auf der Beitritts-Seite führt in die Detektei, die App bleibt offen', (tester) async {
    final state = await oeffnen(tester, ort: '${Routes.beitreten}?raum=ABC-DEF');
    expect(find.byType(DetekteiSeite), findsNothing);
    await tester.binding.handlePopRoute();
    await warten(tester, bis: find.byType(DetekteiSeite));
    expect(find.byType(DetekteiSeite), findsOneWidget, reason: 'Zurück geht in die Detektei');
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    state.dispose();
  });

  testWidgets('Solo-Abend: „Abend abbrechen“ fragt nach und führt nach Ja in die Detektei', (tester) async {
    final state = await oeffnen(tester);
    await bisZumStart(tester, 'Solo mit Bots');
    await tippen(tester, 'Abend beginnen');
    expect(find.byType(AbendSeite), findsOneWidget);
    final halter = tester.element(find.byType(AbendSeite)).read<AbendHalter>();
    expect(halter.laeuft, isTrue);

    await tester.tap(find.text('Abend abbrechen'));
    await warten(tester, bis: find.byType(MKarteikartenDialog));
    expect(find.text('Abend abbrechen?'), findsOneWidget, reason: 'Die Rückfrage');
    expect(find.byType(AbendSeite), findsOneWidget, reason: 'Vor der Antwort bleibt der Abend stehen');

    await tippen(tester, 'Weiterspielen');
    expect(find.byType(MKarteikartenDialog), findsNothing);
    expect(find.byType(AbendSeite), findsOneWidget);
    expect(halter.laeuft, isTrue, reason: 'Weiterspielen lässt den Abend unberührt');
    expect(
      GoRouter.of(tester.element(find.byType(AbendSeite))).routeInformationProvider.value.uri.path,
      Routes.abend,
      reason: 'Weiterspielen navigiert nicht: die Adresse bleibt die des Abends',
    );

    await tester.tap(find.text('Abend abbrechen'));
    await warten(tester, bis: find.byType(MKarteikartenDialog));
    await tester.tap(find.descendant(of: find.byType(MKarteikartenDialog), matching: find.text('Abend abbrechen')));
    await warten(tester, bis: find.byType(DetekteiSeite));
    expect(find.byType(DetekteiSeite), findsOneWidget, reason: 'Nach Ja geht es in die Detektei');
    expect(find.byType(AbendSeite), findsNothing);
    expect(halter.laeuft, isFalse, reason: 'Der Abend ist freigegeben und lässt sich nicht fortsetzen');
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    state.dispose();
  });

  testWidgets('Solo-Abend: die Leiste öffnet die Detektivkarte, auch bei 320 px und doppelter Schrift (M6)', (tester) async {
    final state = await oeffnen(tester);
    await bisZumStart(tester, 'Solo mit Bots');
    await tippen(tester, 'Abend beginnen');
    tester.view.physicalSize = const Size(320, 844);
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await warten(tester);
    expect(tester.takeException(), isNull, reason: 'Die Leiste läuft nicht über');
    // Der Knopf der Leiste (der Eintrag der Rollenphase heißt „Deine Detektivkarte“).
    await tester.tap(find.text('Detektivkarte'));
    await warten(tester, bis: find.byType(MKarteikartenDialog));
    expect(find.text('Deine Detektivkarte'), findsWidgets);
    expect(find.text('So laufen Befragungen', skipOffstage: false), findsOneWidget);
    await tippen(tester, 'Schließen');
    expect(find.byType(MKarteikartenDialog), findsNothing);
    expect(find.byType(AbendSeite), findsOneWidget, reason: 'Der Abend läuft weiter');
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    state.dispose();
  });

  testWidgets('Android-Zurück auf dem Solo-Abend fragt ebenso nach', (tester) async {
    final state = await oeffnen(tester);
    await bisZumStart(tester, 'Solo mit Bots');
    await tippen(tester, 'Abend beginnen');
    await tester.binding.handlePopRoute();
    await warten(tester, bis: find.byType(MKarteikartenDialog));
    expect(find.text('Abend abbrechen?'), findsOneWidget);
    await tippen(tester, 'Weiterspielen');
    expect(find.byType(AbendSeite), findsOneWidget, reason: 'Die App bleibt auf dem Abend');
    expect(
      GoRouter.of(tester.element(find.byType(AbendSeite))).routeInformationProvider.value.uri.path,
      Routes.abend,
      reason: 'Weiterspielen navigiert nicht: die Adresse bleibt die des Abends',
    );
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    state.dispose();
  });
}
