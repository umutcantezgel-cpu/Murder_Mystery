# FÜR DEN NUTZER

Hier steht alles, was nur Menschen prüfen oder entscheiden können, und alles, was wegen der Grenzen weggelassen wurde. Die Liste wird bis F7 fortgeschrieben.

## Nicht übernommen, weil nicht vorhanden
- **Werkstatt („Ehrensache auf der Hebebühne“) und Gemeindesaal („Der letzte Tee im Gemeindesaal“):**
  - Im Repo gibt es dazu keine Daten oder Texte, nur die Titel im Teamchat. Es wurde nichts übernommen (E-006).
  - Das Kanon-Schema ist fallneutral (`content/party/<fall>/`), sodass beide Fälle später nach demselben Muster angelegt werden können.

## Grenzfälle, die ich so entschieden habe (bitte prüfen)
- **Flutter-SDK aus dem Netz:**
  - Zum Bauen und Testen habe ich Flutter 3.47.6 aus derselben Quelle geladen, die `build.sh` des Projekts verwendet (`storage.googleapis.com/flutter_infra_release/…/flutter_linux_3.47.6-stable.tar.xz`). Es liegt repo-lokal in `.werkzeug/flutter` und ist gitignored.
  - Ich werte das als Paketinstallation über das Werkzeug des Projekts (E-013, G2-2). Ohne SDK ließe sich kein Build und kein Test belegen.
- **CanvasKit:**
  - `build.sh` baut jetzt mit `--no-web-resources-cdn`. So lädt die Web-Fassung CanvasKit nicht mehr von `gstatic.com`, sondern aus dem eigenen Build.
  - Die Datei wird dadurch etwa 37 MB größer, wenn das Deployment den Ordner ausliefert. Das ist die Bedingung für „zur Laufzeit keine fremden Server“.
- **Spoilerschutz:** Wer im Browser die Entwicklerwerkzeuge öffnet, kann die Kanon-Dateien und damit die Lösung lesen. Das zu verhindern ist in einer lokalen Web-App nicht möglich und kein Ziel (E-013).

- **Druck und Spoiler (E-035):** Außen steht überall nur ein neutraler Code, auch auf den Fassungen; keine Seite verrät sich durch Zahl, Rahmen oder Überschrift. Wer beim Ausschneiden bewusst die Rückseiten liest, kann trotzdem Funde und die Täterfassung lesen. Druckt einseitig, sortiert nur nach Codes, und am besten druckt jemand, der nicht den Detektiv spielt.

- **Gruppenwahl ohne Ergebnisanzeige (E-025):** Die Runde sieht nach ihrer Wahl nicht, ob der Hinweis wahr, neutral oder ein Gerücht war, und auch keine Stimmenzahl. Sonst ließe sich ein Gerücht als Freispruch lesen und die Sabotage der Täterrolle bei vier Rollen erkennen. Erst die Auflösung zeigt, wie oft die Gruppe zusammengehalten hat.
- **Wer mehrere Fall-Codes nacheinander spielt,** kann mit der Zeit lernen, welche Satzform der Hinweise in Runde 3 meist stimmt. Für einen Partyabend mit einem Fall ist das ohne Bedeutung.

- **Helligkeit der Karte (Master 7.13):** Die Ermittlung zeigt das verlangte Grundlicht von 23 % in kühlem Blaugrau, dazu warme Kerzenpunkte und den Lichtkegel des Detektivs. Auf hellen Bildschirmen wirkt das stimmungsvoll; auf einem dunklen Beamer kann es zu düster sein. Der Wert ist eine Zahl in `lib/party/karte_session.dart` (`dunkel: 0.77`).
- **Erzählerstimme:** Sie nutzt nur Stimmen, die der Browser als lokal meldet, und liest genau den Bausteintext vor. Fehlt eine deutsche lokale Stimme, steht der Text da und ein Hinweis erscheint. Chrome kann sehr lange Sätze manchmal abbrechen; dann hilft „Noch einmal vorlesen“.
- **Stimmen auf Papier (E-036, E-039):** Die vier Kernrollen haben keine offenen Stimmkarten. Sie geben je Runde einen Streifen A oder B aus ihrer versiegelten Fassung ab; nur beim Täter zählt B −1. Die Spielleitung merkt beim Zählen, dass sabotiert wurde, aber nicht von wem, weil sie keinen Code einer Kernrolle kennt. Die Codes der Gäste stehen auf deren Karten; wer sie sich beim Ausschneiden merkt, wüsste, welcher Gast wie gestimmt hat. Am Bildschirm sieht das niemand.
- **Fassungen beim Falten (E-039):** Die Innenseite der Täterfassung ist dichter beschrieben als die drei anderen (etwa 450 gegen 250 Wörter), weil sie die Tat erzählt. Ganz gleich würde es nur mit Fülltext. Faltet die Fassungen deshalb genau so, wie das Spielleitungsheft es beschreibt, und seht dabei nicht hinein.
- **Kleine Runde und Sabotage (E-039):** Bei vier Rollen verhindert eine Sabotage der Täterrolle in dieser Runde den wahren Hinweis. Das ist gewollt: Die Täterrolle kann eine kleine Runde bremsen.
- **Mehrmals spielen (E-039):** Fünf der neun Entscheidungen sind in jedem Pfad richtig. Wer den Fall mit mehreren Fall-Codes spielt, kann lernen, welche Optionen meist stimmen, und kommt dann leichter auf Meister-Punkte. Für einen Abend mit einem Fall spielt das keine Rolle. Der Simulator nennt die beste feste Folge (`party_simulate`).

## Optionen zur Entscheidung
- **Kernnamen:**
  - Laut Einstellungen bleiben Ahmet, Fatma, Olli und Can. Damit es keine Klischees gibt, sind Herkunft, Motive und Kopftuch so verteilt, dass keine Gruppe allein die Verfehlungen trägt (E-007).
  - Die Vorprüfung hatte zusätzlich vorgeschlagen, die Kernnamen über alle fünf Herkunftsgruppen neu zu verteilen. Wollt ihr das, ist es eine kleine Kanon-Änderung.

- **Kopftuch bei Emine (E-039):** Emine trägt ein Kopftuch und hat gesehen, wie Fatma die Schatulle nahm; sie schweigt darüber. Sie hat weder Lüge noch Nebendelikt, die Regel aus TON §7 ist also eingehalten. Zwei der drei Kopftuchträgerinnen stehen damit aber im Schatulle-Strang. Wer das ändern will, legt Emines Kopftuch in `figuren.json` (Look `kopf`) auf eine andere, unbelastete Figur.
- **Kopftuch bei Fatma (E-014):**
  - Behzads Material gibt Fatma ein Kopftuch; sie ist zugleich eine der vier möglichen Täterinnen und hat die Münzschatulle mitgenommen.
  - Ich habe es behalten und Gegengewichte gesetzt: Ihr Motiv ist Ehrgeiz für ihre Abschlussarbeit, sie will die Schatulle zurückbringen. Emine (Kopftuch) ist Grundschullehrerin, Tugba (Kopftuch) die Party-Planerin, die beruflich Projekte leitet (E-029: das dritte Kopftuch lag zuerst bei Azra, damit standen alle drei Kopftuchträgerinnen im Schatulle-Strang).
  - Wenn ihr es anders wollt, ist es eine Zeile im Kanon (`figuren.json`, Look von Fatma).
- **Muster der Nebendelikte (SENS-03, E-029):**
  - Ahmet, Fatma und Can tragen Geld, Mitnahme der Schatulle und Streich, Olli Türschaden und Vertuschung. Wer die Namen türkisch oder muslimisch liest, kann darin ein Muster sehen.
  - Gegengewichte sind gesetzt: Jede Kernrolle ist gleich oft Täterin oder Täter, die Herkünfte sind verschieden, Fatma leiht die Schatulle zum Abzeichnen und will sie zurückbringen.
  - Zwei Auswege, je eine kleine Kanon-Änderung:
    - (1) Kernnamen neu verteilen, etwa Olli mit dem Mietgeld.
    - (2) Fatmas Kopftuch auf eine unbelastete Figur legen.
  - Ohne deine Entscheidung bleibt es, wie es ist.
- **Herkunft:** Das Feld `herkunft` dient nur der Ausgewogenheitsprüfung. Es erscheint im Spiel nie als Etikett.
  - Im Burgstadt-Strang habt ihr entschieden, dass Herkunft nicht Teil der Spieldaten ist (dort E48). Hier zeigt kein Spielertext eine Herkunft, nur die Story-Bibel und die Prüfwerkzeuge lesen das Feld.
  - Soll die Regel auch hier gelten, kommt das Feld aus `figuren.json` heraus und die Namensbalance wird über eine eigene Prüfliste belegt. Das ist eine kleine Änderung (E-028).
- **Farbnamen (E-028, E-037):** Fatma heißt jetzt „Beerenrot“ (Änderung aus dem Burgstadt-Strang). Tugba hieß zuerst „Bordeaux mit Gold“, dann „Karminrot mit Gold“, damit keine Farbe nach Wein klingt; seit E-037 trägt sie „Rostorange mit Gold“, weil Karminrot zu nah an Fatmas Beerenrot lag. Fatmas Kopftuch ist taubengrau.

## Nur durch Menschen prüfbar
- Ein echter Testabend: Ton, Humor, Rundendauer (Vorgabe 30 Minuten), Verständlichkeit der Regeln.
- Die Wirkung der Figuren und der Bilder aus den Bildprompts.
- Die Stimme: welche lokale Stimme das Gerät anbietet und wie sie klingt.
- Ob sich die Gruppe in den Figuren wiederfindet.
- Wie hell die Karte auf eurem Bildschirm oder Beamer wirken soll (siehe oben).
- Ob die Seifenblasen, der Staub an der Rüstung und die Rußwolke am Kamin witzig sind oder stören.
- **Die drei Lacher im Intro (E-039):** Olli verläuft sich, Sibel erschrickt vor der Rüstung, Hana verqualmt den Kamin. Fragt vorher, ob die Spielerinnen und Spieler dieser Rollen damit einverstanden sind. Die Lacher sind Vorgabe (TON §8); ändern lässt sich das in `texte/erzaehler-intro.json`.
- **Ähnliche Figurenfarben über Räume hinweg (E-037):** Meryem/Serkan, Olli/Serkan, Ahmet/Baran, Murat/Hakan, Olli/Meryem und Serkan/Kaan liegen unter ΔE 10. Im selben Startraum gilt überall mindestens 10. Die Figuren unterscheiden sich durch Silhouette, Kopf und Haar. Wer am Testabend Verwechslungen merkt, kann einzelne Farbcodes in `figuren.json` anpassen; der Farbtest zeigt dann sofort, ob die Abstände halten.

## Abschluss (F7)
- **Letzte E2E-Matrix:** Vollständig (84/84, 0 Konsolenfehler, 0 fremde Anfragen) lief sie auf `081e258`. Danach hat E-041 nur noch die Täteransicht in der App und die Fotostellen geändert. Die Matrix auf diesem Stand habe ich auf deinen Wunsch abgebrochen, um schnell auf main zu kommen. Belegt ist die Änderung durch die Widget-Tests. Wer sicher gehen will: `tool/pruefen.sh e2e` (gut 1,5 Stunden).
- **main:** Die neuen Commits von origin/main (BOLLWERK, Fusion, Leitstand) sind per Merge übernommen, ohne Konflikt. Danach lief die Prüfung grün: Analyse, 416 Kern-Tests, 166 Flutter-Tests, Server-Smoke.
- **Tag `schlosskeller-1.0` noch nicht auf GitHub:** Der Git-Proxy dieser Sitzung blockt das Pushen von Tags (HTTP 403); main selbst ist gepusht. Der Tag liegt annotiert auf dem letzten Commit von main. So kommt er nach GitHub, von einem eigenen Rechner aus:
  `git fetch origin main && git tag -a schlosskeller-1.0 origin/main -m "Spuk im Schlosskeller 1.0" && git push origin schlosskeller-1.0`
  Alternativ auf GitHub unter „Releases“ ein Release mit dem Tag `schlosskeller-1.0` auf `main` anlegen (E-042).

## Finale (A-063 bis A-067)
Einstimmung (Vorgeschichte und Vorstellung), Erzählerakte (nur für den Erzähler) und „Dein Moment“ (Einfluss-Schicht) auf dem Branch `claude/schlosskeller-finale`. Belege stehen in `planung/finale/STATUS.md`, alle Festlegungen in `planung/finale/SPEZIFIKATION.md` („Änderungen“ 1–54; die PDFs ab 48).

### Nur durch Menschen prüfbar
- **Ton der Einstimmung:** Vorgeschichte und Vorstellungen sind maschinell geprüft, aber noch nie an einem echten Tisch gelaufen.
  - Hört sie einmal laut vorgelesen und einmal mit der Stimme des Geräts: Tragen die Pointen, passt das Tempo, wird die Vorstellung bei vielen Rollen zu lang?
  - Die Texte stehen in `texte/erzaehler-vorgeschichte.json` und `texte/erzaehler-vorstellung.json` (`content/party/schlosskeller/`).
- **Zahlen von „Dein Moment“:** Abgestimmt ist nur mit Bots (1.000 Abende je Tischgröße, E-048, Spezifikation „Änderungen“ 20–23).
  - Am Bot-Tisch mit 20 Rollen gibt es zu 86 % Tischbonus +1, weil die späten Rollen (ab Rolle 13) als Bots hilfsbereit sind. Bei 4 bis 12 Rollen sind es 22 bis 30 %.
  - Am echten Tisch prüfen: Wie oft wächst der Zusammenhalt, wie oft kippt der Spuk, reichen die Nachtminuten, sind die Sterne erreichbar?
  - Die Stellschrauben stehen in `content/party/zusatz/schlosskeller/einfluss.json` (`zahlen`, `bots`, `ziele`, `ereignisse`).
- **Kern-Epiloge:** Die vier Epiloge „erreicht“ von Ahmet, Fatma, Olli und Can sind nach der Prüfung neu geschrieben. Sie werten den Ausgang nicht mehr, weil auch die unentdeckte Täterrolle „nicht angeklagt“ erreicht.
  - Hört sie nach einer richtigen und nach einer falschen Anklage.
  - Die übrigen Textänderungen derselben Prüfung (warmer Morgen, Sammelblock der Vorstellung, Stern des Abends) stehen in Spezifikation „Änderungen“ 29–36 und im Prüfjournal von `planung/finale/STATUS.md`.
- **Kachelraster von „Dein Moment“:** Die Tests laufen bei 320 und 390 px und doppelter Schrift. Ob sich die Kacheln auf einem echten 320-px-Handy gut tippen und lesen lassen, zeigt nur das Gerät.
- **Porträts im Druck:** Vor dem Druck `flutter test tool/bild/druck_portraets_test.dart` laufen lassen, sonst stehen Schattenrisse in den Heften. Seht euch Erzählerheft, Steckbriefe und Erzählerakte einmal auf Papier an.
- **Erzählerakte als PDF (Nachtrag 2026-10-30):** Maschinell geprüft sind Bytes, Seitenzahl und Sichtbarkeit, nicht das Gerät und nicht das Papier.
  - Auf einem echten Handy: Detektei → **PDFs zum Ausdrucken** → **Druckmappe vorbereiten** → **Erzählerakte**. Öffnet sich das Teilen, lässt sich die Datei speichern und drucken?
  - Am Abend in der offenen Erzählerakte **Als PDF** antippen: reihum am Pult, am Erzähler-Handy und online am Erzähler-Sitz. Mit „Dein Moment“ müssen die Sterne darin stehen.
  - Einmal auf Papier: Sind die Porträts mit 360 px (in der App) scharf genug? Die Release-Dateien haben 720 px.
  - Bei 320 px Breite brechen „Schließen“ und „Als PDF“ im Fuß der Erzählerakte vielleicht auf zwei Zeilen um. Ist das noch gut lesbar und tippbar?
- **Ladezeit im Browser:** Die App zeichnet 22 Porträts und rechnet sie in reinem Dart um. Wie lange dauert „Erzählerakte“ in der Druckmappe der Web-Fassung, auch auf einem schwachen Handy? Ziel unter 20 Sekunden, sonst die Porträts auf 240 px verkleinern. Scheitern die Bilder im Browser, kommt die Akte ohne Porträts; dann bitte melden.
- **PDFs am Release:** Nach dem ersten CI-Lauf mit dem neuen Job `erzaehlerakte` beide Dateien herunterladen (`erzaehlerakte.pdf`, `erzaehlerakte-dein-moment.pdf`) und durchblättern: 24 Seiten, kein „Heute gespielt“, keine Personenzahl auf dem Deckblatt. Die Dateien sind öffentlich; sie nennen nie den Täter, sind aber nur für die Person gedacht, die erzählt.

### Bewusst so gelassen (bitte prüfen)
- **Sensibilität:**
  - Fatmas Vorstellung nennt das taubengraue Kopftuch als Kleidung, die Pointe gilt ihrer Farbenlehre. Zusammen mit „spricht leise, lächelt viel“ kann man ein Klischee lesen. Ein Sensibilitätsleser sollte das bestätigen; der Ausweg wäre, das Kopftuch in der Vorstellung wegzulassen.
  - Im Netz der Erzählerakte gibt es Paare gleicher Herkunft (Zeynep–Sibel–Serkan, Joanna–Marek, Joanna–Wojtek). Sie sind weder Motiv noch Pointe (TON §7).
  - Aylins Bot-Blasen sind Büro-Humor aus ihrem Alltag („Gerüchte bitte schriftlich und in doppelter Ausführung“, „das hefte ich gleich ordentlich ab“). Wer streng sein will, ersetzt `einfluss.bot.aylin.geruecht` und `.freund_gestanden`.
- **Ungleichgewichte aus dem Kanon:** Alle sind in jedem Pfad gleich und verraten keinen Täter.
  - Can hat vor dem Abend keinen Konflikt mit Herrn Schneider, die anderen drei Kernfiguren schon.
  - Ahmet hat zwei loyale Figuren (Lejla, Joanna), die anderen Kernfiguren je eine.
  - Die Geständnisse der Randfiguren („Auspacken“) betreffen Ahmet und Can je viermal, Fatma zweimal und Olli ein- bis zweimal (Spezifikation „Änderungen“ 10).
- **Widerspruch im Kanon:** In `raeume.json` hat `vorrat_tuer` den Wert `quietscht: false`, Cans `motiveAndConflict` sagt aber, die Tür zum Vorratsraum quietscht auf. Bewusst nicht geändert, weil die Wahrnehmungsbeweise am Raster hängen.

### Gut zu wissen
- **Online:** Mit „Dein Moment“ gilt das Protokoll 5. Alle Geräte brauchen die neue App, ältere kommen nicht mehr in einen Raum.
- **Alte Abende:** Abende, die ein Gerät vorher abgelegt hat, laufen nach „Abend fortsetzen“ ohne „Dein Moment“ weiter.

### Zur Entscheidung
- **Zusammenführung nach `main`:** Wann der Branch nach `main` kommt, entscheidet ihr. Danach wird `einfluss_soll.g.dart` nie mehr neu geschrieben (E-048). Wer die Zahlen von „Dein Moment“ nach einem Testabend ändern will, tut das am besten vorher.

