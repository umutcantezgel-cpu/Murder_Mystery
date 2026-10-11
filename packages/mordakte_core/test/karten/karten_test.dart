import 'package:mordakte_core/runden.dart';
import 'package:test/test.dart';

/// Karte der Akte Schlosskeller; die Kennung folgt `<akte>:<figur>:<slug>`.
KartenDef _karte(String figur, String slug, KartenArt art, {
  int ladungen = 1, int wert = 1, Seltenheit seltenheit = Seltenheit.gewoehnlich,
  List<KartenQuelle> quellen = const [KartenQuelle('rolle')],
}) => KartenDef(
  id: 'schlosskeller:$figur:$slug', akte: 'schlosskeller', figur: figur, seltenheit: seltenheit, art: art,
  ladungen: ladungen, wert: wert, titel: 'Titel $slug', text: 'Text $slug', quellen: quellen,
);

Matcher _kartenFehler(String code) => isA<KartenFehler>().having((e) => e.code, 'code', code);

List<String> _befunde(KartenDef k) => KartenKatalog([k]).pruefe();

AbendErgebnis _abend({
  String rolle = 'can', String pfad = 'ahmet', bool anklageRichtig = false,
  String ende = 'ende_teilerfolg', Set<String> funde = const {}, String spieler = 'p1',
}) => AbendErgebnis(
  akte: 'schlosskeller', salz: 'belohnung-salz', spielerId: spieler, rolle: rolle, pfad: pfad,
  anklageRichtig: anklageRichtig, ende: ende, abstecherFunde: funde,
);

void main() {
  final werkzeug = _karte('ahmet', 'w1', KartenArt.werkzeug);
  final werkzeug2 = _karte('ahmet', 'w2', KartenArt.werkzeug);
  final marke = _karte('can', 'm1', KartenArt.marke);
  final zeit = _karte('can', 'z1', KartenArt.zeit, ladungen: 2, wert: 3);
  final gruendlich = _karte('fatma', 'g1', KartenArt.gruendlich);
  final kosmetik = _karte('fatma', 'k1', KartenArt.kosmetik);
  final katalog = KartenKatalog([werkzeug, werkzeug2, marke, zeit, gruendlich, kosmetik]);

  // Belohnungsquellen: Täterfigur Ahmet, Meister-Karte der Akte, Fundorte ab_1 und ab_2.
  final taeter = _karte('ahmet', 'taeter', KartenArt.zeit, wert: 3, quellen: const [KartenQuelle('taeter')]);
  final meister = _karte('can', 'meister', KartenArt.gruendlich,
      seltenheit: Seltenheit.legendaer, quellen: const [KartenQuelle('meister')]);
  final fund1 = _karte('can', 'fund1', KartenArt.abstecher, quellen: const [KartenQuelle('abstecher', abstecher: 'ab_1')]);
  final fund2 = _karte('can', 'fund2', KartenArt.abstecher, quellen: const [KartenQuelle('abstecher', abstecher: 'ab_2')]);
  final rolle = _karte('can', 'rolle', KartenArt.werkzeug);

  test('Tischvorrat nimmt höchstens drei Karten in Wunschreihenfolge', () {
    final v = TischVorrat.aus([gruendlich.id, werkzeug.id, marke.id, zeit.id], katalog);
    expect(v.karten.map((k) => k.id), [gruendlich.id, werkzeug.id, marke.id]);
    expect(v.toJson().map((e) => e['id']), [gruendlich.id, werkzeug.id, marke.id]);
    expect(v.verfuegbar(zeit.id), isFalse);
  });

  test('Tischvorrat: je Art nur eine Karte', () {
    final v = TischVorrat.aus([werkzeug.id, werkzeug2.id], katalog);
    expect(v.karten.map((k) => k.id), [werkzeug.id]);
    expect(v.rest(werkzeug2.id), 0);
  });

  test('Tischvorrat: höchstens vier Ladungen, Überzähliges wird übergangen', () {
    final a = _karte('ahmet', 'la', KartenArt.werkzeug, ladungen: 2);
    final b = _karte('can', 'lb', KartenArt.marke);
    final c = _karte('fatma', 'lc', KartenArt.zeit, ladungen: 2, wert: 3);
    final d = _karte('fatma', 'ld', KartenArt.gruendlich);
    final v = TischVorrat.aus([a.id, b.id, c.id, d.id], KartenKatalog([a, b, c, d]));
    // a (2) + b (1) = 3; c (2) sprengt die Grenze von vier, d (1) passt noch.
    expect(v.karten.map((k) => k.id), [a.id, b.id, d.id]);
    expect(v.rest(a.id), 2);
    expect(v.verfuegbar(c.id), isFalse);
  });

  test('Kosmetik und unbekannte Kennungen zählen nicht', () {
    expect(kosmetik.art.spielbar, isFalse);
    final v = TischVorrat.aus(['schlosskeller:ahmet:fremd', kosmetik.id, marke.id], katalog);
    expect(v.karten.map((k) => k.id), [marke.id]);
    expect(TischVorrat.aus([kosmetik.id], katalog).karten, isEmpty);
    expect(TischVorrat.leer().karten, isEmpty);
    expect(TischVorrat.leer().verfuegbar(marke.id), isFalse);
  });

  test('Ausspielen prüft Kennung, Art, Verbrauch und Zeit-Karte je Runde', () {
    final v = TischVorrat.aus([werkzeug.id, zeit.id], katalog);
    expect(() => v.pruefe('schlosskeller:ahmet:fremd', {KartenArt.werkzeug}), throwsA(_kartenFehler('card_unknown')));
    expect(() => v.pruefe(werkzeug.id, {KartenArt.marke}), throwsA(_kartenFehler('card_wrong_moment')));
    v.verbrauche(werkzeug.id);
    expect(() => v.pruefe(werkzeug.id, {KartenArt.werkzeug}), throwsA(_kartenFehler('card_used')));
    expect(v.pruefe(zeit.id, {KartenArt.zeit}, runde: 1).id, zeit.id);
    v.verbrauche(zeit.id, runde: 1);
    expect(v.rest(zeit.id), 1);
    expect(() => v.pruefe(zeit.id, {KartenArt.zeit}, runde: 1), throwsA(_kartenFehler('card_once_per_round')));
    expect(v.pruefe(zeit.id, {KartenArt.zeit}, runde: 2).id, zeit.id);
  });

  test('Katalogprüfung: gute Karte stumm, jede Verletzung mit eigenem Befund', () {
    expect(KartenKatalog([werkzeug, zeit, gruendlich]).pruefe(), isEmpty);
    final faelle = <(String, KartenDef)>[
      ('Kennung nicht', KartenDef(
        id: 'schlosskeller:ahmet', akte: 'schlosskeller', figur: 'ahmet', seltenheit: Seltenheit.gewoehnlich,
        art: KartenArt.werkzeug, titel: 'T', text: 'X', quellen: const [KartenQuelle('rolle')])),
      ('Kennung nicht', KartenDef(
        id: 'mordakte:ahmet:x', akte: 'schlosskeller', figur: 'ahmet', seltenheit: Seltenheit.gewoehnlich,
        art: KartenArt.werkzeug, titel: 'T', text: 'X', quellen: const [KartenQuelle('rolle')])),
      ('Ladungen 0 außerhalb 1..2', _karte('ahmet', 'null', KartenArt.werkzeug, ladungen: 0)),
      ('Ladungen 3 außerhalb 1..2', _karte('ahmet', 'drei', KartenArt.werkzeug, ladungen: 3)),
      ('Zeit-Karte mit Wert 2 statt 3..5', _karte('can', 'z2', KartenArt.zeit, wert: 2)),
      ('Zeit-Karte mit Wert 6 statt 3..5', _karte('can', 'z6', KartenArt.zeit, wert: 6)),
      ('Wert nur bei Zeit-Karten', _karte('ahmet', 'w2', KartenArt.werkzeug, wert: 2)),
      ('Titel oder Text fehlt', KartenDef(
        id: 'schlosskeller:ahmet:leer', akte: 'schlosskeller', figur: 'ahmet', seltenheit: Seltenheit.selten,
        art: KartenArt.marke, titel: ' ', text: 'X', quellen: const [KartenQuelle('rolle')])),
      ('keine Quelle, also nie erhältlich', _karte('ahmet', 'ohne', KartenArt.marke, quellen: const [])),
    ];
    for (final (erwartet, karte) in faelle) {
      expect(_befunde(karte), hasLength(1), reason: erwartet);
      expect(_befunde(karte).single, contains(erwartet));
    }
  });

  test('Belohnung ist für Salz und Spieler deterministisch und je Spieler verschieden', () {
    final pool = KartenKatalog([for (final s in ['a', 'b', 'c', 'd']) _karte('can', 'rolle_$s', KartenArt.werkzeug)]);
    final e = _abend();
    expect(belohnungFuer(e, pool, {}), belohnungFuer(e, pool, {}));
    expect(belohnungFuer(e, pool, {}), hasLength(1));
    final je = {for (var i = 1; i <= 12; i++) belohnungFuer(_abend(spieler: 'p$i'), pool, {}).single};
    expect(je.length, greaterThan(1));
  });

  test('Belohnung bevorzugt unbesessene Karten der eigenen Rolle', () {
    final pool = KartenKatalog([for (final s in ['a', 'b', 'c', 'd']) _karte('can', 'rolle_$s', KartenArt.werkzeug)]);
    final besitz = {'schlosskeller:can:rolle_a', 'schlosskeller:can:rolle_b', 'schlosskeller:can:rolle_c'};
    for (var i = 1; i <= 8; i++) {
      expect(belohnungFuer(_abend(spieler: 'p$i'), pool, besitz), ['schlosskeller:can:rolle_d']);
    }
    final alle = {...besitz, 'schlosskeller:can:rolle_d'};
    expect(belohnungFuer(_abend(), pool, alle).single, isIn(alle), reason: 'Ist alles besessen, gibt es trotzdem eine Karte');
  });

  test('Belohnung: Täterkarte nur bei richtiger Anklage, Meisterkarte nur im Meister-Ende', () {
    final pool = KartenKatalog([rolle, taeter, meister]);
    expect(belohnungFuer(_abend(), pool, {}), isNot(contains(taeter.id)));
    expect(belohnungFuer(_abend(anklageRichtig: true), pool, {}), contains(taeter.id));
    expect(belohnungFuer(_abend(ende: 'ende_teilerfolg'), pool, {}), isNot(contains(meister.id)));
    expect(belohnungFuer(_abend(ende: 'ende_meister'), pool, {}), contains(meister.id));
  });

  test('Belohnung: Abstecherkarten nur für gelungene Fundorte, nie doppelt', () {
    final pool = KartenKatalog([rolle, fund1, fund2, taeter, meister]);
    expect(belohnungFuer(_abend(funde: {'ab_1'}), pool, {}), contains(fund1.id));
    expect(belohnungFuer(_abend(funde: {'ab_1'}), pool, {}), isNot(contains(fund2.id)));
    expect(belohnungFuer(_abend(funde: {'ab_1'}), pool, {fund1.id}), isNot(contains(fund1.id)));
    final voll = belohnungFuer(_abend(funde: {'ab_1', 'ab_2'}, anklageRichtig: true, ende: 'ende_meister'), pool, {});
    expect(voll.toSet(), hasLength(voll.length), reason: 'keine Karte doppelt');
    expect(voll, containsAll([rolle.id, fund1.id, fund2.id, taeter.id, meister.id]));
  });
}
