// M7b: Morgenlicht. Am Morgen draußen schaltet die Abend-Karte auf Tageslicht
// (SzenenLicht.tag); der Renderer lässt dann Laternen und das Glühen der Kulisse
// aus und lässt kaum noch Staub wirbeln. Die Nacht bleibt, wie sie war.
import 'dart:ui';

import 'package:flame/game.dart' show Vector2;
import 'package:flutter_test/flutter_test.dart';
import 'package:mordakte/game/mordakte_game.dart';
import 'package:mordakte/game/scene/lighting.dart';
import 'package:mordakte/game/szenen_erweiterung.dart';
import 'package:mordakte/party/rundgang_karte.dart';

import 'hilfe.dart';
import 'rundgang_hilfe.dart';

const _dt = 1 / 60;

/// Zeichnet die Karte [k] einige Bilder lang und liefert die glühenden Laternen des letzten.
int _laternen(RundgangKarte k) {
  final game = MordakteGame(session: k)..onGameResize(Vector2(390, 844));
  addTearDown(game.dispose);
  for (var i = 0; i < 20; i++) {
    game.update(_dt);
  }
  final rec = PictureRecorder();
  game.render(Canvas(rec));
  rec.endRecording().dispose();
  return game.laternenGezeichnet;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Lichtmodus: tags keine Laternen, nachts wie bisher', () {
    final nacht = MordakteGame.szenenLichtModus(const SzenenLicht(dunkel: 0.58));
    expect([nacht.mode, nacht.laternen, nacht.taschenlampe], [LightMode.night, true, true]);
    final tag = MordakteGame.szenenLichtModus(const SzenenLicht(dunkel: 0.45, tag: true));
    expect([tag.mode, tag.laternen, tag.taschenlampe], [LightMode.day, false, false]);
  });

  test('Wetter: tags wirbelt draußen kaum Staub, sonst bleibt alles wie bisher', () {
    expect(MordakteGame.wetterZiel('dust', draussen: true), 1.0);
    expect(MordakteGame.wetterZiel('dust', draussen: false), 0.55);
    expect(MordakteGame.wetterZiel('neon', draussen: false), 0.35);
    expect(MordakteGame.wetterZiel('rain', draussen: false), 0.0);
    expect(MordakteGame.wetterZiel('dust', draussen: true, tag: true), lessThan(0.5));
    expect(MordakteGame.wetterZiel('neon', draussen: true, tag: true), 1.0, reason: 'nur Staub wird schwächer');
  });

  test('Im Bild: Auf dem Parkplatz glühen abends die Laternen, am Morgen keine', () async {
    final v = rundgangDaten.vorspielMorgen!;
    // Vorspiel: Ankunft auf dem Parkplatz um sechs (Nacht).
    final abend = RundgangKarte(rundgangDaten, weltEbenen, ebenenSzenarien, v.vorspiel)..bewegungReduziert = true;
    addTearDown(abend.dispose);
    expect(await abend.geheZu(0), isTrue);
    expect([abend.aktuelleEbene, abend.licht!.tag], ['aussen', false]);
    // Morgen: dieselbe Stelle um zehn nach sieben (Tag).
    final morgen = RundgangKarte(rundgangDaten, weltEbenen, ebenenSzenarien, v.morgen)..bewegungReduziert = true;
    addTearDown(morgen.dispose);
    final parkplatz = v.morgen.stationen.indexWhere((s) => s.ort == v.vorspiel.stationen.first.ort);
    for (var i = 0; i <= parkplatz; i++) {
      expect(await morgen.geheZu(i), isTrue);
    }
    expect([morgen.aktuelleEbene, morgen.licht!.tag], ['aussen', true]);
    final nachts = _laternen(abend);
    expect(nachts, greaterThan(abend.licht!.punkte.length), reason: 'abends glühen Laternen');
    expect(_laternen(morgen), morgen.licht!.punkte.length, reason: 'am Morgen nur die Lichtpunkte der Szene');
  });
}
