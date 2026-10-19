// Testtreiber für das Befragungsmodul (A-051): Der Detektiv erledigt alle
// Befragungen der Runde über Nachrichten, wie ein Gerät es täte – feste zuerst,
// dann so viele freie, wie die Runde erlaubt, je mit der ersten Frage. Nutzt nur
// die eigene Ansicht des Detektivs, nie den Zustand des Raums.

/// Schickt über [senden] die Befehle, mit denen die Befragungen der Ansicht [s]
/// des Detektivs erledigt sind. Ohne Befragungen (Altakte) geschieht nichts.
void befragungenErledigen(Map<String, Object?> s, void Function(String typ, Map<String, Object?> daten) senden) {
  final privat = (s['privat'] as Map).cast<String, Object?>();
  final karten = privat['befragungen'];
  if (karten is! List) return;
  var frei = privat['befragungenFrei'] as int;
  for (final k in karten.cast<Map>()) {
    if (k['erledigt'] == true) continue;
    if (k['frage'] == null) {
      if (k['pflicht'] != true) {
        if (frei <= 0) continue;
        frei--;
      }
      senden('befragen', {'id': k['id'], 'frage': 0});
    }
    if (k['mensch'] == true) senden('erledigt', {'id': k['id']});
  }
}
