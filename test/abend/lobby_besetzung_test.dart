// Langer Abend M3b: Lobby mit Sitzen, Rollenzahl im Raum und Figurenwahl.
// Der Gastgeber vergibt die Sitze (Detektiv, Erzähler) und teilt Figuren zu;
// Gast-Detektiv und Gast-Erzähler teilen ebenfalls zu, eine reine Rolle nur
// wünscht. Alles geht als Raumnachricht an einen echten Raum.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mordakte/abend/abend_halter.dart';
import 'package:mordakte/abend/einrichtung/klasse_zeile.dart';
import 'package:mordakte/abend/online/gast_ansicht.dart';
import 'package:mordakte/abend/online/gastgeber_lobby.dart';
import 'package:mordakte/abend/online/lobby_besetzung.dart';
import 'package:mordakte/abend/online/online_halter.dart';
import 'package:mordakte/l10n/gen/app_localizations_de.dart';
import 'package:mordakte/meta/meta_store.dart';
import 'package:mordakte/stil/stil.dart';
import 'package:mordakte_core/mordakte_core.dart' show Besetzung;
import 'package:mordakte_core/runden.dart';
import 'package:provider/provider.dart';

import '../party_widgets/hilfe.dart' show akteDaten, partyDaten;
import 'online_hilfe.dart';

final l = LDe();

/// Anbieter der Lobby mit dem Dienst [d].
Widget Function(Widget) _anbieter(TestLobbyDienst d) {
  final halter = OnlineHalter()..uebernehmeDienst(d);
  return (app) => MultiProvider(
        providers: [
          ChangeNotifierProvider<MetaStore>.value(value: MetaStore.memory()..name = 'Anna'),
          ChangeNotifierProvider<OnlineHalter>.value(value: halter),
          ChangeNotifierProvider<AbendHalter>.value(value: AbendHalter()),
        ],
        child: app,
      );
}

/// Die Gastseite von [id] mit der Ansicht des Raums; Befehle gehen als [id] in den Raum.
Widget _gast(BuildContext context, SchlosskellerRaum raum, String id) {
  final inhalt = baueGastSeite(GastKontext(
    context: context,
    dienst: TestGast(raum.zustandFuer(id), spielerId: id),
    befehl: (m) async => raum.nachricht(id, m),
    belohnung: null,
  ));
  return Scaffold(
    body: MRahmen(
      marke: inhalt.marke,
      titel: inhalt.titel,
      untertitel: inhalt.untertitel,
      aktionen: inhalt.aktionen,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: inhalt.kinder),
    ),
  );
}

Future<void> _tippe(WidgetTester tester, Finder f) async {
  await tester.ensureVisible(f);
  await tester.pump();
  await tester.tap(f);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

void main() {
  test('Lobby-Stand: Mindestzahl aus Geräten ohne Sitz, Vorgabe sieben, Vorschlag aus der Gästeliste', () {
    final raum = lobbyRaum();
    var stand = LobbyStand.aus(raum.zustandFuer('gastgeber'), partyDaten, 'gastgeber');
    expect([stand.spieler.length, stand.ohneSitz.length, stand.min, stand.anzahl, stand.rollen], [4, 3, 4, 7, null]);
    expect([stand.ichVergebeSitze, stand.ichTeileZu, stand.sitzeKlar, stand.detektiv?.id], [true, true, true, 'gastgeber']);
    expect(stand.besetzt, partyDaten.texte.besetzung.besetzt(7));
    raum.nachricht('gastgeber', {'typ': 'besetzung', 'rollen': 7});
    raum.nachricht('gastgeber', {'typ': 'zuteilen', 'spieler': 'g2', 'rolle': 'fatma'});
    raum.nachricht('g1', {'typ': 'wunsch', 'rolle': 'olli'});
    stand = LobbyStand.aus(raum.zustandFuer('g1'), partyDaten, 'g1');
    expect([stand.ichVergebeSitze, stand.ichTeileZu], [false, false], reason: 'Ben spielt eine Figur');
    expect(stand.inhaberVon('fatma')?.id, 'g2');
    expect([for (final s in stand.wuenschenSich('olli')) s.id], ['g1']);
    // Gästeliste (M5): Namen ohne Groß- und Kleinschreibung, nur freie, besetzte Figuren, nur Geräte ohne Sitz und Figur.
    expect(stand.vorschlagAus({'ben': 'olli', 'DORA': 'fatma', 'Anna': 'ahmet', 'Zoe': 'can'}), {'g1': 'olli'});
    expect(stand.vorschlagAus({'Ben': 'detective'}), isEmpty, reason: 'Nur Figuren der Besetzung');
  });

  testWidgets('Gastgeber: Rollenzahl liegt im Raum, Sitze und Figuren per Tipp auf einen Platz', (tester) async {
    final raum = lobbyRaum();
    final d = TestLobbyDienst(raum);
    await zeigeImThema(tester, (c) => const GastgeberLobbySeite(), huelle: _anbieter(d));
    await tester.pump();
    expect(raum.lobbyRollen, 7, reason: 'Beim Öffnen geht die Vorgabe an den Raum');
    await _tippe(tester, find.byTooltip(l.online_rollen_mehr));
    expect(raum.lobbyRollen, 8);
    // Ben liest vor.
    await _tippe(tester, find.byKey(const ValueKey('lobby-platz-g1')));
    expect(find.text(l.online_lobby_wahl_titel('Ben')), findsOneWidget);
    await _tippe(tester, find.text(l.abend_platz_erzaehler).last);
    expect(raum.erzaehlerGeraet, 'g1');
    expect(find.textContaining(l.abend_platz_erzaehler), findsWidgets);
    // Cleo bekommt Fatma.
    await _tippe(tester, find.byKey(const ValueKey('lobby-platz-g2')));
    await _tippe(tester, find.byKey(const ValueKey('figur-fatma')));
    expect(raum.zustandFuer('g2')['spieler'], contains(containsPair('figur', 'fatma')));
    expect(find.text(l.online_lobby_zufall), findsWidgets, reason: 'Dora lost beim Start');
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Gastgeber als Erzähler: ohne Gast-Detektiv startet der Abend nicht', (tester) async {
    final raum = lobbyRaum(gastgeberSitz: Sitz.erzaehler);
    for (final g in ['g2']) {
      raum.nachricht(g, {'typ': 'bereit', 'wert': true});
    }
    raum.verbunden('g3', true);
    raum.nachricht('g3', {'typ': 'bereit', 'wert': true});
    final d = TestLobbyDienst(raum);
    await zeigeImThema(tester, (c) => const GastgeberLobbySeite(), huelle: _anbieter(d));
    await tester.pump();
    final start = find.widgetWithText(FilledButton, l.online_abend_starten);
    expect(tester.widget<FilledButton>(start).onPressed, isNull);
    expect(find.byKey(const ValueKey('lobby-sitze')), findsOneWidget);
    expect(find.byType(KlasseZeile), findsNothing, reason: 'Die Klasse wählt der Detektiv');
    await _tippe(tester, find.byKey(const ValueKey('lobby-platz-g1')));
    await _tippe(tester, find.text(l.abend_platz_detektiv).last);
    expect(raum.detektivGeraet, 'g1');
    expect(find.byKey(const ValueKey('lobby-sitze')), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Gast: Platz, Wunsch; Gast-Detektiv und Gast-Erzähler teilen zu, eine Rolle nicht', (tester) async {
    final raum = lobbyRaum();
    raum.nachricht('gastgeber', {'typ': 'sitz', 'spieler': 'g1', 'sitz': 'erzaehler'});
    raum.nachricht('gastgeber', {'typ': 'besetzung', 'rollen': 5});
    // Cleo (Rolle): Zufall, Wunsch Olli.
    await zeigeImThema(tester, (c) => _gast(c, raum, 'g2'));
    expect(find.byKey(const ValueKey('dein-platz')), findsOneWidget);
    expect(find.text(l.online_gast_zufall_text), findsOneWidget);
    expect(find.byType(Slider), findsNothing, reason: 'Eine Rolle legt nichts fest');
    expect(find.text(l.online_gast_verteilen_titel.toUpperCase()), findsNothing);
    await _tippe(tester, find.byKey(const ValueKey('figur-olli')));
    expect(raum.zustandFuer('g2')['spieler'], contains(allOf(containsPair('id', 'g2'), containsPair('wunsch', 'olli'))));
    expect(() => raum.nachricht('g2', {'typ': 'zuteilen', 'spieler': 'g2', 'rolle': 'olli'}), throwsA(isA<PartyRaumFehler>()));
    // Ben (Erzähler) sieht den Wunsch und teilt Cleo Olli zu.
    await zeigeImThema(tester, (c) => _gast(c, raum, 'g1'));
    expect(find.text(l.online_gast_erzaehler_text), findsOneWidget);
    expect(find.text(l.online_gast_verteilen_titel.toUpperCase()), findsOneWidget);
    expect(find.textContaining(l.online_lobby_wunsch(figurName(partyDaten, 'olli'))), findsWidgets);
    await _tippe(tester, find.byKey(const ValueKey('lobby-platz-g2')));
    expect(find.text(l.online_lobby_platz.toUpperCase()), findsNothing, reason: 'Sitze vergibt nur der Gastgeber');
    await _tippe(tester, find.byKey(const ValueKey('figur-olli')));
    expect(raum.zustandFuer('g2')['spieler'], contains(allOf(containsPair('id', 'g2'), containsPair('figur', 'olli'))));
    // Ein Gast-Detektiv teilt ebenso zu (Ben wird Detektiv, der Gastgeber liest vor).
    final zwei = lobbyRaum(gastgeberSitz: Sitz.erzaehler);
    zwei.nachricht('gastgeber', {'typ': 'sitz', 'spieler': 'g1', 'sitz': 'detektiv'});
    await zeigeImThema(tester, (c) => _gast(c, zwei, 'g1'));
    expect(find.text(l.online_gast_detektiv_text), findsOneWidget);
    await _tippe(tester, find.byTooltip(l.online_rollen_mehr));
    expect(zwei.lobbyRollen, 8, reason: 'Der Detektiv legt die Rollenzahl fest');
    await _tippe(tester, find.byKey(const ValueKey('lobby-platz-g2')));
    await _tippe(tester, find.byKey(const ValueKey('figur-can')));
    expect(zwei.zustandFuer('g2')['spieler'], contains(allOf(containsPair('id', 'g2'), containsPair('figur', 'can'))));
  });

  testWidgets('Lobby ohne Überlauf bei 320 px und doppelter Schrift', (tester) async {
    final raum = lobbyRaum();
    raum.nachricht('gastgeber', {'typ': 'sitz', 'spieler': 'g1', 'sitz': 'erzaehler'});
    raum.nachricht('gastgeber', {'typ': 'besetzung', 'rollen': 7});
    raum.nachricht('gastgeber', {'typ': 'zuteilen', 'spieler': 'g2', 'rolle': 'fatma'});
    raum.nachricht('g2', {'typ': 'wunsch', 'rolle': 'ahmet'});
    for (final (groesse, schrift) in const [(Size(320, 640), 2.0), (Size(390, 844), 1.0)]) {
      await zeigeImThema(tester, (c) => const GastgeberLobbySeite(), groesse: groesse, schrift: schrift, huelle: _anbieter(TestLobbyDienst(raum)));
      expect(tester.takeException(), isNull, reason: 'Gastgeber bei $groesse');
      await _tippe(tester, find.byKey(const ValueKey('lobby-platz-g3')));
      expect(tester.takeException(), isNull, reason: 'Wahl bei $groesse');
      // Dora ist getrennt und hat keine Ansicht.
      for (final id in ['g1', 'g2']) {
        await zeigeImThema(tester, (c) => _gast(c, raum, id), groesse: groesse, schrift: schrift);
        expect(tester.takeException(), isNull, reason: '$id bei $groesse');
      }
    }
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Gibt der Gastgeber den Detektiv ab, liest er vor; fehlt ihm ein Platz, sagt der Hinweis das', (tester) async {
    final raum = lobbyRaum();
    final d = TestLobbyDienst(raum);
    await zeigeImThema(tester, (c) => const GastgeberLobbySeite(), huelle: _anbieter(d));
    await tester.pump();
    // Anna gibt Ben den Detektiv-Sitz: Sie rückt auf den freien Erzähler-Sitz, die Sitze stehen.
    await _tippe(tester, find.byKey(const ValueKey('lobby-platz-g1')));
    await _tippe(tester, find.text(l.abend_platz_detektiv).last);
    await tester.pump();
    expect([raum.detektivGeraet, raum.sitzVon('gastgeber')], ['g1', Sitz.erzaehler]);
    expect(LobbyStand.aus(raum.zustandFuer('gastgeber'), partyDaten, 'gastgeber').sitzeKlar, isTrue);
    expect(find.byKey(const ValueKey('lobby-sitze')), findsNothing);
    // Dora liest vor, Anna nimmt sich den Detektiv zurück und gibt ihn Cleo: Jetzt fehlt nur Annas eigener Platz.
    await d.verb.befehl({'typ': 'sitz', 'spieler': 'g3', 'sitz': 'erzaehler'});
    await d.verb.befehl({'typ': 'sitz', 'spieler': 'gastgeber', 'sitz': 'detektiv'});
    await tester.pump();
    await _tippe(tester, find.byKey(const ValueKey('lobby-platz-g2')));
    await _tippe(tester, find.text(l.abend_platz_detektiv).last);
    await tester.pump();
    expect([raum.detektivGeraet, raum.erzaehlerGeraet, raum.sitzVon('gastgeber')], ['g2', 'g3', null]);
    expect(find.text(l.online_lobby_gastgeber_platz), findsOneWidget);
    expect(find.text(l.online_lobby_detektiv_fehlt), findsNothing, reason: 'Der Detektiv steht doch');
    final start = find.widgetWithText(FilledButton, l.online_abend_starten);
    expect(tester.widget<FilledButton>(start).onPressed, isNull);
    // Ein Tipp auf die eigene Karte: Anna liest vor, Dora spielt wieder eine Figur.
    await _tippe(tester, find.byKey(const ValueKey('lobby-platz-gastgeber')));
    await _tippe(tester, find.text(l.abend_platz_erzaehler).last);
    await tester.pump();
    expect([raum.detektivGeraet, raum.erzaehlerGeraet], ['g2', 'gastgeber']);
    expect(find.byKey(const ValueKey('lobby-sitze')), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Akte ohne Erzähler-Sitz: Der Gastgeber ermittelt, Gäste bekommen nur eine Figur', (tester) async {
    final daten = akteDaten('gewoelbe');
    expect(daten.mitErzaehlerSitz, isFalse);
    final raum = lobbyRaum(daten: daten);
    final d = TestLobbyDienst(raum, daten: daten);
    await zeigeImThema(tester, (c) => const GastgeberLobbySeite(), huelle: _anbieter(d));
    await tester.pump();
    await _tippe(tester, find.byKey(const ValueKey('lobby-platz-g1')));
    expect(find.text(l.online_lobby_wahl_titel('Ben')), findsOneWidget, reason: 'Die Figur wählt Anna weiter');
    expect(find.text(l.online_lobby_platz.toUpperCase()), findsNothing, reason: 'Kein Sitz, der Anna ohne Platz ließe');
    expect(find.text(l.abend_platz_detektiv), findsNothing);
    await _tippe(tester, find.text(l.common_close));
    // Annas eigene Karte bietet nichts an: Sie bleibt auf dem Detektiv-Sitz.
    await _tippe(tester, find.byKey(const ValueKey('lobby-platz-gastgeber')));
    expect(find.text(l.online_lobby_wahl_titel('Anna')), findsNothing);
    expect([raum.detektivGeraet, raum.sitzVon('gastgeber')], ['gastgeber', Sitz.detektiv]);
    final stand = LobbyStand.aus(raum.zustandFuer('gastgeber'), daten, 'gastgeber');
    expect(stand.sitzWahl(stand.spieler.firstWhere((s) => s.id == 'g1')), [null]);
    expect(stand.sitzWahl(stand.gastgeber!), [Sitz.detektiv]);
    // Der Sitz heißt, wie die Akte den Ermittler nennt (Gewölbe: Geburtstagskind), nie „Detektiv“.
    expect(lobbyUnterzeile(l, stand, stand.gastgeber!), startsWith('Geburtstagskind'));
    await tester.pumpWidget(const SizedBox.shrink());
  });

  test('Gästeliste: Rollenzahl als Vorgabe, Detektiv-Sitz nur frei und mit Erzähler-Sitz, wegfallende Figuren', () {
    const liste = GaesteListe(personen: 5, gaeste: [Gast('Ben', 'olli'), Gast('cleo', Besetzung.detektiv), Gast('Zoe', 'murat')]);
    final raum = lobbyRaum(gastgeberSitz: Sitz.erzaehler, langerName: false);
    var stand = LobbyStand.aus(raum.zustandFuer('gastgeber'), partyDaten, 'gastgeber', vorgabe: liste.personen);
    expect([stand.vorgabe, stand.anzahl], [5, 5]);
    expect(stand.detektivAus(liste.figurJeName)?.id, 'g2', reason: 'Der Detektiv-Sitz ist frei');
    expect(stand.wegfallendAus(liste), {'murat': 'Zoe'}, reason: 'Murat ist erst ab neun Rollen besetzt');
    expect(LobbyStand.aus(raum.zustandFuer('gastgeber'), partyDaten, 'gastgeber').anzahl, LobbyStand.standardVorgabe);
    // Sitzt der Gastgeber selbst auf dem Detektiv-Sitz, bleibt er dort.
    stand = LobbyStand.aus(lobbyRaum(langerName: false).zustandFuer('gastgeber'), partyDaten, 'gastgeber');
    expect(stand.detektivAus(liste.figurJeName), isNull);
    // Altakten setzen keinen Gast auf den Detektiv-Sitz.
    final gewoelbe = akteDaten('gewoelbe');
    stand = LobbyStand.aus(lobbyRaum(daten: gewoelbe, gastgeberSitz: Sitz.detektiv, langerName: false).zustandFuer('gastgeber'), gewoelbe, 'gastgeber');
    expect(stand.detektivAus({'Cleo': Besetzung.detektiv}), isNull);
  });

  testWidgets('Gästeliste in der Lobby: Rollenzahl, Figur und Detektiv-Sitz vorbelegt, einmal je Gast; Hinweis auf wegfallende Figuren', (tester) async {
    final raum = lobbyRaum(gastgeberSitz: Sitz.erzaehler, langerName: false);
    final meta = MetaStore.memory()
      ..name = 'Anna'
      ..setzeGaesteliste('schlosskeller', const GaesteListe(personen: 5, gaeste: [Gast('Ben', 'olli'), Gast('Cleo', Besetzung.detektiv), Gast('Zoe', 'murat')]));
    final d = TestLobbyDienst(raum);
    final halter = OnlineHalter()..uebernehmeDienst(d);
    await zeigeImThema(
      tester,
      (c) => const GastgeberLobbySeite(),
      huelle: (app) => MultiProvider(
        providers: [
          ChangeNotifierProvider<MetaStore>.value(value: meta),
          ChangeNotifierProvider<OnlineHalter>.value(value: halter),
          ChangeNotifierProvider<AbendHalter>.value(value: AbendHalter()),
        ],
        child: app,
      ),
    );
    for (var i = 0; i < 4; i++) {
      await tester.pump();
    }
    expect(raum.lobbyRollen, 5, reason: 'Die Rollenzahl kommt aus der Gästeliste');
    expect([raum.detektivGeraet, raum.zustandFuer('g1')['spieler']], ['g2', contains(allOf(containsPair('id', 'g1'), containsPair('figur', 'olli')))]);
    final weg = find.byKey(const ValueKey('lobby-gaesteliste-weg'));
    await tester.ensureVisible(weg);
    expect(find.descendant(of: weg, matching: find.text(l.online_lobby_gaesteliste_weg(5, '${figurName(partyDaten, 'murat')} (Zoe)'))), findsOneWidget);
    // Ändert der Gastgeber die Figur von Hand, bleibt es dabei.
    await d.verb.befehl({'typ': 'zuteilen', 'spieler': 'g1', 'rolle': null});
    for (var i = 0; i < 3; i++) {
      await tester.pump();
    }
    expect(raum.zustandFuer('g1')['spieler'], contains(allOf(containsPair('id', 'g1'), isNot(contains('figur')))));
    // Mit neun Rollen ist die Figur dabei: Der Hinweis verschwindet.
    await d.verb.befehl({'typ': 'besetzung', 'rollen': 9});
    await tester.pump();
    expect(find.byKey(const ValueKey('lobby-gaesteliste-weg')), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
