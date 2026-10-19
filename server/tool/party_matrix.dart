/// Echte WebSocket-Clients in EINEM Schlosskeller-Raum, 4–20 Laststufen, je in
/// drei Sitz-Konstellationen (Host = Erzähler + Gast = Detektiv, Host = Detektiv
/// ohne Erzähler, Host = Detektiv + Gast = Erzähler).
/// Vollständiger Abend, eigene Rollenansichten, Sitze, Vorleser-Sitz, Rechte,
/// Reconnect, Würfelprüfung.
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

Future<void> _health(Uri url) async {
  final http = HttpClient();
  try {
    final req = await http.getUrl(url.replace(scheme: url.scheme == 'wss' ? 'https' : 'http', path: '/health')).timeout(const Duration(seconds: 10));
    final res = await req.close().timeout(const Duration(seconds: 10));
    final text = await res.transform(utf8.decoder).join().timeout(const Duration(seconds: 10));
    _require(res.statusCode == 200 && text.startsWith('ok rooms='), 'Healthcheck nicht grün.');
  } finally { http.close(force: true); }
}

/// Sitze eines Laufs (M3): Client 0 öffnet den Raum, Client 1 ist der Gast mit Sitz.
typedef _Konstellation = ({String name, String hostSitz, String? gastSitz});

const _konstellationen = <_Konstellation>[
  (name: 'Host = Erzähler + Gast = Detektiv', hostSitz: 'erzaehler', gastSitz: 'detektiv'),
  (name: 'Host = Detektiv ohne Erzähler', hostSitz: 'detektiv', gastSitz: null),
  (name: 'Host = Detektiv + Gast = Erzähler', hostSitz: 'detektiv', gastSitz: 'erzaehler'),
];

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
    while (host.latest(Msg.abend)['phase'] != 'ende') {
      _require(++steps < 400, 'Partyabend erreicht das Ende nicht.');
      final s = host.latest(Msg.abend);
      switch (s['phase']) {
        case 'rollen':
          for (final c in rollenC) { await _command(host, c, 'rollenGelesen'); }
          await _command(host, leiterC, 'weiter');
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
    print('PARTY-ONLINE OK · ${k.name} · $count Clients in einem Raum · $rollen Rollen · vollständiger Abend, eigene Karten, Sitze, Vorleser, Rechte, Reconnect, Würfel, Isolation, Health');
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
    // Je Laststufe alle drei Sitz-Konstellationen (M3).
    for (final n in counts) {
      for (final k in _konstellationen) { await _batch(url, n, texte, k); }
    }
    _require(runtimeErrors == 0, 'Server meldete unerwartete Runtime-Fehler.');
    print('PARTY-ONLINE-MATRIX GRÜN · ${counts.length}/${counts.length} Laststufen × ${_konstellationen.length} Sitz-Konstellationen; '
        'App-Bedienung und öffentliche Bereitstellung separat abnehmen.');
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
