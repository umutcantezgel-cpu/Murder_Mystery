import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../tokens.dart';
import '../widgets/m_tafel.dart';
import 'blatt.dart';
import 'material.dart';
import 'zeichen.dart';

/// Bausteine der Abendbildschirme (Karte, Würfel, Funde, Anklage, Finale):
/// Beweisanhänger mit Öse und Schnur, gemalte Würfel, eine rollbare Karteikarte
/// als Dialog, ein Korkbrett mit freier Höhe und das Erinnerungsfoto in Sepia.
///
/// Alles ist reine Darstellung: Zierde bleibt für den Bildschirmleser stumm,
/// Muster kommen aus [MaterialZufall] und hängen nie vom Spielstand ab.

/// Papier eines Beweisanhängers: heller Karton zwischen Manila und Aktenpapier.
final Color _anhaengerKarton = Color.lerp(MRoh.manila, MRoh.blatt, 0.55)!;

/// Beweisanhänger: ein Kartonetikett mit abgeschrägten Ecken, Messingöse und
/// Schnur. Oben steht eine Schreibmaschinenzeile (z. B. „Beweisstück Nr. 03“),
/// darunter eine Perforation und der Inhalt in Tinte.
class MBeweisanhaenger extends StatelessWidget {
  const MBeweisanhaenger({super.key, required this.child, this.kopf, this.neigung = 0, this.samen = 5});

  final Widget child;

  /// Schreibmaschinenzeile unter der Öse, in Originalschreibung.
  final String? kopf;
  final double neigung;
  final int samen;

  /// Platz über dem Etikett, in dem die Schnur hängt.
  static const fadenRaum = 24.0;

  @override
  Widget build(BuildContext context) {
    final inhalt = MFlaeche.papier(
      child: Builder(
        builder: (context) => DefaultTextStyle.merge(
          style: MSchrift.von(context).text,
          child: IconTheme.merge(
            data: IconThemeData(color: MFarben.von(context).papier),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (kopf != null) ...[
                  Text(
                    kopf!,
                    textAlign: TextAlign.center,
                    style: MPapierSchrift.maschine.copyWith(fontSize: 13, letterSpacing: 1.4, color: MRoh.stempelRot),
                  ),
                  const SizedBox(height: 8),
                  const MPerforation(),
                  const SizedBox(height: 14),
                ],
                child,
              ],
            ),
          ),
        ),
      ),
    );
    Widget etikett = CustomPaint(
      painter: _AnhaengerMaler(samen: samen),
      child: Padding(padding: const EdgeInsets.fromLTRB(20, fadenRaum + 42, 20, 20), child: inhalt),
    );
    etikett = RepaintBoundary(child: etikett);
    return neigung == 0 ? etikett : Transform.rotate(angle: neigung, child: etikett);
  }
}

class _AnhaengerMaler extends CustomPainter {
  _AnhaengerMaler({required this.samen});

  final int samen;

  static const _fase = 22.0;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    const oben = MBeweisanhaenger.fadenRaum;
    final w = size.width;
    final h = size.height;
    final form = Path()
      ..moveTo(_fase, oben)
      ..lineTo(w - _fase, oben)
      ..lineTo(w, oben + _fase)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..lineTo(0, oben + _fase)
      ..close();
    canvas.drawShadow(form, Colors.black, 7, false);
    final flaeche = Rect.fromLTRB(0, oben, w, h);
    final grund = _anhaengerKarton;
    canvas.save();
    canvas.clipPath(form);
    canvas.drawRect(
      flaeche,
      Paint()
        ..shader = ui.Gradient.linear(
          flaeche.topLeft,
          flaeche.bottomRight,
          [Color.lerp(grund, Colors.white, 0.3)!, grund, Color.lerp(grund, MRoh.manilaDunkel, 0.35)!],
          const [0, 0.55, 1],
        ),
    );
    // Kartonfasern.
    final z = MaterialZufall(samen * 4099 + w.round() * 7 + h.round());
    final faser = Paint()
      ..strokeWidth = 0.7
      ..strokeCap = StrokeCap.round;
    final n = (w * (h - oben) / 240).clamp(20, 900).toInt();
    for (var i = 0; i < n; i++) {
      final p = Offset(z.naechste() * w, oben + z.naechste() * (h - oben));
      final l = z.zwischen(3, 9);
      faser.color = (z.naechste() < 0.5 ? MRoh.manilaDunkel : Colors.white).withValues(alpha: z.zwischen(0.05, 0.14));
      canvas.drawLine(p, p + Offset(l, l * z.zwischen(-0.12, 0.12)), faser);
    }
    // Verstärkungsring um die Öse.
    final oese = Offset(w / 2, oben + 20);
    canvas.drawCircle(oese, 14, Paint()..color = Color.lerp(grund, MRoh.manilaDunkel, 0.3)!);
    canvas.drawCircle(
      oese,
      14,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8
        ..color = MRoh.tinte.withValues(alpha: 0.2),
    );
    // Abgegriffener Rand.
    canvas.drawPath(
      form,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 9
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5)
        ..color = const Color(0x3A8A6A3A),
    );
    canvas.restore();
    // Messingöse mit Loch.
    final ring = Rect.fromCircle(center: oese, radius: 7.5);
    canvas.drawCircle(oese, 7.5, Paint()..shader = messingVerlauf().createShader(ring));
    canvas.drawCircle(
      oese,
      7.5,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.9
        ..color = MRoh.messingDunkel,
    );
    canvas.drawCircle(oese, 3.6, Paint()..color = MRoh.schwarz.withValues(alpha: 0.9));
    // Schnur: zwei Stränge aus dem Loch, die oben aus dem Bild laufen.
    final schnur = [
      Path()
        ..moveTo(oese.dx - 1, oese.dy)
        ..cubicTo(oese.dx - 6, oese.dy - 16, oese.dx - 24, oben - 6, oese.dx - 40, 0),
      Path()
        ..moveTo(oese.dx + 1, oese.dy - 2)
        ..cubicTo(oese.dx + 10, oben - 2, oese.dx - 12, 10, oese.dx - 28, 0),
    ];
    for (final s in schnur) {
      canvas.drawPath(
        s.shift(const Offset(1.5, 2)),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.4
          ..color = Colors.black.withValues(alpha: 0.35)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.4),
      );
      canvas.drawPath(
        s,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.2
          ..strokeCap = StrokeCap.round
          ..color = const Color(0xFFE7DBBE),
      );
      canvas.drawPath(
        s,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.6
          ..color = const Color(0xFF9C8A62),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _AnhaengerMaler alt) => alt.samen != samen;
}

/// Gestrichelte Tintenlinie (Perforation eines Etiketts, Abriss eines Belegs).
class MPerforation extends StatelessWidget {
  const MPerforation({super.key, this.farbe});

  final Color? farbe;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 2,
        child: CustomPaint(painter: _PerforationMaler(farbe ?? MRoh.tinte.withValues(alpha: 0.35))),
      );
}

class _PerforationMaler extends CustomPainter {
  _PerforationMaler(this.farbe);

  final Color farbe;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = farbe
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;
    for (var x = 1.0; x < size.width; x += 7) {
      canvas.drawLine(Offset(x, size.height / 2), Offset(math.min(x + 3.5, size.width), size.height / 2), p);
    }
  }

  @override
  bool shouldRepaint(covariant _PerforationMaler alt) => alt.farbe != farbe;
}

/// Ein gemalter Würfel aus Elfenbein mit [augen] Augen (1–6). Die Eins ist rot.
class MWuerfel extends StatelessWidget {
  const MWuerfel({super.key, required this.augen, this.groesse = 56});

  final int augen;
  final double groesse;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
        child: SizedBox.square(dimension: groesse, child: CustomPaint(painter: _WuerfelMaler(augen.clamp(1, 6)))),
      );
}

class _WuerfelMaler extends CustomPainter {
  _WuerfelMaler(this.augen);

  final int augen;

  /// Lage der Augen im 3 × 3-Raster (Spalte, Zeile).
  static const _lagen = <int, List<(int, int)>>{
    1: [(1, 1)],
    2: [(0, 0), (2, 2)],
    3: [(0, 0), (1, 1), (2, 2)],
    4: [(0, 0), (2, 0), (0, 2), (2, 2)],
    5: [(0, 0), (2, 0), (1, 1), (0, 2), (2, 2)],
    6: [(0, 0), (2, 0), (0, 1), (2, 1), (0, 2), (2, 2)],
  };

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final koerper = RRect.fromRectAndRadius((Offset.zero & size).deflate(1.5), Radius.circular(w * 0.2));
    // Schatten auf dem Brett.
    canvas.drawRRect(
      koerper.shift(Offset(w * 0.03, w * 0.07)),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    // Körper: Elfenbein mit Licht von oben links.
    canvas.drawRRect(
      koerper,
      Paint()
        ..shader = ui.Gradient.linear(
          koerper.outerRect.topLeft,
          koerper.outerRect.bottomRight,
          const [Color(0xFFFFFBF1), Color(0xFFF0E4C8), Color(0xFFC9B58A)],
          const [0, 0.55, 1],
        ),
    );
    // Oberseite leicht eingesetzt: die Kante wirkt gerundet.
    final flaeche = koerper.deflate(w * 0.07);
    canvas.drawRRect(
      flaeche,
      Paint()
        ..shader = ui.Gradient.radial(
          flaeche.center - Offset(w * 0.12, w * 0.12),
          w * 0.62,
          const [Color(0xFFFFFDF7), Color(0xFFF2E8D0)],
        ),
    );
    canvas.drawRRect(
      koerper,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = const Color(0x77745A2E),
    );
    // Augen.
    final eins = augen == 1;
    final r = w * (eins ? 0.13 : 0.085);
    for (final (sp, ze) in _lagen[augen]!) {
      final m = Offset(w * (0.27 + 0.23 * sp), w * (0.27 + 0.23 * ze));
      canvas.drawCircle(m.translate(0, w * 0.012), r, Paint()..color = Colors.white.withValues(alpha: 0.7));
      canvas.drawCircle(
        m,
        r,
        Paint()
          ..shader = ui.Gradient.radial(
            m - Offset(r * 0.3, r * 0.3),
            r,
            eins ? const [Color(0xFFD0404B), MRoh.stempelRot] : const [Color(0xFF4A3D33), MRoh.tinte],
          ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _WuerfelMaler alt) => alt.augen != augen;
}

/// Karteikarte als rollbarer Dialog: Schreibmaschinenzeile, Titel in Playfair,
/// darunter rollender Inhalt und Knöpfe. Anders als `MKarteikartenDialog`
/// darf der Inhalt lang sein (Listen, Notizbuch) und der Titel umbrechen.
class MKarteiFenster extends StatelessWidget {
  const MKarteiFenster({
    super.key,
    required this.titel,
    required this.inhalt,
    this.marke,
    this.aktionen = const [],
    this.art = PapierArt.karteikarte,
    this.neigung = -0.004,
  });

  final String titel;
  final Widget inhalt;

  /// Schreibmaschinenzeile über dem Titel (Formularkopf).
  final String? marke;
  final List<Widget> aktionen;

  /// Karteikarte oder Notizblock.
  final PapierArt art;
  final double neigung;

  @override
  Widget build(BuildContext context) {
    final breite = MediaQuery.sizeOf(context).width;
    return Semantics(
      scopesRoute: true,
      namesRoute: true,
      explicitChildNodes: true,
      label: titel,
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: EdgeInsets.symmetric(horizontal: breite < 400 ? 12 : 40, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: MBlatt(
            art: art,
            kopfLinie: 7,
            linien: false,
            neigung: neigung,
            samen: titel.codeUnits.fold(3, (a, b) => (a * 31 + b) & 0xffff),
            // Auf schmalen Geräten etwas weniger Rand: mehr Zeilenbreite bei großer Schrift.
            padding: EdgeInsets.fromLTRB(breite < 400 ? 16 : 20, 18, breite < 400 ? 16 : 20, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (marke != null) ...[
                  Text(marke!, style: MPapierSchrift.zwischentitel.copyWith(color: MRoh.stempelRot)),
                  const SizedBox(height: 4),
                ],
                MGanzwortText(titel, style: MPapierSchrift.ueberschrift.copyWith(fontSize: 22)),
                const SizedBox(height: 8),
                Container(height: 1, color: MRoh.tinte.withValues(alpha: 0.3)),
                const SizedBox(height: 12),
                Flexible(child: SingleChildScrollView(child: inhalt)),
                if (aktionen.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Wrap(alignment: WrapAlignment.end, spacing: 10, runSpacing: 8, children: aktionen),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Korkbrett mit Holzrahmen; anders als `MKorkwand` bestimmt der Inhalt die
/// Höhe (für Karten, die mit der Schrift wachsen).
class MKorkbrett extends StatelessWidget {
  const MKorkbrett({super.key, required this.child, this.padding = const EdgeInsets.fromLTRB(12, 20, 12, 14)});

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: MRoh.korkDunkel, width: 8),
          boxShadow: const [BoxShadow(color: Color(0x88000000), blurRadius: 16, offset: Offset(0, 8))],
        ),
        child: ClipRect(
          child: Stack(
            children: [
              // Der Kork liegt in einer eigenen Ebene: Stempel auf den Karten malen ihn nicht neu.
              const Positioned.fill(child: RepaintBoundary(child: CustomPaint(painter: KorkMaler()))),
              Padding(padding: padding, child: child),
            ],
          ),
        ),
      );
}

/// Ein Erinnerungsfoto in Sepia: gezackter heller Rand, getöntes Bild mit
/// Vignette, zwei Klebestreifen. Der Inhalt liegt auf Papier (Tinte).
class MErinnerungsfoto extends StatelessWidget {
  const MErinnerungsfoto({super.key, required this.child, this.neigung = 0, this.samen = 13});

  final Widget child;
  final double neigung;
  final int samen;

  @override
  Widget build(BuildContext context) {
    Widget foto = CustomPaint(
      painter: _SepiaMaler(samen: samen),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(30, 30, 30, 30),
        child: MFlaeche.papier(
          child: Builder(
            builder: (context) => DefaultTextStyle.merge(style: MSchrift.von(context).text, child: child),
          ),
        ),
      ),
    );
    foto = Stack(
      clipBehavior: Clip.none,
      children: [
        RepaintBoundary(child: foto),
        const Positioned(top: -6, left: -12, child: MKlebestreifen(breite: 64, winkel: -0.7)),
        const Positioned(top: -6, right: -12, child: MKlebestreifen(breite: 64, winkel: 0.7)),
      ],
    );
    return neigung == 0 ? foto : Transform.rotate(angle: neigung, child: foto);
  }
}

class _SepiaMaler extends CustomPainter {
  _SepiaMaler({required this.samen});

  final int samen;

  static const _rand = 12.0;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final w = size.width;
    final h = size.height;
    // Gezackter Fotorand (Büttenschnitt).
    final zacke = Path();
    const schritt = 7.0;
    zacke.moveTo(0, 0);
    for (var x = 0.0; x < w; x += schritt) {
      zacke.lineTo(math.min(x + schritt / 2, w), 2.2);
      zacke.lineTo(math.min(x + schritt, w), 0);
    }
    for (var y = 0.0; y < h; y += schritt) {
      zacke.lineTo(w - 2.2, math.min(y + schritt / 2, h));
      zacke.lineTo(w, math.min(y + schritt, h));
    }
    for (var x = w; x > 0; x -= schritt) {
      zacke.lineTo(math.max(x - schritt / 2, 0), h - 2.2);
      zacke.lineTo(math.max(x - schritt, 0), h);
    }
    for (var y = h; y > 0; y -= schritt) {
      zacke.lineTo(2.2, math.max(y - schritt / 2, 0));
      zacke.lineTo(0, math.max(y - schritt, 0));
    }
    zacke.close();
    canvas.drawShadow(zacke, Colors.black, 8, false);
    canvas.drawPath(zacke, Paint()..color = const Color(0xFFEFE4CC));
    // Getöntes Bild: Papier, darüber Sepia und Vignette.
    final bild = Rect.fromLTRB(_rand, _rand, w - _rand, h - _rand);
    canvas.save();
    canvas.clipRect(bild);
    canvas.translate(bild.left, bild.top);
    PapierMaler(art: PapierArt.akte, samen: samen).paint(canvas, bild.size);
    canvas.restore();
    canvas.drawRect(bild, Paint()..color = const Color(0x40A4733D));
    canvas.drawRect(
      bild,
      Paint()
        ..shader = ui.Gradient.radial(
          bild.center,
          bild.longestSide * 0.72,
          const [Color(0x00000000), Color(0x00000000), Color(0x5A5A3418)],
          const [0, 0.55, 1],
        ),
    );
    canvas.drawRect(
      bild,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = const Color(0x553A2614),
    );
  }

  @override
  bool shouldRepaint(covariant _SepiaMaler alt) => alt.samen != samen;
}

/// Überschrift, die nie mitten im Wort bricht: Passt ihr längstes Wort nicht
/// in die Breite (schmale Geräte, große Schrift), wird die Schrift so weit
/// kleiner, dass es passt, höchstens bis [minFaktor]. Umbrochen wird nur
/// zwischen Wörtern. Sonst ein gewöhnlicher [Text] mit [style].
class MGanzwortText extends StatelessWidget {
  const MGanzwortText(this.text, {super.key, required this.style, this.textAlign, this.minFaktor = 0.55});

  final String text;
  final TextStyle style;
  final TextAlign? textAlign;

  /// Kleinster Anteil der Schriftgröße, auf den verkleinert wird.
  final double minFaktor;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, box) {
          final stil = DefaultTextStyle.of(context).style.merge(style);
          final groesse = stil.fontSize ?? 14;
          var faktor = 1.0;
          if (box.hasBoundedWidth && box.maxWidth > 0) {
            final scaler = MediaQuery.textScalerOf(context);
            final richtung = Directionality.of(context);
            var breitestes = 0.0;
            for (final wort in text.split(RegExp(r'\s+'))) {
              if (wort.isEmpty) continue;
              final tp = TextPainter(text: TextSpan(text: wort, style: stil), textDirection: richtung, textScaler: scaler, maxLines: 1)..layout();
              breitestes = math.max(breitestes, tp.width);
              tp.dispose();
            }
            // Ein Hauch Luft, damit Rundungen beim Umbruch das Wort nicht doch teilen.
            if (breitestes > box.maxWidth) faktor = math.max(minFaktor, box.maxWidth / breitestes * 0.97);
          }
          return Text(text, textAlign: textAlign, style: faktor == 1 ? style : style.copyWith(fontSize: groesse * faktor));
        },
      );
}

/// Bild und Text nebeneinander (Fotoabzug und Name, Symbol und Ort); wird es
/// schmal oder die Schrift groß, steht der Text unter dem Bild, damit lange
/// Namen nicht mitten im Wort brechen.
class MBildZeile extends StatelessWidget {
  const MBildZeile({super.key, required this.bild, required this.text, this.abstand = 16, this.oben = false});

  final Widget bild;
  final Widget text;
  final double abstand;

  /// Nebeneinander oben bündig statt mittig.
  final bool oben;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, box) {
          final eng = box.maxWidth < 260 || MediaQuery.textScalerOf(context).scale(10) > 15;
          if (eng) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [bild, SizedBox(height: abstand * 0.75), text],
            );
          }
          return Row(
            crossAxisAlignment: oben ? CrossAxisAlignment.start : CrossAxisAlignment.center,
            children: [bild, SizedBox(width: abstand), Expanded(child: text)],
          );
        },
      );
}

/// Rote Bleistiftschlinge um ein Foto (markierte Person): zwei Bögen, die sich
/// nicht ganz schließen, wie von Hand gezogen.
class MKringel extends StatelessWidget {
  const MKringel({super.key, this.farbe = MRoh.stempelRot});

  final Color farbe;

  @override
  Widget build(BuildContext context) => IgnorePointer(child: ExcludeSemantics(child: CustomPaint(painter: _KringelMaler(farbe))));
}

class _KringelMaler extends CustomPainter {
  _KringelMaler(this.farbe);

  final Color farbe;

  @override
  void paint(Canvas canvas, Size size) {
    final m = size.center(Offset.zero);
    final rx = size.width / 2;
    final ry = size.height / 2;
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.6
      ..strokeCap = StrokeCap.round
      ..color = farbe.withValues(alpha: 0.85);
    final schlinge = Path();
    const schritte = 48;
    for (var i = 0; i <= schritte; i++) {
      // Etwas mehr als eine Runde, mit leicht wachsendem Radius.
      final t = i / schritte * 1.12;
      final w = -math.pi * 0.6 + t * math.pi * 2;
      final s = 1 + 0.05 * t;
      final pt = m + Offset(math.cos(w) * rx * s, math.sin(w) * ry * s * 0.96);
      i == 0 ? schlinge.moveTo(pt.dx, pt.dy) : schlinge.lineTo(pt.dx, pt.dy);
    }
    canvas.drawPath(schlinge, p);
  }

  @override
  bool shouldRepaint(covariant _KringelMaler alt) => alt.farbe != farbe;
}

/// Kartenablage auf Papier: ein dunkler Deckel, auf dem die Hand liegt. Die
/// Karten und ihre Zeilen bleiben so hell auf dunklem Grund lesbar.
class MKartenablage extends StatelessWidget {
  const MKartenablage({super.key, required this.child, this.padding = const EdgeInsets.all(10)});

  final Widget child;
  final EdgeInsets padding;

  /// Die Ablage ist so breit wie ihr Platz; in einem `Center` umschließt sie die Hand.
  @override
  Widget build(BuildContext context) => MFlaeche.dunkel(
        child: MTafel(padding: padding, child: child),
      );
}
