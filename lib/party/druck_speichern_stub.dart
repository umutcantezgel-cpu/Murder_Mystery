import 'dart:typed_data';
import 'dart:ui' show Rect;

import 'datei_teilen.dart';

/// In der App (Android, iOS, Desktop) geht die Datei an das Teilen des Systems.
Future<bool> dateiAnbieten(String name, Uint8List bytes, {String typ = 'application/pdf', Rect? ursprung}) =>
    dateiTeilen(name, bytes, typ: typ, ursprung: ursprung);

/// Das Teilen des Systems braucht keinen eigenen Tipp.
const zweiterTipp = false;

bool dateiTeilbar(String name, String typ) => true;
