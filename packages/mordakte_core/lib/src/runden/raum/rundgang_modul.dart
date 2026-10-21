import '../../party/ablauf.dart';
import '../../welt/vorspiel_morgen.dart';
import '../schlosskeller_raum.dart' show PartyRaumFehler;
import 'raum_modul.dart';

/// Vorspiel und Morgen im Online-Abend (Langer Abend M7b, `welt/vorspiel_morgen.dart`).
///
/// Der Raum nimmt das Modul nur im langen Abend und nur in Akten mit Vorspiel
/// und Morgen. In der Einleitung läuft dann zuerst das Vorspiel, im Ende der
/// Morgen, je Station für Station; die Phasen bleiben, wie sie sind.
///
/// - Nachricht `rundgang {station}`: zur nächsten Station; [station] ist die
///   Station, von der aus es weitergeht (sonst `stale`, ein doppelter Tipp
///   überspringt nichts). Nach der letzten ist der Rundgang fertig.
///   `rundgang {ueberspringen: true}` beendet ihn sofort. Beides nur von dem
///   Gerät, das leitet ([RaumKontext.darfLeiten]), und nur, solange er läuft.
/// - Öffentlich `rundgang` (für alle gleich): Teil, Station, Zahl der
///   Stationen, Uhrzeit und die Karte der Station nach R17 (Titel,
///   Stichpunkte). Nie der Vorlesetext: Den bekommt nur der Vorleser privat
///   (`rundgangText`). Am Morgen gilt der Text zum gezogenen Ende.
/// - Solange das Vorspiel läuft, geht es nicht weiter in die Runden
///   ([darfWeiter]); solange der Morgen läuft, ist der Abend nicht beendet
///   ([haeltOffen]: Der Server räumt den Raum erst danach ab).
///
/// Das Modul ändert nie die Partie: kein Würfel, keine Nachtminuten, keine
/// Wertung.
class RundgangModul extends RaumModul {
  RundgangModul(this.inhalt);

  /// Vorspiel und Morgen der Akte.
  final VorspielMorgen inhalt;

  final Set<RundgangTeil> _fertig = {};
  int _station = 0;

  /// Laufender Rundgang in der Phase von [k], sonst `null`.
  RundgangTeil? laufend(RaumKontext k) {
    final teil = switch (k.phase) {
      PartyPhase.intro => RundgangTeil.vorspiel,
      PartyPhase.ende => RundgangTeil.morgen,
      _ => null,
    };
    return teil == null || _fertig.contains(teil) ? null : teil;
  }

  /// Station des laufenden Rundgangs (ab 0).
  int get station => _station;

  @override
  Map<String, Set<String>> get nachrichten => const {
        'rundgang': {'station', 'ueberspringen'},
      };

  @override
  void nachricht(RaumKontext k, String id, String typ, Map<String, Object?> inhalt) {
    k.darfLeiten(id);
    final teil = laufend(k) ?? (throw const PartyRaumFehler('invalid_phase'));
    final ueberspringen = inhalt['ueberspringen'];
    final station = inhalt['station'];
    if (ueberspringen != null) {
      if (ueberspringen != true || station != null) throw const PartyRaumFehler('invalid');
      _fertig.add(teil);
      return;
    }
    if (station is! int) throw const PartyRaumFehler('invalid');
    if (station != _station) throw const PartyRaumFehler('stale');
    if (_station + 1 >= this.inhalt.rundgang(teil).stationen.length) {
      _fertig.add(teil);
    } else {
      _station++;
    }
  }

  @override
  bool darfWeiter(RaumKontext k) => laufend(k) != RundgangTeil.vorspiel;

  @override
  bool haeltOffen(RaumKontext k) => laufend(k) == RundgangTeil.morgen;

  @override
  void beimStart(RaumKontext k) => _station = 0;

  @override
  void phaseGewechselt(RaumKontext k) => _station = 0;

  /// Station und Text des laufenden Rundgangs, am Morgen zum gezogenen Ende.
  (RundgangTeil, RundgangStation, RundgangText)? _aktuell(RaumKontext k) {
    final teil = laufend(k);
    if (teil == null) return null;
    final stationen = inhalt.rundgang(teil).stationen;
    final st = stationen[_station.clamp(0, stationen.length - 1)];
    final ende = teil == RundgangTeil.morgen ? k.partie?.spiel.ende.id : null;
    return (teil, st, st.textFuer(ende));
  }

  @override
  Map<String, Object?> oeffentlich(RaumKontext k, String id) {
    final a = _aktuell(k);
    if (a == null) return const {};
    final (teil, st, text) = a;
    return {
      'rundgang': {
        'teil': teil.name,
        'station': _station,
        'anzahl': inhalt.rundgang(teil).stationen.length,
        'id': st.id,
        'zeit': '${st.zeit}',
        'karte': text.karteJson(),
      },
    };
  }

  @override
  Map<String, Object?> privat(RaumKontext k, String id) {
    final a = _aktuell(k);
    if (a == null || id != k.vorleser) return const {};
    return {'rundgangText': a.$3.vorlesen};
  }
}
