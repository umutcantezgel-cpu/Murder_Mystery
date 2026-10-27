// T-N · Neutral = alt (Finale §0.1, §0.3, §4): Ohne Einfluss-Schicht spielen alle fünf Akten bitgleich wie
// vor ihr. Gerechnet wird dieselbe Serialisierung wie beim Schnappschuss (andere_akten_lauf.dart):
// RundenPartie- und Druckspiel-Abende sowie geskriptete Online-Abende im Raum mit jeder Geräteansicht.
// Der Vergleichsstand andere_akten_soll.g.dart entstand vor der ersten Codeänderung und wird nie neu
// geschrieben (tool/bollwerk/andere_akten_soll.dart).
@TestOn('vm')
library;

import 'package:test/test.dart';

import 'andere_akten_lauf.dart';
import 'andere_akten_soll.g.dart';

void main() {
  for (final akte in schnappAkten) {
    test('$akte ohne neue Schichten: Partie, Druckspiel und Raumansichten gleich dem Schnappschuss', () {
      final ist = andereAktenSummenFuer(akte);
      final soll = {for (final e in andereAktenSoll.entries) if (e.key.startsWith('$akte/')) e.key: e.value};
      expect(soll, isNotEmpty, reason: 'Schnappschuss ohne $akte');
      expect(ist.keys.toSet(), soll.keys.toSet(), reason: 'gleiche Teile wie im Schnappschuss');
      for (final k in soll.keys) {
        expect(ist[k], soll[k], reason: '$k weicht vom Stand vor der Einfluss-Schicht ab');
      }
    });
  }

  test('Der Schnappschuss deckt alle fünf Akten ab', () {
    expect({for (final k in andereAktenSoll.keys) k.split('/').first}, schnappAkten.toSet());
  });
}
