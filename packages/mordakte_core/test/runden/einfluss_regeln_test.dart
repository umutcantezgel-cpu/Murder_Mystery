// Regeln der Einfluss-Schicht (Finale §3.2–§3.10, §3.13, §3.14): Daten, Tischwerte, Leisten, Ereignisse,
// Minuten, Auspacken, private Nachrichten, Zugtafel, Ertappt, Ende, Auszeichnungen, Text-Katalog und der
// Architekturwächter T-G (einfluss.dart kennt weder Lösung noch Fall noch Hinweisgüte).
import 'dart:io';

import 'package:mordakte_core/mordakte_core.dart';
import 'package:mordakte_core/runden.dart';
import 'package:test/test.dart';

import '../party/kanon_hilfe.dart';
import 'einfluss_hilfe.dart';

EinflussRegeln get _r => einflussRegeln;

/// Stand mit den ersten [n] Rollen der Besetzungsreihenfolge.
EinflussStand _stand(int n) => EinflussStand(_r, besetzt: _r.figuren.take(n).toList());

EinflussZug _z(String rolle, ZugArt art, [String? ziel, String? tipp]) => EinflussZug(rolle, art, ziel: ziel, tipp: tipp);

void _setze(EinflussStand s, int runde, List<EinflussZug> zuege) {
  for (final z in zuege) {
    s.setze(runde, z);
  }
}

Matcher _formatFehler(String teil) => throwsA(isA<FormatException>().having((e) => e.message, 'message', contains(teil)));

void main() {
  group('Architekturwächter T-G', () {
    final ordner = '$repoWurzel/packages/mordakte_core/lib/src/runden';
    for (final datei in ['einfluss.dart', 'einfluss_ziele.dart']) {
      test('$datei nennt weder Pfad noch Täter noch Qualität noch FallCode und nutzt kein dart:math', () {
        final quelle = File('$ordner/$datei').readAsStringSync();
        final verboten = RegExp(r'pfad|taeter|täter|qualit', caseSensitive: false);
        expect([for (final m in verboten.allMatches(quelle)) m[0]], isEmpty);
        expect(quelle.contains('FallCode'), isFalse);
        expect(quelle.contains('dart:math'), isFalse);
      });
    }

    test('einfluss.dart importiert nur Ermittlung und Rng', () {
      final quelle = File('$ordner/einfluss.dart').readAsStringSync();
      final importe = [for (final m in RegExp(r"^import '([^']+)';", multiLine: true).allMatches(quelle)) m[1]];
      expect(importe, ['../party/entscheidungen.dart', '../util/rng.dart']);
    });
  });

  group('Daten (einfluss.json)', () {
    test('Regeln lesen alles: 19 Optionen mit Bezug und Randnotizen, 20 Figuren, 6 Ereignisse', () {
      expect(_r.akte, 'schlosskeller');
      expect(_r.bezug.keys.toSet(), {for (final e in einflussErmittlung.entscheidungen) for (final o in e.optionen) o.id});
      expect(_r.bezug, hasLength(19));
      expect(_r.randnotizen, hasLength(19));
      expect(_r.figuren, hasLength(20));
      expect(_r.auspacken.keys.toSet(), _r.figuren.toSet());
      expect(_r.bots.keys.toSet(), _r.figuren.toSet());
      expect(_r.ziele.keys.toSet(), _r.figuren.toSet());
      expect([for (final e in _r.ereignisse) e.id], ['tee', 'kerzenschein', 'erinnerung', 'flackerlicht', 'fledermaus', 'kragen']);
      expect(_r.arten.keys.toSet(), ZugArt.waehlbar.toSet());
      expect(_r.kern, ['ahmet', 'fatma', 'olli', 'can']);
      expect(_r.tipps, [..._r.kern, tippKeiner]);
      for (final p in _r.bots.values) {
        expect(p.gewichte.values.fold(0, (a, b) => a + b), 100);
      }
    });

    test('ausJson prüft Format, Zahlen, Arten, Bezug-Optionen und Verweise', () {
      Map<String, Object?> mit(void Function(Map<String, Object?> j) aendern) => kopie(einflussJson())..let(aendern);
      final erm = einflussErmittlung;
      expect(() => EinflussRegeln.ausJson(mit((j) => j['format'] = 'x'), erm), _formatFehler('format'));
      expect(() => EinflussRegeln.ausJson(mit((j) => ((j['zahlen'] as Map)['tisch'] as Map)['teiler'] = 0), erm), _formatFehler('zahlen.tisch.teiler'));
      expect(() => EinflussRegeln.ausJson(mit((j) => ((j['zahlen'] as Map)['minuten'] as Map)['boden'] = 50), erm), _formatFehler('Boden'));
      expect(() => EinflussRegeln.ausJson(mit((j) => (j['arten'] as List).removeLast()), erm), _formatFehler('arten'));
      expect(() => EinflussRegeln.ausJson(mit((j) => (j['bezug'] as Map)['e9_9_x'] = ['ahmet']), erm), _formatFehler('unbekannte Option e9_9_x'));
      expect(() => EinflussRegeln.ausJson(mit((j) => (j['bezug'] as Map).remove('e3_3_aylin')), erm), _formatFehler('Option e3_3_aylin fehlt'));
      expect(() => EinflussRegeln.ausJson(mit((j) => (j['bezug'] as Map)['e3_3_aylin'] = ['niemand']), erm), _formatFehler('unbekannte Figur niemand'));
      expect(() => EinflussRegeln.ausJson(mit((j) => (j['randnotizen'] as Map)['e3_3_aylin'] = ['b_x']), erm), _formatFehler('unbekannte Beobachtung b_x'));
      expect(() => EinflussRegeln.ausJson(mit((j) => (j['randnotizen'] as Map)['e3_3_aylin'] = ['b_aylin_quittung', 'b_hana_wachs', 'b_baran_rufe']), erm), _formatFehler('1 bis 2'));
      expect(() => EinflussRegeln.ausJson(mit((j) => (j['auspacken'] as Map)['tim'] = {'fakt': 'f_x'}), erm), _formatFehler('unbekannter Fakt f_x'));
      expect(() => EinflussRegeln.ausJson(mit((j) => (j['auspacken'] as Map)['tim'] = <String, Object?>{}), erm), _formatFehler('fakt oder notiz'));
      expect(() => EinflussRegeln.ausJson(mit((j) => (((j['bots'] as Map)['tim'] as Map)['gewichte'] as Map)['helfen'] = 41), erm), _formatFehler('Summe nicht 100'));
      expect(() => EinflussRegeln.ausJson(mit((j) => ((j['ziele'] as Map)['tim'] as List).removeLast()), erm), _formatFehler('genau zwei Sterne'));
      expect(() => EinflussRegeln.ausJson(mit((j) => (j['ereignisse'] as List).add({'id': 'tee', 'leiste': 'spuk', 'stufe': 1})), erm), _formatFehler('doppelt'));
    });
  });

  group('Tischwert (§3.3) und Würfel (§3.4)', () {
    test('m(n) = ⌈n/5⌉ und T = sign(v)·min(2, ⌊|v|/m(n)⌋)', () {
      final z = _r.zahlen;
      expect({for (final n in [4, 5, 6, 10, 11, 15, 16, 20]) n: z.tischMass(n)}, {4: 1, 5: 1, 6: 2, 10: 2, 11: 3, 15: 3, 16: 4, 20: 4});
      expect(z.tischwert(0, 4), 0);
      expect(z.tischwert(1, 6), 0);
      expect(z.tischwert(3, 6), 1);
      expect(z.tischwert(5, 6), 2);
      expect(z.tischwert(9, 4), 2);
      expect(z.tischwert(-4, 4), -2);
      expect(z.tischwert(-3, 20), 0);
      expect(z.tischwert(-8, 20), -2);
    });

    test('Golden-Schutz: ohne Tisch und Umweg ist der Modifikator genau die Basis; sonst [−2, +3]', () {
      final z = _r.zahlen;
      for (var basis = -3; basis <= 4; basis++) {
        expect(z.suchModifikator(basis), basis);
      }
      expect(z.suchModifikator(2, tisch: 2), 3);
      expect(z.suchModifikator(0, tisch: -2), -2);
      expect(z.suchModifikator(0, tisch: -2, umweg: 1), -1);
      expect(z.suchModifikator(1, tisch: 1, umweg: 1), 3);
    });

    test('Budget (§3.7): Grund + Übertrag ≤ 5 ab Runde 2 + Änderung, Boden 42', () {
      final z = _r.zahlen;
      expect(z.rundenBudget(runde: 1, restVorher: 30, aenderung: 0), 45);
      expect(z.rundenBudget(runde: 2, restVorher: 30, aenderung: 0), 50);
      expect(z.rundenBudget(runde: 2, restVorher: 4, aenderung: 9), 58);
      expect(z.rundenBudget(runde: 3, restVorher: 0, aenderung: -8), 42);
      expect(z.rundenBudget(runde: 1, restVorher: 0, aenderung: -16), 42);
    });

    test('Leistenzuwachs (§3.8, abgestimmt): Zusammenhalt +2 ab 5K ≥ 2·n_eff, +1 ab 5K ≥ n_eff; Spuk +2 ab 2L ≥ n_eff, +1 ab 4L ≥ n_eff', () {
      final z = _r.zahlen;
      expect([for (final k in [0, 1, 2, 3]) z.zuwachs(Leiste.zusammenhalt, k, 4)], [0, 1, 2, 2], reason: 'n = 4 zählt als n_eff = 5');
      expect([for (final k in [2, 3, 4, 5]) z.zuwachs(Leiste.zusammenhalt, k, 12)], [0, 1, 1, 2]);
      expect([for (final k in [3, 4, 7, 8]) z.zuwachs(Leiste.zusammenhalt, k, 20)], [0, 1, 1, 2]);
      expect([for (final l in [2, 3, 5, 6]) z.zuwachs(Leiste.spuk, l, 12)], [0, 1, 1, 2]);
    });
  });

  group('Folgen einer Runde', () {
    test('Zeigen und Decken: Tischwerte, Gerüchte, Spuk und Flackerlicht, private Nachrichten, Zugtafel', () {
      final s = _stand(6); // ahmet, fatma, olli, can, leyla, emine
      _setze(s, 1, [
        _z('ahmet', ZugArt.lauschen, 'leyla'),
        _z('fatma', ZugArt.zeigen, 'ahmet'),
        _z('olli', ZugArt.zeigen, 'ahmet'),
        _z('can', ZugArt.zeigen, 'ahmet'),
        _z('leyla', ZugArt.decken, 'fatma'),
        _z('emine', ZugArt.decken, 'fatma'),
      ]);
      expect(s.vollstaendig(1), isTrue);
      expect(s.tisch(1, 'e1_1_joanna'), 0, reason: 'vor den Folgen gibt es keinen Tischwert');
      final f = s.auswerten(1);
      expect(f.tisch, {'e1_1_joanna': 1, 'e1_1_damir': 1, 'e1_2_emine': -1, 'e1_2_tugba': -1, 'e1_3_tim': 0, 'e1_3_azra': 0});
      expect(s.tisch(1, 'e1_2_tugba'), -1);
      expect([for (final g in f.geruechte) g.toJson()], [{'figur': 'ahmet', 'laut': true}]);
      expect([f.summeZusammenhalt, f.summeSpuk, f.zusammenhalt, f.spuk], [0, 3, 0, 2]);
      expect([for (final e in f.ereignisse) e.id], ['flackerlicht']);
      expect([f.minutenHelfen, f.minutenAblenken, f.minutenEreignisse, f.minuten], [0, 0, -3, -3]);
      expect(fluesternAus(_r.zahlen, f.zusammenhaltZuwachs), Fluestern.still);
      expect({for (final e in f.privat.entries) e.key: [for (final n in e.value) n.toJson()]}, {
        'fatma': [{'art': 'mehrere_halten'}, {'art': 'wirkte'}],
        'ahmet': [{'art': 'gelauscht', 'figur': 'leyla', 'zug': 'decken', 'ziel': 'fatma'}],
        'olli': [{'art': 'wirkte'}],
        'can': [{'art': 'wirkte'}],
        'leyla': [{'art': 'wirkte'}],
        'emine': [{'art': 'wirkte'}],
      });
      expect([for (final t in f.tafel) t.toJson()], [
        {'rolle': 'ahmet', 'art': 'lauschen', 'ziel': 'leyla'},
        {'rolle': 'fatma', 'art': 'zeigen', 'ziel': 'ahmet'},
        {'rolle': 'olli', 'art': 'zeigen', 'ziel': 'ahmet'},
        {'rolle': 'can', 'art': 'zeigen', 'ziel': 'ahmet'},
        {'rolle': 'leyla', 'art': 'decken', 'ziel': 'fatma'},
        {'rolle': 'emine', 'art': 'decken', 'ziel': 'fatma'},
      ]);
      expect(s.decker(1, 'e1_2_emine'), ['leyla', 'emine']);
      expect(s.decker(1, 'e1_1_joanna'), isEmpty);
      expect(() => s.setze(1, _z('ahmet', ZugArt.helfen)), throwsStateError, reason: 'nach den Folgen ist die Runde fest');
    });

    test('Ein Decker allein: „Jemand hält zu dir“; Selbst-Decken und Unwirksames ohne Folgen', () {
      final s = _stand(6);
      _setze(s, 1, [
        _z('ahmet', ZugArt.decken, 'ahmet'),
        _z('fatma', ZugArt.decken, 'olli'),
        _z('olli', ZugArt.zeigen, 'can'),
      ]);
      final f = s.auswerten(1);
      expect(f.privat['olli']!.map((n) => n.art), [PrivatArt.haeltZuDir, PrivatArt.ohneFolgen]);
      expect(f.privat['ahmet']!.map((n) => n.art), [PrivatArt.ohneFolgen], reason: 'n = 6: ein Decken allein bewegt T nicht');
      expect(f.privat.containsKey('can'), isFalse);
      expect(f.zuege['leyla']!.art, ZugArt.abgewartet);
      expect(f.geruechte.single.toJson(), {'figur': 'can', 'laut': false});
    });

    test('Lauschen („Änderungen“ 1): Schlüssel mit Ziel, ohne Ziel und bei abgewartet; Inhalt wie bisher', () {
      final s = _stand(6);
      _setze(s, 1, [
        _z('ahmet', ZugArt.lauschen, 'fatma'),
        _z('fatma', ZugArt.helfen),
        _z('olli', ZugArt.lauschen, 'can'),
        _z('leyla', ZugArt.lauschen, 'emine'),
        _z('emine', ZugArt.decken, 'fatma'),
      ]);
      final f = s.auswerten(1);
      PrivatNachricht gelauscht(String rolle) => f.privat[rolle]!.singleWhere((n) => n.art == PrivatArt.gelauscht);
      expect(gelauscht('ahmet').schluessel, 'einfluss.privat.gelauscht.ohne_ziel');
      expect(gelauscht('olli').schluessel, 'einfluss.privat.gelauscht.abgewartet');
      expect(gelauscht('leyla').schluessel, 'einfluss.privat.gelauscht');
      expect([for (final r in ['ahmet', 'olli', 'leyla']) gelauscht(r).toJson()], [
        {'art': 'gelauscht', 'figur': 'fatma', 'zug': 'helfen'},
        {'art': 'gelauscht', 'figur': 'can', 'zug': 'abgewartet'},
        {'art': 'gelauscht', 'figur': 'emine', 'zug': 'decken', 'ziel': 'fatma'},
      ]);
      expect(const PrivatNachricht(PrivatArt.wirkte).schluessel, 'einfluss.privat.wirkte');
    });

    test('Helfen: Deckel +9, Zusammenhalt +2 → Tee, Kerzenschein, Erinnerung; Flüstern wahr; Nachfragen', () {
      final s = _stand(5);
      final alle = [for (final r in s.besetzt) _z(r, ZugArt.helfen)];
      _setze(s, 1, alle);
      final f1 = s.auswerten(1);
      expect([f1.minutenHelfen, f1.minutenEreignisse, f1.minuten], [9, 5, 14]);
      expect([f1.zusammenhaltZuwachs, f1.zusammenhalt, f1.spuk], [2, 2, 0]);
      expect([for (final e in f1.ereignisse) e.id], ['tee']);
      expect(fluesternAus(_r.zahlen, f1.zusammenhaltZuwachs), Fluestern.wahr);
      _setze(s, 2, alle);
      final f2 = s.auswerten(2);
      expect([for (final e in f2.ereignisse) e.id], ['kerzenschein']);
      expect(f2.kerzenschein, isTrue);
      expect(s.kerzenscheinNehmen(), isTrue);
      expect(s.kerzenscheinNehmen(), isFalse);
      expect([s.nachfragen(0), s.nachfragen(24), s.nachfragen(25), s.nachfragen(49), s.nachfragen(50), s.nachfragen(90)], [0, 0, 1, 1, 2, 2],
          reason: 'je volle 25 Restminuten eine, höchstens 2');
      _setze(s, 3, alle);
      final f3 = s.auswerten(3);
      expect([for (final e in f3.ereignisse) e.id], ['erinnerung']);
      expect(s.zusammenhalt, 6);
      expect([s.nachfragen(50), s.nachfragen(25), s.nachfragen(9)], [3, 2, 1]);
      expect(s.tischbonus, 1);
      expect(s.morgen, MorgenVariante.warm);
      expect(() => s.auswerten(4), throwsStateError);
    });

    test('Ablenken: Deckel −8, Zusammenhalt nie unter 0, Spuk → Flackerlicht, Fledermaus (T doppelt), Kragen', () {
      final s = _stand(5); // ahmet, fatma, olli, can, leyla
      _setze(s, 1, [
        _z('ahmet', ZugArt.ablenken),
        _z('fatma', ZugArt.ablenken),
        _z('olli', ZugArt.ablenken),
        _z('can', ZugArt.helfen),
      ]);
      expect(s.vollstaendig(1), isFalse);
      final f1 = s.auswerten(1);
      expect([f1.minutenHelfen, f1.minutenAblenken, f1.minutenEreignisse, f1.minuten], [3, -8, -3, -8]);
      expect([f1.summeZusammenhalt, f1.summeSpuk, f1.zusammenhalt, f1.spuk], [0, 6, 0, 2]);
      expect(f1.ablenker, ['ahmet', 'fatma', 'olli']);
      expect(_r.zahlen.rundenBudget(runde: 1, restVorher: 0, aenderung: f1.minuten), 42);
      _setze(s, 2, [
        _z('ahmet', ZugArt.ablenken),
        _z('fatma', ZugArt.ablenken),
        _z('olli', ZugArt.ablenken),
        _z('can', ZugArt.decken, 'fatma'),
        _z('leyla', ZugArt.helfen),
      ]);
      final f2 = s.auswerten(2);
      expect([for (final e in f2.ereignisse) e.id], ['fledermaus']);
      expect(f2.fledermaus, isTrue);
      expect([f2.tisch['e2_2_vitrine'], f2.tisch['e2_2_tasche']], [-2, -2], reason: 'n = 5: v = −1 → T = −1, doppelt −2');
      _setze(s, 3, [for (final r in ['ahmet', 'fatma', 'olli']) _z(r, ZugArt.ablenken)]);
      final f3 = s.auswerten(3);
      expect([for (final e in f3.ereignisse) e.id], ['kragen']);
      expect(f3.minutenEreignisse, -5);
      expect(s.spuk, 6);
      expect(s.tischbonus, -1);
      expect(s.morgen, MorgenVariante.chaotisch);
      expect(s.ausgeloest, {'flackerlicht', 'fledermaus', 'kragen'});
    });

    test('Kragen erzwingt den chaotischen Morgen, auch bei hohem Zusammenhalt („Änderungen“ 2)', () {
      final s = _stand(5); // ahmet, fatma, olli, can, leyla
      _setze(s, 1, [
        _z('ahmet', ZugArt.auspacken),
        _z('fatma', ZugArt.helfen),
        _z('olli', ZugArt.zeigen, 'can'),
        _z('can', ZugArt.zeigen, 'olli'),
        _z('leyla', ZugArt.zeigen, 'ahmet'),
      ]);
      s.auswerten(1);
      _setze(s, 2, [
        _z('ahmet', ZugArt.zeigen, 'can'),
        _z('fatma', ZugArt.auspacken),
        _z('olli', ZugArt.helfen),
        _z('can', ZugArt.zeigen, 'olli'),
        _z('leyla', ZugArt.zeigen, 'ahmet'),
      ]);
      s.auswerten(2);
      _setze(s, 3, [
        _z('ahmet', ZugArt.zeigen, 'can'),
        _z('fatma', ZugArt.zeigen, 'olli'),
        _z('olli', ZugArt.auspacken),
        _z('can', ZugArt.zeigen, 'olli'),
        _z('leyla', ZugArt.helfen),
      ]);
      final f3 = s.auswerten(3);
      expect([s.zusammenhalt, s.spuk], [6, 6]);
      expect([for (final e in f3.ereignisse) e.id], ['erinnerung', 'kragen']);
      expect(morgenAus(_r.zahlen, zusammenhalt: 6, spuk: 6), MorgenVariante.gemischt, reason: 'ohne Kragen wäre der Morgen gemischt');
      expect(s.morgen, MorgenVariante.chaotisch);
      expect(s.tischbonus, 0);
    });

    test('Auspacken einmal am Abend: Fakt und Notiz öffentlich mit Namen, danach gesperrt', () {
      final s = _stand(7); // … tim
      _setze(s, 1, [_z('ahmet', ZugArt.auspacken), _z('emine', ZugArt.auspacken), _z('tim', ZugArt.auspacken)]);
      final f = s.auswerten(1);
      expect([for (final a in f.auspacken) a.toJson()], [
        {'figur': 'ahmet', 'fakt': 'f_nd_ahmet_umschlag'},
        {'figur': 'emine', 'fakt': 'f_nd_fatma', 'notiz': 'b_emine_schatulle'},
        {'figur': 'tim', 'fakt': 'f_kurzschluss', 'notiz': 'b_tim_kurzschluss'},
      ]);
      expect(f.fakten, {'f_nd_ahmet_umschlag', 'f_nd_fatma', 'f_kurzschluss'});
      expect(f.notizen, ['b_emine_schatulle', 'b_tim_kurzschluss']);
      expect(s.gestanden, {'ahmet': 1, 'emine': 1, 'tim': 1});
      expect([f.summeZusammenhalt, f.zusammenhaltZuwachs], [6, 2]);
      expect(() => s.setze(2, _z('ahmet', ZugArt.auspacken)), throwsArgumentError);
      s.setze(2, _z('fatma', ZugArt.auspacken));
      expect(s.zug(2, 'fatma')!.art, ZugArt.auspacken);
      s.setze(2, _z('fatma', ZugArt.helfen));
      expect(s.zug(2, 'fatma')!.art, ZugArt.helfen, reason: 'änderbar bis zu den Folgen');
    });

    test('Unzulässige Züge ändern nichts', () {
      final s = _stand(4);
      expect(() => s.setze(2, _z('ahmet', ZugArt.helfen)), throwsStateError);
      expect(() => s.setze(1, _z('leyla', ZugArt.helfen)), throwsArgumentError, reason: 'nicht besetzt');
      expect(() => s.setze(1, _z('ahmet', ZugArt.zeigen, 'ahmet')), throwsArgumentError);
      expect(() => s.setze(1, _z('ahmet', ZugArt.zeigen)), throwsArgumentError);
      expect(() => s.setze(1, _z('ahmet', ZugArt.zeigen, 'leyla')), throwsArgumentError, reason: 'Ziel nicht besetzt');
      expect(() => s.setze(1, _z('ahmet', ZugArt.lauschen, 'ahmet')), throwsArgumentError);
      expect(() => s.setze(1, _z('ahmet', ZugArt.helfen, 'fatma')), throwsArgumentError);
      expect(() => s.setze(1, _z('ahmet', ZugArt.abgewartet, 'fatma')), throwsArgumentError);
      expect(() => s.setze(1, _z('ahmet', ZugArt.helfen, null, 'fatma')), throwsArgumentError, reason: 'Tipp nur in Runde 3');
      expect(s.zug(1, 'ahmet'), isNull);
      s.setze(1, _z('ahmet', ZugArt.decken, 'ahmet'));
      s.auswerten(1);
      s.auswerten(2);
      expect(() => s.setze(3, _z('ahmet', ZugArt.helfen, null, 'leyla')), throwsArgumentError);
      s.setze(3, _z('ahmet', ZugArt.helfen, null, 'fatma'));
      s.setze(3, _z('fatma', ZugArt.abgewartet, null, tippKeiner));
      expect(s.tipps, isEmpty, reason: 'verdeckt bis zur Auswertung');
      s.auswerten(3);
      expect(s.tipps, {'ahmet': 'fatma', 'fatma': tippKeiner});
      expect(() => EinflussStand(_r, besetzt: ['ahmet', 'ahmet']), throwsArgumentError);
      expect(() => EinflussStand(_r, besetzt: ['schneider']), throwsArgumentError);
    });

    test('Ertappt: gezogen aus den Deckern über ertappt:<salz>:<entscheidung>, ohne Decker niemand', () {
      expect(ertapptAuswahl(salz: 's', entscheidung: 'e1_2', decker: const []), isNull);
      final decker = ['leyla', 'emine', 'tim'];
      final soll = decker[Rng(Rng.hashString('ertappt:salz-1:e1_2')).nextInt(3)];
      expect(ertapptAuswahl(salz: 'salz-1', entscheidung: 'e1_2', decker: decker), soll);
      final gezogen = {for (var i = 0; i < 60; i++) ertapptAuswahl(salz: 's$i', entscheidung: 'e2_1', decker: decker)};
      expect(gezogen, decker.toSet(), reason: 'jeder Decker kann ertappt werden');
      final s = _stand(5);
      s.ertapptMelden('leyla');
      s.ertapptMelden('leyla');
      expect(s.ertappt, {'leyla': 2});
      expect(() => s.ertapptMelden('tim'), throwsArgumentError);
    });

    test('Ende (§3.10): Tischbonus, Endwert 0…9, Morgen', () {
      final z = _r.zahlen;
      expect([for (final (zh, sp) in [(4, 0), (0, 4), (4, 4), (3, 3), (6, 6)]) tischbonusAus(z, zusammenhalt: zh, spuk: sp)], [1, -1, 0, 0, 0]);
      expect(endwertAus(z, punkte: 9, tischbonus: 1), 9);
      expect(endwertAus(z, punkte: 0, tischbonus: -1), 0);
      expect(endwertAus(z, punkte: 5, tischbonus: 1), 6);
      expect(morgenAus(z, zusammenhalt: 4, spuk: 3), MorgenVariante.warm);
      expect(morgenAus(z, zusammenhalt: 3, spuk: 4), MorgenVariante.chaotisch);
      expect(morgenAus(z, zusammenhalt: 4, spuk: 4), MorgenVariante.gemischt);
      expect(morgenAus(z, zusammenhalt: 0, spuk: 0), MorgenVariante.gemischt);
      expect(morgenAus(z, zusammenhalt: 6, spuk: 0, erzwungen: [MorgenVariante.chaotisch]), MorgenVariante.chaotisch);
      expect([for (final w in [0, 1, 2, 3]) fluesternAus(z, w)], [Fluestern.still, Fluestern.neutral, Fluestern.wahr, Fluestern.wahr]);
    });
  });

  group('Auszeichnungen (§3.10)', () {
    NachtProtokoll protokoll({Map<String, int> ertappt = const {}, String? aufloesung = 'fatma'}) => NachtProtokoll(
          besetzt: const ['ahmet', 'fatma', 'olli', 'can', 'leyla'],
          zuege: {
            1: {
              'ahmet': _z('ahmet', ZugArt.zeigen, 'fatma'),
              'fatma': _z('fatma', ZugArt.decken, 'olli'),
              'olli': _z('olli', ZugArt.ablenken),
              'can': _z('can', ZugArt.auspacken),
              'leyla': _z('leyla', ZugArt.decken, 'ahmet'),
            },
            2: {
              'ahmet': _z('ahmet', ZugArt.zeigen, 'fatma'),
              'fatma': _z('fatma', ZugArt.decken, 'olli'),
              'olli': _z('olli', ZugArt.ablenken),
              'can': _z('can', ZugArt.helfen),
              'leyla': _z('leyla', ZugArt.decken, 'leyla'),
            },
            3: {
              'ahmet': _z('ahmet', ZugArt.helfen, null, 'fatma'),
              'fatma': _z('fatma', ZugArt.decken, 'olli', 'olli'),
              'olli': _z('olli', ZugArt.zeigen, 'ahmet', tippKeiner),
              'can': _z('can', ZugArt.helfen, null, 'ahmet'),
              'leyla': _z('leyla', ZugArt.helfen, null, 'fatma'),
            },
          },
          erfolge: const {1: ['e1_2_emine'], 2: ['e2_2_tasche'], 3: ['e3_2_fatma']},
          ertappt: ertappt,
          angeklagt: 'fatma',
          rest: 12,
          aufloesung: aufloesung,
        );

    test('Stern, Spürnasen, Schlossgeist, Treue Seele aus dem Protokoll', () {
      final p = protokoll();
      expect(gestuetzteErfolge(p, _r, 'ahmet'), 2);
      expect(gestuetzteErfolge(p, _r, 'olli'), 0);
      final a = auszeichnen(p, _r, sterne: const {'ahmet': 1, 'fatma': 2, 'can': 1});
      expect(a.wertung, {'ahmet': 7, 'fatma': 6, 'olli': 0, 'can': 4, 'leyla': 2});
      expect(a.toJson(), {
        'stern': 'ahmet', 'spuernasen': ['ahmet', 'leyla'], 'schlossgeist': 'olli', 'treueSeele': 'fatma',
        'wertung': {'ahmet': 7, 'fatma': 6, 'olli': 0, 'can': 4, 'leyla': 2},
      });
    });

    test('Ohne Auflösung keine Spürnasen; Gleichstand: weniger Ertappt, dann Besetzungsreihenfolge', () {
      final ohne = auszeichnen(protokoll(aufloesung: null), _r, sterne: const {});
      expect(ohne.spuernasen, isEmpty);
      expect(ohne.wertung, {'ahmet': 2, 'fatma': 0, 'olli': 0, 'can': 1, 'leyla': 0});
      final gleich = auszeichnen(protokoll(aufloesung: null), _r, sterne: const {'fatma': 1, 'olli': 1});
      expect([gleich.wertung['fatma'], gleich.wertung['olli']], [3, 3]);
      expect(gleich.stern, 'fatma');
      expect(auszeichnen(protokoll(aufloesung: null, ertappt: {'fatma': 1}), _r, sterne: const {'fatma': 1, 'olli': 1}).stern, 'olli');
    });
  });

  group('Texte (§3.13)', () {
    test('Katalog: alle Pflichtschlüssel, eindeutig, Ereignisse aus den Daten', () {
      final k = einflussKatalog(_r);
      expect(k.toSet(), hasLength(k.length));
      // 283 aus §3.13 und der Textart, dazu „Änderungen“ 1 (2 Lausch-Karten), 3 (6 Ereignistitel), 6 (Tipp-Karte).
      expect(k, hasLength(292));
      expect(k, containsAll([
        'einfluss.zug.zeigen.wahl', 'einfluss.zug.decken.wahl', 'einfluss.zug.lauschen.wahl', 'einfluss.tipp.wahl',
        'einfluss.ereignis.fledermaus', 'einfluss.ereignis.fledermaus.karte', 'einfluss.privat.ohne_folgen',
        'einfluss.ziel.hakan.2', 'einfluss.epilog.tugba.verfehlt', 'einfluss.bot.can.freund_gestanden', 'einfluss.preis.treue_seele',
        'einfluss.privat.gelauscht', 'einfluss.privat.gelauscht.ohne_ziel', 'einfluss.privat.gelauscht.abgewartet', 'einfluss.tipp.p1',
        for (final e in _r.ereignisse) 'einfluss.ereignis.${e.id}.titel',
      ]));
      expect(k.where((x) => x.startsWith('einfluss.zug.') && x.endsWith('.wahl')), hasLength(3));
    });

    test('Textart nach „Änderungen“: Vorlesen oder Karte', () {
      const vorlesen = [
        'einfluss.folgen.start.1', 'einfluss.auspacken.ahmet', 'einfluss.ablenken.schluss', 'einfluss.geruecht.laut',
        'einfluss.leiste.ruhig', 'einfluss.ereignis.tee', 'einfluss.wieder', 'einfluss.fluestern.still', 'einfluss.ertappt',
        'einfluss.ertappt.selbst', 'einfluss.verwischt', 'einfluss.tischbonus.plus', 'einfluss.preis.stern',
        'einfluss.morgen.warm', 'einfluss.epilog.can.erreicht',
      ];
      const karten = [
        'einfluss.zug.zeigen.titel', 'einfluss.tipp.titel', 'einfluss.tipp.p1', 'einfluss.ereignis.tee.karte',
        'einfluss.ereignis.kerzenschein.titel', 'einfluss.privat.gelauscht.abgewartet', 'einfluss.abzeichen.minus2',
        'einfluss.befragung.mauert', 'einfluss.tischruf.umweg', 'einfluss.nachfrage.p1', 'einfluss.privat.ertappt',
        'einfluss.ziel.ahmet.1', 'einfluss.bot.olli.geruecht', 'intro.start', 'ui.weiter',
      ];
      for (final k in vorlesen) {
        expect(einflussVorlesetext(k), isTrue, reason: k);
      }
      for (final k in karten) {
        expect(einflussVorlesetext(k), isFalse, reason: k);
      }
      // Im Katalog: 111 Vorlesetexte (Folgen 3, Auspacken 20, Ablenken 21, Gerüchte 2, Leisten 5, Ereignisse 6,
      // wieder, Flüstern, Ertappt 2, Verwischt, Tischbonus 2, Preise 4, Morgen 3, Epiloge 40), der Rest Karten.
      final k = einflussKatalog(_r);
      expect(k.where(einflussVorlesetext), hasLength(111));
      expect(k.where((x) => !einflussVorlesetext(x)), hasLength(181));
    });

    test('Bereich einfluss: Textsammlung, Verweise, Vorlesen in textQuellen, Platzhalter mit Anzeigenamen', () {
      final ordner = '$repoWurzel/content/party/schlosskeller';
      final index = leseJson('$ordner/texte/index.json');
      final probe = {
        'settingId': kanon.settingId,
        'bereich': 'einfluss',
        'hinweis': 'Fixture',
        'eintraege': [
          {'id': 'einfluss.ertappt', 'text': '@figur hielt zu @ziel.'},
          {'id': 'einfluss.privat.gelauscht', 'text': '@figur: @zug bei @ziel'},
          {'id': 'einfluss.privat.gelauscht.abgewartet', 'text': '@figur hat abgewartet'},
          {'id': 'einfluss.zug.decken.titel', 'text': 'Decken'},
          {'id': 'ui.falsch', 'text': 'Nicht hier'},
        ],
      };
      final sammlung = Textsammlung.lade((p) {
        if (p == 'texte/index.json') {
          return {...index, 'dateien': [...index['dateien'] as List, {'datei': 'einfluss-probe.json', 'bereich': 'einfluss'}]};
        }
        if (p == 'texte/einfluss-probe.json') return probe;
        return leseJson('$ordner/$p');
      });
      expect(sammlung.bausteine['einfluss.ertappt'], '@figur hielt zu @ziel.');
      expect(textVerweise(kanon, sammlung), ['texte/einfluss-probe.json: ui.falsch ist kein Einfluss-Schlüssel']);
      final quellen = {for (final q in textQuellen(kanon, sammlung)) if (q.ort.startsWith('texte/einfluss-probe.json#')) q.ort.split('#').last: q.vorlesen};
      expect(quellen, {
        'einfluss.ertappt': true,
        'einfluss.privat.gelauscht': false,
        'einfluss.privat.gelauscht.abgewartet': false,
        'einfluss.zug.decken.titel': false,
        'ui.falsch': false,
      });
      final texte = Texte(kanon, sammlung);
      expect(texte.einflussText('einfluss.ertappt', figur: 'meryem', ziel: 'kaan'), 'Hana hielt zu Wojtek.');
      expect(texte.einflussText('einfluss.privat.gelauscht', figur: 'murat', ziel: 'johanna', zug: 'decken'), 'Marek: Decken bei Joanna');
      // Abgewartet hat keinen Kurznamen; der Text trägt kein @zug („Änderungen“ 1).
      expect(texte.einflussText('einfluss.privat.gelauscht.abgewartet', figur: 'murat', zug: 'abgewartet'), 'Marek hat abgewartet');
      expect(() => texte.einflussText('einfluss.ertappt', figur: 'niemand'), throwsArgumentError);
    });
  });

  test('Zug als JSON hin und zurück', () {
    for (final z in [_z('ahmet', ZugArt.zeigen, 'can'), _z('can', ZugArt.helfen, null, tippKeiner), const EinflussZug.abgewartet('olli')]) {
      expect(EinflussZug.ausJson(z.toJson()), z);
    }
    expect(() => EinflussZug.ausJson({'rolle': 'ahmet', 'art': 'schummeln'}), throwsFormatException);
  });
}

extension<T> on T {
  T let(void Function(T) f) {
    f(this);
    return this;
  }
}
