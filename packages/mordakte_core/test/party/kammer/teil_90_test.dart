// Teil 90 (Auflösungsheft, versiegelt) des Kammerspiels (MECH 6.1–6.4, 7.2, 8.1–8.4, 10.1; RK x.12, ZG x.12,
// ZR x.13): Seitenzahlen nach MECH 10.1 (9 / 10 / 12 bei 6 / 12 / 20 Personen, dazwischen steigend), jede Seite
// A4 hoch; die Außenseite trägt Titel, Fall-Code und Hinweis im oberen Drittel, mittig, das mittlere Drittel ist
// leer, im unteren steht die Anleitung zum Verschließen (Faltart wie Teil 11); die Seiten 2 bis 5 nach MECH 8.4
// (Was wirklich war und Meilensteine, Enden 1 und 2, Enden 3 und 4, Rückblende allein), ab Seite 6 Zeitleiste,
// Die Rollen am Tisch, Tipp-Wertung und Zum Nachlesen in dieser Reihenfolge; „Die Rollen am Tisch“ und die
// Bonus-Ziele genau für die gespielten Rollen, Verdächtige mit Fassungscode, die anderen mit Platz; fehlende
// Zusatzrollen nirgends mit Namen, fehlende Zeugen in der Streifentabelle; jedes Ende mit beiden Bund-Sätzen;
// Stichworte M1 bis M3 passend zu den Vermerken; Lösung, Sekunden und alle vier Fassungscodes; nichts unter 9 pt
// außer Kopf und Fuß, die Rückblende in mindestens 10 pt; gleiche Eingaben, gleiche Bytes. Rot-Proben: zu lange
// Rückblende, Meilensteinregel und Rollen-Absätze brechen mit KammerUeberlauf ab, statt still abzuschneiden.
//
// Seitenzahlen für alle Personenzahlen 6 bis 20; die übrigen Prüfungen bei 6 (alle sechs Zeugen fehlen),
// 10 (Vorgabe, Marek und Zeynep fehlen), 13 (Sibel ohne Damir, Detektiv m), 14 (ab hier liest jede Person ihren
// Absatz selbst) und 20 (alle achtzehn Rollen). Text aus pdftotext -layout, Lage und Größe aus pdftotext -bbox.
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:mordakte_core/kammer_io.dart' show leseKammerDateien;
import 'package:mordakte_core/party_druck.dart';
import 'package:test/test.dart';

import '../kanon_hilfe.dart' show repoWurzel;
import 'kammer_druck_hilfe.dart';

/// Seiten von Teil 90 bei 6, 12 und 20 Personen (MECH 10.1).
const mech101 = {6: 9, 12: 10, 20: 12};

/// Genau geprüfte Besetzungen mit Detektiv.
const faelle = {6: 'w', 10: 'w', 13: 'm', 14: 'w', 20: 'w'};

const mm = KammerSatz.mm;

/// Wortboxen sind so hoch wie die Schrift mal (Oberlänge + Unterlänge) von Inter.
const interHoehe = 1.209;

/// Kopf und Fuß (8,5 pt, gemeinsamer Helfer) liegen über bzw. unter diesen Linien (pt von oben).
const kopfBis = 60.0, fussAb = 785.0;

typedef Wort = ({double x0, double y0, double x1, double y1, String wort});

Future<Uint8List> setze(KammerKontext k) async => (await kammerTeilDatei(k, kammerTeil(k, '90'))).bytes;

/// Wortboxen je Seite (pdftotext -bbox).
Future<List<List<Wort>>> woerter(Uint8List bytes) async {
  final dir = Directory.systemTemp.createTempSync('kammer_90');
  try {
    final f = File('${dir.path}/satz.pdf')..writeAsBytesSync(bytes);
    final xml = (await Process.run('pdftotext', ['-bbox', f.path, '-'])).stdout as String;
    return [
      for (final seite in xml.split('<page ').skip(1))
        [
          for (final w in RegExp(r'<word xMin="([\d.]+)" yMin="([\d.]+)" xMax="([\d.]+)" yMax="([\d.]+)">([^<]*)<').allMatches(seite))
            (x0: double.parse(w.group(1)!), y0: double.parse(w.group(2)!), x1: double.parse(w.group(3)!), y1: double.parse(w.group(4)!), wort: w.group(5)!),
        ],
    ];
  } finally {
    dir.deleteSync(recursive: true);
  }
}

/// Text in Satzreihenfolge (pdftotext -raw): Tabellenzellen nacheinander, nicht Zeile für Zeile gemischt.
Future<String> rohText(Uint8List bytes) async {
  final dir = Directory.systemTemp.createTempSync('kammer_90');
  try {
    final f = File('${dir.path}/satz.pdf')..writeAsBytesSync(bytes);
    return (await Process.run('pdftotext', ['-raw', f.path, '-'])).stdout as String;
  } finally {
    dir.deleteSync(recursive: true);
  }
}

/// Zeilen einer Seite ohne Rand.
List<String> zeilen(String seite) => [for (final z in seite.split('\n')) z.trim()];

void main() {
  final bytes = <String, Uint8List>{};
  final pdfs = <String, KammerPdf>{};
  String schluessel(int personen, String detektiv) => '$personen$detektiv';

  setUpAll(() async {
    final saetze = [for (var p = 6; p <= 20; p++) (p, 'w'), (13, 'm')];
    for (final (p, d) in saetze) {
      bytes[schluessel(p, d)] = await setze(kammerKontext(p, detektiv: d));
    }
    final befunde = await kammerPdfs([for (final (p, d) in saetze) bytes[schluessel(p, d)]!]);
    for (final (i, (p, d)) in saetze.indexed) {
      pdfs[schluessel(p, d)] = befunde[i];
    }
  });

  test('Seitenzahlen nach MECH 10.1 (9 / 10 / 12 bei 6 / 12 / 20), dazwischen steigend, jede Seite A4 hoch', () {
    var vorher = 0;
    for (var p = 6; p <= 20; p++) {
      final pdf = pdfs[schluessel(p, 'w')]!;
      if (mech101.containsKey(p)) expect(pdf.seiten, mech101[p], reason: '$p Personen');
      expect(pdf.seiten, inInclusiveRange(9, 12), reason: '$p Personen');
      expect(pdf.seiten, greaterThanOrEqualTo(vorher), reason: '$p Personen');
      expect(pdf.formate, everyElement('hoch'), reason: '$p Personen');
      vorher = pdf.seiten;
    }
    expect(pdfs[schluessel(13, 'm')]!.seiten, pdfs[schluessel(13, 'w')]!.seiten);
  });

  test('Tipp-Wertung: die Sonderregel steht bei jeder Personenzahl auf der Seite der Tabelle (nie allein umbrochen)', () {
    for (var p = 6; p <= 20; p++) {
      final k = kammerKontext(p);
      final seiten = [for (final s in pdfs[schluessel(p, 'w')]!.seitenText) kammerFlach(s)];
      int seite(String text) => seiten.indexWhere((s) => s.contains(text));
      final tabelle = seite(kammerFlach(k.klartext(k.ui('90', 'tippWertung.wer'))));
      final regel = kammerFlach(k.klartext(k.inhalt.aufloesung.sonderregel));
      expect(tabelle, greaterThan(0), reason: '$p Personen');
      expect(seite(regel.substring(0, math.min(40, regel.length))), tabelle, reason: '$p Personen');
    }
  });

  for (final MapEntry(key: personen, value: detektiv) in faelle.entries) {
    group('$personen Personen, Detektiv $detektiv', () {
      late KammerKontext k;
      late KammerPdf pdf;
      late List<String> flach;
      late String alles;
      late List<List<Wort>> boxen;
      String u(String s, [Map<String, String> w = const {}]) => k.klartext(k.ui('90', s, w));
      String text(String roh) => kammerFlach(k.klartext(roh));
      KammerBesetzung b() => k.besetzung;

      setUpAll(() async {
        k = kammerKontext(personen, detektiv: detektiv);
        pdf = pdfs[schluessel(personen, detektiv)]!;
        flach = [for (final s in pdf.seitenText) kammerFlach(s)];
        alles = kammerFlach(await rohText(bytes[schluessel(personen, detektiv)]!));
        boxen = await woerter(bytes[schluessel(personen, detektiv)]!);
      });

      test('Außenseite: oben mittig nur Titel, Fall-Code und Hinweis, Mitte leer, unten die Anleitung zum Verschließen wie Teil 11, ohne Kopf und Fuß', () {
        final seite = boxen.first;
        const a4 = KammerSatz.a4Hoch;
        final drittel = a4.height / 3;
        final oben = seite.where((w) => w.y1 < drittel).toList();
        final mitte = seite.where((w) => w.y0 < 2 * drittel && w.y1 > drittel).toList();
        final unten = seite.where((w) => w.y0 > 2 * drittel).toList();
        expect(oben.length + mitte.length + unten.length, seite.length, reason: 'Wort über einem Falz');
        expect(kammerFlach(oben.map((w) => w.wort).join(' ')), kammerFlach('${u('deckblatt.titel')} ${k.fallCode} ${u('deckblatt.hinweis')}'));
        // Das mittlere Drittel liegt gefaltet außen; direkt hinter dem Code liegt die Anleitung, nie die Lösung.
        expect(mitte, isEmpty, reason: mitte.map((w) => w.wort).join(' '));
        // Unten die vier Schritte nummeriert, Schritt 1 mit der letzten Seite dieses Hefts.
        final letzte = {'letzte': '${pdf.seiten}'};
        final anleitung = [u('verschliessen.titel'), for (var n = 1; n <= 4; n++) '$n. ${u('verschliessen.$n', letzte)}'];
        expect(kammerFlach(unten.map((w) => w.wort).join(' ')), kammerFlach(anleitung.join(' ')));
        expect(u('verschliessen.1', letzte), contains('2 bis ${pdf.seiten} '));
        // Dieselbe Faltart wie Teil 11: Schritte 2 und 3 wörtlich gleich.
        for (final n in [2, 3]) {
          expect(u('verschliessen.$n'), k.klartext(k.ui('11', 'verschliessen.$n')), reason: 'Schritt $n');
        }
        // Mittig: Titel, Code und Hinweis je Zeile um die Blattmitte (die Sperrung des Codes rückt ihn um 3 pt),
        // der Block senkrecht in der Mitte des oberen Drittels.
        final blockMitte = (oben.map((w) => w.y0).reduce(math.min) + oben.map((w) => w.y1).reduce(math.max)) / 2;
        expect(blockMitte, closeTo(drittel / 2, 12));
        final zeilenMitte = <double, List<Wort>>{};
        for (final w in oben) {
          (zeilenMitte[w.y0.roundToDouble()] ??= []).add(w);
        }
        for (final z in zeilenMitte.values) {
          final mitte = (z.map((w) => w.x0).reduce(math.min) + z.map((w) => w.x1).reduce(math.max)) / 2;
          expect(mitte, closeTo(a4.width / 2, 4), reason: z.map((w) => w.wort).join(' '));
        }
        // Der Fuß zählt die Seiten im Teil, die Außenseite mit.
        for (var s = 2; s <= pdf.seiten; s++) {
          expect(flach[s - 1], contains(kammerFlach(k.uiGemeinsam('fuss.seite', {'seite': '$s', 'seiten': '${pdf.seiten}'}))));
        }
      });

      test('Seiten 2 bis 5 nach MECH 8.4', () {
        final enden = {for (final e in k.inhalt.aufloesung.enden) e.nr: u('ende', {'nr': '${e.nr}', 'name': k.klartext(e.name)})};
        final s2 = zeilen(pdf.seitenText[1]), s3 = zeilen(pdf.seitenText[2]), s4 = zeilen(pdf.seitenText[3]), s5 = zeilen(pdf.seitenText[4]);
        // Seite 2: Was wirklich war (Kernsatz wörtlich), die neun Meilensteine mit Summe.
        expect(s2, containsAllInOrder([u('wasWirklichWar'), u('meilensteine')]));
        expect(flach[1], contains(text(k.inhalt.aufloesung.wasWirklichWar)));
        expect(flach[1], contains(kammerFlach(u('meilensteine.summe', {'max': '${k.fall.punkte.detektivMax}'}))));
        for (final m in k.inhalt.aufloesung.meilensteine) {
          expect(s2.where(RegExp('^${m.nr}\\s{2,}').hasMatch), hasLength(1), reason: m.nr);
        }
        // Seite 3: Endentabelle, Ende 1 und 2; Seite 4: Ende 3 und 4.
        expect(s3, containsAllInOrder([u('enden'), enden[1], enden[2]]));
        expect(s3, isNot(contains(enden[3])));
        expect(s4, containsAllInOrder([enden[3], enden[4]]));
        // Seite 5: die Rückblende allein, ganz.
        expect(s5, contains(u('rueckblende')));
        expect(s5, isNot(contains(u('zeitleiste'))));
        for (final r in k.inhalt.aufloesung.rueckblende) {
          expect(flach[4], contains(text(r)));
        }
        // Seite 6 beginnt mit der Zeitleiste.
        expect(zeilen(pdf.seitenText[5]).where((z) => z.isNotEmpty).elementAt(1), u('zeitleiste'));
      });

      test('ab Seite 6: Zeitleiste, Die Rollen am Tisch, Tipp-Wertung, Zum Nachlesen in Reihenfolge', () {
        final rest = [for (final s in pdf.seitenText.skip(5)) ...zeilen(s)];
        final folge = [
          u('zeitleiste'),
          u('rollenAmTisch'),
          u('tippWertung'),
          u('tippWertung.bonusZiele'),
          u('zumNachlesen'),
          u('zumNachlesen.ausloeser'),
          if (b().abwesenheitsblatt) u('zumNachlesen.streifen'),
          u('zumNachlesen.indizkarten'),
        ];
        expect(rest, containsAllInOrder(folge));
        for (final h in folge) {
          expect(rest.where((z) => z == h), hasLength(1), reason: h);
        }
        if (!b().abwesenheitsblatt) expect(rest, isNot(contains(u('zumNachlesen.streifen'))));
        // Wer liest (MECH 8.4): ab 14 Personen jede Person selbst.
        expect(alles, contains(kammerFlach(u(personen >= 14 ? 'rollenAmTisch.selbst' : 'rollenAmTisch.erzaehler'))));
        expect(alles, isNot(contains(kammerFlach(u(personen >= 14 ? 'rollenAmTisch.erzaehler' : 'rollenAmTisch.selbst')))));
      });

      test('Die Rollen am Tisch: je gespielter Rolle ihr Absatz in Platzreihenfolge, Verdächtige mit Fassungscode, die anderen mit Platz', () {
        var bisher = -1;
        for (final p in b().besetzt) {
          final r = k.rolle(p);
          final name = r.fassung == null
              ? u('rollenAmTisch.platz', {'name': p.name, 'platz': '${p.platz}'})
              : u('rollenAmTisch.fassung', {'name': p.name, 'code': r.fassung!.code});
          final i = alles.indexOf(kammerFlach('$name ${k.klartext(r.teil90)}'));
          expect(i, greaterThan(bisher), reason: p.name);
          bisher = i;
          // Das Etikett ist nie nur der Name: Der Absatz beginnt selbst mit ihm („Lejla Lejla …“).
          expect(name, isNot(p.name), reason: p.name);
        }
        final abschnitt = alles.substring(alles.indexOf(kammerFlach(u('rollenAmTisch'))), alles.indexOf(kammerFlach(u('tippWertung.wer'))));
        for (final p in b().besetzt) {
          expect(abschnitt, isNot(contains('${p.name} ${p.name} ')), reason: p.name);
        }
        for (final p in k.fall.plaetze.where((p) => !b().istBesetzt(p.id))) {
          expect(alles, isNot(contains(text(k.rolle(p).teil90))), reason: p.name);
        }
      });

      test('fehlende Zusatzrollen stehen nirgends mit Namen, fehlende Zeugen in der Streifentabelle (MECH 8.3)', () {
        for (final p in k.fall.plaetze.where((p) => p.art == KammerArt.zusatz && !b().istBesetzt(p.id))) {
          expect(RegExp('\\b${p.name}\\b').hasMatch(alles), isFalse, reason: p.name);
        }
        final streifen = alles.contains(kammerFlach(u('zumNachlesen.streifen')))
            ? alles.substring(alles.indexOf(kammerFlach(u('zumNachlesen.streifen'))), alles.indexOf(kammerFlach(u('zumNachlesen.indizkarten'))))
            : '';
        for (final p in b().fehlendeZeugen) {
          final karte = k.rolle(p).geheimniskarte;
          expect(streifen, contains(p.name));
          for (final c in [...k.inhalt.streifenVon(p.id).oeffnen, ...karte.pflichtCodes]) {
            expect(streifen, contains(c), reason: '${p.name} $c');
          }
        }
      });

      test('Enden: Endentabelle, in jedem Ende beide Bund-Sätze, keine Platzhalter', () {
        final a = k.inhalt.aufloesung;
        String zaehlen(String s) => '${RegExp(RegExp.escape(kammerFlach(s))).allMatches(alles).length}';
        expect(zaehlen(u('bund.ohnePp9')), '4');
        expect(zaehlen(u('bund.mitPp9')), '4');
        for (final s in [a.bundSaetze.taeterOhnePp9, a.bundSaetze.taeterMitPp9, a.bundSaetze.andereOhnePp9, a.bundSaetze.andereMitPp9]) {
          expect(zaehlen(k.klartext(s)), '2', reason: s);
        }
        for (final e in k.fall.enden) {
          expect(alles, contains(kammerFlach(u('enden.bereich', {'von': '${e.von}', 'bis': '${e.bis}'}))));
        }
        expect(pdf.text, isNot(matches(RegExp(r'[{}]|BUNDSATZ|OFFEN'))));
      });

      test('Tipp-Wertung: Lösungen, Sonderregel, Bonus-Ziel jeder gespielten Rolle und des Erzählers, Spürnase', () {
        final a = k.inhalt.aufloesung;
        final tipp = alles.substring(alles.indexOf(kammerFlach(u('tippWertung.wer'))), alles.indexOf(kammerFlach(u('zumNachlesen.wer'))));
        for (final t in a.tippFragen) {
          expect(tipp, contains(text(t.loesung)));
        }
        expect(tipp, contains(text(a.sonderregel)));
        expect(tipp, contains(text(a.spuernase)));
        final etikett = '${k.klartext(k.uiGemeinsam('heft.deinBonusZiel'))}:';
        for (final p in b().besetzt) {
          final ziel = text(k.rolle(p).bonusZiel.text).replaceFirst(etikett, '').trim();
          expect(tipp, contains(ziel), reason: p.name);
          expect(tipp, contains(p.name));
        }
        expect(tipp, contains(text(a.erzaehlerBonus)));
        expect(tipp, contains(k.klartext(k.uiGemeinsam('erzaehler'))));
      });

      test('Zum Nachlesen: Pflicht-Auslöser jeder gespielten Rolle, die 19 Indizkarten', () {
        final nach = alles.substring(alles.indexOf(kammerFlach(u('zumNachlesen.wer'))));
        for (final p in b().besetzt) {
          for (final t in k.texte(k.rolle(p).stufe2.ausloeser)) {
            expect(nach, contains(text(t)), reason: p.name);
          }
          // Die Rundensperre steht wie im Heft vor den Auslösern, gleich hinter dem Namen.
          final sperre = k.rolle(p).geheimniskarte.sperre;
          if (sperre > 1) {
            final vorn = '${p.name} ${text(k.uiGemeinsam('heft.rundensperre', {'runde': '$sperre'}))}';
            final i = nach.indexOf(vorn);
            expect(i, greaterThanOrEqualTo(0), reason: p.name);
            // Dazwischen höchstens die Nummer „1.“.
            final erster = nach.indexOf(text(k.texte(k.rolle(p).stufe2.ausloeser).first), i);
            expect(erster - (i + vorn.length), inInclusiveRange(1, 4), reason: p.name);
          }
        }
        final indiz = nach.substring(nach.indexOf(kammerFlach(u('zumNachlesen.indizkarten'))));
        for (final c in k.inhalt.indizkarten.karten) {
          expect(indiz, contains(c.code));
        }
      });

      test('Lösung, Sekunden und alle vier Fassungscodes (nur Teil 90 darf das)', () {
        for (final c in k.fall.fassungsCodes) {
          expect(alles, contains(c));
        }
        expect(alles, contains(k.fall.plaetze.firstWhere((p) => p.id == k.fall.taeter).name));
        for (final z in k.inhalt.aufloesung.zeitleiste) {
          expect(alles, contains(kammerFlach(z.zeit)));
        }
      });

      test('nichts unter 9 pt außer Kopf und Fuß, Rückblende in mindestens 10 pt, Druckrand', () async {
        for (final (i, seite) in boxen.indexed) {
          for (final w in seite) {
            if (i > 0 && (w.y1 < kopfBis || w.y0 > fussAb)) continue;
            expect(w.y1 - w.y0, greaterThanOrEqualTo(9 * interHoehe - 0.05), reason: 'Seite ${i + 1}: ${w.wort}');
          }
        }
        // Seite 5: der Vorlesetext (alles außer Überschrift, Hinweis und Marke) in mindestens 10 pt.
        final rueck = [for (final w in boxen[4]) if (w.y0 > kopfBis && w.y1 < fussAb) w.y1 - w.y0]..sort();
        expect(rueck[rueck.length ~/ 4], greaterThanOrEqualTo(10 * interHoehe - 0.05));
        final rand = await kammerRandAbstand(bytes[schluessel(personen, detektiv)]!);
        expect(rand!.abstand, greaterThanOrEqualTo(KammerSatz.druckRand - 0.01), reason: 'Seite ${rand.seite}: ${rand.wort}');
      });
    });
  }

  test('Stichworte M1 bis M3 passen zu den Vermerken, die der Detektiv wörtlich abschreibt; der Ort um 23:57 bringt M1 nicht', () {
    // Alle Texte des Inhalts; Vermerke beginnen mit ihrem Feld („Alibi beim Scheppern · Fatma: …“).
    final texte = <String>[];
    void sammeln(Object? j) {
      if (j is String) texte.add(j);
      if (j is List) j.forEach(sammeln);
      if (j is Map) j.values.forEach(sammeln);
    }

    for (final d in leseKammerDateien(repoWurzel).values) {
      sammeln(jsonDecode(d));
    }
    const alibi = 'Alibi beim Scheppern · ';
    const nr = {'Ahmet': 'M1', 'Fatma': 'M2', 'Can': 'M3', 'für das leuchtende Gesicht': 'M3'};
    for (final personen in [6, 10, 12, 20]) {
      final k = kammerKontext(personen);
      // Die Stichworte stehen im ersten Satz; danach folgt höchstens, was allein nicht genügt.
      List<String> stichworte(String m) => [
            for (final x in RegExp('„([^“]+)“').allMatches(k.klartext(k.inhalt.aufloesung.meilensteine.singleWhere((s) => s.nr == m).stichwort).split('. ').first))
              x.group(1)!.toLowerCase(),
          ];
      var geprueft = 0;
      for (final v in texte.where((t) => t.startsWith(alibi)).map((t) => k.klartext(t))) {
        final wer = nr.keys.where((w) => v.startsWith('$alibi$w:'));
        if (wer.isEmpty) continue;
        final m = nr[wer.single]!;
        expect(stichworte(m).where((s) => v.toLowerCase().contains(s)), isNotEmpty, reason: '$personen Personen, $m: $v');
        geprueft++;
      }
      expect(geprueft, greaterThanOrEqualTo(5), reason: '$personen Personen');
      final ort = [for (final t in texte) if (t.startsWith('Ort um 23:57 · ') && t.contains('Ahmet')) k.klartext(t).toLowerCase()];
      expect(ort, isNotEmpty);
      for (final o in ort) {
        expect(stichworte('M1').where(o.contains), isEmpty, reason: '$personen Personen: $o');
      }
    }
  });

  test('gleiche Eingaben, gleiche Bytes', () async {
    expect(await setze(kammerKontext(13, detektiv: 'm')), bytes[schluessel(13, 'm')]);
  });

  group('Überlauf ist nie still', () {
    KammerKontext mit(int personen, String datei, void Function(Map<String, Object?> json) aendern) {
      final dateien = leseKammerDateien(repoWurzel);
      final json = jsonDecode(dateien[datei]!) as Map<String, Object?>;
      aendern(json);
      return KammerKontext(KammerInhalt.ausJson({...dateien, datei: jsonEncode(json)}), personen: personen, stil: kammerStil);
    }

    Matcher ueberlauf(int seite, String wo) =>
        throwsA(isA<KammerUeberlauf>().having((e) => e.teil, 'teil', '90').having((e) => e.seite, 'seite', seite).having((e) => e.wo, 'wo', wo));

    void setzen(KammerKontext k) => kammerAufloesung(kammerStil.neuesDokument('probe'), k);

    test('doppelt lange Rückblende: auch in 10 pt nicht auf Seite 5', () {
      final k = mit(10, 'aufloesung.json', (j) {
        final r = j['rueckblende']! as List;
        r.addAll([...r]);
      });
      expect(() => setzen(k), ueberlauf(5, 'rueckblende'));
    });

    test('längere Meilensteinregel: Seite 2 läuft über', () {
      final k = mit(10, 'aufloesung.json', (j) => j['meilensteinRegel'] = List.filled(3, j['meilensteinRegel']).join(' '));
      expect(() => setzen(k), ueberlauf(2, 'meilensteine'));
    });

    test('zu lange Anleitung zum Verschließen: auch in 9 pt nicht im unteren Drittel von Seite 1', () {
      final k = mit(10, 'ui/90.json', (j) => j['verschliessen.1'] = List.filled(12, j['verschliessen.1']).join(' '));
      expect(
        () => setzen(k),
        throwsA(isA<KammerUeberlauf>().having((e) => e.teil, 'teil', '90').having((e) => e.seite, 'seite', 1).having((e) => e.wo, 'wo', contains('verschliessen'))),
      );
    });

    test('doppelt lange Absätze „Die Rollen am Tisch“ bei 20 Personen: mehr Seiten als geplant', () {
      final dateien = leseKammerDateien(repoWurzel);
      final json = <String, Object?>{for (final e in dateien.entries) e.key: jsonDecode(e.value)};
      for (final d in dateien.keys.where((d) => d.startsWith('rollen/'))) {
        final r = json[d]! as Map<String, Object?>;
        r['teil90'] = '${r['teil90']} ${r['teil90']}';
      }
      final k = KammerKontext(KammerInhalt.ausJson(json), personen: 20, stil: kammerStil);
      expect(
        () => setzen(k),
        throwsA(isA<KammerUeberlauf>().having((e) => e.teil, 'teil', '90').having((e) => '$e', 'meldung', contains('geplant sind 7'))),
      );
    });
  });
}
