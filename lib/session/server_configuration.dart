/// Öffentliche Deployment-Konfiguration. Ohne Freigabe bleibt Online sichtbar,
/// aber öffnet keine Verbindung; insbesondere gibt es keinen localhost-Fallback.
const defaultServerUrl = String.fromEnvironment('MORDAKTE_SERVER');

/// Nur verschlüsselter Internet-WebSocket am Server-Endpunkt /ws.
/// Zugangsdaten gehören nie in diese öffentliche, in die App eingebettete URL.
Uri? publicServerUri(String value) {
  if (value.isEmpty ||
      value.contains(RegExp(r'\s')) ||
      RegExp(r'^wss://[^/?#]+:0+/', caseSensitive: false).hasMatch(value)) {
    return null;
  }
  final uri = Uri.tryParse(value);
  if (uri == null ||
      uri.scheme != 'wss' ||
      uri.host.isEmpty ||
      uri.path != '/ws' ||
      uri.userInfo.isNotEmpty ||
      uri.hasQuery ||
      uri.hasFragment ||
      (uri.hasPort && (uri.port <= 0 || uri.port > 65535))) {
    return null;
  }
  final host = uri.host.toLowerCase().replaceAll(RegExp(r'^\[|\]$|\.$'), '');
  if (host == 'localhost' ||
      host.endsWith('.localhost') ||
      host == '0.0.0.0' ||
      RegExp(r'^127(?:\.|$)').hasMatch(host)) {
    return null;
  }
  // IPv6-Schleifenadressen einschließlich langer und IPv4-abgebildeter Form.
  if (host.contains(':')) {
    final bytes = Uri.parseIPv6Address(host);
    if (bytes.take(15).every((byte) => byte == 0) && bytes.last <= 1) {
      return null;
    }
    final mapped =
        bytes.take(10).every((byte) => byte == 0) &&
        bytes[10] == 255 &&
        bytes[11] == 255;
    if (mapped &&
        (bytes[12] == 127 || bytes.skip(12).every((byte) => byte == 0))) {
      return null;
    }
  }
  return uri;
}
