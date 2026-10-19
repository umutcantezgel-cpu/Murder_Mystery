// F5-BAUMEISTER-02: Rollenhefte, versiegelte Fassungen der Kernrollen und Stimmkarten als PDF
// (Master 7.11, 7.14, G-1). Geprüft wird, was auf dem Papier steht: pdfinfo und pdftotext über die Testhilfe.
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:mordakte_core/mordakte_core.dart' show Gespraech, befragungsZettel;
import 'package:mordakte_core/src/party/druck/rollen.dart';
import 'package:mordakte_core/src/party/druck/satz.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:test/test.dart';

import 'druck_hilfe.dart';

const _heftMarke = 'Erst lesen, wenn du dein Heft in der Hand hast';

/// Setzt einen Teil in ein eigenes Dokument und prüft das fertige PDF.
Future<PdfBefund> _teil(void Function(pw.Document, DruckKontext) teil, DruckKontext k) async {
  final doc = k.stil.neuesDokument('Test');
  teil(doc, k);
  return pdfPruefen(await doc.save());
}

/// Text der Seiten [von] bis [bis] (ohne [bis]), flach.
String _seiten(PdfBefund b, int von, int bis) => flach(b.seitenText.sublist(von, bis).join(' '));

/// Seitennummern (0-basiert) der Deckblätter, eines je besetzter Rolle.
List<int> _deckblaetter(PdfBefund b) => [
      for (var i = 0; i < b.seiten; i++)
        if (flach(b.seitenText[i]).contains(_heftMarke)) i,
    ];

/// Die ersten [n] Zeichen eines Textes, flach.
String _anfang(String s, int n) {
  final f = flach(s);
  return f.substring(0, min(n, f.length));
}

int _zaehle(String text, String muster) => muster.allMatches(text).length;

/// Text je Seite in Zeichenfolge des PDFs (pdftotext -raw): Eine Karte bleibt im Stück, auch neben einer anderen.
List<String> _seitenRoh(Uint8List bytes) {
  final dir = Directory.systemTemp.createTempSync('druck_roh');
  try {
    final f = File('${dir.path}/satz.pdf')..writeAsBytesSync(bytes);
    final text = Process.runSync('pdftotext', ['-raw', f.path, '-']).stdout as String;
    return text.split('\f');
  } finally {
    dir.deleteSync(recursive: true);
  }
}

void main() {
  test('alle drei Teile sind A4 und nicht leer', () async {
    final k = druckKontext(pfad: 'ahmet', n: 12);
    for (final teil in [rollenhefte, fassungen, stimmkarten]) {
      final b = await _teil(teil, k);
      expect(b.a4, isTrue);
      expect(b.seiten, greaterThan(0));
    }
  });

  test('Fassungen: vier Kernrollen mit gleich vielen Seiten, jede beginnt mit ihrem Code', () async {
    final k = druckKontext(pfad: 'fatma', n: 12);
    final b = await _teil(fassungen, k);
    expect(b.seiten % 4, 0);
    final l = b.seiten ~/ 4;
    expect(k.satz.fassungen, hasLength(4));
    for (var i = 0; i < 4; i++) {
      final f = k.satz.fassungen[i];
      expect(b.seitenText[i * l].trim(), startsWith(f.code), reason: f.rolle);
    }
  });

  test('Außenseite zeigt nur Code und neutralen Hinweis, keinen Namen, nie Täter oder Nur für dich (E-035)', () async {
    final k = druckKontext(pfad: 'fatma', n: 12);
    final b = await _teil(fassungen, k);
    final l = b.seiten ~/ 4;
    for (var i = 0; i < 4; i++) {
      final f = k.satz.fassungen[i];
      final aussen = _seiten(b, i * l, i * l + 1);
      expect(aussen, '${f.code} ${flach(k.ui('ui.druck.fassung.aussen'))}', reason: f.rolle);
      for (final p in k.kanon.kernverdaechtige) {
        expect(aussen, isNot(contains(k.figurName(p))), reason: f.rolle);
      }
      expect(aussen, isNot(contains('Nur für dich')), reason: f.rolle);
      expect(aussen, isNot(contains('Du warst es')), reason: f.rolle);
    }
  });

  test('Täterfassung von fatma enthält die Tarnung, die anderen nicht; alle vier haben dieselben Seiten und Überschriften (E-036)', () async {
    final k = druckKontext(pfad: 'fatma', n: 12);
    final b = await _teil(fassungen, k);
    expect(b.seiten, 16, reason: 'vier Fassungen zu je vier Seiten');
    final tarnung = _anfang(k.satz.fassungen.firstWhere((f) => f.rolle == 'fatma').dossier.tarnung!, 50);
    final ueberschriften = [
      for (final u in ['ui.druck.rollen.ziel', 'ui.druck.rollen.weiss', 'ui.druck.rollen.verberge', 'ui.druck.rollen.wahl', 'ui.druck.fassung.notizen']) flach(k.ui(u)),
    ];
    for (var i = 0; i < 4; i++) {
      final f = k.satz.fassungen[i];
      final text = _seiten(b, i * 4, (i + 1) * 4);
      final taeterin = f.rolle == 'fatma';
      expect(text.contains(tarnung), taeterin, reason: f.rolle);
      expect(text, isNot(contains('Nur für dich')), reason: f.rolle);
      // Gleicher Aufbau: Inhalt auf Seite 2, Rundenwahl mit drei Streifen auf Seite 3, Notizen auf Seite 4.
      expect([for (final u in ueberschriften) _zaehle(text, u)], [1, 1, 1, 1, 1], reason: f.rolle);
      expect(_seiten(b, i * 4 + 2, i * 4 + 3), contains(flach(k.ui('ui.druck.rollen.wahl'))), reason: f.rolle);
      // Je Runde ein Streifen A und ein Streifen B (E-039).
      for (var r = 1; r <= 3; r++) {
        for (final c in [f.streifenA[r]!, f.streifen[r]!]) {
          expect(_seiten(b, i * 4 + 2, i * 4 + 3), contains(flach(k.ui('ui.druck.stimme.wert', {'code': c}))), reason: '${f.rolle} Runde $r');
        }
      }
      expect(_seiten(b, i * 4 + 3, i * 4 + 4), contains(flach(k.ui('ui.druck.fassung.notizen'))), reason: f.rolle);
    }
  });

  test('Rollenheft-PDF enthält weder Tarnung noch Täterfassung von fatma', () async {
    final k = druckKontext(pfad: 'fatma', n: 12);
    final b = await _teil(rollenhefte, k);
    final text = flach(b.text);
    final dossier = k.satz.fassungen.firstWhere((f) => f.rolle == 'fatma').dossier;
    expect(text, isNot(contains('Nur für dich: Du warst es')));
    expect(text, isNot(contains('Das erzählst du den anderen')));
    expect(text, isNot(contains(_anfang(dossier.tarnung!, 50))));
    expect(text, isNot(contains(_anfang(dossier.tatwissen.first.text, 40))));
  });

  test('jede besetzte Rolle hat ein Deckblatt mit ihrem Namen', () async {
    final k = druckKontext(pfad: 'ahmet', n: 12);
    final b = await _teil(rollenhefte, k);
    final deck = _deckblaetter(b);
    expect(deck, hasLength(k.satz.besetzt.length));
    for (var j = 0; j < deck.length; j++) {
      expect(flach(b.seitenText[deck[j]]), contains(k.figurName(k.satz.besetzt[j])), reason: k.satz.besetzt[j]);
    }
  });

  test('bei n = 4 erscheinen nur Ahmet, Fatma, Olli und Can', () async {
    final k = druckKontext(pfad: 'olli', n: 4);
    expect({for (final r in k.satz.besetzt) k.figurName(r)}, {'Ahmet', 'Fatma', 'Olli', 'Can'});
    final b = await _teil(rollenhefte, k);
    final deck = _deckblaetter(b);
    expect(deck, hasLength(4));
    for (var j = 0; j < deck.length; j++) {
      expect(flach(b.seitenText[deck[j]]), contains(k.figurName(k.satz.besetzt[j])));
    }
  });

  test('im Heft einer Kernrolle steht nur der Hinweis auf den Umschlag, sonst Was ich weiß', () async {
    final k = druckKontext(pfad: 'ahmet', n: 12);
    final b = await _teil(rollenhefte, k);
    final deck = _deckblaetter(b);
    for (var j = 0; j < deck.length; j++) {
      final ende = j + 1 < deck.length ? deck[j + 1] : b.seiten;
      final rolle = k.satz.besetzt[j];
      final heft = _seiten(b, deck[j], ende);
      final fassung = k.satz.fassungen.where((f) => f.rolle == rolle).toList();
      if (fassung.isEmpty) {
        expect(heft, contains('Was ich weiß'), reason: rolle);
      } else {
        expect(heft, contains('Deine Fassung trägt den Code ${fassung.single.code}'), reason: rolle);
        expect(heft, isNot(contains('Was ich weiß')), reason: rolle);
        expect(heft, isNot(contains('Meine Rundenwahl')), reason: rolle);
      }
    }
  });

  test('Sabotage steht nur in der Täterfassung: Hinweis einmal, heimliche Wahl B in jeder Runde (E-036)', () async {
    final k = druckKontext(pfad: 'fatma', n: 12);
    final b = await _teil(fassungen, k);
    for (var i = 0; i < 4; i++) {
      final f = k.satz.fassungen[i];
      final text = _seiten(b, i * 4, (i + 1) * 4);
      final taeterin = f.rolle == 'fatma';
      expect(_zaehle(text, flach(k.ui('ui.druck.fassung.sabotage'))), taeterin ? 1 : 0, reason: f.rolle);
      for (var r = 1; r <= 3; r++) {
        final w = f.dossier.wahlen[r]!;
        expect(w.sabotage != null, taeterin, reason: '${f.rolle} Runde $r');
        expect(text, contains(_anfang(w.sabotage ?? w.b, 40)), reason: '${f.rolle} Runde $r');
      }
      expect(f.streifenWert, taeterin ? -1 : 0, reason: f.rolle);
    }
  });

  test('Stimmkarten: 8 je Blatt, jeder Kartentext und Wertcode steht im PDF, kein Wert und kein Namensfeld (E-035)', () async {
    final k = druckKontext(pfad: 'ahmet', n: 12);
    final doc = k.stil.neuesDokument('Test');
    stimmkarten(doc, k);
    final bytes = await doc.save();
    final b = pdfPruefen(bytes);
    expect(b.seiten, 6, reason: '48 Karten der acht Gäste zu acht je Blatt (E-039)');
    final seiten = _seitenRoh(bytes);
    final text = flach(seiten.join(' '));
    for (final s in k.satz.stimmkarten) {
      expect(text, contains(_anfang(s.text, 40)), reason: '${s.rolle} Runde ${s.runde} ${s.a ? 'A' : 'B'}');
    }
    // Auf dem Papier steht nur der Code, nie ein Wert: Wer druckt, sieht keine Sabotage.
    for (final s in k.satz.stimmkarten) {
      expect(text, contains(flach(k.ui('ui.druck.stimme.wert', {'code': s.wertCode}))), reason: '${s.rolle} Runde ${s.runde}');
    }
    for (final verboten in ['Wert', '−1', '+1', 'Name']) {
      expect(text, isNot(contains(verboten)), reason: verboten);
    }
    expect(_zaehle(text, 'Code '), 48);
    // Keine offene Karte trägt die Sabotage (E-036), und die Kernrollen haben gar keine (E-039).
    expect(k.satz.stimmkarten.where((s) => s.wert == -1), isEmpty);
    expect(k.satz.stimmkarten.where((s) => k.kanon.kernverdaechtige.contains(s.rolle)), isEmpty);
  });

  test('Bei vier Rollen gibt es keine Stimmkarten, nur ein Blatt mit dem Hinweis (E-039)', () async {
    final k = druckKontext(pfad: 'can', n: 4);
    expect(k.satz.stimmkarten, isEmpty);
    final b = await _teil(stimmkarten, k);
    expect(b.seiten, 1);
    expect(flach(b.text), contains(flach(k.ui('ui.druck.stimme.keine'))));
  });

  test('n = 20 ohne Überlauf, alle Teile A4', () async {
    final k = druckKontext(pfad: 'fatma', n: 20);
    for (final teil in [rollenhefte, fassungen, stimmkarten]) {
      final b = await _teil(teil, k);
      expect(b.a4, isTrue);
    }
    final karten = await _teil(stimmkarten, k);
    expect(karten.seiten, 12, reason: '96 Karten der 16 Gäste zu acht je Blatt');
    expect(_zaehle(flach(karten.text), 'Code '), 96);
    expect(flach(karten.text), isNot(contains('−1')));
  });

  test('Modell befragung: Das Heft zeigt Stichpunkte, wer dich anspricht und was du in der Befragung sagst', () async {
    final k = druckKontext(pfad: 'fatma', n: 7);
    final b = await _teil(rollenhefte, k);
    final deck = _deckblaetter(b);
    final alle = flach(b.text);
    expect(alle, isNot(contains(flach(k.ui('ui.druck.rollen.anfang')))), reason: 'Kein Eröffnungssatz mehr');
    for (var j = 0; j < deck.length; j++) {
      final rolle = k.satz.besetzt[j];
      final heft = _seiten(b, deck[j], j + 1 < deck.length ? deck[j + 1] : b.seiten);
      final d = k.satz.rollenhefte[rolle]!;
      expect(heft, contains(flach(k.ui('ui.druck.rollen.tisch'))), reason: rolle);
      for (var r = 1; r <= 3; r++) {
        for (final (g, _) in d.gespraeche[r]!) {
          for (final p in g.stichpunkte) {
            expect(heft, contains(flach(p)), reason: '$rolle Runde $r: $p');
          }
        }
        for (final (g, sprecher) in d.alsPartner[r] ?? const <(Gespraech, String)>[]) {
          expect(heft, contains(flach(k.ui('ui.druck.befragung.zeile', {'name': k.figurName(sprecher), 'thema': g.thema}))), reason: '$rolle Runde $r');
        }
        final bf = d.befragungen[r]!;
        for (final f in bf.fragen) {
          expect(heft, contains(flach(f)), reason: '$rolle Runde $r: $f');
        }
        final z = befragungsZettel(k.texte, bf);
        for (final x in [...z.sagen, ...z.eigene]) {
          expect(heft, contains(flach(x)), reason: '$rolle Runde $r: $x');
        }
        for (final x in z.behaupten) {
          expect(heft, contains(flach(k.ui('ui.druck.rollen.behaupte', {'text': x}))), reason: '$rolle Runde $r: $x');
        }
        if (z.stichpunkte.isEmpty && z.behaupten.isEmpty) expect(heft, contains(flach(k.ui('ui.druck.rollen.nichts'))));
      }
      expect(_zaehle(heft, flach(k.ui('ui.druck.rollen.befragt'))), 3, reason: rolle);
    }
  });

  // Prüfung M2z: Hanas „Das sagst du“ stand als ein Block mit sieben Stichpunkten im Heft. R17 gilt je Karte,
  // deshalb steht jede Karte (je Preisgabe eine, zuletzt die Würze) in einem eigenen Block.
  test('R17 im Rollenheft: Was du in der Befragung sagst, steht je Karte in einem eigenen Block', () async {
    final k = druckKontext(pfad: 'fatma', n: 12);
    expect(k.satz.besetzt, contains('meryem'));
    final b = await _teil(rollenhefte, k);
    final z = befragungsZettel(k.texte, k.texte.sammlung.befragungen['bf_meryem_1']!);
    expect([for (final x in z.karten) x.zeilen.length], [3, 3, 1]);
    for (var i = 1; i < z.karten.length; i++) {
      final vorher = z.karten[i - 1].zeilen.last, danach = z.karten[i].zeilen.first;
      final getrennt = RegExp('${RegExp.escape(vorher)} *\\n\\s*\\n\\s*– ${RegExp.escape(danach)}');
      expect(getrennt.hasMatch(b.text), isTrue, reason: 'Leerzeile zwischen „$vorher“ und „$danach“');
    }
  });

  test('Täterziel steht nur in der versiegelten Fassung, nie im Rollenheft (E-033)', () async {
    final k = druckKontext(pfad: 'fatma', n: 7);
    final taeterZiel = k.texte.dossier('fatma', 'fatma', 7).ziel;
    final unschuldZiel = k.texte.dossier('fatma', 'ahmet', 7).ziel;
    expect(taeterZiel, isNot(unschuldZiel), reason: 'Kanon: Täterziel unterscheidet sich');
    final dateien = {for (final d in await druckDateien(k)) d.name: d};
    final heft = flach(pdfPruefen(dateien['10-rollenhefte.pdf']!.bytes).text);
    final fassungen = flach(pdfPruefen(dateien['11-fassungen.pdf']!.bytes).text);
    final probe = flach(taeterZiel).substring(0, 40);
    expect(heft.contains(probe), isFalse);
    expect(fassungen.contains(probe), isTrue);
  });
}
