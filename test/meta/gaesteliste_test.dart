// M5: Gästeliste je Akte im MetaStore (Name → Figur, Personenzahl). Sie übersteht einen
// Neustart, eine Figur gehört höchstens einem Gast, und sie liefert die Vorbelegung der
// Einrichtung (Figur → Name) und den Wunsch je Gast für die Online-Zuteilung (Name → Figur).
import 'package:flutter_test/flutter_test.dart';
import 'package:mordakte/meta/meta_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  const liste = GaesteListe(personen: 6, gaeste: [Gast('Ayla', 'fatma'), Gast(' Bo ', 'detective'), Gast('Cem'), Gast('', 'olli')]);

  test('Vorbelegung: Figur → Name nur mit Namen und Figur, Namen ohne Leerraum; Name → Figur umgekehrt', () {
    expect(liste.namenJeFigur, {'fatma': 'Ayla', 'detective': 'Bo'});
    expect(liste.figurJeName, {'Ayla': 'fatma', 'Bo': 'detective'});
    expect(const GaesteListe().leer, isTrue);
    expect(const GaesteListe(gaeste: [Gast('')]).leer, isTrue);
    expect(const GaesteListe(personen: 4).leer, isFalse);
  });

  test('eine Figur gehört höchstens einem Gast: Wer sie wählt, nimmt sie dem anderen', () {
    final neu = liste.mitGast(2, const Gast('Cem', 'fatma'));
    expect([for (final g in neu.gaeste) g.figur], [null, 'detective', 'fatma', 'olli']);
    expect(neu.plus(const Gast('Dana')).ohne(0).gaeste.map((g) => g.name), [' Bo ', 'Cem', '', 'Dana']);
    expect(neu.mitPersonen(null).personen, isNull);
  });

  test('JSON hin und zurück; Unlesbares ergibt eine leere Liste', () {
    expect(GaesteListe.ausJson(liste.toJson()), liste);
    expect(GaesteListe.ausJson('kaputt'), const GaesteListe());
    expect(GaesteListe.ausJson({'gaeste': [42, {'name': 'Eda', 'figur': 7}]}).gaeste, [const Gast('Eda')]);
  });

  test('MetaStore: je Akte eine Liste, sie übersteht einen Neustart, leer löscht sie', () async {
    SharedPreferences.setMockInitialValues({});
    final m = await MetaStore.load();
    var gemeldet = 0;
    m.addListener(() => gemeldet++);
    expect(m.gaesteliste('schlosskeller'), const GaesteListe());
    m.setzeGaesteliste('schlosskeller', liste);
    m.setzeGaesteliste('schlosskeller', liste);
    expect(gemeldet, 1, reason: 'Dieselbe Liste noch einmal ändert nichts');
    expect(m.gaesteliste('gewoelbe'), const GaesteListe());

    final prefs = await SharedPreferences.getInstance();
    SharedPreferences.setMockInitialValues({for (final k in prefs.getKeys()) k: prefs.get(k)!});
    final n = await MetaStore.load();
    expect(n.gaesteliste('schlosskeller'), liste);
    n.setzeGaesteliste('schlosskeller', const GaesteListe());
    expect(n.gaesteliste('schlosskeller').leer, isTrue);

    final prefs2 = await SharedPreferences.getInstance();
    SharedPreferences.setMockInitialValues({for (final k in prefs2.getKeys()) k: prefs2.get(k)!});
    expect((await MetaStore.load()).gaesteliste('schlosskeller'), const GaesteListe());
  });
}
