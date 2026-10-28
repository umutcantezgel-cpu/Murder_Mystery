// Finale Schlosskeller über das Relais (Protokoll 5): Einstimmung und „Dein Moment“ kommen über die Meta des
// Gastgebers in den Raum, wie die übrigen Einstellungen. Alle sehen dieselbe öffentliche Ansicht, den
// Vorlesetext der Einstimmung nur der Vorleser, das Lauschergebnis nur der Lauscher, die Zug-Tafel nur der
// Erzähler. Der letzte Aufruf rechnet mit der Abendzeit des Gastgebers; ein Gast, der geht, zieht als Bot.
import 'dart:convert';

import 'package:mordakte_core/runden.dart' show ProtokollRaum, momentAufrufFrist;
import 'package:mordakte_netz/mordakte_netz.dart';
import 'package:test/test.dart';

import 'relay_hilfe.dart';

Matcher _fehler(String key) => throwsA(isA<AbendFehler>().having((e) => e.key, 'key', key));

Map<String, Object?> _m(Object? v) => (v as Map).cast<String, Object?>();
List<Map<String, Object?>> _l(Object? v) => [for (final x in v as List) _m(x)];

/// Gerät mit der Kennung [id] (Gastgeberplatz oder Gast).
AbendVerbindung _geraet(Abend a, String id) => id == 'host' ? a.hostPlatz : a.gaeste.firstWhere((g) => g.spielerId == id);

/// Erledigt die Befragungen des Gastgebers (Detektiv-Sitz) in den Gesprächen.
Future<void> _befragungen(Abend a) async {
  final karten = privat(a.hostPlatz.letzteAnsicht!);
  if (karten['befragungen'] is! List) return;
  var frei = karten['befragungenFrei'] as int;
  for (final k in _l(karten['befragungen'])) {
    if (k['erledigt'] == true) continue;
    if (k['frage'] == null) {
      if (k['pflicht'] != true) {
        if (frei <= 0) continue;
        frei--;
      }
      await a.hostPlatz.befehl({'typ': 'befragen', 'id': k['id'], 'frage': 0});
    }
    if (k['mensch'] == true) await a.hostPlatz.befehl({'typ': 'erledigt', 'id': k['id']});
  }
}

/// Ein Schritt außerhalb der Gespräche: Der Gastgeber ermittelt, [leiter] geht weiter.
Future<void> _schritt(Abend a, AbendVerbindung leiter) async {
  final s = a.hostPlatz.letzteAnsicht!;
  switch (s['phase']) {
    case 'entscheidungen':
      if (s['zug'] case final Map z) {
        switch (z['phase']) {
          case 'aktion':
            await a.hostPlatz.befehl({'typ': 'aktionFertig', 'aktion': z['aktion']});
          case 'wurf':
            await _geraet(a, s['wuerfelPate'] as String).befehl({'typ': 'wurf'});
          case 'tischruf':
            await a.hostPlatz.befehl({'typ': 'tischruf', 'ruf': 'umweg'});
          case 'fund':
            await a.hostPlatz.befehl({'typ': 'fundGelesen'});
        }
      } else if (s['entscheidung'] case final Map e) {
        await a.hostPlatz.befehl({'typ': 'wahl', 'option': _l(e['optionen']).first['id']});
      } else {
        await leiter.befehl({'typ': 'weiter'});
      }
    case 'anklage':
      await a.hostPlatz.befehl({'typ': 'anklage', 'person': 'ahmet'});
      await leiter.befehl({'typ': 'weiter'});
    default:
      await leiter.befehl({'typ': 'weiter'});
  }
}

Future<void> _bisGespraeche(Abend a, AbendVerbindung leiter, int runde) async {
  for (var i = 0; i < 200; i++) {
    final s = a.hostPlatz.letzteAnsicht!;
    if (s['phase'] == 'gespraeche' && s['runde'] == runde) return;
    await _schritt(a, leiter);
  }
  fail('Runde $runde nicht erreicht');
}

void main() {
  test('Einstimmung über die Meta: alle sehen denselben Schritt, den Text nur der Vorleser; Weiter erst danach', () async {
    final a = await Abend.starten(einstimmung: true);
    addTearDown(a.schliessen);
    expect(a.host.meta['einstimmung'], isTrue);
    expect(a.host.meta.containsKey('einfluss'), isFalse);
    for (var i = 0; i < 3; i++) {
      await a.gast(i);
    }
    final erzaehler = a.gaeste[0];
    await a.hostPlatz.befehl({'typ': 'sitz', 'spieler': erzaehler.spielerId, 'sitz': 'erzaehler'});
    await a.startet();
    for (final g in a.gaeste.skip(1)) {
      await g.befehl({'typ': 'rollenGelesen'});
    }
    await erzaehler.befehl({'typ': 'weiter'});
    await warteBis(() => a.gaeste.every((g) => a.aktuell(g) && g.letzteAnsicht!['einstimmung'] is Map));
    final schritt = _m(erzaehler.letzteAnsicht!['einstimmung']);
    expect(schritt['schritt'], 0);
    expect({for (final g in a.gaeste) jsonEncode(g.letzteAnsicht!['einstimmung'])}, hasLength(1));
    final text = privat(erzaehler.letzteAnsicht!)['einstimmungText'] as String;
    for (final v in [a.hostPlatz.letzteAnsicht!, ...a.gaeste.skip(1).map((g) => g.letzteAnsicht!)]) {
      expect(privat(v).containsKey('einstimmungText'), isFalse);
      expect(jsonEncode(v).contains(roh(text)), isFalse);
    }
    await expectLater(a.gaeste[1].befehl({'typ': 'einstimmung', 'schritt': 0}), _fehler('not_host'));
    await expectLater(erzaehler.befehl({'typ': 'weiter'}), _fehler('not_ready'));
    await expectLater(erzaehler.befehl({'typ': 'einstimmung', 'schritt': 5}), _fehler('stale'));
    await erzaehler.befehl({'typ': 'einstimmung', 'schritt': 0});
    await warteBis(() => a.gaeste.every((g) => a.aktuell(g) && _m(g.letzteAnsicht!['einstimmung'])['schritt'] == 1));
    // Die Wiederherstellung aus dem Protokoll und der Meta steht am selben Schritt.
    final wieder = ProtokollRaum.wiederherstellen((a.host.raum as ProtokollRaum).protokoll, () => a.fabrik(a.host.raumCode, a.host.meta));
    for (final g in a.gaeste) {
      expect(jsonEncode(wieder.zustandFuer(g.spielerId!)), jsonEncode(a.host.raum.zustandFuer(g.spielerId!)));
    }
    while (erzaehler.letzteAnsicht!['einstimmung'] is Map) {
      await erzaehler.befehl({'typ': 'einstimmung', 'ueberspringen': true});
      await warteBis(() => a.aktuell(erzaehler));
    }
    await warteBis(() => a.gaeste.every((g) => a.aktuell(g) && !g.letzteAnsicht!.containsKey('einstimmung')));
    expect(erzaehler.letzteAnsicht!['kannWeiter'], isTrue);
  });

  test('Dein Moment über die Meta: Züge, Lauschen, Tafel, letzter Aufruf mit der Uhr des Gastgebers, Bot-Ersatz', () async {
    var jetzt = 1000000;
    final a = await Abend.starten(einfluss: true, abendzeit: () => jetzt);
    addTearDown(a.schliessen);
    expect(a.host.meta['einfluss'], isTrue);
    for (var i = 0; i < 3; i++) {
      await a.gast(i);
    }
    final erzaehler = a.gaeste[0], g1 = a.gaeste[1], g2 = a.gaeste[2];
    await a.hostPlatz.befehl({'typ': 'sitz', 'spieler': erzaehler.spielerId, 'sitz': 'erzaehler'});
    await a.startet();
    final r1 = privat(g1.letzteAnsicht!)['rolle'] as String, r2 = privat(g2.letzteAnsicht!)['rolle'] as String;
    expect(_m(g1.letzteAnsicht!['einfluss'])['runde'], 0);
    await expectLater(g1.befehl({'typ': 'zug', 'art': 'helfen'}), _fehler('invalid_phase'));
    for (final g in [g1, g2]) {
      await g.befehl({'typ': 'rollenGelesen'});
    }
    await _bisGespraeche(a, erzaehler, 1);

    // Runde 1: g1 lauscht bei g2, g2 zeigt auf g1; der Detektiv zieht nicht.
    await expectLater(a.hostPlatz.befehl({'typ': 'zug', 'art': 'helfen'}), _fehler('invalid'));
    await expectLater(erzaehler.befehl({'typ': 'zug', 'art': 'helfen'}), _fehler('invalid'));
    await _befragungen(a);
    await expectLater(erzaehler.befehl({'typ': 'weiter'}), _fehler('not_ready'));
    await g1.befehl({'typ': 'zug', 'art': 'lauschen', 'ziel': r2});
    await g2.befehl({'typ': 'zug', 'art': 'ablenken'});
    await g2.befehl({'typ': 'zug', 'art': 'zeigen', 'ziel': r1}); // geändert bis zu den Folgen
    await warteBis(() => a.gaeste.every(a.aktuell));
    for (final v in [a.hostPlatz.letzteAnsicht!, ...a.gaeste.map((g) => g.letzteAnsicht!)]) {
      expect(_m(v['einfluss'])['gezogen'], unorderedEquals([r1, r2]));
      expect(jsonEncode({...v, 'privat': null}), isNot(contains('lauschen')), reason: 'nie was');
    }
    final tafel = _m(privat(erzaehler.letzteAnsicht!)['einflussTafel']);
    expect(_l(tafel['zuege']), unorderedEquals([
      {'rolle': r1, 'art': 'lauschen', 'ziel': r2},
      {'rolle': r2, 'art': 'zeigen', 'ziel': r1},
    ]));
    for (final v in [a.hostPlatz.letzteAnsicht!, g1.letzteAnsicht!, g2.letzteAnsicht!]) {
      expect(privat(v).containsKey('einflussTafel'), isFalse);
    }
    await erzaehler.befehl({'typ': 'weiter'});
    await warteBis(() => a.gaeste.every((g) => a.aktuell(g) && g.letzteAnsicht!['phase'] == 'entscheidungen'));
    final gelauscht = _l(_m(privat(g1.letzteAnsicht!)['moment'])['gelauscht']);
    expect(gelauscht.single, containsPair('figur', r2));
    expect(gelauscht.single, containsPair('zug', 'zeigen'));
    for (final v in [a.hostPlatz.letzteAnsicht!, erzaehler.letzteAnsicht!, g2.letzteAnsicht!]) {
      expect(privat(v)['moment'] is Map ? _m(privat(v)['moment']).containsKey('gelauscht') : false, isFalse);
    }
    expect({for (final g in a.gaeste) jsonEncode({...g.letzteAnsicht!, 'privat': null})}, hasLength(1), reason: 'öffentlich für alle gleich');
    final folgen = _l(_m(g1.letzteAnsicht!['einfluss'])['folgen']).single;
    expect(folgen['geruechte'], ['einfluss.geruecht.leise@$r1']);

    // Runde 2: g2 geht (nach der Frist nimmt der Gastgeber ihn heraus), g1 zieht nicht; letzter Aufruf.
    await _bisGespraeche(a, erzaehler, 2);
    await g2.verlassen();
    await warteBis(() => (spieler(a.hostPlatz.letzteAnsicht!, g2.spielerId!)['online']) == false);
    await _befragungen(a);
    await expectLater(erzaehler.befehl({'typ': 'weiter'}), _fehler('not_ready'));
    await expectLater(g1.befehl({'typ': 'letzterAufruf'}), _fehler('not_host'));
    await erzaehler.befehl({'typ': 'letzterAufruf', 'zeit': 1});
    await warteBis(() => a.aktuell(erzaehler));
    expect(_m(erzaehler.letzteAnsicht!['einfluss'])['aufruf'], jetzt, reason: 'die Abendzeit des Gastgebers, nicht die mitgeschickte');
    jetzt += momentAufrufFrist - 1;
    await expectLater(erzaehler.befehl({'typ': 'weiter'}), _fehler('not_ready'));
    jetzt += 1;
    await erzaehler.befehl({'typ': 'weiter'});
    await warteBis(() => a.aktuell(erzaehler) && erzaehler.letzteAnsicht!['phase'] == 'entscheidungen');
    final zuege = _l(_m(privat(erzaehler.letzteAnsicht!)['einflussTafel'])['zuege']);
    expect(zuege.firstWhere((z) => z['rolle'] == r1), {'rolle': r1, 'art': 'abgewartet'});
    expect(zuege.firstWhere((z) => z['rolle'] == r2)['bot'], isTrue, reason: 'der gegangene Platz zieht als Bot');
  });
}
