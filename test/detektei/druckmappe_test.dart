// Die Druckmappe bietet das Kammerspiel an (B1, B3, E16): Nach dem Deckel stehen nur
// Personen (6 bis 20: Rollen, Detektiv und Erzähler) und Detektiv oder Detektivin, ohne
// Fall-Code, Rundendauer, Fassung oder „Dein Moment“. Die Gästeliste der Akte gibt die
// Personenzahl vor, wenn sie passt, und die Namen auf „Senden an …“. „Druckmappe
// vorbereiten“ zeigt die KammerTafel für die eingestellten Werte, nie die alte
// Druckfassung und nie die Erzählerakte. „Zurück“ führt dorthin, woher man kam. Eine
// Akte ohne Kammerspiel hat keine Druckmappe. Inhalt und Schriften kommen aus dem
// Bündel, wie im Browser.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mordakte/app/app.dart';
import 'package:mordakte/app/app_state.dart';
import 'package:mordakte/app/router.dart';
import 'package:mordakte/detektei/akten.dart';
import 'package:mordakte/l10n/gen/app_localizations_de.dart';
import 'package:mordakte/meta/meta_store.dart';
import 'package:mordakte/party/datei_knopf.dart';
import 'package:mordakte/party/druck_tafel.dart';
import 'package:mordakte/party/kammer_laden.dart';
import 'package:mordakte/party/kammer_tafel.dart';
import 'package:mordakte/stil/stil.dart';
import 'package:mordakte_core/kammer_io.dart' show ladeKammerInhalt;
import 'package:mordakte_core/party_druck.dart' show kammerTeile;
import 'package:shared_preferences/shared_preferences.dart';

final _de = LDe();

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  /// Öffnet [ort] auf einem Handy (390 px) und wartet, bis [bereit] da ist.
  Future<AppState> oeffnen(WidgetTester t, String ort, {Finder? bereit, GaesteListe? gaeste}) async {
    t.view.physicalSize = const Size(390, 844);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.view.resetDevicePixelRatio);
    final meta = MetaStore.memory()..name = 'Test';
    if (gaeste != null) meta.setzeGaesteliste('schlosskeller', gaeste);
    final state = AppState(meta: meta, scenarios: const {});
    await t.runAsync(() async {
      await AktenKatalog.laden();
      await t.pumpWidget(MordakteApp(app: state, initialLocation: ort));
    });
    await warten(t, bereit);
    return state;
  }

  Future<void> schliessen(WidgetTester t, AppState state) async {
    expect(t.takeException(), isNull);
    await t.pumpWidget(const SizedBox.shrink());
    state.dispose();
  }

  final vorbereiten = find.text(_de.detektei_druck_vorbereiten);

  /// Die Tafel nach „Druckmappe vorbereiten“.
  KammerTafel tafel(WidgetTester t) => t.widget<KammerTafel>(find.byType(KammerTafel));

  test('Personenzahl aus der Gästeliste: Rollen dazu Detektiv und Erzähler, sonst die Vorgabe 10', () {
    final f = ladeKammerInhalt('.').fall;
    expect((f.personenMin, f.personenVorgabe, f.personenMax), (6, 10, 20));
    expect(kammerPersonenVorgabe(f, null), 10, reason: 'Gästeliste offen');
    expect(kammerPersonenVorgabe(f, 4), 6);
    expect(kammerPersonenVorgabe(f, 8), 10);
    expect(kammerPersonenVorgabe(f, 11), 13);
    expect(kammerPersonenVorgabe(f, 18), 20);
    expect(kammerPersonenVorgabe(f, 19), 10, reason: '21 Personen passen nicht');
    expect(kammerPersonenVorgabe(f, 3), 10, reason: '5 Personen passen nicht');
  });

  test('Ein Kammerspiel hat nur der Schlosskeller', () {
    expect(hatKammerspiel('schlosskeller'), isTrue);
    for (final id in ['gewoelbe', 'ravensmoor', 'nachtexpress', 'blue_palm', '']) {
      expect(hatKammerspiel(id), isFalse, reason: id);
    }
  });

  testWidgets('Aus dem Bündel: derselbe Inhalt wie aus den Dateien', (t) async {
    final ausBuendel = (await t.runAsync(() async {
      rootBundle.clear();
      return kammerGrundlageLaden(rootBundle);
    }))!;
    // Jede Datei aus kammerInhaltDateien liegt im Bündel (sonst scheitert das Laden). Verglichen
    // wird, was der Wortlaut nicht ändert: Der Schnappschuss der Test-Assets entsteht beim Start
    // des Testlaufs, die Spieltexte im Repo können sich bis dahin noch ändern.
    final ausDateien = ladeKammerInhalt('.');
    final b = ausBuendel.inhalt;
    expect(b.fall.fallCode, ausDateien.fall.fallCode);
    expect([for (final p in b.fall.plaetze) (p.platz, p.id, p.kanonFigur, p.art)], [for (final p in ausDateien.fall.plaetze) (p.platz, p.id, p.kanonFigur, p.art)]);
    expect(b.ui.keys.toSet(), {'gemeinsam', ...kammerTeile});
    expect(b.rollen, hasLength(18));
    expect(ausBuendel.stil.normal, isNotNull);
  });

  testWidgets('Einstellungen: nur Personen und Detektiv, ohne Fall-Code, Dauer, Fassung und „Dein Moment“', (t) async {
    final state = await oeffnen(t, Routes.druckmappeVon('schlosskeller'), bereit: vorbereiten);
    expect(vorbereiten, findsOneWidget);
    expect(find.text(_de.detektei_druck_titel), findsOneWidget);
    expect(find.text(_de.detektei_druck_personen.toUpperCase()), findsOneWidget);
    expect(find.text(_de.detektei_druck_personen_anzahl('10')), findsOneWidget, reason: 'Vorgabe ohne Gästeliste');
    expect(find.text(_de.detektei_druck_personen_rollen('8')), findsOneWidget);
    expect(find.text(_de.detektei_druck_detektiv.toUpperCase()), findsOneWidget);
    expect(find.text(_de.detektei_druck_detektiv_m), findsOneWidget);
    expect(find.text(_de.detektei_druck_detektiv_w), findsOneWidget);
    // Was es im Kammerspiel nicht gibt (der Fall ist fest): Texte der Einrichtung eines Abends.
    for (final weg in ['DER FALL', 'Zufall', 'Code eingeben', 'WIE LANGE DAUERT EINE RUNDE?', 'Kurzer Abend', 'Langer Abend']) {
      expect(find.text(weg), findsNothing, reason: weg);
    }
    expect(find.textContaining('Minuten'), findsNothing);
    expect(find.textContaining('Fall-Code'), findsNothing);
    expect(find.textContaining('Moment'), findsNothing);
    expect(find.byType(TextField), findsNothing, reason: 'Keine Namensfelder und kein Code');
    // Der Deckel nennt die Schritte des neuen Ablaufs.
    expect(find.text(_de.detektei_druck_hinweis), findsOneWidget);
    expect(_de.detektei_druck_hinweis, isNot(contains('Fall')));
    await schliessen(t, state);
  });

  testWidgets('Regler und Knöpfe: 6 bis 20 Personen, die Zeile nennt die Rollen; vorbereiten nimmt die Werte', (t) async {
    final state = await oeffnen(t, Routes.druckmappeVon('schlosskeller'), bereit: vorbereiten);
    final mehr = find.byTooltip(_de.detektei_druck_personen_mehr);
    final weniger = find.byTooltip(_de.detektei_druck_personen_weniger);
    IconButton knopf(Finder f) => t.widget<IconButton>(find.ancestor(of: f, matching: find.byType(IconButton)).first);
    await tippe(t, mehr);
    expect(find.text(_de.detektei_druck_personen_anzahl('11')), findsOneWidget);
    expect(find.text(_de.detektei_druck_personen_rollen('9')), findsOneWidget);
    // Ganz nach unten: bei 6 Personen (4 Rollen) geht es nicht weiter.
    for (var i = 0; i < 5; i++) {
      await tippe(t, weniger);
    }
    expect(find.text(_de.detektei_druck_personen_anzahl('6')), findsOneWidget);
    expect(find.text(_de.detektei_druck_personen_rollen('4')), findsOneWidget);
    expect(knopf(weniger).onPressed, isNull);
    expect(knopf(mehr).onPressed, isNotNull);
    // Der Regler reicht von 6 bis 20.
    final regler = t.widget<Slider>(find.byType(Slider));
    expect((regler.min, regler.max, regler.divisions), (6.0, 20.0, 14));
    regler.onChanged!(20);
    await t.pump();
    expect(find.text(_de.detektei_druck_personen_anzahl('20')), findsOneWidget);
    expect(find.text(_de.detektei_druck_personen_rollen('18')), findsOneWidget);
    expect(knopf(mehr).onPressed, isNull);
    t.widget<Slider>(find.byType(Slider)).onChanged!(13);
    await t.pump();
    // Detektiv statt Detektivin.
    await tippe(t, find.text(_de.detektei_druck_detektiv_m));
    await t.tap(vorbereiten);
    await t.pump();
    final k = tafel(t).kontext;
    expect((k.personen, k.besetzung.rollen, k.detektiv), (13, 11, 'm'));
    // Die Einstellungen weichen der Tafel; vorbereiten gibt es nur einmal.
    expect(vorbereiten, findsNothing);
    expect(find.byType(Slider), findsNothing);
    expect(find.textContaining(_de.druck_senden_an(''), skipOffstage: false), findsNWidgets(11));
    await schliessen(t, state);
  });

  testWidgets('Vorbereiten: die KammerTafel, keine alte Druckfassung, keine Erzählerakte (E16)', (t) async {
    final state = await oeffnen(t, Routes.druckmappeVon('schlosskeller'), bereit: vorbereiten);
    // Schon vorher: nirgends eine Erzählerakte.
    expect(find.textContaining('Erzählerakte', skipOffstage: false), findsNothing);
    await t.tap(vorbereiten);
    await warten(t, find.byType(KammerTafel));
    expect(find.byType(KammerTafel), findsOneWidget);
    expect(find.byType(DruckTafel), findsNothing);
    final k = tafel(t).kontext;
    expect((k.personen, k.detektiv, k.fallCode), (10, 'w', 'U4YRK'));
    expect(find.text(k.uiGemeinsam('titel.alles'), skipOffstage: false), findsOneWidget);
    expect(find.byType(DateiKnopf, skipOffstage: false), findsNWidgets(1 + 8 + 8));
    // E16: kein Block „Nur Erzähler“, kein Knopf und kein Hinweis zur Erzählerakte.
    expect(find.textContaining('Erzählerakte', skipOffstage: false), findsNothing);
    expect(find.text('Nur Erzähler', skipOffstage: false), findsNothing);
    expect(find.text(_de.druck_erzaehlerakte_hinweis, skipOffstage: false), findsNothing);
    expect(
      find.byWidgetPredicate((w) => w.key is ValueKey<String> && (w.key! as ValueKey<String>).value.startsWith('druck-erzaehlerakte'), skipOffstage: false),
      findsNothing,
    );
    // Auch der Fall-Code-Hinweis der alten Druckfassung fehlt; der Fall ist fest.
    expect(find.text(_de.druck_je_person_hinweis, skipOffstage: false), findsNothing);
    expect(find.text(_de.druck_kammer_je_person_hinweis, skipOffstage: false), findsOneWidget);
    // Die Seite rollte zur Tafel: „Alles in einer Datei“ liegt im Bild.
    await t.pump(const Duration(milliseconds: 400));
    final alles = t.getRect(find.text(k.uiGemeinsam('titel.alles')));
    expect(alles.top, greaterThanOrEqualTo(0));
    expect(alles.bottom, lessThanOrEqualTo(844));
    await schliessen(t, state);
  });

  testWidgets('Die Gästeliste gibt Personenzahl und Namen vor', (t) async {
    // Sechs Personen am Tisch ohne den Detektiv: 8 Personen im Kammerspiel.
    const gaeste = GaesteListe(personen: 6, gaeste: [Gast('Ben', 'ahmet'), Gast('Mia', 'leyla'), Gast('Kim', 'detective'), Gast('Noor', 'tugba')]);
    final state = await oeffnen(t, Routes.druckmappeVon('schlosskeller'), bereit: vorbereiten, gaeste: gaeste);
    expect(find.text(_de.detektei_druck_personen_anzahl('8')), findsOneWidget);
    expect(find.text(_de.detektei_druck_personen_rollen('6')), findsOneWidget);
    await t.tap(vorbereiten);
    await warten(t, find.byType(KammerTafel));
    final k = tafel(t).kontext;
    expect(k.personen, 8);
    expect(k.spieler, {'ahmet': 'Ben', 'leyla': 'Mia', 'detective': 'Kim', 'tugba': 'Noor'});
    expect(find.text(_de.druck_senden_an('Ben'), skipOffstage: false), findsOneWidget);
    expect(find.text(_de.druck_senden_an('Mia'), skipOffstage: false), findsOneWidget, reason: 'Lejla ist im Kanon leyla');
    expect(find.text(_de.druck_senden_an('Fatma'), skipOffstage: false), findsOneWidget, reason: 'Ohne Gast der Name der Rolle');
    expect(find.text(_de.druck_senden_an('Kim'), skipOffstage: false), findsNothing);
    expect(find.text(_de.druck_senden_an('Noor'), skipOffstage: false), findsNothing, reason: 'Tugba spielt bei 8 Personen niemand');
    expect(find.textContaining(_de.druck_senden_an(''), skipOffstage: false), findsNWidgets(6));
    await schliessen(t, state);
  });

  testWidgets('Passt die Gästeliste nicht (21 Personen), gilt die Vorgabe 10', (t) async {
    final state = await oeffnen(t, Routes.druckmappeVon('schlosskeller'), bereit: vorbereiten, gaeste: const GaesteListe(personen: 19));
    expect(find.text(_de.detektei_druck_personen_anzahl('10')), findsOneWidget);
    await schliessen(t, state);
  });

  testWidgets('„Zurück“ führt in die Detektei oder auf die Akte, woher man kam', (t) async {
    var state = await oeffnen(t, Routes.druckmappeVon('schlosskeller', ausDetektei: true), bereit: vorbereiten);
    await t.tap(find.text(_de.common_back));
    await warten(t, find.text(_de.detektei_neuer_abend));
    expect(find.text(_de.detektei_neuer_abend), findsOneWidget);
    expect(find.text(_de.detektei_akte_spielen), findsNothing);
    await schliessen(t, state);

    state = await oeffnen(t, Routes.druckmappeVon('schlosskeller'), bereit: vorbereiten);
    await t.tap(vorbereiten);
    await warten(t, find.byType(KammerTafel));
    // Auch nach dem Vorbereiten: zurück auf die Akte.
    await t.tap(find.text(_de.common_back));
    await warten(t, find.text(_de.detektei_akte_spielen));
    expect(find.text(_de.detektei_akte_spielen), findsOneWidget);
    expect(find.byType(KammerTafel), findsNothing);
    await schliessen(t, state);
  });

  testWidgets('Eine Akte ohne Kammerspiel hat keine Druckmappe', (t) async {
    final state = await oeffnen(t, Routes.druckmappeVon('blue_palm'), bereit: find.text(_de.detektei_druck_keine));
    expect(find.text(_de.detektei_druck_keine), findsOneWidget);
    expect(vorbereiten, findsNothing);
    expect(find.byType(KammerTafel), findsNothing);
    expect(find.byType(DruckTafel), findsNothing);
    expect(find.byType(MAktenmappe), findsOneWidget, reason: 'Der Deckel bleibt');
    await schliessen(t, state);
  });
}

/// Rollt [f] in die Mitte (über die Fußleiste) und tippt darauf.
Future<void> tippe(WidgetTester t, Finder f) async {
  await Scrollable.ensureVisible(t.element(f), alignment: 0.5);
  await t.pump();
  await t.tap(f);
  await t.pump();
}

/// Lässt Ladevorgänge (echte Zeit) und Übergänge ablaufen, bis [finder] etwas findet.
Future<void> warten(WidgetTester t, [Finder? finder]) async {
  for (var i = 0; i < 150; i++) {
    await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
    await t.pump(const Duration(milliseconds: 50));
    if (finder == null || finder.evaluate().isNotEmpty) break;
  }
  await t.pump(const Duration(milliseconds: 500));
}
