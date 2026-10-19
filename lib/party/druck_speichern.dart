import 'dart:typed_data';
import 'dart:ui' show Rect;

import 'druck_speichern_stub.dart' if (dart.library.js_interop) 'druck_speichern_web.dart' as umsetzung;

/// Bietet eine Datei an (A-059): in der App über das Teilen des Systems
/// (`datei_teilen.dart`: speichern, drucken, an eine Person schicken), im
/// Browser über das Teilen des Browsers, wenn er Dateien teilen kann, sonst als
/// Download. `false`, wenn das auf diesem Gerät nicht geklappt hat.
///
/// Im Browser muss der Aufruf direkt im Tipp liegen, ohne `await` davor: Erst
/// die Datei bauen, dann in einem zweiten Tipp anbieten ([zweiterTipp]).
/// [ursprung] ist der Knopf (iPad: Ort des Teilen-Fensters).
Future<bool> dateiAnbieten(String name, Uint8List bytes, {String typ = 'application/pdf', Rect? ursprung}) =>
    umsetzung.dateiAnbieten(name, bytes, typ: typ, ursprung: ursprung);

/// Braucht das Anbieten einen eigenen Tipp, nachdem die Datei gebaut ist? Im Browser ja.
bool get zweiterTipp => umsetzung.zweiterTipp;

/// Teilt dieses Gerät Dateien vom Typ [typ] (sonst Download)? Nur für die Beschriftung.
bool dateiTeilbar(String name, {String typ = 'application/pdf'}) => umsetzung.dateiTeilbar(name, typ);
