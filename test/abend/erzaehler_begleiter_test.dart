// Langer Abend M3b: der Erzähler-Begleiter. Reihum mit Erzähler am Tisch
// öffnet das Gerät auf Wunsch einen Raum nur mit dem Erzählersitz; der
// Erzähler liest am eigenen Handy (Texte, Erzählerpaket, „Weiter“), das Gerät
// zeigt dann nur „… liest vor“. Das Handy sieht nie Dossier, Tarnung,
// Spickzettel, Pfad oder Salz. Ist der Erzähler weg, liest das Gerät wieder
// über das verdeckte Pult.
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mordakte/abend/online/ansicht.dart' show inhaltsKennung;
import 'package:mordakte/abend/online/erzaehler_begleiter.dart';
import 'package:mordakte/l10n/gen/app_localizations_de.dart';
import 'package:mordakte/party/bildschirme/intro.dart';
import 'package:mordakte/party/bildschirme/runde.dart';
import 'package:mordakte/party/daten.dart';
import 'package:mordakte/party/erzaehler_begleitung.dart';
import 'package:mordakte/party/sitzung.dart';
import 'package:mordakte_core/mordakte_core.dart';
import 'package:mordakte_core/runden.dart' show PartyRaumFehler, ProtokollRaum, RundenZugPhase, Tischruf;
import 'package:mordakte_netz/io.dart' show PhoenixAttrappe;
import 'package:mordakte_netz/mordakte_netz.dart' show AbendFehler, LokaleVerbindung, RelayGast, RelayParameter, SpeicherAblage;

import '../party_widgets/hilfe.dart' show diashowDaten, partyDaten, spieleBis, spieleZug, testAbendzeit;
import 'online_hilfe.dart';

final l = LDe();

Map<String, Object?> _map(Object? wert) => (wert as Map).cast<String, Object?>();

/// Reihum, vier Rollen, Pfad ahmet, Erzählerin Mia; die Rollen haben Namen.
/// Mit [daten] etwa der Schlosskeller mit Diashow (M4).
PartySitzung _sitzung({PartyDaten? daten}) => PartySitzung(daten ?? partyDaten, salz: '00aa11bb22cc33dd')
  ..einrichten(
    rollen: 4,
    detektiv: 'w',
    code: FallCode.fuerPfad('ahmet', (daten ?? partyDaten).kanon.pfade).code,
    erzaehlerName: 'Mia',
    detektivName: 'Ada',
    namen: const {'ahmet': 'Ben', 'clara': 'Cleo'},
  );

/// Führt alle Befragungen der Runde am Gerät (feste und freie).
void _befragungenFuehren(PartySitzung s) {
  for (final k in s.befragungen) {
    if (!k.pflicht && s.befragungenFrei == 0) continue;
    if (k.erledigt) continue;
    if (k.frage == null) s.befragen(k.id, 0);
    if (!s.befragungen.firstWhere((b) => b.id == k.id).erledigt) s.befragungErledigt(k.id);
  }
}

/// Alle Texte, die das Handy des Erzählers nie sehen darf: Dossiers (Wissen,
/// Verbergen, Tatwissen) aller besetzten Rollen auf jedem Pfad.
List<String> _geheim(PartySitzung s) => [
      for (final pfad in partyDaten.kanon.pfade)
        for (final rolle in s.besetzt)
          for (final z in [...partyDaten.texte.dossier(rolle, pfad, 4).verbirgt, ...partyDaten.texte.dossier(rolle, pfad, 4).tatwissen]) z.text,
    ];

/// Ein Begleiter zum Schein: liest, wenn der Test es sagt.
class _Schein extends ChangeNotifier implements ErzaehlerBegleitung {
  bool _liest = false;
  int gezeigt = 0;

  @override
  String name = '';

  @override
  bool get liest => _liest;

  set liest(bool ja) {
    _liest = ja;
    notifyListeners();
  }

  @override
  Future<void> zeigen(BuildContext context) async => gezeigt++;

  @override
  Future<void> schliessen() async => liest = false;
}

void main() {
  test('Raum: nur ein Erzähler, Texte und Paket ohne Geheimnisse, Weiter nur wenn der Abschnitt fertig ist', () {
    final s = _sitzung();
    final raum = BegleiterRaum('ABCDEF', s);
    expect(raum.beitreten(BegleiterRaum.tisch, 'Ada'), isTrue);
    expect(raum.vorStart, isTrue);
    expect(raum.beitreten('e1', ' Mia '), isTrue);
    expect([raum.vorStart, raum.erzaehlerOnline, raum.erzaehlerName], [false, true, 'Mia']);
    expect(raum.beitreten('e2', 'Max'), isFalse, reason: 'Ein Raum, ein Erzähler');
    expect(raum.beitreten('e1', 'Mia'), isTrue, reason: 'Er kommt zurück');
    // Rollen: Jede Person liest verdeckt am Gerät; das Gerät führt weiter.
    expect(s.phase, PartyPhase.rollen);
    expect(() => raum.nachricht('e1', {'typ': 'weiter'}), throwsA(isA<PartyRaumFehler>().having((e) => e.code, 'code', 'not_ready')));
    expect(() => raum.nachricht(BegleiterRaum.tisch, {'typ': 'weiter'}), throwsA(isA<PartyRaumFehler>().having((e) => e.code, 'code', 'not_host')));
    expect(() => raum.zustandFuer('e2'), throwsA(isA<PartyRaumFehler>()));
    s.weiter();
    // Auftakt: Das Handy hat den Text, den das Gerät sonst im Pult hätte.
    var v = raum.zustandFuer('e1');
    final texte = [for (final k in s.erzaehler) if (s.hatText(k)) s.text(k)];
    expect(texte, isNotEmpty);
    expect(_map(v['privat'])['erzaehler'], texte);
    expect(_map(v['privat'])['vorleser'], isTrue);
    expect([v['phase'], v['host'], v['kannWeiter'], v['akte']], ['intro', BegleiterRaum.tisch, true, 'schlosskeller']);
    final spieler = [for (final x in v['spieler'] as List) _map(x)];
    expect(spieler.firstWhere((x) => x['id'] == 'e1')['sitz'], 'erzaehler');
    expect(spieler.firstWhere((x) => x['id'] == BegleiterRaum.tisch)['name'], 'Ada');
    expect(spieler.firstWhere((x) => x['rolle'] == 'ahmet')['name'], 'Ben');
    raum.nachricht('e1', {'typ': 'weiter'});
    expect(s.phase, PartyPhase.gespraeche);
    // Gespräche: Paket da, Weiter erst nach den Befragungen; wen der Detektiv befragt, steht öffentlich.
    v = raum.zustandFuer('e1');
    expect(_map(_map(v['privat'])['erzaehlerPaket'])['runde'], 1);
    expect(v['kannWeiter'], isFalse);
    expect(() => raum.nachricht('e1', {'typ': 'weiter'}), throwsA(isA<PartyRaumFehler>().having((e) => e.code, 'code', 'not_ready')));
    expect((v['befragungen'] as List).length, s.befragungen.where((b) => b.pflicht).length);
    _befragungenFuehren(s);
    expect(raum.zustandFuer('e1')['kannWeiter'], isTrue);
    // Verdeckt liest gerade jemand am Gerät: Das Handy wartet.
    s.zeigeVerdeckt('ahmet');
    expect(raum.zustandFuer('e1')['kannWeiter'], isFalse);
    s.verdecken();
    raum.nachricht('e1', {'typ': 'weiter'});
    expect(s.phase, PartyPhase.entscheidungen);
    expect(() => raum.nachricht('e1', {'typ': 'wahl', 'option': 'x'}), throwsA(isA<PartyRaumFehler>().having((e) => e.code, 'code', 'invalid')));
    // Nie ein Geheimnis, nie Salz oder Pfad.
    final roh = jsonEncode(raum.zustandFuer('e1'));
    for (final t in _geheim(s)) {
      expect(roh.contains(jsonEncode(t).substring(1, jsonEncode(t).length - 1)), isFalse, reason: 'Das Handy sieht nie „$t“');
    }
    expect(roh.contains('00aa11bb22cc33dd'), isFalse);
    for (final k in ['salz', 'pfad', 'dossier', 'tarnung', 'spickzettel', 'aufloesung']) {
      expect(roh.contains('"$k"'), isFalse, reason: k);
    }
    // Getrennt und gegangen: Der Sitz bleibt beim Gerät des Erzählers. Ein
    // anderes Gerät, das den Code am Tisch gesehen hat, kommt nie hinein.
    raum.verbunden('e1', false);
    expect([raum.erzaehlerOnline, raum.erzaehlerWeg], [false, false]);
    raum.verbunden('e1', true);
    raum.verlassen('e1');
    expect([raum.erzaehlerOnline, raum.vorStart, raum.erzaehlerWeg], [false, false, true]);
    expect(raum.beitreten('e3', 'Cleo'), isFalse, reason: 'Der Sitz wird nicht für Fremde frei');
    expect(raum.beitreten('e3', 'Mia'), isFalse);
    expect(raum.beitreten('e1', 'Mia'), isTrue, reason: 'Sein Gerät kommt zurück');
    expect([raum.erzaehlerOnline, raum.erzaehlerWeg, raum.erzaehlerName], [true, false, 'Mia']);
    raum.schliessen();
    expect([raum.beendet, raum.beitreten('e3', 'Mia')], [true, false]);
  });

  testWidgets('Gerät: „Am eigenen Handy lesen“ am Pult; liest der Erzähler am Handy, zeigt das Gerät keinen Text', (tester) async {
    final s = _sitzung()..weiter();
    final schein = _Schein();
    s.begleitung = schein;
    final intro = s.text(s.erzaehler.first);
    await zeigeImThema(tester, (c) => Scaffold(body: ListenableBuilder(listenable: s, builder: (_, _) => IntroBildschirm(sitzung: s))));
    expect(find.byKey(const ValueKey('erzaehlerpult-zu')), findsOneWidget);
    await tester.ensureVisible(find.byKey(const ValueKey('erzaehlerpult-handy')));
    await tester.tap(find.byKey(const ValueKey('erzaehlerpult-handy')));
    await tester.pump();
    expect(schein.gezeigt, 1);
    schein.liest = true;
    await tester.pump(const Duration(milliseconds: 400));
    expect([s.istVorleser, s.vorleserName], [false, 'Mia']);
    expect(find.byKey(const ValueKey('vorleser-karte')), findsOneWidget);
    expect(find.text(l.begleiter_handy_hinweis('Mia')), findsOneWidget);
    expect(find.text(intro), findsNothing);
    expect(find.byKey(const ValueKey('erzaehlerpult-zu')), findsNothing);
    // Das Handy ist weg: wieder das Pult.
    schein.liest = false;
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byKey(const ValueKey('erzaehlerpult-zu')), findsOneWidget);
    // Am Gerät lässt sich das Handy ablösen („Wieder am Pult lesen“).
    schein.liest = true;
    await tester.pump(const Duration(milliseconds: 400));
    await tester.ensureVisible(find.byKey(const ValueKey('begleiter-pult')));
    await tester.tap(find.byKey(const ValueKey('begleiter-pult')));
    await tester.pump(const Duration(milliseconds: 400));
    expect([schein.liest, s.istVorleser], [false, true]);
    expect(find.byKey(const ValueKey('erzaehlerpult-zu')), findsOneWidget);
    s.begleitung = null;
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Ein Gerät + Erzähler-Begleiter + Diashow (M4): Das Gerät zeigt das Bild groß mit „Nächstes Bild“, das Handy liest den Text dazu', (tester) async {
    final s = _sitzung(daten: diashowDaten)..weiter();
    expect(s.phase, PartyPhase.intro);
    final schein = _Schein()..liest = true;
    s.begleitung = schein;
    final raum = ProtokollRaum(BegleiterRaum('ABCDEF', s));
    raum.beitreten(BegleiterRaum.tisch, 'Ada');
    raum.beitreten('e1', 'Mia');
    final mia = LiveGast(raum, spielerId: 'e1', daten: diashowDaten);
    final texte = [for (final k in s.erzaehler) if (s.hatText(k)) s.text(k)];
    expect(texte, hasLength(6));
    Future<void> geraet() => zeigeImThema(tester, (c) => Scaffold(body: ListenableBuilder(listenable: s, builder: (_, _) => IntroBildschirm(sitzung: s))));

    // Das Gerät am Tisch: das Bild groß, kein Text, nur wer vorliest.
    await geraet();
    expect(find.byKey(const ValueKey('intro-diashow')), findsOneWidget);
    expect(find.byKey(const ValueKey('vorleser-karte')), findsOneWidget);
    for (final x in texte) {
      expect(find.textContaining(x.substring(0, 30)), findsNothing);
    }
    expect(find.text(l.party_intro_bild('1', '6').toUpperCase()), findsOneWidget);
    await tester.ensureVisible(find.byKey(const ValueKey('dia-naechstes')));
    await tester.tap(find.byKey(const ValueKey('dia-naechstes')));
    await tester.pump(const Duration(milliseconds: 700));
    expect(s.dia, 1);
    expect(find.text(l.party_intro_bild('2', '6').toUpperCase()), findsOneWidget);

    // Das Handy: dasselbe Bild mit dem Text dazu; der Erzähler schaltet selbst weiter.
    await zeigeImThema(tester, (c) => gastSeiteLive(mia));
    expect(find.byKey(const ValueKey('gast-dia-text-1')), findsOneWidget);
    expect(find.textContaining(texte[1].substring(0, 30)), findsOneWidget);
    expect(find.textContaining(texte[0].substring(0, 30)), findsNothing);
    await tester.ensureVisible(find.byKey(const ValueKey('gast-dia-naechstes')));
    await tester.tap(find.byKey(const ValueKey('gast-dia-naechstes')));
    await tester.pump(const Duration(milliseconds: 700));
    expect(mia.befehle.last.$1, {'typ': 'dia', 'nr': 2});
    expect(mia.befehle.last.$2, isNull);
    expect(s.dia, 2);
    expect(find.byKey(const ValueKey('gast-dia-text-2')), findsOneWidget);

    // Zurück am Gerät: Es zeigt das Bild, das der Erzähler gewählt hat.
    await geraet();
    expect(find.text(l.party_intro_bild('3', '6').toUpperCase()), findsOneWidget);
    s.begleitung = null;
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Handy stellt die Uhr (M4): Start über den Raum; Handy und Gerät zeigen dieselbe Restzeit', (tester) async {
    final s = _sitzung();
    testAbendzeit(tester, s);
    spieleBis(s, PartyPhase.gespraeche);
    final raum = ProtokollRaum(BegleiterRaum('ABCDEF', s));
    raum.beitreten(BegleiterRaum.tisch, 'Ada');
    raum.beitreten('e1', 'Mia');
    // Der Transport des Geräts stempelt mit dessen Abendzeit; das Handy kennt sie über den Versatz.
    final mia = LiveGast(raum, spielerId: 'e1')..abendzeit = s.abendzeit;
    String rest() {
      final sek = (s.uhr.rest(s.abendzeit()) / 1000).ceil();
      return '${(sek ~/ 60).toString().padLeft(2, '0')}:${(sek % 60).toString().padLeft(2, '0')}';
    }

    await zeigeImThema(tester, (c) => gastSeiteLive(mia));
    expect(find.byKey(const ValueKey('gast-rundenuhr')), findsOneWidget);
    await tester.ensureVisible(find.byTooltip(l.online_uhr_start));
    await tester.tap(find.byTooltip(l.online_uhr_start));
    await tester.pump();
    expect(mia.befehle.last.$2, isNull);
    expect(s.uhr.laeuft, isTrue);
    await tester.pump(const Duration(seconds: 61));
    expect(find.text(rest()), findsOneWidget);
    await zeigeImThema(tester, (c) => RundeBildschirm(sitzung: s));
    expect(find.text(rest()), findsOneWidget, reason: 'Das Gerät zeigt dieselbe Uhr');
    expect(await mia.befehl({'typ': 'uhr', 'aktion': 'weiter'}), 'invalid_phase', reason: 'Weiter ohne Pause passt nicht');
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Handy: die Gastseite des Erzählers liest vor, hat sein Paket und führt weiter', (tester) async {
    final s = _sitzung()..weiter();
    final raum = ProtokollRaum(BegleiterRaum('ABCDEF', s));
    raum.beitreten(BegleiterRaum.tisch, 'Ada');
    raum.beitreten('e1', 'Mia');
    final mia = LiveGast(raum, spielerId: 'e1');
    await zeigeImThema(tester, (c) => gastSeiteLive(mia));
    expect(find.textContaining(s.text(s.erzaehler.first).substring(0, 30)), findsOneWidget);
    expect(find.text(l.online_erzaehler_hinweis), findsOneWidget);
    await tester.ensureVisible(find.byKey(const ValueKey('gast-weiter')));
    await tester.tap(find.byKey(const ValueKey('gast-weiter')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(s.phase, PartyPhase.gespraeche);
    expect(mia.befehle.last.$1, {'typ': 'weiter'});
    expect(mia.befehle.last.$2, isNull);
    expect(find.byKey(const ValueKey('erzaehlerpaket')), findsOneWidget);
    // Schmal und mit doppelter Schrift ohne Überlauf, in jedem Abschnitt bis zum Finale.
    _befragungenFuehren(s);
    for (var i = 0; i < 3; i++) {
      await zeigeImThema(tester, (c) => gastSeiteLive(mia), groesse: const Size(320, 640), schrift: 2);
      expect(tester.takeException(), isNull, reason: '${s.phase}');
      if (s.kannWeiter) s.weiter();
      mia.geaendert();
    }
    await tester.pumpWidget(const SizedBox.shrink());
  });

  test('Über das Relais: Code öffnen, Erzähler tritt bei, liest, drückt Weiter; am Ende schließt der Raum', () async {
    // Echte Sockets zur lokalen Attrappe (das Testgerüst sperrt HTTP sonst).
    HttpOverrides.global = null;
    final attrappe = await PhoenixAttrappe.starten();
    addTearDown(attrappe.schliessen);
    final relay = RelayParameter(url: attrappe.url, schluessel: attrappe.schluessel);
    final s = _sitzung()..weiter();
    final b = ErzaehlerBegleiter(s, relay: relay);
    s.begleitung = b;
    await b.oeffnen();
    expect([b.offen, b.fehler, b.liest], [true, false, false]);
    final code = b.code!;
    final gast = await RelayGast.beitreten(code: code, name: 'Mia', ablage: SpeicherAblage(), relay: relay, app: 'mordakte', inhalt: await inhaltsKennung());
    Future<void> warteBis(bool Function() ok) async {
      for (var i = 0; i < 500 && !ok(); i++) {
        await Future<void>.delayed(const Duration(milliseconds: 10));
      }
      expect(ok(), isTrue);
    }

    Map<String, Object?> ansicht() => gast.letzteAnsicht ?? const {};
    await warteBis(() => b.liest);
    expect(s.istVorleser, isFalse, reason: 'Das Gerät zeigt nur noch, wer vorliest');
    await warteBis(() => ansicht()['phase'] == 'intro');
    expect(_map(ansicht()['privat'])['erzaehler'], [for (final k in s.erzaehler) if (s.hatText(k)) s.text(k)]);
    await gast.befehl({'typ': 'weiter'});
    expect(s.phase, PartyPhase.gespraeche);
    await warteBis(() => ansicht()['phase'] == 'gespraeche');
    // Das Gerät führt weiter: Das Handy folgt ohne eigene Nachricht.
    _befragungenFuehren(s);
    s.weiter();
    await warteBis(() => ansicht()['phase'] == 'entscheidungen');
    // Der Erzähler geht: Das Gerät liest wieder selbst.
    await gast.verlassen();
    await warteBis(() => !b.liest);
    expect(s.istVorleser, isTrue);
    // Sein Sitz wird nicht frei: Ein anderes Gerät, das den Code gesehen hat, kommt nicht hinein.
    expect(b.raum!.erzaehlerWeg, isTrue);
    await expectLater(
      RelayGast.beitreten(code: code, name: 'Cleo', ablage: SpeicherAblage(), relay: relay, app: 'mordakte', inhalt: await inhaltsKennung()),
      throwsA(isA<AbendFehler>()),
    );
    expect([b.liest, b.raum!.erzaehlerName], [false, 'Mia']);
    // Wer jetzt am Handy lesen soll, bekommt einen neuen Code.
    await b.oeffnen();
    expect([b.offen, b.raum!.erzaehlerWeg, b.raum!.erzaehler], [true, false, null]);
    expect(b.code, isNot(code));
    // Am Ende schließt der Raum von selbst.
    spieleBis(s, PartyPhase.ende);
    await warteBis(() => !b.offen);
    b.dispose();
    expect(s.begleitung, isNull);
  });

  testWidgets('Karte: ohne Relais „noch einmal“; offen mit Code und QR-Code; liest; alles ohne Überlauf', (tester) async {
    final s = _sitzung()..weiter();
    final ohne = ErzaehlerBegleiter(s, relay: const RelayParameter(url: 'http://127.0.0.1:9', schluessel: 'x'));
    await tester.runAsync(() => ohne.oeffnen().timeout(const Duration(seconds: 30)));
    expect([ohne.fehler, ohne.offen], [true, false]);
    await zeigeImThema(tester, (c) => Scaffold(body: BegleiterKarte(begleiter: ohne)), groesse: const Size(320, 640), schrift: 2);
    expect(find.byKey(const ValueKey('begleiter-fehler')), findsOneWidget);
    expect(find.byKey(const ValueKey('begleiter-nochmal')), findsOneWidget);
    expect(tester.takeException(), isNull);
    ohne.dispose();
    // Mit Relais: Code und QR-Code, dann „… liest jetzt am eigenen Handy“.
    late final PhoenixAttrappe attrappe;
    late final RelayParameter relay;
    await tester.runAsync(() async {
      HttpOverrides.global = null;
      attrappe = await PhoenixAttrappe.starten();
      relay = RelayParameter(url: attrappe.url, schluessel: attrappe.schluessel);
    });
    final b = ErzaehlerBegleiter(s, relay: relay);
    await tester.runAsync(b.oeffnen);
    expect(b.offen, isTrue);
    for (final (groesse, schrift) in const [(Size(320, 640), 2.0), (Size(390, 844), 1.0)]) {
      await zeigeImThema(tester, (c) => Scaffold(body: BegleiterKarte(begleiter: b)), groesse: groesse, schrift: schrift);
      expect(find.byKey(const ValueKey('begleiter-code')), findsOneWidget);
      expect(find.byKey(const ValueKey('raumcode')), findsOneWidget);
      expect(find.text(l.begleiter_anleitung('Mia')), findsOneWidget);
      expect(tester.takeException(), isNull, reason: '$groesse');
    }
    late final RelayGast gast;
    await tester.runAsync(() async {
      gast = await RelayGast.beitreten(code: b.code!, name: 'Mia', ablage: SpeicherAblage(), relay: relay, app: 'mordakte', inhalt: await inhaltsKennung());
      for (var i = 0; i < 500 && !b.liest; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 10));
      }
    });
    await tester.pump();
    expect(find.byKey(const ValueKey('begleiter-liest')), findsOneWidget);
    expect(find.text(l.begleiter_liest('Mia')), findsOneWidget);
    await tester.runAsync(() async {
      await gast.verlassen();
      await b.schliessen();
      await attrappe.schliessen();
    });
    b.dispose();
    await tester.pumpWidget(const SizedBox.shrink());
  });

  test('Der Begleiter gehört nur zu reihum mit Erzähler: Solo und ohne Erzähler kein Pult', () {
    expect(_sitzung().erzaehlerAmPult, isTrue);
    final ohne = PartySitzung(partyDaten)..einrichten(rollen: 4, detektiv: 'w');
    expect(ohne.erzaehlerAmPult, isFalse);
    final solo = PartySitzung(partyDaten)..einrichten(rollen: 4, detektiv: 'w', solo: true);
    expect(solo.erzaehlerAmPult, isFalse);
  });

  // LokaleVerbindung bleibt im Netzpaket; hier nur, dass der Tischplatz eine Ansicht hat.
  test('Tischplatz: lokale Verbindung ohne Erzähler', () {
    final s = _sitzung();
    final raum = BegleiterRaum('ABCDEF', s);
    final v = LokaleVerbindung(raum, id: BegleiterRaum.tisch, name: 'Ada');
    expect(v.letzteAnsicht?['phase'], 'rollen');
  });

  testWidgets('Das Gerät nennt, wer am Handy beigetreten ist, nicht den Namen aus der Einrichtung', (tester) async {
    final s = _sitzung()..weiter();
    final schein = _Schein()..name = 'Cleo';
    s.begleitung = schein;
    schein.liest = true;
    await zeigeImThema(tester, (c) => Scaffold(body: ListenableBuilder(listenable: s, builder: (_, _) => IntroBildschirm(sitzung: s))));
    expect(s.vorleserName, 'Cleo');
    expect(find.text(l.vorleser_liest('Cleo')), findsOneWidget);
    expect(find.text(l.begleiter_handy_hinweis('Cleo')), findsOneWidget);
    expect(find.text(l.vorleser_liest('Mia')), findsNothing, reason: 'Sonst merkt der Tisch nicht, dass Cleo liest');
    // Ohne Namen vom Handy bleibt der Name aus der Einrichtung.
    schein.name = '';
    expect(s.vorleserName, 'Mia');
    s.begleitung = null;
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Handy in den Entscheidungen: Auftakt mit Würfel, Frage, Optionen, Nachtzeit und Funde wie am Tisch, nie „abgeschlossen“', (tester) async {
    final s = _sitzung();
    spieleBis(s, PartyPhase.gespraeche);
    _befragungenFuehren(s);
    s.weiter();
    expect([s.phase, s.zug?.istAuftakt], [PartyPhase.entscheidungen, true]);
    final raum = BegleiterRaum('ABCDEF', s);
    raum.beitreten('e1', 'Mia');
    final mia = LiveGast(raum, spielerId: 'e1');
    await zeigeImThema(tester, (c) => gastSeiteLive(mia), groesse: const Size(390, 2400));
    // Der Auftakt läuft am Gerät: Das Handy zeigt den Zug und wer würfelt, würfelt aber nie selbst.
    var wurf = false;
    for (var i = 0; i < 12 && s.zug != null; i++) {
      final z = s.zug!;
      final v = raum.zustandFuer('e1');
      expect(_map(v['zug'])['phase'], z.phase.name);
      mia.geaendert();
      await tester.pump();
      expect(find.text(l.online_ermittlung_fertig), findsNothing, reason: z.phase.name);
      switch (z.phase) {
        case RundenZugPhase.aktion:
          s.aktionFertig(z.aktion);
        case RundenZugPhase.wurf:
          wurf = true;
          expect(v['wuerfelPate'], 'rolle:${s.wuerfelRolle}');
          expect(_map(_map(v['zug'])['chancen']).values.cast<int>().fold(0, (a, b) => a + b), 100);
          expect(find.text(l.online_wuerfelt(s.wuerfelPate)), findsOneWidget);
          expect(find.text(l.online_wuerfeln_knopf), findsNothing, reason: 'Gewürfelt wird am Gerät');
          s.wuerfeln();
        case RundenZugPhase.tischruf:
          s.tischruf(Tischruf.umweg);
        case RundenZugPhase.fund:
          s.fundGelesen();
      }
    }
    expect(wurf, isTrue, reason: 'Der Auftakt würfelt');
    // Die erste offene Frage: Frage, Optionen, Nachtzeit und Marken wie am Tisch.
    final e = s.laufendeEntscheidung!;
    expect(s.kannWeiter, isFalse);
    var v = raum.zustandFuer('e1');
    expect(_map(v['entscheidung'])['frage'], e.frage);
    expect([for (final o in _map(v['entscheidung'])['optionen'] as List) _map(o)['text']], [for (final o in s.optionen(e.id)) o.text]);
    expect([v['restMinuten'], v['marken'], v['kannWeiter']], [s.restMinuten, s.marken, false]);
    mia.geaendert();
    await tester.pump();
    expect(find.text(e.frage), findsWidgets);
    expect(find.text(l.online_ermittlung_fertig), findsNothing);
    expect(find.text(l.online_ermittlung_wartet), findsOneWidget);
    expect(find.text(l.online_nachtzeit(s.restMinuten)), findsOneWidget);
    // Der Detektiv wählt am Gerät: Funde und Würfe stehen danach im Notizbuch des Handys.
    s.schlageVor(e.richtig[s.spiel.pfad]!);
    s.bestaetigen();
    spieleZug(s);
    v = raum.zustandFuer('e1');
    expect(_map(v['notizbuch']), {for (final f in s.funde.entries) f.key: [for (final a in f.value) a.text]});
    expect(_map(v['notizbuch']).keys, contains(e.id));
    expect((v['wuerfe'] as List).length, s.wuerfe.length);
    // Nie ein Geheimnis, nie Salz oder Pfad.
    final roh = jsonEncode(v);
    for (final t in _geheim(s)) {
      expect(roh.contains(jsonEncode(t).substring(1, jsonEncode(t).length - 1)), isFalse, reason: 'Das Handy sieht nie „$t“');
    }
    expect(roh.contains('00aa11bb22cc33dd'), isFalse);
    for (final k in ['salz', 'pfad', 'dossier', 'tarnung', 'spickzettel', 'aufloesung', 'ziel']) {
      expect(roh.contains('"$k"'), isFalse, reason: k);
    }
    // Anklage: die Verdächtigen wie am Tisch.
    spieleBis(s, PartyPhase.anklage);
    expect(raum.zustandFuer('e1')['verdaechtige'], s.kernverdaechtige);
    mia.geaendert();
    await tester.pump();
    expect(find.text(l.online_verdaechtige_titel.toUpperCase()), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
