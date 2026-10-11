import 'package:flutter/foundation.dart';
import 'package:mordakte_netz/mordakte_netz.dart';

/// Das Relais dieser Seite. Standard ist das Relais des Netzpakets (Supabase,
/// einstellbar mit `--dart-define=MORDAKTE_RELAY_URL=…`). Nur zum lokalen Prüfen
/// im Browser: `?relay=ws://127.0.0.1:<port>` vor dem `#` der Adresse nimmt die
/// lokale Attrappe, aber ausschließlich, wenn die Seite selbst von `127.0.0.1`
/// oder `localhost` kommt; auf einer echten Adresse wird der Parameter ignoriert.
String? relayUeberschreibung([Uri? seite]) {
  if (!kIsWeb && seite == null) return null;
  final Uri u;
  try {
    u = seite ?? Uri.base;
  } catch (_) {
    return null;
  }
  if (u.host != '127.0.0.1' && u.host != 'localhost') return null;
  final wert = u.queryParameters['relay'];
  if (wert == null || wert.trim().isEmpty) return null;
  final r = Uri.tryParse(wert.trim());
  if (r == null || !{'ws', 'wss', 'http', 'https'}.contains(r.scheme) || r.host.isEmpty) return null;
  return wert.trim();
}

/// Relais-Parameter dieser Seite (siehe [relayUeberschreibung]).
RelayParameter relayFuerSeite([Uri? seite]) {
  final url = relayUeberschreibung(seite);
  return url == null ? const RelayParameter() : RelayParameter(url: url);
}

/// Beitrittsadresse für den QR-Code im Web: diese Seite mit
/// `#/beitreten?raum=<CODE>`; im Browser mit lokalem Relais bleibt `?relay=`
/// erhalten, damit auch der Gast an dieselbe Attrappe kommt. Auf Handys und ohne
/// Webadresse `null` (der QR-Code enthält dann nur den Code).
String? beitrittsLink(String code, [Uri? seite]) {
  if (!kIsWeb && seite == null) return null;
  final Uri u;
  try {
    u = seite ?? Uri.base;
  } catch (_) {
    return null;
  }
  if (!u.hasScheme || u.host.isEmpty || !{'http', 'https'}.contains(u.scheme)) return null;
  final relay = relayUeberschreibung(u);
  final basis = Uri(
    scheme: u.scheme,
    host: u.host,
    port: u.hasPort ? u.port : null,
    path: u.path.isEmpty ? '/' : u.path,
    queryParameters: relay == null ? null : {'relay': relay},
  );
  return '$basis#/beitreten?raum=$code';
}

/// Raumcode zum Anzeigen: `ABC-DEF`.
String raumCodeAnzeige(String code) => code.length == 6 ? '${code.substring(0, 3)}-${code.substring(3)}' : code;
