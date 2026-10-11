import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:mordakte_netz/io.dart';
import 'package:mordakte_netz/mordakte_netz.dart';
import 'package:test/test.dart';

const _topic = 'mordakte:v1:AYYEHJ:gagjzfqdxevewopn';

typedef _Schluessel = ({Sitzungsschluessel host, Sitzungsschluessel gast});

/// Beide Richtungsschlüssel eines Sitzes, über echte X25519/HKDF-Ableitung.
Future<_Schluessel> _schluessel() async {
  final host = await Schluesselpaar.erzeugen(Random(3));
  final gast = await Schluesselpaar.erzeugen(Random(4));
  final kh = await Sitzungsschluessel.ableiten(eigen: host, fremdOeffentlich: gast.oeffentlich, code: host.raumCode, epoch: 1, cid: gast.cid);
  final kg = await Sitzungsschluessel.ableiten(eigen: gast, fremdOeffentlich: host.oeffentlich, code: host.raumCode, epoch: 1, cid: gast.cid);
  return (host: kh, gast: kg);
}

UmschlagPaar _paar(String seite, Sitzungsschluessel k, {String topic = _topic}) =>
    UmschlagPaar(topic: topic, eigeneSeite: seite, schluessel: k, zufall: Random(seite == 'h' ? 10 : 11));

/// Kopie eines Umschlags mit einzelnen geänderten Feldern.
Map<String, Object?> _kopie(Map<String, Object?> u, {String? ct, String? iv, Object? n, Object? s}) => {
      ...u,
      if (ct != null) 'ct': ct,
      if (iv != null) 'iv': iv,
      if (n != null) 'n': n,
      if (s != null) 's': s,
    };

/// Ein Bit im Klartext-Byte [idx] kippen, wieder als Base64.
String _kippe(String b64, int idx) {
  final b = base64Decode(b64);
  b[idx] ^= 1;
  return base64Encode(b);
}

final _nonce = base64Encode(List<int>.filled(12, 0));

Future<void> _warteBis(bool Function() bedingung) async {
  final ende = DateTime.now().add(const Duration(seconds: 15));
  while (!bedingung()) {
    if (DateTime.now().isAfter(ende)) fail('Zeitüberschreitung');
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
}

void main() {
  group('Umschlag: Verschlüsselung', () {
    test('Roundtrip in beide Richtungen, Form und Zählnummer', () async {
      final k = await _schluessel();
      final h = _paar('h', k.host);
      final g = _paar('c', k.gast);
      final msg = {'t': 'abend', 'v': 1, 'text': 'Ünïcode ✓'};
      final u = await h.verpacken(msg);
      expect(u.keys, unorderedEquals(['s', 'n', 'iv', 'ct']));
      expect(u['s'], 'h');
      expect(u['n'], 1);
      expect(base64Decode(u['iv'] as String).length, 12);
      expect(base64Decode(u['ct'] as String).length, utf8.encode(jsonEncode(msg)).length + 16, reason: 'Chiffretext + 16-Byte-Tag');
      final o = await g.oeffnen(u);
      expect(o?.nachricht, msg);
      expect(o?.n, 1);

      final zurueck = await h.oeffnen(await g.verpacken({'t': 'befehl', 'q': 7}));
      expect(zurueck?.nachricht, {'t': 'befehl', 'q': 7});
      expect(zurueck?.n, 1);
    });

    test('Manipulation an ct, Tag, iv, n oder s wird abgelehnt, ohne den Zähler vorzurücken', () async {
      final k = await _schluessel();
      final h = _paar('h', k.host);
      final g = _paar('c', k.gast);
      final u = await h.verpacken({'t': 'abend'});
      final ct = u['ct'] as String, iv = u['iv'] as String;
      final gefaelscht = <String, Map<String, Object?>>{
        'ct': _kopie(u, ct: _kippe(ct, 0)),
        'Tag': _kopie(u, ct: _kippe(ct, base64Decode(ct).length - 1)),
        'iv': _kopie(u, iv: _kippe(iv, 3)),
        'n': _kopie(u, n: 2),
        's': _kopie(u, s: 'c'),
      };
      for (final e in gefaelscht.entries) {
        expect(await g.oeffnen(e.value), isNull, reason: 'Feld ${e.key}');
      }
      expect(g.empfangenN, 0);
      expect((await g.oeffnen(u))?.n, 1, reason: 'Das echte Paket geht danach noch durch');
    });

    test('Fremdes Thema lehnt einen Umschlag ab (Thema ist Teil der Zugehörigkeitsdaten)', () async {
      final k = await _schluessel();
      final u = await _paar('h', k.host).verpacken({'t': 'abend'});
      final anderes = _paar('c', k.gast, topic: 'mordakte:v1:AYYEHJ:anderer');
      expect(await anderes.oeffnen(u), isNull);
      expect((await _paar('c', k.gast).oeffnen(u))?.n, 1);
    });

    test('Wiederholung und nicht steigende Zählnummer werden verworfen', () async {
      final k = await _schluessel();
      final h = _paar('h', k.host);
      final g = _paar('c', k.gast);
      final u1 = await h.verpacken({'i': 1});
      final u2 = await h.verpacken({'i': 2});
      final u3 = await h.verpacken({'i': 3});
      expect((await g.oeffnen(u3))?.n, 3);
      expect(await g.oeffnen(u3), isNull, reason: 'Wiederholung');
      expect(await g.oeffnen(u2), isNull, reason: 'älter als das größte geöffnete n');
      expect(await g.oeffnen(u1), isNull);
      expect(g.empfangenN, 3);
      expect((await g.oeffnen(await h.verpacken({'i': 4})))?.n, 4);

      final frisch = _paar('c', k.gast)..empfangsUntergrenze(10);
      expect(await frisch.oeffnen(await h.verpacken({'i': 5})), isNull, reason: 'unterhalb der Untergrenze');
    });

    test('Eigene Umschläge und Umschläge der falschen Seite werden abgelehnt', () async {
      final k = await _schluessel();
      final h = _paar('h', k.host);
      final g = _paar('c', k.gast);
      expect(await h.oeffnen(await h.verpacken({'x': 1})), isNull, reason: 'eigene Seite');
      expect(await g.oeffnen(await g.verpacken({'y': 1})), isNull, reason: 'eigene Seite');
      expect((await h.oeffnen(await g.verpacken({'y': 2})))?.nachricht, {'y': 2});
    });

    test('Zu kurz, zu groß, falsche Felder und Müll werden abgelehnt', () async {
      final k = await _schluessel();
      final g = _paar('c', k.gast);
      Map<String, Object?> rahmen({required Object? ct, String? iv, Object? n = 1}) => {'s': 'h', 'n': n, 'iv': iv ?? _nonce, 'ct': ct};
      final faelle = <String, Object?>{
        'Chiffretext ohne Tag': rahmen(ct: base64Encode(List<int>.filled(15, 0))),
        'Chiffretext über der Grenze': rahmen(ct: base64Encode(List<int>.filled(maxUmschlagZeichen + 1, 0))),
        'iv mit 11 Byte': rahmen(ct: base64Encode(List<int>.filled(20, 0)), iv: base64Encode(List<int>.filled(11, 0))),
        'kein Base64': rahmen(ct: '%%%'),
        'n als Text': rahmen(ct: base64Encode(List<int>.filled(20, 0)), n: '1'),
        'kein Objekt': 'Umschlag',
        'null': null,
      };
      for (final e in faelle.entries) {
        expect(await g.oeffnen(e.value), isNull, reason: e.key);
      }
      expect(g.empfangenN, 0);
    });

    test('Eine große Ansicht (150 KB Klartext) geht durch die Grenze', () async {
      final k = await _schluessel();
      final gross = 'x' * 150000;
      final u = await _paar('h', k.host).verpacken({'text': gross});
      expect((await _paar('c', k.gast).oeffnen(u))?.nachricht['text'], gross);
    });
  });

  test('Gleichzeitige Sendungen kommen vollständig und in Reihenfolge an', () async {
    final a = await PhoenixAttrappe.starten();
    addTearDown(a.schliessen);
    final k = await _schluessel();
    final hs = PhoenixSocket(relaySocketUri(url: a.url, schluessel: a.schluessel));
    final gs = PhoenixSocket(relaySocketUri(url: a.url, schluessel: a.schluessel));
    addTearDown(() async {
      await hs.schliessen();
      await gs.schliessen();
    });
    await hs.verbinde();
    await gs.verbinde();
    final hk = hs.kanal(_topic, presence: false);
    final gk = gs.kanal(_topic, presence: false);
    await hk.beitreten();
    await gk.beitreten();

    final hp = _paar('h', k.host);
    final gp = _paar('c', k.gast);
    final empfangen = <int>[];
    final zaehler = <int>[];
    gk.nachrichten.listen((m) {
      unawaited(gp.oeffnen(m.payload).then((g) {
        if (g == null) return;
        empfangen.add(g.nachricht['i'] as int);
        zaehler.add(g.n);
      }));
    });

    // Alle 60 Sendungen ohne Warten: Verschlüsselung und Versand laufen geordnet
    // hintereinander, die Öffnung auf der Gegenseite darf sich nicht überholen.
    final ok = await Future.wait([for (var i = 0; i < 60; i++) hp.senden(hk, {'i': i, 'pad': 'x' * 2000})]);
    expect(ok, everyElement(isTrue));
    await _warteBis(() => empfangen.length == 60);
    expect(empfangen, List<int>.generate(60, (i) => i));
    expect(zaehler, List<int>.generate(60, (i) => i + 1));
  });
}
