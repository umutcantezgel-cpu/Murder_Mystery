# Langer Abend & Begleiter · STATUS

Plan: [PLAN.md](PLAN.md). Branch: `claude/beautiful-dijkstra-z79u0t` (einziger Push-Branch).
Bei Wiederaufnahme zuerst diese Datei und `git log --oneline -15` lesen, dann den ersten offenen Meilenstein fortsetzen.
Entscheidungen A-050 bis A-061 stehen in `planung/gesamt/STATUS.md`, E-043 in `planung/finalisierung-schlosskeller/ENTSCHEIDUNGSLOG.md`.

## Meilensteine

| Nr. | Inhalt | Stand |
|---|---|---|
| M0 | Werkbank, CI, Basislinie, Nähte | fertig: Kanon-Werkzeuge und -Tor, UI-Basis eingefroren, Raum-Naht, Inhaltskennung je Akte, ARB-Tontest, Golden Kern 1.2 |
| M1 | Glitch-Fix alle Akten, Szenen-Naht | fertig: freie Bahn mit Körperkasten, Neuplanen statt Hängen, kein Stand auf Personen, Rückblende je Frame exakt, WeltSzene-Naht |
| M2 | Befragungsmodell, Stichpunkte, Kanon K1 und K2 | fertig: Detektiv 3–5 Befragungen, Rollen ein Tischgespräch je Runde, Antworten verdeckt und als Kanon-Kurzfassung (R17), Spickzettel, Erzählerwissen unbesetzter Zielfiguren (E-044), K1 neutrale Feier |
| M3 | Sitze, Erzähler, Lobby-Zuteilung, Gast-Detektiv | fertig: Sitzplan und Rechte (Detektiv/Erzähler/Rolle), Vorleser-Sitz nur im Schlosskeller, Lobby mit Figurenwahl durch Detektiv und Erzähler, Gast-Detektiv und Gast-Erzähler am eigenen Gerät, Erzähler-Begleiter reihum, „Wer macht was“, Klasse am Detektiv-Sitz (M6.4); Nachschliff läuft |
| M4 | Diashow, Rundenuhr | offen |
| M5 | Steckbriefe, PDFs, Teilen | fertig: Steckbriefe und Charakterübersicht (K3), Gästeliste, Erzählerheft mit allen Stichpunkten, Rollenheft je Person, Alles-PDF, Teilen über das System |
| M6 | Klassenfähigkeiten, Erklärungen | fertig: fünf Fähigkeiten auf der Karte (pfadgleich, invariant), Gerüchte mit Prüfer, Klassenzeile, Profil, Detektivkarte; online reist die Klasse mit dem Detektiv-Sitz |
| M7 | Langer Abend: Ebenen, Fassung, Streifzug, Vorspiel und Morgen | offen |
| M8 | Lebendige NPCs | offen |
| M9 | Mehrspieler-Bewegung | offen |
| M10 | CYOA-Ausbau | offen |
| M11 | Doku, e2e, Gegenprüfung, Release | offen |

## Prüfjournal (neueste zuerst)

- 2026-10-19 M3 + M5 zusammengeführt (je Gegenprüfung mit Korrekturen): `pruefen.sh schnell` grün (Kern 681 +1 übersprungen, Krimidinner 67, Klang 4, Netz 50, Kanon-Tor aktuell), App `flutter test` 522/522, Party-Matrix (3 Sitz-Konstellationen, Host-Wechsel in 5 Akten) und Relais-Matrix (3 Läufe) grün, `akte_pruefen` alle 5 Akten 0 Befunde.
- 2026-10-19 Klassentests nach M2 (Treiber ohne Befragungen) rot im CI-Lauf zu b3d013d, behoben in 0ffb9fa; CI zu 0ffb9fa komplett grün.
- 2026-10-19 M2 + M6 zusammengeführt (je zwei Runden Gegenprüfung mit Korrekturen): `pruefen.sh schnell` grün (Analyse ohne Befund, Kern 632 +1 übersprungen, Krimidinner 67, Klang 4, Netz 48, Kanon-Tor aktuell), `akte_pruefen` alle 5 Akten 0 Befunde, Karten, Texte (1668), Plausibilität und Simulator OK. Lanes einzeln: App M2 246 + 35, M6 381, Party- und Relais-Matrix grün, Browserproben solo (320), geraete, karten_fotos grün.
- 2026-10-19 M1 + K1 zusammengeführt: `flutter analyze` und `dart analyze` ohne Befund, `kanon_tor.sh --pruefen` aktuell. Einzeln geprüft: M1 App-Tests 247 + 28 (party_widgets, session, stil, abend), Kern-Auswahl 133, `akte_pruefen` alle 5 Akten 0 Befunde, Gegenproben ohne Fix rot; K1 Kern 529, App 217 + 79, Netz 48, Plausibilität und Simulator OK, Golden unverändert.
- 2026-10-18 M0-Tor: `pruefen.sh schnell` grün (Analyse ohne Befund, Kern 529, Netz 48, Krimidinner 67, Klang 4, Kanon-Tor überall aktuell). App `flutter test` 337/337. Party-Matrix (4 Clients) und Relais-Matrix (4 Gäste, lokal) grün.
- 2026-10-18 Basis korrigiert (E-043): Die eingebettete Kanon-Kopie war veraltet (6 Dateien). Neu erzeugt; der Golden von Kern 1.1 passte nur zur alten Kopie (Code 7 wich ab). Neuer Golden `determinismus_soll_k12.g.dart` auf dem aktuellen Kanon, VM und Node grün; `determinismus_web_test` nutzt ihn. Ab jetzt nie neu schreiben.
- 2026-10-18 Basislauf vor allen Änderungen (`pruefen.sh schnell`): Analyse ohne Befund, Kern 517 (+1 übersprungen), Netz 48, Krimidinner 67, Klang 4 grün. Nur der neue Kanon-Tor-Schritt war rot (eingebettete Kopie veraltet, siehe oben).

## Hinweise für die Umsetzung

- Rechenleistung: 4 Kerne. Höchstens zwei Agenten parallel, Tests gezielt mit `--concurrency=1`/`2`.
- Test-Attrappen in `test/abend/*` nutzen `noSuchMethod`: Neue Mitglieder von `GastgeberDienst`/`GastDienst`/`LokaleVerbindung` bekommen dort im selben Commit Standardwerte, sonst werfen die Tests zur Laufzeit.
- Die Naht für Gast-Bausteine entsteht mit dem ersten Gastbaustein (M2b), nicht vorab.
- K1-Festlegungen für M7: Einfahrtstor des Hofs und Außentor nur per Torschlüssel (Bund, Kollegin um sieben); Hof und Garten hoch ummauert, Erdgeschossfenster vergittert; kein Empfang in Hof, Erdgeschoss, Turm; kein Telefon im Schloss; Seitentür vom Schlosshof ins Erdgeschoss (nicht auf dem Keller-Raster). Tugba ist die Party-Planerin.
- Nach jeder Inhaltsänderung außerhalb des Kanon-Tors: `python3 tool/inhalt_kennung.py` (sonst meldet `pruefen.sh schnell` eine veraltete Kennung).

