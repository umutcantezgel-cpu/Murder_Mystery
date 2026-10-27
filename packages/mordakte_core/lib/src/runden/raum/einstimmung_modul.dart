import '../../party/ablauf.dart';
import '../../party/einstimmung.dart';
import '../schlosskeller_raum.dart' show PartyRaumFehler;
import 'raum_modul.dart';

/// Vorgeschichte und Vorstellung im Online-Abend (Einstimmung, A-063,
/// `party/einstimmung.dart`).
///
/// Der Raum nimmt das Modul nur, wenn die Spielleitung die Einstimmung
/// eingeschaltet hat und die Akte eine hat. Sie läuft zu Beginn der
/// Einleitung, vor Vorspiel und Diashow; die Phasen bleiben, wie sie sind.
///
/// - Nachricht `einstimmung {schritt}`: zum nächsten Schritt; [schritt] ist der
///   Schritt, von dem aus es weitergeht (sonst `stale`, ein doppelter Tipp
///   überspringt nichts). `einstimmung {ueberspringen: true}` überspringt den
///   Rest des laufenden Teils (Vorgeschichte oder Vorstellung). Beides nur von
///   dem Gerät, das leitet ([RaumKontext.darfLeiten]), und nur, solange sie läuft.
/// - Öffentlich `einstimmung` (für alle gleich): Teil, Schritt, Zahl der
///   Schritte, Nummer im Teil, Kennung des Bausteins und die vorgestellte
///   Figur. Nie der Text: Den bekommt nur der Vorleser privat
///   (`einstimmungText`); fällt er aus, wandert der Text mit der Leitung.
/// - Solange die Einstimmung läuft, geht es nicht weiter ([darfWeiter]), und
///   das Vorspiel wartet ([laeuft] als `wartet` des Rundgangs).
///
/// Das Modul ändert nie die Partie: kein Baustein in `spiel.bausteine`, kein
/// Würfel, keine Nachtminuten, keine Wertung. Die Schritte hängen nur an
/// Rollenzahl und Detektiv, nie am Pfad.
class EinstimmungModul extends RaumModul {
  EinstimmungModul(this.einstimmung);

  final Einstimmung einstimmung;
  EinstimmungLauf? _lauf;

  /// Lauf des Abends (ab dem Start), sonst `null`.
  EinstimmungLauf? get lauf => _lauf;

  /// Läuft die Einstimmung gerade (Einleitung, noch nicht fertig)?
  bool laeuft(RaumKontext k) => k.phase == PartyPhase.intro && !(_lauf?.fertig ?? true);

  @override
  Map<String, Set<String>> get nachrichten => const {
        'einstimmung': {'schritt', 'ueberspringen'},
      };

  @override
  void nachricht(RaumKontext k, String id, String typ, Map<String, Object?> inhalt) {
    k.darfLeiten(id);
    final lauf = _lauf;
    if (lauf == null || !laeuft(k)) throw const PartyRaumFehler('invalid_phase');
    final ueberspringen = inhalt['ueberspringen'];
    final schritt = inhalt['schritt'];
    if (ueberspringen != null) {
      if (ueberspringen != true || schritt != null) throw const PartyRaumFehler('invalid');
      lauf.ueberspringen();
      return;
    }
    if (schritt is! int) throw const PartyRaumFehler('invalid');
    if (!lauf.weiter(schritt)) throw const PartyRaumFehler('stale');
  }

  @override
  bool darfWeiter(RaumKontext k) => !laeuft(k);

  @override
  void beimStart(RaumKontext k) {
    final e = k.partie!.spiel.einstellungen;
    _lauf = EinstimmungLauf(einstimmung.schritte(rollen: e.rollen, detektiv: e.detektiv));
  }

  @override
  Map<String, Object?> oeffentlich(RaumKontext k, String id) {
    final lauf = _lauf;
    final s = lauf?.aktuell;
    if (lauf == null || s == null || !laeuft(k)) return const {};
    return {
      'einstimmung': {
        'teil': s.teil.name,
        'schritt': lauf.schritt,
        'anzahl': lauf.schritte.length,
        'nr': s.nr,
        'von': s.von,
        'kennung': s.kennung,
        'figur': ?s.figur,
      },
    };
  }

  @override
  Map<String, Object?> privat(RaumKontext k, String id) {
    final s = _lauf?.aktuell;
    if (s == null || !laeuft(k) || id != k.vorleser) return const {};
    return {'einstimmungText': k.texte.baustein(s.kennung)};
  }
}
