// F-09 (Vorzug F2-ORCH-06): Besetzung 4–20, Ersatzpartner, NPC, Lösbarkeit je Zahl.
import 'package:mordakte_core/mordakte_core.dart';
import 'package:test/test.dart';

import 'kanon_hilfe.dart';

void main() {
  late Besetzung b;
  late Ermittlung e;
  setUpAll(() {
    b = Besetzung(kanon);
    e = Ermittlung(kanon);
  });

  test('Plätze 1 bis n sind besetzt, die Kernrollen immer', () {
    for (var n = 4; n <= 20; n++) {
      final besetzt = b.besetzt(n);
      expect(besetzt, b.reihenfolge.take(n).toList());
      expect(besetzt, containsAll(kanon.kernverdaechtige));
      expect(b.npc(n), hasLength(20 - n));
      expect({...besetzt, ...b.npc(n)}, hasLength(20));
    }
    expect(() => b.besetzt(3), throwsRangeError);
    expect(() => b.besetzt(21), throwsRangeError);
  });

  test('jede Nebenrolle hat Ersatzpartner, nur aus bekannten Figuren und nie sich selbst', () {
    final figuren = {for (final f in kanon.figuren) f['id'] as String};
    for (final r in b.reihenfolge.skip(4)) {
      expect(b.ersatz[r], isNotEmpty, reason: r);
      for (final x in b.ersatz[r]!) {
        expect(figuren, contains(x));
        expect(x, isNot(r));
      }
    }
  });

  test('Partner: besetzt bleibt, sonst erster besetzter Ersatz, sonst Detektiv, nie der Sprecher (Modell legacy, Gewölbe)', () {
    final g = Besetzung(ladeKanon('gewoelbe'));
    expect(g.modell, GespraechsModell.legacy);
    for (var n = 4; n <= 20; n++) {
      for (final wunsch in g.reihenfolge) {
        for (final sprecher in g.besetzt(n)) {
          final p = g.partner(wunsch, n, sprecher: sprecher);
          expect(p, isNot(sprecher));
          expect(g.istBesetzt(p, n), isTrue, reason: '$wunsch bei $n Rollen → $p');
          if (g.istBesetzt(wunsch, n) && wunsch != sprecher) expect(p, wunsch);
        }
      }
    }
    // Ohne Ersatz springt der Detektiv ein; ein besetzter Wunsch bleibt.
    expect(g.partner('adnan', 4, sprecher: 'adnan'), Besetzung.detektiv);
    expect(g.partner(Besetzung.detektiv, 4, sprecher: 'adnan'), Besetzung.detektiv);
    expect(g.partner('adnan', 4, sprecher: 'rojda'), 'adnan');
  });

  test('Partner im Modell befragung: besetzt bleibt, sonst erster besetzter Ersatz, sonst eine Rolle, nie der Detektiv', () {
    expect(b.modell, GespraechsModell.befragung);
    for (var n = 4; n <= 20; n++) {
      for (final wunsch in [...b.reihenfolge, Besetzung.detektiv]) {
        for (final sprecher in b.besetzt(n)) {
          final p = b.partner(wunsch, n, sprecher: sprecher);
          expect(p, isNot(sprecher));
          expect(p, isNot(Besetzung.detektiv), reason: '$wunsch bei $n Rollen');
          expect(b.besetzt(n), contains(p), reason: '$wunsch bei $n Rollen → $p');
          if (b.besetzt(n).contains(wunsch) && wunsch != sprecher) expect(p, wunsch);
        }
      }
    }
    expect(b.partner('tugba', 4, sprecher: 'can'), 'ahmet');
    expect(b.partner('tugba', 11, sprecher: 'can'), 'baran');
    expect(b.partner('ahmet', 4, sprecher: 'ahmet'), 'fatma');
  });

  test('Begründungsketten brauchen kein Wissen, das bei kleiner Besetzung fehlt', () {
    // Pflichtgespräch-Beobachtungen unbesetzter Gäste kommen als NPC-Karte (W1);
    // verborgenes Wissen steht nie in einer Kette.
    for (final x in e.entscheidungen) {
      for (final p in kanon.pfade) {
        for (final k in x.begruendungFuer(p)!.kette.where((k) => k.startsWith('beobachtung:'))) {
          final bj = e.beobachtungJson(k.split(':')[1])!;
          expect(bj['kanal'], isNot('verborgen'), reason: '${x.id} $k');
        }
      }
    }
  });

  test('jede Zahl von 4 bis 20 ist lösbar: bestes Spiel endet als Meister-Detektiv', () {
    for (var n = 4; n <= 20; n++) {
      for (final p in kanon.pfade) {
        final s = Spiel(kanon, ermittlung: e)
          ..einrichten(Einstellungen(rollen: n, detektiv: 'm', code: FallCode.fuerPfad(p, kanon.pfade)));
        while (s.phase != PartyPhase.anklage) {
          if (s.phase == PartyPhase.entscheidungen) {
            for (final x in e.runde(s.runde)) {
              s.waehle(x.id, x.richtig[p]!);
            }
          }
          if (s.phase == PartyPhase.gruppenwahl) s.abstimmen(kooperativ: n - 1, taeterSabotiert: false);
          s.weiter();
        }
        expect(s.restmenge(), {p});
        s.anklagen(p);
        expect(s.ende.id, 'ende_meister', reason: '$n Rollen, Pfad $p');
      }
    }
  });
}
