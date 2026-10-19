// Langer Abend M3b: der Gast auf dem Detektiv-Sitz ermittelt am eigenen Handy
// (Host = Erzähler + Gast = Detektiv). Detektivkarte in der Rollenphase,
// Befragungen mit den Karten aus M2, eine Option mit Ziel auf der Karte
// wählen, „Das ist endgültig“, der Weg läuft sichtbar und meldet sein Ende,
// Fund lesen, Anklage. Bleibt die Meldung des Gast-Geräts aus, meldet der
// Gastgeber nach einer festen Frist.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mordakte/abend/online/gast_ansicht.dart' show DossierAnsicht, GastKontext, GastWuerfel, baueGastSeite;
import 'package:mordakte/abend/online/gast_ermittlung.dart';
import 'package:mordakte/abend/online/gastgeber_sitzung.dart';
import 'package:mordakte/party/bildschirme/befragung.dart' show BefragungsListe;
import 'package:mordakte/party/bildschirme/detektiv_karte.dart' show DetektivKarteEintrag;
import 'package:mordakte/l10n/gen/app_localizations_de.dart';
import 'package:mordakte/stil/stil.dart' show MHaken;
import 'package:mordakte_core/runden.dart';

import 'online_hilfe.dart';

final l = LDe();

Map<String, Object?> _map(Object? wert) => (wert as Map).cast<String, Object?>();
List<Map<String, Object?>> _liste(Object? wert) => [for (final v in wert as List) _map(v)];

Future<void> _tippe(WidgetTester tester, Finder f) async {
  await tester.ensureVisible(f);
  await tester.pump();
  await tester.tap(f);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 200));
}

/// Der Zug, den Ben gerade sieht (`null` ohne Zug).
Map<String, Object?>? _zug(SchlosskellerRaum raum) => raum.zustandFuer('g1')['zug'] is Map ? _map(raum.zustandFuer('g1')['zug']) : null;

/// Ein Gast-Gerät mit Netz dazwischen: Befehle warten, bis der Test sie
/// freigibt, und die Ansicht bleibt, bis eine neue kommt ([neueAnsicht]).
class _LangsamerGast extends LiveGast {
  _LangsamerGast(super.raum, {required super.spielerId});

  Map<String, Object?>? _stand;
  final List<Completer<void>> offen = [];

  @override
  Map<String, Object?> get ansicht => _stand ??= raum.zustandFuer(spielerId);

  @override
  Future<String?> befehl(Map<String, Object?> c) async {
    final k = Completer<void>();
    offen.add(k);
    await k.future;
    return super.befehl(c);
  }

  void neueAnsicht() {
    _stand = null;
    notifyListeners();
  }
}

void main() {
  testWidgets('Gast-Detektiv: Detektivkarte, Befragung, Option mit Ziel, Weg, Fund und Anklage', (tester) async {
    final raum = sitzRaum(detektiv: 'g1', erzaehler: 'gastgeber');
    final ben = LiveGast(raum, spielerId: 'g1');
    await zeigeImThema(tester, (c) => gastSeiteLive(ben), groesse: const Size(390, 2400), ruhig: true);
    // Rollen: die Detektivkarte (M6.4), kein Dossier.
    expect(find.byType(DetektivKarteEintrag), findsOneWidget);
    expect(find.byType(DossierAnsicht), findsNothing);
    spieleBisSitz(raum, 'gespraeche', detektiv: 'g1', leiter: 'gastgeber');
    ben.geaendert();
    await tester.pump();
    expect(find.byType(BefragungsListe), findsOneWidget);
    // Die erste feste Befragung: Frage stellen; spielt ein Mensch die Rolle, ist sie danach zu beantworten.
    final karte = _liste(_map(raum.zustandFuer('g1')['privat'])['befragungen']).firstWhere((k) => k['pflicht'] == true);
    await _tippe(tester, find.text((karte['fragen'] as List).first as String).first);
    final nachher = _liste(_map(raum.zustandFuer('g1')['privat'])['befragungen']).firstWhere((k) => k['id'] == karte['id']);
    expect(nachher['frage'], 0);
    if (nachher['mensch'] == true) {
      await _tippe(tester, find.bySemanticsIdentifier('befragung-beantwortet-${karte['id']}'));
      expect(_liste(_map(raum.zustandFuer('g1')['privat'])['befragungen']).firstWhere((k) => k['id'] == karte['id'])['erledigt'], isTrue);
    }
    // Entscheidungen: Karte, Option wählen, endgültig.
    spieleBisSitz(raum, 'entscheidungen', detektiv: 'g1', leiter: 'gastgeber', ersteEntscheidung: true);
    ben.geaendert();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byKey(const ValueKey('gast-karte')), findsOneWidget);
    final e = _map(raum.zustandFuer('g1')['entscheidung']);
    final option = _liste(e['optionen']).first;
    await _tippe(tester, find.byKey(ValueKey('option-${option['id']}')));
    await _tippe(tester, find.byKey(const ValueKey('option-bestaetigen')));
    expect(_zug(raum)?['option'], option['id']);
    expect(ben.befehle.any((b) => b.$1['typ'] == 'wahl' && b.$1['option'] == option['id'] && b.$2 == null), isTrue);
    // Der Weg läuft auf Bens Karte (abgekürzt bei „Bewegung reduzieren“) und meldet sein Ende.
    for (var i = 0; i < 80 && _zug(raum)?['phase'] == 'aktion'; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(ben.befehle.any((b) => b.$1['typ'] == 'aktionFertig'), isTrue);
    expect(_zug(raum)?['phase'], isNot('aktion'));
    // Wurf (der Würfelpate würfelt), dann Tischruf oder Fund.
    for (var i = 0; i < 10 && _zug(raum) != null && _zug(raum)!['phase'] != 'fund'; i++) {
      final z = _zug(raum)!;
      if (z['phase'] == 'wurf') {
        raum.nachricht(raum.zustandFuer('g1')['wuerfelPate'] as String, {'typ': 'wurf'});
      } else if (z['phase'] == 'tischruf') {
        ben.geaendert();
        await tester.pump();
        await _tippe(tester, find.byKey(const ValueKey('ruf-umweg')));
        for (var j = 0; j < 80 && _zug(raum)?['phase'] == 'aktion'; j++) {
          await tester.pump(const Duration(milliseconds: 100));
        }
      }
      ben.geaendert();
      await tester.pump();
    }
    expect(_zug(raum)?['phase'], 'fund');
    await _tippe(tester, find.byKey(const ValueKey('fund-gelesen')));
    expect(_zug(raum), isNull, reason: 'Fund gelesen');
    // Anklage: Ahmet markieren, endgültig anklagen.
    spieleBisSitz(raum, 'anklage', detektiv: 'g1', leiter: 'gastgeber');
    ben.geaendert();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(GastAnklage), findsOneWidget);
    await _tippe(tester, find.byKey(const ValueKey('verdaechtig-ahmet')));
    await _tippe(tester, find.byKey(const ValueKey('anklagen')));
    expect(raum.partieFuerGastgeber!.spiel.angeklagt, 'ahmet');
    expect(raum.zustandFuer('g1')['kannWeiter'], isTrue, reason: 'Weiter führt der Erzähler-Gastgeber');
    expect(find.byKey(const ValueKey('gast-weiter')), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Eine Frage gilt sofort als gestellt, bis die Ansicht des Raums sie trägt (kein zweiter Tipp)', (tester) async {
    final raum = sitzRaum(detektiv: 'g1', erzaehler: 'gastgeber');
    spieleBisSitz(raum, 'gespraeche', detektiv: 'g1', leiter: 'gastgeber');
    final ben = _LangsamerGast(raum, spielerId: 'g1');
    await zeigeImThema(tester, (c) => gastSeiteLive(ben), groesse: const Size(390, 2400), ruhig: true);
    final karte = _liste(_map(raum.zustandFuer('g1')['privat'])['befragungen']).firstWhere((k) => k['pflicht'] == true);
    final frage = find.bySemanticsIdentifier('befragung-frage-${karte['id']}-0');
    expect(frage, findsOneWidget);
    await _tippe(tester, frage);
    expect(ben.offen, hasLength(1), reason: 'Der Befehl ist unterwegs');
    expect(frage, findsNothing, reason: 'Die Karte zeigt die Frage schon als gestellt');
    // Der Raum bestätigt; bis die neue Ansicht kommt, bleibt die Frage gestellt.
    ben.offen.single.complete();
    await tester.pump();
    expect(frage, findsNothing);
    ben.neueAnsicht();
    await tester.pump();
    expect(frage, findsNothing);
    expect(_liste(_map(raum.zustandFuer('g1')['privat'])['befragungen']).firstWhere((k) => k['id'] == karte['id'])['frage'], 0);
    expect(ben.befehle.where((b) => b.$1['typ'] == 'befragen'), hasLength(1), reason: 'Nichts doppelt');
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Würfelt der Gast-Detektiv selbst, steht die Würfelbühne auf seiner Seite', (tester) async {
    final raum = sitzRaum(detektiv: 'g1', erzaehler: 'gastgeber');
    spieleBisSitz(raum, 'entscheidungen', detektiv: 'g1', leiter: 'gastgeber');
    // Der Auftakt: aktionFertig, dann würfelt der Pate.
    final ben = LiveGast(raum, spielerId: 'g1');
    raum.nachricht('g1', {'typ': 'aktionFertig', 'aktion': _zug(raum)!['aktion']});
    await zeigeImThema(tester, (c) => gastSeiteLive(ben), ruhig: true);
    expect(_zug(raum)?['phase'], 'wurf');
    expect(find.byType(GastWuerfel), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  test('Ersatzmeldung: Schweigt das Gerät des Gast-Detektivs, meldet der Gastgeber das Ende des Wegs', () async {
    final frist = GastgeberSitzung.aktionsFrist;
    GastgeberSitzung.aktionsFrist = const Duration(milliseconds: 40);
    addTearDown(() => GastgeberSitzung.aktionsFrist = frist);
    final raum = sitzRaum(detektiv: 'g1', erzaehler: 'gastgeber');
    spieleBisSitz(raum, 'entscheidungen', detektiv: 'g1', leiter: 'gastgeber', ersteEntscheidung: true);
    final s = GastgeberSitzung(SitzDienst(raum));
    final e = _map(raum.zustandFuer('g1')['entscheidung']);
    raum.nachricht('g1', {'typ': 'wahl', 'option': _liste(e['optionen']).first['id']});
    s.dienst.verb.aktualisiere();
    await Future<void>.delayed(const Duration(milliseconds: 5));
    expect(_zug(raum)?['phase'], 'aktion');
    await Future<void>.delayed(const Duration(milliseconds: 120));
    expect(_zug(raum)?['phase'], isNot('aktion'), reason: 'Der Gastgeber hat gemeldet');
    expect((s.dienst.verb as SitzVerbindung).befehle.where((b) => b['typ'] == 'aktionFertig'), hasLength(1));
    expect(s.letzterFehler, isNull, reason: 'Still, auch wenn der Detektiv schneller war');
    s.dispose();
  });

  testWidgets('Detektiv-Seiten ohne Überlauf bei 320 px und doppelter Schrift', (tester) async {
    final raum = sitzRaum(detektiv: 'g1', erzaehler: 'gastgeber');
    final ben = LiveGast(raum, spielerId: 'g1');
    for (final phase in ['rollen', 'gespraeche', 'entscheidungen', 'anklage']) {
      spieleBisSitz(raum, phase, detektiv: 'g1', leiter: 'gastgeber', ersteEntscheidung: phase == 'entscheidungen');
      await zeigeImThema(tester, (c) => gastSeiteLive(ben), groesse: const Size(320, 640), schrift: 2, ruhig: true);
      if (phase == 'entscheidungen') {
        final e = _map(raum.zustandFuer('g1')['entscheidung']);
        await _tippe(tester, find.byKey(ValueKey('option-${_liste(e['optionen']).first['id']}')));
      }
      expect(tester.takeException(), isNull, reason: phase);
    }
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Notizbuch: Die Antworten der App-Rollen bleiben nach den Gesprächen auf dem Gerät des Gast-Detektivs', (tester) async {
    final raum = sitzRaum(detektiv: 'g1', erzaehler: 'gastgeber');
    spieleBisSitz(raum, 'gespraeche', detektiv: 'g1', leiter: 'gastgeber');
    final ben = LiveGast(raum, spielerId: 'g1');
    await zeigeImThema(tester, (c) => gastSeiteLive(ben), groesse: const Size(390, 4000), ruhig: true);
    // Eine Rolle, die die App spricht: Die Antwort steht nach der Frage auf ihrer Karte, nur einmal.
    final app = _liste(_map(raum.zustandFuer('g1')['privat'])['befragungen']).firstWhere((k) => k['mensch'] != true);
    await ben.befehl({'typ': 'befragen', 'id': app['id'], 'frage': 0});
    await tester.pump();
    final karte = _liste(_map(raum.zustandFuer('g1')['privat'])['befragungen']).firstWhere((k) => k['id'] == app['id']);
    final antwort = [for (final z in karte['antwort'] as List) ...(z as List).cast<String>()];
    expect(antwort, isNotEmpty);
    for (final a in antwort) {
      expect(find.text(a), findsOneWidget, reason: 'In den Gesprächen steht „$a“ auf der Karte, nicht doppelt im Notizbuch');
    }
    // Der Erzähler führt weiter: Die Ansicht der Entscheidungen trägt keine Befragungen mehr.
    spieleBisSitz(raum, 'entscheidungen', detektiv: 'g1', leiter: 'gastgeber', ersteEntscheidung: true);
    ben.geaendert();
    await tester.pump(const Duration(milliseconds: 300));
    expect(_map(raum.zustandFuer('g1')['privat']).containsKey('befragungen'), isFalse);
    expect(find.text(l.detektiv_gast_notizen.toUpperCase()), findsOneWidget);
    for (final a in antwort) {
      expect(find.text(a), findsOneWidget, reason: 'Bens Notizbuch behält „$a“');
    }
    // In den Gesprächen der nächsten Runde steht sie weiter im Notizbuch.
    spieleBisSitz(raum, 'gespraeche', detektiv: 'g1', leiter: 'gastgeber');
    ben.geaendert();
    await tester.pump(const Duration(milliseconds: 300));
    expect(raum.zustandFuer('g1')['runde'], 2);
    for (final a in antwort) {
      expect(find.text(a), findsOneWidget, reason: 'Runde 2: „$a“ aus Runde 1');
    }
    // Nach dem Neuladen (dasselbe Gerät, dieselbe Ablage) kommt das Notizbuch aus der Ablage zurück.
    await tester.pumpWidget(const SizedBox.shrink());
    final neu = LiveGast(raum, spielerId: 'g1', ablage: ben.ablage);
    await zeigeImThema(tester, (c) => gastSeiteLive(neu), groesse: const Size(390, 4000), ruhig: true);
    await tester.pump(const Duration(milliseconds: 100));
    for (final a in antwort) {
      expect(find.text(a), findsOneWidget, reason: 'Nach dem Neuladen: „$a“');
    }
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Tischruf: Eine Karte löst ihren eigenen Ruf aus; die Rufe ohne Karte kosten, nie still mit verworfener Karte', (tester) async {
    final raum = sitzRaum(detektiv: 'g1', erzaehler: 'gastgeber');
    spieleBisSitz(raum, 'entscheidungen', detektiv: 'g1', leiter: 'gastgeber', ersteEntscheidung: true);
    final e = _map(raum.zustandFuer('g1')['entscheidung']);
    // Pech beim Wurf, im Vorrat eine Nochmal- und eine Umweg-Karte.
    final ansicht = {
      ...raum.zustandFuer('g1'),
      'zug': {
        'id': e['id'], 'option': _liste(e['optionen']).first['id'], 'suche': true, 'phase': 'tischruf', 'aktion': 1,
        'wurf': {'a': 1, 'b': 1, 'mod': 0, 'stufe': 'pech'}, 'funde': const <String>[],
      },
      'vorrat': [
        {'id': 'k-nochmal', 'art': KartenArt.nochmal.name, 'rest': 1},
        {'id': 'k-umweg', 'art': KartenArt.umweg.name, 'rest': 1},
      ],
    };
    final gesendet = <Map<String, Object?>>[];
    await zeigeImThema(
      tester,
      (c) {
        final inhalt = baueGastSeite(GastKontext(context: c, dienst: TestGast(ansicht), befehl: (m) async => gesendet.add(m), belohnung: null));
        return Scaffold(body: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: inhalt.kinder)));
      },
      groesse: const Size(390, 3000),
      ruhig: true,
    );
    expect(find.byType(MHaken), findsNothing, reason: 'Keine Karte zum Anhaken, die ein anderer Ruf verwirft');
    await _tippe(tester, find.byKey(const ValueKey('ruf-karte-k-nochmal')));
    await _tippe(tester, find.byKey(const ValueKey('ruf-karte-k-umweg')));
    await _tippe(tester, find.byKey(const ValueKey('ruf-umweg')));
    expect(gesendet, [
      {'typ': 'tischruf', 'ruf': 'nochmal', 'karte': 'k-nochmal'},
      {'typ': 'tischruf', 'ruf': 'umweg', 'karte': 'k-umweg'},
      {'typ': 'tischruf', 'ruf': 'umweg'},
    ]);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
