import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:mordakte_core/mordakte_core.dart';
import 'package:mordakte_core/runden.dart';
import 'package:mordakte_netz/mordakte_netz.dart' show AbendFehler;

import '../../party/sitzung.dart';
import '../../party/stand/befragung_stand.dart';
import 'ansicht.dart';
import 'gastgeber_dienst.dart';

/// Der Abend auf dem Gastgebergerät: Der Gastgeber ist der gemeinsame Detektiv
/// und nutzt dieselben Bildschirme wie beim Spiel an einem Gerät. Das Lesemodell
/// ist die Partie des Raums ([SchlosskellerRaum.partieFuerGastgeber]); jede
/// Eingabe geht als Raumnachricht über den Platz des Gastgebers
/// ([GastgeberDienst.verb]) hinaus und verändert die Partie nur dort. Nach jeder
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
    geburtstagskind = dienst.geburtstagskind;
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

  /// Letzte Ablehnung des Raums (fester Schlüssel wie `not_ready`) oder `null`.
  /// Der Bildschirm zeigt sie einmal und ruft dann [fehlerQuittieren].
  String? get letzterFehler => _fehler;

  void fehlerQuittieren() => _fehler = null;

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
    final n = jListe(dienst.ansicht['erzaehler']).length;
    // Antworten der App bleiben im Notizbuch, auch wenn die Ansicht sie nach den Gesprächen nicht mehr trägt.
    final vorher = _notizen.length;
    for (final k in befragungen) {
      if (k.antwort != null) _notizen[k.id] = k;
    }
    if (_notizen.length != vorher && _notizenBereit) _notizenSichern();
    raumGeaendert(erzaehlerAb: spiel.bausteine.length - n);
  }

  // ------------------------------------------------------ Notizbuch

  /// Das Notizbuch der Befragungen kennt nur dieses Gerät: Nach den Gesprächen
  /// trägt die Ansicht des Raums die Antworten nicht mehr. Damit es eine
  /// Rückkehr zum Abend übersteht, liegen Kennung, Frage und Art jeder
  /// beantworteten Befragung neben dem Raum in der Ablage, an das Salz dieses
  /// Abends gebunden. Die Antwort entsteht beim Laden wieder aus den
  /// Preisgaben, wie im Raum ([befragungsAntwort]). Geschrieben wird erst nach
  /// dem Laden, damit die Notizen der Runden davor nicht verloren gehen.
  Future<void> _notizenLaden() async {
    try {
      final roh = await dienst.ablage.lesen(GastgeberDienst.notizSchluessel);
      if (roh == null || _entsorgt) return;
      final d = jsonDecode(roh);
      if (d is! Map || d['salz'] != dienst.salz) return;
      final texte = daten.texte;
      final geladen = <String, BefragungKarte>{};
      for (final n in jMaps(d['notizen'])) {
        final b = texte.sammlung.befragungen[jText(n['id'])];
        final frage = n['frage'];
        if (b == null || frage is! int || frage < 0 || frage >= b.fragen.length) continue;
        geladen[b.id] = BefragungKarte(
          id: b.id, rolle: b.rolle, thema: b.thema, fragen: b.fragen, pflicht: n['pflicht'] == true,
          mensch: false, frage: frage, erledigt: true, waehlbar: false, antwort: befragungsAntwort(texte, b),
        );
      }
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
    final stand = jsonEncode({
      'salz': dienst.salz,
      'notizen': [
        for (final k in _notizen.values) {'id': k.id, 'frage': k.frage, 'pflicht': k.pflicht},
      ],
    });
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
  List<BefragungKarte> get befragungen {
    final privat = jMap(dienst.ansicht['privat']);
    final offen = jZahl(privat['befragungenFrei']);
    return [
      for (final k in jMaps(privat['befragungen']))
        BefragungKarte(
          id: jText(k['id']),
          rolle: jText(k['rolle']),
          thema: jText(k['thema']),
          fragen: jTexte(k['fragen']),
          pflicht: k['pflicht'] == true,
          mensch: k['mensch'] == true,
          frage: k['frage'] is int ? k['frage'] as int : null,
          erledigt: k['erledigt'] == true,
          waehlbar: k['pflicht'] == true || k['frage'] is int || offen > 0,
          antwort: k['antwort'] is List ? jTexte(k['antwort']) : null,
        ),
    ];
  }

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

  /// Der Raum entscheidet mit: In der Rollenphase müssen alle Rollenkarten gelesen sein.
  @override
  bool get kannWeiter => super.kannWeiter && dienst.ansicht['kannWeiter'] == true;

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
    unawaited(_hoerer?.cancel());
    _hoerer = null;
    // Ist der Abend vorbei, ist er auch abgelegt zu Ende; sonst bleibt der Stand
    // liegen, und die Gäste warten auf die Rückkehr der Spielleitung.
    unawaited(dienst.schliessen(endgueltig: phase == PartyPhase.ende));
    super.dispose();
  }
}
