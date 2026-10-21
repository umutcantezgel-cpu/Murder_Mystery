// M7b: Vorspiel und Morgen im langen Abend an einem Gerät. Lang: nach den
// Rollen das Vorspiel (Rundgang ab 18 Uhr, Einfahrtstor offen bis zur Sperre),
// dann die Diashow; nach der Auflösung der Morgen mit Tageslicht, dann das
// Schlussbild. Punkte, Ende, Würfe und Nachtminuten bleiben gleich; das Journal
// merkt den Rundgang nur bei lang. Kurz: weder Vorspiel noch Morgen.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_test/flutter_test.dart';
import 'package:mordakte/party/bildschirme/aufloesung.dart';
import 'package:mordakte/party/bildschirme/intro.dart';
import 'package:mordakte/party/bildschirme/rundgang.dart';
import 'package:mordakte/party/daten.dart';
import 'package:mordakte/party/diashow_ansicht.dart';
import 'package:mordakte/party/party_seite.dart';
import 'package:mordakte/party/sitzung.dart';
import 'package:mordakte_core/mordakte_core.dart';

import 'hilfe.dart';
import 'rundgang_hilfe.dart';

/// Der Abend [s] wie in der App, mit „Bewegung reduzieren“ (Wege per Kurzblende).
Future<void> _zeige(WidgetTester t, PartySitzung s) async {
  t.view.physicalSize = const Size(390, 844);
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.resetPhysicalSize);
  addTearDown(t.view.resetDevicePixelRatio);
  await t.pumpWidget(rahmen(Builder(
    builder: (context) => MediaQuery(
      data: MediaQuery.of(context).copyWith(disableAnimations: true),
      child: PartyAblauf(sitzung: s),
    ),
  )));
  await t.pump();
  await t.pump();
}

Future<void> _tippe(WidgetTester t, Key key) async {
  await t.ensureVisible(find.byKey(key));
  await t.tap(find.byKey(key));
  await t.pump();
  await t.pump();
}

/// Alles, was den Abend bewertet: Punkte, Würfe, Nachtminuten, Marken, Gewähltes,
/// Gruppenwahlen, Anklage, Funde und Erzähltexte.
String _wertung(PartySitzung s) => [
      s.spiel.punkte,
      [for (final w in s.wuerfe) w.toJson()],
      s.restMinuten,
      s.reserveMinuten,
      s.marken,
      s.spiel.gewaehlt,
      s.spiel.qualitaeten,
      s.angeklagt,
      {for (final e in s.funde.entries) e.key: [for (final f in e.value) f.text]},
      s.spiel.bausteine,
    ].join('|');

void main() {
  setUp(rundgangWeltAusDateien);

  testWidgets('Lang: nach den Rollen das Vorspiel vor der Diashow, Rundgang mit offenem Einfahrtstor, dann die Einleitung', (t) async {
    final s = rundgangSitzung();
    spieleBis(s, PartyPhase.rollen);
    s.weiter();
    expect([s.phase, s.rundgang, s.rundgangStation], [PartyPhase.intro, RundgangTeil.vorspiel, 0]);
    expect(s.kannWeiter, isFalse, reason: 'Erst das Vorspiel, dann die Einleitung');
    final vorher = _wertung(s);
    await _zeige(t, s);
    expect(find.byType(RundgangBildschirm), findsOneWidget);
    expect(find.byType(DiashowAnsicht), findsNothing);
    final stationen = s.rundgangStationen;
    final karte = RundgangBildschirm.letzteKarte.value!;
    for (var i = 0; i < stationen.length; i++) {
      final st = stationen[i];
      await t.pump();
      expect(find.text(st.text!.titel), findsOneWidget, reason: st.id);
      for (final p in st.text!.punkte) {
        expect(find.text(p), findsOneWidget, reason: st.id);
      }
      // Solo: Der Text steht unter der Karte.
      expect(find.byKey(const ValueKey('rundgang-vorlesetext')), findsOneWidget);
      expect(find.text('STATION ${i + 1} VON ${stationen.length}'), findsOneWidget);
      expect([karte.aktuelleEbene, karte.lage.uhr], [st.ebene, st.zeit], reason: st.id);
      if (st.id == 'v_lieferung') {
        // Die Lieferung kommt durchs offene Einfahrtstor; Marek steht beim Lieferwagen.
        expect(karte.welt.offen(karte.welt.portale.singleWhere((p) => p.id == 'p_einfahrtstor').offen, karte.lage), isTrue);
        expect(karte.world.value!.npcs.map((n) => n.id), contains(rundgangDaten.npcKennung['murat']));
      }
      await _tippe(t, const ValueKey('rundgang-weiter'));
    }
    // Nach der Sperre: die Diashow der Einleitung.
    expect(s.rundgang, isNull);
    expect([s.phase, s.dia, s.kannWeiter], [PartyPhase.intro, 0, isTrue]);
    expect(find.byType(RundgangBildschirm), findsNothing);
    expect(find.byType(IntroBildschirm), findsOneWidget);
    expect(find.byType(DiashowAnsicht), findsOneWidget);
    expect(_wertung(s), vorher, reason: 'Der Rundgang ändert nichts am Abend');
    expect(t.takeException(), isNull);
    await t.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Lang: nach der Auflösung der Morgen mit Tageslicht, dann das Schlussbild; Punkte und Ende davor und danach gleich', (t) async {
    final s = rundgangSitzung(pfad: 'fatma');
    spieleBis(s, PartyPhase.aufloesung);
    final punkte = s.spiel.punkte, ende = s.ende.id, wertung = _wertung(s);
    await _zeige(t, s);
    expect(find.byType(AufloesungBildschirm), findsOneWidget);
    await t.ensureVisible(find.text(s.ui('ui.allgemein.weiter')));
    await t.tap(find.text(s.ui('ui.allgemein.weiter')));
    await t.pump();
    await t.pump();
    expect([s.phase, s.rundgang], [PartyPhase.ende, RundgangTeil.morgen]);
    expect(find.byType(RundgangBildschirm), findsOneWidget);
    expect(find.text(s.ui('ui.aufloesung.punkte', {'punkte': '$punkte'})), findsNothing, reason: 'Das Schlussbild kommt erst nach dem Morgen');
    final karte = RundgangBildschirm.letzteKarte.value!;
    final stationen = s.rundgangStationen;
    for (var i = 0; i < stationen.length; i++) {
      await t.pump();
      final st = stationen[i];
      final text = st.textFuer(ende);
      expect(find.text(text.titel), findsOneWidget, reason: st.id);
      expect(find.text(text.punkte.first), findsOneWidget, reason: st.id);
      // Ab dem Finale lesen alle: Der Vorlesetext steht offen.
      expect(find.byKey(const ValueKey('rundgang-vorlesetext')), findsOneWidget);
      expect([karte.aktuelleEbene, karte.lage.uhr], [st.ebene, st.zeit], reason: st.id);
      // Tageslicht-Schalter: draußen am Morgen hell.
      expect([karte.tageslicht, karte.licht!.tag], [true, true], reason: st.id);
      await _tippe(t, const ValueKey('rundgang-weiter'));
    }
    expect([s.phase, s.rundgang], [PartyPhase.ende, null]);
    expect(find.byType(RundgangBildschirm), findsNothing);
    expect(find.text(s.ui('ui.aufloesung.punkte', {'punkte': '$punkte'})), findsOneWidget);
    expect([s.spiel.punkte, s.ende.id, _wertung(s)], [punkte, ende, wertung]);
    // Das Journal kennt den Morgen; nach dem Fortsetzen steht das Schlussbild.
    final befehle = (s.abendstand['befehle'] as List).cast<Map>();
    expect(befehle.where((b) => b['b'] == 'rundgang'), hasLength(stationen.length + 1), reason: 'Vorspiel übersprungen, Morgen abgegangen');
    final weiter = PartySitzung.fortsetzen(rundgangDaten, s.abendstand);
    addTearDown(weiter.dispose);
    expect([weiter.phase, weiter.rundgang, weiter.spiel.punkte, weiter.ende.id], [PartyPhase.ende, null, punkte, ende]);
    expect(t.takeException(), isNull);
    await t.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Rundgang überspringen führt sofort zur Diashow; im Morgen zum Schlussbild', (t) async {
    final s = rundgangSitzung();
    spieleBis(s, PartyPhase.rollen);
    s.weiter();
    await _zeige(t, s);
    await _tippe(t, const ValueKey('rundgang-ueberspringen'));
    expect([s.phase, s.rundgang], [PartyPhase.intro, null]);
    expect(find.byType(DiashowAnsicht), findsOneWidget);
    spieleBis(s, PartyPhase.aufloesung);
    s.weiter();
    await t.pump();
    await t.pump();
    expect([s.phase, s.rundgang], [PartyPhase.ende, RundgangTeil.morgen]);
    s.rundgangWeiter();
    await t.pump();
    await _tippe(t, const ValueKey('rundgang-ueberspringen'));
    expect([s.phase, s.rundgang], [PartyPhase.ende, null]);
    expect(find.byType(AufloesungBildschirm), findsOneWidget);
    expect(find.text(s.ui('ui.aufloesung.punkte', {'punkte': '${s.spiel.punkte}'})), findsOneWidget);
    expect((s.abendstand['befehle'] as List).cast<Map>().where((b) => b['b'] == 'rundgang').map((b) => b['ueberspringen'] ?? b['station']), [true, 0, true]);
    await t.pumpWidget(const SizedBox.shrink());
  });

  test('Kurz und lang mit Vorspiel und Morgen: dieselbe Wertung, dasselbe Ende (gleiches Salz, gleiche Wahl)', () {
    for (final pfad in rundgangDaten.kanon.pfade) {
      final kurz = rundgangSitzung(pfad: pfad, fassung: Abendfassung.kurz);
      final lang = rundgangSitzung(pfad: pfad);
      for (final s in [kurz, lang]) {
        spieleBis(s, PartyPhase.rollen);
        s.weiter();
        rundgangAbgehen(s);
        spieleBis(s, PartyPhase.aufloesung);
        s.weiter();
        rundgangAbgehen(s);
      }
      expect([lang.phase, lang.rundgang], [PartyPhase.ende, null]);
      expect([_wertung(lang), lang.ende.id], [_wertung(kurz), kurz.ende.id], reason: pfad);
      kurz.dispose();
      lang.dispose();
    }
  });

  testWidgets('Reihum mit Erzähler am Tisch: Die Karte sehen alle, der Vorlesetext liegt zugedeckt im Pult, bis der Erzähler hinschaut', (t) async {
    final s = rundgangSitzung(solo: false, erzaehler: 'Eva');
    spieleBis(s, PartyPhase.rollen);
    s.weiter();
    await _zeige(t, s);
    final st = s.rundgangAktuell!;
    expect(find.text(st.text!.titel), findsOneWidget);
    expect(find.byKey(const ValueKey('erzaehlerpult-zu')), findsOneWidget);
    expect(find.byKey(const ValueKey('rundgang-vorlesetext')), findsNothing);
    expect(find.textContaining(st.text!.vorlesen.substring(0, 30)), findsNothing);
    s.pultZeigen();
    await t.pump();
    expect(find.byKey(const ValueKey('rundgang-vorlesetext')), findsOneWidget);
    expect(find.byKey(const ValueKey('erzaehlerpult-zudecken')), findsOneWidget);
    s.pultSchliessen();
    await t.pump();
    expect(find.byKey(const ValueKey('rundgang-vorlesetext')), findsNothing);
    await t.pumpWidget(const SizedBox.shrink());
  });

  test('Fortsetzen mitten im Morgen: dieselbe Station, dasselbe Ende, die Wertung unverändert', () {
    final s = rundgangSitzung(pfad: 'olli');
    spieleBis(s, PartyPhase.aufloesung);
    s.weiter();
    s.rundgangWeiter();
    s.rundgangWeiter();
    final weiter = PartySitzung.fortsetzen(rundgangDaten, s.abendstand);
    expect([weiter.phase, weiter.rundgang, weiter.rundgangStation], [PartyPhase.ende, RundgangTeil.morgen, 2]);
    expect([weiter.ende.id, _wertung(weiter)], [s.ende.id, _wertung(s)]);
    expect(weiter.rundgangText!.titel, s.rundgangText!.titel);
    weiter.dispose();
    s.dispose();
  });

  test('Kurz: kein Vorspiel, kein Morgen, kein Rundgang im Journal', () {
    final s = rundgangSitzung(fassung: Abendfassung.kurz);
    expect(s.vorspielMorgen, isNull);
    spieleBis(s, PartyPhase.rollen);
    s.weiter();
    expect([s.phase, s.rundgang, s.kannWeiter], [PartyPhase.intro, null, isTrue]);
    expect(() => s.rundgangWeiter(), throwsStateError);
    spieleBis(s, PartyPhase.aufloesung);
    s.weiter();
    expect([s.phase, s.rundgang], [PartyPhase.ende, null]);
    expect((s.abendstand['befehle'] as List).cast<Map>().where((b) => b['b'] == 'rundgang'), isEmpty);
    s.dispose();
  });

  testWidgets('Kurz: Nach den Rollen kommt gleich die Diashow, nach der Auflösung gleich das Schlussbild', (t) async {
    final s = rundgangSitzung(fassung: Abendfassung.kurz);
    spieleBis(s, PartyPhase.rollen);
    s.weiter();
    await _zeige(t, s);
    expect(find.byType(RundgangBildschirm), findsNothing);
    expect(find.byType(DiashowAnsicht), findsOneWidget);
    spieleBis(s, PartyPhase.aufloesung);
    s.weiter();
    await t.pump();
    await t.pump();
    expect(find.byType(RundgangBildschirm), findsNothing);
    expect(find.text(s.ui('ui.aufloesung.punkte', {'punkte': '${s.spiel.punkte}'})), findsOneWidget);
    await t.pumpWidget(const SizedBox.shrink());
  });

  test('Lang ohne Inhalt (Akte ohne vorspiel_morgen.json): weder Vorspiel noch Morgen', () {
    final s = PartySitzung(langDaten);
    s.einrichten(rollen: 4, detektiv: 'w', solo: true, fassung: Abendfassung.lang);
    spieleBis(s, PartyPhase.rollen);
    s.weiter();
    expect([s.lang, s.rundgang, s.kannWeiter], [true, null, true]);
    s.dispose();
  });

  testWidgets('App-Assets: Der Schlosskeller lädt Vorspiel und Morgen aus content/welt, das Gewölbe (ohne langfassung) nicht', (t) async {
    final (keller, gewoelbe) = (await t.runAsync(() async => (
          await PartyDaten.laden(rootBundle, fall: 'schlosskeller'),
          await PartyDaten.laden(rootBundle, fall: 'gewoelbe'),
        )))!;
    final v = keller.vorspielMorgen;
    expect(v, isNotNull);
    expect([v!.vorspiel.stationen.length, v.morgen.stationen.length], [rundgangDaten.vorspielMorgen!.vorspiel.stationen.length, rundgangDaten.vorspielMorgen!.morgen.stationen.length]);
    expect(gewoelbe.vorspielMorgen, isNull);
  });
}
