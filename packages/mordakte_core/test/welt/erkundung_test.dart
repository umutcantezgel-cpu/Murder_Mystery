// M7b Streifzug: Erkundung des langen Abends. Fünfzehn Orte und die
// Treffpunkte der Befragungen, in den Runden erreichbar, nie in der
// Außenwelt, reine Stimmung (R15, R17). Kosmetischer Zufall nur über den
// Samen der Welt. Gegenproben: Der Prüfer schlägt bei jedem Verstoß an.
import 'dart:convert';

import 'package:mordakte_core/mordakte_core.dart';
import 'package:mordakte_core/src/karten/sperrwoerter.dart' show spoilerWoerter;
import 'package:test/test.dart';

import '../party/kanon_hilfe.dart';

Map<String, Object?> get _roh => leseJson('$repoWurzel/content/welt/schlosskeller/erkundung.json');
Map<String, Object?> get _regeln => leseJson('$repoWurzel/content/party/textregeln.json');

WeltEbenen? _welt;
WeltEbenen get welt => _welt ??= WeltEbenen.ausJson(leseJson('$repoWurzel/content/welt/schlosskeller/langfassung.json'), kanon);

Erkundung get erkundung => Erkundung.ausJson(_roh);

List<String> _befunde(Erkundung e) => pruefeErkundung(e, welt, ton: Textpruefer(_regeln), regeln: _regeln);

/// Kopie der Rohdaten, an der [aendern] etwas verändert.
Erkundung _mit(void Function(Map<String, dynamic> j) aendern) {
  final j = jsonDecode(jsonEncode(_roh)) as Map<String, dynamic>;
  aendern(j);
  return Erkundung.ausJson(j);
}

/// Setzt die erste Zeile der Stichpunkte des Orts [id].
Erkundung _zeile(String id, String text) => _mit((j) {
      final o = (j['orte'] as List).cast<Map<String, dynamic>>().firstWhere((o) => o['id'] == id);
      (o['stichpunkte'] as List)[0] = text;
    });

Map<String, dynamic> _ort(Map<String, dynamic> j, String id) => (j['orte'] as List).cast<Map<String, dynamic>>().firstWhere((o) => o['id'] == id);

void main() {
  test('welt.json nennt die Erkundung; Schema und pruefeErkundung ohne Befund', () {
    expect(leseJson('$repoWurzel/content/welt/schlosskeller/welt.json')['erkundung'], 'erkundung.json');
    final schema = SchemaPruefer(leseJson('$repoWurzel/content/welt/erkundung.schema.json')).pruefe(_roh);
    expect(schema, isEmpty, reason: schema.join('\n'));
    final f = _befunde(erkundung);
    expect(f, isEmpty, reason: f.join('\n'));
  });

  test('15 Orte über Keller-Rand, Erdgeschoss, Hof und Garten und Turm; 8–12 Treffpunkte; nichts in der Außenwelt', () {
    final e = erkundung;
    expect(e.orte, hasLength(erkundungAnzahl));
    expect(erkundungAnzahl, 15);
    expect(e.treffpunkte.length, inInclusiveRange(treffpunkteMindestens, treffpunkteHoechstens));
    final gruppen = <String, int>{};
    for (final o in e.orte) {
      expect(o.ebene, isNot('aussen'), reason: o.id);
      final stelle = erkundungsStelle(welt, o)!;
      gruppen.update(erkundungsGruppe(welt, o, stelle)!, (n) => n + 1, ifAbsent: () => 1);
    }
    expect(gruppen.keys.toSet(), erkundungsGruppen.toSet());
    for (final t in e.treffpunkte) {
      expect(['erdgeschoss', 'turm'], contains(t.ebene), reason: t.id);
    }
    final ids = [for (final o in e.orte) o.id, for (final t in e.treffpunkte) t.id];
    expect(ids.toSet(), hasLength(ids.length));
  });

  test('jeder Ort und Treffpunkt ist in jeder Runde des langen Abends erreichbar; im kurzen Abend nur der Keller', () {
    final lagen = rundenLagen(kanon);
    expect([for (final l in lagen) l.uhr.toString()], ['00:30', '01:15', '02:00']);
    for (final l in lagen) {
      final r = welt.erreichbar(l);
      for (final o in erkundung.orte) {
        final (x, y) = erkundungsStelle(welt, o, raster: welt.raster(o.ebene, l))!;
        expect(welt.raster(o.ebene, l).canStand(x, y, 0.28), isTrue, reason: '${o.id} $l');
        expect(r[o.ebene], contains(Pt(x.floor(), y.floor())), reason: '${o.id} $l');
      }
      for (final t in erkundung.treffpunkte) {
        final (x, y) = treffpunktStelle(welt, t)!;
        expect(r[t.ebene], contains(Pt(x.floor(), y.floor())), reason: '${t.id} $l');
      }
      // Kurz: Hoftür zu, das Erdgeschoss bleibt unerreichbar (nur der Keller-Rand zählt dort).
      final kurz = welt.erreichbar(WeltLage(lang: false, uhr: l.uhr));
      expect(kurz['erdgeschoss'], isEmpty, reason: '$l');
    }
  });

  test('Keller-Rand: kein Sperrort, kein Ziel-Raum, weit weg von allem, was der Fall untersucht', () {
    final keller = [for (final o in erkundung.orte) if (o.ebene == kellerEbene) o];
    expect(keller, isNotEmpty);
    for (final o in keller) {
      final ort = kanon.graph.orte[o.ziel.ort]!;
      for (final g in kanon.gegenstaende) {
        expect((g['lage'] as Map?)?['ort'], isNot(ort.id), reason: o.id);
      }
      expect(['thekensaal', 'ost_saal', 'turmgang'], isNot(contains(ort.raum)), reason: o.id);
    }
  });

  test('keine Spoilerwörter, Namen oder Uhrzeiten; R17 in allen Fassungen', () {
    final namen = [for (final f in kanon.figuren) (f['name'] as String).toLowerCase()];
    for (final q in erkundungsTexte(erkundung)) {
      final t = q.text.toLowerCase();
      for (final w in spoilerWoerter) {
        expect(t, isNot(contains(w)), reason: q.ort);
      }
      for (final n in namen) {
        expect(RegExp('\\b${RegExp.escape(n)}\\b').hasMatch(t), isFalse, reason: '${q.ort}: $n');
      }
      expect(t, isNot(contains('geburtstag')), reason: q.ort);
      expect(RegExp(r'\d').hasMatch(t), isFalse, reason: q.ort);
    }
    for (final o in erkundung.orte) {
      for (final liste in [o.stichpunkte, ...o.varianten]) {
        expect(liste.length, inInclusiveRange(1, erkundungPunkte), reason: o.id);
        for (final z in liste) {
          expect(RegExp(r'[\p{L}\p{N}]+', unicode: true).allMatches(z).length, lessThanOrEqualTo(erkundungWorte), reason: '${o.id}: $z');
        }
      }
    }
  });

  test('Varianten: gleicher Samen, gleiche Fassung; verschiedene Samen zeigen alle Fassungen', () {
    final o = erkundung.orte.firstWhere((o) => o.varianten.isNotEmpty);
    expect(o.stichpunkteFuer(42), same(o.stichpunkteFuer(42)));
    final i = Rng(Rng.hashString('lang:42:erkundung:${o.id}')).nextInt(o.varianten.length + 1);
    expect(o.stichpunkteFuer(42), i == 0 ? o.stichpunkte : o.varianten[i - 1]);
    final gesehen = {for (var s = 0; s < 200; s++) o.stichpunkteFuer(s)};
    expect(gesehen, hasLength(o.varianten.length + 1));
    final ohne = erkundung.orte.firstWhere((o) => o.varianten.isEmpty);
    expect(ohne.stichpunkteFuer(7), same(ohne.stichpunkte));
  });

  test('Treffpunkte der Befragungen: aus dem Samen der Welt, je Runde verschieden, deterministisch', () {
    final e = erkundung;
    const ids = ['bf_ahmet_1', 'bf_fatma_1', 'bf_olli_1', 'bf_can_1', 'bf_leyla_1'];
    final a = e.treffpunkteFuer(1234, ids);
    expect(a.keys, ids);
    expect(e.treffpunkteFuer(1234, ids).map((k, v) => MapEntry(k, v.id)), a.map((k, v) => MapEntry(k, v.id)));
    expect({for (final t in a.values) t.id}, hasLength(ids.length), reason: 'genug Treffpunkte: keine zwei am selben Ort');
    // Die erste Befragung zieht genau nach der Formel.
    expect(a['bf_ahmet_1'], e.treffpunkte[Rng(Rng.hashString('lang:1234:treff:bf_ahmet_1')).nextInt(e.treffpunkte.length)]);
    // Mehr Befragungen als Treffpunkte: dann teilen sie sich Orte, ohne Fehler.
    final viele = [for (var i = 0; i < e.treffpunkte.length + 3; i++) 'bf_x${i}_1'];
    final v = e.treffpunkteFuer(9, viele);
    expect(v, hasLength(viele.length));
    expect({for (final t in v.values) t.id}, hasLength(e.treffpunkte.length));
    // Ein anderer Samen ergibt (meist) andere Treffpunkte.
    final andere = {for (var s = 0; s < 20; s++) e.treffpunkteFuer(s, ids)['bf_ahmet_1']!.id};
    expect(andere.length, greaterThan(1));
  });

  group('Gegenproben: der Prüfer schlägt an', () {
    test('Sperrwort, Name, Gegenstand, Sperrort, Beiname, Vorfall', () {
      for (final (zeile, grund) in [
        ('Hier hängt kein Schlüssel.', 'Sperrwort'),
        ('Ahmet stand vorhin hier.', 'Name'),
        ('Eine Notlaterne flackert matt.', 'Gegenstand'),
        ('Wie an der Kamin-Nische unten.', 'Sperrort'),
        ('Ein Schlossgeist soll hier wohnen.', 'Beiname'),
        ('Hier riecht es nach Geld.', 'Vorfall'),
        ('Die Laterne brennt schwach.', 'Teil eines Gegenstands'),
        ('Ein Geburtstagskuchen stand hier.', 'Geburtstag'),
        ('Ein Burgsaal voller Bilder.', 'Raumwort'),
      ]) {
        expect(_befunde(_zeile('ek_brunnen', zeile)), isNotEmpty, reason: grund);
      }
    });

    test('R17: zu viele Wörter, zu viele Stichpunkte, zu langer Titel', () {
      expect(_befunde(_zeile('ek_brunnen', 'Eins zwei drei vier fünf sechs sieben acht neun.')), isNotEmpty);
      expect(_befunde(_mit((j) => (_ort(j, 'ek_brunnen')['stichpunkte'] as List).add('Noch ein Satz am Brunnen.'))), isNotEmpty);
      expect(_befunde(_mit((j) => _ort(j, 'ek_brunnen')['titel'] = 'Ein sehr alter und tiefer Brunnen')), isNotEmpty);
    });

    test('Fünf-Wort-Leck aus einer geschützten Kanonstelle', () {
      final b = (kanon.bonusJson['hinweise'] as List).cast<Map>().first['text'] as String;
      final fuenf = RegExp(r'[\p{L}\p{N}]+', unicode: true).allMatches(b).take(5).map((m) => m.group(0)).join(' ');
      expect(pruefeErkundung(_zeile('ek_brunnen', '$fuenf.'), welt), contains(contains('übernimmt')));
    });

    test('Außenwelt, Wand, unbekanntes Ziel, Sperrort im Keller, doppelte Stelle', () {
      expect(_befunde(_mit((j) {
        _ort(j, 'ek_brunnen')['ebene'] = 'aussen';
        _ort(j, 'ek_brunnen')['ziel'] = {'ort': 'aussen_park_bank'};
      })), contains(contains('nicht in jeder Runde zugänglich')));
      expect(_befunde(_mit((j) => _ort(j, 'ek_brunnen')['ziel'] = {'kachel': [0, 0]})), contains(contains('ek_brunnen')));
      expect(_befunde(_mit((j) => _ort(j, 'ek_brunnen')['ziel'] = {'ding': 'gibt_es_nicht'})), contains(contains('gibt es auf')));
      expect(_befunde(_mit((j) => _ort(j, 'ek_windfang')['ziel'] = {'ort': 'am_kamin'})), contains(contains('Sperrort')));
      expect(_befunde(_mit((j) => _ort(j, 'ek_windfang')['ziel'] = {'ort': 'am_handykorb'})), contains(contains('Ziel-Raum')));
      expect(_befunde(_mit((j) => _ort(j, 'ek_hofbank')['ziel'] = {'kachel': [25, 6]})), contains(contains('Ankunftsradius')));
      // Hinter der Seitentür vor dem Ersatzschlüssel: In den Runden ist sie offen, die Kachel dahinter also erreichbar.
      expect(_befunde(_mit((j) => _ort(j, 'ek_standuhr')['ziel'] = {'kachel': [22, 15]})), isEmpty, reason: 'offene Seitentür');
    });

    test('Anzahl, Kennungen, Treffpunkte', () {
      expect(_befunde(_mit((j) => (j['orte'] as List).removeLast())), contains(contains('Erkundungsorte statt 15')));
      expect(_befunde(_mit((j) => _ort(j, 'ek_herd')['id'] = 'ek_brunnen')), contains(contains('doppelt')));
      expect(_befunde(_mit((j) => _ort(j, 'ek_herd')['id'] = 'eg_brunnen')), contains(contains('gehört dem Kanon')));
      expect(_befunde(_mit((j) => (j['treffpunkte'] as List).removeRange(0, 4))), contains(contains('Treffpunkte (erlaubt')));
      expect(_befunde(_mit((j) {
        final t = (j['treffpunkte'] as List).cast<Map<String, dynamic>>().first;
        t['ebene'] = 'keller';
        t['ort'] = 'vor_theke';
      })), contains(contains('Erdgeschoss oder im Turm')));
      expect(_befunde(_mit((j) {
        final t = (j['treffpunkte'] as List).cast<Map<String, dynamic>>();
        t[1]['ort'] = t[0]['ort'];
      })), contains(contains('schon ein Treffpunkt')));
    });
  });
}
