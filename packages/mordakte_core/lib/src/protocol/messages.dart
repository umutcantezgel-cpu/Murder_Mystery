/// WebSocket-Umschlag zwischen App und Server (JSON-Text-Frames).
///
/// Client → Server:
///   {"t":"hello","name":"Anna","token":"…optional…","proto":1}
///   {"t":"create"} oder {"t":"create","abend":"schlosskeller"}
///   {"t":"abend_cmd","c":{"typ":"bereit","wert":true}}
///   {"t":"join","code":"KX4T"}
///   {"t":"leave"}
///   {"t":"cmd","c":{…Command.toJson()…}}
///   {"t":"mv", …MoveInput.toJson()…}
///   {"t":"ping","n":42}
///
/// Server → Client:
///   {"t":"welcome","player":"p_…","token":"…"}
///   {"t":"room","code":"KX4T"}
///   {"t":"err","key":"room_not_found"}
///   {"t":"w","wt":12345, …WorldSnapshot.toJson() ohne "t"…}  (Laufzeit unter "wt", siehe server/lib/wire.dart)
///   {"t":"c", …CaseView.toJson()…}
///   {"t":"ev","list":[…GameEvent.toJson()…]}
///   {"t":"pong","n":42}
library;

const protocolVersion = 1;

abstract final class Msg {
  // Client → Server
  static const hello = 'hello';
  static const create = 'create';
  static const join = 'join';
  static const leave = 'leave';
  static const cmd = 'cmd';
  static const abendCmd = 'abend_cmd';
  static const move = 'mv';
  static const ping = 'ping';

  // Server → Client
  static const welcome = 'welcome';
  static const room = 'room';
  static const error = 'err';
  static const world = 'w';
  static const caseView = 'c';
  static const abend = 'abend';
  static const events = 'ev';
  static const pong = 'pong';
}

/// Fehler-Schlüssel (App übersetzt `error_<key>`).
abstract final class NetError {
  static const roomNotFound = 'room_not_found';
  static const roomFull = 'room_full';
  static const gameRunning = 'game_running';
  static const badMessage = 'bad_message';
  static const notInRoom = 'not_in_room';
  static const protocol = 'protocol';
}

const maxPlayersPerRoom = 6;
