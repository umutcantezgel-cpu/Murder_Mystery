import '../party/ablauf.dart';
import '../party/entscheidungen.dart';
import '../party/gruppenwahl.dart';
import '../party/kanon/kanon.dart';
import '../karten/abstecher.dart';
import '../karten/karte.dart';
import '../karten/vorrat.dart';
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

  /// Erkundungsort bei einem Abstecher (sonst null).
  final String? abstecher;

  /// Nebenfund eines Abstechers (Stimmung, nie ein Fakt).
  final String? nebenfund;

  const RundenZug._({
    required this.id,
    required this.option,
    required this.suche,
    required this.phase,
    required this.aktion,
    this.ruf,
    this.wurf,
    this.funde = const [],
    this.abstecher,
    this.nebenfund,
  });

  bool get istAuftakt => option == null && abstecher == null;
  bool get istAbstecher => abstecher != null;
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
  factory RundenPartie(
    Kanon kanon, {
    required WuerfelQuelle quelle,
    Ermittlung? ermittlung,
    TischVorrat? vorrat,
    List<AbstecherOrt> abstecher = const [],
  }) {
    final spiel = Spiel(kanon, ermittlung: ermittlung);
    return RundenPartie._(spiel, Zugschicht(spiel.ermittlung, quelle), vorrat ?? TischVorrat.leer(), List.unmodifiable(abstecher));
  }

  RundenPartie._(this.spiel, this._zuege, this.vorrat, this.abstecherOrte);

  final Spiel spiel;
  final Zugschicht _zuege;
  RundenZug? _zug;
  int _aktionsNummer = 0;

  /// Karten des Tisches (höchstens 3, siehe [TischVorrat]); Bots haben keine.
  final TischVorrat vorrat;

  /// Erkundungsorte der Akte (optional, nie Fakten).
  final List<AbstecherOrt> abstecherOrte;

  /// Ergebnis je besuchtem Erkundungsort.
  final Map<String, Stufe> abstecherErgebnis = {};
  bool _abstecherGruendlich = false;
  String? _abstecherKarte;

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
  ///
  /// [karte] (Art gründlich) macht „gründlich“ kostenfrei; sie wirkt erst nach
  /// der endgültigen Wahl und für jede Option gleich (K-06).
  void waehle(String option, {bool gruendlich = false, String? karte}) {
    final e = naechsteEntscheidung ?? (throw StateError('Keine neue Entscheidung möglich.'));
    e.option(option); // vor jeder Zustandsänderung prüfen
    final suche = istSuche(e);
    if (gruendlich && !suche) throw ArgumentError('Befragungen sind würfelfrei.');
    if (karte != null) {
      if (!gruendlich) throw const KartenFehler('card_wrong_moment');
      vorrat.pruefe(karte, {KartenArt.gruendlich});
    }
    _zuege.waehle(option, gruendlich: gruendlich, gratis: karte != null);
    if (karte != null) vorrat.verbrauche(karte);
    _zug = RundenZug._(
      id: e.id, option: option, suche: suche,
      phase: RundenZugPhase.aktion, aktion: ++_aktionsNummer,
    );
  }

  /// Liefert false für einen veralteten/doppelten Kartenrückruf, ohne Wirkung.
  bool aktionFertig(int aktion) {
    final z = _zug;
    if (z == null || z.phase != RundenZugPhase.aktion || z.aktion != aktion) return false;
    if (z.suche || z.istAbstecher) {
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
    if (z.istAbstecher) {
      final mod = WuerfelRegel.modifikator(werkzeug: werkzeug, gruendlich: _abstecherGruendlich, marke: false);
      return (mod: mod, garantie: false, markeWirkt: false, prozent: Map.unmodifiable(WuerfelRegel.chancenProzent(mod)));
    }
    final v = _zuege.vorschau(werkzeug: werkzeug, marke: marke);
    return (mod: v.mod, garantie: v.garantie, markeWirkt: v.markeWirkt,
      prozent: Map.unmodifiable(v.prozent));
  }

  /// [karte] (Art werkzeug) ist die Quelle in der Welt für +1 (K-07); der
  /// Deckel +2 bleibt. Sie wird erst mit dem Wurf verbraucht.
  Wurf wuerfeln({bool werkzeug = false, bool marke = false, String? karte}) {
    final z = _erwarte(RundenZugPhase.wurf);
    if (karte != null) {
      if (z.istAuftakt) throw const KartenFehler('card_wrong_moment');
      vorrat.pruefe(karte, {KartenArt.werkzeug});
      werkzeug = true;
    }
    if (z.istAbstecher) {
      final w = _zuege.abstecher('abstecher:${z.abstecher}',
          mitWurf: true, werkzeug: werkzeug, gruendlich: _abstecherGruendlich, gratis: _abstecherKarte != null)!;
      if (karte != null) vorrat.verbrauche(karte);
      if (_abstecherKarte != null) vorrat.verbrauche(_abstecherKarte!);
      _abstecherKarte = null;
      abstecherErgebnis[z.abstecher!] = w.stufe;
      final ort = abstecherOrte.firstWhere((a) => a.id == z.abstecher);
      _zug = RundenZug._(
        id: z.id, option: null, suche: true, phase: RundenZugPhase.fund, aktion: z.aktion, wurf: w,
        abstecher: z.abstecher,
        nebenfund: switch (w.stufe) { Stufe.erfolg => ort.erfolg, Stufe.teilerfolg => ort.teilerfolg, Stufe.pech => ort.pech },
      );
      return w;
    }
    final w = z.istAuftakt ? _zuege.auftakt() : _zuege.anlauf(werkzeug: werkzeug, marke: marke);
    if (karte != null) vorrat.verbrauche(karte);
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
  ///
  /// [karte] (Art nochmal bzw. umweg passend zum Ruf) macht den Gang kostenfrei.
  void tischruf(Tischruf ruf, {String? karte}) {
    final z = _erwarte(RundenZugPhase.tischruf);
    if (karte != null) vorrat.pruefe(karte, {ruf == Tischruf.nochmal ? KartenArt.nochmal : KartenArt.umweg});
    final weiterLauf = _zuege.tischruf(ruf, gratis: karte != null);
    if (karte != null) vorrat.verbrauche(karte);
    if (weiterLauf) {
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

  /// Sofort wirkende Karten: Zeit (Nachtminuten, einmal je Runde), Marke (in den
  /// Bestand) und Erinnerung (reine Anzeige öffentlicher Texte). Zeit und Marke
  /// nur in der Ermittlung. Nichts davon berührt Wahl, Fakten oder Wertung.
  KartenDef karteSpielen(String id) {
    final k = vorrat.pruefe(id, {KartenArt.zeit, KartenArt.marke, KartenArt.erinnerung}, runde: runde);
    if (k.art != KartenArt.erinnerung && phase != PartyPhase.entscheidungen) throw const KartenFehler('card_wrong_moment');
    switch (k.art) {
      case KartenArt.zeit:
        _zuege.zeitDazu(k.wert);
      case KartenArt.marke:
        _zuege.markeGutschrift();
      default:
        break;
    }
    vorrat.verbrauche(id, runde: runde);
    return k;
  }

  /// Erkundungsorte, die jetzt besucht werden dürfen: in der Ermittlung, ohne
  /// laufenden Zug, ab ihrer Runde, einmal je Abend und nur, wenn die
  /// Reserve-Regel alle offenen Pflichtzüge deckt (K-12).
  List<AbstecherOrt> get abstecherOffen {
    if (phase != PartyPhase.entscheidungen || _zug != null || !_zuege.abstecherErlaubt()) return const [];
    return [for (final a in abstecherOrte) if (a.abRunde <= runde && !abstecherErgebnis.containsKey(a.id)) a];
  }

  /// Beginnt einen Abstecher mit sichtbarer Kartenaktion; danach Wurf und Fund.
  /// [karte] (Art abstecher) macht den Gang kostenfrei.
  void starteAbstecher(String id, {bool gruendlich = false, String? karte}) {
    if (!abstecherOffen.any((a) => a.id == id)) throw StateError('Abstecher $id ist jetzt nicht möglich.');
    if (gruendlich && !_zuege.abstecherErlaubt(gruendlich: true)) throw StateError('Reserve-Regel sperrt gründlich.');
    if (karte != null) vorrat.pruefe(karte, {KartenArt.abstecher});
    _abstecherGruendlich = gruendlich;
    _abstecherKarte = karte;
    _zug = RundenZug._(
      id: 'abstecher:$id', option: null, suche: true,
      phase: RundenZugPhase.aktion, aktion: ++_aktionsNummer, abstecher: id,
    );
  }

  /// Gelungene Erkundungen (Erfolg oder Teilerfolg) – Quelle für Kartenfunde.
  Set<String> get abstecherFunde => {
        for (final e in abstecherErgebnis.entries)
          if (e.value != Stufe.pech) e.key,
      };

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
      abstecher: z.abstecher, nebenfund: z.nebenfund,
    );
  }
}
