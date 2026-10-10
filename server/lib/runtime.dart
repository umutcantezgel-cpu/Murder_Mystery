/// Austauschbare Spiel-Runtime für den Server.
///
/// Produktion: [CoreRuntime] um die echte `RoomRuntime` aus `mordakte_core`.
/// Tests/Smoke: eine eigene Fake-Implementierung von [GameRuntime].
library;

import 'package:mordakte_core/mordakte_core.dart';

/// Gemeinsamer Lebenszyklus klassischer Räume und geführter Partyabende.
abstract interface class ManagedRuntime {
  /// Spieler-IDs (ohne Bots).
  List<String> get humanPlayers;

  bool get finished;

  /// Noch in der Lobby (Partie nicht gestartet).
  bool get inLobby;

  bool join(String playerId, String name);

  void leave(String playerId);

  void setConnected(String playerId, bool connected);

  void tick(int dtMs);

  List<GameEvent> drainEvents(String playerId);
}

/// Unveränderte Welt-/Fallansichten der klassischen RoomRuntime.
abstract interface class GameRuntime implements ManagedRuntime {
  void applyMove(String playerId, MoveInput move);
  void applyCommand(String playerId, Command command);
  WorldSnapshot worldFor(String playerId);
  CaseView? caseFor(String playerId, {bool force = false});
}

/// Eigene, ausdrücklich pro Empfänger zusammengesetzte Abendansichten.
abstract interface class AbendRuntime implements ManagedRuntime {
  String get abend;
  int get maxPlayers;
  Map<String, Object?>? stateFor(String playerId, {bool force = false});

  /// null = angenommen, sonst ein fester Fehler-Schlüssel ohne Nutzdaten.
  String? applyAbendCommand(String playerId, Map<String, Object?> command);
}

/// Erzeugt die Runtime für einen neuen Raum.
typedef RuntimeFactory = ManagedRuntime Function(String roomCode);

/// Adapter auf die echte [RoomRuntime].
class CoreRuntime implements GameRuntime {
  CoreRuntime(this.inner);

  final RoomRuntime inner;

  @override
  List<String> get humanPlayers => inner.humanPlayers;

  @override
  bool get finished => inner.finished;

  @override
  bool get inLobby => inner.inLobby;

  @override
  bool join(String playerId, String name) => inner.join(playerId, name);

  @override
  void leave(String playerId) => inner.leave(playerId);

  @override
  void setConnected(String playerId, bool connected) => inner.setConnected(playerId, connected);

  @override
  void applyMove(String playerId, MoveInput move) => inner.applyMove(playerId, move);

  @override
  void applyCommand(String playerId, Command command) => inner.applyCommand(playerId, command);

  @override
  void tick(int dtMs) => inner.tick(dtMs);

  @override
  WorldSnapshot worldFor(String playerId) => inner.worldFor(playerId);

  @override
  CaseView? caseFor(String playerId, {bool force = false}) => inner.caseFor(playerId, force: force);

  @override
  List<GameEvent> drainEvents(String playerId) => inner.drainEvents(playerId);
}

/// Produktions-Fabrik: eine echte [RoomRuntime] pro Raumcode.
RuntimeFactory coreRuntimeFactory(Map<String, ScenarioDef> scenarios) =>
    (code) => CoreRuntime(RoomRuntime(roomCode: code, scenarios: scenarios));
