// Die Zuschauerkarte des Erzählers (online, M6.4): Von der Klasse des
// Detektiv-Sitzes wirkt dort nur das Tempo, damit der Weg im Gleichlauf läuft.
// Leuchten, Türen, Marken und Gerüchte sieht nur der Detektiv.
import 'package:flutter_test/flutter_test.dart';
import 'package:mordakte/party/klasse_wirkung.dart';

import 'klasse_hilfe.dart';

void main() {
  test('Zuschauer: nur das Tempo der Klasse, sonst die Karte wie ohne Klasse', () {
    final s = klassenSitzung(n: 4, pfad: 'ahmet');
    expect(KlasseWirkung.zuschauer(null), isNull);
    for (final klasse in ['forensic', 'profiler', 'excop', 'journalist', 'medic']) {
      final w = KlasseWirkung.fuer(s, klasse)!;
      final z = KlasseWirkung.zuschauer(w)!;
      expect([z.tempoFaktor, z.glanzRadius, z.tuerenZeigen, z.stimmungZeigen], [w.tempoFaktor, 0, false, false], reason: klasse);
      for (final npc in s.daten.kanonKennung.keys) {
        expect([z.geruechtFuer(npc), z.gespraechsMarker(npc)], [null, false], reason: '$klasse/$npc');
      }
    }
    // Gegenprobe: Die volle Wirkung zeigt dem Detektiv, was der Zuschauer nicht sieht.
    expect(KlasseWirkung.fuer(s, 'forensic')!.glanzRadius, greaterThan(0));
    expect(KlasseWirkung.fuer(s, 'excop')!.tuerenZeigen, isTrue);
    expect(KlasseWirkung.fuer(s, 'medic')!.tempoFaktor, greaterThan(1));
  });
}
