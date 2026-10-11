/// Echte WebSocket-Clients in EINEM Schlosskeller-Raum, 4–20 Laststufen.
/// Vollständiger Abend, eigene Rollenansichten, Rechte, Reconnect, Würfelprüfung.
/// Lokal: dart run tool/party_matrix.dart [--clients=4]
/// Öffentlich: `dart run tool/party_matrix.dart --url=wss://<freigegebener-host>/ws`
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:mordakte_core/mordakte_core.dart';
import 'package:mordakte_core/runden.dart';
import 'package:mordakte_server/party.dart';
import 'package:mordakte_server/rooms.dart';
import 'package:mordakte_server/runtime.dart';
import 'package:mordakte_server/scenarios.dart';
import 'package:mordakte_server/server.dart';

import 'smoke.dart' show Client;

String _stage = 'Vorbereitung';

void _require(bool ok, String label) { if (!ok) throw StateError(label); }
Map<String, Object?> _map(Object? v) => (v as Map).cast<String, Object?>();
List<Map<String, Object?>> _list(Object? v) => [for (final e in v as List) _map(e)];

Iterable<String> _keys(Object? v) sync* {
  if (v is Map) {
    for (final e in v.entries) { yield e.key.toString(); yield* _keys(e.value); }
  } else if (v is List) {
    for (final e in v) { yield* _keys(e); }
  }
}

Future<Map<String, dynamic>> _command(Client host, Client sender, String typ, [Map<String, Object?> data = const {}]) async {
  _stage = 'Abendbefehl $typ';
  final version = host.latest(Msg.abend)['version'] as int;
  sender.send({'t': Msg.abendCmd, 'c': {'typ': typ, ...data}});
  return host.expect(Msg.abend, where: (s) => (s['version'] as int) > version, timeout: const Duration(seconds: 10));
}

Future<void> _health(Uri url) async {
  final http = HttpClient();
  try {
    final req = await http.getUrl(url.replace(scheme: url.scheme == 'wss' ? 'https' : 'http', path: '/health')).timeout(const Duration(seconds: 10));
    final res = await req.close().timeout(const Duration(seconds: 10));
    final text = await res.transform(utf8.decoder).join().timeout(const Duration(seconds: 10));
    _require(res.statusCode == 200 && text.startsWith('ok rooms='), 'Healthcheck nicht grün.');
  } finally { http.close(force: true); }
}

Future<void> _batch(Uri url, int count, Texte texte) async {
  final all = <Client>[];
  final active = <Client>[];
  try {
    _stage = 'Anmeldung ($count Clients)';
    for (var i = 0; i < count; i++) {
      final c = await Client.connect(url.toString(), 'Partyprobe-$i').timeout(const Duration(seconds: 10));
      all.add(c); active.add(c);
      await c.hello();
    }
    final host = active.first;
    _stage = 'Partyraum erstellen und beitreten';
    host.send({'t': Msg.create, 'abend': 'schlosskeller'});
    final room = await host.expect(Msg.room);
    final code = room['code'] as String;
    _require(room['abend'] == 'schlosskeller', 'Falsche Raumart beim Erstellen.');
    for (final c in active.skip(1)) {
      c.send({'t': Msg.join, 'code': code});
      await c.expect(Msg.room, where: (s) => s['code'] == code);
    }
    for (final c in active) {
      await c.expect(Msg.abend, where: (s) => _list(s['spieler']).length == count);
      c.send({'t': Msg.abendCmd, 'c': {'typ': 'bereit', 'wert': true}});
    }
    await host.expect(Msg.abend, where: (s) => _list(s['spieler']).length == count && _list(s['spieler']).every((t) => t['bereit'] == true));
    final rollen = (count - 1).clamp(4, 20);
    await _command(host, host, 'start', {'rollen': rollen});
    _require(host.latest(Msg.abend)['phase'] == 'rollen', 'Start führte nicht zu den Rollen.');
    for (final c in active.skip(1)) {
      await c.expect(Msg.abend, where: (s) => s['phase'] == 'rollen' && _map(s['privat'])['spieler'] == c.playerId);
    }

    // Der echte Produktions-Handler behält beim Reconnect Identität und Dossier.
    _stage = 'Reconnect';
    final original = active[1];
    final privateBefore = jsonEncode(original.latest(Msg.abend)['privat']);
    await original.close();
    await original.closed.future.timeout(const Duration(seconds: 5));
    final returned = await Client.connect(url.toString(), original.name).timeout(const Duration(seconds: 10));
    all.add(returned);
    await returned.hello(token: original.token);
    _require(returned.playerId == original.playerId, 'Reconnect wechselte die Spieler-ID.');
    await returned.expect(Msg.room, where: (s) => s['code'] == code);
    final resumed = await returned.expect(Msg.abend, where: (s) => s['phase'] == 'rollen');
    _require(jsonEncode(resumed['privat']) == privateBefore, 'Reconnect wechselte die Rollenkarte.');
    active[1] = returned;
    await host.expect(Msg.abend, where: (s) => (s['version'] as int) >= (resumed['version'] as int));

    // Ein klassischer Raum bleibt getrennt; nach dem Start kein fremder Zutritt.
    _stage = 'Fremden klassischen Raum trennen';
    final outsider = await Client.connect(url.toString(), 'Fremder-Raum').timeout(const Duration(seconds: 10));
    all.add(outsider);
    await outsider.hello();
    outsider.send({'t': Msg.create});
    final otherCode = (await outsider.expect(Msg.room))['code'];
    _require(otherCode != code, 'Raumcodes kollidieren.');
    await outsider.expect(Msg.caseView);
    outsider.send({'t': Msg.join, 'code': code});
    await outsider.expect(Msg.error, where: (s) => s['key'] == (count == 21 ? NetError.roomFull : NetError.gameRunning));
    outsider.send({'t': Msg.abendCmd, 'c': {'typ': 'weiter'}});
    await outsider.expect(Msg.error, where: (s) => s['key'] == NetError.badMessage);

    // Keine Client-Nachricht darf eine fremde Rolle/Identität adressieren.
    active[1].send({'t': Msg.abendCmd, 'c': {'typ': 'rollenGelesen', 'spieler': host.playerId}});
    await active[1].expect(Msg.error, where: (s) => s['key'] == 'invalid');
    active[1].send({'t': Msg.abendCmd, 'c': {'typ': 'weiter'}});
    await active[1].expect(Msg.error, where: (s) => s['key'] == 'not_host');

    var forgedDiceChecked = false;
    var steps = 0;
    while (host.latest(Msg.abend)['phase'] != 'ende') {
      _require(++steps < 400, 'Partyabend erreicht das Ende nicht.');
      final s = host.latest(Msg.abend);
      switch (s['phase']) {
        case 'rollen':
          for (final c in active.skip(1)) { await _command(host, c, 'rollenGelesen'); }
          await _command(host, host, 'weiter');
        case 'entscheidungen':
          if (s['zug'] case final Map z) {
            switch (z['phase']) {
              case 'aktion':
                await _command(host, host, 'aktionFertig', {'aktion': z['aktion']});
              case 'wurf':
                final pate = active.firstWhere((c) => c.playerId == s['wuerfelPate']);
                if (!forgedDiceChecked) {
                  pate.send({'t': Msg.abendCmd, 'c': {'typ': 'wurf', 'a': 6, 'b': 6}});
                  await pate.expect(Msg.error, where: (m) => m['key'] == 'invalid');
                  forgedDiceChecked = true;
                }
                if (z['id'] != 'auftakt') await _command(host, pate, 'wuerfelHilfe', {'marke': true});
                await _command(host, pate, 'wurf');
              case 'tischruf':
                await _command(host, host, 'tischruf', {'ruf': count.isEven ? 'nochmal' : 'umweg'});
              case 'fund':
                await _command(host, host, 'fundGelesen');
              default: throw StateError('Unbekannter Zugabschnitt.');
            }
          } else if (s['entscheidung'] case final Map e) {
            // Der Treiber kennt die Lösung nicht: wählt eine angebotene Option.
            await _command(host, host, 'wahl', {'option': _list(e['optionen']).first['id']});
          } else {
            await _command(host, host, 'weiter');
          }
        case 'gruppenwahl':
          for (final c in active.skip(1)) {
            final state = await c.expect(Msg.abend, where: (m) => m['phase'] == 'gruppenwahl' && m['runde'] == s['runde']);
            if (_map(state['privat'])['hatGestimmt'] == false) await _command(host, c, 'stimme', {'kooperativ': count.isEven});
          }
          await _command(host, host, 'weiter');
        case 'anklage':
          await _command(host, host, 'anklage', {'person': (s['verdaechtige'] as List).first});
          await _command(host, host, 'weiter');
        default:
          await _command(host, host, 'weiter');
      }
    }
    final last = host.latest(Msg.abend);
    for (final c in active.skip(1)) {
      await c.expect(Msg.abend, where: (s) => s['phase'] == 'ende' && s['version'] == last['version']);
    }
    _require(forgedDiceChecked, 'Manipulationsprüfung wurde nicht erreicht.');
    final solution = _map(last['aufloesung']);
    final pfad = solution['pfad'] as String;
    final salz = solution['salz'] as String;
    final quelle = SalzWuerfel(salz);
    for (final w in _list(last['wuerfe'])) {
      final expected = Wurf.werfen(quelle, w['id'] as String, w['anlauf'] as int, w['mod'] as int, garantie: w['garantie'] as bool);
      _require(jsonEncode(expected.toJson()) == jsonEncode(w), 'Würfelprotokoll lässt sich nicht nachrechnen.');
    }
    _require(last['wuerfelZusage'] == SchlosskellerRaum(
      raumCode: 'PRUEFUNG', kanon: texte.kanon, texte: texte,
      fallCode: FallCode.fuerPfad(pfad, texte.kanon.pfade), salz: salz,
    ).wuerfelZusage, 'Würfelzusage stimmt nicht mit der Auflösung überein.');

    // Alle tatsächlich übertragenen Spielansichten prüfen, nicht nur Endstände.
    // Die Anmeldung selbst enthält natürlich das eigene Sitzungstoken; sie wird
    // weder als Spielansicht geprüft noch je ausgegeben.
    final identities = all.map((c) => c.token!).toSet();
    for (final c in all.where((c) => c != outsider)) {
      for (final view in c.inbox.where((m) => m['t'] == Msg.abend)) {
        final private = _map(view['privat']);
        _require(private['spieler'] == c.playerId && view['raum'] == code, 'Ansicht gehört einem anderen Empfänger oder Raum.');
        final text = jsonEncode(view);
        _require(identities.every((identity) => !text.contains(identity)), 'Sitzungsschlüssel in einer Spielansicht.');
        if (!['finale', 'aufloesung', 'ende'].contains(view['phase'])) {
          _require(_keys(view).toSet().intersection({'pfad', 'fallCode', 'salz', 'seed', 'richtig', 'qualitaeten'}).isEmpty, 'Geheimer Steuerwert vor dem Finale übertragen.');
          // Ein zufälliger fünfstelliger Code kann zufällig in einem Hash/Bezeichner
          // vorkommen. Statt fehleranfälliger Teilwortsuche das gesamte Schema sperren.
          // Öffentlich am Tisch: gewählte Optionen, Tischvorrat der Karten und Erkundungsorte.
          const allowed = {'t', 'protokoll', 'version', 'spiel', 'akte', 'raum', 'host', 'phase', 'runde',
            'wuerfelZusage', 'spieler', 'kannWeiter', 'rollen', 'restMinuten', 'marken',
            'erzaehler', 'notizbuch', 'wuerfe', 'wuerfelPate', 'gewaehlt', 'vorrat', 'abstecher',
            'abstecherErgebnis', 'entscheidung', 'zug', 'botGespraeche', 'verdaechtige', 'privat'};
          _require(view.keys.every(allowed.contains), 'Nicht freigegebenes Feld vor dem Finale übertragen.');
        }
        if (private['rolle'] case final String role) {
          final dossier = _map(private['dossier']);
          final expected = texte.dossier(role, pfad, rollen);
          final expectedDossier = {
            'wer': expected.wer, 'ziel': expected.ziel, 'besetzung': expected.besetzung,
            'weiss': [for (final z in expected.weiss) z.text],
            'verbirgt': [for (final z in expected.verbirgt) z.text],
            if (expected.tarnung != null) 'tarnung': expected.tarnung,
            if (expected.tatwissen.isNotEmpty) 'tatwissen': [for (final z in expected.tatwissen) z.text],
          };
          _require(jsonEncode(dossier) == jsonEncode(expectedDossier), 'Falsche, ergänzte oder fremde Rollenkarte übertragen.');
          _require(_keys(view).where((key) => key == 'dossier').length == 1, 'Mehr als eine Rollenkarte in einer Ansicht.');
          if (role != pfad && !['finale', 'aufloesung', 'ende'].contains(view['phase'])) {
            _require(!text.contains(texte.sammlung.taeter[pfad]!.tarnung), 'Täterfassung an einen unschuldigen Gast übertragen.');
          }
        } else {
          _require(!private.containsKey('dossier'), 'Detektiv bekam eine fremde Rollenkarte.');
        }
      }
    }
    _require(!outsider.has(Msg.abend), 'Ein fremder Raum bekam eine Partyansicht.');
    await _health(url);
    print('PARTY-ONLINE OK · $count Clients in einem Raum · $rollen Rollen · vollständiger Abend, eigene Karten, Rechte, Reconnect, Würfel, Isolation, Health');
  } finally {
    for (final c in all) { if (!c.closed.isCompleted) c.send({'t': Msg.leave}); }
    await Future.wait(all.where((c) => !c.closed.isCompleted).map((c) => c.close().timeout(const Duration(seconds: 5))));
    await Future<void>.delayed(const Duration(milliseconds: 100));
  }
}

Future<void> main(List<String> args) async {
  RoomManager? rooms;
  HttpServer? server;
  var runtimeErrors = 0;
  try {
    String? remote;
    int? single;
    for (final arg in args) {
      if (arg.startsWith('--url=') && remote == null) { remote = arg.substring(6); }
      else if (arg.startsWith('--clients=') && single == null) { single = int.parse(arg.substring(10)); }
      else { throw StateError('Aufruf: party_matrix.dart [--clients=4..21] [--url=wss://<host>/ws]'); }
    }
    _require(single == null || (single >= 4 && single <= 21), 'Clientzahl muss zwischen 4 und 21 liegen.');
    final scenarios = loadScenarios(resolveScenarioDir(null), log: (_) {});
    final partyDir = resolvePartyDir(null);
    Map<String, Object?> lesen(String p) => (jsonDecode(File('$partyDir/$p').readAsStringSync()) as Map).cast<String, Object?>();
    final kanon = Kanon.lade(lesen);
    final texte = Texte(kanon, Textsammlung.lade(lesen));
    final Uri url;
    if (remote == null) {
      rooms = RoomManager(
        runtimeFactory: coreRuntimeFactory(scenarios),
        abendFactories: {'schlosskeller': loadSchlosskellerFactory(partyDir)},
        log: (message) { if (message.contains('Fehler')) runtimeErrors++; },
      );
      server = await serveMordakte(rooms, port: 0, trustProxy: false);
      url = Uri.parse('ws://127.0.0.1:${server.port}/ws');
      print('PARTY-ONLINE-MATRIX · lokaler Produktions-Handler, ein Raum je Laststufe');
    } else {
      url = Uri.parse(remote);
      _require(url.scheme == 'wss' && url.host.isNotEmpty && url.path == '/ws' && url.userInfo.isEmpty && !url.hasQuery && !url.hasFragment,
        'Öffentlicher Test braucht eine wss-Adresse ohne Zugangsdaten.');
      print('PARTY-ONLINE-MATRIX · konfigurierter öffentlicher Server');
    }
    await _health(url);
    final counts = single == null ? [for (var n = 4; n <= 20; n++) n] : [single];
    for (final n in counts) { await _batch(url, n, texte); }
    _require(runtimeErrors == 0, 'Server meldete unerwartete Runtime-Fehler.');
    print('PARTY-ONLINE-MATRIX GRÜN · ${counts.length}/${counts.length} Laststufen; App-Bedienung und öffentliche Bereitstellung separat abnehmen.');
  } catch (error) {
    // Keine Rohpakete, Tokens, privaten Rollenkarten oder Konfigurationswerte.
    final detail = error is StateError ? error.message : '${error.runtimeType} bei $_stage';
    stderr.writeln('PARTY-ONLINE-MATRIX ROT · $detail');
    exitCode = 1;
  } finally {
    await rooms?.close();
    await server?.close(force: true);
  }
}
