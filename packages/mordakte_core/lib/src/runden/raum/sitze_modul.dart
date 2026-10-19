import '../../karten/klassen.dart';
import '../schlosskeller_raum.dart' show PartyRaumFehler;
import '../sitze.dart';
import 'raum_modul.dart';

/// Lobby des Online-Abends (Langer Abend M3): Sitze, Rollenzahl, Figurenwahl.
///
/// Nachrichten, alle nur vor dem Start (danach `game_running`):
/// - `sitz {spieler, sitz, klasse?}`: nur der Gastgeber. Setzt ein Gerät auf
///   den Detektiv- (`detektiv`) oder Erzähler-Sitz (`erzaehler`) oder nimmt ihm
///   den Sitz (`null`). `klasse` (eine Detektivklasse wie `forensic`) gilt nur
///   für den Detektiv-Sitz. Die Klasse reist mit dem Sitz: Das Gerät auf dem
///   Detektiv-Sitz darf sie selbst setzen, mit `sitz` auf sich und `detektiv`.
/// - `besetzung {rollen}`: Rollenzahl n (liegt im Raum, für alle sichtbar).
/// - `zuteilen {spieler, rolle}`: Figur für ein Gerät ohne Sitz, nur aus den
///   besetzten Figuren bei n; `null` heißt Zufall beim Start. Tausch, wenn ein
///   anderes Gerät die Figur hält.
/// - `wunsch {rolle}`: jedes Gerät, ein Hinweis für die Zuteilung.
///
/// `besetzung` und `zuteilen` dürfen der Gastgeber, der Detektiv- und der
/// Erzähler-Sitz ([RaumKontext.darfLeiten]). Wessen Sitz oder Figur sich
/// ändert, muss wieder `bereit` melden. Der Start verteilt danach die Rollen
/// ([Sitzplan.verteile]); die Ansicht trägt Sitz, Figur und Wunsch je Gerät.
class SitzeModul extends RaumModul {
  /// Der Plan dieses Raums; der Raum liest ihn für Rechte, Start und Ansicht.
  final Sitzplan plan = Sitzplan();

  @override
  Map<String, Set<String>> get nachrichten => const {
        'sitz': {'spieler', 'sitz', 'klasse'},
        'besetzung': {'rollen'},
        'zuteilen': {'spieler', 'rolle'},
        'wunsch': {'rolle'},
      };

  @override
  bool vorStart(String typ) => true;

  @override
  void nachricht(RaumKontext k, String id, String typ, Map<String, Object?> inhalt) {
    if (k.partie != null) throw const PartyRaumFehler('game_running');
    switch (typ) {
      case 'sitz':
        final ziel = _geraet(k, inhalt);
        final sitz = inhalt['sitz'] == null ? null : (Sitz.lesen(inhalt['sitz']) ?? (throw const PartyRaumFehler('invalid')));
        if (sitz != null && !sitz.vergeben) throw const PartyRaumFehler('invalid');
        final klasseSetzen = inhalt.containsKey('klasse');
        final klasse = inhalt['klasse'];
        if (klasse != null && (klasse is! String || KlassenFaehigkeit.vonKlasse(klasse) == null || sitz != Sitz.detektiv)) {
          throw const PartyRaumFehler('invalid');
        }
        // Die Klasse setzt das Gerät auf dem Detektiv-Sitz selbst; alles andere nur der Gastgeber.
        final eigeneKlasse = id == ziel && sitz == Sitz.detektiv && plan.detektiv == id && klasseSetzen;
        if (!eigeneKlasse) k.nurHost(id);
        _aufheben(k, plan.setze(ziel, sitz, klasse: klasse as String?, klasseSetzen: klasseSetzen));
      case 'besetzung':
        k.darfLeiten(id);
        final n = inhalt['rollen'];
        final b = k.texte.besetzung;
        if (n is! int || n < b.minRollen || n > b.maxRollen) throw const PartyRaumFehler('invalid');
        _aufheben(k, plan.setzeRollen(n, b.besetzt(n)));
      case 'zuteilen':
        k.darfLeiten(id);
        final ziel = _geraet(k, inhalt);
        final rolle = inhalt['rolle'];
        final n = plan.rollen;
        if (n == null || (rolle != null && rolle is! String) || plan.sitzt(ziel)) throw const PartyRaumFehler('invalid');
        final besetzt = k.texte.besetzung.besetzt(n);
        if (rolle != null && !besetzt.contains(rolle)) throw const PartyRaumFehler('invalid');
        _aufheben(k, plan.zuteilen(ziel, rolle as String?, besetzt));
      case 'wunsch':
        final rolle = inhalt['rolle'];
        if (rolle != null && (rolle is! String || !k.texte.besetzung.reihenfolge.contains(rolle))) {
          throw const PartyRaumFehler('invalid');
        }
        plan.wuenscht(id, rolle as String?);
    }
  }

  /// Zielgerät aus `spieler`: ein Gerät im Raum (nur Ziel, nie Absender).
  static String _geraet(RaumKontext k, Map<String, Object?> inhalt) {
    final ziel = inhalt['spieler'];
    if (ziel is! String || !k.spielerIds.contains(ziel)) throw const PartyRaumFehler('invalid');
    return ziel;
  }

  static void _aufheben(RaumKontext k, Set<String> betroffen) {
    for (final b in betroffen) {
      k.bereitAufheben(b);
    }
  }

  /// Die Klasse des Detektiv-Sitzes sehen nur dieses Gerät und der Gastgeber.
  /// Ab dem Start bleibt sie beim Sitz, auch wenn der Gastgeber ihn neu
  /// vergibt (`detektivNeu`): Dann sieht sie, wer jetzt ermittelt.
  @override
  Map<String, Object?> privat(RaumKontext k, String id) {
    final klasse = plan.klasse;
    final detektiv = k.partie == null ? plan.detektiv : k.detektiv;
    if (klasse == null || (id != detektiv && id != k.host)) return const {};
    return {'klasse': klasse};
  }
}
