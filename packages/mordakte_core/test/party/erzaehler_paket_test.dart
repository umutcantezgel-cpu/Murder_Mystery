// A-052 (M2.1-Vertrag): Das Erzählerpaket kennt Tisch-Stichpunkte, Befragungen mit ihren Antworten und die
// NPC-Bausteine der Runde, nie Pfad, Salz, Fall-Code, Qualität, Bonus-Katalog, verbirgt, Tatwissen, Tarnung,
// Sabotage oder Ziele. Es ist für jede Rollenzahl und Runde in allen Pfaden gleich.
import 'dart:convert';

import 'package:mordakte_core/mordakte_core.dart';
import 'package:mordakte_core/runden.dart';
import 'package:test/test.dart';

import 'kanon_hilfe.dart';

Texte _laden() => Texte(kanon, Textsammlung.lade((p) => leseJson('$repoWurzel/content/party/schlosskeller/$p')));

final _texte = _laden();
final _plan = Befragungsplan(_texte);

Iterable<String> _schluessel(Object? wert) sync* {
  if (wert is Map) {
    for (final e in wert.entries) {
      yield e.key.toString();
      yield* _schluessel(e.value);
    }
  } else if (wert is List) {
    for (final e in wert) {
      yield* _schluessel(e);
    }
  }
}

/// Texte, die nie im Paket stehen dürfen: alles Verborgene aller Rollen in allen Pfaden, Tatwissen und Tarnung,
/// Sabotagen, Ziele, Wahrheiten der Lügen, verborgene Beobachtungen und der ganze Bonus-Katalog.
Set<String> _verboten() {
  final t = _texte;
  final aus = <String>{
    for (final x in t.sammlung.taeter.values) ...[x.tarnung, x.ziel],
    for (final w in t.sammlung.wahlen.values) ?w.sabotage,
    for (final g in t.sammlung.gespraeche) g.ziel,
    for (final d in t.sammlung.dossiers.values) d.ziel,
    for (final h in kanon.bonusJson['hinweise'] as List) (h as Map)['text'] as String,
    for (final b in kanon.beobachtungen)
      if (b['kanal'] != 'pflichtgespraech') ...[b['text'] as String, ?b['duText'] as String?],
    for (final f in kanon.figuren)
      for (final l in (f['luegen'] as List? ?? const [])) ...[(l as Map)['wahrheit'] as String, ?l['duWahrheit'] as String?],
  };
  for (final r in kanon.figuren.map((f) => f['id'] as String)) {
    for (final p in kanon.pfade) {
      final d = t.dossier(r, p, 20);
      aus.addAll([for (final z in [...d.verbirgt, ...d.tatwissen]) z.text]);
    }
  }
  // Kanon-Texte, die auch öffentlich sind (etwa eine Lüge, die als Behauptung am Tisch steht), bleiben erlaubt.
  final erlaubt = {
    for (final b in t.sammlung.befragungen.values) ...befragungsAntwort(t, b),
    for (final k in t.sammlung.bausteine.keys) if (k.startsWith('npc.')) t.sammlung.bausteine[k]!,
  };
  return aus.difference(erlaubt)..removeWhere((x) => x.trim().length < 12);
}

void main() {
  const verboteneSchluessel = {
    'pfad', 'pfade', 'salz', 'seed', 'fallCode', 'code', 'richtig', 'qualitaet', 'qualitaeten', 'taeter', 'tarnung',
    'tatwissen', 'verbirgt', 'weiss', 'sabotage', 'ziel', 'hinweis', 'hinweise', 'bonus', 'preisgabe', 'quelle',
  };
  final verboten = _verboten();

  test('Verbotene Texte sind nicht leer (sonst prüft der Test nichts)', () {
    expect(verboten.length, greaterThan(50));
  });

  test('4–20 Rollen, Runden 1 bis 3: nur erlaubte Schlüssel, keine verborgenen Texte, pfadgleich', () {
    final zweiter = Befragungsplan(_laden());
    for (var n = 4; n <= 20; n++) {
      for (var r = 1; r <= 3; r++) {
        final paket = erzaehlerPaket(_texte, _plan, n: n, runde: r);
        final j = jsonEncode(paket.toJson());
        expect(_schluessel(paket.toJson()).toSet().intersection(verboteneSchluessel), isEmpty, reason: '$n / $r');
        for (final v in verboten) {
          expect(j.contains(v), isFalse, reason: '$n Rollen, Runde $r: „$v“');
        }
        // Gleich gerechnet mit einer frischen Textsammlung: Das Paket hängt nur an Rollenzahl und Runde.
        expect(jsonEncode(erzaehlerPaket(zweiter.texte, zweiter, n: n, runde: r).toJson()), j, reason: '$n / $r');
      }
    }
  });

  test('Inhalt: alle Tischgespräche, alle festen und freien Befragungen, NPC-Bausteine der Runde', () {
    for (final n in [4, 9, 20]) {
      for (var r = 1; r <= 3; r++) {
        final paket = erzaehlerPaket(_texte, _plan, n: n, runde: r);
        final besetzt = _texte.besetzung.besetzt(n);
        final br = _plan.fuer(n, r);
        expect(paket.tisch.map((t) => t.sprecher), besetzt);
        final plan = _texte.gespraechsplan(n);
        for (final t in paket.tisch) {
          final g = _texte.sammlung.gespraeche.singleWhere((g) => g.rolle == t.sprecher && g.runde == r);
          expect([t.partner, t.thema, t.stichpunkte], [plan[g.id], g.thema, g.stichpunkte]);
        }
        expect(paket.befragungen.map((b) => b.rolle), besetzt);
        expect([for (final b in paket.befragungen) if (b.pflicht) b.rolle], br.pflicht);
        expect(paket.freiWahlen, br.freiWahlen);
        for (final b in paket.befragungen) {
          expect(b.antwort, botAntwort(_texte, br.text(b.rolle)));
          expect(b.fragen, br.text(b.rolle).fragen);
        }
        expect(paket.npc.map((x) => x.kennung), Erzaehler(kanon).npcWissen(r, besetzt: (f) => _texte.besetzung.istBesetzt(f, n)));
        for (final x in paket.npc) {
          expect(x.text, _texte.baustein(x.kennung));
        }
      }
    }
    // Bei 4 Rollen spricht der Erzähler in Runde 2 für Lejla, Marek und Hana.
    expect(erzaehlerPaket(_texte, _plan, n: 4, runde: 2).npc.map((x) => x.figur).toSet(), {'leyla', 'murat', 'meryem'});
    expect(() => erzaehlerPaket(_texte, _plan, n: 4, runde: 4), throwsArgumentError);
  });

  test('Rot-Probe: ein Tatwissen-Satz im Paket würde gefunden', () {
    final satz = verboten.firstWhere((v) => _texte.sammlung.taeter.values.any((x) => x.tarnung == v));
    final j = jsonEncode({...erzaehlerPaket(_texte, _plan, n: 4, runde: 1).toJson(), 'probe': satz});
    expect(verboten.where(j.contains), isNotEmpty);
  });
}
