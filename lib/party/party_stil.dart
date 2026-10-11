import 'package:flutter/material.dart';

import '../stil/stil.dart';

export '../stil/widgets/roll_flaeche.dart' show RollFlaeche;

/// Schreibweisen des Partymodus (Gewölbekeller bei Nacht, warmes Kerzenlicht).
///
/// Die Werte kommen aus dem Designsystem `lib/stil/` ([MRoh], [MRohSchrift]);
/// diese Namen bleiben, damit die Party-Bildschirme nicht umgeschrieben
/// werden müssen. Neue Bildschirme verwenden [MFarben], [MSchrift] und
/// [MKnopf] direkt.
abstract final class Keller {
  static const nacht = MRoh.grund;
  static const nacht2 = MRoh.grund2;
  static const stein = MRoh.flaeche;
  static const steinHell = MRoh.flaecheHoch;
  static const linie = MRoh.linie;
  static const linieStark = MRoh.linieStark;
  static const kerze = MRoh.akzent;
  static const kerzeHell = MRoh.akzentHell;
  static const kerzeSchwach = MRoh.akzentSchwach;
  static const papier = MRoh.papier;
  static const papierGedaempft = MRoh.papierLeise;
  static const blaugrau = Color(0xFF6E7F92);
  static const gefahr = MRoh.gefahr;
  static const notlicht = Color(0xFF2FBF5A);

  static const schreibmaschine = MRohSchrift.anzeige;
  static const schrift = MRohSchrift.text;

  static const titel = MRohSchrift.titel;
  static const ueberschrift = MRohSchrift.ueberschrift;
  static const text = MRohSchrift.fliesstext;
  static const leise = MRohSchrift.leise;
  static const marke = MRohSchrift.marke;

  /// Erzählertext: groß und ruhig lesbar, auch für Vorlesende.
  static const erzaehler = MRohSchrift.erzaehler;

  /// Maximale Inhaltsbreite auf großen Bildschirmen.
  static const breite = MMass.breite;
}

/// Seitenrahmen: Hintergrund, Kopf (Marke, Titel, Untertitel), Inhalt, Fuß mit
/// Aktionen. Dünner Mantel um [MRahmen].
class PartyRahmen extends StatelessWidget {
  const PartyRahmen({
    super.key,
    required this.child,
    this.marke,
    this.titel,
    this.untertitel,
    this.aktionen = const [],
    this.scroll = true,
  });

  final Widget child;
  final String? marke;
  final String? titel;
  final String? untertitel;
  final List<Widget> aktionen;
  final bool scroll;

  @override
  Widget build(BuildContext context) => MRahmen(
        marke: marke,
        titel: titel,
        untertitel: untertitel,
        aktionen: aktionen,
        scroll: scroll,
        child: child,
      );
}

/// Knopf im Kellerstil. [haupt] ist der warme Hauptknopf, sonst ein ruhiger
/// Rahmenknopf. Dünner Mantel um [MKnopf].
class PartyKnopf extends StatelessWidget {
  const PartyKnopf({super.key, required this.text, required this.onPressed, this.haupt = true, this.icon});

  final String text;
  final VoidCallback? onPressed;
  final bool haupt;
  final IconData? icon;

  @override
  Widget build(BuildContext context) =>
      MKnopf(text: text, onPressed: onPressed, art: haupt ? MKnopfArt.haupt : MKnopfArt.zweit, icon: icon);
}

/// Tafel: Fläche für zusammengehörige Inhalte. Dünner Mantel um [MTafel].
class PartyTafel extends StatelessWidget {
  const PartyTafel({super.key, required this.child, this.padding = const EdgeInsets.all(18), this.akzent});

  final Widget child;
  final EdgeInsets padding;

  /// Farbiger linker Rand (z. B. Farbcode einer Figur).
  final Color? akzent;

  @override
  Widget build(BuildContext context) => MTafel(padding: padding, akzent: akzent, child: child);
}

/// Kleiner Farbpunkt mit dem Farbcode einer Figur.
class FarbPunkt extends StatelessWidget {
  const FarbPunkt(this.farbe, {super.key, this.groesse = 14});
  final Color farbe;
  final double groesse;

  @override
  Widget build(BuildContext context) => Container(
        width: groesse,
        height: groesse,
        // Heller Rand, damit auch sehr dunkle Farbcodes auf dem dunklen Grund sichtbar sind (B7).
        decoration: BoxDecoration(color: farbe, shape: BoxShape.circle, border: Border.all(color: Keller.papierGedaempft, width: 1.5)),
      );
}

/// Farben und Schriften des Themas: in einer Akte mit deren Akzent (Kerzenorange,
/// Spukcyan, Mondblau, Messing, Neon), sonst im Grundton Kerzenmessing. Die
/// Konstanten in [Keller] bleiben der Grundton; Bildschirme des Abends nehmen
/// diese Zugriffe, damit der Akzent der Akte sichtbar wird.
extension KellerThema on BuildContext {
  MFarben get farben => MFarben.von(this);
  MSchrift get schrift => MSchrift.von(this);
}
