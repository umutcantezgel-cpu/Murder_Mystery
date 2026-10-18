// L3 · gleiche Würfelprotokolle auf VM, Node und Chrome, gleich der eingecheckten Liste
// der geltenden Kern-Version (Kern 1.2, E-043: Stand des Kanons vor dem Öffnen für den langen
// Abend; die eingebettete Kopie war älter. Die Listen zu Kern 1.0 und 1.1 bleiben unverändert liegen).
import 'package:test/test.dart';

import 'determinismus_lauf.dart';
import 'determinismus_soll_k12.g.dart';

void main() {
  test('1.000 Codes: Protokoll-Summen gleich der Soll-Liste (WÜ-6)', () {
    final ist = determinismusListe(determinismusSoll.length);
    expect(ist.length, 1000);
    for (var i = 0; i < ist.length; i++) {
      expect(ist[i], determinismusSoll[i], reason: 'Code $i');
    }
  });
}
