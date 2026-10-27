// Ende mit Einfluss-Schicht (Finale §3.10, T-K): Endwert = clamp(Punkte + Tischbonus, 0, 9) in der Matrix aus
// fall.json; richtig oder falsch bestimmt allein die Anklage (die Klasse bleibt). Alle Punkte × Tischbonus ×
// Anklage über alle 768 Wahlfolgen und 4 Pfade; Geklärt-Regel (hebt nur an); Tischbonus aus den Leisten am
// echten Abend mit Bausteinen des Endes; Erfahrung nur mit Schicht.
@TestOn('vm')
library;

import 'package:mordakte_core/mordakte_core.dart';
import 'package:mordakte_core/runden.dart';
import 'package:test/test.dart';

import '../party/kanon_hilfe.dart';
import 'einfluss_hilfe.dart';
import 'einfluss_lauf.dart';

/// Zusatz mit festem Tischbonus, sonst neutral (Gruppenwahl wie heute).
class _FesterBonus implements SpielZusatz {
  @override
  final int tischbonus;
  _FesterBonus(this.tischbonus);
  @override
  Set<String> sichtbar(Spiel s, int bis) => s.bekannteFakten(bis);
  @override
  Set<String> geliefert(int bis) => const {};
  @override
  List<String> nachWechsel(Spiel s, PartyPhase von) => const [];
  @override
  bool get ueberspringeGruppenwahl => false;
  @override
  Qualitaet? bonusQualitaet(int runde) => null;
  @override
  bool nachgereichtIn(int runde) => false;
}

Ermittlung get _erm => einflussErmittlung;

/// Ein Druck-freier Abend über das reine Spiel mit [zusatz] (Gruppenwahl immer wahr).
Spiel _spiel(String pfad, List<String> folge, String anklage, SpielZusatz? zusatz) {
  final s = Spiel(kanon, ermittlung: _erm)
    ..einrichten(Einstellungen(rollen: 6, detektiv: 'w', code: FallCode.fuerPfad(pfad, kanon.pfade)))
    ..zusatz = zusatz;
  var i = 0;
  while (s.phase != PartyPhase.ende) {
    if (s.phase == PartyPhase.entscheidungen) {
      for (final e in _erm.runde(s.runde)) {
        s.waehle(e.id, folge[_erm.entscheidungen.indexOf(e)]);
        i++;
      }
    }
    if (s.phase == PartyPhase.gruppenwahl) s.abstimmen(kooperativ: 5, taeterSabotiert: false);
    if (s.phase == PartyPhase.anklage) s.anklagen(anklage);
    s.weiter();
  }
  expect(i, 9);
  return s;
}

void main() {
  final folgen = Simulator(kanon).folgen().toList();
  final enden = Enden(kanon);

  test('Matrix: jeder Endwert 0 … 9 × Anklage hat genau ein Ende; Klasse = Anklage', () {
    for (var punkte = 0; punkte <= 9; punkte++) {
      for (final bonus in [-1, 0, 1]) {
        final w = (punkte + bonus).clamp(0, 9);
        for (final richtig in [true, false]) {
          expect(enden.passend(w, richtig), hasLength(1));
          expect(enden.ende(w, richtig).richtig, richtig);
        }
      }
    }
    expect(endwertAus(einflussRegeln.zahlen, punkte: 9, tischbonus: 1), 9);
    expect(endwertAus(einflussRegeln.zahlen, punkte: 0, tischbonus: -1), 0);
  });

  test('Alle Punkte × Tischbonus × Anklage über 768 Folgen und 4 Pfade: Endwert, Ende, Klasse bleibt', () {
    final punkteGesehen = <int>{};
    var abende = 0;
    for (final pfad in kanon.pfade) {
      for (final (fi, folge) in folgen.indexed) {
        final anklage = kanon.kernverdaechtige[fi % 4];
        final ohne = _spiel(pfad, folge, anklage, null);
        punkteGesehen.add(ohne.punkte);
        for (final bonus in [-1, 0, 1]) {
          final mit = _spiel(pfad, folge, anklage, _FesterBonus(bonus));
          expect(mit.punkte, ohne.punkte, reason: 'Punkte roh, ohne Auspacken keine Geklärt-Regel');
          expect(mit.endwert, (ohne.punkte + bonus).clamp(0, 9));
          expect(mit.ende.id, enden.ende(mit.endwert, anklage == pfad).id);
          expect(mit.ende.richtig, ohne.ende.richtig, reason: 'Klasse bleibt: nur die Anklage bestimmt richtig/falsch');
          if (bonus == 0) expect(mit.ende.id, ohne.ende.id);
          expect(mit.bausteine.where((b) => b.startsWith('einfluss.tischbonus.')), bonus == 0 ? isEmpty : ['einfluss.tischbonus.${bonus > 0 ? 'plus' : 'minus'}']);
          abende++;
        }
      }
    }
    expect(punkteGesehen, containsAll([for (var p = 0; p <= 9; p++) p]), reason: 'alle Punkte kommen vor');
    expect(abende, 4 * 768 * 3);
  }, timeout: const Timeout(Duration(minutes: 2)));

  test('Ohne Zusatz: Endwert = Punkte, Ende wie die Matrix, keine Geklärt-Regel', () {
    final s = _spiel('olli', folgen[123], 'olli', null);
    expect(s.endwert, s.punkte);
    expect(s.ende.id, enden.ende(s.punkte, true).id);
    for (final e in _erm.entscheidungen) {
      expect(s.geklaert(e.id), isFalse);
    }
  });

  group('Geklärt-Regel', () {
    for (final (pfad, falsch) in const [('ahmet', 'e3_3_aylin'), ('fatma', 'e3_3_aylin'), ('olli', 'e3_3_aylin'), ('can', 'e3_3_zeynep')]) {
      test('Pfad $pfad: Ausgepacktes klärt e3_3 vor dem Öffnen; $falsch zählt trotzdem (hebt nur an)', () {
        final folge = [for (final e in _erm.entscheidungen) e.id == 'e3_3' ? falsch : e.richtig[pfad]!];
        final mit = spieleEinflussAbend(pfad: pfad, rollen: 20, folge: folge, quelle: const FesterWuerfel.erfolg(), salz: 'geklaert:$pfad', profil: Tischprofil.auspacken);
        final soll = _erm.faktenVon(_erm.entscheidung('e3_3').richtig[pfad]!, pfad);
        expect(soll, isNotEmpty);
        expect(mit.einfluss!.geliefert(1), containsAll(soll));
        expect(mit.spiel.geklaert('e3_3'), isTrue);
        expect(mit.spiel.punkte, 9);
        expect(mit.spiel.ende.id, 'ende_meister');
        // Ohne die Auspackenden (n = 9: weder Zeynep noch Aylin besetzt) bleibt es bei 8 Punkten.
        final ohne = spieleEinflussAbend(pfad: pfad, rollen: 9, folge: folge, quelle: const FesterWuerfel.erfolg(), salz: 'geklaert:$pfad', profil: Tischprofil.auspacken);
        expect(ohne.spiel.geklaert('e3_3'), isFalse);
        expect(ohne.spiel.punkte, 8);
        // Eine richtige Wahl bleibt richtig, geklärt oder nicht.
        final best = spieleEinflussAbend(pfad: pfad, rollen: 20, folge: _erm.bestesSpiel(pfad), quelle: const FesterWuerfel.erfolg(), salz: 'geklaert-b:$pfad', profil: Tischprofil.auspacken);
        expect(best.spiel.punkte, 9);
      });
    }

    test('Geklärt hebt über alle Folgen nur an, genau nach der Regel; ohne Auspacken nie', () {
      final sim = Simulator(kanon);
      for (final pfad in kanon.pfade) {
        for (final (fi, folge) in folgen.indexed) {
          if (fi % 8 != 0) continue;
          for (final profil in const [Tischprofil.auspacken, Tischprofil.stuetzen]) {
            final p = spieleEinflussAbend(pfad: pfad, rollen: 20, folge: folge, quelle: SalzWuerfel('g$fi'), salz: 'g$fi', profil: profil);
            final s = p.spiel;
            var extra = 0;
            for (final e in _erm.entscheidungen) {
              final richtig = _erm.istRichtig(e.id, s.gewaehlt[e.id]!, pfad);
              final soll = _erm.faktenVon(e.richtig[pfad]!, pfad);
              final geklaert = soll.isNotEmpty && p.einfluss!.geliefert(e.runde).containsAll(soll);
              expect(s.geklaert(e.id), geklaert, reason: '$pfad $fi ${e.id}');
              if (!richtig && geklaert) extra++;
            }
            expect(s.punkte, sim.verlauf(pfad, folge).punkte + extra);
            if (profil == Tischprofil.stuetzen) expect(extra, 0, reason: 'ohne Auspacken nichts geklärt');
          }
        }
      }
    });
  });

  group('Tischbonus aus den Leisten am echten Abend', () {
    test('Zusammenhalt ≥ 4: +1 (warmer Morgen); Spuk ≥ 4: −1 (chaotisch); Bausteine von Finale und Auflösung', () {
      for (final (profil, bonus, morgen) in const [(Tischprofil.auspacken, 1, 'warm'), (Tischprofil.stuetzen, -1, 'chaotisch')]) {
        final p = spieleEinflussAbend(
          pfad: 'fatma', rollen: 10, folge: _erm.bestesSpiel('fatma'), quelle: const FesterWuerfel.neutral(), salz: 'bonus:${profil.name}', profil: profil,
        );
        final e = p.einfluss!;
        expect(e.stand.tischbonus, bonus, reason: profil.name);
        expect(p.spiel.endwert, (9 + bonus).clamp(0, 9));
        expect(p.spiel.ende.id, 'ende_meister');
        final b = p.spiel.bausteine;
        final fin = b.indexOf('finale.fatma.ende_meister');
        expect(b[fin - 1], 'einfluss.tischbonus.${bonus > 0 ? 'plus' : 'minus'}');
        final ab = b.indexWhere((x) => x.startsWith('aufloesung.gruppe.'));
        final ende = b.sublist(ab);
        final sterne = e.sterne();
        expect([for (final x in ende) if (x.startsWith('einfluss.epilog.')) x],
            [for (final f in p.spiel.besetzt) 'einfluss.epilog.$f.${sterne[f]! >= 1 ? 'erreicht' : 'verfehlt'}']);
        final a = e.auszeichnungen();
        expect(ende, contains(einflussBaustein('einfluss.preis.stern', figur: a.stern!)));
        expect(ende.last, 'einfluss.morgen.$morgen');
        expect(e.stand.morgen.name, morgen);
      }
    });

    test('Spürnasen erst ab dem Finale; Sterne und Auszeichnungen aus dem Protokoll; Erfahrung nur mit Schicht', () {
      final p = spieleEinflussAbend(pfad: 'can', rollen: 8, folge: _erm.bestesSpiel('can'), quelle: const SalzWuerfel('nase'), salz: 'nase');
      final e = p.einfluss!;
      final prot = e.protokoll();
      expect(prot.fertig, isTrue);
      expect(prot.aufloesung, 'can');
      expect(prot.rest, p.restJeRunde[2]);
      final a = e.auszeichnungen();
      expect(a.spuernasen, [for (final r in p.spiel.besetzt) if (e.stand.tipps[r] == 'can') r]);
      for (final r in p.spiel.besetzt) {
        final xp = EinflussErfahrung(sterne: e.sterne()[r]!, sternDesAbends: a.stern == r, spuernase: a.spuernasen.contains(r));
        expect(xp.xp, 15 * e.sterne()[r]! + (a.stern == r ? 25 : 0) + (a.spuernasen.contains(r) ? 10 : 0));
        expect(xpFuer(p.spiel.ende.id, einfluss: xp), xpFuer(p.spiel.ende.id) + xp.xp);
      }
      expect(xpFuer('ende_meister'), 300, reason: 'ohne Schicht wie bisher');
      const ergebnis = AbendErgebnis(akte: 'schlosskeller', salz: 's', spielerId: 'x', rolle: 'olli', pfad: 'can', anklageRichtig: true, ende: 'ende_teilerfolg');
      expect(ergebnis.xp, 200);
      const mit = AbendErgebnis(
        akte: 'schlosskeller', salz: 's', spielerId: 'x', rolle: 'olli', pfad: 'can', anklageRichtig: true, ende: 'ende_teilerfolg',
        einfluss: EinflussErfahrung(sterne: 2, sternDesAbends: true, spuernase: true),
      );
      expect(mit.xp, 200 + 30 + 25 + 10);
    });
  });
}
