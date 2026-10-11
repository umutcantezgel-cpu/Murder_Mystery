import 'kanon/kanon.dart';
import 'tatmatrix.dart';

/// Wann eine Spur in einem Pfad entsteht. Gelesen wird aus der Bedingung
/// `entstehtWenn`: `immer`, eine Pfadliste `pfade` (Akten ohne Simulation) oder
/// die Gegenstandsspuren der Tatmatrix (wer den Kerzenständer hält, wo der Bund
/// am Ende liegt), ohne Wahrnehmungsrechnung. Das ist schnell genug für die App.
class SpurRechner {
  final Kanon kanon;
  final Map<String, Tatmatrix> _matrix = {};
  SpurRechner(this.kanon);

  Tatmatrix matrix(String pfad) => _matrix[pfad] ??= kanon.tatmatrix(pfad);

  /// Wer greift in [pfad] den Kerzenständer? Ohne Simulation: niemand.
  Set<String> greifer(String pfad) => !kanon.hatSimulation
      ? const {}
      : {
          for (final s in matrix(pfad).gegenstaende['kerzenstaender']?.spur ?? const <SpurPunkt>[])
            if (s.traeger != null) s.traeger!,
        };

  /// Wo liegt der Bund am Ende des Fensters (Einrichtung, Ort oder Träger)?
  String? bundEnde(String pfad) {
    if (!kanon.hatSimulation) return null;
    final s = matrix(pfad).gegenstaende['bund_schneider']?.stand(kanon.regeln.fensterBis);
    return s?.einrichtung ?? s?.ort ?? s?.traeger;
  }

  bool entsteht(Map bedingung, String pfad) {
    if (bedingung['immer'] == true) return true;
    final pf = bedingung['pfade'];
    if (pf is List) return pf.contains(pfad);
    final g = bedingung['kerzenstaenderGegriffenVon'];
    if (g != null) return greifer(pfad).contains(g);
    final b = bedingung['bundEndetBei'];
    if (b != null) return bundEnde(pfad) == b;
    return false;
  }
}
