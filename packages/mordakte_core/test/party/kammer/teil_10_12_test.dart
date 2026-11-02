// Teil 10 (Rollenhefte) und Teil 12 (Zusatzhefte) des Kammerspiels (MECH 10.1,
// 10.3, 10.4; RK 1.1, ZG 0.6, ZR 0.7): je Rolle genau vier bzw. drei Seiten A4
// hoch mit eigener Seitenzählung, die Abschnitte in Bibel-Reihenfolge, die vier
// Verdächtigen in gleicher Gestalt (E9: gleiche Seitenumbrüche, gleiche
// Schriftgröße je Seite), nichts unter 9 pt, fehlende Rollen ohne Heft, fehlende
// Ziele nur als Ausweichziel, Tandem-Kasten und Solo-Abschnitt nach Besetzung,
// Teil 12 bei 6 bis 12 Personen nur die Hinweisseite, die Einzeldatei mit dem
// Heft und der Abbildung der eigenen Aktionskarte. Dazu eine Rot-Probe des
// Überlaufschutzes mit einem viel zu langen Text.
//
// Personenzahlen: 6, 12 und 20 (Stützstellen von MECH 10.1), 7 (erster Zeuge),
// 10 (Vorgabe, Joanna mit ihrer Notiz), 13 (Sibel spielt ihr Tandem allein),
// 15 (Hana allein, Sibel mit Damir). Die PDFs prüfen pdfinfo und pdftotext.
// Einzeldateien und Druckrand nur bei 20 (alle achtzehn Rollen; dateien_test.dart
// prüft beides an weiteren Grenzen), die Bytegleichheit bei 13.
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:mordakte_core/kammer_io.dart' show leseKammerDateien;
import 'package:mordakte_core/party_druck.dart';
import 'package:test/test.dart';

import '../kanon_hilfe.dart' show repoWurzel;
import 'kammer_druck_hilfe.dart';

const personenzahlen = [6, 7, 10, 12, 13, 15, 20];

/// Seiten je Heft (MECH 10.1).
int seitenJeHeft(KammerPlatz p) => p.art == KammerArt.zusatz ? 3 : 4;

/// Seiten von Teil 10 und Teil 12 bei 6, 12 und 20 Personen (MECH 10.1).
const mech101 = {
  6: (zehn: 16, zwoelf: 1),
  12: (zehn: 40, zwoelf: 1),
  20: (zehn: 40, zwoelf: 24),
};

/// Die Hefte eines Teils: je besetzter Rolle ihre Seiten in Platzreihenfolge.
Map<KammerPlatz, List<String>> hefte(KammerPdf pdf, List<KammerPlatz> rollen) {
  final aus = <KammerPlatz, List<String>>{};
  var seite = 0;
  for (final p in rollen) {
    aus[p] = pdf.seitenText.sublist(seite, seite + seitenJeHeft(p));
    seite += seitenJeHeft(p);
  }
  return aus;
}

/// Überschriften der Gestalt in Bibel-Reihenfolge, wie sie gedruckt werden
/// (aus ui/gemeinsam.json, ui/10.json, ui/12.json).
List<String> ueberschriften(KammerKontext k, KammerPlatz p) {
  String g(String s) => k.klartext(k.uiGemeinsam(s));
  String u(String teil, String s) => k.klartext(k.ui(teil, s));
  return switch (p.art) {
    KammerArt.verdaechtig => [
        g('heft.deinAuftritt'),
        g('heft.werDuBist'),
        g('ueberschrift.wasAlleWissen'),
        g('ueberschrift.soSpieltIhr'),
        g('heft.deineMarker'),
        u('10', 'stufe1'),
        u('10', 'kernsaetze'),
        g('heft.wennDerErzaehlerFragt'),
        u('10', 'stufe2'),
        u('10', 'gespraechsauftraege'),
        u('10', 'freigabe'),
        g('heft.wasDuBeiDirTraegst'),
        g('heft.deineAktionskarte'),
        u('10', 'fassung'),
      ],
    KammerArt.zeuge => [
        g('heft.deinAuftritt'),
        g('heft.werDuBist'),
        g('heft.deineMarker'),
        g('ueberschrift.wasAlleWissen'),
        g('heft.wasDuWeisst'),
        g('heft.stufe1'),
        g('heft.wennDerErzaehlerFragt'),
        g('heft.stufe2'),
        g('heft.wasDuDannZugibst'),
        g('heft.nachbohrZiele'),
        g('heft.wasDuBeiDirTraegst'),
        g('heft.deineAktionskarte'),
        g('heft.angeklagt'),
        g('ueberschrift.soSpieltIhr'),
      ],
    KammerArt.zusatz => [
        g('heft.deinAuftritt'),
        g('heft.werDuBist'),
        g('heft.deineMarker'),
        g('ueberschrift.wasAlleWissen'),
        g('heft.wasDuWeisst'),
        g('heft.stufe1'),
        g('heft.wennDerErzaehlerFragt'),
        g('heft.stufe2'),
        g('heft.wasDuDannZugibst'),
        u('12', 'gespraechsauftraege'),
        g('heft.deineAktionskarte'),
        g('heft.wasDuBeiDirTraegst'),
        g('heft.angeklagt'),
        g('ueberschrift.soSpieltIhr'),
      ],
  };
}

/// Seite (ab 1) jeder Überschrift in [heft], in der gegebenen Reihenfolge
/// gesucht: eine Überschrift steht allein auf ihrer Zeile. Fehlt eine oder
/// steht sie vor der vorigen: null an ihrer Stelle.
List<int?> seitenDerUeberschriften(List<String> heft, List<String> titel) {
  final zeilen = <(int, String)>[
    for (var s = 0; s < heft.length; s++)
      for (final z in heft[s].split('\n')) (s + 1, kammerFlach(z)),
  ];
  final aus = <int?>[];
  var ab = 0;
  for (final t in titel) {
    final i = zeilen.indexWhere((z) => z.$2 == kammerFlach(t), ab);
    if (i < 0) {
      aus.add(null);
    } else {
      aus.add(zeilen[i].$1);
      ab = i + 1;
    }
  }
  return aus;
}

/// Wortboxen je Seite (pdftotext -bbox): Höhe und oberer Rand.
Future<List<List<({double hoehe, double oben, String wort})>>> woerter(Uint8List bytes) async {
  final dir = Directory.systemTemp.createTempSync('kammer_woerter');
  try {
    final f = File('${dir.path}/satz.pdf')..writeAsBytesSync(bytes);
    final xml = (await Process.run('pdftotext', ['-bbox', f.path, '-'])).stdout as String;
    return [
      for (final seite in xml.split('<page ').skip(1))
        [
          for (final w in RegExp(r'<word xMin="[\d.]+" yMin="([\d.]+)" xMax="[\d.]+" yMax="([\d.]+)">([^<]*)<').allMatches(seite))
            (hoehe: double.parse(w.group(2)!) - double.parse(w.group(1)!), oben: double.parse(w.group(1)!), wort: w.group(3)!),
        ],
    ];
  } finally {
    dir.deleteSync(recursive: true);
  }
}

/// Wortboxen sind so hoch wie die Schrift mal (Oberlänge + Unterlänge) von Inter.
const interHoehe = 1.209;

/// Schriftgröße, die auf einer Seite am häufigsten vorkommt (ohne Kopf und Fuß).
double haeufigsteGroesse(List<({double hoehe, double oben, String wort})> seite) {
  final zaehler = <double, int>{};
  for (final w in seite.where((w) => w.oben > 45 && w.oben < 795)) {
    final g = (w.hoehe / interHoehe * 4).round() / 4;
    zaehler[g] = (zaehler[g] ?? 0) + 1;
  }
  return (zaehler.entries.toList()..sort((a, b) => b.value != a.value ? b.value - a.value : a.key.compareTo(b.key))).first.key;
}

void main() {
  for (final personen in personenzahlen) {
    group('$personen Personen', () {
      late KammerKontext k;
      late KammerBesetzung b;
      late DruckDatei zehn, zwoelf;
      late KammerPdf p10, p12;
      late Map<KammerPlatz, List<String>> h10, h12;

      setUpAll(() async {
        k = kammerKontext(personen);
        b = k.besetzung;
        zehn = await kammerTeilDatei(k, kammerTeil(k, '10'));
        zwoelf = await kammerTeilDatei(k, kammerTeil(k, '12'));
        final pdfs = await kammerPdfs([zehn.bytes, zwoelf.bytes]);
        (p10, p12) = (pdfs[0], pdfs[1]);
        h10 = hefte(p10, b.hauptrollen);
        h12 = b.zusatzrollen.isEmpty ? {} : hefte(p12, b.zusatzrollen);
      });

      test('Seitenzahlen nach MECH 10.1, alle Seiten A4 hoch', () {
        expect(p10.seiten, 4 * b.hauptrollen.length);
        expect(p12.seiten, b.zusatzrollen.isEmpty ? 1 : 3 * b.zusatzrollen.length);
        if (mech101[personen] case final m?) {
          expect(p10.seiten, m.zehn);
          expect(p12.seiten, m.zwoelf);
        }
        expect(p10.formate, everyElement('hoch'));
        expect(p12.formate, everyElement('hoch'));
      });

      test('jedes Heft zählt seine Seiten selbst, Kopf mit Titel der Rolle', () {
        final fuss = RegExp(RegExp.escape(kammerFlach(k.uiGemeinsam('fuss.seite', {'seite': '#S#', 'seiten': '#N#'})))
            .replaceAll('#S#', r'(\d+)')
            .replaceAll('#N#', r'(\d+)'));
        for (final e in {...h10, ...h12}.entries) {
          final p = e.key;
          final n = seitenJeHeft(p);
          for (var s = 0; s < n; s++) {
            final m = fuss.firstMatch(kammerFlach(e.value[s]));
            expect(m, isNotNull, reason: '${p.name} Seite ${s + 1}');
            expect((int.parse(m!.group(1)!), int.parse(m.group(2)!)), (s + 1, n), reason: '${p.name} Seite ${s + 1}');
          }
          final kopf = p.art == KammerArt.zusatz
              ? k.ui('12', 'kopf', {'name': p.name, 'platz': '${p.platz}', 'tandem': '${p.tandem}'})
              : k.ui('10', 'kopf', {'name': p.name, 'platz': '${p.platz}'});
          expect(kammerFlach(e.value.first), contains(kammerFlach(k.klartext(kopf))), reason: p.name);
        }
      });

      test('nur die besetzten Rollen haben ein Heft, in Platzreihenfolge', () {
        String kopf(KammerPlatz p) => kammerFlach(k.klartext(p.art == KammerArt.zusatz
            ? k.ui('12', 'kopf', {'name': p.name, 'platz': '${p.platz}', 'tandem': '${p.tandem}'})
            : k.ui('10', 'kopf', {'name': p.name, 'platz': '${p.platz}'})));
        final alle = kammerFlach('${p10.text} ${p12.text}');
        for (final p in k.fall.plaetze) {
          expect(alle.contains(kopf(p)), b.istBesetzt(p.id), reason: p.name);
        }
        if (b.zusatzrollen.isEmpty) {
          // MECH 10.1: bei 6 bis 12 Personen nur die Hinweisseite, wörtlich.
          expect(kammerFlach(p12.text), contains(kammerFlach(k.ui('12', 'hinweisseite'))));
          expect(kammerFlach(k.ui('12', 'hinweisseite')), 'Heute ohne Zusatzrollen. Zusatzrollen gibt es ab dreizehn Personen.');
        }
      });

      test('Abschnitte in Bibel-Reihenfolge (RK 1.1, ZG 0.6, ZR 0.7)', () {
        for (final e in {...h10, ...h12}.entries) {
          final titel = ueberschriften(k, e.key);
          final seiten = seitenDerUeberschriften(e.value, titel);
          for (var i = 0; i < titel.length; i++) {
            expect(seiten[i], isNotNull, reason: '${e.key.name}: „${titel[i]}“ fehlt oder steht nicht in Reihenfolge');
          }
          // Auftritt auf Seite 1; Was du bei dir trägst und Aktionskarte auf der letzten Seite (Rollenhefte).
          expect(seiten.first, 1, reason: e.key.name);
          if (e.key.art != KammerArt.zusatz) {
            expect(seiten[titel.indexOf(k.klartext(k.uiGemeinsam('heft.wasDuBeiDirTraegst')))], 4, reason: e.key.name);
          }
          // Besetzungshinweis unten auf der letzten Seite, sonst nirgends (RK 1.1, ZG G-13, ZR 0.7).
          final hinweis = kammerFlach(k.klartext(k.uiGemeinsam('besetzungshinweis', {'name': e.key.name})));
          for (var s = 0; s < e.value.length; s++) {
            expect(kammerFlach(e.value[s]).contains(hinweis), s == e.value.length - 1, reason: '${e.key.name} Seite ${s + 1}');
          }
          // Notizen auf der letzten Seite der Rollenhefte 1–10 (RK 1.1, ZG 0.6).
          if (e.key.art != KammerArt.zusatz) {
            expect(e.value.last.toUpperCase(), contains(k.klartext(k.uiGemeinsam('notizen')).toUpperCase()), reason: e.key.name);
          }
        }
      });

      test('E9: die vier Verdächtigen in gleicher Gestalt (gleiche Seiten, gleiche Schrift)', () async {
        final verdaechtige = b.verdaechtige;
        expect(verdaechtige, hasLength(4));
        final titel = ueberschriften(k, verdaechtige.first);
        final seiten = [for (final p in verdaechtige) seitenDerUeberschriften(h10[p]!, titel)];
        for (var i = 1; i < 4; i++) {
          expect(seiten[i], seiten.first, reason: '${verdaechtige[i].name} bricht anders um als ${verdaechtige.first.name}');
        }
        final w = await woerter(zehn.bytes);
        for (var s = 0; s < 4; s++) {
          final groessen = [for (var i = 0; i < 4; i++) haeufigsteGroesse(w[4 * i + s])];
          expect(groessen.toSet(), hasLength(1), reason: 'Seite ${s + 1}: $groessen');
        }
      });

      test('keine Schrift unter 9 pt (außer Kopf und Fuß)', () async {
        for (final d in [zehn, if (b.zusatzrollen.isNotEmpty) zwoelf]) {
          final w = await woerter(d.bytes);
          for (var s = 0; s < w.length; s++) {
            for (final x in w[s].where((x) => x.oben > 45 && x.oben < 795)) {
              expect(x.hoehe / interHoehe, greaterThanOrEqualTo(KammerSatz.kleinsteGroesse - 0.05), reason: '${d.name} Seite ${s + 1}: „${x.wort}“');
            }
          }
        }
      });

      test('fehlende Ziele: nur das Ausweichziel, ohne den Namen (RK 1.2, ZG 0.2)', () {
        for (final e in {...h10, ...h12}.entries) {
          final text = kammerFlach(e.value.join(' '));
          for (final a in k.rolle(e.key).gespraechsauftraege) {
            final ziel = k.inhalt.platzVon(a.ziel);
            final kopf = '${k.klartext(k.uiGemeinsam('heft.ziel', {'nr': '${a.nr}'}))} · ${ziel.name}';
            if (b.istBesetzt(a.ziel)) {
              expect(text, contains(kopf), reason: '${e.key.name} → ${ziel.name}');
              expect(text, contains(kammerFlach(k.klartext(a.frage))), reason: '${e.key.name} → ${ziel.name}');
            } else {
              expect(text, isNot(contains(kopf)), reason: '${e.key.name} → ${ziel.name}');
              expect(text, contains(kammerFlach(k.klartext(a.ausweich!))), reason: '${e.key.name} → Ausweichziel für ${ziel.name}');
            }
          }
        }
      });

      test('Tandem-Kasten bei allen Zusatzrollen, Solo-Abschnitt nur beim kleineren Platz, der allein spielt', () {
        for (final e in h12.entries) {
          final r = k.rolle(e.key);
          final seite1 = kammerFlach(e.value.first);
          expect(seite1, contains(kammerFlach(k.klartext(k.ui('12', 'deinTandem')))), reason: e.key.name);
          // Der Kasten steht in der Fassung dieser Besetzung (Ersatz, wenn der Partner fehlt; ZR 1.12).
          expect(seite1, contains(kammerFlach(k.klartext(r.tandemKasten!)).substring(0, 40)), reason: e.key.name);
          final solo = r.solo == null ? null : kammerFlach(k.klartext(r.solo!));
          if (solo != null) {
            expect(kammerFlach(e.value.join(' ')).contains(solo), b.solo == e.key, reason: e.key.name);
          }
        }
        switch (personen) {
          case 13:
            expect(b.solo?.id, 'sibel');
          case 15:
            expect(b.solo?.id, 'hana');
          case 20 || 12:
            expect(b.solo, isNull);
        }
      });

      test('Joanna mit ihrer Notiz; Tugba ohne leere Überschriften', () {
        final joanna = k.inhalt.platzVon('joanna');
        if (b.istBesetzt('joanna')) {
          final text = kammerFlach(h10[joanna]!.join(' '));
          expect(text, contains(kammerFlach(k.klartext(k.ui('10', 'notiz')))));
          expect(text, contains(kammerFlach(k.klartext(k.rolle(joanna).notiz!.hinweis))));
        }
        final tugba = k.inhalt.platzVon('tugba');
        if (b.istBesetzt('tugba')) {
          final heft = h12[tugba]!;
          final zeilen = [for (final s in heft) ...s.split('\n').map(kammerFlach)];
          for (final leer in ['heft.behaeltstDuFuerDich', 'heft.verboten']) {
            expect(zeilen, isNot(contains(kammerFlach(k.klartext(k.uiGemeinsam(leer))))), reason: leer);
          }
          // ZR 8.6: die Einleitung steht ohne eigene Überschrift gleich unter „Stufe 1“.
          final i = zeilen.indexOf(kammerFlach(k.klartext(k.uiGemeinsam('heft.stufe1'))));
          expect(i, greaterThanOrEqualTo(0));
          expect(kammerFlach(zeilen.skip(i + 1).take(3).join(' ')), startsWith(kammerFlach(k.klartext(k.rolle(tugba).stufe1.regie!)).substring(0, 30)));
        }
      });

      if (personen == 20) {
        test('Einzeldatei: Heft mit eigener Seitenzählung, danach die eigene Aktionskarte (MECH 10.3)', () async {
          final dateien = await kammerEinzeldateien(k);
          final pdfs = await kammerPdfs([for (final d in dateien) d.bytes]);
          for (var i = 0; i < dateien.length; i++) {
            final p = b.besetzt[i];
            final teil = p.art == KammerArt.zusatz ? '12' : '10';
            expect(dateien[i].name, k.ui(teil, 'dateiEinzeln', {'figur': dateiWort(p.name)}));
            expect(dateien[i].name, isNot(startsWith('90')));
            expect(pdfs[i].seiten, seitenJeHeft(p) + 1, reason: dateien[i].name);
            expect(pdfs[i].formate, everyElement('hoch'), reason: dateien[i].name);
            // Das Heft ist dasselbe wie in Teil 10 bzw. 12.
            final heft = (p.art == KammerArt.zusatz ? h12 : h10)[p]!;
            expect(pdfs[i].seitenText.take(seitenJeHeft(p)).toList(), heft, reason: dateien[i].name);
            expect(kammerFlach(pdfs[i].seitenText.last), contains(kammerFlach(k.klartext(k.rolle(p).aktionskarte.name))), reason: dateien[i].name);
          }
        });

        test('Druckrand: kein Text näher als 5 mm an der Papierkante', () async {
          for (final d in [zehn, zwoelf]) {
            final a = await kammerRandAbstand(d.bytes);
            if (a == null) continue;
            expect(a.abstand, greaterThanOrEqualTo(KammerSatz.druckRand - 0.5 * KammerSatz.mm), reason: '${d.name} Seite ${a.seite}: „${a.wort}“');
          }
        });

      }

      if (personen == 13) {
        test('gleiche Eingaben, gleiche Bytes', () async {
          final k2 = kammerKontext(personen);
          expect((await kammerTeilDatei(k2, kammerTeil(k2, '12'))).bytes, zwoelf.bytes);
        });
      }
    });
  }

  group('Fehler', () {
    test('Heft einer heute nicht besetzten Rolle oder der falschen Gestalt: ArgumentError', () {
      final k = kammerKontext(6);
      final doc = kammerStil.neuesDokument('probe');
      expect(() => kammerRollenheft(doc, k, k.inhalt.platzVon('lejla')), throwsArgumentError);
      expect(() => kammerRollenheft(doc, k, k.inhalt.platzVon('sibel')), throwsArgumentError);
      expect(() => kammerZusatzheft(doc, k, k.inhalt.platzVon('ahmet')), throwsArgumentError);
    });

    test('Rot-Probe: ein viel zu langer Text ist ein Überlauf mit Teil, Seite und Rolle, nie still', () {
      final dateien = leseKammerDateien(repoWurzel);
      final datei = k10Datei(dateien, 'ahmet');
      final rolle = jsonDecode(dateien[datei]!) as Map<String, Object?>;
      final stufe2 = rolle['stufe2']! as Map<String, Object?>;
      stufe2['wasDuVerbirgst'] = List.filled(12, stufe2['wasDuVerbirgst']! as String).join(' ');
      dateien[datei] = jsonEncode(rolle);
      final k = KammerKontext(KammerInhalt.ausJson(dateien), personen: 10, stil: kammerStil);
      expect(
        () => kammerRollenhefte(kammerStil.neuesDokument('probe'), k),
        throwsA(isA<KammerUeberlauf>()
            .having((e) => e.teil, 'teil', '10')
            .having((e) => e.seite, 'seite', inInclusiveRange(1, 4))
            .having((e) => '$e', 'meldung', allOf(contains('Teil 10'), contains('Ahmet'), contains('9.0pt')))),
      );
    });
  });
}

/// Pfad der Rollendatei von [id] in den Inhaltsdateien.
String k10Datei(Map<String, String> dateien, String id) => dateien.keys.singleWhere((d) => d.startsWith('rollen/') && d.endsWith('-$id.json'));
