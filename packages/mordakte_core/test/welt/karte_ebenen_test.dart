// M7a: Welt-Ebenen des langen Abends (A-056, K1). Alle Ebenen sind erreichbar,
// Portale führen in beide Richtungen, das Außentor bleibt in den Runden zu, die
// Hoftür im kurzen Abend und von der Sperre (18:50) bis 00:15; im Vorspiel steht
// sie offen wie im Kanon (Lieferung um 18:30). Der Kanon-Keller bleibt unberührt.
import 'dart:convert';

import 'package:mordakte_core/mordakte_core.dart';
import 'package:test/test.dart';

import '../party/kanon_hilfe.dart';

Map<String, Object?> get _roh => leseJson('$repoWurzel/content/welt/schlosskeller/langfassung.json');
Map<String, Object?> get _regeln => leseJson('$repoWurzel/content/party/textregeln.json');

WeltEbenen? _welt;
WeltEbenen get welt => _welt ??= WeltEbenen.ausJson(_roh, kanon);

List<String> _befunde(WeltEbenen w) => pruefeEbenen(w, ton: Textpruefer(_regeln), regeln: _regeln);

/// Uhrzeiten von der Sperre bis kurz vor dem Morgen im Viertelstundentakt.
Iterable<Uhrzeit> get _nacht sync* {
  for (var t = welt.zeiten.sperre; t < welt.zeiten.morgen; t = t.plus(15 * 60)) {
    yield t;
  }
  yield welt.zeiten.morgen.plus(-1);
}

/// Das Portal, dessen Kellerseite auf der Kanon-Tür [tuer] liegt.
Portal _portalAn(String tuer) {
  final kacheln = kanon.graph.tueren[tuer]!.kacheln.toSet();
  return welt.portale.singleWhere((p) => p.seiteAuf(kellerEbene)?.kacheln.every(kacheln.contains) ?? false);
}

void main() {
  test('Schema und pruefeEbenen ohne Befund', () {
    final schema = SchemaPruefer(leseJson('$repoWurzel/content/welt/langfassung.schema.json')).pruefe(_roh);
    expect(schema, isEmpty, reason: schema.join('\n'));
    final f = _befunde(welt);
    expect(f, isEmpty, reason: f.join('\n'));
  });

  test('vier Ebenen, der Keller ist der Kanon-Graph, jede Ebene unter 70 × 60 Kacheln', () {
    expect(welt.ebenen.keys, ['keller', 'erdgeschoss', 'turm', 'aussen']);
    expect(identical(welt.keller.graph, kanon.graph), isTrue);
    for (final e in welt.ebenen.values.where((e) => !e.ausKanon)) {
      expect(e.graph.breite, lessThanOrEqualTo(ebeneHoechstBreite), reason: e.id);
      expect(e.graph.hoehe, lessThanOrEqualTo(ebeneHoechstHoehe), reason: e.id);
    }
  });

  test('mit allem offen (Morgen, langer Abend) sind alle Räume aller Ebenen erreichbar', () {
    final r = welt.erreichbareRaeume(WeltLage(lang: true, uhr: welt.zeiten.morgen));
    for (final e in welt.ebenen.values) {
      expect(r[e.id], e.graph.raeume.keys.toSet(), reason: e.id);
    }
  });

  test('Portale führen in beide Richtungen', () {
    final lage = WeltLage(lang: true, uhr: welt.zeiten.morgen);
    for (final p in welt.portale) {
      for (final (von, nach) in [(p.a, p.b), (p.b, p.a)]) {
        final r = welt.erreichbar(lage, von: (von.ebene, von.ankunft));
        expect(r[nach.ebene], contains(nach.ankunft), reason: '${p.id}: ${von.ebene} → ${nach.ebene}');
      }
    }
  });

  test('Außentor: in den Runden nie begehbar, die Außenwelt bleibt unerreichbar (beide Fassungen)', () {
    final tor = _portalAn('aussentor');
    for (final lang in [false, true]) {
      for (final uhr in _nacht) {
        final lage = WeltLage(lang: lang, uhr: uhr);
        expect(welt.offen(tor.offen, lage), isFalse, reason: '$lage');
        expect(welt.erreichbar(lage)['aussen'], isEmpty, reason: '$lage');
        for (final p in welt.portale.where((p) => p.seiteAuf('aussen') != null)) {
          expect(welt.offen(p.offen, lage), isFalse, reason: '${p.id} $lage');
        }
      }
    }
    expect(welt.offen(tor.offen, WeltLage.um('07:00')), isTrue, reason: 'am Morgen');
    expect(welt.offen(tor.offen, WeltLage.um('18:00')), isTrue, reason: 'im Vorspiel');
    expect(welt.offen(tor.offen, WeltLage.um('07:00', lang: false)), isFalse, reason: 'kurzer Abend');
  });

  test('Hoftür: im kurzen Abend zu, im langen ab der Sperre zu und ab 00:15 wieder offen', () {
    final hof = _portalAn('hoftuer');
    for (final uhr in [Uhrzeit.parse('18:00'), Uhrzeit.parse('18:30'), ..._nacht, welt.zeiten.morgen]) {
      final kurz = WeltLage(lang: false, uhr: uhr);
      expect(welt.offen(hof.offen, kurz), isFalse, reason: '$kurz');
      expect(welt.erreichbar(kurz)['erdgeschoss'], isEmpty, reason: '$kurz');
    }
    for (final uhr in [welt.zeiten.sperre, Uhrzeit.parse('23:30'), welt.zeiten.ersatzschluessel.plus(-1)]) {
      final lage = WeltLage(lang: true, uhr: uhr);
      expect(welt.offen(hof.offen, lage), isFalse, reason: '$lage');
      expect(welt.erreichbar(lage)['erdgeschoss'], isEmpty, reason: '$lage');
    }
    final danach = WeltLage.um('00:15');
    expect(welt.offen(hof.offen, danach), isTrue);
    expect(welt.erreichbareRaeume(danach)['erdgeschoss'], {'eg_hof', 'eg_garten', 'eg_halle', 'eg_kueche'});
  });

  test('Vorspiel wie im Kanon: Lieferung um 18:30 durch Hof und Hoftür, Herr Schneider schließt erst um 18:50 ab', () {
    // Kanon-Zeitleiste: z_lieferung (18:30, über den Schlosshof, durch die Hoftür) vor z_forderung (18:50, Sperre).
    final zeitleiste = {
      for (final e in (leseJson('$repoWurzel/content/party/schlosskeller/zeitleiste.json')['eintraege'] as List).cast<Map>())
        e['id']: Uhrzeit.parse(e['zeit'] as String),
    };
    final lieferung = zeitleiste['z_lieferung']!;
    expect([lieferung < welt.zeiten.sperre, welt.zeiten.sperre == zeitleiste['z_forderung']], [true, true]);
    final hof = _portalAn('hoftuer');
    final hoftuer = kanon.graph.tueren['hoftuer']!.kacheln.single;
    for (final uhr in [Uhrzeit.parse('18:00'), lieferung, welt.zeiten.sperre.plus(-1)]) {
      final lage = WeltLage(lang: true, uhr: uhr);
      expect(welt.offen(hof.offen, lage), isTrue, reason: 'Hoftür $lage');
      expect(welt.zugangOffen('erdgeschoss', lage), isTrue, reason: 'Hof $lage');
      expect(welt.erreichbareRaeume(lage)['erdgeschoss'], {'eg_hof', 'eg_garten'}, reason: 'Halle und Küche erst mit dem Ersatzschlüssel, $lage');
      expect(welt.raster(kellerEbene, lage).isLockedDoor(hoftuer.x, hoftuer.y), isFalse, reason: 'Kellerseite der Hoftür $lage');
      // Der Weg der Lieferung: vom Schlosshof durch die Hoftür in den Keller.
      final b = hof.seiteAuf('erdgeschoss')!;
      expect(welt.erreichbar(lage, von: ('erdgeschoss', b.ankunft))[kellerEbene], contains(hof.seiteAuf(kellerEbene)!.ankunft), reason: '$lage');
    }
    final gesperrt = WeltLage(lang: true, uhr: welt.zeiten.sperre);
    expect(welt.offen(hof.offen, gesperrt), isFalse, reason: 'Um 18:50 schließt Herr Schneider Hoftür und Außentor');
    expect(welt.offen(_portalAn('aussentor').offen, gesperrt), isFalse);
    expect(welt.raster(kellerEbene, gesperrt).isLockedDoor(hoftuer.x, hoftuer.y), isTrue);
  });

  test('Turm: Toilette immer, Turmzimmer und Wehrgang erst mit dem Ersatzschlüssel', () {
    for (final lage in [WeltLage.um('01:15', lang: false), WeltLage.um('00:10')]) {
      expect(welt.erreichbareRaeume(lage)['turm'], {'turm_treppe', 'turm_wc'}, reason: '$lage');
    }
    expect(welt.erreichbareRaeume(WeltLage.um('00:30'))['turm'], {'turm_treppe', 'turm_wc', 'turm_zimmer', 'turm_wehrgang'});
  });

  test('Kanon-Keller bleibt unberührt: Kanon-Raster zu, Darstellungsraster mit offenen Portalen', () {
    final hoftuer = kanon.graph.tueren['hoftuer']!.kacheln.single;
    final morgen = welt.raster(kellerEbene, WeltLage.um('07:00'));
    expect(morgen.isLockedDoor(hoftuer.x, hoftuer.y), isFalse);
    expect(kanon.graph.raster.isLockedDoor(hoftuer.x, hoftuer.y), isTrue);
    final verschlossen = {
      for (final t in kanon.graph.tueren.values)
        if (t.verschlossen) ...t.kacheln,
    };
    expect(welt.offeneKacheln(kellerEbene, WeltLage.um('01:15', lang: false)).intersection(verschlossen), isEmpty);
    expect(welt.offeneKacheln(kellerEbene, WeltLage.um('01:15')).intersection(verschlossen), {hoftuer});
  });

  test('Szenarien: Keller wie bisher plus Portale, die übrigen Ebenen nur mit Portalen', () {
    final vorlage = jsonDecode(jsonEncode(leseJson('$repoWurzel/content/scenarios/ravensmoor.json'))) as Map<String, dynamic>;
    final welt0 = leseJson('$repoWurzel/content/welt/schlosskeller/welt.json');
    final sz = partyEbenenSzenarien(kanon, vorlage, welt, welt: welt0);
    final kurz = ScenarioDef.fromJson(partySzenarioJson(kanon, vorlage, welt: welt0));
    expect(sz.keys, welt.ebenen.keys);
    final k = sz[kellerEbene]!;
    expect(k.id, kurz.id);
    expect(k.map.rows, kurz.map.rows);
    expect(k.map.rows, kanon.graph.karte.rows);
    expect(jsonEncode([for (final p in k.map.props) [p.type, p.x, p.y]]), jsonEncode([for (final p in kurz.map.props) [p.type, p.x, p.y]]));
    expect([for (final h in k.hotspots) h.id], [for (final h in kurz.hotspots) h.id, for (final (p, _) in welt.portaleAuf(kellerEbene)) p.id]);
    for (final e in welt.ebenen.values.where((e) => !e.ausKanon)) {
      final s = sz[e.id]!;
      expect(s.id, ebenenSzenarioId(e.id));
      expect(s.map.rows, e.graph.karte.rows);
      expect({for (final h in s.hotspots) h.id}, {for (final (p, _) in welt.portaleAuf(e.id)) p.id}, reason: e.id);
      expect(s.theme.backdrop, 'schloss');
      expect(validateScenario(s).errors.where((x) => x.contains('backdrop')), isEmpty);
      expect(TileGrid(s.map).walkable(s.map.spawn.first.x, s.map.spawn.first.y), isTrue, reason: '${e.id}: Start');
    }
  });

  group('Rot-Probe: pruefeEbenen findet', () {
    Map<String, Object?> kopie() => jsonDecode(jsonEncode(_roh)) as Map<String, Object?>;
    Map ebene(Map<String, Object?> j, String id) => (j['ebenen'] as List).cast<Map>().singleWhere((e) => e['id'] == id);
    Map portal(Map<String, Object?> j, String id) => (j['portale'] as List).cast<Map>().singleWhere((p) => p['id'] == id);
    List<String> befunde(Map<String, Object?> j) => _befunde(WeltEbenen.ausJson(j, kanon));

    test('ein Außentor, das in den Runden offen ist', () {
      final j = kopie();
      portal(j, 'p_aussentor')['offen'] = 'nach_ersatzschluessel';
      expect(befunde(j), contains(startsWith('aussen ist in der Lage lang')));
    });

    test('eine Hoftür, die immer offen ist', () {
      final j = kopie();
      portal(j, 'p_hoftuer')['offen'] = 'immer';
      final f = befunde(j);
      expect(f, contains(contains('verschlossene Kanon-Tür hoftuer öffnet immer')));
      expect(f, contains(startsWith('erdgeschoss ist in der Lage kurz')));
    });

    test('eine Kanon-Kennung, eine zu große Ebene, ein Sperrwort und eine abgeschnittene Kachel', () {
      final j = kopie();
      final eg = ebene(j, 'erdgeschoss');
      ((eg['orte'] as List).first as Map)['id'] = 'wc';
      (eg['raster'] as Map)['breite'] = 80;
      ((eg['rooms'] as List).first as Map)['beschreibung'] = 'Hier brennt eine Kerze.';
      final f = befunde(j);
      expect(f, contains(contains('Kennung wc gehört dem Kanon')));
      expect(f, contains(contains('ist größer als 70 × 60')));
      expect(f, contains(contains('Sperrwort „Kerze“')));

      final k = kopie();
      final t = ebene(k, 'turm');
      ((t['tueren'] as List).cast<Map>().singleWhere((d) => d['id'] == 'turm_wehrgang_tuer'))['zustand'] = 'verschlossen';
      expect(befunde(k), contains(contains('verschlossene Tür turm_wehrgang_tuer hat keine Bedingung')));
    });
  });
}
