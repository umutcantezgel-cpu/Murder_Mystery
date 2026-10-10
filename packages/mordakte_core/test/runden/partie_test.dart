import 'package:mordakte_core/mordakte_core.dart';
import 'package:mordakte_core/runden.dart';
import 'package:test/test.dart';

import '../party/kanon_hilfe.dart';

final _erm = Ermittlung(kanon);

Einstellungen _einstellungen(String pfad, {int rollen = 7}) => Einstellungen(
  rollen: rollen, detektiv: 'm', code: FallCode.fuerPfad(pfad, kanon.pfade),
);

RundenPartie _partie({WuerfelQuelle quelle = const FesterWuerfel.pech(), String pfad = 'ahmet'}) =>
    RundenPartie(kanon, quelle: quelle, ermittlung: _erm)..einrichten(_einstellungen(pfad));

/// Vollständiger Zug einschließlich der sichtbaren Aktion und des Fundlesens.
void _zugFertig(RundenPartie p, {Tischruf ruf = Tischruf.nochmal}) {
  var schritte = 0;
  while (p.zug != null) {
    if (++schritte > 15) fail('Zug hat eine Sackgasse: ${p.zug?.id}');
    switch (p.zug!.phase) {
      case RundenZugPhase.aktion:
        expect(p.aktionFertig(p.zug!.aktion), isTrue);
      case RundenZugPhase.wurf:
        final v = p.vorschau();
        expect(v.prozent.values.fold(0, (a, b) => a + b), 100);
        p.wuerfeln();
      case RundenZugPhase.tischruf:
        p.tischruf(ruf);
      case RundenZugPhase.fund:
        p.fundGelesen();
    }
  }
}

void _bisEntscheidungen(RundenPartie p, int runde) {
  var schritte = 0;
  while (p.phase != PartyPhase.entscheidungen || p.runde != runde) {
    if (++schritte > 100) fail('Runde $runde nicht erreichbar');
    if (p.zug != null) {
      _zugFertig(p);
    } else if (p.naechsteEntscheidung case final e?) {
      p.waehle(e.optionen.first.id);
    } else {
      if (p.phase == PartyPhase.gruppenwahl) p.abstimmen(kooperativ: 6, taeterSabotiert: false);
      p.weiter();
    }
  }
}

void main() {
  test('Auftakt kostet keine Nachtzeit, keine Wahl und keinen Kanon-Fund', () {
    final p = _partie();
    _bisEntscheidungen(p, 1);
    expect(p.zug!.istAuftakt, isTrue);
    expect(p.naechsteEntscheidung, isNull);
    expect(p.kannWeiter, isFalse);
    expect(() => p.weiter(), throwsStateError);
    expect(() => p.waehle(_erm.entscheidungen.first.optionen.first.id), throwsStateError);
    _zugFertig(p);
    expect(p.restMinuten, 45);
    expect(p.spiel.gewaehlt, isEmpty);
    expect(p.fakten, isEmpty);
    expect(p.marken, 1);
    expect(p.wuerfe.single.id, 'auftakt');
    expect(p.naechsteEntscheidung!.id, 'e1_1');
  });

  test('Befragung wartet auf Aktion, nie auf Würfel; Fund muss gelesen werden', () {
    final p = _partie();
    _bisEntscheidungen(p, 1);
    _zugFertig(p);
    final e = p.naechsteEntscheidung!;
    p.waehle(e.richtig['ahmet']!);
    expect(p.zug!.suche, isFalse);
    expect(p.spiel.gewaehlt, isEmpty);
    expect(p.fakten, isEmpty);
    expect(p.zug!.funde, isEmpty);
    expect(() => p.wuerfeln(), throwsStateError);
    expect(() => p.fundGelesen(), throwsStateError);
    final aktion = p.zug!.aktion;
    expect(p.aktionFertig(aktion), isTrue);
    expect(p.aktionFertig(aktion), isFalse);
    expect(p.zug!.phase, RundenZugPhase.fund);
    expect(p.spiel.gewaehlt, {e.id: e.richtig['ahmet']!});
    expect(p.fakten, _erm.faktenVon(e.richtig['ahmet']!, 'ahmet'));
    expect(p.wuerfe, hasLength(1));
    expect(p.naechsteEntscheidung, isNull);
    expect(() => p.weiter(), throwsStateError);
    expect(() => p.waehle(e.optionen.last.id), throwsStateError);
    p.fundGelesen();
    expect(p.naechsteEntscheidung!.id, 'e1_2');
  });

  for (final ruf in Tischruf.values) {
    test('Pech → ${ruf.name} → gleicher Fund, dritter Anlauf garantiert', () {
      final p = _partie();
      _bisEntscheidungen(p, 2);
      final e = p.naechsteEntscheidung!;
      final option = e.richtig['ahmet']!;
      final vorher = p.fakten;
      p.waehle(option);
      for (var anlauf = 1; anlauf <= 3; anlauf++) {
        final aktion = p.zug!.aktion;
        expect(p.zug!.phase, RundenZugPhase.aktion);
        expect(p.zug!.option, option);
        expect(p.aktionFertig(aktion - 1), isFalse);
        expect(() => p.wuerfeln(), throwsStateError);
        p.aktionFertig(aktion);
        final v = p.vorschau();
        expect(v.garantie, anlauf == 3);
        if (anlauf == 3) expect(v.prozent[Stufe.pech], 0);
        final w = p.wuerfeln();
        expect(w.anlauf, anlauf);
        expect(() => p.wuerfeln(), throwsStateError);
        if (anlauf < 3) {
          expect(w.stufe, Stufe.pech);
          expect(p.fakten, vorher);
          expect(p.zug!.funde, isEmpty);
          expect(p.spiel.gewaehlt.containsKey(e.id), isFalse);
          expect(() => p.waehle(e.optionen.last.id), throwsStateError);
          expect(() => p.weiter(), throwsStateError);
          p.tischruf(ruf);
          expect(p.aktionFertig(aktion), isFalse);
        } else {
          expect(w.stufe, Stufe.teilerfolg);
          expect(p.zug!.phase, RundenZugPhase.fund);
          expect(p.spiel.gewaehlt[e.id], option);
          expect(p.zug!.funde.map((f) => f.text), _erm.aufdecken(option, 'ahmet').map((f) => f.text));
        }
      }
      expect(p.restMinuten, 33);
      p.fundGelesen();
      expect(p.naechsteEntscheidung!.id, 'e2_2');
    });
  }

  test('Fremde Option und gründliche Befragung ändern keinen Zustand', () {
    final p = _partie();
    _bisEntscheidungen(p, 1);
    _zugFertig(p);
    final option = p.naechsteEntscheidung!.optionen.first.id;
    expect(() => p.waehle('unbekannt'), throwsStateError);
    expect(() => p.waehle(option, gruendlich: true), throwsArgumentError);
    expect(p.restMinuten, 45);
    expect(p.zug, isNull);
    expect(p.spiel.gewaehlt, isEmpty);
    p.waehle(option);
    _zugFertig(p);
    expect(p.spiel.gewaehlt, hasLength(1));
  });

  test('Vorschau und Wurf teilen Modifikator, Marke und Garantie', () {
    final p = _partie();
    _bisEntscheidungen(p, 2);
    p.waehle(p.naechsteEntscheidung!.optionen.first.id, gruendlich: true);
    p.aktionFertig(p.zug!.aktion);
    final v = p.vorschau(werkzeug: true, marke: true);
    final bestand = p.marken;
    expect(v.mod, 2);
    expect(v.markeWirkt, isFalse);
    final w = p.wuerfeln(werkzeug: true, marke: true);
    expect(w.mod, v.mod);
    expect(w.garantie, v.garantie);
    expect(p.marken, bestand + 1); // Pech schenkt eine Marke, keine verfällt.
  });

  test('Zug-Ansichten und öffentliche Sammlungen sind unveränderlich', () {
    final p = _partie();
    _bisEntscheidungen(p, 1);
    _zugFertig(p);
    final e = p.naechsteEntscheidung!;
    p.waehle(e.optionen.first.id);
    p.aktionFertig(p.zug!.aktion);
    expect(() => p.zug!.funde.clear(), throwsUnsupportedError);
    expect(() => p.fakten.clear(), throwsUnsupportedError);
    expect(() => p.wuerfe.clear(), throwsUnsupportedError);
    expect(() => p.restJeRunde.clear(), throwsUnsupportedError);
  });

  test('Druckspiel bleibt beim unveränderten Kanon-Ablauf ohne Würfel', () {
    final p = RundenPartie(kanon, quelle: const FesterWuerfel.pech(), ermittlung: _erm);
    expect(() => p.einrichten(Einstellungen(rollen: 7, detektiv: 'm', code: FallCode.fuerPfad('ahmet', kanon.pfade), druck: true)), throwsArgumentError);
    expect(p.phase, PartyPhase.titel);
    expect(p.wuerfe, isEmpty);
  });

  test('Alle 768 Wahlfolgen × 4 Pfade × 3 Würfelströme bleiben kanongleich (9.216 Abende)', () {
    var abende = 0;
    final folgen = Simulator(kanon).folgen().toList();
    expect(folgen, hasLength(768));
    for (final pfad in kanon.pfade) {
      for (final folge in folgen) {
        for (final quelle in [const FesterWuerfel.pech(), const FesterWuerfel.erfolg(), const FesterWuerfel.neutral()]) {
          _vergleicheAbend(pfad, 7, folge, quelle, wechsel: abende);
          abende++;
        }
      }
    }
    expect(abende, 9216);
  }, timeout: const Timeout(Duration(minutes: 3)));

  test('Bestes Spiel ist für 4–20 Rollen in allen Pfaden auch mit Salz-Würfen lösbar', () {
    for (final pfad in kanon.pfade) {
      final folge = [for (final e in _erm.entscheidungen) e.richtig[pfad]!];
      for (var n = 4; n <= 20; n++) {
        final p = _vergleicheAbend(pfad, n, folge, SalzWuerfel('partie:$pfad:$n'), wechsel: n);
        expect(p.spiel.punkte, 9);
        expect(p.spiel.restmenge(), {pfad});
        expect(p.spiel.ende.id, 'ende_meister');
      }
    }
  });
}

RundenPartie _vergleicheAbend(String pfad, int n, List<String> folge, WuerfelQuelle quelle, {required int wechsel}) {
  final e = _einstellungen(pfad, rollen: n);
  final p = RundenPartie(kanon, quelle: quelle, ermittlung: _erm)..einrichten(e);
  final referenz = Spiel(kanon, ermittlung: _erm)..einrichten(e);
  var index = 0;
  var schritte = 0;
  while (p.phase != PartyPhase.ende) {
    if (++schritte > 100) fail('Sackgasse in $pfad / $n / $folge');
    if (p.zug != null) {
      _zugFertig(p);
    } else if (p.naechsteEntscheidung case final entscheidung?) {
      expect(p.fakten, referenz.bekannteFakten(), reason: 'Stand vor ${entscheidung.id}');
      final option = folge[index++];
      p.waehle(option, gruendlich: istSuche(entscheidung) && wechsel.isEven);
      _zugFertig(p, ruf: wechsel.isEven ? Tischruf.umweg : Tischruf.nochmal);
      referenz.waehle(entscheidung.id, option);
      expect(p.spiel.gewaehlt, referenz.gewaehlt);
      expect(p.fakten, referenz.bekannteFakten());
    } else {
      if (p.phase == PartyPhase.gruppenwahl) {
        final stimmen = wechsel % n;
        final sabotage = wechsel.isEven;
        expect(p.abstimmen(kooperativ: stimmen, taeterSabotiert: sabotage),
          referenz.abstimmen(kooperativ: stimmen, taeterSabotiert: sabotage));
      }
      if (p.phase == PartyPhase.anklage) {
        p.anklagen(pfad);
        referenz.anklagen(pfad);
      }
      p.weiter();
      referenz.weiter();
      expect(p.phase, referenz.phase);
      expect(p.runde, referenz.runde);
      expect(p.spiel.bausteine, referenz.bausteine);
    }
  }
  expect(index, 9);
  expect(p.spiel.punkte, referenz.punkte);
  expect(p.spiel.ende.id, referenz.ende.id);
  expect(p.spiel.qualitaeten, referenz.qualitaeten);
  expect(p.spiel.restmenge(), referenz.restmenge());
  expect(p.restJeRunde, hasLength(3));
  expect(p.restJeRunde.every((rest) => rest >= 0), isTrue);
  expect(p.wuerfe.every((wurf) => wurf.anlauf <= 3), isTrue);
  return p;
}
