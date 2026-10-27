import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../party/ablauf.dart';
import '../party/befragung.dart';
import '../party/einstimmung.dart';
import '../party/entscheidungen.dart';
import '../party/erzaehler_paket.dart';
import '../party/fall_code.dart';
import '../party/fassung.dart';
import '../party/kanon/kanon.dart';
import '../party/texte.dart';
import '../karten/abstecher.dart';
import '../karten/karte.dart';
import '../karten/vorrat.dart';
import '../util/rng.dart';
import '../welt/erkundung.dart';
import '../welt/vorspiel_morgen.dart';
import 'abend_raum.dart';
import 'bots.dart';
import 'einfluss.dart' show EinflussRegeln;
import 'partie.dart';
import 'raum/befragung_modul.dart';
import 'raum/dia_modul.dart';
import 'raum/einfluss_raum.dart';
import 'raum/einstimmung_modul.dart';
import 'raum/raum_modul.dart';
import 'raum/rundgang_modul.dart';
import 'raum/sichtfelder.dart';
import 'raum/sitze_modul.dart';
import 'raum/streifzug_modul.dart';
import 'raum/uhr_modul.dart';
import 'runden_uhr.dart' show RundenUhr, abendZeitFeld;
import 'sitze.dart';
import 'wuerfel.dart';
import 'zugschicht.dart';

/// Protokollfehler mit festem Schlüssel, niemals mit fremden Rollen-/Nutzdaten.
class PartyRaumFehler implements Exception {
  final String code;
  const PartyRaumFehler(this.code);
  @override
  String toString() => 'PartyRaumFehler: $code';
}

class _Teilnehmer {
  final String id;
  String name;
  bool online = true;
  bool aufgegeben = false;
  bool bereit = false;
  bool gelesen = false;
  String? rolle;
  _Teilnehmer(this.id, this.name);
}

/// Autoritativer Schlosskeller-Abend, ohne Socket, Flutter oder lokale Uhr.
///
/// Die Identität kommt ausschließlich vom authentifizierten Transport, nie aus
/// einem Nachrichtenfeld. Rollen werden einmal beim Start zugeteilt und bleiben
/// beim Reconnect erhalten. [zustandFuer] baut für jedes Gerät eine neue,
/// ausdrückliche Positivliste: genau ein eigenes Dossier, nie alle Rollenkarten,
/// die richtige Option, Gruppenwahl-Qualität, Fall-Code oder Würfelsalz.
///
/// Sitze (`sitze.dart`, Lobby über [SitzeModul]): Ein Gerät führt den
/// Detektiv, eines liest optional als Erzähler vor; der Gastgeber sitzt auf
/// einem der beiden ([gastgeberSitz]). Alle übrigen Geräte spielen Figuren,
/// unbesetzte Rollen sind Bots. Dadurch können auch wenige verbundene Geräte
/// einen kanongültigen Abend mit mindestens vier Rollen spielen. Kapazität:
/// größte Besetzung der Akte plus Detektiv- und Erzähler-Sitz plus vier
/// Assistenz-Plätze (Schlosskeller: 26 Geräte).
///
/// Rechte: `start` und `sitz` nur der Gastgeber; Ermittlung (`wahl`,
/// `abstecher`, `tischruf`, `fundGelesen`, `karte`, `anklage`, Befragungen) nur
/// der Detektiv-Sitz, hat er aufgegeben, der Gastgeber ([ermittler]); „Weiter“
/// nur, wer gerade leitet: der Erzähler, sonst der Detektiv, sonst der
/// Gastgeber ([vorleser], [_darfLeiten]). Fällt der Detektiv-Sitz während des
/// Abends aus, vergibt ihn der Gastgeber neu (`detektivNeu`, [_detektivNeu]):
/// an sich selbst oder einen Platz ohne Figur, nie an eine Figur.
///
/// Rundenuhr und Diashow (M4): Die Gesprächszeit läuft für alle gleich
/// ([UhrModul], Dauer [rundenMinuten]); in Akten mit Diashow ([diaAnzahl])
/// zeigen alle Geräte in der Einleitung dasselbe Bild ([DiaModul]). Die
/// Abendzeit kommt nur vom Transport (Feld [abendZeitFeld] jeder Nachricht).
///
/// Fassung (M7b): Im langen Abend ([fassung], aus der Meta des Gastgebers)
/// deckt die Rundenuhr den ganzen Streifzug ab, Gespräche und Entscheidungen;
/// alle sehen öffentlich `fassung: lang`. Mit der Erkundung der Akte kommt der
/// Streifzug dazu ([StreifzugModul]: Erkundung und Treffpunkte). Mit Vorspiel
/// und Morgen der Akte (`rundgang`) laufen im langen Abend vor der Diashow das
/// Vorspiel und nach der Auflösung der Morgen ([RundgangModul]); der Abend ist
/// erst nach dem Morgen beendet. Kurze Abende tragen keinen der Schlüssel und
/// bleiben bytegleich. Partie, Würfel und Wertung kennen die Fassung nicht.
///
/// Einstimmung (A-063): Mit [einstimmung] (eingeschaltet in der Meta des
/// Gastgebers, `einstimmung: true`, nur in Akten mit Vorgeschichte) laufen zu
/// Beginn der Einleitung Vorgeschichte und Vorstellung ([EinstimmungModul]),
/// vor Vorspiel und Diashow. Ohne bleibt jede Ansicht bytegleich.
///
/// Einfluss-Schicht „Dein Moment“ (Finale §3, A-064): Mit [einfluss]
/// (eingeschaltet in der Meta des Gastgebers, `einfluss: true`, nur in Akten mit
/// der Fähigkeit) zieht in den Gesprächen jede besetzte Rolle geheim einen Zug
/// (`zug`), der Leitende kann den letzten Aufruf geben (`letzterAufruf`), nach
/// Runde 3 fragt der Detektiv nach (`nachfrage`); die Gruppenwahl entfällt
/// ([EinflussRaum]). Alle sehen öffentlich `einfluss`, jede Rolle privat
/// `moment`, der Erzähler `einflussTafel`, ab dem Finale `aufloesung.einfluss`.
/// Ohne Schicht bleibt jede Ansicht bytegleich und `zug` ist `invalid`.
///
/// Vorleser-Sitz (nur Akten mit [vorleserSitz]): Erzähltext geht vor dem
/// Finale nur an ein Gerät, an das, das leitet ([vorleser]), und zwar im
/// privaten Teil. Alle sehen öffentlich nur `erzaehlerLiest` und
/// `bausteinZahl`. Ab dem Finale sehen alle die Texte (Auflösung). Altakten
/// zeigen den Erzähltext wie vor M3 allen öffentlich.
/// Die Methodennamen entsprechen RaumSpiel; der Transportadapter bleibt separat.
///
/// Der Raum spielt jede Akte (Schlosskeller, Gewölbe, Klassiker): Rollenzahl
/// und Kennung kommen aus dem Kanon der Akte. Mehr Geräte als Rollen werden
/// Assistenz-Plätze ohne eigene Rolle (sie sehen die öffentliche Ansicht).
class SchlosskellerRaum implements AbendRaum {
  SchlosskellerRaum({
    required this.raumCode,
    required Kanon kanon,
    required Texte texte,
    required FallCode fallCode,
    required String salz,
    this.akte = 'schlosskeller',
    this.festerGastgeber = false,
    this.gastgeberSitz = Sitz.detektiv,
    KartenKatalog? katalog,
    List<AbstecherOrt> abstecher = const [],
    this.rundenMinuten = 30,
    this.diaAnzahl = 0,
    this.fassung = Abendfassung.kurz,
    Erkundung? erkundung,
    VorspielMorgen? rundgang,
    this.einstimmung,
    this.einfluss,
    List<RaumModul> module = const [],
  }) : _module = List.unmodifiable(() {
         // Einstimmung (A-063) nur, wenn eingeschaltet; das Vorspiel wartet auf sie.
         final einstimmungModul = einstimmung == null ? null : EinstimmungModul(einstimmung);
         return [
           // Die Lobby (Sitze, Rollenzahl, Figurenwahl) gehört zu jedem Raum; [_sitze] liest ihren Plan.
           SitzeModul(),
           // Das Gesprächsmodell der Akte bringt sein Modul selbst mit (A-051); Altakten bleiben ohne.
           if (texte.besetzung.befragungsmodell) BefragungModul(),
           // Die Gesprächszeit läuft für alle gleich (M4); die Diashow nur in Akten, die eine haben.
           UhrModul(minuten: rundenMinuten.clamp(1, RundenUhr.hoechstStart), lang: fassung.istLang),
           if (diaAnzahl > 0) DiaModul(anzahl: diaAnzahl),
           // Der lange Abend wird zum Streifzug (M7b): Erkundung und Treffpunkte, rein kosmetisch.
           if (fassung.istLang && erkundung != null) StreifzugModul(erkundung: erkundung, weltSamen: weltSamenAus(salz)),
           ?einstimmungModul,
           // Vorspiel und Morgen (M7b) nur im langen Abend und nur mit Inhalt der Akte.
           if (fassung.istLang && rundgang != null) RundgangModul(rundgang, wartet: einstimmungModul?.laeuft),
           ...module,
         ];
       }()), _katalog = katalog ?? KartenKatalog(const []), _abstecher = abstecher, _kanon = kanon, _texte = texte, _fallCode = fallCode, _salz = salz,
       wuerfelZusage = sha256.convert(utf8.encode(salz)).toString() {
    if (salz.isEmpty || !gastgeberSitz.vergeben) throw const PartyRaumFehler('invalid_setup');
    if (einfluss != null && einfluss!.akte != akte) throw const PartyRaumFehler('invalid_setup');
  }

  /// Kennung der Akte (Ordner unter `content/party/`).
  final String akte;

  /// Rundendauer der Einrichtung in Minuten: So lange läuft die Uhr der
  /// Gespräche nach `uhr start` ([UhrModul]).
  final int rundenMinuten;

  /// Zahl der Bilder der Diashow zur Einleitung (`party/diashow.dart`); 0 heißt:
  /// keine Diashow, die Einleitung bleibt wie bisher.
  final int diaAnzahl;

  /// Kurzer oder langer Abend (M7b). Lang lebt die Rundenuhr über Gespräche
  /// und Entscheidungen ([UhrModul.lang]); sonst ändert sie nichts am Abend.
  final Abendfassung fassung;

  /// Einstimmung der Akte (Vorgeschichte und Vorstellung, A-063), wenn sie
  /// eingeschaltet ist; sonst `null` und der Abend wie bisher.
  final Einstimmung? einstimmung;

  /// Regeln der Einfluss-Schicht „Dein Moment“ (Finale §3), wenn sie
  /// eingeschaltet ist; sonst `null` und der Abend wie bisher.
  final EinflussRegeln? einfluss;

  /// Raumseite der Schicht (letzter Aufruf, Bots je Runde, Ansichten); `null` ohne Schicht.
  late final EinflussRaum? _moment = einfluss == null ? null : EinflussRaum(einfluss!);

  /// Gastgebergerät als Autorität (Relais-Modus): Die Leitung wandert nie zu
  /// einem anderen Gerät, sonst bekäme ein Gast Salz und Täterpfad.
  final bool festerGastgeber;

  /// Sitz des Gastgebers in der Lobby (Meta `sitz` des Gastgebergeräts):
  /// [Sitz.detektiv] wie bisher oder [Sitz.erzaehler]. Er sitzt dort, sobald
  /// er im Raum ist und der Sitz frei ist; `sitz` ändert es vor dem Start.
  final Sitz gastgeberSitz;

  final KartenKatalog _katalog;
  final List<AbstecherOrt> _abstecher;

  /// Erweiterungen mit eigenen Nachrichten und Ansichtsteilen (siehe [RaumModul]).
  final List<RaumModul> _module;
  late final RaumKontext _kontext = _Kontext(this);

  /// Sitze, Rollenzahl und Figurenwahl der Lobby; ab dem Start unverändert.
  Sitzplan get _sitze => (_module.first as SitzeModul).plan;

  /// Zusätzliche Plätze ohne Rolle über der größten Besetzung.
  static const assistenzPlaetze = 4;

  /// Detektiv- und Erzähler-Sitz über der größten Besetzung.
  static const sitzPlaetze = 2;

  @override
  final String raumCode;
  final Kanon _kanon;
  final Texte _texte;
  final FallCode _fallCode;
  final String _salz;

  /// Server-Zusage vor dem ersten Zug. Eine gemeinsame Commit/Reveal-Runde
  /// aller Geräte ist noch eine zusätzliche, getrennt abzunehmende Erweiterung.
  final String wuerfelZusage;
  final Map<String, _Teilnehmer> _teilnehmer = {};
  final Map<String, bool> _stimmen = {};
  final Map<String, List<String>> _funde = {};
  RundenPartie? _partie;
  String? _host;
  String? _detektiv;
  String? _erzaehler;
  int _version = 0;
  int _erzaehlerAb = 0;
  bool _wurfWerkzeug = false;
  bool _wurfMarke = false;
  String? _wurfKarte;

  int get _minRollen => _kanon.besetzungJson['minRollen'] as int;
  int get _maxRollen => _kanon.besetzungJson['maxRollen'] as int;

  @override
  int get version => _version;
  @override
  int get maxSpieler => _maxRollen + sitzPlaetze + assistenzPlaetze;
  @override
  bool get vorStart => _partie == null;
  /// Beendet ist der Abend im Ende, im langen Abend erst nach dem Morgen
  /// ([RaumModul.haeltOffen]): So räumt der Server den Raum nicht ab, während
  /// alle noch draußen herumgehen.
  @override
  bool get beendet => _partie?.phase == PartyPhase.ende && !_module.any((m) => m.haeltOffen(_kontext));
  @override
  List<String> get spielerIds => List.unmodifiable(_teilnehmer.keys);

  /// Laufende Partie zum Lesen auf dem Gastgebergerät (Relais-Modus). Der
  /// Gastgeber ist die Autorität und kennt Salz und Pfad ohnehin; Änderungen
  /// laufen trotzdem ausschließlich über [nachricht]. Nie an Gäste geben.
  RundenPartie? get partieFuerGastgeber => _partie;

  /// Würfelpate (Geräte-Kennung) des nächsten Wurfs.
  String? get wuerfelPate => _wuerfelPate;

  /// Rollen, deren Gerät die Rollenkarte gelesen bzw. in dieser Runde gestimmt hat.
  Set<String> get gelesen => {for (final t in _teilnehmer.values) if (t.gelesen && t.rolle != null) t.rolle!};
  Set<String> get gestimmt => Set.of(_stimmen.keys);

  /// Rolle eines Geräts (null für Detektiv, Erzähler und Assistenz).
  String? rolleVon(String id) => _teilnehmer[id]?.rolle;

  /// Gerät auf dem Detektiv-Sitz (in der Lobby nach Plan, ab dem Start fest).
  String? get detektivGeraet => vorStart ? _sitze.detektiv : _detektiv;

  /// Gerät auf dem Erzähler-Sitz, sonst `null`.
  String? get erzaehlerGeraet => vorStart ? _sitze.erzaehler : _erzaehler;

  /// Klasse des Detektiv-Sitzes (`forensic`, …), sonst `null`. Sie ändert nur
  /// die Darstellung auf seiner Karte, nie den Abend.
  String? get klasse => _sitze.klasse;

  /// Rollenzahl der Lobby (`besetzung`), sonst `null`.
  int? get lobbyRollen => _sitze.rollen;

  /// Sitz eines Geräts. In der Lobby nur Detektiv oder Erzähler (sonst `null`),
  /// ab dem Start auch Rolle oder Assistenz.
  Sitz? sitzVon(String id) {
    if (vorStart) return _sitze.sitzVon(id);
    if (!_teilnehmer.containsKey(id)) return null;
    if (id == _detektiv) return Sitz.detektiv;
    if (id == _erzaehler) return Sitz.erzaehler;
    return _teilnehmer[id]!.rolle != null ? Sitz.rolle : Sitz.assistenz;
  }

  /// Gilt der Vorleser-Sitz in dieser Akte? Nur in Akten mit Erzähler, heute
  /// denen im Modell befragung (Schlosskeller, wie das Erzählerpaket). Die
  /// übrigen Akten zeigen den Erzähltext allen öffentlich wie vor M3
  /// (Besitzerentscheidung 1: Mechanik per Akte, andere Akten unverändert).
  bool get vorleserSitz => _texte.besetzung.befragungsmodell;

  /// Wer den Abend gerade leitet („Weiter“) und vorliest: der Erzähler, solange
  /// er verbunden ist, sonst der Detektiv-Sitz, solange er verbunden ist, sonst
  /// der Gastgeber. Leitung und Vorleser folgen derselben Kette: Fällt der
  /// Erzähler aus, liest, wer übernimmt, und kein Text geht an ein getrenntes
  /// Gerät; zurück liest der Erzähler das laufende Fenster selbst. Die Frist,
  /// bevor die Oberfläche übernimmt, liegt außen. Vor dem Start niemand.
  String? get vorleser {
    if (vorStart) return null;
    for (final id in [_erzaehler, _detektiv]) {
      if (id != null && (_teilnehmer[id]?.online ?? false)) return id;
    }
    return _host;
  }

  /// Wer ermittelt (Rechte, Befragungskarten, Notizen): der Detektiv-Sitz; hat
  /// er den Abend aufgegeben, der Gastgeber, bis er zurückkommt. Sonst stünde
  /// der Abend ohne festen Gastgeber still, denn der Sitz wandert nicht mit der
  /// Leitung. Vor dem Start der Detektiv-Sitz des Plans.
  String? get ermittler {
    if (vorStart) return _sitze.detektiv;
    final d = _detektiv;
    return d != null && _teilnehmer[d]?.aufgegeben == false ? d : _host;
  }

  /// Beginn des Erzählerfensters in `spiel.bausteine` (nur Gastgebergerät):
  /// Die Bausteine ab hier hat der letzte Schritt ausgegeben.
  int get erzaehlerAb => _erzaehlerAb;

  @override
  bool beitreten(String id, String name) {
    if (id.isEmpty || name.trim().isEmpty || name.runes.length > 40) return false;
    final alt = _teilnehmer[id];
    if (alt != null) {
      alt.name = name.trim();
      alt.online = true;
      alt.aufgegeben = false;
      _host ??= id;
      _hostSitz();
      _version++;
      return true;
    }
    if (!vorStart || _teilnehmer.length >= maxSpieler) return false;
    _teilnehmer[id] = _Teilnehmer(id, name.trim());
    _host ??= id;
    _hostSitz();
    _version++;
    return true;
  }

  /// In der Lobby sitzt der Gastgeber auf [gastgeberSitz], solange er keinen
  /// Sitz hat und dieser frei ist (auch ein neuer Gastgeber nach einem Wechsel).
  void _hostSitz() {
    final h = _host;
    if (!vorStart || h == null || _sitze.sitzt(h)) return;
    final frei = gastgeberSitz == Sitz.detektiv ? _sitze.detektiv == null : _sitze.erzaehler == null;
    if (!frei) return;
    for (final b in _sitze.setze(h, gastgeberSitz)) {
      _teilnehmer[b]?.bereit = false;
    }
  }

  @override
  void verlassen(String id) {
    final t = _teilnehmer[id];
    if (t == null) return;
    if (vorStart) {
      _teilnehmer.remove(id);
      _sitze.entferne(id);
    } else {
      t.online = false;
      t.aufgegeben = true;
    }
    if (_host == id && !festerGastgeber) _host = _ersteOnlineId(ohne: id);
    _hostSitz();
    _botStimmen();
    _version++;
  }

  @override
  void verbunden(String id, bool ja) {
    final t = _teilnehmer[id];
    if (t == null || t.online == ja) return;
    t.online = ja;
    if (ja) {
      t.aufgegeben = false;
      _host ??= id;
      _hostSitz();
    }
    // Keine Neuzuteilung, kein neues Würfelsalz. Temporärer Verbindungsabbruch
    // überträgt nicht sofort die Leitung; das entscheidet die Gnadenfrist außen.
    _version++;
  }

  String? _ersteOnlineId({String? ohne}) {
    for (final t in _teilnehmer.values) {
      if (t.online && t.id != ohne) return t.id;
    }
    return null;
  }

  _Teilnehmer _person(String id) {
    final t = _teilnehmer[id];
    if (t == null || !t.online) throw const PartyRaumFehler('not_in_room');
    return t;
  }

  void _nurHost(String id) {
    if (_host != id) throw const PartyRaumFehler('not_host');
  }

  /// Nur wer ermittelt ([ermittler], ab dem Start).
  void _nurDetektiv(String id) {
    if (vorStart || id != ermittler) throw const PartyRaumFehler('not_detective');
  }

  /// Wer den Abend führen darf (Weiter, später Uhr und Bilder).
  /// - Lobby: der Gastgeber, der Detektiv- und der Erzähler-Sitz (Rollenzahl, Zuteilung).
  /// - Abend: nur, wer gerade leitet ([vorleser]): der Erzähler; ist er offline
  ///   oder fehlt er, der Detektiv; erst danach der Gastgeber, auch wenn er
  ///   ohne festen Gastgeber eine Rolle spielt (die Frist von zwei Minuten liegt
  ///   außen, wie bei Gästen).
  void _darfLeiten(String id) {
    if (vorStart) {
      if (id == _host || id == _sitze.detektiv || id == _sitze.erzaehler) return;
      throw const PartyRaumFehler('not_host');
    }
    if (id != vorleser) throw const PartyRaumFehler('not_host');
  }

  RaumModul? _modulFuer(String typ) {
    for (final m in _module) {
      if (m.nachrichten.containsKey(typ)) return m;
    }
    return null;
  }

  /// Feste Nachrichten, keine beliebigen Methoden oder Rollenkennungen.
  /// Eine optionale Revision verwirft veraltete Aktionen vor jeder Änderung.
  /// Die Abendzeit ([abendZeitFeld]) setzt der Transport in jede Nachricht;
  /// nur die Uhr liest sie.
  @override
  void nachricht(String id, Map<String, Object?> inhalt) {
    final t = _person(id);
    final typ = inhalt['typ'];
    if (typ is! String) throw const PartyRaumFehler('invalid');
    final erlaubt = switch (typ) {
      'bereit' => {'wert'},
      'start' => {'rollen', 'detektiv', 'vorrat'},
      'rollenGelesen' || 'weiter' || 'fundGelesen' => <String>{},
      'wahl' => {'option', 'gruendlich', 'karte'},
      'aktionFertig' => {'aktion'},
      'wurf' => <String>{},
      'wuerfelHilfe' => {'marke', 'karte'},
      'tischruf' => {'ruf', 'karte'},
      'abstecher' => {'ort', 'gruendlich', 'karte'},
      'karte' => {'id'},
      'stimme' => {'kooperativ'},
      'anklage' => {'person'},
      'detektivNeu' => {'spieler'},
      // Einfluss-Schicht (Finale §3.14): nur mit Schicht, sonst unbekannt (`invalid`).
      'zug' when einfluss != null => {'art', 'ziel', 'tipp'},
      'letzterAufruf' when einfluss != null => <String>{},
      'nachfrage' when einfluss != null => {'option'},
      _ => _modulFuer(typ)?.nachrichten[typ] ?? (throw const PartyRaumFehler('invalid')),
    };
    if (inhalt.keys.any((k) => k != 'typ' && k != 'revision' && k != abendZeitFeld && !erlaubt.contains(k))) {
      throw const PartyRaumFehler('invalid');
    }
    final zeit = inhalt[abendZeitFeld];
    if (zeit != null && (zeit is! int || zeit < 0)) throw const PartyRaumFehler('invalid');
    if (inhalt.containsKey('revision') && inhalt['revision'] != _version) {
      throw const PartyRaumFehler('stale');
    }
    try {
      if (typ == 'bereit') {
        if (!vorStart) throw const PartyRaumFehler('game_running');
        t.bereit = _bool(inhalt, 'wert');
      } else if (typ == 'start') {
        _nurHost(id);
        _start(inhalt);
        for (final m in _module) {
          m.beimStart(_kontext);
        }
      } else if (_modulFuer(typ) case final m?) {
        if (vorStart && !m.vorStart(typ)) throw const PartyRaumFehler('not_started');
        m.nachricht(_kontext, id, typ, inhalt);
      } else {
        final p = _partie ?? (throw const PartyRaumFehler('not_started'));
        if (typ == 'zug') {
          // Nur Geräte mit Figur, nur in den Gesprächen, änderbar bis zu den Folgen.
          _moment!.zug(p, t.rolle, inhalt);
        } else if (typ == 'letzterAufruf') {
          _darfLeiten(id);
          _moment!.letzterAufruf(p, inhalt);
        } else if (typ == 'nachfrage') {
          _nurDetektiv(id);
          _moment!.nachfrage(p, inhalt);
        } else if (typ == 'rollenGelesen') {
          if (p.phase != PartyPhase.rollen || t.rolle == null) throw const PartyRaumFehler('invalid_phase');
          t.gelesen = true;
        } else if (typ == 'stimme') {
          if (p.phase != PartyPhase.gruppenwahl || t.rolle == null) throw const PartyRaumFehler('invalid_phase');
          if (_stimmen.containsKey(t.rolle)) throw const PartyRaumFehler('already_voted');
          _stimmen[t.rolle!] = _bool(inhalt, 'kooperativ');
          _auswerten();
        } else if (typ == 'wurf' || typ == 'wuerfelHilfe') {
          if (id != _wuerfelPate) throw const PartyRaumFehler('not_dice_player');
          if (typ == 'wuerfelHilfe') {
            // Werkzeug kommt nur aus einer Quelle in der Welt (K-07): einer
            // Werkzeug-Karte des Tischvorrats, nie aus einem freien Feld.
            final marke = _bool(inhalt, 'marke', sonst: false);
            final karte = inhalt['karte'];
            if (karte != null) {
              if (karte is! String) throw const PartyRaumFehler('invalid');
              p.vorrat.pruefe(karte, {KartenArt.werkzeug});
            }
            p.vorschau(werkzeug: karte != null, marke: marke); // Phase zuerst prüfen.
            _wurfWerkzeug = karte != null;
            _wurfKarte = karte as String?;
            _wurfMarke = marke;
          } else {
            p.wuerfeln(marke: _wurfMarke, karte: _wurfKarte);
            _wurfWerkzeug = _wurfMarke = false;
            _wurfKarte = null;
            _merkeFund();
          }
        } else if (typ == 'detektivNeu') {
          _nurHost(id);
          _detektivNeu(_string(inhalt, 'spieler'));
        } else if (typ == 'karte') {
          // Sofort wirkende Karten (Zeit, Marke, Erinnerung) legt der Detektiv.
          _nurDetektiv(id);
          p.karteSpielen(_string(inhalt, 'id'));
        } else {
          if (typ == 'weiter') {
            _darfLeiten(id);
          } else if (typ == 'aktionFertig') {
            // Die Karte des Detektivs meldet das Ende eines Laufs; der Gastgeber
            // rendert mit und meldet ersatzweise. Die Nummer verhindert Doppelte.
            if (id != _detektiv && id != _host) throw const PartyRaumFehler('not_detective');
          } else {
            _nurDetektiv(id);
          }
          switch (typ) {
            case 'weiter':
              if (!_kannWeiter) throw const PartyRaumFehler('not_ready');
              // Mit Schicht: aus den Gesprächen erst, wenn alle Menschen gezogen haben oder die Frist
              // nach dem letzten Aufruf (Abendzeit dieser Nachricht) um ist; wer fehlt, hat abgewartet.
              final m = _moment;
              final moment = m != null && p.phase == PartyPhase.gespraeche ? m : null;
              if (moment != null) {
                if (!moment.darfWeiter(p, _menschSpielt, zeit: zeit as int?)) throw const PartyRaumFehler('not_ready');
                moment.vorFolgen(p, _menschSpielt);
              }
              final runde = p.runde;
              final ab = p.spiel.bausteine.length;
              p.weiter();
              _erzaehlerAb = ab;
              moment?.nachFolgen(p, runde);
              // Verzögerte Funde (Umweg, mauert) kommen mit dem Zwischenresümee ins Notizbuch.
              if (m != null) _funde.addAll(m.nachgereicht(p));
              if (p.phase == PartyPhase.gruppenwahl) {
                _stimmen.clear();
                _botStimmen();
              }
              for (final m in _module) {
                m.phaseGewechselt(_kontext);
              }
            case 'wahl':
              p.waehle(_string(inhalt, 'option'),
                  gruendlich: _bool(inhalt, 'gruendlich', sonst: false), karte: _kannString(inhalt, 'karte'));
            case 'abstecher':
              p.starteAbstecher(_string(inhalt, 'ort'),
                  gruendlich: _bool(inhalt, 'gruendlich', sonst: false), karte: _kannString(inhalt, 'karte'));
            case 'aktionFertig':
              final aktion = inhalt['aktion'];
              if (aktion is! int || !p.aktionFertig(aktion)) throw const PartyRaumFehler('stale');
              _merkeFund();
            case 'tischruf':
              final ruf = switch (inhalt['ruf']) {
                'nochmal' => Tischruf.nochmal,
                'umweg' => Tischruf.umweg,
                _ => throw const PartyRaumFehler('invalid'),
              };
              p.tischruf(ruf, karte: _kannString(inhalt, 'karte'));
              _merkeFund();
            case 'fundGelesen':
              p.fundGelesen();
            case 'anklage':
              p.anklagen(_string(inhalt, 'person'));
          }
        }
      }
    } on StateError {
      throw const PartyRaumFehler('invalid_phase');
    } on KartenFehler catch (e) {
      throw PartyRaumFehler(e.code);
    } on ArgumentError {
      throw const PartyRaumFehler('invalid');
    }
    _version++;
  }

  void _start(Map<String, Object?> inhalt) {
    if (!vorStart) throw const PartyRaumFehler('game_running');
    if (_teilnehmer.values.any((t) => !t.online || !t.bereit)) throw const PartyRaumFehler('not_ready');
    // Ohne Angabe gilt die Rollenzahl der Lobby (`besetzung`). Liegt sie im
    // Raum, gilt nur sie: Was alle in der Lobby gesehen haben (Rollenzahl und
    // Zuteilung), überschreibt der Start nicht still.
    final lobby = _sitze.rollen;
    final rollen = inhalt['rollen'] ?? lobby;
    if (lobby != null && rollen != lobby) throw const PartyRaumFehler('invalid');
    final detektiv = inhalt['detektiv'] ?? 'm';
    // Eine Figur bekommt jedes Gerät ohne Sitz, soweit die Rollen reichen.
    final gaeste = _teilnehmer.keys.where((id) => !_sitze.sitzt(id)).length;
    if (rollen is! int || rollen < _minRollen || rollen > _maxRollen || rollen < (gaeste < _maxRollen ? gaeste : _maxRollen) ||
        (detektiv != 'm' && detektiv != 'w')) {
      throw const PartyRaumFehler('invalid');
    }
    if (!_sitze.startklar(_host)) throw const PartyRaumFehler('seats');
    // Tischvorrat: höchstens 3 Karten aus den Wünschen der Spielleitung
    // (Vereinigung der Decks am Tisch), unabhängig von der Besetzung (K-06).
    final wunsch = inhalt['vorrat'];
    if (wunsch != null && (wunsch is! List || wunsch.length > 12 || wunsch.any((w) => w is! String))) {
      throw const PartyRaumFehler('invalid');
    }
    final vorrat = TischVorrat.aus([for (final w in (wunsch as List?) ?? const []) w as String], _katalog);
    // Mit Einfluss-Schicht ziehen Bots und Ertappt aus dem Salz des Raums (Finale §3.11).
    final p = RundenPartie(_kanon, quelle: SalzWuerfel(_salz), vorrat: vorrat, abstecher: _abstecher, einfluss: einfluss);
    p.einrichten(Einstellungen(rollen: rollen, detektiv: detektiv as String, code: _fallCode));
    // Zuerst die Zuteilung der Lobby, der Rest wie bisher gemischt in
    // Beitrittsreihenfolge; Detektiv- und Erzähler-Sitz bekommen keine Figur,
    // überzählige Geräte bleiben Assistenz ohne Rolle.
    final gemischt = [...p.spiel.besetzt];
    Rng(Rng.hashString('rollen:$_salz')).shuffle(gemischt);
    final zuteilung = _sitze.verteile(_teilnehmer.keys, gemischt);
    for (final t in _teilnehmer.values) {
      t.rolle = zuteilung[t.id];
    }
    _detektiv = _sitze.detektiv;
    _erzaehler = _sitze.erzaehler;
    _partie = p;
  }

  /// Fällt der Detektiv-Sitz während des Abends aus (getrennt oder
  /// aufgegeben), vergibt ihn der Gastgeber neu ([ziel]): an sich selbst oder
  /// an einen verbundenen Platz ohne Figur (Assistenz). Wer eine Figur spielt,
  /// übernimmt nie (Besitzerentscheidung A-062): So ermittelt nie eine
  /// Täterrolle, und kein Dossier wechselt den Platz. Die beiden tauschen ihre
  /// Plätze; der bisherige Detektiv bekommt den Platz von [ziel] (den
  /// Erzähler-Sitz des Gastgebers oder den Platz ohne Figur) und sitzt dort,
  /// wenn er zurückkommt. So bleibt der Sitzplan eine Permutation, und das
  /// Protokoll spielt ihn gleich wieder ein. Die Klasse bleibt beim Sitz (der
  /// Abend hat mit ihr begonnen; sie ändert ohnehin nur die Darstellung).
  void _detektivNeu(String ziel) {
    final alt = _detektiv;
    final weg = alt == null ? null : _teilnehmer[alt];
    final neu = _teilnehmer[ziel];
    if (alt == null || weg == null || (weg.online && !weg.aufgegeben) || neu == null || !neu.online || neu.aufgegeben || ziel == alt) {
      throw const PartyRaumFehler('invalid');
    }
    // Ein Gastgeber nach einem Wechsel (ohne festen Gastgeber) kann eine Figur spielen.
    if (neu.rolle != null || (ziel != _host && sitzVon(ziel) != Sitz.assistenz)) throw const PartyRaumFehler('invalid');
    if (ziel == _erzaehler) _erzaehler = alt;
    _detektiv = ziel;
  }

  static bool _bool(Map<String, Object?> j, String name, {bool? sonst}) {
    final v = j.containsKey(name) ? j[name] : sonst;
    if (v is! bool) throw const PartyRaumFehler('invalid');
    return v;
  }

  static String? _kannString(Map<String, Object?> j, String name) => j[name] == null ? null : _string(j, name);

  static String _string(Map<String, Object?> j, String name) {
    final v = j[name];
    if (v is! String || v.isEmpty || v.length > 80) throw const PartyRaumFehler('invalid');
    return v;
  }

  /// Spielt ein Mensch [rolle] (ein Gerät, das nicht aufgegeben hat)? Sonst zieht und spricht die App sie.
  bool _menschSpielt(String rolle) => _teilnehmer.values.any((t) => !t.aufgegeben && t.rolle == rolle);

  bool get _kannWeiter {
    final p = _partie;
    if (p == null || !p.kannWeiter) return false;
    if (!_module.every((m) => m.darfWeiter(_kontext))) return false;
    if (_moment case final m? when !m.darfWeiter(p, _menschSpielt, ansicht: true)) return false;
    return p.phase != PartyPhase.rollen || !_teilnehmer.values.any((t) => !t.aufgegeben && t.rolle != null && !t.gelesen);
  }

  /// Reihum unter den verbundenen Geräten, nie der Erzähler.
  String? get _wuerfelPate {
    final online = [for (final t in _teilnehmer.values) if (t.online && t.id != _erzaehler) t.id];
    if (online.isEmpty) return null;
    return online[(_partie?.wuerfe.length ?? 0) % online.length];
  }

  void _botStimmen() {
    final p = _partie;
    if (p == null || p.phase != PartyPhase.gruppenwahl) return;
    final menschen = {for (final t in _teilnehmer.values) if (!t.aufgegeben && t.rolle != null) t.rolle};
    for (final rolle in p.spiel.besetzt) {
      if (!menschen.contains(rolle)) {
        _stimmen.putIfAbsent(rolle, () => botKooperativ(salz: _salz, rolle: rolle, runde: p.runde));
      }
    }
    _auswerten();
  }

  void _auswerten() {
    final p = _partie!;
    if (_stimmen.length != p.spiel.besetzt.length || p.spiel.qualitaeten.containsKey(p.runde)) return;
    p.abstimmen(
      kooperativ: _stimmen.entries.where((e) => e.key != p.spiel.pfad && e.value).length,
      taeterSabotiert: _stimmen[p.spiel.pfad] == false,
    );
  }

  void _merkeFund() {
    final z = _partie?.zug;
    if (z != null && z.phase == RundenZugPhase.fund && !z.istAuftakt) {
      _funde[z.id] = [for (final f in z.funde) f.text];
    }
  }

  /// Befragungsplan der Akte für das Erzählerpaket (nur Modell befragung).
  late final Befragungsplan _befragungsplan = Befragungsplan(_texte);
  final Map<(int, int), Map<String, Object?>> _pakete = {};

  /// Pfadfreies Erzählerpaket der Runde (A-052): Tisch-Stichpunkte,
  /// Befragungen mit Antworten, npc-Texte; nie verbirgt, Tatwissen, Tarnung.
  Map<String, Object?> _erzaehlerPaket(int n, int runde) =>
      _pakete.putIfAbsent((n, runde), () => erzaehlerPaket(_texte, _befragungsplan, n: n, runde: runde).toJson());

  /// E-044: Was der Erzähler zum Rundenstart über unbesetzte Gäste sprach, in
  /// der Reihenfolge des Abends. Der Detektiv behält es als Notiz, auch wenn
  /// ein anderer Sitz vorliest; es hängt nur an Runde und Besetzung (S-1).
  List<String> _npcNotizen(RundenPartie p) => [
        for (final k in {for (final b in p.spiel.bausteine) if (b.startsWith('npc.')) b}) _texte.baustein(k),
      ];

  List<EntscheidungsOption> _optionen(Entscheidung e) {
    final optionen = [...e.optionen];
    // Online darf auch die Reihenfolge nicht vom geheimen Fall-Code abhängen.
    Rng(Rng.hashString('optionen:$_salz:${e.id}')).shuffle(optionen);
    return optionen;
  }

  /// Nur erlaubte öffentliche Daten und das Dossier des Empfängers. Insbesondere
  /// keine generische toJson()-Abbildung von Spiel, Kanon, Dossier oder Optionen.
  @override
  Map<String, Object?> zustandFuer(String id) {
    final ich = _person(id);
    final p = _partie;
    final nachFinale = p != null && p.phase.index >= PartyPhase.finale.index;
    final zug = p?.zug;
    final e = p?.naechsteEntscheidung;
    final rolle = ich.rolle;
    final dossier = p == null || rolle == null ? null : _texte.dossier(rolle, p.spiel.pfad, p.spiel.einstellungen.rollen);
    // Vorleser-Sitz: Die Bausteine des letzten Schritts liest ein Gerät vor.
    final fenster = p == null ? const <String>[] : [for (final b in p.spiel.bausteine.skip(_erzaehlerAb)) _texte.baustein(b)];
    final befragungsmodell = _texte.besetzung.befragungsmodell;
    final ansicht = <String, Object?>{
      't': 'abend', 'protokoll': 1, 'version': _version,
      'spiel': akte, 'akte': akte, 'raum': raumCode, 'host': _host,
      // Nur der lange Abend trägt die Fassung; kurze Ansichten bleiben bytegleich.
      if (fassung.istLang) 'fassung': fassung.name,
      'phase': p?.phase.name ?? 'lobby', 'runde': p?.runde ?? 0,
      'wuerfelZusage': wuerfelZusage,
      // Sitz, Figur (Lobby) und Wunsch sind am Tisch öffentlich, nie ein Dossier.
      'spieler': [for (final t in _teilnehmer.values) {
        'id': t.id, 'name': t.name, 'online': t.online, 'bereit': t.bereit,
        if (sitzVon(t.id) case final sitz?) 'sitz': sitz.name,
        if (t.rolle != null) 'rolle': t.rolle,
        if (p == null) ...{
          'figur': ?_sitze.zuteilung[t.id],
          'wunsch': ?_sitze.wuensche[t.id],
        },
      }],
      'kannWeiter': _kannWeiter,
      // In der Lobby liegt die Rollenzahl im Raum (`besetzung`).
      if (p == null && _sitze.rollen != null) 'rollen': _sitze.rollen,
      if (p != null) ...{
        'rollen': p.spiel.einstellungen.rollen,
        'restMinuten': p.restMinuten, 'marken': p.marken,
        if (vorleserSitz) ...{
          'erzaehlerLiest': fenster.isNotEmpty,
          'bausteinZahl': fenster.length,
        },
        // Ab dem Finale dürfen alle die Auflösungstexte sehen; Altakten zeigen sie immer allen.
        if (nachFinale || !vorleserSitz) 'erzaehler': fenster,
        'notizbuch': {for (final f in _funde.entries) f.key: [...f.value]},
        'wuerfe': [for (final w in p.wuerfe) w.toJson()],
        'wuerfelPate': _wuerfelPate,
        // Gewählte Optionen sind am Tisch öffentlich (Karte, Notizbuch).
        'gewaehlt': Map.of(p.spiel.gewaehlt),
        'vorrat': p.vorrat.toJson(),
        'abstecher': [
          for (final a in p.abstecherOffen) {'id': a.id, 'ort': a.ort, 'name': a.name},
        ],
        'abstecherErgebnis': {for (final e in p.abstecherErgebnis.entries) e.key: e.value.kurz},
        if (e != null) 'entscheidung': {
          'id': e.id, 'frage': e.frage, 'suche': istSuche(e),
          'optionen': [for (final o in _optionen(e)) {'id': o.id, 'text': o.text, 'ziel': Map.of(o.ziel)}],
        },
        if (zug != null) 'zug': {
          'id': zug.id, 'option': zug.option, 'suche': zug.suche,
          'phase': zug.phase.name, 'aktion': zug.aktion, 'ruf': zug.ruf?.name,
          'wurf': zug.wurf?.toJson(), 'funde': [for (final f in zug.funde) f.text],
          if (zug.istAbstecher) ...{'abstecher': zug.abstecher, 'nebenfund': zug.nebenfund},
          // Einfluss-Schicht: Tischwert, „Die Spur verwischt“, Kennzeichen des Fundes, Zeile „Tisch“.
          if (_moment case final m?) ...m.zugFelder(p, zug),
          if (zug.phase == RundenZugPhase.wurf) ...{
            'werkzeug': _wurfWerkzeug, 'marke': _wurfMarke,
            'mod': p.vorschau(werkzeug: _wurfWerkzeug, marke: _wurfMarke).mod,
            'chancen': {
              for (final v in p.vorschau(werkzeug: _wurfWerkzeug, marke: _wurfMarke).prozent.entries) v.key.name: v.value,
            },
          },
        },
        // Altakten (Modell legacy): öffentliche Sprechblasen der Bots. Im Modell befragung
        // antworten App-Rollen nur dem Detektiv und erst nach seiner Frage (BefragungModul).
        if (p.phase == PartyPhase.gespraeche && !_texte.besetzung.befragungsmodell) 'botGespraeche': [
          for (final g in botGespraeche(_texte, rollen: p.spiel.einstellungen.rollen, runde: p.runde, mitNpc: true))
            if (!_teilnehmer.values.any((t) => !t.aufgegeben && t.rolle == g.rolle)) {
              'id': g.id, 'rolle': g.rolle, 'partner': g.partner, 'thema': g.thema, 'text': g.text,
              'preisgaben': [for (final z in g.preisgaben) {'quelle': z.quelle, 'text': z.text}],
            },
        ],
        if (p.phase == PartyPhase.anklage) 'verdaechtige': [..._kanon.kernverdaechtige],
      },
      // Einfluss-Schicht (Finale §3.12): öffentlich nie wer was spielte, nie Zählwerte oder Tipps.
      if (_moment case final m?) 'einfluss': m.oeffentlich(p),
      'privat': <String, Object?>{
        'spieler': id, 'detektiv': id == ermittler,
        if (p != null && vorleserSitz && id == vorleser) ...{'vorleser': true, 'erzaehler': fenster},
        if (p != null && befragungsmodell) ...{
          if (id == _erzaehler) 'erzaehlerPaket': _erzaehlerPaket(p.spiel.einstellungen.rollen, p.runde.clamp(1, Befragungsplan.runden)),
          if (id == ermittler) 'erzaehlerNotizen': _npcNotizen(p),
        },
        if (dossier != null) ...{
          'rolle': rolle, 'gelesen': ich.gelesen,
          'dossier': {
            'wer': dossier.wer, 'ziel': dossier.ziel, 'besetzung': dossier.besetzung,
            'weiss': [for (final z in dossier.weiss) z.text],
            'verbirgt': [for (final z in dossier.verbirgt) z.text],
            if (dossier.tarnung != null) 'tarnung': dossier.tarnung,
            if (dossier.tatwissen.isNotEmpty) 'tatwissen': [for (final z in dossier.tatwissen) z.text],
          },
          if (p!.phase == PartyPhase.gespraeche) 'gespraeche': [
            for (final (g, partner) in dossier.gespraeche[p.runde] ?? <(Gespraech, String)>[])
              if (_texte.besetzung.befragungsmodell)
                {'partner': partner, 'thema': g.thema, 'ziel': g.ziel, 'stichpunkte': [...g.stichpunkte]}
              else
                {'partner': partner, 'thema': g.thema, 'ziel': g.ziel, 'text': g.text},
          ],
          if (p.phase == PartyPhase.gruppenwahl) ...{
            'hatGestimmt': _stimmen.containsKey(rolle),
            if (dossier.wahlen[p.runde] case final w?) 'wahl': {
              'a': w.a, 'b': w.sabotage ?? w.b,
            },
          },
          // „Dein Moment“: eigener Zug, erlaubte Züge, Sterne, private Nachrichten, Lauschergebnis.
          if (_moment case final m?) 'moment': m.moment(p, rolle!),
        },
        // Zug-Tafel der laufenden Runde nur beim Erzähler-Sitz (§3.12).
        if (p != null && id == _erzaehler && _moment != null) 'einflussTafel': ?_moment.tafel(p),
      },
      if (nachFinale) 'aufloesung': {
        'pfad': p.spiel.pfad, 'fallCode': _fallCode.code, 'salz': _salz,
        'punkte': p.spiel.punkte, 'ende': p.spiel.ende.id,
        'seifenblasen': p.seifenblasenBilanz,
        'abstecherFunde': [...p.abstecherFunde]..sort(),
        if (_moment case final m?) 'einfluss': m.aufloesung(p),
      },
    };
    final privat = ansicht['privat']! as Map<String, Object?>;
    for (final m in _module) {
      for (final e in m.oeffentlich(_kontext, id).entries) {
        if (ansicht.containsKey(e.key)) throw StateError('Modul überschreibt Ansichtsschlüssel ${e.key}');
        ansicht[e.key] = e.value;
      }
      for (final e in m.privat(_kontext, id).entries) {
        if (privat.containsKey(e.key)) throw StateError('Modul überschreibt privaten Schlüssel ${e.key}');
        privat[e.key] = e.value;
      }
    }
    bool freigegeben(String k) =>
        raumOeffentlicheSchluessel.contains(k) ||
        (nachFinale && raumSchluesselNachFinale.contains(k)) ||
        (!vorleserSitz && raumSchluesselOhneVorleser.contains(k));
    assert(
      ansicht.keys.every(freigegeben),
      'Nicht freigegebener Ansichtsschlüssel: ${ansicht.keys.where((k) => !freigegeben(k)).join(', ')}',
    );
    return ansicht;
  }
}

/// Lesender Blick der Module auf den Raum.
class _Kontext extends RaumKontext {
  _Kontext(this._r);
  final SchlosskellerRaum _r;

  @override
  String? get host => _r._host;
  @override
  String? get detektiv => _r.ermittler;
  @override
  String? get erzaehler => _r.erzaehlerGeraet;
  @override
  String? get vorleser => _r.vorleser;
  @override
  RundenPartie? get partie => _r._partie;
  @override
  Kanon get kanon => _r._kanon;
  @override
  Texte get texte => _r._texte;
  @override
  Iterable<String> get spielerIds => _r._teilnehmer.keys;
  @override
  bool istOnline(String id) => _r._teilnehmer[id]?.online ?? false;
  @override
  String? rolleVon(String id) => _r._teilnehmer[id]?.rolle;
  @override
  bool menschSpielt(String rolle) => _r._menschSpielt(rolle);
  @override
  void nurHost(String id) => _r._nurHost(id);
  @override
  void nurDetektiv(String id) => _r._nurDetektiv(id);
  @override
  void darfLeiten(String id) => _r._darfLeiten(id);
  @override
  void bereitAufheben(String id) {
    final t = _r._teilnehmer[id];
    if (t != null && _r.vorStart) t.bereit = false;
  }
}
