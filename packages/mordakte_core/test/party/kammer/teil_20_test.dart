// Teil 20 (Karten) des Kammerspiels (MECH 3, 4, 10.1; E8, E9, E12): alle Seiten
// A4 quer; Seiten = 10 Blätter Indizkarten + Geheimniskarten zwei je Blatt +
// Aktionskarten acht je Blatt (17 / 17 / 22 bei 6 / 12 / 20 Personen); die
// Indizkarten nach Code, dann Geheimnis- und Aktionskarten in Platzreihenfolge
// (besetzte Rollen und fehlende Zeugen 5–10, nie fehlende Zusatzrollen); die
// Außenseiten nur mit den erlaubten Texten (Code und Runde bzw. Name und Platz);
// im Z-Falz nichts von innen auf der Außenseite oder dem Deckfeld, der Text innen
// erst 5 mm unter dem Falz; jede Karte vollständig gesetzt; nichts unter 9 pt
// (FALL-BIBEL 19.2 Nr. 4, auch FX3); eine Schrift für alle Geheimniskarten und
// eine für alle Aktionskarten (E9); Druckrand 5 mm; die Abbildung der eigenen
// Aktionskarte in der Einzeldatei; gleiche Eingaben, gleiche Bytes; Rot-Probe:
// FX3 mit einem Satz mehr bricht ab, statt unter 9 pt zu gehen.
//
// Seitenzahlen für alle Personenzahlen 6 bis 20 (ein Satz kostet eine halbe
// Sekunde). Die übrigen Prüfungen bei 6 (alle sechs Zeugen fehlen, sechs Karten
// beim Detektiv), 10 (Vorgabe, Marek und Zeynep fehlen), 13 (Sibel allein, Damir
// fehlt, ungerade Zahl Geheimniskarten) und 20 (alle achtzehn). Text kommt aus
// pdftotext -raw (Karte für Karte in Satzreihenfolge), Lage und Größe aus
// pdftotext -bbox.
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:mordakte_core/kammer_io.dart' show leseKammerDateien;
import 'package:mordakte_core/party_druck.dart';
import 'package:test/test.dart';

import '../kanon_hilfe.dart' show repoWurzel;
import 'kammer_druck_hilfe.dart';

const genau = [6, 10, 13, 20];

/// Seiten von Teil 20 bei 6, 12 und 20 Personen (MECH 10.1).
const mech101 = {6: 17, 12: 17, 20: 22};

const mm = KammerSatz.mm;

/// Falze im Z-Falz (von oben): Feld 1 bis 70 mm, Feld 2 bis 140 mm, darunter das Deckfeld.
const falz1 = 70 * mm, falz2 = 140 * mm;

/// Wortboxen sind so hoch wie die Schrift mal (Oberlänge + Unterlänge) von Inter.
const interHoehe = 1.209;

typedef Wort = ({double x0, double y0, double x1, double y1, String wort});

/// Wortboxen je Seite (pdftotext -bbox) und die Seitenbreite.
Future<({List<List<Wort>> seiten, double breite})> woerter(Uint8List bytes) async {
  final dir = Directory.systemTemp.createTempSync('kammer_20');
  try {
    final f = File('${dir.path}/satz.pdf')..writeAsBytesSync(bytes);
    final xml = (await Process.run('pdftotext', ['-bbox', f.path, '-'])).stdout as String;
    final breite = double.parse(RegExp(r'<page width="([\d.]+)"').firstMatch(xml)!.group(1)!);
    return (
      breite: breite,
      seiten: [
        for (final seite in xml.split('<page ').skip(1))
          [
            for (final w in RegExp(r'<word xMin="([\d.]+)" yMin="([\d.]+)" xMax="([\d.]+)" yMax="([\d.]+)">([^<]*)<').allMatches(seite))
              (x0: double.parse(w.group(1)!), y0: double.parse(w.group(2)!), x1: double.parse(w.group(3)!), y1: double.parse(w.group(4)!), wort: w.group(5)!),
          ],
      ],
    );
  } finally {
    dir.deleteSync(recursive: true);
  }
}

/// Text je Seite in Satzreihenfolge (pdftotext -raw): Karte für Karte.
Future<List<String>> rohText(Uint8List bytes) async {
  final dir = Directory.systemTemp.createTempSync('kammer_20');
  try {
    final f = File('${dir.path}/satz.pdf')..writeAsBytesSync(bytes);
    final text = (await Process.run('pdftotext', ['-raw', f.path, '-'])).stdout as String;
    final seiten = text.split('\f');
    if (seiten.last.trim().isEmpty) seiten.removeLast();
    return seiten;
  } finally {
    dir.deleteSync(recursive: true);
  }
}

/// Zum Vergleichen: ohne Leerraum und Striche (pdftotext trennt an Zeilenenden).
String norm(String s) => s.replaceAll(RegExp(r'[\s\-–]'), '').replaceAll('☐', '□');

/// Schriftgröße eines Worts, auf Viertelpunkte gerundet.
double groesse(Wort w) => ((w.y1 - w.y0) / interHoehe * 4).round() / 4;

/// Häufigste Schriftgröße unter [ws].
double haeufigste(Iterable<Wort> ws) {
  final z = <double, int>{};
  for (final w in ws) {
    z[groesse(w)] = (z[groesse(w)] ?? 0) + 1;
  }
  return (z.entries.toList()..sort((a, b) => b.value != a.value ? b.value - a.value : a.key.compareTo(b.key))).first.key;
}

/// Die Seiten von Teil 20 für [b]: 10 + ⌈G/2⌉ + ⌈A/8⌉.
({int indiz, int geheimnis, int aktion}) seitenplan(KammerBesetzung b) =>
    (indiz: 10, geheimnis: (b.geheimniskarten.length / 2).ceil(), aktion: (b.aktionskarten.length / 8).ceil());

void main() {
  final saetze = <int, DruckDatei>{};
  final pdfs = <int, KammerPdf>{};

  setUpAll(() async {
    for (var p = 6; p <= 20; p++) {
      final k = kammerKontext(p);
      saetze[p] = await kammerTeilDatei(k, kammerTeil(k, '20'));
    }
    final alle = await kammerPdfs([for (var p = 6; p <= 20; p++) saetze[p]!.bytes]);
    for (var p = 6; p <= 20; p++) {
      pdfs[p] = alle[p - 6];
    }
  });

  test('Seitenzahlen nach MECH 10.1 bei 6 bis 20 Personen, alle Seiten A4 quer', () {
    for (var p = 6; p <= 20; p++) {
      final b = kammerKontext(p).besetzung;
      // Geheimnis- und Aktionskarten: besetzte Rollen und fehlende Zeugen, bei 6 bis 12 Personen immer zehn.
      expect(b.geheimniskarten.length, p <= 12 ? 10 : p - 2, reason: '$p Personen');
      expect(b.aktionskarten.length, b.geheimniskarten.length, reason: '$p Personen');
      final plan = seitenplan(b);
      expect(pdfs[p]!.seiten, plan.indiz + plan.geheimnis + plan.aktion, reason: '$p Personen');
      expect(pdfs[p]!.formate, everyElement('quer'), reason: '$p Personen');
      expect(saetze[p]!.name, '20-karten.pdf');
    }
    for (final e in mech101.entries) {
      expect(pdfs[e.key]!.seiten, e.value, reason: '${e.key} Personen (MECH 10.1)');
    }
  });

  for (final personen in genau) {
    group('$personen Personen', () {
      late KammerKontext k;
      late KammerBesetzung b;
      late List<String> roh;
      late List<List<Wort>> wo;
      late double seitenBreite;
      late List<KammerIndizkarte> indiz;
      late ({int indiz, int geheimnis, int aktion}) plan;

      setUpAll(() async {
        k = kammerKontext(personen);
        b = k.besetzung;
        final bytes = saetze[personen]!.bytes;
        roh = await rohText(bytes);
        final w = await woerter(bytes);
        (wo, seitenBreite) = (w.seiten, w.breite);
        indiz = [...k.inhalt.indizkarten.karten]..sort((a, c) => a.code.compareTo(c.code));
        plan = seitenplan(b);
      });

      String indizAussen(KammerIndizkarte c) => k.klartext(k.ui('20', 'indiz.aussen', {'code': c.code, 'runde': '${c.abRunde}'}));
      String geheimnisAussen(KammerPlatz p) =>
          k.klartext(k.ui('20', b.istBesetzt(p.id) ? 'geheimnis.vorne' : 'geheimnis.vorne.fehlt', {'name': p.name, 'platz': '${p.platz}'}));
      String aktionKopf(KammerPlatz p) => k.klartext(b.istBesetzt(p.id) ? k.ui('20', 'aktion.kopf', {'name': p.name}) : k.ui('20', 'aktion.kopf.detektiv'));

      /// Prüft, dass [erwartet] in dieser Reihenfolge in [text] vorkommen.
      void inReihenfolge(String text, List<String> erwartet, String wo) {
        var ab = 0;
        for (final e in erwartet) {
          final i = norm(text).indexOf(norm(e), ab);
          expect(i, greaterThanOrEqualTo(0), reason: '$wo: „$e“ fehlt oder steht zu früh');
          ab = i + norm(e).length;
        }
      }

      test('Reihenfolge: Indizkarten nach Code, je zwei je Blatt, dann Geheimnis- und Aktionskarten in Platzreihenfolge', () {
        expect(roh, hasLength(plan.indiz + plan.geheimnis + plan.aktion));
        for (var s = 0; s < plan.indiz; s++) {
          final paar = indiz.skip(2 * s).take(2).toList();
          inReihenfolge(roh[s], [for (final c in paar) indizAussen(c)], 'Indizkarten Seite ${s + 1}');
          for (final c in indiz.where((c) => !paar.contains(c))) {
            expect(norm(roh[s]), isNot(contains(norm(indizAussen(c)))), reason: 'Seite ${s + 1}: ${c.code}');
          }
        }
        for (var s = 0; s < plan.geheimnis; s++) {
          final paar = b.geheimniskarten.skip(2 * s).take(2).toList();
          inReihenfolge(roh[plan.indiz + s], [for (final p in paar) geheimnisAussen(p)], 'Geheimniskarten Seite ${s + 1}');
        }
        for (var s = 0; s < plan.aktion; s++) {
          final acht = b.aktionskarten.skip(8 * s).take(8).toList();
          final text = roh[plan.indiz + plan.geheimnis + s];
          inReihenfolge(
              text,
              [
                for (final p in acht) ...[aktionKopf(p), k.klartext(k.rolle(p).aktionskarte.name)],
              ],
              'Aktionskarten Seite ${s + 1}');
        }
        // Platzreihenfolge, besetzte Rollen und fehlende Zeugen.
        expect([for (final p in b.geheimniskarten) p.platz], [for (var i = 1; i <= (personen <= 12 ? 10 : personen - 2); i++) i]);
      });

      test('Besetzung: fehlende Zeugen mit eigener Vorderseite und Karte beim Detektiv, fehlende Zusatzrollen gar nicht', () {
        final alles = norm(roh.join(' '));
        final fehlend = b.fehlendeZeugen;
        expect(
            fehlend.length,
            switch (personen) {
              6 => 6,
              10 => 2,
              _ => 0,
            });
        String n(String s) => norm(s);
        int zaehle(String s) => n(s).allMatches(alles).length;
        expect(zaehle(k.klartext(k.ui('20', 'aktion.kopf.detektiv'))), fehlend.length);
        expect(zaehle(k.klartext(k.ui('20', 'geheimnis.vorne.hinweis'))), b.besetzt.length);
        for (final p in k.inhalt.fall.plaetze) {
          final aktion = n(k.klartext(k.rolle(p).aktionskarte.name));
          final vorne = n(k.klartext(k.ui('20', 'geheimnis.vorne', {'name': p.name, 'platz': '${p.platz}'})));
          if (b.istBesetzt(p.id)) {
            expect(alles, contains(n(aktionKopf(p))), reason: p.name);
            expect(alles, contains(aktion), reason: p.name);
          } else if (fehlend.contains(p)) {
            expect(alles, contains(n(geheimnisAussen(p))), reason: p.name);
            expect(alles, isNot(contains(n(k.klartext(k.ui('20', 'aktion.kopf', {'name': p.name}))))), reason: p.name);
            expect(alles, contains(aktion), reason: p.name);
          } else {
            expect(p.art, KammerArt.zusatz, reason: p.name);
            expect(alles, isNot(contains(vorne)), reason: p.name);
            expect(alles, isNot(contains(aktion)), reason: p.name);
          }
        }
      });

      test('jede Karte vollständig: alle Texte stehen auf ihrem Blatt', () {
        final ik = k.inhalt.indizkarten;
        for (final (i, c) in indiz.indexed) {
          final text = norm(roh[i ~/ 2]);
          final teile = [
            c.titel,
            c.wasDuFindest,
            ?c.ortstermin,
            if (c.ortstermin != null) c.zeugen.length > 1 ? ik.ortsterminSchlussMehrzahl : ik.ortsterminSchlussEinzahl,
            ...(c.art == KammerKartenArt.ortstermin && c.vermerke.isEmpty ? [ik.ortsterminVermerk] : c.vermerke),
          ];
          for (final t in teile) {
            expect(text, contains(norm(k.klartext(t))), reason: '${c.code}: $t');
          }
        }
        for (final (i, p) in b.geheimniskarten.indexed) {
          final text = norm(roh[plan.indiz + i ~/ 2]);
          final gk = k.rolle(p).geheimniskarte;
          for (final t in [gk.wasIchZugebe, ...gk.vermerke, gk.undNochEtwas]) {
            expect(text, contains(norm(k.klartext(t))), reason: '${p.name}: $t');
          }
        }
        for (final (i, p) in b.aktionskarten.indexed) {
          final text = norm(roh[plan.indiz + plan.geheimnis + i ~/ 8]);
          final a = k.rolle(p).aktionskarte;
          for (final t in [
            a.wirkung,
            a.grenzen,
            k.ui('20', 'aktion.fuss'),
            k.uiGemeinsam('ab.runde', {'runde': '${a.abRunde}'}),
          ]) {
            expect(text, contains(norm(k.klartext(t))), reason: '${p.name}: $t');
          }
        }
        expect(roh.join(), isNot(contains('{')));
        expect(roh.join(), isNot(contains('OFFEN')));
      });

      test('Z-Falz: außen nur Code und Runde bzw. Name und Platz (E8, E12), innen nichts über den Falzen', () {
        final hinweis = k.klartext(k.ui('20', 'falz.hinweis')).split(RegExp(r'\s+')).toSet();
        final zFalz = [
          for (final c in indiz) {c.code, ...indizAussen(c).split(RegExp(r'\s+'))},
          for (final p in b.geheimniskarten)
            {...geheimnisAussen(p).split(RegExp(r'\s+')), if (b.istBesetzt(p.id)) ...k.klartext(k.ui('20', 'geheimnis.vorne.hinweis')).split(RegExp(r'\s+'))},
        ];
        // Die Indizkarten belegen 10 Blätter, das letzte nur links.
        final karteAuf = <(int, int), Set<String>>{};
        for (final (i, erlaubt) in zFalz.indexed) {
          final s = i < indiz.length ? i ~/ 2 : plan.indiz + (i - indiz.length) ~/ 2;
          final spalte = i < indiz.length ? i % 2 : (i - indiz.length) % 2;
          karteAuf[(s, spalte)] = erlaubt;
        }
        for (var s = 0; s < plan.indiz + plan.geheimnis; s++) {
          for (final w in wo[s]) {
            final spalte = (w.x0 + w.x1) / 2 < seitenBreite / 2 ? 0 : 1;
            final ort = 'Seite ${s + 1}, „${w.wort}“ bei ${(w.y0 / mm).toStringAsFixed(1)} mm';
            expect(karteAuf.containsKey((s, spalte)), isTrue, reason: '$ort: Text auf einer leeren Hälfte');
            // Kein Wort über einem Falz, keins auf dem Deckfeld.
            expect(w.y0 >= falz1 || w.y1 <= falz1, isTrue, reason: ort);
            expect(w.y1, lessThanOrEqualTo(falz2 - mm), reason: '$ort: zu nah am Deckfeld');
            if (w.y1 <= falz1) {
              expect(karteAuf[(s, spalte)], contains(w.wort), reason: '$ort: kein Text der Außenseite');
            } else if (w.y0 < falz1 + 5 * mm) {
              expect(hinweis, contains(w.wort), reason: '$ort: Text der Innenseite näher als 5 mm am Falz');
            }
          }
        }
      });

      test('keine Schrift unter 9 pt, Druckrand 5 mm', () async {
        for (final (s, seite) in wo.indexed) {
          for (final w in seite) {
            expect((w.y1 - w.y0) / interHoehe, greaterThanOrEqualTo(9 - 0.05), reason: 'Seite ${s + 1}: „${w.wort}“');
          }
        }
        final rand = await kammerRandAbstand(saetze[personen]!.bytes);
        expect(rand!.abstand, greaterThanOrEqualTo(KammerSatz.druckRand - 0.01), reason: 'Seite ${rand.seite}: ${rand.wort}');
      });

      test('gleiche Gestalt (E9): eine Schrift für alle Geheimniskarten, eine für alle Aktionskarten', () {
        final hinweis = k.klartext(k.ui('20', 'falz.hinweis')).split(RegExp(r'\s+')).toSet();
        final geheim = <String, double>{};
        for (final (i, p) in b.geheimniskarten.indexed) {
          final seite = wo[plan.indiz + i ~/ 2];
          final innen = seite.where((w) => w.y0 > falz1 && w.y1 < falz2 && !hinweis.contains(w.wort) && ((w.x0 + w.x1) / 2 < seitenBreite / 2) == (i.isEven));
          geheim[p.name] = haeufigste(innen);
        }
        expect(geheim.values.toSet(), hasLength(1), reason: '$geheim');
        final aktion = <String, double>{};
        for (final (i, p) in b.aktionskarten.indexed) {
          final seite = wo[plan.indiz + plan.geheimnis + i ~/ 8];
          final zelle = i % 8;
          final zelleBreite = seitenBreite / 4;
          final zelleHoehe = KammerSatz.a7Hoehe;
          final drin = seite.where((w) => ((w.x0 + w.x1) / 2 / zelleBreite).floor() == zelle % 4 && ((w.y0 + w.y1) / 2 / zelleHoehe).floor() == zelle ~/ 4);
          aktion[p.name] = haeufigste(drin);
        }
        expect(aktion.values.toSet(), hasLength(1), reason: '$aktion');
        expect(aktion.values.first, greaterThanOrEqualTo(geheim.values.first), reason: 'Aktionskarten haben mehr Platz');
      });
    });
  }

  test('Einzeldatei: am Ende die eigene Aktionskarte (MECH 10.3), A4 hoch, in derselben Schrift wie am Tisch', () async {
    final k = kammerKontext(13);
    for (final p in [k.besetzung.besetzt.first, k.besetzung.besetzt.last]) {
      final d = await kammerEinzeldatei(k, p);
      final pdf = kammerPdf(d.bytes);
      expect(pdf.formate, everyElement('hoch'));
      final letzte = norm(pdf.seitenText.last);
      final a = k.rolle(p).aktionskarte;
      for (final t in [
        k.uiGemeinsam('heft.deineAktionskarte'),
        k.ui('20', 'aktion.kopf', {'name': p.name}),
        a.name,
        a.wirkung,
        a.grenzen,
        k.ui('20', 'aktion.fuss'),
      ]) {
        expect(letzte, contains(norm(k.klartext(t))), reason: '${p.name}: $t');
      }
      // Ohne Kopf, Fuß und Überschrift der Seite: nur die Karte.
      final abbildung = (await woerter(d.bytes)).seiten.last.where((x) => x.y0 > 100 && x.y1 < 780);
      final plan = seitenplan(k.besetzung);
      final amTisch = (await woerter(saetze[13]!.bytes)).seiten.skip(plan.indiz + plan.geheimnis).expand((s) => s);
      expect(haeufigste(abbildung), haeufigste(amTisch), reason: p.name);
    }
  });

  test('gleiche Eingaben ergeben gleiche Bytes', () async {
    final k = kammerKontext(13);
    final a = await kammerTeilDatei(k, kammerTeil(k, '20'));
    expect(a.bytes, saetze[13]!.bytes);
  });

  group('Überlauf ist nie still, und nie unter 9 pt', () {
    KammerKontext mit(int personen, void Function(Map<String, Object?> j) aendern) {
      final j = <String, Object?>{for (final e in leseKammerDateien(repoWurzel).entries) e.key: jsonDecode(e.value)};
      aendern(j);
      return KammerKontext(KammerInhalt.ausJson(j), personen: personen, stil: kammerStil);
    }

    test('FX3 mit einem Satz mehr passt nicht mehr: Überlauf mit Code statt kleinerer Schrift', () {
      final k = mit(10, (j) {
        final karten = ((j['indizkarten.json']! as Map<String, Object?>)['karten']! as List).cast<Map<String, Object?>>();
        final fx3 = karten.firstWhere((c) => c['code'] == 'FX3');
        fx3['wasDuFindest'] = '${fx3['wasDuFindest']} ${'Am Boden liegt nichts als Staub und ein paar Krümel vom Buffet. ' * 2}'.trim();
      });
      expect(
        () => kammerKarten(kammerStil.neuesDokument('probe'), k),
        throwsA(isA<KammerUeberlauf>().having((e) => e.teil, 'teil', '20').having((e) => '$e', 'meldung', allOf(contains('FX3'), contains('9.0pt')))),
      );
    });

    test('eine Geheimniskarte, die auch in 9 pt nicht passt, nennt die Rolle', () {
      final k = mit(20, (j) {
        final gk = (j['rollen/18-tugba.json']! as Map<String, Object?>)['geheimniskarte']! as Map<String, Object?>;
        gk['wasIchZugebe'] = List.filled(5, gk['wasIchZugebe']).join(' ');
      });
      expect(
        () => kammerKarten(kammerStil.neuesDokument('probe'), k),
        throwsA(isA<KammerUeberlauf>().having((e) => '$e', 'meldung', allOf(contains('Teil 20'), contains('Tugba')))),
      );
    });
  });
}
