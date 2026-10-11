import 'package:mordakte_core/runden.dart' show KartenDef;

import '../karten/katalog_laden.dart' show KartenFigur, kartenFigurenAus;
import 'sitzung.dart';

final _zwischen = Expando<Map<String, KartenFigur>>('PartyKartenFiguren');

/// Farbcode und Büste der Figuren der Akte für die Karten am Tisch.
extension PartyKartenFiguren on PartySitzung {
  Map<String, KartenFigur> get _kartenFiguren => _zwischen[this] ??= kartenFigurenAus(kanon.figurenJson);

  /// Die Figur zu [k], wenn die Karte zur Akte des Abends gehört; sonst `null`
  /// (Detektivklassen und fremde Akten färbt die Karte selbst).
  KartenFigur? kartenFigur(KartenDef k) => k.akte == daten.fall ? _kartenFiguren[k.figur] : null;
}
