// Determinismus der Einfluss-Schicht (Finale §4): 1.000 Codes, je Abend eine FNV-Summe über jeden Schritt und
// den Endstand (einfluss_lauf.dart), gleich der eingecheckten Liste einfluss_soll.g.dart. Die Liste schreibt
// tool/bollwerk/einfluss_soll.dart einmal; sie wird nie neu geschrieben, um ein Tor grün zu machen.
@TestOn('vm')
library;

import 'package:test/test.dart';

import 'einfluss_lauf.dart';
import 'einfluss_soll.g.dart';

void main() {
  test('1.000 Codes: Summen gleich der Soll-Liste', () {
    final ist = einflussDeterminismusListe(einflussSoll.length);
    expect(ist, hasLength(1000));
    for (var i = 0; i < ist.length; i++) {
      expect(ist[i], einflussSoll[i], reason: 'Code $i');
    }
  });

  test('Zweimal gerechnet, dieselben Summen; verschiedene Codes, verschiedene Abende', () {
    final a = einflussDeterminismusListe(60);
    expect(einflussDeterminismusListe(60), a);
    expect(a.toSet(), hasLength(60));
  });
}
