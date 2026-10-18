/// Öffentliche Schlüssel der Abendansicht vor dem Finale (A-009, K-22).
///
/// Jede neue öffentliche Ansicht erweitert diese Liste im selben Commit. Der
/// Raum prüft seine Ansichten dagegen, und die Netz-Matrizen
/// (`server/tool/party_matrix.dart`, `server/tool/relay_matrix.dart`) lehnen
/// jedes andere Feld vor dem Finale ab. Gerätespezifisches gehört in `privat`.
const raumOeffentlicheSchluessel = <String>{
  't', 'protokoll', 'version', 'spiel', 'akte', 'raum', 'host', 'phase', 'runde',
  'wuerfelZusage', 'spieler', 'kannWeiter', 'rollen', 'restMinuten', 'marken',
  'erzaehler', 'notizbuch', 'wuerfe', 'wuerfelPate', 'gewaehlt', 'vorrat', 'abstecher',
  'abstecherErgebnis', 'entscheidung', 'zug', 'botGespraeche', 'verdaechtige', 'privat',
};

/// Schlüssel, die erst ab dem Finale dazukommen dürfen.
const raumSchluesselNachFinale = <String>{'aufloesung'};
