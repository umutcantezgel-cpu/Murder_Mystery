/// Echte TCP/WebSocket-Clients gegen den Produktions-Handler und die echte Engine.
/// Lokal: dart run tool/online_matrix.dart
/// Öffentlich: dart run tool/online_matrix.dart --url=wss://<freigegebener-host>/ws
/// 4–20 gleichzeitige Clients, klassische Räume mit höchstens sechs Detektiven.
/// Kein Beleg für einen 20-Personen-Partyraum oder private Party-Rollenkarten.
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:mordakte_core/mordakte_core.dart';
import 'package:mordakte_server/rooms.dart';
import 'package:mordakte_server/runtime.dart';
import 'package:mordakte_server/scenarios.dart';
import 'package:mordakte_server/server.dart';
import 'package:mordakte_server/wire.dart';

import 'smoke.dart' show Client;

void _require(bool condition, String label) {
  if (!condition) throw StateError(label);
}

Future<void> _health(Uri socket) async {
  final client = HttpClient();
  try {
    final uri = socket.replace(
      scheme: socket.scheme == 'wss' ? 'https' : 'http',
      path: '/health',
    );
    final request = await client
        .getUrl(uri)
        .timeout(const Duration(seconds: 10));
    final response = await request.close().timeout(const Duration(seconds: 10));
    final body = await response
        .transform(utf8.decoder)
        .join()
        .timeout(const Duration(seconds: 10));
    _require(
      response.statusCode == 200 && body.startsWith('ok rooms='),
      'Healthcheck muss HTTP 200 und den Mordakte-Status liefern.',
    );
  } finally {
    client.close(force: true);
  }
}

Future<void> _batch(Uri url, int count, String scenario) async {
  final clients = <Client>[];
  final groups = <(String, List<Client>)>[];
  try {
    for (var i = 0; i < count; i++) {
      final client = await Client.connect(
        url.toString(),
        'Pruefung-$count-$i',
      ).timeout(const Duration(seconds: 10));
      clients.add(client);
      await client.hello();
    }
    _require(
      clients.map((client) => client.playerId).toSet().length == count,
      'Jedes Gerät braucht eine eigene Spieler-ID.',
    );

    for (var offset = 0; offset < count; offset += maxPlayersPerRoom) {
      final group = clients.sublist(
        offset,
        math.min(offset + maxPlayersPerRoom, count),
      );
      final host = group.first;
      host.send({'t': Msg.create});
      final code = (await host.expect(Msg.room))['code'] as String;
      groups.add((code, group));
      host.send({
        't': Msg.cmd,
        'c': ConfigureGame(
          scenarioId: scenario,
          mode: 'story',
          bots: 0,
        ).toJson(),
      });
      for (final guest in group.skip(1)) {
        guest.send({'t': Msg.join, 'code': code});
        await guest.expect(
          Msg.room,
          where: (message) => message['code'] == code,
        );
      }
      await host.expect(
        Msg.caseView,
        where: (message) {
          final view = CaseView.fromJson(message);
          return view.scenarioId == scenario &&
              view.bots == 0 &&
              view.lobby.length == group.length;
        },
      );
      for (final member in group) {
        member.send({'t': Msg.cmd, 'c': const SetReady(true).toJson()});
      }
      await host.expect(
        Msg.caseView,
        where: (message) =>
            CaseView.fromJson(message).lobby.every((player) => player.ready),
      );
      host.send({'t': Msg.cmd, 'c': const StartGame().toJson()});
      for (final member in group) {
        await member.expect(
          Msg.world,
          where: (message) => message['phase'] == 'intro',
        );
      }
      for (final member in group) {
        member.send({'t': Msg.cmd, 'c': const SetReady(true).toJson()});
      }
    }

    for (final (code, group) in groups) {
      final expectedIds = group.map((client) => client.playerId).toSet();
      for (final member in group) {
        final world = decodeWorld(
          await member.expect(
            Msg.world,
            where: (message) => message['phase'] == 'investigation',
          ),
        );
        final actualIds = world.detectives.map((player) => player.id).toSet();
        _require(
          actualIds.length == expectedIds.length &&
              actualIds.containsAll(expectedIds),
          'Ein Raum darf keine Figuren eines anderen Raums senden.',
        );
        final view = CaseView.fromJson(
          await member.expect(
            Msg.caseView,
            where: (message) => message['phase'] == 'investigation',
          ),
        );
        _require(
          view.roomCode == code && view.scenarioId == scenario,
          'Fallzustand muss zum eigenen Raum gehören.',
        );
        final me = world.detective(member.playerId!)!;
        member.send({
          't': Msg.move,
          ...MoveInput(x: me.x + 0.1, y: me.y, facing: 0, seq: 1).toJson(),
        });
        await member.expect(Msg.world, where: (message) => message['ack'] == 1);
      }
    }

    // Sitzungsschlüssel dürfen nie in Welt-/Fallansichten anderer Geräte landen.
    final identities = clients.map((client) => client.token!).toList();
    for (final member in clients) {
      final views = member.inbox.where(
        (message) => message['t'] == Msg.world || message['t'] == Msg.caseView,
      );
      for (final view in views) {
        final serialized = jsonEncode(view);
        _require(
          identities.every((identity) => !serialized.contains(identity)),
          'Sitzungsschlüssel in einer Spielansicht.',
        );
      }
      _require(!member.has(Msg.error), 'Unerwarteter Protokollfehler.');
    }

    final original = clients.first;
    final oldId = original.playerId;
    await original.close();
    await original.closed.future.timeout(const Duration(seconds: 5));
    final returned = await Client.connect(
      url.toString(),
      original.name,
    ).timeout(const Duration(seconds: 10));
    clients.add(returned);
    await returned.hello(token: original.token);
    _require(
      returned.playerId == oldId,
      'Reconnect muss dieselbe Spieler-ID behalten.',
    );
    await returned.expect(
      Msg.room,
      where: (message) => message['code'] == groups.first.$1,
    );
    await returned.expect(
      Msg.caseView,
      where: (message) => message['phase'] == 'investigation',
    );
    await _health(url);
    print(
      'ONLINE OK · $count Clients · ${groups.length} Räume · $scenario · Start, Isolation, Bewegung, Reconnect, Health',
    );
  } finally {
    for (final client in clients) {
      if (!client.closed.isCompleted) client.send({'t': Msg.leave});
    }
    await Future.wait(
      clients
          .where((client) => !client.closed.isCompleted)
          .map((client) => client.close().timeout(const Duration(seconds: 5))),
    );
    // Den Close-Callbacks des echten Servers Zeit zum Freigeben des IP-Limits geben.
    await Future<void>.delayed(const Duration(milliseconds: 100));
  }
}

Future<void> main(List<String> args) async {
  RoomManager? rooms;
  HttpServer? server;
  var runtimeErrors = 0;
  try {
    final scenarios = loadScenarios(resolveScenarioDir(null), log: (_) {});
    _require(
      scenarios.keys.toSet().containsAll({
        'ravensmoor',
        'nachtexpress',
        'blue_palm',
      }),
      'Die drei klassischen Szenarien müssen vorhanden sein.',
    );
    final Uri url;
    if (args.isEmpty) {
      rooms = RoomManager(
        runtimeFactory: coreRuntimeFactory(scenarios),
        log: (message) {
          if (message.contains('Fehler')) runtimeErrors++;
        },
      );
      server = await serveMordakte(rooms, port: 0, trustProxy: false);
      url = Uri.parse('ws://127.0.0.1:${server.port}/ws');
      print(
        'ONLINE-MATRIX · lokaler Produktions-Handler mit echter Engine und TCP/WebSocket',
      );
    } else {
      _require(
        args.length == 1 && args.single.startsWith('--url='),
        'Aufruf: online_matrix.dart [--url=wss://<host>/ws]',
      );
      url = Uri.parse(args.single.substring(6));
      _require(
        url.scheme == 'wss' &&
            url.host.isNotEmpty &&
            url.userInfo.isEmpty &&
            !url.hasQuery &&
            !url.hasFragment &&
            url.path == '/ws',
        'Öffentlicher Test braucht eine wss-Adresse ohne Zugangsdaten.',
      );
      print('ONLINE-MATRIX · konfigurierter öffentlicher Server');
    }
    await _health(url);
    final ids = scenarios.keys.toList()..sort();
    for (var count = 4; count <= 20; count++) {
      await _batch(url, count, ids[(count - 4) % ids.length]);
    }
    _require(runtimeErrors == 0, 'Server meldete Runtime-Fehler.');
    print(
      'ONLINE-MATRIX GRÜN · 17/17 Laststufen (4–20 Clients); Partyraum und öffentliche Bereitstellung separat abnehmen.',
    );
  } catch (error) {
    // Keine rohen Protokollnachrichten, Sitzungsschlüssel oder Konfiguration ausgeben.
    final detail = error is StateError
        ? error.message
        : error.runtimeType.toString();
    stderr.writeln('ONLINE-MATRIX ROT · $detail');
    exitCode = 1;
  } finally {
    await rooms?.close();
    await server?.close(force: true);
  }
}
