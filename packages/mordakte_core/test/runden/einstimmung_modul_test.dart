// A-063, SPEZIFIKATION §1: Einstimmung im Online-Raum (EinstimmungModul). Nur
// wenn eingeschaltet. Öffentlich sehen alle denselben Schritt ohne Text, den
// Vorlesetext bekommt nur der Vorleser privat, und er wandert mit der Leitung.
// Weiter und Vorspiel erst danach; die Diashow bleibt unberührt. Rechte und
// Fehlercodes sind fest (`not_host`, `stale`, `invalid`, `invalid_phase`); die
// Partie bleibt unberührt. Ein Raum ohne Einstimmung liefert dieselben Ansichten
// wie bisher, auch wenn die Akte eine Vorgeschichte hat.
import 'dart:convert';

import 'package:mordakte_core/mordakte_core.dart';
import 'package:mordakte_core/runden.dart';
import 'package:test/test.dart';

import '../party/einstimmung_hilfe.dart';
import '../party/kanon_hilfe.dart';
import 'befragung_treiber.dart';

final _texte = einstimmungTexteMit();
final _einstimmung = Einstimmung.aus(einstimmungKanon)!;
final _erm = Ermittlung(kanon);
final _inhalt = VorspielMorgen.ausJson(leseJson('$repoWurzel/content/welt/schlosskeller/vorspiel_morgen.json'));

SchlosskellerRaum _raum({
  bool mitEinstimmung = true,
  Abendfassung fassung = Abendfassung.lang,
  String pfad = 'ahmet',
  Kanon? k,
  Texte? t,
}) =>
    SchlosskellerRaum(
      raumCode: 'ABCD', kanon: k ?? einstimmungKanon, texte: t ?? _texte, diaAnzahl: 6, fassung: fassung, rundgang: _inhalt,
      einstimmung: mitEinstimmung ? _einstimmung : null,
      fallCode: FallCode.fuerPfad(pfad, kanon.pfade), salz: 'pruefung-raumsalz-unabhaengig-vom-pfad',
    );

Map<String, Object?> _map(Object? v) => (v as Map).cast<String, Object?>();
List<Map<String, Object?>> _liste(Object? v) => [for (final x in v as List) _map(x)];
Matcher _fehler(String code) => isA<PartyRaumFehler>().having((e) => e.code, 'code', code);
const _geraete = ['p0', 'p1', 'p2', 'p3'];

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

/// Ein Schritt wie am Tisch: Detektiv p0, Leiter p1 (Erzähler). Einstimmung und Rundgänge geht der Leiter ab.
void _schritt(AbendRaum r, String pfad) {
  final s = r.zustandFuer('p0');
  if (s['einstimmung'] case final Map e) {
    _befehl(r, 'p1', 'einstimmung', {'schritt': e['schritt']});
    return;
  }
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
      _befehl(r, 'p0', 'anklage', {'person': pfad});
    default:
      _befehl(r, 'p1', 'weiter');
  }
}

/// Spielt bis [erreicht] (Ansicht von p0) gilt; [jeSchritt] sieht jeden Zwischenstand.
void _bis(AbendRaum r, bool Function(Map<String, Object?>) erreicht, {String pfad = 'ahmet', void Function()? jeSchritt}) {
  for (var i = 0; i < 800; i++) {
    jeSchritt?.call();
    if (erreicht(r.zustandFuer('p0'))) return;
    _schritt(r, pfad);
  }
  fail('Zielzustand nicht erreicht');
}

/// Was den Abend bewertet, aus der Ansicht des Gastgebers (nach dem Finale).
String _wertung(Map<String, Object?> s) => jsonEncode([s['wuerfe'], s['gewaehlt'], s['restMinuten'], s['marken'], s['notizbuch'], _map(s['aufloesung'])..remove('salz')]);

void main() {
  test('Nachrichten: Schritt für Schritt, alle sehen denselben Schritt ohne Text, nur der Vorleser liest; Weiter erst danach', () {
    final r = _raum();
    _start(r);
    expect(() => _befehl(r, 'p1', 'einstimmung', {'schritt': 0}), throwsA(_fehler('invalid_phase')), reason: 'Rollenphase');
    _bis(r, (s) => s['phase'] == 'intro');
    final schritte = _einstimmung.schritte(rollen: 4, detektiv: 'm');
    expect(schritte, hasLength(7 + 7));
    for (final (i, st) in schritte.indexed) {
      final ansichten = {for (final id in _geraete) id: r.zustandFuer(id)};
      expect({for (final a in ansichten.values) jsonEncode(a['einstimmung'])}, hasLength(1), reason: 'Schritt $i für alle gleich');
      final e = _map(ansichten['p2']!['einstimmung']);
      expect(e, {
        'teil': st.teil.name, 'schritt': i, 'anzahl': schritte.length, 'nr': st.nr, 'von': st.von, 'kennung': st.kennung,
        if (st.figur != null) 'figur': st.figur,
      });
      final text = _texte.baustein(st.kennung);
      // Öffentlicher Schlüssel ohne Text; den Vorlesetext bekommt nur der Vorleser (Erzähler p1), privat.
      expect(_map(ansichten['p1']!['privat'])['einstimmungText'], text);
      for (final id in ['p0', 'p2', 'p3']) {
        expect(jsonEncode(ansichten[id]), isNot(contains(jsonEncode(text))), reason: '$id liest nicht vor');
        expect(_map(ansichten[id]!['privat']).containsKey('einstimmungText'), isFalse);
      }
      final ohnePrivat = Map.of(ansichten['p1']!)..remove('privat');
      expect(jsonEncode(ohnePrivat), isNot(contains(jsonEncode(text))));
      expect(ansichten['p1']!.keys.every(raumOeffentlicheSchluessel.contains), isTrue);
      // Weiter erst nach der Einstimmung; das Vorspiel wartet; die Diashow bleibt, wie sie ist.
      expect([ansichten['p1']!['kannWeiter'], ansichten['p1']!.containsKey('rundgang'), ansichten['p1']!['dia']], [false, false, 0]);
      expect(() => _befehl(r, 'p1', 'weiter'), throwsA(_fehler('not_ready')));
      expect(() => _befehl(r, 'p1', 'rundgang', {'station': 0}), throwsA(_fehler('invalid_phase')));
      // Rechte und Fehlercodes.
      expect(() => _befehl(r, 'p2', 'einstimmung', {'schritt': i}), throwsA(_fehler('not_host')));
      expect(() => _befehl(r, 'p0', 'einstimmung', {'schritt': i}), throwsA(_fehler('not_host')), reason: 'Der Detektiv leitet nicht, solange der Erzähler da ist');
      expect(() => _befehl(r, 'p1', 'einstimmung', {'schritt': i + 1}), throwsA(_fehler('stale')));
      expect(() => _befehl(r, 'p1', 'einstimmung', {'schritt': i - 1}), throwsA(_fehler('stale')));
      expect(() => _befehl(r, 'p1', 'einstimmung', {'schritt': '$i'}), throwsA(_fehler('invalid')));
      expect(() => _befehl(r, 'p1', 'einstimmung', <String, Object?>{}), throwsA(_fehler('invalid')));
      expect(() => _befehl(r, 'p1', 'einstimmung', {'schritt': i, 'ueberspringen': true}), throwsA(_fehler('invalid')));
      expect(() => _befehl(r, 'p1', 'einstimmung', {'ueberspringen': false}), throwsA(_fehler('invalid')));
      expect(() => _befehl(r, 'p1', 'einstimmung', {'schritt': i, 'text': 'x'}), throwsA(_fehler('invalid')));
      _befehl(r, 'p1', 'einstimmung', {'schritt': i});
    }
    // Danach: das Vorspiel (langer Abend), die Einstimmung ist vorbei.
    final s = r.zustandFuer('p1');
    expect([s['phase'], s.containsKey('einstimmung'), _map(s['privat']).containsKey('einstimmungText')], ['intro', false, false]);
    expect(_map(s['rundgang'])['teil'], 'vorspiel');
    expect(() => _befehl(r, 'p1', 'einstimmung', {'schritt': schritte.length}), throwsA(_fehler('invalid_phase')));
    expect(r.partieFuerGastgeber!.spiel.bausteine.where((b) => b.startsWith('vorgeschichte.') || b.startsWith('vorstellung.')), isEmpty);
  });

  test('Überspringen: erst der Rest der Vorgeschichte, dann der Rest der Vorstellung', () {
    final r = _raum(fassung: Abendfassung.kurz);
    _start(r);
    _bis(r, (s) => s['phase'] == 'intro');
    _befehl(r, 'p1', 'einstimmung', {'schritt': 0});
    _befehl(r, 'p1', 'einstimmung', {'ueberspringen': true});
    expect(_map(r.zustandFuer('p2')['einstimmung']), containsPair('kennung', 'vorstellung.start'));
    expect(_map(r.zustandFuer('p2')['einstimmung']), containsPair('schritt', 7));
    _befehl(r, 'p1', 'einstimmung', {'ueberspringen': true});
    final s = r.zustandFuer('p1');
    // Kurzer Abend: kein Vorspiel, gleich weiter in die Diashow und die Runden.
    expect([s.containsKey('einstimmung'), s.containsKey('rundgang'), s['kannWeiter'], s['dia']], [false, false, true, 0]);
    _befehl(r, 'p1', 'weiter');
    expect(r.zustandFuer('p0')['phase'], 'gespraeche');
    expect(() => _befehl(r, 'p1', 'einstimmung', {'ueberspringen': true}), throwsA(_fehler('invalid_phase')));
  });

  test('Der Vorlesetext wandert mit: Fällt der Erzähler aus, liest und leitet der Detektiv', () {
    final r = _raum();
    _start(r);
    _bis(r, (s) => s['phase'] == 'intro');
    _befehl(r, 'p1', 'einstimmung', {'schritt': 0});
    r.verbunden('p1', false);
    final kennung = _einstimmung.schritte(rollen: 4, detektiv: 'm')[1].kennung;
    expect(_map(r.zustandFuer('p0')['privat'])['einstimmungText'], _texte.baustein(kennung));
    _befehl(r, 'p0', 'einstimmung', {'schritt': 1});
    expect(_map(r.zustandFuer('p0')['einstimmung'])['schritt'], 2);
    r.verbunden('p1', true);
    expect(_map(r.zustandFuer('p0')['privat']).containsKey('einstimmungText'), isFalse);
    expect(_map(r.zustandFuer('p1')['privat'])['einstimmungText'], isA<String>());
    expect(() => _befehl(r, 'p0', 'einstimmung', {'schritt': 2}), throwsA(_fehler('not_host')));
  });

  test('Die Diashow bleibt unberührt: dia gilt auch während der Einstimmung wie bisher', () {
    final r = _raum(fassung: Abendfassung.kurz);
    _start(r);
    _bis(r, (s) => s['phase'] == 'intro');
    expect(r.zustandFuer('p2')['dia'], 0);
    _befehl(r, 'p1', 'dia', {'nr': 2});
    expect([r.zustandFuer('p2')['dia'], r.zustandFuer('p2').containsKey('einstimmung')], [2, true]);
    expect(() => _befehl(r, 'p1', 'dia', {'nr': 6}), throwsA(_fehler('invalid')));
  });

  test('Pfadblind: Die öffentliche Spur der Einstimmung ist in allen vier Pfaden gleich', () {
    final spuren = <String>{};
    for (final p in kanon.pfade) {
      final r = _raum(pfad: p, fassung: Abendfassung.kurz);
      _start(r);
      _bis(r, (s) => s['phase'] == 'intro');
      final spur = <Object?>[];
      for (var e = r.zustandFuer('p0')['einstimmung']; e is Map; e = r.zustandFuer('p0')['einstimmung']) {
        spur.add([e, _map(r.zustandFuer('p1')['privat'])['einstimmungText']]);
        _befehl(r, 'p1', 'einstimmung', {'schritt': e['schritt']});
      }
      spuren.add(jsonEncode(spur));
    }
    expect(spuren, hasLength(1));
  });

  test('Die Einstimmung ändert nichts am Abend: gleiche Wertung mit und ohne', () {
    final mit = _raum(), ohne = _raum(mitEinstimmung: false);
    for (final r in [mit, ohne]) {
      _start(r);
      _bis(r, (s) => s['phase'] == 'ende' && !s.containsKey('rundgang'));
    }
    expect(_wertung(mit.zustandFuer('p0')), _wertung(ohne.zustandFuer('p0')));
    expect(raumOeffentlicheSchluessel, contains('einstimmung'));
  });

  test('Ohne Einstimmung liefert der Raum dieselben Ansichten wie bisher, auch mit Vorgeschichte in der Akte', () {
    final echt = Texte(kanon, Textsammlung.lade((p) => leseJson('$repoWurzel/content/party/schlosskeller/$p')));
    for (final f in Abendfassung.values) {
      final bisher = _raum(mitEinstimmung: false, fassung: f, k: kanon, t: echt);
      final akte = _raum(mitEinstimmung: false, fassung: f);
      expect([bisher.einstimmung, akte.einstimmung], [null, null]);
      final a = <String>[], b = <String>[];
      for (final (r, l) in [(bisher, a), (akte, b)]) {
        _start(r);
        _bis(r, (s) => s['phase'] == 'ende' && !s.containsKey('rundgang'), jeSchritt: () => l.add(jsonEncode([for (final id in _geraete) r.zustandFuer(id)])));
      }
      expect(b, a, reason: f.name);
      expect(a.any((x) => x.contains('"einstimmung"') || x.contains('einstimmungText')), isFalse, reason: f.name);
    }
  });
}
