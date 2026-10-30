import 'dart:ui' show Rect;

import 'package:flutter/foundation.dart';

import 'druck_speichern_stub.dart' if (dart.library.js_interop) 'druck_speichern_web.dart' as umsetzung;

/// Die Wege, eine fertige Datei anzubieten (A-059).
enum DateiWeg {
  /// Download: im Browser direkt in den Download-Ordner, in der Android-App über
  /// den Speichern-Dialog des Systems (Ort wählen, meist „Downloads“). Am Rechner
  /// der Weg zum Speichern und Drucken: Das Teilen-Fenster von Windows und macOS
  /// kennt beides nicht.
  herunterladen,

  /// Das Teilen des Systems (App) oder des Browsers: speichern, drucken oder an
  /// eine Person schicken, je nachdem, was das Gerät dort anbietet.
  teilen,
}

/// Was dieses Gerät mit Dateien kann: in der App das Teilen des Systems
/// (`datei_teilen.dart`), auf Android dazu den Speichern-Dialog
/// (`datei_speichern.dart`), im Browser den Download und, wenn der Browser
/// Dateien teilen kann, sein Teilen.
class DateiGeraet {
  const DateiGeraet();

  /// Braucht das Anbieten einen eigenen Tipp, nachdem die Datei gebaut ist? Im
  /// Browser ja (Download und Teilen müssen direkt im Tipp liegen), auf Android
  /// auch: Dort wählt man zwischen „Herunterladen“ und „Teilen“.
  bool get zweiterTipp => umsetzung.zweiterTipp;

  /// Gibt es einen Download? Im Browser und in der Android-App (Speichern-Dialog),
  /// nicht in der App auf iOS und am Rechner (auf iOS hat das Teilen-Fenster
  /// „In Dateien sichern“).
  bool get kannHerunterladen => umsetzung.kannHerunterladen;

  /// Öffnet „Herunterladen“ erst einen Dialog des Systems (Android: Ort wählen)?
  /// Im Browser nicht, der Download geht gleich in den Download-Ordner.
  bool get herunterladenMitDialog => umsetzung.herunterladenMitDialog;

  /// Kann das Gerät eine Datei vom Typ [typ] teilen?
  bool kannTeilen(String name, String typ) => umsetzung.dateiTeilbar(name, typ);

  /// Der Weg, wenn niemand wählt ([dateiAnbieten] ohne `weg`, etwa im
  /// Krimidinner, das die Datei im Tipp baut): im Browser der Download, in der
  /// App das Teilen des Systems, auch auf Android. Dort öffnet „Herunterladen“
  /// einen Dialog; den bekommt nur, wer den Knopf dafür wählt ([dateiWege]).
  DateiWeg get standardWeg =>
      kannHerunterladen && !herunterladenMitDialog ? DateiWeg.herunterladen : DateiWeg.teilen;

  Future<bool> anbieten(String name, Uint8List bytes, {required String typ, Rect? ursprung, required DateiWeg weg}) =>
      umsetzung.dateiAnbieten(name, bytes, typ: typ, ursprung: ursprung, teilen: weg == DateiWeg.teilen);
}

/// Das Gerät, auf dem die App läuft; Tests setzen hier den Browser oder Android
/// ein, weil sie selbst auf keinem von beiden laufen.
@visibleForTesting
DateiGeraet dateiGeraet = const DateiGeraet();

/// Bietet eine Datei auf dem Weg [weg] an (A-059), ohne Angabe auf dem
/// Standardweg ([DateiGeraet.standardWeg]): in der App über das Teilen des
/// Systems, im Browser als Download. `false`, wenn das auf diesem Gerät nicht
/// geklappt hat; ein Abbruch im Teilen-Fenster oder im Speichern-Dialog ist kein
/// Fehler.
///
/// Im Browser muss der Aufruf direkt im Tipp liegen, ohne `await` davor: Erst
/// die Datei bauen, dann in einem zweiten Tipp anbieten ([zweiterTipp]).
/// [ursprung] ist der Knopf (iPad: Ort des Teilen-Fensters).
Future<bool> dateiAnbieten(String name, Uint8List bytes, {String typ = 'application/pdf', Rect? ursprung, DateiWeg? weg}) =>
    dateiGeraet.anbieten(name, bytes, typ: typ, ursprung: ursprung, weg: weg ?? dateiGeraet.standardWeg);

/// Braucht das Anbieten einen eigenen Tipp, nachdem die Datei gebaut ist? Im
/// Browser und auf Android ja.
bool get zweiterTipp => dateiGeraet.zweiterTipp;

/// Die Wege, die dieses Gerät für eine Datei vom Typ [typ] zur Wahl hat, in der
/// Reihenfolge der Knöpfe. Wo es einen Download gibt (Browser, Android), steht er
/// immer vorn: Ein geschlossenes Teilen-Fenster darf nie der einzige Weg zur
/// Datei sein.
List<DateiWeg> dateiWege(String name, {String typ = 'application/pdf'}) => [
      if (dateiGeraet.kannHerunterladen) DateiWeg.herunterladen,
      if (dateiGeraet.kannTeilen(name, typ)) DateiWeg.teilen,
    ];
