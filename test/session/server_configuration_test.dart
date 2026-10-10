import 'package:flutter_test/flutter_test.dart';
import 'package:mordakte/session/online_session.dart';
import 'package:mordakte/session/server_configuration.dart';

void main() {
  test(
    'Kein localhost-Standard; eine konfigurierte Adresse muss öffentlich sein',
    () {
      expect(
        defaultServerUrl.isEmpty || publicServerUri(defaultServerUrl) != null,
        isTrue,
      );
    },
  );

  test('Verschlüsselte öffentliche Adresse mit Serverpfad', () {
    expect(
      publicServerUri('wss://mordakte.example.org/ws')?.host,
      'mordakte.example.org',
    );
    expect(publicServerUri('wss://mordakte.example.org:8443/ws')?.port, 8443);
  });

  for (final value in [
    '',
    'https://mordakte.example.org/ws',
    'ws://mordakte.example.org/ws',
    'wss://localhost/ws',
    'wss://localhost./ws',
    'wss://game.localhost/ws',
    'wss://127.0.0.1/ws',
    'wss://127.3.4.5/ws',
    'wss://0.0.0.0/ws',
    'wss://[::1]/ws',
    'wss://[::]/ws',
    'wss://[0:0:0:0:0:0:0:1]/ws',
    'wss://[::ffff:127.0.0.1]/ws',
    'wss://[::ffff:7f00:1]/ws',
    'wss://name@example.org/ws',
    'wss://example.org/ws?auth=fixture',
    'wss://example.org/ws#fragment',
    'wss://example.org/wrong',
    'wss://example.org:0/ws',
    'wss://example.org:99999/ws',
    'wss://[broken/ws',
    'wss://exa mple.org/ws',
  ]) {
    test('Ungültige oder lokale Konfiguration wird abgewiesen: $value', () {
      expect(publicServerUri(value), isNull);
    });
  }

  test(
    'Fehlende Konfiguration scheitert vor Socket- und Speicherzugriff',
    () async {
      await expectLater(
        OnlineSession.connect(url: '', playerName: 'Test', scenarios: const {}),
        throwsA(
          isA<OnlineSessionException>().having(
            (error) => error.key,
            'key',
            'server_missing',
          ),
        ),
      );
    },
  );

  test(
    'Auch ein gespeicherter alter localhost-Wert öffnet keinen Socket',
    () async {
      await expectLater(
        OnlineSession.connect(
          url: 'ws://localhost:8080/ws',
          playerName: 'Test',
          scenarios: const {},
        ),
        throwsA(
          isA<OnlineSessionException>().having(
            (error) => error.key,
            'key',
            'server_invalid',
          ),
        ),
      );
    },
  );
}
