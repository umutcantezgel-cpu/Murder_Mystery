// Dateien des Kammerspiel-Drucks (ARCHITEKTUR A2, MECH 10.1, 10.3): Für jede
// Personenzahl 6 bis 20 entstehen die acht Teile in fester Reihenfolge mit den
// Dateinamen aus ui/*.json, alle Seiten A4 (Lageplan-Blätter und Karten quer),
// „Alles in einer Datei“ mit der Summe der Seiten und je besetzter Rolle eine
// Einzeldatei mit dem Rollennamen, nie Teil 90. Gleiche Eingaben ergeben gleiche
// Bytes. Dazu Rot-Proben des Überlaufschutzes und der Seitenzählung (satz.dart).
// Die Prüfungen je Personenzahl stehen in dateien_satz.dart; diese Datei prüft 6 bis
// 13 Personen, dateien_14_20_test.dart die übrigen (zwei Testprozesse).
//
// Personenzahlen: alle fünfzehn für die Teile und die Gesamtdatei. Jede Zahl
// besetzt eine andere Rolle, und jede Stufe (Abwesenheitsblatt bis 11, Verhörstuhl
// leise ab 12, Zusatzrollen und Solo ab 13, Gegenüberstellung ab 14) ändert Teile
// und Seitenzahlen. Die Einzeldateien (je Rolle ein eigener Satz, zusammen 165 bei
// allen Zahlen) und die Bytegleichheit (doppelter Satz) prüfen wir an den Grenzen
// 6, 11, 12, 13, 14 und 20: Dort kommt jede Rolle mindestens einmal vor (bei 20 alle
// achtzehn, bei 13 Sibel allein), und jeder Zweig der Teile wird einmal gesetzt; die
// Bytegleichheit hängt nur am Speichern (festeBytes), nicht an der Besetzung. Die
// PDFs prüfen pdfinfo und pdftotext nebeneinander.
import 'dart:convert';

import 'package:mordakte_core/kammer_io.dart' show leseKammerDateien;
import 'package:mordakte_core/party_druck.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:test/test.dart';

import '../kanon_hilfe.dart' show repoWurzel;
import 'dateien_satz.dart';
import 'kammer_druck_hilfe.dart';

void main() {
  // 6 bis 13 Personen; 14 bis 20 in dateien_14_20_test.dart (Begründung in dateien_satz.dart).
  dateienJePersonen(6, 13);

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
