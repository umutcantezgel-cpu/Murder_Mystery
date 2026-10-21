// M7b Zusammenführung: der ganze lange Abend an einem Gerät, wie ihn das
// Entwickler-Skript (`?party=schlosskeller&fassung=lang`) spielt. Die Folge
// lautet Vorspiel → Diashow → 3 × Streifzug (Gespräche → Entscheidungen) →
// Auflösung → Morgen → Schlussbild. Das Skript geht beide Rundgänge Station für
// Station ab, trifft jede Befragung an ihrem Treffpunkt, erkundet über die
// Runden alle fünfzehn Orte und geht vor jeder Entscheidung zurück in den
// Keller. Die Phasen und Fotostellen passen zur Browser-Lane `e2e.mjs --lang`.
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mordakte/party/party_seite.dart';
import 'package:mordakte/party/sitzung.dart';
import 'package:mordakte/party/skript.dart';
import 'package:mordakte/party/streifzug_karte.dart';
import 'package:mordakte/party/streifzug_steuerung.dart';
import 'package:mordakte_core/mordakte_core.dart';

import 'hilfe.dart';
import 'rundgang_hilfe.dart';

Map<String, Object?> _json(String p) => jsonDecode(File(p).readAsStringSync()) as Map<String, Object?>;

/// Welt des Streifzugs aus den Repo-Dateien, mit dem Kanon von [rundgangDaten].
StreifzugWelt _streifzugWelt() => StreifzugWelt(
      weltEbenen,
      ebenenSzenarien,
      Erkundung.ausJson(_json('content/welt/schlosskeller/erkundung.json')),
    );

const _runde = ['gespraeche', 'entscheidungen', 'gruppenwahl', 'bonus', 'resuemee'];

/// Phasen ab der Einrichtung, wie im kurzen Abend (`PHASEN` in tool/e2e/e2e.mjs).
const _phasen = ['einrichtung', 'rollen', 'intro', ..._runde, ..._runde, ..._runde, 'anklage', 'finale', 'aufloesung', 'ende'];

/// Folge ohne direkte Wiederholungen (`kollabiere` in tool/e2e/e2e.mjs).
List<String> _kollabiere(List<String> l) => [for (var i = 0; i < l.length; i++) if (i == 0 || l[i] != l[i - 1]) l[i]];

/// `fotoGruppe` aus tool/e2e/e2e.mjs: feste Namen (`FESTE_FOTOS`) und die
/// Muster je Abschnitt, aus der Datei gelesen. So prüft der Test dieselbe
/// Zuordnung wie die Browser-Lane.
String Function(String) _e2eFotoGruppe() {
  final js = File('tool/e2e/e2e.mjs').readAsStringSync();
  final block = RegExp(r'const FESTE_FOTOS = \{(.*?)\n\};', dotAll: true).firstMatch(js)!.group(1)!;
  final fest = {for (final m in RegExp(r"^\s+(\w+): '(\w+)',", multiLine: true).allMatches(block)) m.group(1)!: m.group(2)!};
  final rumpf = RegExp(r'function fotoGruppe\(name\) \{(.*?)\n\}', dotAll: true).firstMatch(js)!.group(1)!;
  final muster = [
    for (final m in RegExp(r"if \((.*)\) return '(\w+)';").allMatches(rumpf))
      (gruppe: m.group(2)!, re: [for (final r in RegExp(r'/(\^[^/]*)/\.test\(name\)').allMatches(m.group(1)!)) RegExp(r.group(1)!)]),
  ];
  expect(fest, containsPair('vorspiel', 'intro'));
  expect(fest, containsPair('morgen', 'ende'));
  expect(muster.map((m) => m.gruppe), containsAll(['gespraeche', 'entscheidungen', 'gruppenwahl', 'aufloesung']));
  return (name) {
    if (fest[name] case final g?) return g;
    for (final m in muster) {
      if (m.re.any((r) => r.hasMatch(name))) return m.gruppe;
    }
    return 'unbekannt:$name';
  };
}

void main() {
  setUp(rundgangWeltAusDateien);

  testWidgets('Skript lang: Vorspiel, Diashow, dreimal Streifzug mit Treffpunkten, allen Erkundungen und Rückkehr, Auflösung, Morgen', (t) async {
    StreifzugWelt.vorgabe = _streifzugWelt();
    addTearDown(() => StreifzugWelt.vorgabe = null);
    // Würfel aus dem Salz wie in der App: So spielt das Journal am Ende denselben Abend nach.
    final s = PartySitzung(rundgangDaten, salz: 'langer-abend-skript');
    final st = s.streifzug;

    // Zeitlinie: Rundgang-Stationen, Wechsel des Streifzugs (mit Stelle), Ankünfte und Wahlen.
    final stationen = <String>[];
    // Uhr des Tests beim Erreichen jeder Station (Rundgang, Station).
    final stationsZeit = <(RundgangTeil, DateTime)>[];
    final zeitlinie = <String>[];
    final ankuenfte = <int, Set<String>>{};
    final befragt = <int, Set<String>>{};
    var gewaehlt = 0;
    String? letzteStation, letzterModus, letztesOffen;
    // Vor dem Bildschirm angemeldet: sieht jede Wahl, bevor der Streifzug zurückschaltet.
    s.addListener(() {
      if (s.rundgang case final teil?) {
        final station = '${teil.name}:${s.rundgangStation}';
        if (station != letzteStation) {
          stationen.add(station);
          stationsZeit.add((teil, t.binding.clock.now()));
        }
        letzteStation = station;
      }
      if (s.streifzugLaeuft && s.phase == PartyPhase.gespraeche) {
        (befragt[s.runde] ??= {}).addAll([for (final k in s.befragungen) if (k.erledigt) k.id]);
      }
      if (s.spiel.gewaehlt.length > gewaehlt) {
        gewaehlt = s.spiel.gewaehlt.length;
        zeitlinie.add('wahl r${s.runde} ${st.modus.name}');
      }
    });
    st.addListener(() {
      if (st.modus.name != letzterModus) {
        letzterModus = st.modus.name;
        zeitlinie.add('modus ${st.modus.name}@${st.position?.ebene}');
      }
      final offen = st.offen;
      if (offen != letztesOffen && offen != null && offen.startsWith(StreifzugMarke.treffPraefix)) {
        (ankuenfte[s.runde] ??= {}).add(offen.substring(StreifzugMarke.treffPraefix.length));
      }
      letztesOffen = offen;
    });

    final zeilen = <String>[];
    final vorher = debugPrint;
    debugPrint = (String? m, {int? wrapWidth}) {
      if (m != null) zeilen.add(m);
    };
    PartySitzung.protokoll = true;
    addTearDown(() => PartySitzung.protokoll = false);
    t.view.physicalSize = const Size(390, 844);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.view.resetDevicePixelRatio);
    testAbendzeit(t, s);
    await t.pumpWidget(MaterialApp(theme: ThemeData.dark(), home: Scaffold(body: PartyAblauf(sitzung: s))));
    await t.pump();
    final dev = PartyDev(rollen: 4, pfad: 'ahmet', takt: 60, fotos: false, fotopause: 60, zeitraffer: 600, fassung: Abendfassung.lang);
    unawaited(PartySkript(s, dev).starten());
    try {
      for (var i = 0; i < 30000 && !zeilen.any((z) => z.startsWith('PARTY fertig') || z.startsWith('PARTY fehler')); i++) {
        await t.pump(const Duration(milliseconds: 100));
      }
    } finally {
      debugPrint = vorher;
    }
    expect(zeilen.where((z) => z.startsWith('PARTY fehler')), isEmpty);
    expect(zeilen.any((z) => z.startsWith('PARTY fertig pfad=ahmet')), isTrue,
        reason: 'Der Abend läuft durch: ${zeilen.reversed.take(12).toList().reversed.join(' | ')}; ${s.phase} ${s.rundgang} ${st.modus} ${st.offen}');
    expect([s.lang, s.phase, s.rundgang], [true, PartyPhase.ende, null]);

    // Phasen wie im kurzen Abend; Vorspiel und Morgen sind Unterzustände.
    final phasen = [for (final z in zeilen) if (z.startsWith('PARTY phase=')) RegExp(r'phase=(\w+)').firstMatch(z)!.group(1)!];
    expect(_kollabiere(phasen.where((p) => p != 'titel').toList()), _phasen);

    // Fotostellen: dieselbe Abschnittsfolge, die e2e.mjs prüft, und die Folge im Abend.
    final fotos = [for (final z in zeilen) if (z.startsWith('PARTY foto=')) z.substring('PARTY foto='.length)];
    final gruppe = _e2eFotoGruppe();
    expect(_kollabiere(fotos.map(gruppe).toList()), ['titel', ..._phasen], reason: fotos.join(' > '));
    int pos(String f) {
      expect(fotos.where((x) => x == f), hasLength(1), reason: f);
      return fotos.indexOf(f);
    }

    expect(pos('dossier_taeter'), lessThan(pos('vorspiel')));
    expect(pos('vorspiel'), lessThan(pos('intro')), reason: 'Erst das Vorspiel, dann die Diashow');
    expect(pos('intro'), lessThan(pos('gespraeche_r1')));
    for (var r = 1; r <= 3; r++) {
      expect(pos('gespraeche_r$r'), lessThan(pos('streifzug_r$r')));
      expect(pos('streifzug_r$r'), lessThan(pos('treffpunkt_r$r')));
      expect(pos('erkundung_r$r'), lessThan(pos('entscheidungen_fertig_r$r')));
    }
    expect(pos('entscheidungen_fertig_r3'), lessThan(pos('anklage')));
    // Die Auflösung meldet sich mit der Runde (`aufloesung_r3`).
    expect(pos('aufloesung_r3'), lessThan(pos('morgen')));
    expect(pos('morgen'), lessThan(pos('ende')), reason: 'Erst der Morgen, dann das Schlussbild');

    // Beide Rundgänge ganz, Station für Station, nichts übersprungen.
    final vm = rundgangDaten.vorspielMorgen!;
    expect(stationen, [
      for (var i = 0; i < vm.rundgang(RundgangTeil.vorspiel).stationen.length; i++) 'vorspiel:$i',
      for (var i = 0; i < vm.rundgang(RundgangTeil.morgen).stationen.length; i++) 'morgen:$i',
    ]);
    final befehle = (s.abendstand['befehle'] as List).cast<Map>();
    expect(befehle.where((b) => b['b'] == 'rundgang' && b['ueberspringen'] == true), isEmpty);
    // Wie im Streifzug geht jeder Weg sichtbar los und wird nach höchstens 1,5 s
    // abgekürzt: Von Station zu Station vergehen höchstens Weg, Takt und Bild.
    for (var i = 1; i < stationsZeit.length; i++) {
      final (teil, zeit) = stationsZeit[i];
      if (stationsZeit[i - 1].$1 != teil) continue;
      expect(zeit.difference(stationsZeit[i - 1].$2), lessThanOrEqualTo(const Duration(milliseconds: 2000)), reason: '${stationen[i]}: Weg nicht abgekürzt');
    }

    // Jede erledigte Befragung am Treffpunkt angetroffen, in jeder Runde.
    for (var r = 1; r <= 3; r++) {
      expect(befragt[r], isNotEmpty, reason: 'Runde $r');
      expect(ankuenfte[r], containsAll(befragt[r]!), reason: 'Runde $r: Befragungen ohne Treffpunkt');
    }

    // Alle fünfzehn Erkundungen, je Runde der Reihum-Deckel; im Journal nur lang.
    expect(s.erkundet, {for (final o in StreifzugWelt.vorgabe!.erkundung.orte) o.id});
    expect([for (var r = 1; r <= 3; r++) s.erkundetInRunde(r)], [streifzugDeckelReihum, streifzugDeckelReihum, streifzugDeckelReihum]);
    expect(befehle.where((b) => b['b'] == 'erkundet'), hasLength(erkundungAnzahl));

    // Vor jeder Entscheidung zurück in den Keller: Zwischen zwei Wahlen liegt
    // ein Rückweg, und gewählt wird in der Entscheidung, im Keller.
    final wahlen = zeitlinie.where((z) => z.startsWith('wahl')).toList();
    expect(wahlen, hasLength(s.spiel.gewaehlt.length));
    expect(wahlen, hasLength(greaterThanOrEqualTo(3)));
    var zurueck = false, rueckweg = false;
    for (final z in zeitlinie) {
      if (z.startsWith('modus rueckweg')) rueckweg = true;
      if (z == 'modus entscheidung@$kellerEbene' && rueckweg) zurueck = true;
      if (z.startsWith('wahl')) {
        expect(zurueck, isTrue, reason: '$z ohne Rückkehr in den Keller: ${zeitlinie.join(' | ')}');
        expect(z, endsWith(StreifzugModus.entscheidung.name));
        zurueck = rueckweg = false;
      }
    }

    // Nach dem Fortsetzen derselbe Abend, ohne Vorspiel oder Morgen von vorn.
    PartySitzung.protokoll = false;
    final weiter = PartySitzung.fortsetzen(rundgangDaten, s.abendstand);
    addTearDown(weiter.dispose);
    expect([weiter.phase, weiter.rundgang, weiter.spiel.punkte, weiter.ende.id, weiter.erkundet], [PartyPhase.ende, null, s.spiel.punkte, s.ende.id, s.erkundet]);

    await t.pumpWidget(const SizedBox());
    await t.pump(const Duration(seconds: 2));
    s.dispose();
  });
}
