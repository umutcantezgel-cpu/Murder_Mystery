import '../../util/rng.dart';
import '../ablauf.dart';
import '../befragung.dart';
import '../enden.dart';
import '../entscheidungen.dart';
import '../erzaehler.dart';
import '../erzaehler_paket.dart';
import '../fall_code.dart';
import '../gruppenwahl.dart';
import '../kanon/kanon.dart';
import '../karte.dart';
import '../texte.dart';

/// Druckspiel eines Abends (F5-ORCH-01, Master 7.14): alle Teile als Daten,
/// bevor daraus PDF wird. Außen tragen Karten, Umschläge und Fassungen nur
/// neutrale Codes; die Zuordnung steht im versiegelten Auflösungsheft.
///
/// Alle Texte kommen wortgleich aus Textsammlung und Kanon. Das Modell
/// spielt sich am Tisch so wie der Bildschirm: gleiche Optionen in gleicher
/// Reihenfolge, gleiche Funde, gleiche Schwellen, gleiche Enden.

/// Ankreuzhilfe einer Indizkarte für den Ermittlungsbogen.
typedef Kreuz = ({String person, String typ});

/// Karte zu einer Option: außen [code], innen die Funde des Pfads.
class Indizkarte {
  final String code;
  final String entscheidung;
  final String option;

  /// Überschrift innen: Person, Gegenstand oder Stelle.
  final String ziel;

  /// Person, die heute niemand spielt (NPC-Karte, Master 7.10).
  final bool unbesetztePerson;

  /// Funde wortgleich aus `Ermittlung.aufdecken`.
  final List<String> funde;

  /// Kreuze für den Ermittlungsbogen (nur Faktarten des Bogens).
  final List<Kreuz> kreuze;

  const Indizkarte({
    required this.code,
    required this.entscheidung,
    required this.option,
    required this.ziel,
    required this.unbesetztePerson,
    required this.funde,
    required this.kreuze,
  });
}

/// Eine Entscheidung auf dem Detektivbogen.
class BogenEntscheidung {
  final String id;
  final int runde, nr;
  final String frage;

  /// Optionen in der Reihenfolge des Bildschirms: Text und Kartencode.
  final List<({String option, String text, String karte})> optionen;

  const BogenEntscheidung(this.id, this.runde, this.nr, this.frage, this.optionen);
}

/// Offene Stimmkarte eines Gastes in einer Runde. Der Abreißstreifen trägt nur den
/// neutralen [wertCode]; den [wert] (A = 1, B = 0) kennt die Codetabelle der Runde
/// im Spielleitungsheft (E-035). Die vier Kernrollen haben keine offenen Karten:
/// Sie stimmen nur mit den Streifen A und B aus ihrer versiegelten Fassung ab, so
/// kennt die Spielleitung keinen ihrer Codes (E-036, E-039).
class Stimmkarte {
  final String rolle;
  final int runde;
  final bool a;
  final String text;
  final int wert;
  final String wertCode;
  const Stimmkarte(this.rolle, this.runde, this.a, this.text, this.wert, this.wertCode);
}

/// Hinweis-Umschlag einer Runde und Qualität.
class HinweisUmschlag {
  final String code;
  final int runde;
  final Qualitaet qualitaet;

  /// Kennungen (`bonus.rahmen`, `hinweis.<id>`) und Wortlaut.
  final List<String> kennungen;
  final List<String> texte;
  const HinweisUmschlag(this.code, this.runde, this.qualitaet, this.kennungen, this.texte);
}

/// Auszähltabelle einer Runde für genau diese Personenzahl: ab welcher
/// Summe der Stimmkarten welcher Umschlag gilt (absteigend geordnet).
class Auszaehlung {
  final int runde;
  final List<({int abSumme, String umschlag})> stufen;

  /// Wertcode → Wert aller Stimmkarten dieser Runde.
  final Map<String, int> werte;
  const Auszaehlung(this.runde, this.stufen, this.werte);

  /// Summe der abgegebenen Streifen.
  int summe(Iterable<String> codes) => codes.fold(0, (s, c) => s + werte[c]!);

  /// Umschlag zu einer Summe (unter 0 zählt wie 0).
  String umschlagBei(int summe) {
    final s = summe < 0 ? 0 : summe;
    for (final st in stufen) {
      if (s >= st.abSumme) return st.umschlag;
    }
    return stufen.last.umschlag;
  }
}

/// Versiegelte Fassung einer Kernrolle: außen nur [code]. Innen je Runde ein
/// Streifen A (+1) und ein Streifen B (G-1, E-036, E-039): B zählt bei der
/// Täterrolle −1 (Sabotage), bei den anderen 0. So tun alle vier dasselbe, und
/// keine offene Karte verrät, welche Kernrolle wie gestimmt hat.
class Fassung {
  final String code;
  final String rolle;
  final Dossier dossier;

  /// Runde → Wertcode des A-Streifens (Wert 1).
  final Map<int, String> streifenA;

  /// Runde → Wertcode des B-Streifens.
  final Map<int, String> streifen;

  /// Wert der B-Streifen: −1 bei der Täterrolle, sonst 0.
  final int streifenWert;
  const Fassung(this.code, this.rolle, this.dossier, this.streifenA, this.streifen, this.streifenWert);
}

/// Erzählerheft, früher Spielleitungsheft (ohne Lösung): Bausteine je Abschnitt in Lesereihenfolge.
class Spielleitungsheft {
  final List<String> intro;
  /// Runde → Bausteine zum Rundenstart (mit dem Wissen unbesetzter Gäste, F-09).
  final Map<int, List<String>> rundenStart;
  final Map<int, String> resuemeeGruppe;

  /// Restmenge (sortierte Personen, verbunden mit `_`) → Baustein.
  final Map<String, String> resuemeeRest;

  /// Runde → Stufe (offen, spur, klar) → Baustein.
  final Map<int, Map<String, String>> resuemeeLage;
  final String anklage;
  final List<Auszaehlung> auszaehlung;

  const Spielleitungsheft({
    required this.intro,
    required this.rundenStart,
    required this.resuemeeGruppe,
    required this.resuemeeRest,
    required this.resuemeeLage,
    required this.anklage,
    required this.auszaehlung,
  });
}

/// Ermittlungsbogen: Faktarten je Kernperson und die Ausschlussregeln.
class Ermittlungsbogen {
  final List<String> personen;
  final List<String> typen;
  final List<Ausschlussregel> regeln;

  /// Regeltexte wortgleich aus dem Kanon.
  final Map<String, String> regelText;

  /// Faktarten, die die Lage „Spur“ ergeben; `schluesselbeweis` ergibt „klar“.
  final Set<String> belastend;

  const Ermittlungsbogen(this.personen, this.typen, this.regeln, this.regelText, this.belastend);
}

/// Versiegeltes Auflösungsheft.
class Aufloesungsheft {
  final String taeter;

  /// Entscheidung → Code der richtigen Indizkarte.
  final Map<String, String> richtig;
  final List<EndeRegel> endentabelle;

  /// Ende → Bausteine (Finaltext, Rückblende).
  final Map<String, List<String>> finale;

  /// Bausteine der Auflösung: Gruppe (nach Zahl der Runden mit Zusammenhalt) und je besetzter Rolle.
  final Map<int, String> gruppe;
  final List<String> rollen;

  /// Bedeutung jedes Codes als technische Kennung (`indizkarte:<e>:<o>`,
  /// `umschlag:<runde>:<qualitaet>`, `fassung:<rolle>[:taeter]`); den Text
  /// dazu setzt das Auflösungsheft aus Bausteinen.
  final Map<String, String> codes;

  const Aufloesungsheft({
    required this.taeter,
    required this.richtig,
    required this.endentabelle,
    required this.finale,
    required this.gruppe,
    required this.rollen,
    required this.codes,
  });
}

class DruckSatz {
  final FallCode code;
  final int rollen;
  final String detektiv;

  /// Minuten je Runde für das Spielleitungsheft.
  final int rundendauerMinuten;
  final List<String> besetzt;
  final Spielleitungsheft spielleitung;
  final List<BogenEntscheidung> detektivbogen;
  final Ermittlungsbogen ermittlungsbogen;
  final Map<String, Dossier> rollenhefte;
  final List<Fassung> fassungen;
  final List<Indizkarte> indizkarten;
  final List<Stimmkarte> stimmkarten;
  final List<HinweisUmschlag> umschlaege;
  final Aufloesungsheft aufloesung;

  /// Gesprächsplan für diese Personenzahl (Kennung → Partner).
  final Map<String, String> gespraechsplan;

  /// Befragungen des Detektivs je Runde (Modell befragung, A-051); leer im Modell legacy.
  /// Sie hängen nur an der Personenzahl, nie am Pfad.
  final Map<int, BefragungsRunde> befragungen;

  /// Erzählerpaket je Runde für das Erzählerheft (A-052, M2.1): Tisch-Stichpunkte,
  /// Befragungen mit Antworten, NPC-Bausteine. Pfadfrei; leer im Modell legacy.
  final Map<int, ErzaehlerPaket> erzaehler;

  DruckSatz._({
    required this.code,
    required this.rollen,
    required this.detektiv,
    required this.rundendauerMinuten,
    required this.besetzt,
    required this.spielleitung,
    required this.detektivbogen,
    required this.ermittlungsbogen,
    required this.rollenhefte,
    required this.fassungen,
    required this.indizkarten,
    required this.stimmkarten,
    required this.umschlaege,
    required this.aufloesung,
    required this.gespraechsplan,
    required this.befragungen,
    required this.erzaehler,
  });

  Indizkarte karte(String code) => indizkarten.firstWhere((k) => k.code == code);
  HinweisUmschlag umschlag(String code) => umschlaege.firstWhere((u) => u.code == code);

  /// Erzeugt den Satz für [code], [rollen] Personen und Detektiv [detektiv] (m/w).
  /// [rundendauerMinuten]: Dauer einer Runde, wie in der Einrichtung gewählt; ohne Angabe die Vorgabe aus `fall.json`.
  factory DruckSatz.aus(Kanon kanon, Texte texte, FallCode code, {required int rollen, required String detektiv, int? rundendauerMinuten}) {
    final spiel = Spiel(kanon)..einrichten(Einstellungen(rollen: rollen, detektiv: detektiv, code: code, druck: true));
    final pfad = spiel.pfad;
    final ermittlung = spiel.ermittlung;
    final karte = PartyKarte(kanon, ermittlung: ermittlung);
    final besetzt = spiel.besetzt;
    final codes = _Codes(code);
    final bedeutung = <String, String>{};

    // Indizkarten und Detektivbogen
    final bogenTypen = {for (final r in ermittlung.regeln) ...r.wenn, ...Erzaehler.belastend};
    final karten = <Indizkarte>[];
    final bogen = <BogenEntscheidung>[];
    final kartenCode = <String, String>{};
    for (final e in ermittlung.entscheidungen) {
      for (final o in e.optionen) {
        final c = codes.neu();
        kartenCode[o.id] = c;
        bedeutung[c] = 'indizkarte:${e.id}:${o.id}';
        final ziel = karte.ziele[o.id]!;
        final person = ziel.person;
        karten.add(Indizkarte(
          code: c,
          entscheidung: e.id,
          option: o.id,
          ziel: ziel.name,
          unbesetztePerson: person != null && !spiel.besetzung.istBesetzt(person, rollen),
          funde: [for (final a in ermittlung.aufdecken(o.id, pfad)) a.text],
          kreuze: [
            for (final f in ermittlung.faktenVon(o.id, pfad))
              if (bogenTypen.contains(ermittlung.fakten[f]!.typ))
                for (final p in ermittlung.fakten[f]!.personen)
                  if (kanon.kernverdaechtige.contains(p)) (person: p, typ: ermittlung.fakten[f]!.typ),
          ],
        ));
      }
      bogen.add(BogenEntscheidung(e.id, e.runde, e.nr, e.frage, [
        for (final o in spiel.optionen(e.id)) (option: o.id, text: o.text, karte: kartenCode[o.id]!),
      ]));
    }
    // Druckreihenfolge nach Code: Die Lage im Stapel verrät nichts.
    karten.sort((a, b) => a.code.compareTo(b.code));

    // Stimmkarten nur für Gäste (E-039); die Kernrollen stimmen mit ihrer Fassung.
    // Die Wertcodes entstehen erst nach allen anderen Codes, damit diese gleich bleiben.
    final stimmDaten = <(String, int, bool, String, int)>[];
    for (var r = 1; r <= 3; r++) {
      for (final rolle in besetzt) {
        if (kanon.kernverdaechtige.contains(rolle)) continue;
        final w = texte.sammlung.wahlen['gw_${rolle}_$r']!;
        stimmDaten.add((rolle, r, true, w.a, 1));
        // Die offene Karte B ist bei allen gleich (Text ohne Sabotage, Wert 0).
        stimmDaten.add((rolle, r, false, w.b, 0));
      }
    }

    // Hinweis-Umschläge und Auszählung für genau diese Personenzahl
    final umschlaege = <HinweisUmschlag>[];
    final auszaehlung = <({int runde, List<({int abSumme, String umschlag})> stufen})>[];
    for (var r = 1; r <= 3; r++) {
      final je = <Qualitaet, String>{};
      for (final q in Qualitaet.values) {
        final c = codes.neu();
        je[q] = c;
        bedeutung[c] = 'umschlag:$r:${q.name}';
        final h = spiel.gruppe.hinweis(pfad, r, q);
        final k = ['bonus.rahmen', 'hinweis.${h['id']}'];
        umschlaege.add(HinweisUmschlag(c, r, q, k, [for (final x in k) texte.baustein(x)]));
      }
      final stufen = <({int abSumme, String umschlag})>[];
      Qualitaet? vorher;
      for (var s = rollen; s >= 0; s--) {
        final q = spiel.gruppe.qualitaet(s, rollen);
        if (q != vorher) {
          stufen.add((abSumme: s, umschlag: je[q]!));
          vorher = q;
        }
      }
      // Jede Stufe gilt ab der kleinsten Summe mit derselben Qualität.
      final fest = <({int abSumme, String umschlag})>[];
      for (var i = 0; i < stufen.length; i++) {
        final naechste = i + 1 < stufen.length ? stufen[i + 1].abSumme : -1;
        var ab = stufen[i].abSumme;
        while (ab - 1 > naechste) {
          ab--;
        }
        fest.add((abSumme: ab, umschlag: stufen[i].umschlag));
      }
      auszaehlung.add((runde: r, stufen: fest));
      umschlaege.sort((a, b) => a.code.compareTo(b.code));
    }

    // Fassungen der Kernrollen (Codes jetzt, B-Streifen nach den Stimmkarten)
    final fassungsCodes = <String, String>{};
    for (final p in kanon.kernverdaechtige) {
      final c = codes.neu();
      bedeutung[c] = 'fassung:$p${p == pfad ? ':taeter' : ''}';
      fassungsCodes[p] = c;
    }

    // Wertcodes der Stimmkarten und die Codetabelle je Runde
    final stimmen = [for (final (rolle, r, a, text, wert) in stimmDaten) Stimmkarte(rolle, r, a, text, wert, codes.neu())];
    final fassungen = [
      for (final p in kanon.kernverdaechtige)
        Fassung(fassungsCodes[p]!, p, texte.dossier(p, pfad, rollen), {for (var r = 1; r <= 3; r++) r: codes.neu()},
            {for (var r = 1; r <= 3; r++) r: codes.neu()}, p == pfad ? -1 : 0),
    ];
    final zaehlung = [
      for (final a in auszaehlung)
        Auszaehlung(a.runde, a.stufen, {
          for (final s in stimmen.where((s) => s.runde == a.runde)) s.wertCode: s.wert,
          for (final f in fassungen) f.streifenA[a.runde]!: 1,
          for (final f in fassungen) f.streifen[a.runde]!: f.streifenWert,
        }),
    ];

    // Spielleitungsheft
    final erz = spiel.erzaehler;
    final kern = kanon.kernverdaechtige;
    final restmengen = <Set<String>>[
      kern.toSet(),
      for (final weg in kern) kern.where((p) => p != weg).toSet(),
      for (var a = 0; a < kern.length; a++)
        for (var b = a + 1; b < kern.length; b++) {kern[a], kern[b]},
      for (final p in kern) {p},
    ];
    final heft = Spielleitungsheft(
      intro: erz.intro(spiel),
      rundenStart: {for (var r = 1; r <= 3; r++) r: erz.rundenStart(r, besetzt: (f) => spiel.besetzung.istBesetzt(f, rollen))},
      resuemeeGruppe: {for (var r = 1; r <= 3; r++) r: 'resuemee.gruppe.$r'},
      resuemeeRest: {for (final m in restmengen) _restSchluessel(kern, m): erz.restSchluessel(m)},
      resuemeeLage: {
        for (var r = 1; r <= 3; r++) r: {for (final st in ['offen', 'spur', 'klar']) st: 'resuemee.lage.$r.$st'},
      },
      anklage: erz.anklage().single,
      auszaehlung: zaehlung,
    );

    final ende = Enden(kanon);
    final heftAufloesung = Aufloesungsheft(
      taeter: pfad,
      richtig: {for (final e in ermittlung.entscheidungen) e.id: kartenCode[e.richtig[pfad]]!},
      endentabelle: ende.regeln,
      finale: {for (final r in ende.regeln) r.id: ['finale.$pfad.${r.id}', 'rueckblende.$pfad']},
      gruppe: {for (var n = 0; n <= 3; n++) n: 'aufloesung.gruppe.$n'},
      rollen: [for (final r in besetzt) erz.aufloesungRolle(r, pfad)],
      codes: Map.unmodifiable(bedeutung),
    );

    final befragungsplan = texte.besetzung.befragungsmodell ? Befragungsplan(texte) : null;
    return DruckSatz._(
      code: code,
      rollen: rollen,
      detektiv: detektiv,
      rundendauerMinuten: rundendauerMinuten ?? (kanon.fall['rundendauerMinuten'] as num).toInt(),
      besetzt: besetzt,
      spielleitung: heft,
      detektivbogen: bogen,
      ermittlungsbogen: Ermittlungsbogen(
        kern,
        [for (final t in ['alibi', 'nebendelikt', 'spaetankunft', 'motiv', 'zusatzindiz', 'fundort', 'schluesselbeweis']) if (bogenTypen.contains(t)) t],
        ermittlung.regeln,
        // Spielertext der Regel (F-10: wortgleich mit dem Ermittlungsbogen im Kanon).
        {for (final r in ermittlung.regeln) r.id: texte.baustein('ermittlungsbogen.${r.folge}')},
        Erzaehler.belastend,
      ),
      rollenhefte: {for (final r in besetzt) r: texte.dossier(r, pfad, rollen)},
      fassungen: fassungen,
      indizkarten: karten,
      stimmkarten: stimmen,
      umschlaege: umschlaege,
      aufloesung: heftAufloesung,
      gespraechsplan: texte.gespraechsplan(rollen),
      befragungen: befragungsplan == null ? const {} : {for (var r = 1; r <= Befragungsplan.runden; r++) r: befragungsplan.fuer(rollen, r)},
      erzaehler: befragungsplan == null
          ? const {}
          : {for (var r = 1; r <= Befragungsplan.runden; r++) r: erzaehlerPaket(texte, befragungsplan, n: rollen, runde: r)},
    );
  }

  static String _restSchluessel(List<String> kern, Set<String> m) => [for (final p in kern) if (m.contains(p)) p].join('_');

  /// Restmenge nach dem Ermittlungsbogen aus den Kreuzen gezogener Karten
  /// (so rechnet der Tisch, ohne Auflösungsheft).
  Set<String> restmengeAus(Iterable<Kreuz> kreuze) {
    final st = {for (final p in ermittlungsbogen.personen) p: <String>{}};
    for (final k in kreuze) {
      st[k.person]?.add(k.typ);
    }
    bool erfuellt(Ausschlussregel r, String p) => r.wenn.every((t) => st[p]!.contains(t));
    for (final r in ermittlungsbogen.regeln.where((r) => r.folge == 'ueberfuehrt')) {
      final u = [for (final p in ermittlungsbogen.personen) if (erfuellt(r, p)) p];
      if (u.length == 1) return {u.single};
    }
    final rest = ermittlungsbogen.personen.toSet();
    for (final r in ermittlungsbogen.regeln.where((r) => r.folge == 'entlastet')) {
      rest.removeWhere((p) => erfuellt(r, p));
    }
    return rest;
  }

  /// Schlüssel der Restmenge für das Spielleitungsheft.
  String restSchluessel(Set<String> rest) => _restSchluessel(ermittlungsbogen.personen, rest);
}

/// Neutrale Codes eines Satzes: zwei Buchstaben und eine Ziffer, eindeutig.
/// Kein Buchstabenpaar kommt zweimal vor, damit sich Codes wie MN4 und MN7
/// beim Vorlesen nicht verwechseln lassen (E-036).
class _Codes {
  _Codes(FallCode code) : _rng = Rng(code.seed ^ Rng.hashString('druck'));
  final Rng _rng;
  final Set<String> _vergeben = {};
  static const _buchstaben = 'ACDEFHJKLMNPRTUVWXY';
  static const _ziffern = '3479';

  String neu() {
    while (true) {
      final c = '${_buchstaben[_rng.nextInt(_buchstaben.length)]}${_buchstaben[_rng.nextInt(_buchstaben.length)]}${_ziffern[_rng.nextInt(_ziffern.length)]}';
      if (_vergeben.add(c.substring(0, 2))) return c;
    }
  }
}
