// Vorübergehende Messung (Gruppe A), wird wieder gelöscht.
import 'package:mordakte_core/party_druck.dart';
import 'package:test/test.dart';

import 'kammer_druck_hilfe.dart';
import 'teil_11_test.dart' show laengen, groessteAbweichung, teile;

void main() {
  for (final personen in [6, 7, 8, 9, 10, 20]) {
    test('RN7 $personen', () async {
      final k = kammerKontext(personen);
      final pdf = kammerPdf((await kammerTeilDatei(k, kammerTeil(k, '11'))).bytes);
      final l = [for (var f = 0; f < 4; f++) laengen(k, pdf, f)];
      final out = StringBuffer('P$personen\n');
      for (final t in teile) {
        final a = groessteAbweichung([for (final x in l) x[t]!]);
        out.writeln('  $t: ${[for (final x in l) x[t]]}  max ${(100 * a.abweichung).toStringAsFixed(1)} % (f${a.fassung})');
      }
      print(out);
    });
  }
}
