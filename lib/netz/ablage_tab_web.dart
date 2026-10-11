import 'dart:js_interop';

/// Im Web gibt es `sessionStorage` (kann in privaten Fenstern fehlen: dann
/// liefern Lesen und Schreiben nichts und werfen nie).
const tabSpeicherDa = true;

@JS('sessionStorage')
external _Speicher get _sitzung;

extension type _Speicher._(JSObject _) implements JSObject {
  external String? getItem(String key);
  external void setItem(String key, String value);
  external void removeItem(String key);
}

String? tabLesen(String schluessel) {
  try {
    return _sitzung.getItem(schluessel);
  } catch (_) {
    return null;
  }
}

void tabSchreiben(String schluessel, String wert) {
  try {
    _sitzung.setItem(schluessel, wert);
  } catch (_) {}
}

void tabLoeschen(String schluessel) {
  try {
    _sitzung.removeItem(schluessel);
  } catch (_) {}
}
