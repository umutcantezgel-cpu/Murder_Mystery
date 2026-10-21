// M6 (A-055): Die Klassen-Ebene des Renderers zeichnet nur. Gerüchte kommen
// in Hörweite weich ins Bild und gehen wieder, immer nur eines zugleich; ohne
// Gerücht, Radius oder Türhinweis zeichnet sie nichts.
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:mordakte/game/scene/klassen_ebene.dart';
import 'package:mordakte/game/scene/markers.dart' show TextCache;
import 'package:mordakte/game/scene/palette.dart';
import 'package:mordakte/game/scene/static_scene.dart';
import 'package:mordakte/game/szenen_erweiterung.dart';
import 'package:mordakte_core/mordakte_core.dart';

import 'klasse_hilfe.dart';

/// Eine feste Klasse für die Ebene, ohne Abend dahinter.
class _Klasse implements SzenenKlasse {
  _Klasse({this.glanzRadius = 0, this.tuerenZeigen = false, this.stimmungZeigen = false, this.geruechte = const {}, this.marker = const {}});

  @override
  final double glanzRadius;
  @override
  double get tempoFaktor => 1;
  @override
  final bool tuerenZeigen;
  @override
  final bool stimmungZeigen;
  final Map<String, String> geruechte;
  final Set<String> marker;

  @override
  String? geruechtFuer(String npcId) => geruechte[npcId];
  @override
  bool gespraechsMarker(String npcId) => marker.contains(npcId);
}

KlassenFigur _figur(String id, double abstand) => (id: id, kopf: const Offset(200, 300), abstand: abstand);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Gerüchte: nur die nächste Figur in Hörweite, weich ein- und ausgeblendet', () {
    final ebene = KlassenEbene(ScenePalette.fallback, TextCache());
    final k = _Klasse(geruechte: {'a': 'Im Turm soll früher ein Uhrmacher gewohnt haben.', 'b': 'Der Wind heult.'});
    void bild(List<KlassenFigur> figuren) {
      final rec = PictureRecorder();
      ebene.ueberKoepfen(Canvas(rec), k, figuren: figuren, gespraech: null, t: 0, dt: 0.1);
      rec.endRecording().dispose();
    }

    bild([_figur('a', 5), _figur('b', 4)]);
    expect(ebene.geruechtDeckkraft, isEmpty, reason: 'niemand in Hörweite');
    bild([_figur('a', 1.5), _figur('b', 2), _figur('c', 0.5)]);
    expect(ebene.geruechtDeckkraft.keys, ['a'], reason: 'die nächste Figur mit Gerücht');
    for (var i = 0; i < 5; i++) {
      bild([_figur('a', 1.5), _figur('b', 2)]);
    }
    expect(ebene.geruechtDeckkraft['a'], 1);
    bild([_figur('a', 3), _figur('b', 2)]);
    expect(ebene.geruechtDeckkraft['a'], lessThan(1), reason: 'a blendet aus');
    expect(ebene.geruechtDeckkraft['b'], greaterThan(0), reason: 'b blendet ein');
    for (var i = 0; i < 10; i++) {
      bild([_figur('a', 3), _figur('b', 5)]);
    }
    expect(ebene.geruechtDeckkraft, isEmpty, reason: 'alle wieder ausgeblendet');
  });

  test('Köpfe: Gesprächsmarker und Stimmungszeichen nur mit der Wirkung', () {
    final ebene = KlassenEbene(ScenePalette.fallback, TextCache());
    int bytes(SzenenKlasse k, {SzenenGeste? geste}) {
      final rec = PictureRecorder();
      ebene.ueberKoepfen(Canvas(rec), k,
          figuren: [_figur('a', 4), _figur('b', 4)], gespraech: geste == null ? null : (npc: 'a', geste: geste), t: 0, dt: 0.1);
      final bild = rec.endRecording();
      final n = bild.approximateBytesUsed;
      bild.dispose();
      return n;
    }

    final leer = bytes(_Klasse(), geste: SzenenGeste.abwehr);
    expect(bytes(_Klasse(marker: {'b'})), greaterThan(leer), reason: 'Sprechblasen-Marker');
    for (final g in SzenenGeste.values) {
      expect(bytes(_Klasse(stimmungZeigen: true), geste: g), greaterThan(leer), reason: 'Stimmung ${g.name}');
    }
  });

  test('Boden: Leuchten, Türen und Treppen zeichnen ohne Fehler, ohne Wirkung bleibt das Bild leer', () {
    final d = klassenDaten();
    final scene = StaticScene.build(d.szenario);
    addTearDown(scene.dispose);
    final ebene = KlassenEbene(scene.pal, TextCache());
    final h = d.szenario.hotspots.first;
    final fall = CaseView(
      version: 1, roomCode: 'PARTY', hostId: 'me', scenarioId: d.szenario.id, mode: 'story', seed: 0, bots: 0, lobby: const [],
      phase: Phase.investigation, chapter: 1, notebook: const [], board: const [], deductions: const [], contradictions: 0,
      hotspots: {h.id: HotspotState.open}, openDoors: const [], items: const [], inventory: const [], leadOptions: const [],
      leadVotes: const {}, chosenLeads: const [], accusations: const {}, heard: const {}, deadNpcs: const [],
      abilityCooldownMs: 0, abilityCharges: 0, pingsLeft: 0, ending: null,
    );
    int befehle(SzenenKlasse k) {
      final rec = PictureRecorder();
      final c = Canvas(rec);
      ebene.boden(c, k, scene: scene, fall: fall, glanz: [SzenenGlanzPunkt('g', h.x + 1.5, h.y + 0.5)], ich: Offset(h.x + 0.5, h.y + 0.5),
          offen: const {}, cull: const Rect.fromLTWH(-1e5, -1e5, 2e5, 2e5), t: 1);
      final bild = rec.endRecording();
      final n = bild.approximateBytesUsed;
      bild.dispose();
      return n;
    }

    final leer = befehle(_Klasse());
    expect(befehle(_Klasse(glanzRadius: 3)), greaterThan(leer), reason: 'Leuchten im Umkreis');
    expect(befehle(_Klasse(tuerenZeigen: true)), greaterThan(leer), reason: 'Umrisse');
    expect(scene.doors, isNotEmpty);
    expect(scene.propAt.values.any((p) => p.prop!.type.contains('treppe')), isTrue, reason: 'der Schlosskeller hat eine Treppe');
  });
}
