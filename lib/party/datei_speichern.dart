import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Der Kanal zur Android-App (`MainActivity.kt`). Tests hängen sich mit einem
/// Zeugen an denselben Namen (`setMockMethodCallHandler`).
const _kanal = MethodChannel('mordakte/datei');

/// „Herunterladen“ in der Android-App (A-059): öffnet den Speichern-Dialog des
/// Systems, die Person wählt den Ort, meist „Downloads“. Danach zeigt Android
/// kurz [gespeichert]; der Satz kommt aus der ARB, das Kotlin kennt keinen
/// Oberflächentext. `false`, wenn es den Dialog nicht gibt oder das Schreiben
/// scheitert (dann steht „Teilen“ daneben); ein Abbruch im Dialog zählt als
/// angeboten, wie beim Teilen (`datei_teilen.dart`).
Future<bool> dateiSpeichern(String name, Uint8List bytes, {String typ = 'application/pdf', required String gespeichert}) async {
  try {
    await _kanal.invokeMethod<bool>('speichern', {'name': name, 'typ': typ, 'bytes': bytes, 'gespeichert': gespeichert});
    return true;
  } catch (e) {
    debugPrint('DATEI speichern fehler $e');
    return false;
  }
}
