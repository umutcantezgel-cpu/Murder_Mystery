/// Fähigkeiten der Detektivklassen auf der Karte (A-055, Langer Abend M6).
///
/// Jede Klasse wirkt nur auf die Darstellung und das Lauftempo der eigenen
/// Figur: Hinweise auf Orte, Marken an Figuren, Gerüchte am Rand. Sie ändert
/// nie Optionen, Fakten, Punkte, Ende, Würfelchancen oder Nachtminuten. Darum
/// liest diese Datei weder Partie noch Zugschicht noch Würfel; sie hält nur
/// feste Werte (Wächter: `test/karten/klassen_test.dart`).
library;

/// Was eine Detektivklasse auf der Karte kann.
enum KlassenFaehigkeit {
  /// Forensikerin: Hotspots und Erkundungsorte leuchten im weiten Radius.
  spurenblick,

  /// Profiler: Sprechblasen-Marker an Zeugen mit Randgespräch, Stimmungsgesten.
  menschenkenner,

  /// Ex-Polizist: Türen, verschlossene Türen und Treppen sind umrandet.
  ortskundig,

  /// Journalistin: beim Vorbeigehen eine pfadfreie Gerüchtzeile der Figur.
  geruechte,

  /// Sanitäter: läuft schneller (nur die sichtbare Figur).
  laufschritt;

  /// Fähigkeit der Klasse [klasse] (`forensic`, `profiler`, …); `null` bei
  /// unbekannter Klasse.
  static KlassenFaehigkeit? vonKlasse(String? klasse) => _jeKlasse[klasse];

  /// Kennung der Klasse, zu der diese Fähigkeit gehört.
  String get klasse => _jeKlasse.entries.firstWhere((e) => e.value == this).key;
}

const _jeKlasse = {
  'forensic': KlassenFaehigkeit.spurenblick,
  'profiler': KlassenFaehigkeit.menschenkenner,
  'excop': KlassenFaehigkeit.ortskundig,
  'journalist': KlassenFaehigkeit.geruechte,
  'medic': KlassenFaehigkeit.laufschritt,
};

/// Feste Werte einer Klasse auf der Karte. Alle Felder sind Darstellung oder
/// Tempo der eigenen Figur; keines fließt in eine Wahl, einen Wurf oder die
/// Wertung.
class KlassenParameter {
  /// Radius in Kacheln, in dem offene Hotspots und Erkundungsorte um den
  /// Detektiv leuchten.
  final double glanzRadius;

  /// Faktor auf das Lauftempo der eigenen Figur (1 = Grundtempo).
  final double tempoFaktor;

  /// Türen, verschlossene Türen und Treppen werden umrandet.
  final bool tuerenZeigen;

  /// Zeugen, mit denen gerade ein Randgespräch möglich ist, tragen eine
  /// Sprechblase.
  final bool gespraechsMarker;

  /// Die Geste der Gesprächszeile steht als Zeichen über der Figur.
  final bool stimmungZeigen;

  /// Figuren sagen beim Vorbeigehen eine Gerüchtzeile.
  final bool geruechte;

  const KlassenParameter({
    this.glanzRadius = standardGlanzRadius,
    this.tempoFaktor = 1,
    this.tuerenZeigen = false,
    this.gespraechsMarker = false,
    this.stimmungZeigen = false,
    this.geruechte = false,
  });

  /// Leuchtradius jeder Klasse ohne Spurenblick (Kacheln).
  static const standardGlanzRadius = 3.0;

  /// Leuchtradius mit Spurenblick (Kacheln).
  static const spurenGlanzRadius = 6.0;

  /// Lauftempo mit Laufschritt.
  static const laufschrittFaktor = 1.3;

  /// Werte der Fähigkeit [f].
  static KlassenParameter von(KlassenFaehigkeit f) => switch (f) {
        KlassenFaehigkeit.spurenblick => const KlassenParameter(glanzRadius: spurenGlanzRadius),
        KlassenFaehigkeit.menschenkenner => const KlassenParameter(gespraechsMarker: true, stimmungZeigen: true),
        KlassenFaehigkeit.ortskundig => const KlassenParameter(tuerenZeigen: true),
        KlassenFaehigkeit.geruechte => const KlassenParameter(geruechte: true),
        KlassenFaehigkeit.laufschritt => const KlassenParameter(tempoFaktor: laufschrittFaktor),
      };
}
