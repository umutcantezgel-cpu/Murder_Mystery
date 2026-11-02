// Teil 02 Tisch (MECH 10.1, 10.2, 5, 7.1, 9.7; WELT 2.1–2.8, 4.2, 5.4): Seitenzahl je
// Personenzahl, Blatt A und B quer, der Rest hoch, Abschnitte in Reihenfolge (Lageplan,
// Markerfelder, Positions-Marker, Tipp-Zettel, Abwesenheitsblatt), der Lageplan mit allen
// Zonen, Teilfeldern, Türen und Gegenständen samt Namen (auch dem Schlüsselkasten der
// Stiftung), Legende und Hinweisen, ohne Rollennamen und ohne überdeckte Beschriftung;
// Marker nur für besetzte Rollen, Tipp-Zettel P − 1 Stück wörtlich, Abwesenheitsblatt nur
// bei 6 bis 11 Personen mit den Streifen der fehlenden Zeugen in Platzreihenfolge; Schrift
// nirgends unter 9 pt, nur Joannas Notiz 8 pt (MECH 5.2, Befund R2-11); Druckrand, gleiche
// Bytes und Überlauf mit Stelle.
//
// Personenzahlen: 6 (alle Zeugen fehlen), 9 (letzte mit Joannas Streifen), 10 (Detektiv
// männlich, neun Tipp-Zettel auf drei Blättern), 11 (letztes Abwesenheitsblatt), 12 (ohne
// Abwesenheitsblatt), 13 (Sibel allein), 14 (vier Blätter Tipp-Zettel), 17, 18 (fünf
// Blätter) und 20 (alle Rollen, 40 Marker). Seitenzahl: Lageplan 2 + Marker 1 +
// ⌈(P − 1) / 4⌉ Tipp-Zettel-Blätter + 1 Abwesenheitsblatt bis 11 Personen, also 6 / 6 / 8 bei
// 6 / 12 / 20 Personen wie MECH 10.1.
//
// Schriftgröße: pdftotext -bbox gibt je Wort die Höhe der Schriftzeile (Inter: 1,21 × Größe);
// auf den Tipp-Zettel-Blättern steht der Text um 90° gedreht, dort zählt die Breite.
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:mordakte_core/kammer_io.dart' show leseKammerDateien;
import 'package:mordakte_core/party_druck.dart';
import 'package:test/test.dart';

import '../kanon_hilfe.dart' show repoWurzel;
import 'kammer_druck_hilfe.dart';

/// Personenzahl → Detektiv (`w` oder `m`), Begründung oben.
const faelle = {6: 'w', 9: 'w', 10: 'm', 11: 'w', 12: 'w', 13: 'w', 14: 'w', 17: 'w', 18: 'w', 20: 'w'};

/// Seiten nach MECH 10.1: Lageplan 2, Marker 1, Tipp-Zettel P − 1 zu 4 je Blatt,
/// Abwesenheitsblatt 1 bei 6 bis 11 Personen.
int seitenErwartet(int personen) => 2 + 1 + tippBlaetter(personen) + (personen <= 11 ? 1 : 0);

int tippBlaetter(int personen) => ((personen - 1) / 4).ceil();

/// Höhe einer Textzeile (pt) für eine Schriftgröße in Inter (Auf- plus Unterlänge), mit Spiel.
double zeile(double pt) => pt * 1.21 - 0.2;

/// Satz von Teil 02 in einem eigenen Dokument.
Future<Uint8List> setze(KammerKontext k) async => (await kammerTeilDatei(k, kammerTeil(k, '02'))).bytes;

typedef Wort = ({double x0, double y0, double x1, double y1, String text});

/// Text je Seite in der Reihenfolge des Satzes (pdftotext -raw) und Wörter mit Rahmen (-bbox).
Future<(List<String>, List<List<Wort>>)> lies(Uint8List bytes) async {
  final dir = Directory.systemTemp.createTempSync('kammer_02');
  try {
    final f = File('${dir.path}/satz.pdf')..writeAsBytesSync(bytes);
    final r = await Future.wait([Process.run('pdftotext', ['-raw', f.path, '-']), Process.run('pdftotext', ['-bbox', f.path, '-'])]);
    final roh = (r[0].stdout as String).split('\f');
    if (roh.isNotEmpty && roh.last.trim().isEmpty) roh.removeLast();
    String ent(String s) => s.replaceAll('&amp;', '&').replaceAll('&lt;', '<').replaceAll('&gt;', '>').replaceAll('&quot;', '"');
    final woerter = [
      for (final seite in (r[1].stdout as String).split('<page ').skip(1))
        [
          for (final w in RegExp(r'<word xMin="([\d.]+)" yMin="([\d.]+)" xMax="([\d.]+)" yMax="([\d.]+)">([^<]*)<').allMatches(seite))
            (
              x0: double.parse(w.group(1)!),
              y0: double.parse(w.group(2)!),
              x1: double.parse(w.group(3)!),
              y1: double.parse(w.group(4)!),
              text: ent(w.group(5)!),
            ),
        ],
    ];
    return (roh, woerter);
  } finally {
    dir.deleteSync(recursive: true);
  }
}

/// Wie oft [muster] in [text] vorkommt.
int anzahl(String text, Pattern muster) => muster.allMatches(text).length;

/// Ein Name als ganzes Wort.
RegExp wort(String name) => RegExp('(?<![\\wÄÖÜäöüß])${RegExp.escape(name)}(?![\\wÄÖÜäöüß])');

void main() {
  test('MECH 10.1: 6 / 6 / 8 Seiten bei 6 / 12 / 20 Personen', () {
    expect([for (final p in [6, 12, 20]) seitenErwartet(p)], [6, 6, 8]);
  });

  for (final MapEntry(key: personen, value: detektiv) in faelle.entries) {
    group('$personen Personen, Detektiv $detektiv', () {
      late KammerKontext k;
      late Uint8List bytes;
      late KammerPdf pdf;
      late List<String> roh;
      late List<String> flach;
      late List<List<Wort>> woerter;
      String u(String s, [Map<String, String> w = const {}]) => k.klartext(k.ui('02', s, w));
      final abwesend = personen <= 11;
      // Seiten (ab 0): 0 Blatt A, 1 Blatt B, 2 Marker, 3 … Tipp-Zettel, zuletzt Abwesenheitsblatt.
      final tipp = [for (var i = 0; i < tippBlaetter(personen); i++) 3 + i];
      final abwesenheit = abwesend ? 3 + tippBlaetter(personen) : null;

      setUpAll(() async {
        k = kammerKontext(personen, detektiv: detektiv);
        bytes = await setze(k);
        pdf = kammerPdf(bytes);
        (roh, woerter) = await lies(bytes);
        flach = [for (final s in roh) kammerFlach(s.replaceAll(' ', ' '))];
      });

      test('Seitenzahl nach MECH 10.1, Blatt A und B quer, der Rest hoch', () {
        expect(pdf.seiten, seitenErwartet(personen));
        expect(pdf.formate, ['quer', 'quer', for (var i = 2; i < pdf.seiten; i++) 'hoch']);
        expect(roh, hasLength(pdf.seiten));
      });

      test('Abschnitte in Reihenfolge: Lageplan, Markerfelder, Marker, Tipp-Zettel, Abwesenheitsblatt', () {
        final t = k.inhalt.tisch;
        expect(flach[0], allOf(startsWith(kammerFlach(u('lageplan.titel'))), contains(kammerFlach(u('lageplan.legende')))));
        expect(flach[0], contains(kammerFlach(u('lageplan.blattA.anschluss'))));
        expect(flach[1], allOf(startsWith(kammerFlach(u('lageplan.blattB'))), contains(kammerFlach(u('lageplan.blattB.anschluss')))));
        expect(flach[2], startsWith(kammerFlach(u('marker.titel'))));
        for (final s in tipp) {
          expect(flach[s], contains(kammerFlach(k.klartext(t.tippZettel.titel))), reason: 'Seite ${s + 1}');
        }
        final zeugen = kammerFlach(k.klartext(k.inhalt.streifen.first.etikett).split(' · ').first);
        for (var s = 0; s < pdf.seiten; s++) {
          expect(flach[s].contains(zeugen), s == abwesenheit, reason: 'Seite ${s + 1}');
        }
      });

      test('Lageplan: Titel wörtlich, Zonen mit Namen, Teilfelder, Türen, alle Gegenstände mit Namen, Legende, Hinweise', () {
        final p = k.inhalt.tisch.lageplan;
        final a = flach[0];
        expect(a, startsWith('Lageplan: Gewölbekeller unter dem Schlossturm'));
        for (final z in k.fall.zonen) {
          expect(a, contains(kammerFlach(k.klartext(z.name))), reason: 'Zone ${z.nr}');
          for (final f in z.felder) {
            expect(wort(f).hasMatch(roh[0]), isTrue, reason: 'Feld $f');
          }
        }
        for (final t in p.tueren) {
          expect(a, contains(kammerFlach(k.klartext(t.name))), reason: t.id);
        }
        for (final o in p.gegenstaende) {
          expect(a, contains(kammerFlach(k.klartext(o.name))), reason: o.id);
        }
        expect(a, contains('Schlüsselkasten der Stiftung'));
        expect(a, contains('Eiskübel (vor dem Ostende)'));
        for (final l in p.legende) {
          expect(a, contains(kammerFlach(k.klartext(l.text))), reason: 'Legende ${l.schluessel}');
        }
        for (final h in p.hinweise) {
          expect(a, contains(kammerFlach(k.klartext(h))));
        }
        for (final s in ['lageplan.massstab', 'legende.feldgrenze', 'legende.gegenstand', 'legende.moebel', 'legende.tuer.offen', 'legende.tuer.angelehnt', 'legende.tuer.zu', 'legende.tuer.verschlossen']) {
          expect(a, contains(kammerFlach(u(s))), reason: s);
        }
        // Die Lageplan-Führung (MECH 9.7) nennt die Räume; jeder steht auf dem Plan.
        for (final r in k.fall.raumnamen) {
          expect(a, contains(r), reason: r);
        }
      });

      test('Lageplan und Markerfelder: kein Rollenname, keine Beschriftung überdeckt eine andere', () {
        for (final s in [0, 1]) {
          for (final pl in k.fall.plaetze) {
            expect(wort(pl.name).hasMatch(roh[s]), isFalse, reason: '${pl.name} auf Seite ${s + 1}');
          }
          final w = woerter[s];
          for (var i = 0; i < w.length; i++) {
            for (var j = i + 1; j < w.length; j++) {
              final a = w[i], b = w[j];
              final dx = (a.x1 < b.x1 ? a.x1 : b.x1) - (a.x0 > b.x0 ? a.x0 : b.x0);
              final dy = (a.y1 < b.y1 ? a.y1 : b.y1) - (a.y0 > b.y0 ? a.y0 : b.y0);
              expect(dx > 1 && dy > 1, isFalse, reason: 'Seite ${s + 1}: „${a.text}“ überdeckt „${b.text}“');
            }
          }
        }
      });

      test('Blatt B: alle Felder mit Kennung und Namen wörtlich (WELT 2.1)', () {
        final b = flach[1];
        for (final f in k.fall.felder) {
          expect(b, contains(kammerFlach(k.klartext(f.name))), reason: f.id);
          expect(wort(f.id).hasMatch(roh[1]), isTrue, reason: f.id);
        }
      });

      test('Positions-Marker: zwei je besetzter Rolle, Detektiv und Herr Schneider; fehlende Rollen ohne Marker', () {
        final m = flach[2];
        final besetzt = k.besetzung.besetzt.toSet();
        final platz = RegExp(RegExp.escape(kammerFlach(u('marker.platz', {'platz': '#'}))).replaceAll('#', r'(\d+)') + r'(?!\d)');
        final plaetze = [for (final x in platz.allMatches(m)) int.parse(x.group(1)!)];
        for (final pl in k.fall.plaetze) {
          final n = besetzt.contains(pl) ? 2 : 0;
          expect(anzahl(m, wort(pl.name)), n, reason: pl.name);
          expect(plaetze.where((x) => x == pl.platz), hasLength(n), reason: 'Platz ${pl.platz}');
        }
        expect(anzahl(m, wort(u('marker.detektiv'))), 2);
        expect(u('marker.detektiv'), detektiv == 'w' ? 'Detektivin' : 'Detektiv');
        expect(anzahl(m, u('marker.schneider')), 2);
        final marker = k.besetzung.marker;
        expect(marker, hasLength(2 * besetzt.length + 4));
        expect(marker.length, lessThanOrEqualTo(k.inhalt.tisch.marker.max));
        // Je Marker ein Zeitpunkt, dazu einmal im Hinweis oben.
        for (final z in k.fall.zeitpunkte) {
          expect(anzahl(m, k.klartext(k.uiGemeinsam('zeitpunkt.$z'))), marker.length ~/ 2 + 1, reason: z);
        }
      });

      test('Tipp-Zettel: P − 1 Stück (Rollen und Erzähler), wörtlich nach MECH 7.1', () {
        final t = k.inhalt.tisch.tippZettel;
        final text = [for (final s in tipp) flach[s]].join(' ');
        expect(anzahl(text, k.klartext(t.titel)), personen - 1);
        expect(anzahl(text, kammerFlach(k.klartext(t.fuss))), personen - 1);
        expect(anzahl(text, kammerFlach(k.klartext(t.name))), personen - 1);
        for (final f in t.fragen) {
          final punkte = f.punkte == 1 ? u('tippZettel.punkt') : u('tippZettel.punkte', {'punkte': '${f.punkte}'});
          // Inter hat kein ☐: Der Satz setzt □ (KammerSatz.glyphen).
          expect(anzahl(text, kammerFlach(KammerSatz.glyphen('${k.klartext(f.text)} $punkte'))), personen - 1, reason: 'Frage ${f.nr}');
        }
        // Vier je Blatt, nur das letzte darf weniger tragen.
        for (final (i, s) in tipp.indexed) {
          expect(anzahl(flach[s], k.klartext(t.titel)), i < tipp.length - 1 ? t.jeBlatt : personen - 1 - t.jeBlatt * i, reason: 'Seite ${s + 1}');
        }
      });

      test('Abwesenheitsblatt nur bei 6 bis 11 Personen: Streifen der fehlenden Zeugen in Platzreihenfolge', () {
        final fehlend = k.besetzung.fehlendeZeugen;
        expect(fehlend.isNotEmpty, abwesend);
        if (abwesenheit == null) return;
        final s = flach[abwesenheit];
        var vorher = -1;
        for (final st in k.inhalt.streifen) {
          final fehlt = fehlend.any((p) => p.id == st.zeuge);
          final etikett = kammerFlach(k.klartext(st.etikett));
          expect(s.contains(etikett), fehlt, reason: st.zeuge);
          expect(s.contains(kammerFlach(k.klartext(st.protokoll))), fehlt, reason: '${st.zeuge} Protokoll');
          expect(s.contains(kammerFlach(k.klartext(st.vermerk))), fehlt, reason: '${st.zeuge} Vermerk');
          if (fehlt) {
            expect(s.indexOf(etikett), greaterThan(vorher), reason: 'Reihenfolge ${st.zeuge}');
            vorher = s.indexOf(etikett);
          }
          if (st.mitNotiz) {
            for (final z in k.inhalt.rolle(st.zeuge).notiz!.zeilen) {
              // Gedrehter Text kommt aus pdftotext Wort für Wort: flach vergleichen.
              expect(s.contains(kammerFlach(k.klartext(z))), fehlt, reason: 'Notiz: $z');
            }
          }
        }
      });

      test('Schrift: nirgends unter 9 pt, nur Joannas Notiz 8 pt (MECH 5.2), Falzmarke wie in satz.dart', () {
        final falten = k.klartext(k.uiGemeinsam('falten')).split(' ').toSet();
        final notiz = {
          for (final z in k.inhalt.rolle('joanna').notiz!.zeilen) ...k.klartext(z).split(' '),
        };
        for (var s = 0; s < pdf.seiten; s++) {
          final gedreht = tipp.contains(s);
          for (final w in woerter[s]) {
            final h = gedreht ? w.x1 - w.x0 : w.y1 - w.y0;
            if (h >= zeile(9)) continue;
            final erlaubt = s == abwesenheit && ((notiz.contains(w.text) && h >= zeile(8)) || falten.contains(w.text));
            expect(erlaubt, isTrue, reason: 'Seite ${s + 1}: „${w.text}“ nur ${(h / 1.21).toStringAsFixed(1)} pt');
          }
        }
        if (abwesenheit != null && personen <= 9) {
          // Joannas Notiz steht wirklich in 8 pt (nicht kleiner).
          final notizWoerter = [for (final w in woerter[abwesenheit]) if (w.y1 - w.y0 < zeile(9) && !falten.contains(w.text)) w];
          expect(notizWoerter, isNotEmpty);
          expect(notizWoerter.every((w) => w.y1 - w.y0 >= zeile(8)), isTrue);
        }
      });

      test('Druckrand: Text hält 5 mm Abstand zur Papierkante', () async {
        final r = await kammerRandAbstand(bytes);
        expect(r, isNotNull);
        expect(r!.abstand, greaterThanOrEqualTo(5 * 72 / 25.4 - 0.5), reason: 'Seite ${r.seite}: „${r.wort}“');
      });
    });
  }

  test('gleiche Eingaben, gleiche Bytes', () async {
    for (final p in [6, 20]) {
      final a = await setze(kammerKontext(p));
      final b = await setze(kammerKontext(p));
      expect(a, b, reason: '$p Personen');
    }
  });

  test('Joannas Protokoll (R2-11): gekürzt, mit allen Tatsachen, Kernsatz und Uhrzeit (WELT 5.4, ZG 4.12)', () {
    final p = kammerInhalt.streifenVon('joanna').protokoll;
    for (final teil in [
      'Zeugenprotokoll Joanna, Fotografin des Abends.',
      'Um 23:57 Uhr',
      'in der Tür zum Ost-Saal',
      'wer wo ist',
      'Herr Schneider sagte da zu Olli: „Zweitausend, bis zwölf.“',
      'Im Dunkeln, kurz bevor das Licht wieder anging, hab ich mit der Handylampe die Tafel abgeleuchtet. Der Kopf der Tafel war leer.',
    ]) {
      expect(p, contains(teil));
    }
    // Die Notiz darunter nennt das Gruppenfoto (WELT 5.4).
    expect(kammerInhalt.rolle('joanna').notiz!.zeilen, contains(startsWith('Gruppenfoto')));
  });

  group('Überlauf aus dem Inhalt bricht mit Teil und Stelle ab', () {
    KammerKontext mit(int personen, void Function(Map<String, Object?> j) aendern) {
      final j = <String, Object?>{for (final e in leseKammerDateien(repoWurzel).entries) e.key: jsonDecode(e.value)};
      aendern(j);
      return KammerKontext(KammerInhalt.ausJson(j), personen: personen, stil: kammerStil);
    }

    Map<String, Object?> json(Map<String, Object?> j, String datei) => j[datei]! as Map<String, Object?>;
    String lang(Object? text, int mal) => List.filled(mal, text! as String).join(' ');
    Matcher ueberlaufIn(List<String> wo) => throwsA(isA<KammerUeberlauf>()
        .having((e) => e.teil, 'teil', '02')
        .having((e) => '$e', 'meldung', allOf([contains('Teil 02'), contains('Seite'), for (final w in wo) contains(w)])));

    test('Joannas Streifen: Protokoll doppelt so lang', () {
      final k = mit(6, (j) {
        final st = (json(j, 'abwesenheit.json')['streifen']! as List).cast<Map<String, Object?>>().firstWhere((s) => s['zeuge'] == 'joanna');
        st['protokoll'] = lang(st['protokoll'], 2);
      });
      expect(() => kammerTisch(kammerStil.neuesDokument('probe'), k), ueberlaufIn(['joanna', 'protokoll']));
    });

    test('Abwesenheitsblatt: Schrift unter 9/8 pt im Inhalt', () {
      final k = mit(6, (j) => (json(j, 'tisch.json')['abwesenheitsblatt']! as Map<String, Object?>)['schriftPt'] = 8);
      expect(() => kammerTisch(kammerStil.neuesDokument('probe'), k), ueberlaufIn(['abwesenheitsblatt', '9/8 pt']));
    });

    test('Legende: Text sechsmal so lang', () {
      final k = mit(12, (j) {
        final l = ((json(j, 'tisch.json')['lageplan']! as Map<String, Object?>)['legende']! as List).cast<Map<String, Object?>>().first;
        l['text'] = lang(l['text'], 6);
      });
      expect(() => kammerTisch(kammerStil.neuesDokument('probe'), k), ueberlaufIn(['legende']));
    });

    test('Lageplan: ein Gegenstandsname, für den kein Platz frei ist', () {
      final k = mit(12, (j) {
        final g = ((json(j, 'tisch.json')['lageplan']! as Map<String, Object?>)['gegenstaende']! as List).cast<Map<String, Object?>>();
        final o = g.firstWhere((o) => o['id'] == 'spuele');
        o['name'] = lang(o['name'], 30).replaceAll(' ', '');
      });
      expect(() => kammerTisch(kammerStil.neuesDokument('probe'), k), ueberlaufIn(['lageplan', 'kein freier Platz']));
    });
  });
}
