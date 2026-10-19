import 'dart:ui';

import 'package:mordakte_core/mordakte_core.dart';

/// Optionale Erweiterung einer `GameSession` für Szenen ohne Mordakte-Engine
/// (Partymodus, E-030). [MordakteGame] prüft `session is SzenenErweiterung`;
/// ohne sie bleibt alles wie bisher (Bestandsschutz).
abstract interface class SzenenErweiterung {
  /// Beschriftung der Aktion an einer Figur; `null` heißt: gerade nicht
  /// ansprechbar (die Figur bleibt sichtbar).
  String? npcAktion(String npcId);

  /// Wird eine Figur untersucht statt befragt? Dann zeigt der Aktionsknopf die
  /// Lupe statt der Sprechblase (E-038).
  bool npcUntersuchen(String npcId);

  /// Beschriftung der Aktion an einem Hotspot; `null` heißt: Vorgabe nach Art.
  String? hotspotAktion(String hotspotId);

  /// Licht der Szene; `null` heißt: Licht nach Spielphase wie bisher.
  SzenenLicht? get licht;

  /// Räume im Sichtfeld, wenn der eigene Detektiv bei ([x], [y]) steht.
  /// `null` heißt: kein Nebel des Krieges.
  Set<String>? sichtbareRaeume(double x, double y);

  /// Hervorhebung einer Figur in einer Rückblende: `null` normal, `0` nur
  /// Umriss im Dunkeln, `1` hervorgehoben.
  double? hervorhebung(String npcId);

  /// Ruhe-Animation einer stehenden Figur (Atmen, leichtes Wiegen).
  bool get ruheAnimation;

  /// Kleine Effekte (Master 7.13): Seifenblasen aus der Pfeife des eigenen
  /// Detektivs im Stand, Gags an Rüstung (`party_ruestung`) und Kamin
  /// (`party_kamin`), wenn der Detektiv vorbeikommt.
  bool get kleineEffekte;

  /// Aussehen des eigenen Detektivs aus dem Kanon; `null` heißt: Vorgabe.
  LookDef? get detektivAussehen;

  /// Fester Kamerapunkt in Kachelkoordinaten (Rückblende); dann wird die
  /// eigene Figur nicht gezeichnet. `null` heißt: Kamera folgt der Figur.
  Offset? get kamera;

  /// Die Szene meldet die Figuren jedes Frame genau auf ihren Wegen
  /// (Rückblende). Der Renderer übernimmt die Stellen dann direkt: kein
  /// 120-ms-Puffer, keine Sehnen zwischen Proben, kein Teleport-Sprung.
  bool get exakteFiguren;
}

/// Optionale, vom Spielablauf geführte Figur. Klassische Sessions implementieren
/// dies nicht und behalten ihre Vorhersage, Tastatur und Joystick-Steuerung.
abstract interface class GefuehrteSzene {
  bool get eingabeGesperrt;
  bool get bewegungReduziert;
  SzenenPose? get figurenPose;
  double get posenFortschritt;

  /// Ziel der laufenden Handlung (befragte Person oder untersuchter Ort) in
  /// Kachelkoordinaten. Die Kamera stellt dann Detektiv und Ziel als
  /// Zweier-Einstellung ins Bild (Szenenregie). `null`: keine Handlung.
  Offset? get handlungsZiel;

  /// Nur der tatsächlich laufende Renderer treibt Wege und Posen voran.
  /// Hintergrund-Timer dürfen keine Kartenaktion als gesehen quittieren.
  void szenenSchritt(double sekunden);
}

/// Optional: freiwillige, glitzernde Markierungen in der Szene (offene
/// Abstecher). Sie sind keine Hotspots der Entscheidung: nur ein Funkeln, das
/// den Ort zeigt; gewählt wird über die Aktionsliste des Bildschirms.
abstract interface class SzenenGlanz {
  /// Aktuelle Markierungen in Kachelkoordinaten (leer, wenn nichts offen ist).
  List<SzenenGlanzPunkt> get glanzpunkte;
}

/// Ein Funkeln an einem Ort ([x], [y] in Kachelkoordinaten).
class SzenenGlanzPunkt {
  final String id;
  final double x, y;
  const SzenenGlanzPunkt(this.id, this.x, this.y);
}

enum SzenenPose { gehen, suchen, befragen }

/// Optional (M1.5, noch ohne Nutzer): Die Szene übernimmt das Tippen zum
/// Gehen, etwa ein Gast, dessen Weg der Gastgeber plant. Ohne sie plant der
/// Renderer den Weg selbst wie bisher.
abstract interface class SzenenLaufziel {
  /// Lauf zum Punkt [ziel] (Kachelkoordinaten), auf Wunsch zu der Person oder
  /// dem Ort [zielId]. `false`, wenn kein Weg dorthin führt.
  bool laufeZu(Offset ziel, {String? zielId});
}

/// Optional (M1.5, noch ohne Nutzer): Aussehen und Namensschild der Figuren
/// kommen aus der Szene statt aus dem Szenario. Ohne sie gilt die Vorgabe.
abstract interface class SzenenFiguren {
  /// Aussehen der Figur [id]; `null` heißt: Vorgabe des Szenarios.
  LookDef? aussehenVon(String id);

  /// Text des Namensschilds der Figur [id]; `null` heißt: Vorgabe.
  String? schild(String id);
}

/// Optional: Wirkung der Detektivklasse auf die Szene (A-055, M6), nur
/// Darstellung und Tempo, nie Fakten, Punkte oder Würfel. Ohne sie oder mit
/// den neutralen Werten (Radius 0, Tempo 1, sonst nichts) bleibt alles wie
/// bisher: kein Leuchten im Umkreis, Grundtempo, keine Türhinweise, keine
/// Marken und keine Gerüchte.
abstract interface class SzenenKlasse {
  /// Radius um den eigenen Detektiv, in dem offene Hotspots und Glanzpunkte
  /// zusätzlich leuchten (Kacheln); 0 heißt: kein Leuchten.
  double get glanzRadius;

  /// Faktor auf das Lauftempo des eigenen Detektivs (1 = Grundtempo).
  double get tempoFaktor;

  /// Türen, verschlossene Türen und Treppen werden umrandet.
  bool get tuerenZeigen;

  /// Gerücht der Figur [npcId] beim Vorbeigehen; `null` heißt: keines.
  String? geruechtFuer(String npcId);

  /// Sprechblasen-Marker über der Figur [npcId]: Mit ihr ist gerade ein
  /// Randgespräch möglich.
  bool gespraechsMarker(String npcId);

  /// Die Geste der laufenden Gesprächszeile steht als Zeichen über der Figur.
  bool get stimmungZeigen;
}

/// Optional: Geste der befragten Figur in einem Gespräch mit Wahl. Die Figur
/// unterbricht ihre Tätigkeit und spielt die aktuelle Zeile: Arme verschränkt
/// bei Abwehr, der Blick wandert beim Nachdenken.
abstract interface class SzenenGespraech {
  /// Renderer-Kennung der Figur und Geste der aktuellen Zeile, sonst `null`.
  ({String npc, SzenenGeste geste})? get gespraechsGeste;
}

enum SzenenGeste { zuhoeren, abwehr, nachdenken }

/// Ein Lichtpunkt der Szene in Kachelkoordinaten.
class SzenenLichtpunkt {
  final double x, y, z;
  final double radius;
  final Color farbe;

  /// Stärke des Sinus-Flackerns (0 = ruhig).
  final double flackern;
  const SzenenLichtpunkt(this.x, this.y, {this.z = 0.6, required this.radius, required this.farbe, this.flackern = 0});
}

/// Licht einer Szene (Master 7.13): Grundlicht, Lichtpunkte, Taschenlampe.
class SzenenLicht {
  /// Anteil der Dunkelheit (0,77 heißt 23 % Grundlicht).
  final double dunkel;

  /// Lichtpunkte (warme Kerzen, Notausgangsschild, getragene Lampen).
  final List<SzenenLichtpunkt> punkte;

  /// Lichtkegel des eigenen Detektivs.
  final bool taschenlampe;

  /// Räume mit Raumlicht (werden aufgehellt).
  final Set<String> helleRaeume;

  const SzenenLicht({required this.dunkel, this.punkte = const [], this.taschenlampe = true, this.helleRaeume = const {}});
}

/// Optional: Punkte der Szene, die im Bild bleiben sollen (Ziele der laufenden
/// Entscheidung, Ziel des Laufs). Mit `GameView.kameraPassend` passt die Kamera
/// Zoom und Ausschnitt an diese Punkte und an den eigenen Detektiv an.
abstract interface class SzenenKamera {
  /// Ziele in Kachelkoordinaten; leer, wenn nichts Besonderes im Bild sein muss.
  List<Offset> get kameraZiele;
}

/// Teil des Bildes, den ein Bedienfeld über der Szene verdeckt (Pixel). Die
/// Kamera legt den Ausschnitt in den freien Rest.
class SzenenRand {
  final double oben, unten, links, rechts;
  const SzenenRand({this.oben = 0, this.unten = 0, this.links = 0, this.rechts = 0});

  static const keiner = SzenenRand();

  @override
  bool operator ==(Object other) =>
      other is SzenenRand && other.oben == oben && other.unten == unten && other.links == links && other.rechts == rechts;

  @override
  int get hashCode => Object.hash(oben, unten, links, rechts);
}

/// Hintergrund hinter und neben der Karte (Palette der Akte): ein weicher
/// Verlauf von [mitte] nach [rand] statt reinem Schwarz.
class SzenenUmgebung {
  final Color mitte, rand;
  const SzenenUmgebung({required this.mitte, required this.rand});

  @override
  bool operator ==(Object other) => other is SzenenUmgebung && other.mitte == mitte && other.rand == rand;

  @override
  int get hashCode => Object.hash(mitte, rand);
}
