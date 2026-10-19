// F3-BAUMEISTER-01: Textprüfer (Sätze, Fachwörter, Verbote, Vorlesezeichen), Mittelwert und Quellen.
import 'dart:io';

import 'package:mordakte_core/mordakte_core.dart';
import 'package:test/test.dart';

import 'kanon_hilfe.dart';

Map<String, Object?> _regeln() => leseJson('$repoWurzel/content/party/textregeln.json');

Textpruefer _pruefer() => Textpruefer(_regeln());

TextQuelle _q(String text, {bool vorlesen = false}) => TextQuelle(ort: 'probe.json#x', text: text, vorlesen: vorlesen);

/// Die Regeln, die ein Text verletzt (leer heißt grün).
List<String> _regelnVon(String text, {bool vorlesen = false}) => [for (final b in _pruefer().pruefe(_q(text, vorlesen: vorlesen))) b.regel];

/// Eine Wortfolge aus großgeschriebenen Wörtern, damit Satzgrenzen greifen.
String _wortfolge(int n) => List.filled(n, 'Wort').join(' ');

String _tonLeitfaden() => File('$repoWurzel/planung/finalisierung-schlosskeller/TON-LEITFADEN.md').readAsStringSync();

/// Probe-Sammlung: jede Textdatei des Index bekommt je einen Eintrag ihres Bereichs.
Textsammlung _probeSammlung(Map<String, Object?> index) {
  final bereiche = {for (final d in index['dateien'] as List) 'texte/${(d as Map)['datei']}': d['bereich'] as String};
  var n = 0;
  return Textsammlung.lade((p) {
    if (p == 'texte/index.json') return index;
    final bereich = bereiche[p]!;
    n++;
    return {'bereich': bereich, 'eintraege': _probeEintraege(bereich, n)};
  });
}

List<Map<String, Object?>> _probeEintraege(String bereich, int n) => switch (bereich) {
      'erzaehler' => [
          {'id': 'probe.$n', 'text': 'Es ist kalt.'},
        ],
      'detektiv' => [
          {'id': 'detektiv.probe$n', 'text': 'Du sitzt.'},
        ],
      'ui' => [
          {'id': 'ui.probe$n', 'text': 'Weiter.'},
        ],
      'dossier' => [
          {
            'rolle': 'probe$n',
            'wer': 'Du bist da.',
            'ziel': 'Ein Ziel.',
            'besetzung': 'Frei.',
            'weiss': [
              {'text': 'Ein Wissen.'},
            ],
            'verbirgt': [
              {'text': 'Ein Geheimnis.'},
            ],
          },
        ],
      'taeter' => [
          {
            'rolle': 'probe$n',
            'tarnung': 'Eine Tarnung.',
            'ziel': 'Ein Ziel.',
            'tatwissen': [
              {'text': 'Die Tat.'},
            ],
            'verbirgt': <Map<String, Object?>>[],
          },
        ],
      'gespraech' => [
          {
            'id': 'g_probe${n}_1_1',
            'rolle': 'probe$n',
            'runde': 1,
            'nr': 1,
            'partner': 'detective',
            'thema': 'Ein Thema.',
            'ziel': 'Ein Ziel.',
            'text': 'Ein Text.',
            'preisgabe': <String>[],
          },
        ],
      'befragung' => [
          {
            'id': 'bf_probe${n}_1',
            'rolle': 'probe$n',
            'runde': 1,
            'thema': 'Ein Thema.',
            'fragen': ['Wo warst du?', 'Was hast du gesehen?'],
            'stichpunkte': ['Ich war da.'],
            'preisgabe': <String>[],
          },
        ],
      _ => [
          {'id': 'gw_probe$n', 'a': 'Option a.', 'b': 'Option b.', 'sabotage': null},
        ],
    };

void main() {
  group('Satztrennung (§4)', () {
    test('Abkürzungen, Initialen und Ordnungszahlen trennen nicht', () {
      final p = _pruefer();
      expect(p.saetze('Das kostet ca. zehn Euro. Gut.'), hasLength(2));
      expect(p.saetze('Bring z. B. Tee mit. Danke.'), hasLength(2));
      expect(p.saetze('Nr. Fünf steht im Weg. Danke.'), hasLength(2));
      expect(p.saetze('Am 3. Mai ist Schluss. Dann Ruhe.'), hasLength(2));
    });

    test('Anführungszeichen gehören zum Satz', () {
      expect(_pruefer().saetze('„Nein.“ Er lacht.'), ['„Nein.“', 'Er lacht.']);
    });

    test('Auslassungspunkte trennen nur vor einem Großbuchstaben', () {
      expect(_pruefer().saetze('Ich weiß nicht … vielleicht gar nicht.'), hasLength(1));
      expect(_pruefer().saetze('Hm... Gut.'), hasLength(2));
    });

    test('ein Text ohne Satzzeichen am Ende ist ein Satz', () {
      expect(_pruefer().saetze('Kein Punkt am Ende'), ['Kein Punkt am Ende']);
    });
  });

  group('Satzlänge und Mittelwert (§4)', () {
    test('Wörter zählen, Bindestrich verbindet', () {
      expect(_pruefer().woerter('Der alte Schlüssel liegt im Kaminsaal.'), 6);
      expect(_pruefer().woerter('Die E-Zigarette liegt da.'), 4);
    });

    test('mehr als 25 Wörter melden, 25 Wörter nicht', () {
      expect(_regelnVon('${_wortfolge(25)}.'), isNot(contains('Satzlänge')));
      expect(_regelnVon('${_wortfolge(26)}.'), contains('Satzlänge'));
    });

    test('Mittel über 14 Wörter je Satz meldet den Bereich, 14 nicht', () {
      final p = _pruefer();
      expect(p.pruefeMittel('texte/probe.json', [_q('${_wortfolge(15)}.')]), hasLength(1));
      expect(p.pruefeMittel('texte/probe.json', [_q('${_wortfolge(15)}. ${_wortfolge(13)}.')]), isEmpty);
      expect(p.pruefeMittel('texte/probe.json', [_q('${_wortfolge(14)}.')]), isEmpty);
    });
  });

  group('Fachwörter (§5)', () {
    test('Fachwörter melden mit Ersatz, ohne Groß- und Kleinschreibung', () {
      expect(_regelnVon('Die Schanktheke ist voll.'), ['Fachwort, Ersatz: Buffettheke']);
      expect(_regelnVon('Ein SAMOWAR steht da.'), ['Fachwort, Ersatz: großer Teekocher']);
      expect(_regelnVon('Das Red Herring war falsch.'), ['Fachwort, Ersatz: falsche Fährte']);
      expect(_regelnVon('Die Smoking Gun liegt im Tresor.'), ['Fachwort, Ersatz: Schlüsselbeweis']);
      expect(_regelnVon('Ein Chafing-Dish auf dem Buffet.'), ['Fachwort, Ersatz: Warmhaltebehälter']);
      expect(_regelnVon('Er handelte im Affekt.'), ['Fachwort, Ersatz: in Panik']);
      expect(_regelnVon('Der Kautionsumschlag liegt da.'), ['Fachwort, Ersatz: Umschlag mit dem Mietgeld']);
    });

    test('ähnliche Wörter sind kein Fachwort', () {
      expect(_regelnVon('Die Buffettheke ist voll.'), isEmpty);
      expect(_regelnVon('Das Tresorfach ist leer.'), isEmpty);
    });
  });

  group('Alkohol (§6)', () {
    test('Alkoholwörter melden auch als Wortanfang', () {
      expect(_regelnVon('Es gibt Bier.'), ['Alkohol']);
      expect(_regelnVon('Der Bierkasten steht da.'), ['Alkohol']);
      expect(_regelnVon('Er trinkt Glühwein.'), ['Alkohol']);
      expect(_regelnVon('Er ist betrunken.'), ['Alkohol']);
      expect(_regelnVon('Ein Barbetrieb wäre schön.'), ['Alkohol']);
      expect(_regelnVon('Ein Fass steht da.'), ['Alkohol']);
      expect(_regelnVon('Prost!'), ['Alkohol']);
    });

    test('Ausnahmen: alkoholfrei, Bargeld, weinen, Baran; Weinrot und Bordeaux sind Alkohol (E-028)', () {
      expect(_regelnVon('Apfelpunsch, alkoholfrei, ist der Renner.'), isEmpty);
      expect(_regelnVon('Am Ärmel des weinroten Mantels klebt Farbe.'), ['Alkohol']);
      expect(_regelnVon('Sie trägt ein Jackett in Bordeaux.'), ['Alkohol']);
      expect(_regelnVon('Herr Schneider will 2.000 € Bargeld.'), isEmpty);
      expect(_regelnVon('Sie fängt an zu weinen.'), isEmpty);
      expect(_regelnVon('Baran steht am Fenster.'), isEmpty);
      expect(_regelnVon('Die Fassade ist alt.'), isEmpty);
    });

    test('Kater nur als Katze erlaubt', () {
      expect(_regelnVon('Er hat einen Kater.'), ['Alkohol']);
      expect(_regelnVon('Die Katze und der Kater schlafen.'), isEmpty);
    });
  });

  group('Drogen und Rauchen (§6)', () {
    test('Drogen und Rauchen nur als ganzes Wort', () {
      expect(_regelnVon('Ein Joint liegt auf dem Tisch.'), ['Drogen']);
      expect(_regelnVon('Er kifft im Flur.'), ['Drogen']);
      expect(_regelnVon('Die Drogerie hat zu.'), isEmpty);
      expect(_regelnVon('Er raucht auf dem Flur.'), ['Rauchen']);
      expect(_regelnVon('Die E-Zigarette liegt da.'), ['Rauchen']);
      expect(_regelnVon('Eine Shisha steht da.'), ['Rauchen']);
      expect(_regelnVon('Er dampft im Flur.'), ['Rauchen']);
    });

    test('Rauch und Qualm nur im Kamin', () {
      expect(_regelnVon('Qualm im Kaminsaal.'), isEmpty);
      expect(_regelnVon('Der Rauch aus dem Kamin zieht ab.'), isEmpty);
      expect(_regelnVon('Dichter Qualm im Keller.'), ['Rauchen']);
      expect(_regelnVon('Rauch über dem Buffet.'), ['Rauchen']);
    });

    test('die Kamin-Ausnahme gilt nicht für das Rauchen selbst', () {
      expect(_regelnVon('Im Kamin wird nicht geraucht.'), ['Rauchen']);
    });
  });

  group('Vorlesetext (§4)', () {
    test('Abkürzungen, Klammern und Ziffern nur im Vorlesetext', () {
      expect(_regelnVon('Es ist ca. zehn Uhr.', vorlesen: true), ['Abkürzung (nur Vorlesen)']);
      expect(_regelnVon('Es ist ca. zehn Uhr.'), isEmpty);
      expect(_regelnVon('Die Tür (quietscht) knarrt.', vorlesen: true), ['Klammer (nur Vorlesen)', 'Klammer (nur Vorlesen)']);
      expect(_regelnVon('Es ist 23:58 Uhr.', vorlesen: true), ['Ziffer (nur Vorlesen)', 'Ziffer (nur Vorlesen)']);
      expect(_regelnVon('Es ist zwei vor zwölf.', vorlesen: true), isEmpty);
      expect(_regelnVon('Es kostet 2.000 € Bargeld.'), isEmpty);
    });

    test('z. B., Nr., usw. und bzw. sind Abkürzungen', () {
      for (final a in ['z. B.', 'Nr. 3', 'usw.', 'bzw.']) {
        expect(_regelnVon('Es gibt Tee, $a Kaffee.', vorlesen: true), contains('Abkürzung (nur Vorlesen)'), reason: a);
      }
    });
  });

  group('Quellen (textQuellen)', () {
    test('textQuellen deckt jede Textdatei des Index ab (38 aus F3, 8 Oberflächendateien aus F4, 3 Druckdateien aus F5, 1 Gästewissen aus F5, 3 Befragungen aus M2a, 1 Befragungs-Oberfläche aus M2b, 1 Gästewissen der Zielfiguren aus E-044)', () {
      final index = leseJson('$repoWurzel/content/party/schlosskeller/texte/index.json');
      final dateien = [for (final d in index['dateien'] as List) 'texte/${(d as Map)['datei']}'];
      expect(dateien, hasLength(55));
      final quellen = textQuellen(kanon, _probeSammlung(index));
      final orte = {for (final q in quellen) q.ort.split('#').first};
      expect(orte.where((o) => o.startsWith('texte/')), unorderedEquals(dateien));
    });

    test('vorgelesen werden nur Erzähler und Bonus-Hinweise (E-029)', () {
      final index = leseJson('$repoWurzel/content/party/schlosskeller/texte/index.json');
      final quellen = textQuellen(kanon, _probeSammlung(index));
      // Erzähler-Dateien heißen erzaehler-*.json (Bereich erzaehler); ui-erzaehler.json ist Oberfläche.
      bool gesprochen(TextQuelle q) => q.ort.startsWith('texte/erzaehler-') || q.ort.startsWith('bonus.json#');
      final erzaehler = quellen.where(gesprochen);
      expect(erzaehler, isNotEmpty);
      expect(erzaehler.every((q) => q.vorlesen), isTrue);
      expect(quellen.where((q) => !gesprochen(q)).any((q) => q.vorlesen), isFalse);
    });

    test('textQuellen erfasst jede genannte Kanon-Feldart als Lesetext', () {
      final index = leseJson('$repoWurzel/content/party/schlosskeller/texte/index.json');
      final kanonQuellen = textQuellen(kanon, _probeSammlung(index)).where((q) => !q.ort.startsWith('texte/')).toList();
      const arten = [
        'beobachtungen.json#',
        'gegenstaende.json#spur',
        '.zeigt',
        '.harmlos',
        'entscheidungen.json#',
        '.frage',
        '.begruendung.',
        'bonus.json#',
        'zeitleiste.json#',
        '.behauptung',
        '.wahrheit',
        'gegenstaende.json#nd_',
        '.alltag',
        '.persoenlichesZiel',
        'setting.json#',
      ];
      for (final a in arten) {
        expect(kanonQuellen.any((q) => q.ort.contains(a)), isTrue, reason: 'Kanon-Feldart $a fehlt');
      }
      expect(kanonQuellen.where((q) => !q.ort.startsWith('bonus.json#')).any((q) => q.vorlesen), isFalse);
    });
  });

  group('Schnittstelle: textregeln.json (§5, §6)', () {
    test('die Fachwortliste aus TON-LEITFADEN §5 steht vollständig in textregeln.json', () {
      final zeilen = _tonLeitfaden().split('\n');
      final anfang = zeilen.indexWhere((z) => z.startsWith('## 5.'));
      final ende = zeilen.indexWhere((z) => z.startsWith('## 6.'));
      final fach = {for (final k in (_regeln()['fachwoerter'] as Map).keys) k as String};
      final fehlend = <String>[];
      for (final zeile in zeilen.sublist(anfang, ende)) {
        if (!zeile.startsWith('| ') || zeile.startsWith('| Nicht') || zeile.startsWith('|---')) continue;
        for (final wort in zeile.split('|')[1].split(',')) {
          var w = wort.trim().toLowerCase();
          if (w.startsWith('im ')) w = w.substring(3);
          if (!fach.contains(w)) fehlend.add(w);
        }
      }
      expect(fehlend, isEmpty);
    });

    test('die Alkoholliste aus TON-LEITFADEN §6 steht vollständig in textregeln.json', () {
      final zeile = _tonLeitfaden().split('\n').firstWhere((z) => z.contains('Verboten sind'));
      final teil = zeile.substring(zeile.indexOf('Verboten sind') + 'Verboten sind'.length).replaceAll(RegExp(r'\(.*?\)'), '').replaceAll('.', '');
      final alkohol = [
        for (final w in teil.split(',')) if (w.trim().isNotEmpty) w.trim().toLowerCase(),
      ];
      expect(alkohol, hasLength(12));
      final liste = [for (final w in (_regeln()['verboten'] as Map)['alkohol'] as List) w as String];
      expect(liste, containsAll(alkohol));
    });

    test('Rauchen, Drogen und Ausnahmen aus §6 sind eingetragen', () {
      final verboten = _regeln()['verboten'] as Map;
      expect(verboten['rauchen'] as List, containsAll(['e-zigarette', 'zigarette', 'dampfen', 'shisha', 'rauch', 'qualm']));
      expect(verboten['drogen'] as List, containsAll(['rauschmittel', 'joint', 'kiffen', 'drogen']));
      final ausnahmen = [for (final a in _regeln()['ausnahmen'] as List) a as String];
      expect(ausnahmen, containsAll(['bargeld', 'alkoholfrei', 'kater:katze', 'rauch:kamin', 'qualm:kamin']));
    });
  });
}
