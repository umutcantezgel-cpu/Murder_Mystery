// Sammelkarten im MetaStore: Startset, Deck-Regeln, Neustart-Persistenz und die
// einmalige Abendbuchung. Der Katalog kommt aus den echten Dateien in content/karten.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mordakte/meta/meta_store.dart';
import 'package:mordakte_core/runden.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Alle `content/karten/*.json` ohne Schemata, in der Reihenfolge des Laders.
KartenKatalog echterKatalog() {
  final dateien = Directory('content/karten').listSync().whereType<File>()
      .where((f) => f.path.endsWith('.json') && !f.path.endsWith('.schema.json'))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));
  return KartenKatalog.ausDateien([for (final f in dateien) jsonDecode(f.readAsStringSync()) as Map<String, Object?>]);
}

/// Die fünf Karten mit Quelle `start` (koefferchen, zweiter_blick, presseausweis, streifenplan, notfalltasche).
const start = [
  'mordakte:forensic:koefferchen',
  'mordakte:profiler:zweiter_blick',
  'mordakte:journalist:presseausweis',
  'mordakte:excop:streifenplan',
  'mordakte:medic:notfalltasche',
];
const stirnlampe = 'schlosskeller:tim:stirnlampe'; // Werkzeug, 1 Ladung
const zoomfinger = 'schlosskeller:johanna:zoomfinger'; // Gründlich, 2 Ladungen
const ertappt = 'schlosskeller:olli:ertappt'; // Werkzeug, 2 Ladungen

/// Gerät mit gespeichertem Kartenkonto: [besitz] je Kennung mit Anzahl, [deck] in Reihenfolge.
Future<MetaStore> mitKonto({Map<String, int> besitz = const {}, List<String> deck = const []}) {
  SharedPreferences.setMockInitialValues({
    'mordakte.karten': jsonEncode({
      'v': 1,
      'besitz': {for (final e in besitz.entries) e.key: {'n': e.value, 'neu': false}},
      'deck': deck,
    }),
  });
  return MetaStore.load();
}

/// Besitz als vergleichbare Werte (Anzahl, NEU-Marke).
Map<String, (int, bool)> besitzWerte(MetaStore m) => {for (final e in m.besitz.entries) e.key: (e.value.n, e.value.neu)};

/// Forensiker-Abend: Rollen-Karte aus abdruck, koefferchen und lupe.
const rollenAbend = AbendErgebnis(
  akte: 'schlosskeller',
  salz: 'salz-1',
  spielerId: 'me',
  rolle: 'klasse:forensic',
  pfad: 'ahmet',
  anklageRichtig: false,
  ende: 'ende_teilerfolg',
);

void main() {
  late KartenKatalog katalog;
  setUpAll(() => katalog = echterKatalog());

  test('Startset: nur Karten mit Quelle start, Deck gültig, einmal vergeben', () {
    final m = MetaStore.memory();
    expect(m.kartenBereit, isFalse);
    m.initKarten(katalog);
    expect({for (final k in katalog.alle) if (k.hatQuelle('start')) k.id}, start.toSet());
    expect(m.besitz.keys.toSet(), start.toSet());
    expect(m.besitz.values.every((b) => b.n == 1 && !b.neu), isTrue, reason: 'Startkarten sind nicht NEU');
    expect(m.neueKarten, isEmpty);
    expect(m.deck, hasLength(3));
    expect(m.deck, ['mordakte:forensic:koefferchen', 'mordakte:profiler:zweiter_blick', 'mordakte:journalist:presseausweis']);
    expect(TischVorrat.aus(m.deck, katalog).karten.map((k) => k.id), m.deck, reason: 'das Deck ist ein gültiger Tischvorrat');
    m.initKarten(katalog);
    expect(m.besitz.keys.toSet(), start.toSet(), reason: 'ein zweiter Aufruf vergibt kein zweites Startset');
    expect(m.deck, hasLength(3));
  });

  test('setzeDeck verwirft Unbekanntes und Doppelte und wendet die Art- und Ladungsregel an', () async {
    final m = await mitKonto(besitz: {for (final id in start) id: 1, stirnlampe: 1, zoomfinger: 1, ertappt: 1});
    m.setzeDeck(['x:unbekannt:y', start[0], start[0], start[1], start[3], start[4]], katalog: katalog);
    expect(m.deck, [start[0], start[1], start[3]], reason: 'Unbekannt und Doppelt fallen weg, Zeit-Karte passt nicht mehr');

    m.setzeDeck([start[0], stirnlampe, start[1]], katalog: katalog);
    expect(m.deck, [start[0], start[1]], reason: 'zweite Werkzeug-Karte verdrängt keine, sie fällt weg');

    m.setzeDeck([ertappt, zoomfinger, start[2]], katalog: katalog);
    expect(m.deck, [ertappt, zoomfinger], reason: 'fünf Ladungen sind zu viel, die dritte Karte fällt weg');
    expect(m.deck.fold<int>(0, (s, id) => s + katalog[id]!.ladungen), lessThanOrEqualTo(TischVorrat.maxLadungen));

    m.setzeDeck(start, katalog: katalog);
    expect(m.deck, hasLength(TischVorrat.maxKarten));
    m.setzeDeck(start);
    expect(m.deck, start.take(3), reason: 'ohne Katalog greift nur die Obergrenze von drei');
  });

  test('setzeDeck ohne Kartenkonto bleibt wirkungslos', () {
    final m = MetaStore.memory();
    m.setzeDeck(start, katalog: katalog);
    expect(m.deck, isEmpty);
    expect(m.kartenBereit, isFalse);
  });

  test('Persistenz: Besitz, NEU, Deck, Abende und Akten überleben einen Neustart', () async {
    SharedPreferences.setMockInitialValues({});
    final m = await MetaStore.load();
    m.initKarten(katalog);
    m.setzeDeck([start[1], start[0]], katalog: katalog);
    final b = m.verbucheAbend(abendId: 'abend-a', ergebnis: rollenAbend, katalog: katalog, punkte: 4);
    expect(b.neu, hasLength(1));

    final prefs = await SharedPreferences.getInstance();
    final werte = {for (final k in prefs.getKeys()) k: prefs.get(k)!};
    SharedPreferences.setMockInitialValues(werte);
    final n = await MetaStore.load();
    expect(n.kartenBereit, isTrue);
    expect(n.deck, [start[1], start[0]]);
    expect(besitzWerte(n), besitzWerte(m));
    expect(n.neueKarten, m.neueKarten);
    expect(n.xp, m.xp);
    expect(n.gebuchteAbende, ['abend-a']);
    expect(n.akten['schlosskeller']?.gespielt, 1);
    expect(n.akten['schlosskeller']?.bestPunkte, 4);

    n.initKarten(katalog);
    expect(besitzWerte(n), besitzWerte(m), reason: 'nach dem Neustart kein zweites Startset');
    final nochmal = n.verbucheAbend(abendId: 'abend-a', ergebnis: rollenAbend, katalog: katalog);
    expect(nochmal.schonVerbucht, isTrue);
    expect(nochmal.karten, isEmpty, reason: 'Zwischenspeicher ist nach dem Neustart leer');
    expect(n.xp, m.xp, reason: 'derselbe Abend wird nach dem Neustart nicht erneut gutgeschrieben');
  });

  test('verbucheAbend: XP nach Ende, NEU-Marke, Doppelte zählen hoch', () {
    final m = MetaStore.memory();
    final b1 = m.verbucheAbend(abendId: 'a1', ergebnis: rollenAbend, katalog: katalog);
    expect(b1.xpVorher, 0);
    expect(b1.xp, 200, reason: 'ende_teilerfolg bringt 200 XP');
    expect(m.xp, 200);
    expect(b1.neu, b1.karten);
    expect(m.neueKarten, b1.neu.toSet());
    m.markiereGesehen(b1.neu);
    expect(m.neueKarten, isEmpty, reason: 'gesehen nimmt die NEU-Marke');

    // Die Klassen-Karten: drei Rollen-Karten, koefferchen ist schon im Startset.
    final klasse = {'mordakte:forensic:abdruck', 'mordakte:forensic:koefferchen', 'mordakte:forensic:lupe'};
    final b2 = m.verbucheAbend(abendId: 'a2', ergebnis: rollenAbend, katalog: katalog);
    final b3 = m.verbucheAbend(abendId: 'a3', ergebnis: rollenAbend, katalog: katalog);
    final b4 = m.verbucheAbend(abendId: 'a4', ergebnis: rollenAbend, katalog: katalog);
    expect(b2.neu, hasLength(1));
    expect(b3.neu, isEmpty, reason: 'alle drei Rollen-Karten sind nach zwei Abenden im Besitz');
    expect(b3.karten, hasLength(1));
    expect(m.kartenAnzahl(b3.karten.single), greaterThanOrEqualTo(2));
    expect(b4.neu, isEmpty);
    expect(klasse.fold<int>(0, (s, id) => s + m.kartenAnzahl(id)), 5, reason: 'Startexemplar plus vier Abende');
    expect(m.xp, 800);
  });

  test('verbucheAbend ist idempotent für dieselbe Abend-Kennung', () {
    final m = MetaStore.memory();
    final erst = m.verbucheAbend(abendId: 'doppelt', ergebnis: rollenAbend, katalog: katalog);
    final xp = m.xp;
    final besitz = besitzWerte(m);
    final zweit = m.verbucheAbend(abendId: 'doppelt', ergebnis: rollenAbend, katalog: katalog);
    expect(zweit.schonVerbucht, isTrue);
    expect(zweit.karten, erst.karten, reason: 'liefert die zuerst berechnete Belohnung');
    expect(m.xp, xp);
    expect(besitzWerte(m), besitz);
    expect(m.gebuchteAbende, ['doppelt']);
  });

  test('Doppelbuchungssperre merkt höchstens 50 Abend-Kennungen', () {
    final m = MetaStore.memory();
    for (var i = 0; i < 55; i++) {
      m.verbucheAbend(abendId: 'abend-$i', ergebnis: rollenAbend, katalog: katalog);
    }
    expect(m.gebuchteAbende, hasLength(50));
    expect(m.gebuchteAbende.first, 'abend-5');
    expect(m.gebuchteAbende.last, 'abend-54');
    expect(m.xp, 55 * 200);
  });
}
