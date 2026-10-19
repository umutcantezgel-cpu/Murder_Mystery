import '../../party/ablauf.dart';
import '../runden_uhr.dart';
import '../schlosskeller_raum.dart' show PartyRaumFehler;
import 'raum_modul.dart';

/// Gemeinsame Rundenuhr im Online-Abend (Langer Abend M4, `runden_uhr.dart`).
///
/// Nachricht `uhr {aktion, minuten?}`, nur in den Gesprächen und nur von dem
/// Gerät, das gerade leitet ([RaumKontext.darfLeiten]: der Erzähler, sonst der
/// Detektiv, sonst der Gastgeber):
/// - `start` stellt die Uhr auf die volle Dauer ([minuten] der Einrichtung
///   oder `minuten`) und lässt sie laufen,
/// - `pause` hält sie an, `weiter` lässt sie weiterlaufen,
/// - `plus {minuten}` gibt Zeit dazu (am Tisch meist fünf Minuten).
///
/// Die Abendzeit jeder Aktion kommt nur vom Transport ([abendZeitFeld]);
/// fehlt sie, ist die Nachricht `invalid`. So bleibt der Raum frei von einer
/// eigenen Uhr, und das Protokoll spielt sich nach einem Neustart gleich ein.
///
/// Mit jeder Runde, also beim Übergang in die Gespräche, steht die Uhr wieder
/// auf der vollen Dauer, noch nicht gestartet. Öffentlich ist nur ihr Zustand
/// (`uhr`, [RundenUhr.toJson]), solange die Gespräche laufen; die Restzeit
/// rechnet jedes Gerät selbst.
class UhrModul extends RaumModul {
  UhrModul({this.minuten = 30}) {
    if (minuten < 1 || minuten > RundenUhr.hoechstStart) throw ArgumentError.value(minuten, 'minuten');
  }

  /// Rundendauer der Einrichtung in Minuten.
  final int minuten;

  RundenUhr? _uhr;

  /// Uhr der laufenden Gespräche, sonst `null` (zum Lesen, etwa für Tests).
  RundenUhr? get uhr => _uhr;

  @override
  Map<String, Set<String>> get nachrichten => const {
        'uhr': {'aktion', 'minuten'},
      };

  @override
  void nachricht(RaumKontext k, String id, String typ, Map<String, Object?> inhalt) {
    k.darfLeiten(id);
    final uhr = _uhr;
    if (uhr == null || k.phase != PartyPhase.gespraeche) throw const PartyRaumFehler('invalid_phase');
    final zeit = inhalt[abendZeitFeld];
    final aktion = UhrAktion.lesen(inhalt['aktion']);
    final minuten = inhalt['minuten'];
    if (zeit is! int || zeit < 0 || aktion == null || (minuten != null && minuten is! int)) throw const PartyRaumFehler('invalid');
    // Falscher Zustand (StateError) und falsche Minuten (ArgumentError) übersetzt der Raum.
    _uhr = uhr.aktion(aktion, zeit: zeit, minuten: minuten as int?);
  }

  @override
  void beimStart(RaumKontext k) => _uhr = null;

  @override
  void phaseGewechselt(RaumKontext k) => _uhr = k.phase == PartyPhase.gespraeche ? RundenUhr.minuten(minuten) : null;

  @override
  Map<String, Object?> oeffentlich(RaumKontext k, String id) {
    final uhr = _uhr;
    if (uhr == null || k.phase != PartyPhase.gespraeche) return const {};
    return {'uhr': uhr.toJson()};
  }
}
