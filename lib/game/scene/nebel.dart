import 'dart:ui';

import 'palette.dart';

/// Grundton des Schleiers über unbekannten Räumen: ein sehr dunkles Violett,
/// kein reines Schwarz (die Räume bleiben ahnbar).
const nebelGrund = Color(0xFF0B0A12);

/// Deckkraft des Schleiers über einem Raum.
///
/// [sicht] ist die Sichtbarkeit (0 verborgen … 1 sichtbar). Ein noch nie
/// betretener Raum verschwindet höchstens zu 62 %, ein schon bekannter
/// (`erinnert`) nur zu 38 %. Nie undurchsichtig: die Obergrenze ist 0,65.
double nebelDeckkraft(double sicht, {required bool erinnert}) =>
    (1 - sicht.clamp(0.0, 1.0)) * (erinnert ? .38 : .62);

/// Farbe des Schleiers: Nebelfarbe der Szene, zu 60 % in Richtung [nebelGrund].
Color nebelSchleier(ScenePalette pal) => mix(pal.fog, nebelGrund, .6);

/// Schleierfarbe samt Deckkraft für eine bestimmte Sicht.
Color nebelFarbe(ScenePalette pal, double sicht, {required bool erinnert}) =>
    nebelSchleier(pal).withValues(alpha: nebelDeckkraft(sicht, erinnert: erinnert));
