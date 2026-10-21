import 'package:flutter/foundation.dart';

/// Abschnitt des Streifzugs in den Entscheidungen (Langer Abend M7b): frei
/// unterwegs, auf dem Weg zurück in den Keller oder in der Entscheidung (der
/// unveränderte Ablauf am Tisch).
enum StreifzugModus { streifzug, rueckweg, entscheidung }

/// Was ein Streifzug-Bildschirm der [StreifzugSteuerung] anbietet.
abstract interface class StreifzugBedienung {
  /// Geht geführt zur Marke [marke] (`treff:<befragung>`, `erkunde:<ort>`);
  /// `false`, wenn es die Marke gerade nicht gibt.
  bool gehe(String marke);

  /// Schließt die offene Karte.
  void schliessen();

  /// Beendet einen geführten Weg sofort am Ziel.
  void abkuerzen();

  /// Vor einer Entscheidung: zurück in den Keller, danach die Entscheidung.
  /// `false`, wenn gerade keine Entscheidung offen ist.
  bool zurEntscheidung();
}

/// Bedienung des Streifzugs auf einem Gerät (Langer Abend M7b): wohin der
/// Detektiv gerade geht, welche Karte offen ist und ob er in der Entscheidung
/// steht. Bildschirm, Entwickler-Skript und Tests teilen sie. Sie liegt nie
/// im Journal und ändert nichts am Abend; über sie läuft nur, was auch ein
/// Tipp auf den Bildschirm auslöst.
class StreifzugSteuerung extends ChangeNotifier {
  StreifzugBedienung? _bedienung;
  String? _offen;
  String? _unterwegs;
  StreifzugModus _modus = StreifzugModus.streifzug;

  /// Letzte Stelle des Detektivs (Ebene, x, y) mit ihrer Runde: Der nächste
  /// Bildschirm derselben Runde beginnt dort, eine neue Runde im Keller.
  ({int runde, String ebene, double x, double y})? position;

  /// Kennungen der Erkundungsorte der Akte in Dateireihenfolge, sobald der
  /// Bildschirm die Welt geladen hat (Skript: Plan über die Runden).
  List<String> orte = const [];

  /// Ist ein Streifzug-Bildschirm angemeldet?
  bool get bereit => _bedienung != null;

  /// Offene Karte: eine Marke, `start` (Rundenstart), `tisch` oder `uhr`.
  String? get offen => _offen;

  /// Marke, zu der der Detektiv gerade geführt geht, sonst `null`.
  String? get unterwegs => _unterwegs;

  StreifzugModus get modus => _modus;

  /// Ist [b] der angemeldete Bildschirm? Nur er meldet seinen Stand (beim
  /// Wechsel der Phase blenden zwei Bildschirme kurz übereinander).
  bool angemeldet(StreifzugBedienung b) => identical(_bedienung, b);

  /// Der Bildschirm meldet sich an (und beim Entsorgen wieder ab).
  void anmelden(StreifzugBedienung b) => _bedienung = b;

  void abmelden(StreifzugBedienung b) {
    if (!identical(_bedienung, b)) return;
    _bedienung = null;
    // Still: Abgemeldet wird beim Entsorgen des Bildschirms, mitten im Abbau des Baums.
    _offen = _unterwegs = null;
    _modus = StreifzugModus.streifzug;
  }

  bool gehe(String marke) => _bedienung?.gehe(marke) ?? false;
  void schliessen() => _bedienung?.schliessen();
  void abkuerzen() => _bedienung?.abkuerzen();
  bool zurEntscheidung() => _bedienung?.zurEntscheidung() ?? false;

  /// Stand des Bildschirms; meldet nur Änderungen.
  void melde({required String? offen, required String? unterwegs, required StreifzugModus modus}) =>
      _setze(offen: offen, unterwegs: unterwegs, modus: modus);

  void _setze({required String? offen, required String? unterwegs, required StreifzugModus modus}) {
    if (offen == _offen && unterwegs == _unterwegs && modus == _modus) return;
    _offen = offen;
    _unterwegs = unterwegs;
    _modus = modus;
    notifyListeners();
  }
}
