// F-10, F-11 (Gerüst F3-ORCH-00): Textsammlung, Schemas, Verweise, Dossier je Pfad.
import 'package:mordakte_core/mordakte_core.dart';
import 'package:test/test.dart';

import 'kanon_hilfe.dart';

String _datei(String rel) => '$repoWurzel/content/party/schlosskeller/$rel';

Textsammlung _sammlung([Map<String, Map<String, Object?>> ersatz = const {}]) =>
    Textsammlung.lade((p) => ersatz[p] ?? leseJson(_datei(p)));

/// Eine kleine Probe-Sammlung neben der echten, für Regeln, die erst mit Texten greifen.
Textsammlung _probe({List<Map<String, Object?>> gespraeche = const [], List<Map<String, Object?>> dossiers = const []}) {
  final index = leseJson(_datei('texte/index.json'));
  Map<String, Object?> leer(String datei) => leseJson(_datei('texte/$datei'));
  return Textsammlung.lade((p) {
    if (p == 'texte/index.json') return index;
    final d = p.substring('texte/'.length);
    if (d == 'gespraeche-r1-b5.json') return {...leer(d), 'eintraege': gespraeche};
    if (d == 'dossiers-b5.json') return {...leer(d), 'eintraege': dossiers};
    if (d == 'taeter-ahmet.json') {
      return {
        ...leer(d),
        'eintraege': [
          {
            'rolle': 'ahmet',
            'tarnung': 'Du sagst, du hast Servietten geholt.',
            'tatwissen': [
              {'text': 'Du weißt, was an der Vorratstür geschah.'},
            ],
            'verbirgt': [
              {'ref': 'luege:luege_ahmet_servietten'},
            ],
            'ziel': 'Niemand darf es herausfinden.',
          },
        ],
      };
    }
    if (d == 'dossiers-b1.json') {
      return {
        ...leer(d),
        'eintraege': [
          {
            'rolle': 'ahmet',
            'wer': 'Du bist Ahmet.',
            'weiss': [],
            'verbirgt': [
              {'ref': 'nebendelikt:nd_mietgeld'},
            ],
            'ziel': 'Die Miete soll erst morgen Thema sein.',
            'besetzung': 'Kann jede Person spielen.',
          },
        ],
      };
    }
    return leer(d);
  });
}

void main() {
  final schemaOrdner = '$repoWurzel/content/party/schema';
  const schemaJeBereich = {
    'erzaehler': 'texte-bausteine',
    'detektiv': 'texte-bausteine',
    'ui': 'texte-bausteine',
    'einfluss': 'texte-bausteine',
    'dossier': 'texte-dossier',
    'taeter': 'texte-taeter',
    'gespraech': 'texte-gespraech',
    'befragung': 'texte-befragung',
    'kurzfassung': 'texte-kurzfassung',
    'wahl': 'texte-wahl',
  };

  test('Index und jede Textdatei passen zu ihrem Schema', () {
    final t = _sammlung();
    final fehler = SchemaPruefer(leseJson('$schemaOrdner/texte-index.schema.json')).pruefe(t.index);
    expect(fehler, isEmpty, reason: fehler.join('\n'));
    for (final d in t.dateien.entries.where((d) => d.key != 'texte/index.json')) {
      final s = SchemaPruefer(leseJson('$schemaOrdner/${schemaJeBereich[d.value['bereich']]}.schema.json'));
      final f = s.pruefe(d.value);
      expect(f, isEmpty, reason: '${d.key}: ${f.join('\n')}');
    }
  });

  test('Verweise der Textsammlung zeigen auf den Kanon, keine Kennung doppelt', () {
    final f = textVerweise(kanon, _sammlung());
    expect(f, isEmpty, reason: f.join('\n'));
  });

  test('Dossier wird je Pfad zusammengesetzt: Trenner-Wissen nur im passenden Pfad', () {
    final t = _probe(dossiers: [
      {
        'rolle': 'enes',
        'wer': 'Du bist Damir.',
        'weiss': [
          {'ref': 'beobachtung:b_damir_an_der_theke'},
        ],
        'verbirgt': [
          {'ref': 'beobachtung:b_damir_ahmet_blieb'},
          {'ref': 'beobachtung:b_damir_ahmet_weg'},
        ],
        'ziel': 'Kein Streit ums Teegeschirr.',
        'besetzung': 'Kann jede Person spielen.',
      },
    ]);
    expect(textVerweise(kanon, t), isEmpty);
    final texte = Texte(kanon, t);
    for (final p in kanon.pfade) {
      final d = texte.dossier('enes', p, 20);
      expect(d.weiss, hasLength(1));
      expect(d.verbirgt, hasLength(1), reason: p);
      // Seit E-039 ist Ahmet auch im Pfad Can beim Scheppern nicht bei Damir.
      final erwartet = p == 'ahmet' || p == 'can' ? 'b_damir_ahmet_weg' : 'b_damir_ahmet_blieb';
      final b = kanon.beobachtungen.firstWhere((b) => b['id'] == erwartet);
      expect(d.verbirgt.single.text, b['duText'] ?? b['text']);
    }
  });

  test('Kernrolle: im eigenen Pfad die Täterfassung, sonst die Unschuldsfassung', () {
    final texte = Texte(kanon, _probe());
    final taeter = texte.dossier('ahmet', 'ahmet', 4);
    expect(taeter.taeter, isTrue);
    expect(taeter.tarnung, isNotNull);
    expect(taeter.verbirgt.single.behauptung, isNotEmpty);
    final unschuldig = texte.dossier('ahmet', 'fatma', 4);
    expect(unschuldig.taeter, isFalse);
    expect(unschuldig.verbirgt.single.art, 'nebendelikt');
  });

  test('Sabotage-Text nur im eigenen Pfad der Kernrolle', () {
    final texte = Texte(kanon, _sammlung());
    for (final k in kanon.kernverdaechtige) {
      for (final p in kanon.pfade) {
        final w = texte.dossier(k, p, 4).wahlen.values.whereType<WahlText>().toList();
        expect(w, hasLength(3), reason: '$k in $p');
        expect(w.every((x) => (x.sabotage != null) == (k == p)), isTrue, reason: '$k in $p');
      }
    }
  });

  test('Tischgespräche: Ersatzpartner bei kleiner Besetzung, P-1 wird erzwungen', () {
    Map<String, Object?> g(String rolle, String partner, List<String> preisgabe) => {
          'id': 'g_${rolle}_1_1',
          'rolle': rolle,
          'runde': 1,
          'nr': 1,
          'partner': partner,
          'thema': 'Der Abend',
          'ziel': 'Herausfinden, wer wo war',
          'preisgabe': preisgabe,
          'stichpunkte': ['Wo warst du beim Knall?', 'Ich hab kaum was gesehen.'],
        };
    final gut = _probe(gespraeche: [
      g('hakan', 'leyla', ['beobachtung:b_pawel_schneider']),
    ]);
    expect(textVerweise(kanon, gut), isEmpty);
    final dossierLos = Texte(kanon, gut);
    // Im Modell befragung springt nie der Detektiv ein, sondern die erste andere besetzte Rolle.
    expect(dossierLos.besetzung.partner('leyla', 4, sprecher: 'hakan'), 'ahmet');
    final schlecht = _probe(gespraeche: [
      g('enes', 'leyla', ['beobachtung:b_damir_ahmet_blieb', 'nebendelikt:nd_mietgeld', 'beobachtung:b_hana_wachs', 'luege:luege_ahmet_miete']),
    ]);
    final f = textVerweise(kanon, schlecht);
    expect(f.where((x) => x.contains('nicht für den Tisch')), hasLength(1));
    expect(f.where((x) => x.contains('nicht erlaubt')), hasLength(1));
    expect(f.where((x) => x.contains('gehört nicht zu')), hasLength(1));
    expect(f.where((x) => x.contains('nicht die Lüge')), hasLength(1));
    // Ein Kettenglied gehört in die Befragung, nicht an den Tisch (A-051).
    final kette = textVerweise(kanon, _probe(gespraeche: [g('enes', 'leyla', ['beobachtung:b_damir_an_der_theke'])]));
    expect(kette, ['Gespräch g_enes_1_1: beobachtung:b_damir_an_der_theke ist ein Kettenglied und gehört in die Befragung']);
  });

  test('P-2: ein ersetzbarer Partner steht nicht im Text, eine Kernrolle darf', () {
    Map<String, Object?> g(String partner, String text, String rolle) => {
          'id': 'g_${rolle}_1_1',
          'rolle': rolle,
          'runde': 1,
          'nr': 1,
          'partner': partner,
          'thema': 'Der Abend',
          'ziel': 'Wissen, wer wo war',
          'preisgabe': [],
          'stichpunkte': [text, 'Ich hab nichts gesehen.'],
        };
    final f = textVerweise(
        kanon,
        _probe(gespraeche: [
          g('leyla', 'Lejla, wo warst du beim Knall?', 'enes'),
          g('ahmet', 'Ahmet, wo warst du beim Knall?', 'hakan'),
          g('tim', 'Wo warst du beim Knall?', 'selin'),
        ]));
    expect(f.where((x) => x.contains('(P-2)')), ['Gespräch g_enes_1_1: nennt den Partner Lejla, der ersetzt werden kann (P-2)']);
  });

  test('Gesprächsplan 4 bis 20: Höchstlast, Wunschpartner bleibt, nie mit sich selbst (V-19, E-028)', () {
    final t = _sammlung();
    final texte = Texte(kanon, t);
    final v = texte.lastVerstoesse();
    expect(v, isEmpty, reason: v.join('\n'));
    final b = texte.besetzung;
    for (var n = b.minRollen; n <= b.maxRollen; n++) {
      final plan = texte.gespraechsplan(n);
      for (final g in t.gespraeche) {
        final p = plan[g.id];
        if (!b.istBesetzt(g.rolle, n)) {
          expect(p, isNull, reason: '${g.id} bei $n');
          continue;
        }
        expect(p, isNot(g.rolle), reason: '${g.id} bei $n');
        expect(b.istBesetzt(p!, n), isTrue, reason: '${g.id} bei $n');
        if (b.istBesetzt(g.partner, n)) expect(p, g.partner, reason: '${g.id} bei $n');
      }
    }
  });

  test('Rot-Probe (Modell legacy, Gewölbe): zu viele Gespräche mit einer Kernrolle werden gemeldet', () {
    final g = Besetzung(ladeKanon('gewoelbe'));
    expect(g.modell, GespraechsModell.legacy);
    final wuensche = <GespraechsWunsch>[
      for (final r in g.reihenfolge.skip(16))
        for (var nr = 1; nr <= 3; nr++) (id: 'g_${r}_1_$nr', rolle: r, runde: 1, nr: nr, partner: 'adnan'),
    ];
    expect(g.lastVerstoesse(wuensche, g.gespraechsplan(wuensche, 20), 20).where((x) => x.startsWith('20 Rollen, Runde 1: adnan')), isNotEmpty);
  });

  test('Modell befragung: der Plan leitet überzählige Wünsche um, ein erzwungener Plan wird gemeldet', () {
    final b = Texte(kanon, _sammlung()).besetzung;
    final wuensche = <GespraechsWunsch>[
      for (final r in ['enes', 'selin', 'hakan', 'tugba']) (id: 'g_${r}_1_1', rolle: r, runde: 1, nr: 1, partner: 'ahmet'),
      (id: 'g_ahmet_1_1', rolle: 'ahmet', runde: 1, nr: 1, partner: 'fatma'),
    ];
    final plan = b.gespraechsplan(wuensche, 20);
    expect(plan.values.where((p) => p == 'ahmet'), hasLength(1));
    expect(plan.values, isNot(contains(Besetzung.detektiv)));
    expect(b.lastVerstoesse(wuensche, plan, 20), isEmpty);
    final erzwungen = {...plan, for (final w in wuensche) if (w.rolle != 'ahmet') w.id: 'ahmet'};
    expect(b.lastVerstoesse(wuensche, erzwungen, 20), contains('20 Rollen, Runde 1: ahmet hat 5 Gespräche (höchstens 2)'));
  });

  test('Modell befragung: hat zuletzt nur der Sprecher selbst freie Last, tauscht der Plan', () {
    final b = Texte(kanon, _sammlung()).besetzung;
    // Vier Rollen, ein Ring ahmet → fatma → olli → ahmet; can wünscht sich ahmet, der schon vergeben ist.
    final wuensche = <GespraechsWunsch>[
      (id: 'a', rolle: 'ahmet', runde: 1, nr: 1, partner: 'fatma'),
      (id: 'f', rolle: 'fatma', runde: 1, nr: 1, partner: 'olli'),
      (id: 'o', rolle: 'olli', runde: 1, nr: 1, partner: 'ahmet'),
      (id: 'c', rolle: 'can', runde: 1, nr: 1, partner: 'ahmet'),
    ];
    final plan = b.gespraechsplan(wuensche, 4);
    expect(plan.values.toSet(), {'ahmet', 'fatma', 'olli', 'can'}, reason: '$plan');
    for (final w in wuensche) {
      expect(plan[w.id], isNot(w.rolle));
    }
    expect(b.lastVerstoesse(wuensche, plan, 4), isEmpty);
  });

  test('doppelte Kennungen und unbekannte Verweise werden gemeldet', () {
    final t = _probe(dossiers: [
      {
        'rolle': 'enes',
        'wer': 'Du bist Damir.',
        'weiss': [
          {'ref': 'beobachtung:b_gibt_es_nicht'},
        ],
        'verbirgt': [],
        'ziel': 'x',
        'besetzung': 'x',
      },
      {'rolle': 'enes', 'wer': 'nochmal', 'weiss': [], 'verbirgt': [], 'ziel': 'x', 'besetzung': 'x'},
    ]);
    final f = textVerweise(kanon, t);
    expect(f.any((x) => x.contains('dossier.enes in')), isTrue);
    expect(f.any((x) => x.contains('unbekannter Verweis')), isTrue);
  });

  test('Lückenliste nennt fehlende Teile (Vollständigkeit prüft das F3-Tor)', () {
    final l = textLuecken(kanon, _sammlung());
    expect(l.where((x) => x.startsWith('Erzähler-Baustein')), hasLength(Erzaehler(kanon).katalog().length - _sammlung().bausteine.keys.where((k) => !k.startsWith('detektiv.') && !k.startsWith('ermittlungsbogen.') && !k.startsWith('ui.')).length));
  });
}
