// Bots der Einfluss-Schicht (Finale §3.11): eigener Strom einfluss:<salz>:<rolle>:<runde>, getrennt von
// Stimmen- und Würfelstrom; nur öffentliche Eingaben (nie Lösung, Fall oder Dossier); Persönlichkeit je
// Figur mit plausiblen Verteilungen über 2.000 Salze; Übersteuerungen; jeder Bot-Zug ist gültig.
import 'dart:io';

import 'package:mordakte_core/mordakte_core.dart';
import 'package:mordakte_core/runden.dart';
import 'package:test/test.dart';

import '../party/kanon_hilfe.dart';
import 'einfluss_hilfe.dart';

EinflussRegeln get _r => einflussRegeln;
const _salze = 2000;

BotLage _lage({
  List<String>? besetzt,
  List<List<Geruecht>> geruechte = const [],
  Set<String> ertappt = const {},
  Set<String> gestanden = const {},
  Set<String> sichtbar = const {},
  List<String> verdaechtig = const ['ahmet', 'fatma', 'olli', 'can'],
}) =>
    BotLage(besetzt: besetzt ?? _r.figuren, geruechte: geruechte, ertappt: ertappt, gestanden: gestanden, sichtbar: sichtbar, verdaechtig: verdaechtig);

/// Züge über [_salze] Salze.
List<EinflussZug> _zuege(String rolle, int runde, BotLage lage) =>
    [for (var i = 0; i < _salze; i++) botZug(_r, salz: 'verteilung-$i', rolle: rolle, runde: runde, lage: lage)];

/// Anteil je Zugart in Prozent.
Map<ZugArt, double> _anteile(List<EinflussZug> z) => {
      for (final a in ZugArt.values)
        if (z.any((x) => x.art == a)) a: 100 * z.where((x) => x.art == a).length / z.length,
    };

void _ungefaehr(Map<ZugArt, double> ist, Map<ZugArt, num> soll, String grund, {double toleranz = 4}) {
  for (final a in ZugArt.values) {
    expect(ist[a] ?? 0, closeTo(soll[a] ?? 0, toleranz), reason: '$grund: ${a.name}');
  }
}

void main() {
  group('Strom und Eingaben', () {
    test('Eigener Strom einfluss:<salz>:<rolle>:<runde>, getrennt von Stimmen und Würfeln', () {
      expect(botStromText('s', 'ahmet', 2), 'einfluss:s:ahmet:2');
      final seeds = <int, String>{};
      for (var i = 0; i < 50; i++) {
        for (final rolle in _r.figuren) {
          for (var runde = 1; runde <= 3; runde++) {
            for (final text in [botStromText('salz$i', rolle, runde), 'bot:salz$i:$rolle:$runde', SalzWuerfel.seedText('salz$i', rolle, runde)]) {
              final h = Rng.hashString(text);
              expect(seeds.putIfAbsent(h, () => text), text, reason: 'Seed-Kollision zwischen Strömen');
            }
          }
        }
      }
      // Bot-Züge verbrauchen keinen fremden Strom: Stimmen und Würfel bleiben gleich, ob vorher Bots zogen oder nicht.
      final vorher = [for (final r in _r.figuren) botKooperativ(salz: 'x', rolle: r, runde: 1)];
      final augen = const SalzWuerfel('x').augen('e2_1', 1);
      for (final r in _r.figuren) {
        botZug(_r, salz: 'x', rolle: r, runde: 1, lage: _lage());
      }
      expect([for (final r in _r.figuren) botKooperativ(salz: 'x', rolle: r, runde: 1)], vorher);
      expect(const SalzWuerfel('x').augen('e2_1', 1), augen);
    });

    test('Gleiche Eingaben, gleicher Zug; Salz, Rolle und Runde ändern den Strom', () {
      final a = botZug(_r, salz: 'abend', rolle: 'can', runde: 2, lage: _lage());
      expect(botZug(_r, salz: 'abend', rolle: 'can', runde: 2, lage: _lage()), a);
      final verschieden = {for (var i = 0; i < 40; i++) botZug(_r, salz: 'abend$i', rolle: 'can', runde: 2, lage: _lage()).art};
      expect(verschieden.length, greaterThan(2));
      expect(() => botZug(_r, salz: '', rolle: 'can', runde: 2, lage: _lage()), throwsArgumentError);
      expect(() => botZug(_r, salz: 's', rolle: 'can', runde: 4, lage: _lage()), throwsArgumentError);
      expect(() => botZug(_r, salz: 's', rolle: 'tugba', runde: 1, lage: _lage(besetzt: _r.figuren.take(4).toList())), throwsArgumentError);
    });

    test('Keine Eingabe kennt Lösung, Fall oder Dossier: botZug nimmt nur Regeln, Salz, Rolle, Runde und das öffentliche Bild', () {
      final quelle = File('$repoWurzel/packages/mordakte_core/lib/src/runden/einfluss.dart').readAsStringSync();
      final signatur = RegExp(r'EinflussZug botZug\(([^)]*)\)').firstMatch(quelle)![1]!;
      expect(signatur.replaceAll(RegExp(r'\s+'), ' '), 'EinflussRegeln r, {required String salz, required String rolle, required int runde, required BotLage lage}');
      final lage = RegExp(r'class BotLage \{(.*?)\n\}', dotAll: true).firstMatch(quelle)![1]!;
      final felder = {for (final m in RegExp(r'^  final [^;=]*? (\w+(?:, \w+)*);', multiLine: true).allMatches(lage)) ...m[1]!.split(', ')};
      expect(felder, {'besetzt', 'geruechte', 'ertappt', 'gestanden', 'sichtbar', 'verdaechtig'});
    });
  });

  group('Persönlichkeit über $_salze Salze', () {
    test('Ohne Anlass folgen alle 20 Figuren ihren Gewichten (±4 Prozentpunkte)', () {
      for (final rolle in _r.figuren) {
        final p = _r.bots[rolle]!;
        if (p.auspacken?.runde == 2) continue; // eigene Probe unten
        final soll = {for (final e in p.gewichte.entries) e.key: e.value};
        _ungefaehr(_anteile(_zuege(rolle, 2, _lage())), soll, rolle);
      }
    });

    test('Feste Auspack-Runden: Hana in Runde 1 etwa 58 %, Aylin in Runde 3 30 %, Azra in Runde 2 etwa 68 %', () {
      // 50 % fest, sonst die 15 % Auspack-Gewicht: 50 + 50 · 0,15 = 57,5; der Rest nach den Gewichten.
      _ungefaehr(_anteile(_zuege('meryem', 1, _lage())), {ZugArt.auspacken: 57.5, ZugArt.helfen: 27.5, ZugArt.zeigen: 7.5, ZugArt.lauschen: 7.5}, 'meryem r1');
      // Wer schon gestanden hat, hilft statt auszupacken: 55 + 15.
      _ungefaehr(_anteile(_zuege('meryem', 1, _lage(gestanden: {'meryem'}))), {ZugArt.helfen: 70, ZugArt.zeigen: 15, ZugArt.lauschen: 15}, 'meryem gestanden');
      // 30 % fest, sonst die Gewichte ohne Auspacken.
      _ungefaehr(_anteile(_zuege('aylin', 3, _lage())), {ZugArt.auspacken: 30, ZugArt.helfen: 31.5, ZugArt.zeigen: 10.5, ZugArt.lauschen: 28}, 'aylin r3');
      _ungefaehr(_anteile(_zuege('aylin', 1, _lage())), {ZugArt.helfen: 45, ZugArt.zeigen: 15, ZugArt.lauschen: 40}, 'aylin r1');
      expect({for (final z in _zuege('aylin', 1, _lage())) if (z.art == ZugArt.zeigen) z.ziel}, {'ahmet'}, reason: 'Aylin zeigt nur auf Ahmet');
      // 60 % fest, sonst die 20 % Auspack-Gewicht: 60 + 40 · 0,2 = 68.
      _ungefaehr(_anteile(_zuege('dilara', 2, _lage())), {ZugArt.auspacken: 68, ZugArt.helfen: 16, ZugArt.decken: 4, ZugArt.zeigen: 4, ZugArt.lauschen: 8}, 'dilara r2');
    });

    test('Feste Ziele, Ersatz für Unbesetzte, Zeigen auf die Meistberedete', () {
      expect({for (final z in _zuege('leyla', 2, _lage())) if (z.art == ZugArt.decken || z.art == ZugArt.lauschen) z.ziel}, {'ahmet'});
      expect({for (final z in _zuege('fatma', 2, _lage())) if (z.art == ZugArt.lauschen) z.ziel}, {'emine'});
      expect({for (final z in _zuege('ahmet', 2, _lage())) if (z.art == ZugArt.decken) z.ziel}, {'ahmet'});
      final vier = _r.figuren.take(4).toList();
      final ersatz = {for (final z in _zuege('fatma', 2, _lage(besetzt: vier))) if (z.art == ZugArt.lauschen) z.ziel};
      expect(ersatz, {'ahmet', 'olli', 'can'}, reason: 'Emine ist unbesetzt: Ersatz aus dem Strom');
      expect({for (final z in _zuege('dilara', 2, _lage())) if (z.art == ZugArt.decken) z.ziel}, {'fatma'});
      expect({for (final z in _zuege('tim', 2, _lage())) if (z.art == ZugArt.zeigen) z.ziel}, {'enes'});
      final ohneDamir = {for (final z in _zuege('tim', 2, _lage(besetzt: _r.figuren.take(7).toList()))) if (z.art == ZugArt.zeigen) z.ziel};
      expect(ohneDamir, isNotEmpty);
      expect(ohneDamir.contains('enes') || ohneDamir.contains('tim'), isFalse, reason: 'Damir ist unbesetzt: Ersatz aus dem Strom, nie auf sich selbst');
      final ohneGeruecht = {for (final z in _zuege('murat', 2, _lage())) if (z.art == ZugArt.zeigen) z.ziel};
      expect(ohneGeruecht, {'ahmet', 'fatma', 'olli', 'can'}, reason: 'ohne Gerücht eine gezogene Kernfigur');
      final beredet = _lage(geruechte: [
        [const Geruecht('olli', laut: false), const Geruecht('baran', laut: true)],
      ]);
      expect({for (final z in _zuege('murat', 2, beredet)) if (z.art == ZugArt.zeigen) z.ziel}, {'baran'});
      expect({for (final z in _zuege('baran', 2, beredet)) if (z.art == ZugArt.zeigen) z.ziel}, {'olli'}, reason: 'nie auf sich selbst');
    });

    test('Übersteuerungen: Freund beredet, mehrere tuscheln, Geheimnis bekannt, nach Ertappt', () {
      final freund = _lage(geruechte: [[const Geruecht('ahmet', laut: false)]]);
      expect({for (final z in _zuege('leyla', 2, freund)) '${z.art.name}:${z.ziel}'}, {'decken:ahmet'});
      final laut = _lage(geruechte: [[const Geruecht('can', laut: true), const Geruecht('olli', laut: false)]]);
      final can = _zuege('can', 2, laut);
      // 50 % auf die meistberedete andere Figur, sonst die Gewichte (15 % zeigen): 50 + 0,5 · 15 = 57,5.
      expect(_anteile(can)[ZugArt.zeigen], closeTo(57.5, 4));
      expect({for (final z in can) if (z.art == ZugArt.zeigen) z.ziel}, contains('olli'));
      expect(_anteile(_zuege('ahmet', 2, _lage(sichtbar: {'f_nd_ahmet_umschlag'})))[ZugArt.decken], isNull, reason: 'kein Selbst-Decken');
      expect(_anteile(_zuege('ahmet', 2, _lage(gestanden: {'ahmet'})))[ZugArt.decken], isNull);
      final ertappt = _anteile(_zuege('leyla', 2, _lage(ertappt: {'leyla'})));
      expect(ertappt[ZugArt.decken], isNull);
      expect(ertappt[ZugArt.helfen], closeTo(80, 4));
      expect(_anteile(_zuege('leyla', 2, _lage(ertappt: {'leyla'}, geruechte: [[const Geruecht('ahmet', laut: false)]])))[ZugArt.decken], isNull,
          reason: 'nach Ertappt gewinnt Helfen auch gegen den Freund');
    });

    test('Tipp nur in Runde 3, gezogen aus der öffentlichen Restmenge', () {
      expect(_zuege('can', 2, _lage()).every((z) => z.tipp == null), isTrue);
      final tipps = [for (final z in _zuege('hakan', 3, _lage(verdaechtig: ['ahmet', 'olli']))) z.tipp];
      expect(tipps.toSet(), {'ahmet', 'olli'});
      expect(100 * tipps.where((t) => t == 'ahmet').length / tipps.length, closeTo(50, 4));
      expect({for (final z in _zuege('hakan', 3, _lage(verdaechtig: ['can']))) z.tipp}, {'can'});
      expect({for (final z in _zuege('hakan', 3, _lage(verdaechtig: const []))) z.tipp}, {tippKeiner});
    });
  });

  test('Ganze Nächte nur mit Bots, 4 bis 20 Rollen: jeder Zug gültig, gleiche Salze gleiche Nacht', () {
    String nacht(int n, String salz) {
      final s = EinflussStand(_r, besetzt: _r.figuren.take(n).toList());
      final aus = StringBuffer();
      for (var runde = 1; runde <= 3; runde++) {
        final lage = s.botLage(sichtbar: {for (final f in s.folgen) ...f.fakten}, verdaechtig: _r.kern);
        for (final rolle in s.besetzt) {
          s.setze(runde, botZug(_r, salz: salz, rolle: rolle, runde: runde, lage: lage));
        }
        expect(s.vollstaendig(runde), isTrue);
        final f = s.auswerten(runde);
        // Ein Decker wird ertappt, wenn es einen gibt (Strom wie im Spiel).
        final o = _r.optionen(runde).first;
        if (ertapptAuswahl(salz: salz, entscheidung: _r.entscheidungVon[o]!, decker: s.decker(runde, o)) case final e?) s.ertapptMelden(e);
        aus.write(f.toJson());
      }
      expect(s.tipps.keys.toSet(), s.besetzt.toSet(), reason: 'jeder Bot tippt in Runde 3');
      return aus.toString();
    }

    for (var n = 4; n <= 20; n++) {
      for (var i = 0; i < 30; i++) {
        expect(nacht(n, 'nacht-$n-$i'), nacht(n, 'nacht-$n-$i'));
      }
    }
  });
}
