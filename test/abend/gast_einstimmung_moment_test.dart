// Finale Schlosskeller online: Einstimmung (A-063) und „Dein Moment“ (§3) in
// einem Raum. Der Gastgeber schaltet beides in der Meta ein; der Raum führt
// durch Vorgeschichte und Vorstellung, dann Vorspiel und Diashow, dann Runde 1
// mit dem Moment. Das Gastgebergerät auf dem Erzähler-Sitz spiegelt beides und
// sieht die Zug-Tafel; seine Erzählerakte nennt die Sterne der Schicht.
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mordakte/abend/online/gastgeber_dienst.dart';
import 'package:mordakte/abend/online/gastgeber_sitzung.dart';
import 'package:mordakte/party/daten.dart';
import 'package:mordakte_core/mordakte_core.dart';
import 'package:mordakte_core/runden.dart';
import 'package:mordakte_netz/mordakte_netz.dart' show RelayParameter, SpeicherAblage;

import 'online_hilfe.dart';

/// Kein Relais nötig: Der Raum entsteht ohne Verbindung (erst `oeffnen` verbindet).
const _ohneRelais = RelayParameter(url: 'http://127.0.0.1:9', schluessel: 'x');

Map<String, Object?> _map(Object? v) => (v as Map).cast<String, Object?>();

String _rolle(SchlosskellerRaum raum, String id) => _map(raum.zustandFuer(id)['privat'])['rolle'] as String;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late PartyDaten daten;
  setUpAll(() async => daten = await PartyDaten.laden(rootBundle, fall: 'schlosskeller'));

  test('Die App lädt beides; die Erzählerakte nimmt ihre Ziele aus den Sternen der Schicht', () {
    expect([daten.einstimmung, daten.einfluss, daten.erzaehlerakte, daten.steckbriefe, daten.vorspielMorgen, daten.diashow], everyElement(isNotNull));
    final sterne = EinflussZielQuelle(daten.einfluss!, daten.texte);
    for (final f in daten.erzaehlerakte!.figuren) {
      expect([for (final z in f.ziele) z.text], [for (final z in sterne.zieleVon(f.figur)) z.text], reason: f.figur);
      expect(f.ziele, hasLength(2), reason: f.figur);
    }
  });

  test('Gastgeber: Meta mit einstimmung und einfluss, der Raum mit beiden, auch nach der Wiederherstellung', () async {
    final ablage = SpeicherAblage();
    final an = await GastgeberDienst.neu(
      daten: daten,
      akteId: 'schlosskeller',
      name: 'Anna',
      detektiv: 'w',
      ablage: ablage,
      fassung: Abendfassung.lang,
      einstimmung: true,
      einfluss: true,
      relay: _ohneRelais,
    );
    expect([an.meta['einstimmung'], an.meta['einfluss'], an.meta['fassung']], [true, true, 'lang']);
    expect([an.raum.einstimmung != null, an.raum.einfluss != null, an.raum.fassung], [true, true, Abendfassung.lang]);
    await an.schliessen(endgueltig: false);
    final zurueck = await GastgeberDienst.wiederherstellen(ablage: ablage, relay: _ohneRelais);
    expect([zurueck?.raum.einstimmung != null, zurueck?.raum.einfluss != null], [true, true]);
    await zurueck!.schliessen();
  });

  test('Langer Abend, Gastgeber erzählt: Einstimmung, Vorspiel, Diashow, dann Runde 1 mit Moment und Zug-Tafel', () async {
    final raum = sitzRaum(
      detektiv: 'g1',
      erzaehler: 'gastgeber',
      daten: daten,
      fassung: Abendfassung.lang,
      einstimmung: daten.einstimmung,
      rundgang: daten.vorspielMorgen,
      diaAnzahl: daten.diashow!.dias.length,
      einfluss: daten.einfluss,
    );
    spieleBisSitz(raum, 'intro', detektiv: 'g1', leiter: 'gastgeber');
    final s = GastgeberSitzung(SitzDienst(raum, daten: daten));
    addTearDown(s.dispose);
    expect([s.mitEinstimmung, s.einfluss, s.einstimmungSteuerbar, s.erzaehlerakteSichtbar], [true, true, true, true]);
    expect([s.einstimmung?.teil, s.rundgang, s.kannWeiter], [EinstimmungTeil.vorgeschichte, null, false], reason: 'Das Vorspiel wartet');
    expect(s.momentOffen, isEmpty);
    // In der Einleitung zieht niemand.
    expect(() => raum.nachricht('g2', {'typ': 'zug', 'art': 'helfen'}), throwsA(isA<PartyRaumFehler>()));

    // Anna führt durch die Einstimmung; danach das Vorspiel, dann die Diashow.
    while (s.einstimmung != null) {
      s.einstimmungWeiter();
      await pumpEventQueue();
    }
    expect(s.rundgang, RundgangTeil.vorspiel);
    s.rundgangUeberspringen();
    await pumpEventQueue();
    expect([s.phase, s.rundgang, s.kannWeiter], [PartyPhase.intro, null, true]);
    s.weiter();
    await pumpEventQueue();

    // Runde 1: Ben ermittelt, Cleo und Dora ziehen am eigenen Gerät.
    expect([s.phase, s.runde], [PartyPhase.gespraeche, 1]);
    befragungenImRaum(raum, detektiv: 'g1');
    expect(_map(_map(raum.zustandFuer('g2')['privat'])['moment'])['offen'], isTrue);
    expect(s.momentOffen, unorderedEquals([_rolle(raum, 'g2'), _rolle(raum, 'g3')]));
    expect(s.kannWeiter, isFalse, reason: 'Erst ziehen alle Menschen');
    raum.nachricht('g2', {'typ': 'zug', 'art': 'helfen'});
    raum.nachricht('g3', {'typ': 'zug', 'art': 'zeigen', 'ziel': _rolle(raum, 'g2')});
    expect([for (final z in s.einflussTafel!.zuege) (z.rolle, z.art)],
        unorderedEquals([(_rolle(raum, 'g2'), ZugArt.helfen), (_rolle(raum, 'g3'), ZugArt.zeigen)]));
    expect(s.kannWeiter, isTrue);
    s.weiter();
    await pumpEventQueue();
    expect(s.phase, PartyPhase.entscheidungen);
    expect(s.einflussLage!.folgenVon(1), isNotNull);
    expect(s.erzaehler, contains('einfluss.folgen.start.1'));
    expect(s.erzaehler.where((k) => k.startsWith('vorgeschichte.') || k.startsWith('vorstellung.')), isEmpty);
    expect(s.erzaehlerakteSichtbar, isTrue, reason: 'Bis zum Finale');
  });
}
