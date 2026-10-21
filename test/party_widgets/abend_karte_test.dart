// M7b: Die Abend-Karte (Naht für Streifzug, Vorspiel und Morgen). Start im
// Keller am Ermittlungsort, Ebenenwechsel nur über offene Portale (über den
// Renderer wie am Tisch und geführt mit laufeZu), das Einfahrtstor bleibt in
// den Runden zu, zurueckInDenKeller endet immer am Startort (ohne offenen Weg
// mit einer Kurzblende), in keinem Frame steht der Detektiv in Wand oder
// Möbel, und die Karte ändert nichts am Abend. Dazu das Tageslicht am Morgen.
import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:flame/game.dart' show Vector2;
import 'package:flutter_test/flutter_test.dart';
import 'package:mordakte/game/mordakte_game.dart';
import 'package:mordakte/game/scene/lighting.dart';
import 'package:mordakte/game/scene/palette.dart';
import 'package:mordakte/game/szenen_erweiterung.dart';
import 'package:mordakte/party/abend_karte.dart';
import 'package:mordakte/party/karten_quelle.dart';
import 'package:mordakte/party/sitzung.dart';
import 'package:mordakte_core/mordakte_core.dart';
import 'package:mordakte_core/runden.dart' hide KartenQuelle;

import 'hilfe.dart';

const _dt = 1 / 60;

/// In den Runden nach dem Ersatzschlüssel: Hoftür und Wendeltreppe offen, Außentor und Einfahrtstor zu.
final _runde = WeltLage.um('00:30');
final _morgen = WeltLage.um('07:00');

AbendKarte _karte({WeltLage? lage, String ebene = kellerEbene, (double, double)? start, KartenQuelle? quelle, void Function(String, String)? onAnkunft}) {
  final k = AbendKarte(partyDaten, weltEbenen, ebenenSzenarien,
      lage: lage ?? _runde, ebene: ebene, start: start, quelle: quelle, detektivName: 'Dana', onAnkunft: onAnkunft);
  addTearDown(k.dispose);
  return k;
}

Offset _pos(AbendKarte k) {
  final d = k.world.value!.detectives.single;
  return Offset(d.x, d.y);
}

Set<String> _hotspots(AbendKarte k) => {for (final e in k.caseView.value!.hotspots.entries) if (e.value == HotspotState.open) e.key};

/// Treibt einen geführten Weg Bild für Bild und prüft in jedem Bild, dass der
/// Detektiv frei steht (Raster der gezeigten Ebene, wie der Renderer).
Future<int> _treibe(AbendKarte k, Future<Object?> weg, {int hoechstens = 60 * 60}) async {
  var fertig = false;
  unawaited(weg.whenComplete(() => fertig = true));
  var n = 0;
  while (!fertig && n < hoechstens) {
    k.szenenSchritt(_dt);
    n++;
    final p = _pos(k);
    expect(k.rasterVon(k.aktuelleEbene).canStand(p.dx, p.dy, Tuning.playerRadius), isTrue,
        reason: 'Bild $n auf ${k.aktuelleEbene} bei $p in Wand oder Möbel');
    await Future<void>.delayed(Duration.zero);
  }
  await Future<void>.delayed(Duration.zero);
  expect(fertig, isTrue, reason: 'Der Weg endet');
  return n;
}

/// Jede Strecke des Plans besteht die freie Bahn mit Körperkasten (Raster der Ebene).
void _pruefePlan(AbendKarte k, List<LaufAbschnitt> plan) {
  var von = _pos(k);
  for (final a in plan) {
    final r = k.rasterVon(a.ebene);
    for (final p in a.punkte) {
      expect(r.freieBahn(von.dx, von.dy, p.dx, p.dy, Tuning.playerRadius), isTrue, reason: '${a.ebene}: $von → $p streift Wand oder Möbel');
      von = p;
    }
    if (a.portal case final id?) {
      final p = weltEbenen.portale.singleWhere((p) => p.id == id);
      final dort = p.seiteAuf(a.ebene) == p.a ? p.b : p.a;
      von = Offset(dort.ankunftX, dort.ankunftY);
    }
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Start im Keller am Ermittlungsort; offen sind nur die Portale der Lage', () {
    final k = _karte();
    expect(k.aktuelleEbene, kellerEbene);
    expect(_pos(k), Offset(k.kellerStart.$1, k.kellerStart.$2));
    expect(k.rasterVon(kellerEbene).canStand(k.kellerStart.$1, k.kellerStart.$2, Tuning.playerRadius), isTrue);
    expect(k.scenario!.id, ebenenSzenarioId(kellerEbene));
    expect(k.ebenenSzenarien, {for (final e in weltEbenen.ebenen.keys) ebenenSzenarioId(e)});
    expect(_hotspots(k), {'p_wendeltreppe', 'p_hoftuer'}, reason: '00:30: Hoftür offen, Außentor zu');
    k.wechsleLage(WeltLage.um('00:10'));
    expect(_hotspots(k), {'p_wendeltreppe'}, reason: 'vor dem Ersatzschlüssel nur die Treppe');
    k.wechsleLage(WeltLage.um('01:15', lang: false));
    expect(_hotspots(k), {'p_wendeltreppe'}, reason: 'im kurzen Abend nur die Treppe');
    expect(k.wechsle('p_hoftuer'), isFalse);
    k.wechsleLage(_morgen);
    expect(_hotspots(k), {'p_wendeltreppe', 'p_hoftuer', 'p_aussentor'});
    expect(k.hotspotAktion('p_aussentor'), isNotEmpty);
  });

  test('Über den Renderer: Tippen, Laufen und Interact wechseln durch ein offenes Portal; jedes Bild steht frei', () {
    final k = _karte();
    final game = MordakteGame(session: k)..onGameResize(Vector2(390, 844));
    addTearDown(game.dispose);
    game.update(_dt);
    final hof = weltEbenen.portale.singleWhere((p) => p.id == 'p_hoftuer');
    final kachel = hof.a.kacheln.first;
    expect(game.tippen(game.worldToScreen(kachel.x + 0.5, kachel.y + 0.5, 0.5)), isTrue);
    for (var i = 0; i < 20 * 60 && k.aktuelleEbene == kellerEbene; i++) {
      game.update(_dt);
      // Im Bild des Wechsels steht die Figur noch an der Tür im Keller.
      if (k.aktuelleEbene != kellerEbene) break;
      final p = game.eigenePosition;
      expect(k.rasterVon(kellerEbene).canStand(p.dx, p.dy, Tuning.playerRadius), isTrue, reason: 'Bild $i bei $p');
    }
    expect(k.aktuelleEbene, 'erdgeschoss');
    game.update(_dt);
    expect(game.eigenePosition, Offset(hof.b.ankunftX, hof.b.ankunftY), reason: 'Ankunft am Gegenstück');
    expect(k.scenario!.id, ebenenSzenarioId('erdgeschoss'));
    expect(_hotspots(k), {'p_hoftuer'}, reason: 'Das Einfahrtstor ist in den Runden kein Ziel');
  });

  test('Das Einfahrtstor bleibt in den Runden zu: kein Wechsel, kein geführter Weg, durch das Tor kein Durchkommen', () async {
    final k = _karte();
    expect(k.wechsle('p_hoftuer'), isTrue);
    expect(k.aktuelleEbene, 'erdgeschoss');
    final vorher = _pos(k);
    expect(k.wechsle('p_einfahrtstor'), isFalse);
    k.send(const Interact('p_einfahrtstor'));
    expect([k.aktuelleEbene, _pos(k)], ['erdgeschoss', vorher]);
    expect(k.hotspotAktion('p_einfahrtstor'), isNull);
    expect(k.planeWeg('aussen', (5.5, 5.5)), isNull);
    expect(await k.laufeZu('aussen', 'aussen_park_bank'), isFalse, reason: 'Die Außenwelt ist in den Runden unerreichbar');
    expect([k.aktuelleEbene, _pos(k), k.laeuft], ['erdgeschoss', vorher, false]);
    // Über den Renderer: zum Tor laufen, nie auf die Torkacheln, und die Ebene bleibt.
    final game = MordakteGame(session: k)..onGameResize(Vector2(390, 844));
    addTearDown(game.dispose);
    game.update(_dt);
    final tor = weltEbenen.portale.singleWhere((p) => p.id == 'p_einfahrtstor').a;
    final torKacheln = {for (final t in tor.kacheln) (t.x, t.y)};
    expect(game.tippen(game.worldToScreen(tor.kacheln.first.x + 0.5, tor.kacheln.first.y + 0.5, 0.5)), isTrue);
    for (var i = 0; i < 25 * 60 && game.tippWeg != null; i++) {
      game.update(_dt);
      final p = game.eigenePosition;
      expect(torKacheln.contains((p.dx.floor(), p.dy.floor())), isFalse, reason: 'auf dem verschlossenen Tor bei $p');
      expect(k.rasterVon('erdgeschoss').canStand(p.dx, p.dy, Tuning.playerRadius), isTrue);
    }
    for (var i = 0; i < 30; i++) {
      game.update(_dt);
    }
    expect(k.aktuelleEbene, 'erdgeschoss');
    // Am Morgen schließt die Kollegin auf.
    k.wechsleLage(_morgen);
    k.setzeDetektiv(tor.ankunftX, tor.ankunftY);
    expect(k.wechsle('p_einfahrtstor'), isTrue);
    expect(k.aktuelleEbene, 'aussen');
  });

  test('laufeZu plant über Portale bis zu einem Ort auf einer anderen Ebene; jedes Bild steht frei, die Ankunft wird gemeldet', () async {
    final ankunft = <(String, String)>[];
    final k = _karte(onAnkunft: (e, o) => ankunft.add((e, o)));
    final plan = k.planeWeg('turm', (weltEbenen.ebenen['turm']!.graph.orte['turm_am_schreibtisch']!.x, weltEbenen.ebenen['turm']!.graph.orte['turm_am_schreibtisch']!.y))!;
    expect([for (final a in plan) a.ebene], [kellerEbene, 'turm']);
    expect(plan.first.portal, 'p_wendeltreppe');
    _pruefePlan(k, plan);
    final weg = k.laufeZu('turm', 'turm_am_schreibtisch');
    expect([k.laeuft, k.eingabeGesperrt, k.figurenPose], [true, true, SzenenPose.gehen]);
    // Während des Wegs nimmt die Karte keine Eingabe an.
    final mitten = _pos(k);
    k.move(mitten.dx + 3, mitten.dy, 0);
    expect(_pos(k), mitten);
    final bilder = await _treibe(k, weg);
    expect(await weg, isTrue);
    expect(bilder, greaterThan(60), reason: 'ein sichtbarer Weg, kein Sprung');
    expect([k.aktuelleEbene, k.laeuft, k.eingabeGesperrt], ['turm', false, false]);
    final ziel = weltEbenen.ebenen['turm']!.graph.orte['turm_am_schreibtisch']!;
    expect(dist(_pos(k).dx, _pos(k).dy, ziel.x, ziel.y), lessThan(AbendKarte.ankunftsRadius));
    expect(ankunft.last, ('turm', 'turm_am_schreibtisch'));
    // Über zwei Ebenen: vom Turm durch den Keller in den Hof.
    final hof = k.laufeZu('erdgeschoss', 'eg_am_brunnen');
    expect([for (final a in k.planeWeg('erdgeschoss', (weltEbenen.ebenen['erdgeschoss']!.graph.orte['eg_am_brunnen']!.x, 10.5))!) a.portal],
        ['p_wendeltreppe', 'p_hoftuer', null], reason: 'vom Turm hinab, durch den Keller und die Hoftür');
    await _treibe(k, hof);
    expect(await hof, isTrue);
    expect([k.aktuelleEbene, ankunft.last], ['erdgeschoss', ('erdgeschoss', 'eg_am_brunnen')]);
  });

  test('Geführt im Renderer: Die Figur folgt dem Weg, steht in jedem Bild frei und wechselt die Ebene mit Überblendung', () async {
    final k = _karte();
    final game = MordakteGame(session: k)..onGameResize(Vector2(390, 844));
    addTearDown(game.dispose);
    game.update(_dt);
    _pruefePlan(k, k.planeWeg('erdgeschoss', (weltEbenen.ebenen['erdgeschoss']!.graph.orte['eg_garten_beet']!.x, weltEbenen.ebenen['erdgeschoss']!.graph.orte['eg_garten_beet']!.y))!);
    var fertig = false;
    unawaited(k.laufeZu('erdgeschoss', 'eg_garten_beet').then((ok) => fertig = ok));
    var wechsel = false;
    for (var i = 0; i < 60 * 60 && !fertig; i++) {
      final ebene = k.aktuelleEbene;
      game.update(_dt);
      await Future<void>.delayed(Duration.zero);
      if (k.aktuelleEbene != ebene) {
        wechsel = true;
        game.update(_dt);
        expect(game.blende, greaterThan(0), reason: 'Überblendung beim Wechsel');
      }
      final p = game.eigenePosition;
      expect(k.rasterVon(k.aktuelleEbene).canStand(p.dx, p.dy, Tuning.playerRadius), isTrue, reason: 'Bild $i auf ${k.aktuelleEbene} bei $p');
      expect((p - _pos(k)).distance, lessThan(1e-6), reason: 'Der Renderer zeigt die geführte Stelle');
    }
    expect([fertig, wechsel, k.aktuelleEbene], [true, true, 'erdgeschoss']);
    game.update(_dt);
    expect((game.eigenePosition - _pos(k)).distance, lessThan(1e-6), reason: 'Am Ziel steht die Figur genau dort');
  });

  test('zurueckInDenKeller: geführt durch die Hoftür an den Startort; ohne offenen Weg mit einer Kurzblende', () async {
    final ankunft = <(String, String)>[];
    final k = _karte(onAnkunft: (e, o) => ankunft.add((e, o)));
    await _treibe(k, k.laufeZu('erdgeschoss', 'eg_halle_kamin'));
    expect(k.aktuelleEbene, 'erdgeschoss');
    final zurueck = k.zurueckInDenKeller();
    expect(k.laeuft, isTrue);
    await _treibe(k, zurueck);
    expect([k.aktuelleEbene, _pos(k)], [kellerEbene, Offset(k.kellerStart.$1, k.kellerStart.$2)]);
    expect(ankunft.last, (kellerEbene, k.ermittlungsOrt));

    // In der Außenwelt während der Runden (alle Tore zu): sofort zurück, kein Weg.
    final draussen = _karte(ebene: 'aussen', start: (21.5, 1.5));
    expect(draussen.aktuelleEbene, 'aussen');
    expect(draussen.planeWeg(kellerEbene, draussen.kellerStart), isNull);
    await draussen.zurueckInDenKeller();
    expect([draussen.aktuelleEbene, _pos(draussen), draussen.laeuft], [kellerEbene, Offset(draussen.kellerStart.$1, draussen.kellerStart.$2), false]);
    expect(draussen.scenario!.id, ebenenSzenarioId(kellerEbene));
    expect(draussen.world.value!.correctX, draussen.kellerStart.$1, reason: 'Der Renderer springt (Kurzblende) statt zu laufen');
  });

  testWidgets('zurueckInDenKeller endet auch ohne Renderer: Nach der Frist des Wachhunds steht der Detektiv am Startort', (t) async {
    final k = AbendKarte(partyDaten, weltEbenen, ebenenSzenarien, lage: _runde, ebene: 'turm', start: (2.5, 8.5));
    var fertig = false;
    unawaited(k.zurueckInDenKeller().then((_) => fertig = true));
    expect(k.laeuft, isTrue);
    await t.pump(const Duration(milliseconds: 500));
    expect(fertig, isFalse, reason: 'Der Wachhund wartet seine Frist ab');
    await t.pump(k.wachhundFrist);
    await t.pump();
    expect(fertig, isTrue);
    expect([k.aktuelleEbene, _pos(k)], [kellerEbene, Offset(k.kellerStart.$1, k.kellerStart.$2)]);
    await k.dispose();
  });

  test('Bewegung reduziert: Der geführte Weg springt ans Ziel; ein neuer Weg löst den alten ab', () async {
    final k = _karte()..bewegungReduziert = true;
    expect(await k.laufeZu('turm', 'turm_beim_sessel'), isTrue);
    expect(k.aktuelleEbene, 'turm');
    k.bewegungReduziert = false;
    final erster = k.laufeZu('turm', 'turm_an_der_zinne');
    final zweiter = k.laufeZu('turm', 'turm_am_schreibtisch');
    expect(await erster, isFalse, reason: 'abgelöst');
    k.abkuerzen();
    expect(await zweiter, isTrue);
    expect(() => k.laufeZu('turm', 'gibt_es_nicht'), throwsArgumentError);
  });

  test('Eine Ebene, die in der neuen Lage zu ist, führt mit einer Kurzblende in den Keller', () {
    final k = _karte(lage: _morgen);
    expect(k.wechsle('p_aussentor'), isTrue);
    expect(k.aktuelleEbene, 'aussen');
    k.wechsleLage(_runde);
    expect([k.aktuelleEbene, _pos(k)], [kellerEbene, Offset(k.kellerStart.$1, k.kellerStart.$2)]);
  });

  test('Ankunft beim Tippen: einmal je Ort, erst wer sich entfernt, kommt wieder an', () {
    final ankunft = <(String, String)>[];
    final k = _karte(onAnkunft: (e, o) => ankunft.add((e, o)));
    k.wechsle('p_hoftuer');
    ankunft.clear();
    final brunnen = weltEbenen.ebenen['erdgeschoss']!.graph.orte['eg_am_brunnen']!;
    k.move(brunnen.x + 0.3, brunnen.y, 0);
    k.move(brunnen.x + 0.2, brunnen.y, 0);
    expect(ankunft, [('erdgeschoss', 'eg_am_brunnen')]);
    // Weg vom Brunnen (an einen anderen Ort oder ins Leere) und wieder hin.
    k.move(brunnen.x + 3, brunnen.y, 0);
    k.move(brunnen.x, brunnen.y, 0);
    expect(ankunft.where((a) => a == ('erdgeschoss', 'eg_am_brunnen')), hasLength(2));
  });

  test('Keine Wirkung auf den Abend: Partie, Journal, Würfel und Nachtminuten bleiben, wie sie sind', () async {
    final s = PartySitzung(langDaten, wuerfel: const FesterWuerfel.neutral(), salz: '0123456789abcdef')
      ..einrichten(rollen: 5, detektiv: 'w', code: FallCode.fuerPfad('olli', langDaten.kanon.pfade).code, fassung: Abendfassung.lang);
    spieleBis(s, PartyPhase.entscheidungen);
    final vorher = jsonEncode(s.abendstand);
    final minuten = s.restMinuten, wuerfe = s.wuerfe.length;
    final k = AbendKarte(langDaten, weltEbenen, ebenenSzenarien, lage: _runde, quelle: SitzungsKartenQuelle(s));
    addTearDown(k.dispose);
    expect(_hotspots(k), containsAll(['p_wendeltreppe', 'p_hoftuer']), reason: 'Im Keller dazu die Ziele der Entscheidung');
    await _treibe(k, k.laufeZu('erdgeschoss', 'eg_garten_bank'));
    expect(_hotspots(k), {'p_hoftuer'}, reason: 'Auf den Ebenen keine Ziele der Entscheidung');
    k.send(const Interact('irgendwas'));
    await _treibe(k, k.zurueckInDenKeller());
    expect(jsonEncode(s.abendstand), vorher);
    expect([s.restMinuten, s.wuerfe.length, s.phase], [minuten, wuerfe, PartyPhase.entscheidungen]);
    s.dispose();
  });

  group('Tageslicht (SzenenLicht.tag)', () {
    test('Am Morgen draußen Tag, drinnen und im Keller Nacht; in den Runden überall Nacht', () {
      final k = _karte(lage: _morgen);
      expect(k.licht!.tag, isFalse, reason: 'Keller');
      k.wechsle('p_hoftuer');
      final eg = weltEbenen.ebenen['erdgeschoss']!.graph;
      final brunnen = eg.orte['eg_am_brunnen']!, kamin = eg.orte['eg_halle_kamin']!;
      k.setzeDetektiv(brunnen.x, brunnen.y);
      expect(k.licht!.tag, isTrue, reason: 'Hof am Morgen');
      k.setzeDetektiv(kamin.x, kamin.y);
      expect(k.licht!.tag, isFalse, reason: 'Halle bleibt drinnen');
      k.wechsleLage(_runde);
      k.setzeDetektiv(brunnen.x, brunnen.y);
      expect(k.licht!.tag, isFalse, reason: 'Hof in der Nacht');
    });

    test('Der Renderer wählt bei tag den Tag-Modus; die Nacht bleibt bytegleich', () {
      const nacht = SzenenLicht(dunkel: 0.58);
      final n = MordakteGame.szenenLichtModus(nacht);
      expect([n.mode, n.darkness, n.dayTint, n.taschenlampe], [LightMode.night, 0.58, 0, true], reason: 'wie vor M7b');
      expect(MordakteGame.szenenLichtModus(const SzenenLicht(dunkel: 1.4, taschenlampe: false)).darkness, 1, reason: 'begrenzt wie bisher');
      final t = MordakteGame.szenenLichtModus(const SzenenLicht(dunkel: 0.5, tag: true));
      expect([t.mode, t.taschenlampe], [LightMode.day, false]);
      expect(t.dayTint, lessThanOrEqualTo(0.15), reason: 'nur ein leichter Schleier');
      expect(MordakteGame.vignettenStaerke(nacht: true, tag: false, umgebung: false), 0.62);
      expect(MordakteGame.vignettenStaerke(nacht: false, tag: false, umgebung: false), 0.38);
      expect(MordakteGame.vignettenStaerke(nacht: false, tag: false, umgebung: true), 0.5);
      expect(MordakteGame.vignettenStaerke(nacht: false, tag: true, umgebung: true), lessThan(0.5));
    });

    test('Im Bild: Tageslicht ist deutlich heller als die Nacht derselben Szene', () async {
      Future<double> helligkeit(SzenenLicht l) async {
        final m = MordakteGame.szenenLichtModus(l);
        final rec = PictureRecorder();
        final c = Canvas(rec);
        const view = Rect.fromLTWH(0, 0, 64, 64);
        c.drawRect(view, Paint()..color = const Color(0xFFFFFFFF));
        LightingRenderer(ScenePalette.fallback)
            .render(c, view, mode: m.mode, darkness: m.darkness, lights: const [], litRooms: const [], glows: const [], dayTint: m.dayTint);
        final bild = await rec.endRecording().toImage(64, 64);
        final daten = (await bild.toByteData())!;
        bild.dispose();
        var summe = 0;
        for (var i = 0; i < daten.lengthInBytes; i += 4) {
          summe += daten.getUint8(i) + daten.getUint8(i + 1) + daten.getUint8(i + 2);
        }
        return summe / (daten.lengthInBytes / 4 * 3 * 255);
      }

      final tag = await helligkeit(const SzenenLicht(dunkel: 0.5, tag: true));
      final nacht = await helligkeit(const SzenenLicht(dunkel: 0.5));
      expect(tag, greaterThan(0.8));
      expect(nacht, lessThan(0.5));
    });
  });
}
