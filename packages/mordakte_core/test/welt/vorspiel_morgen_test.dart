// M7b: Vorspiel und Morgen des langen Abends (vorspiel_morgen.json). Schema und
// Prüfer ohne Befund; Rundgänge über die Ebenen mit den Toren der Kanon-Zeitleiste
// (Vorspiel bis zur Sperre um zehn vor sieben, Morgen ab sieben mit dem
// Torschlüssel der Kollegin); Karten nach R17, keine Fallhinweise, der Morgen
// ende-neutral oder je Ende. Rot-Proben zeigen, dass der Prüfer greift.
import 'dart:convert';

import 'package:mordakte_core/mordakte_core.dart';
import 'package:test/test.dart';

import '../party/kanon_hilfe.dart';

Map<String, Object?> get _roh => leseJson('$repoWurzel/content/welt/schlosskeller/vorspiel_morgen.json');
Map<String, Object?> get _regeln => leseJson('$repoWurzel/content/party/textregeln.json');

WeltEbenen? _welt;
WeltEbenen get welt => _welt ??= WeltEbenen.ausJson(leseJson('$repoWurzel/content/welt/schlosskeller/langfassung.json'), kanon);

Texte? _texte;
Texte get texte => _texte ??= Texte(kanon, Textsammlung.lade((p) => leseJson('$repoWurzel/content/party/schlosskeller/$p')));

List<String> _befunde(Map<String, Object?> j) =>
    pruefeVorspielMorgen(VorspielMorgen.ausJson(j), welt, ton: Textpruefer(_regeln), regeln: _regeln, geschuetzt: steckbriefGeschuetzt(texte));

Map<String, Object?> _kopie() => jsonDecode(jsonEncode(_roh)) as Map<String, Object?>;

Map _station(Map<String, Object?> j, String teil, String id) =>
    ((j[teil] as Map)['stationen'] as List).cast<Map>().singleWhere((s) => s['id'] == id);

void main() {
  test('Schema und pruefeVorspielMorgen ohne Befund', () {
    final schema = SchemaPruefer(leseJson('$repoWurzel/content/welt/vorspiel_morgen.schema.json')).pruefe(_roh);
    expect(schema, isEmpty, reason: schema.join('\n'));
    final f = _befunde(_roh);
    expect(f, isEmpty, reason: f.join('\n'));
  });

  test('Vorspiel: draußen ankommen, über Außenwelt, Hof und Garten bis in den Keller; die Sperre um zehn vor sieben zuletzt', () {
    final v = VorspielMorgen.ausJson(_roh).vorspiel;
    expect([v.startEbene, v.startZeit], ['aussen', Uhrzeit.parse('18:00')]);
    expect({for (final s in v.stationen) s.ebene}, containsAll(['aussen', 'erdgeschoss', kellerEbene]));
    expect(v.stationen.length, inInclusiveRange(rundgangStationenMin, rundgangStationenMax));
    final sperre = v.stationen.last;
    expect([sperre.ebene, sperre.zeit], [kellerEbene, welt.zeiten.sperre]);
    expect(sperre.textFuer(null).vorlesen, allOf(contains('Hoftür'), contains('Einfahrtstor'), contains('Außentor')));
    // Bis zur Sperre stehen Einfahrtstor, Außentor und Hoftür offen: Der Weg jeder Station läuft in dieser Lage.
    for (final (i, s) in v.stationen.indexed) {
      final weg = v.wegLage(i);
      expect(weg.uhr < welt.zeiten.sperre, isTrue, reason: s.id);
      for (final p in welt.portale) {
        expect(welt.offen(p.offen, weg), isTrue, reason: '${p.id} auf dem Weg zu ${s.id}');
      }
    }
    // Ab der Station zur Sperre ist alles zu, außer der Wendeltreppe.
    expect([for (final p in welt.portale) if (welt.offen(p.offen, sperre.lage)) p.id], ['p_wendeltreppe']);
    // Kein Text je Ende im Vorspiel.
    expect(v.stationen.every((s) => s.jeEnde.isEmpty && s.text != null), isTrue);
  });

  test('Morgen: ab sieben aus dem Keller nach draußen; die letzte Station je Ende, alle übrigen ende-neutral', () {
    final m = VorspielMorgen.ausJson(_roh).morgen;
    expect([m.startEbene, m.startOrt, m.startZeit], [kellerEbene, 'geburtstagsplatz', welt.zeiten.morgen]);
    expect(m.stationen.first.zeit, welt.zeiten.morgen);
    expect(m.stationen.first.textFuer(null).vorlesen, allOf(contains('Torschlüssel'), contains('Außentor'), contains('Einfahrtstor')));
    for (final s in m.stationen) {
      expect(s.ebene, isNot(kellerEbene), reason: '${s.id}: Der Morgen läuft draußen');
      expect(welt.offen(Oeffnung.nieInRunden, s.lage), isTrue, reason: '${s.id}: Tageslicht ab sieben');
    }
    final enden = [for (final r in Enden(kanon).regeln) r.id];
    final abschied = m.stationen.last;
    expect(abschied.jeEnde.keys.toSet(), enden.toSet());
    expect({for (final e in enden) abschied.textFuer(e).vorlesen}.length, enden.length, reason: 'je Ende ein eigener Text');
    for (final s in m.stationen.take(m.stationen.length - 1)) {
      expect([s.jeEnde, s.text], [isEmpty, isNotNull], reason: s.id);
      expect(identical(s.textFuer('ende_meister'), s.textFuer('ende_eskalation')), isTrue, reason: s.id);
    }
  });

  test('Figuren nur ohne Verdacht und nur auf den neuen Ebenen; die Karte trägt nie den Vorlesetext', () {
    final v = VorspielMorgen.ausJson(_roh);
    for (final r in [v.vorspiel, v.morgen]) {
      for (final s in r.stationen) {
        for (final x in s.figuren) {
          expect(kanon.kernverdaechtige, isNot(contains(x.figur)), reason: s.id);
          expect(s.ebene, isNot(kellerEbene));
        }
        for (final (_, t) in s.texte) {
          expect(t.karteJson().keys, ['titel', 'punkte']);
          expect(jsonEncode(t.karteJson()), isNot(contains(t.vorlesen)));
        }
      }
    }
  });

  group('Rot-Probe: pruefeVorspielMorgen findet', () {
    test('eine Station im Hof nach der Sperre (Tore zu, Hof unerreichbar)', () {
      final j = _kopie();
      _station(j, 'vorspiel', 'v_lieferung')['zeit'] = '19:00';
      _station(j, 'vorspiel', 'v_garten')['zeit'] = '19:00';
      final f = _befunde(j);
      expect(f, contains(contains('v_lieferung um 19:00 liegt nicht vor der Sperre')));
      expect(f, contains(contains('v_lieferung: erdgeschoss ist um 19:00 nicht zugänglich')));
      // Vom Garten in den Keller geht es nur durch die Hoftür, und die ist um sieben zu.
      expect(f, contains(contains('v_sperre (keller/geburtstagsplatz) ist um 19:00 vom Ort davor nicht erreichbar')));
      expect(f, contains(contains('v_sperre um 18:50 liegt vor der Station davor')));
    });

    test('eine Sperre, die das Einfahrtstor nicht nennt, und einen Morgen vor sieben', () {
      final j = _kopie();
      final sperre = _station(j, 'vorspiel', 'v_sperre');
      ((sperre['text'] as Map)['vorlesen'] as String).let((t) => (sperre['text'] as Map)['vorlesen'] = t.replaceAll('das Einfahrtstor und ', ''));
      _station(j, 'morgen', 'm_kollegin')['zeit'] = '06:30';
      final f = _befunde(j);
      expect(f, contains(contains('nennt das Einfahrtstor nicht')));
      expect(f, contains(contains('erste Station m_kollegin liegt nicht bei der Morgenzeit')));
      expect(f, contains(contains('m_kollegin: aussen ist um 06:30 nicht zugänglich')));
    });

    test('Karten gegen R17: vier Stichpunkte, ein zu langer Stichpunkt, ein langer Titel', () {
      final j = _kopie();
      final t = _station(j, 'vorspiel', 'v_park')['text'] as Map;
      (t['punkte'] as List).add('Noch ein Punkt.');
      final u = _station(j, 'morgen', 'm_garten')['text'] as Map;
      (u['punkte'] as List)[0] = 'Raureif liegt auf allen Hecken und auf allen Beeten.';
      u['titel'] = 'Ganz viel Stille im alten Garten';
      final f = _befunde(j);
      expect(f, contains(contains('v_park: 4 Stichpunkte statt 1 bis 3 (R17)')));
      expect(f, contains(contains('m_garten: Stichpunkt mit 9 Wörtern statt höchstens 8 (R17)')));
      expect(f, contains(contains('m_garten: Titel mit 6 Wörtern')));
    });

    test('Fallhinweise (R15): ein Kernverdächtiger als Figur und im Text, ein Gegenstand, Ziffern, Geburtstag', () {
      final j = _kopie();
      (_station(j, 'vorspiel', 'v_lieferung')['figuren'] as List).add({'figur': 'olli', 'ort': 'eg_hof_bank'});
      final t = _station(j, 'vorspiel', 'v_lieferung')['text'] as Map;
      t['vorlesen'] = '${t['vorlesen']} Ahmet trägt die Brottasche hinein.';
      (t['punkte'] as List)[0] = 'Um 18:30 kommt der Lieferwagen.';
      final u = _station(j, 'vorspiel', 'v_ankunft')['text'] as Map;
      u['vorlesen'] = '${u['vorlesen']} Es ist ein Geburtstag.';
      final f = _befunde(j);
      expect(f, contains(contains('olli ist kernverdächtig (R15)')));
      expect(f, contains(contains('nennt Ahmet (R15)')));
      expect(f, contains(contains('„Brottasche“ gehört nicht in Vorspiel oder Morgen (R15)')));
      expect(f, contains(contains('Ziffern verraten Zeiten oder Mengen')));
      expect(f, contains(contains('Geburtstag (A-061)')));
    });

    test('ein Morgen, der ein Urteil verrät, ein fehlendes Ende und Texte je Ende im Vorspiel', () {
      final j = _kopie();
      final t = _station(j, 'morgen', 'm_hof')['text'] as Map;
      t['vorlesen'] = '${t['vorlesen']} Der Täter gesteht alles.';
      ((_station(j, 'morgen', 'm_abschied')['jeEnde']) as Map).remove('ende_eskalation');
      final park = _station(j, 'vorspiel', 'v_park');
      park['jeEnde'] = {'ende_meister': park['text']};
      final f = _befunde(j);
      expect(f, contains(contains('„gesteht“ passt nicht zu jedem Ende')));
      expect(f, contains(contains('„Täter“ gehört nicht in Vorspiel oder Morgen (R15)')));
      expect(f, contains(contains('Texte je Ende für ende_meister, ende_teilerfolg, ende_justizirrtum statt für')));
      expect(f, contains(contains('v_park: Texte je Ende gibt es nur am Morgen')));
      expect(f, contains(contains('v_park braucht genau einen gemeinsamen Text oder Texte je Ende')));
    });

    test('eine Fünf-Wort-Folge aus einem Dossier und ein Ort im Keller außer dem Ermittlungsort', () {
      final j = _kopie();
      final geheim = texte.sammlung.dossiers['murat']!.ziel;
      final t = _station(j, 'morgen', 'm_hof')['text'] as Map;
      t['vorlesen'] = '${t['vorlesen']} $geheim';
      _station(j, 'vorspiel', 'v_sperre')['ort'] = 'im_windfang';
      final f = _befunde(j);
      expect(f, contains(contains('stammt aus Dossier murat.ziel')));
      expect(f, contains(contains('führt im Keller an im_windfang statt an den Ermittlungsort geburtstagsplatz')));
    });

    test('Raumwörter, die kein Raum sind, und ein zu langer Rundgang', () {
      final j = _kopie();
      final t = _station(j, 'morgen', 'm_hof')['text'] as Map;
      t['vorlesen'] = '${t['vorlesen']} Im Laderaum klappern die Behälter.';
      final stationen = (j['morgen'] as Map)['stationen'] as List;
      stationen.insert(1, {...(stationen[1] as Map), 'id': 'm_zwei'});
      stationen.insert(1, {...(stationen[1] as Map), 'id': 'm_drei'});
      final f = _befunde(j);
      expect(f, contains(contains('Raumwort „Laderaum“ ist kein Raum')));
      expect(f, contains(contains('morgen: 7 Stationen (erlaubt 4–6)')));
    });
  });
}

extension<T> on T {
  R let<R>(R Function(T) f) => f(this);
}
