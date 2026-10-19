// F5-BAUMEISTER-01: Erzählerheft (früher Spielleitungsheft, M5) ohne Lösung und Detektivbogen mit
// Ermittlungsbogen (Master 7.14). Geprüft wird das fertige PDF (pdfinfo, pdftotext): Format, Wortlaut
// aus den Bausteinen, Codes, Fragen. M5: Das Heft kennt alle Stichpunkte des Erzählerpakets, die
// Antworten der Befragungen und die Dia-Nummern; der Bogen zeigt nur die Fragen.
import 'dart:math' as math;

import 'package:mordakte_core/mordakte_core.dart' show befragungsZettel;
import 'package:mordakte_core/runden.dart' show botAntwort;
import 'package:mordakte_core/src/party/druck/satz.dart';
import 'package:mordakte_core/src/party/druck/spielleitung.dart';
import 'package:test/test.dart';

import 'druck_hilfe.dart';

/// Die ersten 60 Zeichen eines Bausteins, flach wie der Text aus dem PDF.
String _anfang(String s) {
  final f = flach(s);
  return f.substring(0, math.min(60, f.length));
}

Future<PdfBefund> _heft(DruckKontext k, {bool druckspiel = true}) async {
  final doc = k.stil.neuesDokument('Heft');
  erzaehlerheft(doc, k, druckspiel: druckspiel);
  return pdfPruefen(await doc.save());
}

Future<PdfBefund> _bogen(DruckKontext k) async {
  final doc = k.stil.neuesDokument('Bogen');
  detektivbogen(doc, k);
  return pdfPruefen(await doc.save());
}

int _zaehle(String text, String muster) =>
    RegExp(RegExp.escape(muster)).allMatches(text).length;

void main() {
  late DruckKontext k;
  late String heft;
  late String bogen;

  setUpAll(() async {
    k = druckKontext();
    heft = flach((await _heft(k)).text);
    bogen = flach((await _bogen(k)).text);
  });

  test('beide Teile sind A4 und mehrseitig', () async {
    final h = await _heft(k);
    final b = await _bogen(k);
    expect(h.a4, isTrue);
    expect(b.a4, isTrue);
    expect(h.seiten, greaterThan(1));
    expect(b.seiten, greaterThan(1));
  });

  test('Deckblatt: Falltitel, Baustein, Fall-Code und Personenzahl', () {
    expect(heft, contains(flach(k.fallTitel)));
    expect(heft, contains(_anfang(k.ui('ui.druck.spielleitung.titel'))));
    expect(heft, contains('Fall-Code: ${k.satz.code.code}'));
    expect(heft, contains(flach(k.ui('ui.druck.spielleitung.personen', {'anzahl': '${k.satz.rollen}'}))));
    expect(heft, contains(flach(k.ui('ui.druck.spielleitung.aufloesung'))));
  });

  test('Heft nennt jeden Intro-Baustein und jeden Rundenstart wortgleich', () {
    for (final id in k.satz.spielleitung.intro) {
      expect(heft, contains(_anfang(k.text(id))), reason: id);
    }
    expect(k.satz.spielleitung.rundenStart, hasLength(3));
    for (final id in k.satz.spielleitung.rundenStart.values.expand((l) => l)) {
      expect(heft, contains(_anfang(k.text(id))), reason: id);
    }
  });

  test('E-044: Zum Rundenstart liest das Heft das Wissen unbesetzter Zielfiguren mit Namen vor', () async {
    // 12 Rollen: Azra, Damir und Aylin spielt niemand, Emine und Zeynep sind besetzt.
    final h = k.satz.spielleitung.rundenStart;
    expect(h[1], containsAllInOrder(['runde.1.start', 'npc.dilara.1', 'npc.enes.1']));
    expect(h[1], isNot(contains('npc.emine.1')));
    expect(h[2], contains('npc.dilara.2'));
    expect(h[3], contains('npc.aylin.3'));
    expect(h[3], isNot(contains('npc.zeynep.3')));
    for (final id in ['npc.dilara.1', 'npc.enes.1', 'npc.dilara.2', 'npc.aylin.3']) {
      expect(heft, contains(_anfang(k.text(id))), reason: id);
    }
    // Bei 20 Rollen spielt jemand jede Zielfigur: kein Wort über sie im Heft.
    final voll = druckKontext(n: 20);
    final vollHeft = flach((await _heft(voll)).text);
    for (final id in ['npc.emine.1', 'npc.dilara.1', 'npc.enes.1', 'npc.dilara.2', 'npc.zeynep.3', 'npc.aylin.3']) {
      expect(vollHeft, isNot(contains(_anfang(voll.text(id)))), reason: id);
    }
  });

  test(
    'Heft nennt jede Restmenge mit Namen und Vorlesetext, dazu Resümee, Lage und Anklage',
    () {
      final h = k.satz.spielleitung;
      expect(h.resuemeeRest, hasLength(1 + 4 + 6 + 4));
      for (final e in h.resuemeeRest.entries) {
        final namen = [
          for (final id in e.key.split('_')) k.figurName(id),
        ].join(' · ');
        expect(heft, contains(namen), reason: e.key);
        expect(heft, contains(_anfang(k.text(e.value))), reason: e.value);
      }
      for (final id in h.resuemeeGruppe.values) {
        expect(heft, contains(_anfang(k.text(id))), reason: id);
      }
      for (final lage in h.resuemeeLage.values) {
        for (final id in lage.values) {
          expect(heft, contains(_anfang(k.text(id))), reason: id);
        }
      }
      expect(heft, contains(_anfang(k.text(h.anklage))));
    },
  );

  test(
    'Auszähltabelle: je Runde eine Tabelle, jede Stufe mit Summe und Umschlag-Code',
    () {
      final tabellen = k.satz.spielleitung.auszaehlung;
      expect(tabellen, hasLength(3));
      for (final a in tabellen) {
        expect(a.stufen, isNotEmpty);
        for (final st in a.stufen) {
          expect(
            heft,
            contains(
              k.ui('ui.druck.spielleitung.auszaehlung.ab', {
                'summe': '${st.abSumme}',
              }),
            ),
            reason: 'Runde ${a.runde}',
          );
          expect(k.satz.umschlag(st.umschlag).code, st.umschlag);
          expect(
            heft,
            contains(st.umschlag),
            reason: 'Runde ${a.runde} ${st.umschlag}',
          );
        }
      }
    },
  );

  test(
    'Heft ohne Lösung: keine Finale-, Rückblende- oder Auflösungsbausteine, kein Täterwort',
    () {
      final aufloesung = [
        for (final e in k.satz.aufloesung.finale.values) ...e,
        ...k.satz.aufloesung.rollen,
        ...k.satz.aufloesung.gruppe.values,
      ];
      expect(aufloesung, isNotEmpty);
      for (final id in aufloesung) {
        expect(heft, isNot(contains(_anfang(k.text(id)))), reason: id);
      }
      expect(heft, isNot(contains('Täterfassung')));
      expect(heft, isNot(contains('Täter')));
    },
  );

  test(
    'Bogen: jeder Kartencode steht genau einmal bei seiner Option, jeder Optionstext wortgleich',
    () {
      final optionen = [for (final b in k.satz.detektivbogen) ...b.optionen];
      expect(optionen, isNotEmpty);
      for (final o in optionen) {
        expect(_zaehle(bogen, 'Karte ${o.karte}'), 1, reason: o.karte);
        expect(bogen, contains(flach(o.text)), reason: o.text);
      }
      expect(
        RegExp(r'Karte [A-Z]{2}[3479]').allMatches(bogen),
        hasLength(optionen.length),
      );
    },
  );

  test('Bogen: neun Entscheidungen mit wortgleicher Frage und Punktefeld', () {
    expect(k.satz.detektivbogen, hasLength(9));
    for (final b in k.satz.detektivbogen) {
      expect(bogen, contains(flach(b.frage)), reason: b.id);
    }
    expect(bogen, contains('von 9'));
  });

  test(
    'Ermittlungsbogen: vier Kernpersonen, Faktarten, Regeltexte und Lage-Regel',
    () {
      final eb = k.satz.ermittlungsbogen;
      expect(eb.personen, unorderedEquals(k.kanon.kernverdaechtige));
      for (final p in eb.personen) {
        expect(bogen, contains(k.figurName(p)), reason: p);
      }
      expect(eb.typen, isNotEmpty);
      for (final t in eb.typen) {
        expect(bogen, contains(k.ui('ui.druck.bogen.typ.$t')), reason: t);
      }
      expect(eb.regeln, isNotEmpty);
      for (final r in eb.regeln) {
        expect(bogen, contains(flach(eb.regelText[r.id]!)), reason: r.id);
      }
      expect(bogen, contains(_anfang(k.ui('ui.druck.bogen.lage'))));
    },
  );

  test('Modell befragung: Heft und Bogen nennen je Runde die Befragungen mit ihren Fragen, nur das Heft die Antworten', () {
    for (var r = 1; r <= 3; r++) {
      final br = k.satz.befragungen[r]!;
      final rollen = [...br.pflicht, if (br.freiWahlen > 0) ...br.frei];
      for (final rolle in rollen) {
        final t = br.text(rolle);
        final zeile = flach(k.ui('ui.druck.befragung.zeile', {'name': k.figurName(rolle), 'thema': t.thema}));
        expect(heft, contains(zeile), reason: 'Heft Runde $r: $rolle');
        expect(bogen, contains(zeile), reason: 'Bogen Runde $r: $rolle');
        for (final f in t.fragen) {
          expect(heft, contains(flach(f)), reason: 'Heft Runde $r: $f');
          expect(bogen, contains(flach(f)), reason: 'Bogen Runde $r: $f');
        }
      }
      if (br.freiWahlen > 0) {
        expect(heft, contains(flach(k.ui('ui.druck.spielleitung.befragungen_frei_${br.freiWahlen}'))));
        expect(bogen, contains(flach(k.ui('ui.druck.bogen.befragungen_frei_${br.freiWahlen}'))));
      }
      // Antworten kennt der Erzähler (A-052): im Heft aus dem Erzählerpaket, nie im Bogen des Detektivs.
      final paket = k.satz.erzaehler[r]!;
      expect({for (final b in paket.befragungen) b.rolle}, {...br.pflicht, ...br.frei}, reason: 'Runde $r');
      for (final b in paket.befragungen) {
        expect(b.antwort, botAntwort(k.texte, br.text(b.rolle)), reason: 'Runde $r: ${b.rolle}');
        for (final a in b.antwort) {
          expect(heft, contains(flach(a)), reason: 'Heft Runde $r: Antwort von ${b.rolle}');
        }
      }
      for (final rolle in [...br.pflicht, ...br.frei]) {
        final z = befragungsZettel(k.texte, br.text(rolle));
        for (final a in [...z.sagen, ...z.behaupten, ...z.eigene, ...botAntwort(k.texte, br.text(rolle))]) {
          expect(bogen, isNot(contains(flach(a))), reason: 'Bogen Runde $r: Antwort von $rolle');
        }
      }
    }
    // Marken stehen in Großbuchstaben.
    expect(heft, contains(flach(k.ui('ui.druck.spielleitung.schritt.befragungen')).toUpperCase()));
    expect(heft, isNot(contains(flach(k.ui('ui.druck.spielleitung.schritt.gespraeche')).toUpperCase())));
  });

  test('Erzählerheft: Am Tisch steht jedes Tischgespräch des Erzählerpakets mit Partner, Thema und Stichpunkten', () {
    expect(heft, contains(flach(k.ui('ui.druck.erzaehler.tisch')).toUpperCase()));
    for (var r = 1; r <= 3; r++) {
      final paket = k.satz.erzaehler[r]!;
      expect(paket.tisch, isNotEmpty, reason: 'Runde $r');
      expect(paket.tisch.map((t) => t.sprecher).toSet(), k.satz.besetzt.toSet(), reason: 'Runde $r: jede besetzte Rolle spricht am Tisch');
      for (final t in paket.tisch) {
        final zeile = flach(k.ui('ui.druck.erzaehler.tisch_zeile', {'sprecher': k.figurName(t.sprecher), 'partner': k.figurName(t.partner), 'thema': t.thema}));
        expect(heft, contains(zeile), reason: 'Runde $r: ${t.sprecher}');
        for (final z in t.stichpunkte) {
          expect(heft, contains(flach(z)), reason: 'Runde $r: ${t.sprecher}');
        }
      }
    }
  });

  test('Erzählerheft: jedes Intro-Stück trägt seine Dia-Nummer, der Kasten sagt, dass der Detektiv es nicht liest', () {
    final intro = k.satz.spielleitung.intro;
    expect(intro, hasLength(6), reason: 'Schlosskeller: sechs Dias (A-054)');
    for (var i = 1; i <= intro.length; i++) {
      expect(heft, contains(k.ui('ui.druck.erzaehler.dia', {'nr': '$i'})), reason: 'Dia $i');
    }
    expect(heft, isNot(contains(k.ui('ui.druck.erzaehler.dia', {'nr': '${intro.length + 1}'}))));
    expect(heft, contains(flach(k.ui('ui.druck.erzaehler.nur_du'))));
    expect(bogen, isNot(contains(k.ui('ui.druck.erzaehler.dia', {'nr': '1'}))));
  });

  test('Erzählerheft ohne Druckspiel (Abend am Bildschirm): Vorlesen, Tisch und Befragungen, kein Code, keine Auszählung, keine Anklage', () async {
    final h = await _heft(k, druckspiel: false);
    expect(h.a4, isTrue);
    final text = flach(h.text);
    expect(text, contains(flach(k.ui('ui.druck.erzaehler.app'))));
    expect(text, contains(flach(k.ui('ui.druck.erzaehler.app_rest'))));
    for (final id in [...k.satz.spielleitung.intro, ...k.satz.spielleitung.rundenStart.values.expand((l) => l)]) {
      expect(text, contains(_anfang(k.text(id))), reason: id);
    }
    for (final t in k.satz.erzaehler[2]!.tisch) {
      expect(text, contains(flach(t.stichpunkte.first)), reason: t.sprecher);
    }
    for (final b in k.satz.erzaehler[3]!.befragungen) {
      for (final a in b.antwort) {
        expect(text, contains(flach(a)), reason: b.rolle);
      }
    }
    expect(text, isNot(contains(k.satz.code.code)));
    expect(text, isNot(contains(flach(k.ui('ui.druck.spielleitung.vorbereitung.einleitung')))));
    expect(text, isNot(contains(flach(k.ui('ui.druck.spielleitung.wertseite')))));
    expect(text, isNot(contains(flach(k.ui('ui.druck.spielleitung.anklage.klagt')))));
    expect(text, isNot(contains(flach(k.ui('ui.druck.spielleitung.anhang')))));
    for (final f in k.satz.fassungen) {
      expect(text, isNot(contains(f.code)), reason: f.rolle);
    }
  });

  test(
    'Personenzahl 4 und 20: beide Teile A4 ohne Überlauf, mit Personenzahl und Anhang',
    () async {
      for (final (n, pfad) in [(4, 'can'), (20, 'fatma')]) {
        final kn = druckKontext(pfad: pfad, n: n);
        final h = await _heft(kn);
        final b = await _bogen(kn);
        expect(h.a4, isTrue, reason: 'Heft $n');
        expect(b.a4, isTrue, reason: 'Bogen $n');
        expect(
          flach(h.text),
          contains('$n Rollen und der Detektiv'),
          reason: 'Heft $n',
        );
        expect(
          flach(h.text),
          contains('Anhang: Restmengen'),
          reason: 'Heft $n',
        );
        expect(flach(b.text), contains('von 9'), reason: 'Bogen $n');
      }
    },
  );
}
