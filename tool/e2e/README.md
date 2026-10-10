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
- `node --test browser_test.mjs`: Browser-Konfiguration ohne Maschinenpfade prüfen
- `node e2e.mjs --nur pfad=ahmet,n=4`: nur passende Läufe. Felder: `pfad`, `ende`, `n`, `skript`, `fotos` (0/1), `semantik` (0/1). Mehrere Felder mit Komma trennen; `skript=best,a,richtig` ist ein Wert.
- `--parallel 1`: eine Seite statt zwei (höchstens 2)
- `--negativtest`: prüft eine Kopie des ersten gewählten Laufs, deren Ende-Erwartung vertauscht ist. Der Lauf muss als „Fehler erkannt“ gemeldet werden.

## Parameter

- Mit Fotos (n = 7): `takt=400&zeitraffer=60&fotos=1`, Zeitlimit 6 min. Je Fotostelle ein Bildschirmfoto 200 ms nach der Meldung, nacheinander.
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
