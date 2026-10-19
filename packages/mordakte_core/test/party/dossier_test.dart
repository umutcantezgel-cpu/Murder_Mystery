// F-11 (F3-TEST-01): Dossiers je Rolle, Pfad und Besetzung; Geheimnisregeln und Pflichtgespräche nach SCHLUESSEL.md.
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

List<String> _rollen(Kanon kanon) => [for (final x in kanon.figuren) x['id'] as String];

/// Zeigt-Texte aller Spuren, die im Pfad [p] entstehen und dort für [p] Schlüsselbeweis, Zusatzindiz oder Fundort sind.
List<String> _tatSpuren(Kanon kanon, Texte texte, String p) {
  const typen = {'schluesselbeweis', 'zusatzindiz', 'fundort'};
  final f = <String>[];
  for (final g in kanon.gegenstaende) {
    for (final s in (g['spuren'] as List? ?? const [])) {
      final m = s as Map;
      final rolle = m['rolle'] as Map;
      if (typen.contains(rolle[p]) && texte.spuren.entsteht(m['entstehtWenn'] as Map, p)) {
        f.add(m['zeigt'] as String);
      }
    }
  }
  return f;
}

/// Schritt 1: Jedes Dossier lässt sich für jede besetzte Rolle, jeden Pfad und die Besetzungen 4, 12 und 20 zusammensetzen.
List<String> _zusammensetzungFehler(Kanon kanon, Textsammlung t) {
  final texte = Texte(kanon, t);
  final f = <String>[];
  for (final n in [4, 12, 20]) {
    for (final r in texte.besetzung.besetzt(n)) {
      for (final p in kanon.pfade) {
        final wo = '$r in $p bei $n Rollen';
        try {
          final d = texte.dossier(r, p, n);
          if (d.wer.isEmpty) f.add('$wo: wer ist leer');
          if (d.ziel.isEmpty) f.add('$wo: ziel ist leer');
          if (d.besetzung.isEmpty) f.add('$wo: besetzung ist leer');
        } catch (e) {
          f.add('$wo: wirft $e');
        }
      }
    }
  }
  return f;
}

/// Schritt 2: Die Täterfassung gehört nur dem eigenen Pfad. Dort enthält das Tatwissen alle Tatspuren des Pfads.
List<String> _taeterFehler(Kanon kanon, Textsammlung t) {
  final texte = Texte(kanon, t);
  final f = <String>[];
  for (final r in kanon.kernverdaechtige) {
    for (final p in kanon.pfade) {
      final d = texte.dossier(r, p, 4);
      final wo = '$r in $p';
      if (r != p) {
        if (d.taeter) f.add('$wo: Täterfassung in fremdem Pfad');
        if (d.tatwissen.isNotEmpty) f.add('$wo: Tatwissen in fremdem Pfad');
        continue;
      }
      if (!d.taeter) f.add('$wo: keine Täterfassung im eigenen Pfad');
      if ((d.tarnung ?? '').isEmpty) f.add('$wo: Tarnung fehlt');
      final erwartet = _tatSpuren(kanon, texte, p);
      if (erwartet.isEmpty) f.add('$wo: keine Tatspur im Pfad');
      for (final z in erwartet) {
        if (!d.tatwissen.any((x) => x.text == z)) f.add('$wo: Spur fehlt im Tatwissen: „$z“');
      }
    }
  }
  return f;
}

/// Schritt 3: Verweise unter `weiss` (Rohdaten) zeigen nicht auf verborgene Beobachtungen, Nebendelikte oder Lügen.
List<String> _weissGeheimnisse(Kanon kanon, Textsammlung t) {
  final texte = Texte(kanon, t);
  final f = <String>[];
  for (final d in t.dossiers.values) {
    for (final p in d.weiss) {
      final ref = p.ref;
      if (ref == null) continue;
      final teile = ref.split(':');
      final art = teile.first;
      final b = art == 'beobachtung' ? texte.beobachtung(teile.last) : null;
      final geheim = art == 'nebendelikt' ||
          art == 'luege' ||
          (art == 'beobachtung' && (b == null || b['kanal'] == 'verborgen'));
      if (geheim) f.add('Dossier ${d.rolle}, weiss: $ref ist geheim oder unbekannt');
    }
  }
  return f;
}

/// Schritt 4: `verbirgt` enthält je Rolle und Pfad die eigenen verborgenen Beobachtungen im Pfad, das Nebendelikt und alle Lügen.
List<String> _verbirgtFehler(Kanon kanon, Textsammlung t) {
  final texte = Texte(kanon, t);
  final f = <String>[];
  for (final r in _rollen(kanon)) {
    final figur = kanon.figur(r)!;
    for (final p in kanon.pfade) {
      final v = texte.dossier(r, p, 4).verbirgt;
      final wo = '$r in $p';
      for (final b in kanon.beobachtungen) {
        if (b['wer'] != r || b['kanal'] != 'verborgen' || !Kanon.giltIn(b['pfade'], p)) continue;
        if (!v.any((z) => z.art == 'beobachtung' && z.text == (b['duText'] ?? b['text']))) {
          f.add('$wo: verborgene Beobachtung ${b['id']} fehlt');
        }
      }
      for (final n in kanon.gegenstaendeJson['nebendelikte'] as List) {
        final m = n as Map;
        if (m['person'] == r && !v.any((z) => z.art == 'nebendelikt' && z.text == (m['duText'] ?? m['text']))) {
          f.add('$wo: Nebendelikt ${m['id']} fehlt');
        }
      }
      for (final l in (figur['luegen'] as List? ?? const [])) {
        final m = l as Map;
        final behauptet = m['behauptung'];
        if (!v.any((z) => z.art == 'luege' && (z.behauptung ?? '').isNotEmpty && z.behauptung == behauptet)) {
          f.add('$wo: Lüge ${m['id']} fehlt');
        }
      }
    }
  }
  return f;
}

/// Schritt 5: je besetzter Rolle und Besetzung 4 bis 20 je Runde so viele Gespräche, wie das Gesprächsmodell
/// verlangt (legacy drei mit den Nummern 1 bis 3, befragung eines; A-051), Partner besetzt und nie die Rolle selbst;
/// im Modell befragung je Runde die eigene Befragung und genau eine Person, die die Rolle anspricht.
List<String> _gespraechFehler(Kanon kanon, Textsammlung t) {
  final texte = Texte(kanon, t);
  final b = texte.besetzung;
  final je = b.tischJeRolle;
  final soll = [for (var i = 1; i <= je; i++) i].join(',');
  final f = <String>[];
  for (var n = b.minRollen; n <= b.maxRollen; n++) {
    for (final r in b.besetzt(n)) {
      for (final p in kanon.pfade) {
        final d = texte.dossier(r, p, n);
        for (var runde = 1; runde <= 3; runde++) {
          final l = d.gespraeche[runde] ?? const <(Gespraech, String)>[];
          final wo = '$r, Runde $runde, $n Rollen';
          if (l.length != je) f.add('$wo: ${l.length} statt $je Gespräche');
          final nrs = [for (final x in l) x.$1.nr];
          if (nrs.join(',') != soll) f.add('$wo: Nummern $nrs statt $soll');
          for (final x in l) {
            if (!b.istBesetzt(x.$2, n)) f.add('$wo: Partner ${x.$2} ist nicht besetzt');
            if (x.$2 == r) f.add('$wo: Partner ist die Rolle selbst');
          }
          if (b.befragungsmodell) {
            if (d.befragungen[runde]?.id != BefragungText.kennung(r, runde)) f.add('$wo: eigene Befragung fehlt');
            if ((d.alsPartner[runde] ?? const []).length != 1) f.add('$wo: ${(d.alsPartner[runde] ?? const []).length} Personen sprechen die Rolle an statt 1');
          }
        }
      }
    }
  }
  return f;
}

/// Schritt 6: je Rolle und Runde ein Wahltext; die Sabotage steht genau bei Kernrollen im eigenen Pfad.
List<String> _wahlFehler(Kanon kanon, Textsammlung t) {
  final texte = Texte(kanon, t);
  final f = <String>[];
  for (final r in _rollen(kanon)) {
    for (final p in kanon.pfade) {
      final d = texte.dossier(r, p, 4);
      final soll = r == p && kanon.kernverdaechtige.contains(r);
      for (var runde = 1; runde <= 3; runde++) {
        final w = d.wahlen[runde];
        final wo = '$r in $p, Runde $runde';
        if (w == null) {
          f.add('$wo: kein Wahltext');
          continue;
        }
        if (soll && w.sabotage == null) f.add('$wo: Sabotage fehlt');
        if (!soll && w.sabotage != null) f.add('$wo: Sabotage ohne Recht');
      }
    }
  }
  return f;
}

const _platzhalter = ['OFFENE FRAGE', 'TODO', 'XXX', '<', '>'];

/// Schritt 7: Kein Text in Dossiers, Täterfassungen, Gesprächen oder Wahlen enthält einen Platzhalter.
List<String> _platzhalterFehler(Kanon kanon, Textsammlung t) {
  final texte = Texte(kanon, t);
  final f = <String>[];
  void pruefe(String wo, String? s) {
    if (s == null) return;
    final klein = s.toLowerCase();
    for (final v in _platzhalter) {
      if (klein.contains(v.toLowerCase())) f.add('$wo enthält „$v“');
    }
  }

  for (final d in t.dossiers.values) {
    pruefe('Dossier ${d.rolle}', d.wer);
    pruefe('Dossier ${d.rolle}', d.ziel);
    pruefe('Dossier ${d.rolle}', d.besetzung);
    for (final z in [...d.weiss, ...d.verbirgt]) {
      pruefe('Dossier ${d.rolle}', z.text);
    }
  }
  for (final x in t.taeter.values) {
    pruefe('Täterfassung ${x.rolle}', x.tarnung);
    pruefe('Täterfassung ${x.rolle}', x.ziel);
    for (final z in [...x.tatwissen, ...x.verbirgt]) {
      pruefe('Täterfassung ${x.rolle}', z.text);
    }
  }
  for (final g in t.gespraeche) {
    pruefe('Gespräch ${g.id}', g.thema);
    pruefe('Gespräch ${g.id}', g.ziel);
    pruefe('Gespräch ${g.id}', g.text);
    for (final x in g.stichpunkte) {
      pruefe('Gespräch ${g.id}', x);
    }
  }
  for (final b in t.befragungen.values) {
    for (final x in [b.thema, ...b.fragen, ...b.stichpunkte]) {
      pruefe('Befragung ${b.id}', x);
    }
  }
  for (final w in t.wahlen.values) {
    pruefe('Wahl ${w.id}', w.a);
    pruefe('Wahl ${w.id}', w.b);
    pruefe('Wahl ${w.id}', w.sabotage);
  }
  for (final r in _rollen(kanon)) {
    for (final p in kanon.pfade) {
      final d = texte.dossier(r, p, 4);
      final wo = '$r in $p';
      pruefe(wo, d.wer);
      pruefe(wo, d.ziel);
      pruefe(wo, d.besetzung);
      pruefe(wo, d.tarnung);
      for (final z in [...d.weiss, ...d.verbirgt, ...d.tatwissen]) {
        pruefe(wo, z.text);
        pruefe(wo, z.behauptung);
      }
      for (final l in d.gespraeche.values) {
        for (final x in l) {
          pruefe(wo, x.$1.thema);
          pruefe(wo, x.$1.ziel);
          pruefe(wo, x.$1.text);
          for (final y in x.$1.stichpunkte) {
            pruefe(wo, y);
          }
        }
      }
      for (final w in d.wahlen.values) {
        if (w == null) continue;
        pruefe(wo, w.a);
        pruefe(wo, w.b);
        pruefe(wo, w.sabotage);
      }
    }
  }
  return f;
}

void main() {
  test('Jedes Dossier lässt sich zusammensetzen: alle Rollen, Pfade, Besetzung 4, 12 und 20', () {
    final f = _zusammensetzungFehler(kanon, _textsammlung);
    expect(f, isEmpty, reason: f.join('\n'));
  });

  test('Rot-Probe: ein fehlendes Dossier wird beim Zusammensetzen gemeldet', () {
    final t = _sammlungMit({
      'texte/dossiers-b5.json': _geaendert('texte/dossiers-b5.json', (alt) => [for (final e in alt) if (e['rolle'] != 'enes') e]),
    });
    final f = _zusammensetzungFehler(kanon, t);
    expect(f.any((x) => x.startsWith('enes in ') && x.contains('wirft')), isTrue, reason: f.join('\n'));
  });

  test('Täterfassung nur im eigenen Pfad: Tatwissen mit allen Tatspuren des Pfads, sonst leer', () {
    final f = _taeterFehler(kanon, _textsammlung);
    expect(f, isEmpty, reason: f.join('\n'));
  });

  test('Unter „weiss“ steht kein Geheimnis: keine verborgene Beobachtung, kein Nebendelikt, keine Lüge', () {
    final f = _weissGeheimnisse(kanon, _textsammlung);
    expect(f, isEmpty, reason: f.join('\n'));
  });

  test('„verbirgt“ ist vollständig: verborgene Beobachtungen, Nebendelikt und jede Lüge je Pfad', () {
    final f = _verbirgtFehler(kanon, _textsammlung);
    expect(f, isEmpty, reason: f.join('\n'));
  });

  test('Gespräche je Besetzung 4 bis 20 nach Gesprächsmodell: Anzahl, Nummern, Partner besetzt, Befragung', () {
    final f = _gespraechFehler(kanon, _textsammlung);
    expect(f, isEmpty, reason: f.join('\n'));
  });

  test('Wahltexte: je Rolle und Runde einer, Sabotage nur bei Kernrollen im eigenen Pfad', () {
    final f = _wahlFehler(kanon, _textsammlung);
    expect(f, isEmpty, reason: f.join('\n'));
  });

  test('Keine Platzhalter in Dossiers, Täterfassungen, Gesprächen und Wahlen', () {
    final f = _platzhalterFehler(kanon, _textsammlung);
    expect(f, isEmpty, reason: f.join('\n'));
  });

  test('Rot-Probe: verborgene Beobachtung unter „weiss“ wird gemeldet', () {
    final t = _sammlungMit({
      'texte/dossiers-b1.json': _geaendert(
        'texte/dossiers-b1.json',
        (alt) => [
          for (final e in alt)
            if (e['rolle'] == 'ahmet') {...e, 'weiss': [{'ref': 'beobachtung:b_damir_ahmet_blieb'}]} else e,
        ],
      ),
    });
    final f = _weissGeheimnisse(kanon, t);
    expect(f, isNotEmpty);
    expect(f.single, contains('b_damir_ahmet_blieb'));
  });

  test('Rot-Probe: fehlende Tatspur im Tatwissen wird gemeldet', () {
    final t = _sammlungMit({
      'texte/taeter-ahmet.json': _geaendert(
        'texte/taeter-ahmet.json',
        (alt) => [
          for (final e in alt)
            {
              ...e,
              'tatwissen': [
                for (final z in e['tatwissen'] as List)
                  if ((z as Map)['ref'] != 'spur:spur_griff_papier') z,
              ],
            },
        ],
      ),
    });
    final f = _taeterFehler(kanon, t);
    expect(f.where((x) => x.startsWith('ahmet in ahmet') && x.contains('Spur fehlt')), hasLength(1));
  });

  test('Rot-Probe: fehlende Lüge im „verbirgt“ wird gemeldet', () {
    final t = _sammlungMit({
      'texte/dossiers-b1.json': _geaendert(
        'texte/dossiers-b1.json',
        (alt) => [
          for (final e in alt)
            if (e['rolle'] == 'fatma')
              {
                ...e,
                'verbirgt': [
                  for (final z in e['verbirgt'] as List)
                    if ((z as Map)['ref'] != 'luege:luege_fatma_buffet') z,
                ],
              }
            else
              e,
        ],
      ),
    });
    final f = _verbirgtFehler(kanon, t);
    expect(f.any((x) => x == 'fatma in ahmet: Lüge luege_fatma_buffet fehlt'), isTrue, reason: f.join('\n'));
  });

  test('Rot-Probe: ein Tischgespräch zu wenig wird gemeldet', () {
    final t = _sammlungMit({
      'texte/gespraeche-r1-b1.json': _geaendert(
        'texte/gespraeche-r1-b1.json',
        (alt) => [for (final e in alt) if (e['id'] != 'g_ahmet_1_1') e],
      ),
    });
    final f = _gespraechFehler(kanon, t);
    expect(f.any((x) => x.startsWith('ahmet, Runde 1') && x.contains('0 statt 1')), isTrue, reason: f.join('\n'));
  });

  test('Rot-Probe: eine falsche Gesprächsnummer wird gemeldet', () {
    final t = _sammlungMit({
      'texte/gespraeche-r1-b1.json': _geaendert(
        'texte/gespraeche-r1-b1.json',
        (alt) => [for (final e in alt) if (e['id'] == 'g_ahmet_1_1') {...e, 'nr': 5} else e],
      ),
    });
    final f = _gespraechFehler(kanon, t);
    expect(f.any((x) => x.startsWith('ahmet, Runde 1') && x.contains('Nummern')), isTrue, reason: f.join('\n'));
  });

  test('Rot-Probe: fehlende Sabotage bei einer Kernrolle im eigenen Pfad wird gemeldet', () {
    final t = _sammlungMit({
      'texte/wahlen-kern.json': _geaendert(
        'texte/wahlen-kern.json',
        (alt) => [for (final e in alt) if (e['id'] == 'gw_ahmet_1') {...e, 'sabotage': null} else e],
      ),
    });
    final f = _wahlFehler(kanon, t);
    expect(f, contains('ahmet in ahmet, Runde 1: Sabotage fehlt'));
  });

  test('Rot-Probe: ein Platzhalter „TODO“ im Dossier wird gemeldet', () {
    final t = _sammlungMit({
      'texte/dossiers-b1.json': _geaendert(
        'texte/dossiers-b1.json',
        (alt) => [
          for (final e in alt) if (e['rolle'] == 'ahmet') {...e, 'wer': '${e['wer']} TODO'} else e,
        ],
      ),
    });
    final f = _platzhalterFehler(kanon, t);
    expect(f.any((x) => x.contains('TODO')), isTrue, reason: f.join('\n'));
  });

  test('Beobachtungen der eigenen Rolle stehen im Dossier in der Du-Form (E-032)', () {
    // In der dritten Person über sich selbst („roch sie“, „neben ihm“) liest
    // sich das eigene Dossier falsch. Wer eine Du-Fassung hat, bekommt sie.
    final texte = Texte(kanon, _textsammlung);
    final fehler = <String>[];
    final selbst = RegExp(r'\b(sie|er|ihr|ihm|ihn)\b');
    for (final f in kanon.figuren) {
      final r = f['id'] as String;
      for (final p in kanon.pfade) {
        final d = texte.dossier(r, p, 20);
        for (final z in [...d.weiss, ...d.verbirgt, ...d.tatwissen]) {
          if (z.art != 'beobachtung') continue;
          final b = kanon.beobachtungen.firstWhere((b) => (b['duText'] ?? b['text']) == z.text);
          if (b['duText'] != null) {
            if (!RegExp(r'\b([Dd]u|dir|dich|deine?[mnrs]?)\b').hasMatch(z.text)) fehler.add('$r: ${b['id']} ohne du');
          } else if (b['wer'] == r && selbst.hasMatch(b['text'] as String) && !_dritteErlaubt.contains(b['id'])) {
            fehler.add('$r: ${b['id']} spricht die eigene Rolle in der dritten Person an');
          }
        }
      }
    }
    expect(fehler.toSet(), isEmpty);
  });

  test('Lügen und Heimlichtuereien stehen im eigenen Dossier in der Du-Form (E-036)', () {
    final texte = Texte(kanon, _textsammlung);
    final dritte = RegExp(r'^(Er|Sie) |\b(seine?[mnrs]?|ihm|ihn)\b');
    final fehler = <String>[];
    for (final f in kanon.figuren) {
      final r = f['id'] as String;
      for (final p in kanon.pfade) {
        final d = texte.dossier(r, p, 20);
        for (final z in [...d.weiss, ...d.verbirgt]) {
          if (z.art != 'luege' && z.art != 'nebendelikt') continue;
          if (dritte.hasMatch(z.text)) fehler.add('$r/$p: ${z.art} in der dritten Person: ${z.text}');
          if (z.art == 'nebendelikt' && !z.text.startsWith('Du ')) fehler.add('$r/$p: Heimlichtuerei ohne Satz in Du-Form: ${z.text}');
        }
      }
    }
    expect(fehler.toSet(), isEmpty, reason: fehler.toSet().join('\n'));
  });
}

/// Beobachtungen, deren Pronomen der dritten Person eine andere Person meinen.
const _dritteErlaubt = {'b_pawel_schneider'};
