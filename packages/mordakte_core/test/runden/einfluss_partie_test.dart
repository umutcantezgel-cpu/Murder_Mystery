// Haken der Einfluss-Schicht in RundenPartie und Spiel (Finale §3.1, §3.2, §3.5, §3.7, §3.8, §3.14): Moment nur
// in den Gesprächen, Bots füllen fehlende Züge, Folgen beim Wechsel in die Ermittlung mit Bausteinen,
// Tischwerte an den Optionen, Flüstern statt Gruppenwahl, Minutenübertrag und Boden, Randnotizen und
// Nachfragen, Texte mit Figuren; ohne Schicht keine dieser Wirkungen.
@TestOn('vm')
library;

import 'package:mordakte_core/mordakte_core.dart';
import 'package:mordakte_core/runden.dart';
import 'package:test/test.dart';

import '../party/kanon_hilfe.dart';
import 'einfluss_hilfe.dart';
import 'einfluss_lauf.dart';

EinflussRegeln get _r => einflussRegeln;
Ermittlung get _erm => einflussErmittlung;

RundenPartie _partie({int rollen = 6, String pfad = 'olli', WuerfelQuelle quelle = const FesterWuerfel.neutral(), String salz = 'haken'}) =>
    RundenPartie(kanon, quelle: quelle, ermittlung: _erm, einfluss: _r, salz: salz)
      ..einrichten(Einstellungen(rollen: rollen, detektiv: 'm', code: FallCode.fuerPfad(pfad, kanon.pfade)));

/// Weiter bis zu [phase] in [runde]; Züge der Detektivseite mit bestem Spiel, kein eigener Moment.
void _bis(RundenPartie p, PartyPhase phase, int runde, {String pfad = 'olli'}) {
  for (var i = 0; !(p.phase == phase && p.runde == runde); i++) {
    if (i > 300) fail('$phase/$runde nicht erreicht');
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
      if (p.phase == PartyPhase.anklage && p.spiel.angeklagt == null) p.anklagen(pfad);
      if (p.phase == PartyPhase.gruppenwahl) p.abstimmen(kooperativ: 3, taeterSabotiert: false);
      p.weiter();
    }
  }
}

void main() {
  test('Ohne Schicht: kein Moment, keine Tischwerte, keine Nachfragen, keine Kennzeichen', () {
    final p = RundenPartie(kanon, quelle: const SalzWuerfel('ohne'), ermittlung: _erm)
      ..einrichten(Einstellungen(rollen: 6, detektiv: 'm', code: FallCode.fuerPfad('olli', kanon.pfade)));
    expect(p.einfluss, isNull);
    expect(p.spiel.zusatz, isNull);
    _bis(p, PartyPhase.gespraeche, 1);
    expect(() => p.zugSetzen('ahmet', ZugArt.helfen), throwsStateError);
    _bis(p, PartyPhase.entscheidungen, 2);
    expect(p.tisch('e2_1_ascheneimer'), isNull);
    p.waehle('e2_1_ascheneimer');
    expect(p.zug!.tisch, isNull);
    p.aktionFertig(p.zug!.aktion);
    expect(p.tischVorschau(), isNull);
    p.wuerfeln();
    expect(p.zug!.einfluss, isNull);
    expect(p.zug!.verwischt, isFalse);
    expect(p.nachfragenOffen, 0);
    expect(p.nachfrageOptionen, isEmpty);
    expect(() => p.nachfrage('e2_1_ascheneimer'), throwsStateError);
  });

  test('Einrichtung: Salz nötig, Regeln passen zur Ermittlung', () {
    expect(() => RundenPartie(kanon, quelle: const FesterWuerfel.neutral(), ermittlung: _erm, einfluss: _r), throwsArgumentError);
    final p = RundenPartie(kanon, quelle: const SalzWuerfel('aus-wuerfel'), ermittlung: _erm, einfluss: _r);
    p.einrichten(Einstellungen(rollen: 5, detektiv: 'w', code: FallCode.fuerPfad('can', kanon.pfade)));
    expect(p.einfluss!.salz, 'aus-wuerfel');
    expect(p.einfluss!.stand.besetzt, p.spiel.besetzt);
    expect(identical(p.spiel.zusatz, p.einfluss), isTrue);
    final fremd = ladeKanon('gewoelbe');
    expect(() => RundenPartie(fremd, quelle: const SalzWuerfel('x'), einfluss: _r), throwsArgumentError);
  });

  test('Moment nur in den Gesprächen, änderbar bis zu den Folgen; Bots füllen, wer fehlt', () {
    final p = _partie(rollen: 6, salz: 'moment');
    expect(() => p.zugSetzen('ahmet', ZugArt.helfen), throwsStateError, reason: 'vor den Gesprächen');
    _bis(p, PartyPhase.gespraeche, 1);
    p.zugSetzen('ahmet', ZugArt.zeigen, ziel: 'fatma');
    p.zugSetzen('ahmet', ZugArt.helfen);
    p.zugSetzen('fatma', ZugArt.abgewartet);
    expect(() => p.zugSetzen('ahmet', ZugArt.zeigen, ziel: 'ahmet'), throwsArgumentError);
    expect(() => p.zugSetzen('tim', ZugArt.helfen), throwsArgumentError, reason: 'nicht besetzt');
    expect(() => p.zugSetzen('olli', ZugArt.helfen, tipp: 'can'), throwsArgumentError, reason: 'Tipp erst in Runde 3');
    final lage = p.einfluss!.botLage();
    p.weiter();
    expect(p.phase, PartyPhase.entscheidungen);
    final f = p.einfluss!.stand.folgenVon(1)!;
    expect(f.zuege['ahmet']!.art, ZugArt.helfen);
    expect(f.zuege['fatma']!.art, ZugArt.abgewartet);
    for (final r in ['olli', 'can', 'leyla', 'emine']) {
      expect(f.zuege[r], botZug(_r, salz: 'moment', rolle: r, runde: 1, lage: lage), reason: '$r zieht als Bot');
    }
    expect(() => p.zugSetzen('ahmet', ZugArt.helfen), throwsStateError, reason: 'nach den Folgen fest');
    _bis(p, PartyPhase.gespraeche, 3);
    p.zugSetzen('olli', ZugArt.helfen, tipp: 'can');
    p.weiter();
    expect(p.einfluss!.stand.tipps['olli'], 'can');
  });

  test('Folgen als Bausteine beim Wechsel; Gruppenwahl entfällt, Flüstern nach dem Zusammenhalt', () {
    final p = _partie(rollen: 5, salz: 'folgen');
    _bis(p, PartyPhase.gespraeche, 1);
    // Runde 1: alle helfen → Zusammenhalt +2 → Tee, Flüstern wahr.
    for (final r in p.spiel.besetzt) {
      p.zugSetzen(r, ZugArt.helfen);
    }
    var vorher = p.spiel.bausteine.length;
    p.weiter();
    expect(p.spiel.bausteine.sublist(vorher), ['einfluss.folgen.start.1', 'einfluss.leiste.zusammenhalt.2', 'einfluss.ereignis.tee', 'einfluss.wieder']);
    expect(p.restMinuten, 45 + 9 + 5, reason: 'Helfen +9 (Deckel), Tee +5');
    _bis(p, PartyPhase.bonus, 1);
    expect(p.spiel.qualitaeten[1], Qualitaet.wahr);
    expect(p.spiel.bausteine.where((b) => b.startsWith('hinweis.')).single, 'hinweis.${p.spiel.gruppe.hinweis('olli', 1, Qualitaet.wahr)['id']}');
    _bis(p, PartyPhase.resuemee, 1);
    expect(p.spiel.bausteine.reversed.take(3).last, 'resuemee.gruppe.1');
    // Runde 2: zwei lenken ab, einer zeigt, Rest wartet → Spuk +2, still.
    _bis(p, PartyPhase.gespraeche, 2);
    p.zugSetzen('ahmet', ZugArt.ablenken);
    p.zugSetzen('fatma', ZugArt.ablenken);
    p.zugSetzen('olli', ZugArt.zeigen, ziel: 'can');
    p.zugSetzen('can', ZugArt.abgewartet);
    p.zugSetzen('leyla', ZugArt.abgewartet);
    final rest1 = p.restJeRunde.single;
    vorher = p.spiel.bausteine.length;
    p.weiter();
    expect(p.spiel.bausteine.sublist(vorher), [
      'einfluss.folgen.start.2',
      'einfluss.ablenken.ahmet',
      'einfluss.ablenken.fatma',
      'einfluss.ablenken.schluss',
      einflussBaustein('einfluss.geruecht.leise', figur: 'can'),
      'einfluss.leiste.spuk.2',
      'einfluss.ereignis.flackerlicht',
      'einfluss.wieder',
    ]);
    expect(p.restMinuten, (45 + (rest1 > 5 ? 5 : rest1) - 8 - 3).clamp(42, 99), reason: 'Übertrag ≤ 5, Ablenken −8, Flackerlicht −3, Boden 42');
    expect(p.tisch('e2_1_bauchtasche'), 1, reason: 'n = 5: ein Zeigen auf can');
    _bis(p, PartyPhase.bonus, 2);
    expect(p.spiel.qualitaeten.containsKey(2), isFalse);
    expect(p.spiel.bausteine.last, 'einfluss.fluestern.still');
    _bis(p, PartyPhase.resuemee, 2);
    expect(p.spiel.bausteine.reversed.take(2).toList().reversed.first, startsWith('resuemee.rest.'), reason: 'ohne Geflüster kein Gruppenfach');
    expect(p.spiel.bausteine.where((b) => b == 'resuemee.gruppe.2'), isEmpty);
    // Nie eine Gruppenwahl.
    _bis(p, PartyPhase.ende, 3);
    expect(p.spiel.bausteine.where((b) => b.startsWith('aufloesung.gruppe.')).single,
        'aufloesung.gruppe.${[for (var r = 1; r <= 3; r++) if (p.spiel.qualitaeten[r] == Qualitaet.wahr) r].length}');
  });

  test('Randnotizen: Auspacken zeigt sie, ein Zusatzfund nimmt die erste noch nicht gezeigte', () {
    final p = _partie(rollen: 8, pfad: 'can', quelle: const FesterWuerfel.erfolg(), salz: 'notizen');
    _bis(p, PartyPhase.gespraeche, 1, pfad: 'can');
    p.zugSetzen('emine', ZugArt.auspacken);
    p.weiter();
    expect(p.einfluss!.randnotizen, ['b_emine_schatulle']);
    expect(p.fakten, contains('f_nd_fatma'));
    expect(p.einfluss!.geliefert(1), {'f_nd_fatma'});
    _bis(p, PartyPhase.entscheidungen, 3, pfad: 'can');
    // e3_2_fatma hat den Vorrat b_emine_schatulle – schon gezeigt, also kein Zusatzfund.
    while (p.naechsteEntscheidung?.id != 'e3_2') {
      _schritt(p, 'can');
    }
    p.waehle('e3_2_fatma');
    while (p.zug!.phase != RundenZugPhase.fund) {
      _schritt(p, 'can');
    }
    expect(p.wuerfe.last.stufe, Stufe.erfolg);
    expect(p.zug!.einfluss!.randnotizen, isEmpty);
  });

  test('Nachfragen nach Runde 3: je volle 25 Restminuten eine (höchstens 2), zeigen fehlende Randnotizen', () {
    final p = _partie(rollen: 6, pfad: 'ahmet', quelle: const FesterWuerfel.erfolg(), salz: 'nachfrage');
    _bis(p, PartyPhase.resuemee, 3, pfad: 'ahmet');
    expect(p.nachfragenOffen, 0, reason: 'erst vor der Anklage');
    p.weiter();
    expect(p.phase, PartyPhase.anklage);
    final rest = p.restJeRunde[2];
    final soll = (rest ~/ 25).clamp(0, 2) + (p.einfluss!.stand.ausgeloest.contains('erinnerung') ? 1 : 0);
    expect(p.nachfragenOffen, soll);
    expect(soll, greaterThan(0), reason: 'immer Erfolg lässt Minuten übrig');
    final optionen = p.nachfrageOptionen;
    expect(optionen, isNotEmpty);
    for (final o in optionen) {
      expect(p.spiel.gewaehlt.values, contains(o));
    }
    final erste = optionen.first;
    final n = p.nachfrage(erste);
    expect(_r.randnotizen[erste], contains(n));
    expect(p.einfluss!.randnotizen.last, n);
    expect(p.einfluss!.nachfragen.single, (option: erste, notiz: n));
    expect(p.nachfragenOffen, soll - 1);
    expect(() => p.nachfrage('e1_1_joanna'), throwsArgumentError, reason: 'nicht gewählt');
    while (p.nachfragenOffen > 0 && p.nachfrageOptionen.isNotEmpty) {
      p.nachfrage(p.nachfrageOptionen.first);
    }
    if (p.nachfrageOptionen.isNotEmpty) expect(() => p.nachfrage(p.nachfrageOptionen.first), throwsStateError);
    p.anklagen('ahmet');
    expect(p.nachfragenOffen, 0);
  });

  test('Texte: jeder Baustein eines Abends löst sich auf, Figuren-Bausteine mit Anzeigenamen', () {
    final ordner = '$repoWurzel/content/party/schlosskeller';
    final index = leseJson('$ordner/texte/index.json');
    final probe = {
      'settingId': kanon.settingId,
      'bereich': 'einfluss',
      'hinweis': 'Fixture',
      'eintraege': [for (final e in fixtureTexte(_r).entries) {'id': e.key, 'text': e.value}],
    };
    final sammlung = Textsammlung.lade((p) {
      if (p == 'texte/index.json') {
        return {...index, 'dateien': [...index['dateien'] as List, {'datei': 'einfluss-probe.json', 'bereich': 'einfluss'}]};
      }
      if (p == 'texte/einfluss-probe.json') return probe;
      return leseJson('$ordner/$p');
    });
    final texte = Texte(kanon, sammlung);
    for (var i = 0; i < 40; i++) {
      final pfad = kanon.pfade[i % 4];
      final p = spieleEinflussAbend(
        pfad: pfad, rollen: 4 + i % 17, folge: gezogeneFolge(_erm, Rng(i)), quelle: SalzWuerfel('texte$i'), salz: 'texte$i',
        profil: Tischprofil.values[i % 4], weise: Detektivweise.strom(Rng(Rng.hashString('texte-weise$i'))),
      );
      for (final b in p.spiel.bausteine) {
        expect(texte.baustein(b), isNotEmpty, reason: b);
        if (b.contains('@')) expect(texte.baustein(b), isNot(contains('@')), reason: b);
      }
    }
    expect(texte.baustein(einflussBaustein('einfluss.geruecht.laut', figur: 'meryem')), contains('Hana'));
    expect(texte.baustein(einflussBaustein('einfluss.ertappt', figur: 'kaan', ziel: 'olli')), allOf(contains('Wojtek'), contains('Olli')));
    expect(() => texte.baustein('einfluss.geruecht.laut@niemand'), throwsArgumentError);
  });

  test('Gleiche Eingaben, gleicher Abend (Bausteine, Würfe, Folgen, Kennzeichen)', () {
    String abend() {
      final p = spieleEinflussAbend(
        pfad: 'fatma', rollen: 11, folge: gezogeneFolge(_erm, Rng(7)), quelle: const SalzWuerfel('gleich'), salz: 'gleich',
        weise: Detektivweise.strom(Rng(99)),
      );
      final e = p.einfluss!;
      return [
        p.spiel.bausteine, [for (final w in p.wuerfe) w.zeile], [for (final f in e.stand.folgen) f.toJson()],
        {for (final f in e.funde.entries) f.key: f.value.toJson()}, e.randnotizen, p.restJeRunde, p.spiel.ende.id,
      ].toString();
    }

    expect(abend(), abend());
  });
}

void _schritt(RundenPartie p, String pfad) {
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
    p.weiter();
  }
}
