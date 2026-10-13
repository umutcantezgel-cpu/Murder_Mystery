import 'dart:math' as math;

import 'package:mordakte_klang/mordakte_klang.dart';
import 'package:test/test.dart';

void main() {
  test('Jeder Klang ist kurz, laut genug und übersteuert nicht', () {
    for (final e in klangKatalog.entries) {
      final p = e.value();
      final spitze = p.fold<double>(0, (m, v) => math.max(m, v.abs()));
      expect(p.length, greaterThan(0), reason: e.key);
      expect(p.length / klangRate, lessThan(4), reason: e.key);
      expect(spitze, inInclusiveRange(0.3, 0.95), reason: e.key);
      expect(p.first.abs(), lessThan(0.02), reason: '${e.key} beginnt ohne Knacken');
      expect(p.last.abs(), lessThan(0.02), reason: '${e.key} endet ohne Knacken');
    }
  });

  test('Atmosphären sind nahtlose Schleifen von acht Sekunden', () {
    for (final e in atmosphaerenKatalog.entries) {
      final p = e.value();
      expect(p.length, 8 * klangRate, reason: e.key);
      // Der Sprung vom Ende zum Anfang ist nicht größer als der größte darin.
      var groesster = 0.0;
      for (var i = 1; i < p.length; i++) {
        groesster = math.max(groesster, (p[i] - p[i - 1]).abs());
      }
      expect((p.first - p.last).abs(), lessThanOrEqualTo(groesster * 1.01), reason: e.key);
    }
  });

  test('Gleiche Formel, gleicher Klang (deterministisch)', () {
    expect(knopf(), knopf());
    expect(atmoRegen().sublist(0, 2000), atmoRegen().sublist(0, 2000));
  });

  test('WAV-Kopf stimmt', () {
    final w = wavMono16(knopf(), klangRate);
    expect(String.fromCharCodes(w.sublist(0, 4)), 'RIFF');
    expect(String.fromCharCodes(w.sublist(8, 12)), 'WAVE');
    expect(w.length, 44 + knopf().length * 2);
  });
}
