// Online-Bildschirme in der Ermittlungsmappe (M2): Jede Ansicht eines Gastgeräts passt
// bei 320 und 390 px, auch mit doppelter Schrift und bei „Bewegung reduzieren“. Das
// Dossier zeigt Täterin oder Täter mit denselben Köpfen, Stempeln und Mappen in derselben
// Folge wie Unschuldige (K-22, E-041). Lobby, Beitritt und die Wartebildschirme des
// Gastgebers laufen ohne Überlauf; Bots tragen ihren Stempel. Die Taschenuhr steht bei
// „Bewegung reduzieren“ still.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mordakte/abend/abend_halter.dart';
import 'package:mordakte/abend/online/beitreten_seite.dart';
import 'package:mordakte/abend/online/gast_ansicht.dart';
import 'package:mordakte/abend/online/gast_seite.dart';
import 'package:mordakte/abend/online/gastgeber_ablauf.dart';
import 'package:mordakte/abend/online/gastgeber_lobby.dart';
import 'package:mordakte/abend/online/gastgeber_sitzung.dart';
import 'package:mordakte/abend/online/gastgeber_wartet.dart';
import 'package:mordakte/abend/online/online_halter.dart';
import 'package:mordakte/abend/online/online_teile.dart';
import 'package:mordakte/l10n/gen/app_localizations_de.dart';
import 'package:mordakte/meta/meta_store.dart';
import 'package:mordakte/stil/mappe/online_bausteine.dart';
import 'package:mordakte/stil/stil.dart';
import 'package:mordakte_netz/mordakte_netz.dart' show VerbindungsStatus;
import 'package:provider/provider.dart';

import 'online_hilfe.dart';

/// Die Ansicht von Ben (`g1`) direkt nach dem Start, einmal als Täter und einmal unschuldig.
({Map<String, Object?> taeter, Map<String, Object?> unschuldig}) dossierAnsichten() {
  Map<String, Object?>? taeter;
  Map<String, Object?>? unschuldig;
  for (final pfad in const ['ahmet', 'fatma', 'olli', 'can']) {
    final raum = testRaum(pfad: pfad);
    starte(raum);
    final v = raum.zustandFuer('g1');
    final rolle = (v['privat'] as Map)['rolle'];
    if (rolle == pfad) {
      taeter ??= v;
    } else {
      unschuldig ??= v;
    }
  }
  return (taeter: taeter!, unschuldig: unschuldig!);
}

/// Anbieter, die Lobby und Beitritt lesen; die Lobby bekommt jedes Mal einen frischen Raum.
Widget Function(Widget) anbieter() {
  final halter = OnlineHalter()..uebernehmeDienst(TestLobbyDienst(lobbyPlaetze));
  return (app) => MultiProvider(
        providers: [
          ChangeNotifierProvider<MetaStore>.value(value: MetaStore.memory()..name = 'Test'),
          ChangeNotifierProvider<OnlineHalter>.value(value: halter),
          ChangeNotifierProvider<AbendHalter>.value(value: AbendHalter()),
        ],
        child: app,
      );
}

int botStempel(WidgetTester tester, String text) => tester.widgetList<MStempel>(find.byType(MStempel)).where((s) => s.text == text).length;

void main() {
  final l = LDe();
  final ansichten = ansichtenEinesAbends();

  testWidgets('Gastansicht: jeder Abschnitt ohne Überlauf bei 320 und 390 px, auch mit doppelter Schrift', (tester) async {
    expect(
      ansichten.keys,
      containsAll(['lobby', 'rollen', 'rollen-danach', 'gespraeche', 'entscheidungen:frage', 'gruppenwahl', 'gruppenwahl-danach', 'anklage', 'aufloesung', 'ende']),
      reason: 'Der Abend im Raum läuft durch alle Abschnitte',
    );
    const faelle = [
      (Size(390, 844), 1.0, false),
      (Size(320, 640), 1.0, false),
      (Size(320, 640), 2.0, true),
      (Size(390, 844), 2.0, false),
    ];
    for (final (groesse, schrift, ruhig) in faelle) {
      for (final e in ansichten.entries) {
        await zeigeImThema(tester, (c) => gastSeite(c, e.value), groesse: groesse, schrift: schrift, ruhig: ruhig);
        expect(tester.takeException(), isNull, reason: '${e.key} bei ${groesse.width.round()} px, Schrift $schrift');
      }
    }
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Dossier: Täter und Unschuldige mit gleichen Köpfen, Stempeln und Mappen in gleicher Folge', (tester) async {
    final koepfe = [l.online_dossier_wer, l.online_dossier_ziel, l.online_dossier_weiss, l.online_dossier_verbirgt, l.online_dossier_besetzung];
    final (:taeter, :unschuldig) = dossierAnsichten();

    Future<({List<String> koepfe, List<String> stempel, int mappen, int fotos})> gestalt(Map<String, Object?> v) async {
      await zeigeImThema(
        tester,
        (c) => Scaffold(
          body: SingleChildScrollView(
            child: DossierAnsicht(kontext: GastKontext(context: c, dienst: TestGast(v), befehl: (_) async {}, belohnung: null)),
          ),
        ),
        groesse: const Size(390, 3000),
      );
      expect(tester.takeException(), isNull);
      final gefunden = [for (final k in koepfe) if (find.text(k).evaluate().isNotEmpty) k]
        ..sort((a, b) => tester.getTopLeft(find.text(a)).dy.compareTo(tester.getTopLeft(find.text(b)).dy));
      return (
        koepfe: gefunden,
        stempel: [for (final s in tester.widgetList<MStempel>(find.byType(MStempel))) s.text],
        mappen: find.byType(MAktenmappe).evaluate().length,
        fotos: find.byType(MFotoabzug).evaluate().length,
      );
    }

    final a = await gestalt(unschuldig);
    expect(a.koepfe, koepfe, reason: 'Das Dossier hat alle Köpfe in fester Folge');
    expect(a.stempel, [l.online_dossier_stempel]);
    expect(a.mappen, 1);
    expect(a.fotos, 1);

    final b = await gestalt(taeter);
    expect(b.koepfe, a.koepfe, reason: 'Täterin oder Täter: dieselben Köpfe in derselben Folge');
    expect(b.stempel, a.stempel, reason: 'Dieselben Stempel');
    expect(b.mappen, a.mappen);
    expect(b.fotos, a.fotos);
    // Tarnung und Tatwissen stehen ohne eigenen Kopf unter „Was ich verberge“.
    final verbirgt = tester.getTopLeft(find.text(l.online_dossier_verbirgt)).dy;
    final besetzung = tester.getTopLeft(find.text(l.online_dossier_besetzung)).dy;
    for (final unter in [l.online_dossier_tarnung, l.online_dossier_tatwissen]) {
      for (final e in find.text(unter).evaluate()) {
        final y = tester.getTopLeft(find.byWidget(e.widget)).dy;
        expect(y, inExclusiveRange(verbirgt, besetzung), reason: '$unter steht im Abschnitt „Was ich verberge“');
        expect((e.widget as Text).style?.color, isNot(MRoh.stempelRot), reason: '$unter ist kein Formularkopf');
      }
    }
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Gastgeber: Lobby, Beitritt, Rollen und Gruppenwahl ohne Überlauf; Bots mit Stempel', (tester) async {
    final semantik = tester.ensureSemantics();
    final raum = testRaum();
    starte(raum);
    raum.nachricht('g1', {'typ': 'rollenGelesen'});
    final rollen = GastgeberSitzung(TestAbendDienst(raum));
    final raum2 = testRaum();
    starte(raum2);
    spieleBisPhase(raum2, 'gruppenwahl');
    raum2.nachricht('g1', {'typ': 'stimme', 'kooperativ': true});
    final wahl = GastgeberSitzung(TestAbendDienst(raum2));

    for (final (groesse, schrift) in const [(Size(320, 640), 2.0), (Size(390, 844), 1.0)]) {
      final grund = '${groesse.width.round()} px, Schrift $schrift';
      await zeigeImThema(tester, (c) => const GastgeberLobbySeite(), groesse: groesse, schrift: schrift, huelle: anbieter());
      expect(tester.takeException(), isNull, reason: 'Lobby bei $grund');
      expect(find.bySemanticsLabel(l.online_code_semantik('ABC-DEF')), findsOneWidget);
      expect(find.text(l.online_rollen_anzahl(7)), findsOneWidget);
      expect(find.byTooltip(l.online_rollen_weniger), findsOneWidget);
      // Vier Rollen bleiben ohne Gast: vier gestempelte Schattenrisse.
      expect(botStempel(tester, l.online_bot_stempel), 4, reason: 'Bots bei $grund');

      await zeigeImThema(tester, (c) => const BeitretenSeite(raum: 'abcdef'), groesse: groesse, schrift: schrift, huelle: anbieter());
      expect(tester.takeException(), isNull, reason: 'Beitritt bei $grund');
      expect(find.byKey(const ValueKey('beitreten-code')), findsOneWidget);

      await zeigeImThema(tester, (c) => Scaffold(body: GastgeberRollenWarten(sitzung: rollen)), groesse: groesse, schrift: schrift);
      expect(tester.takeException(), isNull, reason: 'Rollen bei $grund');
      expect(find.text(l.online_rollen_warten(1, 2)), findsOneWidget);
      expect(botStempel(tester, l.online_rollen_gelesen), 1, reason: 'Ben hat gelesen: ein Stempel');
      expect(find.byType(OnlinePlatzKarte), findsNWidgets(2));
      expect(botStempel(tester, l.online_bot_stempel), 2, reason: 'Zwei Rollen spielen Bots');

      await zeigeImThema(tester, (c) => Scaffold(body: GastgeberGruppenwahl(sitzung: wahl)), groesse: groesse, schrift: schrift);
      expect(tester.takeException(), isNull, reason: 'Gruppenwahl bei $grund');
      expect(find.text(l.online_wahl_fortschritt(1, 2)), findsOneWidget);
      expect(botStempel(tester, l.online_wahl_abgegeben_kurz), 1);
    }
    await tester.pumpWidget(const SizedBox.shrink());
    rollen.dispose();
    wahl.dispose();
    semantik.dispose();
  });

  testWidgets('Gastseite: Verbindungszustand als Telegramm, „Abend verlassen“ fragt mit einer Karteikarte', (tester) async {
    final halter = OnlineHalter()..uebernehmeGast(TestGast(ansichten['gespraeche']!, status: VerbindungsStatus.getrennt));
    await zeigeImThema(
      tester,
      (c) => const GastSeite(),
      groesse: const Size(320, 640),
      schrift: 2,
      huelle: (app) => MultiProvider(
        providers: [
          ChangeNotifierProvider<OnlineHalter>.value(value: halter),
          ChangeNotifierProvider<AbendHalter>.value(value: AbendHalter()),
        ],
        child: app,
      ),
    );
    expect(tester.takeException(), isNull);
    expect(find.descendant(of: find.byKey(const ValueKey('online-status')), matching: find.text(l.online_status_getrennt)), findsOneWidget);
    expect(find.byType(OnlineHinweisKarte), findsOneWidget);
    await tester.ensureVisible(find.text(l.online_verlassen));
    await tester.pump();
    await tester.tap(find.text(l.online_verlassen));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(MKarteikartenDialog), findsOneWidget, reason: 'Die Rückfrage ist eine Karteikarte');
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text(l.online_verlassen_titel), findsOneWidget);
    expect(find.text(l.online_verlassen_ja), findsOneWidget);
    await tester.tap(find.text(l.online_verlassen_nein));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(MKarteikartenDialog), findsNothing, reason: '„Bleiben“ schließt die Rückfrage');
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Gastgeber im Abend: Menü und „Abend beenden“ als Karteikarten', (tester) async {
    final raum = testRaum();
    starte(raum);
    final sitzung = GastgeberSitzung(TestAbendDienst(raum));
    await zeigeImThema(
      tester,
      (c) => Scaffold(body: GastgeberAblauf(sitzung: sitzung)),
      groesse: const Size(320, 640),
      schrift: 2,
      huelle: (app) => MultiProvider(
        providers: [
          ChangeNotifierProvider<OnlineHalter>.value(value: OnlineHalter()),
          ChangeNotifierProvider<AbendHalter>.value(value: AbendHalter()),
        ],
        child: app,
      ),
    );
    expect(tester.takeException(), isNull);
    expect(find.byKey(const ValueKey('online-leiste')), findsOneWidget);
    await tester.tap(find.byTooltip(l.online_menue));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(tester.takeException(), isNull, reason: 'Das Menü passt auch mit doppelter Schrift');
    expect(find.byType(MKarteikartenDialog), findsOneWidget);
    expect(find.byType(PlatzZeile), findsNWidgets(3));
    await tester.tap(find.text(l.online_beenden));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(tester.takeException(), isNull);
    expect(find.byType(MKarteikartenDialog), findsNWidgets(2), reason: 'Die Rückfrage liegt als zweite Karteikarte darüber');
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text(l.online_beenden_titel), findsOneWidget);
    await tester.tap(find.text(l.online_beenden_nein));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(MKarteikartenDialog), findsOneWidget, reason: '„Weiterspielen“ schließt nur die Rückfrage');
    await tester.pumpWidget(const SizedBox.shrink());
    sitzung.dispose();
  });

  testWidgets('Taschenuhr: tickt im Sekundentakt, steht bei „Bewegung reduzieren“ still', (tester) async {
    CustomPainter maler() => tester.widget<CustomPaint>(find.descendant(of: find.byType(MOnlineTaschenuhr), matching: find.byType(CustomPaint))).painter!;
    for (final ruhig in [false, true]) {
      await zeigeImThema(tester, (c) => Scaffold(body: OnlineWarteNotiz(text: l.online_warten_spielleitung)), ruhig: ruhig);
      final vorher = maler();
      await tester.pump(const Duration(milliseconds: 1100));
      expect(maler().shouldRepaint(vorher), !ruhig, reason: ruhig ? 'Ruhig: der Zeiger springt nicht' : 'Der Sekundenzeiger springt weiter');
    }
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
