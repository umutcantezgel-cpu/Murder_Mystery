// M4: Diashow zur Einleitung. Die Datei der Akte besteht den Prüfer; jede
// Regel hat eine Gegenprobe, die genau einen Befund auslöst.
import 'dart:convert';

import 'package:mordakte_core/mordakte_core.dart';
import 'package:test/test.dart';

import 'kanon_hilfe.dart';

final _texte = Texte(kanon, Textsammlung.lade((p) => leseJson('$repoWurzel/content/party/schlosskeller/$p')));
final _roh = leseJson('$repoWurzel/content/welt/schlosskeller/diashow.json');

/// Kopie der Datei mit einer Änderung am Bild [nr] (null: an der ganzen Datei).
Map<String, Object?> _mit(void Function(Map<String, Object?> j, Map<String, Object?> dia) aendern, {int nr = 0}) {
  final j = (jsonDecode(jsonEncode(_roh)) as Map).cast<String, Object?>();
  final dia = ((j['dias'] as List)[nr] as Map).cast<String, Object?>();
  aendern(j, dia);
  return j;
}

String? _text(String k) => _texte.sammlung.bausteine[k];

List<String> _befunde(Map<String, Object?> j) => pruefeDiashow(Diashow.ausJson(j), kanon, _text);

void main() {
  final schema = SchemaPruefer(leseJson('$repoWurzel/content/welt/diashow.schema.json'));

  test('Die Diashow des Schlosskellers erfüllt Schema und Prüfer', () {
    expect(schema.pruefe(_roh), isEmpty);
    final d = Diashow.ausJson(_roh);
    expect(d.akte, 'schlosskeller');
    expect(d.dias, hasLength(6), reason: 'sechs Abschnitte des Intros (K1: Start, Ausfall, drei Lacher, Auftrag)');
    expect(pruefeDiashow(d, kanon, _text), isEmpty);
  });

  test('Jedes Bild gehört zu genau einem Abschnitt des Intros, in seiner Reihenfolge', () {
    final d = Diashow.ausJson(_roh);
    final abschnitte = Erzaehler(kanon).introAbschnitte;
    expect([for (final x in d.dias) x.baustein], [for (final a in abschnitte) a.basis]);
    // Jede Fassung, die der Abend lesen kann, findet ihr Bild.
    for (final (i, a) in abschnitte.indexed) {
      for (final f in a.fassungen) {
        expect(d.nrFuer(f), i, reason: f);
      }
    }
    expect(d.nrFuer('runde.1.start'), isNull);
    // Das Intro eines Abends ist genau die Folge der Bilder (jede Besetzung, beide Detektive).
    for (final detektiv in ['m', 'w']) {
      for (final n in [4, 7, 12]) {
        final s = Spiel(kanon)..einrichten(Einstellungen(rollen: n, detektiv: detektiv, code: FallCode.fuerPfad('ahmet', kanon.pfade)));
        expect([for (final k in Erzaehler(kanon).intro(s)) d.nrFuer(k)], [for (var i = 0; i < d.dias.length; i++) i]);
      }
    }
  });

  test('Akten ohne introTeile haben weniger Abschnitte, aber dieselbe Form', () {
    final g = ladeKanon('gewoelbe');
    final basen = [for (final a in Erzaehler(g).introAbschnitte) a.basis];
    expect(basen.first, 'intro.start');
    expect(basen.last, 'intro.auftrag');
    expect(basen.where((b) => b.startsWith('intro.lacher.')), hasLength(4));
  });

  group('Gegenproben', () {
    test('Zahl der Bilder', () {
      final j = _mit((j, _) => j['dias'] = (j['dias'] as List).take(2).toList());
      expect(_befunde(j), contains(contains('2 Bilder')));
    });

    test('Unbekannter, doppelter und fehlender Abschnitt, falsche Reihenfolge', () {
      expect(_befunde(_mit((_, d) => d['baustein'] = 'intro.vorspiel')), containsAll([contains('kein Abschnitt'), contains('intro.start hat kein Bild')]));
      expect(_befunde(_mit((_, d) => d['baustein'] = 'intro.ausfall')), containsAll([contains('intro.ausfall hat 2 Bilder'), contains('intro.start hat kein Bild')]));
      final getauscht = _mit((j, _) {
        final l = j['dias'] as List;
        final a = l[2];
        l[2] = l[3];
        l[3] = a;
      });
      expect(_befunde(getauscht), [contains('Reihenfolge')]);
    });

    test('Wortzahl je Fassung', () {
      // Eine Fassung zu lang, eine zu kurz, eine fehlt.
      final lang = List.filled(70, 'Wort').join(' ');
      String? text(String k) => switch (k) {
            'intro.auftrag.w' => lang,
            'intro.start' => 'Ein Schloss.',
            'intro.ausfall' => null,
            _ => _text(k),
          };
      expect(pruefeDiashow(Diashow.ausJson(_roh), kanon, text), containsAll([
        contains('intro.start hat 2 Wörter'),
        contains('intro.ausfall fehlt'),
        contains('intro.auftrag.w hat 70 Wörter'),
      ]));
    });

    test('Kamera: genau ein Ziel, bekannt, Zoom im Rahmen', () {
      expect(_befunde(_mit((_, d) => (d['kamera'] as Map)['raum'] = 'thekensaal')), [contains('genau einen Ort oder einen Raum')]);
      expect(_befunde(_mit((_, d) => (d['kamera'] as Map)['ort'] = 'mondbasis')), [contains('Ort mondbasis')]);
      expect(_befunde(_mit((_, d) => (d['kamera'] as Map)['zoom'] = 3)), [contains('Zoom 3')]);
    });

    test('Figuren: bekannt, einmal, höchstens vier, nur das Opfer liegt', () {
      expect(_befunde(_mit((_, d) => (d['figuren'] as List).add('gespenst'))), containsAll([contains('Figur gespenst'), contains('5 Figuren')]));
      expect(_befunde(_mit((_, d) => d['figuren'] = ['tugba', 'tugba'])), [contains('doppelt')]);
      expect(_befunde(_mit((_, d) => d['liegt'] = ['tugba'])), [contains('liegen darf nur das Opfer')]);
      expect(_befunde(_mit((_, d) => d['figuren'] = ['tugba'], nr: 1)), [contains('schneider liegt, steht aber nicht im Bild')]);
    });

    test('Notlicht (M7b): nur mit Figuren im Bild; Schema kennt die Stimmung, unbekannte nicht', () {
      expect(Diashow.ausJson(_roh).dias[1].stimmung, DiaStimmung.notlicht, reason: 'Bild 2: Herr Schneider im Vorratsraum');
      expect(Diashow.ausJson(_roh).dias[5].stimmung, DiaStimmung.stromausfall, reason: 'Bild 6 bleibt im Dunkel');
      expect(_befunde(_mit((_, d) => d..['figuren'] = <String>[]..['liegt'] = <String>[], nr: 1)), [contains('Notlicht ohne Figur')]);
      expect(_befunde(_mit((_, d) => d..['figuren'] = <String>[]..['liegt'] = <String>[]..['stimmung'] = 'stromausfall', nr: 1)), isEmpty);
      final falsch = _mit((_, d) => d['stimmung'] = 'flutlicht', nr: 1);
      expect(schema.pruefe(falsch), isNotEmpty);
      expect(() => Diashow.ausJson(falsch), throwsFormatException);
    });

    test('R15: Sperrort, Ziel-Raum und pfadabhängige Spur nur, wenn der Baustein sie nennt', () {
      // Der Jackenständer ist Fundort und Ziel-Ort; das Intro nennt den Ostsaal nicht.
      expect(_befunde(_mit((_, d) => (d['kamera'] as Map)['ort'] = 'am_jackenstaender')), [contains('Sperrort')]);
      // Den Ostsaal sucht eine Entscheidung ab.
      expect(_befunde(_mit((_, d) => d['kamera'] = {'raum': 'ost_saal', 'zoom': 1, 'fahrt': 'ruhig'})), [contains('Ziel-Raum')]);
      // Vor der Vorratsraumtür liegt der Kerzenständer; der Ort gehört zum Buffetsaal, den der Ausfall nicht nennt.
      expect(_befunde(_mit((_, d) => (d['kamera'] as Map)['ort'] = 'vor_vorratstuer', nr: 1)), [contains('Sperrort')]);
      // Im Vorratsraum ist ebenfalls gesperrt, aber der Ausfall nennt ihn: erlaubt.
      expect(_befunde(_mit((_, d) => (d['kamera'] as Map)['ort'] = 'vorrat_mitte', nr: 1)), isEmpty);
      // Die Kamin-Nische ist Fundort und Ort eines anderen Lachers; im Rüstungs-Rückblick ist sie kein Thema.
      expect(_befunde(_mit((_, d) => (d['kamera'] as Map)['ort'] = 'am_kamin', nr: 2)), [contains('Kamin-Nische, einen Sperrort')]);
      // Beim Eiskübel liegt eine Spur nur in manchen Pfaden (Tatmatrix).
      // Das gilt auch, wenn der Baustein den Raum nennt (der Start nennt das Buffet).
      expect(_befunde(_mit((_, d) => (d['kamera'] as Map)['ort'] = 'am_eiskuebel')), [contains('nur in manchen Pfaden eine Spur')]);
      // Bei der Rüstung ebenso, aber der Rüstungs-Lacher zeigt genau diesen Ort: erlaubt.
      expect(_befunde(_roh), isEmpty);
      expect(Diashow.ausJson(_roh).dias[2].kamera.ort, 'an_der_ruestung');
    });

    test('R15: Verdächtige und das Opfer nur, wenn der Baustein sie nennt oder sie den Lacher spielen', () {
      expect(_befunde(_mit((_, d) => (d['figuren'] as List)[0] = 'ahmet')), [contains('ahmet steht im Bild')]);
      expect(_befunde(_mit((_, d) => (d['figuren'] as List)[0] = 'schneider')), [contains('schneider steht im Bild')]);
      expect(_befunde(_mit((_, d) => d['figuren'] = ['selin'], nr: 3)), isEmpty, reason: 'Gäste ohne Verdacht dürfen in jedes Bild');
      expect(_befunde(_mit((_, d) => d['figuren'] = ['fatma'], nr: 3)), [contains('fatma steht im Bild')]);
      expect(_befunde(_mit((_, d) => d['figuren'] = ['detective'])), [contains('detective steht im Bild')], reason: 'Der Detektiv nur im Auftrag');
    });

    test('Kein Text im Bild: unbekannte Felder sind ein Fehler', () {
      for (final j in [
        _mit((_, d) => d['bildunterschrift'] = 'Im Keller'),
        _mit((_, d) => (d['kamera'] as Map)['titel'] = 'Saal'),
        _mit((j, _) => j['text'] = 'Diashow'),
      ]) {
        expect(schema.pruefe(j), isNotEmpty);
        expect(() => Diashow.ausJson(j), throwsFormatException);
      }
    });
  });
}
