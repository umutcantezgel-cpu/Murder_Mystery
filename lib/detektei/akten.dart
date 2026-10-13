import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../karten/katalog_laden.dart' show KartenFigur, kartenFigurenAus;

export '../karten/katalog_laden.dart' show KartenFigur;

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

/// Nummer einer Akte in der Kampagne, zweistellig („01“ für die erste).
String akteNummer(int index) => (index + 1).toString().padLeft(2, '0');

/// Die Lage einer Akte, wie sie vor dem Abend jeder lesen darf (`setting.json`):
/// Schauplatz, Anlass, Zeitpunkt und die Stimmung in kurzen Sätzen.
@immutable
class AkteLage {
  const AkteLage({this.schauplatz = '', this.anlass = '', this.datum = '', this.atmosphaere = const []});

  final String schauplatz;
  final String anlass;

  /// Zeitpunkt in Worten („ein Samstag im November …“).
  final String datum;

  /// Stimmungssätze („Der Wind pfeift …“), als Randnotizen gedacht.
  final List<String> atmosphaere;

  bool get leer => schauplatz.isEmpty && anlass.isEmpty && datum.isEmpty && atmosphaere.isEmpty;
}

/// Öffentlicher Auszug einer Akte für ihre Seite: die Lage und die Besetzung.
///
/// Von jeder Figur gehen nur Kennung, Name, Rollentitel, Farbcode und Aussehen
/// weiter ([kartenFigurenAus]). Motive, Geheimnisse, Lügen und die Frage, wer
/// als Täter in Frage kommt, liest dieser Auszug nie.
@immutable
class AkteAuszug {
  const AkteAuszug({this.lage, this.personen = const [], this.opfer});

  final AkteLage? lage;

  /// Die Rollen in Besetzungsreihenfolge (wie in `figuren.json`).
  final List<KartenFigur> personen;

  /// Das Opfer des Abends (eine Nebenfigur ohne Rolle), falls bekannt.
  final KartenFigur? opfer;

  bool get leer => lage == null && personen.isEmpty && opfer == null;

  /// Liest `content/party/<id>/setting.json` und `figuren.json`. Fehlt eine
  /// Datei oder ist sie nicht lesbar, bleibt ihr Teil leer.
  static Future<AkteAuszug> laden(String id, [AssetBundle? bundle]) async {
    final b = bundle ?? rootBundle;
    AkteLage? lage;
    try {
      final s = jsonDecode(await b.loadString('content/party/$id/setting.json')) as Map<String, dynamic>;
      String feld(String k) => (s[k] is String ? s[k] as String : '').trim();
      lage = AkteLage(
        schauplatz: feld('schauplatz'),
        anlass: feld('anlass'),
        datum: feld('datum'),
        atmosphaere: [
          for (final z in (s['atmosphaere'] as List? ?? const []))
            if (z is String && z.trim().isNotEmpty) z.trim(),
        ],
      );
    } catch (_) {
      lage = null;
    }
    var personen = const <KartenFigur>[];
    KartenFigur? opfer;
    try {
      final j = jsonDecode(await b.loadString('content/party/$id/figuren.json')) as Map<String, Object?>;
      final opferRoh = j['opfer'];
      // Nur die öffentlichen Felder gehen in den Auszug.
      final alle = kartenFigurenAus({
        'figuren': [
          for (final f in (j['figuren'] as List? ?? const []))
            if (f is Map) _oeffentlich(f),
        ],
        if (opferRoh is Map) 'opfer': _oeffentlich(opferRoh),
      });
      final opferId = opferRoh is Map ? opferRoh['id'] : null;
      opfer = opferId is String ? alle[opferId] : null;
      personen = List.unmodifiable([
        for (final e in alle.entries)
          if (e.key != opferId) e.value,
      ]);
    } catch (_) {
      personen = const [];
      opfer = null;
    }
    return AkteAuszug(lage: lage == null || lage.leer ? null : lage, personen: personen, opfer: opfer);
  }

  /// Die Felder einer Figur, die vor dem Abend jeder sehen darf.
  static Map<String, Object?> _oeffentlich(Map<dynamic, dynamic> f) => {
        for (final k in const ['id', 'name', 'roleTitle', 'colorCode', 'look'])
          if (f[k] != null) k: f[k],
      };
}
