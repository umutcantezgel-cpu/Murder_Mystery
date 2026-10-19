import '../../party/ablauf.dart';
import '../schlosskeller_raum.dart' show PartyRaumFehler;
import 'raum_modul.dart';

/// Diashow der Einleitung im Online-Abend (Langer Abend M4, `party/diashow.dart`).
///
/// Nachricht `dia {nr}`, nur in der Einleitung und nur von dem Gerät, das
/// gerade leitet ([RaumKontext.darfLeiten]): Alle Geräte zeigen das Bild [nr]
/// (ab 0) der Diashow der Akte. Die Bilder selbst rendert jedes Gerät aus der
/// Akte; öffentlich ist nur der Zähler `dia`, nie ein Text. Den Erzähltext zum
/// Bild sieht wie bisher nur der Vorleser-Sitz.
///
/// Der Raum nimmt das Modul nur in Akten mit Diashow; ohne bleibt die
/// Einleitung wie bisher.
class DiaModul extends RaumModul {
  DiaModul({required this.anzahl}) {
    if (anzahl < 1) throw ArgumentError.value(anzahl, 'anzahl');
  }

  /// Zahl der Bilder der Diashow.
  final int anzahl;

  int _dia = 0;

  /// Laufendes Bild (ab 0).
  int get dia => _dia;

  @override
  Map<String, Set<String>> get nachrichten => const {
        'dia': {'nr'},
      };

  @override
  void nachricht(RaumKontext k, String id, String typ, Map<String, Object?> inhalt) {
    k.darfLeiten(id);
    if (k.phase != PartyPhase.intro) throw const PartyRaumFehler('invalid_phase');
    final nr = inhalt['nr'];
    if (nr is! int || nr < 0 || nr >= anzahl) throw const PartyRaumFehler('invalid');
    _dia = nr;
  }

  @override
  void phaseGewechselt(RaumKontext k) => _dia = 0;

  @override
  Map<String, Object?> oeffentlich(RaumKontext k, String id) => k.phase == PartyPhase.intro ? {'dia': _dia} : const {};
}
