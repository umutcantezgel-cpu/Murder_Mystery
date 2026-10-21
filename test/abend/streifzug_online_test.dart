// M7b Streifzug online: Der Gastgeber auf dem Detektiv-Sitz geht wie am Tisch
// auf Streifzug und meldet Erkundung und Treffen dem Raum; der Gast-Detektiv
// sieht dieselbe Ansicht auf seinem Gerät. Wer getroffen wird, liest „Der
// Detektiv trifft dich am Brunnen“, alle anderen, wen er trifft. Der Erzähler
// sieht den Streifzug nur lesend. Kurz bleibt alles wie bisher.
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mordakte/abend/online/erzaehler_ablauf.dart';
import 'package:mordakte/abend/online/gast_ermittlung.dart';
import 'package:mordakte/abend/online/gast_streifzug.dart';
import 'package:mordakte/abend/online/gastgeber_sitzung.dart';
import 'package:mordakte/l10n/gen/app_localizations_de.dart';
import 'package:mordakte/party/bildschirme/befragung.dart';
import 'package:mordakte/party/bildschirme/streifzug.dart';
import 'package:mordakte/party/party_seite.dart';
import 'package:mordakte/party/streifzug_karte.dart';
import 'package:mordakte_core/mordakte_core.dart';
import 'package:mordakte_core/runden.dart' show SchlosskellerRaum;

import '../party_widgets/hilfe.dart' show langDaten;
import 'online_hilfe.dart';

final l = LDe();

Map<String, Object?> _json(String p) => jsonDecode(File(p).readAsStringSync()) as Map<String, Object?>;

final Erkundung _erkundung = Erkundung.ausJson(_json('content/welt/schlosskeller/erkundung.json'));

StreifzugWelt? _welt;

/// Welt des Streifzugs aus den Repo-Dateien (wie in der App aus den Assets).
StreifzugWelt get _streifzugWelt => _welt ??= () {
      final kanon = langDaten.kanon;
      final welt = WeltEbenen.ausJson(_json('content/welt/schlosskeller/langfassung.json'), kanon);
      final szenarien = partyEbenenSzenarien(kanon, _json('content/scenarios/ravensmoor.json').cast<String, dynamic>(), welt,
          id: langDaten.szenario.id, welt: _json('content/welt/schlosskeller/welt.json'));
      return StreifzugWelt(welt, szenarien, _erkundung);
    }();

/// Langer Abend mit Streifzug: Detektiv [detektiv], Erzähler [erzaehler].
SchlosskellerRaum _raum({String detektiv = 'gastgeber', String? erzaehler = 'g2', Abendfassung fassung = Abendfassung.lang}) =>
    sitzRaum(detektiv: detektiv, erzaehler: erzaehler, daten: langDaten, fassung: fassung, erkundung: _erkundung);

Map<String, Object?> _map(Object? v) => (v as Map).cast<String, Object?>();
List<Map<String, Object?>> _befragungen(SchlosskellerRaum r, String detektiv) =>
    [for (final b in _map(r.zustandFuer(detektiv)['privat'])['befragungen'] as List) _map(b)];

/// Gerät, das die Figur [rolle] spielt.
String _geraetMit(SchlosskellerRaum r, String rolle) =>
    [for (final s in r.zustandFuer('gastgeber')['spieler'] as List) if (_map(s)['rolle'] == rolle) _map(s)['id'] as String].single;

void main() {
  setUp(() => StreifzugWelt.vorgabe = _streifzugWelt);
  tearDown(() => StreifzugWelt.vorgabe = null);

  test('Gastgeber-Detektiv: Treffpunkte wie im Raum, Erkundung und Treffen gehen als Nachrichten hinaus', () {
    final raum = _raum();
    final dienst = SitzDienst(raum, daten: langDaten);
    final s = GastgeberSitzung(dienst);
    spieleBisSitz(raum, 'gespraeche', detektiv: 'gastgeber', leiter: 'g2');
    expect(bildschirm(s), isA<StreifzugBildschirm>());
    final soll = _erkundung.treffpunkteFuer(weltSamenAus('salz-test'), [for (final k in s.befragungen) k.id]);
    expect(s.streifzugTreffpunkte(_erkundung), {for (final e in soll.entries) e.key: e.value.id});
    expect(s.weltSamen, weltSamenAus('salz-test'), reason: 'Gerät und Raum ziehen aus demselben Samen');
    s.erkunden('ek_brunnen');
    expect(dienst.verb.befehle.last, {'typ': 'erkunde', 'ort': 'ek_brunnen'});
    expect(s.erkundet, contains('ek_brunnen'));
    expect(_map(raum.zustandFuer('g1')['streifzug'])['erkundet'], ['ek_brunnen']);
    s.erkunden('ek_brunnen');
    expect(dienst.verb.befehle.where((b) => b['typ'] == 'erkunde'), hasLength(1), reason: 'jeder Ort einmal');
    final b = s.befragungen.first;
    s.streifzugTreffen(b.id);
    expect(dienst.verb.befehle.last, {'typ': 'treffen', 'befragung': b.id});
    expect(_map(_map(raum.zustandFuer('g3')['streifzug'])['treffpunkt'])['figur'], b.rolle);
    expect(s.erkundungFrei, isTrue, reason: 'online ohne Deckel');
    s.dispose();
  });

  testWidgets('Gäste: wer getroffen wird, liest es mit dem Treffpunkt; die anderen sehen, wen der Detektiv trifft', (t) async {
    final raum = _raum();
    spieleBisSitz(raum, 'gespraeche', detektiv: 'gastgeber', leiter: 'g2');
    final b = _befragungen(raum, 'gastgeber').firstWhere((b) => b['mensch'] == true);
    final rolle = b['rolle'] as String;
    final getroffen = _geraetMit(raum, rolle);
    final anzeige = _erkundung.treffpunkt(_erkundung.treffpunkteFuer(weltSamenAus('salz-test'), [for (final x in _befragungen(raum, 'gastgeber')) x['id'] as String])[b['id']]!.id)!.anzeige;
    // Vor dem Treffen: Der Streifzug läuft, niemand ist gemeint.
    final gast = LiveGast(raum, spielerId: getroffen, daten: langDaten);
    await zeigeImThema(t, (_) => gastSeiteLive(gast));
    expect(find.byKey(const ValueKey('gast-streifzug')), findsOneWidget);
    expect(find.text(l.streifzug_laeuft_titel), findsOneWidget);
    expect(find.byKey(const ValueKey('gast-streifzug-mich')), findsNothing);
    raum.nachricht('gastgeber', {'typ': 'treffen', 'befragung': b['id']});
    gast.geaendert();
    await t.pump();
    expect(find.text(l.streifzug_trifft_dich(anzeige)), findsOneWidget);
    expect(find.byKey(const ValueKey('gast-streifzug-mich')), findsOneWidget);
    // Ein anderer Gast sieht, wen der Detektiv trifft.
    final anderer = [for (final id in ['g1', 'g3']) if (id != getroffen) id].first;
    final ander = LiveGast(raum, spielerId: anderer, daten: langDaten);
    await zeigeImThema(t, (_) => gastSeiteLive(ander));
    expect(find.byKey(const ValueKey('gast-streifzug-treffen')), findsOneWidget);
    expect(find.byKey(const ValueKey('gast-streifzug-mich')), findsNothing);
    await t.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Gast-Detektiv: dieselbe Streifzug-Ansicht; Ankunft am Treffpunkt öffnet die Befragung, alles geht an den Raum', (t) async {
    final raum = _raum(detektiv: 'g1', erzaehler: 'gastgeber');
    spieleBisSitz(raum, 'gespraeche', detektiv: 'g1', leiter: 'gastgeber');
    final ben = LiveGast(raum, spielerId: 'g1', daten: langDaten);
    await zeigeImThema(t, (_) => gastSeiteLive(ben), ruhig: true);
    expect(find.byType(StreifzugAnsicht), findsOneWidget);
    final b = _befragungen(raum, 'g1').firstWhere((b) => b['pflicht'] == true);
    final karte = find.byKey(ValueKey('streifzug-treff:${b['id']}'));
    expect(karte, findsOneWidget);
    await t.ensureVisible(karte);
    await t.tap(karte);
    await t.pump();
    expect(ben.befehle.map((x) => x.$1), anyElement(equals({'typ': 'treffen', 'befragung': b['id']})));
    expect(ben.befehle.where((x) => x.$2 != null), isEmpty, reason: 'Der Raum nimmt alles an');
    for (var i = 0; i < 40 && find.byType(BefragungsKarte).evaluate().isEmpty; i++) {
      await t.pump(const Duration(milliseconds: 100));
    }
    expect(find.byType(BefragungsKarte), findsOneWidget);
    final frage = (b['fragen'] as List).first as String;
    await t.ensureVisible(find.text(frage));
    await t.tap(find.text(frage));
    await t.pump();
    expect(ben.befehle.last.$1, {'typ': 'befragen', 'id': b['id'], 'frage': 0});
    // Erkundung über die Steuerung wie das Skript: Meldung an den Raum.
    final steuerung = t.widget<StreifzugAnsicht>(find.byType(StreifzugAnsicht)).abend.steuerung;
    expect(t.widget<StreifzugAnsicht>(find.byType(StreifzugAnsicht)).abend, isA<GastStreifzug>());
    steuerung.schliessen();
    await t.pump();
    expect(steuerung.gehe('erkunde:ek_brunnen'), isTrue);
    for (var i = 0; i < 40 && !ben.befehle.any((x) => x.$1['typ'] == 'erkunde'); i++) {
      await t.pump(const Duration(milliseconds: 100));
    }
    expect(ben.befehle.map((x) => x.$1), anyElement(equals({'typ': 'erkunde', 'ort': 'ek_brunnen'})));
    expect(_map(raum.zustandFuer('g3')['streifzug'])['erkundet'], ['ek_brunnen']);

    // Entscheidungen: erst zurück in den Keller, dann die unveränderte Ermittlung des Gastes.
    spieleBisSitz(raum, 'entscheidungen', detektiv: 'g1', leiter: 'gastgeber');
    ben.geaendert();
    await t.pump();
    expect(find.byType(GastErmittlung), findsNothing);
    final zur = find.byKey(const ValueKey('streifzug-zur-entscheidung'));
    await t.ensureVisible(zur);
    await t.tap(zur);
    for (var i = 0; i < 40 && find.byType(GastErmittlung).evaluate().isEmpty; i++) {
      await t.pump(const Duration(milliseconds: 100));
    }
    expect(find.byType(GastErmittlung), findsOneWidget);
    await t.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Kurz: der Gast-Detektiv hat seine Befragungsliste wie bisher, die Gäste keinen Streifzug', (t) async {
    final raum = _raum(detektiv: 'g1', erzaehler: 'gastgeber', fassung: Abendfassung.kurz);
    spieleBisSitz(raum, 'gespraeche', detektiv: 'g1', leiter: 'gastgeber');
    expect(raum.zustandFuer('g3').containsKey('streifzug'), isFalse);
    await zeigeImThema(t, (_) => gastSeiteLive(LiveGast(raum, spielerId: 'g1', daten: langDaten)));
    expect(find.byType(StreifzugAnsicht), findsNothing);
    expect(find.byType(BefragungsListe), findsOneWidget);
    await zeigeImThema(t, (_) => gastSeiteLive(LiveGast(raum, spielerId: 'g3', daten: langDaten)));
    expect(find.byKey(const ValueKey('gast-streifzug')), findsNothing);
    await t.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Erzähler-Gastgeber: sieht den Streifzug des Gast-Detektivs nur lesend, mit Stelle und Treffen', (t) async {
    final raum = _raum(detektiv: 'g1', erzaehler: 'gastgeber');
    final s = GastgeberSitzung(SitzDienst(raum, daten: langDaten));
    spieleBisSitz(raum, 'gespraeche', detektiv: 'g1', leiter: 'gastgeber');
    raum.nachricht('g1', {'typ': 'erkunde', 'ort': 'ek_ausblick'});
    await zeigeImThema(t, (_) => ErzaehlerPultOnline(sitzung: s), ruhig: true);
    expect(find.byKey(const ValueKey('streifzug-zuschauer')), findsOneWidget);
    expect(find.text(l.streifzug_ist(_erkundung.ort('ek_ausblick')!.titel)), findsOneWidget);
    final b = _befragungen(raum, 'g1').first;
    raum.nachricht('g1', {'typ': 'treffen', 'befragung': b['id']});
    s.notifyListeners();
    await t.pump();
    expect(find.byKey(const ValueKey('streifzug-zuschauer-satz')), findsOneWidget);
    final tp = _map(_map(raum.zustandFuer('gastgeber')['streifzug'])['treffpunkt']);
    expect(find.text(l.streifzug_trifft(s.personAmTisch(b['rolle'] as String), tp['anzeige'] as String)), findsOneWidget);
    await t.pumpWidget(const SizedBox.shrink());
    s.dispose();
  });
}
