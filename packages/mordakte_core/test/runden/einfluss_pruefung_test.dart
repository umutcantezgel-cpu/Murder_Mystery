// Prüfer der Einfluss-Schicht (Finale §3, §4): die echten Daten sind grün, Fixture-Texte für alle
// Schlüssel sind grün, und jede Regel hat eine Fehlerprobe.
import 'package:mordakte_core/mordakte_core.dart';
import 'package:mordakte_core/runden.dart';
import 'package:test/test.dart';

import '../party/kanon_hilfe.dart';
import 'einfluss_hilfe.dart';

final _ton = Textpruefer(leseJson('$repoWurzel/content/party/textregeln.json'));
final _r15 = PfadgleichRegeln(kanon, art: 'einen Einfluss-Text');

List<String> _pruefe(Map<String, Object?> j, {Map<String, String>? texte, bool mitTexten = true}) => pruefeEinfluss(
      j,
      einflussErmittlung,
      texte: texte ?? fixtureTexte(einflussRegeln),
      texteNoetig: mitTexten,
      ton: _ton,
      r15: _r15,
    );

/// Befunde, die [teil] enthalten.
Matcher _befund(String teil) => anyElement(contains(teil));

void main() {
  test('einfluss.json passt zum Schema (content/party/zusatz/einfluss.schema.json)', () {
    final f = SchemaPruefer(leseJson('$repoWurzel/content/party/zusatz/einfluss.schema.json')).pruefe(einflussJson());
    expect(f, isEmpty, reason: f.join('\n'));
  });

  test('Die echten Daten sind grün: Ausgewogenheit, Quellen in allen Pfaden, Ziele erreichbar und verfehlbar', () {
    final f = _pruefe(einflussJson(), mitTexten: false);
    expect(f, isEmpty, reason: f.join('\n'));
  });

  test('Fixture-Texte für alle Schlüssel sind grün (Katalog, Karten, Wortgrenzen, Platzhalter, R15, Ton)', () {
    final f = _pruefe(einflussJson());
    expect(f, isEmpty, reason: f.join('\n'));
  });

  test('f_foto_streit gibt es in allen Pfaden: Joanna liefert ihn beim Auspacken', () {
    expect(einflussErmittlung.faktPfade('f_foto_streit'), kanon.pfade.toSet());
    expect(einflussRegeln.auspacken['johanna']!.fakt, 'f_foto_streit');
  });

  group('Fehlerproben', () {
    test('Format und Verweise: ein Befund statt Abbruch', () {
      final j = kopie(einflussJson())..['format'] = 'einfluss/0';
      expect(_pruefe(j), [contains('format einfluss/0')]);
      final k = kopie(einflussJson());
      (k['bezug'] as Map).remove('e1_1_joanna');
      expect(_pruefe(k), [contains('Option e1_1_joanna fehlt')]);
    });

    test('Bezug ungleich: Kernfiguren in einer Runde mehr als ±1 auseinander', () {
      final j = kopie(einflussJson());
      final b = j['bezug'] as Map;
      b['e1_2_emine'] = ['emine', 'fatma', 'ahmet'];
      b['e1_3_tim'] = ['tim', 'ahmet'];
      expect(_pruefe(j, mitTexten: false), _befund('Runde 1 nennt die Kernfiguren ungleich oft'));
    });

    test('Randnotiz und Auspacken nur aus Quellen aller Pfade', () {
      final j = kopie(einflussJson());
      (j['randnotizen'] as Map)['e1_1_joanna'] = ['b_damir_ahmet_blieb'];
      (j['auspacken'] as Map)['enes'] = {'fakt': 'f_alibi_ahmet', 'notiz': 'b_damir_ahmet_weg'};
      final f = _pruefe(j, mitTexten: false);
      expect(f, _befund('randnotizen.e1_1_joanna: b_damir_ahmet_blieb gilt nicht in allen Pfaden'));
      expect(f, _befund('auspacken.enes: Fakt f_alibi_ahmet gibt es nicht in allen Pfaden'));
      expect(f, _befund('auspacken.enes: b_damir_ahmet_weg gilt nicht in allen Pfaden'));
    });

    test('Vollständigkeit je Figur und Bots, die auspacken', () {
      final j = kopie(einflussJson());
      (j['bots'] as Map).remove('tugba');
      (j['auspacken'] as Map).remove('meryem');
      final f = _pruefe(j, mitTexten: false);
      expect(f, _befund('bots.tugba fehlt'));
      expect(f, _befund('auspacken.meryem fehlt'));
      expect(f, _befund('bots.meryem: packt aus, aber auspacken.meryem fehlt'));
    });

    test('Ziele: nie erreichbar, nie verfehlbar, nicht lesbar, Kernfiguren ungleich geformt', () {
      final j = kopie(einflussJson());
      final z = j['ziele'] as Map;
      z['serkan'] = [
        {'id': 'zu_viel', 'bedingung': {'mind': ['zuege:helfen', 4]}},
        {'id': 'immer', 'bedingung': {'hoechstens': ['spuk', 6]}},
      ];
      expect(_pruefe(j, mitTexten: false), allOf(_befund('ziele.serkan[1] zu_viel: nie erreichbar'), _befund('ziele.serkan[2] immer: nie verfehlbar')));

      final k = kopie(einflussJson());
      (k['ziele'] as Map)['hakan'] = [
        {'id': 'a', 'bedingung': {'mind': ['wurfglueck', 1]}},
        {'id': 'b', 'bedingung': {'hoechstens': ['spuk', 3]}},
      ];
      expect(_pruefe(k, mitTexten: false), _befund('ziele.hakan[1]: unbekanntes Atom wurfglueck'));

      final m = kopie(einflussJson());
      (m['ziele'] as Map)['fatma'] = [
        {'id': 'schatulle_geheim', 'bedingung': {'alle': [{'hoechstens': ['bekannt:f_nd_fatma', 0]}]}},
        {'id': 'helfen', 'bedingung': {'mind': ['zuege:helfen', 1]}},
      ];
      expect(_pruefe(m, mitTexten: false), _befund('ziele: Stern 2 der Kernfiguren hat nicht dieselbe Form'));
    });

    test('Texte: fehlend, fremd, Karte zu lang oder Prosa, Wortgrenzen, Platzhalter', () {
      final t = fixtureTexte(einflussRegeln)
        ..remove('einfluss.wieder')
        ..['einfluss.geheim'] = 'Kurz'
        ..['einfluss.zug.zeigen.titel'] = 'Zeig auf eine Figur am Tisch und sag laut warum'
        ..['einfluss.zug.helfen.p1'] = 'Hilf mit. Dann geht es schneller.'
        ..['einfluss.auspacken.ahmet'] = fixtureSatz
        ..['einfluss.ertappt'] = 'Gleich danach nennt jemand @figur beim Namen. $fixtureSatz'
        ..['einfluss.privat.wirkte'] = 'Dein Zug wirkte bei @figur'
        ..['einfluss.preis.spuernasen'] = 'Gleich danach nennt jemand @figur und @letzte beim Namen. $fixtureSatz';
      final f = _pruefe(einflussJson(), texte: t);
      expect(f, _befund('Text einfluss.wieder fehlt'));
      expect(f, _befund('Text einfluss.geheim gehört nicht zum Einfluss-Katalog'));
      expect(f, _befund('einfluss.zug.zeigen.titel: 10 Wörter statt höchstens 8 (R17)'));
      expect(f, _befund('einfluss.zug.helfen.p1: mehr als ein Satz'));
      expect(f, _befund('einfluss.auspacken.ahmet: 11 Wörter statt 20 bis 45'));
      expect(f, _befund('einfluss.ertappt: Platzhalter @ziel fehlt'));
      expect(f, _befund('einfluss.privat.wirkte: Platzhalter @figur hier nicht erlaubt'));
      // Mehrere Spürnasen („Änderungen“ 44): Namensliste statt @figur.
      expect(f, _befund('einfluss.preis.spuernasen: Platzhalter @figur hier nicht erlaubt'));
      expect(f, _befund('einfluss.preis.spuernasen: Platzhalter @liste fehlt'));
    });

    test('Kragen erzwingt den chaotischen Morgen („Änderungen“ 2)', () {
      final j = kopie(einflussJson());
      for (final e in j['ereignisse'] as List) {
        if ((e as Map)['id'] == 'kragen') e.remove('morgen');
      }
      expect(_pruefe(j, mitTexten: false), ['ereignisse.kragen: erzwingt den chaotischen Morgen nicht']);
    });

    test('Ereignistitel höchstens drei Wörter und ohne „Kerze“; Platzhalter beim Lauschen („Änderungen“ 1, 3)', () {
      final t = fixtureTexte(einflussRegeln)
        ..['einfluss.ereignis.tee.titel'] = 'Tee für alle hier'
        ..['einfluss.ereignis.kerzenschein.titel'] = 'Kerzenschein'
        ..['einfluss.privat.gelauscht.ohne_ziel'] = 'Gelauscht bei @figur'
        ..['einfluss.privat.gelauscht.abgewartet'] = '@figur: @zug';
      final f = _pruefe(einflussJson(), texte: t);
      expect(f, _befund('einfluss.ereignis.tee.titel: 4 Wörter statt höchstens 3 (R17)'));
      expect(f, _befund('einfluss.ereignis.kerzenschein.titel: Ereignistitel ohne „Kerze“'));
      expect(f, _befund('einfluss.privat.gelauscht.ohne_ziel: Platzhalter @zug fehlt'));
      expect(f, _befund('einfluss.privat.gelauscht.abgewartet: Platzhalter @zug hier nicht erlaubt'));
    });

    test('R15 nach ganzen Wörtern; Namen und Spielbegriffe frei; Geltungsbereich („Änderungen“ 8, 15)', () {
      List<String> r15(Map<String, String> aenderung) =>
          [for (final x in _pruefe(einflussJson(), texte: {...fixtureTexte(einflussRegeln), ...aenderung})) if (x.contains('(R15)')) x];
      // Kein Teilwort-Treffer („Tisch“ steckt in „Buffettisch“), Namen samt Genitiv und Herr Schneider frei,
      // Spielbegriffe frei.
      expect(r15({
        'einfluss.folgen.start.1': 'Am Tisch rücken alle zusammen. Herr Schneider nickt Fatma und Lejla zu, und Fatmas Lachen hallt.',
        'einfluss.leiste.spuk.1': 'Der Spuk wächst, der Schlossgeist kichert, und jede Spur und jedes Geheimnis bleibt im Dunkeln.',
        'einfluss.geruecht.leise': 'Leise geht ein Wort über @figur um den Tisch, dann ist es wieder still.',
        'einfluss.bot.can.ertappt': 'Herrn Schneiders Blick trifft mich',
      }), isEmpty);
      // Ganze Wörter aus Fallgegenständen, Sperrorten und Suchstellen fallen in allen Bereichen mit R15 auf.
      const satz = 'Plötzlich liegt ein Silberring mitten im Gewölbe, und alle staunen.';
      final f = r15({
        for (final k in ['einfluss.folgen.start.2', 'einfluss.ablenken.can', 'einfluss.leiste.ruhig', 'einfluss.ereignis.tee'])
          k: '$satz $fixtureSatz',
        'einfluss.ereignis.tee.karte': 'Ein Silberring blitzt auf',
        'einfluss.ereignis.tee.titel': 'Der Silberring',
        'einfluss.bot.olli.geruecht': 'Wo ist der Silberring',
        'einfluss.geruecht.laut': 'Gleich danach nennt jemand @figur beim Namen. $satz',
      });
      for (final k in [
        'einfluss.folgen.start.2', 'einfluss.ablenken.can', 'einfluss.leiste.ruhig', 'einfluss.ereignis.tee', 'einfluss.ereignis.tee.karte',
        'einfluss.ereignis.tee.titel', 'einfluss.bot.olli.geruecht', 'einfluss.geruecht.laut',
      ]) {
        expect(f, _befund('$k: „Silberring“ aus „Fatmas breiter Silberring“ gehört nicht in einen Einfluss-Text (R15)'));
      }
      // Nicht für Auspacken (nennt seine Quelle) und Texte nach dem Finale.
      expect(r15({
        for (final k in ['einfluss.auspacken.fatma', 'einfluss.morgen.warm', 'einfluss.tischbonus.plus', 'einfluss.preis.stern'])
          k: k == 'einfluss.preis.stern' ? 'Gleich danach nennt jemand @figur beim Namen. $satz' : '$satz $fixtureSatz',
        'einfluss.epilog.fatma.erreicht': satz,
      }), isEmpty);
    });

    test('Ton und R15: Ziffern im Vorlesetext, Fallgegenstand im Ereignis, Geburtstag', () {
      final gegenstand = kanon.gegenstaende.first['name'] as String;
      final t = fixtureTexte(einflussRegeln)
        ..['einfluss.morgen.warm'] = 'Um 7 Uhr scheint die Sonne in den Hof. $fixtureSatz'
        ..['einfluss.ereignis.tee'] = 'Plötzlich liegt $gegenstand mitten auf dem Tisch. $fixtureSatz'
        ..['einfluss.ereignis.tee.karte'] = 'Ein Geburtstag am Tisch';
      final f = _pruefe(einflussJson(), texte: t);
      expect(f, _befund('einfluss.morgen.warm: Ziffer'));
      expect(f, _befund('einfluss.ereignis.tee: „'));
      expect(f, _befund('einfluss.ereignis.tee.karte: Geburtstag'));
    });
  });
}
