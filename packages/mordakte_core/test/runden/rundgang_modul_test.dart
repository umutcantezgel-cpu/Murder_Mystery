// M7b: Vorspiel und Morgen im Online-Raum (RundgangModul). Nur im langen Abend
// mit Inhalt der Akte. Öffentlich sehen alle dieselbe Station mit der Karte
// nach R17, den Vorlesetext bekommt nur der Vorleser privat. Weiter in die
// Runden erst nach dem Vorspiel; beendet ist der Abend erst nach dem Morgen.
// Rechte und Fehlercodes sind fest (`not_host`, `stale`, `invalid`,
// `invalid_phase`); die Partie bleibt unberührt.
import 'dart:convert';

import 'package:mordakte_core/mordakte_core.dart';
import 'package:mordakte_core/runden.dart';
import 'package:test/test.dart';

import '../party/kanon_hilfe.dart';
import 'befragung_treiber.dart';

final _texte = Texte(kanon, Textsammlung.lade((p) => leseJson('$repoWurzel/content/party/schlosskeller/$p')));
final _erm = Ermittlung(kanon);
final _inhalt = VorspielMorgen.ausJson(leseJson('$repoWurzel/content/welt/schlosskeller/vorspiel_morgen.json'));

SchlosskellerRaum _raum({Abendfassung fassung = Abendfassung.lang, String pfad = 'ahmet', bool mitInhalt = true}) => SchlosskellerRaum(
      raumCode: 'ABCD', kanon: kanon, texte: _texte, diaAnzahl: 6, fassung: fassung, rundgang: mitInhalt ? _inhalt : null,
      fallCode: FallCode.fuerPfad(pfad, kanon.pfade), salz: 'pruefung-raumsalz-unabhaengig-vom-pfad',
    );

Map<String, Object?> _map(Object? v) => (v as Map).cast<String, Object?>();
List<Map<String, Object?>> _liste(Object? v) => [for (final x in v as List) _map(x)];
Matcher _fehler(String code) => isA<PartyRaumFehler>().having((e) => e.code, 'code', code);

void _befehl(AbendRaum r, String id, String typ, [Map<String, Object?> d = const {}]) => r.nachricht(id, mitAbendzeit({'typ': typ, ...d}, 1000));

/// Vier Geräte: p0 Gastgeber und Detektiv, p1 Erzähler, p2 und p3 spielen Rollen.
void _start(AbendRaum r) {
  for (var i = 0; i < 4; i++) {
    expect(r.beitreten('p$i', 'Person $i'), isTrue);
  }
  _befehl(r, 'p0', 'sitz', {'spieler': 'p1', 'sitz': 'erzaehler'});
  for (var i = 0; i < 4; i++) {
    _befehl(r, 'p$i', 'bereit', {'wert': true});
  }
  _befehl(r, 'p0', 'start', {'rollen': 4});
}

/// Ein Schritt wie am Tisch: Detektiv p0, Leiter p1 (Erzähler). Rundgänge geht der Leiter ab.
void _schritt(AbendRaum r, String pfad, {String? anklage}) {
  final s = r.zustandFuer('p0');
  if (s['rundgang'] case final Map g) {
    _befehl(r, 'p1', 'rundgang', {'station': g['station']});
    return;
  }
  switch (s['phase']) {
    case 'rollen':
      for (final t in _liste(s['spieler'])) {
        if (t['rolle'] != null) _befehl(r, t['id'] as String, 'rollenGelesen');
      }
      _befehl(r, 'p1', 'weiter');
    case 'gespraeche':
      befragungenErledigen(s, (typ, d) => _befehl(r, 'p0', typ, d));
      _befehl(r, 'p1', 'weiter');
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
        _befehl(r, 'p0', 'wahl', {'option': _erm.entscheidung(e['id'] as String).richtig[pfad]!});
      } else {
        _befehl(r, 'p1', 'weiter');
      }
    case 'gruppenwahl':
      for (final t in _liste(s['spieler'])) {
        final id = t['id'] as String;
        final privat = _map(r.zustandFuer(id)['privat']);
        if (privat['rolle'] != null && privat['hatGestimmt'] == false) _befehl(r, id, 'stimme', {'kooperativ': true});
      }
      _befehl(r, 'p1', 'weiter');
    case 'anklage' when s['kannWeiter'] != true:
      _befehl(r, 'p0', 'anklage', {'person': anklage ?? pfad});
    default:
      _befehl(r, 'p1', 'weiter');
  }
}

/// Spielt bis [erreicht] (Ansicht von p0) gilt.
void _bis(AbendRaum r, bool Function(Map<String, Object?>) erreicht, {String pfad = 'ahmet', String? anklage}) {
  for (var i = 0; i < 600; i++) {
    if (erreicht(r.zustandFuer('p0'))) return;
    _schritt(r, pfad, anklage: anklage);
  }
  fail('Zielzustand nicht erreicht');
}

/// Was den Abend bewertet, aus der Ansicht des Gastgebers (nach dem Finale).
String _wertung(Map<String, Object?> s) => jsonEncode([s['wuerfe'], s['gewaehlt'], s['restMinuten'], s['marken'], s['notizbuch'], _map(s['aufloesung'])..remove('salz')]);

void main() {
  test('Vorspiel: alle sehen dieselbe Station, den Vorlesetext nur der Vorleser; Weiter erst nach dem Vorspiel', () {
    final r = _raum();
    _start(r);
    _bis(r, (s) => s['phase'] == 'intro');
    final v = _inhalt.vorspiel;
    for (var i = 0; i < v.stationen.length; i++) {
      final st = v.stationen[i];
      final ansichten = {for (final id in ['p0', 'p1', 'p2', 'p3']) id: r.zustandFuer(id)};
      final oeffentlich = {for (final a in ansichten.values) jsonEncode(a['rundgang'])};
      expect(oeffentlich, hasLength(1), reason: 'Station $i für alle gleich');
      final g = _map(ansichten['p2']!['rundgang']);
      expect(g.keys.toSet(), {'teil', 'station', 'anzahl', 'id', 'zeit', 'karte'});
      expect([g['teil'], g['station'], g['anzahl'], g['id'], g['zeit']], ['vorspiel', i, v.stationen.length, st.id, '${st.zeit}']);
      expect(g['karte'], st.text!.karteJson());
      // Vorleser ist der Erzähler (p1): nur er bekommt den Vorlesetext, privat.
      expect(_map(ansichten['p1']!['privat'])['rundgangText'], st.text!.vorlesen);
      for (final id in ['p0', 'p2', 'p3']) {
        expect(jsonEncode(ansichten[id]), isNot(contains(jsonEncode(st.text!.vorlesen))), reason: '$id liest nicht vor');
      }
      expect(ansichten['p1']!['kannWeiter'], isFalse);
      expect(() => _befehl(r, 'p1', 'weiter'), throwsA(_fehler('not_ready')));
      expect(() => _befehl(r, 'p2', 'rundgang', {'station': i}), throwsA(_fehler('not_host')));
      expect(() => _befehl(r, 'p0', 'rundgang', {'station': i}), throwsA(_fehler('not_host')), reason: 'Der Detektiv leitet nicht, solange der Erzähler da ist');
      expect(() => _befehl(r, 'p1', 'rundgang', {'station': i + 1}), throwsA(_fehler('stale')));
      expect(() => _befehl(r, 'p1', 'rundgang', {'station': '$i'}), throwsA(_fehler('invalid')));
      expect(() => _befehl(r, 'p1', 'rundgang', {'station': i, 'ueberspringen': true}), throwsA(_fehler('invalid')));
      expect(() => _befehl(r, 'p1', 'rundgang', {'ueberspringen': false}), throwsA(_fehler('invalid')));
      expect(() => _befehl(r, 'p1', 'rundgang', {'station': i, 'karte': 'x'}), throwsA(_fehler('invalid')));
      _befehl(r, 'p1', 'rundgang', {'station': i});
    }
    // Nach der Sperre: die Diashow, und es geht weiter in die Runden.
    final s = r.zustandFuer('p1');
    expect([s['phase'], s.containsKey('rundgang'), s['kannWeiter'], s['dia']], ['intro', false, true, 0]);
    expect(_map(s['privat']).containsKey('rundgangText'), isFalse);
    expect(() => _befehl(r, 'p1', 'rundgang', {'station': 0}), throwsA(_fehler('invalid_phase')));
    _befehl(r, 'p1', 'dia', {'nr': 1});
    _befehl(r, 'p1', 'weiter');
    expect(r.zustandFuer('p0')['phase'], 'gespraeche');
    expect(() => _befehl(r, 'p1', 'rundgang', {'station': 0}), throwsA(_fehler('invalid_phase')));
  });

  test('Morgen: erst nach dem Morgen beendet; die letzte Station zeigt die Karte zum gezogenen Ende', () {
    final enden = <String>{};
    for (final (pfad, anklage) in [for (final p in kanon.pfade) (p, null), ('ahmet', 'fatma')]) {
      final r = _raum(pfad: pfad);
      _start(r);
      _bis(r, (s) => s['phase'] == 'ende', pfad: pfad, anklage: anklage);
      final ende = _map(r.zustandFuer('p0')['aufloesung'])['ende'] as String;
      enden.add(ende);
      final m = _inhalt.morgen;
      final wertung = _wertung(r.zustandFuer('p0'));
      for (var i = 0; i < m.stationen.length; i++) {
        expect(r.beendet, isFalse, reason: '$pfad: Der Morgen läuft, Station $i');
        final g = _map(r.zustandFuer('p3')['rundgang']);
        expect([g['teil'], g['station']], ['morgen', i]);
        expect(g['karte'], m.stationen[i].textFuer(ende).karteJson(), reason: '$pfad/$ende');
        expect(_map(r.zustandFuer('p1')['privat'])['rundgangText'], m.stationen[i].textFuer(ende).vorlesen);
        _befehl(r, 'p1', 'rundgang', {'station': i});
      }
      expect(r.beendet, isTrue, reason: pfad);
      expect(r.zustandFuer('p0').containsKey('rundgang'), isFalse);
      expect(_wertung(r.zustandFuer('p0')), wertung, reason: 'Der Morgen ändert nichts am Abend');
    }
    expect(enden, containsAll(['ende_meister', 'ende_justizirrtum']), reason: 'richtige und falsche Anklage');
  });

  test('Überspringen beendet den Rundgang sofort; im Ende ist der Raum dann beendet', () {
    final r = _raum();
    _start(r);
    _bis(r, (s) => s['phase'] == 'intro');
    _befehl(r, 'p1', 'rundgang', {'ueberspringen': true});
    expect(r.zustandFuer('p0')['kannWeiter'], isTrue);
    _bis(r, (s) => s['phase'] == 'ende');
    expect(r.beendet, isFalse);
    _befehl(r, 'p1', 'rundgang', {'station': 0});
    _befehl(r, 'p1', 'rundgang', {'ueberspringen': true});
    expect(r.beendet, isTrue);
    expect(() => _befehl(r, 'p1', 'rundgang', {'ueberspringen': true}), throwsA(_fehler('invalid_phase')));
  });

  test('Fällt der Erzähler aus, führt und liest der Detektiv weiter', () {
    final r = _raum();
    _start(r);
    _bis(r, (s) => s['phase'] == 'intro');
    r.verbunden('p1', false);
    expect(_map(r.zustandFuer('p0')['privat'])['rundgangText'], _inhalt.vorspiel.stationen.first.text!.vorlesen);
    _befehl(r, 'p0', 'rundgang', {'station': 0});
    expect(_map(r.zustandFuer('p0')['rundgang'])['station'], 1);
  });

  test('Kurz und lang ohne Inhalt: kein Rundgang, der Abend endet wie bisher', () {
    for (final r in [_raum(fassung: Abendfassung.kurz), _raum(mitInhalt: false)]) {
      _start(r);
      _bis(r, (s) => s['phase'] == 'intro');
      final s = r.zustandFuer('p1');
      expect([s.containsKey('rundgang'), s['kannWeiter'], _map(s['privat']).containsKey('rundgangText')], [false, true, false]);
      expect(() => _befehl(r, 'p1', 'rundgang', {'station': 0}), throwsA(_fehler('invalid')));
      _bis(r, (s) => s['phase'] == 'ende');
      expect(r.beendet, isTrue);
    }
  });

  test('Der öffentliche Schlüssel rundgang steht in der Sichtfeld-Liste; kurz und lang spielen dieselbe Partie', () {
    expect(raumOeffentlicheSchluessel, contains('rundgang'));
    final kurz = _raum(fassung: Abendfassung.kurz), lang = _raum();
    for (final r in [kurz, lang]) {
      _start(r);
      _bis(r, (s) => s['phase'] == 'ende' && !s.containsKey('rundgang'));
    }
    expect(_wertung(lang.zustandFuer('p0')), _wertung(kurz.zustandFuer('p0')));
  });
}
