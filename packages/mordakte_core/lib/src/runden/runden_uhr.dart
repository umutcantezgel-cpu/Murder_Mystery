/// Gemeinsame Rundenuhr (Langer Abend M4): Die Gesprächszeit läuft für alle
/// gleich, online wie an einem Gerät.
///
/// Die Uhr ist reiner Zustand ohne Takt: Beginn, Dauer, ob sie steht und was
/// beim Anhalten übrig war. Jedes Gerät rechnet die Restzeit selbst aus der
/// Abendzeit ([rest]); in der Ansicht des Raums steht nie ein tickendes Feld,
/// sie ändert sich nur bei Start, Pause, Weiter und Zugabe.
///
/// Abendzeit heißt: Millisekunden der Uhr des Geräts, das den Abend hält
/// (Gastgeber, Server, an einem Gerät dieses selbst). Online kommt sie nie vom
/// Gast: Der Transport stempelt jede Nachricht mit [abendZeitFeld], bevor der
/// Raum sie sieht ([mitAbendzeit]); so spielt ein Neustart des Gastgebers das
/// Protokoll mit denselben Zeiten wieder ein. Gäste rechnen die Abendzeit aus
/// dem Versatz zum Gastgeber (Feld `ht` im `pong` des Relais).
library;

/// Feld der Abendzeit in einer Raumnachricht. Nur der Transport setzt es; was
/// ein Gerät selbst dort mitschickt, überschreibt er.
const abendZeitFeld = 'zeit';

/// [inhalt] mit der Abendzeit [zeit] des Transports; ein mitgeschicktes
/// [abendZeitFeld] fällt dabei weg.
Map<String, Object?> mitAbendzeit(Map<String, Object?> inhalt, int zeit) => {...inhalt, abendZeitFeld: zeit};

/// Aktionen der Nachricht `uhr`.
enum UhrAktion {
  /// Uhr auf die volle Dauer stellen und laufen lassen (auch neu, wenn sie schon lief).
  start,

  /// Anhalten; die Restzeit bleibt stehen.
  pause,

  /// Nach einer Pause weiterlaufen lassen.
  weiter,

  /// Minuten dazugeben (laufend, stehend oder vor dem Start).
  plus;

  /// Aktion aus ihrem Namen, sonst `null`.
  static UhrAktion? lesen(Object? name) => values.where((a) => a.name == name).firstOrNull;
}

/// Zustand der Uhr einer Runde, unveränderlich; jede Aktion liefert einen neuen.
class RundenUhr {
  const RundenUhr._({required this.dauer, this.start, this.pausiert = true, this.restBeiPause});

  /// Eine gestellte, noch nicht gestartete Uhr mit [dauer] Millisekunden.
  factory RundenUhr.neu(int dauer) {
    if (dauer <= 0 || dauer > hoechstDauer) throw ArgumentError.value(dauer, 'dauer');
    return RundenUhr._(dauer: dauer);
  }

  /// Eine Uhr mit [minuten] Minuten.
  factory RundenUhr.minuten(int minuten) => RundenUhr.neu(minuten * minute);

  static const minute = 60000;

  /// Länger läuft keine Runde, auch nicht mit Zugaben (drei Stunden).
  static const hoechstDauer = 180 * minute;

  /// So viele Minuten nimmt `start` bzw. `plus` höchstens auf einmal.
  static const hoechstStart = 120, hoechstPlus = 60;

  /// Volle Dauer in Millisekunden, mit allen Zugaben.
  final int dauer;

  /// Abendzeit (ms), ab der die volle [dauer] zählt; `null`: noch nie gestartet.
  /// Nach einer Pause rückt sie nach, sodass die Restzeit stimmt.
  final int? start;

  /// Steht die Uhr (vor dem Start oder angehalten)?
  final bool pausiert;

  /// Restzeit beim Anhalten (ms); nur bei einer angehaltenen, gestarteten Uhr.
  final int? restBeiPause;

  bool get gestartet => start != null;

  /// Läuft die Uhr (auch wenn ihre Zeit um ist)?
  bool get laeuft => gestartet && !pausiert;

  /// Restzeit in Millisekunden zur Abendzeit [jetzt], zwischen 0 und [dauer].
  int rest(int jetzt) {
    final s = start;
    if (s == null) return dauer;
    if (pausiert) return (restBeiPause ?? dauer).clamp(0, dauer);
    return (dauer - (jetzt - s)).clamp(0, dauer);
  }

  /// Ist die Zeit um (gestartet und nichts mehr übrig)?
  bool abgelaufen(int jetzt) => gestartet && rest(jetzt) == 0;

  /// Wendet [aktion] zur Abendzeit [zeit] an. [minuten]: bei `start` die neue
  /// Dauer (sonst bleibt sie), bei `plus` die Zugabe (Pflicht).
  ///
  /// Wirft [StateError], wenn die Aktion gerade nicht passt (Pause einer
  /// stehenden Uhr, Weiter ohne Pause), und [ArgumentError] bei unzulässigen
  /// Minuten oder einer Dauer über [hoechstDauer].
  RundenUhr aktion(UhrAktion aktion, {required int zeit, int? minuten}) {
    switch (aktion) {
      case UhrAktion.start:
        if (minuten != null && (minuten < 1 || minuten > hoechstStart)) throw ArgumentError.value(minuten, 'minuten');
        return RundenUhr._(dauer: minuten == null ? dauer : minuten * minute, start: zeit, pausiert: false);
      case UhrAktion.pause:
        if (!laeuft) throw StateError('Die Uhr läuft nicht.');
        if (minuten != null) throw ArgumentError.value(minuten, 'minuten');
        return RundenUhr._(dauer: dauer, start: start, restBeiPause: rest(zeit));
      case UhrAktion.weiter:
        if (!gestartet || !pausiert) throw StateError('Die Uhr steht nicht.');
        if (minuten != null) throw ArgumentError.value(minuten, 'minuten');
        // Der Beginn rückt so nach, dass ab jetzt genau die angehaltene Restzeit bleibt.
        return RundenUhr._(dauer: dauer, start: zeit - (dauer - rest(zeit)), pausiert: false);
      case UhrAktion.plus:
        if (minuten == null || minuten < 1 || minuten > hoechstPlus) throw ArgumentError.value(minuten, 'minuten');
        final zugabe = minuten * minute;
        if (dauer + zugabe > hoechstDauer) throw ArgumentError.value(minuten, 'minuten', 'Die Runde würde zu lang.');
        final s = start;
        if (s == null) return RundenUhr._(dauer: dauer + zugabe);
        if (pausiert) return RundenUhr._(dauer: dauer + zugabe, start: s, restBeiPause: rest(zeit) + zugabe);
        // Ist die Zeit schon um, zählt die Zugabe ab jetzt, nicht ab dem Ablauf.
        final beginn = zeit - s > dauer ? zeit - dauer : s;
        return RundenUhr._(dauer: dauer + zugabe, start: beginn, pausiert: false);
    }
  }

  /// Öffentliche Form `{dauer, start?, pausiert, restBeiPause?}` (ohne Takt).
  Map<String, Object?> toJson() => {
        'dauer': dauer,
        'start': ?start,
        'pausiert': pausiert,
        'restBeiPause': ?restBeiPause,
      };

  /// Liest [toJson]; `null` ohne oder mit unbrauchbarer Uhr.
  static RundenUhr? ausJson(Object? j) {
    if (j is! Map) return null;
    final dauer = j['dauer'], start = j['start'], pausiert = j['pausiert'], rest = j['restBeiPause'];
    if (dauer is! int || dauer <= 0 || pausiert is! bool || (start != null && start is! int) || (rest != null && rest is! int)) return null;
    return RundenUhr._(dauer: dauer, start: start as int?, pausiert: pausiert, restBeiPause: rest as int?);
  }

  @override
  bool operator ==(Object other) =>
      other is RundenUhr && other.dauer == dauer && other.start == start && other.pausiert == pausiert && other.restBeiPause == restBeiPause;

  @override
  int get hashCode => Object.hash(dauer, start, pausiert, restBeiPause);

  @override
  String toString() => 'RundenUhr${toJson()}';
}
