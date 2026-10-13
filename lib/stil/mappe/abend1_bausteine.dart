import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../tokens.dart';
import 'material.dart';
import 'zeichen.dart';

import '../widgets/m_ganze_worte.dart';

export '../widgets/m_ganze_worte.dart';

// Bausteine des Abends (Rundenuhr, aufgeschlagene Mappe, Stempelzeile,
// Umschlag). Sie zeigen keine eigenen Texte; jede Beschriftung kommt vom
// Bildschirm.

/// Ist [breite] schmal im Verhältnis zur Schriftgröße? Dann stehen Bilder über
/// statt neben dem Text, und Ränder werden enger (320 px bei 200 % Schrift).
bool schmalFuerSchrift(BuildContext context, double breite) => breite < 60 + 150 * MediaQuery.textScalerOf(context).scale(1);

/// Lage der Teile einer [MTaschenuhr] in ihrer Fläche.
class _UhrGeometrie {
  _UhrGeometrie(Size size)
      : breite = size.width,
        radius = size.width * 0.44,
        mitte = Offset(size.width / 2, size.height - size.width * 0.44 - size.width * 0.02);

  final double breite;

  /// Mittelpunkt des Gehäuses.
  final Offset mitte;

  /// Radius des Gehäuses.
  final double radius;

  /// Radius des Zifferblatts.
  double get blatt => radius * 0.84;

  /// Mittelpunkt und Radius des Bügels über der Krone.
  Offset get buegel => Offset(mitte.dx, mitte.dy - radius - breite * 0.1);
  double get buegelRadius => breite * 0.07;

  /// Fenster im Zifferblatt (unter der Achse, über der Sechs).
  Rect get fenster => Rect.fromCenter(center: mitte + Offset(0, blatt * 0.4), width: blatt * 1.12, height: blatt * 0.4);
}

/// Taschenuhr aus Messing als Rundenuhr: Bügel, Krone und eine kurze Kette,
/// ein Zifferblatt aus Email mit römischen Ziffern, ein rotes Segment für die
/// verbleibende Zeit, ein gebläuter Zeiger und ein roter Sekundenzeiger.
///
/// - [fenster] liegt in einem Ausschnitt des Zifferblatts (z. B. die Restzeit als Text).
/// - [stempel] liegt quer über dem Zifferblatt (z. B. wenn die Zeit um ist).
/// - Die Zeiger gleiten bei „Bewegung reduzieren“ nicht, sie springen.
/// - Das Uhrwerk selbst ist für den Bildschirmleser stumm; [fenster] und
///   [stempel] bleiben lesbar.
class MTaschenuhr extends StatelessWidget {
  const MTaschenuhr({
    super.key,
    required this.anteil,
    this.sekunden = 0,
    this.groesse = 280,
    this.fenster,
    this.stempel,
  });

  /// Verbleibender Anteil (1 = volle Zeit, 0 = abgelaufen).
  final double anteil;

  /// Vergangene Sekunden; der Sekundenzeiger springt im Takt mit.
  final int sekunden;

  /// Breite der Uhr. Die Höhe ist um Bügel und Krone größer ([hoeheZuBreite]).
  final double groesse;

  final Widget? fenster;
  final Widget? stempel;

  /// Höhe zu Breite der ganzen Uhr samt Bügel.
  static const hoeheZuBreite = 1.14;

  @override
  Widget build(BuildContext context) {
    final groesse = Size(this.groesse, this.groesse * hoeheZuBreite);
    final geo = _UhrGeometrie(groesse);
    final fensterRect = geo.fenster;
    final rest = anteil.clamp(0.0, 1.0);
    return SizedBox.fromSize(
      size: groesse,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(child: ExcludeSemantics(child: RepaintBoundary(child: CustomPaint(painter: _GehaeuseMaler(mitFenster: fenster != null))))),
          Positioned.fill(
            child: ExcludeSemantics(
              child: TweenAnimationBuilder<double>(
                tween: Tween(end: rest),
                duration: MBewegung.normal(context),
                curve: Curves.easeOutCubic,
                builder: (context, a, _) => TweenAnimationBuilder<double>(
                  tween: Tween(end: sekunden.toDouble()),
                  duration: MBewegung.schnell(context),
                  curve: Curves.easeOutBack,
                  builder: (context, sek, _) => CustomPaint(painter: _ZeigerMaler(anteil: a, sekunden: sek)),
                ),
              ),
            ),
          ),
          if (fenster != null)
            Positioned.fromRect(
              rect: fensterRect,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: MRoh.karteikarte,
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(color: MRoh.tinte.withValues(alpha: 0.45), width: 1.2),
                  boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 2, offset: Offset(0, 1))],
                ),
                child: MFlaeche.papier(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    child: Center(child: FittedBox(fit: BoxFit.scaleDown, child: fenster)),
                  ),
                ),
              ),
            ),
          const Positioned.fill(child: IgnorePointer(child: ExcludeSemantics(child: CustomPaint(painter: _GlasMaler())))),
          if (stempel != null)
            Positioned(
              left: geo.mitte.dx - geo.blatt * 1.05,
              width: geo.blatt * 2.1,
              top: geo.mitte.dy - geo.blatt * 0.62,
              height: geo.blatt * 0.62,
              child: MFlaeche.papier(child: Center(child: FittedBox(fit: BoxFit.scaleDown, child: stempel))),
            ),
        ],
      ),
    );
  }
}

/// Gehäuse, Kette, Bügel, Krone und Zifferblatt: alles, was sich nicht bewegt.
class _GehaeuseMaler extends CustomPainter {
  const _GehaeuseMaler({this.mitFenster = false});

  /// Mit Fenster im Zifferblatt: die Ziffern IIII, V, VII und VIII entfallen,
  /// wie bei Uhren mit Datumsfenster.
  final bool mitFenster;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final g = _UhrGeometrie(size);
    final c = g.mitte;
    final r = g.radius;
    final rd = g.blatt;
    final w = size.width;

    _kette(canvas, g);

    // Bügel.
    final buegelRect = Rect.fromCircle(center: g.buegel, radius: g.buegelRadius);
    canvas.drawCircle(
      g.buegel + const Offset(1.5, 2.5),
      g.buegelRadius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.026
        ..color = Colors.black.withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );
    canvas.drawCircle(
      g.buegel,
      g.buegelRadius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.024
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [MRoh.messingHell, MRoh.messingMitte, MRoh.messingDunkel],
        ).createShader(buegelRect.inflate(w * 0.02)),
    );
    canvas.drawArc(
      buegelRect.deflate(w * 0.004),
      math.pi * 1.05,
      math.pi * 0.6,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.006
        ..strokeCap = StrokeCap.round
        ..color = Colors.white.withValues(alpha: 0.45),
    );

    // Hals und Krone mit Rändelung.
    final hals = Rect.fromLTRB(c.dx - w * 0.022, c.dy - r - w * 0.04, c.dx + w * 0.022, c.dy - r + w * 0.01);
    canvas.drawRect(hals, Paint()..shader = _quer().createShader(hals));
    final krone = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(c.dx, c.dy - r - w * 0.055), width: w * 0.085, height: w * 0.05),
      Radius.circular(w * 0.012),
    );
    canvas.drawRRect(krone.shift(const Offset(1, 2)), Paint()..color = Colors.black.withValues(alpha: 0.3));
    canvas.drawRRect(krone, Paint()..shader = _quer().createShader(krone.outerRect));
    final kerbe = Paint()
      ..color = MRoh.messingDunkel.withValues(alpha: 0.6)
      ..strokeWidth = 0.8;
    for (var x = krone.left + 2.5; x < krone.right - 1.5; x += 2.6) {
      canvas.drawLine(Offset(x, krone.top + 1.5), Offset(x, krone.bottom - 1.5), kerbe);
    }

    // Gehäuse mit Schatten auf dem Tisch.
    final gehaeuse = Rect.fromCircle(center: c, radius: r);
    canvas.drawShadow(Path()..addOval(gehaeuse), Colors.black, 12, false);
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [MRoh.messingHell, MRoh.messingMitte, Color(0xFFA77A28), MRoh.messingDunkel],
          stops: [0, 0.35, 0.7, 1],
        ).createShader(gehaeuse),
    );
    // Gerändelter Rand.
    final raendel = Paint()
      ..color = MRoh.messingDunkel.withValues(alpha: 0.5)
      ..strokeWidth = 1;
    for (var i = 0; i < 132; i++) {
      final winkel = i * 2 * math.pi / 132;
      final d = Offset(math.cos(winkel), math.sin(winkel));
      canvas.drawLine(c + d * (r * 0.955), c + d * (r * 0.995), raendel);
    }
    canvas.drawCircle(
      c,
      r - 0.6,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = MRoh.messingDunkel,
    );
    // Lünette: ein Grat, der das Licht anders fängt als das Gehäuse.
    canvas.drawCircle(
      c,
      r * 0.905,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.075
        ..shader = const LinearGradient(
          begin: Alignment.bottomRight,
          end: Alignment.topLeft,
          colors: [MRoh.messingHell, MRoh.messingMitte, MRoh.messingDunkel],
        ).createShader(gehaeuse),
    );

    // Zifferblatt aus Email.
    final blatt = Rect.fromCircle(center: c, radius: rd);
    canvas.drawCircle(
      c,
      rd,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.3, -0.35),
          colors: [const Color(0xFFFFFBF2), MRoh.karteikarte, Color.lerp(MRoh.karteikarte, MRoh.blattSchatten, 0.75)!],
          stops: const [0, 0.55, 1],
        ).createShader(blatt),
    );
    canvas.save();
    canvas.clipPath(Path()..addOval(blatt));
    canvas.drawCircle(
      c,
      rd * 1.02,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = rd * 0.09
        ..color = Colors.black.withValues(alpha: 0.22)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, rd * 0.04),
    );
    canvas.restore();

    // Minutenbahn: zwei feine Ringe, Striche, jeder fünfte kräftig.
    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..color = MRoh.tinte.withValues(alpha: 0.8);
    canvas.drawCircle(c, rd * 0.94, ring);
    canvas.drawCircle(c, rd * 0.885, ring);
    final strich = Paint()..color = MRoh.tinte;
    for (var i = 0; i < 60; i++) {
      final winkel = i * 2 * math.pi / 60 - math.pi / 2;
      final d = Offset(math.cos(winkel), math.sin(winkel));
      final kraeftig = i % 5 == 0;
      strich.strokeWidth = kraeftig ? rd * 0.024 : rd * 0.01;
      canvas.drawLine(c + d * (rd * (kraeftig ? 0.83 : 0.885)), c + d * (rd * 0.94), strich);
    }

    // Römische Ziffern (die Vier als „IIII“, wie auf alten Uhren).
    const ziffern = ['XII', 'I', 'II', 'III', 'IIII', 'V', 'VI', 'VII', 'VIII', 'IX', 'X', 'XI'];
    for (var i = 0; i < 12; i++) {
      if (mitFenster && const {4, 5, 7, 8}.contains(i)) continue;
      final winkel = i * 2 * math.pi / 12 - math.pi / 2;
      final d = Offset(math.cos(winkel), math.sin(winkel));
      final tp = TextPainter(
        text: TextSpan(
          text: ziffern[i],
          style: TextStyle(
            fontFamily: MRohSchrift.anzeige,
            fontSize: rd * 0.15,
            height: 1,
            fontWeight: FontWeight.w600,
            fontVariations: const [FontVariation('wght', 600)],
            color: MRoh.tinte,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, c + d * (rd * 0.68) - Offset(tp.width / 2, tp.height / 2));
    }
  }

  /// Querverlauf für runde Messingteile (Krone, Hals).
  LinearGradient _quer() => const LinearGradient(
        colors: [MRoh.messingDunkel, MRoh.messingHell, MRoh.messingMitte, MRoh.messingDunkel],
        stops: [0, 0.35, 0.7, 1],
      );

  /// Kurze Kette vom Bügel nach rechts, Glied für Glied.
  void _kette(Canvas canvas, _UhrGeometrie g) {
    final w = g.breite;
    final start = g.buegel + Offset(g.buegelRadius * 0.7, g.buegelRadius * 0.7);
    final ende = Offset(w * 1.02, g.mitte.dy - g.radius * 0.35);
    final kontrolle = Offset(w * 0.86, g.buegel.dy + w * 0.02);
    Offset punkt(double t) {
      final u = 1 - t;
      return start * (u * u) + kontrolle * (2 * u * t) + ende * (t * t);
    }

    final laenge = w * 0.05;
    final dicke = w * 0.024;
    final glieder = math.max(6, ((ende - start).distance / (laenge * 0.78)).round());
    final schatten = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.009
      ..color = Colors.black.withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5);
    final metall = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.0075
      ..color = MRoh.messingMitte;
    final licht = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.0028
      ..color = MRoh.messingHell.withValues(alpha: 0.9);
    for (var i = 0; i < glieder; i++) {
      final t = (i + 0.5) / glieder;
      final p = punkt(t);
      final tangente = punkt(math.min(1, t + 0.01)) - punkt(math.max(0, t - 0.01));
      canvas.save();
      canvas.translate(p.dx, p.dy);
      canvas.rotate(math.atan2(tangente.dy, tangente.dx));
      final glied = Rect.fromCenter(center: Offset.zero, width: laenge, height: i.isEven ? dicke : dicke * 0.35);
      canvas.drawOval(glied.shift(const Offset(1, 2)), schatten);
      canvas.drawOval(glied, metall);
      canvas.drawOval(glied.deflate(w * 0.003), licht);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _GehaeuseMaler alt) => alt.mitFenster != mitFenster;
}

/// Rotes Segment der Restzeit, gebläuter Zeiger, Sekundenzeiger und Achse.
class _ZeigerMaler extends CustomPainter {
  _ZeigerMaler({required this.anteil, required this.sekunden});

  final double anteil;
  final double sekunden;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final g = _UhrGeometrie(size);
    final c = g.mitte;
    final rd = g.blatt;
    // Der Zeiger läuft im Uhrzeigersinn; das rote Segment reicht vom Zeiger bis zur Zwölf.
    final zeiger = -math.pi / 2 + 2 * math.pi * (1 - anteil);
    if (anteil > 0.0005) {
      final bogen = 2 * math.pi * anteil;
      canvas.drawArc(
        Rect.fromCircle(center: c, radius: rd * 0.94),
        zeiger,
        bogen,
        true,
        Paint()..color = MRoh.stempelRot.withValues(alpha: 0.08),
      );
      canvas.drawArc(
        Rect.fromCircle(center: c, radius: rd * 0.912),
        zeiger,
        bogen,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = rd * 0.05
          ..color = MRoh.stempelRot.withValues(alpha: 0.7),
      );
    }

    _breguet(canvas, c, zeiger, rd);

    // Sekundenzeiger mit Gegengewicht.
    final ws = -math.pi / 2 + 2 * math.pi * (sekunden % 60) / 60;
    final d = Offset(math.cos(ws), math.sin(ws));
    final rot = Paint()
      ..color = MRoh.stempelRot
      ..strokeWidth = math.max(1.2, rd * 0.014)
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(c - d * (rd * 0.2) + const Offset(1, 1.5), c + d * (rd * 0.86) + const Offset(1, 1.5), Paint()
      ..color = Colors.black.withValues(alpha: 0.18)
      ..strokeWidth = rot.strokeWidth);
    canvas.drawLine(c - d * (rd * 0.2), c + d * (rd * 0.86), rot);
    canvas.drawCircle(c - d * (rd * 0.15), rd * 0.035, Paint()..color = MRoh.stempelRot);

    // Achse.
    canvas.drawCircle(
      c,
      rd * 0.055,
      Paint()
        ..shader = const RadialGradient(center: Alignment(-0.4, -0.4), colors: [MRoh.messingHell, MRoh.messingDunkel])
            .createShader(Rect.fromCircle(center: c, radius: rd * 0.055)),
    );
    canvas.drawCircle(c, rd * 0.018, Paint()..color = MRoh.tinte);
  }

  /// Gebläuter Zeiger nach Breguet: schlanke Spitze mit hohlem Mond.
  void _breguet(Canvas canvas, Offset c, double winkel, double rd) {
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(winkel);
    final lang = rd * 0.72;
    final breit = rd * 0.035;
    final spitze = Path()
      ..moveTo(-rd * 0.12, -breit * 0.8)
      ..lineTo(lang * 0.62, -breit * 0.55)
      ..lineTo(lang, 0)
      ..lineTo(lang * 0.62, breit * 0.55)
      ..lineTo(-rd * 0.12, breit * 0.8)
      ..close();
    final mond = Offset(lang * 0.58, 0);
    canvas.save();
    canvas.translate(1.5, 2);
    canvas.drawPath(spitze, Paint()..color = Colors.black.withValues(alpha: 0.22));
    canvas.restore();
    final blau = Paint()
      ..shader = const LinearGradient(colors: [Color(0xFF16285A), MRoh.tinteBlau, Color(0xFF3A63B0)], stops: [0, 0.6, 1])
          .createShader(Rect.fromLTRB(-rd * 0.12, -breit, lang, breit));
    canvas.drawPath(spitze, blau);
    canvas.drawCircle(
      mond,
      rd * 0.075,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = rd * 0.03
        ..color = MRoh.tinteBlau,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ZeigerMaler alt) => alt.anteil != anteil || alt.sekunden != sekunden;
}

/// Uhrglas: Sichel aus Licht und ein kleiner Glanzpunkt.
class _GlasMaler extends CustomPainter {
  const _GlasMaler();

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final g = _UhrGeometrie(size);
    final c = g.mitte;
    final rd = g.blatt;
    final blatt = Rect.fromCircle(center: c, radius: rd);
    final sichel = Path.combine(
      PathOperation.difference,
      Path()..addOval(blatt),
      Path()..addOval(Rect.fromCircle(center: c + Offset(rd * 0.16, rd * 0.22), radius: rd * 1.02)),
    );
    canvas.drawPath(
      sichel,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.center,
          colors: [Colors.white.withValues(alpha: 0.42), Colors.white.withValues(alpha: 0)],
        ).createShader(blatt),
    );
    canvas.save();
    canvas.translate(c.dx - rd * 0.42, c.dy - rd * 0.56);
    canvas.rotate(-0.6);
    canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: rd * 0.3, height: rd * 0.1), Paint()..color = Colors.white.withValues(alpha: 0.3));
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _GlasMaler alt) => false;
}

/// Aufgeschlagene Aktenmappe: die Innenseite aus Manilakarton mit Falz und
/// Farbband, darauf liegen Blätter ([child]). Alles darin steht auf Papier
/// ([MFlaeche.papier]): Schrift und Bedienelemente tragen Tinte.
class MOffeneMappe extends StatelessWidget {
  const MOffeneMappe({
    super.key,
    required this.child,
    this.reiter,
    this.farbe,
    this.siegel,
    this.padding = const EdgeInsets.fromLTRB(12, 18, 12, 18),
    this.samen = 5,
  });

  final Widget child;

  /// Beschriftung des Reiters (Schreibmaschine, Originalschreibung).
  final String? reiter;

  /// Farbband an der Oberkante (ohne Angabe: Akzent des Themas).
  final Color? farbe;

  /// Siegel unten rechts (Kürzel der Akte).
  final String? siegel;
  final EdgeInsets padding;
  final int samen;

  @override
  Widget build(BuildContext context) {
    final band = farbe ?? MFarben.von(context).akzent;
    final innen = Color.lerp(MRoh.manila, MRoh.blatt, 0.22)!;
    final ecken = BorderRadius.only(
      topLeft: Radius.circular(reiter == null ? 6 : 0),
      topRight: const Radius.circular(6),
      bottomLeft: const Radius.circular(6),
      bottomRight: const Radius.circular(6),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (reiter != null)
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 14),
              child: CustomPaint(
                painter: _MappenReiterMaler(Color.lerp(innen, Colors.white, 0.1)!),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 7, 22, 5),
                  child: Text(reiter!, style: MRohSchrift.schreibmaschine.copyWith(fontSize: 13, color: MRoh.tinte, letterSpacing: 1.2)),
                ),
              ),
            ),
          ),
        Stack(
          clipBehavior: Clip.none,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: ecken,
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.55), blurRadius: 18, offset: const Offset(0, 8)),
                  BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 2, offset: const Offset(0, 1)),
                ],
              ),
              child: ClipRRect(
                borderRadius: ecken,
                child: CustomPaint(
                  painter: ManilaMaler(samen: samen, farbe: innen),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(height: 4, color: band.withValues(alpha: 0.85)),
                      // Falz der aufgeschlagenen Mappe: Kerbe mit Lichtkante.
                      const SizedBox(height: 7),
                      Container(height: 1, color: MRoh.manilaDunkel.withValues(alpha: 0.55)),
                      Container(height: 1, color: Colors.white.withValues(alpha: 0.3)),
                      Padding(
                        padding: padding,
                        child: MFlaeche.papier(
                          child: Builder(
                            builder: (context) => DefaultTextStyle.merge(
                              style: MSchrift.von(context).text,
                              child: IconTheme.merge(data: IconThemeData(color: MFarben.von(context).papier), child: child),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (siegel != null) Positioned(bottom: -12, right: 18, child: MSiegel(kuerzel: siegel!, farbe: band)),
          ],
        ),
      ],
    );
  }
}

class _MappenReiterMaler extends CustomPainter {
  _MappenReiterMaler(this.farbe);

  final Color farbe;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Path()
      ..moveTo(0, size.height)
      ..lineTo(8, 2)
      ..quadraticBezierTo(10, 0, 14, 0)
      ..lineTo(size.width - 14, 0)
      ..quadraticBezierTo(size.width - 10, 0, size.width - 8, 2)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawShadow(p, Colors.black, 2, false);
    canvas.drawPath(
      p,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color.lerp(farbe, Colors.white, 0.2)!, farbe],
        ).createShader(Offset.zero & size),
    );
  }

  @override
  bool shouldRepaint(covariant _MappenReiterMaler alt) => alt.farbe != farbe;
}

/// Stempelabdruck als Zeile mit echtem Text: doppelter Rahmen, Schreibmaschine
/// in Stempelfarbe, abgenutzte Farbe. Anders als [MStempel] bleibt der Text ein
/// gewöhnlicher Text (für Bildschirmleser und Tests in Originalschreibung) und
/// darf umbrechen. Mit [aufschlagen] knallt er beim ersten Aufbau auf das Blatt,
/// außer bei „Bewegung reduzieren“.
class MStempelZeile extends StatefulWidget {
  const MStempelZeile(
    this.text, {
    super.key,
    this.farbe = MRoh.stempelRot,
    this.winkel = -0.03,
    this.groesse = 15,
    this.aufschlagen = false,
    this.grund,
  });

  final String text;
  final Color farbe;

  /// Untergrund innerhalb des Rahmens (z. B. ein Etikett auf dem Uhrglas); ohne Angabe durchsichtig.
  final Color? grund;

  /// Drehung in Bogenmaß.
  final double winkel;

  /// Schriftgröße (Skala: 13, 15, 17).
  final double groesse;
  final bool aufschlagen;

  @override
  State<MStempelZeile> createState() => _MStempelZeileState();
}

class _MStempelZeileState extends State<MStempelZeile> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 420));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!widget.aufschlagen || MBewegung.ruhig(context)) {
      _c.value = 1;
    } else if (_c.status == AnimationStatus.dismissed) {
      _c.forward();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final f = widget.farbe;
    // Rahmen und Innenabstand zusammen: 2 × (2,4 + 2,5 + 1 + 8) Pixel.
    const rahmen = 28.0;
    final abdruck = LayoutBuilder(
      builder: (context, box) {
        final stil = TextStyle(
          fontFamily: MRohSchrift.maschine,
          fontSize: widget.groesse,
          height: 1.25,
          letterSpacing: widget.groesse * 0.1,
          color: f.withValues(alpha: 0.92),
        );
        // Ein langes Wort wird kleiner gestempelt statt mitten im Wort umzubrechen.
        final groesse = ganzeWorteGroesse(context, widget.text, stil, box.maxWidth - rahmen, minimum: 11);
        return CustomPaint(
          foregroundPainter: _AbriebMaler(widget.text.codeUnits.fold(23, (a, b) => (a * 31 + b) & 0xffffff)),
          child: Container(
            padding: const EdgeInsets.all(2.5),
            decoration: BoxDecoration(
              color: widget.grund,
              border: Border.all(color: f.withValues(alpha: 0.9), width: 2.4),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Container(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 3),
              decoration: BoxDecoration(
                border: Border.all(color: f.withValues(alpha: 0.8), width: 1),
                borderRadius: BorderRadius.circular(2),
              ),
              child: Text(widget.text, style: stil.copyWith(fontSize: groesse, letterSpacing: groesse * 0.1)),
            ),
          ),
        );
      },
    );
    return AnimatedBuilder(
      animation: _c,
      builder: (context, kind) {
        final t = Curves.easeOutBack.transform(_c.value.clamp(0.0, 1.0));
        return Opacity(
          opacity: _c.value.clamp(0.0, 1.0),
          child: Transform.rotate(angle: widget.winkel, child: Transform.scale(scale: 2.4 - 1.4 * t, child: kind)),
        );
      },
      child: abdruck,
    );
  }
}

/// Abrieb eines Stempels: Papier scheint in kleinen Punkten durch.
class _AbriebMaler extends CustomPainter {
  _AbriebMaler(this.samen);

  final int samen;

  @override
  void paint(Canvas canvas, Size size) {
    final z = MaterialZufall(samen);
    final p = Paint();
    final n = (size.width * size.height / 30).clamp(0, 900).toInt();
    for (var i = 0; i < n; i++) {
      p.color = MRoh.blatt.withValues(alpha: z.zwischen(0.25, 0.85));
      canvas.drawCircle(Offset(z.naechste() * size.width, z.naechste() * size.height), z.zwischen(0.3, 1.1), p);
    }
  }

  @override
  bool shouldRepaint(covariant _AbriebMaler alt) => alt.samen != samen;
}

/// Umschlag aus Kraftpapier.
///
/// - [offen]: Rückseite mit aufgeklappter Lasche, [child] steckt mit dem unteren
///   Rand in der Tasche (der Inhalt braucht unten [einstecken] Pixel freien Rand).
/// - geschlossen: Vorderseite mit zugeklappter Lasche und [siegel] auf der
///   Spitze; [child] steht auf der Vorderseite unter der Lasche.
class MUmschlag extends StatelessWidget {
  const MUmschlag({
    super.key,
    required this.child,
    this.offen = true,
    this.siegel,
    this.siegelFarbe = MRoh.stempelRot,
    this.einstecken = 30,
    this.rand = 14,
    this.farbe = const Color(0xFFCDB284),
  });

  final Widget child;
  final bool offen;
  final String? siegel;
  final Color siegelFarbe;

  /// Wie tief [child] in der Tasche steckt (nur [offen]).
  final double einstecken;

  /// Wie weit der Umschlag links und rechts unter dem Blatt hervorsieht (nur [offen]).
  final double rand;
  final Color farbe;

  /// Höhe der aufgeklappten Lasche über der Rückseite.
  static const _klappe = 44.0;

  /// So weit ragt die Laschenspitze über das eingesteckte Blatt.
  static const _ueberstand = 24.0;

  /// Höhe der Tasche vor dem eingesteckten Blatt.
  static const _tasche = 62.0;

  /// Tiefe der zugeklappten Lasche auf der Vorderseite.
  static const _lasche = 58.0;

  @override
  Widget build(BuildContext context) {
    if (!offen) {
      return Stack(
        clipBehavior: Clip.none,
        children: [
          CustomPaint(
            painter: _UmschlagZuMaler(farbe, _lasche),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, _lasche + 34, 22, 24),
              child: MFlaeche.papier(child: child),
            ),
          ),
          if (siegel != null)
            Positioned(
              top: _lasche - 26,
              left: 0,
              right: 0,
              child: Center(child: MSiegel(kuerzel: siegel!, farbe: siegelFarbe, groesse: 52)),
            ),
        ],
      );
    }
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(left: 0, right: 0, top: _klappe, bottom: 0, child: CustomPaint(painter: _UmschlagRueckMaler(farbe, _klappe))),
        Padding(padding: EdgeInsets.fromLTRB(rand, _ueberstand, rand, _tasche - einstecken), child: child),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: _tasche,
          child: IgnorePointer(
            child: CustomPaint(
              painter: _TaschenMaler(farbe),
              child: siegel == null ? null : Center(child: MSiegel(kuerzel: siegel!, farbe: siegelFarbe, groesse: 38)),
            ),
          ),
        ),
      ],
    );
  }
}

/// Rückseite mit aufgeklappter Lasche (die Lasche ragt [klappe] über die Fläche).
class _UmschlagRueckMaler extends CustomPainter {
  _UmschlagRueckMaler(this.farbe, this.klappe);

  final Color farbe;
  final double klappe;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final rect = Offset.zero & size;
    final lasche = Path()
      ..moveTo(2, 1)
      ..lineTo(size.width / 2 - 10, -klappe + 4)
      ..quadraticBezierTo(size.width / 2, -klappe - 2, size.width / 2 + 10, -klappe + 4)
      ..lineTo(size.width - 2, 1)
      ..close();
    canvas.drawShadow(lasche, Colors.black, 4, false);
    canvas.drawPath(
      lasche,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color.lerp(farbe, MRoh.manilaDunkel, 0.35)!, Color.lerp(farbe, MRoh.manilaDunkel, 0.15)!],
        ).createShader(Rect.fromLTWH(0, -klappe, size.width, klappe)),
    );
    final koerper = RRect.fromRectAndRadius(rect, const Radius.circular(3));
    canvas.drawShadow(Path()..addRRect(koerper), Colors.black, 8, false);
    canvas.drawRRect(koerper, Paint()..color = Color.lerp(farbe, MRoh.manilaDunkel, 0.25)!);
    canvas.save();
    canvas.clipRRect(koerper);
    ManilaMaler(samen: 9, farbe: Color.lerp(farbe, MRoh.manilaDunkel, 0.2)!).paint(canvas, size);
    // Die Innenseite liegt im Schatten der Tasche.
    canvas.drawRect(rect, Paint()..color = Colors.black.withValues(alpha: 0.12));
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _UmschlagRueckMaler alt) => alt.farbe != farbe || alt.klappe != klappe;
}

/// Vordere Tasche des offenen Umschlags mit den schrägen Falzen.
class _TaschenMaler extends CustomPainter {
  _TaschenMaler(this.farbe);

  final Color farbe;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final rect = Offset.zero & size;
    final form = RRect.fromRectAndCorners(rect, bottomLeft: const Radius.circular(3), bottomRight: const Radius.circular(3));
    canvas.drawShadow(Path()..addRRect(form.shift(const Offset(0, -2))), Colors.black, 3, false);
    canvas.save();
    canvas.clipRRect(form);
    ManilaMaler(samen: 13, farbe: farbe).paint(canvas, size);
    final falz = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = MRoh.manilaDunkel.withValues(alpha: 0.6);
    canvas.drawLine(Offset(0, size.height), Offset(size.width * 0.5, size.height * 0.28), falz);
    canvas.drawLine(Offset(size.width, size.height), Offset(size.width * 0.5, size.height * 0.28), falz);
    canvas.restore();
    canvas.drawLine(
      const Offset(1, 0.5),
      Offset(size.width - 1, 0.5),
      Paint()
        ..strokeWidth = 1
        ..color = Colors.white.withValues(alpha: 0.35),
    );
  }

  @override
  bool shouldRepaint(covariant _TaschenMaler alt) => alt.farbe != farbe;
}

/// Geschlossener Umschlag: Vorderseite mit zugeklappter Lasche ([lasche] tief).
class _UmschlagZuMaler extends CustomPainter {
  _UmschlagZuMaler(this.farbe, this.lasche);

  final Color farbe;
  final double lasche;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final rect = Offset.zero & size;
    final koerper = RRect.fromRectAndRadius(rect, const Radius.circular(3));
    canvas.drawShadow(Path()..addRRect(koerper), Colors.black, 10, false);
    canvas.save();
    canvas.clipRRect(koerper);
    ManilaMaler(samen: 17, farbe: farbe).paint(canvas, size);
    final spitze = Offset(size.width / 2, lasche);
    final klappe = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(spitze.dx + 12, spitze.dy - 4)
      ..quadraticBezierTo(spitze.dx, spitze.dy + 3, spitze.dx - 12, spitze.dy - 4)
      ..close();
    canvas.drawShadow(klappe, Colors.black, 3, false);
    canvas.drawPath(
      klappe,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color.lerp(farbe, Colors.white, 0.12)!, farbe],
        ).createShader(Rect.fromLTWH(0, 0, size.width, lasche)),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _UmschlagZuMaler alt) => alt.farbe != farbe || alt.lasche != lasche;
}
