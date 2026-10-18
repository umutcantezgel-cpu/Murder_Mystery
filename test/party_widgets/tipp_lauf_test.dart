// M1: Tippen zum Gehen in allen fünf Akten („Figuren glitschen durch Map“).
// Vom Startplatz des Detektivs aus wird jeder Ort, jeder Hotspot und jede Figur
// angetippt. Danach Frame für Frame: Jede geglättete Strecke besteht
// freieBahn, die eigene Figur steht in jedem Frame frei, und sie kommt ohne
// Hängen und ohne Neuplanen in höchstens 15 Sekunden an.
import 'dart:math' as math;

import 'package:flame/game.dart' show Vector2;
import 'package:flutter_test/flutter_test.dart';
import 'package:mordakte/game/mordakte_game.dart';
import 'package:mordakte/party/karte_session.dart';
import 'package:mordakte/party/sitzung.dart';
import 'package:mordakte_core/mordakte_core.dart';
import 'package:mordakte_core/runden.dart';

import 'hilfe.dart';

const _akten = ['schlosskeller', 'gewoelbe', 'ravensmoor', 'nachtexpress', 'blue_palm'];

/// Höchstens 15 Sekunden bei 60 Bildern je Sekunde.
const _maxFrames = 15 * 60;

/// Ein Abend in den Entscheidungen, ohne laufenden Zug: Die Karte nimmt Eingaben an.
PartySitzung _sitzung(String akte) {
  final s = PartySitzung(akteDaten(akte), wuerfel: const FesterWuerfel.neutral());
  final n = math.min(7, s.kanon.besetzungJson['maxRollen'] as int);
  s.einrichten(rollen: n, detektiv: 'w', code: FallCode.fuerPfad(s.kanon.pfade.first, s.kanon.pfade).code);
  spieleBis(s, PartyPhase.entscheidungen);
  return s;
}

/// Was nach der Ankunft angestoßen wurde (Vorschlag, Randgespräch), wieder zurücknehmen.
void _aufraeumen(PartySitzung s) {
  if (s.vorschlag != null) s.verwerfen();
  if (s.gespraech != null) s.randgespraechBeenden();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final akte in _akten) {
    test('$akte: jeder Tippweg ist frei, steht in jedem Frame und kommt ohne Hängen an', () {
      final s = _sitzung(akte);
      final k = PartyKartenSession(s);
      addTearDown(k.dispose);
      final game = MordakteGame(session: k)..onGameResize(Vector2(390, 844));
      addTearDown(game.dispose);
      game.update(1 / 60);
      final raster = TileGrid(s.daten.szenario.map);
      final start = game.eigenePosition;
      expect(raster.canStand(start.dx, start.dy, Tuning.playerRadius), isTrue, reason: 'Startplatz');
      final ziele = <(String, Offset)>[
        for (final o in s.kanon.graph.orte.values) ('Ort ${o.id}', Offset(o.x, o.y)),
        for (final h in s.daten.szenario.hotspots) ('Hotspot ${h.id}', Offset(h.x + 0.5, h.y + 0.5)),
        for (final n in k.world.value!.npcs) ('Figur ${n.id}', Offset(n.x, n.y)),
      ];
      var strecken = 0, frames = 0;
      for (final (name, ziel) in ziele) {
        final wo = '$akte, $name';
        k.setzeDetektiv(start.dx, start.dy);
        game.update(1 / 60);
        expect(game.eigenePosition, start, reason: '$wo: zurück am Start');
        expect(game.tippen(game.worldToScreen(ziel.dx, ziel.dy)), isTrue, reason: '$wo: erreichbar');
        final weg = game.tippWeg ?? const <Offset>[];
        var von = game.eigenePosition;
        for (final p in weg) {
          expect(raster.freieBahn(von.dx, von.dy, p.dx, p.dy), isTrue, reason: '$wo: Strecke $von → $p streift Wand oder Möbel');
          von = p;
          strecken++;
        }
        final ende = weg.isEmpty ? game.eigenePosition : weg.last;
        var n = 0;
        while (game.tippWeg != null && n < _maxFrames) {
          game.update(1 / 60);
          n++;
          final p = game.eigenePosition;
          expect(raster.canStand(p.dx, p.dy, Tuning.playerRadius), isTrue, reason: '$wo: Frame $n bei $p in Wand oder Möbel');
        }
        frames += n;
        expect(game.tippWeg, isNull, reason: '$wo: nach 15 s nicht angekommen');
        expect(game.tippNeuGeplant, isFalse, reason: '$wo: hing fest und musste neu planen');
        final p = game.eigenePosition;
        expect(dist(p.dx, p.dy, ende.dx, ende.dy), lessThan(0.02), reason: '$wo: abgebrochen bei (${p.dx}, ${p.dy}) statt (${ende.dx}, ${ende.dy}) nach $n Frames');
        _aufraeumen(s);
      }
      expect(strecken, greaterThan(ziele.length), reason: 'es wurden Wege gelaufen');
      expect(frames, greaterThan(0));
    });
  }

  test('Joystick rastet auf Weltrichtungen und bleibt an der Wand stehen statt zu gleiten', () {
    final s = _sitzung('schlosskeller');
    final k = PartyKartenSession(s);
    addTearDown(k.dispose);
    final game = MordakteGame(session: k)..onGameResize(Vector2(390, 844));
    addTearDown(game.dispose);
    game.update(1 / 60);
    final raster = TileGrid(s.daten.szenario.map);
    // Bildschirm „hoch“ ist die Weltdiagonale (−1, −1): Die Figur läuft schräg,
    // bis sie anstößt, und rutscht dann nicht an der Wand entlang.
    game.stick = const Offset(0, -1);
    final spur = <Offset>[game.eigenePosition];
    for (var i = 0; i < 600; i++) {
      game.update(1 / 60);
      final p = game.eigenePosition;
      expect(raster.canStand(p.dx, p.dy, Tuning.playerRadius), isTrue, reason: 'Frame $i bei $p');
      spur.add(p);
    }
    for (var i = 1; i < spur.length; i++) {
      final d = spur[i] - spur[i - 1];
      if (d.distance < 1e-9) continue;
      expect((d.dx - d.dy).abs(), lessThan(1e-9), reason: 'Schritt $i: $d ist nicht diagonal (Gleiten)');
    }
    expect(spur.last, isNot(spur.first), reason: 'die Figur ist gelaufen');
    expect(spur[spur.length - 1], spur[spur.length - 30], reason: 'an der Wand steht sie still');
  });

  test('aus einer Wand rückt die Figur auf freien Boden, statt ohne Kollision zu laufen', () {
    final s = _sitzung('schlosskeller');
    final k = PartyKartenSession(s);
    addTearDown(k.dispose);
    final game = MordakteGame(session: k)..onGameResize(Vector2(390, 844));
    addTearDown(game.dispose);
    game.update(1 / 60);
    final raster = TileGrid(s.daten.szenario.map);
    final start = game.eigenePosition;
    // Die nächste Wandkachel nördlich des Starts.
    var wy = start.dy.floor();
    while (raster.walkable(start.dx.floor(), wy)) {
      wy--;
    }
    k.setzeDetektiv(start.dx.floor() + 0.5, wy + 0.5);
    game.update(1 / 60);
    expect(raster.canStand(game.eigenePosition.dx, game.eigenePosition.dy, Tuning.playerRadius), isFalse);
    game.stick = const Offset(0, -1);
    for (var i = 0; i < 120; i++) {
      game.update(1 / 60);
      final p = game.eigenePosition;
      expect(raster.canStand(p.dx, p.dy, Tuning.playerRadius), isTrue, reason: 'Frame $i bei $p');
    }
  });
}
