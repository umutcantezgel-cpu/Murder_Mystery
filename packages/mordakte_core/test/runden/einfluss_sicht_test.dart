// T-W Wahrheit und T-L Lösbarkeit mit Einfluss-Schicht (Finale §3.4–§3.6, §4): Sichtbare Fakten sind stets
// Fakten des Pfads, der Täter wird nie entlastet; beim Öffnen jeder Entscheidung ist alles sichtbar, was
// frühere Runden fanden (bei bestem Spiel jeder Begründungsfakt früherer Runden), dazu das Ausgepackte
// der Runde; im Zwischenresümee alles der Runde, bei der Anklage alles. Über 4 Pfade × 768 Wahlfolgen ×
// 4 Zugprofile (n und Würfelstrom reihum) und Bot-Tische mit freier Strategie.
@TestOn('vm')
library;

import 'package:mordakte_core/mordakte_core.dart';
import 'package:mordakte_core/runden.dart';
import 'package:test/test.dart';

import '../party/kanon_hilfe.dart';
import 'einfluss_hilfe.dart';
import 'einfluss_lauf.dart';

Ermittlung get _erm => einflussErmittlung;

WuerfelQuelle _strom(int i, String salz) => switch (i % 4) {
      0 => const FesterWuerfel.pech(),
      1 => const FesterWuerfel.erfolg(),
      2 => const FesterWuerfel.neutral(),
      _ => SalzWuerfel(salz),
    };

/// Begründungsfakten von [e] im [pfad], die bei bestem Spiel eine frühere Runde liefert.
Set<String> _begruendungFrueher(Entscheidung e, String pfad) {
  final frueher = {
    for (final x in _erm.entscheidungen)
      if (x.runde < e.runde) ..._erm.faktenVon(x.richtig[pfad]!, pfad),
  };
  return {
    for (final k in e.begruendungFuer(pfad)!.kette)
      if (k.startsWith('fakt:') && frueher.contains(k.substring(5))) k.substring(5),
  };
}

/// Ein Abend mit allen Prüfungen T-W und T-L; gibt die Zahl der geprüften Öffnungen zurück.
int _abend(String pfad, int n, List<String> folge, WuerfelQuelle q, String salz, Tischprofil profil, Detektivweise weise) {
  final best = _gleich(folge, _erm.bestesSpiel(pfad));
  var oeffnungen = 0;
  void wahr(RundenPartie p, String wo) {
    final sichtbar = p.fakten;
    for (final f in sichtbar) {
      if (!_erm.gibtEs(f, pfad)) fail('$salz $wo: $f gibt es im Pfad $pfad nicht');
    }
    if (!p.spiel.restmenge().contains(pfad)) fail('$salz $wo: Täter $pfad entlastet (${p.spiel.restmenge()})');
  }

  spieleEinflussAbend(
    pfad: pfad,
    rollen: n,
    folge: folge,
    quelle: q,
    salz: salz,
    profil: profil,
    weise: weise,
    vorOeffnen: (p, e) {
      oeffnungen++;
      wahr(p, 'vor ${e.id}');
      final sichtbar = p.fakten;
      final frueher = p.spiel.bekannteFakten(e.runde - 1);
      if (!sichtbar.containsAll(frueher)) fail('$salz vor ${e.id}: Funde früherer Runden fehlen: ${frueher.difference(sichtbar)}');
      final geliefert = p.einfluss!.geliefert(e.runde);
      if (!sichtbar.containsAll(geliefert)) fail('$salz vor ${e.id}: Ausgepacktes fehlt: ${geliefert.difference(sichtbar)}');
      if (best) {
        final soll = _begruendungFrueher(e, pfad);
        if (!sichtbar.containsAll(soll)) fail('$salz vor ${e.id}: Begründung früherer Runden fehlt: ${soll.difference(sichtbar)}');
      }
    },
    beobachter: (art, d, p) {
      if (art != 'weiter') return;
      wahr(p, '${p.phase.name}/${p.runde}');
      if (p.phase == PartyPhase.resuemee) {
        final runde = p.spiel.bekannteFakten(p.runde);
        if (!p.spiel.sichtbareFakten(p.runde).containsAll(runde)) fail('$salz: Zwischenresümee ${p.runde} ohne alle Funde');
      }
      if (p.phase == PartyPhase.anklage) {
        final alle = p.spiel.bekannteFakten();
        if (!p.fakten.containsAll(alle)) fail('$salz: bei der Anklage fehlt ${alle.difference(p.fakten)}');
        if (best && p.spiel.restmenge().length != 1) fail('$salz: bestes Spiel lässt ${p.spiel.restmenge()} übrig');
      }
    },
  );
  return oeffnungen;
}

bool _gleich(List<String> a, List<String> b) => a.length == b.length && [for (var i = 0; i < a.length; i++) a[i] == b[i]].every((x) => x);

void main() {
  final folgen = Simulator(kanon).folgen().toList();

  for (final (pi, pfad) in kanon.pfade.indexed) {
    test('Pfad $pfad: 768 Folgen × 4 Profile, n und Strom reihum (T-W, T-L)', () {
      var oeffnungen = 0;
      for (final (fi, folge) in folgen.indexed) {
        for (final (ti, profil) in Tischprofil.values.indexed) {
          final k = fi + ti + pi;
          final salz = 'sicht:$pfad:$fi:${profil.name}';
          oeffnungen += _abend(pfad, 4 + k % 17, folge, _strom(k, salz), salz, profil,
              Detektivweise.fest(k.isEven ? Tischruf.umweg : Tischruf.nochmal, gruendlich: k % 3 == 0));
        }
      }
      expect(oeffnungen, 768 * 4 * 9);
    }, timeout: const Timeout(Duration(minutes: 3)));
  }

  test('Bestes Spiel × alle Profile × n = 4–20 × 4 Ströme: Begründung früherer Runden stets sichtbar', () {
    for (final pfad in kanon.pfade) {
      final best = _erm.bestesSpiel(pfad);
      for (var n = 4; n <= 20; n++) {
        for (final profil in Tischprofil.values) {
          for (var strom = 0; strom < 4; strom++) {
            final salz = 'sicht-best:$pfad:$n:${profil.name}:$strom';
            _abend(pfad, n, best, _strom(strom, salz), salz, profil, Detektivweise.strom(Rng(Rng.hashString(salz))));
          }
        }
      }
    }
  });

  test('Ausgepackte Nebendelikte: Unschuldige mit Alibi scheiden aus, der Täter nie', () {
    for (final pfad in kanon.pfade) {
      // Volle Besetzung, alle packen in Runde 1 aus; bestes Spiel liefert die Alibis.
      final p = spieleEinflussAbend(
        pfad: pfad, rollen: 20, folge: _erm.bestesSpiel(pfad), quelle: const FesterWuerfel.erfolg(), salz: 'nd:$pfad',
        profil: Tischprofil.auspacken,
        vorOeffnen: (p, e) {
          if (e.id == 'e2_1') {
            final nd = {for (final k in _erm.kern) 'f_nd_${k == 'can' ? 'can_maske' : k == 'ahmet' ? 'ahmet_umschlag' : k}'};
            expect(p.fakten, containsAll(nd), reason: 'alle vier Nebendelikte ausgepackt');
            final rest = p.spiel.restmenge();
            expect(rest, contains(pfad));
            for (final k in _erm.kern) {
              final alibi = 'f_alibi_$k';
              if (k != pfad && p.fakten.contains(alibi)) expect(rest, isNot(contains(k)), reason: '$k hat Alibi und Nebendelikt');
            }
          }
        },
      );
      expect(p.spiel.restmenge(), {pfad});
      expect(p.spiel.ende.id, 'ende_meister');
    }
  });
}
