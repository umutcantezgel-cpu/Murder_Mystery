import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mordakte_core/mordakte_core.dart' show LookDef;

import '../../stil/stil.dart';
import '../../ui/widgets/portrait.dart' show PortraitPainter;

/// Seltenheit einer Spielkarte: Zinn, Messing oder Blutgold.
enum KartenSeltenheit { zinn, messing, blutgold }

/// Spielkarte im Format 63 : 88 mit Vorder- und Rückseite.
///
/// Vorderseite: Ölverlauf in [farbe], die Büste aus [look] (oder ein eigenes
/// [bild]), gotischer Doppelrahmen mit Eckschnörkeln, Namensband in
/// Schreibmaschinenschrift, Wirkungstext, Edelstein der Seltenheit und das
/// Siegel der Akte. Rückseite: Mordakte-Lupensiegel auf weinrotem Damast.
///
/// Ein Tipp dreht die Karte in 450 ms um die senkrechte Achse (mit Perspektive);
/// bei „Bewegung reduzieren“ blendet sie stattdessen über. Die Karte zeigt
/// nur, was ihr der Aufrufer übergibt, und kennt keine Spieldaten.
class SpielKarte extends StatefulWidget {
  const SpielKarte({
    super.key,
    required this.name,
    required this.farbe,
    this.look,
    this.bild,
    this.wirkung = '',
    this.seltenheit = KartenSeltenheit.zinn,
    this.seltenheitText,
    this.akte = '',
    this.aufgedeckt = true,
    this.umdrehbar = true,
    this.onUmgedreht,
    this.rueckseitenText = 'Mordakte',
    this.rueckseitenSemantik,
    this.breite,
  });

  /// Name der Karte (Schreibmaschinenschrift im Namensband).
  final String name;

  /// Grundfarbe des Ölverlaufs.
  final Color farbe;

  /// Figur für die Büste; ohne [look] und [bild] bleibt das Bildfeld leer.
  final LookDef? look;

  /// Eigenes Bild statt der Büste.
  final Widget? bild;

  /// Wirkungstext (Inter).
  final String wirkung;
  final KartenSeltenheit seltenheit;

  /// Name der Seltenheit für den Bildschirmleser, bereits übersetzt.
  final String? seltenheitText;

  /// Kürzel der Akte, unten auf der Karte (z. B. `SK`).
  final String akte;

  /// Vorderseite oben (`true`) oder Rückseite oben (`false`).
  final bool aufgedeckt;

  /// Tipp dreht die Karte um.
  final bool umdrehbar;

  /// Meldet die neue Seite nach dem Umdrehen (`true` = Vorderseite).
  final ValueChanged<bool>? onUmgedreht;

  /// Schriftzug unter dem Siegel der Rückseite.
  final String rueckseitenText;

  /// Beschriftung der Rückseite für den Bildschirmleser (sonst [rueckseitenText]).
  final String? rueckseitenSemantik;

  /// Feste Breite; ohne Angabe füllt die Karte die verfügbare Breite.
  final double? breite;

  @override
  State<SpielKarte> createState() => _SpielKarteState();
}

class _SpielKarteState extends State<SpielKarte> with SingleTickerProviderStateMixin {
  /// 0 = Vorderseite oben, 1 = Rückseite oben.
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 450),
    value: widget.aufgedeckt ? 0 : 1,
  );

  /// Zielseite der Umdrehung (unabhängig vom Animationsstand).
  late bool _ziel = widget.aufgedeckt;

  @override
  void didUpdateWidget(SpielKarte alt) {
    super.didUpdateWidget(alt);
    if (alt.aufgedeckt != widget.aufgedeckt && widget.aufgedeckt != _ziel) _setze(widget.aufgedeckt, melden: false);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _setze(bool vorn, {bool melden = true}) {
    // Neu bauen, damit die Beschriftung für Bildschirmleser die sichtbare Seite nennt.
    setState(() => _ziel = vorn);
    final ruhig = MBewegung.ruhig(context);
    // Bei reduzierter Bewegung nur überblenden: kurz, ohne Drehung.
    _c.duration = ruhig ? MBewegung.von(context).dauerSchnell : MBewegung.von(context).dauerLangsam;
    if (vorn) {
      _c.reverse();
    } else {
      _c.forward();
    }
    if (melden) widget.onUmgedreht?.call(vorn);
  }

  void _umdrehen() {
    if (!widget.umdrehbar) return;
    HapticFeedback.selectionClick();
    _setze(!_ziel);
  }

  String get _beschriftung {
    if (!_ziel) return widget.rueckseitenSemantik ?? widget.rueckseitenText;
    final teile = [
      widget.name,
      widget.seltenheitText ?? widget.seltenheit.name,
      widget.wirkung,
    ].where((t) => t.trim().isNotEmpty);
    return teile.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final f = MFarben.von(context);
    final ruhig = MBewegung.ruhig(context);
    return LayoutBuilder(
      builder: (context, box) {
        final breite = widget.breite ?? (box.maxWidth.isFinite ? box.maxWidth : 220.0);
        final hoehe = breite / MMass.kartenSeiten;
        final vorne = _Vorderseite(
          breite: breite,
          name: widget.name,
          farbe: widget.farbe,
          look: widget.look,
          bild: widget.bild,
          wirkung: widget.wirkung,
          rahmenFarbe: f.seltenheit(widget.seltenheit.index),
          edelsteinFarbe: f.seltenheit(widget.seltenheit.index),
          akte: widget.akte,
          papier: f.papier,
          akzent: f.akzentHell,
        );
        final hinten = _Rueckseite(breite: breite, text: widget.rueckseitenText, gold: f.messing);
        final karte = AnimatedBuilder(
          animation: _c,
          builder: (context, _) {
            final v = _c.value;
            if (ruhig) {
              // Überblenden statt Drehen.
              return Stack(
                fit: StackFit.expand,
                children: [
                  Opacity(opacity: 1 - v, child: IgnorePointer(ignoring: v > 0.5, child: vorne)),
                  Opacity(opacity: v, child: IgnorePointer(ignoring: v <= 0.5, child: hinten)),
                ],
              );
            }
            final winkel = v * math.pi;
            final zeigtRueck = winkel > math.pi / 2;
            // Leicht anheben, solange die Karte kippt.
            final hub = 1 + 0.05 * math.sin(v * math.pi);
            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.0012)
                ..scaleByDouble(hub, hub, 1, 1)
                ..rotateY(winkel),
              child: zeigtRueck ? Transform(alignment: Alignment.center, transform: Matrix4.rotationY(math.pi), child: hinten) : vorne,
            );
          },
        );
        return SizedBox(
          width: breite,
          height: hoehe,
          child: Semantics(
            container: true,
            button: widget.umdrehbar,
            label: _beschriftung,
            onTap: widget.umdrehbar ? _umdrehen : null,
            excludeSemantics: true,
            child: MouseRegion(
              cursor: widget.umdrehbar ? SystemMouseCursors.click : MouseCursor.defer,
              child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: widget.umdrehbar ? _umdrehen : null, child: karte),
            ),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Vorderseite

class _Vorderseite extends StatelessWidget {
  const _Vorderseite({
    required this.breite,
    required this.name,
    required this.farbe,
    required this.look,
    required this.bild,
    required this.wirkung,
    required this.rahmenFarbe,
    required this.edelsteinFarbe,
    required this.akte,
    required this.papier,
    required this.akzent,
  });

  final double breite;
  final String name;
  final Color farbe;
  final LookDef? look;
  final Widget? bild;
  final String wirkung;
  final Color rahmenFarbe;
  final Color edelsteinFarbe;
  final String akte;
  final Color papier;
  final Color akzent;

  @override
  Widget build(BuildContext context) {
    final w = breite;
    final h = w / MMass.kartenSeiten;
    final bildRand = BorderRadius.circular(w * 0.03);
    Widget motiv;
    if (bild != null) {
      motiv = FittedBox(fit: BoxFit.cover, clipBehavior: Clip.hardEdge, child: bild);
    } else if (look != null) {
      motiv = FittedBox(
        fit: BoxFit.cover,
        alignment: const Alignment(0, -0.35),
        clipBehavior: Clip.hardEdge,
        child: SizedBox.square(
          dimension: 100,
          child: CustomPaint(painter: PortraitPainter(look: look!, background: false, accent: akzent)),
        ),
      );
    } else {
      motiv = const SizedBox.shrink();
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(w * 0.06),
      child: Stack(
        fit: StackFit.expand,
        children: [
          CustomPaint(painter: _OelPainter(farbe)),
          // Bildfeld mit Innenschatten und Haarlinie.
          Positioned(
            left: w * 0.1,
            right: w * 0.1,
            top: h * 0.07,
            height: h * 0.48,
            child: ClipRRect(
              borderRadius: bildRand,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  const DecoratedBox(decoration: BoxDecoration(color: Color(0x33000000))),
                  motiv,
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        radius: 0.95,
                        colors: [const Color(0x00000000), Colors.black.withValues(alpha: 0.42)],
                        stops: const [0.55, 1],
                      ),
                      borderRadius: bildRand,
                      border: Border.all(color: rahmenFarbe.withValues(alpha: 0.7), width: math.max(1, w * 0.006)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Namensband mit Edelstein.
          Positioned(
            left: w * 0.075,
            right: w * 0.075,
            top: h * 0.525,
            height: h * 0.082,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xE60E0B12), Color(0xF2050408)],
                ),
                border: Border.symmetric(horizontal: BorderSide(color: rahmenFarbe, width: math.max(1, w * 0.006))),
                boxShadow: const [BoxShadow(color: Color(0x88000000), blurRadius: 6, offset: Offset(0, 2))],
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(w * 0.05, 0, w * 0.15, 0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      name,
                      maxLines: 1,
                      style: TextStyle(fontFamily: MRohSchrift.anzeige, fontSize: w * 0.085, color: papier, letterSpacing: w * 0.002),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: w * 0.1,
            top: h * 0.512,
            width: w * 0.12,
            height: h * 0.107,
            child: CustomPaint(painter: _EdelsteinPainter(edelsteinFarbe)),
          ),
          // Wirkungstext.
          Positioned(
            left: w * 0.1,
            right: w * 0.1,
            top: h * 0.64,
            height: h * 0.225,
            child: DecoratedBox(
              decoration: BoxDecoration(color: const Color(0x4D000000), borderRadius: BorderRadius.circular(w * 0.025)),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: w * 0.04, vertical: w * 0.02),
                child: Center(
                  child: Text(
                    wirkung,
                    textAlign: TextAlign.center,
                    maxLines: 5,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontFamily: MRohSchrift.text, fontSize: w * 0.06, height: 1.3, color: papier.withValues(alpha: 0.95)),
                  ),
                ),
              ),
            ),
          ),
          // Siegel der Akte.
          if (akte.isNotEmpty)
            Positioned(
              left: w * 0.1,
              right: w * 0.1,
              top: h * 0.885,
              height: h * 0.06,
              child: Center(
                child: Text(
                  akte,
                  maxLines: 1,
                  style: TextStyle(
                    fontFamily: MRohSchrift.anzeige,
                    fontSize: w * 0.052,
                    letterSpacing: w * 0.012,
                    color: rahmenFarbe.withValues(alpha: 0.95),
                  ),
                ),
              ),
            ),
          Positioned.fill(child: CustomPaint(painter: _GotikRahmenPainter(rahmenFarbe))),
        ],
      ),
    );
  }
}

/// Ölverlauf: Grundfarbe mit hellen und dunklen weichen Schlieren.
class _OelPainter extends CustomPainter {
  _OelPainter(this.farbe);

  final Color farbe;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final hell = Color.lerp(farbe, Colors.white, 0.3)!;
    final dunkel = Color.lerp(farbe, Colors.black, 0.66)!;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [hell, farbe, dunkel],
          stops: const [0, 0.42, 1],
        ).createShader(rect),
    );
    final r = math.Random(farbe.toARGB32());
    for (var i = 0; i < 8; i++) {
      final mitte = Offset(r.nextDouble() * size.width, r.nextDouble() * size.height);
      final radius = size.width * (0.25 + r.nextDouble() * 0.45);
      final ton = i.isEven ? hell : dunkel;
      canvas.drawCircle(
        mitte,
        radius,
        Paint()
          ..shader = RadialGradient(colors: [ton.withValues(alpha: 0.24), ton.withValues(alpha: 0)])
              .createShader(Rect.fromCircle(center: mitte, radius: radius)),
      );
    }
    // Glanz oben links.
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.7, -0.8),
          radius: 0.8,
          colors: [Colors.white.withValues(alpha: 0.12), Colors.white.withValues(alpha: 0)],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(_OelPainter alt) => alt.farbe != farbe;
}

/// Gotischer Doppelrahmen mit Schnörkeln in den vier Ecken.
class _GotikRahmenPainter extends CustomPainter {
  _GotikRahmenPainter(this.farbe);

  final Color farbe;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final linie = Paint()
      ..style = PaintingStyle.stroke
      ..color = farbe.withValues(alpha: 0.92)
      ..strokeCap = StrokeCap.round;
    final aussen = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.03, w * 0.03, size.width - w * 0.06, size.height - w * 0.06),
      Radius.circular(w * 0.05),
    );
    final innen = aussen.deflate(w * 0.03);
    canvas.drawRRect(aussen, linie..strokeWidth = math.max(1.2, w * 0.011));
    canvas.drawRRect(innen, linie..strokeWidth = math.max(0.8, w * 0.005));
    // Eckschnörkel: ein geschwungener Bogen, ein Blatt und eine Perle.
    final u = w * 0.07;
    final bogen = Path()
      ..moveTo(u * 2.3, 0)
      ..quadraticBezierTo(u * 0.15, u * 0.15, 0, u * 2.3)
      ..moveTo(u * 1.5, 0)
      ..quadraticBezierTo(u * 0.55, u * 0.55, 0, u * 1.5);
    final blatt = Path()
      ..moveTo(u * 0.5, u * 0.5)
      ..quadraticBezierTo(u * 1.4, u * 0.45, u * 1.7, u * 1.1)
      ..quadraticBezierTo(u * 0.9, u * 1.2, u * 0.5, u * 0.5);
    final fuell = Paint()
      ..style = PaintingStyle.fill
      ..color = farbe.withValues(alpha: 0.85);
    final r = innen.outerRect.deflate(w * 0.012);
    for (final (o, sx, sy) in [
      (r.topLeft, 1.0, 1.0),
      (r.topRight, -1.0, 1.0),
      (r.bottomLeft, 1.0, -1.0),
      (r.bottomRight, -1.0, -1.0),
    ]) {
      canvas
        ..save()
        ..translate(o.dx, o.dy)
        ..scale(sx, sy)
        ..drawPath(bogen, linie..strokeWidth = math.max(0.8, w * 0.006))
        ..drawPath(blatt, fuell)
        ..drawCircle(Offset(u * 0.28, u * 0.28), u * 0.12, fuell)
        ..restore();
    }
  }

  @override
  bool shouldRepaint(_GotikRahmenPainter alt) => alt.farbe != farbe;
}

/// Edelstein der Seltenheit: eine geschliffene Raute mit Facetten und Glanzpunkt.
class _EdelsteinPainter extends CustomPainter {
  _EdelsteinPainter(this.farbe);

  final Color farbe;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    Offset p(double x, double y) => Offset(w * x, h * y);
    final umriss = Path()
      ..moveTo(p(0.5, 0).dx, p(0.5, 0).dy)
      ..lineTo(p(1, 0.34).dx, p(1, 0.34).dy)
      ..lineTo(p(0.5, 1).dx, p(0.5, 1).dy)
      ..lineTo(p(0, 0.34).dx, p(0, 0.34).dy)
      ..close();
    canvas.drawShadow(umriss, Colors.black, 3, true);
    canvas.drawPath(umriss, Paint()..color = farbe);
    // Oberes Facettenfeld hell, linkes dunkel, rechtes mittel.
    canvas.drawPath(
      Path()
        ..moveTo(p(0, 0.34).dx, p(0, 0.34).dy)
        ..lineTo(p(0.5, 0).dx, p(0.5, 0).dy)
        ..lineTo(p(1, 0.34).dx, p(1, 0.34).dy)
        ..lineTo(p(0.5, 0.46).dx, p(0.5, 0.46).dy)
        ..close(),
      Paint()..color = Colors.white.withValues(alpha: 0.38),
    );
    canvas.drawPath(
      Path()
        ..moveTo(p(0, 0.34).dx, p(0, 0.34).dy)
        ..lineTo(p(0.5, 0.46).dx, p(0.5, 0.46).dy)
        ..lineTo(p(0.5, 1).dx, p(0.5, 1).dy)
        ..close(),
      Paint()..color = Colors.black.withValues(alpha: 0.24),
    );
    canvas.drawPath(
      umriss,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(0.8, w * 0.045)
        ..color = Color.lerp(farbe, Colors.black, 0.55)!,
    );
    canvas.drawCircle(p(0.36, 0.2), w * 0.06, Paint()..color = Colors.white.withValues(alpha: 0.85));
  }

  @override
  bool shouldRepaint(_EdelsteinPainter alt) => alt.farbe != farbe;
}

// ---------------------------------------------------------------------------
// Rückseite

class _Rueckseite extends StatelessWidget {
  const _Rueckseite({required this.breite, required this.text, required this.gold});

  final double breite;
  final String text;
  final Color gold;

  @override
  Widget build(BuildContext context) {
    final w = breite;
    final h = w / MMass.kartenSeiten;
    return ClipRRect(
      borderRadius: BorderRadius.circular(w * 0.06),
      child: Stack(
        fit: StackFit.expand,
        children: [
          CustomPaint(painter: _DamastPainter()),
          CustomPaint(painter: _SiegelPainter(gold)),
          Positioned(
            left: w * 0.1,
            right: w * 0.1,
            top: h * 0.665,
            child: Center(
              child: Text(
                text.toUpperCase(),
                maxLines: 1,
                style: TextStyle(fontFamily: MRohSchrift.anzeige, fontSize: w * 0.065, letterSpacing: w * 0.02, color: gold.withValues(alpha: 0.92)),
              ),
            ),
          ),
          Positioned.fill(child: CustomPaint(painter: _GotikRahmenPainter(gold))),
        ],
      ),
    );
  }
}

/// Weinroter Damast: Rautengitter mit einem dreiblättrigen Motiv je Masche.
class _DamastPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF55122A), Color(0xFF3A0B1C), Color(0xFF2A0714)],
        ).createShader(rect),
    );
    final w = size.width;
    final kachel = w * 0.17;
    final gitter = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(0.6, w * 0.004)
      ..color = const Color(0xFF8E2B47).withValues(alpha: 0.38);
    final motiv = Paint()..color = const Color(0xFF8E2B47).withValues(alpha: 0.34);
    final hell = Paint()..color = const Color(0xFFB5506A).withValues(alpha: 0.18);
    var zeile = 0;
    for (var y = -kachel; y < size.height + kachel; y += kachel * 0.5, zeile++) {
      final versatz = zeile.isEven ? 0.0 : kachel * 0.5;
      for (var x = -kachel + versatz; x < w + kachel; x += kachel) {
        // Raute.
        final c = Offset(x + kachel * 0.5, y + kachel * 0.5);
        canvas.drawPath(
          Path()
            ..moveTo(c.dx, c.dy - kachel * 0.5)
            ..lineTo(c.dx + kachel * 0.5, c.dy)
            ..lineTo(c.dx, c.dy + kachel * 0.5)
            ..lineTo(c.dx - kachel * 0.5, c.dy)
            ..close(),
          gitter,
        );
        // Dreiblättriges Motiv (Lilie).
        final k = kachel * 0.11;
        canvas
          ..drawOval(Rect.fromCenter(center: c.translate(0, -k * 0.9), width: k * 1.1, height: k * 2.4), motiv)
          ..drawOval(Rect.fromCenter(center: c.translate(-k * 0.9, k * 0.1), width: k * 1.0, height: k * 2.0), motiv)
          ..drawOval(Rect.fromCenter(center: c.translate(k * 0.9, k * 0.1), width: k * 1.0, height: k * 2.0), motiv)
          ..drawCircle(c.translate(0, k * 1.2), k * 0.45, hell);
      }
    }
    // Rand abdunkeln.
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          radius: 0.95,
          colors: [const Color(0x00000000), Colors.black.withValues(alpha: 0.4)],
          stops: const [0.55, 1],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(_DamastPainter alt) => false;
}

/// Lupensiegel der Mordakte: Scheibe mit Doppelring und einer Lupe.
class _SiegelPainter extends CustomPainter {
  _SiegelPainter(this.gold);

  final Color gold;

  @override
  void paint(Canvas canvas, Size size) {
    final mitte = Offset(size.width / 2, size.height * 0.46);
    final r = size.width * 0.23;
    canvas.drawCircle(mitte, r, Paint()..color = const Color(0xFF220510));
    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..color = gold.withValues(alpha: 0.95);
    canvas
      ..drawCircle(mitte, r, ring..strokeWidth = math.max(1.2, r * 0.07))
      ..drawCircle(mitte, r * 0.86, ring..strokeWidth = math.max(0.7, r * 0.03));
    // Lupe: Glasring und schräger Griff.
    final glas = mitte.translate(-r * 0.1, -r * 0.1);
    final gr = r * 0.4;
    canvas.drawCircle(glas, gr, Paint()..color = gold.withValues(alpha: 0.1));
    canvas.drawCircle(glas, gr, Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.1
      ..color = gold);
    final w = math.sqrt1_2;
    canvas.drawLine(
      glas.translate(gr * w, gr * w),
      glas.translate(gr * w + r * 0.46, gr * w + r * 0.46),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = r * 0.15
        ..color = gold,
    );
    // Glanzbogen im Glas.
    canvas.drawArc(
      Rect.fromCircle(center: glas, radius: gr * 0.68),
      math.pi * 1.1,
      math.pi * 0.45,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = r * 0.05
        ..color = Colors.white.withValues(alpha: 0.55),
    );
  }

  @override
  bool shouldRepaint(_SiegelPainter alt) => alt.gold != gold;
}
