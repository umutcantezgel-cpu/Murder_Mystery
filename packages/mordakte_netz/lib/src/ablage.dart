/// Dauerhafter Speicher für Gastgeber-Zustand und Gast-Schlüssel. Die App legt
/// eine Implementierung darüber (SharedPreferences, Datei, localStorage); das
/// Paket kennt nur Zeichenketten.
library;

abstract interface class Ablage {
  Future<String?> lesen(String schluessel);
  Future<void> schreiben(String schluessel, String wert);
  Future<void> loeschen(String schluessel);
}

/// Speicher im Arbeitsspeicher (Tests, Probeläufe, Gäste ohne Wiederaufnahme).
class SpeicherAblage implements Ablage {
  final Map<String, String> daten = {};

  @override
  Future<String?> lesen(String schluessel) async => daten[schluessel];

  @override
  Future<void> schreiben(String schluessel, String wert) async => daten[schluessel] = wert;

  @override
  Future<void> loeschen(String schluessel) async => daten.remove(schluessel);
}
