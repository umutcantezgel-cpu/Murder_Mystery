// M7a: Ebenenwechsel im Renderer. Die Wendeltreppe führt hinauf und zurück,
// die Kamera steht sofort am Gegenstück, die Szene kommt aus dem Speicher und
// blendet 0,3 s auf. Verschlossene Portale bieten keine Handlung. Der Nebel
// zeichnet nur Räume im Sichtbereich.
import 'dart:ui';

import 'package:flame/game.dart' show Vector2;
import 'package:flutter_test/flutter_test.dart';
import 'package:mordakte/game/mordakte_game.dart';
import 'package:mordakte/game/scene/iso_pen.dart';
import 'package:mordakte/game/scene/palette.dart';
import 'package:mordakte/game/scene/party_props.dart';
import 'package:mordakte/party/ebenen_vorschau.dart';
import 'package:mordakte_core/mordakte_core.dart';

import 'hilfe.dart';

const _dt = 1 / 60;

(MordakteGame, EbenenVorschau) _aufbau({String ebene = kellerEbene, WeltLage? lage, (double, double)? at}) {
  final v = ebenenVorschau(ebene: ebene, lage: lage, at: at);
  addTearDown(v.dispose);
  final game = MordakteGame(session: v)..onGameResize(Vector2(390, 844));
  addTearDown(game.dispose);
  game.update(_dt);
  return (game, v);
}

/// Tippt das Portal [id] auf der gezeigten Ebene an und läuft hin, bis die Ebene wechselt.
void _durch(MordakteGame game, EbenenVorschau v, String id) {
  final (_, s) = weltEbenen.portaleAuf(v.ebene).firstWhere((e) => e.$1.id == id);
  final vorher = v.ebene;
  final k = s.kacheln.first;
  expect(game.tippen(game.worldToScreen(k.x + 0.5, k.y + 0.5, 0.5)), isTrue, reason: '$id auf $vorher erreichbar');
  for (var i = 0; i < 15 * 60 && v.ebene == vorher; i++) {
    game.update(_dt);
  }
  expect(v.ebene, isNot(vorher), reason: '$id wechselt die Ebene');
  game.update(_dt);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Wendeltreppe hinauf und zurück: Ankunft am Gegenstück, Kamera ohne Schwenk, Szene aus dem Speicher, 0,3 s Überblendung', () {
    final (game, v) = _aufbau();
    expect(game.szenenGebacken, 1);
    final treppe = weltEbenen.portale.singleWhere((p) => p.id == 'p_wendeltreppe');
    v.setzeDetektiv(treppe.a.ankunftX, treppe.a.ankunftY);
    game.update(_dt);

    _durch(game, v, 'p_wendeltreppe');
    expect(v.ebene, 'turm');
    expect(game.eigenePosition, Offset(treppe.b.ankunftX, treppe.b.ankunftY));
    // Kamera folgt sofort: die Figur steht waagerecht in der Bildmitte.
    expect((game.worldToScreen(treppe.b.ankunftX, treppe.b.ankunftY).dx - 195).abs(), lessThan(2));
    expect(game.blende, closeTo(MordakteGame.ebenenBlende - _dt, 1e-9));
    expect(game.szenenImSpeicher, {ebenenSzenarioId(kellerEbene), ebenenSzenarioId('turm')});
    expect(game.szenenGebacken, 2);
    for (var i = 0; i < 20; i++) {
      game.update(_dt);
    }
    expect(game.blende, 0, reason: 'nach 0,3 s ist die Überblendung vorbei');

    _durch(game, v, 'p_wendeltreppe');
    expect(v.ebene, kellerEbene);
    expect(game.eigenePosition, Offset(treppe.a.ankunftX, treppe.a.ankunftY));
    expect(game.szenenGebacken, 2, reason: 'der Keller kommt aus dem Speicher');
    _durch(game, v, 'p_wendeltreppe');
    expect(game.szenenGebacken, 2, reason: 'der Turm auch');
  });

  test('Portale in beide Richtungen über den Renderer: Keller → Hof → Außenwelt → Keller', () {
    final (game, v) = _aufbau();
    final hof = weltEbenen.portale.singleWhere((p) => p.id == 'p_hoftuer');
    v.setzeDetektiv(hof.a.ankunftX, hof.a.ankunftY);
    game.update(_dt);
    _durch(game, v, 'p_hoftuer');
    expect(v.ebene, 'erdgeschoss');
    _durch(game, v, 'p_einfahrtstor');
    expect(v.ebene, 'aussen');
    _durch(game, v, 'p_aussentor');
    expect(v.ebene, kellerEbene);
    expect(game.szenenGebacken, 3, reason: 'zurück im Keller: aus dem Speicher');
    expect(game.szenenImSpeicher.length, lessThanOrEqualTo(3), reason: 'höchstens zwei Szenen neben der gezeigten');
  });

  test('in den Runden: Hoftür und Außentor ohne Handlung, im kurzen Abend nur Treppe und Toilette', () {
    final hoftuer = partyDaten.kanon.graph.tueren['hoftuer']!.kacheln.single;
    for (final (lage, hofOffen) in [(WeltLage.um('01:15', lang: false), false), (WeltLage.um('00:10'), false), (WeltLage.um('02:45'), true)]) {
      final (game, v) = _aufbau(lage: lage);
      final cv = v.caseView.value!;
      expect(cv.hotspots.keys.toSet(), {'p_wendeltreppe', if (hofOffen) 'p_hoftuer'}, reason: '$lage');
      expect(v.wechsle('p_aussentor'), isFalse, reason: '$lage');
      expect(v.ebene, kellerEbene);
      expect(cv.openDoors.any((d) => d[0] == hoftuer.x && d[1] == hoftuer.y), hofOffen, reason: '$lage');
      game.update(_dt);
      expect(v.wechsle('p_hoftuer'), hofOffen, reason: '$lage');
    }
    final (_, kurz) = _aufbau(lage: WeltLage.um('01:15', lang: false));
    expect(kurz.wechsle('p_wendeltreppe'), isTrue);
    expect(kurz.caseView.value!.openDoors, isEmpty, reason: 'die Tür zum Turmzimmer bleibt zu');
  });

  test('Nebel nur im Sichtbereich: entfernte Räume werden nicht gezeichnet', () {
    MordakteGame.debugInitialZoom = 2;
    addTearDown(() => MordakteGame.debugInitialZoom = 1);
    final (game, _) = _aufbau(ebene: 'aussen', at: (6.5, 26.5));
    for (var i = 0; i < 30; i++) {
      game.update(_dt);
    }
    final rec = PictureRecorder();
    game.render(Canvas(rec));
    rec.endRecording().dispose();
    expect(game.nebelVerworfen, greaterThan(0));
  });

  test('neue Requisiten der Ebenen zeichnen sich selbst und stehen im Katalog', () {
    final party = PartyProps(ScenePalette.fallback);
    const neu = ['party_hecke', 'party_brunnen', 'party_bank', 'party_stufen', 'party_tor', 'party_zinne', 'party_laterne', 'party_beet', 'party_herd', 'party_truhe'];
    for (final typ in neu) {
      expect(propCatalog, contains(typ));
      final rec = PictureRecorder();
      expect(party.paint(IsoPen(Canvas(rec), 0, 0), PropDef(type: typ, x: 0, y: 0)), isTrue, reason: typ);
      final bild = rec.endRecording();
      expect(bild.approximateBytesUsed, greaterThan(300), reason: typ);
      bild.dispose();
    }
    final genutzt = {for (final s in ebenenSzenarien.values) for (final p in s.map.props) p.type};
    expect(genutzt.containsAll(neu), isTrue, reason: 'jede neue Requisite steht auf einer Ebene: ${neu.where((t) => !genutzt.contains(t))}');
  });
}
