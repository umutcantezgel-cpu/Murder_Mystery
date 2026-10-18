// M0-Naht: Raum-Module und Rechte. Die Fehlercodes sind ein Vertrag mit den
// Netz-Matrizen (server/tool) und den Gastbildschirmen; sie bleiben fest.
import 'package:mordakte_core/mordakte_core.dart';
import 'package:mordakte_core/runden.dart';
import 'package:test/test.dart';

import '../party/kanon_hilfe.dart';

final _texte = Texte(kanon, Textsammlung.lade((p) => leseJson('$repoWurzel/content/party/schlosskeller/$p')));

SchlosskellerRaum _raum({List<RaumModul> module = const []}) => SchlosskellerRaum(
  raumCode: 'ABCD', kanon: kanon, texte: _texte,
  fallCode: FallCode.fuerPfad('ahmet', kanon.pfade), salz: 'pruefung-raumsalz-unabhaengig-vom-pfad',
  module: module,
);

void _befehl(SchlosskellerRaum r, String id, String typ, [Map<String, Object?> daten = const {}]) =>
    r.nachricht(id, {'typ': typ, ...daten});

Matcher _fehler(String code) => isA<PartyRaumFehler>().having((e) => e.code, 'code', code);

void _beitreten(SchlosskellerRaum r, int n) {
  for (var i = 0; i < n; i++) {
    expect(r.beitreten('p$i', 'Person $i'), isTrue);
    _befehl(r, 'p$i', 'bereit', {'wert': true});
  }
}

/// Testmodul: zählt Pings, darf vor dem Start, schreibt nur privat.
class _Ping extends RaumModul {
  int pings = 0;
  bool weiterErlaubt = true;
  int starts = 0;
  int wechsel = 0;
  bool oeffentlichKollision = false;

  @override
  Map<String, Set<String>> get nachrichten => {'ping': {'wert'}, 'spaeter': {}};
  @override
  bool vorStart(String typ) => typ == 'ping';
  @override
  void nachricht(RaumKontext k, String id, String typ, Map<String, Object?> inhalt) {
    if (typ == 'spaeter') k.nurDetektiv(id);
    pings++;
  }
  @override
  bool darfWeiter(RaumKontext k) => weiterErlaubt;
  @override
  void beimStart(RaumKontext k) => starts++;
  @override
  void phaseGewechselt(RaumKontext k) => wechsel++;
  @override
  Map<String, Object?> oeffentlich(RaumKontext k, String id) => oeffentlichKollision ? {'phase': 'x'} : const {};
  @override
  Map<String, Object?> privat(RaumKontext k, String id) => {'pings': pings};
}

void main() {
  group('Fehlercodes sind fest', () {
    test('unbekannter Typ ist invalid, auch mit Modulen', () {
      final r = _raum(module: [_Ping()]);
      _beitreten(r, 2);
      expect(() => _befehl(r, 'p1', 'gibmirdassalz'), throwsA(_fehler('invalid')));
    });

    test('Spielbefehl vor dem Start ist not_started', () {
      final r = _raum();
      _beitreten(r, 2);
      expect(() => _befehl(r, 'p0', 'wahl', {'option': 'x'}), throwsA(_fehler('not_started')));
      expect(() => _befehl(r, 'p0', 'weiter'), throwsA(_fehler('not_started')));
    });

    test('Gast darf weder starten noch weiterschalten (not_host)', () {
      final r = _raum();
      _beitreten(r, 4);
      expect(() => _befehl(r, 'p1', 'start', {'rollen': 4}), throwsA(_fehler('not_host')));
      _befehl(r, 'p0', 'start', {'rollen': 4});
      expect(() => _befehl(r, 'p1', 'weiter'), throwsA(_fehler('not_host')));
      expect(() => _befehl(r, 'p1', 'anklage', {'person': 'ahmet'}), throwsA(_fehler('not_host')));
    });
  });

  group('Raum-Module', () {
    test('Nachricht vor dem Start nur, wenn das Modul sie erlaubt', () {
      final m = _Ping();
      final r = _raum(module: [m]);
      _beitreten(r, 4);
      _befehl(r, 'p1', 'ping', {'wert': 1});
      expect(m.pings, 1);
      expect(() => _befehl(r, 'p1', 'spaeter'), throwsA(_fehler('not_started')));
      expect(() => _befehl(r, 'p1', 'ping', {'fremd': 1}), throwsA(_fehler('invalid')));
    });

    test('Rechte über den Kontext: nur der Detektiv', () {
      final m = _Ping();
      final r = _raum(module: [m]);
      _beitreten(r, 4);
      _befehl(r, 'p0', 'start', {'rollen': 4});
      expect(m.starts, 1);
      expect(() => _befehl(r, 'p1', 'spaeter'), throwsA(_fehler('not_detective')));
      _befehl(r, 'p0', 'spaeter');
      expect(m.pings, 1);
    });

    test('Module hängen privat an und können Weiter sperren', () {
      final m = _Ping();
      final r = _raum(module: [m]);
      _beitreten(r, 4);
      _befehl(r, 'p0', 'start', {'rollen': 4});
      expect((r.zustandFuer('p1')['privat'] as Map)['pings'], 0);
      for (final t in ['p1', 'p2', 'p3']) {
        _befehl(r, t, 'rollenGelesen');
      }
      m.weiterErlaubt = false;
      expect(r.zustandFuer('p0')['kannWeiter'], isFalse);
      expect(() => _befehl(r, 'p0', 'weiter'), throwsA(_fehler('not_ready')));
      m.weiterErlaubt = true;
      _befehl(r, 'p0', 'weiter');
      expect(m.wechsel, 1);
    });

    test('Module überschreiben nie bestehende Schlüssel', () {
      final m = _Ping()..oeffentlichKollision = true;
      final r = _raum(module: [m]);
      _beitreten(r, 2);
      expect(() => r.zustandFuer('p0'), throwsStateError);
    });
  });

  test('Ansicht nutzt nur freigegebene Schlüssel', () {
    final r = _raum();
    _beitreten(r, 4);
    _befehl(r, 'p0', 'start', {'rollen': 4});
    for (final id in ['p0', 'p1']) {
      expect(r.zustandFuer(id).keys.where((k) => !raumOeffentlicheSchluessel.contains(k)), isEmpty);
    }
  });
}
