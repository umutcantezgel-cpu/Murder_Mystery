/// Eine WebSocket-Verbindung zu einer App.
library;

import 'dart:async';
import 'dart:convert';

import 'package:mordakte_core/mordakte_core.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'codes.dart';
import 'rooms.dart';
import 'wire.dart';

/// Maximale Länge des Spielernamens (Zeichen).
const maxNameLength = 20;

/// Bereinigt den Spielernamen aus `hello`.
String sanitizeName(Object? raw) {
  if (raw is! String) return 'Detektiv';
  final cleaned = raw.replaceAll(RegExp(r'[\u0000-\u001f\u007f]'), '').replaceAll(RegExp(r'\s+'), ' ').trim();
  if (cleaned.isEmpty) return 'Detektiv';
  final runes = cleaned.runes.toList();
  return runes.length <= maxNameLength ? cleaned : String.fromCharCodes(runes.take(maxNameLength)).trim();
}

class Connection implements ClientLink {
  Connection(
    this._channel,
    this._rooms, {
    required this.label,
    this.maxMessageBytes = 8 * 1024,
    this.maxMessagesPerSecond = 40,
    this.onClosed,
  });

  final WebSocketChannel _channel;
  final RoomManager _rooms;

  @override
  final String label;
  final int maxMessageBytes;
  final int maxMessagesPerSecond;

  /// Wird einmal aufgerufen, wenn der Socket zu ist (z. B. Verbindungszähler).
  final void Function()? onClosed;

  Player? _player;
  bool _closed = false;
  StreamSubscription<dynamic>? _sub;

  final Stopwatch _rateClock = Stopwatch()..start();
  int _windowStartMs = 0;
  int _windowCount = 0;
  int _dropped = 0;

  /// Der Spieler dieser Verbindung – nur, solange sie seine aktive Verbindung ist.
  Player? get player {
    final p = _player;
    return p != null && identical(p.link, this) ? p : null;
  }

  void start() {
    _sub = _channel.stream.listen(
      _onData,
      onDone: _onDone,
      onError: (Object e) => _rooms.log('$label: Socket-Fehler: $e'),
      cancelOnError: false,
    );
  }

  @override
  void send(String text) {
    if (_closed) return;
    try {
      _channel.sink.add(text);
    } catch (_) {
      _closed = true;
    }
  }

  @override
  void close(int code, String reason) {
    if (_closed) return;
    _closed = true;
    unawaited(_channel.sink.close(code, reason).catchError((_) {}));
  }

  void _onDone() {
    _closed = true;
    unawaited(_sub?.cancel());
    onClosed?.call();
    final p = _player;
    _player = null;
    if (p != null) _rooms.disconnected(p, this);
  }

  bool _allow() {
    final now = _rateClock.elapsedMilliseconds;
    if (now - _windowStartMs >= 1000) {
      if (_dropped > 0) _rooms.log('$label: $_dropped Nachrichten verworfen (Rate-Limit)');
      _windowStartMs = now;
      _windowCount = 0;
      _dropped = 0;
    }
    if (++_windowCount > maxMessagesPerSecond) {
      _dropped++;
      return false;
    }
    return true;
  }

  bool _tooLarge(String text) {
    if (text.length > maxMessageBytes) return true;
    // Bis zu 3 Bytes pro UTF-16-Einheit: nur im Grenzbereich genau zählen.
    return text.length * 3 > maxMessageBytes && utf8.encode(text).length > maxMessageBytes;
  }

  void _onData(dynamic data) {
    if (_closed || !_allow()) return;
    if (data is! String || _tooLarge(data)) {
      send(encodeError(NetError.badMessage));
      return;
    }
    final Map<String, dynamic> msg;
    try {
      final decoded = jsonDecode(data);
      if (decoded is! Map<String, dynamic>) throw const FormatException('kein Objekt');
      msg = decoded;
    } on FormatException {
      send(encodeError(NetError.badMessage));
      return;
    }
    try {
      _handle(msg);
    } catch (e, st) {
      if (e is FormatException || e is TypeError || e is ArgumentError) {
        send(encodeError(NetError.badMessage));
      } else {
        _rooms.log('$label: Fehler bei "${msg['t']}": $e\n$st');
        send(encodeError(ServerError.internal));
      }
    }
  }

  void _handle(Map<String, dynamic> msg) {
    final type = msg['t'];
    switch (type) {
      case Msg.hello:
        _hello(msg);
        return;
      case Msg.ping:
        send(encodeMsg({'t': Msg.pong, 'n': msg['n']}));
        return;
    }
    final p = player;
    if (p == null) {
      // Erst `hello`, dann alles andere.
      if (type != Msg.move) send(encodeError(NetError.protocol));
      return;
    }
    switch (type) {
      case Msg.create:
        _rooms.create(p, abend: msg['abend']);
      case Msg.join:
        _rooms.join(p, msg['code']);
      case Msg.leave:
        _rooms.leave(p);
      case Msg.cmd:
        _rooms.command(p, Command.fromJson(msg['c'] as Map<String, dynamic>));
      case Msg.abendCmd:
        final command = msg['c'];
        if (command is! Map<String, dynamic>) throw const FormatException('ungültiger Abendbefehl');
        _rooms.abendCommand(p, command);
      case Msg.move:
        final move = MoveInput.fromJson(msg);
        if (!move.x.isFinite || !move.y.isFinite || !move.facing.isFinite) {
          throw const FormatException('ungültige Bewegung');
        }
        _rooms.move(p, move);
      default:
        send(encodeError(NetError.badMessage));
    }
  }

  void _hello(Map<String, dynamic> msg) {
    final proto = msg['proto'];
    if (proto != null && proto != protocolVersion) {
      send(encodeError(NetError.protocol));
      return;
    }
    final rawToken = msg['token'];
    final token = isWellFormedToken(rawToken) ? rawToken as String : null;
    final current = player;
    if (current != null && current.token != token) {
      // Zweites `hello` mit anderer Identität auf derselben Verbindung: abgelehnt
      // (sonst erzeugt ein Socket beliebig viele Spieler). Die App schickt `hello`
      // genau einmal pro Socket.
      send(encodeError(NetError.protocol));
      return;
    }
    // `resume: false` = erster Aufbau der App; fehlt das Feld, wie bisher fortsetzen.
    final p = _rooms.hello(this, token: token, name: sanitizeName(msg['name']), resume: msg['resume'] != false);
    if (p != null) _player = p;
  }
}
