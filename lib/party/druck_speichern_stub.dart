import 'dart:typed_data';
import 'dart:ui' show Rect;

import 'datei_teilen.dart';

/// In der App (Android, iOS, Desktop) geht die Datei immer an das Teilen des
/// Systems, auch ohne [teilen]: Einen Download gibt es hier nicht.
Future<bool> dateiAnbieten(String name, Uint8List bytes, {String typ = 'application/pdf', Rect? ursprung, bool teilen = true}) =>
    dateiTeilen(name, bytes, typ: typ, ursprung: ursprung);

/// Das Teilen des Systems braucht keinen eigenen Tipp.
const zweiterTipp = false;

/// Ohne Browser gibt es keinen Download.
const kannHerunterladen = false;

bool dateiTeilbar(String name, String typ) => true;
