# Anleitung: Partyabend „Spuk im Schlosskeller“

Stand: Oktober 2026. Der lokale Partyabend ist spielbar; Würfelintegration, Solo-Bots und Internet-Party sind noch in Arbeit. Der verbindliche Freigabestand steht in `planung/abschluss/STATUS.md`.

Diese Anleitung hat drei Teile:

- **Teil 1, Für Gastgeber:** Was der Abend ist, Einrichtung, Ablauf und Tipps.
- **Teil 2, Druckspiel:** Der Abend mit Papier.
- **Teil 3, Für Entwickler:** Aufbau, Prüfungen, Texte ändern.

---

## Teil 1: Für Gastgeber

### Was der Abend ist

- Ein Krimi-Abend für Freundesgruppen.
- Es spielen 4 bis 20 Personen. Dazu kommt das Geburtstagskind als Detektivin oder Detektiv.
- Im Fall „Spuk im Schlosskeller“ fällt um Mitternacht bei einer Geburtstagsfeier im Gewölbe der Strom aus. Danach liegt Herr Schneider, der Schlossverwalter, bewusstlos im Vorratsraum.
- Das Geburtstagskind ermittelt mit neun Entscheidungen in drei Runden.
- Die anderen Gäste spielen Rollen mit Geheimnissen. In jeder Runde treffen sie eine Wahl. Sie kann dem Detektiv helfen oder ihn in die Irre führen.
- Am Ende klagt das Geburtstagskind eine von vier Verdächtigen an: Ahmet, Fatma, Olli oder Can. Dann folgt eines von vier Enden.
- Dauer: drei Runden à 30 Minuten (Vorgabe), dazu Anfang und Ende.

### Was ihr braucht

- Einen Bildschirm, den alle sehen können, mit Browser oder Android-App. Ein Gerät reicht. Es geht reihum.
- APK-Download und Web-Zugang: Abschnitt „So spielst du“ in der README. Nach dem Laden funktioniert der lokale Partyabend ohne Spielserver.
- Optional: einen Drucker, wenn ihr mit Papier spielen wollt (Teil 2).
- Für die Erzählerstimme: eine deutsche Stimme auf dem Gerät. Fehlt sie, steht der Text trotzdem auf dem Bildschirm.

### Start

1. Öffnet die App. Ohne besonderen Link startet sie direkt im **Schlosskeller**.
2. Es erscheint „Spuk im Schlosskeller“ mit „Das Buffet hinter dicken Mauern“. Darunter steht: „Das Geburtstagskind schaut beim Einrichten weg.“
3. Tippt auf **„Abend vorbereiten“**.
4. **„Andere Abende & Fälle“** führt stattdessen zur Übersicht: Gewölbe-Begleiter, klassische Fälle und deren Online-Lobby bleiben erreichbar.

### Einrichtung

Die Einrichtung macht jemand, der nicht das Geburtstagskind ist. Die Seite sagt es selbst: „Jemand außer dem Geburtstagskind richtet ein. Das Geburtstagskind schaut bitte weg.“

Die Einrichtung hat diese Abschnitte, von oben nach unten.

1. **Personen am Tisch.** Stellt die Zahl mit dem Regler ein. Der Text zeigt „{anzahl} Personen sitzen am Tisch“. Die Zahl zählt ohne das Geburtstagskind. Der Bereich ist 4 bis 20, die Vorgabe ist 7.
   - Zu jeder Zahl gehört eine feste Besetzung: die Rollen, die dann mitspielen. Sie stehen in der Liste mit Figur und Titel.
   - Jede Rolle hat ein Feld „Name (optional)“. Ohne Namen heißt jede Person wie ihre Figur.
   - Die Erzählertexte nennen die Figuren beim Namen, nicht die Spielernamen.
   - Ändert ihr die Zahl, bleiben die schon eingetragenen Namen erhalten.
2. **Das Geburtstagskind.** Ein Feld „Name (optional)“. Bei den Gesprächen steht der Name. Ohne Namen steht „Geburtstagskind“.
3. **Wer ermittelt?** Wählt „Detektiv“ oder „Detektivin“.
4. **Der Fall.** Die Vorgabe ist „Zufall“. Dann entsteht ein neuer Fall.
   - Mit „Code eingeben“ tragt ihr einen Fall-Code ein. Er heißt „Fall-Code aus fünf Zeichen“.
   - Erlaubt sind Großbuchstaben und die Ziffern 3, 4, 7 und 9. Die Eingabe wird automatisch groß geschrieben.
   - Passt der Code nicht, steht da: „Zu diesem Code gibt es keinen Fall. Prüfe die fünf Zeichen.“
   - Mit demselben Code spielt ihr denselben Fall. Der Hinweis dazu lautet: „Mit demselben Code lässt sich derselbe Fall wieder spielen.“
5. **Wie spielt ihr?** „Am Bildschirm“ ist die Vorgabe. Bei „Zum Drucken“ steht: „Die Druckfassung kommt als PDF. Der Bildschirm führt trotzdem durch den Abend.“ Teil 2 erklärt das Druckspiel.
6. **Wie lange dauert eine Runde?** Zur Wahl stehen 20, 30, 45 und 60 Minuten. Die Vorgabe ist 30 Minuten. Die Uhr auf dem Bildschirm läuft mit dieser Zeit, und die Druckfassung aus der App nennt dieselbe Dauer.
7. **Erzählerstimme.** Der Schalter „Stimme einschalten“ ist anfangs aus. Die Stimme liest nur die festen Texte vor. Die Seite sagt es so: „Die Stimme liest nur die festen Texte vor und lässt sich jederzeit abschalten.“

Tippt danach auf **„Abend starten“**. Der Knopf ist erst aktiv, wenn der Fall-Code passt. Danach lassen sich Personenzahl, Detektiv und Fall nicht mehr ändern.

### Verdeckte Rollenvergabe

Die Seite heißt „Eure Rollen“. Darunter steht: „Gebt das Gerät reihum weiter. Nur die Person, die dran ist, schaut auf ihre Karte.“

1. Tippt auf die Zeile der Person, die gerade das Gerät hat. Die Zeile zeigt Spielernamen, Figur und Titel.
2. Es erscheint: „Gib das Gerät an {name}. Nur {name} schaut hin.“ Die Person tippt auf „Ich bin {name}, zeig her“. Mit „Zurück“ geht es zur Liste.
3. Jetzt liest die Person ihr Dossier. Die Abschnitte heißen „Wer ich bin“, „Was ich weiß“, „Was ich verberge“, „Mein Ziel heute Nacht“, „Meine Pflichtgespräche“ und „Meine Rundenwahl“.
4. Mit „Fertig, Bildschirm zudecken“ endet die Ansicht. Dann steht da: „Der Bildschirm ist wieder zugedeckt.“ Bei der Zeile erscheint ein Häkchen.
5. Wenn alle ihre Rolle gesehen haben, tippt auf **„Alle kennen ihre Rolle“**.

Jede Person sieht nur das eigene Dossier. Wenn ihr „Zum Drucken“ gewählt habt, steht auf dieser Seite zusätzlich die Tafel „Druckfassung“ (Teil 2).

### Der Ablauf

Die Abschnitte kommen in dieser Reihenfolge.

**Intro.** Der Erzähler stellt Schloss, Abend und Figuren vor. Oben steht „Geburtstag im Gewölbe“, darunter „Was vor Mitternacht geschah“. Mit „Die erste Runde beginnt“ geht es weiter.

- Im Intro gibt es drei kurze Rückblicke mit der Marke „Rückblick“. Sie gehören zu den Rollen Sibel, Olli und Hana: Sibel erschrickt vor der Ritterrüstung, Olli verläuft sich, Hana verqualmt den Kamin.
- Fragt vorher die Personen, die diese Rollen spielen, ob sie damit einverstanden sind.
- Ist eine dieser Rollen nicht besetzt, sagt der Erzähler „ein Gast“ statt des Namens.

**Drei Runden.** Jede Runde hat fünf Schritte. Die Runden heißen „Das Alibi-Geflecht“, „Die Indizien-Filterung“ und „Die finale Gegenüberstellung“.

1. **Rundenstart.** Oben steht „Runde {nr} von 3“ und der Name der Runde. Der Erzähler spricht den Rundenstart.
   - Die Uhr heißt „Zeit für diese Runde“. Ihre Knöpfe heißen „Uhr starten“, „Uhr anhalten“ und „Uhr zurücksetzen“. Ist die Zeit um, steht da „Die Zeit ist um.“
   - Die Uhr schaltet nichts weiter. Weiter geht es nur mit „Zur Ermittlung auf der Karte“.
   - Unter „Pflichtgespräche dieser Runde“ steht, wer mit wem spricht: „{sprecher} → {partner}“. Dazu steht das Thema. „Jede Person findet ihre Gespräche auch im eigenen Dossier.“
   - Die Gespräche führen die Personen am Tisch.
2. **Ermittlung auf der Karte.** Der Detektiv trifft in jeder Runde drei Entscheidungen. Oben steht „Entscheidung {nr} von 9“. Die Karte zeigt leuchtende Stellen und Personen.
   - „Steuern: Joystick, Pfeiltasten oder WASD.“
   - „Handeln: Knopf unten rechts oder Leertaste.“ Auch E und Enter lösen die Handlung aus.
   - Am Ziel steht, was man tun kann: „Befragen“ bei einer Person, „Untersuchen“ bei einem Gegenstand, „Absuchen“ bei einem Raum.
   - Ein Tipp macht erst einen Vorschlag. Die Entscheidung wird endgültig, wenn ihr auf „Ja, so machen wir es“ tippt. Die Seite sagt vorher: „Das ist endgültig. Danach gibt es in dieser Entscheidung keinen zweiten Versuch.“ Mit „Noch nicht“ kehrt ihr zurück.
   - Wollt ihr lieber aus einer Liste wählen, tippt auf „Aus einer Liste wählen“. Die Liste heißt „Wähle eine Möglichkeit“.
   - Ein Fund erscheint unter „Was du findest“. Mit „Verstanden“ schließt ihr ihn. Das „Notizbuch“ zeigt alle Funde. Ist es leer, steht da „Noch nichts gefunden.“
   - Nach der dritten Entscheidung steht da: „Alle drei Entscheidungen dieser Runde sind getroffen.“ Tippt auf „Weiter zur Gruppenwahl“.
3. **Gruppenwahl.** Jede Person wählt geheim. Das Geburtstagskind wählt nicht mit. Die Seite sagt: „Reihum wählt ihr geheim zwischen zwei Handlungen.“
   - Gebt das Gerät an die Person, die dran ist. Es erscheint: „Gib das Gerät an {name}. Nur {name} schaut hin.“ Die Person tippt auf „Ich bin {name}, zeig her“.
   - Es erscheinen zwei Karten. Die Person tippt eine an und bestätigt mit „Das ist meine Wahl“. Wer nicht wählen will, tippt auf „Fertig, Bildschirm zudecken“. Die Person bleibt dann offen.
   - Die Liste zeigt nur, wer schon gewählt hat („Schon gewählt“, „Noch offen“). Eine Stimmenzahl steht nie auf dem Bildschirm.
   - Wenn alle gewählt haben, steht da: „Alle haben gewählt. Es wird still im Gewölbe.“ Dann tippt auf „Weiter“.
4. **Bonus-Hinweis.** Unter „Was die Runde dem Geburtstagskind zuflüstert“ steht ein Hinweis. Der Hinweis sagt nie, ob er stimmt. Mit „Weiter“ geht es weiter.
5. **Zwischenresümee.** Es gibt drei Fächer: „Gruppenergebnis“, „Stand der Verdächtigen“ und „Lage“. Dann tippt auf „Nächste Runde“. Nach Runde 3 steht dort „Zur Anklage“.

**Anklage.** Die Seite heißt „Die Anklage“. Die Frage lautet „Wen klagst du an?“.

- Tippt eine der vier Personen an und dann auf „Anklagen“.
- Die Bestätigung sagt: „Das ist endgültig. Eine Anklage lässt sich nicht zurücknehmen.“
- Mit „Ja, ich klage an“ ist die Anklage fest. Dann tippt auf „Weiter“.

**Finale.** Die Seite heißt „Das Finale“. Unter „Die Rückblende“ spielt der Zeitraffer die Nacht nach. Mit „Rückblende noch einmal“ läuft er wieder. Danach liest der Erzähler den Schluss vor. Dann tippt auf „Weiter“.

**Auflösung.** Unter „Was wirklich geschah“ steht zu jeder besetzten Rolle ein Text. Er sagt, was die Figur wirklich getan hat. Mit „Weiter“ geht es zum Ende.

**Ende.** Unter „Das Ende“ stehen die Punkte („{punkte} von 9“), „Wer es war“ und der „Fall-Code“. Dazu steht: „Mit diesem Code startet derselbe Fall noch einmal genauso.“ Mit „Zurück ins Hauptmenü“ endet der Abend. Dazu steht: „Danke, dass ihr zusammen gegruselt und gelacht habt.“

### Erzählerstimme

- Auf den Seiten mit Erzählertext steht oben der Schalter „Erzählerstimme“. Der Tipp dazu lautet „Erzählerstimme an- oder ausschalten“.
- Mit „Noch einmal vorlesen“ liest der Erzähler den Text erneut.
- Gibt es auf dem Gerät keine deutsche Stimme, steht da: „Auf diesem Gerät gibt es keine deutsche Stimme. Der Text steht trotzdem da.“
- Bricht die Stimme einen langen Satz ab, hilft „Noch einmal vorlesen“.

### Wenn jemand ausfällt

- **Vor dem Start:** Stellt in der Einrichtung die neue Personenzahl ein. Die Rollen, die dann fehlen, bleiben als Figuren im Spiel. Ihre Karte sagt: „Diese Person spielt heute niemand. Die Karte sagt, was sie weiß.“
- **Nach dem Start:** Die Personenzahl lässt sich nicht mehr ändern. Die App kennt auch keinen Wechsel der Person mitten im Abend.
- Während des Spiels gibt es keinen Knopf zum Abbrechen. Der Partyabend speichert seinen Stand nicht. Wer die Seite neu lädt, beginnt von vorn.

### Fall-Code und ein zweites Mal spielen

- Der Fall-Code steht am Ende unter „Fall-Code“. Schreibt ihn auf.
- Gebt ihn bei der Einrichtung wieder ein. Dann ist es derselbe Fall.
- Ohne Code, also mit „Zufall“, entsteht ein neuer Fall.

### Vor dem Abend

- Fragt die Personen mit den Rollen Sibel, Olli und Hana vorher nach dem Intro-Rückblick (siehe oben).
- Testet die Karte auf dem Gerät, das ihr benutzt. Auf einem dunklen Beamer kann sie zu düster wirken.
- Wer den Fall schon einmal gespielt hat, weiß mehr als die anderen.

---

## Teil 2: Druckspiel

Beim Druckspiel liegt der Abend auf Papier. Der Bildschirm kann trotzdem mitlaufen. Er führt dann durch den Ablauf.

### Wann es sinnvoll ist

- Ihr wollt ohne Bildschirm am Tisch spielen. Der Abend läuft ganz ohne App.
- Ihr habt einen Drucker und wollt die Karten in der Hand halten.
- Ihr seid bereit, die Stimmen von Hand zu zählen. Das macht die Spielleitung mit Abreißstreifen und einer Tabelle.

### Die acht Dateien bekommen

Es gibt zwei Wege.

- **In der App:** Wählt bei der Einrichtung „Zum Drucken“. Auf der Seite „Eure Rollen“ steht dann die Tafel „Druckfassung“. Tippt auf „Druckfassung erstellen“. Dazu steht: „Die Druckfassung wird erstellt. Das dauert einen Moment.“ Danach gibt es für jede Datei einen Knopf. Der Download klappt in der Browser-Fassung. Sonst steht da: „Herunterladen geht nur in der Browser-Fassung.“
- **Per Befehl:** Das Team erstellt den Satz mit einem Befehl (Teil 3).

Der Satz besteht aus diesen Dateien:

| Knopf in der App | Dateiname | So steht es im Spielleitungsheft |
| --- | --- | --- |
| Spielleitungsheft | 00-spielleitung.pdf | Spielleitungsheft. Dieses Heft bleibt bei dir. |
| Detektivbogen | 01-detektivbogen.pdf | Detektivbogen mit Ermittlungsbogen. Gehört dem Geburtstagskind. |
| Rollenhefte | 10-rollenhefte.pdf | Rollenhefte. Je Person ein Heft mit der eigenen Rolle. |
| Fassungen der Kernrollen | 11-fassungen.pdf | Fassungen. Vier versiegelte Fassungen, außen steht nur ein Code. |
| Stimmkarten | 12-stimmkarten.pdf | Stimmkarten. Für jeden Gast je Runde zwei Karten, A und B, mit einem Streifen zum Abreißen. Die vier Kernrollen haben keine Stimmkarten, ihre Streifen stecken in der Fassung. |
| Indizkarten | 20-indizkarten.pdf | Indizkarten. Verdeckt, nach Code geordnet, bei dir. |
| Hinweis-Umschläge | 21-umschlaege.pdf | Hinweis-Umschläge. Geschlossen bei dir, je Runde drei Umschläge. |
| Auflösungsheft | 90-aufloesung-versiegelt.pdf | Auflösungsheft. Versiegelt. Erst nach der Anklage öffnen. |

### Vor dem Spiel: drucken und vorbereiten

1. **Einseitig drucken.** Druckt alle Dateien einseitig aus. Lest dabei nichts. Das Heft sagt: „Drucke alle Dateien einseitig aus und lies dabei nichts. Sortiere nur nach Nummern, Codes und Rollennamen.“
2. **Teile vorbereiten.** Das Spielleitungsheft steht unter „So bereitest du die Teile vor“:
   - **Indizkarten:** „Schneide jede Karte aus und falte sie an der gestrichelten Mittellinie. Vorn steht dann der Code, hinten der Fund. Leg sie mit dem Code nach oben bereit. Lies dabei nicht, was hinten steht.“
   - **Hinweis-Umschläge:** „Falte jedes Blatt an der gestrichelten Linie, sodass vorn der Code steht und hinten der Text. Wer mag, steckt es in einen echten Umschlag und schreibt den Code darauf. Lies dabei nicht, was hinten steht.“
   - **Fassungen:** „Jede Fassung hat vier Blätter. Leg sie mit der Schrift nach oben aufeinander, das Blatt mit dem Code obenauf. Knick den Stapel in der Mitte nach hinten, sodass der Code vorn bleibt, und klebe ihn zu, ohne hineinzusehen.“
   - **Stimmkarten:** „Schneide die Karten aus und leg sie zu den Rollenheften mit demselben Namen.“ Auf dem Abreißstreifen unten steht der Code und der Hinweis „Abreißen, falten und in die Schüssel legen.“
   - **Auflösungsheft:** „Leg alle Blätter mit der Schrift nach oben aufeinander, das Deckblatt obenauf. Knick den Stapel in der Mitte nach hinten und klebe ihn zu, ohne hineinzusehen.“

### Die Rolle der Spielleitung

Die Spielleitung ist eine eigene Person. Sie sollte nicht das Geburtstagskind sein. Das Spielleitungsheft bleibt bei ihr. Der Detektivbogen gehört dem Geburtstagskind.

Das Heft sagt der Spielleitung: „Lies die Texte mit der Marke Vorlesen genau so vor, wie sie dastehen. Alles andere ist Anleitung für dich.“

- **Zu Beginn:** Lest die Texte mit der Marke „Vorlesen“ vor.
- **Rollen und Fassungen:** „Gib jeder Person ihr Rollenheft und, wenn sie welche hat, ihre Stimmkarten.“ Legt dann die vier versiegelten Fassungen aus und nennt ihre Codes. „Wer einen dieser Codes im eigenen Heft findet, nimmt die Fassung und liest sie allein.“
- **Pro Runde:**
  1. **Rundenstart.** Lest den Rundenstart vor. Stellt die Uhr auf die Minuten, die das Heft nennt. Jede Rolle beginnt die drei Gespräche aus ihrem Heft. Wer angesprochen wird, antwortet aus der eigenen Rolle.
  2. **Entscheidungen.** Das Geburtstagskind wählt auf dem Detektivbogen. Ihr gebt die Indizkarte mit dem gewählten Code aus.
  3. **Gruppenwahl.** Jede Rolle gibt genau einen Streifen ab. Gäste reißen ihn von ihrer Karte A oder B ab. Die vier Kernrollen nehmen Streifen A oder B aus ihrer Fassung. Alle falten den Streifen und legen ihn in eine Schüssel.
     - „Nimm die Streifen einzeln heraus und such jeden Code in der Tabelle. Zähl die Werte zusammen und sag die Summe nie laut. Danach kommen die Streifen weg.“
     - Die Tabelle hat die Spalten „Code“ und „Wert“.
     - Die Tabelle unter der Gruppenwahl hat die Spalten „Summe“ und „Umschlag“.
     - Spielen nur die vier Kernrollen, gibt es keine Stimmkarten. Alle stimmen dann mit den Streifen aus ihrer Fassung; das Heft sagt es an dieser Stelle.
  4. **Umschlag.** „Öffne den Umschlag mit dem Code aus der Tabelle und lies ihn vor.“
  5. **Zwischenresümee.** Lest die Gruppe vor. Dann die Restmenge: Die Regeln stehen auf dem Detektivbogen, der Anhang „Anhang: Restmengen“ im Heft hat die Texte. Zuletzt die Lage: „Die Lage steht auf dem Bogen. Lies den Text vor, der dazu passt.“
- **Nach Runde 3 die Anklage.** „Nach Runde 3 liest du die Anklage vor. Das Geburtstagskind klagt eine der vier Verdächtigen an.“
  - „Dann öffnest du das Auflösungsheft. Dort stehen die richtigen Karten und die Endentabelle.“
  - „Vergleiche die Codes der gewählten Karten mit dem Auflösungsheft. Jede Übereinstimmung bringt einen Punkt.“
  - „Trage die Punkte auf dem Bogen ein. Dann liest du das Ende vor.“
  - Zum Schluss liest du im Auflösungsheft „Auflösung für alle“ vor und danach „Die Rollen am Tisch“.

### Die Fassungen der vier Verdächtigen

- Die Datei mit den Fassungen enthält vier versiegelte Fassungen. Außen steht nur ein Code: „Versiegelt. Erst öffnen, wenn die Spielleitung diesen Code nennt.“
- Jede Kernrolle findet ihren Code im eigenen Rollenheft. Wer den Code findet, nimmt die Fassung und liest sie allein.
- Die Kernrollen haben keine Stimmkarten. Ihre Streifen A und B stecken in der Fassung. Auf der Fassung steht: „Du hast keine Stimmkarten. In jeder Runde gibst du genau einen Streifen von dieser Seite ab.“ Unter jedem Streifen steht: „Nur wenn gewählt: abreißen, in die Schüssel.“
- Im Rollenheft steht: „Deine Fassung trägt den Code … Öffne sie erst, wenn die Spielleitung diesen Code nennt.“
- Die Fassungen faltet ihr nach dem Heft, ohne hineinzusehen.

### Das versiegelte Auflösungsheft

- Das Auflösungsheft ist versiegelt. Dort steht: „Versiegelt – erst nach der Anklage öffnen“.
- Es enthält die richtigen Karten, die Endentabelle, „Auflösung für alle“ und eine Codeliste.
- Die Spielleitung öffnet es erst nach der Anklage.

### Bekannte Grenzen

- **Ausschneiden.** Wer beim Ausschneiden die Rückseiten liest, kann Funde und Fassungen lesen. Druckt einseitig, sortiert nur nach Codes und lasst jemanden ausschneiden, der nicht das Geburtstagskind ist.
- **Dauer.** Das Spielleitungsheft nennt die Rundendauer, die bei der Einrichtung gewählt war. Per Befehl gilt die Vorgabe von 30 Minuten, außer ihr gebt `--dauer` an.
- **Rückblende.** Den Zeitraffer im Finale gibt es nur am Bildschirm. Im Druck steht die Rückblende als Text im Auflösungsheft.
- **Die Summe.** Die Spielleitung sagt die Summe nie laut.

---

## Teil 3: Für Entwickler

### Werkzeugkette

- Flutter 3.47.6. Die Version steht in `build.sh` (Zeile 5) und in `.werkzeug/flutter/bin/cache/flutter.version.json`.
- Das SDK liegt in `.werkzeug/flutter`, der Pub-Cache in `.werkzeug/pub-cache`. `.werkzeug/` steht in `.gitignore`.
- Vor jedem Befehl im Repo: `source .werkzeug/env.sh`. Das setzt `FLUTTER_ROOT`, `PUB_CACHE` und `PATH` und schaltet die Analytics ab.
- `build.sh` baut die Web-Fassung mit `--no-web-resources-cdn`. CanvasKit kommt dann aus dem eigenen Build, nicht von `gstatic.com`.
- Node 22 wird für die E2E-Läufe gebraucht. Chromium steht laut `tool/e2e/README.md` unter `/opt/pw-browsers/chromium-1194/chrome-linux/chrome`.
- Läuft das Flutter-Werkzeug als root, meldet es eine Warnung. Die Befehle laufen trotzdem.

### Aufbau

| Ort | Inhalt |
| --- | --- |
| `content/party/schlosskeller/` | Kanon als JSON je Bereich, zum Beispiel `fall.json`, `figuren.json`, `setting.json`, `raeume.json`, `entscheidungen.json`, `gruppenwahl.json` und `tatmatrix/`. Erzeugt werden `STORY-BIBEL.md` und `bildprompts.json`. |
| `content/party/schlosskeller/texte/` | Textsammlung. `index.json` listet alle Dateien. `SCHLUESSEL.md` erklärt Kennungen und Regeln. |
| `content/party/schema/` | Schemas je Kanon-Datei. Geprüft im Test `kanon_schema_test.dart`. |
| `content/party/textregeln.json`, `content/party/farbnamen.json` | Regeln für den Textprüfer und Farbnamen. |
| `packages/mordakte_core/lib/src/party/` | Logik: `ablauf.dart` (Phasen), `besetzung.dart`, `texte.dart`, `gruppenwahl.dart`, `karte.dart`, `simulator.dart`, `plausibilitaet.dart`, `bibel.dart`, `erzaehler.dart` und `druck/` für den PDF-Satz. |
| `packages/mordakte_core/bin/` | Werkzeuge `party_*.dart`. |
| `packages/mordakte_core/test/party/` | Kern-Tests, zum Beispiel `druck_test.dart`, `spoiler_test.dart`, `simulator_test.dart`, `texte_test.dart`. |
| `lib/party/` | App. `sitzung.dart` ist der Zustand und die Schnittstelle. `party_seite.dart` ordnet jeder Phase einen Bildschirm zu. `bildschirme/` enthält je Abschnitt einen Bildschirm. Dazu `karte_session.dart`, `druck_tafel.dart`, `erzaehler_ausgabe.dart` und `skript.dart` für den Entwickler-Einstieg. |
| `test/party_widgets/` | Widget-Tests der Bildschirme. |
| `tool/e2e/` | Automatische Durchläufe im Browser. |

### Regeln im Code

- Bildschirme erzeugen keinen Text. Oberflächentexte kommen mit `sitzung.ui('ui.…')` aus `texte/ui*.json`. Erzähltexte kommen mit `sitzung.text(…)` aus den Bausteinen (`sitzung.dart`).
- Was nur eine Person sehen darf, gibt es nur in der verdeckten Ansicht: `zeigeVerdeckt`, `dossier`, `wahl` und `istTaeter` (`sitzung.dart`). Vor dem Finale verrät keine andere Methode den Täter-Pfad.
- Der Erzähler spricht nur Texte vor, die wortgleich zum Baustein sind (`erzaehler_ausgabe.dart`, Funktion `wortgleich`).
- Erzählerbausteine haben Kennungen aus `Erzaehler.katalog()` (`packages/mordakte_core/lib/src/party/erzaehler.dart`). Andere Kennungen sind dort verboten.
- Lacher stehen in `setting.json` unter `lacher`. Jeder hat eine `id` und ein Feld `wer` mit der Figur-Kennung. Die Kennung bleibt, auch wenn sich der Anzeigename ändert. Zum Beispiel heißt `selin` im Spiel Sibel und `meryem` Hana (`figuren.json`).
- Die Texte der Lacher stehen in `texte/erzaehler-intro.json` als `intro.lacher.<id>.besetzt` und `intro.lacher.<id>.npc`. `erzaehler.dart` wählt je nach Besetzung die Fassung mit Namen oder mit „ein Gast“.
- Das Feld `herkunft` in `figuren.json` dient nur der Prüfung (`herkunft_test.dart`).
- Figurenfarben stehen als `colorCode` in `figuren.json`. Der Farbabstandstest `farbabstand_test.dart` prüft die Abstände.
- Die Helligkeit der Karte steht in `lib/party/karte_session.dart` (`dunkel: 0.77`).
- Die Tasten stehen in `lib/game/mordakte_game.dart`: W, A, S, D und Pfeiltasten bewegen, E, Leertaste und Enter handeln.
- Der Partymodus speichert nichts im Browser. Der Stand liegt nur im Speicher der Seite.

### Prüfwerkzeuge

Die Befehle laufen im Ordner `packages/mordakte_core`, nach `source .werkzeug/env.sh`. Die Ausgaben gelten für einen sauberen Stand vom 10.10.2026.

| Befehl | Was er prüft oder tut | Ausgabe bei sauberem Stand |
| --- | --- | --- |
| `dart test` | Alle Kern-Tests: Kanon-Schema, Texte, Plausibilität, Simulator, Druck, Besetzung von 4 bis 20 Personen, Spoilerschutz, Farbabstand. | „All tests passed!“ (396 Tests, rund 2 Minuten) |
| `dart test test/party/texte_test.dart` | Nur die Textprüfung: Verweise und Regeln. | „All tests passed!“ (11 Tests) |
| `dart run bin/party_texte.dart` | Textprüfer. Prüft Wortgleichheit des Erzählers, Inhaltsregeln, Lesbarkeit und Fachwörter. | „Texte: OK (1601 Texte)“ |
| `dart run bin/party_pruefen.dart` | Plausibilitätsprüfer für alle Pfade: Tatmatrix, Wege, Wahrnehmung. Optionen: `--matrix <pfad>` gibt die Matrix als Markdown aus, `--wissen` zeigt, wer was weiß. | „Plausibilität: OK (4 Pfade, 22 Personen)“ |
| `dart run bin/party_simulate.dart` | Fall-Simulator: Bericht über alle Pfade, Entscheidungen und Anklagen. Mit `--pruefen` nur die Prüfung, Exitcode 1 bei Verstoß. | „Simulator: OK (329 ms)“ |
| `dart run bin/party_bibel.dart` | Schreibt `content/party/schlosskeller/STORY-BIBEL.md`. Mit `--pruefen` nur der Vergleich, es wird nichts geschrieben. | „Story-Bibel ist aktuell“ |
| `dart run bin/party_prompts.dart` | Schreibt `content/party/schlosskeller/bildprompts.json`. Mit `--pruefen` nur der Vergleich. | „Bildprompts: aktuell (42 Prompts)“ |
| `dart run bin/party_druck.dart --code XXXXX --n 7 --detektiv w --dauer 30 --aus <Ordner>` | Erzeugt den PDF-Satz mit acht Dateien. Ohne `--aus` landet er in `build/druck/<Code>-n<Zahl>`. Die Vorgaben sind `--n 12`, `--detektiv w` und die Rundendauer aus `fall.json` (30 Minuten). `--pfad` (ahmet, fatma, olli, can) ist nur für Testläufe gedacht. | Acht Dateien, dann „Druckspiel <Code> für 7 Rollen und das Geburtstagskind in <Ordner>“ |
| `flutter test test/party_widgets` (im Repo-Wurzelordner) | Widget-Tests der Bildschirme. | „All tests passed!“ (129 Tests, rund 55 Sekunden) |
| `tool/pruefen.sh schnell`, `alles` oder `e2e` | Gesamtprüfung. `schnell`: Pakete, Analyse, Kern-Tests. `alles` zusätzlich: Szenario-Validator, alle Partymodus-Prüfungen, Server-Smoke, Flutter-Tests und Web-Build ohne CDN. `e2e` zusätzlich die E2E-Läufe. Am Ende läuft immer der Secret-Scan. | „Alle Prüfungen bestanden (<Stufe>).“ |
| `npm test` im Ordner `tool/e2e` (ruft `node e2e.mjs` auf) | Spielt den Abend im Browser vom Titel bis zum Ende durch. Braucht den Web-Build in `build/web` und Chromium. Optionen: `--nur pfad=ahmet,n=4`, `--parallel 1` und `--negativtest`. | Berichte in `tool/e2e/fotos/` (ignoriert durch Git) |
| `tool/secret_scan.sh` | Secret-Scan. Prüft, dass nichts aus `quellen/` im Verlauf steckt, keine Chat-Kopfzeilen, keine Schlüsselmuster, keine `.env`-Dateien und keine langen wörtlichen Chat-Passagen. Er ruft Git-Befehle auf. | „Secret-Scan: sauber“ |

Der Secret-Scan läuft vor jedem Push.

### Entwickler-Einstieg

Der Partymodus öffnet sich mit `?party=schlosskeller` an der App-Adresse. Das steht in `lib/main.dart`. Die weiteren Parameter stehen in `lib/party/skript.dart`:

- `code=<Fall-Code>` oder `pfad=<ahmet, fatma, olli oder can>`: Fall-Code oder Täter-Pfad, nur für Testläufe. Der Pfad legt den Täter fest.
- `n=<Zahl>`: Personenzahl ohne Geburtstagskind. Vorgabe ist 7.
- `detektiv=m` oder `w`: Vorgabe ist `w`.
- `dauer=<Sekunden>`: Rundendauer in Sekunden, für schnelle Tests.
- `skript=<Entscheidungen>,<Gruppe>,<Anklage>`: Entscheidungen `best`, `schlecht` oder `erste`. Gruppe `a`, `b` oder `gemischt`. Anklage `richtig`, `falsch` oder eine Kennung. Vorgabe: `best,a,richtig`.
- `takt=<Millisekunden>`: Pause zwischen zwei Schritten. Vorgabe ist 700.
- `zeitraffer=<Zahl>`: Spielsekunden je echter Sekunde in der Rückblende.
- `fotos=0`: Fotostellen nur melden, ohne zu warten.
- `fotopause=<Millisekunden>`: Wartezeit an einer Fotostelle. Vorgabe ist 1200.
- `bis=<Phase>`: Ohne Skript bis zu dieser Phase vorspielen. Die Phasen heißen `titel`, `einrichtung`, `rollen`, `intro`, `gespraeche`, `entscheidungen`, `gruppenwahl`, `bonus`, `resuemee`, `anklage`, `finale`, `aufloesung` und `ende`.
- `at=x,y` und `zoom=<Zahl>`: Startposition des Detektivs und Zoom der Karte.
- `semantik=1`: Bedienhilfen für E2E-Klicks.

Beispiele:

```
?party=schlosskeller&n=7&detektiv=w&skript=best,a,richtig&dauer=20&takt=700&zeitraffer=60
?party=schlosskeller&n=7&bis=anklage
```

Während eines Skript-Laufs schreibt die Konsole Zeilen mit dem Präfix `PARTY`, zum Beispiel `PARTY phase=…` und `PARTY foto=…`.

### Texte ändern

1. **Datei finden.** `content/party/schlosskeller/texte/index.json` listet alle Dateien. Oberflächentexte stehen in `ui*.json` mit Kennungen `ui.…`. Erzählertexte stehen in `erzaehler-*.json`. Dossiers stehen in `dossiers-b*.json`, Pflichtgespräche in `gespraeche-*.json`, Rundenwahlen in `wahlen-*.json` und Täterfassungen in `taeter-<pfad>.json`.
2. **Kennungen beachten.** Ändert keine Kennung und vergebt keine doppelt. Bei einer Doppelung gilt der erste Eintrag, und die Prüfung wird rot (`SCHLUESSEL.md`).
3. **Ton und Regeln.** Der Ton steht im `TON-LEITFADEN.md` im Planungsordner `planung/finalisierung-schlosskeller/`. Die Regeln für den Textprüfer stehen in `content/party/textregeln.json`.
4. **Prüfen.**

   ```
   source .werkzeug/env.sh
   cd packages/mordakte_core
   dart run bin/party_texte.dart
   dart test test/party/texte_test.dart
   ```

5. **Kanon ändern.** Ändert ihr Dateien außerhalb von `texte/`, prüft das Schema mit `dart test` und danach:

   ```
   dart run bin/party_pruefen.dart
   dart run bin/party_simulate.dart --pruefen
   dart run bin/party_bibel.dart
   dart run bin/party_prompts.dart
   dart run bin/party_bibel.dart --pruefen
   dart run bin/party_prompts.dart --pruefen
   ```

   Die Befehle ohne `--pruefen` schreiben die Dateien `STORY-BIBEL.md` und `bildprompts.json` neu.

### Grenzen

- Im Browser lassen sich die Kanon-Dateien über die Entwicklerwerkzeuge lesen. In einer lokalen Web-App lässt sich das nicht verhindern (E-013).
- Die Web-Fassung wird durch `--no-web-resources-cdn` größer. Laut FÜR-DEN-NUTZER sind es etwa 37 MB.
- Die Erzählerstimme nutzt nur lokale Stimmen des Browsers.
