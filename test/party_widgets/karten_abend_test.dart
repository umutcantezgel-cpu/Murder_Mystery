// Sammelkarten im Solo-Abend: Werkzeug im Suchwurf (Vorschau +1, Ladung weg), Erkundung
// über „Erkunden: …“ mit Nebenfund, und Punkte sowie Ende bleiben gegenüber dem Lauf ohne Karte gleich.
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mordakte/karten/widgets/karten_ansicht.dart';
import 'package:mordakte/party/bildschirme/karte.dart';
import 'package:mordakte/party/bildschirme/zug_tafel.dart';
import 'package:mordakte/party/sitzung.dart';
import 'package:mordakte_core/mordakte_core.dart';
import 'package:mordakte_core/runden.dart';

import 'hilfe.dart';

const stirnlampe = 'schlosskeller:tim:stirnlampe'; // Werkzeug, 1 Ladung

/// Abstecher der Akte Schlosskeller (content/party/zusatz/schlosskeller/abstecher.json).
List<AbstecherOrt> get abstecher => AbstecherOrt.liste(
    jsonDecode(File('content/party/zusatz/schlosskeller/abstecher.json').readAsStringSync()) as Map<String, Object?>);

/// Katalog aller Kartendateien (wie der Lader der App).
KartenKatalog get katalog {
  final dateien = Directory('content/karten').listSync().whereType<File>()
      .where((f) => f.path.endsWith('.json') && !f.path.endsWith('.schema.json'))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));
  return KartenKatalog.ausDateien([for (final f in dateien) jsonDecode(f.readAsStringSync()) as Map<String, Object?>]);
}

/// Solo-Abend mit Pfad „ahmet“, neutralen Würfeln (3+4) und dem Tischvorrat [vorrat].
PartySitzung abend(String salz, TischVorrat vorrat) {
  final s = PartySitzung(partyDaten, wuerfel: const FesterWuerfel.neutral(), salz: salz, vorrat: vorrat, abstecher: abstecher);
  s.einrichten(rollen: 4, detektiv: 'w', solo: true, code: FallCode.fuerPfad('ahmet', partyDaten.kanon.pfade).code);
  return s;
}

/// Befragungen beantworten, bis die erste Suche kommt, und diese Suche einsetzen (bis zum Weg).
void zurSuche(PartySitzung s) {
  while (!istSuche(s.laufendeEntscheidung!)) {
    s.schlageVor(s.laufendeEntscheidung!.optionen.first.id);
    s.bestaetigen();
    spieleZug(s);
  }
  s.schlageVor(s.laufendeEntscheidung!.optionen.first.id);
  s.bestaetigen();
}

Future<void> zeige(WidgetTester t, PartySitzung s) async {
  t.view.physicalSize = const Size(390, 844);
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.resetPhysicalSize);
  addTearDown(t.view.resetDevicePixelRatio);
  await t.pumpWidget(MaterialApp(
    theme: ThemeData.dark(),
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(disableAnimations: true),
      child: child!,
    ),
    home: Scaffold(body: KartenBildschirm(sitzung: s)),
  ));
  await t.pump();
}

Future<void> tippen(WidgetTester t, Finder f) async {
  await t.ensureVisible(f);
  await t.tap(f);
  await t.pump();
}

/// Lässt Bilder laufen, bis der Zug in [phase] ist (der Weg läuft im Spiel über Zeit).
Future<void> bisPhase(WidgetTester t, PartySitzung s, RundenZugPhase phase) async {
  for (var i = 0; i < 60 && s.zug?.phase != phase; i++) {
    await t.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  testWidgets('Suchwurf: Werkzeug ist spielbar, +1 auf die Vorschau, die Ladung geht erst mit dem Wurf', (t) async {
    final sem = t.ensureSemantics();
    final s = abend('karten-a', TischVorrat.aus([stirnlampe], katalog));
    spieleBis(s, PartyPhase.entscheidungen, runde: 2); // Runde 1 hat nur Befragungen
    zurSuche(s);
    s.aktionFertig(s.zug!.aktion);
    expect(s.zug!.phase, RundenZugPhase.wurf);
    await zeige(t, s);

    expect(find.byType(WuerfelTafel), findsOneWidget);
    expect(find.text(s.ui('ui.zug.chancen', {'mod': '0'})), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('Stirnlampe.*Jetzt spielbar')), findsOneWidget);

    await tippen(t, find.byKey(const ValueKey('hand-$stirnlampe')));
    expect(find.text(s.ui('ui.zug.chancen', {'mod': '1'})), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('Stirnlampe.*Eingesetzt')), findsOneWidget);
    expect(s.wuerfelVorschau(werkzeug: true).mod, 1);
    expect(s.vorrat.rest(stirnlampe), 1, reason: 'Vorschau verbraucht noch keine Ladung');

    await tippen(t, find.text(s.ui('ui.zug.werfen')));
    expect(s.wuerfe.last.mod, 1);
    expect(s.wuerfe.last.stufe, Stufe.teilerfolg, reason: '3 + 4 + 1 = 8');
    expect(s.vorrat.rest(stirnlampe), 0);
    expect(t.takeException(), isNull);

    // Nach dem Lesen zeigt die Hand im Abend die Karte als aufgebraucht.
    await tippen(t, find.text(s.ui('ui.karte.gelesen')));
    expect(s.zug, isNull);
    expect(find.bySemanticsLabel(RegExp('Stirnlampe.*Aufgebraucht')), findsOneWidget);
    sem.dispose();
    await t.pumpWidget(const SizedBox());
  });

  testWidgets('Erkundung: „Erkunden: …“ startet den Weg, danach steht der Nebenfund da', (t) async {
    final s = abend('karten-b', TischVorrat.aus([stirnlampe], katalog));
    spieleBis(s, PartyPhase.entscheidungen);
    while (s.laufendeEntscheidung != null) {
      s.schlageVor(s.laufendeEntscheidung!.optionen.first.id);
      s.bestaetigen();
      spieleZug(s);
    }
    expect(s.kannWeiter, isTrue);
    final ort = s.abstecherOffen.first;
    await zeige(t, s);

    expect(find.text(KartenTexte.erkunden(ort.name)), findsOneWidget, reason: 'Der Abstecher wird angeboten');
    await tippen(t, find.text(KartenTexte.erkunden(ort.name)));
    expect(find.text(ort.name), findsWidgets);
    expect(find.text(KartenTexte.erkundenNein), findsOneWidget);
    await tippen(t, find.text(KartenTexte.erkundenLos));
    expect(s.zug?.istAbstecher, isTrue);

    await bisPhase(t, s, RundenZugPhase.wurf);
    expect(s.zug!.phase, RundenZugPhase.wurf, reason: 'der Weg führt zur Würfelbühne');
    await tippen(t, find.text(s.ui('ui.zug.werfen')));
    expect(s.abstecherErgebnis[ort.id], Stufe.teilerfolg, reason: 'ohne Werkzeug: 3 + 4 = 7');
    expect(s.abstecherFunde, contains(ort.id));
    expect(find.text(KartenTexte.erkundenFund.toUpperCase()), findsOneWidget, reason: 'NEBENFUND');
    expect(find.text(ort.teilerfolg), findsOneWidget);

    await tippen(t, find.text(s.ui('ui.karte.gelesen')));
    expect(s.zug, isNull);
    expect(s.abstecherOffen.any((a) => a.id == ort.id), isFalse, reason: 'ein Ort je Abend');
    expect(find.text(KartenTexte.erkundenFund.toUpperCase()), findsNothing);
    expect(t.takeException(), isNull);
    await t.pumpWidget(const SizedBox());
  });

  test('Punkte und Ende bleiben gleich, ob die Werkzeug-Karte im Suchwurf liegt oder nicht', () {
    ({int punkte, String ende, String pfad, int rest, List<Stufe> stufen, int karteMods}) lauf({required bool mitKarte}) {
      final s = abend('karten-c', TischVorrat.aus([stirnlampe], katalog));
      spieleBis(s, PartyPhase.entscheidungen, runde: 2);
      zurSuche(s);
      s.aktionFertig(s.zug!.aktion);
      s.wuerfeln(karte: mitKarte ? stirnlampe : null);
      spieleZug(s);
      spieleBis(s, PartyPhase.ende);
      final mods = [for (final w in s.wuerfe) w.mod];
      return (
        punkte: s.spiel.punkte,
        ende: s.ende.id,
        pfad: s.pfad,
        rest: s.restMinuten,
        stufen: [for (final w in s.wuerfe) w.stufe],
        karteMods: mods.where((m) => m > 0).length,
      );
    }

    final mit = lauf(mitKarte: true);
    final ohne = lauf(mitKarte: false);
    expect(mit.karteMods, 1, reason: 'die Karte wirkt genau einmal');
    expect(ohne.karteMods, 0);
    expect(mit.punkte, ohne.punkte);
    expect(mit.ende, ohne.ende);
    expect(mit.pfad, ohne.pfad);
    expect(mit.stufen, ohne.stufen, reason: 'mit +1 bleibt jeder Wurf teilerfolg');
    expect(mit.rest, ohne.rest);
  });
}
