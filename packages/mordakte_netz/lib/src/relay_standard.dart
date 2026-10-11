/// Standardwerte des Relais (Supabase Realtime). Beides sind öffentliche Werte
/// (Projekt-URL und veröffentlichbarer Schlüssel), also kein Geheimnis. Mit
/// `--dart-define=MORDAKTE_RELAY_URL=…` und `MORDAKTE_RELAY_KEY=…` lässt sich
/// ein anderes Relais einstellen (Tests, eigenes Projekt, lokale Attrappe).
library;

import 'package:web_socket_channel/web_socket_channel.dart';

const relayUrl = String.fromEnvironment(
  'MORDAKTE_RELAY_URL',
  defaultValue: 'https://vuiyymgnkuilkbmxvcxo.supabase.co',
);

const relaySchluessel = String.fromEnvironment(
  'MORDAKTE_RELAY_KEY',
  defaultValue: 'sb_publishable_VXH5oe02tG9hLrNlrI2jAQ_j4WhnX88',
);

/// Öffnet die WebSocket-Verbindung; austauschbar für Tests.
typedef KanalFabrik = WebSocketChannel Function(Uri uri);

/// Baut die Socket-Adresse: `wss://<ref>.supabase.co/realtime/v1/websocket?apikey=<key>&vsn=1.0.0`.
/// `http`/`https`-Adressen werden zu `ws`/`wss` (lokale Attrappe: `http://127.0.0.1:port`).
Uri relaySocketUri({String url = relayUrl, String schluessel = relaySchluessel}) {
  final u = Uri.parse(url);
  final ws = switch (u.scheme) {
    'https' || 'wss' => 'wss',
    'http' || 'ws' => 'ws',
    _ => throw FormatException('Unbekanntes Schema für das Relais: ${u.scheme}'),
  };
  final basis = u.path.endsWith('/') ? u.path.substring(0, u.path.length - 1) : u.path;
  return Uri(
    scheme: ws,
    host: u.host,
    port: u.hasPort ? u.port : null,
    path: '$basis/realtime/v1/websocket',
    queryParameters: {'apikey': schluessel, 'vsn': '1.0.0'},
  );
}

/// Alles, was ein Gerät braucht, um ans Relais zu kommen.
class RelayParameter {
  const RelayParameter({this.url = relayUrl, this.schluessel = relaySchluessel, this.fabrik});

  final String url;
  final String schluessel;

  /// Standard: [WebSocketChannel.connect] (VM und Web).
  final KanalFabrik? fabrik;

  Uri get socketUri => relaySocketUri(url: url, schluessel: schluessel);

  KanalFabrik get kanalFabrik => fabrik ?? WebSocketChannel.connect;
}
