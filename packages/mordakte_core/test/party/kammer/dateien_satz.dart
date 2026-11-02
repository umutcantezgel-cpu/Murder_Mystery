// Gemeinsamer Teil von dateien_test.dart und dateien_14_20_test.dart: je Personenzahl
// die acht Teile in fester Reihenfolge mit den Dateinamen aus ui/*.json, alle Seiten A4
// (Lageplan-Blätter und Karten quer), „Alles in einer Datei“ mit der Summe der Seiten,
// die Seitenzählung je Teil und an den Grenzen die Einzeldateien je besetzter Rolle (nie
// Teil 90), der Druckrand und die Bytegleichheit (doppelter Satz). Zwei Testdateien, damit
// der Testlauf die Personenzahlen auf zwei Prozesse verteilt: In einer Datei war sie mit
// rund 110 s der längste Lauf von test/party/kammer/ (4 Prozesse), geteilt je rund 75 s.
import 'package:mordakte_core/party_druck.dart';
import 'package:test/test.dart';

import 'kammer_druck_hilfe.dart';

/// Teile und Dateinamen nach ARCHITEKTUR A2 / MECH 10.1, in dieser Reihenfolge.
const teile = ['00', '01', '02', '10', '11', '12', '20', '90'];
const dateinamen = [
  '00-erzaehlerheft.pdf',
  '01-detektivbogen.pdf',
  '02-tisch.pdf',
  '10-rollenhefte.pdf',
  '11-fassungen.pdf',
  '12-zusatzrollen.pdf',
  '20-karten.pdf',
  '90-aufloesung-versiegelt.pdf',
];

/// Format je Seite: Teil 02 Blatt A und B quer, der Rest hoch; Teil 20 ganz quer (MECH 10.1, 10.2).
List<String> erwartetesFormat(String teil, int seiten) => [
      for (var i = 0; i < seiten; i++)
        switch (teil) {
          '02' => i < 2 ? 'quer' : 'hoch',
          '20' => 'quer',
          _ => 'hoch',
        },
    ];

/// Personenzahlen mit Einzeldateien und Bytegleichheit (Begründung oben).
const grenzen = {6, 11, 12, 13, 14, 20};

/// Die Prüfungen je Personenzahl von [von] bis [bis] (je eine Gruppe „N Personen“).
void dateienJePersonen(int von, int bis) {
  for (var personen = von; personen <= bis; personen++) {
    group('$personen Personen', () {
      late KammerKontext k;
      late List<DruckDatei> dateien;
      late List<KammerPdf> pdfs;
      late DruckDatei alles;
      late KammerPdf a;
      late List<DruckDatei> einzeln;
      late List<KammerPdf> einzelPdfs;

      setUpAll(() async {
        k = kammerKontext(personen);
        dateien = await kammerTeilDateien(k);
        alles = await kammerAlles(k);
        einzeln = grenzen.contains(personen) ? await kammerEinzeldateien(k) : const [];
        final alle = await kammerPdfs([for (final d in [...dateien, alles, ...einzeln]) d.bytes]);
        pdfs = alle.sublist(0, dateien.length);
        a = alle[dateien.length];
        einzelPdfs = alle.sublist(dateien.length + 1);
      });

      test('acht Teile in fester Reihenfolge mit den Dateinamen aus ui/*.json', () {
        expect([for (final t in kammerDruckteile(k)) t.nr], teile);
        expect([for (final d in dateien) d.name], dateinamen);
        expect([for (final t in kammerDruckteile(k)) t.datei], dateinamen);
        expect([for (final t in kammerDruckteile(k)) t.titel], everyElement(isNotEmpty));
      });

      test('jede Seite A4, Lageplan-Blätter und Karten quer, der Rest hoch', () {
        for (var i = 0; i < teile.length; i++) {
          expect(pdfs[i].seiten, greaterThan(0), reason: dateinamen[i]);
          expect(pdfs[i].formate, erwartetesFormat(teile[i], pdfs[i].seiten), reason: dateinamen[i]);
        }
      });

      test('Teil 12: ohne Zusatzrollen genau die Hinweisseite', () {
        final zusatz = pdfs[teile.indexOf('12')];
        if (k.besetzung.zusatzrollen.isEmpty) {
          expect(zusatz.seiten, 1);
          expect(kammerFlach(zusatz.text), contains(kammerFlach(k.ui('12', 'hinweisseite'))));
        } else {
          for (final p in k.besetzung.zusatzrollen) {
            expect(zusatz.text, contains(p.name));
          }
        }
      });

      test('kammerspiel-alles.pdf: alle Teile, Seiten = Summe, Formate in Reihenfolge', () {
        expect(alles.name, k.uiGemeinsam('datei.alles'));
        expect(alles.name, 'kammerspiel-alles.pdf');
        expect(a.seiten, pdfs.fold(0, (s, p) => s + p.seiten));
        expect(a.formate, [for (final p in pdfs) ...p.formate]);
      });

      test('Seitenzahlen zählen je Teil, auch in der Gesamtdatei', () {
        // Muster des Fußes „Seite x von y“ aus ui/gemeinsam.json; Seiten ohne Fuß (Deckblatt,
        // Außenseite, Raster) zählen mit, tragen ihn aber nicht.
        final muster = RegExp(RegExp.escape(kammerFlach(k.uiGemeinsam('fuss.seite', {'seite': '#S#', 'seiten': '#N#'})))
            .replaceAll('#S#', r'(\d+)')
            .replaceAll('#N#', r'(\d+)'));
        var start = 0;
        for (var i = 0; i < teile.length; i++) {
          final n = pdfs[i].seiten;
          var mitFuss = 0;
          for (var s = 1; s <= n; s++) {
            for (final (wo, text) in [(dateinamen[i], pdfs[i].seitenText[s - 1]), ('alles', a.seitenText[start + s - 1])]) {
              final m = muster.firstMatch(kammerFlach(text));
              if (m == null) continue;
              mitFuss++;
              // Im Teil zählt die Seite ab 1; ein Bereich (etwa ein Rollenheft) zählt für sich.
              expect(int.parse(m.group(1)!), lessThanOrEqualTo(int.parse(m.group(2)!)), reason: '$wo Seite $s');
              if (i < 2) expect((int.parse(m.group(1)!), int.parse(m.group(2)!)), (s, n), reason: '$wo Seite $s');
            }
          }
          if (i < 2) expect(mitFuss, greaterThan(0), reason: dateinamen[i]);
          start += n;
        }
      });

      if (grenzen.contains(personen)) {
        test('je besetzter Rolle eine Einzeldatei mit Rollennamen, nie Teil 90', () {
          final b = k.besetzung;
          expect([for (final d in einzeln) d.figur], [for (final p in b.besetzt) p.id]);
          for (var i = 0; i < einzeln.length; i++) {
            final p = b.besetzt[i];
            final d = einzeln[i];
            expect(d.name, '${p.platz <= 10 ? '10-rollenheft' : '12-zusatzheft'}-${dateiWort(p.name)}.pdf');
            expect(d.name, isNot(startsWith('90')));
            final pdf = einzelPdfs[i];
            expect(pdf.formate, everyElement('hoch'), reason: d.name);
            expect(pdf.text, contains(p.name), reason: d.name);
            // Letzte Seite: die Abbildung der eigenen Aktionskarte (MECH 10.3).
            expect(kammerFlach(pdf.seitenText.last), contains(kammerFlach(k.klartext(k.rolle(p).aktionskarte.name))), reason: d.name);
          }
          expect({for (final d in einzeln) d.name}, hasLength(einzeln.length));
          expect([for (final d in einzeln) d.name], everyElement(isNot(anyOf(dateinamen.last, k.uiGemeinsam('datei.alles')))));
          for (final p in k.fall.plaetze.where((p) => !b.istBesetzt(p.id))) {
            expect(() => kammerEinzeldatei(k, p), throwsArgumentError, reason: p.id);
          }
        });

        test('kein Text näher als ${KammerSatz.druckRand ~/ KammerSatz.mm} mm an der Papierkante', () async {
          // Das pdf-Paket bricht Zeilen nach der Tintenbreite um; pdftotext zählt die volle Dickte
          // des letzten Zeichens mit (bis etwa 1,3 pt über den Satz hinaus, ohne Tinte): 0,5 mm Toleranz.
          final abstaende = await Future.wait([for (final d in dateien) kammerRandAbstand(d.bytes)]);
          for (var i = 0; i < dateien.length; i++) {
            final a = abstaende[i];
            if (a == null) continue;
            expect(a.abstand, greaterThanOrEqualTo(KammerSatz.druckRand - 0.5 * KammerSatz.mm),
                reason: '${dateien[i].name} Seite ${a.seite}: „${a.wort}“ ${(a.abstand / KammerSatz.mm).toStringAsFixed(1)} mm');
          }
        });

        test('bytegleich bei zweimaligem Setzen (festeBytes)', () async {
          final k2 = kammerKontext(personen);
          final zweite = await kammerTeilDateien(k2);
          for (var i = 0; i < dateien.length; i++) {
            expect(zweite[i].bytes, dateien[i].bytes, reason: dateien[i].name);
          }
          expect((await kammerAlles(k2)).bytes, alles.bytes);
          final p = k2.besetzung.besetzt.last;
          expect((await kammerEinzeldatei(k2, p)).bytes, einzeln.last.bytes);
        });
      }
    });
  }

}
