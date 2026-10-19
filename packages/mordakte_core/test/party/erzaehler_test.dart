// F-10 (F3-TEST-01, Erzähler 7.12): Sammlung vollständig; durchgespielte Abende nutzen nur vorhandene Bausteine,
// Finale und Auflösung erst am Ende, Resümee nennt die sichtbare Restmenge.
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

/// Ein durchgespielter Abend: der Spielzustand und der Restschlüssel je Runde (in der Reihenfolge der Runden).
typedef _Abend = ({Spiel s, List<String> rest});

/// Spielt einen Abend bis zum Ende. [option] wählt je Entscheidung, [angeklagt] wird angeklagt,
/// [kooperativ] und [taeterSabotiert] bestimmen die Gruppenwahl je Runde.
_Abend _spiele(
  String pfad,
  int rollen, {
  required String Function(Spiel s, Entscheidung e) option,
  required String angeklagt,
  required int kooperativ,
  required bool taeterSabotiert,
}) {
  final s = Spiel(kanon)..weiter();
  s.einrichten(Einstellungen(rollen: rollen, detektiv: 'w', code: FallCode.fuerPfad(pfad, kanon.pfade)));
  final rest = <String>[];
  for (var schritt = 0; s.phase != PartyPhase.ende; schritt++) {
    if (schritt > 100) throw StateError('Abend bleibt in ${s.phase} hängen');
    switch (s.phase) {
      case PartyPhase.entscheidungen:
        for (final e in s.ermittlung.runde(s.runde)) {
          s.waehle(e.id, option(s, e));
        }
      case PartyPhase.gruppenwahl:
        s.abstimmen(kooperativ: kooperativ, taeterSabotiert: taeterSabotiert);
      case PartyPhase.bonus:
        // Das Resümee dieser Runde entsteht beim Weiterschalten; der Schlüssel gilt für den Stand jetzt.
        rest.add(s.erzaehler.restSchluessel(s.ermittlung.restmenge(s.bekannteFakten(s.runde))));
      case PartyPhase.anklage:
        s.anklagen(angeklagt);
      default:
        break;
    }
    s.weiter();
  }
  return (s: s, rest: rest);
}

/// Ein Lauf der Matrix: Pfad, Besetzung, Spielweise, Gruppe und das Ergebnis.
typedef _Lauf = ({String wo, String pfad, int rollen, _Abend a});

List<_Lauf>? _laeufe;

/// Alle Läufe: Pfad × Besetzung {4, 20} × drei Spielweisen × Gruppe (keine kooperative Stimme, alle kooperativ).
List<_Lauf> get _alleLaeufe {
  if (_laeufe != null) return _laeufe!;
  final laeufe = <_Lauf>[];
  for (final pfad in kanon.pfade) {
    final falsch = kanon.kernverdaechtige.firstWhere((p) => p != pfad);
    final weisen = <String, ({String Function(Spiel, Entscheidung) option, String angeklagt})>{
      'bestes Spiel, Anklage des Täters': (option: (s, e) => e.richtig[pfad]!, angeklagt: pfad),
      'erste Option, falsche Anklage': (option: (s, e) => s.optionen(e.id).first.id, angeklagt: falsch),
      'letzte Option, Anklage des Täters': (option: (s, e) => s.optionen(e.id).last.id, angeklagt: pfad),
    };
    for (final rollen in [4, 20]) {
      final gruppen = [
        (name: 'keine kooperative Stimme', kooperativ: 0, sabotiert: true),
        (name: 'alle kooperativ', kooperativ: rollen - 1, sabotiert: false),
      ];
      for (final w in weisen.entries) {
        for (final g in gruppen) {
          final a = _spiele(
            pfad,
            rollen,
            option: w.value.option,
            angeklagt: w.value.angeklagt,
            kooperativ: g.kooperativ,
            taeterSabotiert: g.sabotiert,
          );
          laeufe.add((wo: '$pfad, $rollen Rollen, ${w.key}, ${g.name}', pfad: pfad, rollen: rollen, a: a));
        }
      }
    }
  }
  return _laeufe = laeufe;
}

/// Schritt 10: Jede Kennung eines Abends gibt es (Hinweise aus bonus.json, alles andere aus der Sammlung).
/// Finale und Rückblende kommen genau einmal vor, Auflösung „taeter“ nur für die Täterperson.
List<String> _kennungFehler(
  List<String> bausteine,
  Textsammlung t,
  Set<String> hinweise, {
  required String pfad,
  required String ende,
  required Set<String> besetzteKern,
}) {
  final f = <String>[];
  for (final k in bausteine) {
    if (k.startsWith('hinweis.')) {
      if (!hinweise.contains(k.substring('hinweis.'.length))) f.add('$k: kein Hinweis in bonus.json');
    } else if (!t.bausteine.containsKey(k)) {
      f.add('$k: nicht in der Textsammlung');
    }
  }
  int anzahl(String k) => bausteine.where((x) => x == k).length;
  if (anzahl('finale.$pfad.$ende') != 1) f.add('finale.$pfad.$ende: ${anzahl('finale.$pfad.$ende')} statt 1');
  if (anzahl('rueckblende.$pfad') != 1) f.add('rueckblende.$pfad: ${anzahl('rueckblende.$pfad')} statt 1');
  final finale = bausteine.where((x) => x.startsWith('finale.')).length;
  if (finale != 1) f.add('$finale Finaltexte statt 1');
  for (final k in besetzteKern) {
    final taeter = anzahl('aufloesung.$k.taeter');
    // Bei eigenem Pfadverhalten erzählt die Pfadfassung der Unschuld (E-039).
    final unschuldig = anzahl('aufloesung.$k.unschuldig') + anzahl('aufloesung.$k.unschuldig.$pfad');
    if (k == pfad) {
      if (taeter != 1 || unschuldig != 0) f.add('aufloesung.$k: Täterfassung $taeter, unschuldig $unschuldig');
    } else if (taeter != 0 || unschuldig != 1) {
      f.add('aufloesung.$k: taeter $taeter, unschuldig $unschuldig (nur unschuldig)');
    }
  }
  return f;
}

const _vorFinale = ['intro.', 'runde.', 'npc.', 'bonus.rahmen', 'hinweis.', 'resuemee.', 'anklage.'];

/// Schritt 11: Vor dem ersten finale.-Baustein steht nichts aus Finale, Rückblende oder Auflösung.
List<String> _vorFinaleFehler(List<String> bausteine) {
  final erster = bausteine.indexWhere((k) => k.startsWith('finale.'));
  if (erster < 0) return ['kein finale.-Baustein im Abend'];
  return [
    for (final k in bausteine.take(erster))
      if (!_vorFinale.any((p) => k.startsWith(p))) 'vor dem Finale: $k',
  ];
}

/// Schritt 12: Das Resümee jeder Runde nennt genau die Restmenge des Stands dieser Runde.
List<String> _restFehler(List<String> ist, List<String> soll) {
  final f = <String>[];
  if (ist.length != soll.length) f.add('${ist.length} Restschlüssel statt ${soll.length}');
  for (var i = 0; i < soll.length && i < ist.length; i++) {
    if (ist[i] != soll[i]) f.add('Runde ${i + 1}: ${ist[i]} statt ${soll[i]}');
  }
  return f;
}

void main() {
  final hinweise = {for (final h in kanon.bonusJson['hinweise'] as List) (h as Map)['id'] as String};

  test('Sammlung vollständig: keine Erzähler-, Dossier-, Gesprächs-, Wahl- oder Täterlücke', () {
    final f = textLuecken(kanon, _textsammlung);
    expect(f, isEmpty, reason: f.join('\n'));
  });

  test('Intro (K1): Ankunft und Stromausfall als zwei Bausteine, danach die Lacher und der Auftrag', () {
    final s = Spiel(kanon)..weiter();
    s.einrichten(Einstellungen(rollen: 4, detektiv: 'm', code: FallCode.fuerPfad('can', kanon.pfade)));
    s.weiter();
    expect(s.bausteine, [
      'intro.start',
      'intro.ausfall',
      for (final l in kanon.json['setting.json']!['lacher'] as List)
        'intro.lacher.${(l as Map)['id']}.${s.besetzung.istBesetzt(l['wer'] as String, 4) ? 'besetzt' : 'npc'}',
      'intro.auftrag.m',
    ]);
    expect(s.bausteine, hasLength(6), reason: 'sechs Bilder für die Diashow');
    // Akten ohne setting.introTeile behalten ihr Intro.
    expect(Erzaehler(ladeKanon('gewoelbe')).introTeile, isEmpty);
  });

  test('Durchgespielte Abende nutzen nur vorhandene Bausteine (Pfade, 4 und 20 Rollen, drei Spielweisen, zwei Gruppen)', () {
    expect(_alleLaeufe, hasLength(48), reason: 'Matrix: 4 Pfade × 2 Besetzungen × 3 Spielweisen × 2 Gruppen');
    final f = <String>[];
    for (final l in _alleLaeufe) {
      final besetzteKern = {for (final k in kanon.kernverdaechtige) if (l.a.s.besetzung.istBesetzt(k, l.rollen)) k};
      f.addAll(_kennungFehler(
        l.a.s.bausteine,
        _textsammlung,
        hinweise,
        pfad: l.pfad,
        ende: l.a.s.ende.id,
        besetzteKern: besetzteKern,
      ).map((x) => '${l.wo}: $x'));
    }
    expect(f, isEmpty, reason: f.join('\n'));
  });

  test('Wissen unbesetzter Gäste (W1, E-035): nur bei unbesetzter Figur, gleich in allen Pfaden', () {
    final e = Erzaehler(kanon);
    expect(e.npcPlan, isNotEmpty);
    final f = <String>[];
    for (var n = 4; n <= 20; n++) {
      final b = Besetzung(kanon);
      for (var r = 1; r <= 3; r++) {
        final bloecke = e.npcWissen(r, besetzt: (x) => b.istBesetzt(x, n));
        for (final k in bloecke) {
          final figur = k.split('.')[1];
          if (b.istBesetzt(figur, n)) f.add('$n/$r: $k, obwohl $figur besetzt ist');
          if (!_textsammlung.bausteine.containsKey(k)) f.add('$n/$r: $k fehlt in der Textsammlung');
        }
        // Gespielte Abende: der Rundenstart ist in jedem Pfad derselbe.
        final je = {
          for (final p in kanon.pfade)
            p: (Spiel(kanon)..einrichten(Einstellungen(rollen: n, detektiv: 'w', code: FallCode.fuerPfad(p, kanon.pfade)))).erzaehler.rundenStart(
              r,
              besetzt: (x) => b.istBesetzt(x, n),
            ),
        };
        if (je.values.map((l) => l.join(',')).toSet().length != 1) f.add('$n/$r: Rundenstart hängt am Pfad: $je');
      }
    }
    expect(f, isEmpty, reason: f.join('\n'));
    // Bei voller Besetzung spricht der Erzähler kein Gästewissen.
    for (var r = 1; r <= 3; r++) {
      expect(e.npcWissen(r, besetzt: (_) => true), isEmpty);
    }
  });

  test('Wissen unbesetzter Zielfiguren (E-044): nur im Modell befragung, nur unbesetzt, nur Beobachtungen aller Pfade', () {
    final e = Erzaehler(kanon);
    final beob = {for (final b in kanon.beobachtungen) b['id'] as String: b};
    final ziele = {
      for (final x in e.kanon.entscheidungenJson['entscheidungen'] as List)
        for (final o in (x as Map)['optionen'] as List)
          if (((o as Map)['ziel'] as Map?)?['person'] case final String p) p,
    };
    // Die Zielfiguren mit Kettenwissen, je in der Runde, in der eine Kette es zuerst braucht.
    final zielPlan = {
      for (final r in e.npcPlan.entries)
        for (final f in r.value.entries)
          if (ziele.contains(f.key)) 'npc.${f.key}.${r.key}': f.value,
    };
    expect(zielPlan, {
      'npc.emine.1': ['b_emine_versteck'],
      'npc.dilara.1': ['b_azra_versteck'],
      'npc.enes.1': ['b_damir_an_der_theke'],
      'npc.dilara.2': ['b_azra_tasche'],
      'npc.zeynep.3': ['b_zeynep_gesicht'],
      'npc.aylin.3': ['b_aylin_quittung'],
    });
    for (final r in e.npcPlan.values) {
      for (final l in r.values) {
        for (final b in l) {
          // Pfadneutral wie E-035: Der Erzähler spricht nur, was in allen Pfaden gilt.
          expect([beob[b]!['pfade'], beob[b]!['kanal']], ['alle', 'pflichtgespraech'], reason: b);
        }
      }
    }
    for (final k in zielPlan.keys) {
      expect(_textsammlung.herkunft[k], 'texte/erzaehler-npc-ziel.json', reason: k);
    }
    // Bei 4 Rollen spricht der Erzähler in Runde 1 über Emine, Azra und Damir; ab 17 Rollen spielt sie jemand.
    final b = Besetzung(kanon);
    expect(e.npcWissen(1, besetzt: (x) => b.istBesetzt(x, 4)), ['npc.emine.1', 'npc.dilara.1', 'npc.enes.1']);
    expect(e.npcWissen(1, besetzt: (x) => b.istBesetzt(x, 17)), isEmpty);
    expect(e.npcWissen(3, besetzt: (x) => b.istBesetzt(x, 12)), ['npc.aylin.3', 'npc.kaan.3', 'npc.selin.3']);
    // Die Akten im Modell legacy behalten ihren Erzähler: Ziel-Figuren sprechen dort selbst.
    for (final akte in ['gewoelbe', 'ravensmoor', 'nachtexpress', 'blue_palm']) {
      final k = ladeKanon(akte);
      expect(Besetzung(k).modell, GespraechsModell.legacy, reason: akte);
      expect(Erzaehler(k).npcPlan, isEmpty, reason: akte);
    }
  });

  test('Vor dem Finale nichts aus Finale, Rückblende oder Auflösung', () {
    final f = <String>[];
    for (final l in _alleLaeufe) {
      f.addAll(_vorFinaleFehler(l.a.s.bausteine).map((x) => '${l.wo}: $x'));
    }
    expect(f, isEmpty, reason: f.join('\n'));
  });

  test('Resümee nennt genau die sichtbare Restmenge je Runde', () {
    final f = <String>[];
    for (final l in _alleLaeufe) {
      expect(l.a.rest, hasLength(3), reason: '${l.wo}: drei Runden mit Resümee');
      final ist = [for (final k in l.a.s.bausteine) if (k.startsWith('resuemee.rest.')) k];
      f.addAll(_restFehler(ist, l.a.rest).map((x) => '${l.wo}: $x'));
    }
    expect(f, isEmpty, reason: f.join('\n'));
  });

  // F-15: In jedem der 16 Finaltexte steht der Pflichtsatz; kein Finale nennt Blut oder Wunden (E-029).
  List<String> pflichtsatzFehler(Textsammlung t) => [
        for (final e in t.bausteine.entries)
          if (e.key.startsWith('finale.')) ...[
            if (!e.value.contains('Herr Schneider überlebt')) '${e.key}: Pflichtsatz „Herr Schneider überlebt“ fehlt',
            if (RegExp(r'\b(Blut|blutet|blutig|Wunde)', caseSensitive: false).hasMatch(e.value)) '${e.key}: Blut oder Wunde',
          ],
      ];

  test('Jedes Finale enthält „Herr Schneider überlebt“, keines Blut oder Wunde (F-15)', () {
    final finale = _textsammlung.bausteine.keys.where((k) => k.startsWith('finale.'));
    expect(finale, hasLength(16));
    final f = pflichtsatzFehler(_textsammlung);
    expect(f, isEmpty, reason: f.join('\n'));
  });

  test('Rot-Probe: ein Finale ohne Pflichtsatz wird gemeldet', () {
    final t = _sammlungMit({
      'texte/erzaehler-finale-olli.json': {
        ...leseJson(_datei('texte/erzaehler-finale-olli.json')),
        'eintraege': [
          for (final e in leseJson(_datei('texte/erzaehler-finale-olli.json'))['eintraege'] as List)
            if ((e as Map)['id'] == 'finale.olli.ende_meister') {...e, 'text': 'Olli gesteht. Alle gehen nach Hause.'} else e,
        ],
      },
    });
    expect(pflichtsatzFehler(t), contains('finale.olli.ende_meister: Pflichtsatz „Herr Schneider überlebt“ fehlt'));
  });

  test('Rot-Probe: ein fehlender Finaltext wird in der Lückenliste genannt', () {
    final t = _sammlungMit({
      'texte/erzaehler-finale-ahmet.json': _geaendert(
        'texte/erzaehler-finale-ahmet.json',
        (alt) => [for (final e in alt) if (e['id'] != 'finale.ahmet.ende_meister') e],
      ),
    });
    final f = textLuecken(kanon, t);
    expect(f.any((x) => x.contains('finale.ahmet.ende_meister')), isTrue, reason: f.join('\n'));
  });

  test('Rot-Probe: fremde Kennung und fehlender Hinweis werden gemeldet', () {
    final f = _kennungFehler(
      ['intro.start', 'intro.fremd.xyz', 'hinweis.h_gibt_es_nicht', 'finale.ahmet.ende_meister', 'rueckblende.ahmet'],
      _textsammlung,
      hinweise,
      pfad: 'ahmet',
      ende: 'ende_meister',
      besetzteKern: {'ahmet'},
    );
    expect(f.any((x) => x.startsWith('intro.fremd.xyz')), isTrue, reason: f.join('\n'));
    expect(f.any((x) => x.startsWith('hinweis.h_gibt_es_nicht')), isTrue, reason: f.join('\n'));
  });

  test('Rot-Probe: eine Auflösung vor dem Finale wird gemeldet', () {
    final f = _vorFinaleFehler(['intro.start', 'aufloesung.gruppe.1', 'finale.ahmet.ende_meister']);
    expect(f, ['vor dem Finale: aufloesung.gruppe.1']);
  });

  test('Rot-Probe: ein falscher Restschlüssel im Resümee wird gemeldet', () {
    final f = _restFehler(['resuemee.rest.eins'], ['resuemee.rest.alle']);
    expect(f, ['Runde 1: resuemee.rest.eins statt resuemee.rest.alle']);
  });
}
