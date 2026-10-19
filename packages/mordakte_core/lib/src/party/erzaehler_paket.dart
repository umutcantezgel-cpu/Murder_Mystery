import 'befragung.dart';
import 'texte.dart';

/// Ein Tischgespräch, wie der Erzähler es kennt: wer mit wem worüber, als Stichpunkte.
class ErzaehlerTisch {
  final String sprecher, partner, thema;
  final List<String> stichpunkte;
  const ErzaehlerTisch({required this.sprecher, required this.partner, required this.thema, required this.stichpunkte});

  Map<String, Object?> toJson() => {'sprecher': sprecher, 'partner': partner, 'thema': thema, 'stichpunkte': stichpunkte};
}

/// Eine Befragung, wie der Erzähler sie kennt: wen, Thema, Fragen und die
/// Antwort-Stichpunkte in der dritten Person. [pflicht] unterscheidet feste
/// Befragungen von freien Wahlen; welche frei gewählt werden, weiß erst der Abend.
class ErzaehlerBefragung {
  final String rolle, thema;
  final bool pflicht;
  final List<String> fragen, antwort;
  const ErzaehlerBefragung({required this.rolle, required this.thema, required this.pflicht, required this.fragen, required this.antwort});

  Map<String, Object?> toJson() => {'rolle': rolle, 'thema': thema, 'pflicht': pflicht, 'fragen': fragen, 'antwort': antwort};
}

/// Was der Erzähler über eine unbesetzte Figur zum Rundenstart spricht.
class ErzaehlerNpc {
  final String figur, kennung, text;
  const ErzaehlerNpc({required this.figur, required this.kennung, required this.text});

  Map<String, Object?> toJson() => {'figur': figur, 'kennung': kennung, 'text': text};
}

/// Das Erzählerpaket einer Runde (A-052, M2.1-Vertrag): alles, was der Erzähler
/// am Tisch wissen darf, und nichts darüber hinaus. Es hängt nur an Rollenzahl
/// und Runde, nie an Pfad, Salz, Fall-Code, Qualität oder Bonus-Katalog. Nie
/// darin: `verbirgt`, Tatwissen, Tarnung, Sabotage, Täterziel und die Ziele der
/// Rollen.
class ErzaehlerPaket {
  final int rollen, runde;
  final List<ErzaehlerTisch> tisch;
  final List<ErzaehlerBefragung> befragungen;
  final List<ErzaehlerNpc> npc;

  /// So viele Befragungen wählt der Detektiv in dieser Runde frei.
  final int freiWahlen;

  const ErzaehlerPaket({
    required this.rollen,
    required this.runde,
    required this.tisch,
    required this.befragungen,
    required this.npc,
    required this.freiWahlen,
  });

  Map<String, Object?> toJson() => {
        'rollen': rollen,
        'runde': runde,
        'tisch': [for (final t in tisch) t.toJson()],
        'befragungen': [for (final b in befragungen) b.toJson()],
        'freiWahlen': freiWahlen,
        'npc': [for (final x in npc) x.toJson()],
      };
}

/// Erzählerpaket der Runde [runde] bei [n] Rollen (Modell befragung): alle
/// Tischgespräche besetzter Rollen mit dem Partner aus dem Gesprächsplan, alle
/// festen und frei wählbaren Befragungen mit ihren Antworten und die
/// NPC-Bausteine der Runde.
ErzaehlerPaket erzaehlerPaket(Texte t, Befragungsplan plan, {required int n, required int runde}) {
  if (runde < 1 || runde > Befragungsplan.runden) throw ArgumentError('ungültige Runde $runde');
  final besetzt = t.besetzung.besetzt(n);
  final partner = t.gespraechsplan(n);
  int platz(String r) => t.besetzung.reihenfolge.indexOf(r);
  final tisch = [
    for (final g in t.sammlung.gespraeche)
      if (g.runde == runde && besetzt.contains(g.rolle)) (g, partner[g.id]!),
  ]..sort((a, b) => platz(a.$1.rolle) != platz(b.$1.rolle) ? platz(a.$1.rolle) - platz(b.$1.rolle) : a.$1.nr - b.$1.nr);
  final br = plan.fuer(n, runde);
  final npc = plan.erzaehler.npcWissen(runde, besetzt: (f) => t.besetzung.istBesetzt(f, n));
  return ErzaehlerPaket(
    rollen: n,
    runde: runde,
    tisch: List.unmodifiable([
      for (final (g, p) in tisch)
        ErzaehlerTisch(sprecher: g.rolle, partner: p, thema: g.thema, stichpunkte: List.unmodifiable(g.stichpunkte)),
    ]),
    befragungen: List.unmodifiable([
      for (final r in besetzt)
        if (br.pflicht.contains(r) || br.frei.contains(r))
          ErzaehlerBefragung(
            rolle: r,
            thema: br.text(r).thema,
            pflicht: br.pflicht.contains(r),
            fragen: List.unmodifiable(br.text(r).fragen),
            antwort: befragungsAntwort(t, br.text(r)),
          ),
    ]),
    npc: List.unmodifiable([
      for (final k in npc) ErzaehlerNpc(figur: k.split('.')[1], kennung: k, text: t.baustein(k)),
    ]),
    freiWahlen: br.freiWahlen,
  );
}
