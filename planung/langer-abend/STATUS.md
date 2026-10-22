# Langer Abend & Begleiter · STATUS

Plan: [PLAN.md](PLAN.md). Branch: `claude/brave-allen-of7gx8` (einziger Push-Branch; PR #45 mit M0–M7a ist nach `main` gemergt).
Bei Wiederaufnahme zuerst diese Datei und `git log --oneline -15` lesen, dann den ersten offenen Meilenstein fortsetzen.
Entscheidungen A-050 bis A-061 stehen in `planung/gesamt/STATUS.md`, E-043 in `planung/finalisierung-schlosskeller/ENTSCHEIDUNGSLOG.md`.

## Meilensteine

| Nr. | Inhalt | Stand |
|---|---|---|
| M0 | Werkbank, CI, Basislinie, Nähte | fertig: Kanon-Werkzeuge und -Tor, UI-Basis eingefroren, Raum-Naht, Inhaltskennung je Akte, ARB-Tontest, Golden Kern 1.2 |
| M1 | Glitch-Fix alle Akten, Szenen-Naht | fertig: freie Bahn mit Körperkasten, Neuplanen statt Hängen, kein Stand auf Personen, Rückblende je Frame exakt, WeltSzene-Naht |
| M2 | Befragungsmodell, Stichpunkte, Kanon K1 und K2 | fertig: Detektiv 3–5 Befragungen, Rollen ein Tischgespräch je Runde, Antworten verdeckt und als Kanon-Kurzfassung (R17), Spickzettel, Erzählerwissen unbesetzter Zielfiguren (E-044), K1 neutrale Feier |
| M3 | Sitze, Erzähler, Lobby-Zuteilung, Gast-Detektiv | fertig: Sitzplan und Rechte (Detektiv/Erzähler/Rolle), Vorleser-Sitz nur im Schlosskeller, Lobby mit Figurenwahl durch Detektiv und Erzähler, Gast-Detektiv und Gast-Erzähler am eigenen Gerät, Erzähler-Begleiter reihum, „Wer macht was“, Klasse am Detektiv-Sitz (M6.4); Nachschliff fertig (Gästeliste in der Lobby, Detektiv-Sitz nur an Gastgeber oder Platz ohne Figur, A-062) |
| M4 | Diashow, Rundenuhr | fertig: 6 Dias aus der Spielgrafik zur Einleitung (Vorleser liest, alle sehen das Bild), gemeinsame Rundenuhr mit Zeit vom Transport, Erzählerheft mit Dia-Nummern |
| M5 | Steckbriefe, PDFs, Teilen | fertig: Steckbriefe und Charakterübersicht (K3), Gästeliste, Erzählerheft mit allen Stichpunkten, Rollenheft je Person, Alles-PDF, Teilen über das System |
| M6 | Klassenfähigkeiten, Erklärungen | fertig: fünf Fähigkeiten auf der Karte (pfadgleich, invariant), Gerüchte mit Prüfer, Klassenzeile, Profil, Detektivkarte; online reist die Klasse mit dem Detektiv-Sitz |
| M7 | Langer Abend: Ebenen, Fassung, Streifzug, Vorspiel und Morgen | fertig: M7a Ebenen mit Portalen; M7b Fassung kurz/lang mit „ca. X Min.“ (kurz 15 Min. ≈ 100, lang 20 Min. ≈ 120), Streifzug mit 15 Erkundungsorten und Befragungen an Treffpunkten, Rückweg in den Keller vor jeder Entscheidung, Vorspiel 18:00 und Morgen 07:00 mit Rundgang und Tageslicht, Einfahrtstor im Vorspiel und am Morgen offen (18:50 schließt Schneider Hoftür, Einfahrtstor und Außentor), Dia 2 heller mit Schneider im Bild, `lang_invarianz_test` 48 Kombinationen; Gegenprüfung (W2) offen |
| M8 | Lebendige NPCs | offen |
| M9 | Mehrspieler-Bewegung | offen |
| M10 | CYOA-Ausbau | offen |
| M11 | Doku, e2e, Gegenprüfung, Release | offen |

## Prüfjournal (neueste zuerst)

- 2026-10-22 Abschluss auf Wunsch des Besitzers: M7b und Druckpaket auf `claude/brave-allen-of7gx8`. Lokal grün belegt: die Lanes einzeln (Kern 739 +1, Netz 52, App 594 nach A; Lanes B1/B2, Zusammenführung mit `pruefen.sh schnell`, App-Tests, Matrizen, `akte_pruefen` 5×0), `lang_invarianz_test` 48/48, Drucktests 122 + Porträt-Tests 5. Das volle Tor (`pruefen.sh ci`) fährt die CI dieses Branches; die geplante Gegenprüfung W2 und die Sichtprüfung des Pakets sind nicht gelaufen.
- 2026-10-22 Druckpaket für den Abend: `dart run bin/party_druck.dart --paket --n 12 [--code X]` (aus `packages/mordakte_core`, vorher `flutter test tool/bild/druck_portraets_test.dart` für die Porträts) erzeugt `build/paket/schlosskeller-n<N>-<CODE>/` mit 1-an-alle (Charakterübersicht, Steckbriefe), 2-veranstalter (Fall-Code, Ablauf, Gästeliste), 3-je-person-ungelesen-weitergeben (Rollenheft je Figur, Detektivbögen), 4-nur-erzaehler (Erzählerheft) und ZIPs. PDFs nie committen (Fall-Code).

- 2026-10-20 Welle D zusammengeführt (Nachschliff C, M4, M7a, gemeinsame Gegenprüfung, Sitz-Fix A-062): `pruefen.sh schnell` grün (Kern 727 +1 übersprungen, Netz 51, Krimidinner 67, Klang 4), App 563/563, Party- und Relais-Matrix grün (inkl. Ausfall des Gast-Detektivs), `akte_pruefen` 5×0; CI-Lauf 99 grün.
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

