import 'package:mordakte_core/mordakte_core.dart';
import 'package:mordakte_core/runden.dart';
import 'package:test/test.dart';

import '../party/kanon_hilfe.dart';

final _texte = Texte(kanon, Textsammlung.lade((p) => leseJson('$repoWurzel/content/party/schlosskeller/$p')));
final _erm = Ermittlung(kanon);

const _salz = 'protokoll-raumsalz-karten';
const _werkzeug = 'schlosskeller:ahmet:lupe';
const _zeit = 'schlosskeller:can:uhr';

/// Frischer Raum mit gleichem Salz, Fall, Texten und Katalog: Grundlage jeder Wiederherstellung.
AbendRaum _fabrik() => SchlosskellerRaum(
  raumCode: 'PROT', kanon: kanon, texte: _texte, fallCode: FallCode.fuerPfad('ahmet', kanon.pfade), salz: _salz,
  katalog: KartenKatalog([
    KartenDef(id: _werkzeug, akte: 'schlosskeller', figur: 'ahmet', seltenheit: Seltenheit.gewoehnlich,
        art: KartenArt.werkzeug, titel: 'Lupe', text: 'Eine Lupe.', quellen: const [KartenQuelle('start')]),
    KartenDef(id: _zeit, akte: 'schlosskeller', figur: 'can', seltenheit: Seltenheit.gewoehnlich,
        art: KartenArt.zeit, wert: 3, titel: 'Uhr', text: 'Eine Uhr.', quellen: const [KartenQuelle('start')]),
  ]),
);

Map<String, Object?> _map(Object? value) => (value as Map).cast<String, Object?>();
List<Map<String, Object?>> _liste(Object? value) => [for (final v in value as List) _map(v)];

void _befehl(AbendRaum r, String id, String typ, [Map<String, Object?> daten = const {}]) =>
    r.nachricht(id, {'typ': typ, ...daten});

Matcher _fehler(String code) => isA<PartyRaumFehler>().having((e) => e.code, 'code', code);

void _start(AbendRaum r, int clients, int rollen, {List<String>? vorrat}) {
  for (var i = 0; i < clients; i++) {
    expect(r.beitreten('p$i', 'Person $i'), isTrue);
    _befehl(r, 'p$i', 'bereit', {'wert': true});
  }
  _befehl(r, 'p0', 'start', {'rollen': rollen, 'vorrat': ?vorrat});
}

/// Wie im Schlosskeller-Test: nur Ansichten und Nachrichten, nie der innere Zustand.
void _schritt(AbendRaum r, {String pfad = 'ahmet'}) {
  final s = r.zustandFuer('p0');
  switch (s['phase']) {
    case 'rollen':
      for (final t in _liste(s['spieler'])) {
        if (t['rolle'] != null && t['online'] == true) _befehl(r, t['id'] as String, 'rollenGelesen');
      }
      _befehl(r, 'p0', 'weiter');
    case 'entscheidungen':
      if (s['zug'] case final Map zug) {
        switch (zug['phase']) {
          case 'aktion':
            _befehl(r, 'p0', 'aktionFertig', {'aktion': zug['aktion']});
          case 'wurf':
            _befehl(r, s['wuerfelPate'] as String, 'wurf');
          case 'tischruf':
            _befehl(r, 'p0', 'tischruf', {'ruf': (zug['aktion'] as int).isEven ? 'nochmal' : 'umweg'});
          case 'fund':
            _befehl(r, 'p0', 'fundGelesen');
          default:
            fail('Unbekannter Zugabschnitt');
        }
      } else if (s['entscheidung'] case final Map e) {
        _befehl(r, 'p0', 'wahl', {'option': _erm.entscheidung(e['id'] as String).richtig[pfad]!});
      } else {
        _befehl(r, 'p0', 'weiter');
      }
    case 'gruppenwahl':
      for (final t in _liste(s['spieler'])) {
        final id = t['id'] as String;
        final privat = _map(r.zustandFuer(id)['privat']);
        if (privat['rolle'] != null && privat['hatGestimmt'] == false) _befehl(r, id, 'stimme', {'kooperativ': true});
      }
      _befehl(r, 'p0', 'weiter');
    case 'anklage':
      _befehl(r, 'p0', 'anklage', {'person': pfad});
      _befehl(r, 'p0', 'weiter');
    default:
      _befehl(r, 'p0', 'weiter');
  }
}

void _bis(AbendRaum r, bool Function(Map<String, Object?>) erreicht) {
  for (var i = 0; i < 400; i++) {
    if (erreicht(r.zustandFuer('p0'))) return;
    _schritt(r);
  }
  fail('Zielzustand nicht erreicht');
}

void main() {
  test('Protokoll stellt Abend in Runde 2 mit Karten und Würfelhilfe identisch wieder her', () {
    final r = ProtokollRaum(_fabrik());
    _start(r, 4, 4, vorrat: [_werkzeug, _zeit]);
    _bis(r, (s) => s['runde'] == 2 && s['phase'] == 'entscheidungen');
    _befehl(r, 'p0', 'karte', {'id': _zeit});
    for (var i = 0; i < 4; i++) {
      _schritt(r);
    }
    _bis(r, (s) => s['runde'] == 2 && s['zug'] is Map && _map(s['zug'])['phase'] == 'wurf');
    final pate = r.zustandFuer('p0')['wuerfelPate'] as String;
    final vorher = r.protokoll.length;
    expect(() => _befehl(r, pate == 'p0' ? 'p1' : 'p0', 'wurf'), throwsA(_fehler('not_dice_player')));
    expect(r.protokoll, hasLength(vorher), reason: 'Abgelehnte Nachrichten landen nicht im Protokoll');
    _befehl(r, pate, 'wuerfelHilfe', {'karte': _werkzeug, 'marke': true});

    final typen = [for (final e in r.protokoll) if (e[0] == 'nachricht') _map(e[2])['typ']];
    expect(typen, containsAll(['karte', 'wuerfelHilfe', 'wahl', 'aktionFertig']));
    final ansichten = {for (var i = 0; i < 4; i++) 'p$i': r.zustandFuer('p$i')};
    expect(_map(ansichten['p1']!['privat'])['rolle'], isNotNull, reason: 'Gast sieht die eigene Rolle');

    final wieder = ProtokollRaum.wiederherstellen(r.protokoll, _fabrik);
    expect(wieder.protokoll, r.protokoll);
    for (final id in ansichten.keys) {
      expect(wieder.zustandFuer(id), ansichten[id], reason: 'Gerät $id nach Wiederherstellung');
    }
    expect(_map(wieder.zustandFuer('p0')['zug'])['mod'], _map(r.zustandFuer('p0')['zug'])['mod']);

    // Die Fortsetzung ist ebenfalls gleich: derselbe Wurf, dieselben Karten verbraucht.
    _befehl(r, pate, 'wurf');
    _befehl(wieder, pate, 'wurf');
    for (var i = 0; i < 4; i++) {
      expect(wieder.zustandFuer('p$i'), r.zustandFuer('p$i'), reason: 'Gerät p$i nach dem Wurf');
    }
    expect(_liste(r.zustandFuer('p0')['vorrat']).singleWhere((k) => k['id'] == _werkzeug)['rest'], 0);
  });
}
