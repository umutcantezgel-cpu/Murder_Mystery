// M2 Abend in Mappen: Rundenuhr als Taschenuhr, Vernehmungsprotokolle,
// Stimmzettel im Umschlag und das Resümee als gestempelter Bericht. Geprüft
// werden die Gestalt (gleich für alle Rollen, E-041), das Fehlen von
// Wertungsstempeln und schmale Bildschirme mit großer Schrift.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mordakte/party/bildschirme/gruppenwahl.dart';
import 'package:mordakte/party/bildschirme/intro.dart';
import 'package:mordakte/party/bildschirme/resuemee.dart';
import 'package:mordakte/party/bildschirme/runde.dart';
import 'package:mordakte/party/bildschirme/solo_gespraeche.dart';
import 'package:mordakte/party/bildschirme/titel.dart';
import 'package:mordakte/stil/mappe/abend1_bausteine.dart';
import 'package:mordakte/stil/stil.dart';
import 'package:mordakte_core/mordakte_core.dart';

import 'hilfe.dart';

/// Bildschirm in [breite] × 844 bei [schrift]-facher Schrift; [ruhig]: Bewegung reduzieren.
Future<void> _zeige(WidgetTester t, Widget kind, {double breite = 390, double schrift = 1, bool ruhig = false}) async {
  t.view.physicalSize = Size(breite, 844);
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.resetPhysicalSize);
  addTearDown(t.view.resetDevicePixelRatio);
  await t.pumpWidget(const SizedBox());
  await t.pumpWidget(MaterialApp(
    theme: ThemeData.dark(),
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(schrift), disableAnimations: ruhig),
      child: child!,
    ),
    home: Scaffold(body: kind),
  ));
  await t.pump(const Duration(milliseconds: 500));
}

/// Die Folge der Widget-Typen unter [wurzel]: die Gestalt ohne den Wortlaut.
List<Type> _gestalt(WidgetTester t, Finder wurzel) => [
      for (final e in find.descendant(of: wurzel, matching: find.byWidgetPredicate((_) => true)).evaluate()) e.widget.runtimeType,
    ];

void main() {
  testWidgets('Stimmzettel: Täterrolle und Unschuldige sehen dieselbe Gestalt', (t) async {
    final s = neueSitzung(rollen: 5, pfad: 'can');
    spieleBis(s, PartyPhase.gruppenwahl);
    await _zeige(t, GruppenwahlBildschirm(sitzung: s));
    s.zeigeVerdeckt('ahmet');
    await t.pump(const Duration(milliseconds: 500));
    final unschuldig = _gestalt(t, find.byType(MUmschlag));
    expect(unschuldig, contains(MBlatt));
    expect(find.text(s.ui('ui.rollen.wahl_a')), findsOneWidget);
    expect(find.text(s.ui('ui.rollen.wahl_b')), findsOneWidget);
    s.verdecken();
    await t.pump();
    s.zeigeVerdeckt('can');
    await t.pump(const Duration(milliseconds: 500));
    final taeter = _gestalt(t, find.byType(MUmschlag));
    expect(find.text(partyDaten.texte.sammlung.wahlen['gw_can_1']!.sabotage!), findsOneWidget);
    expect(find.text(s.ui('ui.rollen.wahl_b')), findsOneWidget);
    expect(find.text(s.ui('ui.rollen.wahl_sabotage')), findsNothing);
    expect(taeter, unschuldig);
  });

  testWidgets('Stimmzettel: der gewählte Wahlkreis ist für den Bildschirmleser angekreuzt', (t) async {
    final semantik = t.ensureSemantics();
    final s = neueSitzung(rollen: 5);
    spieleBis(s, PartyPhase.gruppenwahl);
    await _zeige(t, GruppenwahlBildschirm(sitzung: s));
    s.zeigeVerdeckt('ahmet');
    await t.pump();
    final w = s.wahl('ahmet');
    await t.tap(find.text(w.b));
    await t.pump();
    expect(t.getSemantics(find.text(w.b)), isSemantics(isChecked: true, isInMutuallyExclusiveGroup: true, isButton: true));
    expect(t.getSemantics(find.text(w.a)), isSemantics(isChecked: false, isInMutuallyExclusiveGroup: true, isButton: true));
    semantik.dispose();
  });

  testWidgets('Rundenuhr: die Restzeit steht im Fenster der Taschenuhr, Stempel erst bei null', (t) async {
    final s = neueSitzung(rollen: 7);
    spieleBis(s, PartyPhase.gespraeche);
    s.rundendauer = const Duration(seconds: 2);
    await _zeige(t, RundeBildschirm(sitzung: s));
    expect(find.descendant(of: find.byType(MTaschenuhr), matching: find.text('00:02')), findsOneWidget);
    expect(find.byType(MStempelZeile), findsNothing);
    await t.ensureVisible(find.byTooltip(s.ui('ui.runde.start')));
    await t.tap(find.byTooltip(s.ui('ui.runde.start')));
    await t.pump(const Duration(seconds: 3));
    expect(find.descendant(of: find.byType(MTaschenuhr), matching: find.text(s.ui('ui.runde.zeit_um'))), findsOneWidget);
    expect(t.takeException(), isNull);
  });

  testWidgets('Rundenuhr läuft auch bei „Bewegung reduzieren“ ohne Fehler', (t) async {
    final s = neueSitzung(rollen: 7);
    spieleBis(s, PartyPhase.gespraeche);
    s.rundendauer = const Duration(seconds: 2);
    await _zeige(t, RundeBildschirm(sitzung: s), ruhig: true);
    await t.ensureVisible(find.byTooltip(s.ui('ui.runde.start')));
    await t.tap(find.byTooltip(s.ui('ui.runde.start')));
    await t.pump(const Duration(seconds: 1));
    expect(find.text('00:01'), findsOneWidget);
    await t.pump(const Duration(seconds: 2));
    expect(find.text(s.ui('ui.runde.zeit_um')), findsOneWidget);
    expect(t.takeException(), isNull);
  });

  testWidgets('Vernehmungsplan: jede Rolle als Fotoabzug, Gespräche mit dem Abzug der Gesprächsperson', (t) async {
    final s = neueSitzung(rollen: 4);
    spieleBis(s, PartyPhase.gespraeche);
    await _zeige(t, RundeBildschirm(sitzung: s));
    for (final z in s.gespraeche(s.runde)) {
      expect(find.descendant(of: find.byKey(ValueKey(z.gespraech.id)), matching: find.byType(MFotoabzug)), findsOneWidget, reason: z.gespraech.id);
    }
  });

  testWidgets('Vernehmungsprotokoll: Fotoabzug, Thema als Formularfeld, Aussage in Kursive', (t) async {
    final s = neueSitzung(rollen: 4, solo: true);
    spieleBis(s, PartyPhase.gespraeche);
    final g = s.soloGespraeche.first;
    await _zeige(t, SingleChildScrollView(child: BotSprechblase(sitzung: s, gespraech: g)));
    final blase = find.byType(BotSprechblase);
    expect(find.descendant(of: blase, matching: find.byType(MFotoabzug)), findsOneWidget);
    expect(find.descendant(of: blase, matching: find.text(s.ui('ui.rollen.gespraech_thema'))), findsOneWidget);
    expect(find.descendant(of: blase, matching: find.text(g.thema)), findsOneWidget);
    expect(t.widget<Text>(find.text(g.text)).style, MPapierSchrift.kursiv);
  });

  testWidgets('Resümee: die Fachköpfe sind Stempelabdrücke, sonst gibt es keinen Stempel', (t) async {
    final s = neueSitzung();
    spieleBis(s, PartyPhase.resuemee, runde: 1);
    await _zeige(t, ResuemeeBildschirm(sitzung: s));
    final koepfe = t.widgetList<MStempelZeile>(find.byType(MStempelZeile)).map((k) => k.text).toList();
    expect(koepfe, [for (final k in ['ui.resuemee.fach_gruppe', 'ui.resuemee.fach_rest', 'ui.resuemee.fach_lage']) s.ui(k)]);
    expect(find.byType(MStempel), findsNothing);
    // Nur ein Erzählerschalter liest alle drei Fächer vor.
    expect(find.byType(MSchalter), findsOneWidget);
  });

  for (final breite in [320.0, 390.0]) {
    for (final schrift in [1.0, 2.0]) {
      testWidgets('Mappen des Abends ohne Überlauf bei $breite px und Schrift $schrift', (t) async {
        final s = neueSitzung();
        await _zeige(t, TitelBildschirm(sitzung: s), breite: breite, schrift: schrift);
        expect(t.takeException(), isNull, reason: 'Titel');
        spieleBis(s, PartyPhase.intro);
        await _zeige(t, IntroBildschirm(sitzung: s), breite: breite, schrift: schrift);
        expect(t.takeException(), isNull, reason: 'Intro');
        spieleBis(s, PartyPhase.gespraeche);
        await _zeige(t, RundeBildschirm(sitzung: s), breite: breite, schrift: schrift);
        expect(t.takeException(), isNull, reason: 'Runde');
        spieleBis(s, PartyPhase.gruppenwahl);
        await _zeige(t, GruppenwahlBildschirm(sitzung: s), breite: breite, schrift: schrift);
        expect(t.takeException(), isNull, reason: 'Gruppenwahl neutral');
        s.zeigeVerdeckt(s.offeneWaehler.first);
        await t.pump(const Duration(milliseconds: 500));
        expect(t.takeException(), isNull, reason: 'Stimmzettel');
        s.verdecken();
        spieleBis(s, PartyPhase.bonus, runde: 1);
        await _zeige(t, ResuemeeBildschirm(sitzung: s), breite: breite, schrift: schrift);
        expect(t.takeException(), isNull, reason: 'Bonus');
        spieleBis(s, PartyPhase.resuemee, runde: 1);
        await _zeige(t, ResuemeeBildschirm(sitzung: s), breite: breite, schrift: schrift);
        expect(t.takeException(), isNull, reason: 'Resümee');
        await t.pumpWidget(const SizedBox());
      });
    }
  }
}
