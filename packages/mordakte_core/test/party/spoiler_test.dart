// S-1 (F3-TEST-01): Am Tisch steht kein Name, keine Qualität und kein Pfadwissen; Preisgaben gelten in allen Pfaden.
import 'package:mordakte_core/mordakte_core.dart';
import 'package:test/test.dart';

import 'kanon_hilfe.dart';

String _datei(String rel) => '$repoWurzel/content/party/schlosskeller/$rel';

/// Textsammlung aus den Dateien des Kanons; [ersatz] ersetzt einzelne Dateien (Rot-Proben).
Textsammlung _sammlungMit([Map<String, Map<String, Object?>> ersatz = const {}]) =>
    Textsammlung.lade((p) => ersatz[p] ?? leseJson(_datei(p)));

Textsammlung? _echt;
Textsammlung get _textsammlung => _echt ??= _sammlungMit();

/// Eine Datei der Textsammlung mit veränderten Einträgen (Rot-Proben).
Map<String, Object?> _geaendert(
  String datei,
  List<Map<String, Object?>> Function(List<Map<String, Object?>> alt) aendern,
) {
  final j = leseJson(_datei(datei));
  final alt = [for (final e in j['eintraege'] as List) (e as Map).cast<String, Object?>()];
  return {...j, 'eintraege': aendern(alt)};
}

final _wortRe = RegExp(r'[\p{L}\p{N}]+', unicode: true);

/// Alle Folgen aus fünf Wörtern eines Textes (klein, ohne Satzzeichen).
Set<String> _fuenfer(String text) {
  final w = [for (final m in _wortRe.allMatches(text.toLowerCase())) m.group(0)!];
  return {for (var i = 0; i + 5 <= w.length; i++) w.sublist(i, i + 5).join(' ')};
}

/// Texte, die nur in einem Teil der Pfade gelten, mit diesen Pfaden (Quelle → (Text, Pfade)): Spuren mit Feld
/// rolle (Pfade, in denen sie entstehen), Beobachtungen mit pfade ungleich „alle“, Täter- und Unschuldsprofil der
/// vier Kernfiguren (eigener Pfad bzw. alle anderen), Ereignisse der vier Tatmatrizen (E-029).
Map<String, (String, Set<String>)> _pfadwissen(Kanon kanon) {
  final alle = kanon.pfade.toSet();
  final spuren = SpurRechner(kanon);
  final q = <String, (String, Set<String>)>{};
  for (final g in kanon.gegenstaende) {
    for (final s in (g['spuren'] as List? ?? const [])) {
      final m = s as Map;
      if (!m.containsKey('rolle')) continue;
      q['Spur ${m['id']}'] = (m['zeigt'] as String, {for (final p in alle) if (spuren.entsteht(m['entstehtWenn'] as Map, p)) p});
    }
  }
  for (final b in kanon.beobachtungen) {
    if (b['pfade'] != 'alle') q['Beobachtung ${b['id']}'] = (b['text'] as String, {for (final p in b['pfade'] as List) p as String});
    if (b['pfade'] != 'alle' && b['duText'] != null) q['Beobachtung ${b['id']} (Du-Fassung)'] = (b['duText'] as String, {for (final p in b['pfade'] as List) p as String});
  }
  for (final k in kanon.kernverdaechtige) {
    for (final (feld, pfade) in [('killerProfile', {k}), ('innocentProfile', alle.difference({k}))]) {
      final profil = kanon.figur(k)![feld] as Map? ?? const {};
      for (final e in profil.entries) {
        if (e.value is String) q['${feld == 'killerProfile' ? 'Täterprofil' : 'Unschuldsprofil'} $k.${e.key}'] = (e.value as String, pfade);
      }
    }
  }
  for (final p in kanon.pfade) {
    for (final e in kanon.json['tatmatrix/$p.json']!['ereignisse'] as List) {
      final m = e as Map;
      if (m['text'] is String) q['Ereignis ${m['id']} (tatmatrix/$p.json)'] = (m['text'] as String, {p});
    }
  }
  return q;
}

/// Folgen aus pfadneutralen Kanon-Texten (Beobachtungen und Zeitleiste mit „alle“, Gegenstandsbeschreibungen).
/// Eine Folge, die dort vorkommt, zählt nicht als Pfadwissen.
Set<String> _pfadneutral(Kanon kanon) {
  final texte = [
    for (final b in kanon.beobachtungen)
      if (b['pfade'] == 'alle') ...[b['text'] as String, ?b['duText'] as String?],
    for (final z in kanon.zeitleiste)
      if (z['pfade'] == 'alle') z['text'] as String,
    for (final g in kanon.gegenstaende)
      if (g['beschreibung'] is String) g['beschreibung'] as String,
  ];
  return {for (final t in texte) ..._fuenfer(t)};
}

/// Folge → Quelle für alle Fünf-Wort-Folgen aus Pfadwissen, die in keinem pfadneutralen Text stehen und nicht
/// in allen Pfaden gelten (etwa dieselbe Wendung im Täter- und im Unschuldsprofil derselben Figur).
Map<String, String> _verboten(Kanon kanon) {
  final neutral = _pfadneutral(kanon);
  final alle = kanon.pfade.toSet();
  final quelle = <String, String>{};
  final pfade = <String, Set<String>>{};
  _pfadwissen(kanon).forEach((q, eintrag) {
    final (text, gilt) = eintrag;
    for (final folge in _fuenfer(text)) {
      if (neutral.contains(folge)) continue;
      quelle.putIfAbsent(folge, () => q);
      (pfade[folge] ??= {}).addAll(gilt);
    }
  });
  return {
    for (final e in quelle.entries)
      if (!pfade[e.key]!.containsAll(alle)) e.key: e.value,
  };
}

/// Texte, die am Tisch stehen (Fundstelle → Text): Erzählerbausteine außer finale.*, rueckblende.* und aufloesung.*,
/// Vorstellung (dossier.wer), Thema, Text und Stichpunkte aller Gespräche, Thema, Fragen und Stichpunkte aller
/// Befragungen (A-051), Frage und Optionen aus den Entscheidungen.
Map<String, String> _tisch(Kanon kanon, Textsammlung t) {
  final tisch = <String, String>{};
  for (final e in t.bausteine.entries) {
    final k = e.key;
    final bereich = t.dateien[t.herkunft[k]]?['bereich'];
    if (bereich != 'erzaehler') continue;
    if (k.startsWith('finale.') || k.startsWith('rueckblende.') || k.startsWith('aufloesung.')) continue;
    tisch['Baustein $k'] = e.value;
  }
  for (final d in t.dossiers.values) {
    tisch['Dossier ${d.rolle}, Vorstellung'] = d.wer;
  }
  for (final g in t.gespraeche) {
    tisch['Gespräch ${g.id}, Thema'] = g.thema;
    tisch['Gespräch ${g.id}, Text'] = g.text;
    for (var i = 0; i < g.stichpunkte.length; i++) {
      tisch['Gespräch ${g.id}, Stichpunkt ${i + 1}'] = g.stichpunkte[i];
    }
  }
  for (final b in t.befragungen.values) {
    tisch['Befragung ${b.id}, Thema'] = b.thema;
    for (var i = 0; i < b.fragen.length; i++) {
      tisch['Befragung ${b.id}, Frage ${i + 1}'] = b.fragen[i];
    }
    for (var i = 0; i < b.stichpunkte.length; i++) {
      tisch['Befragung ${b.id}, Stichpunkt ${i + 1}'] = b.stichpunkte[i];
    }
  }
  for (final e in kanon.entscheidungenJson['entscheidungen'] as List) {
    final m = e as Map;
    tisch['Entscheidung ${m['id']}, Frage'] = m['frage'] as String;
    for (final o in m['optionen'] as List) {
      final om = o as Map;
      tisch['Entscheidung ${m['id']}, Option ${om['id']}'] = om['text'] as String;
    }
  }
  return tisch;
}

/// Schritt 16: Fünf-Wort-Folgen aus Pfadwissen am Tisch, mit Fundstelle, Folge und Quelle.
List<String> _tischFehler(Map<String, String> tisch, Map<String, String> verboten) => [
      for (final e in tisch.entries)
        for (final folge in _fuenfer(e.value))
          if (verboten.containsKey(folge)) '${e.key}: „$folge“ (Quelle: ${verboten[folge]})',
    ];

/// Schritt 14: Der Text nennt keinen Namen aus figuren.json (Feld name, Vollname, Schlossverwalter).
List<String> _namenFehler(Kanon kanon, String? text) {
  if (text == null) return ['Baustein resuemee.rest.eins fehlt'];
  final klein = text.toLowerCase();
  final namen = {
    for (final f in kanon.figuren) f['name'] as String,
    for (final f in kanon.figuren)
      if (f['vollerName'] is String) f['vollerName'] as String,
    ((kanon.figurenJson['opfer'] as Map)['name'] as String).split(' ').last,
  };
  return [
    for (final n in namen)
      if (RegExp(r'(?<!\p{L})' + RegExp.escape(n.toLowerCase()), unicode: true).hasMatch(klein)) 'Name $n im Text',
  ];
}

const _stamm = ['wahr', 'falsch', 'gelogen', 'lüge', 'gerücht', 'sicher', 'richtig'];

/// Wörter, die eine Qualität verraten. Ein Wortanfang reicht, damit auch Beugungen wie „wahrer“ auffallen.
final _verraetRe = RegExp(
  r'(?<!\p{L})(' + _stamm.join('|') + r')\p{L}*|(?<!\p{L})genau\s+gemerkt\p{L}*',
  unicode: true,
);

/// Schritt 15: Der Rahmen (bonus.rahmen und resuemee.gruppe.1 bis .3) verrät keine Qualität.
List<String> _rahmenFehler(Map<String, String?> texte) => [
      for (final e in texte.entries)
        if (e.value == null)
          '${e.key} fehlt'
        else
          for (final m in _verraetRe.allMatches(e.value!.toLowerCase())) '${e.key}: „${m.group(0)}“',
    ];

Map<String, String?> _rahmen(Textsammlung t) => {
      for (final k in ['bonus.rahmen', 'resuemee.gruppe.1', 'resuemee.gruppe.2', 'resuemee.gruppe.3']) k: t.bausteine[k],
    };

/// Schritt 17: Jede Beobachtung in einer Preisgabe gilt in allen Pfaden, am Tisch wie in Befragungen.
List<String> _preisgabeFehler(Kanon kanon, Textsammlung t) {
  final beob = {for (final b in kanon.beobachtungen) b['id'] as String: b};
  return [
    for (final (id, preisgabe) in [
      for (final g in t.gespraeche) (g.id, g.preisgabe),
      for (final b in t.befragungen.values) (b.id, b.preisgabe),
    ])
      for (final p in preisgabe)
        if (p.startsWith('beobachtung:') && beob[p.substring('beobachtung:'.length)]?['pfade'] != 'alle')
          '$id: $p gilt nicht in allen Pfaden',
  ];
}

String _spurZeigt(Kanon kanon, String id) => [
      for (final g in kanon.gegenstaende)
        for (final s in (g['spuren'] as List? ?? const []))
          if ((s as Map)['id'] == id) s['zeigt'] as String,
    ].single;

void main() {
  test('resuemee.rest.eins nennt keinen Namen aus figuren.json', () {
    final f = _namenFehler(kanon, _textsammlung.bausteine['resuemee.rest.eins']);
    expect(f, isEmpty, reason: f.join('\n'));
  });

  test('Rahmen verrät keine Qualität: bonus.rahmen und resuemee.gruppe.1 bis .3', () {
    final f = _rahmenFehler(_rahmen(_textsammlung));
    expect(f, isEmpty, reason: f.join('\n'));
  });

  test('Kein Satz aus Pfadwissen steht am Tisch: keine Fünf-Wort-Folge aus einem Pfad-Text', () {
    final f = _tischFehler(_tisch(kanon, _textsammlung), _verboten(kanon));
    expect(f, isEmpty, reason: f.join('\n'));
  });

  test('Gegenprobe: eine Folge, die auch in einem pfadneutralen Text steht, wird nicht gemeldet', () {
    final pfadwissen = _pfadwissen(kanon);
    final gemeinsam = {for (final (t, _) in pfadwissen.values) ..._fuenfer(t)}.intersection(_pfadneutral(kanon));
    expect(gemeinsam, isNotEmpty, reason: 'keine gemeinsame Folge gefunden, die Gegenprobe wäre leer');
    final folge = gemeinsam.first;
    final tisch = {..._tisch(kanon, _textsammlung), 'Baustein runde.1.start': folge};
    final f = _tischFehler(tisch, _verboten(kanon));
    expect(f.where((x) => x.contains('„$folge“')), isEmpty, reason: f.join('\n'));
  });

  test('Gegenprobe: eine Wendung aus Täter- und Unschuldsprofil derselben Figur gilt in allen Pfaden und ist frei (E-029)', () {
    final v = _verboten(kanon);
    expect(v.keys.where((f) => f.contains('auf der toilette im turm')), isEmpty);
    final can = kanon.figur('can')!;
    final nurTaeter = _fuenfer((can['killerProfile'] as Map)['crimeExecution'] as String)
        .difference(_fuenfer((can['innocentProfile'] as Map)['actualBehavior'] as String))
        .difference(_pfadneutral(kanon));
    expect(nurTaeter.where(v.containsKey), isNotEmpty, reason: 'Täterwissen ohne Gegenstück bleibt verboten');
  });

  test('Preisgaben am Tisch gelten in allen Pfaden', () {
    final f = _preisgabeFehler(kanon, _textsammlung);
    expect(f, isEmpty, reason: f.join('\n'));
  });

  test('Rot-Probe (a): der Spurtext von spur_ring_messing in runde.1.start wird gemeldet', () {
    final tisch = {..._tisch(kanon, _textsammlung), 'Baustein runde.1.start': _spurZeigt(kanon, 'spur_ring_messing')};
    final f = _tischFehler(tisch, _verboten(kanon));
    expect(f.any((x) => x.startsWith('Baustein runde.1.start')), isTrue, reason: f.join('\n'));
  });

  test('Rot-Probe (b): „Ein wahrer Hinweis …“ im Rahmen wird gemeldet', () {
    final rahmen = {..._rahmen(_textsammlung), 'bonus.rahmen': 'Ein wahrer Hinweis …'};
    final f = _rahmenFehler(rahmen);
    expect(f.any((x) => x.startsWith('bonus.rahmen')), isTrue, reason: f.join('\n'));
  });

  test('Rot-Probe (c): „Nur Olli bleibt.“ im Resümee wird gemeldet', () {
    final f = _namenFehler(kanon, 'Nur Olli bleibt.');
    expect(f.any((x) => x.contains('Olli')), isTrue, reason: f.join('\n'));
  });

  test('Die neuen Felder stehen am Tisch: Stichpunkte und Befragungen werden geprüft (A-051)', () {
    final tisch = _tisch(kanon, _textsammlung);
    expect(tisch.keys.where((k) => k.contains(', Stichpunkt ')), isNotEmpty);
    expect(tisch.keys.where((k) => k.startsWith('Befragung ') && k.contains(', Frage ')), hasLength(greaterThanOrEqualTo(120)));
  });

  test('Rot-Probe: Täterwissen in einer Befragungsfrage wird gemeldet', () {
    final v = _verboten(kanon);
    final folge = v.keys.first;
    final tisch = {..._tisch(kanon, _textsammlung), 'Befragung bf_ahmet_1, Frage 1': '$folge?'};
    expect(_tischFehler(tisch, v).where((x) => x.startsWith('Befragung bf_ahmet_1, Frage 1')), isNotEmpty);
  });

  test('Rot-Probe: eine Befragung mit Beobachtung nur für einen Pfad wird gemeldet', () {
    final t = _sammlungMit({
      'texte/befragungen-r1.json': _geaendert(
        'texte/befragungen-r1.json',
        (alt) => [
          for (final e in alt)
            if (e['id'] == 'bf_enes_1') {...e, 'preisgabe': [...(e['preisgabe'] as List), 'beobachtung:b_damir_ahmet_weg']} else e,
        ],
      ),
    });
    expect(_preisgabeFehler(kanon, t), ['bf_enes_1: beobachtung:b_damir_ahmet_weg gilt nicht in allen Pfaden']);
  });

  test('Rot-Probe: eine Preisgabe mit Beobachtung nur für einen Pfad wird gemeldet', () {
    final t = _sammlungMit({
      'texte/gespraeche-r1-b5.json': _geaendert(
        'texte/gespraeche-r1-b5.json',
        (alt) => [
          for (final e in alt)
            if (e['id'] == 'g_enes_1_1')
              {
                ...e,
                'preisgabe': [...(e['preisgabe'] as List), 'beobachtung:b_damir_ahmet_weg'],
              }
            else
              e,
        ],
      ),
    });
    final f = _preisgabeFehler(kanon, t);
    expect(f, ['g_enes_1_1: beobachtung:b_damir_ahmet_weg gilt nicht in allen Pfaden']);
  });
}
