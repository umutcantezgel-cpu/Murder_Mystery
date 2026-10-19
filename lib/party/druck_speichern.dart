import 'dart:ui' show Rect;

import 'package:flutter/foundation.dart';

import 'druck_speichern_stub.dart' if (dart.library.js_interop) 'druck_speichern_web.dart' as umsetzung;

/// Die Wege, eine fertige Datei anzubieten (A-059).
enum DateiWeg {
  /// Download im Browser. Am Rechner der Weg zum Speichern und Drucken: Das
  /// Teilen-Fenster von Windows und macOS kennt beides nicht.
  herunterladen,

  /// Das Teilen des Systems (App) oder des Browsers: speichern, drucken oder an
  /// eine Person schicken, je nachdem, was das Gerät dort anbietet.
  teilen,
}

/// Was dieses Gerät mit Dateien kann: in der App das Teilen des Systems
/// (`datei_teilen.dart`), im Browser den Download und, wenn der Browser Dateien
/// teilen kann, sein Teilen.
class DateiGeraet {
  const DateiGeraet();

  /// Braucht das Anbieten einen eigenen Tipp, nachdem die Datei gebaut ist? Im Browser ja.
  bool get zweiterTipp => umsetzung.zweiterTipp;

  /// Gibt es einen Download? Nur im Browser.
  bool get kannHerunterladen => umsetzung.kannHerunterladen;

  /// Kann das Gerät eine Datei vom Typ [typ] teilen?
  bool kannTeilen(String name, String typ) => umsetzung.dateiTeilbar(name, typ);

  Future<bool> anbieten(String name, Uint8List bytes, {required String typ, Rect? ursprung, required DateiWeg weg}) =>
      umsetzung.dateiAnbieten(name, bytes, typ: typ, ursprung: ursprung, teilen: weg == DateiWeg.teilen);
}

/// Das Gerät, auf dem die App läuft; Tests setzen hier den Browser ein, weil
/// sie selbst nicht im Browser laufen.
@visibleForTesting
DateiGeraet dateiGeraet = const DateiGeraet();

/// Bietet eine Datei auf dem Weg [weg] an (A-059), ohne Angabe auf dem
/// Standardweg ([dateiWege]): in der App über das Teilen des Systems, im
/// Browser als Download. `false`, wenn das auf diesem Gerät nicht geklappt hat;
/// ein Abbruch im Teilen-Fenster ist kein Fehler.
///
/// Im Browser muss der Aufruf direkt im Tipp liegen, ohne `await` davor: Erst
/// die Datei bauen, dann in einem zweiten Tipp anbieten ([zweiterTipp]).
/// [ursprung] ist der Knopf (iPad: Ort des Teilen-Fensters).
Future<bool> dateiAnbieten(String name, Uint8List bytes, {String typ = 'application/pdf', Rect? ursprung, DateiWeg? weg}) =>
    dateiGeraet.anbieten(name, bytes, typ: typ, ursprung: ursprung, weg: weg ?? dateiWege(name, typ: typ).first);

/// Braucht das Anbieten einen eigenen Tipp, nachdem die Datei gebaut ist? Im Browser ja.
bool get zweiterTipp => dateiGeraet.zweiterTipp;

/// Die Wege, die dieses Gerät für eine Datei vom Typ [typ] hat; der erste ist
/// der Standard. Im Browser steht der Download immer vorn: Ein geschlossenes
/// Teilen-Fenster darf nie der einzige Weg zur Datei sein.
List<DateiWeg> dateiWege(String name, {String typ = 'application/pdf'}) => [
      if (dateiGeraet.kannHerunterladen) DateiWeg.herunterladen,
      if (dateiGeraet.kannTeilen(name, typ)) DateiWeg.teilen,
    ];
