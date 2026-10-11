/// Gemeinsame Schnittstelle eines autoritativen Abend-Raums, unabhängig vom
/// Transport (Dart-Server, Supabase-Relais auf dem Gastgebergerät, Tests).
///
/// Die Identität kommt immer vom Transport, nie aus einem Nachrichtenfeld.
abstract interface class AbendRaum {
  String get raumCode;
  int get version;
  int get maxSpieler;
  bool get vorStart;
  bool get beendet;
  List<String> get spielerIds;

  bool beitreten(String id, String name);
  void verlassen(String id);
  void verbunden(String id, bool ja);

  /// Wirft bei ungültigen Nachrichten einen Fehler mit festem Schlüssel.
  void nachricht(String id, Map<String, Object?> inhalt);

  /// Positivliste für genau ein Gerät.
  Map<String, Object?> zustandFuer(String id);
}

/// Zeichnet jeden erfolgreichen Aufruf auf, damit ein Gastgeber nach einem
/// Neustart den Raum deterministisch wiederherstellen kann: Alle Zufälle
/// hängen am Salz, also ergibt dieselbe Aufrufliste denselben Zustand.
class ProtokollRaum implements AbendRaum {
  ProtokollRaum(this.innen, [List<List<Object?>>? protokoll]) : protokoll = protokoll ?? [];

  final AbendRaum innen;

  /// Aufrufe als JSON-taugliche Listen: `[op, id, …]`.
  final List<List<Object?>> protokoll;

  /// Spielt [protokoll] in einen frischen Raum aus [fabrik] ein. Aufrufe, die
  /// damals erfolgreich waren, sind es wieder (gleiche Reihenfolge, gleiches Salz).
  static ProtokollRaum wiederherstellen(List<List<Object?>> protokoll, AbendRaum Function() fabrik) {
    final r = ProtokollRaum(fabrik());
    for (final e in protokoll) {
      final op = e[0] as String, id = e[1] as String;
      switch (op) {
        case 'beitreten':
          r.beitreten(id, e[2] as String);
        case 'verlassen':
          r.verlassen(id);
        case 'verbunden':
          r.verbunden(id, e[2] as bool);
        case 'nachricht':
          r.nachricht(id, (e[2] as Map).cast<String, Object?>());
      }
    }
    return r;
  }

  @override
  String get raumCode => innen.raumCode;
  @override
  int get version => innen.version;
  @override
  int get maxSpieler => innen.maxSpieler;
  @override
  bool get vorStart => innen.vorStart;
  @override
  bool get beendet => innen.beendet;
  @override
  List<String> get spielerIds => innen.spielerIds;

  @override
  bool beitreten(String id, String name) {
    final ok = innen.beitreten(id, name);
    if (ok) protokoll.add(['beitreten', id, name]);
    return ok;
  }

  @override
  void verlassen(String id) {
    innen.verlassen(id);
    protokoll.add(['verlassen', id]);
  }

  @override
  void verbunden(String id, bool ja) {
    innen.verbunden(id, ja);
    protokoll.add(['verbunden', id, ja]);
  }

  @override
  void nachricht(String id, Map<String, Object?> inhalt) {
    innen.nachricht(id, inhalt);
    protokoll.add(['nachricht', id, Map.of(inhalt)]);
  }

  @override
  Map<String, Object?> zustandFuer(String id) => innen.zustandFuer(id);
}
