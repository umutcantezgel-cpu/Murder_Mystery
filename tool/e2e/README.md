# E2E-Gerüst Partymodus

Spielt den Abend „Spuk im Schlosskeller“ im Browser automatisch vom Titel bis zum Ende durch und prüft jeden Lauf.
Abgedeckt sind die vier Pfade (ahmet, fatma, olli, can) mit allen vier Enden und den Personenzahlen 4, 7, 12, 16 und 20
(80 Läufe). Dazu kommt je Pfad ein Semantik-Lauf (ende_meister, n = 7, 4 Läufe). Fotos entstehen nur bei n = 7.

## Voraussetzungen

- Web-Build ohne CDN im Repo-Wurzelverzeichnis: `flutter build web --release --no-web-resources-cdn -o build/web`
- Node 22 und das bereits deklarierte Playwright 1.56.1: `cd tool/e2e && npm ci`
- Browser einmal installieren: `npx playwright install chromium` (Linux braucht außerdem die von Playwright angegebenen Laufzeitbibliotheken).
- Standard: Playwrights eigenes Chromium. Optional `MORDAKTE_CHROMIUM` auf eine vorhandene Chromium-Datei setzen; kein fester Maschinenpfad.
- Test-Kontexte nutzen ausdrücklich `de-DE`, unabhängig von der Sprache der CI-Maschine (POSIX-Locale ist kein gültiger Browser-Sprachcode).
- Optional für lokal entpackte Linux-Bibliotheken: `MORDAKTE_BROWSER_LIBRARY_PATH`. Dieser Pfad gilt nur im Chromium-Prozess, nicht für Flutter.
- Nur 127.0.0.1, kein Netz

## Aufrufe

Im Ordner `tool/e2e`:

- `node e2e.mjs` oder `npm test`: alle 84 Läufe, zwei Seiten gleichzeitig
- `node start.mjs`: App-Start ohne URL-Parameter bei 320/390 px, Menüwege, keine Konsolenfehler/fremden Anfragen; Handyfotos und Kontaktbogen unter `fotos/start/`.
- `node runden.mjs`: echte Handy-Bedienung bei 320/390 px: Auftakt, Chancen, Würfelknopf, endgültige Listenwahl, sichtbarer Lauf und Gesprächspose, Fund ohne Befragungswurf. Der Standbild-Einstieg setzt nur den Anfang der Runde; alle geprüften Aktionen laufen über echte Knöpfe und den Renderer, nicht über `PartySkript`. Öffentliche Karten-/Würfelfotos unter `fotos/runden/`. Bestandteil von `tool/pruefen.sh e2e`.
- `node solo.mjs`: zwei vollständige Solo-Abende bei 320/390 px vom echten Titel bis zum Ende, ohne Entwicklerroute oder `PartySkript`. Je Runde drei bis fünf Befragungen der Bots (Modell befragung: Antwort erst nach der Frage, freie Wahl über die aufklappbare Zeile, Hilfe `befragung.mjs` über die Semantik-Kennungen `befragung-*`), gesperrte Bot-Dossiers, Vorgeschichte und Vorstellung (A-063, im Assistenten an; die Probe überspringt beide Teile), neun sichtbare Kartenaktionen, Würfel und „Dein Moment“ (Finale §3, im Assistenten an: die Bots ziehen, zu Beginn jeder Ermittlung die Folgen, keine Gruppenwahl). Echte Pointer-Eingaben über die sichtbaren Semantik-Koordinaten (CanvasKit-Scrollcontainer). `--nur320` ist eine einzelne Bedienprobe. Fotos ohne Auflösung unter `fotos/solo/`; Teil von `tool/pruefen.sh e2e`.
- `node erzaehler.mjs`: Online-Abend mit Sitzen (Langer Abend M3b), drei Handys bei 390 px gegen die lokale Relais-Attrappe (`server/` → `dart run ../tool/e2e/attrappe.dart`; eine laufende nimmt `MORDAKTE_RELAIS=ws://127.0.0.1:<port>`). Die Gastgeberin wählt „Dein Platz: Erzähler“, teilt in der Lobby Ben den Detektiv-Sitz und Cleo eine feste Figur zu. Geprüft wird die Privatsphäre-Matrix je Abschnitt: Erzähltext und Erzählerpaket nur am Pult der Gastgeberin, „Anna liest vor.“ bei den Gästen, das Wissen ungespielter Gäste als Notiz nur beim Detektiv, Dossierzeilen nur bei Cleo, Cleos Spickzettel nie beim Detektiv. Ben befragt und wählt die erste Spur am eigenen Gerät; die Gastgeberin sieht die Zuschauerkarte. Fotos ohne geheime Texte und Fehlerbilder unter `fotos/erzaehler/`.
- `node diashow.mjs`: Diashow zur Einleitung (Langer Abend M4). Die Entwicklerroute spielt bis zum Intro vor, danach nur echte Knöpfe: je Bild die Beschriftung „Bild n von 6“ und nur der Erzähltext zu diesem Bild, „Nächstes Bild“ schaltet beide weiter, am letzten Bild bleibt „Weiter“. Bei 390 px mit Bewegung und bei 320 px mit „Bewegung reduzieren“. Fotos der Bilder unter `fotos/diashow/`.
- `node lang.mjs`: der lange Abend (Langer Abend M7b, `?party=schlosskeller&fassung=lang`) gegen denselben Abend kurz. Beide Läufe über die Entwicklerroute (`PartySkript`), nacheinander bei 390 × 844 px, mit gleichem Pfad, Fall-Code, Personenzahl, Skript und Salz (`salz=`, also denselben Würfeln); Vorgabe `ahmet`, n = 4, `ende_meister`, ändern mit `--pfad`, `--n`, `--ende`. Kurz ohne Fotos und mit „Bewegung reduzieren“ (`takt=40&zeitraffer=240`, Kartenaktionen als Kurzblende, Zeitlimit 6 min), lang mit Bewegung und Fotos (`takt=80&zeitraffer=240&fotopause=2000`, Zeitlimit 12 min): Vorspiel Station für Station, Diashow, je Runde Streifzug mit Treffpunkten, Erkundung und Rückweg in den Keller vor jeder Entscheidung, Auflösung, Morgen. Fotografiert werden die Stellen des langen Abends (`fotonur=vorspiel,streifzug,treffpunkt,erkundung,morgen`: nur dort wartet das Skript die Fotopause, die übrigen meldet es nur); `--alle-fotos` fotografiert jede Fotostelle. Jeder Lauf besteht die Prüfungen von `e2e.mjs` (unten, a bis e, dazu die Streifzug-Fotostellen). Außerdem muss die Zeile `PARTY fertig` lang genau so lauten wie kurz: Pfad, Ende, Punkte, Personenzahl und dahinter `wuerfe=` (Zahl der Würfe), `nacht=` (Nachtminuten) und `abend=` (Kennung über Würfe, Wahlen, Fakten, Marken, Qualitäten und Abstecher, `PartySkript.abendKennung`). Die Fotofolge des langen Laufs: `vorspiel` nach den Dossiers und vor `intro`, je Runde `streifzug_r<n>`, `treffpunkt_r<n>` und `erkundung_r<n>` genau einmal in ihrer Runde, `morgen` nach `aufloesung_r3` und vor `ende`, zu jeder ein Foto; kurz gibt es keine davon. Fotos und `bericht.json` unter `fotos/lang/`. Teil von `tool/pruefen.sh ci` (nach `solo.mjs --nur320`) und `tool/pruefen.sh e2e`.
- `node finale.mjs`: das Finale (Schlosskeller) mit Einstimmung und „Dein Moment“ über die Entwicklerroute (`PartySkript`, `?party=schlosskeller&einstimmung=1&einfluss=1`) bei 390 × 844 px; Vorgabe `ahmet`, n = 5, `best,a,richtig`, festes Salz wie `test/party_widgets/einfluss_skript_test.dart`, ändern mit `--pfad` und `--n`. Das Skript geht Vorgeschichte und Vorstellung Schritt für Schritt durch, zieht je Runde für jede Rolle verdeckt den Zug eines Bots, lässt zu Beginn jeder Ermittlung die Folgen lesen, ermittelt ohne Gruppenwahl, nutzt vor der Anklage eine offene Nachfrage und läuft bis zum Schlussbild. Fotos (`fotonur=`, Fotopause 18 s, Zeitlimit 20 min): Vorgeschichte, Vorstellung, Gespräche mit der Moment-Liste, verdeckter Moment (`moment_r1`), Folgen (`folgen_r1`), jede endgültige Wahl (mit Tischwert: `endgueltig_<entscheidung>_abzeichen`), Zwischenresümees mit den Leisten, Nachfrage, Auflösung mit Sternen und Auszeichnungen, Schlussbild; lange Bildschirme scrollt die Probe mit dem Mausrad am linken Rand weiter (dort zeigt kein Knopf einen Tooltip; `_2`, `_3`, …, nie über der Karte; verglichen ohne den Rollbalken), und reicht die Fotopause nicht bis zum Ende, springt sie zum Schluss ganz nach unten (`_schluss`). Geprüft: `PARTY fertig` mit Pfad und Personenzahl, Phasenfolge ohne Gruppenwahl, Fotostellen je Abschnitt und in ihrer Folge (Moment vor den Folgen, Folgen vor dem Auftakt), mindestens ein Abzeichen, zu jeder fotografierten Stelle ein Foto, die Auflösung bis zu ihrem Ende (Sterne, Tipps, Endwert) im Bild, keine Konsolenfehler, keine fremden Anfragen. Fotos, `kontaktbogen.png` und `bericht.json` unter `fotos/finale/`. Teil von `tool/pruefen.sh e2e`, nicht von `ci` (Laufzeit).
- `node druck.mjs`: der Weg zu den PDFs (PDF-Paket). Detektei bei 320 und 390 px: unter der Mappe des Schlosskellers der Knopf „PDFs zum Ausdrucken“, ganz im Bild und genau einmal; die Mappe bleibt genau ein Knopf mit „Spuk im Schlosskeller“ im Namen. Bei 390 px (`--breite 320` für die schmale Breite) führt der Knopf in die Druckmappe; mit den Standardwerten „Druckmappe vorbereiten“, dann „Erzählerakte“ und zum Vergleich „Alles in einer Datei“: Zeit vom Tipp bis „Herunterladen: …“, danach der Download (Name, Größe, beginnt mit `%PDF-`, endet mit `%%EOF`). Ziel für die Erzählerakte: unter 20 s. Ein verfehltes Ziel ist eine Warnung (`ZEITZIEL VERFEHLT`), mit `--zeitziel` ein Fehler; `--drossel 4` (oder 6) rechnet wie ein mittleres (einfaches) Handy, wie `leistung.mjs`. `--ruhig` öffnet die Seiten mit „Bewegung reduzieren“ (Sanduhr statt Ladekreisel). Zum Schluss die Akte-Seite des Schlosskellers bei 320 px: die vier Fußknöpfe ganz im Bild, ohne Überlappung und antippbar; „PDFs zum Ausdrucken“ öffnet auch von hier die Druckmappe. Keine Konsolenfehler, keine fremden Anfragen. Fotos, `kontaktbogen.png`, die beiden PDFs und `bericht.json` (Zeiten, Bytes, Fall-Code der Druckmappe, Lage der Knöpfe) unter `fotos/druck/`. Teil von `tool/pruefen.sh e2e`, nicht von `ci`.
- `node e2e.mjs --lang`: alle gewählten Läufe von `e2e.mjs` als langer Abend (doppeltes Zeitlimit); Fotos dann unter `fotos/e2e/<pfad>_<ende>_n<n>_lang/`.
- `node --test browser_test.mjs`: Browser-Konfiguration ohne Maschinenpfade prüfen
- `node e2e.mjs --nur pfad=ahmet,n=4`: nur passende Läufe. Felder: `pfad`, `ende`, `n`, `skript`, `fotos` (0/1), `semantik` (0/1). Mehrere Felder mit Komma trennen; `skript=best,a,richtig` ist ein Wert.
- `--parallel 1`: eine Seite statt zwei (höchstens 2)
- `--negativtest`: prüft eine Kopie des ersten gewählten Laufs, deren Ende-Erwartung vertauscht ist. Der Lauf muss als „Fehler erkannt“ gemeldet werden.

## Parameter

- Mit Fotos (n = 7): `takt=400&zeitraffer=60&fotos=1&fotopause=2000`, Zeitlimit 8 min. Je Fotostelle ein Bildschirmfoto 200 ms nach der Meldung, nacheinander.
- Ohne Fotos: `takt=40&zeitraffer=240&fotos=0`, Zeitlimit 3 min.
- Semantik-Läufe: `takt=400&zeitraffer=240&fotos=0&semantik=1`, Zeitlimit 3 min. Abweichung von takt=40: Bei 40 ms hat der Browser den neuen Bildschirm noch nicht gezeichnet, wenn die Fotostelle gemeldet wird. Gemessen wurde an `gespraeche_r2` noch der Bildschirm der Vorrunde. Der Bildschirmtext wird im Moment der Fotostelle gelesen.

## Prüfungen je Lauf

a. `PARTY fertig` erscheint.
b. Pfad, Ende und Personenzahl (`rollen`) stimmen mit dem Lauf überein.
c. Die Phasenfolge aus `PARTY phase=` lautet einrichtung, rollen, intro, 3 × (gespraeche, entscheidungen, gruppenwahl, bonus, resuemee), anklage, finale, aufloesung, ende. Der Titel meldet keine Phase, ist aber die erste Fotostelle. Die Fotostellen folgen derselben Reihenfolge.
d. Keine Konsolenfehler (Typ `error`), keine `pageerror`, kein `PARTY fehler`.
e. Keine Anfragen an andere Hosts als 127.0.0.1 und localhost. `data:`, `blob:` und `about:` sind erlaubt.

Zusätzlich bei Semantik-Läufen: An `gespraeche_r1` bis `r3` stehen die Uhrzeit 00:30, 01:15 bzw. 02:00 und der Erzählertext der Runde (`runde.N.start`) im Bildschirmtext (DOM `flt-semantics-host` und alle `aria-label`). An jeder Fotostelle vor `finale` außer den verdeckten Ansichten (`dossier`, `dossier_taeter`, `wahl_verdeckt_*`, `wahl_taeter_*`; E-008, E-039) stehen weder „Nur für dich“ noch die ersten 40 Zeichen der Täterfassung (Feld `tarnung` aus `taeter-<pfad>.json`). Ein leerer Text gilt dort als nicht gezeichnet und wird nicht bewertet. Umgekehrt muss `dossier_taeter` die Tarnung zeigen und `wahl_taeter_r1` bis `r3` den Sabotage-Text der Runde (`wahlen-kern.json`); dort ist ein leerer Text ein Fehler.

## Ausgabe

Alles unter `tool/e2e/fotos/` (gitignored):

- `fotos/e2e/<pfad>_<ende>_n<n>/NNN_<name>.png`: Fotos der Fotoläufe, nummeriert in Reihenfolge der Fotostellen
- `fotos/e2e/bericht.json`: je Lauf `pfad`, `ende`, `n`, `ok`, `ende_ist`, `punkte`, `dauer_s`, `fehler`, `fremd`, `fotos`, `phasen`, `fotostellen`; bei Semantik-Läufen zusätzlich `bildschirmtexte`
- `fotos/e2e/bericht.md`: Tabelle aller Läufe, Summe und Fehler je Lauf

Rückgabewert: 0 nur, wenn alle Läufe bestanden. Bei `--negativtest` 0 nur, wenn der Fehler erkannt wurde. 2 bei Aufruf- oder Bauproblemen (z. B. fehlendes `build/web`).
