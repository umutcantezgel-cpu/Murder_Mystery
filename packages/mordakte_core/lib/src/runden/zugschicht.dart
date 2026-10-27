import '../party/entscheidungen.dart';
import '../party/simulator.dart';
import 'wuerfel.dart';

/// Kosten und Grenzen der Zugschicht in Nachtminuten (K-01, K-11, K-12; Satz 6 des Meta-Simulators).
class ZugParameter {
  final int rundenzeit;
  final int pflicht;
  final int zweit;
  final int dritt;
  final int umweg;
  final int gruendlich;
  final int erfolgGewinn;
  final int abstecher;
  final int abstecherPechZeit;
  /// Höchstens eingelöste Seifenblasen-Marken je Partie (K-07).
  final int markenMax;

  /// Höchstens eingelöste Marken je Wissensziel (K-07).
  final int markenJeZiel;

  /// Grenzen des Suchmodifikators mit Tischwert (Finale §3.4). Ohne Tischwert und Umweg-Bonus gilt
  /// der Grundwert nach K-07 unverändert ([WuerfelRegel.gesamt]).
  final int modBoden;
  final int modDeckel;

  /// Bonus im Anlauf direkt nach einem Umweg (Finale §3.4); 0 = wie heute.
  final int umwegBonus;

  /// Rundenbudget mit Einfluss-Schicht (Finale §3.7): Übertrag aus der Vorrunde höchstens und Boden
  /// (3 × 14, K-12). Gilt nur, wenn [Zugschicht.beginneRunde] Zusatzminuten bekommt.
  final int uebertragHoechstens;
  final int minutenBoden;

  /// Befragung mit Tischwert (Finale §3.4): Zusatzminuten bei T = −1 („zögert“) und T ≤ −2 („mauert“).
  final int zoegert;
  final int mauert;

  const ZugParameter({
    this.rundenzeit = 45,
    this.pflicht = 6,
    this.zweit = 3,
    this.dritt = 3,
    this.umweg = 3,
    this.gruendlich = 2,
    this.erfolgGewinn = 7,
    this.abstecher = 7,
    this.abstecherPechZeit = 3,
    this.markenMax = 3,
    this.markenJeZiel = 2,
    this.modBoden = 0,
    this.modDeckel = WuerfelRegel.modMax,
    this.umwegBonus = 0,
    this.uebertragHoechstens = 0,
    this.minutenBoden = 0,
    this.zoegert = 0,
    this.mauert = 0,
  });

  /// Schlechteste Kosten eines Pflichtzugs: 6 + 2 + 3 + 3 = 14 (K-11).
  int get schlechtesterPflichtzug => pflicht + gruendlich + (zweit > umweg ? zweit : umweg) + (dritt > umweg ? dritt : umweg);

  /// Budget-Ungleichung je Runde (C2): 3 × 14 ≤ 45.
  bool budgetUngleichung(int pflichtzuegeJeRunde) => pflichtzuegeJeRunde * schlechtesterPflichtzug <= rundenzeit;
}

/// Kettensperre auf Entscheidungsebene (C2, K-13): Vorgänger je Pflichtentscheidung.
const Map<String, List<String>> kettensperre = {
  'e2_1': ['e1_1', 'e1_2', 'e1_3'],
  'e2_2': ['e1_2'],
  'e2_3': ['e1_3'],
  'e3_1': ['e1_1', 'e1_2', 'e1_3', 'e2_1', 'e2_2', 'e2_3'],
  'e3_2': ['e2_1', 'e2_2', 'e2_3'],
  'e3_3': ['e1_1', 'e2_1'],
};

/// Tischruf nach Pech (K-10): Nochmal oder Umweg zur selben Kanon-Quelle.
enum Tischruf { nochmal, umweg }

/// Würfelt eine Pflichtentscheidung? Ja, sobald eine Option einen Gegenstand,
/// Raum oder Ort zum Ziel hat (K-05); dann für alle Optionen. Befragen nie.
bool istSuche(Entscheidung e) =>
    e.optionen.any((o) => o.ziel.keys.any((k) => k == 'gegenstand' || k == 'raum' || k == 'ort'));

/// Kennzeichen einer abgeschlossenen Pflichtsuche (Finale §3.4). Ohne Einfluss-Schicht ist [tisch] 0 und
/// niemand liest sie; kein Wurf ändert sich dadurch.
class SuchKennzeichen {
  /// Tischwert der gewählten Option, mit dem die Suche begann.
  final int tisch;

  /// Letzte Stufe (Erfolg oder Teilerfolg; die Rundenschranke zählt als Teilerfolg).
  final Stufe stufe;

  /// Mindestens ein Pech: „Die Spur verwischt“.
  final bool verwischt;

  /// Mindestens ein Umweg: kein Zusatzfund, kein Ertappt, Fakten erst im Zwischenresümee.
  final bool umweg;

  const SuchKennzeichen({required this.tisch, required this.stufe, required this.verwischt, required this.umweg});

  /// Erfolg ohne Umweg: Zusatzfund, und wer im Bezug deckte, kann ertappt werden.
  bool get zusatzfund => stufe == Stufe.erfolg && !umweg;
  bool get ertapptMoeglich => zusatzfund;

  /// Die Fakten kommen erst im Zwischenresümee.
  bool get verzoegert => umweg;
}

/// Zustand einer laufenden Untersuchung (Pflichtzug mit Wurf).
class _Untersuchung {
  final String id;
  final String option;
  final bool gruendlich;

  /// Tischwert der Option (Finale §3.4); 0 ohne Schicht.
  final int tisch;
  int anlauf = 1;
  int pechFolge = 0;
  int marken = 0;
  bool wartetAufTischruf = false;
  bool verwischt = false;
  bool umweg = false;

  /// Der nächste Anlauf folgt direkt auf einen Umweg.
  bool nachUmweg = false;
  _Untersuchung(this.id, this.option, this.gruendlich, this.tisch);
}

/// Die Zugschicht „Würfel stark“ über dem Kanon 1.0 (A-4, WÜ-1…6).
///
/// Wahl vor Wurf: Die Option steht fest, bevor gewürfelt wird; der Würfel ändert
/// nur, wann das Wissen kommt, was es kostet und was dazukommt – nie die Wahl,
/// die Fakten oder die Wertung (WÜ-4). `gewaehlt` und `aufgedeckt` sind getrennt.
class Zugschicht {
  final Ermittlung ermittlung;
  final WuerfelQuelle quelle;
  final ZugParameter p;

  /// Gewählte Option je Pflichtentscheidung (ein `Spiel.waehle` je Entscheidung).
  final Map<String, String> gewaehlt = {};

  /// Pflichtentscheidungen, deren Anlauf abgeschlossen ist.
  final Set<String> aufgedeckt = {};

  /// Fakten-Ids, die der Detektiv kennt, in der Reihenfolge des Aufdeckens.
  final Set<String> fakten = {};

  /// Faktenstand beim Öffnen jeder Pflichtentscheidung (K-14).
  final Map<String, Set<String>> standBeimOeffnen = {};

  final List<Wurf> wuerfe = [];
  final List<String> ereignisse = [];

  /// Kennzeichen jeder abgeschlossenen Pflichtsuche (Finale §3.4).
  final Map<String, SuchKennzeichen> kennzeichen = {};

  int runde = 0;
  int rest = 0;
  List<String> offen = [];

  /// Seifenblasen-Marken (Kern 1.1, K-07/K-10): jedes Pech bringt eine Marke in den Bestand;
  /// eingelöst wird höchstens eine je Wurf, zwei je Wissensziel und [ZugParameter.markenMax] je Partie.
  int markenBestand = 0;
  int markenEingeloest = 0;

  /// Abstecher der Partie und Restminuten am Ende jeder Runde (Seifenblasen-Bilanz, K-24).
  int abstecherZahl = 0;
  final List<int> restJeRunde = [];
  int kettenverletzungen = 0;
  int budgetUeber = 0;
  int pechSzenen = 0;
  int erfolgeMitZusatz = 0;
  int maxPechFolge = 0;
  _Untersuchung? _lauf;
  String? _pfad;

  Zugschicht(this.ermittlung, this.quelle, {this.p = const ZugParameter()});

  /// Pfad nur für die Fakten der Kanon-Engine; der Würfel sieht ihn nie.
  void setzePfad(String pfad) => _pfad = pfad;

  Entscheidung _e(String id) => ermittlung.entscheidung(id);

  /// Schlechteste Kosten aller offenen Pflichtzüge (Reserve-Regel, K-12).
  int get reserveBedarf => offen.length * p.schlechtesterPflichtzug;

  /// Beginnt Runde [r] mit [ZugParameter.rundenzeit] Nachtminuten. Mit [zusatzMinuten] (Einfluss-Schicht,
  /// Finale §3.7) kommen der Übertrag aus der Vorrunde (höchstens [ZugParameter.uebertragHoechstens]) und
  /// die Änderungen der Folgen dazu; das Budget fällt dann nie unter [ZugParameter.minutenBoden].
  void beginneRunde(int r, {int? zusatzMinuten}) {
    if (_lauf != null) throw StateError('Untersuchung ${_lauf!.id} läuft noch');
    if (offen.isNotEmpty) throw StateError('Runde $runde hat offene Pflichtzüge: $offen');
    if (r != runde + 1) throw StateError('Runde $r folgt nicht auf Runde $runde');
    runde = r;
    if (zusatzMinuten == null) {
      rest = p.rundenzeit;
    } else {
      final vorher = restJeRunde.isEmpty ? 0 : restJeRunde.last;
      final uebertrag = r < 2 || vorher <= 0 ? 0 : (vorher < p.uebertragHoechstens ? vorher : p.uebertragHoechstens);
      final budget = p.rundenzeit + uebertrag + zusatzMinuten;
      rest = budget < p.minutenBoden ? p.minutenBoden : budget;
    }
    offen = [for (final e in ermittlung.runde(r)) e.id];
    ereignisse.add('runde:$r');
  }

  /// Auftakt-Suche in Runde 1 (nichtwertend, 0 Nachtminuten, K-03): ein Wurf ohne Modifikator.
  Wurf auftakt() {
    if (runde != 1 || wuerfe.any((w) => w.id == 'auftakt')) throw StateError('Auftakt nur einmal in Runde 1');
    final w = Wurf.werfen(quelle, 'auftakt', 1, 0, garantie: false);
    wuerfe.add(w);
    if (w.stufe == Stufe.pech) _pech();
    if (w.stufe == Stufe.erfolg) erfolgeMitZusatz++;
    ereignisse.add('auftakt:${w.stufe.kurz}');
    return w;
  }

  /// Darf jetzt ein Abstecher beginnen? Nur, wenn danach Restzeit − Kosten (mit „gründlich“
  /// +2 min) − Pech-Zuschlag die schlechtesten Kosten aller offenen Pflichtzüge deckt (K-12, Kern 1.1).
  bool abstecherErlaubt({bool gruendlich = false}) =>
      _lauf == null && rest - p.abstecher - (gruendlich ? p.gruendlich : 0) - p.abstecherPechZeit >= reserveBedarf;

  /// Darf jetzt eine Seifenblasen-Marke eingelöst werden (Bestand und Partie-Deckel)?
  bool get markeVerfuegbar => markenBestand > 0 && markenEingeloest < p.markenMax;

  /// Ein Abstecher (nichtwertend, nie `fakt:`-Glieder). Ohne [mitWurf] Rückgabe null;
  /// „gründlich“ nur mit Wurf, es kostet wie im Pflichtzug +2 min (Kern 1.1).
  /// Mit [gratis] (Abstecher-Karte) kostet der Gang selbst keine Nachtminuten;
  /// ein Pech-Zuschlag bleibt, die Reserve-Regel ebenso.
  Wurf? abstecher(String id, {bool mitWurf = false, bool werkzeug = false, bool gruendlich = false, bool marke = false, bool gratis = false}) {
    final g = mitWurf && gruendlich;
    if (!abstecherErlaubt(gruendlich: g)) throw StateError('Reserve-Regel sperrt Abstecher $id');
    rest -= (gratis ? 0 : p.abstecher) + (g ? p.gruendlich : 0);
    abstecherZahl++;
    if (!mitWurf) {
      ereignisse.add('$id:-');
      return null;
    }
    final w = _werfen(id, 1, werkzeug: werkzeug, gruendlich: g, marke: marke, garantie: false, markenAmZiel: 0);
    if (w.stufe == Stufe.pech) {
      _pech();
      rest -= p.abstecherPechZeit;
    }
    if (w.stufe == Stufe.erfolg) {
      erfolgeMitZusatz++;
      rest += p.erfolgGewinn;
    }
    ereignisse.add('$id:${w.stufe.kurz}');
    return w;
  }

  /// Zeit-Karte: Nachtminuten dazu. Lockert nur Grenzen, ändert keine Wahl.
  void zeitDazu(int minuten) {
    if (minuten < 0) throw ArgumentError('nur dazu');
    rest += minuten;
    ereignisse.add('karte:zeit+$minuten');
  }

  /// Marken-Karte: eine Seifenblasen-Marke in den Bestand. Einlösen bleibt an
  /// die Grenzen 1 je Wurf, 2 je Ziel und [ZugParameter.markenMax] je Partie gebunden.
  void markeGutschrift() {
    markenBestand++;
    ereignisse.add('karte:marke');
  }

  /// Glück im Unglück (K-10, Kern 1.1): jedes Pech bringt eine Seifenblasen-Marke.
  void _pech() {
    pechSzenen++;
    markenBestand++;
  }

  /// Wird eine gewünschte Marke eingelöst? Nur aus dem Bestand, höchstens [ZugParameter.markenMax]
  /// je Partie und [ZugParameter.markenJeZiel] je Wissensziel, und nur, wenn sie wirkt (Modifikator
  /// ohne Marke unter dem Deckel +2), damit keine Marke verfällt.
  /// Mit Tischwert ([extra] ≠ 0) zählt der Modifikator in den Grenzen der Schicht: Eine Marke, die am
  /// Deckel nichts mehr ändert, bleibt im Bestand. Ohne Tischwert genau die Regel von K-07.
  bool _markeWirkt({required bool werkzeug, required bool gruendlich, required int markenAmZiel, int extra = 0}) =>
      markeVerfuegbar &&
      markenAmZiel < p.markenJeZiel &&
      _mod(werkzeug: werkzeug, gruendlich: gruendlich, marke: true, extra: extra) >
          _mod(werkzeug: werkzeug, gruendlich: gruendlich, marke: false, extra: extra);

  /// Modifikator nach K-07 mit dem Zuschlag [extra] der Einfluss-Schicht ([WuerfelRegel.gesamt]).
  int _mod({required bool werkzeug, required bool gruendlich, required bool marke, int extra = 0}) => WuerfelRegel.gesamt(
        WuerfelRegel.modifikator(werkzeug: werkzeug, gruendlich: gruendlich, marke: marke),
        extra,
        boden: p.modBoden,
        deckel: p.modDeckel,
      );

  /// Zuschlag des nächsten Anlaufs (Finale §3.4): Tischwert, direkt nach einem Umweg ohne negatives T
  /// und mit [ZugParameter.umwegBonus]. Ohne Schicht 0.
  int _extra(_Untersuchung u) {
    final a = _anteil(u);
    return a.tisch + a.umweg;
  }

  ({int tisch, int umweg}) _anteil(_Untersuchung u) =>
      (tisch: u.nachUmweg && u.tisch < 0 ? 0 : u.tisch, umweg: u.nachUmweg ? p.umwegBonus : 0);

  Wurf _werfen(String id, int anlauf,
      {required bool werkzeug,
      required bool gruendlich,
      required bool marke,
      required bool garantie,
      required int markenAmZiel,
      int extra = 0}) {
    final m = marke && _markeWirkt(werkzeug: werkzeug, gruendlich: gruendlich, markenAmZiel: markenAmZiel, extra: extra);
    if (m) {
      markenBestand--;
      markenEingeloest++;
    }
    final mod = _mod(werkzeug: werkzeug, gruendlich: gruendlich, marke: m, extra: extra);
    final w = Wurf.werfen(quelle, id, anlauf, mod, garantie: garantie);
    wuerfe.add(w);
    return w;
  }

  /// Öffnet die nächste Pflichtentscheidung der Runde in Kanon-Reihenfolge und
  /// wählt endgültig [option] (Wahl vor Wurf). Gibt zurück, ob gewürfelt wird.
  ///
  /// [tisch] ist der Tischwert der Option (Einfluss-Schicht, Finale §3.4): Bei einer Suche formt er jeden
  /// Anlauf ([WuerfelRegel.gesamt]); eine Befragung kostet bei T = −1 [ZugParameter.zoegert] und bei
  /// T ≤ −2 [ZugParameter.mauert] Minuten mehr. Ohne Schicht 0: alles wie heute.
  bool waehle(String option, {bool gruendlich = false, bool gratis = false, int tisch = 0}) {
    if (_lauf != null) throw StateError('Untersuchung ${_lauf!.id} läuft noch');
    if (offen.isEmpty) throw StateError('keine Pflichtentscheidung offen');
    final id = offen.first;
    final e = _e(id);
    e.option(option); // wirft bei fremder Option, bevor sich etwas ändert
    // Kettensperre (K-13): erst prüfen, dann ändern; eine verletzte Kette öffnet nie.
    final fehlt = [for (final v in kettensperre[id] ?? const <String>[]) if (!aufgedeckt.contains(v)) v];
    if (fehlt.isNotEmpty) {
      kettenverletzungen++;
      throw StateError('Kettensperre $id: $fehlt nicht abgeschlossen');
    }
    offen.removeAt(0);
    standBeimOeffnen[id] = Set.of(fakten);
    gewaehlt[id] = option;
    // Mit der Gründlich-Karte kostet „gründlich“ keine Nachtminuten (+2 bleibt).
    rest -= p.pflicht + (gruendlich && !gratis ? p.gruendlich : 0);
    if (!istSuche(e)) {
      if (tisch <= -2) {
        rest -= p.mauert;
      } else if (tisch == -1) {
        rest -= p.zoegert;
      }
      _decke(id);
      ereignisse.add('$option:B');
      return false;
    }
    _lauf = _Untersuchung(id, option, gruendlich, tisch);
    return true;
  }

  /// Nächster Anlauf der laufenden Untersuchung. Pech-Garantie: ab dem dritten
  /// Anlauf oder nach zwei Pech in Folge mindestens Teilerfolg (K-10).
  Wurf anlauf({bool werkzeug = false, bool marke = false}) {
    final u = _lauf ?? (throw StateError('keine Untersuchung offen'));
    if (u.wartetAufTischruf) throw StateError('Tischruf fehlt');
    final vorher = markenEingeloest;
    final w = _werfen(u.id, u.anlauf,
        werkzeug: werkzeug,
        gruendlich: u.gruendlich,
        marke: marke,
        garantie: u.anlauf >= 3 || u.pechFolge >= 2,
        markenAmZiel: u.marken,
        extra: _extra(u));
    u.marken += markenEingeloest - vorher;
    u.nachUmweg = false;
    ereignisse.add('${u.option}:${u.anlauf}${w.stufe.kurz}');
    switch (w.stufe) {
      case Stufe.pech:
        _pech();
        u.pechFolge++;
        u.verwischt = true;
        if (u.pechFolge > maxPechFolge) maxPechFolge = u.pechFolge;
        u.wartetAufTischruf = true;
      case Stufe.erfolg:
        erfolgeMitZusatz++;
        rest += p.erfolgGewinn;
        _schliesse(u, Stufe.erfolg);
      case Stufe.teilerfolg:
        _schliesse(u, Stufe.teilerfolg);
    }
    return w;
  }

  /// Tischruf nach Pech. Reicht die Restzeit nicht (Rundenschranke), gilt die
  /// Untersuchung als Teilerfolg; Rückgabe dann `false`.
  bool tischruf(Tischruf ruf, {bool gratis = false}) {
    final u = _lauf ?? (throw StateError('keine Untersuchung offen'));
    if (!u.wartetAufTischruf) throw StateError('kein Pech offen');
    u.anlauf++;
    if (ruf == Tischruf.umweg) {
      u.umweg = true;
      u.nachUmweg = true;
    }
    ereignisse.add('${u.option}:ruf:${ruf.name}');
    // Nochmal-/Umweg-Karte: dieser Gang kostet keine Nachtminuten.
    final zusatz = gratis ? 0 : (ruf == Tischruf.umweg ? p.umweg : (u.anlauf == 2 ? p.zweit : p.dritt));
    u.wartetAufTischruf = false;
    if (rest - zusatz < 0) {
      _schliesse(u, Stufe.teilerfolg);
      ereignisse.add('${u.option}:schranke');
      return false;
    }
    rest -= zusatz;
    return true;
  }

  /// Vorschau vor dem nächsten Anlauf (WÜ-2): Modifikator, Garantie und Chancen in Prozent,
  /// genau so, wie [anlauf] mit denselben Eingaben werfen würde.
  ({int mod, bool garantie, bool markeWirkt, Map<Stufe, int> prozent}) vorschau({bool werkzeug = false, bool marke = false}) {
    final u = _lauf ?? (throw StateError('keine Untersuchung offen'));
    final garantie = u.anlauf >= 3 || u.pechFolge >= 2;
    final extra = _extra(u);
    final m = marke && _markeWirkt(werkzeug: werkzeug, gruendlich: u.gruendlich, markenAmZiel: u.marken, extra: extra);
    final mod = _mod(werkzeug: werkzeug, gruendlich: u.gruendlich, marke: m, extra: extra);
    return (mod: mod, garantie: garantie, markeWirkt: m, prozent: WuerfelRegel.chancenProzent(mod, garantie: garantie));
  }

  /// Anteil des Tisches am nächsten Anlauf (Zeile „Tisch“ der Chancenvorschau, Finale §3.4): wirksamer
  /// Tischwert (direkt nach einem Umweg ohne negatives T) und Umweg-Bonus. Ohne Schicht beides 0.
  ({int tisch, int umweg}) tischAnteil() => _anteil(_lauf ?? (throw StateError('keine Untersuchung offen')));

  /// Pech in der laufenden Untersuchung: „Die Spur verwischt“ (Finale §3.4).
  bool get verwischt => _lauf?.verwischt ?? false;

  bool get untersuchungOffen => _lauf != null;
  bool get wartetAufTischruf => _lauf?.wartetAufTischruf ?? false;

  void _schliesse(_Untersuchung u, Stufe stufe) {
    kennzeichen[u.id] = SuchKennzeichen(tisch: u.tisch, stufe: stufe, verwischt: u.verwischt, umweg: u.umweg);
    _decke(u.id);
    _lauf = null;
  }

  void _decke(String id) {
    aufgedeckt.add(id);
    // Befund F-6: ohne Pfad gäbe es still einen leeren Faktenstand – das ist ein Bedienfehler.
    final pf = _pfad ?? (throw StateError('setzePfad fehlt: ohne Pfad kein Faktenstand'));
    fakten.addAll(ermittlung.faktenVon(gewaehlt[id]!, pf));
  }

  void beendeRunde() {
    if (_lauf != null || offen.isNotEmpty) throw StateError('Runde $runde nicht fertig');
    if (rest < 0) budgetUeber++;
    restJeRunde.add(rest);
  }

  /// Nebenwertung „Seifenblasen-Bilanz“ (K-24), getrennt von [wertung]: +1 je Lupe (Erfolg),
  /// Abstecher, übrige Marke und je 5 Restminuten am Rundenende.
  int get seifenblasenBilanz =>
      erfolgeMitZusatz + abstecherZahl + markenBestand + restJeRunde.fold(0, (s, r) => s + (r > 0 ? r ~/ 5 : 0));

  /// Gewählte Optionen in Kanon-Reihenfolge (für die echte Wertung).
  List<String> get optionsfolge => [for (final e in ermittlung.entscheidungen) gewaehlt[e.id]!];

  /// Wertung nur aus der Wahl, über die Kanon-Engine (WÜ-4, Z-04).
  Verlauf wertung(Simulator sim, String pfad) => sim.verlauf(pfad, optionsfolge);

  /// Kanonisches Würfelprotokoll (WÜ-6).
  String get protokoll => wuerfe.map((w) => w.zeile).join(';');
}
