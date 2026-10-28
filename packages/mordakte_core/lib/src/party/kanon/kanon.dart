import '../raumgraph.dart';
import '../tatmatrix.dart';
import '../wahrnehmung.dart';

/// Liest eine Kanon-Datei relativ zum Fallordner (z. B. `figuren.json`,
/// `tatmatrix/can.json`). App, CLI und Tests geben je eigene Leser hinein;
/// der Kern bleibt ohne `dart:io`.
typedef KanonLeser = Map<String, Object?> Function(String relativerPfad);

/// Der Kanon eines Partyfalls: alle Bereichsdateien plus abgeleitete Modelle.
class Kanon {
  static const dateien = [
    'fall.json',
    'setting.json',
    'raeume.json',
    'wahrnehmung.json',
    'figuren.json',
    'gegenstaende.json',
    'zeitleiste.json',
    'beobachtungen.json',
    'besetzung.json',
    'entscheidungen.json',
    'bonus.json',
    'gruppenwahl.json',
    'tatmatrix/basis.json',
  ];

  /// Dateien jeder Akte; die Tatmatrix kommt nur bei Akten mit Simulation dazu.
  static final grunddateien = [
    for (final d in dateien)
      if (!d.startsWith('tatmatrix/')) d,
  ];

  /// Tatmatrix-Dateien einer Akte mit physischer Simulation (`fall.simulation`
  /// fehlt oder ist true): Basis plus eine Datei je Pfad.
  static List<String> simulationsdateien(Map<String, Object?> fall) => fall['simulation'] == false
      ? const []
      : ['tatmatrix/basis.json', for (final p in fall['pfade'] as List) 'tatmatrix/$p.json'];

  final Map<String, Map<String, Object?>> json;
  final RaumGraph graph;
  final WahrnehmungsRegeln regeln;
  final List<String> pfade;

  Kanon._(this.json, this.graph, this.regeln, this.pfade);

  factory Kanon.lade(KanonLeser lies) {
    final j = <String, Map<String, Object?>>{for (final d in grunddateien) d: lies(d)};
    final pfade = [for (final p in (j['fall.json']!['pfade'] as List)) p as String];
    for (final d in simulationsdateien(j['fall.json']!)) {
      j[d] = lies(d);
    }
    return Kanon._(
      j,
      RaumGraph.fromJson(j['raeume.json']!),
      WahrnehmungsRegeln.fromJson(j['wahrnehmung.json']!),
      pfade,
    );
  }

  Map<String, Object?> get fall => json['fall.json']!;

  /// Kennung der Akte (`settingId`).
  String get settingId => fall['settingId'] as String;

  /// Hat die Akte eine physische Tatnacht-Simulation (Tatmatrix, Rückblende)?
  /// Nur der Schlosskeller hat sie; neue Akten beweisen ihre Lösbarkeit über
  /// die Entscheidungsebene (Simulator, Verweise, Textprüfer).
  bool get hatSimulation => fall['simulation'] != false;

  /// Prüfprofil des Simulators. Fehlende Felder bedeuten Schlosskeller-Werte.
  Map<String, Object?> get pruefprofil => ((fall['pruefprofil'] as Map?) ?? const {}).cast<String, Object?>();

  /// Zugparameter der Runden (Nachtminuten, Kosten); fehlend: Schlosskeller.
  Map<String, Object?> get zugJson => ((fall['zug'] as Map?) ?? const {}).cast<String, Object?>();

  /// Akte mit fester Lösung (ein einziger Pfad, z. B. das Gewölbe).
  bool get festeLoesung => pfade.length == 1;

  /// Teile der Vorgeschichte (`setting.vorgeschichte`, Einstimmung A-063) in
  /// Lesereihenfolge; `null`, wenn die Akte keine Einstimmung hat.
  List<String>? get vorgeschichte => switch (json['setting.json']!['vorgeschichte']) {
        final List l => [for (final t in l) t as String],
        _ => null,
      };

  /// Folgt auf die Vorgeschichte die Vorstellungsrunde (`setting.vorstellung`)?
  bool get vorstellung => json['setting.json']!['vorstellung'] == true;
  Map<String, Object?> get figurenJson => json['figuren.json']!;
  Map<String, Object?> get gegenstaendeJson => json['gegenstaende.json']!;
  Map<String, Object?> get beobachtungenJson => json['beobachtungen.json']!;
  Map<String, Object?> get zeitleisteJson => json['zeitleiste.json']!;
  Map<String, Object?> get entscheidungenJson => json['entscheidungen.json']!;
  Map<String, Object?> get bonusJson => json['bonus.json']!;
  Map<String, Object?> get gruppenwahlJson => json['gruppenwahl.json']!;
  Map<String, Object?> get besetzungJson => json['besetzung.json']!;

  /// Kernverdächtige (mögliche Täter).
  List<String> get kernverdaechtige => [for (final p in (fall['kernverdaechtige'] as List)) p as String];

  /// Alle Personen der Welt: Detektiv, Opfer, 20 Rollen.
  List<String> get personen => [
        (figurenJson['detektiv'] as Map)['id'] as String,
        (figurenJson['opfer'] as Map)['id'] as String,
        for (final f in figurenJson['figuren'] as List) (f as Map)['id'] as String,
      ];

  List<Map<String, Object?>> get figuren => [for (final f in figurenJson['figuren'] as List) (f as Map).cast<String, Object?>()];

  Map<String, Object?>? figur(String id) {
    for (final f in figuren) {
      if (f['id'] == id) return f;
    }
    if ((figurenJson['detektiv'] as Map)['id'] == id) return (figurenJson['detektiv'] as Map).cast<String, Object?>();
    if ((figurenJson['opfer'] as Map)['id'] == id) return (figurenJson['opfer'] as Map).cast<String, Object?>();
    return null;
  }

  List<Map<String, Object?>> get gegenstaende =>
      [for (final g in gegenstaendeJson['gegenstaende'] as List) (g as Map).cast<String, Object?>()];

  List<Map<String, Object?>> get beobachtungen =>
      [for (final b in beobachtungenJson['beobachtungen'] as List) (b as Map).cast<String, Object?>()];

  List<Map<String, Object?>> get zeitleiste =>
      [for (final z in zeitleisteJson['eintraege'] as List) (z as Map).cast<String, Object?>()];

  Tatmatrix tatmatrix(String pfad) => !hatSimulation
      ? throw StateError('Akte $settingId hat keine Tatmatrix')
      : Tatmatrix.zusammen(
        TatmatrixDatei.fromJson(json['tatmatrix/basis.json']!),
        TatmatrixDatei.fromJson(json['tatmatrix/$pfad.json']!),
      );

  /// Hat [person] in [pfad] ein eigenes, pfadabhängiges Verhalten, obwohl sie dort
  /// unschuldig ist (Beobachtung mit `eigenwissen`, E-039)? Dann erzählt die
  /// Auflösung ihre Pfadfassung `aufloesung.<person>.unschuldig.<pfad>`.
  bool eigenesVerhalten(String person, String pfad) => person != pfad &&
      beobachtungen.any((b) => b['eigenwissen'] == true && b['wer'] == person && giltIn(b['pfade'], pfad));

  /// Gilt ein Datensatz mit Feld `pfade` ("alle" oder Liste) für [pfad]?
  static bool giltIn(Object? pfadeFeld, String pfad) {
    if (pfadeFeld == null || pfadeFeld == 'alle') return true;
    if (pfadeFeld is List) return pfadeFeld.contains(pfad);
    return false;
  }
}
