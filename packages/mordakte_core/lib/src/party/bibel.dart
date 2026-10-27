// Story-Bibel des Partymodus: eine lesbare Markdown-Übersicht, aus dem Kanon erzeugt.
// Gibt nur wieder, was im Kanon steht. Im Code stehen nur Überschriften, Labels und
// Tabellenköpfe; alle Story-Texte kommen aus den JSON-Dateien.
import 'herkunft.dart';
import 'kanon/kanon.dart';
import 'plausibilitaet.dart';

/// Die Story-Bibel als Markdown. Deterministisch: keine Zeitstempel, feste Reihenfolge.
String storyBibel(Kanon kanon, Plausibilitaet pruefer) => _Bibel(kanon, pruefer).erzeuge();

Map<String, Object?> _m(Object? v) => v == null ? const {} : (v as Map).cast<String, Object?>();

List<Object?> _l(Object? v) => v == null ? const [] : (v as List).cast<Object?>();

String _esc(String s) => s.replaceAll('|', '\\|').replaceAll('\n', ' ');

String _ja(Object? v) => v == true ? 'ja' : 'nein';

const _settingLabels = {
  'settingId': 'Setting-Kennung',
  'schauplatz': 'Schauplatz',
  'anlass': 'Anlass',
  'datum': 'Datum',
  'essen': 'Essen',
  'getraenke': 'Getränke',
  'empfang': 'Empfang',
  'atmosphaere': 'Atmosphäre',
  'brandschutz': 'Brandschutz',
  'ton': 'Ton',
  'introTeile': 'Weitere Intro-Teile',
  'vorgeschichte': 'Vorgeschichte (Teile)',
  'vorstellung': 'Vorstellungsrunde',
};

const _optikLabels = {
  'silhouette': 'Silhouette',
  'outfit': 'Kleidung',
  'baseOutfit': 'Kleidung',
  'accessories': 'Accessoires',
  'distinguishingFeature': 'Merkmal',
  'idleAnimation': 'Ruhe-Animation',
  'interactiveTool': 'Werkzeug',
};

const _lookLabels = {
  'haut': 'Haut',
  'haar': 'Haar',
  'kopf': 'Kopf',
  'kopftuchFarbe': 'Kopftuchfarbe',
  'statur': 'Statur',
  'schnitt': 'Schnitt',
  'glatze': 'Glatze',
};

const _unschuldLabels = {'actualBehavior': 'Verhalten'};

const _taeterLabels = {
  'crimeExecution': 'Tat',
  'smokingGun': 'Schlüsselbeweis',
  'zusatzindiz': 'Zusatzindiz',
};

class _Bibel {
  final Kanon kanon;
  final Plausibilitaet pruefer;
  final _b = StringBuffer();

  _Bibel(this.kanon, this.pruefer);

  late final _raeume = _m(kanon.json['raeume.json']);
  late final _orte = {for (final o in _l(_raeume['orte'])) (o as Map)['id'] as String: _m(o)};
  late final _raumNamen = {for (final r in _l(_raeume['rooms'])) (r as Map)['id'] as String: _m(r)};
  late final _einrichtung = {for (final e in _l(_raeume['einrichtung'])) (e as Map)['id'] as String: _m(e)};
  late final _gegenstaende = {for (final g in kanon.gegenstaende) g['id'] as String: g};
  String get _detektivId => _m(kanon.figurenJson['detektiv'])['id'] as String;

  String erzeuge() {
    _kopf();
    _fallKapitel();
    _settingKapitel();
    _raeumeKapitel();
    _figurenKapitel();
    _zeitKapitel();
    _gegenstaendeKapitel();
    _beobachtungenKapitel();
    _matrixKapitel();
    _entscheidungenKapitel();
    _bonusKapitel();
    return '${_b.toString().trimRight()}\n';
  }

  // Ausgabe-Helfer.

  void _z([String s = '']) => _b.writeln(s);

  void _ueberschrift(String text) {
    _z(text);
    _z();
  }

  void _punkt(String s) => _z('- $s');

  void _unterpunkt(String s) => _z('  - $s');

  void _tabelle(List<String> kopf, List<List<String>> zeilen) {
    _z('| ${kopf.join(' | ')} |');
    _z('|${List.filled(kopf.length, '---').join('|')}|');
    for (final z in zeilen) {
      _z('| ${z.map(_esc).join(' | ')} |');
    }
    _z();
  }

  void _gruppe(String label, Map<String, Object?> m, Map<String, String> labels) {
    _punkt('**$label:**');
    for (final e in m.entries) {
      final v = e.value is List ? _l(e.value).join(', ') : '${e.value}';
      _unterpunkt('${labels[e.key] ?? e.key}: $v');
    }
  }

  // Namen: Personen mit Anzeigename, Orte, Räume, Gegenstände.

  String _name(String id) => kanon.figur(id)?['name'] as String? ?? id;

  /// Person mit Anzeigename, z. B. "Lejla (leyla)".
  String _p(String id) => id == _detektivId ? 'Detektiv ($id)' : '${_name(id)} ($id)';

  /// Kennung, die eine Person sein kann; sonst unverändert (z. B. eine Lüge).
  String _kenn(Object? v) {
    if (v == null) return '–';
    if (v is String && kanon.personen.contains(v)) return _p(v);
    return '$v';
  }

  String _kennListe(Object? v) => _l(v).isEmpty ? '–' : _l(v).map(_kenn).join(', ');

  /// Personen-Feld: "alle", eine Kennung oder eine Liste.
  String _personenFeld(Object? v) {
    if (v == null) return '–';
    if (v is String) return v == 'alle' ? 'alle' : _kenn(v);
    return _l(v).map(_kenn).join(', ');
  }

  String _ort(String id) {
    final o = _orte[id];
    return o == null ? id : '${o['name']} ($id)';
  }

  String _raum(String id) {
    final r = _raumNamen[id];
    return r == null ? id : '${r['anzeigename']} ($id)';
  }

  String _einrichtungName(String id) {
    final e = _einrichtung[id];
    return e == null ? id : '${e['name']} ($id)';
  }

  String _gegenstand(String id) {
    final g = _gegenstaende[id];
    return g == null ? id : '${g['name']} ($id)';
  }

  /// Lage oder Versteck: Träger, Ort, Einrichtung, Stelle, versteckt.
  String _lage(Map<String, Object?> l) {
    final teile = <String>[
      if (l['traeger'] != null) 'bei ${_p(l['traeger'] as String)}',
      if (l['ort'] != null) _ort(l['ort'] as String),
      if (l['einrichtung'] != null) _einrichtungName(l['einrichtung'] as String),
      if (l['stelle'] != null) '${l['stelle']}',
      if (l['versteckt'] == true) 'versteckt',
    ];
    return teile.isEmpty ? '–' : teile.join('; ');
  }

  /// Schlüssel-Wert-Paare einer Spur; Personen-Schlüssel werden mit Anzeigename geschrieben.
  String _kvMap(Object? v, {bool schluesselAlsPerson = false}) {
    final m = _m(v);
    if (m.isEmpty) return '–';
    return m.entries.map((e) {
      final k = schluesselAlsPerson ? _kenn(e.key) : e.key;
      final w = e.value is bool ? _ja(e.value) : _kenn(e.value);
      return '$k: $w';
    }).join('; ');
  }

  // Kapitel.

  void _kopf() {
    final f = kanon.fall;
    _z('# Story-Bibel · ${f['titel']}');
    _z();
    _z('Erzeugt aus dem Kanon (Version ${f['kanonVersion']}). Nicht von Hand ändern: dart run bin/party_bibel.dart');
    _z();
  }

  void _fallKapitel() {
    _ueberschrift('## 1. Fall');
    final f = kanon.fall;
    final personen = _m(f['personen']);
    _punkt('**Titel:** ${f['titel']}');
    _punkt('**Untertitel:** ${f['untertitel']}');
    _punkt('**Pfade:** ${_l(f['pfade']).map((x) => _p(x as String)).join(', ')}');
    _punkt('**Kernverdächtige:** ${_l(f['kernverdaechtige']).map((x) => _p(x as String)).join(', ')}');
    _punkt('**Personen:** ${personen['min']} bis ${personen['max']} (${personen['hinweis']})');
    _punkt('**Finale:** ${f['finaleUhrzeit']}');
    _punkt('**Morgen:** ${f['morgenUhrzeit']}');
    _punkt('**Rundendauer:** ${f['rundendauerMinuten']} Minuten');
    _punkt('**Schwellen-Regel:** ${_m(f['schwellen'])['regel']}');
    _z();
    _z('**Runden**');
    _z();
    _tabelle(
      ['Nr', 'Uhrzeit', 'Name', 'Kern'],
      [
        for (final r in _l(f['runden']))
          [for (final k in ['nr', 'uhrzeit', 'name', 'kern']) '${_m(r)[k]}'],
      ],
    );
    _z('**Endenmatrix**');
    _z();
    _tabelle(
      ['Kennung', 'Ende', 'Anklage', 'Punkte'],
      [
        for (final e in _l(_m(f['enden'])['matrix']))
          [
            '${_m(e)['id']}',
            '${_m(e)['name']}',
            '${_m(e)['anklage']}',
            '${_m(e)['punkteVon']}–${_m(e)['punkteBis']}',
          ],
      ],
    );
    _z('**Regeln**');
    _z();
    for (final e in _m(f['regeln']).entries) {
      _punkt('**${e.key}:** ${e.value}');
    }
    _z();
  }

  void _settingKapitel() {
    _ueberschrift('## 2. Setting');
    final s = _m(kanon.json['setting.json']);
    for (final e in s.entries) {
      if (e.key == 'lacher') continue;
      final label = _settingLabels[e.key] ?? e.key;
      final v = e.value;
      if (v is List) {
        _punkt('**$label:**');
        for (final x in v) {
          _unterpunkt('$x');
        }
      } else {
        _punkt('**$label:** ${v is bool ? _ja(v) : v}');
      }
    }
    _z();
    _z('**Lacher**');
    _z();
    _tabelle(
      ['Zeit', 'Wer', 'Ort', 'Was', 'Trägt'],
      [
        for (final x in _l(s['lacher']))
          [
            '${_m(x)['zeit']}',
            _kenn(_m(x)['wer']),
            _ort('${_m(x)['ort']}'),
            '${_m(x)['was']}',
            '${_m(x)['traegt']}',
          ],
      ],
    );
  }

  void _raeumeKapitel() {
    _ueberschrift('## 3. Räume');
    _tabelle(
      ['Kennung', 'Anzeigename', 'Rechteck x,y,b,l', 'Beschreibung'],
      [
        for (final r in _l(_raeume['rooms']))
          () {
            final m = _m(r);
            final re = _m(m['rechteck']);
            return [
              '${m['id']}',
              '${m['anzeigename']}',
              '${re['x']},${re['y']},${re['b']},${re['l']}',
              '${m['beschreibung'] ?? '–'}',
            ];
          }(),
      ],
    );
    _z('**Türen**');
    _z();
    _tabelle(
      ['Kennung', 'Name', 'Von', 'Nach', 'Schließt', 'Zustand'],
      [
        for (final t in _l(_raeume['tueren']))
          () {
            final m = _m(t);
            final schliesst = m['schluessel'] == null
                ? '${m['schliesst']}'
                : '${m['schliesst']} (Schlüssel: ${_gegenstand('${m['schluessel']}')})';
            return [
              '${m['id']}',
              '${m['name'] ?? '–'}',
              '${m['von']}',
              '${m['nach']}',
              schliesst,
              '${m['zustand']}',
            ];
          }(),
      ],
    );
    _z('**Lichtquellen**');
    _z();
    _tabelle(
      ['Kennung', 'Name', 'Art', 'Räume', 'Brennt (von–bis)'],
      [
        for (final q in _l(_raeume['lichtquellen']))
          () {
            final m = _m(q);
            return [
              '${m['id']}',
              '${m['name'] ?? '–'}',
              '${m['art']}',
              m['raeume'] == null ? '–' : _l(m['raeume']).join(', '),
              m['an'] == null
                  ? '–'
                  : _l(m['an']).map((z) => '${_l(z)[0]}–${_l(z)[1]}').join('; '),
            ];
          }(),
      ],
    );
    _z('**Luftzug**');
    _z();
    for (final x in _l(_raeume['luftzug'])) {
      final luft = _m(x);
      _punkt('**Ab:** ${luft['ab']}');
      _punkt('**Weg:** ${_l(luft['weg']).join(' → ')}');
      _punkt('**Grund:** ${luft['grund']}');
    }
    _z();
    _z('**Orte**');
    _z();
    _tabelle(
      ['Kennung', 'Raum', 'x', 'y', 'Name'],
      [
        for (final o in _l(_raeume['orte']))
          [
            '${_m(o)['id']}',
            '${_m(o)['raum']}',
            '${_m(o)['x']}',
            '${_m(o)['y']}',
            '${_m(o)['name']}',
          ],
      ],
    );
  }

  void _figurenKapitel() {
    _ueberschrift('## 4. Figuren');
    final d = _m(kanon.figurenJson['detektiv']);
    _z('### Detektiv (${d['title']})');
    _z();
    _figurFelder(d);
    final o = _m(kanon.figurenJson['opfer']);
    _z('### Opfer. ${o['name']} (${o['roleTitle']})');
    _z();
    _figurFelder(o);
    final figuren = [...kanon.figuren]
      ..sort((a, b) => (a['besetzungsplatz'] as int).compareTo(b['besetzungsplatz'] as int));
    for (final f in figuren) {
      _z('### ${f['besetzungsplatz']}. ${f['name']} (${f['roleTitle']})');
      _z();
      _figurFelder(f);
    }
    _z('### Herkunftsmatrix (TON §7, §10 Nr. 5)');
    _z();
    _z('Nur diese Matrix und die Prüfwerkzeuge lesen das Feld `herkunft`; im Spiel erscheint es nie. `herkunft_test` prüft, dass keine Herkunft eine Art von Verfehlung allein trägt.');
    _z();
    _tabelle(
      ['Figur', 'Herkunft', 'Kernrolle', 'Nebendelikt', 'Lügen', 'Verschweigt etwas', 'Kopftuch'],
      [
        for (final z in herkunftsMatrix(kanon))
          [_name(z.figur), z.herkunft, _ja(z.kernrolle), _ja(z.nebendelikt), '${z.luegen}', _ja(z.verschweigt), _ja(z.kopftuch)],
      ],
    );
  }

  /// Alle vorhandenen Felder einer Figur; fehlende Felder entfallen.
  void _figurFelder(Map<String, Object?> f) {
    void feld(String label, Object? wert) {
      if (wert != null) _punkt('**$label:** $wert');
    }

    feld('Alter', f['age']);
    feld('Geschlecht', f['geschlecht']);
    feld('Herkunft', f['herkunft']);
    feld('Aussprache', f['aussprache']);
    feld('Alltag', f['alltag']);
    feld('Stufe', f['tier']);
    if (f['colorCode'] != null) feld('Farbcode', '${f['colorCode']} (${f['farbname']})');
    if (f['startRoom'] != null) feld('Startraum', _raum('${f['startRoom']}'));
    if (f['ermittlungsOrt'] != null) feld('Ermittlungsort', _ort('${f['ermittlungsOrt']}'));
    if (f['visualSpecs'] != null) _gruppe('Optik', _m(f['visualSpecs']), _optikLabels);
    if (f['look'] != null) _gruppe('Look', _m(f['look']), _lookLabels);
    feld('Motiv', f['motiveAndConflict']);
    feld('Alibi', f['blackoutAlibi']);
    feld('Geheimnis', f['roleSecret']);
    feld('Persönliches Ziel', f['persoenlichesZiel']);
    if (f['nebendelikt'] != null) {
      final n = _m(f['nebendelikt']);
      feld('Nebendelikt', '${n['text']} (${n['id']})');
    }
    if (f['loyalitaet'] != null) {
      final l = _m(f['loyalitaet']);
      feld('Loyalität', '${_kenn(l['zu'])}: ${l['grund']}');
    }
    if (f['luegen'] != null) {
      _punkt('**Lügen:**');
      for (final x in _l(f['luegen'])) {
        final l = _m(x);
        _unterpunkt('`${l['id']}`: ${l['behauptung']} → ${l['wahrheit']}');
      }
    }
    if (f['innocentProfile'] != null) {
      _gruppe('Unschuldsfassung', _m(f['innocentProfile']), _unschuldLabels);
    }
    if (f['killerProfile'] != null) {
      _gruppe('Täterfassung', _m(f['killerProfile']), _taeterLabels);
    }
    feld('Beweisfarbe', f['beweisFarbe']);
    feld('Status', f['status']);
    feld('Erinnerung', f['erinnerung']);
    feld('Warme Seite', f['warmeSeite']);
    feld('Gedächtnislücke ab', f['gedaechtnisLueckeAb']);
    if (f['schluesselbund'] != null) feld('Schlüsselbund', _gegenstand('${f['schluesselbund']}'));
    feld('Tatnacht', f['tatnacht']);
    feld('Auftrag', f['auftrag']);
    if (f['nieVerdaechtig'] != null) feld('Nie verdächtig', _ja(f['nieVerdaechtig']));
    _z();
  }

  void _zeitKapitel() {
    _ueberschrift('## 5. Zeitleiste');
    _tabelle(
      ['Zeit', 'Ort', 'Wer', 'Was'],
      [
        for (final e in kanon.zeitleiste)
          [
            '${e['zeit']}',
            _ort('${e['ort']}'),
            _personenFeld(e['wer']),
            e['pfade'] == null || e['pfade'] == 'alle'
                ? '${e['text']}'
                : '${e['text']} (Pfade: ${_personenFeld(e['pfade'])})',
          ],
      ],
    );
  }

  void _gegenstaendeKapitel() {
    _ueberschrift('## 6. Gegenstände und Spuren');
    for (final g in kanon.gegenstaende) {
      _z('### ${g['name']} (`${g['id']}`)');
      _z();
      _punkt('**Lage:** ${_lage(_m(g['lage']))}');
      _punkt('**Sichtbar:** ${_ja(g['sichtbar'])}');
      if (g['beschreibung'] != null) _punkt('**Beschreibung:** ${g['beschreibung']}');
      _z();
      final spuren = _l(g['spuren']);
      if (spuren.isNotEmpty) {
        _tabelle(
          ['Stelle', 'entsteht wenn', 'zeigt', 'harmlos', 'Rolle'],
          [
            for (final s in spuren)
              [
                '${_m(s)['stelle']}',
                _kvMap(_m(s)['entstehtWenn']),
                '${_m(s)['zeigt']}',
                '${_m(s)['harmlos']}',
                _kvMap(_m(s)['rolle'], schluesselAlsPerson: true),
              ],
          ],
        );
      }
      final versteck = _m(g['versteckJePfad']);
      if (versteck.isNotEmpty) {
        _punkt('**Versteck je Pfad:**');
        for (final e in versteck.entries) {
          _unterpunkt('${_p(e.key)}: ${_lage(_m(e.value))}');
        }
        _z();
      }
    }
    _z('**Nebendelikte**');
    _z();
    _tabelle(
      ['Kennung', 'Person', 'Text'],
      [
        for (final n in _l(_m(kanon.json['gegenstaende.json'])['nebendelikte']))
          ['${_m(n)['id']}', _kenn(_m(n)['person']), '${_m(n)['text']}'],
      ],
    );
  }

  void _beobachtungenKapitel() {
    _ueberschrift('## 7. Beobachtungen');
    _tabelle(
      ['Kennung', 'Wer', 'Pfade', 'Kanal', 'Text', 'widerlegt', 'belastet', 'entlastet'],
      [
        for (final b in kanon.beobachtungen)
          [
            '${b['id']}',
            _kenn(b['wer']),
            _personenFeld(b['pfade']),
            '${b['kanal']}',
            '${b['text']}',
            _kennListe(b['widerlegt']),
            _kennListe(b['belastet']),
            _kennListe(b['entlastet']),
          ],
      ],
    );
  }

  void _matrixKapitel() {
    _ueberschrift('## 8. Tatmatrix je Pfad');
    for (final p in kanon.pfade) {
      _z('### Pfad ${_name(p)}');
      _z();
      _b.write(pruefer.matrixMarkdown(p));
      _z();
    }
  }

  void _entscheidungenKapitel() {
    _ueberschrift('## 9. Entscheidungen des Detektivs');
    final j = kanon.entscheidungenJson;
    for (final r in _l(j['regeln'])) {
      final m = _m(r);
      _punkt('**${m['id']}:** ${m['text']}');
    }
    _z();
    _tabelle(
      ['Fakt', 'Art', 'Personen', 'Quelle'],
      [
        for (final f in _l(j['fakten']))
          [
            '${_m(f)['id']}',
            '${_m(f)['typ']}',
            _kennListe(_m(f)['personen']),
            _m(_m(f)['quelle']).entries.map((e) => '${e.key}: ${e.value}').join(),
          ],
      ],
    );
    for (final e in _l(j['entscheidungen'])) {
      final m = _m(e);
      _z('### Runde ${m['runde']}.${m['nr']}: ${m['frage']} (`${m['id']}`)');
      _z();
      final richtig = _m(m['richtig']);
      _tabelle(
        ['Option', 'Text', 'Fakten', 'richtig in'],
        [
          for (final o in _l(m['optionen']))
            [
              '${_m(o)['id']}',
              '${_m(o)['text']}',
              _l(_m(o)['fakten']).join(', '),
              [for (final p in kanon.pfade) if (richtig[p] == _m(o)['id']) _name(p)].join(', '),
            ],
        ],
      );
      for (final b in _m(m['begruendung']).entries) {
        final k = _m(b.value);
        _punkt('**Begründung ${b.key == 'alle' ? 'alle Pfade' : _name(b.key)}:** ${k['text']} (${_l(k['kette']).join(', ')})');
      }
      _z();
    }
  }

  void _bonusKapitel() {
    _ueberschrift('## 10. Bonus-Hinweise');
    _tabelle(
      ['Kennung', 'Pfad', 'Runde', 'Qualität', 'Text', 'Wirkung', 'widerlegt durch'],
      [
        for (final h in _l(kanon.bonusJson['hinweise']))
          [
            '${_m(h)['id']}',
            _name(_m(h)['pfad'] as String),
            '${_m(h)['runde']}',
            '${_m(h)['qualitaet']}',
            '${_m(h)['text']}',
            _m(_m(h)['wirkung']).values.map((v) => _kenn(v)).join(' '),
            _l(_m(h)['widerlegtDurch']).join(', '),
          ],
      ],
    );
  }
}
