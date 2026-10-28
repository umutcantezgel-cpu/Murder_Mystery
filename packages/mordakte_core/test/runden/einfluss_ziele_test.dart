// Persönliche Ziele (Finale §3.9): Bedingungssprache, Live-Stand „offen/erreicht/verloren“, Bewertung
// nach der Anklage, Proben „erreichbar und verfehlbar“ und die gleiche Form der vier Kernfiguren.
import 'package:mordakte_core/runden.dart';
import 'package:test/test.dart';

import 'einfluss_hilfe.dart';

EinflussRegeln get _r => einflussRegeln;
final _ziele = EinflussZiele.aus(einflussRegeln);

EinflussZiel _stern(String figur, int nr) => _ziele.von(figur)[nr - 1];

EinflussZug _z(String rolle, ZugArt art, [String? ziel]) => EinflussZug(rolle, art, ziel: ziel);

/// Protokoll bei voller Besetzung; [zuege] je Runde (fehlende Rollen haben abgewartet).
NachtProtokoll _p({
  Map<int, List<EinflussZug>> zuege = const {},
  int runden = 0,
  Set<String> sichtbar = const {},
  Map<String, int> ertappt = const {},
  int zusammenhalt = 0,
  int spuk = 0,
  String? angeklagt,
  int? rest,
}) =>
    NachtProtokoll(
      besetzt: _r.figuren,
      zuege: {for (var r = 1; r <= runden; r++) r: {for (final z in zuege[r] ?? const <EinflussZug>[]) z.rolle: z}},
      sichtbar: sichtbar,
      ertappt: ertappt,
      zusammenhalt: zusammenhalt,
      spuk: spuk,
      angeklagt: angeklagt,
      rest: rest,
    );

ZielStand _stand(String figur, int nr, NachtProtokoll p) => _ziele.stand(_stern(figur, nr), p);

void main() {
  test('Alle 40 Sterne sind lesbar, erreichbar und verfehlbar', () {
    expect(_ziele.je.keys.toSet(), _r.figuren.toSet());
    for (final f in _r.figuren) {
      final s = _ziele.von(f);
      expect([for (final z in s) z.nr], [1, 2], reason: f);
      expect([for (final z in s) z.schluessel], ['einfluss.ziel.$f.1', 'einfluss.ziel.$f.2']);
      for (final z in s) {
        final probe = zielProbe(z, _r);
        expect([probe.erreichbar, probe.verfehlbar], [true, true], reason: '${z.figur}.${z.id}');
        expect(zielForm(zielBedingung(z.bedingung.toJson(), _r)), zielForm(z.bedingung), reason: 'toJson liest sich zurück');
      }
    }
  });

  test('Die vier Kernfiguren haben je Stern dieselbe Form, andere Figuren nicht zwingend', () {
    for (var nr = 1; nr <= 2; nr++) {
      expect({for (final k in _r.kern) zielForm(_stern(k, nr).bedingung)}, hasLength(1), reason: 'Stern $nr');
    }
    expect(zielForm(_stern('ahmet', 1).bedingung), 'alle{hoechstens(bekannt:_,0)}');
    expect(zielForm(_stern('ahmet', 2).bedingung), 'nicht(gleich(angeklagt,ich))');
    expect(zielForm(_stern('leyla', 2).bedingung), 'nicht(gleich(angeklagt,_))');
  });

  group('Live-Stand', () {
    test('Kern I: geheim bis zur Anklage – sichtbar heißt sofort verloren', () {
      expect(_stand('ahmet', 1, _p()), ZielStand.offen);
      expect(_stand('ahmet', 1, _p(runden: 2, sichtbar: {'f_nd_ahmet_quittung'})), ZielStand.verloren);
      expect(_stand('ahmet', 1, _p(runden: 3, angeklagt: 'can', rest: 5)), ZielStand.erreicht);
      expect(_stand('can', 1, _p(runden: 3, sichtbar: {'f_nd_can_zeynep'}, angeklagt: 'can', rest: 5)), ZielStand.verloren);
    });

    test('Kern II und Loyale: offen bis zur Anklage', () {
      expect(_stand('fatma', 2, _p(runden: 3)), ZielStand.offen);
      final p = _p(runden: 3, angeklagt: 'fatma', rest: 0);
      expect(_stand('fatma', 2, p), ZielStand.verloren);
      expect(_stand('ahmet', 2, p), ZielStand.erreicht);
      expect(_stand('emine', 2, p), ZielStand.verloren);
      expect(_stand('kaan', 2, p), ZielStand.erreicht);
    });

    test('Leyla deckt Ahmet zweimal: erreicht, sobald es feststeht; verloren, wenn es nicht mehr geht', () {
      final d = _z('leyla', ZugArt.decken, 'ahmet');
      expect(_stand('leyla', 1, _p(runden: 1, zuege: {1: [d]})), ZielStand.offen);
      expect(_stand('leyla', 1, _p(runden: 2, zuege: {1: [d], 2: [d]})), ZielStand.erreicht);
      expect(_stand('leyla', 1, _p(runden: 2, zuege: {1: [d]})), ZielStand.offen);
      expect(_stand('leyla', 1, _p(runden: 2)), ZielStand.verloren);
    });

    test('Spätestens in Runde zwei auspacken; nie auspacken; jede Runde helfen', () {
      expect(_stand('meryem', 1, _p()), ZielStand.offen);
      expect(_stand('meryem', 1, _p(runden: 1, zuege: {1: [_z('meryem', ZugArt.auspacken)]})), ZielStand.erreicht);
      expect(_stand('meryem', 1, _p(runden: 1)), ZielStand.offen);
      expect(_stand('meryem', 1, _p(runden: 2)), ZielStand.verloren);
      expect(_stand('dilara', 1, _p(runden: 3, zuege: {3: [_z('dilara', ZugArt.auspacken)]})), ZielStand.verloren);
      expect(_stand('emine', 1, _p(runden: 1, zuege: {1: [_z('emine', ZugArt.auspacken)]})), ZielStand.verloren);
      expect(_stand('emine', 1, _p(runden: 2)), ZielStand.offen);
      expect(_stand('emine', 1, _p(runden: 3)), ZielStand.erreicht, reason: 'nach drei Runden kann niemand mehr auspacken');
      final h = _z('tugba', ZugArt.helfen);
      expect(_stand('tugba', 1, _p(runden: 2, zuege: {1: [h], 2: [h]})), ZielStand.offen);
      expect(_stand('tugba', 1, _p(runden: 2, zuege: {1: [h], 2: [_z('tugba', ZugArt.ablenken)]})), ZielStand.verloren);
      expect(_stand('tugba', 1, _p(runden: 3, zuege: {1: [h], 2: [h], 3: [h]})), ZielStand.erreicht);
    });

    test('Ertappt, Gerüchte, Rest: erst am Ende sicher erreicht, vorher sofort verloren', () {
      // „Nie ertappt“ als Fixture (kein Stern der Akte nutzt das Atom nach der Abstimmung, E-048).
      final nieErtappt = EinflussZiel('tim', 2, 'nie_ertappt', zielBedingung({'hoechstens': ['ertappt:ich', 0]}, _r));
      expect(_ziele.stand(nieErtappt, _p(runden: 3)), ZielStand.offen);
      expect(_ziele.stand(nieErtappt, _p(runden: 1, ertappt: {'tim': 1})), ZielStand.verloren);
      expect(_ziele.stand(nieErtappt, _p(runden: 3, angeklagt: 'olli', rest: 3)), ZielStand.erreicht);
      expect(_stand('enes', 1, _p(runden: 1, zuege: {1: [_z('can', ZugArt.zeigen, 'enes')]})), ZielStand.verloren);
      expect(_stand('enes', 1, _p(runden: 2)), ZielStand.offen);
      expect(_stand('serkan', 2, _p(runden: 2, rest: 50)), ZielStand.offen);
      expect(_stand('serkan', 2, _p(runden: 3, rest: 40)), ZielStand.erreicht);
      expect(_stand('serkan', 2, _p(runden: 3, rest: 39)), ZielStand.verloren);
    });

    test('Nie ablenken: verloren mit dem ersten Ablenken, erreicht nach drei Runden ohne', () {
      expect(_stand('tim', 2, _p(runden: 2)), ZielStand.offen);
      expect(_stand('tim', 2, _p(runden: 1, zuege: {1: [_z('tim', ZugArt.ablenken)]})), ZielStand.verloren);
      expect(_stand('tim', 2, _p(runden: 3, zuege: {1: [_z('tim', ZugArt.helfen)], 2: [_z('tim', ZugArt.zeigen, 'enes')]})), ZielStand.erreicht);
    });

    test('Leisten steigen nur: Grenzen gelten sofort, Mindeststände, solange sie erreichbar sind', () {
      expect(_stand('selin', 1, _p(runden: 1, spuk: 3)), ZielStand.verloren);
      expect(_stand('selin', 1, _p(runden: 2, spuk: 2)), ZielStand.offen);
      expect(_stand('meryem', 2, _p(runden: 2, zusammenhalt: 1)), ZielStand.verloren, reason: 'höchstens +2 in der letzten Runde');
      expect(_stand('meryem', 2, _p(runden: 2, zusammenhalt: 2)), ZielStand.offen);
      expect(_stand('meryem', 2, _p(runden: 1, zusammenhalt: 4)), ZielStand.erreicht);
    });

    test('Eine von zwei Möglichkeiten genügt; Ziele auf Figuren zählen nur die eigenen Züge', () {
      expect(_stand('murat', 2, _p(runden: 1, sichtbar: {'f_nd_can_zeynep'})), ZielStand.erreicht);
      expect(_stand('murat', 2, _p(runden: 3, angeklagt: 'can', rest: 0)), ZielStand.verloren);
      expect(_stand('aylin', 2, _p(runden: 1, zuege: {1: [_z('aylin', ZugArt.zeigen, 'ahmet')]})), ZielStand.verloren);
      expect(_stand('aylin', 2, _p(runden: 1, zuege: {1: [_z('baran', ZugArt.zeigen, 'ahmet')]})), ZielStand.offen);
      expect(_stand('johanna', 2, _p(runden: 1, zuege: {1: [_z('johanna', ZugArt.lauschen, 'ahmet')]})), ZielStand.erreicht);
    });

    test('Sterne nach der Anklage, auch aus einem echten Stand der Schicht', () {
      final s = EinflussStand(_r, besetzt: _r.figuren.take(8).toList()); // … johanna
      for (var runde = 1; runde <= 3; runde++) {
        s.setze(runde, _z('leyla', ZugArt.decken, 'ahmet'));
        s.setze(runde, _z('johanna', runde == 1 ? ZugArt.lauschen : ZugArt.helfen, runde == 1 ? 'ahmet' : null));
        s.setze(runde, _z('tim', ZugArt.helfen));
        s.auswerten(runde);
      }
      final p = s.protokoll(sichtbar: {'f_kurzschluss'}, angeklagt: 'olli', rest: 4, aufloesung: 'olli');
      expect(p.rundenFertig, 3);
      expect(p.fertig, isTrue);
      expect(_ziele.sterne('leyla', p), 2);
      expect(_ziele.sterne('johanna', p), 2);
      expect(_ziele.sterne('tim', p), 1, reason: 'Kurzschluss sichtbar, nie abgelenkt');
      expect(_ziele.sterne('olli', p), 1, reason: 'Türschaden geheim, aber angeklagt');
      final alle = _ziele.alleSterne(p);
      expect(alle, {'ahmet': 2, 'fatma': 2, 'olli': 1, 'can': 2, 'leyla': 2, 'emine': 2, 'tim': 1, 'johanna': 2});
      expect(auszeichnen(p, _r, sterne: alle).stern, 'ahmet', reason: 'Gleichstand bei sechs Punkten: Besetzungsreihenfolge');
    });
  });

  test('Lesefehler: unbekannte Atome, Figuren, Fakten, Formen', () {
    void fehler(Object? j, String teil) =>
        expect(() => zielBedingung(j, _r), throwsA(isA<FormatException>().having((e) => e.message, 'message', contains(teil))), reason: '$j');
    fehler({'mind': ['wurfglueck', 1]}, 'unbekanntes Atom');
    fehler({'mind': ['bekannt:f_gibt_es_nicht', 1]}, 'unbekannter Fakt');
    fehler({'mind': ['zieleAuf:decken:niemand', 1]}, 'unbekannte Figur');
    fehler({'mind': ['zieleAuf:helfen:ahmet', 1]}, 'hat kein Ziel');
    fehler({'mind': ['zuege:schummeln', 1]}, 'unbekannte Zugart');
    fehler({'mind': ['angeklagt', 1]}, 'keine Zahl');
    fehler({'mind': ['spuk', 'drei']}, 'ganze Zahl');
    fehler({'mind': ['spuk']}, 'zwei Einträge');
    fehler({'gleich': ['angeklagt', 2]}, 'nur mit Figuren');
    fehler({'gleich': ['spuk', 'ahmet']}, 'nicht mit einer Figur');
    fehler({'gleich': ['spuk', 'angeklagt']}, 'gemischt');
    fehler({'alle': <Object?>[]}, 'nicht leere Liste');
    fehler({'oder': <Object?>[]}, 'unbekannte Verknüpfung');
    fehler({'nicht': {'mind': ['spuk', 1]}, 'mind': ['rest', 1]}, 'genau ein Schlüssel');
    fehler({'mind': ['bekannt:f_nd_fatma:x', 1]}, 'falsche Form');
    expect(zielBedingung({'gleich': ['bekannt:f_nd_fatma', true]}, _r).toJson(), {'gleich': ['bekannt:f_nd_fatma', 1]});
  });
}
