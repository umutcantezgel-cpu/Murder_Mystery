// M7b online: Vorspiel und Morgen im langen Abend. Der Raum hält die Station;
// Gäste sehen die Karte der Station und „Das Vorspiel läuft“ bzw. „Der Morgen
// läuft“, den Vorlesetext nur der Vorleser-Sitz. Wer leitet, schaltet weiter;
// am Gastgebergerät läuft der Rundgang über die Karte wie an einem Gerät. Der
// Raum ist erst nach dem Morgen beendet, der Gastgeber legt den Abend erst
// danach endgültig ab. Der Erzähler-Begleiter (reihum) zeigt das Vorspiel am Handy.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mordakte/abend/online/erzaehler_begleiter.dart';
import 'package:mordakte/abend/online/gastgeber_sitzung.dart';
import 'package:mordakte/l10n/gen/app_localizations_de.dart';
import 'package:mordakte/party/bildschirme/rundgang.dart';
import 'package:mordakte/party/party_seite.dart';
import 'package:mordakte_core/mordakte_core.dart';
import 'package:mordakte_core/runden.dart' show PartyRaumFehler, ProtokollRaum, SchlosskellerRaum;

import '../party_widgets/hilfe.dart' show rahmen, spieleBis;
import '../party_widgets/rundgang_hilfe.dart';
import 'online_hilfe.dart';

final l = LDe();

/// Langer Abend mit Vorspiel und Morgen: Anna (Gastgeberin) ermittelt, Cleo (`g2`) erzählt und leitet.
SchlosskellerRaum _raum({String detektiv = 'gastgeber', String? erzaehler = 'g2', Abendfassung fassung = Abendfassung.lang}) =>
    sitzRaum(
      detektiv: detektiv,
      erzaehler: erzaehler,
      daten: rundgangDaten,
      fassung: fassung,
      rundgang: rundgangDaten.vorspielMorgen,
      diaAnzahl: rundgangDaten.diashow!.dias.length,
    );

/// Schickt [g] den Weiter-Befehl des Rundgangs an der laufenden Station.
Future<void> _weiter(LiveGast g) async {
  final st = (g.ansicht['rundgang'] as Map)['station'];
  expect(await g.befehl({'typ': 'rundgang', 'station': st}), isNull);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(rundgangWeltAusDateien);

  testWidgets('Gäste: Karte der Station und „Das Vorspiel läuft“; den Vorlesetext und die Knöpfe hat nur, wer leitet', (t) async {
    final raum = _raum();
    spieleBisSitz(raum, 'intro', detektiv: 'gastgeber', leiter: 'g2');
    final ben = LiveGast(raum, spielerId: 'g1', daten: rundgangDaten), cleo = LiveGast(raum, spielerId: 'g2', daten: rundgangDaten);
    final v = rundgangDaten.vorspielMorgen!.vorspiel;
    await zeigeImThema(t, (_) => gastSeiteLive(ben));
    final st = v.stationen.first;
    expect(find.text(st.text!.titel), findsOneWidget);
    expect(find.text(st.text!.punkte.first), findsOneWidget);
    expect(find.text(l.rundgang_laeuft_vorspiel.toUpperCase()), findsOneWidget);
    expect(find.byKey(const ValueKey('gast-rundgang-vorlesetext')), findsNothing);
    expect(find.byKey(const ValueKey('vorleser-karte')), findsOneWidget);
    expect(find.byKey(const ValueKey('gast-rundgang-weiter')), findsNothing);
    expect(find.byKey(const ValueKey('gast-weiter')), findsNothing, reason: 'Kein Weiter in die Einleitung während des Vorspiels');
    expect(find.textContaining(st.text!.vorlesen.substring(0, 40)), findsNothing);
    expect(await ben.befehl({'typ': 'rundgang', 'station': 0}), 'not_host');
    // Cleo leitet und liest vor.
    await zeigeImThema(t, (_) => gastSeiteLive(cleo));
    expect(find.byKey(const ValueKey('gast-rundgang-vorlesetext')), findsOneWidget);
    expect(find.textContaining(st.text!.vorlesen.substring(0, 40)), findsOneWidget);
    await t.tap(find.byKey(const ValueKey('gast-rundgang-weiter')));
    await t.pump();
    expect([cleo.befehle.last.$1, cleo.befehle.last.$2], [{'typ': 'rundgang', 'station': 0}, null]);
    expect(find.text(v.stationen[1].text!.titel), findsOneWidget);
    // Überspringen: dann die Diashow der Einleitung.
    await t.tap(find.byKey(const ValueKey('gast-rundgang-ueberspringen')));
    await t.pump();
    expect(raum.zustandFuer('g1').containsKey('rundgang'), isFalse);
    expect(find.byKey(const ValueKey('gast-diashow')), findsOneWidget);
    await t.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Gäste am Morgen: Karte zum gezogenen Ende, „Der Morgen läuft“; danach das Ende mit der Belohnung', (t) async {
    final raum = _raum();
    spieleBisSitz(raum, 'ende', detektiv: 'gastgeber', leiter: 'g2');
    expect(raum.beendet, isFalse, reason: 'Der Morgen läuft');
    final ende = (raum.zustandFuer('g1')['aufloesung'] as Map)['ende'] as String;
    final ben = LiveGast(raum, spielerId: 'g1', daten: rundgangDaten), cleo = LiveGast(raum, spielerId: 'g2', daten: rundgangDaten);
    final m = rundgangDaten.vorspielMorgen!.morgen;
    await zeigeImThema(t, (_) => gastSeiteLive(ben));
    expect(find.text(l.rundgang_laeuft_morgen.toUpperCase()), findsOneWidget);
    for (var i = 0; i < m.stationen.length; i++) {
      ben.geaendert();
      await t.pump();
      expect(find.text(m.stationen[i].textFuer(ende).titel), findsOneWidget, reason: '$i');
      expect(find.byKey(const ValueKey('gast-rundgang-vorlesetext')), findsNothing);
      await _weiter(cleo);
    }
    ben.geaendert();
    await t.pump();
    expect(raum.beendet, isTrue);
    expect(find.text(l.rundgang_laeuft_morgen.toUpperCase()), findsNothing);
    expect(find.text(l.abend_belohnung_ansehen), findsOneWidget, reason: 'Schlussbild mit der Belohnung');
    await t.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Gastgebergerät als Detektiv: Der Rundgang folgt dem Raum, Cleo führt und liest; Anna sieht die Karte und wer vorliest', (t) async {
    final raum = _raum();
    spieleBisSitz(raum, 'intro', detektiv: 'gastgeber', leiter: 'g2');
    final s = GastgeberSitzung(SitzDienst(raum, daten: rundgangDaten));
    addTearDown(s.dispose);
    expect([s.lang, s.rundgang, s.rundgangStation, s.rundgangSteuerbar, s.istVorleser, s.kannWeiter], [true, RundgangTeil.vorspiel, 0, false, false, false]);
    s.rundgangWeiter();
    await t.pump();
    expect(s.rundgangStation, 0, reason: 'Anna leitet nicht: kein Befehl');
    expect((s.dienst.verb as SitzVerbindung).befehle.where((b) => b['typ'] == 'rundgang'), isEmpty);
    t.view.physicalSize = const Size(390, 844);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.view.resetDevicePixelRatio);
    await t.pumpWidget(rahmen(MediaQuery(data: const MediaQueryData(disableAnimations: true, size: Size(390, 844)), child: PartyAblauf(sitzung: s))));
    await t.pump();
    expect(find.byType(RundgangBildschirm), findsOneWidget);
    expect(find.byKey(const ValueKey('vorleser-karte')), findsOneWidget);
    expect(find.byKey(const ValueKey('rundgang-vorlesetext')), findsNothing);
    raum.nachricht('g2', {'typ': 'rundgang', 'station': 0});
    expect(s.rundgangStation, 1);
    raum.nachricht('g2', {'typ': 'rundgang', 'ueberspringen': true});
    expect([s.rundgang, s.abschnittFertig], [null, isTrue]);
    await t.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Gastgebergerät als Erzähler: führt und liest selbst; der Knopf schickt den Rundgang in den Raum', (t) async {
    final raum = _raum(detektiv: 'g1', erzaehler: 'gastgeber');
    spieleBisSitz(raum, 'intro', detektiv: 'g1', leiter: 'gastgeber');
    final dienst = SitzDienst(raum, daten: rundgangDaten);
    final s = GastgeberSitzung(dienst);
    addTearDown(s.dispose);
    expect([s.rundgangSteuerbar, s.istVorleser], [true, true]);
    t.view.physicalSize = const Size(390, 844);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.view.resetDevicePixelRatio);
    await t.pumpWidget(rahmen(MediaQuery(data: const MediaQueryData(disableAnimations: true, size: Size(390, 844)), child: PartyAblauf(sitzung: s))));
    await t.pump();
    expect(find.byKey(const ValueKey('rundgang-vorlesetext')), findsOneWidget);
    await t.ensureVisible(find.byKey(const ValueKey('rundgang-weiter')));
    await t.tap(find.byKey(const ValueKey('rundgang-weiter')));
    await t.pump();
    await t.pump();
    expect(dienst.verb.befehle.last, {'typ': 'rundgang', 'station': 0});
    expect(s.rundgangStation, 1);
    await t.pumpWidget(const SizedBox.shrink());
  });

  test('Kurz: kein Rundgang im Raum und an keinem Gerät', () {
    final raum = _raum(fassung: Abendfassung.kurz);
    spieleBisSitz(raum, 'intro', detektiv: 'gastgeber', leiter: 'g2');
    expect(raum.zustandFuer('g1').containsKey('rundgang'), isFalse);
    expect(() => raum.nachricht('g2', {'typ': 'rundgang', 'station': 0}), throwsA(isA<PartyRaumFehler>()));
    final s = GastgeberSitzung(SitzDienst(raum, daten: rundgangDaten));
    expect([s.lang, s.rundgang, s.vorspielMorgen], [false, null, null]);
    s.dispose();
    spieleBisSitz(raum, 'ende', detektiv: 'gastgeber', leiter: 'g2');
    expect(raum.beendet, isTrue);
  });

  test('Der Gastgeber legt den Abend erst nach dem Morgen endgültig ab', () async {
    final raum = _raum();
    spieleBisSitz(raum, 'ende', detektiv: 'gastgeber', leiter: 'g2');
    final morgen = _Schliessen(raum);
    GastgeberSitzung(morgen).dispose();
    expect(morgen.endgueltig, [false], reason: 'Mitten im Morgen kommt der Gastgeber noch zurück');
    raum.nachricht('g2', {'typ': 'rundgang', 'ueberspringen': true});
    final danach = _Schliessen(raum);
    GastgeberSitzung(danach).dispose();
    expect(danach.endgueltig, [true]);
  });

  test('Erzähler-Begleiter: Das Handy des Erzählers zeigt Station und Vorlesetext des Vorspiels und schaltet weiter', () {
    final s = rundgangSitzung(solo: false, erzaehler: 'Mia');
    final raum = ProtokollRaum(BegleiterRaum('ABCDEF', s));
    raum.beitreten(BegleiterRaum.tisch, 'Ada');
    raum.beitreten('e1', 'Mia');
    spieleBis(s, PartyPhase.rollen);
    s.weiter();
    final v = raum.zustandFuer('e1');
    final st = s.rundgangAktuell!;
    expect((v['rundgang'] as Map)['karte'], st.text!.karteJson());
    expect((v['privat'] as Map)['rundgangText'], st.text!.vorlesen);
    expect(raum.zustandFuer(BegleiterRaum.tisch).containsKey('rundgang'), isFalse);
    expect(() => raum.nachricht('e1', {'typ': 'rundgang', 'station': 3}), throwsA(isA<PartyRaumFehler>()));
    raum.nachricht('e1', {'typ': 'rundgang', 'station': 0});
    expect(s.rundgangStation, 1);
    raum.nachricht('e1', {'typ': 'rundgang', 'ueberspringen': true});
    expect([s.rundgang, raum.zustandFuer('e1').containsKey('rundgang')], [null, false]);
    expect(() => raum.nachricht('e1', {'typ': 'rundgang', 'station': 0}), throwsA(isA<PartyRaumFehler>()));
    s.dispose();
  });
}

/// Gastgeberdienst, der mitschreibt, wie die Sitzung den Abend ablegt.
class _Schliessen extends SitzDienst {
  _Schliessen(super.raum) : super(daten: rundgangDaten);

  final List<bool> endgueltig = [];

  @override
  Future<void> schliessen({bool endgueltig = false}) async => this.endgueltig.add(endgueltig);
}
