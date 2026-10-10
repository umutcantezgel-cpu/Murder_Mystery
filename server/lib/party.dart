/// Adapter des gemeinsamen, transportfreien Schlosskeller-Abends auf den
/// vorhandenen Server-Lebenszyklus. Authentifizierung und Reconnect bleiben im
/// RoomManager, private Daten bleiben in der Empfänger-Projektion des Kerns.
library;

import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:mordakte_core/mordakte_core.dart';
import 'package:mordakte_core/runden.dart';

import 'runtime.dart';

class SchlosskellerRuntime implements AbendRuntime {
  SchlosskellerRuntime(this.inner);
  final SchlosskellerRaum inner;
  final Map<String, int> _gesendet = {};

  @override
  String get abend => 'schlosskeller';
  @override
  int get maxPlayers => inner.maxSpieler;
  @override
  List<String> get humanPlayers => inner.spielerIds;
  @override
  bool get inLobby => inner.vorStart;
  @override
  bool get finished => inner.beendet;
  @override
  bool join(String playerId, String name) => inner.beitreten(playerId, name);
  @override
  void leave(String playerId) { inner.verlassen(playerId); _gesendet.remove(playerId); }
  @override
  void setConnected(String playerId, bool connected) => inner.verbunden(playerId, connected);
  @override
  void tick(int dtMs) {} // Entscheidungen treiben den Abend, nicht die Wandzeit.
  @override
  List<GameEvent> drainEvents(String playerId) => const [];

  @override
  Map<String, Object?>? stateFor(String playerId, {bool force = false}) {
    if (!force && _gesendet[playerId] == inner.version) return null;
    final state = inner.zustandFuer(playerId);
    _gesendet[playerId] = inner.version;
    return state;
  }

  @override
  String? applyAbendCommand(String playerId, Map<String, Object?> command) {
    try {
      inner.nachricht(playerId, command);
      return null;
    } on PartyRaumFehler catch (error) {
      return error.code;
    }
  }
}

String resolvePartyDir(String? fromEnv) {
  if (fromEnv != null && fromEnv.trim().isNotEmpty) return fromEnv.trim();
  for (final path in [
    '/app/content/party/schlosskeller',
    if (Platform.script.scheme == 'file') Platform.script.resolve('../../content/party/schlosskeller').toFilePath(),
    '../content/party/schlosskeller',
    'content/party/schlosskeller',
  ]) {
    if (Directory(path).existsSync()) return Directory(path).absolute.path;
  }
  throw const FormatException('Schlosskeller-Kanon fehlt; PARTY_DIR muss auf den Kanonordner zeigen.');
}

/// Liest nur die vom Kanon/Textindex vorgegebenen Dateien. Kein Dateipfad und
/// kein Fall-Code stammen aus einer Client-Nachricht. Kein Fallback-Spiel, falls
/// die Deployment-Dateien fehlen: Der Server soll dann nicht bereit melden.
RuntimeFactory loadSchlosskellerFactory(String dir) {
  Map<String, Object?> lesen(String path) => (jsonDecode(File('$dir/$path').readAsStringSync()) as Map).cast<String, Object?>();
  final kanon = Kanon.lade(lesen);
  final texte = Texte(kanon, Textsammlung.lade(lesen));
  final zufall = Random.secure();
  return (roomCode) => SchlosskellerRuntime(SchlosskellerRaum(
    raumCode: roomCode, kanon: kanon, texte: texte,
    fallCode: FallCode.zufall(Rng(zufall.nextInt(1 << 32))),
    salz: [for (var i = 0; i < 32; i++) zufall.nextInt(256).toRadixString(16).padLeft(2, '0')].join(),
  ));
}
