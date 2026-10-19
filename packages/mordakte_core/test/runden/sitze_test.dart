// M3: Sitze am Online-Abend. Der Sitzplan ist rein (Sitze, Rollenzahl,
// Zuteilung als Permutation, Wünsche, Verteilung beim Start); die Lobby-
// Nachrichten des SitzeModuls prüfen Rechte und Eingaben mit festen Codes.
import 'package:mordakte_core/mordakte_core.dart';
import 'package:mordakte_core/runden.dart';
import 'package:test/test.dart';

import '../party/kanon_hilfe.dart';

final _texte = Texte(kanon, Textsammlung.lade((p) => leseJson('$repoWurzel/content/party/schlosskeller/$p')));

SchlosskellerRaum _raum({Sitz gastgeberSitz = Sitz.detektiv}) => SchlosskellerRaum(
      raumCode: 'ABCD', kanon: kanon, texte: _texte, gastgeberSitz: gastgeberSitz,
      fallCode: FallCode.fuerPfad('ahmet', kanon.pfade), salz: 'pruefung-raumsalz-unabhaengig-vom-pfad',
    );

Map<String, Object?> _map(Object? v) => (v as Map).cast<String, Object?>();
List<Map<String, Object?>> _liste(Object? v) => [for (final x in v as List) _map(x)];
void _befehl(AbendRaum r, String id, String typ, [Map<String, Object?> d = const {}]) => r.nachricht(id, {'typ': typ, ...d});
Matcher _fehler(String code) => isA<PartyRaumFehler>().having((e) => e.code, 'code', code);

/// Eintrag von [id] in der öffentlichen Spielerliste.
Map<String, Object?> _platz(AbendRaum r, String id) => _liste(r.zustandFuer('p0')['spieler']).firstWhere((s) => s['id'] == id);

void _beitreten(AbendRaum r, int n, {bool bereit = true}) {
  for (var i = 0; i < n; i++) {
    expect(r.beitreten('p$i', 'Person $i'), isTrue);
    if (bereit) _befehl(r, 'p$i', 'bereit', {'wert': true});
  }
}

void main() {
  final besetzt7 = _texte.besetzung.besetzt(7);

  group('Sitzplan (rein)', () {
    test('Ein Gerät hat höchstens einen Sitz; ein neuer Inhaber verdrängt den alten', () {
      final p = Sitzplan();
      expect(p.setze('a', Sitz.detektiv), {'a'});
      expect(p.setze('b', Sitz.detektiv), {'a', 'b'});
      expect([p.detektiv, p.sitzVon('a'), p.sitzVon('b')], ['b', null, Sitz.detektiv]);
      expect(p.setze('b', Sitz.erzaehler), {'b'});
      expect([p.detektiv, p.erzaehler], [null, 'b']);
      p.setze('a', Sitz.detektiv);
      expect(p.setze('c', Sitz.erzaehler), {'c', 'b'});
      expect([p.detektiv, p.erzaehler, p.sitzVon('b')], ['a', 'c', null]);
      expect(() => p.setze('a', Sitz.rolle), throwsArgumentError);
      expect(() => p.setze('a', Sitz.assistenz), throwsArgumentError);
      p.setze('c', null);
      expect(p.erzaehler, isNull);
    });

    test('Die Klasse reist mit dem Detektiv-Sitz', () {
      final p = Sitzplan()..setze('a', Sitz.detektiv, klasse: 'forensic', klasseSetzen: true);
      expect(p.klasse, 'forensic');
      p.setze('a', Sitz.detektiv);
      expect(p.klasse, 'forensic', reason: 'Ohne Angabe bleibt sie beim selben Gerät');
      p.setze('a', Sitz.detektiv, klasseSetzen: true);
      expect(p.klasse, isNull, reason: 'Ausdrücklich ohne Klasse');
      p.setze('a', Sitz.detektiv, klasse: 'medic', klasseSetzen: true);
      p.setze('b', Sitz.detektiv);
      expect(p.klasse, isNull, reason: 'Ein anderes Gerät bringt seine eigene Klasse mit');
      p.setze('b', Sitz.detektiv, klasse: 'excop', klasseSetzen: true);
      p.setze('b', Sitz.erzaehler);
      expect([p.detektiv, p.klasse], [null, null]);
      expect(() => p.setze('c', Sitz.erzaehler, klasse: 'medic', klasseSetzen: true), throwsArgumentError);
    });

    test('Zuteilung nur als Permutation über besetzt(n), mit Tausch, nie auf einen Sitz', () {
      final p = Sitzplan()..setze('d', Sitz.detektiv);
      expect(p.zuteilen('a', besetzt7[0], besetzt7), {'a'});
      expect(p.zuteilen('b', besetzt7[1], besetzt7), {'b'});
      // b will die Figur von a: Tausch.
      expect(p.zuteilen('b', besetzt7[0], besetzt7), {'b', 'a'});
      expect(p.zuteilung, {'a': besetzt7[1], 'b': besetzt7[0]});
      // c hatte keine Figur: a gibt seine ab und hat danach keine.
      expect(p.zuteilen('c', besetzt7[1], besetzt7), {'c', 'a'});
      expect(p.zuteilung, {'b': besetzt7[0], 'c': besetzt7[1]});
      expect(p.zuteilen('c', besetzt7[1], besetzt7), isEmpty, reason: 'Keine Änderung');
      expect(p.zuteilen('c', null, besetzt7), {'c'});
      expect(p.zuteilung, {'b': besetzt7[0]});
      final ausserhalb = _texte.besetzung.reihenfolge[7];
      expect(() => p.zuteilen('a', ausserhalb, besetzt7), throwsArgumentError);
      expect(() => p.zuteilen('d', besetzt7[2], besetzt7), throwsArgumentError, reason: 'Der Detektiv spielt keine Figur');
      // Wer einen Sitz bekommt, verliert seine Figur.
      p.setze('b', Sitz.erzaehler);
      expect(p.zuteilung, isEmpty);
    });

    test('Schrumpft n, fallen Zuteilungen außerhalb von besetzt(n) weg', () {
      final p = Sitzplan();
      final b12 = _texte.besetzung.besetzt(12);
      p.setzeRollen(12, b12);
      p.zuteilen('a', b12[11], b12);
      p.zuteilen('b', b12[2], b12);
      p.wuenscht('a', b12[11]);
      expect(p.setzeRollen(5, _texte.besetzung.besetzt(5)), {'a'});
      expect([p.rollen, p.zuteilung], [5, {'b': b12[2]}]);
      expect(p.wuensche, {'a': b12[11]}, reason: 'Wünsche bleiben als Hinweis');
    });

    test('Verteilung: Zuteilung zuerst, Rest gemischt in Beitrittsreihenfolge, Sitze ohne Figur', () {
      final p = Sitzplan()
        ..setze('h', Sitz.erzaehler)
        ..setze('d', Sitz.detektiv);
      final gemischt = [...besetzt7.take(4)].reversed.toList();
      expect(p.verteile(['h', 'a', 'd', 'b', 'c'], gemischt), {'a': gemischt[0], 'b': gemischt[1], 'c': gemischt[2]});
      p.zuteilen('c', gemischt[0], besetzt7);
      expect(p.verteile(['h', 'a', 'd', 'b', 'c'], gemischt), {'c': gemischt[0], 'a': gemischt[1], 'b': gemischt[2]});
      // Mehr Geräte als Figuren: Assistenz ohne Figur.
      expect(p.verteile(['h', 'a', 'd', 'b', 'c', 'e', 'f'], gemischt).keys, unorderedEquals(['c', 'a', 'b', 'e']));
    });

    test('Startklar nur mit Detektiv und Gastgeber auf einem Sitz', () {
      final p = Sitzplan();
      expect(p.startklar('h'), isFalse);
      p.setze('h', Sitz.erzaehler);
      expect(p.startklar('h'), isFalse, reason: 'Kein Detektiv');
      p.setze('d', Sitz.detektiv);
      expect(p.startklar('h'), isTrue);
      expect(p.startklar('x'), isFalse, reason: 'Der Gastgeber spielt nie eine Figur');
      p.entferne('h');
      expect(p.startklar('d'), isTrue);
    });
  });

  group('Lobby-Nachrichten', () {
    test('Gastgeber sitzt auf seinem Sitz; Sitz und Figur stehen öffentlich in der Spielerliste', () {
      final r = _raum();
      _beitreten(r, 3, bereit: false);
      expect([r.detektivGeraet, r.erzaehlerGeraet], ['p0', null]);
      expect(_platz(r, 'p0')['sitz'], 'detektiv');
      expect(_platz(r, 'p1').containsKey('sitz'), isFalse);
      expect(_map(r.zustandFuer('p0')['privat'])['detektiv'], isTrue);
      final e = _raum(gastgeberSitz: Sitz.erzaehler);
      _beitreten(e, 2, bereit: false);
      expect([e.detektivGeraet, e.erzaehlerGeraet], [null, 'p0']);
      expect(() => SchlosskellerRaum(raumCode: 'X', kanon: kanon, texte: _texte, fallCode: FallCode.fuerPfad('ahmet', kanon.pfade),
          salz: 's', gastgeberSitz: Sitz.rolle), throwsA(_fehler('invalid_setup')));
    });

    test('sitz: nur der Gastgeber; der Detektiv-Sitz setzt nur seine eigene Klasse', () {
      final r = _raum();
      _beitreten(r, 4);
      expect(() => _befehl(r, 'p1', 'sitz', {'spieler': 'p1', 'sitz': 'detektiv'}), throwsA(_fehler('not_host')));
      expect(() => _befehl(r, 'p0', 'sitz', {'spieler': 'fremd', 'sitz': 'detektiv'}), throwsA(_fehler('invalid')));
      expect(() => _befehl(r, 'p0', 'sitz', {'spieler': 'p1', 'sitz': 'rolle'}), throwsA(_fehler('invalid')));
      expect(() => _befehl(r, 'p0', 'sitz', {'spieler': 'p1', 'sitz': 'detektiv', 'klasse': 'zauberer'}), throwsA(_fehler('invalid')));
      expect(() => _befehl(r, 'p0', 'sitz', {'spieler': 'p1', 'sitz': 'erzaehler', 'klasse': 'medic'}), throwsA(_fehler('invalid')));
      _befehl(r, 'p0', 'sitz', {'spieler': 'p0', 'sitz': 'erzaehler'});
      _befehl(r, 'p0', 'sitz', {'spieler': 'p1', 'sitz': 'detektiv'});
      expect([r.detektivGeraet, r.erzaehlerGeraet, r.klasse], ['p1', 'p0', null]);
      // Wessen Sitz sich ändert, meldet sich neu bereit.
      expect([_platz(r, 'p0')['bereit'], _platz(r, 'p1')['bereit'], _platz(r, 'p2')['bereit']], [false, false, true]);
      // Die Klasse reist mit dem Sitz: der Gast-Detektiv setzt sie selbst, ein anderer Gast nicht.
      _befehl(r, 'p1', 'sitz', {'spieler': 'p1', 'sitz': 'detektiv', 'klasse': 'journalist'});
      expect(r.klasse, 'journalist');
      expect(() => _befehl(r, 'p2', 'sitz', {'spieler': 'p2', 'sitz': 'detektiv', 'klasse': 'medic'}), throwsA(_fehler('not_host')));
      expect(() => _befehl(r, 'p1', 'sitz', {'spieler': 'p1', 'sitz': 'erzaehler'}), throwsA(_fehler('not_host')));
      // Sichtbar nur für den Detektiv-Sitz und den Gastgeber.
      for (final id in ['p0', 'p1', 'p2', 'p3']) {
        expect(_map(r.zustandFuer(id)['privat'])['klasse'], id == 'p0' || id == 'p1' ? 'journalist' : isNull, reason: id);
      }
    });

    test('besetzung: n liegt im Raum; nur Gastgeber, Detektiv- und Erzähler-Sitz', () {
      final r = _raum();
      _beitreten(r, 4);
      _befehl(r, 'p0', 'sitz', {'spieler': 'p1', 'sitz': 'erzaehler'});
      expect(() => _befehl(r, 'p2', 'besetzung', {'rollen': 6}), throwsA(_fehler('not_host')));
      expect(() => _befehl(r, 'p0', 'besetzung', {'rollen': 3}), throwsA(_fehler('invalid')));
      expect(() => _befehl(r, 'p0', 'besetzung', {'rollen': 21}), throwsA(_fehler('invalid')));
      _befehl(r, 'p1', 'besetzung', {'rollen': 6});
      for (final id in ['p0', 'p2']) {
        expect(r.zustandFuer(id)['rollen'], 6, reason: 'für alle sichtbar');
      }
      _befehl(r, 'p0', 'besetzung', {'rollen': 7});
      expect(r.lobbyRollen, 7);
    });

    test('zuteilen: Gast-Erzähler und Gast-Detektiv dürfen, eine reine Rolle nicht', () {
      final r = _raum(gastgeberSitz: Sitz.erzaehler);
      _beitreten(r, 5);
      _befehl(r, 'p0', 'sitz', {'spieler': 'p1', 'sitz': 'detektiv'});
      expect(() => _befehl(r, 'p0', 'zuteilen', {'spieler': 'p2', 'rolle': besetzt7[0]}), throwsA(_fehler('invalid')), reason: 'erst n');
      _befehl(r, 'p0', 'besetzung', {'rollen': 7});
      _befehl(r, 'p1', 'zuteilen', {'spieler': 'p2', 'rolle': besetzt7[0]});
      expect(_platz(r, 'p2')['figur'], besetzt7[0]);
      expect(() => _befehl(r, 'p3', 'zuteilen', {'spieler': 'p3', 'rolle': besetzt7[1]}), throwsA(_fehler('not_host')));
      // Nie auf Detektiv- oder Erzählersitz, nie außerhalb von besetzt(n).
      expect(() => _befehl(r, 'p0', 'zuteilen', {'spieler': 'p1', 'rolle': besetzt7[1]}), throwsA(_fehler('invalid')));
      expect(() => _befehl(r, 'p0', 'zuteilen', {'spieler': 'p0', 'rolle': besetzt7[1]}), throwsA(_fehler('invalid')));
      expect(() => _befehl(r, 'p0', 'zuteilen', {'spieler': 'p3', 'rolle': _texte.besetzung.reihenfolge[7]}), throwsA(_fehler('invalid')));
      expect(() => _befehl(r, 'p0', 'zuteilen', {'spieler': 'p3', 'rolle': 'detective'}), throwsA(_fehler('invalid')));
      // Ein Gast-Erzähler teilt ebenso zu; Tausch setzt beide Betroffenen zurück.
      final g = _raum();
      _beitreten(g, 5);
      _befehl(g, 'p0', 'sitz', {'spieler': 'p4', 'sitz': 'erzaehler'});
      _befehl(g, 'p4', 'bereit', {'wert': true});
      _befehl(g, 'p4', 'besetzung', {'rollen': 7});
      _befehl(g, 'p4', 'zuteilen', {'spieler': 'p1', 'rolle': besetzt7[3]});
      _befehl(g, 'p4', 'zuteilen', {'spieler': 'p2', 'rolle': besetzt7[4]});
      for (final id in ['p1', 'p2', 'p3']) {
        _befehl(g, id, 'bereit', {'wert': true});
      }
      _befehl(g, 'p0', 'zuteilen', {'spieler': 'p2', 'rolle': besetzt7[3]});
      expect([_platz(g, 'p1')['figur'], _platz(g, 'p2')['figur']], [besetzt7[4], besetzt7[3]]);
      expect([_platz(g, 'p1')['bereit'], _platz(g, 'p2')['bereit'], _platz(g, 'p3')['bereit']], [false, false, true]);
    });

    test('wunsch: jedes Gerät, nur Figuren der Akte; öffentlich als Hinweis', () {
      final r = _raum();
      _beitreten(r, 3);
      _befehl(r, 'p2', 'wunsch', {'rolle': _texte.besetzung.reihenfolge[9]});
      expect(_platz(r, 'p2')['wunsch'], _texte.besetzung.reihenfolge[9]);
      expect(_platz(r, 'p2')['bereit'], isTrue, reason: 'Ein Wunsch ändert nichts am Platz');
      expect(() => _befehl(r, 'p1', 'wunsch', {'rolle': 'detective'}), throwsA(_fehler('invalid')));
      expect(() => _befehl(r, 'p1', 'wunsch', {'rolle': 'p2', 'spieler': 'p2'}), throwsA(_fehler('invalid')));
      _befehl(r, 'p2', 'wunsch', {'rolle': null});
      expect(_platz(r, 'p2').containsKey('wunsch'), isFalse);
    });

    test('Lobby-Nachrichten nach dem Start: game_running; Lobby-Felder verschwinden', () {
      final r = _raum();
      _beitreten(r, 3);
      _befehl(r, 'p0', 'besetzung', {'rollen': 4});
      _befehl(r, 'p0', 'zuteilen', {'spieler': 'p2', 'rolle': besetzt7[2]});
      _befehl(r, 'p2', 'bereit', {'wert': true});
      _befehl(r, 'p1', 'wunsch', {'rolle': besetzt7[1]});
      _befehl(r, 'p0', 'start', {});
      expect(r.rolleVon('p2'), besetzt7[2]);
      for (final (id, typ, d) in [
        ('p0', 'sitz', <String, Object?>{'spieler': 'p1', 'sitz': 'erzaehler'}),
        ('p0', 'besetzung', <String, Object?>{'rollen': 5}),
        ('p0', 'zuteilen', <String, Object?>{'spieler': 'p1', 'rolle': besetzt7[0]}),
        ('p1', 'wunsch', <String, Object?>{'rolle': null}),
      ]) {
        expect(() => _befehl(r, id, typ, d), throwsA(_fehler('game_running')), reason: typ);
      }
      final spieler = _liste(r.zustandFuer('p0')['spieler']);
      expect(spieler.every((s) => !s.containsKey('figur') && !s.containsKey('wunsch')), isTrue);
      expect([for (final s in spieler) s['sitz']], ['detektiv', 'rolle', 'rolle']);
      expect(spieler.every((s) => raumSpielerFelder.containsAll(s.keys)), isTrue);
    });

    test('Wer die Lobby verlässt, verliert Sitz, Figur und Wunsch; ein neuer Gastgeber setzt sich', () {
      final r = _raum();
      _beitreten(r, 3);
      _befehl(r, 'p0', 'besetzung', {'rollen': 4});
      _befehl(r, 'p0', 'zuteilen', {'spieler': 'p2', 'rolle': besetzt7[2]});
      _befehl(r, 'p2', 'wunsch', {'rolle': besetzt7[2]});
      r.verlassen('p2');
      expect(r.beitreten('p2', 'Zurück'), isTrue);
      expect(_platz(r, 'p2').keys.toSet().intersection({'figur', 'wunsch', 'sitz'}), isEmpty);
      // Server ohne festen Gastgeber: Der neue Gastgeber setzt sich auf den freien Detektiv-Sitz.
      r.verlassen('p0');
      expect([r.zustandFuer('p1')['host'], r.detektivGeraet], ['p1', 'p1']);
    });

    test('Start: ohne Detektiv oder mit Gastgeber ohne Sitz lehnt der Raum ab (seats)', () {
      final r = _raum(gastgeberSitz: Sitz.erzaehler);
      _beitreten(r, 3);
      expect(() => _befehl(r, 'p0', 'start', {'rollen': 4}), throwsA(_fehler('seats')));
      _befehl(r, 'p0', 'sitz', {'spieler': 'p1', 'sitz': 'detektiv'});
      _befehl(r, 'p0', 'sitz', {'spieler': 'p0', 'sitz': null});
      for (final id in ['p0', 'p1']) {
        _befehl(r, id, 'bereit', {'wert': true});
      }
      expect(() => _befehl(r, 'p0', 'start', {'rollen': 4}), throwsA(_fehler('seats')), reason: 'Der Gastgeber spielt keine Figur');
      _befehl(r, 'p0', 'sitz', {'spieler': 'p0', 'sitz': 'erzaehler'});
      _befehl(r, 'p0', 'bereit', {'wert': true});
      // Ohne Rollenzahl in Start und Lobby: invalid.
      expect(() => _befehl(r, 'p0', 'start', {}), throwsA(_fehler('invalid')));
      _befehl(r, 'p0', 'start', {'rollen': 4});
      expect([r.sitzVon('p0'), r.sitzVon('p1'), r.sitzVon('p2')], [Sitz.erzaehler, Sitz.detektiv, Sitz.rolle]);
      expect([r.rolleVon('p0'), r.rolleVon('p1')], [null, null]);
    });

    test('Wiederherstellung über ProtokollRaum ergibt dieselben Sitze und Rollen', () {
      final r = ProtokollRaum(_raum(gastgeberSitz: Sitz.erzaehler));
      _beitreten(r, 6, bereit: false);
      _befehl(r, 'p0', 'sitz', {'spieler': 'p3', 'sitz': 'detektiv', 'klasse': 'profiler'});
      _befehl(r, 'p3', 'besetzung', {'rollen': 7});
      _befehl(r, 'p3', 'zuteilen', {'spieler': 'p5', 'rolle': besetzt7[6]});
      _befehl(r, 'p0', 'zuteilen', {'spieler': 'p1', 'rolle': besetzt7[0]});
      _befehl(r, 'p2', 'wunsch', {'rolle': besetzt7[1]});
      for (var i = 0; i < 6; i++) {
        _befehl(r, 'p$i', 'bereit', {'wert': true});
      }
      _befehl(r, 'p0', 'start', {});
      final neu = ProtokollRaum.wiederherstellen(r.protokoll, () => _raum(gastgeberSitz: Sitz.erzaehler));
      for (var i = 0; i < 6; i++) {
        expect(neu.zustandFuer('p$i'), r.zustandFuer('p$i'), reason: 'p$i');
      }
      final innen = neu.innen as SchlosskellerRaum;
      expect([innen.rolleVon('p5'), innen.rolleVon('p1'), innen.klasse], [besetzt7[6], besetzt7[0], 'profiler']);
      expect([innen.detektivGeraet, innen.erzaehlerGeraet], ['p3', 'p0']);
      expect({for (var i = 0; i < 6; i++) ?innen.rolleVon('p$i')}, hasLength(4));
    });

    test('Start: Liegt die Rollenzahl im Raum, lehnt er eine andere ab und behält die Zuteilung', () {
      final r = _raum();
      _beitreten(r, 4);
      _befehl(r, 'p0', 'besetzung', {'rollen': 7});
      _befehl(r, 'p0', 'zuteilen', {'spieler': 'p1', 'rolle': besetzt7[6]});
      _befehl(r, 'p1', 'bereit', {'wert': true});
      // Mit 6 Rollen fiele die Figur, die alle in der Lobby gesehen haben, still weg.
      expect(() => _befehl(r, 'p0', 'start', {'rollen': 6}), throwsA(_fehler('invalid')));
      expect([r.vorStart, r.lobbyRollen, _platz(r, 'p1')['figur']], [true, 7, besetzt7[6]]);
      _befehl(r, 'p0', 'start', {'rollen': 7});
      expect([r.zustandFuer('p1')['rollen'], r.rolleVon('p1')], [7, besetzt7[6]]);
    });
  });

  group('Detektiv-Sitz neu vergeben (detektivNeu)', () {
    /// Gastgeber p0 liest vor, p1 ermittelt mit Klasse, p2 bis p21 spielen alle
    /// zwanzig Figuren, p22 sitzt ohne Figur am Tisch (Assistenz: Plätze ohne
    /// Figur gibt es erst, wenn mehr Gäste da sind als Rollen).
    const n = 23, ohneFigur = 'p22';
    final figuren = [for (var i = 2; i < n - 1; i++) 'p$i'];
    SchlosskellerRaum gestartet([AbendRaum? raum]) {
      final r = raum ?? _raum(gastgeberSitz: Sitz.erzaehler);
      _beitreten(r, n);
      _befehl(r, 'p0', 'sitz', {'spieler': 'p1', 'sitz': 'detektiv', 'klasse': 'profiler'});
      _befehl(r, 'p1', 'bereit', {'wert': true});
      _befehl(r, 'p0', 'start', {'rollen': 20});
      final innen = r is ProtokollRaum ? r.innen as SchlosskellerRaum : r as SchlosskellerRaum;
      expect([for (var i = 0; i < n; i++) innen.sitzVon('p$i')],
          [Sitz.erzaehler, Sitz.detektiv, for (final _ in figuren) Sitz.rolle, Sitz.assistenz]);
      return innen;
    }

    test('Nur der Gastgeber, nur nach dem Start und nur, wenn der Detektiv fehlt', () {
      final lobby = _raum(gastgeberSitz: Sitz.erzaehler);
      _beitreten(lobby, 3);
      expect(() => _befehl(lobby, 'p0', 'detektivNeu', {'spieler': 'p2'}), throwsA(_fehler('not_started')));
      final r = gestartet();
      expect(() => _befehl(r, 'p0', 'detektivNeu', {'spieler': ohneFigur}), throwsA(_fehler('invalid')), reason: 'Der Detektiv ist da');
      r.verbunden('p1', false);
      expect(() => _befehl(r, ohneFigur, 'detektivNeu', {'spieler': ohneFigur}), throwsA(_fehler('not_host')));
      for (final ziel in ['p1', 'p9', '']) {
        expect(() => _befehl(r, 'p0', 'detektivNeu', {'spieler': ziel}), throwsA(_fehler('invalid')), reason: ziel);
      }
      r.verbunden(ohneFigur, false);
      expect(() => _befehl(r, 'p0', 'detektivNeu', {'spieler': ohneFigur}), throwsA(_fehler('invalid')), reason: 'Ziel getrennt');
      r.verbunden(ohneFigur, true);
      expect(() => _befehl(r, 'p0', 'detektivNeu', {'spieler': ohneFigur, 'klasse': 'forensic'}), throwsA(_fehler('invalid')));
      expect(r.detektivGeraet, 'p1');
    });

    test('Wer eine Figur spielt, übernimmt nie: Der Raum lehnt jede Figur ab, auch die Täterrolle', () {
      final r = gestartet();
      final rollen = {for (final id in figuren) id: r.rolleVon(id)};
      final dossiers = {for (final id in rollen.keys) id: _map(r.zustandFuer(id)['privat'])['dossier']};
      final taeter = rollen.entries.where((e) => e.value == 'ahmet').map((e) => e.key);
      expect(taeter, hasLength(1), reason: 'Pfad Ahmet: Die Täterrolle sitzt an einem Gerät');
      r.verbunden('p1', false);
      for (final id in rollen.keys) {
        expect(() => _befehl(r, 'p0', 'detektivNeu', {'spieler': id}), throwsA(_fehler('invalid')), reason: '$id spielt ${rollen[id]}');
      }
      expect([r.detektivGeraet, r.ermittler], ['p1', 'p1']);
      r.verbunden('p1', true);
      final p1 = _map(r.zustandFuer('p1')['privat']);
      expect([p1['detektiv'], p1.containsKey('rolle'), p1.containsKey('dossier')], [true, false, false]);
      for (final id in rollen.keys) {
        expect(r.rolleVon(id), rollen[id], reason: id);
        expect(_map(r.zustandFuer(id)['privat'])['dossier'], dossiers[id], reason: 'Kein Dossier wechselt den Platz');
      }
    });

    test('Auch ein neuer Gastgeber mit Figur (Raum ohne festen Gastgeber) übernimmt nicht selbst', () {
      final r = gestartet();
      r.verbunden('p1', false);
      r.verlassen('p0');
      expect([r.zustandFuer('p2')['host'], r.sitzVon('p2')], ['p2', Sitz.rolle], reason: 'Gastgeber ist das erste verbundene Gerät');
      final figur = r.rolleVon('p2');
      expect(() => _befehl(r, 'p2', 'detektivNeu', {'spieler': 'p2'}), throwsA(_fehler('invalid')));
      expect([r.detektivGeraet, r.rolleVon('p2')], ['p1', figur]);
      _befehl(r, 'p2', 'detektivNeu', {'spieler': ohneFigur});
      expect([r.detektivGeraet, r.sitzVon('p1'), r.rolleVon('p2')], [ohneFigur, Sitz.assistenz, figur]);
    });

    test('Ein Platz ohne Figur übernimmt: Er tauscht den Platz mit dem Detektiv, die Klasse bleibt beim Sitz', () {
      final r = gestartet();
      final rollen = {for (var i = 0; i < n; i++) 'p$i': r.rolleVon('p$i')};
      for (final id in figuren) {
        _befehl(r, id, 'rollenGelesen');
      }
      r.verbunden('p1', false);
      _befehl(r, 'p0', 'detektivNeu', {'spieler': ohneFigur});
      expect([r.detektivGeraet, r.ermittler, r.sitzVon('p1'), r.sitzVon(ohneFigur)], [ohneFigur, ohneFigur, Sitz.assistenz, Sitz.detektiv]);
      expect({for (var i = 0; i < n; i++) 'p$i': r.rolleVon('p$i')}, rollen, reason: 'Keine Figur wechselt das Gerät');
      final neu = _map(r.zustandFuer(ohneFigur)['privat']);
      expect([neu['detektiv'], neu['klasse'], neu.containsKey('dossier'), neu.containsKey('rolle')], [true, 'profiler', false, false]);
      expect(_platz(r, ohneFigur)['sitz'], 'detektiv');
      // Der bisherige Detektiv kommt zurück und sitzt ohne Figur am Tisch.
      r.verbunden('p1', true);
      final alt = _map(r.zustandFuer('p1')['privat']);
      expect([alt['detektiv'], alt.containsKey('rolle'), alt.containsKey('klasse'), alt.containsKey('dossier')], [false, false, false, false]);
      expect(_platz(r, 'p1')['sitz'], 'assistenz');
      expect(() => _befehl(r, 'p1', 'weiter'), throwsA(_fehler('not_host')));
      _befehl(r, 'p0', 'weiter');
      expect(r.zustandFuer('p0')['phase'], 'intro');
    });

    test('Der Gastgeber übernimmt selbst; wer zurückkommt, sitzt auf dem Erzähler-Sitz', () {
      final r = gestartet();
      r.verlassen('p1');
      expect(r.ermittler, 'p0', reason: 'Bis dahin vertritt der Gastgeber');
      _befehl(r, 'p0', 'detektivNeu', {'spieler': 'p0'});
      expect([r.detektivGeraet, r.erzaehlerGeraet, r.vorleser], ['p0', 'p1', 'p0']);
      expect(_map(r.zustandFuer('p0')['privat'])['klasse'], 'profiler');
      expect(r.beitreten('p1', 'Person 1'), isTrue);
      expect([r.sitzVon('p1'), r.vorleser, r.rolleVon('p1')], [Sitz.erzaehler, 'p1', null]);
      expect(() => _befehl(r, 'p0', 'detektivNeu', {'spieler': ohneFigur}), throwsA(_fehler('invalid')), reason: 'Der Detektiv ist da');
    });

    test('Wiederherstellung über ProtokollRaum ergibt dieselben Sitze nach dem Wechsel', () {
      final r = ProtokollRaum(_raum(gastgeberSitz: Sitz.erzaehler));
      gestartet(r);
      r.verbunden('p1', false);
      _befehl(r, 'p0', 'detektivNeu', {'spieler': ohneFigur});
      r.verbunden('p1', true);
      final neu = ProtokollRaum.wiederherstellen(r.protokoll, () => _raum(gastgeberSitz: Sitz.erzaehler));
      for (var i = 0; i < n; i++) {
        expect(neu.zustandFuer('p$i'), r.zustandFuer('p$i'), reason: 'p$i');
      }
      expect([(neu.innen as SchlosskellerRaum).detektivGeraet, (neu.innen as SchlosskellerRaum).sitzVon('p1')], [ohneFigur, Sitz.assistenz]);
    });
  });
}
