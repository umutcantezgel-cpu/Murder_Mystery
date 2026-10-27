// A-063, SPEZIFIKATION §2: Erzählerakte nur für die Person, die erzählt. Die
// Fixture (einstimmung_hilfe.dart, aus figuren.json erzeugt) erfüllt Schema und
// Prüfer. Geprüft werden Vollständigkeit, Privatsphäre der Schlüssel, Pfadgleichheit
// (nie gelesen: Profile, Lügen, Alibi), eine Fehlerprobe mit einem Tarnungssatz,
// der Ersatz der Ziele über ZielQuelle und die Regeln des Netzes.
import 'package:mordakte_core/mordakte_core.dart';
import 'package:test/test.dart';

import 'einstimmung_hilfe.dart';
import 'kanon_hilfe.dart';

final _ton = Textpruefer(leseJson('$repoWurzel/content/party/textregeln.json'));
final _texte = Texte(kanon, Textsammlung.lade((p) => leseJson('$repoWurzel/content/party/schlosskeller/$p')));

Erzaehlerakte _akte([Map<String, Object?>? j, Kanon? k, ZielQuelle? ziele]) => Erzaehlerakte.ausJson(j ?? erzaehlerakteFixture(), k ?? kanon, ziele: ziele);

List<String> _pruefe(Map<String, Object?> j) => pruefeErzaehlerakte(_akte(j), _texte, ton: _ton);

/// Fixture mit veränderter Figurenliste oder verändertem Netz.
Map<String, Object?> _mit({List<Map<String, Object?>> Function(List<Map<String, Object?>>)? figuren, List<Map<String, Object?>> Function(List<Map<String, Object?>>)? netz}) {
  final j = erzaehlerakteFixture();
  List<Map<String, Object?>> l(Object? x) => [for (final e in x as List) (e as Map).cast<String, Object?>()];
  return {
    ...j,
    if (figuren != null) 'figuren': figuren(l(j['figuren'])),
    if (netz != null) 'netz': netz(l(j['netz'])),
  };
}

/// Alle Schlüssel unter [o].
Set<String> _schluessel(Object? o) => switch (o) {
      final Map m => {for (final e in m.entries) ...{'${e.key}', ..._schluessel(e.value)}},
      final List l => {for (final x in l) ..._schluessel(x)},
      _ => const {},
    };

Iterable<String> _strings(Object? o) sync* {
  if (o is String) yield o;
  if (o is Map) {
    for (final v in o.values) {
      yield* _strings(v);
    }
  }
  if (o is List) {
    for (final v in o) {
      yield* _strings(v);
    }
  }
}

void main() {
  group('Schema', () {
    for (final ordner in ['schema', 'schema-akte']) {
      test('$ordner/erzaehlerakte.schema.json: Fixture gültig, fremde Felder und falsche Werte nicht', () {
        final schema = SchemaPruefer(leseJson('$repoWurzel/content/party/$ordner/erzaehlerakte.schema.json'));
        expect(schema.pruefe(erzaehlerakteFixture()), isEmpty);
        expect(schema.pruefe({...erzaehlerakteFixture(), 'pfad': 'ahmet'}), isNotEmpty, reason: 'additionalProperties');
        expect(schema.pruefe({...erzaehlerakteFixture(), 'format': 'erzaehlerakte/2'}), isNotEmpty);
        expect(schema.pruefe(_mit(netz: (n) => [{...n.first, 'art': 'liebe'}, ...n.skip(1)])), isNotEmpty);
        expect(schema.pruefe(_mit(netz: (n) => [{...n.first, 'sichtbar': 'halb'}, ...n.skip(1)])), isNotEmpty);
        expect(schema.pruefe(_mit(figuren: (f) => [{...f.first, 'ziel': 'x'}, ...f.skip(1)])), isNotEmpty);
        expect(schema.pruefe(_mit(figuren: (f) => [{...f.first, 'stimme': ['nur einer']}, ...f.skip(1)])), isNotEmpty);
      });
    }
  });

  test('Die Fixture erfüllt den Prüfer (Vollständigkeit, Größen, Netz, pfadfrei, Wörter, Ton)', () {
    final f = _pruefe(erzaehlerakteFixture());
    expect(f, isEmpty, reason: f.join('\n'));
  });

  test('Aus dem Kanon gezogen: Name, Alter, Rolle, Alltag, Motiv, Geheimnis, Nebendelikt, Loyalität, Ziele', () {
    final a = _akte();
    expect([for (final x in a.figuren) x.figur], [for (final f in kanon.figuren) f['id']]);
    final ahmet = a.figur('ahmet')!;
    final k = kanon.figur('ahmet')!;
    expect([ahmet.name, ahmet.alter, ahmet.rolle, ahmet.alltag, ahmet.motiv, ahmet.geheimnis, ahmet.platz],
        [k['name'], k['age'], k['roleTitle'], k['alltag'], k['motiveAndConflict'], k['roleSecret'], 1]);
    expect(ahmet.nebendelikt, (k['nebendelikt'] as Map)['text']);
    expect(ahmet.loyalitaet, (zu: 'leyla', grund: (k['loyalitaet'] as Map)['grund']));
    expect([for (final z in ahmet.ziele) z.toJson()], [{'id': 'persoenlichesZiel', 'text': k['persoenlichesZiel']}]);
    expect(a.figur('olli')!.vollerName, 'Olliver');
    expect(a.figur('tim')!.loyalitaet, isNull);
    expect([a.schneider.person, a.schneider.name, a.schneider.alter], ['schneider', 'Herr Schneider', 61]);
    expect(a.detektiv.person, Besetzung.detektiv);
    expect(a.kantenVon('ahmet').map((x) => x.anderer('ahmet')), containsAll(['leyla', 'johanna', 'fatma', 'tugba', 'schneider']));
  });

  group('Vollständigkeit', () {
    test('fehlende, doppelte und unbekannte Figuren', () {
      final f = _pruefe(_mit(figuren: (l) => [...l.where((x) => x['figur'] != 'tugba'), l.first, {...l.first, 'figur': 'niemand'}]));
      expect(f, containsAll(['Figur tugba fehlt', 'Figur ahmet: doppelt', 'Figur niemand: unbekannt']));
    });

    test('Format und settingId', () {
      final f = _pruefe({...erzaehlerakteFixture(), 'format': 'x', 'settingId': 'anders'});
      expect(f, containsAll(['Format x statt erzaehlerakte/1', 'settingId anders statt spuk_im_schlosskeller']));
    });

    test('Größen: Einleitung, Hintergründe, zu Herrn Schneider, Stimme, Kantentext', () {
      final j = erzaehlerakteFixture();
      final f = _pruefe({
        ...j,
        'einleitung': 'Nur ein Satz.',
        'detektiv': {'hintergrund': 'Zu kurz.', 'stimme': ['Eins.', 'Zwei.']},
        'schneider': {...(j['schneider'] as Map).cast<String, Object?>(), 'stimme': ['Ein Punkt mit viel zu vielen Wörtern für eine Karte hier.']},
        'figuren': [
          for (final x in (j['figuren'] as List).cast<Map>())
            if (x['figur'] == 'can') {...x, 'zuSchneider': [for (var i = 0; i < 41; i++) 'Wort'].join(' ')} else x,
        ],
        'netz': [for (final (i, k) in (j['netz'] as List).cast<Map>().indexed) i == 0 ? {...k, 'text': [for (var i = 0; i < 13; i++) 'Wort'].join(' ')} : k],
      });
      expect(f, containsAll([
        'einleitung: 1 Sätze statt 2 bis 4',
        'detektiv.hintergrund: 2 Wörter statt 40 bis 80',
        'schneider.stimme: 1 Punkte statt 2 bis 3',
        'schneider.stimme[0]: 11 Wörter statt höchstens 8',
        'Figur can.zuSchneider: 41 Wörter statt höchstens 40',
        'Kante ahmet–leyla.text: 13 Wörter statt höchstens 12',
      ]));
    });
  });

  group('Privatsphäre und Pfadgleichheit', () {
    test('toJson ohne Dossier-Schlüssel und ohne geheime Kanonfelder', () {
      final keys = _schluessel(_akte().toJson());
      expect(keys.intersection({'ziel', 'weiss', 'verbirgt', 'tarnung', 'tatwissen', 'killerProfile', 'innocentProfile', 'luegen', 'blackoutAlibi', 'pfad', 'fallCode', 'taeter'}), isEmpty);
      expect(keys, containsAll(['ziele', 'geheimnis', 'nebendelikt', 'motiv', 'loyalitaet', 'zuSchneider', 'stimme', 'netz']));
      final texte = _strings(_akte().toJson()).toSet();
      for (final f in kanon.figuren) {
        for (final feld in ['killerProfile', 'innocentProfile']) {
          for (final t in ((f[feld] as Map?) ?? const {}).values) {
            expect(texte, isNot(contains(t)), reason: '${f['id']}.$feld');
          }
        }
        expect(texte, isNot(contains(f['blackoutAlibi'])), reason: '${f['id']}.blackoutAlibi');
        for (final l in (f['luegen'] as List? ?? const [])) {
          expect(texte.intersection({(l as Map)['wahrheit'], l['duWahrheit']}), isEmpty, reason: '${f['id']} Lüge');
        }
      }
    });

    test('Nie gelesen: Profile, Lügen und Alibi ändern die Akte nicht; die Kernfiguren haben dieselbe Gestalt', () {
      final figuren = leseJson('$repoWurzel/content/party/schlosskeller/figuren.json');
      final verfremdet = {
        ...figuren,
        'figuren': [
          for (final f in (figuren['figuren'] as List).cast<Map>())
            {
              ...f,
              'blackoutAlibi': 'verfremdet',
              'luegen': [for (final l in (f['luegen'] as List? ?? const []).cast<Map>()) {...l, 'wahrheit': 'verfremdet', 'behauptung': 'verfremdet'}],
              if (f['killerProfile'] is Map) 'killerProfile': {for (final k in (f['killerProfile'] as Map).keys) k: 'verfremdet'},
              if (f['innocentProfile'] is Map) 'innocentProfile': {for (final k in (f['innocentProfile'] as Map).keys) k: 'verfremdet'},
            },
        ],
      };
      final k = kanonMit(ersatz: {'figuren.json': verfremdet});
      expect(_akte(null, k).toJson(), _akte().toJson());
      // Gleiche Felder je Kernfigur (der Vollname ist eine Eigenschaft der Figur, kein Pfad).
      final gestalt = {for (final id in kanon.kernverdaechtige) id: (_akte().figur(id)!.toJson().keys.where((x) => x != 'vollerName').toList()..sort()).join(',')};
      expect(gestalt.values.toSet(), hasLength(1), reason: '$gestalt');
    });

    test('Pfadfrei: kein Pfadwissen im zusammengesetzten Dokument', () {
      final verboten = pfadwissenVerboten(kanon);
      final gezogen = {
        for (final x in _akte().figuren)
          for (final t in [x.name, x.alltag, ?x.motiv, ?x.geheimnis, ?x.nebendelikt, ?x.loyalitaet?.grund, for (final z in x.ziele) z.text]) ...fuenfWortFolgen(t),
      };
      final treffer = [
        for (final s in _strings(_akte().toJson()))
          for (final folge in fuenfWortFolgen(s))
            if (verboten.containsKey(folge) && !gezogen.contains(folge)) folge,
      ];
      expect(treffer, isEmpty);
    });

    test('Fehlerprobe: ein Tarnungssatz aus taeter-ahmet.json im Hintergrund wird gemeldet', () {
      final tarnung = _texte.sammlung.taeter['ahmet']!.tarnung;
      final satz = _ton.saetze(tarnung).firstWhere((s) => stichpunktWoerter(s) >= 8);
      final f = _pruefe(_mit(figuren: (l) => [
            for (final x in l) x['figur'] == 'ahmet' ? {...x, 'hintergrund': '${x['hintergrund']} $satz'} : x,
          ]));
      expect(f.where((x) => x.startsWith('figuren[0].hintergrund: „') && x.contains('stammt aus texte/taeter-ahmet.json')), isNotEmpty, reason: f.join('\n'));
    });

    test('Fehlerprobe: Wörter wie Täter oder Pfad nur in Hinweis und Einleitung', () {
      final j = erzaehlerakteFixture();
      final f = _pruefe({
        ...j,
        'einleitung': '${j['einleitung']} Den Täter und den Pfad kennst du nie.',
        'figuren': [
          for (final x in (j['figuren'] as List).cast<Map>())
            if (x['figur'] == 'fatma') {...x, 'stimme': ['Spricht über die Tarnung.', 'Kennt jeden Pfad.']} else x,
        ],
      });
      expect(f, containsAll(['figuren[1].stimme[0]: „Tarnung“ gehört nicht in die Erzählerakte', 'figuren[1].stimme[1]: „Pfad“ gehört nicht in die Erzählerakte']));
      expect(f.where((x) => x.startsWith('einleitung') || x.startsWith('hinweis')), isEmpty, reason: f.join('\n'));
    });
  });

  test('ZielQuelle: Ersatz statt persoenlichesZiel, ohne Pfad', () {
    final quelle = _Sterne();
    final a = _akte(null, null, quelle);
    for (final x in a.figuren) {
      expect([for (final z in x.ziele) z.id], ['${x.figur}.1', '${x.figur}.2']);
    }
    expect(quelle.gefragt, [for (final f in kanon.figuren) f['id']]);
    expect(KanonZiele(kanon).zieleVon('ahmet').single.text, kanon.figur('ahmet')!['persoenlichesZiel']);
    expect(KanonZiele(kanon).zieleVon('niemand'), isEmpty);
    expect(pruefeErzaehlerakte(a, _texte, ton: _ton), isEmpty);
  });

  group('Netz', () {
    test('Loyalität fehlt, Dossier-Paar heimlich, zu wenige Kanten, unbekannter Knoten, Schleife, doppeltes Paar', () {
      final f = _pruefe(_mit(netz: (n) => [
            for (final k in n)
              if (k['a'] == 'olli' && k['b'] == 'kaan')
                null
              else if (k['a'] == 'fatma' && k['b'] == 'emine')
                {...k, 'sichtbar': 'heimlich'}
              else if (k['a'] == 'schneider' && k['b'] == 'serkan')
                {...k, 'b': 'gast'}
              else
                k,
            {'a': 'tim', 'b': 'tim', 'art': 'streit', 'sichtbar': 'heimlich', 'text': 'mit sich selbst'},
            {'a': 'leyla', 'b': 'ahmet', 'art': 'schuld', 'sichtbar': 'heimlich', 'text': 'noch einmal'},
            {'a': 'tim', 'b': 'baran', 'art': 'liebe', 'sichtbar': 'halb', 'text': 'unbekannte Art'},
          ].nonNulls.toList()));
      expect(f, containsAll([
        'Netz: Loyalität olli–kaan ist keine Kante',
        'Netz: Loyalität kaan–olli ist keine Kante',
        'Netz: Dossier fatma nennt Emine, das Paar fatma–emine ist keine öffentliche Kante',
        'Netz: Dossier emine nennt Fatma, das Paar emine–fatma ist keine öffentliche Kante',
        'Kante schneider–gast: Knoten gast unbekannt',
        'Kante tim–tim: verbindet eine Figur mit sich selbst',
        'Kante leyla–ahmet: Paar doppelt (Kante 36)',
        'Kante tim–baran: Art liebe unbekannt',
        'Kante tim–baran: Sichtbarkeit halb unbekannt',
      ]));
      final g = _pruefe(_mit(netz: (n) => [for (final k in n) if (k['a'] != 'serkan' && k['b'] != 'serkan') k]));
      expect(g, containsAll(['Netz: serkan hat 0 Kanten statt mindestens 2', 'Netz: 32 Kanten statt etwa 45 (35 bis 60)']));
    });

    test('Die bekannten öffentlichen Paare aus „Wer du bist“: Lejla–Ahmet, Emine–Fatma, Zeynep–Can', () {
      final paare = {
        for (final f in pruefeErzaehlerakte(_akte(_mit(netz: (n) => [for (final k in n) {...k, 'sichtbar': 'heimlich'}])), _texte))
          if (f.startsWith('Netz: Dossier ')) f.split(' ')[2],
      };
      expect(paare, {'ahmet', 'leyla', 'fatma', 'emine', 'zeynep'});
    });
  });
}

/// Zwei Sterne je Figur, wie sie die Einfluss-Schicht liefern würde (Fixture).
class _Sterne implements ZielQuelle {
  final gefragt = <String>[];
  @override
  List<ErzaehlerZiel> zieleVon(String figur) {
    gefragt.add(figur);
    return [ErzaehlerZiel(id: '$figur.1', text: 'Stern eins'), ErzaehlerZiel(id: '$figur.2', text: 'Stern zwei')];
  }
}
