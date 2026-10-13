import 'dart:math' as math;
import 'dart:ui';

import 'package:mordakte_core/mordakte_core.dart';

import '../iso_math.dart';
import 'figur_rig.dart';

export 'figur_rig.dart' show Taetigkeit;
import 'palette.dart';

/// Aussehen einer Figur (Detektiv oder Verdächtige).
class FigureLook {
  final Color coat;
  final Color skin;
  final Color hair;
  final Color hatColor;
  final String hat;
  final String build;

  /// Kleid statt Mantel/Anzug (A-Linie, Ausschnitt statt Hemd und Krawatte).
  final bool dress;

  const FigureLook({
    required this.coat,
    required this.skin,
    required this.hair,
    required this.hatColor,
    required this.hat,
    required this.build,
    this.dress = false,
  });

  factory FigureLook.fromLook(LookDef l) {
    final coat = parseHex(l.coat) ?? const Color(0xFF3A3A44);
    return FigureLook(
      coat: coat,
      skin: parseHex(l.skin) ?? const Color(0xFFE0B89A),
      hair: parseHex(l.hair) ?? const Color(0xFF3B2A20),
      hatColor: (l.headColor == null ? null : parseHex(l.headColor!)) ?? mix(coat, const Color(0xFF16151A), 0.55),
      hat: l.hat,
      build: l.build,
      dress: l.dress,
    );
  }

  static const _skins = [Color(0xFFE8C2A4), Color(0xFFD8A882), Color(0xFFB98563), Color(0xFF8E5E40), Color(0xFFF0CDB4), Color(0xFF6E4630)];
  static const _hairs = [Color(0xFF2A1D14), Color(0xFF5A3B1E), Color(0xFF151214), Color(0xFF8A5A2E), Color(0xFFB8A27A), Color(0xFF4A2E22)];

  factory FigureLook.detective(int coatIdx, String hat, String id) {
    final coat = parseHex(detectiveCoats[coatIdx.abs() % detectiveCoats.length]) ?? const Color(0xFF6B6B6B);
    var h = 0;
    for (final cu in id.codeUnits) {
      h = (h * 31 + cu) & 0x7fffffff;
    }
    return FigureLook(
      coat: coat,
      skin: _skins[h % _skins.length],
      hair: _hairs[(h ~/ 7) % _hairs.length],
      hatColor: mix(coat, const Color(0xFF17161B), 0.62),
      hat: hat,
      build: 'normal',
    );
  }
}

/// Zeichnet Figuren in Bildschirm-Pixeln (Ursprung = Füße).
class FigurePainter {
  static const _black = Color(0xFF000000);
  static const _white = Color(0xFFFFFFFF);

  static (double, double) buildScale(String build) => switch (build) {
        'slim' => (0.86, 1.0),
        'broad' => (1.22, 0.98),
        'tall' => (0.94, 1.12),
        'small' => (0.92, 0.86),
        _ => (1.0, 1.0),
      };

  /// Höhe des Kopfes über den Füßen in Pixeln (für Sprechblasen/Ringe).
  static double headTop(String build) => FigurRig.hoehe * buildScale(build).$2;

  static const _rig = FigurRig();

  /// Aussehen fürs Rig, je Farbkombination nur einmal abgeleitet.
  final Map<int, FigurAussehen> _aussehen = {};

  FigurAussehen _fuerRig(FigureLook l) => _aussehen[Object.hash(l.coat, l.skin, l.hair, l.hatColor, l.hat, l.build, l.dress)] ??= FigurAussehen(
        mantel: l.coat,
        haut: l.skin,
        haar: l.hair,
        hutFarbe: l.hatColor,
        hut: l.hat,
        statur: l.build,
        kleid: l.dress,
      );

  /// Stehende oder gehende Figur (Figuren 2.0, [FigurRig]); Ursprung an den Füßen.
  void standing(
    Canvas c,
    Offset feet,
    FigureLook look, {
    required double facing,
    double walk = 0,
    double moveAmt = 0,
    bool ghost = false,
    bool shadow = true,
    double ruhe = 0,
    bool suchen = false,
    bool befragen = false,
    double handlungsZeit = 0,
    Taetigkeit taetigkeit = Taetigkeit.keine,
    double taetigkeitsGrad = 0,
    double taetigkeitsZeit = 0,
  }) {
    final (wm, _) = buildScale(look.build);
    final sd = Iso.facingToScreen(facing);
    if (shadow && !ghost) {
      final r = Rect.fromCenter(center: feet.translate(1.5, 0.5), width: 26 * wm, height: 10);
      c.drawOval(r, Paint()..shader = Gradient.radial(r.center, 13 * wm, [withAlpha(_black, 0.5), withAlpha(_black, 0)], const [0.35, 1]));
    }
    c.save();
    c.translate(feet.dx, feet.dy);
    _rig.zeichne(
      c,
      _fuerRig(look),
      sx: sd.dx,
      sy: sd.dy,
      walk: walk,
      moveAmt: moveAmt,
      ghost: ghost,
      ruhe: ruhe,
      suchen: suchen,
      befragen: befragen,
      handlungsZeit: handlungsZeit,
      taetigkeit: taetigkeit,
      taetigkeitsGrad: taetigkeitsGrad,
      taetigkeitsZeit: taetigkeitsZeit,
    );
    c.restore();
  }

  /// Die frühere Papierpuppe (Figuren 1.0), nur noch als Rückfall und für Vergleiche.
  void standingAlt(
    Canvas c,
    Offset feet,
    FigureLook look, {
    required double facing,
    double walk = 0,
    double moveAmt = 0,
    bool ghost = false,
    bool shadow = true,
    double ruhe = 0,
    bool suchen = false,
    bool befragen = false,
    double handlungsZeit = 0,
  }) {
    final (wm, hm) = buildScale(look.build);
    final sd = Iso.facingToScreen(facing);
    final front = sd.dy > -0.2;
    final side = sd.dx.abs() > 0.5;
    final dir = sd.dx >= 0 ? 1.0 : -1.0;
    final sw = math.sin(walk) * moveAmt;
    final bob = (math.sin(walk).abs()) * 1.6 * moveAmt;

    if (shadow && !ghost) {
      c.drawOval(Rect.fromCenter(center: feet, width: 24 * wm, height: 9), Paint()..color = withAlpha(_black, 0.38));
    }
    c.save();
    c.translate(feet.dx, feet.dy - bob);
    if (suchen) {
      // Aufrecht bleiben: zum Licht beugen, niemals stolpern oder liegen.
      c.scale(1, 0.9);
      c.skew(dir * (0.16 + 0.025 * math.sin(handlungsZeit * 3)), 0);
    }
    if (ruhe != 0) {
      // Ruhe-Animation (Partymodus): Atmen und leichtes Wiegen um die Füße.
      c.scale(1 + 0.006 * math.cos(ruhe), 1 + 0.016 * math.sin(ruhe));
      c.skew(0.025 * math.sin(ruhe * 0.5), 0);
    }

    final dress = look.dress;
    final legTop = -14.0 * hm;
    final shoulderY = -37.0 * hm;
    final hemY = (dress ? -6.5 : -11.0) * hm;
    final sW = 8.6 * wm, hW = (dress ? 12.6 : 10.8) * wm;
    final coat = look.coat;

    // Beine
    if (!ghost) {
      final trousers = Paint()..color = dress ? shade(look.skin, -0.45) : const Color(0xFF1E1C22);
      final shoe = Paint()..color = const Color(0xFF0C0B0D);
      for (final s in [-1.0, 1.0]) {
        final swing = sw * s;
        final lx = s * 3.4 * wm + swing * (side ? 3.2 * dir : 0.6);
        final lift = side ? 0.0 : math.max(0.0, swing) * 2.2;
        c.drawRRect(
          RRect.fromRectAndRadius(Rect.fromLTRB(lx - 2.2, legTop, lx + 2.2, -lift), const Radius.circular(1.2)),
          trousers,
        );
        c.drawOval(Rect.fromCenter(center: Offset(lx + (side ? dir * 1.2 : 0), -lift - 0.6), width: 5.6, height: 2.8), shoe);
      }
    }

    // hinterer Arm (Seitenansicht)
    void arm(double sx, double swing, Color col) {
      c.save();
      c.translate(sx, shoulderY + 2.5);
      c.rotate(swing);
      c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTRB(-1.9, 0, 1.9, 17 * hm), const Radius.circular(1.9)), Paint()..color = col);
      c.drawCircle(Offset(0, 17.6 * hm), 1.9, Paint()..color = look.skin);
      c.restore();
    }

    if (side) arm(-dir * (sW - 2.5), -sw * 0.35 * dir, shade(coat, -0.32));

    // Mantel
    final body = Path()
      ..moveTo(-sW, shoulderY + 3)
      ..quadraticBezierTo(-sW, shoulderY, -sW + 3, shoulderY)
      ..lineTo(sW - 3, shoulderY)
      ..quadraticBezierTo(sW, shoulderY, sW, shoulderY + 3);
    if (ghost) {
      body
        ..quadraticBezierTo(hW, hemY + 4, 2, -2)
        ..lineTo(-2, -2)
        ..quadraticBezierTo(-hW, hemY + 4, -sW, shoulderY + 3);
    } else {
      body
        ..lineTo(hW, hemY)
        ..quadraticBezierTo(0, hemY + 1.6, -hW, hemY)
        ..close();
    }
    c.drawPath(
      body,
      Paint()
        ..shader = Gradient.linear(Offset(-hW, 0), Offset(hW, 0), [shade(coat, 0.16), coat, shade(coat, -0.34)], const [0, 0.42, 1]),
    );
    final dark = Paint()
      ..color = shade(coat, -0.42)
      ..strokeWidth = 1.1
      ..style = PaintingStyle.stroke;
    final beltY = -22.5 * hm;
    if (front && dress) {
      final cx = side ? dir * 2.5 : 0.0;
      // Ausschnitt mit Perlenkette
      final neck = Path()
        ..moveTo(cx - 3.6, shoulderY)
        ..quadraticBezierTo(cx, shoulderY + 7.5, cx + 3.6, shoulderY)
        ..close();
      c.drawPath(neck, Paint()..color = look.skin);
      final pearl = Paint()..color = const Color(0xFFF1ECE2);
      for (var i = -2; i <= 2; i++) {
        final t = i / 2.0;
        c.drawCircle(Offset(cx + t * 3.0, shoulderY + 4.2 - t * t * 2.2), 0.65, pearl);
      }
      // Rockfalten
      c.drawLine(Offset(cx - 3, beltY + 2), Offset(cx - 5.5, hemY - 0.5), dark);
      c.drawLine(Offset(cx + 3, beltY + 2), Offset(cx + 5.5, hemY - 0.5), dark);
    } else if (front) {
      final cx = side ? dir * 2.5 : 0.0;
      // Hemd + Krawatte
      final shirt = Path()
        ..moveTo(cx - 3, shoulderY)
        ..lineTo(cx + 3, shoulderY)
        ..lineTo(cx, shoulderY + 8)
        ..close();
      c.drawPath(shirt, Paint()..color = const Color(0xFFE9E3D6));
      c.drawLine(Offset(cx, shoulderY + 1), Offset(cx, shoulderY + 7), Paint()
        ..color = shade(coat, -0.55)
        ..strokeWidth = 1.4);
      // Revers
      final lapel = Path()
        ..moveTo(cx - 3.5, shoulderY)
        ..lineTo(cx - 0.5, shoulderY + 10)
        ..moveTo(cx + 3.5, shoulderY)
        ..lineTo(cx + 0.5, shoulderY + 10);
      c.drawPath(lapel, dark);
      final btn = Paint()..color = shade(coat, -0.5);
      c.drawCircle(Offset(cx + 1.4, beltY + 3), 0.9, btn);
      c.drawCircle(Offset(cx + 1.4, beltY + 7), 0.9, btn);
    } else {
      c.drawLine(Offset(0, shoulderY + 2), Offset(0, hemY - 1), dark);
    }
    if (!ghost) {
      c.drawLine(Offset(-sW + 0.6, beltY), Offset(sW - 0.6, beltY), Paint()
        ..color = shade(coat, -0.38)
        ..strokeWidth = 1.8);
    }

    // vorderer Arm / beide Arme frontal; Untersuchungen halten eine sichtbare
    // Lupe ins Licht, Befragungen heben die freie Hand als Gesprächsgeste.
    final handelt = suchen || befragen;
    final geste = -dir * ((suchen ? 1.05 : 0.8) + 0.10 * math.sin(handlungsZeit * 3));
    if (side) {
      arm(dir * (sW - 2.5), handelt ? geste : sw * 0.35 * dir, shade(coat, -0.12));
    } else {
      arm(-(sW - 1.2), handelt && dir < 0 ? geste : sw * 0.18 + 0.05, shade(coat, -0.05));
      arm(sW - 1.2, handelt && dir > 0 ? geste : -sw * 0.18 - 0.05, shade(coat, -0.22));
    }
    if (suchen) {
      final sx = dir * (sW - (side ? 2.5 : 1.2));
      final hand = Offset(sx - math.sin(geste) * 17.6 * hm, shoulderY + 2.5 + math.cos(geste) * 17.6 * hm);
      final glas = hand.translate(dir * 3.5, -6);
      c.drawLine(hand, glas, Paint()..color = const Color(0xFFC49B54)..strokeWidth = 2.5);
      c.drawCircle(glas, 4.3, Paint()..color = const Color(0x885FBCD1));
      c.drawCircle(glas, 4.3, Paint()..color = const Color(0xFFFFD995)..style = PaintingStyle.stroke..strokeWidth = 1.7);
      c.drawArc(Rect.fromCircle(center: glas, radius: 2.6), 3.6, 1.4, false,
        Paint()..color = const Color(0xDDFFFFFF)..style = PaintingStyle.stroke..strokeWidth = 1);
    }

    // Kopf
    final headY = shoulderY - 6.8;
    const hr = 6.4;
    c.drawRect(Rect.fromLTRB(-1.8, shoulderY - 2.5, 1.8, shoulderY + 0.5), Paint()..color = shade(look.skin, -0.2));
    final head = Offset(side ? dir * 0.6 : 0, headY);
    c.drawCircle(
      head,
      hr,
      Paint()
        ..shader = Gradient.radial(head.translate(-2, -2), hr * 1.4, [shade(look.skin, 0.12), look.skin, shade(look.skin, -0.25)], const [0, 0.55, 1]),
    );
    _hair(c, head, hr, look, front, side, dir);
    if (front) {
      final ex = side ? dir * 2.6 : 0.0;
      final eye = Paint()..color = const Color(0xFF191416);
      if (side) {
        c.drawCircle(Offset(head.dx + ex + dir * 0.6, headY + 0.4), 0.95, eye);
        c.drawCircle(Offset(head.dx + ex - dir * 2.8, headY + 0.4), 0.85, eye);
      } else {
        c.drawCircle(Offset(head.dx - 2.3, headY + 0.4), 0.95, eye);
        c.drawCircle(Offset(head.dx + 2.3, headY + 0.4), 0.95, eye);
      }
      c.drawCircle(Offset(head.dx + ex * 0.5, headY + 3.6), 0.7, Paint()..color = withAlpha(shade(look.skin, -0.4), 0.6));
    }
    _hat(c, head, hr, look, front, side, dir);
    c.restore();
  }

  void _hair(Canvas c, Offset h, double r, FigureLook look, bool front, bool side, double dir) {
    // Unter dem Kopftuch ist kein Haar zu sehen.
    if (look.hat == 'kopftuch') return;
    final p = Paint()..color = look.hair;
    if (!front) {
      c.drawCircle(h.translate(0, -0.3), r + 0.3, p);
      return;
    }
    final path = Path()..addArc(Rect.fromCircle(center: h.translate(0, -0.4), radius: r + 0.4), math.pi * 1.02, math.pi * 0.96);
    path.close();
    c.drawPath(path, p);
    if (side) {
      c.drawOval(Rect.fromCenter(center: h.translate(-dir * (r - 1.6), 0.5), width: 5, height: 9), p);
    } else {
      c.drawOval(Rect.fromCenter(center: h.translate(-r + 1, 1), width: 3, height: 7), p);
      c.drawOval(Rect.fromCenter(center: h.translate(r - 1, 1), width: 3, height: 7), p);
    }
  }

  void _hat(Canvas c, Offset h, double r, FigureLook look, bool front, bool side, double dir) {
    final col = look.hatColor;
    final band = Paint()..color = shade(col, -0.45);
    final hi = Paint()..color = shade(col, 0.18);
    switch (look.hat) {
      case 'bowler':
        c.drawOval(Rect.fromCenter(center: h.translate(0, -3), width: 18, height: 4.6), Paint()..color = shade(col, -0.15));
        final crown = Path()..addArc(Rect.fromCenter(center: h.translate(0, -3.4), width: 13, height: 15), math.pi, math.pi);
        crown.close();
        c.drawPath(crown, Paint()..shader = Gradient.linear(h.translate(-6, 0), h.translate(6, 0), [shade(col, 0.2), shade(col, -0.25)]));
        c.drawRect(Rect.fromLTRB(h.dx - 6.4, h.dy - 5.2, h.dx + 6.4, h.dy - 3.6), band);
      case 'fedora':
        c.save();
        c.translate(h.dx, h.dy);
        c.rotate(side ? dir * 0.08 : 0);
        c.drawOval(Rect.fromCenter(center: const Offset(0, -2.4), width: 24, height: 6.6), Paint()..color = shade(col, -0.12));
        final crown = Path()
          ..moveTo(-6.0, -3.0)
          ..quadraticBezierTo(-6.4, -8.4, -4.2, -9.4)
          ..quadraticBezierTo(0, -7.0, 4.2, -9.4)
          ..quadraticBezierTo(6.4, -8.4, 6.0, -3.0)
          ..close();
        c.drawPath(crown, Paint()..shader = Gradient.linear(const Offset(-6, 0), const Offset(6, 0), [shade(col, 0.22), shade(col, -0.25)]));
        c.drawRect(const Rect.fromLTRB(-6.1, -5.0, 6.1, -3.2), band);
        c.restore();
      case 'cap':
        final capCol = mix(col, const Color(0xFF6B5A44), 0.35);
        final dome = Path()..addArc(Rect.fromCenter(center: h.translate(0, -2.2), width: 14.5, height: 10), math.pi, math.pi);
        dome.close();
        c.drawPath(dome, Paint()..color = capCol);
        if (front) {
          final vx = side ? dir * 5.5 : 0.0;
          c.drawOval(Rect.fromCenter(center: h.translate(vx, -2.0), width: side ? 9 : 13, height: 3.4), Paint()..color = shade(capCol, -0.3));
        }
        c.drawCircle(h.translate(0, -7.0), 1.1, Paint()..color = shade(capCol, -0.25));
      case 'bun':
        c.drawCircle(h.translate(side ? -dir * 2 : 0, -r - 1.8), 3.6, Paint()..color = look.hair);
        c.drawCircle(h.translate(side ? -dir * 2.5 : -0.8, -r - 2.6), 1.2, Paint()..color = shade(look.hair, 0.2));
      case 'top':
        c.drawOval(Rect.fromCenter(center: h.translate(0, -3.6), width: 17, height: 4.4), Paint()..color = shade(col, -0.2));
        c.drawRect(Rect.fromLTRB(h.dx - 5.2, h.dy - 17.5, h.dx + 5.2, h.dy - 3.8), Paint()..shader = Gradient.linear(h.translate(-5, 0), h.translate(5, 0), [shade(col, 0.2), shade(col, -0.3)]));
        c.drawOval(Rect.fromCenter(center: h.translate(0, -17.5), width: 10.4, height: 2.8), hi);
        c.drawRect(Rect.fromLTRB(h.dx - 5.2, h.dy - 7.4, h.dx + 5.2, h.dy - 5.4), Paint()..color = mix(band.color, const Color(0xFF7A1E28), 0.5));
      case 'beret':
        c.save();
        c.translate(h.dx + (side ? -dir * 1.2 : 1.2), h.dy - 4.6);
        c.rotate(side ? -dir * 0.22 : 0.2);
        c.drawOval(Rect.fromCenter(center: Offset.zero, width: 16, height: 6.6), Paint()..color = mix(col, const Color(0xFF7A2030), 0.3));
        c.drawOval(Rect.fromCenter(center: const Offset(-1.5, -1.2), width: 9, height: 2.5), Paint()..color = withAlpha(_white, 0.08));
        c.drawLine(const Offset(0, -3.3), const Offset(0.6, -5.2), Paint()
          ..color = shade(col, -0.3)
          ..strokeWidth = 1.2);
        c.restore();
      case 'cloche':
        final cl = mix(col, const Color(0xFF5A3A4A), 0.3);
        final bell = Path()
          ..moveTo(h.dx - 7.6, h.dy + 0.4)
          ..quadraticBezierTo(h.dx - 8, h.dy - 10.5, h.dx, h.dy - 10.2)
          ..quadraticBezierTo(h.dx + 8, h.dy - 10.5, h.dx + 7.6, h.dy + 0.4)
          ..quadraticBezierTo(h.dx, h.dy - 2.2, h.dx - 7.6, h.dy + 0.4)
          ..close();
        c.drawPath(bell, Paint()..shader = Gradient.linear(h.translate(-7, 0), h.translate(7, 0), [shade(cl, 0.2), shade(cl, -0.25)]));
        c.drawPath(
          Path()
            ..moveTo(h.dx - 7.4, h.dy - 3.0)
            ..quadraticBezierTo(h.dx, h.dy - 5.4, h.dx + 7.4, h.dy - 3.0),
          Paint()
            ..color = const Color(0xFFB8955A)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5,
        );
        c.drawCircle(h.translate(side ? -dir * 4.5 : 4.5, -3.8), 1.6, Paint()..color = const Color(0xFFB8955A));
      case 'kopftuch':
        _kopftuch(c, h, r, look.hatColor, front, side, dir);
      default:
        break;
    }
  }
  /// Kopftuch: umschließt Kopf und Hals, das Gesicht bleibt frei, fällt bis auf die Schultern.
  void _kopftuch(Canvas c, Offset h, double r, Color col, bool front, bool side, double dir) {
    final tuch = Paint()..shader = Gradient.linear(h.translate(-r, -r), h.translate(r, r), [shade(col, 0.14), col, shade(col, -0.22)], const [0, 0.5, 1]);
    final aussen = Path()
      ..moveTo(h.dx - r - 1.6, h.dy + r + 3.8)
      ..quadraticBezierTo(h.dx - r - 2.2, h.dy - r - 1.6, h.dx, h.dy - r - 1.6)
      ..quadraticBezierTo(h.dx + r + 2.2, h.dy - r - 1.6, h.dx + r + 1.6, h.dy + r + 3.8)
      ..quadraticBezierTo(h.dx, h.dy + r + 5.6, h.dx - r - 1.6, h.dy + r + 3.8)
      ..close();
    if (!front) {
      c.drawPath(aussen, tuch);
      return;
    }
    final gx = side ? h.dx + dir * 1.8 : h.dx;
    final gesicht = Path()..addOval(Rect.fromCenter(center: Offset(gx, h.dy + 0.9), width: side ? r * 1.25 : r * 1.55, height: r * 1.7));
    final form = Path.combine(PathOperation.difference, aussen, gesicht);
    c.drawPath(form, tuch);
    c.drawPath(
      gesicht,
      Paint()
        ..color = shade(col, -0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.9,
    );
  }


  /// Liegende Figur (Leiche, niedergeschlagen) – zentriert auf Welt-Position.
  void lying(
    Canvas c,
    double wx,
    double wy,
    FigureLook look, {
    double rot = 0.6,
    bool chalk = false,
    Color? glow,
    double scale = 1,
  }) {
    final o = Iso.toScreen(wx, wy);
    c.save();
    c.translate(o.dx, o.dy);
    c.save();
    Iso.applyGround(c);
    c.rotate(rot);
    c.scale(scale);
    if (glow != null) {
      c.drawCircle(Offset.zero, 0.55, Paint()..shader = Gradient.radial(Offset.zero, 0.55, [glow, withAlpha(glow, 0)]));
    }
    if (chalk) {
      _lyingBody(c, look, outline: 0.07, outlineColor: const Color(0xEEEDEDE6));
    }
    _lyingBody(c, look, outline: 0.0, shadowOnly: true);
    c.restore();
    // Oberseite leicht angehoben
    c.translate(0, -2.5);
    Iso.applyGround(c);
    c.rotate(rot);
    c.scale(scale);
    _lyingBody(c, look, outline: 0.0);
    c.restore();
  }

  /// Gliedmaßen als Linien (Welt-Einheiten, Kopf nach +x).
  static const _limbs = [
    // (x0, y0, x1, y1, Breite, Typ) Typ: 0 Mantel, 1 Bein, 4 Ärmel
    (-0.14, -0.05, -0.44, -0.2, 0.085, 1),
    (-0.14, 0.05, -0.46, 0.13, 0.085, 1),
    (0.12, -0.09, 0.3, -0.3, 0.07, 4),
    (0.1, 0.09, -0.02, 0.32, 0.07, 4),
  ];

  void _lyingBody(Canvas c, FigureLook look, {required double outline, Color? outlineColor, bool shadowOnly = false}) {
    Color col(int type) {
      if (outlineColor != null) return outlineColor;
      if (shadowOnly) return withAlpha(_black, 0.45);
      return switch (type) {
        0 => shade(look.coat, -0.02),
        1 => const Color(0xFF24222A),
        2 => look.skin,
        3 => look.hair,
        _ => shade(look.coat, -0.22),
      };
    }

    final limb = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    for (final (x0, y0, x1, y1, w, type) in _limbs) {
      limb
        ..strokeWidth = w + outline * 2
        ..color = col(type);
      c.drawLine(Offset(x0, y0), Offset(x1, y1), limb);
      // Hände/Schuhe
      final end = Paint()..color = outlineColor ?? (shadowOnly ? withAlpha(_black, 0.45) : (type == 1 ? const Color(0xFF0E0D10) : look.skin));
      c.drawCircle(Offset(x1, y1), w * 0.55 + outline, end);
    }
    final torso = RRect.fromLTRBR(-0.2 - outline, -0.12 - outline, 0.17 + outline, 0.12 + outline, Radius.circular(0.07 + outline));
    c.drawRRect(torso, Paint()..color = col(0));
    if (outlineColor == null && !shadowOnly) {
      c.drawLine(const Offset(-0.18, 0), const Offset(0.15, 0), Paint()
        ..color = shade(look.coat, -0.35)
        ..strokeWidth = 0.012);
      c.drawLine(const Offset(-0.06, -0.12), const Offset(-0.06, 0.12), Paint()
        ..color = shade(look.coat, -0.35)
        ..strokeWidth = 0.025);
    }
    c.drawCircle(const Offset(0.27, 0.0), 0.085 + outline, Paint()..color = col(2));
    if (outlineColor == null && !shadowOnly) {
      c.drawArc(Rect.fromCircle(center: const Offset(0.28, 0.0), radius: 0.086), -math.pi / 2, math.pi, true, Paint()..color = look.hair);
    }
  }

  /// Der Schatten: dunkle Silhouette (ohne Augen, die kommen über der Dunkelheit).
  void shadowFigure(Canvas c, Offset feet, double t, {required double facing, required String mode, double alpha = 1}) {
    final sd = Iso.facingToScreen(facing);
    final lean = mode == 'attack' ? sd.dx * 4 : 0.0;
    final sway = math.sin(t * 2.2) * 1.2;
    c.save();
    c.translate(feet.dx, feet.dy - 2 + math.sin(t * 1.7) * 1.2);
    c.drawOval(Rect.fromCenter(center: const Offset(0, 2), width: 30, height: 10), Paint()..color = withAlpha(_black, 0.5 * alpha));
    final body = Path()..moveTo(-15, -2);
    for (var i = 0; i <= 6; i++) {
      final x = -15 + i * 5.0;
      body.lineTo(x, -2 - (i.isEven ? 0 : 5 + math.sin(t * 4 + i) * 2));
    }
    body
      ..lineTo(15, -2)
      ..quadraticBezierTo(11 + sway, -28, 10 + lean, -44)
      ..quadraticBezierTo(8 + lean, -63, lean + sway * 0.5, -64)
      ..quadraticBezierTo(-8 + lean, -63, -10 + lean, -44)
      ..quadraticBezierTo(-11 + sway, -28, -15, -2)
      ..close();
    c.drawPath(
      body,
      Paint()
        ..shader = Gradient.linear(
          const Offset(0, -64),
          const Offset(0, 0),
          [withAlpha(const Color(0xFF16101E), alpha), withAlpha(const Color(0xFF07050A), alpha), withAlpha(const Color(0xFF07050A), 0.2 * alpha)],
          const [0, 0.7, 1],
        ),
    );
    // Arme / Krallen
    final arm = Paint()
      ..color = withAlpha(const Color(0xFF0A0710), alpha)
      ..strokeWidth = 3.2
      ..strokeCap = StrokeCap.round;
    final raise = mode == 'attack' ? -14.0 : 0.0;
    c.drawLine(Offset(-9 + lean, -40), Offset(-15 + lean, -18 + raise + sway), arm);
    c.drawLine(Offset(9 + lean, -40), Offset(15 + lean, -18 + raise - sway), arm);
    final claw = Paint()
      ..color = withAlpha(const Color(0xFF0A0710), alpha)
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;
    for (final s in [-1.0, 1.0]) {
      final hx = s * 15 + lean, hy = -18 + raise + (s < 0 ? sway : -sway);
      for (var k = -1; k <= 1; k++) {
        c.drawLine(Offset(hx, hy), Offset(hx + s * 1.5 + k * 1.6, hy + 5), claw);
      }
    }
    // Kapuzenöffnung
    c.drawOval(Rect.fromCenter(center: Offset(lean + sd.dx * 1.5, -51), width: 10, height: 11), Paint()..color = withAlpha(_black, alpha));
    c.drawPath(
      Path()
        ..moveTo(lean - 8, -56)
        ..quadraticBezierTo(lean, -66, lean + 8, -56),
      Paint()
        ..color = withAlpha(const Color(0xFF3A2A4A), 0.5 * alpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    c.restore();
  }

  /// Rot glühende Augen (über der Dunkelheit gezeichnet).
  void shadowEyes(Canvas c, Offset feet, double t, {required double facing, required String mode, double alpha = 1}) {
    final sd = Iso.facingToScreen(facing);
    final lean = mode == 'attack' ? sd.dx * 4 : 0.0;
    final base = feet.translate(lean + sd.dx * 1.6, -2 + math.sin(t * 1.7) * 1.2 - 51);
    if (sd.dy < -0.6) return; // abgewandt
    final blink = (math.sin(t * 0.9) > 0.985) ? 0.15 : 1.0;
    final strong = mode == 'hunt' || mode == 'attack';
    final a = alpha * blink * (strong ? 1.0 : 0.75);
    for (final s in [-2.3, 2.3]) {
      final o = base.translate(s, 0);
      c.drawCircle(o, strong ? 7 : 5, Paint()..shader = Gradient.radial(o, strong ? 7 : 5, [withAlpha(const Color(0xFFFF2020), 0.55 * a), withAlpha(const Color(0xFFFF2020), 0)]));
      c.drawOval(Rect.fromCenter(center: o, width: 2.6, height: 1.6), Paint()..color = withAlpha(const Color(0xFFFF6A4A), a));
      c.drawCircle(o, 0.6, Paint()..color = withAlpha(const Color(0xFFFFE0C0), a));
    }
  }
}
