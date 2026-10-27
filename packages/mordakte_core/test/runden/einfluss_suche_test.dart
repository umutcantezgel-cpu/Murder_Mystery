// Suche und Befragung mit Tischwert (Finale §3.4, §3.5, §3.8): erschöpfend je Suchoption × T ∈ {−2..2} ×
// Grundwert × Würfelfolge × Tischruf an der Zugschicht (≤ 3 Anläufe, Kosten ≤ 14, Modifikator-Klemme,
// Verwischt, Zusatzfund, Ertappt, Fakten am Ende = Fakten der Option), dazu dieselben Regeln an ganzen
// Partien: Ertappt aus dem Strom, Randnotizen, Fledermaus, Kerzenschein, Befragung redselig/zögert/mauert.
import 'package:mordakte_core/mordakte_core.dart';
import 'package:mordakte_core/runden.dart';
import 'package:test/test.dart';

import '../party/kanon_hilfe.dart';
import 'einfluss_hilfe.dart';

/// Würfel mit festem Skript je Entscheidung: E 6+6 (immer Erfolg), M 3+4 (Summe 7, Stufe nach Modifikator),
/// P 1+1 (immer Pech); andere Würfe neutral 3+4.
class _Skript implements WuerfelQuelle {
  final String id;
  final String folge;
  const _Skript(this.id, this.folge);
  @override
  (int, int) augen(String i, int anlauf) {
    if (i != id || anlauf > folge.length) return (3, 4);
    return switch (folge[anlauf - 1]) { 'E' => (6, 6), 'P' => (1, 1), _ => (3, 4) };
  }
}

/// Alle Würfelfolgen der Länge 3 aus E, M, P.
final _folgen = [
  for (final a in 'EMP'.split(''))
    for (final b in 'EMP'.split(''))
      for (final c in 'EMP'.split('')) '$a$b$c',
];

EinflussRegeln get _r => einflussRegeln;
Ermittlung get _erm => einflussErmittlung;
final _p = einflussZugParameter(einflussRegeln.zahlen);

/// Erwarteter Modifikator eines Anlaufs (§3.4): clamp(basis + T + u, −2, +3), nach einem Umweg ohne
/// negatives T; ohne T und u genau basis.
int _sollMod(int basis, int t, {required bool nachUmweg}) {
  final tw = nachUmweg && t < 0 ? 0 : t;
  final u = nachUmweg ? 1 : 0;
  if (tw == 0 && u == 0) return basis;
  final m = basis + tw + u;
  return m < -2 ? -2 : (m > 3 ? 3 : m);
}

void main() {
  test('Würfel-Haken: gesamt(basis, 0) ist basis; sonst Klemme; Parameter aus einfluss.json', () {
    for (var basis = -3; basis <= 5; basis++) {
      expect(WuerfelRegel.gesamt(basis, 0, boden: -2, deckel: 3), basis);
      for (var extra = -4; extra <= 4; extra++) {
        if (extra == 0) continue;
        expect(WuerfelRegel.gesamt(basis, extra, boden: -2, deckel: 3), (basis + extra).clamp(-2, 3));
        expect(WuerfelRegel.gesamt(basis, extra, boden: -2, deckel: 3), _r.zahlen.suchModifikator(basis, tisch: extra));
      }
    }
    expect([_p.rundenzeit, _p.modBoden, _p.modDeckel, _p.umwegBonus, _p.uebertragHoechstens, _p.minutenBoden, _p.zoegert, _p.mauert], [45, -2, 3, 1, 5, 42, 3, 3]);
    expect(_p.schlechtesterPflichtzug, 14);
    expect(_p.minutenBoden, greaterThanOrEqualTo(3 * _p.schlechtesterPflichtzug), reason: 'Boden 42 deckt drei schlechteste Pflichtzüge');
    const neutral = ZugParameter();
    expect([neutral.modBoden, neutral.modDeckel, neutral.umwegBonus, neutral.uebertragHoechstens, neutral.minutenBoden, neutral.zoegert, neutral.mauert],
        [0, WuerfelRegel.modMax, 0, 0, 0, 0, 0], reason: 'Standard = alt');
  });

  test('Vollständig: jede Suchoption × T ∈ {−2..2} × Grundwert × Würfelfolge × Tischrufe (4 Pfade)', () {
    final suchen = [for (final e in _erm.entscheidungen) if (istSuche(e)) e];
    expect(suchen.map((e) => e.id), ['e2_1', 'e2_2', 'e2_3', 'e3_1', 'e3_2']);
    var faelle = 0;
    for (final e in suchen) {
      for (final o in e.optionen) {
        for (var t = -2; t <= 2; t++) {
          for (final (werkzeug, gruendlich) in const [(false, false), (true, false), (false, true), (true, true)]) {
            for (final folge in _folgen) {
              for (final rufe in const [
                [Tischruf.nochmal, Tischruf.nochmal],
                [Tischruf.nochmal, Tischruf.umweg],
                [Tischruf.umweg, Tischruf.nochmal],
                [Tischruf.umweg, Tischruf.umweg],
              ]) {
                // Die Würfel kennen den Pfad nicht; die Fälle laufen reihum durch alle vier Pfade.
                final pfad = kanon.pfade[faelle++ % kanon.pfade.length];
                _suche(pfad, e, o.id, t, werkzeug: werkzeug, gruendlich: gruendlich, folge: folge, rufe: rufe);
              }
            }
          }
        }
      }
    }
    expect(faelle, 11 * 5 * 4 * 27 * 4);
  });

  test('Befragung: T ≤ −2 kostet „mauert“, T = −1 „zögert“, sonst wie heute; ohne Würfel', () {
    for (var t = -2; t <= 2; t++) {
      final z = Zugschicht(_erm, const FesterWuerfel.neutral(), p: _p)..setzePfad('olli');
      z.beginneRunde(1, zusatzMinuten: 0);
      expect(z.rest, 45);
      final vor = z.rest;
      expect(z.waehle('e1_1_damir', tisch: t), isFalse);
      expect(vor - z.rest, 6 + (t <= -2 ? 3 : (t == -1 ? 3 : 0)), reason: 'T = $t');
      expect(z.wuerfe, isEmpty);
      expect(z.fakten, _erm.faktenVon('e1_1_damir', 'olli'));
    }
  });

  test('Rundenbudget mit Schicht: Übertrag ≤ 5 ab Runde 2, Änderungen, Boden 42; ohne Schicht 45', () {
    final ohne = Zugschicht(_erm, const FesterWuerfel.erfolg())..setzePfad('ahmet');
    final mit = Zugschicht(_erm, const FesterWuerfel.erfolg(), p: _p)..setzePfad('ahmet');
    for (final (runde, zusatz) in [(1, -16), (2, 14), (3, -3)]) {
      ohne.beginneRunde(runde);
      mit.beginneRunde(runde, zusatzMinuten: zusatz);
      expect(ohne.rest, 45);
      final vorher = mit.restJeRunde.isEmpty ? 0 : mit.restJeRunde.last;
      final soll = runde == 1 ? 45 + zusatz : 45 + (vorher > 5 ? 5 : vorher) + zusatz;
      expect(mit.rest, soll < 42 ? 42 : soll, reason: 'Runde $runde');
      for (final z in [ohne, mit]) {
        if (runde == 1) z.auftakt();
        while (z.offen.isNotEmpty) {
          if (z.waehle(_erm.entscheidung(z.offen.first).richtig['ahmet']!)) {
            while (z.untersuchungOffen) {
              z.anlauf();
            }
          }
        }
        z.beendeRunde();
      }
    }
    expect(ohne.restJeRunde.every((r) => r >= 0), isTrue);
    expect(mit.restJeRunde.every((r) => r >= 0), isTrue);
  });

  test('Marke mit Tischwert: wirkt nur, wenn sie den Modifikator noch hebt (Deckel +3)', () {
    final z = Zugschicht(_erm, const _Skript('e2_1', 'MMM'), p: _p)..setzePfad('can');
    z.beginneRunde(1, zusatzMinuten: 0);
    z.markeGutschrift();
    z.markeGutschrift();
    while (z.offen.isNotEmpty) {
      z.waehle(_erm.entscheidung(z.offen.first).optionen.first.id);
    }
    z.beendeRunde();
    z.beginneRunde(2, zusatzMinuten: 0);
    expect(z.waehle('e2_1_ascheneimer', tisch: 2, gruendlich: true), isTrue);
    final v = z.vorschau(marke: true);
    expect([v.mod, v.markeWirkt], [3, false], reason: 'gründlich +2 und T +2 liegen schon am Deckel');
    expect(z.tischAnteil(), (tisch: 2, umweg: 0));
    final w = z.anlauf(marke: true);
    expect([w.mod, z.markenBestand], [3, 2]);
    expect(z.kennzeichen['e2_1']!.stufe, Stufe.erfolg);
    z.waehle('e2_2_tasche', tisch: -1);
    final v2 = z.vorschau(marke: true);
    expect([v2.mod, v2.markeWirkt], [0, true], reason: 'Marke hebt −1 auf 0');
    expect(z.anlauf(marke: true).mod, 0);
    expect(z.markenBestand, 1);
  });

  group('An ganzen Partien (n = 4: m(n) = 1)', () {
    RundenPartie partie(String pfad, WuerfelQuelle q, {String salz = 'suche'}) =>
        RundenPartie(kanon, quelle: q, ermittlung: _erm, einfluss: _r, salz: salz)
          ..einrichten(Einstellungen(rollen: 4, detektiv: 'w', code: FallCode.fuerPfad(pfad, kanon.pfade)));

    /// Spielt bis zu den Gesprächen von [runde]; vorher bestes Spiel, alle helfen.
    void bisGespraeche(RundenPartie p, int runde, String pfad) {
      while (!(p.phase == PartyPhase.gespraeche && p.runde == runde)) {
        if (p.zug case final z?) {
          switch (z.phase) {
            case RundenZugPhase.aktion:
              p.aktionFertig(z.aktion);
            case RundenZugPhase.wurf:
              p.wuerfeln();
            case RundenZugPhase.tischruf:
              p.tischruf(Tischruf.nochmal);
            case RundenZugPhase.fund:
              p.fundGelesen();
          }
        } else if (p.naechsteEntscheidung case final e?) {
          p.waehle(e.richtig[pfad]!);
        } else {
          if (p.phase == PartyPhase.gespraeche) {
            for (final r in p.spiel.besetzt) {
              p.zugSetzen(r, ZugArt.abgewartet);
            }
          }
          p.weiter();
        }
      }
    }

    void zugBisFund(RundenPartie p, {Tischruf ruf = Tischruf.nochmal}) {
      while (p.zug!.phase != RundenZugPhase.fund) {
        final z = p.zug!;
        switch (z.phase) {
          case RundenZugPhase.aktion:
            p.aktionFertig(z.aktion);
          case RundenZugPhase.wurf:
            p.wuerfeln();
          case RundenZugPhase.tischruf:
            expect(z.verwischt, isTrue, reason: 'Pech: Die Spur verwischt');
            p.tischruf(ruf);
          case RundenZugPhase.fund:
            break;
        }
      }
    }

    test('Erfolg auf gedeckter Option: Zusatzfund und Ertappt aus ertappt:<salz>:<id>; Erfolg zählt', () {
      final p = partie('ahmet', const FesterWuerfel.erfolg(), salz: 'ertappt-probe');
      bisGespraeche(p, 2, 'ahmet');
      p.zugSetzen('fatma', ZugArt.decken, ziel: 'ahmet');
      p.zugSetzen('olli', ZugArt.decken, ziel: 'ahmet');
      p.zugSetzen('ahmet', ZugArt.zeigen, ziel: 'can');
      p.zugSetzen('can', ZugArt.abgewartet);
      p.weiter();
      expect(p.tisch('e2_1_ascheneimer'), -2);
      expect(p.tisch('e2_1_bauchtasche'), 1);
      p.waehle('e2_1_ascheneimer');
      expect(p.zug!.tisch, -2);
      zugBisFund(p);
      final f = p.zug!.einfluss!;
      expect(p.wuerfe.last.mod, -2, reason: '0 + T −2');
      expect(p.wuerfe.last.stufe, Stufe.erfolg);
      expect(f.randnotizen, ['b_hana_umschlag']);
      final soll = ertapptAuswahl(salz: 'ertappt-probe', entscheidung: 'e2_1', decker: const ['fatma', 'olli']);
      expect(f.ertappt, soll);
      expect(f.ertapptZiel, 'ahmet');
      expect(p.einfluss!.stand.ertappt, {soll!: 1});
      expect(p.einfluss!.stand.protokoll().erfolge, {2: ['e2_1_ascheneimer']});
      expect([f.verwischt, f.verzoegert], [false, false]);
      expect(p.fakten, containsAll(_erm.faktenVon('e2_1_ascheneimer', 'ahmet')));
    });

    test('Teilerfolg: nur der Fund; Pech → Umweg: +1, negatives T zählt nicht, kein Zusatzfund, Fakten erst im Resümee', () {
      final p = partie('fatma', const _Skript('e2_1', 'PM'));
      bisGespraeche(p, 2, 'fatma');
      p.zugSetzen('fatma', ZugArt.decken, ziel: 'ahmet');
      p.zugSetzen('olli', ZugArt.decken, ziel: 'ahmet');
      p.zugSetzen('ahmet', ZugArt.helfen);
      p.zugSetzen('can', ZugArt.helfen);
      p.weiter();
      final t = p.tisch('e2_1_ascheneimer')!;
      expect(t, -2);
      final vorher = p.fakten;
      p.waehle('e2_1_ascheneimer');
      p.aktionFertig(p.zug!.aktion);
      expect(p.tischVorschau(), (tisch: t, umweg: 0));
      expect(p.wuerfeln().stufe, Stufe.pech);
      expect(p.zug!.verwischt, isTrue);
      p.tischruf(Tischruf.umweg);
      p.aktionFertig(p.zug!.aktion);
      expect(p.tischVorschau(), (tisch: 0, umweg: 1));
      final w = p.wuerfeln();
      expect([w.mod, w.stufe], [1, Stufe.teilerfolg], reason: 'M 3+4 + 1 = 8');
      final f = p.zug!.einfluss!;
      expect([f.verwischt, f.verzoegert, f.randnotizen, f.ertappt], [true, true, isEmpty, isNull]);
      expect(p.zug!.funde, isEmpty, reason: 'verzögert: die Fundkarte zeigt nichts');
      expect(p.fakten, vorher, reason: 'Fakten erst im Zwischenresümee');
      expect(p.spiel.bekannteFakten(), containsAll(_erm.faktenVon('e2_1_ascheneimer', 'fatma')), reason: 'kein Fund geht verloren');
      expect(p.einfluss!.nachgereicht(2), isEmpty);
      p.fundGelesen();
      while (p.phase != PartyPhase.resuemee) {
        if (p.zug case final z?) {
          switch (z.phase) {
            case RundenZugPhase.aktion:
              p.aktionFertig(z.aktion);
            case RundenZugPhase.wurf:
              p.wuerfeln();
            case RundenZugPhase.tischruf:
              p.tischruf(Tischruf.nochmal);
            case RundenZugPhase.fund:
              p.fundGelesen();
          }
        } else if (p.naechsteEntscheidung case final e?) {
          p.waehle(e.richtig['fatma']!);
        } else {
          p.weiter();
        }
      }
      expect(p.fakten, containsAll(_erm.faktenVon('e2_1_ascheneimer', 'fatma')));
      expect(p.einfluss!.nachgereicht(2).keys, ['e2_1']);
      expect(p.einfluss!.nachgereicht(2)['e2_1']!.map((a) => a.fakt), _erm.aufdecken('e2_1_ascheneimer', 'fatma').map((a) => a.fakt));
      // „Änderungen“ 7: Der Erzähler sagt die nachgereichten Funde vorn im Zwischenresümee an, nicht in den Folgen.
      final resuemee = p.spiel.erzaehler.resuemee(p.spiel);
      expect(resuemee.first, 'einfluss.wieder');
      expect(p.spiel.bausteine.sublist(p.spiel.bausteine.length - resuemee.length), resuemee);
      expect([p.einfluss!.nachgereichtIn(1), p.einfluss!.nachgereichtIn(2)], [false, true]);
      expect(p.spiel.bausteine.where((b) => b == 'einfluss.wieder'), hasLength(1));
    });

    test('Pech → Nochmal → Erfolg: Zusatzfund und Ertappt bleiben möglich', () {
      final p = partie('olli', const _Skript('e2_1', 'PE'), salz: 'nochmal');
      bisGespraeche(p, 2, 'olli');
      p.zugSetzen('fatma', ZugArt.decken, ziel: 'ahmet');
      for (final r in ['ahmet', 'olli', 'can']) {
        p.zugSetzen(r, ZugArt.helfen);
      }
      p.weiter();
      expect(p.tisch('e2_1_ascheneimer'), -1);
      p.waehle('e2_1_ascheneimer');
      zugBisFund(p, ruf: Tischruf.nochmal);
      expect([for (final w in p.wuerfe) if (w.id == 'e2_1') '${w.mod}${w.stufe.kurz}'], ['-1P', '-1E']);
      final f = p.zug!.einfluss!;
      expect([f.verwischt, f.verzoegert, f.randnotizen, f.ertappt, f.ertapptZiel], [true, false, ['b_hana_umschlag'], 'fatma', 'ahmet']);
      expect(p.zug!.funde, isNotEmpty);
    });

    test('Fledermaus: negatives T doppelt, jeder Erfolg zwei Randnotizen', () {
      final p = partie('olli', const FesterWuerfel.erfolg(), salz: 'fledermaus');
      bisGespraeche(p, 1, 'olli');
      for (var runde = 1; runde <= 2; runde++) {
        if (runde == 2) bisGespraeche(p, 2, 'olli');
        p.zugSetzen('ahmet', ZugArt.ablenken);
        p.zugSetzen('fatma', ZugArt.ablenken);
        p.zugSetzen('olli', ZugArt.ablenken);
        p.zugSetzen('can', runde == 2 ? ZugArt.decken : ZugArt.ablenken, ziel: runde == 2 ? 'fatma' : null);
        p.weiter();
      }
      final f2 = p.einfluss!.stand.folgenVon(2)!;
      expect(f2.fledermaus, isTrue);
      expect(p.tisch('e2_2_tasche'), -2, reason: 'v = −1, T = −1, doppelt −2');
      // e2_1 zuerst (Kanon-Reihenfolge), dann e2_2_tasche mit Erfolg und zwei Randnotizen (Vorrat hat eine).
      p.waehle('e2_1_ascheneimer');
      zugBisFund(p);
      expect(p.zug!.einfluss!.randnotizen, ['b_hana_umschlag']);
      p.fundGelesen();
      p.waehle('e2_2_tasche');
      zugBisFund(p);
      expect(p.wuerfe.last.mod, -2);
      expect(p.zug!.einfluss!.randnotizen, ['b_azra_tasche']);
      expect(p.zug!.einfluss!.ertappt, 'can');
      expect(p.zug!.einfluss!.ertapptZiel, 'fatma');
    });

    test('Kerzenschein: die nächste Suche ignoriert negatives T, danach gilt es wieder', () {
      final p = partie('can', const FesterWuerfel.neutral(), salz: 'kerze');
      bisGespraeche(p, 1, 'can');
      for (var runde = 1; runde <= 2; runde++) {
        if (runde == 2) bisGespraeche(p, 2, 'can');
        for (final r in ['ahmet', 'fatma', 'olli']) {
          p.zugSetzen(r, ZugArt.helfen);
        }
        p.zugSetzen('can', runde == 2 ? ZugArt.decken : ZugArt.helfen, ziel: runde == 2 ? 'can' : null);
        p.weiter();
      }
      expect(p.einfluss!.stand.folgenVon(2)!.kerzenschein, isTrue);
      expect(p.tisch('e2_1_bauchtasche'), -1);
      p.waehle('e2_1_bauchtasche');
      p.aktionFertig(p.zug!.aktion);
      expect(p.tischVorschau(), (tisch: 0, umweg: 0), reason: 'Kerzenschein: negatives T zählt nicht');
      expect(p.wuerfeln().mod, 0);
      expect(p.einfluss!.stand.kerzenschein, isFalse, reason: 'verbraucht');
      p.fundGelesen();
      p.waehle('e2_2_tasche');
      p.aktionFertig(p.zug!.aktion);
      expect(p.tisch('e2_2_tasche'), 0);
    });

    test('Befragung: redselig bringt eine Randnotiz, zögert kostet 3 Minuten, mauert verzögert bis zum Resümee', () {
      for (final (art, soll) in [(ZugArt.zeigen, BefragungsLage.redselig), (ZugArt.decken, BefragungsLage.mauert)]) {
        final p = partie('ahmet', const FesterWuerfel.neutral(), salz: 'befragung-${art.name}');
        bisGespraeche(p, 1, 'ahmet');
        // Bezug e1_1_damir: enes, ahmet. Zwei Stimmen auf ahmet → |T| = 2.
        p.zugSetzen('fatma', art, ziel: 'ahmet');
        p.zugSetzen('olli', art, ziel: 'ahmet');
        p.zugSetzen('ahmet', ZugArt.helfen);
        p.zugSetzen('can', ZugArt.helfen);
        p.weiter();
        p.zugBisAuftaktFertig();
        final vor = p.restMinuten;
        p.waehle('e1_1_damir');
        expect(p.zug!.tisch, art == ZugArt.zeigen ? 2 : -2);
        p.aktionFertig(p.zug!.aktion);
        final f = p.zug!.einfluss!;
        expect(f.befragung, soll);
        expect(p.wuerfe.where((w) => w.id == 'e1_1'), isEmpty, reason: 'würfelfrei');
        if (soll == BefragungsLage.redselig) {
          expect(vor - p.restMinuten, 6);
          expect(f.randnotizen, ['b_damir_an_der_theke']);
          expect(p.zug!.funde, isNotEmpty);
          expect(p.fakten, containsAll(_erm.faktenVon('e1_1_damir', 'ahmet')));
        } else {
          expect(vor - p.restMinuten, 9);
          expect(f.verzoegert, isTrue);
          expect(f.randnotizen, isEmpty);
          expect(p.zug!.funde, isEmpty);
          expect(p.fakten.intersection(_erm.faktenVon('e1_1_damir', 'ahmet')), isEmpty);
        }
      }
      final p = partie('ahmet', const FesterWuerfel.neutral(), salz: 'befragung-zoegert');
      bisGespraeche(p, 1, 'ahmet');
      p.zugSetzen('fatma', ZugArt.decken, ziel: 'ahmet');
      for (final r in ['olli', 'ahmet', 'can']) {
        p.zugSetzen(r, ZugArt.helfen);
      }
      p.weiter();
      p.zugBisAuftaktFertig();
      final vor = p.restMinuten;
      p.waehle('e1_1_damir');
      p.aktionFertig(p.zug!.aktion);
      expect(p.zug!.einfluss!.befragung, BefragungsLage.zoegert);
      expect(vor - p.restMinuten, 9);
      expect(p.zug!.einfluss!.verzoegert, isFalse);
    });
  });
}

extension on RundenPartie {
  /// Erledigt den Auftakt der Runde 1 (nichtwertend).
  void zugBisAuftaktFertig() {
    while (zug != null) {
      final z = zug!;
      switch (z.phase) {
        case RundenZugPhase.aktion:
          aktionFertig(z.aktion);
        case RundenZugPhase.wurf:
          wuerfeln();
        case RundenZugPhase.tischruf:
          tischruf(Tischruf.nochmal);
        case RundenZugPhase.fund:
          fundGelesen();
      }
    }
  }
}

/// Eine Suche an der Zugschicht: bestes Spiel bis zu [e], dort [option] mit Tischwert [t] und den Würfeln aus
/// [folge]; prüft Anläufe, Kosten, Modifikatoren, Kennzeichen und Fakten.
void _suche(String pfad, Entscheidung e, String option, int t,
    {required bool werkzeug, required bool gruendlich, required String folge, required List<Tischruf> rufe}) {
  final grund = '$pfad ${e.id} $option T=$t w=$werkzeug g=$gruendlich $folge $rufe';
  final z = Zugschicht(_erm, _Skript(e.id, folge), p: _p)..setzePfad(pfad);
  for (var runde = 1; runde <= e.runde; runde++) {
    z.beginneRunde(runde, zusatzMinuten: 0);
    if (runde == 1) z.auftakt();
    while (z.offen.isNotEmpty) {
      final id = z.offen.first;
      if (id != e.id) {
        if (z.waehle(_erm.entscheidung(id).richtig[pfad]!)) {
          while (z.untersuchungOffen) {
            z.anlauf();
            if (z.wartetAufTischruf) z.tischruf(Tischruf.nochmal);
          }
        }
        continue;
      }
      final vor = z.rest;
      final faktenVor = Set.of(z.fakten);
      expect(z.waehle(option, gruendlich: gruendlich, tisch: t), isTrue, reason: grund);
      final basis = WuerfelRegel.modifikator(werkzeug: werkzeug, gruendlich: gruendlich, marke: false);
      var nachUmweg = false, umweg = false, pech = false;
      var anlaeufe = 0;
      while (z.untersuchungOffen) {
        final anteil = z.tischAnteil();
        expect(anteil, (tisch: nachUmweg && t < 0 ? 0 : t, umweg: nachUmweg ? 1 : 0), reason: grund);
        final v = z.vorschau(werkzeug: werkzeug);
        final w = z.anlauf(werkzeug: werkzeug);
        anlaeufe++;
        final soll = _sollMod(basis, t, nachUmweg: nachUmweg);
        expect(w.mod, soll, reason: '$grund Anlauf ${w.anlauf}');
        expect(v.mod, soll, reason: 'Vorschau = Wurf');
        expect(w.mod, inInclusiveRange(-2, 3));
        if (t == 0 && !nachUmweg) expect(w.mod, basis, reason: 'Golden-Schutz');
        nachUmweg = false;
        if (z.wartetAufTischruf) {
          pech = true;
          expect(z.verwischt, isTrue);
          final ruf = rufe[w.anlauf - 1];
          if (ruf == Tischruf.umweg) {
            umweg = true;
            nachUmweg = true;
          }
          expect(z.tischruf(ruf), isTrue, reason: grund);
        }
      }
      expect(anlaeufe, lessThanOrEqualTo(3), reason: grund);
      expect(vor - z.rest, lessThanOrEqualTo(_p.schlechtesterPflichtzug), reason: grund);
      final k = z.kennzeichen[e.id]!;
      final letzte = z.wuerfe.lastWhere((w) => w.id == e.id);
      expect(k.stufe, letzte.stufe, reason: grund);
      expect(k.stufe, isNot(Stufe.pech));
      expect([k.tisch, k.verwischt, k.umweg], [t, pech, umweg], reason: grund);
      expect(k.zusatzfund, k.stufe == Stufe.erfolg && !umweg, reason: grund);
      expect(k.ertapptMoeglich, k.zusatzfund);
      expect(k.verzoegert, umweg);
      expect(z.fakten.difference(faktenVor), _erm.faktenVon(option, pfad).difference(faktenVor), reason: 'Fakten am Ende = Fakten der Option');
      expect(z.fakten, containsAll(_erm.faktenVon(option, pfad)));
      return;
    }
    z.beendeRunde();
  }
  fail('$grund: Entscheidung nicht erreicht');
}
