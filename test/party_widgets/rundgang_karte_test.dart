// M7b: Die Karte von Vorspiel und Morgen (RundgangKarte). Jede Station ist in
// ihrer Lage erreichbar, der Detektiv steht in jedem Bild frei; erst am Ziel
// stellt die Uhrzeit der Station die Tore (die Sperre um zehn vor sieben erst im
// Keller, am Morgen der Torschlüssel der Kollegin). Figuren der Station stehen
// auf ihrer Ebene, im Keller alle übrigen an ihren Ermittlungsorten. Am Morgen
// draußen Tageslicht, im Keller und im Vorspiel nie.
import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mordakte/party/rundgang_karte.dart';
import 'package:mordakte_core/mordakte_core.dart';

import 'hilfe.dart';
import 'rundgang_hilfe.dart';

const _dt = 1 / 60;

RundgangKarte _karte(Rundgang r, {int station = 0}) {
  final k = RundgangKarte(rundgangDaten, weltEbenen, ebenenSzenarien, r, station: station, detektivName: 'Dana');
  addTearDown(k.dispose);
  return k;
}

Offset _pos(RundgangKarte k) {
  final d = k.world.value!.detectives.single;
  return Offset(d.x, d.y);
}

/// Treibt den Weg Bild für Bild; in jedem Bild steht der Detektiv frei.
Future<bool> _treibe(RundgangKarte k, Future<bool> weg) async {
  bool? ergebnis;
  unawaited(weg.then((x) => ergebnis = x));
  for (var n = 0; ergebnis == null && n < 120 * 60; n++) {
    k.szenenSchritt(_dt);
    final p = _pos(k);
    expect(k.rasterVon(k.aktuelleEbene).canStand(p.dx, p.dy, Tuning.playerRadius), isTrue, reason: 'Bild $n auf ${k.aktuelleEbene} bei $p in Wand oder Möbel');
    await Future<void>.delayed(Duration.zero);
  }
  await Future<void>.delayed(Duration.zero);
  expect(ergebnis, isNotNull, reason: 'Der Weg endet');
  return ergebnis!;
}

/// Renderer-Kennungen der Figuren im letzten Bild der Welt.
Map<String, Offset> _figuren(RundgangKarte k) => {for (final n in k.world.value!.npcs) n.id: Offset(n.x, n.y)};

/// Passierbare Portale der gezeigten Ebene (offene Hotspots).
Set<String> _portale(RundgangKarte k) => {for (final e in k.caseView.value!.hotspots.entries) if (e.value == HotspotState.open) e.key};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final v = rundgangDaten.vorspielMorgen!;
  final ermittlung = {for (final f in rundgangDaten.karte.figuren) rundgangDaten.npcKennung[f.id]!: Offset(f.x, f.y)};

  test('Vorspiel: von Station zu Station, jedes Bild frei, die Tore der Station erst am Ziel', () async {
    final r = v.vorspiel;
    final k = _karte(r);
    expect([k.aktuelleEbene, k.lage.uhr], [r.startEbene, r.startZeit]);
    for (final (i, st) in r.stationen.indexed) {
      final weg = k.geheZu(i);
      expect(k.lage.uhr, r.wegLage(i).uhr, reason: '${st.id}: unterwegs gilt die Lage davor');
      expect(await _treibe(k, weg), isTrue, reason: st.id);
      expect(k.aktuelleEbene, st.ebene, reason: st.id);
      final o = weltEbenen.ebenen[st.ebene]!.graph.orte[st.ort]!;
      expect((_pos(k) - Offset(o.x, o.y)).distance, lessThanOrEqualTo(1.5), reason: '${st.id}: am Ort ${st.ort}');
      expect(k.lage.uhr, st.zeit, reason: '${st.id}: am Ziel gilt die Uhrzeit der Station');
      expect(k.tageslicht, isFalse, reason: '${st.id}: Das Vorspiel ist am Abend');
      final figuren = _figuren(k);
      for (final f in st.figuren) {
        final p = weltEbenen.ebenen[st.ebene]!.graph.orte[f.ort]!;
        expect(figuren[rundgangDaten.npcKennung[f.figur]], Offset(p.x, p.y), reason: '${st.id}: ${f.figur} an ${f.ort}');
      }
      if (st.ebene != kellerEbene) {
        expect(figuren.keys.toSet(), {for (final f in st.figuren) rundgangDaten.npcKennung[f.figur]}, reason: '${st.id}: draußen nur die Figuren der Station');
      }
    }
    // Die Sperre: Im Keller angekommen, schließt Herr Schneider ab. Offen bleibt nur die Wendeltreppe.
    expect(k.aktuelleEbene, kellerEbene);
    expect(_portale(k), {'p_wendeltreppe'});
    expect(_figuren(k).length, ermittlung.length, reason: 'Im Keller ist die Feier: alle an ihren Plätzen');
  });

  test('Morgen: aus dem Keller nach draußen, Tageslicht unter freiem Himmel, Einfahrtstor und Außentor offen', () async {
    final r = v.morgen;
    final k = _karte(r);
    expect(k.aktuelleEbene, kellerEbene);
    expect([k.tageslicht, k.licht!.tag], [false, false], reason: 'Der Keller ist nie Tag');
    expect(_portale(k), containsAll(['p_aussentor', 'p_hoftuer', 'p_wendeltreppe']));
    // Herr Schneider steht vor dem Tor, nicht mehr im Keller.
    final schneider = rundgangDaten.npcKennung['schneider']!;
    expect(_figuren(k).containsKey(schneider), isFalse);
    for (final (i, st) in r.stationen.indexed) {
      expect(await _treibe(k, k.geheZu(i)), isTrue, reason: st.id);
      expect(k.aktuelleEbene, st.ebene, reason: st.id);
      final e = weltEbenen.ebenen[st.ebene]!;
      final o = e.graph.orte[st.ort]!;
      final draussen = e.aussen.contains(e.graph.raumAn(o.x, o.y)?.id);
      expect(draussen, isTrue, reason: '${st.id}: Der Morgen läuft draußen');
      expect([k.tageslicht, k.licht!.tag], [true, true], reason: '${st.id}: Tageslicht');
      if (st.ebene == 'erdgeschoss' || st.ebene == 'aussen') expect(_portale(k), contains('p_einfahrtstor'), reason: st.id);
    }
    // Wer zurück in den Keller geht, hat dort wieder das Licht der Nacht.
    await k.zurueckInDenKeller();
    for (var i = 0; i < 120 * 60 && k.laeuft; i++) {
      k.szenenSchritt(_dt);
      await Future<void>.delayed(Duration.zero);
    }
    expect([k.aktuelleEbene, k.tageslicht], [kellerEbene, false]);
  });

  test('Ein neuer Schritt löst den alten ab: Kurzblende ans alte Ziel, dann gilt nur noch die neue Station', () async {
    final r = v.vorspiel;
    final k = _karte(r);
    final erster = k.geheZu(3);
    k.szenenSchritt(_dt);
    final zweiter = k.geheZu(5);
    expect(await erster, isFalse, reason: 'abgelöst');
    expect(await _treibe(k, zweiter), isTrue);
    expect([k.aktuelleEbene, k.lage.uhr, k.station], [kellerEbene, r.stationen[5].zeit, 5]);
  });

  test('Bewegung reduziert: Jede Station per Kurzblende, Lage und Ort wie beim Gehen', () async {
    final r = v.morgen;
    final k = _karte(r, station: 2)..bewegungReduziert = true;
    // Fortsetzen mitten im Morgen: Der Detektiv steht an der Station davor.
    expect(k.aktuelleEbene, r.stationen[1].ebene);
    for (var i = 2; i < r.stationen.length; i++) {
      expect(await k.geheZu(i), isTrue);
      expect([k.aktuelleEbene, k.lage.uhr, k.laeuft], [r.stationen[i].ebene, r.stationen[i].zeit, false]);
    }
  });
}
