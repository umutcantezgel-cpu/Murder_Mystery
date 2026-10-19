# ENTSCHEIDUNGSLOG · Finalisierung „Spuk im Schlosskeller“

Format je Eintrag: Ziel und Messgröße · Wege (mindestens drei) · Bewertung (Logik/Lösbarkeit, Spielspaß am Tisch, Treue zum Quellmaterial, Wartbarkeit) · Umkehrprobe · Folgen zweiter Ordnung · Entscheidung.

---

## E-001 · Partymodus in der vorhandenen Mordakte-App (F0)
- **Ziel:** Der Fall ist im Browser spielbar und nutzt die vorhandene Engine (§8: „Eine zweite baust du nicht“). Messgröße: F-12, F-16.
- **Wege:**
  1. Den Mordakte-Spielablauf (Engine, Schatten, Rat) erweitern, sodass er den Partyablauf mitträgt.
  2. Einen Partymodus in derselben App bauen: neue, reine Dart-Logik unter `mordakte_core/lib/src/party/`, neue Bildschirme unter `lib/party/`; der Renderer (Iso-Projektion, Szenenbau, Figuren, Licht, Joystick) wird wiederverwendet.
  3. Eine eigene HTML/JS-Party-App neben Mordakte.
- **Bewertung:**
  - Weg 1 zwingt Partyregeln (4–20 Rollen, 9 gewertete Entscheidungen, Gruppenwahl, feste Enden) in eine Engine mit 6-Spieler-Grenze, Pflicht-Nacht und Echtzeit-Schatten. Viele Änderungen an Bestandscode, hohes Regressionsrisiko für F-16.
  - Weg 2 nutzt genau die passenden Teile (Renderer, Rng, Validator-Muster, Asset-Laden) und lässt Mordakte unberührt.
  - Weg 3 verstößt gegen §8.
- **Umkehrprobe:** Weg 2 wäre falsch, wenn der Renderer so eng an die Mordakte-Session gebunden ist, dass er nicht ohne sie läuft. Prüfung: Kundschafter F0-KUNDSCHAFTER-01. Ergebnis siehe BESTAND.md.
- **Folgen:** Die Story-Daten liegen außerhalb des Codes (F-16 „kein Story-Text außerhalb des Kanons“). Mordakte-Tests bleiben unverändert.
- **Entscheidung:** Weg 2.

## E-002 · Kanon als JSON je Bereich in `content/party/schlosskeller/` (F0)
- **Ziel:** eine maschinenlesbare Quelle mit Schema, getrennte Dateien für parallele Autoren, Story-Bibel erzeugt. Messgröße: F-01.
- **Wege:**
  1. Eine große JSON-Datei.
  2. JSON je Bereich, dazu Textsammlung `texte/*.json` mit Schlüsseln; Schema-Dateien unter `content/party/schema/`.
  3. Das Zeilenformat des früheren Laufs (`@ID [S] | Feld: Wert`).
- **Bewertung:**
  - Weg 1 erzwingt Dateikonflikte bei parallelen Autoren.
  - Weg 3 ist gut prüfbar, aber das Spiel bräuchte dafür einen eigenen Parser, und Behzads JSON müsste konvertiert werden.
  - Weg 2 erhält Behzads Feldnamen (`settingId`, `characters`, `visualSpecs`, `killerProfile` …), wird von App und Werkzeugen direkt gelesen und erlaubt Dateihoheit je Autor.
- **Umkehrprobe:** Wäre JSON für Autoren zu fehleranfällig? Gegenmaßnahme: Der Validator läuft in jedem Test, und Autoren schreiben nur Textdateien mit flachen Schlüssel-Wert-Paaren.
- **Folgen:** Der Asset-Ordner wird in `pubspec.yaml` eingetragen. Ladegröße prüfen.
- **Entscheidung:** Weg 2. Jeder pfadabhängige Datensatz trägt `pfade` (Liste aus `ahmet|fatma|olli|can`, fehlt das Feld, gilt er für alle).

## E-003 · Branch und Übergabe (F0)
- **Ziel:** Arbeit gesichert, am Ende auf main mit Tag, ohne Force-Push.
- **Wege:**
  1. `finalisierung-schlosskeller` wie in den Einstellungen.
  2. Direkt auf dem Sitzungsbranch `claude/universal-prompt-orchestrator-trt8uu`.
  3. Beide parallel.
- **Bewertung:** Die Einstellungen nennen Weg 1. Die Umgebung kann Pushes auf fremde Branchnamen ablehnen.
- **Umkehrprobe:** Lehnt der Proxy ab, ist Weg 1 nicht pushbar. Dann greift Weg 2 als Sicherungsziel mit denselben Commits.
- **Entscheidung:**
  - Lokaler Arbeitsbranch `finalisierung-schlosskeller` ab origin/main `d92a675`, Upstream abgekoppelt (kein versehentlicher Push auf main).
  - Push an jedem Phasentor; bei Ablehnung auf den Sitzungsbranch.
  - F7: Merge nach main, Push, Tag `schlosskeller-1.0`. Ist das blockiert, folgt ein Pull Request und ein Eintrag unter FÜR DEN NUTZER.

## E-004 · Werkzeugkette nur im Repo (F0)
- **Ziel:** bauen und testen ohne systemweite Installation und ohne fremde Server zur Laufzeit.
- **Entscheidung:**
  - Flutter 3.47.6, dieselbe Quelle wie `build.sh`, liegt in `.werkzeug/flutter`; `PUB_CACHE=.werkzeug/pub-cache`; beides gitignored. Aktivierung: `source .werkzeug/env.sh`.
  - E2E: npm-Paket `playwright` in `tool/e2e/` (Apache-2.0) mit dem vorinstallierten Chromium.
  - PDF: Dart-Paket `pdf` (Apache-2.0).
  - Stimme: Web Speech API über `dart:js_interop`, nur lokale Stimmen (`localService`). Keine neue Abhängigkeit.
- **Begründung:** Alle drei Bibliotheken sind verbreitet, gepflegt und frei lizenziert; Lizenzliste in LIZENZEN.md.

## E-005 · Quellmaterial (F0)
- `quellen/` ist seit dem ersten Arbeitsschritt in `.gitignore`.
- Der Teamchat aus Codays erster Nachricht dieser Sitzung liegt wortgleich in `quellen/schlosskeller-teamchat.txt`.
- Der Secret-Scan vor jedem Push prüft, dass nichts aus `quellen/` im Verlauf ist.

## E-006 · Werkstatt und Gemeindesaal (F0)
- Im Repo gibt es dazu weder Daten noch Texte, nur die Titel im Chat. Es gibt also nichts zu übernehmen (§8 „falls vorhanden“).
- Das Kanon-Schema ist fallneutral (`content/party/<fall>/`), damit beide später andocken können.
- Eintrag unter FÜR DEN NUTZER.

## E-007 · Cast und Leitplanken (F0, Feinentscheidung in F1)
- **Ziel:** Kernnamen laut Einstellungen behalten und trotzdem keine Klischees (Grenze, Vorrang 1).
- **Wege:**
  1. Kernnamen ändern, wie die Vorprüfung vorschlägt (Ahmet → Felix, Fatma → Sophie …).
  2. Kernnamen behalten, Herkunft und Motive so verteilen, dass keine Gruppe allein Verfehlungen trägt; Kopftuch auch bei unbelasteten Figuren; Motive aus der Lage statt aus Not oder Herkunft.
  3. Nichts ändern.
- **Bewertung:**
  - Weg 1 verletzt die Einstellungen (Täter aus Ahmet, Fatma, Olli, Can) und Behzads laufende Modellierung.
  - Weg 3 verletzt die Grenze.
  - Weg 2 hält beides ein.
- **Umkehrprobe:** Bleibt trotz Weg 2 ein Klischee-Eindruck, weil drei Kernnamen türkisch klingen? Gegenmaßnahmen:
  - Jede der vier Kernrollen bekommt eine andere Herkunft. Ahmet ist auch ein bosnischer Vorname, Fatma kommt in türkischen und kurdischen Familien vor.
  - Die Tatverteilung ist gleichmäßig: jede Kernrolle in 25 % der Fall-Codes.
  - Jede Verfehlung ist situativ motiviert.
  - Der Sensibilitätsleser prüft die Gesamtverteilung.
  - Der stärkere Vorschlag liegt als Option unter FÜR DEN NUTZER.
- **Entscheidung:** Weg 2. Konkrete Herkunfts- und Namenszuordnung in F1 (E-1xx).

## E-008 · Spoilerschutz als Architekturregel (F0)
- Die 9 Fragen samt Optionen sind in allen Pfaden wortgleich; nur Wertung und Ergebnistext hängen vom Pfad ab.
- Alle vier Schlüsselbeweis-Orte sind in jedem Pfad belegt; in fremden Pfaden mit dokumentierter harmloser Fassung.
- Der Bonus-Hinweis erscheint in allen drei Qualitäten im selben Rahmen. Die App nennt nie die Stimmenzahl.
- Die Täterfassung eines Dossiers erscheint nur in der verdeckten Einzelansicht und im eigenen Rollenheft.
- **Begründung:** Ein gemeinsamer Bildschirm und gedruckte Unterlagen dürfen den Pfad nicht verraten (F-06, F-11, F-12, F-14).

## E-009 · Haiku-Plätze und Denkstufe (F0)
- Die Maschine hat 4 CPUs, ein Workflow lässt höchstens 2 Agenten gleichzeitig laufen. Für 4 gleichzeitige Plätze laufen bis zu 2 Workflows parallel mit getrennter Dateihoheit.
- Modell `haiku`. Qualitätsarbeit (Autor, Prüfer) läuft mit `effort: max`, Kundschaft mit `high`.
- Stufe-3-Teile baut der Orchestrator selbst: Kanon-Kern, Tatmatrix, Plausibilitätsprüfer, Entscheidungs- und Endenmodell, Simulator-Kern, Einbindung, Übergabe.

## E-010 · Upstream abgekoppelt (F0)
- `git checkout -b finalisierung-schlosskeller origin/main` hat origin/main als Upstream gesetzt. Ein `git push` ohne Ziel hätte main getroffen.
- Mit `git branch --unset-upstream` entfernt. Jeder Push nennt sein Ziel ausdrücklich.

## E-011 · Paketabnahme durch den Orchestrator mit Werkzeughilfe (F0)
- **Ziel:** Jede Rückgabe wird nach den fünf Prüfungen bewertet, ohne dass die Abnahme zum Engpass wird.
- **Wege:**
  1. Ich lese jede Rückgabe vollständig.
  2. Ein Opus-Prüfagent bewertet, ich lese nur Stichproben.
  3. Werkzeuge prüfen alles Messbare; ich lese jede Rückgabe mit den Werkzeugberichten und bewerte selbst.
- **Bewertung:** Das Messbare (Schema, Verweise, Satzlängen, Stopplisten, Tests) ist mechanisch prüfbar und vollständig automatisierbar. Urteil bleibt beim Orchestrator (§4).
- **Entscheidung:** Weg 3.
  - Die Abnahme steht als `ABNAHME`-Zeile im Kopf von `berichte/<Kennung>.md`.
  - Bei sehr großen Stapeln (mehr als 20 gleichartige Texte) lese ich jeden fünften vollständig und alle mit Werkzeugbefund.

## E-012 · Lernen L-01: Rückgabe in einer Nachricht (F0)
- **Befund:** Der Rückgabewert von F0-KONT-01 begann mitten in Tabellenzeile 68. Die Zeilen 1–67 standen in einer früheren Nachricht des Agenten; der Workflow übernimmt nur die letzte.
- **Maßnahme:**
  - Bericht aus dem Agentenverlauf wiederhergestellt (`berichte/F0-KONT-01.md`, vollständig mit Endmarke).
  - AUFTRAGSVORLAGE ergänzt: Die gesamte Rückgabe steht in der letzten Nachricht.
  - Workflows prüfen künftig, dass die Rückgabe mit der Überschrift des Ausgabeformulars beginnt und mit der Endmarke endet. Sonst wird der Auftrag einmal mit dem Hinweis wiederholt.

## E-013 · Plan-Schleife Runde 1: Entscheidungen zu F0-GEGEN-01 (17 Befunde) und F0-GEGEN-02 (16 Befunde)
Je Befund: übernommen (Ü), teilweise (T), verworfen (V), mit Begründung. Die Folgen stehen in PLAN, ABNAHME, NEBELKARTE und FÜR-DEN-NUTZER.

| Befund | Entscheidung | Begründung, Folge |
|---|---|---|
| G1-1, G2-3 Abkürzung über drei wahre Hinweise | Ü | Regel W-1: Ein wahrer Bonus-Hinweis liefert einen wahren Baustein (bestätigt eine Beobachtung oder deckt ein Nebendelikt auf), entlastet aber nie allein einen Kernverdächtigen. F-06 wird um den Fall „0 richtige, 3 wahre Hinweise → mindestens 2 Restverdächtige“ ergänzt. |
| G1-2 Anklage durch Raten | T | Die Anklage bleibt gegen alle vier Kernverdächtigen möglich (Master 7.6: „gegen einen der vier“). Die Endmatrix B-12 bleibt. Der Simulator weist Rate-Enden (Anklage außerhalb der Restmenge) getrennt aus. |
| G1-3 Ein oder zwei Restverdächtige | Ü | Bestes Spiel: nach Runde 2 (6 richtige) genau 2 Restverdächtige, nach Runde 3 (9 richtige) genau 1. Das erfüllt F-06 und 7.6 („in Runde 3 stehen zwei Restverdächtige dem Schlüsselbeweis gegenüber“). |
| G1-4, G1-5 Spoiler im Resümee | Ü | Regel S-1: Resümee-Fächer werden nur aus dem Wissen des Detektivs gefüllt (aufgedeckte Fakten, Gruppenqualität), nie aus dem Pfad. Bei Restmenge 1 nennt kein Baustein einen Namen („Die Spuren haben sich gelichtet – jetzt liegt es an dir.“). Kein Baustein sagt „X ist der Täter“. Der Spoiler-Test prüft alle Bausteine vor dem Finale über alle vier Pfade. |
| G1-6 Marker auf der Karte | Ü | E-008 verschärft: Objektliste, Marker und Licht vor dem Finale sind in allen vier Pfaden identisch; nur Fundtexte unterscheiden sich. Test `karte_pfadgleich_test`. |
| G1-7 Kanal der Pflichtgespräche | Ü (Variante a) | Preisgaben in Pflichtgesprächen sind pfadneutral (Nebendelikte, behauptete Alibis, gemeinsame Beobachtungen). Pfadabhängiges Wissen steht im Dossier unter „Was ich verberge“. Es erreicht den Detektiv nur über eine Detektiv-Entscheidung (Befragung, bei unbesetzter Rolle als NPC-Karte) oder anonym über den Bonus-Hinweis. Rollenwissen ist so gebaut, dass es allein niemanden entlastet (anonyme Beobachtung plus Beweis aus einer Entscheidung). |
| G1-8 Falsche Option zeigt Schlüsselbeweis | Ü | Regel D-1: Optionen mit 0 Punkten decken weder Schlüsselbeweis noch Zusatzindiz auf, nur Nebendelikt- oder Umgebungsfakten. Test in `beweise_test` und `simulator_test`. |
| G1-9, G2-14 Simulator unsound und zu langsam | Ü | Zustand = (Pfad, Menge aufgedeckter Fakten, Gruppenqualitäten); Restmenge als Funktion der Faktenmenge mit Memo. Die erschöpfende Auszählung läuft in der CLI `party_simulate` (Budget unter 5 Minuten für alle Pfade und Personenzahlen). Der Testlauf nutzt dieselbe Auszählung mit Memo; Budget unter 60 Sekunden. NEBELKARTE 16 korrigiert. |
| G1-10, G2-13 Gruppenwahl ohne Kosten | Ü | Jede Option trägt maschinenlesbar `kosten` und `nutzen` aus Geheimnis oder Loyalität (A: Geheimnis oder Freund gerät ins Licht; B: schützt das persönliche Ziel). Persönliche Ziele werden in der Auflösung als „erreicht oder nicht“ gezeigt. Test: Jede Rolle hat bei B einen Nutzen und bei A Kosten; jeder der 36 Hinweise ist über eine Stimmenverteilung erreichbar. |
| G1-11 Sabotage | Ü | Regel G-1: Die Option B der Täterrolle heißt im Kanon „Sabotage“. Sie zählt wie jedes B als 0 und hebt zusätzlich eine kooperative Stimme auf (netto −1). Für alle sichtbar ist nur die Qualität, nie die Zahl. Simulator-Dimension: Stimmenverteilungen je Personenzahl → Qualität. |
| G1-12 Lacher im Intro | Ü | Lacher sind Stimmung, nie Erzählerfakt für Alibis. Alle 20 Gäste existieren in der Welt (W1), unbesetzte nennt der Erzähler nur über Bausteine, die die App nach Besetzung wählt (mit Rollenname oder neutral „eine Freundin“). „Verlaufen auf dem Weg zur Toilette“ wird in F1 vergeben. |
| G1-13 Geburtstagskind im Tatraum | Ü | War schon gelöst: Das Geburtstagskind sitzt ab 23:55 mit verbundenen Augen und Musik auf den Ohren im Ostsaal; die Lockung zur Torte um 0:00 fand wegen des Ausfalls um 23:58 nie statt. Der Plausibilitätsprüfer prüft die Wahrnehmung des Geburtstagskinds. |
| G1-14 Druckspiel ohne Restmengen-Anzeige | Ü | Gedruckt wird ein Ermittlungsbogen mit Ausschlussregeln („Hast du Fakt X und Y, ist Z entlastet“), den das Geburtstagskind selbst ausfüllt. F-14 wird ergänzt: Das Resümee ist ohne Auflösungsheft ablesbar. |
| G1-15 Täterfassung in der Druckdatei | Ü | Druck: Jede Kernrolle erhält beide Fassungen als versiegelte Blätter mit neutralen Codes und eine versiegelte Schlüsselkarte, welche sie öffnet. Wer druckt, liest nichts davon; die Spielleitung hält keine Kernrolle. |
| G1-16 Texte veralten bei Kanon-Änderung | Ü | Textlint: Jede Uhrzeit, jeder Ort und jeder Gegenstand in Texten wird gegen Zeitleiste, Raumgraph und Gegenstandsliste geprüft (`textlint_test`). Regel: Jede Kanon-Änderung nach F3 löst den Textlint und die KONT-Prüfung der betroffenen Dateien aus. |
| G1-17, G2-6 F-09 und Besetzung zu spät | Ü | Besetzungsreihenfolge in F1 (`figuren.json` und `besetzung.json`), Ersatzpartner und Begründungsketten-Prüfung je Personenzahl in F2 (Teil des F2-Tors). |
| G2-1 CanvasKit vom CDN | Ü | `--no-web-resources-cdn` in `build.sh` (Bestandsänderung, dokumentiert) und in `tool/pruefen.sh`. Die Netzprüfung läuft schon im Spike (F1) und nicht erst in F6. |
| G2-2 SDK-Download | T | Denkprotokoll: Ohne SDK kann kein Commit „baut und testet grün“ belegt werden. Das Projekt installiert sein gepinntes SDK selbst über `build.sh` aus derselben Quelle. Das zählt als Paketinstallation über das Werkzeug des Projekts. Nichts wird hochgeladen, die Laufzeit des Spiels bleibt ohne fremde Server. Eintrag unter FÜR DEN NUTZER mit Quelle und Prüfweg. |
| G2-4 Analyse-Reihenfolge | Ü | `tool/pruefen.sh` entsteht in F0 und ruft zuerst `pub get` in allen Paketen auf. |
| G2-5 Bestandsänderungen, Spike | Ü | E-001 erhält eine Liste erlaubter Bestandsänderungen: nur zusätzliche, optionale Parameter mit unverändertem Standardverhalten (z. B. `standing(..., idleT)` mit Standard 0, Fog nur bei gesetztem Schalter). Ein Spike folgt in F1 parallel zum Kanon: Karte aus dem Raumgraph, eine Figur, Licht, Playwright-Probelauf mit Netzprüfung. |
| G2-7 Doppelte Quelle Kern-Rundenwahl | Ü | Die Kern-Rundenwahl entsteht nur über die Dilemma-Dateien (Varianten-Regel); F3-AUTOR-26 schreibt nur die Blöcke 2–5. Beide hängen an den Dossiers. |
| G2-8 Textschlüssel, Eigentümer | Ü | Neuer Auftrag F3-ORCH-00 (Schlüsselschema). Eigentümertabelle im PLAN: `pubspec.yaml`, `packages/mordakte_core/pubspec.yaml`, Barrel `mordakte_core.dart`, `lib/l10n/app_de.arb`, `analysis_options.yaml`, `build.sh`, `router.dart`, `main.dart`, `hub_screen.dart` gehören ORCH. Party-UI-Texte stehen in der Kanon-Textsammlung (`texte/ui.json`), nicht in ARB. |
| G2-9 Isolation paralleler Agenten | Ü | Baumeister, die Code ändern oder bauen, laufen mit `isolation: worktree`. Commits nur mit expliziter Pfadliste. Builds mit eigenem `-o`-Verzeichnis je Lauf. |
| G2-10 Übergabe | Ü | Probe-Push am F0-Tor. F7 mit `git merge --ff-only` auf den aktuellen origin/main-Stand. Hub-Kachel und Routen als letzter F4-Schritt nach dem Holen von origin. F-17-Ersatzweg PR (Master §3) wird im Abschlussbericht ausgewiesen, falls er greift. |
| G2-11 Playwright | Ü | `playwright@1.56.1` gepinnt (passt zu `/opt/pw-browsers/chromium-1194`), `PLAYWRIGHT_BROWSERS_PATH` im Skript. Flutter-Semantik wird im Entwicklerbetrieb per `?semantik=1` eingeschaltet, Klicks laufen über Beschriftungen. Die Karte wird über den Dev-Einstieg mit Skript gesteuert. |
| G2-12 Farbabstand | Ü | ΔE2000-Test in F1 (`farbabstand_test`), gemessen an den Hex-Werten des Kanons. Neue Werte: Can `#F5C400` (Signalgelb), Emine `#5E6E3A` (moosgrün), Azra (vorher Dilara) `#7A2E5C` (pflaumenfarben), Aylin `#3A6EA5` (taubenblau). Minimum je Startraum 11,8, Beweisfarbe 29,6 (Probe 10:52). Gerendert prüft der Sichtprüfer in F4. |
| G2-15 Fehlende Aufträge | Ü | Neue Aufträge F4-BAUMEISTER-08 (Titel, Intro- und Resümee-Bildschirm), -09 (NPC-Karte), F4-ORCH-05 (Spielleitung: Täter für Testläufe festlegen, Pfeife mit Seifenblasen, Gags an Rüstung und Kamin). |
| G2-16 Secret-Scan | Ü | `tool/secret_scan.sh` in F0. Es prüft: `git log --all -- quellen/` ist leer; keine Datei im Verlauf enthält Chat-Kopfzeilen (`[09.10.26,`) oder längere wörtliche Chatblöcke; keine Schlüssel- oder Token-Muster; keine `.env`. Berichte zitieren nur Kurzstellen mit Zeilennummer. |
| G2 offen: Kachel = Meter | Ü | 1 Kachel = 1 m in Raumgraph und Tatmatrix. Die Gehgeschwindigkeit des Detektivs im Spiel ist Bedienkomfort und unterliegt nicht den Tatnacht-Werten aus 7.4. |
| G2 offen: Rundenzeit | Ü | Zwei Uhren: Die Weltuhr je Runde (0:30, 1:15, 2:00, Finale 2:45) steht im Bild, im Erzähler und in den Dossiers. Die Tischzeit (Rundendauer 30 Minuten) ist eine Einstellung; E2E verkürzt sie per Dev-Parameter. |
| G2 offen: PDF-Schriften | Ü | Die PDF-Erzeugung liegt in `mordakte_core` (reines Dart) und bekommt die Schrift-Bytes als Parameter. CLI und App laden sie aus `assets/fonts`. |
| G2 offen: Spoiler über Entwicklerwerkzeuge | V | Gäste mit Browser-Entwicklerwerkzeugen auszuschließen ist kein Ziel eines Partyspiels und technisch nicht durchsetzbar. Eintrag unter FÜR DEN NUTZER. |
| G2 Plan-Summe | Ü | PLAN neu gezählt (siehe Kopf). |

## E-014 · Plan-Schleife Runde 2: Entscheidungen zu F0-GEGEN-03a (33 Altbefunde) und F0-GEGEN-03b (13 Befunde Tatnacht, 10 Beweise, 7 offene Fragen)
- **Ablauf:** Der erste Lauf von F0-GEGEN-03 brach technisch ab (Antwort über der Ausgabegrenze, siehe E-017). Neustart aufgeteilt in 03a (Altbefunde) und 03b (Angriff auf die Tatnacht in Dateien). Beide Rückgaben vollständig (Kopf und Endmarke geprüft).
- **03a, Urteil:** 13 gelöst, 19 teilweise, 1 offen. Entscheidungen zu den Rest-Lücken:

| Befund | Entscheidung | Folge |
|---|---|---|
| G1-1, G2-3 „allein“ undefiniert | Ü | W-1 scharf: Bonus-Hinweise haben **keine** Ausschlusswirkung. Sie bestätigen pfadneutrale Fakten oder decken Nebendelikte auf. Ausschlüsse kommen nur aus Detektiv-Entscheidungen. ABNAHME F-06 ergänzt: Für jede Zahl k richtiger Entscheidungen ist die Restmenge mit beliebigen Hinweisen gleich der Restmenge ohne Hinweise. |
| G1-2 Raten mit 0 Punkten → E2 | V | Die Endenmatrix B-12 ist Vorgabe des Master-Prompts. Der Simulator weist Rate-Enden aus; der E2-Text spricht das Glück an (F3). |
| G1-7 Pflichtgespräche | Ü | Der spoiler_test (F-11) prüft auch Pflichtgespräch-Texte und die öffentlichen Dossierteile: Dort dürfen nur Beobachtungen mit `kanal: pflichtgespraech` stehen, und die sind pfadneutral (Prüfer erzwingt das bereits). |
| G1-9 Simulator-Budget | Ü | Budget in ABNAHME F-06: CLI unter 5 Minuten, Test unter 60 Sekunden. |
| G1-10, G2-13 Dominanz | T | F2-TEST-04 prüft zusätzlich: Keine Option ist für eine Rolle in allen drei Runden kostenlos. |
| G1-11 Sabotage | Ü | F2-ORCH-02 erhält das Kanon-Feld `sabotage` je Kernrolle. |
| G1-12 Lacher, unbesetzte Rollen | Ü | „Verlaufen“ ist vergeben (Olli, 20:15, setting.json). Intro-Bausteine nennen unbesetzte Rollen nur neutral (F3, Erzähler wählt nach Besetzung). |
| G1-13 Geburtstagskind | Ü (erledigt) | Tatmatrix: Augenbinde 23:55:10–0:00:35, Ost-Saal; Plausibilitätsprüfer prüft es. |
| G1-15 Täterfassung im Druck | T | Jede Kernrolle bekommt beide Fassungen in versiegelten Umschlägen mit Zufallscode, die Schlüsselkarte nennt nur den Code. Wer das PDF absichtlich durchliest, kann spoilern; das steht unter FÜR DEN NUTZER. |
| G1-16 Neuprüfung nach Kanon-Änderung | Ü | Regel im PLAN: Jede Kanon-Änderung nach F3 löst Textlint und KONT-Prüfung der betroffenen Texte aus. |
| G2-5 Bestandsänderungen | Ü | Liste der tatsächlichen Bestandsänderungen in E-016. |
| G2-6 Ausfallursache bei 4–5 Rollen | Ü (erledigt) | W1: Tim existiert in jeder Besetzung (bei weniger als 6 Rollen als NPC). |
| G2-9 Worktree ohne SDK | Ü (erledigt) | Aufträge laden die Werkzeugkette über den absoluten Pfad `/home/user/werwolf_digital_flutter/.werkzeug/env.sh`. |
| G2-10 F-17 und PR-Ersatzweg | Ü | ABNAHME F-17: erfüllt mit main = origin/main und Tag, oder mit dem Ersatzweg aus Master §3 (PR mit Abschlussbericht), wenn eine Schutzregel greift; der Abschlussbericht weist das aus. |
| G2-16 Wörtliche Passagen | Ü | Secret-Scan Stufe 4: keine Rohchat-Zeile ab 120 Zeichen wörtlich im Arbeitsstand (`tool/lib/chat_passagen.py`). Ein Fund in einem F0-Bericht wurde gekürzt; im Verlauf steht nur dieser einzelne Feldwert, kein Chatauszug. |
| Übrige „teilweise“ | T | Rest-Lücken sind Aufträge späterer Phasen und dort mit Abnahme belegt (F2–F5). |

- **03b, Tatnacht:**

| Befund | Entscheidung | Begründung, Folge |
|---|---|---|
| 1 Jeder Trenner entscheidet den Fall | V (mit Klarstellung) | Logisch schließt ein Trenner genau eine Kernperson aus (Unschuld) oder lässt sie offen (Tatpfad). Die Spätankunft im Tatpfad schließt niemanden aus; die Restmenge entsteht nur aus Ausschlüssen. Gegenkontakt-Paare würden die Trenner zerstören. F2: Die Spätankunft zählt im Entscheidungsmodell nicht als Ausschluss anderer. |
| 2 Weitere Zeugen am Laufweg (Zeynep, Hana, Wojtek) | V | Der Kaminsaal liegt zwei Türen vom Scheppern entfernt; dort hört niemand das Scheppern (Hörregel). Ohne Bezugsereignis gibt es kein VOR/NACH. Der Wissensvergleich des Prüfers bestätigt es. Regeltext in wahrnehmung.json klargestellt. |
| 3 Schneider in der Gedächtnislücke | Ü (erledigt) | Der Prüfer kappt Schneiders Wahrnehmungen ab 23:58:14. |
| 4 Damir im Ahmet-Pfad | V | Das ist der Trenner: Im Ahmet-Pfad fehlt die Berührung genau während des Scheppern. |
| 5 Pfadverräterische Worte beim Griff | Ü | Ereignistexte neutral, ohne Rede. Der einzige Ruf bleibt „Stehen bleiben!“ in allen Pfaden. |
| 6 Wojtek-Zeile | Ü (erledigt) | Der Prüfer vergleicht das Leuchten ohne Raumbezug; kein Unterschied mehr. |
| 7 Quietschende Tür | Ü | Regel: offene Türen quietschen beim Durchgehen nicht; Zustandswechsel einer quietschenden Tür ist laut (im Rechner umgesetzt). |
| 8 Umschlag-Weg | Ü | Ahmet geht um 0:11 zum Ascheneimer (neue Einrichtung), Hana sieht es (b_hana_umschlag). Planfenster bis 0:15. |
| 9 Notlaterne | Ü | Als Lichtquelle mit leerem Zeitfenster geführt (brennt nie). |
| 10 Zeitversatz in Profilen | Ü | Texte an Pläne angeglichen; Tims Stirnlampe rutscht beim Tasten vom Hals. |
| 11 Notizbuch, Foto, Brottasche | Ü (erledigt) | Stehen als Gegenstände im Kanon, pfadgleich. |
| 12 Klischee-Kopplung | T | Kopftuch bei Fatma bleibt (Quellmaterial, E-007). Gegengewichte: Fatmas Motiv ist Ehrgeiz und die Rückgabe am Montag; Aylin (Kopftuch) ist die kompetente Kassenprüferin; Emine (Kopftuch) die Lehrerin. Neues Feld `alltag` für alle 20 entkoppelt Herkunft und Beruf (z. B. Wojtek studiert Architektur, Pawel ist Rechtsreferendar, Marek führt einen Catering-Betrieb, Serkan ist Rettungssanitäter). Serkans Titel wie in Behzads JSON: „Der Fahrdienst-Organisator“. Sensibilitätsleser F1-SENS-01 prüft die Gesamtverteilung; die Kopftuch-Frage steht unter FÜR DEN NUTZER. |
| 13 Pfeife | V | Vorgabe der Einstellungen: Seifenblasenpfeife. |
| Beweisphysik | T | Azras Ringe aus Holz und Stein (kein Metallabrieb möglich). Übrige Beweise robust; die Beweisprüfung leitet die Entstehung jeder Spur aus der Tatmatrix ab (`beweise_test`). |
| Offene Fragen 1, 2, 4, 7 | Ü | Leuchten sieht man im Dunkeln auch von weitem (nur als Leuchten); Möbel dämpfen nicht; Joannas Foto trägt die Uhrzeit 23:51; Herkunft wird im Spiel nie als Etikett gezeigt, sie dient nur der Ausgewogenheitsprüfung. |

- **Plan-Schleife:** Nach zwei Runden sind keine schweren Befunde offen; die dritte Runde entfällt. Die nächste Gegenprüfung ist F1-GEGEN-01 auf dem fertigen Kanon.

## E-015 · Tatnacht-Modell und Wahrnehmungsregeln (F1)
- **Ziel:** Jede Beobachtung ist aus der Tatmatrix ableitbar (7.4), und kein Zeuge löst den Fall allein.
- **Wege:**
  1. Handgeschriebene 15-Sekunden-Tabellen je Pfad.
  2. Pläne je Person (Aufenthalte, Wege über das Raster, Gesagtes, getragenes Licht). Ein Rechner tastet sekundengenau ab und leitet Sehen, Hören, Fühlen und Riechen her. Die 15-Sekunden-Matrix wird daraus erzeugt.
- **Bewertung:** Weg 1 ist bei 22 Personen × 41 Schritten × 4 Pfaden kaum widerspruchsfrei pflegbar. Weg 2 macht die Regeln prüfbar und die Matrix zum Ableitungsprodukt.
- **Entscheidung:** Weg 2 (`tatmatrix.dart`, `wahrnehmung.dart`, `plausibilitaet.dart`). Verfeinerte Regeln in wahrnehmung.json:
  - drei Lautstärken (sehr laut, laut, leise) und Tumult 23:58–0:00 in Buffetsaal, Durchgang und Ost-Saal;
  - schwaches Licht erkennt bis 3 m, volles Licht im ganzen Raum;
  - wer kauert, sieht nichts;
  - der Bund wird in der Faust getragen und klimpert nur beim Abziehen;
  - Zeitabstände im Dunkeln zählen nicht, nur die Reihenfolge.
- **Umbauten nach dem Wissensvergleich:**
  - Lejla trägt um 23:57:40 die Tortenteller in den Ost-Saal.
  - Olli kauert unschuldig bei Azra statt gegen einen Stuhl zu laufen.
  - Can versteckt den Bund im Täterpfad im Helm der Ritterrüstung.
  - Tugba steht ab 23:55 beim Geburtstagskind.
  - Ahmet startet um 23:58:30.
  - Ergebnis: Jeder der vier Trenner hat genau einen Zeugen (Azra/Olli, Emine/Fatma, Damir/Ahmet, Marek/Can), und niemand sonst weiß pfadabhängig etwas. Das prüft der Test.

## E-016 · Spike und Bestandsänderungen (F1-ORCH-11)
- **Ergebnis:** Der Raumgraph lässt sich ohne Umbau im vorhandenen 2.5D-Renderer zeigen. Weg: `partySzenarioJson` baut aus dem Kanon ein Renderer-Szenario mit einer Vorlage für die Pflichtfelder, Einstieg `preview_main.dart?party=schlosskeller`. Playwright-Probelauf: 0 Konsolenfehler, 0 fremde Netzaufrufe. Fotos an den Nutzer geschickt.
- **Bestandsänderungen bisher** (alle zusätzlich, Standardverhalten unverändert; volle Prüfung grün):
  1. `LookDef.headColor` (optional) und Kopfbedeckung `kopftuch` in `LookDef.hats`.
  2. Figurenzeichner: Fall `kopftuch` (kein Haar darunter), Farbe aus `headColor`.
  3. `preview_main.dart`: Parameter `party`.
  4. `pubspec.yaml`: Assets `content/party/schlosskeller/` und `tatmatrix/`.
  5. Barrel: Exporte des Partymodus.
  6. `build.sh`: `--no-web-resources-cdn` (E-013).
- **Befund für F4:** Der Tisch-Zeichner des Bestands setzt zufällig grüne Flaschen und Messingleuchter auf Tische. Für den Partymodus wird eine eigene Tafel-Darstellung nötig (Teekanne, Tassen, Wasserkaraffe, elektrische Teelichter). Auftrag F4-ORCH-06.
- **Kleinere Befunde für F4:** Teekocher und Kaffeemaschine erscheinen als Herd; die Wendeltreppe als Regal; der Detektiv trägt noch den Mordakte-Hut.

## E-017 · Lernen L-02: Ausgabegrenze bei höchster Denkstufe (F0)
- **Befund:** F0-GEGEN-03 lief 36 Minuten und brach mit „Antwort über 128.000 Ausgabe-Token“ ab. Ursache: ein breiter Prüfauftrag (33 Altbefunde plus Angriff auf Regeln und Kanon) mit `effort: max`.
- **Maßnahme:** Breite Prüfaufträge werden geteilt. Jeder Auftrag nennt eine Längengrenze (höchstens 1.800 Wörter Bericht). Prüfaufträge laufen mit `effort: high`; `max` bleibt für eng geschnittene Autoren- und Gegenprüfaufträge. AUFTRAGSVORLAGE ergänzt.

## E-018 · Lernen L-03: Arbeitsbäume entstehen von main (F1)
- **Befund:** Die Worktree-Isolation legte die Arbeitsbäume von F1-BAUMEISTER-01 und F1-TEST-03 auf `d92a675` (origin/HEAD) an, nicht auf den Arbeitsbranch. Kanon und Party-Code fehlten dort. Beide Agenten haben das erkannt, ohne Git-Schreibbefehle gearbeitet (Snapshot in `/tmp` bzw. Kopie der Daten) und vollständig geliefert. Die Rückgabeprüfung des Workflows verlangte die Endmarke als letzte Zeile; F1-BAUMEISTER-01 setzte offene Fragen dahinter und wurde unnötig neu gestartet (Lauf gestoppt).
- **Maßnahme:**
  - Code-Aufträge mit Worktree beginnen mit Schritt 0: `git checkout --detach <Commit des Arbeitsbranchs>` im eigenen Arbeitsbaum. Das ist die einzige erlaubte Git-Schreiboperation; sie betrifft nur den eigenen Arbeitsbaum.
  - Der Workflow prüft die Endmarke als vorhanden, nicht als letzte Zeile.
  - `.claude/worktrees/` steht in `.gitignore`.
- **Abnahmen:**
  - `ABNAHME F1-TEST-03 · FREIGEGEBEN · Funktion 2 · Kanon 2 · Verzahnung 2 · Inhalt 2 · Grenzen 2 · Summe 10/10`. 14 Sharma-Referenzpaare, Rot-Proben belegt. Übernommen mit einer Anpassung: Pfad über die Testhilfe.
  - `ABNAHME F1-BAUMEISTER-01 · FREIGEGEBEN · Funktion 2 · Kanon 2 · Verzahnung 2 · Inhalt 2 · Grenzen 1 · Summe 9/10`. Ein Punkt Abzug für die Form (offene Fragen nach der Endmarke). Übernommen mit Ergänzung des Felds `alltag`.
  - Die Befunde des Agenten sind umgesetzt:
    - Pipe-Zeichen in der Matrix-Tabelle;
    - alter Name „Merima“ im Lacher am Kamin;
    - neue Verweisprüfung auf alte Namen.

## E-019 · Alle Brüche entschieden (F1-ORCH-03)
- **Verfahren:** Je Bruch ein Denkprotokoll in Kurzform. Wo nichts Stärkeres dagegen sprach, gilt der Vorschlag aus 7.3. Jede Entscheidung ist im Kanon umgesetzt und durch einen Test oder den Prüfer belegt. Spätere Phasen setzen Regeln um, die hier schon entschieden sind (Spalte „Beleg“ nennt das Abnahmekriterium).
- **Prüfwerkzeuge:** `kanon_schema_test`, `kanonVerweise`, `plausibilitaet_test`, `beweise_test`, `farbabstand_test`, `story_bibel_test`, `bin/party_pruefen.dart`.

### Teil 1 · B-01 bis B-17
| Nr | Entscheidung | Kanon / Beleg |
|---|---|---|
| B-01 | Vorschlag übernommen. Kaminsaal = West-Saal mit Kamin-Nische. Vorratsraum (Tatort) hinter der Theke. Turmgang hinter der Bogentür mit Rüstung, Vitrine und Wendeltreppe zum WC. Durchgang zwischen Kaminsaal und Buffetsaal. Windfang innen, Stufen außen. Genau ein Sicherungskasten (Kaminsaal, Ostwand). | `raeume.json`; Verweisprüfung; F-03 |
| B-02 | Herr Schneider schließt um 18:50 Hoftür und Außentor selbst ab. Es gibt einen Bund (Außentor, Hoftür, Turm). Wer ihn nimmt und wo er landet, legt jeder Pfad fest. | `raeume.json` Türen, `gegenstaende.json` bund_schneider, Tatmatrix; Ausgangslage im Prüfer |
| B-03 | Absperren im Dunkeln entfällt. Stufen außen, Windfang innen. Serkan steht am Außentor im Windfang, Marek im Durchgang. | Tatmatrix basis; b_serkan_tor |
| B-04 | Vorschlag übernommen. Deko-Kerzen elektrisch; echt nur der Messingkerzenständer. Der Kamin ist seit 23:30 aus. Restlicht: Notausgangsschild, Leuchtmaske, ab 23:59:30 Handylampen. | `raeume.json` Lichtquellen, `wahrnehmung.json`; Prüfer |
| B-05 | Mitternachts-Klammer übernommen: Torte im Vorratsraum, Tugbas Tortenplan, Tims Steckdose, Schneider will die Notlaterne holen, Zusammenstoß mit Can, danach der Schlag durch eine von vier Personen. | `zeitleiste.json`, Tatmatrix |
| B-06 | Ein Gegenstand „Leuchtmaske“: weiße Gespenstermaske mit nachleuchtender Farbe, Lichtquelle in der Tatmatrix. | `gegenstaende.json` leuchtmaske, `licht_maske` |
| B-07 | Splitter und Kalk an den Pulli-Ärmeln. Marek parkt im Schlosshof auf Schneiders Platz, darum wird durch Hoftür und Turm getragen. | `figuren.json` olli, `zeitleiste.json` z_lieferung, z_tuerschaden |
| B-08 | Schatulle um 23:40, Tasche ausgebeult um 23:45, Schneider findet die Vitrine um 23:53 und stellt Fatma um 23:56. | `zeitleiste.json` |
| B-09 | Ort angeglichen: vor der Vorratsraumtür. Schlüsselbeweis Can = Leuchtfarbe am Griff, Zusatzindiz = Wachs auf der Maske, beides nur im Can-Pfad. Die Kapuzenfasern sind pfadneutral (Schneider packt die Kapuze in jedem Pfad) und eine falsche Fährte. | `gegenstaende.json`; `beweise_test` |
| B-10 | Palette neu (Can, Emine, Azra, Aylin, Detektiv). ΔE2000 je Startraum ≥ 10 (min. 11,8), Beweisfarbe ≥ 20 (min. 22,9). | `figuren.json`; `farbabstand_test` |
| B-11 | Wer im Dunkeln rennt, ist in jedem Pfad Can mit der Leuchtmaske. Zeugen sehen nur ein leuchtendes Gesicht. | Tatmatrix; b_marek_gesicht, b_selin_gesicht |
| B-12 | Endenmatrix wie vorgeschlagen. | `fall.json` enden; F-07 |
| B-13 | Gezählt werden Rollen ohne Geburtstagskind. | `fall.json` personen, `besetzung.json` |
| B-14 | Alkoholfreier Apfelpunsch, kein Rauchen. Die Pfeife des Detektivs bläst Seifenblasen. Mareks E-Zigarette entfällt, er holt Saft. | `setting.json`, `figuren.json`; F-15 |
| B-15 | Namensbalance je Stufe II–V (E-014, E-020). Kopftuch auch bei Aylin (Kassenprüferin) und Emine (Lehrerin). „Hehler“ entfällt. Feld `alltag` entkoppelt Herkunft und Beruf. | `figuren.json`; F1-SENS-01 |
| B-16 | Wachsarten unterscheidbar: rotes Kerzenwachs am Tatort; braunes Möbelwachs an Ollis Handschuh und an der Bogentür (falsche Fährte, sicher widerlegbar). | `gegenstaende.json` arbeitshandschuh_olli, bogentuer_schaden |
| B-17 | Verlaufen: Olli um 20:15 (Lacher). Der Umschlag ist Ahmets Mietgeld-Umschlag (Ascheneimer). Spüle in der Einrichtung. Lichtschächte mit Klappen im Kaminsaal (Luftzug). Türschaden 18:35/18:50 und Schlichtung 23:00 stehen in der Zeitleiste. | `setting.json`, `zeitleiste.json`, `raeume.json` |

### Teil 2 · V-01 bis V-32
| Nr | Entscheidung | Kanon / Beleg |
|---|---|---|
| V-01 | Schneider geht in allen Pfaden denselben Weg; alle vier Motivszenen kommen in jedem Pfad vor (23:51, 23:56, 23:57). | Tatmatrix basis |
| V-02 | Der Handschuh liegt seit 19:30 in der Kamin-Nische (pfadneutral, falsche Fährte). Ollis Zusatzindiz ist der Bund im Eiskübel, in Reichweite. | `gegenstaende.json` |
| V-03 | Ahmets Jacke hängt ab 23:55 am Ständer; er trägt einen schwarzen Pulli über dem weißen T-Shirt. | `figuren.json`, z_jacke |
| V-04 | Beweis nur Messingabrieb; die Vitrine hat einen Holzrahmen ohne Messing. | `gegenstaende.json` silberring_fatma, vitrine |
| V-05 | Schneider ist kurz bewusstlos, hat eine Beule und eine Gedächtnislücke (ab 23:58:14). | `figuren.json` opfer, z_wach |
| V-06 | Tims alte Mehrfachsteckdose an der Kaffeemaschine; die Hauptsicherung fliegt; Tim schaltet um 0:00 im Kaminsaal wieder ein. | Tatmatrix, mehrfachsteckdose_tim |
| V-07 | Jedes Requisit trägt eine Funktion: Klemmbrett (Forderung, Miete 0 €), Quittungszettel, Hoftür, Lichtschacht-Klappen (Luftzug), Pawels Wissen (Schneiders Strenge), Notlaterne (Ziel Schneiders). | `gegenstaende.json`, `beobachtungen.json` |
| V-08 | Angeklagt werden nur die vier Kernverdächtigen. Erweiterungsrollen lügen nie. | `fall.json` kernverdaechtige; `luegen` leer |
| V-09 | Das Geburtstagskind sitzt ab 23:55 mit Augenbinde und Musik im Ost-Saal und ist nie verdächtig. | Tatmatrix; Prüfer |
| V-10 | Zeynep existiert in jeder Besetzung (W1), bei weniger als 10 Rollen als NPC-Gast. | `besetzung.json` |
| V-11 | Geheimnisse sind pfadneutrale Wahrnehmungen. Pfadwissen haben nur die vier Trenner-Zeugen, je genau einer. | `beobachtungen.json`; `plausibilitaet_test` |
| V-12 | Regel: Jede Kernrolle hat die gleichen Bausteine (Motivszene, Nähe zur Theke um 23:57, Nebendelikt mit Spur, mindestens eine widerlegbare Lüge, genau ein Trenner). Gleich viele erreichbare Belastungsfunde je Pfad legt das Entscheidungsmodell fest. | `figuren.json`, `beobachtungen.json`; F-06 (Simulator je Pfad) |
| V-13 | 1 Kachel = 1 m; Wege und Zeiten geprüft. | `raeume.json`; Prüfer |
| V-14 | Weißer Kalk vom Türbogen statt Lack. | `figuren.json` olli |
| V-15 | Jede Rolle hat `persoenlichesZiel` und `loyalitaet` als Quelle für Kosten und Nutzen der Gruppenwahl (E-013). | `figuren.json`; F-08 |
| V-16 | Alle außer dem Detektiv stimmen geheim; sichtbar ist nur die Qualität; Sabotage G-1. | E-013; F-08 |
| V-17 | Entschieden in E-008. | – |
| V-18 | Die Restmenge ergibt sich aus aufgedeckten Fakten (E-013). | F-06 |
| V-19 | Anker-Raster: Kernrollen höchstens 7 Pflichtgespräche je Runde (F2-ORCH-06). | F-09 |
| V-20 | W1: Jede Ursache existiert unabhängig von der Besetzung. | `besetzung.json` |
| V-21 | Besetzungsreihenfolge ab 5 Rollen mit höchstens einer Person Unterschied. | `besetzung.json`; `kanon_schema_test` |
| V-22 | Motive aus der Lage: Ahmet schämt sich für eine zu große Essensbestellung, Fatma ist ehrgeizig, Olli soll 2.000 € zahlen, Can wollte erschrecken. Die Bestechung wird zur Bitte um Aufschub. | `figuren.json` |
| V-23 | Loyalität individuell begründet (`loyalitaet.grund`). Emine schweigt aus Freundschaft; die Scherben-Vertuschung entfällt. | `figuren.json` |
| V-24 | Alle vier Taten geschehen in Panik im Dunkeln, ein Schlag. | `figuren.json` killerProfile, Tatmatrix |
| V-25 | Neue Etiketten aus der Funktion: „Die Designstudentin“, „Die Schreckhafte“, „Der Organisator“, „Der Spaßvogel“. | `figuren.json`; F1-SENS-01 |
| V-26 | Schneiders Ärger gilt nur Sachen und Geld; Feld `warmeSeite`. | `figuren.json` opfer |
| V-27 | Fachwortliste im TON-LEITFADEN; im Kanon ersetzt (Warmhaltebehälter, Spannungsprüfer-Schraubenzieher, Handyhalter, großer Teekocher, Buffettheke, Schlüsselband, Kapuzenpulli, Bauchtasche, Stoffhose). | `figuren.json`; F-10 (textpruefer_test) |
| V-28 | Namensbalance ohne Klangpaare; Feld `aussprache` für die Stimme. | `figuren.json`; E-020 |
| V-29 | „Buffettheke“, Getränke ausdrücklich genannt; Negativliste für Bildprompts. | `setting.json`; F-15 |
| V-30 | Stil- und Negativanker, keine Herkunftswörter in Prompts. | TON-LEITFADEN §9; F-13 (bildprompt_test) |
| V-31 | Spüle in der Einrichtung. | `raeume.json` spuele |
| V-32 | Renderer-Ergänzungen im Partymodus (Kopftuch erledigt; Fog, Licht, Ruhe-Animation, Tafel in F4). | E-016; F4 |

### Teil 3 · A-01 bis A-33
| Nr | Entscheidung | Kanon / Beleg |
|---|---|---|
| A-01 | Eine Buffettheke mit Anrichte dahinter. | `raeume.json` |
| A-02 | „Außentor“: zweiflügelige, eisenbeschlagene Eichentür mit Kastenschloss. | `raeume.json` aussentor |
| A-03 | Ein Bund. | bund_schneider |
| A-04 | Außen: Stufen zum Parkplatz. Schlosshof mit Schneiders reserviertem Platz hinter der Hoftür. | `setting.json`, `zeitleiste.json` |
| A-05 | „Jackenständer“. | `raeume.json` |
| A-06 | Durchgang, Turmgang, Windfang als einzige Gänge. | `raeume.json` |
| A-07 | Kamin-Nische im West-Saal, Anzeigename „Kaminsaal“. | `raeume.json` |
| A-08 | Sicherungskasten im Kaminsaal (Ostwand). | `raeume.json` |
| A-09 | Detektiv: markante Brille, braun karierter Hut, Lichtkegel vom Handy in der Hand, Seifenblasenpfeife, Kleidung aus dem JSON. | `figuren.json` detektiv |
| A-10 | Schneider startet im Buffetsaal. Die Stabtaschenlampe entfällt; er will die Notlaterne holen. Optik aus dem JSON. | `figuren.json` opfer |
| A-11 | Ahmet: Alibi „hinter der Theke“, Bart übernommen, Motiv ist die Bekanntgabe um zwölf. Umschlag im Kamin-Ascheneimer. Bitte um Aufschub statt Bestechung. Zu große Essensbestellung statt Schulden. | `figuren.json` ahmet |
| A-12 | Fatma: BAföG entfällt, dunkler Rollkragen, nur Messing am Ring, Polizei. Münzschatulle statt einzelner Münze; Vorgeschichte 23:40. | `figuren.json`, `zeitleiste.json` |
| A-13 | Olli: Bogentür; Splitter und Kalk an den Pulli-Ärmeln. Das Maßband trägt Wojtek. Fuß des Ständers. Tore zu bis zur Zahlung. Eis holen. Handschuh in der Kamin-Nische. | `figuren.json`, `gegenstaende.json` |
| A-14 | Can: Leuchtmaske, Versteck Vorratsraum, Schneiders Griff an die Kapuze, Maske bleibt in der Bauchtasche, Signalgelb #F5C400. | `figuren.json`, `gegenstaende.json` |
| A-15 | Zeynep: Schwester, weite hellgraue Hose, wusste von der Maske, steht am Bogen. | `figuren.json` |
| A-16 | Lejla: Ahmets Rechnung fürs Essen; Alibi mit den Tortentellern (E-015). | `figuren.json` |
| A-17 | Tim: Kaffeemaschine an der Mehrfachsteckdose; neue Wahrnehmung (Gesicht am Sicherungskasten); Alibi am Sicherungskasten. | `figuren.json` |
| A-18 | Emine: ohne Scherben-Vertuschung, am linken Buffettisch, schwarze Stiefel. | `figuren.json` |
| A-19 | Joanna: Stoffhose, Aufsteckleuchte am Handyhalter, Foto von 23:51. | `figuren.json`, foto_joanna |
| A-20 | Marek: reservierter Platz, Durchgang, keine E-Zigarette, Autoschlüssel. | `figuren.json` |
| A-21 | Baran: „Der Mann für die Musik“; Rufe statt unmöglicher Schritte. | `figuren.json` |
| A-22 | Hana: Kaminklappe nicht geöffnet. | `figuren.json`, `setting.json` |
| A-23 | Serkan: „Der Fahrdienst-Organisator“, wollte Decken holen, steht im Windfang. | `figuren.json` |
| A-24 | Der Quittungszettel stammt aus Schneiders Block und liegt in Aylins Mappe. | quittung_aylin, klemmbrett_schneider |
| A-25 | Wojtek: Arbeitshose mit verstärkten Knien; Möbelwachs statt Kitten; Satz von 23:52. | `figuren.json` |
| A-26 | Azra: Hehler entfällt; Schneider fand ihr Interesse an der Vitrine seltsam. | `figuren.json` |
| A-27 | Damir: „Der Teemeister“, schwarze Schürze, Theke. | `figuren.json` |
| A-28 | Selin: Kaminsaal; sieht das Leuchten der Maske. | `figuren.json` |
| A-29 | Pawel: Schlossstiftung; trinkt Tee. | `figuren.json` |
| A-30 | Tugba: Ablaufplan an der Wandtafel, Notizbuch, Liste von 23:57. | `figuren.json`, notizbuch_tugba |
| A-31 | Hexwert maßgeblich, dazu `farbname`. | `figuren.json` |
| A-32 | Koordinaten in Metern; Ermittlungsort statt freier Koordinaten. | `figuren.json`; Verweisprüfung |
| A-33 | Detektiv mit Farbcode, Startort und Look. Schneider mit Motiv und warmer Seite. Kernrollen mit Geheimnis. | `figuren.json` |

### Zusatzindizien aus dem Täter-System
Behzads Zusatzindizien werden ersetzt, wo sie nicht nur im eigenen Pfad entstehen können:

| Pfad | Quelle | Kanon | Grund |
|---|---|---|---|
| Ahmet | Schmierzettel in der Spüle | Wachs auf dem Umschlag | Schneiders Notiz gäbe es in jedem Pfad. Der Zettel entfällt; die Mietsache belegen Klemmbrett und Quittung. |
| Fatma | Münze mit Wachs | Schatulle mit Wachs | übernommen (Schatulle statt Münze, B-08) |
| Olli | Handschuh mit Wachs in der Kamin-Nische | Bund im Eiskübel | Den Handschuh gibt es in jedem Pfad; er bleibt als falsche Fährte mit braunem Möbelwachs (B-16, V-02). |
| Can | Delle mit Messingabrieb an der Maske; gelbe Fasern | Leuchtfarbe am Griff; Wachs auf der Maske | Der Griff durch die Maske passt nicht zur Panik. Die Fasern entstehen in jedem Pfad (B-09). |

## E-020 · Namensbalance und Klang (F1)
- **Zuordnung** (IDs bleiben Schlüssel, E-014):
  - Stufe II: Leyla → Lejla (bosnisch, Ahmets Cousine), Johanna → Joanna (polnisch).
  - Stufe III: Murat → Marek (polnisch), Meryem → Hana (bosnisch).
  - Stufe IV: Kaan → Wojtek (polnisch), Dilara → Azra (bosnisch).
  - Stufe V: Hakan → Pawel (polnisch), Enes → Damir (bosnisch).
- **Verworfene Zwischenstände und Grund:**
  - Merima: Klang nah an Marek.
  - Kuba: Reim auf Tugba.
  - Bartek: Anfang wie Baran.
  - Enis: Klang nah an Emine.
- **Herkünfte:** deutsch 2, türkisch 6, kurdisch 3, bosnisch 5, polnisch 4.
- **Sprache:** Das Feld `aussprache` steuert die Stimme (z. B. Can → „Dschan“, Tugba → „Tuuba“, Wojtek → „Woitek“).
- **Nachtrag (E-021):** Selin heißt Sibel (Reim Selin/Aylin, F1-SENS-01). Damit sind 9 Namen geändert; Stufe V bleibt ausgewogen.

## E-021 · F1-Prüfrunde: Entscheidungen zu F1-KONT-01, F1-KONT-02, F1-GEGEN-01, F1-SENS-01
- **Abnahmen:** Alle vier Berichte vollständig, mit Fundstellen und Endmarke.
  - `ABNAHME F1-KONT-01 · FREIGEGEBEN · 10/10`
  - `ABNAHME F1-KONT-02 · FREIGEGEBEN · 10/10`
  - `ABNAHME F1-GEGEN-01 · FREIGEGEBEN · 10/10`
  - `ABNAHME F1-SENS-01 · FREIGEGEBEN · 10/10`

| Befund | Entscheidung | Folge |
|---|---|---|
| KONT-01 #4, KONT-02 #3: Grund für das Mitnehmen des Bunds fehlt | Ü | Ein gemeinsamer Grund in allen vier Täterfassungen: In Panik reißt die Person den Bund ab, weil man mit dem Schlüssel rauskommt; gleich danach merkt sie, dass Flucht alles schlimmer macht, und versteckt ihn. |
| KONT-01 #3, KONT-02 #2: Anlass für Griff und Schlag | Ü | Herr Schneider zischt je Pfad leise einen Satz (Ereignis `ev_<pfad>_drohung`, nur die Täterperson ist näher als 1,5 m; der Wissensvergleich bestätigt das). Griffzeit gleich Ankunftszeit (Fatma, Olli 23:58:38). Fatmas Geheimnis begründet die sofortige Rückgabe. |
| KONT-01 #2: Sturz statt Gehen | Ü | Neues Tempo `faellt` (ohne Schrittgeräusch, Grenze wie Rennen). |
| KONT-01 #5: Verbleib des Mietgelds | Ü | Gegenstand `mietgeld` (2.850 € in Ahmets Hosentasche ab 0:12), widerlegt die Miet-Lüge. |
| KONT-01 #7: Handy-Merkmal nach 23:55 | Ü | Zeitleiste `z_handys` (0:05 Handys zurück); Ahmets Merkmal mit Zeitbezug, neue Ruhe-Animation. |
| KONT-01 #10: Belegfenster Leuchten | Ü | Bis 23:59:30. |
| KONT-01 #1, #11: Matrix-Schritte | V | Die 15-Sekunden-Matrix tastet genau zur Zeile ab; wer zur Zeile losgeht, steht dort noch am Start. Ereignisse zwischen den Zeilen stehen in der Tatmatrix-Datei. |
| KONT-01 #6, #8, #9 | V | Aylin hält die Quittung bewusst zurück (ihr Ziel). Pläne müssen nicht jede Reaktion zeigen. Beweisdichte ist je Pfad gleich: ein Schlüsselbeweis, ein Zusatzindiz. |
| KONT-02 #1: Schneiders Erinnerung | V | Die Gedächtnislücke für die Sekunden vor dem Schlag ist gewollt (V-05). |
| KONT-02 #4: Fatmas Beweis nicht sichtbar | V | Entscheidungen zielen auf Orte, Gegenstände und Personen (F-12). Fatmas Ring wird über eine Personen-Entscheidung untersucht, die es in allen Pfaden gibt (F2). |
| KONT-02 #5, #6 | V | Die Sichtungen sind anonym („leuchtendes Gesicht“) und widerlegen Cans Lüge nicht allein; die Ausbeulung widerlegt „nur Bücher“ nicht. Widerlegt wird über Fasern, Zeynep, Glassplitter und Schatulle. |
| KONT-02 #7–#11 | Ü | Spur der Schatulle (Hand, Tasche); „Herr Schneider am Ostende“; „kurz nach dem Scheppern“; Fasertext; Notizbuch widerlegt auch Fatmas Buffet-Lüge. |
| GEGEN-01 #1: Leuchtfarbe nur im Dunkeln | Ü | Spur ist ein Handabdruck aus grünlich-weißer Farbe, im Licht sichtbar. |
| GEGEN-01 #2: Abkürzung über den Bund | T | Kanon bleibt (vier gleiche Untersuchungsziele, Bund nie Kartenmarker). Regel für F2: Der Bund ist erst in Runde 3 suchbar, in einer Entscheidung mit höchstens drei Bereichen. |
| GEGEN-01 #3: Wortmarker in Trenner-Fassungen | Ü | Beide Fassungen je Trenner im gleichen Satzbau; „außer Atem“ gestrichen. |
| GEGEN-01 #4: Trenner-Zeugen bei kleiner Besetzung | Ü | Regel: Ist ein Zeuge unbesetzt, zeigt die Befragung eine NPC-Karte mit seiner Fassung (App: aus dem Kanon, Druck: versiegelt je Fall-Code). Umsetzung F2-ORCH-06, F5. |
| GEGEN-01 #5: Messing am Ring durch den Bund | Ü | Schlüssel aus dunklem Eisen am Stahlring (`schluesselbundMaterial`). |
| GEGEN-01 #6: Farbe am Griff in fremden Pfaden | Ü | Die Spur ist ein Handabdruck um den Griff; er entsteht nur durch festes Zupacken. |
| GEGEN-01 #7, #8, #11 | V | Damirs Spürzeile steht in der Tatmatrix; Ollis Ärmel sind sein Nebendelikt in allen Pfaden, der Schlüsselbeweis ist das Wachs am Fuß; der Hinweis im Kanon regelt den Bund. |
| GEGEN-01 #9, #10 | Ü | Handschuh-Zeitpunkt (18:45); verbogener Schaft als pfadneutrale Spur; Texte angeglichen. |
| SENS-01 1/2, B1: „bar“ | Ü | „2.000 € Bargeld“. |
| SENS-01 B2, B3: Ziffern in Texten | T | Kanon-Felder dürfen Ziffern tragen; Vorlesetexte (`texte/*.json`, F3) schreiben Uhrzeiten und Beträge in Worten. Der Textprüfer prüft nur Vorlesetexte. |
| SENS-01 B4: „Fall-Code“ in der Zeitleiste | Ü | Neutral formuliert. |
| SENS-01 B5, B6, B7, B8, B9, B10, B11, B13, B14 | Ü | Loyalität ohne Geldbezug. Marek „Der Caterer“, Parken nach Telefonauskunft. Wojtek „Der Architekturstudent“, schlank, mit Brille. Lejla ohne „trotzdem“. Hana und Sibel: Ziele über Sachen statt Spott. Fatma lächelt Emine zu. Aylin sachlich. Emine „Die Grundschullehrerin“, Zeynep „Die Fußballtrainerin“. |
| SENS-01 B12: Kopftuch bei 2 von 3 kurdischen Figuren | Ü | Das dritte Kopftuch geht von Aylin (kurdisch) zu Azra (bosnisch). Verteilung: kurdisch 1, türkisch 1, bosnisch 1, je unbelastet und kompetent außer Fatma. |
| SENS-01 B16 | V | Teemeister ist Quellenrolle und Getränk des Abends. |
| SENS-01 Namensklang | T | Selin → Sibel (Reim). Serkan, Can und Baran bleiben, weil die Anlaute klar verschieden sind. Hana/Azra bleiben. |

## E-022 · F1-Prüfrunde: Entscheidungen zu F1-KONT-03 (Pfad Olli)
- **Abnahme:** `ABNAHME F1-KONT-03 · FREIGEGEBEN · 10/10`. Vollständig, jede Fundstelle mit Gegenstelle, Selbstprüfung über alle vier Kernverdächtigen, Endmarke vorhanden.

| Befund | Entscheidung | Folge |
|---|---|---|
| #1 Sturz Schneider | schon erledigt (E-021) | Tempo `faellt`; die Matrix zeigt „fällt“ statt „geht“. |
| #2 Notlaterne „nie bis zu ihr gekommen“ | Ü | Spurtext: „Herr Schneider hat sie nie in die Hand bekommen.“ |
| #3 Handykorb vor 23:55 | Ü | Der Korb steht seit 23:50 auf der Tafel, ab 23:55 kommen die Handys hinein. Olli wartet 23:52:30 nicht mehr am Korb, sondern setzt sich an den Kopf der Ost-Tafel. |
| #4 Eis für Wojtek nie übergeben | Ü | Olli bringt Wojtek um 0:01 das Eis („Hier, dein Eis. Sorry, hat gedauert.“), danach zurück an die Ost-Tafel. Gilt in allen Pfaden; das Unschuldsprofil nennt es. |
| #5 Motiv für den Bund | schon erledigt (E-021) | Gemeinsamer Fluchtgrund in allen Täterfassungen. |
| #6 Olli neben Cans Fluchtweg | V | Das ist Ollis eigene Wahrnehmung im Olli-Pfad. Der Rechner erzeugt sie; das Täterdossier (F3) schöpft aus ihr. Eine Zeugen-Beobachtung braucht es nicht, weil Olli als Täter lügt. |
| #7 Griff vor Ankunft | schon erledigt (E-021) | Griff 23:58:38. |
| #8 Wachszustand | Ü | Zur Tat „noch weich“, als Spur „inzwischen erstarrt“; Schlüsselbeweis und Spurtext gleich formuliert. |
| #9 Handschuh in Weste und am Kamin | Ü | Merkmal: „ein Arbeitshandschuh hängt aus der Westentasche, der zweite liegt seit 19:30 am Kamin“. |
| Frage „um Mitternacht“ | V | Kanon gilt: Strom aus 23:58:00. „Um Mitternacht“ ist die Erzählweise der Gäste; Vorlesetexte sagen „kurz vor Mitternacht“. |
| Frage „wer legt Schneider hin“ | V | Sturz nach dem Schlag, in allen Pfaden gleich (`faellt`). |
| Frage „Bund unter dem Eis bis 0:02“ | V | Fluchtgrund aus E-021: Olli will nicht mehr fliehen und lässt den Bund liegen. Ab 0:00:18 brennt Licht, der Kübel steht mitten am Thekenende; ihn dort herauszuholen sähen alle. |

## E-023 · F1-Prüfrunde: Entscheidungen zu F1-KONT-04 (Pfad Can)
- **Abnahme:** `ABNAHME F1-KONT-04 · FREIGEGEBEN · 10/10`. Vollständig, Fundstellen mit Gegenstellen, Geschwindigkeiten nachgerechnet, Endmarke vorhanden. Der Prüfer las den Kanon teils vor dem Stand von E-021; Befunde #1 und #4 waren dort schon erledigt.

| Befund | Entscheidung | Folge |
|---|---|---|
| #1 Motiv für den Bund | schon erledigt (E-021) | Gemeinsamer Fluchtgrund; Can hört die Drohung `ev_can_drohung` aus unter 1,5 m. |
| #2 Auslöser für „Buuuh!“ | T | Auslöser ist die quietschende Vorratstür (`ev_vorratstuer_auf`, im selben Raum laut), nicht Schneiders Satz. Can glaubt, das Geburtstagskind wird schon zur Torte gebracht (`z_tortenplan`). Steht jetzt in Cans Motivtext. |
| #3 Gang zum Liegenden fehlt im Profil | Ü | „Herr Schneider stürzt in den Vorratsraum. Can kniet sich neben ihn und reißt in Panik den Bund vom Gürtel.“ |
| #4 Leuchtfarbe nur im Dunkeln | schon erledigt (E-021) | Handabdruck in grünlich-weißer Farbe, im Licht sichtbar. |
| #5 Maske und Fasern nicht sichtbar | V | Wie E-021 (KONT-02 #4): Entscheidungen zielen auch auf Personen; Bauchtasche und Schneiders Hand werden über Entscheidungen untersucht, die es in allen Pfaden gibt (F2). |
| #6 „unter einer Kapuze“ | Ü | Gestrichen; bei Eigenleuchten sieht man nur das Gesicht. |
| #7 Fasern als falsche Fährte im Pfad Can | Ü | Rolle je Pfad: in Ahmet, Fatma, Olli `falsche_faehrte`, in Can `ausgangslage`. |
| #8 Lichtschritt der Vorratslampe | Ü | Ereignis `ev_vorratslicht_aus` (23:54:20, Can). Das Einschalten stand schon als `ev_vorratslicht` (0:00:18, Damir). Die Lichtzeiten selbst stehen in `raeume.json`. |
| #9 Matrix nur 23:55–0:05, WC-Zusatzweg | V | Das Fenster ist F-04. Der Rechner prüft die Pläne 23:50–0:15 jede Sekunde und rechnet den Zusatzweg in die Weglänge ein; die Karte zeigt das WC an seiner Tür. |
| #10 „um Mitternacht“ | V | Wie E-022. |
| Frage 4: Ahmets Stelle | Ü | „hinter der Theke am Ostende“. |
| Fragen 1–3 | V | Nach 0:00 gibt es keine Dunkelphase; die Spur ist im Licht sichtbar. Zugang zu Bauchtasche und Zeitleiste regelt F2 (Entscheidungen und Pflichtgespräche). |

## E-024 · F2: Entscheidungsmodell, Restverdächtige, Bonus-Hinweise (Denkprotokoll)
- **Frage:** Wie werden die neun Entscheidungen so gebaut, dass bei bestem Spiel nach Runde 2 genau zwei und nach Runde 3 genau eine Person übrig sind? Dabei soll kein Bonus-Hinweis ausschließen, jede richtige Option eine Begründungskette haben und keine falsche Option einen Schlüsselbeweis oder ein Zusatzindiz zeigen.
- **Verworfen:**
  - **Trenner allein schließt aus.** Dann klärt Runde 1 den Fall fast ganz (drei Alibis, eine Spätankunft).
  - **Abwesenheit einer Spur schließt aus**, etwa „keine Farbe am Griff“. Dann löst eine falsche Option den Fall (Kerzenständer im Pfad Fatma).
  - **Richtig ist immer die Option zur Täterperson.** Dann schließen die falschen Optionen Unschuldige aus.
- **Gewählt: Regeln des Ermittlungsbogens**
  - **R-ENTLASTET:** Wer beim Scheppern nachweislich woanders war (Alibi aus einer Befragung) **und** wessen Heimlichtuerei belegt ist (Nebendelikt aus einer Entscheidung), scheidet aus.
  - **R-UEBERFUEHRT:** Ein Schlüsselbeweis überführt; alle anderen scheiden aus.
  - Spätankunft, Zusatzindiz, Fundort und Motiv belasten nur. Sie ändern den Stand, nicht die Restmenge.
  - Harmlose Fassungen sind neutral formuliert („mit rotem Wachs verschmiert“) und lösen keine Regel aus. Wer aus dem Fehlen einer Spur selbst schließt, spielt gut; die Restmenge bleibt eine sichere Untergrenze.
- **Runde 1, Das Alibi-Geflecht** (pfadunabhängig richtig): Befragung der Trenner Damir, Emine, Azra; die falschen Optionen sind Joanna, Tugba und Tim. Das ergibt Alibis oder eine Spätankunft. Marek ist keine Entscheidung; sein Trenner-Wissen kommt als wahrer Bonus-Hinweis in Runde 1.
- **Runde 2, Die Indizien-Filterung:**
  - e2_1 Ascheneimer oder Cans Bauchtasche. Pfadabhängig: im Pfad Can die Bauchtasche, weil dann alle anderen ein Alibi haben.
  - e2_2 Fatmas Tasche oder Vitrine.
  - e2_3 Olli untersuchen oder Kamin-Nische.
  - Ergebnis: Das Nebendelikt wird belegt, im Täterpfad zusätzlich das Zusatzindiz. Bei bestem Spiel bleiben genau zwei übrig: die Täterperson und Can, im Pfad Can Ahmet und Can.
- **Runde 3, Die finale Gegenüberstellung:**
  - e3_1 Bundsuche in einem von drei Bereichen.
  - e3_2 Kerzenständer genau untersuchen oder Fatmas Hände und Ring.
  - e3_3 Zeynep oder Aylin; deckt das letzte Nebendelikt auf.
  - Mit dem Schlüsselbeweis bleibt genau eine Person.
- **Kanon-Folgen, damit jeder Pfad gleich gebaut ist** (je ein Schlüsselbeweis, ein Zusatzindiz und ein Fundort des Bunds):
  - Ahmet: Schlüsselbeweis ist die abgerissene Umschlag-Ecke im Wachs am Griff. Der Bund in der Jacke wird Fundort.
  - Olli: Zusatzindiz ist rotes Kerzenwachs am rechten Arbeitshandschuh in der Westentasche; das passt zur Quelle, die einen Handschuh als Zusatzindiz nennt. Der Bund im Eiskübel wird Fundort.
  - Der linke Handschuh am Kamin ist nur noch rußig.
  - Neue Pflichtgespräch-Beobachtungen: `b_emine_versteck` und `b_azra_versteck`. Neue verborgene Beobachtung: `b_wojtek_tuer`.
  - Bei jedem belegten Nebendelikt gibt die Person es auf Nachfrage zu.
- **Bonus-Hinweise (36):**
  - **wahr:** Runde 1 die Spätankunft der Täterperson (im Pfad Can Mareks Satz über das leuchtende Gesicht), Runde 2 ein Geheimnis oder Motiv der Täterperson, Runde 3 eine Entlastung der zweiten Person, die bei bestem Spiel übrig ist. Die Entlastung schließt nie allein aus, weil R-ENTLASTET zusätzlich das belegte Nebendelikt verlangt (W-1). Korrigiert nach F2-FALL-01.
  - **neutral:** wahre, pfadgleiche Sätze über Kernpersonen ohne neuen Wert.
  - **falsch:** ein Gerücht über einen Unschuldigen in derselben Satzform wie die wahren Hinweise. Jedes Gerücht widerlegt eine Entscheidung, die im selben Pfad richtig ist (`widerlegtDurch`).
  - Hinweise wirken nie auf die Restmenge (W-1 scharf).
- **G-1 präzisiert:** Sichtbar ist nur, ob die Gruppe zusammengehalten hat (wahr) oder nicht (neutral oder falsch), nie die Zahl. Sonst wäre ein als falsch erkanntes Gerücht ein Freispruch.
- **Wertung:** Punkte sind nur die richtigen Detektiv-Entscheidungen (0–9). Die Gruppenwahl bringt Hinweise, keine Punkte.
- **Nachtrag (Simulator-Lauf):**
  - **Befund:** Im Pfad Can schließt die falsche Option e2_1 (Ascheneimer) Ahmet aus, die richtige (Cans Bauchtasche) nicht.
  - **Ursache:** Der Pfad, dessen Trenner Runde 1 nicht befragt, hat nach Runde 1 drei Alibis.
  - **Suche:** Eine erschöpfende Suche über alle Aufteilungen von Runde 2 mit fester Runde 1 (Damir, Emine, Azra) fand keine Aufteilung, in der bei bestem Spiel nach Runde 2 genau zwei übrig sind und keine falsche Option mehr ausschließt.
  - **Ergebnis:** Das ist strukturell: In einem Pfad muss die richtige Option statt eines Ausschlusses ein Indiz gegen die Täterperson liefern.
  - **Regel (Prüfung im Simulator):** Eine falsche Option darf nur dann mehr ausschließen als die richtige, wenn die richtige ein belastendes Indiz gegen die Täterperson zeigt (Spätankunft, Zusatzindiz, Fundort, Schlüsselbeweis).
  - **Begründung:** Für die Spielenden ist das auch inhaltlich richtig. Nach drei Alibis ist Cans Bauchtasche die naheliegende Wahl; Ahmets Nebendelikt klärt nur noch eine Lüge.

## E-025 · F2-Prüfrunde: Entscheidungen zu F2-TEST-01..04, F2-FALL-01, F2-GEGEN-01
- **Abnahmen:**
  - `F2-TEST-01`, `F2-TEST-02`, `F2-TEST-03`, `F2-TEST-04`: je FREIGEGEBEN · 10/10. 78 neue Tests, jede Prüfung mit Rot-Probe, nur eigene Dateien.
  - `F2-FALL-01`: FREIGEGEBEN · 10/10. Genaue Zahlen, fand die Abweichung in E-024.
  - `F2-GEGEN-01`: FREIGEGEBEN · 10/10. Drei schwere Befunde mit Schritten.
- **Offene Fragen der Testschreiber:**
  - Sabotage ohne kooperative Stimme ergibt 0 (Untergrenze, gewollt).
  - Der Laufzeittest unter 60 s bleibt, weil F-06 das Budget verlangt.
  - J3 (Widerlegung in derselben oder früheren Runde) bleibt als Zusatzprüfung.

| Befund | Entscheidung | Folge |
|---|---|---|
| GEGEN #1: Gruppenzeile je Runde verrät mit dem Hinweis die Wahrheit | Ü | Vor der Auflösung zeigt das Spiel weder Qualität noch Stimmenzahl. Das Resümee-Fach „Gruppenergebnis“ sagt nur, dass die Runde etwas zugeflüstert hat (`resuemee.gruppe.<runde>`). Erst die Auflösung nennt, wie oft die Gruppe zusammengehalten hat (`aufloesung.gruppe.<n>`). G-1 in fall.json angepasst. |
| GEGEN #2: Sabotage bei 4 Rollen sichtbar | Ü (durch #1) | Ohne sichtbare Qualität ist keine Täterwahl ablesbar. |
| GEGEN #3: Kerzenständer überführt allein in drei Pfaden | Ü | R-UEBERFUEHRT verlangt Schlüsselbeweis und Fundort des Bunds derselben Person. Restmenge 1 mit weniger als 9 Punkten fällt von 383 auf 127 Folgen je Pfad. |
| GEGEN #4, FALL #1: erste Option meist richtig | Ü | Die App mischt die Anzeige je Fall-Code (`Spiel.optionen`, deterministisch). Die Kanon-Reihenfolge ist ausgeglichen: Ratestrategien kommen auf 3–6 Punkte, kein Pfad erreicht Meister. Fragetexte von e2_2 und e2_3 nennen keine Person mehr. |
| GEGEN #5a, c, d | Ü | Kette e2_1 (Pfad Can) spricht von Alibis, nicht von Ausschluss. Ketten in Runde 1 nennen das Gegenargument zur falschen Option. |
| GEGEN #5b | T | e3_3 bleibt eine Entscheidung ohne Wirkung auf die Restmenge in drei Pfaden. Sie deckt das letzte Nebendelikt auf (F-06 „bei bestem Spiel jedes Nebendelikt“). Die Kette nennt jetzt den Grund. |
| GEGEN #6a, FALL #3 | T | Die R3-Entlastung bleibt; sie schließt nie allein aus. E-024 ist korrigiert. |
| GEGEN #6b | V | Die R3-Gerüchte über das Bund-Versteck widerlegt die Bundsuche. Eine Fassung in Alibi-Form ließe sich durch keine Entscheidung widerlegen, weil Marek keine Entscheidung ist. Ohne sichtbare Qualität ist die Satzform nur über viele Abende lernbar (NEBELKARTE). |
| GEGEN #6c | Ü | Neutrale Hinweise haben jetzt die Satzform der Runde und sind wahr in allen Pfaden: Tim am Sicherungskasten, Tims Steckdose, Serkan am Tor. |
| GEGEN #6d | Ü | Die Vitrine zeigt den Diebstahl, nicht die Person: Rolle `umgebung`. |
| GEGEN #6e | V | Die Lage-Stufe gibt nur wieder, was der Detektiv gerade selbst gelesen hat. |
| GEGEN #7 | V | B ist nicht dominant: A kostet die Rolle etwas, hilft aber dem Ende der Gruppe. Die Auflösung zeigt das persönliche Ziel (E-013). F3 macht A im Text verlockend. |
| FALL #2: wahre Hinweise nennen den Täter | V | Ohne sichtbare Qualität ist ein wahrer Satz über die Täterperson nicht von einem Gerücht über einen Unschuldigen zu unterscheiden. Die Bestätigung kommt erst über eine Entscheidung. |
| FALL #4 | V | Wie E-024, Nachtrag. |
| FALL #5 | Ü | Der Simulator-Bericht führt drei Ratestrategien je Pfad. |

- **Regelkreis Lernen:**
  - **L-04:** Prüfaufträge stellen das Rollenbriefing wortgleich aus ROLLENBRIEFINGS.md voran. In F2-FALL-01 und F2-GEGEN-01 war es gekürzt.
  - **L-05:** Aufträge, die nur neue Dateien anlegen, laufen ohne eigenen Arbeitsbaum direkt im Repo. Rückgaben werden vor dem Commit selbst nachgeprüft.

## E-026 · F3: Textsammlung und Zuschnitt der Autorenaufträge (F3-ORCH-00)
- **Textsammlung** unter `content/party/schlosskeller/texte/`:
  - Index, je Auftrag eine Datei, Schemas je Bereich (`texte-*.schema.json`).
  - Lader und Zusammensetzer: `party/texte.dart`. Prüfungen: `textVerweise` und `textLuecken`. Anleitung: `texte/SCHLUESSEL.md`.
- **Verweise statt Abschrift.** Dossiers nennen Tatsachen als `beobachtung:`, `luege:`, `nebendelikt:`, `zeitleiste:` oder `spur:`. Das Trenner-Wissen setzt der Code je Pfad ein. So kann niemand pfadabhängiges Wissen falsch abschreiben.
- **P-1 maschinell.** Pflichtgespräche geben nur eigene Pflichtgespräch-Beobachtungen und die Behauptung eigener Lügen preis. Nebendelikte bleiben am Tisch verborgen; sonst schließt die Runde mit einem Alibi aus Runde 1 zu früh aus.
- **Eine Quelle für Wahltexte.** Sie stehen in `texte/wahlen-*.json`; `gruppenwahl.json` hält nur noch die Struktur.
- **Aufträge:**
  - Entfallen als Schreibaufträge: F3-AUTOR-31..35. Bonus-, Indiz- und Entscheidungstexte stehen schon im Kanon und werden in den KONT- und SENS-Stapeln mitgeprüft; Korrekturen macht ORCH.
  - Varianten-Regel: F3-AUTOR-36..38 (Intro), F3-AUTOR-49..50 (Texte der vier Schlüsselbeweise als Vorschlag) und F3-AUTOR-57..58 (Wahltexte der Kernrollen, je zwei Fassungen).
  - Die übrigen Zuschnitte bleiben (Dossiers in Viererblöcken, Gespräche je Runde und Block).

## E-027 · F3 Welle 1: Abnahmen und Entscheidungen (Textprüfer, Dossiers, Täterfassungen, Detektiv, Intro)
- **Abnahmen (alle FREIGEGEBEN):**

  | Bericht | Punkte | Grund für Abzug |
  |---|---|---|
  | BAUMEISTER-01 | 10 | – |
  | AUTOR-10 | 10 | – |
  | AUTOR-01 | 8 | Schweigegründe falsch zugeordnet; Cans Griff stand unter „weiß“ |
  | AUTOR-02 | 9 | Geheimnisse unter „weiß“ |
  | AUTOR-03 | 9 | Platzhalter-Fragen im Text |
  | AUTOR-04 | 9 | Platzhalter-Fragen im Text |
  | AUTOR-05 | 9 | Platzhalter-Fragen im Text |
  | AUTOR-06 bis -09 | je 10 | – |
  | AUTOR-36 | 9 | – |
  | AUTOR-37 | 10 | gewählte Fassung |
  | AUTOR-38 | 9 | – |

  Die Mängel waren klein. ORCH hat sie direkt behoben statt nachbessern zu lassen; das ist schneller, und es ist keine Nachbesserung offen.
- **Textprüfer:**
  - `textLint` bekommt `regeln` als Parameter, weil `textregeln.json` fallneutral ist.
  - Kontextausnahmen in der Form `wort:kontext` sind übernommen (Kater nur Katze, Rauch und Qualm nur mit Kamin).
  - „Turm“, „Gang“, „Zugang“, „Eingang“ und „Raum“ stehen in `raumAusnahmen`: „Toilette im Turm“ ist Kanon-Wortlaut, die übrigen sind Allgemeinwörter.
  - Der Umfang bleibt bei den Spielertexten. Figurenfelder wie `motiveAndConflict` sieht niemand am Tisch.
  - Ob „alkoholfrei“ beim ersten Nennen steht, prüft der Sensibilitätsleser.
- **Kanon:** `spur_notiz_fehlende.zeigt` ist in zwei Sätze geteilt (vorher 29 Wörter).
- **Dossiers:**
  - Schweigegründe der Kernrollen kommen aus dem eigenen Geheimnis (Ahmet: Miete; Fatma: Scham über die Schatulle; Olli: Türschaden selbst klären; Can: Streich und Zeynep).
  - Was ein Geheimnis verrät, steht unter `verbirgt`: Cans Griff, Joannas Foto, Emines Polizeidrohung.
  - Rollen ohne Geheimnis bekommen einen ehrlichen Satz aus ihrem Ziel.
  - Öffentliche Beziehungen (Geschwister, Cousins, beste Freundinnen) dürfen in `wer` stehen; Zeynep: „Can ist dein Bruder.“
  - Dossiers sprechen mit „du“ an (TON-LEITFADEN §3 ergänzt).
- **Täterfassungen:** Spuren stehen in `tatwissen`, `verbirgt` hält Lügen und Nebendelikt (SCHLUESSEL.md angepasst). Die Fasern stehen nur bei Can, denn bei den anderen sind sie eine falsche Fährte.
- **Detektiv:** 12 Schlüssel (der Auftrag nannte irrtümlich 13). „Zur Tatzeit“ statt „Scheppern“, „Mantel“ statt „Trenchcoat“; beides bleibt.
- **Intro (Varianten-Regel):** Fassung 2 ist gewählt.
  - Kriterien: vorlesbar, Grusel mit Humor, Knall wie im Kanon, nicht besetzte Rollen neutral als „ein Gast“.
  - Fassung 1 lässt den Knall weg.
  - Fassung 3 erzählt als Erinnerung, obwohl das Intro am Abend spielt, und verrät mit „eine Freundin“ das Geschlecht nicht besetzter Rollen.

## E-028 · F3 Welle 2: Gesprächsplan, partnerneutrale Gespräche, Abnahmen
- **Befund bei der Abnahme von Welle 2a:** Alle 180 Pflichtgespräche lagen vor, Tests und Textprüfer waren grün. Zwei Strukturfehler fand erst der Blick über alle Dateien:
  - **Last:** Bei 20 Rollen hätten Ahmet, Lejla und Emine in Runde 1 je 10 Gespräche gehabt, Olli in Runde 2 11, der Detektiv in Runde 3 16. V-19 erlaubt höchstens 7.
  - **Anrede:** 86 Texte sprachen einen ersetzbaren Partner mit Namen an oder schrieben ihm etwas zu („du standest am Sicherungskasten“). Springt bei kleiner Besetzung ein Ersatz ein, passt der Text nicht mehr.
  - Ursache ist der Auftrag (ORCH), nicht die Autoren: Jeder Auftrag sah nur eine Datei, und die Regel zur Anrede fehlte.
- **Denkprotokoll Last:**
  - (a) Die Last in den Texten belassen und den Ersatz zur Laufzeit regeln. Verworfen, denn bei 20 Rollen fehlt niemand, also greift kein Ersatz.
  - (b) Wunschpartner einmalig ausgleichen und am Abend einen Plan mit Lastgrenze rechnen. Gewählt.
  - Umsetzung:
    - Ein Ausgleichslauf hat 43 von 180 Wunschpartnern verschoben. Gespräche, deren Preisgabe den Partner betrifft, sind zuletzt gewandert. Bei 20 Rollen hat jetzt niemand mehr als 7 Gespräche je Runde, der Detektiv höchstens 6.
    - `Besetzung.gespraechsplan` behält jeden besetzten Wunschpartner. Für fehlende nimmt er den ersten Ersatz mit freier Last, sonst die besetzte Person mit der kleinsten Last; neue Paare gehen vor Wiederholungen.
    - `Texte.dossier` nutzt den Plan. Der Test „Gesprächsplan 4 bis 20“ prüft für jede Besetzung Höchstlast, Wunschpartner und dass niemand mit sich selbst spricht. Eine Rot-Probe gibt es auch.
- **Denkprotokoll Anrede:**
  - (a) Den Namen zur Laufzeit ersetzen. Verworfen, denn Zuschreibungen wie Beruf, Ort oder Verwandtschaft bleiben falsch.
  - (b) Die Texte partnerneutral schreiben; die App zeigt den Partner auf der Karte. Gewählt.
  - Neue Regeln in SCHLUESSEL.md:
    - P-2 partnerneutral; Kernrollen und den Detektiv darf der Text ansprechen.
    - P-3 nur eigenes Wissen.
    - P-4 Abwechslung.
  - P-2 prüft `textVerweise` maschinell. P-3 und P-4 prüfen Kontinuitätsprüfer und Sensibilitätsleser.
  - Nachbesserung: F3-AUTOR-70 bis -74, je Besetzungsband alle drei Runden.
- **Sichtbarkeit:** `thema` und `text` eines Gesprächs stehen auf der Karte, `ziel` sieht nur die eigene Rolle (SCHLUESSEL.md).
- **Erzählerbausteine Runden (AUTOR-39):** ORCH hat drei Texte neu gefasst.
  - `runde.2.start`: vorher „Nebendelikte werden von echter Gewalt getrennt“, ein Fachwort.
  - `runde.3.start`: vorher ein Satz über „gutes Spiel“, der die Regeln von außen erklärt.
  - `anklage.start`: vorher „eine von ihnen“, jetzt „eine Person“.
- **Auflösung (AUTOR-47):** Die Texte der Zeugen Emine, Azra, Damir und Marek nannten, was nur in einigen Pfaden stimmt, etwa „Fatma war im Dunkeln bei ihr“. Die Auflösung der Nebenrollen gilt aber in allen Pfaden. ORCH hat sie pfadneutral gefasst („was sie im Dunkeln über Fatma wusste“); das Genaue erzählen Finale und Rückblende.
- **Offene Fragen der Autoren:**
  - „Turm“ ist erlaubt (E-027).
  - Beträge stehen in Worten.
  - Gegenseitige Paare sind erlaubt.
  - Pawels Beobachtung darf ganz gesagt werden, sie betrifft Herrn Schneiders Geld, nicht Pawels.
- **Abgleich mit main:** Der parallele Strang hat den Stand `f5190ac` dieses Branches nach `main` gebracht (dort E49) und Fatmas Farbnamen „Weinrot“ zu „Beerenrot“ geändert. Der Merge zurück lief ohne Konflikte.
  - Sein Hinweis auf „Bordeaux mit Gold“ (Tugba) trifft zu. Die Farbe heißt jetzt „Karminrot mit Gold“, Farbcode unverändert; „Beerenrot“ und „Brombeerrot“ wären am Tisch zu leicht zu verwechseln.
  - Die Ausnahme „weinrot“ ist aus `textregeln.json` gestrichen. Neu auf der Alkoholliste stehen bordeaux, champagner, burgunder, rotwein, weißwein und portwein. Test angepasst.
  - Seine Entscheidung E48 („Herkunft ist nicht Teil der Spieldaten“) gilt für die dortigen Spieldaten. Hier zeigt kein Spielertext eine Herkunft; das Feld `herkunft` dient nur der Namensbalance. Die Frage steht unter FÜR DEN NUTZER.
- **Fundtexte (Varianten-Regel, AUTOR-49 und -50):** Fassung 1 ist gewählt.
  - Kriterien: kurz, vorlesbar, keine Verneinung, die jemanden ausschließt; derselbe harmlose Text an derselben Stelle (Griff).
  - Fassung 2 stellt jedem Fund einen Gruselmoment voran („du zuckst zusammen“, fünfmal). Das gehört in Ton und Licht der App, nicht in Fundtexte, die auch gedruckt werden.
  - Übernommen in `gegenstaende.json`, alle zwölf Spuren. Sichtbarkeit und Form stehen in SCHLUESSEL.md.
- **Wahltexte der Kernrollen (Varianten-Regel, AUTOR-57 und -58):** Grundlage ist Fassung 1, weil sie knapp und konkret ist. Fassung 2 wiederholt „Mein Gewissen …“ und „Mein Herz flüstert“ als Formel.
  - ORCH hat geschärft:
    - Die drei Freundes-Wahlen nennen jetzt, was die Rolle verrät: Ahmet Lejlas Versprechen, Fatma Emines Schweigen, Olli Wojteks Wachs-Idee. Vorher stand dort nur „was ich weiß“.
    - Vier Sabotagen lenkten auf das eigene Geheimnis (Münzbilder, Tragen durch den Turm, Schneiders Forderung) oder verrieten die Absicht („harmloser“, „Nebensächliches“). Sie sind ersetzt.
- **Welle 2b, Abnahmen:**

  | Bericht | Punkte | Grund für Abzug |
  |---|---|---|
  | AUTOR-21 bis -25 | je 8 | wie Welle 2a: Partner im Text (P-2); Nachbesserung über AUTOR-70 bis -74 |
  | AUTOR-26 bis -29 | je 9 | Ziffer im Zitat („0 Euro“) bei -28, von ORCH in Worten; sonst Prüfung in KONT-09 |
  | AUTOR-43 bis -46 | je 9 | Prüfung in KONT-04 und -05 |
  | AUTOR-49 | 10 | gewählte Fassung |
  | AUTOR-50 | 9 | – |
  | AUTOR-57 | 9 | gewählt, von ORCH geschärft |
  | AUTOR-58 | 9 | – |
  | AUTOR-65 | 9 | Tims Hemd „black checked“, Kanon sagt rot-schwarz |
  | BAUMEISTER-02 | 8 | Farbe am letzten statt am ersten Kleidungsstück („black fabric trousers in burgundy“ bei Fatma); „burgundy“ ist ein Weinname |

- **Bildprompts:**
  - Die Signaturfarbe steht jetzt am ersten Kleidungsstück. Ein Platzhalter `{farbe}` in `bild.json` setzt sie an eine bestimmte Stelle (Tim: „dark red and black checked flannel shirt“).
  - Aus „burgundy“ wurden zwei Namen: „dark berry red“ (Fatma, #6B1D2F) und „carmine red“ (Tugba, #800020). So tragen die beiden auch im Bild verschiedene Farben.
  - Die Farbtabelle bleibt eine Konstante im Code (`lib` ohne Dateizugriff). Der Test hält sie gleich mit `farbnamen.json`.
  - Die Verbotsprüfung gilt nur dem Motiv, nicht der festen Negativliste („no bar counter“, „no vape“).
  - Täterdetails (Splitter an Ollis Ärmeln, Maske in Cans Bauchtasche, Wojteks Pflaster) bleiben aus den Bildern, weil Bilder vor dem Finale sichtbar sein können.
  - Barrel-Export ergänzt; `pruefen.sh` prüft, ob `bildprompts.json` aktuell ist.
- **Anrede:** Gesprächseröffnungen und Wahltexte stehen in der Ich-Form (TON-LEITFADEN §3 angepasst). Dossiers bleiben bei „du“.
- **Offene Fragen der Autoren:**
  - Das Außentor öffnet sich mit dem Bund oder um sieben Uhr mit dem Ersatzschlüssel der Kollegin; beides ist Kanon (`z_morgen`).
  - Fatmas zwei Fassungen beim Knall (Buffet oder Theke) sind kein Widerspruch: Die eine gilt, wenn sie unschuldig ist, die andere, wenn sie die Tat begangen hat.
  - Der Gesprächsplan überspringt den Sprecher in der Ersatzkette.
  - „Box“ bleibt; das Wort ist Alltagssprache.
- **Nachbesserung der Pflichtgespräche (AUTOR-70 bis -74, je 10/10):**
  - Alle 180 Gespräche sind partnerneutral. Jede Pflichtgespräch-Beobachtung und jede Lüge kommt über die drei Runden mindestens einmal vor. Kein Text ist doppelt, kein Platzhalter steht im Text.
  - Bestätigt: Kurze Behauptungen wie „Ich hab keine Maske“ dürfen in mehreren Texten stehen (P-4 meint ganze Texte). Ahmets Umschlag und Cans Maske bleiben aus den Eröffnungen, weil sie Geheimnisse der Rolle sind (P-3). Pawel lässt „zahlt aus eigener Tasche“ weg; der Kern seiner Beobachtung bleibt.

## E-029 · F3-Prüfrunde: Entscheidungen zu F3-KONT-01..10, F3-SENS-01..05, F3-TEST-01
- **Wiederaufnahme:** Nach einem Container-Neustart kam der UNIVERSAL-PROMPT erneut. Der Nutzer hat entschieden: Schlosskeller fortsetzen. Prüfstapel A lief aus dem Zwischenspeicher weiter (KONT-01, -02, -05 schon fertig), Prüfstapel B neu.
- **KONT-01 (Dossiers):**
  - **Ahmet:** Schneiders Satz um 23:51 („Um zwölf sag ich allen, was der Keller gekostet hat“) verrät Ahmets Motiv. Er steht jetzt unter `verbirgt`.
  - **Pawel:** Seine Pflichtgespräch-Beobachtung enthielt Schneiders Geldsorgen, die er laut Ziel nicht ausplaudern will. Getrennt:
    - Am Tisch sagt er nur noch: „muss jeden Schaden der Stiftung melden, darum streng“.
    - „Zahlt kleine Schäden aus eigener Tasche“ steht unter `verbirgt`.
  - **Wojtek:** Er konnte von den zweitausend Euro nichts wissen, denn beim Streit um 23:00 war er nicht dabei. Gestrichen in `b_wojtek_tuer` und in seiner Auflösung.
    - Der wahre Hinweis `h_olli_2_wahr` nennt jetzt Schaden und Möbelwachs; beides ist durch Wojteks Beobachtung belegt.
  - Fatmas Schweigegrund nennt die Reliefs wie der Kanon.
  - Sibels `roleSecret` ohne „unter einer Kapuze“ (wie `b_selin_gesicht`).
  - Neue Regeln in SCHLUESSEL.md:
    - Schweigegründe dürfen aus `persoenlichesZiel` kommen.
    - S-1 gilt für das, was App und Erzähler zeigen. Was eine Rolle unter `weiss` kennt, darf ihre Spielerin erzählen.
  - Nicht übernommen:
    - Eigene Geheimnisse der Kernrollen unter `weiss` (Vorschlag Nr. 10). Sie gehören unter `verbirgt`.
    - Barans Box-Musik als neue Beobachtung. Sie ist ein harmloses Geheimnis ohne Spielwirkung und bleibt Text aus `roleSecret`.
- **KONT-02 (Täter, Detektiv):**
  - Ahmets Tarnung nennt die hundertfünfzig Euro wie die Lüge.
  - Sein Tatwissen endet mit dem Mietgeld in der Hosentasche (`gegenstaende.json`).
  - Detektiv in Jeans.
  - Der Ermittlungsbogen sagt „beim Scheppern“ wie R-ENTLASTET.
  - Der Folgesatz am Ende von `verbirgt` bleibt; der Auftrag hat ihn verlangt.
- **KONT-05 und Ausgang (Denkprotokoll):**
  - Befund: Finaltexte behaupten einen Bund-Fund in der Nacht (Meister) oder dass niemand ihn findet (Teilerfolg). Das Finale kennt aber nur Pfad, Ende und Punkte. Mit 7 Punkten kann die Bund-Suche falsch gewesen sein, mit 3 richtig.
  - Wege:
    - (a) Je Ende zwei Fassungen, mit Bund gefunden und ohne: 32 statt 16 Texte, und der Erzähler müsste den Verlauf kennen.
    - (b) Der Bund kommt im Finale über das Geständnis.
    - (c) Den Bund in Finaltexten nie nennen.
  - Gewählt ist (b). Bei richtiger Anklage gesteht die Täterperson und gibt den Bund heraus; das Tor geht noch in der Nacht auf. Bei falscher Anklage öffnet um sieben Uhr die Kollegin (`z_morgen`), und das Geständnis folgt später.
  - Umkehrprobe: Falsch wäre (b), wenn ein Spiel mit gefundenem Bund und falscher Anklage endet. Dann liegt der Bund schon da, und trotzdem wartet die Gruppe bis sieben. Das kann vorkommen.
    - Darum sagt die Regel bei falscher Anklage nur: „Der Bund bleibt verschwunden“ heißt, das Tor geht nicht auf, weil niemand den Bund herausgibt.
    - Texte formulieren das neutral: „Das Tor bleibt zu bis zum Morgen.“
  - Regel in SCHLUESSEL.md (Finale und Ausgang). Umsetzung mit den Befunden aus KONT-04, KONT-05 und SENS-02 in einer Nachbesserung der vier Finaldateien.
- **Prüfstapel B (KONT-06, -07, -08, SENS-03; je 10/10):** Alle 180 Gespräche sind geprüft. P-1 ist vollständig, kein Pfadwissen, kein ersetzbarer Partner beim Namen. Die Befunde sind leicht bis mittel; dazu kommt ein schweres Muster (SENS-03, siehe unten).
  - **Kanon (ORCH):**
    - Sibel sitzt beim Knall (`blackoutAlibi`), denn nur so kann sie das Gesicht sehen (`wahrnehmung.json`).
    - Die Tatnacht des Detektivs nennt beide Rufe Schneiders wie `b_detektiv_gehoert`.
    - Tugbas Notiz heißt „wo die Leute angeblich gerade sind“ statt Amtsdeutsch.
  - **Texte:** Nachbesserung F3-AUTOR-75 bis -79, je Block. Die Befunde sind wortgenau mitgegeben.
    - Abgelehnt: Pawels „zahlt selbst“ (Kanon geändert) und Tugbas Torten-Satz (kein eigenes Wissen).
    - Systemisch:
      - Runde 2 prüft Behauptungen statt die Alibi-Frage zu wiederholen.
      - In Runde 3 nur noch selten „Klarheit“.
      - Keine Verwandtschaft als Deckungsgrund im Text.
      - Detektiv-Anrede geschlechtsneutral.
  - **SENS-03, Muster (schwer), Denkprotokoll:** Ahmet, Fatma und Can tragen Geld, Mitnahme und Streich, Olli Türschaden und Vertuschung.
    - Wege:
      - (a) Nebendelikte umverteilen: Der ganze Fall hängt daran, die Tatmatrix und 36 Hinweise wären neu.
      - (b) Kernnamen tauschen: Die Einstellungen legen sie fest.
      - (c) Belassen und die Gegengewichte prüfen.
    - Gewählt ist (c):
      - Jede der vier Kernrollen hat genau ein Nebendelikt und lügt. Die Täterperson wählt der Fall-Code gleich verteilt; jede ist in einem Viertel der Abende unschuldig und in drei Vierteln eine falsche Fährte.
      - Die vier Herkünfte sind verschieden (E-007).
      - Fatmas Mitnahme ist als Ausleihen zum Abzeichnen mit Rückgabe am Montag erzählt, ohne das Wort „Diebstahl“.
      - Can bricht kein Gesetz; er spielt einen Streich.
      - Das Muster entsteht aus Namen, die der Nutzer festgelegt hat. Darum steht es mit beiden Auswegen unter FÜR DEN NUTZER. Auch Fatmas Kopftuch steht dort erneut (E-014).
  - Nicht übernommen:
    - Ein Planeintrag fehlt nicht: Pawel und Tugba haben Pläne in `basis.json`.
    - `b_tugba_notiz` führt weiter nur Ollis Lüge als widerlegt. Fatmas Platz steht erst im Notizbuch selbst (`spur_notiz_fehlende`).
- **Prüfstapel A (KONT-03, -04, -09, -10, SENS-01, -02, -04, -05, TEST-01):**
  - **Kopftuch, Denkprotokoll:** SENS-02, -04 und -05 zeigen denselben Befund: Fatma, Emine und Azra trugen das Kopftuch, und alle drei stehen im Schatulle-Strang (Fatma nimmt, Emine schweigt, Azra gab den Tipp).
    - E-014 wollte das Kopftuch auch bei Aylin. F1-SENS-01 hatte es von Aylin (kurdisch) zu Azra (bosnisch) gelegt, damit nicht zwei von drei kurdischen Figuren es tragen. Dadurch ist der Strang entstanden.
    - Wege:
      - (a) Fatma ohne Kopftuch: Das Quellmaterial gibt es ihr; E-014 hat es bewusst gelassen.
      - (b) Azras Kopftuch an eine Figur außerhalb aller Delikt-Stränge geben, nicht kurdisch.
      - (c) Azras Tipp streichen: Das nimmt Fatmas Motiv einen Anlass.
    - Gewählt ist (b): Tugba, die Geburtstags-Planerin (türkisch, leitet Projekte, unbelastet), trägt jetzt ein goldfarbenes Kopftuch. Azra bekommt den Look aus dem Quellmaterial zurück.
    - Kopftuch tragen jetzt Fatma (kurdisch, Designstudentin), Emine (türkisch, Lehrerin) und Tugba (türkisch, Planerin).
  - **Familie als Deckung (SENS-02, -05):** Die Loyalitätsgründe von Lejla und Zeynep nennen nicht mehr die Verwandtschaft, sondern das Versprechen und die Mitschuld. Verwandtschaften bleiben Fakten in `wer`.
  - **Hautton:** Can war der einzige Kernverdächtige mit dunklem Hautton und in jedem Pfad der maskierte Läufer im Dunkeln. Sein Ton ist jetzt wie Ahmets (nur Renderer).
  - **Beweisbilder (SENS-05, 12 schwere):**
    - Die Bildbeschreibungen zeigten den Fund, etwa den Bund im Helm. Ein Bild je Spur wäre in drei Pfaden falsch und im vierten ein Spoiler.
    - Jetzt zeigen sie den Ort in der harmlosen, pfadgleichen Fassung; der Fund steht nur im Fundtext.
    - Olli und Hana: `{farbe}` an der Weste beziehungsweise am Hemd. Emines Flasche heißt „thermos“, weil „flask“ an Alkohol denken lässt.
  - **Schneider:** „Freundchen“ ist aus Tatmatrix, Figur, Täterfassung und Rückblende gestrichen (TON §7: er beleidigt niemanden). Die Tatnacht des Detektivs nennt beide Rufe.
  - **Entscheidungen und Hinweise (KONT-10):**
    - Begründungstexte nennen nur, was in ihrer Kette steht. Ketten dürfen jetzt Lügen enthalten (`luege:`, Schema und `pruefeBegruendungen`).
    - Begründungen erscheinen erst in der Auflösung (SCHLUESSEL.md).
    - Hinweise spricht der Erzähler; sie gelten jetzt als Vorlesetext mit Uhrzeiten in Worten.
    - Die neutralen Hinweise in Runde 3 haben einen Satz wie die anderen.
    - Fundtexte verneinen nichts mehr: Handschuh, Laterne, Handykorb, Mietgeld, Umschlag.
    - e3_2 fragt ohne „genau“.
  - **Wahltexte (KONT-09, SENS-04):** Sabotagen lenken nicht mehr auf das eigene Geheimnis (Agentur, Stadtfeste, Musik, Ritterrüstung, Studium). Weitere Korrekturen:
    - Lejlas Kosten nennen ihr Versprechen.
    - Zeyneps Kosten nennen den Streich.
    - Aylin zitiert den Zettel wörtlich („0 Euro“).
    - Emines Schweigegrund verbindet Versprechen und Rückgabe.
  - **Auflösung (KONT-03, SENS-02):**
    - Wer etwas verborgen hat, steht jetzt so da: Pawel, Baran, Aylin.
    - Täterfassungen nennen den Bund und sein Versteck.
    - Unschuldsfassungen nennen die eigene Lüge.
    - Lange Sätze sind geteilt.
  - **Intro:** „dunkel, nur ein paar Kerzen und das Notausgangsschild leuchten“.
  - **Nicht übernommen:**
    - SENS-01 Nr. 1 bis 3: Die Fließtexte unter `verbirgt` der Kernrollen gelten nur, wenn die Rolle unschuldig ist. Im eigenen Pfad greift die Täterfassung.
    - Lehnwörter wie Box, Handy, Design und Catering bleiben (TON §4 ergänzt).
    - Emines Satz zur Polizeidrohung bleibt unter `verbirgt`, denn er schützt Fatma.
    - `runde.3.start` bleibt; die Vorratstür ist öffentlich.
    - Neutrale Hinweise in Runde 1 bleiben ohne „nicht“. Dass sie nicht helfen, ist ihr Zweck; wahr und falsch bleiben ununterscheidbar.
  - **TEST-01:** `dossier_test` (15), `erzaehler_test` (8), `spoiler_test` (10). ORCH hat Prüfung 16 geschärft: Eine Fünf-Wort-Folge gilt nur als Pfadwissen, wenn ihre Quellen zusammen nicht alle vier Pfade abdecken. Cans „auf der Toilette im Turm“ steht im Täter- und im Unschuldsprofil und ist darum frei; eine Gegenprobe sichert das. Bonus-Hinweise bleiben außerhalb von Prüfung 16, weil wahre und falsche dieselbe Form haben müssen.
- **Nachbesserung II der Gespräche (AUTOR-75 bis -79):** 133 von 180 Gesprächen geändert, Partner und Preisgaben unverändert.
  - Runde 2 prüft Behauptungen.
  - In Runde 3 nur noch selten Klarheitsformeln.
  - Kein Thema und kein Text doppelt.
  - Bestätigt: „was du vorhin gesagt hast“ darf voraussetzen, dass in Runde 1 geredet wurde.
- **Finale-Nachbesserung (AUTOR-80 bis -83):**
  - Alle 16 Finaltexte folgen der Ausgangsregel. Das Geburtstagskind heißt „du“, der Pflichtsatz steht viermal je Datei.
  - Meister-Texte begründen mit dem Wortlaut von Schlüsselbeweis und Zusatzindiz.
  - Die Rückblenden folgen der Tatmatrix: Weg, Satz Schneiders, Schlag, Spuren, Bund-Versteck, Licht um Mitternacht. Gedanken der Figuren kommen darin nicht vor.
  - ORCH hat zwei Stellen korrigiert: Ahmets Griff ist „der Griff des Kerzenständers“; in Cans Rückblende springt Can aus dem Vorratsraum, als Herr Schneider die Tür aufzieht (`ev_vorratstuer_auf`).
- **F3-Tor bestanden:**
  - `tool/pruefen.sh alles` grün:
    - Analyse ohne Befund
    - 250 Kern-Tests, davon 228 im Partymodus
    - Plausibilität, Story-Bibel, Simulator und Bildprompts aktuell
    - Server-Smoke 63 OK
    - Web-Build ohne CDN
    - Secret-Scan sauber
  - ABNAHME:
    - erfüllt: F-06, F-08, F-15
    - vorläufig: F-10 (Druckteil in F5), F-11 (E2E in F4)
  - Neubewertung der NEBELKARTE mit den neuen Risiken 21 und 22. Für F4 am höchsten: Nr. 7, 13 und 22.

## E-030 · F4-ORCH-01/02: Karte, Sitzung, Renderer-Erweiterung
- **Denkprotokoll:**
  - Der Renderer der Mordakte bleibt die einzige 2,5D-Ansicht.
  - Statt zwei kleiner Schnittstellen (`NpcFilter`, `RaumSicht` im Entwurf) gibt es eine optionale `SzenenErweiterung` (`lib/game/szenen_erweiterung.dart`). Sie liefert:
    - Ziel-Beschriftung an Personen und Hotspots
    - Licht (Grundlicht, Lichtpunkte, Taschenlampe, helle Räume)
    - Nebel des Krieges je Raum
    - Umrisse und Hervorhebung in der Rückblende
    - Ruhe-Animation
    - Aussehen des Detektivs aus dem Kanon
    - festen Kamerapunkt
  - `MordakteGame` fragt sie mit `session is SzenenErweiterung` ab. Ohne sie bleibt jeder Zweig wie bisher (Bestandsschutz).
- **Karte (Kern, `karte.dart`):**
  - Jede der 19 Optionen hat ein Kartenziel an einer Kanon-Stelle:
    - Person am Ermittlungsort
    - Gegenstand an Einrichtung oder Ort
    - Gegenstand eines Trägers an dessen Person
    - Raum an einem benannten Ort
  - Die drei Raum-Ziele von e3_1 tragen dazu jetzt `ziel.ort` (an_der_ruestung, am_jackenstaender, vor_theke); das Schema erlaubte das schon.
  - Offen sind nur die Ziele der laufenden Entscheidung (die erste offene der Runde).
  - `karte_test` belegt: Vor dem Finale ist der Kartenzustand für dieselbe Eingabe in allen vier Pfaden gleich (bestes Spiel je Pfad, erste und letzte Optionen, 4/12/20 Rollen).
- **Indizien auf der Karte:**
  - Vor dem Finale zeigt die Karte in allen Pfaden dieselben Marker (E-008 geht vor 7.13).
  - Das Indiz des aktiven Pfads erscheint als Fundkarte an der Kanon-Stelle der Handlung, mit dem Wortlaut der Spur oder Beobachtung.
  - In der Rückblende nach dem Finale sind Weg, Licht und Bund des aktiven Pfads auf der Karte zu sehen.
- **Licht (Master 7.13, B-04):**
  - Ermittlung: Grundlicht 23 % in Blaugrau.
  - Warme Punkte #FF9329 mit Sinus-Flackern auf jeder zweiten Tischreihe und jeder dritten Thekenkachel. Das sind die elektrischen Deko-Kerzen (E-019).
  - Dazu das Notausgangsschild, das nach der Tat noch brennt, und der Taschenlampenkegel des Detektivs.
  - Rückblende: Raumlicht und Deko-Kerzen nur, solange der Strom da ist. Im Stromausfall gibt es nur die Kanon-Lichter zur Uhrzeit (Kerzenständer bis 23:58:40, Notausgang, Maske, Handylampen, Stirnlampe).
- **Nebel des Krieges:**
  - Sichtbar sind der Raum des Detektivs und Räume hinter offenen Türen (`zustand: offen`). Angelehnte oder geschlossene Türen verdecken.
  - Kommt ein Raum ins Sichtfeld, blendet er radial von der Stelle des Detektivs in 0,4 s auf.
- **Sitzung (`lib/party/sitzung.dart`):**
  - Sie ist die feste API aller Bildschirme.
  - Dossier, Täterfrage und Rundenwahl gibt es nur in der verdeckten Ansicht der Rolle. Pfad, Ende und Rückblende gibt es erst nach dem Finale; sonst wirft sie `StateError`, belegt durch `test/party_widgets/ablauf_test.dart`.
  - Die Rundenwahl zeigt jeder Rolle genau zwei Möglichkeiten. Bei der Täterrolle ist B die Sabotage (G-1). So lässt sich am Bildschirm nicht ablesen, wer drei Möglichkeiten hätte.
- **Oberflächentexte:**
  - Sie stehen als Bausteine `ui.*` in `texte/ui*.json`: eine Datei für ORCH und je Baumeister eine eigene (Dateihoheit), alle im Index.
  - Der Textprüfer prüft sie wie alle Texte, aber ohne Vorleseregeln, denn ihr Bereich ist `ui`.
  - Zwei Annahmen in `textpruefer_test` sind nachgezogen: die Zahl der Dateien (46) und die Erkennung von Erzählertexten über `erzaehler-*` statt über den Namensbestandteil.
- **Entwickler-Einstieg und Probelauf:**
  - `?party=schlosskeller&pfad=…&n=…&skript=best,a,richtig&takt=…&zeitraffer=…` spielt einen Abend allein durch und meldet Fotostellen als `PARTY foto=…`.
  - Erster Probelauf (Ahmet, 7 Rollen, bestes Spiel): Meister-Ende, 9 Punkte, 57 Fotos, 0 Konsolenfehler, 0 fremde Netzaufrufe.
- **Test-Abhängigkeit:** `flutter_test` (SDK) ist als Entwicklungsabhängigkeit für die Widget-Tests der Bildschirme aufgenommen. Die Paketverwaltung hat dafür `pubspec.lock` ergänzt (Master §3: Netz nur über die Paketverwaltung).

## E-031 · F4-Bildschirmwelle, Requisiten, kleine Effekte, Druckmodell
- **Bildschirme (F4-BAUMEISTER-01 bis -06, -08, -09):**
  - Vier Haiku-Baumeister parallel, je eigene Dateien und eigene UI-Datei.
  - Abnahme 9–10/10. Abzug je einen Punkt bei Grenzen für 01, 05, 06: `git log` nur lesend benutzt, was nicht erlaubt war; ohne Folgen.
  - Prüfstand: 116 Widget-Tests grün, Analyse ohne Befund, kein sichtbarer Satz im Code (Grep), 144 neue UI-Bausteine, `party_texte` OK.
- **Entscheidungen zu den offenen Fragen:**
  - Ansprache wie TON §3: Die Gruppe heißt „ihr“, das Dossier spricht die Person mit „du“ an.
  - „Mit {name}“ wird zu „Gespräch mit: {name}“, damit es ohne eingetragenen Namen grammatisch bleibt.
  - Die Gruppenwahl-Erklärung ist sachlich richtiggestellt: Jede Runde bekommt einen Hinweis, wie viel er taugt, bleibt verborgen.
  - Die Sabotage-Beschriftung im Täterdossier lautet jetzt verständlicher: „Deine heimliche Wahl statt B“.
  - „Miete: 0 Euro.“ in einem Wahltext bleibt als Kanon-Ausnahme, denn das ist keine Stimmenzahl.
  - Das Erzählerfeld übergeht unbekannte Kennungen still. Die Vollständigkeit sichert `party_texte`/`textLuecken`, nicht das Spiel am Tisch.
  - Bestätigt:
    - Titel in 40 pt
    - Zusatzbausteine „Die Rückblende“ und „Figur: {name}“
    - Raumzeile der Fundkarte entfällt bei gleichem Namen
- **Requisiten (F4-ORCH-06):**
  - Der Partymodus zeichnet eigene Möbel (`lib/game/scene/party_props.dart`, Katalog-Typen `party_*`), auf denselben Kacheln und mit derselben Begehbarkeit wie das Kanon-Raster:
    - Tafeln und Buffets ohne Flaschen (Teekanne, Tassen, Wasserkaraffe, Brotkorb, Warmhaltebehälter)
    - Theke mit Teekocher und Kaffeemaschine
    - kalter Kamin (Kanon: seit 23:30 aus)
    - Wendeltreppe, Ritterrüstung, Jackenständer, Ascheneimer
    - der umgestoßene Kerzenständer vor der Vorratstür (Kanon: `gegenstaende.json`)
  - Elektrische Teelichter stehen genau an den warmen Lichtpunkten der Karte.
  - Die Mordakte-Vorlage bleibt unverändert (nur neue Katalog-Einträge).
- **Kleine Effekte (F4-ORCH-05, Master 7.13):**
  - Seifenblasen aus der Pfeife, wenn das Geburtstagskind kurz stillsteht.
  - An der Rüstung rieselt Staub und das Visier blitzt.
  - Aus dem kalten Kamin pufft eine Rußwolke.
  - Höchstens alle 10 s je Stück, nur über `SzenenErweiterung.kleineEffekte`.
  - Täter für Testläufe: über den Entwickler-Einstieg `pfad=`. Die Spielleitung bekommt im Druck je Pfad einen Fall-Code (F5).
- **Sichtprüfung vorbereitet:**
  - `bis=<phase>`, `at=x,y`, `zoom`, `fotopause` im Entwickler-Einstieg.
  - `tool/e2e/raeume.mjs` fotografiert alle Räume (8 Fotos, 0 Fehler, dem Nutzer gezeigt).
- **Druckmodell (F5-ORCH-01, vorgezogen im eigenen Arbeitsbaum):**
  - `DruckSatz` enthält Spielleitungsheft, Detektivbogen mit Ermittlungsbogen, Rollenhefte, vier gleich gebaute Fassungen, Indizkarten mit Kreuzen, Stimmkarten (A = 1, B = 0, Sabotage = −1), neun Hinweis-Umschläge mit Auszähltabelle für genau diese Personenzahl und das Auflösungsheft mit Endentabelle.
  - Codes: zwei Buchstaben und eine Ziffer, eindeutig, ohne Bezug zu Art oder Pfad.
  - `druck_modell_test`: 100 Zufallsspiele ergeben dieselbe Optionsreihenfolge, dieselben Funde, dieselbe Restmenge je Runde, dieselbe Hinweisqualität, dieselben Punkte und dasselbe Ende wie `Spiel`.
  - Korrektur: Es sind 19 Optionen, nicht 22 (E-030 berichtigt).

## E-032 · Probelauf mit echten Bildschirmen: Du-Form im Dossier, Rückblende nach Uhr
- **Probelauf:** Olli, 12 Rollen, bestes Spiel, Gruppe gemischt, richtige Anklage. Ergebnis: Meister-Ende, 9 Punkte, 57 Fotos, 0 Konsolenfehler, 0 fremde Netzaufrufe. Die Übersicht ging an den Nutzer.
- **Befund Dossier:**
  - 23 von 31 Beobachtungen, die Dossiers zitieren, sprachen die eigene Rolle in der dritten Person an („roch sie“, „neben ihm“). Die F3-Prüfer hatten das nicht gemeldet.
  - Lösung im Kanon: Feld `duText` (Schema ergänzt). Das Dossier zeigt die Du-Fassung; Fundkarten, Bibel und Erzähler behalten `text`.
  - Absicherung:
    - `dossier_test`: Beobachtungen der eigenen Rolle stehen in der Du-Form, mit Rot-Probe.
    - Der Textprüfer prüft `duText` mit.
    - `spoiler_test` zählt pfadabhängige Du-Fassungen als Pfadwissen.
- **Befund Rückblende:**
  - Unter Last (Software-Rendering, parallele Prüfläufe) fielen Ticks aus. Nach zehn Sekunden stand die Uhr erst bei 23:55:44.
  - Der Zeitraffer folgt jetzt der echten Zeit (Stoppuhr).
  - Die Rückblende zeigt keinen Joystick und keinen Aktionsknopf mehr (`GameView(steuerung: false)`, Vorgabe bleibt `true`, Bestandsschutz).

## E-033 · F5-Drucksatz (vorgezogen parallel zum F4-E2E)
- **Denkprotokoll:**
  - Das E2E-Gerüst belegte nur einen Haiku-Platz. Das Druckmodell war fertig und getestet (E-031).
  - Die drei Druckteile liefen deshalb parallel. Das F4-Tor bleibt Voraussetzung für das F5-Tor.
- **Gerüst (ORCH):**
  - `satz_stil.dart`: A4, Inter und Special Elite, mindestens 9 pt, Höhenmessung, `passendeGroesse` wirft bei Überlauf.
  - `satz.dart` mit `DruckKontext` und acht Dateien mit neutralen Namen.
  - CLI `party_druck`.
  - Testhilfe mit `pdfinfo` und `pdftotext`, damit A4, Seitenzahlen und Wortlaut echt geprüft werden.
- **Baumeister F5-01 bis -03:**
  - Abnahme 10, 9 und 10 von 10.
  - 37 Drucktests, Rot-Proben belegt.
  - Sichtprobe der Seiten als PNG, dem Nutzer gezeigt.
- **Entscheidungen:**
  - **Kernrollen-Hefte gleich (Spoiler):** Das Rollenheft der Täterrolle zeigte das Täterziel. Bei Kernrollen steht „Mein Ziel“ jetzt in der versiegelten Fassung. Die vier Kernhefte unterscheiden sich nur in Name, Gesprächen und Code. Test ergänzt.
  - **Stimmkarten:**
    - Name und Text stehen vorn, der Wert auf der gefalteten Seite.
    - Die Spielleitung zählt die Wertseiten, ohne die Karten umzudrehen; der Hinweis steht im Heft.
    - Die Sabotage bleibt anonym. Eine Spielleitung, die die Karten umdreht, sähe den Namen; das ist eine Frage der Fairness am Tisch (FÜR DEN NUTZER).
  - **Faktarten aus einer Quelle:** Bogen und Indizkarten nutzen beide `ui.druck.bogen.typ.*`, vorher „Spät dran“ gegen „Späte Ankunft“.
  - **Code-Bedeutungen im Modell sind technische Kennungen** (`indizkarte:e:o`, `umschlag:r:q`, `fassung:rolle[:taeter]`). Den Text setzt das Auflösungsheft aus Bausteinen (F-11).
  - **Dokumenttitel aus Bausteinen** (`ui.druck.datei.*`). Kopf und Fuß auf 9 pt.
  - **Probe entfernt:** Die F1-Probeseite (`druck/probe.dart`, `bin/party_druck_probe.dart`) ist durch den Satz ersetzt.
- **F6-TEST-01 vorgezogen:**
  - `story_text_ausserhalb_test`: In `lib/party` und `druck/` steht kein Spielertext im Code. Technische Zeilen sind ausgenommen (Fehler, Messdokumente, `wo:`). Rot-Probe belegt.
  - Stand: 318 Kern-Tests grün.

## E-034 · E2E-Gerüst abgenommen, Druckfassung in der App (F4-BAUMEISTER-07, F5-BAUMEISTER-04)
- **Denkprotokoll:**
  - Das Gerüst (`tool/e2e/e2e.mjs`, `laeufe.mjs`) fährt 80 Läufe (4 Pfade × 4 Enden × 5 Personenzahlen) und 4 Semantik-Läufe. Es prüft Ende, Pfad, Rollen, Phasenfolge, Fotostellen, Konsole, fremde Anfragen und vor dem Finale die Spoilerfreiheit des Bildschirmtexts. Ein Negativtest belegt, dass ein falsches Ende auffällt.
  - Abnahme 9 von 10. Abzug bei Grenzen: Der Chromium-Pfad ist fest verdrahtet wie in `probe.mjs`. In diesem Container ist das richtig, anderswo hilft `PLAYWRIGHT_BROWSERS_PATH` (README).
- **Entscheidungen:**
  - **Takt 400 für Semantik-Läufe bestätigt.** Bei 40 ms war der neue Bildschirm beim Auslesen noch nicht gezeichnet. Die Prüfung soll den gezeichneten Bildschirm lesen, nicht die Geschwindigkeit messen. Die 80 Läufe ohne Fotos bleiben bei 40 ms.
  - **„Nur für dich“ als Teilstring** prüft beide Marken (Rollen-Bildschirm und Druck). Das ist strenger als ein einzelner Baustein, deshalb bleibt es so.
  - **Web-Fassung für Prüfläufe aus einem sauberen Worktree auf HEAD.** Testagenten setzen Rot-Proben in den Arbeitsbaum. Ein Build aus dem Arbeitsbaum könnte eine Mutation mitnehmen.
  - **Druckfassung in der App (ORCH):**
    - Bei eingestelltem Druck zeigt die Rollenvergabe eine Tafel.
    - Sie erzeugt den Satz für Fall-Code und Personenzahl im Gerät, die Schriften kommen aus den Assets.
    - Die acht Dateien werden einzeln angeboten, per Blob-Link über `dart:js_interop`, ohne neue Abhängigkeit und ohne Server.
    - Ohne Browser erscheint ein Hinweis.
    - Eigene Bibliothek `party_druck.dart`, damit `mordakte_core.dart` (Server, Spiel) ohne `pdf` bleibt.
    - Widget-Test: 3 Fälle.
    - `story_text_ausserhalb_test` behandelt Dateinamen wie `Inter-Bold.ttf` als technisch.

## E-035 · Druck ohne Spoiler für den Drucker, Gästewissen über den Erzähler (F5-Prüfung)
- **Anlass:** Zwei Druckprüfer fanden unabhängig dasselbe Kernproblem: Wer den Satz druckt, kann den Täter ablesen.
  - Auf der Stimmkarte stand „Wert: −1“, und zwar nur bei der Täterrolle.
  - Die Täterfassung hatte als einzige eine gerahmte Überschrift „Nur für dich: Du warst es“ und keine Notizseite.
  - Der Ablauf rief die Fassungen nie auf.
  - Die Zählanleitung widersprach sich.
  - Der Besetzungstest (F5-TEST-01) fand dazu sechs Begründungsquellen, die bei kleiner Besetzung niemanden erreichen. Das verletzt F-09.
- **Denkprotokoll:**
  - Master 7.14 verlangt: „Wer druckt, sieht nur neutrale Codes. Die Zuordnung steht im Auflösungsheft.“
  - Vollständig verbergen lässt sich Inhalt beim Drucken nicht: Wer Karten ausschneidet, hält die Innenseite in der Hand.
  - Erreichbar sind drei Dinge:
    - Alles, was zum Sortieren und Verteilen gebraucht wird, trägt nur Codes.
    - Keine Seite verrät sich auf einen Blick, weder durch Zahl, Rahmen, Überschrift noch fehlende Seiten.
    - Die Anleitung sagt ausdrücklich: einseitig drucken, nichts lesen.
  - Duplexdruck habe ich verworfen. Er braucht passende Drucker und spiegelgenaue Rückseiten, und ein falsch eingestellter Drucker legt Lösung und Code auf ein Blatt. Die Faltkarten funktionieren mit jedem Drucker.
- **Entscheidungen Druck:**
  - **Stimmkarten mit Wertcodes:**
    - Unten trägt jede Karte einen Abreißstreifen mit einem neutralen Code. Wert und Namensfeld stehen nicht mehr darauf.
    - In die Schüssel kommt nur der Streifen. Die Spielleitung zählt über die Codetabelle der Runde im Spielleitungsheft: alphabetisch, vier Paare je Zeile.
    - Den Bezug Code → Rolle gibt es nur auf den Karten selbst. Die Wertcodes stehen nicht in der Codeliste des Auflösungshefts.
    - Restrisiko: Die Spielleitung erfährt beim Zählen, dass sabotiert wurde, aber nicht von wem. Wie bisher steht das unter FÜR DEN NUTZER.
  - **Fassungen:**
    - Außen stehen nur Code und „Versiegelt. Erst öffnen, wenn die Spielleitung diesen Code nennt.“, ohne Namen.
    - Innen ist der Aufbau gleich. Der Täterteil heißt „Was nur du weißt“ und ist ohne Rahmen gesetzt, nach dem Ziel.
    - Jede Fassung endet mit mindestens einer Notizseite. Alle vier sind gleich lang.
    - Der Ablauf hat einen neuen ersten Schritt „Rollen und Fassungen“: Die Spielleitung nennt die vier Codes alphabetisch, die Kernrollen finden ihren Code im Rollenheft.
  - **Vorbereitung:**
    - „Einseitig drucken, nichts lesen“.
    - Faltanleitung für Indizkarten, Umschläge, Fassungen und Auflösungsheft.
    - Die Stimmkarten kommen zu den Rollenheften.
  - **Gruppenwahl eindeutig:** Streifen abreißen, falten, in die Schüssel. Die Spielleitung zieht die Streifen einzeln, schlägt die Codes nach und zählt still.
  - **Pflichtgespräche:** Der Plan ist mit Absicht nicht gegenseitig (Befund DRUCK-01 #4). Jede Rolle eröffnet ihre drei Gespräche, wer angesprochen wird, antwortet. Das steht jetzt im Heft.
  - **Wortlaut und Sprache:**
    - „{n} Rollen und das Geburtstagskind“ statt „{n} Personen am Tisch“.
    - Die Ausschlussregeln kommen im Bogen aus dem Spielertext (`ermittlungsbogen.entlastet` und `.ueberfuehrt`, F-10), dazu angeglichen in `entscheidungen.json`.
    - „Diesen Bogen siehst nur du.“ statt des Grammatikfehlers.
    - Die Sabotage-Zeile der Täterfassung erklärt die Wirkung.
  - **Satz:**
    - Indizkarten-Außenseite mit Innenrand.
    - Marken und Rollennamen bleiben mit ihrem Text zusammen (`pw.Inseparable`). Keine Überschrift steht mehr allein am Seitenende.
  - **Kein Befund:**
    - „Späte Ankunft“ im Bogen: Die Fakten entstehen in anderen Pfaden, der Bogen bleibt pfadgleich.
    - Lejla bei 4 Rollen: Sie ist Gast ohne Spieler, wie jede unbesetzte Figur.
    - Lacher-Figuren: Die Kennungen `selin` und `meryem` tragen seit E-007 die Namen Sibel und Hana.
    - Dateinamen: Der Entwurf wird nachgeführt.
  - **Offen als Feinschliff:** Bei Joanna steht die Rundenwahl der Runde 3 allein auf einer Seite.
- **Entscheidung Gästewissen (W1, F-09):**
  - Die sechs Beobachtungen gelten in allen Pfaden gleich (`pfade: alle`, auch Lejlas `b_lejla_ahmet_theke`). Der Erzähler darf sie also sprechen, ohne den Pfad zu verraten. Es sind fünf Bausteine, weil Wojtek zwei Beobachtungen trägt (Zählung berichtigt in E-039).
  - `Erzaehler.npcWissen` wählt für jede Runde die Pflichtgespräch-Beobachtungen, die eine Begründungskette eines beliebigen Pfads zuerst in dieser Runde braucht und die keine Indizkarte liefert, weil die Figur kein Ziel einer Option ist.
  - Gesprochen wird zum Rundenstart, nur bei unbesetzter Figur, ohne Namen wie die Lacher im Intro.
  - Ergebnis: fünf Bausteine `npc.<figur>.<runde>` in `texte/erzaehler-npc.json`:
    - Runde 2: Lejla, Marek, Hana
    - Runde 3: Wojtek, Sibel
  - Sie gelten in App und Spielleitungsheft.
  - Der Besetzungstest erkennt den Erzählerweg. Ein neuer Erzählertest prüft „nur bei unbesetzter Figur, gleich in allen Pfaden“.
- **Belege:**
  - 371 Kern-Tests und 129 Widget-Tests grün.
  - Texte 0 Befunde (1567).
  - Simulator, Plausibilität und Story-Bibel OK.
  - Sichtprobe der neuen Seiten dem Nutzer gezeigt.

## E-036 · Sabotage-Streifen in der Fassung, vier gleiche Fassungsseiten (Nachprüfung F5-DRUCK-03/04)
- **Anlass:** Beide Nachprüfer fanden den Täter weiter in offenen Teilen.
  - (a) Die offene Stimmkarte nennt die Rolle und trägt einen Code. Die Codetabelle im Spielleitungsheft gibt genau diesem Code −1. Wer beides hat, kennt den Täter.
  - (b) Die Täterfassung fällt durch eigene Überschriften („Was nur du weißt“, „Das erzählst du den anderen“) und eine andere Seitenaufteilung auf (zwei Inhaltsseiten, eine Notizseite).
  - E-035 hatte das zu optimistisch beschrieben.
- **Denkprotokoll:**
  - (a) ist kein Lese-, sondern ein Zuordnungsproblem: Rolle und −1 dürfen in keinem offenen Teil verknüpfbar sein.
  - Die Sabotage gehört deshalb dorthin, wo die Täterrolle ohnehin allein liest: in die versiegelte Fassung.
  - Damit niemand am Tisch etwas bemerkt, tun alle vier Kernrollen dasselbe: Bei B geben sie den Streifen aus ihrer Fassung ab. Bei den Unschuldigen zählt er 0, beim Täter −1.
  - (b) lässt sich über gleichen Aufbau lösen: dieselben Überschriften, dieselben vier Seiten, eine gemeinsame Schriftgröße.
  - Die Textmenge der Inhaltsseite bleibt verschieden. Das sieht nur, wer die vier Innenseiten nebeneinanderlegt und liest.
- **Entscheidungen:**
  - **Offene Stimmkarten:** Für alle Rollen gilt A = +1, B = 0. Der Text von B ist ohne Sabotage und bei allen gleich. Kein offenes Blatt trägt eine −1.
  - **Fassung:** Jede Fassung hat vier Seiten.
    - (1) Außenseite: Code und Hinweis im oberen Viertel. Beim Knick in der Mitte bleibt der Code vorn.
    - (2) Inhalt: Mein Ziel, Was ich weiß, Was ich verberge. Bei der Täterrolle stehen dort ohne eigene Überschrift „Du warst es …“, die Tat, die Tarnung und der Hinweis auf die heimliche Wahl.
    - (3) Meine Rundenwahl: dieselbe Anleitung für alle, A und B je Runde, unten drei B-Streifen zum Abreißen.
    - (4) Notizen.
    - Eine Schriftgröße für alle vier. Passt die längste nicht auf die Seite, ist das ein Fehler (`passendeGroesse`).
  - **Codetabelle je Runde:** Karten-Codes plus die vier Fassungs-Streifen. Genau ein Streifen zählt −1.
  - **Codes ohne doppeltes Buchstabenpaar**, damit MN4 und MN7 nie im selben Satz stehen.
  - **Faltanleitung:**
    - Blätter mit der Schrift nach oben stapeln, das Blatt mit dem Code obenauf.
    - In der Mitte nach hinten knicken und zukleben. Die Schrift liegt dann innen, der Code vorn.
    - Gilt für Fassungen und Auflösungsheft; dessen Deckblatt ist nach oben gerückt.
  - **Weitere Satzkorrekturen:**
    - Die Resümee-Fächer bleiben je auf einer Seite (`pw.Inseparable`).
    - Die Codeliste steht in Blöcken zu 16 mit eigener Kopfzeile. Der Hinweis nennt Indizkarten, Hinweis-Umschläge und Fassungen.
    - Der Ermittlungsbogen druckt `ermittlungsbogen.restverdaechtige` und die vier Namen zum Durchstreichen.
    - „Jede Rolle wählt …, jede Rolle gibt genau einen Streifen ab“.
    - „Sortiere nur nach Nummern, Codes und Rollennamen“.
  - **Du-Form im Dossier:**
    - Nebendelikte bekommen `duText` („Du hast die Münzschatulle … mitgenommen.“), Lügen bekommen `duWahrheit` („Du wolltest …“). Schema und Textquellen sind ergänzt.
    - Neuer Test: Lügen und Heimlichtuereien stehen im eigenen Dossier in der Du-Form.
    - Das wirkt in App und Druck gleich (F-10).
  - **Restrisiko, dokumentiert (Befund DRUCK-04 #3):**
    - Indizkarten und Hinweis-Umschläge tragen die Innenseite auf demselben Blatt. Nach dem Falten liegt sie hinten.
    - Wer beim Ausschneiden liest, sieht Funde. Ohne Duplexdruck gibt es keine sichere technische Lösung; Duplex hat E-035 verworfen.
    - Die Anleitung sagt „einseitig drucken, nichts lesen, nur nach Codes sortieren“.
  - **Präzisierung zu E-035:**
    - „Ohne Namen“ meint: Der Gast, den niemand spielt, wird nicht genannt. Andere Figuren im zitierten Satz schon.
    - Der Toiletten-Lacher mit Olli gilt in allen Pfaden gleich und ist kein Spoiler.
    - Zwei Gespräche einer Rolle mit dem Geburtstagskind in einer Runde sind Ersatzpartner-Regel, kein Fehler.
    - Gestrichelte Randlinien an der Blattkante sind Zierde. Alle Texte haben Innenrand.
- **Belege:**
  - 372 Kern-Tests und 129 Widget-Tests grün.
  - Texte 0 Befunde (1581).
  - Story-Bibel aktuell.
  - Sichtprobe der 16 Fassungsseiten dem Nutzer gezeigt.

## E-037 · Spiel- und Sichtprüfung der E2E-Fotos (F4-SPIEL-01/02, F4-SICHT-01/02)
- **Grundlage:** zweite E2E-Matrix 84/84 auf `eacf0b4`, 16 Abende mit Fotos und 8 Raumfotos.
- **Abnahme:** SPIEL-01 9/10, SPIEL-02 10/10, SICHT-01 10/10, SICHT-02 9/10.
- **Echte Befunde, behoben:**
  - **Rückblende markiert scheinbar die falsche Figur (SICHT-01 #1).**
    - Ursache: Im Ahmet-Pfad stehen um 23:54:25 Ahmet und Johanna auf demselben Fleck (24,5/12,5), ebenso Detektiv und Hakan. Johanna wird über Ahmet gezeichnet.
    - Lösung: `PartyKartenSession` rückt Figuren auf demselben Fleck um 0,42 Felder auseinander. Die hervorgehobene Figur bleibt stehen.
  - **Uhr der Rückblende:** immer mit Sekunden (`Uhrzeit.mitSekunden`), nicht nur bei vollen Minuten ohne.
  - **Platzhalter beim Einrichten:** „Name (optional)“ statt des abgeschnittenen „Name am Tisch (optional)“.
  - **Text unter der Fußleiste:** `RollFlaeche` im gemeinsamen Rahmen zeigt eine Scrollleiste und unten Verlauf mit Pfeil, solange noch etwas folgt. Der Rückblende-Kasten im Finale hat 45 % statt 55 % der Höhe.
  - **Fundkarte unter der nächsten Entscheidung:** Bei offener Fundkarte zeigt der Kopf deren Entscheidung.
  - **Rundenkopf ohne Designsatz:** Der Kern-Satz aus `fall.json` stand als Untertitel auf dem Bildschirm. Er doppelte den Erzähler und verriet in Runde 3 Mechanik („zwei Restverdächtige“). Entfernt.
  - **Knöpfe im Kartenkopf:** mit Rahmen und Symbol; „Aus einer Liste wählen“ statt „Ohne Karte wählen“.
  - **Farbpunkt:** heller Rand, damit dunkle Farbcodes wie Ahmets (#1A1A1A) sichtbar sind.
  - **Rollenliste:** kein doppelter Name, wenn kein Spielername eingetragen ist.
  - **Ende-Bildschirm:** Knopf „Zurück ins Hauptmenü“.
  - **Texte:**
    - „Herr Schneider hat nur eine Beule.“ statt „geht es gut“, passend zu den Finaltexten.
    - Einheitlich „Schauvitrine“ statt „Turmvitrine“ (11 Stellen, Kanonname „Schauvitrine im Turmgang“).
  - **Figurenfarben (B4, F-13):**
    - Tugbas Jackett ist jetzt Rostorange (#D2691E) statt Karminrot (#800020). Zu Fatmas Beerenrot lag es nur bei ΔE 7,4, und beide tragen Kopftuch. Neu hat es mindestens ΔE 26,4 zu allen Figuren.
    - Fatmas Kopftuch ist jetzt Taubengrau (#9A8C98) statt fast schwarz. Es wirkte im Dunkeln wie Haar.
    - Dossiers, Figurendaten, Bilddaten, Farbtabelle der Prompts, Bildprompts und Story-Bibel sind nachgezogen.
  - **E2E-Fotos:** Fotopause 2 s und Zeitlimit 8 min in Fotoläufen. Zwei Fotos (SPIEL-01 #6, SICHT-02 #7) zeigten unter Last schon den nächsten Bildschirm.
- **Kein Befund, mit Begründung:**
  - **Bonus-Hinweise mit Namen (SICHT-02 #1, #2):**
    - Das ist die dokumentierte Ausnahme S-1/E-025: Der Hinweis kommt wahr, neutral oder als Gerücht im selben Rahmen.
    - Ein falscher Hinweis belastet Unschuldige (SPIEL-02 Frage 2). Ein Name verrät also nichts.
  - **Gästewissen „Acht Minuten vor zwölf sagte Olli …“ (SICHT-02 #3, SPIEL-02 #1):** Die Beobachtung gilt in allen Pfaden. Ist Wojtek besetzt, erzählt er sie im Gespräch ebenso. Der Bildschirm ist in allen Pfaden gleich (E-035, `erzaehler_test`).
  - **„Eine Person übrig“ nach Runde 3 (SPIEL-01 #1, SPIEL-02 #2):**
    - Das ist der eigene Schluss des Detektivs aus den gezogenen Indizkarten (Schlüsselbeweis plus Fundort, Regel R-UEBERFUEHRT), ohne Namen (S-1).
    - Bei gutem Spiel ist der Fall damit gelöst; das ist das Ziel.
    - Der widersprechende Designsatz ist vom Bildschirm genommen.
  - **Schneider in Rückblende 2 und 3 nicht im Bild (SICHT-01 #2):**
    - Die Kamera folgt dem Täter. Schneider trägt seinen Ring, sobald er im Bild ist; zur Tatzeit sind beide im Bild.
    - B9 lese ich so: hervorgehoben, wo sichtbar. Ein Zoom auf beide wäre bei getrennten Räumen zu klein.
  - **Gelblicher Punkt an den Getränkekisten (SICHT-01 Frage 2):** Die Kiste wird ohne Flaschen gezeichnet (`_crate`). Der Punkt ist eine erlaubte Lichtquelle.
  - **Zwei Gespräche mit dem Geburtstagskind in einer Runde:** Ersatzpartner-Regel.
- **Bekannte Restliste Farbabstand:**
  - Unter ΔE 10 liegen über Raumgrenzen hinweg: Meryem/Serkan 5,2, Olli/Serkan 7,7, Ahmet/Baran 7,9, Murat/Hakan 8,2, Olli/Meryem 8,8, Serkan/Kaan 9,4.
  - Im selben Startraum bleibt F-13 erfüllt (≥ 10).
  - Die Paare unterscheiden sich durch Silhouette, Kopf und Haar. Die Sichtprüfer haben sie nicht gemeldet. Steht unter FÜR DEN NUTZER.

## E-038 · Nachprüfung der Fotos nach E-037 (F4-SPIEL-03, F4-SICHT-03)
- **Grundlage:** dritte E2E-Matrix 84/84 auf `17173e2` (Beleg `belege/E2E-17173e2.md`). Abnahme SPIEL-03 10/10, SICHT-03 10/10.
- **E-037 hält im Bild:**
  - Ring auf der Täterfigur, keine Überdeckung, Uhr hh:mm:ss.
  - Platzhalter vollständig.
  - Fundkarte unter ihrer Entscheidung.
  - Rundenkopf ohne Designsatz.
  - Knöpfe mit Rahmen, Farbpunkte mit Rand, Rollenliste ohne Doppelnamen.
  - Ende mit „Zurück ins Hauptmenü“.
  - Tugba rostorange, Fatmas Kopftuch erkennbar.
- **Behoben:**
  - **Verb am Aktionsknopf:**
    - Problem: Bei Personen-Zielen stand „Befragen“, obwohl die Option „Olli und seine Weste untersuchen“ oder „Fatmas Hände und ihren Ring untersuchen“ lautet.
    - Lösung: `KartenZiel.aktion` leitet die Handlung aus dem Verb am Ende des Optionstexts ab (`aktionAus`): befragen/fragen → Befragen, untersuchen/durchsuchen → Untersuchen, suchen → Absuchen.
    - Wird eine Person untersucht, zeigt der Knopf die Lupe (`SzenenErweiterung.npcUntersuchen`). Das Namensschild bleibt über dem Kopf (`ActionTarget.figur`).
    - Test in `karte_test`.
  - **Rundenuhr in Runde 3:** Sie rutschte durch das Gästewissen unter die Fußleiste. Die Uhr steht jetzt oben in der Rundenzentrale, der Erzähler darunter.
  - **Rückblende:** Uhrzeit und Wiederholen-Knopf stehen über dem Bild statt darauf. Sie verdeckten Herrn Schneider samt Ring (SICHT-03 #1, #2).
  - **Scroll-Hinweis:** Ein kleines Abzeichen mit Pfeil rechts außen und ein flacher Verlauf ersetzen den Pfeil, der über der letzten Textzeile lag.
- **Kein Befund, mit Begründung:**
  - **„Acht Minuten vor zwölf sagte Olli …“ (SPIEL-03 #1, „neuer Grund“: steht auch im Täterwissen Ollis):**
    - Die Beobachtung `b_wojtek_olli_satz` ist im Kanon `art: pfadneutral`, `pfade: alle`, und der Satz steht in der gemeinsamen Zeitleiste (`zeitleiste.json`).
    - Olli sagt ihn in jedem Pfad. Die Täterfassung zitiert ihn nur als Ausgangslage.
    - Der Bildschirm ist in allen Pfaden gleich (`erzaehler_test`).
  - **Kopftücher von Emine und Tugba im dunklen Buffetsaal (SICHT-03 #3):**
    - Master 7.13 verlangt 23 % Grundlicht. Abseits von Kerzen und Taschenlampe zeigen Figuren dort Umriss und Helligkeit, keine Farben.
    - Im Licht sind die Kopftücher klar erkennbar, etwa Emine im Durchgang mit Y ≈ 103–144.
    - Die Helligkeit ist unter FÜR DEN NUTZER als Stellschraube vermerkt.
  - **Zwei Vorhängeschlösser im Windfang (SICHT-03 #5):** Das sind die zwei Flügel des verschlossenen Außentors, laut Kanon zwei Kacheln, „verschlossen ab 18:50“.
  - **Weitere:**
    - Joystick über einer Figur im Raumfoto (SICHT-03 #6): Das Bedienfeld gehört zum Spiel.
    - Schild unter der Entscheidungskarte (SPIEL-03 #6): situativ, die Kamera folgt dem Detektiv.
    - Verschobene Fotostelle (SPIEL-03 #7): Fotozeitpunkt des Gerüsts unter Last, kein Spielfehler.
    - `fall.json` Kern Runde 3 „zwei Restverdächtige“: Er beschreibt den Stand zu Beginn der Runde und wird nicht mehr angezeigt (E-037).

## E-039 · F6-Härtung: Gegenprüfung und Spieltests (F6-GEGEN-01..03, F6-SPIEL-01/02)
- **Abnahmen** (je fünf Prüfungen zu 0–2 Punkten; Gegenprobe je schwerem und mittlerem Befund, die ihn zu widerlegen versucht):
  - `F6-GEGEN-01` (Logik, Abkürzungen): FREIGEGEBEN · 9/10. Drei schwere Befunde mit Zahlen aus eigenen Skripten; eine Grenzüberschreitung (`git log` statt nur `git status`) kostet einen Punkt.
  - `F6-GEGEN-02` (Spoiler): FREIGEGEBEN · 9/10. Stimmzuordnung im Druck gefunden; zwei Befunde von der Gegenprobe widerlegt.
  - `F6-GEGEN-03` (Ton, Inhaltsregeln): FREIGEGEBEN · 9/10. Familie als Deckungsgrund und Ausgang am Morgen gefunden; ebenfalls `git log` gelesen.
  - `F6-SPIEL-01` (zwei schwache App-Abende): FREIGEGEBEN · 10/10.
  - `F6-SPIEL-02` (Papier-Abend, Fall KLRVK, 9 Rollen): FREIGEGEBEN · 9/10. Zwei Befunde beruhen auf einer Fehllesung von E-036.
- **Denkprotokoll Pfad Can (GEGEN-01 Nr. 1 bis 3, 8):**
  - **Befund:** Im Pfad Can hatte Ahmet Damirs Alibi. Nach Runde 1 hatten also Ahmet, Fatma und Olli ein Alibi und nur Can keins. Der Erzähler sagte „Noch keine Spur“ nur in diesem Pfad. Ahmet schied über sein Nebendelikt aus: in Runde 2 über die falsche Option Ascheneimer, in Runde 3 über Aylins Beleg. So blieb Can in 12 Folgen schon nach Runde 2 allein übrig, in 9 Folgen ohne Schlüsselbeweis.
  - **Wege:**
    - (a) Damirs Aussage im Pfad Can ohne Alibi und ohne Spätankunft. Dann fehlt Damirs Fund im Pfad Can, und die Lücke verrät den Pfad.
    - (b) Ahmet verlässt auch im Pfad Can kurz vor dem Scheppern Damir, aus einem eigenen, harmlosen Grund.
    - (c) Can bekommt einen Trenner in Runde 1. Das ergäbe vier Trenner für drei Entscheidungen und einen Umbau von Runde 1.
  - **Gewählt: (b).** Ahmet steht im Pfad Can kurz vor dem Scheppern auf und versteckt den Umschlag in seiner Jacke im Ost-Saal. Danach kommt er mit „Damir, ich bin's wieder.“ zurück und holt den Umschlag kurz nach zwölf wieder heraus (`tatmatrix/can.json`).
    - Damirs Satz `b_damir_ahmet_weg` gilt jetzt in den Pfaden Ahmet und Can.
    - Ahmets eigenes Wissen steht in zwei verborgenen Beobachtungen: `b_ahmet_haelt` (Fatma, Olli) und `b_ahmet_jacke` (Can, `eigenwissen`).
    - Die Auflösung erzählt es mit `aufloesung.ahmet.unschuldig.can`.
  - **Folgen:**
    - In jedem Pfad zeigt Runde 1 genau eine Spätankunft und zwei Alibis, und Can bleibt unbefragt. Es bleiben also stets zwei ohne Alibi, und der Erzähler sagt überall „Es gibt erste Spuren“.
    - Ahmet kann im Pfad Can nicht mehr über R-ENTLASTET ausscheiden. Allein bleibt jede Täterperson nur über R-UEBERFUEHRT.
    - Die Ausnahme aus E-024, Nachtrag (`gegenTaeter`), entfällt.
    - Gästebeweise im Pfad Can sind unverändert. Ahmets Gang geschieht im Dunkeln und ungesehen; nur Damir als sein Trenner-Zeuge weiß davon.
  - **Wissensgrenze:** Der Plausibilitätsprüfer erlaubt pfadabhängiges Wissen jetzt auch der Person, die ein erklärtes eigenes Pfadverhalten hat (`eigenwissen`). Für alle anderen gilt die Regel weiter; eine Rot-Probe ohne `eigenwissen` wird gemeldet.
  - **Simulator, neue Prüfungen:**
    - Keine Folge lässt vor Runde 3 nur eine Person übrig.
    - Allein übrig bleibt die Täterperson nur mit Schlüsselbeweis und Fundort.
    - Nach Runde 1 bei bestem Spiel gibt es in jedem Pfad genau eine Spätankunft und zwei Alibis.
    - Keine falsche Option schließt im Verlauf des besten Spiels mehr aus als die richtige, ohne Ausnahme (Wortlaut in E-040 präzisiert).
    - `abkuerzung_test` mit Rot-Probe auf dem alten Kanon.
  - **Umkehrprobe:**
    - Falsch wäre (b), wenn Ahmets Gang im Pfad Can einen Zeugen hätte. Der Prüfer zeigt, dass niemand außer Damir ihn wahrnimmt.
    - Falsch wäre es auch, wenn der Pfad Can nun leichter oder schwerer würde. Der Simulator zählt in allen vier Pfaden 128 Folgen mit Restmenge 1, alle über den Schlüsselbeweis.
- **Befunde und Entscheidungen** (Ü übernommen, T teilweise, V verworfen):

| Befund | Entscheidung | Folge |
|---|---|---|
| GEGEN-01 Nr. 1–3, 8 | Ü | Pfad Can wie oben. Ketten `e2_1` und `e3_3` im Pfad Can neu begründet. |
| GEGEN-01 Nr. 4: Codekette Codetabelle ↔ Streifen der Täterfassung | V | Die Kette braucht den Blick in die versiegelte Fassung. Wer sie öffnet, liest dort ohnehin „Du warst es“. Restrisiko wie E-035. |
| GEGEN-01 Nr. 5: Gästewissen lenkt auf den Ascheneimer | V | Die Sätze sind pfadneutral und Teil der Ketten; eine falsche Fährte im Pfad Can ist gewollt. Die Gegenprobe zeigt: Neutralisieren bräche die Ketten für Zeynep. |
| GEGEN-01 Nr. 6, Gegenprobe: Tim und Serkan nur in neutralen, Marek nur in wahren Hinweisen | Ü | Neutrale Hinweise sind jetzt pfadgleiche Sätze über Kernpersonen oder das leuchtende Gesicht. Die wahren Sätze nennen Marek nicht mehr, und Ollis Gerücht in Runde 2 nennt Can. `abkuerzung_test`: Kein Name steht in einer Runde nur bei einer Qualität. |
| GEGEN-01 Nr. 7: Kerzenständer 3 oder 4 Funde, harmlose Sätze kurz | Ü | Die harmlosen Sätze an Griff (zweimal), Fuß, Umschlag und Schatulle sind verschieden und mindestens halb so lang wie die belastenden. Der Kerzenständer zeigt in allen Pfaden vier Funde (Test). |
| GEGEN-01 Nr. 9: Bei vier Rollen verhindert Sabotage einen wahren Hinweis | Ü (Vermerk) | Folge der Regel −1 (5·2 < 3·4). Gewollt: Die Täterrolle kann die Gruppe bei kleiner Besetzung bremsen. Vermerk unter FÜR DEN NUTZER. |
| GEGEN-02 Nr. 1, GEGEN-03 Nr. 7, SPIEL-02 Nr. 3: Stimmzuordnung über offene Karten der Kernrollen | Ü | Die vier Kernrollen haben keine offenen Stimmkarten mehr. Sie stimmen nur mit den Streifen A (+1) und B (0, bei der Täterrolle −1) aus ihrer Fassung ab. Die Spielleitung kennt keinen ihrer Codes und kann eine −1 keiner Rolle zuordnen. Heft, Karten und Fassung sagen dasselbe; bei vier Rollen erklärt ein Blatt, warum es keine Stimmkarten gibt. |
| GEGEN-02 Nr. 2, 3, 4 | V | Von der Gegenprobe widerlegt (E-024, E-025; Foto-Zeitpunkt). Nr. 3 ist durch den neuen Hinweis `h_can_3_wahr` ohnehin geändert. |
| GEGEN-02 Nr. 5: Täter-Innenseite doppelt so dicht | T | Jede unschuldige Kernrolle hat jetzt ihre Nacht als Chronik in der Du-Form (aus der Tatmatrix belegt). Dazu kommt je ein Eröffnungs- und Schlusssatz an derselben Stelle wie bei der Täterfassung. Wörter je Innenseite: unschuldig etwa 250 statt 140, Täter 400 bis 480. Ganz gleich würde es nur mit Fülltext. Das Heft sagt beim Falten jetzt „ohne hineinzusehen“. |
| GEGEN-02 Nr. 6: Gästeheft eines Trenner-Zeugen pfadabhängig | V | Eigenes Rollenheft, privat wie jedes Heft (E-008, G1-7). Restrisiko beim Druck wie E-035. |
| GEGEN-02 Nr. 7: Zahl in E-035 | Ü | Berichtigt: sechs Beobachtungen in fünf Bausteinen. |
| GEGEN-03 Nr. 1: Mehrheitsschablone erreicht Meister-Punkte | V (Vermerk) | Master 7.7 erlaubt pfadunabhängig richtige frühe Entscheidungen. Fünf der neun sind es, und Meister beginnt bei sieben Punkten (B-12). Die Schablone setzt Wissen aus mehreren Fall-Codes voraus; an einem Abend ist sie nicht erreichbar. Der Vorschlag (Schlüsselbeweise in Runde 2) widerspräche Master 7.6, Runde 3. Der Simulator berichtet jetzt die beste feste Folge (8/7/8/7) und zählt 3 feste Folgen mit 7 Punkten in allen Pfaden; Vermerk unter FÜR DEN NUTZER. |
| GEGEN-03 Nr. 2 | V | Von der Gegenprobe widerlegt (G1-15, E-035, E-036). |
| GEGEN-03 Nr. 3: Verwandtschaft als Deckungsgrund | Ü | `gw_leyla_2`, `gw_zeynep_2`, `gw_can_2` begründen das Schweigen mit Versprechen und Mitschuld. `gw_ahmet_2` nennt Lejla beim Namen statt „meine Cousine“. |
| GEGEN-03 Nr. 4: Geständnisse nennen Waffe und Schlag | Ü | Die vier `aufloesung.*.taeter` sagen „im Dunkeln hat ihn die Panik gepackt“ (TON §1). |
| GEGEN-03 Nr. 5: Emines Kopftuch im Schatulle-Strang | V (Vermerk) | Gegenprobe: TON §7 verbietet das Kopftuch als Teil einer Lüge oder eines Delikts; Emine hat beides nicht. E-029 hat sie bedacht. Vermerk unter FÜR DEN NUTZER. |
| GEGEN-03 Nr. 6: Ausgang in der Nacht gegen Master 7.9 | Ü | Bei richtiger Anklage schließt Herr Schneider das Außentor erst auf, als es dämmert; bis dahin gibt es Torte und Tee. SCHLUESSEL.md ist nachgeführt. |
| GEGEN-03 Nr. 8: Herkunftsmatrix fehlt | Ü | `herkunft.dart` erzeugt sie, und die Story-Bibel zeigt sie in Kapitel 4. `herkunft_test` prüft: Keine Art von Verfehlung liegt bei einer Herkunft allein, und eine Kopftuchträgerin ist unbelastet. Dazu gibt es Rot-Proben. TON §7 verweist darauf. |
| GEGEN-03 Nr. 9: Azras Tipp fehlt in der Auflösung | Ü | `aufloesung.dilara` nennt ihn. |
| GEGEN-03 Nr. 10: Emines Prompt „bottle“ | Ü | „thermos jug of tea“; im Kanon „Thermoskanne mit Tee“. |
| GEGEN-03 Nr. 11: Lacher führen Gäste vor | V (Vermerk) | TON §8 gibt sie vor. Hinweis für Gastgeber in Anleitung und FÜR DEN NUTZER: vorher fragen. |
| GEGEN-03 Nr. 12: „Buffet-Chefin“ | Ü | Lejla heißt „Die Apothekerin“, wie ihr Beruf. |
| SPIEL-01 Nr. 1: Szene malt in die Uhrzeile der Rückblende | Ü | `ClipRect` um die Szene. |
| SPIEL-01 Nr. 2: keine Täteransicht im Fotosatz | Ü | Fotostellen `dossier_taeter` und `wahl_taeter_r1..3`, dazu eine positive Semantikprüfung (die Tarnung steht an `dossier_taeter`). |
| SPIEL-01 Nr. 3: Lage „offen“ trotz Motiv | Ü | Das Motiv zählt zu den belastenden Arten (E-024 nannte es schon). Im Ermittlungsbogen gibt es die Spalte „Motiv“. |
| SPIEL-02 Nr. 1, 2 | V | Von der Gegenprobe widerlegt (E-027, E-036). Seit E-039 gibt es ohnehin keine offenen Karten der Kernrollen mehr. |
| SPIEL-02 Nr. 4: Vorlesetexte ohne Marke | Ü | Die Marke „Vorlesen“ steht vor der Lage-Tabelle und im Anhang. |
| SPIEL-02 Nr. 5: Schritt „Auflösung für alle“ fehlt | Ü | Neuer Absatz nach dem Ende: „Auflösung für alle“, dann „Die Rollen am Tisch“. |
| SPIEL-02 Nr. 6: Meister-Text behauptet einen Fund | Ü | In den vier Meister-Enden kommt der Schlüsselbeweis erst nach dem Geständnis: „Zusammen seht ihr euch den Kerzenständer an.“ Das gilt unabhängig vom Verlauf (wie E-029 für den Bund). |
| SPIEL-02 Nr. 7: Knall und Scheppern | Ü | Die Regel R-ENTLASTET (Kanon und Ermittlungsbogen) erklärt: „Das Scheppern ist das laute Poltern an der Theke, gut eine halbe Minute nach dem Knall.“ |
| SPIEL-02 Nr. 8: Option „Weste“, Karte „Handschuh“ | Ü | Der Fund nennt die Westentasche. |
| SPIEL-02 Nr. 9: Schlüsselband neben Schlüsselbund | Ü | Ahmet trägt ein blaues Stoffarmband. |
| SPIEL-02 Nr. 10: „Umschlag“ für die Fassung | Ü | Heft und Dateiliste sagen „Fassung“. |

- **Belege:**
  - 388 Kern-Tests (neu: `abkuerzung_test`, `herkunft_test`, Rot-Proben in Plausibilität und Druck) und 129 Widget-Tests grün.
  - Texte 0 Befunde (1601).
  - Plausibilität, Simulator, Story-Bibel und Bildprompts OK.
  - Druckproben der Fassungsseiten dem Nutzer gezeigt.
- **Regelkreis Lernen (L-06):** Gegenprüfer lesen gern `git log`, obwohl der Auftrag nur `git status` erlaubt. Die Auftragsvorlage nennt jetzt ausdrücklich: „Zum Stand reicht `git status`; den Commit nennt der Auftrag.“

## E-040 · Nachprüfung von E-039 (F6-GEGEN-04, F6-GEGEN-05) und Anleitung (F7-DOKU-01)
- **Abnahmen:**
  - `F6-GEGEN-04` (Logik): FREIGEGEBEN · 10/10. Eigene Nachrechnung aller 768 Folgen je Pfad bestätigt E-039 für GEGEN-01 Nr. 1, 2, 3, 6 und 7. Gefunden hat sie eine zu weite Aussage in E-039 und die Frage nach dem wahren Hinweis in Runde 3. Kein `git log` (L-06 wirkt).
  - `F6-GEGEN-05` (Druck): FREIGEGEBEN · 9/10. Codes, Summen, Umschläge und Enden stimmen in drei Sätzen; sechs Befunde berechtigt. Ein Befund beruht auf einem Grammatikirrtum.
  - `F7-DOKU-01` (Anleitung): FREIGEGEBEN · 10/10. 168 Zitate geprüft, Befehle ausgeführt, keine Spoiler. Vier offene Fragen sauber gemeldet.
- **Denkprotokoll zum wahren Hinweis in Runde 3 (GEGEN-04 Nr. 2, Gegenprobe: schwer):**
  - **Befund:** Bleiben nach Runde 3 zwei Personen ohne Überführung, entlastet der wahre Hinweis die zweite. Wer ihm glaubt, klagt richtig an. Das gilt für 14 Folgen je Pfad mit mindestens sieben Punkten.
  - **Gegenprüfung:**
    - Der falsche Hinweis derselben Runde beschuldigt in allen vier Pfaden genau diese zweite Person: „X hat den Schlüsselbund … versteckt“. Der neutrale nennt sie nicht.
    - Die Qualität bleibt verborgen (G-1). Wer dem Satz folgt, wettet also darauf, dass die Gruppe zusammengehalten hat.
    - Genau das ist der Lohn der Zusammenarbeit (Master 7.8): Ein wahrer Hinweis soll helfen. W-1 verlangt nur, dass er die Restmenge nicht ändert, und das hält.
    - Im Beispiel liegt außerdem der Bund schon in der Jacke der Täterperson (Fundort aus `e3_1`).
    - Das Ende hängt nach B-12 an Punkten und Anklage, nicht an der Restmenge. Meister ohne Schlüsselbeweis erzählt das Finale seit E-039 ehrlich: Der Beweis kommt erst nach dem Geständnis.
  - **Entscheidung: V.** Keine Abkürzung, sondern die gewollte Wirkung der Gruppenwahl. FALL #2 aus E-025 gilt weiter.
- **Befunde und Entscheidungen:**

| Befund | Entscheidung | Folge |
|---|---|---|
| GEGEN-04 Nr. 1: Nach falschem `e2_1` schließt `e3_3_aylin` Ahmet aus, `e3_3_zeynep` niemanden (Pfade Fatma, Olli, je 80 Vorgeschichten) | V, Wortlaut berichtigt | Aylins Beleg ist ein zweiter Weg zu Ahmets Nebendelikt, wenn der Ascheneimer verpasst wurde. Er kostet den Punkt und führt nicht zum Täter (es bleiben immer zwei). E-039 meinte „im Verlauf des besten Spiels“; so prüft es der Simulator. |
| GEGEN-04 Nr. 2 | V | Siehe Denkprotokoll. |
| GEGEN-04 Nr. 3: `h_can_3_wahr` nennt die Anrichte | Ü | „Beim Scheppern war Ahmet nicht an der Theke, sondern drüben im Ost-Saal an seiner Jacke.“ |
| GEGEN-05 Nr. 1: Täterfassungen „Du schlägst einmal zu.“ (TON §1) | Ü | Die vier `taeter-*.json` sagen nur noch „Dann ist da nur ein dumpfer Schlag und Poltern.“, auch im Satz „Kommt es heraus …“. `tonregeln_test`: kein Schlagverb in einem Spielertext, mit Rot-Probe. |
| GEGEN-05 Nr. 2: Zeile „Motiv“ fehlt im gedruckten Ermittlungsbogen | Ü | Zeilenliste ergänzt. Test: Der Bogen hat für jede Art eine Zeile, die eine Indizkarte ankreuzen lässt. E-039 hatte das zu früh als erledigt geführt. |
| GEGEN-05 Nr. 3: Rollenheft „Dein Umschlag“ | Ü | „Deine Fassung trägt den Code … Öffne sie erst …“. Der Knopf in der App heißt „Fassungen der Kernrollen“. |
| GEGEN-05 Nr. 4: „Abreißen … in die Schüssel“ unter beiden Streifen | Ü | Die Fassungsstreifen sagen „Nur wenn gewählt: abreißen, in die Schüssel.“ Der erste, längere Wortlaut passte nicht in die Zelle und fiel im PDF weg; ein neuer Test fing das ab. |
| GEGEN-05 Nr. 5: Stapeln mit Schrift nach oben | V | Gegenprobe: Obenauf liegt das Codeblatt, die Innenseite liegt darunter und wird nach innen gefaltet. FÜR DEN NUTZER verweist auf das Heft. |
| GEGEN-05 Nr. 6: „ohne hineinzusehen“ fehlt bei Karten und Umschlägen | Ü | „Lies dabei nicht, was hinten steht.“ |
| GEGEN-05 Nr. 7: „Herrn Schneiders Kollegin“ | V | Richtig gebeugt (vorangestellter Genitiv mit „Herr“: „Herrn Meiers Haus“). |
| GEGEN-05 Nr. 8: Vier-Rollen-Heft spricht von Gästekarten | Ü | Ohne Stimmkarten nennt das Heft `teile.stimme_keine` und `gruppenwahl_kern` (Test). |
| GEGEN-05 Nr. 9: Meister-Ende setzt gesammelte Spuren voraus | T | Fatma: „Du hast die Spuren gut zusammengetragen.“ statt „alle“. Mit mindestens sieben Punkten sind Spuren gesammelt; der Satz bei Ahmet bleibt. |
| DOKU-01, Frage 1: Druck nennt immer 30 Minuten | Ü | `DruckSatz.aus(…, rundendauerMinuten:)`; die App gibt die gewählte Dauer weiter, `party_druck --dauer`. Test. |
| DOKU-01, Frage 2: Falten in FÜR DEN NUTZER gegen Heft | Ü | FÜR DEN NUTZER verweist auf das Heft. |
| DOKU-01, Frage 3: Lacher-Namen im Master | V | Der Master ist der Auftrag und bleibt unverändert. Die Kennungen `selin` und `meryem` tragen seit E-007 die Namen Sibel und Hana; den dritten Lacher hat TON §8 Olli gegeben. |
| DOKU-01, Frage 4: Fotos älter als E-039 | Ü | Neue E2E-Matrix auf dem Endstand. |

- **Belege:** 396 Kern-Tests (neu: `druck_nachpruefung_test`, `tonregeln_test`), Analyse ohne Befund, Texte 0 Befunde (1604), Plausibilität, Simulator, Story-Bibel und Bildprompts OK.

## E-041 · Sichtprüfung der Täteransicht und der Rückblende (F6-SICHT-04)
- **Abnahme:** `F6-SICHT-04`: FREIGEGEBEN · 10/10. Alle 32 Bilder der vier Meister-Läufe geprüft, Helligkeit und Kopfzeile gemessen. Die Uhr der Rückblende ist in 16 von 16 Bildern frei (E-039 wirkt). Vier begründete Befunde, kein `git log`.
- **Befunde und Entscheidungen:**

| Befund | Entscheidung | Folge |
|---|---|---|
| Nr. 1: Die Täteransicht trägt „Nur für dich: Du warst es“ und einen roten Rand; ein Blick über die Schulter verrät die Rolle | Ü | Wie im Druck (E-035, E-039) steht die Täterfassung im Abschnitt „Was ich verberge“: zuerst „Du warst es. Vor dem Morgen darf das niemand erfahren.“, dann Tarnung und Tatwissen. Die unschuldigen Kernrollen lesen an derselben Stelle „Du warst es nicht. Trotzdem hast du heute Nacht etwas zu verbergen.“ Die Tafel mit Warnfarbe entfällt; die Ansicht hat bei allen dieselben Abschnitte (Widget-Test ohne `Keller.gefahr`). |
| Nr. 2: Ausnahmelisten in B8, README und `e2e.mjs` unterschiedlich | Ü | Alle drei nennen `dossier`, `dossier_taeter`, `wahl_verdeckt_*` und `wahl_taeter_*` (E-008, E-039). |
| Nr. 3: Nur ein Rückblendenfoto liegt im Stromausfall | Ü | Die Ansicht meldet ihre Uhrzeit an die Sitzung (`rueckblendeZeit`). Das Skript nimmt `rueckblende_1` in jedem Pfad kurz nach 23:58:05 auf. |
| Nr. 4: Leere Täteransicht würde bestehen, Täterwahl ungeprüft | Ü | `dossier_taeter` muss die Tarnung zeigen, `wahl_taeter_r1..3` den Sabotage-Text der Runde; ein leerer Text ist dort ein Fehler. |

- **Folge:** Die App-Ansicht hat sich geändert. Deshalb läuft die E2E-Matrix auf dem neuen Endstand noch einmal; ihr Beleg ersetzt `E2E-081e258.md` in F-12 und F-16.

## E-042 · Übergabe an main ohne entfernten Tag, Matrix auf dem Endstand abgebrochen (F7)
- **Anlass 1:** Der Nutzer will schnell fertig werden: „nah beende schnell wir sind zu stark gesplittet und müssen einfach alles auf main pushen“. Die Matrix aus E-041 auf `c54d708` ist deshalb nach 37 von 84 Läufen abgebrochen; alle 37 waren OK (Pfad Ahmet ganz, Fatma zur Hälfte).
- **Anlass 2:** `main` ist per Fast-forward gepusht (`681ebb9..d5f580e`, kein Force). Den Push des Tags `schlosskeller-1.0` lehnt der Git-Proxy der Sitzung ab: `POST git-receive-pack … HTTP 403`. Branches gehen durch, `refs/tags/*` nicht.
- **Denkprotokoll:** Master §2 sagt, eine blockierte Aktion lasse ich weg, notiere sie unter FÜR DEN NUTZER und arbeite weiter. Die Umgebung verbietet, eine 403 zu umgehen. Ein anderer Weg, etwa ein Release über die GitHub-Oberfläche, wäre genau das. F-17 hat für blockierte Schritte einen Ersatzweg (E-014): Er ist erfüllt, wenn der Abschlussbericht ihn ausweist.
- **Entscheidung:** Der Tag liegt annotiert im lokalen Repo, auf dem letzten Commit von main. Der Befehl, mit dem der Nutzer ihn pusht, steht unter FÜR DEN NUTZER und im Abschlussbericht. Der Tag aus dem ersten Versuch zeigte auf `d5f580e`. Er war nie auf origin und wird lokal auf den Commit mit diesem Eintrag gesetzt; ein veröffentlichter Tag wird also nicht überschrieben.
- **Prüfung statt Matrix:** Nach dem Merge von origin/main sind grün: `tool/pruefen.sh schnell` (Analyse, 416 Kern-Tests, Secret-Scan), `flutter test` 166/166, Server-Smoke 63/63. Die letzte volle Matrix (84/84) lief auf `081e258`. E-041 änderte danach nur die Täteransicht, belegt im Widget-Test.


## E-043 · Kanon geöffnet für den langen Abend (A-050)
- **Anlass:** Spieltest des Besitzers (2026-10-18) und seine Entscheidung „Kanon aufmachen“. Der Schlosskeller bekommt eine neutrale Feier ohne Geburtstag, Stichpunkte statt Gesprächsprosa, Befragungen des Detektivs, eine Story-Brücke für Hof, Garten und Turm und Steckbriefe.
- **Entscheidung:** Die Schlosskeller-Dateien dürfen geändert werden. Fest bleiben die Beweis-Teilmenge (`entscheidungen.json`, `bonus.json`, `gruppenwahl.json`, `tatmatrix/{ahmet,fatma,olli,can}.json`, `wahrnehmung.json`, Raster von `raeume.json`), alle Kennungen, `beobachtung.pfade`, `spuren.entstehtWenn`, die nichttextuellen Teile der Tatmatrix und `fall.pfade/kernverdaechtige/zug`. Geänderte Einträge in `quellabgleich.json` tragen den Status `angepasst` mit Grund E-043.
- **Folge:** `tool/kanon_fest.txt` hält die festen Dateien, `tool/kanon_neu.sh` baselined den Rest. Der Determinismus-Golden wird ab jetzt nicht neu erzeugt.
- **Basis korrigiert (vor jeder Änderung am Kanon):** Die eingebettete Kanon-Kopie (`test/web/kanon_eingebettet.g.dart`) war seit älteren Kanon-Änderungen veraltet (6 Dateien, darunter `entscheidungen.json`, `bonus.json` und `tatmatrix/can.json`). Der Golden von Kern 1.1 passte nur zu dieser alten Kopie. Die Kopie ist neu erzeugt, und `determinismus_soll_k12.g.dart` (Kern 1.2) hält den aktuellen Stand fest; die Listen zu Kern 1.0 und 1.1 bleiben liegen. `kanon_einbetten.dart --pruefe` läuft jetzt in `tool/pruefen.sh schnell` (über `tool/kanon_tor.sh --pruefen`), damit die Kopie nicht wieder veraltet.

## E-044 · Wissen unbesetzter Zielfiguren über den Erzähler, Befragungsantworten als Kurzfassungen (Prüfung M2)
- **Anlass:** Die Prüfung von M2 (Modell befragung, nur Schlosskeller) fand zwei offene Befunde. Beide standen als übersprungene Tests im Repo; der Integrator hat für den Besitzer entschieden.
  - **Befund 1:** Das Wissen unbesetzter Figuren, die Ziel einer Option sind, erreicht den Detektiv nie. Der Planer zählte es als Zustellweg „ziel“ (NPC-Karte), aber die Fundkarte zeigt nur die Fakten der Option. E-035 hatte Zielfiguren aus dem Erzählerwissen genommen, weil es annahm, die Indizkarte liefere ihr Wissen. Im Modell legacy brachten das die NPC-Sprechblasen, im Modell befragung trägt sie niemand. Betroffen: `b_damir_an_der_theke`, `b_emine_versteck`, `b_azra_versteck`, `b_azra_tasche`, `b_zeynep_gesicht`, `b_aylin_quittung`, bei 4 Rollen 21 Lücken (je Entscheidung, Pfad und Glied gezählt).
  - **Befund 2:** Antwort- und Spickzettelzeilen gaben Beobachtung und Behauptung wortgleich aus dem Kanon wieder, bis 19 Wörter. R17 verlangt auf dem Handy Stichpunkte zu höchstens acht Wörtern. Der Besitzer will „keine Textantworten, stichpunktartige Infos als Dialoghilfe“.
- **Entscheidung 1 (mit Verweis auf E-035 und E-036):**
  - Im Modell befragung spricht der Erzähler (Vorleser, solo die App) das Pflichtgespräch-Wissen unbesetzter Figuren zum Rundenstart auch dann, wenn die Figur Ziel einer Option ist. `Erzaehler.npcPlan` nimmt Zielfiguren nur in diesem Modell auf; die Akten im Modell legacy behalten ihren Plan.
  - Wie in E-035: nur, solange die Figur unbesetzt ist, nur Beobachtungen, die in allen Pfaden gelten, gesprochen in der Runde, in der eine Kette eines beliebigen Pfads sie zuerst braucht. Alle sechs Glieder haben `pfade: alle`; kein Ersatzweg nötig.
  - Die Präzisierung aus E-036 („der Gast, den niemand spielt, wird nicht genannt“) gilt für Zielfiguren nicht, weil die Optionen sie ohnehin beim Namen nennen. Gäste, die kein Ziel sind, bleiben namenlos.
  - Neu `texte/erzaehler-npc-ziel.json` mit sechs Vorlesebausteinen: Runde 1 Emine, Azra, Damir; Runde 2 Azra; Runde 3 Zeynep, Aylin. Uhrzeiten und Beträge in Worten. Azras Satz zur Tasche weicht vom gleichlautenden Bonus-Hinweis ab, damit das Erzählerpaket keinen Text aus dem Bonus-Katalog trägt.
  - Der Zustellweg „ziel“ entfällt. Diese Glieder kommen über „npc“; I-B2 und `akte_pruefen._besetzung` zählen eine Zielfigur nur noch im Modell legacy.
  - Der Detektiv bleibt bei drei bis fünf Befragungen je Runde; der Plan ist unverändert.
- **Entscheidung 2:**
  - Für jede Preisgabe einer Befragung gibt es eine Kanon-Kurzfassung in `texte/befragung-kurz.json` (Bereich `kurzfassung`). Eine Preisgabe ist eine Karte: ein bis drei Stichpunkte zu je höchstens acht Wörtern.
  - `antwort` zeigt die App dem Detektiv: Beobachtungen in der dritten Person, Lügen nur als Behauptung in der Ich-Form. `du` steht auf dem Spickzettel der Rolle; ohne `du` gilt `antwort`, bei Lügen mit „Behaupte:“ davor.
  - Alle Hinweisinhalte bleiben: Uhrzeit, Personen, Ort und Richtung. Wo acht Wörter nicht reichen, stehen zwei oder drei Stichpunkte. Drei Lügen sagen „durchgehend“ statt „die ganze Zeit“.
  - `beobachtungen.json` und `figuren.json` bleiben unverändert. F-11 bleibt erfüllt, weil die Kurzfassungen Kanon sind: Fehlt eine, scheitert die Antwort geschlossen.
  - Geprüft werden R17, P-1 (nur öffentliche Preisgaben, Lügen ohne Wahrheit und ohne `du`), P-2 und I-B6 (keine unbesetzten Namen), Fünf-Wort-Folgen und der Textprüfer wie bei allen Tischtexten.
  - **Rollenheft-Druck:** Er nutzt die Kurzfassung, wie App und Online-Spickzettel. Gründe:
    - Der Wunsch nach Stichpunkten als Dialoghilfe gilt für jede Spielerin, ob sie vom Handy oder vom Papier liest.
    - Mischt ein Abend Geräte und Papier, lesen alle dieselben Zeilen (F-10).
    - Die Langfassung steht im selben Heft unter „Was ich weiß“ und „Was ich verberge“. Es geht also nichts verloren.
- **Dazu:** Das Online-Notizbuch des Gastgebers (`befragungsNotizen`) ging nach einer Rückkehr zum Abend verloren. Kennung, Frage und Art jeder beantworteten Befragung liegen jetzt in der Ablage, an das Salz des Abends gebunden (`gastgeber.befragungen`). Beim Laden entsteht die Antwort wieder aus den Preisgaben.
- **Belege:** Die beiden vorher übersprungenen Tests laufen und sind grün: `befragung_loesbar_test` „Ohne die Annahme NPC-Karte …“ (4 bis 20 Rollen, vier Pfade) und `befragung_test` „R17: Jede Preisgabe ist eine Karte …“. Dazu kommen Rot-Proben. Neue Tests decken Erzähler, Erzählerpaket, Spielleitungsheft, Online-Raum, Solo, Reihum und die Rückkehr des Gastgebers ab. Die Akten im Modell legacy bleiben unverändert (`ui_basis_unveraendert_test`, `akte_pruefen` für alle fünf Akten mit 0 Befunden). Der Determinismus-Golden ist nicht neu erzeugt.
