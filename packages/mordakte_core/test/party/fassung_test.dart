// M7b: Fassung kurz/lang und Zeitbudget nach K-18. Die Schätzung steht im
// Setup und auf der Startübersicht als „ca. X Min.“; jede lange liegt über
// jeder kurzen (PLAN.md, Leitregel Zeitbudget).
import 'package:mordakte_core/mordakte_core.dart';
import 'package:mordakte_core/runden.dart' as runden;
import 'package:test/test.dart';

void main() {
  test('Minutenoptionen und Vorgaben je Fassung', () {
    expect(Abendfassung.kurz.minutenOptionen, [10, 15, 20]);
    expect(Abendfassung.lang.minutenOptionen, [20, 25, 30, 40]);
    expect(Abendfassung.kurz.standardMinuten, 15);
    expect(Abendfassung.lang.standardMinuten, 20);
    for (final f in Abendfassung.values) {
      expect(f.minutenOptionen, contains(f.standardMinuten));
    }
  });

  test('Schätzung nach K-18: kurz 55,2 + 3·m, lang 59 + 3·m', () {
    for (final m in [10, 15, 20, 25, 30, 40]) {
      expect(abendMinutenGenau(Abendfassung.kurz, m), closeTo(55.2 + 3 * m, 1e-9));
      expect(abendMinutenGenau(Abendfassung.lang, m), closeTo(59 + 3 * m, 1e-9));
    }
  });

  test('Anzeige auf fünf Minuten gerundet: kurz 85/100/115, lang 120/135/150/180', () {
    expect([for (final m in Abendfassung.kurz.minutenOptionen) abendMinutenCa(Abendfassung.kurz, m)], [85, 100, 115]);
    expect([for (final m in Abendfassung.lang.minutenOptionen) abendMinutenCa(Abendfassung.lang, m)], [120, 135, 150, 180]);
    // Vorgaben: kurz ≈ 100 (PLAN: ≈ 85–100), lang ≈ 120.
    expect(abendMinutenCa(Abendfassung.kurz, Abendfassung.kurz.standardMinuten), 100);
    expect(abendMinutenCa(Abendfassung.lang, Abendfassung.lang.standardMinuten), 120);
  });

  test('jede lange Schätzung liegt über jeder kurzen (genau und gerundet)', () {
    final kurz = Abendfassung.kurz.minutenOptionen;
    final lang = Abendfassung.lang.minutenOptionen;
    for (final k in kurz) {
      for (final l in lang) {
        expect(abendMinutenGenau(Abendfassung.lang, l), greaterThan(abendMinutenGenau(Abendfassung.kurz, k)), reason: 'lang $l gegen kurz $k');
        expect(abendMinutenCa(Abendfassung.lang, l), greaterThan(abendMinutenCa(Abendfassung.kurz, k)), reason: 'lang $l gegen kurz $k');
      }
    }
  });

  test('Lesen und Schreiben: nur „lang“ ist lang, alles andere kurz', () {
    for (final f in Abendfassung.values) {
      expect(Abendfassung.lesen(f.name), f);
    }
    expect(Abendfassung.lang.name, 'lang');
    expect(Abendfassung.kurz.name, 'kurz');
    for (final x in [null, '', 'LANG', 'lang ', 1, true, 'mittel', const <String>[]]) {
      expect(Abendfassung.lesen(x), Abendfassung.kurz, reason: '$x');
    }
    expect(Abendfassung.lang.istLang, isTrue);
    expect(Abendfassung.kurz.istLang, isFalse);
  });

  test('auch über das Runden-Barrel erreichbar', () {
    expect(runden.Abendfassung.lesen('lang'), Abendfassung.lang);
  });
}
