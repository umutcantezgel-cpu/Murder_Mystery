import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:mordakte_core/mordakte_core.dart';
import 'package:mordakte_core/runden.dart';

import 'daten.dart';
import 'runden_texte.dart';

/// Ein Partyabend in der App (F4-ORCH-02). Hält den Spielzustand ([Spiel]),
/// Einstellungen, Spielernamen, die verdeckte Einzelansicht, die laufende
/// Gruppenwahl und den Vorschlag auf der Karte.
///
/// Feste API für alle Bildschirme in `lib/party/bildschirme/`:
/// - Kein Bildschirm erzeugt Text. Story-Texte kommen über [text], Texte der
///   Oberfläche über [ui] (Kennungen `ui.*` in `texte/ui*.json`, F-11).
/// - Was nur eine Person sehen darf (Dossier, Täterfassung, Wahl), gibt es nur
///   in der verdeckten Einzelansicht ([verdeckt]); vor dem Finale verrät keine
///   andere Methode den Täter-Pfad (E-008).
class PartySitzung extends ChangeNotifier {
  /// [vorrat] (Deck des Geräts) und [abstecher] (Erkundungsorte der Akte) sind
  /// optional; ohne sie läuft der Abend wie bisher ohne Karten und Abstecher.
  ///
  /// Mit [partie] liest die Sitzung eine schon eingerichtete Partie, die ein
  /// anderer führt (Online-Abend: der Raum des Gastgebergeräts, siehe
  /// `GastgeberSitzung`). [salz] muss dann das Salz dieses Raums sein.
  PartySitzung(
    this.daten, {
    WuerfelQuelle? wuerfel,
    String? salz,
    TischVorrat? vorrat,
    List<AbstecherOrt> abstecher = const [],
    RundenPartie? partie,
  }) {
    // Das Salz ist unabhängig von Fall-Code, Pfad, Besetzung und Optionswahl.
    // Eine Vorgabe dient reproduzierbaren Tests, nicht dem Einrichtungsbildschirm.
    final zufall = math.Random.secure();
    _salz = salz ?? List.generate(16, (_) => zufall.nextInt(256).toRadixString(16).padLeft(2, '0')).join();
    if (_salz.isEmpty) throw ArgumentError('leeres Salz');
    _quelle = wuerfel ?? SalzWuerfel(_salz);
    if (partie != null) {
      _partie = partie;
      // Die Partie ist schon eingerichtet; der Fall-Code steht in ihren Einstellungen.
      if (partie.phase.index > PartyPhase.einrichtung.index) _code = partie.spiel.einstellungen.code;
    } else {
      _partie = RundenPartie(daten.kanon, quelle: _quelle, ermittlung: daten.karte.ermittlung, vorrat: vorrat, abstecher: abstecher);
    }
  }

  /// Läuft der Abend online über einen Raum (Gastgebergerät)? Dann gehen alle
  /// Eingaben als Raumnachrichten hinaus, und Bildschirme, die auf Gäste warten,
  /// zeigen den Fortschritt statt der Geräteübergabe.
  bool get online => false;

  /// Darf dieses Gerät jetzt würfeln? Offline immer; online nur die Würfelpatin
  /// oder der Würfelpate des Raums.
  bool get darfWuerfeln => true;

  final PartyDaten daten;
  late final String _salz;
  late final WuerfelQuelle _quelle;
  late RundenPartie _partie;
  Spiel? _druckSpiel;
  bool _solo = false;
  bool get solo => _solo;

  /// Lesemodell für bestehende Kanon-Ansichten. Änderungen nur über die Sitzung.
  Spiel get spiel => _druckSpiel ?? _partie.spiel;
  bool get mitWuerfel => _druckSpiel == null;
  RundenZug? get zug => mitWuerfel ? _partie.zug : null;
  int get restMinuten => _partie.restMinuten;
  int get reserveMinuten => _partie.reserveMinuten;
  int get marken => _partie.marken;
  List<Wurf> get wuerfe => _partie.wuerfe;

  // ---------------------------------------------------------------------------
  // Karten und Abstecher

  /// Legt das Deck (Tischvorrat) und die Erkundungsorte fest. Nur vor der
  /// Einrichtung des Abends, denn der Assistent lädt die Akte, bevor das Deck
  /// feststeht; danach ändert sich der Vorrat nur noch durch Ausspielen.
  void kartenAnlegen({TischVorrat? vorrat, List<AbstecherOrt> abstecher = const []}) {
    if (_druckSpiel != null || phase.index > PartyPhase.einrichtung.index) {
      throw StateError('Karten lassen sich nur vor der Einrichtung des Abends festlegen.');
    }
    _partie = RundenPartie(daten.kanon, quelle: _quelle, ermittlung: daten.karte.ermittlung, vorrat: vorrat, abstecher: abstecher);
    notifyListeners();
  }

  /// Karten des Tisches (höchstens drei; je Art eine); leer ohne Deck und im Druckspiel.
  TischVorrat get vorrat => mitWuerfel ? _partie.vorrat : TischVorrat.leer();

  /// Liegt mindestens eine Karte auf dem Tisch?
  bool get hatKarten => mitWuerfel && _partie.vorrat.karten.isNotEmpty;

  /// Spielt eine Sofortkarte (Zeit, Marke, Erinnerung). Zeit und Marke wirken nur
  /// in der Ermittlung, einmal je Runde bzw. Ladung; nichts berührt Wahl oder Wertung.
  KartenDef karteSpielen(String id) {
    final k = _partie.karteSpielen(id);
    _melde();
    notifyListeners();
    return k;
  }

  /// Erkundungsorte dieser Akte (auch bereits besuchte).
  List<AbstecherOrt> get abstecherOrte => _partie.abstecherOrte;

  /// Erkundungsorte, die jetzt besucht werden dürfen (ohne laufenden Zug).
  List<AbstecherOrt> get abstecherOffen => mitWuerfel ? _partie.abstecherOffen : const [];

  /// Ergebnis je besuchtem Erkundungsort.
  Map<String, Stufe> get abstecherErgebnis => Map.unmodifiable(_partie.abstecherErgebnis);

  /// Gelungene Erkundungen (Erfolg oder Teilerfolg), Quelle der Kartenfunde.
  Set<String> get abstecherFunde => _partie.abstecherFunde;

  /// Beginnt eine Erkundung: sichtbarer Weg, dann Würfelbühne, dann der Nebenfund.
  /// Mit [karte] (Art Abstecher) kostet der Gang keine Nachtminuten.
  void starteAbstecher(String id, {String? karte}) {
    if (!mitWuerfel) throw StateError('Abstecher gibt es nur mit Würfeln.');
    _partie.starteAbstecher(id, karte: karte);
    _vorschlag = null;
    _zugGeaendert();
  }

  /// Der Erkundungsort des laufenden Zugs (sonst null).
  AbstecherOrt? get abstecherLaufend {
    final id = zug?.abstecher;
    if (id == null) return null;
    for (final a in _partie.abstecherOrte) {
      if (a.id == id) return a;
    }
    return null;
  }

  /// Stabile Kennung dieses Abends für die Belohnungsbuchung: aus dem Salz
  /// abgeleitet (zwei FNV-Hashes), verrät es nicht.
  String get abendId {
    String hex(String s) => Rng.hashString(s).toRadixString(16).padLeft(8, '0');
    return '${hex('abend:a:$_salz')}${hex('abend:b:$_salz')}';
  }

  /// Ergebnis dieses Abends aus Sicht eines Geräts (erst nach dem Finale):
  /// Grundlage der Kartenbelohnung. [rolle] ist die gespielte Rolle oder
  /// `klasse:<name>` für den Detektiv.
  AbendErgebnis abendErgebnis({String spielerId = 'me', String? rolle}) {
    _nurNachFinale();
    return AbendErgebnis(
      akte: daten.fall,
      salz: _salz,
      spielerId: spielerId,
      rolle: rolle,
      pfad: spiel.pfad,
      anklageRichtig: spiel.ende.richtig,
      ende: spiel.ende.id,
      abstecherFunde: abstecherFunde,
      tischFiguren: {...besetzt},
    );
  }

  /// Würfelpate wechselt mit jedem Wurf; Rollen haben keinen Einfluss auf die Augen.
  String get wuerfelPate => solo ? personAmTisch(Besetzung.detektiv) : spielerName(besetzt[wuerfe.length % besetzt.length]);

  /// Schreibt bei jedem Schritt eine Zeile `PARTY …` in die Konsole
  /// (Entwickler-Einstieg und E2E-Läufe).
  static bool protokoll = false;

  Kanon get kanon => daten.kanon;
  PartyKarte get karte => daten.karte;

  PartyPhase get phase => spiel.phase;
  int get runde => spiel.runde;
  bool get eingerichtet => phase.index > PartyPhase.einrichtung.index;

  // ---------------------------------------------------------------------------
  // Texte

  /// Wortlaut eines Bausteins (Erzähler, Detektiv, Hinweis, Oberfläche).
  String text(String kennung) => rundenTexte[kennung] ?? daten.texte.baustein(kennung);

  /// Text der Oberfläche; Platzhalter `{name}` werden aus [werte] gefüllt.
  String ui(String kennung, [Map<String, String> werte = const {}]) {
    var t = text(kennung);
    for (final e in werte.entries) {
      t = t.replaceAll('{${e.key}}', e.value);
    }
    return t;
  }

  /// Gibt es den Baustein? (für optionale Texte der Oberfläche)
  bool hatText(String kennung) {
    try {
      text(kennung);
      return true;
    } on ArgumentError {
      return false;
    }
  }

  /// Bausteine, die der Erzähler beim letzten Schritt ausgegeben hat.
  List<String> get erzaehler => spiel.bausteine.sublist(_erzaehlerAb);
  int _erzaehlerAb = 0;

  /// Für Online-Abende: Der Raum hat die Partie verändert (eigener Befehl oder
  /// ein Gast). Gleicht Erzählerfenster und letzten Fund mit der Partie ab und
  /// meldet allen Zuhörern die Änderung. [erzaehlerAb] ist der Beginn des
  /// Erzählerfensters in `spiel.bausteine`.
  @protected
  void raumGeaendert({required int erzaehlerAb}) {
    _erzaehlerAb = erzaehlerAb.clamp(0, spiel.bausteine.length);
    final z = zug;
    if (z != null && z.phase == RundenZugPhase.fund && z.option != null) {
      final ziel = karte.ziele[z.option];
      if (ziel != null) {
        _funde[z.id] = z.funde;
        _letzterFund = (entscheidung: z.id, ziel: ziel, funde: z.funde);
      }
    } else {
      _letzterFund = null;
    }
    _melde();
    notifyListeners();
  }

  /// Für Online-Abende: das gewählte, noch nicht bestätigte Ziel vergessen.
  @protected
  void vorschlagLoeschen() => _vorschlag = null;

  // ---------------------------------------------------------------------------
  // Figuren

  Map<String, Object?> figur(String id) => kanon.figur(id) ?? (throw ArgumentError('unbekannte Figur $id'));
  String figurName(String id) => figur(id)['name'] as String;
  String figurTitel(String id) => (figur(id)['roleTitle'] ?? figur(id)['title'] ?? '') as String;
  Color figurFarbe(String id) => Color(int.parse((figur(id)['colorCode'] as String).substring(1), radix: 16) | 0xFF000000);

  /// Aussehen einer Figur für Porträts und Fotoabzüge (aus `look` und Farbcode).
  LookDef figurAussehen(String id) => _aussehen[id] ??= LookDef.fromJson(renderLook(figur(id)));
  final Map<String, LookDef> _aussehen = {};

  /// Name am Tisch: Spielername, sonst Figurenname.
  String spielerName(String rolle) {
    final n = namen[rolle];
    return n == null || n.trim().isEmpty ? figurName(rolle) : n.trim();
  }

  // ---------------------------------------------------------------------------
  // Einrichtung

  int get minRollen => spiel.besetzung.minRollen;
  int get maxRollen => spiel.besetzung.maxRollen;

  /// Besetzte Rollen bei [n] Personen (feste Besetzungsreihenfolge).
  List<String> rollenBei(int n) => spiel.besetzung.besetzt(n);

  /// Spielernamen je Rolle.
  final Map<String, String> namen = {};

  /// Name des Geburtstagskinds (Detektiv).
  String geburtstagskind = '';

  /// Erzähler-Stimme an (lokal, abschaltbar).
  bool stimmeAn = false;

  /// Rundendauer; im Entwickler-Einstieg auch in Sekunden.
  Duration rundendauer = const Duration(minutes: 30);

  /// Spielsekunden je echter Sekunde in der Rückblende.
  double zeitraffer = 25;

  FallCode? _code;
  FallCode get fallCode => _code ?? (throw StateError('Spiel ist noch nicht eingerichtet'));

  /// Ein neuer zufälliger Fall-Code.
  static FallCode zufallsCode([int? seed]) => FallCode.zufall(Rng(seed ?? DateTime.now().microsecondsSinceEpoch ^ math.Random().nextInt(1 << 30)));

  /// Titel → Einrichtung.
  void zurEinrichtung() {
    if (phase == PartyPhase.titel) _weiter();
  }

  /// Einrichtung abschließen. [code] leer oder ungültig heißt: Zufall.
  void einrichten({
    required int rollen,
    required String detektiv,
    String? code,
    bool druck = false,
    bool solo = false,
    int rundendauerMinuten = 30,
    Map<String, String> namen = const {},
    String geburtstagskind = '',
  }) {
    if (solo && druck) throw ArgumentError('Solo ist kein Druckspiel');
    zurEinrichtung();
    final c = (code == null ? null : FallCode.lesen(code)) ?? zufallsCode();
    final einstellung = Einstellungen(rollen: rollen, detektiv: detektiv, code: c, druck: druck, rundendauerMinuten: rundendauerMinuten);
    if (druck) {
      if (phase != PartyPhase.einrichtung) throw StateError('Der Abend ist bereits eingerichtet.');
      final papier = Spiel(daten.kanon, ermittlung: daten.karte.ermittlung)..einrichten(einstellung);
      _druckSpiel = papier;
    } else {
      _partie.einrichten(einstellung);
    }
    _code = c;
    _solo = solo;
    _erzaehlFlags.clear();
    _gefuehrteGespraeche.clear();
    _gespraech = null;
    this.namen
      ..clear()
      ..addAll({for (final r in besetzt) if (namen[r] != null) r: namen[r]!});
    this.geburtstagskind = geburtstagskind;
    rundendauer = Duration(minutes: rundendauerMinuten);
    _melde();
    notifyListeners();
  }

  Einstellungen get einstellungen => spiel.einstellungen;
  List<String> get besetzt => spiel.besetzt;

  // ---------------------------------------------------------------------------
  // Verdeckte Einzelansicht

  String? _verdeckt;

  /// Rolle, deren verdeckte Ansicht gerade offen ist.
  String? get verdeckt => _verdeckt;

  /// „Ich bin `Name`, zeig her“.
  void zeigeVerdeckt(String rolle) {
    if (solo && !nachFinale) throw StateError('Bot-Dossiers bleiben verdeckt');
    if (!besetzt.contains(rolle)) throw ArgumentError('$rolle ist nicht besetzt');
    _verdeckt = rolle;
    notifyListeners();
  }

  /// Ansicht schließen; der Bildschirm ist danach wieder neutral.
  void verdecken() {
    _verdeckt = null;
    notifyListeners();
  }

  void _nurVerdeckt(String rolle) {
    if ((solo || _verdeckt != rolle) && !nachFinale) throw StateError('nur in der verdeckten Ansicht von $rolle');
  }

  /// Dossier (nur verdeckt). Kernrollen bekommen im eigenen Pfad die Täterfassung.
  Dossier dossier(String rolle) {
    _nurVerdeckt(rolle);
    return daten.texte.dossier(rolle, spiel.pfad, einstellungen.rollen);
  }

  /// Ist [rolle] die Täterrolle? Nur verdeckt oder nach dem Finale.
  bool istTaeter(String rolle) {
    _nurVerdeckt(rolle);
    return rolle == spiel.pfad;
  }

  /// Die zwei Möglichkeiten der Rundenwahl (nur verdeckt): A kooperativ, B
  /// eigennützig. Bei der Täterrolle ist B die Sabotage (G-1).
  ({String a, String b}) wahl(String rolle) {
    _nurVerdeckt(rolle);
    final w = daten.texte.sammlung.wahlen['gw_${rolle}_$runde']!;
    return (a: w.a, b: rolle == spiel.pfad && w.sabotage != null ? w.sabotage! : w.b);
  }

  // ---------------------------------------------------------------------------
  // Runden

  Map<String, Object?> get _rundeKanon => (kanon.fall['runden'] as List).cast<Map>().firstWhere((r) => r['nr'] == runde).cast<String, Object?>();
  String get rundenName => _rundeKanon['name'] as String;

  /// Uhrzeit der Runde im Spiel („00:30“); gleich in Bild, Erzähler und Dossier.
  String get rundenUhrzeit => _rundeKanon['uhrzeit'] as String;

  /// Pflichtgespräche der besetzten Rollen in [r] mit dem tatsächlichen Partner.
  List<({Gespraech gespraech, String partner})> gespraeche(int r) {
    final plan = daten.texte.gespraechsplan(einstellungen.rollen);
    final b = besetzt.toSet();
    return [
      for (final g in daten.texte.sammlung.gespraeche)
        if (g.runde == r && b.contains(g.rolle)) (gespraech: g, partner: plan[g.id] ?? g.partner),
    ]..sort((x, y) => besetzt.indexOf(x.gespraech.rolle) != besetzt.indexOf(y.gespraech.rolle)
        ? besetzt.indexOf(x.gespraech.rolle).compareTo(besetzt.indexOf(y.gespraech.rolle))
        : x.gespraech.nr.compareTo(y.gespraech.nr));
  }

  /// Name einer Gesprächsperson am Tisch (Rolle oder Detektiv).
  String personAmTisch(String id) => id == (kanon.figurenJson['detektiv'] as Map)['id']
      ? (geburtstagskind.trim().isEmpty ? ui('ui.allgemein.detektiv') : geburtstagskind.trim())
      : spielerName(id);

  final Map<int, List<BotGespraech>> _soloGespraeche = {};
  final Set<String> _soloGelesen = {};

  /// Nur öffentliche Sprechblasen der aktuellen Runde, keine künftigen Texte.
  List<BotGespraech> get soloGespraeche => !solo || runde < 1 ? const [] : _soloGespraeche.putIfAbsent(
    runde, () => botGespraeche(daten.texte, rollen: einstellungen.rollen, runde: runde, mitNpc: true),
  );

  /// Bereits gehörte Aussagen bleiben im Notizbuch erreichbar.
  List<BotGespraech> get soloNotizen => List.unmodifiable({
    for (final liste in _soloGespraeche.values)
      for (final g in liste) if (_soloGelesen.contains(g.id)) g.id: g,
  }.values);

  void soloGespraechGelesen(String id) {
    if (!solo || phase != PartyPhase.gespraeche || !soloGespraeche.any((g) => g.id == id)) {
      throw StateError('kein aktuelles Solo-Gespräch');
    }
    if (_soloGelesen.add(id)) notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Ablauf

  /// Kann der Abend zum nächsten Abschnitt? Solo-Wissen kommt vor der Wahl;
  /// eine Uhr oder eine verdeckte Bot-Karte kann diese Schranke nicht umgehen.
  bool get kannWeiter {
    if (solo && phase == PartyPhase.gespraeche && soloGespraeche.any((g) => !_soloGelesen.contains(g.id))) return false;
    return mitWuerfel ? _partie.kannWeiter && _vorschlag == null : switch (phase) {
        PartyPhase.titel => true,
        PartyPhase.einrichtung => false,
        PartyPhase.entscheidungen => karte.laufend(spiel) == null && _vorschlag == null && _letzterFund == null,
        PartyPhase.gruppenwahl => spiel.qualitaeten.containsKey(runde),
        PartyPhase.anklage => spiel.angeklagt != null,
        PartyPhase.ende => false,
        _ => true,
      };
  }

  /// Zum nächsten Abschnitt.
  void weiter() {
    if (phase == PartyPhase.einrichtung) throw StateError('Einrichtung über einrichten() abschließen');
    _weiter();
  }

  void _weiter() {
    if (!kannWeiter) throw StateError('Der aktuelle Abschnitt ist noch nicht abgeschlossen.');
    final vorher = spiel.bausteine.length;
    if (mitWuerfel) {
      _partie.weiter();
    } else {
      spiel.weiter();
    }
    _erzaehlerAb = vorher;
    _verdeckt = null;
    if (phase == PartyPhase.gruppenwahl) {
      _stimmen.clear();
      if (solo) {
        for (final rolle in besetzt) {
          _stimmen[rolle] = botKooperativ(salz: _salz, rolle: rolle, runde: runde);
        }
        _auswerten();
      }
    }
    _letzterFund = null;
    _melde();
    notifyListeners();
  }

  void _melde() {
    if (!protokoll) return;
    final e = laufendeEntscheidung?.id;
    debugPrint('PARTY phase=${phase.name} runde=$runde${e == null ? '' : ' entscheidung=$e'}');
  }

  // ---------------------------------------------------------------------------
  // Entscheidungen auf der Karte

  /// Laufende Entscheidung (Frage und Optionen in gemischter Reihenfolge).
  Entscheidung? get laufendeEntscheidung {
    if (mitWuerfel) return _partie.naechsteEntscheidung;
    final id = karte.laufend(spiel);
    return id == null ? null : spiel.ermittlung.entscheidung(id);
  }

  List<EntscheidungsOption> optionen(String entscheidungId) => spiel.optionen(entscheidungId);

  KartenZiel? _vorschlag;

  /// Gewähltes, noch nicht bestätigtes Ziel („Das ist endgültig“).
  KartenZiel? get vorschlag => _vorschlag;

  /// Handlung an einem Hotspot oder einer Person (Kanon-Kennung).
  bool schlageVorAn(String kennung) {
    if (laufendeEntscheidung == null || _letzterFund != null) return false;
    final z = karte.zielFuer(spiel, kennung);
    if (z == null) return false;
    _vorschlag = z;
    notifyListeners();
    return true;
  }

  /// Vorschlag über die Option (Liste statt Karte).
  void schlageVor(String optionId) {
    final z = karte.ziele[optionId];
    if (z == null || z.entscheidung != laufendeEntscheidung?.id || _letzterFund != null) {
      throw ArgumentError('$optionId gehört nicht zur laufenden Entscheidung');
    }
    _vorschlag = z;
    notifyListeners();
  }

  void verwerfen() {
    _vorschlag = null;
    notifyListeners();
  }

  /// Endgültige Auswahl. Digital beginnt jetzt erst der sichtbare Laufweg;
  /// weder Fundtext noch die nächste Entscheidung sind bereits freigegeben.
  void bestaetigen({bool gruendlich = false, String? karte}) {
    final z = _vorschlag ?? (throw StateError('kein Vorschlag'));
    if (mitWuerfel) {
      _partie.waehle(z.option, gruendlich: gruendlich, karte: karte);
    } else {
      final funde = spiel.waehle(z.entscheidung, z.option);
      _funde[z.entscheidung] = funde;
      _letzterFund = (entscheidung: z.entscheidung, ziel: z, funde: funde);
    }
    _vorschlag = null;
    _zugGeaendert();
  }

  /// Rückruf der sichtbaren Kartenaktion, nie ein Timer des Bildschirms.
  bool aktionFertig(int nummer) {
    if (!mitWuerfel || !_partie.aktionFertig(nummer)) return false;
    _zugGeaendert();
    return true;
  }

  /// Chancen vor dem Wurf; [werkzeug] zeigt sie mit einer Werkzeug-Karte (+1).
  ({int mod, bool garantie, bool markeWirkt, Map<Stufe, int> prozent}) wuerfelVorschau({bool marke = false, bool werkzeug = false}) =>
      _partie.vorschau(werkzeug: werkzeug, marke: marke);

  /// Wirft. [karte] (Art Werkzeug) ist die Quelle des +1 und wird mit dem Wurf verbraucht.
  void wuerfeln({bool marke = false, String? karte}) {
    _partie.wuerfeln(marke: marke, karte: karte);
    _zugGeaendert();
  }

  /// Tischruf nach Pech; [karte] (Nochmal bzw. Umweg passend zum Ruf) macht ihn kostenfrei.
  void tischruf(Tischruf ruf, {String? karte}) {
    _partie.tischruf(ruf, karte: karte);
    _zugGeaendert();
  }

  void _zugGeaendert() {
    final z = zug;
    if (z != null && z.phase == RundenZugPhase.fund && z.option != null) {
      final ziel = karte.ziele[z.option]!;
      _funde[z.id] = z.funde;
      _letzterFund = (entscheidung: z.id, ziel: ziel, funde: z.funde);
    }
    _melde();
    notifyListeners();
  }

  /// Entwickler-Hook: Der Kartenbildschirm stellt den Detektiv neben dieses
  /// Ziel (Skript für E2E-Läufe). Im Spiel bleibt er leer.
  final ValueNotifier<KartenZiel?> detektivSetzen = ValueNotifier(null);

  /// Entwickler-Hook: Der Kartenbildschirm stellt den Detektiv an diese Stelle.
  final ValueNotifier<(double, double)?> detektivAn = ValueNotifier(null);

  final Map<String, List<Aufdeckung>> _funde = {};

  /// Alle bisherigen Funde je Entscheidung (Notizbuch des Detektivs).
  Map<String, List<Aufdeckung>> get funde => Map.unmodifiable(_funde);

  ({String entscheidung, KartenZiel ziel, List<Aufdeckung> funde})? _letzterFund;

  /// Fund der zuletzt bestätigten Entscheidung, bis er gelesen ist.
  ({String entscheidung, KartenZiel ziel, List<Aufdeckung> funde})? get letzterFund => _letzterFund;

  void fundGelesen() {
    if (mitWuerfel) _partie.fundGelesen();
    _letzterFund = null;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Gruppenwahl (reihum verdeckt; nie eine Stimmenzahl)

  final Map<String, bool> _stimmen = {};

  /// Rollen, die in dieser Runde noch wählen müssen.
  List<String> get offeneWaehler => [for (final r in besetzt) if (!_stimmen.containsKey(r)) r];
  bool get alleGestimmt => phase == PartyPhase.gruppenwahl && offeneWaehler.isEmpty;

  /// Stimme der Rolle (nur in ihrer verdeckten Ansicht): A kooperativ, B nicht.
  void stimme(String rolle, {required bool kooperativ}) {
    if (phase != PartyPhase.gruppenwahl) throw StateError('keine Gruppenwahl');
    _nurVerdeckt(rolle);
    _stimmen[rolle] = kooperativ;
    _verdeckt = null;
    if (offeneWaehler.isEmpty) _auswerten();
    notifyListeners();
  }

  void _auswerten() {
    final pfad = spiel.pfad;
    final abstimmen = mitWuerfel ? _partie.abstimmen : spiel.abstimmen;
    abstimmen(
      kooperativ: [for (final e in _stimmen.entries) if (e.key != pfad && e.value) e].length,
      taeterSabotiert: _stimmen[pfad] == false,
    );
    _melde();
  }

  // ---------------------------------------------------------------------------
  // Anklage, Finale, Auflösung

  List<String> get kernverdaechtige => kanon.kernverdaechtige;

  void anklagen(String person) {
    if (mitWuerfel) {
      _partie.anklagen(person);
    } else {
      spiel.anklagen(person);
    }
    _melde();
    notifyListeners();
  }

  String? get angeklagt => spiel.angeklagt;

  bool get nachFinale => phase.index >= PartyPhase.finale.index;

  void _nurNachFinale() {
    if (!nachFinale) throw StateError('erst nach dem Finale');
  }

  /// Täter-Pfad (erst nach dem Finale).
  String get pfad {
    _nurNachFinale();
    return spiel.pfad;
  }

  // ---------------------------------------------------------------------------
  // Gespräche mit Wahl (M6): Randgespräche mit unbesetzten Zeugen auf der Karte.
  // Sie kosten keine Zeit, würfeln nicht und schreiben nie in die Wertung; ihre
  // Flags gelten nur für diesen Abend und färben das Nachspiel (R1–R12).

  /// Erzähltiefe des Abends; `aus` heißt: wie bisher, ohne Randgespräche.
  Erzaehltiefe erzaehltiefe = Erzaehltiefe.voll;

  final Set<String> _erzaehlFlags = {};
  final Set<String> _gefuehrteGespraeche = {};
  GespraechsLauf? _gespraech;

  /// Laufendes Randgespräch oder `null`.
  GespraechsLauf? get gespraech => _gespraech;

  /// Flags aus den geführten Gesprächen dieses Abends.
  Set<String> get erzaehlFlags => Set.unmodifiable(_erzaehlFlags);

  ErzaehlUmwelt get _erzaehlUmwelt => ErzaehlUmwelt(
        runde: runde.clamp(1, 3),
        flags: _erzaehlFlags,
        hatFund: _funde.values.any((f) => f.isNotEmpty),
        tiefe: erzaehltiefe,
      );

  /// Kann der Detektiv jetzt mit [figur] (Kanon-Kennung) ein Randgespräch führen?
  /// Nur mit unbesetzten Figuren, zwischen zwei Zügen auf der Karte.
  bool randgespraechMoeglich(String figur) =>
      phase == PartyPhase.entscheidungen &&
      _gespraech == null &&
      zug == null &&
      _vorschlag == null &&
      _letzterFund == null &&
      !besetzt.contains(figur) &&
      daten.erzaehlung?.offenFuer(figur, _erzaehlUmwelt, gefuehrt: _gefuehrteGespraeche) != null;

  /// Beginnt das nächste offene Randgespräch mit [figur].
  bool randgespraechBeginnen(String figur) {
    if (!randgespraechMoeglich(figur)) return false;
    final g = daten.erzaehlung!.offenFuer(figur, _erzaehlUmwelt, gefuehrt: _gefuehrteGespraeche)!;
    _gespraech = GespraechsLauf(g, _erzaehlUmwelt);
    notifyListeners();
    return true;
  }

  /// Antwortet im laufenden Randgespräch.
  void randgespraechWaehlen(Wahl w) {
    final g = _gespraech;
    if (g == null || !g.wahlen.contains(w)) return;
    g.waehle(w);
    notifyListeners();
  }

  /// Beendet das Randgespräch; seine Flags gelten ab jetzt für den Abend.
  void randgespraechBeenden() {
    final g = _gespraech;
    if (g == null) return;
    _erzaehlFlags.addAll(g.neueFlags);
    _gefuehrteGespraeche.add(g.gespraech.id);
    _gespraech = null;
    notifyListeners();
  }

  /// Nachspiel nach dem Finale: je Zeuge höchstens ein Satz (R10).
  List<Epilog> get nachspiel {
    _nurNachFinale();
    return daten.erzaehlung?.nachspiel(_erzaehlFlags, richtig: spiel.ende.richtig) ?? const [];
  }

  /// Ende des Abends (erst nach dem Finale).
  EndeRegel get ende {
    _nurNachFinale();
    return spiel.ende;
  }

  /// Gibt es zu dieser Akte eine Rückblende als Zeitraffer? Akten ohne
  /// Simulation erzählen sie nur: Text `rueckblende.<pfad>`, keine Bildszene.
  bool get hatRueckblende => kanon.hatSimulation;

  /// Rückblende des Pfads (erst nach dem Finale); nur für Akten mit [hatRueckblende].
  Rueckblende get rueckblende {
    _nurNachFinale();
    return _rueckblende ??= karte.rueckblende(spiel.pfad);
  }

  Rueckblende? _rueckblende;

  /// Uhrzeit, die die laufende Rückblende gerade zeigt (gesetzt von der Ansicht).
  /// Nur der Entwickler-Einstieg liest sie, um eine Fotostelle im Stromausfall zu treffen.
  Uhrzeit? rueckblendeZeit;
}
