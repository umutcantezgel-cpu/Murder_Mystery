import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Eine Akte der Kampagne: ein Eintrag aus `content/party/akten.json`, dazu
/// (falls lesbar) die Spannweite der Besetzung aus `besetzung.json` der Akte.
@immutable
class AkteInfo {
  const AkteInfo({
    required this.id,
    required this.titel,
    required this.untertitel,
    required this.ton,
    this.freiAb = 0,
    this.minRollen,
    this.maxRollen,
  });

  /// Kennung, zugleich Ordner unter `content/party/`.
  final String id;
  final String titel;
  final String untertitel;

  /// Ton der Akte (`spuk`, …); die Oberfläche übersetzt ihn.
  final String ton;

  /// Freischaltung in der Kampagne (Anzahl abgeschlossener Akten); noch ohne Wirkung.
  final int freiAb;

  /// Kleinste und größte Zahl besetzter Rollen; `null`, wenn die Datei fehlt.
  final int? minRollen;
  final int? maxRollen;

  /// Gibt es zu dieser Akte eine Druckmappe? (Bisher nur der Schlosskeller.)
  bool get druckbar => id == 'schlosskeller';

  /// Zwei Buchstaben für das Siegel, falls der Stil kein Kürzel kennt.
  String get kuerzel {
    final t = titel.trim();
    return t.length >= 2 ? t.substring(0, 2).toUpperCase() : t.toUpperCase();
  }
}

/// Liest die Kampagne aus `content/party/akten.json`.
abstract final class AktenKatalog {
  static const pfad = 'content/party/akten.json';

  /// Alle Akten in Spielreihenfolge. Das Standardbündel (`rootBundle`) hält
  /// gelesene Dateien selbst im Zwischenspeicher.
  static Future<List<AkteInfo>> laden([AssetBundle? bundle]) => _lesen(bundle ?? rootBundle);

  static Future<List<AkteInfo>> _lesen(AssetBundle bundle) async {
    final json = jsonDecode(await bundle.loadString(pfad)) as Map<String, dynamic>;
    final liste = <AkteInfo>[];
    for (final eintrag in (json['akten'] as List? ?? const [])) {
      final m = eintrag as Map<String, dynamic>;
      final id = m['id'] as String;
      int? min, max;
      try {
        final b = jsonDecode(await bundle.loadString('content/party/$id/besetzung.json')) as Map<String, dynamic>;
        min = (b['minRollen'] as num?)?.toInt();
        max = (b['maxRollen'] as num?)?.toInt();
      } catch (_) {
        // Ohne Besetzungsdatei zeigt die Karte keine Personenzahl.
      }
      liste.add(AkteInfo(
        id: id,
        titel: m['titel'] as String? ?? id,
        untertitel: m['untertitel'] as String? ?? '',
        ton: m['ton'] as String? ?? '',
        freiAb: (m['freiAb'] as num?)?.toInt() ?? 0,
        minRollen: min,
        maxRollen: max,
      ));
    }
    return liste;
  }
}
