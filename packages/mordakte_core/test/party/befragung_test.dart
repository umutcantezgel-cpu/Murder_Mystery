// A-051 (M2a): Befragungsplan des Schlosskellers – Größen je Runde, I-B1 bis I-B6, Last, Zustellung und
// Rot-Proben an Kopien der Textsammlung. Die anderen Akten behalten das Modell legacy.
import 'dart:math';

import 'package:mordakte_core/mordakte_core.dart';
import 'package:mordakte_core/runden.dart';
import 'package:test/test.dart';

import 'kanon_hilfe.dart';

String _datei(String rel) => '$repoWurzel/content/party/schlosskeller/$rel';

/// Textsammlung des Schlosskellers; [ersatz] ersetzt einzelne Dateien (Rot-Proben).
Textsammlung _sammlungMit([Map<String, Map<String, Object?>> ersatz = const {}]) =>
    Textsammlung.lade((p) => ersatz[p] ?? leseJson(_datei(p)));

/// Eine Datei der Textsammlung mit veränderten Einträgen.
Map<String, Object?> _geaendert(String datei, List<Map<String, Object?>> Function(List<Map<String, Object?>> alt) aendern) {
  final j = leseJson(_datei(datei));
  final alt = [for (final e in j['eintraege'] as List) (e as Map).cast<String, Object?>()];
  return {...j, 'eintraege': aendern(alt)};
}

Texte _texteMit([Map<String, Map<String, Object?>> ersatz = const {}]) => Texte(kanon, _sammlungMit(ersatz));

final _texte = _texteMit();
final _plan = Befragungsplan(_texte);

String _befund(List<String> f) => f.isEmpty ? 'keine Verstöße' : '${f.length} Verstöße, z. B.:\n${f.take(12).join('\n')}';

void main() {
  test('Der Schlosskeller hat das Modell befragung, die anderen Akten legacy', () {
    final b = _texte.besetzung;
    expect(b.modell, GespraechsModell.befragung);
    expect([b.tischJeRolle, b.hoechstlast, b.befragungenMin, b.befragungenMax], [1, 3, 3, 5]);
    for (final akte in ['gewoelbe', 'ravensmoor', 'nachtexpress', 'blue_palm']) {
      final x = Besetzung(ladeKanon(akte));
      expect(x.modell, GespraechsModell.legacy, reason: akte);
      expect([x.tischJeRolle, x.hoechstlast], [3, Besetzung.lastRolle], reason: akte);
    }
  });

  test('Größen: 3 bis höchstens 5 Befragungen je Runde, feste und freie decken genau die Besetzung', () {
    final f = <String>[];
    for (var n = 4; n <= 20; n++) {
      final besetzt = _texte.besetzung.besetzt(n);
      for (var r = 1; r <= 3; r++) {
        final br = _plan.fuer(n, r);
        final wo = '$n Rollen, Runde $r';
        if (br.gesamt < 3 || br.gesamt > min(5, n)) f.add('$wo: ${br.gesamt} Befragungen');
        if (br.freiWahlen < 0 || br.freiWahlen > Befragungsplan.freiHoechstens) f.add('$wo: ${br.freiWahlen} freie Wahlen');
        if (br.freiWahlen > br.frei.length) f.add('$wo: mehr freie Wahlen als freie Rollen');
        if (br.pflicht.toSet().length != br.pflicht.length) f.add('$wo: doppelte Pflicht');
        if (!br.pflicht.every(besetzt.contains)) f.add('$wo: Pflicht mit unbesetzter Rolle');
        if (br.frei.join(',') != [for (final x in besetzt) if (!br.pflicht.contains(x)) x].join(',')) f.add('$wo: frei ist nicht der Rest der Besetzung');
        final platz = [for (final x in br.pflicht) besetzt.indexOf(x)];
        if (platz.join(',') != ([...platz]..sort()).join(',')) f.add('$wo: Pflicht nicht in Besetzungsreihenfolge');
        for (final x in [...br.pflicht, ...br.frei]) {
          if (br.text(x).rolle != x || br.text(x).runde != r) f.add('$wo: falscher Text für $x');
        }
      }
    }
    expect(f, isEmpty, reason: _befund(f));
  });

  test('Bei 4, 12 und 20 Rollen sieht der Plan so aus (feste Befragungen, freie Wahlen)', () {
    String zeile(int n) => [for (var r = 1; r <= 3; r++) '${_plan.fuer(n, r).pflicht.join(',')}+${_plan.fuer(n, r).freiWahlen}'].join(' | ');
    expect(zeile(4), 'ahmet+2 | fatma+2 | olli,can+2');
    expect(zeile(12), 'ahmet,emine+2 | fatma,leyla,murat,meryem+1 | olli,can,zeynep+2');
    expect(zeile(20), 'ahmet,emine,dilara,enes+1 | fatma,olli,leyla,murat,meryem+0 | can,zeynep,aylin,kaan,selin+0');
  });

  test('I-B1: Der Plan hängt nur an der Rollenzahl: frisch gerechnet, in anderer Reihenfolge, gleich', () {
    final zweiter = Befragungsplan(_texteMit());
    for (var n = 20; n >= 4; n--) {
      for (var r = 3; r >= 1; r--) {
        final a = _plan.fuer(n, r), b = zweiter.fuer(n, r);
        expect([a.pflicht, a.frei, a.freiWahlen], [b.pflicht, b.frei, b.freiWahlen], reason: '$n / $r');
      }
    }
    // Pfadfrei: Das Dossier einer Rolle trägt in jedem Pfad dieselben Befragungen.
    for (final rolle in ['ahmet', 'leyla', 'kaan']) {
      final ids = {for (final p in kanon.pfade) [for (final b in _texte.dossier(rolle, p, 20).befragungen.values) b?.id].join(',')};
      expect(ids, hasLength(1), reason: rolle);
    }
  });

  test('I-B2 bis I-B6: Befragungsplan.verstoesse() ist leer', () {
    final f = _plan.verstoesse();
    expect(f, isEmpty, reason: _befund(f));
  });

  test('I-B2: Jedes Tisch-Kettenglied hat bei jeder Besetzung einen rechtzeitigen Weg', () {
    final glieder = tischKettenglieder(kanon);
    expect(glieder, isNotEmpty);
    for (var n = 4; n <= 20; n++) {
      final z = _plan.zustellung(n);
      expect(z.keys.toSet(), glieder.keys.toSet(), reason: '$n Rollen');
      for (final e in z.values) {
        expect(e.runde, lessThanOrEqualTo(glieder[e.glied]!), reason: '$n Rollen, ${e.glied}');
        final besetzt = _texte.besetzung.istBesetzt(e.halter, n);
        expect(e.weg == Zustellweg.befragung, besetzt, reason: '$n Rollen, ${e.glied}');
        if (besetzt) expect(_plan.fuer(n, e.runde).pflicht, contains(e.halter));
      }
    }
    // Bei 20 Rollen kommt alles aus Befragungen, bei 4 aus Erzähler und Zielen.
    expect(_plan.zustellung(20).values.map((z) => z.weg).toSet(), {Zustellweg.befragung});
    expect(_plan.zustellung(4).values.map((z) => z.weg).toSet(), containsAll([Zustellweg.npc, Zustellweg.ziel]));
  });

  test('I-B3: Jede Befragung sagt alle eigenen Kettenglieder, die ab ihrer Runde gebraucht werden', () {
    for (final g in _plan.glieder.keys) {
      final h = _plan.halter(g);
      for (var r = 1; r <= 3; r++) {
        if (_plan.bedarfsrunden[g]!.any((x) => x >= r)) {
          expect(_texte.sammlung.befragungen[BefragungText.kennung(h, r)]!.preisgabe, contains(g), reason: '$h, Runde $r');
        }
      }
    }
  });

  test('I-B4: Jede besetzte Kernrolle wird an jedem Abend mindestens einmal fest befragt', () {
    for (var n = 4; n <= 20; n++) {
      for (final k in kanon.kernverdaechtige) {
        expect([for (var r = 1; r <= 3; r++) ..._plan.fuer(n, r).pflicht], contains(k), reason: '$n Rollen');
      }
    }
  });

  test('I-B5: Last je Rolle und Runde 1 bis 3, Tischgespräche als Sprecherin und Partnerin plus höchstens eine Befragung', () {
    final f = <String>[];
    for (var n = 4; n <= 20; n++) {
      final plan = _texte.gespraechsplan(n);
      final besetzt = _texte.besetzung.besetzt(n);
      for (var r = 1; r <= 3; r++) {
        final br = _plan.fuer(n, r);
        for (final x in besetzt) {
          final tisch = _texte.sammlung.gespraeche.where((g) => g.runde == r && (g.rolle == x || (besetzt.contains(g.rolle) && plan[g.id] == x))).length;
          final befragt = br.pflicht.contains(x) || br.frei.contains(x) ? 1 : 0;
          if (tisch < 1 || tisch + befragt > 3) f.add('$n Rollen, Runde $r: $x hat $tisch Tischgespräche und $befragt Befragung');
        }
        // Der Detektiv sitzt nie am Tisch.
        if (plan.values.contains(Besetzung.detektiv)) f.add('$n Rollen: der Detektiv ist Tischpartner');
      }
    }
    expect(f, isEmpty, reason: _befund(f));
    expect(_texte.lastVerstoesse(), isEmpty);
  });

  test('I-B6: Fragen, Thema und Stichpunkte nennen nur Figuren, die mit der befragten Rolle besetzt sind', () {
    final namen = {for (final x in kanon.figuren) x['id'] as String: x['name'] as String};
    final reihe = _texte.besetzung.reihenfolge;
    final f = <String>[];
    for (final b in _texte.sammlung.befragungen.values) {
      // Wird die Rolle befragt, sind höchstens die Plätze bis zu ihrem eigenen sicher besetzt.
      final unsicher = reihe.skip(reihe.indexOf(b.rolle) + 1);
      for (final u in unsicher) {
        final re = RegExp('(?<!\\p{L})${RegExp.escape(namen[u]!)}(?!\\p{L})', unicode: true);
        for (final t in [b.thema, ...b.fragen, ...b.stichpunkte]) {
          if (re.hasMatch(t)) f.add('${b.id}: nennt ${namen[u]}');
        }
      }
    }
    expect(f, isEmpty, reason: _befund(f));
  });

  test('P-1 für Befragungen: nur eigene Pflichtgespräch-Beobachtungen in allen Pfaden und eigene Lügen', () {
    for (final b in _texte.sammlung.befragungen.values) {
      for (final p in b.preisgabe) {
        final id = p.split(':').last;
        if (p.startsWith('beobachtung:')) {
          final x = _texte.beobachtung(id)!;
          expect([x['wer'], x['kanal'], x['pfade']], [b.rolle, 'pflichtgespraech', 'alle'], reason: '${b.id} $p');
        } else {
          expect(p, startsWith('luege:'), reason: b.id);
          expect(_texte.luege(id)!['person'], b.rolle, reason: '${b.id} $p');
        }
      }
    }
  });

  test('Antworten entstehen nur aus den Preisgaben, unabhängig von der Frage', () {
    for (final b in _texte.sammlung.befragungen.values) {
      final antwort = botAntwort(_texte, b);
      expect(antwort, hasLength(b.preisgabe.length), reason: b.id);
      for (var i = 0; i < antwort.length; i++) {
        final id = b.preisgabe[i].split(':').last;
        expect(antwort[i], b.preisgabe[i].startsWith('luege:') ? _texte.luege(id)!['behauptung'] : _texte.beobachtung(id)!['text'], reason: b.id);
        if (b.preisgabe[i].startsWith('luege:')) expect(antwort[i], isNot(_texte.luege(id)!['wahrheit']));
      }
      expect(() => antwort.clear(), throwsUnsupportedError);
    }
  });

  test('Tischgespräche: eines je Rolle und Runde, Stichpunkte statt Prosa, ohne Kettenglied', () {
    final glieder = tischKettenglieder(kanon);
    for (final g in _texte.sammlung.gespraeche) {
      expect(g.nr, 1, reason: g.id);
      expect(g.text, isEmpty, reason: g.id);
      expect(g.stichpunkte.length, inInclusiveRange(2, 3), reason: g.id);
      expect(g.stichpunkte.every((s) => stichpunktWoerter(s) <= 8), isTrue, reason: g.id);
      expect(g.partner, isNot(Besetzung.detektiv), reason: g.id);
      expect(g.preisgabe.where(glieder.containsKey), isEmpty, reason: g.id);
    }
    expect(_texte.sammlung.gespraeche, hasLength(60));
    expect(_texte.sammlung.befragungen, hasLength(60));
  });

  test('Dossier: Befragungen je Runde und wer die Rolle am Tisch anspricht', () {
    for (final n in [4, 12, 20]) {
      final plan = _texte.gespraechsplan(n);
      for (final r in _texte.besetzung.besetzt(n)) {
        final d = _texte.dossier(r, kanon.pfade.first, n);
        for (var runde = 1; runde <= 3; runde++) {
          expect(d.befragungen[runde]?.id, BefragungText.kennung(r, runde));
          expect(d.gespraeche[runde], hasLength(1));
          final an = d.alsPartner[runde] ?? const <(Gespraech, String)>[];
          expect(an.map((x) => x.$2).toList(),
              [for (final g in _texte.sammlung.gespraeche) if (g.runde == runde && plan[g.id] == r) g.rolle]);
          expect(an, hasLength(1), reason: '$r, Runde $runde, $n Rollen');
        }
      }
    }
    // Im Modell legacy trägt das Dossier keine Befragungen.
    final g = Texte(ladeKanon('gewoelbe'), Textsammlung.lade((p) => leseJson('$repoWurzel/content/party/gewoelbe/$p')));
    expect(g.dossier('adnan', 'merle', 4).befragungen.values.whereType<BefragungText>(), isEmpty);
  });

  test('Rot-Probe: fehlt einer Befragung ein Kettenglied, melden I-B3 und I-B2', () {
    final t = _texteMit({
      'texte/befragungen-r1.json': _geaendert('texte/befragungen-r1.json', (alt) => [
            for (final e in alt)
              if (e['id'] == 'bf_emine_1') {...e, 'preisgabe': <String>[]} else e,
          ]),
    });
    final f = Befragungsplan(t).verstoesse();
    expect(f, contains('Befragung bf_emine_1: beobachtung:b_emine_versteck fehlt, eine Entscheidung ab Runde 1 braucht es (I-B3)'));
    expect(f.where((x) => x.contains('e1_2: beobachtung:b_emine_versteck von emine') && x.contains('(I-B2)')), isNotEmpty);
  });

  test('Rot-Probe: eine Befragung mit fremder oder verborgener Preisgabe scheitert geschlossen', () {
    for (final quelle in ['beobachtung:b_emine_schatulle', 'beobachtung:b_tim_gesicht', 'luege:luege_ahmet_miete', 'spur:fremd']) {
      final t = _texteMit({
        'texte/befragungen-r1.json': _geaendert('texte/befragungen-r1.json', (alt) => [
              for (final e in alt)
                if (e['id'] == 'bf_emine_1') {...e, 'preisgabe': [quelle]} else e,
            ]),
      });
      expect(() => botAntwort(t, t.sammlung.befragungen['bf_emine_1']!), throwsStateError, reason: quelle);
      expect(textVerweise(kanon, t.sammlung).where((x) => x.startsWith('Befragung bf_emine_1')), isNotEmpty, reason: quelle);
    }
  });

  test('Rot-Probe: ein unbesetzter Name in einer Frage wird gemeldet (I-B6)', () {
    final t = _texteMit({
      'texte/befragungen-r1.json': _geaendert('texte/befragungen-r1.json', (alt) => [
            for (final e in alt)
              if (e['id'] == 'bf_ahmet_1') {...e, 'fragen': ['Wo war Tugba beim Knall?', 'Wer stand bei dir?']} else e,
          ]),
    });
    expect(Befragungsplan(t).verstoesse().where((x) => x.contains('bf_ahmet_1 nennt die unbesetzte Figur tugba')), isNotEmpty);
  });

  test('Rot-Probe: Prosa, Kettenglied und Detektiv am Tisch werden im Modell befragung gemeldet', () {
    final t = _sammlungMit({
      'texte/gespraeche-r1-b1.json': _geaendert('texte/gespraeche-r1-b1.json', (alt) => [
            for (final e in alt)
              if (e['id'] == 'g_ahmet_1_1')
                {...e, 'partner': 'detective', 'text': 'Ich hab nur Servietten gesucht.', 'preisgabe': ['luege:luege_ahmet_servietten']}
              else
                e,
          ]),
    });
    final f = textVerweise(kanon, t);
    expect(f, containsAll([
      'Gespräch g_ahmet_1_1: der Detektiv ist kein Tischpartner (Modell befragung)',
      'Gespräch g_ahmet_1_1: Prosa statt Stichpunkte (Modell befragung)',
      'Gespräch g_ahmet_1_1: luege:luege_ahmet_servietten ist ein Kettenglied und gehört in die Befragung',
    ]));
  });

  test('Rot-Probe: zu lange Stichpunkte und Fragen ohne Fragezeichen werden gemeldet (R17)', () {
    final t = _sammlungMit({
      'texte/befragungen-r2.json': _geaendert('texte/befragungen-r2.json', (alt) => [
            for (final e in alt)
              if (e['id'] == 'bf_tim_2') {...e, 'fragen': ['Erzähl vom Stromausfall.', 'Wo warst du?'], 'stichpunkte': ['Eins zwei drei vier fünf sechs sieben acht neun.']} else e,
          ]),
    });
    final f = textVerweise(kanon, t);
    expect(f.where((x) => x.startsWith('Befragung bf_tim_2: Frage ohne Fragezeichen')), hasLength(1));
    expect(f.where((x) => x.startsWith('Befragung bf_tim_2: Stichpunkt mit 9 Wörtern')), hasLength(1));
  });

  test('Lückenliste im Modell befragung: fehlende Befragung und zweites Tischgespräch werden genannt', () {
    final t = _sammlungMit({
      'texte/befragungen-r3.json': _geaendert('texte/befragungen-r3.json', (alt) => [for (final e in alt) if (e['id'] != 'bf_can_3') e]),
      'texte/gespraeche-r3-b1.json': _geaendert('texte/gespraeche-r3-b1.json', (alt) => [
            ...alt,
            {...alt.first, 'id': 'g_ahmet_3_2', 'nr': 2},
          ]),
    });
    final l = textLuecken(kanon, t);
    expect(l, containsAll(['Befragung bf_can_3 fehlt', 'Rolle ahmet, Runde 3: 2 statt 1 Tischgespräche']));
    expect(textLuecken(kanon, _sammlungMit()).where((x) => x.startsWith('Befragung') || x.contains('Tischgespräche')), isEmpty);
  });
}
