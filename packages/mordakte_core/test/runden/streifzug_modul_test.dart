// M7b Streifzug online: Das Streifzug-Modul nimmt `erkunde` und `treffen` nur
// vom Gerät, das ermittelt, nur im langen Abend und nur in Gesprächen und
// Entscheidungen. Öffentlich steht nur, wo der Detektiv war, was er erkundet
// hat und wen er wo trifft; nie Pfad, Salz oder Wertung. Treffpunkte und
// Fassungen zieht der Raum aus dem Samen der Welt (gleich wie am Gastgebergerät).
import 'dart:convert';

import 'package:mordakte_core/mordakte_core.dart';
import 'package:mordakte_core/runden.dart';
import 'package:test/test.dart';

import '../party/kanon_hilfe.dart';
import 'befragung_treiber.dart';

final _texte = Texte(kanon, Textsammlung.lade((p) => leseJson('$repoWurzel/content/party/schlosskeller/$p')));
final _erm = Ermittlung(kanon);
final _erkundung = Erkundung.ausJson(leseJson('$repoWurzel/content/welt/schlosskeller/erkundung.json'));
const _salz = 'pruefung-raumsalz-unabhaengig-vom-pfad';

SchlosskellerRaum _raum({Abendfassung fassung = Abendfassung.lang, Erkundung? erkundung, String pfad = 'ahmet'}) => SchlosskellerRaum(
      raumCode: 'ABCD', kanon: kanon, texte: _texte, fassung: fassung, erkundung: erkundung ?? _erkundung,
      fallCode: FallCode.fuerPfad(pfad, kanon.pfade), salz: _salz,
    );

Map<String, Object?> _map(Object? v) => (v as Map).cast<String, Object?>();
List<Map<String, Object?>> _liste(Object? v) => [for (final x in v as List) _map(x)];
Matcher _fehler(String code) => isA<PartyRaumFehler>().having((e) => e.code, 'code', code);

void _befehl(AbendRaum r, String id, String typ, [Map<String, Object?> d = const {}]) => r.nachricht(id, mitAbendzeit({'typ': typ, ...d}, 1000));

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

void _schritt(AbendRaum r, String pfad, {String leiter = 'p0'}) {
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
        _befehl(r, 'p0', 'wahl', {'option': _erm.entscheidung(e['id'] as String).richtig[pfad]!});
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
      _befehl(r, 'p0', 'anklage', {'person': pfad});
    default:
      _befehl(r, leiter, 'weiter');
  }
}

void _bis(AbendRaum r, String phase, {int runde = 1, String pfad = 'ahmet', String leiter = 'p0'}) {
  for (var i = 0; i < 400; i++) {
    final s = r.zustandFuer('p0');
    if (s['phase'] == phase && s['runde'] == runde) return;
    _schritt(r, pfad, leiter: leiter);
  }
  fail('$phase in Runde $runde nicht erreicht');
}

Map<String, Object?> _streifzug(AbendRaum r, [String id = 'p2']) => _map(r.zustandFuer(id)['streifzug']);

/// Befragungen der laufenden Runde aus der Ansicht des Detektivs.
List<Map<String, Object?>> _befragungen(AbendRaum r) => _liste(_map(r.zustandFuer('p0')['privat'])['befragungen']);

void main() {
  test('Kurz gibt es keinen Streifzug: Nachrichten ungültig, kein Schlüssel; ohne Erkundung auch lang nicht', () {
    for (final r in [_raum(fassung: Abendfassung.kurz), SchlosskellerRaum(
      raumCode: 'ABCD', kanon: kanon, texte: _texte, fassung: Abendfassung.lang,
      fallCode: FallCode.fuerPfad('ahmet', kanon.pfade), salz: _salz,
    )]) {
      _start(r);
      _bis(r, 'gespraeche');
      expect(() => _befehl(r, 'p0', 'erkunde', {'ort': 'ek_brunnen'}), throwsA(_fehler('invalid')));
      expect(() => _befehl(r, 'p0', 'treffen', {'befragung': _befragungen(r).first['id']}), throwsA(_fehler('invalid')));
      expect(r.zustandFuer('p2').containsKey('streifzug'), isFalse);
      expect(_map(r.zustandFuer('p0')['privat']).containsKey('streifzug'), isFalse);
    }
  });

  test('Rechte und Phasen: nur der Detektiv-Sitz, nur in Gesprächen und Entscheidungen, Treffen nur in den Gesprächen', () {
    final r = _raum();
    _start(r, erzaehler: true);
    expect(() => _befehl(r, 'p0', 'erkunde', {'ort': 'ek_brunnen'}), throwsA(_fehler('invalid_phase')), reason: 'Rollen');
    expect(r.zustandFuer('p2').containsKey('streifzug'), isFalse);
    _bis(r, 'gespraeche', leiter: 'p1');
    for (final id in ['p1', 'p2', 'p3']) {
      expect(() => _befehl(r, id, 'erkunde', {'ort': 'ek_brunnen'}), throwsA(_fehler('not_detective')), reason: id);
    }
    expect(() => _befehl(r, 'p0', 'erkunde', {'ort': 'gibt_es_nicht'}), throwsA(_fehler('invalid')));
    expect(() => _befehl(r, 'p0', 'erkunde', {'ort': 'ek_brunnen', 'extra': 1}), throwsA(_fehler('invalid')));
    expect(() => _befehl(r, 'p0', 'treffen', {'befragung': 'bf_ahmet_3'}), throwsA(_fehler('invalid')), reason: 'nicht diese Runde');
    _befehl(r, 'p0', 'erkunde', {'ort': 'ek_brunnen'});
    _befehl(r, 'p0', 'erkunde', {'ort': 'ek_brunnen'});
    expect(_streifzug(r)['erkundet'], ['ek_brunnen'], reason: 'jeder Ort einmal');
    expect([_streifzug(r)['ebene'], _streifzug(r)['ort']], ['erdgeschoss', 'ek_brunnen']);
    _bis(r, 'entscheidungen', leiter: 'p1');
    expect(() => _befehl(r, 'p0', 'treffen', {'befragung': 'bf_ahmet_1'}), throwsA(_fehler('invalid_phase')));
    _befehl(r, 'p0', 'erkunde', {'ort': 'ek_herd'});
    expect(_streifzug(r)['erkundet'], ['ek_brunnen', 'ek_herd']);
    _bis(r, 'gruppenwahl', leiter: 'p1');
    expect(() => _befehl(r, 'p0', 'erkunde', {'ort': 'ek_baum'}), throwsA(_fehler('invalid_phase')));
    expect(r.zustandFuer('p2').containsKey('streifzug'), isFalse);
    _bis(r, 'gespraeche', runde: 2, leiter: 'p1');
    expect(_streifzug(r)['erkundet'], ['ek_brunnen', 'ek_herd'], reason: 'über den Abend');
    expect(_streifzug(r)['ebene'], kellerEbene, reason: 'Jede Runde beginnt im Keller');
  });

  test('Treffen: Treffpunkt aus dem Samen der Welt wie am Gastgebergerät, öffentlich nur Figur und Ort', () {
    final r = _raum();
    _start(r);
    _bis(r, 'gespraeche');
    final ids = [for (final b in _befragungen(r)) b['id'] as String];
    final soll = _erkundung.treffpunkteFuer(weltSamenAus(_salz), ids);
    final privat = _map(_map(r.zustandFuer('p0')['privat'])['streifzug']);
    expect(privat['treffpunkte'], {for (final e in soll.entries) e.key: e.value.id});
    expect(privat['varianten'], {for (final o in _erkundung.orte) if (o.varianten.isNotEmpty) o.id: o.fassungFuer(weltSamenAus(_salz))});
    for (final id in ['p1', 'p2', 'p3']) {
      expect(_map(r.zustandFuer(id)['privat']).containsKey('streifzug'), isFalse, reason: '$id bekommt keine Treffpunkte aller');
    }
    final b = _befragungen(r).first;
    _befehl(r, 'p0', 'treffen', {'befragung': b['id']});
    final t = soll[b['id']]!;
    for (final id in ['p0', 'p1', 'p2', 'p3']) {
      expect(_streifzug(r, id)['treffpunkt'], {'figur': b['rolle'], 'ort': t.id, 'anzeige': t.anzeige}, reason: id);
    }
    expect([_streifzug(r)['ebene'], _streifzug(r)['ort']], [t.ebene, t.id]);
    // Wer getroffen wird, sieht es an seiner Figur.
    final getroffen = [for (final s in _liste(r.zustandFuer('p0')['spieler'])) if (s['rolle'] == b['rolle']) s['id']];
    for (final id in getroffen) {
      expect(_map(_streifzug(r, id as String)['treffpunkt'])['figur'], _map(r.zustandFuer(id)['privat'])['rolle']);
    }
    _befehl(r, 'p0', 'erkunde', {'ort': 'ek_beet'});
    expect(_streifzug(r).containsKey('treffpunkt'), isFalse, reason: 'Wer weitergeht, trifft niemanden mehr');
    _befehl(r, 'p0', 'treffen', {'befragung': b['id']});
    _bis(r, 'entscheidungen');
    expect(_streifzug(r).containsKey('treffpunkt'), isFalse, reason: 'In den Entscheidungen trifft der Detektiv niemanden');
  });

  test('Ansicht ohne Lecks: nur freigegebene Schlüssel, im Streifzug weder Pfad noch Salz noch Wertung', () {
    for (final pfad in kanon.pfade) {
      final r = _raum(pfad: pfad);
      _start(r);
      var schritte = 0;
      while (r.zustandFuer('p0')['phase'] != 'finale') {
        expect(++schritte, lessThan(400));
        final s = r.zustandFuer('p0');
        if (s['phase'] == 'gespraeche' || s['phase'] == 'entscheidungen') {
          _befehl(r, 'p0', 'erkunde', {'ort': _erkundung.orte[schritte % _erkundung.orte.length].id});
          if (s['phase'] == 'gespraeche') _befehl(r, 'p0', 'treffen', {'befragung': _befragungen(r).first['id']});
          for (final id in ['p0', 'p1', 'p2', 'p3']) {
            final v = r.zustandFuer(id);
            expect(v.keys.every(raumOeffentlicheSchluessel.contains), isTrue, reason: '${v.keys.where((k) => !raumOeffentlicheSchluessel.contains(k))}');
            final text = jsonEncode(v['streifzug']);
            expect(_map(v['streifzug']).keys.toSet().difference({'ebene', 'ort', 'erkundet', 'treffpunkt'}), isEmpty);
            for (final verboten in [_salz, '"pfad"', '"salz"', '"qualitaet"', 'tatwissen', 'verbirgt', 'taeter']) {
              expect(text.contains(verboten), isFalse, reason: '$id: $verboten');
            }
            final privat = _map(v['privat'])['streifzug'];
            if (privat != null) {
              expect(id, 'p0', reason: 'privat nur beim Detektiv');
              expect(_map(privat).keys.toSet(), {'treffpunkte', 'varianten'});
            }
          }
        }
        _schritt(r, pfad);
      }
    }
  });

  test('Lang mit Streifzug und kurz spielen denselben Abend: Würfe, Nachtminuten, Funde und Auflösung gleich', () {
    final kurz = _raum(fassung: Abendfassung.kurz), lang = _raum();
    _start(kurz);
    _start(lang);
    var schritte = 0;
    while (kurz.zustandFuer('p0')['phase'] != 'ende') {
      expect(++schritte, lessThan(400));
      final s = lang.zustandFuer('p0');
      if (s['phase'] == 'gespraeche' || s['phase'] == 'entscheidungen') {
        // Erkundet und getroffen wird nur im langen Abend; der Fall merkt nichts davon.
        _befehl(lang, 'p0', 'erkunde', {'ort': _erkundung.orte[schritte % _erkundung.orte.length].id});
        if (s['phase'] == 'gespraeche') _befehl(lang, 'p0', 'treffen', {'befragung': _befragungen(lang).first['id']});
      }
      for (final k in ['restMinuten', 'marken', 'wuerfe', 'notizbuch', 'gewaehlt', 'phase', 'runde']) {
        expect(jsonEncode(lang.zustandFuer('p0')[k]), jsonEncode(kurz.zustandFuer('p0')[k]), reason: '$k, Schritt $schritte');
      }
      _schritt(kurz, 'ahmet');
      _schritt(lang, 'ahmet');
    }
    expect(jsonEncode(lang.zustandFuer('p0')['aufloesung']), jsonEncode(kurz.zustandFuer('p0')['aufloesung']));
  });
}
