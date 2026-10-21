// M4: Gemeinsame Rundenuhr und Diashow-Zähler im Online-Raum. Die Uhr ist reiner
// Zustand ohne Takt; ihre Abendzeit kommt nur vom Transport (Feld `zeit`), das
// Protokoll spielt sich deshalb gleich wieder ein. Rechte und Fehlercodes sind
// fest (`not_host`, `invalid`, `invalid_phase`), die Ansicht trägt nur `uhr` und `dia`.
import 'dart:convert';

import 'package:mordakte_core/mordakte_core.dart';
import 'package:mordakte_core/runden.dart';
import 'package:test/test.dart';

import '../party/kanon_hilfe.dart';
import 'befragung_treiber.dart';

final _texte = Texte(kanon, Textsammlung.lade((p) => leseJson('$repoWurzel/content/party/schlosskeller/$p')));
final _erm = Ermittlung(kanon);
const _min = RundenUhr.minute;

SchlosskellerRaum _raum({int minuten = 20, int dias = 6, Abendfassung fassung = Abendfassung.kurz}) => SchlosskellerRaum(
      raumCode: 'ABCD', kanon: kanon, texte: _texte, rundenMinuten: minuten, diaAnzahl: dias, fassung: fassung,
      fallCode: FallCode.fuerPfad('ahmet', kanon.pfade), salz: 'pruefung-raumsalz-unabhaengig-vom-pfad',
    );

Map<String, Object?> _map(Object? v) => (v as Map).cast<String, Object?>();
List<Map<String, Object?>> _liste(Object? v) => [for (final x in v as List) _map(x)];
Matcher _fehler(String code) => isA<PartyRaumFehler>().having((e) => e.code, 'code', code);

/// Wie ein Transport: jede Nachricht mit der Abendzeit [zeit].
void _befehl(AbendRaum r, String id, String typ, [Map<String, Object?> d = const {}, int zeit = 1000]) =>
    r.nachricht(id, mitAbendzeit({'typ': typ, ...d}, zeit));

/// Vier Geräte: p0 Gastgeber und Detektiv, p1 Erzähler (wenn [erzaehler]), der Rest spielt Rollen.
void _start(AbendRaum r, {bool erzaehler = false}) {
  for (var i = 0; i < 4; i++) {
    expect(r.beitreten('p$i', 'Person $i'), isTrue);
  }
  if (erzaehler) _befehl(r, 'p0', 'sitz', {'spieler': 'p1', 'sitz': 'erzaehler'});
  for (var i = 0; i < 4; i++) {
    _befehl(r, 'p$i', 'bereit', {'wert': true});
  }
  _befehl(r, 'p0', 'start', {'rollen': 4});
}

/// Ein Schritt des Abends wie am Tisch: Detektiv p0, Leiter [leiter].
void _schritt(AbendRaum r, String leiter) {
  final s = r.zustandFuer('p0');
  switch (s['phase']) {
    case 'rollen':
      for (final t in _liste(s['spieler'])) {
        if (t['rolle'] != null) _befehl(r, t['id'] as String, 'rollenGelesen');
      }
      _befehl(r, leiter, 'weiter');
    case 'gespraeche':
      befragungenErledigen(s, (typ, d) => _befehl(r, 'p0', typ, d));
      _befehl(r, leiter, 'weiter');
    case 'entscheidungen':
      if (s['zug'] case final Map zug) {
        switch (zug['phase']) {
          case 'aktion':
            _befehl(r, 'p0', 'aktionFertig', {'aktion': zug['aktion']});
          case 'wurf':
            _befehl(r, s['wuerfelPate'] as String, 'wurf');
          case 'tischruf':
            _befehl(r, 'p0', 'tischruf', {'ruf': 'nochmal'});
          case 'fund':
            _befehl(r, 'p0', 'fundGelesen');
        }
      } else if (s['entscheidung'] case final Map e) {
        _befehl(r, 'p0', 'wahl', {'option': _erm.entscheidung(e['id'] as String).richtig['ahmet']!});
      } else {
        _befehl(r, leiter, 'weiter');
      }
    case 'gruppenwahl':
      for (final t in _liste(s['spieler'])) {
        final id = t['id'] as String;
        final privat = _map(r.zustandFuer(id)['privat']);
        if (privat['rolle'] != null && privat['hatGestimmt'] == false) _befehl(r, id, 'stimme', {'kooperativ': true});
      }
      _befehl(r, leiter, 'weiter');
    case 'anklage' when s['kannWeiter'] != true:
      _befehl(r, 'p0', 'anklage', {'person': 'ahmet'});
    default:
      _befehl(r, leiter, 'weiter');
  }
}

void _bis(AbendRaum r, String phase, {int runde = 1, String leiter = 'p0'}) {
  for (var i = 0; i < 400; i++) {
    final s = r.zustandFuer('p0');
    if (s['phase'] == phase && s['runde'] == runde) return;
    _schritt(r, leiter);
  }
  fail('$phase in Runde $runde nicht erreicht');
}

RundenUhr _uhr(AbendRaum r, [String id = 'p0']) => RundenUhr.ausJson(r.zustandFuer(id)['uhr'])!;

void main() {
  group('RundenUhr (rein)', () {
    test('Vor dem Start steht die volle Dauer; Start, Ablauf und Restzeit folgen der Abendzeit', () {
      final u = RundenUhr.minuten(10);
      expect([u.gestartet, u.laeuft, u.rest(123456), u.abgelaufen(123456)], [false, false, 10 * _min, false]);
      final l = u.aktion(UhrAktion.start, zeit: 5000);
      expect([l.gestartet, l.laeuft, l.rest(5000), l.rest(5000 + 3 * _min)], [true, true, 10 * _min, 7 * _min]);
      expect(l.rest(5000 + 11 * _min), 0, reason: 'nie unter null');
      expect(l.abgelaufen(5000 + 10 * _min), isTrue);
      expect(l.rest(4000), 10 * _min, reason: 'nie über die Dauer, auch wenn die Uhr zurückspringt');
      expect(u.aktion(UhrAktion.start, zeit: 0, minuten: 25).dauer, 25 * _min);
    });

    test('Pause hält die Restzeit fest, Weiter läuft genau von dort', () {
      final l = RundenUhr.minuten(10).aktion(UhrAktion.start, zeit: 0);
      final p = l.aktion(UhrAktion.pause, zeit: 4 * _min);
      expect([p.laeuft, p.pausiert, p.restBeiPause, p.rest(9 * _min)], [false, true, 6 * _min, 6 * _min]);
      final w = p.aktion(UhrAktion.weiter, zeit: 20 * _min);
      expect([w.laeuft, w.rest(20 * _min), w.rest(21 * _min)], [true, 6 * _min, 5 * _min]);
    });

    test('Plus gibt Zeit dazu: vor dem Start, laufend, angehalten und nach dem Ablauf ab jetzt', () {
      final u = RundenUhr.minuten(10);
      expect(u.aktion(UhrAktion.plus, zeit: 0, minuten: 5).rest(0), 15 * _min);
      final l = u.aktion(UhrAktion.start, zeit: 0);
      expect(l.aktion(UhrAktion.plus, zeit: 2 * _min, minuten: 5).rest(2 * _min), 13 * _min);
      final p = l.aktion(UhrAktion.pause, zeit: 2 * _min).aktion(UhrAktion.plus, zeit: 3 * _min, minuten: 5);
      expect([p.pausiert, p.rest(9 * _min)], [true, 13 * _min]);
      final um = l.aktion(UhrAktion.plus, zeit: 30 * _min, minuten: 5);
      expect([um.rest(30 * _min), um.rest(31 * _min), um.laeuft], [5 * _min, 4 * _min, true], reason: 'Abgelaufen: fünf Minuten ab jetzt');
    });

    test('Falscher Zustand ist ein StateError, falsche Minuten ein ArgumentError', () {
      final u = RundenUhr.minuten(10);
      expect(() => u.aktion(UhrAktion.pause, zeit: 0), throwsStateError);
      expect(() => u.aktion(UhrAktion.weiter, zeit: 0), throwsStateError);
      final l = u.aktion(UhrAktion.start, zeit: 0);
      expect(() => l.aktion(UhrAktion.weiter, zeit: 0), throwsStateError);
      expect(() => l.aktion(UhrAktion.plus, zeit: 0), throwsArgumentError);
      expect(() => l.aktion(UhrAktion.plus, zeit: 0, minuten: 0), throwsArgumentError);
      expect(() => l.aktion(UhrAktion.plus, zeit: 0, minuten: 61), throwsArgumentError);
      expect(() => u.aktion(UhrAktion.start, zeit: 0, minuten: 121), throwsArgumentError);
      expect(() => l.aktion(UhrAktion.pause, zeit: 0, minuten: 5), throwsArgumentError);
      var lang = RundenUhr.minuten(120);
      lang = lang.aktion(UhrAktion.plus, zeit: 0, minuten: 60);
      expect(() => lang.aktion(UhrAktion.plus, zeit: 0, minuten: 1), throwsArgumentError, reason: 'höchstens drei Stunden');
      expect(() => RundenUhr.neu(0), throwsArgumentError);
    });

    test('Die Ansicht ist JSON ohne Takt und liest sich zurück', () {
      final p = RundenUhr.minuten(10).aktion(UhrAktion.start, zeit: 7).aktion(UhrAktion.pause, zeit: 60007);
      expect(p.toJson(), {'dauer': 10 * _min, 'start': 7, 'pausiert': true, 'restBeiPause': 9 * _min});
      expect(RundenUhr.minuten(5).toJson(), {'dauer': 5 * _min, 'pausiert': true});
      expect(RundenUhr.ausJson(jsonDecode(jsonEncode(p.toJson()))), p);
      for (final kaputt in [null, 3, {'dauer': 'x', 'pausiert': true}, {'dauer': 10, 'pausiert': 1}, {'dauer': 0, 'pausiert': true}]) {
        expect(RundenUhr.ausJson(kaputt), isNull, reason: '$kaputt');
      }
      expect(mitAbendzeit({'typ': 'uhr', 'zeit': 3}, 9), {'typ': 'uhr', 'zeit': 9}, reason: 'Der Transport überschreibt mitgeschickte Zeit');
    });
  });

  group('Uhr im Raum', () {
    test('Nur in den Gesprächen; jede Runde beginnt mit voller, stehender Uhr', () {
      final r = _raum();
      _start(r);
      expect(r.zustandFuer('p0').containsKey('uhr'), isFalse);
      expect(() => _befehl(r, 'p0', 'uhr', {'aktion': 'start'}), throwsA(_fehler('invalid_phase')));
      _bis(r, 'gespraeche');
      expect(_uhr(r), RundenUhr.minuten(20));
      _befehl(r, 'p0', 'uhr', {'aktion': 'start'}, 5000);
      expect(_uhr(r).start, 5000);
      _bis(r, 'entscheidungen');
      expect(r.zustandFuer('p0').containsKey('uhr'), isFalse);
      expect(() => _befehl(r, 'p0', 'uhr', {'aktion': 'pause'}), throwsA(_fehler('invalid_phase')));
      _bis(r, 'gespraeche', runde: 2);
      expect(_uhr(r), RundenUhr.minuten(20), reason: 'Neue Runde, neue Uhr');
    });

    test('Die Zeit kommt nur vom Transport: ohne Abendzeit invalid, Gerätezeit wird überschrieben', () {
      final r = _raum();
      _start(r);
      _bis(r, 'gespraeche');
      expect(() => r.nachricht('p0', {'typ': 'uhr', 'aktion': 'start'}), throwsA(_fehler('invalid')));
      expect(() => r.nachricht('p0', {'typ': 'uhr', 'aktion': 'start', 'zeit': 'jetzt'}), throwsA(_fehler('invalid')));
      expect(() => r.nachricht('p0', {'typ': 'weiter', 'zeit': -1}), throwsA(_fehler('invalid')));
      // Ein Gast schickt eine eigene Zeit; der Transport stempelt seine.
      r.nachricht('p0', mitAbendzeit({'typ': 'uhr', 'aktion': 'start', 'zeit': 1}, 777));
      expect(_uhr(r).start, 777);
    });

    test('Aktionen, Zustände und Minuten mit festen Codes', () {
      final r = _raum();
      _start(r);
      _bis(r, 'gespraeche');
      expect(() => _befehl(r, 'p0', 'uhr', {'aktion': 'stopp'}), throwsA(_fehler('invalid')));
      expect(() => _befehl(r, 'p0', 'uhr', {'aktion': 'plus', 'minuten': '5'}), throwsA(_fehler('invalid')));
      expect(() => _befehl(r, 'p0', 'uhr', {'aktion': 'plus'}), throwsA(_fehler('invalid')));
      expect(() => _befehl(r, 'p0', 'uhr', {'aktion': 'start', 'wer': 'p1'}), throwsA(_fehler('invalid')));
      expect(() => _befehl(r, 'p0', 'uhr', {'aktion': 'pause'}), throwsA(_fehler('invalid_phase')), reason: 'Die Uhr läuft noch nicht');
      _befehl(r, 'p0', 'uhr', {'aktion': 'start'}, 0);
      _befehl(r, 'p0', 'uhr', {'aktion': 'pause'}, 2 * _min);
      _befehl(r, 'p0', 'uhr', {'aktion': 'plus', 'minuten': 5}, 3 * _min);
      _befehl(r, 'p0', 'uhr', {'aktion': 'weiter'}, 10 * _min);
      final u = _uhr(r);
      expect([u.laeuft, u.rest(10 * _min), u.dauer], [true, 23 * _min, 25 * _min]);
    });

    test('Rechte: nur wer leitet (Erzähler, sonst Detektiv); öffentlich für alle gleich', () {
      final r = _raum();
      _start(r, erzaehler: true);
      _bis(r, 'gespraeche', leiter: 'p1');
      for (final id in ['p0', 'p2', 'p3']) {
        expect(() => _befehl(r, id, 'uhr', {'aktion': 'start'}), throwsA(_fehler('not_host')), reason: id);
      }
      _befehl(r, 'p1', 'uhr', {'aktion': 'start'}, 4242);
      final ansichten = [for (final id in ['p0', 'p1', 'p2', 'p3']) jsonEncode(r.zustandFuer(id)['uhr'])];
      expect(ansichten.toSet(), hasLength(1));
      expect(_uhr(r, 'p3').start, 4242);
      // Fällt der Erzähler aus, führt der Detektiv die Uhr weiter.
      r.verbunden('p1', false);
      _befehl(r, 'p0', 'uhr', {'aktion': 'pause'}, 5000);
      expect(_uhr(r).pausiert, isTrue);
    });

    test('Kein Takt: Ohne Aktion bleibt die Ansicht gleich, egal wie viel Zeit vergeht', () {
      final r = _raum();
      _start(r);
      _bis(r, 'gespraeche');
      _befehl(r, 'p0', 'uhr', {'aktion': 'start'}, 0);
      final vorher = jsonEncode(r.zustandFuer('p2'));
      expect(jsonEncode(r.zustandFuer('p2')), vorher);
      expect(raumOeffentlicheSchluessel, containsAll(['uhr', 'dia']));
    });

    test('Wiederherstellung: Das Protokoll mit seinen Zeiten ergibt dieselbe Uhr', () {
      final r = ProtokollRaum(_raum());
      _start(r);
      _bis(r, 'gespraeche');
      _befehl(r, 'p0', 'uhr', {'aktion': 'start'}, 1000);
      _befehl(r, 'p0', 'uhr', {'aktion': 'pause'}, 1000 + 3 * _min);
      _befehl(r, 'p0', 'uhr', {'aktion': 'plus', 'minuten': 5}, 1000 + 4 * _min);
      _befehl(r, 'p0', 'uhr', {'aktion': 'weiter'}, 1000 + 6 * _min);
      // Wie in der Ablage des Gastgebers: als JSON geschrieben und gelesen.
      final abgelegt = [for (final e in jsonDecode(jsonEncode(r.protokoll)) as List) (e as List).cast<Object?>()];
      final neu = ProtokollRaum.wiederherstellen(abgelegt, _raum);
      for (final id in ['p0', 'p1', 'p2', 'p3']) {
        expect(jsonEncode(neu.zustandFuer(id)), jsonEncode(r.zustandFuer(id)), reason: id);
      }
      expect(_uhr(neu).rest(1000 + 6 * _min), 22 * _min);
    });

    test('Die Rundendauer der Einrichtung gilt; Unsinn wird begrenzt statt den Raum zu sprengen', () {
      for (final (minuten, soll) in [(45, 45), (0, 1), (500, RundenUhr.hoechstStart)]) {
        final r = _raum(minuten: minuten);
        _start(r);
        _bis(r, 'gespraeche');
        expect(_uhr(r).dauer, soll * _min, reason: '$minuten');
      }
    });
  });

  group('Langer Abend (M7b): eine Uhr für den ganzen Streifzug', () {
    test('Lang läuft die Uhr der Gespräche in den Entscheidungen weiter; erst die Gruppenwahl räumt sie ab', () {
      final r = _raum(fassung: Abendfassung.lang);
      expect(r.fassung, Abendfassung.lang);
      _start(r);
      expect(r.zustandFuer('p2')['fassung'], 'lang', reason: 'Alle sehen die Fassung, auch in der Lobby');
      expect(() => _befehl(r, 'p0', 'uhr', {'aktion': 'start'}), throwsA(_fehler('invalid_phase')));
      _bis(r, 'gespraeche');
      expect(_uhr(r), RundenUhr.minuten(20));
      _befehl(r, 'p0', 'uhr', {'aktion': 'start'}, 5000);
      _bis(r, 'entscheidungen');
      expect(_uhr(r).start, 5000, reason: 'Dieselbe Uhr, nicht neu gestellt');
      expect(_uhr(r, 'p3').laeuft, isTrue);
      _befehl(r, 'p0', 'uhr', {'aktion': 'pause'}, 5000 + 7 * _min);
      _befehl(r, 'p0', 'uhr', {'aktion': 'plus', 'minuten': 5}, 5000 + 8 * _min);
      _befehl(r, 'p0', 'uhr', {'aktion': 'weiter'}, 5000 + 9 * _min);
      final u = _uhr(r, 'p2');
      expect([u.laeuft, u.dauer, u.rest(5000 + 9 * _min)], [true, 25 * _min, 18 * _min]);
      _bis(r, 'gruppenwahl');
      expect(r.zustandFuer('p0').containsKey('uhr'), isFalse);
      expect(() => _befehl(r, 'p0', 'uhr', {'aktion': 'pause'}), throwsA(_fehler('invalid_phase')));
      _bis(r, 'gespraeche', runde: 2);
      expect(_uhr(r), RundenUhr.minuten(20), reason: 'Neue Runde, neue Uhr');
      _bis(r, 'entscheidungen', runde: 2);
      expect(_uhr(r), RundenUhr.minuten(20), reason: 'Ungestartet bleibt sie auch in den Entscheidungen stehen');
      _befehl(r, 'p0', 'uhr', {'aktion': 'start'}, 9000);
      expect(_uhr(r).start, 9000, reason: 'In den Entscheidungen lässt sie sich auch starten');
    });

    test('Lang in den Entscheidungen: nur wer leitet stellt die Uhr, alle sehen dieselbe', () {
      final r = _raum(fassung: Abendfassung.lang);
      _start(r, erzaehler: true);
      _bis(r, 'gespraeche', leiter: 'p1');
      _befehl(r, 'p1', 'uhr', {'aktion': 'start'}, 100);
      _bis(r, 'entscheidungen', leiter: 'p1');
      for (final id in ['p0', 'p2', 'p3']) {
        expect(() => _befehl(r, id, 'uhr', {'aktion': 'pause'}), throwsA(_fehler('not_host')), reason: id);
      }
      _befehl(r, 'p1', 'uhr', {'aktion': 'pause'}, 200);
      expect({for (final id in ['p0', 'p1', 'p2', 'p3']) jsonEncode(r.zustandFuer(id)['uhr'])}, hasLength(1));
      expect(_uhr(r, 'p2').pausiert, isTrue);
    });

    test('Kurz bleibt, wie es war: nie der Schlüssel fassung, keine Uhr in den Entscheidungen', () {
      final r = _raum();
      expect(r.fassung, Abendfassung.kurz);
      _start(r);
      for (var i = 0; i < 400 && r.zustandFuer('p0')['phase'] != 'ende'; i++) {
        final s = r.zustandFuer('p2');
        expect(s.containsKey('fassung'), isFalse, reason: '${s['phase']}');
        if (s['phase'] == 'entscheidungen') {
          expect(s.containsKey('uhr'), isFalse);
          expect(() => _befehl(r, 'p0', 'uhr', {'aktion': 'start'}), throwsA(_fehler('invalid_phase')));
        }
        _schritt(r, 'p0');
      }
      expect(r.zustandFuer('p0')['phase'], 'ende');
    });

    test('Lang und kurz spielen denselben Abend: Ansichten gleich bis auf Fassung und Uhr, Auflösung, Würfe und Nachtminuten gleich', () {
      final kurz = _raum(), lang = _raum(fassung: Abendfassung.lang);
      _start(kurz);
      _start(lang);
      Map<String, Object?> ohne(Map<String, Object?> v) => Map.of(v)..remove('fassung')..remove('uhr');
      var schritte = 0;
      while (kurz.zustandFuer('p0')['phase'] != 'ende') {
        expect(++schritte, lessThan(400));
        for (final id in ['p0', 'p1', 'p2', 'p3']) {
          expect(jsonEncode(ohne(lang.zustandFuer(id))), jsonEncode(ohne(kurz.zustandFuer(id))), reason: '$id, Schritt $schritte');
        }
        _schritt(kurz, 'p0');
        _schritt(lang, 'p0');
      }
      final a = kurz.zustandFuer('p0'), b = lang.zustandFuer('p0');
      expect(b['phase'], 'ende');
      for (final k in ['aufloesung', 'wuerfe', 'restMinuten', 'marken', 'notizbuch', 'gewaehlt']) {
        expect(jsonEncode(b[k]), jsonEncode(a[k]), reason: k);
      }
    });

    test('Lang: Das Protokoll ergibt nach der Wiederherstellung dieselbe Uhr in den Entscheidungen', () {
      final r = ProtokollRaum(_raum(fassung: Abendfassung.lang));
      _start(r);
      _bis(r, 'gespraeche');
      _befehl(r, 'p0', 'uhr', {'aktion': 'start'}, 1000);
      _bis(r, 'entscheidungen');
      _befehl(r, 'p0', 'uhr', {'aktion': 'pause'}, 1000 + 3 * _min);
      final abgelegt = [for (final e in jsonDecode(jsonEncode(r.protokoll)) as List) (e as List).cast<Object?>()];
      final neu = ProtokollRaum.wiederherstellen(abgelegt, () => _raum(fassung: Abendfassung.lang));
      for (final id in ['p0', 'p1', 'p2', 'p3']) {
        expect(jsonEncode(neu.zustandFuer(id)), jsonEncode(r.zustandFuer(id)), reason: id);
      }
      expect(_uhr(neu).restBeiPause, 17 * _min);
    });

    test('Der Schlüssel fassung ist öffentlich freigegeben', () {
      expect(raumOeffentlicheSchluessel, contains('fassung'));
    });
  });

  group('Diashow im Raum', () {
    test('Nur in der Einleitung, nur der Leiter, nur gültige Bilder; alle sehen dasselbe', () {
      final r = _raum();
      _start(r, erzaehler: true);
      expect(() => _befehl(r, 'p1', 'dia', {'nr': 1}), throwsA(_fehler('invalid_phase')));
      _bis(r, 'intro', runde: 0, leiter: 'p1');
      expect(r.zustandFuer('p2')['dia'], 0);
      expect(() => _befehl(r, 'p0', 'dia', {'nr': 1}), throwsA(_fehler('not_host')));
      expect(() => _befehl(r, 'p2', 'dia', {'nr': 1}), throwsA(_fehler('not_host')));
      for (final falsch in [-1, 6, '2', null]) {
        expect(() => _befehl(r, 'p1', 'dia', {'nr': falsch}), throwsA(_fehler('invalid')), reason: '$falsch');
      }
      expect(() => _befehl(r, 'p1', 'dia', {'nr': 1, 'text': 'x'}), throwsA(_fehler('invalid')));
      _befehl(r, 'p1', 'dia', {'nr': 3});
      expect({for (final id in ['p0', 'p1', 'p2', 'p3']) r.zustandFuer(id)['dia']}, {3});
      // Den Text sieht nur der Vorleser; die Nummer ist öffentlich.
      expect(_map(r.zustandFuer('p2')['privat']).containsKey('erzaehler'), isFalse);
      expect((_map(r.zustandFuer('p1')['privat'])['erzaehler'] as List), hasLength(6));
      _bis(r, 'gespraeche', leiter: 'p1');
      expect(r.zustandFuer('p0').containsKey('dia'), isFalse);
    });

    test('Akten ohne Diashow kennen die Nachricht nicht', () {
      final r = _raum(dias: 0);
      _start(r);
      _bis(r, 'intro', runde: 0);
      expect(r.zustandFuer('p0').containsKey('dia'), isFalse);
      expect(() => _befehl(r, 'p0', 'dia', {'nr': 0}), throwsA(_fehler('invalid')));
    });
  });
}
