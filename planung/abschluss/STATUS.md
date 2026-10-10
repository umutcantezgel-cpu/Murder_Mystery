# Mordakte · Abschlussstatus

Stand: 2026-10-10 · Arbeitsblock A0 (lokale Grundprüfung grün, vollständige Party-E2E läuft) · Arbeitsbranch ausschließlich `main` · Ausgangsstand `8459824`.

**Nicht fertig.** Grün bedeutet frisch ausgeführte, nachvollziehbare Belege; historische Abnahmen allein reichen nicht. Prozentwerte sind konservative Arbeitsfortschritte, keine Erfolgsquoten. Die endgültige Abnahme braucht zusätzlich einen vom Nutzer bestätigten Online-Abend auf echten Handys.

## Ziele 1–8

| Nr. | Ziel | Stand | Beleg | Nächster Schritt | Fortschritt |
|---|---|---|---|---|---|
| 1 | Runden, sichtbare Aktionen, starker Würfel, immer lösbar | GELB: Würfelkern vorhanden, noch nicht in den Partyabend integriert | `packages/mordakte_core/lib/src/runden/`, vorhandene Rundentests | Kern mit Sitzung und Kartenaktionen verbinden; Simulator gegen echte Spielzustände | 20 % |
| 2 | Party, Solo/Bots und Internet für jeden Abend; WLAN optional | GELB: Schlosskeller lokal; klassische Online-Räume mit echter Engine und 4–20 gleichzeitigen Clients lokal geprüft; noch kein Partyprotokoll | `server/tool/online_matrix.dart`: 17/17 Laststufen, verteilt auf klassische Räume mit höchstens 6 Personen | Autoritativen Abendzustand mit ausschließlich eigener Rollenansicht implementieren; Party-Solo/Bots ergänzen | 25 % |
| 3 | Start Schlosskeller, Gewölbe vollständig spielbar, klassische Fälle erhalten | GELB: Schlosskeller-Start und Menüwege belegt; Gewölbe weiterhin Begleiter | `test/app/start_test.dart`, `node tool/e2e/start.mjs`: 2/2 Handygrößen; Hub-Regressionstests grün | Gewölbe-Spielablauf aus dem unveränderten Kanon aufbauen | 35 % |
| 4 | Mehr Inhalt, schöner gemalter Iso-Look, FEINKORN nur Leben, mobil ohne Überläufe | GELB: Start/Online-Hinweis bei 320/390 px und 200-%-Schrift geprüft; noch keine neue Aktions-/Inhaltsschicht | `test/app/start_test.dart`; [Handyfotos A0](https://cosmos.augmentcode.com/files/app-start-7f7043c536694d2b85920af83243ce13) | Aktionsbühne, lesbare Nebelgestaltung und neue Inhalte; weitere Handy-Sichtabnahmen | 20 % |
| 5 | Release-APK bei jedem main-Push, Release latest, Signatur/Fallback, Web bleibt | GELB: Workflow, optionale Signatur und Debug-Fallback implementiert; APK noch nicht gebaut/veröffentlicht | `.github/workflows/release.yml`, 9 Python-Tests, Workflow-YAML geprüft; Web-Build Exit 0 | Auf main pushen, echten Actions-/APK-Lauf und Download prüfen | 60 % |
| 6 | Railway mit Healthcheck; konfigurierte öffentliche Adresse, kein localhost-Standard | GELB: sichere URL-Konfiguration ohne localhost-Fallback und echter lokaler Healthcheck geprüft; keine öffentliche Adresse vorhanden | `test/session/server_configuration_test.dart`, `tool/ci/check_server_url.py`, `server/tool/online_matrix.dart` | Railway-Zugang/Freigabe, öffentliche Adresse hinterlegen und extern prüfen | 40 % |
| 7 | Gesamtprüfung, Party-E2E, 4–20 echte Online-Clients, Secret-Scan | GELB: `alles` frisch grün; 84 Party-E2E-Läufe gestartet; 20-Personen-Partyraum noch offen | `.werkzeug/belege/a0-alles.log` (723 Tests grün, 1 bestehender Skip), 63/63 Server-Smokes, Online-Matrix 17/17, Secret-Scan sauber; E2E-Vollbeleg noch ausstehend | Party-E2E abschließen; danach Partyraum-/Privatheitsmatrix und öffentliche Prüfung ergänzen | 55 % |
| 8 | README „So spielst du“ + Anleitung je Abend | GELB: README mit APK/Web/Online und ehrlichen Freigabeständen; drei Anleitungen vorhanden | `README.md`, `docs/{partykrimi,gewoelbe,klassisch}/ANLEITUNG.md` | Mit den neuen Spielformen fortschreiben; tatsächliche Web-/Serveradressen ergänzen | 55 % |

## Aktueller Arbeitsblock A0

1. Werkzeugkette und frische Baseline (Flutter 3.47.6 / Dart 3.13.5).
2. Release-/Prüfworkflow, Signing-Fallback, portable Browserprüfungen.
3. Schlosskeller-Standardstart und nutzbare Server-Konfiguration, mit Regressionstests.
4. Prüfungen, kleine Commits auf main, Push, Actions-Ergebnis prüfen, Screenshots teilen.

## Entscheidungen / Grenzen

- **A-001:** Der direkte Nutzerauftrag vom 2026-10-10 ersetzt die historischen Branch-, Modell-, Leitstand- und Generationenregeln des BOLLWERK-Laufs. Keine neuen Branches/Worktrees, keine Merges/Force-Pushes, keine Tag-Pushes. Vision, Kanon, Würfel-/Fairnessregeln und Stil bleiben maßgeblich.
- **A-002:** `krimidinner/**` und `content/party/schlosskeller/**` bleiben unverändert. Neue spielbare Schichten kommen außerhalb des Kanons hinzu. Burgstadt wird niemals wieder angelegt.
- **A-003:** Kein öffentlicher Server wird erfunden oder als erreichbar ausgegeben. Eine fehlende URL muss verständlich sichtbar sein, niemals still auf localhost zeigen. Sobald Railway eine öffentliche Adresse liefert, wird sie als getesteter Standard eingebunden.
- **A-004:** Keine neue App-/Dart-/npm-Abhängigkeit geplant. Bereits deklarierte Pakete werden mit ihren Paketmanagern installiert. Browser-Laufzeitbibliotheken sind Werkzeugvoraussetzungen, keine neuen Spielpakete; keine systemweite Installation.
- **A-005:** Unteragenten nur mit ausschließlich Datei-/Shell-Werkzeugen. Eine lokale Definition mit expliziter Werkzeug-Allowlist (`read`, `edit`, `write`, `bash`) wurde eingerichtet. Zwei lesende Aufträge lieferten jedoch sofort keine Ausgabe und 0 Werkzeugaufrufe. Keine verwertbare Delegation, keine fremden Änderungen; bis zur Klärung arbeitet die Hauptsitzung selbst weiter.
- **A-006:** Browserkontexte verwenden `de-DE`; die POSIX-Sprache der Cloud-Maschine ist kein gültiger Browser-Sprachcode. Native Browser-/PDF-Bibliotheken bleiben auf diese Prozesse beschränkt. Bei unbegrenztem Linux-Stack setzt das Prüfskript nur seinen eigenen Soft-Limit auf 8192 KiB; damit sind reproduzierte native Flutter-Tester-Abstürze behoben.
- **A-007:** Die 4–20-Client-Matrix belegt bislang **klassische Räume mit höchstens 6 Personen**, nicht einen gemeinsamen 20-Personen-Partyraum. Dieser Unterschied wird weder in README noch bei der Abnahme verschwiegen.

## Nur durch den Nutzer / einmal gesammelt angefragt

- Railway-Projekt bzw. Deployment-Zugang als Secret bereitstellen (keine Werte im Chat).
- GitHub Actions erlauben: **bereits aktiviert**, Veröffentlichungsrechte im ersten Release-Lauf noch zu prüfen.
- Optional Android-Keystore als GitHub-Secrets; sonst ausdrücklich Debug-Signatur zum Testen.
- Am Ende Online-Testabend auf Handys bestätigen. **Bestätigung ausstehend.**

## Weckruf und Wiederaufnahme

- Aktive Routine: täglich **09:00, 15:00 und 21:00 Europe/Berlin**.
- Subscription-ID: `01M4KCYARRS5EY928WCXAYFFH2`.
- Beim Wecken zuerst diese Datei und `git status --short --branch` lesen. Anschließend den nächsten offenen Zielpunkt bearbeiten, nicht nur einen Status melden.
- Routine erst nach belegter Erfüllung aller Ziele und Handy-Bestätigung entfernen (oder auf ausdrücklichen Stopp des Nutzers).

## Prüfjournal

- 2026-10-10: Arbeitskopie sauber auf main (`8459824`), keine vorhandene CI. Flutter-SDK aus der im Projekt gepinnten Quelle geladen. Archiv-Eigentümer lokal korrigiert; kein Git-Trust-Ausnahmeeintrag und keine globale Installation. Flutter-Version bestätigt.
- Bereits deklarierte Dart-/Flutter-Pakete und Playwright 1.56.1 installiert. Browser-/PDF-Laufzeitbibliotheken lokal bereitgestellt, ohne Systeminstallation. Maschinenspezifischen Chromium-Pfad durch portable Auswahl mit geprüftem optionalem Override ersetzt.
- A0: `tool/pruefen.sh alles` Exit 0: Analyse ohne Befunde; Pakete 37 + 67 + 415 + 5 Tests grün (1 schon vorhandener Skip), Flutter 199 Tests grün, CI-Helfer 9/9, Szenario-/Kanonprüfungen grün, Server-Smoke 63 OK/0 FAIL, Online-Matrix 17/17, Web-Build ohne CDN und Secret-Scan sauber.
- A0: `node --test tool/e2e/browser_test.mjs` 4/4 grün; `node tool/e2e/start.mjs` Exit 0, Start ohne Parameter bei 320/390 px, Menü erreichbar, 0 Konsolenfehler und 0 fremde Netzaufrufe. Echter SpecialElite-Font im Widgettest verhindert den zuvor sichtbaren Wortumbruch des Titels.
- A0: erster vollständiger Party-E2E-Aufruf wurde nach 600 s vom Werkzeug-Zeitlimit unterbrochen (bis dahin 18 Läufe, alle fertig gemeldeten grün). Das ist **kein** vollständiger grüner Beleg. Ein neuer vollständiger Lauf läuft ohne dieses Kurzzeitlimit im Hintergrund; Log `.werkzeug/belege/a0-party-e2e-full.log`, Exit-Datei `.werkzeug/belege/a0-party-e2e-full.exit`.
- Offene Web-Build-Warnung: erwartete Cupertino-Schrift nicht gebündelt. Der Build gelingt; Nutzung/Entfernung der zugehörigen Icons wird separat geprüft, keine neue Abhängigkeit nur zum Unterdrücken der Warnung.
