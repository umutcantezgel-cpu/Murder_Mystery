import 'package:mordakte_core/mordakte_core.dart';

import 'fake_session.dart';
import 'game_session.dart';
import 'local_session.dart';
import 'online_session.dart';

import 'server_configuration.dart';

export 'server_configuration.dart' show defaultServerUrl;

/// Erzeugt Sessions. Die Lobby-Phase läuft in beiden Modi in der Session:
/// Solo → Lobby (KI-Partner, Klasse) → Start; Online → Raum erstellen/beitreten → Lobby → Start.
class SessionFactory {
  /// Offline-Solo: Runtime läuft im Prozess, der Spieler ist Host.
  static Future<GameSession> solo({
    required Map<String, ScenarioDef> scenarios,
    required String playerName,
    bool autoplay = false,
    double timeScale = 1,
  }) async {
    return LocalSession(scenarios: scenarios, playerName: playerName, autoplay: autoplay, timeScale: timeScale);
  }

  /// Online: [roomCode] == null → neuen Raum erstellen.
  static Future<GameSession> online({
    required Map<String, ScenarioDef> scenarios,
    required String playerName,
    String? roomCode,
    String serverUrl = defaultServerUrl,
  }) async {
    return OnlineSession.connect(url: serverUrl, playerName: playerName, scenarios: scenarios, roomCode: roomCode);
  }

  /// Raumcode einer nicht verlassenen Online-Partie (z. B. nach Neuladen des Tabs),
  /// sonst `null`. Rückkehr: [online] mit diesem `roomCode` – der Server erkennt
  /// das gespeicherte Token und gibt den gehaltenen Platz zurück.
  static Future<String?> storedOnlineRoom() => OnlineSession.storedRoomCode();

  static GameSession fake() => FakeSession();
}
