# Langer Abend & Begleiter · STATUS

Plan: [PLAN.md](PLAN.md). Branch: `claude/beautiful-dijkstra-z79u0t` (einziger Push-Branch).
Bei Wiederaufnahme zuerst diese Datei und `git log --oneline -15` lesen, dann den ersten offenen Meilenstein fortsetzen.
Entscheidungen A-050 bis A-061 stehen in `planung/gesamt/STATUS.md`, E-043 in `planung/finalisierung-schlosskeller/ENTSCHEIDUNGSLOG.md`.

## Meilensteine

| Nr. | Inhalt | Stand |
|---|---|---|
| M0 | Werkbank, CI, Basislinie, Nähte | fertig: Kanon-Werkzeuge und -Tor, UI-Basis eingefroren, Raum-Naht, Inhaltskennung je Akte, ARB-Tontest, Golden Kern 1.2 |
| M1 | Glitch-Fix alle Akten, Szenen-Naht | offen |
| M2 | Befragungsmodell, Stichpunkte, Kanon K1 und K2 | offen |
| M3 | Sitze, Erzähler, Lobby-Zuteilung, Gast-Detektiv | offen |
| M4 | Diashow, Rundenuhr | offen |
| M5 | Steckbriefe, PDFs, Teilen | offen |
| M6 | Klassenfähigkeiten, Erklärungen | offen |
| M7 | Langer Abend: Ebenen, Fassung, Streifzug, Vorspiel und Morgen | offen |
| M8 | Lebendige NPCs | offen |
| M9 | Mehrspieler-Bewegung | offen |
| M10 | CYOA-Ausbau | offen |
| M11 | Doku, e2e, Gegenprüfung, Release | offen |

## Prüfjournal (neueste zuerst)

- 2026-10-18 M0-Tor: `pruefen.sh schnell` grün (Analyse ohne Befund, Kern 529, Netz 48, Krimidinner 67, Klang 4, Kanon-Tor überall aktuell). App `flutter test` 337/337. Party-Matrix (4 Clients) und Relais-Matrix (4 Gäste, lokal) grün.
- 2026-10-18 Basis korrigiert (E-043): Die eingebettete Kanon-Kopie war veraltet (6 Dateien). Neu erzeugt; der Golden von Kern 1.1 passte nur zur alten Kopie (Code 7 wich ab). Neuer Golden `determinismus_soll_k12.g.dart` auf dem aktuellen Kanon, VM und Node grün; `determinismus_web_test` nutzt ihn. Ab jetzt nie neu schreiben.
- 2026-10-18 Basislauf vor allen Änderungen (`pruefen.sh schnell`): Analyse ohne Befund, Kern 517 (+1 übersprungen), Netz 48, Krimidinner 67, Klang 4 grün. Nur der neue Kanon-Tor-Schritt war rot (eingebettete Kopie veraltet, siehe oben).

## Hinweise für die Umsetzung

- Rechenleistung: 4 Kerne. Höchstens zwei Agenten parallel, Tests gezielt mit `--concurrency=1`/`2`.
- Test-Attrappen in `test/abend/*` nutzen `noSuchMethod`: Neue Mitglieder von `GastgeberDienst`/`GastDienst`/`LokaleVerbindung` bekommen dort im selben Commit Standardwerte, sonst werfen die Tests zur Laufzeit.
- Die Naht für Gast-Bausteine entsteht mit dem ersten Gastbaustein (M2b), nicht vorab.
- Nach jeder Inhaltsänderung außerhalb des Kanon-Tors: `python3 tool/inhalt_kennung.py` (sonst meldet `pruefen.sh schnell` eine veraltete Kennung).

