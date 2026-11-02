// Teil 11 (versiegelte Fassungen) des Kammerspiels (RK 7.1–7.7, MECH 10.1, 10.4, 10.5, E9): bei jeder
// Personenzahl 16 Seiten A4 hoch, je Fassung vier mit eigener Seitenzählung in der Reihenfolge WW4, JM3,
// RN7, YW4. Seite 1 ist die Außenseite: im oberen Drittel mittig nur der Code und der Hinweis (RK 7.2),
// das mittlere Drittel leer, im unteren Drittel die Anleitung zum Verschließen; kein Kopf, kein Fuß.
// Seiten 2 bis 4 tragen die Abschnitte der Bibel in ihrer Reihenfolge. Gleiche Gestalt (E9): je Seite
// dieselbe Schriftgröße und jede Überschrift auf derselben Höhe in allen vier Fassungen; Zeitleiste und Listen
// in allen vier mit denselben Abständen (gestreckt wäre die Fassung mit mehr Text dichter); nichts unter
// 9 pt. Längen nach RK 7.7 an den gedruckten Seiten: jeder Teil höchstens zehn Prozent vom Mittel der
// vier. Platzhalter je Besetzung: fehlende Rollen stehen nicht im Text, besetzte mit Namen. Nur RN7
// enthält die Tat. Dazu Druckrand, Bytegleichheit und Rot-Proben (Überlauf, Längenprüfung).
//
// Personenzahlen: alle von 6 bis 20 (Teil 11 ist klein; die Platzhalter ändern die Längen je Besetzung).
// Die PDFs prüfen pdfinfo und pdftotext (-layout für Text und Längen, -bbox-layout für Lage und Größe).
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:mordakte_core/kammer_io.dart' show leseKammerDateien;
import 'package:mordakte_core/party_druck.dart';
import 'package:test/test.dart';

import '../kanon_hilfe.dart' show repoWurzel;
import 'kammer_druck_hilfe.dart';

/// Seiten von Teil 11 bei 6, 12 und 20 Personen (MECH 10.1): immer 16.
const mech101 = {6: 16, 12: 16, 20: 16};

/// Seitenhöhe und -breite A4 in pt.
const _hoehe = 841.89, _breite = 595.28;

/// Wortboxen sind so hoch wie die Schrift mal (Oberlänge + Unterlänge) von Inter.
const _interHoehe = 1.209;

/// Eine Textzeile aus `pdftotext -bbox-layout`: Text, Lage und die Höhen ihrer Wörter.
typedef Zeile = ({String text, double x0, double y0, double x1, double y1, List<double> hoehen});

/// Zeilen je Seite.
Future<List<List<Zeile>>> zeilenJeSeite(Uint8List bytes) async {
  final dir = Directory.systemTemp.createTempSync('kammer_t11');
  try {
    final f = File('${dir.path}/satz.pdf')..writeAsBytesSync(bytes);
    final xml = (await Process.run('pdftotext', ['-bbox-layout', f.path, '-'])).stdout as String;
    final zahl = RegExp(r'xMin="([\d.]+)" yMin="([\d.]+)" xMax="([\d.]+)" yMax="([\d.]+)"');
    final wort = RegExp(r'<word xMin="[\d.]+" yMin="([\d.]+)" xMax="[\d.]+" yMax="([\d.]+)">([^<]*)</word>');
    return [
      for (final seite in xml.split('<page ').skip(1))
        [
          for (final z in seite.split('<line ').skip(1))
            () {
              final m = zahl.firstMatch(z)!;
              final w = wort.allMatches(z.split('</line>').first).toList();
              return (
                text: _unescape(w.map((x) => x.group(3)!).join(' ')),
                x0: double.parse(m.group(1)!),
                y0: double.parse(m.group(2)!),
                x1: double.parse(m.group(3)!),
                y1: double.parse(m.group(4)!),
                hoehen: [for (final x in w) double.parse(x.group(2)!) - double.parse(x.group(1)!)],
              );
            }(),
        ],
    ];
  } finally {
    dir.deleteSync(recursive: true);
  }
}

String _unescape(String s) => s.replaceAll('&amp;', '&').replaceAll('&lt;', '<').replaceAll('&gt;', '>').replaceAll('&quot;', '"').replaceAll('&apos;', "'");

/// Wörter zum Zählen (RK 7.7): Folgen mit Buchstabe oder Ziffer, ohne Listennummern „1.“ … „5.“.
int woerter(String s) => s
    .split(RegExp(r'\s+'))
    .where((w) => RegExp(r'[\p{L}\p{N}]', unicode: true).hasMatch(w) && !RegExp(r'^\d+\.$').hasMatch(w))
    .length;

/// Die gezählten Teile einer Fassung (RK 7.7, RK 7.1), in dieser Reihenfolge.
const teile = ['ziel', 'zeitleiste', 'wasNurDuWeisst', 'heftUndWahrheit', 'wennEsEngWird', 'stufe3', 'gesamt'];

/// Wörter je Teil der Fassung [f] (0 bis 3) aus dem gedruckten Text ([pdf], pdftotext -layout): zwischen
/// den Überschriften aus ui/11.json, ohne Kopf, Fuß, Tabellenkopf, Bedingung, Marke und „Danach …“.
Map<String, int> laengen(KammerKontext k, KammerPdf pdf, int f) {
  String u(String s) => kammerFlach(k.klartext(k.ui('11', s)));
  final fuss = kammerFlach(k.klartext(k.uiGemeinsam('fuss.code', {'code': k.fallCode})));
  // Text der Seite s (1 bis 4) zwischen den Überschriften von und bis (null: bis zum Fuß).
  String zwischen(int s, String von, String? bis) {
    final zeilen = pdf.seitenText[4 * f + s - 1].split('\n').map(kammerFlach).toList();
    final a = zeilen.indexOf(u(von));
    final e = bis == null ? zeilen.indexWhere((z) => z.startsWith(fuss), a) : zeilen.indexOf(u(bis));
    expect(a, greaterThanOrEqualTo(0), reason: 'Fassung ${f + 1}: $von');
    expect(e, greaterThan(a), reason: 'Fassung ${f + 1}: $von … $bis');
    return zeilen.sublist(a + 1, e).join(' ');
  }

  final tabellenkopf = woerter('${u('zeitleiste.zeit')} ${u('zeitleiste.text')}');
  final festeStufe3 = woerter('${u('stufe3.bedingung')} ${k.klartext(k.uiGemeinsam('vorlesen'))} ${u('stufe3.danach')}');
  final l = {
    'ziel': woerter(zwischen(2, 'deinZiel', 'wasWirklichGeschah')),
    'zeitleiste': woerter(zwischen(2, 'wasWirklichGeschah', null)) - tabellenkopf,
    'wasNurDuWeisst': woerter(zwischen(3, 'wasNurDuWeisst', 'heftUndWahrheit')),
    'heftUndWahrheit': woerter(zwischen(3, 'heftUndWahrheit', 'wennEsEngWird')),
    'wennEsEngWird': woerter(zwischen(3, 'wennEsEngWird', 'stufe3')),
    'stufe3': woerter(zwischen(3, 'stufe3', null)) - festeStufe3,
  };
  return {...l, 'gesamt': l.values.fold(0, (a, b) => a + b)};
}

/// Größte Abweichung vom Mittel der vier (Anteil, mit Vorzeichen) und ihre Fassung.
({double abweichung, int fassung}) groessteAbweichung(List<int> werte) {
  final mittel = werte.fold(0, (a, b) => a + b) / werte.length;
  var beste = (abweichung: 0.0, fassung: 0);
  for (var i = 0; i < werte.length; i++) {
    final a = (werte[i] - mittel) / mittel;
    if (a.abs() > beste.abweichung.abs()) beste = (abweichung: a, fassung: i);
  }
  return beste;
}

void main() {
  for (var personen = 6; personen <= 20; personen++) {
    group('$personen Personen', () {
      late KammerKontext k;
      late DruckDatei datei;
      late KammerPdf pdf;
      late List<List<Zeile>> zeilen;
      late List<String> codes;

      String u(String s) => kammerFlach(k.klartext(k.ui('11', s)));

      setUpAll(() async {
        k = kammerKontext(personen);
        datei = await kammerTeilDatei(k, kammerTeil(k, '11'));
        pdf = kammerPdf(datei.bytes);
        zeilen = await zeilenJeSeite(datei.bytes);
        codes = [for (final p in k.besetzung.verdaechtige) k.rolle(p).fassung!.code];
      });

      test('16 Seiten A4 hoch (MECH 10.1), Datei und Fassungen in der Reihenfolge WW4, JM3, RN7, YW4', () {
        expect(datei.name, '11-fassungen.pdf');
        expect(pdf.seiten, 16);
        if (mech101[personen] case final n?) expect(pdf.seiten, n);
        expect(pdf.formate, everyElement('hoch'));
        expect(codes, k.fall.fassungsCodes);
        expect(codes, ['WW4', 'JM3', 'RN7', 'YW4']);
      });

      test('Seiten 2 bis 4 jeder Fassung: Kopf mit Code, Fuß „Seite x von 4“', () {
        final fuss = RegExp(RegExp.escape(kammerFlach(k.uiGemeinsam('fuss.seite', {'seite': '#S#', 'seiten': '#N#'})))
            .replaceAll('#S#', r'(\d+)')
            .replaceAll('#N#', r'(\d+)'));
        final kopf = kammerFlach(k.kopfText(k.teilTitel('11')));
        for (var f = 0; f < 4; f++) {
          for (var s = 2; s <= 4; s++) {
            final text = pdf.seitenText[4 * f + s - 1];
            final erste = kammerFlach(text.split('\n').firstWhere((z) => z.trim().isNotEmpty));
            expect(erste, '$kopf ${codes[f]}', reason: '${codes[f]} Seite $s');
            final m = fuss.firstMatch(kammerFlach(text));
            expect(m, isNotNull, reason: '${codes[f]} Seite $s');
            expect((int.parse(m!.group(1)!), int.parse(m.group(2)!)), (s, 4), reason: '${codes[f]} Seite $s');
          }
        }
      });

      test('Außenseite (RK 7.2): oben mittig nur Code und Hinweis, Mitte leer, unten die Anleitung, kein Kopf und Fuß', () {
        final hinweis = u('aussen.hinweis');
        expect(hinweis, 'Versiegelt. Erst öffnen, wenn der Erzähler es sagt.');
        const drittel = _hoehe / 3;
        // Die vier Schritte nummeriert (1. bis 4.).
        final anleitung = kammerFlach([u('verschliessen.titel'), for (var n = 1; n <= 4; n++) '$n. ${u('verschliessen.$n')}'].join(' '));
        for (var f = 0; f < 4; f++) {
          final z = zeilen[4 * f];
          final oben = z.where((l) => l.y1 < drittel).toList();
          final mitte = z.where((l) => l.y0 < 2 * drittel && l.y1 > drittel).toList();
          final unten = z.where((l) => l.y0 > 2 * drittel).toList();
          expect(oben.length + mitte.length + unten.length, z.length, reason: '${codes[f]}: Zeile über einem Falz');
          expect(kammerFlach(oben.map((l) => l.text).join(' ')), '${codes[f]} $hinweis', reason: codes[f]);
          expect(mitte, isEmpty, reason: '${codes[f]}: das mittlere Drittel liegt gefaltet außen');
          // Code und Hinweis waagrecht mittig, der Block senkrecht in der Mitte des oberen Drittels.
          for (final l in oben) {
            expect((l.x0 + l.x1) / 2, closeTo(_breite / 2, 3), reason: '${codes[f]}: „${l.text}“');
          }
          final blockMitte = (oben.first.y0 + oben.last.y1) / 2;
          expect(blockMitte, closeTo(drittel / 2, 12), reason: codes[f]);
          expect(oben.first.hoehen.first / _interHoehe, greaterThanOrEqualTo(40), reason: '${codes[f]}: Code groß');
          expect(kammerFlach(unten.map((l) => l.text).join(' ')), anleitung, reason: codes[f]);
          // Kein Kopf, kein Fuß, kein Teiltitel.
          final alles = kammerFlach(pdf.seitenText[4 * f]);
          expect(alles, isNot(contains(kammerFlach(k.teilTitel('11')))), reason: codes[f]);
          expect(alles, isNot(contains(kammerFlach(k.uiGemeinsam('fuss.code', {'code': k.fallCode})))), reason: codes[f]);
        }
      });

      test('Abschnitte in Bibel-Reihenfolge auf den Seiten der Bibel (RK 7.1, MECH 10.4)', () {
        final plan = {
          2: ['deinZiel', 'wasWirklichGeschah'].map(u).toList(),
          3: ['wasNurDuWeisst', 'heftUndWahrheit', 'wennEsEngWird', 'stufe3'].map(u).toList(),
          4: [kammerFlach(k.klartext(k.uiGemeinsam('notizen')))],
        };
        expect(plan[4], ['Notizen']);
        expect(u('stufe3.bedingung'), 'Nennt der Detektiv bei der Anklage dich, stehst du auf und liest diesen Text laut vor. Wirst du nicht angeklagt, liest du ihn nicht vor. Den Rest erzählt das Auflösungsheft.');
        expect(u('stufe3.danach'), 'Danach stellst du deine Marker dahin, wo du wirklich warst.');
        for (var f = 0; f < 4; f++) {
          for (final e in plan.entries) {
            final titel = [for (final l in zeilen[4 * f + e.key - 1]) kammerFlach(l.text)].where(e.value.contains).toList();
            expect(titel, e.value, reason: '${codes[f]} Seite ${e.key}');
          }
          // Die Bedingung, der Vorlesetext und „Danach …“ in dieser Reihenfolge unter Stufe 3.
          final s3 = kammerFlach(pdf.seitenText[4 * f + 2]);
          final r = k.rolle(k.besetzung.verdaechtige[f]).fassung!;
          final i = [u('stufe3'), u('stufe3.bedingung'), kammerFlach(k.klartext(r.stufe3)), u('stufe3.danach')].map(s3.indexOf).toList();
          expect(i, everyElement(greaterThanOrEqualTo(0)), reason: codes[f]);
          expect(i, orderedEquals([...i]..sort()), reason: codes[f]);
          // Die Zeitleiste hat 16 oder 17 Zeilen (RK 7.1), „Was nur du weißt“ und „Wenn es eng wird“ je fünf.
          expect(r.zeitleiste.length, inInclusiveRange(16, 17), reason: codes[f]);
          expect(k.texte(r.wasNurDuWeisst), hasLength(5), reason: codes[f]);
          expect(k.texte(r.wennEsEngWird), hasLength(5), reason: codes[f]);
        }
      });

      test('E9: je Seite dieselbe Schrift und jede Überschrift auf derselben Höhe in allen vier Fassungen', () {
        double haeufigste(List<Zeile> seite) {
          final n = <double, int>{};
          for (final l in seite.where((l) => l.y0 > 60 && l.y1 < 785)) {
            for (final h in l.hoehen) {
              final g = (h / _interHoehe * 4).round() / 4;
              n[g] = (n[g] ?? 0) + 1;
            }
          }
          return (n.entries.toList()..sort((a, b) => b.value - a.value)).first.key;
        }

        final feste = [
          ...['deinZiel', 'wasWirklichGeschah', 'wasNurDuWeisst', 'heftUndWahrheit', 'wennEsEngWird', 'stufe3', 'stufe3.danach'].map(u),
          kammerFlach(k.klartext(k.uiGemeinsam('notizen'))),
        ];
        for (var s = 1; s <= 4; s++) {
          final groessen = {for (var f = 0; f < 4; f++) haeufigste(zeilen[4 * f + s - 1])};
          expect(groessen, hasLength(1), reason: 'Seite $s: $groessen');
          if (s == 2 || s == 3) expect(groessen.single, greaterThanOrEqualTo(9.5), reason: 'Seite $s');
          // Jede feste Zeile (Überschriften, „Danach …“) steht in allen vier auf derselben Höhe.
          for (final t in feste) {
            final y = [
              for (var f = 0; f < 4; f++)
                for (final l in zeilen[4 * f + s - 1])
                  if (kammerFlach(l.text) == t) l.y0,
            ];
            if (y.isEmpty) continue;
            expect(y, hasLength(4), reason: 'Seite $s: „$t“');
            expect(y.reduce((a, b) => a > b ? a : b) - y.reduce((a, b) => a < b ? a : b), lessThan(0.5), reason: 'Seite $s: „$t“ $y');
          }
        }
      });

      test('gleiche Dichte (RK 7.1): Zeitleiste und Listen in allen vier mit denselben Abständen, der Rest bleibt darunter frei', () {
        // Abstände von Zeile zu Zeile (Oberkante zu Oberkante) unter der Überschrift [von] bis zur Überschrift [bis]
        // (null: bis zum Fuß). Was auf einer Höhe steht (Zeit und Text, Nummer und Eintrag), ist eine Zeile.
        List<double> abstaende(List<Zeile> seite, String von, String? bis) {
          final oben = seite.firstWhere((l) => kammerFlach(l.text) == von).y1;
          final unten = bis == null ? 785.0 : seite.firstWhere((l) => kammerFlach(l.text) == bis).y0;
          final ys = [for (final l in seite) if (l.y0 > oben && l.y1 < unten) l.y0]..sort();
          final hoehen = <double>[];
          for (final y in ys) {
            if (hoehen.isEmpty || y - hoehen.last > 0.5) hoehen.add(y);
          }
          return [for (var i = 1; i < hoehen.length; i++) hoehen[i] - hoehen[i - 1]];
        }

        for (final (s, von, bis) in [(2, 'wasWirklichGeschah', null), (3, 'wasNurDuWeisst', 'heftUndWahrheit'), (3, 'wennEsEngWird', 'stufe3')]) {
          final alle = [for (var f = 0; f < 4; f++) ...abstaende(zeilen[4 * f + s - 1], u(von), bis == null ? null : u(bis))]..sort();
          // Höchstens zwei Abstände über alle vier: innerhalb eines Eintrags (einer Tabellenzeile) und von Eintrag zu
          // Eintrag. Eine gestreckte Liste brächte je Fassung einen eigenen Abstand zwischen den Einträgen.
          final gruppen = <double>[];
          for (final a in alle) {
            if (gruppen.isEmpty || a - gruppen.last > 0.3) gruppen.add(a);
          }
          expect(alle, isNotEmpty, reason: 'Seite $s: „${u(von)}“');
          expect(gruppen.length, lessThanOrEqualTo(2), reason: 'Seite $s: „${u(von)}“ ${[for (final g in gruppen) g.toStringAsFixed(2)]}');
        }
      });

      test('keine Schrift unter 9 pt (außer Kopf und Fuß)', () {
        for (var s = 0; s < zeilen.length; s++) {
          for (final l in zeilen[s].where((l) => l.y0 > 60 && l.y1 < 785)) {
            for (final h in l.hoehen) {
              expect(h / _interHoehe, greaterThanOrEqualTo(KammerSatz.kleinsteGroesse - 0.05), reason: 'Seite ${s + 1}: „${l.text}“');
            }
          }
        }
      });

      test('Längen nach RK 7.7 an den gedruckten Seiten: jeder Teil höchstens zehn Prozent vom Mittel', () {
        final l = [for (var f = 0; f < 4; f++) laengen(k, pdf, f)];
        printOnFailure([for (final t in teile) '$t: ${[for (final x in l) x[t]]}'].join('\n'));
        for (final t in teile) {
          final a = groessteAbweichung([for (final x in l) x[t]!]);
          expect(a.abweichung.abs(), lessThanOrEqualTo(0.10), reason: '$t: ${codes[a.fassung]} ${(100 * a.abweichung).toStringAsFixed(1)} %');
        }
      });

      test('Platzhalter je Besetzung: fehlende Rollen fehlen, besetzte stehen mit Namen', () {
        final text = pdf.text;
        expect(text, isNot(contains('{')));
        expect(text, isNot(contains('}')));
        expect(text, isNot(contains('OFFEN')));
        final genannt = <String>{
          for (final p in k.besetzung.verdaechtige)
            for (final m in RegExp(r'\{(?:rolle|wenn):([a-z,]+)\|').allMatches(jsonEncode(_fassungTexte(k.rolle(p).fassung!)))) ...m.group(1)!.split(','),
        };
        expect(genannt, containsAll(['marek', 'lejla', 'joanna', 'emine', 'zeynep', 'tim']));
        for (final p in k.fall.plaetze.where((p) => p.platz > 4)) {
          final steht = RegExp('\\b${p.name}s?\\b').hasMatch(text);
          if (!k.besetzung.istBesetzt(p.id)) {
            expect(steht, isFalse, reason: '${p.name} fehlt heute');
          } else if (genannt.contains(p.id)) {
            expect(steht, isTrue, reason: '${p.name} spielt heute');
          }
        }
      });

      test('nur RN7 enthält die Tat (E9, RK 7.3–7.6)', () {
        final taeter = k.inhalt.platzVon(k.fall.taeter);
        expect(k.rolle(taeter).fassung!.code, 'RN7');
        for (var f = 0; f < 4; f++) {
          final innen = kammerFlach(pdf.seitenText.sublist(4 * f + 1, 4 * f + 4).join(' '));
          final tat = codes[f] == 'RN7';
          expect(innen.contains('dumpfer Schlag'), tat, reason: codes[f]);
          expect(innen.contains('Du warst es nicht.'), !tat, reason: codes[f]);
          expect(innen.contains('Du warst es.'), tat, reason: codes[f]);
        }
      });

      if (personen == 6 || personen == 13 || personen == 20) {
        test('Druckrand: kein Text näher als 5 mm an der Papierkante', () async {
          final a = await kammerRandAbstand(datei.bytes);
          expect(a, isNotNull);
          expect(a!.abstand, greaterThanOrEqualTo(KammerSatz.druckRand - 0.5 * KammerSatz.mm), reason: 'Seite ${a.seite}: „${a.wort}“');
        });

        test('gleiche Eingaben, gleiche Bytes; der Detektiv ändert nichts', () async {
          final k2 = kammerKontext(personen);
          expect((await kammerTeilDatei(k2, kammerTeil(k2, '11'))).bytes, datei.bytes);
          final km = kammerKontext(personen, detektiv: 'm');
          expect((await kammerTeilDatei(km, kammerTeil(km, '11'))).bytes, datei.bytes);
        });
      }
    });
  }

  group('Rot-Proben', () {
    /// Kontext für [personen] mit dem echten Inhalt, nach [aendern] (JSON je Datei).
    KammerKontext mit(int personen, void Function(Map<String, Object?> j) aendern) {
      final j = <String, Object?>{for (final e in leseKammerDateien(repoWurzel).entries) e.key: jsonDecode(e.value)};
      aendern(j);
      return KammerKontext(KammerInhalt.ausJson(j), personen: personen, stil: kammerStil);
    }

    Map<String, Object?> fassung(Map<String, Object?> j, String id) =>
        (j[j.keys.singleWhere((d) => d.startsWith('rollen/') && d.endsWith('-$id.json'))]! as Map<String, Object?>)['fassung']! as Map<String, Object?>;

    test('ein zu langer Sobald-Satz: Überlauf auf Seite 3 von YW4, nie still', () {
      final k = mit(10, (j) {
        final eng = (fassung(j, 'can')['wennEsEngWird']! as List).cast<String>();
        eng[0] = List.filled(12, eng[0]).join(' ');
      });
      expect(
        () => kammerFassungen(kammerStil.neuesDokument('probe'), k),
        throwsA(isA<KammerUeberlauf>()
            .having((e) => e.teil, 'teil', '11')
            .having((e) => e.seite, 'seite', 3)
            .having((e) => '$e', 'meldung', allOf(contains('Teil 11'), contains('YW4'), contains('stufe3'), contains('9.0pt')))),
      );
    });

    test('ein zu langer Hinweis auf der Außenseite: Überlauf, nie still', () {
      final k = mit(10, (j) {
        final ui = j['ui/11.json']! as Map<String, Object?>;
        ui['aussen.hinweis'] = List.filled(30, ui['aussen.hinweis']).join(' ');
      });
      expect(
        () => kammerFassungen(kammerStil.neuesDokument('probe'), k),
        throwsA(isA<KammerUeberlauf>().having((e) => e.teil, 'teil', '11').having((e) => '$e', 'meldung', contains('aussen'))),
      );
    });

    test('die Längenprüfung erkennt einen doppelt so langen Teil', () async {
      final k = mit(20, (j) {
        final f = fassung(j, 'fatma');
        f['heftUndWahrheit'] = '${f['heftUndWahrheit']} ${f['heftUndWahrheit']}';
      });
      final pdf = kammerPdf((await kammerTeilDatei(k, kammerTeil(k, '11'))).bytes);
      final l = [for (var f = 0; f < 4; f++) laengen(k, pdf, f)];
      final a = groessteAbweichung([for (final x in l) x['heftUndWahrheit']!]);
      expect(a.fassung, 1);
      expect(a.abweichung, greaterThan(0.10));
      // Die Gestalt bleibt trotzdem gleich: Die Überschrift danach steht in allen vier auf derselben Höhe.
      final zeilen = await zeilenJeSeite((await kammerTeilDatei(k, kammerTeil(k, '11'))).bytes);
      final titel = kammerFlach(k.klartext(k.ui('11', 'wennEsEngWird')));
      final y = [for (var f = 0; f < 4; f++) zeilen[4 * f + 2].firstWhere((z) => kammerFlach(z.text) == titel).y0];
      expect(y.toSet().length, 1, reason: '$y');
    });
  });
}

/// Die Texte einer Fassung (für die Suche nach Platzhaltern).
List<String> _fassungTexte(KammerFassung f) => [
      f.ziel,
      for (final z in f.zeitleiste) ...[z.zeit, z.text],
      ...f.wasNurDuWeisst,
      f.heftUndWahrheit,
      ...f.wennEsEngWird,
      f.stufe3,
    ];
