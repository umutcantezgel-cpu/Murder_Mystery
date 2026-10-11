/// Ein Erkundungsort einer Akte (Abstecher, K-24): optional, kostet
/// Nachtminuten, auf allen Pfaden gleich und nie ein Fakt. Sein Fund ist
/// Stimmung (Nebenfund) und kann eine Sammelkarte bringen.
class AbstecherOrt {
  final String id;

  /// Kanon-Ort (raeume.json `orte`), an dem der Detektiv sucht.
  final String ort;
  final String name;
  final String erfolg;
  final String teilerfolg;
  final String pech;

  /// Runde, ab der der Ort offen ist (1..3).
  final int abRunde;

  const AbstecherOrt({
    required this.id,
    required this.ort,
    required this.name,
    required this.erfolg,
    required this.teilerfolg,
    required this.pech,
    this.abRunde = 1,
  });

  factory AbstecherOrt.fromJson(Map j) => AbstecherOrt(
        id: j['id'] as String,
        ort: j['ort'] as String,
        name: j['name'] as String,
        erfolg: j['erfolg'] as String,
        teilerfolg: j['teilerfolg'] as String,
        pech: j['pech'] as String,
        abRunde: j['abRunde'] as int? ?? 1,
      );

  /// Liest `{"abstecher": [...]}`.
  static List<AbstecherOrt> liste(Map<String, Object?>? j) =>
      [for (final a in (j?['abstecher'] as List? ?? const [])) AbstecherOrt.fromJson(a as Map)];
}
