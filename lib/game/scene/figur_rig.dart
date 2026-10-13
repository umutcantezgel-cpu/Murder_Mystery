import 'dart:math' as math;
import 'dart:ui';

import 'palette.dart';

/// Figuren 2.0: eine per Code gezeichnete, gegliederte Figur (2,5D-Ausschnitt).
///
/// Die Figur dreht sich stufenlos: aus der Blickrichtung auf dem Bildschirm
/// entstehen Gierwinkel, Seitenanteil [_Pose.seite] und Frontanteil [_Pose.front].
/// Daraus folgen Breite der Schultern, Lage der Gesichtszüge, Reihenfolge der
/// Gliedmaßen (fern hinter dem Körper, nah davor) und die Richtung, in die Beine
/// und Arme schwingen. Beine und Arme haben zwei Glieder (Knie, Ellbogen), der
/// Gang hat Bodenkontakt, Knieknick und Schulterschwung. Mantelschöße und Haare
/// schwingen nach. Im Stand atmet die Figur, verlagert das Gewicht und blinzelt.
///
/// Koordinaten: Ursprung an den Füßen, Bildschirm-Pixel bei Zoom 1, y nach oben negativ.
class FigurRig {
  const FigurRig();

  static const _tinte = Color(0xFF14101A);

  /// Gesamthöhe (Scheitel) bei Statur „normal“.
  static const hoehe = 60.0;

  void zeichne(
    Canvas c,
    FigurAussehen a, {
    required double sx,
    required double sy,
    double walk = 0,
    double moveAmt = 0,
    bool ghost = false,
    double ruhe = 0,
    bool suchen = false,
    bool befragen = false,
    double handlungsZeit = 0,
  }) {
    final p = _Pose(a, sx, sy, walk, moveAmt, ruhe, suchen, befragen, handlungsZeit);

    c.save();
    c.translate(p.gewicht, -p.wippen);
    if (suchen) {
      // Vorgebeugt zur Spur, aufrecht im Stand.
      c.translate(p.vorX * 2.2, 0);
    }

    // Reihenfolge: ferner Arm, Beine, Rumpf, naher Arm, Kopf. Im Rücken sind beide
    // Arme vor dem Rumpf zu sehen (an den Seiten), von vorn ebenso.
    if (!ghost) {
      _bein(c, p, p.fernSeite);
      _bein(c, p, p.nahSeite);
    }
    if (p.profil) _arm(c, p, p.fernSeite, hinten: true);
    _rumpf(c, p, ghost: ghost);
    if (p.profil) {
      _arm(c, p, p.nahSeite, hinten: false);
    } else {
      _arm(c, p, -1, hinten: false);
      _arm(c, p, 1, hinten: false);
    }
    _kopf(c, p);
    c.restore();
  }

  // --- Beine -----------------------------------------------------------------

  void _bein(Canvas c, _Pose p, double seite) {
    final a = p.a;
    final hueftX = seite * p.hueftBreite * 0.48 * (0.45 + 0.55 * p.frontAbs);
    final huefte = Offset(hueftX, p.hueftY);
    final phase = p.walk + (seite > 0 ? 0 : math.pi);
    final schwung = math.sin(phase) * p.move;
    // Fußziel: Schritt in Gehrichtung, in der Schwungphase angehoben, sonst am Boden.
    final heben = math.max(0.0, math.cos(phase)) * 2.8 * p.move;
    final ziel = Offset(
      hueftX + schwung * 6.2 * p.vorX + (p.profil ? 0 : seite * 0.6),
      -0.9 + schwung * 2.6 * p.vorY - heben,
    );
    final lo = p.oberschenkel, lu = p.unterschenkel;
    final knie = _knie(huefte, ziel, lo, lu, p);
    final hose = a.kleid ? shade(a.haut, -0.42) : a.hose;
    final dicke = 4.6 * p.wm;
    _glied(c, huefte, knie, dicke, dicke * 0.92, hose, shade(hose, -0.3));
    _glied(c, knie, ziel.translate(0, -1.0), dicke * 0.9, dicke * 0.72, hose, shade(hose, -0.3));
    // Schuh: zeigt in Gehrichtung.
    final schuhLaenge = 6.4 * (0.4 + 0.6 * p.seiteAbs);
    final ende = ziel;
    final spitze = ende.translate(p.vorX * schuhLaenge, p.vorY * 1.2);
    final schuh = Path()
      ..moveTo(ende.dx - 2.6, ende.dy - 2.0)
      ..quadraticBezierTo(spitze.dx + p.vorX * 1.2, spitze.dy - 2.6, spitze.dx + p.vorX * 1.4, spitze.dy - 0.4)
      ..lineTo(ende.dx - 2.4 * (1 - p.seiteAbs * 0.5), ende.dy + 0.4)
      ..close();
    c.drawPath(schuh, Paint()..color = a.schuh);
    c.drawCircle(spitze.translate(-p.vorX * 1.0, -1.6), 0.8, Paint()..color = withAlpha(const Color(0xFFFFFFFF), 0.25));
  }

  /// Knie über zwei Glieder (Kreisschnitt); das Knie zeigt nach vorn.
  Offset _knie(Offset h, Offset f, double lo, double lu, _Pose p) {
    var d = f - h;
    var dist = d.distance;
    final maxL = lo + lu - 0.05;
    if (dist > maxL) {
      d = d / dist * maxL;
      dist = maxL;
    }
    if (dist < 0.5) return h.translate(0, lo);
    final aa = (lo * lo - lu * lu + dist * dist) / (2 * dist);
    final hh = math.sqrt(math.max(0.0, lo * lo - aa * aa));
    final mitte = h + d / dist * aa;
    var senk = Offset(-d.dy / dist, d.dx / dist);
    final vor = p.profil ? p.vorX : (p.vorX.abs() < 0.2 ? 0.2 : p.vorX);
    if (senk.dx * vor < 0) senk = -senk;
    return mitte + senk * hh;
  }

  void _glied(Canvas c, Offset a, Offset b, double wa, double wb, Color farbe, Color dunkel) {
    // Rund abgeschlossene Striche: Gelenke schließen sauber, ohne Kappenflecken.
    final w = (wa + wb) / 2;
    c.drawLine(a, b, Paint()
      ..color = withAlpha(_tinte, 0.45)
      ..strokeWidth = w + 1.2
      ..strokeCap = StrokeCap.round);
    c.drawLine(a, b, Paint()
      ..color = farbe
      ..strokeWidth = w
      ..strokeCap = StrokeCap.round);
    // Lichtkante links, Schattenkante rechts.
    c.drawLine(a.translate(-w * 0.22, 0), b.translate(-w * 0.22, 0), Paint()
      ..color = withAlpha(shade(farbe, 0.35), 0.45)
      ..strokeWidth = w * 0.28
      ..strokeCap = StrokeCap.round);
    c.drawLine(a.translate(w * 0.26, 0), b.translate(w * 0.26, 0), Paint()
      ..color = withAlpha(dunkel, 0.6)
      ..strokeWidth = w * 0.3
      ..strokeCap = StrokeCap.round);
  }

  // --- Arme ------------------------------------------------------------------

  void _arm(Canvas c, _Pose p, double seite, {required bool hinten}) {
    final a = p.a;
    final schulterX = seite * p.schulterBreite * (p.profil ? 0.25 : 0.86);
    final schulter = Offset(schulterX + (p.profil ? seite * p.seite.sign * 0 : 0), p.schulterY + 2.6);
    final phase = p.walk + (seite > 0 ? math.pi : 0);
    var oben = math.sin(phase) * 0.42 * p.move + seite * 0.05 * (1 - p.seiteAbs);
    var ellbogen = 0.22 + 0.32 * p.move;
    var handOffen = false;
    // Gesten: die Hand auf der Seite des Ziels.
    final gestenSeite = p.profil ? p.nahSeite : (p.seite >= 0 ? 1.0 : -1.0);
    if ((p.befragen || p.suchen) && seite == gestenSeite && !hinten) {
      final wackeln = 0.08 * math.sin(p.handlungsZeit * 3);
      oben = (p.suchen ? 1.15 : 0.95) + wackeln;
      ellbogen = p.suchen ? 0.55 : 0.85 + 0.15 * math.sin(p.handlungsZeit * 2.3);
      handOffen = p.befragen;
    }
    final lo = p.oberarm, lu = p.unterarm;
    final ell = schulter + _armRichtung(p, oben, seite) * lo;
    final hand = ell + _armRichtung(p, oben + ellbogen, seite) * lu;
    final aermel = hinten ? shade(a.mantel, -0.3) : shade(a.mantel, -0.08);
    final w = 4.4 * p.wm;
    _glied(c, schulter, ell, w, w * 0.9, aermel, shade(aermel, -0.32));
    _glied(c, ell, hand, w * 0.88, w * 0.74, aermel, shade(aermel, -0.32));
    // Manschette und Hand.
    final handPunkt = hand + _armRichtung(p, oben + ellbogen, seite) * 1.6;
    final haut = hinten ? shade(a.haut, -0.24) : shade(a.haut, -0.06);
    final hautPaint = Paint()..color = haut;
    final kontur = Paint()
      ..color = withAlpha(_tinte, 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6;
    if (handOffen) {
      final r = Rect.fromCenter(center: handPunkt, width: 3.6, height: 2.8);
      c.drawOval(r, hautPaint);
      c.drawOval(r, kontur);
      // Daumen
      c.drawCircle(handPunkt.translate(-seite * 1.3, -0.9), 0.8, hautPaint);
    } else {
      final r = Rect.fromCenter(center: handPunkt, width: 2.9, height: 3.3);
      c.drawOval(r, hautPaint);
      c.drawOval(r, kontur);
    }
    if (p.suchen && seite == gestenSeite && !hinten) _lupe(c, handPunkt, p);
  }

  Offset _armRichtung(_Pose p, double w, double seite) {
    // Schwingt in Gehrichtung; nach außen leicht gespreizt.
    final aussen = p.profil ? 0.0 : seite * 0.08;
    return Offset(math.sin(w) * p.vorX + aussen, math.cos(w) * 1.0 + math.sin(w) * p.vorY * 0.4 - (w > 0.8 ? math.sin(w) * 0.25 : 0));
  }

  void _lupe(Canvas c, Offset hand, _Pose p) {
    final glas = hand.translate(p.vorX * 4 + (p.profil ? 0 : 2), -6.5);
    c.drawLine(hand, glas, Paint()
      ..color = const Color(0xFF7A4E22)
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round);
    c.drawCircle(glas, 4.6, Paint()..color = const Color(0x6672C4D8));
    c.drawCircle(glas, 4.6, Paint()
      ..color = const Color(0xFFE6C27A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6);
    c.drawArc(Rect.fromCircle(center: glas, radius: 2.8), 3.7, 1.3, false, Paint()
      ..color = const Color(0xDDFFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9);
  }

  // --- Rumpf -----------------------------------------------------------------

  void _rumpf(Canvas c, _Pose p, {required bool ghost}) {
    final a = p.a;
    final sB = p.schulterBreite, hB = p.saumBreite;
    final sY = p.schulterY, tY = p.tailleY, saum = p.saumY;
    final atmen = p.atmen;
    // Mantelschöße schwingen nach (laufen der Bewegung hinterher).
    final nach = -math.sin(p.walk * 2 + 0.6) * 1.4 * p.move;
    final schoss = Offset(-p.vorX * (1.6 * p.move) + nach * p.vorX, 0);
    final taille = sB * (a.kleid ? 0.72 : 0.84);

    final koerper = Path()
      ..moveTo(-sB, sY + 3.2)
      ..quadraticBezierTo(-sB + 0.2, sY - 0.4 - atmen, -sB + 3.4, sY - 0.8 - atmen)
      ..lineTo(sB - 3.4, sY - 0.8 - atmen)
      ..quadraticBezierTo(sB - 0.2, sY - 0.4 - atmen, sB, sY + 3.2)
      ..quadraticBezierTo(taille + 0.6, tY - 2, taille, tY);
    if (ghost) {
      koerper
        ..quadraticBezierTo(hB * 0.7, saum, 1.5, -3)
        ..lineTo(-1.5, -3)
        ..quadraticBezierTo(-hB * 0.7, saum, -taille, tY);
    } else {
      koerper
        ..lineTo(hB + schoss.dx, saum)
        ..quadraticBezierTo(schoss.dx * 0.5, saum + (a.kleid ? 2.4 : 1.4), -hB + schoss.dx, saum)
        ..lineTo(-taille, tY);
    }
    koerper
      ..quadraticBezierTo(-taille - 0.6, tY - 2, -sB, sY + 3.2)
      ..close();

    // Kontur zur Trennung vom dunklen Boden, dann Fläche mit Licht von oben links.
    c.drawPath(koerper, Paint()
      ..color = withAlpha(_tinte, 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeJoin = StrokeJoin.round);
    c.drawPath(
      koerper,
      Paint()
        ..shader = Gradient.linear(
          Offset(-sB - p.seite * 2, sY),
          Offset(sB - p.seite * 2, saum),
          [shade(a.mantel, 0.14), a.mantel, shade(a.mantel, -0.3)],
          const [0, 0.45, 1],
        ),
    );
    // Randlicht links oben (Kerzen- und Mondlicht).
    c.save();
    c.clipPath(koerper);
    c.drawPath(koerper.shift(const Offset(1.2, 1.0)), Paint()
      ..color = withAlpha(shade(a.mantel, 0.45), 0.28)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0);
    c.restore();

    final dunkel = Paint()
      ..color = shade(a.mantel, -0.48)
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final mitte = p.seite * sB * 0.42;
    if (p.front > -0.15) {
      final kragenTiefe = a.kleid ? 6.0 : 10.5;
      if (a.kleid) {
        // Ausschnitt und Kette.
        final hals = Path()
          ..moveTo(mitte - 3.4, sY - 0.6)
          ..quadraticBezierTo(mitte, sY + 7, mitte + 3.4, sY - 0.6)
          ..close();
        c.drawPath(hals, Paint()..color = a.haut);
        if (a.variante % 3 != 0) {
          final perle = Paint()..color = const Color(0xFFF3EDE2);
          for (var i = -2; i <= 2; i++) {
            final t = i / 2.0;
            c.drawCircle(Offset(mitte + t * 2.9, sY + 3.8 - t * t * 2.0), 0.62, perle);
          }
        }
        // Gürtel und Rockfalten.
        c.drawLine(Offset(-taille + 0.4, tY), Offset(taille - 0.4, tY), Paint()
          ..color = shade(a.mantel, -0.35)
          ..strokeWidth = 1.6);
        c.drawLine(Offset(mitte - 2.6, tY + 2), Offset(mitte - 4.8 + schoss.dx, saum - 0.6), dunkel);
        c.drawLine(Offset(mitte + 2.6, tY + 2), Offset(mitte + 4.8 + schoss.dx, saum - 0.6), dunkel);
      } else {
        // Hemd, Krawatte, Revers, Knöpfe, Einstecktuch.
        final hemd = Path()
          ..moveTo(mitte - 3.2, sY - 0.6)
          ..lineTo(mitte + 3.2, sY - 0.6)
          ..lineTo(mitte, sY + kragenTiefe)
          ..close();
        c.drawPath(hemd, Paint()..color = a.hemd);
        if (a.variante % 4 != 1) {
          final binder = Path()
            ..moveTo(mitte - 0.9, sY + 0.6)
            ..lineTo(mitte + 0.9, sY + 0.6)
            ..lineTo(mitte + 1.2, sY + kragenTiefe - 1.4)
            ..lineTo(mitte, sY + kragenTiefe)
            ..lineTo(mitte - 1.2, sY + kragenTiefe - 1.4)
            ..close();
          c.drawPath(binder, Paint()..color = a.krawatte);
        }
        final revers = Path()
          ..moveTo(mitte - 3.6, sY - 0.4)
          ..lineTo(mitte - 0.4, sY + kragenTiefe + 1)
          ..moveTo(mitte + 3.6, sY - 0.4)
          ..lineTo(mitte + 0.4, sY + kragenTiefe + 1);
        c.drawPath(revers, dunkel..strokeWidth = 1.2);
        final knopf = Paint()..color = shade(a.mantel, -0.55);
        c.drawCircle(Offset(mitte + 1.2, tY + 1.2), 0.85, knopf);
        c.drawCircle(Offset(mitte + 1.2, tY + 5.2), 0.85, knopf);
        if (a.variante % 5 == 2) {
          c.drawPath(
            Path()
              ..moveTo(mitte - sB * 0.62, sY + 6)
              ..lineTo(mitte - sB * 0.62 + 2.4, sY + 4.6)
              ..lineTo(mitte - sB * 0.62 + 3.2, sY + 6.4)
              ..close(),
            Paint()..color = a.akzent,
          );
        }
        // Mantelsaum offen (Trenchcoat-Andeutung).
        c.drawLine(Offset(mitte, sY + kragenTiefe + 1), Offset(mitte + schoss.dx * 0.6, saum - 0.4), dunkel..strokeWidth = 0.9);
      }
    } else {
      // Rücken: Naht und Kragen.
      c.drawLine(Offset(mitte, sY + 1.5), Offset(mitte + schoss.dx * 0.6, saum - 1), dunkel);
      c.drawLine(Offset(-3.6, sY + 0.6), Offset(3.6, sY + 0.6), dunkel..strokeWidth = 1.6);
    }
    if (a.schal && !ghost) {
      final schal = Path()
        ..moveTo(-4.6, sY - 0.8)
        ..quadraticBezierTo(0, sY + 2.6, 4.6, sY - 0.8)
        ..lineTo(4.2, sY + 1.4)
        ..quadraticBezierTo(0, sY + 4.4, -4.2, sY + 1.4)
        ..close();
      c.drawPath(schal, Paint()..color = a.akzent);
      if (p.front > -0.15) {
        c.drawRRect(
          RRect.fromRectAndRadius(Rect.fromLTWH(mitte + 1.2 + nach * 0.3, sY + 1, 2.6, 9), const Radius.circular(1)),
          Paint()..color = shade(a.akzent, -0.12),
        );
      }
    }
  }

  // --- Kopf ------------------------------------------------------------------

  void _kopf(Canvas c, _Pose p) {
    final a = p.a;
    final r = 6.8;
    final kopf = Offset(p.seite * 0.9 + p.kopfDrehung * 1.2, p.kopfY + p.nicken);
    // Hals.
    c.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(kopf.dx * 0.6, p.schulterY - 2.2), width: 4.6, height: 5.4), const Radius.circular(1.6)),
      Paint()..color = shade(a.haut, -0.22),
    );
    final form = Rect.fromCenter(center: kopf, width: r * 1.86, height: r * 2.08);
    // Haar hinten (lange Haare, Zopf) liegt hinter dem Kopf.
    _haarHinten(c, kopf, r, p);
    c.drawOval(form.inflate(0.8), Paint()..color = withAlpha(_tinte, 0.5));
    c.drawOval(
      form,
      Paint()
        ..shader = Gradient.radial(
          kopf.translate(-2.4 - p.seite, -2.6),
          r * 1.55,
          [shade(a.haut, 0.16), a.haut, shade(a.haut, -0.26)],
          const [0, 0.55, 1],
        ),
    );
    // Ohren (seitlich sichtbar).
    if (p.seiteAbs > 0.25 && p.front > -0.6) {
      final ox = kopf.dx - p.seite * r * 0.28;
      c.drawOval(Rect.fromCenter(center: Offset(ox, kopf.dy + 0.8), width: 1.9, height: 2.9), Paint()..color = shade(a.haut, -0.14));
      c.drawArc(Rect.fromCenter(center: Offset(ox, kopf.dy + 0.8), width: 1.2, height: 2.0), -1.2, 2.4, false, Paint()
        ..color = shade(a.haut, -0.32)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.45);
    }
    if (p.front > -0.1) _gesicht(c, kopf, r, p);
    _haarVorn(c, kopf, r, p);
    _hut(c, kopf, r, p);
  }

  void _gesicht(Canvas c, Offset k, double r, _Pose p) {
    final a = p.a;
    final f = p.front.clamp(0.0, 1.0);
    final mitte = k.dx + p.seite * r * 0.52;
    final abstand = r * 0.36 * (0.35 + 0.65 * f);
    final augenY = k.dy + 0.2;
    final blinzeln = p.blinzeln;
    final augen = <double>[
      if (f > 0.35 || p.seite > 0) mitte + abstand,
      if (f > 0.35 || p.seite < 0) mitte - abstand,
    ];
    final braue = Paint()
      ..color = shade(a.haar, -0.1)
      ..strokeWidth = 1.1
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    for (final ex in augen) {
      if (blinzeln) {
        c.drawLine(Offset(ex - 1.1, augenY + 0.2), Offset(ex + 1.1, augenY + 0.2), Paint()
          ..color = shade(a.haut, -0.5)
          ..strokeWidth = 0.8);
      } else {
        c.drawOval(Rect.fromCenter(center: Offset(ex, augenY), width: 2.5, height: 1.9), Paint()..color = const Color(0xFFF4EEE6));
        final blick = p.seite * 0.45 + p.kopfDrehung * 0.4;
        c.drawCircle(Offset(ex + blick, augenY + 0.1), 0.85, Paint()..color = a.augen);
        c.drawCircle(Offset(ex + blick - 0.3, augenY - 0.3), 0.3, Paint()..color = const Color(0xCCFFFFFF));
        c.drawLine(Offset(ex - 1.3, augenY - 0.9), Offset(ex + 1.3, augenY - 0.9), Paint()
          ..color = withAlpha(_tinte, 0.55)
          ..strokeWidth = 0.6);
      }
      // Braue (leicht angehoben beim Befragen).
      final hoch = p.befragen ? 0.6 : 0.0;
      c.drawLine(Offset(ex - 1.4, augenY - 2.4 - hoch), Offset(ex + 1.3, augenY - 2.7 - hoch), braue);
    }
    // Nase: Schattenkante zur abgewandten Seite.
    final nx = mitte + p.seite * 1.4;
    c.drawPath(
      Path()
        ..moveTo(nx, augenY + 0.8)
        ..lineTo(nx + p.seite * 1.4 + 0.2, augenY + 3.0)
        ..lineTo(nx - 0.4, augenY + 3.2),
      Paint()
        ..color = shade(a.haut, -0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.75,
    );
    // Mund.
    final my = augenY + 4.9;
    final mundBreite = 1.8 * (0.5 + 0.5 * f);
    c.drawPath(
      Path()
        ..moveTo(mitte - mundBreite + p.seite * 0.6, my)
        ..quadraticBezierTo(mitte + p.seite * 0.6, my + (p.befragen ? 0.9 : 0.4), mitte + mundBreite + p.seite * 0.6, my),
      Paint()
        ..color = shade(a.haut, -0.45)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8,
    );
    // Wangenröte und Bart.
    c.drawCircle(Offset(mitte - abstand - 0.6, augenY + 2.6), 1.4, Paint()..color = withAlpha(const Color(0xFFD9786A), 0.16));
    if (a.bart > 0) {
      final bartPaint = Paint()..color = shade(a.haar, a.grau ? 0.05 : -0.05);
      if (a.bart == 1) {
        // Schnurrbart.
        c.drawPath(
          Path()
            ..moveTo(mitte - 2.4 + p.seite * 0.6, my - 0.6)
            ..quadraticBezierTo(mitte + p.seite * 0.6, my - 2.2, mitte + 2.4 + p.seite * 0.6, my - 0.6)
            ..quadraticBezierTo(mitte + p.seite * 0.6, my - 0.9, mitte - 2.4 + p.seite * 0.6, my - 0.6),
          bartPaint,
        );
      } else {
        // Vollbart entlang des Kinns.
        final bart = Path()
          ..moveTo(k.dx - r * 0.82, k.dy + 0.5)
          ..quadraticBezierTo(k.dx - r * 0.7, k.dy + r * 1.08, mitte, k.dy + r * 1.1)
          ..quadraticBezierTo(k.dx + r * 0.7, k.dy + r * 1.08, k.dx + r * 0.82, k.dy + 0.5)
          ..quadraticBezierTo(mitte, k.dy + r * 0.55, k.dx - r * 0.82, k.dy + 0.5)
          ..close();
        c.drawPath(bart, bartPaint);
      }
    }
    if (a.brille) {
      final rahmen = Paint()
        ..color = const Color(0xFF2A2018)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.7;
      for (final ex in augen) {
        c.drawCircle(Offset(ex, augenY + 0.1), 1.9, rahmen);
      }
      if (augen.length == 2) c.drawLine(Offset(augen[1] + 1.9, augenY), Offset(augen[0] - 1.9, augenY), rahmen);
    }
  }

  void _haarHinten(Canvas c, Offset k, double r, _Pose p) {
    final a = p.a;
    if (a.hut == 'kopftuch') return;
    final paint = Paint()..color = shade(a.haar, -0.08);
    switch (a.frisur) {
      case Frisur.lang:
        final nach = -math.sin(p.walk * 2 + 1.1) * 1.2 * p.move;
        c.drawRRect(
          RRect.fromRectAndRadius(Rect.fromLTRB(k.dx - r * 1.05 + nach, k.dy - r * 0.4, k.dx + r * 1.05 + nach, k.dy + r * 1.55), Radius.circular(r * 0.8)),
          paint,
        );
      case Frisur.zopf:
        final nach = -math.sin(p.walk * 2 + 1.1) * 1.6 * p.move;
        final ansatz = k.translate(-p.seite * r * 0.85, -r * 0.2);
        c.drawLine(ansatz, ansatz.translate(-p.seite * 1.5 + nach, r * 1.3), Paint()
          ..color = paint.color
          ..strokeWidth = 3.2
          ..strokeCap = StrokeCap.round);
      default:
        break;
    }
  }

  void _haarVorn(Canvas c, Offset k, double r, _Pose p) {
    final a = p.a;
    if (a.hut == 'kopftuch') return;
    final paint = Paint()
      ..shader = Gradient.linear(k.translate(-r, -r), k.translate(r, r * 0.4), [shade(a.haar, 0.22), a.haar, shade(a.haar, -0.25)], const [0, 0.5, 1]);
    if (p.front < -0.15) {
      // Hinterkopf ganz behaart (außer Glatze).
      if (a.frisur == Frisur.glatze) {
        c.drawArc(Rect.fromCircle(center: k.translate(0, 1.2), radius: r * 0.98), 0.2, math.pi - 0.4, false, Paint()
          ..color = a.haar
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.2);
        return;
      }
      c.drawOval(Rect.fromCenter(center: k.translate(0, -0.6), width: r * 1.98, height: r * 2.0), paint);
      return;
    }
    final s = p.seite;
    switch (a.frisur) {
      case Frisur.glatze:
        // Haarkranz an den Seiten.
        c.drawArc(Rect.fromCircle(center: k.translate(0, 0.6), radius: r * 0.98), math.pi * 0.95, math.pi * 0.25, false, Paint()
          ..color = a.haar
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.8);
        c.drawArc(Rect.fromCircle(center: k.translate(0, 0.6), radius: r * 0.98), -math.pi * 0.2, math.pi * 0.25, false, Paint()
          ..color = a.haar
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.8);
        c.drawOval(Rect.fromCenter(center: k.translate(-1.8 - s, -r * 0.62), width: 3.6, height: 1.6), Paint()..color = withAlpha(const Color(0xFFFFFFFF), 0.28));
      case Frisur.locken:
        for (var i = 0; i < 7; i++) {
          final w = math.pi * (1.05 + i * 0.15);
          c.drawCircle(k + Offset(math.cos(w) * r * 0.86, math.sin(w) * r * 0.86 - 0.6), 2.6, paint);
        }
        c.drawOval(Rect.fromCenter(center: k.translate(0, -r * 0.62), width: r * 1.7, height: r * 0.8), paint);
      default:
        final scheitel = switch (a.frisur) {
          Frisur.seitenscheitel => 0.32,
          Frisur.zurueck => 0.0,
          _ => 0.12,
        };
        final kappe = Path()
          ..moveTo(k.dx - r * 1.0, k.dy + (a.frisur == Frisur.lang ? r * 0.5 : -0.4))
          ..quadraticBezierTo(k.dx - r * 1.08, k.dy - r * 1.15, k.dx + (scheitel - s * 0.2) * r, k.dy - r * 1.12)
          ..quadraticBezierTo(k.dx + r * 1.08, k.dy - r * 1.1, k.dx + r * 1.0, k.dy + (a.frisur == Frisur.lang ? r * 0.5 : -0.4))
          ..quadraticBezierTo(
            k.dx + r * 0.6,
            k.dy - r * (a.frisur == Frisur.zurueck ? 0.72 : 0.42),
            k.dx + (scheitel - 0.1) * r + s * r * 0.3,
            k.dy - r * (a.frisur == Frisur.kurz ? 0.62 : 0.5),
          )
          ..quadraticBezierTo(k.dx - r * 0.6, k.dy - r * 0.55, k.dx - r * 1.0, k.dy + (a.frisur == Frisur.lang ? r * 0.5 : -0.4))
          ..close();
        c.drawPath(kappe, paint);
        // Glanzlicht.
        c.drawArc(Rect.fromCircle(center: k.translate(-1.4, -0.6), radius: r * 0.86), math.pi * 1.18, math.pi * 0.32, false, Paint()
          ..color = withAlpha(shade(a.haar, 0.5), 0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.9);
    }
  }

  void _hut(Canvas c, Offset h, double r, _Pose p) {
    final a = p.a;
    final col = a.hutFarbe;
    final band = Paint()..color = shade(col, -0.45);
    final s = p.seite;
    switch (a.hut) {
      case 'bowler':
        c.drawOval(Rect.fromCenter(center: h.translate(0, -3.4), width: 18.5, height: 4.8), Paint()..color = shade(col, -0.15));
        final krone = Path()..addArc(Rect.fromCenter(center: h.translate(0, -3.8), width: 13.4, height: 15.5), math.pi, math.pi);
        krone.close();
        c.drawPath(krone, Paint()..shader = Gradient.linear(h.translate(-6, 0), h.translate(6, 0), [shade(col, 0.22), shade(col, -0.28)]));
        c.drawRect(Rect.fromLTRB(h.dx - 6.6, h.dy - 5.6, h.dx + 6.6, h.dy - 4.0), band);
      case 'fedora':
        c.save();
        c.translate(h.dx, h.dy);
        c.rotate(s * 0.1);
        c.drawOval(Rect.fromCenter(center: const Offset(0, -2.8), width: 25, height: 6.8), Paint()..color = shade(col, -0.14));
        final krone = Path()
          ..moveTo(-6.2, -3.4)
          ..quadraticBezierTo(-6.6, -9.0, -4.3, -10.0)
          ..quadraticBezierTo(0, -7.6, 4.3, -10.0)
          ..quadraticBezierTo(6.6, -9.0, 6.2, -3.4)
          ..close();
        c.drawPath(krone, Paint()..shader = Gradient.linear(const Offset(-6, 0), const Offset(6, 0), [shade(col, 0.24), shade(col, -0.28)]));
        c.drawRect(const Rect.fromLTRB(-6.3, -5.4, 6.3, -3.6), band);
        c.restore();
      case 'cap':
        final kappe = mix(col, const Color(0xFF6B5A44), 0.35);
        final dom = Path()..addArc(Rect.fromCenter(center: h.translate(0, -2.6), width: 15, height: 10.6), math.pi, math.pi);
        dom.close();
        c.drawPath(dom, Paint()..color = kappe);
        if (p.front > -0.2) {
          c.drawOval(Rect.fromCenter(center: h.translate(s * 5.8, -2.4), width: p.seiteAbs > 0.5 ? 9 : 13.6, height: 3.6), Paint()..color = shade(kappe, -0.3));
        }
        c.drawCircle(h.translate(0, -7.6), 1.1, Paint()..color = shade(kappe, -0.25));
      case 'bun':
        c.drawCircle(h.translate(-s * 2, -r - 2.0), 3.8, Paint()..color = a.haar);
        c.drawCircle(h.translate(-s * 2.5 - 0.8, -r - 2.8), 1.2, Paint()..color = shade(a.haar, 0.22));
      case 'top':
        c.drawOval(Rect.fromCenter(center: h.translate(0, -4.0), width: 17.5, height: 4.6), Paint()..color = shade(col, -0.2));
        c.drawRect(Rect.fromLTRB(h.dx - 5.4, h.dy - 18.2, h.dx + 5.4, h.dy - 4.2),
            Paint()..shader = Gradient.linear(h.translate(-5, 0), h.translate(5, 0), [shade(col, 0.22), shade(col, -0.32)]));
        c.drawOval(Rect.fromCenter(center: h.translate(0, -18.2), width: 10.8, height: 2.9), Paint()..color = shade(col, 0.18));
        c.drawRect(Rect.fromLTRB(h.dx - 5.4, h.dy - 7.8, h.dx + 5.4, h.dy - 5.8), Paint()..color = mix(band.color, const Color(0xFF7A1E28), 0.5));
      case 'beret':
        c.save();
        c.translate(h.dx - s * 1.2 + 1.2, h.dy - 5.0);
        c.rotate(-s * 0.22 + 0.2);
        c.drawOval(Rect.fromCenter(center: Offset.zero, width: 16.5, height: 6.8), Paint()..color = mix(col, const Color(0xFF7A2030), 0.3));
        c.drawOval(Rect.fromCenter(center: const Offset(-1.5, -1.2), width: 9, height: 2.5), Paint()..color = withAlpha(const Color(0xFFFFFFFF), 0.09));
        c.restore();
      case 'cloche':
        final cl = mix(col, const Color(0xFF5A3A4A), 0.3);
        final glocke = Path()
          ..moveTo(h.dx - 7.8, h.dy + 0.2)
          ..quadraticBezierTo(h.dx - 8.2, h.dy - 11, h.dx, h.dy - 10.6)
          ..quadraticBezierTo(h.dx + 8.2, h.dy - 11, h.dx + 7.8, h.dy + 0.2)
          ..quadraticBezierTo(h.dx, h.dy - 2.4, h.dx - 7.8, h.dy + 0.2)
          ..close();
        c.drawPath(glocke, Paint()..shader = Gradient.linear(h.translate(-7, 0), h.translate(7, 0), [shade(cl, 0.22), shade(cl, -0.26)]));
        c.drawPath(
          Path()
            ..moveTo(h.dx - 7.6, h.dy - 3.2)
            ..quadraticBezierTo(h.dx, h.dy - 5.6, h.dx + 7.6, h.dy - 3.2),
          Paint()
            ..color = const Color(0xFFB8955A)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5,
        );
      case 'kopftuch':
        _kopftuch(c, h, r, col, p);
      default:
        break;
    }
  }

  /// Kopftuch: umschließt Kopf und Hals, das Gesicht bleibt frei, fällt bis auf die Schultern.
  void _kopftuch(Canvas c, Offset h, double r, Color col, _Pose p) {
    final tuch = Paint()..shader = Gradient.linear(h.translate(-r, -r), h.translate(r, r), [shade(col, 0.16), col, shade(col, -0.24)], const [0, 0.5, 1]);
    final aussen = Path()
      ..moveTo(h.dx - r - 1.8, h.dy + r + 4.0)
      ..quadraticBezierTo(h.dx - r - 2.4, h.dy - r - 1.8, h.dx, h.dy - r - 1.8)
      ..quadraticBezierTo(h.dx + r + 2.4, h.dy - r - 1.8, h.dx + r + 1.8, h.dy + r + 4.0)
      ..quadraticBezierTo(h.dx, h.dy + r + 6.0, h.dx - r - 1.8, h.dy + r + 4.0)
      ..close();
    if (p.front < -0.1) {
      c.drawPath(aussen, tuch);
      return;
    }
    final gx = h.dx + p.seite * 2.0;
    final gesicht = Path()..addOval(Rect.fromCenter(center: Offset(gx, h.dy + 1.0), width: r * (1.25 + 0.35 * p.front.clamp(0.0, 1.0)), height: r * 1.72));
    c.drawPath(Path.combine(PathOperation.difference, aussen, gesicht), tuch);
    c.drawPath(gesicht, Paint()
      ..color = shade(col, -0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9);
  }
}

/// Aussehen einer Figur für das Rig: Farben aus dem Kanon plus abgeleitete,
/// feste Merkmale (Frisur, Brille, Bart, Schal). Die Ableitung hängt nur vom
/// Aussehen ab, nie vom Abend: gleiche Figur, gleiches Bild.
class FigurAussehen {
  FigurAussehen({
    required this.mantel,
    required this.haut,
    required this.haar,
    required this.hutFarbe,
    required this.hut,
    required this.statur,
    required this.kleid,
  }) : variante = _hash('${mantel.toARGB32()}|${haut.toARGB32()}|${haar.toARGB32()}|$hut|$statur|$kleid') {
    final v = variante;
    final hell = haar.computeLuminance();
    grau = hell > 0.38 && (haar.r - haar.b).abs() < 0.12;
    frisur = switch (hut) {
      'bun' => Frisur.kurz,
      _ when kleid => const [Frisur.lang, Frisur.zopf, Frisur.lang, Frisur.locken, Frisur.seitenscheitel][v % 5],
      _ when grau && v % 3 == 0 => Frisur.glatze,
      _ => const [Frisur.kurz, Frisur.seitenscheitel, Frisur.zurueck, Frisur.locken, Frisur.kurz, Frisur.seitenscheitel][v % 6],
    };
    brille = (v >> 3) % 5 == 0;
    bart = kleid ? 0 : const [0, 0, 1, 0, 2, 0, 0][(v >> 5) % 7];
    schal = (v >> 7) % 6 == 0;
    final dunklerMantel = shade(mantel, -0.5);
    hose = kleid ? shade(haut, -0.42) : mix(dunklerMantel, const Color(0xFF1C1A20), 0.55);
    hemd = const [Color(0xFFEDE6D6), Color(0xFFE2E7EC), Color(0xFFF2E9D8), Color(0xFFDCD3C4)][(v >> 9) % 4];
    krawatte = const [Color(0xFF7A1E28), Color(0xFF243650), Color(0xFF3B2A20), Color(0xFF4A5A30), Color(0xFF6A4A12)][(v >> 11) % 5];
    akzent = const [Color(0xFF9A2A2A), Color(0xFFB8955A), Color(0xFF2F5A6A), Color(0xFF6A3A6A)][(v >> 13) % 4];
    augen = const [Color(0xFF2A1A10), Color(0xFF3A5A7A), Color(0xFF4A3A1A), Color(0xFF2E4A30)][(v >> 15) % 4];
    schuh = const [Color(0xFF0E0C0E), Color(0xFF2A1A12), Color(0xFF151318)][(v >> 17) % 3];
  }

  final Color mantel;
  final Color haut;
  final Color haar;
  final Color hutFarbe;
  final String hut;
  final String statur;
  final bool kleid;

  /// Fester Hash des Aussehens (Quelle aller abgeleiteten Merkmale).
  final int variante;

  late final bool grau;
  late final Frisur frisur;
  late final bool brille;

  /// 0 kein Bart, 1 Schnurrbart, 2 Vollbart.
  late final int bart;
  late final bool schal;
  late final Color hose;
  late final Color hemd;
  late final Color krawatte;
  late final Color akzent;
  late final Color augen;
  late final Color schuh;

  static int _hash(String s) {
    var h = 0x811C9DC5;
    for (final c in s.codeUnits) {
      h = ((h ^ c) * 0x01000193) & 0x7fffffff;
    }
    return h;
  }
}

/// Frisuren des Rigs (aus dem Aussehen abgeleitet).
enum Frisur { kurz, seitenscheitel, zurueck, locken, lang, zopf, glatze }

/// Abgeleitete Pose eines Bildes: Drehung, Proportionen, Gang, Ruhe.
class _Pose {
  _Pose(this.a, double sx, double sy, this.walk, double moveAmt, this.ruhe, this.suchen, this.befragen, this.handlungsZeit)
      : move = moveAmt.clamp(0.0, 1.0) {
    // Gierwinkel: 0 = zum Betrachter, ±π/2 = seitlich, π = abgewandt.
    final l = math.sqrt(sx * sx + sy * sy);
    final dx = l < 1e-6 ? 0.0 : sx / l, dy = l < 1e-6 ? 1.0 : sy / l;
    seite = dx;
    front = dy;
    seiteAbs = seite.abs();
    frontAbs = front.abs();
    profil = seiteAbs > 0.72;
    nahSeite = seite >= 0 ? 1.0 : -1.0;
    fernSeite = -nahSeite;
    // Vorwärtsrichtung der Glieder auf dem Bildschirm (seitlich flach, frontal verkürzt).
    vorX = seite;
    vorY = front;
    final (w, h) = switch (a.statur) {
      'slim' => (0.86, 1.0),
      'broad' => (1.22, 0.98),
      'tall' => (0.94, 1.12),
      'small' => (0.92, 0.86),
      _ => (1.0, 1.0),
    };
    wm = w;
    hm = h;
    final atem = ruhe == 0 ? 0.0 : math.sin(ruhe * 1.3);
    atmen = 0.5 + 0.5 * atem;
    gewicht = ruhe == 0 ? 0.0 : math.sin(ruhe * 0.35) * 0.7;
    kopfDrehung = ruhe == 0 ? 0.0 : math.sin(ruhe * 0.21 + 1.3) * 0.5;
    nicken = befragen ? math.sin(handlungsZeit * 2.6) * 0.5 : 0.0;
    wippen = math.sin(walk).abs() * 1.8 * move;
    // Blinzeln: kurz alle paar Sekunden, je Figur versetzt.
    final takt = ((ruhe == 0 ? handlungsZeit + walk * 0.1 : ruhe) * 0.7 + a.variante % 97 * 0.13) % 4.3;
    blinzeln = takt < 0.11;
  }

  final FigurAussehen a;
  final double walk;
  final double move;
  final double ruhe;
  final bool suchen;
  final bool befragen;
  final double handlungsZeit;

  late final double seite, front, seiteAbs, frontAbs;
  late final bool profil;
  late final double nahSeite, fernSeite, vorX, vorY;
  late final double wm, hm;
  late final double atmen, gewicht, kopfDrehung, nicken, wippen;
  late final bool blinzeln;

  double get schulterBreite => 9.2 * wm * (0.6 + 0.4 * frontAbs);
  double get hueftBreite => 8.6 * wm;
  double get saumBreite => (a.kleid ? 12.8 : 10.4) * wm * (0.62 + 0.38 * frontAbs);
  double get schulterY => -41.0 * hm;
  double get tailleY => -27.0 * hm;
  double get hueftY => -24.5 * hm;
  double get saumY => (a.kleid ? -7.0 : -12.5) * hm;
  double get kopfY => -51.5 * hm;
  double get oberschenkel => 11.6 * hm;
  double get unterschenkel => 11.4 * hm;
  double get oberarm => 9.0 * hm;
  double get unterarm => 8.4 * hm;
}
