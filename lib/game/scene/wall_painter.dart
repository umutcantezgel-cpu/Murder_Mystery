import 'dart:math' as math;
import 'dart:ui';

import '../iso_math.dart';
import 'iso_pen.dart';
import 'palette.dart';

const double kWallTall = 1.6;
const double kWallLow = 0.25;
const double kDoorTop = 1.22;

/// Eine Wandkachel (`#` oder `W`).
class WallInfo {
  final int x, y;
  final bool tall;
  final bool window;

  /// Sichtbare Seiten (kein Wand-Nachbar).
  final bool south, east;

  /// Seite schaut auf eine Bodenfläche (Fenster dort).
  final bool southFloor, eastFloor;

  /// Seite schaut in einen Außenbereich (Fassade).
  final bool southOutdoor, eastOutdoor;

  const WallInfo({
    required this.x,
    required this.y,
    required this.tall,
    required this.window,
    required this.south,
    required this.east,
    required this.southFloor,
    required this.eastFloor,
    required this.southOutdoor,
    required this.eastOutdoor,
  });

  double get height => tall ? kWallTall : kWallLow;
  bool get hasWindowFace => window && tall && (southFloor || eastFloor);
}

/// Eine Türkachel (`+` oder `L`).
class DoorInfo {
  final int x, y;

  /// Wandlinie verläuft entlang x (Tür verbindet Nord und Süd).
  final bool alongX;
  final bool tall;
  final bool locked;

  const DoorInfo({required this.x, required this.y, required this.alongX, required this.tall, required this.locked});
}

typedef _FaceAt = Offset Function(double u, double z);

class WallPainter {
  final ScenePalette pal;

  WallPainter(this.pal);

  static const _black = Color(0xFF000000);
  static const _white = Color(0xFFFFFFFF);

  void paintWall(Canvas c, WallInfo w) {
    final h = w.height;
    final x = w.x.toDouble(), y = w.y.toDouble();
    if (w.south) {
      _face(c, (u, z) => Iso.toScreen(x + u, y + 1, z), h, 0.0, w.window && w.southFloor, w.southOutdoor, w.tall);
    }
    if (w.east) {
      _face(c, (u, z) => Iso.toScreen(x + 1, y + 1 - u, z), h, 0.24, w.window && w.eastFloor, w.eastOutdoor, w.tall);
    }
    // Oberseite
    final top = [
      Iso.toScreen(x, y, h),
      Iso.toScreen(x + 1, y, h),
      Iso.toScreen(x + 1, y + 1, h),
      Iso.toScreen(x, y + 1, h),
    ];
    final topCol = w.tall ? pal.wallTop : shade(pal.wallTop, -0.12);
    c.drawPath(Path()..addPolygon(top, true), Paint()..color = topCol);
    if (w.tall) {
      final edge = Paint()
        ..color = withAlpha(shade(pal.wallTop, 0.25), 0.7)
        ..strokeWidth = 1;
      if (w.south) c.drawLine(top[3], top[2], edge);
      if (w.east) c.drawLine(top[2], top[1], edge);
    } else {
      // Schnittkante: dezente Schraffur zeigt die abgeschnittene Wand.
      final hatch = Paint()
        ..color = withAlpha(_black, 0.18)
        ..strokeWidth = 1;
      for (var i = 1; i < 4; i++) {
        final t = i / 4;
        c.drawLine(Iso.toScreen(x + t, y, h), Iso.toScreen(x, y + t, h), hatch);
        c.drawLine(Iso.toScreen(x + 1, y + t, h), Iso.toScreen(x + t, y + 1, h), hatch);
      }
      if (w.window) {
        final g = [Iso.toScreen(x + 0.2, y + 0.42, h + 0.01), Iso.toScreen(x + 0.8, y + 0.42, h + 0.01), Iso.toScreen(x + 0.8, y + 0.58, h + 0.01), Iso.toScreen(x + 0.2, y + 0.58, h + 0.01)];
        c.drawPath(Path()..addPolygon(g, true), Paint()..color = withAlpha(mix(pal.glass, _white, 0.3), 0.8));
      }
    }
    // Kante zwischen den Seiten
    if (w.south && w.east) {
      c.drawLine(
        Iso.toScreen(x + 1, y + 1, 0),
        Iso.toScreen(x + 1, y + 1, h),
        Paint()
          ..color = withAlpha(_white, 0.07)
          ..strokeWidth = 1,
      );
    }
  }

  void _face(Canvas c, _FaceAt at, double h, double dim, bool window, bool outdoor, bool tall) {
    Color d(Color col) => shade(col, -dim);
    List<Offset> q(double u0, double u1, double z0, double z1) => [at(u0, z0), at(u1, z0), at(u1, z1), at(u0, z1)];
    void fillQ(List<Offset> pts, Paint p) => c.drawPath(Path()..addPolygon(pts, true), p);

    final base = q(0, 1, 0, h);
    final bTop = at(0.5, h), bBot = at(0.5, 0);
    fillQ(
      base,
      Paint()
        ..shader = Gradient.linear(bTop, bBot, [d(shade(pal.wall, 0.1)), d(shade(pal.wall, -0.18))]),
    );
    if (!tall) {
      fillQ(q(0, 1, h - 0.04, h), Paint()..color = d(shade(pal.wallTop, -0.2)));
      return;
    }
    final line = Paint()..strokeWidth = 1;
    if (outdoor) {
      // Fassade: Mauerwerk.
      fillQ(q(0, 1, 0, 0.16), Paint()..color = d(shade(pal.wall, -0.3)));
      line.color = withAlpha(d(shade(pal.wall, -0.45)), 0.55);
      var row = 0;
      for (var z = 0.16; z < h - 0.05; z += 0.18) {
        c.drawLine(at(0, z), at(1, z), line);
        final off = row.isEven ? 0.0 : 0.25;
        for (var u = off; u < 1; u += 0.5) {
          if (u > 0.01) c.drawLine(at(u, z), at(u, math.min(h, z + 0.18)), line);
        }
        row++;
      }
      fillQ(q(0, 1, h - 0.07, h), Paint()..color = d(shade(pal.wallTop, -0.05)));
    } else {
      // Innenwand: Täfelung, Tapete, Stuck.
      fillQ(q(0, 1, 0, 0.5), Paint()..color = d(mix(shade(pal.wall, -0.16), pal.trim, 0.06)));
      line.color = withAlpha(d(shade(pal.wall, 0.12)), 0.45);
      for (var u = 0.125; u < 1; u += 0.25) {
        c.drawLine(at(u, 0.56), at(u, 1.46), line);
      }
      // Paneele
      final panel = Paint()
        ..color = withAlpha(d(shade(pal.wall, -0.35)), 0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8;
      fillQ(q(0.1, 0.45, 0.1, 0.4), panel);
      fillQ(q(0.55, 0.9, 0.1, 0.4), panel);
      fillQ(q(0, 1, 0.48, 0.53), Paint()..color = d(withAlpha(pal.trim, 0.85)));
      fillQ(q(0, 1, 0, 0.06), Paint()..color = d(shade(pal.wall, -0.5)));
      fillQ(q(0, 1, h - 0.1, h - 0.05), Paint()..color = d(withAlpha(pal.trim, 0.55)));
    }
    if (window) _window(c, at, d, outdoor);
  }

  void _window(Canvas c, _FaceAt at, Color Function(Color) d, bool outdoor) {
    List<Offset> q(double u0, double u1, double z0, double z1) => [at(u0, z0), at(u1, z0), at(u1, z1), at(u0, z1)];
    void fillQ(List<Offset> pts, Paint p) => c.drawPath(Path()..addPolygon(pts, true), p);
    const u0 = 0.2, u1 = 0.8, z0 = 0.6, z1 = 1.36;
    fillQ(q(u0 - 0.05, u1 + 0.05, z0 - 0.06, z1 + 0.05), Paint()..color = d(shade(pal.trim, -0.35)));
    final glassTop = at(0.5, z1), glassBot = at(0.5, z0);
    final colors = outdoor
        ? [d(withAlpha(pal.light, 0.95)), d(mix(pal.light, const Color(0xFF8A4B1C), 0.55))]
        : [d(mix(pal.glass, const Color(0xFF7FA0C8), 0.35)), d(shade(pal.glass, -0.35))];
    fillQ(q(u0, u1, z0, z1), Paint()..shader = Gradient.linear(glassTop, glassBot, colors));
    // Spiegelung
    final refl = Paint()..color = withAlpha(_white, outdoor ? 0.18 : 0.12);
    c.drawPath(Path()..addPolygon([at(u0 + 0.06, z1 - 0.05), at(u0 + 0.2, z1 - 0.05), at(u0 + 0.06, z0 + 0.3)], true), refl);
    final frame = Paint()
      ..color = d(pal.trim)
      ..strokeWidth = 1.4;
    c.drawLine(at(0.5, z0), at(0.5, z1), frame);
    c.drawLine(at(u0, (z0 + z1) / 2 + 0.06), at(u1, (z0 + z1) / 2 + 0.06), frame);
    fillQ(q(u0 - 0.07, u1 + 0.07, z0 - 0.08, z0 - 0.03), Paint()..color = d(shade(pal.trim, 0.1)));
  }

  /// Animierter Fenster-Effekt (Regen/Schnee/Blitz), pro Frame.
  void paintWindowWeather(Canvas c, WallInfo w, String weather, double t, double flash) {
    if (!w.hasWindowFace) return;
    final x = w.x.toDouble(), y = w.y.toDouble();
    final faces = <_FaceAt>[
      if (w.south && w.southFloor) (u, z) => Iso.toScreen(x + u, y + 1, z),
      if (w.east && w.eastFloor) (u, z) => Iso.toScreen(x + 1, y + 1 - u, z),
    ];
    final seed = (w.x * 31 + w.y * 17) % 97;
    for (final at in faces) {
      if (flash > 0.01) {
        final pts = [at(0.2, 0.6), at(0.8, 0.6), at(0.8, 1.36), at(0.2, 1.36)];
        c.drawPath(Path()..addPolygon(pts, true), Paint()..color = withAlpha(const Color(0xFFE8F0FF), 0.85 * flash));
      }
      if (weather == 'rain' || weather == 'neon') {
        final p = Paint()
          ..color = withAlpha(const Color(0xFFB8C8DC), 0.55)
          ..strokeWidth = 0.9;
        for (var i = 0; i < 4; i++) {
          final u = 0.25 + ((seed * (i + 3)) % 50) / 100;
          final ph = ((t * (0.55 + i * 0.13) + i * 0.37 + seed * 0.01) % 1.0);
          final z = 1.32 - ph * 0.68;
          c.drawLine(at(u, z), at(u + 0.01, z - 0.09), p);
        }
      } else if (weather == 'snow') {
        final p = Paint()..color = withAlpha(_white, 0.75);
        for (var i = 0; i < 4; i++) {
          final ph = ((t * (0.18 + i * 0.05) + i * 0.29 + seed * 0.01) % 1.0);
          final u = 0.26 + ((seed * (i + 5)) % 48) / 100 + 0.04 * math.sin(t * 1.5 + i);
          c.drawCircle(at(u, 1.32 - ph * 0.68), 1.1, p);
        }
      }
    }
  }

  // --- Türen ---------------------------------------------------------------

  void paintDoor(Canvas c, DoorInfo d, {required bool open}) {
    final pen = IsoPen(c, d.x.toDouble(), d.y.toDouble());
    final x0 = d.alongX ? 0.0 : 0.0, x1 = 1.0, y0 = 0.0, y1 = 1.0;
    final wood = mix(pal.wood, pal.trim, 0.08);
    // Schwelle
    if (d.alongX) {
      pen.worldBox(x0, 0.38, x1, 0.62, 0, 0.025, shade(pal.darkWood, 0.1));
    } else {
      pen.worldBox(0.38, y0, 0.62, y1, 0, 0.025, shade(pal.darkWood, 0.1));
    }
    if (d.locked && !open) {
      // Geschlossene Tür mit Schloss.
      final zTop = d.tall ? kDoorTop : 0.6;
      if (d.alongX) {
        pen.worldBox(0.05, 0.44, 0.95, 0.56, 0, zTop, wood);
        Offset at(double u, double z) => pen.w(u, 0.56, z);
        _doorPanels(c, at, zTop, 0.05, 0.95, wood);
        _lock(c, at, 0.8, zTop * 0.48);
      } else {
        pen.worldBox(0.44, 0.05, 0.56, 0.95, 0, zTop, wood);
        Offset at(double u, double z) => pen.w(0.56, 1 - u, z);
        _doorPanels(c, at, zTop, 0.05, 0.95, shade(wood, -0.2));
        _lock(c, at, 0.8, zTop * 0.48);
      }
    } else if (d.locked && open) {
      // Aufgeschwungenes Türblatt an der Angel.
      final zTop = d.tall ? kDoorTop : 0.6;
      if (d.alongX) {
        pen.worldBox(0.04, 0.5, 0.13, 1.0, 0, zTop, wood);
      } else {
        pen.worldBox(0.5, 0.04, 1.0, 0.13, 0, zTop, wood);
      }
    }
    if (d.tall) {
      // Sturz über der Tür.
      pen.worldBox(0, 0, 1, 1, kDoorTop, kWallTall, pal.wall, top: pal.wallTop, eastC: shade(pal.wall, -0.24));
      final trim = mix(pal.trim, pal.darkWood, 0.5);
      if (d.alongX) {
        pen.worldBox(0, 0.9, 0.08, 1.0, 0, kDoorTop, trim, top: shade(trim, 0.1));
        pen.worldBox(0.92, 0.9, 1.0, 1.0, 0, kDoorTop, trim, top: shade(trim, 0.1));
        pen.worldBox(0, 0.9, 1.0, 1.0, kDoorTop - 0.06, kDoorTop + 0.02, trim);
      } else {
        pen.worldBox(0.9, 0, 1.0, 0.08, 0, kDoorTop, trim, top: shade(trim, 0.1));
        pen.worldBox(0.9, 0.92, 1.0, 1.0, 0, kDoorTop, trim, top: shade(trim, 0.1));
        pen.worldBox(0.9, 0, 1.0, 1.0, kDoorTop - 0.06, kDoorTop + 0.02, trim);
      }
    } else {
      // Niedrige Pfosten in der Stumpfwand.
      final col = shade(pal.wall, 0.05);
      final top = mix(pal.trim, pal.darkWood, 0.55);
      if (d.alongX) {
        pen.worldBox(0, 0.25, 0.1, 0.75, 0, kWallLow + 0.04, col, top: top);
        pen.worldBox(0.9, 0.25, 1, 0.75, 0, kWallLow + 0.04, col, top: top);
      } else {
        pen.worldBox(0.25, 0, 0.75, 0.1, 0, kWallLow + 0.04, col, top: top);
        pen.worldBox(0.25, 0.9, 0.75, 1, 0, kWallLow + 0.04, col, top: top);
      }
    }
  }

  /// Türblatt einer unverschlossenen Tür, um die Angel gedreht ([winkel] 0 =
  /// geschlossen, π/2 = ganz offen nach Süden bzw. Osten). Höhe [hoehe].
  void paintDoorLeaf(Canvas c, DoorInfo d, double winkel, double hoehe) {
    final ox = d.x.toDouble(), oy = d.y.toDouble();
    Offset w(double x, double y, double z) => Iso.toScreen(ox + x, oy + y, z);
    final angel = d.alongX ? const Offset(0.08, 0.5) : const Offset(0.5, 0.08);
    final dir = d.alongX ? Offset(math.cos(winkel), math.sin(winkel)) : Offset(math.sin(winkel), math.cos(winkel));
    const laenge = 0.84, dicke = 0.05;
    final n = Offset(-dir.dy, dir.dx) * (dicke / 2);
    final a = angel - n, b = angel + n;
    final ae = a + dir * laenge, be = b + dir * laenge;
    final holz = mix(pal.wood, pal.trim, 0.08);
    // Sichtbar ist die Seite, deren Normale zur Kamera (+x +y) zeigt.
    final vorn = (n.dx + n.dy) > 0;
    final (f0, f1) = vorn ? (b, be) : (a, ae);
    final licht = ((vorn ? n : -n).dx * -1 + (vorn ? n : -n).dy) / (dicke / 2) * 0.08;
    final flaeche = shade(holz, licht.clamp(-0.25, 0.15));
    List<Offset> quad(Offset p, Offset q) => [w(p.dx, p.dy, 0), w(q.dx, q.dy, 0), w(q.dx, q.dy, hoehe), w(p.dx, p.dy, hoehe)];
    final schatten = Paint()..color = withAlpha(const Color(0xFF000000), 0.18);
    c.drawPath(Path()..addPolygon([w(a.dx, a.dy, 0), w(ae.dx, ae.dy, 0), w(be.dx + 0.06, be.dy + 0.06, 0), w(b.dx + 0.06, b.dy + 0.06, 0)], true), schatten);
    // Stirnkante am freien Ende, große Fläche, Oberkante.
    c.drawPath(Path()..addPolygon(quad(ae, be), true), Paint()..color = shade(holz, -0.3));
    c.drawPath(Path()..addPolygon(quad(f0, f1), true), Paint()..color = flaeche);
    c.drawPath(Path()..addPolygon([w(a.dx, a.dy, hoehe), w(ae.dx, ae.dy, hoehe), w(be.dx, be.dy, hoehe), w(b.dx, b.dy, hoehe)], true), Paint()..color = shade(holz, 0.12));
    Offset at(double u, double z) {
      final p = Offset.lerp(f0, f1, u)!;
      return w(p.dx, p.dy, z);
    }

    if (hoehe > 0.5) _doorPanels(c, at, hoehe, 0.0, 1.0, flaeche);
    final knauf = at(0.86, hoehe * 0.48);
    c.drawCircle(knauf, 1.6, Paint()..color = const Color(0xFFC8A24A));
    c.drawCircle(knauf.translate(-0.4, -0.4), 0.6, Paint()..color = withAlpha(const Color(0xFFFFFFFF), 0.6));
  }

  void _doorPanels(Canvas c, _FaceAt at, double h, double u0, double u1, Color wood) {
    final p = Paint()
      ..color = withAlpha(shade(wood, -0.45), 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9;
    final m = (u1 - u0) * 0.14;
    for (final (a, b) in [(0.08, 0.45), (0.55, 0.92)]) {
      final pts = [at(u0 + m, h * a), at(u1 - m, h * a), at(u1 - m, h * b), at(u0 + m, h * b)];
      c.drawPath(Path()..addPolygon(pts, true), p);
    }
  }

  void _lock(Canvas c, _FaceAt at, double u, double z) {
    final gold = mix(pal.trim, const Color(0xFFE8C860), 0.4);
    final plate = [at(u - 0.05, z - 0.08), at(u + 0.05, z - 0.08), at(u + 0.05, z + 0.08), at(u - 0.05, z + 0.08)];
    c.drawPath(Path()..addPolygon(plate, true), Paint()..color = gold);
    final ctr = at(u, z + 0.01);
    c.drawCircle(ctr, 1.4, Paint()..color = const Color(0xFF120C08));
    // Vorhängeschloss
    final pl = at(u - 0.2, z - 0.05);
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: pl, width: 7, height: 6), const Radius.circular(1.5)), Paint()..color = gold);
    c.drawArc(
      Rect.fromCenter(center: pl.translate(0, -3), width: 5, height: 6),
      math.pi,
      math.pi,
      false,
      Paint()
        ..color = shade(gold, -0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
  }
}
