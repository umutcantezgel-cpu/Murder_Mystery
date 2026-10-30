// Finale Schlosskeller (A-063, SPEZIFIKATION §2): die Erzählerakte an einem
// Gerät. Sie gehört nur dem Erzähler-Platz: reihum über die Rollenphase („Gib
// das Gerät an …“) und das offene Pult; nie im Solo, nie ohne Erzähler, nie ab
// dem Finale. Reiter „Figuren“ (besetzte zuerst, dann ohne Spieler) und „Netz“
// (Ring mit Herrn Schneider in der Mitte, öffentlich durchgezogen, heimlich
// gestrichelt, antippbar). Die Ziele kommen mit der Schicht aus ihren Sternen;
// an einem Abend ohne „Dein Moment“ sind es die Ziele des Kanons. „Als PDF“ gibt
// es nur in der offenen Akte, in der Fassung, die sie zeigt, für die Personenzahl
// des Abends.
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mordakte/l10n/gen/app_localizations_de.dart';
import 'package:mordakte/party/bildschirme/intro.dart';
import 'package:mordakte/party/bildschirme/rollen.dart';
import 'package:mordakte/party/datei_teilen.dart';
import 'package:mordakte/party/druck_speichern.dart';
import 'package:mordakte/party/erzaehlerakte_ansicht.dart';
import 'package:mordakte/party/sitzung.dart';
import 'package:mordakte_core/mordakte_core.dart';
import 'package:share_plus/share_plus.dart';

import 'erzaehl_hilfe.dart';
import 'hilfe.dart';
import 'rundgang_hilfe.dart' show rundgangDaten;

final _de = LDe();

/// Die Liste des Reiters „Figuren“.
Finder get _figurenListe => find.descendant(of: find.byKey(const ValueKey('erzaehlerakte-figuren')), matching: find.byType(Scrollable)).first;

/// Handyformat mit reduzierter Bewegung.
Future<void> _zeige(WidgetTester t, Widget kind, {Size groesse = const Size(390, 844), double schrift = 1}) async {
  t.view.physicalSize = groesse;
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.resetPhysicalSize);
  addTearDown(t.view.resetDevicePixelRatio);
  await t.pumpWidget(rahmen(MediaQuery(data: MediaQueryData(disableAnimations: true, size: groesse, textScaler: TextScaler.linear(schrift)), child: kind)));
  await t.pump();
}

/// Der Knopf „Als PDF“ der Erzählerakte.
Finder get _pdf => find.text(_de.erzaehlerakte_pdf);

/// Tippt auf [knopf] und wartet in echter Zeit, bis [fertig] gilt (die PDF-Erzeugung läuft wirklich).
Future<void> _tippeUndWarte(WidgetTester t, Finder knopf, bool Function() fertig) async {
  await t.ensureVisible(knopf);
  await t.tap(knopf);
  await t.pump();
  for (var i = 0; i < 600 && !fertig(); i++) {
    await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
    await t.pump(const Duration(milliseconds: 20));
  }
  await t.pump();
}

/// Fängt das Teilen des Systems ab.
List<ShareParams> _zeuge() {
  final geteilt = <ShareParams>[];
  final vorher = dateiTeilenUeber;
  dateiTeilenUeber = (p) async {
    geteilt.add(p);
    return const ShareResult('ok', ShareResultStatus.success);
  };
  addTearDown(() => dateiTeilenUeber = vorher);
  return geteilt;
}

/// Der Browser ohne Teilen: nur Herunterladen.
class _Browser extends DateiGeraet {
  final angeboten = <(String, Uint8List)>[];

  @override
  bool get zweiterTipp => true;

  @override
  bool get kannHerunterladen => true;

  @override
  bool kannTeilen(String name, String typ) => false;

  @override
  Future<bool> anbieten(String name, Uint8List bytes, {required String typ, Rect? ursprung, required DateiWeg weg}) async {
    angeboten.add((name, bytes));
    return true;
  }
}

void main() {
  test('Daten: die Akte des Schlosskellers mit den Sternen der Schicht als Ziele; ohne Zusatz und Datei keine', () {
    final a = erzaehlDaten.erzaehlerakte!;
    expect(a.figuren.length, erzaehlDaten.kanon.figuren.length);
    for (final f in a.figuren) {
      expect(f.ziele.length, 2, reason: '${f.figur}: zwei Sterne');
    }
    expect(a.netz, isNotEmpty);
    expect(erzaehlDaten.erzaehlerakteFuer(einfluss: true), same(a));
    // Ein Abend ohne „Dein Moment“: das persönliche Ziel des Kanons, kein Stern (Finale §2, §3.1).
    final kanon = erzaehlDaten.erzaehlerakteFuer(einfluss: false)!;
    for (final f in kanon.figuren) {
      final ziel = erzaehlDaten.kanon.figur(f.figur)!['persoenlichesZiel'] as String;
      expect([for (final z in f.ziele) (z.id, z.text)], [('persoenlichesZiel', ziel)], reason: f.figur);
    }
    expect(partyDaten.erzaehlerakte, isNull, reason: 'Ohne Eintrag in akten.json');
    expect(rundgangDaten.erzaehlerakte, isNull, reason: 'Ohne Datei');
    for (final fall in ['gewoelbe', 'ravensmoor', 'nachtexpress', 'blue_palm']) {
      expect(akteDaten(fall).erzaehlerakte, isNull, reason: fall);
    }
  });

  test('Sichtbar nur dem Erzähler am Tisch, bis zum Finale; nie im Solo, nie ohne Erzähler, nie ohne Akte', () {
    expect(erzaehlSitzung(solo: true).erzaehlerakteSichtbar, isFalse);
    expect(erzaehlSitzung().erzaehlerakteSichtbar, isFalse, reason: 'Ohne Erzähler');
    final ohneAkte = PartySitzung(rundgangDaten)..einrichten(rollen: 4, detektiv: 'w', erzaehlerName: 'Mia');
    expect(ohneAkte.erzaehlerakteSichtbar, isFalse);
    final s = erzaehlSitzung(erzaehler: 'Mia', einstimmung: false);
    expect(s.erzaehlerakteSichtbar, isTrue);
    spieleBis(s, PartyPhase.anklage);
    expect(s.erzaehlerakteSichtbar, isTrue);
    spieleBis(s, PartyPhase.finale);
    expect(s.erzaehlerakteSichtbar, isFalse, reason: 'Nie ab dem Finale');
  });

  testWidgets('Rollenphase: Eintrag, „Gib das Gerät an Mia“, dann die Akte; besetzte Figuren zuerst; Netz antippbar', (t) async {
    final s = erzaehlSitzung(rollen: 5, erzaehler: 'Mia', namen: const {'ahmet': 'Ben'}, einstimmung: false);
    await _zeige(t, RollenBildschirm(sitzung: s));
    expect(find.byKey(const ValueKey('erzaehlerakte-eintrag')), findsOneWidget);
    expect(find.text(_de.erzaehlerakte_fuer('Mia')), findsOneWidget);
    await t.ensureVisible(find.byKey(const ValueKey('erzaehlerakte-eintrag')));
    await t.tap(find.byKey(const ValueKey('erzaehlerakte-eintrag')));
    await t.pump();
    expect(find.byKey(const ValueKey('erzaehlerakte-zwischenstufe')), findsOneWidget);
    expect(find.text(s.ui('ui.verdeckt.weitergeben', {'name': 'Mia'})), findsOneWidget);
    expect(find.byType(ErzaehlerakteSeite), findsNothing, reason: 'Erst wenn Mia das Gerät hat');
    await t.ensureVisible(find.byKey(const ValueKey('erzaehlerakte-zeigen')));
    await t.tap(find.byKey(const ValueKey('erzaehlerakte-zeigen')));
    await t.pumpAndSettle();
    expect(find.byType(ErzaehlerakteSeite), findsOneWidget);
    expect(find.text(_de.erzaehlerakte_titel), findsWidgets);
    // Figuren: „Heute gespielt“ vor „Ohne Spieler“; Emine (Platz sechs) steht unter den Gästen ohne Spieler.
    // Kleine Schritte: Jeder Zug schwingt nach, und unter der Akte liegt im Fuß auch „Als PDF“.
    final besetzt = find.byKey(const ValueKey('akte-besetzt')), ohne = find.byKey(const ValueKey('akte-ohne'));
    await t.scrollUntilVisible(besetzt, 120, scrollable: _figurenListe);
    await t.scrollUntilVisible(find.byKey(const ValueKey('akte-figur-ahmet')), 120, scrollable: _figurenListe);
    expect(find.text(_de.einstimmung_gespielt_von('Ben')), findsOneWidget);
    await t.scrollUntilVisible(ohne, 120, scrollable: _figurenListe);
    await t.scrollUntilVisible(find.byKey(const ValueKey('akte-figur-emine')), 120, scrollable: _figurenListe);
    expect(t.getTopLeft(find.byKey(const ValueKey('akte-figur-emine'))).dy, greaterThan(t.getTopLeft(ohne).dy));
    expect(find.byKey(const ValueKey('akte-besetzt')).evaluate().isEmpty || t.getTopLeft(besetzt).dy < t.getTopLeft(ohne).dy, isTrue);
    await t.scrollUntilVisible(find.byKey(const ValueKey('akte-figur-ahmet')), -120, scrollable: _figurenListe);
    await t.ensureVisible(find.byKey(const ValueKey('akte-figur-ahmet')));
    await t.pump();
    // Aufklappen: alle Abschnitte, Bindungen als Chips.
    await t.tap(find.byKey(const ValueKey('akte-figur-ahmet')));
    await t.pump();
    // Der Abend spielt „Dein Moment“ nicht: Die Akte nennt das Ziel des Kanons.
    expect(s.einfluss, isFalse);
    final ahmet = erzaehlDaten.erzaehlerakteFuer(einfluss: false)!.figur('ahmet')!;
    for (final k in ['hintergrund', 'bindungen', 'zu_schneider', 'motiv', 'geheimnis', 'nebendelikt', 'ziele', 'stimme']) {
      expect(find.text(s.ui('ui.druck.akte.$k')), findsWidgets, reason: k);
    }
    expect(find.text(ahmet.motiv!), findsOneWidget);
    expect(find.text(erzaehlDaten.kanon.figur('ahmet')!['persoenlichesZiel'] as String), findsOneWidget);
    for (final stern in erzaehlDaten.erzaehlerakte!.figur('ahmet')!.ziele) {
      expect(find.text(stern.text), findsNothing, reason: 'Kein Stern ohne die Schicht');
    }
    final kante = erzaehlDaten.erzaehlerakte!.kantenVon('ahmet').first;
    expect(find.byKey(ValueKey('bindung-ahmet-${kante.anderer('ahmet')}-${kante.sichtbar}')), findsOneWidget);
    // Netz: Ring mit Herrn Schneider in der Mitte, Knoten antippbar.
    await t.tap(find.text(_de.erzaehlerakte_reiter_netz));
    await t.pump();
    expect(find.byKey(const ValueKey('netz-ring')), findsOneWidget);
    expect(find.byWidgetPredicate((w) => w is CustomPaint && w.painter is NetzMaler), findsOneWidget);
    expect(find.byKey(ValueKey('netz-knoten-${erzaehlDaten.erzaehlerakte!.schneider.person}')), findsOneWidget);
    for (final f in erzaehlDaten.erzaehlerakte!.figuren) {
      expect(find.byKey(ValueKey('netz-knoten-${f.figur}')), findsOneWidget, reason: f.figur);
    }
    NetzMaler maler() => t.widget<CustomPaint>(find.byWidgetPredicate((w) => w is CustomPaint && w.painter is NetzMaler)).painter! as NetzMaler;
    expect(maler().wahl, isNull);
    expect(maler().kanten.any((k) => k.oeffentlich) && maler().kanten.any((k) => !k.oeffentlich), isTrue, reason: 'Öffentliche und heimliche Kanten');
    await t.tap(find.byKey(const ValueKey('netz-knoten-ahmet')));
    await t.pump();
    expect(maler().wahl, 'ahmet');
    // „Alle Bindungen“ liegt unter dem Ring; bei kleinem Bildschirm erst nach dem Rollen im Bild.
    expect(find.byKey(const ValueKey('netz-alle'), skipOffstage: false), findsOneWidget);
    await t.ensureVisible(find.byKey(const ValueKey('netz-alle'), skipOffstage: false));
    await t.pump();
    await t.tap(find.byKey(const ValueKey('netz-alle')));
    await t.pump();
    expect(find.byKey(const ValueKey('netz-alle')), findsNothing, reason: 'Auswahl aufgehoben');
    expect(t.takeException(), isNull);
    // Schließen: zurück zur neutralen Rollenliste.
    await t.tap(find.byKey(const ValueKey('erzaehlerakte-schliessen')));
    await t.pumpAndSettle();
    expect(find.byType(ErzaehlerakteSeite), findsNothing);
    expect(find.byKey(const ValueKey('erzaehlerakte-eintrag')), findsOneWidget);
  });

  testWidgets('Ohne Erzähler und im Solo gibt es keinen Eintrag; am offenen Pult liegt die Akte bereit, zugedeckt nicht', (t) async {
    await _zeige(t, RollenBildschirm(sitzung: erzaehlSitzung(einstimmung: false)));
    expect(find.byKey(const ValueKey('erzaehlerakte-eintrag')), findsNothing);
    await _zeige(t, RollenBildschirm(sitzung: erzaehlSitzung(solo: true, einstimmung: false)));
    expect(find.byKey(const ValueKey('erzaehlerakte-eintrag')), findsNothing);
    final s = erzaehlSitzung(rollen: 4, erzaehler: 'Mia', einstimmung: false);
    spieleBis(s, PartyPhase.intro);
    await _zeige(t, ListenableBuilder(listenable: s, builder: (_, _) => IntroBildschirm(sitzung: s)));
    expect(find.byKey(const ValueKey('erzaehlerakte-knopf')), findsNothing, reason: 'Zugedeckt sieht der Tisch nichts');
    s.pultZeigen();
    await t.pump();
    await t.ensureVisible(find.byKey(const ValueKey('erzaehlerakte-knopf')));
    expect(find.byKey(const ValueKey('erzaehlerakte-knopf')), findsOneWidget);
    expect(find.byKey(const ValueKey('erzaehlerpult-zudecken')), findsOneWidget);
    final solo = erzaehlSitzung(rollen: 4, solo: true, einstimmung: false);
    spieleBis(solo, PartyPhase.intro);
    await _zeige(t, IntroBildschirm(sitzung: solo));
    expect(find.byKey(const ValueKey('erzaehlerakte-knopf')), findsNothing);
  });

  testWidgets('Die Akte schließt sich selbst, sobald das Finale beginnt', (t) async {
    final s = erzaehlSitzung(rollen: 4, erzaehler: 'Mia', einstimmung: false);
    spieleBis(s, PartyPhase.anklage);
    await _zeige(t, Builder(builder: (c) => TextButton(onPressed: () => erzaehlerakteZeigen(c, s), child: const Text('x'))));
    await t.tap(find.byType(TextButton));
    await t.pumpAndSettle();
    expect(find.byType(ErzaehlerakteSeite), findsOneWidget);
    if (s.angeklagt == null) s.anklagen(s.spiel.pfad);
    s.weiter();
    expect(s.phase, PartyPhase.finale);
    await t.pumpAndSettle();
    expect(find.byType(ErzaehlerakteSeite), findsNothing);
  });

  testWidgets('Schmal und mit doppelter Schrift ohne Überlauf, beide Reiter', (t) async {
    final s = erzaehlSitzung(rollen: 20, erzaehler: 'Mia', einstimmung: false);
    await _zeige(
      t,
      ErzaehlerakteSeite(daten: s.daten, besetzt: s.besetzt, einfluss: s.einfluss, spieler: (f) => s.namen[f]),
      groesse: const Size(320, 640),
      schrift: 2,
    );
    await t.scrollUntilVisible(find.byKey(const ValueKey('akte-figur-ahmet')), 300, scrollable: _figurenListe);
    await t.tap(find.byKey(const ValueKey('akte-figur-ahmet')));
    await t.pump();
    expect(t.takeException(), isNull);
    await t.ensureVisible(find.text(_de.erzaehlerakte_reiter_netz));
    await t.pump();
    await t.tap(find.text(_de.erzaehlerakte_reiter_netz));
    await t.pump();
    expect(find.byKey(const ValueKey('erzaehlerakte-netz')), findsOneWidget);
    final netz = find.descendant(of: find.byKey(const ValueKey('erzaehlerakte-netz')), matching: find.byType(Scrollable)).first;
    await t.scrollUntilVisible(find.byKey(const ValueKey('netz-knoten-leyla')), 200, scrollable: netz);
    await t.tap(find.byKey(const ValueKey('netz-knoten-leyla')));
    await t.pump();
    expect(t.takeException(), isNull);
  });

  testWidgets('„Als PDF“ nur in der offenen Akte: nicht im Eintrag, nicht am Pult, nie im Solo; mit der Personenzahl des Abends', (t) async {
    final s = erzaehlSitzung(rollen: 5, erzaehler: 'Mia', einstimmung: false);
    await _zeige(t, RollenBildschirm(sitzung: s));
    expect(_pdf, findsNothing, reason: 'Die Rollenvergabe sieht der ganze Tisch');
    await t.ensureVisible(find.byKey(const ValueKey('erzaehlerakte-eintrag')));
    await t.tap(find.byKey(const ValueKey('erzaehlerakte-eintrag')));
    await t.pump();
    expect(_pdf, findsNothing, reason: '„Gib das Gerät an Mia“');
    await t.ensureVisible(find.byKey(const ValueKey('erzaehlerakte-zeigen')));
    await t.tap(find.byKey(const ValueKey('erzaehlerakte-zeigen')));
    await t.pumpAndSettle();
    expect(_pdf, findsOneWidget);
    expect(t.widget<ErzaehlerakteSeite>(find.byType(ErzaehlerakteSeite)).rollen, 5);
    await t.tap(find.byKey(const ValueKey('erzaehlerakte-schliessen')));
    await t.pumpAndSettle();
    expect(_pdf, findsNothing);

    // Am Pult: zugedeckt nichts, offen nur der Knopf zur Akte; das PDF erst in ihr.
    final pult = erzaehlSitzung(rollen: 4, erzaehler: 'Mia', einstimmung: false);
    spieleBis(pult, PartyPhase.intro);
    await _zeige(t, ListenableBuilder(listenable: pult, builder: (_, _) => IntroBildschirm(sitzung: pult)));
    expect(_pdf, findsNothing);
    pult.pultZeigen();
    await t.pump();
    expect(_pdf, findsNothing);
    await t.ensureVisible(find.byKey(const ValueKey('erzaehlerakte-knopf')));
    await t.tap(find.byKey(const ValueKey('erzaehlerakte-knopf')));
    await t.pump();
    await t.pump(const Duration(milliseconds: 600));
    expect(_pdf, findsOneWidget);
    expect(t.widget<ErzaehlerakteSeite>(find.byType(ErzaehlerakteSeite)).rollen, 4);
    await t.tap(find.byKey(const ValueKey('erzaehlerakte-schliessen')));
    await t.pump();
    await t.pump(const Duration(milliseconds: 600));
    expect(find.byType(ErzaehlerakteSeite), findsNothing);
    expect(_pdf, findsNothing);

    // Im Solo gibt es weder Akte noch PDF.
    final solo = erzaehlSitzung(rollen: 4, solo: true, einstimmung: false);
    spieleBis(solo, PartyPhase.intro);
    await _zeige(t, IntroBildschirm(sitzung: solo));
    expect(find.byKey(const ValueKey('erzaehlerakte-knopf')), findsNothing);
    expect(_pdf, findsNothing);

    // Ohne passende Personenzahl oder ohne Akte keinen Knopf.
    for (final n in [null, 3, 21]) {
      await _zeige(t, ErzaehlerakteSeite(daten: erzaehlDaten, besetzt: s.besetzt, einfluss: false, rollen: n));
      expect(_pdf, findsNothing, reason: '$n Personen');
    }
    await _zeige(t, ErzaehlerakteSeite(daten: partyDaten, besetzt: s.besetzt, einfluss: false, rollen: 5));
    expect(_pdf, findsNothing, reason: 'Ohne Erzählerakte');
  });

  testWidgets('„Als PDF“ setzt die Fassung, die die Akte zeigt: ohne „Dein Moment“ die Ziele des Kanons, mit ihm die Sterne', (t) async {
    final angefragt = mitErsatzPortraets();
    final geteilt = _zeuge();
    final s = erzaehlSitzung(rollen: 7, erzaehler: 'Mia', einstimmung: false);
    await _zeige(t, ErzaehlerakteSeite(daten: s.daten, besetzt: s.besetzt, einfluss: false, rollen: 7));
    expect(angefragt, isEmpty, reason: 'Erst beim Tipp');
    await _tippeUndWarte(t, _pdf, () => geteilt.isNotEmpty);
    expect(geteilt.single.fileNameOverrides, ['erzaehlerakte.pdf']);
    expect(geteilt.single.files!.single.mimeType, 'application/pdf');
    final ohne = (await t.runAsync(() => geteilt.single.files!.single.readAsBytes()))!;
    expect(String.fromCharCodes(ohne.take(5)), '%PDF-');
    expect(ohne, await t.runAsync(() => erzaehlerakteSoll(erzaehlDaten, einfluss: false, rollen: 7)));

    // Mit „Dein Moment“ im Browser: erst bauen, dann „Herunterladen: Erzählerakte“.
    final browser = _Browser();
    final vorher = dateiGeraet;
    dateiGeraet = browser;
    addTearDown(() => dateiGeraet = vorher);
    await _zeige(t, ErzaehlerakteSeite(key: const ValueKey('mit'), daten: s.daten, besetzt: s.besetzt, einfluss: true, rollen: 7));
    final laden = find.text(_de.druck_datei_laden(s.ui('ui.druck.akte.titel')));
    await _tippeUndWarte(t, _pdf, () => laden.evaluate().isNotEmpty);
    expect(laden, findsOneWidget);
    await t.tap(laden);
    await t.pump();
    final (name, mit) = browser.angeboten.single;
    expect(name, 'erzaehlerakte.pdf');
    expect(mit, await t.runAsync(() => erzaehlerakteSoll(erzaehlDaten, einfluss: true, rollen: 7)));
    expect(mit, isNot(ohne), reason: 'Die Sterne sind eine andere Fassung');
    expect(angefragt, hasLength(2));
  });

  testWidgets('Gilt die Akte nicht mehr, entsteht keine Datei', (t) async {
    mitErsatzPortraets();
    final geteilt = _zeuge();
    var erlaubt = true;
    final s = erzaehlSitzung(rollen: 5, erzaehler: 'Mia', einstimmung: false);
    await _zeige(t, ErzaehlerakteSeite(daten: s.daten, besetzt: s.besetzt, einfluss: false, rollen: 5, erlaubt: () => erlaubt));
    erlaubt = false;
    await _tippeUndWarte(t, _pdf, () => find.text(_de.druck_datei_fehler).evaluate().isNotEmpty);
    expect(find.text(_de.druck_datei_fehler), findsOneWidget);
    expect(geteilt, isEmpty);
  });
}
