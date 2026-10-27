// T-B · Bestes Spiel → Meister für jedes Zugprofil und n = 4–20; keine Budgetüberschreitung in ganzen
// Abenden mit Einfluss-Schicht (Finale §3.7, §3.10, §4). Je Pfad: alle 768 Wahlfolgen für das stützende und
// das störende Profil (n ∈ {4, 7, 12, 20} und alle vier Würfelströme reihum, Tischruf und „gründlich“
// wechselnd), dazu Bot-Tische über Salze; bestes Spiel vollständig über n = 4–20 × Profile × Ströme × Rufe.
@TestOn('vm')
library;

import 'package:mordakte_core/mordakte_core.dart';
import 'package:mordakte_core/runden.dart';
import 'package:test/test.dart';

import '../party/kanon_hilfe.dart';
import 'einfluss_hilfe.dart';
import 'einfluss_lauf.dart';

const _n = [4, 7, 12, 20];

/// Würfelströme: immer Pech, immer Erfolg, neutral 3+4 (mit Tischwert mal Pech, mal Erfolg) und Salz.
WuerfelQuelle _strom(int i, String salz) => switch (i % 4) {
      0 => const FesterWuerfel.pech(),
      1 => const FesterWuerfel.erfolg(),
      2 => const FesterWuerfel.neutral(),
      _ => SalzWuerfel(salz),
    };

/// Prüft einen fertigen Abend: Budget, Wertung, Endwert, Ende; bestes Spiel endet als Meister.
void _pruefe(RundenPartie p, String pfad, List<String> folge, String grund) {
  final erm = einflussErmittlung;
  final s = p.spiel;
  expect(p.restJeRunde, hasLength(3), reason: grund);
  expect(p.restJeRunde.every((r) => r >= 0), isTrue, reason: '$grund: Budget ${p.restJeRunde}');
  expect(p.wuerfe.every((w) => w.anlauf <= 3 && w.mod >= -2 && w.mod <= 3), isTrue, reason: grund);
  final klassisch = [for (final e in erm.entscheidungen) if (erm.istRichtig(e.id, s.gewaehlt[e.id]!, pfad)) e].length;
  expect(s.punkte, greaterThanOrEqualTo(klassisch), reason: '$grund: Geklärt hebt nur an');
  final bonus = p.einfluss!.stand.tischbonus;
  expect(s.endwert, (s.punkte + bonus).clamp(0, 9), reason: grund);
  expect(s.ende.id, s.enden.ende(s.endwert, s.angeklagt == pfad).id, reason: grund);
  expect(s.ende.richtig, s.angeklagt == pfad, reason: '$grund: die Anklage bestimmt richtig oder falsch');
  if (_gleich(folge, erm.bestesSpiel(pfad)) && s.angeklagt == pfad) {
    expect(s.punkte, 9, reason: grund);
    expect(s.ende.id, 'ende_meister', reason: '$grund: bestes Spiel → Meister');
  }
}

bool _gleich(List<String> a, List<String> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

/// Wacht während des Abends: Restminuten nie negativ.
void _budget(String art, Map<String, Object?> d, RundenPartie p) {
  if (p.restMinuten < 0) fail('Budget überschritten nach $art: ${p.restMinuten} (Runde ${p.runde})');
}

void main() {
  final folgen = Simulator(kanon).folgen().toList();

  test('768 Wahlfolgen, Würfelströme und Profile', () {
    expect(folgen, hasLength(768));
    expect(Tischprofil.values, hasLength(4));
  });

  test('Bestes Spiel → Meister: 4 Pfade × n = 4–20 × 4 Profile × 4 Ströme × 2 Rufe', () {
    var abende = 0;
    for (final pfad in kanon.pfade) {
      final best = einflussErmittlung.bestesSpiel(pfad);
      for (var n = 4; n <= 20; n++) {
        for (final profil in Tischprofil.values) {
          for (var strom = 0; strom < 4; strom++) {
            for (final ruf in Tischruf.values) {
              final salz = 'tb-best:$pfad:$n:${profil.name}:$strom:${ruf.name}';
              final p = spieleEinflussAbend(
                pfad: pfad, rollen: n, folge: best, quelle: _strom(strom, salz), salz: salz, profil: profil,
                weise: Detektivweise.fest(ruf, gruendlich: ruf == Tischruf.umweg), beobachter: _budget,
              );
              _pruefe(p, pfad, best, salz);
              expect(p.spiel.ende.id, 'ende_meister', reason: salz);
              abende++;
            }
          }
        }
      }
    }
    expect(abende, 4 * 17 * 4 * 4 * 2);
  });

  for (final (pi, pfad) in kanon.pfade.indexed) {
    test('Pfad $pfad: 768 Folgen × {stützen, stören, Bots} × n ∈ {4, 7, 12, 20} × 4 Ströme; Auspacken und freie Bot-Tische', () {
      var abende = 0;
      for (final (fi, folge) in folgen.indexed) {
        for (final profil in const [Tischprofil.stuetzen, Tischprofil.stoeren, Tischprofil.bots]) {
          for (final (ni, n) in _n.indexed) {
            for (var strom = 0; strom < 4; strom++) {
              final salz = 'tb:$pfad:$fi:${profil.name}:$n:$strom';
              final k = fi + ni + strom;
              final p = spieleEinflussAbend(
                pfad: pfad, rollen: n, folge: folge, quelle: _strom(strom, salz), salz: salz, profil: profil,
                weise: Detektivweise.fest(k.isEven ? Tischruf.umweg : Tischruf.nochmal, gruendlich: k % 3 == 0),
                anklage: k % 5 == 0 ? kanon.kernverdaechtige[(k ~/ 5) % 4] : pfad,
                beobachter: _budget,
              );
              _pruefe(p, pfad, folge, salz);
              abende++;
            }
          }
        }
        // Alle packen in Runde 1 aus (n reihum); Bot-Tisch mit Salz-Würfeln und freier Strategie (n = 4–20).
        final salzA = 'tb-auspacken:$pfad:$fi';
        _pruefe(
          spieleEinflussAbend(
            pfad: pfad, rollen: _n[(fi + pi) % 4], folge: folge, quelle: _strom(fi + pi, salzA), salz: salzA,
            profil: Tischprofil.auspacken, weise: Detektivweise.fest(fi.isEven ? Tischruf.umweg : Tischruf.nochmal), beobachter: _budget,
          ),
          pfad, folge, salzA,
        );
        final salzB = 'tb-frei:$pfad:$fi';
        _pruefe(
          spieleEinflussAbend(
            pfad: pfad, rollen: 4 + (fi + pi) % 17, folge: folge, quelle: SalzWuerfel(salzB), salz: salzB,
            weise: Detektivweise.strom(Rng(Rng.hashString('tb-weise:$salzB'))), beobachter: _budget,
          ),
          pfad, folge, salzB,
        );
        abende += 2;
      }
      expect(abende, 768 * (3 * 4 * 4 + 2));
    }, timeout: const Timeout(Duration(minutes: 4)));
  }
}
