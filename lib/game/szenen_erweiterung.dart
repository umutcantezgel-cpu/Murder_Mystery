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
}

/// Optionale, vom Spielablauf geführte Figur. Klassische Sessions implementieren
/// dies nicht und behalten ihre Vorhersage, Tastatur und Joystick-Steuerung.
abstract interface class GefuehrteSzene {
  bool get eingabeGesperrt;
  bool get bewegungReduziert;
  SzenenPose? get figurenPose;
  double get posenFortschritt;

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
