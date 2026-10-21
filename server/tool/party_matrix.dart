/// Echte WebSocket-Clients in EINEM Schlosskeller-Raum, 4–20 Laststufen, je in
/// drei Sitz-Konstellationen (Host = Erzähler + Gast = Detektiv, Host = Detektiv
/// ohne Erzähler, Host = Detektiv + Gast = Erzähler). Lokal dazu ein Lauf mit dem
/// langen Abend (M7b, eigene Raumart nur dieser Matrix) mit Vorspiel und Morgen:
/// Alle sehen dieselbe Station, den Vorlesetext nur der Vorleser, weiter
/// schaltet nur, wer leitet; der Raum ist erst nach dem Morgen beendet. Die Uhr der Gespräche
/// läuft in den Entscheidungen weiter und lässt sich dort stellen, jede Ansicht
/// trägt `fassung: lang`. Kurz fehlen Uhr und Schlüssel dort wie bisher.
/// Vollständiger Abend, eigene Rollenansichten, Sitze, Vorleser-Sitz, Rechte,
/// Reconnect, Würfelprüfung. Dazu je Akte ein Host-Wechsel nach dem Start: Der
/// Gastgeber auf dem Detektiv-Sitz geht, der neue führt den Abend zu Ende. Zuletzt
/// fällt ein Gast-Detektiv aus, und der Gastgeber vergibt seinen Sitz neu.
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
  final version = host.latest(Msg.abend)['version'] as int;
  _stage = 'Abendbefehl $typ (Phase ${host.latest(Msg.abend)['phase']})';
  final fehler = sender.count(Msg.error);
  sender.send({'t': Msg.abendCmd, 'c': {'typ': typ, ...data}});
  try {
    return await host.expect(Msg.abend, where: (s) => (s['version'] as int) > version, timeout: const Duration(seconds: 10));
  } on TimeoutException {
    // Nur der feste Fehlerschlüssel des Raums, nie Nutzdaten.
    final neu = sender.inbox.where((m) => m['t'] == Msg.error).skip(fehler).map((m) => m['key']).toList();
    throw StateError('$_stage ohne Wirkung${neu.isEmpty ? '' : ', abgelehnt: ${neu.join(', ')}'}.');
  }
}

/// Geht einen Rundgang (Vorspiel oder Morgen, M7b) ab: Eine Rolle darf nicht
/// schalten, ein veralteter Schritt ist `stale`; je Station sehen alle dieselbe
/// Karte, den Vorlesetext nur [vorleser] (privat). Liefert die vorgelesenen Texte.
Future<Set<String>> _rundgang(Client host, Client leiter, Client rolle, List<Client> alle, Client vorleser) async {
  final texte = <String>{};
  final teil = _map(host.latest(Msg.abend)['rundgang'])['teil'];
  rolle.send({'t': Msg.abendCmd, 'c': {'typ': 'rundgang', 'station': 0}});
  await rolle.expect(Msg.error, where: (m) => m['key'] == 'not_host');
  final erste = _map(host.latest(Msg.abend)['rundgang'])['station'] as int;
  leiter.send({'t': Msg.abendCmd, 'c': {'typ': 'rundgang', 'station': erste + 1}});
  await leiter.expect(Msg.error, where: (m) => m['key'] == 'stale');
  for (var i = 0; i < 12; i++) {
    final s = host.latest(Msg.abend);
    final g = s['rundgang'];
    if (g is! Map || g['teil'] != teil) break;
    final karten = <String>{};
    for (final c in alle) {
      final v = await _sicht(c, s['version'] as int);
      _require(v['rundgang'] is Map, 'Rundgang fehlt bei einem Gerät.');
      _require(_map(v['rundgang']).keys.toSet().difference({'teil', 'station', 'anzahl', 'id', 'zeit', 'karte'}).isEmpty, 'Unbekanntes Feld im Rundgang.');
      karten.add(jsonEncode(v['rundgang']));
      final privat = _map(v['privat']);
      if (c.playerId == vorleser.playerId) {
        _require(privat['rundgangText'] is String, 'Der Vorleser bekam den Vorlesetext der Station nicht.');
        texte.add(privat['rundgangText'] as String);
      } else {
        _require(!privat.containsKey('rundgangText'), 'Vorlesetext der Station an ein Gerät, das nicht vorliest.');
      }
    }
    _require(karten.length == 1, 'Die Station ist nicht für alle gleich.');
    _require(s['kannWeiter'] != true || teil == 'morgen', 'Während des Vorspiels geht es nicht weiter in die Runden.');
    await _command(host, leiter, 'rundgang', {'station': g['station']});
  }
  _require(host.latest(Msg.abend)['rundgang'] == null, 'Der Rundgang endet nicht.');
  return texte;
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

/// Sitze eines Laufs (M3): Client 0 öffnet den Raum, Client 1 ist der Gast mit Sitz;
/// [lang]: der lange Abend (M7b).
typedef _Konstellation = ({String name, String hostSitz, String? gastSitz, bool lang});

const _konstellationen = <_Konstellation>[
  (name: 'Host = Erzähler + Gast = Detektiv', hostSitz: 'erzaehler', gastSitz: 'detektiv', lang: false),
  (name: 'Host = Detektiv ohne Erzähler', hostSitz: 'detektiv', gastSitz: null, lang: false),
  (name: 'Host = Detektiv + Gast = Erzähler', hostSitz: 'detektiv', gastSitz: 'erzaehler', lang: false),
  (name: 'Langer Abend: Host = Erzähler + Gast = Detektiv', hostSitz: 'erzaehler', gastSitz: 'detektiv', lang: true),
];

/// Raumart des langen Abends, nur am lokalen Server dieser Matrix (Server-Räume
/// des Produktionsservers haben keine Meta und spielen kurz).
const _langAbend = 'schlosskeller~lang';

/// Ansicht von [c], die [wo] erfüllt: schon empfangen (auch wenn `_command` sie
/// verbraucht hat), sonst die nächste.
Future<Map<String, dynamic>> _ansicht(Client c, bool Function(Map<String, dynamic>) wo) async {
  for (final m in c.inbox.reversed) {
    if (m['t'] == Msg.abend && wo(m)) return m;
  }
  return c.expect(Msg.abend, where: wo, timeout: const Duration(seconds: 10));
}

/// Ansicht von [c] mit mindestens der Version [version] (die letzte, sonst die nächste).
Future<Map<String, dynamic>> _sicht(Client c, int version) async {
  final letzte = c.latest(Msg.abend);
  if ((letzte['version'] as int) >= version) return letzte;
  return c.expect(Msg.abend, where: (m) => (m['version'] as int) >= version, timeout: const Duration(seconds: 10));
}

Future<void> _batch(Uri url, int count, Texte texte, _Konstellation k) async {
  final all = <Client>[];
  final active = <Client>[];
  try {
    _stage = 'Anmeldung ($count Clients, ${k.name})';
    for (var i = 0; i < count; i++) {
      final c = await Client.connect(url.toString(), 'Partyprobe-$i').timeout(const Duration(seconds: 10));
      all.add(c); active.add(c);
      await c.hello();
    }
    final host = active.first;
    _stage = 'Partyraum erstellen und beitreten';
    host.send({'t': Msg.create, 'abend': k.lang ? _langAbend : 'schlosskeller'});
    final room = await host.expect(Msg.room);
    final code = room['code'] as String;
    _require(room['abend'] == 'schlosskeller', 'Falsche Raumart beim Erstellen.');
    for (final c in active.skip(1)) {
      c.send({'t': Msg.join, 'code': code});
      await c.expect(Msg.room, where: (s) => s['code'] == code);
    }
    for (final c in active) {
      await c.expect(Msg.abend, where: (s) => _list(s['spieler']).length == count);
    }

    // Sitze in der Lobby (M3): Wer den Raum öffnet, sitzt zuerst auf dem Detektiv-Sitz.
    // Die Klasse reist mit dem Detektiv-Sitz; ein Gast-Detektiv setzt sie selbst.
    _stage = 'Sitze (${k.name})';
    final gast = active[1];
    final detektiv = k.gastSitz == 'detektiv' ? gast : host;
    final erzaehler = k.hostSitz == 'erzaehler' ? host : (k.gastSitz == 'erzaehler' ? gast : null);
    final leiter = erzaehler ?? detektiv;
    final vorleser = erzaehler ?? detektiv;
    final klasse = k.gastSitz == 'detektiv' ? 'forensic' : 'medic';
    host.send({'t': Msg.abendCmd, 'c': {'typ': 'sitz', 'spieler': gast.playerId, 'sitz': 'zauberer'}});
    await host.expect(Msg.error, where: (s) => s['key'] == 'invalid');
    gast.send({'t': Msg.abendCmd, 'c': {'typ': 'sitz', 'spieler': gast.playerId, 'sitz': 'erzaehler'}});
    await gast.expect(Msg.error, where: (s) => s['key'] == 'not_host');
    if (k.hostSitz == 'erzaehler') await _command(host, host, 'sitz', {'spieler': host.playerId, 'sitz': 'erzaehler'});
    if (k.gastSitz != null) await _command(host, host, 'sitz', {'spieler': gast.playerId, 'sitz': k.gastSitz});
    await _command(host, detektiv, 'sitz', {'spieler': detektiv.playerId, 'sitz': 'detektiv', 'klasse': klasse});
    final sitze = {for (final t in _list(host.latest(Msg.abend)['spieler'])) t['id']: t['sitz']};
    _require(sitze[detektiv.playerId] == 'detektiv' && (erzaehler == null || sitze[erzaehler.playerId] == 'erzaehler'),
        'Sitzplan der Lobby stimmt nicht.');
    final mitSitz = {detektiv, ?erzaehler};
    final rollenGaeste = [for (final c in active) if (!mitSitz.contains(c)) c];

    for (final c in active) {
      c.send({'t': Msg.abendCmd, 'c': {'typ': 'bereit', 'wert': true}});
    }
    await host.expect(Msg.abend, where: (s) => _list(s['spieler']).length == count && _list(s['spieler']).every((t) => t['bereit'] == true));
    final rollen = rollenGaeste.length.clamp(4, 20);
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
    Client wer(Client c) => c == original ? returned : c;
    final detektivC = wer(detektiv), leiterC = wer(leiter);
    final erzaehlerC = erzaehler == null ? null : wer(erzaehler);
    final rollenC = [for (final c in rollenGaeste) wer(c)];

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

    // Keine Client-Nachricht darf eine fremde Rolle/Identität adressieren; Rechte je Sitz.
    final rolle = rollenC.first;
    rolle.send({'t': Msg.abendCmd, 'c': {'typ': 'rollenGelesen', 'spieler': host.playerId}});
    await rolle.expect(Msg.error, where: (s) => s['key'] == 'invalid');
    rolle.send({'t': Msg.abendCmd, 'c': {'typ': 'weiter'}});
    await rolle.expect(Msg.error, where: (s) => s['key'] == 'not_host');
    rolle.send({'t': Msg.abendCmd, 'c': {'typ': 'anklage', 'person': 'ahmet'}});
    await rolle.expect(Msg.error, where: (s) => s['key'] == 'not_detective');
    if (erzaehlerC != null) {
      erzaehlerC.send({'t': Msg.abendCmd, 'c': {'typ': 'fundGelesen'}});
      await erzaehlerC.expect(Msg.error, where: (s) => s['key'] == 'not_detective');
      detektivC.send({'t': Msg.abendCmd, 'c': {'typ': 'weiter'}});
      await detektivC.expect(Msg.error, where: (s) => s['key'] == 'not_host');
    }

    var forgedDiceChecked = false;
    var befragt = 0;
    var steps = 0;
    // Rundenuhr und Diashow (M4): je einmal geprüft; dazu die Uhr im Streifzug (M7b).
    var uhrGeprueft = false, diaGeprueft = false, streifzugGeprueft = false, uhrAbgeraeumt = false;
    // Vorspiel und Morgen (M7b): nur im langen Abend, je ganz abgegangen.
    final rundgaenge = <String>{};
    final vorgelesenRundgang = <String>{};
    // Im langen Abend läuft im Ende noch der Morgen; erst danach ist der Abend vorbei.
    while (host.latest(Msg.abend)['phase'] != 'ende' || host.latest(Msg.abend)['rundgang'] is Map) {
      _require(++steps < 400, 'Partyabend erreicht das Ende nicht.');
      final s = host.latest(Msg.abend);
      switch (s['phase']) {
        case 'intro' || 'ende' when s['rundgang'] is Map:
          _stage = 'Rundgang ${(s['rundgang'] as Map)['teil']}';
          rundgaenge.add((s['rundgang'] as Map)['teil'] as String);
          vorgelesenRundgang.addAll(await _rundgang(host, leiterC, rollenC.first, active, wer(vorleser)));
        case 'rollen':
          for (final c in rollenC) { await _command(host, c, 'rollenGelesen'); }
          await _command(host, leiterC, 'weiter');
        case 'entscheidungen' when !streifzugGeprueft:
          // Uhr im Streifzug (M7b): lang läuft die Uhr der Gespräche weiter, für alle gleich,
          // und wer leitet, stellt sie; kurz gibt es dort keine Uhr (`invalid_phase`).
          _stage = 'Uhr im Streifzug';
          streifzugGeprueft = true;
          if (k.lang) {
            _require(RundenUhr.ausJson(s['uhr'])?.laeuft == true, 'Langer Abend: Die Uhr der Gespräche läuft in den Entscheidungen nicht weiter.');
            final andere = rollenC.first;
            andere.send({'t': Msg.abendCmd, 'c': {'typ': 'uhr', 'aktion': 'pause'}});
            await andere.expect(Msg.error, where: (m) => m['key'] == 'not_host');
            final angehalten = await _command(host, leiterC, 'uhr', {'aktion': 'pause'});
            _require(RundenUhr.ausJson(angehalten['uhr'])?.pausiert == true, 'Langer Abend: Die Uhr hält in den Entscheidungen nicht an.');
            final weiter = await _command(host, leiterC, 'uhr', {'aktion': 'weiter'});
            final uhren = <String>{};
            for (final c in active) {
              final v = await _sicht(c, weiter['version'] as int);
              _require(RundenUhr.ausJson(v['uhr'])?.laeuft == true, 'Langer Abend: Die Uhr läuft nach Weiter nicht.');
              uhren.add(jsonEncode(v['uhr']));
            }
            _require(uhren.length == 1, 'Langer Abend: Die Uhr in den Entscheidungen ist nicht für alle gleich.');
          } else {
            _require(!s.containsKey('uhr'), 'Kurzer Abend: Uhr in den Entscheidungen.');
            leiterC.send({'t': Msg.abendCmd, 'c': {'typ': 'uhr', 'aktion': 'pause'}});
            await leiterC.expect(Msg.error, where: (m) => m['key'] == 'invalid_phase');
          }
        case 'entscheidungen':
          if (s['zug'] case final Map z) {
            switch (z['phase']) {
              case 'aktion':
                await _command(host, detektivC, 'aktionFertig', {'aktion': z['aktion']});
              case 'wurf':
                final pate = active.firstWhere((c) => c.playerId == s['wuerfelPate']);
                _require(pate != erzaehlerC, 'Der Erzähler ist Würfelpate.');
                if (!forgedDiceChecked) {
                  pate.send({'t': Msg.abendCmd, 'c': {'typ': 'wurf', 'a': 6, 'b': 6}});
                  await pate.expect(Msg.error, where: (m) => m['key'] == 'invalid');
                  forgedDiceChecked = true;
                }
                if (z['id'] != 'auftakt') await _command(host, pate, 'wuerfelHilfe', {'marke': true});
                await _command(host, pate, 'wurf');
              case 'tischruf':
                await _command(host, detektivC, 'tischruf', {'ruf': count.isEven ? 'nochmal' : 'umweg'});
              case 'fund':
                await _command(host, detektivC, 'fundGelesen');
              default: throw StateError('Unbekannter Zugabschnitt.');
            }
          } else if (s['entscheidung'] case final Map e) {
            // Der Treiber kennt die Lösung nicht: wählt eine angebotene Option.
            await _command(host, detektivC, 'wahl', {'option': _list(e['optionen']).first['id']});
          } else {
            await _command(host, leiterC, 'weiter');
          }
        case 'intro' when s['dia'] is int && !diaGeprueft:
          // Diashow (M4): Den Zähler sehen alle; schalten darf nur, wer leitet.
          _stage = 'Diashow';
          final andere = rollenC.first;
          andere.send({'t': Msg.abendCmd, 'c': {'typ': 'dia', 'nr': 1}});
          await andere.expect(Msg.error, where: (m) => m['key'] == 'not_host');
          await _command(host, leiterC, 'dia', {'nr': 1});
          for (final c in active) {
            await _ansicht(c, (m) => m['phase'] == 'intro' && m['dia'] == 1);
          }
          diaGeprueft = true;
          await _command(host, leiterC, 'weiter');
        case 'gespraeche' when s['uhr'] is Map && !uhrGeprueft:
          // Rundenuhr (M4): Der Server stempelt die Zeit; was das Gerät mitschickt, gilt nicht.
          _stage = 'Rundenuhr';
          final andere = rollenC.first;
          andere.send({'t': Msg.abendCmd, 'c': {'typ': 'uhr', 'aktion': 'start'}});
          await andere.expect(Msg.error, where: (m) => m['key'] == 'not_host');
          final vorher = DateTime.now().millisecondsSinceEpoch;
          await _command(host, leiterC, 'uhr', {'aktion': 'start', 'zeit': 1});
          final nachher = DateTime.now().millisecondsSinceEpoch;
          final uhren = <String>{};
          for (final c in active) {
            final v = await _ansicht(c, (m) => m['phase'] == 'gespraeche' && RundenUhr.ausJson(m['uhr'])?.laeuft == true);
            final start = RundenUhr.ausJson(v['uhr'])!.start!;
            _require(start >= vorher && start <= nachher, 'Die Uhr trägt nicht die Zeit des Servers.');
            uhren.add(jsonEncode(v['uhr']));
          }
          _require(uhren.length == 1, 'Die Uhr ist nicht für alle gleich.');
          uhrGeprueft = true;
        case 'gespraeche':
          // Modell befragung (A-051): Der Detektiv-Sitz erledigt seine Befragungen.
          final privat = _map((await _sicht(detektivC, s['version'] as int))['privat']);
          if (privat['befragungen'] is List) {
            var frei = privat['befragungenFrei'] as int;
            for (final k in _list(privat['befragungen'])) {
              if (k['erledigt'] == true) continue;
              if (k['frage'] == null) {
                if (k['pflicht'] != true) {
                  if (frei <= 0) continue;
                  frei--;
                }
                await _command(host, detektivC, 'befragen', {'id': k['id'], 'frage': 0});
                befragt++;
              }
              if (k['mensch'] == true) await _command(host, detektivC, 'erledigt', {'id': k['id']});
            }
          }
          await _command(host, leiterC, 'weiter');
        case 'gruppenwahl' when !uhrAbgeraeumt:
          // Nach dem Streifzug gibt es keine Uhr mehr, kurz wie lang.
          _stage = 'Uhr nach dem Streifzug';
          uhrAbgeraeumt = true;
          _require(!s.containsKey('uhr'), 'Uhr in der Gruppenwahl.');
          leiterC.send({'t': Msg.abendCmd, 'c': {'typ': 'uhr', 'aktion': 'pause'}});
          await leiterC.expect(Msg.error, where: (m) => m['key'] == 'invalid_phase');
        case 'gruppenwahl':
          for (final c in rollenC) {
            final state = await c.expect(Msg.abend, where: (m) => m['phase'] == 'gruppenwahl' && m['runde'] == s['runde']);
            if (_map(state['privat'])['hatGestimmt'] == false) await _command(host, c, 'stimme', {'kooperativ': count.isEven});
          }
          await _command(host, leiterC, 'weiter');
        case 'anklage':
          await _command(host, detektivC, 'anklage', {'person': (s['verdaechtige'] as List).first});
          await _command(host, leiterC, 'weiter');
        default:
          await _command(host, leiterC, 'weiter');
      }
    }
    final last = host.latest(Msg.abend);
    for (final c in active.skip(1)) {
      await c.expect(Msg.abend, where: (s) => s['phase'] == 'ende' && s['version'] == last['version']);
    }
    _require(forgedDiceChecked, 'Manipulationsprüfung wurde nicht erreicht.');
    _require(uhrGeprueft, 'Die Rundenuhr wurde nicht geprüft.');
    _require(streifzugGeprueft && uhrAbgeraeumt, 'Die Uhr im Streifzug wurde nicht geprüft.');
    _require(diaGeprueft, 'Die Diashow wurde nicht geprüft.');
    _require(k.lang ? rundgaenge.containsAll(['vorspiel', 'morgen']) : rundgaenge.isEmpty, 'Vorspiel und Morgen nur im langen Abend und dort ganz.');
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
    // Was nur das Erzählerpaket je enthalten darf, und was nie: verbirgt, Tatwissen, Tarnung.
    final npcTexte = {for (final e in texte.sammlung.bausteine.entries) if (e.key.startsWith('npc.')) e.value};
    final geheim = <String>{
      for (final r in texte.besetzung.besetzt(rollen)) ...[
        for (final z in texte.dossier(r, pfad, rollen).verbirgt) z.text,
        for (final z in texte.dossier(r, pfad, rollen).tatwissen) z.text,
        ?texte.dossier(r, pfad, rollen).tarnung,
      ],
    };
    final vorgelesen = <String>{};
    var spickzettel = 0, erzaehlerAnsichten = 0, notizen = 0, auflosungFuerAlle = 0;
    for (final c in all.where((c) => c != outsider)) {
      for (final view in c.inbox.where((m) => m['t'] == Msg.abend)) {
        final private = _map(view['privat']);
        _require(private['spieler'] == c.playerId && view['raum'] == code, 'Ansicht gehört einem anderen Empfänger oder Raum.');
        final text = jsonEncode(view);
        _require(identities.every((identity) => !text.contains(identity)), 'Sitzungsschlüssel in einer Spielansicht.');
        final istDetektiv = c.playerId == detektiv.playerId, istErzaehler = c.playerId == erzaehler?.playerId;
        final lobby = view['phase'] == 'lobby';
        // Fassung (M7b): lang trägt jede Ansicht `fassung: lang`, kurz keine den Schlüssel.
        _require(k.lang ? view['fassung'] == 'lang' : !view.containsKey('fassung'), 'Fassung fehlt oder steht im kurzen Abend.');
        final nachFinale = ['finale', 'aufloesung', 'ende'].contains(view['phase']);
        if (!nachFinale) {
          _require(_keys(view).toSet().intersection({'pfad', 'fallCode', 'salz', 'seed', 'richtig', 'qualitaeten'}).isEmpty, 'Geheimer Steuerwert vor dem Finale übertragen.');
          // Ein zufälliger fünfstelliger Code kann zufällig in einem Hash/Bezeichner
          // vorkommen. Statt fehleranfälliger Teilwortsuche das gesamte Schema sperren.
          // Öffentlich am Tisch: gewählte Optionen, Tischvorrat der Karten und Erkundungsorte.
          // Die Liste steht einmal im Kern (raumOeffentlicheSchluessel, A-009).
          _require(view.keys.every(raumOeffentlicheSchluessel.contains), 'Nicht freigegebenes Feld vor dem Finale übertragen.');
          _require(_list(view['spieler']).every((t) => raumSpielerFelder.containsAll(t.keys)), 'Nicht freigegebenes Spielerfeld.');
          // Vorleser-Sitz: Erzähltext nur privat beim Erzähler, ohne Erzähler beim Detektiv.
          _require(!view.containsKey('erzaehler'), 'Öffentlicher Erzähltext vor dem Finale.');
          if (c.playerId == vorleser.playerId && !lobby) {
            final eigene = (private['erzaehler'] as List).cast<String>();
            _require(eigene.length == view['bausteinZahl'] && view['erzaehlerLiest'] == eigene.isNotEmpty, 'Vorleser ohne seinen Erzähltext.');
            vorgelesen.addAll(eigene);
          } else {
            _require(!private.containsKey('erzaehler') && !private.containsKey('vorleser'), 'Erzähltext an ein Gerät, das nicht vorliest.');
          }
        } else if (view['phase'] != 'ende') {
          // Ab dem Finale sehen alle die Auflösungstexte (öffentlich, für alle gleich).
          _require(view['erzaehler'] is List, 'Nach dem Finale fehlt der öffentliche Erzähltext.');
          auflosungFuerAlle++;
        }
        // Das Erzählerpaket bekommt nur der Erzähler, die npc-Notizen nur der Detektiv, die Klasse Detektiv und Gastgeber.
        _require(private.containsKey('erzaehlerPaket') == (istErzaehler && !lobby), 'Erzählerpaket am falschen Sitz.');
        _require(private.containsKey('erzaehlerNotizen') == (istDetektiv && !lobby), 'npc-Notizen am falschen Sitz.');
        if (!lobby) {
          _require(private['klasse'] == (istDetektiv || c.playerId == host.playerId ? klasse : null), 'Klasse am falschen Gerät.');
          _require(private['detektiv'] == istDetektiv, 'Detektiv-Merkmal am falschen Gerät.');
        }
        if (private['erzaehlerNotizen'] case final List n) {
          _require(npcTexte.containsAll(n), 'Notiz des Detektivs ist kein npc-Wissen.');
          notizen += n.length;
        }
        if (istErzaehler) {
          erzaehlerAnsichten++;
          _require(_keys(view).toSet().intersection({'dossier', 'verbirgt', 'tatwissen', 'tarnung'}).isEmpty, 'Erzähler bekam Rollenwissen.');
          if (!nachFinale) {
            final nur = jsonEncode(private);
            _require(geheim.every((t) => !nur.contains(t)), 'Erzählerpaket enthält verbirgt, Tatwissen oder Tarnung.');
          }
        }
        // Modell befragung: Antworten der App und Befragungskarten gibt es nur für den Detektiv; der
        // Erzähler kennt die pfadfreien Antworten aller Befragungen nur aus seinem Paket (A-052).
        if (!istDetektiv) {
          final ohnePaket = {...view, 'privat': Map.of(private)..remove('erzaehlerPaket')};
          _require(!_keys(ohnePaket).contains('antwort') && !private.containsKey('befragungen'), 'Befragungsantwort an einen Gast.');
        }
        if (private['rolle'] case final String role) {
          if (private['befragung'] case final Map b) {
            _require(b['id'] == BefragungText.kennung(role, view['runde'] as int), 'Fremde Befragung an einen Gast.');
            final soll = befragungsZettel(texte, texte.sammlung.befragungen[b['id']]!);
            _require(jsonEncode(b['karten']) == jsonEncode([for (final k in soll.karten) {'zeilen': k.zeilen, 'behaupte': k.behaupten}]),
                'Falscher Spickzettel an einen Gast.');
            spickzettel++;
          }
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
          if (role != pfad && !nachFinale) {
            _require(!text.contains(texte.sammlung.taeter[pfad]!.tarnung), 'Täterfassung an einen unschuldigen Gast übertragen.');
          }
        } else {
          _require(!private.containsKey('dossier'), 'Detektiv bekam eine fremde Rollenkarte.');
        }
      }
    }
    // Vorspiel und Morgen (M7b): Den Vorlesetext einer Station sieht nur der Vorleser, auch am Morgen.
    for (final c in all.where((c) => c != outsider && c.playerId != vorleser.playerId)) {
      for (final view in c.inbox.where((m) => m['t'] == Msg.abend)) {
        final text = jsonEncode(view);
        _require(vorgelesenRundgang.every((t) => !text.contains(jsonEncode(t))), 'Vorlesetext des Rundgangs an ein Gerät, das nicht vorliest.');
        _require(!_map(view['privat']).containsKey('rundgangText'), 'Vorlesetext des Rundgangs an ein Gerät, das nicht vorliest.');
      }
    }
    // Kein Gerät außer dem Vorleser sieht vor dem Finale einen vorgelesenen Text (die Notizen des Detektivs ausgenommen).
    for (final c in all.where((c) => c != outsider && c.playerId != vorleser.playerId)) {
      for (final view in c.inbox.where((m) => m['t'] == Msg.abend && !['finale', 'aufloesung', 'ende'].contains(m['phase']))) {
        final text = jsonEncode({...view, 'privat': Map.of(_map(view['privat']))..remove('erzaehlerNotizen')});
        _require(vorgelesen.every((t) => !text.contains(jsonEncode(t))), 'Erzähltext vor dem Finale an ein Gerät, das nicht vorliest.');
      }
    }
    _require(!outsider.has(Msg.abend), 'Ein fremder Raum bekam eine Partyansicht.');
    _require(vorgelesen.isNotEmpty, 'Der Vorleser bekam keinen Erzähltext.');
    _require(auflosungFuerAlle >= count, 'Keine Ansichten nach dem Finale geprüft.');
    _require(erzaehlerC == null || erzaehlerAnsichten > 0, 'Keine Erzähleransicht geprüft.');
    if (texte.besetzung.befragungsmodell) {
      _require(befragt >= 9, 'Der Detektiv hat kaum Befragungen geführt ($befragt).');
      _require(spickzettel >= rollenC.length, 'Zu wenige Spickzettel geprüft ($spickzettel).');
      _require(rollen > 7 || notizen > 0, 'Der Detektiv bekam kein npc-Wissen als Notiz.');
    }
    await _health(url);
    print('PARTY-ONLINE OK · ${k.name} · $count Clients in einem Raum · $rollen Rollen · vollständiger Abend${k.lang ? ' mit Vorspiel und Morgen' : ''}, eigene Karten, Sitze, Vorleser, Rechte, Uhr, Diashow, Reconnect, Würfel, Isolation, Health');
  } finally {
    for (final c in all) { if (!c.closed.isCompleted) c.send({'t': Msg.leave}); }
    await Future.wait(all.where((c) => !c.closed.isCompleted).map((c) => c.close().timeout(const Duration(seconds: 5))));
    await Future<void>.delayed(const Duration(milliseconds: 100));
  }
}

/// Ausfall des Gast-Detektivs (Nachschliff M3, A-062): Host = Erzähler, Gast = Detektiv
/// mit Klasse; 21 weitere Gäste spielen alle zwanzig Figuren, einer sitzt ohne Figur am
/// Tisch (Assistenz). Solange der Detektiv da ist, lehnt der Raum `detektivNeu` ab, und
/// nur der Gastgeber darf es senden. Ist der Detektiv getrennt, nimmt der Raum keine
/// Figur an, auch nicht die Täterrolle; den Sitz übernimmt der Platz ohne Figur. Beide
/// tauschen die Plätze, die Klasse bleibt beim Sitz, kein Dossier wechselt den Platz.
/// Der alte Detektiv kommt zurück und sitzt ohne Figur am Tisch; der neue ermittelt den
/// Abend zu Ende. Alle Ansichten bleiben in der Sichtfeld-Liste.
Future<void> _detektivAusfall(Uri url) async {
  final all = <Client>[];
  try {
    _stage = 'Detektiv-Ausfall: Anmeldung';
    for (var i = 0; i < 23; i++) {
      final c = await Client.connect(url.toString(), 'Ausfallprobe-$i').timeout(const Duration(seconds: 10));
      all.add(c);
      await c.hello();
    }
    final host = all[0], alt = all[1];
    host.send({'t': Msg.create, 'abend': 'schlosskeller'});
    final room = await host.expect(Msg.room);
    final code = room['code'] as String;
    for (final c in all.skip(1)) {
      c.send({'t': Msg.join, 'code': code});
      await c.expect(Msg.room, where: (s) => s['code'] == code);
    }
    for (final c in all) {
      await c.expect(Msg.abend, where: (s) => _list(s['spieler']).length == all.length);
    }
    await _command(host, host, 'sitz', {'spieler': host.playerId, 'sitz': 'erzaehler'});
    await _command(host, host, 'sitz', {'spieler': alt.playerId, 'sitz': 'detektiv'});
    await _command(host, alt, 'sitz', {'spieler': alt.playerId, 'sitz': 'detektiv', 'klasse': 'forensic'});
    for (final c in all) {
      c.send({'t': Msg.abendCmd, 'c': {'typ': 'bereit', 'wert': true}});
    }
    await host.expect(Msg.abend, where: (s) => _list(s['spieler']).every((t) => t['bereit'] == true));
    final start = await _command(host, host, 'start', {'rollen': 20});
    final sitzeVorher = {for (final t in _list(start['spieler'])) t['id']: t['sitz']};
    final ohne = all.where((c) => sitzeVorher[c.playerId] == 'assistenz').toList();
    final rollen = all.where((c) => sitzeVorher[c.playerId] == 'rolle').toList();
    _require(ohne.length == 1 && rollen.length == 20, 'Detektiv-Ausfall: kein Platz ohne Figur neben zwanzig Figuren.');
    final neu = ohne.single;

    _stage = 'Detektiv-Ausfall: Rechte';
    host.send({'t': Msg.abendCmd, 'c': {'typ': 'detektivNeu', 'spieler': neu.playerId}});
    await host.expect(Msg.error, where: (s) => s['key'] == 'invalid');
    neu.send({'t': Msg.abendCmd, 'c': {'typ': 'detektivNeu', 'spieler': neu.playerId}});
    await neu.expect(Msg.error, where: (s) => s['key'] == 'not_host');
    final version = start['version'] as int;
    final dossiers = <String, String>{};
    String? taeter;
    for (final c in rollen) {
      final p = _map((await _sicht(c, version))['privat']);
      _require(p['rolle'] is String && p['dossier'] is Map, 'Detektiv-Ausfall: Figur ohne Dossier.');
      dossiers[c.playerId!] = jsonEncode(p['dossier']);
      if (_map(p['dossier']).containsKey('tatwissen')) taeter = c.playerId;
    }
    _require(taeter != null, 'Detektiv-Ausfall: Die Täterrolle sitzt an keinem Gerät.');

    _stage = 'Detektiv-Ausfall: Detektiv getrennt';
    await alt.close();
    await alt.closed.future.timeout(const Duration(seconds: 5));
    await host.expect(Msg.abend, where: (s) => _list(s['spieler']).any((t) => t['id'] == alt.playerId && t['online'] == false));
    // Keine Figur übernimmt den Sitz, die Täterrolle zuerst.
    for (final c in [rollen.firstWhere((c) => c.playerId == taeter), ...rollen.where((c) => c.playerId != taeter).take(2)]) {
      host.send({'t': Msg.abendCmd, 'c': {'typ': 'detektivNeu', 'spieler': c.playerId}});
      await host.expect(Msg.error, where: (s) => s['key'] == 'invalid');
    }
    await _command(host, host, 'detektivNeu', {'spieler': neu.playerId});
    final sicht = _map((await neu.expect(Msg.abend, where: (s) => _map(s['privat'])['detektiv'] == true))['privat']);
    _require(sicht['klasse'] == 'forensic' && !sicht.containsKey('dossier') && !sicht.containsKey('rolle'), 'Der neue Detektiv hat eine Figur oder keine Klasse.');
    final sitze = {for (final t in _list(host.latest(Msg.abend)['spieler'])) t['id']: t['sitz']};
    _require(sitze[neu.playerId] == 'detektiv' && sitze[alt.playerId] == 'assistenz', 'Die Sitze wurden nicht getauscht.');

    _stage = 'Detektiv-Ausfall: Rückkehr';
    final zurueck = await Client.connect(url.toString(), alt.name).timeout(const Duration(seconds: 10));
    all.add(zurueck);
    await zurueck.hello(token: alt.token);
    _require(zurueck.playerId == alt.playerId, 'Rückkehr wechselte die Spieler-ID.');
    final privat = _map((await zurueck.expect(Msg.abend, where: (s) => _map(s['privat'])['detektiv'] == false))['privat']);
    _require(!privat.containsKey('rolle') && !privat.containsKey('dossier') && !privat.containsKey('klasse'), 'Der alte Detektiv sitzt nicht ohne Figur am Tisch.');
    zurueck.send({'t': Msg.abendCmd, 'c': {'typ': 'fundGelesen'}});
    await zurueck.expect(Msg.error, where: (s) => s['key'] == 'not_detective');
    final nachher = host.latest(Msg.abend)['version'] as int;
    for (final c in rollen) {
      final p = _map((await _sicht(c, nachher))['privat']);
      _require(jsonEncode(p['dossier']) == dossiers[c.playerId], 'Detektiv-Ausfall: Ein Dossier hat den Platz gewechselt.');
    }

    // Der neue Detektiv ermittelt, der Erzähler (Gastgeber) führt weiter.
    var steps = 0;
    while (host.latest(Msg.abend)['phase'] != 'ende') {
      _require(++steps < 400, 'Detektiv-Ausfall: Der Abend erreicht das Ende nicht.');
      final s = host.latest(Msg.abend);
      _stage = 'Detektiv-Ausfall: Phase ${s['phase']}';
      switch (s['phase']) {
        case 'rollen':
          for (final c in rollen) {
            if (_map((await _sicht(c, s['version'] as int))['privat'])['gelesen'] == false) await _command(host, c, 'rollenGelesen');
          }
          await _command(host, host, 'weiter');
        case 'entscheidungen':
          if (s['zug'] case final Map z) {
            switch (z['phase']) {
              case 'aktion':
                await _command(host, neu, 'aktionFertig', {'aktion': z['aktion']});
              case 'wurf':
                await _command(host, [neu, zurueck, ...rollen].firstWhere((c) => c.playerId == s['wuerfelPate']), 'wurf');
              case 'tischruf':
                await _command(host, neu, 'tischruf', {'ruf': 'umweg'});
              case 'fund':
                await _command(host, neu, 'fundGelesen');
              default: throw StateError('Unbekannter Zugabschnitt.');
            }
          } else if (s['entscheidung'] case final Map e) {
            await _command(host, neu, 'wahl', {'option': _list(e['optionen']).first['id']});
          } else {
            await _command(host, host, 'weiter');
          }
        case 'gespraeche':
          final p = _map((await _sicht(neu, s['version'] as int))['privat']);
          _require(p['befragungen'] is List, 'Der neue Detektiv bekommt keine Befragungskarten.');
          var frei = p['befragungenFrei'] as int;
          for (final k in _list(p['befragungen'])) {
            if (k['erledigt'] == true) continue;
            if (k['frage'] == null) {
              if (k['pflicht'] != true) {
                if (frei <= 0) continue;
                frei--;
              }
              await _command(host, neu, 'befragen', {'id': k['id'], 'frage': 0});
            }
            if (k['mensch'] == true) await _command(host, neu, 'erledigt', {'id': k['id']});
          }
          await _command(host, host, 'weiter');
        case 'gruppenwahl':
          for (final c in rollen) {
            if (_map((await _sicht(c, s['version'] as int))['privat'])['hatGestimmt'] == false) await _command(host, c, 'stimme', {'kooperativ': true});
          }
          await _command(host, host, 'weiter');
        case 'anklage':
          await _command(host, neu, 'anklage', {'person': (s['verdaechtige'] as List).first});
          await _command(host, host, 'weiter');
        default:
          await _command(host, host, 'weiter');
      }
    }
    for (final c in all) {
      for (final view in c.inbox.where((m) => m['t'] == Msg.abend && !['finale', 'aufloesung', 'ende'].contains(m['phase']))) {
        _require(view.keys.every(raumOeffentlicheSchluessel.contains), 'Detektiv-Ausfall: nicht freigegebenes Feld vor dem Finale.');
        _require(_list(view['spieler']).every((t) => raumSpielerFelder.containsAll(t.keys)), 'Detektiv-Ausfall: nicht freigegebenes Spielerfeld.');
      }
    }
    print('PARTY-ONLINE OK · Ausfall des Gast-Detektivs · ${all.length - 1} Geräte, 20 Figuren · nur der Gastgeber vergibt den Sitz neu, keine Figur übernimmt, '
        'der Platz ohne Figur ermittelt, Plätze getauscht, Klasse beim Sitz, Dossiers am Platz, Abend zu Ende');
  } finally {
    for (final c in all) { if (!c.closed.isCompleted) c.send({'t': Msg.leave}); }
    await Future.wait(all.where((c) => !c.closed.isCompleted).map((c) => c.close().timeout(const Duration(seconds: 5))));
    await Future<void>.delayed(const Duration(milliseconds: 100));
  }
}

/// Server ohne festen Gastgeber, Akte [akte]: Der Gastgeber (Detektiv-Sitz) geht in
/// der ersten Entscheidung. Der neue Gastgeber vertritt ihn als Ermittler und Leiter
/// und führt den Abend zu Ende (vor M3 lief das über die Leitung allein).
Future<void> _hostwechsel(Uri url, String akte) async {
  final all = <Client>[];
  try {
    _stage = 'Host-Wechsel $akte: Anmeldung';
    for (var i = 0; i < 4; i++) {
      final c = await Client.connect(url.toString(), 'Wechselprobe-$i').timeout(const Duration(seconds: 10));
      all.add(c);
      await c.hello();
    }
    final alt = all.first, neu = all[1];
    alt.send({'t': Msg.create, 'abend': akte});
    final room = await alt.expect(Msg.room);
    _require(room['abend'] == akte, 'Falsche Akte beim Erstellen ($akte).');
    for (final c in all.skip(1)) {
      c.send({'t': Msg.join, 'code': room['code']});
      await c.expect(Msg.room, where: (s) => s['code'] == room['code']);
    }
    for (final c in all) {
      await c.expect(Msg.abend, where: (s) => _list(s['spieler']).length == all.length);
      c.send({'t': Msg.abendCmd, 'c': {'typ': 'bereit', 'wert': true}});
    }
    await alt.expect(Msg.abend, where: (s) => _list(s['spieler']).every((t) => t['bereit'] == true));
    await _command(alt, alt, 'start', {'rollen': 4});
    var leiter = alt;
    var online = List.of(all);
    var steps = 0;
    while (leiter.latest(Msg.abend)['phase'] != 'ende') {
      _require(++steps < 400, 'Host-Wechsel $akte: Der Abend erreicht das Ende nicht.');
      final s = leiter.latest(Msg.abend);
      if (leiter == alt && s['phase'] == 'entscheidungen') {
        _stage = 'Host-Wechsel $akte: Gastgeber geht';
        alt.send({'t': Msg.leave});
        final v = await neu.expect(Msg.abend, where: (m) => m['host'] == neu.playerId);
        _require(_map(v['privat'])['detektiv'] == true, 'Host-Wechsel $akte: Der neue Gastgeber vertritt den Detektiv nicht.');
        leiter = neu;
        online = all.skip(1).toList();
        continue;
      }
      switch (s['phase']) {
        case 'rollen':
          for (final c in online) {
            if (_map((await _sicht(c, s['version'] as int))['privat'])['gelesen'] == false) await _command(leiter, c, 'rollenGelesen');
          }
          await _command(leiter, leiter, 'weiter');
        case 'entscheidungen':
          if (s['zug'] case final Map z) {
            switch (z['phase']) {
              case 'aktion':
                await _command(leiter, leiter, 'aktionFertig', {'aktion': z['aktion']});
              case 'wurf':
                await _command(leiter, online.firstWhere((c) => c.playerId == s['wuerfelPate']), 'wurf');
              case 'tischruf':
                await _command(leiter, leiter, 'tischruf', {'ruf': 'umweg'});
              case 'fund':
                await _command(leiter, leiter, 'fundGelesen');
              default: throw StateError('Unbekannter Zugabschnitt.');
            }
          } else if (s['entscheidung'] case final Map e) {
            await _command(leiter, leiter, 'wahl', {'option': _list(e['optionen']).first['id']});
          } else {
            await _command(leiter, leiter, 'weiter');
          }
        case 'gespraeche':
          // Modell befragung: Der Vertreter bekommt die Befragungskarten des Detektivs.
          final privat = _map(s['privat']);
          if (privat['befragungen'] is List) {
            var frei = privat['befragungenFrei'] as int;
            for (final k in _list(privat['befragungen'])) {
              if (k['erledigt'] == true) continue;
              if (k['frage'] == null) {
                if (k['pflicht'] != true) {
                  if (frei <= 0) continue;
                  frei--;
                }
                await _command(leiter, leiter, 'befragen', {'id': k['id'], 'frage': 0});
              }
              if (k['mensch'] == true) await _command(leiter, leiter, 'erledigt', {'id': k['id']});
            }
          }
          await _command(leiter, leiter, 'weiter');
        case 'gruppenwahl':
          for (final c in online) {
            if (_map((await _sicht(c, s['version'] as int))['privat'])['hatGestimmt'] == false) await _command(leiter, c, 'stimme', {'kooperativ': true});
          }
          await _command(leiter, leiter, 'weiter');
        case 'anklage':
          await _command(leiter, leiter, 'anklage', {'person': (s['verdaechtige'] as List).first});
          await _command(leiter, leiter, 'weiter');
        default:
          await _command(leiter, leiter, 'weiter');
      }
    }
    _require(leiter == neu, 'Host-Wechsel $akte: Der Gastgeber ging nicht.');
    print('PARTY-ONLINE OK · Host-Wechsel nach dem Start · $akte · der neue Gastgeber ermittelt und führt den Abend zu Ende');
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
        // Alle Akten wie der Produktionsserver; der Schlosskeller wie bisher ohne Zusatzorte.
        abendFactories: {
          ...loadAktenFactories(partyDir),
          'schlosskeller': loadSchlosskellerFactory(partyDir),
          // Nur diese Matrix: der lange Abend als eigene Raumart (M7b).
          _langAbend: loadSchlosskellerFactory(partyDir, fassung: Abendfassung.lang),
        },
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
    // Je Laststufe alle drei Sitz-Konstellationen (M3), lokal dazu der lange Abend (M7b).
    final konstellationen = [for (final k in _konstellationen) if (remote == null || !k.lang) k];
    for (final n in counts) {
      for (final k in konstellationen) { await _batch(url, n, texte, k); }
    }
    // Host-Wechsel nach dem Start in jeder Akte (M3: der Detektiv-Sitz wandert nicht mit).
    final akten = [
      for (final a in (jsonDecode(File('${Directory(partyDir).parent.path}/akten.json').readAsStringSync())['akten'] as List)) (a as Map)['id'] as String,
    ];
    for (final akte in akten) { await _hostwechsel(url, akte); }
    // Fällt der Gast-Detektiv aus, vergibt der Gastgeber den Sitz neu (Nachschliff M3).
    await _detektivAusfall(url);
    _require(runtimeErrors == 0, 'Server meldete unerwartete Runtime-Fehler.');
    print('PARTY-ONLINE-MATRIX GRÜN · ${counts.length}/${counts.length} Laststufen × ${konstellationen.length} Sitz-Konstellationen, '
        'Host-Wechsel in ${akten.length} Akten, Ausfall des Gast-Detektivs; App-Bedienung und öffentliche Bereitstellung separat abnehmen.');
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
