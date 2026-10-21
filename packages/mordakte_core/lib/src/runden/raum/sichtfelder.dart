/// Öffentliche Schlüssel der Abendansicht vor dem Finale (A-009, K-22).
///
/// Jede neue öffentliche Ansicht erweitert diese Liste im selben Commit. Der
/// Raum prüft seine Ansichten dagegen, und die Netz-Matrizen
/// (`server/tool/party_matrix.dart`, `server/tool/relay_matrix.dart`) lehnen
/// jedes andere Feld vor dem Finale ab. Gerätespezifisches gehört in `privat`.
const raumOeffentlicheSchluessel = <String>{
  't', 'protokoll', 'version', 'spiel', 'akte', 'raum', 'host', 'phase', 'runde',
  'wuerfelZusage', 'spieler', 'kannWeiter', 'rollen', 'restMinuten', 'marken',
  'notizbuch', 'wuerfe', 'wuerfelPate', 'gewaehlt', 'vorrat', 'abstecher',
  'abstecherErgebnis', 'entscheidung', 'zug', 'botGespraeche', 'verdaechtige', 'privat',
  // Modell befragung (A-051, `raum/befragung_modul.dart`): nur Paarungen und Themen, nie eine Antwort.
  'befragungen', 'tisch',
  // Vorleser-Sitz (M3): Erzähltext steht im `privat` genau eines Geräts; alle sehen nur, dass vorgelesen wird.
  'erzaehlerLiest', 'bausteinZahl',
  // Rundenuhr und Diashow (M4): Zustand der Uhr ohne Takt (`raum/uhr_modul.dart`), Nummer des Bildes (`raum/dia_modul.dart`).
  'uhr', 'dia',
  // Fassung (M7b): nur im langen Abend, Wert `lang`; nie Pfad, Salz oder Wertung.
  'fassung',
  // Streifzug (M7b, `raum/streifzug_modul.dart`): Stelle des Detektivs, erkundete Orte, laufendes Treffen; nur lang, rein kosmetisch.
  'streifzug',
};

/// Schlüssel, die erst ab dem Finale dazukommen dürfen: die Auflösung und der
/// Erzähltext für alle (vor dem Finale nur beim Vorleser-Sitz).
const raumSchluesselNachFinale = <String>{'aufloesung', 'erzaehler'};

/// Akten ohne Vorleser-Sitz (`SchlosskellerRaum.vorleserSitz`, die Altakten):
/// Der Erzähltext steht wie vor M3 für alle öffentlich, auch vor dem Finale.
const raumSchluesselOhneVorleser = <String>{'erzaehler'};

/// Einträge in `spieler` (je Gerät, öffentlich): Sitz, Figur der Lobby und
/// Wunsch sind am Tisch bekannt, nie ein Dossier.
const raumSpielerFelder = <String>{'id', 'name', 'online', 'bereit', 'sitz', 'rolle', 'figur', 'wunsch'};
