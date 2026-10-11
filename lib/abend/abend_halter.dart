import 'package:flutter/foundation.dart';

import '../party/sitzung.dart';

/// Hält den laufenden Abend zwischen dem Assistenten (`/abend/neu`) und der
/// Abendseite (`/abend`). Der Assistent übergibt die eingerichtete Sitzung, die
/// Abendseite räumt sie am Ende wieder ab. Nach einem Neuladen der Seite ist der
/// Halter leer; `/abend` führt dann zurück in die Detektei.
class AbendHalter extends ChangeNotifier {
  PartySitzung? _sitzung;

  /// Der laufende Abend, falls einer läuft.
  PartySitzung? get sitzung => _sitzung;
  bool get laeuft => _sitzung != null;

  /// Übernimmt [s]; ein vorheriger Abend wird entsorgt.
  void uebernehmen(PartySitzung s) {
    final alt = _sitzung;
    _sitzung = s;
    if (alt != null && !identical(alt, s)) alt.dispose();
    notifyListeners();
  }

  /// Gibt [s] frei, falls sie noch der laufende Abend ist, und entsorgt sie.
  /// Meldet nichts weiter, weil der Aufruf beim Abbau der Abendseite geschieht.
  /// Eine Sitzung, die [uebernehmen] schon ersetzt hat, ist bereits entsorgt.
  void freigeben(PartySitzung s) {
    if (!identical(_sitzung, s)) return;
    _sitzung = null;
    s.dispose();
  }
}
