import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mordakte/party/bildschirme/befragung.dart';
import 'package:mordakte/party/bildschirme/einrichtung.dart';
import 'package:mordakte/party/bildschirme/gruppenwahl.dart';
import 'package:mordakte/party/bildschirme/karte.dart';
import 'package:mordakte/party/bildschirme/rollen.dart';
import 'package:mordakte/party/bildschirme/solo_gespraeche.dart';
import 'package:mordakte/party/party_seite.dart';
import 'package:mordakte/party/sitzung.dart';
import 'package:mordakte/party/skript.dart';
import 'package:mordakte/party/stand/befragung_stand.dart';
import 'package:mordakte_core/mordakte_core.dart';
import 'package:mordakte_core/runden.dart';

import 'hilfe.dart';

Future<void> zeigen(WidgetTester t, Widget child, double breite, double schrift) async {
  t.view.physicalSize = Size(breite, 844);
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.resetPhysicalSize);
  addTearDown(t.view.resetDevicePixelRatio);
  await t.pumpWidget(MaterialApp(theme: ThemeData.dark(), builder: (context, child) => MediaQuery(
    data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(schrift)), child: child!,
  ), home: Scaffold(body: child)));
  await t.pump();
}

Future<void> tippen(WidgetTester t, String text) async {
  final f = find.text(text);
  await t.ensureVisible(f);
  await t.tap(f);
  await t.pump();
}

void main() {
  test('Solo schützt Bot-Karten auch auf Sitzungsebene und lehnt den Druckmodus ab', () {
    final s = neueSitzung();
    expect(() => s.einrichten(rollen: 4, detektiv: 'w', solo: true, druck: true), throwsArgumentError);
    expect(s.phase, PartyPhase.titel);
    s.einrichten(rollen: 4, detektiv: 'w', solo: true, detektivName: 'Mira');
    expect(s.solo, isTrue);
    expect(s.mitWuerfel, isTrue);
    expect(s.wuerfelPate, 'Mira');
    for (final r in s.besetzt) {
      expect(() => s.zeigeVerdeckt(r), throwsStateError);
      expect(() => s.dossier(r), throwsStateError);
      expect(() => s.istTaeter(r), throwsStateError);
      expect(() => s.wahl(r), throwsStateError);
    }
    expect(s.verdeckt, isNull);
    s.dispose();
  });

  test('Fortschritt vertauscht Gesprächsnummer und Gesamtzahl nicht', () {
    final s = neueSitzung();
    expect(s.ui('ui.solo.fortschritt', {'nr': '2', 'gesamt': '15'}), 'Gespräch 2 von 15');
    s.dispose();
  });

  test('Befragungen sperren die nächste Entscheidung; die Antwort kommt erst nach der Frage und bleibt im Notizbuch', () {
    final s = neueSitzung(rollen: 4, solo: true);
    spieleBis(s, PartyPhase.gespraeche);
    expect(s.befragungsmodell, isTrue);
    expect(s.soloGespraeche, isEmpty, reason: 'Im Modell befragung keine öffentlichen Sprechblasen');
    final plan = Befragungsplan(partyDaten.texte).fuer(4, 1);
    expect([for (final k in s.befragungen) k.rolle], [...plan.pflicht, ...plan.frei]);
    expect(s.befragungen.every((k) => k.antwort == null && !k.mensch), isTrue);
    expect(s.kannWeiter, isFalse);
    expect(() => s.weiter(), throwsStateError);
    expect(() => s.befragen('bf_ahmet_3', 0), throwsArgumentError, reason: 'nicht in dieser Runde');
    expect(s.befragungsNotizen, isEmpty);
    final pflicht = s.befragungen.firstWhere((k) => k.pflicht);
    expect(() => s.befragen(pflicht.id, pflicht.fragen.length), throwsArgumentError);
    s.befragen(pflicht.id, 1);
    final gefragt = s.befragungen.firstWhere((k) => k.id == pflicht.id);
    expect(gefragt.frage, 1);
    expect(gefragt.erledigt, isTrue, reason: 'Im Solo antwortet die App sofort');
    expect(gefragt.antwort, botAntwort(partyDaten.texte, plan.text(pflicht.rolle)));
    // Freie Wahlen: genau so viele, wie die Runde erlaubt; danach sind die übrigen gesperrt.
    final frei = [for (final k in s.befragungen) if (!k.pflicht) k];
    for (var w = 0; w < plan.freiWahlen; w++) {
      s.befragen(frei[w].id, 0);
    }
    expect(s.befragungenFrei, 0);
    for (final k in frei.skip(plan.freiWahlen)) {
      expect(s.befragungVon(k.rolle)!.waehlbar, isFalse);
      expect(() => s.befragen(k.id, 0), throwsArgumentError);
    }
    PartySkript.befragungenErledigen(s);
    expect(s.kannWeiter, isTrue);
    expect(s.befragungsNotizen, hasLength(plan.gesamt));
    final notizen = s.befragungsNotizen;
    expect(() => notizen.clear(), throwsUnsupportedError);
    s.weiter();
    expect(s.phase, PartyPhase.entscheidungen);
    expect(s.befragungsNotizen.map((k) => k.id), notizen.map((k) => k.id));
    expect(() => s.befragen(frei.last.id, 0), throwsStateError);
    s.dispose();
  });

  testWidgets('E-044: Solo mit 4 Rollen erzählt zum Rundenstart das Wissen unbesetzter Zielfiguren', (t) async {
    final s = neueSitzung(rollen: 4, solo: true);
    spieleBis(s, PartyPhase.gespraeche);
    expect(s.erzaehler, ['runde.1.start', 'npc.emine.1', 'npc.dilara.1', 'npc.enes.1']);
    await zeigen(t, bildschirm(s), 390, 1);
    expect(find.byType(BefragungBildschirm), findsOneWidget);
    for (final k in s.erzaehler) {
      expect(find.text(s.text(k)), findsOneWidget, reason: k);
    }
    await t.pumpWidget(const SizedBox());
    s.dispose();
  });

  test('Solo mit dauerhaftem Pech: 4–20 Rollen und alle Pfade vollständig lösbar', () {
    final plan = Befragungsplan(partyDaten.texte);
    for (final pfad in partyDaten.kanon.pfade) {
      for (var n = 4; n <= 20; n++) {
        final s = neueSitzung(rollen: n, pfad: pfad, solo: true, salz: 'solo-probe', wuerfel: const FesterWuerfel.pech());
        // Je Runde drei bis fünf Befragungen statt aller Bot-Gespräche. Was eine unbesetzte Figur weiß, sagt der
        // Erzähler zum Rundenstart, auch bei Zielfiguren (E-044).
        final zustellung = plan.zustellung(n);
        for (var r = 1; r <= 3; r++) {
          spieleBis(s, PartyPhase.gespraeche, runde: r);
          expect(s.befragungen.where((k) => k.pflicht).length + s.befragungenFrei, inInclusiveRange(3, 5), reason: '$pfad / $n / Runde $r');
          for (final z in zustellung.values.where((z) => z.weg == Zustellweg.npc && z.runde == r)) {
            expect(s.erzaehler, contains('npc.${z.halter}.$r'), reason: '$pfad / $n: ${z.glied}');
          }
        }
        spieleBis(s, PartyPhase.ende);
        expect(s.ende.id, 'ende_meister', reason: '$pfad / $n');
        expect(s.spiel.punkte, 9);
        expect(s.spiel.restmenge(), {pfad});
        expect(s.soloNotizen, isEmpty);
        expect(s.befragungsNotizen.length, inInclusiveRange(9, 15));
        // Jedes Tisch-Kettenglied, das eine Befragung zustellt, hat der Detektiv rechtzeitig gehört.
        expect(zustellung.keys.toSet(), plan.glieder.keys.toSet(), reason: '$n Rollen: jedes Glied hat einen Weg');
        for (final z in zustellung.values.where((z) => z.weg == Zustellweg.befragung)) {
          final k = s.befragungsNotizen.firstWhere((k) => k.id == BefragungText.kennung(z.halter, z.runde), orElse: () => throw TestFailure('$pfad / $n: ${z.glied} nicht gehört'));
          // Gehört hat er die Kanon-Kurzfassung derselben Preisgabe (E-044).
          expect(k.antwort, containsAllInOrder(oeffentlicheKurzfassung(partyDaten.texte, z.halter, z.glied).antwort), reason: '$pfad / $n: ${z.glied}');
        }
        for (var r = 1; r <= 3; r++) {
          final stimmen = {for (final rolle in s.besetzt) rolle: botKooperativ(salz: 'solo-probe', rolle: rolle, runde: r)};
          final q = s.spiel.gruppe.auswerten(rollen: n,
            kooperativ: stimmen.entries.where((e) => e.key != pfad && e.value).length,
            taeterSabotiert: stimmen[pfad] == false);
          expect(s.spiel.qualitaeten[r], q);
        }
        s.dispose();
      }
    }
  });

  test('Gleiche Wahlen liefern in Party und Solo dasselbe Würfelprotokoll und dieselben Funde', () {
    for (final pfad in partyDaten.kanon.pfade) {
      final solo = neueSitzung(rollen: 4, pfad: pfad, solo: true, salz: 'gleich', wuerfel: SalzWuerfel('gleich'));
      final party = neueSitzung(rollen: 4, pfad: pfad, salz: 'gleich', wuerfel: SalzWuerfel('gleich'));
      spieleBis(solo, PartyPhase.ende);
      spieleBis(party, PartyPhase.ende);
      expect(solo.wuerfe.map((w) => w.toJson()), party.wuerfe.map((w) => w.toJson()));
      expect(solo.spiel.bekannteFakten(), party.spiel.bekannteFakten());
      expect(solo.funde.map((k, v) => MapEntry(k, v.map((f) => f.text).toList())),
        party.funde.map((k, v) => MapEntry(k, v.map((f) => f.text).toList())));
      solo.dispose(); party.dispose();
    }
  });

  testWidgets('Einrichtung bietet Solo ohne Spielernamen oder Druckbogen und startet echte Bot-Rollen', (t) async {
    final s = neueSitzung()..zurEinrichtung();
    await zeigen(t, EinrichtungBildschirm(sitzung: s), 390, 1);
    await tippen(t, s.ui('ui.solo.solo'));
    expect(find.byKey(const ValueKey('name-ahmet')), findsNothing);
    expect(find.text(s.ui('ui.einrichtung.spiel_druck')), findsNothing);
    expect(find.text(s.ui('ui.solo.name').toUpperCase()), findsOneWidget);
    await tippen(t, s.ui('ui.einrichtung.start'));
    expect(s.solo, isTrue);
    expect(s.phase, PartyPhase.rollen);
    expect(s.besetzt, hasLength(7));
    expect(s.einstellungen.druck, isFalse);
    expect(t.takeException(), isNull);
    await t.pumpWidget(const SizedBox());
    s.dispose();
  });

  testWidgets('Bot-Rollen sind keine aufdeckbaren Karten', (t) async {
    final s = neueSitzung(rollen: 4, solo: true);
    await zeigen(t, RollenBildschirm(sitzung: s), 320, 2);
    await tippen(t, s.figurName('ahmet'));
    expect(s.verdeckt, isNull);
    expect(find.text(s.ui('ui.verdeckt.frage', {'name': s.spielerName('ahmet')})), findsNothing);
    expect(find.text(s.ui('ui.rollen.verbirgt_titel')), findsNothing);
    expect(t.takeException(), isNull);
    await t.pumpWidget(const SizedBox());
    s.dispose();
  });

  for (final breite in [320.0, 390.0]) {
    for (final schrift in [1.0, 2.0]) {
      testWidgets('Solo-Befragungen und automatische Wahl bei $breite px / Schrift $schrift', (t) async {
        final s = neueSitzung(rollen: 20, solo: true);
        spieleBis(s, PartyPhase.gespraeche);
        await zeigen(t, bildschirm(s), breite, schrift);
        expect(find.byType(BefragungBildschirm), findsOneWidget);
        expect(find.byType(SoloGespraecheBildschirm), findsNothing);
        final karten = s.befragungen;
        final antworten = {
          for (final k in karten)
            for (final a in botAntwort(partyDaten.texte, partyDaten.texte.sammlung.befragungen[k.id]!)) a,
        };
        // Feste Befragungen als volle Karten, freie als schmale Zeilen zur Wahl.
        final plan = Befragungsplan(partyDaten.texte).fuer(20, 1);
        for (final k in karten) {
          expect(find.byKey(ValueKey(k.pflicht ? k.id : 'wahl-${k.id}')), findsOneWidget, reason: k.id);
        }
        expect(find.byType(BefragungsKarte), findsNWidgets(plan.pflicht.length));
        for (final k in karten.where((k) => !k.pflicht)) {
          final zeile = find.byKey(ValueKey('wahl-${k.id}'));
          expect(find.descendant(of: zeile, matching: find.text(k.thema)), findsOneWidget, reason: k.id);
          expect(find.descendant(of: zeile, matching: find.text(k.fragen.first)), findsNothing, reason: 'Zur Wahl nur Name und Thema: ${k.id}');
        }
        for (final a in antworten) {
          expect(find.text(a), findsNothing, reason: 'Vor der Frage keine Antwort: $a');
        }
        expect(find.text(s.ui('ui.runde.weiter')), findsNothing);
        expect(find.text(s.ui('ui.rollen.verbirgt_titel')), findsNothing);
        // Höchstens drei Zeilen am Tisch aufgeschnappt, nur Paarung und Thema.
        expect(find.byType(TischZeile), findsNWidgets(3));
        final fragen = {for (final k in karten) ...k.fragen};
        for (final g in partyDaten.texte.sammlung.gespraeche.where((g) => g.runde == 1)) {
          for (final p in g.stichpunkte.where((p) => !fragen.contains(p))) {
            expect(find.text(p), findsNothing, reason: 'Stichpunkt am Tisch: $p');
          }
        }
        Future<void> frage(BefragungKarte k) async {
          if (!k.pflicht) {
            // Ein Tipp klappt die freie Befragung auf.
            final zeile = find.byKey(ValueKey('wahl-${k.id}'));
            await t.ensureVisible(zeile);
            await t.tap(zeile);
            await t.pump();
          }
          final f = find.descendant(of: find.byKey(ValueKey(k.id)), matching: find.text(k.fragen.first));
          await t.ensureVisible(f);
          await t.tap(f);
          await t.pump();
          expect(t.takeException(), isNull);
        }
        for (final k in karten.where((k) => k.pflicht)) {
          await frage(k);
          final antwort = s.befragungVon(k.rolle)!.antwort!;
          expect(antwort, isNotEmpty);
          expect(find.descendant(of: find.byKey(ValueKey(k.id)), matching: find.text(antwort.first)), findsOneWidget, reason: k.id);
        }
        expect(plan.freiWahlen, inInclusiveRange(1, 2));
        for (final k in karten.where((k) => !k.pflicht).take(plan.freiWahlen)) {
          await frage(k);
        }
        expect(s.befragungenFertig, isTrue);
        await t.pump();
        expect(find.text(s.ui('ui.befragung.fertig')), findsOneWidget);
        expect(find.text(s.ui('ui.runde.weiter')), findsOneWidget);
        expect(s.befragungsNotizen, hasLength(plan.gesamt));
        // Am Ende stehen drei bis fünf Karten da, keine Zeile mehr zur Wahl.
        expect(find.byType(BefragungsKarte), findsNWidgets(plan.gesamt));
        expect(plan.gesamt, inInclusiveRange(3, 5));
        expect(find.byWidgetPredicate((w) => w.key is ValueKey<String> && (w.key! as ValueKey<String>).value.startsWith('wahl-')), findsNothing);
        await t.pumpWidget(const SizedBox());
        spieleBis(s, PartyPhase.gruppenwahl);
        expect(s.alleGestimmt, isTrue);
        expect(s.kannWeiter, isTrue);
        await zeigen(t, GruppenwahlBildschirm(sitzung: s), breite, schrift);
        expect(find.text(s.ui('ui.solo.gruppenwahl')), findsOneWidget);
        expect(find.text(s.ui('ui.verdeckt.frage', {'name': s.spielerName('ahmet')})), findsNothing);
        expect(t.takeException(), isNull);
        await t.pumpWidget(const SizedBox());
        s.dispose();
      });
    }
  }

  testWidgets('Browserproben finden Karten, Fragen und freie Wahlen über Semantik-Kennungen', (t) async {
    final semantik = t.ensureSemantics();
    final s = neueSitzung(rollen: 7, solo: true);
    spieleBis(s, PartyPhase.gespraeche);
    await zeigen(t, bildschirm(s), 390, 1);
    final pflicht = s.befragungen.firstWhere((k) => k.pflicht);
    final frei = s.befragungen.firstWhere((k) => !k.pflicht);
    await t.ensureVisible(find.byKey(ValueKey(pflicht.id)));
    expect(find.bySemanticsIdentifier('befragung-${pflicht.id}'), findsOneWidget);
    for (var i = 0; i < pflicht.fragen.length; i++) {
      expect(find.bySemanticsIdentifier('befragung-frage-${pflicht.id}-$i'), findsOneWidget, reason: '$i');
    }
    await t.ensureVisible(find.byKey(ValueKey('wahl-${frei.id}')));
    expect(find.bySemanticsIdentifier('befragung-waehlen-${frei.id}'), findsOneWidget);
    await t.pumpWidget(const SizedBox());
    semantik.dispose();
    s.dispose();
  });

  testWidgets('Altakte (Modell legacy): Solo-Sprechblasen wie bisher, dann die Karte', (t) async {
    final d = akteDaten('gewoelbe');
    final s = PartySitzung(d, wuerfel: const FesterWuerfel.neutral())
      ..einrichten(rollen: 4, detektiv: 'w', solo: true, code: FallCode.fuerPfad(d.kanon.pfade.first, d.kanon.pfade).code);
    spieleBis(s, PartyPhase.gespraeche);
    expect(s.befragungsmodell, isFalse);
    expect(s.befragungen, isEmpty);
    await zeigen(t, bildschirm(s), 390, 1);
    expect(find.byType(SoloGespraecheBildschirm), findsOneWidget);
    expect(find.text('Gespräch 1 von ${s.soloGespraeche.length}'), findsOneWidget);
    for (final _ in s.soloGespraeche) {
      await tippen(t, s.ui('ui.solo.gehoert'));
    }
    expect(find.text(s.ui('ui.runde.weiter')), findsOneWidget);
    expect(t.takeException(), isNull);
    await t.pumpWidget(const SizedBox());
    s.dispose();
  });

  testWidgets('Notizbuch zeigt die Antworten der Befragungen, keine Bot-Dossiers', (t) async {
    final s = neueSitzung(rollen: 4, solo: true);
    spieleBis(s, PartyPhase.entscheidungen);
    await zeigen(t, KartenBildschirm(sitzung: s), 390, 1);
    await tippen(t, s.ui('ui.karte.notizbuch'));
    expect(s.befragungsNotizen, isNotEmpty);
    expect(find.byType(BefragungsKarte), findsNWidgets(s.befragungsNotizen.length));
    expect(find.text(s.ui('ui.befragung.notizen')), findsOneWidget);
    expect(find.byType(BotSprechblase), findsNothing);
    expect(find.text(s.ui('ui.rollen.verbirgt_titel')), findsNothing);
    expect(find.text(s.ui('ui.karte.notizbuch_leer')), findsNothing);
    expect(t.takeException(), isNull);
    await t.pumpWidget(const SizedBox());
    s.dispose();
  });

  // Prüfung M2z (R17, E-044): Wojteks Antwort hat zwei Karten. Hintereinander las sich „an ihm vorbei“ als Schneider
  // oder Olli; jede Karte ist deshalb ein eigenes Zitat, das Notizbuch zeigt sie genauso.
  testWidgets('Antwort der App: je Preisgabe ein eigenes Zitat mit höchstens drei Stichpunkten', (t) async {
    final s = neueSitzung(rollen: 20, solo: true);
    spieleBis(s, PartyPhase.gespraeche);
    final texte = partyDaten.texte;
    final b = texte.sammlung.befragungen['bf_kaan_1']!;
    final k = BefragungKarte(
      id: b.id, rolle: b.rolle, thema: b.thema, fragen: b.fragen, pflicht: true, mensch: false,
      frage: 0, erledigt: true, waehlbar: false, antwortKarten: befragungsKarten(texte, b),
    );
    expect(k.antwortKarten, hasLength(2));
    expect(k.antwort, botAntwort(texte, b));
    await zeigen(t, SingleChildScrollView(child: BefragungsKarte(sitzung: s, karte: k)), 390, 1);
    final zitate = find.byType(AussageKarte);
    expect(zitate, findsNWidgets(2));
    for (final (i, karte) in k.antwortKarten!.indexed) {
      expect(karte.length, inInclusiveRange(1, 3));
      for (final z in karte) {
        expect(find.descendant(of: zitate.at(i), matching: find.text(z)), findsOneWidget, reason: z);
      }
    }
    // Was die App im Solo antwortet, kommt als dieselben Karten.
    PartySkript.befragungenErledigen(s);
    for (final n in s.befragungsNotizen) {
      expect(n.antwortKarten, befragungsKarten(texte, texte.sammlung.befragungen[n.id]!), reason: n.id);
    }
    expect(t.takeException(), isNull);
    await t.pumpWidget(const SizedBox());
    s.dispose();
  });

  // E-044: Das Wissen unbesetzter Gäste spricht der Erzähler nur zum Rundenstart. Bei vier Rollen trägt
  // npc.emine.1 die Ketten von e1_2 und (Pfad Fatma) e3_1; mit sechs Rollen steht dasselbe als Antwort
  // von Emine im Notizbuch. Nachlesen darf nicht an der Rollenzahl hängen.
  testWidgets('Notizbuch behält, was der Erzähler für unbesetzte Gäste sprach (E-044)', (t) async {
    final s = neueSitzung(rollen: 4, pfad: 'fatma', solo: true);
    spieleBis(s, PartyPhase.entscheidungen, runde: 3);
    expect(s.laufendeEntscheidung?.id, 'e3_1');
    expect(s.erzaehler.where((k) => k.startsWith('npc.')), isEmpty, reason: 'Das Erzählerfenster trägt das Wissen nicht mehr');
    final gesprochen = [for (final k in s.spiel.bausteine) if (k.startsWith('npc.')) k];
    expect(gesprochen, containsAll(['npc.emine.1', 'npc.dilara.1', 'npc.enes.1']));
    await zeigen(t, KartenBildschirm(sitzung: s), 390, 1);
    await tippen(t, s.ui('ui.karte.notizbuch'));
    expect(find.text(s.ui('ui.befragung.erzaehler_notizen')), findsOneWidget);
    for (final k in gesprochen) {
      expect(find.text(s.text(k)), findsOneWidget, reason: k);
    }
    expect(s.erzaehlerNotizen, gesprochen.toSet().toList());
    expect(t.takeException(), isNull);
    await t.pumpWidget(const SizedBox());
    s.dispose();

    // Schon bei den Entscheidungen der ersten Runde: e1_1 bis e1_3 brauchen Damir, Emine und Azra.
    final r1 = neueSitzung(rollen: 4, pfad: 'fatma', solo: true);
    spieleBis(r1, PartyPhase.entscheidungen, runde: 1);
    expect(r1.erzaehlerNotizen, ['npc.emine.1', 'npc.dilara.1', 'npc.enes.1']);
    r1.dispose();
    // Pfadfrei: Was der Erzähler sprach, hängt nur an Runde und Besetzung (S-1).
    for (final pfad in partyDaten.kanon.pfade) {
      final p = neueSitzung(rollen: 4, pfad: pfad, solo: true);
      spieleBis(p, PartyPhase.entscheidungen, runde: 3);
      expect(p.erzaehlerNotizen, s.erzaehlerNotizen, reason: pfad);
      p.dispose();
    }
    // Mit sechs Rollen spielt jemand Emine; ihr Wissen kommt dann aus ihrer Befragung.
    final sechs = neueSitzung(rollen: 6, pfad: 'fatma', solo: true);
    spieleBis(sechs, PartyPhase.entscheidungen, runde: 1);
    expect(sechs.erzaehlerNotizen, ['npc.dilara.1', 'npc.enes.1']);
    sechs.dispose();
    // Altakte (Modell legacy): Das Notizbuch bleibt wie bisher.
    final d = akteDaten('gewoelbe');
    final alt = PartySitzung(d, wuerfel: const FesterWuerfel.neutral())
      ..einrichten(rollen: 4, detektiv: 'w', solo: true, code: FallCode.fuerPfad(d.kanon.pfade.first, d.kanon.pfade).code);
    spieleBis(alt, PartyPhase.entscheidungen);
    expect(alt.erzaehlerNotizen, isEmpty);
    alt.dispose();
  });
}
