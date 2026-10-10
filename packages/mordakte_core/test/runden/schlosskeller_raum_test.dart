import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:mordakte_core/mordakte_core.dart';
import 'package:mordakte_core/runden.dart';
import 'package:test/test.dart';

import '../party/kanon_hilfe.dart';

final _texte = Texte(kanon, Textsammlung.lade((p) => leseJson('$repoWurzel/content/party/schlosskeller/$p')));
final _erm = Ermittlung(kanon);

SchlosskellerRaum _raum({String pfad = 'ahmet'}) => SchlosskellerRaum(
  raumCode: 'ABCD', kanon: kanon, texte: _texte,
  fallCode: FallCode.fuerPfad(pfad, kanon.pfade), salz: 'pruefung-raumsalz-unabhaengig-vom-pfad',
);

Map<String, Object?> _map(Object? value) => (value as Map).cast<String, Object?>();
List<Map<String, Object?>> _liste(Object? value) => [for (final v in value as List) _map(v)];
Map<String, Object?> _oeffentlich(Map<String, Object?> s) => Map.of(s)..remove('privat');

void _befehl(SchlosskellerRaum r, String id, String typ, [Map<String, Object?> daten = const {}]) =>
    r.nachricht(id, {'typ': typ, ...daten});

Matcher _fehler(String code) => isA<PartyRaumFehler>().having((e) => e.code, 'code', code);

void _start(SchlosskellerRaum r, int clients, int rollen) {
  for (var i = 0; i < clients; i++) {
    expect(r.beitreten('p$i', 'Person $i'), isTrue);
    _befehl(r, 'p$i', 'bereit', {'wert': true});
  }
  _befehl(r, 'p0', 'start', {'rollen': rollen});
}

/// Treiber benutzt nur Ansichten und Nachrichten, niemals den internen Zustand.
void _schritt(SchlosskellerRaum r, {String pfad = 'ahmet', bool bestesSpiel = true}) {
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
        final option = bestesSpiel ? _erm.entscheidung(e['id'] as String).richtig[pfad]! : _liste(e['optionen']).first['id'];
        _befehl(r, 'p0', 'wahl', {'option': option});
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

void _bis(SchlosskellerRaum r, bool Function(Map<String, Object?>) erreicht) {
  for (var i = 0; i < 400; i++) {
    if (erreicht(r.zustandFuer('p0'))) return;
    _schritt(r);
  }
  fail('Zielzustand nicht erreicht');
}

Iterable<String> _schluessel(Object? wert) sync* {
  if (wert is Map) {
    for (final e in wert.entries) {
      yield e.key.toString();
      yield* _schluessel(e.value);
    }
  } else if (wert is List) {
    for (final e in wert) { yield* _schluessel(e); }
  }
}

void main() {
  test('Identität, Kapazität, Startrechte und unbekannte Felder werden geprüft', () {
    final r = _raum();
    expect(() => r.zustandFuer('fremd'), throwsA(_fehler('not_in_room')));
    expect(r.beitreten('p0', 'Leitung'), isTrue);
    expect(r.beitreten('p1', 'Gast'), isTrue);
    final vorher = r.zustandFuer('p0');
    expect(() => _befehl(r, 'p1', 'start', {'rollen': 4}), throwsA(_fehler('not_host')));
    expect(() => _befehl(r, 'p0', 'start', {'rollen': 4}), throwsA(_fehler('not_ready')));
    expect(() => _befehl(r, 'p1', 'bereit', {'wert': true, 'spieler': 'p0'}), throwsA(_fehler('invalid')));
    expect(r.zustandFuer('p0'), vorher);
    for (var i = 2; i <= 20; i++) { expect(r.beitreten('p$i', 'Person $i'), isTrue); }
    expect(r.beitreten('zu-viel', 'Niemand'), isFalse);
    expect(r.spielerIds, hasLength(21));
  });

  test('4–20 Rollen: jedes Gerät erhält ausschließlich sein eigenes Dossier', () {
    for (final pfad in kanon.pfade) {
      for (var rollen = 4; rollen <= 20; rollen++) {
        final r = _raum(pfad: pfad);
        _start(r, rollen + 1, rollen);
        final publicHost = _oeffentlich(r.zustandFuer('p0'));
        expect(_map(r.zustandFuer('p0')['privat']).containsKey('dossier'), isFalse);
        final gesehen = <String>{};
        for (var i = 1; i <= rollen; i++) {
          final s = r.zustandFuer('p$i');
          expect(_oeffentlich(s), publicHost);
          final privat = _map(s['privat']);
          final rolle = privat['rolle'] as String;
          expect(gesehen.add(rolle), isTrue);
          final dossier = _map(privat['dossier']);
          final soll = _texte.dossier(rolle, pfad, rollen);
          expect(dossier['wer'], soll.wer);
          expect(dossier['verbirgt'], [for (final z in soll.verbirgt) z.text]);
          expect(dossier['tarnung'], soll.tarnung);
          expect(_schluessel(s).where((k) => k == 'dossier'), hasLength(1));
          expect(_schluessel(s).toSet().intersection({'pfad', 'fallCode', 'salz', 'seed', 'richtig', 'qualitaeten', 'taeter'}), isEmpty);
          if (rolle != pfad) expect(jsonEncode(s), isNot(contains(_texte.sammlung.taeter[pfad]!.tarnung)));
        }
        expect(gesehen, _texte.besetzung.besetzt(rollen).toSet());
        expect(r.beitreten('nach-start', 'Neuer Gast'), isFalse);
      }
    }
  });

  test('Öffentliche Auswahlreihenfolge und Würfe verraten keinen Fall-Code/Pfad', () {
    List<Object?>? soll;
    for (final pfad in kanon.pfade) {
      final r = _raum(pfad: pfad);
      _start(r, 4, 4);
      final verlauf = <Object?>[];
      for (var i = 0; i < 300 && !r.beendet; i++) {
        final s = r.zustandFuer('p0');
        if (s['entscheidung'] case final Map e) verlauf.add({'id': e['id'], 'optionen': e['optionen']});
        if (s['phase'] == 'anklage') {
          verlauf.add(s['wuerfe']);
          break;
        }
        _schritt(r, pfad: pfad, bestesSpiel: false);
      }
      expect(verlauf, hasLength(10)); // neun Entscheidungen und Würfelprotokoll
      if (soll == null) { soll = verlauf; } else { expect(verlauf, soll); }
    }
  });

  test('Reconnect hält Rollenkarte und Salz fest; Gnadenfrist ersetzt keine Stimme', () {
    final r = _raum();
    _start(r, 5, 4);
    final privat = r.zustandFuer('p1')['privat'];
    final zusage = r.wuerfelZusage;
    r.verbunden('p1', false);
    expect(() => r.zustandFuer('p1'), throwsA(_fehler('not_in_room')));
    expect(r.zustandFuer('p0')['kannWeiter'], isFalse);
    r.verbunden('p1', true);
    expect(r.zustandFuer('p1')['privat'], privat);
    expect(r.wuerfelZusage, zusage);
    _bis(r, (s) => s['phase'] == 'gruppenwahl');
    r.verbunden('p1', false);
    for (var i = 2; i <= 4; i++) { _befehl(r, 'p$i', 'stimme', {'kooperativ': true}); }
    expect(r.zustandFuer('p0')['kannWeiter'], isFalse);
    r.verlassen('p1'); // erst nach Ablauf der äußeren Gnadenfrist
    expect(r.zustandFuer('p0')['kannWeiter'], isTrue);
    expect(r.beitreten('p1', 'Zurück'), isTrue);
    expect(_map(r.zustandFuer('p1')['privat'])['rolle'], _map(privat)['rolle']);
    expect(_map(r.zustandFuer('p1')['privat'])['hatGestimmt'], isTrue);
  });

  test('Gast kann weder fremde Stimmen noch Würfelaugen vorgeben', () {
    final r = _raum();
    _start(r, 5, 4);
    _bis(r, (s) => s['phase'] == 'gruppenwahl');
    final vorher = r.zustandFuer('p0');
    expect(() => _befehl(r, 'p1', 'stimme', {'rolle': 'p2', 'kooperativ': true}), throwsA(_fehler('invalid')));
    expect(() => _befehl(r, 'p1', 'weiter'), throwsA(_fehler('not_host')));
    expect(r.zustandFuer('p0'), vorher);
    _befehl(r, 'p1', 'stimme', {'kooperativ': false});
    expect(() => _befehl(r, 'p1', 'stimme', {'kooperativ': true}), throwsA(_fehler('already_voted')));
    for (var i = 2; i <= 4; i++) {
      final s = r.zustandFuer('p$i');
      expect(_map(s['privat'])['hatGestimmt'], isFalse);
      expect(_schluessel(s), isNot(contains('kooperativ')));
      expect(_schluessel(s), isNot(contains('qualitaet')));
    }
  });

  test('Würfelhilfe wird vor dem Wurf in der gemeinsamen Chance sichtbar', () {
    final r = _raum();
    _start(r, 4, 4);
    _bis(r, (s) => s['runde'] == 2 && s['zug'] is Map && _map(s['zug'])['phase'] == 'wurf');
    var s = r.zustandFuer('p0');
    final pate = s['wuerfelPate'] as String;
    final anderer = pate == 'p0' ? 'p1' : 'p0';
    expect(() => _befehl(r, anderer, 'wurf'), throwsA(_fehler('not_dice_player')));
    expect(() => _befehl(r, pate, 'wurf', {'a': 6, 'b': 6}), throwsA(_fehler('invalid')));
    _befehl(r, pate, 'wuerfelHilfe', {'werkzeug': true, 'marke': true});
    s = r.zustandFuer('p0');
    final mod = _map(s['zug'])['mod'];
    expect(mod, inInclusiveRange(1, 2));
    for (var i = 1; i < 4; i++) { expect(_map(r.zustandFuer('p$i')['zug'])['chancen'], _map(s['zug'])['chancen']); }
    _befehl(r, pate, 'wurf');
    expect(_map(_map(r.zustandFuer('p0')['zug'])['wurf'])['mod'], mod);
  });

  test('Veraltete Revision und Animationsrückrufe verändern keinen Zug', () {
    final r = _raum();
    _start(r, 1, 4);
    _bis(r, (s) => s['zug'] is Map);
    var s = r.zustandFuer('p0');
    expect(() => _befehl(r, 'p0', 'aktionFertig', {'aktion': 1, 'revision': (s['version'] as int) - 1}), throwsA(_fehler('stale')));
    expect(r.zustandFuer('p0'), s);
    _befehl(r, 'p0', 'aktionFertig', {'aktion': _map(s['zug'])['aktion']});
    s = r.zustandFuer('p0');
    expect(() => _befehl(r, 'p0', 'aktionFertig', {'aktion': _map(s['zug'])['aktion']}), throwsA(_fehler('stale')));
    expect(r.zustandFuer('p0'), s);
  });

  test('Host-Wechsel überträgt Leitung, niemals die private Rolle des alten Hosts', () {
    final r = _raum();
    _start(r, 5, 4);
    final rolle = _map(r.zustandFuer('p1')['privat'])['rolle'];
    r.verlassen('p0');
    final s = r.zustandFuer('p1');
    expect(s['host'], 'p1');
    expect(_map(s['privat'])['rolle'], rolle);
    expect(_map(s['privat'])['detektiv'], isFalse);
    expect(r.beitreten('p0', 'Leitung zurück'), isTrue);
    expect(_map(r.zustandFuer('p0')['privat']).containsKey('dossier'), isFalse);
    expect(r.zustandFuer('p0')['host'], 'p1');
  });

  test('Solo/Bots und 4/12/20/21 Geräte: vier Pfade vollständig, eigene Karten, prüfbare Würfe', () {
    for (final pfad in kanon.pfade) {
      for (final clients in [1, 4, 12, 20, 21]) {
        final rollen = (clients - 1).clamp(4, 20);
        final r = _raum(pfad: pfad);
        _start(r, clients, rollen);
        for (var i = 0; i < 400 && !r.beendet; i++) {
          final s = r.zustandFuer('p0');
          if (!['finale', 'aufloesung', 'ende'].contains(s['phase'])) {
            expect(_schluessel(s).toSet().intersection({'pfad', 'fallCode', 'salz', 'seed', 'richtig', 'qualitaeten'}), isEmpty);
          }
          _schritt(r, pfad: pfad);
        }
        expect(r.beendet, isTrue, reason: '$pfad / $clients Geräte');
        final s = r.zustandFuer('p0');
        final aufloesung = _map(s['aufloesung']);
        expect(aufloesung['pfad'], pfad);
        expect(aufloesung['punkte'], 9);
        expect(aufloesung['ende'], 'ende_meister');
        final salz = aufloesung['salz'] as String;
        expect(sha256.convert(utf8.encode(salz)).toString(), s['wuerfelZusage']);
        final quelle = SalzWuerfel(salz);
        for (final w in _liste(s['wuerfe'])) {
          expect(Wurf.werfen(quelle, w['id'] as String, w['anlauf'] as int, w['mod'] as int, garantie: w['garantie'] as bool).toJson(), w);
        }
      }
    }
  });
}
