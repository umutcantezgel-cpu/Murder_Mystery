// F4-BAUMEISTER-03: Rundenzentrale mit Uhr und Pflichtgesprächen (Master 7.6 Schritt 5).
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mordakte_core/mordakte_core.dart';
import 'package:mordakte/party/bildschirme/runde.dart';
import 'package:mordakte/party/bildschirme/spickzettel.dart';
import 'package:mordakte/party/party_stil.dart';
import 'package:mordakte/party/runden_uhr.dart' show SitzungsUhr;
import 'package:mordakte/party/sitzung.dart';
import 'package:mordakte/party/skript.dart';
import 'package:mordakte/stil/mappe/zeichen.dart' show MStempel;
import 'package:mordakte/stil/widgets/m_knopf.dart' show MKnopf;
import 'package:mordakte_core/runden.dart' show FesterWuerfel, UhrAktion, botAntwort;

import 'hilfe.dart';

/// Runde 1 mit einer Uhr von fünf Sekunden auf dem Bildschirm. Die Uhr ist die
/// der Sitzung ([PartySitzung.uhr], M4); ihre Abendzeit folgt der Testuhr.
Future<PartySitzung> _uhrBild(WidgetTester t) async {
  final s = neueSitzung(rollen: 7);
  spieleBis(s, PartyPhase.gespraeche);
  s.rundendauer = const Duration(seconds: 5);
  testAbendzeit(t, s);
  await t.pumpWidget(rahmen(ListenableBuilder(listenable: s, builder: (_, _) => RundeBildschirm(sitzung: s))));
  return s;
}

/// Tippt einen Knopf der Uhr. Der Bildschirm ist lang, daher erst in den Blick scrollen.
Future<void> _tippe(WidgetTester t, String tipp) async {
  final knopf = find.byTooltip(tipp);
  await t.ensureVisible(knopf);
  await t.tap(knopf);
}

void main() {
  testWidgets('Runde 1 zeigt Rundennamen und Uhrzeit 00:30', (t) async {
    final s = neueSitzung(rollen: 7);
    spieleBis(s, PartyPhase.gespraeche, runde: 1);
    await t.pumpWidget(rahmen(RundeBildschirm(sitzung: s)));
    expect(find.text(s.rundenName), findsOneWidget);
    expect(find.textContaining('00:30'), findsOneWidget);
  });

  testWidgets('E-044: Reihum liest der Vorleser zum Rundenstart das Wissen unbesetzter Zielfiguren vor', (t) async {
    final s = neueSitzung(rollen: 12);
    spieleBis(s, PartyPhase.gespraeche, runde: 3);
    // 12 Rollen: Zeynep ist besetzt, Aylin, Wojtek und Sibel spielt niemand.
    expect(s.erzaehler, ['runde.3.start', 'npc.aylin.3', 'npc.kaan.3', 'npc.selin.3']);
    await t.pumpWidget(rahmen(RundeBildschirm(sitzung: s)));
    for (final k in s.erzaehler) {
      expect(find.text(s.text(k)), findsOneWidget, reason: k);
    }
    expect(find.text(s.text('npc.zeynep.3')), findsNothing);
  });

  testWidgets('Runde 2 zeigt Uhrzeit 01:15', (t) async {
    final s = neueSitzung(rollen: 7);
    spieleBis(s, PartyPhase.gespraeche, runde: 2);
    await t.pumpWidget(rahmen(RundeBildschirm(sitzung: s)));
    expect(find.text(s.rundenName), findsOneWidget);
    expect(find.textContaining('01:15'), findsOneWidget);
  });

  testWidgets('Uhr startet bei der Rundendauer', (t) async {
    await _uhrBild(t);
    expect(find.text('00:05'), findsOneWidget);
  });

  testWidgets('Uhr läuft nach Start herunter', (t) async {
    final s = await _uhrBild(t);
    await _tippe(t, s.ui('ui.runde.start'));
    await t.pump(const Duration(seconds: 2));
    expect(find.text('00:03'), findsOneWidget);
  });

  testWidgets('Pause hält die Uhr an', (t) async {
    final s = await _uhrBild(t);
    await _tippe(t, s.ui('ui.runde.start'));
    await t.pump(const Duration(seconds: 2));
    await _tippe(t, s.ui('ui.runde.pause'));
    await t.pump(const Duration(seconds: 3));
    expect(find.text('00:03'), findsOneWidget);
    expect(find.byKey(const ValueKey('rundenuhr-angehalten')), findsOneWidget);
    expect(s.uhr.pausiert, isTrue);
  });

  testWidgets('Nach der Pause läuft die Uhr genau von dort weiter', (t) async {
    final s = await _uhrBild(t);
    await _tippe(t, s.ui('ui.runde.start'));
    await t.pump(const Duration(seconds: 1));
    await _tippe(t, s.ui('ui.runde.pause'));
    await t.pump(const Duration(seconds: 10));
    expect(find.byTooltip(s.ui('ui.runde.start')), findsNothing, reason: 'Nach der Pause heißt der Knopf Weiter');
    await _tippe(t, s.ui('ui.runde.weiterlaufen'));
    await t.pump(const Duration(seconds: 2));
    expect(find.text('00:02'), findsOneWidget);
    expect(find.byKey(const ValueKey('rundenuhr-angehalten')), findsNothing);
  });

  testWidgets('Plus gibt fünf Minuten dazu, auch wenn die Zeit schon um ist', (t) async {
    final s = await _uhrBild(t);
    await _tippe(t, s.ui('ui.runde.start'));
    await t.pump(const Duration(seconds: 2));
    await _tippe(t, s.ui('ui.runde.plus'));
    await t.pump();
    expect(find.text('05:03'), findsOneWidget);
    expect(s.uhr.dauer, const Duration(minutes: 5, seconds: 5).inMilliseconds);
    await t.pump(const Duration(minutes: 6));
    expect(find.text(s.ui('ui.runde.zeit_um')), findsOneWidget);
    await _tippe(t, s.ui('ui.runde.plus'));
    await t.pump(const Duration(seconds: 1));
    expect(find.text('04:59'), findsOneWidget, reason: 'Die Zugabe zählt ab jetzt');
    expect(find.text(s.ui('ui.runde.zeit_um')), findsNothing);
  });

  testWidgets('Der Bildschirm zeigt die Uhr der Sitzung; jede Runde beginnt mit gestellter Uhr', (t) async {
    final s = await _uhrBild(t);
    // Gestellt von außen (am Tisch: dasselbe Gerät, online der Raum): Der Bildschirm zeigt sie.
    expect(s.uhrAktion(UhrAktion.start, minuten: 2), isTrue);
    await t.pump(const Duration(seconds: 30));
    expect(find.text('01:30'), findsOneWidget);
    expect(s.uhrAktion(UhrAktion.weiter), isFalse, reason: 'Weiter ohne Pause passt nicht');
    spieleBis(s, PartyPhase.gespraeche, runde: 2);
    expect(s.uhr.gestartet, isFalse);
    expect(s.uhr.dauer, const Duration(seconds: 5).inMilliseconds);
    await t.pump();
    expect(find.text('00:05'), findsOneWidget);
  });

  testWidgets('Langer Abend (M7b): Die Uhr am Tisch läuft in den Entscheidungen weiter, eine neue Runde stellt sie neu', (t) async {
    final s = PartySitzung(langDaten, wuerfel: const FesterWuerfel.neutral())
      ..einrichten(rollen: 7, detektiv: 'w', code: FallCode.fuerPfad('ahmet', langDaten.kanon.pfade).code, rundendauerMinuten: 20, fassung: Abendfassung.lang);
    testAbendzeit(t, s);
    spieleBis(s, PartyPhase.gespraeche);
    await t.pumpWidget(rahmen(ListenableBuilder(listenable: s, builder: (_, _) => SitzungsUhr(sitzung: s))));
    expect(find.text('20:00'), findsOneWidget);
    expect(s.uhrAktion(UhrAktion.start), isTrue);
    await t.pump(const Duration(minutes: 1));
    spieleBis(s, PartyPhase.entscheidungen);
    expect(s.uhrInPhase, isTrue);
    await t.pump(const Duration(seconds: 30));
    expect(find.text('18:30'), findsOneWidget, reason: 'Dieselbe Uhr wie in den Gesprächen');
    spieleBis(s, PartyPhase.gespraeche, runde: 2);
    await t.pump();
    expect(find.text('20:00'), findsOneWidget);
    await t.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('bei 0 erscheint der Baustein Die Zeit ist um', (t) async {
    final s = await _uhrBild(t);
    await _tippe(t, s.ui('ui.runde.start'));
    await t.pump(const Duration(seconds: 6));
    expect(find.text('00:00'), findsOneWidget);
    expect(find.text(s.ui('ui.runde.zeit_um')), findsOneWidget);
  });

  testWidgets('bei 0 bleibt die Uhr stehen und schaltet nicht weiter', (t) async {
    final s = await _uhrBild(t);
    await _tippe(t, s.ui('ui.runde.start'));
    await t.pump(const Duration(seconds: 9));
    expect(find.text('00:00'), findsOneWidget);
    expect(s.phase, PartyPhase.gespraeche);
  });

  testWidgets('jede Paarung am Tisch nennt Sprecher, Partner und Thema mit Namen', (t) async {
    final s = PartySitzung(partyDaten);
    s.einrichten(
      rollen: 7,
      detektiv: 'w',
      code: FallCode.fuerPfad('ahmet', partyDaten.kanon.pfade).code,
      namen: {'ahmet': 'Lena'},
    );
    spieleBis(s, PartyPhase.gespraeche);
    await t.pumpWidget(rahmen(RundeBildschirm(sitzung: s)));
    final tisch = s.tisch(s.runde);
    expect(tisch, hasLength(7), reason: 'Ein Tischgespräch je Rolle');
    for (final z in tisch) {
      final zeile = find.byKey(ValueKey('tisch-${z.id}'));
      final paarung = s.ui('ui.runde.paarung', {'sprecher': s.spielerName(z.rolle), 'partner': s.personAmTisch(z.partner)});
      expect(find.descendant(of: zeile, matching: find.text(paarung)), findsOneWidget, reason: z.id);
      expect(find.descendant(of: zeile, matching: find.text(z.thema)), findsOneWidget, reason: z.id);
      expect(z.partner, isNot(Besetzung.detektiv), reason: 'Der Detektiv sitzt nicht am Tisch');
    }
    expect(find.textContaining('Lena'), findsWidgets);
  });

  testWidgets('kein Ziel eines Gesprächs ist sichtbar', (t) async {
    final s = neueSitzung(rollen: 7);
    spieleBis(s, PartyPhase.gespraeche, runde: 2);
    await t.pumpWidget(rahmen(RundeBildschirm(sitzung: s)));
    final gespraeche = s.gespraeche(2);
    expect(gespraeche, isNotEmpty);
    for (final z in gespraeche) {
      expect(z.gespraech.ziel, isNotEmpty);
      expect(find.textContaining(z.gespraech.ziel), findsNothing, reason: z.gespraech.id);
    }
  });

  testWidgets('kein Stichpunkt und keine Antwort sind am Tisch sichtbar, nur Fragen des Detektivs', (t) async {
    final s = neueSitzung(rollen: 7);
    spieleBis(s, PartyPhase.gespraeche, runde: 2);
    await t.pumpWidget(rahmen(RundeBildschirm(sitzung: s)));
    for (final z in s.gespraeche(2)) {
      expect(z.gespraech.text, isEmpty, reason: 'Modell befragung: Stichpunkte statt Eröffnungssatz');
      for (final p in z.gespraech.stichpunkte) {
        expect(find.text(p), findsNothing, reason: z.gespraech.id);
      }
    }
    final karten = s.befragungen;
    expect(karten, isNotEmpty);
    for (final k in karten) {
      expect(find.byKey(ValueKey(k.pflicht ? k.id : 'wahl-${k.id}')), findsOneWidget, reason: k.id);
      final b = partyDaten.texte.sammlung.befragungen[k.id]!;
      final z = befragungsZettel(partyDaten.texte, b);
      for (final a in [...z.sagen, ...z.behaupten, ...z.eigene, ...botAntwort(partyDaten.texte, b)]) {
        expect(find.text(a), findsNothing, reason: '${k.id}: $a');
      }
    }
  });

  testWidgets('Weiter wartet auf die Befragungen; eine Frage am Tisch geht verdeckt an die Person', (t) async {
    t.view.physicalSize = const Size(390, 844);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.view.resetDevicePixelRatio);
    final s = neueSitzung(rollen: 7);
    spieleBis(s, PartyPhase.gespraeche);
    await t.pumpWidget(rahmen(ListenableBuilder(listenable: s, builder: (_, _) => RundeBildschirm(sitzung: s))));
    expect(s.kannWeiter, isFalse);
    await t.tap(find.text(s.ui('ui.runde.weiter')));
    await t.pump();
    expect(s.phase, PartyPhase.gespraeche, reason: 'Weiter ist gesperrt');
    final k = s.befragungen.firstWhere((k) => k.pflicht);
    final name = s.spielerName(k.rolle);
    final frage = find.descendant(of: find.byKey(ValueKey(k.id)), matching: find.text(k.fragen.last));
    await t.ensureVisible(frage);
    await t.tap(frage);
    await t.pump();
    // Zwischenstufe: Das Gerät geht kurz an die befragte Person, ihr Zettel bleibt zu.
    expect(find.text(s.ui('ui.befragung.geraet', {'name': name})), findsOneWidget);
    expect(s.verdeckt, isNull);
    final zettel = befragungsZettel(partyDaten.texte, partyDaten.texte.sammlung.befragungen[k.id]!);
    expect(find.text(zettel.stichpunkte.first), findsNothing);
    await t.tap(find.text(s.ui('ui.verdeckt.frage', {'name': name})));
    await t.pump();
    expect(s.verdeckt, k.rolle);
    expect(find.text(s.ui('ui.befragung.fragt', {'frage': k.fragen.last})), findsOneWidget);
    for (final z in zettel.stichpunkte) {
      expect(find.text(z), findsOneWidget, reason: z);
    }
    for (final z in zettel.behaupten) {
      expect(find.text(s.ui('ui.befragung.behaupte', {'text': z})), findsOneWidget, reason: z);
    }
    await t.ensureVisible(find.text(s.ui('ui.verdeckt.schliessen')));
    await t.tap(find.text(s.ui('ui.verdeckt.schliessen')));
    await t.pump();
    expect(s.verdeckt, isNull);
    expect(s.befragungVon(k.rolle)!.erledigt, isTrue, reason: 'Mit dem Zudecken ist die Frage beantwortet');
    expect(find.byWidgetPredicate((w) => w is MStempel && w.text == s.ui('ui.befragung.erledigt')), findsOneWidget);
    PartySkript.befragungenErledigen(s);
    await t.pump();
    expect(s.kannWeiter, isTrue);
    await t.ensureVisible(find.text(s.ui('ui.runde.weiter')));
    await t.tap(find.text(s.ui('ui.runde.weiter')));
    expect(s.phase, PartyPhase.entscheidungen);
  });

  // Prüfung M2z (R17, E-044): Hanas Befragung hat zwei Preisgaben und Würze, sieben Zeilen in einem Block. Der Zettel
  // zeigt jede Karte getrennt; keine Zeile hat mehr als acht Wörter, auch Behauptungen mit „Behaupte:“ davor.
  testWidgets('Spickzettel: je Preisgabe eine Karte, zuletzt die Würze, jede Zeile höchstens acht Wörter', (t) async {
    final s = neueSitzung(rollen: 20, pfad: 'fatma');
    spieleBis(s, PartyPhase.gespraeche);
    final mehrere = <String>[];
    for (final rolle in s.besetzt) {
      s.zeigeVerdeckt(rolle);
      await t.pumpWidget(rahmen(SingleChildScrollView(child: SpickzettelInhalt(sitzung: s, rolle: rolle, runde: 1))));
      final z = s.spickzettel(rolle, 1);
      final karten = find.byType(SpickKarte);
      expect(karten, findsNWidgets(z.karten.length), reason: rolle);
      for (final (i, k) in z.kartenZeilen((x) => s.ui('ui.befragung.behaupte', {'text': x})).indexed) {
        expect(k.length, inInclusiveRange(1, 3), reason: rolle);
        for (final zeile in k) {
          expect(find.descendant(of: karten.at(i), matching: find.text(zeile)), findsOneWidget, reason: '$rolle: $zeile');
          expect(stichpunktWoerter(zeile), lessThanOrEqualTo(8), reason: '$rolle: $zeile');
        }
      }
      if (z.karten.length > 1) mehrere.add(rolle);
      s.verdecken();
    }
    expect(mehrere, containsAll(['meryem', 'kaan', 'fatma']));
    expect(t.takeException(), isNull);
  });

  testWidgets('Mein Spickzettel: verdeckt je Person, nur die laufende Runde', (t) async {
    t.view.physicalSize = const Size(390, 844);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.view.resetDevicePixelRatio);
    final s = neueSitzung(rollen: 7, pfad: 'fatma');
    spieleBis(s, PartyPhase.gespraeche, runde: 2);
    await t.pumpWidget(rahmen(ListenableBuilder(listenable: s, builder: (_, _) => RundeBildschirm(sitzung: s))));
    const rolle = 'emine';
    final name = s.spielerName(rolle);
    final eigen = partyDaten.texte.sammlung.gespraeche.firstWhere((g) => g.rolle == rolle && g.runde == 2);
    final vorher = partyDaten.texte.sammlung.gespraeche.firstWhere((g) => g.rolle == rolle && g.runde == 1);
    expect(find.text(eigen.stichpunkte.first), findsNothing);
    final person = find.text(name).last;
    await t.ensureVisible(person);
    await t.tap(person);
    await t.pump();
    expect(find.text(s.ui('ui.verdeckt.weitergeben', {'name': name})), findsOneWidget);
    await t.tap(find.text(s.ui('ui.verdeckt.frage', {'name': name})));
    await t.pump();
    expect(s.verdeckt, rolle);
    expect(find.byWidgetPredicate((w) => w is PartyRahmen && w.marke == s.ui('ui.befragung.spickzettel')), findsOneWidget);
    for (final p in eigen.stichpunkte) {
      expect(find.text(p), findsOneWidget, reason: p);
    }
    for (final p in vorher.stichpunkte.where((p) => !eigen.stichpunkte.contains(p))) {
      expect(find.text(p), findsNothing, reason: 'Runde 1 bleibt weg: $p');
    }
    // Kein Dossier, kein Täterwissen auf dem Spickzettel.
    expect(find.text(s.ui('ui.rollen.verbirgt_titel')), findsNothing);
    await t.ensureVisible(find.text(s.ui('ui.verdeckt.schliessen')));
    await t.tap(find.text(s.ui('ui.verdeckt.schliessen')));
    await t.pump();
    expect(s.verdeckt, isNull);
    expect(find.text(eigen.stichpunkte.first), findsNothing);
  });

  testWidgets('Reihum: eine freie Befragung wird erst aufgeklappt; sind die Wahlen getroffen, entfallen die übrigen', (t) async {
    t.view.physicalSize = const Size(390, 844);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.view.resetDevicePixelRatio);
    final s = neueSitzung(rollen: 12);
    spieleBis(s, PartyPhase.gespraeche);
    await t.pumpWidget(rahmen(ListenableBuilder(listenable: s, builder: (_, _) => RundeBildschirm(sitzung: s))));
    final frei = [for (final k in s.befragungen) if (!k.pflicht) k];
    final wahlen = s.befragungenFrei;
    expect(wahlen, inInclusiveRange(1, 2));
    expect(frei.length, greaterThan(wahlen));
    for (final k in frei.take(wahlen)) {
      final zeile = find.byKey(ValueKey('wahl-${k.id}'));
      await t.ensureVisible(zeile);
      expect(find.descendant(of: zeile, matching: find.text(k.thema)), findsOneWidget);
      expect(find.descendant(of: zeile, matching: find.text(k.fragen.first)), findsNothing, reason: 'Fragen erst nach dem Aufklappen');
      await t.tap(zeile);
      await t.pump();
      final frage = find.descendant(of: find.byKey(ValueKey(k.id)), matching: find.text(k.fragen.first));
      await t.ensureVisible(frage);
      await t.tap(frage);
      await t.pump();
      // Die Frage geht verdeckt an die Person; zurück am Tisch steht die Karte als gewählt da.
      expect(find.text(s.ui('ui.befragung.geraet', {'name': s.spielerName(k.rolle)})), findsOneWidget);
      await t.tap(find.text(s.ui('ui.allgemein.zurueck')));
      await t.pump();
      expect(s.befragungVon(k.rolle)!.gefragt, isTrue);
      expect(s.befragungVon(k.rolle)!.erledigt, isFalse, reason: 'Ohne Antwort ist sie noch offen');
    }
    expect(s.befragungenFrei, 0);
    for (final k in frei.skip(wahlen)) {
      expect(find.byKey(ValueKey('wahl-${k.id}')), findsNothing, reason: k.id);
      expect(find.byKey(ValueKey(k.id)), findsNothing, reason: k.id);
    }
    expect(find.text(s.ui('ui.befragung.frei_fertig')), findsOneWidget);
    // Wer nicht gewählt ist, liest auf dem eigenen Zettel, dass die Befragung entfällt.
    final ohne = frei.skip(wahlen).first.rolle;
    s.zeigeVerdeckt(ohne);
    await t.pump();
    expect(find.text(s.ui('ui.befragung.entfaellt')), findsOneWidget);
    await t.ensureVisible(find.text(s.ui('ui.verdeckt.schliessen')));
    await t.tap(find.text(s.ui('ui.verdeckt.schliessen')));
    await t.pump();
    expect(s.kannWeiter, isFalse, reason: 'Die gewählten Befragungen sind noch nicht beantwortet');
  });

  testWidgets('Druckspiel: die Befragungen stehen nur zum Lesen da, Weiter wartet nicht', (t) async {
    final s = neueSitzung()..einrichten(rollen: 7, detektiv: 'w', druck: true);
    spieleBis(s, PartyPhase.gespraeche);
    await t.pumpWidget(rahmen(RundeBildschirm(sitzung: s)));
    expect(s.befragungAufPapier, isTrue);
    expect(s.kannWeiter, isTrue);
    expect(find.text(s.ui('ui.befragung.hinweis_druck')), findsOneWidget);
    final k = s.befragungen.firstWhere((k) => k.pflicht);
    expect(find.byKey(ValueKey(k.id)), findsOneWidget);
    expect(find.descendant(of: find.byKey(ValueKey(k.id)), matching: find.text(k.fragen.first)), findsOneWidget);
    expect(find.descendant(of: find.byKey(ValueKey(k.id)), matching: find.byType(MKnopf)), findsNothing, reason: 'Keine Frage zum Antippen');
    expect(() => s.befragen(k.id, 0), throwsStateError);
    await t.tap(find.text(s.ui('ui.runde.weiter')));
    expect(s.phase, PartyPhase.entscheidungen);
  });

  testWidgets('Altakte (Modell legacy): der Vernehmungsplan aller Pflichtgespräche ohne Eröffnungssatz', (t) async {
    final d = akteDaten('gewoelbe');
    final s = PartySitzung(d, wuerfel: const FesterWuerfel.neutral())
      ..einrichten(rollen: 7, detektiv: 'w', code: FallCode.fuerPfad(d.kanon.pfade.first, d.kanon.pfade).code);
    spieleBis(s, PartyPhase.gespraeche, runde: 2);
    await t.pumpWidget(rahmen(RundeBildschirm(sitzung: s)));
    expect(s.befragungsmodell, isFalse);
    final gespraeche = s.gespraeche(2);
    expect(gespraeche, hasLength(21));
    for (final z in gespraeche) {
      expect(z.gespraech.text, isNotEmpty);
      expect(find.textContaining(z.gespraech.text), findsNothing, reason: z.gespraech.id);
      final paarung = s.ui('ui.runde.paarung', {'sprecher': s.spielerName(z.gespraech.rolle), 'partner': s.personAmTisch(z.partner)});
      expect(find.descendant(of: find.byKey(ValueKey(z.gespraech.id)), matching: find.text(paarung)), findsOneWidget, reason: z.gespraech.id);
    }
    await t.tap(find.text(s.ui('ui.runde.weiter')));
    expect(s.phase, PartyPhase.entscheidungen);
  });

  testWidgets('kein Überlauf auf 1280 × 800 mit 20 Rollen', (t) async {
    t.view.physicalSize = const Size(1280, 800);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.view.resetDevicePixelRatio);
    final s = neueSitzung(rollen: 20);
    spieleBis(s, PartyPhase.gespraeche);
    expect(s.besetzt, hasLength(20));
    await t.pumpWidget(rahmen(RundeBildschirm(sitzung: s)));
    expect(t.takeException(), isNull);
  });

  testWidgets('kein Überlauf auf 390 × 844 mit 20 Rollen', (t) async {
    t.view.physicalSize = const Size(390, 844);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.view.resetDevicePixelRatio);
    final s = neueSitzung(rollen: 20);
    spieleBis(s, PartyPhase.gespraeche);
    expect(s.besetzt, hasLength(20));
    await t.pumpWidget(rahmen(RundeBildschirm(sitzung: s)));
    expect(t.takeException(), isNull);
  });
}
