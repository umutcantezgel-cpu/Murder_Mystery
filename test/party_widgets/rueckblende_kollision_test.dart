// M1: Rückblende ohne Glitschen (Schlosskeller). Bild für Bild bei Zeitraffer
// 25 und 60 Bildern je Sekunde: Jede Figur steht mit ihrem Körper frei, der
// Renderer zeichnet sie genau dort, wo die Szene sie meldet (keine Sehnen,
// kein Teleport), und zwischen zwei Bildern springt niemand.
import 'package:flame/game.dart' show Vector2;
import 'package:flutter_test/flutter_test.dart';
import 'package:mordakte/game/mordakte_game.dart';
import 'package:mordakte/party/karte_session.dart';
import 'package:mordakte_core/mordakte_core.dart';

import 'hilfe.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('die Wege der Tatmatrix sind in allen Pfaden mit dem ganzen Körper frei', () {
    final raster = TileGrid(partyDaten.szenario.map);
    var wege = 0;
    for (final pfad in partyDaten.kanon.pfade) {
      final ablauf = partyDaten.karte.rueckblende(pfad).ablauf;
      expect(ablauf.fehler, isEmpty, reason: pfad);
      for (final e in ablauf.abschnitte.entries) {
        for (final a in e.value.where((a) => a.istWeg)) {
          wege++;
          for (var i = 1; i < a.linie.length; i++) {
            final (ax, ay) = a.linie[i - 1];
            final (bx, by) = a.linie[i];
            expect(raster.freieBahn(ax, ay, bx, by), isTrue, reason: '$pfad, ${e.key} ab ${a.von}: ($ax, $ay) → ($bx, $by)');
          }
        }
      }
    }
    expect(wege, greaterThan(20), reason: 'genug Wege geprüft');
  });

  test('Bruchteilzeit: auf ganzen Sekunden wie bisher, dazwischen auf der Linie', () {
    final rb = partyDaten.karte.rueckblende(partyDaten.kanon.pfade.first);
    var geprueft = 0;
    for (final e in rb.ablauf.abschnitte.entries) {
      for (final a in e.value.where((a) => a.istWeg)) {
        for (var t = a.von; t < a.bis; t = t.plus(1)) {
          expect(a.posAmBruch(t.sekunden.toDouble()), a.posAm(t));
          expect(rb.bild(t, bruch: 0).personen[e.key]!.x, rb.bild(t).personen[e.key]!.x);
          for (var k = 1; k < 10; k++) {
            final z = rb.bild(t, bruch: k / 10).personen[e.key]!;
            var naechste = double.infinity;
            for (var i = 1; i < a.linie.length; i++) {
              final (ax, ay) = a.linie[i - 1];
              final (bx, by) = a.linie[i];
              final d = distToSegment(z.x, z.y, ax, ay, bx, by);
              if (d < naechste) naechste = d;
            }
            expect(naechste, lessThan(1e-9), reason: '${e.key} um $t + ${k / 10}');
            geprueft++;
          }
        }
      }
    }
    expect(geprueft, greaterThan(100));
  });

  for (final pfad in partyDaten.kanon.pfade) {
    test('$pfad: jedes Bild der Rückblende steht frei und wird genau gezeichnet', () {
      final s = neueSitzung(rollen: 7, pfad: pfad);
      spieleBis(s, PartyPhase.finale);
      final k = PartyKartenSession(s, rueckblendeModus: true);
      addTearDown(k.dispose);
      var frame = 0;
      k.testUhr = () => frame / 60;
      final game = MordakteGame(session: k)..onGameResize(Vector2(390, 844));
      addTearDown(game.dispose);
      final raster = TileGrid(s.daten.szenario.map);
      // Schnellster Weg der Tatmatrix: weiter darf eine Figur je Bild nicht
      // kommen (plus das Beiseiterücken einer stehenden Figur).
      var tempo = 0.0;
      for (final l in s.rueckblende.ablauf.abschnitte.values) {
        for (final a in l.where((a) => a.istWeg)) {
          final v = a.laenge / a.bis.minus(a.von);
          if (v > tempo) tempo = v;
        }
      }
      final sprung = tempo * k.zeitraffer / 60 + 0.45;
      final vorher = <String, Offset>{};
      var bilder = 0;
      while (!k.fertig.value && frame < 60 * 120) {
        frame++;
        game.update(1 / 60);
        bilder++;
        for (final n in k.world.value!.npcs) {
          final wo = '$pfad, Bild $frame (${k.zeit.value}), ${n.id}';
          expect(raster.canStand(n.x, n.y, Tuning.playerRadius), isTrue, reason: '$wo bei (${n.x}, ${n.y}) in Wand oder Möbel');
          final gezeichnet = game.figurPosition(n.id);
          expect(gezeichnet, Offset(n.x, n.y), reason: '$wo: Renderer zeichnet woanders');
          final alt = vorher[n.id];
          if (alt != null) expect((Offset(n.x, n.y) - alt).distance, lessThanOrEqualTo(sprung), reason: '$wo springt');
          vorher[n.id] = Offset(n.x, n.y);
        }
      }
      expect(k.fertig.value, isTrue, reason: 'die Rückblende läuft durch');
      expect(bilder, greaterThan(600));
    });
  }
}
