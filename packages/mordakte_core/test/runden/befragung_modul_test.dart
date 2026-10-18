// A-051 (M2b): Befragungen im Online-Abend. Nur der Detektiv fragt, nur in den
// Gesprächen und nur nach Plan. App-Rollen antworten nur ihm und erst nach der
// Frage; Menschen bekommen ihren Spickzettel privat. Öffentlich sind nur
// Paarungen und Themen. „Weiter“ wartet, bis die Runde durch ist.
import 'dart:convert';

import 'package:mordakte_core/mordakte_core.dart';
import 'package:mordakte_core/runden.dart';
import 'package:test/test.dart';

import '../party/kanon_hilfe.dart';
import 'befragung_treiber.dart';

final _texte = Texte(kanon, Textsammlung.lade((p) => leseJson('$repoWurzel/content/party/schlosskeller/$p')));
final _erm = Ermittlung(kanon);
const _salz = 'pruefung-raumsalz-unabhaengig-vom-pfad';

SchlosskellerRaum _raum({String pfad = 'ahmet'}) => SchlosskellerRaum(
      raumCode: 'ABCD', kanon: kanon, texte: _texte,
      fallCode: FallCode.fuerPfad(pfad, kanon.pfade), salz: _salz,
    );

Map<String, Object?> _map(Object? v) => (v as Map).cast<String, Object?>();
List<Map<String, Object?>> _liste(Object? v) => [for (final x in v as List) _map(x)];
void _befehl(SchlosskellerRaum r, String id, String typ, [Map<String, Object?> d = const {}]) => r.nachricht(id, {'typ': typ, ...d});
Matcher _fehler(String code) => isA<PartyRaumFehler>().having((e) => e.code, 'code', code);

/// Startet mit [geraete] Geräten (p0 ist Gastgeber und Detektiv) und spielt bis zu den Gesprächen der Runde [runde].
SchlosskellerRaum _bisGespraeche(int geraete, int rollen, {int runde = 1, String pfad = 'ahmet'}) {
  final r = _raum(pfad: pfad);
  for (var i = 0; i < geraete; i++) {
    expect(r.beitreten('p$i', 'Person $i'), isTrue);
    _befehl(r, 'p$i', 'bereit', {'wert': true});
  }
  _befehl(r, 'p0', 'start', {'rollen': rollen});
  for (var i = 0; i < 400; i++) {
    final s = r.zustandFuer('p0');
    if (s['phase'] == 'gespraeche' && s['runde'] == runde) return r;
    switch (s['phase']) {
      case 'rollen':
        for (var g = 1; g < geraete; g++) {
          if (_map(r.zustandFuer('p$g')['privat'])['rolle'] != null) _befehl(r, 'p$g', 'rollenGelesen');
        }
      case 'gespraeche':
        befragungenErledigen(s, (typ, d) => _befehl(r, 'p0', typ, d));
      case 'entscheidungen':
        if (s['zug'] case final Map z) {
          switch (z['phase']) {
            case 'aktion': _befehl(r, 'p0', 'aktionFertig', {'aktion': z['aktion']});
            case 'wurf': _befehl(r, s['wuerfelPate'] as String, 'wurf');
            case 'tischruf': _befehl(r, 'p0', 'tischruf', {'ruf': 'umweg'});
            case 'fund': _befehl(r, 'p0', 'fundGelesen');
          }
          continue;
        } else if (s['entscheidung'] case final Map e) {
          _befehl(r, 'p0', 'wahl', {'option': _erm.entscheidung(e['id'] as String).richtig[pfad]!});
          continue;
        }
      case 'gruppenwahl':
        for (var g = 1; g < geraete; g++) {
          final p = _map(r.zustandFuer('p$g')['privat']);
          if (p['rolle'] != null && p['hatGestimmt'] == false) _befehl(r, 'p$g', 'stimme', {'kooperativ': true});
        }
      case 'anklage':
        _befehl(r, 'p0', 'anklage', {'person': pfad});
    }
    _befehl(r, 'p0', 'weiter');
  }
  fail('Gespräche der Runde $runde nicht erreicht');
}

List<Map<String, Object?>> _karten(SchlosskellerRaum r) => _liste(_map(r.zustandFuer('p0')['privat'])['befragungen']);

void main() {
  final plan = Befragungsplan(_texte);

  test('Der Schlosskeller-Raum bringt das Modul mit; „Weiter“ wartet auf die Befragungen', () {
    final r = _bisGespraeche(1, 7);
    final s = r.zustandFuer('p0');
    expect(s['kannWeiter'], isFalse);
    expect(() => _befehl(r, 'p0', 'weiter'), throwsA(_fehler('not_ready')));
    final br = plan.fuer(7, 1);
    final karten = _karten(r);
    expect([for (final k in karten) k['rolle']], [...br.pflicht, ...br.frei]);
    expect(_map(s['privat'])['befragungenFrei'], br.freiWahlen);
    expect(s.containsKey('botGespraeche'), isFalse, reason: 'Im Modell befragung keine öffentlichen Sprechblasen');
    befragungenErledigen(s, (typ, d) => _befehl(r, 'p0', typ, d));
    expect(r.zustandFuer('p0')['kannWeiter'], isTrue);
    _befehl(r, 'p0', 'weiter');
    expect(r.zustandFuer('p0')['phase'], 'entscheidungen');
  });

  test('Rechte und Regeln: nur der Detektiv, nur in den Gesprächen, nur nach Plan', () {
    final r = _bisGespraeche(3, 7);
    final karten = _karten(r);
    final pflicht = karten.firstWhere((k) => k['pflicht'] == true);
    expect(() => _befehl(r, 'p1', 'befragen', {'id': pflicht['id'], 'frage': 0}), throwsA(_fehler('not_detective')));
    expect(() => _befehl(r, 'p0', 'befragen', {'id': 'bf_niemand_1', 'frage': 0}), throwsA(_fehler('invalid')));
    expect(() => _befehl(r, 'p0', 'befragen', {'id': 'bf_ahmet_2', 'frage': 0}), throwsA(_fehler('invalid')), reason: 'falsche Runde');
    expect(() => _befehl(r, 'p0', 'befragen', {'id': pflicht['id'], 'frage': 9}), throwsA(_fehler('invalid')));
    expect(() => _befehl(r, 'p0', 'befragen', {'id': pflicht['id'], 'frage': '0'}), throwsA(_fehler('invalid')));
    expect(() => _befehl(r, 'p0', 'befragen', {'id': pflicht['id'], 'frage': 0, 'antwort': 'x'}), throwsA(_fehler('invalid')));
    expect(() => _befehl(r, 'p0', 'erledigt', {'id': pflicht['id']}), throwsA(_fehler('invalid_phase')), reason: 'erst fragen');
    // Freie Wahlen: höchstens so viele, wie die Runde erlaubt.
    final frei = karten.where((k) => k['pflicht'] != true).toList();
    final wahlen = _map(r.zustandFuer('p0')['privat'])['befragungenFrei'] as int;
    for (var i = 0; i < wahlen; i++) {
      _befehl(r, 'p0', 'befragen', {'id': frei[i]['id'], 'frage': 0});
    }
    expect(_map(r.zustandFuer('p0')['privat'])['befragungenFrei'], 0);
    expect(() => _befehl(r, 'p0', 'befragen', {'id': frei[wahlen]['id'], 'frage': 0}), throwsA(_fehler('invalid')));
    // Ein zweites Mal fragen ist erlaubt, zählt aber nicht als neue Wahl.
    _befehl(r, 'p0', 'befragen', {'id': frei[0]['id'], 'frage': 1});
    expect(_karten(r).firstWhere((k) => k['id'] == frei[0]['id'])['frage'], 0);
  });

  test('Außerhalb der Gespräche gibt es keine Befragung', () {
    final r = _raum();
    for (var i = 0; i < 2; i++) {
      r.beitreten('p$i', 'P$i');
      _befehl(r, 'p$i', 'bereit', {'wert': true});
    }
    expect(() => _befehl(r, 'p0', 'befragen', {'id': 'bf_ahmet_1', 'frage': 0}), throwsA(_fehler('not_started')));
    _befehl(r, 'p0', 'start', {'rollen': 4});
    expect(() => _befehl(r, 'p0', 'befragen', {'id': 'bf_ahmet_1', 'frage': 0}), throwsA(_fehler('invalid_phase')));
    expect(r.zustandFuer('p0').containsKey('befragungen'), isFalse);
    expect(_map(r.zustandFuer('p0')['privat']).containsKey('befragungen'), isFalse);
  });

  test('App-Rollen antworten nur dem Detektiv und erst nach der Frage; Menschen bekommen ihren Spickzettel', () {
    for (final (geraete, rollen) in [(1, 4), (3, 7), (8, 7), (21, 20)]) {
      final r = _bisGespraeche(geraete, rollen);
      final menschen = {
        for (var g = 1; g < geraete; g++)
          if (_map(r.zustandFuer('p$g')['privat'])['rolle'] case final String rolle) rolle: 'p$g',
      };
      final br = plan.fuer(rollen, 1);
      for (final k in _karten(r)) {
        expect(k.containsKey('antwort'), isFalse, reason: 'vor der Frage: ${k['id']}');
        expect(k['mensch'], menschen.containsKey(k['rolle']), reason: '${k['id']}');
      }
      // Feste Befragungen und alle freien Wahlen stellen.
      befragungenErledigen(r.zustandFuer('p0'), (typ, d) {
        if (typ == 'befragen') _befehl(r, 'p0', typ, d);
      });
      final gestellt = [for (final k in _karten(r)) if (k['frage'] != null) k];
      expect(gestellt.length, br.gesamt, reason: '$rollen Rollen');
      for (final k in gestellt) {
        final text = br.text(k['rolle'] as String);
        if (menschen.containsKey(k['rolle'])) {
          expect(k.containsKey('antwort'), isFalse, reason: 'Ein Mensch antwortet am Tisch: ${k['id']}');
          expect(k['erledigt'], isFalse);
        } else {
          expect(k['antwort'], botAntwort(_texte, text), reason: '${k['id']}');
          expect(k['erledigt'], isTrue);
        }
      }
      final antworten = {
        for (final k in gestellt)
          for (final a in botAntwort(_texte, br.text(k['rolle'] as String))) a,
      };
      final oeffentlich = <String>{};
      for (var g = 0; g < geraete; g++) {
        final s = r.zustandFuer('p$g');
        final o = Map.of(s)..remove('privat');
        oeffentlich.add(jsonEncode(o));
        final json = jsonEncode(o);
        for (final a in antworten) {
          expect(json, isNot(contains(jsonEncode(a).substring(1, jsonEncode(a).length - 1))), reason: 'öffentlich: $a');
        }
        expect(_liste(s['befragungen']).every((b) => b.keys.toSet().containsAll({'rolle', 'thema', 'erledigt'}) && b.length == 3), isTrue);
        expect(_liste(s['tisch']).every((t) => t.keys.toSet().difference({'rolle', 'partner', 'thema'}).isEmpty), isTrue);
        if (g == 0) continue;
        final privat = _map(s['privat']);
        expect(privat.containsKey('befragungen'), isFalse, reason: 'Nur der Detektiv hat Befragungskarten');
        final rolle = privat['rolle'] as String?;
        if (rolle == null) {
          expect(privat.containsKey('befragung'), isFalse);
          continue;
        }
        final eigen = _map(privat['befragung']);
        final soll = befragungsZettel(_texte, br.text(rolle));
        expect(eigen['id'], BefragungText.kennung(rolle, 1));
        expect(eigen['stichpunkte'], soll.stichpunkte);
        expect(eigen['behaupte'], soll.behaupten);
        expect(eigen['fragen'], br.text(rolle).fragen);
        // Kein fremder Spickzettel im eigenen privaten Teil.
        final privatJson = jsonEncode(privat);
        for (final x in [...br.pflicht, ...br.frei].where((x) => x != rolle)) {
          for (final z in befragungsZettel(_texte, br.text(x)).sagen) {
            if (soll.sagen.contains(z)) continue;
            expect(privatJson, isNot(contains(jsonEncode(z).substring(1, jsonEncode(z).length - 1))), reason: '$rolle sieht $x');
          }
        }
      }
      expect(oeffentlich, hasLength(1), reason: 'Der öffentliche Teil ist für alle Geräte gleich ($rollen Rollen)');
      // Menschen: erst nach „erledigt“ ist die Runde durch.
      if (menschen.keys.any((m) => gestellt.any((k) => k['rolle'] == m))) expect(r.zustandFuer('p0')['kannWeiter'], isFalse);
      befragungenErledigen(r.zustandFuer('p0'), (typ, d) => _befehl(r, 'p0', typ, d));
      expect(r.zustandFuer('p0')['kannWeiter'], isTrue, reason: '$rollen Rollen');
    }
  });

  test('Wer aufgibt, wird zur App-Rolle: Die Antwort kommt dann nach der Frage', () {
    final r = _bisGespraeche(5, 4);
    final rolle1 = _map(r.zustandFuer('p1')['privat'])['rolle'] as String;
    final id = BefragungText.kennung(rolle1, 1);
    expect(_karten(r).firstWhere((k) => k['id'] == id)['mensch'], isTrue);
    r.verlassen('p1');
    final k = _karten(r).firstWhere((k) => k['id'] == id);
    expect(k['mensch'], isFalse);
    if (k['pflicht'] == true || (_map(r.zustandFuer('p0')['privat'])['befragungenFrei'] as int) > 0) {
      _befehl(r, 'p0', 'befragen', {'id': id, 'frage': 0});
      expect(_karten(r).firstWhere((k) => k['id'] == id)['antwort'], botAntwort(_texte, plan.fuer(4, 1).text(rolle1)));
    }
  });

  test('Tischpaarungen der Runde sind öffentlich und nennen nie den Detektiv', () {
    final r = _bisGespraeche(1, 12, runde: 2);
    final tisch = _liste(r.zustandFuer('p0')['tisch']);
    expect(tisch, [
      for (final t in tischPaarungen(_texte, n: 12, runde: 2)) {'rolle': t.rolle, 'partner': t.partner, 'thema': t.thema},
    ]);
    expect(tisch.every((t) => t['partner'] != Besetzung.detektiv), isTrue);
    expect(tisch, hasLength(12));
  });
}
