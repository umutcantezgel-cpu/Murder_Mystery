// M3: Sitze am Online-Abend. Der Sitzplan ist rein (Sitze, Rollenzahl,
// Zuteilung als Permutation, Wünsche, Verteilung beim Start).
import 'package:mordakte_core/mordakte_core.dart';
import 'package:mordakte_core/runden.dart';
import 'package:test/test.dart';

import '../party/kanon_hilfe.dart';

final _texte = Texte(kanon, Textsammlung.lade((p) => leseJson('$repoWurzel/content/party/schlosskeller/$p')));

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
}
