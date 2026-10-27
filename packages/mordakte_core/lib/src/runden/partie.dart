import '../party/ablauf.dart';
import '../party/entscheidungen.dart';
import '../party/gruppenwahl.dart';
import '../party/kanon/kanon.dart';
import '../karten/abstecher.dart';
import '../karten/karte.dart';
import '../karten/vorrat.dart';
import 'einfluss.dart';
import 'einfluss_abend.dart';
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

  /// Nur mit Einfluss-Schicht (Finale §3.3, §3.4): Tischwert der Option, „Die Spur verwischt“ nach
  /// einem Pech und die Kennzeichen des Fundes (Randnotizen, Ertappt, Verzögerung, Befragungslage).
  final int? tisch;
  final bool verwischt;
  final EinflussFund? einfluss;

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
    this.tisch,
    this.verwischt = false,
    this.einfluss,
  });

  /// Ein Zug, wie ihn ein Gerät aus der Ansicht des Raums kennt (Langer Abend
  /// M3, Gast-Detektiv): nur lesend für die Karte, ohne Wurf und Funde. Er
  /// verändert keine Partie; die Partie erzeugt ihre Züge selbst. Mit
  /// Einfluss-Schicht trägt die Ansicht `zug` dazu `tisch`, `verwischt` und
  /// `einfluss` ([EinflussFund.ausJson]); ohne bleiben sie leer.
  const RundenZug.ansicht({
    required String id,
    String? option,
    bool suche = false,
    required RundenZugPhase phase,
    required int aktion,
    Tischruf? ruf,
    String? abstecher,
    int? tisch,
    bool verwischt = false,
    EinflussFund? einfluss,
  }) : this._(
          id: id, option: option, suche: suche, phase: phase, aktion: aktion, ruf: ruf, abstecher: abstecher,
          tisch: tisch, verwischt: verwischt, einfluss: einfluss,
        );

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
  /// Mit [einfluss] spielt der Abend die Einfluss-Schicht „Dein Moment“ (Finale §3); sie braucht ein
  /// [salz] (sonst das Salz eines [SalzWuerfel]s) für Bots und Ertappt. Ohne [einfluss] alles wie heute.
  factory RundenPartie(
    Kanon kanon, {
    required WuerfelQuelle quelle,
    Ermittlung? ermittlung,
    TischVorrat? vorrat,
    List<AbstecherOrt> abstecher = const [],
    EinflussRegeln? einfluss,
    String? salz,
  }) {
    final spiel = Spiel(kanon, ermittlung: ermittlung);
    String? einflussSalz;
    if (einfluss != null) {
      for (final e in spiel.ermittlung.entscheidungen) {
        for (final o in e.optionen) {
          if (!einfluss.bezug.containsKey(o.id)) throw ArgumentError('Einfluss-Regeln ohne Option ${o.id}');
        }
      }
      einflussSalz = salz ?? (quelle is SalzWuerfel ? quelle.salz : null);
      if (einflussSalz == null || einflussSalz.isEmpty) throw ArgumentError('Die Einfluss-Schicht braucht ein Salz.');
    }
    final p = einfluss == null ? const ZugParameter() : einflussZugParameter(einfluss.zahlen);
    return RundenPartie._(
      spiel, Zugschicht(spiel.ermittlung, quelle, p: p), vorrat ?? TischVorrat.leer(), List.unmodifiable(abstecher),
      einfluss, einflussSalz,
    );
  }

  RundenPartie._(this.spiel, this._zuege, this.vorrat, this.abstecherOrte, this._regeln, this._salz);

  final Spiel spiel;
  final Zugschicht _zuege;
  RundenZug? _zug;
  int _aktionsNummer = 0;
  final EinflussRegeln? _regeln;
  final String? _salz;
  EinflussAbend? _einfluss;

  /// Die Einfluss-Schicht des Abends (ab [einrichten]); `null` ohne Schicht.
  EinflussAbend? get einfluss => _einfluss;

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

  /// Fakten, die der Detektiv sieht (mit Einfluss-Schicht ohne die bis zum Zwischenresümee verzögerten).
  Set<String> get fakten => Set.unmodifiable(spiel.sichtbareFakten());

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
    if (_regeln case final r?) {
      final e = EinflussAbend(r, spiel, salz: _salz!, restJeRunde: () => _zuege.restJeRunde);
      _einfluss = e;
      spiel.zusatz = e;
    }
  }

  /// Mit Einfluss-Schicht: Folgen beim Wechsel in die Ermittlung, deren Minuten ins Rundenbudget.
  void weiter() {
    if (!kannWeiter) throw StateError('Der aktuelle Abschnitt ist noch nicht abgeschlossen.');
    if (phase == PartyPhase.entscheidungen) _zuege.beendeRunde();
    spiel.weiter();
    if (phase == PartyPhase.entscheidungen) {
      _zuege.beginneRunde(runde, zusatzMinuten: _einfluss?.stand.folgenVon(runde)?.minuten);
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
    final ein = _einfluss;
    _zuege.waehle(option, gruendlich: gruendlich, gratis: karte != null, tisch: ein?.tischFuerWahl(option, suche: suche) ?? 0);
    if (suche) ein?.sucheGewaehlt();
    if (karte != null) vorrat.verbrauche(karte);
    _zug = RundenZug._(
      id: e.id, option: option, suche: suche,
      phase: RundenZugPhase.aktion, aktion: ++_aktionsNummer,
      tisch: ein?.tisch(option),
    );
  }

  /// Tischwert der Option [optionId] in der laufenden Runde (Abzeichen vor der Wahl, Finale §3.3);
  /// `null` ohne Einfluss-Schicht.
  int? tisch(String optionId) => _einfluss?.tisch(optionId);

  /// Zug einer besetzten Rolle im Moment dieser Runde (Finale §3.2): nur in den Gesprächen, änderbar bis
  /// zu den Folgen; [tipp] nur in der Tipp-Runde. Wer beim Wechsel in die Ermittlung keinen Zug hat,
  /// zieht als Bot; wer bewusst nichts tut, setzt [ZugArt.abgewartet].
  void zugSetzen(String rolle, ZugArt art, {String? ziel, String? tipp}) {
    final e = _einfluss ?? (throw StateError('Ohne Einfluss-Schicht gibt es keinen Moment.'));
    e.zugSetzen(EinflussZug(rolle, art, ziel: ziel, tipp: tipp));
  }

  /// Zeile „Tisch“ der Chancenvorschau (Finale §3.4): wirksamer Tischwert und Umweg-Bonus des nächsten
  /// Anlaufs einer Pflichtsuche; `null` ohne Schicht, beim Auftakt und bei Abstechern.
  ({int tisch, int umweg})? tischVorschau() {
    final z = _erwarte(RundenZugPhase.wurf);
    if (_einfluss == null || z.istAuftakt || z.istAbstecher) return null;
    return _zuege.tischAnteil();
  }

  /// Nachfragen nach Runde 3, vor der Anklage (Finale §3.5); ohne Schicht 0.
  int get nachfragenOffen => _einfluss?.nachfragenOffen ?? 0;

  /// Gewählte Optionen, zu denen eine Nachfrage noch eine Randnotiz zeigt.
  List<String> get nachfrageOptionen => _einfluss?.nachfrageOptionen ?? const [];

  /// Eine Nachfrage: zeigt die nächste Randnotiz von [optionId].
  String nachfrage(String optionId) =>
      (_einfluss ?? (throw StateError('Ohne Einfluss-Schicht gibt es keine Nachfragen.'))).nachfrage(optionId);

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
  /// Deckel +2 bleibt. Sie wird erst mit dem Wurf verbraucht, und nur, wenn sie
  /// wirkt: Liegt der Wurf auch ohne sie schon beim Deckel, bleibt die Ladung
  /// (wie bei der Marke; mit Tischwert zählt der Deckel der Schicht).
  Wurf wuerfeln({bool werkzeug = false, bool marke = false, String? karte}) {
    final z = _erwarte(RundenZugPhase.wurf);
    if (karte != null) {
      if (z.istAuftakt) throw const KartenFehler('card_wrong_moment');
      vorrat.pruefe(karte, {KartenArt.werkzeug});
      if (vorschau(werkzeug: true).mod <= vorschau().mod) {
        karte = null;
      } else {
        werkzeug = true;
      }
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
      _setzePhase(RundenZugPhase.tischruf, wurf: w, verwischt: _einfluss != null);
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
        ruf: ruf, wurf: z.wurf, tisch: z.tisch, verwischt: z.verwischt,
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

  /// Deckt die gewählte Option auf. Mit Einfluss-Schicht wertet sie den Zug aus (Finale §3.4); verzögerte
  /// Funde zeigt die Fundkarte nicht, sie kommen im Zwischenresümee ([EinflussAbend.nachgereicht]).
  void _aufdecken({Wurf? wurf}) {
    final z = _zug!;
    final funde = spiel.waehle(z.id, z.option!);
    final ein = _einfluss?.aufdecken(z.id, z.option!, suche: z.suche, kennzeichen: _zuege.kennzeichen[z.id], funde: funde);
    _zug = RundenZug._(
      id: z.id, option: z.option, suche: z.suche,
      phase: RundenZugPhase.fund, aktion: z.aktion,
      ruf: z.ruf, wurf: wurf ?? z.wurf,
      funde: ein != null && ein.verzoegert ? const [] : List.unmodifiable(funde),
      tisch: z.tisch, verwischt: z.verwischt, einfluss: ein,
    );
  }

  void _setzePhase(RundenZugPhase phase, {Wurf? wurf, bool? verwischt}) {
    final z = _zug!;
    _zug = RundenZug._(
      id: z.id, option: z.option, suche: z.suche, phase: phase,
      aktion: z.aktion, ruf: z.ruf, wurf: wurf ?? z.wurf, funde: z.funde,
      abstecher: z.abstecher, nebenfund: z.nebenfund,
      tisch: z.tisch, verwischt: verwischt ?? z.verwischt, einfluss: z.einfluss,
    );
  }
}
