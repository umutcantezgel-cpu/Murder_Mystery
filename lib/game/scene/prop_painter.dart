import 'dart:math' as math;
import 'dart:ui';

import 'package:mordakte_core/mordakte_core.dart';

import 'iso_pen.dart';
import 'palette.dart';
import 'party_props.dart';

/// Lichtquelle eines Props.
class PropLight {
  final double z;
  final Color color;
  final double radius;

  /// Flackern 0..1.
  final double flicker;

  const PropLight(this.z, this.color, this.radius, {this.flicker = 0});
}

/// Code-gezeichnete Möbel und Objekte. [paint] erzeugt den statischen Teil
/// (wird als Picture gecacht), [paintDynamic] animierte Teile (Flammen, Neon …).
class PropPainter {
  final ScenePalette pal;
  final String weather;

  PropPainter(this.pal, {this.weather = 'none'}) : _party = PartyProps(pal);

  final PartyProps _party;

  static const _black = Color(0xFF000000);
  static const _white = Color(0xFFFFFFFF);
  static const _brass = Color(0xFFC8A24A);
  static const _darkMetal = Color(0xFF2B2C31);

  /// Haben animierte Teile.
  static const dynamicTypes = {'fireplace', 'candles', 'tv', 'vending', 'neon_sign', 'clock', 'lamp'};

  /// Höhe des oberen Rands (für Hotspot-Marker auf Props).
  static double topZ(PropDef p) {
    final party = PartyProps.topZ(p.type);
    if (party != null) return party;
    switch (p.type) {
      case 'table':
        return 0.45;
      case 'desk':
        return 0.5;
      case 'counter':
        return 0.61;
      case 'bed':
        return 0.4;
      case 'pool_table':
        return 0.45;
      default:
        return p.spec.height;
    }
  }

  PropLight? light(PropDef p) {
    final custom = parseHex(p.color);
    switch (p.type) {
      case 'fireplace':
        return const PropLight(0.3, Color(0xFFFF8A3A), 3.2, flicker: 0.5);
      case 'lamp':
        return PropLight(1.15, pal.light, 2.8, flicker: 0.05);
      case 'candles':
        return PropLight(0.45, mix(pal.light, const Color(0xFFFFB050), 0.4), 2.0, flicker: 0.4);
      case 'tv':
        return const PropLight(0.45, Color(0xFF8FB4FF), 1.8, flicker: 0.6);
      case 'vending':
        return PropLight(0.9, mix(custom ?? const Color(0xFFE8F0FF), _white, 0.5), 2.2, flicker: 0.1);
      case 'neon_sign':
        return PropLight(0.85, custom ?? pal.accent, 2.6, flicker: 0.25);
      case 'party_laterne':
        return PropLight(1.85, mix(pal.light, const Color(0xFFFFE2A8), 0.3), 3.0, flicker: 0.06);
      default:
        return p.spec.light ? PropLight(p.spec.height * 0.7, pal.light, 2.0) : null;
    }
  }

  void paint(Canvas c, PropDef p, {bool east = false}) {
    final pen = IsoPen(c, p.x.toDouble(), p.y.toDouble(), east: east);
    final custom = parseHex(p.color);
    final rng = Rng((p.x * 7919 + p.y * 104729 + p.type.hashCode) & 0x7fffffff);
    if (p.type.startsWith('party_') && _party.paint(pen, p)) return;
    switch (p.type) {
      case 'table':
        _table(pen, custom, rng);
      case 'chair':
        _chair(pen, custom);
      case 'armchair':
        _armchair(pen, custom);
      case 'sofa':
        _sofa(pen, custom);
      case 'bed':
        _bed(pen, custom);
      case 'desk':
        _desk(pen, custom);
      case 'bookshelf':
        _bookshelf(pen, custom, rng);
      case 'cabinet':
        _cabinet(pen, custom, rng);
      case 'wardrobe':
        _wardrobe(pen, custom);
      case 'piano':
        _piano(pen, custom);
      case 'fireplace':
        _fireplace(pen, custom);
      case 'plant':
        _plant(pen, custom, rng);
      case 'lamp':
        _lamp(pen, custom);
      case 'clock':
        _clock(pen, custom);
      case 'crate':
        _crate(pen, custom, p.spec.height);
      case 'barrel':
        _barrel(pen, custom);
      case 'bathtub':
        _bathtub(pen, custom);
      case 'sink':
        _sink(pen, custom);
      case 'toilet':
        _toilet(pen, custom);
      case 'counter':
        _counter(pen, custom, rng);
      case 'stove':
        _stove(pen, custom);
      case 'fridge':
        _fridge(pen, custom);
      case 'seat':
        _seat(pen, custom);
      case 'luggage':
        _luggage(pen, custom);
      case 'statue':
        _statue(pen, custom);
      case 'vending':
        _vending(pen, custom, rng);
      case 'neon_sign':
        _neonBoard(pen);
      case 'pool_table':
        _poolTable(pen, custom, rng);
      case 'bar_stool':
        _barStool(pen, custom);
      case 'tv':
        _tv(pen, custom);
      case 'bush':
        _bush(pen, custom, rng);
      case 'tree':
        _tree(pen, custom, rng);
      case 'car':
        _car(pen, custom);
      case 'candles':
        _candlesStatic(pen);
      default:
        _crate(pen, custom ?? pal.wood, math.max(0.2, p.spec.height));
    }
  }

  // --- Möbel ---------------------------------------------------------------

  void _legs(IsoPen pen, double u0, double v0, double u1, double v1, double z, Color col, [double s = 0.05]) {
    for (final (u, v) in [(u0, v0), (u1, v0), (u0, v1), (u1, v1)]) {
      pen.part(u, v, () => pen.box(u, v, u + s, v + s, 0, z, col));
    }
    pen.flush();
  }

  void _table(IsoPen pen, Color? custom, Rng rng) {
    final wood = custom ?? pal.wood;
    _legs(pen, 0.13, 0.17, 0.82, 0.78, 0.39, pal.darkWood);
    pen.box(0.07, 0.11, 0.93, 0.89, 0.38, 0.45, wood, edge: withAlpha(shade(wood, 0.35), 0.6));
    pen.topRect(0.32, 0.11, 0.68, 0.89, 0.451, pen.fill(withAlpha(pal.text, 0.55)));
    switch (rng.nextInt(3)) {
      case 0:
        pen.cylinder(0.5, 0.5, 0.06, 0.45, 0.6, pal.porcelain, rTop: 0.045);
        pen.sphere(0.5, 0.5, 0.66, 0.07, mix(pal.danger, _white, 0.1));
      case 1:
        pen.cylinder(0.42, 0.45, 0.08, 0.45, 0.47, pal.porcelain);
        pen.cylinder(0.42, 0.45, 0.04, 0.47, 0.53, pal.porcelain);
        pen.cylinder(0.62, 0.62, 0.035, 0.45, 0.6, const Color(0xFF2F4A35));
      default:
        pen.cylinder(0.5, 0.5, 0.03, 0.45, 0.62, _brass);
    }
  }

  void _chair(IsoPen pen, Color? custom) {
    final wood = pal.wood;
    final fab = custom ?? pal.fabric;
    _legs(pen, 0.2, 0.22, 0.75, 0.75, 0.27, pal.darkWood, 0.05);
    pen.box(0.2, 0.18, 0.8, 0.26, 0.3, 0.8, wood);
    pen.frontRect(0.28, 0.72, 0.42, 0.72, 0.26, pen.fill(shade(fab, -0.1)));
    pen.box(0.18, 0.24, 0.82, 0.82, 0.26, 0.33, fab, edge: withAlpha(shade(fab, 0.3), 0.5));
  }

  void _armchair(IsoPen pen, Color? custom) {
    final fab = custom ?? pal.fabric;
    pen.box(0.12, 0.16, 0.88, 0.9, 0.04, 0.3, shade(fab, -0.08));
    pen.box(0.12, 0.1, 0.88, 0.3, 0.3, 0.8, shade(fab, -0.04), edge: withAlpha(shade(fab, 0.3), 0.4));
    pen.part(0.17, 0.6, () => pen.box(0.08, 0.24, 0.25, 0.92, 0.3, 0.52, fab));
    pen.part(0.5, 0.6, () => pen.box(0.25, 0.3, 0.75, 0.9, 0.3, 0.38, shade(fab, 0.08)));
    pen.part(0.83, 0.6, () => pen.box(0.75, 0.24, 0.92, 0.92, 0.3, 0.52, fab));
    pen.flush();
    // Knöpfe
    pen.onFront(0.3, () {
      final b = Paint()..color = shade(fab, -0.35);
      for (final u in [0.35, 0.5, 0.65]) {
        pen.c.drawCircle(Offset(u, 0.62), 0.018, b);
      }
    });
  }

  void _sofa(IsoPen pen, Color? custom) {
    final fab = custom ?? mix(const Color(0xFF2F5A45), pal.fabric, 0.15);
    pen.box(0.03, 0.2, 0.97, 0.9, 0.04, 0.28, shade(fab, -0.1));
    pen.box(0.03, 0.12, 0.97, 0.34, 0.28, 0.7, shade(fab, -0.03), edge: withAlpha(shade(fab, 0.3), 0.35));
    pen.part(0.09, 0.6, () => pen.box(0.02, 0.26, 0.16, 0.92, 0.28, 0.46, fab));
    pen.part(0.32, 0.6, () => pen.box(0.16, 0.34, 0.5, 0.88, 0.28, 0.36, shade(fab, 0.08)));
    pen.part(0.67, 0.6, () => pen.box(0.5, 0.34, 0.84, 0.88, 0.28, 0.36, shade(fab, 0.06)));
    pen.part(0.91, 0.6, () => pen.box(0.84, 0.26, 0.98, 0.92, 0.28, 0.46, fab));
    pen.flush();
    pen.onFront(0.34, () {
      final b = Paint()..color = shade(fab, -0.35);
      for (final u in [0.2, 0.4, 0.6, 0.8]) {
        pen.c.drawCircle(Offset(u, 0.56), 0.016, b);
      }
    });
  }

  void _bed(IsoPen pen, Color? custom) {
    final wood = pal.darkWood;
    final cover = custom ?? mix(pal.fabric, const Color(0xFF3A3F6A), 0.4);
    pen.box(0.05, 0.0, 0.95, 0.08, 0.04, 0.78, shade(wood, 0.1), edge: withAlpha(pal.trim, 0.4));
    pen.box(0.05, 0.06, 0.95, 0.98, 0.04, 0.22, wood);
    pen.box(0.08, 0.08, 0.92, 0.95, 0.22, 0.32, pal.porcelain);
    pen.box(0.16, 0.1, 0.84, 0.3, 0.32, 0.4, shade(pal.porcelain, 0.05));
    pen.box(0.08, 0.36, 0.92, 0.96, 0.32, 0.37, cover);
    pen.topRect(0.08, 0.36, 0.92, 0.43, 0.371, pen.fill(shade(cover, 0.18)));
    pen.box(0.05, 0.92, 0.95, 1.0, 0.04, 0.42, shade(wood, 0.05));
  }

  void _desk(IsoPen pen, Color? custom) {
    final wood = custom ?? pal.wood;
    pen.part(0.89, 0.23, () => pen.box(0.86, 0.2, 0.92, 0.26, 0, 0.44, pal.darkWood));
    pen.part(0.24, 0.5, () {
      pen.box(0.06, 0.18, 0.42, 0.82, 0, 0.44, shade(wood, -0.06));
      final line = pen.stroke(shade(wood, -0.45), 0.8);
      for (final z in [0.15, 0.29]) {
        pen.c.drawLine(pen.p(0.06, 0.82, z), pen.p(0.42, 0.82, z), line);
      }
      for (final z in [0.08, 0.22, 0.36]) {
        pen.c.drawCircle(pen.p(0.24, 0.821, z), 1.2, pen.fill(_brass));
      }
    });
    pen.part(0.89, 0.79, () => pen.box(0.86, 0.76, 0.92, 0.82, 0, 0.44, pal.darkWood));
    pen.flush();
    pen.box(0.03, 0.13, 0.97, 0.87, 0.44, 0.5, wood, edge: withAlpha(shade(wood, 0.35), 0.6));
    pen.topRect(0.12, 0.5, 0.42, 0.78, 0.501, pen.fill(const Color(0xFF2E5B3E)));
    pen.topRect(0.5, 0.35, 0.8, 0.7, 0.502, pen.fill(const Color(0xFFE9E2CF)));
    pen.box(0.18, 0.22, 0.4, 0.42, 0.5, 0.56, mix(pal.fabric, _black, 0.2));
    pen.cylinder(0.62, 0.25, 0.035, 0.5, 0.55, const Color(0xFF151520));
    pen.cylinder(0.84, 0.28, 0.025, 0.5, 0.66, _brass);
    pen.cylinder(0.84, 0.28, 0.1, 0.66, 0.74, const Color(0xFF2F6B45), rTop: 0.05);
  }

  void _bookshelf(IsoPen pen, Color? custom, Rng rng) {
    final wood = custom ?? pal.darkWood;
    pen.box(0.02, 0.04, 0.98, 0.5, 0, 1.58, wood);
    const books = [
      Color(0xFF7A2430), Color(0xFF2F4A3A), Color(0xFF263A5C), Color(0xFF8C6A2C),
      Color(0xFF5A3A28), Color(0xFFCFC2A2), Color(0xFF4A2A4A), Color(0xFF1F2A2A),
    ];
    pen.onFront(0.5, () {
      final c = pen.c;
      c.drawRect(const Rect.fromLTRB(0.07, 0.06, 0.93, 1.5), Paint()..color = shade(wood, -0.55));
      for (var k = 0; k < 4; k++) {
        final z0 = 0.09 + k * 0.36;
        var u = 0.09;
        while (u < 0.88) {
          final w = 0.035 + rng.nextDouble() * 0.04;
          if (u + w > 0.91) break;
          final h = 0.2 + rng.nextDouble() * 0.11;
          final col = books[rng.nextInt(books.length)];
          if (rng.chance(0.08)) {
            u += 0.05;
            continue;
          }
          c.drawRect(Rect.fromLTRB(u, z0, u + w, z0 + h), Paint()..color = col);
          c.drawRect(Rect.fromLTRB(u, z0 + h * 0.7, u + w, z0 + h * 0.76), Paint()..color = withAlpha(pal.trim, 0.55));
          c.drawRect(Rect.fromLTRB(u, z0, u + w * 0.25, z0 + h), Paint()..color = withAlpha(_white, 0.08));
          u += w + 0.004;
        }
        c.drawRect(Rect.fromLTRB(0.05, z0 - 0.035, 0.95, z0), Paint()..color = shade(wood, 0.12));
      }
    });
    pen.box(0.0, 0.02, 1.0, 0.54, 1.54, 1.62, shade(wood, 0.1), edge: withAlpha(pal.trim, 0.35));
  }

  void _cabinet(IsoPen pen, Color? custom, Rng rng) {
    final wood = custom ?? pal.wood;
    pen.box(0.06, 0.1, 0.94, 0.6, 0.02, 1.27, wood);
    pen.onFront(0.6, () {
      final c = pen.c;
      final dark = Paint()
        ..color = shade(wood, -0.45)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.012;
      c.drawRect(const Rect.fromLTRB(0.1, 0.06, 0.48, 0.6), dark);
      c.drawRect(const Rect.fromLTRB(0.52, 0.06, 0.9, 0.6), dark);
      c.drawRect(const Rect.fromLTRB(0.1, 0.68, 0.9, 1.2), Paint()..color = pal.glass);
      for (final z in [0.86, 1.03]) {
        c.drawRect(Rect.fromLTRB(0.1, z - 0.01, 0.9, z + 0.005), Paint()..color = shade(wood, 0.1));
      }
      for (var k = 0; k < 6; k++) {
        final u = 0.16 + k * 0.12;
        final z = k.isEven ? 0.7 : 0.87;
        c.drawCircle(Offset(u, z + 0.06), 0.045, Paint()..color = rng.chance(0.5) ? pal.porcelain : mix(pal.porcelain, const Color(0xFF4A7AB0), 0.4));
      }
      c.drawLine(const Offset(0.5, 0.68), const Offset(0.5, 1.2), Paint()
        ..color = shade(wood, -0.2)
        ..strokeWidth = 0.02);
      c.drawRect(const Rect.fromLTRB(0.12, 0.7, 0.2, 1.18), Paint()..color = withAlpha(_white, 0.1));
      for (final u in [0.45, 0.55]) {
        c.drawCircle(Offset(u, 0.4), 0.018, Paint()..color = _brass);
      }
    });
    pen.box(0.03, 0.07, 0.97, 0.63, 1.25, 1.32, shade(wood, 0.1), edge: withAlpha(pal.trim, 0.3));
  }

  void _wardrobe(IsoPen pen, Color? custom) {
    final wood = custom ?? pal.wood;
    _legs(pen, 0.06, 0.1, 0.88, 0.58, 0.05, pal.darkWood, 0.06);
    pen.box(0.03, 0.06, 0.97, 0.66, 0.04, 1.64, wood);
    pen.onFront(0.66, () {
      final c = pen.c;
      final line = Paint()
        ..color = shade(wood, -0.45)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.012;
      c.drawLine(const Offset(0.5, 0.08), const Offset(0.5, 1.6), line);
      for (final (a, b) in [(0.1, 0.44), (0.56, 0.9)]) {
        c.drawRect(Rect.fromLTRB(a, 0.14, b, 0.72), line);
        c.drawRect(Rect.fromLTRB(a, 0.82, b, 1.5), line);
        c.drawRect(Rect.fromLTRB(a + 0.02, 0.84, a + 0.06, 1.48), Paint()..color = withAlpha(_white, 0.06));
      }
      c.drawRect(const Rect.fromLTRB(0.455, 0.72, 0.475, 0.92), Paint()..color = _brass);
      c.drawRect(const Rect.fromLTRB(0.525, 0.72, 0.545, 0.92), Paint()..color = _brass);
    });
    pen.box(0.0, 0.03, 1.0, 0.69, 1.62, 1.72, shade(wood, 0.12), edge: withAlpha(pal.trim, 0.35));
  }

  void _piano(IsoPen pen, Color? custom) {
    final black = custom ?? const Color(0xFF17151A);
    pen.part(0.1, 0.6, () => pen.box(0.08, 0.52, 0.14, 0.7, 0, 0.42, black));
    pen.part(0.9, 0.6, () => pen.box(0.86, 0.52, 0.92, 0.7, 0, 0.42, black));
    pen.flush();
    pen.box(0.04, 0.08, 0.96, 0.52, 0.04, 0.82, black, top: shade(black, 0.15), edge: withAlpha(_white, 0.25));
    pen.onFront(0.52, () {
      final c = pen.c;
      c.drawRect(const Rect.fromLTRB(0.3, 0.56, 0.7, 0.74), Paint()..color = const Color(0xFFE8DFC8));
      final l = Paint()
        ..color = const Color(0x55302010)
        ..strokeWidth = 0.008;
      for (var i = 0; i < 4; i++) {
        c.drawLine(Offset(0.33, 0.6 + i * 0.035), Offset(0.67, 0.6 + i * 0.035), l);
      }
      c.drawRect(const Rect.fromLTRB(0.1, 0.12, 0.9, 0.36), Paint()
        ..color = withAlpha(_white, 0.06)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.01);
    });
    pen.box(0.05, 0.52, 0.95, 0.74, 0.42, 0.49, black);
    pen.topRect(0.08, 0.54, 0.92, 0.72, 0.491, pen.fill(const Color(0xFFEDE6D4)));
    final k = pen.fill(const Color(0xFF111014));
    for (var i = 0; i < 16; i++) {
      if (i % 7 == 2 || i % 7 == 6) continue;
      final u = 0.1 + i * 0.051;
      pen.topRect(u, 0.54, u + 0.026, 0.63, 0.492, k);
    }
    for (final u in [0.14, 0.86]) {
      pen.cylinder(u, 0.3, 0.03, 0.82, 0.86, _brass);
      pen.cylinder(u, 0.3, 0.018, 0.86, 0.98, const Color(0xFFEDE3C8));
    }
  }

  void _fireplace(IsoPen pen, Color? custom) {
    final stone = custom ?? mix(pal.wall, const Color(0xFF6B5E55), 0.55);
    pen.box(0.0, 0.04, 1.0, 0.55, 0, 1.0, stone);
    pen.onFront(0.55, () {
      final c = pen.c;
      final mortar = Paint()
        ..color = withAlpha(shade(stone, -0.4), 0.5)
        ..strokeWidth = 0.008;
      for (var z = 0.12; z < 0.95; z += 0.12) {
        c.drawLine(Offset(0, z), Offset(1, z), mortar);
      }
      final arch = Path()
        ..moveTo(0.2, 0)
        ..lineTo(0.2, 0.44)
        ..quadraticBezierTo(0.5, 0.66, 0.8, 0.44)
        ..lineTo(0.8, 0)
        ..close();
      c.drawPath(arch, Paint()..color = shade(stone, -0.3));
      final inner = Path()
        ..moveTo(0.25, 0)
        ..lineTo(0.25, 0.42)
        ..quadraticBezierTo(0.5, 0.6, 0.75, 0.42)
        ..lineTo(0.75, 0)
        ..close();
      c.drawPath(inner, Paint()..color = const Color(0xFF0E0806));
      c.drawPath(
        inner,
        Paint()
          ..shader = Gradient.linear(const Offset(0.5, 0), const Offset(0.5, 0.5), [const Color(0xCCB0441A), const Color(0x00B0441A)]),
      );
      final log = Paint()..color = const Color(0xFF3A2416);
      c.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTRB(0.3, 0.02, 0.7, 0.08), const Radius.circular(0.03)), log);
      c.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTRB(0.34, 0.07, 0.64, 0.12), const Radius.circular(0.03)), log);
    });
    pen.box(-0.03, 0.0, 1.03, 0.62, 0.98, 1.08, shade(stone, 0.18), edge: withAlpha(_white, 0.15));
    pen.box(0.12, 0.04, 0.88, 0.42, 1.08, 1.26, shade(stone, -0.06));
    for (final u in [0.12, 0.88]) {
      pen.cylinder(u, 0.35, 0.03, 1.08, 1.12, _brass);
      pen.cylinder(u, 0.35, 0.018, 1.12, 1.24, const Color(0xFFEDE3C8));
    }
    pen.box(0.42, 0.22, 0.58, 0.36, 1.08, 1.24, pal.darkWood);
    pen.onFront(0.36, () => pen.c.drawCircle(const Offset(0.5, 1.17), 0.05, Paint()..color = const Color(0xFFEDE3C8)));
  }

  void _plant(IsoPen pen, Color? custom, Rng rng) {
    final leaf = custom ?? const Color(0xFF3C6B3A);
    pen.cylinder(0.5, 0.5, 0.15, 0, 0.3, const Color(0xFF9A5434), rTop: 0.19);
    pen.oval(0.5, 0.5, 0.3, 0.16, pen.fill(const Color(0xFF2A1A10)));
    final base = pen.p(0.5, 0.5, 0.32);
    final leaves = <(double, double)>[];
    for (var i = 0; i < 9; i++) {
      leaves.add((i * math.pi * 2 / 9 + rng.nextDouble() * 0.4, 0.8 + rng.nextDouble() * 0.4));
    }
    leaves.sort((a, b) => math.sin(a.$1).compareTo(math.sin(b.$1)));
    for (final (a, len) in leaves) {
      final front = math.sin(a);
      final tip = base + Offset(math.cos(a) * 20 * len, math.sin(a) * 7 * len - 26 * len + front * 4);
      final mid = Offset.lerp(base, tip, 0.5)!;
      final n = Offset(-(tip.dy - base.dy), tip.dx - base.dx);
      final nn = n / math.max(1, n.distance) * 4.5;
      final path = Path()
        ..moveTo(base.dx, base.dy)
        ..quadraticBezierTo(mid.dx + nn.dx, mid.dy + nn.dy - 6, tip.dx, tip.dy)
        ..quadraticBezierTo(mid.dx - nn.dx, mid.dy - nn.dy - 4, base.dx, base.dy)
        ..close();
      pen.c.drawPath(path, pen.fill(shade(leaf, front * 0.18)));
      pen.c.drawLine(base, tip, pen.stroke(withAlpha(shade(leaf, 0.35), 0.5), 0.6));
    }
  }

  void _lamp(IsoPen pen, Color? custom) {
    pen.oval(0.5, 0.5, 0, 0.15, pen.fill(withAlpha(_black, 0.35)));
    pen.cylinder(0.5, 0.5, 0.12, 0, 0.04, _brass);
    pen.c.drawLine(pen.p(0.5, 0.5, 0.04), pen.p(0.5, 0.5, 1.05), pen.stroke(_brass, 2.2));
    final shadeCol = custom ?? mix(pal.light, const Color(0xFFF2E2C0), 0.4);
    pen.cylinder(0.5, 0.5, 0.2, 1.02, 1.36, shadeCol, rTop: 0.11, top: shade(shadeCol, -0.2));
  }

  void _clock(IsoPen pen, Color? custom) {
    final wood = custom ?? mix(pal.darkWood, const Color(0xFF4A2A18), 0.4);
    pen.box(0.22, 0.18, 0.78, 0.6, 0, 0.3, wood);
    pen.box(0.27, 0.22, 0.73, 0.56, 0.3, 1.34, shade(wood, -0.06));
    pen.onFront(0.56, () {
      pen.c.drawRRect(
        RRect.fromRectAndRadius(const Rect.fromLTRB(0.37, 0.5, 0.63, 1.2), const Radius.circular(0.05)),
        Paint()..color = mix(pal.glass, _black, 0.4),
      );
    });
    pen.box(0.19, 0.15, 0.81, 0.63, 1.34, 1.76, wood, edge: withAlpha(pal.trim, 0.35));
    pen.onFront(0.63, () {
      final c = pen.c;
      c.drawCircle(const Offset(0.5, 1.55), 0.17, Paint()..color = _brass);
      c.drawCircle(const Offset(0.5, 1.55), 0.145, Paint()..color = const Color(0xFFEDE3C8));
      final h = Paint()
        ..color = const Color(0xFF1A1410)
        ..strokeWidth = 0.02
        ..strokeCap = StrokeCap.round;
      c.drawLine(const Offset(0.5, 1.55), const Offset(0.5, 1.66), h);
      c.drawLine(const Offset(0.5, 1.55), const Offset(0.58, 1.52), h);
      final top = Path()
        ..moveTo(0.19, 1.76)
        ..quadraticBezierTo(0.5, 1.95, 0.81, 1.76)
        ..close();
      c.drawPath(top, Paint()..color = shade(wood, 0.1));
    });
  }

  void _crate(IsoPen pen, Color? custom, double h) {
    final wood = custom ?? const Color(0xFF8B6A44);
    final z1 = math.min(h, 0.6);
    pen.box(0.1, 0.1, 0.9, 0.9, 0, z1, wood);
    final line = pen.stroke(withAlpha(shade(wood, -0.45), 0.7), 0.8);
    for (final t in [0.33, 0.66]) {
      pen.c.drawLine(pen.p(0.1, 0.9, z1 * t), pen.p(0.9, 0.9, z1 * t), line);
      final su = pen.sideU(0.1, 0.9);
      pen.c.drawLine(pen.p(su, 0.1, z1 * t), pen.p(su, 0.9, z1 * t), line);
      pen.c.drawLine(pen.p(0.1 + 0.8 * t, 0.1, z1), pen.p(0.1 + 0.8 * t, 0.9, z1), line);
    }
    final brace = pen.stroke(shade(wood, -0.25), 2.2);
    pen.c.drawLine(pen.p(0.14, 0.9, 0.04), pen.p(0.86, 0.9, z1 - 0.04), brace);
    pen.frontRect(0.1, 0.17, 0, z1, 0.9, pen.fill(shade(wood, -0.15)));
    pen.frontRect(0.83, 0.9, 0, z1, 0.9, pen.fill(shade(wood, -0.15)));
  }

  void _barrel(IsoPen pen, Color? custom) {
    final wood = custom ?? const Color(0xFF6E4A2C);
    pen.cylinder(0.5, 0.5, 0.3, 0, 0.7, wood);
    final hoop = pen.stroke(const Color(0xFF2A2A2E), 2.0);
    for (final z in [0.1, 0.35, 0.6]) {
      pen.c.drawArc(pen.groundOval(0.5, 0.5, z, 0.305), 0, math.pi, false, hoop);
    }
    pen.oval(0.5, 0.5, 0.7, 0.26, pen.stroke(shade(wood, -0.3), 0.8));
  }

  void _bathtub(IsoPen pen, Color? custom) {
    final enamel = custom ?? pal.porcelain;
    for (final (u, v) in [(0.12, 0.22), (0.88, 0.22), (0.12, 0.78), (0.88, 0.78)]) {
      pen.part(u, v, () => pen.sphere(u, v, 0.05, 0.05, _brass));
    }
    pen.flush();
    pen.box(0.05, 0.15, 0.95, 0.85, 0.08, 0.45, enamel, edge: withAlpha(_white, 0.5));
    pen.topRect(0.1, 0.21, 0.9, 0.79, 0.451, pen.fill(shade(enamel, -0.2)));
    pen.topRect(0.13, 0.25, 0.87, 0.75, 0.452, pen.fill(withAlpha(const Color(0xFF6F98B8), 0.85)));
    pen.c.drawLine(pen.p(0.2, 0.35, 0.453), pen.p(0.55, 0.35, 0.453), pen.stroke(withAlpha(_white, 0.45), 1));
    pen.cylinder(0.5, 0.18, 0.03, 0.45, 0.58, pal.metal);
  }

  void _sink(IsoPen pen, Color? custom) {
    final por = custom ?? pal.porcelain;
    pen.onFront(0.06, () {
      final c = pen.c;
      c.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTRB(0.22, 0.72, 0.78, 1.24), const Radius.circular(0.06)), Paint()..color = _brass);
      c.drawRRect(
        RRect.fromRectAndRadius(const Rect.fromLTRB(0.26, 0.76, 0.74, 1.2), const Radius.circular(0.05)),
        Paint()..shader = Gradient.linear(const Offset(0.26, 1.2), const Offset(0.74, 0.76), [const Color(0xFF9FB0BC), const Color(0xFF4A5560), const Color(0xFF8A9AA6)], const [0, 0.6, 1]),
      );
    });
    pen.cylinder(0.5, 0.5, 0.08, 0, 0.48, por, rTop: 0.06);
    pen.box(0.2, 0.26, 0.8, 0.74, 0.48, 0.62, por, edge: withAlpha(_white, 0.5));
    pen.oval(0.5, 0.52, 0.621, 0.18, pen.fill(shade(por, -0.22)));
    pen.cylinder(0.5, 0.32, 0.025, 0.62, 0.72, pal.metal);
  }

  void _toilet(IsoPen pen, Color? custom) {
    final por = custom ?? pal.porcelain;
    pen.box(0.3, 0.1, 0.7, 0.28, 0.22, 0.62, por, edge: withAlpha(_white, 0.4));
    pen.cylinder(0.5, 0.56, 0.16, 0, 0.32, por, rTop: 0.19);
    pen.oval(0.5, 0.56, 0.33, 0.19, pen.fill(shade(por, -0.05)));
    pen.oval(0.5, 0.57, 0.331, 0.11, pen.fill(shade(por, -0.35)));
    pen.cylinder(0.62, 0.2, 0.02, 0.6, 0.64, pal.metal);
  }

  void _counter(IsoPen pen, Color? custom, Rng rng) {
    final cab = custom ?? mix(pal.wood, const Color(0xFF6A6F66), 0.35);
    pen.box(0.0, 0.1, 1.0, 0.8, 0, 0.55, cab);
    pen.onFront(0.8, () {
      final c = pen.c;
      final l = Paint()
        ..color = shade(cab, -0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.012;
      c.drawRect(const Rect.fromLTRB(0.06, 0.06, 0.47, 0.46), l);
      c.drawRect(const Rect.fromLTRB(0.53, 0.06, 0.94, 0.46), l);
      c.drawRect(const Rect.fromLTRB(0.0, 0.0, 1.0, 0.04), Paint()..color = shade(cab, -0.5));
      for (final u in [0.42, 0.58]) {
        c.drawRect(Rect.fromLTRB(u - 0.01, 0.32, u + 0.01, 0.42), Paint()..color = pal.metal);
      }
    });
    pen.box(-0.01, 0.08, 1.01, 0.82, 0.55, 0.61, const Color(0xFFBDB6A8), edge: withAlpha(_white, 0.35));
    switch (rng.nextInt(3)) {
      case 0:
        pen.cylinder(0.3, 0.4, 0.07, 0.61, 0.78, const Color(0xFF8AA0A8));
        pen.cylinder(0.3, 0.4, 0.075, 0.78, 0.8, const Color(0xFF6A4A2A));
      case 1:
        pen.box(0.45, 0.3, 0.8, 0.6, 0.61, 0.64, const Color(0xFF9A7448));
      default:
        pen.cylinder(0.7, 0.35, 0.04, 0.61, 0.82, const Color(0xFF2F5A3A), rTop: 0.02);
    }
  }

  void _stove(IsoPen pen, Color? custom) {
    final iron = custom ?? const Color(0xFF2A2A2E);
    pen.box(0.05, 0.06, 0.95, 0.14, 0.55, 0.78, iron);
    pen.box(0.05, 0.12, 0.95, 0.86, 0, 0.55, iron, edge: withAlpha(_white, 0.18));
    for (final (u, v) in [(0.3, 0.32), (0.7, 0.32), (0.3, 0.66), (0.7, 0.66)]) {
      pen.oval(u, v, 0.551, 0.12, pen.fill(const Color(0xFF111114)));
      pen.oval(u, v, 0.552, 0.08, pen.stroke(const Color(0xFF55555C), 1));
    }
    pen.onFront(0.86, () {
      final c = pen.c;
      c.drawRect(const Rect.fromLTRB(0.14, 0.08, 0.86, 0.42), Paint()..color = shade(iron, 0.1));
      c.drawRect(const Rect.fromLTRB(0.24, 0.16, 0.76, 0.32), Paint()..color = const Color(0xFF0C0C0E));
      c.drawRect(const Rect.fromLTRB(0.2, 0.37, 0.8, 0.39), Paint()..color = pal.metal);
      for (final u in [0.2, 0.4, 0.6, 0.8]) {
        c.drawCircle(Offset(u, 0.48), 0.025, Paint()..color = pal.metal);
      }
    });
  }

  void _fridge(IsoPen pen, Color? custom) {
    final col = custom ?? const Color(0xFFD8D2C2);
    pen.box(0.1, 0.1, 0.9, 0.7, 0, 1.42, col, edge: withAlpha(_white, 0.35));
    pen.box(0.12, 0.12, 0.88, 0.68, 1.42, 1.48, shade(col, 0.05));
    pen.onFront(0.7, () {
      final c = pen.c;
      c.drawRect(const Rect.fromLTRB(0.0, 0.98, 1.0, 1.0), Paint()..color = shade(col, -0.35));
      c.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTRB(0.76, 1.06, 0.8, 1.32), const Radius.circular(0.02)), Paint()..color = pal.metal);
      c.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTRB(0.76, 0.58, 0.8, 0.9), const Radius.circular(0.02)), Paint()..color = pal.metal);
      c.drawRect(const Rect.fromLTRB(0.4, 1.32, 0.6, 1.36), Paint()..color = _brass);
      c.drawRect(const Rect.fromLTRB(0.08, 0.1, 0.14, 1.38), Paint()..color = withAlpha(_white, 0.12));
    });
  }

  void _seat(IsoPen pen, Color? custom) {
    final fab = custom ?? mix(const Color(0xFF2E3F66), pal.fabric, 0.3);
    pen.box(0.12, 0.26, 0.88, 0.84, 0, 0.08, _darkMetal);
    pen.box(0.06, 0.12, 0.94, 0.3, 0.08, 0.95, shade(fab, -0.06), edge: withAlpha(shade(fab, 0.3), 0.4));
    pen.frontRect(0.2, 0.8, 0.76, 0.92, 0.3, pen.fill(const Color(0xFFE6DFCF)));
    pen.part(0.06, 0.6, () => pen.box(0.02, 0.28, 0.1, 0.9, 0.08, 0.5, pal.wood));
    pen.part(0.5, 0.6, () => pen.box(0.1, 0.24, 0.9, 0.88, 0.08, 0.38, fab, edge: withAlpha(shade(fab, 0.35), 0.4)));
    pen.part(0.94, 0.6, () => pen.box(0.9, 0.28, 0.98, 0.9, 0.08, 0.5, pal.wood));
    pen.flush();
  }

  void _luggage(IsoPen pen, Color? custom) {
    final leather = custom ?? const Color(0xFF7A4B2A);
    pen.box(0.1, 0.2, 0.9, 0.78, 0, 0.26, leather, edge: withAlpha(_brass, 0.6));
    final strap = pen.fill(shade(leather, -0.45));
    pen.frontRect(0.27, 0.33, 0, 0.26, 0.78, strap);
    pen.frontRect(0.67, 0.73, 0, 0.26, 0.78, strap);
    pen.topRect(0.27, 0.2, 0.33, 0.78, 0.261, strap);
    pen.topRect(0.67, 0.2, 0.73, 0.78, 0.261, strap);
    final second = mix(const Color(0xFF3F5A4A), leather, 0.2);
    pen.box(0.2, 0.3, 0.74, 0.7, 0.26, 0.42, second, edge: withAlpha(_brass, 0.5));
    pen.c.drawArc(
      Rect.fromCenter(center: pen.p(0.47, 0.5, 0.46), width: 10, height: 6),
      math.pi,
      math.pi,
      false,
      pen.stroke(shade(leather, -0.4), 1.6),
    );
  }

  void _statue(IsoPen pen, Color? custom) {
    final marble = custom ?? const Color(0xFFCFCBC2);
    pen.box(0.16, 0.16, 0.84, 0.84, 0, 0.1, shade(marble, -0.2));
    pen.box(0.22, 0.22, 0.78, 0.78, 0.1, 0.46, shade(marble, -0.1));
    pen.box(0.18, 0.18, 0.82, 0.82, 0.46, 0.52, shade(marble, -0.15));
    pen.cylinder(0.5, 0.5, 0.15, 0.52, 1.18, marble, rTop: 0.11);
    final fold = pen.stroke(withAlpha(shade(marble, -0.35), 0.6), 0.8);
    final b = pen.p(0.5, 0.5, 0.52), t = pen.p(0.5, 0.5, 1.15);
    for (final dx in [-3.0, 0.5, 4.0]) {
      pen.c.drawLine(b.translate(dx, 0), t.translate(dx * 0.4 + 1, 0), fold);
    }
    pen.sphere(0.5, 0.5, 1.2, 0.13, marble, squash: 0.45);
    pen.c.drawLine(pen.p(0.62, 0.5, 1.18), pen.p(0.72, 0.5, 1.45), pen.stroke(shade(marble, -0.05), 3.2));
    pen.sphere(0.5, 0.5, 1.36, 0.09, marble);
  }

  void _vending(IsoPen pen, Color? custom, Rng rng) {
    final body = custom ?? const Color(0xFF8C1C2B);
    pen.box(0.06, 0.12, 0.94, 0.68, 0, 1.5, body, edge: withAlpha(_white, 0.25));
    pen.onFront(0.68, () {
      final c = pen.c;
      c.drawRect(const Rect.fromLTRB(0.11, 0.42, 0.65, 1.37), Paint()..color = const Color(0xFF14181E));
      const cols = [Color(0xFFD9473A), Color(0xFF3A7BD9), Color(0xFFE8C04A), Color(0xFF4AB86A), Color(0xFFE8E4D8)];
      for (var r = 0; r < 4; r++) {
        final z = 0.5 + r * 0.22;
        for (var i = 0; i < 4; i++) {
          final u = 0.15 + i * 0.12;
          c.drawRect(Rect.fromLTRB(u, z, u + 0.08, z + 0.13), Paint()..color = cols[rng.nextInt(cols.length)]);
        }
        c.drawRect(Rect.fromLTRB(0.11, z - 0.02, 0.65, z), Paint()..color = pal.metal);
      }
      c.drawRect(const Rect.fromLTRB(0.69, 0.82, 0.89, 1.3), Paint()..color = const Color(0xFF1A1A1E));
      for (var i = 0; i < 6; i++) {
        c.drawCircle(Offset(0.74 + (i % 2) * 0.1, 1.2 - (i ~/ 2) * 0.1), 0.025, Paint()..color = const Color(0xFFCFCFCF));
      }
      c.drawRect(const Rect.fromLTRB(0.15, 0.1, 0.62, 0.28), Paint()..color = const Color(0xFF070708));
    });
  }

  void _neonBoard(IsoPen pen) {
    pen.box(0.44, 0.44, 0.56, 0.52, 0, 0.5, _darkMetal);
    pen.box(0.06, 0.4, 0.94, 0.52, 0.5, 1.2, const Color(0xFF16141B), edge: withAlpha(_white, 0.12));
  }

  void _poolTable(IsoPen pen, Color? custom, Rng rng) {
    final rim = const Color(0xFF4A2A18);
    final felt = custom ?? const Color(0xFF1E6B3E);
    _legs(pen, 0.08, 0.14, 0.86, 0.8, 0.14, shade(rim, -0.2), 0.07);
    pen.box(0.02, 0.1, 0.98, 0.9, 0.12, 0.42, rim, top: shade(rim, 0.15), edge: withAlpha(_brass, 0.4));
    pen.topRect(0.08, 0.16, 0.92, 0.84, 0.421, pen.fill(felt));
    final hole = pen.fill(const Color(0xFF0A0A0A));
    for (final (u, v) in [(0.09, 0.17), (0.5, 0.16), (0.91, 0.17), (0.09, 0.83), (0.5, 0.84), (0.91, 0.83)]) {
      pen.oval(u, v, 0.422, 0.035, hole);
    }
    const balls = [Color(0xFFF2EEE0), Color(0xFFD9B23A), Color(0xFFB8322F), Color(0xFF2F4FA0), Color(0xFF141414)];
    for (var i = 0; i < 5; i++) {
      final u = 0.2 + rng.nextDouble() * 0.6, v = 0.25 + rng.nextDouble() * 0.5;
      final o = pen.p(u, v, 0.45);
      pen.c.drawCircle(o, 2.2, pen.fill(balls[i]));
      pen.c.drawCircle(o.translate(-0.7, -0.7), 0.7, pen.fill(withAlpha(_white, 0.6)));
    }
    pen.c.drawLine(pen.p(0.15, 0.7, 0.44), pen.p(0.8, 0.45, 0.47), pen.stroke(const Color(0xFFC8A272), 1.2));
  }

  void _barStool(IsoPen pen, Color? custom) {
    pen.oval(0.5, 0.5, 0, 0.15, pen.fill(_darkMetal));
    pen.c.drawLine(pen.p(0.5, 0.5, 0), pen.p(0.5, 0.5, 0.46), pen.stroke(pal.metal, 2.4));
    pen.oval(0.5, 0.5, 0.18, 0.11, pen.stroke(pal.metal, 1.2));
    pen.cylinder(0.5, 0.5, 0.18, 0.44, 0.52, custom ?? const Color(0xFF8E2B2B));
  }

  void _tv(IsoPen pen, Color? custom) {
    final wood = pal.wood;
    _legs(pen, 0.16, 0.26, 0.8, 0.7, 0.12, pal.darkWood, 0.04);
    pen.box(0.12, 0.22, 0.88, 0.78, 0.1, 0.25, wood);
    final body = custom ?? const Color(0xFF3B3631);
    pen.box(0.2, 0.28, 0.8, 0.7, 0.25, 0.62, body, edge: withAlpha(_white, 0.2));
    pen.onFront(0.7, () {
      pen.c.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTRB(0.25, 0.3, 0.68, 0.58), const Radius.circular(0.04)), Paint()..color = const Color(0xFF0E1216));
      pen.c.drawCircle(const Offset(0.74, 0.5), 0.025, Paint()..color = _brass);
      pen.c.drawCircle(const Offset(0.74, 0.4), 0.025, Paint()..color = _brass);
    });
    final ant = pen.stroke(pal.metal, 0.9);
    pen.c.drawLine(pen.p(0.5, 0.45, 0.62), pen.p(0.3, 0.35, 0.95), ant);
    pen.c.drawLine(pen.p(0.5, 0.45, 0.62), pen.p(0.72, 0.4, 0.98), ant);
  }

  void _snowCap(IsoPen pen, double u, double v, double z, double r) {
    if (weather != 'snow') return;
    final o = pen.p(u, v, z);
    final rad = r * IsoPen.rx;
    pen.c.drawOval(Rect.fromCenter(center: o.translate(0, -rad * 0.45), width: rad * 1.5, height: rad * 0.7), pen.fill(withAlpha(const Color(0xFFF2F6FA), 0.9)));
  }

  void _bush(IsoPen pen, Color? custom, Rng rng) {
    final leaf = custom ?? mix(const Color(0xFF2F5A2C), pal.fog, 0.1);
    final blobs = [(0.35, 0.4, 0.35, 0.25), (0.66, 0.42, 0.37, 0.24), (0.5, 0.66, 0.3, 0.26), (0.3, 0.66, 0.27, 0.2), (0.72, 0.68, 0.28, 0.2), (0.5, 0.45, 0.55, 0.23)];
    blobs.sort((a, b) => (a.$1 + a.$2 + a.$3 * 0.5).compareTo(b.$1 + b.$2 + b.$3 * 0.5));
    for (final (u, v, z, r) in blobs) {
      pen.sphere(u, v, z, r, shade(leaf, (rng.nextDouble() - 0.5) * 0.15), squash: 0.85);
      _snowCap(pen, u, v, z, r);
    }
    if (rng.chance(0.5)) {
      final berry = pen.fill(mix(pal.danger, _white, 0.15));
      for (var i = 0; i < 5; i++) {
        pen.c.drawCircle(pen.p(0.25 + rng.nextDouble() * 0.5, 0.45 + rng.nextDouble() * 0.35, 0.3 + rng.nextDouble() * 0.3), 1.3, berry);
      }
    }
  }

  void _tree(IsoPen pen, Color? custom, Rng rng) {
    final leaf = custom ?? mix(const Color(0xFF2A4A26), pal.fog, 0.15);
    pen.cylinder(0.5, 0.5, 0.09, 0, 1.05, const Color(0xFF4A3424), rTop: 0.06);
    final blobs = [(0.5, 0.5, 1.12, 0.42), (0.28, 0.46, 1.34, 0.33), (0.72, 0.44, 1.38, 0.33), (0.46, 0.68, 1.3, 0.34), (0.6, 0.58, 1.62, 0.32), (0.42, 0.4, 1.74, 0.28), (0.52, 0.5, 1.95, 0.22)];
    blobs.sort((a, b) => (a.$1 + a.$2 + a.$3 * 0.6).compareTo(b.$1 + b.$2 + b.$3 * 0.6));
    for (final (u, v, z, r) in blobs) {
      pen.sphere(u, v, z, r, shade(leaf, (rng.nextDouble() - 0.5) * 0.18), squash: 0.88);
      _snowCap(pen, u, v, z, r);
    }
  }

  void _car(IsoPen pen, Color? custom) {
    final body = custom ?? const Color(0xFF3E5468);
    final tire = pen.fill(const Color(0xFF111113));
    // hintere Räder (unter der Karosserie sichtbar)
    pen.box(-0.1, 0.18, 1.1, 0.82, 0.12, 0.42, body, edge: withAlpha(_white, 0.3));
    pen.box(0.16, 0.24, 0.8, 0.76, 0.42, 0.72, shade(body, 0.04), top: shade(body, 0.18));
    pen.onFront(0.76, () {
      pen.c.drawRect(const Rect.fromLTRB(0.2, 0.46, 0.46, 0.69), Paint()..color = pal.glass);
      pen.c.drawRect(const Rect.fromLTRB(0.5, 0.46, 0.76, 0.69), Paint()..color = pal.glass);
      pen.c.drawRect(const Rect.fromLTRB(0.22, 0.6, 0.3, 0.68), Paint()..color = withAlpha(_white, 0.15));
    });
    pen.onSide(pen.sideU(0.16, 0.8), () {
      pen.c.drawRect(const Rect.fromLTRB(0.28, 0.46, 0.72, 0.69), Paint()..color = shade(pal.glass, 0.1));
    });
    pen.onFront(0.82, () {
      final c = pen.c;
      c.drawRect(const Rect.fromLTRB(-0.1, 0.13, 1.1, 0.17), Paint()..color = pal.metal);
      for (final u in [0.12, 0.88]) {
        c.drawCircle(Offset(u, 0.12), 0.13, tire);
        c.drawCircle(Offset(u, 0.12), 0.06, Paint()..color = pal.metal);
      }
      c.drawLine(const Offset(0.48, 0.2), const Offset(0.48, 0.4), Paint()
        ..color = shade(body, -0.35)
        ..strokeWidth = 0.01);
    });
    final su = pen.sideU(-0.1, 1.1);
    pen.onSide(su, () {
      final c = pen.c;
      c.drawCircle(const Offset(0.28, 0.3), 0.06, Paint()..color = const Color(0xFFF0E2A0));
      c.drawCircle(const Offset(0.72, 0.3), 0.06, Paint()..color = const Color(0xFFF0E2A0));
      c.drawRect(const Rect.fromLTRB(0.2, 0.13, 0.8, 0.17), Paint()..color = pal.metal);
    });
  }

  void _candlesStatic(IsoPen pen) {
    pen.cylinder(0.5, 0.5, 0.12, 0, 0.04, _brass);
    pen.c.drawLine(pen.p(0.5, 0.5, 0.04), pen.p(0.5, 0.5, 0.3), pen.stroke(_brass, 2.2));
    pen.c.drawLine(pen.p(0.28, 0.5, 0.3), pen.p(0.72, 0.5, 0.3), pen.stroke(_brass, 1.8));
    for (final u in [0.28, 0.5, 0.72]) {
      pen.cylinder(u, 0.5, 0.035, 0.3, u == 0.5 ? 0.5 : 0.44, const Color(0xFFEDE3C8));
    }
  }

  // --- Animierte Teile -----------------------------------------------------

  void paintDynamic(Canvas c, PropDef p, double t, {bool east = false, double night = 0}) {
    final pen = IsoPen(c, p.x.toDouble(), p.y.toDouble(), east: east);
    final seed = (p.x * 13 + p.y * 7) % 11;
    switch (p.type) {
      case 'fireplace':
        pen.onFront(0.56, () {
          final cc = pen.c;
          cc.drawOval(
            Rect.fromCenter(center: const Offset(0.5, 0.06), width: 0.5, height: 0.08),
            Paint()..color = withAlpha(const Color(0xFFFF6A1A), 0.75 + 0.2 * math.sin(t * 7)),
          );
          for (var i = 0; i < 4; i++) {
            final u = 0.34 + i * 0.1;
            final h = 0.16 + 0.1 * (0.5 + 0.5 * math.sin(t * (6 + i) + i * 1.7 + seed));
            _flameLocal(cc, Offset(u, 0.06), 0.06, h, math.sin(t * 5 + i) * 0.02);
          }
        });
      case 'candles':
        for (final (u, z) in [(0.28, 0.44), (0.5, 0.5), (0.72, 0.44)]) {
          final b = pen.p(u, 0.5, z);
          _flame(c, b, 2.4, 6 + 1.5 * math.sin(t * 9 + u * 10), math.sin(t * 6 + u * 7) * 0.8);
        }
      case 'lamp':
        final o = pen.p(0.5, 0.5, 1.02);
        c.drawOval(Rect.fromCenter(center: o, width: 15, height: 7), Paint()..color = withAlpha(mix(pal.light, _white, 0.5), 0.9));
      case 'tv':
        final flick = 0.55 + 0.35 * (0.5 + 0.5 * math.sin(t * 13 + seed)) * (0.6 + 0.4 * math.sin(t * 3.1));
        pen.onFront(0.701, () {
          pen.c.drawRRect(
            RRect.fromRectAndRadius(const Rect.fromLTRB(0.27, 0.32, 0.66, 0.56), const Radius.circular(0.04)),
            Paint()..color = withAlpha(mix(const Color(0xFF8FB4FF), _white, 0.3), flick),
          );
          final scan = Paint()
            ..color = withAlpha(_black, 0.25)
            ..strokeWidth = 0.008;
          for (var z = 0.34; z < 0.56; z += 0.03) {
            pen.c.drawLine(Offset(0.27, z), Offset(0.66, z), scan);
          }
        });
      case 'vending':
        final a = 0.25 + 0.06 * math.sin(t * 2 + seed) + (math.sin(t * 23 + seed) > 0.97 ? -0.15 : 0);
        pen.onFront(0.681, () {
          pen.c.drawRect(const Rect.fromLTRB(0.11, 0.42, 0.65, 1.37), Paint()..color = withAlpha(const Color(0xFFDDEEFF), a));
          pen.c.drawRect(const Rect.fromLTRB(0.08, 1.38, 0.92, 1.47), Paint()..color = withAlpha(mix(parseHex(p.color) ?? const Color(0xFFFF4A5A), _white, 0.4), 0.9));
        });
      case 'neon_sign':
        _neon(pen, p, t, seed);
      case 'clock':
        final sw = math.sin(t * math.pi) * 0.07;
        pen.onFront(0.565, () {
          final cc = pen.c;
          cc.drawLine(const Offset(0.5, 1.18), Offset(0.5 + sw, 0.66), Paint()
            ..color = _brass
            ..strokeWidth = 0.012);
          cc.drawCircle(Offset(0.5 + sw, 0.64), 0.04, Paint()..color = _brass);
        });
    }
  }

  void _neon(IsoPen pen, PropDef p, double t, int seed) {
    final col = parseHex(p.color) ?? pal.accent;
    final second = luminance(col) > 0.5 ? const Color(0xFF44E0FF) : const Color(0xFFFF4FA8);
    final off = math.sin(t * 17 + seed) > 0.985 || (math.sin(t * 0.7 + seed) > 0.96 && math.sin(t * 31) > 0);
    final a = off ? 0.25 : 1.0;
    pen.onFront(0.53, () {
      final c = pen.c;
      final frame = Path()..addRRect(RRect.fromRectAndRadius(const Rect.fromLTRB(0.12, 0.56, 0.88, 1.14), const Radius.circular(0.06)));
      final glyph = Path();
      switch (seed % 3) {
        case 0: // Pfeil
          glyph
            ..moveTo(0.22, 0.85)
            ..lineTo(0.7, 0.85)
            ..moveTo(0.58, 0.97)
            ..lineTo(0.72, 0.85)
            ..lineTo(0.58, 0.73);
        case 1: // Cocktailglas
          glyph
            ..moveTo(0.32, 1.04)
            ..lineTo(0.68, 1.04)
            ..lineTo(0.5, 0.82)
            ..close()
            ..moveTo(0.5, 0.82)
            ..lineTo(0.5, 0.66)
            ..moveTo(0.4, 0.66)
            ..lineTo(0.6, 0.66);
        default: // Stern
          for (var i = 0; i <= 5; i++) {
            final a = -math.pi / 2 + i * math.pi * 4 / 5;
            final pt = Offset(0.5 + math.cos(a) * 0.2, 0.85 - math.sin(a) * 0.22);
            if (i == 0) {
              glyph.moveTo(pt.dx, pt.dy);
            } else {
              glyph.lineTo(pt.dx, pt.dy);
            }
          }
      }
      for (final (path, cl) in [(frame, second), (glyph, col)]) {
        c.drawPath(path, Paint()
          ..color = withAlpha(cl, 0.16 * a)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.14
          ..strokeCap = StrokeCap.round);
        c.drawPath(path, Paint()
          ..color = withAlpha(cl, 0.4 * a)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.065
          ..strokeCap = StrokeCap.round);
        c.drawPath(path, Paint()
          ..color = withAlpha(mix(cl, _white, 0.55), a)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.025
          ..strokeCap = StrokeCap.round);
      }
    });
  }

  /// Flamme in lokaler Ebenen-Geometrie (z nach oben).
  void _flameLocal(Canvas c, Offset base, double w, double h, double sway) {
    final path = Path()
      ..moveTo(base.dx - w, base.dy)
      ..quadraticBezierTo(base.dx - w * 0.9, base.dy + h * 0.6, base.dx + sway, base.dy + h)
      ..quadraticBezierTo(base.dx + w * 0.9, base.dy + h * 0.6, base.dx + w, base.dy)
      ..close();
    c.drawPath(
      path,
      Paint()
        ..shader = Gradient.linear(base, base.translate(0, h), [const Color(0xFFFFF2B0), const Color(0xFFFF9A2A), const Color(0x00FF4A10)], const [0, 0.5, 1]),
    );
  }

  /// Kerzenflamme in Bildschirm-Pixeln.
  void _flame(Canvas c, Offset base, double w, double h, double sway) {
    c.drawCircle(base.translate(0, -h * 0.4), h * 0.9, Paint()..color = const Color(0x22FFC060));
    final path = Path()
      ..moveTo(base.dx - w, base.dy)
      ..quadraticBezierTo(base.dx - w, base.dy - h * 0.6, base.dx + sway, base.dy - h)
      ..quadraticBezierTo(base.dx + w, base.dy - h * 0.6, base.dx + w, base.dy)
      ..close();
    c.drawPath(
      path,
      Paint()
        ..shader = Gradient.linear(base, base.translate(0, -h), [const Color(0xFFFFF6C8), const Color(0xFFFFB040), const Color(0x00FF6020)], const [0, 0.55, 1]),
    );
  }
}
