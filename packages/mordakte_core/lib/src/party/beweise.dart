import 'kanon/kanon.dart';
import 'plausibilitaet.dart';
import 'spuren.dart';

/// Eine Spur und die Pfade, in denen sie laut Tatmatrix entsteht.
class SpurEntstehung {
  final String gegenstand;
  final String spur;
  final Set<String> pfade;
  final Map<String, String> rolle;
  SpurEntstehung(this.gegenstand, this.spur, this.pfade, this.rolle);
}

/// Beweisprüfung (F-05): Jede Spur entsteht genau dort, wo die Tatmatrix es
/// physisch erlaubt; Schlüsselbeweis und Zusatzindiz entstehen nur im eigenen
/// Pfad; in fremden Pfaden gibt es eine harmlose Fassung.
class Beweise {
  final Kanon kanon;
  /// Physischer Prüfer; nur bei Akten mit Simulation (Schlosskeller) gesetzt.
  final Plausibilitaet? pruefer;
  Beweise(this.kanon, [this.pruefer]);

  late final SpurRechner _spuren = SpurRechner(kanon);

  /// Wer greift in Pfad [pfad] den Kerzenständer (laut Spur der Tatmatrix)?
  Set<String> greifer(String pfad) => _spuren.greifer(pfad);

  /// Wo liegt der Bund am Ende des Fensters (Einrichtung oder Ort)?
  String? bundEnde(String pfad) => _spuren.bundEnde(pfad);

  bool entsteht(Map bedingung, String pfad) => _spuren.entsteht(bedingung, pfad);

  List<SpurEntstehung> entstehungen() => [
        for (final g in kanon.gegenstaende)
          for (final s in (g['spuren'] as List? ?? const []))
            SpurEntstehung(
              g['id'] as String,
              (s as Map)['id'] as String,
              {for (final p in kanon.pfade) if (entsteht(s['entstehtWenn'] as Map, p)) p},
              ((s['rolle'] as Map?) ?? const {}).map((k, v) => MapEntry(k as String, v as String)),
            ),
      ];

  /// Alle Verstöße als lesbare Befunde.
  List<String> pruefe() {
    final f = <String>[];
    final alle = entstehungen();
    for (final e in alle) {
      for (final r in e.rolle.entries) {
        if (r.key == 'alle') {
          if (e.pfade.length != kanon.pfade.length) f.add('${e.spur}: Rolle „alle“, entsteht aber nur in ${e.pfade.join(', ')}');
          continue;
        }
        if (r.value == 'schluesselbeweis' || r.value == 'zusatzindiz' || r.value == 'fundort') {
          if (!(e.pfade.length == 1 && e.pfade.contains(r.key))) {
            f.add('${e.spur}: ${r.value} für ${r.key}, entsteht aber in {${e.pfade.join(', ')}}');
          }
        }
      }
    }
    for (final p in kanon.pfade) {
      final schluessel = [for (final e in alle) if (e.rolle[p] == 'schluesselbeweis' && e.pfade.contains(p)) e.spur];
      final zusatz = [for (final e in alle) if (e.rolle[p] == 'zusatzindiz' && e.pfade.contains(p)) e.spur];
      if (schluessel.length != 1) f.add('Pfad $p: ${schluessel.length} Schlüsselbeweise (${schluessel.join(', ')}), erwartet 1');
      if (zusatz.length != 1) f.add('Pfad $p: ${zusatz.length} Zusatzindizien (${zusatz.join(', ')}), erwartet 1');
      // Kein Schlüsselbeweis oder Zusatzindiz eines fremden Pfads entsteht hier.
      for (final e in alle) {
        for (final r in e.rolle.entries) {
          if (r.key != p && r.key != 'alle' && (r.value == 'schluesselbeweis' || r.value == 'zusatzindiz') && e.pfade.contains(p)) {
            f.add('Pfad $p: ${r.value} von ${r.key} (${e.spur}) entsteht auch hier');
          }
        }
      }
      if (kanon.hatSimulation) {
        final g = greifer(p);
        if (g.length != 1 || g.first != p) f.add('Pfad $p: Kerzenständer gegriffen von $g, erwartet $p');
      }
    }
    return f;
  }
}
