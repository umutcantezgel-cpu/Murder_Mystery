// Teil 01 Detektivbogen und Ermittlungsbogen (MECH 2.1–2.6, 10.1; RK 6.1–6.12; MECH 1.4–1.6,
// 9.11 B): sechs Seiten A4 hoch bei jeder Personenzahl, Seitenplan nach MECH 2.6 und den
// Seitenangaben in RK 6 (Abschnitte auf ihrer Seite und in Reihenfolge), Texte vollständig
// (Fragen-Leitfaden, Untersuchungen, Raster, Regeln, Anklagefeld), Untersuchungsliste mit
// allen Indizkarten nach Runde und Code, Vermerke 1 bis 48 zweispaltig, besetzungsabhängige
// Teile („Wenn Rollen fehlen“ nach `wennRollenFehlenBei`, Aktionskarten nur der fehlenden
// Zeugen bis 11 Personen, Dankeskarte ab 13), Ansprache nach `--detektiv`, Lesetext nie unter
// 9 pt, Druckrand, gleiche Bytes, Überlauf mit Teil und Seite.
//
// Personenzahlen: 6 (alle Zeugen fehlen, Hinweis „6“), 8 (Detektiv männlich), 10 (Vorgabe),
// 11 (nur Zeynep fehlt), 12 (alle Zeugen da, ohne den Zusatz ab 14), 13 (Dankeskarte),
// 14 (Gegenüberstellung im Hinweis), 15 (Hinweis „15–20“) und 20 (alle Rollen, Detektiv
// männlich). Text je Seite über pdftotext -raw (Reihenfolge des Satzes) und -layout (Vermerke).
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:mordakte_core/kammer_io.dart' show leseKammerDateien;
import 'package:mordakte_core/party_druck.dart';
import 'package:test/test.dart';

import '../kanon_hilfe.dart' show repoWurzel;
import 'kammer_druck_hilfe.dart';

/// Personenzahl → Detektiv (`w` oder `m`), Begründung oben.
const faelle = {6: 'w', 8: 'm', 10: 'w', 11: 'w', 12: 'w', 13: 'w', 14: 'w', 15: 'w', 20: 'm'};

/// Höhe eines Worts in pdftotext -bbox je pt Schriftgröße (Inter: Ober- plus Unterlänge).
const bboxJePt = 1.209;

/// Text je Seite mit pdftotext in [modus] (`-raw` oder `-layout`).
Future<List<String>> seitenText(Uint8List bytes, String modus) async {
  final dir = Directory.systemTemp.createTempSync('kammer_01');
  try {
    final f = File('${dir.path}/satz.pdf')..writeAsBytesSync(bytes);
    final text = (await Process.run('pdftotext', [modus, f.path, '-'])).stdout as String;
    final seiten = text.split('\f');
    if (seiten.isNotEmpty && seiten.last.trim().isEmpty) seiten.removeLast();
    return seiten;
  } finally {
    dir.deleteSync(recursive: true);
  }
}

/// Wörter je Seite mit Höhe (pt) aus pdftotext -bbox.
Future<List<List<({String wort, double hoehe})>>> woerter(Uint8List bytes) async {
  final dir = Directory.systemTemp.createTempSync('kammer_01');
  try {
    final f = File('${dir.path}/satz.pdf')..writeAsBytesSync(bytes);
    final xml = (await Process.run('pdftotext', ['-bbox', f.path, '-'])).stdout as String;
    return [
      for (final p in xml.split('<page ').skip(1))
        [
          for (final w in RegExp(r'<word xMin="[\d.]+" yMin="([\d.]+)" xMax="[\d.]+" yMax="([\d.]+)">([^<]*)<').allMatches(p))
            (wort: w.group(3)!, hoehe: double.parse(w.group(2)!) - double.parse(w.group(1)!)),
        ],
    ];
  } finally {
    dir.deleteSync(recursive: true);
  }
}

/// Teil 01 in einem eigenen Dokument.
Future<Uint8List> setze(KammerKontext k) async => (await kammerTeilDatei(k, kammerTeil(k, '01'))).bytes;

/// Zeilen einer Seite ohne Rand.
List<String> zeilen(String seite) => [for (final z in seite.split('\n')) z.trim()];

void main() {
  for (final MapEntry(key: personen, value: detektiv) in faelle.entries) {
    group('$personen Personen, Detektiv $detektiv', () {
      late KammerKontext k;
      late KammerPdf pdf;
      late List<String> roh;
      late List<String> flach;
      late List<String> layout;
      late Uint8List bytes;
      String u(String s, [Map<String, String> w = const {}]) => k.klartext(k.ui('01', s, w));
      String gm(String s, [Map<String, String> w = const {}]) => k.klartext(k.uiGemeinsam(s, w));
      String f(String s) => kammerFlach(KammerSatz.glyphen(k.klartext(s)));
      KammerDetektiv d() => k.inhalt.detektiv;

      setUpAll(() async {
        k = kammerKontext(personen, detektiv: detektiv);
        bytes = await setze(k);
        pdf = kammerPdf(bytes);
        final texte = await Future.wait([seitenText(bytes, '-raw'), seitenText(bytes, '-layout')]);
        roh = texte[0];
        layout = texte[1];
        flach = [for (final s in roh) kammerFlach(s)];
      });

      test('sechs Seiten A4 hoch bei jeder Personenzahl (MECH 10.1), Fuß zählt im Teil', () {
        expect(kammerDetektivbogenSeiten, 6);
        expect(pdf.seiten, kammerDetektivbogenSeiten);
        expect(roh, hasLength(kammerDetektivbogenSeiten));
        expect(pdf.formate, everyElement('hoch'));
        for (var s = 1; s <= pdf.seiten; s++) {
          expect(flach[s - 1], contains(kammerFlach(gm('fuss.seite', {'seite': '$s', 'seiten': '$kammerDetektivbogenSeiten'}))));
          expect(flach[s - 1], contains(kammerFlach(gm('fuss.code', {'code': 'U4YRK'}))));
        }
      });

      test('Abschnitte auf den Seiten des Seitenplans (MECH 2.6, RK 6), je Seite in Reihenfolge', () {
        final fehlend = k.besetzung.aktionskartenBeimDetektiv.isNotEmpty;
        final plan = <int, List<String>>{
          1: [u('fuer').toUpperCase(), u('titel'), u('deinAuftritt'), u('wasDuSelbstWeisst'), gm('ueberschrift.wasAlleWissen')],
          2: [u('soErmittelstDu'), gm('ueberschrift.soSpieltIhr').toUpperCase(), u('fragenLeitfaden'), u('untersuchungen'), gm('ueberschrift.licht')],
          3: [u('aufgabenJeRunde'), u('untersuchungsliste')],
          4: [u('ermittlungsbogen'), u('bogenFuehren')],
          5: [u('vermerke')],
          6: [u('anklage'), u('wennRollenFehlen', {'personen': '$personen'}), if (fehlend) u('aktionskartenFehlend'), u('gegenKarten')],
        };
        for (final MapEntry(key: seite, value: titel) in plan.entries) {
          final z = zeilen(roh[seite - 1]);
          var vorher = -1;
          for (final t in titel) {
            final i = z.indexOf(t);
            expect(i, greaterThan(vorher), reason: 'Seite $seite: „$t“ fehlt oder steht nicht in Reihenfolge');
            vorher = i;
          }
        }
        // Jede Überschrift steht nur auf ihrer Seite (ein Seitenplan, kein Fließen).
        for (final MapEntry(key: seite, value: titel) in plan.entries) {
          for (final t in titel) {
            for (var s = 1; s <= roh.length; s++) {
              if (s != seite) expect(zeilen(roh[s - 1]), isNot(contains(t)), reason: '„$t“ auch auf Seite $s');
            }
          }
        }
        if (!fehlend) expect(roh.join('\n'), isNot(contains(u('aktionskartenFehlend'))));
      });

      test('Seite 1: Ansprache nach dem Detektiv, Auftritt, eigenes Wissen, Was alle wissen (MECH 1.5, 1.6, RK 6.3)', () {
        final s1 = flach[0];
        expect(s1, contains(detektiv == 'w' ? 'FÜR DIE DETEKTIVIN' : 'FÜR DEN DETEKTIV'));
        expect(s1, isNot(contains(detektiv == 'w' ? 'FÜR DEN DETEKTIV' : 'FÜR DIE DETEKTIVIN')));
        expect(s1, contains(kammerFlach(gm('personen', {'personen': '$personen', 'rollen': '${personen - 2}'}))));
        expect(s1, contains(gm('vorlesen').toUpperCase()));
        expect(s1, contains(f(d().auftritt)));
        for (final z in k.texte(d().wasDuSelbstWeisst)) {
          expect(s1, contains(f(z)));
        }
        for (final z in k.texte(k.inhalt.gemeinsam.wasAlleWissen)) {
          expect(s1, contains(f(z)));
        }
        expect(s1.contains('Dankeskarte'), personen >= k.fall.schwellen.dankeskarteAb);
      });

      test('Seite 2: Tischregeln in Kurzform, Fragen-Leitfaden vollständig, Untersuchungen 1–8, Licht (RK 6.6, 6.7, MECH 9.11 B)', () {
        final s2 = flach[1];
        expect(s2, contains(f(k.inhalt.gemeinsam.soSpieltIhr)));
        // Die ganzen Tischregeln stehen nur im Erzählerheft.
        for (final r in k.inhalt.gemeinsam.tischregeln) {
          expect(flach.join(' '), isNot(contains(f(r.text))), reason: r.nr);
        }
        final nummern = <String>[];
        for (final g in d().fragenLeitfaden) {
          expect(s2, contains(f(g.titel)), reason: g.titel);
          for (final frage in g.fragen) {
            expect(s2, contains(frage.nr == null ? f(frage.text) : kammerFlach('${frage.nr} ${k.klartext(frage.text)}')), reason: frage.nr ?? frage.text);
            if (frage.nr != null) nummern.add(frage.nr!);
          }
        }
        expect(nummern, ['A1', 'A2', 'A3', 'A4', 'A5', 'A6', 'B1', 'B2', 'B3', 'B4', 'C1', 'C2', 'C3']);
        final untersuchungen = k.texte(d().untersuchungen);
        expect(untersuchungen, hasLength(8));
        for (final (i, z) in untersuchungen.indexed) {
          expect(s2, contains(kammerFlach('${i + 1}. ${k.klartext(z)}')));
        }
        expect(s2, contains(f(k.inhalt.gemeinsam.licht)));
      });

      test('Seite 3: Aufgaben je Runde im Kasten, Untersuchungsliste mit allen Indizkarten nach Runde und Code (RK 6.5, MECH 3.2)', () {
        final s3 = flach[2];
        final z3 = zeilen(roh[2]);
        for (final a in d().aufgabenJeRunde) {
          final r = k.fall.runden.firstWhere((r) => r.nr == a.runde);
          expect(z3, contains(gm('runde.titel', {'runde': '${r.nr}', 'name': k.text(r.name)})));
          for (final z in k.texte(a.zeilen)) {
            expect(s3, contains(f(z)));
          }
        }
        expect(z3, contains([u('untersuchungsliste.code'), u('untersuchungsliste.titel'), u('untersuchungsliste.abRunde'), u('untersuchungsliste.gewaehlt'), u('untersuchungsliste.keinBund')].join(' ')));
        final karten = k.inhalt.indizkarten.karten;
        expect(karten, hasLength(19));
        final zeileDerKarte = RegExp(r'^([A-Z]{2}\d) (.+) (\d)$');
        final gelesen = [for (final z in z3) if (zeileDerKarte.firstMatch(z) case final m?) (m.group(1)!, m.group(2)!, int.parse(m.group(3)!))];
        final erwartet = ([...karten]..sort((a, b) => a.abRunde != b.abRunde ? a.abRunde - b.abRunde : a.code.compareTo(b.code)))
            .map((c) => (c.code, k.klartext(c.titel), c.abRunde))
            .toList();
        expect(gelesen, erwartet);
        // Die Karten sind nur auf Seite 3 als Liste gedruckt (Runde 1 bis 3).
        expect({for (final c in erwartet) c.$3}, {1, 2, 3});
      });

      test('Seite 4: Raster mit den vier Verdächtigen, Felder unter dem Raster, Hinweise, Regeln 2.3 und 2.4 (MECH 2.1–2.4, RK 6.9)', () {
        final s4 = flach[3];
        final b = d().bogen;
        expect(s4, contains(f(b.hinweis)));
        final namen = [for (final id in b.spalten) k.inhalt.platzVon(id).name];
        expect(namen, ['Ahmet', 'Fatma', 'Olli', 'Can']);
        expect(zeilen(roh[3]), contains(namen.join(' ')));
        for (final z in b.zeilen) {
          expect(s4, contains(f(z.titel)), reason: z.id);
          if (z.zusatz != null) expect(s4, contains(f(z.zusatz!)), reason: z.id);
        }
        expect([for (final z in b.zeilen) z.id], ['ort2357', 'alibi', 'heimlichtuerei', 'ausgeschieden']);
        for (final z in k.texte(b.unterRaster)) {
          expect(s4, contains(f(z)));
        }
        final hinweise = s4.indexOf(f(b.fuehren));
        final entlastung = s4.indexOf(f(b.entlastungsregel));
        final ueberfuehrung = s4.indexOf(f(b.ueberfuehrungsregel));
        expect(hinweise, greaterThan(s4.indexOf(f(k.texte(b.unterRaster).last))));
        expect(entlastung, greaterThan(hinweise), reason: 'RK 6.9: Regeln stehen unter den Hinweisen');
        expect(ueberfuehrung, greaterThan(entlastung));
      });

      test('Seite 5: Vermerke 1 bis 48, zweispaltig (Nr · Runde · Quelle · Vermerk)', () {
        final n = d().vermerkeZeilen;
        expect(n, 48);
        final kopf = [u('vermerke.nr'), u('vermerke.runde'), u('vermerke.quelle'), u('vermerke.vermerk')].join(' ');
        expect(RegExp(RegExp.escape(kopf)).allMatches(kammerFlach(layout[4])), hasLength(2));
        final z5 = zeilen(layout[4]);
        for (var i = 1; i <= n ~/ 2; i++) {
          expect(z5, contains(matches(RegExp('^$i\\s+${i + n ~/ 2}\$'))), reason: 'Zeile $i neben ${i + n ~/ 2}');
        }
      });

      test('Seite 6: Anklagefeld und Hilfe, „Wenn Rollen fehlen“ für heute, Aktionskarten nur der fehlenden Zeugen, Karten gegen dich', () {
        final s6 = flach[5];
        for (final z in k.texte(d().anklageFeld)) {
          expect(s6, contains(f(z)));
        }
        expect(s6, contains(f(d().anklageHilfe)));
        // Alle Zeilen, deren Bereich die heutige Personenzahl enthält, und keine andere (RK 6.12).
        final heute = d().wennRollenFehlenBei(personen);
        expect(heute, isNotEmpty);
        for (final h in d().wennRollenFehlen) {
          final gilt = personen >= h.von && personen <= h.bis;
          expect(heute.contains(h.text), gilt);
          expect(s6.contains(f(h.text)), gilt, reason: '${h.von}–${h.bis}');
        }
        expect(heute.length, switch (personen) { 6 => 2, <= 11 => 1, <= 14 => 1, _ => 2 });
        // Aktionskarten (RK 6.8, MECH 4.6): genau die der fehlenden Zeugen, mit Kartenname und Tipp.
        final fehlend = {for (final p in k.besetzung.fehlendeZeugen) p.id};
        expect(fehlend.length, personen <= 11 ? 12 - personen : 0);
        final s6zeilen = zeilen(roh[5]);
        for (final t in d().aktionskartenTipps) {
          final p = k.fall.plaetze.firstWhere((p) => p.id == t.schluessel);
          final name = k.klartext(k.rolle(p).aktionskarte.name);
          expect(s6.contains(f(t.text)), fehlend.contains(p.id), reason: p.id);
          expect(s6zeilen.contains(name), fehlend.contains(p.id), reason: name);
        }
        expect(s6, contains(f(d().gegenKarten)));
        // Freier Platz wird zu Notizlinien.
        if (personen >= 12) expect(s6zeilen, contains(gm('notizen').toUpperCase()));
      });

      test('kein OFFEN, kein Platzhalter, Lesetext nie unter 9 pt, Druckrand', () async {
        final alles = roh.join('\n');
        expect(alles, isNot(contains('OFFEN')));
        expect(alles, isNot(contains('{')));
        expect(alles, isNot(contains('}')));
        expect(alles, isNot(contains('**')));
        // Kleiner als 9 pt (Wörter unter 9 × 1,209 pt hoch) sind nur Kopf, Fuß und Marken (8,5 pt).
        final klein = <String>{
          for (final t in [
            k.kopfText(k.teilTitel('01')),
            gm('fuss.code', {'code': k.fallCode}),
            for (var s = 1; s <= 6; s++) gm('fuss.seite', {'seite': '$s', 'seiten': '6'}),
            gm('vorlesen').toUpperCase(),
            gm('notizen').toUpperCase(),
            gm('ueberschrift.soSpieltIhr').toUpperCase(),
            u('fuer').toUpperCase(),
          ])
            ...t.split(RegExp(r'\s+')),
        };
        final ws = await woerter(bytes);
        expect(ws, hasLength(6));
        for (final (i, seite) in ws.indexed) {
          for (final w in seite) {
            if (w.hoehe < 9 * bboxJePt - 0.05) expect(klein, contains(w.wort), reason: 'Seite ${i + 1}: „${w.wort}“ ${(w.hoehe / bboxJePt).toStringAsFixed(2)} pt');
          }
        }
        final rand = await kammerRandAbstand(bytes);
        expect(rand!.abstand, greaterThanOrEqualTo(KammerSatz.druckRand), reason: 'Seite ${rand.seite}: ${rand.wort}');
      });
    });
  }

  test('gleiche Eingaben, gleiche Bytes', () async {
    final a = await setze(kammerKontext(9, detektiv: 'm'));
    final b = await setze(kammerKontext(9, detektiv: 'm'));
    expect(a, b);
  });

  group('Überlauf ist nie still', () {
    KammerKontext mit(String datei, void Function(Map<String, Object?> json) aendern, {int personen = 10}) {
      final dateien = leseKammerDateien(repoWurzel);
      final json = jsonDecode(dateien[datei]!) as Map<String, Object?>;
      aendern(json);
      return KammerKontext(KammerInhalt.ausJson({...dateien, datei: jsonEncode(json)}), personen: personen, stil: kammerStil);
    }

    Matcher ueberlauf(int seite) => throwsA(isA<KammerUeberlauf>().having((e) => e.teil, 'teil', '01').having((e) => e.seite, 'seite', seite));
    void setzen(KammerKontext k) => kammerDetektivbogen(kammerStil.neuesDokument('probe'), k);
    String mal(Object? text, int n) => List.filled(n, text! as String).join(' ');

    test('etwas längeres Licht passt noch (dichter Satz), viel längeres läuft auf Seite 2 über', () {
      setzen(mit('gemeinsam.json', (j) => j['licht'] = '${j['licht']} Die Kerzen flackern im Luftzug. Die Schatten an der Wand werden dabei lang und unruhig.'));
      expect(() => setzen(mit('gemeinsam.json', (j) => j['licht'] = mal(j['licht'], 3))), ueberlauf(2));
    });

    test('zu lange Aufgaben je Runde: Seite 3', () {
      final k = mit('detektiv.json', (j) {
        for (final r in (j['aufgabenJeRunde']! as List).cast<Map<String, Object?>>()) {
          r['zeilen'] = [...(r['zeilen']! as List), ...(r['zeilen']! as List)];
        }
      });
      expect(() => setzen(k), ueberlauf(3));
    });

    test('zu lange Hinweise zum Bogen: Raster hätte zu wenig Schreibraum, Seite 4', () {
      expect(() => setzen(mit('detektiv.json', (j) => (j['bogen']! as Map<String, Object?>)['fuehren'] = mal((j['bogen']! as Map)['fuehren'], 3))), ueberlauf(4));
    });

    test('zu viele Vermerke: Zeilen unter 8 mm, Seite 5', () {
      expect(() => setzen(mit('detektiv.json', (j) => j['vermerkeZeilen'] = 120)), ueberlauf(5));
    });

    test('zu lange Tipps bei 6 Personen: Seite 6', () {
      final k = mit('detektiv.json', personen: 6, (j) {
        for (final t in (j['aktionskartenTipps']! as List).cast<Map<String, Object?>>()) {
          t['text'] = mal(t['text'], 4);
        }
      });
      expect(() => setzen(k), ueberlauf(6));
    });
  });
}
