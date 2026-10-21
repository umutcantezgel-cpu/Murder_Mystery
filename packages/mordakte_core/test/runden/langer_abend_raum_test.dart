// M7b Zusammenführung: der lange Online-Abend in einem Raum mit Streifzug
// (StreifzugModul) sowie Vorspiel und Morgen (RundgangModul). Die Folge lautet
// Vorspiel → Diashow → 3 × Streifzug (Gespräche, Entscheidungen) → Auflösung →
// Morgen; erst danach ist der Raum beendet. Die Module kommen sich nicht in die
// Quere: `streifzug` gibt es nur in den Runden, `rundgang` nur in Einleitung und
// Ende, jede Ansicht bleibt in der Sichtfeld-Liste. Gespielt wird dieselbe
// Partie wie im kurzen Abend.
import 'dart:convert';

import 'package:mordakte_core/mordakte_core.dart';
import 'package:mordakte_core/runden.dart';
import 'package:test/test.dart';

import '../party/kanon_hilfe.dart';
import 'befragung_treiber.dart';

final _texte = Texte(kanon, Textsammlung.lade((p) => leseJson('$repoWurzel/content/party/schlosskeller/$p')));
final _erm = Ermittlung(kanon);
final _erkundung = Erkundung.ausJson(leseJson('$repoWurzel/content/welt/schlosskeller/erkundung.json'));
final _inhalt = VorspielMorgen.ausJson(leseJson('$repoWurzel/content/welt/schlosskeller/vorspiel_morgen.json'));
const _salz = 'pruefung-raumsalz-unabhaengig-vom-pfad';
const _geraete = ['p0', 'p1', 'p2', 'p3'];

/// Der Raum wie beim Gastgeber: mit Diashow, Erkundung und Rundgang; kurz nimmt er beides nicht.
SchlosskellerRaum _raum(Abendfassung fassung) => SchlosskellerRaum(
      raumCode: 'ABCD', kanon: kanon, texte: _texte, diaAnzahl: 6, fassung: fassung, erkundung: _erkundung, rundgang: _inhalt,
      fallCode: FallCode.fuerPfad('ahmet', kanon.pfade), salz: _salz,
    );

Map<String, Object?> _map(Object? v) => (v as Map).cast<String, Object?>();
List<Map<String, Object?>> _liste(Object? v) => [for (final x in v as List) _map(x)];
Matcher _fehler(String code) => isA<PartyRaumFehler>().having((e) => e.code, 'code', code);

void _befehl(AbendRaum r, String id, String typ, [Map<String, Object?> d = const {}]) => r.nachricht(id, mitAbendzeit({'typ': typ, ...d}, 1000));

/// Vier Geräte: p0 Gastgeber und Detektiv, p1 Erzähler (leitet), p2 und p3 spielen Rollen.
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

/// Ein Schritt wie am Tisch: Detektiv p0, Leiter p1. Rundgänge geht der Leiter Station für Station ab.
void _schritt(AbendRaum r) {
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
        _befehl(r, 'p0', 'wahl', {'option': _erm.entscheidung(e['id'] as String).richtig['ahmet']!});
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
      _befehl(r, 'p0', 'anklage', {'person': 'ahmet'});
    default:
      _befehl(r, 'p1', 'weiter');
  }
}

/// Abschnitt der Ansicht: Vorspiel und Morgen als eigene Abschnitte, sonst die Phase.
String _abschnitt(Map<String, Object?> s) => s['rundgang'] is Map ? _map(s['rundgang'])['teil'] as String : s['phase'] as String;

/// Spielt den Abend bis zum Schluss und liefert die Folge der Abschnitte (ohne direkte Wiederholung).
List<String> _spiele(SchlosskellerRaum r, {void Function(Map<String, Object?> s)? jeSchritt}) {
  final folge = <String>[];
  for (var i = 0; i < 800; i++) {
    final s = r.zustandFuer('p0');
    final a = _abschnitt(s);
    if (folge.isEmpty || folge.last != a) folge.add(a);
    if (s['phase'] == 'ende' && s['rundgang'] == null) return folge;
    jeSchritt?.call(s);
    _schritt(r);
  }
  fail('Der Abend erreicht das Ende nicht: ${folge.join(' > ')}');
}

/// Was den Abend bewertet, aus der Ansicht des Detektivs.
String _wertung(Map<String, Object?> s) => jsonEncode([s['wuerfe'], s['gewaehlt'], s['restMinuten'], s['marken'], s['notizbuch'], s['aufloesung']]);

void main() {
  test('Vorspiel, Diashow, dreimal Streifzug, Auflösung, Morgen: beide Module im selben Raum, dieselbe Partie wie kurz', () {
    final kurz = _raum(Abendfassung.kurz);
    _start(kurz);
    final folgeKurz = _spiele(kurz);
    expect(kurz.beendet, isTrue);
    expect(folgeKurz.where((a) => a == 'vorspiel' || a == 'morgen'), isEmpty);

    final lang = _raum(Abendfassung.lang);
    _start(lang);
    final orte = [for (final o in _erkundung.orte) o.id];
    final erledigt = <String>{};
    final getroffen = <int, Set<String>>{};
    var erkundet = const <Object?>[];
    final folgeLang = _spiele(lang, jeSchritt: (s) {
      final phase = s['phase'] as String;
      final runde = s['runde'] as int;
      final imRundgang = s['rundgang'] is Map;
      final imStreifzug = phase == 'gespraeche' || phase == 'entscheidungen';
      for (final id in _geraete) {
        final v = lang.zustandFuer(id);
        expect(v.keys.where((k) => !raumOeffentlicheSchluessel.contains(k) && !raumSchluesselNachFinale.contains(k)), isEmpty, reason: '$id in $phase');
        expect(v.containsKey('streifzug'), imStreifzug, reason: '$id: streifzug nur in den Runden ($phase)');
        expect(v['rundgang'] is Map, imRundgang, reason: '$id: rundgang nur in Einleitung und Ende ($phase)');
        expect(_map(v['privat']).containsKey('rundgangText'), imRundgang && id == 'p1', reason: '$id: Vorlesetext nur beim Erzähler');
        expect(_map(v['privat']).containsKey('streifzug'), imStreifzug && id == 'p0', reason: '$id: Treffpunkte nur beim Detektiv');
      }
      if (imRundgang) {
        // Während Vorspiel und Morgen gibt es keinen Streifzug.
        expect(() => _befehl(lang, 'p0', 'erkunde', {'ort': orte.first}), throwsA(_fehler('invalid_phase')));
        if (phase == 'ende') expect(lang.beendet, isFalse, reason: 'Der Morgen hält den Raum offen');
      }
      if (!imStreifzug) return;
      // Je Runde fünf Orte, drei in den Gesprächen, zwei in den Entscheidungen.
      final plan = orte.sublist((runde - 1) * 5, runde * 5);
      for (final ort in phase == 'gespraeche' ? plan.take(3) : plan.skip(3)) {
        if (erledigt.add(ort)) _befehl(lang, 'p0', 'erkunde', {'ort': ort});
      }
      if (phase == 'gespraeche') {
        final treffpunkte = _map(_map(_map(s['privat'])['streifzug'])['treffpunkte']);
        for (final b in treffpunkte.keys) {
          if ((getroffen[runde] ??= {}).add(b)) _befehl(lang, 'p0', 'treffen', {'befragung': b});
        }
        expect(() => _befehl(lang, 'p0', 'rundgang', {'station': 0}), throwsA(_fehler('not_host')));
        expect(() => _befehl(lang, 'p1', 'rundgang', {'station': 0}), throwsA(_fehler('invalid_phase')));
      }
      erkundet = _map(lang.zustandFuer('p2')['streifzug'])['erkundet'] as List;
    });
    expect(lang.beendet, isTrue);

    // Dieselbe Folge wie kurz, mit dem Vorspiel vor der Diashow und dem Morgen vor dem Schluss.
    final soll = [
      for (final a in folgeKurz) ...[
        if (a == 'intro') 'vorspiel',
        if (a == 'ende') 'morgen',
        a,
      ],
    ];
    expect(folgeLang, soll);
    expect(folgeLang.where((a) => a == 'gespraeche'), hasLength(3));
    expect(erkundet, orte, reason: 'alle fünfzehn Orte, in der Reihenfolge der Runden');
    expect([for (var r = 1; r <= 3; r++) getroffen[r]], everyElement(isNotEmpty));
    expect(_wertung(lang.zustandFuer('p0')), _wertung(kurz.zustandFuer('p0')), reason: 'Streifzug und Rundgang ändern nichts am Abend');
  });
}
