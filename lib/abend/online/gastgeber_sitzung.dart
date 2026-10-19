import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:mordakte_core/mordakte_core.dart';
import 'package:mordakte_core/runden.dart';
import 'package:mordakte_netz/mordakte_netz.dart' show AbendFehler;

import '../../party/karten_aktion.dart';
import '../../party/sitzung.dart';
import '../../party/stand/befragung_stand.dart';
import 'ansicht.dart';
import 'gastgeber_dienst.dart';

/// Der Abend auf dem Gastgebergerät: Der Gastgeber sitzt auf dem Detektiv-
/// oder dem Erzähler-Sitz ([sitz], Langer Abend M3) und nutzt dieselben
/// Bildschirme wie beim Spiel an einem Gerät. Das Lesemodell ist die Partie des
/// Raums ([SchlosskellerRaum.partieFuerGastgeber]); jede Eingabe geht als
/// Raumnachricht über den Platz des Gastgebers ([GastgeberDienst.verb]) hinaus
/// und verändert die Partie nur dort. Ermittlungsbefehle nimmt der Raum nur vom
/// Detektiv-Sitz an, „Weiter“ nur von dem, der leitet ([leitet]). Nach jeder
/// Änderung schickt der [RelayHost] den Gästen ihre neuen Ansichten.
///
/// Phasen, die Gäste brauchen (Rollen lesen, Gruppenwahl, Würfeln durch einen
/// Gast), liest die Sitzung aus dem Raum: [gelesen], [gestimmt], [darfWuerfeln].
class GastgeberSitzung extends PartySitzung {
  GastgeberSitzung._(this.dienst, RundenPartie partie) : super(dienst.daten, partie: partie, salz: dienst.salz) {
    // Namen am Tisch: Gäste mit Rolle heißen so, wie sie sich eingetragen haben.
    for (final s in dienst.spieler) {
      final r = s.rolle;
      if (r != null && s.name.trim().isNotEmpty) namen[r] = s.name.trim();
    }
    detektivName = dienst.detektivName;
    rundendauer = Duration(minutes: dienst.minuten);
    stimmeAn = dienst.stimme;
    _hoerer = dienst.verb.ansichten.listen((_) => _abgleichen());
    _abgleichen();
    unawaited(_erzaehlstandLaden());
    unawaited(_notizenLaden());
  }

  /// Baut die Sitzung für einen schon gestarteten Raum ([GastgeberDienst.gestartet]).
  factory GastgeberSitzung(GastgeberDienst dienst) {
    final partie = dienst.raum.partieFuerGastgeber ?? (throw StateError('Der Abend hat noch nicht begonnen.'));
    return GastgeberSitzung._(dienst, partie);
  }

  final GastgeberDienst dienst;
  StreamSubscription<Map<String, Object?>>? _hoerer;
  String? _fehler;
  bool _entsorgt = false;

  @override
  bool get online => true;

  // ---------------------------------------------------------------- Sitze

  String get _ich => dienst.verb.spielerId ?? gastgeberPlatz;

  /// Sitz des Gastgebers an diesem Abend: Detektiv oder Erzähler.
  Sitz get sitz => dienst.raum.sitzVon(_ich) ?? dienst.sitz;

  /// Ermittelt der Gastgeber? Auf dem Detektiv-Sitz, oder wenn er einen Gast-
  /// Detektiv vertritt, der den Abend aufgegeben hat ([SchlosskellerRaum.ermittler]).
  /// Sonst ermittelt ein Gast ([detektivGeraet]).
  bool get istDetektiv => dienst.raum.ermittler == _ich;

  /// Nur wer ermittelt, hat Detektivkarte, Klassenwirkung und Klassen-Belohnung.
  @override
  bool get detektivAmGeraet => istDetektiv;

  /// Gerät auf dem Detektiv-Sitz: der Gastgeber selbst oder ein Gast.
  String? get detektivGeraet => dienst.raum.detektivGeraet;

  /// Liest dieses Gerät die Erzähltexte vor? Wer leitet, liest ([SchlosskellerRaum.vorleser]):
  /// der Erzähler, sonst der Detektiv, sonst der Gastgeber; während der Frist
  /// für einen getrennten Erzähler noch nicht ([uebernahmeFrist]). Ab dem Finale
  /// und in Akten ohne Vorleser-Sitz lesen alle.
  @override
  bool get istVorleser => nachFinale || !dienst.raum.vorleserSitz || (dienst.raum.vorleser == _ich && !uebernahmeFrist);

  /// Wer vorliest, wenn es nicht der Gastgeber ist; während der Frist der getrennte Erzähler.
  @override
  String get vorleserName => dienst.nameVon(uebernahmeFrist ? dienst.raum.erzaehlerGeraet : dienst.raum.vorleser);

  /// Klasse des Detektiv-Sitzes (`forensic`, …), sonst `null`. Sie reist mit dem
  /// Sitz und ändert nur die Darstellung auf seiner Karte, nie den Abend.
  /// Vertritt der Gastgeber einen Gast-Detektiv, gilt seine eigene Klasse
  /// (`null`: die Ausrüstung dieses Geräts).
  @override
  String? get detektivKlasse => istDetektiv && sitz != Sitz.detektiv ? null : dienst.raum.klasse;

  /// Darf der Gastgeber gerade „Weiter“ drücken? Nur, wenn er leitet wie im Raum
  /// ([SchlosskellerRaum.vorleser]): als Erzähler, ohne verbundenen Erzähler als
  /// Detektiv, sonst als Gastgeber. Fällt ein Gast-Erzähler aus, übernimmt der
  /// Gastgeber erst nach der Frist ([erzaehlerFrist]).
  @override
  bool get leitet => dienst.raum.vorleser == _ich && !uebernahmeFrist;

  /// Ist der Detektiv-Sitz ein Gast, der getrennt ist oder den Abend aufgegeben
  /// hat? Dann steht die Ermittlung, bis er zurückkommt oder der Gastgeber den
  /// Sitz neu vergibt ([detektivNeu]). Nur bis zur Anklage: danach ermittelt
  /// niemand mehr.
  bool get detektivWeg {
    final d = detektivGeraet;
    if (d == null || d == _ich || phase.index >= PartyPhase.finale.index) return false;
    return !dienst.spieler.any((s) => s.id == d && s.online);
  }

  /// Wer den Detektiv-Sitz übernehmen kann: der Gastgeber und jeder verbundene Gast.
  List<SpielerInfo> get detektivKandidaten => [
        for (final s in dienst.spieler)
          if (s.online && s.id != detektivGeraet) s,
      ];

  /// Gibt den Detektiv-Sitz an [spieler] (Gastgeber oder Gast); beide tauschen
  /// die Plätze (Raumnachricht `detektivNeu`). Kommt der bisherige Detektiv
  /// zurück, sitzt er auf dem Platz seines Nachfolgers.
  void detektivNeu(String spieler) => _senden([
        {'typ': 'detektivNeu', 'spieler': spieler},
      ]);

  /// So lange wartet der Gastgeber, bevor er für einen getrennten Erzähler
  /// vorliest und weiterführt (Plan M3: zwei Minuten). Kommt der Erzähler in der
  /// Zeit zurück, merkt der Tisch nichts.
  static Duration erzaehlerFrist = const Duration(minutes: 2);

  Timer? _fristUhr;
  bool _fristVorbei = false;

  /// Ist der Erzähler-Sitz ein Gast, der gerade getrennt ist?
  bool get _erzaehlerWeg {
    final e = dienst.raum.erzaehlerGeraet;
    return e != null && e != _ich && !dienst.spieler.any((s) => s.id == e && s.online);
  }

  @override
  bool get uebernahmeFrist {
    _fristPruefen();
    return _fristUhr != null;
  }

  /// Startet die Frist, sobald der Erzähler getrennt ist, und setzt sie zurück,
  /// wenn er wieder da ist. Nach Ablauf meldet die Sitzung die Übernahme.
  void _fristPruefen() {
    if (_entsorgt) return;
    if (!_erzaehlerWeg) {
      _fristUhr?.cancel();
      _fristUhr = null;
      _fristVorbei = false;
      return;
    }
    if (_fristUhr != null || _fristVorbei) return;
    _fristUhr = Timer(erzaehlerFrist, () {
      _fristUhr = null;
      _fristVorbei = true;
      if (!_entsorgt) notifyListeners();
    });
  }

  /// Letzte Ablehnung des Raums (fester Schlüssel wie `not_ready`) oder `null`.
  /// Der Bildschirm zeigt sie einmal und ruft dann [fehlerQuittieren].
  String? get letzterFehler => _fehler;

  void fehlerQuittieren() => _fehler = null;

  // ---------------------------------------------- Ersatzmeldung der Aktion

  /// Ermittelt ein Gast, meldet sein Gerät das Ende jedes sichtbaren Wegs. Bleibt
  /// die Meldung aus (Gerät im Hintergrund, Verbindung weg), meldet der
  /// Gastgeber nach dieser festen Frist ersatzweise: der längste Weg plus etwas
  /// Puffer ([KartenAktion.hoechstDauer]). Die Nummer der Aktion verhindert
  /// Doppelte; eine veraltete Meldung bleibt still.
  static Duration aktionsFrist = KartenAktion.hoechstDauer + const Duration(seconds: 2);

  Timer? _aktionsUhr;
  int? _aktionsNr;

  void _aktionPruefen() {
    final z = zug;
    if (istDetektiv || z == null || z.phase != RundenZugPhase.aktion) {
      _aktionsUhr?.cancel();
      _aktionsUhr = null;
      _aktionsNr = null;
      return;
    }
    if (_aktionsNr == z.aktion) return;
    _aktionsNr = z.aktion;
    _aktionsUhr?.cancel();
    final nr = z.aktion;
    _aktionsUhr = Timer(aktionsFrist, () {
      _aktionsUhr = null;
      final jetzt = zug;
      if (_entsorgt || jetzt == null || jetzt.phase != RundenZugPhase.aktion || jetzt.aktion != nr) return;
      unawaited(() async {
        try {
          await dienst.verb.befehl({'typ': 'aktionFertig', 'aktion': nr});
        } catch (_) {
          // Der Detektiv war schneller: nichts zu melden.
        }
      }());
    });
  }

  // ------------------------------------------------------- Randgespräche

  /// Die Randgespräche führt nur der Gastgeber; der Raum kennt sie nicht. Damit
  /// sie eine Rückkehr zum Abend überstehen, liegen Flags und geführte Gespräche
  /// neben dem Raum in der Ablage, an das Salz dieses Abends gebunden.
  Future<void> _erzaehlstandLaden() async {
    try {
      final roh = await dienst.ablage.lesen(GastgeberDienst.erzaehlSchluessel);
      if (roh == null || _entsorgt) return;
      final d = jsonDecode(roh);
      if (d is Map && d['salz'] == dienst.salz) erzaehlstandUebernehmen(d.cast<String, Object?>());
    } catch (e) {
      debugPrint('ONLINE erzaehlstand lesen $e');
    }
  }

  /// Randgespräche mit Zeugen führt der Gastgeber nur auf dem Detektiv-Sitz;
  /// als Erzähler spricht er niemanden an.
  @override
  bool randgespraechMoeglich(String figur) => istDetektiv && super.randgespraechMoeglich(figur);

  @override
  void randgespraechGefuehrt() {
    final stand = jsonEncode({'salz': dienst.salz, ...erzaehlstand});
    unawaited(() async {
      try {
        await dienst.ablage.schreiben(GastgeberDienst.erzaehlSchluessel, stand);
      } catch (e) {
        debugPrint('ONLINE erzaehlstand schreiben $e');
      }
    }());
  }

  void _abgleichen() {
    if (_entsorgt) return;
    _fristPruefen();
    _aktionPruefen();
    // Antworten der App bleiben im Notizbuch, auch wenn die Ansicht sie nach den Gesprächen nicht mehr trägt.
    final vorher = _notizen.length;
    for (final k in befragungen) {
      if (k.antwort != null) _notizen[k.id] = k;
    }
    if (_notizen.length != vorher && _notizenBereit) _notizenSichern();
    // Vorleser-Sitz: Der öffentliche Teil trägt keinen Erzähltext mehr; das
    // Fenster kommt aus dem Raum (nur auf dem Gastgebergerät).
    raumGeaendert(erzaehlerAb: dienst.raum.erzaehlerAb);
  }

  // ------------------------------------------------------ Notizbuch

  /// Das Notizbuch der Befragungen kennt nur dieses Gerät: Nach den Gesprächen
  /// trägt die Ansicht des Raums die Antworten nicht mehr. Damit es eine
  /// Rückkehr zum Abend übersteht, liegen Kennung, Frage und Art jeder
  /// beantworteten Befragung neben dem Raum in der Ablage, an das Salz dieses
  /// Abends gebunden. Die Antwort entsteht beim Laden wieder aus den
  /// Preisgaben, wie im Raum ([befragungsKarten]). Geschrieben wird erst nach
  /// dem Laden, damit die Notizen der Runden davor nicht verloren gehen.
  Future<void> _notizenLaden() async {
    try {
      final roh = await dienst.ablage.lesen(GastgeberDienst.notizSchluessel);
      if (roh == null || _entsorgt) return;
      final d = jsonDecode(roh);
      if (d is! Map || d['salz'] != dienst.salz) return;
      final geladen = notizenAusAblage(daten.texte, d['notizen']);
      if (geladen.isEmpty) return;
      final jetzt = Map.of(_notizen);
      _notizen
        ..clear()
        ..addAll(geladen)
        ..addAll(jetzt);
      notifyListeners();
    } catch (e) {
      debugPrint('ONLINE notizen lesen $e');
    } finally {
      _notizenBereit = true;
      if (!_entsorgt && _notizen.isNotEmpty) _notizenSichern();
    }
  }

  bool _notizenBereit = false;

  void _notizenSichern() {
    final stand = jsonEncode({'salz': dienst.salz, 'notizen': notizenFuerAblage(_notizen.values)});
    unawaited(() async {
      try {
        await dienst.ablage.schreiben(GastgeberDienst.notizSchluessel, stand);
      } catch (e) {
        debugPrint('ONLINE notizen schreiben $e');
      }
    }());
  }

  // ------------------------------------------------------------ Befragungen

  /// Die Befragungskarten des Detektivs stehen im privaten Teil der eigenen
  /// Ansicht (A-051); die Antwort einer App-Rolle erst nach der Frage.
  @override
  List<BefragungKarte> get befragungen => befragungsKartenAus(jMap(dienst.ansicht['privat']));

  @override
  int get befragungenFrei => jZahl(jMap(dienst.ansicht['privat'])['befragungenFrei']);

  /// Der Raum entscheidet mit [kannWeiter], ob die Befragungen der Runde durch sind.
  @override
  bool get befragungenFertig => phase != PartyPhase.gespraeche || dienst.ansicht['kannWeiter'] == true;

  final Map<String, BefragungKarte> _notizen = {};

  @override
  List<BefragungKarte> get befragungsNotizen => List.unmodifiable(_notizen.values);

  @override
  void befragen(String id, int frage) => _senden([
        {'typ': 'befragen', 'id': id, 'frage': frage},
      ]);

  @override
  void befragungErledigt(String id) => _senden([
        {'typ': 'erledigt', 'id': id},
      ]);

  // ---------------------------------------------------------------- Lesen

  /// Rollen, deren Gerät die Rollenkarte schon gelesen hat.
  Set<String> get gelesen => dienst.raum.gelesen;

  /// Rollen, die in dieser Runde schon gestimmt haben (Bots stimmen selbst).
  Set<String> get gestimmt => dienst.raum.gestimmt;

  /// Rollen, die ein Mensch an einem Gerät spielt (der Rest sind Bots).
  List<String> get menschenRollen => [for (final s in dienst.gaeste) if (s.rolle != null) s.rolle!];

  /// Name am Tisch, der als Nächster würfelt, sonst die Rolle der Reihe nach.
  @override
  String get wuerfelPate {
    final n = dienst.nameVon(dienst.raum.wuerfelPate);
    return n.isEmpty ? super.wuerfelPate : n;
  }

  @override
  bool get darfWuerfeln {
    final pate = dienst.raum.wuerfelPate;
    return pate != null && pate == dienst.verb.spielerId;
  }

  /// Der Raum entscheidet mit: In der Rollenphase müssen alle Rollenkarten
  /// gelesen sein, und „Weiter“ drückt nur, wer leitet ([leitet]).
  @override
  bool get kannWeiter => abschnittFertig && leitet;

  /// Fertig nach Partie und Raum, egal wer weiterführt.
  @override
  bool get abschnittFertig => super.kannWeiter && dienst.ansicht['kannWeiter'] == true;

  @override
  List<String> get offeneWaehler => [for (final r in besetzt) if (!gestimmt.contains(r)) r];

  @override
  bool get alleGestimmt => phase == PartyPhase.gruppenwahl && spiel.qualitaeten.containsKey(runde);

  // --------------------------------------------------------------- Befehle

  void _senden(List<Map<String, Object?>> befehle) {
    unawaited(() async {
      try {
        for (final c in befehle) {
          await dienst.verb.befehl(c);
        }
      } on AbendFehler catch (e) {
        _fehler = e.key;
        if (!_entsorgt) notifyListeners();
      } catch (_) {
        _fehler = 'invalid';
        if (!_entsorgt) notifyListeners();
      }
    }());
  }

  @override
  void weiter() => _senden([
        {'typ': 'weiter'},
      ]);

  @override
  void bestaetigen({bool gruendlich = false, String? karte}) {
    final z = vorschlag ?? (throw StateError('kein Vorschlag'));
    vorschlagLoeschen();
    _senden([
      {'typ': 'wahl', 'option': z.option, if (gruendlich) 'gruendlich': true, 'karte': ?karte},
    ]);
  }

  @override
  bool aktionFertig(int nummer) {
    final z = zug;
    if (z == null || z.phase != RundenZugPhase.aktion || z.aktion != nummer) return false;
    _senden([
      {'typ': 'aktionFertig', 'aktion': nummer},
    ]);
    return true;
  }

  @override
  void wuerfeln({bool marke = false, String? karte}) {
    if (!darfWuerfeln) return;
    // Immer den eigenen Stand mitschicken: Ein früherer Würfelpate (Gast) kann im
    // Raum Marke oder Werkzeug angehakt haben, die sonst still in diesen Wurf einflössen.
    _senden([
      {'typ': 'wuerfelHilfe', 'marke': marke, 'karte': ?karte},
      {'typ': 'wurf'},
    ]);
  }

  @override
  void tischruf(Tischruf ruf, {String? karte}) => _senden([
        {'typ': 'tischruf', 'ruf': ruf.name, 'karte': ?karte},
      ]);

  @override
  void fundGelesen() => _senden([
        {'typ': 'fundGelesen'},
      ]);

  @override
  void starteAbstecher(String id, {String? karte}) {
    vorschlagLoeschen();
    _senden([
      {'typ': 'abstecher', 'ort': id, 'karte': ?karte},
    ]);
  }

  @override
  KartenDef karteSpielen(String id) {
    final k = vorrat.karte(id) ?? (throw const KartenFehler('card_unknown'));
    _senden([
      {'typ': 'karte', 'id': id},
    ]);
    return k;
  }

  @override
  void anklagen(String person) => _senden([
        {'typ': 'anklage', 'person': person},
      ]);

  /// Der Gastgeber stimmt nicht mit ab; die Gäste stimmen auf ihren Geräten.
  @override
  void stimme(String rolle, {required bool kooperativ}) => throw StateError('Online stimmen die Gäste auf ihren Geräten.');

  @override
  void kartenAnlegen({TischVorrat? vorrat, List<AbstecherOrt> abstecher = const []}) =>
      throw StateError('Der Tischvorrat steht beim Start des Abends fest.');

  @override
  void dispose() {
    if (_entsorgt) return;
    _entsorgt = true;
    _fristUhr?.cancel();
    _fristUhr = null;
    _aktionsUhr?.cancel();
    _aktionsUhr = null;
    unawaited(_hoerer?.cancel());
    _hoerer = null;
    // Ist der Abend vorbei, ist er auch abgelegt zu Ende; sonst bleibt der Stand
    // liegen, und die Gäste warten auf die Rückkehr des Gastgebers.
    unawaited(dienst.schliessen(endgueltig: phase == PartyPhase.ende));
    super.dispose();
  }
}
