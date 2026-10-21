// Langer Abend M7b online: Die Fassung reist in der Meta des Gastgebers in den
// Raum, über die Wiederherstellung und in die Sitzung des Gastgebergeräts. Lang
// läuft die Rundenuhr über Gespräche und Entscheidungen; die Gäste und der
// Erzähler-Begleiter sehen sie dort, wer leitet, stellt sie. Kurz bleibt alles
// wie bisher: kein Schlüssel `fassung`, keine Uhr in den Entscheidungen.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mordakte/abend/online/erzaehler_begleiter.dart';
import 'package:mordakte/abend/online/gastgeber_dienst.dart';
import 'package:mordakte/abend/online/gastgeber_sitzung.dart';
import 'package:mordakte/l10n/gen/app_localizations_de.dart';
import 'package:mordakte/party/daten.dart';
import 'package:mordakte/party/sitzung.dart';
import 'package:mordakte_core/mordakte_core.dart';
import 'package:mordakte_core/runden.dart' show PartyRaumFehler, ProtokollRaum, RundenUhr, SchlosskellerRaum, UhrAktion;
import 'package:mordakte_netz/mordakte_netz.dart' show RelayParameter, SpeicherAblage;

import '../party_widgets/hilfe.dart' show langDaten, partyDaten, spieleBis;
import 'online_hilfe.dart';

final l = LDe();

/// Kein Relais nötig: Der Raum entsteht ohne Verbindung (erst `oeffnen` verbindet).
const _ohneRelais = RelayParameter(url: 'http://127.0.0.1:9', schluessel: 'x');

/// Raum mit Anna (Gastgeberin, Detektivin), Cleo (`g2`) erzählt und leitet.
SchlosskellerRaum _raum(Abendfassung f) => sitzRaum(detektiv: 'gastgeber', erzaehler: 'g2', daten: langDaten, fassung: f);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Gastgeber: lang steht in der Meta und im Raum, auch nach der Wiederherstellung; kurz ohne Schlüssel', () async {
    final daten = await PartyDaten.laden(rootBundle, fall: 'schlosskeller');
    expect(daten.hat('langfassung'), isTrue, reason: 'akten.json schaltet den langen Abend frei');
    final ablage = SpeicherAblage();
    final lang = await GastgeberDienst.neu(
      daten: daten, akteId: 'schlosskeller', name: 'Anna', detektiv: 'w', ablage: ablage, minuten: 25, fassung: Abendfassung.lang, relay: _ohneRelais,
    );
    expect([lang.meta['fassung'], lang.fassung, lang.raum.fassung, lang.minuten], ['lang', Abendfassung.lang, Abendfassung.lang, 25]);
    expect(lang.raum.zustandFuer(gastgeberPlatz)['fassung'], 'lang');
    await lang.schliessen(endgueltig: false);
    final zurueck = await GastgeberDienst.wiederherstellen(ablage: ablage, relay: _ohneRelais);
    expect(zurueck, isNotNull);
    expect([zurueck!.fassung, zurueck.raum.fassung], [Abendfassung.lang, Abendfassung.lang]);
    await zurueck.schliessen();

    final kurz = await GastgeberDienst.neu(
      daten: daten, akteId: 'schlosskeller', name: 'Anna', detektiv: 'w', ablage: SpeicherAblage(), minuten: 15, relay: _ohneRelais,
    );
    expect(kurz.meta.containsKey('fassung'), isFalse, reason: 'Kurze Abende bleiben bytegleich');
    expect([kurz.fassung, kurz.raum.fassung], [Abendfassung.kurz, Abendfassung.kurz]);
    expect(kurz.raum.zustandFuer(gastgeberPlatz).containsKey('fassung'), isFalse);
    await kurz.schliessen();

    // Eine Altakte kennt keinen langen Abend.
    final gewoelbe = await PartyDaten.laden(rootBundle, fall: 'gewoelbe');
    await expectLater(
      GastgeberDienst.neu(daten: gewoelbe, akteId: 'gewoelbe', name: 'Anna', detektiv: 'w', ablage: SpeicherAblage(), fassung: Abendfassung.lang, relay: _ohneRelais),
      throwsArgumentError,
    );
  });

  test('Gastgebergerät: Die Sitzung übernimmt die Fassung des Raums; lang gehört die Uhr auch zu den Entscheidungen', () {
    for (final f in Abendfassung.values) {
      final raum = _raum(f);
      final s = GastgeberSitzung(SitzDienst(raum, daten: langDaten));
      expect([s.fassung, s.lang], [f, f.istLang]);
      spieleBisSitz(raum, 'gespraeche', detektiv: 'gastgeber', leiter: 'g2');
      raum.nachricht('g2', {'typ': 'uhr', 'aktion': 'start', 'zeit': 1000});
      spieleBisSitz(raum, 'entscheidungen', detektiv: 'gastgeber', leiter: 'g2');
      expect(s.uhrInPhase, f.istLang, reason: '$f');
      if (f.istLang) {
        expect(s.uhr.start, 1000, reason: 'Die Uhr der Gespräche läuft in den Entscheidungen weiter');
        raum.nachricht('g2', {'typ': 'uhr', 'aktion': 'pause', 'zeit': 61000});
        expect(s.uhr.pausiert, isTrue);
      } else {
        expect(raum.zustandFuer('gastgeber').containsKey('uhr'), isFalse);
        expect(() => raum.nachricht('g2', {'typ': 'uhr', 'aktion': 'pause', 'zeit': 61000}), throwsA(isA<PartyRaumFehler>()));
      }
      s.dispose();
    }
  });

  testWidgets('Gäste: lang steht die Uhr auch in den Entscheidungen, wer leitet, hält sie an; kurz nicht', (t) async {
    for (final f in Abendfassung.values) {
      final raum = _raum(f);
      spieleBisSitz(raum, 'gespraeche', detektiv: 'gastgeber', leiter: 'g2');
      raum.nachricht('g2', {'typ': 'uhr', 'aktion': 'start', 'zeit': 5000000});
      spieleBisSitz(raum, 'entscheidungen', detektiv: 'gastgeber', leiter: 'g2');
      LiveGast gast(String id) => LiveGast(raum, spielerId: id, daten: langDaten)..abendzeit = () => 5000000 + 60000;
      final cleo = gast('g2'), ben = gast('g1');
      await zeigeImThema(t, (_) => gastSeiteLive(ben));
      expect(find.byKey(const ValueKey('gast-rundenuhr')), f.istLang ? findsOneWidget : findsNothing, reason: '$f');
      if (f.istLang) {
        expect(find.text('29:00'), findsOneWidget, reason: 'Dieselbe Restzeit wie in den Gesprächen');
        expect(find.byTooltip(l.online_uhr_pause), findsNothing, reason: 'Ben leitet nicht');
        await zeigeImThema(t, (_) => gastSeiteLive(cleo));
        await t.ensureVisible(find.byTooltip(l.online_uhr_pause));
        await t.tap(find.byTooltip(l.online_uhr_pause));
        await t.pump();
        expect(cleo.befehle.last.$1, {'typ': 'uhr', 'aktion': 'pause'});
        expect(cleo.befehle.last.$2, isNull, reason: 'Der Raum nimmt sie an');
        expect(RundenUhr.ausJson(raum.zustandFuer('g1')['uhr'])!.pausiert, isTrue);
      } else {
        expect(await cleo.befehl({'typ': 'uhr', 'aktion': 'pause'}), 'invalid_phase');
      }
      await t.pumpWidget(const SizedBox.shrink());
    }
  });

  test('Erzähler-Begleiter: lang die Uhr auch in den Entscheidungen und der Schlüssel fassung; kurz wie bisher', () {
    for (final f in Abendfassung.values) {
      final s = PartySitzung(langDaten, salz: '00aa11bb22cc33dd')
        ..einrichten(
          rollen: 4, detektiv: 'w', code: FallCode.fuerPfad('ahmet', langDaten.kanon.pfade).code, erzaehlerName: 'Mia', fassung: f,
        );
      final raum = ProtokollRaum(BegleiterRaum('ABCDEF', s));
      raum.beitreten(BegleiterRaum.tisch, 'Ada');
      raum.beitreten('e1', 'Mia');
      expect(raum.zustandFuer('e1').containsKey('fassung'), f.istLang, reason: '$f');
      spieleBis(s, PartyPhase.gespraeche);
      raum.nachricht('e1', {'typ': 'uhr', 'aktion': 'start', 'zeit': 1000});
      spieleBis(s, PartyPhase.entscheidungen);
      expect(raum.zustandFuer('e1').containsKey('uhr'), f.istLang, reason: '$f');
      if (f.istLang) {
        raum.nachricht('e1', {'typ': 'uhr', 'aktion': 'pause', 'zeit': 2000});
        expect(s.uhr.pausiert, isTrue);
        expect(RundenUhr.ausJson(raum.zustandFuer('e1')['uhr'])!.pausiert, isTrue);
      } else {
        expect(() => raum.nachricht('e1', {'typ': 'uhr', 'aktion': 'pause', 'zeit': 2000}), throwsA(isA<PartyRaumFehler>()));
      }
      expect(s.uhrAktion(UhrAktion.plus, minuten: 5), isTrue, reason: 'Am Gerät selbst wie bisher');
      s.dispose();
    }
  });

  test('Ohne Akteneintrag (Testdaten des Grundabends) bleibt der Raum der Sitzung kurz', () {
    final raum = sitzRaum(detektiv: 'gastgeber', erzaehler: 'g2', fassung: Abendfassung.lang);
    expect(() => GastgeberSitzung(SitzDienst(raum, daten: partyDaten)), throwsArgumentError,
        reason: 'Die Sitzung nimmt den langen Abend nur in Akten mit Langfassung an');
  });
}
