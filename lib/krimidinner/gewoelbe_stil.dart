import 'package:flutter/material.dart';

import '../party/party_stil.dart';
import '../stil/tokens.dart';

/// Farben aus der Look-Bibel K9 des Krimidinners „Spuk im Gewölbe“.
///
/// Grundlage bleibt der Kellerstil der Partyabende ([Keller], [PartyTafel],
/// [PartyKnopf]) und damit das Designsystem `lib/stil/`; die K9-Farben setzen
/// nur Akzente (Bernstein und Spukcyan sind dieselben Token-Werte).
abstract final class K9 {
  static const bruchstein = Color(0xFF6B6660);
  static const eisenschwarz = Color(0xFF22201E);
  static const kerzenbernstein = MRoh.akzent;
  static const glutorange = Color(0xFFC8642B);
  static const punschbraun = Color(0xFF9C4A23);
  static const nachtblau = Color(0xFF1E2A3A);
  static const moosgruen = Color(0xFF4A5A3C);
  static const pergament = Color(0xFFE9DCC0);
  static const spukcyan = MRoh.geist;

  /// Alle Rollen tragen denselben Akzent: keine Farbe verrät eine Rolle.
  static const akzent = kerzenbernstein;

  /// Leicht nachtblauer Kellergrund.
  static const grund = RadialGradient(
    center: Alignment(0, -0.7),
    radius: 1.35,
    colors: [Color(0xFF1C2230), Keller.nacht],
  );

  /// Fußleiste und Navigationsleiste.
  static const leiste = Color(0xF00B0A0E);
}

/// Texte auf Papierweiß (Druckvorschau).
abstract final class Papier {
  static const grund = Color(0xFFFFFFFF);
  static const tinte = K9.eisenschwarz;
  static const tinteLeise = K9.bruchstein;
  static const linie = Color(0x336B6660);

  static const titel = TextStyle(fontFamily: Keller.schreibmaschine, fontSize: 19, height: 1.25, color: tinte);
  static const text = TextStyle(fontFamily: Keller.schrift, fontSize: 14.5, height: 1.45, color: tinte);
  static const leise = TextStyle(fontFamily: Keller.schrift, fontSize: 12.5, height: 1.4, color: tinteLeise);
  static const marke = TextStyle(
    fontFamily: Keller.schrift,
    fontSize: 11,
    height: 1.3,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.1,
    color: K9.punschbraun,
  );
}

/// Rundes Namensschild: Initiale in Spukcyan auf Nachtblau.
class NamensSchild extends StatelessWidget {
  const NamensSchild({super.key, this.initiale, this.icon, this.groesse = 44});

  final String? initiale;
  final IconData? icon;
  final double groesse;

  @override
  Widget build(BuildContext context) => Container(
        width: groesse,
        height: groesse,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: K9.nachtblau,
          shape: BoxShape.circle,
          border: Border.all(color: K9.spukcyan.withValues(alpha: 0.55), width: 1.5),
          boxShadow: const [BoxShadow(color: Color(0x55A9D6D9), blurRadius: 10)],
        ),
        child: initiale != null
            ? Text(
                initiale!,
                style: TextStyle(
                  fontFamily: Keller.schreibmaschine,
                  fontSize: groesse * 0.46,
                  height: 1,
                  color: K9.spukcyan,
                ),
              )
            : Icon(icon ?? Icons.person_rounded, size: groesse * 0.5, color: K9.spukcyan),
      );
}

/// Hinweistafel mit Symbol (etwa „Den geführten Abend gibt es hier noch nicht“).
class GewoelbeHinweis extends StatelessWidget {
  const GewoelbeHinweis({super.key, required this.text, this.icon = Icons.info_outline_rounded, this.akzent = K9.akzent});

  final String text;
  final IconData icon;
  final Color akzent;

  @override
  Widget build(BuildContext context) => PartyTafel(
        akzent: akzent,
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: akzent, size: 22),
            const SizedBox(width: 12),
            Expanded(child: Text(text, style: Keller.text)),
          ],
        ),
      );
}
