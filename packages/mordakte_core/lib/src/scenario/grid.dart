import 'dart:math' as math;

import '../model/rules.dart';
import '../util/geom.dart';
import 'catalog.dart';
import 'scenario_def.dart';

/// Begehbarkeit, Kollision und Sichtlinie auf dem Kachelraster.
///
/// Positionen sind kontinuierlich in Kachel-Einheiten: Kachel (x, y) deckt
/// [x, x+1) × [y, y+1) ab, ihr Mittelpunkt ist (x + 0.5, y + 0.5).
/// Client (Vorhersage) und Runtime (Prüfung) benutzen denselben Code.
class TileGrid {
  final MapDef map;
  final int width;
  final int height;
  late final List<bool> _blocked;
  late final List<bool> _sightBlocked;
  final Set<Pt> _openDoors = {};

  TileGrid(this.map)
      : width = map.width,
        height = map.height {
    _blocked = List.filled(width * height, true);
    _sightBlocked = List.filled(width * height, true);
    for (var y = 0; y < height; y++) {
      for (var x = 0; x < width; x++) {
        _recompute(x, y);
      }
    }
  }

  bool inBounds(int x, int y) => x >= 0 && y >= 0 && x < width && y < height;

  String charAt(int x, int y) => map.charAt(x, y);

  bool isWall(int x, int y) {
    final c = charAt(x, y);
    return c == TileChar.wall || c == TileChar.window;
  }

  bool isDoor(int x, int y) {
    final c = charAt(x, y);
    return c == TileChar.door || c == TileChar.lockedDoor;
  }

  bool isLockedDoor(int x, int y) => charAt(x, y) == TileChar.lockedDoor && !_openDoors.contains(Pt(x, y));

  bool isFloorLike(int x, int y) {
    final c = charAt(x, y);
    return c == TileChar.floor || c == TileChar.door || c == TileChar.lockedDoor;
  }

  /// Blockiert Bewegung (Wand, Leere, verschlossene Tür, blockierendes Prop).
  bool blocked(int x, int y) => !inBounds(x, y) || _blocked[y * width + x];

  /// Blockiert Sicht (Wand, Leere, verschlossene Tür).
  bool blocksSight(int x, int y) => !inBounds(x, y) || _sightBlocked[y * width + x];

  bool walkable(int x, int y) => !blocked(x, y);

  Set<Pt> get openDoors => Set.unmodifiable(_openDoors);

  void openDoor(Pt p) {
    if (_openDoors.add(p) && inBounds(p.x, p.y)) _recompute(p.x, p.y);
  }

  void setOpenDoors(Iterable<Pt> doors) {
    final changed = {..._openDoors, ...doors};
    _openDoors
      ..clear()
      ..addAll(doors);
    for (final p in changed) {
      if (inBounds(p.x, p.y)) _recompute(p.x, p.y);
    }
  }

  void _recompute(int x, int y) {
    final c = charAt(x, y);
    final floorLike = c == TileChar.floor || c == TileChar.door || (c == TileChar.lockedDoor && _openDoors.contains(Pt(x, y)));
    final prop = map.propAt[Pt(x, y)];
    _blocked[y * width + x] = !floorLike || (prop != null && prop.spec.blocks);
    _sightBlocked[y * width + x] = !floorLike;
  }

  RoomDef? roomAtPos(double x, double y) => map.roomAt(x.floor(), y.floor());

  /// Passt ein Kreis mit Radius [r] an Position (x, y)?
  bool canStand(double x, double y, [double r = 0.28]) {
    final x0 = (x - r).floor(), x1 = (x + r).floor();
    final y0 = (y - r).floor(), y1 = (y + r).floor();
    for (var ty = y0; ty <= y1; ty++) {
      for (var tx = x0; tx <= x1; tx++) {
        if (blocked(tx, ty)) return false;
      }
    }
    return true;
  }

  /// Bewegt von (x, y) um (dx, dy) mit Gleiten an Wänden. Gibt die neue Position zurück.
  (double, double) slide(double x, double y, double dx, double dy, [double r = 0.28]) {
    // In kleinen Schritten, damit schnelle Bewegungen nicht durch Ecken tunneln.
    final len = math.sqrt(dx * dx + dy * dy);
    final steps = math.max(1, (len / 0.2).ceil());
    final sx = dx / steps, sy = dy / steps;
    var cx = x, cy = y;
    for (var i = 0; i < steps; i++) {
      if (canStand(cx + sx, cy, r)) cx += sx;
      if (canStand(cx, cy + sy, r)) cy += sy;
    }
    return (cx, cy);
  }

  /// Freie Sichtlinie zwischen zwei Punkten (nur Wände/Türen blockieren).
  bool lineOfSight(double ax, double ay, double bx, double by) {
    var x = ax.floor(), y = ay.floor();
    final tx = bx.floor(), ty = by.floor();
    final dx = bx - ax, dy = by - ay;
    final stepX = dx > 0 ? 1 : -1, stepY = dy > 0 ? 1 : -1;
    final tDeltaX = dx == 0 ? double.infinity : (1 / dx).abs();
    final tDeltaY = dy == 0 ? double.infinity : (1 / dy).abs();
    var tMaxX = dx == 0 ? double.infinity : ((dx > 0 ? (x + 1 - ax) : (ax - x)) * tDeltaX);
    var tMaxY = dy == 0 ? double.infinity : ((dy > 0 ? (y + 1 - ay) : (ay - y)) * tDeltaY);
    var guard = 0;
    while ((x != tx || y != ty) && guard++ < 256) {
      if (tMaxX < tMaxY) {
        tMaxX += tDeltaX;
        x += stepX;
      } else {
        tMaxY += tDeltaY;
        y += stepY;
      }
      if (x == tx && y == ty) break;
      if (blocksSight(x, y)) return false;
    }
    return true;
  }

  /// Kommt der Körper (Radius [r]) auf der Strecke von (ax, ay) nach (bx, by)
  /// durch? Anders als [lineOfSight] zählen Requisiten und die Breite der
  /// Figur: ein gewischter Kreis statt eines Strahls. Geprüft wird in Schritten
  /// von höchstens 0,1 Kacheln, je Schritt der Kasten um beide Proben. So
  /// besteht auch jede Zwischenposition [canStand], selbst an Möbelecken.
  bool freieBahn(double ax, double ay, double bx, double by, [double r = Tuning.playerRadius]) {
    final schritte = math.max(1, (dist(ax, ay, bx, by) / 0.1).ceil());
    var vx = ax, vy = ay;
    for (var i = 1; i <= schritte; i++) {
      final k = i / schritte;
      final nx = ax + (bx - ax) * k, ny = ay + (by - ay) * k;
      if (!_kastenFrei(math.min(vx, nx) - r, math.min(vy, ny) - r, math.max(vx, nx) + r, math.max(vy, ny) + r)) return false;
      vx = nx;
      vy = ny;
    }
    return true;
  }

  /// Keine blockierte Kachel unter dem Kasten [x0, x1] × [y0, y1] (wie [canStand]).
  bool _kastenFrei(double x0, double y0, double x1, double y1) {
    for (var ty = y0.floor(); ty <= y1.floor(); ty++) {
      for (var tx = x0.floor(); tx <= x1.floor(); tx++) {
        if (blocked(tx, ty)) return false;
      }
    }
    return true;
  }

  /// Aufschlag für eine Kachel aus `extraBlockiert` (Personen). Weich: Der Weg
  /// geht außen herum, solange der Umweg kürzer ist; ein Ziel wird dadurch nie
  /// unerreichbar.
  static const _personenAufschlag = 6.0;

  /// A* über begehbare Kacheln (4er-Nachbarschaft + Diagonalen ohne Eckenschneiden).
  /// Liefert Kachelpfad ohne Start, oder `null`. Kacheln in [extraBlockiert]
  /// (z. B. unter Personen) sind weiche Hindernisse mit Aufschlag, keine Wände.
  List<Pt>? findPath(Pt from, Pt to, {int maxNodes = 4000, Set<Pt> extraBlockiert = const {}}) {
    if (from == to) return [];
    if (blocked(to.x, to.y)) return null;
    final open = _MinHeap();
    final g = <Pt, double>{from: 0};
    final came = <Pt, Pt>{};
    open.push(from, _h(from, to));
    final closed = <Pt>{};
    var expanded = 0;
    while (open.isNotEmpty) {
      final cur = open.pop();
      if (cur == to) {
        final path = <Pt>[cur];
        var p = cur;
        while (came.containsKey(p)) {
          p = came[p]!;
          if (p != from) path.add(p);
        }
        return path.reversed.toList();
      }
      if (!closed.add(cur)) continue;
      if (++expanded > maxNodes) return null;
      for (final d in _dirs) {
        final nx = cur.x + d.$1, ny = cur.y + d.$2;
        if (blocked(nx, ny)) continue;
        final diag = d.$1 != 0 && d.$2 != 0;
        if (diag && (blocked(cur.x + d.$1, cur.y) || blocked(cur.x, cur.y + d.$2))) continue;
        final n = Pt(nx, ny);
        if (closed.contains(n)) continue;
        var ng = g[cur]! + (diag ? 1.4142 : 1.0);
        if (extraBlockiert.isNotEmpty && n != to && extraBlockiert.contains(n)) ng += _personenAufschlag;
        if (ng < (g[n] ?? double.infinity)) {
          g[n] = ng;
          came[n] = cur;
          open.push(n, ng + _h(n, to));
        }
      }
    }
    return null;
  }

  /// Nächste begehbare Kachel zu (x, y) (Spirale), z. B. für NPC-/Prop-Ziele.
  Pt? nearestWalkable(int x, int y, {int maxRadius = 4}) {
    if (walkable(x, y)) return Pt(x, y);
    for (var r = 1; r <= maxRadius; r++) {
      Pt? best;
      var bestD = double.infinity;
      for (var dy = -r; dy <= r; dy++) {
        for (var dx = -r; dx <= r; dx++) {
          if (dx.abs() != r && dy.abs() != r) continue;
          if (walkable(x + dx, y + dy)) {
            final d = (dx * dx + dy * dy).toDouble();
            if (d < bestD) {
              bestD = d;
              best = Pt(x + dx, y + dy);
            }
          }
        }
      }
      if (best != null) return best;
    }
    return null;
  }

  static double _h(Pt a, Pt b) {
    final dx = (a.x - b.x).abs(), dy = (a.y - b.y).abs();
    return (dx + dy) + (1.4142 - 2) * math.min(dx, dy);
  }

  static const _dirs = [(1, 0), (-1, 0), (0, 1), (0, -1), (1, 1), (1, -1), (-1, 1), (-1, -1)];
}

class _MinHeap {
  final _items = <(Pt, double)>[];

  bool get isNotEmpty => _items.isNotEmpty;

  void push(Pt p, double prio) {
    _items.add((p, prio));
    var i = _items.length - 1;
    while (i > 0) {
      final parent = (i - 1) >> 1;
      if (_items[parent].$2 <= _items[i].$2) break;
      final t = _items[parent];
      _items[parent] = _items[i];
      _items[i] = t;
      i = parent;
    }
  }

  Pt pop() {
    final top = _items.first.$1;
    final last = _items.removeLast();
    if (_items.isNotEmpty) {
      _items[0] = last;
      var i = 0;
      while (true) {
        final l = 2 * i + 1, r = l + 1;
        var m = i;
        if (l < _items.length && _items[l].$2 < _items[m].$2) m = l;
        if (r < _items.length && _items[r].$2 < _items[m].$2) m = r;
        if (m == i) break;
        final t = _items[m];
        _items[m] = _items[i];
        _items[i] = t;
        i = m;
      }
    }
    return top;
  }
}
