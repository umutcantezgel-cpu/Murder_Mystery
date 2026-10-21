// M7b Streifzug: Im langen Abend werden Gespräche und Entscheidungen zum Gang
// durchs Schloss. Jede Befragung hat einen Treffpunkt, die Befragung öffnet
// sich erst bei der Ankunft (dieselbe Karte wie kurz, mit Impulskarte), die
// Erkundung kostet nichts, vor jeder Entscheidung geht es zurück in den Keller,
// reihum ist die freie Erkundung gedeckelt. Der kurze Abend bleibt, wie er war.
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_test/flutter_test.dart';
import 'package:mordakte/game/game_view.dart';
import 'package:mordakte/party/bildschirme/befragung.dart';
import 'package:mordakte/party/bildschirme/karte.dart';
import 'package:mordakte/party/bildschirme/runde.dart';
import 'package:mordakte/party/bildschirme/streifzug.dart';
import 'package:mordakte/party/party_seite.dart';
import 'package:mordakte/party/sitzung.dart';
import 'package:mordakte/party/skript.dart';
import 'package:mordakte/party/streifzug_karte.dart';
import 'package:mordakte/party/streifzug_steuerung.dart';
import 'package:mordakte_core/mordakte_core.dart';
import 'package:mordakte_core/runden.dart';

import 'hilfe.dart';

Map<String, Object?> _json(String p) => jsonDecode(File(p).readAsStringSync()) as Map<String, Object?>;

StreifzugWelt? _welt;

/// Welt des Streifzugs aus den Repo-Dateien (Kanon der Langfassung-Daten).
StreifzugWelt get streifzugWelt => _welt ??= () {
      final kanon = langDaten.kanon;
      final welt = WeltEbenen.ausJson(_json('content/welt/schlosskeller/langfassung.json'), kanon);
      final szenarien = partyEbenenSzenarien(kanon, _json('content/scenarios/ravensmoor.json').cast<String, dynamic>(), welt,
          id: langDaten.szenario.id, welt: _json('content/welt/schlosskeller/welt.json'));
      return StreifzugWelt(welt, szenarien, Erkundung.ausJson(_json('content/welt/schlosskeller/erkundung.json')));
    }();

/// Langer Abend mit Pfad ahmet und neutralen Würfeln.
PartySitzung _lang({bool solo = true, int rollen = 4, String salz = 'streifzug-probe'}) {
  final s = PartySitzung(langDaten, wuerfel: const FesterWuerfel.neutral(), salz: salz);
  s.einrichten(rollen: rollen, detektiv: 'w', solo: solo, code: FallCode.fuerPfad('ahmet', langDaten.kanon.pfade).code, fassung: Abendfassung.lang);
  return s;
}

/// Der Abend im Rahmen wie in der App ([PartyAblauf]); [ruhig] kürzt Wege ab (Bewegung reduziert).
Future<void> _zeige(WidgetTester t, PartySitzung s, {bool ruhig = false}) async {
  StreifzugWelt.vorgabe = streifzugWelt;
  addTearDown(() => StreifzugWelt.vorgabe = null);
  t.view.physicalSize = const Size(390, 844);
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.resetPhysicalSize);
  addTearDown(t.view.resetDevicePixelRatio);
  testAbendzeit(t, s);
  await t.pumpWidget(MaterialApp(
    theme: ThemeData.dark(),
    builder: (context, child) => MediaQuery(data: MediaQuery.of(context).copyWith(disableAnimations: ruhig), child: child!),
    home: Scaffold(body: PartyAblauf(sitzung: s)),
  ));
  await t.pump();
}

/// Pumpt Bilder, bis [ok] gilt (höchstens [sekunden] Spielzeit).
Future<void> _bis(WidgetTester t, bool Function() ok, {double sekunden = 40, String grund = ''}) async {
  for (var i = 0; i < sekunden * 20 && !ok(); i++) {
    await t.pump(const Duration(milliseconds: 50));
  }
  expect(ok(), isTrue, reason: grund);
}

Future<void> _tippe(WidgetTester t, Finder f) async {
  await t.ensureVisible(f);
  await t.tap(f);
  await t.pump();
}

/// Leert den Baum am Ende, damit Karte und Uhren abgebaut sind.
Future<void> _ende(WidgetTester t, PartySitzung s) async {
  await t.pumpWidget(const SizedBox());
  await t.pump(const Duration(seconds: 2));
  s.dispose();
}

void main() {
  testWidgets('kurz bleibt, wie er war: Befragung, Runde und Karte; lang wird beides zum Streifzug', (t) async {
    final kurzSolo = neueSitzung(rollen: 4, solo: true);
    spieleBis(kurzSolo, PartyPhase.gespraeche);
    expect(bildschirm(kurzSolo), isA<BefragungBildschirm>());
    spieleBis(kurzSolo, PartyPhase.entscheidungen);
    expect(bildschirm(kurzSolo), isA<KartenBildschirm>());
    final kurzReihum = neueSitzung(rollen: 4);
    spieleBis(kurzReihum, PartyPhase.gespraeche);
    expect(bildschirm(kurzReihum), isA<RundeBildschirm>());
    // Kurz mit der Akte, die eine Langfassung hat: weiterhin die alten Bildschirme.
    final kurzLangAkte = PartySitzung(langDaten, wuerfel: const FesterWuerfel.neutral(), salz: 'x')
      ..einrichten(rollen: 4, detektiv: 'w', solo: true, code: FallCode.fuerPfad('ahmet', langDaten.kanon.pfade).code);
    spieleBis(kurzLangAkte, PartyPhase.gespraeche);
    expect(bildschirm(kurzLangAkte), isA<BefragungBildschirm>());
    expect(() => kurzLangAkte.erkunden('ek_brunnen'), throwsStateError, reason: 'kurz gibt es keine Erkundung');
    final lang = _lang();
    spieleBis(lang, PartyPhase.gespraeche);
    expect(bildschirm(lang), isA<StreifzugBildschirm>());
    spieleBis(lang, PartyPhase.entscheidungen);
    expect(bildschirm(lang), isA<StreifzugBildschirm>());
    spieleBis(lang, PartyPhase.gruppenwahl);
    expect(bildschirm(lang), isNot(isA<StreifzugBildschirm>()));
    for (final s in [kurzSolo, kurzReihum, kurzLangAkte, lang]) {
      s.dispose();
    }
  });

  testWidgets('lang solo: Treffpunktkarte, der Detektiv läuft hin, bei Ankunft öffnet sich die Befragung mit Impulskarte', (t) async {
    final s = _lang();
    spieleBis(s, PartyPhase.gespraeche);
    await _zeige(t, s);
    // Rundenstart: Erzähltext und Uhr, dann los.
    expect(s.streifzug.offen, streifzugStart);
    expect(find.text(s.text('runde.1.start')), findsOneWidget);
    expect(find.text(s.ui('ui.allgemein.uhrzeit', {'uhrzeit': '00:30'})), findsOneWidget);
    await _tippe(t, find.byKey(const ValueKey('streifzug-los')));
    expect(s.streifzug.offen, isNull);

    // Jede Befragung hat ihren Treffpunkt aus dem Samen der Welt.
    final e = streifzugWelt.erkundung;
    final treff = e.treffpunkteFuer(s.weltSamen, [for (final k in s.befragungen) k.id]);
    expect(s.streifzugTreffpunkte(e), {for (final x in treff.entries) x.key: x.value.id});
    final pflicht = s.befragungen.firstWhere((k) => k.pflicht);
    final tp = treff[pflicht.id]!;
    expect(find.text('Triff ${s.personAmTisch(pflicht.rolle)} ${tp.anzeige}'), findsOneWidget);

    // Antippen: Der Detektiv läuft hin; erst bei der Ankunft öffnet sich die Befragung.
    await _tippe(t, find.byKey(ValueKey('streifzug-treff:${pflicht.id}')));
    expect(s.streifzug.unterwegs, 'treff:${pflicht.id}');
    expect(find.byType(BefragungsKarte), findsNothing);
    // Er läuft sichtbar (Bild für Bild), kein Sprung.
    final karte = t.widget<GameView>(find.byType(GameView)).session as StreifzugKarte;
    final start = karte.position;
    await t.pump(const Duration(milliseconds: 600));
    await t.pump(const Duration(milliseconds: 600));
    expect(karte.laeuft, isTrue);
    expect(karte.world.value!.detectives.single.moving, isTrue);
    expect(karte.position, isNot(start));
    expect(s.streifzug.offen, isNull, reason: 'unterwegs noch keine Befragung');
    await _bis(t, () => s.streifzug.offen == 'treff:${pflicht.id}', grund: 'Ankunft am Treffpunkt');
    final pos = s.streifzug.position!;
    expect(pos.ebene, tp.ebene);
    final ort = streifzugWelt.welt.ebenen[tp.ebene]!.graph.orte[tp.ort]!;
    expect(dist(pos.x, pos.y, ort.x, ort.y), lessThanOrEqualTo(1.0), reason: 'Der Detektiv steht am Treffpunkt');
    await t.pump();
    expect(find.byType(BefragungsKarte), findsOneWidget);
    // Impulskarte: was die Figur gerade am Tisch bespricht, nur Paarung und Thema.
    expect(find.byKey(const ValueKey('streifzug-impuls')), findsOneWidget);
    for (final p in s.tisch(1).where((p) => p.rolle == pflicht.rolle || p.partner == pflicht.rolle).take(3)) {
      expect(find.text(p.thema), findsWidgets);
    }
    // Dieselbe Befragung wie kurz: erst die Frage, dann die Antwort.
    expect(find.byType(AussageKarte), findsNothing);
    await _tippe(t, find.text(pflicht.fragen.first));
    expect(s.befragungen.firstWhere((k) => k.id == pflicht.id).erledigt, isTrue);
    expect(find.byType(AussageKarte), findsWidgets);
    await _tippe(t, find.byKey(const ValueKey('streifzug-schliessen')));
    expect(find.byKey(ValueKey('streifzug-treff:${pflicht.id}')), findsNothing, reason: 'erledigt: kein Treffpunkt mehr');

    // Weiter erst, wenn die Befragungen durch sind (wie kurz); dann über die Steuerung wie das Skript.
    expect(s.kannWeiter, isFalse);
    var frei = s.befragungenFrei;
    for (final k in [...s.befragungen]) {
      if (k.erledigt || (!k.pflicht && frei <= 0)) continue;
      if (!k.pflicht) frei--;
      expect(s.streifzug.gehe('treff:${k.id}'), isTrue);
      await _bis(t, () => s.streifzug.offen == 'treff:${k.id}', grund: 'Ankunft bei ${k.id}');
      s.befragen(k.id, 0);
      s.streifzug.schliessen();
      await t.pump();
    }
    expect(s.befragungenFertig, isTrue);
    expect(s.kannWeiter, isTrue);
    await _tippe(t, find.byKey(const ValueKey('streifzug-weiter')));
    expect(s.phase, PartyPhase.entscheidungen);
    await _ende(t, s);
  });

  testWidgets('Erkundung: Karte mit Stimmung bei der Ankunft, 0 Nachtminuten, kein Würfel, im Journal nur lang', (t) async {
    final s = _lang();
    spieleBis(s, PartyPhase.gespraeche);
    await _zeige(t, s, ruhig: true);
    s.streifzug.schliessen();
    await t.pump();
    final minuten = s.restMinuten, wuerfe = s.wuerfe.length, bausteine = s.spiel.bausteine.length;
    final o = streifzugWelt.erkundung.ort('ek_brunnen')!;
    expect(find.byKey(const ValueKey('streifzug-erkunde:ek_brunnen')), findsOneWidget);
    expect(s.streifzug.gehe('erkunde:ek_brunnen'), isTrue);
    await _bis(t, () => s.streifzug.offen == 'erkunde:ek_brunnen', grund: 'Bewegung reduziert: Kurzblende ans Ziel');
    await t.pump();
    expect(find.byKey(const ValueKey('streifzug-erkundung-ek_brunnen')), findsOneWidget);
    expect(find.text(o.titel), findsOneWidget);
    for (final p in o.stichpunkteFuer(s.weltSamen)) {
      expect(find.text(p), findsOneWidget);
    }
    expect(s.erkundet, {'ek_brunnen'});
    expect([s.restMinuten, s.wuerfe.length, s.spiel.bausteine.length], [minuten, wuerfe, bausteine]);
    s.streifzug.schliessen();
    await t.pump();
    expect(find.byKey(const ValueKey('streifzug-erkunde:ek_brunnen')), findsNothing, reason: 'besucht');
    // Journal: nur lang, und nach dem Fortsetzen bleibt die Erkundung.
    final befehle = [for (final b in s.abendstand['befehle'] as List) (b as Map)['b']];
    expect(befehle, contains('erkundet'));
    final weiter = PartySitzung.fortsetzen(langDaten, s.abendstand);
    expect(weiter.erkundet, {'ek_brunnen'});
    expect(weiter.restMinuten, s.restMinuten);
    weiter.dispose();
    await _ende(t, s);
  });

  testWidgets('Entscheidungen: erst nach der Rückkehr in den Keller, danach der unveränderte Ablauf', (t) async {
    final s = _lang();
    spieleBis(s, PartyPhase.gespraeche);
    PartySkript.befragungenErledigen(s);
    // Der Detektiv steht zuletzt im Hof (Stelle der Runde).
    final brunnen = streifzugWelt.welt.ebenen['erdgeschoss']!.graph.orte['eg_am_brunnen']!;
    s.streifzug.position = (runde: 1, ebene: 'erdgeschoss', x: brunnen.x, y: brunnen.y);
    s.weiter();
    expect(s.phase, PartyPhase.entscheidungen);
    expect(s.zug?.istAuftakt, isTrue);
    await _zeige(t, s);
    expect(find.byType(KartenBildschirm), findsNothing, reason: 'erst der Streifzug');
    expect(find.byKey(const ValueKey('streifzug-zur-entscheidung')), findsOneWidget);
    expect(s.streifzug.position!.ebene, 'erdgeschoss');
    await _tippe(t, find.byKey(const ValueKey('streifzug-zur-entscheidung')));
    expect(s.streifzug.modus, StreifzugModus.rueckweg);
    expect(find.byType(KartenBildschirm), findsNothing, reason: 'unterwegs in den Keller');
    await _bis(t, () => s.streifzug.modus == StreifzugModus.entscheidung, grund: 'zurück im Keller');
    final keller = s.streifzug.position!;
    final ort = langDaten.kanon.graph.orte[(langDaten.kanon.figur((langDaten.kanon.figurenJson['detektiv'] as Map)['id'] as String)!)['ermittlungsOrt']]!;
    expect([keller.ebene, keller.x, keller.y], [kellerEbene, ort.x, ort.y], reason: 'am Ermittlungsort');
    await t.pump();
    expect(find.byType(KartenBildschirm), findsOneWidget);
    // Auftakt und erste Entscheidung laufen wie am Tisch; danach wieder der Streifzug.
    expect(s.laufendeEntscheidung, isNull, reason: 'Der Auftakt läuft');
    spieleZug(s);
    await t.pump();
    expect(s.streifzug.modus, StreifzugModus.entscheidung, reason: 'Nach dem Auftakt bleibt die Entscheidung offen');
    final erste = s.laufendeEntscheidung!.id;
    s.schlageVor(s.laufendeEntscheidung!.richtig[s.spiel.pfad]!);
    s.bestaetigen();
    spieleZug(s);
    await t.pump();
    expect(s.laufendeEntscheidung?.id, isNot(erste));
    expect(s.streifzug.modus, StreifzugModus.streifzug);
    await t.pump();
    expect(find.byType(KartenBildschirm), findsNothing);
    expect(find.byKey(const ValueKey('streifzug-zur-entscheidung')), findsOneWidget);
    // Zwischen den Entscheidungen frei erkunden; ohne offene Entscheidung kommt „Weiter“.
    expect(find.byKey(const ValueKey('streifzug-erkunde:ek_herd')), findsOneWidget);
    await _ende(t, s);
  });

  testWidgets('Reihum: Befragung am Treffpunkt geht verdeckt an die Person, die freie Erkundung ist je Runde gedeckelt', (t) async {
    final s = _lang(solo: false);
    spieleBis(s, PartyPhase.gespraeche);
    await _zeige(t, s, ruhig: true);
    s.streifzug.schliessen();
    await t.pump();
    expect(find.byKey(const ValueKey('streifzug-tisch')), findsOneWidget);
    final k = s.befragungen.firstWhere((k) => k.pflicht && k.mensch);
    expect(s.streifzug.gehe('treff:${k.id}'), isTrue);
    await _bis(t, () => s.streifzug.offen == 'treff:${k.id}');
    await t.pump();
    await _tippe(t, find.text(k.fragen.first));
    // Verdeckte Übergabe wie im kurzen Abend.
    final name = s.spielerName(k.rolle);
    expect(find.text(s.ui('ui.befragung.geraet', {'name': name})), findsOneWidget);
    await _tippe(t, find.text(s.ui('ui.verdeckt.frage', {'name': name})));
    expect(s.verdeckt, k.rolle);
    await _tippe(t, find.text(s.ui('ui.verdeckt.schliessen')));
    expect(s.verdeckt, isNull);
    expect(s.befragungen.firstWhere((b) => b.id == k.id).erledigt, isTrue);

    // Deckel: fünf freie Erkundungen, dann gehört die Zeit dem Tisch.
    s.streifzug.schliessen();
    await t.pump();
    final orte = streifzugWelt.erkundung.orte;
    for (var i = 0; i < streifzugDeckelReihum; i++) {
      expect(s.erkundungFrei, isTrue);
      expect(s.streifzug.gehe('erkunde:${orte[i].id}'), isTrue);
      await _bis(t, () => s.streifzug.offen == 'erkunde:${orte[i].id}');
      s.streifzug.schliessen();
      await t.pump();
    }
    expect(s.erkundetInRunde(), streifzugDeckelReihum);
    expect(s.erkundungFrei, isFalse);
    expect(find.byKey(const ValueKey('streifzug-deckel')), findsOneWidget);
    expect(find.text(streifzugTexte(t.element(find.byType(StreifzugAnsicht))).streifzug_deckel_titel), findsOneWidget);
    expect(find.byKey(ValueKey('streifzug-erkunde:${orte[streifzugDeckelReihum].id}')), findsNothing);
    expect(s.streifzug.gehe('erkunde:${orte[streifzugDeckelReihum].id}'), isFalse);
    expect(() => s.erkunden(orte[streifzugDeckelReihum].id), throwsStateError);
    // Treffpunkte bleiben trotz Deckel.
    expect(find.byKey(ValueKey('streifzug-treff:${s.befragungen.firstWhere((b) => !b.erledigt && (b.pflicht || (s.befragungenFrei > 0 && b.waehlbar))).id}')), findsOneWidget);
    // Die nächste Runde beginnt mit freier Erkundung.
    PartySkript.befragungenErledigen(s);
    await t.pumpWidget(const SizedBox());
    await t.pump(const Duration(seconds: 2));
    spieleBis(s, PartyPhase.gespraeche, runde: 2);
    expect(s.erkundetInRunde(), 0);
    expect(s.erkundetInRunde(1), streifzugDeckelReihum);
    expect(s.erkundungFrei, isTrue);
    s.dispose();
  });

  testWidgets('Skript lang reihum: Befragungen per Treffpunkt, alle 15 Erkundungen über die Runden, vor jeder Entscheidung zurück', (t) async {
    final s = PartySitzung(langDaten, wuerfel: const FesterWuerfel.neutral(), salz: 'skript-lang');
    final zeilen = <String>[];
    final vorher = debugPrint;
    debugPrint = (String? m, {int? wrapWidth}) {
      if (m != null) zeilen.add(m);
    };
    PartySitzung.protokoll = true;
    addTearDown(() => PartySitzung.protokoll = false);
    await _zeige(t, s);
    final dev = PartyDev(rollen: 4, pfad: 'ahmet', takt: 60, fotos: false, fotopause: 60, zeitraffer: 600, fassung: Abendfassung.lang);
    unawaited(PartySkript(s, dev).starten());
    try {
      for (var i = 0; i < 20000 && !zeilen.any((z) => z.startsWith('PARTY fertig') || z.startsWith('PARTY fehler')); i++) {
        await t.pump(const Duration(milliseconds: 100));
      }
    } finally {
      debugPrint = vorher;
    }
    expect(zeilen.where((z) => z.startsWith('PARTY fehler')), isEmpty);
    expect(zeilen.any((z) => z.startsWith('PARTY fertig pfad=ahmet')), isTrue, reason: 'Der Abend läuft durch: ${zeilen.reversed.take(12).toList().reversed.join(' | ')}; ${s.phase} ${s.streifzug.modus} ${s.streifzug.offen} ${s.streifzug.unterwegs}');
    expect(s.lang, isTrue);
    final fotos = [for (final z in zeilen) if (z.startsWith('PARTY foto=')) z.substring('PARTY foto='.length)];
    for (var r = 1; r <= 3; r++) {
      for (final f in ['gespraeche_r$r', 'streifzug_r$r', 'treffpunkt_r$r', 'erkundung_r$r']) {
        expect(fotos.where((x) => x == f), hasLength(1), reason: f);
      }
      // Reihenfolge innerhalb der Runde: Rundenstart, Streifzug, dann Treffpunkt und Erkundung, vor den Entscheidungen.
      final start = fotos.indexOf('gespraeche_r$r');
      expect(fotos.indexOf('streifzug_r$r'), greaterThan(start));
      expect(fotos.indexOf('treffpunkt_r$r'), greaterThan(fotos.indexOf('streifzug_r$r')));
      expect(fotos.indexOf('entscheidungen_fertig_r$r'), greaterThan(fotos.indexOf('erkundung_r$r')));
    }
    expect(s.erkundet, {for (final o in streifzugWelt.erkundung.orte) o.id}, reason: 'alle 15 Orte, verteilt über die Runden');
    for (var r = 1; r <= 3; r++) {
      expect(s.erkundetInRunde(r), streifzugDeckelReihum, reason: 'Runde $r: genau der Deckel');
    }
    // Die Phasen bleiben die des kurzen Abends.
    final phasen = [for (final z in zeilen) if (z.startsWith('PARTY phase=')) RegExp(r'phase=(\w+)').firstMatch(z)!.group(1)!];
    expect(phasen.toSet(), containsAll(['gespraeche', 'entscheidungen', 'gruppenwahl', 'anklage', 'finale', 'ende']));
    await _ende(t, s);
  });

  test('Streifzug-Karte: Figur am Treffpunkt, Ankunft geführt und getippt, einmal je Ankunft; Treffpunkt vor Erkundung', () async {
    final angekommen = <String>[];
    final w = streifzugWelt;
    final k = StreifzugKarte(langDaten, w.welt, w.szenarien, lage: WeltLage.um('00:30'), detektivName: 'Dana', ansprechen: 'Ansprechen', onMarke: (m) => angekommen.add(m.id));
    addTearDown(k.dispose);
    k.bewegungReduziert = true;
    final brunnen = w.erkundung.ort('ek_brunnen')!;
    final stelle = erkundungsStelle(w.welt, brunnen, raster: k.rasterVon('erdgeschoss'))!;
    final tp = w.erkundung.treffpunkt('tp_brunnen')!;
    final ort = treffpunktStelle(w.welt, tp)!;
    final (fx, fy) = k.nebenOrt('erdgeschoss', ort.$1, ort.$2);
    expect(k.rasterVon('erdgeschoss').canStand(fx, fy, Tuning.playerRadius), isTrue, reason: 'Die Figur steht frei');
    k.marken = [
      StreifzugMarke(id: 'erkunde:ek_brunnen', ebene: 'erdgeschoss', x: stelle.$1, y: stelle.$2),
      StreifzugMarke(id: 'treff:bf_fatma_1', ebene: 'erdgeschoss', x: ort.$1, y: ort.$2, ort: tp.ort, figur: 'fatma', figurX: fx, figurY: fy),
    ];
    // Im Keller steht Fatma an ihrem Ermittlungsort, im Hof am Treffpunkt.
    final npc = langDaten.npcKennung['fatma']!;
    expect(k.npcAktion(npc), isNull, reason: 'im Keller kein Treffpunkt');
    expect(await k.geheZu(k.marke('erkunde:ek_brunnen')!), isTrue);
    expect(k.aktuelleEbene, 'erdgeschoss');
    expect(angekommen, ['erkunde:ek_brunnen']);
    expect([for (final n in k.world.value!.npcs) if (n.id == npc) (n.x, n.y)], [(fx, fy)]);
    expect(k.npcAktion(npc), 'Ansprechen');
    expect(k.glanzpunkte.map((g) => g.id), containsAll(['erkunde:ek_brunnen', 'treff:bf_fatma_1']));
    // Getippt: dieselbe Stelle meldet nichts doppelt; weg und zurück meldet wieder.
    k.move(stelle.$1, stelle.$2 + 0.1, 0);
    expect(angekommen, hasLength(1));
    k.move(stelle.$1 + 3, stelle.$2 + 3, 0);
    k.move(stelle.$1, stelle.$2, 0);
    expect(angekommen, ['erkunde:ek_brunnen', 'erkunde:ek_brunnen']);
    // Am Treffpunkt geht die Befragung vor; Ansprechen der Figur in Reichweite zählt auch.
    k.move(ort.$1, ort.$2, 0);
    expect(angekommen.last, 'treff:bf_fatma_1');
    k.move(ort.$1 - 4, ort.$2 + 1, 0);
    k.send(Interact(npc));
    expect(angekommen.last, 'treff:bf_fatma_1');
    expect(angekommen, hasLength(3), reason: 'zu weit weg zum Ansprechen');
    // Neben der Figur, aber außerhalb des Ankunftsradius des Treffpunkts: erst das Ansprechen öffnet.
    final (ax, ay) = (fx + (fx - ort.$1), fy + (fy - ort.$2));
    k.move(ax, ay, 0);
    expect(angekommen, hasLength(3));
    k.send(Interact(npc));
    expect(angekommen, hasLength(4));
    expect(() => k.laufeZuPunkt('mond', (1, 1), ziel: 'x'), throwsArgumentError);
  });

  testWidgets('Die App lädt die Welt des Streifzugs aus den Assets (Ebenen, Szenarien, Erkundung)', (t) async {
    final w = await t.runAsync(() => StreifzugWelt.laden(rootBundle, langDaten));
    expect(w!.erkundung.orte, hasLength(erkundungAnzahl));
    expect(w.szenarien.keys, containsAll(['keller', 'erdgeschoss', 'turm']));
    expect(await t.runAsync(() => StreifzugWelt.ladeErkundung(rootBundle, 'gewoelbe')), isNull, reason: 'Altakten haben keine');
  });

  test('Solo ohne Deckel; Erkundung ändert keine Wertung', () {
    final s = _lang();
    spieleBis(s, PartyPhase.gespraeche);
    for (final o in streifzugWelt.erkundung.orte.take(streifzugDeckelReihum + 2)) {
      s.erkunden(o.id);
    }
    expect(s.erkundetInRunde(), streifzugDeckelReihum + 2);
    expect(s.erkundungFrei, isTrue);
    // Gleicher Abend ohne Erkundung: gleiche Punkte, gleiches Ende, gleiche Würfe.
    final ohne = _lang();
    for (final x in [s, ohne]) {
      spieleBis(x, PartyPhase.anklage);
      x.anklagen(x.spiel.pfad);
      x.weiter();
    }
    expect(s.spiel.punkte, ohne.spiel.punkte);
    expect(s.spiel.ende.id, ohne.spiel.ende.id);
    expect([for (final w in s.wuerfe) w.toJson()], [for (final w in ohne.wuerfe) w.toJson()]);
    s.dispose();
    ohne.dispose();
  });
}
