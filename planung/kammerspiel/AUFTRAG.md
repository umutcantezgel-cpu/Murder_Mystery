# Auftrag des Besitzers (wörtlich) und seine Entscheidungen

## Entscheidungen (AskUserQuestion, 2026-11-01)
- Das neue Pen-&-Paper-Druckspiel **ersetzt das bisherige Druckspiel** in der Druckmappe (Stimmkarten, Umschläge, alter Rollenheft-Aufbau verschwinden aus dem Druck). Das Spiel in der App (Bildschirm, Solo, reihum, online, „Dein Moment“) bleibt unverändert.
- **Fester Fall: Olli ist der Täter** (Fall U4YRK). Alle Domino-Ketten, Karten und Geständnisse sind auf Olli zugeschnitten.
- **Auslieferung in der App-Druckmappe** („PDFs zum Ausdrucken“), zusätzlich per Befehl im Repo; Probe-Sets für 6, 10 und 20 Personen an den Besitzer.

## Auftrag (wörtlich)

# AUFTRAG: Komplett-Refactoring des Krimispiels „Spuk im Schlosskeller“ (Fall-Code: U4YRK) zu einem interaktiven Pen-&-Paper-Murder-Mystery (Stil: „Knives Out“)

Du bist ein erfahrener Game-Designer für interaktive Krimispiele / Pen-&-Paper-Rollenspiele und Senior-Entwickler für automatisierte Druck-PDF-Generierung. Deine Aufgabe ist es, den bestehenden Quellcode und die gesamten Spieltexte von **„Spuk im Schlosskeller“ (Fall-Code: U4YRK)** vollständig zu überarbeiten, alle logischen und mechanischen Schwächen zu beheben und ein ausdruckbares, sofort spielbares Komplett-PDF-Set ohne Lücken oder Widersprüche zu generieren.

---

## 1. DESIGN-ZIEL & TONFALL
- **Vibe & Tempo:** Dynamisches, hochgradig interaktives Kammerspiel im Stil von *Knives Out* kombiniert mit *Pen & Paper*-Einflussmöglichkeiten.
- **Keine Fronterzählung & kein Detektiv-Alleingang:** Keine minutenlangen Vorlesemonologe des Erzählers, keine Papageien-Dialoge (in denen Rollen 3 Runden lang denselben Satz vorlesen) und keine „Auto-Solve“-Indizkarten, die Spieler-Geständnisse vorwegnehmen, ohne dass mit dem Spieler gesprochen wurde.
- **Spieleranzahl:** Flexibel skalierbar für **6 bis 20 Personen** nach einem sauberen Zwiebel-Prinzip.

---

## 2. DIE ROLLE DES „ERZÄHLERS“ (NICHT-ALLWISSENDER GAMEMASTER)
- Die Rolle heißt weiterhin **„Erzähler“**.
- **WICHTIG:** Der Erzähler ist **nicht-allwissend**! Er kennt den Täter (Olli) vorab NICHT, damit er selbst miträtseln kann. Das Auflösungsheft (Teil 90) bleibt bis nach der finalen Anklage versiegelt.
- **Vom Vorleser zum Moderator:**
  1. Das Erzählerheft enthält kurze, lebendige Moderations-Anweisungen statt endloser Vorlesetexte.
  2. Der Erzähler leitet die **Ping-Pong-Vorstellungsrunde**: Er liest für jede Rolle nur eine kurze, humorvolle Anspielfrage (1–2 Sätze) vor, woraufhin sich der jeweilige Spieler mit seinem eigenen Text im Rollenheft selbst vorstellt.
  3. Er verwaltet das **Evidence Board (Lageplan)** in der Tischmitte und fordert die Spieler auf, ihre Positions-Marker zu setzen und bei enttarnten Lügen anzupassen.
  4. **Spoilerfreie Moderations-Impulse im Erzählerheft:** Für jede der 3 Runden bekommt der Erzähler 3–4 „Moderations-Tipps bei Gesprächsflaute“ (z. B.: *„Falls Fatma weiterhin behauptet, am linken Buffet gestanden zu haben, bitte Emine oder Zeynep, genau zu beschreiben, was ihnen an Fatma vor dem Knall aufgefallen ist.“*). Diese Impulse verraten dem Erzähler nicht die Lösung, halten aber den Domino-Effekt am Laufen.
  5. Der Erzähler gibt vor der Auflösung wie alle anderen Spieler einen eigenen geheimen Täter-Tipp ab.

---

## 3. ÜBERTRAGUNG DER „GEISTER-NPCS“ AUF DIE TOP-10-ROLLEN & SKALIERUNG (6–20 SPIELER)

### A. Streichung aller imaginären Zeugen im Kernspiel (Top 10)
Im bisherigen Spiel lieferten fiktive NPCs (Azra, Damir, Aylin, Tugba, Wojtek) die wichtigsten Beweise. Im neuen System werden alle Beobachtungen dieser NPCs fest in die Rollen 5 bis 10 integriert:
1. **Ahmet (Rolle 1 – Verdächtiger, Fassung WW4):** Hat von allen 150 € für eine angebliche Saalmiete kassiert, obwohl der Keller kostenlos war, um seine viel zu große Catering-Bestellung bei Marek zu bezahlen. Schlüpfte um 23:57 Uhr mit dem Geldumschlag hinter die Theke zu Herrn Schneider. Duckte sich beim Knall & Scheppern am Ostende der Theke neben Marek. Warf den leeren Umschlag um 00:12 Uhr in den Ascheneimer am Kamin.
2. **Fatma (Rolle 2 – Verdächtige, Fassung JM3):** Nahm um 23:40 Uhr heimlich die Münzschatulle aus der bereits gesprungenen Schauvitrine im Turmgang (wollte nur das Wappen abzeichnen und sie am Montag zurückbringen). Schneider entdeckte um 23:56 Uhr einen Glassplitter an ihrem Mantel und drohte mit der Polizei um Punkt zwölf. Ging um 23:57 Uhr zur Theken-Klappe, um die Schatulle zurückzugeben. Zog sich beim Knall zum linken Buffettisch zurück und kauerte dort beim Scheppern neben Emine.
3. **Olli (Rolle 3 – Verdächtiger & TÄTER, Fassung RN7):** Riss um 18:35 Uhr beim Tragen der Warmhaltebehälter (zusammen mit Tim) den Beschlag der Bogentür aus der gekalkten Wand und schmierte die Schramme mit Tims braunem Möbelwachs zu. Schneider forderte um 23:00 Uhr 2.000 € Schadensersatz bis Mitternacht, sonst Polizei. Ging um 23:57 Uhr zum Eiskübel vor der Theke (Eis für Tims gequetschten Finger holen + mit Schneider reden). Wurde im Dunkeln nach dem Knall (23:58 Uhr) von Schneider am Ärmel gepackt, schlug in Panik mit dem Messingkerzenständer zu (das laute Scheppern ca. 30 Sek. nach dem Knall; weißer Wandkalk & Holzsplitter von seinem Ärmel blieben im weichen roten Wachs am Fuß des Kerzenständers kleben; rote Wachstropfen fielen auf seinen rechten Arbeitshandschuh in der Westentasche). Riss Schneiders Schlüsselbund ab, versteckte ihn unter den Eiswürfeln im Eiskübel und schlich erst *nach* dem Scheppern zu Lejla an den rechten Buffettisch.
4. **Can (Rolle 4 – Verdächtiger, Fassung YW4):** Schlich um 23:54 Uhr mit einer grünlich-weißen Leuchtmaske in den dunklen Vorratsraum hinter der Theke, um um Mitternacht die „blinde Kuh“ zu erschrecken. Schwester Zeynep stand am Bogen zum Durchgang Schmiere. Sprang um 23:58 Uhr (direkt beim Knall) aus dem Vorratsraum, als Schneider die Notlaterne holen wollte. Schneider packte ihn an der Kapuze („Hab ich dich!“), Can riss sich los und rannte *vor* dem Scheppern durch den Durchgang in den Kaminsaal (stopfte die Maske in die Bauchtasche) und weiter auf die Turm-Toilette.
5. **Lejla (Rolle 5 – Gast / Apothekerin & Ahmets Cousine):**
   - *Übernimmt Ex-Geist Aylin & Azra (Teil 1):* Weiß von Ahmets Catering-Rechnungsproblem und hat bei der Buffet-Planung Herrn Schneiders Quittungszettel („Miete Schlosskeller: 0 Euro“) gesehen. Sah Ahmet um 23:57 Uhr mit dickem Umschlag hinter die Theke schlüpfen. Außerdem kauerte Lejla beim Knall am **rechten Buffettisch** und weiß sicher: Beim lauten Scheppern war Olli noch NICHT da – Olli kam erst *nach* dem Scheppern im Dunkeln zu ihr gekrochen und flüsterte „Lejla? Ich bin’s, Olli.“
6. **Emine (Rolle 6 – Gast / Grundschullehrerin & Fatmas beste Freundin):**
   - Sah um 23:40 Uhr im Turmgang, wie Fatma die Münzschatulle aus der Vitrine nahm, und hörte um 23:56 Uhr Schneiders Drohung („Um Punkt zwölf rufe ich die Polizei“). Lag beim Knall UND beim Scheppern hinter dem **linken Buffettisch**, wo Fatma direkt neben ihr kauerte („Emine? Ich bin’s, Fatma“).
7. **Tim (Rolle 7 – Gast / Hobby-Elektriker & Ollis Berufsschul-Kumpel):**
   - *Übernimmt Ex-Geist Wojtek:* Verursachte um 23:58 Uhr den Knall/Stromausfall, weil er trotz Schneiders Warnung die Kaffeemaschine für den Tortenkaffee in seine alte Mehrfachsteckdose steckte. Eilte im Dunkeln zum Sicherungskasten (sah dort das leuchtende Gesicht vorbeihuschen) und schaltete um 00:00 Uhr das Licht wieder ein. **Zudem:** Half Olli um 18:30 Uhr beim Tragen der Behälter durch die Bogentür, klemmte sich später den Finger (weshalb Olli ihm um 23:52 Uhr versprach: „Ich hol dir Eis, und dann red ich mit Schneider“) und lieh Olli das braune Möbelwachs aus seinem Werkzeugkasten!
8. **Joanna (Rolle 8 – Gast / Fotografin des Abends):**
   - *Übernimmt Ex-Geist Tugba:* Fotografierte um 23:51 Uhr heimlich den Streit zwischen Schneider und Ahmet (mit dickem Umschlag) an der Theke. Zudem suchte sie um 23:55 Uhr alle Gäste für das Mitternachts-Gruppenfoto bei der Torte zusammen und machte sich auf ihrem Handy-Notizblock eine exakte Checkliste, wer um 23:57 Uhr an der Theke stand (Ahmet, Fatma, Olli am Eiskübel, Schneider am Ostende) und dass Can nirgends zu sehen war.
9. **Marek (Rolle 9 – Gast / Caterer):**
   - *Übernimmt Ex-Geist Damir:* Lieferte um 18:30 Uhr das Essen (parkte auf Schneiders reserviertem Parkplatz) und wartet darauf, dass Ahmet ihm noch heute Abend 150 € Nachzahlung für das zu groß bestellte Buffet bar bezahlt. Stand kurz vor zwölf beim Saft am Ostende der Theke: Bezeugt, dass Ahmet sich beim Knall direkt neben ihm am Ostende der Theke duckte („Marek? Ich bin’s, Ahmet“) und auch beim Scheppern dort neben ihm kauerte (Ahmets Alibi!). Zudem sah Marek an der Schwelle zum Durchgang, dass das leuchtende Gespenstergesicht bereits **vor dem lauten Scheppern** an ihm vorbei in Richtung Kaminsaal rannte (Cans Alibi!).
10. **Zeynep (Rolle 10 – Gast / Fußballtrainerin & Cans Schwester):**
    - *Übernimmt Ex-Geist Azra (Teil 2):* Stand ab 23:54 Uhr für Cans Streich am Bogen zum Durchgang Schmiere. Sah um 23:45 Uhr Fatmas auffällig ausgebeulte Umhängetasche. Sah im Dunkeln direkt nach dem Knall (noch vor dem Scheppern!), wie Can mit dem leuchtenden Gesicht aus dem Durchgang an ihr vorbei in den Kaminsaal stürmte, während hinter ihm an der Theke noch jemand mit Herrn Schneider stritt.

### B. Skalierungs-Mechanik (Zwiebel-Prinzip für 6 bis 20 Personen)
- **6 bis 9 Spieler:** Wenn Rollen aus den Plätzen 5–10 unbesetzt bleiben, generiert der Code ein 1-seitiges **„Abwesenheits-&-Spuren-Blatt für kleine Runden“**, auf dem die Aussagen der nicht mitspielenden Rollen 5–10 als Zeugenprotokolle bei den jeweiligen Orten auf dem Lageplan ausliegen.
- **10 Spieler (Standard):** Erzähler + Detektiv + Rollen 1–8, oder (wenn Erzähler = Detektiv bzw. 10 Rollen + Detektiv + Erzähler = 12) exakte Zuteilung.
- **11 bis 20 Spieler (Modulare Zusatzrollen 11–18: Azra, Damir, Aylin, Tugba, Wojtek, Hana, Sibel, Serkan):**
  Erstelle im Code/PDF für diese 8 optionalen Zusatzrollen kompakte, vollwertige **Zusatz-Rollenhefte + eigene Handlungskarten**, die in 4 Tandem-Paaren eigene verdeckte Mini-Intrigen des Abends ausspielen (und jeweils 1 bestätigendes Rand-Indiz zum Hauptfall kennen, das sonst die Rollen 5–10 allein tragen):
  - *Tandem 1 (Sibel & Damir – Das Vitrinen-Missgeschick um 21:00 Uhr):* Sibel erschrak im Turmgang vor der Ritterrüstung und stieß rückwärts gegen die Schauvitrine (Sprung im Glas); Damir half ihr, die Scherben unter den Teppich zu kehren.
  - *Tandem 2 (Hana & Serkan – Das Kamin-Desaster um 23:30 Uhr):* Hana wollte heimlich einen Liebesbrief im Kamin verbrennen, ohne die Kaminklappe zu öffnen (Rauch im Kaminsaal); Serkan riss die Lichtschächte auf und versteckte am Auto eine Überraschungstorte/Wunderkerzen.
  - *Tandem 3 (Azra & Wojtek – Der falsche Alarm um 20:15 Uhr & der Werkzeugkasten):* Wojtek brachte die Musikboxen mit und lieh Tim den Werkzeugkasten mit dem Möbelwachs; Azra beobachtete um 00:12 Uhr Ahmet am Ascheneimer des Kamins.
  - *Tandem 4 (Aylin & Tugba – Die Schlüssel-&-Gästeliste):* Aylin half Herrn Schneider beim Einlass und weiß, wo die Ersatz-Sicherungen und Putzmittel liegen; Tugba führte Buch über die Spiele-Punkte des Abends und sah Olli mit dem rußigen linken Arbeitshandschuh am Kamin.

---

## 4. NEUER SPIELABLAUF & MECHANIKEN (IM CODE UMZUSETZEN)

### 1. Einstieg: Ping-Pong-Vorstellung & Live-Anekdoten (Statt Vorlese-Wüste)
- Kürze die Vorgeschichte des Erzählers auf maximal 1 Seite (knackige Atmosphäre: Altes Schloss, Gewölbekeller ohne Handyempfang, Hausmeister Schneider, Wiedersehen der Clique).
- **Ping-Pong-Vorstellung:** Im Erzählerheft steht zu jeder Rolle nur eine kurze Anmoderation + Frage (z. B. an Olli: *„Olli, du bist der Mann fürs Grobe bei jedem Umzug – warum bist du heute schon um Viertel nach acht fast in die Mitternachtstorte gefallen?“*). Im Rollenheft des Spielers steht ganz oben unter **„Dein Auftritt bei der Vorstellung“** eine kurze, witzige Antwort in der Ich-Form (inklusive der jeweiligen Anekdote aus den früheren Dias 3, 4 und 5!).
- Danach liest der Erzähler den Tat-Moment vor (23:58 Uhr Knall -> Dunkelheit -> 30 Sek. später lautes Scheppern an der Theke -> 00:00 Uhr Licht geht an -> Herr Schneider liegt bewusstlos mit Platzwunde im Vorratsraum, Schlüsselbund ist weg, Außentor verschlossen).

### 2. Das „Evidence Board“ (Lageplan + Positions-Marker) – PFLICHTBESTANDTEIL
Generiere im PDF-Code eine eigene, übersichtlich gestaltete Doppelseite **„Lageplan: Gewölbekeller unter dem Schlossturm“** (zum Auflegen in der Tischmitte) sowie einen Bogen mit **ausschneidbaren Positions-Markern** für alle Rollen:
- Eingezeichnete Zonen auf dem Lageplan:
  1. **Ost-Saal** (Lange Tafel, Jackenständer)
  2. **Buffetsaal – Linkes Buffet** (Gebäck, Thermoskanne)
  3. **Buffetsaal – Rechtes Buffet** (Warmhaltebehälter)
  4. **Theke & Anrichte** (Westende mit Theken-Klappe & Eiskübel, Kerzenständer, Ostende mit Saft/Servietten)
  5. **Vorratsraum** (Hinter der Theke: Mitternachtstorte, Notlaterne, Fundort Herr Schneider)
  6. **Durchgang mit Steinbogen** (Verbindung zwischen Theke/Buffetsaal und Kaminsaal, Sicherungskasten)
  7. **Kaminsaal** (Kamin mit Ascheneimer & Nische, Wandbänke)
  8. **Turmgang & Turm** (Bogentür mit beschädigtem Beschlag, Ritterrüstung, Schauvitrine, Treppe zur Turm-Toilette)
- **Spielmechanik am Board:** Zu Beginn von Runde 1 muss jeder Spieler seinen Marker auf das Feld stellen, wo er beim Knall/Scheppern angeblich war (Olli stellt sich in den Ost-Saal, Can auf die Turm-Toilette, Fatma ans linke Buffet usw.). Sobald im Spielverlauf eine Lüge durch Zeugen oder Beweise geknackt wird, muss der Marker vor aller Augen auf den wahren Aufenthaltsort umgestellt werden!

### 3. Das 2-Stufen-Antwortsystem in den Rollenheften (Statt starrer Wiederholungen)
Entferne die sich wiederholenden 1-Satz-Antworten aus den Runden 1–3. Jedes Rollenheft erhält pro Runde klare, interaktive Gesprächsleitlinien nach dem **2-Stufen-Prinzip**:
- **Aktive Tischgesprächs-Aufträge:** Jede Rolle bekommt pro Runde 2 konkrete Nachbohr-Ziele gegenüber anderen Mitspielern (mit echten Fragen und Vorwürfen statt belanglosem Smalltalk).
- **Stufe 1 (Deine Tarn-Aussage / Solange dir nichts bewiesen wird):** Was der Spieler behauptet, wenn der Detektiv oder andere Gäste ihn befragen.
- **Stufe 2 (Wenn du unter Druck gerätst / Konfrontations-Trigger):** Eine glasklare Bedingung (*„Sobald jemand [konkreten Hinweis/Zeugenaussage/Beweiskarte] gegen dich auf den Tisch legt, gibst du dein Teil-Geheimnis zu:“*), gefolgt von der wahren Aussage UND einem **neuen Domino-Hinweis**, der eine andere Rolle am Tisch unter Druck setzt!
- *Wichtig für Olli (Täter):* Olli hat drei Stufen:
  - Stufe 1: Behauptet, durchgehend im Ost-Saal gesessen zu haben.
  - Stufe 2 (wenn Joannas Liste, Fatmas/Ahmets Aussage um 23:57 Uhr am Eiskübel oder Lejlas Aussage über seine späte Ankunft am rechten Buffet aufgedeckt wird): Gibt zu, kurz vor zwölf am Eiskübel gewesen zu sein und wegen der beschädigten Bogentür (2.000 €) mit Schneider gestritten zu haben – behauptet aber, er habe sich beim Knall sofort geduckt, während das leuchtende Gespenst (Can) aus dem Vorratsraum auf Schneider losging!
  - Stufe 3 (erst bei der finalen Anklage, wenn Kerzenständer `XD3`, Handschuh `FN3` und Schlüssel im Eiskübel `PP9` zusammenkommen): Das finale Geständnis.

### 4. Handlungskarten statt A/B-Schnipsel-Schüssel
STREICHE die alten Stimmkarten A/B mit den kryptischen Code-Tabellen (`DC3`, `DP4`...) und STREICHE die 9 Hinweis-Umschläge (`FR4`, `NT9`, `LV3` usw.) komplett!
Ersetze sie durch **2 Karten pro Rolle** (zum Ausschneiden und Falten):
1. **Verdeckte Geheimnis-/Beweiskarte (1 pro Rolle):** Liegt verdeckt vor dem Spieler. Darauf ist das jeweilige Geheimnis/Beweisstück dokumentiert (inkl. offiziellem Vermerk für den Ermittlungsbogen!). Sobald der Spieler im Gespräch mit dem auf der Vorderseite genannten Trigger konfrontiert wird – oder wenn er sich am Ende einer Runde freiwillig entscheidet, reinen Tisch zu machen –, dreht er diese Karte offen für alle um!
2. **Offene Pen-&-Paper-Aktionskarte (1 pro Rolle):** Eine einmalig im Spiel einsetzbare Spezialfähigkeit, die jeder Rolle echten Einfluss auf das Geschehen gibt (z. B. *Kreuzverhör erzwingen*, *Taschen-/Gegenstands-Check verlangen*, *Zeitstempel-Beweis einfordern*, *Veto/Ablenkung durch den Täter Olli* usw.).

### 5. Tatort-Indizkarten & Korrigierte Entscheidungsmatrix
Der Detektiv darf weiterhin am Ende jeder Runde **3 Tatort-/Beweis-Untersuchungen** (Indizkarten) durchführen, um physische Spuren im Schlosskeller zu sichern. Korrigiere dabei zwingend folgende Logikfehler des Originals:
- **Fehlerkorrektur 1 (Can-Alibi):** Im Original gab es keine Karte, die auf dem Ermittlungsbogen `Can – Alibi` freischaltete. Im neuen System liefert Mareks/Tims Zeitbeobachtung (*Das leuchtende Gesicht rannte bereits VOR dem lauten Scheppern durch den Durchgang in den Kaminsaal*) offiziell das Kreuz **`Can – Alibi`**! Zusammen mit **`Can – Heimlichtuerei`** (Leuchtmaske in Bauchtasche `JT3` / Zeyneps Aussage `FK3`) kann Can nun regulär entlastet werden.
- **Fehlerkorrektur 2 (Kein Namens-Spoiler auf Karte `XD3`):** Auf der Indizkarte `XD3` (Messingkerzenständer) steht im Wachs am Fuß: *„Feine Holzsplitter und weißer Wandkalk.“* Darunter darf NICHT direkt *„Olli – Schlüsselbeweis“* stehen, sondern: *„Schlüsselbeweis: Der Täter hat kurz zuvor Holzarbeiten an einer gekalkten Wand verrichtet.“* Erst in Kombination mit Karte `FN3` (Ollis rechter Arbeitshandschuh mit Möbelwachs, weißem Kalk und roten Kerzenwachstropfen) ist Olli überführt!
- **Fehlerkorrektur 3 (Faire Punkteberechnung ohne Pfad-Strafe):** Im Auflösungsheft (Teil 90) gibt es maximal **9 Detektiv-Punkte**, die nach aufgeklärten Fakten (Meilensteinen) statt nach starrer Karten-Reihenfolge vergeben werden:
  - 3 Punkte für die 3 korrekten Entlastungs-Alibis beim Scheppern (Ahmet über Marek, Fatma über Emine, Can über Marek/Tim).
  - 4 Punkte für die 4 aufgedeckten Heimlichtuereien (Ahmets 150-€-Mietschwindel, Fatmas Münzschatulle, Cans Leuchtmaske, Ollis 2.000-€-Bogentürschaden).
  - 1 Punkt für den Fundort von Herrn Schneiders Schlüsselbund unter den Eiswürfeln im Eiskübel (`PP9`).
  - 1 Punkt für den kombinierten Täter-Schlüsselbeweis (Messingkerzenständer mit Kalk/Holzsplittern `XD3` + Ollis Handschuh mit rotem Kerzenwachs `FN3`).

### 6. Geheime Tipp-Abgabe & Punktewertung für ALLE Spieler (Vor der Anklage)
Bevor der Detektiv in Runde 3 seine offizielle Anklage verkündet, gibt es den Showdown-Moment **„Die geheime Tipp-Runde der Clique“**:
- Generiere im PDF einen Bogen mit **Tipp-Zetteln für alle Mitspieler (inkl. Erzähler)**.
- Jeder notiert geheim:
  1. Wer hat Herrn Schneider niedergeschlagen? (2 Punkte)
  2. Wo ist der Schlüsselbund versteckt? (1 Punkt)
  3. Welches persönliche Bonus-Ziel aus dem eigenen Rollenheft wurde erreicht? (z. B. für Gastrollen: *„Habe ich meinen Schützling verteidigt, bis seine Unschuld am Überfall feststand, oder geholfen, ein echtes Alibi aufzudecken?“* – 2 Punkte).
- Dadurch fiebert jeder einzelne Spieler bis zur letzten Sekunde aktiv mit!

---

## 5. SELBST-TESTS & QUALITÄTSSICHERUNG (ZWINGEND VOR CODE-AUSGABE DURCHZUFÜHREN)

Bevor du den finalen Code schreibst und ausführst, überprüfe deinen Entwurf systematisch anhand dieser 5 Test-Protokolle und dokumentiere kurz das Ergebnis:
1. **Interaktions- & Pausen-Test (Perspektive jeder Rolle 1–10 + Zusatzrollen):** Hat jede einzelne Rolle in Runde 1, 2 und 3 aktive Gesprächsaufträge, einen klaren Stufe-1/Stufe-2-Übergang, eine sinnvolle Geheimniskarte und eine nützliche Spezialfähigkeit? Gibt es irgendeine Rolle (insbesondere Joanna, Tim, Marek, Lejla), die noch Leerlauf hat? (Falls ja: sofort beheben!).
2. **Domino-Ketten-Test (Spielfluss-Simulation):** Simuliere Runde 1 bis 3 chronologisch: Führt das Aufdecken von Hinweis A zuverlässig zum Trigger für Rolle B, und von dort weiter zu Rolle C, bis am Ende von Runde 3 alle 3 Unschuldigen (Ahmet, Fatma, Can) entlastet werden können und alle Beweise (Bogentür/Kalk, Kerzenständer, Eiskübel, verspätete Ankunft am rechten Buffet) logisch auf Olli zeigen?
3. **Zeitstrahl- & Orts-Konsistenz-Test:** Prüfe alle Uhrzeiten (18:30 Lieferung/Bogentür, 20:15 Vorratsraum, 21:00 Rüstung/Vitrine, 23:00 Streit Olli/Schneider, 23:30 Kaminqualm, 23:40 Münzschatulle, 23:51 Streitfoto Ahmet/Schneider, 23:54 Can im Vorratsraum, 23:57 Ahmet/Fatma/Olli an der Theke, 23:58 Knall + Cans Flucht, 23:58:30 Scheppern/Schlag durch Olli, 00:00 Licht an, 00:12 Umschlag im Ascheneimer). Stimmen alle Uhrzeiten und Raumbezeichnungen auf dem Lageplan, in den Rollenheften, auf den Karten und im Auflösungsheft 100 % überein?
4. **Skalierungs-Test (6 vs. 10 vs. 20 Spieler):** Funktioniert das Spiel fehlerfrei, wenn nur 6 Personen spielen (über das Abwesenheits-Protokollblatt), wenn 10 Personen spielen und wenn bis zu 20 Personen spielen?
5. **Druck- & Layout-Vollständigkeitstest:** Enthält das generierte PDF-Paket wirklich ALLE benötigten Teile ohne Platzhalter (`TODO`, `...` o. Ä.)?
   - `00` Erzählerheft (nicht-allwissender Gamemaster, inkl. Ping-Pong-Fragen, Moderations-Impulsen und Skalierungs-Anleitung)
   - `01` Detektivbogen & überarbeiteter Ermittlungsbogen
   - `02` Lageplan (Evidence Board) + ausschneidbare Positions-Marker + Tipp-Zettel für alle Spieler + Abwesenheits-Blatt für Runden unter 10 Spielern
   - `10` Rollenhefte für alle 10 Hauptrollen (inkl. Vorstellungs-Auftritt/Anekdote, Runden-Gesprächsaufträgen und 2-Stufen-Antwortsystem)
   - `11` Versiegelte Fassungen für die 4 Hauptverdächtigen (`WW4` Ahmet, `JM3` Fatma, `RN7` Olli, `YW4` Can)
   - `12` Modulare Zusatz-Rollenhefte (Rollen 11–18 für große Gruppen bis 20 Personen)
   - `20` Handlungskarten-Bögen (Geheimnis-/Beweiskarten + Spezialfähigkeits-Karten für alle Rollen) & Tatort-Indizkarten (`AD3` bis `YT4`)
   - `90` Versiegeltes Auflösungsheft (mit korrigierter Meilenstein-Punktewertung, den 4 Enden, der kompletten Rückblende und der Punkte-Auswertung für alle Mitspieler).

Schreibe nun den vollständigen, sauberen und sofort ausführbaren Code, der dieses gesamte Spiel-Set lückenlos und druckfertig generiert.
