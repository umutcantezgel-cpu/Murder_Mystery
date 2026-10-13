import 'dart:math' as math;
import 'dart:ui';

import 'package:mordakte_core/mordakte_core.dart';

import '../iso_math.dart';
import 'floor_painter.dart';
import 'kulisse.dart';
import 'palette.dart';
import 'prop_painter.dart';
import 'wall_painter.dart';

enum StaticKind { wall, door, prop }

/// Ein gecachtes, statisches Objekt der Szene (Wand, Tür, Prop).
class StaticDrawable {
  final StaticKind kind;
  final int x, y;
  final double depth;
  final Rect bounds;

  /// Höhe für Verdeckungstest.
  final double height;

  /// Wird halbtransparent, wenn es den eigenen Spieler verdeckt.
  final bool tall;
  final PropDef? prop;
  final bool east;
  final WallInfo? wall;
  final DoorInfo? door;
  Picture? picture;

  /// Niedrige Variante (Cutaway), wenn die Wand den Raum des Spielers nach
  /// Süden/Osten begrenzt.
  Picture? lowPicture;

  /// Räume, deren Süd-/Ostgrenze dieses Objekt ist.
  Set<String> backRooms = const {};

  /// 0 = hoch, 1 = abgesenkt (weich überblendet).
  double cut = 0;

  /// Aktuelle Deckkraft (weich überblendet).
  double alpha = 1;

  StaticDrawable({
    required this.kind,
    required this.x,
    required this.y,
    required this.depth,
    required this.bounds,
    required this.height,
    required this.tall,
    this.prop,
    this.east = false,
    this.wall,
    this.door,
    this.picture,
  });

  /// Grober Silhouetten-Test gegen ein Bildschirm-Rechteck (Spielerfigur).
  bool occludes(Rect r) {
    if (!bounds.overlaps(r)) return false;
    final cx = Iso.sx(x + 0.5, y + 0.5);
    final top = (x + y) * Iso.halfH - height * Iso.unitZ;
    final bottom = (x + y + 2) * Iso.halfH;
    for (final px in [r.left + 6, r.center.dx, r.right - 6]) {
      final dx = (px - cx).abs();
      if (dx >= Iso.halfW) continue;
      final t = top + dx * 0.5, b = bottom - dx * 0.5;
      if (b > r.top && t < r.bottom) return true;
    }
    return false;
  }
}

/// Bodenbild eines Raums.
class FloorTile {
  final Rect dst;
  final Image? image;
  final Picture? picture;
  final RoomDef? room;

  FloorTile(this.dst, this.image, this.picture, this.room);
}

/// Alles Statische eines Szenarios: Böden (als Bild), Wände, Türen, Props (als Picture).
class StaticScene {
  final ScenarioDef scenario;
  final ScenePalette pal;
  final WallPainter wallPainter;
  final PropPainter propPainter;
  final List<FloorTile> floors = [];
  final List<StaticDrawable> drawables = [];
  final List<StaticDrawable> doors = [];
  final List<PropDef> lightProps = [];
  final Map<Pt, StaticDrawable> propAt = {};
  Set<Pt> _openDoors = {};
  late final Rect worldBounds;

  /// Umgebung jenseits der Karte (nur Darstellung); `null` ohne Kulisse.
  Kulisse? kulisse;

  StaticScene._(this.scenario, this.pal, this.wallPainter, this.propPainter);

  static const decorTypes = {'rug', 'bloodstain', 'papers', 'puddle'};

  factory StaticScene.build(ScenarioDef s, {double resolution = 1.6}) {
    final pal = ScenePalette.fromTheme(s.theme);
    final scene = StaticScene._(s, pal, WallPainter(pal), PropPainter(pal, weather: s.theme.weather));
    scene._build(resolution);
    return scene;
  }

  MapDef get map => scenario.map;

  bool _isWall(int x, int y) {
    final c = map.charAt(x, y);
    return c == TileChar.wall || c == TileChar.window;
  }

  bool _floorLike(int x, int y) {
    final c = map.charAt(x, y);
    return c == TileChar.floor || c == TileChar.door || c == TileChar.lockedDoor;
  }

  bool _isDoor(int x, int y) {
    final c = map.charAt(x, y);
    return c == TileChar.door || c == TileChar.lockedDoor;
  }

  void _build(double resolution) {
    final w = map.width, h = map.height;
    worldBounds = Rect.fromLTRB(
      -h * Iso.halfW - 64,
      -kWallTall * Iso.unitZ - 64,
      w * Iso.halfW + 64,
      (w + h) * Iso.halfH + 64,
    );
    _buildFloors(resolution);
    kulisse = Kulisse.baue(scenario, pal, propPainter);
    // Wände. Hohe Wände, die einen Raum zusätzlich nach Süden/Osten begrenzen,
    // bekommen eine niedrige Variante (Cutaway, solange der Spieler dort ist).
    bool tallAt(int x, int y) => _isWall(x, y) && (_floorLike(x, y + 1) || _floorLike(x + 1, y) || _floorLike(x + 1, y + 1));
    bool cuttable(int x, int y) => tallAt(x, y) && _backRooms(x, y).isNotEmpty;
    for (var y = 0; y < h; y++) {
      for (var x = 0; x < w; x++) {
        if (_isWall(x, y)) {
          final tall = tallAt(x, y);
          final info = WallInfo(
            x: x,
            y: y,
            tall: tall,
            window: map.charAt(x, y) == TileChar.window,
            // Seiten zu absenkbaren Nachbarn mitzeichnen (sonst Loch im Cutaway).
            south: !_isWall(x, y + 1) || (tall && cuttable(x, y + 1)),
            east: !_isWall(x + 1, y) || (tall && cuttable(x + 1, y)),
            southFloor: _floorLike(x, y + 1),
            eastFloor: _floorLike(x + 1, y),
            southOutdoor: map.roomAt(x, y + 1)?.outdoor ?? false,
            eastOutdoor: map.roomAt(x + 1, y)?.outdoor ?? false,
          );
          final d = StaticDrawable(
            kind: StaticKind.wall,
            x: x,
            y: y,
            depth: x + y + 1.0,
            bounds: Iso.tileBounds(x, y, info.height, 2),
            height: info.height,
            tall: tall,
            wall: info,
          );
          d.picture = _record(d.bounds, (c) => wallPainter.paintWall(c, info));
          if (tall) {
            final back = _backRooms(x, y);
            if (back.isNotEmpty) {
              final low = WallInfo(
                x: x,
                y: y,
                tall: false,
                window: info.window,
                south: info.south,
                east: info.east,
                southFloor: info.southFloor,
                eastFloor: info.eastFloor,
                southOutdoor: info.southOutdoor,
                eastOutdoor: info.eastOutdoor,
              );
              d.backRooms = back;
              d.lowPicture = _record(d.bounds, (c) => wallPainter.paintWall(c, low));
            }
          }
          drawables.add(d);
        } else if (_isDoor(x, y)) {
          final alongX = _isWall(x - 1, y) || _isWall(x + 1, y) || !(_isWall(x, y - 1) || _isWall(x, y + 1));
          bool tallAt(int ax, int ay) => _isWall(ax, ay) && (_floorLike(ax, ay + 1) || _floorLike(ax + 1, ay) || _floorLike(ax + 1, ay + 1));
          final tall = alongX ? (tallAt(x - 1, y) || tallAt(x + 1, y)) : (tallAt(x, y - 1) || tallAt(x, y + 1));
          final info = DoorInfo(x: x, y: y, alongX: alongX, tall: tall, locked: map.charAt(x, y) == TileChar.lockedDoor);
          final d = StaticDrawable(
            kind: StaticKind.door,
            x: x,
            y: y,
            depth: x + y + 1.0,
            bounds: Iso.tileBounds(x, y, tall ? kWallTall : 0.7, 4),
            height: tall ? kWallTall : 0.6,
            tall: tall,
            door: info,
          );
          d.picture = _record(d.bounds, (c) => wallPainter.paintDoor(c, info, open: false));
          if (tall) {
            final back = _backRooms(x, y, door: true);
            if (back.isNotEmpty) {
              d.backRooms = back;
              d.lowPicture = _record(d.bounds, (c) => wallPainter.paintDoor(c, _lowDoor(info), open: false));
            }
          }
          drawables.add(d);
          doors.add(d);
        }
      }
    }
    // Props
    for (final p in map.props) {
      if (decorTypes.contains(p.type)) continue;
      final spec = p.spec;
      if (!spec.blocks && spec.height <= 0) continue;
      final east = _isWall(p.x - 1, p.y) && !_isWall(p.x, p.y - 1);
      final hgt = math.max(0.3, spec.height);
      final extra = switch (p.type) {
        'tree' => 0.4,
        'car' => 0.2,
        'clock' => 0.2,
        _ => 0.15,
      };
      final d = StaticDrawable(
        kind: StaticKind.prop,
        x: p.x,
        y: p.y,
        depth: p.x + p.y + 1.0,
        bounds: Iso.tileBounds(p.x, p.y, hgt + extra, p.type == 'car' || p.type == 'tree' ? 18 : 8),
        height: hgt,
        tall: spec.tall,
        prop: p,
        east: east,
      );
      d.picture = _record(d.bounds, (c) => propPainter.paint(c, p, east: east));
      drawables.add(d);
      propAt[Pt(p.x, p.y)] = d;
      if (spec.light) lightProps.add(p);
    }
  }

  DoorInfo _lowDoor(DoorInfo d) => DoorInfo(x: d.x, y: d.y, alongX: d.alongX, tall: false, locked: d.locked);

  /// Räume nördlich/westlich (bzw. bei Türen: auf der Rückseite) dieser Kachel.
  Set<String> _backRooms(int x, int y, {bool door = false}) {
    final out = <String>{};
    final cand = door
        ? (_isWall(x - 1, y) || _isWall(x + 1, y) ? [(0, -1)] : [(-1, 0)])
        : [(0, -1), (-1, 0), (-1, -1)];
    for (final (dx, dy) in cand) {
      final nx = x + dx, ny = y + dy;
      if (!_floorLike(nx, ny) || _isDoor(nx, ny)) continue;
      final r = map.roomAt(nx, ny);
      if (r != null) out.add(r.id);
    }
    return out;
  }

  Picture _record(Rect bounds, void Function(Canvas) draw) {
    final rec = PictureRecorder();
    final c = Canvas(rec, bounds);
    draw(c);
    return rec.endRecording();
  }

  void _buildFloors(double resolution) {
    final groups = <String, FloorGroup>{};
    final w = map.width, h = map.height;
    RoomDef? neighbourRoom(int x, int y) {
      for (final (dx, dy) in [(0, -1), (-1, 0), (0, 1), (1, 0)]) {
        final nx = x + dx, ny = y + dy;
        if (!_floorLike(nx, ny) || _isDoor(nx, ny)) continue;
        final r = map.roomAt(nx, ny);
        if (r != null) return r;
      }
      return null;
    }

    for (var y = 0; y < h; y++) {
      for (var x = 0; x < w; x++) {
        if (!_floorLike(x, y)) continue;
        var room = _isDoor(x, y) ? null : map.roomAt(x, y);
        room ??= neighbourRoom(x, y) ?? map.roomAt(x, y);
        final key = room?.id ?? '_misc';
        final g = groups.putIfAbsent(
          key,
          () => FloorGroup(
            key: key,
            style: floorStyles.contains(room?.floor) ? room!.floor : 'planks',
            room: room,
            tiles: [],
            outdoor: room?.outdoor ?? false,
          ),
        );
        g.tiles.add(Pt(x, y));
      }
    }
    final painter = FloorPainter(pal);
    final propMap = {for (final p in map.props) Pt(p.x, p.y): p};
    for (final g in groups.values) {
      var l = double.infinity, t = double.infinity, r = -double.infinity, b = -double.infinity;
      final tileSet = g.tiles.toSet();
      for (final p in g.tiles) {
        l = math.min(l, (p.x - p.y - 1) * Iso.halfW);
        r = math.max(r, (p.x - p.y + 1) * Iso.halfW);
        t = math.min(t, (p.x + p.y) * Iso.halfH);
        b = math.max(b, (p.x + p.y + 2) * Iso.halfH);
      }
      final bounds = Rect.fromLTRB(l, t, r, b).inflate(28);
      final rec = PictureRecorder();
      final c = Canvas(rec);
      var res = resolution;
      final maxDim = math.max(bounds.width, bounds.height) * res;
      if (maxDim > 4096) res *= 4096 / maxDim;
      c.scale(res);
      c.translate(-bounds.left, -bounds.top);
      Iso.applyGround(c);
      painter.paintGroup(c, g, props: propMap, isWall: _isWall);
      for (final p in map.props) {
        if (decorTypes.contains(p.type) && tileSet.contains(Pt(p.x, p.y))) {
          painter.paintDecor(c, p, Rng(p.x * 31 + p.y * 977 + 5));
        }
      }
      final pic = rec.endRecording();
      Image? img;
      try {
        img = pic.toImageSync((bounds.width * res).ceil(), (bounds.height * res).ceil());
      } catch (_) {
        img = null;
      }
      if (img != null) {
        pic.dispose();
        floors.add(FloorTile(bounds, img, null, g.room));
      } else {
        // Fallback: Picture direkt (mit Auflösungs-Skalierung rückgängig).
        final rec2 = PictureRecorder();
        final c2 = Canvas(rec2);
        c2.scale(1 / res);
        c2.translate(bounds.left * res, bounds.top * res);
        c2.drawPicture(pic);
        pic.dispose();
        floors.add(FloorTile(bounds, null, rec2.endRecording(), g.room));
      }
    }
  }

  /// Verschlossene Türen öffnen/schließen (Pictures neu aufnehmen).
  void setOpenDoors(Set<Pt> open) {
    if (open.length == _openDoors.length && open.containsAll(_openDoors)) return;
    _openDoors = Set.of(open);
    for (final d in doors) {
      final info = d.door!;
      if (!info.locked) continue;
      final isOpen = _openDoors.contains(Pt(d.x, d.y));
      d.picture?.dispose();
      d.picture = _record(d.bounds, (c) => wallPainter.paintDoor(c, info, open: isOpen));
      if (d.lowPicture != null) {
        d.lowPicture!.dispose();
        d.lowPicture = _record(d.bounds, (c) => wallPainter.paintDoor(c, _lowDoor(info), open: isOpen));
      }
    }
  }

  void dispose() {
    kulisse?.dispose();
    for (final f in floors) {
      f.image?.dispose();
      f.picture?.dispose();
    }
    for (final d in drawables) {
      d.picture?.dispose();
      d.lowPicture?.dispose();
    }
  }
}
