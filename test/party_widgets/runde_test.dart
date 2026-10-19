// F4-BAUMEISTER-03: Rundenzentrale mit Uhr und Pflichtgesprächen (Master 7.6 Schritt 5).
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mordakte_core/mordakte_core.dart';
import 'package:mordakte/party/bildschirme/runde.dart';
import 'package:mordakte/party/party_stil.dart';
import 'package:mordakte/party/sitzung.dart';
import 'package:mordakte/party/skript.dart';
import 'package:mordakte/stil/mappe/zeichen.dart' show MStempel;
import 'package:mordakte_core/runden.dart' show FesterWuerfel, botAntwort;

import 'hilfe.dart';

/// Runde 1 mit einer Uhr von fünf Sekunden auf dem Bildschirm.
Future<PartySitzung> _uhrBild(WidgetTester t) async {
  final s = neueSitzung(rollen: 7);
  spieleBis(s, PartyPhase.gespraeche);
  s.rundendauer = const Duration(seconds: 5);
  await t.pumpWidget(rahmen(RundeBildschirm(sitzung: s)));
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
  });

  testWidgets('Zurücksetzen stellt die Rundendauer wieder her', (t) async {
    final s = await _uhrBild(t);
    await _tippe(t, s.ui('ui.runde.start'));
    await t.pump(const Duration(seconds: 2));
    await _tippe(t, s.ui('ui.runde.zuruecksetzen'));
    await t.pump();
    expect(find.text('00:05'), findsOneWidget);
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
      expect(find.byKey(ValueKey(k.id)), findsOneWidget, reason: k.id);
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
