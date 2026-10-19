import 'dart:async';
import 'dart:js_interop';
import 'dart:typed_data';
import 'dart:ui' show Rect;

/// Im Browser (nur `dart:js_interop`, ohne Paket): ein Download über einen
/// Blob-Link, mit [teilen] das Teilen-Fenster des Browsers (`navigator.share`).
/// Am Handy kann es speichern und an eine Person schicken, am Rechner
/// (Windows, macOS) weder speichern noch drucken: Darum ist der Download der
/// Standard und steht immer neben dem Teilen. Beides verlangt einen Tipp des
/// Nutzers: Bis zum Aufruf läuft alles synchron.
Future<bool> dateiAnbieten(String name, Uint8List bytes, {String typ = 'application/pdf', Rect? ursprung, bool teilen = false}) async {
  if (!teilen) return _herunterladen(name, bytes, typ);
  final daten = _TeilDaten(files: [_Datei([bytes.toJS].toJS, name.toJS, _BlobOptionen(type: typ.toJS))].toJS);
  if (!_kannTeilen(daten)) return false;
  try {
    await _navigator.share(daten).toDart;
    return true;
  } catch (e) {
    // Ein Abbruch im Teilen-Fenster ist kein Fehler: Der Download steht daneben.
    return '$e'.contains('AbortError');
  }
}

/// Der Browser verlangt für Teilen und Download einen eigenen Tipp.
const zweiterTipp = true;

/// Den Download gibt es in jedem Browser.
const kannHerunterladen = true;

bool dateiTeilbar(String name, String typ) =>
    _kannTeilen(_TeilDaten(files: [_Datei(<JSAny>[].toJS, name.toJS, _BlobOptionen(type: typ.toJS))].toJS));

bool _kannTeilen(_TeilDaten daten) {
  try {
    return _navigator.canShare(daten);
  } catch (_) {
    // Ohne canShare (etwa Firefox am Rechner) bleibt der Download.
    return false;
  }
}

/// Download über einen Blob-Link. Die Adresse wird erst später freigegeben,
/// damit langsame Browser (Safari) die Datei noch lesen.
bool _herunterladen(String name, Uint8List bytes, String typ) {
  final blob = _Blob([bytes.toJS].toJS, _BlobOptionen(type: typ.toJS));
  final url = _createObjectURL(blob);
  final a = _dokument.createElement('a'.toJS) as _Link;
  a.href = url;
  a.download = name.toJS;
  _dokument.body.appendChild(a);
  a.click();
  a.remove();
  Timer(const Duration(minutes: 1), () => _revokeObjectURL(url));
  return true;
}

@JS('Blob')
extension type _Blob._(JSObject _) implements JSObject {
  external factory _Blob(JSArray<JSAny> teile, _BlobOptionen optionen);
}

@JS('File')
extension type _Datei._(JSObject _) implements JSObject {
  external factory _Datei(JSArray<JSAny> teile, JSString name, _BlobOptionen optionen);
}

extension type _BlobOptionen._(JSObject _) implements JSObject {
  external factory _BlobOptionen({JSString type});
}

extension type _TeilDaten._(JSObject _) implements JSObject {
  external factory _TeilDaten({JSArray<_Datei> files});
}

@JS('navigator')
external _Navigator get _navigator;

extension type _Navigator._(JSObject _) implements JSObject {
  external bool canShare(_TeilDaten daten);
  external JSPromise<JSAny?> share(_TeilDaten daten);
}

@JS('URL.createObjectURL')
external JSString _createObjectURL(_Blob blob);

@JS('URL.revokeObjectURL')
external void _revokeObjectURL(JSString url);

@JS('document')
external _Dokument get _dokument;

extension type _Dokument._(JSObject _) implements JSObject {
  external JSObject createElement(JSString tag);
  external _Element get body;
}

extension type _Element._(JSObject _) implements JSObject {
  external void appendChild(JSObject kind);
}

extension type _Link._(JSObject _) implements JSObject {
  external set href(JSString wert);
  external set download(JSString wert);
  external void click();
  external void remove();
}
