import '../party/ablauf.dart';
import '../party/entscheidungen.dart';
import '../party/gruppenwahl.dart';
import '../party/kanon/kanon.dart';
import 'wuerfel.dart';
import 'zugschicht.dart';

/// Unterabschnitte eines Zugs. Die Karte bestätigt zuerst die sichtbare Aktion;
/// erst danach wird gewürfelt bzw. die unveränderte Kanon-Quelle aufgedeckt.
enum RundenZugPhase { aktion, wurf, tischruf, fund }

/// Unveränderliche Ansicht des aktuellen Zugs, ohne Täterpfad oder richtige Wahl.
class RundenZug {
  final String id;
  final String? option;
  final bool suche;
  final RundenZugPhase phase;

  /// Eindeutige Nummer der Kartenaktion. Verspätete Animationsrückrufe eines
  /// früheren Zugs oder Anlaufs dürfen den aktuellen Zug nicht abschließen.
  final int aktion;
  final Tischruf? ruf;
  final Wurf? wurf;
  final List<Aufdeckung> funde;

  const RundenZug._({
    required this.id,
    required this.option,
    required this.suche,
    required this.phase,
    required this.aktion,
    this.ruf,
    this.wurf,
    this.funde = const [],
  });

  bool get istAuftakt => option == null;
}

/// Verbindet Kanon-Ablauf und Würfelkern, ohne Flutter, Uhr oder Transport.
///
/// Party, Solo und der autoritative Server können denselben Controller nutzen.
/// Auswahl, Kartenaktion, Wurf/Tischruf und Lesen sind getrennte Schritte. Die
/// Auswahl ist sofort gesperrt; genau ein [Spiel.waehle] geschieht nach dem
/// abgeschlossenen Anlauf. Bis dahin sind weder Fundtext noch neue Fakten im
/// Kanon-Spiel sichtbar. Würfel ändern niemals die Option oder die Wertung.
///
/// [spiel] dient bestehenden Ansichten als Lesemodell. Sobald dieser Controller
/// verwendet wird, dürfen Aufrufer das Spiel nicht parallel selbst verändern.
/// Weder Spiel noch Controller dürfen als Online-Zustand serialisiert werden:
/// dafür ist eine separate, spielerbezogene Projektion erforderlich.
class RundenPartie {
  factory RundenPartie(Kanon kanon, {required WuerfelQuelle quelle, Ermittlung? ermittlung}) {
    final spiel = Spiel(kanon, ermittlung: ermittlung);
    return RundenPartie._(spiel, Zugschicht(spiel.ermittlung, quelle));
  }

  RundenPartie._(this.spiel, this._zuege);

  final Spiel spiel;
  final Zugschicht _zuege;
  RundenZug? _zug;
  int _aktionsNummer = 0;

  PartyPhase get phase => spiel.phase;
  int get runde => spiel.runde;
  RundenZug? get zug => _zug;
  int get restMinuten => _zuege.rest;
  int get reserveMinuten => _zuege.reserveBedarf;
  int get marken => _zuege.markenBestand;
  int get seifenblasenBilanz => _zuege.seifenblasenBilanz;
  List<Wurf> get wuerfe => List.unmodifiable(_zuege.wuerfe);
  List<int> get restJeRunde => List.unmodifiable(_zuege.restJeRunde);
  Set<String> get fakten => Set.unmodifiable(spiel.bekannteFakten());

  Entscheidung? get naechsteEntscheidung {
    if (phase != PartyPhase.entscheidungen || _zug != null || _zuege.offen.isEmpty) return null;
    return spiel.ermittlung.entscheidung(_zuege.offen.first);
  }

  bool get kannWeiter => _zug == null && switch (phase) {
    PartyPhase.einrichtung || PartyPhase.ende => false,
    PartyPhase.entscheidungen => _zuege.offen.isEmpty,
    PartyPhase.gruppenwahl => spiel.qualitaeten.containsKey(runde),
    PartyPhase.anklage => spiel.angeklagt != null,
    _ => true,
  };

  void einrichten(Einstellungen einstellungen) {
    if (einstellungen.druck) throw ArgumentError('Das Druckspiel bleibt ohne Würfel und verwendet Spiel.');
    spiel.einrichten(einstellungen);
    _zuege.setzePfad(spiel.pfad);
  }

  void weiter() {
    if (!kannWeiter) throw StateError('Der aktuelle Abschnitt ist noch nicht abgeschlossen.');
    if (phase == PartyPhase.entscheidungen) _zuege.beendeRunde();
    spiel.weiter();
    if (phase == PartyPhase.entscheidungen) {
      _zuege.beginneRunde(runde);
      if (runde == 1) {
        // Der erste, nichtwertende Suchwurf kostet keine Nachtminuten (K-03).
        _zug = RundenZug._(
          id: 'auftakt', option: null, suche: true,
          phase: RundenZugPhase.aktion, aktion: ++_aktionsNummer,
        );
      }
    }
  }

  /// Wahl vor Wurf. Eine weitere Auswahl ist bis zum Lesen des Fundes gesperrt.
  /// „Gründlich“ gehört nur zu Suchen, nie zu Befragungen.
  void waehle(String option, {bool gruendlich = false}) {
    final e = naechsteEntscheidung ?? (throw StateError('Keine neue Entscheidung möglich.'));
    e.option(option); // vor jeder Zustandsänderung prüfen
    final suche = istSuche(e);
    if (gruendlich && !suche) throw ArgumentError('Befragungen sind würfelfrei.');
    _zuege.waehle(option, gruendlich: gruendlich);
    _zug = RundenZug._(
      id: e.id, option: option, suche: suche,
      phase: RundenZugPhase.aktion, aktion: ++_aktionsNummer,
    );
  }

  /// Liefert false für einen veralteten/doppelten Kartenrückruf, ohne Wirkung.
  bool aktionFertig(int aktion) {
    final z = _zug;
    if (z == null || z.phase != RundenZugPhase.aktion || z.aktion != aktion) return false;
    if (z.suche) {
      _setzePhase(RundenZugPhase.wurf);
    } else {
      _aufdecken();
    }
    return true;
  }

  ({int mod, bool garantie, bool markeWirkt, Map<Stufe, int> prozent}) vorschau({
    bool werkzeug = false, bool marke = false,
  }) {
    final z = _erwarte(RundenZugPhase.wurf);
    if (z.istAuftakt) {
      return (mod: 0, garantie: false, markeWirkt: false,
        prozent: Map.unmodifiable(WuerfelRegel.chancenProzent(0)));
    }
    final v = _zuege.vorschau(werkzeug: werkzeug, marke: marke);
    return (mod: v.mod, garantie: v.garantie, markeWirkt: v.markeWirkt,
      prozent: Map.unmodifiable(v.prozent));
  }

  Wurf wuerfeln({bool werkzeug = false, bool marke = false}) {
    final z = _erwarte(RundenZugPhase.wurf);
    final w = z.istAuftakt ? _zuege.auftakt() : _zuege.anlauf(werkzeug: werkzeug, marke: marke);
    if (z.istAuftakt) {
      // Der Auftakt hat keine wertende Entscheidung und keine Kanon-Funde.
      _setzePhase(RundenZugPhase.fund, wurf: w);
    } else if (w.stufe == Stufe.pech) {
      _setzePhase(RundenZugPhase.tischruf, wurf: w);
    } else {
      _aufdecken(wurf: w);
    }
    return w;
  }

  /// Beide Wege behalten dieselbe gewählte Kanon-Quelle. Auch ein neuer Anlauf
  /// braucht eine neue sichtbare Kartenaktion, bevor wieder gewürfelt wird.
  void tischruf(Tischruf ruf) {
    final z = _erwarte(RundenZugPhase.tischruf);
    if (_zuege.tischruf(ruf)) {
      _zug = RundenZug._(
        id: z.id, option: z.option, suche: z.suche,
        phase: RundenZugPhase.aktion, aktion: ++_aktionsNummer,
        ruf: ruf, wurf: z.wurf,
      );
    } else {
      // Rundenschranke: Das Wissen bleibt auch ohne weitere Nachtzeit erreichbar.
      _aufdecken();
    }
  }

  void fundGelesen() {
    _erwarte(RundenZugPhase.fund);
    _zug = null;
  }

  Qualitaet abstimmen({required int kooperativ, required bool taeterSabotiert}) =>
      spiel.abstimmen(kooperativ: kooperativ, taeterSabotiert: taeterSabotiert);

  void anklagen(String person) => spiel.anklagen(person);

  RundenZug _erwarte(RundenZugPhase erwartetePhase) {
    final z = _zug;
    if (z == null || z.phase != erwartetePhase) throw StateError('Erwartet $erwartetePhase, ist ${z?.phase}.');
    return z;
  }

  void _aufdecken({Wurf? wurf}) {
    final z = _zug!;
    final funde = spiel.waehle(z.id, z.option!);
    _zug = RundenZug._(
      id: z.id, option: z.option, suche: z.suche,
      phase: RundenZugPhase.fund, aktion: z.aktion,
      ruf: z.ruf, wurf: wurf ?? z.wurf, funde: List.unmodifiable(funde),
    );
  }

  void _setzePhase(RundenZugPhase phase, {Wurf? wurf}) {
    final z = _zug!;
    _zug = RundenZug._(
      id: z.id, option: z.option, suche: z.suche, phase: phase,
      aktion: z.aktion, ruf: z.ruf, wurf: wurf ?? z.wurf, funde: z.funde,
    );
  }
}
