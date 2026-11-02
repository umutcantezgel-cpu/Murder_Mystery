// Teil 00 Erzählerheft (MECH 9, 10.1, 10.5, 1.1–1.5, E10): Seitenzahl je Personenzahl,
// A4 hoch, Seitenplan nach MECH 9.1 mit „Was alle wissen“ immer auf Seite 7 (der Text
// `fassungenOeffnen` nennt sie), Abschnitte in Reihenfolge, Vorstellungsrunde nach MECH 9.4
// (besetzte Rollen in Spielreihenfolge mit Rollenbezeichnung, fehlende fehlen, Lacher nur
// für fehlende Zusatzrollen), Vorlesen und Anleitung gekennzeichnet, besetzungsabhängige
// Teile (Zeugenstreifen und „Karten unter den Streifen“ bis 11, kleine Runden bis 8,
// Gegenüberstellung ab 14, sieben Minuten ab 18), keine Fassungscodes (E10), Druckrand,
// gleiche Bytes, Überlauf mit Teil und Seite.
//
// Seitenzahl: MECH 10.1 nennt 15 / 16 / 17 bei 6 / 12 / 20 Personen. Mit „Was alle wissen“
// fest auf Seite 7 (MECH 9.1, 9.6) kann die Vorstellungsrunde die Seitenzahl nicht mehr
// ändern (sie füllt immer die Seiten 5 und 6), und MECH 9.14 legt „Karten unter den
// Streifen“ bei 6 bis 11 Personen auf Seite 16. Das Heft hat darum bei jeder Besetzung die
// 16 Seiten des Seitenplans MECH 9.1 (Abweichung von MECH 10.1 bei 6 und 20 gemeldet).
//
// Personenzahlen: die Stufen 6 (alle Zeugen fehlen, kleine Runden), 8 (letzte kleine Runde),
// 10 (Detektiv männlich), 11 (letzter Zeugenstreifen), 12 (alle Hauptrollen, beide Lacher),
// 13 (Sibel allein, Hana-Lacher), 14 (Gegenüberstellung), 18 (sieben Minuten) und 20 (alle
// Rollen, kein Abschluss). Der Text kommt über pdftotext -raw (Reihenfolge des Satzes).
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:mordakte_core/kammer_io.dart' show leseKammerDateien;
import 'package:mordakte_core/party_druck.dart';
import 'package:test/test.dart';

import '../kanon_hilfe.dart' show repoWurzel;
import 'kammer_druck_hilfe.dart';

/// Seiten des Erzählerhefts je Personenzahl (Seitenplan MECH 9.1, Begründung oben).
const seitenErwartet = 16;

/// Personenzahl → Detektiv (`w` oder `m`), Begründung oben.
const faelle = {6: 'w', 8: 'w', 10: 'm', 11: 'w', 12: 'w', 13: 'w', 14: 'w', 18: 'w', 20: 'w'};

/// Text je Seite in der Reihenfolge des Satzes (pdftotext -raw).
Future<List<String>> rohSeiten(Uint8List bytes) async {
  final dir = Directory.systemTemp.createTempSync('kammer_00');
  try {
    final f = File('${dir.path}/satz.pdf')..writeAsBytesSync(bytes);
    final text = (await Process.run('pdftotext', ['-raw', f.path, '-'])).stdout as String;
    final seiten = text.split('\f');
    if (seiten.isNotEmpty && seiten.last.trim().isEmpty) seiten.removeLast();
    return seiten;
  } finally {
    dir.deleteSync(recursive: true);
  }
}

/// Satz eines Teils 00 in einem eigenen Dokument.
Future<Uint8List> setze(KammerKontext k) async => (await kammerTeilDatei(k, kammerTeil(k, '00'))).bytes;

/// Nummer der ersten Seite ab [ab], auf der [zeile] als eigene Zeile steht (Überschrift), sonst null.
int? seiteMitZeile(List<String> seiten, String zeile, {int ab = 2}) {
  for (var i = ab - 1; i < seiten.length; i++) {
    if (seiten[i].split('\n').map((z) => z.trim()).contains(zeile)) return i + 1;
  }
  return null;
}

void main() {
  for (final MapEntry(key: personen, value: detektiv) in faelle.entries) {
    group('$personen Personen, Detektiv $detektiv', () {
      late KammerKontext k;
      late KammerPdf pdf;
      late List<String> roh;
      late List<String> flach;
      late Uint8List bytes;
      String u(String s, [Map<String, String> w = const {}]) => k.klartext(k.ui('00', s, w));

      setUpAll(() async {
        k = kammerKontext(personen, detektiv: detektiv);
        bytes = await setze(k);
        pdf = kammerPdf(bytes);
        roh = await rohSeiten(bytes);
        flach = [for (final s in roh) kammerFlach(s)];
      });

      test('Seitenzahl nach dem Seitenplan, jede Seite A4 hoch, Fuß zählt im Teil', () {
        expect(pdf.seiten, seitenErwartet);
        expect(roh, hasLength(seitenErwartet));
        expect(pdf.formate, everyElement('hoch'));
        for (var s = 1; s <= pdf.seiten; s++) {
          expect(flach[s - 1], contains(kammerFlach(k.uiGemeinsam('fuss.seite', {'seite': '$s', 'seiten': '$seitenErwartet'}))));
        }
      });

      test('Abschnitte auf den Seiten des Seitenplans (MECH 9.1), in Reihenfolge', () {
        final runde = [for (final r in k.fall.runden) k.klartext(k.uiGemeinsam('runde.titel', {'runde': '${r.nr}', 'name': k.text(r.name)}))];
        final plan = <(String, int)>[
          (u('vorbereitung'), 2),
          (u('ablauf'), 3),
          (u('rundenaufbau'), 3),
          (u('soLaeuftDerAbend'), 4),
          (u('vorgeschichte'), 4),
          (u('vorstellung'), 5),
          (u('tatMoment'), 6),
          (u('auftrag'), 6),
          (u('fassungenOeffnen'), 7),
          (k.klartext(k.uiGemeinsam('ueberschrift.wasAlleWissen')), kammerErzaehlerheftSeiteWasAlleWissen),
          (u('lageplanFuehrung'), 8),
          (runde[0], 9),
          (u('impulse.regeln'), 10),
          (runde[1], 11),
          (runde[2], 12),
          (u('bonusZiel'), 13),
          (u('tippRunde'), 13),
          (u('anklage'), 13),
          (k.klartext(k.uiGemeinsam('ueberschrift.tischregeln')), 14),
          (u('herrSchneider'), 15),
          (u('masstabelle'), 15),
          (u('skalierung'), 16),
          if (k.besetzung.abwesenheitsblatt) (u('kartenUnterStreifen'), 16),
        ];
        for (final (titel, seite) in plan) {
          expect(seiteMitZeile(roh, titel), seite, reason: titel);
        }
        // Das Inhaltsverzeichnis auf dem Deckblatt nennt dieselben Seiten.
        for (final (titel, seite) in plan.where((p) => p.$1 != u('rundenaufbau') && p.$1 != u('auftrag'))) {
          expect(flach[0], contains('$titel ${u('inhalt.seite', {'seite': '$seite'})}'), reason: titel);
        }
        if (!k.besetzung.abwesenheitsblatt) expect(seiteMitZeile(roh, u('kartenUnterStreifen'), ab: 1), isNull);
      });

      test('„Was alle wissen“ ganz auf Seite 7, wie `fassungenOeffnen` sagt (MECH 9.6, 1.5)', () {
        const s = kammerErzaehlerheftSeiteWasAlleWissen;
        expect(s, 7);
        final e = k.inhalt.erzaehlerheft;
        final fassungen = kammerFlach(k.klartext(e.fassungenOeffnen, werte: {'seite': '$s'}));
        expect(fassungen, contains('Seite $s'));
        expect(flach[s - 1], contains(fassungen));
        for (final z in k.texte(k.inhalt.gemeinsam.wasAlleWissen)) {
          expect(flach[s - 1], contains(kammerFlach(k.klartext(z))));
        }
        // Ab 13 Personen trägt die Zeile „18:00 Uhr“ die Dankeskarte (MECH 1.5).
        expect(flach[s - 1].contains('Dankeskarte'), personen >= k.fall.schwellen.dankeskarteAb);
      });

      test('Vorstellungsrunde (MECH 9.4): besetzte Rollen in Spielreihenfolge, dann der Detektiv', () {
        final b = k.besetzung;
        final v = k.inhalt.erzaehlerheft.vorstellung;
        final text = kammerFlach('${roh[4]}\n${roh[5]}');
        var pos = text.indexOf(kammerFlach(k.klartext(v.start)));
        expect(pos, greaterThan(0));
        for (final p in b.besetzt) {
          final wer = u('vorstellung.rolle', {'name': p.name, 'titel': k.text(p.bezeichnung)});
          final frage = kammerFlach(k.klartext(k.rolle(p).frage));
          final a = text.indexOf(wer, pos);
          expect(a, greaterThan(pos), reason: wer);
          expect(text.indexOf(frage, a), greaterThan(a), reason: p.name);
          pos = text.indexOf(frage, a);
        }
        for (final p in k.fall.plaetze.where((p) => !b.istBesetzt(p.id))) {
          expect(text, isNot(contains(u('vorstellung.rolle', {'name': p.name, 'titel': k.text(p.bezeichnung)}))), reason: p.name);
          expect(text, isNot(contains(kammerFlach(k.klartext(k.rolle(p).frage)))), reason: p.name);
        }
        final detektivFrage = text.indexOf(kammerFlach(k.klartext(v.frageDetektiv)));
        expect(text.indexOf(u('vorstellung.detektiv')), greaterThan(pos));
        expect(detektivFrage, greaterThan(pos));
        // Lacher nur für fehlende Rollen (Sibel, Hana), nach dem Detektiv.
        for (final l in v.lacherFehlend) {
          final i = text.indexOf(kammerFlach(k.klartext(l.text)));
          expect(i >= 0, !b.istBesetzt(l.schluessel), reason: l.schluessel);
          if (i >= 0) expect(i, greaterThan(detektivFrage));
        }
        // Der Abschluss gilt Gästen ohne Spieler: nur, wenn eine Rolle fehlt.
        expect(text.contains(kammerFlach(k.klartext(v.abschluss))), b.rollen < k.fall.plaetze.length);
        // Der Tat-Moment beginnt auf Seite 6, der Auftrag in der Fassung des Detektivs.
        expect(flach[5], contains(kammerFlach(k.klartext(k.inhalt.erzaehlerheft.auftrag))));
        expect(flach[5], contains(detektiv == 'm' ? 'auch noch der Detektiv' : 'auch noch die Detektivin'));
        expect(text, contains(detektiv == 'm' ? 'Zum Schluss: der Detektiv' : 'Zum Schluss: die Detektivin'));
      });

      test('Vorlesen und Anleitung gekennzeichnet (Lageplan-Führung nach Besetzung)', () {
        final vorlesen = k.klartext(k.uiGemeinsam('vorlesen')).toUpperCase();
        final anleitung = k.klartext(k.uiGemeinsam('anleitung')).toUpperCase();
        int zahl(String seite, String marke) => seite.split('\n').where((z) => z.trim() == marke).length;
        // Seite 4: „So läuft der Abend“ und Vorgeschichte, beide Vorlesen.
        expect(zahl(roh[3], vorlesen), 2);
        expect(zahl(roh[3], anleitung), 0);
        // Seite 8: je Schritt eine Marke; die Schritte mit Zeugenstreifen nur bis 11 Personen.
        final schritte = [
          for (final f in k.inhalt.erzaehlerheft.lageplanFuehrung)
            if (!f.nurMitStreifen || k.besetzung.abwesenheitsblatt) f,
        ];
        expect(zahl(roh[7], vorlesen), schritte.where((f) => f.vorlesen).length);
        expect(zahl(roh[7], anleitung), schritte.where((f) => !f.vorlesen).length);
        for (final f in k.inhalt.erzaehlerheft.lageplanFuehrung) {
          expect(flach[7].contains(kammerFlach(k.klartext(f.text))), !f.nurMitStreifen || k.besetzung.abwesenheitsblatt);
        }
        // Seite 5: Anleitung zur Vorstellungsrunde, dann Vorlesen.
        expect(zahl(roh[4], anleitung), 1);
        expect(zahl(roh[4], vorlesen), greaterThanOrEqualTo(2));
      });

      test('besetzungsabhängig: kleine Runden, Gegenüberstellung, Skalierung, Bonus-Ziel', () {
        final b = k.besetzung;
        final e = k.inhalt.erzaehlerheft;
        expect(flach[2].contains(kammerFlach(k.klartext(e.kleineRunden))), b.abschnittBKurz);
        final gegen = kammerFlach(k.klartext(e.gegenueberstellung));
        expect(flach[10].contains(gegen), b.gegenueberstellung, reason: 'Runde 2');
        expect(flach[11].contains(gegen), b.gegenueberstellung, reason: 'Runde 3');
        if (b.gegenueberstellung) {
          expect(flach[10], contains(kammerFlach(k.klartext(e.gegenueberstellungRegel))));
          expect(gegen.contains('sieben Minuten'), personen >= k.fall.schwellen.gegenueberstellungLangAb);
        }
        expect(flach[15], contains(u('skalierung.heute', {'personen': '$personen'})));
        final hinweis = e.skalierungsHinweis(personen);
        expect(flach[15], contains(kammerFlach(k.klartext(hinweis == null || k.leer(hinweis) ? k.ui('00', 'skalierung.keinHinweis') : hinweis))));
        final karten = (b.rollen * 3 / 4).ceil();
        expect(flach[12], contains(u('bonusZiel.heute', {'rollen': '${b.rollen}', 'karten': '$karten'})));
        for (final p in b.besetzt) {
          expect(roh[12].split('\n').map((z) => z.trim()), contains(startsWith(p.name)), reason: p.name);
        }
      });

      test('Karten unter den Streifen (MECH 9.14): nur fehlende Zeugen, nur bis 11 Personen', () {
        final b = k.besetzung;
        final e = k.inhalt.erzaehlerheft;
        for (final p in k.fall.plaetze.where((p) => p.art == KammerArt.zeuge)) {
          final zeile = kammerFlach(k.klartext(e.kartenUnterStreifenMuster, werte: {'name': p.name, 'codes': '#', 'runde': '#'})).split('#').first;
          expect(flach[15].contains(zeile), b.fehlendeZeugen.contains(p), reason: p.name);
          if (b.fehlendeZeugen.contains(p)) {
            for (final c in k.rolle(p).geheimniskarte.pflichtCodes) {
              expect(flach[15], contains(c), reason: '${p.name} $c');
            }
          }
        }
      });

      test('keine Lösung (E10): kein Fassungscode, kein offener Platzhalter; Druckrand hält 5 mm', () async {
        for (final c in k.fall.fassungsCodes) {
          expect(pdf.text, isNot(contains(c)), reason: c);
        }
        expect(pdf.text, isNot(contains('{')));
        expect(pdf.text, isNot(contains('}')));
        final rand = await kammerRandAbstand(bytes);
        expect(rand!.abstand, greaterThanOrEqualTo(KammerSatz.druckRand - 0.01), reason: '${rand.seite} ${rand.wort}');
      });
    });
  }

  test('gleiche Eingaben ergeben gleiche Bytes', () async {
    final a = await setze(kammerKontext(11));
    final b = await setze(kammerKontext(11));
    expect(a, b);
  });

  group('Überlauf ist nie still', () {
    KammerInhalt mit(String datei, void Function(Map<String, Object?> json) aendern) {
      final dateien = leseKammerDateien(repoWurzel);
      final json = jsonDecode(dateien[datei]!) as Map<String, Object?>;
      aendern(json);
      return KammerInhalt.ausJson({...dateien, datei: jsonEncode(json)});
    }

    Matcher ueberlauf(int seite) => throwsA(isA<KammerUeberlauf>().having((e) => e.teil, 'teil', '00').having((e) => e.seite, 'seite', seite));

    test('zu lange Vorgeschichte: Seite 4', () {
      final inhalt = mit('erzaehlerheft.json', (j) => j['vorgeschichte'] = '${j['vorgeschichte']}\n\n${j['vorgeschichte']}');
      final k = KammerKontext(inhalt, personen: 10, stil: kammerStil);
      expect(() => kammerErzaehlerheft(kammerStil.neuesDokument('probe'), k), ueberlauf(4));
    });

    test('zu lange Vorstellungsfrage bei 20 Personen: Seite 6 läuft über, „Was alle wissen“ bliebe nicht auf Seite 7', () {
      final inhalt = mit('rollen/18-tugba.json', (j) {
        final v = j['vorstellung']! as Map<String, Object?>;
        v['frage'] = List.filled(8, v['frage']).join(' ');
      });
      final k = KammerKontext(inhalt, personen: 20, stil: kammerStil);
      expect(() => kammerErzaehlerheft(kammerStil.neuesDokument('probe'), k), ueberlauf(kammerErzaehlerheftSeiteWasAlleWissen - 1));
    });

    test('zu lange Tischregeln: auch in 9 pt nicht auf einer Seite', () {
      final inhalt = mit('gemeinsam.json', (j) {
        for (final r in (j['tischregeln']! as List).cast<Map<String, Object?>>()) {
          r['text'] = List.filled(6, 'Alle dürfen jeden fragen, solange das Heft es erlaubt.').join(' ');
        }
      });
      final k = KammerKontext(inhalt, personen: 10, stil: kammerStil);
      expect(() => kammerErzaehlerheft(kammerStil.neuesDokument('probe'), k), throwsA(isA<KammerUeberlauf>().having((e) => e.teil, 'teil', '00')));
    });
  });
}
