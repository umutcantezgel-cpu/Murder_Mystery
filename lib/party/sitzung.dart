import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:mordakte_core/mordakte_core.dart';
import 'package:mordakte_core/runden.dart';

import 'daten.dart';
import 'erzaehler_begleitung.dart';
import 'runden_texte.dart';
import 'stand/befragung_stand.dart';

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
      if (vorrat != null || abstecher.isNotEmpty) {
        _merke('karten', {'vorrat': [for (final k in vorrat?.karten ?? const <KartenDef>[]) k.id], 'abstecher': [for (final a in abstecher) a.id]});
      }
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
    _merke('karten', {'vorrat': [for (final k in vorrat?.karten ?? const <KartenDef>[]) k.id], 'abstecher': [for (final a in abstecher) a.id]});
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
    _merke('karte', {'id': id});
    _melde();
    notifyListeners();
    return k;
  }

  /// Erkundungsorte dieser Akte (auch bereits besuchte).
  List<AbstecherOrt> get abstecherOrte => _partie.abstecherOrte;

  /// Erkundungsorte, die jetzt besucht werden dürfen (ohne laufenden Zug und
  /// ohne offenes Randgespräch).
  List<AbstecherOrt> get abstecherOffen => mitWuerfel && _gespraech == null ? _partie.abstecherOffen : const [];

  /// Ergebnis je besuchtem Erkundungsort.
  Map<String, Stufe> get abstecherErgebnis => Map.unmodifiable(_partie.abstecherErgebnis);

  /// Gelungene Erkundungen (Erfolg oder Teilerfolg), Quelle der Kartenfunde.
  Set<String> get abstecherFunde => _partie.abstecherFunde;

  /// Beginnt eine Erkundung: sichtbarer Weg, dann Würfelbühne, dann der Nebenfund.
  /// Mit [karte] (Art Abstecher) kostet der Gang keine Nachtminuten.
  void starteAbstecher(String id, {String? karte}) {
    if (!mitWuerfel) throw StateError('Abstecher gibt es nur mit Würfeln.');
    if (_gespraech != null) throw StateError('Erst das Randgespräch beenden.');
    _partie.starteAbstecher(id, karte: karte);
    _merke('abstecher', {'id': id, 'karte': karte});
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

  /// Samen der Welt des langen Abends (M7b): kosmetischer Zufall auf den
  /// Welt-Ebenen (Erkundung, Wege, Wetter) zieht nur aus
  /// `Rng(Rng.hashString('lang:$weltSamen:…'))`. Er kommt aus dem Salz des
  /// Abends wie [abendId], berührt den Würfelstrom ([SalzWuerfel]) nie und ist
  /// an einem Gerät, nach dem Fortsetzen und online beim Gastgeber (gleiches
  /// Salz des Raums) derselbe. Er verrät das Salz nicht und geht nie an Gäste.
  int get weltSamen => Rng.hashString('welt:$_salz');

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
  String get wuerfelPate => solo ? personAmTisch(Besetzung.detektiv) : spielerName(wuerfelRolle!);

  /// Rolle der Person, die als Nächste würfelt (reihum der Reihe nach); im Solo
  /// würfelt der Detektiv (`null`).
  String? get wuerfelRolle => solo ? null : besetzt[wuerfe.length % besetzt.length];

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
  // Sitze und Vorleser (Langer Abend M3)

  /// Liest dieses Gerät die Erzähltexte vor? An einem Gerät ja (mit einem
  /// Erzähler am Tisch über das verdeckte Pult, [erzaehlerAmPult]), außer der
  /// Erzähler liest am eigenen Handy mit ([begleitung]); ab dem Finale lesen
  /// alle. Online nur der Vorleser-Sitz des Raums. Wer nicht vorliest, sieht
  /// nur, dass gerade vorgelesen wird (`ErzaehlerFeld`).
  bool get istVorleser => nachFinale || !(_begleitung?.liest ?? false);

  /// Name dessen, der gerade vorliest, wenn es nicht dieses Gerät ist; sonst
  /// leer. Liest der Erzähler am Handy, der Name, mit dem er beigetreten ist:
  /// So sieht der Tisch, wer wirklich liest ([ErzaehlerBegleitung.name]).
  String get vorleserName {
    if (istVorleser) return '';
    final amHandy = _begleitung?.name.trim() ?? '';
    return amHandy.isNotEmpty ? amHandy : erzaehlerName;
  }

  ErzaehlerBegleitung? _begleitung;

  /// Erzähler-Begleiter (nur reihum mit Erzähler am Tisch): Das Gerät öffnet
  /// einen Raum nur mit dem Erzählersitz, der Erzähler liest am eigenen Handy.
  /// Gehört dem Bildschirm des Abends, der ihn auch entsorgt; liegt nie im Journal.
  ErzaehlerBegleitung? get begleitung => _begleitung;

  set begleitung(ErzaehlerBegleitung? b) {
    if (identical(b, _begleitung)) return;
    _begleitung?.removeListener(_begleitungGeaendert);
    _begleitung = b;
    b?.addListener(_begleitungGeaendert);
  }

  void _begleitungGeaendert() => notifyListeners();

  /// Darf dieses Gerät „Weiter“ drücken? An einem Gerät immer; online nur, wer
  /// gerade leitet (der Erzähler, sonst der Detektiv, sonst der Gastgeber).
  bool get leitet => true;

  /// Ist der Abschnitt fertig, egal welches Gerät weiterführt? An einem Gerät
  /// dasselbe wie [kannWeiter].
  bool get abschnittFertig => kannWeiter;

  /// Läuft gerade die Frist, bevor dieses Gerät für einen getrennten Erzähler
  /// übernimmt (online, zwei Minuten)? Bis dahin liest und leitet es noch nicht.
  bool get uebernahmeFrist => false;

  /// Führt dieses Gerät den Detektiv? An einem Gerät immer; online nur der
  /// Detektiv-Sitz oder wer ihn vertritt. Nur dort liegen Detektivkarte,
  /// Klassenwirkung und Klassen-Belohnung.
  bool get detektivAmGeraet => true;

  /// Klasse des Detektiv-Sitzes, wenn der Abend sie festlegt (online: der Raum,
  /// die Klasse reist mit dem Sitz); `null`: die Ausrüstung dieses Geräts.
  String? get detektivKlasse => null;

  /// Sitzt an einem Gerät ein Erzähler mit am Tisch ([erzaehlerName])? Dann
  /// liegen die Erzähltexte vor dem Finale im verdeckten Erzählerpult: Das Gerät
  /// geht an den Erzähler, nur er schaut hin (Muster [zeigeVerdeckt]). Die
  /// Auflösung lesen danach alle. Solo und Akten ohne Erzähler-Sitz nie.
  bool get erzaehlerAmPult => !online && !solo && erzaehlerName.isNotEmpty && daten.mitErzaehlerSitz && !nachFinale;

  bool _pult = false;

  /// Ist das Erzählerpult offen (nur der Erzähler schaut hin)?
  bool get pultOffen => _pult && erzaehlerAmPult;

  /// „Ich bin der Erzähler, zeig her“: öffnet das Pult mit den Texten dieses Schritts.
  void pultZeigen() {
    if (!erzaehlerAmPult) throw StateError('Kein Erzähler am Tisch');
    _pult = true;
    notifyListeners();
  }

  /// Pult zudecken; der Bildschirm ist wieder neutral.
  void pultSchliessen() {
    if (!_pult) return;
    _pult = false;
    notifyListeners();
  }

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

  /// Name des Detektivs am Tisch (leer: „Detektiv“ der Akte).
  String detektivName = '';

  /// Früherer Name von [detektivName] (vor Langer Abend M3).
  @Deprecated('detektivName')
  String get geburtstagskind => detektivName;
  @Deprecated('detektivName')
  set geburtstagskind(String wert) => detektivName = wert;

  /// Name des Erzählers beim Spiel an einem Gerät (Langer Abend M3); leer heißt:
  /// kein Erzähler, das Gerät zeigt die Texte offen wie bisher. Nie im Solo und
  /// nur in Akten mit Erzähler-Sitz ([PartyDaten.mitErzaehlerSitz]).
  String erzaehlerName = '';

  /// Erzähler-Stimme an (lokal, abschaltbar).
  bool get stimmeAn => _stimmeAn;
  set stimmeAn(bool wert) {
    _stimmeAn = wert;
    _merke('stimmeAn', {'wert': wert});
  }

  bool _stimmeAn = false;

  /// Rundendauer; im Entwickler-Einstieg auch in Sekunden.
  Duration rundendauer = const Duration(minutes: 30);

  // ---------------------------------------------------------------------------
  // Fassung (Langer Abend M7b)

  Abendfassung _fassung = Abendfassung.kurz;

  /// Kurzer oder langer Abend ([einrichten]); nur Akten mit dem Zusatz
  /// `langfassung` können lang sein. Die Fassung ändert nie Fall, Wertung,
  /// Würfe oder Nachtminuten, nur Zeit und Darstellung: Lang deckt die
  /// Rundenuhr den ganzen Streifzug ab ([uhrInPhase]).
  Abendfassung get fassung => _fassung;

  /// Online übernimmt die Sitzung des Gastgebers die Fassung des Raums.
  @protected
  set fassung(Abendfassung f) {
    if (f.istLang && !daten.hat('langfassung')) throw ArgumentError('Diese Akte hat keinen langen Abend');
    _fassung = f;
  }

  /// Läuft der lange Abend?
  bool get lang => _fassung.istLang;

  // ---------------------------------------------------------------------------
  // Rundenuhr und Diashow (Langer Abend M4)

  /// Uhr des Abends in Millisekunden ([RundenUhr]): an einem Gerät seine
  /// Wanduhr, online die des Gastgebers (dieselbe, mit der der Transport jeden
  /// Befehl stempelt). Tests setzen eine eigene.
  int Function() abendzeit = () => DateTime.now().millisecondsSinceEpoch;

  /// Uhr der laufenden Gespräche, sobald jemand sie gestellt hat; sonst steht
  /// sie auf der vollen [rundendauer]. Mit jeder Runde wieder gestellt; nicht im
  /// Journal: Nach dem Fortsetzen steht die Uhr wieder auf voller Zeit.
  RundenUhr? _uhr;

  /// Die gemeinsame Rundenuhr der Gespräche. An einem Gerät hält sie die
  /// Sitzung, online der Raum (`GastgeberSitzung`); jedes Gerät rechnet die
  /// Restzeit selbst aus [abendzeit]. Im langen Abend ist es die Uhr des ganzen
  /// Streifzugs: Sie wird beim Eintritt in die Gespräche gestellt und läuft in
  /// den Entscheidungen derselben Runde weiter ([uhrInPhase]).
  RundenUhr get uhr => _uhr ?? RundenUhr.neu(rundendauer.inMilliseconds.clamp(1000, RundenUhr.hoechstDauer));

  /// Gehört die Rundenuhr zur laufenden Phase? Kurz nur in den Gesprächen
  /// (wie bisher), lang im ganzen Streifzug: Gespräche und Entscheidungen
  /// einer Runde teilen sich eine Uhr. Der Streifzug-Bildschirm zeigt sie dann
  /// in beiden Phasen ([SitzungsUhr]).
  bool get uhrInPhase => phase == PartyPhase.gespraeche || (lang && phase == PartyPhase.entscheidungen);

  /// Stellt dieses Gerät die Uhr? An einem Gerät immer; online nur, wer leitet.
  bool get uhrSteuerbar => leitet;

  /// Wer die Uhr stellt, wenn es nicht dieses Gerät ist (online); sonst leer.
  String get uhrStellerName => '';

  /// Start, Pause, Weiter oder Zugabe ([minuten]) an der Uhr, zur Abendzeit
  /// [zeit] (ohne Angabe jetzt). `false`, wenn die Aktion gerade nicht passt.
  bool uhrAktion(UhrAktion aktion, {int? minuten, int? zeit}) {
    try {
      _uhr = uhr.aktion(aktion, zeit: zeit ?? abendzeit(), minuten: minuten);
    } on StateError {
      return false;
    } on ArgumentError {
      return false;
    }
    notifyListeners();
    return true;
  }

  /// Diashow zur Einleitung der Akte (`daten.diashow`), sonst `null`.
  Diashow? get diashow => daten.diashow;

  int _dia = 0;

  /// Laufendes Bild der Diashow in der Einleitung (ab 0). An einem Gerät hält
  /// es die Sitzung, online der Raum.
  int get dia => _dia;

  /// Schaltet dieses Gerät die Bilder? An einem Gerät immer; online nur, wer leitet.
  bool get diaSteuerbar => leitet;

  /// Zeigt Bild [nr] der Diashow (nur in der Einleitung, nur gültige Bilder).
  void diaSetzen(int nr) {
    final d = diashow;
    if (d == null || phase != PartyPhase.intro || nr < 0 || nr >= d.dias.length || nr == _dia) return;
    _dia = nr;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Vorspiel und Morgen (Langer Abend M7b)

  /// Vorspiel und Morgen der Akte ([PartyDaten.vorspielMorgen]), nur im langen
  /// Abend; sonst `null`, und kurze Abende bleiben, wie sie waren.
  VorspielMorgen? get vorspielMorgen => lang ? daten.vorspielMorgen : null;

  /// Rundgänge, die an diesem Abend fertig sind (zu Ende gegangen oder übersprungen).
  final Set<RundgangTeil> _rundgangFertig = {};
  int _rundgangStation = 0;

  /// Der laufende Rundgang: das Vorspiel in der Einleitung, bevor die Diashow
  /// kommt, und der Morgen im Ende, bevor das Schlussbild kommt. Die Phasen
  /// bleiben dabei, wie sie sind (`PARTY phase=`); der Rundgang ist ein
  /// Unterzustand. `null` ohne Rundgang (kurzer Abend, Akte ohne Inhalt) und
  /// sobald er fertig ist.
  RundgangTeil? get rundgang {
    final teil = switch (phase) {
      PartyPhase.intro => RundgangTeil.vorspiel,
      PartyPhase.ende => RundgangTeil.morgen,
      _ => null,
    };
    if (teil == null || vorspielMorgen == null || _rundgangFertig.contains(teil)) return null;
    return teil;
  }

  /// Station des laufenden Rundgangs (ab 0). An einem Gerät hält sie die
  /// Sitzung, online der Raum.
  int get rundgangStation => _rundgangStation;

  /// Stationen des laufenden Rundgangs (leer ohne Rundgang).
  List<RundgangStation> get rundgangStationen {
    final teil = rundgang;
    final v = vorspielMorgen;
    return teil == null || v == null ? const [] : v.rundgang(teil).stationen;
  }

  /// Die laufende Station, sonst `null`.
  RundgangStation? get rundgangAktuell {
    final stationen = rundgangStationen;
    return stationen.isEmpty ? null : stationen[rundgangStation.clamp(0, stationen.length - 1)];
  }

  /// Karte und Vorlesetext der laufenden Station; am Morgen zum gezogenen Ende.
  RundgangText? get rundgangText => rundgangAktuell?.textFuer(phase == PartyPhase.ende ? spiel.ende.id : null);

  /// Führt dieses Gerät durch den Rundgang? An einem Gerät immer; online, wer leitet.
  bool get rundgangSteuerbar => leitet;

  /// Zur nächsten Station; nach der letzten ist der Rundgang fertig, und es
  /// geht zur Diashow (Vorspiel) bzw. zum Schlussbild (Morgen). Nichts davon
  /// berührt Partie, Würfel, Nachtminuten, Punkte oder Ende. Das Journal merkt
  /// den Schritt; es gibt ihn nur im langen Abend.
  void rundgangWeiter() {
    final teil = rundgang ?? (throw StateError('Gerade läuft kein Rundgang.'));
    final station = _rundgangStation;
    if (station + 1 >= rundgangStationen.length) {
      _rundgangFertig.add(teil);
    } else {
      _rundgangStation = station + 1;
    }
    _merke('rundgang', {'station': station});
    notifyListeners();
  }

  /// Überspringt den Rest des laufenden Rundgangs.
  void rundgangUeberspringen() {
    final teil = rundgang ?? (throw StateError('Gerade läuft kein Rundgang.'));
    _rundgangFertig.add(teil);
    _merke('rundgang', {'ueberspringen': true});
    notifyListeners();
  }

  /// Spielsekunden je echter Sekunde in der Rückblende.
  double zeitraffer = 25;

  FallCode? _code;
  FallCode get fallCode => _code ?? (throw StateError('Spiel ist noch nicht eingerichtet'));

  /// Ein neuer zufälliger Fall-Code.
  static FallCode zufallsCode([int? seed]) => FallCode.zufall(Rng(seed ?? DateTime.now().microsecondsSinceEpoch ^ math.Random().nextInt(1 << 30)));

  /// Titel → Einrichtung.
  void zurEinrichtung() {
    if (phase != PartyPhase.titel) return;
    _weiter();
    _merke('titel');
  }

  /// Einrichtung abschließen. [code] leer oder ungültig heißt: Zufall.
  /// [erzaehlerName] (an einem Gerät, optional) setzt einen Erzähler an den
  /// Tisch; im Solo gibt es keinen. [geburtstagskind] ist der frühere Name von
  /// [detektivName] und gilt nur, wenn dieser fehlt. [fassung] lang gibt es nur
  /// in Akten mit dem Zusatz `langfassung` und nicht im Druckspiel; das Journal
  /// merkt sie nur bei lang, kurze Abende bleiben bytegleich.
  void einrichten({
    required int rollen,
    required String detektiv,
    String? code,
    bool druck = false,
    bool solo = false,
    int rundendauerMinuten = 30,
    Map<String, String> namen = const {},
    String detektivName = '',
    String erzaehlerName = '',
    Abendfassung fassung = Abendfassung.kurz,
    @Deprecated('detektivName') String? geburtstagskind,
  }) {
    if (solo && druck) throw ArgumentError('Solo ist kein Druckspiel');
    if (fassung.istLang && !daten.hat('langfassung')) throw ArgumentError('Diese Akte hat keinen langen Abend');
    if (fassung.istLang && druck) throw ArgumentError('Das Druckspiel ist ein kurzer Abend');
    if (solo && erzaehlerName.trim().isNotEmpty) throw ArgumentError('Im Solo gibt es keinen Erzähler');
    if (erzaehlerName.trim().isNotEmpty && !daten.mitErzaehlerSitz) throw ArgumentError('Diese Akte hat keinen Erzähler-Sitz');
    final detektivname = detektivName.trim().isEmpty ? (geburtstagskind ?? '') : detektivName;
    if (phase == PartyPhase.titel) _weiter();
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
    // Modell befragung (A-051): Der Detektiv führt eigene Befragungen. Im Druckspiel stehen sie auf
    // seinem Bogen; die App zeigt sie dann nur ([befragungAufPapier]).
    _befragung = befragungsmodell ? BefragungStand(daten.texte, rollen: rollen, mensch: !solo) : null;
    _erzaehlFlags.clear();
    _gefuehrteGespraeche.clear();
    _gespraech = null;
    this.namen
      ..clear()
      ..addAll({for (final r in besetzt) if (namen[r] != null) r: namen[r]!});
    this.detektivName = detektivname;
    this.erzaehlerName = erzaehlerName.trim();
    _pult = false;
    rundendauer = Duration(minutes: rundendauerMinuten);
    _fassung = fassung;
    _merke('einrichten', {
      'rollen': rollen,
      'detektiv': detektiv,
      'code': c.code,
      'druck': druck,
      'solo': solo,
      'minuten': rundendauerMinuten,
      'namen': {...this.namen},
      'detektivName': detektivname,
      if (this.erzaehlerName.isNotEmpty) 'erzaehler': this.erzaehlerName,
      // Nur der lange Abend steht im Journal; kurze Abende bleiben bytegleich wie vor M7b.
      if (fassung.istLang) 'fassung': fassung.name,
    });
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
    _merke('zeigen', {'rolle': rolle});
    notifyListeners();
  }

  /// Ansicht schließen; der Bildschirm ist danach wieder neutral.
  void verdecken() {
    _verdeckt = null;
    _merke('verdecken');
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
      ? (detektivName.trim().isEmpty ? ui('ui.allgemein.detektiv') : detektivName.trim())
      : spielerName(id);

  final Map<int, List<BotGespraech>> _soloGespraeche = {};
  final Set<String> _soloGelesen = {};

  /// Nur öffentliche Sprechblasen der aktuellen Runde, keine künftigen Texte.
  /// Nur im Modell legacy; im Modell befragung antworten die Bots auf Fragen ([befragungen]).
  List<BotGespraech> get soloGespraeche => !solo || runde < 1 || befragungsmodell ? const [] : _soloGespraeche.putIfAbsent(
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
    if (_soloGelesen.add(id)) {
      _merke('gelesen', {'id': id});
      notifyListeners();
    }
  }

  // ---------------------------------------------------------------------------
  // Befragungen (A-051, Modell befragung): Der Detektiv befragt je Runde drei bis
  // fünf Rollen, feste und frei gewählte. Er sieht Thema und Fragen; antwortet
  // die App (Solo), kommt die Antwort erst nach der Frage. Reihum antwortet die
  // Person am Tisch aus ihrem verdeckten Spickzettel.

  /// Hat diese Akte das Gesprächsmodell befragung?
  bool get befragungsmodell => daten.texte.besetzung.befragungsmodell;

  BefragungStand? _befragung;

  /// Befragungskarten der laufenden Runde (leer ohne Modell befragung und außerhalb der Runden).
  List<BefragungKarte> get befragungen => _befragung == null || runde < 1 ? const [] : _befragung!.karten(runde);

  /// Freie Wahlen, die in dieser Runde noch offen sind.
  int get befragungenFrei => _befragung == null || runde < 1 ? 0 : _befragung!.freiOffen(runde);

  /// Druckspiel im Modell befragung: Die Befragungen stehen auf dem Bogen des
  /// Detektivs. Die App zeigt sie nur zum Lesen, und „Weiter“ wartet nicht.
  bool get befragungAufPapier => _befragung != null && einstellungen.druck;

  /// Sind alle Befragungen der Runde geführt? Erst dann geht es aus den Gesprächen weiter.
  bool get befragungenFertig => _befragung == null || runde < 1 || befragungAufPapier || _befragung!.fertig(runde);

  void _nurBefragung() {
    if (_befragung == null || befragungAufPapier || phase != PartyPhase.gespraeche) throw StateError('keine Befragung in diesem Abschnitt');
  }

  /// Der Detektiv stellt die Frage [frage] der Befragung [id]. Eine freie
  /// Befragung ist damit gewählt; im Solo ist sie erledigt, reihum erst nach
  /// [befragungErledigt].
  void befragen(String id, int frage) {
    _nurBefragung();
    _befragung!.befragen(runde, id, frage);
    _merke('befragt', {'id': id, 'frage': frage});
    notifyListeners();
  }

  /// Die befragte Person hat am Tisch geantwortet.
  void befragungErledigt(String id) {
    _nurBefragung();
    if (_befragung!.verlauf.erledigt(id)) return;
    _befragung!.erledigen(runde, id);
    _merke('befragtFertig', {'id': id});
    notifyListeners();
  }

  /// Antworten, die die App bisher gegeben hat (Notizbuch des Solo-Detektivs).
  List<BefragungKarte> get befragungsNotizen => List.unmodifiable(_befragung?.aufgedeckt ?? const <BefragungKarte>[]);

  /// Modell befragung (E-044): Das Wissen unbesetzter Gäste spricht der Erzähler
  /// nur zum Rundenstart; das Erzählerfenster trägt es danach nicht mehr. Damit
  /// der Detektiv es bei den Entscheidungen nachlesen kann, wie eine Antwort aus
  /// einer Befragung, bleibt es im Notizbuch: die npc-Bausteine dieses Abends in
  /// der Reihenfolge, in der der Erzähler sie sprach. Sie hängen nur an Runde und
  /// Besetzung (S-1) und entstehen beim Fortsetzen und online mit der Partie neu.
  List<String> get erzaehlerNotizen => !befragungsmodell ? const [] : List.unmodifiable({
        for (final k in spiel.bausteine) if (k.startsWith('npc.')) k,
      });

  /// Die Tischgespräche der Runde [r]: nur Paarung und Thema.
  List<TischPaarung> tisch(int r) => tischPaarungen(daten.texte, n: einstellungen.rollen, runde: r);

  /// Die Befragungskarte von [rolle] in dieser Runde (öffentlich: Thema, Stand), sonst null.
  BefragungKarte? befragungVon(String rolle) {
    for (final k in befragungen) {
      if (k.rolle == rolle) return k;
    }
    return null;
  }

  /// Ist die Befragung von [rolle] in Runde [r] fest? Null ohne Befragungen an diesem Gerät (online, Altakte).
  bool? befragungFest(String rolle, int r) => _befragung?.verlauf.runde(r).pflicht.contains(rolle);

  /// Spickzettel der Befragung von [rolle] in Runde [r] (nur verdeckt): was sie dem Detektiv sagt.
  BefragungsZettel spickzettel(String rolle, int r) {
    _nurVerdeckt(rolle);
    final b = daten.texte.sammlung.befragungen[BefragungText.kennung(rolle, r)] ?? (throw StateError('keine Befragung von $rolle'));
    return befragungsZettel(daten.texte, b);
  }

  // ---------------------------------------------------------------------------
  // Ablauf

  /// Kann der Abend zum nächsten Abschnitt? Solo-Wissen kommt vor der Wahl;
  /// eine Uhr oder eine verdeckte Bot-Karte kann diese Schranke nicht umgehen.
  bool get kannWeiter {
    // Ein offenes Randgespräch endet erst mit „Gespräch beenden“.
    if (_gespraech != null) return false;
    // Erst das Vorspiel, dann die Einleitung (langer Abend, M7b).
    if (rundgang != null) return false;
    if (solo && phase == PartyPhase.gespraeche && soloGespraeche.any((g) => !_soloGelesen.contains(g.id))) return false;
    if (phase == PartyPhase.gespraeche && !befragungenFertig) return false;
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
    _merke('weiter');
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
    // Neue Texte liegen wieder zugedeckt im Pult, bis der Erzähler hinschaut.
    _pult = false;
    // Jede Einleitung beginnt mit dem ersten Bild, jede Runde mit gestellter Uhr.
    // Im langen Abend läuft dieselbe Uhr in den Entscheidungen weiter ([uhrInPhase]).
    _dia = 0;
    _rundgangStation = 0;
    if (phase == PartyPhase.gespraeche) _uhr = null;
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
    _merke('an', {'kennung': kennung});
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
    _merke('vor', {'option': optionId});
    notifyListeners();
  }

  void verwerfen() {
    _vorschlag = null;
    _merke('verwerfen');
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
    _merke('bestaetigen', {'gruendlich': gruendlich, 'karte': karte});
    _zugGeaendert();
  }

  /// Rückruf der sichtbaren Kartenaktion, nie ein Timer des Bildschirms.
  bool aktionFertig(int nummer) {
    if (!mitWuerfel || !_partie.aktionFertig(nummer)) return false;
    _merke('aktion', {'nummer': nummer});
    _zugGeaendert();
    return true;
  }

  /// Chancen vor dem Wurf; [werkzeug] zeigt sie mit einer Werkzeug-Karte (+1).
  ({int mod, bool garantie, bool markeWirkt, Map<Stufe, int> prozent}) wuerfelVorschau({bool marke = false, bool werkzeug = false}) =>
      _partie.vorschau(werkzeug: werkzeug, marke: marke);

  /// Wirft. [karte] (Art Werkzeug) ist die Quelle des +1 und wird mit dem Wurf verbraucht.
  void wuerfeln({bool marke = false, String? karte}) {
    _partie.wuerfeln(marke: marke, karte: karte);
    _merke('wurf', {'marke': marke, 'karte': karte});
    _zugGeaendert();
  }

  /// Tischruf nach Pech; [karte] (Nochmal bzw. Umweg passend zum Ruf) macht ihn kostenfrei.
  void tischruf(Tischruf ruf, {String? karte}) {
    _partie.tischruf(ruf, karte: karte);
    _merke('ruf', {'ruf': ruf.name, 'karte': karte});
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
    _merke('fund');
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
    _merke('stimme', {'rolle': rolle, 'kooperativ': kooperativ});
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
    _merke('anklage', {'person': person});
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
  // Abendstand (M8): jeder Schritt als Befehl, damit ein Abend nach dem Neuladen
  // weitergeht. Würfel und Bots hängen am Salz; dieselben Befehle mit demselben
  // Salz ergeben denselben Abend.

  final List<Map<String, Object?>> _befehle = [];

  void _merke(String befehl, [Map<String, Object?> werte = const {}]) => _befehle.add({'b': befehl, ...werte});

  /// Formatversion des Abendstands. Version 2 (A-051): Befragungen als Befehle
  /// `befragt` und `befragtFertig`; ein Stand der Version 1 einer Akte mit dem
  /// Modell befragung stammt aus der alten Fassung und wird verworfen.
  static const abendstandFormat = 'abendstand/2';

  /// Formate, die [fortsetzen] noch liest.
  static const abendstandFormate = {'abendstand/1', abendstandFormat};

  /// Der Abend zum Ablegen (JSON): Akte, Salz und alle Befehle seit dem Anlegen.
  Map<String, Object?> get abendstand => {
        'format': abendstandFormat,
        'fall': daten.fall,
        'salz': _salz,
        'titel': kanon.fall['titel'],
        'phase': phase.name,
        'runde': runde,
        'befehle': [for (final b in _befehle) {...b}],
      };

  /// Baut einen abgelegten Abend wieder auf: neue Sitzung mit demselben Salz,
  /// alle Befehle der Reihe nach. Das Deck kommt aus [katalog], die
  /// Erkundungsorte aus [abstecher] (beides wie beim Anlegen). Eine offene
  /// verdeckte Ansicht wird geschlossen: Das Gerät liegt danach vielleicht in
  /// anderen Händen. Wirft [FormatException], wenn der Stand nicht passt.
  static PartySitzung fortsetzen(
    PartyDaten daten,
    Map<String, Object?> stand, {
    KartenKatalog? katalog,
    List<AbstecherOrt> abstecher = const [],
  }) {
    if (!abendstandFormate.contains(stand['format']) || stand['fall'] != daten.fall || stand['salz'] is! String) {
      throw const FormatException('Abendstand passt nicht zur Akte');
    }
    // Vor dem Modell befragung kannte der Schlosskeller drei Pflichtgespräche je Rolle.
    if (stand['format'] == 'abendstand/1' && daten.texte.besetzung.befragungsmodell) throw const AbendstandVeraltet();
    final s = PartySitzung(daten, salz: stand['salz'] as String);
    try {
      for (final b in stand['befehle'] as List) {
        s._spiele((b as Map).cast<String, Object?>(), katalog: katalog, abstecher: abstecher);
      }
    } catch (e) {
      s.dispose();
      throw FormatException('Abendstand nicht abspielbar: $e');
    }
    if (s.verdeckt != null) s.verdecken();
    return s;
  }

  void _spiele(Map<String, Object?> b, {KartenKatalog? katalog, List<AbstecherOrt> abstecher = const []}) {
    String? text(String k) => b[k] as String?;
    switch (b['b']) {
      case 'karten':
        final vorrat = [for (final id in b['vorrat'] as List) id as String];
        final orte = [for (final id in b['abstecher'] as List) id as String];
        kartenAnlegen(
          vorrat: katalog == null || vorrat.isEmpty ? null : TischVorrat.aus(vorrat, katalog),
          abstecher: [for (final id in orte) abstecher.firstWhere((a) => a.id == id)],
        );
      case 'karte':
        karteSpielen(text('id')!);
      case 'abstecher':
        starteAbstecher(text('id')!, karte: text('karte'));
      case 'stimmeAn':
        stimmeAn = b['wert'] == true;
      case 'titel':
        zurEinrichtung();
      case 'einrichten':
        einrichten(
          rollen: b['rollen'] as int,
          detektiv: text('detektiv')!,
          code: text('code'),
          druck: b['druck'] == true,
          solo: b['solo'] == true,
          rundendauerMinuten: b['minuten'] as int? ?? 30,
          namen: ((b['namen'] as Map?) ?? const {}).cast<String, String>(),
          // Abende vor M3 legten den Detektivnamen unter `geburtstagskind` ab.
          detektivName: text('detektivName') ?? text('geburtstagskind') ?? '',
          erzaehlerName: text('erzaehler') ?? '',
          // Abende ohne den Schlüssel (kurz, vor M7b) bleiben kurz.
          fassung: Abendfassung.lesen(b['fassung']),
        );
      case 'zeigen':
        zeigeVerdeckt(text('rolle')!);
      case 'verdecken':
        verdecken();
      case 'gelesen':
        soloGespraechGelesen(text('id')!);
      case 'befragt':
        befragen(text('id')!, b['frage'] as int);
      case 'befragtFertig':
        befragungErledigt(text('id')!);
      case 'weiter':
        weiter();
      case 'an':
        if (!schlageVorAn(text('kennung')!)) throw StateError('Vorschlag an ${b['kennung']} nicht möglich');
      case 'vor':
        schlageVor(text('option')!);
      case 'verwerfen':
        verwerfen();
      case 'bestaetigen':
        bestaetigen(gruendlich: b['gruendlich'] == true, karte: text('karte'));
      case 'aktion':
        if (!aktionFertig(b['nummer'] as int)) throw StateError('Aktion ${b['nummer']} nicht möglich');
      case 'wurf':
        wuerfeln(marke: b['marke'] == true, karte: text('karte'));
      case 'ruf':
        tischruf(Tischruf.values.byName(text('ruf')!), karte: text('karte'));
      case 'fund':
        fundGelesen();
      case 'stimme':
        stimme(text('rolle')!, kooperativ: b['kooperativ'] == true);
      case 'anklage':
        anklagen(text('person')!);
      case 'tiefe':
        erzaehltiefe = Erzaehltiefe.values.byName(text('wert')!);
      case 'gespraech':
        if (!randgespraechBeginnen(text('figur')!)) throw StateError('Gespräch mit ${b['figur']} nicht möglich');
      case 'wahl':
        final g = _gespraech ?? (throw StateError('kein Gespräch'));
        randgespraechWaehlen(g.wahlen[b['nr'] as int]);
      case 'gespraechEnde':
        randgespraechBeenden();
      case 'rundgang':
        if (b['ueberspringen'] == true) {
          rundgangUeberspringen();
        } else {
          if (b['station'] != rundgangStation) throw StateError('Rundgang an Station ${b['station']} nicht möglich');
          rundgangWeiter();
        }
      default:
        throw FormatException('unbekannter Befehl ${b['b']}');
    }
  }

  // ---------------------------------------------------------------------------
  // Gespräche mit Wahl (M6): Randgespräche mit unbesetzten Zeugen auf der Karte.
  // Sie kosten keine Zeit, würfeln nicht und schreiben nie in die Wertung; ihre
  // Flags gelten nur für diesen Abend und färben das Nachspiel (R1–R12).

  /// Erzähltiefe des Abends; `aus` heißt: wie bisher, ohne Randgespräche.
  Erzaehltiefe get erzaehltiefe => _erzaehltiefe;
  set erzaehltiefe(Erzaehltiefe wert) {
    _erzaehltiefe = wert;
    _merke('tiefe', {'wert': wert.name});
  }

  Erzaehltiefe _erzaehltiefe = Erzaehltiefe.voll;

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
  /// Zwischen zwei Zügen auf der Karte, nie mit Kernverdächtigen. Eine Rolle,
  /// die ein Mensch spielt, spricht nicht durch die App; im Solo-Spiel spielen
  /// Bots die Rollen, dort sind alle Zeugen ansprechbar.
  bool randgespraechMoeglich(String figur) =>
      phase == PartyPhase.entscheidungen &&
      _gespraech == null &&
      zug == null &&
      _vorschlag == null &&
      _letzterFund == null &&
      !kernverdaechtige.contains(figur) &&
      (solo || !besetzt.contains(figur)) &&
      daten.erzaehlung?.offenFuer(figur, _erzaehlUmwelt, gefuehrt: _gefuehrteGespraeche) != null;

  /// Beginnt das nächste offene Randgespräch mit [figur].
  bool randgespraechBeginnen(String figur) {
    if (!randgespraechMoeglich(figur)) return false;
    final g = daten.erzaehlung!.offenFuer(figur, _erzaehlUmwelt, gefuehrt: _gefuehrteGespraeche)!;
    _gespraech = GespraechsLauf(g, _erzaehlUmwelt);
    _merke('gespraech', {'figur': figur});
    notifyListeners();
    return true;
  }

  /// Antwortet im laufenden Randgespräch.
  void randgespraechWaehlen(Wahl w) {
    final g = _gespraech;
    if (g == null || !g.wahlen.contains(w)) return;
    final nr = g.wahlen.indexOf(w);
    g.waehle(w);
    _merke('wahl', {'nr': nr});
    notifyListeners();
  }

  /// Beendet das Randgespräch; seine Flags gelten ab jetzt für den Abend.
  void randgespraechBeenden() {
    final g = _gespraech;
    if (g == null) return;
    _erzaehlFlags.addAll(g.neueFlags);
    _gefuehrteGespraeche.add(g.gespraech.id);
    _gespraech = null;
    _merke('gespraechEnde');
    randgespraechGefuehrt();
    notifyListeners();
  }

  /// Nach jedem beendeten Randgespräch. Der Online-Gastgeber legt hier den
  /// [erzaehlstand] ab; sein Abend steht im Raum, nicht im Befehlsprotokoll.
  @protected
  void randgespraechGefuehrt() {}

  /// Flags und geführte Gespräche dieses Abends (JSON).
  @protected
  Map<String, Object?> get erzaehlstand => {
        'flags': _erzaehlFlags.toList()..sort(),
        'gefuehrt': _gefuehrteGespraeche.toList()..sort(),
      };

  /// Übernimmt einen abgelegten [erzaehlstand] (Rückkehr des Online-Gastgebers).
  @protected
  void erzaehlstandUebernehmen(Map<String, Object?> stand) {
    _erzaehlFlags.addAll([for (final f in stand['flags'] as List? ?? const []) f as String]);
    _gefuehrteGespraeche.addAll([for (final g in stand['gefuehrt'] as List? ?? const []) g as String]);
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

/// Ein Abendstand aus der Fassung vor dem Modell befragung (A-051): Er lässt sich
/// nicht mehr abspielen und wird mit einem Hinweis verworfen.
class AbendstandVeraltet extends FormatException {
  // Technische Meldung (nur Protokoll); den Hinweis zeigt die Detektei aus dem ARB.
  const AbendstandVeraltet() : super('abendstand_veraltet');
}
