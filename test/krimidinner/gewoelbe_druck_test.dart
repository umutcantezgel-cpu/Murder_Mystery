// Druck: Vorschau der Steckbriefe auf Papierweiß, je Person ein Mappen-Knopf,
// kein Mappeninhalt im Baum. In der App gehen Steckbriefe und Mappen an das Teilen
// des Systems (M5, A-059); nur wenn das scheitert, kommt der Hinweis aufs Drucken im Browser.
// Im Browser laden sie herunter, auch wenn er Dateien teilen kann (Rechner).
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mordakte/krimidinner/abschnitt_ansicht.dart';
import 'package:mordakte/krimidinner/gewoelbe_seite.dart';
import 'package:mordakte/party/datei_teilen.dart';
import 'package:mordakte/party/druck_speichern.dart';
import 'package:share_plus/share_plus.dart';

import 'hilfe.dart';

const nurBrowser = 'Speichern geht nur im Browser. Öffne die App im Browser und drucke von dort.';

bool mappenInhaltSichtbar(WidgetTester tester, int n) {
  for (var r = 1; r <= n; r++) {
    final rr = 'R${r.toString().padLeft(2, '0')}';
    for (final (id, f) in [('$rr-GEHEIM', 'Motiv'), ('$rr-LÜGE', 'Muss wahr sagen über'), ('$rr-WISSEN', 'Wissen')]) {
      final wert = feld(id, f);
      if (sichtbar(tester, wert.substring(0, wert.length < 50 ? wert.length : 50))) return true;
    }
  }
  return sichtbar(tester, feld('DET-B1', 'Beobachtung'));
}

void main() {
  testWidgets('Vorschau zeigt N Steckbriefe, je Person ein Mappen-Knopf, kein Mappeninhalt', (tester) async {
    groesse(tester, const Size(800, 3000));
    await tester.pumpWidget(gewoelbeApp(teil: GewoelbeTeil.druck, n: 6));
    await bilder(tester);

    expect(find.text('Steckbriefe für alle'), findsOneWidget);
    expect(find.text('Als Datei speichern'), findsOneWidget);
    expect(find.text('Rollenmappen – geheim'), findsOneWidget);
    expect(find.text('Druck die Mappen, ohne hineinzuschauen. Am besten druckt nicht das Geburtstagskind.'), findsOneWidget);

    final vorschau = tester.widgetList<AbschnittAnsicht>(find.byType(AbschnittAnsicht)).where((a) => a.hell).toList();
    expect(vorschau, hasLength(8));
    expect(vorschau.where((a) => a.abschnitt.schluessel!.startsWith('R')), hasLength(6));

    expect(find.text('Mappe für das Geburtstagskind'), findsOneWidget);
    for (var r = 1; r <= 6; r++) {
      expect(find.text('Mappe für ${feld('R${r.toString().padLeft(2, '0')}-STAMM', 'Name')}'), findsOneWidget);
    }
    expect(find.textContaining('Mappe für '), findsNWidgets(7));
    expect(mappenInhaltSichtbar(tester, 6), isFalse);
  });

  testWidgets('In der App gehen Steckbriefe und Mappen als HTML an das Teilen des Systems', (tester) async {
    final geteilt = <ShareParams>[];
    final vorher = dateiTeilenUeber;
    dateiTeilenUeber = (p) async {
      geteilt.add(p);
      return const ShareResult('ok', ShareResultStatus.success);
    };
    addTearDown(() => dateiTeilenUeber = vorher);
    groesse(tester, const Size(800, 3000));
    await tester.pumpWidget(gewoelbeApp(teil: GewoelbeTeil.druck, n: 5));
    await bilder(tester);

    await tester.tap(find.text('Als Datei speichern'));
    await bilder(tester);
    expect(geteilt.single.fileNameOverrides, ['gewoelbe-steckbriefe-5.html']);
    expect(geteilt.single.files!.single.mimeType, 'text/html');
    expect(find.text('Gespeichert: gewoelbe-steckbriefe-5.html'), findsOneWidget);
    expect(find.text(nurBrowser), findsNothing);

    await tester.ensureVisible(find.text('Mappe für Merle Hartwig'));
    await tester.tap(find.text('Mappe für Merle Hartwig'));
    await bilder(tester);
    expect(geteilt, hasLength(2));
    expect(geteilt.last.fileNameOverrides!.single, startsWith('gewoelbe-mappe-'));
    expect(find.text(nurBrowser), findsNothing);
    expect(mappenInhaltSichtbar(tester, 5), isFalse);
  });

  testWidgets('Im Browser lädt Speichern die Datei herunter, auch wenn er Dateien teilen kann', (tester) async {
    final browser = _Browser();
    final vorher = dateiGeraet;
    dateiGeraet = browser;
    addTearDown(() => dateiGeraet = vorher);
    groesse(tester, const Size(800, 3000));
    await tester.pumpWidget(gewoelbeApp(teil: GewoelbeTeil.druck, n: 5));
    await bilder(tester);

    await tester.tap(find.text('Als Datei speichern'));
    await bilder(tester);
    expect(browser.angeboten, [('gewoelbe-steckbriefe-5.html', DateiWeg.herunterladen)]);
    expect(find.text('Gespeichert: gewoelbe-steckbriefe-5.html'), findsOneWidget);
    expect(find.text(nurBrowser), findsNothing);
  });

  testWidgets('Scheitert das Teilen, zeigt Speichern den Hinweis, Mappen bleiben verdeckt', (tester) async {
    final vorher = dateiTeilenUeber;
    dateiTeilenUeber = (p) async => throw UnsupportedError('kein Teilen');
    addTearDown(() => dateiTeilenUeber = vorher);
    groesse(tester, const Size(800, 3000));
    await tester.pumpWidget(gewoelbeApp(teil: GewoelbeTeil.druck, n: 5));
    await bilder(tester);
    expect(find.text(nurBrowser), findsNothing);

    await tester.tap(find.text('Als Datei speichern'));
    await bilder(tester);
    expect(find.text(nurBrowser), findsOneWidget);

    await tester.ensureVisible(find.text('Mappe für Merle Hartwig'));
    await tester.tap(find.text('Mappe für Merle Hartwig'));
    await bilder(tester);
    expect(find.text(nurBrowser), findsOneWidget);
    expect(mappenInhaltSichtbar(tester, 5), isFalse);

    await tester.ensureVisible(find.text('Mappe für das Geburtstagskind'));
    await tester.tap(find.text('Mappe für das Geburtstagskind'));
    await bilder(tester);
    expect(mappenInhaltSichtbar(tester, 5), isFalse);
  });

  testWidgets('Druck im Telefonformat ohne Überlauf', (tester) async {
    groesse(tester, const Size(390, 844));
    await tester.pumpWidget(gewoelbeApp(teil: GewoelbeTeil.druck, n: 20));
    await bilder(tester);
    expect(tester.takeException(), isNull);
  });

  testWidgets('die Mappen-Knöpfe stehen vor der Vorschau, auch bei 20 Rollen schnell erreichbar', (tester) async {
    groesse(tester, const Size(390, 844));
    await tester.pumpWidget(gewoelbeApp(teil: GewoelbeTeil.druck, n: 20));
    await bilder(tester);
    final mappen = tester.getTopLeft(find.text('Rollenmappen – geheim')).dy;
    final vorschau = tester.getTopLeft(find.text('VORSCHAU')).dy;
    final ersteKarte = tester.getTopLeft(find.byWidgetPredicate((w) => w is AbschnittAnsicht && w.hell).first).dy;
    expect(mappen, lessThan(vorschau));
    expect(mappen, lessThan(ersteKarte));
    // Der Knopf für das Geburtstagskind liegt höchstens zwei Bildschirmhöhen tief.
    expect(tester.getTopLeft(find.text('Mappe für das Geburtstagskind')).dy, lessThan(2 * 844));
  });
}

/// Ein Browser, der Dateien teilen kann (Chrome unter Windows, Safari am Mac).
class _Browser extends DateiGeraet {
  final angeboten = <(String, DateiWeg)>[];

  @override
  bool get zweiterTipp => true;

  @override
  bool get kannHerunterladen => true;

  @override
  bool kannTeilen(String name, String typ) => true;

  @override
  Future<bool> anbieten(String name, Uint8List bytes, {required String typ, Rect? ursprung, required DateiWeg weg}) async {
    angeboten.add((name, weg));
    return true;
  }
}
