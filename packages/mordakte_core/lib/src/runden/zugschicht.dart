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

/// Zustand einer laufenden Untersuchung (Pflichtzug mit Wurf).
class _Untersuchung {
  final String id;
  final String option;
  final bool gruendlich;
  int anlauf = 1;
  int pechFolge = 0;
  int marken = 0;
  bool wartetAufTischruf = false;
  _Untersuchung(this.id, this.option, this.gruendlich);
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

  void beginneRunde(int r) {
    if (_lauf != null) throw StateError('Untersuchung ${_lauf!.id} läuft noch');
    if (offen.isNotEmpty) throw StateError('Runde $runde hat offene Pflichtzüge: $offen');
    if (r != runde + 1) throw StateError('Runde $r folgt nicht auf Runde $runde');
    runde = r;
    rest = p.rundenzeit;
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
  bool _markeWirkt({required bool werkzeug, required bool gruendlich, required int markenAmZiel}) =>
      markeVerfuegbar &&
      markenAmZiel < p.markenJeZiel &&
      WuerfelRegel.modifikator(werkzeug: werkzeug, gruendlich: gruendlich, marke: false) < WuerfelRegel.modMax;

  Wurf _werfen(String id, int anlauf,
      {required bool werkzeug, required bool gruendlich, required bool marke, required bool garantie, required int markenAmZiel}) {
    final m = marke && _markeWirkt(werkzeug: werkzeug, gruendlich: gruendlich, markenAmZiel: markenAmZiel);
    if (m) {
      markenBestand--;
      markenEingeloest++;
    }
    final mod = WuerfelRegel.modifikator(werkzeug: werkzeug, gruendlich: gruendlich, marke: m);
    final w = Wurf.werfen(quelle, id, anlauf, mod, garantie: garantie);
    wuerfe.add(w);
    return w;
  }

  /// Öffnet die nächste Pflichtentscheidung der Runde in Kanon-Reihenfolge und
  /// wählt endgültig [option] (Wahl vor Wurf). Gibt zurück, ob gewürfelt wird.
  bool waehle(String option, {bool gruendlich = false, bool gratis = false}) {
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
      _decke(id);
      ereignisse.add('$option:B');
      return false;
    }
    _lauf = _Untersuchung(id, option, gruendlich);
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
        markenAmZiel: u.marken);
    u.marken += markenEingeloest - vorher;
    ereignisse.add('${u.option}:${u.anlauf}${w.stufe.kurz}');
    switch (w.stufe) {
      case Stufe.pech:
        _pech();
        u.pechFolge++;
        if (u.pechFolge > maxPechFolge) maxPechFolge = u.pechFolge;
        u.wartetAufTischruf = true;
      case Stufe.erfolg:
        erfolgeMitZusatz++;
        rest += p.erfolgGewinn;
        _decke(u.id);
        _lauf = null;
      case Stufe.teilerfolg:
        _decke(u.id);
        _lauf = null;
    }
    return w;
  }

  /// Tischruf nach Pech. Reicht die Restzeit nicht (Rundenschranke), gilt die
  /// Untersuchung als Teilerfolg; Rückgabe dann `false`.
  bool tischruf(Tischruf ruf, {bool gratis = false}) {
    final u = _lauf ?? (throw StateError('keine Untersuchung offen'));
    if (!u.wartetAufTischruf) throw StateError('kein Pech offen');
    u.anlauf++;
    ereignisse.add('${u.option}:ruf:${ruf.name}');
    // Nochmal-/Umweg-Karte: dieser Gang kostet keine Nachtminuten.
    final zusatz = gratis ? 0 : (ruf == Tischruf.umweg ? p.umweg : (u.anlauf == 2 ? p.zweit : p.dritt));
    u.wartetAufTischruf = false;
    if (rest - zusatz < 0) {
      _decke(u.id);
      _lauf = null;
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
    final m = marke && _markeWirkt(werkzeug: werkzeug, gruendlich: u.gruendlich, markenAmZiel: u.marken);
    final mod = WuerfelRegel.modifikator(werkzeug: werkzeug, gruendlich: u.gruendlich, marke: m);
    return (mod: mod, garantie: garantie, markeWirkt: m, prozent: WuerfelRegel.chancenProzent(mod, garantie: garantie));
  }

  bool get untersuchungOffen => _lauf != null;
  bool get wartetAufTischruf => _lauf?.wartetAufTischruf ?? false;

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
