import 'dart:ui' show Rect;

import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart';

/// Das Teilen des Systems für Dateien (PDF der Druckfassung, Steckbriefe,
/// Mappen des Krimidinners); Tests setzen hier einen Zeugen ein wie bei
/// `teilenUeber` in `teilen.dart`.
@visibleForTesting
Future<ShareResult> Function(ShareParams) dateiTeilenUeber = (p) => SharePlus.instance.share(p);

/// Gibt eine Datei an das Teilen des Systems (A-059): Auf Android und iOS lässt
/// sie sich speichern, drucken oder per Messenger und Mail an eine Person
/// schicken. Die Datei entsteht aus den Bytes ([XFile.fromData]); den Namen
/// setzt [ShareParams.fileNameOverrides], weil die meisten Systeme den Namen der
/// Datei sonst verwerfen. [ursprung] ist der Knopf (iPad: Ort des Fensters).
/// `false`, wenn das System nicht teilen kann; ein Abbruch im Teilen-Fenster
/// zählt als angeboten.
Future<bool> dateiTeilen(String name, Uint8List bytes, {String typ = 'application/pdf', Rect? ursprung}) async {
  try {
    await dateiTeilenUeber(ShareParams(
      files: [XFile.fromData(bytes, mimeType: typ, name: name)],
      fileNameOverrides: [name],
      sharePositionOrigin: ursprung,
    ));
    return true;
  } catch (e) {
    debugPrint('DATEI teilen fehler $e');
    return false;
  }
}
