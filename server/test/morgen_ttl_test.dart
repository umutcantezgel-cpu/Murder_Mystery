// M7b: Server-TTL im langen Abend. Ein beendeter Raum verfällt nach
// finishedRoomTtl. Im langen Abend gilt der Raum erst nach dem Morgen als
// beendet: Solange der Rundgang am Morgen läuft, räumt der Server ihn nicht ab,
// auch wenn die Frist längst um ist. Kurze Abende enden wie bisher mit dem Ende.
import 'dart:async';

import 'package:mordakte_core/runden.dart';
import 'package:mordakte_server/party.dart';
import 'package:mordakte_server/rooms.dart';
import 'package:test/test.dart';

/// Verbindung ohne Netz: sammelt, was der Server schickt.
class _Link implements ClientLink {
  final gesendet = <String>[];

  @override
  String get label => 'test';

  @override
  void send(String text) => gesendet.add(text);

  @override
  void close(int code, String reason) {}
}

/// Spielt den Abend im Raum bis zum Ende, allein am Tisch: Der Gastgeber
/// ermittelt und leitet, alle Rollen sind Bots. Rundgänge am Morgen bleiben
/// offen; das Vorspiel überspringt der Gastgeber.
void _bisZumEnde(SchlosskellerRuntime r, String host) {
  String? befehl(Map<String, Object?> c) => r.applyAbendCommand(host, c);
  expect(befehl({'typ': 'bereit', 'wert': true}), isNull);
  expect(befehl({'typ': 'start', 'rollen': 4}), isNull);
  for (var i = 0; i < 800; i++) {
    final s = r.inner.zustandFuer(host);
    if (s['phase'] == 'ende') return;
    final Map<String, Object?> c;
    if (s['rundgang'] is Map) {
      c = {'typ': 'rundgang', 'ueberspringen': true};
    } else if (s['phase'] == 'gespraeche') {
      // Befragungen (A-051): feste, dann so viele freie, wie die Runde erlaubt; Bots antworten selbst.
      final privat = (s['privat'] as Map).cast<String, Object?>();
      final frei = privat['befragungenFrei'] as int? ?? 0;
      final offen = [
        for (final k in (privat['befragungen'] as List? ?? const []).cast<Map>())
          if (k['erledigt'] != true && k['frage'] == null && (k['pflicht'] == true || frei > 0)) k,
      ];
      offen.sort((a, b) => (a['pflicht'] == true ? 0 : 1).compareTo(b['pflicht'] == true ? 0 : 1));
      c = offen.isEmpty ? {'typ': 'weiter'} : {'typ': 'befragen', 'id': offen.first['id'], 'frage': 0};
    } else if (s['phase'] == 'entscheidungen' && s['zug'] is Map) {
      final z = (s['zug'] as Map).cast<String, Object?>();
      c = switch (z['phase']) {
        'aktion' => {'typ': 'aktionFertig', 'aktion': z['aktion']},
        'wurf' => {'typ': 'wurf'},
        'tischruf' => {'typ': 'tischruf', 'ruf': 'umweg'},
        _ => {'typ': 'fundGelesen'},
      };
    } else if (s['phase'] == 'entscheidungen' && s['entscheidung'] is Map) {
      c = {'typ': 'wahl', 'option': (((s['entscheidung'] as Map)['optionen'] as List).first as Map)['id']};
    } else if (s['phase'] == 'anklage' && s['kannWeiter'] != true) {
      c = {'typ': 'anklage', 'person': (s['verdaechtige'] as List).first};
    } else {
      c = {'typ': 'weiter'};
    }
    final fehler = befehl(c);
    expect(fehler, isNull, reason: '${s['phase']}: $c');
  }
  fail('Das Ende wurde nicht erreicht');
}

Future<void> _warte(Duration d) => Future<void>.delayed(d);

void main() {
  final partyDir = resolvePartyDir(null);
  const ttl = Duration(milliseconds: 250);

  RoomManager manager() {
    final m = RoomManager(
      runtimeFactory: (_) => throw StateError('kein klassischer Raum'),
      abendFactories: {
        'kurz': loadSchlosskellerFactory(partyDir),
        'lang': loadSchlosskellerFactory(partyDir, fassung: Abendfassung.lang),
      },
      finishedRoomTtl: ttl,
      emptyRoomTtl: const Duration(hours: 1),
      janitorInterval: const Duration(milliseconds: 20),
      log: (_) {},
    );
    addTearDown(m.close);
    return m;
  }

  (String, SchlosskellerRuntime, String) eroeffne(RoomManager m, String art) {
    final p = m.hello(_Link(), name: 'Anna')!;
    m.create(p, abend: art);
    final room = p.room!;
    return (room.code, room.runtime as SchlosskellerRuntime, p.id);
  }

  test('Lang: Solange der Morgen läuft, bleibt der Raum über die Frist hinaus; danach verfällt er', () async {
    final m = manager();
    final (code, r, host) = eroeffne(m, 'lang');
    _bisZumEnde(r, host);
    final s = r.inner.zustandFuer(host);
    expect([s['phase'], (s['rundgang'] as Map)['teil']], ['ende', 'morgen']);
    expect(r.finished, isFalse);
    await _warte(ttl * 4);
    expect(m.room(code), isNotNull, reason: 'Der Morgen läuft: kein Abräumen');
    // Die Gäste gehen den Morgen ab; erst nach der letzten Station ist der Abend beendet.
    expect(r.applyAbendCommand(host, {'typ': 'rundgang', 'station': 0}), isNull);
    await _warte(ttl * 2);
    expect(m.room(code), isNotNull);
    expect(r.applyAbendCommand(host, {'typ': 'rundgang', 'ueberspringen': true}), isNull);
    expect(r.finished, isTrue);
    await _warte(ttl ~/ 2);
    expect(m.room(code), isNotNull, reason: 'Die Frist beginnt erst jetzt');
    await _warte(ttl * 3);
    expect(m.room(code), isNull, reason: 'Nach dem Morgen und der Frist ist der Raum weg');
  });

  test('Kurz: Mit dem Ende ist der Raum beendet und verfällt nach der Frist wie bisher', () async {
    final m = manager();
    final (code, r, host) = eroeffne(m, 'kurz');
    _bisZumEnde(r, host);
    expect(r.inner.zustandFuer(host).containsKey('rundgang'), isFalse);
    expect(r.finished, isTrue);
    await _warte(ttl * 4);
    expect(m.room(code), isNull);
  });
}
