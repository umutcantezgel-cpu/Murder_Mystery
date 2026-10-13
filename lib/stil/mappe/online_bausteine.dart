import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../tokens.dart';
import 'material.dart';
import 'zeichen.dart';

/// Bausteine der Online-Bildschirme (Lobby, Beitritt, Gastansicht):
/// Fotoabzug ohne Bild, Taschenuhr fürs Warten, Platzkarte mit Abriss,
/// Protokollstreifen, Stimmkreis eines Stimmzettels, geschlossener Aktendeckel
/// und eine Bildzeile, die bei wenig Platz umbricht.
///
/// Alles ist Darstellung: Zierde bleibt für den Bildschirmleser stumm, Muster
/// kommen aus [MaterialZufall] und hängen nie vom Spielstand ab.

/// Dunkle Tinte eines grünen Stempels („Bereit“, „Gelesen“) auf Papier.
const mOnlineStempelGruen = Color(0xFF2F6B37);

// ------------------------------------------------------------ Silhouette

/// Fotoabzug ohne Bild: weißer Rand wie [MFotoabzug], darin der Schattenriss
/// einer noch unbekannten Person (Hut oder bloßer Kopf, je nach [samen]).
/// Für Plätze, deren Rolle noch niemand kennt, und für Bots.
class MOnlineSilhouette extends StatelessWidget {
  const MOnlineSilhouette({
    super.key,
    this.groesse = 52,
    this.neigung = 0,
    this.beschriftung,
    this.stempel,
    this.stempelFarbe = MRoh.stempelRot,
    this.samen = 1,
    this.semantik,
  });

  /// Kantenlänge des Bildes.
  final double groesse;
  final double neigung;

  /// Handschriftliche Zeile unter dem Bild.
  final String? beschriftung;

  /// Stempel quer über das Bild (z. B. „Bot“).
  final String? stempel;
  final Color stempelFarbe;

  /// Samen für Körnung und Kopfform.
  final int samen;

  /// Beschriftung für den Bildschirmleser; sonst Beschriftung und Stempel.
  final String? semantik;

  @override
  Widget build(BuildContext context) {
    final rand = groesse < 64 ? 5.0 : 8.0;
    Widget abzug = DecoratedBox(
      decoration: const BoxDecoration(
        boxShadow: [BoxShadow(color: Color(0x88000000), blurRadius: 10, offset: Offset(0, 5))],
      ),
      child: CustomPaint(
        painter: const PapierMaler(art: PapierArt.foto, flecken: false),
        child: Padding(
          padding: EdgeInsets.fromLTRB(rand, rand, rand, beschriftung == null ? rand : 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DecoratedBox(
                position: DecorationPosition.foreground,
                decoration: BoxDecoration(border: Border.all(color: Colors.black.withValues(alpha: 0.18))),
                child: SizedBox.square(dimension: groesse, child: CustomPaint(painter: _SilhouettenMaler(samen))),
              ),
              if (beschriftung != null)
                SizedBox(
                  width: groesse,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      beschriftung!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: MPapierSchrift.hand.copyWith(fontSize: (groesse * 0.2).clamp(15, 22)),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
    if (stempel != null) {
      abzug = Stack(
        clipBehavior: Clip.none,
        children: [
          abzug,
          // Über den Schultern, damit der Kopf als Umriss lesbar bleibt.
          Positioned(
            left: -8,
            right: -8,
            top: rand + groesse * 0.58,
            child: Center(child: ExcludeSemantics(child: MStempel(text: stempel!, farbe: stempelFarbe, groesse: groesse < 60 ? 12 : 14, aufschlagen: true))),
          ),
        ],
      );
    }
    final label = semantik ?? [?beschriftung, ?stempel].join(', ');
    abzug = label.isEmpty
        ? ExcludeSemantics(child: RepaintBoundary(child: abzug))
        : Semantics(image: true, label: label, excludeSemantics: true, child: RepaintBoundary(child: abzug));
    return neigung == 0 ? abzug : Transform.rotate(angle: neigung, child: abzug);
  }
}

class _SilhouettenMaler extends CustomPainter {
  const _SilhouettenMaler(this.samen);

  final int samen;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final w = size.width;
    final h = size.height;
    final rect = Offset.zero & size;
    // Atelierhintergrund: kühles Grau mit Lichtkegel hinter dem Kopf.
    canvas.drawRect(
      rect,
      Paint()
        ..shader = ui.Gradient.radial(
          Offset(w * 0.5, h * 0.36),
          w * 0.8,
          const [Color(0xFFA3A9AE), Color(0xFF6E757D), Color(0xFF474D55)],
          const [0, 0.55, 1],
        ),
    );
    final dunkel = Paint()..color = const Color(0xFF262A30);
    // Schultern und Hals.
    final schultern = Path()
      ..moveTo(w * 0.06, h)
      ..cubicTo(w * 0.1, h * 0.8, w * 0.26, h * 0.71, w * 0.42, h * 0.69)
      ..lineTo(w * 0.58, h * 0.69)
      ..cubicTo(w * 0.74, h * 0.71, w * 0.9, h * 0.8, w * 0.94, h)
      ..close();
    canvas.drawPath(schultern, dunkel);
    canvas.drawRect(Rect.fromLTRB(w * 0.43, h * 0.5, w * 0.57, h * 0.72), dunkel);
    // Kopf.
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.5, h * 0.42), width: w * 0.3, height: h * 0.36), dunkel);
    // Hut (Fedora) bei zwei von drei Samen: Krone und Krempe.
    if (samen % 3 != 0) {
      final krone = RRect.fromRectAndCorners(
        Rect.fromLTRB(w * 0.35, h * 0.13, w * 0.65, h * 0.31),
        topLeft: Radius.circular(w * 0.08),
        topRight: Radius.circular(w * 0.08),
      );
      canvas.drawRRect(krone, dunkel);
      canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.5, h * 0.3), width: w * 0.54, height: h * 0.08), dunkel);
      canvas.drawLine(
        Offset(w * 0.36, h * 0.26),
        Offset(w * 0.64, h * 0.26),
        Paint()
          ..color = Colors.white.withValues(alpha: 0.12)
          ..strokeWidth = math.max(1, h * 0.025),
      );
    }
    // Körnung des Abzugs.
    final z = MaterialZufall(samen * 131 + size.width.round());
    final korn = Paint();
    final n = (w * h / 28).clamp(30, 600).toInt();
    for (var i = 0; i < n; i++) {
      korn.color = (z.naechste() < 0.5 ? Colors.black : Colors.white).withValues(alpha: z.zwischen(0.03, 0.09));
      canvas.drawCircle(Offset(z.naechste() * w, z.naechste() * h), z.zwischen(0.3, 0.9), korn);
    }
  }

  @override
  bool shouldRepaint(covariant _SilhouettenMaler alt) => alt.samen != samen;
}

// ------------------------------------------------------------ Taschenuhr

/// Taschenuhr aus Messing, deren Sekundenzeiger ruhig im Sekundentakt springt:
/// das Zeichen fürs Warten. Bei „Bewegung reduzieren“ steht sie still. Die
/// Zeiger zeigen keine echte Uhrzeit; die Uhr ist reine Zierde.
class MOnlineTaschenuhr extends StatefulWidget {
  const MOnlineTaschenuhr({super.key, this.groesse = 46});

  /// Durchmesser des Gehäuses.
  final double groesse;

  @override
  State<MOnlineTaschenuhr> createState() => _MOnlineTaschenuhrState();
}

class _MOnlineTaschenuhrState extends State<MOnlineTaschenuhr> {
  Timer? _takt;
  int _sekunde = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Still bei „Bewegung reduzieren“ und solange die Seite verdeckt ist (TickerMode aus).
    if (MBewegung.ruhig(context) || !TickerMode.valuesOf(context).enabled) {
      _takt?.cancel();
      _takt = null;
    } else {
      _takt ??= Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() => _sekunde = (_sekunde + 1) % 3600);
      });
    }
  }

  @override
  void dispose() {
    _takt?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
        child: RepaintBoundary(
          child: SizedBox(
            width: widget.groesse,
            height: widget.groesse * 1.24,
            child: CustomPaint(painter: _UhrMaler(_sekunde)),
          ),
        ),
      );
}

class _UhrMaler extends CustomPainter {
  const _UhrMaler(this.sekunde);

  final int sekunde;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final r = w / 2;
    final m = Offset(r, size.height - r);
    final gehaeuse = Rect.fromCircle(center: m, radius: r);

    // Bügel und Krone über dem Gehäuse.
    final kroneMitte = Offset(r, m.dy - r - w * 0.04);
    canvas.drawCircle(
      Offset(r, kroneMitte.dy - w * 0.1),
      w * 0.085,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.045
        ..color = MRoh.messingMitte,
    );
    final krone = Rect.fromCenter(center: kroneMitte, width: w * 0.17, height: w * 0.11);
    canvas.drawRRect(RRect.fromRectAndRadius(krone, Radius.circular(w * 0.025)), Paint()..shader = messingVerlauf().createShader(krone));

    // Schatten und Gehäuse.
    canvas.drawCircle(
      m + const Offset(1.5, 2.5),
      r * 0.97,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.45)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
    canvas.drawCircle(
      m,
      r,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.35, -0.4),
          colors: [MRoh.messingHell, MRoh.messingMitte, MRoh.messingDunkel],
          stops: [0, 0.55, 1],
        ).createShader(gehaeuse),
    );
    canvas.drawCircle(m, r * 0.86, Paint()..color = MRoh.messingDunkel);

    // Zifferblatt.
    final blatt = Rect.fromCircle(center: m, radius: r * 0.81);
    canvas.drawCircle(
      m,
      r * 0.81,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.25, -0.3),
          colors: [Color(0xFFFCF8EE), Color(0xFFE6DAC0)],
        ).createShader(blatt),
    );
    final strich = Paint()
      ..color = MRoh.tinte
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 60; i++) {
      final gross = i % 5 == 0;
      if (!gross && r < 20) continue;
      final winkel = i * math.pi / 30 - math.pi / 2;
      final richtung = Offset(math.cos(winkel), math.sin(winkel));
      strich.strokeWidth = gross ? math.max(1.2, r * 0.06) : 0.7;
      canvas.drawLine(m + richtung * (r * (gross ? 0.62 : 0.7)), m + richtung * (r * 0.76), strich);
    }

    // Stunden- und Minutenzeiger (ruhig, fast still), dann der springende Sekundenzeiger.
    final minuten = 8 + (sekunde % 3600) / 60;
    final stunden = 10 + minuten / 60;
    void zeiger(double anteil, double laenge, double breite, Color farbe, {double rueck = 0.12}) {
      final winkel = anteil * 2 * math.pi - math.pi / 2;
      final richtung = Offset(math.cos(winkel), math.sin(winkel));
      canvas.drawLine(
        m - richtung * (r * rueck),
        m + richtung * laenge,
        Paint()
          ..color = farbe
          ..strokeWidth = breite
          ..strokeCap = StrokeCap.round,
      );
    }

    zeiger(stunden / 12, r * 0.42, math.max(1.6, r * 0.09), MRoh.tinte);
    zeiger(minuten / 60, r * 0.62, math.max(1.2, r * 0.06), MRoh.tinte);
    zeiger((sekunde % 60) / 60, r * 0.7, math.max(0.8, r * 0.03), MRoh.stempelRot, rueck: 0.2);
    canvas.drawCircle(m, math.max(1.6, r * 0.07), Paint()..shader = messingVerlauf().createShader(Rect.fromCircle(center: m, radius: r * 0.07)));

    // Glasreflex.
    canvas.drawArc(
      Rect.fromCircle(center: m, radius: r * 0.7),
      -2.7,
      1.1,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.08
        ..strokeCap = StrokeCap.round
        ..color = Colors.white.withValues(alpha: 0.35),
    );
  }

  @override
  bool shouldRepaint(covariant _UhrMaler alt) => alt.sekunde != sekunde;
}

// ------------------------------------------------------------ Platzkarte

/// Platzkarte aus Karton: oben ein Kontrollabschnitt ([abschnitt]), darunter
/// nach einer Perforation der Hauptteil ([child]). An der Perforation sind
/// beide Seiten halbrund eingekerbt, wie bei einer Eintrittskarte.
class MOnlineTicket extends StatelessWidget {
  const MOnlineTicket({
    super.key,
    required this.abschnitt,
    required this.child,
    this.neigung = 0,
    this.samen = 5,
    this.art = PapierArt.akte,
  });

  final Widget abschnitt;
  final Widget child;
  final double neigung;
  final int samen;
  final PapierArt art;

  @override
  Widget build(BuildContext context) {
    Widget ticket = RepaintBoundary(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Kerbstueck(
            unten: true,
            art: art,
            samen: samen,
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
            child: abschnitt,
          ),
          _Kerbstueck(
            oben: true,
            perforation: true,
            art: art,
            samen: samen + 1,
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
            child: child,
          ),
        ],
      ),
    );
    return neigung == 0 ? ticket : Transform.rotate(angle: neigung, child: ticket);
  }
}

class _Kerbstueck extends StatelessWidget {
  const _Kerbstueck({
    required this.child,
    required this.art,
    required this.samen,
    required this.padding,
    this.oben = false,
    this.unten = false,
    this.perforation = false,
  });

  final Widget child;
  final PapierArt art;
  final int samen;
  final EdgeInsets padding;
  final bool oben;
  final bool unten;
  final bool perforation;

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: _KerbenSchatten(oben: oben, unten: unten),
        child: ClipPath(
          clipper: _KerbenClipper(oben: oben, unten: unten),
          child: CustomPaint(
            painter: PapierMaler(art: art, samen: samen, flecken: false),
            foregroundPainter: perforation ? const _PerforationMaler() : null,
            child: MFlaeche.papier(
              child: Builder(
                builder: (context) => DefaultTextStyle.merge(
                  style: MSchrift.von(context).text,
                  child: IconTheme.merge(
                    data: const IconThemeData(color: MRoh.tinte),
                    child: Padding(padding: padding, child: child),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}

const _kerbe = 10.0;

Path _kerbenPfad(Size s, {required bool oben, required bool unten}) {
  const r = Radius.circular(_kerbe);
  final p = Path()..moveTo(oben ? _kerbe : 0, 0);
  p.lineTo(oben ? s.width - _kerbe : s.width, 0);
  if (oben) p.arcToPoint(Offset(s.width, _kerbe), radius: r, clockwise: false);
  p.lineTo(s.width, unten ? s.height - _kerbe : s.height);
  if (unten) p.arcToPoint(Offset(s.width - _kerbe, s.height), radius: r, clockwise: false);
  p.lineTo(unten ? _kerbe : 0, s.height);
  if (unten) p.arcToPoint(Offset(0, s.height - _kerbe), radius: r, clockwise: false);
  p.lineTo(0, oben ? _kerbe : 0);
  if (oben) p.arcToPoint(const Offset(_kerbe, 0), radius: r, clockwise: false);
  return p..close();
}

class _KerbenClipper extends CustomClipper<Path> {
  const _KerbenClipper({required this.oben, required this.unten});

  final bool oben;
  final bool unten;

  @override
  Path getClip(Size size) => _kerbenPfad(size, oben: oben, unten: unten);

  @override
  bool shouldReclip(covariant _KerbenClipper alt) => alt.oben != oben || alt.unten != unten;
}

class _KerbenSchatten extends CustomPainter {
  const _KerbenSchatten({required this.oben, required this.unten});

  final bool oben;
  final bool unten;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final pfad = _kerbenPfad(size, oben: oben, unten: unten);
    canvas.drawShadow(pfad.shift(const Offset(0, 2)), Colors.black, 5, false);
  }

  @override
  bool shouldRepaint(covariant _KerbenSchatten alt) => alt.oben != oben || alt.unten != unten;
}

/// Gestrichelte Perforation an der Oberkante zwischen den Kerben.
class _PerforationMaler extends CustomPainter {
  const _PerforationMaler();

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = MRoh.tinte.withValues(alpha: 0.38)
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;
    for (var x = _kerbe + 6; x < size.width - _kerbe - 6; x += 9) {
      canvas.drawLine(Offset(x, 1.5), Offset(math.min(x + 4, size.width - _kerbe - 6), 1.5), p);
    }
  }

  @override
  bool shouldRepaint(covariant _PerforationMaler alt) => false;
}

// ------------------------------------------------------------ Protokollstreifen

/// Protokollstreifen: ein schmaler Streifen Fernschreibpapier mit gerissenen
/// Kanten oben und unten und einer Lochreihe links, wie ein Abhörprotokoll.
/// [randFarbe] zieht einen Registerstrich neben der Lochreihe (Farbcode einer Figur).
class MOnlineProtokoll extends StatelessWidget {
  const MOnlineProtokoll({super.key, required this.child, this.samen = 3, this.neigung = 0, this.randFarbe});

  final Widget child;
  final int samen;
  final double neigung;
  final Color? randFarbe;

  @override
  Widget build(BuildContext context) {
    Widget streifen = RepaintBoundary(
      child: CustomPaint(
        painter: _RissSchatten(samen),
        child: ClipPath(
          clipper: _RissClipper(samen),
          child: CustomPaint(
            painter: PapierMaler(art: PapierArt.telegramm, samen: samen, flecken: false),
            foregroundPainter: _LochreiheMaler(randFarbe),
            child: MFlaeche.papier(
              child: Builder(
                builder: (context) => DefaultTextStyle.merge(
                  style: MSchrift.von(context).text,
                  child: Padding(padding: const EdgeInsets.fromLTRB(38, 18, 16, 18), child: child),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    return neigung == 0 ? streifen : Transform.rotate(angle: neigung, child: streifen);
  }
}

Path _rissPfad(Size s, int samen) {
  final z = MaterialZufall(samen * 97 + s.width.round());
  final p = Path()..moveTo(0, z.zwischen(1, 4));
  for (var x = 6.0; x < s.width; x += 6) {
    p.lineTo(x, z.zwischen(0.5, 4.5));
  }
  p
    ..lineTo(s.width, z.zwischen(1, 4))
    ..lineTo(s.width, s.height - z.zwischen(1, 4));
  for (var x = s.width - 6; x > 0; x -= 6) {
    p.lineTo(x, s.height - z.zwischen(0.5, 4.5));
  }
  return p
    ..lineTo(0, s.height - z.zwischen(1, 4))
    ..close();
}

class _RissClipper extends CustomClipper<Path> {
  const _RissClipper(this.samen);

  final int samen;

  @override
  Path getClip(Size size) => _rissPfad(size, samen);

  @override
  bool shouldReclip(covariant _RissClipper alt) => alt.samen != samen;
}

class _RissSchatten extends CustomPainter {
  const _RissSchatten(this.samen);

  final int samen;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    canvas.drawShadow(_rissPfad(size, samen).shift(const Offset(0, 2)), Colors.black, 5, false);
  }

  @override
  bool shouldRepaint(covariant _RissSchatten alt) => alt.samen != samen;
}

class _LochreiheMaler extends CustomPainter {
  const _LochreiheMaler(this.randFarbe);

  final Color? randFarbe;

  @override
  void paint(Canvas canvas, Size size) {
    final loch = Paint()..color = const Color(0xFF231B1F).withValues(alpha: 0.78);
    final saum = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..color = Colors.white.withValues(alpha: 0.45);
    for (var y = 14.0; y < size.height - 8; y += 18) {
      canvas.drawCircle(Offset(12, y), 3.4, loch);
      canvas.drawCircle(Offset(12.4, y + 0.6), 3.6, saum);
    }
    final strich = Paint()
      ..color = MRoh.tinte.withValues(alpha: 0.28)
      ..strokeWidth = 1;
    for (var y = 6.0; y < size.height - 6; y += 7) {
      canvas.drawLine(Offset(23, y), Offset(23, y + 3.5), strich);
    }
    if (randFarbe != null) {
      canvas.drawRect(Rect.fromLTWH(27, 6, 4, size.height - 12), Paint()..color = randFarbe!.withValues(alpha: 0.85));
    }
  }

  @override
  bool shouldRepaint(covariant _LochreiheMaler alt) => alt.randFarbe != randFarbe;
}

// ------------------------------------------------------------ Stimmkreis

/// Kreis eines Stimmzettels; [angekreuzt] zieht ein Kreuz in Füllertinte
/// hinein, Strich für Strich (bei „Bewegung reduzieren“ sofort).
class MOnlineStimmkreis extends StatelessWidget {
  const MOnlineStimmkreis({super.key, required this.angekreuzt, this.groesse = 32});

  final bool angekreuzt;
  final double groesse;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
        child: TweenAnimationBuilder<double>(
          tween: Tween(end: angekreuzt ? 1 : 0),
          duration: MBewegung.normal(context),
          curve: Curves.easeOut,
          builder: (context, t, _) => SizedBox.square(dimension: groesse, child: CustomPaint(painter: _KreuzMaler(t))),
        ),
      );
}

class _KreuzMaler extends CustomPainter {
  const _KreuzMaler(this.t);

  /// Fortschritt des Kreuzes (0 leer, 0,5 erster Strich, 1 fertig).
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final m = size.center(Offset.zero);
    final r = size.shortestSide / 2 - 2;
    canvas.drawCircle(
      m,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..color = MRoh.tinte.withValues(alpha: 0.75),
    );
    if (t <= 0) return;
    final stift = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..color = MRoh.tinteBlau;
    void strich(Offset a, Offset b, Offset beuge, double anteil) {
      if (anteil <= 0) return;
      final pfad = Path()
        ..moveTo(a.dx, a.dy)
        ..quadraticBezierTo(beuge.dx, beuge.dy, b.dx, b.dy);
      for (final metrik in pfad.computeMetrics()) {
        canvas.drawPath(metrik.extractPath(0, metrik.length * anteil.clamp(0, 1)), stift);
      }
    }

    final d = r * 1.05;
    strich(m + Offset(-d, -d), m + Offset(d * 0.95, d), m + Offset(-d * 0.1, d * 0.12), t * 2);
    strich(m + Offset(d, -d * 0.95), m + Offset(-d * 0.9, d * 0.95), m + Offset(d * 0.12, d * 0.05), t * 2 - 1);
  }

  @override
  bool shouldRepaint(covariant _KreuzMaler alt) => alt.t != t;
}

// ------------------------------------------------------------ Aktendeckel

/// Geschlossener Aktendeckel aus Manilakarton mit Reiter: das Gegenstück zur
/// offenen [MAktenmappe]. Der Inhalt liegt auf dem Karton (Tintenschrift).
class MOnlineAktendeckel extends StatelessWidget {
  const MOnlineAktendeckel({super.key, required this.child, this.reiter, this.farbe, this.neigung = 0});

  final Widget child;

  /// Beschriftung des Reiters (Schreibmaschine, Originalschreibung).
  final String? reiter;

  /// Band unter dem Reiter; ohne Angabe der Akzent.
  final Color? farbe;
  final double neigung;

  @override
  Widget build(BuildContext context) {
    final band = farbe ?? MFarben.von(context).akzent;
    const ecken = BorderRadius.only(
      topRight: Radius.circular(6),
      bottomLeft: Radius.circular(6),
      bottomRight: Radius.circular(6),
    );
    Widget deckel = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Der Reiter ist ein Aktenzeichen und bleibt für den Bildschirmleser stumm:
        // Ein Deckel ist meist ein Knopf, dessen Name nur der Inhalt sein soll.
        if (reiter != null)
          ExcludeSemantics(
            child: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: CustomPaint(
                painter: _DeckelReiterMaler(Color.lerp(MRoh.manila, Colors.white, 0.08)!),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 7, 22, 5),
                  child: Text(reiter!, style: MRohSchrift.schreibmaschine.copyWith(fontSize: 13, color: MRoh.tinte, letterSpacing: 1.2)),
                ),
              ),
            ),
          ),
        DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: ecken,
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 14, offset: const Offset(0, 6)),
              BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 2, offset: const Offset(0, 1)),
            ],
          ),
          child: ClipRRect(
            borderRadius: ecken,
            child: CustomPaint(
              painter: const ManilaMaler(samen: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(height: 5, color: band.withValues(alpha: 0.85)),
                  MFlaeche.papier(
                    child: Builder(
                      builder: (context) => DefaultTextStyle.merge(
                        style: MSchrift.von(context).text,
                        child: IconTheme.merge(
                          data: const IconThemeData(color: MRoh.tinte),
                          child: Padding(padding: const EdgeInsets.fromLTRB(14, 12, 12, 12), child: child),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
    deckel = RepaintBoundary(child: deckel);
    return neigung == 0 ? deckel : Transform.rotate(angle: neigung, child: deckel);
  }
}

class _DeckelReiterMaler extends CustomPainter {
  const _DeckelReiterMaler(this.farbe);

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
  bool shouldRepaint(covariant _DeckelReiterMaler alt) => alt.farbe != farbe;
}

// ------------------------------------------------------------ Bildzeile

/// Bild und Text nebeneinander (Fotoabzug und Name), rechts optional ein
/// Zustand (Stempel, Etikett). Wird es schmal oder die Schrift groß, rückt der
/// Zustand unter den Text; ganz schmal steht auch der Text unter dem Bild.
class MOnlineBildZeile extends StatelessWidget {
  const MOnlineBildZeile({super.key, required this.bild, required this.text, this.rechts, this.abstand = 14});

  final Widget bild;
  final Widget text;
  final Widget? rechts;
  final double abstand;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, b) {
          final skala = MediaQuery.textScalerOf(context).scale(10) / 10;
          final breite = b.maxWidth;
          // Platz für den Text neben dem Bild, gemessen in Buchstaben der Grundgröße:
          // Reicht er nicht für ein langes Wort, steht der Text unter dem Bild.
          if (breite < 210 || (breite - 80) / skala < 110) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [bild, const SizedBox(height: 10), text, if (rechts != null) ...[const SizedBox(height: 8), rechts!]],
            );
          }
          final rechtsDarunter = breite < 360 || skala > 1.3;
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              bild,
              SizedBox(width: abstand),
              Expanded(
                child: rechtsDarunter && rechts != null
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [text, const SizedBox(height: 8), rechts!],
                      )
                    : text,
              ),
              if (!rechtsDarunter && rechts != null) ...[
                const SizedBox(width: 10),
                ConstrainedBox(constraints: BoxConstraints(maxWidth: breite * 0.42), child: rechts!),
              ],
            ],
          );
        },
      );
}
