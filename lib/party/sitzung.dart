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
  PartySitzung(this.daten, {WuerfelQuelle? wuerfel}) {
    // Das Salz ist unabhängig von Fall-Code, Pfad, Besetzung und Optionswahl.
    // Random.secure liefert nur das Salz; sämtliche Augen kommen aus SalzWuerfel.
    final zufall = math.Random.secure();
    final salz = List.generate(16, (_) => zufall.nextInt(256).toRadixString(16).padLeft(2, '0')).join();
    _partie = RundenPartie(daten.kanon, quelle: wuerfel ?? SalzWuerfel(salz), ermittlung: daten.karte.ermittlung);
  }

  final PartyDaten daten;
  late final RundenPartie _partie;
  Spiel? _druckSpiel;

  /// Lesemodell für bestehende Kanon-Ansichten. Änderungen nur über die Sitzung.
  Spiel get spiel => _druckSpiel ?? _partie.spiel;
  bool get mitWuerfel => _druckSpiel == null;
  RundenZug? get zug => mitWuerfel ? _partie.zug : null;
  int get restMinuten => _partie.restMinuten;
  int get reserveMinuten => _partie.reserveMinuten;
  int get marken => _partie.marken;
  List<Wurf> get wuerfe => _partie.wuerfe;

  /// Würfelpate wechselt mit jedem Wurf; Rollen haben keinen Einfluss auf die Augen.
  String get wuerfelPate => spielerName(besetzt[wuerfe.length % besetzt.length]);

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

  // ---------------------------------------------------------------------------
  // Figuren

  Map<String, Object?> figur(String id) => kanon.figur(id) ?? (throw ArgumentError('unbekannte Figur $id'));
  String figurName(String id) => figur(id)['name'] as String;
  String figurTitel(String id) => (figur(id)['roleTitle'] ?? figur(id)['title'] ?? '') as String;
  Color figurFarbe(String id) => Color(int.parse((figur(id)['colorCode'] as String).substring(1), radix: 16) | 0xFF000000);

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
    int rundendauerMinuten = 30,
    Map<String, String> namen = const {},
    String geburtstagskind = '',
  }) {
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
    if (_verdeckt != rolle && !nachFinale) throw StateError('nur in der verdeckten Ansicht von $rolle');
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

  // ---------------------------------------------------------------------------
  // Ablauf

  /// Kann der Abend zum nächsten Abschnitt?
  bool get kannWeiter => mitWuerfel ? _partie.kannWeiter && _vorschlag == null : switch (phase) {
        PartyPhase.titel => true,
        PartyPhase.einrichtung => false,
        PartyPhase.entscheidungen => karte.laufend(spiel) == null && _vorschlag == null && _letzterFund == null,
        PartyPhase.gruppenwahl => spiel.qualitaeten.containsKey(runde),
        PartyPhase.anklage => spiel.angeklagt != null,
        PartyPhase.ende => false,
        _ => true,
      };

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
    if (phase == PartyPhase.gruppenwahl) _stimmen.clear();
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
  void bestaetigen({bool gruendlich = false}) {
    final z = _vorschlag ?? (throw StateError('kein Vorschlag'));
    if (mitWuerfel) {
      _partie.waehle(z.option, gruendlich: gruendlich);
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

  ({int mod, bool garantie, bool markeWirkt, Map<Stufe, int> prozent}) wuerfelVorschau({bool marke = false}) =>
      _partie.vorschau(marke: marke);

  void wuerfeln({bool marke = false}) {
    _partie.wuerfeln(marke: marke);
    _zugGeaendert();
  }

  void tischruf(Tischruf ruf) {
    _partie.tischruf(ruf);
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

  /// Ende des Abends (erst nach dem Finale).
  EndeRegel get ende {
    _nurNachFinale();
    return spiel.ende;
  }

  /// Rückblende des Pfads (erst nach dem Finale).
  Rueckblende get rueckblende {
    _nurNachFinale();
    return _rueckblende ??= karte.rueckblende(spiel.pfad);
  }

  Rueckblende? _rueckblende;

  /// Uhrzeit, die die laufende Rückblende gerade zeigt (gesetzt von der Ansicht).
  /// Nur der Entwickler-Einstieg liest sie, um eine Fotostelle im Stromausfall zu treffen.
  Uhrzeit? rueckblendeZeit;
}
