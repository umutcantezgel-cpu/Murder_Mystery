// M3: Der Gastgeber sitzt auf dem Detektiv- oder dem Erzähler-Sitz. Die
// Gastgeber-Sitzung kennt Sitz, Detektiv-Gerät und Vorleser; den Erzähltext
// liest sie über das Fenster des Raums (`erzaehlerAb`), nicht aus dem
// öffentlichen Teil, der ihn nicht mehr trägt. Randgespräche führt der
// Gastgeber nur auf dem Detektiv-Sitz, „Weiter“ nur, wenn er leitet. Die
// Gastansicht zeigt den Erzähltext nur dem Vorleser und den Detektiv am Platz
// des Detektiv-Sitzes. Drei Konstellationen: Host = Erzähler + Gast = Detektiv,
// Host = Detektiv ohne Erzähler, Host = Detektiv + Gast = Erzähler.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mordakte/abend/abend_halter.dart';
import 'package:mordakte/abend/online/gast_ansicht.dart';
import 'package:mordakte/abend/online/gast_seite.dart';
import 'package:mordakte/abend/online/gastgeber_ablauf.dart';
import 'package:mordakte/abend/online/gastgeber_sitzung.dart';
import 'package:mordakte/abend/online/online_halter.dart';
import 'package:mordakte/l10n/gen/app_localizations_de.dart';
import 'package:mordakte/party/daten.dart';
import 'package:mordakte/party/skript.dart';
import 'package:mordakte_core/mordakte_core.dart';
import 'package:mordakte_core/runden.dart';
import 'package:provider/provider.dart';

import '../party_widgets/hilfe.dart' show akteDaten;
import 'online_hilfe.dart';

final de = LDe();

/// Schlosskeller mit Randgesprächen.
PartyDaten get _daten => akteDaten('schlosskeller');

Map<String, Object?> _map(Object? wert) => (wert as Map).cast<String, Object?>();

/// Ein Raum mit Anna (Gastgeberin), Ben (`g1`), Cleo (`g2`) und Dora (`g3`); die
/// Sitze vergibt die Lobby. [erzaehler] und [detektiv] sind Geräte.
SchlosskellerRaum _raum({String detektiv = 'gastgeber', String? erzaehler}) => sitzRaum(detektiv: detektiv, erzaehler: erzaehler);

/// Spielt bis zum Abschnitt [phase] (siehe [spieleBisSitz]).
void _bis(SchlosskellerRaum raum, String phase, {required String detektiv, required String leiter, bool ersteEntscheidung = false}) =>
    spieleBisSitz(raum, phase, detektiv: detektiv, leiter: leiter, ersteEntscheidung: ersteEntscheidung);

Future<void> _warten() async {
  for (var i = 0; i < 5; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

/// Die Gastseite von [id] als Widget mit der Ansicht des Raums.
Future<void> _gastSeite(WidgetTester tester, SchlosskellerRaum raum, String id) =>
    zeigeImThema(tester, (context) => gastSeite(context, raum.zustandFuer(id), spieler: id));

void main() {
  final texte = _daten.texte;

  test('Host = Detektiv ohne Erzähler: Sitz, Vorleser, Fenster aus dem Raum, Randgespräche', () async {
    final raum = _raum();
    final s = GastgeberSitzung(SitzDienst(raum));
    expect([s.sitz, s.istDetektiv, s.istVorleser, s.detektivGeraet, s.leitet], [Sitz.detektiv, true, true, 'gastgeber', true]);
    _bis(raum, 'gespraeche', detektiv: 'gastgeber', leiter: 'gastgeber');
    (s.dienst.verb as SitzVerbindung).aktualisiere();
    await _warten();
    // Das Erzählerfenster kommt aus dem Raum; der öffentliche Teil trägt keinen Erzähltext.
    expect(s.erzaehler, raum.partieFuerGastgeber!.spiel.bausteine.sublist(raum.erzaehlerAb));
    expect(s.erzaehler, contains('runde.1.start'));
    expect(s.dienst.ansicht.containsKey('erzaehler'), isFalse);
    expect([for (final k in s.erzaehler) texte.baustein(k)], _map(s.dienst.ansicht['privat'])['erzaehler']);
    PartySkript.befragungenErledigen(s);
    await _warten();
    s.weiter();
    await _warten();
    _bis(raum, 'entscheidungen', detektiv: 'gastgeber', leiter: 'gastgeber', ersteEntscheidung: true);
    (s.dienst.verb as SitzVerbindung).aktualisiere();
    await _warten();
    expect(_daten.erzaehlung!.gespraeche.any((g) => s.randgespraechMoeglich(g.figur)), isTrue, reason: 'Der Detektiv spricht Zeugen an');
  });

  test('Host = Erzähler + Gast = Detektiv: kein Randgespräch, keine Ermittlung, der Gastgeber liest und leitet', () async {
    final raum = _raum(detektiv: 'g1', erzaehler: 'gastgeber');
    final s = GastgeberSitzung(SitzDienst(raum));
    expect([s.sitz, s.istDetektiv, s.istVorleser, s.detektivGeraet, s.detektivKlasse, s.leitet],
        [Sitz.erzaehler, false, true, 'g1', 'profiler', true]);
    expect(s.menschenRollen, hasLength(2), reason: 'Ben ermittelt und spielt keine Figur');
    _bis(raum, 'entscheidungen', detektiv: 'g1', leiter: 'gastgeber', ersteEntscheidung: true);
    (s.dienst.verb as SitzVerbindung).aktualisiere();
    await _warten();
    expect(s.phase, PartyPhase.entscheidungen);
    expect(_daten.erzaehlung!.gespraeche.any((g) => s.randgespraechMoeglich(g.figur)), isFalse,
        reason: 'Der Erzähler spricht keine Zeugen an (keine Aufforderung)');
    expect(s.randgespraechBeginnen(_daten.erzaehlung!.gespraeche.first.figur), isFalse);
    // Ermittlung nur vom Detektiv-Sitz: Der Raum lehnt die Anklage des Gastgebers ab.
    s.anklagen('ahmet');
    await _warten();
    expect(s.letzterFehler, 'not_detective');
    s.fehlerQuittieren();
    // Der Gast-Detektiv bekommt das npc-Wissen als Notiz, der Gastgeber liest es vor.
    final notizen = (_map(raum.zustandFuer('g1')['privat'])['erzaehlerNotizen'] as List).cast<String>();
    expect(notizen, [for (final k in s.erzaehlerNotizen) texte.baustein(k)]);
    expect(notizen, isNotEmpty);
  });

  test('Host = Detektiv + Gast = Erzähler: der Gastgeber liest nicht und leitet nur, wenn der Erzähler fehlt', () async {
    final raum = _raum(erzaehler: 'g3');
    final s = GastgeberSitzung(SitzDienst(raum));
    expect([s.sitz, s.istDetektiv, s.istVorleser, s.detektivGeraet, s.leitet], [Sitz.detektiv, true, false, 'gastgeber', false]);
    for (final g in ['g1', 'g2']) {
      raum.nachricht(g, {'typ': 'rollenGelesen'});
    }
    (s.dienst.verb as SitzVerbindung).aktualisiere();
    await _warten();
    expect(s.dienst.ansicht['kannWeiter'], isTrue, reason: 'Der Raum wäre bereit');
    expect(s.kannWeiter, isFalse, reason: 'Weiter drückt der Erzähler');
    // Fällt der Erzähler aus, übernimmt der Gastgeber erst nach der Frist (Plan M3: zwei Minuten).
    final frist = GastgeberSitzung.erzaehlerFrist;
    GastgeberSitzung.erzaehlerFrist = const Duration(milliseconds: 30);
    addTearDown(() => GastgeberSitzung.erzaehlerFrist = frist);
    raum.verbunden('g3', false);
    expect([s.uebernahmeFrist, s.leitet, s.kannWeiter, s.istVorleser], [true, false, false, false], reason: 'Die Frist läuft');
    expect(s.vorleserName, 'Dora', reason: 'Bis dahin steht der getrennte Erzähler da');
    await Future<void>.delayed(const Duration(milliseconds: 80));
    expect([s.uebernahmeFrist, s.leitet, s.kannWeiter], [false, true, true], reason: 'Nach der Frist leitet der Gastgeber');
    raum.verbunden('g3', true);
    expect([s.uebernahmeFrist, s.leitet], [false, false], reason: 'Zurück leitet wieder der Erzähler');
    raum.nachricht('g3', {'typ': 'weiter'});
    (s.dienst.verb as SitzVerbindung).aktualisiere();
    await _warten();
    expect(s.phase, PartyPhase.intro);
    // Den Erzähltext hat der Erzähler; der Gastgeber sieht nur, dass vorgelesen wird.
    final host = s.dienst.ansicht;
    expect([host['erzaehlerLiest'], _map(host['privat']).containsKey('erzaehler')], [true, false]);
    expect(_map(raum.zustandFuer('g3')['privat'])['erzaehler'], [for (final k in s.erzaehler) texte.baustein(k)]);
  });

  test('Übernimmt der Gastgeber den Detektiv-Sitz vom Erzähler-Sitz aus, liest und leitet er ohne Frist weiter', () async {
    // Host = Erzähler + Gast = Detektiv: Ben fällt aus, Anna ermittelt selbst. Ben
    // landet getrennt auf dem Erzähler-Sitz; vorgelesen hat bis eben Anna.
    final raum = _raum(detektiv: 'g1', erzaehler: 'gastgeber');
    final s = GastgeberSitzung(SitzDienst(raum));
    raum.verbunden('g1', false);
    (s.dienst.verb as SitzVerbindung).aktualisiere();
    await _warten();
    expect([s.detektivWeg, s.leitet, s.istVorleser, s.uebernahmeFrist], [true, true, true, false]);
    s.detektivNeu('gastgeber');
    await _warten();
    (s.dienst.verb as SitzVerbindung).aktualisiere();
    await _warten();
    expect([raum.detektivGeraet, raum.erzaehlerGeraet, raum.vorleser], ['gastgeber', 'g1', 'gastgeber']);
    expect([s.istDetektiv, s.uebernahmeFrist, s.leitet, s.istVorleser], [true, false, true, true], reason: 'Keine Frist für Ben');
    expect(s.vorleserName, 'Anna');
    // Kommt Ben zurück, liest er als Erzähler; fällt er dann aus, gilt die Frist wie sonst.
    final frist = GastgeberSitzung.erzaehlerFrist;
    GastgeberSitzung.erzaehlerFrist = const Duration(milliseconds: 30);
    addTearDown(() => GastgeberSitzung.erzaehlerFrist = frist);
    raum.verbunden('g1', true);
    expect([s.uebernahmeFrist, s.leitet, s.istVorleser], [false, false, false]);
    raum.verbunden('g1', false);
    expect([s.uebernahmeFrist, s.leitet, s.vorleserName], [true, false, 'Ben'], reason: 'Ben las vor');
    await Future<void>.delayed(const Duration(milliseconds: 80));
    expect([s.uebernahmeFrist, s.leitet, s.istVorleser], [false, true, true]);
    s.dispose();
  });

  testWidgets('Gastansicht: Erzähltext nur beim Vorleser, der Detektiv sitzt am Platz des Detektiv-Sitzes', (tester) async {
    // Host = Detektiv + Gast = Erzähler: Dora liest vor, die Rollen hören zu.
    final raum = _raum(erzaehler: 'g3');
    _bis(raum, 'intro', detektiv: 'gastgeber', leiter: 'g3');
    final start = texte.baustein(raum.partieFuerGastgeber!.spiel.bausteine.sublist(raum.erzaehlerAb).first).substring(0, 40);
    await _gastSeite(tester, raum, 'g3');
    expect(find.textContaining(start), findsOneWidget, reason: 'Die Erzählerin liest vor');
    for (final id in ['g1', 'g2']) {
      await _gastSeite(tester, raum, id);
      expect(find.textContaining(start), findsNothing, reason: '$id hört zu');
    }
    // Host = Erzähler + Gast = Detektiv: Ben ermittelt; am Tisch heißt der Detektiv Ben, nicht die Gastgeberin.
    final zwei = _raum(detektiv: 'g1', erzaehler: 'gastgeber');
    _bis(zwei, 'intro', detektiv: 'g1', leiter: 'gastgeber');
    await _gastSeite(tester, zwei, 'g1');
    expect(find.textContaining(start), findsNothing, reason: 'Der Gast-Detektiv hört zu');
    final c = GastKontext(
      context: tester.element(find.byType(Scaffold).first),
      dienst: TestGast(zwei.zustandFuer('g2'), spielerId: 'g2'),
      befehl: (_) async {},
      belohnung: null,
    );
    expect(c.personAmTisch(Besetzung.detektiv), 'Ben');
    expect([for (final p in c.spieler) p.sitz], [Sitz.erzaehler, Sitz.detektiv, Sitz.rolle, Sitz.rolle]);
    expect([c.vorleser, c.erzaehlerTexte, c.sitz], [false, isEmpty, Sitz.rolle]);
    final detektiv = GastKontext(
      context: tester.element(find.byType(Scaffold).first),
      dienst: TestGast(zwei.zustandFuer('g1'), spielerId: 'g1'),
      befehl: (_) async {},
      belohnung: null,
    );
    expect([detektiv.sitz, detektiv.dossier, detektiv.vorleser], [Sitz.detektiv, null, false]);
  });

  testWidgets('Host = Detektiv + Gast = Erzähler: Ist der Abschnitt fertig, sagt der Fuß jedes Bildschirms, dass Dora weiterführt', (tester) async {
    final raum = _raum(erzaehler: 'g3');
    final s = GastgeberSitzung(SitzDienst(raum));
    final verb = s.dienst.verb as SitzVerbindung;
    Future<void> zeigen() async {
      verb.aktualisiere();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
    }

    await zeigeImThema(
      tester,
      (c) => Scaffold(body: GastgeberAblauf(sitzung: s)),
      huelle: (app) => MultiProvider(
        providers: [
          ChangeNotifierProvider<OnlineHalter>.value(value: OnlineHalter()),
          ChangeNotifierProvider<AbendHalter>.value(value: AbendHalter()),
        ],
        child: app,
      ),
    );
    final hinweis = find.byKey(const ValueKey('fuss-hinweis'));
    // Rollen: Solange jemand liest, ruht „Weiter“ ohne Hinweis; danach führt Dora weiter.
    expect(hinweis, findsNothing);
    for (final g in ['g1', 'g2']) {
      raum.nachricht(g, {'typ': 'rollenGelesen'});
    }
    await zeigen();
    expect([s.abschnittFertig, s.leitet, s.kannWeiter], [true, false, false]);
    expect(find.descendant(of: hinweis, matching: find.text(de.vorleser_fuehrt('Dora'))), findsOneWidget);
    // Gruppenwahl, nachdem alle gewählt haben.
    _bis(raum, 'gruppenwahl', detektiv: 'gastgeber', leiter: 'g3');
    await zeigen();
    expect(hinweis, findsNothing, reason: 'Noch wählt jemand');
    for (final g in ['g1', 'g2']) {
      raum.nachricht(g, {'typ': 'stimme', 'kooperativ': true});
    }
    await zeigen();
    expect(s.alleGestimmt, isTrue);
    expect(find.text(de.vorleser_fuehrt('Dora')), findsOneWidget);
    // Ist Dora getrennt, steht dort die Frist; ist sie zurück, führt sie wieder weiter.
    raum.verbunden('g3', false);
    await zeigen();
    expect(find.text(de.vorleser_frist('Dora')), findsOneWidget);
    expect(find.text(de.vorleser_fuehrt('Dora')), findsNothing);
    raum.verbunden('g3', true);
    await zeigen();
    expect(find.text(de.vorleser_fuehrt('Dora')), findsOneWidget);
    // Anklage: Anna klagt an, Dora führt weiter.
    _bis(raum, 'anklage', detektiv: 'gastgeber', leiter: 'g3');
    raum.nachricht('gastgeber', {'typ': 'anklage', 'person': 'ahmet'});
    await zeigen();
    expect(find.text(de.vorleser_fuehrt('Dora')), findsOneWidget);
    // Finale: Alle lesen, aber weiter führt Dora.
    _bis(raum, 'finale', detektiv: 'gastgeber', leiter: 'g3');
    await zeigen();
    expect([s.istVorleser, s.leitet], [true, false]);
    expect(find.text(de.vorleser_fuehrt('Dora')), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    s.dispose();
  });

  testWidgets('Leitet der Gastgeber selbst, bleibt der Fuß ohne Hinweis', (tester) async {
    final raum = _raum(detektiv: 'g1', erzaehler: 'gastgeber');
    final s = GastgeberSitzung(SitzDienst(raum));
    for (final g in ['g2', 'g3']) {
      raum.nachricht(g, {'typ': 'rollenGelesen'});
    }
    (s.dienst.verb as SitzVerbindung).aktualisiere();
    await zeigeImThema(
      tester,
      (c) => Scaffold(body: GastgeberAblauf(sitzung: s)),
      huelle: (app) => MultiProvider(
        providers: [
          ChangeNotifierProvider<OnlineHalter>.value(value: OnlineHalter()),
          ChangeNotifierProvider<AbendHalter>.value(value: AbendHalter()),
        ],
        child: app,
      ),
    );
    expect([s.abschnittFertig, s.leitet, s.kannWeiter], [true, true, true]);
    expect(find.byKey(const ValueKey('fuss-hinweis')), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
    s.dispose();
  });

  group('Ausfall des Gast-Detektivs (Nachschliff M3)', () {
    Future<void> zeige(WidgetTester tester, GastgeberSitzung s) => zeigeImThema(
          tester,
          (c) => Scaffold(body: GastgeberAblauf(sitzung: s)),
          huelle: (app) => MultiProvider(
            providers: [
              ChangeNotifierProvider<OnlineHalter>.value(value: OnlineHalter()),
              ChangeNotifierProvider<AbendHalter>.value(value: AbendHalter()),
            ],
            child: app,
          ),
        );

    Future<void> tippe(WidgetTester tester, Finder f) async {
      await tester.ensureVisible(f);
      await tester.pump();
      await tester.tap(f);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
    }

    testWidgets('Ein Band sagt, dass Ben fehlt; der Gastgeber gibt den Sitz an Cleo, beide tauschen', (tester) async {
      final raum = _raum(detektiv: 'g1', erzaehler: 'gastgeber');
      final s = GastgeberSitzung(SitzDienst(raum));
      final cleo = raum.rolleVon('g2');
      await zeige(tester, s);
      expect([s.detektivWeg, find.byKey(const ValueKey('detektiv-weg')).evaluate().length], [false, 0]);
      raum.verbunden('g1', false);
      (s.dienst.verb as SitzVerbindung).aktualisiere();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(s.detektivWeg, isTrue);
      expect(find.text(de.online_detektiv_weg('Ben')), findsOneWidget);
      await tippe(tester, find.byKey(const ValueKey('detektiv-weitergeben')));
      expect(find.text(de.online_detektiv_wer), findsOneWidget);
      expect(find.byKey(const ValueKey('detektiv-an-g1')), findsNothing, reason: 'Nicht an den, der fehlt');
      for (final id in ['gastgeber', 'g2', 'g3']) {
        expect(find.byKey(ValueKey('detektiv-an-$id')), findsOneWidget, reason: id);
      }
      await tippe(tester, find.byKey(const ValueKey('detektiv-an-g2')));
      expect([raum.detektivGeraet, raum.rolleVon('g1'), raum.rolleVon('g2')], ['g2', cleo, null]);
      expect(find.text(de.online_detektiv_neu('Cleo')), findsOneWidget);
      expect(find.byKey(const ValueKey('detektiv-weg')), findsNothing, reason: 'Cleo ist da');
      expect([s.istDetektiv, s.sitz], [false, Sitz.erzaehler]);
      await tester.pumpWidget(const SizedBox.shrink());
      s.dispose();
    });

    testWidgets('Der Gastgeber übernimmt selbst: Er ermittelt, Ben bekommt den Erzähler-Sitz', (tester) async {
      final raum = _raum(detektiv: 'g1', erzaehler: 'gastgeber');
      final s = GastgeberSitzung(SitzDienst(raum));
      raum.verlassen('g1');
      (s.dienst.verb as SitzVerbindung).aktualisiere();
      await zeige(tester, s);
      expect(find.byKey(const ValueKey('detektiv-weg')), findsOneWidget, reason: 'Auch nach dem Aufgeben');
      await tippe(tester, find.byKey(const ValueKey('detektiv-weitergeben')));
      await tippe(tester, find.byKey(const ValueKey('detektiv-an-gastgeber')));
      expect([raum.detektivGeraet, raum.erzaehlerGeraet, s.istDetektiv, s.sitz], ['gastgeber', 'g1', true, Sitz.detektiv]);
      expect(find.text(de.online_platz_neu_detektiv), findsOneWidget);
      expect(find.byKey(const ValueKey('detektiv-weg')), findsNothing);
      await tester.pumpWidget(const SizedBox.shrink());
      s.dispose();
    });

    testWidgets('Am Gast-Gerät: Cleo erfährt, dass sie jetzt ermittelt, und öffnet ihre Detektivkarte', (tester) async {
      final raum = _raum(detektiv: 'g1', erzaehler: 'gastgeber');
      final cleo = LiveGast(raum, spielerId: 'g2');
      final halter = OnlineHalter()..uebernehmeGast(cleo);
      await zeigeImThema(
        tester,
        (c) => const GastSeite(),
        groesse: const Size(390, 2400),
        huelle: (app) => MultiProvider(
          providers: [
            ChangeNotifierProvider<OnlineHalter>.value(value: halter),
            ChangeNotifierProvider<AbendHalter>.value(value: AbendHalter()),
          ],
          child: app,
        ),
      );
      expect(find.byKey(const ValueKey('gast-detektivkarte')), findsNothing, reason: 'Cleo spielt eine Figur');
      raum.verbunden('g1', false);
      raum.nachricht('gastgeber', {'typ': 'detektivNeu', 'spieler': 'g2'});
      cleo.geaendert();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byKey(const ValueKey('platz-neu')), findsOneWidget);
      expect(find.text(de.online_platz_neu_detektiv), findsOneWidget);
      // In der Rollenphase steht die Detektivkarte im Inhalt, danach im Fuß der Seite.
      // Ben ist zurück und liest Cleos Figur.
      raum.verbunden('g1', true);
      for (final g in ['g1', 'g3']) {
        raum.nachricht(g, {'typ': 'rollenGelesen'});
      }
      raum.nachricht('gastgeber', {'typ': 'weiter'});
      cleo.geaendert();
      await tester.pump();
      await tippe(tester, find.byKey(const ValueKey('gast-detektivkarte')));
      expect(find.text(de.detektiv_karte_titel), findsWidgets);
      await tester.pumpWidget(const SizedBox.shrink());
    });
  });
}
