/// Gemeinsame Schnittstelle aller Wege zu einem Abend-Raum: im selben Prozess
/// ([LokaleVerbindung]), über das Relais als Gast ([RelayGast]) oder später
/// über den Dart-Server. Die App-Bildschirme kennen nur diese Schnittstelle.
library;

import 'dart:async';

/// Zustand einer Verbindung zum Abend.
enum VerbindungsStatus {
  /// Erster Aufbau oder Wiederaufbau, noch keine gültige Antwort des Gastgebers.
  verbinde,

  /// Verbindung steht, der Gastgeber ist da.
  verbunden,

  /// Das Relais ist nicht erreichbar (wird automatisch wieder versucht).
  getrennt,

  /// Das Relais ist erreichbar, aber der Gastgeber ist gerade weg
  /// (Hintergrund, kurzer Abbruch). Der Abend ist angehalten, nicht beendet.
  pausiert,

  /// Endgültig vorbei (selbst gegangen, Gastgeber hat geschlossen, abgewiesen).
  geschlossen,
}

/// Fehler mit festem Schlüssel, niemals mit Nutzdaten. Die Schlüssel des Raums
/// (`not_host`, `invalid_phase`, …) werden unverändert durchgereicht; dazu
/// kommen Transportschlüssel wie `zeitueberschreitung`, `getrennt`, `voll`,
/// `proto`, `gestartet`, `geschlossen`, `kein_raum`.
class AbendFehler implements Exception {
  const AbendFehler(this.key);
  final String key;
  @override
  String toString() => 'AbendFehler: $key';
}

/// Ein Gerät am Abend. Die Ansichten sind die Positivliste des Raums
/// (`AbendRaum.zustandFuer`) für genau dieses Gerät.
abstract interface class AbendVerbindung {
  String get raumCode;

  /// Eigene Spieler-ID im Raum, sobald bekannt.
  String? get spielerId;

  /// Volle Ansichten. Jeder neue Zuhörer bekommt zuerst die letzte bekannte.
  Stream<Map<String, Object?>> get ansichten;

  /// Jeder neue Zuhörer bekommt zuerst den aktuellen Zustand.
  Stream<VerbindungsStatus> get status;

  /// Schickt eine Raumnachricht und wartet auf die Bestätigung des Gastgebers.
  /// Wirft [AbendFehler] mit dem Schlüssel der Ablehnung.
  Future<void> befehl(Map<String, Object?> c);

  /// Verlässt den Abend endgültig.
  Future<void> verlassen();
}

/// Kleiner „BehaviorSubject“: merkt sich den letzten Wert und gibt ihn jedem
/// neuen Zuhörer zuerst. Läuft auf VM und Web (nur `dart:async`).
class LetzterWert<T> {
  LetzterWert([T? anfang]) {
    if (anfang != null) {
      _wert = anfang;
      _hat = true;
    }
  }

  final StreamController<T> _ctrl = StreamController<T>.broadcast(sync: true);
  T? _wert;
  bool _hat = false;
  bool _zu = false;

  bool get hat => _hat;
  T? get wert => _wert;
  bool get geschlossen => _zu;

  void add(T v) {
    if (_zu) return;
    _wert = v;
    _hat = true;
    _ctrl.add(v);
  }

  Stream<T> get strom => Stream<T>.multi((c) {
        if (_hat && !c.isClosed) c.add(_wert as T);
        if (_zu) {
          c.close();
          return;
        }
        final sub = _ctrl.stream.listen(c.add, onError: c.addError, onDone: c.close);
        c.onCancel = sub.cancel;
      });

  Future<void> schliessen() async {
    if (_zu) return;
    _zu = true;
    await _ctrl.close();
  }
}
