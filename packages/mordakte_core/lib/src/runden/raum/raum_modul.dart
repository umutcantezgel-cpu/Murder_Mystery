import '../../party/ablauf.dart';
import '../../party/kanon/kanon.dart';
import '../../party/texte.dart';
import '../partie.dart';

/// Lesender Blick eines [RaumModul]s auf den Abend. Nie Salz oder Fall-Code.
abstract class RaumKontext {
  /// Gerät der Spielleitung (Autorität).
  String? get host;

  /// Gerät, das ermittelt: der Detektiv-Sitz (Gastgeber oder Gast, siehe
  /// `runden/sitze.dart`); hat er den Abend aufgegeben, der Gastgeber.
  String? get detektiv;

  /// Gerät auf dem Erzähler-Sitz; `null` ohne Erzähler.
  String? get erzaehler;

  /// Laufende Partie; null vor dem Start. Nur lesen, Änderungen nie hier.
  RundenPartie? get partie;

  PartyPhase? get phase => partie?.phase;
  int get runde => partie?.runde ?? 0;

  Kanon get kanon;
  Texte get texte;

  Iterable<String> get spielerIds;
  bool istOnline(String id);

  /// Rolle eines Geräts (null für Detektiv, Erzähler und Assistenz).
  String? rolleVon(String id);

  /// Spielt ein Mensch [rolle] (ein Gerät, das nicht aufgegeben hat)? Sonst spricht die App sie.
  bool menschSpielt(String rolle);

  /// Rechte: werfen `PartyRaumFehler` mit festem Code.
  void nurHost(String id);
  void nurDetektiv(String id);
  void darfLeiten(String id);

  /// Einzige schreibende Hilfe, nur für die Lobby: Ändern sich Sitz oder Figur
  /// eines Geräts, muss es wieder `bereit` melden.
  void bereitAufheben(String id);
}

/// Erweiterung des Raums mit eigenen Nachrichten und Ansichtsteilen.
///
/// Ein Modul darf nie bestehende Ansichtsschlüssel überschreiben, nie die
/// Partie ändern und nie Salz, Pfad oder Fall-Code ausgeben. Seine
/// öffentlichen Schlüssel stehen in `raumOeffentlicheSchluessel`.
abstract class RaumModul {
  /// Nachrichtentyp → erlaubte Schlüssel (ohne `typ` und `revision`).
  Map<String, Set<String>> get nachrichten;

  /// Darf [typ] vor dem Start kommen (Lobby)? Sonst braucht er eine Partie.
  bool vorStart(String typ) => false;

  /// Verarbeitet eine bereits geprüfte Nachricht. Fehler als `PartyRaumFehler`.
  void nachricht(RaumKontext k, String id, String typ, Map<String, Object?> inhalt);

  /// Zusätzliche Bedingung für „Weiter“.
  bool darfWeiter(RaumKontext k) => true;

  /// Nach dem Start (Partie und Rollen stehen fest).
  void beimStart(RaumKontext k) {}

  /// Nach jedem Phasenwechsel durch „Weiter“.
  void phaseGewechselt(RaumKontext k) {}

  /// Öffentliche Teile der Ansicht für Gerät [id] (für alle Geräte gleich).
  Map<String, Object?> oeffentlich(RaumKontext k, String id) => const {};

  /// Private Teile der Ansicht für Gerät [id].
  Map<String, Object?> privat(RaumKontext k, String id) => const {};
}
