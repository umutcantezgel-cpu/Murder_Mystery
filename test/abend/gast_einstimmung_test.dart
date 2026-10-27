// Finale Schlosskeller (A-063) online: die Einstimmung im Raum. Der Gastgeber
// schaltet sie in der Meta ein (`einstimmung: true`, nur wenn an); der Raum hält
// den Schritt. Alle sehen Kapitel und Vorstellungskarte (eigene Figur: „Du bist
// dran“), den Vorlesetext nur der Vorleser-Sitz (privat `einstimmungText`). Wer
// leitet, schaltet weiter oder überspringt; das Vorspiel wartet. Das
// Gastgebergerät spiegelt die Einstimmung in seiner Sitzung.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mordakte/abend/online/ansicht.dart' show spielerAusAnsicht;
import 'package:mordakte/abend/online/gastgeber_dienst.dart';
import 'package:mordakte/abend/online/gastgeber_sitzung.dart';
import 'package:mordakte/l10n/gen/app_localizations_de.dart';
import 'package:mordakte/party/bildschirme/einstimmung.dart';
import 'package:mordakte/party/daten.dart';
import 'package:mordakte/party/party_seite.dart';
import 'package:mordakte_core/mordakte_core.dart';
import 'package:mordakte_core/runden.dart' show SchlosskellerRaum;
import 'package:mordakte_netz/mordakte_netz.dart' show RelayParameter, SpeicherAblage;

import '../party_widgets/erzaehl_hilfe.dart';
import '../party_widgets/hilfe.dart' show rahmen;
import 'online_hilfe.dart';

final l = LDe();

/// Kein Relais nötig: Der Raum entsteht ohne Verbindung (erst `oeffnen` verbindet).
const _ohneRelais = RelayParameter(url: 'http://127.0.0.1:9', schluessel: 'x');

/// Raum mit Einstimmung: Anna (Gastgeberin) ermittelt, Cleo (`g2`) erzählt und leitet.
SchlosskellerRaum _raum({String detektiv = 'gastgeber', String? erzaehler = 'g2', Abendfassung fassung = Abendfassung.kurz}) => sitzRaum(
      detektiv: detektiv,
      erzaehler: erzaehler,
      daten: erzaehlDaten,
      fassung: fassung,
      einstimmung: erzaehlDaten.einstimmung,
      rundgang: fassung.istLang ? erzaehlDaten.vorspielMorgen : null,
      diaAnzahl: erzaehlDaten.diashow!.dias.length,
    );

Map<String, Object?> _einstimmung(SchlosskellerRaum raum, [String id = 'g1']) => (raum.zustandFuer(id)['einstimmung'] as Map).cast<String, Object?>();

/// Die Leiterin schaltet einen Schritt weiter.
void _weiter(SchlosskellerRaum raum, [String leiter = 'g2']) => raum.nachricht(leiter, {'typ': 'einstimmung', 'schritt': _einstimmung(raum)['schritt']});

/// Handyformat mit reduzierter Bewegung für das Gastgebergerät.
Future<void> _zeige(WidgetTester t, Widget kind) async {
  t.view.physicalSize = const Size(390, 844);
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.resetPhysicalSize);
  addTearDown(t.view.resetDevicePixelRatio);
  await t.pumpWidget(rahmen(MediaQuery(data: const MediaQueryData(disableAnimations: true, size: Size(390, 844)), child: kind)));
  await t.pump();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Gastgeber: einstimmung steht nur eingeschaltet in der Meta und gibt dem Raum die Einstimmung, auch nach der Wiederherstellung', () async {
    final daten = await PartyDaten.laden(rootBundle, fall: 'schlosskeller');
    expect([daten.einstimmung, daten.erzaehlerakte, daten.steckbriefe], everyElement(isNotNull), reason: 'Die App lädt den Erzählteil');
    final ablage = SpeicherAblage();
    final an = await GastgeberDienst.neu(daten: daten, akteId: 'schlosskeller', name: 'Anna', detektiv: 'w', ablage: ablage, einstimmung: true, relay: _ohneRelais);
    expect([an.meta['einstimmung'], an.raum.einstimmung != null], [true, true]);
    await an.schliessen(endgueltig: false);
    final zurueck = await GastgeberDienst.wiederherstellen(ablage: ablage, relay: _ohneRelais);
    expect(zurueck?.raum.einstimmung, isNotNull);
    await zurueck!.schliessen();
    final aus = await GastgeberDienst.neu(daten: daten, akteId: 'schlosskeller', name: 'Anna', detektiv: 'w', ablage: SpeicherAblage(), relay: _ohneRelais);
    expect([aus.meta.containsKey('einstimmung'), aus.raum.einstimmung], [false, null], reason: 'Ohne Einstimmung bleibt die Meta bytegleich');
    await aus.schliessen();
    final gewoelbe = await PartyDaten.laden(rootBundle, fall: 'gewoelbe');
    expect([gewoelbe.einstimmung, gewoelbe.erzaehlerakte, gewoelbe.steckbriefe], [null, null, null]);
    await expectLater(
      GastgeberDienst.neu(daten: gewoelbe, akteId: 'gewoelbe', name: 'Anna', detektiv: 'w', ablage: SpeicherAblage(), einstimmung: true, relay: _ohneRelais),
      throwsArgumentError,
    );
  });

  testWidgets('Gäste: Kapitel und Karte für alle, den Text nur der Vorleser; die Knöpfe hat nur, wer leitet', (t) async {
    final raum = _raum();
    spieleBisSitz(raum, 'intro', detektiv: 'gastgeber', leiter: 'g2');
    final ben = LiveGast(raum, spielerId: 'g1', daten: erzaehlDaten), cleo = LiveGast(raum, spielerId: 'g2', daten: erzaehlDaten);
    final e = erzaehlDaten.einstimmung!;
    final text = erzaehlDaten.texte.baustein(Einstimmung.teilKennung(e.teile.first));
    await zeigeImThema(t, (_) => gastSeiteLive(ben));
    expect(find.text(l.einstimmung_laeuft.toUpperCase()), findsOneWidget);
    expect(find.text(erzaehlDaten.texte.baustein(Einstimmung.titelKennung(e.teile.first))), findsOneWidget, reason: 'Kapiteltitel');
    expect(find.text(l.einstimmung_zaehler(l.einstimmung_vorgeschichte, '1', '${e.teile.length}').toUpperCase()), findsOneWidget);
    expect(find.byKey(const ValueKey('gast-einstimmung-vorlesetext')), findsNothing);
    expect(find.byKey(const ValueKey('vorleser-karte')), findsOneWidget);
    expect(find.textContaining(text.substring(0, 40)), findsNothing);
    expect(find.byKey(const ValueKey('gast-einstimmung-weiter')), findsNothing);
    expect(find.byKey(const ValueKey('gast-weiter')), findsNothing, reason: 'Kein Weiter in die Einleitung während der Einstimmung');
    expect(await ben.befehl({'typ': 'einstimmung', 'schritt': 0}), 'not_host');
    // Cleo leitet und liest.
    await zeigeImThema(t, (_) => gastSeiteLive(cleo));
    expect(find.byKey(const ValueKey('gast-einstimmung-vorlesetext')), findsOneWidget);
    expect(find.text(text), findsOneWidget);
    await t.ensureVisible(find.byKey(const ValueKey('gast-einstimmung-weiter')));
    await t.tap(find.byKey(const ValueKey('gast-einstimmung-weiter')));
    await t.pump();
    expect([cleo.befehle.last.$1, cleo.befehle.last.$2], [{'typ': 'einstimmung', 'schritt': 0}, null]);
    expect(_einstimmung(raum)['schritt'], 1);
    expect(await cleo.befehl({'typ': 'einstimmung', 'schritt': 0}), 'stale', reason: 'Ein doppelter Tipp überspringt nichts');
    await t.ensureVisible(find.byKey(const ValueKey('gast-einstimmung-ueberspringen')));
    await t.tap(find.byKey(const ValueKey('gast-einstimmung-ueberspringen')));
    await t.pump();
    expect([_einstimmung(raum)['teil'], _einstimmung(raum)['kennung']], ['vorstellung', Einstimmung.start]);
    expect(find.text(erzaehlDaten.texte.baustein(Einstimmung.vorstellungTitel)), findsOneWidget);
    await t.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Vorstellung: eigene Figur „Du bist dran“, die Karte nennt, wer spielt, nie der Vorlesetext; ohne Gerät spielt die App', (t) async {
    final raum = _raum();
    spieleBisSitz(raum, 'intro', detektiv: 'gastgeber', leiter: 'g2');
    final ben = LiveGast(raum, spielerId: 'g1', daten: erzaehlDaten), cleo = LiveGast(raum, spielerId: 'g2', daten: erzaehlDaten);
    final namen = {for (final s in spielerAusAnsicht(raum.zustandFuer('g1'))) if (s.rolle != null) s.rolle!: s.name};
    final eigene = (raum.zustandFuer('g1')['privat'] as Map)['rolle'] as String;
    raum.nachricht('g2', {'typ': 'einstimmung', 'ueberspringen': true});
    final gesehen = <String>{};
    while (raum.zustandFuer('g1')['einstimmung'] is Map) {
      final figur = _einstimmung(raum)['figur'] as String?;
      if (figur != null && figur != Besetzung.detektiv) {
        ben.geaendert();
        await zeigeImThema(t, (_) => gastSeiteLive(ben));
        final name = namen[figur];
        if (figur == eigene) {
          expect(find.text(l.einstimmung_du_bist_dran), findsOneWidget);
          expect(find.text(l.einstimmung_gespielt_von('Ben')), findsOneWidget);
        } else {
          expect(find.text(l.einstimmung_du_bist_dran), findsNothing, reason: figur);
          expect(find.text(name == null ? l.einstimmung_app_spielt(erzaehlDaten.kanon.figur(figur)!['name'] as String) : l.einstimmung_gespielt_von(name)),
              findsOneWidget, reason: figur);
        }
        expect(find.byKey(ValueKey('gast-vorstellung-$figur')), findsOneWidget);
        // Cleo liest: der Text ohne Spielernamen; „gespielt von“ steht nur auf der Karte.
        await zeigeImThema(t, (_) => gastSeiteLive(cleo));
        final blatt = find.byKey(const ValueKey('gast-einstimmung-vorlesetext'));
        expect(blatt, findsOneWidget);
        expect(find.descendant(of: blatt, matching: find.textContaining('gespielt von')), findsNothing);
        expect(find.descendant(of: blatt, matching: find.textContaining('App spielt')), findsNothing);
        gesehen.add(figur);
      }
      _weiter(raum);
    }
    expect(gesehen, raum.partieFuerGastgeber!.spiel.besetzt.toSet());
    expect(gesehen.where((f) => namen[f] == null), isNotEmpty, reason: 'Auch Figuren ohne Gerät');
    await t.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Schmal und mit doppelter Schrift ohne Überlauf', (t) async {
    final raum = _raum();
    spieleBisSitz(raum, 'intro', detektiv: 'gastgeber', leiter: 'g2');
    final ben = LiveGast(raum, spielerId: 'g1', daten: erzaehlDaten), cleo = LiveGast(raum, spielerId: 'g2', daten: erzaehlDaten);
    raum.nachricht('g2', {'typ': 'einstimmung', 'ueberspringen': true});
    _weiter(raum);
    for (final g in [ben, cleo]) {
      await zeigeImThema(t, (_) => gastSeiteLive(g), groesse: const Size(320, 640), schrift: 2);
      expect(t.takeException(), isNull, reason: g.spielerId);
    }
    await t.pumpWidget(const SizedBox.shrink());
  });

  test('Langer Abend: Das Vorspiel wartet auf die Einstimmung; erst danach steht der Rundgang in der Ansicht', () {
    final raum = _raum(fassung: Abendfassung.lang);
    spieleBisSitz(raum, 'intro', detektiv: 'gastgeber', leiter: 'g2');
    expect([raum.zustandFuer('g1')['einstimmung'] is Map, raum.zustandFuer('g1').containsKey('rundgang')], [true, false]);
    raum.nachricht('g2', {'typ': 'einstimmung', 'ueberspringen': true});
    raum.nachricht('g2', {'typ': 'einstimmung', 'ueberspringen': true});
    expect([raum.zustandFuer('g1').containsKey('einstimmung'), raum.zustandFuer('g1')['rundgang'] is Map], [false, true]);
  });

  testWidgets('Gastgebergerät als Erzähler: spiegelt die Einstimmung, liest selbst und schickt die Nachricht', (t) async {
    final raum = _raum(detektiv: 'g1', erzaehler: 'gastgeber');
    spieleBisSitz(raum, 'intro', detektiv: 'g1', leiter: 'gastgeber');
    final dienst = SitzDienst(raum, daten: erzaehlDaten);
    final s = GastgeberSitzung(dienst);
    addTearDown(s.dispose);
    final e = erzaehlDaten.einstimmung!;
    final erste = Einstimmung.teilKennung(e.teile.first);
    expect([s.mitEinstimmung, s.einstimmung?.kennung, s.einstimmungNr, s.einstimmungSteuerbar, s.istVorleser, s.kannWeiter, s.rundgang],
        [true, erste, 0, true, true, false, null]);
    expect(s.einstimmungSchritte, e.schritte(rollen: 4, detektiv: 'w'));
    expect(s.einstimmungAnzahl, s.einstimmungSchritte.length);
    await _zeige(t, PartyAblauf(sitzung: s));
    expect(find.byType(EinstimmungBildschirm), findsOneWidget);
    expect(find.text(s.text(erste)), findsOneWidget, reason: 'Anna liest');
    await t.ensureVisible(find.byKey(const ValueKey('einstimmung-weiter')));
    await t.tap(find.byKey(const ValueKey('einstimmung-weiter')));
    await t.pump();
    expect(dienst.verb.befehle.last, {'typ': 'einstimmung', 'schritt': 0});
    expect(s.einstimmungNr, 1);
    s.einstimmungUeberspringen();
    await t.pump();
    expect(dienst.verb.befehle.last, {'typ': 'einstimmung', 'ueberspringen': true});
    expect([s.einstimmung?.teil, s.einstimmung?.kennung], [EinstimmungTeil.vorstellung, Einstimmung.start]);
    s.einstimmungUeberspringen();
    await t.pump();
    await t.pump(const Duration(milliseconds: 400));
    expect([s.einstimmung, s.abschnittFertig], [null, isTrue]);
    expect(find.byType(EinstimmungBildschirm), findsNothing);
    await t.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Gastgebergerät als Detektiv: Cleo führt und liest; Anna sieht Karte und wer vorliest, ihr Knopf schickt nichts', (t) async {
    final raum = _raum();
    spieleBisSitz(raum, 'intro', detektiv: 'gastgeber', leiter: 'g2');
    final dienst = SitzDienst(raum, daten: erzaehlDaten);
    final s = GastgeberSitzung(dienst);
    addTearDown(s.dispose);
    expect([s.einstimmungSteuerbar, s.istVorleser, s.kannWeiter], [false, false, false]);
    s.einstimmungWeiter();
    expect(dienst.verb.befehle.where((b) => b['typ'] == 'einstimmung'), isEmpty);
    await _zeige(t, PartyAblauf(sitzung: s));
    expect(find.byType(EinstimmungBildschirm), findsOneWidget);
    expect(find.byKey(const ValueKey('vorleser-karte')), findsOneWidget);
    expect(find.text(s.text(s.einstimmung!.kennung)), findsNothing);
    expect(find.text(l.einstimmung_fuehrt('Cleo')), findsOneWidget);
    raum.nachricht('g2', {'typ': 'einstimmung', 'ueberspringen': true});
    _weiter(raum);
    expect(s.einstimmung!.figur, raum.partieFuerGastgeber!.spiel.besetzt.first);
    // Die Testverbindung meldet Änderungen des Raums nicht: neu aufbauen.
    await _zeige(t, PartyAblauf(sitzung: s));
    expect(find.byType(VorstellungsKarte), findsOneWidget);
    await t.pumpWidget(const SizedBox.shrink());
  });
}
