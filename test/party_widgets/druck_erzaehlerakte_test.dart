// Die Erzählerakte als PDF in der Druckmappe (A-063, PDF-Paket): Unter „Rollenhefte
// einzeln senden“ steht ein eigener Abschnitt „Nur Erzähler“ mit Hinweis und Knopf. Die
// Datei entsteht erst beim Tipp, ohne Satz und Fall-Code, mit den Zielen des Kanons (wie
// das Druckspiel und die Kommandozeile ohne --dein-moment, nie die Sterne von „Dein
// Moment“) und der Personenzahl der Einstellung. Sie ist in allen Pfaden dieselbe. Nie in
// der Rollenvergabe, die der ganze Tisch sieht, nie ohne Druckspiel, nie im Solo, nie bei
// Akten ohne Erzählerakte. Im Browser: „Herunterladen: Erzählerakte“.
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mordakte/app/app.dart';
import 'package:mordakte/app/app_state.dart';
import 'package:mordakte/app/router.dart';
import 'package:mordakte/detektei/akten.dart';
import 'package:mordakte/l10n/gen/app_localizations_de.dart';
import 'package:mordakte/meta/meta_store.dart';
import 'package:mordakte/party/bildschirme/rollen.dart';
import 'package:mordakte/party/daten.dart';
import 'package:mordakte/party/datei_teilen.dart';
import 'package:mordakte/party/druck_portraets.dart';
import 'package:mordakte/party/druck_speichern.dart';
import 'package:mordakte/party/druck_tafel.dart';
import 'package:mordakte/party/sitzung.dart';
import 'package:mordakte_core/mordakte_core.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'erzaehl_hilfe.dart';
import 'hilfe.dart';

final _de = LDe();

/// Druckspiel im Schlosskeller (mit Erzählerakte und „Dein Moment“) für [rollen] Personen, Täterpfad [pfad].
PartySitzung _sitzung({String pfad = 'ahmet', int rollen = 6, PartyDaten? daten, bool druck = true, String erzaehler = ''}) {
  final d = daten ?? erzaehlDaten;
  return PartySitzung(d)..einrichten(rollen: rollen, detektiv: 'w', code: FallCode.fuerPfad(pfad, d.kanon.pfade).code, druck: druck, erzaehlerName: erzaehler);
}

Future<void> _zeige(WidgetTester t, Widget kind) async {
  t.view.physicalSize = const Size(1280, 1600);
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.resetPhysicalSize);
  addTearDown(t.view.resetDevicePixelRatio);
  await t.pumpWidget(rahmen(kind));
}

/// Die Tafel der Druckmappe (mit dem Abschnitt der Erzählerakte) in einer rollenden Seite.
Widget _mappe(PartySitzung s, {bool druckspiel = true, bool erzaehlerakte = true}) =>
    SingleChildScrollView(child: DruckTafel(sitzung: s, druckspiel: druckspiel, erzaehlerakte: erzaehlerakte));

/// Fängt das Teilen des Systems ab.
List<ShareParams> _zeuge() {
  final geteilt = <ShareParams>[];
  final vorher = dateiTeilenUeber;
  dateiTeilenUeber = (p) async {
    geteilt.add(p);
    return const ShareResult('ok', ShareResultStatus.success);
  };
  addTearDown(() => dateiTeilenUeber = vorher);
  return geteilt;
}

/// Der Browser ohne Teilen (Firefox am Rechner): nur Herunterladen.
class _Browser extends DateiGeraet {
  final angeboten = <(String, DateiWeg, Uint8List)>[];

  @override
  bool get zweiterTipp => true;

  @override
  bool get kannHerunterladen => true;

  @override
  bool kannTeilen(String name, String typ) => false;

  @override
  Future<bool> anbieten(String name, Uint8List bytes, {required String typ, Rect? ursprung, required DateiWeg weg}) async {
    angeboten.add((name, weg, bytes));
    return true;
  }
}

/// Tippt auf [knopf] und wartet in echter Zeit, bis [fertig] gilt (die PDF-Erzeugung läuft wirklich).
Future<void> _tippeUndWarte(WidgetTester t, Finder knopf, bool Function() fertig) async {
  await t.ensureVisible(knopf);
  await t.tap(knopf);
  await t.pump();
  for (var i = 0; i < 600 && !fertig(); i++) {
    await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
    await t.pump(const Duration(milliseconds: 20));
  }
  await t.pump();
}

/// Bytes der geteilten Datei.
Future<Uint8List> _bytes(WidgetTester t, ShareParams p) async => (await t.runAsync(() => p.files!.single.readAsBytes()))!;

/// Die Test-Assets wie `flutter test` sie liefert (`UNIT_TEST_ASSETS`, ohne Paketpräfix).
Future<ByteData?> _testAsset(ByteData? nachricht) async {
  final key = utf8.decode(nachricht!.buffer.asUint8List());
  final f = File('${Platform.environment['UNIT_TEST_ASSETS']}/$key');
  return f.existsSync() ? ByteData.sublistView(f.readAsBytesSync()) : null;
}

/// Lässt das Laden von [asset] einmal scheitern (etwa eine Schrift beim ersten Tipp);
/// alles andere kommt aus den Test-Assets.
void _einmalOhne(WidgetTester t, String asset) {
  var gescheitert = false;
  final m = t.binding.defaultBinaryMessenger;
  m.setMockMessageHandler('flutter/assets', (n) {
    if (!gescheitert && utf8.decode(n!.buffer.asUint8List()) == asset) {
      gescheitert = true;
      return Future.value();
    }
    return _testAsset(n);
  });
  addTearDown(() => m.setMockMessageHandler('flutter/assets', _testAsset));
}

/// Der Knopf der Erzählerakte in der Druckmappe (Schlüssel `druck-erzaehlerakte-<n>`).
final _knopf = find.byWidgetPredicate((w) => w.key is ValueKey<String> && (w.key! as ValueKey<String>).value.startsWith('druck-erzaehlerakte'));

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('Druckmappe: Abschnitt „Nur Erzähler“ unter den Rollenheften; der Knopf teilt erzaehlerakte.pdf mit den Zielen des Kanons', (t) async {
    final angefragt = mitErsatzPortraets();
    final geteilt = _zeuge();
    final s = _sitzung();
    await _zeige(t, _mappe(s));
    final kopf = find.text(s.ui('ui.druck.paket.dateien.ordner4'));
    expect(kopf, findsOneWidget);
    expect(find.text(_de.druck_erzaehlerakte_hinweis), findsOneWidget);
    expect(_knopf, findsOneWidget);
    expect(find.text(s.ui('ui.druck.akte.titel')), findsOneWidget);
    // Der Abschnitt steht unter „Rollenhefte einzeln senden“ und dessen Knöpfen.
    expect(t.getTopLeft(kopf).dy, greaterThan(t.getTopLeft(find.text(_de.druck_je_person)).dy));
    expect(t.getTopLeft(kopf).dy, greaterThan(t.getTopLeft(find.text(_de.druck_senden_an(s.spielerName(s.besetzt.last)))).dy));
    expect(angefragt, isEmpty, reason: 'Porträts erst beim Tipp');

    await _tippeUndWarte(t, find.text(s.ui('ui.druck.akte.titel')), () => geteilt.isNotEmpty);
    expect(geteilt, hasLength(1));
    final p = geteilt.single;
    expect(p.fileNameOverrides, ['erzaehlerakte.pdf']);
    expect(p.files!.single.mimeType, 'application/pdf');
    final bytes = await _bytes(t, p);
    expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
    expect(angefragt, [same(s.daten.kanon)]);
    expect(find.text(_de.druck_datei_fehler), findsNothing);

    // Dieselbe Datei wie der Kern mit den Zielen des Kanons für 6 Personen; nie die Sterne.
    final soll = await t.runAsync(() => erzaehlerakteSoll(erzaehlDaten, einfluss: false, rollen: 6));
    expect(bytes, soll);
    final sterne = await t.runAsync(() => erzaehlerakteSoll(erzaehlDaten, einfluss: true, rollen: 6));
    expect(bytes, isNot(sterne), reason: 'Die Druckmappe nennt nie die Sterne von „Dein Moment“');

    // Der zweite Tipp baut nicht neu.
    await _tippeUndWarte(t, find.text(s.ui('ui.druck.akte.titel')), () => geteilt.length > 1);
    expect(geteilt.last.fileNameOverrides, ['erzaehlerakte.pdf']);
    expect(angefragt, hasLength(1));
  });

  testWidgets('Scheitern die Porträts oder sind sie unlesbar, entsteht die Akte ohne Bilder', (t) async {
    final s = _sitzung(rollen: 5);
    final ohneBilder = await t.runAsync(() => erzaehlerakteSoll(erzaehlDaten, einfluss: false, rollen: 5, portraets: const {}));
    final vorher = druckPortraetsUeber;
    addTearDown(() => druckPortraetsUeber = vorher);
    for (final (warum, bilder) in [
      ('Zeichner wirft', (Kanon k) async => throw StateError('PNG geht hier nicht')),
      ('unlesbares Bild', (Kanon k) async => {for (final id in ersatzPortraets(k).keys) id: Uint8List.fromList(const [1, 2, 3])}),
    ]) {
      druckPortraetsUeber = bilder;
      final geteilt = _zeuge();
      await _zeige(t, KeyedSubtree(key: ValueKey(warum), child: _mappe(s)));
      await _tippeUndWarte(t, _knopf, () => geteilt.isNotEmpty);
      expect(find.text(_de.druck_datei_fehler), findsNothing, reason: warum);
      final bytes = await _bytes(t, geteilt.single);
      expect(String.fromCharCodes(bytes.take(5)), '%PDF-', reason: warum);
      expect(bytes, ohneBilder, reason: warum);
    }
  });

  testWidgets('Scheitert der erste Tipp, steht der Fehler da, und der nächste Tipp baut neu und teilt die Datei', (t) async {
    final angefragt = mitErsatzPortraets();
    final geteilt = _zeuge();
    _einmalOhne(t, 'assets/fonts/PlayfairDisplay-Variabel.ttf');
    final s = _sitzung(rollen: 5);
    await _zeige(t, _mappe(s));
    await _tippeUndWarte(t, _knopf, () => find.text(_de.druck_datei_fehler).evaluate().isNotEmpty);
    expect(find.text(_de.druck_datei_fehler), findsOneWidget);
    expect(geteilt, isEmpty);
    // Unter dem Knopf steht jetzt der Fehler: auf die Beschriftung tippen, nicht in die Mitte.
    await _tippeUndWarte(t, find.text(s.ui('ui.druck.akte.titel')), () => geteilt.isNotEmpty);
    expect(find.text(_de.druck_datei_fehler), findsNothing);
    expect(await _bytes(t, geteilt.single), await t.runAsync(() => erzaehlerakteSoll(erzaehlDaten, einfluss: false, rollen: 5)));
    expect(angefragt, hasLength(1), reason: 'Der erste Versuch scheiterte schon an der Schrift');
  });

  testWidgets('Ändert sich die Personenzahl der Tafel, entsteht die Akte für die neue Zahl', (t) async {
    mitErsatzPortraets();
    final geteilt = _zeuge();
    await _zeige(t, _mappe(_sitzung(rollen: 6)));
    await _tippeUndWarte(t, _knopf, () => geteilt.isNotEmpty);
    // Dieselbe Tafel (derselbe Zustand) mit einer Sitzung für acht Personen.
    await _zeige(t, _mappe(_sitzung(rollen: 8)));
    expect(find.byKey(const ValueKey('druck-erzaehlerakte-8')), findsOneWidget);
    await _tippeUndWarte(t, _knopf, () => geteilt.length > 1);
    expect(await _bytes(t, geteilt.first), await t.runAsync(() => erzaehlerakteSoll(erzaehlDaten, einfluss: false, rollen: 6)));
    expect(await _bytes(t, geteilt.last), await t.runAsync(() => erzaehlerakteSoll(erzaehlDaten, einfluss: false, rollen: 8)));
  });

  testWidgets('Zwei Codes aus verschiedenen Pfaden ergeben dieselbe Erzählerakte', (t) async {
    mitErsatzPortraets();
    final geteilt = _zeuge();
    final ahmet = _sitzung(pfad: 'ahmet', rollen: 9), olli = _sitzung(pfad: 'olli', rollen: 9);
    expect(ahmet.fallCode.code, isNot(olli.fallCode.code));
    expect(ahmet.spiel.pfad, isNot(olli.spiel.pfad));
    await _zeige(t, _mappe(ahmet));
    await _tippeUndWarte(t, _knopf, () => geteilt.isNotEmpty);
    await _zeige(t, KeyedSubtree(key: const ValueKey('olli'), child: _mappe(olli)));
    await _tippeUndWarte(t, _knopf, () => geteilt.length > 1);
    expect(geteilt, hasLength(2));
    final a = await _bytes(t, geteilt.first), b = await _bytes(t, geteilt.last);
    expect(a, b);
    expect(a, await t.runAsync(() => erzaehlerakteSoll(erzaehlDaten, einfluss: false, rollen: 9)));
    expect(String.fromCharCodes(a).contains(ahmet.fallCode.code) || String.fromCharCodes(a).contains(olli.fallCode.code), isFalse);
  });

  testWidgets('Kein Knopf: Rollenvergabe am Tisch, ohne Druckspiel, im Solo, ohne Erzählerakte, ohne den Schalter', (t) async {
    void keiner(String warum) {
      expect(_knopf, findsNothing, reason: warum);
      expect(find.text(_de.druck_erzaehlerakte_hinweis), findsNothing, reason: warum);
    }

    // Die Rollenvergabe sieht der ganze Tisch: Die Tafel „Druckfassung“ dort bietet die
    // Erzählerakte nie an (verdeckt liegt sie mit Erzähler nur im eigenen Eintrag).
    for (final erzaehler in ['', 'Mia']) {
      final s = _sitzung(erzaehler: erzaehler);
      await _zeige(t, RollenBildschirm(sitzung: s));
      expect(find.text(s.ui('ui.druck.app.titel')), findsOneWidget);
      keiner('Rollenvergabe${erzaehler.isEmpty ? '' : ' mit Erzähler'}');
    }
    // Reihum ohne Druck: nur das Erzählerheft.
    final reihum = _sitzung(druck: false, erzaehler: 'Mia');
    await _zeige(t, RollenBildschirm(sitzung: reihum));
    expect(find.text(_de.druck_erzaehlerheft_hinweis), findsOneWidget);
    keiner('Rollenvergabe reihum');
    // Die Tafel selbst: nur mit Schalter, im Druckspiel, nicht im Solo, nur mit Akte.
    await _zeige(t, _mappe(_sitzung(), erzaehlerakte: false));
    keiner('ohne Schalter');
    await _zeige(t, _mappe(_sitzung(druck: false), druckspiel: false));
    keiner('ohne Druckspiel');
    final solo = PartySitzung(erzaehlDaten)..einrichten(rollen: 5, detektiv: 'w', solo: true);
    await _zeige(t, _mappe(solo));
    keiner('Solo');
    for (final d in [partyDaten, langDaten]) {
      expect(d.erzaehlerakteFuer(einfluss: false), isNull);
      await _zeige(t, _mappe(_sitzung(daten: d)));
      expect(find.text(_de.druck_je_person), findsOneWidget);
      keiner('ohne Erzählerakte');
    }
  });

  testWidgets('Im Browser: erst bauen, dann „Herunterladen: Erzählerakte“', (t) async {
    mitErsatzPortraets();
    final browser = _Browser();
    final vorher = dateiGeraet;
    dateiGeraet = browser;
    addTearDown(() => dateiGeraet = vorher);
    final s = _sitzung(rollen: 4);
    await _zeige(t, _mappe(s));
    final titel = s.ui('ui.druck.akte.titel');
    final laden = find.text(_de.druck_datei_laden(titel));
    expect(laden, findsNothing);
    await _tippeUndWarte(t, find.text(titel), () => laden.evaluate().isNotEmpty);
    expect(browser.angeboten, isEmpty, reason: 'Der erste Tipp baut nur');
    expect(laden, findsOneWidget);
    expect(find.text(_de.druck_datei_teilen(titel)), findsNothing);
    await t.tap(laden);
    await t.pump();
    expect(browser.angeboten, hasLength(1));
    final (name, weg, bytes) = browser.angeboten.single;
    expect((name, weg), ('erzaehlerakte.pdf', DateiWeg.herunterladen));
    expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
  });

  testWidgets('In der App: Akte → Druckmappe vorbereiten → Erzählerakte mit den Schriften aus dem Bündel', (t) async {
    mitErsatzPortraets();
    final geteilt = _zeuge();
    t.view.physicalSize = const Size(390, 844);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.view.resetDevicePixelRatio);
    final state = AppState(meta: MetaStore.memory()..name = 'Test', scenarios: const {});
    await t.runAsync(() async {
      // Die Akte vorab in echter Zeit, ohne Ladevorgänge früherer Tests im Zwischenspeicher.
      rootBundle.clear();
      await PartyDaten.laden(rootBundle);
      await AktenKatalog.laden();
      await t.pumpWidget(MordakteApp(app: state, initialLocation: Routes.druckmappeVon('schlosskeller')));
    });
    final vorbereiten = find.text('Druckmappe vorbereiten');
    for (var i = 0; i < 200 && vorbereiten.evaluate().isEmpty; i++) {
      await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
      await t.pump(const Duration(milliseconds: 50));
    }
    await t.tap(vorbereiten);
    await t.pump();
    final tafel = t.widget<DruckTafel>(find.byType(DruckTafel));
    expect(tafel.erzaehlerakte, isTrue);
    final s = tafel.sitzung;
    expect(find.text(s.ui('ui.druck.paket.dateien.ordner4'), skipOffstage: false), findsOneWidget);
    await _tippeUndWarte(t, find.text(s.ui('ui.druck.akte.titel')), () => geteilt.isNotEmpty);
    expect(geteilt.single.fileNameOverrides, ['erzaehlerakte.pdf']);
    final soll = await t.runAsync(() async => erzaehlerakteSoll(erzaehlDaten, einfluss: false, rollen: s.einstellungen.rollen));
    expect(await _bytes(t, geteilt.single), soll);
    await t.pumpWidget(const SizedBox.shrink());
    state.dispose();
  });
}
