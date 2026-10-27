// „Dein Moment“ an einem Gerät (Finale §3): reihum ziehen alle verdeckt,
// solo die Bots; zu Beginn der Ermittlung die Folgen, Abzeichen an den
// Optionen, Fundkarte mit Randnotiz und Ertappt, Tischruf, Nachfragen,
// Resümee mit Leisten, Auflösung mit Sternen und Preisen, abendstand/3 hin und
// zurück und ein Stand der Version 2 ohne Schicht.
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mordakte/abend/einrichtung/abend_neu_seite.dart' show Spielweise;
import 'package:mordakte/abend/einrichtung/abschnitte.dart';
import 'package:mordakte/abend/rollen_uebersicht.dart';
import 'package:mordakte/l10n/gen/app_localizations_de.dart';
import 'package:mordakte/party/bildschirme/anklage.dart';
import 'package:mordakte/party/bildschirme/aufloesung.dart';
import 'package:mordakte/party/bildschirme/einfluss_teile.dart';
import 'package:mordakte/party/bildschirme/moment.dart';
import 'package:mordakte/party/bildschirme/npc_karte.dart';
import 'package:mordakte/party/bildschirme/resuemee.dart';
import 'package:mordakte/party/bildschirme/rollen.dart';
import 'package:mordakte/party/bildschirme/runde.dart';
import 'package:mordakte/party/bildschirme/zug_tafel.dart';
import 'package:mordakte/party/party_seite.dart' show PartyAblauf;
import 'package:mordakte/party/einfluss_sicht.dart';
import 'package:mordakte/party/sitzung.dart';
import 'package:mordakte/party/skript.dart';
import 'package:mordakte_core/mordakte_core.dart';
import 'package:mordakte_core/runden.dart';

import 'einfluss_hilfe.dart';
import 'hilfe.dart';

/// Zwei zeigen auf Ahmet, Ahmet deckt sich: Tischwert +1 an seinen Optionen (n = 4, m = 1).
({ZugArt art, String? ziel, String? tipp}) _zweiZeigen(PartySitzung s, String rolle) {
  final m = s.momentSicht(rolle);
  final tipp = m.tipps.isEmpty ? null : m.tipps.first;
  return switch (rolle) {
    'ahmet' => (art: ZugArt.decken, ziel: 'ahmet', tipp: tipp),
    'fatma' || 'olli' => (art: ZugArt.zeigen, ziel: 'ahmet', tipp: tipp),
    _ => (art: ZugArt.lauschen, ziel: 'ahmet', tipp: tipp),
  };
}

void main() {
  group('reihum', () {
    test('Gespräche enden erst, wenn alle verdeckt gezogen haben; dann die Folgen', () {
      final s = einflussSitzung();
      einflussBis(s, PartyPhase.gespraeche);
      expect(s.einfluss, isTrue);
      expect(s.momentOffen, s.besetzt);
      PartySkript.befragungenErledigen(s);
      expect(s.kannWeiter, isFalse, reason: 'Ohne Züge geht es nicht weiter');
      // Der Moment ist privat: nur verdeckt.
      expect(() => s.momentSicht('ahmet'), throwsStateError);
      expect(() => s.momentZug('ahmet', ZugArt.helfen), throwsStateError);
      for (final r in s.besetzt) {
        s.momentZeigen(r);
        expect(s.momentAnsicht, r);
        final m = s.momentSicht(r);
        expect(m.offen, isTrue);
        expect(m.arten, containsAll([ZugArt.helfen, ZugArt.zeigen, ZugArt.decken, ZugArt.lauschen]));
        expect(m.sterne, hasLength(2));
        final z = planZug(s, r);
        s.momentZug(r, z.art, ziel: z.ziel, tipp: z.tipp);
        expect(s.verdeckt, isNull, reason: 'Nach dem Zug ist zugedeckt');
        expect(s.momentAnsicht, isNull);
      }
      expect(s.momentOffen, isEmpty);
      expect(s.kannWeiter, isTrue);
      s.weiter();
      expect(s.phase, PartyPhase.entscheidungen);
      expect(s.folgenOffen, isTrue);
      expect(s.erzaehler.first, 'einfluss.folgen.start.1');
      // Jeder Baustein der Folgen hat einen Wortlaut (Platzhalter mit Anzeigenamen).
      for (final k in s.erzaehler) {
        expect(s.text(k), isNot(contains('@')));
      }
      s.folgenGelesen();
      expect(s.folgenOffen, isFalse);
      // Reihum zieht keine Rolle als Bot: kein Raunen.
      expect(s.einflussLage!.folgenVon(1)!.blasen, isEmpty);
    });

    test('Lauschergebnis nur beim Lauscher, in der nächsten Runde unter „Was du erfahren hast“', () {
      final s = einflussSitzung();
      einflussBis(s, PartyPhase.gespraeche, runde: 2);
      s.momentZeigen('can');
      final can = s.momentSicht('can');
      expect(can.vorrunde.where((n) => n.gelauscht), hasLength(1));
      final g = can.vorrunde.firstWhere((n) => n.gelauscht);
      expect((g.figur, g.zug, g.ziel), ('ahmet', 'decken', 'ahmet'));
      s.verdecken();
      s.momentZeigen('fatma');
      expect(s.momentSicht('fatma').vorrunde.where((n) => n.gelauscht), isEmpty);
      s.verdecken();
    });

    test('Wie letzte Runde und ausgegraute Einmal-Züge', () {
      final s = einflussSitzung(rollen: 5);
      einflussBis(s, PartyPhase.gespraeche);
      // Leyla packt in Runde 1 aus; danach ist die Kachel ausgegraut.
      alleZiehen(s, plan: (s, r) => r == 'leyla' ? (art: ZugArt.auspacken, ziel: null, tipp: null) : planZug(s, r));
      einflussBis(s, PartyPhase.gespraeche, runde: 2);
      s.momentZeigen('leyla');
      final m = s.momentSicht('leyla');
      expect(m.arten, isNot(contains(ZugArt.auspacken)));
      expect(m.wieLetzteRunde, isNull, reason: 'Auspacken geht nur einmal');
      s.verdecken();
      s.momentZeigen('fatma');
      final f = s.momentSicht('fatma');
      expect(f.wieLetzteRunde?.art, ZugArt.zeigen);
      expect(f.wieLetzteRunde?.ziel, 'ahmet');
      s.verdecken();
    });
  });

  test('Solo: Die Bots ziehen, bis zu drei raunen', () {
    final s = einflussSitzung(rollen: 7, solo: true);
    einflussBis(s, PartyPhase.gespraeche);
    expect(s.momentOffen, isEmpty);
    expect(() => s.momentZeigen('ahmet'), throwsStateError, reason: 'Bot-Dossiers bleiben verdeckt');
    PartySkript.befragungenErledigen(s);
    expect(s.kannWeiter, isTrue);
    s.weiter();
    final f = s.einflussAbend!.stand.folgenVon(1)!;
    expect(f.zuege, hasLength(7));
    expect(f.zuege.values.where((z) => z.art == ZugArt.abgewartet), isEmpty);
    expect(s.einflussLage!.folgenVon(1)!.blasen.length, lessThanOrEqualTo(3));
  });

  group('Ermittlung', () {
    test('Abzeichen: Tischwert an den Optionen mit Ahmet im Bezug', () {
      final s = einflussSitzung();
      einflussBis(s, PartyPhase.gespraeche);
      alleZiehen(s, plan: _zweiZeigen);
      einflussBis(s, PartyPhase.entscheidungen);
      expect(s.tischwert('e1_1_joanna'), 1);
      expect(s.tischwert('e1_2_emine'), 0);
      expect(abzeichenSchluessel(1), 'einfluss.abzeichen.plus1');
      expect(abzeichenSchluessel(-2), 'einfluss.abzeichen.minus2');
    });

    testWidgets('Befragung mit Rückendeckung: redselig, Fundkarte mit Randnotiz', (t) async {
      final s = einflussSitzung();
      einflussBis(s, PartyPhase.gespraeche);
      alleZiehen(s, plan: _zweiZeigen);
      einflussBis(s, PartyPhase.entscheidungen);
      s.folgenGelesen();
      final d = EinflussDarstellung.sitzung(s);
      await t.pumpWidget(rahmen(SingleChildScrollView(child: TischAbzeichen(tisch: s.tischwert('e1_1_joanna')!, darstellung: d))));
      expect(find.text(s.text('einfluss.abzeichen.plus1')), findsOneWidget);
      expect(s.laufendeEntscheidung!.id, 'e1_1');
      s.schlageVor('e1_1_joanna');
      s.bestaetigen();
      s.aktionFertig(s.zug!.aktion);
      final ein = s.zug!.einfluss!;
      expect((ein.tisch, ein.befragung), (1, BefragungsLage.redselig));
      expect(ein.randnotizen, isNotEmpty);
      final fund = s.letzterFund!;
      await t.pumpWidget(rahmen(SingleChildScrollView(child: FundKarte(sitzung: s, ziel: fund.ziel, funde: fund.funde, onGelesen: s.fundGelesen))));
      expect(find.byKey(const ValueKey('fund-einfluss')), findsOneWidget);
      expect(find.text(s.text('einfluss.befragung.redselig')), findsOneWidget);
      expect(find.byKey(ValueKey('randnotiz-${ein.randnotizen.first}')), findsOneWidget);
    });

    testWidgets('Suche mit Rückendeckung: Chancenzeile „Tisch“, Zusatzfund und Ertappt', (t) async {
      final s = einflussSitzung(wuerfel: const FesterWuerfel.erfolg());
      einflussBis(s, PartyPhase.gespraeche, runde: 2);
      alleZiehen(s, plan: _zweiZeigen);
      einflussBis(s, PartyPhase.entscheidungen, runde: 2);
      s.folgenGelesen();
      expect(s.laufendeEntscheidung!.id, 'e2_1');
      expect(s.tischwert('e2_1_ascheneimer'), 1);
      s.schlageVor('e2_1_ascheneimer');
      s.bestaetigen();
      s.aktionFertig(s.zug!.aktion);
      expect(s.zug!.phase, RundenZugPhase.wurf);
      expect(s.tischVorschau?.tisch, 1);
      await t.pumpWidget(rahmen(SingleChildScrollView(child: WuerfelTafel(sitzung: s))));
      expect(find.byKey(const ValueKey('chance-tisch')), findsOneWidget);
      s.wuerfeln();
      final z = s.zug!;
      expect((z.phase, z.wurf!.stufe), (RundenZugPhase.fund, Stufe.erfolg));
      final ein = z.einfluss!;
      expect(ein.randnotizen, isNotEmpty, reason: 'Zusatzfund');
      expect((ein.ertappt, ein.ertapptZiel), ('ahmet', 'ahmet'), reason: 'Ahmet deckte sich selbst');
      final fund = s.letzterFund!;
      await t.pumpWidget(rahmen(SingleChildScrollView(child: FundKarte(sitzung: s, ziel: fund.ziel, funde: fund.funde, onGelesen: s.fundGelesen))));
      expect(find.byKey(const ValueKey('fund-ertappt')), findsOneWidget);
      expect(find.text(s.daten.texte.einflussText('einfluss.ertappt.selbst', figur: 'ahmet')), findsOneWidget);
      // Privat erfährt Ahmet, dass er ertappt wurde (nächster Moment).
      expect(s.einflussAbend!.privatFuer('ahmet').map((n) => n.nachricht.art), contains(PrivatArt.ertappt));
    });

    testWidgets('Pech: Die Spur verwischt, Tischruf-Knöpfe mit Wirkungstext', (t) async {
      final s = einflussSitzung(wuerfel: const FesterWuerfel.pech());
      einflussBis(s, PartyPhase.entscheidungen, runde: 2);
      s.folgenGelesen();
      s.schlageVor(s.laufendeEntscheidung!.optionen.first.id);
      s.bestaetigen();
      s.aktionFertig(s.zug!.aktion);
      s.wuerfeln();
      expect(s.zug!.phase, RundenZugPhase.tischruf);
      expect(s.zug!.verwischt, isTrue);
      await t.pumpWidget(rahmen(SingleChildScrollView(child: TischrufTafel(sitzung: s))));
      expect(find.text(s.text('einfluss.verwischt')), findsOneWidget);
      expect(find.text(s.text('einfluss.tischruf.nochmal')), findsOneWidget);
      expect(find.text(s.text('einfluss.tischruf.umweg')), findsOneWidget);
    });
  });

  testWidgets('Nachfragen nach Runde 3: Option wählen, Randnotiz zeigen', (t) async {
    final s = einflussSitzung(rollen: 4);
    einflussBis(s, PartyPhase.anklage);
    final offen = s.nachfragenOffen;
    expect(offen, greaterThan(0), reason: 'Bestes Spiel lässt Nachtminuten für Nachfragen übrig');
    await t.pumpWidget(rahmen(AnklageBildschirm(sitzung: s)));
    final o = s.nachfrageOptionen.first;
    expect(find.byKey(ValueKey('nachfrage-$o')), findsOneWidget);
    await t.ensureVisible(find.byKey(ValueKey('nachfrage-$o')));
    await t.tap(find.byKey(ValueKey('nachfrage-$o')));
    await t.pump();
    final lage = s.einflussLage!;
    expect(lage.nachgefragt.single.option, o);
    expect(s.nachfragenOffen, offen - 1);
    expect(find.byKey(ValueKey('randnotiz-${lage.nachgefragt.single.notiz}')), findsOneWidget);
  });

  testWidgets('Resümee mit Leisten; Dossier mit „Deine Ziele“ statt Rundenwahl', (t) async {
    final s = einflussSitzung();
    // Dossier: zwei Sternkarten und die Erklärung, keine Rundenwahl.
    s.zeigeVerdeckt('fatma');
    await t.pumpWidget(rahmen(RollenBildschirm(sitzung: s)));
    await t.pump();
    expect(find.byKey(const ValueKey('stern-1')), findsOneWidget);
    expect(find.byKey(const ValueKey('stern-2')), findsOneWidget);
    expect(find.byKey(const ValueKey('moment-erklaerung')), findsOneWidget);
    expect(find.text(s.ui('ui.rollen.wahl_titel')), findsNothing);
    s.verdecken();
    einflussBis(s, PartyPhase.resuemee);
    await t.pumpWidget(rahmen(ResuemeeBildschirm(sitzung: s)));
    expect(find.byKey(const ValueKey('einfluss-resuemee')), findsOneWidget);
    expect(find.byKey(const ValueKey('leiste-zusammenhalt')), findsOneWidget);
    expect(find.byKey(const ValueKey('leiste-spuk')), findsOneWidget);
  });

  testWidgets('Auflösung: Protokoll der Nacht, Sterne, Tipps, Preise, Endwert', (t) async {
    final s = einflussSitzung();
    einflussBis(s, PartyPhase.aufloesung);
    final a = s.einflussAufloesung!;
    expect(a.protokoll.keys, [1, 2, 3]);
    expect(a.tipps.keys, containsAll(s.besetzt));
    expect(s.erzaehler, contains(startsWith('einfluss.preis.stern@')));
    expect(s.erzaehler.where((k) => k.startsWith('einfluss.epilog.')), hasLength(s.besetzt.length));
    await t.pumpWidget(rahmen(AufloesungBildschirm(sitzung: s)));
    await t.pump();
    expect(find.byKey(const ValueKey('einfluss-aufloesung')), findsOneWidget);
    for (final r in s.besetzt) {
      expect(find.byKey(ValueKey('protokoll-$r')), findsOneWidget);
      expect(find.byKey(ValueKey('sterne-$r')), findsOneWidget);
    }
    expect(find.byKey(const ValueKey('endwert')), findsOneWidget);
    expect(a.endwert, s.spiel.endwert);
  });

  group('Abendstand', () {
    test('abendstand/3 hin und zurück: Schicht, Züge und Nachfragen kommen wieder', () {
      final s = einflussSitzung(salz: 'stand-3');
      einflussBis(s, PartyPhase.gespraeche, runde: 2);
      alleZiehen(s);
      final stand = jsonDecode(jsonEncode(s.abendstand)) as Map<String, Object?>;
      expect(stand['format'], 'abendstand/3');
      final einrichten = (stand['befehle'] as List).cast<Map>().firstWhere((b) => b['b'] == 'einrichten');
      expect(einrichten['einfluss'], isTrue);
      final r = PartySitzung.fortsetzen(einflussDaten, stand);
      expect(r.einfluss, isTrue);
      expect((r.phase, r.runde), (PartyPhase.gespraeche, 2));
      for (final rolle in s.besetzt) {
        expect(r.einflussAbend!.stand.zug(2, rolle), s.einflussAbend!.stand.zug(2, rolle));
      }
      expect(r.einflussAbend!.stand.folgenVon(1)!.toJson(), s.einflussAbend!.stand.folgenVon(1)!.toJson());
      expect(r.kannWeiter, s.kannWeiter);
      // Bis zur Anklage, eine Nachfrage; auch sie kommt mit dem Stand wieder.
      einflussBis(s, PartyPhase.anklage);
      s.nachfrage(s.nachfrageOptionen.first);
      final r2 = PartySitzung.fortsetzen(einflussDaten, jsonDecode(jsonEncode(s.abendstand)) as Map<String, Object?>);
      expect(r2.einflussLage!.nachgefragt.map((n) => n.notiz), s.einflussLage!.nachgefragt.map((n) => n.notiz));
      expect(r2.nachfragenOffen, s.nachfragenOffen);
      expect(r2.restMinuten, s.restMinuten);
    });

    test('Ein Stand ohne Schicht schreibt keinen Eintrag; Version 2 läuft ohne Schicht weiter', () {
      final s = neueSitzung(rollen: 4, salz: 'stand-2', daten: einflussDaten);
      spieleBis(s, PartyPhase.gespraeche);
      final stand = jsonDecode(jsonEncode(s.abendstand)) as Map<String, Object?>;
      final einrichten = (stand['befehle'] as List).cast<Map>().firstWhere((b) => b['b'] == 'einrichten');
      expect(einrichten.containsKey('einfluss'), isFalse);
      final r = PartySitzung.fortsetzen(einflussDaten, {...stand, 'format': 'abendstand/2'});
      expect(r.einfluss, isFalse);
      expect(r.momentOffen, isEmpty);
      expect(r.phase, PartyPhase.gespraeche);
      spieleBis(r, PartyPhase.gruppenwahl);
      expect(r.phase, PartyPhase.gruppenwahl, reason: 'Ohne Schicht bleibt die Gruppenwahl');
    });
  });

  testWidgets('Rundenbildschirm: Liste „Dein Moment“, Zwischenstufe, verdeckte Ansicht', (t) async {
    final s = einflussSitzung();
    einflussBis(s, PartyPhase.gespraeche);
    await t.pumpWidget(rahmen(PartyAblauf(sitzung: s)));
    await t.pumpAndSettle();
    expect(find.byType(RundeBildschirm), findsOneWidget);
    expect(find.byKey(const ValueKey('moment-liste')), findsOneWidget);
    await t.ensureVisible(find.byKey(const ValueKey('moment-ahmet')));
    await t.tap(find.byKey(const ValueKey('moment-ahmet')));
    await t.pumpAndSettle();
    await t.tap(find.byKey(const ValueKey('moment-zeig-her')));
    await t.pumpAndSettle();
    expect(s.momentAnsicht, 'ahmet');
    expect(find.byType(MomentBildschirm), findsOneWidget);
    await t.ensureVisible(find.byKey(const ValueKey('zug-helfen')));
    await t.tap(find.byKey(const ValueKey('zug-helfen')));
    await t.pump();
    await t.ensureVisible(find.byKey(const ValueKey('moment-bestaetigen')));
    await t.tap(find.byKey(const ValueKey('moment-bestaetigen')));
    await t.pumpAndSettle();
    expect(s.momentGezogen('ahmet'), isTrue);
    expect(s.verdeckt, isNull);
    expect(find.byType(MomentBildschirm), findsNothing);
    expect(find.text(momentTexte(t.element(find.byType(RundeBildschirm))).moment_zeile('fertig')), findsOneWidget);
  });

  group('Einrichtung', () {
    testWidgets('Schalter „Dein Moment“: an bei Akten mit Regeln, aus im Druckspiel', (t) async {
      final s = PartySitzung(einflussDaten, salz: 'einrichtung');
      final w = EinrichtungsWerte(s);
      addTearDown(w.dispose);
      expect((w.einflussMoeglich, w.einfluss, w.einflussAn), (true, true, true));
      await t.pumpWidget(rahmen(SingleChildScrollView(child: EinrichtungsAbschnitte(werte: w))));
      expect(find.byType(MomentAbschnitt), findsOneWidget);
      await t.ensureVisible(find.byKey(const ValueKey('moment-schalter')));
      await t.tap(find.byKey(const ValueKey('moment-schalter')));
      await t.pump();
      expect(w.einflussAn, isFalse);
      await t.tap(find.byKey(const ValueKey('moment-schalter')));
      await t.pump();
      expect(w.einflussAn, isTrue);
      // Im Druckspiel nie: Papierstreifen A/B bleiben.
      w.setzeSpielart(Spielart.druck);
      await t.pump();
      expect(w.einflussAn, isFalse);
      expect(find.byType(MomentAbschnitt), findsNothing);
      w.setzeSpielart(Spielart.bildschirm);
      w.starten();
      expect(s.einfluss, isTrue);
    });

    test('Akte ohne Regeln: kein Schalter, Abend ohne Schicht', () {
      final s = PartySitzung(partyDaten, salz: 'ohne');
      final w = EinrichtungsWerte(s);
      expect(w.einflussMoeglich, isFalse);
      expect(w.einflussAn, isFalse);
      w.starten();
      expect(s.einfluss, isFalse);
      expect(() => PartySitzung(partyDaten).einrichten(rollen: 4, detektiv: 'w', einfluss: true), throwsArgumentError);
      w.dispose();
    });

    test('Wer macht was: Aufgaben mit „Dein Moment“', () {
      final l = LDe();
      expect(aufgabe(l, Spielweise.reihum, Sitz.rolle, UebersichtPhase.gespraeche, einfluss: true), l.aufgabe_rolle_moment);
      expect(aufgabe(l, Spielweise.eigene, Sitz.detektiv, UebersichtPhase.entscheidungen, einfluss: true), l.aufgabe_detektiv_tischwerte);
      expect(aufgabe(l, Spielweise.eigene, Sitz.erzaehler, UebersichtPhase.entscheidungen, einfluss: true), l.aufgabe_erzaehler_folgen);
      // Ohne Schicht wie bisher.
      expect(aufgabe(l, Spielweise.reihum, Sitz.rolle, UebersichtPhase.gespraeche), l.aufgabe_rolle_gespraeche);
    });
  });
}
