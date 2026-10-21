import 'dart:math' as math;
import 'dart:ui';

import 'package:mordakte_core/mordakte_core.dart';

import 'palette.dart';

/// Eine zusammenhängende Bodenfläche (ein Raum plus zugeordnete Türkacheln).
class FloorGroup {
  final String key;
  final String style;
  final RoomDef? room;
  final List<Pt> tiles;
  final bool outdoor;

  FloorGroup({required this.key, required this.style, required this.room, required this.tiles, required this.outdoor});
}

/// Zeichnet Böden prozedural auf der Bodenebene (Canvas bereits mit
/// `Iso.applyGround` transformiert, Einheiten = Kacheln, absolute Welt-Koordinaten).
class FloorPainter {
  final ScenePalette pal;

  FloorPainter(this.pal);

  static const _black = Color(0xFF000000);
  static const _white = Color(0xFFFFFFFF);

  (Color, Color) colors(String style) {
    final p = pal;
    switch (style) {
      case 'parquet':
        return (p.floor, p.floorAlt);
      case 'planks':
        return (shade(p.floor, -0.04), p.floorAlt);
      case 'carpet':
        return (shade(mix(p.floorAlt, p.danger, 0.42), -0.18), p.trim);
      case 'checker':
        return (mix(p.text, p.floor, 0.38), mix(p.floorAlt, _black, 0.45));
      case 'tiles':
        return (mix(const Color(0xFFB9B4A8), p.floor, 0.22), mix(const Color(0xFF6F6A61), p.floorAlt, 0.2));
      case 'stone':
        return (mix(const Color(0xFF6A665F), p.floor, 0.2), mix(const Color(0xFF3E3A36), p.floorAlt, 0.2));
      case 'metal':
        return (mix(const Color(0xFF515962), p.floor, 0.1), mix(const Color(0xFF353B42), p.floorAlt, 0.1));
      case 'linoleum':
        return (mix(const Color(0xFF6E7A66), p.floor, 0.3), mix(const Color(0xFF545D4D), p.floorAlt, 0.3));
      case 'grass':
        return (mix(const Color(0xFF34502A), p.floor, 0.12), mix(const Color(0xFF233A1C), p.floorAlt, 0.12));
      case 'gravel':
        return (mix(const Color(0xFF79736A), p.floor, 0.2), mix(const Color(0xFF55504A), p.floorAlt, 0.2));
      case 'asphalt':
        return (mix(const Color(0xFF2F3136), p.floor, 0.08), mix(const Color(0xFF222428), p.floorAlt, 0.08));
      case 'snow':
        return (mix(const Color(0xFFDCE4EE), p.floor, 0.05), mix(const Color(0xFFAEBDD0), p.floorAlt, 0.05));
      default:
        return (p.floor, p.floorAlt);
    }
  }

  Path _area(List<Pt> tiles) {
    final path = Path();
    for (final t in tiles) {
      path.addRect(Rect.fromLTWH(t.x - 0.012, t.y - 0.012, 1.024, 1.024));
    }
    return path;
  }

  void paintGroup(Canvas c, FloorGroup g, {required Map<Pt, PropDef> props, required bool Function(int, int) isWall}) {
    if (g.tiles.isEmpty) return;
    final (base, alt) = colors(g.style);
    final rng = Rng(g.key.hashCode & 0x7fffffff);
    final area = _area(g.tiles);
    c.drawPath(area, Paint()..color = base);
    c.save();
    c.clipPath(area);
    switch (g.style) {
      case 'parquet':
        _parquet(c, g, base, alt, rng);
      case 'planks':
        _planks(c, g, base, alt, rng);
      case 'carpet':
        _carpet(c, g, base, alt, rng);
      case 'checker':
        _checker(c, g, base, alt, rng);
      case 'tiles':
        _tiles(c, g, base, alt, rng);
      case 'stone':
        _stone(c, g, base, alt, rng);
      case 'metal':
        _metal(c, g, base, alt, rng);
      case 'linoleum':
        _linoleum(c, g, base, alt, rng);
      case 'grass':
        _grass(c, g, base, alt, rng);
      case 'gravel':
        _gravel(c, g, base, alt, rng);
      case 'asphalt':
        _asphalt(c, g, base, alt, rng);
      case 'snow':
        _snow(c, g, base, alt, rng);
      default:
        _planks(c, g, base, alt, rng);
    }
    _ambientOcclusion(c, g, isWall, props);
    c.restore();
  }

  // --- Stile ---------------------------------------------------------------

  void _parquet(Canvas c, FloorGroup g, Color base, Color alt, Rng rng) {
    final line = Paint()
      ..color = withAlpha(shade(alt, -0.35), 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.012;
    final fill = Paint();
    for (final t in g.tiles) {
      for (var j = 0; j < 2; j++) {
        for (var i = 0; i < 2; i++) {
          final bx = t.x + i * 0.5, by = t.y + j * 0.5;
          final horiz = (t.x * 2 + i + t.y * 2 + j).isEven;
          for (var k = 0; k < 3; k++) {
            fill.color = mix(base, alt, 0.08 + rng.nextDouble() * 0.55);
            final r = horiz
                ? Rect.fromLTWH(bx, by + k / 6, 0.5, 1 / 6)
                : Rect.fromLTWH(bx + k / 6, by, 1 / 6, 0.5);
            c.drawRect(r, fill);
            c.drawRect(r, line);
          }
        }
      }
    }
    _sheen(c, g, 0.05);
  }

  void _planks(Canvas c, FloorGroup g, Color base, Color alt, Rng rng) {
    final b = _bounds(g);
    final joint = Paint()
      ..color = withAlpha(shade(alt, -0.45), 0.7)
      ..strokeWidth = 0.014
      ..style = PaintingStyle.stroke;
    final grain = Paint()
      ..color = withAlpha(shade(alt, -0.3), 0.18)
      ..strokeWidth = 0.008
      ..style = PaintingStyle.stroke;
    final fill = Paint();
    const pw = 0.25;
    for (var ry = b.top; ry < b.bottom - 1e-6; ry += pw) {
      var xs = b.left - rng.nextDouble() * 1.6;
      while (xs < b.right) {
        final len = 1.1 + rng.nextDouble() * 1.6;
        fill.color = mix(base, alt, rng.nextDouble() * 0.6);
        final r = Rect.fromLTWH(xs, ry, len, pw);
        c.drawRect(r, fill);
        c.drawLine(Offset(xs, ry), Offset(xs, ry + pw), joint);
        final gy = ry + pw * (0.3 + rng.nextDouble() * 0.4);
        c.drawLine(Offset(xs + 0.1, gy), Offset(xs + len * (0.4 + rng.nextDouble() * 0.5), gy), grain);
        xs += len;
      }
      c.drawLine(Offset(b.left, ry), Offset(b.right, ry), joint);
    }
    _sheen(c, g, 0.04);
  }

  void _carpet(Canvas c, FloorGroup g, Color base, Color alt, Rng rng) {
    final motif = Paint()..color = withAlpha(alt, 0.16);
    final dot = Paint()..color = withAlpha(alt, 0.22);
    for (final t in g.tiles) {
      final cx = t.x + 0.5, cy = t.y + 0.5;
      final path = Path()
        ..moveTo(cx, cy - 0.2)
        ..lineTo(cx + 0.2, cy)
        ..lineTo(cx, cy + 0.2)
        ..lineTo(cx - 0.2, cy)
        ..close();
      c.drawPath(path, motif);
      c.drawCircle(Offset(t.x.toDouble(), t.y.toDouble()), 0.035, dot);
    }
    final room = g.room;
    if (room != null && room.w >= 2 && room.h >= 2) {
      final r = Rect.fromLTWH(room.x.toDouble(), room.y.toDouble(), room.w.toDouble(), room.h.toDouble());
      c.drawRect(
        r,
        Paint()
          ..color = withAlpha(shade(base, -0.4), 0.55)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.36,
      );
      c.drawRect(
        r.deflate(0.24),
        Paint()
          ..color = withAlpha(alt, 0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.07,
      );
      c.drawRect(
        r.deflate(0.36),
        Paint()
          ..color = withAlpha(alt, 0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.02,
      );
    }
    // Flor-Struktur
    final fib = Paint()..color = withAlpha(_white, 0.025);
    for (final t in g.tiles) {
      for (var i = 0; i < 10; i++) {
        c.drawCircle(Offset(t.x + rng.nextDouble(), t.y + rng.nextDouble()), 0.04 + rng.nextDouble() * 0.06, fib);
      }
    }
  }

  void _checker(Canvas c, FloorGroup g, Color base, Color alt, Rng rng) {
    final dark = Paint()..color = alt;
    final vein = Paint()
      ..color = withAlpha(shade(base, -0.4), 0.13)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.01;
    final grout = Paint()
      ..color = withAlpha(_black, 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.01;
    for (final t in g.tiles) {
      final r = Rect.fromLTWH(t.x.toDouble(), t.y.toDouble(), 1, 1);
      if ((t.x + t.y).isOdd) {
        c.drawRect(r, dark);
      } else {
        final p = Path()
          ..moveTo(t.x + rng.nextDouble() * 0.3, t.y.toDouble())
          ..quadraticBezierTo(t.x + 0.3 + rng.nextDouble() * 0.4, t.y + 0.5, t.x + 0.6 + rng.nextDouble() * 0.4, t.y + 1.0);
        c.drawPath(p, vein);
      }
      c.drawRect(r, grout);
    }
    _sheen(c, g, 0.07);
  }

  void _tiles(Canvas c, FloorGroup g, Color base, Color alt, Rng rng) {
    final groutCol = mix(base, alt, 0.7);
    c.drawPath(_area(g.tiles), Paint()..color = groutCol);
    final fill = Paint();
    const n = 3;
    const s = 1 / n;
    for (final t in g.tiles) {
      for (var j = 0; j < n; j++) {
        for (var i = 0; i < n; i++) {
          fill.color = mix(base, _white, rng.nextDouble() * 0.08);
          c.drawRRect(
            RRect.fromRectAndRadius(Rect.fromLTWH(t.x + i * s + 0.018, t.y + j * s + 0.018, s - 0.036, s - 0.036), const Radius.circular(0.02)),
            fill,
          );
        }
      }
    }
    _sheen(c, g, 0.06);
  }

  void _stone(Canvas c, FloorGroup g, Color base, Color alt, Rng rng) {
    c.drawPath(_area(g.tiles), Paint()..color = shade(alt, -0.1));
    final fill = Paint();
    for (final t in g.tiles) {
      final rects = <Rect>[];
      final r = Rect.fromLTWH(t.x.toDouble(), t.y.toDouble(), 1, 1);
      final k = rng.nextInt(3);
      if (k == 0) {
        rects.add(r);
      } else if (k == 1) {
        final s = 0.35 + rng.nextDouble() * 0.3;
        rects
          ..add(Rect.fromLTWH(r.left, r.top, 1, s))
          ..add(Rect.fromLTWH(r.left, r.top + s, 1, 1 - s));
      } else {
        final s = 0.35 + rng.nextDouble() * 0.3;
        rects
          ..add(Rect.fromLTWH(r.left, r.top, s, 1))
          ..add(Rect.fromLTWH(r.left + s, r.top, 1 - s, 1));
      }
      for (final q in rects) {
        fill.color = mix(base, alt, rng.nextDouble() * 0.45);
        c.drawRRect(RRect.fromRectAndRadius(q.deflate(0.03), const Radius.circular(0.06)), fill);
        if (rng.chance(0.25)) {
          final crack = Paint()
            ..color = withAlpha(_black, 0.2)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.01;
          final p = Path()
            ..moveTo(q.left + q.width * rng.nextDouble(), q.top + 0.05)
            ..lineTo(q.left + q.width * rng.nextDouble(), q.center.dy)
            ..lineTo(q.left + q.width * rng.nextDouble(), q.bottom - 0.08);
          c.drawPath(p, crack);
        }
      }
    }
  }

  void _metal(Canvas c, FloorGroup g, Color base, Color alt, Rng rng) {
    final tread = Paint()..color = shade(base, 0.12);
    final tread2 = Paint()..color = withAlpha(_black, 0.25);
    for (final t in g.tiles) {
      for (var j = 0; j < 4; j++) {
        for (var i = 0; i < 4; i++) {
          final cx = t.x + (i + 0.5) / 4, cy = t.y + (j + 0.5) / 4;
          c.save();
          c.translate(cx, cy);
          c.rotate((i + j).isEven ? math.pi / 4 : -math.pi / 4);
          final r = Rect.fromCenter(center: Offset.zero, width: 0.15, height: 0.04);
          c.drawRRect(RRect.fromRectAndRadius(r.shift(const Offset(0.01, 0.012)), const Radius.circular(0.02)), tread2);
          c.drawRRect(RRect.fromRectAndRadius(r, const Radius.circular(0.02)), tread);
          c.restore();
        }
      }
    }
    final seam = Paint()
      ..color = withAlpha(_black, 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.02;
    final rivet = Paint()..color = shade(base, 0.25);
    for (final t in g.tiles) {
      if (t.x.isEven && t.y.isEven) {
        final r = Rect.fromLTWH(t.x.toDouble(), t.y.toDouble(), 2, 2);
        c.drawRect(r, seam);
        for (final o in [r.topLeft, r.topRight, r.bottomLeft, r.bottomRight]) {
          c.drawCircle(o + const Offset(0.08, 0.08), 0.025, rivet);
        }
      }
    }
    _sheen(c, g, 0.06);
  }

  void _linoleum(Canvas c, FloorGroup g, Color base, Color alt, Rng rng) {
    final altPaint = Paint()..color = mix(base, alt, 0.5);
    final speck = Paint();
    final line = Paint()
      ..color = withAlpha(_black, 0.14)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.012;
    for (final t in g.tiles) {
      final r = Rect.fromLTWH(t.x.toDouble(), t.y.toDouble(), 1, 1);
      if ((t.x + t.y).isOdd) c.drawRect(r, altPaint);
      c.drawRect(r, line);
      for (var i = 0; i < 7; i++) {
        speck.color = withAlpha(rng.chance(0.5) ? _white : _black, 0.12);
        c.drawCircle(Offset(t.x + rng.nextDouble(), t.y + rng.nextDouble()), 0.012 + rng.nextDouble() * 0.015, speck);
      }
    }
    _sheen(c, g, 0.05);
  }

  void _grass(Canvas c, FloorGroup g, Color base, Color alt, Rng rng) {
    final patch = Paint();
    for (final t in g.tiles) {
      if (rng.chance(0.55)) {
        patch.color = withAlpha(rng.chance(0.5) ? shade(base, 0.15) : alt, 0.35);
        c.drawOval(
          Rect.fromCenter(
            center: Offset(t.x + rng.nextDouble(), t.y + rng.nextDouble()),
            width: 0.6 + rng.nextDouble() * 1.0,
            height: 0.5 + rng.nextDouble() * 0.8,
          ),
          patch,
        );
      }
    }
    final blade = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.018
      ..strokeCap = StrokeCap.round;
    for (final t in g.tiles) {
      for (var i = 0; i < 22; i++) {
        final x = t.x + rng.nextDouble(), y = t.y + rng.nextDouble();
        final l = 0.05 + rng.nextDouble() * 0.07;
        blade.color = withAlpha(rng.chance(0.5) ? shade(base, 0.28) : shade(alt, -0.2), 0.6);
        // „Nach oben“ auf dem Bildschirm = Welt-Richtung (−1, −1).
        c.drawLine(Offset(x, y), Offset(x - l + rng.nextDouble() * 0.03, y - l), blade);
      }
      if (rng.chance(0.12)) {
        final fl = Paint()..color = rng.chance(0.5) ? const Color(0xCCE8E0C8) : const Color(0xCCD9B44A);
        c.drawCircle(Offset(t.x + rng.nextDouble(), t.y + rng.nextDouble()), 0.03, fl);
      }
    }
  }

  void _gravel(Canvas c, FloorGroup g, Color base, Color alt, Rng rng) {
    final p = Paint();
    for (final t in g.tiles) {
      for (var i = 0; i < 34; i++) {
        final r = 0.018 + rng.nextDouble() * 0.03;
        p.color = withAlpha(rng.chance(0.5) ? shade(base, 0.25) : shade(alt, -0.2), 0.75);
        c.drawOval(Rect.fromCenter(center: Offset(t.x + rng.nextDouble(), t.y + rng.nextDouble()), width: r * 2, height: r * 1.5), p);
      }
    }
  }

  void _asphalt(Canvas c, FloorGroup g, Color base, Color alt, Rng rng) {
    final p = Paint();
    for (final t in g.tiles) {
      for (var i = 0; i < 20; i++) {
        p.color = withAlpha(rng.chance(0.5) ? _white : _black, 0.08 + rng.nextDouble() * 0.08);
        c.drawCircle(Offset(t.x + rng.nextDouble(), t.y + rng.nextDouble()), 0.01 + rng.nextDouble() * 0.012, p);
      }
      if (rng.chance(0.08)) {
        p.color = withAlpha(_black, 0.22);
        c.drawOval(Rect.fromCenter(center: Offset(t.x + 0.5, t.y + 0.5), width: 0.7, height: 0.45), p);
      }
      if (rng.chance(0.1)) {
        final crack = Paint()
          ..color = withAlpha(_black, 0.35)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.015;
        final path = Path()..moveTo(t.x + rng.nextDouble(), t.y.toDouble());
        for (var k = 1; k <= 3; k++) {
          path.lineTo(t.x + rng.nextDouble(), t.y + k / 3);
        }
        c.drawPath(path, crack);
      }
    }
    final room = g.room;
    if (room != null && room.outdoor && room.w >= 4 && room.h >= 3) {
      final line = Paint()
        ..color = withAlpha(const Color(0xFFE8E4D6), 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.06;
      for (var x = room.x + 1; x < room.x + room.w; x += 2) {
        c.drawLine(Offset(x.toDouble(), room.y + 0.15), Offset(x.toDouble(), room.y + 1.7), line);
      }
    }
  }

  void _snow(Canvas c, FloorGroup g, Color base, Color alt, Rng rng) {
    final p = Paint();
    for (final t in g.tiles) {
      if (rng.chance(0.5)) {
        p.color = withAlpha(rng.chance(0.5) ? _white : alt, 0.3);
        c.drawOval(
          Rect.fromCenter(center: Offset(t.x + rng.nextDouble(), t.y + rng.nextDouble()), width: 0.8 + rng.nextDouble(), height: 0.5 + rng.nextDouble() * 0.6),
          p,
        );
      }
      p.color = const Color(0xDDFFFFFF);
      for (var i = 0; i < 4; i++) {
        c.drawCircle(Offset(t.x + rng.nextDouble(), t.y + rng.nextDouble()), 0.012, p);
      }
    }
  }

  // --- Licht & Schatten -----------------------------------------------------

  Rect _bounds(FloorGroup g) {
    var l = double.infinity, t = double.infinity, r = -double.infinity, b = -double.infinity;
    for (final p in g.tiles) {
      l = math.min(l, p.x.toDouble());
      t = math.min(t, p.y.toDouble());
      r = math.max(r, p.x + 1.0);
      b = math.max(b, p.y + 1.0);
    }
    return Rect.fromLTRB(l, t, r, b);
  }

  void _sheen(Canvas c, FloorGroup g, double a) {
    final b = _bounds(g);
    c.drawRect(
      b,
      Paint()
        ..shader = Gradient.linear(
          b.topLeft,
          b.bottomRight,
          [withAlpha(_white, a), withAlpha(_white, 0), withAlpha(_white, a * 0.6), withAlpha(_white, 0)],
          const [0.0, 0.35, 0.6, 1.0],
        ),
    );
  }

  void _ambientOcclusion(Canvas c, FloorGroup g, bool Function(int, int) isWall, Map<Pt, PropDef> props) {
    final tileSet = g.tiles.toSet();
    final aoCol = g.style == 'snow' ? const Color(0xFF2A3B5A) : _black;
    final strong = g.outdoor ? 0.22 : 0.42;
    for (final t in g.tiles) {
      final x = t.x.toDouble(), y = t.y.toDouble();
      if (isWall(t.x, t.y - 1) && !tileSet.contains(Pt(t.x, t.y - 1))) {
        c.drawRect(
          Rect.fromLTWH(x, y, 1, 0.5),
          Paint()..shader = Gradient.linear(Offset(x, y), Offset(x, y + 0.5), [withAlpha(aoCol, strong), withAlpha(aoCol, 0)]),
        );
      }
      if (isWall(t.x - 1, t.y) && !tileSet.contains(Pt(t.x - 1, t.y))) {
        c.drawRect(
          Rect.fromLTWH(x, y, 0.5, 1),
          Paint()..shader = Gradient.linear(Offset(x, y), Offset(x + 0.5, y), [withAlpha(aoCol, strong), withAlpha(aoCol, 0)]),
        );
      }
      if (isWall(t.x, t.y + 1)) {
        c.drawRect(
          Rect.fromLTWH(x, y + 0.75, 1, 0.25),
          Paint()..shader = Gradient.linear(Offset(x, y + 1), Offset(x, y + 0.75), [withAlpha(aoCol, strong * 0.45), withAlpha(aoCol, 0)]),
        );
      }
      if (isWall(t.x + 1, t.y)) {
        c.drawRect(
          Rect.fromLTWH(x + 0.75, y, 0.25, 1),
          Paint()..shader = Gradient.linear(Offset(x + 1, y), Offset(x + 0.75, y), [withAlpha(aoCol, strong * 0.45), withAlpha(aoCol, 0)]),
        );
      }
      final prop = props[t];
      if (prop != null && prop.spec.blocks) {
        final tall = prop.spec.height >= 1.2;
        final ctr = Offset(x + 0.55, y + 0.55);
        final rad = tall ? 0.85 : 0.68;
        c.drawCircle(
          ctr,
          rad,
          Paint()
            ..shader = Gradient.radial(ctr, rad, [withAlpha(_black, tall ? 0.5 : 0.4), withAlpha(_black, 0)]),
        );
      }
    }
  }

  // --- Dekor (begehbar) -----------------------------------------------------

  void paintDecor(Canvas c, PropDef p, Rng rng) {
    final x = p.x.toDouble(), y = p.y.toDouble();
    final custom = parseHex(p.color);
    switch (p.type) {
      case 'rug':
        final col = custom ?? mix(pal.danger, const Color(0xFF3A1420), 0.35);
        final r = Rect.fromLTWH(x - 0.35, y - 0.15, 1.7, 1.3);
        c.drawRRect(RRect.fromRectAndRadius(r.shift(const Offset(0.04, 0.04)), const Radius.circular(0.04)), Paint()..color = withAlpha(_black, 0.35));
        c.drawRRect(RRect.fromRectAndRadius(r, const Radius.circular(0.04)), Paint()..color = shade(col, -0.25));
        c.drawRect(r.deflate(0.1), Paint()..color = col);
        final gold = Paint()
          ..color = withAlpha(pal.trim, 0.75)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.035;
        c.drawRect(r.deflate(0.14), gold);
        c.drawRect(r.deflate(0.24), gold..strokeWidth = 0.015);
        final ctr = r.center;
        final med = Path()
          ..moveTo(ctr.dx, ctr.dy - 0.32)
          ..lineTo(ctr.dx + 0.42, ctr.dy)
          ..lineTo(ctr.dx, ctr.dy + 0.32)
          ..lineTo(ctr.dx - 0.42, ctr.dy)
          ..close();
        c.drawPath(med, Paint()..color = withAlpha(pal.trim, 0.35));
        c.drawPath(med, gold..strokeWidth = 0.02);
        c.drawCircle(ctr, 0.08, Paint()..color = withAlpha(pal.trim, 0.6));
        // Fransen
        final fr = Paint()
          ..color = withAlpha(const Color(0xFFE8DCC0), 0.7)
          ..strokeWidth = 0.012;
        for (var i = 0; i <= 12; i++) {
          final fy = r.top + r.height * i / 12;
          c.drawLine(Offset(r.left, fy), Offset(r.left - 0.07, fy), fr);
          c.drawLine(Offset(r.right, fy), Offset(r.right + 0.07, fy), fr);
        }
      case 'bloodstain':
        final col = custom ?? shade(pal.danger, -0.45);
        final paint = Paint()..color = withAlpha(col, 0.88);
        c.drawOval(Rect.fromCenter(center: Offset(x + 0.5, y + 0.5), width: 0.55, height: 0.42), paint);
        for (var i = 0; i < 9; i++) {
          final a = rng.nextDouble() * math.pi * 2;
          final d = 0.25 + rng.nextDouble() * 0.25;
          final rr = 0.02 + rng.nextDouble() * 0.06;
          c.drawCircle(Offset(x + 0.5 + math.cos(a) * d, y + 0.5 + math.sin(a) * d), rr, paint);
        }
        c.drawOval(
          Rect.fromCenter(center: Offset(x + 0.45, y + 0.45), width: 0.18, height: 0.1),
          Paint()..color = withAlpha(_white, 0.12),
        );
      case 'papers':
        for (var i = 0; i < 4; i++) {
          c.save();
          c.translate(x + 0.25 + rng.nextDouble() * 0.5, y + 0.25 + rng.nextDouble() * 0.5);
          c.rotate(rng.nextDouble() * math.pi);
          final r = Rect.fromCenter(center: Offset.zero, width: 0.26, height: 0.34);
          c.drawRect(r.shift(const Offset(0.015, 0.015)), Paint()..color = withAlpha(_black, 0.3));
          c.drawRect(r, Paint()..color = custom ?? const Color(0xFFE9E2CF));
          final ln = Paint()
            ..color = withAlpha(const Color(0xFF3A3A48), 0.45)
            ..strokeWidth = 0.01;
          for (var k = 0; k < 5; k++) {
            final ly = r.top + 0.06 + k * 0.05;
            c.drawLine(Offset(r.left + 0.04, ly), Offset(r.right - 0.04 - (k == 4 ? 0.08 : 0), ly), ln);
          }
          c.restore();
        }
      case 'party_ascheneimer':
        // Von oben: Blechrand, graue Asche und der umgelegte Henkel, alles flach.
        final ctr = Offset(x + 0.5, y + 0.5);
        c.drawCircle(ctr.translate(0.03, 0.03), 0.22, Paint()..color = withAlpha(_black, 0.3));
        c.drawCircle(ctr, 0.2, Paint()..color = const Color(0xFF55575C));
        c.drawCircle(ctr, 0.16, Paint()..color = const Color(0xFF8C8A86));
        for (var i = 0; i < 5; i++) {
          final a = rng.nextDouble() * math.pi * 2;
          final d = rng.nextDouble() * 0.1;
          c.drawCircle(ctr.translate(math.cos(a) * d, math.sin(a) * d), 0.02 + rng.nextDouble() * 0.02, Paint()..color = const Color(0xFF6E6C69));
        }
        c.drawArc(
          Rect.fromCircle(center: ctr, radius: 0.26),
          math.pi * 0.15,
          math.pi * 0.7,
          false,
          Paint()
            ..color = const Color(0xFF3A3B3F)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.025,
        );
      case 'puddle':
        final col = custom ?? mix(const Color(0xFF243246), pal.fog, 0.3);
        final path = Path()
          ..addOval(Rect.fromCenter(center: Offset(x + 0.45, y + 0.5), width: 0.8, height: 0.55))
          ..addOval(Rect.fromCenter(center: Offset(x + 0.68, y + 0.62), width: 0.45, height: 0.4))
          ..addOval(Rect.fromCenter(center: Offset(x + 0.3, y + 0.3), width: 0.35, height: 0.3));
        c.drawPath(path, Paint()..color = withAlpha(col, 0.85));
        c.drawPath(
          path,
          Paint()
            ..shader = Gradient.linear(Offset(x, y), Offset(x + 1, y + 1), [withAlpha(_white, 0.22), withAlpha(_white, 0), withAlpha(_white, 0.12)], const [0, 0.5, 1]),
        );
        c.drawLine(
          Offset(x + 0.2, y + 0.45),
          Offset(x + 0.55, y + 0.3),
          Paint()
            ..color = withAlpha(_white, 0.3)
            ..strokeWidth = 0.02
            ..strokeCap = StrokeCap.round,
        );
    }
  }
}
