import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../l10n/lookup.dart';
import '../stil/stil.dart';

/// Text, der Wörter nie mitten im Wort umbricht: Passt das längste Wort nicht in
/// die Breite (große Schrift, schmales Handy), wird die Schrift gerade so weit
/// verkleinert, dass es passt (höchstens auf 40 Prozent). Sonst ein gewöhnlicher [Text].
class GanzeWorte extends StatelessWidget {
  const GanzeWorte(this.text, {super.key, required this.style, this.textAlign, this.maxLines});

  final String text;
  final TextStyle style;
  final TextAlign? textAlign;
  final int? maxLines;

  static final _trenner = RegExp(r'\s+|(?<=-)');

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, box) {
          var faktor = 1.0;
          final groesse = style.fontSize;
          if (box.hasBoundedWidth && groesse != null && box.maxWidth > 0) {
            final scaler = MediaQuery.textScalerOf(context);
            var breitestes = 0.0;
            for (final wort in text.split(_trenner)) {
              if (wort.isEmpty) continue;
              final tp = TextPainter(text: TextSpan(text: wort, style: style), textDirection: TextDirection.ltr, textScaler: scaler, maxLines: 1)..layout();
              if (tp.width > breitestes) breitestes = tp.width;
              tp.dispose();
            }
            if (breitestes > box.maxWidth) faktor = (box.maxWidth / breitestes * 0.98).clamp(0.4, 1.0);
          }
          return Text(
            text,
            textAlign: textAlign,
            maxLines: maxLines,
            overflow: maxLines == null ? null : TextOverflow.ellipsis,
            style: faktor == 1 ? style : style.copyWith(fontSize: groesse! * faktor, letterSpacing: (style.letterSpacing ?? 0) * faktor),
          );
        },
      );
}

/// Wortmarke „MORDAKTE“: geprägte Messinglettern auf dem Schreibtisch, darunter
/// der Untertitel in Schreibmaschine zwischen zwei Messinglinien. Der Titel
/// schrumpft bei großer Schrift, statt zu umbrechen.
class MordakteWortmarke extends StatelessWidget {
  const MordakteWortmarke({super.key});

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final hoehe = MediaQuery.textScalerOf(context).scale(40) * 1.15;
    final messing = Paint()
      ..shader = ui.Gradient.linear(
        Offset(0, hoehe * 0.08),
        Offset(0, hoehe * 0.92),
        const [MRoh.messingHell, Color(0xFFE2BD6A), MRoh.messingMitte, Color(0xFF9A6E22), MRoh.messingHell],
        const [0, 0.32, 0.55, 0.8, 1],
      );
    final titel = TextStyle(
      fontFamily: MRohSchrift.anzeige,
      fontSize: 40,
      height: 1.15,
      fontWeight: FontWeight.w800,
      fontVariations: const [FontVariation('wght', 800)],
      letterSpacing: 7,
      foreground: messing,
      shadows: const [
        // Prägung: dunkle Kante unten, heller Grat oben.
        Shadow(color: Color(0xCC000000), offset: Offset(0, 2.5), blurRadius: 3),
        Shadow(color: Color(0x66FFF0C4), offset: Offset(0, -1)),
      ],
    );
    final linie = Container(
      width: 28,
      height: 1.2,
      decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0x00C99A3E), MRoh.messingMitte])),
    );
    return Column(
      children: [
        const SizedBox(height: MMass.s8),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Padding(
            // Die Laufweite steht auch hinter dem letzten Buchstaben; so bleibt die Marke mittig.
            padding: const EdgeInsets.only(left: 7),
            child: Text(l.appTitle.toUpperCase(), textAlign: TextAlign.center, style: titel),
          ),
        ),
        const SizedBox(height: MMass.s4),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              linie,
              const SizedBox(width: MMass.s12),
              Text(
                l.appSubtitle.toUpperCase(),
                textAlign: TextAlign.center,
                style: MRohSchrift.schreibmaschine.copyWith(fontSize: 13, letterSpacing: 2.2, color: MRoh.messingHell.withValues(alpha: 0.85)),
              ),
              const SizedBox(width: MMass.s12),
              Transform.flip(flipX: true, child: linie),
            ],
          ),
        ),
      ],
    );
  }
}

/// Kopf eines Abschnitts auf dem Schreibtisch: Marke in Messing, eine feine
/// Linie und ein leiser Hinweis darunter.
class SchreibtischKopf extends StatelessWidget {
  const SchreibtischKopf({super.key, required this.marke, this.hinweis});

  /// Bereits in der gewünschten Schreibweise (z. B. Versalien).
  final String marke;
  final String? hinweis;

  @override
  Widget build(BuildContext context) {
    final t = MSchrift.von(context);
    final f = MFarben.von(context);
    final linie = Container(
      height: 1,
      decoration: BoxDecoration(gradient: LinearGradient(colors: [f.akzent.withValues(alpha: 0.55), f.akzent.withValues(alpha: 0)])),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LayoutBuilder(
          builder: (context, box) {
            final tp = TextPainter(
              text: TextSpan(text: marke, style: t.marke),
              textDirection: TextDirection.ltr,
              textScaler: MediaQuery.textScalerOf(context),
              maxLines: 1,
            )..layout();
            final breite = tp.width;
            tp.dispose();
            // Die Linie läuft hinter der Marke aus; passt die Marke nicht, steht sie allein.
            if (breite + 60 > box.maxWidth) return Text(marke, style: t.marke);
            return Row(children: [Text(marke, style: t.marke), const SizedBox(width: MMass.s12), Expanded(child: linie)]);
          },
        ),
        if (hinweis != null) ...[const SizedBox(height: 2), Text(hinweis!, style: t.leise)],
      ],
    );
  }
}

/// Fortschritt als Balken: auf Papier ein Tintenrahmen mit Schraffur, auf dem
/// Schreibtisch eine eingelassene Messingschiene. Nur Bild; die Zahl steht daneben.
class TintenBalken extends StatelessWidget {
  const TintenBalken({super.key, required this.wert, this.hoehe = 10, this.farbe});

  /// 0 bis 1.
  final double wert;
  final double hoehe;

  /// Farbe der Füllung; ohne Angabe Tintenblau auf Papier, Messing auf dem Schreibtisch.
  final Color? farbe;

  @override
  Widget build(BuildContext context) {
    final papier = MFlaeche.hellVon(context);
    return ExcludeSemantics(
      child: SizedBox(
        height: hoehe,
        width: double.infinity,
        child: CustomPaint(painter: _BalkenMaler(wert.clamp(0.0, 1.0), papier: papier, farbe: farbe)),
      ),
    );
  }
}

class _BalkenMaler extends CustomPainter {
  _BalkenMaler(this.wert, {required this.papier, this.farbe});

  final double wert;
  final bool papier;
  final Color? farbe;

  @override
  void paint(Canvas canvas, Size size) {
    final r = Offset.zero & size;
    if (papier) {
      final tinte = farbe ?? MRoh.tinteBlau;
      canvas.drawRect(
        r.deflate(0.8),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2
          ..color = MRoh.tinte.withValues(alpha: 0.7),
      );
      final voll = Rect.fromLTWH(r.left + 2, r.top + 2, (r.width - 4) * wert, r.height - 4);
      canvas.save();
      canvas.clipRect(voll);
      canvas.drawRect(voll, Paint()..color = tinte.withValues(alpha: 0.16));
      final strich = Paint()
        ..strokeWidth = 1.3
        ..color = tinte.withValues(alpha: 0.85);
      for (var x = voll.left - size.height; x < voll.right + size.height; x += 4) {
        canvas.drawLine(Offset(x, voll.bottom), Offset(x + size.height, voll.top), strich);
      }
      canvas.restore();
      return;
    }
    final rr = RRect.fromRectAndRadius(r, Radius.circular(size.height / 2));
    canvas.drawRRect(rr, Paint()..color = const Color(0xFF120F14));
    canvas.drawRRect(
      rr,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = MRoh.messingDunkel,
    );
    if (wert <= 0) return;
    final voll = RRect.fromRectAndRadius(Rect.fromLTWH(1.5, 1.5, (size.width - 3) * wert, size.height - 3), Radius.circular(size.height / 2));
    canvas.drawRRect(
      voll,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: farbe == null
              ? const [MRoh.messingHell, MRoh.messingMitte, Color(0xFF8A6220)]
              : [Color.lerp(farbe, Colors.white, 0.3)!, farbe!, Color.lerp(farbe, Colors.black, 0.35)!],
        ).createShader(voll.outerRect),
    );
  }

  @override
  bool shouldRepaint(covariant _BalkenMaler alt) => alt.wert != wert || alt.papier != papier || alt.farbe != farbe;
}
