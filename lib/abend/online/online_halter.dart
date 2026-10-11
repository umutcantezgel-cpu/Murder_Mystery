import 'dart:async';

import 'package:flutter/foundation.dart';

import 'gast_dienst.dart';
import 'gastgeber_dienst.dart';

/// Hält die Verbindung eines Online-Abends zwischen den Seiten: auf dem
/// Gastgebergerät den [GastgeberDienst] (Lobby und Abend), auf einem Gast den
/// [GastDienst]. Wie der `AbendHalter` ist er nach dem Neuladen der Seite leer;
/// die Detektei bietet dann die Rückkehr aus dem abgelegten Stand an.
class OnlineHalter extends ChangeNotifier {
  GastgeberDienst? _dienst;
  GastDienst? _gast;

  /// Der Raum, den dieses Gerät als Gastgeber führt (Lobby oder laufender Abend).
  GastgeberDienst? get dienst => _dienst;

  /// Der Raum, in dem dieses Gerät Gast ist.
  GastDienst? get gast => _gast;

  /// Übernimmt [d]; ein früherer Gastgeberabend wird beendet.
  void uebernehmeDienst(GastgeberDienst d) {
    final alt = _dienst;
    _dienst = d;
    if (alt != null && !identical(alt, d)) unawaited(alt.schliessen());
    notifyListeners();
  }

  /// Der Dienst ist zu Ende (geschlossen oder weitergereicht). Meldet nichts
  /// weiter: Der Aufruf geschieht beim Abbau einer Seite (wie bei `AbendHalter.freigeben`).
  void vergissDienst(GastgeberDienst d) {
    if (identical(_dienst, d)) _dienst = null;
  }

  /// Übernimmt [g]; eine frühere Gastverbindung wird getrennt.
  void uebernehmeGast(GastDienst g) {
    final alt = _gast;
    _gast = g;
    if (alt != null && !identical(alt, g)) {
      unawaited(alt.trennen());
    }
    notifyListeners();
  }

  /// Die Gastverbindung ist zu Ende; meldet nichts weiter (siehe [vergissDienst]).
  void vergissGast(GastDienst g) {
    if (identical(_gast, g)) _gast = null;
  }
}
