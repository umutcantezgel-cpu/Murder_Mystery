import 'package:mordakte_core/mordakte_core.dart';
import 'package:mordakte_core/runden.dart';
import 'package:test/test.dart';

void main() {
  test('Bot-Strom benutzt Salz, eigene Rolle und Runde, nicht den Fall-Code', () {
    for (final rolle in ['ahmet', 'fatma', 'olli', 'can']) {
      for (var runde = 1; runde <= 3; runde++) {
        final soll = Rng(Rng.hashString('bot:probe:$rolle:$runde')).chance(0.7);
        for (var i = 0; i < 10; i++) {
          expect(botKooperativ(salz: 'probe', rolle: rolle, runde: runde), soll);
        }
      }
    }
  });

  test('Kooperation liegt bei 70 Prozent, beide Wahlen bleiben möglich', () {
    for (final rolle in ['ahmet', 'fatma', 'olli', 'can']) {
      var a = 0;
      for (var i = 0; i < 10000; i++) {
        if (botKooperativ(salz: 'probe-$i', rolle: rolle, runde: 1)) a++;
      }
      expect(a / 10000, inInclusiveRange(0.68, 0.72), reason: rolle);
    }
  });

  test('Beliebig viele Bot-Stimmen verändern die Würfelquelle nicht', () {
    final wuerfel = SalzWuerfel('probe');
    final vorher = Wurf.werfen(wuerfel, 'e2_1', 1, 0, garantie: false).toJson();
    for (var i = 0; i < 1000; i++) {
      botKooperativ(salz: 'probe', rolle: 'rolle-$i', runde: i % 3 + 1);
    }
    expect(Wurf.werfen(wuerfel, 'e2_1', 1, 0, garantie: false).toJson(), vorher);
  });

  test('Ungültige Runden und leere Bot-Eingaben werden abgewiesen', () {
    for (final runde in [0, 4]) {
      expect(() => botKooperativ(salz: 'probe', rolle: 'ahmet', runde: runde), throwsArgumentError);
    }
    expect(() => botKooperativ(salz: '', rolle: 'ahmet', runde: 1), throwsArgumentError);
    expect(() => botKooperativ(salz: 'probe', rolle: '', runde: 1), throwsArgumentError);
  });
}
