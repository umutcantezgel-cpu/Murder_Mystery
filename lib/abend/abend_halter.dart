import 'package:flutter/foundation.dart';
import 'package:mordakte_core/runden.dart' show AbendErgebnis;

import '../party/sitzung.dart';

/// Was vom beendeten Abend für die Belohnung bleibt. Es enthält keine Sitzung:
/// Die Abendseite räumt sie ab, bevor die Belohnungsseite öffnet.
class AbendAbschluss {
  const AbendAbschluss({required this.abendId, required this.ergebnis, this.punkte = 0, this.endeName = ''});

  /// Stabile Kennung des Abends (Doppelbuchungssperre des Geräts).
  final String abendId;
  final AbendErgebnis ergebnis;

  /// Richtige Entscheidungen des Abends.
  final int punkte;

  /// Name des erreichten Endes (Untertitel der Belohnungsseite).
  final String endeName;
}

/// Hält den laufenden Abend zwischen dem Assistenten (`/abend/neu`) und der
/// Abendseite (`/abend`). Der Assistent übergibt die eingerichtete Sitzung, die
/// Abendseite räumt sie am Ende wieder ab. Nach einem Neuladen der Seite ist der
/// Halter leer; `/abend` führt dann zurück in die Detektei.
class AbendHalter extends ChangeNotifier {
  PartySitzung? _sitzung;
  AbendAbschluss? _abschluss;

  /// Der laufende Abend, falls einer läuft.
  PartySitzung? get sitzung => _sitzung;
  bool get laeuft => _sitzung != null;

  /// Der zuletzt beendete Abend, dessen Belohnung noch nicht abgeholt ist.
  AbendAbschluss? get abschluss => _abschluss;

  /// Merkt den beendeten Abend für die Belohnungsseite.
  void beende(AbendAbschluss a) {
    _abschluss = a;
    notifyListeners();
  }

  /// Die Belohnung ist abgeholt; die Belohnungsseite ist wieder gesperrt.
  void abschlussErledigt() {
    if (_abschluss == null) return;
    _abschluss = null;
    notifyListeners();
  }

  /// Übernimmt [s]; ein vorheriger Abend wird entsorgt.
  void uebernehmen(PartySitzung s) {
    final alt = _sitzung;
    _sitzung = s;
    _abschluss = null;
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
