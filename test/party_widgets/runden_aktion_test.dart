import 'dart:math' as math;

import 'package:flame/game.dart' show Vector2;
import 'package:flutter_test/flutter_test.dart';
import 'package:mordakte/party/karte_session.dart';
import 'package:mordakte/party/sitzung.dart';
import 'package:mordakte/game/mordakte_game.dart';
import 'package:mordakte/game/szenen_erweiterung.dart';
import 'package:mordakte_core/mordakte_core.dart';
import 'package:mordakte_core/runden.dart';

import 'hilfe.dart';

PartyKartenSession karte(PartySitzung s) {
  final k = PartyKartenSession(s);
  addTearDown(k.dispose);
  return k;
}

const _akten = ['schlosskeller', 'gewoelbe', 'ravensmoor', 'nachtexpress', 'blue_palm'];

/// Eingerichteter Abend einer Akte mit höchstens [rollen] Rollen.
PartySitzung _sitzung(String akte, {int rollen = 7, String? pfad, WuerfelQuelle wuerfel = const FesterWuerfel.neutral()}) {
  final s = PartySitzung(akteDaten(akte), wuerfel: wuerfel);
  final n = math.min(rollen, s.kanon.besetzungJson['maxRollen'] as int);
  s.einrichten(rollen: n, detektiv: 'w', code: FallCode.fuerPfad(pfad ?? s.kanon.pfade.first, s.kanon.pfade).code);
  return s;
}

/// Der Detektiv bleibt nicht auf einer anderen Person stehen.
void keinePersonAmStand(PartySitzung s, PartyKartenSession k, String wo) {
  final (x, y) = k.kartenAktion!.weg.last;
  for (final f in s.karte.figuren) {
    expect(dist(x, y, f.x, f.y), greaterThanOrEqualTo(0.6), reason: '$wo: Standplatz ($x, $y) liegt auf ${f.id}');
  }
}

/// Echte, pro Frame aufgerufene Aktion. Kein aktionFertig und kein Teleport.
List<Object> laufen(PartySitzung s, PartyKartenSession k) {
  final raster = TileGrid(s.daten.szenario.map);
  final spur = <Object>[];
  final posen = <SzenenPose?>{};
  expect(k.aktionsFehler.value, isFalse);
  final dauer = k.kartenAktion!.dauer;
  expect(dauer, inInclusiveRange(4, 12));
  for (var frame = 0; frame < 750 && s.zug?.phase == RundenZugPhase.aktion; frame++) {
    posen.add(k.figurenPose);
    k.szenenSchritt(1 / 60);
    final d = k.world.value!.detectives.single;
    expect(raster.canStand(d.x, d.y, Tuning.playerRadius), isTrue, reason: 'Frame $frame: Figur schneidet eine Wand');
    if (frame % 15 == 0) spur.add((d.x, d.y, d.facing, k.figurenPose, d.moving));
  }
  expect(s.zug?.phase, isNot(RundenZugPhase.aktion));
  expect(posen.any((p) => p == SzenenPose.suchen || p == SzenenPose.befragen), isTrue);
  return spur;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final akte in _akten) {
    test('$akte: jedes Kanon-Ziel hat einen sichtbaren, kollisionsfreien Weg, eine Pose und keinen Stand auf einer Person', () {
      final daten = akteDaten(akte);
      var geprueft = 0;
      for (final ziel in daten.karte.ziele.values) {
        final s = _sitzung(akte);
        final e = s.karte.ermittlung.entscheidung(ziel.entscheidung);
        spieleBis(s, PartyPhase.entscheidungen, runde: e.runde);
        while (s.laufendeEntscheidung!.id != e.id) {
          s.schlageVor(s.laufendeEntscheidung!.optionen.first.id);
          s.bestaetigen();
          spieleZug(s);
        }
        final k = karte(s);
        final wuerfeVorher = s.wuerfe.length;
        s.schlageVor(ziel.option);
        s.bestaetigen();
        expect(s.letzterFund, isNull);
        expect(s.laufendeEntscheidung, isNull);
        expect(s.kannWeiter, isFalse);
        expect(() => s.weiter(), throwsStateError);
        keinePersonAmStand(s, k, '$akte, ${ziel.option}');
        laufen(s, k);
        if (istSuche(e)) {
          expect(s.zug!.phase, RundenZugPhase.wurf);
          expect(s.letzterFund, isNull);
        } else {
          expect(s.zug!.phase, RundenZugPhase.fund);
          expect(s.letzterFund, isNotNull);
          expect(s.wuerfe, hasLength(wuerfeVorher), reason: 'Befragungen würfeln nie');
        }
        geprueft++;
      }
      expect(geprueft, daten.karte.ziele.length);
    });
  }

  test('Pech, Umweg und Nochmal behalten Quelle und Wissen bis zum garantierten dritten Wurf', () {
    final s = neueSitzung(rollen: 4, wuerfel: const FesterWuerfel.pech());
    spieleBis(s, PartyPhase.entscheidungen, runde: 2);
    final k = karte(s);
    final e = s.laufendeEntscheidung!;
    final option = e.richtig[s.spiel.pfad]!;
    s.schlageVor(option);
    s.bestaetigen();
    final ersteAktion = s.zug!.aktion;
    final quelle = (k.kartenAktion!.zielX, k.kartenAktion!.zielY);
    laufen(s, k);
    final ersterOrt = (k.world.value!.detectives.single.x, k.world.value!.detectives.single.y);
    s.wuerfeln();
    expect(s.zug!.phase, RundenZugPhase.tischruf);
    expect(s.letzterFund, isNull);
    expect(s.spiel.gewaehlt.containsKey(e.id), isFalse);
    s.tischruf(Tischruf.umweg);
    expect(s.zug!.option, option);
    expect((k.kartenAktion!.zielX, k.kartenAktion!.zielY), quelle);
    expect(k.kartenAktion!.weg.last, isNot(ersterOrt));
    expect(s.aktionFertig(ersteAktion), isFalse);
    laufen(s, k);
    s.wuerfeln();
    expect(s.zug!.phase, RundenZugPhase.tischruf);
    s.tischruf(Tischruf.nochmal);
    laufen(s, k);
    expect(s.wuerfelVorschau().garantie, isTrue);
    expect(s.wuerfelVorschau().prozent[Stufe.pech], 0);
    s.wuerfeln();
    expect(s.zug!.wurf!.stufe, Stufe.teilerfolg);
    expect(s.letzterFund!.ziel.option, option);
    expect(s.letzterFund!.funde.map((f) => f.text), s.spiel.ermittlung.aufdecken(option, s.spiel.pfad).map((f) => f.text));
    expect(s.kannWeiter, isFalse);
    s.fundGelesen();
    expect(s.laufendeEntscheidung!.id, 'e2_2');
  });

  test('ein Hintergrund-Timer allein beendet keine Kartenaktion', () async {
    final s = neueSitzung(rollen: 4);
    while (s.phase != PartyPhase.entscheidungen) { s.weiter(); }
    final k = karte(s);
    final start = k.world.value!.detectives.single;
    await Future<void>.delayed(const Duration(milliseconds: 230));
    expect(s.zug!.phase, RundenZugPhase.aktion);
    expect(k.world.value!.detectives.single.x, start.x);
    expect(k.aktionsFortschritt.value, 0);
  });

  test('Flame treibt den Weg, Joystick und alte Positionspakete überschreiben ihn nicht', () {
    final s = neueSitzung(rollen: 4);
    spieleBis(s, PartyPhase.entscheidungen);
    final k = karte(s);
    final game = MordakteGame(session: k)
      ..onGameResize(Vector2(390, 844))
      ..stick = const Offset(1, -1);
    addTearDown(game.dispose);
    s.schlageVor(s.laufendeEntscheidung!.optionen.first.id);
    s.bestaetigen();
    final ende = k.kartenAktion!.weg.last;
    k.move(-999, -999, 2);
    k.setzeDetektiv(-999, -999);
    for (var i = 0; i < 750 && s.zug?.phase == RundenZugPhase.aktion; i++) {
      game.update(1 / 60);
      game.triggerAction();
    }
    expect(s.zug!.phase, RundenZugPhase.fund);
    final d = k.world.value!.detectives.single;
    expect((d.x, d.y), ende);
    expect(game.target.value, isNull);
    expect(s.spiel.gewaehlt, hasLength(1));
  });

  test('Szene abkürzen braucht weiter eine sichtbare Zielpose und würfelt nicht selbst', () {
    final s = neueSitzung(rollen: 4);
    spieleBis(s, PartyPhase.entscheidungen, runde: 2);
    final k = karte(s);
    s.schlageVor(s.laufendeEntscheidung!.optionen.first.id);
    s.bestaetigen();
    k.aktionAbkuerzen();
    expect(s.zug!.phase, RundenZugPhase.aktion);
    k.szenenSchritt(0.05);
    expect(k.figurenPose, SzenenPose.suchen);
    expect(s.zug!.phase, RundenZugPhase.aktion);
    k.szenenSchritt(0.25);
    expect(s.zug!.phase, RundenZugPhase.wurf);
    expect(s.wuerfe, hasLength(1));
  });

  for (final akte in _akten) {
    test('$akte: Weg, Pose, Dauer und Chancen sind bei gleichem Würfelstrom in allen Pfaden gleich', () {
      List<Object>? referenz;
      for (final pfad in akteDaten(akte).kanon.pfade) {
        final s = _sitzung(akte, rollen: 20, pfad: pfad, wuerfel: const FesterWuerfel.pech());
        spieleBis(s, PartyPhase.entscheidungen, runde: 2);
        final k = karte(s);
        s.schlageVor(s.laufendeEntscheidung!.optionen.first.id);
        s.bestaetigen();
        final spur = laufen(s, k);
        // Eine Suche würfelt; nach dem Pech folgt der Umweg mit eigenem Weg.
        if (s.zug?.phase == RundenZugPhase.wurf) {
          spur.add(s.wuerfelVorschau().prozent);
          s.wuerfeln();
          expect(s.zug?.phase, RundenZugPhase.tischruf, reason: '$akte, $pfad: Pech');
          s.tischruf(Tischruf.umweg);
          spur.addAll(laufen(s, k));
        }
        referenz ??= spur;
        expect(spur, referenz, reason: pfad);
      }
    });
  }

  test('Druckspiel bleibt ohne Würfel und ohne neue Zugschritte spielbar', () {
    final s = neueSitzung()..einrichten(rollen: 4, detektiv: 'w', druck: true);
    spieleBis(s, PartyPhase.ende);
    expect(s.mitWuerfel, isFalse);
    expect(s.wuerfe, isEmpty);
    expect(s.funde, hasLength(9));
  });
}
