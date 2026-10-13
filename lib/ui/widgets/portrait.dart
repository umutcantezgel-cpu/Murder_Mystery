import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:mordakte_core/mordakte_core.dart';

import '../../app/theme.dart';
import '../../game/scene/figur_rig.dart';
import '../../game/scene/figure_painter.dart' show FigureLook, aussehenAus;
import '../../game/scene/palette.dart' show mix, shade;

/// Code-gezeichnete Büste einer Figur (Verdächtige, Detektive).
class Portrait extends StatelessWidget {
  const Portrait({
    super.key,
    required this.look,
    this.size = 96,
    this.background = true,
    this.accent = Noir.brass,
    this.dead = false,
    this.circle = false,
  });

  final LookDef look;
  final double size;
  final bool background;
  final Color accent;
  final bool dead;
  final bool circle;

  @override
  Widget build(BuildContext context) {
    Widget p = CustomPaint(
      size: Size.square(size),
      painter: PortraitPainter(look: look, background: background, accent: accent),
    );
    if (dead) {
      p = ColorFiltered(
        colorFilter: const ColorFilter.matrix(_grey),
        child: Opacity(opacity: 0.6, child: p),
      );
    }
    if (circle) p = ClipOval(child: p);
    return SizedBox.square(dimension: size, child: p);
  }
}

const _grey = <double>[
  0.33, 0.33, 0.33, 0, 0, //
  0.33, 0.33, 0.33, 0, 0, //
  0.33, 0.33, 0.33, 0, 0, //
  0, 0, 0, 1, 0,
];

/// Mini-Avatar eines Detektivs (Mantelfarbe + Hut).
class DetectiveAvatar extends StatelessWidget {
  const DetectiveAvatar({
    super.key,
    required this.coat,
    required this.hat,
    this.size = 40,
    this.ring,
    this.ghost = false,
  });

  final int coat;
  final String hat;
  final double size;
  final Color? ring;
  final bool ghost;

  @override
  Widget build(BuildContext context) {
    final c = detectiveCoats[coat.clamp(0, detectiveCoats.length - 1)];
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Noir.night3,
        border: Border.all(color: ring ?? hexColor(c).withValues(alpha: 0.8), width: size > 36 ? 2 : 1.5),
      ),
      child: ClipOval(
        child: Opacity(
          opacity: ghost ? 0.45 : 1,
          child: Portrait(
            look: LookDef(coat: c, hat: hat, hair: '#3b2a20'),
            size: size,
            background: false,
          ),
        ),
      ),
    );
  }
}

/// Bildnis einer Figur wie ein Atelierfoto: dieselben Merkmale wie die Figur
/// auf der Karte (Frisur, Brille, Bart, Schal, Augenfarbe, Hemd und Krawatte
/// aus [FigurAussehen]), Führungslicht von links oben, Kantenlicht rechts.
/// Hängt nur vom Aussehen ab (gleich für alle Rollen).
class PortraitPainter extends CustomPainter {
  PortraitPainter({required this.look, this.background = true, this.accent = Noir.brass});

  final LookDef look;
  final bool background;
  final Color accent;

  static final Map<int, FigurAussehen> _cache = {};

  static const _tinte = Color(0xFF14101A);
  static const _weiss = Color(0xFFFFFFFF);
  static const _schwarz = Color(0xFF000000);

  FigurAussehen get _a {
    final l = FigureLook.fromLook(look);
    return _cache[Object.hash(l.coat, l.skin, l.hair, l.hatColor, l.hat, l.build, l.dress, l.weiblich)] ??= aussehenAus(l);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final a = _a;
    final u = size.width / 100;
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    if (background) _hintergrund(canvas, size);
    canvas.scale(u);
    // Klein: etwas tiefer und kleiner im Bild.
    if (a.statur == 'small') {
      canvas.translate(5, 9);
      canvas.scale(0.9);
    } else if (a.statur == 'tall') {
      canvas.translate(0, -2);
    }
    // Nah wie ein Atelier- oder Fahndungsfoto: Kopf groß, Schultern am Bildrand.
    canvas.translate(50, 54);
    canvas.scale(1.16);
    canvas.translate(-50, -50);
    final k = _Kopf.fuer(a);
    _haarHinten(canvas, a, k);
    _koerper(canvas, a, k);
    _hals(canvas, a, k);
    if (a.hut != 'kopftuch') _ohren(canvas, a, k);
    _gesichtsform(canvas, a, k);
    _gesicht(canvas, a, k);
    _haarVorn(canvas, a, k);
    _kopfbedeckung(canvas, a, k);
    if (a.brille) _brille(canvas, k);
    canvas.restore();
  }

  void _hintergrund(Canvas c, Size size) {
    final r = Offset.zero & size;
    c.drawRect(
      r,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.35, -0.45),
          radius: 1.0,
          colors: [Color.lerp(accent, Noir.night3, 0.7)!, Noir.night2, const Color(0xFF07080E)],
          stops: const [0, 0.58, 1],
        ).createShader(r),
    );
    // Lichtkegel des Ateliers hinter dem Kopf.
    c.drawOval(
      Rect.fromCenter(center: Offset(size.width * 0.44, size.height * 0.4), width: size.width * 0.9, height: size.height * 0.8),
      Paint()
        ..shader = RadialGradient(colors: [_weiss.withValues(alpha: 0.08), _weiss.withValues(alpha: 0)]).createShader(
          Rect.fromCenter(center: Offset(size.width * 0.44, size.height * 0.4), width: size.width * 0.9, height: size.height * 0.8),
        ),
    );
  }

  // --- Körper ------------------------------------------------------------------

  void _koerper(Canvas c, FigurAussehen a, _Kopf k) {
    final sw = switch (a.statur) { 'slim' => 31.0, 'broad' => 43.0, 'tall' => 33.0, 'small' => 34.0, _ => 37.0 };
    const schulterY = 76.0;
    final mantel = a.mantel;
    final koerper = Path()
      ..moveTo(50 - sw - 4, 104)
      ..lineTo(50 - sw - 2, schulterY + 10)
      ..quadraticBezierTo(50 - sw, schulterY - 1, 50 - sw * 0.45, schulterY - 3.5)
      ..lineTo(50 - 8, schulterY - 7)
      ..lineTo(50 + 8, schulterY - 7)
      ..lineTo(50 + sw * 0.45, schulterY - 3.5)
      ..quadraticBezierTo(50 + sw, schulterY - 1, 50 + sw + 2, schulterY + 10)
      ..lineTo(50 + sw + 4, 104)
      ..close();
    final b = koerper.getBounds();
    c.drawPath(
      koerper,
      Paint()
        ..shader = LinearGradient(
          colors: [shade(mantel, 0.16), mantel, shade(mantel, -0.42)],
          stops: const [0, 0.42, 1],
        ).createShader(b),
    );
    if (a.kleid) {
      // Ausschnitt mit Perlenkette.
      final aus = Path()
        ..moveTo(50 - 10, schulterY - 6.5)
        ..quadraticBezierTo(50, 92, 50 + 10, schulterY - 6.5)
        ..close();
      c.drawPath(aus, Paint()..color = shade(a.haut, -0.12));
      c.drawPath(
        Path()
          ..moveTo(50 - 10, schulterY - 6.5)
          ..quadraticBezierTo(50, 92, 50 + 10, schulterY - 6.5),
        Paint()
          ..color = shade(mantel, -0.35)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2,
      );
      final perle = Paint()..color = const Color(0xFFF1ECE2);
      final glanz = Paint()..color = _weiss.withValues(alpha: 0.8);
      for (var i = 0; i <= 10; i++) {
        final t = i / 10;
        final x = 50 - 8 + 16 * t;
        final y = (1 - t) * (1 - t) * (schulterY - 5) + 2 * t * (1 - t) * 86 + t * t * (schulterY - 5);
        c.drawCircle(Offset(x, y), 1.15, perle);
        c.drawCircle(Offset(x - 0.35, y - 0.35), 0.35, glanz);
      }
    } else {
      // Hemd, Krawatte, Revers.
      c.drawPath(
        Path()
          ..moveTo(50 - 8.5, schulterY - 7)
          ..lineTo(50 + 8.5, schulterY - 7)
          ..lineTo(50, 96)
          ..close(),
        Paint()..color = a.hemd,
      );
      // Kragenspitzen.
      final kragen = Paint()..color = shade(a.hemd, -0.08);
      c.drawPath(Path()..addPolygon(const [Offset(41.5, 69), Offset(49, 72), Offset(45.5, 77.5)], true), kragen);
      c.drawPath(Path()..addPolygon(const [Offset(58.5, 69), Offset(51, 72), Offset(54.5, 77.5)], true), kragen);
      if (!a.weiblich && a.variante % 4 != 1) {
        final krawatte = a.krawatte;
        c.drawPath(Path()..addPolygon(const [Offset(48.2, 71.2), Offset(51.8, 71.2), Offset(51.2, 74.6), Offset(48.8, 74.6)], true), Paint()..color = shade(krawatte, 0.08));
        final blatt = Path()..addPolygon(const [Offset(48.8, 74.4), Offset(51.2, 74.4), Offset(53.2, 93), Offset(50, 97), Offset(46.8, 93)], true);
        c.drawPath(blatt, Paint()..color = krawatte);
        c.drawPath(
          blatt,
          Paint()
            ..shader = const LinearGradient(colors: [Color(0x22FFFFFF), Color(0x00FFFFFF), Color(0x33000000)]).createShader(const Rect.fromLTRB(46.8, 74, 53.2, 97)),
        );
      } else {
        // Offener Kragen; bei Frauen eine feine Kette mit Anhänger.
        c.drawPath(Path()..addPolygon(const [Offset(46.4, 70.5), Offset(53.6, 70.5), Offset(50, 80)], true), Paint()..color = shade(a.haut, -0.14));
        if (a.weiblich) {
          c.drawPath(
            Path()
              ..moveTo(46.6, 70.8)
              ..quadraticBezierTo(50, 78.5, 53.4, 70.8),
            Paint()
              ..color = const Color(0xFFD9B45A)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 0.5,
          );
          c.drawCircle(const Offset(50, 75.2), 1.1, Paint()..color = a.akzent);
          c.drawCircle(const Offset(50, 75.2), 1.1, Paint()
            ..color = const Color(0xFFD9B45A)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.4);
        }
      }
      final revers = shade(mantel, -0.22);
      final links = Path()..addPolygon(const [Offset(41, 68.5), Offset(46, 78), Offset(49.4, 98), Offset(40, 104), Offset(33.5, 77)], true);
      final rechts = Path()..addPolygon(const [Offset(59, 68.5), Offset(54, 78), Offset(50.6, 98), Offset(60, 104), Offset(66.5, 77)], true);
      c.drawPath(links, Paint()..color = shade(revers, 0.08));
      c.drawPath(rechts, Paint()..color = shade(revers, -0.12));
      final kante = Paint()
        ..color = shade(mantel, 0.3).withValues(alpha: 0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.6;
      c.drawPath(links, kante);
      c.drawPath(rechts, kante..color = shade(mantel, -0.5).withValues(alpha: 0.55));
      // Einstecktuch links (im Bild).
      c.drawPath(Path()..addPolygon(const [Offset(31, 88), Offset(36.5, 87), Offset(35, 90.5)], true), Paint()..color = a.akzent);
    }
    if (a.schal) {
      final schal = a.akzent;
      final band = Path()
        ..moveTo(50 - 11, schulterY - 9)
        ..quadraticBezierTo(50, schulterY - 3, 50 + 11, schulterY - 9)
        ..lineTo(50 + 12, schulterY - 3.5)
        ..quadraticBezierTo(50, schulterY + 2.5, 50 - 12, schulterY - 3.5)
        ..close();
      c.drawPath(band, Paint()..color = schal);
      c.drawPath(
        Path()..addPolygon([const Offset(50 + 3, schulterY - 3), const Offset(50 + 9, schulterY - 3.6), Offset(50 + 10.5, schulterY + 16), Offset(50 + 5, schulterY + 17)], true),
        Paint()..color = shade(schal, -0.15),
      );
      final streifen = Paint()
        ..color = shade(schal, 0.25).withValues(alpha: 0.6)
        ..strokeWidth = 0.6;
      c.drawLine(Offset(50 + 5.4, schulterY + 13), Offset(50 + 10.2, schulterY + 12.4), streifen);
    }
    // Kantenlicht auf der rechten Schulter.
    c.drawPath(
      Path()
        ..moveTo(50 + sw * 0.5, schulterY - 3.2)
        ..quadraticBezierTo(50 + sw, schulterY - 0.8, 50 + sw + 1.8, schulterY + 10),
      Paint()
        ..color = Color.lerp(accent, _weiss, 0.4)!.withValues(alpha: 0.38)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );
  }

  void _hals(Canvas c, FigurAussehen a, _Kopf k) {
    final hals = RRect.fromRectAndRadius(Rect.fromLTRB(50 - k.b * 0.42, k.kinn - 7, 50 + k.b * 0.42, 72), const Radius.circular(3));
    c.drawRRect(
      hals,
      Paint()
        ..shader = LinearGradient(colors: [shade(a.haut, -0.12), shade(a.haut, -0.32)]).createShader(hals.outerRect),
    );
    // Schatten unter dem Kinn.
    c.drawOval(
      Rect.fromCenter(center: Offset(50.8, k.kinn + 1.2), width: k.b * 1.2, height: 5),
      Paint()
        ..color = _schwarz.withValues(alpha: 0.22)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.4),
    );
  }

  void _ohren(Canvas c, FigurAussehen a, _Kopf k) {
    for (final s in [-1.0, 1.0]) {
      final o = Offset(50 + s * k.b * 0.98, k.augenY + 2.2);
      final r = Rect.fromCenter(center: o, width: 5.2, height: 9.0);
      c.drawOval(r, Paint()..color = shade(a.haut, s > 0 ? -0.22 : -0.06));
      c.drawArc(r.deflate(1.3), s > 0 ? -1.4 : 1.7, 2.9, false, Paint()
        ..color = shade(a.haut, -0.36)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.7);
    }
  }

  void _gesichtsform(Canvas c, FigurAussehen a, _Kopf k) {
    final form = k.form;
    final b = form.getBounds();
    c.drawPath(form, Paint()..color = _tinte.withValues(alpha: 0.45));
    c.drawPath(
      k.form,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.38, -0.32),
          radius: 0.95,
          colors: [shade(a.haut, 0.14), a.haut, shade(a.haut, -0.3)],
          stops: const [0, 0.52, 1],
        ).createShader(b.inflate(-0.6)),
    );
    c.save();
    c.clipPath(form);
    // Schattenseite rechts, Kantenlicht ganz außen.
    c.drawRect(
      b,
      Paint()
        ..shader = LinearGradient(
          colors: [_schwarz.withValues(alpha: 0), _schwarz.withValues(alpha: 0), _schwarz.withValues(alpha: 0.2)],
          stops: const [0, 0.55, 1],
        ).createShader(b),
    );
    c.drawPath(
      form.shift(const Offset(-1.6, 0)),
      Paint()
        ..color = Color.lerp(accent, _weiss, 0.55)!.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
    c.restore();
  }

  void _gesicht(Canvas c, FigurAussehen a, _Kopf k) {
    final haut = a.haut;
    final ay = k.augenY;
    final abstand = k.b * 0.42;
    final kleid = a.kleid || a.weiblich;
    // Augenbrauen.
    final braue = Paint()
      ..color = a.grau ? shade(a.haar, -0.25) : shade(a.haar, -0.15)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = kleid ? 1.15 : 1.6;
    for (final s in [-1.0, 1.0]) {
      final x = 50 + s * abstand;
      c.drawPath(
        Path()
          ..moveTo(x - s * 3.6, ay - 4.0)
          ..quadraticBezierTo(x + s * 0.2, ay - 6.0 - (kleid ? 0.4 : 0), x + s * 3.9, ay - 4.6),
        braue,
      );
    }
    // Augen.
    for (final s in [-1.0, 1.0]) {
      final x = 50 + s * abstand;
      final auge = Path()
        ..moveTo(x - 3.7, ay)
        ..quadraticBezierTo(x - 0.4, ay - 2.9, x + 3.7, ay - 0.2)
        ..quadraticBezierTo(x + 0.2, ay + 2.2, x - 3.7, ay)
        ..close();
      c.drawPath(auge, Paint()..color = const Color(0xFFF2ECE4));
      c.save();
      c.clipPath(auge);
      final iris = Offset(x - 0.5, ay - 0.2);
      c.drawCircle(iris, 1.9, Paint()..color = a.augen);
      c.drawCircle(iris, 1.9, Paint()
        ..color = shade(a.augen, -0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.4);
      c.drawCircle(iris, 0.85, Paint()..color = const Color(0xFF0C0A0C));
      c.drawCircle(iris.translate(-0.6, -0.6), 0.5, Paint()..color = _weiss.withValues(alpha: 0.9));
      // Schatten des Oberlids.
      c.drawRect(Rect.fromLTRB(x - 4, ay - 3, x + 4, ay - 1.4), Paint()..color = shade(haut, -0.35).withValues(alpha: 0.35));
      c.restore();
      // Oberlid und Wimpern, Unterlid zart.
      c.drawPath(
        Path()
          ..moveTo(x - 3.8, ay + 0.1)
          ..quadraticBezierTo(x - 0.4, ay - 3.0, x + 3.8, ay - 0.3),
        Paint()
          ..color = _tinte.withValues(alpha: 0.85)
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = kleid ? 1.05 : 0.8,
      );
      if (kleid) {
        c.drawLine(Offset(x + s * 3.6, ay - 0.3), Offset(x + s * 4.6, ay - 1.3), Paint()
          ..color = _tinte.withValues(alpha: 0.8)
          ..strokeWidth = 0.7
          ..strokeCap = StrokeCap.round);
      }
      c.drawPath(
        Path()
          ..moveTo(x - 3.0, ay + 0.9)
          ..quadraticBezierTo(x, ay + 2.1, x + 3.2, ay + 0.6),
        Paint()
          ..color = shade(haut, -0.3).withValues(alpha: 0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.5,
      );
    }
    // Nase: Rücken im Licht, Schattenkante rechts, Flügel und Spitze.
    final ny = k.nasenY;
    // Weicher Schatten neben dem Nasenrücken, kurze Kante zur Spitze.
    c.drawOval(
      Rect.fromCenter(center: Offset(52.4, ny - 3.2), width: 2.6, height: 7.5),
      Paint()
        ..color = shade(haut, -0.35).withValues(alpha: 0.28)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.1),
    );
    c.drawPath(
      Path()
        ..moveTo(52.0, ny - 3.6)
        ..quadraticBezierTo(52.9, ny - 1.8, 52.9, ny - 0.4),
      Paint()
        ..color = shade(haut, -0.38).withValues(alpha: 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.7
        ..strokeCap = StrokeCap.round,
    );
    c.drawOval(Rect.fromCenter(center: Offset(49.6, ny - 1.4), width: 2.8, height: 2.2), Paint()..color = _weiss.withValues(alpha: 0.16));
    final loch = Paint()..color = shade(haut, -0.55).withValues(alpha: 0.7);
    c.drawOval(Rect.fromCenter(center: Offset(48.2, ny + 0.5), width: 1.9, height: 1.0), loch);
    c.drawOval(Rect.fromCenter(center: Offset(52.2, ny + 0.5), width: 1.9, height: 1.0), loch);
    c.drawArc(Rect.fromCenter(center: Offset(53.2, ny - 0.3), width: 2.6, height: 2.6), -0.6, 2.4, false, Paint()
      ..color = shade(haut, -0.4).withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6);
    // Wangen.
    final rot = Paint()..color = const Color(0xFFD9786A).withValues(alpha: kleid ? 0.2 : 0.11);
    c.drawOval(Rect.fromCenter(center: Offset(50 - abstand - 1, ny), width: 7, height: 4.5), rot);
    c.drawOval(Rect.fromCenter(center: Offset(50 + abstand + 1, ny), width: 7, height: 4.5), rot);
    // Mund.
    final my = k.mundY;
    final mb = kleid ? 4.4 : 4.8;
    final lippe = mix(shade(haut, -0.28), const Color(0xFFA8484A), kleid ? 0.5 : 0.22);
    c.drawPath(
      Path()
        ..moveTo(50 - mb, my)
        ..quadraticBezierTo(50 - mb * 0.5, my - 1.7, 50 - 0.4, my - 1.0)
        ..quadraticBezierTo(50 + mb * 0.5, my - 1.9, 50 + mb, my)
        ..quadraticBezierTo(50, my + 0.5, 50 - mb, my)
        ..close(),
      Paint()..color = shade(lippe, -0.12),
    );
    c.drawPath(
      Path()
        ..moveTo(50 - mb + 0.4, my + 0.2)
        ..quadraticBezierTo(50, my + 3.0, 50 + mb - 0.4, my + 0.2)
        ..quadraticBezierTo(50, my + 0.8, 50 - mb + 0.4, my + 0.2)
        ..close(),
      Paint()..color = shade(lippe, 0.06),
    );
    c.drawLine(Offset(50 - 1.4, my + 1.2), Offset(50 + 0.6, my + 1.2), Paint()
      ..color = _weiss.withValues(alpha: 0.25)
      ..strokeWidth = 0.6
      ..strokeCap = StrokeCap.round);
    c.drawPath(
      Path()
        ..moveTo(50 - mb, my)
        ..quadraticBezierTo(50, my + 0.7, 50 + mb, my),
      Paint()
        ..color = shade(haut, -0.6).withValues(alpha: 0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.6,
    );
    // Kinnschatten.
    c.drawOval(Rect.fromCenter(center: Offset(50.6, my + 5.2), width: 6, height: 2.2), Paint()..color = shade(haut, -0.3).withValues(alpha: 0.25));
    if (a.bart > 0) _bart(c, a, k);
  }

  void _bart(Canvas c, FigurAussehen a, _Kopf k) {
    final farbe = a.grau ? shade(a.haar, -0.05) : shade(a.haar, -0.05);
    final my = k.mundY;
    final schnurr = Path()
      ..moveTo(50 - 6.2, my + 0.2)
      ..quadraticBezierTo(50 - 4.0, my - 3.8, 50, my - 2.6)
      ..quadraticBezierTo(50 + 4.0, my - 3.8, 50 + 6.2, my + 0.2)
      ..quadraticBezierTo(50 + 3.0, my - 1.4, 50, my - 1.4)
      ..quadraticBezierTo(50 - 3.0, my - 1.4, 50 - 6.2, my + 0.2)
      ..close();
    if (a.bart == 2) {
      final b = k.b;
      final voll = Path()
        ..moveTo(50 - b * 0.98, k.augenY + 3.5)
        ..quadraticBezierTo(50 - b * 0.95, k.kinn - 1, 50 - b * 0.4, k.kinn + 1.2)
        ..quadraticBezierTo(50, k.kinn + 3.0, 50 + b * 0.4, k.kinn + 1.2)
        ..quadraticBezierTo(50 + b * 0.95, k.kinn - 1, 50 + b * 0.98, k.augenY + 3.5)
        ..lineTo(50 + b * 0.78, k.augenY + 4.5)
        ..quadraticBezierTo(50 + b * 0.62, my + 1.5, 50 + 5, my + 2.2)
        ..quadraticBezierTo(50, my + 4.2, 50 - 5, my + 2.2)
        ..quadraticBezierTo(50 - b * 0.62, my + 1.5, 50 - b * 0.78, k.augenY + 4.5)
        ..close();
      c.drawPath(voll, Paint()..color = farbe);
      final strich = Paint()
        ..color = shade(farbe, 0.18).withValues(alpha: 0.45)
        ..strokeWidth = 0.4
        ..strokeCap = StrokeCap.round;
      for (var i = 0; i < 18; i++) {
        final t = i / 17;
        final x = 50 - b * 0.85 + t * b * 1.7;
        final y = k.kinn - 3 + math.sin(t * math.pi) * 3.2;
        c.drawLine(Offset(x, y), Offset(x + 0.3, y + 1.6), strich);
      }
    }
    c.drawPath(schnurr, Paint()..color = shade(farbe, -0.08));
  }

  // --- Haare -------------------------------------------------------------------

  void _haarHinten(Canvas c, FigurAussehen a, _Kopf k) {
    if (a.hut == 'kopftuch' || a.hut == 'cloche') return;
    final haar = Paint()..color = shade(a.haar, -0.2);
    switch (a.frisur) {
      case Frisur.lang:
        c.drawPath(
          Path()
            ..moveTo(50 - k.b * 1.25, k.oben + 10)
            ..quadraticBezierTo(50 - k.b * 1.5, 70, 50 - k.b * 1.4, 84)
            ..lineTo(50 + k.b * 1.4, 84)
            ..quadraticBezierTo(50 + k.b * 1.5, 70, 50 + k.b * 1.25, k.oben + 10)
            ..close(),
          haar,
        );
      case Frisur.zopf:
        c.drawOval(Rect.fromCenter(center: Offset(50 + k.b * 0.9, k.oben + 9), width: 9, height: 9), haar);
      default:
        break;
    }
  }

  Paint _haarFarbe(FigurAussehen a, Rect r) => Paint()
    ..shader = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [shade(a.haar, 0.18), a.haar, shade(a.haar, -0.35)],
      stops: const [0, 0.4, 1],
    ).createShader(r);

  void _haarVorn(Canvas c, FigurAussehen a, _Kopf k) {
    if (a.hut == 'kopftuch' || a.hut == 'cloche') return;
    final b = k.b, o = k.oben;
    final rect = Rect.fromLTRB(50 - b * 1.3, o - 4, 50 + b * 1.3, k.augenY + 12);
    final p = _haarFarbe(a, rect);
    final glanz = Paint()
      ..color = _weiss.withValues(alpha: 0.18)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1.2;
    final mitHut = a.hut != 'none' && a.hut != 'bun';
    switch (a.frisur) {
      case Frisur.glatze:
        // Kranz an den Seiten.
        for (final s in [-1.0, 1.0]) {
          c.drawPath(
            Path()
              ..moveTo(50 + s * b * 0.98, k.augenY - 6)
              ..quadraticBezierTo(50 + s * b * 1.12, k.augenY, 50 + s * b * 0.95, k.augenY + 6)
              ..lineTo(50 + s * b * 0.8, k.augenY + 5)
              ..quadraticBezierTo(50 + s * b * 0.92, k.augenY - 1, 50 + s * b * 0.82, k.augenY - 6)
              ..close(),
            p,
          );
        }
        c.drawArc(Rect.fromCenter(center: Offset(46, o + 7), width: 12, height: 8), 3.6, 1.2, false, glanz..color = _weiss.withValues(alpha: 0.28));
      case Frisur.locken:
        final rng = math.Random(a.variante);
        final kreis = <Offset>[];
        for (var i = 0; i < 26; i++) {
          final w = math.pi + i / 25 * math.pi;
          final rr = 1.02 + rng.nextDouble() * 0.12;
          kreis.add(Offset(50 + math.cos(w) * b * rr, o + 15 + math.sin(w) * 16 * rr));
        }
        for (var i = 0; i < 9; i++) {
          kreis.add(Offset(50 - b * 0.7 + i * b * 0.18, o + 3 + rng.nextDouble() * 4));
        }
        for (final q in kreis) {
          c.drawCircle(q, 3.6, p);
        }
        for (final q in kreis.take(12)) {
          c.drawArc(Rect.fromCircle(center: q, radius: 2.2), 3.4, 1.4, false, glanz);
        }
      case Frisur.lang || Frisur.zopf:
        // Mittelscheitel, rahmt das Gesicht.
        c.drawPath(
          Path()
            ..moveTo(50, o - 1)
            ..quadraticBezierTo(50 - b * 1.2, o - 1, 50 - b * 1.12, k.augenY + (a.frisur == Frisur.lang ? 16 : 4))
            ..lineTo(50 - b * 0.82, k.augenY + (a.frisur == Frisur.lang ? 14 : 2))
            ..quadraticBezierTo(50 - b * 0.86, o + 8, 50 - 1, o + 5)
            ..lineTo(50 + 1, o + 5)
            ..quadraticBezierTo(50 + b * 0.86, o + 8, 50 + b * 0.82, k.augenY + (a.frisur == Frisur.lang ? 14 : 2))
            ..lineTo(50 + b * 1.12, k.augenY + (a.frisur == Frisur.lang ? 16 : 4))
            ..quadraticBezierTo(50 + b * 1.2, o - 1, 50, o - 1)
            ..close(),
          p,
        );
        c.drawPath(
          Path()
            ..moveTo(50 - 3, o + 2)
            ..quadraticBezierTo(50 - b * 0.8, o + 3, 50 - b * 0.95, o + 14),
          glanz,
        );
        if (a.frisur == Frisur.zopf && a.hut == 'none') {
          // Zopf über der Schulter.
          for (var i = 0; i < 5; i++) {
            c.drawOval(Rect.fromCenter(center: Offset(50 + b * 1.05 + i * 0.6, k.kinn + 2 + i * 4.2), width: 5.2, height: 5.0), p);
          }
        }
      case Frisur.zurueck:
        c.drawPath(
          Path()
            ..moveTo(50 - b * 1.02, k.augenY - 3)
            ..quadraticBezierTo(50 - b * 1.12, o - 2, 50, o - 2.5)
            ..quadraticBezierTo(50 + b * 1.12, o - 2, 50 + b * 1.02, k.augenY - 3)
            ..lineTo(50 + b * 0.9, k.augenY - 4)
            ..quadraticBezierTo(50 + b * 0.7, o + 5.5, 50, o + 6.5)
            ..quadraticBezierTo(50 - b * 0.7, o + 5.5, 50 - b * 0.9, k.augenY - 4)
            ..close(),
          p,
        );
        for (var i = -2; i <= 2; i++) {
          c.drawPath(
            Path()
              ..moveTo(50 + i * 3.4, o + 5)
              ..quadraticBezierTo(50 + i * 3.9, o + 1, 50 + i * 4.6, o - 1.6),
            Paint()
              ..color = shade(a.haar, i < 0 ? 0.25 : -0.2).withValues(alpha: 0.5)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 0.6,
          );
        }
      case Frisur.seitenscheitel || Frisur.kurz:
        final scheitel = a.frisur == Frisur.seitenscheitel;
        c.drawPath(
          Path()
            ..moveTo(50 - b * 1.03, k.augenY - 2)
            ..quadraticBezierTo(50 - b * 1.14, o - 3, 50 - 2, o - 3)
            ..quadraticBezierTo(50 + b * 1.14, o - 3, 50 + b * 1.03, k.augenY - 2)
            ..lineTo(50 + b * 0.92, k.augenY - 3.5)
            ..quadraticBezierTo(50 + b * 0.8, o + 7.5, 50 + (scheitel ? 2 : 4), o + 7)
            ..quadraticBezierTo(50 - b * 0.4, o + (scheitel ? 10 : 7.5), 50 - b * 0.92, k.augenY - 3.5)
            ..close(),
          p,
        );
        // Strähnen.
        final straehne = Paint()
          ..color = shade(a.haar, -0.35).withValues(alpha: 0.35)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.45
          ..strokeCap = StrokeCap.round;
        for (var i = 0; i < 7; i++) {
          final x = 50 - b * 0.75 + i * b * 0.25;
          c.drawPath(
            Path()
              ..moveTo(x, o - 1.5 + (i - 3).abs() * 0.4)
              ..quadraticBezierTo(x + 1.6, o + 2, x + 2.4 + (scheitel ? 0.8 : 0), o + 5.2),
            straehne,
          );
        }
        if (scheitel) {
          c.drawLine(Offset(50 - b * 0.4, o - 1.5), Offset(50 - b * 0.46, o + 5.5), Paint()
            ..color = shade(a.haar, -0.45)
            ..strokeWidth = 0.6);
        }
        if (!mitHut) {
          c.drawPath(
            Path()
              ..moveTo(50 - b * 0.2, o)
              ..quadraticBezierTo(50 + b * 0.5, o - 0.5, 50 + b * 0.8, o + 5),
            glanz,
          );
        }
    }
  }

  // --- Kopfbedeckung -------------------------------------------------------------

  void _kopfbedeckung(Canvas c, FigurAussehen a, _Kopf k) {
    final f = a.hutFarbe;
    final b = k.b, o = k.oben;
    final kante = Paint()
      ..color = _tinte.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6;
    Paint verlauf(Rect r, Color col) => Paint()
      ..shader = LinearGradient(colors: [shade(col, 0.18), col, shade(col, -0.4)], stops: const [0, 0.45, 1]).createShader(r);
    switch (a.hut) {
      case 'fedora':
        final krempe = Rect.fromCenter(center: Offset(50, o + 6.5), width: b * 3.2, height: 9);
        c.drawOval(krempe, verlauf(krempe, shade(f, -0.1)));
        final krone = Path()
          ..moveTo(50 - b * 0.98, o + 6.5)
          ..quadraticBezierTo(50 - b * 1.0, o - 10, 50 - b * 0.3, o - 11)
          ..quadraticBezierTo(50, o - 8.5, 50 + b * 0.3, o - 11)
          ..quadraticBezierTo(50 + b * 1.0, o - 10, 50 + b * 0.98, o + 6.5)
          ..close();
        c.drawPath(krone, verlauf(krone.getBounds(), f));
        c.drawPath(krone, kante);
        c.drawPath(
          Path()
            ..moveTo(50 - b * 0.98, o + 2)
            ..lineTo(50 + b * 0.98, o + 2)
            ..lineTo(50 + b * 0.98, o + 6)
            ..quadraticBezierTo(50, o + 7.5, 50 - b * 0.98, o + 6)
            ..close(),
          Paint()..color = shade(f, -0.5),
        );
        c.drawArc(Rect.fromCenter(center: Offset(50, o + 7.5), width: b * 3.0, height: 7.5), 0.15, math.pi - 0.3, false, Paint()
          ..color = _weiss.withValues(alpha: 0.12)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.9);
      case 'bowler':
        final krempe = Rect.fromCenter(center: Offset(50, o + 5), width: b * 2.6, height: 6);
        c.drawOval(krempe, Paint()..color = shade(f, -0.15));
        final kuppel = Rect.fromLTRB(50 - b * 0.98, o - 12, 50 + b * 0.98, o + 12);
        c.drawArc(kuppel, math.pi, math.pi, true, verlauf(kuppel, f));
        c.drawArc(kuppel.deflate(3), 3.6, 1.0, false, Paint()
          ..color = _weiss.withValues(alpha: 0.25)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2);
        c.drawRect(Rect.fromLTRB(50 - b * 0.98, o + 1, 50 + b * 0.98, o + 4), Paint()..color = shade(f, -0.45));
      case 'top':
        final krempe = Rect.fromCenter(center: Offset(50, o + 5), width: b * 2.7, height: 6.5);
        c.drawOval(krempe, Paint()..color = shade(f, -0.15));
        final zyl = Rect.fromLTRB(50 - b * 0.86, o - 22, 50 + b * 0.86, o + 5);
        c.drawRect(zyl, verlauf(zyl, f));
        c.drawOval(Rect.fromCenter(center: Offset(50, o - 22), width: b * 1.72, height: 4), Paint()..color = shade(f, 0.12));
        c.drawRect(Rect.fromLTRB(50 - b * 0.86, o - 2, 50 + b * 0.86, o + 2), Paint()..color = shade(a.akzent, -0.3));
      case 'cap':
        final krone = Path()
          ..moveTo(50 - b * 1.08, o + 7)
          ..quadraticBezierTo(50 - b * 1.2, o - 6, 50, o - 6.5)
          ..quadraticBezierTo(50 + b * 1.25, o - 6, 50 + b * 1.12, o + 7)
          ..close();
        c.drawPath(krone, verlauf(krone.getBounds(), f));
        c.drawPath(krone, kante);
        final schirm = Path()
          ..moveTo(50 - b * 0.95, o + 6.4)
          ..quadraticBezierTo(50, o + 12.5, 50 + b * 0.95, o + 6.4)
          ..quadraticBezierTo(50, o + 8.6, 50 - b * 0.95, o + 6.4)
          ..close();
        c.drawPath(schirm, Paint()..color = shade(f, -0.35));
        c.drawCircle(Offset(50, o - 5.5), 1.0, Paint()..color = shade(f, -0.3));
      case 'beret':
        c.save();
        c.translate(48, o + 1);
        c.rotate(-0.16);
        final r = Rect.fromCenter(center: Offset.zero, width: b * 2.5, height: 11);
        c.drawOval(r, verlauf(r, f));
        c.drawOval(r, kante);
        c.drawLine(const Offset(0, -5.4), const Offset(0.4, -7.4), Paint()
          ..color = shade(f, -0.3)
          ..strokeWidth = 1.2
          ..strokeCap = StrokeCap.round);
        c.restore();
      case 'cloche':
        final glocke = Path()
          ..moveTo(50 - b * 1.18, k.augenY - 2)
          ..quadraticBezierTo(50 - b * 1.25, o - 7, 50, o - 7)
          ..quadraticBezierTo(50 + b * 1.25, o - 7, 50 + b * 1.18, k.augenY - 2)
          ..quadraticBezierTo(50, k.augenY - 7.5, 50 - b * 1.18, k.augenY - 2)
          ..close();
        c.drawPath(glocke, verlauf(glocke.getBounds(), f));
        c.drawPath(glocke, kante);
        c.drawPath(
          Path()
            ..moveTo(50 - b * 1.12, o + 5)
            ..quadraticBezierTo(50, o + 1.5, 50 + b * 1.12, o + 5)
            ..lineTo(50 + b * 1.14, o + 8)
            ..quadraticBezierTo(50, o + 4.5, 50 - b * 1.14, o + 8)
            ..close(),
          Paint()..color = shade(a.akzent, -0.15),
        );
        c.drawCircle(Offset(50 + b * 0.62, o + 5.2), 1.6, Paint()..color = const Color(0xFFB8963A));
      case 'bun':
        final dutt = Rect.fromCenter(center: Offset(50, o - 3.5), width: 12, height: 10);
        c.drawOval(dutt, _haarFarbe(a, dutt));
        c.drawArc(dutt.deflate(2.5), 3.5, 1.4, false, Paint()
          ..color = _weiss.withValues(alpha: 0.2)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.9);
      case 'kopftuch':
        final tuch = Path()
          ..moveTo(50, o - 4)
          ..quadraticBezierTo(50 - b * 1.4, o - 3, 50 - b * 1.18, k.augenY + 8)
          ..quadraticBezierTo(50 - b * 1.0, k.kinn + 5, 50, k.kinn + 6)
          ..quadraticBezierTo(50 + b * 1.0, k.kinn + 5, 50 + b * 1.18, k.augenY + 8)
          ..quadraticBezierTo(50 + b * 1.4, o - 3, 50, o - 4)
          ..close();
        final innen = Path()
          ..moveTo(50, o + 3.5)
          ..quadraticBezierTo(50 - b * 0.98, o + 4, 50 - b * 0.92, k.augenY + 5)
          ..quadraticBezierTo(50 - b * 0.7, k.kinn + 0.5, 50, k.kinn + 1)
          ..quadraticBezierTo(50 + b * 0.7, k.kinn + 0.5, 50 + b * 0.92, k.augenY + 5)
          ..quadraticBezierTo(50 + b * 0.98, o + 4, 50, o + 3.5)
          ..close();
        final ring = Path()
          ..fillType = PathFillType.evenOdd
          ..addPath(tuch, Offset.zero)
          ..addPath(innen, Offset.zero);
        c.drawPath(ring, verlauf(tuch.getBounds(), f));
        c.drawPath(ring, kante);
        // Falten.
        final falte = Paint()
          ..color = shade(f, -0.3).withValues(alpha: 0.6)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.6;
        for (final s in [-1.0, 1.0]) {
          c.drawPath(
            Path()
              ..moveTo(50 + s * b * 0.5, o - 1)
              ..quadraticBezierTo(50 + s * b * 1.15, o + 6, 50 + s * b * 1.05, k.augenY + 10),
            falte,
          );
        }
    }
  }

  void _brille(Canvas c, _Kopf k) {
    final abstand = k.b * 0.42;
    final rahmen = Paint()
      ..color = const Color(0xFF2A2018)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9;
    for (final s in [-1.0, 1.0]) {
      final m = Offset(50 + s * abstand, k.augenY - 0.2);
      c.drawCircle(m, 4.6, Paint()..color = const Color(0xFFB8D4E8).withValues(alpha: 0.1));
      c.drawCircle(m, 4.6, rahmen);
      c.drawArc(Rect.fromCircle(center: m, radius: 3.4), 3.6, 0.9, false, Paint()
        ..color = _weiss.withValues(alpha: 0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.7);
      c.drawLine(Offset(50 + s * (abstand + 4.6), k.augenY - 0.8), Offset(50 + s * k.b * 0.98, k.augenY - 1.6), rahmen);
    }
    c.drawArc(Rect.fromCenter(center: Offset(50, k.augenY - 0.2), width: abstand * 2 - 9.2, height: 3.2), math.pi, math.pi, false, rahmen);
  }

  @override
  bool shouldRepaint(covariant PortraitPainter old) =>
      old.look.coat != look.coat ||
      old.look.hat != look.hat ||
      old.look.hair != look.hair ||
      old.look.skin != look.skin ||
      old.look.build != look.build ||
      old.look.dress != look.dress ||
      old.look.headColor != look.headColor ||
      old.look.gender != look.gender ||
      old.background != background ||
      old.accent != accent;
}

/// Maße des Kopfes im Bild (Einheiten: Hundertstel der Bildbreite).
class _Kopf {
  _Kopf(this.b, this.oben, this.kinn)
      : augenY = oben + (kinn - oben) * 0.47,
        nasenY = oben + (kinn - oben) * 0.68,
        mundY = oben + (kinn - oben) * 0.81;

  /// Halbe Kopfbreite.
  final double b;
  final double oben, kinn;
  final double augenY, nasenY, mundY;

  factory _Kopf.fuer(FigurAussehen a) {
    final b = switch (a.statur) { 'slim' => 13.6, 'broad' => 16.2, _ => 14.8 };
    return _Kopf(b, 22, a.statur == 'broad' ? 61 : 62);
  }

  Path get form {
    final m = (oben + kinn) / 2;
    final kiefer = b * (0.6 + (b - 13.6) * 0.03);
    return Path()
      ..moveTo(50, oben)
      ..cubicTo(50 + b * 1.08, oben, 50 + b * 1.1, m - 6, 50 + b, m + 2)
      ..cubicTo(50 + b * 0.94, m + 11, 50 + kiefer, kinn - 1, 50, kinn)
      ..cubicTo(50 - kiefer, kinn - 1, 50 - b * 0.94, m + 11, 50 - b, m + 2)
      ..cubicTo(50 - b * 1.1, m - 6, 50 - b * 1.08, oben, 50, oben)
      ..close();
  }
}
