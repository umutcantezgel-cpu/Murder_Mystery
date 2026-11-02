// Die Tafel des Kammerspiels in der Druckmappe (B1, B3, E16, ARCHITEKTUR A2/A3):
// „Alles in einer Datei“, die acht Teile mit Titeln aus ui/*.json und je besetzter
// Rolle „Senden an …“ (Spielername aus der Gästeliste über die Kanon-Figur, sonst der
// Name der Rolle). Für 6, 13 und 20 Personen genau die besetzten Rollen. Jede Datei
// entsteht erst beim Tipp; sie ist dieselbe wie aus dem Kern (Dateiname aus ui/*.json,
// %PDF-, gleiche Bytes). Kommt ein Kontext mit anderer Personenzahl, entsteht jede Datei
// neu. Eine Erzählerakte gibt es auf der Tafel nie.
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mordakte/l10n/gen/app_localizations_de.dart';
import 'package:mordakte/party/datei_knopf.dart';
import 'package:mordakte/party/datei_teilen.dart';
import 'package:mordakte/party/druck_speichern.dart';
import 'package:mordakte/party/kammer_tafel.dart';
import 'package:mordakte_core/kammer_io.dart' show ladeKammerInhalt;
import 'package:mordakte_core/party_druck.dart';
import 'package:share_plus/share_plus.dart';

import 'hilfe.dart';

final _de = LDe();

/// Der Inhalt aus dem Repo (Tests laufen im Repo-Wurzelordner), einmal geladen.
final KammerInhalt _inhalt = ladeKammerInhalt('.');

/// Der schlichte Druckstil mit den Schriften aus assets/fonts, wie die Kommandozeile.
final DruckStil _stil = DruckStil(
  regular: File('assets/fonts/Inter-Regular.ttf').readAsBytesSync(),
  fett: File('assets/fonts/Inter-Bold.ttf').readAsBytesSync(),
  schreibmaschine: File('assets/fonts/SpecialElite-Regular.ttf').readAsBytesSync(),
);

KammerKontext _kontext(int personen, {String detektiv = 'w', Map<String, String> spieler = const {}}) =>
    KammerKontext(_inhalt, personen: personen, stil: _stil, detektiv: detektiv, spieler: spieler);

Future<void> _zeige(WidgetTester t, KammerKontext k) async {
  t.view.physicalSize = const Size(1280, 1600);
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.resetPhysicalSize);
  addTearDown(t.view.resetDevicePixelRatio);
  await t.pumpWidget(rahmen(SingleChildScrollView(child: KammerTafel(kontext: k))));
}

/// Fängt das Teilen des Systems ab (App auf iOS und am Rechner: ein Tipp baut und teilt).
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

/// Der Browser ohne Teilen: Der erste Tipp baut, der zweite lädt herunter.
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

_Browser _imBrowser() {
  final b = _Browser();
  final vorher = dateiGeraet;
  dateiGeraet = b;
  addTearDown(() => dateiGeraet = vorher);
  return b;
}

/// Tippt auf [knopf] und wartet in echter Zeit, bis [fertig] gilt (der PDF-Satz läuft
/// wirklich). Scheitert der Satz, steht der Fehler da: Das darf nie sein.
Future<void> _tippeUndWarte(WidgetTester t, Finder knopf, bool Function() fertig) async {
  final fehler = find.text(_de.druck_datei_fehler);
  await t.ensureVisible(knopf);
  await t.tap(knopf);
  await t.pump();
  for (var i = 0; i < 1200 && !fertig() && fehler.evaluate().isEmpty; i++) {
    await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
    await t.pump(const Duration(milliseconds: 20));
  }
  await t.pump();
  expect(fehler, findsNothing, reason: 'Die Datei hinter „${(knopf.evaluate().firstOrNull?.widget as Text?)?.data}“ entsteht ohne Fehler');
}

Future<Uint8List> _bytes(WidgetTester t, ShareParams p) async => (await t.runAsync(() => p.files!.single.readAsBytes()))!;

/// Erwartet die Datei des Kerns: gleicher Name, %PDF-, gleiche Bytes.
Future<void> _wieImKern(WidgetTester t, String name, Uint8List bytes, Future<DruckDatei> Function() kern) async {
  final soll = (await t.runAsync(kern))!;
  expect(name, soll.name);
  expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
  expect(bytes, soll.bytes, reason: '$name wie aus dem Kern');
}

void main() {
  test('Titel und Dateinamen kommen aus ui/*.json', () {
    final k = _kontext(10);
    final roh = _inhalt.ui;
    expect(k.uiGemeinsam('titel.alles'), roh['gemeinsam']!['titel.alles']);
    expect(k.uiGemeinsam('datei.alles'), roh['gemeinsam']!['datei.alles']);
    for (final t in kammerDruckteile(k)) {
      expect(t.titel, roh[t.nr]!['titel'], reason: t.nr);
      expect(t.datei, roh[t.nr]!['datei'], reason: t.nr);
      expect(t.datei, endsWith('.pdf'), reason: t.nr);
    }
  });

  for (final personen in [6, 13, 20]) {
    testWidgets('$personen Personen: Alles, acht Teile und je besetzter Rolle ein Knopf, keine Erzählerakte', (t) async {
      final k = _kontext(personen);
      expect(k.besetzung.rollen, personen - 2, reason: 'Personen = Rollen + Detektiv + Erzähler');
      await _zeige(t, k);
      expect(find.text(k.spielTitel), findsOneWidget);
      expect(find.text(_de.druck_kammer_hinweis('$personen', '${personen - 2}')), findsOneWidget);
      expect(find.text(k.uiGemeinsam('titel.alles')), findsOneWidget);
      final teile = kammerDruckteile(k);
      expect([for (final t in teile) t.nr], kammerTeile);
      expect(teile, hasLength(8));
      for (final teil in teile) {
        expect(find.text(teil.titel), findsOneWidget, reason: teil.nr);
      }
      expect(find.text(_de.druck_je_person), findsOneWidget);
      expect(find.text(_de.druck_kammer_je_person_hinweis), findsOneWidget);
      // Genau die besetzten Rollen, in Platzreihenfolge, mit dem Namen der Rolle.
      final senden = find.textContaining(_de.druck_senden_an(''));
      expect(senden, findsNWidgets(personen - 2));
      expect([for (final e in senden.evaluate()) (e.widget as Text).data], [for (final p in k.besetzung.besetzt) _de.druck_senden_an(p.name)]);
      for (final p in _inhalt.fall.plaetze.skip(personen - 2)) {
        expect(find.text(_de.druck_senden_an(p.name)), findsNothing, reason: '${p.name} spielt heute niemand');
      }
      // Je Datei ein Knopf: 1 + 8 + Rollen.
      expect(find.byType(DateiKnopf), findsNWidgets(1 + 8 + personen - 2));
      // E16: keine Erzählerakte, kein „Nur Erzähler“, kein Fall-Code-Hinweis des alten Druckspiels.
      expect(find.textContaining('Erzählerakte'), findsNothing);
      expect(find.text(_de.druck_erzaehlerakte_hinweis), findsNothing);
      expect(find.text(_de.druck_je_person_hinweis), findsNothing);
      expect(t.takeException(), isNull);
    });
  }

  test('Zusatzrollen erst ab 13 Personen, bei 20 alle 18 Rollen', () {
    expect(_kontext(6).besetzung.besetzt.map((p) => p.art).toSet(), {KammerArt.verdaechtig});
    expect(_kontext(12).besetzung.zusatzrollen, isEmpty);
    expect(_kontext(13).besetzung.zusatzrollen.map((p) => p.name), ['Sibel']);
    expect(_kontext(20).besetzung.besetzt, hasLength(18));
  });

  testWidgets('ein Tipp baut die Datei aus dem Kern und teilt sie als PDF mit dem Namen aus ui/*.json', (t) async {
    final geteilt = _zeuge();
    final k = _kontext(10);
    await _zeige(t, k);
    final bogen = kammerTeil(k, '01');
    await _tippeUndWarte(t, find.text(bogen.titel), () => geteilt.isNotEmpty);
    expect(find.text(_de.druck_datei_fehler), findsNothing);
    final p = geteilt.single;
    expect(p.fileNameOverrides, [_inhalt.ui['01']!['datei']]);
    expect(p.files!.single.mimeType, 'application/pdf');
    await _wieImKern(t, p.fileNameOverrides!.single, await _bytes(t, p), () => kammerTeilDatei(k, bogen));
    // Der zweite Tipp baut nicht neu und teilt dieselbe Datei.
    await _tippeUndWarte(t, find.text(bogen.titel), () => geteilt.length > 1);
    expect(geteilt.last.fileNameOverrides, p.fileNameOverrides);
  });

  testWidgets('„Alles in einer Datei“ baut kammerspiel-alles.pdf wie der Kern', (t) async {
    final geteilt = _zeuge();
    final k = _kontext(6);
    await _zeige(t, k);
    await _tippeUndWarte(t, find.text(k.uiGemeinsam('titel.alles')), () => geteilt.isNotEmpty);
    final p = geteilt.single;
    expect(p.fileNameOverrides, [_inhalt.ui['gemeinsam']!['datei.alles']]);
    await _wieImKern(t, p.fileNameOverrides!.single, await _bytes(t, p), () => kammerAlles(k));
  });

  testWidgets('„Senden an“ nennt die Spieler der Gästeliste über die Kanon-Figur, sonst die Rolle', (t) async {
    final browser = _imBrowser();
    // Lejla ist im Kanon leyla, Sibel ist selin; „detective“ und eine Figur ohne Platz heute stören nicht.
    final k = _kontext(13, spieler: {'ahmet': 'Ben', 'leyla': 'Mia', 'selin': 'Sara', 'detective': 'Kim', 'tugba': 'Noor'});
    final lejla = _inhalt.fall.plaetze.firstWhere((p) => p.id == 'lejla');
    final sibel = _inhalt.fall.plaetze.firstWhere((p) => p.id == 'sibel');
    expect((lejla.kanonFigur, sibel.kanonFigur), ('leyla', 'selin'));
    await _zeige(t, k);
    for (final name in ['Ben', 'Mia', 'Sara']) {
      expect(find.text(_de.druck_senden_an(name)), findsOneWidget, reason: name);
    }
    expect(find.text(_de.druck_senden_an('Ahmet')), findsNothing, reason: 'Ben spielt Ahmet');
    expect(find.text(_de.druck_senden_an('Lejla')), findsNothing, reason: 'Mia spielt Lejla');
    expect(find.text(_de.druck_senden_an('Fatma')), findsOneWidget, reason: 'Fatma ohne Gast');
    expect(find.text(_de.druck_senden_an('Kim')), findsNothing, reason: 'Der Detektiv hat kein Rollenheft');
    expect(find.text(_de.druck_senden_an('Noor')), findsNothing, reason: 'Tugba spielt bei 13 Personen niemand');
    expect(find.textContaining(_de.druck_senden_an('')), findsNWidgets(11));

    // Rollenheft (Platz 1–10): „Herunterladen: Rollenheft Mia“, Datei mit dem Rollennamen.
    final mia = find.text(_de.druck_datei_laden(_de.druck_rollenheft_von('Mia')));
    await _tippeUndWarte(t, find.text(_de.druck_senden_an('Mia')), () => mia.evaluate().isNotEmpty);
    expect(browser.angeboten, isEmpty, reason: 'Der erste Tipp baut nur');
    await t.tap(mia);
    await t.pump();
    final (name, weg, bytes) = browser.angeboten.single;
    expect(weg, DateiWeg.herunterladen);
    expect(name, _inhalt.ui['10']!['dateiEinzeln']!.replaceAll('{figur}', 'lejla'));
    await _wieImKern(t, name, bytes, () => kammerEinzeldatei(k, lejla));

    // Zusatzheft (Platz 11–18): „Herunterladen: Zusatzheft Sara“.
    final sara = find.text(_de.druck_datei_laden(_de.druck_zusatzheft_von('Sara')));
    await _tippeUndWarte(t, find.text(_de.druck_senden_an('Sara')), () => sara.evaluate().isNotEmpty);
    await t.tap(sara);
    await t.pump();
    final (name2, _, bytes2) = browser.angeboten.last;
    expect(name2, _inhalt.ui['12']!['dateiEinzeln']!.replaceAll('{figur}', 'sibel'));
    await _wieImKern(t, name2, bytes2, () => kammerEinzeldatei(k, sibel));
  });

  testWidgets('Ändert sich die Personenzahl, entsteht jede Datei neu', (t) async {
    final browser = _imBrowser();
    final k6 = _kontext(6);
    await _zeige(t, k6);
    final bogen = kammerTeil(k6, '01');
    final laden = find.text(_de.druck_datei_laden(bogen.titel));
    await _tippeUndWarte(t, find.text(bogen.titel), () => laden.evaluate().isNotEmpty);
    expect(laden, findsOneWidget);
    // Dieselbe Tafel mit einem Kontext für zehn Personen: wieder der Knopf zum Bauen.
    final k10 = _kontext(10);
    await t.pumpWidget(rahmen(SingleChildScrollView(child: KammerTafel(kontext: k10))));
    expect(laden, findsNothing);
    expect(find.text(_de.druck_kammer_hinweis('10', '8')), findsOneWidget);
    expect(find.textContaining(_de.druck_senden_an('')), findsNWidgets(8));
    await _tippeUndWarte(t, find.text(bogen.titel), () => laden.evaluate().isNotEmpty);
    await t.tap(laden);
    await t.pump();
    await _wieImKern(t, browser.angeboten.single.$1, browser.angeboten.single.$3, () => kammerTeilDatei(k10, kammerTeil(k10, '01')));
    // Ebenso der Detektiv: ein neuer Schlüssel je Wahl.
    await t.pumpWidget(rahmen(SingleChildScrollView(child: KammerTafel(kontext: _kontext(10, detektiv: 'm')))));
    expect(laden, findsNothing);
    expect(find.text(bogen.titel), findsOneWidget);
  });
}
