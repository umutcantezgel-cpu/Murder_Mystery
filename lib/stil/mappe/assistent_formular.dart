import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../tokens.dart';
import 'material.dart';

/// Bausteine für Formulare auf Papier: Ankreuzfelder, Formularzeilen, ein
/// Regler mit Messingknauf, Registerreiter für Schritte und eine Messingskala.
/// Sie gehören zur Ermittlungsmappe (siehe `lib/stil/stil.dart`), werden aber
/// direkt importiert.

/// Eine Wahl auf einem Formular: „Zutreffendes ankreuzen“. Jede Möglichkeit ist
/// ein Kästchen mit Schreibmaschinentext; die gewählte trägt ein Tintenkreuz.
///
/// Für den Bildschirmleser ist jede Möglichkeit ein Knopf mit ihrem Text, der
/// gewählte ist ausgewählt (wie die Segmente eines Auswahlknopfs).
class MAnkreuzWahl<T> extends StatelessWidget {
  const MAnkreuzWahl({super.key, required this.optionen, required this.gewaehlt, required this.onWahl});

  /// Werte und Beschriftungen in Lesereihenfolge.
  final List<(T, String)> optionen;
  final T gewaehlt;
  final ValueChanged<T> onWahl;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: MMass.s20,
    runSpacing: 0,
    children: [for (final (wert, text) in optionen) MAnkreuzFeld(text: text, gewaehlt: wert == gewaehlt, onTap: () => onWahl(wert))],
  );
}

/// Ein einzelnes Ankreuzfeld (siehe [MAnkreuzWahl]).
class MAnkreuzFeld extends StatelessWidget {
  const MAnkreuzFeld({super.key, required this.text, required this.gewaehlt, required this.onTap});

  final String text;
  final bool gewaehlt;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final papier = MFlaeche.hellVon(context);
    final schrift = papier ? MPapierSchrift.maschine : MRohSchrift.schreibmaschine;
    return Semantics(
      button: true,
      selected: gewaehlt,
      inMutuallyExclusiveGroup: true,
      enabled: onTap != null,
      label: text,
      onTap: onTap,
      excludeSemantics: true,
      // Eigene durchsichtige Fläche: der Druckschatten liegt auf dem Papier, nicht unter ihm.
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          splashFactory: NoSplash.splashFactory,
          highlightColor: (papier ? MRoh.tinte : MRoh.papier).withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(3),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: MMass.tippflaeche),
            child: Padding(
              padding: const EdgeInsets.only(right: MMass.s4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  MKaestchen(gewaehlt: gewaehlt, samen: text.codeUnits.fold(3, (a, b) => (a * 31 + b) & 0xffff)),
                  const SizedBox(width: 10),
                  Flexible(child: Text(text, style: schrift)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Formularkopf auf Papier in roter Schreibmaschine (z. B. „PERSONEN AM TISCH“).
///
/// Der Text erscheint unverändert (Versalien setzt der Aufrufer). Lange Wörter
/// brechen nicht mitten im Wort (siehe [MWortfest]).
class MFormkopf extends StatelessWidget {
  const MFormkopf(this.text, {super.key, this.textAlign = TextAlign.start});

  final String text;
  final TextAlign textAlign;

  static final _stil = MPapierSchrift.zwischentitel.copyWith(color: MRoh.stempelRot, letterSpacing: 1.1);

  @override
  Widget build(BuildContext context) => MWortfest(text, style: _stil, textAlign: textAlign);
}

/// Ein Text, der nie mitten im Wort bricht: Mehrere Wörter umbrechen wie
/// gewohnt; ist ein einzelnes Wort breiter als die Zeile (schmaler Bildschirm,
/// große Schrift, lange deutsche Wörter wie „Grundschullehrerin“), wird der
/// ganze Text so weit kleiner gesetzt, dass dieses Wort passt.
class MWortfest extends StatelessWidget {
  const MWortfest(this.text, {super.key, required this.style, this.textAlign = TextAlign.start});

  final String text;
  final TextStyle style;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, box) {
      var stil = style;
      final groesse = style.fontSize;
      if (groesse != null && box.maxWidth.isFinite && box.maxWidth > 0) {
        final scaler = MediaQuery.textScalerOf(context);
        final richtung = Directionality.of(context);
        var breitestes = 0.0;
        for (final wort in text.split(RegExp(r'\s+'))) {
          if (wort.isEmpty) continue;
          final tp = TextPainter(text: TextSpan(text: wort, style: style), textDirection: richtung, textScaler: scaler, maxLines: 1)..layout();
          breitestes = math.max(breitestes, tp.width);
          tp.dispose();
        }
        if (breitestes > box.maxWidth) {
          // Etwas Luft, damit Rundungen der Schriftbreite das Wort nicht doch umbrechen.
          final faktor = box.maxWidth / breitestes * 0.97;
          final abstand = style.letterSpacing;
          stil = style.copyWith(fontSize: groesse * faktor, letterSpacing: abstand == null ? null : abstand * faktor);
        }
      }
      return Text(text, textAlign: textAlign, style: stil);
    },
  );
}

/// Ein gedrucktes Kästchen; [gewaehlt] trägt ein Kreuz in Füllertinte.
class MKaestchen extends StatelessWidget {
  const MKaestchen({super.key, required this.gewaehlt, this.groesse = 22, this.samen = 1});

  final bool gewaehlt;
  final double groesse;

  /// Samen der Handbewegung (leicht unterschiedliche Kreuze).
  final int samen;

  @override
  Widget build(BuildContext context) {
    final papier = MFlaeche.hellVon(context);
    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: groesse,
        child: CustomPaint(
          painter: _KreuzMaler(
            gewaehlt: gewaehlt,
            rahmen: papier ? MRoh.tinte.withValues(alpha: 0.72) : MRoh.papierLeise,
            tinte: papier ? MRoh.tinteBlau : MRoh.akzentHell,
            samen: samen,
          ),
        ),
      ),
    );
  }
}

class _KreuzMaler extends CustomPainter {
  _KreuzMaler({required this.gewaehlt, required this.rahmen, required this.tinte, required this.samen});

  final bool gewaehlt;
  final Color rahmen;
  final Color tinte;
  final int samen;

  @override
  void paint(Canvas canvas, Size size) {
    final r = Offset.zero & size;
    canvas.drawRect(
      r.deflate(1),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = rahmen,
    );
    if (!gewaehlt) return;
    final z = MaterialZufall(samen);
    final w = size.width;
    final h = size.height;
    final strich = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.6
      ..strokeCap = StrokeCap.round
      ..color = tinte;
    // Zwei schnelle Federstriche, die ein wenig über das Kästchen hinausgehen.
    final a = Path()
      ..moveTo(w * z.zwischen(0.0, 0.12), h * z.zwischen(0.02, 0.14))
      ..quadraticBezierTo(w * 0.52, h * z.zwischen(0.42, 0.56), w * z.zwischen(0.98, 1.12), h * z.zwischen(0.95, 1.08));
    final b = Path()
      ..moveTo(w * z.zwischen(0.92, 1.1), h * z.zwischen(-0.12, 0.04))
      ..quadraticBezierTo(w * z.zwischen(0.45, 0.6), h * 0.5, w * z.zwischen(-0.06, 0.08), h * z.zwischen(0.9, 1.0));
    canvas.drawPath(a, strich);
    canvas.drawPath(b, strich..strokeWidth = 2.2);
  }

  @override
  bool shouldRepaint(covariant _KreuzMaler alt) => alt.gewaehlt != gewaehlt || alt.rahmen != rahmen || alt.tinte != tinte || alt.samen != samen;
}

/// Eingabefeld als Formularzeile auf Papier: ein heller Hauch mit Tintenlinie
/// darunter, im Fokus eine Linie in Füllertinte.
InputDecoration mPapierFeld(String platzhalter) {
  UnderlineInputBorder linie(Color farbe, double breite) => UnderlineInputBorder(
    borderSide: BorderSide(color: farbe, width: breite),
    borderRadius: BorderRadius.zero,
  );
  return InputDecoration(
    hintText: platzhalter,
    hintStyle: MPapierSchrift.leise.copyWith(fontSize: 15),
    isDense: true,
    filled: true,
    fillColor: MRoh.tinte.withValues(alpha: 0.04),
    contentPadding: const EdgeInsets.fromLTRB(10, 12, 10, 9),
    border: linie(MRoh.tinte.withValues(alpha: 0.55), 1.2),
    enabledBorder: linie(MRoh.tinte.withValues(alpha: 0.55), 1.2),
    disabledBorder: linie(MRoh.tinte.withValues(alpha: 0.25), 1),
    focusedBorder: linie(MRoh.tinteBlau, 2),
    errorBorder: linie(MRoh.stempelRot, 1.4),
    focusedErrorBorder: linie(MRoh.stempelRot, 2),
  );
}

/// Ein Regler auf Papier: Tintenspur, Teilstriche und ein Knauf aus Messing.
class MPapierRegler extends StatelessWidget {
  const MPapierRegler({super.key, required this.child});

  /// Der [Slider] (ohne eigene Farben).
  final Widget child;

  @override
  Widget build(BuildContext context) => SliderTheme(
    data: SliderTheme.of(context).copyWith(
      trackHeight: 3,
      activeTrackColor: MRoh.tinteBlau,
      inactiveTrackColor: MRoh.tinte.withValues(alpha: 0.2),
      activeTickMarkColor: MRoh.blatt.withValues(alpha: 0.7),
      inactiveTickMarkColor: MRoh.tinte.withValues(alpha: 0.4),
      tickMarkShape: const RoundSliderTickMarkShape(tickMarkRadius: 1.4),
      thumbShape: const MMessingKnauf(),
      overlayColor: MRoh.messingMitte.withValues(alpha: 0.2),
      overlayShape: const RoundSliderOverlayShape(overlayRadius: 22),
    ),
    child: child,
  );
}

/// Reglerknauf aus gebürstetem Messing mit Schraubschlitz.
class MMessingKnauf extends SliderComponentShape {
  const MMessingKnauf({this.radius = 11});

  final double radius;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => Size.fromRadius(radius);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final canvas = context.canvas;
    final r = radius * (1 + 0.08 * activationAnimation.value);
    canvas.drawCircle(
      center.translate(0.8, 2),
      r,
      Paint()
        ..color = const Color(0x66000000)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5),
    );
    canvas.drawCircle(
      center,
      r,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.35, -0.45),
          colors: [MRoh.messingHell, MRoh.messingMitte, MRoh.messingDunkel],
          stops: [0, 0.55, 1],
        ).createShader(Rect.fromCircle(center: center, radius: r)),
    );
    canvas.drawCircle(
      center,
      r - 0.6,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.1
        ..color = MRoh.messingDunkel,
    );
    // Schraubschlitz, leicht schräg.
    final schlitz = Offset(math.cos(-0.6), math.sin(-0.6)) * (r * 0.5);
    canvas.drawLine(
      center - schlitz,
      center + schlitz,
      Paint()
        ..strokeWidth = 1.8
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xFF4A3208),
    );
    canvas.drawLine(
      center - schlitz + const Offset(0.5, 0.9),
      center + schlitz + const Offset(0.5, 0.9),
      Paint()
        ..strokeWidth = 0.7
        ..color = const Color(0x66FFF0C4),
    );
  }
}

/// Registerreiter über einer Mappe als Schrittanzeige: erledigte Reiter tragen
/// einen Tintenhaken, der aktuelle steht hell und hoch mit Nummer und Namen,
/// kommende zeigen nur ihre Nummer. Darunter liegt die Oberkante der Mappe.
///
/// Für den Bildschirmleser ist die ganze Leiste eine Zeile [semantik].
class MRegisterSchritte extends StatelessWidget {
  const MRegisterSchritte({super.key, required this.namen, required this.aktuell, this.semantik, this.farbe});

  final List<String> namen;
  final int aktuell;
  final String? semantik;

  /// Farbe der Kante des aktuellen Reiters (ohne Angabe: Akzent).
  final Color? farbe;

  @override
  Widget build(BuildContext context) {
    final akzent = farbe ?? MFarben.von(context).akzent;
    final dauer = MBewegung.normal(context);
    final hell = Color.lerp(MRoh.manila, Colors.white, 0.12)!;
    final reiter = <Widget>[
      for (var i = 0; i < namen.length; i++)
        Padding(
          padding: const EdgeInsets.only(right: 3),
          child: _Reiter(
            aktuell: i == aktuell,
            erledigt: i < aktuell,
            farbe: i == aktuell ? hell : (i < aktuell ? MRoh.manila : Color.lerp(MRoh.manila, MRoh.manilaDunkel, 0.55)!),
            kante: akzent,
            dauer: dauer,
            text: i == aktuell ? '${i + 1}  ${namen[i]}' : '${i + 1}',
          ),
        ),
    ];
    // Die Reiter sind Zierde mit Nummern; ihre Schrift wächst nur begrenzt mit,
    // die volle Angabe steht in der Marke über dem Titel und in [semantik].
    return Semantics(
      container: true,
      label: semantik,
      excludeSemantics: true,
      child: MediaQuery.withClampedTextScaling(
        maxScaleFactor: 1.4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: MMass.s12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [for (var i = 0; i < reiter.length; i++) i == aktuell ? Flexible(child: reiter[i]) : reiter[i]],
              ),
            ),
            // Oberkante der Mappe, in der Farbe des aktuellen Reiters.
            DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(3)),
                gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [hell, MRoh.manila]),
                boxShadow: const [BoxShadow(color: Color(0x88000000), blurRadius: 6, offset: Offset(0, 3))],
              ),
              child: const SizedBox(height: 7),
            ),
          ],
        ),
      ),
    );
  }
}

class _Reiter extends StatelessWidget {
  const _Reiter({required this.aktuell, required this.erledigt, required this.farbe, required this.kante, required this.dauer, required this.text});

  final bool aktuell;
  final bool erledigt;
  final Color farbe;
  final Color kante;
  final Duration dauer;
  final String text;

  @override
  Widget build(BuildContext context) {
    final stil = MRohSchrift.schreibmaschine.copyWith(fontSize: 14, height: 1.2, color: aktuell ? MRoh.tinte : MRoh.tinteLeise);
    final Widget inhalt = erledigt
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_rounded, size: 16, color: MRoh.tinteBlau),
              const SizedBox(width: 2),
              Text(text, style: stil),
            ],
          )
        : FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(text, maxLines: 1, style: stil),
          );
    return AnimatedContainer(
      duration: dauer,
      curve: Curves.easeOutCubic,
      constraints: BoxConstraints(minHeight: aktuell ? 36 : 30, minWidth: 34),
      child: CustomPaint(
        painter: _ReiterForm(farbe: farbe, kante: aktuell ? kante : null),
        child: Padding(padding: EdgeInsets.fromLTRB(13, aktuell ? 10 : 7, 13, 5), child: inhalt),
      ),
    );
  }
}

/// Trapezförmiger Reiter mit gerundeten Ecken, Verlauf und Schatten.
class _ReiterForm extends CustomPainter {
  _ReiterForm({required this.farbe, this.kante});

  final Color farbe;

  /// Farbige Oberkante (nur der aktuelle Reiter).
  final Color? kante;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Path()
      ..moveTo(0, size.height)
      ..lineTo(5, 3)
      ..quadraticBezierTo(6.5, 0, 10, 0)
      ..lineTo(size.width - 10, 0)
      ..quadraticBezierTo(size.width - 6.5, 0, size.width - 5, 3)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawShadow(p, Colors.black, 2, false);
    canvas.drawPath(
      p,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color.lerp(farbe, Colors.white, 0.18)!, farbe],
        ).createShader(Offset.zero & size),
    );
    final k = kante;
    if (k != null) {
      canvas.save();
      canvas.clipPath(p);
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, 3), Paint()..color = k);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ReiterForm alt) => alt.farbe != farbe || alt.kante != kante;
}

/// Messingskala: ein Röhrchen in einer gebürsteten Messingfassung, das sich bis
/// [wert] (0–1) füllt, mit Teilstrichen und Glanz. Rein gemalt; die
/// Beschriftung für den Bildschirmleser setzt der Bildschirm.
class MMessingSkala extends StatelessWidget {
  const MMessingSkala({super.key, required this.wert, this.hoehe = 22, this.fuellung = MRoh.akzent, this.teile = 10});

  final double wert;
  final double hoehe;

  /// Farbe der Füllung (ohne Angabe: Kerzenmessing).
  final Color fuellung;

  /// Anzahl der Abschnitte zwischen den Teilstrichen.
  final int teile;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: SizedBox(
      height: hoehe,
      width: double.infinity,
      child: CustomPaint(
        painter: _SkalaMaler(wert: wert.clamp(0.0, 1.0), fuellung: fuellung, teile: teile),
      ),
    ),
  );
}

class _SkalaMaler extends CustomPainter {
  _SkalaMaler({required this.wert, required this.fuellung, required this.teile});

  final double wert;
  final Color fuellung;
  final int teile;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final aussen = RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(size.height / 2));
    canvas.drawRRect(
      aussen.shift(const Offset(0, 2)),
      Paint()
        ..color = const Color(0x55000000)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
    canvas.drawRRect(aussen, Paint()..shader = messingVerlauf().createShader(Offset.zero & size));
    canvas.drawRRect(
      aussen.deflate(0.6),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = MRoh.messingDunkel,
    );
    // Nieten an beiden Enden.
    final rand = size.height * 0.42;
    for (final x in [rand, size.width - rand]) {
      final m = Offset(x, size.height / 2);
      canvas.drawCircle(
        m,
        2.2,
        Paint()
          ..shader = const RadialGradient(
            center: Alignment(-0.4, -0.4),
            colors: [Color(0xFFFFF0C4), Color(0xFF6E4A10)],
          ).createShader(Rect.fromCircle(center: m, radius: 2.4)),
      );
    }
    // Das Röhrchen.
    final links = size.height * 0.85;
    final innen = RRect.fromLTRBR(links, 4, size.width - links, size.height - 4, Radius.circular((size.height - 8) / 2));
    canvas.drawRRect(
      innen,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF120C08), Color(0xFF2B1D12)],
        ).createShader(innen.outerRect),
    );
    final breite = innen.width * wert;
    if (breite > 0.5) {
      canvas.save();
      canvas.clipRRect(innen);
      final voll = Rect.fromLTWH(innen.left, innen.top, breite, innen.height);
      canvas.drawRect(
        voll,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color.lerp(fuellung, Colors.white, 0.45)!, fuellung, Color.lerp(fuellung, Colors.black, 0.35)!],
            stops: const [0, 0.45, 1],
          ).createShader(voll),
      );
      canvas.restore();
    }
    // Teilstriche und Glanz über dem Glas.
    final strich = Paint()
      ..strokeWidth = 1
      ..color = Colors.black.withValues(alpha: 0.35);
    for (var i = 1; i < teile; i++) {
      final x = innen.left + innen.width * i / teile;
      final lang = i * 2 == teile;
      canvas.drawLine(Offset(x, innen.top + (lang ? 1 : innen.height * 0.45)), Offset(x, innen.bottom), strich);
    }
    canvas.save();
    canvas.clipRRect(innen);
    canvas.drawRect(
      Rect.fromLTWH(innen.left, innen.top, innen.width, innen.height * 0.45),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white.withValues(alpha: 0.28), Colors.white.withValues(alpha: 0)],
        ).createShader(innen.outerRect),
    );
    canvas.restore();
    canvas.drawRRect(
      innen,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = MRoh.messingDunkel.withValues(alpha: 0.9),
    );
  }

  @override
  bool shouldRepaint(covariant _SkalaMaler alt) => alt.wert != wert || alt.fuellung != fuellung || alt.teile != teile;
}
