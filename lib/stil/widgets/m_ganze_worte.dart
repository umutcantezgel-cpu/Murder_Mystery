import 'dart:math' as math;

import 'package:flutter/material.dart';

// Ganze Worte (gemeinsam für alle Bildschirme): Bei schmalem Platz und großer
// Schrift wird ein Titel kleiner, statt ein Wort mitten durch zu brechen.

/// Schriftgröße, bei der das längste Wort von [text] noch in eine Zeile der
/// Breite [breite] passt (mit der Schriftskalierung des Geräts), höchstens die
/// Größe von [stil], mindestens [minimum]. So bricht kein Wort mitten durch.
///
/// Gemessen wird mit dem geerbten Textstil ([DefaultTextStyle]), denn ein
/// geerbter Zeichenabstand macht ein Wort breiter. Nach einem Bindestrich darf
/// die Zeile umbrechen; dort endet ein Wort.
double ganzeWorteGroesse(BuildContext context, String text, TextStyle stil, double breite, {double minimum = 13}) {
  final wirk = DefaultTextStyle.of(context).style.merge(stil);
  final groesse = wirk.fontSize ?? 30;
  if (!breite.isFinite || breite <= 0) return groesse;
  final skala = MediaQuery.textScalerOf(context);
  final worte = text.split(RegExp(r'\s+|(?<=[-–])')).where((w) => w.isNotEmpty).toList();
  double laengstes(double g) {
    var breitestes = 0.0;
    for (final wort in worte) {
      final tp = TextPainter(
        text: TextSpan(text: wort, style: wirk.copyWith(fontSize: g)),
        textDirection: TextDirection.ltr,
        textScaler: skala,
        maxLines: 1,
      )..layout();
      if (tp.width > breitestes) breitestes = tp.width;
      tp.dispose();
    }
    return breitestes;
  }

  final untergrenze = math.min(minimum, groesse);
  var g = groesse;
  // Ein geerbter Zeichenabstand wächst nicht mit der Schrift; darum höchstens
  // dreimal nachmessen, bis das längste Wort mit etwas Luft hineinpasst.
  for (var i = 0; i < 3; i++) {
    final w = laengstes(g);
    if (w == 0 || w <= breite * 0.98) return g;
    g = (g * breite / w * 0.97).clamp(untergrenze, groesse);
    if (g == untergrenze) return g;
  }
  return g;
}

/// Text, dessen Wörter nie mitten durchbrechen: Reicht die Breite für das
/// längste Wort nicht, wird die Schrift so weit kleiner, dass es ganz in eine
/// Zeile passt (siehe [ganzeWorteGroesse]). Sonst gilt [stil] unverändert.
class MGanzeWorte extends StatelessWidget {
  const MGanzeWorte(this.text, {super.key, required this.stil, this.minimum = 13, this.textAlign});

  final String text;
  final TextStyle stil;

  /// Kleinste Schriftgröße (vor der Skalierung des Geräts).
  final double minimum;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, box) {
          final g = ganzeWorteGroesse(context, text, stil, box.maxWidth, minimum: minimum);
          return Text(text, style: g == stil.fontSize ? stil : stil.copyWith(fontSize: g), textAlign: textAlign);
        },
      );
}

