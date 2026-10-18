// M1: Gewischter Körperkreis (TileGrid.freieBahn) und weiche Personen-Hindernisse
// im A* (findPath extraBlockiert). lineOfSight, slide und canStand bleiben, wie
// sie sind; die Glättung der Wege benutzt nur noch freieBahn.
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:mordakte_core/mordakte_core.dart';
import 'package:test/test.dart';

/// Kleine Karte aus Zeilen; `T` ist ein Tisch (blockiert), sonst wie TileChar.
TileGrid _raster(List<String> zeilen) {
  final props = <PropDef>[];
  final rows = <String>[];
  for (var y = 0; y < zeilen.length; y++) {
    final z = zeilen[y];
    for (var x = 0; x < z.length; x++) {
      if (z[x] == 'T') props.add(PropDef(type: 'table', x: x, y: y));
    }
    rows.add(z.replaceAll('T', '.'));
  }
  final w = rows.fold(0, (m, r) => math.max(m, r.length));
  return TileGrid(MapDef(
    rows: rows,
    rooms: [RoomDef(id: 'raum', name: LText.empty, x: 0, y: 0, w: w, h: rows.length, floor: 'stone', lit: false, outdoor: false)],
    props: props,
    spawn: const [Pt(1, 1)],
    councilRoom: 'raum',
  ));
}

final _saal = _raster(const [
  '##########',
  '#........#',
  '#..T.....#',
  '#........#',
  '##########',
]);

void main() {
  group('freieBahn', () {
    test('frei im leeren Gang, auch entlang der Wand', () {
      expect(_saal.freieBahn(1.5, 1.5, 8.5, 1.5), isTrue);
      expect(_saal.freieBahn(1.5, 3.5, 8.5, 3.5), isTrue);
    });

    test('ein Möbel sperrt, obwohl die Sicht frei ist', () {
      expect(_saal.lineOfSight(1.5, 2.5, 6.5, 2.5), isTrue, reason: 'Sicht ignoriert Möbel (Kanon-Wahrnehmung)');
      expect(_saal.freieBahn(1.5, 2.5, 6.5, 2.5), isFalse);
    });

    test('die Körperbreite zählt: am Tisch vorbeistreifen ist nicht frei', () {
      // Mittellinie in Reihe 1, der Körper (r = 0,28) ragt in Reihe 2 hinein.
      expect(_saal.canStand(1.5, 1.85, Tuning.playerRadius), isTrue);
      expect(_saal.lineOfSight(1.5, 1.85, 6.5, 1.85), isTrue);
      expect(_saal.freieBahn(1.5, 1.85, 6.5, 1.85), isFalse);
      // Mit genug Abstand geht es.
      expect(_saal.freieBahn(1.5, 1.7, 6.5, 1.7), isTrue);
    });

    test('schräg über die Tischecke ist gesperrt, die Diagonale daneben frei', () {
      expect(_saal.freieBahn(2.5, 1.5, 4.5, 3.5), isFalse, reason: 'schneidet die Ecke von (3, 2)');
      expect(_saal.freieBahn(4.5, 1.5, 6.5, 3.5), isTrue);
    });

    test('Wände und Leere sperren', () {
      expect(_saal.freieBahn(1.5, 1.5, 1.5, -0.5), isFalse);
      expect(_saal.freieBahn(8.5, 1.5, 10.5, 1.5), isFalse);
    });

    test('ohne Länge gilt canStand', () {
      expect(_saal.freieBahn(1.5, 1.5, 1.5, 1.5), _saal.canStand(1.5, 1.5, Tuning.playerRadius));
      expect(_saal.freieBahn(3.5, 2.5, 3.5, 2.5), isFalse);
    });

    test('der Radius ist einstellbar', () {
      expect(_saal.freieBahn(1.5, 1.85, 6.5, 1.85, 0.1), isTrue);
    });

    test('auf jeder freien Strecke besteht jede Zwischenposition canStand (alle klassischen Karten)', () {
      final rnd = math.Random(7);
      var frei = 0;
      for (final f in Directory('../../content/scenarios').listSync().whereType<File>().where((f) => f.path.endsWith('.json'))) {
        final s = ScenarioDef.fromJson(jsonDecode(f.readAsStringSync()) as Map<String, dynamic>);
        final g = TileGrid(s.map);
        for (var n = 0; n < 4000; n++) {
          final ax = rnd.nextDouble() * g.width, ay = rnd.nextDouble() * g.height;
          final bx = ax + (rnd.nextDouble() - 0.5) * 6, by = ay + (rnd.nextDouble() - 0.5) * 6;
          if (!g.freieBahn(ax, ay, bx, by)) continue;
          frei++;
          for (var i = 0; i <= 200; i++) {
            final k = i / 200;
            expect(g.canStand(ax + (bx - ax) * k, ay + (by - ay) * k, Tuning.playerRadius), isTrue,
                reason: '${s.id}: ($ax, $ay) → ($bx, $by) bei $k');
          }
        }
      }
      expect(frei, greaterThan(1000), reason: 'genug freie Strecken geprüft');
    });
  });

  group('findPath mit Personen', () {
    final gang = _raster(const [
      '#########',
      '#.......#',
      '#.......#',
      '#.......#',
      '#########',
    ]);

    test('ohne Personen bleibt der Weg wie bisher', () {
      expect(gang.findPath(const Pt(1, 2), const Pt(7, 2), extraBlockiert: const {}), gang.findPath(const Pt(1, 2), const Pt(7, 2)));
    });

    test('eine Person im Weg wird umgangen, wenn es Platz gibt', () {
      final weg = gang.findPath(const Pt(1, 2), const Pt(7, 2), extraBlockiert: {const Pt(4, 2)})!;
      expect(weg.last, const Pt(7, 2));
      expect(weg, isNot(contains(const Pt(4, 2))));
    });

    test('weich: im engen Gang geht der Weg trotzdem durch', () {
      final eng = _raster(const [
        '#########',
        '#.......#',
        '#########',
      ]);
      final weg = eng.findPath(const Pt(1, 1), const Pt(7, 1), extraBlockiert: {const Pt(4, 1)});
      expect(weg, isNotNull);
      expect(weg, contains(const Pt(4, 1)));
    });

    test('das Ziel selbst darf belegt sein', () {
      final weg = gang.findPath(const Pt(1, 2), const Pt(5, 2), extraBlockiert: {const Pt(5, 2)})!;
      expect(weg.last, const Pt(5, 2));
      expect(weg, hasLength(4));
    });
  });
}
