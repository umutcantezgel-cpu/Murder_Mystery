import 'dart:async';

import 'package:mordakte_core/mordakte_core.dart';
import 'package:mordakte_core/runden.dart';
import 'package:mordakte_netz/mordakte_netz.dart' show AbendFehler;

import '../../party/sitzung.dart';
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

  void _abgleichen() {
    if (_entsorgt) return;
    final n = jListe(dienst.ansicht['erzaehler']).length;
    raumGeaendert(erzaehlerAb: spiel.bausteine.length - n);
  }

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
    _senden([
      if (marke || karte != null) {'typ': 'wuerfelHilfe', 'marke': marke, 'karte': ?karte},
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
