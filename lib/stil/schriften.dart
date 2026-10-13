import 'package:flutter/painting.dart';

/// Die Schriftfamilien der Ermittlungsmappe. Nur hier stehen Schriftnamen.
///
/// - **Playfair** (Playfair Display, OFL): Titel, Schlagzeilen und Messingschilder.
/// - **Lora** (OFL): Lesetext mit echter Kursive.
/// - **SpecialElite** (Apache 2.0): Schreibmaschine, die Identität von Mordakte.
/// - **CourierPrime** (OFL): klare Schreibmaschine für Telegramme und „Klare Schrift“.
/// - **Caveat** (OFL): Handschrift für Randnotizen des Detektivs.
/// - **Inter** (OFL): kleine funktionale Texte.
///
/// Playfair, Lora und Caveat sind variable Schriften. Jede Rolle setzt deshalb
/// das Gewicht doppelt: als [FontWeight] und als Achse `wght`.
abstract final class MSchriftFamilie {
  static const titel = 'Playfair';
  static const lesen = 'Lora';
  static const maschine = 'SpecialElite';
  static const telegramm = 'CourierPrime';
  static const hand = 'Caveat';
  static const ui = 'Inter';
}

/// Ein Stil mit Gewicht als [FontWeight] und als variable Achse.
TextStyle mStil(
  String familie, {
  required double groesse,
  double? zeile,
  int gewicht = 400,
  double laufweite = 0,
  bool kursiv = false,
  Color? farbe,
}) =>
    TextStyle(
      fontFamily: familie,
      fontSize: groesse,
      height: zeile == null ? null : zeile / groesse,
      fontWeight: FontWeight.values[((gewicht ~/ 100) - 1).clamp(0, 8)],
      fontVariations: familie == MSchriftFamilie.titel || familie == MSchriftFamilie.lesen || familie == MSchriftFamilie.hand
          ? [FontVariation('wght', gewicht.toDouble())]
          : null,
      letterSpacing: laufweite,
      fontStyle: kursiv ? FontStyle.italic : FontStyle.normal,
      color: farbe,
    );
