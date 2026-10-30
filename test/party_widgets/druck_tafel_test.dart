// F5-BAUMEISTER-04, M5: Druckfassung in der App (Master 7.6, 7.14, A-059). Mit Druckspiel
// steht die Tafel in der Rollenvergabe: Fall-Code-Hinweis, „Alles in einer Datei“, die acht
// Teile und je Person ein Rollenheft. Jede Datei entsteht erst beim Tipp und geht an das
// Teilen des Systems (kein „nur im Browser“ mehr); im Browser steht danach immer
// „Herunterladen“ und, wenn er Dateien teilen kann, „Teilen“, in der Android-App beide
// („Herunterladen“ öffnet den Speichern-Dialog des Systems). Ohne Druckspiel gibt es reihum bei
// Akten mit Druckfassung nur das Erzählerheft, ohne Fall-Code.
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mordakte/detektei/akten.dart';
import 'package:mordakte/l10n/gen/app_localizations_de.dart';
import 'package:mordakte/party/bildschirme/rollen.dart';
import 'package:mordakte/party/daten.dart';
import 'package:mordakte/party/datei_teilen.dart';
import 'package:mordakte/party/druck_speichern.dart';
import 'package:mordakte/party/sitzung.dart';
import 'package:mordakte_core/mordakte_core.dart';
import 'package:share_plus/share_plus.dart';

import 'hilfe.dart';

final _de = LDe();

Map<String, Object?> _json(String pfad) => jsonDecode(File(pfad).readAsStringSync()) as Map<String, Object?>;

/// Schlosskeller mit dem Zusatz druckspiel (wie in akten.json).
final _mitDruckspiel = PartyDaten.aus(
  (p) => _json('content/party/schlosskeller/$p'),
  _json('content/scenarios/ravensmoor.json'),
  akte: const AkteInfo(id: 'schlosskeller', titel: 'Spuk im Schlosskeller', untertitel: '', ton: 'spuk', faehigkeiten: {'druckspiel'}),
);

PartySitzung _sitzung({required bool druck, PartyDaten? daten, Map<String, String> namen = const {}}) =>
    PartySitzung(daten ?? partyDaten)
      ..einrichten(rollen: 5, detektiv: 'w', code: FallCode.fuerPfad('olli', partyDaten.kanon.pfade).code, druck: druck, namen: namen);

Future<void> _zeige(WidgetTester t, PartySitzung s) async {
  t.view.physicalSize = const Size(1280, 1600);
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.resetPhysicalSize);
  addTearDown(t.view.resetDevicePixelRatio);
  await t.pumpWidget(rahmen(RollenBildschirm(sitzung: s)));
}

/// Fängt das Teilen des Systems ab; [scheitern] lässt es wie auf einem Gerät ohne Teilen scheitern.
List<ShareParams> _zeuge({bool scheitern = false}) {
  final geteilt = <ShareParams>[];
  final vorher = dateiTeilenUeber;
  dateiTeilenUeber = (p) async {
    if (scheitern) throw UnsupportedError('kein Teilen');
    geteilt.add(p);
    return const ShareResult('ok', ShareResultStatus.success);
  };
  addTearDown(() => dateiTeilenUeber = vorher);
  return geteilt;
}

/// Spielt den Browser nach: Download immer, Teilen nur mit [teilbar] (Chrome und
/// Edge unter Windows, Safari am Mac). Das Teilen-Fenster wird geschlossen; das
/// meldet die Web-Fassung wie ein Abbruch ohne Fehler.
class _Browser extends DateiGeraet {
  _Browser({required this.teilbar});

  final bool teilbar;
  final angeboten = <(String, DateiWeg)>[];

  @override
  bool get zweiterTipp => true;

  @override
  bool get kannHerunterladen => true;

  @override
  bool kannTeilen(String name, String typ) => teilbar;

  @override
  Future<bool> anbieten(String name, Uint8List bytes, {required String typ, Rect? ursprung, required DateiWeg weg}) async {
    angeboten.add((name, weg));
    return true;
  }
}

_Browser _imBrowser({required bool teilbar}) {
  final b = _Browser(teilbar: teilbar);
  final vorher = dateiGeraet;
  dateiGeraet = b;
  addTearDown(() => dateiGeraet = vorher);
  return b;
}

/// Spielt die Android-App nach: „Herunterladen“ (Speichern-Dialog des Systems) und
/// „Teilen“ nach dem Bauen; wer nicht wählt, teilt.
class _Android extends DateiGeraet {
  final angeboten = <(String, DateiWeg)>[];

  @override
  bool get zweiterTipp => true;

  @override
  bool get kannHerunterladen => true;

  @override
  bool kannTeilen(String name, String typ) => true;

  @override
  DateiWeg get standardWeg => DateiWeg.teilen;

  @override
  Future<bool> anbieten(String name, Uint8List bytes, {required String typ, Rect? ursprung, required DateiWeg weg}) async {
    angeboten.add((name, weg));
    return true;
  }
}

_Android _aufAndroid() {
  final a = _Android();
  final vorher = dateiGeraet;
  dateiGeraet = a;
  addTearDown(() => dateiGeraet = vorher);
  return a;
}

/// Tippt auf [knopf] und wartet in echter Zeit, bis [fertig] gilt (die PDF-Erzeugung läuft wirklich).
Future<void> _tippeUndWarte(WidgetTester t, Finder knopf, bool Function() fertig) async {
  await t.ensureVisible(knopf);
  await t.tap(knopf);
  await t.pump();
  for (var i = 0; i < 400 && !fertig(); i++) {
    await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
    await t.pump(const Duration(milliseconds: 20));
  }
  await t.pump();
}

const _teile = ['spielleitung', 'detektivbogen', 'rollenhefte', 'fassungen', 'stimmkarten', 'indizkarten', 'umschlaege', 'aufloesung'];

void main() {
  testWidgets('ohne Druck und ohne Druckspiel-Akte gibt es keine Druckfassung', (t) async {
    final s = _sitzung(druck: false);
    await _zeige(t, s);
    expect(find.text(s.ui('ui.druck.app.titel')), findsNothing);
    expect(find.text(s.ui('ui.druck.datei.spielleitung')), findsNothing);
  });

  testWidgets('mit Druck: Fall-Code-Hinweis, „Alles in einer Datei“, acht Teile und je Person ein Knopf, ohne Erstellen-Schritt', (t) async {
    final s = _sitzung(druck: true, namen: {'ahmet': 'Ayla'});
    await _zeige(t, s);
    expect(find.text(s.ui('ui.druck.app.titel')), findsOneWidget);
    expect(find.text(s.ui('ui.druck.app.hinweis', {'code': s.fallCode.code})), findsOneWidget);
    expect(find.text(s.ui('ui.druck.datei.alles')), findsOneWidget);
    for (final teil in _teile) {
      expect(find.text(s.ui('ui.druck.datei.$teil')), findsOneWidget, reason: teil);
    }
    expect(find.text(_de.druck_je_person), findsOneWidget);
    expect(find.text(_de.druck_senden_an('Ayla')), findsOneWidget);
    for (final r in s.besetzt.skip(1)) {
      expect(find.text(_de.druck_senden_an(s.figurName(r))), findsOneWidget, reason: r);
    }
    // Den alten Zwischenschritt und den Browser-Hinweis gibt es nicht mehr.
    expect(find.text(s.ui('ui.druck.app.erstellen')), findsNothing);
    expect(find.text(s.ui('ui.druck.app.nur_browser')), findsNothing);
  });

  testWidgets('ein Tipp erstellt die Datei und gibt sie als PDF an das Teilen des Systems', (t) async {
    final geteilt = _zeuge();
    final s = _sitzung(druck: true);
    await _zeige(t, s);
    final knopf = find.text(s.ui('ui.druck.datei.aufloesung'));
    await _tippeUndWarte(t, knopf, () => geteilt.isNotEmpty);
    expect(geteilt, hasLength(1));
    final p = geteilt.single;
    expect(p.fileNameOverrides, ['90-aufloesung-versiegelt.pdf']);
    expect(p.files!.single.mimeType, 'application/pdf');
    final bytes = await t.runAsync(() => p.files!.single.readAsBytes());
    expect(String.fromCharCodes(bytes!.take(5)), '%PDF-');
    expect(find.text(s.ui('ui.druck.app.nur_browser')), findsNothing);
    expect(find.text(_de.druck_datei_fehler), findsNothing);

    // Der zweite Tipp baut nicht neu, er teilt dieselbe Datei noch einmal.
    await _tippeUndWarte(t, knopf, () => geteilt.length > 1);
    expect(geteilt, hasLength(2));
    expect(geteilt.last.fileNameOverrides, ['90-aufloesung-versiegelt.pdf']);
  });

  testWidgets('„Alles in einer Datei“ und „Senden an“ teilen das Druckspiel und das Heft der Person', (t) async {
    final geteilt = _zeuge();
    final s = _sitzung(druck: true, namen: {'fatma': 'Bea'});
    await _zeige(t, s);
    await _tippeUndWarte(t, find.text(s.ui('ui.druck.datei.alles')), () => geteilt.isNotEmpty);
    expect(geteilt.single.fileNameOverrides, ['druckspiel-alles.pdf']);
    await _tippeUndWarte(t, find.text(_de.druck_senden_an('Bea')), () => geteilt.length > 1);
    expect(geteilt.last.fileNameOverrides, ['10-rollenheft-fatma.pdf']);
  });

  testWidgets('scheitert das Teilen, steht ein Hinweis da, nie „nur im Browser“', (t) async {
    final geteilt = _zeuge(scheitern: true);
    final s = _sitzung(druck: true);
    await _zeige(t, s);
    await _tippeUndWarte(t, find.text(s.ui('ui.druck.datei.detektivbogen')), () => find.text(_de.druck_datei_fehler).evaluate().isNotEmpty);
    expect(geteilt, isEmpty);
    expect(find.text(_de.druck_datei_fehler), findsOneWidget);
    expect(find.text(s.ui('ui.druck.app.nur_browser')), findsNothing);
  });

  testWidgets('im Browser mit Teilen (Rechner): Herunterladen steht vorn, ein geschlossenes Teilen-Fenster lässt den Download', (t) async {
    final browser = _imBrowser(teilbar: true);
    final s = _sitzung(druck: true);
    await _zeige(t, s);
    final alles = s.ui('ui.druck.datei.alles');
    final laden = find.text(_de.druck_datei_laden(alles));
    final teilen = find.text(_de.druck_datei_teilen(alles));
    await _tippeUndWarte(t, find.text(alles), () => laden.evaluate().isNotEmpty);
    // Der erste Tipp baut nur; Download und Teilen brauchen im Browser einen eigenen Tipp.
    expect(browser.angeboten, isEmpty);
    expect(laden, findsOneWidget);
    expect(teilen, findsOneWidget);
    expect(t.getTopLeft(laden).dx, lessThan(t.getTopLeft(teilen).dx));

    await t.tap(teilen);
    await t.pump();
    expect(browser.angeboten, [('druckspiel-alles.pdf', DateiWeg.teilen)]);
    expect(find.text(_de.druck_datei_fehler), findsNothing);
    // Nach dem Teilen-Fenster ist der Download noch da.
    expect(laden, findsOneWidget);
    await t.tap(laden);
    await t.pump();
    expect(browser.angeboten.last, ('druckspiel-alles.pdf', DateiWeg.herunterladen));
  });

  testWidgets('im Browser ohne Teilen (Firefox am Rechner): nur Herunterladen', (t) async {
    final browser = _imBrowser(teilbar: false);
    final s = _sitzung(druck: true, namen: {'fatma': 'Bea'});
    await _zeige(t, s);
    final senden = _de.druck_senden_an('Bea');
    final laden = find.text(_de.druck_datei_laden(senden));
    await _tippeUndWarte(t, find.text(senden), () => laden.evaluate().isNotEmpty);
    expect(find.text(_de.druck_datei_teilen(senden)), findsNothing);
    await t.tap(laden);
    await t.pump();
    expect(browser.angeboten, [('10-rollenheft-fatma.pdf', DateiWeg.herunterladen)]);
  });

  testWidgets('in der Android-App: nach dem Bauen „Herunterladen“ und „Teilen“, jeder Knopf nimmt seinen Weg', (t) async {
    final android = _aufAndroid();
    final s = _sitzung(druck: true, namen: {'fatma': 'Bea'});
    await _zeige(t, s);
    final senden = _de.druck_senden_an('Bea');
    final laden = find.text(_de.druck_datei_laden(senden));
    final teilen = find.text(_de.druck_datei_teilen(senden));
    await _tippeUndWarte(t, find.text(senden), () => laden.evaluate().isNotEmpty);
    // Der erste Tipp baut nur, auch beim Rollenheft einer Person; dann wählt man den Weg.
    expect(android.angeboten, isEmpty);
    expect(laden, findsOneWidget);
    expect(teilen, findsOneWidget);
    expect(t.getTopLeft(laden).dx, lessThan(t.getTopLeft(teilen).dx));

    await t.tap(laden);
    await t.pump();
    expect(android.angeboten, [('10-rollenheft-fatma.pdf', DateiWeg.herunterladen)]);
    await t.tap(teilen);
    await t.pump();
    expect(android.angeboten.last, ('10-rollenheft-fatma.pdf', DateiWeg.teilen));
    expect(find.text(_de.druck_datei_fehler), findsNothing);
  });

  testWidgets('reihum ohne Druck, Akte mit Druckspiel: nur das Erzählerheft, kein Fall-Code; im Solo keins', (t) async {
    final geteilt = _zeuge();
    final s = _sitzung(druck: false, daten: _mitDruckspiel);
    await _zeige(t, s);
    final heft = find.text(s.ui('ui.druck.datei.spielleitung'));
    expect(heft, findsNWidgets(2), reason: 'Titel der Tafel und Knopf');
    expect(find.text(_de.druck_erzaehlerheft_hinweis), findsOneWidget);
    expect(find.textContaining(s.fallCode.code), findsNothing);
    expect(find.text(s.ui('ui.druck.datei.aufloesung')), findsNothing);
    expect(find.text(s.ui('ui.druck.datei.alles')), findsNothing);
    await _tippeUndWarte(t, heft.last, () => geteilt.isNotEmpty);
    expect(geteilt.single.fileNameOverrides, ['00-erzaehlerheft.pdf']);

    // Ein Solo-Abend hat keinen Erzähler: dort gibt es kein Heft.
    final solo = PartySitzung(_mitDruckspiel)..einrichten(rollen: 5, detektiv: 'w', solo: true);
    await _zeige(t, solo);
    expect(find.text(solo.ui('ui.druck.datei.spielleitung')), findsNothing);
  });
}
