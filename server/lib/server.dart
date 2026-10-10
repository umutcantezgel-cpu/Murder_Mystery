/// HTTP-Einstieg: `GET /health` und WebSocket unter `/ws`.
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'connection.dart';
import 'rooms.dart';

/// Größte eingehende WebSocket-Nachricht auf Transportebene (Bytes, auch über
/// Fragmente summiert). Größeres wird schon vor dem Puffern abgebrochen; die
/// feinere Grenze der App-Nachrichten prüft `Connection` (8 KB → `bad_message`).
const maxFrameBytes = 16 * 1024;

/// Shelf-Handler für den Mordakte-Server.
///
/// [maxConnections] / [maxConnectionsPerAddress]: offene `/ws`-Sockets insgesamt bzw.
/// pro Client-Adresse. [trustProxy]: Client-Adresse aus `X-Real-IP` bzw. dem letzten
/// Eintrag von `X-Forwarded-For` (vom vorgeschalteten Proxy gesetzt) statt der
/// TCP-Gegenstelle.
Handler createHandler(
  RoomManager rooms, {
  Duration pingInterval = const Duration(seconds: 20),
  int maxConnections = 10000,
  // 20 Gäste plus Detektiv hinter derselben NAT-Adresse, mit Reconnect-Reserve.
  int maxConnectionsPerAddress = 42,
  bool trustProxy = true,
}) {
  var connections = 0;
  var open = 0;
  final perAddress = <String, int>{};
  return (Request request) {
    switch (request.url.path) {
      case 'health':
        return Response.ok('ok rooms=${rooms.roomCount} players=${rooms.onlineCount}\n');
      case 'ws':
        final address = _clientAddress(request, trustProxy: trustProxy);
        final label = '#${++connections} $address';
        if (open >= maxConnections || (perAddress[address] ?? 0) >= maxConnectionsPerAddress) {
          rooms.log('$label: abgewiesen (zu viele Verbindungen: $open offen, '
              '${perAddress[address] ?? 0} von dieser Adresse)');
          return Response(503, body: 'too many connections\n');
        }
        // Schon vor dem Upgrade zählen, damit ein Schwall von Anfragen die Grenze nicht überholt.
        open++;
        perAddress[address] = (perAddress[address] ?? 0) + 1;
        var released = false;
        void release() {
          if (released) return;
          released = true;
          open--;
          final n = (perAddress[address] ?? 1) - 1;
          if (n <= 0) {
            perAddress.remove(address);
          } else {
            perAddress[address] = n;
          }
        }

        final Response refused;
        try {
          refused = _upgrade(request, (socket) {
            final guarded = _FrameGuardSocket(socket, maxFrameBytes, () {
              rooms.log('$label: Nachricht über ${maxFrameBytes ~/ 1024} KB – Verbindung getrennt');
            });
            final ws = WebSocket.fromUpgradedSocket(guarded, serverSide: true, maxPayloadLength: maxFrameBytes)
              ..pingInterval = pingInterval;
            Connection(IOWebSocketChannel(ws), rooms, label: label, onClosed: release).start();
          }, onFailed: release);
        } on HijackException {
          rethrow;
        } catch (_) {
          release();
          rethrow;
        }
        release();
        return refused;
      case '':
        return Response.ok('Mordakte-Server – WebSocket: /ws, Status: /health\n');
      default:
        return Response.notFound('not found\n');
    }
  };
}

/// Startet den HTTP-Server auf allen Interfaces. [port] 0 = freier Port.
Future<HttpServer> serveMordakte(
  RoomManager rooms, {
  int port = 8080,
  Duration? pingInterval,
  bool trustProxy = true,
}) =>
    shelf_io.serve(
      pingInterval == null
          ? createHandler(rooms, trustProxy: trustProxy)
          : createHandler(rooms, pingInterval: pingInterval, trustProxy: trustProxy),
      InternetAddress.anyIPv4,
      port,
    );

/// WebSocket-Handshake wie `shelf_web_socket`, aber mit eigener Socket-Übernahme
/// (Größenbegrenzung vor dem Puffern). Gibt bei ungültigen Anfragen eine Antwort
/// zurück; sonst wirft `request.hijack` eine [HijackException].
Response _upgrade(
  Request request,
  void Function(Socket socket) onSocket, {
  required void Function() onFailed,
}) {
  if (request.method != 'GET') return _wsOnly();
  final connection = request.headers['Connection'];
  if (connection == null) return _wsOnly();
  if (!connection.toLowerCase().split(',').map((t) => t.trim()).contains('upgrade')) return _wsOnly();
  if (request.headers['Upgrade']?.toLowerCase() != 'websocket') return _wsOnly();
  final version = request.headers['Sec-WebSocket-Version'];
  if (version == null) return Response(400, body: 'missing Sec-WebSocket-Version\n');
  if (version != '13') return _wsOnly();
  if (request.protocolVersion != '1.1') return Response(400, body: 'unexpected HTTP version\n');
  final key = request.headers['Sec-WebSocket-Key'];
  if (key == null) return Response(400, body: 'missing Sec-WebSocket-Key\n');
  if (!request.canHijack) throw StateError('/ws braucht einen Server mit Request-Hijacking.');

  request.hijack((channel) {
    final sink = channel.sink;
    if (sink is! Socket) {
      onFailed();
      return;
    }
    try {
      sink.add(utf8.encode('HTTP/1.1 101 Switching Protocols\r\n'
          'Upgrade: websocket\r\n'
          'Connection: Upgrade\r\n'
          'Sec-WebSocket-Accept: ${WebSocketChannel.signKey(key)}\r\n'
          '\r\n'));
      onSocket(sink);
    } catch (_) {
      onFailed();
      sink.destroy();
    }
  });
}

Response _wsOnly() => Response.notFound('Only WebSocket connections are supported.\n');

String _clientAddress(Request request, {required bool trustProxy}) {
  if (trustProxy) {
    final real = request.headers['x-real-ip']?.trim();
    if (real != null && real.isNotEmpty) return real;
    final forwarded = request.headers['x-forwarded-for'];
    if (forwarded != null && forwarded.isNotEmpty) {
      // Letzter Eintrag = vom nächsten (vertrauenswürdigen) Proxy angehängt; die
      // vorderen kann der Client selbst mitschicken.
      final last = forwarded.split(',').last.trim();
      if (last.isNotEmpty) return last;
    }
  }
  final info = request.context['shelf.io.connection_info'];
  return info is HttpConnectionInfo ? info.remoteAddress.address : '?';
}

/// Prüft die Rahmenköpfe eingehender (maskierter) WebSocket-Daten, bevor dart:io
/// sie zu einer Nachricht zusammensetzt. `maxPayloadLength` begrenzt nur einzelne
/// Rahmen; Fortsetzungsrahmen würden ohne diese Summe unbegrenzt gepuffert.
class FrameGuard {
  FrameGuard(this.maxMessageBytes);

  final int maxMessageBytes;

  final List<int> _header = [];
  int _headerLength = 2;
  int _payloadLeft = 0;
  int _messageBytes = 0;

  /// `false`, sobald eine Nachricht (Summe ihrer Datenrahmen) zu groß ist.
  bool check(List<int> chunk) {
    var i = 0;
    while (i < chunk.length) {
      if (_payloadLeft > 0) {
        final n = chunk.length - i < _payloadLeft ? chunk.length - i : _payloadLeft;
        _payloadLeft -= n;
        i += n;
        continue;
      }
      _header.add(chunk[i++]);
      if (_header.length < _headerLength) continue;
      final len7 = _header[1] & 0x7f;
      if (_header.length == 2) {
        _headerLength = 2 + (len7 == 126 ? 2 : (len7 == 127 ? 8 : 0)) + ((_header[1] & 0x80) != 0 ? 4 : 0);
        if (_header.length < _headerLength) continue;
      }
      int length;
      if (len7 == 126) {
        length = (_header[2] << 8) | _header[3];
      } else if (len7 == 127) {
        // Alles ab 2^32 ist ohnehin zu groß.
        if (_header[2] | _header[3] | _header[4] | _header[5] != 0) return false;
        length = (_header[6] << 24) | (_header[7] << 16) | (_header[8] << 8) | _header[9];
      } else {
        length = len7;
      }
      final opcode = _header[0] & 0x0f;
      final fin = (_header[0] & 0x80) != 0;
      if (opcode < 8) {
        // Daten- oder Fortsetzungsrahmen (Steuerrahmen dürfen dazwischen stehen).
        _messageBytes += length;
        if (_messageBytes > maxMessageBytes) return false;
        if (fin) _messageBytes = 0;
      } else if (length > 125) {
        return false;
      }
      _header.clear();
      _headerLength = 2;
      _payloadLeft = length;
    }
    return true;
  }
}

/// Socket-Hülle: leitet alles durch, lässt eingehende Daten aber erst durch [FrameGuard].
class _FrameGuardSocket extends Stream<Uint8List> implements Socket {
  _FrameGuardSocket(this._inner, int maxMessageBytes, this._onViolation) : _guard = FrameGuard(maxMessageBytes);

  final Socket _inner;
  final FrameGuard _guard;
  final void Function() _onViolation;
  bool _blocked = false;

  @override
  StreamSubscription<Uint8List> listen(
    void Function(Uint8List event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) =>
      _inner
          .transform(StreamTransformer<Uint8List, Uint8List>.fromHandlers(handleData: (data, sink) {
            if (_blocked) return;
            if (!_guard.check(data)) {
              _blocked = true;
              _onViolation();
              _inner.destroy();
              return;
            }
            sink.add(data);
          }))
          .listen(onData, onError: onError, onDone: onDone, cancelOnError: cancelOnError);

  @override
  Encoding get encoding => _inner.encoding;

  @override
  set encoding(Encoding value) => _inner.encoding = value;

  @override
  void add(List<int> data) => _inner.add(data);

  @override
  void addError(Object error, [StackTrace? stackTrace]) => _inner.addError(error, stackTrace);

  @override
  Future<void> addStream(Stream<List<int>> stream) => _inner.addStream(stream);

  @override
  Future<void> flush() => _inner.flush();

  @override
  Future<void> close() => _inner.close();

  @override
  Future<void> get done => _inner.done;

  @override
  void write(Object? object) => _inner.write(object);

  @override
  void writeAll(Iterable<Object?> objects, [String separator = '']) => _inner.writeAll(objects, separator);

  @override
  void writeln([Object? object = '']) => _inner.writeln(object);

  @override
  void writeCharCode(int charCode) => _inner.writeCharCode(charCode);

  @override
  void destroy() => _inner.destroy();

  @override
  bool setOption(SocketOption option, bool enabled) => _inner.setOption(option, enabled);

  @override
  Uint8List getRawOption(RawSocketOption option) => _inner.getRawOption(option);

  @override
  void setRawOption(RawSocketOption option) => _inner.setRawOption(option);

  @override
  InternetAddress get address => _inner.address;

  @override
  int get port => _inner.port;

  @override
  InternetAddress get remoteAddress => _inner.remoteAddress;

  @override
  int get remotePort => _inner.remotePort;
}
