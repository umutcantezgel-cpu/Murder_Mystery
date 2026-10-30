// Kein Wort bricht mitten im Wort um: Detektei, Fallakte, Druckmappe, Profil und die
// Aktenmappen im Assistenten am kleinsten Handy (320 px) mit doppelter Schrift, gemessen
// mit den echten Schriften. Dazu GanzeWorte selbst (misst mit dem wirksamen Stil) und der
// unveränderte Name der Akte-Knöpfe für den Bildschirmleser.
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mordakte/app/app.dart';
import 'package:mordakte/app/app_state.dart';
import 'package:mordakte/abend/online/lobby_besetzung.dart' show LobbyStand, zeigeLobbyWahl;
import 'package:mordakte/abend/rollen_uebersicht.dart';
import 'package:mordakte/app/router.dart';
import 'package:mordakte/detektei/akten.dart';
import 'package:mordakte/detektei/schreibtisch.dart';
import 'package:mordakte/l10n/gen/app_localizations_de.dart';
import 'package:mordakte/meta/meta_store.dart';
import 'package:mordakte/party/daten.dart';
import 'package:mordakte/party/datei_teilen.dart';
import 'package:mordakte/party/druck_speichern_stub.dart' as app;
import 'package:mordakte/party/druck_tafel.dart';
import 'package:mordakte/stil/stil.dart';
import 'package:mordakte_core/runden.dart' show Sitz;
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../abend/online_hilfe.dart';
import '../party_widgets/hilfe.dart' show partyDaten;

/// Prüft jeden Absatz unter [bereich]: Jedes Wort steht in einer einzigen Zeile.
void keinWortGeteilt(WidgetTester tester, Finder bereich) {
  final absaetze = tester.renderObjectList<RenderParagraph>(find.descendant(of: bereich, matching: find.byType(RichText), skipOffstage: false));
  expect(absaetze, isNotEmpty);
  for (final p in absaetze) {
    if (p.didExceedMaxLines) continue;
    final text = p.text.toPlainText();
    for (final m in RegExp(r'[^\s-]+-?').allMatches(text)) {
      final zeilen = p.getBoxesForSelection(TextSelection(baseOffset: m.start, extentOffset: m.end)).map((b) => b.top.round()).toSet();
      expect(zeilen.length, lessThanOrEqualTo(1), reason: '„${m.group(0)}“ in „$text“ bricht mitten im Wort um');
    }
  }
}

final _de = LDe();

/// Spielt die Android-App nach (zwei Wege nach dem Bauen); Kanal und Teilen sind abgefangen.
void androidNachspielen() {
  final vorher = app.aufAndroid;
  app.aufAndroid = true;
  addTearDown(() => app.aufAndroid = vorher);
  const kanal = MethodChannel('mordakte/datei');
  final bote = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  bote.setMockMethodCallHandler(kanal, (_) async => true);
  addTearDown(() => bote.setMockMethodCallHandler(kanal, null));
  final teilen = dateiTeilenUeber;
  dateiTeilenUeber = (_) async => const ShareResult('ok', ShareResultStatus.success);
  addTearDown(() => dateiTeilenUeber = teilen);
}

/// Wartet in echter Zeit (Bündel, PDF-Satz), bis [finder] etwas findet.
Future<void> warteBis(WidgetTester tester, Finder finder, {bool lang = false}) async {
  for (var i = 0; i < (lang ? 600 : 100) && finder.evaluate().isEmpty; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 25)));
    await tester.pump(const Duration(milliseconds: 30));
  }
  expect(finder, findsWidgets);
  await tester.pump(const Duration(milliseconds: 400));
}

void main() {
  setUpAll(() async {
    // Die echten Schriften der App, damit Textbreiten wie auf dem Gerät gemessen werden.
    final elite = FontLoader('SpecialElite')..addFont(rootBundle.load('assets/fonts/SpecialElite-Regular.ttf'));
    final inter = FontLoader('Inter')
      ..addFont(rootBundle.load('assets/fonts/Inter-Regular.ttf'))
      ..addFont(rootBundle.load('assets/fonts/Inter-SemiBold.ttf'))
      ..addFont(rootBundle.load('assets/fonts/Inter-Bold.ttf'));
    final playfair = FontLoader('Playfair')..addFont(rootBundle.load('assets/fonts/PlayfairDisplay-Variabel.ttf'));
    final lora = FontLoader('Lora')
      ..addFont(rootBundle.load('assets/fonts/Lora-Variabel.ttf'))
      ..addFont(rootBundle.load('assets/fonts/Lora-Kursiv-Variabel.ttf'));
    final courier = FontLoader('CourierPrime')..addFont(rootBundle.load('assets/fonts/CourierPrime-Regular.ttf'));
    final caveat = FontLoader('Caveat')..addFont(rootBundle.load('assets/fonts/Caveat-Variabel.ttf'));
    for (final l in [elite, inter, playfair, lora, courier, caveat]) {
      await l.load();
    }
  });
  setUp(() => SharedPreferences.setMockInitialValues({}));

  /// Öffnet [ort] auf einem Handy (320 px, doppelte Schrift) und wartet, bis [bereit] da ist.
  Future<AppState> oeffnen(WidgetTester tester, String ort, {Finder? bereit, double breite = 320, double schrift = 2, int xp = 0}) async {
    tester.view.physicalSize = Size(breite, 844);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = schrift;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final meta = MetaStore.memory()
      ..name = 'Test'
      ..debugSetXp(xp);
    final state = AppState(meta: meta, scenarios: const {});
    await tester.runAsync(() async {
      await AktenKatalog.laden();
      for (final id in ['schlosskeller', 'blue_palm']) {
        await AkteAuszug.laden(id);
      }
      await tester.pumpWidget(MordakteApp(app: state, initialLocation: ort));
    });
    for (var i = 0; i < 100; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
      await tester.pump(const Duration(milliseconds: 50));
      if (bereit == null || bereit.evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 600));
    return state;
  }

  Future<void> schliessen(WidgetTester tester, AppState state) async {
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    state.dispose();
  }

  testWidgets('GanzeWorte misst mit dem wirksamen Stil (Laufweite des DefaultTextStyle)', (tester) async {
    // Breite knapp über dem Wort ohne Laufweite: Mit der geerbten Laufweite passt es nicht mehr.
    const stil = TextStyle(fontFamily: 'Caveat', fontSize: 34);
    final ohne = TextPainter(text: const TextSpan(text: 'Melone', style: stil), textDirection: TextDirection.ltr)..layout();
    final breite = ohne.width + 1;
    ohne.dispose();
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: DefaultTextStyle(
          style: const TextStyle(letterSpacing: 1.5),
          child: Center(child: SizedBox(width: breite, child: const GanzeWorte('Melone', style: stil))),
        ),
      ),
    );
    final absatz = tester.renderObject<RenderParagraph>(find.text('Melone'));
    expect(absatz.getBoxesForSelection(const TextSelection(baseOffset: 0, extentOffset: 6)).map((b) => b.top.round()).toSet(), hasLength(1));
  });

  testWidgets('Detektei: 320 px, doppelte Schrift, kein Wort geteilt (auch „Sammlung“ auf der Karteikarte)', (tester) async {
    final state = await oeffnen(tester, Routes.start, bereit: find.text('Blue Palm Motel'));
    expect(find.text('Sammlung'), findsOneWidget);
    keinWortGeteilt(tester, find.byType(RollFlaeche));
    await schliessen(tester, state);
  });

  for (final id in ['schlosskeller', 'blue_palm']) {
    testWidgets('Fallakte $id: 320 px, doppelte Schrift, kein Wort geteilt', (tester) async {
      final state = await oeffnen(tester, Routes.akteVon(id), bereit: find.text('Personen'));
      expect(find.text('Die Lage'), findsOneWidget);
      keinWortGeteilt(tester, find.byType(RollFlaeche));
      await schliessen(tester, state);
    });
  }

  testWidgets('Druckmappe: 320 px, doppelte Schrift, der Deckel teilt kein Wort', (tester) async {
    final state = await oeffnen(tester, Routes.druckmappeVon('schlosskeller'), bereit: find.text('Spuk im Schlosskeller'));
    expect(find.text('Druckmappe'), findsWidgets);
    keinWortGeteilt(tester, find.byType(MAktenmappe));
    // Die Anleitung in Schritten: Jeder Schritt beginnt eine eigene Zeile.
    final hinweis = tester.renderObject<RenderParagraph>(find.textContaining('So geht'));
    final text = hinweis.text.toPlainText();
    var oben = -1.0;
    for (final anfang in ['So geht', '1. ', '2. ', '3. ']) {
      final i = text.indexOf(anfang);
      expect(i, greaterThanOrEqualTo(0), reason: anfang);
      final box = hinweis.getBoxesForSelection(TextSelection(baseOffset: i, extentOffset: i + 1)).first;
      expect(box.left, lessThan(1), reason: '„$anfang“ steht am Zeilenanfang');
      expect(box.top, greaterThan(oben), reason: '„$anfang“ steht unter dem Schritt davor');
      oben = box.top;
    }
    // Wem die Erzählerakte gehört, steht bei ihrem Knopf („Nur Erzähler“), nicht noch einmal hier.
    expect(text, isNot(contains('Erzählerakte')));
    // Schritt 2 nennt den Knopf in der Fußleiste: auch er bleibt ganz.
    keinWortGeteilt(tester, find.ancestor(of: find.text('Druckmappe vorbereiten'), matching: find.byType(MKnopf)));
    await schliessen(tester, state);
  });

  // In der Android-App (und im Browser) stehen nach dem Bauen „Herunterladen: …“ und „Teilen: …“.
  // Bräche ein Wort selbst in der kleinsten Schrift, steht der Dateiname als Zeile darüber und auf
  // den Knöpfen nur der Weg; ein Symbol, neben dem ein Wort bräche, entfällt.
  testWidgets('Druckmappe in der Android-App: 320 px, doppelte Schrift, die Dateien und ihre Wege teilen kein Wort', (tester) async {
    androidNachspielen();
    await tester.runAsync(() => PartyDaten.laden(rootBundle, fall: 'schlosskeller'));
    final state = await oeffnen(tester, Routes.druckmappeVon('schlosskeller'), bereit: find.text('Druckmappe vorbereiten'));
    await tester.tap(find.text('Druckmappe vorbereiten'));
    await warteBis(tester, find.text('Alles in einer Datei'));
    keinWortGeteilt(tester, find.byType(DruckTafel));
    for (final datei in ['Alles in einer Datei', 'Erzählerakte', 'Detektivbogen']) {
      await tester.ensureVisible(find.text(datei));
      await tester.tap(find.text(datei));
      await warteBis(tester, find.bySemanticsLabel(_de.druck_datei_laden(datei)), lang: true);
    }
    // „Senden an …“ nennt die Datei nicht: Die Wege nennen das Rollenheft.
    final senden = find.textContaining(_de.druck_senden_an('')).first;
    final person = tester.widget<Text>(senden).data!.substring(_de.druck_senden_an('').length);
    await tester.ensureVisible(senden);
    await tester.tap(senden);
    await warteBis(tester, find.text(_de.druck_datei_laden(_de.druck_rollenheft_von(person))), lang: true);
    keinWortGeteilt(tester, find.byType(DruckTafel));
    await schliessen(tester, state);
  });

  testWidgets('Steckbriefe in der Android-App: 320 px, doppelte Schrift, „Charakterübersicht“ steht als Zeile über „Herunterladen“ und „Teilen“', (tester) async {
    androidNachspielen();
    await tester.runAsync(() async {
      await PartyDaten.laden(rootBundle, fall: 'schlosskeller');
      await rootBundle.loadString('content/party/schlosskeller/steckbriefe.json');
    });
    final state = await oeffnen(tester, Routes.steckbriefeVon('schlosskeller'), bereit: find.text('Charakterübersicht'));
    await tester.ensureVisible(find.text('Charakterübersicht'));
    await tester.tap(find.text('Charakterübersicht'));
    await warteBis(tester, find.bySemanticsLabel(_de.druck_datei_laden('Charakterübersicht')), lang: true);
    // Der Name als Zeile, auf den Knöpfen nur der Weg; der Bildschirmleser hört beides zusammen.
    expect(find.text('Charakterübersicht'), findsOneWidget);
    expect(find.text(_de.druck_datei_laden_kurz), findsOneWidget);
    expect(find.text(_de.druck_datei_teilen_kurz), findsOneWidget);
    expect(find.bySemanticsLabel(_de.druck_datei_teilen('Charakterübersicht')), findsOneWidget);
    keinWortGeteilt(tester, find.byType(RollFlaeche));
    await schliessen(tester, state);
  });

  testWidgets('Profil: 320 px, doppelte Schrift, kein Wort geteilt (Klassen, Hüte, Erfolge)', (tester) async {
    // Mit Erfahrung, damit die Hüte ihre Namen tragen (gesperrte nennen den Rang).
    final state = await oeffnen(tester, Routes.profile, xp: 1450);
    for (final text in ['Forensikerin', 'Melone', 'Meisterkombinierer']) {
      expect(find.text(text, skipOffstage: false), findsWidgets, reason: text);
    }
    keinWortGeteilt(tester, find.byType(RollFlaeche));
    await schliessen(tester, state);
  });

  testWidgets('Assistent: die Aktenmappen teilen bei 320 px und doppelter Schrift kein Wort', (tester) async {
    // Der Assistent zeigt die Akten als eigene Aktenmappen (Lane Assistent).
    final state = await oeffnen(tester, Routes.abendNeu, bereit: find.byType(MAktenmappe));
    keinWortGeteilt(tester, find.byType(MAktenmappe));
    await schliessen(tester, state);
  });

  testWidgets('Sitze (M3): Lobby, Erzähler, Gast-Detektiv und „Wer macht was“ teilen bei 320 px kein Wort', (tester) async {
    Future<void> zeige(WidgetBuilder seite) => zeigeImThema(tester, seite, groesse: const Size(320, 844), schrift: 2, ruhig: true);
    // Lobby eines Gastes mit Wunschwahl, dazu die Lobby des Erzähler-Gastes (teilt zu).
    // Spielernamen tippen die Gäste selbst; geprüft werden die Wörter der App.
    final lobby = lobbyRaum(langerName: false)..nachricht('gastgeber', {'typ': 'sitz', 'spieler': 'g1', 'sitz': 'erzaehler'});
    for (final id in ['g1', 'g2']) {
      await zeige((c) => gastSeiteLive(LiveGast(lobby, spielerId: id)));
      keinWortGeteilt(tester, find.byType(MRahmen));
    }
    // Erzähler-Gast in den Gesprächen: Text und offenes Erzählerpaket.
    final abend = sitzRaum(erzaehler: 'g3');
    spieleBisSitz(abend, 'gespraeche', detektiv: 'gastgeber', leiter: 'g3');
    await zeige((c) => gastSeiteLive(LiveGast(abend, spielerId: 'g3')));
    // Alle Abschnitte des Pakets aufklappen (Befragungen mit Antworten, ungespielte Gäste).
    for (final kopf in [RegExp(r'^Befragungen \('), RegExp(r'^Ungespielte Gäste \(')]) {
      final f = find.textContaining(kopf, findRichText: true);
      if (f.evaluate().isEmpty) continue;
      await tester.ensureVisible(f.first);
      await tester.tap(f.first);
      await tester.pump();
    }
    keinWortGeteilt(tester, find.byType(MRahmen));
    // Gast-Detektiv in den Entscheidungen.
    final detektiv = sitzRaum(detektiv: 'g1', erzaehler: 'gastgeber');
    spieleBisSitz(detektiv, 'entscheidungen', detektiv: 'g1', leiter: 'gastgeber', ersteEntscheidung: true);
    await zeige((c) => gastSeiteLive(LiveGast(detektiv, spielerId: 'g1')));
    keinWortGeteilt(tester, find.byType(MRahmen));
    // „Wer macht was“ mit dem offenen Erzähler-Sitz.
    await zeige((c) => const Scaffold(body: SingleChildScrollView(child: RollenUebersicht(hervorheben: Sitz.erzaehler))));
    for (final sitz in ['detektiv', 'rolle', 'assistenz']) {
      await tester.ensureVisible(find.byKey(ValueKey('uebersicht-$sitz')));
      await tester.tap(find.byKey(ValueKey('uebersicht-$sitz')));
      await tester.pump();
    }
    keinWortGeteilt(tester, find.byType(RollenUebersicht));
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Sitze (M3): Tischruf, Fund und Fertig des Gast-Detektivs und die Figurenwahl der Lobby teilen bei 320 px kein Wort', (tester) async {
    Future<void> zeige(WidgetBuilder seite) => zeigeImThema(tester, seite, groesse: const Size(320, 844), schrift: 2, ruhig: true);
    // Ben ermittelt am eigenen Handy und wählt falsch, damit auch Pech (Tischruf) kommt.
    final raum = sitzRaum(detektiv: 'g1', erzaehler: 'gastgeber');
    spieleBisSitz(raum, 'entscheidungen', detektiv: 'g1', leiter: 'gastgeber', ersteEntscheidung: true);
    final ben = LiveGast(raum, spielerId: 'g1');
    final erm = raum.partieFuerGastgeber!.spiel.ermittlung;
    final gesehen = <String>{};
    const alle = ['tischruf', 'fund', 'fertig'];
    for (var i = 0; i < 600 && !gesehen.containsAll(alle); i++) {
      // Pech kommt erst in einer späteren Runde: bis zu ihren Entscheidungen weiter.
      if (raum.zustandFuer('g1')['phase'] != 'entscheidungen') {
        spieleBisSitz(raum, 'entscheidungen', detektiv: 'g1', leiter: 'gastgeber');
        continue;
      }
      final v = raum.zustandFuer('g1');
      final zug = v['zug'] is Map ? (v['zug'] as Map).cast<String, Object?>() : null;
      final art = zug != null ? '${zug['phase']}' : (v['entscheidung'] is Map ? 'frage' : 'fertig');
      if (art != 'frage' && art != 'aktion' && art != 'wurf' && gesehen.add(art)) {
        await zeige((c) => gastSeiteLive(ben));
        keinWortGeteilt(tester, find.byType(MRahmen));
      }
      switch (art) {
        case 'aktion':
          raum.nachricht('g1', {'typ': 'aktionFertig', 'aktion': zug!['aktion']});
        case 'wurf':
          raum.nachricht(v['wuerfelPate'] as String, {'typ': 'wurf'});
        case 'tischruf':
          raum.nachricht('g1', {'typ': 'tischruf', 'ruf': 'umweg'});
        case 'fund':
          raum.nachricht('g1', {'typ': 'fundGelesen'});
        case 'frage':
          final e = (v['entscheidung'] as Map).cast<String, Object?>();
          final optionen = [for (final o in e['optionen'] as List) (o as Map)['id'] as String];
          final richtig = erm.entscheidung(e['id'] as String).richtig['ahmet'];
          raum.nachricht('g1', {'typ': 'wahl', 'option': optionen.firstWhere((o) => o != richtig, orElse: () => optionen.first)});
        default:
          raum.nachricht('gastgeber', {'typ': 'weiter'});
      }
    }
    expect(gesehen, containsAll(alle));
    // Die Figurenwahl der Lobby: Kachel mit Inhaber und Wunsch eines anderen Gastes.
    final lobby = lobbyRaum(langerName: false)
      ..nachricht('gastgeber', {'typ': 'besetzung', 'rollen': 7})
      ..nachricht('gastgeber', {'typ': 'zuteilen', 'spieler': 'g2', 'rolle': 'fatma'})
      ..nachricht('g2', {'typ': 'wunsch', 'rolle': 'ahmet'})
      ..nachricht('g1', {'typ': 'wunsch', 'rolle': 'fatma'});
    final stand = LobbyStand.aus(lobby.zustandFuer('gastgeber'), partyDaten, 'gastgeber');
    await zeige((c) => Scaffold(
          body: Center(
            child: MKnopf(text: 'auf', onPressed: () => zeigeLobbyWahl(c, stand: stand, spieler: stand.spieler.firstWhere((s) => s.id == 'g1'), befehl: (_) async {})),
          ),
        ));
    await tester.tap(find.text('auf'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.textContaining('Wunsch: Cleo'), findsWidgets);
    keinWortGeteilt(tester, find.byType(Dialog));
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Akte-Knopf der Kampagne: derselbe Name für den Bildschirmleser wie vor der Mappe, ohne Reiter', (tester) async {
    final semantik = tester.ensureSemantics();
    final state = await oeffnen(tester, Routes.start, bereit: find.text('Blue Palm Motel'), breite: 390, schrift: 1);
    expect(find.text('Akte Nr. 01'), findsOneWidget, reason: 'Der Reiter ist sichtbar');
    expect(find.bySemanticsLabel('Spuk im Schlosskeller\nDas Buffet hinter dicken Mauern\nSpuk\n4 bis 20 Personen'), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('Akte Nr')), findsNothing);
    await schliessen(tester, state);
    semantik.dispose();
  });
}
