// Dateien des Kammerspiel-Drucks (ARCHITEKTUR A2, MECH 10.1, 10.3): Für jede
// Personenzahl 6 bis 20 entstehen die acht Teile in fester Reihenfolge mit den
// Dateinamen aus ui/*.json, alle Seiten A4 (Lageplan-Blätter und Karten quer),
// „Alles in einer Datei“ mit der Summe der Seiten und je besetzter Rolle eine
// Einzeldatei mit dem Rollennamen, nie Teil 90. Gleiche Eingaben ergeben gleiche
// Bytes. Dazu Rot-Proben des Überlaufschutzes und der Seitenzählung (satz.dart).
//
// Personenzahlen: alle fünfzehn für die Teile und die Gesamtdatei. Jede Zahl
// besetzt eine andere Rolle, und jede Stufe (Abwesenheitsblatt bis 11, Verhörstuhl
// leise ab 12, Zusatzrollen und Solo ab 13, Gegenüberstellung ab 14) ändert Teile
// und Seitenzahlen. Die Einzeldateien (je Rolle ein eigener Satz, zusammen 165 bei
// allen Zahlen) und die Bytegleichheit (doppelter Satz) prüfen wir an den Grenzen
// 6, 11, 12, 13, 14 und 20: Dort kommt jede Rolle mindestens einmal vor (bei 20 alle
// achtzehn, bei 13 Sibel allein), und jeder Zweig der Teile wird einmal gesetzt; die
// Bytegleichheit hängt nur am Speichern (festeBytes), nicht an der Besetzung. Die
// PDFs prüfen pdfinfo und pdftotext nebeneinander; so bleibt der Test unter einer Minute.
import 'dart:convert';

import 'package:mordakte_core/kammer_io.dart' show leseKammerDateien;
import 'package:mordakte_core/party_druck.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:test/test.dart';

import '../kanon_hilfe.dart' show repoWurzel;
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

void main() {
  for (var personen = 6; personen <= 20; personen++) {
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

  group('Kontext', () {
    test('Personen außerhalb 6 bis 20: RangeError; Detektiv nur w oder m', () {
      expect(() => kammerKontext(5), throwsRangeError);
      expect(() => kammerKontext(21), throwsRangeError);
      expect(() => kammerKontext(10, detektiv: 'x'), throwsArgumentError);
      expect(kammerKontext(10, detektiv: 'm').detektivWeiblich, isFalse);
      expect(kammerKontext(10).detektivWeiblich, isTrue);
    });

    test('ui: fehlender Schlüssel oder Wert wirft mit Datei und Schlüssel', () {
      final k = kammerKontext(10);
      expect(() => k.ui('00', 'gibtEsNicht'), throwsA(isA<ArgumentError>().having((e) => '$e', 'text', contains('ui/00.json'))));
      expect(() => k.ui('20', 'indiz.aussen'), throwsA(isA<ArgumentError>().having((e) => '$e', 'text', contains('indiz.aussen'))));
      expect(k.ui('20', 'indiz.aussen', {'code': 'AD3', 'runde': '1'}), contains('AD3'));
      expect(k.uiGemeinsam('detektiv'), isNot(equals(kammerKontext(10, detektiv: 'm').uiGemeinsam('detektiv'))));
    });

    test('Spielernamen nur für die App: je Kanon-Figur, sonst der Rollenname', () {
      final lejla = kammerInhalt.platzVon('lejla');
      final k = KammerKontext(kammerInhalt, personen: 10, stil: kammerStil, spieler: {lejla.kanonFigur: 'Ayla'});
      expect(k.sendenAn(lejla), 'Ayla');
      expect(k.sendenAn(kammerInhalt.platzVon('olli')), 'Olli');
    });
  });

  group('Überlaufschutz (satz.dart)', () {
    final k = kammerKontext(10);
    Matcher ueberlauf(String teil, int seite, [String? wo]) => throwsA(isA<KammerUeberlauf>()
        .having((e) => e.teil, 'teil', teil)
        .having((e) => e.seite, 'seite', seite)
        .having((e) => '$e', 'meldung', allOf([contains('Teil $teil'), contains('Seite $seite'), if (wo != null) contains(wo)])));
    pw.Document doc() => kammerStil.neuesDokument('probe');

    test('feste Seite zu hoch: Ausnahme mit Teil und Seite', () {
      expect(() => kammerTeilSetzen(doc(), k, '00', (s) => s.seite([pw.SizedBox(height: 2000)], wo: 'probe')), ueberlauf('00', 1, 'probe'));
      expect(
        () => kammerTeilSetzen(doc(), k, '10', (s) {
          s.seite([pw.SizedBox(height: 100)]);
          s.seite([pw.SizedBox(height: 100)]);
          s.seite([pw.SizedBox(height: 900)]);
        }, bereich: 'Lejla'),
        ueberlauf('10', 3, 'Lejla'),
      );
    });

    test('fließend: mehr Seiten als erlaubt und unteilbar zu hoch', () {
      expect(() => kammerTeilSetzen(doc(), k, '00', (s) => s.fliessend([for (var i = 0; i < 6; i++) pw.SizedBox(height: 500)], maxSeiten: 3)), ueberlauf('00', 6));
      expect(() => kammerTeilSetzen(doc(), k, '01', (s) => s.fliessend([pw.Container(height: 2000)])), throwsA(isA<KammerUeberlauf>().having((e) => e.teil, 'teil', '01')));
    });

    test('Rasterzelle zu hoch, Raster größer als die Seite, keine passende Schriftgröße', () {
      expect(
        () => kammerTeilSetzen(doc(), k, '20', (s) => s.a7([KammerZelle(pw.SizedBox(height: 400), wo: 'XY1')])),
        ueberlauf('20', 1, 'XY1'),
      );
      expect(() => kammerTeilSetzen(doc(), k, '02', (s) => s.raster([KammerZelle(pw.SizedBox())], breite: 100, hoehe: 100, spalten: 9, reihen: 1)), throwsA(isA<KammerUeberlauf>()));
      expect(
        () => kammerTeilSetzen(doc(), k, '90', (s) => s.passendeGroesse((g) => pw.SizedBox(height: g * 100), breite: 100, hoehe: 100, wo: 'probe')),
        ueberlauf('90', 1, 'probe'),
      );
    });

    test('Kasten fester Größe: zu hoher Inhalt ist ein Überlauf, passender bleibt', () {
      expect(
        () => kammerTeilSetzen(doc(), k, '02', (s) {
          s.fest(pw.SizedBox(height: 40), breite: 100, hoehe: 50, innen: const pw.EdgeInsets.all(4), wo: 'ok');
          s.fest(pw.SizedBox(height: 60), breite: 100, hoehe: 50, wo: 'etikett');
        }),
        ueberlauf('02', 1, 'etikett'),
      );
    });

    test('Druckrand: Text in Rasterzellen hält 5 mm Abstand zur Papierkante', () {
      expect(
        () => kammerTeilSetzen(doc(), k, '20', (s) => s.a7([KammerZelle(pw.SizedBox())], innen: const pw.EdgeInsets.all(6), wo: 'aktion')),
        throwsA(isA<KammerUeberlauf>().having((e) => '$e', 'meldung', allOf(contains('Teil 20'), contains('aktion'), contains('Papierkante')))),
      );
      expect(
        () => kammerTeilSetzen(doc(), k, '02', (s) => s.raster([KammerZelle(pw.SizedBox())], breite: 100, hoehe: 100, spalten: 2, reihen: 2, ueber: pw.SizedBox(height: 10))),
        throwsA(isA<KammerUeberlauf>().having((e) => '$e', 'meldung', contains('Papierkante'))),
      );
      // Z-Falz: An der Papierkante wächst der Innenabstand, in der Mitte nicht; die Textbreite ist für beide Spalten gleich.
      const innen = pw.EdgeInsets.all(10);
      final links = KammerSatz.zFalzInnenFuer(innen, 0), rechts = KammerSatz.zFalzInnenFuer(innen, 1);
      expect(KammerSatz.zFalzAussenRand + links.left, closeTo(KammerSatz.druckRand, 0.01));
      expect(KammerSatz.zFalzAussenRand + rechts.right, closeTo(KammerSatz.druckRand, 0.01));
      expect((links.right, rechts.left), (10, 10));
      expect(KammerSatz.zFalzTextBreite(innen), closeTo(KammerSatz.a5Breite - links.horizontal, 0.01));
      expect(KammerSatz.zFalzInnenFuer(KammerSatz.zFalzInnen, 0).horizontal, KammerSatz.zFalzInnen.horizontal, reason: 'Vorgabe hält den Druckrand schon');
    });

    test('versiegelte Außenseite: der Inhalt bleibt über dem ersten Falz (ein Drittel des Blatts)', () {
      expect(
        () => kammerTeilSetzen(doc(), k, '90', (s) => s.versiegelt(code: 'AB1', hinweis: List.filled(14, 'Zeile').join('\n'))),
        ueberlauf('90', 1, 'AB1'),
      );
      kammerTeilSetzen(doc(), k, '11', (s) => s.versiegelt(code: 'AB1', hinweis: 'Zeile', titel: 'Titel'));
    });

    test('ein Teil ohne Seite ist ein Fehler; Seiten zählen je Teil', () {
      expect(() => kammerTeilSetzen(doc(), k, '00', (s) {}), throwsStateError);
      final d = doc();
      late KammerSeiten erster, zweiter;
      kammerTeilSetzen(d, k, '00', (s) {
        erster = s;
        s.seite([pw.SizedBox(height: 10)]);
        s.seite([pw.SizedBox(height: 10)]);
      });
      kammerTeilSetzen(d, k, '01', (s) {
        zweiter = s;
        s.seite([pw.SizedBox(height: 10)]);
      });
      expect(erster.gesetzt, 2);
      expect(zweiter.gesetzt, 1);
    });
  });

  group('Überlauf aus dem Inhalt: ein absichtlich zu langer Text bricht mit Teil und Stelle ab', () {
    /// Kontext für [personen] mit dem echten Inhalt, nach [aendern] (JSON je Datei).
    KammerKontext mit(int personen, void Function(Map<String, Object?> j) aendern) {
      final j = <String, Object?>{for (final e in leseKammerDateien(repoWurzel).entries) e.key: jsonDecode(e.value)};
      aendern(j);
      return KammerKontext(KammerInhalt.ausJson(j), personen: personen, stil: kammerStil);
    }

    Map<String, Object?> json(Map<String, Object?> j, String datei) => j[datei]! as Map<String, Object?>;
    String lang(Object? text, int mal) => List.filled(mal, text! as String).join(' ');
    Matcher ueberlaufIn(String teil, String wo) => throwsA(isA<KammerUeberlauf>()
        .having((e) => e.teil, 'teil', teil)
        .having((e) => e.seite, 'seite', greaterThan(0))
        .having((e) => '$e', 'meldung', allOf(contains('Teil $teil'), contains('Seite'), contains(wo))));
    pw.Document doc() => kammerStil.neuesDokument('probe');

    test('Indizkarte im Z-Falz (Teil 20)', () {
      final k = mit(10, (j) {
        final karte = (json(j, 'indizkarten.json')['karten']! as List).cast<Map<String, Object?>>().firstWhere((c) => c['code'] == 'FX3');
        karte['wasDuFindest'] = lang(karte['wasDuFindest'], 6);
      });
      expect(() => kammerKarten(doc(), k), ueberlaufIn('20', 'FX3'));
    });

    test('Aktionskarte A7 (Teil 20)', () {
      final k = mit(10, (j) {
        final a = json(j, 'rollen/01-ahmet.json')['aktionskarte']! as Map<String, Object?>;
        a['wirkung'] = lang(a['wirkung'], 8);
      });
      expect(() => kammerKarten(doc(), k), ueberlaufIn('20', 'aktionskarten'));
    });

    test('Etikett eines Zeugenstreifens (Teil 02, bisher still gekürzt)', () {
      final k = mit(6, (j) {
        final st = (json(j, 'abwesenheit.json')['streifen']! as List).cast<Map<String, Object?>>().first;
        st['etikett'] = lang(st['etikett'], 5);
      });
      expect(() => kammerTisch(doc(), k), ueberlaufIn('02', 'etikett'));
    });

    test('Zeitleiste einer Fassung (Teil 11)', () {
      final k = mit(10, (j) {
        final f = json(j, 'rollen/03-olli.json')['fassung']! as Map<String, Object?>;
        final z = (f['zeitleiste']! as List).cast<Map<String, Object?>>().first;
        z['text'] = lang(z['text'], 40);
      });
      expect(() => kammerFassungen(doc(), k), ueberlaufIn('11', 'zeitleiste'));
    });
  });
}
