# Fall-Bibel Kammerspiel „Spuk im Schlosskeller“ (U4YRK, Täter Olli)

Stand 2026-11-02, Integration Runde 2. Phase „Fall-Bibel“. Repo nur gelesen. Diese Datei ist die eine, widerspruchsfreie
Spezifikation des Druckspiels „Kammerspiel“. Sie führt die fünf Teilentwürfe `bibel/01-welt.md`, `02-mechanik.md`,
`03-rollen-kern.md`, `04-rollen-zeugen.md` und `05-rollen-zusatz.md` zusammen und behebt die Befunde der Testprotokolle 1 bis 5,
Runden 1 und 2. Welcher Befund wie behoben ist, steht in `bibel/TESTPROTOKOLL.md`. Die Datei ist Spezifikation, kein fertiger
Spieltext. Texte mit dem Zusatz **wörtlich** gelten so für den Druck.

Wo diese Datei und ein Teilentwurf sich unterscheiden, gilt diese Datei. Die Teilentwürfe bleiben als Herkunft liegen.

## 0. Über diese Fall-Bibel

### 0.1 Rang der Quellen und Kürzel

| Rang | Quelle | Kürzel |
|---|---|---|
| 1 | Auftrag des Besitzers, `kammerspiel/AUFTRAG.md` | A:Zeile |
| 2 | Verbindliche Entscheidungen, `kammerspiel/ENTSCHEIDUNGEN.md` | B1–B3, E1–E17 |
| 3 | Kanon des Olli-Falls, `content/party/schlosskeller/`, Bericht `verstehen/kanon-olli.md` | KO |
| 4 | Abgleich, Lücken, Regeln, heutiges Set: `verstehen/abgleich.md`, `luecken.md`, `regeln.md`, `u4yrk-set.md` | ABG, LÜ, REG, US |
| 5 | Diese Fall-Bibel | Kennungen WELT, MECH, RK, ZG, ZR (0.2) |

Nummern in dieser Datei: W-01 bis W-27 (Welt), K-01 bis K-25 (Abweichungen vom App-Kanon), M-01 bis M-40 (Mechanik),
R-01 bis R-14 (Tischregeln), M1 bis M9 (Meilensteine), D1 bis D16 (Domino-Knoten), RK-01 bis RK-24 (Verdächtige, Detektiv,
Fassungen), G-01 bis G-13 und Z-01 bis Z-18 (Zeugen), ZG-01 bis ZG-16 und ZR-01 bis ZR-22 (Zusatzrollen), I-01 bis I-24 (Integration Runde 1, 19.1),
I-25 bis I-41 (Integration Runde 2, 19.4). Befund-Kürzel wie P14-05, P2-01, P3-04 oder P5-B3 verweisen auf `TESTPROTOKOLL.md`.

### 0.2 Aufbau und Kennungen

Die Kapitel 1 bis 19 folgen der Gliederung Welt, Zeitstrahl, Lageplan, Positionen, Wahrnehmung, Spuren, Mechanik, Bogen,
Indizkarten, Karten, Abwesenheitsblatt, Punkte, Enden, Erzählerheft, Rollen 1–18, Detektiv, Fassungen, Teileliste,
Entscheidungsprotokoll.

Jeder Unterabschnitt trägt die Kennung seines Teilentwurfs und behält seine Nummer: „WELT 3.4“, „MECH 9.9“, „RK 1.5“, „ZG 0.4“,
„ZR 0.6“. So bleiben alle Verweise gültig: „WELT §3.4“ steht unter der Überschrift „WELT 3.4“. Ein Verweis ohne Kürzel
(„4.2“, „Abschnitt 5“, „R-08“) zeigt in den Teil, dessen Kennung der Abschnitt trägt, in dem er steht. Die Tischregeln R-01 bis
R-14 stehen in MECH 1.4.

Neu in der Integration sind die Unterabschnitte WELT 5.8, MECH 9.14, MECH 12a, RK 1.8, RK 2.12, RK 3.12, RK 4.12, RK 5.12 und
ZG 0.6 sowie die Abschnitte 0 und 19.1 bis 19.3. Die Integration Runde 2 hat 19.4 ergänzt; 19.2 nennt den Stand
nach Runde 2.

### 0.3 Konkordanz: Kennung → Kapitel

Jede Zeile nennt einen Abschnitt der Teilentwürfe und das Kapitel, in dem er steht. „–“ heißt: nicht übernommen (19.3).

| Kennung | Titel | Kapitel |
|---|---|---|
| WELT 0 | Rahmen | 0 (0.2, 0.3); 0.1 nicht übernommen |
| WELT 1 | Weltbestand | 1 |
| WELT 2 | Lageplan | 3 |
| WELT 3 | Zeitstrahl | 2 |
| WELT 4 | Positionstabelle | 4 |
| WELT 5 | Wahrnehmungsmatrix | 5 |
| WELT 6 | Spuren und Beweise | 6 |
| WELT 7 | Wahrheit je Rolle | 1 |
| WELT 8 | Entscheidungen und Auflösungstabelle | 19 |
| MECH 0 | Grundlagen | 7 |
| MECH 1 | Ablauf des Abends | 7 |
| MECH 2 | Ermittlungsbogen (Teil 01) | 8 |
| MECH 3 | Indizkarten AD3 bis YT4 | 9 |
| MECH 4 | Geheimniskarten und Aktionskarten | 10 |
| MECH 5 | Abwesenheitsblatt (Teil 02) | 11 |
| MECH 6 | Detektiv-Punkte und Meilenstein-Quellen-Matrix | 12 |
| MECH 7 | Tipp-Runde, Wertung, Bonus-Ziele | 12 |
| MECH 8 | Anklage, vier Enden, Rückblende, Teil 90 | 13 |
| MECH 9 | Erzählerheft (Teil 00) | 14 |
| MECH 10 | Teileliste | 18 |
| MECH 11 | Domino-Gerüst (Vorgabe für die Rollen-Phase und für Protokoll 2) | 7 |
| MECH 12 | Entscheidungen dieser Datei | 19 |
| MECH 12a | Abweichungen vom Auftrag (Mechanik), zur Kenntnis des Besitzers (P5-M7) | 19 |
| MECH 13 | Selbstprüfung und offene Punkte | – |
| RK 0 | Rahmen | 15 |
| RK 1 | Gemeinsame Bauteile der vier Verdächtigen | 15 |
| RK 2 | Rolle 1: Ahmet (Fassung WW4) – unschuldig | 15 |
| RK 3 | Rolle 2: Fatma (Fassung JM3) – unschuldig | 15 |
| RK 4 | Rolle 3: Olli (Fassung RN7) – der Täter | 15 |
| RK 5 | Rolle 4: Can (Fassung YW4) – unschuldig | 15 |
| RK 6 | Der Detektiv (Teil 01, Rollenteil) | 16 |
| RK 7 | Die vier versiegelten Fassungen (Teil 11) | 17 |
| RK 8 | Prüfungen dieser Datei | 15 |
| RK 9 | Entscheidungen dieser Datei | 19 |
| RK 10 | Offene Punkte (für Integration und Text-Phase; keiner blockiert) | – |
| ZG 0 | Grundsätze für alle sechs Zeugen | 15 |
| ZG 1 | Lejla (Platz 5) – die Apothekerin | 15 |
| ZG 2 | Emine (Platz 6) – die Grundschullehrerin | 15 |
| ZG 3 | Tim (Platz 7) – der Hobby-Elektriker | 15 |
| ZG 4 | Joanna (Platz 8) – die Fotografin des Abends | 15 |
| ZG 5 | Marek (Platz 9) – der Caterer | 15 |
| ZG 6 | Zeynep (Platz 10) – die Fußballtrainerin | 15 |
| ZG 7 | Querschnitt: Wer bohrt wen an | 15 |
| ZG 8 | Protokoll 1: Interaktions- und Pausen-Test (A:128) | – |
| ZG 9 | Protokoll 2: Domino-Anteil der Zeugen (A:129) | – |
| ZG 10 | Protokoll 3: Zeit und Ort (A:130) | – |
| ZG 11 | Entscheidungen dieser Datei | 19 |
| ZG 12 | Offene Punkte (keiner blockiert) | – |
| ZR 0 | Grundsätze für alle acht Zusatzrollen | 15 |
| ZR 1 | Sibel (Platz 11) – die Vorsichtige · Tandem 1 | 15 |
| ZR 2 | Damir (Platz 12) – der Teemeister · Tandem 1 | 15 |
| ZR 3 | Hana (Platz 13) – die Kamin-Heizerin · Tandem 2 | 15 |
| ZR 4 | Serkan (Platz 14) – der Fahrdienst-Organisator · Tandem 2 | 15 |
| ZR 5 | Azra (Platz 15) – die Flohmarkt-Kennerin · Tandem 3 | 15 |
| ZR 6 | Wojtek (Platz 16) – der Architekturstudent · Tandem 3 | 15 |
| ZR 7 | Aylin (Platz 17) – die Kassenprüferin · Tandem 4 | 15 |
| ZR 8 | Tugba (Platz 18) – die Party-Planerin · Tandem 4 | 15 |
| ZR 9 | Querschnitt: Wer bohrt wen an | 15 |
| ZR 10 | Protokoll 1: Interaktions- und Pausen-Test (A:128) | – |
| ZR 11 | Protokoll 2: Domino-Anteil der Zusatzrollen (A:129), nicht lösen, nicht stören | – |
| ZR 12 | Protokoll 3: Zeit und Ort (A:130) | – |
| ZR 13 | Protokoll 4: Skalierung 13 bis 20 Personen, Herkunft und Kopftuch | 15 |
| ZR 14 | Entscheidungen dieser Datei | 19 |
| ZR 15 | Offene Punkte (keiner blockiert) | – |

### WELT 0.2 Schreibregeln, die aus dieser Welt folgen

- **Sekunden** stehen nur in dieser Bibel und im Auflösungsheft (Teil 90). Spielertexte nennen im Dunkeln nur die
  Reihenfolge („erst das Gesicht, dann das Scheppern“). Grund: Im Dunkeln schätzt niemand Zeitabstände (`wahrnehmung.json`, `zeitgefuehl`).
- **Uhrzeiten H:MM** nur aus der Kanon-Liste: 18:00, 18:30, 18:35, 18:45, 18:50, 19:00, 19:30, 20:15, 21:00, 22:00,
  22:30, 23:00, 23:20, 23:30, 23:40, 23:45, 23:50 bis 23:59, 0:00, 0:01, 0:02, 0:03, 0:05, 0:10 bis 0:13, 0:15, 0:20,
  0:30, 1:15, 2:00, 2:45, 7:00 (Textprüfer `textpruefer.dart:476-480`). Alle Zeiten dieser Datei halten das ein.
- Vorlesetexte: Uhrzeiten und Beträge in Worten. Karten und Hefte: „23:58 Uhr“, „2.000 €“.
- Raumnamen genau so: **Ost-Saal**, **Buffetsaal**, **Vorratsraum**, **Durchgang**, **Kaminsaal**, **Turmgang**,
  **Windfang**. Dazu „Steinbogen“, „Turm-Toilette“, „Theke“, „Theken-Klappe“.
- Immer „Herr Schneider“ / „Herrn Schneider“. Bloß „Schneider“ nur in Ollis wörtlicher Rede.
- Kein Verb des Schlagens, in keiner Form (Prüfliste `pfadwissen.dart:10`; der eigene Prüfer muss auch Grundform und
  Partizip erkennen, LÜ S-34). Der Schlag ist nur „ein dumpfer Schlag, Poltern,
  Metall scheppert über den Steinboden“. Herr Schneider ist „bewusstlos, mit einer dicken Beule“ (E4). Kein Blut.
- Getränke nur Tee, Kaffee, warmer **alkoholfreier** Apfelpunsch, Wasser, Säfte. „Bargeld“ statt „bar“.
- Kopftuch ist nie Spur, Merkmal, Teil einer Lüge oder eines Geheimnisses. Herkunft ist nie Motiv.
- Fatma hat die Schatulle **ausgeliehen** (zum Abzeichnen, Rückgabe am Montag), nie „gestohlen“.
- **Ahmets Weg hinter die Theke** (23:56:50 bis 23:56:58) heißt in allen Spielertexten „um 23:57 Uhr“ bzw. „um drei vor
  zwölf“ (P3-01). Nie 23:56.
- **Ollis Gang zum Eiskübel** (23:56:30 bis 23:56:50) heißt in Spielertexten ebenfalls „um 23:57 Uhr“ bzw. „um drei vor
  zwölf“ (A:41, P3R2-04). Beide Wege stehen in Spielertexten nie unter 23:56 (P2-26).
- **„kurz vor zwölf“** heißt in Spielertexten immer 23:55 bis 23:57 Uhr. Was im Dunkeln kurz vor dem Licht geschah
  (23:59:30 Joannas Handylampe, 23:59:40 Tims Stirnlampe), heißt „im Dunkeln, kurz bevor das Licht wieder anging“ oder in
  Zeitspalten „im Dunkeln, kurz vor dem Licht“ (P3-04).
- **„kurz nach zwölf“** heißt in Spielertexten 0:00 bis 0:05 (Handys, Can, Serkan). Ahmet am Ascheneimer heißt immer
  „um 0:12 Uhr“ bzw. „zwölf nach zwölf“, Azras Skizzenblock „um 0:10 Uhr“ bzw. „zehn nach zwölf“ (P3R2-16).
- **„kurz vor zwölf“ nicht für Nachbarzeiten:** Der Knall heißt „um 23:58 Uhr“ bzw. „um zwei vor zwölf“, die Zeit ab 23:50
  „ab zehn vor zwölf“ (P3R2-15).
- **Platzhalter:** Jede gedruckte Zeile, die eine Rolle mit höherem Platz nennt, trägt einen Platzhalter [Name | Ersatz]
  (ZG G-08, ZR ZG-10, P5-B4). Der Prüfer der Text-Phase vergleicht jeden Namen 5–18 in Teil 10, 12, 20 und 90 mit der
  Besetzung.

### WELT 0.3 Abweichungen vom App-Kanon (vollständig, zur Kenntnis des Besitzers)

| Nr | Kanon (App) | Kammerspiel | Grund |
|---|---|---|---|
| K-01 | Olli trägt 18:30 mit Wojtek | mit **Tim** | A:41, A:48 |
| K-02 | Möbelwachs aus Wojteks Werkzeugtasche, Wojtek gibt es | Wojteks Werkzeugkasten, seit 18:00 an Tim verliehen; **Tim** gibt Olli das Wachs | A:48 und A:63 zusammen (ABG D-14) |
| K-03 | Wojteks Finger 23:50, Ollis Satz 23:52 zu Wojtek | **Tims** Finger, Satz zu Tim | A:41, A:48 |
| K-04 | Olli kauert sich zu Azra | zu **Lejla**: „Lejla? Ich bin's, Olli.“ | A:41, A:44 |
| K-05 | Lejla beim Knall im Ost-Saal | Lejla am **rechten Buffettisch**, kauert | A:44 |
| K-06 | Ahmet kauert neben Damir | neben **Marek** (Damir zusätzlich daneben) | A:39, A:52 |
| K-07 | Marek holt Saft im Durchgang | Marek hinter der Theke am **Ostende**, Saftkrüge | A:52, W-06 |
| K-08 | Sicherungskasten im Kaminsaal | im **Durchgang** | A:83, W-03 |
| K-09 | Zeynep am Bogen, auf der Kaminsaal-Seite | **im Steinbogen** (gehört zum Durchgang) | A:54, W-04 |
| K-10 | Tugbas Notizbuch mit der Liste von 23:57 | **Joannas Handy-Notiz** mit Zeitstempel 23:57 | A:50, W-08 |
| K-11 | Azra sieht 23:45 die Tasche | **Zeynep** | A:54 |
| K-12 | Hana sieht 0:12 Ahmet am Ascheneimer | **Azra** | A:63 |
| K-13 | Barans Box und Kopfhörer | **Wojteks** Box und Kopfhörer | A:63 |
| K-14 | Baran, Pawel spielen mit | gibt es nicht | A:59, E2 |
| K-15 | Scheppern 23:58:40 | **23:58:30** | A:73, A:130, W-05 |
| K-16 | Damir findet Herrn Schneider | **Marek** | ABG D-25 |
| K-17 | Schneiders Sätze 23:51, 23:56, 23:57 laut | **leise** (nur bis 3 m) | W-07 |
| K-18 | 20:15 nur Ollis Irrweg | dazu Azras falscher Alarm und Wojteks Taschenlampe | A:63, W-13 |
| K-19 | Hana feuert den Kamin an, um ihn zum Ziehen zu bringen | Hana will dabei heimlich einen Liebesbrief verbrennen | A:62 |
| K-20 | Serkan will Decken holen | Serkan will Wunderkerzen holen („Decken“ ist seine Ausrede) | A:62 |
| K-21 | Mietgeld 19 × 150 € = 2.850 € | 17 × 150 € = **2.550 €** | 18 Rollen, W-12 |
| K-22 | Aylin, Tugba ohne Tandem | Tandem 4 mit Gästeliste, Dankeskarte, Wissen über den Bund | A:64, W-17 |
| K-23 | Die Handys kommen um 23:55 in den Handykorb | Tugba sammelt sie schon um 23:00 für ihr Ratespiel ein, auch Tims an der Kaffeemaschine; nur Joanna behält ihres | Wer nicht im Ost-Saal war, hätte im Dunkeln ein Handy gehabt; das bräche die Lichtregel W-23 (P3-02) |
| K-24 | Azra holt um 0:10 ihre Strickjacke von der Wandbank | Azra holt ihren Skizzenblock | Ihr Merkmal ist der lange Strickcardigan, den sie trägt; sonst wäre dasselbe Stück an zwei Orten (P3-21) |
| K-25 | Rundenstart Runde 1 mit „Alle vier Verdächtigen haben gute Gründe, nahe der Theke gewesen zu sein.“ | der Satz entfällt; dafür „Wer war wo, als es knallte, und wo, als es schepperte?“ | Olli und Can nennen in Stufe 1 andere Orte; der Erzähler würde sonst mit eigener Stimme deuten (E10, P145R2-M10) |

---

## 1. Welt

### WELT 1.1 Wer heute Nacht im Keller ist (W-01)

**Fester Bestand, unabhängig von der Personenzahl am Tisch:** die 18 aus der Clique (Rollen 1–18), der Detektiv als
ihr Gast und Herr Schneider. Zusammen 20 Menschen. Baran und Pawel gibt es in dieser Welt nicht.

Regel für ungespielte Rollen:
- Sie sind trotzdem da. Fakten wie das Mietgeld, die Rüstung oder die blinde Kuh bleiben gleich.
- **Rollen 5–10** heißen auch ungespielt mit Namen, aber nur auf dem Abwesenheitsblatt (A:57, E7), auf ihren eigenen
  Geheimniskarten, in Joannas Liste (W-21) und in Teil 90. In Teil 90 dürfen Zeugen 5–10 mit Namen stehen, wenn sie heute
  auf dem Abwesenheitsblatt lagen (P14-16).
- **Rollen 11–18** werden ungespielt nie genannt, auch nicht in Teil 90: Zusatzrollen stehen dort nur, wenn sie gespielt
  wurden (P14-16). Wo die Geschichte sie braucht, heißen sie „ein Gast“ (Rüstung,
  Kamin, Alarm, Ruf zur blinden Kuh). Ihre Rand-Indizien fallen dann weg; die Rollen 5–10 tragen alles Nötige.
- Die Liste von Joanna (5.4) nennt nur Rollen 1–10 und Herrn Schneider. Keine Zusatzrolle steht darauf.

### WELT 1.2 Die 18 Rollen

Alter, Beruf, Farbe und Merkmal aus `figuren.json`. Herkunft steht nur hier (für die Herkunftsprüfung 7.4), nie im Spiel.

| Platz | Name | Alter | Beruf / Alltag | Stellung im Fall | Farbe | Merkmal am Abend | Herkunft |
|---|---|---|---|---|---|---|---|
| 1 | Ahmet | 27 | Agentur für Stadtfeste und Märkte; hat den Abend organisiert | Verdächtiger (WW4) | Schwarz und Weiß | schwarzer Strickpulli, blaues Stoffarmband; dicker Umschlag; schwarze Jacke ab 23:55 am Jackenständer | bosnisch |
| 2 | Fatma | 26 | Kommunikationsdesign, letztes Semester; Abschlussarbeit über alte Münzbilder | Verdächtige (JM3) | Beerenrot | beerenroter Wollmantel, schwere Umhängetasche aus Leder, breiter Silberring rechts | kurdisch, trägt Kopftuch |
| 3 | Olli | 28 | Lagerlogistiker, hilft bei jedem Umzug | Verdächtiger und Täter (RN7) | Marineblau und Khaki | grauer Kapuzenpulli, dunkelblaue Daunenweste, rechter Arbeitshandschuh hängt aus der Westentasche | deutsch |
| 4 | Can | 25 | Ausbildung zum Mediengestalter, dreht lustige Kurzvideos | Verdächtiger (YW4) | Signalgelb | signalgelber weiter Kapuzenpulli mit Bauchtasche | türkisch |
| 5 | Lejla | 25 | Apothekerin; hat das Buffet mit Marek geplant | Zeugin | Türkis | türkise Latzschürze, Abrechnungsblock | bosnisch |
| 6 | Emine | 26 | Grundschullehrerin | Zeugin | Olivgrün | olivgrüner Steppmantel, silberne Thermoskanne mit Tee | türkisch, trägt Kopftuch |
| 7 | Tim | 27 | Mechatroniker, Hobby-Elektriker | Zeuge | Karorot | kariertes Flanellhemd, Stirnlampe um den Hals, Spannungsprüfer-Schraubenzieher | deutsch |
| 8 | Joanna | 24 | Medienwissenschaft, fotografiert Hochzeiten; Fotografin des Abends | Zeugin | Violett | violetter Cardigan, Handy im Handyhalter mit Aufsteckleuchte | polnisch |
| 9 | Marek | 28 | Catering-Betrieb mit seiner Schwester; hat geliefert | Zeuge | Lederbraun | dunkelbraune Lederjacke, Autoschlüssel mit Anhänger | polnisch |
| 10 | Zeynep | 23 | Sportstudium, trainiert eine Mädchen-Fußballmannschaft | Zeugin | Minzgrün | minzgrüner Pulli, Kappe verkehrt herum | türkisch |
| 11 | Sibel | 23 | Biologiestudium; fürchtet nur alte Rüstungen | Tandem 1 | Pastellrosa | Fransenschal bis übers Kinn | türkisch |
| 12 | Damir | 25 | Erzieher; Teemeister des Abends | Tandem 1 | Weiß mit Schwarz | weißes Hemd, schwarze Schürze, große Teekanne | bosnisch |
| 13 | Hana | 25 | Försterin | Tandem 2 | Jeansblau | Jeanshemd, Rußflecken an Wange und Händen | bosnisch |
| 14 | Serkan | 29 | Rettungssanitäter; fährt alle heim | Tandem 2 | Stahlblau | stahlblaue Steppweste, Klemmbrett mit Fahrzeiten, LED-Taschenlampe | türkisch |
| 15 | Azra | 26 | Kunstgeschichte, Flohmärkte, kennt alte Münzen | Tandem 3 | Pflaume | Lupe an einer Silberkette, langer Strickcardigan | bosnisch |
| 16 | Wojtek | 27 | Architekturstudium | Tandem 3 | Aschgrau | Zimmermannsbleistift hinter dem Ohr, Maßband | polnisch |
| 17 | Aylin | 24 | Steuerfachangestellte, hebt jeden Beleg auf | Tandem 4 | Taubenblau | schwarze Ledermappe mit Belegen | kurdisch |
| 18 | Tugba | 27 | Projektleiterin; hat den Ablaufplan geschrieben | Tandem 4 | Rostorange mit Gold | Notizbuch mit goldenem Einband | türkisch, trägt Kopftuch |

### WELT 1.3 Beziehungen

Nur als Tatsache in „Wer du bist“. Schweigen wird nie mit Verwandtschaft begründet, sondern mit Versprechen oder
Mitschuld (REG §6.4).

| Paar | Beziehung | Folge in der Tatnacht |
|---|---|---|
| Ahmet – Lejla | Cousin und Cousine | Lejla hat Ahmet versprochen, nichts über die Essensrechnung zu sagen |
| Ahmet – Marek | Kunde und Caterer | Ahmet schuldet Marek heute Abend die Nachzahlung (1.8) |
| Ahmet – Joanna | sie fotografiert seine Stadtfeste | Joanna hat Ahmet um 23:53 versprochen, das Foto keinem zu zeigen |
| Ahmet – Olli | Banknachbarn in der Schule | – |
| Ahmet – Fatma | gleiche Schule, er eine Klasse drüber | – |
| Ahmet – Can | Ahmet hat Can Radfahren beigebracht | – |
| Fatma – Emine | beste Freundinnen seit der 5. Klasse | Emine hat Fatma Schweigen versprochen |
| Fatma – Azra | kennen sich aus der Unibibliothek | Azra hat Fatma von der Münzschatulle erzählt |
| Fatma – Olli | Olli trug ihre Umzugskisten | – |
| Olli – Tim | Kumpel aus der Berufsschule, schrauben an Fahrrädern | Tim half beim Tragen, gab das Möbelwachs, hält zu Olli |
| Olli – Can | Sportverein, Can filmt | – |
| Can – Zeynep | Geschwister, Zeynep zwei Jahre jünger | Zeynep steht für Cans Streich Schmiere (Mitschuld) |
| Lejla – Marek | haben das Buffet zusammen geplant | – |
| Tim – Wojtek | Tim leiht Wojteks Werkzeugkasten | 20:15 erfährt Wojtek vom Wachs |
| Tim – Hana | Tim repariert ihre Motorsäge | – |
| Joanna – Marek | Hochzeiten (sie fotografiert, er kocht) | – |
| Joanna – Wojtek | sie fotografiert seine Hausmodelle | – |
| Marek – Aylin | Aylin macht seine Steuer | – |
| Zeynep – Sibel | wohnen in einer WG | – |
| Sibel – Damir | Damir begleitet Sibel um 21:00 zur Turm-Toilette | Tandem 1 |
| Emine – Damir | Damir betreut nachmittags Kinder aus Emines Klasse | – |
| Hana – Serkan | Tandem 2 | decken sich gegenseitig |
| Azra – Wojtek | skizzieren zusammen Fassaden | Tandem 3 |
| Aylin – Tugba | Tandem 4 | Dankeskarte für Herrn Schneider |
| Lejla – Serkan | Erste-Hilfe-Kurs, er war Ausbilder | – |
| Tugba – Damir, Tugba – Azra | Spieleabende, Flohmarkt-Deko | – |

### WELT 1.4 Herr Schneider (keine Rolle)

- 61, **Schlossverwalter** seit 25 Jahren, Spitzname „der Hausmeister“. Dunkelgrüne Wachsjacke, grauer Rollkragen.
- Großer **Schlüsselbund an der rechten Gürtelschlaufe**: Schlüssel aus dunklem Eisen an einem Stahlring, kein Messing.
  Daran Außentor, Hoftür, Turm. Den Außentor-Schlüssel gibt es nur zweimal: an seinem Bund und bei seiner Kollegin.
- **Klemmbrett** mit Belegungsblatt der Stiftung und Quittungsblock mit Durchschlägen (6.10).
- Er duzt alle. Die Gäste sagen „Herr Schneider“ und duzen ihn.
- Warme Seite: Er hat den Messingkerzenständer selbst poliert, weil er Feste mag. Jeden Schaden muss er der Stiftung
  melden; kleine Schäden zahlt er oft aus eigener Tasche. Darum ist er beim Geld so streng.
- Heute ärgert er sich über die Bogentür (Olli), den Parkplatz (Marek), die Musik (Wojtek), die Miete (Ahmet), die
  offene Vitrine (Fatma). Um zwölf will er alles klären.
- **Nach der Tat (W-18):** bewusstlos bis 0:01:30, dicke Beule, Gedächtnislücke ab 23:58:09 (direkt nach „Hab ich
  dich!“). Danach sitzt er mit einem Kühlpack im Buffetsaal und wird bald wieder grantig. Er erinnert sich an: Knall,
  Dunkelheit, Weg zur Notlaterne, leuchtendes Gespenstergesicht, er packt eine Kapuze, „Hab ich dich!“. Dann nichts.
  Er sagt, wo er um 23:57 stand (am Ostende der Theke). Über Geldsachen der Gäste spricht er nicht: „Das kläre ich mit
  den Leuten selbst.“

### WELT 1.5 Der Detektiv (Spielerrolle, nie verdächtig)

Nach Kanon ein Gast der Clique, die ganze Nacht im Keller. Heller sandbeiger Trenchcoat, braun karierter Hut, Pfeife
mit Seifenblasen. Hat die 150 € nicht bezahlt: Er ist Gast der Clique (Kanon zählt nur die Rollen als Zahlende).

| Zeit | Was der Detektiv selbst erlebt hat |
|---|---|
| 23:50–23:55 | sitzt im Ost-Saal an der langen Tafel, Ostseite |
| 23:54 | sieht Olli hereinkommen und sich an den Kopf der Tafel setzen |
| 23:55 | Tugba macht ihn zur blinden Kuh: Augenbinde, Ehrenplatz der blinden Kuh. Wojtek setzt ihm seine Kopfhörer auf, laute Musik über die Akku-Box |
| 23:55–0:00:35 | sieht nichts; hört nur sehr Lautes: den Knall, „Hab ich dich!“, „Stehen bleiben!“, „Stehen bleiben, hab ich gesagt!“, das Scheppern, „Hier liegt Herr Schneider!“ |
| 0:00:35 | Tugba nimmt ihm Augenbinde und Kopfhörer ab: „So, Augen auf. Das war nicht die Überraschung.“ |
| 0:20 | Herr Schneider: „Finde raus, wer das war. Bis zum Morgen.“ |

Der Detektiv weiß also: Um fünf vor zwölf saß Olli am Kopf der Tafel. Wo Olli danach war, weiß er nicht.

### WELT 1.6 Wichtige Gegenstände (Kurzliste; Einzelheiten in Abschnitt 6)

Messingkerzenständer mit drei roten Wachskerzen · Eiskübel (Metallkübel mit Eiswürfeln) · Schlüsselbund ·
Ollis Arbeitshandschuhe (links, rechts) · Möbelwachs-Dose in Wojteks Werkzeugkasten · Bogentür mit ausgerissenem
Beschlag · Umschlag „Miete Schlosskeller“ · Mietgeld · Münzschatulle · Fatmas Umhängetasche · Leuchtmaske ·
Mehrfachsteckdose und Kaffeemaschine · Hauptsicherung im Sicherungskasten · Notlaterne · Mitternachtstorte ·
Quittungszettel · Schneiders Klemmbrett · Joannas Handy (Foto 23:51, Notiz 23:57) · Ahmets Jacke mit Namensliste ·
Handykorb · Wojteks Musikbox und Kopfhörer · Tims Stirnlampe · Serkans LED-Taschenlampe · Hanas halb verkohlter Brief ·
Splitter unter dem Sockel der Rüstung · Tugbas Notizbuch mit Punkteliste und Dankeskarte · Aylins Gästeliste.

### WELT 1.7 Essen und Getränke

- Offenes Buffet ab 19:00: warmes Essen aus Warmhaltebehältern (rechter Buffettisch), frisches Brot in der Brottasche,
  Dips, Gebäck (linker Buffettisch).
- Getränke: schwarzer Tee aus dem großen Teekocher (Damir schenkt im Teegeschirr des Schlosses aus), Kaffee aus der
  Kaffeemaschine, warmer alkoholfreier Apfelpunsch, Wasser, Säfte.
- **Saftkrüge, Gläser, Tassen und Servietten** stehen auf der Anrichte Ost hinter dem Ostende der Theke (W-06, ABG D-08).
  Nachschub in den **Getränkekisten im Durchgang**.
- **Eiskübel** mit Eiswürfeln für Saft und Wasser vor dem Ostende der Theke.
- Emine hat eine silberne Thermoskanne mit Tee. Um Mitternacht soll es Tortenkaffee (Tim) und Tortentee (Damir) geben.
- Keine Flaschen, kein Alkohol, nichts wird geraucht.

### WELT 1.8 Geld (W-12)

| Betrag | Was | Wer weiß es |
|---|---|---|
| 150 € je Gast | „Miete“, die Ahmet um 18:00 am Jackenständer im Ost-Saal von den 17 anderen aus der Clique in Bargeld eingesammelt hat; der Keller war umsonst | alle zahlten; dass es keine Miete gab, wissen Ahmet, Lejla (Nachmittag), Aylin (22:30), Herr Schneider |
| 2.550 € | Summe: 17 × 150 €. Steckt im Umschlag „Miete Schlosskeller“, ab 0:12 in Ahmets Hosentasche | Ahmet. **Nur im Auflösungsheft gedruckt** (ABG D-41) |
| Nachzahlung | Ahmet hat bei Marek viel zu groß bestellt. Marek verlangt **150 € pro zahlendem Gast mehr, zusammen 2.550 €**, heute Abend in Bargeld. Das Mietgeld ist genau diese Nachzahlung | Ahmet, Marek, Lejla (weiß, dass Ahmet mit der Rechnung in der Klemme steckt) |
| 2.000 € | Schadensersatz für die Bogentür, in Bargeld, bis Mitternacht | Olli, Herr Schneider, Tim (18:50 dabei) |

Auch Marek hat seine 150 € „Miete“ an Ahmet gezahlt. Er merkt erst später: Die „Miete“ war genau so hoch wie seine
Nachzahlung pro Gast.

### WELT 7.1 Die vier Verdächtigen

**1 Ahmet (WW4) – unschuldig.**
- Nebendelikt: hat von allen 150 € „Miete“ kassiert, obwohl der Keller umsonst war. Damit wollte er Mareks Nachzahlung
  für das viel zu groß bestellte Buffet bezahlen.
- Ablauf: 23:51 droht Herr Schneider ihm leise. 23:56:58 schlüpft er mit dem Umschlag hinter die Theke am Ostende. Er
  will Herrn Schneider bitten, um zwölf nichts zu sagen: „Bitte sag um zwölf nichts. Ich geb allen das Geld zurück.“
  Dazu kommt er nicht. Beim Knall kauert er an Mareks Beinen und hält den Umschlag fest bis zum Licht. 0:12 Ascheneimer.
- Stufe 1 (Lügen): „Ich hab hinter der Theke nur Servietten gesucht.“ / „Die 150 € waren für die Miete.“
- Wissen über andere: Um 23:57 stand Olli am Eiskübel; Herr Schneider sagte zu ihm „Zweitausend, bis zwölf“. Neben ihm
  stand Marek mit den Saftkrügen.
- Ziel (Kanon): Niemand soll vor dem Morgen erfahren, dass die Miete erfunden war.

**2 Fatma (JM3) – unschuldig.**
- Nebendelikt: hat um 23:40 die Münzschatulle aus der schon gesprungenen Vitrine genommen, um das Wappen abzuzeichnen;
  Rückgabe am Montag. Azra hatte ihr von der Schatulle erzählt.
- Ablauf: 23:56 sieht Herr Schneider die Splitter und droht leise mit der Polizei um Punkt zwölf. 23:57 geht sie mit
  der Tasche zur Klappe, um die Schatulle zurückzugeben. Beim Knall geht sie zurück und kauert neben Emine.
- Stufe 1: „Ich stand die ganze Zeit beim Gebäck am linken Buffet.“ / „In meiner Tasche sind nur Bücher.“
- Wissen über andere: Von der Klappe sah sie um 23:57 Olli am Eiskübel vor Herrn Schneider stehen (Worte nicht gehört).
  Sie sah Ahmet mit etwas in der Hand am Ostende hinter die Theke gehen.
- Ziel (Kanon): Die Schatulle soll zurück, ohne dass es alle erfahren.

**3 Olli (RN7) – der Täter.**
- Nebendelikt: Bogentür 18:35 beschädigt, Schramme 18:45 mit Möbelwachs verdeckt. 18:50 fordert Herr Schneider 2.000 €
  bis Mitternacht; 23:00 lauter Streit mit Polizei-Drohung.
- Tat: siehe Sekundenprotokoll 23:58:10 bis 23:58:55. In Panik, nie geplant. Er greift den Kerzenständer am Fuß; dann
  nur ein dumpfer Schlag und Poltern. Er reißt den Bund ab, um hinauszukommen, merkt sofort, dass Flucht alles schlimmer
  macht, und schiebt den Bund unter das Eis.
- Stufe 1: „Ich saß die ganze Zeit am Kopf der Tafel im Ost-Saal. Als das Licht anging, hab ich Tim Eis gebracht.“
  Bleib locker und ein bisschen müde.
- Stufe 2 (A:95): Er gibt zu, kurz vor zwölf am Eiskübel gewesen zu sein und wegen der Bogentür (2.000 €) mit Herrn
  Schneider gestritten zu haben. Er behauptet: „Beim Knall hab ich mich am Eiskübel geduckt. Dann ist das leuchtende
  Gespenst aus dem Vorratsraum auf Herrn Schneider los. Ich bin zu Lejla gekrochen.“ Er sagt „das Gespenst“, nie selbst
  Cans Namen (W-25).
- Ollis Wissen: Er hat Can 1,4 m entfernt fliehen sehen, **bevor** er selbst zur Tür ging. Er weiß, dass seine Stufe 2
  die Wahrheit bewusst verdreht.
- Stufe 3 (nur RN7, erst bei XD3 + FN3 + PP9): das Geständnis. „Im Dunkeln hat mich die Panik gepackt.“
- Ziel (Kanon, angepasst): unentdeckt bleiben; den Türschaden selbst mit Herrn Schneider klären.

**4 Can (YW4) – unschuldig.**
- Nebendelikt: Streich mit der Leuchtmaske. Er wollte um zwölf die blinde Kuh erschrecken.
- Ablauf: 23:54 Vorratsraum, Licht aus. Nach dem Knall glaubt er, die blinde Kuh kommt, springt heraus, Herr Schneider
  packt die Kapuze: „Hab ich dich!“ Er reißt sich los, rennt, Maske in die Bauchtasche, Turm-Toilette. 0:01 kommt er
  herunter.
- Stufe 1: „Ich war die ganze Zeit oben auf der Turm-Toilette.“ / „Welche Maske? Ich hab keine Maske.“
- Wissen über andere: Als er sich losriss, brüllte Herr Schneider ihm „Stehen bleiben!“ hinterher; da stand Herr
  Schneider noch. Um 23:54 sah er Fatma und Emine am linken Buffet tuscheln; Fatma hielt ihre Tasche fest. Zeynep stand
  für ihn Schmiere.
- Ziel (Kanon): Der Streich soll nicht herauskommen.

### WELT 7.2 Die Zeugen 5–10

| Rolle | Geheimnis (Stufe 1 hält es zurück) | Wissen zum Hauptfall | Nebendelikt | Ziel (Kanon, angepasst) |
|---|---|---|---|---|
| 5 Lejla | weiß von Ahmets Ärger mit der Essensrechnung; sah nachmittags auf dem Klemmbrett „Saalmiete Schlosskeller: 0 Euro“; sah 23:56:58 Ahmet mit dickem Umschlag am Ostende hinter die Theke schlüpfen | kauerte beim Knall allein am rechten Buffettisch; beim Scheppern war Olli **nicht** da; danach: „Lejla? Ich bin's, Olli.“ | – | Ahmet schützen, bis er selbst redet (Versprechen) |
| 6 Emine | sah 23:40, wie Fatma die Schatulle nahm; hörte 23:56 die Drohung | kauerte ab dem Knall hinter dem linken Buffettisch; gleich danach kam Fatma: „Emine? Ich bin's, Fatma.“; beim Scheppern war Fatma da | – | Fatma nicht verraten (Versprechen) |
| 7 Tim | der Knall kam von seiner alten Mehrfachsteckdose (trotz Warnung, obwohl er sie richten wollte); trug 18:30 mit Olli, gab 18:45 das Wachs, war 18:50 und 23:00 dabei; 23:52 Ollis Satz | am Sicherungskasten im Durchgang: Gesicht vorbei, dann Schneiders Ruf, dann Scheppern; hörte 23:57 „Zweitausend, bis zwölf“; 0:01 brachte Olli ihm Eis | Kurzschluss trotz Warnung; Wachs gegeben | Niemand soll erfahren, dass seine Steckdose den Ausfall verursacht hat (Mitschuld beim Wachs: hält zu Olli) |
| 8 Joanna | Foto 23:51; Versprechen an Ahmet (23:53), es keinem zu zeigen | Notiz 23:57 (5.4); hörte „Zweitausend, bis zwölf“; 23:59:30 Kopf der Tafel leer | – | Ihr Versprechen an Ahmet halten, ohne den Detektiv anzulügen |
| 9 Marek | Nachzahlung 150 € pro Gast, heute Abend in Bargeld fällig; sah 23:56:58 Ahmets Umschlag („mein Geld?“) | Ahmet kauerte an seinen Beinen (Flüstern) bis zum Licht; sah im Kerzenlicht das Gesicht herausspringen, gepackt werden, sich losreißen und zur Klappe verschwinden, dann die zweite Gestalt, dann das Scheppern; fand 0:00:20 Herrn Schneider | Parken auf Herrn Schneiders Platz | Der Lieferwagen soll nicht abgeschleppt werden |
| 10 Zeynep | stand für Cans Streich Schmiere; wusste, dass Can mit der Maske im Vorratsraum wartete; sah 23:45 Fatmas ausgebeulte Tasche | im Steinbogen: Can mit dem Gesicht rannte vorbei und streifte sie; danach Schneiders zweiter Ruf; dann das Scheppern | Schmiere | Can schützen (Mitschuld) |

Zeyneps Schmiere hat einen klaren Zweck: Sie hält den Fluchtweg frei. Vom Bogen sieht sie den Durchgang entlang bis zur
Klappe. Sie soll aufpassen, dass niemand aus dem Kaminsaal herüberkommt und Can nach dem Erschrecken entwischen kann.

### WELT 7.3 Die vier Tandems (Rollen 11–18)

Jede Zusatzrolle hat: einen Teil der gemeinsamen Mini-Intrige, ein eigenes Geheimnis und **ein** Rand-Indiz, das etwas
bestätigt, was schon die Rollen 5–10 tragen. Keine Zusatzrolle weiß mehr als die Rollen 5–10 (ABG D-23).

M1 bis M9 sind die neun Meilensteine aus A:109-112 (LÜ L-01): M1 Ahmet-Alibi, M2 Fatma-Alibi, M3 Can-Alibi,
M4 Ahmets Mietschwindel, M5 Fatmas Münzschatulle, M6 Cans Leuchtmaske, M7 Ollis Bogentür-Schaden, M8 Fundort des
Bunds, M9 Schlüsselbeweis (XD3 mit FN3).

**Tandem 1 – Sibel (11) & Damir (12): Das Vitrinen-Missgeschick um 21:00**
- Gemeinsam: Damir begleitet Sibel zur Turm-Toilette. Sibel erschrickt vor der Rüstung, stößt gegen die Vitrine: Sprung.
  Damir kehrt die paar Splitter unter den Sockel der Rüstung („unter den Teppich gekehrt“, nur als Wortspiel; es gibt
  keinen Teppich). Beide fürchten: Kommt die Vitrine zur Sprache, hängt man den Sprung jemand anderem an.
- Sibel: Geheimnis: Sie hat die Vitrine beschädigt. Ziel: Die Rüstung soll aus dem Turmgang verschwinden.
  Rand-Indiz (bestätigt Cans Fluchtweg, M3/M6): „Im Dunkeln huschte ein leuchtendes Gesicht vom Durchgang quer durch den
  Kaminsaal zur Bogentür. Dann war es weg.“
- Damir: Geheimnis: Er hat die Splitter versteckt. Kanon-Färbung: Herr Schneider ärgert sich, dass er das Teegeschirr
  des Schlosses benutzt. Rand-Indiz (bestätigt Ahmets Alibi, M1): „Beim Knall hab ich mich hinter der Theke am Ostende
  geduckt. Direkt neben mir hat Ahmet geflüstert: ‚Marek? Ich bin's, Ahmet.‘ Beim Scheppern war er noch da.“
- Nebenwirkung: Der Sprung von 21:00 zeigt, dass Fatma die Scheibe nur angehoben hat (stützt ihre Fassung, nicht ihr
  Alibi).

**Tandem 2 – Hana (13) & Serkan (14): Das Kamin-Desaster um 23:30**
- Gemeinsam: Hana feuert um 23:20 den Kamin an, um heimlich einen alten Liebesbrief zu verbrennen, und vergisst die
  Kaminklappe. Serkan sieht das Papier. Um 23:30 reißt er die Lichtschacht-Klappen auf. Beim Lüften verrät er ihr seinen
  Plan mit den Wunderkerzen. Sie decken sich gegenseitig.
- Hana: Geheimnis: der Brief (halb verkohlt in der Nische; an wen, bleibt ihr Geheimnis, kein Name in der Welt). Ziel:
  Den Kamin wieder zum Ziehen bringen und sich bei Herrn Schneider für den Ruß entschuldigen. Rand-Indiz (bestätigt die
  Reihenfolge bei Can, M3): „Im Dunkeln huschte ein leuchtendes Gesicht durch den Kaminsaal zur Bogentür. Kurz danach
  roch es nach ausgeblasenen Kerzen, mit dem Luftzug aus Richtung Theke.“ Sie kann nicht sagen, ob es „vor dem
  Scheppern“ war; sie hört es nicht. Der Geruch kommt einige Sekunden nach dem Erlöschen an (WELT §3.6); er stützt Cans
  Alibi, beweist es aber nicht (P3-03).
- Serkan: Geheimnis: Wunderkerzen im Auto (offene Flamme ist verboten); um 23:56 wollte er sie holen. Stufe 1: „Ich
  wollte Decken aus dem Auto holen.“ Ziel: Alle sicher nach Hause fahren. Rand-Indiz (bestätigt: der Bund blieb im
  Keller, M8): „Von kurz vor zwölf bis nach zwölf stand ich am Außentor. Es war abgeschlossen. Durchs Außentor ist niemand
  hinaus, und die Innentür ging die ganze Zeit nicht auf.“

**Tandem 3 – Azra (15) & Wojtek (16): Der falsche Alarm um 20:15 und der Werkzeugkasten**
- Gemeinsam: 20:15 ruft Azra „Einbrecher an der Torte!“, Wojtek leuchtet mit der Taschenlampe aus seinem Werkzeugkasten,
  es ist Olli („Ich wollte nur aufs Klo!“). Danach sieht Wojtek die halb leere Wachsdose; Tim: „Olli brauchte was für
  eine Schramme.“ Wojtek nimmt Azra das Versprechen ab, zu schweigen.
- Wojtek: Brachte Musikbox und Kopfhörer mit (Herr Schneider drohte 22:00, die Box einzukassieren); lieh Tim den
  Werkzeugkasten. Geheimnis: Das Wachs stammt aus seinem Kasten; er fürchtet, dass Herr Schneider auch ihn zur Kasse
  bittet. Ziel: Niemand soll wissen, dass das Möbelwachs aus seinem Kasten kam. Rand-Indiz (bestätigt Ollis
  Heimlichtuerei, M7): „In meinem Werkzeugkasten ist die Dose Möbelwachs halb leer, am Rand Holzstaub. Heute Morgen war
  sie neu.“
- Azra: Geheimnis (Kanon): Sie hat Fatma von der Münzschatulle erzählt; Herr Schneider fand es seltsam, wie lange sie vor
  der Vitrine stand. Ziel: Niemand soll denken, sie hätte Fatma angestiftet. Rand-Indiz (bestätigt Ahmets
  Heimlichtuerei, M4): „Um zwölf nach zwölf hat Ahmet am Kamin einen gefalteten Umschlag in
  den Ascheneimer geworfen.“ (P3R2-16)

**Tandem 4 – Aylin (17) & Tugba (18): Die Schlüssel- und Gästeliste**
- Gemeinsam (harmlos): Beim Einlass hakt Aylin die Gästeliste ab und lässt dabei heimlich alle Tugbas Dankeskarte für
  Herrn Schneider unterschreiben. Die Karte soll mit der Torte überreicht werden. Herr Schneider zeigt Aylin
  Sicherungskasten, Fach und Notlaterne und erklärt den Bund.
- Aylin: Geheimnis (Kanon): Sie hat den Quittungszettel „Miete: 0 Euro. Schneider“ (22:30) und will ihr Geld zurück, ohne
  Ahmet bloßzustellen. Sie weiß auch: Herr Schneider muss jeden Schaden melden und zahlt kleine Schäden oft selbst.
  Ziel: Ihr Geld zurückbekommen, ohne Ahmet vor allen bloßzustellen. Rand-Indiz (bestätigt Ahmets Heimlichtuerei, M4):
  der Quittungszettel.
- Tugba: **ganz unbelastet** (W-17). Kein Nebendelikt, keine Lüge, kein zurückgehaltenes Wissen zum Fall. Ihre
  „Geheimniskarte“ ist nur die Überraschung mit der Dankeskarte. Ziel (Kanon): Den Abend retten, Torte um halb eins,
  egal was passiert. Offenes Wissen, das sie jedem sofort sagt (bestätigt FN3, M9): „Um halb acht hat Olli am kalten Kamin
  den linken Arbeitshandschuh in die Nische gelegt. Der war schwarz vom alten Ruß. Den rechten hatte er in der
  Westentasche. Den linken hat er dort liegen lassen.“

Bei ungerader Zusatzzahl spielt die letzte Rolle ihr Tandem allein (E6). Fehlt Damir, fehlt nur sein Rand-Indiz; Marek
oder das Abwesenheitsblatt tragen Ahmets Alibi.

### WELT 7.4 Herkunfts- und Kopftuchprüfung (ABG D-33, TON:63-64)

| Verfehlung | Trägerinnen und Träger | Herkünfte | Regel erfüllt |
|---|---|---|---|
| Nebendelikt einer Kernrolle | Ahmet, Fatma, Olli, Can | bosnisch, kurdisch, deutsch, türkisch | ja |
| Nebendelikt | Kernrollen, Tim, Marek, Zeynep, Sibel, Hana, Serkan | bosnisch, kurdisch, deutsch, türkisch, polnisch | ja |
| Lüge (Stufe 1) | Ahmet, Fatma, Olli, Can, Serkan | bosnisch, kurdisch, deutsch, türkisch | ja |
| Verschweigen | Lejla, Emine, Tim, Joanna, Marek, Zeynep, Sibel, Damir, Hana, Wojtek, Azra, Aylin | bosnisch, türkisch, deutsch, polnisch, kurdisch | ja |
| Kopftuch unbelastet | Tugba | – | ja (Fatma und Emine sind belastet) |

---

## 2. Zeitstrahl

### WELT 3.1 Takt-Entscheidung: Scheppern um 23:58:30 (W-05)

Der Auftrag verlangt 23:58:30 (A:130) und „30 Sekunden“ (A:73). Im Kanon-Takt (23:58:40) wäre Can um 23:58:30 noch
zwischen Klappe und Durchgang; Cans Alibi wäre falsch. Deshalb gilt **ein neuer Sekundentakt** nach ABG §3.15, mit den
Wegen aus 2.8 neu gerechnet. Ergebnis der Prüfung: Can ist 10 s vor dem Scheppern an Tim vorbei, 9 s vorher durch
den Steinbogen, 7 s vorher vor der Bogentür. Herr Schneider brüllt 8 s vor dem Scheppern zum zweiten Mal, und zwar
nachdem Can den Bogen passiert hat. Olli braucht für alles nach dem Schlag 24 s. Kein Weg ist schneller als erlaubt.

Gedruckt wird: im Vorlesetext „kurz darauf“, auf Karten „23:58 Uhr“, Sekunden nur in Teil 90.

### WELT 3.2 Vor dem Abend

| Wann | Ort | Wer | Ereignis |
|---|---|---|---|
| Wochen vorher | – | Ahmet, Herr Schneider | Ahmet bekommt den Keller umsonst. Dafür gestaltet er das Programm des Adventsmarkts der Schlossstiftung |
| Wochen vorher | – | Ahmet, Marek | Ahmet bestellt das Buffet viel zu groß. Marek setzt eine Nachzahlung an: 150 € pro Gast, fällig heute Abend in Bargeld |
| vorher | Unibibliothek | Azra, Fatma | Azra erzählt Fatma von der Münzschatulle mit dem Wappen in der Schauvitrine |
| am Nachmittag | Schneiders Büro im Schloss | Lejla, Herr Schneider | Herr Schneider will eine Genehmigung für das mitgebrachte Essen sehen. Auf seinem Klemmbrett sieht Lejla das Belegungsblatt der Stiftung: „Saalmiete Schlosskeller: 0 Euro“ |
| am Nachmittag | zu Hause | Can | Can malt eine weiße Gespenstermaske mit grünlich-weißer Leuchtfarbe an |
| am Nachmittag | zu Hause | Serkan | Serkan legt eine Packung Wunderkerzen für die Mitternachtstorte in sein Auto |

### WELT 3.3 18:00 bis 23:49

| Zeit | Ort (Zone) | Wer | Ereignis |
|---|---|---|---|
| 18:00 | Windfang (W) | alle | Die Gäste kommen über die fünf Sandsteinstufen und das Außentor. Herr Schneider begrüßt knapp |
| 18:00 | Windfang, Durchgang | Aylin, Herr Schneider | Aylin hilft beim Einlass und hakt die Gästeliste ab. Herr Schneider zeigt ihr den Sicherungskasten und das Fach mit Ersatzsicherungen und Putzmitteln im Durchgang und die Notlaterne hinter der Vorratsraumtür: „Falls was ist.“ Er sagt ihr auch: Den Außentor-Schlüssel gibt es nur an seinem Bund und bei seiner Kollegin |
| 18:00 | Windfang (W), beim Einlass | Aylin, Tugba | Mit der Gästeliste lässt Aylin beim Einlass heimlich alle eine Dankeskarte für Herrn Schneider unterschreiben, während er die Gäste begrüßt. Tugba hat die Karte gebastelt und verwahrt sie danach in ihrem Notizbuch (P3R2-19) |
| 18:00 | Ost-Saal (1) | Ahmet, alle Gäste außer dem Detektiv | Ahmet sammelt am Jackenständer von allen 150 € „Miete“ in Bargeld ein, in einen Umschlag mit der Aufschrift „Miete Schlosskeller“. In seiner Jackentasche führt er eine Namensliste mit „150 € ✓“. Aylin zahlt nur unter Protest und will einen Beleg: „Den Beleg gibt's von Herrn Schneider.“ |
| 18:00 | hinter der Theke (4c) | Wojtek, Tim | Wojtek bringt Musikbox, Kopfhörer und seinen Werkzeugkasten mit. Tim leiht sich den Werkzeugkasten für den Abend; er will seine wackelige alte Mehrfachsteckdose richten. Er tut es nicht. Der Kasten steht ab jetzt hinter der Theke neben der Kaffeemaschine |
| 18:30 | Schlosshof, Turmgang (8) | Marek, Olli, Tim, Herr Schneider | Marek liefert das Essen über den Schlosshof und stellt den Lieferwagen auf Herrn Schneiders reservierten Platz („Am Telefon hieß es, das geht in Ordnung“). Herr Schneider: „Steht der um Mitternacht noch da, lass ich ihn abschleppen.“ Olli und Tim tragen die Warmhaltebehälter durch Hoftür, Turmgang und Bogentür |
| 18:35 | vor der Bogentür (7/8) | Olli, Tim | Olli schrammt mit einem Warmhaltebehälter die geschnitzte Bogentür. Ein Beschlag reißt aus der gekalkten Wand. Holzsplitter und weißer Kalk bleiben an Ollis Pulli-Ärmeln |
| 18:45 | vor der Bogentür | Olli, Tim | Tim holt braunes Möbelwachs aus dem Werkzeugkasten und gibt es Olli. Olli reibt es mit seinem rechten Arbeitshandschuh in die Schramme und steckt den Handschuh in die Westentasche. Die Dose kommt zurück in den Kasten |
| 18:50 | vor der Bogentür | Herr Schneider, Olli, Tim | Herr Schneider entdeckt den Schaden. Er verlangt 2.000 € in Bargeld bis Mitternacht und schreibt es in seinen Quittungsblock. Er schließt Hoftür, Einfahrtstor und Außentor ab: „Keiner geht, bevor das bezahlt ist.“ Die übrigen Gäste merken nicht, dass die Tore zu sind |
| 19:00 | Buffetsaal | alle | Das Buffet ist eröffnet |
| 19:30 | Kamin-Nische (7) | Olli, Tugba | Olli wärmt sich am noch kalten Kamin die Hände. Er legt seinen linken Arbeitshandschuh in die Nische; der Handschuh wird schwarz vom alten Ruß. Er vergisst ihn dort. Tugba sieht es |
| 20:15 | Vorratsraum (5) | Olli, Azra, Wojtek, Tim, viele | Lacher. Olli sucht die Toilette, nimmt die falsche Tür neben der Anrichte und steht im dunklen Vorratsraum vor der Mitternachtstorte. Er stößt ans Regal. Azra sieht jemanden in der dunklen Tür verschwinden und ruft: „Einbrecher an der Torte!“ Wojtek holt seine Taschenlampe aus dem Werkzeugkasten und leuchtet hinein. Olli: „Ich wollte nur aufs Klo!“ Alle lachen |
| 20:15 | hinter der Theke (4c) | Wojtek, Azra, Tim | Beim Zurücklegen der Lampe sieht Wojtek die Dose Möbelwachs: halb leer, am Rand Holzstaub. Tim: „Olli brauchte was für eine Schramme.“ Wojtek bittet Azra: „Sag keinem, dass das Wachs aus meinem Kasten ist.“ Azra verspricht es |
| 21:00 | Turmgang (8) | Sibel, Damir | Lacher. Damir begleitet Sibel zur Turm-Toilette. Sibel hält die Ritterrüstung für einen Menschen, schreit und stolpert rückwärts gegen die Schauvitrine. Die Scheibe bekommt einen Sprung, ein paar Splitter springen von der Ecke. Damir kehrt sie unter den Sockel der Rüstung. Beide schweigen. Den Schrei hört man bis in den Kaminsaal. Als Damir es im Ost-Saal erzählt, lachen alle; vom Sprung erzählt er nichts. Vom Sprung weiß niemand sonst. Seit 21:00 ist die Scheibe lose |
| 22:00 | Anrichte (4c) | Herr Schneider | Er zündet die drei roten Kerzen im Messingkerzenständer an. Es sind die einzigen echten Kerzen im Keller |
| 22:00 | Ost-Saal (1) | Herr Schneider, Wojtek | Er verlangt leise Musik und droht, Wojteks Box einzukassieren |
| 22:30 | Ost-Saal, Tafel West | Aylin, Herr Schneider | Aylin fragt nach einem Beleg für die Miete. Er schreibt auf einen Quittungszettel: „Miete: 0 Euro. Schneider“. Durchschlag auf seinem Klemmbrett. Aylin steckt den Zettel in ihre Ledermappe |
| 23:00 | Ost-Saal (1) | Tugba, alle | Zu Beginn ihres Ratespiels, bevor Herr Schneider an der Theke laut wird, sammelt Tugba alle Handys in den Handykorb ein, auch Tims und Ollis an der Kaffeemaschine und das des Detektivs. Nur Joanna behält ihres als Fotografin. Vor 0:05 holt sich niemand seins zurück (K-23, P3R2-14) |
| 23:00 | vor der Theke (4b) | Herr Schneider, Olli, Tim | Lauter Streit um die 2.000 €. Herr Schneider, sehr laut: „Bis Mitternacht. Sonst ruf ich die Polizei!“ Tim steht an der Kaffeemaschine und hört alles. Fast alle anderen sitzen im Ost-Saal bei Tugbas Ratespiel; durch die offene Tür hören sie nur, dass Herr Schneider brüllt, die Worte gehen im Spiel unter (P3R2-13) |
| 23:20 | Kamin-Nische (7) | Hana, Serkan | Hana feuert den Kamin an, ohne die Kaminklappe zu öffnen. Sie will heimlich einen alten Liebesbrief verbrennen. Einen alten Arbeitshandschuh in der Nische schiebt sie zur Seite. Serkan sieht, wie sie Papier in den Kamin stopft |
| 23:30 | Kaminsaal (7) | Hana, Serkan, Herr Schneider, Aylin | Lacher. Dichter Qualm aus dem Kamin füllt den Kaminsaal, alle husten. Serkan reißt die Klappen der Lichtschächte auf. Herr Schneider löscht das Feuer und schimpft über den Ruß an der Wand. Aylin holt Putzmittel und Lappen aus dem Fach im Durchgang; Hana wischt den Ruß ab. Der Brief ist nur halb verkohlt und liegt unter der Asche in der Nische. Serkan verrät Hana beim Lüften seinen Plan mit den Wunderkerzen. Seitdem zieht Luft vom Buffetsaal durch den Durchgang in den Kaminsaal |
| 23:40 | Turmgang, Vitrine (8) | Fatma, Emine | Fatma hebt die gesprungene, lose Scheibe an und nimmt die Münzschatulle. Sie will das Wappen mit den zwei Löwen abzeichnen und die Schatulle am Montag zurückbringen. Dabei bricht die Ecke: Scherben fallen zu Boden, feine Splitter bleiben am rechten Ärmel ihres Mantels. Emine kommt gerade die Wendeltreppe von der Toilette herunter und sieht es. Fatma: „Montag bring ich sie zurück. Versprochen.“ Emine verspricht zu schweigen |
| 23:40 | Kaminsaal (7) | Hana | Im Kaminsaal ist nach dem Qualm nur Hana; sie wischt mit dem Gesicht zur Wand Ruß ab. Fatma und Emine gehen unbemerkt durch. Can und Zeynep setzen sich erst nach 23:45 mit dem Gebäck an die lange Tafel, Sibel kommt kurz vor 23:50 auf die Wandbank Süd (P3R2-20) |
| 23:45 | linkes Buffet (2) | Zeynep, Fatma | Zeynep holt Gebäck für sich und Can. Sie sieht, dass Fatmas Umhängetasche auffällig ausgebeult ist |

### WELT 3.4 Sekundenprotokoll 23:50:00 bis 0:01:00

**Stand um 23:50:00:** Herr Schneider und Ahmet vor der Theke (4b), Ahmet mit dem dicken Umschlag. Fatma am linken
Buffettisch beim Gebäck, Emine dahinter (2). Joanna in der Saalmitte. Olli und Tim vor der Bogentür (7). Can und Zeynep
an der langen Tafel im Kaminsaal (7). Hana an der Kamin-Nische, Sibel auf der Wandbank Süd (7). Lejla und Marek
decken im Ost-Saal Tortenteller und Gläser (1). Damir schenkt im Ost-Saal Tee aus. Serkan, Azra, Wojtek (Wandbank Ost,
Box), Aylin (Tafel West), Tugba (Wandtafel), Detektiv (Tafel Ost) im Ost-Saal.

| Zeit | Zone | Ereignis | Lautstärke |
|---|---|---|---|
| 23:50:00 | 7 | Tim klemmt sich an der schweren Bogentür den Finger ein: „Au! Mein Finger!“ Olli und Tim wollten nachsehen, ob das Wachs die Schramme noch verdeckt | laut |
| 23:51:00 | 4b | Herr Schneider zu Ahmet: „Um zwölf sag ich allen, was der Keller gekostet hat.“ Ahmet hält den dicken Umschlag. Joanna fotografiert die Szene heimlich aus der Saalmitte (4 m; sie hört die Worte nicht). Zeitstempel des Fotos 23:51 | leise |
| 23:51:30–23:52:30 | 4a → 6 → 7 → 8 | Herr Schneider geht über die Klappe, durch Durchgang, Kaminsaal und Bogentür zur Vitrine. Gegen 23:52:15 geht er an Olli und Tim vorbei | – |
| 23:52:00 | 7 | Olli zu Tim: „Ich hol dir Eis. Und dann red ich mit Schneider.“ Nur Tim hört es; Herr Schneider ist noch über 3 m entfernt | leise |
| 23:52:30–23:54:00 | 7 → 6 → 2 → 1 | Olli geht in den Ost-Saal und setzt sich an den Kopf der Tafel. Der Detektiv sieht ihn | – |
| 23:53:00 | 8 | Herr Schneider findet die angehobene Scheibe, das leere Samtbett, die Scherben: „Wer war an der Vitrine?“ Tim vor der Bogentür hört es | laut |
| 23:53:00 | 2 | Ahmet hat gesehen, wie Joanna das Handy sinken ließ. Ahmet zu Joanna: „Zeig das Foto bitte keinem.“ Joanna verspricht es | leise |
| 23:53:30 | 2 → 1 | Ahmet und Joanna gehen in den Ost-Saal | – |
| 23:54:00–23:54:20 | 7 → 6 → 4a → 4c → 5 | Can geht mit der Maske über Steinbogen, Durchgang, Klappe, hinter der Theke in den Vorratsraum vor das Regal mit der Torte. Im Buffetsaal sind nur Fatma und Emine; sie tuscheln über die Tasche und achten nicht auf die Klappe. Can sieht die beiden. Im Kaminsaal achtet niemand auf Can: Tim schaut auf seinen Finger, Hana wischt mit dem Gesicht zur Wand Ruß ab, Sibel döst auf der Wandbank Süd, den Schal bis übers Kinn | – |
| 23:54:00–23:54:10 | 7 → 6 | Zeynep stellt sich in den Steinbogen, Rücken am Nordpfeiler (Schmiere) | – |
| 23:54:20 | 5 | Can schaltet im Vorratsraum das Licht aus. Die Maske leuchtet grünlich-weiß | – |
| 23:54:40–23:55:50 | 8 → 7 → 6 → 4a → 2 | Herr Schneider kommt zurück. Im Steinbogen macht Zeynep ihm Platz. Er geht zum linken Buffet | – |
| 23:55:00 | 1 | Tugba: „Alle in den Ost-Saal! Um zwölf gibt's Torte!“ Die Handys liegen seit dem Ratespiel im Korb; nur Joanna hat ihres | laut |
| 23:55:00–23:55:10 | 1 | Der Detektiv geht auf den Ehrenplatz der blinden Kuh, bekommt die Augenbinde. 23:55:05 setzt Wojtek ihm seine Kopfhörer auf; laute Musik über die Akku-Box | – |
| 23:55:00–23:55:15 | 1 → 4a | Joanna geht bis an die Tür zum Durchgang und ruft: „Gruppenfoto um zwölf, mit Torte! Alle in den Ost-Saal!“ Sie sieht Zeynep im Steinbogen („Komm gleich!“). Can ist nicht da. Herr Schneider kommt ihr im Durchgang entgegen | laut |
| 23:55:10–23:55:30 | 1 | Ahmet hängt seine schwarze Jacke an den Jackenständer. Den Umschlag behält er in der Hand | – |
| 23:55:15–23:55:40 | 4a → 1 | Joanna geht zurück und stellt sich in die offene Tür zum Ost-Saal | – |
| 23:55:30–23:55:45 | 1 → W | Serkan geht durch den Buffetsaal und die Innentür (quietscht) zum Außentor. Er will die Wunderkerzen aus dem Auto holen | laut (Tür) |
| 23:55:30–23:55:40 | 1 → 3 | Lejla geht an den rechten Buffettisch und deckt die Warmhaltebehälter zu | – |
| 23:55:30–23:55:40 | 1 → 4d | Marek geht hinter die Theke ans Ostende und füllt die Saftkrüge, Gesicht zur Anrichte Ost | – |
| 23:55:30–23:56:00 | 7 → 6 → 4a → 4c | Tim geht mit dem Finger in der Hand durch den Steinbogen (an Zeynep vorbei), Durchgang, Klappe, hinter der Theke zur Kaffeemaschine | – |
| 23:55:50 | 2 | Herr Schneider am linken Buffettisch bei Fatma | – |
| 23:56:00 | 2 | Herr Schneider sieht Glassplitter am rechten Ärmel von Fatmas Mantel: „Die Schatulle. Um Punkt zwölf geh ich raus und ruf die Polizei.“ Emine hört es (2,2 m), sonst niemand | leise |
| 23:56:00 | W | Serkan findet das Außentor verschlossen. Er schaltet seine LED-Lampe an und leuchtet aufs Schloss | – |
| 23:56:30–23:56:50 | 2 → 4d | Herr Schneider geht zum Ostende der Theke | – |
| 23:56:30–23:56:50 | 1 → 4b | Olli steht vom Kopf der Tafel auf und geht durch die Tür (an Joanna vorbei) zum Eiskübel | – |
| 23:56:50–23:56:58 | 1 → 4d | Ahmet geht an Joanna vorbei und schlüpft am Ostende hinter die Theke, neben Marek. Marek sieht den dicken Umschlag. Lejla sieht es vom rechten Buffet | – |
| 23:57:00 | 4d/4b | Herr Schneider zu Olli: „Zweitausend, bis zwölf.“ Hören: Olli, Ahmet, Marek (Rücken zur Theke), Tim, Joanna | leise |
| 23:57:00 | 1 | Joanna tippt ihre Liste in die Notizen ihres Handys. Zeitstempel 23:57 (Wortlaut 5.4) | – |
| 23:57:00–23:57:06 | 2 → 4a | Fatma geht mit der Tasche vom linken Buffet zur Theken-Klappe. Sie will Herrn Schneider die Schatulle zurückgeben | – |
| 23:57:00–23:57:03 | 5 | Can stellt sich im Dunkeln direkt hinter die angelehnte Vorratsraumtür | – |
| 23:57:25–23:57:30 | 4d → 4c | Herr Schneider geht hinter der Theke an Ahmet und Marek vorbei zu Tim an die Kaffeemaschine. Ahmet kommt nicht zu Wort | – |
| 23:57:30–23:57:40 | 1 | Joanna geht von der Tür zum Handykorb. Sie stellt ihr Handy im Halter neben den Korb, Kamera auf den Ehrenplatz | – |
| 23:57:30–23:57:35 | 1 → 4d | Damir kommt mit der großen Teekanne aus dem Ost-Saal ans Ostende hinter die Theke. Er will zum Teekocher, aber Herr Schneider steht im Weg. Er wartet hinter Marek. Auf den Eiskübel achtet er nicht (heiße Kanne) | – |
| 23:57:40 | 4c | Herr Schneider zu Tim: „Nicht die alte Leiste!“ Der ganze Buffetsaal hört es, auch Can hinter der Tür | laut |
| 23:57:50 | 4c | Tim steckt die Kaffeemaschine für den Tortenkaffee trotzdem in seine Mehrfachsteckdose | – |
| **23:58:00** | 4c | **Knall.** Ein Steckplatz verschmort, die Hauptsicherung fliegt. Überall Strom aus. Es leuchten nur noch die Kerzen an der Anrichte und das Notausgangsschild | sehr laut |
| 23:58:00 | – | Ahmet kauert sich an Mareks Beine. Damir kauert am Ostende. Emine kauert hinter dem linken Buffettisch. Lejla kauert am rechten Buffettisch. Marek bleibt stehen. Olli bleibt am Eiskübel stehen. Tim tastet sich hinter der Theke nach Westen. Joanna stößt den Handyhalter um; ihr Handy rutscht zwischen die anderen in den Korb | – |
| 23:58:01–23:58:05 | 4a → 2 | Fatma geht von der Klappe hinter den linken Buffettisch und kauert sich hin | – |
| 23:58:02 | 4c | Herr Schneider: „Ruhe! Ich hol die Notlaterne.“ Er geht hinter der Theke 2,2 m zur Vorratsraumtür (bis 23:58:05) | laut |
| 23:58:03 | 4d | Ahmet: „Marek? Ich bin's, Ahmet.“ Marek und Damir hören es | leise |
| 23:58:05 | 4c | Herr Schneider zieht die angelehnte Vorratsraumtür auf. Sie quietscht nicht. Tim ist schon am Westende hinter der Theke, einen Schritt vor der Klappe (P3R2-11) | – |
| 23:58:06 | 2 | Fatma: „Emine? Ich bin's, Fatma.“ | leise |
| 23:58:06 | 5 → 4c | Can glaubt, die blinde Kuh wird gebracht, und springt mit der leuchtenden Maske heraus | – |
| 23:58:07 | 4c | Can: „Buuuh!“ | laut |
| 23:58:08 | 4c | Herr Schneider packt Can an der gelben Kapuze: „Hab ich dich!“ Ab 23:58:09 Gedächtnislücke | sehr laut |
| 23:58:09 | 6 | Tim erreicht den Sicherungskasten. Die Stirnlampe rutscht ihm vom Hals. Er findet den Hauptschalter nicht | – |
| 23:58:08–23:58:17 | 4c | Can und Herr Schneider ringen im Kerzenlicht. Marek sieht das leuchtende Gesicht und Schneiders Umriss | – |
| 23:58:10–23:58:15 | 4b → 4a | Olli geht vom Eiskübel vor der Theke nach Westen bis vor die Theke beim Westende. Er bleibt 1,4 m neben der Klappe im Dunkeln stehen. Er will mit Herrn Schneider reden | – |
| 23:58:12 | 6 | Tim: „Wo ist denn der Hauptschalter?“ | leise |
| 23:58:17 | 4c | Can reißt sich los und rennt hinter der Theke nach Westen | – |
| 23:58:18 | 4c | Herr Schneider: „Stehen bleiben!“ | sehr laut |
| 23:58:19 | 4a | Can rennt durch die Klappe, 1,4 m an Olli vorbei. Olli sieht das leuchtende Gesicht | laut (Schritte) |
| 23:58:19 | 4a → 4c | Olli geht durch die Klappe hinter die Theke zur Vorratsraumtür (bis 23:58:25) | – |
| 23:58:20 | 6 | Can rennt 1 m an Tim vorbei | laut (Schritte) |
| 23:58:21 | 6 | Can rennt durch den Steinbogen und streift Zeynep | – |
| 23:58:21–23:58:22 | 7 | Can rennt quer durch den Kaminsaal. Hana und Sibel sehen das leuchtende Gesicht | laut (Schritte) |
| 23:58:22 | 4c | Herr Schneider: „Stehen bleiben, hab ich gesagt!“ (Can ist schon im Kaminsaal) | sehr laut |
| 23:58:23 | 7 | Can vor der Bogentür. Er stopft die Maske in die Bauchtasche seines Pullis. Das Leuchten ist weg | – |
| 23:58:24–23:58:40 | 8 | Can tastet sich durch den dunklen Turmgang und die Wendeltreppe hinauf. Etwa 23:58:40 schließt er sich auf der Turm-Toilette ein | – |
| 23:58:25 | 4c | Olli im Kerzenlicht vor der Vorratsraumtür: „Lass uns reden, nur kurz.“ Marek sieht vom Ostende aus eine zweite Gestalt von der Klappe her ins Kerzenlicht kommen, nur als Umriss | leise |
| 23:58:26 | 4c | Herr Schneider packt Olli am Ärmel und zischt: „Zweitausend. Sonst Polizei.“ | leise |
| 23:58:29 | 4c | Olli greift in Panik den Messingkerzenständer am Fuß. Holzsplitter und weißer Kalk von seinem Ärmel bleiben im weichen Wachs am Fuß kleben. Rote Wachstropfen fallen auf den rechten Arbeitshandschuh, der aus seiner Westentasche hängt | – |
| **23:58:30** | 4c | **Scheppern:** ein dumpfer Schlag, Poltern, Metall scheppert über den Steinboden. Die Kerzen fallen und erlöschen. Es riecht nach frisch erloschenem Wachs; der Luftzug trägt den Geruch Richtung Kaminsaal. Herr Schneider fällt rückwärts in den Vorratsraum und bleibt direkt hinter der Tür liegen (bis 23:58:32) | sehr laut |
| 23:58:31–23:58:33 | 4c → 5 | Olli in den dunklen Vorratsraum | – |
| 23:58:35 | 5 | Olli reißt in Panik den Schlüsselbund von der Gürtelschlaufe. Er denkt: Mit dem Schlüssel komm ich raus, bevor das Licht angeht. Gleich danach weiß er: Flucht macht alles schlimmer. Der Bund klimpert | leise |
| 23:58:36–23:58:49 | 5 → 4c → 4a → 4b | Olli tastet sich zurück: Tür, hinter der Theke nach Westen, Klappe, vor der Theke nach Osten zum Eiskübel | – |
| 23:58:49 | 4b | Olli schiebt den Bund unter die Eiswürfel. Das Eis klirrt. Niemand ist näher als 1,9 m | leise |
| 23:58:50–23:58:54 | 4b → 3 | Olli kriecht zum rechten Buffettisch und kauert sich neben Lejla | – |
| 23:58:55 | 3 | Olli: „Lejla? Ich bin's, Olli.“ | leise |
| 23:59:30 | 1 | Joanna findet ihr Handy im Korb am Halter und schaltet die Aufsteckleuchte an, dann die Taschenlampen der anderen Handys. Der Kopf der Tafel ist leer | – |
| 23:59:40 | 6 | Tim findet seine Stirnlampe am Boden und schaltet sie an. Er sieht Zeynep im Steinbogen stehen | – |
| **0:00:00** | 6 | **Licht.** Tim schaltet die Hauptsicherung ein. Der Vorratsraum bleibt dunkel (Schalter innen) | – |
| 0:00:05 | – | Alle Kauernden stehen auf: Ahmet (Umschlag in der Hand), Damir, Emine, Fatma (Tasche), Lejla, Olli. Alle schauen zur Theke: Der Kerzenständer liegt am Boden, Herr Schneider fehlt | – |
| 0:00:05–0:00:08 | 3 → 4b | Olli geht zum Eiskübel und bleibt dort stehen | – |
| 0:00:10–0:00:16 | 4d → 4c | Marek geht hinter der Theke zur Vorratsraumtür und macht sie ganz auf | – |
| 0:00:18 | 5 | Marek schaltet im Vorratsraum das Licht an | – |
| 0:00:20 | 5 | Marek: „Hier liegt Herr Schneider!“ Lejla eilt als Apothekerin hin | sehr laut |
| 0:00:30–0:01:00 | 4b → 4a → 6 | Olli nimmt obenauf eine Handvoll Eis in eine Serviette und bringt sie über die Klappe in den Durchgang zu Tim | – |
| 0:00:35 | 1 | Tugba nimmt dem Detektiv Augenbinde und Kopfhörer ab: „So, Augen auf. Das war nicht die Überraschung.“ | – |
| 0:01:00 | 6 | Olli zu Tim: „Hier, dein Eis. Hat gedauert.“ Can kommt von der Turm-Toilette herunter. Serkan schaltet seine Lampe aus | – |

### WELT 3.5 0:01 bis 0:15

| Zeit | Ort | Wer | Ereignis |
|---|---|---|---|
| 0:01:30 | Kaminsaal, Wandbank West | Can, Zeynep | Can setzt sich auf die Wandbank. Zeynep geht zu ihm |
| 0:01:30 | Vorratsraum | Herr Schneider, Lejla | Herr Schneider kommt zu sich: dicke Beule, Gedächtnislücke. „Mein Kopf.“ Lejla holt das Kühlpack aus dem Erste-Hilfe-Kasten im Regal |
| 0:02:00 | Vorratsraum | Herr Schneider | „Mein Schlüsselbund! Der ist weg!“ |
| 0:02:40–0:02:45 | Windfang → Buffetsaal | Serkan | Serkan kommt durch die Innentür (quietscht) und ruft unter dem Notausgangsschild: „Das Tor ist zu. Abgeschlossen.“ |
| 0:03 | Buffetsaal, unter dem Notausgangsschild | alle | Tor zu, Bund weg, hinter den Mauern kein Empfang. Aylin: „Den Schlüssel fürs Außentor gibt's nur an seinem Bund und bei seiner Kollegin.“ Die Gruppe sitzt bis zum Morgen fest |
| 0:05 | Ost-Saal, Handykorb | Tugba | Tugba gibt die Handys zurück. Keines hat Empfang |
| 0:10 | Kaminsaal, Wandbank West | Azra | Azra holt ihren Skizzenblock von der Wandbank West und bleibt dort sitzen (K-24) |
| 0:11 | Buffetsaal → Kaminsaal | Ahmet | Ahmet geht zum Kamin |
| 0:12 | Kamin-Nische, Ascheneimer | Ahmet, Azra | Ahmet nimmt das Geld aus dem Umschlag und steckt es in die Hosentasche. Den leeren Umschlag faltet er und wirft ihn in den Ascheneimer neben der Kamin-Nische. Azra sieht es (4 m, volles Licht) |
| 0:13 | Buffetsaal | Ahmet | Ahmet steht wieder vor der Theke |
| 0:15 | Turmgang | Herr Schneider | Ihm fällt der Ersatzschlüssel der Stiftung ein. Er holt ihn aus dem Schlüsselkasten neben der Hoftür. Damit öffnet er Hoftür, Turm und die Seitentür vom Schlosshof ins Erdgeschoss. Außentor und Einfahrtstor öffnet er nicht. Hof und Garten sind hoch ummauert, die Fenster vergittert. Alle bleiben bis zum Morgen |

**Nach dem Licht greift niemand außer Olli in den Eiskübel** (W-19). Olli nimmt um 0:00:30 nur obenauf Eis. Das
Kühlpack kommt aus dem Erste-Hilfe-Kasten. Der Bund liegt deshalb bis zur Untersuchung unentdeckt unter dem Eis.

Ausblick (nicht Teil dieses Zeitstrahls): 0:20 Auftrag an den Detektiv; Runden um 0:30, 1:15, 2:00; Anklage 2:45;
7:00 schließt Herrn Schneiders Kollegin das Außentor auf.

### WELT 3.6 Die Ereignisse der vier Tandems im Zeitstrahl

| Tandem | Zeit | Ereignis |
|---|---|---|
| 1 Sibel & Damir | 21:00 | Rüstung, Sprung in der Vitrine, Splitter unter den Sockel der Rüstung |
| 1 | 23:57:30–0:00:05 | Damir am Ostende, kauert neben Ahmet, hört dessen Flüstern |
| 1 | 23:58:21–23:58:22 | Sibel sieht das leuchtende Gesicht durch den Kaminsaal |
| 2 Hana & Serkan | 23:20, 23:30 | Brief im Kamin, Qualm, Serkan öffnet die Lichtschächte |
| 2 | 23:55:30–0:02:45 | Serkan am Außentor; niemand kommt in den Windfang |
| 2 | 23:58:21–23:58:22 und ab etwa 23:58:45 | Hana sieht das Gesicht; einige Sekunden später riecht sie erloschene Kerzen (Luftzug etwa 1 m/s über rund 14 m) |
| 3 Azra & Wojtek | 18:00 | Wojtek leiht Tim den Werkzeugkasten |
| 3 | 20:15 | falscher Alarm, Taschenlampe, halb leere Wachsdose |
| 3 | 23:55:05 | Wojteks Kopfhörer auf dem Detektiv |
| 3 | 0:12 | Azra sieht Ahmet am Ascheneimer |
| 4 Aylin & Tugba | 18:00 | Einlass mit Gästeliste, Dankeskarte, Aylin lernt Sicherungskasten, Fach und Bund kennen |
| 4 | 19:30 | Tugba sieht Olli den linken Handschuh in die Kamin-Nische legen |
| 4 | 22:30 | Aylins Quittungszettel |
| 4 | 23:55, 0:00:35, 0:05 | Tugbas blinde Kuh, Augenbinde ab, Handys zurück |

---

## 3. Lageplan

### WELT 2.1 Die acht Zonen und das Randfeld

Namen der Zonen wörtlich nach A:78-85. Teilfelder für die Marker (ABG D-37, LÜ L-18). Der Windfang ist kein
nummeriertes Spielfeld, steht aber als Randfeld W auf dem Plan (Serkans Platz, Außentor).

| Zone | Name (wörtlich) | Teilfelder | Gegenstände und Einrichtung |
|---|---|---|---|
| 1 | **Ost-Saal** | – | lange Tafel von Nord nach Süd, Kopf der Tafel am Nordende zur Tür hin, Sitzplätze Westseite und Ostseite; Jackenständer am Eingang (Ahmets schwarze Jacke); Wandtafel mit Ablaufplan an der Ostwand; Handykorb am Ostrand der Tafel; Wandbänke; Ehrenplatz der blinden Kuh im Süden; Wojteks Musikbox an der Wandbank Ost. Keine weitere Außentür (P3R2-01) |
| 2 | **Buffetsaal – Linkes Buffet** | „am“ und „hinter dem“ linken Buffettisch | linker Buffettisch: Gebäck, Brottasche mit Brot, Dips, Emines Thermoskanne |
| 3 | **Buffetsaal – Rechtes Buffet** | „am“ und „hinter dem“ rechten Buffettisch | rechter Buffettisch: Warmhaltebehälter mit warmem Essen |
| 4 | **Theke & Anrichte** | 4a Theke Westende mit Theken-Klappe (dazu der Platz vor der Theke am Westende) · 4b Vor der Theke mit Eiskübel (der Streifen vor der Theke von der Mitte bis vor das Ostende, mit dem Eiskübel) · 4c Hinter der Theke: Anrichte, Vorratsraumtür (mit Kerzenständer, Teekocher, Kaffeemaschine) · 4d Theke Ostende (die offene Kachel am Ostende und dahinter, mit der Anrichte Ost: Saft, Gläser, Servietten) | Buffettheke aus dunklem Holz (6 m); Theken-Klappe am Westende; Eiskübel vor dem Ostende; an der Nordwand: Spüle, Anrichte mit Messingkerzenständer, großer Teekocher, Kaffeemaschine an Tims Mehrfachsteckdose, Wojteks Werkzeugkasten auf dem Boden daneben, Anrichte Ost mit Saftkrügen, Gläsern, Tassen, Servietten |
| 5 | **Vorratsraum** | – | hinter der Theke; Regal mit der Mitternachtstorte, Regale mit Vorräten, Erste-Hilfe-Kasten mit Kühlpack im Regal, Notlaterne am Haken direkt hinter der Tür, Lichtschalter innen neben der Tür; **Fundort Herr Schneider** direkt hinter der Tür; kühl, fensterlos, einziger Zugang die Vorratsraumtür |
| 6 | **Durchgang mit Steinbogen** | – | kurzer, niedriger Gang (2 × 2 m) zwischen Buffetsaal und Kaminsaal; Getränkekisten (Nordwestecke); **Sicherungskasten mit der Hauptsicherung** an der Nordwand neben den Kisten, darunter ein Fach mit Ersatzsicherungen, Putzmitteln, Lappen; offener Steinbogen zum Kaminsaal (gehört zu Zone 6, W-04) |
| 7 | **Kaminsaal** | – | Kamin-Nische in der Westwand mit Ascheneimer daneben, lange Tafel, Wandbänke (Nord unter den Lichtschächten, West, Süd), zwei Lichtschächte mit Klappen in der Nordwand |
| 8 | **Turmgang & Turm** | 8a Turmgang · 8b Wendeltreppe und Turm-Toilette | Bogentür mit beschädigtem Beschlag (auf der Grenze 7/8), Ritterrüstung, Schauvitrine, Wendeltreppe zur Turm-Toilette, Hoftür zum Schlosshof (verschlossen), Schlüsselkasten der Stiftung neben der Hoftür; der übrige Turm ist mit Vorhängeschloss zu |
| W | Windfang (Randfeld) | – | Innentür zum Buffetsaal (schwer, quietscht, zu), Außentor (zweiflügelig, eisenbeschlagen, Kastenschloss) mit fünf Sandsteinstufen zum Parkplatz |

Lage der Zonen im Buffetsaal: Zone 4 ist der Streifen an der Nordwand mit der Theke (2 m hinter, 1 m vor der Theke).
Zone 2 ist die Westhälfte südlich davon, Zone 3 die Osthälfte. Saalmitte und Innentür liegen auf der Grenze 2/3.

**Feldnamen (wörtlich, gleich auf Blatt B, in MECH §10.2 und in allen Heften, P3-05):** 1 Ost-Saal · 2 Linkes Buffet ·
3 Rechtes Buffet · 4a Theke Westende mit Theken-Klappe · 4b Vor der Theke mit Eiskübel · 4c Hinter der Theke: Anrichte,
Vorratsraumtür · 4d Theke Ostende · 5 Vorratsraum · 6 Durchgang mit Steinbogen · 7 Kaminsaal · 8a Turmgang · 8b Wendeltreppe
und Turm-Toilette · W Windfang. Was in der Tabelle in Klammern steht, gehört in die Legende von Blatt A, nicht in den
Feldnamen. Ollis Warteplatz „vor der Theke beim Westende“ liegt in 4a, der Eiskübel in 4b, Cans Platz auf der
Wendeltreppe in 8b.

### WELT 2.2 Türen und Nachbarschaften

| Verbindung | Tür | Zustand | quietscht |
|---|---|---|---|
| Zone 1 Ost-Saal ↔ Buffetsaal (4d) | Holztür rechts neben der Theke | offen | ja, nur beim Bewegen der Tür |
| Buffetsaal (4c) ↔ Zone 5 Vorratsraum | Vorratsraumtür, einfache Holztür | angelehnt | **nein** |
| Buffetsaal (4a) ↔ Zone 6 Durchgang | Holztür links neben der Theke | offen | ja, nur beim Bewegen der Tür |
| Zone 6 ↔ Zone 7 Kaminsaal | offener Steinbogen, 1 m breit | offen | – |
| Zone 7 ↔ Zone 8 Turmgang | geschnitzte Bogentür aus Eiche | offen | ja, nur beim Bewegen der Tür |
| Buffetsaal ↔ W Windfang | Innentür unter dem grünen Notausgangsschild | zu | ja (laut) |
| W ↔ draußen | Außentor | verschlossen seit 18:50 | ja |
| Zone 8 ↔ Schlosshof | Hoftür | verschlossen seit 18:50 | ja |

Kette von West nach Ost: Turmgang – Bogentür – Kaminsaal – Steinbogen – Durchgang – Tür – Buffetsaal – Tür – Ost-Saal.
Turmgang und Kaminsaal erreicht man vom Buffetsaal **nur durch den Durchgang**. Hinter die Theke kommt man über die
Theken-Klappe am Westende oder über das offene Ostende.

### WELT 2.3 Maße (Kanon-Raster, 1 Kachel = 1 m, x nach Osten, y nach Süden)

| Raum | Lage | Größe |
|---|---|---|
| Turmgang | x 1–3, y 1–6 | 3 × 6 m |
| Vorratsraum | x 13–15, y 2–5; Tür (14/6) | 3 × 4 m |
| Kaminsaal | x 1–6, y 8–19; Bogentür (2/7) | 6 × 12 m |
| Durchgang | x 8–9, y 8–9; Steinbogen (7/9), Tür zum Buffetsaal (10/9) | 2 × 2 m, von Bogen bis Tür 4 m |
| Buffetsaal | x 11–18, y 7–18 | 8 × 12 m |
| Theke | x 12–17 auf y 9; Klappe (11/9) und Ostende (18/9) frei | 6 m lang |
| Ost-Saal | x 20–25, y 7–18; Tür (19/9) | 6 × 12 m |
| Windfang | x 14–15, y 20–21; Innentür (14/19), Außentor (14–15/22) | 2 × 2 m |

Feste Punkte (Mitte der Kachel):

| Punkt | x/y | Zone |
|---|---|---|
| Kerzenständer auf der Anrichte, Lichtmitte | 13,5/8,5 | 4c |
| vor der Vorratsraumtür (Ort des Schlags) | 14,5/7,5 | 4c |
| direkt hinter der Vorratsraumtür (Fundort) | 14,5/5,5 | 5 |
| Theken-Klappe | 11,5/9,5 | 4a |
| vor der Theke beim Westende | 12,5/10,5 | 4a |
| Eiskübel | 17,5/10,5 | 4b |
| Ostende der Theke (offen) | 18,5/9,5 | 4d |
| hinter der Theke an der Kaffeemaschine (Tim) | 16,5/8,5 | 4c |
| hinter der Theke am Ostende, Saftkrüge (Marek) | 17,5/8,5 | 4d |
| hinter der Theke ganz am Ostende (Ahmet); Damir kauert daneben, halb im offenen Ostende | 18,5/8,5 und 18,5/8,9 | 4d |
| am rechten Buffettisch (Lejla) | 16,5/13,5 | 3 |
| hinter dem linken Buffettisch (Emine, Fatma) | 11,5/13,5 | 2 |
| Tür zum Ost-Saal (Joanna 23:55:40–23:57:30) | 19,5/9,5 | 1 |
| Handykorb | 24,5/12,5 | 1 |
| Kopf der Tafel im Ost-Saal (Nordende der Tafel) | 22,5/10,5 | 1 |
| Jackenständer | 20,5/8,5 | 1 |
| Tafel Westseite (Aylin) | 21,5/13,5 | 1 |
| Tafel Ostseite (Azra, Detektiv bis 23:55) | 24,5/13,5 | 1 |
| Ehrenplatz der blinden Kuh (Detektiv, Tugba) | 24,5/16,5 | 1 |
| Wandbank Ost (Wojtek, Box) | 25,5/15,5 | 1 |
| Sicherungskasten, Standplatz davor (Tim) | 9,5/8,5 | 6 |
| Steinbogen (Zeynep, am Nordpfeiler) | 7,5/9,5 | 6 |
| vor der Bogentür | 2,5/8,5 | 7 |
| Kamin-Nische, davor (Hana) | 2,5/13,5 | 7 |
| Ascheneimer | 1,5/14,5 | 7 |
| Wandbank Süd (Sibel) | 3,5/18,5 | 7 |

### WELT 2.4 Entscheidung Eiskübel: Ostende (W-02)

Der Eiskübel steht **vor der Theke am Ostende** (17,5/10,5, Teilfeld 4b).

Begründung:
1. Der Auftrag stützt das Ostende selbst zweimal: Olli streitet „am Eiskübel“ mit Herrn Schneider (A:95), und Herr
   Schneider steht „am Ostende“ (A:50). Beides passt nur, wenn der Eiskübel am Ostende steht (1,4 m Abstand).
2. Der Kanon sagt dasselbe (`gegenstaende.json:271`).
3. A:81 lese ich als Aufzählung: „Westende mit Theken-Klappe“ · „Eiskübel“ · „Kerzenständer“ · „Ostende mit Saft und
   Servietten“. Die Legende des Lageplans schreibt „Eiskübel (vor dem Ostende)“, damit niemand stolpert.
4. Das Versteck bleibt geheim: Wer am Ostende **hinter** der Theke kauert (Ahmet 2,2 m, Damir 1,9 m, Marek 2,0 m),
   hört das leise Eisklirren im Tumult nicht (Grenze 1,5 m).

### WELT 2.5 Entscheidung Sicherungskasten: Durchgang (W-03), Geometrie des Durchgangs (LÜ L-07)

Der **Sicherungskasten hängt im Durchgang an der Nordwand, gleich östlich neben den Getränkekisten** (über der Kachel
9/8). Darunter liegt das Fach mit Ersatzsicherungen und Putzmitteln.

Begründung:
1. A:83 legt ihn ausdrücklich in Zone 6.
2. Im Durchgang hört Tim das Scheppern (Durchgang grenzt an den Buffetsaal). Im Kaminsaal hörte er es nicht. Erst so
   trägt Tim das Can-Alibi (A:106, A:109), auch wenn Marek nicht mitspielt.

Belegung des Durchgangs (2 × 2 m) in der Tatnacht:

```
          y=8   [Kisten 8/8]  [Tim vor dem Sicherungskasten 9/8]
 Bogen 7/9 ──── [  8/9  ]     [  9/9  ] ──── Tür 10/9 ──── Klappe 11/9
 (Zeynep am       Cans Fluchtweg läuft auf y = 9 von Ost nach West
  Nordpfeiler)
```

- **Tim** steht auf 9/8 vor dem Kasten, Gesicht zur Wand. Er steht nicht im Fluchtweg.
- **Zeynep** steht im Steinbogen, mit dem Rücken an den nördlichen Bogenpfeiler gedrückt. Der Bogen ist 1 m breit.
  Can kommt daran vorbei, streift sie aber.
- **Cans Fluchtweg:** Vorratsraumtür → hinter der Theke nach Westen → Klappe → Tür → 9/9 (1 m an Tim vorbei) → 8/9 →
  Steinbogen (streift Zeynep) → quer durch den Kaminsaal → vor die Bogentür → Bogentür → Turmgang → Wendeltreppe →
  Turm-Toilette. Bis vor die Bogentür 13,3 m, rennend (2,5 m/s) 5,3 s.
- Der **Steinbogen gehört zu Zone 6** (W-04). Wer im Bogen steht, hört wie im Durchgang. So erfüllt Zeynep A:54
  („noch vor dem Scheppern“). Das ist L-07 Lösung (c), aber im Bogen statt auf 8/9, damit niemand mitten im Gang steht.

### WELT 2.6 Licht

| Lichtquelle | Ort | an | Reichweite | Wirkung in der Tatnacht |
|---|---|---|---|---|
| Strom (Deckenlicht, elektrische Deko-Kerzen) | alle Räume außer Vorratsraum | bis 23:58:00, wieder ab 0:00:00 | voll | vor dem Knall erkennt jeder jeden im selben Raum |
| Lampe im Vorratsraum | Zone 5 | aus ab 23:54:20 (Can), an 0:00:18 (Marek) | voll | Can wartet im Dunkeln |
| **drei rote Kerzen im Messingkerzenständer** | Anrichte (4c) | 22:00 bis 23:58:30 | 2 m um 13,5/8,5 | einziges Licht hinter der Theke nach dem Knall; Vorratsraumtür hell (1,4 m), Klappe knapp dunkel (2,2 m) |
| grünes Notausgangsschild (Akku) | über der Innentür | immer | 1,5 m, nur Umrisse | erreicht weder Theke noch Buffettische |
| Leuchtmaske (nachleuchtend) | an Can | 23:54:20 bis 23:58:23 (dann in der Bauchtasche) | beleuchtet nichts | im Dunkeln von weitem als leuchtendes Gesicht sichtbar |
| Kaminfeuer | Kamin-Nische | 23:20 bis 23:30 | – | in der Tatnacht aus |
| Serkans LED-Taschenlampe | Windfang | 23:56:00 bis 0:01:00 | 3 m | hinter der geschlossenen Innentür, erreicht den Buffetsaal nicht |
| Joannas Aufsteckleuchte, dann Handylampen | am Handykorb (1) | ab 23:59:30 | 3 m | Ost-Saal; erreicht die Tür (5,8 m) nicht |
| Tims Stirnlampe | Durchgang (6) | ab 23:59:40 | 3 m | zeigt Zeynep im Steinbogen (2,2 m); die Klappe nicht (Wand neben der Tür), den Eiskübel nicht (8,2 m) (P3R2-10) |
| **Notlaterne** | am Haken direkt hinter der Vorratsraumtür | **nie** | – | Herr Schneider wollte sie holen; sie hängt unberührt |

**Lichtregel (W-23, ABG D-10):** Von 23:58:30 (Kerzen aus) bis 23:58:54 (Olli kauert bei Lejla) erreicht kein Licht
die Vorratsraumtür, die Theken-Klappe, den Eiskübel oder Ollis Weg. Kein Text darf das ändern.

### WELT 2.7 Hör-, Seh-, Fühl- und Riechregeln fürs Kammerspiel

Aus `wahrnehmung.json`, unverändert, plus W-04.

| Sinn | Regel |
|---|---|
| Räume fürs Hören | Ost-Saal · Buffetsaal (Zonen 2, 3, 4 sind **ein** Raum) · Vorratsraum · Durchgang mit Steinbogen · Kaminsaal · Turmgang mit Turm · Windfang |
| sehr laut | im selben Raum und in jedem direkt angrenzenden Raum hinter offener oder angelehnter Tür; auch durch Kopfhörer; zwei Räume weiter nicht; hinter geschlossener Tür nichts Genaues. Sehr laut sind: Knall, „Hab ich dich!“, beide „Stehen bleiben!“, Scheppern, „Hier liegt Herr Schneider!“ |
| laut | im selben Raum; im angrenzenden Raum nur bis 3 m von der Tür. Laut sind: normale Rufe, rennende Schritte, quietschende Türen |
| leise | im selben Raum bis 3 m. Leise sind: Flüstern, Schneiders Einzeldrohungen (W-07), Gehen, Klimpern des Bunds, Eisklirren |
| in der Tür | Wer in einer offenen Tür steht, hört wie in beiden Räumen (Joanna 23:55:40 bis 23:57:30; P3R2-13) |
| 23:00 | Herr Schneiders Ausbruch um 23:00 ist sehr laut. Im Ost-Saal hört man durch die offene Tür, dass er brüllt; die Worte gehen im Ratespiel unter. Wer im Buffetsaal ist, versteht sie (Tim; P3R2-13) |
| Tumult | 23:58:00 bis 0:00:00 in Buffetsaal, Durchgang und Ost-Saal: laut nur bis 3 m, leise nur bis 1,5 m. Sehr laut bleibt überall hörbar |
| Sehen | braucht Licht am Ziel und freie Sicht. Wände sperren, Theke und Tische nicht. Volles Licht: man erkennt jeden im Raum. Kerzenlicht: Gesicht und Farben bis 3 m, weiter nur Umriss. Notlicht: nur Umriss. Die Maske sieht man im Dunkeln von weitem. Wer kauert, liegt oder eine Augenbinde trägt, sieht nichts |
| Fühlen | bis 1 m. Man spürt, dass jemand da ist oder vorbeidrängt. Wer es ist, weiß man nur, wenn die Person spricht |
| Riechen | Luftzug seit 23:30: Buffetsaal → Durchgang → Kaminsaal. Gerüche halten 90 s. Der verschmorte Steckplatz qualmt nur einen Augenblick; sein Geruch bleibt hinter der Theke und erreicht den Durchgang und den Kaminsaal nicht. Im Kaminsaal riecht man in der Tatnacht nur die ausgeblasenen Kerzen (P3R2-21) |
| Zeitgefühl | Im Dunkeln zählt nur die Reihenfolge, die eine Person selbst wahrgenommen hat |
| Tempo | im Dunkeln gehen höchstens 1 m/s, bei Licht 1,5 m/s, rennen 2,5 m/s (nie lautlos) |

Folgen, die man kennen muss:
- Im **Kaminsaal und im Turmgang** hört man das Scheppern nicht (zwei Räume vom Buffetsaal). Auch den Knall nicht. Man
  merkt nur, dass das Licht ausgeht.
- Im **Windfang** (Innentür zu) hört man aus dem Buffetsaal nur dumpfes Rumoren.
- Im **Ost-Saal** hört man alles sehr Laute aus dem Buffetsaal, Leises und Lautes nicht (alle sitzen mehr als 3 m von
  der Tür entfernt). Ausnahme: Joanna hört in der offenen Tür wie im Buffetsaal (P3R2-13).

### WELT 2.8 Abstände, auf die es ankommt (nachgerechnet)

| von | nach | m | Bedeutung |
|---|---|---|---|
| Marek (17,5/8,5) | Vorratsraumtür | 3,2 | knapp über der Grenze fürs Gesicht: Marek sieht dort nur Umrisse und die Maske |
| Marek | Eiskübel | 2,0 | Eisklirren nicht hörbar |
| Ahmet (18,5/8,5) | Eiskübel | 2,2 | dto. |
| Damir (am Ostende, kauernd) | Eiskübel | 1,9 | dto. |
| Lejla | Eiskübel | 3,2 | dto. |
| Eiskübel | Vorratsraumtür | 4,2 | Olli sieht von dort Schneider und Can im Kerzenlicht |
| vor der Theke beim Westende | Klappe | 1,4 | Can rennt an Olli vorbei |
| Kerzen | Vorratsraumtür / Klappe / vor der Theke West | 1,4 / 2,2 / 2,2 | Tür hell, Klappe und Ollis Warteplatz dunkel |
| Tür zum Ost-Saal | Ostende / Eiskübel / Ahmet / Marek / Tim / Lejla / Klappe / Emine | 1,0 / 2,2 / 1,4 / 2,2 / 3,2 / 5,0 / 8,0 / 8,9 | Joanna sieht um 23:57 den ganzen Buffetsaal und durch die zweite Tür bis zum Steinbogen (P3R2-09) |
| Ostende (Schneider 23:57) | Olli / Ahmet / Marek / Tim / Joanna / Lejla | 1,4 / 1,0 / 1,4 / 2,2 / 1,0 / 4,5 | wer „Zweitausend, bis zwölf“ (leise) hört |
| Tim am Kasten | Cans Weg auf 9/9 | 1,0 | Tim sieht das Gesicht, spürt den Luftzug |
| Tim am Kasten | Klappe / Eiskübel | 2,2 / 8,2 | die Wand neben der Tür sperrt die Klappe; die Stirnlampe erreicht den Eiskübel nicht (P3R2-10) |
| Handykorb | Kopf der Tafel / Tür | 2,8 / 5,8 | Joannas Licht zeigt um 23:59:30 den leeren Kopf der Tafel |
| Wege | | | |
| Tim: Kaffeemaschine → Klappe → Sicherungskasten | | 9,0 | im Dunkeln 9 s |
| Can: Vorratsraumtür → Klappe / Tim / Steinbogen / vor die Bogentür | | 4,2 / 6,2 / 8,2 / 13,3 | rennend 1,7 / 2,5 / 3,3 / 5,3 s |
| Olli: Eiskübel → vor der Theke West | | 5,0 | 5 s |
| Olli: vor der Theke West → Klappe → Vorratsraumtür | | 5,6 | 5,6 s |
| Olli: hinter der Tür → Klappe → Eiskübel | | 12,6 | 13 s (23:58:36 bis 23:58:49) |
| Olli: Eiskübel → rechter Buffettisch | | 3,2 | 4 bis 5 s, kriechend (23:58:50 bis 23:58:54) |
| Olli über das Ostende zur Tür (nicht genommen) | | 7,4 | dort kauern Ahmet und Damir, steht Marek, gehen Tim und Herr Schneider |
| Fatma: Klappe → hinter den linken Buffettisch | | 4,0 | 4 s |

---

## 4. Positionen

### WELT 4.1 Wahre Positionen

Zone (Teilfeld), Ort, Haltung. „dto.“ = wie in der Spalte davor.

| Person | 23:57:00 | Knall 23:58:00 | Scheppern 23:58:30 | Licht 0:00:00 |
|---|---|---|---|---|
| Herr Schneider | 4d am Ostende der Theke, steht | 4c hinter der Theke an der Kaffeemaschine, steht | 4c vor der Vorratsraumtür, fällt in 5 | 5 direkt hinter der Vorratsraumtür, liegt bewusstlos |
| Detektiv | 1 Ehrenplatz der blinden Kuh, Augenbinde, Kopfhörer | dto. | dto. | dto. |
| 1 Ahmet | 4d hinter der Theke ganz am Ostende, steht, Umschlag | 4d, kauert an Mareks Beinen | 4d, kauert | 4d, kauert |
| 2 Fatma | unterwegs von 2 nach 4a (ab 23:57:06 an der Klappe), Tasche | 4a an der Theken-Klappe, steht | 2 hinter dem linken Buffettisch, kauert neben Emine | dto. |
| 3 Olli | 4b am Eiskübel, steht | 4b am Eiskübel, steht | 4c vor der Vorratsraumtür, steht | 3 am rechten Buffettisch, kauert neben Lejla |
| 4 Can | 5 direkt hinter der Vorratsraumtür, Maske | 5, steht | 8b auf der Wendeltreppe (unterwegs zur Turm-Toilette) | 8b Turm-Toilette |
| 5 Lejla | 3 am rechten Buffettisch, steht | 3, kauert | 3, kauert, allein | 3, kauert, Olli neben ihr |
| 6 Emine | 2 hinter dem linken Buffettisch, steht | 2, kauert | 2, kauert, Fatma neben ihr | dto. |
| 7 Tim | 4c an der Kaffeemaschine, steht | 4c, bricht nach Westen auf | 6 am Sicherungskasten, steht | 6, schaltet ein |
| 8 Joanna | 1 in der Tür zum Ost-Saal, steht, tippt die Liste | 1 am Handykorb, steht | 1 am Handykorb, sucht ihr Handy | 1 am Handykorb, Handylampe an |
| 9 Marek | 4d hinter der Theke am Ostende, Saftkrüge, steht | 4d, steht | 4d, steht | 4d, steht |
| 10 Zeynep | 6 im Steinbogen, steht | dto. | dto. | dto. |
| 11 Sibel | 7 Wandbank Süd, sitzt | dto. | dto. | dto. |
| 12 Damir | 1 an der langen Tafel, Teekanne | 4d am Ostende, kauert | 4d, kauert | 4d, kauert |
| 13 Hana | 7 an der Kamin-Nische, steht | dto. | dto. | dto. |
| 14 Serkan | W am Außentor, steht, Lampe | dto. | dto. | dto. |
| 15 Azra | 1 lange Tafel, Ostseite, sitzt | dto. | dto. | dto. |
| 16 Wojtek | 1 Wandbank Ost bei der Box, sitzt | dto. | dto. | dto. |
| 17 Aylin | 1 lange Tafel, Westseite, sitzt, Mappe | dto. | dto. | dto. |
| 18 Tugba | 1 beim Ehrenplatz neben dem Detektiv, steht | dto. | dto. | dto. |

### WELT 4.2 Behauptete Positionen für die Marker zu Beginn von Runde 1

Jede Person setzt zwei Marker: „23:57“ und „Scheppern“ (ABG D-20). Rollen 5–18 sagen über ihren Ort die Wahrheit;
ihre Geheimnisse liegen woanders. Nur die vier Verdächtigen setzen in Stufe 1 einen falschen Marker.

| Person | Marker 23:57 (Stufe 1) | Marker Scheppern (Stufe 1) | Behauptung | wird umgestellt auf |
|---|---|---|---|---|
| 1 Ahmet | 4d | 4d | „Ich hab hinter der Theke nur Servietten gesucht.“ | bleibt (der Ort stimmt, der Grund nicht) |
| 2 Fatma | **2** | 2 | „Ich stand die ganze Zeit beim Gebäck am linken Buffet.“ | 23:57 → **4a** |
| 3 Olli | **1** | **1** | „Ich saß die ganze Zeit am Kopf der Tafel im Ost-Saal.“ | Stufe 2: 23:57 → 4b, Scheppern → 4b („am Eiskübel geduckt“); Stufe 3: Scheppern → **4c** |
| 4 Can | **8b** | 8b | „Ich war die ganze Zeit oben auf der Turm-Toilette.“ | 23:57 → **5**; Scheppern bleibt 8b (er war da schon auf der Wendeltreppe) |
| 5 Lejla | 3 | 3 | wahr | – |
| 6 Emine | 2 | 2 | wahr | – |
| 7 Tim | 4c | 6 | wahr | – |
| 8 Joanna | 1 | 1 | wahr | – |
| 9 Marek | 4d | 4d | wahr | – |
| 10 Zeynep | 6 | 6 | Ort wahr; Grund halb wahr („hab nach der blinden Kuh geschaut“) | – |
| 11 Sibel | 7 | 7 | wahr | – |
| 12 Damir | 1 | 4d | wahr | – |
| 13 Hana | 7 | 7 | wahr | – |
| 14 Serkan | W | W | wahr („wollte Decken holen“ ist die Ausrede, nicht der Ort) | – |
| 15 Azra | 1 | 1 | wahr | – |
| 16 Wojtek | 1 | 1 | wahr | – |
| 17 Aylin | 1 | 1 | wahr | – |
| 18 Tugba | 1 | 1 | wahr | – |
| Herr Schneider (Erzähler setzt) | 4d | 4c | seine Erinnerung und der Fundort | – |
| Detektiv | 1 | 1 | wahr | – |

---

## 5. Wahrnehmung

### WELT 5.1 Wer hört was in der Tatnacht

✓ = hört es, – = hört es nicht. Grund in Klammern nur, wo es nicht offensichtlich ist.

| Ereignis | Zeit | Buffetsaal (alle Wachen) | Durchgang (Tim, Zeynep) | Ost-Saal (inkl. Detektiv) | Kaminsaal, Turmgang | Windfang (Serkan) | Vorratsraum (Can bis 23:58:06) |
|---|---|---|---|---|---|---|---|
| „Zweitausend, bis zwölf.“ (leise) | 23:57:00 | nur Olli, Ahmet, Marek, Tim | – | nur Joanna (in der Tür, 1 m) | – | – | – |
| „Nicht die alte Leiste!“ (laut) | 23:57:40 | ✓ | nur Zeynep (genau 3 m von der Tür), harmlos | – (> 3 m von der Tür) | – | – | ✓ (direkt hinter der Tür) |
| Knall (sehr laut) | 23:58:00 | ✓ | ✓ | ✓ | – | dumpf | ✓ |
| „Ruhe! Ich hol die Notlaterne.“ (laut, Tumult) | 23:58:02 | nur bis 3 m: Ahmet, Marek, Damir, Olli (2,2 m), Tim (rund 2 m, schon im Gehen; P3R2-12) | – | – | – | – | ✓ |
| „Marek? Ich bin's, Ahmet.“ (leise) | 23:58:03 | Marek, Damir | – | – | – | – | – |
| „Emine? Ich bin's, Fatma.“ (leise) | 23:58:06 | Emine | – | – | – | – | – |
| „Buuuh!“ (laut, Tumult) | 23:58:07 | nur Schneider (Marek 3,2 m: knapp nicht) | – | – | – | – | – |
| „Hab ich dich!“ (sehr laut) | 23:58:08 | ✓ | ✓ | ✓ | – | dumpf | – |
| „Stehen bleiben!“ (sehr laut) | 23:58:18 | ✓ | ✓ | ✓ | – | dumpf | – |
| Cans rennende Schritte (laut) | 23:58:17–23:58:22 | nur bis 3 m vom Weg: Olli | Tim, Zeynep | – | Hana, Sibel | – | – |
| „Stehen bleiben, hab ich gesagt!“ (sehr laut) | 23:58:22 | ✓ | ✓ | ✓ | – (Can schon im Kaminsaal) | dumpf | – |
| „Lass uns reden, nur kurz.“ / „Zweitausend. Sonst Polizei.“ (leise) | 23:58:25–26 | nur Olli und Schneider | – | – | – | – | – |
| Scheppern (sehr laut) | 23:58:30 | ✓ | ✓ | ✓ | – | dumpf | – |
| Klimpern des Bunds (leise) | 23:58:35 | – | – | – | – | – | nur Olli |
| Eis klirrt (leise) | 23:58:49 | niemand (nächste: Damir 1,9 m, Marek 2,0 m) | – | – | – | – | – |
| „Lejla? Ich bin's, Olli.“ (leise) | 23:58:55 | Lejla | – | – | – | – | – |
| „Hier liegt Herr Schneider!“ (sehr laut) | 0:00:20 | ✓ | ✓ | ✓ | – | dumpf | – |

### WELT 5.2 Wer sieht das leuchtende Gesicht

| Wer | wo | was | Reihenfolge zum Scheppern bezeugbar |
|---|---|---|---|
| Herr Schneider | vor der Tür | Gesicht springt heraus, er packt die Kapuze | nein (Gedächtnislücke ab 23:58:09) |
| Marek | 4d, 3,2 m, Kerzenlicht | Gesicht springt heraus, ringt mit Herrn Schneider, reißt sich los, verschwindet hinter der Theke zur Klappe Richtung Durchgang | **ja**: erst weg, dann zweite Gestalt, dann Scheppern |
| Olli | vor der Theke West, 1,4 m | Gesicht rennt durch die Klappe an ihm vorbei | (Täter) |
| Tim | Durchgang, 1 m | Gesicht rennt an ihm vorbei in den Kaminsaal | **ja**: erst Gesicht, dann Schneiders Ruf, dann Scheppern |
| Zeynep | Steinbogen, streift sie | Can mit der Maske rennt an ihr vorbei in den Kaminsaal | **ja**: erst Can, dann Schneiders Ruf, dann Scheppern |
| Hana | Kamin-Nische, etwa 5 m | Gesicht huscht quer durch den Kaminsaal zur Bogentür | nein; sie weiß nur: erst das Gesicht, dann der Geruch. Stützt Cans Alibi, beweist es nicht (P3-03) |
| Sibel | Wandbank Süd, etwa 10 m | dto. | nein (hört kein Scheppern) |
| Ahmet, Damir, Emine, Fatma, Lejla | kauernd | nichts | nein |
| Joanna, Azra, Wojtek, Aylin, Tugba, Detektiv | Ost-Saal | nichts (keine Sicht durch die Tür zur Klappe) | nein |
| Serkan | Windfang | nichts | nein |

### WELT 5.3 Die tragenden Aussagen, geometrisch geprüft

**Ahmets Alibi über Marek (und Damir).** Ahmet ist ab 23:56:58 hinter der Theke am Ostende. Beim Knall kauert er sich an
Mareks Beine und flüstert: „Marek? Ich bin's, Ahmet.“ Marek steht und spürt ihn (unter 1 m) bis zum Licht. Damir kauert
0,7 m daneben, hört das Flüstern im Tumult (unter 1,5 m) und spürt Ahmets Schulter. Beim Scheppern ist Ahmet noch da.
Kernsatz Marek: „Beim Knall hat Ahmet sich an meine Beine gekauert und geflüstert: ‚Marek? Ich bin's, Ahmet.‘ Er war
noch da, als es schepperte, und auch, als das Licht anging.“

**Fatmas Alibi über Emine.** Fatma steht beim Knall an der Klappe. Sie geht 4 m zurück und kauert ab 23:58:05 neben Emine.
Um 23:58:06 flüstert sie. Beim Scheppern ist sie seit 25 s da. Kernsatz Emine: „Gleich nach dem Knall hat Fatma sich neben mich
gekauert und geflüstert: ‚Emine? Ich bin's, Fatma.‘ Beim Scheppern war sie neben mir.“ (Emine kauerte, sie lag nicht.)

**Cans Alibi über Marek, Tim und Zeynep.**
- Marek (4d, stehend, Kerzenlicht 3,2 m): „Das leuchtende Gesicht ist aus der Vorratsraumtür gesprungen. Herr Schneider
  hat es gepackt. Es hat sich losgerissen und ist hinter der Theke zur Klappe verschwunden, Richtung Durchgang. Erst
  danach hat es gescheppert.“
- Tim (Durchgang, 1 m): „Am Sicherungskasten ist ein leuchtendes Gesicht an mir vorbei in den Kaminsaal gerannt.
  Danach hat Herr Schneider noch gebrüllt. Erst dann hat es an der Theke gescheppert.“
- Zeynep (Steinbogen): „Kurz nach dem Knall ist Can mit dem leuchtenden Gesicht durch den Durchgang an mir vorbei in den
  Kaminsaal gerannt. Er hat mich im Bogen gestreift. Als er schon vorbei war, hat Herr Schneider an der Theke noch
  hinterhergebrüllt. Erst danach kam das Scheppern.“
- Warum möglich: Durchgang und Bogen grenzen an den Buffetsaal, also hören Tim und Zeynep das sehr laute Scheppern
  (W-03, W-04). Can ist mindestens 9 s vor dem Scheppern an beiden vorbei.
- Zeynep hört **nicht**, dass „noch jemand mit Herrn Schneider stritt“ (A:54): Das Gespräch an der Tür ist leise und
  8 m entfernt, ohne Sicht. Sie hört nur Schneiders zweiten, sehr lauten Ruf. Nie „Zweitausend“ hörbar machen.

**Mareks zweite Gestalt (Variante 4b, W-06).** Nach Cans Flucht kommt im Kerzenlicht jemand von der Klappe her zu Herrn
Schneider. Marek sieht nur einen dunklen Umriss (3,2 m, über der Grenze fürs Gesicht). Herr Schneider packt den Umriss
am Ärmel. Gleich danach scheppert es und die Kerzen sind aus. Marek erkennt nichts: keine Größe, keine Kleidung, keine
Stimme (leise, 3,2 m im Tumult). Kernsatz: „Kurz bevor es schepperte, kam noch jemand von der Klappe her zu Herrn
Schneider. Nur ein Umriss. Wer, kann ich nicht sagen.“

**Ollis späte Ankunft über Lejla.** Lejla kauert ab dem Knall allein am rechten Buffettisch. Beim Scheppern ist niemand
neben ihr; sie spürt niemanden und hört kein Flüstern. 25 s nach dem Scheppern kriecht jemand zu ihr und flüstert:
„Lejla? Ich bin's, Olli.“ Im Dunkeln weiß sie keine Sekunden, aber sicher die Reihenfolge. Kernsatz: „Beim Scheppern war
ich allein. Erst danach ist Olli zu mir gekrochen und hat geflüstert: ‚Lejla? Ich bin's, Olli.‘“
Achtung (ABG §3.18): Lejlas Aussage passt auch zu Ollis Stufe 2 („erst am Eiskübel geduckt, dann zu Lejla
gekrochen“). Sie **löst** Stufe 2 aus, **widerlegt** sie aber nicht. Widerlegt wird Stufe 2 durch Cans Alibi und
Mareks zweite Gestalt, den Bund im Eiskübel und XD3 mit FN3.

**Tims Blick am Sicherungskasten.** Tim steht mit dem Gesicht zur Wand und tastet nach dem Schalter. Die rennenden
Schritte (laut, 1 m) lassen ihn herumfahren. Er sieht das leuchtende Gesicht von Ost nach West vorbei und durch den
Bogen verschwinden. Die Klappe sieht er nicht (Wand neben der Tür), den Eiskübel nicht, die Vorratsraumtür nicht. Ab
23:59:40 zeigt seine Stirnlampe Zeynep im Bogen.

### WELT 5.4 Joannas Liste (W-08, W-21)

Joanna steht 23:55:40 bis 23:57:30 in der offenen Tür zum Ost-Saal. Von dort sieht sie bei vollem Licht den ganzen
Buffetsaal (2.8). Durch die Tür neben der Klappe sieht sie einen Streifen des
Durchgangs bis zum Steinbogen, den Sicherungskasten nicht. Zeynep steht im Bogen; dort hat Joanna sie schon um 23:55:15
gesehen (P3R2-09). Sie tippt um 23:57:00 in
die Notizen ihres Handys. Zeitstempel 23:57. **Wortlaut der Notiz:**

> Gruppenfoto 0:00 – wer fehlt noch?
> Ahmet: hinter der Theke, Ostende
> Fatma: geht zur Klappe
> Olli: am Eiskübel, redet mit Herrn Schneider
> Herr Schneider: am Ostende
> Marek: Saft, hinter der Theke
> Tim: Kaffeemaschine
> Lejla: rechtes Buffet
> Emine: linkes Buffet
> Zeynep: im Bogen zum Kaminsaal, kommt gleich
> Can: nirgends!
> Kaminsaal: noch ein paar, kommen gleich

Joanna hat außerdem gehört, wie Herr Schneider zu Olli „Zweitausend, bis zwölf“ sagte. Was das heißt, weiß sie nicht.
Um 23:59:30 leuchtet sie mit der Handylampe die Tafel ab: Der Kopf der Tafel ist leer. Das Foto von 23:51 ist auf
demselben Handy.

### WELT 5.5 Wer sah Olli um 23:57 am Eiskübel (ABG D-35)

Bei vollem Licht konnten viele Olli sehen. Damit Ollis Stufe 1 nicht in Minute eins fällt, legt die Welt fest, wer es
weiß und wer nicht hinsah.

| Person | sah Olli am Eiskübel? | Warum | trägt es aktiv |
|---|---|---|---|
| Joanna | ja, 2,2 m, und hörte „Zweitausend, bis zwölf“ | steht in der Tür, notiert | **ja** (Liste, A:95) |
| Ahmet | ja, 2,2 m, und hörte den Satz | wartete auf Herrn Schneider | **ja** (Stufe 2, A:95) |
| Fatma | ja, 6 m | stand an der Klappe und wartete auf Herrn Schneider | **ja** (Stufe 2, A:95) |
| Lejla | im Blickfeld, 3,2 m | schaute nur auf Ahmet und den Umschlag | nein; sie weiß nur „da stand wer am Eiskübel“ |
| Marek | nein | Rücken zur Theke, füllte Saftkrüge; hörte den Satz, sah nicht, zu wem | nein |
| Tim | nein | Rücken zur Theke an der Kaffeemaschine; hörte den Satz; weiß seit 23:52, dass Olli Eis holen und mit Herrn Schneider reden wollte | über den Satz von 23:52 (Stufe 2) |
| Emine | im Blickfeld, 6,7 m | schaute nur auf Fatma | nein |
| Damir | ging 23:57:30 vorbei | trug die heiße Teekanne, schaute auf die Kanne | nein |
| Ost-Saal (Azra, Wojtek, Aylin, Tugba) | nein | schauten nach Süden auf die blinde Kuh; der Kopf der Tafel liegt im Norden, 3 bis 4 m hinter oder neben ihnen (P3R2-01) | nein |
| Detektiv | nein | Augenbinde ab 23:55; sah Olli um 23:54 am Kopf der Tafel sitzen | nein |
| Herr Schneider | ja | sagt nichts über Geldsachen (W-18) | nein |

### WELT 5.6 Wer hörte welche Drohung von Herrn Schneider

| Zeit | an wen | Wortlaut | Lautstärke | wer hört es |
|---|---|---|---|---|
| 18:30 | Marek | „Steht der um Mitternacht noch da, lass ich ihn abschleppen.“ | laut | Marek, Olli, Tim (im Hof) |
| 18:50 | Olli | „Keiner geht, bevor das bezahlt ist.“ (2.000 € bis Mitternacht) | laut | Olli, Tim |
| 22:00 | Wojtek | „Ab jetzt leise. Sonst kassier ich die Box ein.“ | laut | Ost-Saal |
| 23:00 | Olli | „Bis Mitternacht. Sonst ruf ich die Polizei!“ | sehr laut (Worte nur im Buffetsaal verständlich, P3R2-13) | Tim (Inhalt); Ost-Saal nur „Herr Schneider wird laut“ |
| 23:51 | Ahmet | „Um zwölf sag ich allen, was der Keller gekostet hat.“ | leise | Ahmet |
| 23:56 | Fatma | „Die Schatulle. Um Punkt zwölf geh ich raus und ruf die Polizei.“ | leise | Fatma, Emine |
| 23:57:00 | Olli | „Zweitausend, bis zwölf.“ | leise | Olli, Ahmet, Marek, Tim, Joanna |
| 23:57:40 | Tim | „Nicht die alte Leiste!“ | laut | ganzer Buffetsaal, Can |
| 23:58:26 | Olli | „Zweitausend. Sonst Polizei.“ | leise | Olli |

### WELT 5.7 Was niemand wahrnehmen kann (Ausschlüsse)

- Niemand sieht, wer den Kerzenständer hielt. Marek sieht nur einen Umriss.
- Außer Olli hört niemand das Klimpern des Bunds oder das Eisklirren.
- Zwischen 23:58:10 und 0:00:00 nimmt niemand Olli wahr, außer Marek (nur Umriss im Kerzenlicht), Herrn Schneider (ohne
  Erinnerung) und Lejla (sie spürt ihn und hört sein Flüstern erst nach dem Scheppern).
- Niemand im Kaminsaal, im Turmgang oder im Windfang hört das Scheppern.
- Niemand sieht Can zwischen 23:58:23 und 0:01:00.
- Herr Schneider weiß nichts nach „Hab ich dich!“.
- Can nimmt Olli nicht wahr.
- Fatmas Weg durch den Kaminsaal um 23:40 sieht niemand; Emine sieht sie erst an der Vitrine (P3R2-20).

### WELT 5.8 Abgeleitete Wahrnehmungen aus den Rollen (RK §10 Nr. 2, Integration Runde 1)

Die Rollenteile leiten weitere Beobachtungen aus Raum, Licht und Abstand ab. Sie stehen hier, damit Protokoll 3 sie findet.
Keine entscheidet den Fall; jede erzeugt Druck oder lenkt zu einer Indizkarte.

| Wer | Zeit | Was | Warum möglich | Quelle |
|---|---|---|---|---|
| Olli | 23:55 | sieht Ahmet im Ost-Saal die Jacke aufhängen, den dicken Umschlag in der Hand | rund 3 m, volles Licht | RK-04 |
| Can | 23:50 | sieht im Kaminsaal Olli und Tim an der Bogentür; hört „Au! Mein Finger!“ | gleicher Raum, Licht, laut | RK-05 |
| Ahmet | 23:55 | sieht Olli am Kopf der Tafel sitzen | Ost-Saal, Licht | RK-06 |
| Ahmet | 23:58 bis 0:00 | durch das offene Ostende kommt niemand an ihm vorbei | Fühlen bis 1 m; Damir kauert daneben | RK-08 |
| Olli | 23:58:19 | erkennt nicht, wer unter der Maske steckt | Klappe dunkel, die Maske beleuchtet nichts | RK-12 |
| Tim | 23:50 bis 23:55 | durch die Bogentür geht nur Herr Schneider; 23:55 sieht er ihn zu Fatma ans linke Buffet gehen | steht an der Bogentür, Licht | Z-08 |
| Tim | 23:57 | Ahmet schlüpft zwei Meter neben ihm hinter die Theke; gleich danach kommt Herr Schneider an Ahmet vorbei zu ihm | 2 m, volles Licht | P3-23 |
| Zeynep | 23:50 | sieht Olli und Tim an der Bogentür | gleicher Raum, Licht | Z-08 |
| Zeynep | 0:00 | sieht Tim am Sicherungskasten, direkt an Cans Weg | 2 m, Stirnlampe, dann Licht | P3-11 |
| Joanna | 23:56 | sieht Herrn Schneider bei Fatma am linken Buffet | Tür zum Ost-Saal, Licht | Z-08 |
| Joanna | 23:55 | Can ist weder im Buffetsaal noch im Durchgang | ruft an der Tür zum Durchgang, Licht | P2-06 |
| Lejla | 0:00:05 | Olli geht als Erstes zum Eiskübel, vor Mareks Ruf | Licht, 3,2 m | Z-08, P2-06 |
| Marek | 23:57:40 | Tim steht einen Meter neben ihm an der Kaffeemaschine, als Herr Schneider „Nicht die alte Leiste!“ ruft | 1 m, Licht, laut | P2-06 |
| Damir | 23:54 | sieht Olli sich an den Kopf der Tafel setzen; wann er aufstand, nicht | schenkt gerade ein | P3-20 |
| Damir | 0:00 | Ahmet steht mit dem Umschlag in der Hand neben ihm auf | Licht, unter 1 m | ZR-05 |
| Sibel, Hana | 0:00, 0:01 | Zeynep steht im Steinbogen; Can kommt aus dem Turmgang | Kaminsaal, Licht | ZR-05 |
| Aylin | 22:30 | sieht im Quittungsblock den Durchschlag zur Bogentür | an der Tafel West, Licht | ZR-05 |
| Aylin | 23:55 | Serkan geht aus dem Ost-Saal, als alle zur blinden Kuh sollen | Ost-Saal, Licht | P14-09 |
| Azra | 0:12 | Ahmet nimmt ein Bündel Scheine aus dem Umschlag | 4 m, Licht | ZR-05 |
| Ost-Saal-Rollen | 23:58:30 bis 0:00 | schauen zur Tür in den Buffetsaal, woher der Lärm kam; den leeren Kopf der Tafel bemerkt nur Joanna | Joanna leuchtet die Tafel fürs Gruppenfoto ab | ZR-09, P3-20 |

---

## 6. Spuren und Beweise

### WELT 6 Spuren und Beweise

Lage = Zustand bei der Ermittlung (ab 0:20). Codes nur, wo E3 sie festlegt; die übrigen Codes vergibt die Karten-Phase.

| Spur | Ort (Zone) | Zustand | entstanden | beweist | Code |
|---|---|---|---|---|---|
| **Messingkerzenständer** | umgestoßen auf dem Steinboden vor der Vorratsraumtür (4c) | Schaft leicht verbogen. Die drei roten Kerzen liegen daneben. **Am Fuß kleben im erstarrten roten Wachs feine Holzsplitter und weißer Kalk.** Am Griff rote Wachstropfen vom Kerzenteller (harmlos) | Wachs lief seit 22:00 auf den Fuß; Splitter und Kalk 23:58:29 von Ollis Ärmel | Wer den Kerzenständer am Fuß hielt, hatte Holzsplitter und weißen Kalk am Ärmel. Allein nennt er keinen Namen. Mit FN3: Olli | XD3 |
| Rote Wachsspritzer | Steinboden vor der Vorratsraumtür (4c) | rund um den Kerzenständer | 23:58:30 | Ort des Geschehens. Auf dem Lageplan nie rot zeichnen | – |
| **Ollis rechter Arbeitshandschuh** | hängt aus der Tasche von Ollis Daunenweste (bei Olli) | Fingerkuppen: braunes Möbelwachs und weißer Kalk. Handrücken: frische rote Kerzenwachstropfen | Kuppen 18:45, Tropfen 23:58:29 | Kuppen: Olli hat die Schramme mit Möbelwachs verdeckt. Tropfen: Olli war am brennenden Kerzenständer. Mit XD3: Schlüsselbeweis gegen Olli | FN3 |
| Ollis linker Arbeitshandschuh | in der Kamin-Nische (7) | schwarz vom Ruß; seit 23:20 zur Seite geschoben | 19:30 abgelegt, Ruß von alt und vom Kaminqualm 23:30 | Olli hatte heute Nacht nur den rechten Handschuh bei sich | – |
| Ollis Pulli-Ärmel | an Olli | an beiden Bündchen noch Kalkstaub und ein paar feine Holzsplitter; auf dem grauen Pulli fällt es kaum auf | 18:35 | passt zum Wachs am Fuß und zur Bogentür. Nur bei genauer Untersuchung von Olli sichtbar, zusammen mit FN3 | – |
| **Möbelwachs** | Dose in Wojteks Werkzeugkasten, hinter der Theke neben der Kaffeemaschine (4c) | halb leer, am Rand Holzstaub | 18:45 benutzt | Mit dem Wachs wurde Holz behandelt. Auf Karten nur „braunes Möbelwachs“ | – |
| **Bogentür-Beschlag** | Bogentür, Grenze 7/8 | ein Beschlag aus der gekalkten Wand gerissen, frische Holzsplitter, weißer Kalk am Türbogen, darüber ein Rest braunes Möbelwachs | 18:35, Wachs 18:45 | Ollis Heimlichtuerei; Kalk und Splitter wie am Kerzenständerfuß | – |
| **Schlüsselbund** | unter den Eiswürfeln im Eiskübel vor dem Ostende der Theke (4b) | großer Bund, Schlüssel aus dunklem Eisen an einem Stahlring; Außentor, Hoftür, Turm; Eis halb geschmolzen | 23:58:49 | Fundort. Liegt genau an dem Platz, den Olli in Stufe 2 zugibt | PP9 |
| Eiskübel | vor dem Ostende (4b) | Metallkübel, Eiswürfel, Schmelzwasser; obenauf fehlt eine Handvoll Eis | – | – | (PP9) |
| **Umschlag** | im Ascheneimer neben der Kamin-Nische (7) | leer, gefaltet, langer Knick; Aufschrift „Miete Schlosskeller“ in Ahmets Handschrift; grau von kalter Asche | 0:12 | Ahmets Mietschwindel (mit Quittungszettel oder Belegungsblatt) | – |
| Mietgeld | Ahmets Hosentasche | 2.550 € in Scheinen | 0:12 umgesteckt | dto. | – |
| Ahmets Jacke | am Jackenständer (1) | Brusttasche: Namensliste der 17 anderen aus der Clique, hinter jedem „150 € ✓“. Innentasche: ein Kaugummipapier | 18:00, 23:55 | Ahmet hat bei allen kassiert. Kein Bund in der Jacke | – |
| **Münzschatulle** | in Fatmas Umhängetasche aus Leder | zwischen Skizzenblock und Stiften. Deckel blank poliert, Wappen mit zwei Löwen | 23:40 | Fatmas Heimlichtuerei | – |
| Glassplitter | am rechten Ärmel von Fatmas beerenrotem Mantel | feine Splitter wie von der Vitrinenscheibe | 23:40 | Fatma war an der Vitrine. Nie am Kopftuch | – |
| Fatmas Silberring | an ihrer rechten Hand | feine Kratzer in einer Kerbe, von der Glasscheibe | 23:40 | nichts Neues (harmlos) | – |
| Schauvitrine | Turmgang (8a) | gesprungene Scheibe angehoben, Scherben am Boden, Samtbett leer | Sprung 21:00, Scherben 23:40 | die Schatulle fehlt | – |
| Splitter unter dem Sockel der Rüstung | Turmgang (8a) | ein paar kleine Glassplitter | 21:00 | Der Sprung war schon vor Fatma da (Tandem 1) | – |
| Rüstungshelm | Turmgang (8a) | Staub und eine alte Spinnwebe | – | kein Bund darin | – |
| Brottasche | linker Buffettisch (2) | Brot und Krümel | – | kein Bund darin | – |
| **Leuchtmaske** | in der Bauchtasche von Cans signalgelbem Kapuzenpulli | zusammengefaltet, grünlich-weiße Leuchtfarbe, noch leicht klebrig | am Nachmittag bemalt, 23:58:23 eingesteckt | Cans Heimlichtuerei | JT3 |
| Gelbe Fasern | an Herrn Schneiders rechter Hand | knallgelbe Fasern wie von einer Kapuze | 23:58:08 | Herr Schneider hat Can gepackt. **Falsche Fährte** gegen Can, widerlegt durch Cans Alibi | – |
| **Mehrfachsteckdose** | auf dem Boden hinter der Theke an der Kaffeemaschine (4c) | ein Steckplatz schwarz verschmort; die Kaffeemaschine steckt noch drin | 23:58:00 | Der Knall kam von Tims Steckdose | – |
| Hauptsicherung | Sicherungskasten im Durchgang (6) | wieder eingeschaltet; Fach darunter mit Ersatzsicherungen und Putzmitteln | 0:00:00 | Tim war am Kasten | – |
| Tims Stirnlampe | um Tims Hals | an | 23:59:40 gefunden | Tim war im Dunkeln am Kasten | – |
| Notlaterne | am Haken direkt hinter der Vorratsraumtür (5) | unberührt, aus | – | Herr Schneider hat sie nicht mehr erreicht | – |
| Mitternachtstorte | Regal im Vorratsraum (5) | unversehrt | – | – | – |
| **Quittungszettel** | in Aylins schwarzer Ledermappe | „Miete: 0 Euro. Schneider“ | 22:30 | Die Miete war erfunden | – |
| **Herrn Schneiders Klemmbrett** | bei Herrn Schneider | Belegungsblatt der Stiftung: „Saalmiete Schlosskeller: 0 Euro“. Quittungsblock, Durchschläge: „Bogentür, Beschlag ausgerissen: 2.000 € Bargeld. Bis Mitternacht.“ (18:50, ohne Namen) und „Miete: 0 Euro.“ (22:30) | Nachmittag, 18:50, 22:30 | Mietschwindel; Motiv für den Bogentür-Schaden | – |
| **Joannas Foto** | auf Joannas Handy | Zeitstempel 23:51: Herr Schneider und Ahmet streiten vor der Theke, Ahmet hält einen dicken Umschlag | 23:51 | Ahmets Motiv | – |
| **Joannas Notiz** | auf Joannas Handy | Zeitstempel 23:57, Wortlaut 5.4 | 23:57 | widerlegt Ollis und Fatmas Stufe 1 für 23:57; Can fehlte | – |
| **Fatmas Tasche** | an Fatma | schwere Umhängetasche aus Leder, auffällig ausgebeult (Schatulle) | 23:40 | wie Schatulle | – |
| Hanas Brief | unter der Asche in der Kamin-Nische (7) | halb verkohlt; lesbar nur „Ich trau mich nicht, es dir zu sagen“; kein Name | 23:20 | nichts zum Hauptfall (Tandem 2) | – |
| Wojteks Kopfhörer und Box | Ost-Saal (1) | Box mit Akku, lief durch | 23:55 | warum der Detektiv nur sehr Lautes hörte | – |
| Handykorb | lange Tafel im Ost-Saal (1) | leer, die Handys sind seit 0:05 zurück; daneben Joannas umgestoßener Handyhalter | 23:55, 23:58, 0:05 | – | – |
| Serkans Wunderkerzen | in Serkans Auto auf dem Parkplatz vor dem Außentor | unerreichbar, nie angezündet | Nachmittag | nichts zum Hauptfall (Tandem 2) | – |
| Tugbas Notizbuch | bei Tugba | Ablaufplan, Punkteliste der Spiele, die Dankeskarte für Herrn Schneider mit allen Unterschriften | 18:00 | nichts zum Hauptfall (Tandem 4) | – |
| Aylins Gästeliste | in Aylins Mappe | alle 18 aus der Clique und der Detektiv abgehakt | 18:00 | – | – |

---

## 7. Mechanik

### MECH 0.2 Begriffe der Spielsprache (E5)

| Begriff | Bedeutung |
|---|---|
| Person | Wer am Tisch sitzt. **Personen = Rollen + Detektiv + Erzähler** (E6). 6–20 Personen, 4–18 Rollen |
| Rolle | Platz 1–18 nach WELT §1.2. Rollen 1–10 sind Hauptrollen, 11–18 Zusatzrollen in Tandems |
| die vier Verdächtigen | Ahmet, Fatma, Olli, Can. Immer besetzt. Die vier Spalten des Ermittlungsbogens |
| Zeugen | Rollen 5–10: Lejla, Emine, Tim, Joanna, Marek, Zeynep |
| Untersuchung | Der Detektiv wählt eine Indizkarte. Drei je Runde, am Ende der Runde (A:105); in Runde 3 erst nach der Tipp-Runde (1.3) |
| Indizkarte | Karte AD3 bis YT4 (19 Stück). Entweder **Spurkarte** (Ort, Gegenstand, Spur) oder **Ortstermin** |
| Ortstermin | Indizkarte für einen Platz, an dem beim Scheppern ein Zeuge war. Wer dort war, antwortet vor allen auf die Frage der Karte. Fehlt die Person heute, dreht der Erzähler ihren Zeugenstreifen um |
| Geheimniskarte | Je Rolle eine. Liegt verdeckt vor der Person. Innen: was die Person zugibt, Vermerk für den Bogen, Domino-Hinweis. Z-Falz: Der Text liegt innen (4.1) |
| Umdrehen | Bei Geheimnis- und Indizkarten: die Karte wenden und das leere Deckfeld aufklappen; danach liegt der Text offen. Bei Zeugenstreifen: den Streifen wenden (4.1, 5.2) |
| Aktionskarte | Je Rolle eine. Liegt offen vor der Person. Einmal im Spiel |
| Zeugenstreifen | Teil des Abwesenheitsblatts. Je fehlendem Zeugen 5–10 einer. Liegt verdeckt neben dem Lageplan |
| Vermerk | Fester Satz für den Ermittlungsbogen auf einer Karte oder einem Streifen |
| Meilenstein | M1 bis M9, je ein Detektiv-Punkt (A:108-112) |
| Auslöser | Bedingung im Rollenheft, im Spieltext immer als Satz mit „Sobald“ formuliert (E5) |
| Pflicht-Auslöser | Auslöser, bei dem die Geheimniskarte umgedreht werden **muss** (Abschnitt 4.2) |
| Rundensperre | „frühestens in Runde N“. Vorher bleibt eine Karte zu, auch wenn ein Auslöser erfüllt ist |
| Stufe 1, 2, 3 | Tarn-Aussage, Geständnis des Teil-Geheimnisses (= Geheimniskarte umdrehen), bei den Verdächtigen: Satz bei der eigenen Anklage |
| Marker | Zwei je Person: „23:57“ und „Scheppern“ (WELT §4.2) |
| Reinen Tisch machen | Die eigene Geheimniskarte freiwillig am Rundenende umdrehen (A:101) |
| Verhörstuhl | Ein Stuhl am Kopf des Tisches. Wer dort sitzt, beantwortet Fragen des Detektivs (R-02) |
| Gegenüberstellung | Ab 14 Personen in Runde 2 und 3: fünf Minuten, ab 18 Personen sieben, in denen die vier Verdächtigen nebeneinander am Kopf des Tisches sitzen. Wer in der Runde ein Ziel unter den vier hat, stellt genau eine Frage (1.3) |
| Marker-Probe | Abschnitt e jeder Runde: Wer einen Marker hat, dem eine offene Karte ausdrücklich widerspricht, stellt ihn um (1.3, R-06) |
| Vor allen | Der ganze Tisch hört zu: bei der Gegenüberstellung, beim Ortstermin, bei einem Impuls, beim Vorlesen einer Karte, nach „Alle mal herhören!“ und am Verhörstuhl, solange alle anderen schweigen (R-13) |
| Domino-Hinweis | Letzter Satz jeder Geheimniskarte. Er bringt eine andere Rolle unter Druck (A:92) |
| Dazu sag ich jetzt nichts | Erlaubte Antwort, wenn jemand etwas bestätigen soll, das sein Heft noch zurückhält (R-14) |

Im Spieltext nie: „Trigger“, „Evidence Board“, „Board“, „Pen & Paper“, „Gamemaster“, „Ping-Pong“, „Smalltalk“,
„Auto-Solve“ (REG §9 Nr. 9). In dieser Spezifikation stehen sie nur, wo der Auftrag zitiert wird.

### MECH 0.3 Die Mechanik in zwölf Sätzen

1. Vier Verdächtige, einer war es: Olli. Der Erzähler weiß es nicht (A:26, E10).
2. Nach Vorgeschichte, Vorstellungsrunde und Tat-Moment setzt jede Person zwei Marker auf den Lageplan.
3. Es gibt drei Runden zu je dreißig Minuten.
4. In jeder Runde reden alle frei. Jede Rolle hat zwei Nachbohr-Ziele. Der Detektiv befragt am Verhörstuhl.
5. Wer im Gespräch mit seinem Auslöser konfrontiert wird, dreht seine Geheimniskarte um (Stufe 2).
6. Am Rundenende darf jede Person freiwillig reinen Tisch machen.
7. Dann macht der Detektiv drei Untersuchungen. Die Indizkarten sind an Runden gebunden (ab Runde 1, 2 oder 3). In Runde 3
   kommt vorher die Tipp-Runde.
8. Was offen liegt, trägt der Detektiv als Vermerk in den Ermittlungsbogen ein.
9. Wird eine Ortsangabe widerlegt, wird der Marker vor allen umgestellt.
10. Fehlen Zeugen 5–10, liegen ihre Aussagen als verdeckte Zeugenstreifen neben dem Lageplan. Nur Ortstermine oder die
    Aktionskarte „Zeitstempel“ decken sie auf.
11. In Runde 3 geben alle außer dem Detektiv vor den letzten drei Untersuchungen einen geheimen Tipp ab. Danach untersucht
    der Detektiv ein letztes Mal und klagt an.
12. Das Auflösungsheft wertet die Anklage, die neun Meilensteine des Detektivs und die Tipps aller.

### MECH 1.1 Zeitplan mit Minuten (Ziel 2,5 bis 3 Stunden)

Minuten am Tisch, ohne das Drucken und Schneiden vorher (Abschnitt 10.5). Eine Runde dauert bei jeder Personenzahl
dreißig Minuten (M-02). In großen Runden laufen die Gespräche parallel.

| Nr | Schritt | P = 6 | P = 12 | P = 20 | Uhr im Spiel |
|---|---|---|---|---|---|
| 0 | Aufbau am Tisch: Lageplan, Marker, Karten, Hefte verteilen | 10 | 12 | 12 | – |
| 1 | Begrüßung und „So läuft der Abend“ (Vorlesen, 9.2) | 4 | 4 | 4 | – |
| 2 | Vorgeschichte (Vorlesen, höchstens eine Druckseite, 9.3) | 3 | 3 | 3 | – |
| 3 | Vorstellungsrunde (je Rolle etwa 50 s, dazu Detektiv und Lacher, 9.4) | 6 | 11 | 17 | – |
| 4 | Tat-Moment und Auftrag (Vorlesen, 9.5) | 3 | 3 | 3 | 23:55 bis 0:20 |
| 5 | Die vier Verdächtigen öffnen still ihre Fassung (9.6) | 3 | 3 | 3 | 0:20 |
| 6 | Lageplan-Führung, Marker setzen, Zeugenstreifen auslegen (9.7) | 5 | 7 | 8 | – |
| 7 | Runde 1 „Das Alibi-Geflecht“ (1.3) | 30 | 30 | 30 | ab 0:30 |
| 8 | Runde 2 „Die Indizien-Filterung“ | 30 | 30 | 30 | ab 1:15 |
| 9 | Pause | 10 | 10 | 10 | – |
| 10 | Runde 3 „Die finale Gegenüberstellung“ | 30 | 30 | 30 | ab 2:00 |
| 11 | Tipp-Runde (7.1), in Runde 3 zwischen Abschnitt c und d | 4 | 5 | 6 | 2:45 |
| 12 | Anklage und Stufe 3 (8.1) | 5 | 5 | 5 | 2:45 |
| 13 | Auflösung (8.4) | 12 | 14 | 15 | – |
| | **Summe** | **155 min (2 Std. 35 Min.)** | **167 min (2 Std. 47 Min.)** | **176 min (2 Std. 56 Min.)** | |

Die Pause liegt zwischen Runde 2 und Runde 3, damit vor der Gegenüberstellung alle frisch sind (M-03).

### MECH 1.2 Wer tut was in jedem Schritt

| Schritt | Erzähler | Detektiv | Rollen |
|---|---|---|---|
| 0 Aufbau | legt Lageplan (zwei Blätter), Markerfelder, Indizkarten-Stapel (nach Code, ungelesen), Tipp-Zettel, Teil 90 versiegelt zu sich; gibt jeder Rolle Heft, Geheimniskarte (verdeckt), Aktionskarte (offen), zwei Marker; die vier versiegelten Fassungen behält er bis Schritt 5 | bekommt Teil 01 und zwei Marker; bei 6–11 Personen die Aktionskarten der fehlenden Zeugen (4.6) | legen Geheimniskarte verdeckt, Aktionskarte offen vor sich; lesen noch nichts Neues |
| 1 Begrüßung | liest 9.2 vor, stellt die Uhr | hört zu | hören zu |
| 2 Vorgeschichte | liest 9.3 vor | hört zu | hören zu |
| 3 Vorstellungsrunde | liest je Rolle die Frage aus 9.4 vor; zuletzt die Frage an den Detektiv; dann die Lacher fehlender Zusatzrollen | antwortet mit „Dein Auftritt“ aus Teil 01 | antworten mit „Dein Auftritt“ aus dem Heft, Ich-Form |
| 4 Tat-Moment | liest 9.5 vor (Fassung m oder w für den Detektiv) | hört zu | hören zu |
| 5 Fassungen | sagt den vier Verdächtigen, dass sie ihre Fassung jetzt still öffnen | liest „Was du selbst weißt“ in Teil 01 | die vier Verdächtigen lesen still; alle anderen lesen „Was alle wissen“ im Heft |
| 6 Lageplan | führt nach 9.7; setzt Herrn Schneiders Marker; legt die Zeugenstreifen fehlender Zeugen neben die Markerfelder und deren Geheimniskarten verdeckt darunter; legt die Tabelle „Karten unter den Streifen“ (9.14) zu sich | setzt seine Marker (Ost-Saal) | setzen ihre zwei Marker nach „Deine Marker“ im Heft (Stufe 1) |
| 7, 8, 10 Runden | liest den Rundenstart (9.8); stellt die Uhr; moderiert mit Impulsen (9.9); fragt nach jeder Indizkarte die Standardfrage (1.4 R-08); führt die Marker-Probe | befragt am Verhörstuhl, geht von Gespräch zu Gespräch, wählt am Ende drei Indizkarten, liest sie laut vor, trägt Vermerke ein | führen die zwei Nachbohr-Gespräche ihres Hefts; drehen bei Pflicht-Auslöser ihre Geheimniskarte um; stellen Marker um; spielen ihre Aktionskarte |
| 9 Pause | – | darf den Bogen ordnen | – |
| 11 Tipp-Runde (Runde 3, nach Abschnitt c) | liest 9.12 vor, verteilt Tipp-Zettel, füllt selbst einen aus, sammelt alle gefaltet ein; danach führt er Abschnitt d und e der Runde 3 | wartet; danach macht er die drei Untersuchungen der Runde 3 (1.3 d) und trägt Vermerke ein (e) | füllen den Tipp-Zettel aus |
| 12 Anklage | liest den Anklagetext (9.12) | nennt eine Person und drei Gründe; dann legt er den Stift weg (R-12) | die angeklagte Person liest ihre Stufe 3 (bei den Verdächtigen aus der Fassung) |
| 13 Auflösung | öffnet Teil 90 und folgt seiner Reihenfolge (8.4) | legt den Bogen offen hin | lesen ihren Absatz „Die Rollen am Tisch“ vor (ab 14 Personen), sonst liest der Erzähler |

### MECH 1.3 Aufbau jeder Runde (30 Minuten)

| Abschnitt | Minuten | Was geschieht |
|---|---|---|
| a Rundenstart | 1 | Erzähler liest den Rundenstart (9.8). Ab jetzt sind die Indizkarten dieser Runde frei |
| b Tischgespräch und Verhörstuhl | 17 | Alle reden. Jede Rolle verfolgt ihre zwei Nachbohr-Ziele der Runde. Der Detektiv holt Personen auf den Verhörstuhl (je höchstens zwei Minuten, R-02). Geheimniskarten werden umgedreht, sobald ein Pflicht-Auslöser erfüllt ist (mit dem Ruf „Karte!“, R-03). Marker werden umgestellt. Aktionskarten werden gespielt. Bei Flaute liest der Erzähler einen Impuls (9.9). Ab 14 Personen: in Runde 1 nach der Hälfte „Wechsel!“, in Runde 2 und 3 nach der Hälfte erst die Gegenüberstellung, dann „Wechsel!“ |
| c Reinen Tisch | 2 | Erzähler fragt einmal reihum: „Will jemand reinen Tisch machen?“ Wer will und darf (Rundensperre), dreht seine Geheimniskarte um |
| d Untersuchungen | 6 | Der Detektiv nennt nacheinander drei Indizkarten aus Teil 01. Der Erzähler sucht den Code im Stapel und gibt die Karte ungelesen weiter. Der Detektiv liest sie laut vor. Nach jeder Karte stellt der Erzähler die Standardfrage (R-08) |
| e Marker-Probe und Bogen | 3 | Erzähler: „Nennt eine offene Karte oder ein offener Streifen für jemanden ausdrücklich einen anderen Ort als seinen Marker?“ Wer betroffen ist, stellt um (R-06). Der Detektiv trägt Vermerke ein |
| f Rundenschluss | 1 | Erzähler liest den Rundenschluss (9.8). In Runde 3 entfällt er; dort liegt die Tipp-Runde zwischen c und d |

**Runde 3 hat eine eigene Reihenfolge** (P2-03): a, b, c, dann die Tipp-Runde (7.1, 9.12), dann d und e, dann die Anklage
(8.1). So fallen alle Tipps, bevor XD3, PP9, VP7 und FK3 gezogen werden können. A:105 („am Ende jeder Runde“) und A:115
(„bevor der Detektiv anklagt“) bleiben erfüllt.

**Gegenüberstellung** (ab 14 Personen, Runde 2 und 3; **wörtlich** im Erzählerheft, P14-04, P145R2-M02): „Ab 14 Personen ruft der
Erzähler in Runde 2 und 3 nach der Hälfte von Abschnitt b die Gegenüberstellung aus. Ahmet, Fatma, Olli und Can setzen sich
nebeneinander an den Kopf des Tisches. Reihum stellt dort jede Person, deren Ziel in dieser Runde einer der vier ist, genau
eine Frage. Frage und Antwort dauern zusammen höchstens zwanzig Sekunden. Die Gegenüberstellung dauert fünf Minuten, ab
18 Personen sieben. Danach ruft der Erzähler ‚Wechsel!‘.“ Die Gegenüberstellung trifft alle vier gleich und bleibt spoilerfrei
(E10). Was dort gesagt wird, gilt als vor allen gesagt (R-13). Der Verhörstuhl ruht in dieser Zeit; der Detektiv hört zu und
darf selbst fragen. Nachgerechnet (P145R2-M02): Mit genau einer Frage je Person gibt es in Runde 2 bei 14, 16, 18 und 20
Personen 11, 13, 15 und 17 Fragen, in Runde 3 12, 14, 16 und 18. Zu zwanzig Sekunden reichen fünf Minuten bis 16 Personen
und sieben Minuten ab 18.

**Kleine Runden** (**wörtlich** im Erzählerheft, P14-K14): „Bei 6 bis 8 Personen darf der Erzähler Abschnitt b nach zwölf
Minuten beenden, wenn alle Ziele gefragt sind.“

### MECH 1.4 Tischregeln (stehen gekürzt in jedem Rollenheft, ganz im Erzählerheft und in Teil 01)

| Nr | Regel |
|---|---|
| R-01 Tischgespräch | Alle dürfen jeden fragen. Lügen ist erlaubt, solange dein Heft es erlaubt (Stufe 1). Zeugen sagen über ihren eigenen Ort immer die Wahrheit (WELT §4.2) |
| R-02 Verhörstuhl | Der Detektiv darf jederzeit eine Person auf den Verhörstuhl bitten, höchstens zwei Minuten. Bis 11 Personen ruhen dabei die anderen Gespräche. Ab 12 Personen laufen sie leise weiter; wer zuhören will, kommt dazu. Soll eine Antwort dort vor allen gelten, bittet der Detektiv vorher den Erzähler um „Alle mal herhören!“. Keine Höchstzahl je Runde (P145R2-M01) |
| R-03 Umdrehen ist Pflicht | Ist ein Pflicht-Auslöser aus deinem Heft erfüllt und die Rundensperre vorbei, drehst du deine Geheimniskarte sofort um, liest „Was ich zugebe“ vor und sagst den Domino-Hinweis. Was auf deiner Karte steht, darfst du danach nicht mehr bestreiten. Was dein Heft dir für die Zeit danach vorgibt, gilt weiter. Bevor du umdrehst, rufst du laut „Karte!“. Alle Gespräche ruhen, bis du vorgelesen hast und die genannte Person geantwortet hat (P2-16) |
| R-04 Rundensperre | Steht in deinem Heft „frühestens in Runde N“, bleibt die Karte vorher zu. Ist der Auslöser früher erfüllt, drehst du sie gleich zu Beginn von Runde N um |
| R-05 Reinen Tisch | Am Rundenende darfst du deine Geheimniskarte freiwillig umdrehen, wenn die Rundensperre vorbei ist |
| R-06 Marker | Jede Person hat zwei Marker: „23:57“ und „Scheppern“. Nennt eine offene Indizkarte, ein offener Streifen, eine offene Geheimniskarte oder eine vor allen vorgelesene Notiz aus einem Heft für dich ausdrücklich einen anderen Ort, oder verlangt es ein Auslöser in deinem Heft, stellst du deinen Marker sofort vor allen um. Schlüsse aus mehreren Karten zählen nicht; sie gehören in die Anklage. Ortslügen fallen vor Geheimnissen: Du darfst den Marker umstellen und trotzdem noch ausweichen, warum du dort warst, bis deine Geheimniskarte offen ist |
| R-07 Aktionskarten | Einmal im Spiel, offen ausspielen, danach umdrehen. Nur im Tischgespräch (Abschnitt b), sofern die Karte nichts anderes sagt. Nicht während einer Untersuchung, nicht ab der Tipp-Runde |
| R-08 Standardfrage | Nach jeder Indizkarte fragt der Erzähler: „Löst diese Karte bei jemandem etwas aus?“ Wer betroffen ist, dreht um (Rundensperre beachten). Liegen Zeugenstreifen aus, prüft der Erzähler danach still: „Steht dieser Code in meiner Tabelle ‚Karten unter den Streifen‘?“ (9.14). Steht er dort, zieht er die genannte Karte unter dem Streifen hervor und legt sie offen daneben, sofort oder zu Beginn der genannten Runde |
| R-09 Offen ist offen | Was einmal offen liegt (Karte, Streifen, Geheimniskarte), bleibt offen auf dem Tisch. Indizkarten legt der Detektiv offen an den Rand des Lageplans |
| R-10 Herr Schneider | Herr Schneider sitzt mit einem Kühlpack im Buffetsaal. Der Erzähler spricht ihn nur mit den Sätzen aus 9.10, und nur, wenn eine Indizkarte (JA9, PM3) oder die Aktionskarte „Krankenbesuch“ es verlangt |
| R-11 Nichts vorher lesen | Indizkarten, fremde Geheimniskarten, Zeugenstreifen, fremde Hefte, Fassungen und Teil 90 liest niemand vorher. Der Erzähler auch nicht |
| R-12 Ende der Ermittlung | Mit der Anklage legt der Detektiv den Stift weg. Was danach offen wird (Stufe 3), zählt nicht für seine Punkte |
| R-13 Vor allen | „Vor allen“ heißt: Der ganze Tisch hört zu. So ist es bei der Gegenüberstellung, beim Ortstermin und bei den Antworten auf einen Impuls des Erzählers. Ebenso beim Vorlesen einer umgedrehten Karte und nach dem Ruf „Alle mal herhören!“. Am Verhörstuhl gilt es nur, solange die anderen Gespräche ruhen. Wer im Grüppchen einen solchen Satz sagen will, ruft den Erzähler und sagt ihn dann vor allen (P2-10, P2-16, P145R2-M01) |
| R-14 Bestätigen | Sollst du sagen, ob etwas stimmt, und dein Heft hält es noch zurück, sagst du: „Dazu sag ich jetzt nichts.“ Das gilt als Antwort. Lügen darfst du nur, wo dein Heft es erlaubt (P145R2-M04, P2-20) |

**Kurzform in jedem Rollenheft, jedem Zusatzheft und in Teil 01, Kasten „So spielt ihr“ (wörtlich, P5-K7, P2-16, P145R2-M04):**
> „Jeder darf jeden fragen. Lügen darfst du nur, wenn dein Heft es erlaubt. Darfst du etwas noch nicht bestätigen, sagst du:
> ‚Dazu sag ich jetzt nichts.‘ Sobald ein Auslöser aus deinem Heft eintritt, drehst du deine Geheimniskarte sofort um. Vorher
> rufst du laut ‚Karte!‘. Was offen liegt, bestreitest du nicht mehr. Nennt etwas Offenes für dich ausdrücklich einen anderen
> Ort, stellst du deinen Marker sofort um. ‚Vor allen‘ heißt: Der ganze Tisch hört zu. Das ist so am Verhörstuhl, solange
> alle anderen schweigen, beim Ortstermin, bei einem Impuls, beim Vorlesen einer Karte und nach ‚Alle mal herhören!‘. Deine
> Aktionskarte spielst du einmal, nur im Gespräch.“

### MECH 1.5 „Was alle wissen“ (gemeinsames Wissen, wörtlich in allen Heften, in Teil 01 und im Erzählerheft)

Dieser Block steht gleich lautend in jedem Rollenheft (Teil 10), jedem Zusatzheft (Teil 12), in Teil 01 und im Erzählerheft
(Teil 00, Seite 7; P145R2-M09). Er ist wahr
für jede Person, weil es sich nach Mitternacht sofort herumgesprochen hat. Ungespielte Zusatzrollen heißen darin „ein
Gast“, ungespielte Zeugen 5–10 werden umschrieben (WELT §1.1). Platzhalter in eckigen Klammern setzt der Generator nach
Besetzung ein (M-04).

**wörtlich (Lesetext, Ziffern erlaubt):**

> **Was alle wissen**
> – 18:00 Uhr: Ihr kommt über die Sandsteinstufen und das Außentor. Herr Schneider begrüßt euch knapp. Am Jackenständer im Ost-Saal sammelt Ahmet von allen aus der Clique 150 € „Miete“ in Bargeld ein. Der Detektiv ist euer Gast und zahlt nichts.
> – 19:00 Uhr: Das Buffet ist eröffnet.
> – 20:15 Uhr: Olli sucht die Toilette und steht plötzlich im dunklen Vorratsraum vor der Mitternachtstorte. [Azra | Ein Gast] ruft: „Einbrecher an der Torte!“ Alle lachen.
> – 21:00 Uhr: Im Turmgang schreit [Sibel | ein Gast] vor der Ritterrüstung auf. Als es sich herumspricht, lachen alle.
> – 22:00 Uhr: Herr Schneider zündet die drei roten Kerzen im Messingkerzenständer auf der Anrichte an. Es sind die einzigen echten Kerzen im Keller. Er verlangt leisere Musik.
> – 23:00 Uhr: Für das Ratespiel im Ost-Saal kommen alle Handys in den Handykorb. Nur [Joanna | die Fotografin des Abends] behält ihr Handy. An der Theke wird Herr Schneider laut. Die meisten sitzen beim Ratespiel und verstehen die Worte nicht.
> – 23:30 Uhr: Dichter Qualm aus dem Kamin füllt den Kaminsaal. Alle husten. Die Klappen der Lichtschächte werden aufgerissen.
> – 23:55 Uhr: Alle sollen in den Ost-Saal: blinde Kuh, Torte und Gruppenfoto. Der Detektiv bekommt die Augenbinde und Kopfhörer mit lauter Musik.
> – 23:58 Uhr: Ein Knall, der Strom ist weg. Herr Schneider brüllt: „Hab ich dich!“ Dann: „Stehen bleiben!“ Und: „Stehen bleiben, hab ich gesagt!“ Kurz darauf scheppert es laut an der Theke.
> – 0:00 Uhr: Das Licht geht wieder an. Der Messingkerzenständer liegt vor der Vorratsraumtür am Boden. Jemand ruft: „Hier liegt Herr Schneider!“ Er liegt gleich hinter der Tür, bewusstlos, mit einer dicken Beule.
> – Kurz danach: Herr Schneider kommt zu sich. Sein Schlüsselbund ist weg. Das Außentor ist abgeschlossen. Kein Handy hat Empfang.
> – Herr Schneider erinnert sich nur: Er wollte die Notlaterne holen. Ein leuchtendes Gespenstergesicht sprang ihn an. Er hat eine Kapuze gepackt: „Hab ich dich!“ Danach weiß er nichts mehr.
> – Ahmet, Fatma, Olli und Can sind die vier Verdächtigen. Einer von ihnen war es.

Ab 13 Personen steht am Ende der Zeile „18:00 Uhr“ zusätzlich, **wörtlich**: „Beim Einlass habt ihr heimlich eine
Dankeskarte für Herrn Schneider unterschrieben.“ (P14-K17, P145R2-K10, ZR ZG-14) Ab 13 Personen spielen Zusatzrollen mit, die
davon wissen; so wissen es auch die Rollen 1–10.

Prüfung gegen WELT: 18:00 (§3.3), 20:15 (W-13), 21:00, 22:00 (einzige echte Kerzen), 23:00 (W-27, Handys K-23), 23:30, 23:55 (W-08,
D-42), Rufe (§5.1, sehr laut, im Buffetsaal, Durchgang und Ost-Saal hörbar, für den Rest sofort herumerzählt), 0:00
(§3.4), Erinnerung (§1.4). Den Ruf „Hier liegt Herr Schneider!“ gibt der Block ohne Namen wieder, weil Marek ungespielt
nicht genannt wird (WELT §1.1).

### MECH 1.6 Was der Detektiv selbst weiß (Teil 01, aus WELT §1.5)

**wörtlich (Lesetext):**

> **Was du selbst weißt**
> – Ab zehn vor zwölf sitzt du im Ost-Saal an der langen Tafel, auf der Ostseite.
> – Um 23:54 Uhr siehst du Olli hereinkommen. Er setzt sich an den Kopf der Tafel.
> – Um 23:55 Uhr wirst du die blinde Kuh: Augenbinde, Ehrenplatz der blinden Kuh, Kopfhörer mit lauter Musik. Ab jetzt siehst du nichts mehr.
> – Du hörst nur sehr Lautes: den Knall, „Hab ich dich!“, zweimal „Stehen bleiben!“, das Scheppern und „Hier liegt Herr Schneider!“.
> – Kurz nach Mitternacht nimmt dir jemand Augenbinde und Kopfhörer ab: „So, Augen auf. Das war nicht die Überraschung.“
> – Um 0:20 Uhr bittet dich Herr Schneider: „Finde raus, wer das war. Bis zum Morgen.“

### MECH 11.1 Knoten

| Id | Fakt | Halter (gespielt) | Ersatz bei Abwesenheit | frühestens |
|---|---|---|---|---|
| D1 | Olli um 23:57 am Eiskübel | Joanna S1 (Liste); Ahmet, Fatma (S1, und GK-Domino Ahmet); Olli GK | Str Joanna (FX3, Zeitstempel) | R1 |
| D2 | Olli beim Scheppern nicht bei Lejla | Lejla S1 | Str Lejla (DM3, Zeitstempel) | R1 |
| D3 | Olli Stufe 2: Bogentür, 2.000 €, Eiskübel, „Gesicht aus dem Vorratsraum“ (wahr) und „geduckt“ (gelogen, mündlich) | Olli | – (immer gespielt) | R1 |
| D4 | Fatma um 23:57 an der Klappe | Joanna S1 | Str Joanna | R1 |
| D5 | Fatma Alibi | Emine S1 | Str Emine (RH3) | R1 |
| D6 | Fatma Heimlichtuerei | Fatma GK; Emine GK | NN3; GK Emine (Erzählertabelle) | R1 (Fatma), R2 (Emine) |
| D7 | Ahmet Alibi | Marek S1; Damir | Str Marek (WJ9) | R1 |
| D8 | Ahmet Heimlichtuerei | Ahmet GK; Lejla GK; Aylin | PM3, WM9; GK Lejla (Erzählertabelle) | R2 (praktisch) |
| D9 | Ahmets Foto 23:51 | Joanna GK | GK Joanna (Erzählertabelle) | R2 |
| D10 | Can Heimlichtuerei | Can GK; Zeynep GK | JT3; GK Zeynep (Erzählertabelle) | R1/R2 (Can), R3 (Zeynep) |
| D11 | Cans Alibi (Gesicht vor dem Scheppern) | Tim GK, Marek GK, Zeynep GK; Hana (stützend) | GK Tim, Marek, Zeynep (Erzählertabelle); FK3 | R3 |
| D12 | zweite Gestalt nach dem Gesicht | Marek GK | GK Marek (XD3, JT3) | R3 |
| D13 | Wachs für Olli, Kurzschluss | Tim GK; Wojtek | MR4; GK Tim (Erzählertabelle) | R2 (MR4), R3 (Tim) |
| D14 | Fundort Eiskübel | – | PP9 | R3 |
| D15 | Schlüsselbeweis | – | XD3 + FN3 | R3 |
| D16 | falsche Fährte gelbe Kapuze | Herr Schneider (Tat-Moment), JA9 | – | R1 |

### MECH 11.2 Kanten (Auslöser → Folge)

| von | nach | Art |
|---|---|---|
| FX3 oder Joanna S1 (D1, D4) | Olli GK (D3); Fatma Marker 23:57 → 4a | Pflicht |
| DM3 oder Lejla S1 (D2) | Olli GK (D3) | Pflicht |
| Ahmet GK (Domino) | Olli GK (D3) | Pflicht (A:95: Ahmets Aussage) |
| Olli GK (Domino „Gesicht aus dem Vorratsraum“) + JA9 | Can GK (D10) | Pflicht |
| Can GK (Domino Fatma 23:54) | Druck auf Fatma | Druck |
| Fatma GK (Domino Ahmet 23:57) | Druck auf Ahmet; mit WE3 zur Taschenkontrolle | Druck |
| FM9 + Fatma Marker auf 4a | Fatma GK (D6) | Pflicht |
| NN3 | Fatma GK, Emine GK (R2) | Pflicht |
| PM3 oder WM9 | Ahmet GK (D8), Lejla GK (R2), Joanna GK (R2) | Pflicht |
| WE3 | Lejla GK, Joanna GK (R2) | Pflicht |
| JT3 | Can GK; Zeynep GK, Marek GK (R3) | Pflicht |
| MR4 | Tim GK (R3), Wojtek GK (R2) | Pflicht |
| FK3 | Zeynep GK, Tim GK (R3) | Pflicht |
| XD3 | Marek GK (R3) | Pflicht |
| Tim GK, Marek GK, Zeynep GK (D11) + Can GK oder JT3 | Bogen: Can Alibi ✓ → Can scheidet aus | Bogen |
| Marek GK (D12) + D11 | Ollis „Gespenst“-Version widerlegt | Bogen |
| PP9 + D1 + XD3 + FN3 (passende Spur, Teil 2) | Überführung Olli (2.4) | Bogen |

Keine Kante führt im Kreis: Jede Pflicht hängt an einer Indizkarte oder an Wissen, das selbst an einer Indizkarte oder an
offenem Stufe-1-Wissen hängt. Keine Pflicht verlangt eine Karte, die erst durch dieselbe Geheimniskarte frei würde.

### MECH 11.3 Pfad-Skizzen

**6 Personen, Tisch zurückhaltend.** R1: WJ9 (Str Marek → M1), RH3 (Str Emine → M2), DM3 (Str Lejla → Olli ✗; Pflicht für
Olli → GK: M7, Ort um 23:57 Eiskübel, Domino zu Can). Ollis Marker 1 → 4b. R2: Taschenkontrolle bei Can (JT3 frei → Can GK:
M6; Can-Marker 23:57 → 5; Karten unter den Streifen Marek und Zeynep vorgemerkt für R3), Stirnlampe; PM3 (M4; Ahmet GK; Lejla GK →
Ahmet-Ort), NN3 (M5; Fatma GK; Emine GK), FN3 (Teil 2), MR4 (Karte unter Tims Streifen vorgemerkt). Ende R2: Ahmet und Fatma
ausgeschieden; Olli und Can übrig. R3 Beginn: GK Marek, GK Zeynep, GK Tim gehen auf → M3, zweite Gestalt. R3: XD3 (Teil 1),
PP9 (M8), FX3 (Joannas Liste nachgeholt, Ort um 23:57 für Olli bestätigt). Überführt: Olli. 9 Punkte möglich.

**10 Personen, Tisch forsch.** R1 im Gespräch: Joanna trägt die Liste vor → Olli dreht um (M7, Domino „Gesicht aus dem
Vorratsraum“), Fatma stellt 23:57 auf 4a; Lejla erzählt, dass Olli erst nach dem Scheppern kam; Emine nennt Fatmas Alibi
(M2). Untersuchungen R1: WJ9 (Str Marek → M1), JA9 (gelbe Kapuze; mit Ollis Domino → Can dreht um: M6), FM9 (Fatma dreht um:
M5). R2: Lejla und Joanna dürfen umdrehen, sobald PM3 oder WM9 offen ist; Untersuchungen PM3 (M4, Ahmet dreht um), FN3, MR4.
Tim ist gesperrt bis R3. Ende R2: Ahmet, Fatma ausgeschieden; Can hat M6, Alibi offen; Olli ✗. R3: Tim dreht sofort um (MR4
in R2 gezogen) → M3 über Tim; XD3 (Karte unter Mareks Streifen → M3, zweite Gestalt), PP9, FK3 (Karte unter Zeyneps Streifen). Überführt: Olli.

**20 Personen.** Wie 10, dazu: Damir bestätigt M1 in R1, Sibel und Damir erklären den älteren Sprung (YT4), Tugba nennt den
linken Handschuh (VP7, FN3), Aylin und Azra stützen M4 in R2, Wojtek stützt M7 in R2, Hana stützt M3 in R3, Serkan stützt
M8 (niemand ist durchs Außentor hinaus). Die Aktionskarten der Zusatzrollen beschleunigen nur Gespräche. Der Fall fällt nicht vor R3, weil
D11, D14 und D15 an R3 hängen.

In allen drei Skizzen liegt die Tipp-Runde in Runde 3 vor den Untersuchungen XD3, PP9 und FK3 (1.3, P2-03).

---

## 8. Ermittlungsbogen (Teil 01)

### MECH 2.1 Raster (wörtlich als Tabelle)

Der Bogen hat vier Spalten, je eine für Ahmet, Fatma, Olli und Can, und drei Zeilen. Darunter stehen die Felder für
Fundort, Schlüsselbeweis und Überführung.

| Zeile | Ahmet | Fatma | Olli | Can |
|---|---|---|---|---|
| **Ort um 23:57** (Hilfszeile, keine Punkte) | | | | |
| **Alibi beim Scheppern** | | | | |
| **Heimlichtuerei** | | | | |
| **Ausgeschieden** (Alibi ✓ und Heimlichtuerei ✓) | ☐ | ☐ | ☐ | ☐ |

Unter dem Raster, **wörtlich**:

> **Fundort des Schlüsselbunds:** ______________________ Quelle: ______
> **Schlüsselbeweis:** Teil 1 ☐ · Teil 2 ☐ · gehört zu: ______________
> **Überführt** (Regel 2.4): ☐ Name: ______________

Eintragsweise je Zelle (steht als Hinweis über dem Raster, **wörtlich**):
> „Schreib in jede Zelle kurz, was feststeht, und woher du es weißt. Setz ✓, wenn es belegt ist, ✗, wenn es widerlegt ist. Ohne Zeichen ist es noch offen. Ein ✓ bei ‚Alibi‘ braucht eine Quelle, die nicht die Person selbst ist.“

Beispiel (nur hier, nicht im Druck): Spalte Olli, Zeile Alibi: „✗ kam erst nach dem Scheppern zum rechten Buffet (Lejla)“.

### MECH 2.2 Vermerke

Ein Vermerk ist der feste Satz unter „Für den Ermittlungsbogen“ auf einer Indizkarte, einer Geheimniskarte oder einem
Zeugenstreifen. Form, **wörtlich als Muster**:

> „[Zeile] · [Spalte]: [Kernfakt].“

| Zeile im Vermerk | Spalte | darf eine Person nennen? |
|---|---|---|
| „Ort um 23:57“ | eine der vier | ja (Ortsangabe) |
| „Alibi beim Scheppern“ | eine der vier, oder „für das leuchtende Gesicht“ | ja, weil es entlastet. Tim und Marek kennen das Gesicht nicht; ihre Vermerke lauten „für das leuchtende Gesicht“ (M-11) |
| „Heimlichtuerei“ | eine der vier, oder ohne Spalte (Satz mit „Wer“) | auf Geheimniskarten und Streifen ja; auf Indizkarten nur als Besitzangabe des Fundorts (etwa „in Fatmas Tasche“), nie als Urteil |
| „Fundort“ | ohne Spalte | **nie** |
| „Schlüsselbeweis, Teil 1“ | ohne Spalte | **nie** (A:107, Fehlerkorrektur 2). „Teil 2“ ist kein gedruckter Vermerk: Der Detektiv kreuzt Teil 2 an, wenn eine offene Karte an einer Person genau die Spur zeigt, die Teil 1 beschreibt (2.4, P2-02) |
| „Hinweis“ | ohne oder mit Spalte | ja, als Tatsache |

Kein Vermerk enthält „Täter“, „Täterin“, „wahr“, „falsch“, „Gerücht“, „gesteht“, „gibt zu“ (REG §6.10, US §13.5).
Was eine anwesende Rolle nur im Gespräch sagt, hat keinen gedruckten Vermerk. Der Detektiv schreibt es selbst ein und
nennt die Person als Quelle. Für die Punkte zählt der Kernfakt, nicht die Quelle (Abschnitt 6).

### MECH 2.3 Entlastungsregel (wörtlich, aus Kanon R-ENTLASTET, angepasst)

> **Wer ausscheidet:** Wer beim Scheppern nachweislich woanders war **und** eine aufgedeckte Heimlichtuerei hat, scheidet aus. Beides muss zusammenkommen. Das Alibi zeigt, dass die Person es nicht war. Die Heimlichtuerei erklärt, warum sie geflunkert oder sich seltsam verhalten hat. Das Scheppern ist das laute Poltern an der Theke, kurz nach dem Knall.

Folgen: Ahmet scheidet mit M1 und M4 aus, Fatma mit M2 und M5, Can mit M3 und M6. Olli kann nie ausscheiden: Sein Alibi
wird widerlegt (Lejla).

### MECH 2.4 Überführungsregel (wörtlich)

> **Wer überführt ist:** Eine Person ist überführt, wenn alle drei Dinge offen auf dem Tisch liegen:
> 1. Schlüsselbeweis Teil 1: eine Karte mit dem Vermerk ‚Schlüsselbeweis, Teil 1‘.
> 2. Schlüsselbeweis Teil 2: eine Spur an einer Person, die genau zu Teil 1 passt.
> 3. Der Fundort des Schlüsselbunds liegt an einem Platz, an dem diese Person kurz vor dem Scheppern nachweislich war (Zeile „Ort um 23:57“).
> Dann scheiden alle anderen aus.

Für Olli: XD3 (Teil 1) + FN3 als passende Spur an Olli (Teil 2: Kalkstaub und Holzsplitter an den Bündchen, rote
Kerzenwachstropfen auf dem Handschuh) + PP9 (Fundort Eiskübel) + „Ort um 23:57 · Olli: am Eiskübel“ (Joannas Liste,
Ahmet, Fatma oder Ollis Geheimniskarte). Teil 01 sagt vorab nicht, welche Spur Teil 2 ist; erst der Vermerk auf XD3
beschreibt sie (P2-01). Darum fällt der Fall nicht, bevor XD3 offen liegt. Das ist A:96, A:107, A:112 (XD3 + FN3 + PP9). Für keine andere Person können die
drei Teile zusammenkommen (WELT §6).

### MECH 2.5 Anklagefeld (wörtlich)

> **Anklage.** Ich klage an: ______________. Weil: (drei Gründe) ______________________________________
> Nach dem Auflösungsheft: Punkte ____ von 9 · Ende: ______________

### MECH 2.6 Inhalt von Teil 01 (Seitenfolge)

| Seite | Inhalt |
|---|---|
| 1 | Titel „Detektivbogen“, „Dein Auftritt“ (RK §6.3), „Was du selbst weißt“ (1.6), „Was alle wissen“ (1.5) |
| 2 | „So ermittelst du“ (Tischregeln R-01 bis R-14 in Kurzform), „Licht im Keller nach dem Knall“ (9.11 Teil B) |
| 3 | Kasten „Deine Aufgaben je Runde“ (RK §6.5); Untersuchungsliste: alle 19 Indizkarten nach Runde geordnet, je Zeile Titel, Code, „ab Runde“, Kästchen „gewählt in Runde __“ und „Kein Bund ☐“ (Tabelle 3.2, Spalten 1–4; RK-19) |
| 4 | Ermittlungsbogen: Raster 2.1, Regeln 2.3 und 2.4, Hinweise RK §6.9 |
| 5 | Vermerke-Liste, nummeriert 1 bis 48, zweispaltig (Nr · Runde · Quelle · Vermerk) |
| 6 | Anklagefeld 2.5 mit Hilfe RK §6.10; bei 6–11 Personen „Aktionskarten der fehlenden Zeugen“ (4.6, RK §6.8; Seite 2 wäre sonst zu voll, P145R2-K13) |

---

## 9. Indizkarten

### MECH 3.1 Grundsätze

1. **Nur Sichtbares.** Indizkarten zeigen Orte, Gegenstände und Spuren. Nie, was eine Person weiß, sah oder hörte. Nie ein
   Geständnis (A:18, US §13.5). Das Wissen der Zeugen steckt in den Rollen (A:38) oder auf den Zeugenstreifen.
2. **Ortstermine** ersetzen die alten Befragungskarten (LÜ L-02). Sie enthalten kein Wissen, nur den Ort und eine Frage.
   Wer dort war, antwortet vor allen. Fehlt die Person, dreht der Erzähler ihren Zeugenstreifen um. So kommt kein Zeugenwissen
   ohne Gespräch oder Untersuchung auf den Tisch (E7, LÜ L-03).
3. **Kein Name als Urteil.** Personennamen stehen nur als Besitzangabe („Ollis Weste“, „in Fatmas Tasche“). Fundort und
   Schlüsselbeweis nennen keine Person (A:107, ABG §3.19).
4. **Rundenbindung** (E12). Jede Karte trägt außen „ab Runde 1“, „ab Runde 2“ oder „ab Runde 3“. Nicht gezogene Karten
   bleiben in späteren Runden wählbar. XD3, PP9 und VP7 gibt es erst ab Runde 3, FN3 ab Runde 2. Damit fällt der Fall nicht vor
   Runde 3 (3.5).
5. **Jede Karte hilft.** Jede Ortskarte sagt, ob an genau diesem Platz der Schlüsselbund liegt. Nennt sie einen anderen Ort,
   dann nur als Entfernung (P2-18). Falsche Suche deckt Wahres auf, das weniger hilft, nie Falsches (REG §6.10).
6. **Codes:** die 19 Codes aus US §5, Inhalte neu (E3). Druck nach Code sortiert, damit die Lage im Stapel nichts verrät.
7. **Kein Spoiler-Wort:** „Täter“, „wahr“, „falsch“, „Gerücht“, Ende, Schlag-Verben, rote Teilchen am Fundort sind verboten
   (REG §6.1, §6.10, §6.12).
8. **Gleiche Titel für Personen-Karten** (E9, P2-01): Die drei Karten, die eine Person durchsuchen, heißen gleich gebaut:
   „Olli: Taschen und Kleidung“ (FN3), „Fatma: Taschen und Kleidung“ (NN3), „Can: Taschen und Kleidung“ (JT3). Der Fundort hat
   einen Ortstitel ohne Gegenstand („Vor der Theke am Ostende“, P2-07).
9. **Format** (P5-M6): A5-Feld hoch (148 × 210 mm), zwei je A4, Z-Falz in drei Felder zu 148 × 70 mm: Feld 1 Außenseite,
   Feld 2 Innenseite, Feld 3 leeres Deckfeld. Gefaltet liegt der Text innen. Umdrehen heißt: wenden und das Deckfeld
   aufklappen. Feld 3 trägt auf der Druckseite ein dichtes graues Raster als Sichtschutz (P145R2-K06).

### MECH 3.2 Übersicht

Spalten 1–4 stehen so in Teil 01 (Untersuchungsliste). Spalten 5–7 stehen nur hier.

| Titel (Teil 01) | Code | ab Runde | Art | Zone | füllt im Bogen | Meilenstein |
|---|---|---|---|---|---|---|
| Ortstermin: linker Buffettisch | RH3 | 1 | Ortstermin | 2 | über Emine oder ihren Streifen: Alibi Fatma | M2 |
| Ortstermin: rechter Buffettisch | DM3 | 1 | Ortstermin | 3 | über Lejla oder ihren Streifen: Alibi Olli ✗ | – (Domino zu Olli) |
| Ortstermin: hinter der Theke am Ostende | WJ9 | 1 | Ortstermin | 4d | über Marek oder seinen Streifen: Alibi Ahmet | M1 |
| Ortstermin: Tür zum Ost-Saal | FX3 | 1 | Ortstermin | 1 | über Joanna oder ihren Streifen: Ort um 23:57 für alle vier | – (Domino zu Olli, Fatma, Can) |
| Ortstermin: Durchgang mit Sicherungskasten | AD3 | 1 | Ortstermin | 6 | über Tim und Zeynep oder ihre Streifen: Hinweise | – |
| Jackenständer im Ost-Saal | WE3 | 1 | Spur | 1 | Hinweis | – (mit der Taschenkontrolle Ahmets Auslöser c; P145R2-M08) |
| Herrn Schneiders rechte Hand | JA9 | 1 | Spur | bei Herrn Schneider | Hinweis (gelbe Kapuze) | – (falsche Fährte, Druck auf Can) |
| Schauvitrine im Turmgang | FM9 | 1 | Spur | 8a | Hinweis (Schatulle fehlt) | (M5 mit anderem) |
| Bogentür und Ritterrüstung | YT4 | 1 | Spur | 7/8a | Hinweis · Heimlichtuerei (Bogentür) | M7 mit FN3 |
| Herrn Schneiders Klemmbrett | PM3 | 2 | Spur | bei Herrn Schneider | Heimlichtuerei (Miete) + Hinweis (2.000 €) | M4 |
| Hinter der Theke: Kaffeemaschine und Werkzeugkasten | MR4 | 2 | Spur | 4c | Hinweise (Knall, Möbelwachs) | – (Domino zu Tim) |
| Ascheneimer am Kamin | WM9 | 2 | Spur | 7 | Heimlichtuerei (Umschlag) | M4 |
| Kamin-Nische | VP7 | 3 | Spur | 7 | Hinweis (linker Handschuh) | – (stützt M9) |
| Fatma: Taschen und Kleidung | NN3 | 2 | Spur | bei Fatma | Heimlichtuerei Fatma | M5 |
| Can: Taschen und Kleidung | JT3 | 2 | Spur | bei Can | Heimlichtuerei Can | M6 |
| Olli: Taschen und Kleidung | FN3 | 2 | Spur | bei Olli | Hinweis · Heimlichtuerei (Bogentür) und Hinweis (Spur an Olli); passt zu Teil 1 → Teil 2 | M7 (mit YT4), M9 (mit XD3) |
| Messingkerzenständer und Vorratsraum | XD3 | 3 | Spur | 4c, 5 | Schlüsselbeweis Teil 1 | M9 (mit FN3) |
| Vor der Theke am Ostende | PP9 | 3 | Spur | 4b | Fundort | M8 |
| Ortstermin: im Steinbogen | FK3 | 3 | Ortstermin | 6 | über Zeynep oder ihre Karte: Heimlichtuerei Can, Alibi Can | M6, M3 („Zeyneps Aussage“, E3) |

Je Runde frei: Runde 1 neun Karten, ab Runde 2 sechs dazu, ab Runde 3 vier dazu (XD3, PP9, VP7, FK3).

Gleichgewicht der vier Verdächtigen auf den Karten (M-12): Jede hat eine Hinweiskarte ab Runde 1 und eine Gegenstandskarte
ab Runde 2. Ahmet: WE3 / WM9. Fatma: FM9 / NN3. Olli: YT4 / FN3. Can: JA9 / JT3.

### MECH 3.3 Kartentexte (wörtlich)

Außenseite aller Karten (Feld 1), **wörtlich**: „Indizkarte [Code] · ab Runde [N] · Erst umdrehen, wenn der Detektiv diese Karte
gewählt hat.“ Innenseite (Feld 2, im Z-Falz verdeckt): Titel, „Was du findest“, bei Ortsterminen „Ortstermin“, dann „Für den Ermittlungsbogen“.

Für alle Ortstermine gilt der Schlusssatz, **wörtlich**: „Liegt für diesen Ort ein Zeugenstreifen neben dem Lageplan,
dreht der Erzähler ihn jetzt um.“ Bei AD3 in der Mehrzahl: „Liegen für diesen Ort Zeugenstreifen neben dem Lageplan, dreht der Erzähler sie jetzt um.“
Für alle Ortstermine gilt als Vermerk, **wörtlich**: „Nichts Gedrucktes. Was die Person hier sagt, trägst du selbst ein.
Ein umgedrehter Zeugenstreifen hat einen eigenen Vermerk.“

**AD3 · ab Runde 1 · Ortstermin: Durchgang mit Sicherungskasten**
- Was du findest: „Ein kurzer, niedriger Gang, gut zwei Meter lang. An der Nordwand hängt der Sicherungskasten. Die Hauptsicherung ist wieder eingeschaltet. Darunter ein Fach mit Ersatzsicherungen, Putzmitteln und Lappen. Daneben stehen Getränkekisten. Der Steinbogen zum Kaminsaal ist nur 1 m breit. Im Durchgang liegt kein Schlüsselbund.“
- Ortstermin: „Wer beim Knall oder beim Scheppern im Durchgang oder im Steinbogen war, stellt sich an seinen Platz. Sag vor allen: Wo genau hast du gestanden? Was hast du bis zum Licht getan?“
- Wirkung: Tim und Zeynep antworten mit Stufe 1. Fehlen sie: Zeugenstreifen Tim und Zeugenstreifen Zeynep.

**DM3 · ab Runde 1 · Ortstermin: rechter Buffettisch**
- Was du findest: „Auf dem rechten Buffettisch stehen die Warmhaltebehälter, sauber zugedeckt. Bis zum Eiskübel vor dem Ostende der Theke sind es gut 3 m. Am rechten Buffettisch liegt kein Schlüsselbund.“
- Ortstermin: „Wer beim Scheppern hier war, sagt vor allen: Wo genau warst du? Wer war im Dunkeln neben dir, seit wann, und woran hast du die Person erkannt?“
- Wirkung: Lejla antwortet (Olli kam erst nach dem Scheppern). Fehlt sie: Zeugenstreifen Lejla. Pflicht-Auslöser für Olli (4.2).

**FK3 · ab Runde 3 · Ortstermin: im Steinbogen** („Zeyneps Aussage“, E3)
- Was du findest: „Der Steinbogen zwischen Durchgang und Kaminsaal ist nur 1 m breit. Wer hier steht und jemand rennt durch, wird gestreift. Aus dem Bogen sieht man den Durchgang entlang bis zur Tür und zur Theken-Klappe. Im Steinbogen liegt kein Schlüsselbund.“
- Ortstermin: „Wer im Steinbogen stand, stellt sich hinein und sagt vor allen: Was kam im Dunkeln durch den Bogen? Was hast du danach gehört? Und warum hast du genau hier gestanden?“
- Wirkung: Pflicht-Auslöser für Zeyneps Geheimniskarte (Runde 3 ist erreicht). Fehlt Zeynep: Zeugenstreifen Zeynep (falls noch zu); die Tabelle „Karten unter den Streifen“ (9.14) nennt FK3 auch für ihre Geheimniskarte. Pflicht-Auslöser auch für Tims Geheimniskarte (Nachbar im Durchgang).

**FM9 · ab Runde 1 · Schauvitrine im Turmgang**
- Was du findest: „Die gesprungene Scheibe der Schauvitrine ist angehoben. Frische Scherben liegen am Boden. Das Samtbett ist leer: Die Münzschatulle mit dem Wappen fehlt. Kein Schlüsselbund.“
- Vermerk: „Hinweis: Aus der Schauvitrine fehlt die Münzschatulle.“

**FN3 · ab Runde 2 · Olli: Taschen und Kleidung**
- Was du findest: „In der Tasche von Ollis dunkelblauer Daunenweste steckt sein rechter Arbeitshandschuh. An den Fingerkuppen: braunes Möbelwachs und weißer Kalk. Auf dem Handrücken: rote Kerzenwachstropfen. An beiden Bündchen von Ollis grauem Kapuzenpulli hängen Kalkstaub und ein paar feine Holzsplitter. Sonst nichts.“
- Vermerke: „Hinweis · Heimlichtuerei: Möbelwachs und Kalk an den Fingerkuppen von Ollis rechtem Handschuh. Vergleiche die Bogentür (YT4).“ und „Hinweis: Auf dem Handrücken rote Kerzenwachstropfen. An beiden Bündchen von Ollis Pulli Kalkstaub und feine Holzsplitter.“ (P2-17: ohne „frische“, Teil 90 behält es; P2-02: kein Vermerk „Schlüsselbeweis“ auf FN3; ob die Spur zu Teil 1 passt, entscheidet der Detektiv)

**FX3 · ab Runde 1 · Ortstermin: Tür zum Ost-Saal**
- Was du findest: „Die Holztür zwischen Ost-Saal und Buffetsaal steht offen. Aus der Tür sieht man bei Licht den ganzen Buffetsaal: Theke, Eiskübel, beide Buffettische und die Theken-Klappe. Durch die offene Tür neben der Klappe sieht man ein Stück in den Durchgang, bis zum Steinbogen. Den Sicherungskasten sieht man nicht. Auf der langen Tafel liegt ein umgestoßener Handyhalter neben dem Handykorb. In der Tür und am Handykorb liegt kein Schlüsselbund.“ (P2-18, P3R2-09)
- Ortstermin: „Wer um 23:57 Uhr in dieser Tür stand, sagt vor allen: Wen hast du von hier aus gesehen, und wo? Und wo warst du, als es schepperte?“
- Wirkung: Joanna antwortet mit ihrer Liste (WELT §5.4). Fehlt sie: Zeugenstreifen Joanna. Pflicht-Auslöser für Ollis Geheimniskarte. Fatma stellt ihren Marker „23:57“ nach R-06 auf 4a um; ihre Geheimniskarte dreht sie erst nach ihren Pflicht-Auslösern in 4.2 um. Can steht als „nirgends“ auf der Liste und gerät unter Druck.

**JA9 · ab Runde 1 · Herrn Schneiders rechte Hand**
- Was du findest: „Herr Schneider sitzt mit einem Kühlpack im Buffetsaal. An seiner rechten Hand hängen knallgelbe Fasern, wie von einer Kapuze. Er brummt: ‚Das Gespenst hatte eine Kapuze. Mehr weiß ich nicht.‘“
- Vermerk: „Hinweis: Herr Schneider hat im Dunkeln jemanden an einer knallgelben Kapuze gepackt.“

**JT3 · ab Runde 2 · Can: Taschen und Kleidung**
- Was du findest: „In der Bauchtasche von Cans signalgelbem Kapuzenpulli steckt eine zusammengefaltete weiße Maske. Sie ist mit grünlich-weißer Leuchtfarbe bemalt. Die Farbe ist noch leicht klebrig. Sonst nichts.“
- Vermerk: „Heimlichtuerei: In Cans Bauchtasche steckt eine Maske mit grünlich-weißer Leuchtfarbe.“ (P5-K12)

**MR4 · ab Runde 2 · Hinter der Theke: Kaffeemaschine und Werkzeugkasten**
- Was du findest: „Hinter der Theke steht die Kaffeemaschine. Ihr Stecker steckt in einer alten, wackeligen Mehrfachsteckdose auf dem Boden. Ein Steckplatz ist schwarz verschmort. Daneben steht ein Werkzeugkasten. Darin eine Dose braunes Möbelwachs: halb leer, am Rand Holzstaub. Kein Schlüsselbund.“
- Vermerke: „Hinweis: Der Knall kam aus dieser Mehrfachsteckdose.“ und „Hinweis: Mit diesem Möbelwachs wurde heute Holz behandelt.“

**NN3 · ab Runde 2 · Fatma: Taschen und Kleidung**
- Was du findest: „In Fatmas schwerer Umhängetasche aus Leder liegt zwischen Skizzenblock und Stiften eine Münzschatulle. Der Deckel ist blank poliert und zeigt ein Wappen mit zwei Löwen. Am rechten Ärmel von Fatmas beerenrotem Mantel hängen feine Glassplitter.“
- Vermerk: „Heimlichtuerei: Die Münzschatulle aus der Schauvitrine steckt in Fatmas Tasche.“

**PM3 · ab Runde 2 · Herrn Schneiders Klemmbrett**
- Was du findest: „Herr Schneider zeigt dir sein Klemmbrett. Oben das Belegungsblatt der Stiftung: ‚Saalmiete Schlosskeller: 0 Euro‘. Darunter der Quittungsblock mit zwei Durchschlägen: ‚Bogentür, Beschlag ausgerissen: 2.000 € Bargeld. Bis Mitternacht.‘ Ohne Namen. Und: ‚Miete: 0 Euro.‘ Herr Schneider sagt nur: ‚Das kläre ich mit den Leuten selbst.‘“
- Vermerke: „Heimlichtuerei: Der Keller hat nichts gekostet. Wer trotzdem ‚Miete‘ eingesammelt hat, hat geschwindelt.“ und „Hinweis: Für den Schaden an der Bogentür verlangt Herr Schneider 2.000 € bis Mitternacht.“

**PP9 · ab Runde 3 · Vor der Theke am Ostende**
- Was du findest: „Der Eiskübel steht vor dem Ostende der Theke. Das Eis ist halb geschmolzen. Obenauf fehlt eine Handvoll Eiswürfel. Unter den Eiswürfeln liegt Herrn Schneiders Schlüsselbund: große Schlüssel aus dunklem Eisen an einem Stahlring. Herr Schneider steckt ihn ein: ‚Aufgeschlossen wird, wenn's hell ist.‘“
- Vermerk: „Fundort: Unter den Eiswürfeln im Eiskübel liegt Herrn Schneiders Schlüsselbund.“ (geprüft, LÜ L-12)

**RH3 · ab Runde 1 · Ortstermin: linker Buffettisch**
- Was du findest: „Auf dem linken Buffettisch: Gebäck, Dips, eine silberne Thermoskanne und die Brottasche. In der Brottasche sind nur Brot und Krümel. Kein Schlüsselbund.“
- Ortstermin: wie DM3.
- Wirkung: Emine (und Fatma, weil sie beim Scheppern dort kauerte) antworten. Fehlt Emine: Zeugenstreifen Emine.

**VP7 · ab Runde 3 · Kamin-Nische**
- Was du findest: „In der Kamin-Nische liegt ein linker Arbeitshandschuh, schwarz vom Ruß, zur Seite geschoben. Unter der Asche liegt ein halb verkohlter Brief. Lesbar ist nur: ‚Ich trau mich nicht, es dir zu sagen.‘ Kein Name. Kein Schlüsselbund.“
- Vermerk: „Hinweis: Jemand hat hier einen linken Arbeitshandschuh liegen lassen.“

**WE3 · ab Runde 1 · Jackenständer im Ost-Saal**
- Was du findest: „Am Jackenständer hängt Ahmets schwarze Jacke. In der Brusttasche steckt eine Namensliste: die 17 anderen aus der Clique, hinter jedem Namen ‚150 € ✓‘. In der Innentasche ein Kaugummipapier. Kein Schlüsselbund.“
- Vermerk: „Hinweis: Ahmet hat heute von allen anderen aus der Clique 150 € eingesammelt.“ (P145R2-M08: Das Einsammeln weiß ohnehin jeder; ein Schwindel ist es erst mit dem Wissen, dass der Keller umsonst war.)

**WJ9 · ab Runde 1 · Ortstermin: hinter der Theke am Ostende**
- Was du findest: „Hinter dem Ostende der Theke steht die Anrichte Ost mit Saftkrügen, Gläsern, Tassen und Servietten. Von hier bis zur Vorratsraumtür sind es gut 3 m, bis zum Eiskübel 2 m. Hinter der Theke am Ostende liegt kein Schlüsselbund.“
- Ortstermin: wie DM3.
- Wirkung: Marek und Ahmet antworten (Ahmet war dort, sein Ort stimmt); Damir antwortet mit, wenn er gespielt wird (ZR-15). Fehlt Marek: Zeugenstreifen Marek.

**WM9 · ab Runde 2 · Ascheneimer am Kamin**
- Was du findest: „Im Ascheneimer neben der Kamin-Nische liegt ein leerer, gefalteter Umschlag mit einem langen Knick. Darauf steht in Ahmets Handschrift: ‚Miete Schlosskeller‘. Er ist grau von kalter Asche. Kein Schlüsselbund.“
- Vermerk: „Heimlichtuerei: Wer das Mietgeld eingesammelt hat, hat den Umschlag geleert und im Ascheneimer versteckt.“

**XD3 · ab Runde 3 · Messingkerzenständer und Vorratsraum**
- Was du findest: „Der Messingkerzenständer liegt umgestoßen auf dem Steinboden vor der Vorratsraumtür. Der Schaft ist leicht verbogen. Die drei roten Kerzen liegen daneben. Am Griff kleben rote Wachstropfen vom Kerzenteller. Im erstarrten roten Wachs am Fuß kleben feine Holzsplitter und weißer Kalk. Im Vorratsraum gleich hinter der Tür hängt die Notlaterne unberührt am Haken. Die Mitternachtstorte steht unversehrt im Regal. Kein Schlüsselbund.“
- Vermerk: „Schlüsselbeweis, Teil 1: Im roten Wachs am Fuß kleben feine Holzsplitter und weißer Kalk. Wer den Kerzenständer am Fuß hielt, hatte beides am Ärmel. Teil 2 ist die passende Spur an einer Person.“ (A:107, geprüft LÜ L-12, P2-02)

**YT4 · ab Runde 1 · Bogentür und Ritterrüstung**
- Was du findest: „An der geschnitzten Bogentür zum Turmgang ist ein Beschlag aus der gekalkten Wand gerissen. Frische Holzsplitter und weißer Kalk am Türbogen, darüber ein Rest braunes Möbelwachs. Im Helm der Ritterrüstung: Staub und eine alte Spinnwebe. Unter dem Sockel der Rüstung liegen ein paar kleine Glassplitter. Kein Schlüsselbund.“
- Vermerk: „Hinweis · Heimlichtuerei: Jemand hat heute an der Bogentür einen Beschlag ausgerissen und die Schramme mit braunem Möbelwachs überdeckt.“

### MECH 3.4 Domino-Wirkung je Karte (wer reagieren muss, wer unter Druck gerät)

„Pflicht“ = Pflicht-Auslöser einer Geheimniskarte (4.2). Bei fehlenden Zeugen gilt dasselbe über die Tabelle „Karten unter
den Streifen“ (9.14).

| Code | Pflicht (Rundensperre) | Druck ohne Pflicht |
|---|---|---|
| AD3 | – | Tim (Kasten), Zeynep (Bogen) |
| DM3 | Olli (Lejlas Aussage) | – |
| FK3 | Zeynep (R3), Tim (R3) | Can |
| FM9 | Emine (R2); Fatma, wenn ihr Marker „23:57“ schon auf 4a steht; Sibel; Azra | Damir |
| FN3 | – | Olli, Tugba, Tim, Wojtek |
| FX3 | Olli (Joannas Liste) | Fatma (Marker umstellen), Can („nirgends“) |
| JA9 | Can, wenn zusätzlich jemand vor allen sagt, er habe gesehen, wie das leuchtende Gesicht aus dem Vorratsraum kam | Zeynep |
| JT3 | Can; Zeynep (R3); Marek (R3) | – |
| MR4 | Tim (R3); Wojtek (R2) | Olli |
| NN3 | Fatma; Emine (R2); Azra | – |
| PM3 | Ahmet; Lejla (R2); Joanna (R2); Aylin (R2) | Olli, Tim |
| PP9 | – | Olli, Tim (Eis), Lejla |
| RH3 | – | Emine, Fatma |
| VP7 (R3) | Hana (ihr Brief) | Tugba, Olli |
| WE3 | Lejla (R2); Joanna (R2); Aylin (R2) | Ahmet |
| WJ9 | – | Marek, Ahmet |
| WM9 | Ahmet; Lejla (R2); Joanna (R2) | Azra |
| XD3 | Marek (R3) | Olli, Tim |
| YT4 | Sibel, Damir (Splitter) | Olli, Tim, Wojtek |

### MECH 3.5 Warum der Fall nicht vor Runde 3 fällt

1. **Überführung** braucht XD3 und PP9 (beide ab Runde 3, gezogen erst nach der Tipp-Runde) und die passende Spur an der
   Person (FN3, ab Runde 2). Teil 01 sagt nicht, welche Spur Teil 2 ist; erst der Vermerk von XD3 beschreibt sie. FN3 trägt
   keinen Vermerk „Schlüsselbeweis“ (P2-01, P2-02). Kein anderer Weg überführt (2.4).
2. **Ausschluss durch Entlastung:** Damit nur Olli übrig bliebe, müsste Can entlastet sein. Cans Alibi (M3) kommt nur aus
   Quellen mit Rundensperre 3: Tims, Mareks und Zeyneps Geheimniskarte, FK3, Hanas Rand-Indiz (M-14). Ende Runde 2
   stehen also bei gutem Spiel Olli und Can gegenüber (Kanon `fall.json:36-41`). Liegt FN3 schon in Runde 2 offen, ist Olli
   ab dann der Hauptverdächtige: Die roten Tropfen passen zu den einzigen echten Kerzen im Keller (MECH §1.5, 22:00). Überführt
   ist er erst mit XD3 und PP9, und Cans Alibi kommt erst in Runde 3 (P2-17).
3. **Gegengewicht** gegen eine frühe Festlegung auf Olli: Herr Schneiders Erinnerung (Gespenst, Kapuze), JA9 (gelbe
   Fasern), Ollis Stufe 2 („das Gespenst ist auf Herrn Schneider los“) und Joannas „Can: nirgends!“ belasten Can.
4. Bei 6 Personen gilt dasselbe, weil auch die Zeugenstreifen von Tim, Marek und Zeynep ihre Geheimnisse erst ab Runde 3
   freigeben (5.3).
5. **Titel verraten nichts:** Die drei Personen-Karten heißen gleich gebaut („[Name]: Taschen und Kleidung“), und in Runde 3
   stehen neben dem Kerzenständer zwei mögliche Verstecke zur Wahl (PP9 „Vor der Theke am Ostende“, VP7 „Kamin-Nische“). Der
   Fundort ist aus der Liste nicht ablesbar (P2-07).
6. **Die Tipps fallen vorher:** In Runde 3 tippen alle, bevor XD3, PP9 und FK3 gezogen werden können (1.3, P2-03).

---

## 10. Geheimniskarten und Aktionskarten

### MECH 4.1 Geheimniskarte: Form und Regeln

- **Format:** A5-Feld hoch (148 × 210 mm), zwei je A4, Z-Falz in drei Felder zu 148 × 70 mm: Feld 1 Vorderseite, Feld 2
  Innenseite, Feld 3 leeres Deckfeld. Gefaltet liegt der Text innen zwischen Feld 2 und Feld 3; außen sieht man nur die
  Vorderseite und eine leere Seite. Auf dem Tisch liegt die Vorderseite oben. „Umdrehen“ heißt: die Karte wenden und das
  Deckfeld aufklappen; dann liegt der Text offen (P5-M6). Feld 3 trägt auf der Druckseite ein dichtes graues Raster als
  Sichtschutz (P145R2-K06).
- **Vorderseite, für alle 18 gleich, wörtlich** (E8, LÜ L-04):
  > „Geheimnis · [Name] · Platz [Nr]
  > Liegt verdeckt vor dir. Umdrehen nur, wenn dein Heft es sagt, oder wenn du am Rundenende reinen Tisch machst.“
- **Vorderseite für fehlende Zeugen 5–10, wörtlich** (P14-K12):
  > „Geheimnis · [Name] · Platz [Nr] · Heute spielt diese Rolle niemand. Der Erzähler dreht sie um.“
- **Innenseite, für alle 18 gleich aufgebaut:**
  1. „Was ich zugebe“: Ich-Form, höchstens 60 Wörter, nur Wahres (das Spiel lügt nie mit eigener Stimme, REG §6.10).
  2. „Für den Ermittlungsbogen“: ein oder zwei Vermerke nach 2.2.
  3. „Und noch etwas“: der Domino-Hinweis, ein Satz, wahr, nennt eine andere Rolle oder einen Ort.
- Die **Bedingung** zum Umdrehen steht nie auf der Karte, nur im Heft (E8). Auch bei fehlenden
  Zeugen steht sie weder auf der Karte noch auf dem Etikett, sondern nur in der Tabelle „Karten unter den Streifen“ im
  Erzählerheft (9.14, P14-05).
- **Lügen auf Karten sind verboten.** Ollis Lüge in Stufe 2 („Ich hab mich geduckt, das Gespenst ist auf Herrn Schneider
  los“) sagt Olli nur mündlich (Rollenheft). Seine Karte enthält nur Wahres (M-15).
- Fehlt ein Zeuge 5–10, wird seine Geheimniskarte trotzdem gedruckt und liegt verdeckt unter seinem Zeugenstreifen (5.2).
  Ist ihre Bedingung erfüllt, zieht der Erzähler die Karte unter dem Streifen hervor und legt sie offen daneben. Der Streifen
  bleibt zu, bis sein eigener Code kommt (P14-K13). Geheimniskarten fehlender Zusatzrollen werden nicht gedruckt.

### MECH 4.2 Die 18 Geheimniskarten (Vorgabe für die Rollen-Phase)

Den Wortlaut „Was ich zugebe“ enthalten RK 2.8 bis 5.8, ZG x.6 und ZR x.7 (P145R2-K17). Kernfakten, Vermerke, Domino-Hinweis, Rundensperre und die
**Pflicht-Auslöser** stehen hier fest. Weitere Auslöser aus dem Gespräch darf die Rollen-Phase ergänzen, aber keine, die
eine Rundensperre umgehen.

**Die vier Verdächtigen (gleiche Gestalt, E9):** keine Rundensperre, je drei Pflicht-Auslöser, je ein Vermerk
„Heimlichtuerei“ und ein Vermerk „Ort um 23:57“, Domino-Hinweis im Ring Ahmet → Olli → Can → Fatma → Ahmet (M-16).

| Platz | Kernfakten „Was ich zugebe“ (aus WELT §7.1) | Vermerke (wörtlich) | Domino-Hinweis (wörtlich) | Pflicht-Auslöser |
|---|---|---|---|---|
| 1 Ahmet | 150 € „Miete“ von allen, obwohl der Keller umsonst war; das Geld sollte Mareks Nachzahlung für das zu groß bestellte Buffet bezahlen; 23:57 mit dem Umschlag hinter die Theke, wollte Herrn Schneider bitten, um zwölf nichts zu sagen | „Heimlichtuerei · Ahmet: hat von allen 150 € ‚Miete‘ eingesammelt, obwohl der Keller umsonst war.“ · „Ort um 23:57 · Ahmet: hinter der Theke am Ostende.“ | „Um 23:57 Uhr stand Olli am Eiskübel. Herr Schneider sagte zu ihm: ‚Zweitausend, bis zwölf.‘“ | (a) PM3 oder WM9 liegt offen; (b) Lejlas Geheimniskarte liegt offen; (c) eine Taschenkontrolle bei dir hat das Bündel Scheine gezeigt **und** WE3 liegt offen, Reihenfolge egal (P2-19) |
| 2 Fatma | 23:40 Münzschatulle aus der schon gesprungenen Vitrine ausgeliehen, um das Wappen abzuzeichnen, Rückgabe Montag; 23:56 Drohung; 23:57 zur Theken-Klappe, um sie zurückzugeben | „Heimlichtuerei · Fatma: hat um 23:40 die Münzschatulle aus der Vitrine ausgeliehen, um das Wappen abzuzeichnen. Rückgabe am Montag.“ · „Ort um 23:57 · Fatma: an der Theken-Klappe.“ | „Um 23:57 Uhr ging Ahmet mit einem dicken Umschlag am Ostende hinter die Theke.“ | (a) NN3 liegt offen; (b) FM9 liegt offen **und** dein Marker „23:57“ steht schon auf der Klappe; (c) Emines Geheimniskarte liegt offen |
| 3 Olli | 18:35 Bogentür beim Tragen beschädigt, 18:45 mit Möbelwachs überdeckt; Herr Schneider verlangt 2.000 € bis Mitternacht; kurz vor zwölf am Eiskübel, wollte mit Herrn Schneider reden | „Heimlichtuerei · Olli: hat um 18:35 an der Bogentür einen Beschlag ausgerissen und die Schramme mit Möbelwachs überdeckt. Herr Schneider verlangt 2.000 € bis Mitternacht.“ · „Ort um 23:57 · Olli: am Eiskübel.“ | „Nach dem Knall sprang ein leuchtendes Gesicht aus dem Vorratsraum, und Herr Schneider packte es.“ | (a) Joanna liest vor allen aus ihrer Notiz von 23:57 vor, dass er am Eiskübel stand (etwa bei FX3), oder ihr Zeugenstreifen liegt offen (P2-16); (b) Lejla sagt vor allen oder ihr Streifen zeigt, dass du erst nach dem Scheppern zu ihr kamst (DM3); (c) Ahmet oder Fatma sagen vor allen, dass du um 23:57 am Eiskübel standest (A:95) |
| 4 Can | ab 23:54 mit Leuchtmaske im dunklen Vorratsraum, Streich für die blinde Kuh; Zeynep stand Schmiere; nach dem Knall herausgesprungen, Herr Schneider packte die Kapuze; losgerissen, weggerannt, Maske in die Bauchtasche, Turm-Toilette | „Heimlichtuerei · Can: hat ab 23:54 mit einer Leuchtmaske im dunklen Vorratsraum auf die blinde Kuh gewartet. Ein Streich.“ · „Ort um 23:57 · Can: im Vorratsraum.“ | „Um 23:54 Uhr tuschelten Fatma und Emine am linken Buffet. Fatma hielt ihre Tasche ganz fest.“ Fehlt Emine (RK-10): „Um 23:54 Uhr tuschelte Fatma mit einer Freundin am linken Buffet. Fatma hielt ihre Tasche ganz fest.“ | (a) JT3 liegt offen; (b) Zeyneps Geheimniskarte liegt offen; (c) JA9 liegt offen **und** jemand hat vor allen gesagt oder eine offene Karte sagt, dass das leuchtende Gesicht aus dem Vorratsraum kam, Reihenfolge egal (P2-19) |

Zu Cans Auslöser (c): Ollis offene Geheimniskarte erfüllt den zweiten Teil von Cans Auslöser (c), egal ob JA9 vorher oder
nachher offen liegt (P2-19, 11.2). Ollis Domino-Hinweis ist eine eigene Beobachtung. Eine bloße Vermutung, etwa Tugbas „Ich glaub, da wollte jemand die blinde Kuh im Vorratsraum
erschrecken“, erfüllt ihn nicht (P14-K01, P2-15, ZR ZG-15).

Zusätzlich gilt für Olli (Stufe 2, nur mündlich, WELT §7.1, W-25): Er sagt „das Gespenst“, nie Cans Namen, und behauptet,
er habe sich beim Knall am Eiskübel geduckt. Er stellt den Marker „Scheppern“ auf 4b. Stufe 3 steht in RN7 (8.1).

**Zeugen 5–10:** Rundensperre wie angegeben. Die Pflicht-Auslöser sind dieselben Codes, die in der Tabelle „Karten
unter den Streifen“ (9.14) stehen, damit gespielte und fehlende Zeugen gleich reagieren (M-17). Ihr offenes Wissen (Stufe 1)
steht nicht auf der Karte, sondern im Heft und auf dem Zeugenstreifen.

| Platz | Kernfakten (WELT §7.2) | Vermerke (wörtlich) | Domino-Hinweis (wörtlich) | Sperre | Pflicht-Auslöser |
|---|---|---|---|---|---|
| 5 Lejla | weiß von Ahmets Ärger mit der Essensrechnung; sah nachmittags auf Herrn Schneiders Klemmbrett „Saalmiete Schlosskeller: 0 Euro“; sah 23:57 Ahmet mit dickem Umschlag am Ostende hinter die Theke schlüpfen; Versprechen an Ahmet | „Heimlichtuerei · Ahmet: Der Keller hat nichts gekostet. Auf Herrn Schneiders Klemmbrett stand ‚Saalmiete Schlosskeller: 0 Euro‘.“ · „Ort um 23:57 · Ahmet: hinter der Theke am Ostende, mit einem dicken Umschlag.“ | „Als das Licht anging, ist Olli als Erstes zum Eiskübel, noch bevor jemand ‚Hier liegt Herr Schneider!‘ rief.“ | Runde 2 | WE3, PM3 oder WM9 liegt offen |
| 6 Emine | sah 23:40 im Turmgang, wie Fatma die Schatulle nahm („Montag bring ich sie zurück.“); hörte 23:56 Herrn Schneiders leise Drohung | „Heimlichtuerei · Fatma: Um 23:40 nahm Fatma die Münzschatulle aus der Vitrine. Sie sagte: ‚Montag bring ich sie zurück.‘“ | „Um elf ist Herr Schneider an der Theke laut geworden. Mit wem, hab ich vom Ost-Saal aus nicht gesehen.“ | Runde 2 | FM9 oder NN3 liegt offen |
| 7 Tim | der Knall kam aus seiner alten Mehrfachsteckdose, trotz Warnung; am Sicherungskasten rannte ein leuchtendes Gesicht an ihm vorbei in den Kaminsaal, danach brüllte Herr Schneider noch, erst dann schepperte es | „Alibi beim Scheppern · für das leuchtende Gesicht: Es rannte am Sicherungskasten vorbei in den Kaminsaal. Danach brüllte Herr Schneider noch. Erst dann schepperte es.“ · „Hinweis: Der Knall kam aus Tims alter Mehrfachsteckdose.“ | „Das Möbelwachs aus dem Werkzeugkasten hab ich um 18:45 Olli gegeben, für eine Schramme an der Bogentür.“ | Runde 3 | MR4 oder FK3 liegt offen |
| 8 Joanna | Foto 23:51: Herr Schneider und Ahmet streiten vor der Theke, Ahmet hält einen dicken Umschlag; Ahmet bat sie 23:53, es keinem zu zeigen | „Hinweis · Heimlichtuerei Ahmet: Foto um 23:51 Uhr. Herr Schneider und Ahmet streiten vor der Theke, Ahmet hält einen dicken Umschlag.“ | „Um fünf vor zwölf hab ich an der Tür zum Durchgang zum Gruppenfoto gerufen. Can war weder im Buffetsaal noch im Durchgang.“ | Runde 2 | WE3, PM3 oder WM9 liegt offen |
| 9 Marek | Nachzahlung 150 € pro Gast, heute in Bargeld fällig; im Kerzenlicht: Gesicht aus der Tür, gepackt, losgerissen, zur Klappe verschwunden; danach kam ein Umriss von der Klappe zu Herrn Schneider; dann das Scheppern | „Alibi beim Scheppern · für das leuchtende Gesicht: Es riss sich los und verschwand hinter der Theke zur Klappe. Erst danach schepperte es.“ · „Hinweis: Nach dem Gesicht kam noch jemand von der Klappe her zu Herrn Schneider. Nur ein Umriss.“ | „Kurz vor dem Knall rief Herr Schneider Tim zu: ‚Nicht die alte Leiste!‘ Tim stand einen Meter neben mir an der Kaffeemaschine.“ | Runde 3 | XD3 oder JT3 liegt offen |
| 10 Zeynep | stand ab 23:54 im Steinbogen Schmiere für Cans Streich; Can wartete mit Maske im Vorratsraum; kurz nach dem Knall rannte Can mit dem leuchtenden Gesicht vorbei und streifte sie; danach brüllte Herr Schneider noch; erst dann das Scheppern | „Heimlichtuerei · Can: Can wartete mit einer Leuchtmaske im dunklen Vorratsraum auf die blinde Kuh. Ich stand für ihn Schmiere.“ · „Alibi beim Scheppern · Can: Er rannte mit dem leuchtenden Gesicht durch den Bogen, bevor es schepperte.“ | „Als das Licht anging, stand Tim am Sicherungskasten, direkt an Cans Weg. Frag ihn, was an ihm vorbeikam.“ | Runde 3 | FK3 oder JT3 liegt offen |

Prüfung der Domino-Hinweise der Zeugen: Sie nennen nur Rollen, die bei Anwesenheit des Zeugen immer besetzt sind
(Lejla → Olli, Joanna → Can, Marek → Tim, Tim → Olli, Zeynep → Tim, Emine → niemand Bestimmtes). Sie drücken auf
verschiedene Personen, damit in Runde 2 und 3 neuer Druck entsteht (A:92, P2-06). Emines Hinweis nennt niemanden. Das ist
eine Abweichung von A:92 (MECH 12a): Emine schaut von 23:50 bis 23:58 nur auf Fatma (WELT §5.5); eine neue wahre Beobachtung
über eine immer besetzte Rolle hat sie nicht, und erfinden würde gegen den Kanon gehen (P145R2-K15). Die früheren Ahmet-Sätze von Lejla,
Joanna und Marek stehen in ihren Heften unter „Nach dem Umdrehen“; ihre Vermerke für M4 bleiben. Wer Platz k spielt,
hat alle Plätze unter k am Tisch (E6).

Mareks Kernsatz „Erst danach schepperte es“ und Tims „Danach brüllte Herr Schneider noch“ sind geometrisch geprüft
(WELT §5.3). Zeynep hört nie „Zweitausend“ (WELT §5.3).

**Zusatzrollen 11–18:** Den Wortlaut der Karten enthalten ZR 1.7 bis 8.7 (P145R2-K17). Vorgaben (WELT §7.3):

| Platz | Thema der Karte | Vermerk-Art | Sperre | Pflicht-Auslöser (mindestens) |
|---|---|---|---|---|
| 11 Sibel | Rüstung, Sprung in der Vitrine um 21:00 | „Hinweis: Der Sprung in der Vitrinenscheibe war schon um 21:00 Uhr da.“ | keine | FM9 oder YT4 liegt offen |
| 12 Damir | hat die Splitter unter den Sockel der Rüstung gekehrt | Hinweis (Splitter von 21:00) | keine | YT4 liegt offen |
| 13 Hana | Liebesbrief im Kamin | Hinweis ohne Hauptfall | keine | VP7 liegt offen |
| 14 Serkan | Wunderkerzen im Auto, „Decken“ als Ausrede | Hinweis: niemand ist durchs Außentor hinaus | keine | die Frage, warum er um 23:56 Uhr zum Außentor ging, wird ihm zweimal gestellt |
| 15 Azra | hat Fatma von der Schatulle erzählt | Hinweis | keine | NN3 oder FM9 liegt offen |
| 16 Wojtek | das Möbelwachs stammt aus seinem Werkzeugkasten | Hinweis zur Heimlichtuerei an der Bogentür (Dose halb leer, Holzstaub; zählt mit YT4 für M7) | Runde 2 | MR4 liegt offen |
| 17 Aylin | Quittungszettel „Miete: 0 Euro. Schneider“ | Heimlichtuerei · Ahmet mit dem Zettel als Beleg (zählt für M4) | Runde 2 | PM3 oder WE3 liegt offen |
| 18 Tugba | die Dankeskarte für Herrn Schneider (harmlos, W-17) | „Nichts für den Ermittlungsbogen.“ | keine | keiner; sie dreht um, wann sie will |

Regel für alle Zusatzrollen: Wissen, das **Cans Alibi** stützt (Reihenfolge Gesicht vor Scheppern, Hanas Kerzengeruch),
ist frühestens in Runde 3 frei, egal ob es offen im Heft oder auf der Karte steht (M-14). Tugbas Wissen über den linken
Handschuh (19:30) ist offen und sofort frei (W-17).

### MECH 4.3 Aktionskarte: Form und Regeln

- **Format:** A7 hoch (74 × 105 mm), acht je A4. Rückseite leer. Nach dem Ausspielen umdrehen: leere Seite = verbraucht.
- **Aufbau, für alle 18 gleich:** Kopf „Aktionskarte · [Name der Rolle]“, Name der Aktion, „Wirkung“ (höchstens 45 Wörter),
  „Grenzen“ (höchstens 30 Wörter), Fuß „Einmal im Spiel. Danach umdrehen.“
- Allgemeine Grenzen (stehen in R-07): nur im Tischgespräch, nicht während einer Untersuchung, nicht ab der Tipp-Runde,
  keine Karte öffnet eine Indizkarte einer späteren Runde, keine Karte zwingt jemanden, gegen eine Rundensperre umzudrehen,
  keine Karte zwingt zur Wahrheit (Stufe 1 bleibt erlaubt). Intern, nie als Drucksatz: Keine Aktionskarte und keine
  Indizkarte betrifft Kopfbedeckungen (REG §9 Nr. 18, P5-M5).
- Aktionskarten erzeugen Gesprächslagen. Ob daraus ein Auslöser wird, entscheidet das Heft der betroffenen Person.

### MECH 4.4 Die 18 Aktionskarten (wörtlich)

| Platz | Rolle | Name | Wirkung (wörtlich) | Grenzen (wörtlich) | ab Runde | Klasse |
|---|---|---|---|---|---|---|
| 1 | Ahmet | **Einspruch** | „Spiel sie, wenn dir eine Frage gestellt wird. Du antwortest nicht. Die fragende Person muss die Frage einer anderen Person stellen.“ | „Nicht gegen Ortstermine, Indizkarten oder Karten, die offen liegen. Was offen liegt, bleibt liegen. Ein Satz, der eine Karte auslöst, gilt trotzdem. Die Frage darf später wiederkommen.“ | 1 | Schutz |
| 2 | Fatma | **Gegenfrage** | „Spiel sie, wenn dir eine Frage gestellt wird. Zuerst beantwortet die fragende Person eine Frage von dir. Dann antwortest du.“ | wie Einspruch | 1 | Schutz |
| 3 | Olli | **Themenwechsel** | „Spiel sie, wenn gerade über dich gesprochen wird. Das Gespräch über dich endet. Der Erzähler liest sofort einen Impuls vor, und es geht damit weiter.“ | wie Einspruch | 1 | Schutz |
| 4 | Can | **Retourkutsche** | „Spiel sie, wenn dir jemand etwas vorwirft. Bevor du antwortest, sagt diese Person, wo sie selbst beim Scheppern war und wer das bezeugen kann.“ | wie Einspruch | 1 | Schutz |
| 5 | Lejla | **Krankenbesuch** | „Du gehst zu Herrn Schneider und stellst ihm zwei Fragen. Der Erzähler antwortet mit den passenden Sätzen aus ‚Herr Schneider antwortet‘. Liegt JA9 noch zu, legt der Erzähler sie offen hin, ohne dass der Detektiv eine Untersuchung verbraucht.“ | „Herr Schneider weiß nichts nach ‚Hab ich dich!‘. Über Geld und Ärger der Gäste sagt er nur: ‚Das kläre ich mit den Leuten selbst.‘“ | 1 | Frage |
| 6 | Emine | **Kreuzverhör** | „Du nennst zwei Personen und eine Frage. Die zweite geht kurz außer Hörweite. Die erste antwortet. Dann kommt die zweite zurück und antwortet auf dieselbe Frage.“ | „Danach darf jede Person am Tisch eine Nachfrage an eine der beiden stellen. Lügen nach Stufe 1 bleibt erlaubt.“ | 1 | Frage |
| 7 | Tim | **Stirnlampe** | „Der Detektiv darf in dieser Runde eine Untersuchung mehr machen: vier statt drei.“ | „Nur Indizkarten, die in dieser Runde schon frei sind.“ | 2 | Untersuchung |
| 8 | Joanna | **Zeitstempel** | „Eine Person deiner Wahl sagt, wo sie um 23:51 Uhr oder um 23:57 Uhr war. Du wählst die Uhrzeit. Sie nennt eine Person, die sie dort gesehen hat. Die genannte Person sagt sofort, ob das stimmt. Kann sie niemanden nennen, sagt sie das.“ | „Nennt sie jemanden, der heute fehlt, dreht der Erzähler dessen Streifen um, auch wenn sie ihn nur umschreibt. Der Streifen gilt als Antwort. Herr Schneider zählt als niemand.“ | 1 | Beleg |
| 9 | Marek | **Taschenkontrolle** | „Eine Person deiner Wahl zeigt, was sie bei sich trägt. Gibt es dafür eine Indizkarte, legt der Erzähler sie offen hin, ohne dass der Detektiv eine Untersuchung verbraucht. Sonst liest die Person ‚Was du bei dir trägst‘ aus ihrem Heft vor.“ | „Nur Taschen und was die Person bei sich trägt. Nur Indizkarten, die in dieser Runde schon frei sind.“ | 2 | Beleg |
| 10 | Zeynep | **Gelbe Karte** | „Eine Person deiner Wahl muss die nächste Frage, die ihr gestellt wird, sofort beantworten. Sie darf dafür keine Aktionskarte spielen.“ | „Eine schon gespielte Schutzkarte bleibt gültig. Lügen nach Stufe 1 bleibt erlaubt.“ | 1 | Frage |
| 11 | Sibel | **Noch mal rückwärts** | „Eine Person deiner Wahl erzählt ihre Nacht noch einmal, diesmal rückwärts: vom Licht um zwölf zurück bis 23:57 Uhr. Alle hören zu.“ | „Lügen nach Stufe 1 bleibt erlaubt. Die Person darf sich kurz besinnen.“ | 1 | Frage |
| 12 | Damir | **Teepause** | „Zwei Personen deiner Wahl setzen sich mit dir zur Seite und reden drei Minuten miteinander. Du hörst zu. Danach sagst du dem Detektiv einen Satz daraus.“ | „Dein Satz muss stimmen.“ | 1 | Frage |
| 13 | Hana | **Spurenlesen** | „Du wählst eine Zone auf dem Lageplan. Jede Person, deren Marker ‚Scheppern‘ dort steht, sagt, was sie im Dunkeln gehört, gespürt oder gerochen hat.“ | „Lügen nach Stufe 1 bleibt erlaubt.“ | 1 | Frage |
| 14 | Serkan | **Lagebesprechung** | „Der Detektiv sagt sofort laut, wen er gerade am meisten verdächtigt und warum. Danach darf jede Person genau einen Einwand sagen.“ | „Der Detektiv muss sich nicht festlegen, nur seine Lage schildern.“ | 1 | Frage |
| 15 | Azra | **Lupe** | „Du wählst eine offene Indizkarte und eine Person. Die Person beantwortet sofort eine Frage von dir zu diesem Fund.“ | „Lügen nach Stufe 1 bleibt erlaubt.“ | 1 | Frage |
| 16 | Wojtek | **Maßband** | „Du wählst zwei Orte auf dem Lageplan. Der Erzähler liest aus der Maßtabelle vor, wie weit sie auseinanderliegen und ob man im Dunkeln vom einen zum anderen etwas erkennen konnte.“ | „Nur Orte aus der Maßtabelle.“ | 1 | Untersuchung |
| 17 | Aylin | **Beleg bitte!** | „Eine Person deiner Wahl nennt für eine ihrer Behauptungen einen Beleg: eine Person, die es bezeugt, oder einen Gegenstand. Kann sie das nicht, schreibt der Detektiv ‚ohne Beleg‘ daneben.“ | „Die genannte Person sagt sofort, ob das stimmt. Hält ihr Heft es noch zurück, sagt sie: ‚Dazu sag ich jetzt nichts.‘“ | 1 | Beleg |
| 18 | Tugba | **Handzeichen** | „Du stellst allen eine Ja-oder-Nein-Frage über einen Ort oder eine Uhrzeit. Auf drei heben alle gleichzeitig die Hand für Ja.“ | „Jede Rolle antwortet nach ihrem Heft. Wer etwas noch zurückhalten darf, hebt nicht und sagt: ‚Ich enthalte mich.‘ Detektiv und Erzähler heben nicht.“ | 1 | Frage |

Zuordnung bei der Taschenkontrolle (steht im Erzählerheft, Seite 15, 9.1): Ollis Weste → FN3, Cans Bauchtasche → JT3, Fatmas Tasche → NN3.
Bei allen anderen gilt „Was du bei dir trägst“ im Heft. Vorgabe für Ahmets Heft: „ein dickes Bündel Scheine in der
Hosentasche“ (die Summe steht nur in Teil 90, WELT §1.8). Was eine Person zeigt, ist wahr; erklären darf sie es nach
Stufe 1.

### MECH 4.5 Gleichgewicht

| Klasse | Karten | Stärke | Begründung |
|---|---|---|---|
| Schutz | Einspruch, Gegenfrage, Themenwechsel, Retourkutsche | gleich stark, eine Frage oder ein Vorwurf | Die vier Verdächtigen haben gleich gebaute Karten. Ollis Karte heißt neutral „Themenwechsel“ (E9, REG §9 Nr. 16). Keine Schutzkarte hält einen Ortstermin, eine Indizkarte oder einen Pflicht-Auslöser auf |
| Untersuchung | Stirnlampe, Maßband | Stirnlampe stark (zehnte Untersuchung), Maßband mittel | Stirnlampe erst ab Runde 2, damit sie nicht die Runde-1-Spuren beschleunigt |
| Beleg | Zeitstempel, Taschenkontrolle, Beleg bitte! | Taschenkontrolle stark (freie Indizkarte), Zeitstempel mittel (kann einen Streifen öffnen) | Taschenkontrolle erst ab Runde 2 und nur für freie Karten |
| Frage | Krankenbesuch, Kreuzverhör, Gelbe Karte, Noch mal rückwärts, Teepause, Spurenlesen, Lagebesprechung, Lupe, Handzeichen | mittel bis schwach | Sie machen Gespräche schärfer, decken aber nichts selbst auf |

Gegengewicht: Die Gelbe Karte (Zeynep) bricht eine noch nicht gespielte Schutzkarte. Die Zeugen 5–10 haben die stärkeren
Karten, weil sie die Domino-Kette tragen (A:128). Zusatzrollen haben Gesprächskarten, damit sie den Hauptfall nicht allein
lösen (A:60, WELT §7.3).

### MECH 4.6 Aktionskarten fehlender Zeugen beim Detektiv (M-18)

Fehlt eine der Rollen 5–10, bekommt der Detektiv ihre Aktionskarte. Er spielt sie nach denselben Regeln. Aufdruck im Kopf
statt des Rollennamens, **wörtlich**: „Aktionskarte · heute beim Detektiv“.

| Personen | fehlende Zeugen | Aktionskarten beim Detektiv |
|---|---|---|
| 6 | Lejla, Emine, Tim, Joanna, Marek, Zeynep | Krankenbesuch, Kreuzverhör, Stirnlampe, Zeitstempel, Taschenkontrolle, Gelbe Karte |
| 7 | Emine bis Zeynep | Kreuzverhör, Stirnlampe, Zeitstempel, Taschenkontrolle, Gelbe Karte |
| 8 | Tim bis Zeynep | Stirnlampe, Zeitstempel, Taschenkontrolle, Gelbe Karte |
| 9 | Joanna, Marek, Zeynep | Zeitstempel, Taschenkontrolle, Gelbe Karte |
| 10 | Marek, Zeynep | Taschenkontrolle, Gelbe Karte |
| 11 | Zeynep | Gelbe Karte |
| 12–20 | keine | keine |

Grund: In kleinen Runden fehlen die Köpfe, die Fragen stellen. Die Karten geben dem Detektiv zusätzliche Wege, ohne dass
eine Rundensperre fällt. Aktionskarten fehlender Zusatzrollen werden nicht gedruckt.

---

## 11. Abwesenheitsblatt (Teil 02)

### MECH 5.1 Wann

Sobald eine der Rollen 5–10 unbesetzt ist (E7), also bei 6 bis 11 Personen. Ab 12 Personen gibt es kein Blatt. Bei 12 bis
20 Personen entfällt es ohne Ersatzseite (Teil 02 hat genug anderen Inhalt).

### MECH 5.2 Form

- **Ein A4-Blatt hoch, einseitig, mit 5 mm Rand** (A:57). Bis zu sechs Zeugenstreifen in zwei Spalten und drei Reihen, je
  100 × 95 mm. Gefaltet wird 30 mm unter der Oberkante, Druckseite außen: oben das Etikett (30 mm), darunter das Protokoll
  (65 mm, um 180° gedreht). Auf dem Tisch liegt das Etikett oben, das Protokoll mit der Schrift nach unten. Umdrehen heißt:
  den Streifen wenden (P14-02).
- **Satz:** Protokoll und Vermerk in 9 pt, rund 16 Zeilen. Joannas Notiz steht zweispaltig in 8 pt unter ihrem Protokoll
  (Ausnahme nur für die Notiz; neben dem Protokoll brächen die Zeilen um, P145R2-K04). Eine Schlusszeile zur Geheimniskarte gibt es nicht.
- Gedruckt werden nur die Streifen der heute fehlenden Zeugen, in Platzreihenfolge.
- Beim Aufbau legt der Erzähler jeden Streifen mit dem Etikett nach oben neben das Markerfeld der Zone des Zeugen. Darunter
  legt er die Geheimniskarte dieses Zeugen (Teil 20), verdeckt.
- Zwei Dinge je fehlendem Zeugen: **Zeugenstreifen** (sein offenes Wissen, Stufe 1) und **seine Geheimniskarte** (Stufe 2).
  So gibt es für gespielte und fehlende Zeugen dieselben Texte (M-19).

### MECH 5.3 Die sechs Zeugenstreifen

Etikett, **wörtlich als Muster** (P14-05, P14-06, P2-09):
> „Zeugenstreifen · [Name], [Rollenbezeichnung] · Zone [Nr], [Ort].
> Umdrehen, wenn der Detektiv [Ortstermin-Code] zieht oder beim ‚Zeitstempel‘ jemand [Name] als Zeugin/Zeugen nennt.
> Darunter liegt [Namens] Geheimniskarte. Wann sie umgedreht wird, weiß der Erzähler.“

Das Etikett nennt keine Freigabe-Codes der Geheimniskarte. Sie stehen nur in der Tabelle „Karten unter den Streifen“ im
Erzählerheft (9.14). Eine Schlusszeile im Protokoll gibt es nicht (P14-02). Die Rollenbezeichnung (Spalte 1 unten) hilft dem
Erzähler, wenn jemand die fehlende Person nur umschreibt.

| Zeuge, Rollenbezeichnung | Lage (Zone, Ort) | Streifen umdrehen bei | Geheimniskarte umdrehen bei | Inhalt des Protokolls (höchstens 80 Wörter; Wortlaut ZG 1.11, 2.11, 3.11, 4.12, 5.11, 6.11; Kernsätze aus WELT §5.3) | Vermerk (wörtlich) |
|---|---|---|---|---|---|
| Lejla, die Apothekerin | 3, rechter Buffettisch | DM3; Zeitstempel | WE3, PM3 oder WM9, ab Runde 2 | Sie kauerte beim Knall allein am rechten Buffettisch. Kernsatz: „Beim Scheppern war ich allein. Erst danach ist Olli zu mir gekrochen und hat geflüstert: ‚Lejla? Ich bin's, Olli.‘“ | „Alibi beim Scheppern · Olli: nicht am rechten Buffettisch. Er kam erst nach dem Scheppern dorthin.“ (P5-K11) |
| Emine, die Grundschullehrerin | 2, hinter dem linken Buffettisch | RH3; Zeitstempel | FM9 oder NN3, ab Runde 2 | Kernsatz: „Gleich nach dem Knall hat Fatma sich neben mich gekauert und geflüstert: ‚Emine? Ich bin's, Fatma.‘ Beim Scheppern war sie neben mir.“ | „Alibi beim Scheppern · Fatma: kauerte hinter dem linken Buffettisch neben Emine.“ |
| Tim, der Hobby-Elektriker | 6, am Sicherungskasten | AD3; Zeitstempel | MR4 oder FK3, ab Runde 3 | Er stand beim Scheppern im Durchgang am Sicherungskasten und suchte den Hauptschalter. Um zwölf schaltete er das Licht wieder ein. Gleich danach brachte Olli ihm Eis in einer Serviette für seinen eingeklemmten Finger. | „Hinweis: Tim war beim Scheppern im Durchgang am Sicherungskasten.“ |
| Joanna, die Fotografin des Abends | 1, Tür zum Ost-Saal | FX3; Zeitstempel | WE3, PM3 oder WM9, ab Runde 2 | Ihre Handy-Notiz mit Zeitstempel 23:57, Wortlaut WELT §5.4 (zweispaltig in 8 pt). Dazu: Herr Schneider sagte um 23:57 zu Olli „Zweitausend, bis zwölf“. Kernsatz (P3-04): „Im Dunkeln, kurz bevor das Licht wieder anging, hab ich mit der Handylampe die Tafel abgeleuchtet. Der Kopf der Tafel war leer.“ | „Ort um 23:57 · alle vier: siehe Joannas Liste (Ahmet hinter der Theke am Ostende, Fatma zur Klappe, Olli am Eiskübel, Can nirgends).“ |
| Marek, der Caterer | 4d, hinter der Theke am Ostende | WJ9; Zeitstempel | XD3 oder JT3, ab Runde 3 | Kernsatz: „Beim Knall hat Ahmet sich an meine Beine gekauert und geflüstert: ‚Marek? Ich bin's, Ahmet.‘ Er war noch da, als es schepperte, und auch, als das Licht anging.“ Dazu: Er hat Herrn Schneider gefunden | „Alibi beim Scheppern · Ahmet: kauerte hinter der Theke am Ostende an Mareks Beinen.“ |
| Zeynep, die Fußballtrainerin | 6, im Steinbogen | AD3; FK3; Zeitstempel | FK3 oder JT3, ab Runde 3 | Ab kurz vor zwölf stand sie im Steinbogen und wartete auf die blinde Kuh (halb wahr, WELT §4.2). Um 23:45 war Fatmas Umhängetasche am linken Buffet auffällig ausgebeult | „Hinweis: Um 23:45 Uhr war Fatmas Tasche auffällig ausgebeult.“ |

Zeiten im Protokoll nur als Reihenfolge, nie in Sekunden (WELT §0.2). „Zweitausend, bis zwölf“ steht nur bei Joanna
(WELT §5.6). Namen fehlender Zeugen stehen nur auf diesem Blatt, auf ihren Geheimniskarten, in Joannas Liste und in Teil 90 (WELT §1.1,
W-21, P14-16).

### MECH 5.4 Aufdecken

| Was | Wodurch | Wer dreht | Rundensperre |
|---|---|---|---|
| Zeugenstreifen | Ortstermin der Zone oder Aktionskarte „Zeitstempel“, bei der jemand den Zeugen nennt. Andere Aktionskarten öffnen keinen Streifen | Erzähler | keine (der Ortstermin selbst ist an seine Runde gebunden) |
| Geheimniskarte darunter | Ein Code aus der Tabelle „Karten unter den Streifen“ (9.14) liegt offen, egal wodurch: Untersuchung, Taschenkontrolle, Stirnlampe oder Krankenbesuch (P14-K02) | Erzähler, sofort oder zu Beginn der genannten Runde. Er zieht die Karte unter dem Streifen hervor und legt sie offen daneben. Der Streifen bleibt zu, bis sein eigener Code kommt (P14-K13) | wie in der Tabelle |

Nie offen von Anfang an, nie durch ein Gespräch allein (E7). Der Erzähler liest Streifen und Karte erst, wenn er sie
umdreht; dann liest der Detektiv sie laut vor.

### MECH 5.5 Warum das kein Selbstlöser ist (LÜ L-03)

Bei 6 Personen ist am Anfang nichts offen. In Runde 1 kann der Detektiv höchstens drei Ortstermine ziehen (oder vier mit
anderen Wegen), also höchstens drei der fünf Streifen mit Runde-1-Ortstermin. Ollis spätes Kommen (Lejla) und Joannas Liste
lösen nur Ollis Stufe 2 aus. Die Geheimnisse aller Zeugen sind gesperrt (Runde 2 oder 3). Cans Alibi kommt frühestens in
Runde 3. Der Schlüsselbeweis kommt frühestens in Runde 3. Prüfung in 11.3.

Die sechs Zeugenstreifen im Wortlaut (Etikett, Protokoll, Vermerk) stehen bei den Rollen in Kapitel 15: ZG 1.11, ZG 2.11,
ZG 3.11, ZG 4.12, ZG 5.11, ZG 6.11. Die Tabelle „Karten unter den Streifen“ steht im Erzählerheft, MECH 9.14.

---

## 12. Punkte, Tipp-Runde, Bonus-Ziele

### MECH 6.1 Die neun Meilensteine (A:108-112, Fehlerkorrektur 3)

Je Meilenstein ein Punkt, höchstens neun. Es zählt der **Kernfakt im richtigen Feld**, egal aus welcher Quelle (keine
Pfad-Strafe; für M1 bis M3 gilt die Regel unter der Tabelle). Kein Minuspunkt für Falsches. Es zählt, was bei der Anklage
auf dem Bogen steht (R-12).

| Nr | Feld | Kernfakt, der dastehen muss | Stichwort, das genügt |
|---|---|---|---|
| M1 | Alibi · Ahmet | Ahmet kauerte beim Scheppern hinter der Theke am Ostende (bei Marek) | „Ostende“ oder „bei Marek“ oder „bei Damir“ |
| M2 | Alibi · Fatma | Fatma kauerte beim Scheppern hinter dem linken Buffettisch (bei Emine) | „linkes Buffet“ oder „bei Emine“ |
| M3 | Alibi · Can | Can (das leuchtende Gesicht) war vor dem Scheppern schon durch den Durchgang Richtung Kaminsaal | „vor dem Scheppern weg“ oder „Gesicht vor dem Scheppern durch den Durchgang“ |
| M4 | Heimlichtuerei · Ahmet | Ahmet hat 150 € „Miete“ eingesammelt, obwohl der Keller umsonst war, oder den Umschlag geleert und versteckt | „Keller umsonst“, „Keller hat nichts gekostet“, „0 Euro“, „Miete erfunden“ oder „Umschlag“ zusammen mit „Ascheneimer“. „Miete“ allein genügt nicht, das Einsammeln wissen alle (P145R2-M08) |
| M5 | Heimlichtuerei · Fatma | Fatma hat die Münzschatulle aus der Vitrine ausgeliehen | „Münzschatulle“ |
| M6 | Heimlichtuerei · Can | Can hat mit der Leuchtmaske im Vorratsraum auf die blinde Kuh gewartet | „Maske“ oder „Streich“ |
| M7 | Heimlichtuerei · Olli | Olli hat die Bogentür beschädigt (2.000 €) | „Bogentür“ |
| M8 | Fundort | Der Schlüsselbund lag unter dem Eis im Eiskübel | „Eiskübel“ |
| M9 | Schlüsselbeweis | Teil 1 und Teil 2 angekreuzt **und** „gehört zu: Olli“ | XD3 offen, dazu die passende Spur an einer Person (FN3) offen, Olli eingetragen |

**M1 bis M3 zählen nur, wenn in der Zelle eine Quelle steht, die nicht die Person selbst ist:** eine Zeugin, ein Zeuge, ein
Streifen oder eine Karte. Welche, ist egal (P2-05, Entlastungsregel 2.3 „nachweislich“).

### MECH 6.2 Quellen je Meilenstein (alle Wege)

„GK“ = Geheimniskarte, „S1“ = offenes Wissen (Stufe 1) einer gespielten Rolle, „Str“ = Zeugenstreifen.

| Meilenstein | Quellen unabhängig von der Besetzung | Quellen aus Rollen 5–10 (gespielt oder als Streifen/GK) | Quellen aus Zusatzrollen |
|---|---|---|---|
| M1 | – | Marek S1 / Str Marek (WJ9, Zeitstempel) | Damir (Rand-Indiz) |
| M2 | – | Emine S1 / Str Emine (RH3, Zeitstempel) | – |
| M3 | FK3 (öffnet Zeynep); Verbindung Gesicht = Can über JT3 oder Cans GK | Tim GK, Marek GK, Zeynep GK (je ab Runde 3) | Hana (nur stützend, ab Runde 3) |
| M4 | PM3, WM9, Ahmets GK | Lejla GK; Marek GK (stützend); Joanna GK (Hinweis) | Aylin GK, Azra (Rand-Indiz) |
| M5 | NN3, Fatmas GK | Emine GK | Azra (stützend), Sibel (stützend) |
| M6 | JT3, Cans GK | Zeynep GK | Sibel (stützend) |
| M7 | Ollis GK; YT4 + FN3 zusammen | Tim GK | Wojtek GK |
| M8 | PP9 | – | Serkan (stützend: niemand ist durchs Außentor hinaus) |
| M9 | XD3 + FN3 | – | Tugba (stützend: linker Handschuh), VP7 (stützend) |

M8 und M9 haben bewusst nur Indizkarten als Quelle: Der Fundort belohnt die Suche, der Schlüsselbeweis die Kombination
(LÜ L-01 d). Beide Karten sind bei jeder Personenzahl verfügbar und schließen sich gegenseitig nicht aus.

### MECH 6.3 Matrix je Personenzahl (6 bis 20)

Jede Zelle nennt die erreichbaren Quellen. Immer verfügbar sind zusätzlich die besetzungsfreien Quellen aus 6.2 (Spalte 2);
sie werden nur bei M1 bis M3 nicht wiederholt, weil es dort keine gibt.

| P | besetzt | M1 Ahmet-Alibi | M2 Fatma-Alibi | M3 Can-Alibi (ab R3) | M4 | M5 | M6 | M7 | M8 | M9 |
|---|---|---|---|---|---|---|---|---|---|---|
| 6 | 1–4 | Str Marek (WJ9 oder Zeitstempel beim Detektiv) | Str Emine (RH3 oder Zeitstempel) | GK Tim (MR4/FK3), GK Marek (XD3/JT3), GK Zeynep (FK3/JT3) | PM3, WM9, GK Ahmet, GK Lejla (Str) | NN3, GK Fatma, GK Emine (Str) | JT3, GK Can, GK Zeynep (Str) | GK Olli, YT4+FN3, GK Tim (Str) | PP9 | XD3+FN3 |
| 7 | +Lejla | wie 6 | wie 6 | wie 6 | + Lejla gespielt | wie 6 | wie 6 | wie 6 | PP9 | XD3+FN3 |
| 8 | +Emine | wie 6 | Emine S1 (+RH3) | wie 6 | wie 7 | + Emine gespielt | wie 6 | wie 6 | PP9 | XD3+FN3 |
| 9 | +Tim | wie 6 | Emine | Tim gespielt; GK Marek, GK Zeynep (Str) | wie 7 | wie 8 | wie 6 | + Tim gespielt | PP9 | XD3+FN3 |
| 10 | +Joanna | Str Marek (WJ9 oder Joannas Zeitstempel) | Emine | wie 9 | + Joanna (Hinweis) | wie 8 | wie 6 | wie 9 | PP9 | XD3+FN3 |
| 11 | +Marek | Marek S1 | Emine | Tim, Marek gespielt; GK Zeynep (Str) | + Marek | wie 8 | wie 6 | wie 9 | PP9 | XD3+FN3 |
| 12 | +Zeynep | Marek | Emine | Tim, Marek, Zeynep | wie 11 | wie 8 | + Zeynep | wie 9 | PP9 | XD3+FN3 |
| 13 | +Sibel | Marek | Emine | wie 12 | wie 11 | + Sibel (stützend) | wie 12 | wie 9 | PP9 | XD3+FN3 |
| 14 | +Damir | Marek, Damir | Emine | wie 12 | wie 11 | wie 13 | wie 12 | wie 9 | PP9 | XD3+FN3 |
| 15 | +Hana | Marek, Damir | Emine | + Hana (stützend) | wie 11 | wie 13 | wie 12 | wie 9 | PP9 | XD3+FN3 |
| 16 | +Serkan | wie 15 | Emine | wie 15 | wie 11 | wie 13 | wie 12 | wie 9 | PP9 (+Serkan) | XD3+FN3 |
| 17 | +Azra | wie 15 | Emine | wie 15 | + Azra | + Azra | wie 12 | wie 9 | wie 16 | XD3+FN3 |
| 18 | +Wojtek | wie 15 | Emine | wie 15 | wie 17 | wie 17 | wie 12 | + Wojtek | wie 16 | XD3+FN3 |
| 19 | +Aylin | wie 15 | Emine | wie 15 | + Aylin | wie 17 | wie 12 | wie 18 | wie 16 | XD3+FN3 |
| 20 | +Tugba | wie 15 | Emine | wie 15 | wie 19 | wie 17 | wie 12 | wie 18 | wie 16 | XD3+FN3 (+Tugba) |

Ergebnis: Für jede Personenzahl hat jeder Meilenstein mindestens eine erreichbare Quelle. Ab 12 Personen haben M1 bis M7
mindestens zwei unabhängige Quellen. Bei 6 bis 10 Personen haben M1 und M2 je eine Quelle (der Streifen), die aber über zwei
Wege aufgeht (Ortstermin oder Zeitstempel) und an keiner Entweder-oder-Wahl hängt (M-20).

Budget-Prüfung 6 Personen, schlechtester Fall (kein Verdächtiger dreht freiwillig um): Runde 1 WJ9, RH3, YT4. Runde 2
Taschenkontrolle (FN3 frei), Stirnlampe (vierte Untersuchung): PM3, NN3, JT3, MR4. Runde 3 XD3, PP9, FK3. Die drei Untersuchungen der
Runde 3 fallen nach der Tipp-Runde und vor der Anklage. Damit liegen alle neun Meilensteine offen; M3 kommt über GK Marek (XD3), GK Zeynep (JT3) und GK Tim (MR4). Mit freiwilligem oder ausgelöstem
Umdrehen der Verdächtigen bleibt Spielraum.

### MECH 6.4 Prüfung im Auflösungsheft

Teil 90 druckt die Tabelle 6.1 (Feld, Kernfakt, Stichwort) mit einem Kästchen je Meilenstein. Der Erzähler legt den
Ermittlungsbogen daneben und hakt ab. Summe = Detektiv-Punkte (0 bis 9). Zweifel entscheidet die Mehrheit des Tisches,
nicht der Erzähler allein.

### MECH 7.1 Tipp-Zettel (wörtlich)

Format A6 quer, vier je A4, einmal gefaltet. Je Rolle einer, dazu einer für den Erzähler. Der Detektiv bekommt keinen; seine
Anklage ist sein Tipp (M-21).

> **Tipp-Zettel** · Name: ________________
> 1. Wer war es? Wer steckt hinter dem dumpfen Schlag im Dunkeln? ________________ (2 Punkte)
> 2. Wo ist Herrn Schneiders Schlüsselbund versteckt? ________________ (1 Punkt)
> 3. Mein Bonus-Ziel: erreicht ☐ ja ☐ nein. Woran sieht man das? ________________ (2 Punkte)
> Falten und dem Erzähler geben. Geöffnet wird erst mit dem Auflösungsheft.

Frage 1 ist regelkonform (REG §9 Nr. 3). Die Tipps fallen vor den letzten drei Untersuchungen (1.3). Wer den Eiskübel tippt,
muss es aus dem Gespräch schließen (P2-03).

### MECH 7.2 Wertung (steht nur in Teil 90)

| Frage | Punkte | Regel |
|---|---|---|
| 1 | 2 | „Olli“ |
| 2 | 1 | „Eiskübel“ (auch „unter dem Eis“) |
| 3 | 2 | Bonus-Ziel erfüllt nach der Prüfbedingung in Teil 90, Stand bei der Anklage; der Tisch bestätigt |
| Sonderregel | – | **Für Olli zählen Frage 1 und 2 nicht.** Er bekommt stattdessen 3 Punkte, wenn der Detektiv nicht ihn angeklagt hat. So hat jeder höchstens 5 Punkte (M-22) |

Der Erzähler zählt mit. „Spürnase des Abends“ ist, wer die meisten Punkte hat; Gleichstand teilt den Titel. Der Detektiv
ist nicht in dieser Wertung; für ihn zählen Ende und Punkte von 9.

### MECH 7.3 Bonus-Ziel-Schema (Vorgabe für die Rollen-Phase, E14)

Jede Rolle hat genau ein Bonus-Ziel im Heft. Form, **wörtlich als Muster**:
> „**Dein Bonus-Ziel:** [ein Satz]. **Erfüllt, wenn** [Bedingung, die bei der Anklage am Tisch sichtbar ist].“

Erlaubte Bedingungen (am Tisch prüfbar):

| Typ | Bedingung | für wen (Vorgabe) |
|---|---|---|
| Reinen Tisch | „Du hast deine Geheimniskarte am Ende einer Runde freiwillig umgedreht (reinen Tisch), bevor einer deiner drei Sobald-Fälle eingetreten ist.“ Der Detektiv schreibt in der Vermerke-Liste „freiwillig“ zum Eintrag (P14-07) | alle vier Verdächtigen, gleiche Gestalt (E9). Für Olli belohnt es, den Türschaden selbst zuzugeben (Kanon-Ziel, WELT §7.1); weil sein Stein früh fällt, ist das für ihn schwer und gleicht die Sonderwertung M-22 aus |
| Schutz | „Deine Schutzperson steht bei der Anklage auf dem Bogen als ausgeschieden (Alibi und Heimlichtuerei).“ Satz ohne Gewaltwort, etwa „bis feststand, dass er es nicht war“ (REG §9 Nr. 4) | Lejla (Ahmet), Emine (Fatma), Zeynep (Can) |
| Eigenes Anliegen | Ein Ergebnis, das am Tisch zu sehen ist: eine bestimmte Karte offen oder zu, eine Zusage vor allen | Tim, Joanna, Marek, Zusatzrollen. Tims Ziel darf nicht „Olli schützen“ sein (ABG A-231) |
| Aufdecken | „Eine Geheimniskarte wurde umgedreht, weil du ihren Auslöser vor allen genannt hast. Die Person bestätigt es.“ | höchstens bei zwei Rollen, weil die Prüfung auf Ehrlichkeit beruht |

Geprüft wird jedes Bonus-Ziel nach dem Stand bei der Anklage (R-12): Die Tipp-Runde liegt in Runde 3 vor den letzten drei
Untersuchungen (1.3). Auf dem Tipp-Zettel kreuzt die Person an, was sie erwartet; es zählt die Prüfbedingung in Teil 90.

Regeln: Jedes Ziel ist bei jeder Personenzahl erfüllbar, bei der die Rolle mitspielt (Ausweichbedingung, wenn eine genannte
Person fehlt). Ausnahme mit Absicht: Ollis Ziel ist ab 7 Personen kaum zu erreichen; das gleicht die Sonderwertung M-22 aus
(P145R2-K16). Kein Bonus-Ziel erfüllt sich ohne Zutun der Rolle schon in Runde 1 oder 2 (P145R2-M07). Kein Ziel belohnt, eine Unschuldige oder einen Unschuldigen anzuklagen. Kein Ziel braucht Wissen aus Teil 90.

**Bonus-Ziel des Erzählers, wörtlich:** „Bei der Anklage liegen mindestens drei Viertel der Geheimniskarten der
gespielten Rollen offen. Karten unter den Zeugenstreifen zählen nicht mit.“ (P145R2-K21) Grund: Der Erzähler moderiert; das belohnt, dass er Gespräche in Gang hält (M-23).

---

## 13. Anklage und Enden

### MECH 8.1 Anklage und Stufe 3

1. Der Detektiv nennt eine Person (eine der vier Verdächtigen oder jemand anderes) und drei Gründe.
2. Ist die angeklagte Person eine der vier Verdächtigen, liest sie „Stufe 3: Wenn du angeklagt wirst“ aus ihrer Fassung
   vor. Die vier Stufe-3-Texte haben gleiche Gestalt (E9, REG §9 Nr. 15). Nur RN7 enthält ein Geständnis, regelkonform:
   „Im Dunkeln hat mich die Panik gepackt.“ Kein Schlag-Verb, keine Waffe als Handlung (REG §6.1). Die drei anderen
   enthalten einen empörten Widerspruch mit der eigenen Wahrheit.
3. Ist eine andere Person angeklagt, sagt sie nur: „Ich war es nicht.“ Das steht in jedem Heft der Rollen 5–18.
4. Dann öffnet der Erzähler Teil 90.

### MECH 8.2 Die vier Enden

| Ende | Anklage | Detektiv-Punkte | Name (Kanon `fall.json:57-87`) |
|---|---|---|---|
| 1 | Olli | 7 bis 9 | Meister-Detektiv |
| 2 | Olli | 0 bis 6 | Teilerfolg |
| 3 | jemand anderes | 4 bis 9 | Justizirrtum |
| 4 | jemand anderes | 0 bis 3 | Totale Eskalation |

Texte: Kanon `texte/erzaehler-finale-olli.json` (`finale.olli.ende_*`) als Grundlage, mit zwei Anpassungen (M-24):
1. **Schlüsselbund-Satz in zwei Fassungen**, weil PP9 schon offen sein kann:
   - Enden 1 und 2, PP9 nicht offen, **wörtlich**: „Olli holt den Bund unter dem Eis im Eiskübel hervor und gibt ihn heraus.“
   - Enden 1 und 2, PP9 offen, **wörtlich**: „Der Bund aus dem Eiskübel liegt schon bei Herrn Schneider.“
   - Enden 3 und 4, PP9 nicht offen: Kanon-Satz „Der Schlüsselbund bleibt verschwunden. Um sieben Uhr schließt Herrn Schneiders Kollegin mit ihrem Torschlüssel das Außentor auf.“
   - Enden 3 und 4, PP9 offen, **wörtlich**: „Den Bund hat Herr Schneider, aber er schließt erst auf, als es hell wird.“
   - Austausch, **wörtlich als Regel** (P5-K6): In Ende 1 und 2 ersetzt der PP9-Satz den Satz „Olli holt den Bund unter dem
     Eis im Eiskübel hervor und gibt ihn heraus.“ In Ende 3 und 4 ersetzt er die Sätze „Der Schlüsselbund bleibt verschwunden.
     Um sieben Uhr schließt Herrn Schneiders Kollegin mit ihrem Torschlüssel das Außentor auf.“
2. Jedes Ende enthält „Herr Schneider überlebt“ (REG §6.1), „Beule und eine Gedächtnislücke“, kein Blut, keine Wunde.

### MECH 8.3 Rückblende (Gliederung mit Kernsätzen)

Eine Rückblende für alle vier Enden. Vorlesetext: Uhrzeiten in Worten, keine Ziffern. Darunter eine Zeitleiste zum
Nachlesen mit Ziffern und Sekunden (nur in Teil 90, WELT §0.2). Länge der Rückblende: 400 bis 500 Wörter.

| Abschnitt | Inhalt (WELT §3) | Kernsatz (wörtlich, Vorlesen) |
|---|---|---|
| 1 Der Abend | 18:30 Tragen, 18:35 Beschlag, 18:45 Möbelwachs von Tim, 18:50 Forderung, Tore zu; 23:00 Streit | „Um halb sieben tragen Olli und Tim die Warmhaltebehälter durch den Turmgang. Fünf Minuten später schrammt Olli die Bogentür, und ein Beschlag reißt aus der gekalkten Wand.“ |
| 2 Vier Heimlichtuereien | Ahmets Miete und Nachzahlung; Fatmas Schatulle um zwanzig vor zwölf; Cans Maske ab sechs vor zwölf, Zeynep im Bogen; Olli will mit Herrn Schneider reden | „Vier aus der Clique haben heute etwas zu verbergen. Nur einer davon hat mit dem Scheppern zu tun.“ |
| 3 Zwei vor zwölf | Tims Steckdose, Knall; Ahmet an Mareks Beinen, Fatma neben Emine, Lejla allein | „Zwei vor zwölf steckt Tim die Kaffeemaschine in seine alte Steckdose. Es knallt, und überall ist es dunkel.“ |
| 4 Das Gespenst | Can springt heraus, „Hab ich dich!“, reißt sich los, rennt an Olli, Tim und Zeynep vorbei in den Kaminsaal; Herr Schneider brüllt zweimal; Marek sieht es im Kerzenlicht | „Can ist schon im Kaminsaal, als Herr Schneider ihm noch hinterherbrüllt. Erst danach scheppert es.“ |
| 5 Das Scheppern | Olli geht über die Klappe zur Vorratsraumtür: „Lass uns reden, nur kurz.“ Herr Schneider packt ihn am Ärmel: „Zweitausend. Sonst Polizei.“ Panik; Kerzenständer am Fuß; Holzsplitter und Kalk im Wachs; rote Tropfen auf den Handschuh | „Dann, in Panik: ein dumpfer Schlag, Poltern, Metall scheppert über den Steinboden. Die Kerzen gehen aus.“ |
| 6 Der Bund | Olli reißt den Bund ab, um hinauszukommen, merkt sofort, dass Flucht alles schlimmer macht; tastet sich zum Eiskübel; schiebt ihn unter das Eis; kriecht zu Lejla | „Olli schiebt den Bund unter die Eiswürfel. Dann kriecht er zum rechten Buffettisch und flüstert: ‚Lejla? Ich bin's, Olli.‘“ |
| 7 Licht | Tim schaltet ein; Marek findet Herrn Schneider; Olli nimmt obenauf Eis für Tim | „Um Mitternacht geht das Licht an. Olli holt Tim eine Handvoll Eis, nur von oben.“ |
| 8 Nach Mitternacht | zwölf nach zwölf Ahmets Umschlag im Ascheneimer; Herr Schneider überlebt | „Herr Schneider überlebt. Er hat eine dicke Beule und eine Gedächtnislücke, und er ist bald wieder grantig.“ |

Zeitleiste zum Nachlesen: die Sekunden aus WELT §3.4 von 23:57:00 bis 0:01:00, gekürzt auf die Zeilen, die in den
Abschnitten 3 bis 7 vorkommen.

Namen in Teil 90 (P14-16, WELT §1.1): Zeugen 5–10 stehen mit Namen, weil sie heute entweder gespielt wurden oder auf dem
Abwesenheitsblatt lagen. Zusatzrollen 11–18 stehen nur mit Namen, wenn sie gespielt wurden; sonst heißt es „ein Gast“ (etwa
Damir in der Zeitleiste um 23:57:30). Die Kernsätze oben nennen keine Zusatzrolle.

### MECH 8.4 Gliederung von Teil 90 und Reihenfolge der Auflösung

| Seite | Inhalt | Wer liest |
|---|---|---|
| 1 | Deckblatt „Versiegelt – erst nach der Anklage öffnen“, Fall-Code U4YRK | – |
| 2 | „Was wirklich war“, Kernsatz **wörtlich** (P5-K6): „Es war Olli. Um drei vor zwölf stand er am Eiskübel. Als das leuchtende Gesicht schon weg war, ging er über die Theken-Klappe zur Vorratsraumtür. Im Dunkeln hat ihn die Panik gepackt. Den Schlüsselbund hat er unter die Eiswürfel im Eiskübel geschoben. Der Schlüsselbeweis: Holzsplitter und weißer Kalk im Wachs am Fuß des Kerzenständers, dieselben Spuren an Ollis Ärmeln, dazu frische rote Kerzenwachstropfen auf seinem rechten Handschuh.“ Dann Meilensteine prüfen (Tabelle 6.1 mit Kästchen) | Erzähler laut, dann mit dem Detektiv |
| 3 | Endentabelle (8.2) und Enden 1 und 2 | Erzähler liest das passende Ende |
| 4 | Enden 3 und 4 | dto. |
| 5–6 | Rückblende (Vorlesen) und Zeitleiste (Nachlesen) | Erzähler |
| 7–8 | „Die Rollen am Tisch“: je gespielter Rolle zwei bis drei Sätze, was sie verbarg und welchen Domino-Stein sie trug (Wortlaut RK 2.12 bis 5.12, ZG 1.12, 2.12, 3.12, 4.13, 5.12, 6.12, ZR 1.13 bis 8.13) | Erzähler; ab 14 Personen liest jede Person ihren Absatz selbst |
| 9 (ab 15 Personen 9 und 10) | Tipp-Wertung: Antworten, Sonderregel Olli, Bonus-Ziele aller gespielten Rollen und des Erzählers mit Prüfbedingung, Spürnase | Erzähler |
| 10 (ab 15 Personen 11) | Zum Nachlesen: Pflicht-Auslöser der heute gespielten Rollen und der Streifen neben dem Lageplan; Liste der Indizkarten (Code, Titel, Runde) | wer will |

---

## 14. Erzählerheft (Teil 00)

### MECH 9 Erzählerheft (Teil 00)

Der Erzähler kennt den Täter nicht (A:26, E10). Das Heft enthält keine Lösung, keine Stufe-2-Inhalte, keine Antworten der
Rollen und keine Codes-Zuordnung von Fassungen zu Personen. Alle Texte zum Vorlesen sind Vorlesetexte nach REG §6.5:
keine Ziffern, keine Abkürzungen, Uhrzeiten und Beträge in Worten, Sätze höchstens 25 Wörter, im Mittel höchstens 14.

### MECH 9.1 Gliederung

| Seite | Abschnitt |
|---|---|
| 1 | Deckblatt „Erzählerheft – du kennst die Lösung nicht. Das ist Absicht.“ |
| 2 | Vorbereitung: Teileliste mit Personenzahl, was ausschneiden und falten (10.5), was an wen geht. **Wörtlich** (P5-M6): „Am besten schneidet und faltet jemand, der heute nicht mitspielt. Machst du es selbst: Schneide an den Linien, lies nichts, und falte jede Karte sofort zu. Leg sie mit dem Code nach oben ab.“ |
| 3 | Ablauf mit Minuten (1.1), Tischregeln (1.4), Rundenaufbau (1.3) |
| 4 | „So läuft der Abend“ (9.2), Vorgeschichte (9.3) |
| 5–6 | Vorstellungsrunde (9.4) |
| 7 | Tat-Moment und Auftrag (9.5), Fassungen öffnen (9.6), „Was alle wissen“ (1.5, P145R2-M09) |
| 8 | Lageplan-Führung (9.7) |
| 9–10 | Runde 1: Start, Impulse, Rundenende |
| 11–12 | Runde 2 |
| 13–14 | Runde 3, dein Bonus-Ziel, Tipp-Runde, Anklage, Auflösung (9.12) |
| 15 | „Herr Schneider antwortet“ (9.10), Maßtabelle und Licht (9.11), Zuordnung bei der Taschenkontrolle, **wörtlich**: „Taschenkontrolle: Ollis Weste → FN3, Cans Bauchtasche → JT3, Fatmas Tasche → NN3. Bei allen anderen liest die Person ‚Was du bei dir trägst‘ vor.“ |
| 16 | Skalierung: nur die Zeile der heutigen Personenzahl ausführlich, dazu die Kurztabelle (9.13); bei 6 bis 11 Personen die Tabelle „Karten unter den Streifen“ (9.14) |

### MECH 9.2 So läuft der Abend (wörtlich, Vorlesen)

> „Willkommen im Schlosskeller. Heute spielt ihr einen Krimi, und ihr spielt ihn selbst. Jede Rolle hat ein Heft, eine verdeckte Geheimniskarte und eine offene Aktionskarte. Erst stelle ich euch die Geschichte vor, dann stellt ihr euch selbst vor. Dann geschieht es. Danach gibt es drei Runden. In jeder Runde redet ihr miteinander, fragt nach und bohrt nach. Wer in die Enge kommt, muss mit der Wahrheit herausrücken. Am Ende jeder Runde macht der Detektiv drei Untersuchungen. Auf dem Lageplan zeigt jeder, wo er war. Wer lügt, muss seinen Marker irgendwann umstellen. In der letzten Runde tippt ihr alle, auch ich, bevor der Detektiv ein letztes Mal untersucht. Dann klagt er an. Übrigens: Ich weiß selbst nicht, wer es war.“

### MECH 9.3 Vorgeschichte (wörtlich, Vorlesen, höchstens eine Druckseite)

Aus Kanon `texte/erzaehler-vorgeschichte.json` gekürzt. Gesperrt sind wie im Kanon: Geld, Miete, Gefallen, Streich,
Münzen, Schatulle, Türschaden, Steckdose (REG §9 Nr. 27). Etwa 330 Wörter.

> „Lehnt euch zurück. Wo die Stadt aufhört und die Wälder anfangen, steht an einer stillen Landstraße ein altes Schloss. Seine Gewölbe sind noch älter als das Schloss, denn man hat es auf die Keller einer kleinen Burg gesetzt. Die Mauern sind dicker, als ein Arm lang ist. Heute gehört alles einer Stiftung. Im Dorf erzählt man sich: Bei Westwind singt das Schloss.
>
> Seit fünfundzwanzig Jahren kümmert sich Herr Schneider um Schloss, Park und Garten. Offiziell ist er Schlossverwalter, aber fast alle nennen ihn einfach den Hausmeister. Er brummt über Lärm, Krümel und Matsch an den Schuhen. Danke sagt er selten. Feste mag er trotzdem, auch wenn er das nie zugeben würde.
>
> Die Clique ist über viele Jahre gewachsen. Ein paar kommen aus derselben Straße, andere aus der Schule, von der Uni, aus der Berufsschule oder von Spieleabenden. Jeder brachte jemanden mit, und keiner ging wieder. Früher traf sich die ganze Clique jeden November zu einem großen Herbstabend. Dann kamen Studium, Arbeit und Umzüge dazwischen. Diesen Sommer stand fest: Der Herbstabend kommt zurück.
>
> Ahmet hat den Keller organisiert. Tief unter dem Turm liegt ein weiter Gewölbekeller, mehrere Gewölbe hintereinander, durch niedrige Gänge verbunden. Es gibt lange Tafeln, Wandbänke und Platz für ein Buffet. Der Wind summt in den Lichtschächten, und schwere Türen quietschen, als wollten sie mitreden. Handyempfang gibt es hier unten nicht.
>
> Heute ist Samstag. Draußen wird es früh Nacht und bitterkalt, und der Wind kommt von Westen. Der Ablaufplan steht, und fürs Buffet ist alles geplant. Um Mitternacht gibt es Torte und dazu ein Spiel: blinde Kuh. Jetzt fahren die Autos aus der Stadt hinaus. Am Ende der Landstraße wartet das alte Schloss. Hört ihr es schon singen?“

### MECH 9.4 Vorstellungsrunde

Ablauf, **wörtlich** als Anleitung für den Erzähler:
> „Lies den Starttext. Dann rufst du die Rollen der Reihe nach auf, von Platz eins an. Lies zu jeder Rolle nur die Frage. Die Person antwortet mit ‚Dein Auftritt‘ aus ihrem Heft. Wer nicht gespielt wird, wird übersprungen. Zum Schluss fragst du den Detektiv.“

- Starttext, **wörtlich** (aus Kanon `vorstellung.start`, angepasst): „Das alte Schloss hat schon viele Gäste gesehen, aber noch nie euch alle auf einmal. Zeit, dass es euch kennenlernt. Ich stelle jedem eine Frage. Wer gefragt wird, steht kurz auf und antwortet selbst.“
- Je Rolle: Name, Rollenbezeichnung, Frage (1–2 Sätze, humorvoll, spoilerfrei). Die Fragen stehen wörtlich in RK 2.3 bis 5.3, ZG 1.3 bis 6.3 und ZR 1.3 bis 8.3, die
  Frage an den Detektiv in RK 6.3 (P145R2-K17). Die Antwort steht nur im Rollenheft. Vorgabe aus A:72: Olli wird nach dem Lacher von
  Viertel nach acht gefragt (Beispiel A:72 sinngemäß, ohne Ziffern). Die Rüstung (Sibel) und der Kamin (Hana) stehen in
  ihrem Auftritt, wenn sie gespielt werden (ABG D-28).
- Frage an den Detektiv: RK 6.3.
- Danach, nur wenn die Rolle fehlt, **wörtlich** (Kanon `intro.lacher.*.npc`):
  - Sibel fehlt: „Um neun Uhr abends hielt ein Gast die alte Ritterrüstung im Turmgang für einen Menschen. Der Gast schrie auf und stolperte rückwärts.“
  - Hana fehlt: „Ein Gast feuerte den Kamin an, ohne die Kaminklappe zu öffnen. Um halb zwölf abends füllte dichter Qualm den Kaminsaal. Alle husteten, die Klappen der Lichtschächte wurden aufgerissen, und das Feuer wurde gelöscht.“
- Abschluss, **wörtlich** (Kanon `vorstellung.npc`, gekürzt): „Wer heute ohne Spielerin oder Spieler dabei ist, isst trotzdem mit und lacht mit. Das Schloss zählt jeden Gast mit.“

### MECH 9.5 Tat-Moment und Auftrag (wörtlich, Vorlesen)

Nur, was alle wahrnehmen konnten oder sofort erfuhren (WELT §5.1, §2.6). Ohne Namen der Zeugen 5–10 (WELT §1.1).

> „Es ist kurz vor Mitternacht. Im Ost-Saal sitzt du mit verbundenen Augen auf dem Ehrenplatz der blinden Kuh. In deinen Kopfhörern läuft laute Musik. Gleich gibt es Torte.
>
> Zwei vor zwölf: ein lauter Knall. Überall geht das Licht aus. Nur die drei roten Kerzen an der Anrichte hinter der Theke flackern noch. Über der Innentür leuchtet grün das Notausgangsschild.
>
> Im Buffetsaal duckt sich, wer kann. Herr Schneider brüllt: ‚Hab ich dich!‘ Dann: ‚Stehen bleiben!‘ Und noch einmal: ‚Stehen bleiben, hab ich gesagt!‘
>
> Kurz darauf scheppert es laut an der Theke. Ein dumpfer Schlag, Poltern, Metall scheppert über den Steinboden. Die Kerzen sind aus. Jetzt ist es fast ganz dunkel.
>
> Um Mitternacht geht das Licht wieder an. Alle blinzeln. Vor der Tür zum Vorratsraum liegt der Messingkerzenständer am Boden. Herr Schneider ist weg.
>
> Jemand reißt die Tür zum Vorratsraum auf und ruft: ‚Hier liegt Herr Schneider!‘ Er liegt gleich hinter der Tür, bewusstlos, mit einer dicken Beule.
>
> Kurz danach kommt er zu sich. ‚Mein Kopf.‘ Dann: ‚Mein Schlüsselbund! Der ist weg!‘ Dann kommt jemand vom Windfang herein: ‚Das Tor ist zu. Abgeschlossen.‘ Den Schlüssel fürs Außentor gibt es nur zweimal: an Herrn Schneiders Bund und bei seiner Kollegin. Hinter den dicken Mauern hat kein Handy Empfang. Ihr sitzt bis zum Morgen fest.
>
> Herr Schneider sitzt mit einem Kühlpack im Buffetsaal und brummt: ‚Ich wollte die Notlaterne holen. Da springt mich so ein leuchtendes Gespenstergesicht an. Ich hab eine Kapuze erwischt. Dann weiß ich nichts mehr.‘“

Auftrag, **wörtlich** (Kanon `intro.auftrag.m` und `.w`):
> m: „Eben warst du noch die blinde Kuh, und jetzt bist du auch noch der Detektiv. Herr Schneider bittet dich: ‚Finde raus, wer das war. Bis zum Morgen.‘“
> w: „Eben warst du noch die blinde Kuh, und jetzt bist du auch noch die Detektivin. Herr Schneider bittet dich: ‚Finde raus, wer das war. Bis zum Morgen.‘“

Prüfung: Kein Schlag-Verb (nur das Nomen „Schlag“), keine Ziffern, kein Blut, „bewusstlos, mit einer dicken Beule“ (E4),
„kurz darauf“ statt Sekunden (WELT §3.1), alle Rufe sehr laut und im Ost-Saal hörbar (WELT §5.1), Herr Schneiders
Erinnerung nach WELT §1.4.

### MECH 9.6 Fassungen öffnen (wörtlich, Anleitung)

> „Gib Ahmet, Fatma, Olli und Can je die versiegelte Fassung mit dem Code, der in ihrem Heft steht. Lies vor: ‚Ahmet, Fatma, Olli und Can: Öffnet jetzt eure versiegelte Fassung und lest sie still. Zeigt sie niemandem.‘ Gib ihnen drei Minuten. Alle anderen lesen in der Zeit ‚Was alle wissen‘ in ihrem Heft. Du liest es auf Seite 7.“

### MECH 9.7 Lageplan-Führung

Schritte (Anleitung):
1. Blatt A (Lageplan) und Blatt B (Markerfelder) nebeneinander in die Tischmitte legen (10.2).
2. Vorlesen, **wörtlich**: „Das hier ist der Gewölbekeller unter dem Schlossturm. Ganz im Osten der Ost-Saal mit der langen Tafel. Daneben der Buffetsaal mit den zwei Buffettischen und der Theke. Hinter der Theke die Anrichte und die Tür zum Vorratsraum. Westlich führt ein kurzer Durchgang mit einem Steinbogen in den Kaminsaal. Hinter der Bogentür liegt der Turmgang mit der Ritterrüstung und der Treppe zur Turm-Toilette. Im Süden der Windfang mit dem Außentor.“
3. Herrn Schneiders Marker setzen: „23:57“ auf 4d (Ostende), „Scheppern“ auf 4c (vor der Vorratsraumtür).
4. Der Detektiv setzt beide Marker auf 1 (Ost-Saal).
5. Vorlesen, **wörtlich**: „Jetzt setzt jede Rolle ihre zwei Marker. Der Marker ‚drei vor zwölf‘ kommt dahin, wo ihr da wart. Der Marker ‚Scheppern‘ dahin, wo ihr beim lauten Scheppern wart. So steht es in eurem Heft unter ‚Deine Marker‘. Wer später bei einer Lüge über seinen Ort ertappt wird, stellt seinen Marker vor allen um.“
6. Bei 6 bis 11 Personen: Zeugenstreifen und darunter die Geheimniskarten der fehlenden Zeugen neben die Markerfelder ihrer
   Zone legen, Etikett nach oben. Vorlesen, **wörtlich**: „Diese Streifen sind die Aussagen von Gästen, die heute niemand spielt. Sie bleiben verdeckt. Nur ein Ortstermin oder die Aktionskarte Zeitstempel deckt sie auf. Wann sie aufgedeckt werden, steht auf ihrem Etikett.“
7. Indizkarten-Stapel, nach Code sortiert, bleibt beim Erzähler.

### MECH 9.8 Rundenstart und Rundenschluss (wörtlich, Vorlesen)

Grundlage Kanon `runde.*.start`, ergänzt um die Freigabe der Karten. In Runde 1 fehlt der Kanon-Satz über die Theke, weil
Olli und Can in Stufe 1 andere Orte nennen; der Erzähler soll nicht deuten (WELT K-25, P145R2-M10).

- Runde 1, Start: „Es ist halb eins. Im Keller wird es still, und das Licht flackert. Die erste Runde heißt: Das Alibi-Geflecht. Wer war wo, als es knallte, und wo, als es schepperte? Ab jetzt sind die Karten der ersten Runde frei. Hört jetzt genau zu.“
- Runde 1, Schluss: „Die erste Runde ist vorbei. Auf dem Lageplan hat sich schon etwas bewegt. Schaut genau hin, wer wo steht.“
- Runde 2, Start: „Es ist Viertel nach eins. Im Gewölbe knarrt es leise. Die zweite Runde heißt: Die Indizien-Filterung. Manche hier verbergen etwas, das mit dem Knall gar nichts zu tun hat. Trennt das eine vom anderen. Ab jetzt sind auch die Karten der zweiten Runde frei.“
- Runde 2, Schluss: „Die zweite Runde ist vorbei. Macht eine Pause. Holt euch Tee oder Saft. Danach kommt die letzte Runde.“
- Runde 3, Start: „Es ist zwei Uhr. Die letzte Runde heißt: Die finale Gegenüberstellung. Jetzt zählt nur noch, wer an der Vorratsraumtür war und wo der Schlüsselbund steckt. Ab jetzt sind auch die Karten der dritten Runde frei. Im Keller ist es ganz still. Jetzt wird es ernst.“
- Runde 3, Schluss: entfällt. Nach Abschnitt c folgt die Tipp-Runde (9.12), dann die letzten drei Untersuchungen, dann die
  Anklage.

### MECH 9.9 Moderationsimpulse (wörtlich, spoilerfrei, für jede Besetzung)

Regeln für den Erzähler, **wörtlich**:
> „Lies einen Impuls, wenn das Gespräch länger als eine halbe Minute stockt oder nach der Hälfte der Gesprächszeit. Lies nie mehr als einen Impuls auf einmal. Wenn ein Impuls eine Person nennt, die heute niemand spielt, lies den Ausweichsatz.“

Ausweichsatz, **wörtlich**:
> „Diese Person ist heute nicht am Tisch. Was sie weiß, liegt vielleicht als Zeugenstreifen neben dem Lageplan. Detektiv, eine Untersuchung an ihrem Ort kann es aufdecken.“

Grundsatz: Kein Impuls nennt nur einen Verdächtigen. Jeder Impuls fragt alle vier oder alle am Tisch, oder er knüpft an
etwas an, das schon offen liegt (REG §9 Nr. 14, E10). Das Beispiel aus A:30 (Fatma, Emine, Zeynep) wird deshalb durch
gleich gebaute Impulse ersetzt, die alle vier treffen (M-25).

**Jederzeit: Domino-Frage**
- Wann: Gleich nachdem eine Geheimniskarte umgedreht wurde.
- Nennt die Karte am Ende eine Person am Tisch, Vorlesen: „Die Karte nennt am Ende jemanden. Bitte, sag uns sofort, ob das stimmt. Wenn dein Heft es dir noch nicht erlaubt, sag: ‚Dazu sag ich jetzt nichts.‘“ (P2-20, R-14)
- Nennt sie einen Ort, niemanden oder nur Herrn Schneider, fragt der Detektiv in die Runde: „Wer weiß dazu etwas?“ Der
  Erzähler antwortet nie für Herrn Schneider (R-10, P2-12).
- Wenn die genannte Person fehlt: Ausweichsatz.

**Runde 2 und 3, ab 14 Personen: Gegenüberstellung** (nach der Hälfte von Abschnitt b, 1.3, P14-04)
> „Gegenüberstellung! Ahmet, Fatma, Olli und Can, setzt euch nebeneinander an den Kopf des Tisches. Wer in dieser Runde eine
> Frage an einen der vier hat, stellt hier genau eine. Reihum, Frage und Antwort zusammen höchstens zwanzig Sekunden. In fünf
> Minuten rufe ich: Wechsel!“

Ab 18 Personen lautet der letzte Satz **wörtlich**: „In sieben Minuten rufe ich: Wechsel!“ (P145R2-M02)

**Runde 1 – Das Alibi-Geflecht**

I-1.1 Wer hat dich gesehen?
> „Kurz vor zwölf war noch Licht. Ahmet, Fatma, Olli und Can: Nennt jetzt nacheinander einen Namen. Wer hat dich um drei vor zwölf gesehen? Die genannte Person sagt, ob das stimmt.“
- Wenn die genannte Person fehlt: Ausweichsatz.

I-1.2 Wer war neben dir?
> „Beim Knall hat sich fast jeder irgendwo hingekauert. Sagt reihum: Wer war im Dunkeln neben dir, und woran hast du die Person erkannt? Wer allein war, sagt das auch.“
- Wenn jemand eine fehlende Person nennt: Ausweichsatz.

I-1.3 Dem Ruf nicht gefolgt
> „Um fünf vor zwölf sollten alle in den Ost-Saal, zur blinden Kuh, zur Torte und zum Gruppenfoto. Wer ist dem Ruf nicht gefolgt? Und warum nicht?“

I-1.4 Der Lageplan
> „Schaut auf den Lageplan. Steht ein Marker irgendwo, wo diese Person noch niemand gesehen hat? Fragt nach. Die Person muss sagen, wer sie dort gesehen haben könnte.“

**Runde 2 – Die Indizien-Filterung**

I-2.1 Geld
> „Heute Nacht ging viel Bargeld durch viele Hände. Wer hat heute Abend Geld bezahlt, wer hat Geld eingesammelt, und wer schuldet noch jemandem etwas? Jede Person sagt einen Satz dazu.“

I-2.2 Turmgang und Bogentür
> „Im Turmgang und an der Bogentür ist heute einiges passiert. Wer war heute Abend dort, wann, und warum?“

I-2.3 Das Gesicht
> „Herr Schneider hat im Dunkeln ein leuchtendes Gesicht gepackt. Wer hat dieses Gesicht heute Nacht gesehen, und wo standest du da? Wer noch nicht mehr sagen mag, sagt wenigstens, wo er stand.“

I-2.4 Selbst damit herausrücken
> „Wer bisher nur die halbe Wahrheit gesagt hat, kann jetzt noch selbst damit herausrücken. Wer es von sich aus tut, steht besser da, als wenn eine Karte es zeigt.“

**Runde 3 – Die finale Gegenüberstellung**

I-3.1 Was kam zuerst?
> „Im Dunkeln zählt nur, was zuerst kam. Wer zwischen Knall und Scheppern etwas gesehen, gehört oder gespürt hat, erzählt es jetzt der Reihe nach. Was kam zuerst, was danach?“

I-3.2 Der Weg zur Vorratsraumtür
> „Herr Schneider stand beim Scheppern vor der Vorratsraumtür. Detektiv, geh mit allen die Marker auf dem Lageplan ab. Wer hätte im Dunkeln dorthin kommen können, und auf welchem Weg?“

I-3.3 Nach dem Licht
> „Als das Licht anging, kam einiges in Bewegung. Wer hat seit Mitternacht etwas geholt, weggebracht oder weggeworfen? Jede Person sagt einen Satz.“

I-3.4 Letzte Gelegenheit
> „Gleich kommt die Tipp-Runde. Wer seine Geheimniskarte noch nicht umgedreht hat, hat jetzt die letzte Gelegenheit, reinen Tisch zu machen.“

Tragfähigkeit je Besetzung: I-1.1, I-1.2, I-1.3, I-1.4, alle Impulse in Runde 2 und 3 fragen alle oder die vier
Verdächtigen und gehen daher schon bei 6 Personen. Nennt eine Antwort eine fehlende Person, greift der Ausweichsatz und
lenkt auf einen Ortstermin. Spoilerprüfung: Kein Impuls nennt Eiskübel, Kerzenständer-Fuß, Handschuh, Maske, Schatulle oder
Ollis Namen als Ziel. I-3.3 trifft Olli (Eis), Ahmet (Umschlag), Marek (Tür), Lejla (Kühlpack) und die Person mit den
Handys gleichermaßen.

### MECH 9.10 „Herr Schneider antwortet“ (wörtlich, für JA9, PM3 und die Aktionskarte „Krankenbesuch“)

Herr Schneider weiß nur, was in WELT §1.4 steht. Über Geld und Ärger der Gäste schweigt er (W-18).

| Frage nach | Antwort (Vorlesen) |
|---|---|
| seinem Platz kurz vor zwölf | „Um drei vor zwölf stand ich am Ostende der Theke. Dann bin ich hinter der Theke zur Kaffeemaschine.“ |
| der Kaffeemaschine, der Leiste | „Ich hab noch gesagt: Nicht die alte Leiste! Dann hat es geknallt.“ |
| dem Knall, der Notlaterne | „Nach dem Knall wollte ich die Notlaterne holen. Die hängt gleich hinter der Tür vom Vorratsraum.“ |
| dem Gespenst, der Kapuze | „So ein leuchtendes Gesicht ist mich angesprungen. Ich hab eine Kapuze erwischt. Hab ich dich, hab ich gerufen. Dann ist alles weg.“ |
| dem, was danach war | „Danach weiß ich nichts mehr. Aufgewacht bin ich mit einer dicken Beule.“ |
| dem Schlüsselbund | „Der hing an meiner rechten Gürtelschlaufe. Außentor, Hoftür, Turm. Den Schlüssel fürs Außentor gibt es nur zweimal: an meinem Bund und bei meiner Kollegin.“ |
| Geld, Miete, Schaden, Vitrine, Streit, einer bestimmten Person | „Das kläre ich mit den Leuten selbst.“ |
| wer es war | „Wenn ich das wüsste, säßest du nicht hier. Finde es raus.“ |
| allem anderen | „Mein Kopf brummt. Frag die anderen.“ |

Prüfung: Kein Satz verrät einen Täter. „Nicht die alte Leiste“ war laut und im ganzen Buffetsaal hörbar (WELT §5.6).

### MECH 9.11 Maßtabelle (für „Maßband“) und Licht (auch in Teil 01)

**Teil A – Maßtabelle (wörtlich, Vorlesen; Abstände in Worten).** Werte aus WELT §2.8, gerundet.

| von | nach | Abstand (Vorlesen) | im Dunkeln nach dem Knall |
|---|---|---|---|
| Ostende hinter der Theke (Saftkrüge) | Vorratsraumtür | „gut drei Meter“ | „Im Kerzenlicht sieht man dort nur Umrisse und leuchtende Farbe.“ |
| Ostende hinter der Theke | Eiskübel | „zwei Meter“ | „Dunkel. Man sieht nichts.“ |
| Eiskübel | Vorratsraumtür | „gut vier Meter“ | „Bis zum Knall hell. Danach sieht man vom Eiskübel an der Tür im Kerzenlicht nur Umrisse und leuchtende Farbe.“ |
| Eiskübel | rechter Buffettisch | „gut drei Meter“ | „Dunkel.“ |
| Eiskübel | vor der Theke am Westende | „fünf Meter“ | „Dunkel.“ |
| Theken-Klappe | Vorratsraumtür | „gut vier Meter, hinter der Theke entlang“ | „Die Tür ist hell, die Klappe fast dunkel.“ |
| Theken-Klappe | hinter dem linken Buffettisch | „vier Meter“ | „Dunkel.“ |
| Theken-Klappe | Sicherungskasten | „gut zwei Meter, durch die offene Tür“ | „Dunkel.“ |
| Sicherungskasten | Steinbogen | „gut zwei Meter“ | „Dunkel. Leuchtende Farbe sieht man.“ |
| Vorratsraumtür | Steinbogen | „gut acht Meter“ | „Dunkel.“ |
| Steinbogen | Bogentür | „fünf Meter, quer durch den Kaminsaal“ | „Dunkel.“ |
| Tür zum Ost-Saal | Eiskübel | „gut zwei Meter“ | „Dunkel.“ |
| Tür zum Ost-Saal | Kopf der Tafel | „gut drei Meter“ | „Dunkel.“ |

**Teil B – Licht im Keller nach dem Knall (wörtlich, Lesetext in Teil 01 und im Erzählerheft):**
> „Nach dem Knall leuchten nur noch die drei roten Kerzen an der Anrichte und das grüne Notausgangsschild. Die Kerzen beleuchten etwa zwei Meter rund um die Anrichte. Die Vorratsraumtür liegt im Licht, die Theken-Klappe kaum, der Eiskübel und die Buffettische nicht. Ein Gesicht erkennt man im Kerzenlicht nur aus der Nähe. Leuchtende Farbe sieht man im Dunkeln von weitem. Beim Scheppern gehen die Kerzen aus. Bis Mitternacht ist es im Buffetsaal dann dunkel. Kurz bevor das Licht wieder angeht, gehen im Ost-Saal Handylampen an und im Durchgang eine Stirnlampe. Sie reichen nicht bis zum Eiskübel und nicht bis zur Vorratsraumtür.“

Prüfung gegen WELT §2.6, §2.7 und W-23 (Lichtregel): stimmt. Joannas Handylampe (23:59:30) und Tims Stirnlampe
(23:59:40) gehen erst nach Ollis Rückkehr zu Lejla an; die Stirnlampe erreicht weder die Klappe (Wand neben der Tür) noch den
Eiskübel (8,2 m) noch die Vorratsraumtür (P3R2-10).

### MECH 9.12 Tipp-Runde, Anklage, Auflösung (wörtlich, Vorlesen und Anleitung)

- Dein eigenes Bonus-Ziel, **wörtlich** im Erzählerheft vor der Tipp-Runde (P5-M3): „Dein eigenes Bonus-Ziel: Bei der
  Anklage liegen mindestens drei Viertel der Geheimniskarten der gespielten Rollen offen. Zähl vor der Tipp-Runde nach,
  und noch einmal bei der Anklage. Karten unter den Zeugenstreifen zählen nicht mit.“ (P145R2-K21)
- Tipp-Runde, Vorlesen: „Bevor der Detektiv seine letzten Untersuchungen macht und anklagt, tippt die ganze Clique. Jede Person bekommt einen Tipp-Zettel, ich auch. Schreibt geheim auf, wer es war, wo der Schlüsselbund steckt und ob ihr euer Bonus-Ziel erreicht habt. Faltet den Zettel und gebt ihn mir.“
- Anleitung: Zettel einsammeln, ungeöffnet in die Mitte legen. Dann folgen die drei Untersuchungen der Runde 3 und die
  Marker-Probe (1.3 d, e). Danach klagt der Detektiv an und legt den Stift weg (R-12).
- Anklage, Vorlesen (Kanon `anklage.start`): „Die Nacht ist fast vorbei. Du stehst vor den vier Verdächtigen und musst dich entscheiden. Klag eine Person an und sag laut, warum. Dann zeigt sich, ob du richtig lagst.“
- Anleitung: Die angeklagte Person liest ihre Stufe 3 (8.1). Dann Teil 90 öffnen und seiner Reihenfolge folgen (8.4).

### MECH 9.13 Skalierungsanleitung

Der Generator druckt im Erzählerheft die Zeile der heutigen Personenzahl ausführlich und die Tabelle als Überblick.

| Personen | Rollen | neu besetzt | Abwesenheitsblatt | Aktionskarten beim Detektiv | Zusatzhefte | Hinweis für den Erzähler |
|---|---|---|---|---|---|---|
| 6 | 4 | Ahmet, Fatma, Olli, Can | 6 Streifen + 6 Geheimniskarten | 6 | – | Alle reden mit allen. Ermuntere den Detektiv, Ortstermine früh zu nutzen. Abschnitt b darfst du nach zwölf Minuten beenden, wenn alle Ziele gefragt sind (1.3) |
| 7 | 5 | + Lejla | 5 | 5 | – | wie 6 |
| 8 | 6 | + Emine | 4 | 4 | – | wie 6 |
| 9 | 7 | + Tim | 3 | 3 | – | – |
| 10 | 8 | + Joanna | 2 (Marek, Zeynep) | 2 | – | Standardrunde |
| 11 | 9 | + Marek | 1 (Zeynep) | 1 | – | – |
| 12 | 10 | + Zeynep | – | – | – | alle Hauptrollen. Ab hier laufen beim Verhörstuhl die anderen Gespräche leise weiter (R-02). Soll eine Antwort dort für alle gelten, rufst du vorher „Alle mal herhören!“ (R-13) |
| 13 | 11 | + Sibel (allein, Solo-Abschnitt) | – | – | 1 | – |
| 14 | 12 | + Damir | – | – | 2 | Ab hier zerfällt das Gespräch in Grüppchen. Runde 1: Rufe nach der Hälfte von Abschnitt b „Wechsel!“; jede Rolle geht zu ihrem zweiten Nachbohr-Ziel. Runde 2 und 3: Rufe nach der Hälfte die Gegenüberstellung aus (1.3; fünf Minuten, ab 18 Personen sieben), danach „Wechsel!“. Ab hier liest jede Person ihren Absatz „Die Rollen am Tisch“ selbst |
| 15 | 13 | + Hana (allein) | – | – | 3 | wie 14 |
| 16 | 14 | + Serkan | – | – | 4 | wie 14 |
| 17 | 15 | + Azra (allein) | – | – | 5 | wie 14 |
| 18 | 16 | + Wojtek | – | – | 6 | wie 14 |
| 19 | 17 | + Aylin (allein) | – | – | 7 | wie 14 |
| 20 | 18 | + Tugba | – | – | 8 | wie 14 |

Erzähler und Detektiv sind immer zwei verschiedene Personen (E6). Die Variante „Erzähler ist zugleich Detektiv“ (A:58)
gibt es nicht (ABG D-21).

### MECH 9.14 Karten unter den Streifen (Erzählerheft Seite 16, nur bei 6 bis 11 Personen; P14-05)

Gedruckt werden nur die Zeilen der heute fehlenden Zeugen. Die Tabelle nennt nur Codes und Runden, keinen Inhalt (E10). Der
Erzähler schaut nach jeder Indizkarte still hinein (R-08). Anleitung, **wörtlich**: „Liegt ein Code aus dieser Tabelle offen,
egal wodurch, ziehst du die Karte unter dem Streifen hervor und legst sie offen daneben. Ist ihre Runde noch nicht erreicht,
tust du es gleich zu Beginn dieser Runde. Der Streifen bleibt zu, bis sein eigener Code kommt. Dann liest der Detektiv die
Karte laut vor.“

Muster je Zeile, **wörtlich**: „Karte unter dem Streifen [Name]: umdrehen, sobald [Codes] offen liegt. Frühestens zu Beginn von
Runde [N].“

| Streifen | Codes für die Karte darunter | frühestens | So umschreiben die Hefte diese Person (für den „Zeitstempel“) |
|---|---|---|---|
| Lejla | WE3, PM3 oder WM9 | Runde 2 | „die Apothekerin am rechten Buffettisch“, „deine Cousine“, „meine Cousine“ |
| Emine | FM9 oder NN3 | Runde 2 | „deine beste Freundin“, „meine beste Freundin“, „eine Freundin von Fatma“ |
| Tim | MR4 oder FK3 | Runde 3 | „der Hobby-Elektriker“, „dein Kumpel aus der Berufsschule“, „mein Kumpel“ |
| Joanna | WE3, PM3 oder WM9 | Runde 2 | „die Fotografin des Abends“ |
| Marek | XD3 oder JT3 | Runde 3 | „der Caterer“ |
| Zeynep | FK3 oder JT3 | Runde 3 | „die Fußballtrainerin“, „deine Schwester“, „meine Schwester“ |

„Ein Gast“ und „jemand“ öffnen keinen Streifen; „ein Gast mit einer großen Teekanne“ ist Damir (P145R2-K03).

Die Streifen selbst öffnen nur ihre Ortstermine (Zeynep: AD3 oder FK3) und der „Zeitstempel“ (5.4).

---

## 15. Rollen 1–18

Schreibweise in diesem Kapitel: Wörtliche Texte stehen in „ “. Zitate darin stehen in ‚ ‘. Im Druck fallen die äußeren
Zeichen weg, wo der Text für sich steht (Kasten, Karte, Streifen); die inneren werden dann zu „ “. Platzhalter: In den
Abschnitten RK steht ein fehlbarer Name in eckigen Klammern, [Lejla]; der Ersatz steht in RK 1.5. In den Abschnitten ZG und
ZR gilt [Name | Ersatz] nach ZG G-08; steht hinter dem Strich nichts, entfällt der Satzteil. In Tabellenzellen steht der Strich
als „\|“. Jede gedruckte Zeile, die eine Rolle mit höherem Platz nennt, trägt einen Platzhalter (WELT §0.2).

Reihenfolge: gemeinsame Bauteile der vier Verdächtigen (RK 1, RK 8.1, RK 8.2), die Rollen 1–4 (RK 2 bis 5), Grundsätze der
Zeugen (ZG 0) und die Rollen 5–10 (ZG 1 bis 6, mit den Zeugenstreifen), Querschnitt der Zeugen (ZG 7), Grundsätze der
Zusatzrollen (ZR 0), die Rollen 11–18 (ZR 1 bis 8), Querschnitt und Skalierung der Zusatzrollen (ZR 9, ZR 13).

### RK 0.3 Schreibregeln für alle Texte dieser Datei

Es gelten WELT §0.2, MECH §0.2 und REG §6 und §9. Hier nur, was beim Schreiben der Rollen am häufigsten stolpert:

- Kein Verb des Schlagens, auch nicht „vorschlagen“, „nachschlagen“ (REG §9 Nr. 31). Stattdessen „Bitte den Detektiv um den Ortstermin“.
- Das Nomen „Schlag“ nur in „ein dumpfer Schlag“. Kein Blut, keine Wunde. Herr Schneider: „bewusstlos, mit einer dicken Beule“.
- „Herr Schneider“ / „Herrn Schneider“. Bloß „Schneider“ nur in Ollis wörtlicher Rede.
- Raumwörter nur aus der Liste (REG §6.9). Kein „Umgang“, „Ausgang“, „Übergang“, „Vorgang“, kein „Saal“ allein.
- Uhrzeiten nur Kanon-Minuten (WELT §0.2). Sekunden nie. Im Dunkeln nur Reihenfolgen.
- Vorlesetexte (Fragen des Erzählers, „Dein Auftritt“): keine Ziffern, keine Klammern, keine Abkürzungen, Sätze höchstens
  25 Wörter, im Mittel höchstens 14. Hefte, Karten, Fassungen: „23:57 Uhr“ und „2.000 €“ erlaubt.
- Fatma hat die Schatulle **ausgeliehen**. Can spielt einen **Streich**. Kopftuch kommt nirgends vor.
- Kein eindeutiges Farbwort einer anderen Figur (REG §6.7): in Heften 1–4 nie „türkis“, „olivgrün“, „karorot“,
  „violett“, „lederbraun“, „minzgrün“, „sandbeige“ und kein anderes eindeutiges Farbwort aus REG §6.7, außer beim eigenen Merkmal.
- Keine Anglizismen außer Handy, Box, Design, Catering, Hobby, Dips. Ollis Kanon-Satz heißt im Kammerspiel „Hier, dein Eis. Hat gedauert.“ (P145R2-K01)
  steht nur in seiner Fassung als Zitat aus WELT §3.4.

### RK 1 · Gemeinsame Bauteile der vier Verdächtigen

#### RK 1.1 Rollenheft (Teil 10): Gliederung und Wortbudget (gleiche Gestalt, E9, MECH §10.4)

Alle vier Hefte haben dieselben Überschriften in derselben Reihenfolge und dieselben Wortbudgets. Toleranz: zehn Prozent der
Wörter je Seite (REG §6.11). „Was alle wissen“ (MECH §1.5) und die Tischregeln (Kurzform von MECH §1.4) sind für alle gleich
und zählen nicht ins Budget.

| Seite | Überschrift (wörtlich) | Inhalt | Wörter |
|---|---|---|---|
| 1 | „Dein Auftritt bei der Vorstellung“ | Ich-Form, Vorlesetext | 65–80 |
| 1 | „Wer du bist“ | Profil, Beziehungen als Tatsache, „Was dich heute antreibt“ | 75–95 |
| 1 | „Was alle wissen“ | MECH §1.5 wörtlich | fest |
| 2 | „Deine Marker“ | zwei Zeilen (23:57, Scheppern) | 25–35 |
| 2 | „Stufe 1: Was du sagst, solange dir nichts bewiesen ist“ | Kernsätze, ein Regiesatz, sieben Ausweichsätze und ein Markersatz, bei allen vier gleich gebaut (P5-K3, P2-21) | 120–180 |
| 2 | „Wenn der Erzähler fragt“ | Antworten auf die Impulse, Tabelle 1.8 (P14-08) | 120–145 |
| 2 | „Stufe 2: Wenn es dich erwischt“ | „Was du verbirgst“, drei Sobald-Sätze, „Was du dann sagst“, Marker, „Ab dann“ | 205–245; Seite 2 zusammen 465–535 |
| 3 | „Deine Gesprächsaufträge“ | je Runde zwei Ziele mit Frage und Nachschlag; Ausweichziel nur gedruckt, wenn die Zielrolle fehlt | 230–280 |
| 3 | „Was du über andere sagen darfst“ | Freigabe-Tabelle (1.4) | 90–120 |
| 4 | „Was du bei dir trägst“ | Text für die Taschenkontrolle, in der Ich-Form, weil die Person ihn vorliest (P145R2-K09) | 20–35 |
| 4 | „Deine Aktionskarte“ | Abbildung der Karte, ein Tipp | 70–85 |
| 4 | „Dein Bonus-Ziel“ | Satz und Erfüllt-Bedingung | 40–55 |
| 4 | „Deine versiegelte Fassung“ | „Deine Fassung trägt den Code [Code]. Öffne sie erst, wenn der Erzähler es sagt.“ | fest |
| 4 | „Notizen“ | Linien | – |

Hinweis zur Besetzung unten auf Seite 4, **wörtlich** (Kanon-Muster): „Jede Person kann [Name] spielen, egal welches Geschlecht
sie hat.“

#### RK 1.2 Form der Gesprächsaufträge (A:90, Protokoll 1)

Jede Runde hat **zwei Ziele**. Ziel 1 richtet sich immer an eine andere verdächtige Person (immer besetzt, kein Ausweichziel
nötig). Ziel 2 richtet sich an eine Zeugin oder einen Zeugen 5–10 und hat ein Ausweichziel. Jedes Ziel hat:

| Feld | Inhalt |
|---|---|
| Zielrolle | Name |
| Frage | wörtlich, Ich-Form, eine echte Frage oder ein Vorwurf |
| Nachschlag | ein Sobald-Satz mit einer Bedingung, die am Tisch sichtbar wird, und dem Satz, den du dann nachlegst |
| Ausweichziel | nur bei Ziel 2: wen du stattdessen fragst, wenn die Zielrolle heute niemand spielt |

Der Generator druckt bei fehlender Zielrolle **nur das Ausweichziel**. Der Name der fehlenden Rolle steht dann nirgends im Heft
(WELT §1.1). Ausweichziele sind immer eine der vier Verdächtigen oder eine Bitte an den Detektiv um eine Untersuchung. Jede Bitte an den
Detektiv hat einen zweiten Satz: eine echte Frage an eine andere Verdächtige oder einen anderen Verdächtigen, die wahr
beantwortbar ist (A:90, RK-24, P14-14).

Verteilung der Ziele (RK-02). Ziel 1 läuft in jeder Runde nach einem anderen Muster, damit jede der vier genau dreimal Ziel ist:

| Runde | Muster Ziel 1 | Ahmet → | Fatma → | Olli → | Can → |
|---|---|---|---|---|---|
| 1 Alibi-Geflecht | rückwärts im Ring, Frage zum Marker | Fatma | Can | Ahmet | Olli |
| 2 Indizien-Filterung | Domino-Ring (MECH M-16), Nachschlag = eigener Domino-Hinweis | Olli | Ahmet | Can | Fatma |
| 3 Gegenüberstellung | über Kreuz, Frage zum Weg zur Vorratsraumtür | Can | Olli | Fatma | Ahmet |

| Runde | Ziel 2 Ahmet | Ziel 2 Fatma | Ziel 2 Olli | Ziel 2 Can |
|---|---|---|---|---|
| 1 | Marek (Ausweich: Detektiv, WJ9, dazu Frage an Can) | Emine (Ausweich: Detektiv, RH3, dazu Frage an Olli) | Tim (Ausweich: Can, P14-K06) | Zeynep (Ausweich: Fatma) |
| 2 | Joanna (Ausweich: Detektiv, FX3, dazu Frage an Fatma) | Zeynep (Ausweich: Can) | Marek (Ausweich: Ahmet) | Joanna (Ausweich: Detektiv, WE3, dazu Frage an Ahmet) |
| 3 | Lejla (Ausweich: Detektiv, DM3, dazu Frage an Olli) | Marek (Ausweich: Detektiv, XD3, dazu Frage an Can) | Lejla (Ausweich: Frage an Can; Karte offen dazu Bitte an den Detektiv, DM3) | Tim (Ausweich: Frage an Olli; Karte offen dazu Bitte an den Detektiv, FK3) |

Jede Zeugin und jeder Zeuge 5–10 ist mindestens einmal Ziel: Lejla 2, Emine 1, Tim 2, Joanna 2, Marek 3, Zeynep 2.
Ausweichziele an den Detektiv nennen den Titel der Indizkarte aus seiner Liste, nicht den Code (Spieltext); der Code steht hier
nur zur Prüfung.

#### RK 1.3 Stufen (A:91-96, MECH §0.2, R-03 bis R-06)

| Stufe | Wo es steht | Wann | Form |
|---|---|---|---|
| 1 | Heft Seite 2 | von Anfang an | zwei Kernsätze (Kanon-Lügen) und sieben Ausweichsätze auf die häufigsten Fragen |
| 2 | Heft Seite 2, Geheimniskarte | sobald einer der drei Pflicht-Auslöser erfüllt ist, oder freiwillig am Rundenende | Karte umdrehen, „Was ich zugebe“ vorlesen, Domino-Hinweis sagen, Marker umstellen |
| 3 | Fassung Seite 3 | nur, wenn der Detektiv dich bei der Anklage nennt | Text vorlesen, gleiche Gestalt bei allen vier (RK-14) |

Keine Rundensperre für die vier Verdächtigen (MECH §4.2). Jede hat genau die drei Pflicht-Auslöser aus MECH §4.2, wörtlich als
Sobald-Satz. Zusätzliche Auslöser aus dem Gespräch gibt es bei den vier nicht (RK-03: gleiche Gestalt, kein Streit am Tisch, ob
ein Gesprächssatz „genug“ war).

#### RK 1.4 Freigabe von Wissen über andere (RK-07)

Was eine Verdächtige über andere weiß, darf sie nicht immer sofort sagen, sonst fällt Ollis Stufe 1 in Minute eins
(WELT §5.5). Drei Freigabestufen, gleich für alle vier:

| Stufe | Bedeutung |
|---|---|
| **sofort** | darfst du von Anfang an sagen; es verrät dein Geheimnis nicht |
| **nach dem Marker** | erst, wenn dein Marker „23:57“ umgestellt ist (gilt nur für Fatma; Ahmets Marker stimmt, bei Olli und Can fällt der Marker mit der Karte) |
| **nach der Karte** | erst, wenn deine Geheimniskarte offen liegt |

Jede der vier hat genau drei Einträge „sofort“, einen Eintrag „nach dem Marker“ (bei Ahmet wörtlich „Dein Marker stimmt. Hier
kommt nichts dazu.“, bei Olli und Can „Dein Marker fällt mit deiner Karte. Hier kommt nichts dazu.“) und drei Einträge „nach der
Karte“. Wortlaut in 8.1.

#### RK 1.5 Besetzungsvarianten in Heften, Karten und Fassungen 1–4 (RK-11)

Ahmet, Fatma, Olli und Can sind immer besetzt. Die Zeugen 5–10 und die Zusatzrollen nicht. Ein Text der vier nennt eine fehlende
Rolle nie mit Namen (WELT §1.1). Der Generator ersetzt nach dieser Tabelle. Steht der Name in wörtlicher Rede, fällt nur der
Name weg.

| fehlt | in Heft und Fassung von | wird zu |
|---|---|---|
| 5 Lejla | Ahmet | „deine Cousine“ |
| 5 Lejla | Olli | „die Apothekerin am rechten Buffettisch“; Flüstern: „Ich bin's, Olli.“ |
| 6 Emine | Fatma | „deine beste Freundin“; Flüstern: „Ich bin's, Fatma.“ |
| 6 Emine | Can, Karte Can | „eine Freundin von Fatma“ (siehe 5.8, RK-10) |
| 7 Tim | Olli | „dein Kumpel aus der Berufsschule“ |
| 7 Tim | Can | „ein Gast“ |
| 8 Joanna | alle | „die Fotografin des Abends“ (wie MECH §1.5) |
| 9 Marek | Ahmet | „der Caterer“; Flüstern: „Ich bin's, Ahmet.“ |
| 9 Marek | Olli, Fatma | „der Caterer“ |
| 10 Zeynep | Can | „deine Schwester“ |
| 10 Zeynep | Fatma | „jemand“; Fatmas Eintrag „sofort“ über Zeynep wird ersetzt durch „Um 23:56 Uhr ist Herr Schneider von unserem Buffet zum Ostende gegangen.“ (P14-K05) |
| 12 Damir | Ahmet | „ein Gast mit einer großen Teekanne“ |
| 15 Azra | Fatma | „eine Bekannte aus der Unibibliothek“ |
| 17 Aylin | Ahmet | „ein Gast“ |
| andere 11–18 | alle | „ein Gast“ |

Satzteile, die nur eine Beziehung zur fehlenden Rolle beschreiben („[Joanna] fotografiert deine Stadtfeste.“), entfallen ganz.
In Ich-Sätzen der Rolle wird aus „deine“ „meine“ („meine Cousine“, „meine beste Freundin“, „mein Kumpel aus der Berufsschule“,
„meine Schwester“), aus „der Caterer“ bleibt „der Caterer“.
In den Tabellen unten stehen Namen fehlbarer Rollen in eckigen Klammern: [Lejla]. Das heißt: Variante nach dieser Tabelle.

#### RK 1.6 Bonus-Ziel der vier (MECH §7.3, M-36)

Typ „Reinen Tisch“, gleiche Gestalt, für alle vier **wörtlich** (P14-07):
> „**Dein Bonus-Ziel:** Du sagst selbst, was du verbirgst, bevor man es dir beweist. **Erfüllt, wenn** du deine Geheimniskarte am Ende einer Runde freiwillig umgedreht hast (reinen Tisch), bevor einer deiner drei Sobald-Fälle eingetreten ist.“

Prüfung: Wer am Rundenende reinen Tisch macht, sagt es laut. Der Detektiv schreibt in der Vermerke-Liste „freiwillig“ zum
Eintrag (MECH §2.6). Ein Eintrag ohne „freiwillig“ erfüllt das Ziel nicht; eine Pflicht-Umdrehung zählt nicht. Zweifel
entscheidet die Mehrheit des Tisches (MECH §6.4). Die frühere Ersatzregel (RK-17) entfällt.

#### RK 1.7 Stufe 3 und Anklage (MECH §8.1, RK-14)

Stufe 3 steht nur in der Fassung. Sie wird nur vorgelesen, wenn der Detektiv die Person anklagt. Vorher bleibt jede der vier
bei Stufe 2 und den Sätzen aus „Wenn es eng wird“ (Fassung Seite 3). A:96 („erst bei der finalen Anklage, wenn XD3, FN3 und PP9
zusammenkommen“) ist so erfüllt: Ollis Geständnis kommt erst bei der Anklage; liegen XD3, FN3 und PP9 dann offen, ist er nach
MECH §2.4 zugleich überführt. Liegen sie nicht offen, gesteht er trotzdem, weil die Enden 1 und 2 („Teilerfolg“) es so erzählen
(MECH §8.2). Ein Text für jeden Beweisstand, gleich lang wie die drei anderen.

#### RK 1.8 „Wenn der Erzähler fragt“ (Heft Seite 2, **wörtlich**, P14-08)

Die Impulse stehen in MECH §9.9. Jede der vier hat dieselbe Tabelle mit denselben Zeilen. „Karte zu“ und „Karte offen“
meinen die eigene Geheimniskarte. Namen in eckigen Klammern nach 1.5. Antworten aus Stufe 1 dürfen lügen, so weit das Heft
es erlaubt (R-01); Antworten nach dem Umdrehen sind wahr.

| Impuls | Ahmet | Fatma | Olli | Can |
|---|---|---|---|---|
| I-1.1 Wer hat dich gesehen? | „Hinter der Theke am Ostende. [Marek] stand direkt neben mir.“ | Marker noch am Buffet: „Am linken Buffet. [Emine] war bei mir.“ Marker auf der Klappe: „An der Theken-Klappe. [Joanna] hat mich dort gesehen.“ | Karte zu: „Am Kopf der Tafel. Der Detektiv hat mich hereinkommen sehen.“ Karte offen: „Am Eiskübel. Ahmet stand hinter der Theke.“ | Karte zu: „Oben auf der Turm-Toilette. Da sieht einen keiner.“ Karte offen: „Im Vorratsraum, im Dunkeln. Gesehen hat mich da keiner.“ |
| I-1.2 Wer war neben dir? | „Ich hab mich an [Mareks] Beine gekauert und geflüstert: ‚[Marek]? Ich bin's, Ahmet.‘“ | „[Emine]. Ich hab mich gleich nach dem Knall neben sie gekauert.“ | Karte zu: „Weiß ich nicht genau. Es war ja dunkel.“ Karte offen: „Erst niemand. Dann bin ich zu [Lejla] gekrochen.“ | Karte zu: „Niemand. Ich war allein oben.“ Karte offen: „Niemand. Ich bin gerannt. Im Steinbogen hab ich [Zeynep] gestreift.“ |
| I-1.3 Dem Ruf nicht gefolgt | „Ich. Ich hab hinter der Theke Servietten für die Torte gesucht.“ | Marker noch am Buffet: „Ich. Ich bin beim Gebäck am linken Buffet geblieben.“ Marker auf der Klappe: „Ich war kurz an der Theken-Klappe. Ich wollte Herrn Schneider etwas fragen.“ | Karte zu: „Ich bin gefolgt. Ich saß am Kopf der Tafel.“ Karte offen: „Am Eiskübel. Eis für [Tim], und ich wollte mit Herrn Schneider reden.“ | Karte zu: „Ich war oben auf der Turm-Toilette. Den Ruf hab ich nicht gehört.“ Karte offen: „Ich hab im Vorratsraum auf die blinde Kuh gewartet.“ |
| I-2.1 Geld | Karte zu: „Ich hab von allen 150 € für die Miete eingesammelt. Das Geld bekommt Herr Schneider.“ Karte offen: „Der Keller hat nichts gekostet. Ihr bekommt euer Geld zurück.“ | „150 € an Ahmet, wie alle. Ich schulde niemandem etwas.“ | Karte zu: „150 € an Ahmet, wie alle.“ Karte offen: „Herr Schneider will 2.000 € für die Bogentür. Bis Mitternacht.“ | „150 € an Ahmet, wie alle. Ich schulde niemandem etwas.“ |
| I-2.2 Turmgang und Bogentür | „Im Turmgang war ich heute nicht.“ | Karte zu: „Im Turmgang war ich kurz, vor zwölf. Da steht diese Rüstung.“ Karte offen: „Um 23:40 Uhr hab ich dort die Münzschatulle ausgeliehen.“ | „Um halb sieben hab ich mit [Tim] die Warmhaltebehälter durch den Turmgang getragen.“ | „Zur Turm-Toilette geht man durch den Turmgang und die Wendeltreppe hoch. Da war ich.“ |
| I-2.3 Das Gesicht | „Gesehen hab ich nichts. Ich hab am Ostende gekauert.“ | „Gesehen hab ich nichts. Ich hab hinter dem linken Buffettisch gekauert.“ | Karte zu: „Ich saß im Ost-Saal. Von da sieht man nichts.“ Karte offen: wie Stufe 2 | Karte zu: „Ich war oben im Turm. Gesehen hab ich nichts.“ Karte offen: „Das Gesicht war ich, mit meiner Maske.“ |
| I-3.1 Was kam zuerst? | „Erst der Knall. Dann ‚Ruhe! Ich hol die Notlaterne.‘ Dann ‚Hab ich dich!‘, zweimal ‚Stehen bleiben!‘ und das Scheppern.“ | „Erst der Knall. Dann ‚Hab ich dich!‘, zweimal ‚Stehen bleiben!‘, dann das Scheppern. Da war ich schon neben [Emine].“ | Karte zu: „Knall, Rufe, Scheppern. Gesehen hab ich nichts.“ Karte offen: wie Stufe 2 | „Das Scheppern hab ich nicht gehört. Was danach an der Theke war, weiß ich nicht.“ |
| I-3.3 Nach dem Licht | Karte zu: „Ich war kurz im Kaminsaal, durchatmen. Geholt hab ich nichts.“ Karte offen: „Um zwölf nach zwölf hab ich den leeren Umschlag in den Ascheneimer am Kamin geworfen.“ | „Ich hab nichts geholt und nichts weggebracht.“ | „Ich hab [Tim] obenauf Eis aus dem Eiskübel gebracht.“ | „Kurz nach zwölf bin ich runter und hab mich im Kaminsaal auf die Wandbank gesetzt.“ |

Die übrigen Impulse (I-1.4, I-2.4, I-3.2, I-3.4) fragen nach Markern, Wegen oder reinem Tisch. Die vier antworten darauf mit
Stufe 1, nach dem Umdrehen mit Stufe 2, oder sie machen am Rundenende reinen Tisch (R-05). Gleiche Gestalt: acht Zeilen bei
allen vier, 126 bis 139 Wörter je Heft (7.7). Cans Antworten auf I-2.2 und I-3.1 sind vor und nach dem Umdrehen wahr
(P3R2-02). Olli sagt bei „Karte zu“ nie „Ich war am Eiskübel“; Ahmet nennt Olli in diesen
Antworten nicht (RK-09).

#### RK 8.1 „Was du über andere sagen darfst“ (Heft Seite 3, **wörtlich**, RK-07)

Kopf, für alle vier gleich: „Was du über andere sagen darfst. Sofort: alles in der ersten Spalte. Wenn dein Marker ‚23:57‘ umgestellt ist: die zweite. Wenn deine Karte offen liegt: die dritte.“

| | Sofort | Wenn dein Marker umgestellt ist | Wenn deine Karte offen liegt |
|---|---|---|---|
| Ahmet | „Um 23:55 Uhr saß Olli am Kopf der Tafel im Ost-Saal.“ · „Beim Knall hab ich an [Mareks] Beinen gekauert. [Damir] war neben mir.“ · „Durch das Ostende ist im Dunkeln niemand an mir vorbeigekommen.“ | „Dein Marker stimmt. Hier kommt nichts dazu.“ | „Um 23:57 Uhr stand Olli am Eiskübel. Herr Schneider sagte zu ihm: ‚Zweitausend, bis zwölf.‘“ · „[Joanna] hat mich um 23:51 Uhr mit Herrn Schneider fotografiert.“ · „Um 23:57 Uhr ging Herr Schneider hinter der Theke an mir vorbei zur Kaffeemaschine.“ |
| Fatma | „Beim Knall hab ich mich neben [Emine] gekauert.“ · „Um Viertel vor zwölf hat [Zeynep] am linken Buffet Gebäck geholt.“ (fehlt Zeynep: „Um 23:56 Uhr ist Herr Schneider von unserem Buffet zum Ostende gegangen.“, P14-K05) · „Kurz vor zwölf hab ich Can im Buffetsaal nirgends gesehen.“ | „Von der Klappe hab ich um 23:57 Uhr Olli am Eiskübel vor Herrn Schneider gesehen. Dann ging Herr Schneider zur Kaffeemaschine.“ | „Um 23:57 Uhr ging Ahmet mit einem dicken Umschlag am Ostende hinter die Theke.“ · „Um 23:56 Uhr drohte mir Herr Schneider mit der Polizei. [Emine] hat es gehört.“ · „Um 23:54 Uhr hab ich mit [Emine] über meine Tasche getuschelt.“ |
| Olli | „Um 23:55 Uhr hat Ahmet im Ost-Saal seine Jacke aufgehängt. Einen dicken Umschlag hatte er in der Hand.“ · „Gleich als das Licht anging, hab ich [Tim] Eis aus dem Eiskübel gebracht.“ · „Um halb sieben hat Herr Schneider [Marek] gedroht, den Lieferwagen abschleppen zu lassen.“ | „Dein Marker fällt mit deiner Karte. Hier kommt nichts dazu.“ | „Um 23:57 Uhr sagte Herr Schneider leise zu mir: ‚Zweitausend, bis zwölf.‘“ · „Um 23:57 Uhr stand Ahmet hinter der Theke am Ostende.“ · „Nach dem Knall sprang ein leuchtendes Gesicht aus dem Vorratsraum. Herr Schneider packte es.“ |
| Can | „Um zehn vor zwölf standen Olli und [Tim] an der Bogentür im Kaminsaal. Einer rief: ‚Au! Mein Finger!‘“ · „Um Viertel vor zwölf hat [Zeynep] Gebäck für uns beide geholt.“ · „Kurz nach zwölf saß ich im Kaminsaal auf der Wandbank. [Zeynep] kam zu mir.“ | „Dein Marker fällt mit deiner Karte. Hier kommt nichts dazu.“ | „Um 23:54 Uhr tuschelten Fatma und [Emine] am linken Buffet.“ · „Als ich mich losriss, stand Herr Schneider noch und brüllte: ‚Stehen bleiben!‘“ · „Im Steinbogen hab ich [Zeynep] gestreift.“ |

Prüfung: Kein Eintrag „sofort“ verrät das eigene Geheimnis oder widerspricht der eigenen Stufe 1. Kein Eintrag „sofort“ ist ein
Pflicht-Auslöser für eine andere verdächtige Person (Ahmets „Olli um 23:55 am Kopf der Tafel“ stützt sogar Ollis Stufe 1, wahr
und nur bis 23:56). Ollis Stufe 1 fällt also nicht durch die drei anderen in Minute eins (WELT §5.5).

#### RK 8.2 Gleiche Gestalt der vier (E9, REG §6.11, MECH §10.4)

| Merkmal | Ahmet | Fatma | Olli | Can | gleich? |
|---|---|---|---|---|---|
| Heft: Seiten, Überschriften, Reihenfolge | 4, 1.1 | 4, 1.1 | 4, 1.1 | 4, 1.1 | ja |
| Auftritt mit Anekdote | Händedruck (Kanon) | Farbenlehre (Kanon) | Verlaufen (Dia 4) | Video (Kanon) | ja, je eine kurze Geschichte |
| Kernsätze Stufe 1 | 2 + Regiesatz | 2 + Regiesatz | 2 + Regiesatz | 2 + Regiesatz | ja (P5-K3); Ollis Regiesatz ist Kanon, die drei anderen sind gleich gebaut |
| Ausweichsätze | 7 + Markersatz | 7 + Markersatz | 7 + Markersatz | 7 + Markersatz | ja (P5-K3; die siebte Zeile fragt nach 23:51, P2-21) |
| Pflicht-Auslöser | 3 | 3 | 3 | 3 | ja |
| Rundensperre | keine | keine | keine | keine | ja |
| Geheimniskarte: Wörter, Vermerke, Domino | 59, 2, 1 | 57, 2, 1 | 55, 2, 1 | 57, 2, 1 | ja |
| „Wenn der Erzähler fragt“ | 8 Zeilen | 8 Zeilen | 8 Zeilen | 8 Zeilen | ja (1.8, P14-08) |
| „Ab dann“: Schlusssatz | „Mehr gibst du nicht zu. Dabei bleibst du.“ | dto. | dto. | dto. | ja (P5-B3); „Mit dem Scheppern hast du nichts zu tun“ steht nur in den Fassungen WW4, JM3, YW4 |
| Absatz für Teil 90 | 3 Sätze | 3 Sätze | 3 Sätze | 3 Sätze | ja (P5-M2) |
| Aktionskarte | Einspruch (Schutz) | Gegenfrage (Schutz) | Themenwechsel (Schutz) | Retourkutsche (Schutz) | ja (M-35) |
| Gesprächsaufträge | 6, Muster 1.2 | 6 | 6 | 6 | ja |
| Freigabe sofort / Marker / Karte | 3 / 1 / 3 | 3 / 1 / 3 | 3 / 1 / 3 | 3 / 1 / 3 | ja |
| „Was du bei dir trägst“ | Bündel Scheine (keine Karte) | Tasche → NN3 | Weste → FN3 | Bauchtasche → JT3 | Wirkung der Taschenkontrolle ungleich, aber MECH §4.4 so festgelegt; Ahmets Gegenstück ist WE3 |
| Bonus-Ziel | freiwillig reinen Tisch vor dem ersten eigenen Sobald-Fall | dto. | dto. | dto. | ja (M-36, P14-07) |
| Fassung: Seiten, Überschriften | 4, 7.1 | 4 | 4 | 4 | ja |
| „Was nur du weißt“ | 5 Punkte | 5 | 5 | 5 | ja |
| „Wenn es eng wird“ | 5 Sätze | 5 | 5 | 5 | ja (P2-04) |
| Stufe 3: Aufbau | Antwort · Ort beim Scheppern · Geheimnis · Vorratsraumtür · Bund | dto. | Antwort · Weg zur Tür · Panik · Bund · Entschuldigung | dto. wie Ahmet | ja, gleiche fünf Bausteine |
| Marker, die lügen (Stufe 1) | 0 | 1 | 2 | 1 | nein, aber WELT §4.2 fest; im Heft je eine Zeile „stimmt / gelogen“ |

Die Lügen über Marker sind die einzige sichtbare Ungleichheit. Sie folgt aus der Welt (WELT §4.2) und dem Auftrag (A:86) und ist
am Tisch erwartbar: Jede der vier hat mindestens eine Lüge in Stufe 1.

### RK 2 · Rolle 1: Ahmet (Fassung WW4) – unschuldig

#### RK 2.1 Profil

| Feld | Inhalt |
|---|---|
| Platz | 1, immer besetzt, Verdächtiger |
| Alter, Beruf | 27, Agentur für Stadtfeste und Märkte; hat den Abend organisiert |
| Merkmal | Brille, kurzer Bart, schwarzer Strickpulli, blaues Stoffarmband; ab 23:55 hängt die schwarze Jacke am Jackenständer |
| Farbe | Schwarz und Weiß |
| Beziehungen (WELT §1.3) | Lejla Cousine (Versprechen zur Essensrechnung) · Marek Caterer, Ahmet schuldet die Nachzahlung · Joanna fotografiert seine Stadtfeste (Versprechen zum Foto) · Olli Banknachbar · Fatma eine Klasse unter ihm · Can hat von ihm Radfahren gelernt |
| Geheimnis | Mietschwindel: 150 € „Miete“ von allen, obwohl der Keller umsonst war; Geld für die Nachzahlung |
| Ziel (Kanon) | Niemand soll vor dem Morgen erfahren, dass die Miete erfunden war. |
| Code der Fassung | WW4 |

#### RK 2.2 Marker

| Marker | Stufe 1 (behauptet) | wahr | umstellen |
|---|---|---|---|
| 23:57 | 4d Theke Ostende | 4d hinter der Theke ganz am Ostende | nie (der Ort stimmt, der Grund nicht) |
| Scheppern | 4d Theke Ostende | 4d, kauert an Mareks Beinen | nie |

Heft, **wörtlich**: „Marker 23:57: Theke Ostende (4d). Marker Scheppern: Theke Ostende (4d). Beide stimmen. Du lügst nicht über den Ort, nur über den Grund.“

#### RK 2.3 Vorstellungsrunde

Frage des Erzählers (Erzählerheft, **wörtlich**, Vorlesetext):
> „Ahmet, du hast diesen Abend organisiert, und jeder hier hat von dir schon eine Aufgabe bekommen. Welche Aufgabe hast du dir selbst gegeben?“

„Dein Auftritt bei der Vorstellung“ (Heft, **wörtlich**, Vorlesetext, 70 Wörter):
> „Welche Aufgabe ich mir gegeben hab? Dass ihr alle eure Aufgaben macht! Ich plane beruflich Stadtfeste, da ist so ein Keller ein Kinderspiel. Wer mir heute die Hand gegeben hat, hatte danach eine Aufgabe. Einer trägt Stühle, eine zählt Teller, einer hält die Tür auf. Ein paar von euch haben mir deshalb nur noch von Weitem gewinkt. Schlau. Aber keine Sorge: Heute läuft alles nach Plan. Ich kümmere mich darum.“

Anekdote: keine aus den Dias 3–5 (die gehören Sibel, Olli, Hana; WELT D-28). Der Händedruck mit Aufgabe ist Kanon
(`texte/erzaehler-vorstellung.json` „vorstellung.ahmet“, `steckbriefe.json` „Keine Sorge, ich kümmere mich darum.“). Kein Wort zu
Geld, Miete oder Herrn Schneider (Sperrwörter wie in der Vorgeschichte, MECH §9.3, RK-18).

#### RK 2.4 „Wer du bist“ (Heft, **wörtlich**)

> „Du bist Ahmet, 27, der Organisator. Du arbeitest in einer Agentur, die Stadtfeste und Märkte plant. Den Abend im Schlosskeller hast du organisiert. Man erkennt dich an Brille, kurzem Bart, schwarzem Strickpulli und blauem Stoffarmband. [Lejla] ist deine Cousine. [Marek] hat das Essen geliefert, du bist sein Kunde. [Joanna] fotografiert deine Stadtfeste. Neben Olli hast du in der Schule gesessen, und Can hast du Radfahren beigebracht.
> Was dich heute antreibt: Niemand soll vor dem Morgen erfahren, dass die Miete erfunden war.“

#### RK 2.5 Wissen

★ = steht im Heft in „Was du über andere sagen darfst“ (1.4).

| Nr | Fakt | sicher / vermutet | Quelle | Freigabe |
|---|---|---|---|---|
| 1 | Der Keller war umsonst; dafür gestaltet Ahmet das Programm des Adventsmarkts der Stiftung | sicher | WELT §3.2 | nach der Karte |
| 2 | Nachzahlung: 150 € pro Gast, heute in Bargeld fällig | sicher | WELT §1.8 | nach der Karte |
| 3 | 23:51 Herr Schneider leise: „Um zwölf sag ich allen, was der Keller gekostet hat.“ | sicher | WELT §5.6 | nach der Karte |
| 4 ★ | 23:51 hat Joanna die Szene fotografiert; 23:53 hat sie versprochen, das Foto keinem zu zeigen | sicher | WELT §3.4 | nach der Karte |
| 5 ★ | Um 23:55, als er seine Jacke aufhängte, saß Olli am Kopf der Tafel im Ost-Saal | sicher | RK-06 | sofort |
| 6 ★ | 23:57 stand Olli am Eiskübel; Herr Schneider sagte leise zu ihm: „Zweitausend, bis zwölf.“ | sicher | WELT §5.5 | nach der Karte (Domino) |
| 7 ★ | Beim Knall kauerte er an Mareks Beinen und flüsterte; Marek stand bis zum Licht; [Damir] kauerte daneben | sicher | WELT §5.3 | sofort |
| 8 | Nach dem Knall rief Herr Schneider: „Ruhe! Ich hol die Notlaterne.“ | sicher | WELT §5.1 | sofort |
| 9 ★ | Durch das offene Ostende ist im Dunkeln niemand an ihm vorbeigekommen | sicher | RK-08 | sofort |
| 10 ★ | Herr Schneider ging um 23:57 hinter der Theke an ihm vorbei zur Kaffeemaschine | sicher | WELT §3.4 | nach der Karte |
| 11 | Olli hat Ärger mit Herrn Schneider wegen Geld; wofür, weiß er nicht | vermutet | aus Nr. 6 | – |
| 12 | Lejla und Joanna halten zu ihm, solange es geht | vermutet | Versprechen | – |

Was Ahmet **nicht** weiß: wer das leuchtende Gesicht war; wer an der Vorratsraumtür war; wo der Bund ist; dass Lejla das
Belegungsblatt mit „0 Euro“ gesehen hat; dass Azra ihn um 0:12 sah.

#### RK 2.6 Stufe 1 (Heft Seite 2)

Kernsätze, **wörtlich**: „Ich hab hinter der Theke nur Servietten gesucht.“ · „Die 150 € waren für die Miete.“

| Wenn jemand fragt | sagst du (wörtlich) | wahr? |
|---|---|---|
| Wo warst du um drei vor zwölf? | „Hinter der Theke am Ostende. Servietten für die Torte. Als Organisator denk ich an so was.“ | Ort wahr, Grund gelogen |
| Wo warst du um 23:51 Uhr? | „Vor der Theke. Ich hab kurz mit Herrn Schneider geredet.“ | wahr |
| Wo warst du beim Knall und beim Scheppern? | „Ich hab mich an [Mareks] Beine gekauert und geflüstert: ‚[Marek]? Ich bin's, Ahmet.‘ Bis das Licht anging, hab ich mich nicht bewegt.“ | wahr |
| Was hast du im Dunkeln gehört? | „Herr Schneider rief: ‚Ruhe! Ich hol die Notlaterne.‘ Dann ‚Hab ich dich!‘, zweimal ‚Stehen bleiben!‘ und das Scheppern. Gesehen hab ich nichts.“ | wahr |
| Wer stand um drei vor zwölf an der Theke? | „Keine Ahnung. Ich hab Servietten gesucht, nicht Leute gezählt.“ | gelogen (du hältst Olli zurück, sonst müsstest du erklären, warum du auf Herrn Schneider gewartet hast) |
| Was war in dem dicken Umschlag? | „Das Mietgeld. Das wollte ich Herrn Schneider geben.“ | halb (passt zur Lüge über die Miete) |
| Was ist das Geld in deiner Hosentasche? | „Die Miete. Ich heb sie auf, bis Herr Schneider sie nimmt. Den Umschlag hab ich weggeworfen.“ | halb |

Regie, **wörtlich** (P5-K3): „Bleib dabei geschäftig, wie jemand, der an alles denkt.“
Markersatz, **wörtlich** (P5-K3): „Dein Marker stimmt. Fragt jemand nach dem Grund, bleib bei den Servietten, bis deine Karte offen ist.“
„Wenn der Erzähler fragt“: Tabelle 1.8, Spalte Ahmet.

#### RK 2.7 Stufe 2 (Heft Seite 2)

„Was du verbirgst“, **wörtlich**:
> „Der Keller war umsonst. Herr Schneider hat ihn dir überlassen, weil du das Programm des Adventsmarkts der Stiftung gestaltest. Beim Essen hast du viel zu groß bestellt. Die Nachzahlung ist heute fällig: 150 € pro Gast, in Bargeld. Statt es zuzugeben, hast du von allen 150 € ‚Miete‘ eingesammelt. Um 23:51 Uhr drohte Herr Schneider, es um zwölf allen zu sagen. Um 23:57 Uhr wolltest du ihn hinter der Theke bitten, nichts zu sagen.“

Pflicht-Auslöser (MECH §4.2), **wörtlich** im Heft:
> „Du drehst deine Geheimniskarte sofort um, wenn einer dieser drei Fälle eintritt:
> (a) Sobald Herrn Schneiders Klemmbrett (PM3) oder der Ascheneimer am Kamin (WM9) offen liegt.
> (b) Sobald [Lejlas] Geheimniskarte offen liegt.
> (c) Sobald eine Taschenkontrolle bei dir das Bündel Scheine gezeigt hat und der Jackenständer im Ost-Saal (WE3) offen liegt. Was davon zuerst da war, ist egal.
> Du darfst sie auch am Ende jeder Runde freiwillig umdrehen.“

Variante (b), wenn Lejla fehlt, **wörtlich**: „(b) Sobald die Geheimniskarte unter dem Zeugenstreifen am rechten Buffettisch offen liegt.“

„Was du dann sagst“, **wörtlich**: „Lies ‚Was ich zugebe‘ von deiner Karte vor. Sag dann den Satz unter ‚Und noch etwas‘. Leg nach: ‚Ihr bekommt euer Geld zurück. Versprochen.‘“

Marker: bleiben (4d).

„Ab dann“, **wörtlich**:
> „Ab jetzt sagst du offen, was an der Theke war. Du darfst sagen, dass [Joanna] um 23:51 Uhr ein Foto gemacht hat. Zum Umschlag sagst du die Wahrheit. Um 0:12 Uhr hast du das Geld in die Hosentasche gesteckt. Den leeren Umschlag hast du in den Ascheneimer am Kamin geworfen. Mehr gibst du nicht zu. Dabei bleibst du.“

#### RK 2.8 Geheimniskarte Ahmet (Teil 20, Innenseite **wörtlich**)

Vorderseite wie MECH §4.1 („Geheimnis · Ahmet · Platz 1“ und der Hinweis darunter), für alle vier gleich gebaut.

> **Was ich zugebe**
> „Der Keller hat nichts gekostet. Trotzdem hab ich von allen 150 € ‚Miete‘ eingesammelt. Ich hatte das Essen zu groß bestellt. Die Nachzahlung ist heute fällig, in Bargeld. Um 23:51 Uhr hat Herr Schneider gedroht, es um zwölf allen zu sagen. Um 23:57 Uhr bin ich mit dem Umschlag hinter die Theke. Ich wollte ihn bitten, nichts zu sagen.“ (59 Wörter, kein Name einer Rolle 5–10; P5-K9)
>
> **Für den Ermittlungsbogen**
> „Heimlichtuerei · Ahmet: hat von allen 150 € ‚Miete‘ eingesammelt, obwohl der Keller umsonst war.“
> „Ort um 23:57 · Ahmet: hinter der Theke am Ostende.“
>
> **Und noch etwas**
> „Um 23:57 Uhr stand Olli am Eiskübel. Herr Schneider sagte zu ihm: ‚Zweitausend, bis zwölf.‘“

Wirkung des Domino-Hinweises: Pflicht-Auslöser (c) für Olli (MECH §4.2, A:95).

#### RK 2.9 Gesprächsaufträge (Heft Seite 3)

| Runde | Ziel | Zielrolle | Frage (wörtlich) | Nachschlag (wörtlich) | Ausweichziel (wörtlich, nur wenn die Zielrolle fehlt) |
|---|---|---|---|---|---|
| 1 | 1 | Fatma | „Fatma, dein Marker steht am linken Buffet. Wer hat dich dort um drei vor zwölf gesehen?“ | „Sobald jemand sagt, dass Fatma um drei vor zwölf zur Theken-Klappe ging: ‚Also warst du gar nicht beim Gebäck. Was wolltest du an der Klappe?‘“ | – (immer besetzt) |
| 1 | 2 | Marek | „Marek, sag dem Detektiv, wer sich beim Knall an deine Beine gekauert hat.“ | „Sobald Marek es bestätigt: ‚Und war ich noch da, als es schepperte, und als das Licht anging?‘“ | „Bitte den Detektiv um den Ortstermin ‚hinter der Theke am Ostende‘. Sag: ‚Dort hab ich gekauert. Wer dort war, kann es bezeugen.‘ Bis der Detektiv dort war, frag Can: ‚Can, ich war ab fünf vor zwölf im Ost-Saal und dann an der Theke. Dich hab ich nirgends gesehen. Wann bist du zur Turm-Toilette hoch?‘“ |
| 2 | 1 | Olli | „Olli, um elf ist Herr Schneider an der Theke richtig laut geworden. Mit wem hat er da gestritten, und worum ging es?“ | „Sobald deine Geheimniskarte offen liegt: ‚Um drei vor zwölf hat Herr Schneider zu dir gesagt: Zweitausend, bis zwölf. Zweitausend wofür?‘“ | – |
| 2 | 2 | Joanna | „Joanna, du hast um fünf vor zwölf alle zum Gruppenfoto gerufen und dann in der Tür zum Ost-Saal gestanden. Wen hast du von dort an der Theke gesehen?“ | „Sobald deine Geheimniskarte offen liegt: ‚Du darfst das Foto von 23:51 Uhr jetzt zeigen. Ich hab Herrn Schneider nur gebeten, um zwölf nichts zu sagen.‘“ | „Bitte den Detektiv um den Ortstermin ‚Tür zum Ost-Saal‘. Sag: ‚Von dort sieht man die ganze Theke.‘ Bis dahin frag Fatma: ‚Fatma, du schleppst die schwere Tasche den ganzen Abend mit dir herum. Was ist da drin?‘“ |
| 3 | 1 | Can | „Can, Herr Schneider hat im Dunkeln eine Kapuze erwischt. Wo genau warst du, als er ‚Hab ich dich!‘ brüllte, und wer hat dich dort gesehen?“ | „Sobald Herrn Schneiders rechte Hand (JA9) offen liegt: ‚An seiner Hand hängen gelbe Fasern. Dein Pulli ist gelb. Erklär das.‘“ | – |
| 3 | 2 | Lejla | „Lejla, du warst beim Knall am rechten Buffet. Wer kam im Dunkeln zu dir, und wann?“ | „Sobald deine Geheimniskarte offen liegt: ‚Mit der Miete ist es raus. Du musst mich nicht mehr schützen. Sag dem Detektiv alles, was du heute Nacht mitbekommen hast.‘“ | „Bitte den Detektiv um den Ortstermin ‚rechter Buffettisch‘. Sag: ‚Wer dort beim Scheppern war, weiß, wer daneben war.‘ Bis dahin frag Olli: ‚Olli, um fünf vor zwölf saßt du am Kopf der Tafel. Wo warst du, als es schepperte?‘“ |

Was die Ziele treiben: R1 Fatmas Ortslüge und Ahmets eigenes Alibi (M1); R2 Ollis Heimlichtuerei (Domino zu Olli) und Joannas
Liste (D1, D4); R3 die falsche Fährte gegen Can (D16) und Ollis späte Ankunft (D2).

#### RK 2.10 Seite 4: Was du bei dir trägst, Aktionskarte, Bonus-Ziel

„Was du bei dir trägst“, **wörtlich**: „In meiner Hosentasche steckt ein dickes Bündel Scheine. Sonst trag ich nur mein Handy. Meine schwarze Jacke hängt am Jackenständer im Ost-Saal.“ (Taschenkontrolle: keine Indizkarte; die Summe steht nur in Teil 90, MECH §4.4.)

Aktionskarte (MECH §4.4, **wörtlich**): **Einspruch** · Wirkung: „Spiel sie, wenn dir eine Frage gestellt wird. Du antwortest nicht. Die fragende Person muss die Frage einer anderen Person stellen.“ · Grenzen: „Nicht gegen Ortstermine, Indizkarten oder Karten, die offen liegen. Was offen liegt, bleibt liegen. Ein Satz, der eine Karte auslöst, gilt trotzdem. Die Frage darf später wiederkommen.“ · ab Runde 1.

Tipp im Heft, **wörtlich**: „Spiel sie, wenn jemand nach dem Geld fragt, bevor deine Karte offen ist. Gegen eine Indizkarte hilft sie nicht.“

Bonus-Ziel, **wörtlich**: „**Dein Bonus-Ziel:** Du sagst selbst, was du verbirgst, bevor man es dir beweist. **Erfüllt, wenn** du deine Geheimniskarte am Ende einer Runde freiwillig umgedreht hast (reinen Tisch), bevor einer deiner drei Sobald-Fälle eingetreten ist.“ (1.6)

#### RK 2.11 Wenn Rollen fehlen

| fehlt | was sich bei Ahmet ändert |
|---|---|
| Lejla (6 Personen) | „deine Cousine“; Auslöser (b) über die Geheimniskarte unter ihrem Zeugenstreifen (öffnet ab Runde 2 mit WE3, PM3 oder WM9); R3 Ziel 2 → Ausweichziel |
| Emine, Tim | nichts |
| Joanna (6–9 Personen) | „die Fotografin des Abends“; R2 Ziel 2 → Ausweichziel |
| Marek (6–10 Personen) | „der Caterer“; Flüstern „Ich bin's, Ahmet.“; sein Alibi trägt der Zeugenstreifen Marek (WJ9 oder Zeitstempel, MECH §5.3); R1 Ziel 2 → Ausweichziel |
| Zeynep | nichts |
| Damir (unter 14 Personen) | „ein Gast mit einer großen Teekanne“ (Heft Seite 3 und Fassung, P145R2-K12) |
| Aylin (unter 19 Personen) | „ein Gast“ (nur Fassung) |

Alle drei Pflicht-Auslöser bleiben bei jeder Personenzahl erreichbar: (a) über PM3 und WM9, (b) über Lejla oder die Karte unter ihrem Streifen, (c)
über die Taschenkontrolle (Marek oder beim Detektiv, MECH §4.6) und WE3.

#### RK 2.12 Absatz für Teil 90, „Die Rollen am Tisch“ (**wörtlich**, Vorlesen, P5-M2)

„Ahmet hatte von allen Miete eingesammelt, obwohl der Keller nichts kostete. Mit dem Geld wollte er die viel zu große
Essensrechnung bezahlen. Beim Scheppern kauerte er hinter der Theke am Ostende, und Marek spürte ihn die ganze Zeit.“

### RK 3 · Rolle 2: Fatma (Fassung JM3) – unschuldig

#### RK 3.1 Profil

| Feld | Inhalt |
|---|---|
| Platz | 2, immer besetzt, Verdächtige |
| Alter, Beruf | 26, Kommunikationsdesign im letzten Semester; Abschlussarbeit über alte Münzbilder |
| Merkmal | beerenroter Wollmantel, schwere Umhängetasche aus Leder, breiter Silberring rechts |
| Farbe | Beerenrot |
| Beziehungen (WELT §1.3) | Emine beste Freundin seit der 5. Klasse (Versprechen zu schweigen) · Azra aus der Unibibliothek (erzählte von der Schatulle) · Ahmet eine Klasse über ihr · Olli trug ihre Umzugskisten |
| Geheimnis | hat um 23:40 die Münzschatulle aus der schon gesprungenen Vitrine ausgeliehen (Abzeichnen, Rückgabe Montag) |
| Ziel (Kanon) | Die Schatulle soll zurück, ohne dass es alle erfahren. |
| Code der Fassung | JM3 |

#### RK 3.2 Marker

| Marker | Stufe 1 (behauptet) | wahr | umstellen |
|---|---|---|---|
| 23:57 | 2 Linkes Buffet | 4a an der Theken-Klappe (ab 23:57 dort, kommt von 2) | auf 4a, sobald eine offene Karte, ein offener Streifen oder Joannas vorgetragene Liste dich an der Klappe zeigt (R-06), spätestens mit deiner Geheimniskarte |
| Scheppern | 2 Linkes Buffet | 2, kauert hinter dem linken Buffettisch neben Emine | nie |

Heft, **wörtlich**: „Marker 23:57: Linkes Buffet (2). Marker Scheppern: Linkes Buffet (2). Der erste ist gelogen. Der zweite stimmt.“

#### RK 3.3 Vorstellungsrunde

Frage des Erzählers (**wörtlich**, Vorlesetext):
> „Fatma, du hast für jede Farbe ein Lob und für jedes Muster gleich noch eins. Welche Farbe hat dieser Abend bis jetzt?“

„Dein Auftritt bei der Vorstellung“ (**wörtlich**, Vorlesetext, 70 Wörter):
> „Ganz klar: Kellergrau mit einem Hauch Kerzenrot. Ich studiere Kommunikationsdesign, letztes Semester. Mir fällt jedes Muster auf, jede Farbe, jeder schiefe Buchstabe. Wer heute ‚hübsch‘ gesagt hat, hat von mir eine kleine Farbenlehre bekommen. Gern geschehen. Ehrlich gesagt tut mir nur das grüne Notausgangsschild ein bisschen weh. Das passt zu gar nichts hier. Aber sonst? Diese alten Bögen, dieses warme Licht auf dem Stein. Die Farben hier sind einfach wunderschön.“

Anekdote: keine aus den Dias 3–5. Farbenlehre und Lieblingssatz sind Kanon (`vorstellung.fatma`, `steckbriefe.json`). Kein Wort zu
Münzen, Schatulle, Vitrine oder Turmgang (RK-18).

#### RK 3.4 „Wer du bist“ (**wörtlich**)

> „Du bist Fatma, 26, die Designstudentin. Du studierst Kommunikationsdesign, letztes Semester. Deine Abschlussarbeit handelt von alten Münzbildern. Man erkennt dich am beerenroten Wollmantel, an der schweren Umhängetasche aus Leder und am breiten Silberring an der rechten Hand. [Emine] ist seit der 5. Klasse deine beste Freundin. [Azra] kennst du aus der Unibibliothek. Ahmet war an deiner Schule eine Klasse über dir. Olli hat bei deinem Umzug die Kisten getragen.
> Was dich heute antreibt: Die Schatulle soll zurück, ohne dass es alle erfahren.“

#### RK 3.5 Wissen

| Nr | Fakt | sicher / vermutet | Quelle | Freigabe |
|---|---|---|---|---|
| 1 | 23:40 Schatulle ausgeliehen, Ecke gebrochen, Splitter am rechten Ärmel; Emine sah es und versprach zu schweigen | sicher | WELT §3.3 | nach der Karte |
| 2 | Azra hat ihr von der Schatulle erzählt | sicher | WELT §3.2 | nach der Karte |
| 3 ★ | 23:56 Herr Schneider leise: „Die Schatulle. Um Punkt zwölf geh ich raus und ruf die Polizei.“ Emine hörte es | sicher | WELT §5.6 | nach der Karte |
| 4 ★ | 23:54 tuschelte sie mit Emine am linken Buffet über die Tasche; auf die Klappe achteten beide nicht | sicher | WELT §3.4 | nach der Karte |
| 5 ★ | 23:57 ging Ahmet mit einem dicken Umschlag am Ostende hinter die Theke | sicher | WELT §3.4, §0.2 | nach der Karte (Domino) |
| 6 ★ | Von der Klappe sah sie um 23:57 Olli am Eiskübel vor Herrn Schneider stehen; Worte hörte sie nicht. Dann ging Herr Schneider hinter der Theke zur Kaffeemaschine, nicht zu ihr | sicher | WELT §5.5, RK-09 | nach dem Marker |
| 7 ★ | Beim Knall ging sie zurück und kauerte neben Emine; Flüstern; beim Scheppern war sie dort | sicher | WELT §5.3 | sofort |
| 8 ★ | Um 23:45 holte Zeynep am linken Buffet Gebäck. Fehlt Zeynep, steht hier: Um 23:56 ging Herr Schneider von ihrem Buffet zum Ostende | sicher | WELT §3.3, §3.4 | sofort |
| 9 ★ | Kurz vor zwölf hat sie Can im Buffetsaal nirgends gesehen. Um 23:54 achtete sie nicht auf die Theken-Klappe (P3R2-03) | sicher | WELT §3.4 | sofort |
| 10 | Die Scheibe hatte schon vor ihr einen Sprung | sicher | WELT §3.3 | nach der Karte |
| 11 | Can hat sich kurz vor zwölf nirgends blicken lassen | vermutet | Gespräch | – |
| 12 | Wer im Dunkeln bei Herrn Schneider war, hatte vielleicht auch Ärger mit ihm | vermutet | aus Nr. 3 | – |

Was Fatma **nicht** weiß: wer das leuchtende Gesicht war; was an der Vorratsraumtür geschah; wo der Bund ist; dass Zeynep die
Tasche bemerkt hat; dass Can sie um 23:54 sah.

#### RK 3.6 Stufe 1 (Heft Seite 2)

Kernsätze, **wörtlich**: „Ich stand die ganze Zeit beim Gebäck am linken Buffet.“ · „In meiner Tasche sind nur Bücher.“

| Wenn jemand fragt | sagst du (wörtlich) | wahr? |
|---|---|---|
| Wo warst du um drei vor zwölf? | „Am linken Buffet, beim Gebäck. [Emine] war bei mir.“ | gelogen |
| Wo warst du um 23:51 Uhr? | „Am linken Buffet beim Gebäck. [Emine] war bei mir.“ | wahr |
| Wo warst du beim Knall und beim Scheppern? | „Ich hab mich hinter den linken Buffettisch gekauert, neben [Emine]. Ich hab geflüstert: ‚[Emine]? Ich bin's, Fatma.‘ Bis das Licht anging, war ich da.“ | wahr |
| Was hast du im Dunkeln gehört? | „Den Knall, dann ‚Hab ich dich!‘, zweimal ‚Stehen bleiben!‘ und das Scheppern. Gesehen hab ich nichts.“ | wahr |
| Was wollte Herr Schneider an deinem Buffet? | „Er hat geschimpft, wie immer. Worüber, weiß ich nicht mehr.“ | gelogen |
| Wer stand um drei vor zwölf an der Theke? | „Da war viel los. So genau hab ich nicht hingeschaut.“ | gelogen (du hältst Olli zurück, sonst verrätst du die Klappe) |
| Was hängt da an deinem Ärmel? | „Keine Ahnung. Irgendwo hängen geblieben.“ | gelogen |

Regie, **wörtlich** (P5-K3): „Bleib dabei freundlich und ein bisschen abgelenkt, wie jemand, der nur Farben im Kopf hat.“
„Wenn der Erzähler fragt“: Tabelle 1.8, Spalte Fatma.

Markersatz: Wenn der Marker fällt, bevor die Karte offen ist (R-06, „Ortslügen fallen vor Geheimnissen“), **wörtlich**:
> „Muss dein Marker ‚23:57‘ auf die Klappe, bevor deine Karte offen ist: Stell ihn um und sag: ‚Ja, ich war kurz an der Klappe. Ich wollte Herrn Schneider etwas fragen. Dann kam der Knall.‘ Ab dann darfst du sagen, dass du von der Klappe aus Olli am Eiskübel gesehen hast.“

#### RK 3.7 Stufe 2 (Heft Seite 2)

„Was du verbirgst“, **wörtlich**:
> „Um 23:40 Uhr hast du im Turmgang die gesprungene Scheibe der Schauvitrine angehoben und die Münzschatulle ausgeliehen. Du willst das Wappen für deine Abschlussarbeit abzeichnen und sie am Montag zurückbringen. Dabei brach die Ecke der Scheibe, Splitter blieben an deinem Ärmel. [Emine] hat es gesehen und versprochen zu schweigen. Um 23:56 Uhr drohte Herr Schneider mit der Polizei. Um 23:57 Uhr wolltest du ihm die Schatulle an der Theken-Klappe zurückgeben.“

Pflicht-Auslöser, **wörtlich**:
> „Du drehst deine Geheimniskarte sofort um, wenn einer dieser drei Fälle eintritt:
> (a) Sobald die Indizkarte „Fatma: Taschen und Kleidung“ (NN3) offen liegt.
> (b) Sobald die Schauvitrine im Turmgang (FM9) offen liegt und dein Marker ‚23:57‘ schon auf der Theken-Klappe steht.
> (c) Sobald [Emines] Geheimniskarte offen liegt.
> Du darfst sie auch am Ende jeder Runde freiwillig umdrehen.“

Variante (c), wenn Emine fehlt, **wörtlich**: „(c) Sobald die Geheimniskarte unter dem Zeugenstreifen am linken Buffettisch offen liegt.“

„Was du dann sagst“, **wörtlich**: „Lies ‚Was ich zugebe‘ von deiner Karte vor. Sag dann den Satz unter ‚Und noch etwas‘. Leg nach: ‚Am Montag bring ich sie zurück. Versprochen.‘“

Marker: „23:57“ auf 4a, falls er dort noch nicht steht.

„Ab dann“, **wörtlich**:
> „Ab jetzt sagst du offen, was du an der Klappe wolltest. Du darfst sagen, dass Herr Schneider dir um 23:56 Uhr mit der Polizei gedroht hat und dass [Emine] es gehört hat. Die Schatulle zeigst du, wenn jemand fragt. Sie bleibt in deiner Tasche, bis Herr Schneider sie nimmt. Mehr gibst du nicht zu. Dabei bleibst du.“

#### RK 3.8 Geheimniskarte Fatma (Innenseite **wörtlich**)

> **Was ich zugebe**
> „Um 23:40 Uhr hab ich im Turmgang die Münzschatulle aus der Vitrine ausgeliehen. Die Scheibe hatte schon einen Sprung. Ich wollte das Wappen abzeichnen, für meine Abschlussarbeit. Am Montag bring ich sie zurück. Um 23:56 Uhr hat Herr Schneider die Splitter an meinem Ärmel gesehen. Um 23:57 Uhr wollte ich ihm die Schatulle an der Theken-Klappe zurückgeben.“ (57 Wörter, P5-K9)
>
> **Für den Ermittlungsbogen**
> „Heimlichtuerei · Fatma: hat um 23:40 die Münzschatulle aus der Vitrine ausgeliehen, um das Wappen abzuzeichnen. Rückgabe am Montag.“
> „Ort um 23:57 · Fatma: an der Theken-Klappe.“
>
> **Und noch etwas**
> „Um 23:57 Uhr ging Ahmet mit einem dicken Umschlag am Ostende hinter die Theke.“

Wirkung: Druck auf Ahmet; zusammen mit WE3 Anlass für eine Taschenkontrolle (Ahmets Auslöser c, MECH §11.2).

#### RK 3.9 Gesprächsaufträge

| Runde | Ziel | Zielrolle | Frage (wörtlich) | Nachschlag (wörtlich) | Ausweichziel (wörtlich) |
|---|---|---|---|---|---|
| 1 | 1 | Can | „Can, dein Marker steht auf der Turm-Toilette. Wann bist du hoch, und wer hat dich gehen sehen?“ | „Sobald jemand sagt, dass Can um drei vor zwölf nirgends zu sehen war: ‚Nirgends? Dann sag uns, wer dich auf der Treppe gesehen hat.‘“ | – (immer besetzt) |
| 1 | 2 | Emine | „Emine, sag dem Detektiv, wer sich gleich nach dem Knall neben dich gekauert hat.“ | „Sobald Emine es bestätigt: ‚Und war ich noch neben dir, als es schepperte?‘“ | „Bitte den Detektiv um den Ortstermin ‚linker Buffettisch‘. Sag: ‚Dort hab ich gekauert. Wer dort war, kann es bezeugen.‘ Bis dahin frag Olli: ‚Olli, du sagst, du saßt im Ost-Saal. Wer hat dich dort beim Knall gesehen?‘“ |
| 2 | 1 | Ahmet | „Ahmet, ich hab dir 150 € Miete gegeben, wie alle. Wie viel hat der Keller denn gekostet? Hast du eine Quittung von Herrn Schneider?“ | „Sobald deine Geheimniskarte offen liegt: ‚Um drei vor zwölf bist du mit einem dicken Umschlag am Ostende hinter die Theke. Was war da drin?‘“ | – |
| 2 | 2 | Zeynep | „Zeynep, du hast um Viertel vor zwölf bei mir am linken Buffet Gebäck geholt. Für wen? Und wo warst du danach?“ | „Sobald jemand sagt, dass Can um drei vor zwölf nirgends war: ‚Zeynep, du kennst deinen Bruder. Wo war er?‘“ | Can: „Can, um fünf vor zwölf sollten alle in den Ost-Saal, zur blinden Kuh und zur Torte. Du bist nicht gekommen. Warum nicht?“ |
| 3 | 1 | Olli | „Olli, wo warst du, als es schepperte? Und wer hat dich dort gespürt oder gehört?“ | „Sobald Ollis Marker am Eiskübel steht: ‚Vom Eiskübel sind es nur ein paar Meter bis zur Vorratsraumtür. Wer kann sagen, dass du dort geblieben bist?‘“ | – |
| 3 | 2 | Marek | „Marek, du standst hinter der Theke, als die Kerzen noch brannten. Was hast du an der Vorratsraumtür gesehen?“ | „Sobald dein Marker ‚23:57‘ auf der Klappe steht: ‚Ich war um drei vor zwölf an der Klappe, aber beim Knall bin ich sofort zurück. Hast du danach an der Klappe noch jemanden gesehen?‘“ | „Bitte den Detektiv, den Messingkerzenständer und den Vorratsraum zu untersuchen. Sag: ‚Dort lag Herr Schneider. Da muss man zuerst hinschauen.‘ Bis dahin frag Can: ‚Can, Herr Schneider hat eine Kapuze erwischt. Wo war deine, als es schepperte?‘“ |

Was die Ziele treiben: R1 Cans Ortslüge (D10, Joannas „nirgends“) und Fatmas Alibi (M2); R2 Ahmets Heimlichtuerei (Domino zu
Ahmet) und Zeynep zu Can; R3 Ollis Weg zur Tür (D3) und Mareks zweite Gestalt (D12). Fatmas eigene Frage an Marek ist riskant
für sie: Die zweite Gestalt kam „von der Klappe her“. Emines Alibi entlastet sie (WELT §5.3). Das ist gewollte Spannung.

#### RK 3.10 Seite 4

„Was du bei dir trägst“, **wörtlich**: „Über der Schulter trag ich meine schwere Umhängetasche aus Leder. Darin: Skizzenblock, Stifte und die Münzschatulle. An meinem rechten Mantelärmel hängen feine Glassplitter.“ (Taschenkontrolle: NN3, frei ab Runde 2.)

Aktionskarte (MECH §4.4, **wörtlich**): **Gegenfrage** · Wirkung: „Spiel sie, wenn dir eine Frage gestellt wird. Zuerst beantwortet die fragende Person eine Frage von dir. Dann antwortest du.“ · Grenzen: wie Einspruch („Nicht gegen Ortstermine, Indizkarten oder Karten, die offen liegen. Was offen liegt, bleibt liegen. Ein Satz, der eine Karte auslöst, gilt trotzdem. Die Frage darf später wiederkommen.“) · ab Runde 1.

Tipp, **wörtlich**: „Spiel sie, wenn jemand nach deiner Tasche fragt. Stell zuerst deine Frage, am besten nach dem Geld oder nach der Turm-Toilette.“

Bonus-Ziel, **wörtlich**: „**Dein Bonus-Ziel:** Du sagst selbst, was du verbirgst, bevor man es dir beweist. **Erfüllt, wenn** du deine Geheimniskarte am Ende einer Runde freiwillig umgedreht hast (reinen Tisch), bevor einer deiner drei Sobald-Fälle eingetreten ist.“ (1.6)

#### RK 3.11 Wenn Rollen fehlen

| fehlt | was sich bei Fatma ändert |
|---|---|
| Lejla | nichts |
| Emine (6 Personen) | „deine beste Freundin“; Flüstern „Ich bin's, Fatma.“; Alibi über den Zeugenstreifen Emine (RH3, Zeitstempel); Auslöser (c) über die Karte unter dem Streifen (ab Runde 2 mit FM9 oder NN3); R1 Ziel 2 → Ausweichziel |
| Tim, Joanna | Namen entfallen („zur Kaffeemaschine“, „die Fotografin des Abends“) |
| Marek (6–10 Personen) | R3 Ziel 2 → Ausweichziel |
| Zeynep (6–11 Personen) | „jemand“; Wissen Nr. 8 wird im Heft ersetzt durch „Um 23:56 Uhr ist Herr Schneider von unserem Buffet zum Ostende gegangen.“, damit es drei Einträge „sofort“ bleiben (P14-K05); R2 Ziel 2 → Ausweichziel |
| Azra (unter 17 Personen) | „eine Bekannte aus der Unibibliothek“ |

Alle drei Pflicht-Auslöser bleiben erreichbar: (a) NN3 (Untersuchung oder Taschenkontrolle), (b) FM9 plus Marker (Joannas Liste oder
FX3), (c) Emine oder die Karte unter ihrem Streifen.

#### RK 3.12 Absatz für Teil 90, „Die Rollen am Tisch“ (**wörtlich**, Vorlesen, P5-M2)

„Fatma hatte um zwanzig vor zwölf die Münzschatulle ausgeliehen, um das Wappen abzuzeichnen. An der Theken-Klappe wollte sie
sie zurückgeben. Beim Scheppern kauerte sie schon hinter dem linken Buffettisch neben Emine.“

### RK 4 · Rolle 3: Olli (Fassung RN7) – der Täter

Das Rollenheft (vorab sendbar) enthält **nichts**, woraus man die Tat lesen kann (MECH §10.4). Es ist so gebaut, als wäre Olli
unschuldig. Ollis Stufe-2-Satz „geduckt“ steht dort ohne Hinweis, dass er gelogen ist. Was wirklich geschah, steht nur in RN7
(Abschnitt 7.5).

#### RK 4.1 Profil

| Feld | Inhalt |
|---|---|
| Platz | 3, immer besetzt, Verdächtiger und Täter |
| Alter, Beruf | 28, Lagerlogistiker, hilft bei jedem Umzug |
| Merkmal | grauer Kapuzenpulli, dunkelblaue Daunenweste, rechter Arbeitshandschuh hängt aus der Westentasche |
| Farbe | Marineblau und Khaki |
| Beziehungen (WELT §1.3) | Tim Kumpel aus der Berufsschule (trug mit, gab das Wachs, hält zu Olli) · Ahmet Banknachbar · Fatma (trug ihre Umzugskisten) · Can Sportverein, Can filmt |
| Geheimnis (Heft) | Bogentür 18:35 beschädigt, Schramme mit Möbelwachs überdeckt; Herr Schneider verlangt 2.000 € bis Mitternacht; 23:57 am Eiskübel |
| Tat (nur RN7) | WELT §3.4 23:58:10 bis 23:58:55, §7.1 |
| Ziel (Kanon, Heft) | Den Türschaden selbst mit Herrn Schneider klären, ohne die Gruppe hineinzuziehen. |
| Ziel (RN7) | Unentdeckt bleiben, ohne einen Unschuldigen ins Unglück zu stürzen. |
| Code der Fassung | RN7 |

#### RK 4.2 Marker

| Marker | Stufe 1 (behauptet) | Stufe 2 (behauptet) | wahr | umstellen |
|---|---|---|---|---|
| 23:57 | 1 Ost-Saal | 4b vor der Theke mit Eiskübel | 4b am Eiskübel | mit der Geheimniskarte auf 4b |
| Scheppern | 1 Ost-Saal | 4b („am Eiskübel geduckt“) | 4c vor der Vorratsraumtür | mit der Geheimniskarte auf 4b; mit Stufe 3 (Anklage) auf 4c |

Heft, **wörtlich**: „Marker 23:57: Ost-Saal (1). Marker Scheppern: Ost-Saal (1). Beide sind gelogen.“ Die Umstellung auf 4c steht
nur in RN7.

#### RK 4.3 Vorstellungsrunde

Frage des Erzählers (**wörtlich**, Vorlesetext; A:72 sinngemäß ohne Ziffern):
> „Olli, du bist der Mann fürs Grobe bei jedem Umzug. Warum bist du heute schon um Viertel nach acht fast in die Mitternachtstorte gefallen?“

„Dein Auftritt bei der Vorstellung“ (**wörtlich**, Vorlesetext, 78 Wörter), mit der Anekdote aus Dia 4 (Verlaufen, 20:15):
> „Also, das war so. Ich such das Klo. Ich nehm die Tür neben der Anrichte, und auf einmal steh ich im Dunkeln vor der Mitternachtstorte. Ich stoß ans Regal. Hinter mir ruft jemand: ‚Einbrecher an der Torte!‘ Dann leuchtet mir einer mit der Taschenlampe mitten ins Gesicht. Und ich sag nur: ‚Ich wollte nur aufs Klo!‘ Der Torte geht's gut, ehrlich. Und wer beim nächsten Umzug mit anpackt, kriegt die ganze Geschichte. Die dauert länger als der Umzug.“

Quelle: WELT §3.3 20:15, Kanon `intro.lacher.lacher_verlaufen.besetzt`. Azra und Wojtek bleiben namenlos („jemand“, „einer“),
damit der Text bei jeder Besetzung gleich bleibt (RK-18). Kein Wort zu Tür, Schaden, Wachs oder Herrn Schneider.

#### RK 4.4 „Wer du bist“ (**wörtlich**)

> „Du bist Olli, 28, der Anpacker. Du bist Lagerlogistiker und hilfst bei jedem Umzug. Man erkennt dich am grauen Kapuzenpulli und an der dunkelblauen Daunenweste. Aus der Westentasche hängt dein rechter Arbeitshandschuh. [Tim] ist dein Kumpel aus der Berufsschule, ihr schraubt zusammen an alten Fahrrädern. Ahmet war in der Schule dein Banknachbar. Für Fatma hast du beim Umzug die Kisten getragen. Mit Can bist du im Sportverein, und er filmt eure Spiele.
> Was dich heute antreibt: Den Schaden an der Bogentür willst du selbst mit Herrn Schneider klären, ohne die Gruppe hineinzuziehen.“

#### RK 4.5 Wissen

Spalte „wo“: H = steht im Heft, F = steht nur in RN7.

| Nr | Fakt | sicher / vermutet | wo | Quelle | Freigabe |
|---|---|---|---|---|---|
| 1 | 18:30 trug er mit Tim die Warmhaltebehälter; 18:35 Beschlag ausgerissen; 18:45 Möbelwachs von Tim; 18:50 Forderung 2.000 €, Tore zu | sicher | H | WELT §3.3 | nach der Karte; woher das Wachs kam, sagt Olli nie |
| 2 | 23:00 lauter Streit, „Bis Mitternacht. Sonst ruf ich die Polizei!“; Tim hörte es | sicher | H | WELT §5.6 | nach der Karte |
| 3 | 23:52 zu Tim: „Ich hol dir Eis. Und dann red ich mit Schneider.“ | sicher | H | WELT §3.4 | nach der Karte |
| 4 ★ | 23:55 hängte Ahmet im Ost-Saal seine Jacke auf, einen dicken Umschlag in der Hand | sicher | H | RK-04 | sofort |
| 5 ★ | Gleich als das Licht anging, brachte er Tim Eis aus dem Eiskübel | sicher | H | WELT §3.4, W-20 | sofort |
| 6 ★ | 18:30 drohte Herr Schneider Marek, den Lieferwagen abschleppen zu lassen | sicher | H | WELT §5.6 | sofort |
| 7 ★ | 23:57 sagte Herr Schneider leise zu ihm: „Zweitausend, bis zwölf.“ Ahmet stand hinter der Theke am Ostende | sicher | H | WELT §3.4 | nach der Karte |
| 8 ★ | Nach dem Knall sprang ein leuchtendes Gesicht aus dem Vorratsraum, Herr Schneider packte es | sicher | H | WELT §5.2 | nach der Karte (Domino) |
| 9 | Das Gesicht riss sich los und rannte dicht an ihm vorbei durch die Klappe, **bevor** er zur Vorratsraumtür ging. Wer darunter steckte, erkannte er nicht | sicher | F | WELT §3.4, RK-12 | nie (RN7) |
| 10 | Die Tat, der Bund unter dem Eis, die Spuren an Ärmel und Handschuh | sicher | F | WELT §3.4, §6 | nur Stufe 3 |
| 11 | Der linke Handschuh liegt seit 19:30 in der Kamin-Nische; er hat ihn vergessen | sicher | F | WELT §3.3 | nie |
| 12 | Wer unter der leuchtenden Maske steckte, war vielleicht an der Vorratsraumtür | vermutet (Heft-Fassung seiner Geschichte) | H | Stufe 2 | nach der Karte |

#### RK 4.6 Stufe 1 (Heft Seite 2)

Kernsätze, **wörtlich**: „Ich saß die ganze Zeit am Kopf der Tafel im Ost-Saal.“ · „Als das Licht anging, hab ich [Tim] Eis gebracht.“
Regie, **wörtlich** (Kanon `taeter-olli.json` „tarnung“, neutral): „Bleib dabei locker und ein bisschen müde, wie jemand, der den ganzen Abend gesessen hat.“

| Wenn jemand fragt | sagst du (wörtlich) | wahr? |
|---|---|---|
| Wo warst du um drei vor zwölf? | „Am Kopf der Tafel im Ost-Saal. Gleich gibt's Torte, hab ich gedacht.“ | gelogen |
| Wo warst du um 23:51 Uhr? | „An der Bogentür im Kaminsaal, bei [Tim]. Er hat sich den Finger eingeklemmt. Ich hab gesagt, ich hol ihm Eis.“ | wahr |
| Wo warst du beim Knall und beim Scheppern? | „Sitzen geblieben. Im Dunkeln rennt man nicht rum.“ | gelogen |
| Wer saß bei dir? | „Weiß ich nicht genau. Die blinde Kuh saß irgendwo mit Augenbinde. Es war ja dunkel.“ | ausweichend |
| Woher hattest du das Eis? | „Aus dem Eiskübel an der Theke, gleich als das Licht anging. [Tim] hatte sich den Finger eingeklemmt.“ | wahr |
| Was hast du mit Herrn Schneider zu tun? | „Der meckert über alles. Über mich auch mal.“ | ausweichend |
| Was ist mit deinem Handschuh? | „Mein Arbeitshandschuh. Ich hab heute beim Ausladen geholfen. Rote Tropfen? Keine Ahnung.“ | erst wahr, dann gelogen (P2-17: gilt, solange deine Karte zu ist) |

Markersatz, **wörtlich** (P5-K3): „Deine Marker fallen nur mit deiner Karte. Dann stellst du beide auf den Eiskübel.“
„Wenn der Erzähler fragt“: Tabelle 1.8, Spalte Olli.

Ein umgestellter Marker vor der Karte kommt bei Olli nicht vor: Alles, was seinen Marker widerlegt, ist Pflicht-Auslöser.

#### RK 4.7 Stufe 2 (Heft Seite 2)

„Was du verbirgst“, **wörtlich**:
> „Um 18:35 Uhr hast du beim Tragen der Warmhaltebehälter die geschnitzte Bogentür geschrammt. Ein Beschlag ist aus der gekalkten Wand gerissen. [Tim] hat dir braunes Möbelwachs gegeben, und du hast die Schramme damit überdeckt. Um 18:50 Uhr verlangte Herr Schneider 2.000 € in Bargeld bis Mitternacht. Um 23:00 Uhr drohte er mit der Polizei. Um 23:57 Uhr standst du am Eiskübel. Du wolltest Eis für [Tim] holen und mit Herrn Schneider reden.“

Pflicht-Auslöser (MECH §4.2, A:95), **wörtlich**:
> „Du drehst deine Geheimniskarte sofort um, wenn einer dieser drei Fälle eintritt:
> (a) Sobald [Joanna] vor allen aus ihrer Notiz von 23:57 Uhr vorliest, dass du am Eiskübel standst.
> (b) Sobald [Lejla] vor allen sagt oder ihr Zeugenstreifen zeigt, dass du erst nach dem Scheppern zu ihr an den rechten Buffettisch kamst.
> (c) Sobald Ahmet oder Fatma vor allen sagen, dass du um 23:57 Uhr am Eiskübel standst.
> Du darfst sie auch am Ende jeder Runde freiwillig umdrehen.“

Varianten: Joanna fehlt: „(a) Sobald der Zeugenstreifen an der Tür zum Ost-Saal offen liegt.“ · Lejla fehlt: „(b) Sobald der Zeugenstreifen am rechten Buffettisch zeigt, dass du erst nach dem Scheppern dorthin kamst.“

„Was du dann sagst“, **wörtlich**:
> „Lies ‚Was ich zugebe‘ von deiner Karte vor. Sag dann den Satz unter ‚Und noch etwas‘. Leg nach: ‚Beim Knall hab ich mich am Eiskübel geduckt. Dann ist das leuchtende Gespenst aus dem Vorratsraum auf Herrn Schneider los. Dann hat es gescheppert. Ich bin zu [Lejla] gekrochen.‘“

Variante, wenn Lejla fehlt: Der letzte Satz lautet „Ich bin zum rechten Buffettisch gekrochen.“

Marker: beide auf 4b.

„Ab dann“, **wörtlich**:
> „Ab jetzt sagst du offen, was an der Bogentür war. Sag immer ‚das Gespenst‘ oder ‚das leuchtende Gesicht‘, nie einen Namen. Fragt jemand, wer es war: ‚Erkannt hab ich nur das Leuchten.‘ Woher das Möbelwachs kam, sagst du nicht. Mehr gibst du nicht zu. Dabei bleibst du.“

Prüfung W-25 und MECH M-15: Der Satz „geduckt“ steht nur im Heft und wird nur gesagt. Die Karte enthält nur Wahres. „Erkannt hab
ich nur das Leuchten“ ist wahr (RK-12). Kein Name als Lüge.

#### RK 4.8 Geheimniskarte Olli (Innenseite **wörtlich**)

> **Was ich zugebe**
> „Um 18:35 Uhr hab ich beim Tragen der Warmhaltebehälter die Bogentür geschrammt. Ein Beschlag ist aus der gekalkten Wand gerissen. Die Schramme hab ich mit braunem Möbelwachs überdeckt. Herr Schneider verlangt 2.000 € bis Mitternacht. Um 23:57 Uhr stand ich am Eiskübel. Ich wollte Eis für einen eingeklemmten Finger holen und mit Herrn Schneider reden.“ (55 Wörter, kein Name einer Rolle 5–10)
>
> **Für den Ermittlungsbogen**
> „Heimlichtuerei · Olli: hat um 18:35 an der Bogentür einen Beschlag ausgerissen und die Schramme mit Möbelwachs überdeckt. Herr Schneider verlangt 2.000 € bis Mitternacht.“
> „Ort um 23:57 · Olli: am Eiskübel.“
>
> **Und noch etwas**
> „Nach dem Knall sprang ein leuchtendes Gesicht aus dem Vorratsraum, und Herr Schneider packte es.“

Wirkung: mit JA9 Pflicht-Auslöser (c) für Can (MECH §4.2). Der Satz ist wahr: Olli sah es vom Eiskübel im Kerzenlicht (4,2 m,
Umriss und Leuchten, WELT §2.8). Die Karte sagt nichts über „geduckt“.

#### RK 4.9 Gesprächsaufträge

| Runde | Ziel | Zielrolle | Frage (wörtlich) | Nachschlag (wörtlich) | Ausweichziel (wörtlich) |
|---|---|---|---|---|---|
| 1 | 1 | Ahmet | „Ahmet, dein Marker steht hinter der Theke. Um fünf vor zwölf sollten alle in den Ost-Saal. Was hast du hinter der Theke gemacht?“ | „Sobald Ahmet ‚Servietten‘ sagt: ‚Servietten? Im Ost-Saal hattest du einen dicken Umschlag in der Hand, keine Servietten.‘“ | – (immer besetzt) |
| 1 | 2 | Tim | „Tim, ich hab dir Eis gebracht, gleich als das Licht anging. Sag dem Detektiv, wo du da warst.“ | „Sobald Tim es bestätigt: ‚Siehst du. Kaum war Licht, war ich bei dir.‘“ | Can: „Can, du sagst, du warst auf der Turm-Toilette. Bist du dafür durch den Ost-Saal gekommen? Dann hättest du mich am Kopf der Tafel sitzen sehen.“ (P14-K06) |
| 2 | 1 | Can | „Can, du drehst doch ständig lustige Videos. Hattest du für Mitternacht irgendwas vorbereitet?“ | „Sobald deine Geheimniskarte offen liegt: ‚Ich hab das leuchtende Gesicht aus dem Vorratsraum springen sehen. Can, du warst um drei vor zwölf nirgends. Wo warst du da?‘“ | – |
| 2 | 2 | Marek | „Marek, um halb sieben hat Herr Schneider gedroht, deinen Lieferwagen abschleppen zu lassen. Steht der immer noch auf seinem Platz?“ | „Sobald deine Geheimniskarte offen liegt: ‚Ich hab Ärger mit Herrn Schneider wegen der Bogentür, du wegen des Parkplatzes. Wer hier hat noch Ärger mit ihm?‘“ | Ahmet: „Ahmet, du hast bei der Ankunft von uns allen Geld eingesammelt. Wofür genau, und wo ist das Geld jetzt?“ |
| 3 | 1 | Fatma | „Fatma, wo genau warst du beim Knall? Und wer hat gehört, dass du dich nicht bewegt hast?“ | „Sobald Fatmas Marker ‚23:57‘ auf der Klappe steht: ‚Von der Klappe sind es nur ein paar Schritte bis zur Vorratsraumtür. Warum bist du beim Knall weg, und wohin?‘“ | – |
| 3 | 2 | Lejla | „Lejla, du hast nach dem Licht Herrn Schneider versorgt. Weiß er noch, wer ihn gepackt hat?“ | „Sobald deine Geheimniskarte offen liegt: ‚Sag dem Detektiv: Ich hab bei dir am rechten Buffet gekauert, bis das Licht anging.‘“ | „Frag Can: ‚Can, wo warst du, als das Licht anging?‘ Liegt deine Geheimniskarte offen, bitte außerdem den Detektiv um den Ortstermin ‚rechter Buffettisch‘ und sag: ‚Dort hab ich gekauert, bis das Licht anging.‘“ |

Was die Ziele treiben: Olli lenkt ab, ohne über einen Namen zu lügen. R1 Ahmets Umschlag (D8) und Ollis eigene Stufe 1 (Tim, W-20);
R2 Cans Heimlichtuerei (Domino zu Can, D10, D16) und Mareks Parkplatz (Nebendelikt, Druck auf Marek, der in R3 die zweite Gestalt
trägt); R3 Fatmas Klappe (falsche Fährte, die Emine auflöst) und Lejla, deren Aussage Ollis Stufe 2 stützt, aber nicht widerlegt
(WELT §5.3). Wahr ist jeder Satz außer denen, die Stufe 1 und Stufe 2 erlauben.

#### RK 4.10 Seite 4

„Was du bei dir trägst“, **wörtlich**: „In der Tasche meiner dunkelblauen Daunenweste steckt mein rechter Arbeitshandschuh. Er hängt halb heraus. Den linken hab ich heute Abend irgendwo liegen lassen.“ (Taschenkontrolle: FN3, frei ab Runde 2.)

Aktionskarte (MECH §4.4, **wörtlich**): **Themenwechsel** · Wirkung: „Spiel sie, wenn gerade über dich gesprochen wird. Das Gespräch über dich endet. Der Erzähler liest sofort einen Impuls vor, und es geht damit weiter.“ · Grenzen: „Nicht gegen Ortstermine, Indizkarten oder Karten, die offen liegen. Was offen liegt, bleibt liegen. Ein Satz, der eine Karte auslöst, gilt trotzdem. Die Frage darf später wiederkommen.“ · ab Runde 1.

Tipp, **wörtlich**: „Spiel sie, wenn das Gespräch zu lange bei dir hängt. Gegen eine Indizkarte hilft sie nicht.“

Bonus-Ziel, **wörtlich**: „**Dein Bonus-Ziel:** Du sagst selbst, was du verbirgst, bevor man es dir beweist. **Erfüllt, wenn** du deine Geheimniskarte am Ende einer Runde freiwillig umgedreht hast (reinen Tisch), bevor einer deiner drei Sobald-Fälle eingetreten ist.“ (1.6)

Hinweis für Teil 90 (nicht im Heft): Für Olli zählen Tipp-Fragen 1 und 2 nicht; er bekommt 3 Punkte, wenn der Detektiv nicht ihn
anklagt (MECH §7.2, M-22). Frage 3 (Bonus-Ziel) zählt wie bei allen.

#### RK 4.11 Wenn Rollen fehlen

| fehlt | was sich bei Olli ändert |
|---|---|
| Lejla (6 Personen) | „die Apothekerin am rechten Buffettisch“; Auslöser (b) über ihren Zeugenstreifen (DM3, Zeitstempel); Stufe-2-Satz „zum rechten Buffettisch gekrochen“; R3 Ziel 2 → Ausweichziel |
| Emine | nichts |
| Tim (6–8 Personen) | „dein Kumpel aus der Berufsschule“; R1 Ziel 2 → Ausweichziel Can (so fragt Olli in Runde 1 nicht zweimal Ahmet, P14-K06) |
| Joanna (6–9 Personen) | „die Fotografin des Abends“; Auslöser (a) über ihren Zeugenstreifen (FX3, Zeitstempel) |
| Marek (6–10 Personen) | „der Caterer“; R2 Ziel 2 → Ausweichziel |
| Zeynep | nichts |

Alle drei Pflicht-Auslöser bleiben erreichbar: (a) Joanna oder FX3/Zeitstempel ab Runde 1; (b) Lejla oder DM3/Zeitstempel ab
Runde 1; (c) Ahmets Domino-Hinweis oder Fatma nach umgestelltem Marker.

#### RK 4.12 Absatz für Teil 90, „Die Rollen am Tisch“ (**wörtlich**, Vorlesen, P5-M2)

„Olli hatte beim Tragen die Bogentür beschädigt und die Schramme mit Möbelwachs überdeckt. Um drei vor zwölf stand er am
Eiskübel und wollte mit Herrn Schneider reden. Im Dunkeln hat ihn die Panik gepackt.“

### RK 5 · Rolle 4: Can (Fassung YW4) – unschuldig

#### RK 5.1 Profil

| Feld | Inhalt |
|---|---|
| Platz | 4, immer besetzt, Verdächtiger |
| Alter, Beruf | 25, Ausbildung zum Mediengestalter, dreht lustige Kurzvideos |
| Merkmal | signalgelber weiter Kapuzenpulli mit Bauchtasche |
| Farbe | Signalgelb |
| Beziehungen (WELT §1.3) | Zeynep Schwester, zwei Jahre jünger (steht Schmiere, Mitschuld) · Ahmet hat ihm Radfahren beigebracht · Olli Sportverein, Can filmt |
| Geheimnis | Streich mit der Leuchtmaske: ab 23:54 im dunklen Vorratsraum, nach dem Knall herausgesprungen, gepackt, losgerissen, weggerannt |
| Ziel (Kanon) | Der Streich soll nicht herauskommen. |
| Code der Fassung | YW4 |

#### RK 5.2 Marker

| Marker | Stufe 1 (behauptet) | wahr | umstellen |
|---|---|---|---|
| 23:57 | 8b Wendeltreppe und Turm-Toilette | 5 Vorratsraum, direkt hinter der Tür | mit der Geheimniskarte auf 5 |
| Scheppern | 8b Wendeltreppe und Turm-Toilette | 8b, auf der Wendeltreppe | nie |

Heft, **wörtlich**: „Marker 23:57: Wendeltreppe und Turm-Toilette (8b). Marker Scheppern: Wendeltreppe und Turm-Toilette (8b). Der erste ist gelogen. Wo du beim Scheppern warst, weißt du selbst nicht genau: Im Turm hast du es nicht gehört. Lass den zweiten stehen.“

Grund: Can hört das Scheppern nicht (WELT §2.7, §5.1). Das Heft verrät ihm nicht, dass sein Alibi stimmt (RK-13). Cans Alibi
kommt nur von Tim, Marek, Zeynep oder FK3 (MECH M-14).

#### RK 5.3 Vorstellungsrunde

Frage des Erzählers (**wörtlich**, Vorlesetext):
> „Can, du drehst lustige Kurzvideos und sitzt nie lange still. Was war heute Abend dein bestes Video, und warum hat keiner gelacht?“

„Dein Auftritt bei der Vorstellung“ (**wörtlich**, Vorlesetext, 67 Wörter):
> „Mein bestes Video heute? Die Tür zum Ost-Saal. Die quietscht, wenn man sie bewegt. Also hab ich sie zwanzig Mal bewegt, ganz langsam, mit Musik. Titel: ‚Das Schloss singt.‘ Keiner hat gelacht. Also hab ich es noch mal gezeigt, nur lauter. Ich mach eine Ausbildung zum Mediengestalter und dreh nebenbei Kurzvideos. Mein Lieblingssatz: ‚Wartet, das muss ich filmen!‘ Mein zweitliebster: ‚Wartet, das muss ich noch mal filmen!‘“

Anekdote: keine aus den Dias 3–5. Quelle: Kanon „vorstellung.can“ (Witz noch einmal, nur lauter), `steckbriefe.json` („Wartet, das
muss ich filmen!“), quietschende Tür (WELT §2.2), „Bei Westwind singt das Schloss“ (MECH §9.3). Kein Wort zu Maske, Streich,
Vorratsraum oder blinder Kuh (RK-18).

#### RK 5.4 „Wer du bist“ (**wörtlich**)

> „Du bist Can, 25, der Spaßvogel. Du machst eine Ausbildung zum Mediengestalter und drehst lustige Kurzvideos. Man erkennt dich am signalgelben, weiten Kapuzenpulli mit der großen Bauchtasche. Witze reißt du auch, wenn keiner lacht. Wo etwas Lustiges passiert, hast du schon das Handy in der Hand. [Zeynep] ist deine Schwester, zwei Jahre jünger und lauter als du. Ahmet hat dir Radfahren beigebracht. Mit Olli bist du im Sportverein, und du filmst eure Spiele.
> Was dich heute antreibt: Der Streich soll nicht herauskommen.“

#### RK 5.5 Wissen

| Nr | Fakt | sicher / vermutet | Quelle | Freigabe |
|---|---|---|---|---|
| 1 | Maske am Nachmittag bemalt; ab 23:54 im dunklen Vorratsraum; Zeynep stand im Steinbogen Schmiere | sicher | WELT §3.2, §3.4 | nach der Karte |
| 2 ★ | 23:50 im Kaminsaal: Olli und Tim standen an der Bogentür; einer rief „Au! Mein Finger!“ | sicher | RK-05 | sofort |
| 3 ★ | 23:45 holte Zeynep am linken Buffet Gebäck für sie beide | sicher | WELT §3.3 | sofort |
| 4 ★ | Nach dem Licht saß er auf der Wandbank im Kaminsaal; Zeynep kam zu ihm | sicher | WELT §3.5 | sofort |
| 5 ★ | 23:54 tuschelten Fatma und Emine am linken Buffet; Fatma hielt ihre Tasche ganz fest | sicher | W-24 | nach der Karte (Domino) |
| 6 | 23:57 hörte er hinter der Tür „Nicht die alte Leiste!“; nach dem Knall „Ruhe! Ich hol die Notlaterne.“ Er dachte, die blinde Kuh wird gebracht | sicher | WELT §5.1 | nach der Karte |
| 7 ★ | Als er sich losriss, stand Herr Schneider noch und brüllte ihm „Stehen bleiben!“ hinterher | sicher | WELT §7.1 | nach der Karte |
| 8 ★ | Im Steinbogen streifte er Zeynep | sicher | WELT §2.5 | nach der Karte |
| 9 | Das Scheppern hörte er im Turm nicht; was danach an der Theke geschah, weiß er nicht | sicher | RK-13 | sofort (passt zu Stufe 1) |
| 10 | Die gelben Fasern an Herrn Schneiders Hand stammen von seiner Kapuze | sicher | WELT §6 | nach der Karte |
| 11 | Wer nach ihm zu Herrn Schneider kam, war es | vermutet | aus Nr. 7 | nach der Karte |
| 12 | Wer an der Klappe vorbeikam, hat er nicht wahrgenommen | sicher | WELT §5.7 | – |

Was Can **nicht** weiß: dass Olli an der Klappe stand; dass Tim ihn im Durchgang sah; dass Marek ihn im Kerzenlicht sah; wann
es schepperte.

#### RK 5.6 Stufe 1 (Heft Seite 2)

Kernsätze, **wörtlich**: „Ich war die ganze Zeit oben auf der Turm-Toilette.“ · „Welche Maske? Ich hab keine Maske.“ (P3-18)

| Wenn jemand fragt | sagst du (wörtlich) | wahr? |
|---|---|---|
| Wo warst du um drei vor zwölf? | „Oben auf der Turm-Toilette. Ich musste dringend, und der Weg da hoch ist weit.“ | gelogen |
| Wo warst du um 23:51 Uhr? | „Im Kaminsaal an der langen Tafel. [Zeynep] saß bei mir.“ | wahr |
| Wo warst du beim Knall und beim Scheppern? | „Immer noch oben. Da hört man gar nichts. Auf einmal war das Licht weg, und ich saß im Dunkeln.“ | halb (oben hört man wirklich nichts) |
| Wann bist du hoch, und auf welchem Weg? | „Kurz vor zwölf. Vom Kaminsaal durch die Bogentür, durch den Turmgang und die Wendeltreppe hinauf.“ | Weg wahr, Zeit gelogen |
| Wo war [Zeynep]? | „Im Kaminsaal, glaub ich. Wir haben vorher zusammen Gebäck gegessen. Frag sie selbst.“ | gelogen |
| Herr Schneider hat eine Kapuze gepackt. Deine? | „Ich war oben im Turm. Frag Herrn Schneider, ob er mein Gesicht gesehen hat.“ | ausweichend (er sah nur die Maske) |
| Was ist in deiner Bauchtasche? | „Nichts Besonderes. Krümel und ein Taschentuch.“ | gelogen |

Regie, **wörtlich** (P5-K3): „Bleib dabei albern, wie jemand, der nichts ernst nimmt.“
Markersatz, **wörtlich** (P5-K3): „Dein Marker ‚23:57‘ fällt nur mit deiner Karte. Dann stellst du ihn auf den Vorratsraum.“
„Wenn der Erzähler fragt“: Tabelle 1.8, Spalte Can.

Ein umgestellter Marker vor der Karte kommt bei Can nicht vor: Joannas „Can: nirgends!“ widerspricht der Turm-Toilette nicht.

#### RK 5.7 Stufe 2 (Heft Seite 2)

„Was du verbirgst“, **wörtlich**:
> „Am Nachmittag hast du eine weiße Gespenstermaske mit grünlich-weißer Leuchtfarbe bemalt. Ab 23:54 Uhr hast du damit im dunklen Vorratsraum gewartet. Um zwölf wolltest du die blinde Kuh erschrecken. [Zeynep] stand im Steinbogen Schmiere. Nach dem Knall dachtest du, die blinde Kuh kommt, und bist herausgesprungen. Herr Schneider hat dich an der Kapuze gepackt: ‚Hab ich dich!‘ Du hast dich losgerissen und bist auf die Turm-Toilette gerannt.“

Pflicht-Auslöser (MECH §4.2), **wörtlich**:
> „Du drehst deine Geheimniskarte sofort um, wenn einer dieser drei Fälle eintritt:
> (a) Sobald die Indizkarte „Can: Taschen und Kleidung“ (JT3) offen liegt.
> (b) Sobald [Zeyneps] Geheimniskarte offen liegt.
> (c) Sobald Herrn Schneiders rechte Hand (JA9) offen liegt und jemand vor allen gesagt hat oder eine offene Karte sagt: Das Gesicht kam aus dem Vorratsraum. Was davon zuerst da war, ist egal.
> Du darfst sie auch am Ende jeder Runde freiwillig umdrehen.“

Variante (b), wenn Zeynep fehlt, **wörtlich**: „(b) Sobald die Geheimniskarte unter dem Zeugenstreifen im Steinbogen offen liegt.“

„Was du dann sagst“, **wörtlich**: „Lies ‚Was ich zugebe‘ von deiner Karte vor. Sag dann den Satz unter ‚Und noch etwas‘. Leg nach: ‚Als ich mich losgerissen hab, stand Herr Schneider noch. Er hat mir ‚Stehen bleiben!‘ hinterhergebrüllt.‘“

Marker: „23:57“ auf 5.

„Ab dann“, **wörtlich**:
> „Ab jetzt sagst du offen, wie dein Streich lief. Du darfst sagen, dass [Zeynep] Schmiere stand und dass du sie im Steinbogen gestreift hast. Was nach deiner Flucht an der Theke geschah, weißt du nicht. Im Turm hört man nichts. Sag das ehrlich. Mehr gibst du nicht zu. Dabei bleibst du.“

#### RK 5.8 Geheimniskarte Can (Innenseite **wörtlich**)

> **Was ich zugebe**
> „Ab 23:54 Uhr hab ich mit einer Leuchtmaske im dunklen Vorratsraum gewartet. Um zwölf wollte ich die blinde Kuh erschrecken. [Zeynep stand im Steinbogen für mich Schmiere.] Nach dem Knall dachte ich, sie kommt. Ich bin rausgesprungen, und Herr Schneider hat mich an der Kapuze gepackt. Ich hab mich losgerissen und bin weggerannt, bis auf die Turm-Toilette.“ (57 Wörter mit, 50 ohne den Satz in Klammern; der Satz entfällt, wenn Zeynep fehlt, RK-10)
>
> **Für den Ermittlungsbogen**
> „Heimlichtuerei · Can: hat ab 23:54 mit einer Leuchtmaske im dunklen Vorratsraum auf die blinde Kuh gewartet. Ein Streich.“
> „Ort um 23:57 · Can: im Vorratsraum.“
>
> **Und noch etwas**
> „Um 23:54 Uhr tuschelten Fatma und Emine am linken Buffet. Fatma hielt ihre Tasche ganz fest.“
> Variante, wenn Emine fehlt (RK-10): „Um 23:54 Uhr tuschelte Fatma mit einer Freundin am linken Buffet. Fatma hielt ihre Tasche ganz fest.“

Wirkung: Druck auf Fatma (Tasche, NN3) und Emine (MECH §11.2).

#### RK 5.9 Gesprächsaufträge

| Runde | Ziel | Zielrolle | Frage (wörtlich) | Nachschlag (wörtlich) | Ausweichziel (wörtlich) |
|---|---|---|---|---|---|
| 1 | 1 | Olli | „Olli, dein Marker steht im Ost-Saal. Die blinde Kuh hatte eine Augenbinde auf. Wer außer ihr kann sagen, dass du sitzen geblieben bist?“ | „Sobald Olli sagt, er war die ganze Zeit im Ost-Saal: ‚Um zehn vor zwölf standst du an der Bogentür im Kaminsaal. Das hab ich gesehen. Was hast du da gemacht?‘“ | – (immer besetzt) |
| 1 | 2 | Zeynep | „Zeynep, sag dem Detektiv, wo du mich gesehen hast, als das Licht wieder an war.“ | „Sobald jemand fragt, warum Zeynep im Steinbogen stand: ‚Sie hat nach der blinden Kuh geschaut. Stimmt's, Zeynep?‘“ | Fatma: „Fatma, du warst kurz vor zwölf im Buffetsaal. Hast du mich da gesehen? Nein? Siehst du.“ |
| 2 | 1 | Fatma | „Fatma, du schleppst den ganzen Abend diese schwere Tasche mit dir herum. Was ist da drin, das du nicht mal beim Gebäck abstellst?“ | „Sobald deine Geheimniskarte offen liegt: ‚Um 23:54 Uhr hast du mit [Emine] am linken Buffet getuschelt und deine Tasche ganz festgehalten. Worüber habt ihr getuschelt?‘“ | – |
| 2 | 2 | Joanna | „Joanna, du hast heute ständig fotografiert. Zeig dem Detektiv, wer auf deinen letzten Fotos vor zwölf zu sehen ist.“ | „Sobald Joanna sagt, dass du um drei vor zwölf nirgends warst: ‚Nirgends heißt nicht an der Theke. Wen hast du denn an der Theke gesehen?‘“ | „Bitte den Detektiv, den Jackenständer im Ost-Saal zu untersuchen. Sag: ‚Dort hat Ahmet heute von allen Geld eingesammelt.‘ Bis dahin frag Ahmet: ‚Ahmet, du hast heute von allen Geld eingesammelt. Wo ist es jetzt?‘“ |
| 3 | 1 | Ahmet | „Ahmet, du warst hinter der Theke am Ostende, nicht weit von der Vorratsraumtür. Was hast du im Dunkeln gehört, bevor es schepperte? Und wer kann sagen, dass du dich nicht bewegt hast?“ | „Sobald der Ascheneimer am Kamin (WM9) offen liegt: ‚Der leere Umschlag im Ascheneimer trägt deine Handschrift. Was hast du nach zwölf am Kamin gemacht?‘“ | – |
| 3 | 2 | Tim | „Tim, du warst im Dunkeln im Durchgang. Was hast du gehört und gesehen, und in welcher Reihenfolge?“ | „Sobald deine Geheimniskarte offen liegt: ‚Das leuchtende Gesicht war ich. Sag dem Detektiv, ob ich vor oder nach dem Scheppern an dir vorbei bin.‘“ | „Frag Olli: ‚Olli, wo warst du, als es schepperte?‘ Liegt deine Geheimniskarte offen, bitte außerdem den Detektiv um den Ortstermin ‚im Steinbogen‘ und sag: ‚Da bin ich durchgerannt. Wer dort stand, weiß, wann.‘“ |

Was die Ziele treiben: R1 Ollis Ortslüge und die Bogentür (RK-05, Druck zu YT4) und Cans eigene Deckung; R2 Fatmas Tasche
(Domino zu Fatma) und Joannas Liste (D1, D4) oder Ahmets Geld (WE3); R3 Ahmets Weg und Umschlag (D8) und Cans eigenes Alibi über
Tim oder FK3 (D11, frühestens Runde 3, M-14). Die Fotos sind eine echte Frage: Joannas Foto von 23:51 zeigt Ahmet (WELT §6).

#### RK 5.10 Seite 4

„Was du bei dir trägst“, **wörtlich**: „In der Bauchtasche meines Pullis steckt etwas Weiches, Zusammengefaltetes: meine Leuchtmaske. Die Farbe ist noch leicht klebrig. Sonst trag ich nur mein Handy.“ (Taschenkontrolle: JT3, frei ab Runde 2.)

Aktionskarte (MECH §4.4, **wörtlich**): **Retourkutsche** · Wirkung: „Spiel sie, wenn dir jemand etwas vorwirft. Bevor du antwortest, sagt diese Person, wo sie selbst beim Scheppern war und wer das bezeugen kann.“ · Grenzen: wie Einspruch („Nicht gegen Ortstermine, Indizkarten oder Karten, die offen liegen. Was offen liegt, bleibt liegen. Ein Satz, der eine Karte auslöst, gilt trotzdem. Die Frage darf später wiederkommen.“) · ab Runde 1.

Tipp, **wörtlich**: „Spiel sie, wenn dir jemand das Gespenst vorwirft. Dann muss die Person erst selbst sagen, wo sie beim Scheppern war.“

Bonus-Ziel, **wörtlich**: „**Dein Bonus-Ziel:** Du sagst selbst, was du verbirgst, bevor man es dir beweist. **Erfüllt, wenn** du deine Geheimniskarte am Ende einer Runde freiwillig umgedreht hast (reinen Tisch), bevor einer deiner drei Sobald-Fälle eingetreten ist.“ (1.6)

#### RK 5.11 Wenn Rollen fehlen

| fehlt | was sich bei Can ändert |
|---|---|
| Lejla | nichts |
| Emine (6 Personen) | Domino-Hinweis und R2-Nachschlag mit „einer Freundin“ (RK-10) |
| Tim (6–8 Personen) | „ein Gast“ an der Bogentür (Wissen Nr. 2, Fassung); R3 Ziel 2 → Ausweichziel |
| Joanna (6–9 Personen) | R2 Ziel 2 → Ausweichziel |
| Marek | nichts im Heft; Cans Alibi kommt dann über die Karten von Tim, Zeynep und Marek unter ihren Streifen (MECH §6.3) |
| Zeynep (6–11 Personen) | „deine Schwester“; Satz in Klammern auf der Karte entfällt; Auslöser (b) über die Karte unter ihrem Streifen (FK3 oder JT3, ab Runde 3); R1 Ziel 2 → Ausweichziel |

Alle drei Pflicht-Auslöser bleiben erreichbar: (a) JT3 (Untersuchung oder Taschenkontrolle ab Runde 2); (b) Zeynep oder die Karte unter
ihrem Streifen (Runde 3); (c) JA9 (ab Runde 1) und Ollis Domino-Hinweis.

#### RK 5.12 Absatz für Teil 90, „Die Rollen am Tisch“ (**wörtlich**, Vorlesen, P5-M2)

„Can wartete mit einer Leuchtmaske im dunklen Vorratsraum, um die blinde Kuh zu erschrecken. Herr Schneider packte seine
Kapuze, doch Can riss sich los und rannte in den Turm, bevor es schepperte. Die gelben Fasern waren eine falsche Fährte.“

### ZG 0 · Grundsätze für alle sechs Zeugen

#### ZG 0.1 Regeln

| Nr | Regel | Quelle |
|---|---|---|
| G-01 | **Zeugen lügen nie.** Sie dürfen schweigen, ausweichen und halbe Wahrheiten sagen. Jeder Satz, den ein Zeugenheft vorgibt, ist wahr. | WELT §7.4 (Zeugen tragen nur „Verschweigen“), REG §6.10 |
| G-02 | Über den eigenen Ort sagen Zeugen immer die Wahrheit. Beide Marker stehen von Anfang an richtig und werden nie umgestellt. | R-01, WELT §4.2 |
| G-03 | Stufe 1 hat drei Teile: „Das sagst du jedem“ (offenes Wissen, sofort frei), „Das behältst du für dich“ (Tarnsätze auf bestimmte Fragen) und „Verboten“ (Sätze, die gelogen wären). | A:91, Z-01 |
| G-04 | Stufe 2 = Geheimniskarte umdrehen. Pflicht-Auslöser sind die Codes aus MECH §4.2 (gelten auch für fehlende Zeugen, über die Tabelle „Karten unter den Streifen“ im Erzählerheft, MECH §9.14) und die Gesprächs-Auslöser dieser Datei (nur für gespielte Zeugen). Kein Gesprächs-Auslöser umgeht eine Rundensperre. | MECH §4.2, R-03, R-04, Z-02 |
| G-05 | Wissen, das Cans Alibi stützt (das Gesicht war vor dem Scheppern weg), ist frühestens in Runde 3 frei. Das betrifft Tim, Marek und Zeynep. | M-14 |
| G-06 | Zeugen haben keine Stufe 3. Werden sie angeklagt, sagen sie nur, **wörtlich**: „Ich war es nicht.“ | MECH §8.1 Nr. 3 |
| G-07 | Nachbohr-Ziele stützen sich nur auf eigenes offenes Wissen, auf „Was alle wissen“ (MECH §1.5), auf offen liegende Karten und auf die eigene Geheimniskarte erst nach dem Umdrehen. Hängt ein Ziel vom Tischstand ab, hat es zwei Fassungen. | Z-05 |
| G-08 | Platzhalter für Rollen, die fehlen können: [Name \| Ersatz]. Der Generator setzt den Namen, wenn die Rolle gespielt wird, sonst den Ersatz. Steht hinter dem Strich nichts, entfällt der Satzteil. Zusatzrollen 11–18 heißen ungespielt nie mit Namen, sondern „ein Gast“ (WELT §1.1). **Jede gedruckte Zeile, die eine Rolle mit höherem Platz nennt, trägt einen Platzhalter.** Das gilt auch für die Tabelle „Was du weißt“, die gedruckt wird (0.6). Der Prüfer der Text-Phase vergleicht jeden Namen 5–18 in Teil 10, 12, 20 und 90 mit der Besetzung (P5-B4). | M-04, Z-06 |
| G-09 | Uhrzeiten nur aus der Kanon-Liste (WELT §0.2), nie Sekunden. Lesetexte (Heft, Karte, Streifen) schreiben „23:57 Uhr“ und „150 €“. Vorlesetexte (Frage des Erzählers, „Dein Auftritt“, Absatz für Teil 90) schreiben Uhrzeiten und Beträge in Worten, ohne Ziffern. | WELT §0.2, REG §6.5 |
| G-10 | Höchstens 25 Wörter je Satz, im Mittel höchstens 14. Wortregeln REG §6 und WELT §0.2: kein Verb des Schlagens, immer „Herr Schneider“ (bloß „Schneider“ nur in Ollis wörtlicher Rede), „in Bargeld“, „eingeklemmter Finger“, Fatma hat die Schatulle „ausgeliehen“. Kopftuch kommt nie vor. Kein eindeutiges Farbwort einer anderen Figur (REG §6.7): Zeugenhefte sagen „Cans Kapuze“, „Fatmas Mantel“, „gelb“, nie „signalgelb“ oder „beerenrot“. | REG §6 |
| G-11 | Nach dem Umdrehen gilt R-03: Was auf der Karte steht, wird nie mehr bestritten. Unter „Nach dem Umdrehen“ nennt das Heft weitere wahre Sätze, die die Person ab dann auf Nachfrage sagt. Bis zum Umdrehen gilt R-14: Wer etwas bestätigen soll, das sein Heft noch zurückhält, sagt „Dazu sag ich jetzt nichts.“ | R-03, R-14 (P145R2-M04) |
| G-12 | **Handzeichen:** Fragt jemand mit der Aktionskarte „Handzeichen“ nach etwas, das du noch zurückhalten darfst, hebst du die Hand nicht und sagst laut: „Ich enthalte mich.“ So lügt niemand mit der Hand. | MECH §4.4, P14-11, wie ZR ZG-16 |
| G-13 | Unten auf der letzten Seite jedes Zeugenhefts, **wörtlich**: „Jede Person kann [Name] spielen, egal welches Geschlecht sie hat.“ | REG §9 Nr. 25, P5-K10 |

#### ZG 0.2 Besetzungsregel für Ziele

Wer Platz k spielt, hat alle Plätze unter k am Tisch (E6). Die vier Verdächtigen sind immer da. Ein Nachbohr-Ziel braucht
deshalb nur dann ein Ausweichziel, wenn es eine Rolle mit höherem Platz nennt. Fehlt die Zielrolle, druckt der Generator
nur das Ausweichziel.

| Rolle | spielt ab Personen | sicher am Tisch | Ziele mit Ausweichziel |
|---|---|---|---|
| 5 Lejla | 7 | 1–4 | R2-2 (Marek), R3-2 (Tim) |
| 6 Emine | 8 | 1–5 | keine |
| 7 Tim | 9 | 1–6 | R1-2 (Zeynep), R3-2 (Marek) |
| 8 Joanna | 10 | 1–7 | R3-2 (Zeynep) |
| 9 Marek | 11 | 1–8 | keine |
| 10 Zeynep | 12 | 1–9 | keine |

#### ZG 0.3 Übersicht

| Platz | Rolle | Marker 23:57 / Scheppern | Domino-Stein | Sperre | Pflicht-Codes (MECH) | Gesprächs-Auslöser (nur gespielt) | Domino-Hinweis drückt auf | Aktionskarte (ab Runde) | Bonus-Ziel |
|---|---|---|---|---|---|---|---|---|---|
| 5 | Lejla | 3 / 3 | offen: Olli kam erst nach dem Scheppern (D2). Karte: Miete 0 Euro, Ahmets Umschlag (D8) | R2 | WE3, PM3, WM9 | Ahmets oder Joannas Karte offen | Olli | Krankenbesuch (1) | Ahmet scheidet aus |
| 6 | Emine | 2 / 2 | offen: Fatmas Alibi (D5). Karte: Schatulle, Drohung (D6) | R2 | FM9, NN3 | Fatmas Karte offen | Herrn Schneiders Drohungen | Kreuzverhör (1) | Fatma scheidet aus |
| 7 | Tim | 4c / 6 | Karte: Gesicht vor dem Scheppern (D11), Knall, Wachs für Olli (D13) | R3 | MR4, FK3 | in R3: direkte Frage, „das Gespenst war es“; Zeyneps Karte offen | Olli | Stirnlampe (2) | Alibi-Zeile bei drei von vier |
| 8 | Joanna | 1 / 1 | offen: Notiz 23:57 (D1, D4). Karte: Foto 23:51 (D9) | R2 | WE3, PM3, WM9 | Ahmets oder Lejlas Karte offen | Can | Zeitstempel (1) | Ort-Zeile bei allen vier |
| 9 | Marek | 4d / 4d | offen: Ahmets Alibi (D7). Karte: Gesicht und zweite Gestalt (D11, D12) | R3 | XD3, JT3 | Cans Karte offen; in R3: direkte Frage, „das Gespenst war es“ | Tim | Taschenkontrolle (2) | Ahmets Heimlichtuerei belegt |
| 10 | Zeynep | 6 / 6 | offen: Fatmas Tasche. Karte: Schmiere, Cans Alibi (D10, D11) | R3 | FK3, JT3 | Cans Karte offen; in R3: direkte Frage, „Can oder das Gespenst war es“ | Tim | Gelbe Karte (1) | Can scheidet aus |

#### ZG 0.4 Antworten auf die Moderationsimpulse (Stufe 1, solange die eigene Karte zu ist)

Die Impulse stehen in MECH §9.9. Jede Antwort ist wahr. Sie steht so im jeweiligen Heft unter „Wenn der Erzähler fragt“.

| Impuls | Lejla | Emine | Tim | Joanna | Marek | Zeynep |
|---|---|---|---|---|---|---|
| I-1.1 (ein Verdächtiger nennt dich als Zeugen für 23:57) | „Ahmet stand hinter der Theke am Ostende. Am Eiskübel stand jemand, aber ich hab nicht hingeschaut, wer.“ Sonst: „Das hab ich nicht gesehen.“ | Bei Fatma: „Frag Fatma selbst. Ich sag dir, was ich sicher weiß: Beim Scheppern war sie neben mir.“ Sonst: „Ich hab nur auf Fatma geachtet.“ | Bei Ahmet: „Ja. Um drei vor zwölf ist Ahmet zwei Meter neben mir am Ostende hinter die Theke.“ Sonst: „Um drei vor zwölf stand ich mit dem Rücken zur Theke an der Kaffeemaschine. Bestätigen kann ich da keinen.“ (P3R2-05) | liest den Eintrag dieser Person aus ihrer Notiz vor | Bei Ahmet: „Ahmet stand neben mir.“ Sonst: „Ich hatte den Rücken zur Theke.“ | „Ich stand im Steinbogen und hab vor allem in den Kaminsaal geschaut. Bestätigen kann ich da keinen.“ |
| I-1.2 Wer war neben dir? | „Beim Knall niemand. Beim Scheppern auch niemand. Erst danach ist Olli zu mir gekrochen.“ | „Gleich nach dem Knall hat Fatma sich neben mich gekauert und geflüstert: ‚Emine? Ich bin's, Fatma.‘“ | „Neben mir stand niemand. Ich hab am Sicherungskasten den Hauptschalter gesucht.“ | „Ich war am Handykorb im Ost-Saal und hab im Dunkeln nach meinem Handy gesucht.“ | „Ahmet. Er hat sich an meine Beine gekauert und geflüstert: ‚Marek? Ich bin's, Ahmet.‘“ | „Neben mir stand niemand. Ich hab mich im Steinbogen an den Pfeiler gedrückt.“ |
| I-1.3 Dem Ruf nicht gefolgt | „Ich. Ich hab am rechten Buffet die Warmhaltebehälter zugedeckt.“ | „Ich. Ich bin am linken Buffet geblieben.“ | „Ich. Um zwölf sollte es Tortenkaffee geben, ich stand an der Kaffeemaschine.“ | „Ich hab doch selbst gerufen. Dann stand ich in der Tür zum Ost-Saal und hab notiert, wer fehlt.“ | „Ich. Ich hab hinter der Theke die Saftkrüge für die Torte gefüllt.“ | „Ich. Ich stand im Steinbogen und hab nach der blinden Kuh Ausschau gehalten.“ |
| I-2.1 Geld | „Ich hab Ahmet meine 150 € gegeben, wie alle. Über fremdes Geld red ich nicht.“ | „Ich hab Ahmet meine 150 € gegeben, wie alle. Ich schulde niemandem etwas.“ | „150 € an Ahmet, wie alle. Ich schulde niemandem etwas.“ | „150 € an Ahmet, wie alle. Ich schulde niemandem etwas.“ | „Auch ich hab Ahmet 150 € ‚Miete‘ gegeben. Übers Geschäft red ich nicht beim Essen.“ | „150 € an Ahmet, wie alle. Ich schulde niemandem etwas.“ |
| I-2.2 Turmgang und Bogentür | „Dazu weiß ich nichts.“ | „Ich war vor zwölf oben auf der Turm-Toilette.“ | „Um zehn vor zwölf hab ich mir an der schweren Bogentür den Finger eingeklemmt.“ | „Dazu weiß ich nichts.“ | „Um halb sieben haben Olli und Tim mein Essen durch den Turmgang reingetragen.“ | „Um zehn vor zwölf standen Olli und Tim an der Bogentür. Tim hat ‚Au! Mein Finger!‘ gerufen.“ |
| I-2.3 Das Gesicht | „Ich hab kein Gesicht gesehen. Ich hab am rechten Buffet gekauert.“ | „Ich hab nichts gesehen. Ich hab hinter dem linken Buffettisch gekauert.“ | „Ich stand am Sicherungskasten im Durchgang.“ | „Ich war im Ost-Saal. Von da sieht man die Theke im Dunkeln nicht.“ | „Ich stand hinter der Theke am Ostende.“ | „Ich stand im Steinbogen.“ |
| I-3.1 Was kam zuerst? (Runde 3) | „Erst der Knall. Dann die Rufe von Herrn Schneider. Dann das Scheppern. Erst danach kam Olli zu mir.“ | „Erst der Knall. Gleich danach kam Fatma zu mir. Dann die Rufe, dann das Scheppern.“ | Gesprächs-Auslöser: Karte umdrehen | „Im Ost-Saal: Knall, Rufe, Scheppern. Im Dunkeln, kurz bevor das Licht wieder anging, hab ich mit der Handylampe die Tafel abgeleuchtet. Der Kopf der Tafel war leer.“ | Gesprächs-Auslöser: Karte umdrehen | Gesprächs-Auslöser: Karte umdrehen |
| I-3.3 Nach dem Licht | „Ich bin zu Herrn Schneider gelaufen. Das Kühlpack hab ich aus dem Erste-Hilfe-Kasten im Regal geholt.“ | „Ich hab nichts geholt und nichts weggebracht.“ | „Ich hab das Licht eingeschaltet. Dann hat Olli mir Eis in einer Serviette gebracht.“ | „Ich hab die Handylampen angemacht. Später kamen alle Handys aus dem Korb zurück.“ | „Ich hab die Tür zum Vorratsraum aufgemacht, drinnen Licht gemacht und Herrn Schneider gefunden.“ | „Ich bin zu Can auf die Wandbank im Kaminsaal.“ |

Die übrigen Impulse (I-1.4, I-2.4, I-3.2, I-3.4) fragen nach Markern oder nach Reinem Tisch. Zeugen antworten darauf mit
ihrem offenen Wissen oder machen am Rundenende reinen Tisch (R-05), wenn die Sperre vorbei ist.

#### ZG 0.5 Antworten am Ortstermin (Indizkarten MECH §3.3)

| Ortstermin | wer antwortet | Antwort (wörtlich, Stufe 1) |
|---|---|---|
| DM3 rechter Buffettisch | Lejla | „Ich war am rechten Buffettisch. Beim Knall hab ich mich hingekauert, allein. Beim Scheppern war ich allein. Erst danach ist Olli zu mir gekrochen und hat geflüstert: ‚Lejla? Ich bin's, Olli.‘ Erkannt hab ich ihn an der Stimme.“ |
| RH3 linker Buffettisch | Emine | „Ich war hinter dem linken Buffettisch. Gleich nach dem Knall hat Fatma sich neben mich gekauert und geflüstert: ‚Emine? Ich bin's, Fatma.‘ Beim Scheppern war sie neben mir, bis das Licht anging.“ |
| WJ9 hinter der Theke am Ostende | Marek | „Ich stand hinter der Theke am Ostende. Beim Knall hat Ahmet sich an meine Beine gekauert und geflüstert: ‚Marek? Ich bin's, Ahmet.‘ Er war noch da, als es schepperte, und auch, als das Licht anging.“ |
| FX3 Tür zum Ost-Saal | Joanna | liest ihre Notiz vor (4.5), dann: „Herr Schneider sagte zu Olli: ‚Zweitausend, bis zwölf.‘ Beim Scheppern war ich am Handykorb im Ost-Saal.“ |
| AD3 Durchgang mit Sicherungskasten | Tim | „Ich stand vor dem Sicherungskasten, mit dem Gesicht zur Wand, und hab den Hauptschalter gesucht. Meine Stirnlampe lag am Boden. Um zwölf hab ich das Licht eingeschaltet.“ |
| AD3 Durchgang mit Sicherungskasten | Zeynep | „Ich stand im Steinbogen, mit dem Rücken am Pfeiler. Ich hab gewartet, bis das Licht anging.“ |
| FK3 im Steinbogen (ab Runde 3) | Zeynep, Tim | Pflicht-Auslöser: beide drehen ihre Geheimniskarte um und lesen sie vor |

#### ZG 0.6 Aufbau des Zeugenhefts (Teil 10, A4 hoch, vier Seiten; P14-17, P5-M4)

| Seite | Abschnitte (in dieser Reihenfolge, Überschriften **wörtlich**) | Wörter |
|---|---|---|
| 1 | Kopf „Rollenheft · [Name] · Platz [Nr]“ · „Dein Auftritt bei der Vorstellung“ (x.3) · „Wer du bist“ (Profil, Beziehungen, Haltung; Wortlaut unten) · „Deine Marker“ (Wortlaut unten) · „Was alle wissen“ (MECH §1.5, gleich lautend) | 50–70 · 60–90 · 15–25 · fest |
| 2 | „Was du weißt“ (Tabelle x.4 ohne die Spalte „Quelle“; Zeilen mit „Karte“ tragen den Zusatz „erst nach dem Umdrehen“, Zeilen mit „Runde 3“ den Zusatz „frühestens in Runde 3“) · „Stufe 1“ (Das sagst du jedem · Das behältst du für dich · Verboten) · „Wenn der Erzähler fragt“ (0.4) | 150–240 · 100–170 · 80–120 |
| 3 | „Stufe 2: Wann du umdrehst“ (Sobald-Sätze) · „Was du dann zugibst“ (Innenseite der Geheimniskarte) · „Nach dem Umdrehen“ · „Deine Nachbohr-Ziele“ (Runde 1–3, je zwei; Ausweichziel nur gedruckt, wenn die Zielrolle fehlt) | 40–90 · 80–110 · 15–80 · 180–300 |
| 4 | „Was du bei dir trägst“ · „Deine Aktionskarte“ (Abbildung und Tipp) · „Dein Bonus-Ziel“ · „Wenn du angeklagt wirst: ‚Ich war es nicht.‘“ · „So spielt ihr“ (MECH §1.4, Kurzform) · Besetzungshinweis (G-13) · „Notizen“ | 15–35 · 60–85 · 40–60 · fest |

Die Spalte „Worauf du hinauswillst“ ist Arbeitshilfe und wird nicht gedruckt (P2-22). „Was du bei dir trägst“ steht in der
Ich-Form, weil die Person es vorliest (P145R2-K09).

Die Wissen-Tabellen werden gedruckt. Darum tragen alle ihre Zeilen, die eine Rolle mit höherem Platz nennen, einen Platzhalter
(G-08, P5-B4). Der Generator prüft Überlauf bei 9 pt.

**„Wer du bist“ (wörtlich, nach dem Muster RK §2.4):**

- Lejla: „Du bist Lejla, 25, Apothekerin. Das Buffet heute hast du [mit Marek |] geplant. Man erkennt dich an der türkisen Latzschürze und an deinem Abrechnungsblock. Ahmet ist dein Cousin, ihr seid Tür an Tür aufgewachsen. Du hast ihm versprochen, über seine Sorgen mit der Rechnung fürs Essen zu schweigen. [Serkan war dein Ausbilder im Erste-Hilfe-Kurs. |]
  Was dich heute antreibt: Du hältst zu Ahmet, bis er selbst redet. Aber du lügst für niemanden.“
- Emine: „Du bist Emine, 26, Grundschullehrerin. Deine Klasse bekommst du in drei Sekunden still. Man erkennt dich am olivgrünen Steppmantel und an deiner silbernen Thermoskanne mit Tee. Fatma ist seit der fünften Klasse deine beste Freundin. Heute hast du ihr versprochen zu schweigen. [Damir betreut nachmittags Kinder aus deiner Klasse. |]
  Was dich heute antreibt: Du hältst zu Fatma. Aber du lügst für niemanden.“
- Tim: „Du bist Tim, 27, Mechatroniker und Hobby-Elektriker. Wenn etwas wackelt, sagst du: Lass mal, das schau ich mir an. Man erkennt dich am karierten Flanellhemd, an der Stirnlampe um den Hals und am Spannungsprüfer-Schraubenzieher. Olli ist dein Kumpel aus der Berufsschule, ihr schraubt zusammen an alten Fahrrädern. [Wojteks Werkzeugkasten hast du dir heute geliehen. |] [Für Hana reparierst du die Motorsäge. |]
  Was dich heute antreibt: Niemand soll erfahren, dass deine alte Mehrfachsteckdose den Ausfall verursacht hat. Zu Olli hältst du, aber du lügst nicht für ihn.“
- Joanna: „Du bist Joanna, 24. Du studierst Medienwissenschaft und fotografierst Hochzeiten. Heute bist du die Fotografin des Abends. Man erkennt dich am violetten Cardigan und an deinem Handy im Handyhalter mit Aufsteckleuchte. Ahmets Stadtfeste fotografierst du. [Mit Marek machst du oft Hochzeiten: Du fotografierst, er kocht. |] [Wojteks Hausmodelle fotografierst du auch. |]
  Was dich heute antreibt: Du hältst dein Versprechen an Ahmet, ohne den Detektiv anzulügen.“
- Marek: „Du bist Marek, 28. Mit deiner Schwester führst du einen kleinen Catering-Betrieb. Das ganze Essen heute ist von euch. Man erkennt dich an der dunkelbraunen Lederjacke und am Autoschlüssel mit Anhänger. Ahmet ist dein Kunde. Mit Lejla hast du das Buffet geplant, mit Joanna machst du oft Hochzeiten. [Aylin macht deine Steuer. |]
  Was dich heute antreibt: Dein Lieferwagen soll nicht abgeschleppt werden. Und du willst dein Geld.“
- Zeynep: „Du bist Zeynep, 23. Du studierst Sport und trainierst eine Mädchenmannschaft im Fußball. Man erkennt dich am minzgrünen Pulli und an der Kappe, verkehrt herum. Can ist dein großer Bruder, zwei Jahre älter, aber lauter bist du. [Mit Sibel wohnst du in einer WG. |]
  Was dich heute antreibt: Du hältst zu Can. Aber du lügst nicht für ihn.“

Verwandtschaft steht hier nur als Tatsache; das Schweigen begründen Versprechen (Lejla, Emine, Joanna) oder Mitschuld (Tim,
Zeynep), REG §6.4. Jede Rolle nennt nur ihr eigenes Farbwort (REG §6.7).

**„Deine Marker“ (wörtlich, Feldnamen nach WELT §2.1):**

| Rolle | Markerzeile |
|---|---|
| Lejla | „Marker 23:57: Rechtes Buffet (3). Marker Scheppern: Rechtes Buffet (3). Beide stimmen.“ |
| Emine | „Marker 23:57: Linkes Buffet (2). Marker Scheppern: Linkes Buffet (2). Beide stimmen.“ |
| Tim | „Marker 23:57: Hinter der Theke: Anrichte, Vorratsraumtür (4c). Marker Scheppern: Durchgang mit Steinbogen (6). Beide stimmen.“ |
| Joanna | „Marker 23:57: Ost-Saal (1). Marker Scheppern: Ost-Saal (1). Beide stimmen.“ |
| Marek | „Marker 23:57: Theke Ostende (4d). Marker Scheppern: Theke Ostende (4d). Beide stimmen.“ |
| Zeynep | „Marker 23:57: Durchgang mit Steinbogen (6). Marker Scheppern: Durchgang mit Steinbogen (6). Beide stimmen.“ |

### ZG 1 · Lejla (Platz 5) – die Apothekerin

#### ZG 1.1 Profil

| Feld | Inhalt |
|---|---|
| Platz, Stellung | 5, Zeugin. Spielt ab 7 Personen |
| Alter, Beruf | 25, Apothekerin. Hat das Buffet geplant |
| Rollenbezeichnung | Die Apothekerin |
| Merkmal | türkise Latzschürze, Abrechnungsblock |
| Beziehungen | **Ahmet**: Cousin, Tür an Tür aufgewachsen. Sie hat ihm versprochen, nichts über die Essensrechnung zu sagen. **[Marek \| –]**: hat mit ihr das Buffet geplant. **[Serkan \| –]**: war ihr Ausbilder im Erste-Hilfe-Kurs |
| Nebendelikt | keins |
| Haltung (wörtlich im Heft) | „Du hältst zu Ahmet. Aber du lügst für niemanden.“ |
| Kanon-Ziel | Ahmet schützen, bis er selbst redet (WELT §7.2) |

#### ZG 1.2 Marker

| Marker | behauptet (Stufe 1) | wahr | Umstellen |
|---|---|---|---|
| 23:57 | 3 Rechtes Buffet | 3, am rechten Buffettisch, steht | nie |
| Scheppern | 3 Rechtes Buffet | 3, kauert allein | nie |

#### ZG 1.3 Vorstellungsrunde

- **Frage des Erzählers (wörtlich, Vorlesen):** „Lejla, die Apothekerin. Du hast heute das Buffet geplant. Gibt es den
  Nachschlag bei dir eigentlich auch auf Rezept?“
- **Dein Auftritt (wörtlich, Ich-Form):** „Ich bin Lejla, Apothekerin. In der Apotheke frage ich: Wie oft am Tag? Heute
  frage ich: Wie viele Teller? Das Buffet hab ich [mit Marek |] geplant. Ahmet ist mein Cousin, wir sind Tür an Tür groß
  geworden. Wer bei mir Nein sagt, kriegt trotzdem einen vollen Teller. Das nennt man Fürsorge.“
- Anekdote: Keine der früheren Dias 3, 4, 5 gehört Lejla (Rüstung Sibel, Verlaufen Olli, Kamin Hana; WELT D-28). Ihre
  eigene Anekdote ist der Nachschlag (Kanon `vorstellung.leyla`, `steckbriefe.json`).

#### ZG 1.4 Wissen

**Sicher** (frei ab: „offen“ = Stufe 1 sofort; „Karte“ = erst nach dem Umdrehen):

| Zeit | Was Lejla weiß | Quelle | frei ab |
|---|---|---|---|
| Wochen vorher | Ahmet steckt mit der Rechnung fürs Essen in der Klemme. Sie hat ihm Schweigen versprochen | WELT §1.3, §1.8 | Karte |
| Nachmittag | In Herrn Schneiders Büro wollte er eine Genehmigung für das mitgebrachte Essen sehen. Auf seinem Klemmbrett lag das Belegungsblatt der Stiftung: „Saalmiete Schlosskeller: 0 Euro“ | WELT §3.2 | Karte |
| 18:00 | Ahmet sammelt am Jackenständer von allen 150 € „Miete“ in Bargeld ein. Sie zahlt auch | WELT §3.3 | offen |
| 23:50 | deckt [mit Marek \|] im Ost-Saal Tortenteller und Gläser | WELT §3.4 | offen |
| 23:55 | geht an den rechten Buffettisch und deckt die Warmhaltebehälter zu | WELT §3.4 | offen |
| 23:57 | Ahmet schlüpft mit einem dicken Umschlag am Ostende hinter die Theke | WELT §3.4, §5.5 | Karte (nur der Ort ohne Umschlag ist offen, er steht auf Ahmets Marker) |
| 23:57 | Am Eiskübel stand jemand. Sie hat nicht hingeschaut, wer | WELT §5.5 | offen |
| 23:57 | Herr Schneider ruft laut: „Nicht die alte Leiste!“ | WELT §5.6 | offen |
| 23:58 | Knall. Sie kauert sich allein hin. Sie hört „Hab ich dich!“, zweimal „Stehen bleiben!“ und das Scheppern | WELT §5.1 | offen |
| nach dem Scheppern | Jemand kriecht zu ihr und flüstert: „Lejla? Ich bin's, Olli.“ Vorher war niemand neben ihr | WELT §5.3 | offen (D2) |
| 0:00 | Licht. Olli steht neben ihr auf und geht als Erstes zum Eiskübel | WELT §3.4, W-20, Z-08 | offen |
| 0:00 | „Hier liegt Herr Schneider!“ Sie eilt als Apothekerin in den Vorratsraum | WELT §3.4 | offen |
| 0:01 | Herr Schneider kommt zu sich: dicke Beule, Gedächtnislücke. Sie holt das Kühlpack aus dem Erste-Hilfe-Kasten im Regal | WELT §3.5, W-19 | offen |
| 0:02 | Herr Schneider: „Mein Schlüsselbund! Der ist weg!“ | WELT §3.5 | offen |

**Vermutet:** Mit der „Miete“ will Ahmet die Essensrechnung bezahlen (stimmt, WELT §1.8). Olli war vor dem Scheppern
woanders; wo, weiß sie nicht. Die Gedächtnislücke von Herrn Schneider nach einer Beule ist normal (Apothekerin).

**Weiß nicht:** wer am Eiskübel stand; was zwischen Knall und Scheppern an der Theke geschah; wie hoch Ahmets
Nachzahlung ist; dass der Bund im Eiskübel liegt.

#### ZG 1.5 Stufe 1

**Das sagst du jedem (wörtlich):**
- „Ab kurz vor zwölf war ich am rechten Buffettisch und hab die Warmhaltebehälter zugedeckt.“
- „Beim Knall hab ich mich hingekauert, allein.“
- „Beim Scheppern war ich allein. Erst danach ist Olli zu mir gekrochen und hat geflüstert: ‚Lejla? Ich bin's, Olli.‘“
  (Kernsatz WELT §5.3)
- „Als das Licht anging, ist Olli als Erstes zum Eiskübel.“
- „Für Herrn Schneider hab ich das Kühlpack aus dem Erste-Hilfe-Kasten geholt. Er hat eine dicke Beule. An die Sekunden
  vor dem Scheppern erinnert er sich nicht.“

**Das behältst du für dich (wörtlich):**

| Wenn jemand fragt | sagst du |
|---|---|
| wo Ahmet kurz vor zwölf war | „Ahmet stand hinter der Theke am Ostende. Was er da wollte, frag ihn selbst.“ |
| ob Ahmet etwas in der Hand hatte | „Frag Ahmet.“ |
| nach der Miete oder dem Geld | „Ahmet hat kassiert. Frag ihn, wofür.“ |
| ob du etwas über Ahmet weißt | „Ich hab Ahmet etwas versprochen. Über seine Sachen redet er selbst.“ (P5-B5) |
| was Herr Schneider am Nachmittag von dir wollte | „Er wollte eine Genehmigung fürs mitgebrachte Essen sehen.“ |

**Verboten:** „Die Miete war echt.“ · „Ahmet hatte nichts in der Hand.“ · „Ich weiß nichts über das Geld.“

#### ZG 1.6 Stufe 2

**Rundensperre:** frühestens Runde 2.

**Wann du umdrehst (wörtlich im Heft):**
1. „Sobald die Indizkarte WE3, PM3 oder WM9 offen auf dem Tisch liegt.“ (MECH)
2. „Sobald Ahmets Geheimniskarte offen auf dem Tisch liegt.“ (Z-04)
3. „Sobald Joannas Geheimniskarte offen auf dem Tisch liegt.“ (Z-04, nur wenn Joanna gespielt wird)
4. „Liegt eins davon schon in Runde 1 offen, drehst du zu Beginn von Runde 2 um.“

**Geheimniskarte, Innenseite (wörtlich):**

> **Was ich zugebe**
> „Ich hab Ahmet versprochen, über seine Sorgen zu schweigen. Aber das hier stimmt. Am Nachmittag sah ich in Herrn
> Schneiders Büro sein Klemmbrett. Darauf stand: ‚Saalmiete Schlosskeller: 0 Euro‘. Und um 23:57 Uhr ist Ahmet mit einem
> dicken Umschlag am Ostende hinter die Theke geschlüpft. Ich hab es vom rechten Buffet aus gesehen.“
>
> **Für den Ermittlungsbogen**
> „Heimlichtuerei · Ahmet: Der Keller hat nichts gekostet. Auf Herrn Schneiders Klemmbrett stand ‚Saalmiete Schlosskeller: 0 Euro‘.“
> „Ort um 23:57 · Ahmet: hinter der Theke am Ostende, mit einem dicken Umschlag.“
>
> **Und noch etwas**
> „Als das Licht anging, ist Olli als Erstes zum Eiskübel, noch bevor jemand ‚Hier liegt Herr Schneider!‘ rief.“ (P2-06)

**Nach dem Umdrehen** sagst du auf Nachfrage außerdem (wörtlich): „Ahmet steckt mit der Rechnung fürs Essen in der Klemme.“ ·
„Ich glaube, mit der ‚Miete‘ wollte Ahmet die Rechnung fürs Essen bezahlen. Fragt ihn.“ (als Vermutung kenntlich, wahr nach WELT §1.8)

#### ZG 1.7 Nachbohr-Ziele

| Runde | Nr | Ziel | Frage oder Vorwurf (wörtlich) | Worauf du hinauswillst | Ausweichziel |
|---|---|---|---|---|---|
| 1 | 1 | Olli | „Olli, dein Marker steht im Ost-Saal. Aber beim Scheppern war ich am rechten Buffet allein. Erst danach bist du zu mir gekrochen: ‚Lejla? Ich bin's, Olli.‘ Wo warst du vorher?“ Stell diese Frage vor allen. Ruf dafür den Erzähler. | Ollis Pflicht-Auslöser (b), sein Marker fällt (P2-16) | – |
| 1 | 2 | Can | „Can, Herr Schneider hat im Dunkeln ein leuchtendes Gesicht an einer Kapuze gepackt. Deine Kapuze ist die auffälligste im Keller, und für einen Spaß bist du immer zu haben. Wo warst du, als um fünf vor zwölf alle in den Ost-Saal sollten?“ | Druck auf Cans Marker; lenkt von Ahmet ab | – |
| 2 | 1 | Ahmet | Karte zu: „Ahmet, du hast heute von allen Geld eingesammelt. Sag selbst, wofür es wirklich ist, bevor es jemand anders tut.“ Karte offen: „Ahmet, jetzt liegt es auf dem Tisch. Sag allen, wofür das Geld war. Dann glaubt man dir auch den Rest.“ | Ahmet macht reinen Tisch (M4); dein Bonus-Ziel | – |
| 2 | 2 | Marek | „Marek, Ahmet sagt, er hat sich beim Knall an deine Beine gekauert. Stimmt das? Dann sag es laut, damit es alle hören.“ | Ahmets Alibi (M1) für dein Bonus-Ziel | Olli: „Olli, um elf ist Herr Schneider an der Theke laut geworden. Ging es da um dich?“ (Ollis Heimlichtuerei, M7) |
| 3 | 1 | Olli | Olli in Stufe 2: „Olli, du sagst, du hast dich beim Knall am Eiskübel geduckt. Von da bis zu mir sind es ein paar Schritte. Warum kamst du erst nach dem Scheppern? Und als das Licht anging, bist du als Erstes zurück zum Eiskübel.“ Olli noch in Stufe 1: „Olli, du warst nicht im Ost-Saal. Du warst bei mir, aber erst nach dem Scheppern. Wo warst du davor?“ | Druck auf Ollis Stufe 2; lenkt den Detektiv zum Eiskübel (PP9) | – |
| 3 | 2 | Tim | „Tim, du warst beim Scheppern im Durchgang am Sicherungskasten. Ist da im Dunkeln etwas an dir vorbei? Sag es jetzt, vor allen.“ | Tims Gesprächs-Auslöser in Runde 3; Cans Alibi (M3) | Can: „Can, Herr Schneider hat dem Gespenst zweimal ‚Stehen bleiben!‘ hinterhergebrüllt. Wenn du es warst: Wohin bist du gerannt, und wann?“ |

#### ZG 1.8 Aktionskarte (wörtlich, MECH §4.4)

| Feld | Text |
|---|---|
| Kopf | „Aktionskarte · Lejla“ |
| Name | **Krankenbesuch** · ab Runde 1 · Klasse Frage |
| Wirkung | „Du gehst zu Herrn Schneider und stellst ihm zwei Fragen. Der Erzähler antwortet mit den passenden Sätzen aus ‚Herr Schneider antwortet‘. Liegt JA9 noch zu, legt der Erzähler sie offen hin, ohne dass der Detektiv eine Untersuchung verbraucht.“ (P14-K15) |
| Grenzen | „Herr Schneider weiß nichts nach ‚Hab ich dich!‘. Über Geld und Ärger der Gäste sagt er nur: ‚Das kläre ich mit den Leuten selbst.‘“ |
| Fuß | „Einmal im Spiel. Danach umdrehen.“ |
| Tipp im Heft (nicht auf der Karte) | „Gut in Runde 1 oder 2. Frag ihn, wo er um drei vor zwölf stand und was nach dem Knall war. Das hilft dem Detektiv beim Lageplan.“ |

#### ZG 1.9 Was du bei dir trägst (für die Taschenkontrolle, wörtlich)

„In der Schürzentasche: mein Abrechnungsblock mit Notizen zum Buffet und ein Kugelschreiber. Mein Handy hab ich seit
kurz nach zwölf zurück.“

#### ZG 1.10 Bonus-Ziel und fehlende Rollen

- **Wörtlich:** „**Dein Bonus-Ziel:** Du hältst zu Ahmet, bis feststeht, dass er es nicht war. **Erfüllt, wenn** Ahmet bei
  der Anklage auf dem Ermittlungsbogen als ausgeschieden steht: Alibi ✓ und Heimlichtuerei ✓.“
- Hinweis im Heft (wörtlich): „Ahmet scheidet nur aus, wenn auch sein Geheimnis auf dem Tisch liegt. Schützen heißt hier:
  ihm helfen, selbst damit herauszurücken.“
- Prüfbarkeit: Ahmet ist immer besetzt. Alibi über Marek, Mareks Streifen oder Damir; Heimlichtuerei über PM3, WM9,
  Ahmets oder Lejlas Karte. Erreichbar bei 7 bis 20 Personen.

| fehlt | Folge für Lejla |
|---|---|
| Marek | Auftritt ohne „mit Marek“; R2-2 wird zum Ausweichziel Olli |
| Tim | R3-2 wird zum Ausweichziel Can |
| Joanna | Gesprächs-Auslöser 3 entfällt |
| Serkan | Beziehung entfällt |
| ihre Aktionskarte | Fehlt Lejla selbst, spielt der Detektiv „Krankenbesuch“ (MECH §4.6) |

#### ZG 1.11 Zeugenstreifen Lejla (Abwesenheitsblatt, bei 6 Personen)

| Feld | Inhalt |
|---|---|
| Ort auf dem Lageplan | neben dem Markerfeld „3 Rechtes Buffet“; darunter verdeckt Lejlas Geheimniskarte |
| Streifen aufdecken | DM3 (ab Runde 1) oder beim „Zeitstempel“ nennt jemand Lejla als Zeugin |
| Geheimniskarte aufdecken | nur über die Tabelle „Karten unter den Streifen“ (MECH §9.14): sobald WE3, PM3 oder WM9 offen liegt, egal wodurch; frühestens Runde 2 |

**Etikett (wörtlich):**
> „Zeugenstreifen · Lejla, die Apothekerin · Zone 3, rechter Buffettisch.
> Umdrehen, wenn der Detektiv DM3 zieht oder beim ‚Zeitstempel‘ jemand Lejla als Zeugin nennt.
> Darunter liegt Lejlas Geheimniskarte. Wann sie umgedreht wird, weiß der Erzähler.“

**Protokoll (wörtlich):**
> „Zeugenprotokoll Lejla, Apothekerin. Ab kurz vor zwölf war ich am rechten Buffettisch und hab die Warmhaltebehälter
> zugedeckt. Beim Knall hab ich mich hingekauert, allein. Beim Scheppern war ich allein. Erst danach ist Olli zu mir
> gekrochen und hat geflüstert: ‚Lejla? Ich bin's, Olli.‘ Als das Licht anging, bin ich zu Herrn Schneider gelaufen. Er
> hat eine dicke Beule.“

**Vermerk (wörtlich, MECH):** „Alibi beim Scheppern · Olli: nicht am rechten Buffettisch. Er kam erst nach dem Scheppern dorthin.“ (P5-K11)

Eine Schlusszeile gibt es nicht (P14-02, P14-05).

#### ZG 1.12 Absatz für Teil 90, „Die Rollen am Tisch“ (wörtlich, Vorlesen)

„Lejla kauerte allein am rechten Buffettisch. Sie wusste sicher, dass Olli erst nach dem Scheppern zu ihr kam. Für Ahmet
schwieg sie über das Klemmbrett, auf dem für den Keller null Euro Miete stand.“

### ZG 2 · Emine (Platz 6) – die Grundschullehrerin

#### ZG 2.1 Profil

| Feld | Inhalt |
|---|---|
| Platz, Stellung | 6, Zeugin. Spielt ab 8 Personen |
| Alter, Beruf | 26, Grundschullehrerin |
| Rollenbezeichnung | Die Grundschullehrerin |
| Merkmal | olivgrüner Steppmantel, silberne Thermoskanne mit Tee |
| Beziehungen | **Fatma**: beste Freundin seit der 5. Klasse. Emine hat ihr Schweigen versprochen. **[Damir \| –]**: betreut nachmittags Kinder aus ihrer Klasse |
| Nebendelikt | keins |
| Haltung (wörtlich im Heft) | „Du hältst zu Fatma. Aber du lügst für niemanden. Wie in der Schule: der Reihe nach, und nur, was stimmt.“ |
| Kanon-Ziel | Fatma nicht verraten (WELT §7.2) |

#### ZG 2.2 Marker

| Marker | behauptet (Stufe 1) | wahr | Umstellen |
|---|---|---|---|
| 23:57 | 2 Linkes Buffet | 2, hinter dem linken Buffettisch, steht | nie |
| Scheppern | 2 Linkes Buffet | 2, kauert, Fatma neben ihr | nie |

#### ZG 2.3 Vorstellungsrunde

- **Frage des Erzählers (wörtlich, Vorlesen):** „Emine, die Grundschullehrerin. Du bringst jeden Morgen zwanzig Kinder in
  drei Sekunden zur Ruhe. Wie lange brauchst du für diese Clique?“
- **Dein Auftritt (wörtlich, Ich-Form):** „Ich bin Emine, Grundschullehrerin. Meine Klasse ist in drei Sekunden still.
  Diese Clique hab ich noch nie still erlebt. Meine silberne Thermoskanne ist immer dabei, mit meinem eigenen Tee. Fatma
  ist seit der fünften Klasse meine beste Freundin. Damals half sie mir in Kunst und ich ihr in Mathe. So machen wir das
  bis heute.“
- Anekdote: keine der Dias 3–5 (WELT D-28). Eigene: die stille Klasse (Kanon `vorstellung.emine`).

#### ZG 2.4 Wissen

**Sicher:**

| Zeit | Was Emine weiß | Quelle | frei ab |
|---|---|---|---|
| 18:00 | zahlt 150 € „Miete“ an Ahmet | WELT §3.3 | offen |
| 23:40 | kommt im Turmgang die Wendeltreppe von der Toilette herunter. Fatma hebt die gesprungene Scheibe der Vitrine an und nimmt die Münzschatulle. Die Ecke bricht, Scherben fallen, Splitter bleiben am rechten Ärmel von Fatmas Mantel. Fatma: „Montag bring ich sie zurück. Versprochen.“ Emine verspricht zu schweigen | WELT §3.3 | Karte |
| 23:50 | hinter dem linken Buffettisch, Fatma beim Gebäck | WELT §3.4 | offen |
| 23:54 | tuschelt mit Fatma über die Tasche; achtet nicht auf die Theken-Klappe | WELT §3.4 | offen, dass sie tuschelten; Inhalt Karte |
| 23:56 | Herr Schneider bei Fatma. Er sieht die Glassplitter und sagt leise: „Die Schatulle. Um Punkt zwölf geh ich raus und ruf die Polizei.“ | WELT §3.4, §5.6 | Karte |
| 23:57 | Fatma geht mit der Tasche zur Theken-Klappe. Emine schaut nur auf Fatma | WELT §3.4, §5.5 | nach dem Umdrehen (Z-07) |
| 23:57 | Herr Schneider ruft laut: „Nicht die alte Leiste!“ | WELT §5.6 | offen |
| 23:58 | Knall. Sie kauert sich hin. Gleich danach kauert Fatma neben ihr: „Emine? Ich bin's, Fatma.“ Dann die Rufe, dann das Scheppern. Fatma bleibt bis zum Licht | WELT §5.3 | offen (D5) |

**Vermutet:** Fatma wollte um 23:57 die Schatulle an Herrn Schneider zurückgeben (stimmt, WELT §7.1). Herr Schneider hat
heute noch anderen gedroht (stimmt; alle wissen, dass er um elf an der Theke laut wurde).

**Weiß nicht:** wer am Eiskübel stand; was an der Theke nach dem Knall geschah; seit wann die Scheibe gesprungen war.

#### ZG 2.5 Stufe 1

**Das sagst du jedem (wörtlich):**
- „Ab kurz vor zwölf stand ich hinter dem linken Buffettisch.“
- „Gleich nach dem Knall hat Fatma sich neben mich gekauert und geflüstert: ‚Emine? Ich bin's, Fatma.‘ Beim Scheppern war
  sie neben mir.“ (Kernsatz WELT §5.3)
- „Sie blieb neben mir, bis das Licht anging.“

**Das behältst du für dich (wörtlich):**

| Wenn jemand fragt | sagst du |
|---|---|
| wo Fatma um drei vor zwölf war | „Frag Fatma selbst. Ich sag dir, was ich sicher weiß: Beim Scheppern war sie neben mir.“ |
| wenn du bestätigen sollst, dass Fatma um drei vor zwölf bei dir war | „Dazu sag ich jetzt nichts. Beim Scheppern war sie neben mir.“ (R-14, P145R2-M04) |
| was in Fatmas Tasche ist | „Fatmas Tasche ist Fatmas Sache.“ |
| worüber ihr getuschelt habt | „Unter Freundinnen tuschelt man. Worüber, bleibt unter uns.“ |
| ob du im Turmgang warst | „Ich war vor zwölf oben auf der Turm-Toilette.“ |
| ob Herr Schneider bei euch war | „Ja, kurz. Was er wollte, soll Fatma erzählen.“ |

**Verboten:** „Fatma war um drei vor zwölf die ganze Zeit bei mir.“ · „In Fatmas Tasche sind nur Bücher.“ · „Ich hab im
Turmgang nichts gesehen.“

#### ZG 2.6 Stufe 2

**Rundensperre:** frühestens Runde 2.

**Wann du umdrehst (wörtlich im Heft):**
1. „Sobald die Indizkarte FM9 oder NN3 offen auf dem Tisch liegt.“ (MECH)
2. „Sobald Fatmas Geheimniskarte offen auf dem Tisch liegt.“ (Z-04)
3. „Liegt eins davon schon in Runde 1 offen, drehst du zu Beginn von Runde 2 um.“

**Geheimniskarte, Innenseite (wörtlich):**

> **Was ich zugebe**
> „Um 23:40 Uhr kam ich im Turmgang die Wendeltreppe herunter. Da hob Fatma die Scheibe der Vitrine an und nahm die
> Münzschatulle. Sie sagte: ‚Montag bring ich sie zurück.‘ Ich hab versprochen zu schweigen. Um 23:56 Uhr sah Herr
> Schneider Glassplitter an ihrem Mantel. Er sagte: ‚Die Schatulle. Um Punkt zwölf geh ich raus und ruf die
> Polizei.‘“
>
> **Für den Ermittlungsbogen**
> „Heimlichtuerei · Fatma: Um 23:40 nahm Fatma die Münzschatulle aus der Vitrine. Sie sagte: ‚Montag bring ich sie zurück.‘“
>
> **Und noch etwas**
> „Um elf ist Herr Schneider an der Theke laut geworden. Mit wem, hab ich vom Ost-Saal aus nicht gesehen.“ (P3-11)

**Nach dem Umdrehen** sagst du (wörtlich):
- gleich nach dem Domino-Hinweis, in die Runde: „Wem hat Herr Schneider heute noch gedroht?“
- auf Nachfrage: „Um drei vor zwölf ist Fatma mit der Tasche zur Theken-Klappe gegangen. Ich glaube, sie wollte die
  Schatulle zurückgeben.“

#### ZG 2.7 Nachbohr-Ziele

| Runde | Nr | Ziel | Frage oder Vorwurf (wörtlich) | Worauf du hinauswillst | Ausweichziel |
|---|---|---|---|---|---|
| 1 | 1 | Olli | „Olli, du sagst, du hast die ganze Zeit am Kopf der Tafel gesessen. Wer saß neben dir, als es knallte? Nenn mir einen Namen, der das bezeugt.“ | Ollis Stufe 1 braucht einen Zeugen, und es gibt keinen | – |
| 1 | 2 | Lejla | „Lejla, ich war am linken Buffet, du am rechten. Bei mir war Fatma, gleich nach dem Knall. Wer war beim Scheppern bei dir?“ | Lejlas offenes Wissen kommt auf den Tisch (D2); Fatmas Alibi (M2) gleich mit | – |
| 2 | 1 | Fatma | Karte zu: „Fatma, ich halte zu dir. Aber sag es selbst, bevor es eine Karte tut. Du weißt, was ich meine.“ Karte offen: „Fatma, jetzt ist es raus. Erzähl allen, warum du um drei vor zwölf zur Theken-Klappe wolltest.“ | Fatma macht reinen Tisch (M5); dein Bonus-Ziel | – |
| 2 | 2 | Olli | Sobald Ollis Geheimniskarte offen liegt: „Olli, Herr Schneider wollte zweitausend Euro von dir, bis Mitternacht. Womit hat er dir gedroht, wenn du nicht zahlst?“ Sonst: „Olli, um elf ist Herr Schneider an der Theke laut geworden. Warst du dabei?“ | dein Domino-Hinweis; Ollis Druck um Mitternacht wird sichtbar | – |
| 3 | 1 | Olli | „Olli, beim Scheppern war Fatma neben mir. Und du? Wer hat dich da gespürt oder gehört? Nenn einen Namen.“ | Ollis Stufe 2 („geduckt am Eiskübel“) hat keinen Zeugen | – |
| 3 | 2 | Can | „Can, erzähl der Reihe nach, wie in der Schule: Wo warst du beim Knall, wo beim Scheppern? Und an wem bist du dazwischen vorbei?“ | Cans Reihenfolge; nennt er Tim oder Zeynep, sind sie in Runde 3 direkt gefragt | – |

#### ZG 2.8 Aktionskarte (wörtlich, MECH §4.4)

| Feld | Text |
|---|---|
| Kopf | „Aktionskarte · Emine“ |
| Name | **Kreuzverhör** · ab Runde 1 · Klasse Frage |
| Wirkung | „Du nennst zwei Personen und eine Frage. Die zweite geht kurz außer Hörweite. Die erste antwortet. Dann kommt die zweite zurück und antwortet auf dieselbe Frage.“ |
| Grenzen | „Danach darf jede Person am Tisch eine Nachfrage an eine der beiden stellen. Lügen nach Stufe 1 bleibt erlaubt.“ |
| Fuß | „Einmal im Spiel. Danach umdrehen.“ |
| Tipp im Heft | „Gut für zwei, deren Geschichten zusammenpassen müssten. Etwa Olli und Lejla mit der Frage: ‚Wo war Olli beim Scheppern?‘“ |

#### ZG 2.9 Was du bei dir trägst (wörtlich)

„Meine silberne Thermoskanne mit Tee. Mein Handy hab ich seit kurz nach zwölf zurück.“

#### ZG 2.10 Bonus-Ziel und fehlende Rollen

- **Wörtlich:** „**Dein Bonus-Ziel:** Du hältst zu Fatma, bis feststeht, dass sie es nicht war. **Erfüllt, wenn** Fatma bei
  der Anklage auf dem Ermittlungsbogen als ausgeschieden steht: Alibi ✓ und Heimlichtuerei ✓.“
- Hinweis im Heft (wörtlich): „Fatma scheidet nur aus, wenn auch ihr Geheimnis auf dem Tisch liegt. Halt zu ihr, indem du
  ihr hilfst, es selbst zu sagen.“
- Prüfbarkeit: Fatma ist immer besetzt. Alibi über Emine selbst; Heimlichtuerei über NN3, Fatmas oder Emines Karte.

| fehlt | Folge für Emine |
|---|---|
| Marek | nichts (kein Ziel nennt ihn) |
| Damir | Beziehung entfällt |
| Emine selbst | der Detektiv spielt „Kreuzverhör“ (MECH §4.6) |

#### ZG 2.11 Zeugenstreifen Emine (bei 6 und 7 Personen)

| Feld | Inhalt |
|---|---|
| Ort auf dem Lageplan | neben dem Markerfeld „2 Linkes Buffet“; darunter verdeckt Emines Geheimniskarte |
| Streifen aufdecken | RH3 (ab Runde 1) oder beim „Zeitstempel“ nennt jemand Emine als Zeugin |
| Geheimniskarte aufdecken | nur über die Tabelle „Karten unter den Streifen“ (MECH §9.14): sobald FM9 oder NN3 offen liegt, egal wodurch; frühestens Runde 2 |

**Etikett (wörtlich):**
> „Zeugenstreifen · Emine, die Grundschullehrerin · Zone 2, hinter dem linken Buffettisch.
> Umdrehen, wenn der Detektiv RH3 zieht oder beim ‚Zeitstempel‘ jemand Emine als Zeugin nennt.
> Darunter liegt Emines Geheimniskarte. Wann sie umgedreht wird, weiß der Erzähler.“

**Protokoll (wörtlich):**
> „Zeugenprotokoll Emine, Grundschullehrerin. Ab kurz vor zwölf stand ich hinter dem linken Buffettisch. Beim Knall hab
> ich mich hingekauert. Gleich nach dem Knall hat Fatma sich neben mich gekauert und geflüstert: ‚Emine? Ich bin's,
> Fatma.‘ Beim Scheppern war sie neben mir. Sie blieb, bis das Licht anging.“

**Vermerk (wörtlich, MECH):** „Alibi beim Scheppern · Fatma: kauerte hinter dem linken Buffettisch neben Emine.“

Eine Schlusszeile gibt es nicht (P14-02, P14-05).

#### ZG 2.12 Absatz für Teil 90 (wörtlich, Vorlesen)

„Emine kauerte hinter dem linken Buffettisch. Gleich nach dem Knall kam Fatma zu ihr, und beim Scheppern war sie noch da.
Um zwanzig vor zwölf hatte Emine gesehen, wie Fatma die Münzschatulle auslieh, und sie hielt ihr Versprechen, so lange es
ging.“

### ZG 3 · Tim (Platz 7) – der Hobby-Elektriker

#### ZG 3.1 Profil

| Feld | Inhalt |
|---|---|
| Platz, Stellung | 7, Zeuge. Spielt ab 9 Personen |
| Alter, Beruf | 27, Mechatroniker, Hobby-Elektriker |
| Rollenbezeichnung | Der Hobby-Elektriker |
| Merkmal | kariertes Flanellhemd, Stirnlampe um den Hals, Spannungsprüfer-Schraubenzieher |
| Beziehungen | **Olli**: Kumpel aus der Berufsschule, sie schrauben zusammen an alten Fahrrädern. Tim hat um halb sieben mit ihm getragen und ihm um 18:45 Uhr das Möbelwachs gegeben (P3R2-07); aus dieser Mitschuld hält er zu ihm. **[Wojtek \| –]**: Tim hat sich seinen Werkzeugkasten geliehen. **[Hana \| –]**: Tim repariert ihre Motorsäge |
| Nebendelikt | Kurzschluss trotz Warnung; das Möbelwachs gegeben |
| Haltung (wörtlich im Heft) | „Du hältst zu Olli, aber du lügst nicht für ihn. Und den Knall willst du lieber niemandem erklären.“ |
| Kanon-Ziel | Niemand soll erfahren, dass seine Mehrfachsteckdose den Ausfall verursacht hat (WELT §7.2) |

#### ZG 3.2 Marker

| Marker | behauptet (Stufe 1) | wahr | Umstellen |
|---|---|---|---|
| 23:57 | 4c Hinter der Theke | 4c, an der Kaffeemaschine, Rücken zur Theke | nie |
| Scheppern | 6 Durchgang | 6, vor dem Sicherungskasten, Gesicht zur Wand | nie |

#### ZG 3.3 Vorstellungsrunde

- **Frage des Erzählers (wörtlich, Vorlesen):** „Tim, der Hobby-Elektriker. Du reparierst alles, vom Fahrrad bis zum
  Rasenmäher. Was hast du heute schon repariert, das vorher gar nicht kaputt war?“
- **Dein Auftritt (wörtlich, Ich-Form):** „Ich bin Tim, Mechatroniker. Wenn irgendwo was wackelt, sag ich: Lass mal, das
  schau ich mir an. Olli kenn ich von der Berufsschule. Seitdem schrauben wir zusammen an alten Fahrrädern. Repariert hab
  ich heute noch nichts. Aber der Abend ist ja noch jung.“
- Anekdote: keine der Dias 3–5 (WELT D-28). Eigene: der Reparierer (Kanon `vorstellung.tim`, Steckbrief-Satz „Lass mal,
  das schau ich mir an.“).

#### ZG 3.4 Wissen

**Sicher:**

| Zeit | Was Tim weiß | Quelle | frei ab |
|---|---|---|---|
| 18:00 | leiht sich Wojteks Werkzeugkasten (der Name nur, wenn Wojtek gespielt wird), um seine wackelige alte Mehrfachsteckdose zu richten. Er tut es nicht. Der Kasten steht hinter der Theke neben der Kaffeemaschine | WELT §3.3, W-11 | offen, dass er den Kasten geliehen hat; die Steckdose: Karte |
| 18:30 | Im Schlosshof droht Herr Schneider [Marek \| dem Caterer]: „Steht der um Mitternacht noch da, lass ich ihn abschleppen.“ Tim trägt mit Olli die Warmhaltebehälter durch Hoftür, Turmgang und Bogentür | WELT §3.3, §5.6 | offen |
| 18:35 | Olli schrammt die Bogentür. Ein Beschlag reißt aus der gekalkten Wand. Holzsplitter und weißer Kalk bleiben an Ollis Ärmeln | WELT §3.3 | nach dem Umdrehen |
| 18:45 | Tim gibt Olli braunes Möbelwachs aus dem Werkzeugkasten. Olli reibt es mit dem rechten Arbeitshandschuh in die Schramme und steckt den Handschuh in die Westentasche | WELT §3.3 | Karte (Domino) |
| 18:50 | Herr Schneider verlangt von Olli 2.000 € in Bargeld bis Mitternacht und schließt die Tore ab: „Keiner geht, bevor das bezahlt ist.“ | WELT §3.3 | nach dem Umdrehen |
| 20:15 | sagt beim Werkzeugkasten [zu Wojtek \| zu einem Gast]: „Olli brauchte was für eine Schramme.“ | WELT §3.3 | nach dem Umdrehen |
| 23:00 | hört an der Kaffeemaschine den Streit: „Bis Mitternacht. Sonst ruf ich die Polizei!“ | WELT §3.3, W-27 | nach dem Umdrehen |
| 23:50 | steht mit Olli vor der Bogentür, sie schauen nach der Schramme. Klemmt sich den Finger ein: „Au! Mein Finger!“ | WELT §3.4 | offen: der Finger an der Bogentür; der Grund: nach dem Umdrehen |
| 23:52 | Olli: „Ich hol dir Eis. Und dann red ich mit Schneider.“ Danach geht Olli Richtung Ost-Saal | WELT §3.4, §5.5 | „Ich hol dir Eis“ offen; ganzer Satz nach dem Umdrehen (Z-14) |
| 23:52–23:54 | Herr Schneider geht an ihm vorbei in den Turmgang, ruft dort laut: „Wer war an der Vitrine?“, und kommt zurück | WELT §3.4 | offen |
| 23:50–23:55 | Durch die Bogentür geht in dieser Zeit nur Herr Schneider | WELT §3.4, Z-08 | offen |
| 23:55 | geht durch den Steinbogen [(Zeynep steht dort) \|], den Durchgang und die Klappe zur Kaffeemaschine. Dabei sieht er Herrn Schneider zu Fatma ans linke Buffet gehen | WELT §3.4, Z-08 | offen |
| 23:57 | Ahmet schlüpft am Ostende hinter die Theke, zwei Meter neben ihm. Gleich danach geht Herr Schneider an Ahmet vorbei zu ihm | WELT §3.4, P3-23 | offen |
| 23:57 | hört hinter sich: „Zweitausend, bis zwölf.“ Dann kommt Herr Schneider vom Ostende zu ihm: „Nicht die alte Leiste!“ Tim steckt die Kaffeemaschine trotzdem ein | WELT §3.4, §5.6 | „Nicht die alte Leiste“ offen (alle hörten es); das Einstecken: Karte; „Zweitausend“: nach dem Umdrehen |
| 23:58 | Knall. Hinter ihm ruft Herr Schneider: „Ruhe! Ich hol die Notlaterne.“ (P3R2-12) Tastet sich hinter der Theke nach Westen, durch die Klappe in den Durchgang. Am Sicherungskasten rutscht ihm die Stirnlampe vom Hals. Er findet den Hauptschalter nicht | WELT §3.4 | offen |
| danach | hört „Hab ich dich!“, „Stehen bleiben!“. Rennende Schritte lassen ihn herumfahren: Ein leuchtendes Gesicht rennt einen Meter an ihm vorbei durch den Bogen in den Kaminsaal. Danach brüllt Herr Schneider noch einmal. Dann scheppert es | WELT §5.3 | Karte (Runde 3) |
| im Dunkeln, kurz vor dem Licht | findet die Stirnlampe am Boden und schaltet sie an. [Sie zeigt Zeynep im Steinbogen. \|] | WELT §3.4 | offen |
| 0:00 | schaltet die Hauptsicherung ein | WELT §3.4 | offen |
| 0:01 | Olli bringt ihm Eis in einer Serviette: „Hier, dein Eis. Hat gedauert.“ | WELT §3.4, P5-K16 | offen |

**Vermutet:** Das „Zweitausend, bis zwölf“ galt Olli (stimmt). Olli wollte um zwölf mit Herrn Schneider über das Geld
reden (stimmt). Das leuchtende Gesicht war ein Streich (stimmt; wer es war, weiß er nicht). Er hat das Gefühl, dass Olli
nicht alles sagt (Gefühl, kein Wissen).

**Weiß nicht:** wer das Gesicht war; woher es genau kam (die Klappe sieht er nicht); was an der Vorratsraumtür geschah;
wo Olli zwischen fünf vor zwölf und dem Licht war; dass der Bund im Eiskübel liegt.

#### ZG 3.5 Stufe 1

**Das sagst du jedem (wörtlich):**
- „Kurz vor zwölf stand ich hinter der Theke an der Kaffeemaschine. Um zwölf sollte es Tortenkaffee geben.“
- „Beim Knall hab ich mich im Dunkeln in den Durchgang zum Sicherungskasten getastet. Meine Stirnlampe ist mir vom Hals
  gerutscht.“
- „Beim Scheppern stand ich am Sicherungskasten und hab den Hauptschalter gesucht. Um zwölf hab ich das Licht wieder
  eingeschaltet.“
- „Gleich danach hat Olli mir Eis in einer Serviette gebracht, für meinen eingeklemmten Finger.“
- „Um zehn vor zwölf hab ich mir an der schweren Bogentür den Finger eingeklemmt.“
- „Von zehn vor zwölf bis kurz nach fünf vor zwölf stand ich an der Bogentür. Durch die Bogentür ist in der Zeit nur Herr
  Schneider gegangen.“
- „Um 23:53 Uhr rief Herr Schneider im Turmgang laut: ‚Wer war an der Vitrine?‘ Kurz danach ging er zu Fatma ans linke
  Buffet.“
- „[Als meine Stirnlampe kurz vor dem Licht wieder anging, stand Zeynep im Steinbogen. |]“

**Das behältst du für dich (wörtlich):**

| Wenn jemand fragt | sagst du |
|---|---|
| warum die Sicherung geflogen ist | „Alter Keller, alte Leitungen. Die Hauptsicherung ist geflogen, und ich hab sie wieder eingeschaltet.“ |
| ob Herr Schneider mit „Nicht die alte Leiste!“ dich meinte | „Herr Schneider ruft heute viel.“ |
| was im Durchgang an dir vorbeikam (Runde 1 und 2) | „Ich hab mit dem Gesicht zur Wand den Hauptschalter gesucht. Mehr sag ich dazu jetzt nicht.“ |
| was du mit Olli an der Bogentür gemacht hast | „Wir haben uns die alte Tür angeschaut. Dabei hab ich mir den Finger eingeklemmt. Dann ist Olli rüber Richtung Ost-Saal.“ |
| worum es um elf an der Theke ging | „Frag Herrn Schneider.“ |
| nach dem Tragen um halb sieben | „Ich hab Olli geholfen, die Warmhaltebehälter reinzutragen. Schwere Dinger.“ |
| ob du „Zweitausend, bis zwölf“ gehört hast | „Ich stand mit dem Rücken zur Theke.“ |
| nach dem Werkzeugkasten oder dem Möbelwachs | „Der Werkzeugkasten steht hinter der Theke. Ich hab ihn mir heute [von Wojtek \|] geliehen.“ |
| nur ab 17 Personen gedruckt: wenn eine offene Karte zeigt, dass du um 20:15 Uhr gesagt hast: ‚Olli brauchte was für eine Schramme.‘ | „Ja, das hab ich gesagt. Mehr dazu in der letzten Runde.“ (P14-10) |

**Verboten:** „Ich hab im Durchgang nichts gesehen.“ · „Mit dem Knall hab ich nichts zu tun.“ · „Olli war die ganze Zeit
im Ost-Saal.“ · „Ich weiß nichts über die Bogentür.“

#### ZG 3.6 Stufe 2

**Rundensperre:** frühestens Runde 3.

**Wann du umdrehst (wörtlich im Heft):**
1. „Sobald die Indizkarte MR4 oder FK3 offen auf dem Tisch liegt.“ (MECH)
2. „Sobald dich in Runde 3 jemand vor allen fragt, was im Dunkeln an dir vorbeikam. Auch ein Impuls des Erzählers, der
   alle danach fragt, zählt.“ (Z-03)
3. „Sobald in Runde 3 jemand vor allen sagt, das leuchtende Gesicht oder das Gespenst sei es gewesen.“ (Z-03)
4. „Sobald Zeyneps Geheimniskarte offen auf dem Tisch liegt.“ (Z-04, nur wenn Zeynep gespielt wird)
5. „Liegt MR4 schon in Runde 2 offen, drehst du zu Beginn von Runde 3 um.“

**Geheimniskarte, Innenseite (wörtlich):**

> **Was ich zugebe**
> „Der Knall kam aus meiner alten Mehrfachsteckdose. Herr Schneider hatte mich gewarnt: ‚Nicht die alte Leiste!‘ Ich hab
> die Kaffeemaschine trotzdem eingesteckt. Im Dunkeln stand ich dann am Sicherungskasten. Da rannte ein leuchtendes Gesicht
> an mir vorbei in den Kaminsaal. Danach brüllte Herr Schneider noch. Erst dann schepperte es an der Theke.“
>
> **Für den Ermittlungsbogen**
> „Alibi beim Scheppern · für das leuchtende Gesicht: Es rannte am Sicherungskasten vorbei in den Kaminsaal. Danach brüllte Herr Schneider noch. Erst dann schepperte es.“
> „Hinweis: Der Knall kam aus Tims alter Mehrfachsteckdose.“
>
> **Und noch etwas**
> „Das Möbelwachs aus dem Werkzeugkasten hab ich um 18:45 Olli gegeben, für eine Schramme an der Bogentür.“

**Nach dem Umdrehen** sagst du auf Nachfrage außerdem (wörtlich):
- „Um 18:35 Uhr hat Olli beim Tragen die Bogentür geschrammt. Ein Beschlag ist aus der Wand gerissen.“ (P3R2-07)
- „Um 18:50 Uhr verlangte Herr Schneider von Olli 2.000 € in Bargeld, bis Mitternacht. Dann hat er die Tore abgeschlossen:
  ‚Keiner geht, bevor das bezahlt ist.‘“
- „Um 23:00 Uhr hab ich gehört, wie er zu Olli sagte: ‚Bis Mitternacht. Sonst ruf ich die Polizei!‘“
- „Um 23:52 Uhr hat Olli zu mir gesagt: ‚Ich hol dir Eis. Und dann red ich mit Schneider.‘ Das Eis kam erst nach dem
  Licht.“
- „Um 23:57 Uhr hab ich hinter mir gehört: ‚Zweitausend, bis zwölf.‘“
- „Wer das Gesicht war, hab ich nicht erkannt. Es kam aus Richtung Buffetsaal und verschwand durch den Bogen.“

#### ZG 3.7 Nachbohr-Ziele

| Runde | Nr | Ziel | Frage oder Vorwurf (wörtlich) | Worauf du hinauswillst | Ausweichziel |
|---|---|---|---|---|---|
| 1 | 1 | Fatma | „Fatma, um 23:53 Uhr rief Herr Schneider im Turmgang: ‚Wer war an der Vitrine?‘ Kurz danach ging er zu dir ans linke Buffet. Was wollte er von dir?“ | Druck auf Fatma; lenkt den Detektiv zur Vitrine (FM9) | – |
| 1 | 2 | Zeynep | „Zeynep, als ich kurz nach fünf vor zwölf durch den Steinbogen bin, standest du schon da. Und als meine Stirnlampe kurz vor dem Licht wieder anging, standest du immer noch da. Ganz allein im Dunkeln. Auf wen hast du gewartet?“ | Druck auf Zeyneps Schmiere | Can: „Can, du sagst, du warst auf der Turm-Toilette. Von zehn vor zwölf bis kurz nach fünf vor zwölf stand ich direkt an der Bogentür. Da ist nur Herr Schneider durch. Wann bist du zum Turm hoch?“ |
| 2 | 1 | Ahmet | „Ahmet, um drei vor zwölf kam Herr Schneider vom Ostende zu mir an die Kaffeemaschine. Da hast du gestanden. Er war richtig geladen. Was hattest du mit ihm zu klären?“ | Ahmets Heimlichtuerei (M4); lenkt von deiner Leiste ab | – |
| 2 | 2 | Can | Sobald JA9 offen liegt: „Can, an Herrn Schneiders Hand hängen knallgelbe Fasern. Er hat eine Kapuze erwischt. Gelb trägt hier nur einer: du.“ Sonst: „Can, Herr Schneider hat im Dunkeln eine Kapuze erwischt. Deine ist die auffälligste im Keller. Wo war die um drei vor zwölf?“ | Druck auf Can; lenkt von Olli ab | – |
| 3 | 1 | Olli | Karte zu: „Olli, um 23:52 Uhr wolltest du mir Eis holen. Gekommen ist es erst nach dem Licht. Wo warst du so lange?“ Karte offen: „Olli, um 23:52 Uhr hast du gesagt: ‚Ich hol dir Eis. Und dann red ich mit Schneider.‘ Das Eis kam erst nach dem Licht. Was war dazwischen?“ (P3R2-06) | Druck auf Ollis Stufe 2 | – |
| 3 | 2 | Marek | „Marek, du standest am Ostende, und an der Anrichte brannten noch die Kerzen. Was hast du an der Vorratsraumtür gesehen, bevor es schepperte?“ | Mareks Gesprächs-Auslöser in Runde 3 (D11, D12) | Lejla: „Lejla, du hast Herrn Schneider nach dem Licht versorgt. Hat er gesagt, wen er im Dunkeln gepackt hat?“ (P14-K07) |

#### ZG 3.8 Aktionskarte (wörtlich, MECH §4.4)

| Feld | Text |
|---|---|
| Kopf | „Aktionskarte · Tim“ |
| Name | **Stirnlampe** · ab Runde 2 · Klasse Untersuchung |
| Wirkung | „Der Detektiv darf in dieser Runde eine Untersuchung mehr machen: vier statt drei.“ |
| Grenzen | „Nur Indizkarten, die in dieser Runde schon frei sind.“ |
| Fuß | „Einmal im Spiel. Danach umdrehen.“ |
| Tipp im Heft | „Spiel sie in Runde 2, wenn die Spuren zu Geld, Schatulle oder Kapuze noch zu sind. Oder in Runde 3, damit der Detektiv alles Wichtige noch schafft.“ |

#### ZG 3.9 Was du bei dir trägst (wörtlich)

„Um den Hals meine Stirnlampe, in der Hemdtasche mein Spannungsprüfer-Schraubenzieher. Um den eingeklemmten Finger eine
nasse Serviette. Mein Handy hab ich seit kurz nach zwölf zurück.“

#### ZG 3.10 Bonus-Ziel und fehlende Rollen

- **Wörtlich:** „**Dein Bonus-Ziel:** Du hast das Licht wieder angemacht, jetzt soll auch klar werden, wer beim Scheppern
  wo war. **Erfüllt, wenn** bei der Anklage im Ermittlungsbogen in der Zeile ‚Alibi beim Scheppern‘ bei allen vier
  Verdächtigen ein Zeichen steht, ✓ oder ✗.“ (P145R2-M07)
- Prüfbarkeit: Alle vier Zeichen brauchen meist Runde 3; Tim treibt das mit seinen Zielen und seiner Karte. Quellen bei jeder
  Besetzung ab 9 Personen: Ahmet (Marek oder Streifen Marek), Fatma (Emine), Olli ✗
  (Lejla), Can (Tims eigene Karte, Marek, Zeynep, FK3). Das Ziel belohnt Aussagen, nicht das Schützen von Olli (ABG A-231).

| fehlt | Folge für Tim |
|---|---|
| Zeynep | R1-2 wird zum Ausweichziel Can; Satz über Zeynep im Steinbogen entfällt; Gesprächs-Auslöser 4 entfällt |
| Marek | R3-2 wird zum Ausweichziel Lejla (P14-K07) |
| Wojtek, Hana | Beziehungen entfallen; „[von Wojtek \|]“ entfällt |
| Tim selbst | der Detektiv spielt „Stirnlampe“ (MECH §4.6) |

#### ZG 3.11 Zeugenstreifen Tim (bei 6 bis 8 Personen)

| Feld | Inhalt |
|---|---|
| Ort auf dem Lageplan | neben dem Markerfeld „6 Durchgang mit Steinbogen“, auf der Seite des Sicherungskastens; darunter verdeckt Tims Geheimniskarte |
| Streifen aufdecken | AD3 (ab Runde 1) oder beim „Zeitstempel“ nennt jemand Tim als Zeugen |
| Geheimniskarte aufdecken | nur über die Tabelle „Karten unter den Streifen“ (MECH §9.14): sobald MR4 oder FK3 offen liegt, egal wodurch; frühestens Runde 3 |

**Etikett (wörtlich):**
> „Zeugenstreifen · Tim, der Hobby-Elektriker · Zone 6, Durchgang am Sicherungskasten.
> Umdrehen, wenn der Detektiv AD3 zieht oder beim ‚Zeitstempel‘ jemand Tim als Zeugen nennt.
> Darunter liegt Tims Geheimniskarte. Wann sie umgedreht wird, weiß der Erzähler.“

**Protokoll (wörtlich):**
> „Zeugenprotokoll Tim, Mechatroniker. Nach dem Knall hab ich mich im Dunkeln in den Durchgang zum Sicherungskasten
> getastet. Meine Stirnlampe ist mir vom Hals gerutscht. Beim Scheppern stand ich am Sicherungskasten und hab den
> Hauptschalter gesucht. Um zwölf hab ich das Licht wieder eingeschaltet. Gleich danach hat Olli mir Eis in einer
> Serviette gebracht, für meinen eingeklemmten Finger.“

**Vermerk (wörtlich, MECH):** „Hinweis: Tim war beim Scheppern im Durchgang am Sicherungskasten.“

Eine Schlusszeile gibt es nicht (P14-02, P14-05).

#### ZG 3.12 Absatz für Teil 90 (wörtlich, Vorlesen)

„Tim steckte trotz Warnung die Kaffeemaschine in seine alte Mehrfachsteckdose, und es knallte. Am Sicherungskasten rannte
das leuchtende Gesicht an ihm vorbei, bevor es schepperte. Er hatte Olli das Möbelwachs gegeben und hielt lange zu ihm.“

### ZG 4 · Joanna (Platz 8) – die Fotografin des Abends

#### ZG 4.1 Profil

| Feld | Inhalt |
|---|---|
| Platz, Stellung | 8, Zeugin. Spielt ab 10 Personen |
| Alter, Beruf | 24, Studium der Medienwissenschaft, fotografiert Hochzeiten; heute die Fotografin des Abends |
| Rollenbezeichnung | Die Fotografin des Abends |
| Merkmal | violetter Cardigan, Handy im Handyhalter mit Aufsteckleuchte |
| Beziehungen | **Ahmet**: sie fotografiert seine Stadtfeste. Um 23:53 hat sie ihm versprochen, das Foto keinem zu zeigen. **[Marek \| –]**: Hochzeiten, sie fotografiert, er kocht. **[Wojtek \| –]**: sie fotografiert seine Hausmodelle |
| Nebendelikt | keins |
| Haltung (wörtlich im Heft) | „Du hältst dein Versprechen an Ahmet. Aber den Detektiv lügst du nicht an.“ |
| Kanon-Ziel | Ihr Versprechen an Ahmet halten, ohne den Detektiv anzulügen (WELT §7.2) |

#### ZG 4.2 Marker

| Marker | behauptet (Stufe 1) | wahr | Umstellen |
|---|---|---|---|
| 23:57 | 1 Ost-Saal | 1, in der offenen Tür zum Ost-Saal, steht | nie |
| Scheppern | 1 Ost-Saal | 1, am Handykorb, sucht ihr Handy | nie |

#### ZG 4.3 Vorstellungsrunde

- **Frage des Erzählers (wörtlich, Vorlesen):** „Joanna, die Fotografin des Abends. Wie bekommst du eine Clique aufs
  Gruppenfoto, die nie gleichzeitig am selben Ort ist?“
- **Dein Auftritt (wörtlich, Ich-Form):** „Ich bin Joanna, die Fotografin des Abends. Ich studiere Medienwissenschaft und
  fotografiere Hochzeiten. Mein Trick fürs Gruppenfoto: Ich zähle bis drei und drücke bei zwei ab. Wer sich drücken will,
  landet trotzdem im Album. Notfalls von hinten. Dann nenne ich es Kunst.“
- Anekdote: keine der Dias 3–5 (WELT D-28). Eigene: das Gruppenfoto (Kanon `vorstellung.johanna`).

#### ZG 4.4 Wissen

**Sicher:**

| Zeit | Was Joanna weiß | Quelle | frei ab |
|---|---|---|---|
| 18:00 | zahlt 150 € „Miete“ an Ahmet | WELT §3.3 | offen |
| 23:51 | fotografiert heimlich aus der Saalmitte, wie Herr Schneider und Ahmet vor der Theke streiten. Ahmet hält einen dicken Umschlag. Worte hört sie nicht. Zeitstempel 23:51 | WELT §3.4 | Karte |
| 23:53 | Ahmet: „Zeig das Foto bitte keinem.“ Sie verspricht es | WELT §3.4 | Karte (Domino) |
| 23:55 | hat als Fotografin noch ihr Handy; die anderen liegen seit dem Ratespiel um elf im Korb. Ruft an der Tür zum Durchgang: „Gruppenfoto um zwölf, mit Torte! Alle in den Ost-Saal!“ [Zeynep \| Jemand] ruft aus dem Steinbogen: „Komm gleich!“ Can sieht sie nicht. Herr Schneider kommt ihr im Durchgang entgegen | WELT §3.4 | offen |
| 23:55–23:57 | steht in der offenen Tür zum Ost-Saal und sieht den ganzen Buffetsaal | WELT §2.8, §5.4 | offen |
| 23:56 | sieht Herrn Schneider am linken Buffet bei Fatma, dann geht er zum Ostende. Worte hört sie nicht | WELT §3.4, Z-08 | offen |
| 23:57 | Olli geht an ihr vorbei aus dem Ost-Saal zum Eiskübel. Gleich danach geht Ahmet an ihr vorbei und schlüpft am Ostende hinter die Theke (P3R2-04, P2-26) | WELT §3.4, W-22 | offen |
| 23:57 | hört aus einem Meter: Herr Schneider zu Olli: „Zweitausend, bis zwölf.“ Was das heißt, weiß sie nicht | WELT §5.4, §5.6 | offen |
| 23:57 | tippt die Notiz in ihr Handy, Zeitstempel 23:57 (Wortlaut 4.5) | WELT §5.4 | offen |
| 23:57 | geht zum Handykorb, stellt ihr Handy in den Halter, Kamera auf den Ehrenplatz | WELT §3.4 | offen |
| 23:58 | Knall. Sie stößt den Halter um, ihr Handy rutscht in den Korb. Sie hört die Rufe und das Scheppern | WELT §3.4 | offen |
| im Dunkeln, kurz vor dem Licht | findet ihr Handy, macht die Aufsteckleuchte an, dann die Lampen der anderen Handys. Der Kopf der Tafel ist leer | WELT §5.4 | offen |

**Vermutet:** Auf ihrem Foto geht es um Geld (stimmt). „Zweitausend, bis zwölf“ heißt, Olli soll Herrn Schneider bis
Mitternacht Geld geben (stimmt). Can hat irgendetwas vor, weil er nirgends war (halb: ein Streich, keine Tat).

**Weiß nicht:** was Herr Schneider und Ahmet um 23:51 sagten; was im Kaminsaal und im Durchgang nach fünf vor zwölf
geschah; was nach dem Knall im Buffetsaal geschah.

#### ZG 4.5 Joannas Notiz (Kasten im Heft, wörtlich, WELT §5.4)

> „Notiz, Zeitstempel 23:57
> Gruppenfoto 0:00 – wer fehlt noch?
> Ahmet: hinter der Theke, Ostende
> Fatma: geht zur Klappe
> Olli: am Eiskübel, redet mit Herrn Schneider
> Herr Schneider: am Ostende
> Marek: Saft, hinter der Theke
> Tim: Kaffeemaschine
> Lejla: rechtes Buffet
> Emine: linkes Buffet
> Zeynep: im Bogen zum Kaminsaal, kommt gleich
> Can: nirgends!
> Kaminsaal: noch ein paar, kommen gleich“

Die Notiz nennt immer die Rollen 1–10, auch wenn sie fehlen (W-21). Im Heft steht darunter, **wörtlich**: „Diesen Kasten
liest du vor, wenn jemand fragt, wer um drei vor zwölf wo war. Lies ihn ganz vor, Zeile für Zeile. Dein Heft gibst du nicht
aus der Hand.“ (P2-23)

#### ZG 4.6 Stufe 1

**Das sagst du jedem (wörtlich):**
- „Um 23:57 Uhr stand ich in der Tür zum Ost-Saal und hab fürs Gruppenfoto notiert, wer wo ist. Hier ist meine Notiz, mit
  Zeitstempel.“ (dann den Kasten vorlesen)
- „Kurz vorher ist Olli an mir vorbei aus dem Ost-Saal zum Eiskübel. Herr Schneider hat zu ihm gesagt: ‚Zweitausend, bis
  zwölf.‘ Was das heißt, weiß ich nicht.“
- „Im Dunkeln, kurz bevor das Licht wieder anging, hab ich mit der Handylampe die Tafel abgeleuchtet. Der Kopf der Tafel war
  leer.“ (P3-04)
- „Um 23:56 Uhr stand Herr Schneider bei Fatma am linken Buffet. Danach ging er zum Ostende.“
- „Can hab ich ab fünf vor zwölf nirgends gesehen.“

**Das behältst du für dich (wörtlich):**

| Wenn jemand fragt | sagst du |
|---|---|
| ob du Ahmet fotografiert hast | „Ich hab den ganzen Abend alle fotografiert. Fotos zeig ich heute nicht.“ |
| ob du jemandem etwas versprochen hast | „Versprechen halte ich.“ |
| warum Ahmet so nervös ist | „Frag Ahmet.“ |
| was du gegen zehn vor zwölf in der Saalmitte gemacht hast | „Ich war im Buffetsaal und hab fotografiert. Das mach ich den ganzen Abend.“ |

**Verboten:** „Ich hab Ahmet nicht fotografiert.“ · „Auf meinem Handy ist nichts.“ · „Ich hab nichts gehört.“

#### ZG 4.7 Stufe 2

**Rundensperre:** frühestens Runde 2.

**Wann du umdrehst (wörtlich im Heft):**
1. „Sobald die Indizkarte WE3, PM3 oder WM9 offen auf dem Tisch liegt.“ (MECH)
2. „Sobald Ahmets Geheimniskarte offen auf dem Tisch liegt.“ (Z-04)
3. „Sobald Lejlas Geheimniskarte offen auf dem Tisch liegt.“ (Z-04)
4. „Liegt eins davon schon in Runde 1 offen, drehst du zu Beginn von Runde 2 um.“

**Geheimniskarte, Innenseite (wörtlich):**

> **Was ich zugebe**
> „Um 23:51 Uhr hab ich heimlich ein Foto gemacht. Herr Schneider und Ahmet streiten vor der Theke. Ahmet hält einen dicken
> Umschlag. Was sie sagten, hab ich nicht gehört. Das Foto ist auf meinem Handy, mit Zeitstempel. Den Detektiv lüge ich
> nicht an. Hier ist es.“
>
> **Für den Ermittlungsbogen**
> „Hinweis · Heimlichtuerei Ahmet: Foto um 23:51 Uhr. Herr Schneider und Ahmet streiten vor der Theke, Ahmet hält einen dicken Umschlag.“
>
> **Und noch etwas**
> „Um fünf vor zwölf hab ich an der Tür zum Durchgang zum Gruppenfoto gerufen. Can war weder im Buffetsaal noch im Durchgang.“ (P2-06)

**Nach dem Umdrehen** gilt (wörtlich im Heft): „Das Foto darfst du jetzt jedem beschreiben, der fragt. Mehr als die Karte
zeigt es nicht.“ Auf Nachfrage sagst du außerdem (wörtlich): „Ahmet hat mich um 23:53 Uhr gebeten, das Foto keinem zu zeigen.“

#### ZG 4.8 Nachbohr-Ziele

| Runde | Nr | Ziel | Frage oder Vorwurf (wörtlich) | Worauf du hinauswillst | Ausweichziel |
|---|---|---|---|---|---|
| 1 | 1 | Olli | „Olli, auf meiner Notiz von 23:57 Uhr steht: ‚Olli: am Eiskübel, redet mit Herrn Schneider.‘ Ich hab gehört, wie er zu dir sagte: ‚Zweitausend, bis zwölf.‘ Und im Dunkeln, kurz bevor das Licht anging, war der Kopf der Tafel leer. Wo warst du wirklich?“ Stell diese Frage vor allen. Ruf dafür den Erzähler. | Ollis Pflicht-Auslöser (a), sein Marker 23:57 fällt (P2-16) | – |
| 1 | 2 | Fatma | „Fatma, dein Marker steht beim Gebäck. Auf meiner Notiz steht: ‚Fatma: geht zur Klappe.‘ Kurz vorher war Herr Schneider bei dir. Was wolltest du an der Theken-Klappe?“ | Fatmas Marker 23:57 fällt auf 4a; Druck auf ihre Karte | – |
| 2 | 1 | Can | „Can, auf meiner Notiz steht bei dir nur: ‚nirgends!‘ Ich hab im Buffetsaal und am Durchgang nach allen geschaut. Dich hab ich nicht gesehen. Wo warst du um drei vor zwölf?“ | Cans Marker 23:57; Druck auf seine Karte; dein Bonus-Ziel | – |
| 2 | 2 | Ahmet | Karte zu: „Ahmet, du weißt, worum du mich um 23:53 Uhr gebeten hast. Für dich lüg ich nicht. Sag es selbst, bevor ich es muss.“ Karte offen: „Ahmet, auf meinem Foto von 23:51 Uhr hältst du einen dicken Umschlag, und Herr Schneider ist sauer. Was war in dem Umschlag?“ | Ahmet macht reinen Tisch (M4) | – |
| 3 | 1 | Olli | Olli in Stufe 2: „Olli, du sagst, du hast dich beim Knall am Eiskübel geduckt. Um 23:57 Uhr standst du genau dort. Detektiv, wenn er da so lange war, dann schau dir den Eiskübel an.“ Olli noch in Stufe 1: „Olli, auf meiner Notiz stehst du am Eiskübel, und der Kopf der Tafel war leer. Wo warst du beim Scheppern?“ | lenkt den Detektiv zum Eiskübel (PP9, M8) | – |
| 3 | 2 | Zeynep | „Zeynep, um fünf vor zwölf hab ich zum Gruppenfoto gerufen, und du hast aus dem Steinbogen ‚Komm gleich!‘ gerufen. Gekommen bist du nicht. Was kam im Dunkeln durch den Bogen?“ | Zeyneps Gesprächs-Auslöser in Runde 3 (D10, D11) | Tim: „Tim, du standest im Durchgang am Sicherungskasten. Was kam im Dunkeln an dir vorbei, und wann?“ |

#### ZG 4.9 Aktionskarte (wörtlich, MECH §4.4)

| Feld | Text |
|---|---|
| Kopf | „Aktionskarte · Joanna“ |
| Name | **Zeitstempel** · ab Runde 1 · Klasse Beleg |
| Wirkung | „Eine Person deiner Wahl sagt, wo sie um 23:51 Uhr oder um 23:57 Uhr war. Du wählst die Uhrzeit. Sie nennt eine Person, die sie dort gesehen hat. Die genannte Person sagt sofort, ob das stimmt. Kann sie niemanden nennen, sagt sie das.“ |
| Grenzen | „Nennt sie jemanden, der heute fehlt, dreht der Erzähler dessen Streifen um, auch wenn sie ihn nur umschreibt. Der Streifen gilt als Antwort. Herr Schneider zählt als niemand.“ (P2-09) |
| Fuß | „Einmal im Spiel. Danach umdrehen.“ |
| Tipp im Heft | „Frag Can nach drei vor zwölf. Auf deiner Notiz steht er nirgends. Oder frag Olli, solange er noch sagt, er war im Ost-Saal.“ |

#### ZG 4.10 Was du bei dir trägst (wörtlich)

„Mein Handy im Handyhalter mit Aufsteckleuchte. Darauf meine Fotos und meine Notiz von 23:57 Uhr.“ Im Heft darunter, nicht
zum Vorlesen: „Das Foto von 23:51 Uhr zeigst du erst, wenn deine Geheimniskarte offen liegt.“ (P145R2-K09)

#### ZG 4.11 Bonus-Ziel und fehlende Rollen

- **Wörtlich:** „**Dein Bonus-Ziel:** Dein Gruppenfoto ist geplatzt, aber deine Notiz soll zählen. **Erfüllt, wenn** bei
  der Anklage im Ermittlungsbogen in der Zeile ‚Ort um 23:57‘ bei allen vier Verdächtigen ein Ort steht. ‚Nirgends‘
  zählt nicht.“
- Prüfbarkeit: Ahmet, Fatma, Olli über die Notiz (oder Ahmets, Lejlas, Fatmas, Ollis Karte); Can über Cans Karte („Ort um
  23:57 · Can: im Vorratsraum“) oder Zeyneps Karte. Erreichbar bei 10 bis 20 Personen. Es belohnt, Can zum Reden zu
  bringen, nicht ihn anzuklagen.

| fehlt | Folge für Joanna |
|---|---|
| Marek, Wojtek | Beziehungen entfallen |
| Zeynep | R3-2 wird zum Ausweichziel Tim. Die Notiz nennt Zeynep trotzdem (W-21) |
| Joanna selbst | der Detektiv spielt „Zeitstempel“ (MECH §4.6) |

#### ZG 4.12 Zeugenstreifen Joanna (bei 6 bis 9 Personen; wörtlich; die Notiz zweispaltig in 8 pt darunter, Wortlaut 4.5; P14-02, P145R2-K04)

| Feld | Inhalt |
|---|---|
| Ort auf dem Lageplan | neben dem Markerfeld „1 Ost-Saal“, an der Seite zur Tür; darunter verdeckt Joannas Geheimniskarte |
| Streifen aufdecken | FX3 (ab Runde 1) oder beim „Zeitstempel“ nennt jemand Joanna als Zeugin |
| Geheimniskarte aufdecken | nur über die Tabelle „Karten unter den Streifen“ (MECH §9.14): sobald WE3, PM3 oder WM9 offen liegt, egal wodurch; frühestens Runde 2 |

**Etikett (wörtlich):**
> „Zeugenstreifen · Joanna, die Fotografin des Abends · Zone 1, Tür zum Ost-Saal.
> Umdrehen, wenn der Detektiv FX3 zieht oder beim ‚Zeitstempel‘ jemand Joanna als Zeugin nennt.
> Darunter liegt Joannas Geheimniskarte. Wann sie umgedreht wird, weiß der Erzähler.“

**Protokoll (wörtlich; die Notiz zweispaltig in 8 pt daneben, Wortlaut 4.5; P14-02):**
> „Zeugenprotokoll Joanna, Fotografin des Abends. Um 23:57 Uhr stand ich in der Tür zum Ost-Saal. Fürs Gruppenfoto hab ich
> notiert, wer wo ist. Herr Schneider sagte da zu Olli: ‚Zweitausend, bis zwölf.‘ Im Dunkeln, kurz bevor das Licht wieder
> anging, hab ich mit der Handylampe die Tafel abgeleuchtet. Der Kopf der Tafel war leer.“

**Vermerk (wörtlich, MECH):** „Ort um 23:57 · alle vier: siehe Joannas Liste (Ahmet hinter der Theke am Ostende, Fatma zur Klappe, Olli am Eiskübel, Can nirgends).“

Eine Schlusszeile gibt es nicht (P14-02, P14-05).

#### ZG 4.13 Absatz für Teil 90 (wörtlich, Vorlesen)

„Joanna stand um drei vor zwölf in der Tür zum Ost-Saal und notierte für das Gruppenfoto, wer wo war. Ihre Notiz zeigte
Olli am Eiskübel. Ihr Foto von Ahmet mit dem Umschlag hielt sie zurück, bis eine Spur es verlangte.“

### ZG 5 · Marek (Platz 9) – der Caterer

#### ZG 5.1 Profil

| Feld | Inhalt |
|---|---|
| Platz, Stellung | 9, Zeuge. Spielt ab 11 Personen |
| Alter, Beruf | 28, führt mit seiner Schwester einen kleinen Catering-Betrieb; hat heute das Essen geliefert |
| Rollenbezeichnung | Der Caterer |
| Merkmal | dunkelbraune Lederjacke, Autoschlüssel mit Anhänger |
| Beziehungen | **Ahmet**: Kunde. Ahmet hat viel zu groß bestellt und schuldet Marek heute die Nachzahlung. **Lejla**: hat mit ihm das Buffet geplant. **Joanna**: Hochzeiten, sie fotografiert, er kocht. **[Aylin \| –]**: macht seine Steuer |
| Nebendelikt | Lieferwagen auf Herrn Schneiders reserviertem Platz |
| Haltung (wörtlich im Heft) | „Du willst dein Geld. Aber du sagst nur, was du sicher weißt. Im Dunkeln hast du mehr gesehen als alle anderen.“ |
| Kanon-Ziel | Der Lieferwagen soll nicht abgeschleppt werden (WELT §7.2) |

#### ZG 5.2 Marker

| Marker | behauptet (Stufe 1) | wahr | Umstellen |
|---|---|---|---|
| 23:57 | 4d Theke Ostende | 4d, hinter der Theke am Ostende an den Saftkrügen, Rücken zur Theke | nie |
| Scheppern | 4d Theke Ostende | 4d, steht, Ahmet an seinen Beinen | nie |

#### ZG 5.3 Vorstellungsrunde

- **Frage des Erzählers (wörtlich, Vorlesen):** „Marek, der Caterer. Das ganze Essen heute ist von dir. Wie oft am Abend
  darf man dich fürs Buffet loben, bevor es dir zu viel wird?“
- **Dein Auftritt (wörtlich, Ich-Form):** „Ich bin Marek. Mit meiner Schwester führe ich einen kleinen Catering-Betrieb.
  Alles auf dem Buffet ist von uns. Lob nehme ich gern entgegen, am liebsten zweimal. Mit Joanna mache ich oft Hochzeiten:
  Sie fotografiert, ich koche. Meinen Lieferwagen hab ich heute ganz nah ans Schloss gestellt. Herr Schneider fand das
  weniger praktisch als ich.“
- Anekdote: keine der Dias 3–5 (WELT D-28). Eigene: das doppelte Lob (Kanon `vorstellung.murat`) und der Parkplatz
  (WELT §3.3, harmlos, Z-12).

#### ZG 5.4 Wissen

**Sicher:**

| Zeit | Was Marek weiß | Quelle | frei ab |
|---|---|---|---|
| Wochen vorher | Ahmet hat viel zu groß bestellt. Die Nachzahlung ist 150 € pro Gast, heute Abend in Bargeld fällig | WELT §1.8, §3.2 | Karte (Domino) |
| 18:00 | zahlt seine 150 € „Miete“ an Ahmet | WELT §1.8 | offen |
| 18:30 | liefert über den Schlosshof, parkt auf Herrn Schneiders reserviertem Platz („Am Telefon hieß es, das geht in Ordnung“). Herr Schneider: „Steht der um Mitternacht noch da, lass ich ihn abschleppen.“ Olli und Tim tragen die Warmhaltebehälter durch Hoftür, Turmgang und Bogentür | WELT §3.3 | offen |
| 23:50 | deckt mit Lejla im Ost-Saal Tortenteller und Gläser | WELT §3.4 | offen |
| 23:55 | geht hinter die Theke ans Ostende und füllt Saftkrüge, Gesicht zur Anrichte Ost | WELT §3.4 | offen |
| 23:57 | Ahmet schlüpft neben ihn hinter die Theke, mit einem dicken Umschlag. Marek denkt: Ist das mein Geld? | WELT §3.4, §7.2 | nach dem Umdrehen |
| 23:57 | hört hinter sich: „Zweitausend, bis zwölf.“ Er sieht nicht, zu wem | WELT §5.5, §5.6 | offen |
| 23:57 | Herr Schneider geht hinter der Theke an ihm vorbei zur Kaffeemaschine. [Damir \| Ein Gast] wartet mit der großen Teekanne hinter ihm. Dann: „Nicht die alte Leiste!“ | WELT §3.4 | offen |
| 23:58 | Knall. Marek bleibt stehen. Ahmet kauert sich an seine Beine: „Marek? Ich bin's, Ahmet.“ Herr Schneider: „Ruhe! Ich hol die Notlaterne.“ | WELT §3.4, §5.1, §5.3 | offen (D7) |
| danach | Im Kerzenlicht, gut drei Meter entfernt: Ein leuchtendes Gesicht springt aus der Vorratsraumtür. Herr Schneider packt es: „Hab ich dich!“ Sie ringen. Es reißt sich los und verschwindet hinter der Theke zur Klappe, Richtung Durchgang. „Stehen bleiben!“, zweimal | WELT §5.2, §5.3 | Karte (Runde 3) |
| danach | Von der Klappe her kommt noch jemand zu Herrn Schneider, nur ein Umriss. Herr Schneider packt den Umriss am Ärmel. Dann scheppert es, die Kerzen sind aus | WELT §5.3 (W-06) | Karte (Runde 3) |
| bis 0:00 | Ahmet bleibt an seinen Beinen, bis das Licht angeht | WELT §5.3 | offen |
| 0:00 | Als das Licht angeht, steht [Damir \| der Gast mit der Teekanne] gleich neben Ahmet auf. Marek geht zur Vorratsraumtür, macht sie ganz auf, knipst innen das Licht an: „Hier liegt Herr Schneider!“ Er liegt direkt hinter der Tür. Die Notlaterne hängt unberührt am Haken | WELT §3.4, §6 | offen |

**Vermutet:** Die „Miete“ ist seine Nachzahlung, 150 € pro Gast (stimmt, WELT §1.8). Der Umriss an der Tür war nicht das
Gesicht (stimmt).

**Weiß nicht:** wer der Umriss war (keine Größe, keine Kleidung, keine Stimme); zu wem „Zweitausend, bis zwölf“ gesagt
wurde; wohin das Gesicht nach der Klappe lief; dass der Bund im Eiskübel liegt.

#### ZG 5.5 Stufe 1

**Das sagst du jedem (wörtlich):**
- „Kurz vor zwölf stand ich hinter der Theke am Ostende und hab Saftkrüge gefüllt. Mit dem Rücken zur Theke.“
- „Beim Knall bin ich stehen geblieben. Ahmet hat sich an meine Beine gekauert und geflüstert: ‚Marek? Ich bin's, Ahmet.‘
  Er war noch da, als es schepperte, und auch, als das Licht anging.“ (Kernsatz WELT §5.3)
- „[Damir stand vorher mit der Teekanne hinter mir. Als das Licht anging, stand er gleich neben Ahmet auf. | Ein Gast mit der großen Teekanne stand vorher hinter mir. Als das Licht anging, stand er gleich neben Ahmet auf.]“ (P3-12)
- „Kurz vor zwölf hat Herr Schneider hinter mir zu jemandem gesagt: ‚Zweitausend, bis zwölf.‘ Zu wem, hab ich nicht
  gesehen.“
- „Um zwölf hab ich die Tür zum Vorratsraum aufgemacht und drinnen das Licht angeknipst. Herr Schneider lag gleich hinter
  der Tür. Die Notlaterne hing unberührt am Haken.“
- „Um halb sieben haben Olli und Tim mein Essen durch den Turmgang reingetragen.“
- „Ich steh auf Herrn Schneiders Parkplatz. Am Telefon hieß es, das geht in Ordnung.“
- „Die Mitternachtstorte steht unversehrt im Regal.“ (P14-K04, WELT §6)

**Das behältst du für dich (wörtlich):**

| Wenn jemand fragt | sagst du |
|---|---|
| was du nach dem Knall an der Tür gesehen hast (Runde 1 und 2) | „Im Dunkeln bin ich stehen geblieben, damit keiner über mich fällt. Was an der Tür war, dazu sag ich jetzt nichts.“ |
| ob Ahmet etwas in der Hand hatte | „Frag Ahmet.“ |
| ob Ahmet dir Geld schuldet | „Übers Geschäft red ich nicht beim Essen.“ |

**Verboten:** „Ich hab im Dunkeln nichts gesehen.“ · „Ahmet schuldet mir nichts.“ · „Ahmet hatte nichts in der Hand.“

#### ZG 5.6 Stufe 2

**Rundensperre:** frühestens Runde 3.

**Wann du umdrehst (wörtlich im Heft):**
1. „Sobald die Indizkarte XD3 oder JT3 offen auf dem Tisch liegt.“ (MECH)
2. „Sobald Cans Geheimniskarte offen auf dem Tisch liegt.“ (Z-04)
3. „Sobald dich in Runde 3 jemand vor allen fragt, was du nach dem Knall an der Vorratsraumtür gesehen hast. Auch ein
   Impuls des Erzählers, der alle danach fragt, zählt.“ (Z-03)
4. „Sobald in Runde 3 jemand vor allen sagt, das leuchtende Gesicht oder das Gespenst sei es gewesen.“ (Z-03)
5. „Liegt eins davon schon früher offen, drehst du zu Beginn von Runde 3 um.“

**Geheimniskarte, Innenseite (wörtlich):**

> **Was ich zugebe**
> „Nach dem Knall sah ich im Kerzenlicht: Ein leuchtendes Gesicht sprang aus der Vorratsraumtür. Herr Schneider packte es.
> Es riss sich los und verschwand hinter der Theke zur Klappe, Richtung Durchgang. Danach kam noch jemand von der Klappe her
> zu Herrn Schneider. Nur ein Umriss. Wer, kann ich nicht sagen. Dann schepperte es.“
>
> **Für den Ermittlungsbogen**
> „Alibi beim Scheppern · für das leuchtende Gesicht: Es riss sich los und verschwand hinter der Theke zur Klappe. Erst danach schepperte es.“
> „Hinweis: Nach dem Gesicht kam noch jemand von der Klappe her zu Herrn Schneider. Nur ein Umriss.“
>
> **Und noch etwas**
> „Kurz vor dem Knall rief Herr Schneider Tim zu: ‚Nicht die alte Leiste!‘ Tim stand einen Meter neben mir an der Kaffeemaschine.“ (P2-06)

**Nach dem Umdrehen** sagst du auf Nachfrage außerdem (wörtlich):
- „Ahmet schuldet mir heute Abend 150 € pro Gast Nachzahlung fürs Essen, in Bargeld.“
- „Um 23:57 Uhr ist Ahmet mit einem dicken Umschlag neben mich hinter die Theke. Ich dachte: Ist das mein Geld?“
- „Herr Schneider hat den Umriss am Ärmel gepackt. Gleich danach schepperte es, und die Kerzen waren aus.“
- „Die ‚Miete‘ war genau so hoch wie meine Nachzahlung pro Gast.“

#### ZG 5.7 Nachbohr-Ziele

| Runde | Nr | Ziel | Frage oder Vorwurf (wörtlich) | Worauf du hinauswillst | Ausweichziel |
|---|---|---|---|---|---|
| 1 | 1 | Ahmet | „Ahmet, du sagst, du hast hinter der Theke Servietten gesucht. Die liegen auf der Anrichte direkt vor meiner Nase. Was wolltest du wirklich hinter der Theke?“ | Ahmets Stufe-1-Lüge wackelt; zugleich bezeugst du auf Nachfrage sein Alibi (M1) | – |
| 1 | 2 | Tim | „Tim, du standest kurz vor zwölf an der Kaffeemaschine, einen Meter neben mir. Herr Schneider hat hinter uns gesagt: ‚Zweitausend, bis zwölf.‘ Zu wem? Und kurz danach rief er dir zu: ‚Nicht die alte Leiste!‘ Dann knallte es.“ | Druck auf Tim (Knall, Olli) | – |
| 2 | 1 | Ahmet | „Ahmet, du hast um sechs von uns allen 150 € ‚Miete‘ eingesammelt, auch von mir. Wo ist das Geld jetzt?“ Dazu im Heft: „Wenn er ausweicht, ist das ein guter Moment für deine Taschenkontrolle.“ | Ahmets Heimlichtuerei (M4), dein Bonus-Ziel | – |
| 2 | 2 | Olli | „Olli, du und Tim, ihr habt um halb sieben mein Essen durch den Turmgang getragen. Ist dabei was kaputtgegangen?“ Sobald YT4 offen liegt, dazu: „Seitdem fehlt an der Bogentür ein Beschlag. Wart ihr das?“ | Ollis Heimlichtuerei (M7), Tims Wachs | – |
| 3 | 1 | Olli | Karte offen: „Olli, du sagst, das Gespenst ist auf Herrn Schneider los. Ich hab es im Kerzenlicht gesehen. Das Gesicht riss sich los und war zur Klappe weg. Danach kam noch einer von der Klappe zu Herrn Schneider. Erst dann schepperte es. Wer war das?“ Karte zu: „Olli, du sagst, du warst am Eiskübel. Das sind zwei Meter von mir. Gespürt hab ich beim Knall nur Ahmet.“ | Ollis Stufe 2 fällt (D12) | – |
| 3 | 2 | Can | Karte offen: „Can, das Gesicht sprang aus der Vorratsraumtür, Herr Schneider packte die Kapuze, und dann riss es sich los. Warst du das? Dann sag allen, wohin du gerannt bist.“ Karte zu: „Can, wenn du das Gespenst warst: Wohin bist du danach gerannt?“ | Cans Pflicht-Auslöser (c) mit JA9; Reihenfolge für M3 | – |

#### ZG 5.8 Aktionskarte (wörtlich, MECH §4.4)

| Feld | Text |
|---|---|
| Kopf | „Aktionskarte · Marek“ |
| Name | **Taschenkontrolle** · ab Runde 2 · Klasse Beleg |
| Wirkung | „Eine Person deiner Wahl zeigt, was sie bei sich trägt. Gibt es dafür eine Indizkarte, legt der Erzähler sie offen hin, ohne dass der Detektiv eine Untersuchung verbraucht. Sonst liest die Person ‚Was du bei dir trägst‘ aus ihrem Heft vor.“ |
| Grenzen | „Nur Taschen und was die Person bei sich trägt. Nur Indizkarten, die in dieser Runde schon frei sind.“ (P5-M5) |
| Fuß | „Einmal im Spiel. Danach umdrehen.“ |
| Tipp im Heft | „Wer heute von allen kassiert hat, trägt vielleicht noch viel Bargeld bei sich.“ |

#### ZG 5.9 Was du bei dir trägst (wörtlich)

„Ich hab den Autoschlüssel des Lieferwagens mit Anhänger und meinen Geldbeutel. Mein Handy hab ich seit kurz nach zwölf zurück.“

#### ZG 5.10 Bonus-Ziel und fehlende Rollen

- **Wörtlich:** „**Dein Bonus-Ziel:** Du willst wissen, was aus dem eingesammelten Geld geworden ist. **Erfüllt, wenn** bei
  der Anklage im Ermittlungsbogen bei Ahmet die Zeile ‚Heimlichtuerei‘ belegt ist (✓).“
- Prüfbarkeit: Quellen PM3, WM9, Ahmets, Lejlas, Joannas, Mareks Karte, Aylin. Erreichbar bei 11 bis 20 Personen. Kein
  Ziel gegen einen Unschuldigen: Ahmets Heimlichtuerei hilft ihm sogar beim Ausscheiden.

| fehlt | Folge für Marek |
|---|---|
| Damir | „Ein Gast mit der großen Teekanne“ statt „Damir“ |
| Aylin | Beziehung entfällt |
| Zeynep | nichts (kein Ziel nennt sie) |
| Marek selbst | der Detektiv spielt „Taschenkontrolle“ (MECH §4.6) |

#### ZG 5.11 Zeugenstreifen Marek (bei 6 bis 10 Personen)

| Feld | Inhalt |
|---|---|
| Ort auf dem Lageplan | neben dem Markerfeld „4d Theke Ostende“; darunter verdeckt Mareks Geheimniskarte |
| Streifen aufdecken | WJ9 (ab Runde 1) oder beim „Zeitstempel“ nennt jemand Marek als Zeugen |
| Geheimniskarte aufdecken | nur über die Tabelle „Karten unter den Streifen“ (MECH §9.14): sobald XD3 oder JT3 offen liegt, egal wodurch; frühestens Runde 3 |

**Etikett (wörtlich):**
> „Zeugenstreifen · Marek, der Caterer · Zone 4d, hinter der Theke am Ostende.
> Umdrehen, wenn der Detektiv WJ9 zieht oder beim ‚Zeitstempel‘ jemand Marek als Zeugen nennt.
> Darunter liegt Mareks Geheimniskarte. Wann sie umgedreht wird, weiß der Erzähler.“

**Protokoll (wörtlich):**
> „Zeugenprotokoll Marek, Caterer. Kurz vor zwölf stand ich hinter der Theke am Ostende und hab Saftkrüge gefüllt. Beim
> Knall bin ich stehen geblieben. Ahmet hat sich an meine Beine gekauert und geflüstert: ‚Marek? Ich bin's, Ahmet.‘ Er war
> noch da, als es schepperte, und auch, als das Licht anging. Dann hab ich die Tür zum Vorratsraum aufgemacht und
> gerufen: ‚Hier liegt Herr Schneider!‘“

Bei 6 bis 10 Personen fehlt auch Damir; der Streifen nennt ihn deshalb nie.

**Vermerk (wörtlich, MECH):** „Alibi beim Scheppern · Ahmet: kauerte hinter der Theke am Ostende an Mareks Beinen.“

Eine Schlusszeile gibt es nicht (P14-02, P14-05).

#### ZG 5.12 Absatz für Teil 90 (wörtlich, Vorlesen)

„Marek stand am Ostende hinter der Theke, und Ahmet kauerte an seinen Beinen. Im Kerzenlicht sah er das Gesicht fliehen
und danach einen Umriss von der Klappe kommen. Dass Ahmet ihm die Nachzahlung schuldete, behielt er lange für sich.“

### ZG 6 · Zeynep (Platz 10) – die Fußballtrainerin

#### ZG 6.1 Profil

| Feld | Inhalt |
|---|---|
| Platz, Stellung | 10, Zeugin. Spielt ab 12 Personen |
| Alter, Beruf | 23, Sportstudium, trainiert eine Mädchenmannschaft im Fußball |
| Rollenbezeichnung | Die Fußballtrainerin |
| Merkmal | minzgrüner Pulli, Kappe verkehrt herum |
| Beziehungen | **Can**: großer Bruder, zwei Jahre älter. Sie steht für seinen Streich Schmiere; aus dieser Mitschuld schützt sie ihn. **[Sibel \| –]**: wohnen in einer WG |
| Nebendelikt | Schmiere für Cans Streich |
| Haltung (wörtlich im Heft) | „Du hältst zu Can, aber du lügst nicht für ihn. Du weißt: Er war es nicht.“ |
| Kanon-Ziel | Can schützen (WELT §7.2) |

#### ZG 6.2 Marker

| Marker | behauptet (Stufe 1) | wahr | Umstellen |
|---|---|---|---|
| 23:57 | 6 Durchgang mit Steinbogen | 6, im Steinbogen, Rücken am Nordpfeiler | nie |
| Scheppern | 6 Durchgang mit Steinbogen | 6, dto. | nie |

#### ZG 6.3 Vorstellungsrunde

- **Frage des Erzählers (wörtlich, Vorlesen):** „Zeynep, die Fußballtrainerin. Bei dir wird sogar das Teetrinken zum
  Wettkampf. Wer hat heute Abend schon gegen dich verloren?“
- **Dein Auftritt (wörtlich, Ich-Form):** „Ich bin Zeynep. Ich studiere Sport und trainiere eine Mädchenmannschaft im
  Fußball. Can ist mein großer Bruder, aber lauter bin ich. Heute hab ich schon zwei Wettrennen zum Buffet gewonnen und
  eins im Teetrinken. Nur beim Witzeerzählen verliere ich gegen Can. Seine sind schlechter, aber er erzählt sie zweimal.“
- Anekdote: keine der Dias 3–5 (WELT D-28; die Rüstung gehört Sibel, auch wenn sie Zeyneps Mitbewohnerin ist). Eigene: der
  Wettkampf (Kanon `vorstellung.zeynep`).

#### ZG 6.4 Wissen

**Sicher:**

| Zeit | Was Zeynep weiß | Quelle | frei ab |
|---|---|---|---|
| 18:00 | zahlt 150 € „Miete“ an Ahmet | WELT §3.3 | offen |
| vorher | Can will um zwölf die blinde Kuh mit einer Leuchtmaske erschrecken. Sie soll Schmiere stehen | WELT §7.1, §7.2 | Karte |
| 23:45 | holt am linken Buffet Gebäck für sich und Can. Fatmas Umhängetasche ist auffällig ausgebeult | WELT §3.3 | offen |
| 23:50 | an der langen Tafel im Kaminsaal mit Can. Olli und Tim stehen an der Bogentür; Tim ruft: „Au! Mein Finger!“ | WELT §3.4, Z-08 | offen |
| 23:54 | Can geht mit der Maske über Steinbogen, Durchgang und Klappe in den Vorratsraum. Sie stellt sich in den Steinbogen, Rücken am Nordpfeiler. Ihr Auftrag: den Fluchtweg frei halten und aufpassen, dass niemand aus dem Kaminsaal herüberkommt | WELT §3.4, §7.2 | Karte |
| 23:54–23:55 | Herr Schneider kommt aus dem Turmgang zurück. Sie macht ihm im Bogen Platz | WELT §3.4 | offen |
| 23:55 | Joanna ruft an der Tür zum Durchgang zum Gruppenfoto. Zeynep: „Komm gleich!“ Kurz danach geht Tim mit dem Finger in der Hand an ihr vorbei Richtung Klappe | WELT §3.4 | offen |
| 23:57 | hört Herrn Schneider laut: „Nicht die alte Leiste!“ | WELT §5.1 | offen |
| 23:58 | Knall. Sie hört „Hab ich dich!“ und „Stehen bleiben!“ | WELT §5.1 | offen |
| danach | Can rennt mit dem leuchtenden Gesicht durch den Durchgang, streift sie im Bogen und rennt in den Kaminsaal. Danach brüllt Herr Schneider noch einmal. Dann scheppert es | WELT §5.3 | Karte (Runde 3) |
| im Dunkeln, kurz vor dem Licht | Tims Stirnlampe leuchtet sie an | WELT §3.4 | offen |
| 0:01 | Can kommt von der Turm-Toilette herunter. Sie geht zu ihm auf die Wandbank im Kaminsaal | WELT §3.5 | offen |

**Vermutet:** Can hat mit dem Scheppern nichts zu tun (stimmt). Wenn Herr Schneider Can noch hinterherbrüllte, stand er
da noch; also kam das Scheppern von etwas anderem (stimmt, eigener Schluss).

**Weiß nicht:** was an der Theke geschah (acht Meter, keine Sicht); was leise gesagt wurde, nie „Zweitausend“ (WELT §5.3);
wo Olli nach dem Knall war.

#### ZG 6.5 Stufe 1

**Das sagst du jedem (wörtlich):**
- „Ab kurz vor zwölf stand ich im Steinbogen zwischen Durchgang und Kaminsaal. Ich hab nach der blinden Kuh Ausschau
  gehalten.“ (halb wahr, WELT §4.2)
- „Um Viertel vor zwölf hab ich am linken Buffet Gebäck geholt. Fatmas Umhängetasche war auffällig ausgebeult.“
- „Um zehn vor zwölf standen Olli und Tim im Kaminsaal an der Bogentür. Tim hat ‚Au! Mein Finger!‘ gerufen.“
- „Kurz vor dem Knall rief Herr Schneider an der Theke: ‚Nicht die alte Leiste!‘ Das hab ich bis in den Bogen gehört.“

**Das behältst du für dich (wörtlich):**

| Wenn jemand fragt | sagst du |
|---|---|
| warum du im Bogen standest | „Ich wollte sehen, wann die blinde Kuh zur Torte gebracht wird.“ |
| wo Can war | „Can ist alt genug. Frag ihn selbst.“ |
| was du im Dunkeln gesehen hast (Runde 1 und 2) | „Ich hab mich an den Pfeiler gedrückt und gewartet, bis das Licht anging. Mehr sag ich jetzt nicht.“ |
| ob du Fatma an der Klappe gesehen hast | „Ich hab vor allem in den Kaminsaal geschaut. Auf die Klappe hab ich nicht geachtet.“ |
| nach Cans Kapuze | „Gelb ist eine schöne Farbe. Mehr nicht.“ |
| wenn Cans Geheimniskarte schon vor Runde 3 offen liegt | „Was auf Cans Karte steht, stimmt. Mehr sag ich jetzt nicht.“ |

**Verboten:** „Can war auf der Toilette.“ · „Ich hab im Dunkeln nichts gesehen.“ · „Ich weiß nichts von einer Maske.“

#### ZG 6.6 Stufe 2

**Rundensperre:** frühestens Runde 3.

**Wann du umdrehst (wörtlich im Heft):**
1. „Sobald die Indizkarte FK3 oder JT3 offen auf dem Tisch liegt.“ (MECH)
2. „Sobald Cans Geheimniskarte offen auf dem Tisch liegt.“ (Z-04)
3. „Sobald dich in Runde 3 jemand vor allen fragt, was im Dunkeln durch den Bogen kam. Auch ein Impuls des Erzählers, der
   alle danach fragt, zählt.“ (Z-03)
4. „Sobald in Runde 3 jemand vor allen sagt, Can oder das Gespenst sei es gewesen.“ (Z-03)
5. „Liegt eins davon schon früher offen, drehst du zu Beginn von Runde 3 um.“

**Geheimniskarte, Innenseite (wörtlich):**

> **Was ich zugebe**
> „Ich hab für Can Schmiere gestanden. Ab 23:54 Uhr wartete er mit einer Leuchtmaske im dunklen Vorratsraum auf die blinde
> Kuh. Kurz nach dem Knall rannte er mit dem leuchtenden Gesicht durch den Durchgang und streifte mich im Bogen. Als er
> schon im Kaminsaal war, brüllte Herr Schneider ihm noch hinterher. Erst danach kam das Scheppern.“
>
> **Für den Ermittlungsbogen**
> „Heimlichtuerei · Can: Can wartete mit einer Leuchtmaske im dunklen Vorratsraum auf die blinde Kuh. Ich stand für ihn Schmiere.“
> „Alibi beim Scheppern · Can: Er rannte mit dem leuchtenden Gesicht durch den Bogen, bevor es schepperte.“
>
> **Und noch etwas**
> „Als das Licht anging, stand Tim am Sicherungskasten, direkt an Cans Weg. Frag ihn, was an ihm vorbeikam.“ (P3-11)

**Nach dem Umdrehen** sagst du auf Nachfrage außerdem (wörtlich):
- „Ich sollte den Weg frei halten, damit Can nach dem Erschrecken entwischen kann.“
- „Was an der Theke war, hab ich nicht gesehen. Gehört hab ich nur Herrn Schneiders Rufe und dann das Scheppern.“

#### ZG 6.7 Nachbohr-Ziele

| Runde | Nr | Ziel | Frage oder Vorwurf (wörtlich) | Worauf du hinauswillst | Ausweichziel |
|---|---|---|---|---|---|
| 1 | 1 | Fatma | „Fatma, um Viertel vor zwölf hab ich am linken Buffet Gebäck geholt. Deine Tasche war ausgebeult wie ein Fußball. Was hast du da drin?“ | Fatmas Stufe 1 wackelt; lenkt zu FM9 und NN3 | – |
| 1 | 2 | Olli | „Olli, du sagst, du warst die ganze Zeit im Ost-Saal. Um zehn vor zwölf hab ich dich im Kaminsaal gesehen, mit Tim an der Bogentür. Was habt ihr da gemacht?“ | Druck auf Olli und Tim; lenkt den Detektiv zur Bogentür (YT4) | – |
| 2 | 1 | Tim | „Tim, kurz vor dem Knall rief Herr Schneider: ‚Nicht die alte Leiste!‘ Das hab ich bis in den Bogen gehört. Dann knallte es, und wer kam zum Sicherungskasten? Du. Was hast du an der Leiste gemacht?“ | Tims Heimlichtuerei; lenkt zu MR4 | – |
| 2 | 2 | Joanna | „Joanna, du hast den ganzen Abend fotografiert. Zeig dem Detektiv deine Fotos von kurz vor zwölf. Dann sieht er, wer wo war.“ | Druck auf Joannas Foto; lenkt von Can ab | – |
| 3 | 1 | Olli | Karte offen: „Olli, du sagst, das Gespenst ist auf Herrn Schneider los. Das Gespenst war mein Bruder. Er war schon an mir vorbei im Kaminsaal, da hat Herr Schneider ihm noch hinterhergebrüllt. Erst danach hat es gescheppert.“ Karte zu, Olli in Stufe 2: „Olli, du sagst, ein Gespenst ist auf Herrn Schneider los. Du hast dich aber geduckt. Woher weißt du, was das Gespenst beim Scheppern gemacht hat?“ Olli noch in Stufe 1: „Olli, wo warst du beim Scheppern? Und wer hat dich da gesehen?“ | Ollis Stufe 2 fällt; Cans Alibi (M3) | – |
| 3 | 2 | Tim | „Tim, du standest am Sicherungskasten, direkt neben dem Weg. Sag allen, was an dir vorbeikam, und wann.“ | Tims Gesprächs-Auslöser in Runde 3; zweite Quelle für M3 | – |

#### ZG 6.8 Aktionskarte (wörtlich, MECH §4.4)

| Feld | Text |
|---|---|
| Kopf | „Aktionskarte · Zeynep“ |
| Name | **Gelbe Karte** · ab Runde 1 · Klasse Frage |
| Wirkung | „Eine Person deiner Wahl muss die nächste Frage, die ihr gestellt wird, sofort beantworten. Sie darf dafür keine Aktionskarte spielen.“ |
| Grenzen | „Eine schon gespielte Schutzkarte bleibt gültig. Lügen nach Stufe 1 bleibt erlaubt.“ |
| Fuß | „Einmal im Spiel. Danach umdrehen.“ |
| Tipp im Heft | „Gut gegen jemanden, der sich hinter einer Schutzkarte verstecken will. Bleibt das Gespräch zu lange bei Can, zeig die Gelbe Karte jemand anderem.“ |

#### ZG 6.9 Was du bei dir trägst (wörtlich)

„Mein Handy, seit kurz nach zwölf zurück, und eine Trillerpfeife vom Training.“

#### ZG 6.10 Bonus-Ziel und fehlende Rollen

- **Wörtlich:** „**Dein Bonus-Ziel:** Du hältst zu Can, bis feststeht, dass er es nicht war. **Erfüllt, wenn** Can bei der
  Anklage auf dem Ermittlungsbogen als ausgeschieden steht: Alibi ✓ und Heimlichtuerei ✓.“
- Hinweis im Heft (wörtlich): „Can scheidet nur aus, wenn auch sein Streich auf dem Tisch liegt. Dein eigenes Geheimnis
  hilft ihm dabei.“
- Prüfbarkeit: Can ist immer besetzt. Alibi über Zeyneps, Tims, Mareks Karte oder FK3; Heimlichtuerei über JT3, Cans oder
  Zeyneps Karte. Erreichbar bei 12 bis 20 Personen.

| fehlt | Folge für Zeynep |
|---|---|
| Sibel | Beziehung entfällt |
| Zeynep selbst | der Detektiv spielt „Gelbe Karte“ (MECH §4.6) |

#### ZG 6.11 Zeugenstreifen Zeynep (bei 6 bis 11 Personen)

| Feld | Inhalt |
|---|---|
| Ort auf dem Lageplan | neben dem Markerfeld „6 Durchgang mit Steinbogen“, auf der Seite des Steinbogens; darunter verdeckt Zeyneps Geheimniskarte |
| Streifen aufdecken | AD3 (ab Runde 1), FK3 (ab Runde 3) oder beim „Zeitstempel“ nennt jemand Zeynep als Zeugin |
| Geheimniskarte aufdecken | nur über die Tabelle „Karten unter den Streifen“ (MECH §9.14): sobald FK3 oder JT3 offen liegt, egal wodurch, auch per Taschenkontrolle (P14-K02); frühestens Runde 3 |

**Etikett (wörtlich):**
> „Zeugenstreifen · Zeynep, die Fußballtrainerin · Zone 6, im Steinbogen.
> Umdrehen, wenn der Detektiv AD3 oder FK3 zieht oder beim ‚Zeitstempel‘ jemand Zeynep als Zeugin nennt.
> Darunter liegt Zeyneps Geheimniskarte. Wann sie umgedreht wird, weiß der Erzähler.“

**Protokoll (wörtlich):**
> „Zeugenprotokoll Zeynep, Fußballtrainerin. Ab kurz vor zwölf stand ich im Steinbogen zwischen Durchgang und Kaminsaal.
> Ich wollte sehen, wann die blinde Kuh zur Torte gebracht wird. Um Viertel vor zwölf hab ich am linken Buffet Gebäck
> geholt. Fatmas Umhängetasche war auffällig ausgebeult.“

**Vermerk (wörtlich, MECH):** „Hinweis: Um 23:45 Uhr war Fatmas Tasche auffällig ausgebeult.“

Eine Schlusszeile gibt es nicht (P14-02, P14-05).

#### ZG 6.12 Absatz für Teil 90 (wörtlich, Vorlesen)

„Zeynep stand im Steinbogen Schmiere, damit ihr Bruder nach dem Streich entwischen konnte. Can rannte an ihr vorbei,
bevor es schepperte. So wurde sie eine der Zeuginnen für Cans Alibi, und sie schwieg bis zur letzten Runde.“

### ZG 7 · Querschnitt: Wer bohrt wen an

#### ZG 7.1 Druck der Zeugen auf die vier Verdächtigen je Runde

„(A)“ = nur als Ausweichziel.

| Runde | auf Ahmet | auf Fatma | auf Olli | auf Can |
|---|---|---|---|---|
| 1 | Marek | Tim, Joanna, Zeynep | Lejla, Emine, Joanna, Zeynep | Lejla, Tim (A) |
| 2 | Lejla, Tim, Joanna, Marek | Emine | Emine, Marek, Lejla (A) | Tim, Joanna |
| 3 | – (seine Fragen sind beantwortet) | – (ihre Fragen sind beantwortet) | alle sechs, je aus anderem Blick: Lejla (spät gekommen, Eiskübel), Emine (kein Zeuge), Tim (Eis kam spät), Joanna (Eiskübel prüfen), Marek (zweite Gestalt), Zeynep (Reihenfolge) | Emine, Marek, Lejla (A) |

Begründung der Verteilung: Runde 1 „Alibi-Geflecht“ trifft die Ortslügen (Olli, Fatma, Cans Marker). Runde 2
„Indizien-Filterung“ trifft die Heimlichtuereien (Ahmets Geld, Fatmas Schatulle, Cans Kapuze, Ollis Bogentür). Runde 3
„Gegenüberstellung“ stellt Ollis Gespenst-Fassung gegen die Reihenfolge der drei Zeugen im Durchgang und an der Theke.

#### ZG 7.2 Druck der Zeugen untereinander

| Runde | wer fragt wen | Wirkung |
|---|---|---|
| 1 | Emine → Lejla | Lejlas offenes Wissen (D2) kommt sicher auf den Tisch |
| 1 | Tim → Zeynep | Zeyneps Schmiere wird verdächtig |
| 1 | Marek → Tim | Tims Knall wird verdächtig |
| 2 | Lejla → Marek | Ahmets Alibi (M1) wird laut gesagt |
| 2 | Zeynep → Tim | Tims Leiste; der Detektiv denkt an MR4 |
| 2 | Zeynep → Joanna | Joannas Foto wird verdächtig |
| 3 | Lejla → Tim, Zeynep → Tim, Joanna → Zeynep (A: Tim), Tim → Marek (A: Lejla) | Gesprächs-Auslöser der drei Runde-3-Zeugen; fehlt Marek, fragt Tim Lejla nach Herrn Schneider (P14-K07) |

Wer wird von anderen Zeugen angebohrt: Lejla (1×), Tim (5×), Joanna (1×), Marek (2×), Zeynep (2×). Emine wird über Cans
Domino-Hinweis, RH3 und FM9 angesprochen. Dazu kommen die Verdächtigen aus Teil 03.

### ZR 0 · Grundsätze für alle acht Zusatzrollen

#### ZR 0.1 Regeln

| Nr | Regel | Quelle |
|---|---|---|
| ZG-01 | **Zusatzrollen lügen nie.** Einzige Ausnahme ist Serkans Ausrede mit den Decken. Alle dürfen schweigen, ausweichen und halbe Wahrheiten sagen. Jeder Satz, den ein Zusatzheft vorgibt, ist wahr, außer Serkans Decken-Satz. | WELT §7.4 (Lüge: nur Serkan unter 11–18), REG §6.10 |
| ZG-02 | Über den eigenen Ort sagen Zusatzrollen immer die Wahrheit. Beide Marker stehen von Anfang an richtig und werden nie umgestellt. | WELT §4.2, R-01 |
| ZG-03 | Stufe 1 hat drei Teile: „Das sagst du jedem“ (offenes Wissen), „Das behältst du für dich“ (Tarnsätze auf bestimmte Fragen) und „Verboten“ (Sätze, die gelogen wären). Tugba hat nur den ersten Teil. | A:91, ZG G-03, W-17 |
| ZG-04 | Stufe 2 = Geheimniskarte umdrehen. Pflicht-Auslöser sind die Codes aus MECH §4.2 und die Gesprächs-Auslöser dieser Datei. Kein Auslöser umgeht eine Rundensperre. Sperren: Wojtek und Aylin frühestens Runde 2, alle anderen keine. | MECH §4.2, R-03, R-04 |
| ZG-05 | **Genau ein Rand-Indiz je Rolle.** Es bestätigt nur, was die Rollen 5–10 oder die Indizkarten schon tragen. Keine Zusatzrolle weiß mehr als die Zeugen. | WELT §7.3, ABG D-23 |
| ZG-06 | Wissen, das Cans Alibi stützt, ist frühestens in Runde 3 frei. Das betrifft nur Hanas Kerzengeruch. | M-14 |
| ZG-07 | Zusatzrollen haben keine Stufe 3. Werden sie angeklagt, sagen sie nur, **wörtlich**: „Ich war es nicht.“ | MECH §8.1 Nr. 3 |
| ZG-08 | Nachbohr-Ziele stützen sich nur auf eigenes offenes Wissen, auf „Was alle wissen“ (MECH §1.5), auf die Marker auf dem Lageplan, auf offen liegende Karten und auf die eigene Geheimniskarte erst nach dem Umdrehen. Hängt ein Ziel vom Tischstand ab, hat es zwei oder drei Fassungen. | ZG G-07 |
| ZG-09 | Nachbohr-Ziele nennen nur Rollen mit kleinerem Platz. Die sind immer besetzt, wenn die Zusatzrolle spielt (E6). Deshalb braucht kein Ziel ein eigenes Ausweichziel; in der Tabelle steht „– (immer besetzt)“. Fällt eine Zielrolle am Abend doch aus (jemand geht früher), gilt das Ausweichziel, **wörtlich im Heft**: „Fehlt dein Ziel, frag stattdessen den Verdächtigen, den du in dieser Runde noch nicht gefragt hast. Stell ihm dieselbe Frage.“ | E6, ZR-04 |
| ZG-10 | Ungespielte Zusatzrollen heißen nie mit Namen, sondern „ein Gast“. In Ich-Sätzen auch „mein Begleiter“ oder „der Gast“. **Jede gedruckte Zeile, die eine Rolle mit höherem Platz nennt, trägt einen Platzhalter**, auch in „Was du weißt“, in Tarnsätzen und auf Karten. Der Prüfer der Text-Phase vergleicht jeden Namen 5–18 in Teil 10, 12, 20 und 90 mit der Besetzung (P5-B4, P14-01). | WELT §1.1, ZG G-08 |
| ZG-11 | Uhrzeiten nur aus der Kanon-Liste, nie Sekunden. Lesetext (Heft, Karte): „23:57 Uhr“, „150 €“. Vorlesetext (Frage des Erzählers, „Dein Auftritt“, Absatz für Teil 90): Uhrzeiten und Beträge in Worten, ohne Ziffern. | WELT §0.2, REG §6.5 |
| ZG-12 | Ton: höchstens 25 Wörter je Satz, im Mittel höchstens 14. Kein Verb des Schlagens. Immer „Herr Schneider“. „in Bargeld“. Qualm nur mit einem Wort, das mit „Kamin“ beginnt, im selben Satz. Kopftuch und Herkunft kommen nie vor. Kein eindeutiges Farbwort einer anderen Figur (REG §6.7): Zusatzhefte sagen „Cans Kapuze“, „gelb“, nie „signalgelb“; „Notizbuch mit goldenem Einband“ steht nur in Tugbas Heft. | REG §6, WELT §0.2 |
| ZG-13 | Nach dem Umdrehen gilt R-03. Unter „Nach dem Umdrehen“ nennt das Heft weitere wahre Sätze für Nachfragen. Bis zum Umdrehen gilt R-14. | R-03, R-14 (P145R2-M04) |
| ZG-14 | **Dankeskarte:** Alle aus der Clique haben um 18:00 Uhr beim Einlass heimlich eine Dankeskarte für Herrn Schneider unterschrieben. Geheim ist das nur vor Herrn Schneider. Wer gefragt wird, bestätigt es. | WELT §3.3, ZR-17 |
| ZG-15 | **Nicht lösen, nicht stören:** Keine Zusatzrolle kennt den Fundort, den Fuß des Kerzenständers, die Tat oder die Reihenfolge an der Vorratsraumtür. Kein Satz einer Zusatzrolle erfüllt einen Pflicht-Auslöser der vier Verdächtigen (geprüft in 11.3). Keine Zusatzrolle sagt, das leuchtende Gesicht sei aus dem Vorratsraum gekommen. | A:60, MECH §4.2, ZR-02 |
| ZG-16 | **Handzeichen:** Fragt jemand mit der Aktionskarte „Handzeichen“ nach etwas, das du noch zurückhältst, hebst du die Hand nicht und sagst laut: „Ich enthalte mich.“ So lügt niemand mit der Hand. Dieselbe Regel steht auf der Karte selbst und gilt für alle Rollen (MECH §4.4, ZG G-12). | ZR-16, P14-11 |

#### ZR 0.2 Besetzung, Tandems, Solo (E6)

Personen = Rollen + Detektiv + Erzähler. Zusatzrollen kommen paarweise in Platzreihenfolge dazu. Bei ungerader Zahl spielt
die letzte Zusatzrolle ihr Tandem allein. Allein spielt deshalb immer nur der kleinere Platz eines Tandems.

| Platz | Rolle | Tandem | spielt ab Personen | Partner | spielt allein bei | Solo-Abschnitt |
|---|---|---|---|---|---|---|
| 11 | Sibel | 1 | 13 | Damir (12) | 13 Personen | 1.12 |
| 12 | Damir | 1 | 14 | Sibel (11) | nie | – |
| 13 | Hana | 2 | 15 | Serkan (14) | 15 Personen | 3.12 |
| 14 | Serkan | 2 | 16 | Hana (13) | nie | – |
| 15 | Azra | 3 | 17 | Wojtek (16) | 17 Personen | 5.12 |
| 16 | Wojtek | 3 | 18 | Azra (15) | nie | – |
| 17 | Aylin | 4 | 19 | Tugba (18) | 19 Personen | 7.12 |
| 18 | Tugba | 4 | 20 | Aylin (17) | nie | – |

Folge für die Texte: Der größere Platz eines Tandems darf den Partner immer mit Namen nennen. Der kleinere Platz nennt den
Partner nur als Platzhalter [Name | Ersatz].

#### ZR 0.3 Übersicht

| Platz | Rolle | Marker 23:57 / Scheppern | eigenes Geheimnis (Karte) | Rand-Indiz (Meilenstein, frei ab) | Sperre | Pflicht-Codes (MECH) | Gesprächs-Auslöser (nur gespielt) | Domino-Hinweis drückt auf | Aktionskarte | Bonus-Ziel |
|---|---|---|---|---|---|---|---|---|---|---|
| 11 | Sibel | 7 / 7 | Sprung in der Vitrine um 21:00 | Gesicht huscht zur Bogentür (stützt M6, R1) | – | FM9, YT4 | Damirs Karte offen; Vorwurf „Vitrine kaputt gemacht“ | Damir (Solo: Vitrine, Schatulle) | Noch mal rückwärts | Karte selbst umgedreht, bevor FM9 oder YT4 offen lag |
| 12 | Damir | 1 / 4d | Splitter unter den Sockel gekehrt | Ahmet flüstert neben ihm (M1, R1) | – | YT4 | Sibels Karte offen; Vorwurf „Vitrine kaputt gemacht“ | Ahmet (Umschlag beim Licht) | Teepause | sein Name als Quelle bei Ahmets Alibi |
| 13 | Hana | 7 / 7 | Liebesbrief im Kamin | Gesicht, danach Kerzengeruch (stützt M3, R3) | – | VP7 | Serkans Karte offen; vor allen nach dem Papier gefragt | Serkan (Solo: Kamin-Nische) | Spurenlesen | Can: Alibi ✓ |
| 14 | Serkan | W / W | Wunderkerzen im Auto, „Decken“ | niemand ist durchs Außentor hinaus (stützt M8, R1) | – | zweimal nach dem Außentor gefragt | Hanas Karte offen | Hana | Lagebesprechung | Schlüsselbund wieder bei Herrn Schneider |
| 15 | Azra | 1 / 1 | hat Fatma von der Schatulle erzählt | Ahmet am Ascheneimer um 0:12 (M4, R2) | – | NN3, FM9 | Fatmas Karte offen | Wojtek (Solo: Tim) | Lupe | Fatmas Karte offen, bevor NN3 offen lag |
| 16 | Wojtek | 1 / 1 | Möbelwachs aus seinem Kasten | Dose halb leer um 20:15, Tims Satz (stützt M7, Karte) | R2 | MR4 | Azras Karte offen; Tims Karte offen | Tim (und Olli) | Maßband | eigene Karte freiwillig umgedreht, bevor MR4 offen lag |
| 17 | Aylin | 1 / 1 | Quittungszettel „Miete: 0 Euro“ | der Zettel selbst (M4, Karte) | R2 | PM3, WE3 | Ahmets Karte offen; Taschenkontrolle bei ihr | Bogentür (Durchschlag) | Beleg bitte! | Ahmets Karte offen, bevor PM3 oder WM9 offen lag |
| 18 | Tugba | 1 / 1 | nur die Dankeskarte (harmlos) | linker Handschuh um 19:30 (stützt M9, R1) | – | keiner | Aylins Karte offen; Taschenkontrolle bei ihr | Aylin | Handzeichen | jemand sagt vor allen, dass die Torte heil ist |

#### ZR 0.4 Die vier Mini-Intrigen

Jede Intrige ist verdeckt (keiner außer dem Tandem weiß davon), kanonverträglich (WELT §7.3, Kanon `figuren.json`) und
berührt den Hauptfall nur am Rand. Sie geht über die Geheimniskarten der beiden auf.

**Tandem 1 – Sibel & Damir: Das Vitrinen-Missgeschick um 21:00 (A:61)**
- Was geschah (WELT §3.3, 21:00): Damir begleitet Sibel zur Turm-Toilette. Sibel hält die Ritterrüstung für einen Menschen,
  schreit und stolpert rückwärts gegen die Schauvitrine. Die Scheibe springt, ein paar Splitter springen von der Ecke. Damir
  kehrt sie unter den Sockel der Rüstung. Beide schweigen. Als es sich herumspricht, lachen alle über den Schrei. Vom Sprung weiß sonst niemand.
- Was verdeckt bleibt: der Sprung und die Splitter. „Unter den Teppich gekehrt“ ist nur ein Wortspiel; es gibt keinen Teppich.
- Spannung: Herr Schneider hat um 23:53 die angehobene Scheibe und das leere Samtbett gefunden (WELT §3.4). Wer über die
  Vitrine redet, bringt den Sprung ins Spiel. Sibel hat Angst, dass man ihn jemand anderem anhängt. Damir hat schon Ärger mit
  Herrn Schneider wegen des Teegeschirrs (Kanon) und will keinen neuen.
- Wie es aufgeht: YT4 (Splitter unter dem Sockel, ab Runde 1) dreht beide Karten. FM9 dreht Sibels Karte, Sibels Karte dreht
  Damirs. Wirft jemand einer anderen Person vor, die Vitrine kaputt gemacht zu haben, drehen beide aus Gewissen um. In Runde 2 spricht
  Damir leise mit Sibel darüber (P14-09).
- Berührung mit dem Hauptfall: Der Sprung von 21:00 stützt Fatmas Fassung (sie hob die Scheibe nur an), nicht ihr Alibi.
  Damir kauerte beim Knall neben Ahmet (Rand-Indiz M1). Sibel sah das Gesicht zum Turm huschen (Rand-Indiz, stützt M6).

**Tandem 2 – Hana & Serkan: Das Kamin-Desaster um 23:30 (A:62)**
- Was geschah (WELT §3.3, 23:20 und 23:30): Hana feuert den Kamin an, ohne die Kaminklappe zu öffnen. Sie will heimlich
  einen alten Liebesbrief verbrennen. Serkan sieht, wie sie Papier in den Kamin stopft. Um 23:30 füllt der Qualm aus dem
  Kamin den Kaminsaal. Serkan reißt die Klappen der Lichtschächte auf. Beim Lüften verrät er Hana seinen Plan: Wunderkerzen
  für die Mitternachtstorte, sie liegen im Auto. Offenes Feuer erlaubt Herr Schneider nicht. Seitdem decken sie sich.
- Was verdeckt bleibt: der Brief (halb verkohlt unter der Asche, ohne Namen) und die Wunderkerzen. Serkans Ausrede um 23:56:
  „Ich wollte Decken aus dem Auto holen.“
- Wie es aufgeht: VP7 (Kamin-Nische, ab Runde 3, P2-07) dreht Hanas Karte. Hanas Karte verrät Serkans Ausrede und dreht seine.
  In Runde 1 fragt Wojtek Hana vor allen nach dem Kamin, in Runde 2 spricht Serkan leise mit Hana (P14-09). Fragt jemand
  Hana vor allen, was sie in den Kamin gesteckt hat, dreht sie um. Serkan fragen der Detektiv ab 16 Personen (RK 6.12) und
  Azra ab 17 nach dem Warum (P145R2-M05).
  Wird Serkan zweimal gefragt, warum er zum Außentor ging, dreht er um; seine Karte verrät Hanas Papier und dreht ihre.
- Berührung mit dem Hauptfall: Serkan bezeugt, dass niemand durchs Außentor hinausging (stützt M8: der Bund ist wohl noch im
  Keller). Hana roch
  nach dem Gesicht die ausgeblasenen Kerzen (stützt M3, erst Runde 3).

**Tandem 3 – Azra & Wojtek: Der falsche Alarm um 20:15 und der Werkzeugkasten (A:63)**
- Was geschah (WELT §3.3, 18:00 und 20:15): Wojtek leiht Tim um 18:00 seinen Werkzeugkasten. Um 20:15 ruft Azra „Einbrecher
  an der Torte!“, Wojtek leuchtet mit der Taschenlampe aus dem Kasten in den Vorratsraum: Es ist Olli. Beim Zurücklegen sieht
  Wojtek die Dose Möbelwachs halb leer, am Rand Holzstaub. Tim sagt: „Olli brauchte was für eine Schramme.“ Wojtek bittet
  Azra, nichts zu sagen. Sie verspricht es.
- Was verdeckt bleibt: Wojtek: Das Wachs kam aus seinem Kasten; er fürchtet, dass Herr Schneider auch ihn zur Kasse bittet.
  Azra: ihr Versprechen, und ihr eigenes Geheimnis aus dem Kanon (sie hat Fatma von der Münzschatulle erzählt).
- Wie es aufgeht: FM9 oder NN3 dreht Azras Karte; ihr Domino-Hinweis nennt Wojteks Bitte. MR4 (ab Runde 2) oder Azras Karte
  dreht Wojteks Karte, frühestens in Runde 2.
- Berührung mit dem Hauptfall: Wojteks Karte verbindet das Wachs mit Olli (stützt M7 mit YT4). Azra sah Ahmet um 0:12 am
  Ascheneimer (M4, ab Runde 2).

**Tandem 4 – Aylin & Tugba: Die Schlüssel- und Gästeliste (A:64)**
- Was geschah (WELT §3.3, 18:00 und 22:30): Aylin hilft Herrn Schneider beim Einlass und hakt die Gästeliste ab. Er zeigt ihr
  Sicherungskasten, Fach und Notlaterne und erklärt den Bund. Mit der Gästeliste lässt Aylin heimlich alle Tugbas Dankeskarte
  für Herrn Schneider unterschreiben. Um 22:30 bekommt Aylin den Quittungszettel „Miete: 0 Euro. Schneider“.
- Was verdeckt bleibt: Aylin: der Zettel. Sie will ihr Geld zurück, ohne Ahmet bloßzustellen. Tugba: nur die Überraschung
  mit der Dankeskarte. **Tugba ist ganz unbelastet** (E11, W-17): kein Nebendelikt, keine Lüge, kein zurückgehaltenes Wissen
  zum Fall. Die Heimlichkeit des Tandems trägt allein Aylin.
- Wie es aufgeht: PM3 oder WE3 (Aylin frühestens Runde 2) dreht Aylins Karte. Tugba dreht ihre, wann sie will, spätestens
  wenn Aylins Karte offen liegt.
- Berührung mit dem Hauptfall: Aylins Zettel belegt Ahmets Mietschwindel (M4). Tugba sah um 19:30 Olli den linken Handschuh in
  die Kamin-Nische legen (stützt M9 mit VP7 und FN3).

#### ZR 0.5 Antworten auf die Moderationsimpulse (Stufe 1, solange die eigene Karte zu ist)

Die Impulse stehen in MECH §9.9. Jede Antwort ist wahr, außer Serkans Decken-Satz. Sie steht so im jeweiligen Heft unter
„Wenn der Erzähler fragt“.

**Tandem 1 und 2:**

| Impuls | Sibel | Damir | Hana | Serkan |
|---|---|---|---|---|
| I-1.1 (ein Verdächtiger nennt dich als Zeugen für 23:57) | „Um drei vor zwölf hab ich im Kaminsaal auf der Wandbank gedöst. Bestätigen kann ich da keinen.“ | Bei Ahmet: „Ja. Als ich kurz vor zwölf mit der Teekanne kam, stand Ahmet hinter der Theke am Ostende.“ Sonst: „Ich hab auf meine heiße Kanne geschaut.“ | „Ich hab im Kaminsaal mit dem Gesicht zur Wand Ruß gewischt. Bestätigen kann ich da keinen.“ | „Ich stand im Windfang am Außentor. Da war niemand außer mir.“ |
| I-1.2 Wer war neben dir? | „Niemand. Ich saß allein auf der Wandbank Süd.“ | „Ahmet. Er hat geflüstert: ‚Marek? Ich bin's, Ahmet.‘ Ich hab seine Schulter gespürt.“ | „Niemand. Ich stand allein an der Kamin-Nische.“ | „Niemand. Ich stand allein am Außentor.“ |
| I-1.3 Dem Ruf nicht gefolgt | „Ich. Den Ruf hab ich im Kaminsaal gar nicht gehört. Ich hab gedöst.“ | „Ich war im Ost-Saal. Kurz vor zwölf bin ich mit der Teekanne zur Theke, für den Tortentee.“ | „Ich. Den Ruf hab ich im Kaminsaal nicht gehört. Ich hab Ruß gewischt.“ | Stufe-1-Lüge: „Ich. Ich wollte Decken aus dem Auto holen.“ (zählt als einmal gefragt, 4.7) |
| I-2.1 Geld | „150 € an Ahmet, wie alle. Ich schulde niemandem etwas.“ | „150 € an Ahmet, wie alle. Der Tee kostet nichts.“ | „150 € an Ahmet, wie alle. Ich schulde niemandem etwas.“ | „150 € an Ahmet, wie alle. Fürs Heimfahren nehm ich nichts.“ |
| I-2.2 Turmgang und Bogentür | „Um neun war ich im Turmgang. Die Rüstung. Darüber red ich nicht gern.“ | „Um neun hab ich Sibel zur Turm-Toilette begleitet.“ | „Um zehn vor zwölf hat Tim an der Bogentür ‚Au! Mein Finger!‘ gerufen.“ | „Dazu weiß ich nichts.“ |
| I-2.3 Das Gesicht | „Ich hab es gesehen. Es huschte quer durch den Kaminsaal zur Bogentür. Ich saß auf der Wandbank Süd.“ | „Ich hab am Ostende gekauert. Gesehen hab ich nichts.“ | „Ich hab es auch gesehen, von der Kamin-Nische aus.“ | „Ich stand am Außentor.“ |
| I-3.1 Was kam zuerst? (Runde 3) | „Erst wurde es dunkel. Dann huschte das Gesicht durch den Kaminsaal. Dann blieb es still, bis das Licht anging.“ | „Erst der Knall. Dann kauerte Ahmet neben mir und flüsterte. Dann die Rufe von Herrn Schneider, dann das Scheppern. Ahmet blieb neben mir.“ | Rand-Indiz frei: „Erst das Gesicht im Kaminsaal. Kurz danach roch es nach ausgeblasenen Kerzen, mit dem Luftzug aus Richtung Theke.“ | „Im Windfang hab ich nur dumpfes Rumpeln gehört. Das Tor blieb zu.“ |
| I-3.3 Nach dem Licht | „Kurz nach zwölf kam Can aus dem Turmgang. Geholt hab ich nichts.“ | „Ich hab nichts geholt und nichts weggebracht.“ | „Ich bin mit allen in den Buffetsaal. Geholt hab ich nichts.“ | „Ich kam vom Außentor zurück und hab gerufen: ‚Das Tor ist zu.‘“ |

**Tandem 3 und 4:**

| Impuls | Azra | Wojtek | Aylin | Tugba |
|---|---|---|---|---|
| I-1.1 | „Ich saß im Ost-Saal und hab der blinden Kuh zugeschaut. Bestätigen kann ich da keinen.“ | wie Azra | wie Azra | „Ich stand neben der blinden Kuh. Auf die Theke hab ich nicht geschaut.“ |
| I-1.2 | „Ich saß an der langen Tafel im Ost-Saal, bei den anderen.“ | „Ich saß auf der Wandbank Ost bei meiner Box.“ | „Ich saß an der Tafel, Westseite, meine Mappe auf dem Schoß.“ | „Ich stand neben dem Detektiv beim Ehrenplatz.“ |
| I-1.3 | „Ich bin gefolgt. Ich war im Ost-Saal.“ | „Ich bin gefolgt. Ich hab dem Detektiv meine Kopfhörer aufgesetzt.“ | „Ich bin gefolgt. Ich war im Ost-Saal.“ | „Ich hab doch selbst gerufen. Wer gefehlt hat, hab ich nicht aufgeschrieben. Frag [Joanna \| die Fotografin des Abends], die hat gezählt.“ |
| I-2.1 | „150 € an Ahmet, wie alle. Ich schulde niemandem etwas.“ | „150 € an Ahmet, wie alle. Ich schulde niemandem etwas.“ | „Ich hab Ahmet 150 € gegeben. Nur unter Protest. Ich wollte einen Beleg.“ | „150 € an Ahmet, wie alle. Aylin wollte dafür einen Beleg.“ |
| I-2.2 | „Im Turmgang war ich heute auch mal. Mehr sag ich dazu nicht.“ | „Dazu weiß ich nichts.“ | „Dazu weiß ich nichts.“ | „Dazu weiß ich nichts.“ |
| I-2.3 | „Ich war im Ost-Saal.“ | „Ich war im Ost-Saal.“ | „Ich war im Ost-Saal.“ | „Ich war im Ost-Saal, bei der blinden Kuh.“ |
| I-3.1 | „Knall, Rufe, Scheppern. Gesehen hab ich nichts.“ | „Knall, Rufe, Scheppern. Gesehen hab ich nichts.“ | „Knall, Rufe, Scheppern. Gesehen hab ich nichts.“ | „Knall, Rufe, Scheppern. Der Detektiv hatte die Augenbinde und die Kopfhörer auf.“ |
| I-3.3 | „Um zehn nach zwölf hab ich meinen Skizzenblock von der Wandbank im Kaminsaal geholt.“ (ab Runde 2 dazu das Rand-Indiz, 5.6; P3R2-16) | „Ich hab nichts geholt und nichts weggebracht.“ | „Ich hab nichts geholt. Ich hab gesagt: Den Schlüssel fürs Außentor gibt's nur an seinem Bund und bei seiner Kollegin.“ | „Ich hab dem Detektiv Augenbinde und Kopfhörer abgenommen. Kurz danach hab ich die Handys zurückgegeben.“ |

Die übrigen Impulse (I-1.4, I-2.4, I-3.2, I-3.4) fragen nach Markern oder nach reinem Tisch. Zusatzrollen antworten mit ihrem
offenen Wissen oder machen am Rundenende reinen Tisch (R-05), wenn die Sperre vorbei ist. Ihre Marker stimmen.

#### ZR 0.6 Ortstermine und Aktionskarten anderer Rollen

| Lage | wer antwortet | Antwort (wörtlich, Stufe 1) |
|---|---|---|
| WJ9 Ortstermin hinter der Theke am Ostende | Damir (zusätzlich zu Marek und Ahmet) | „Ich hab hinter der Theke am Ostende gekauert, gleich neben Ahmet. Er hat geflüstert: ‚Marek? Ich bin's, Ahmet.‘ Ich hab seine Schulter gespürt, bis das Licht anging.“ |
| andere Ortstermine (AD3, DM3, FK3, FX3, RH3) | keine Zusatzrolle | Keine Zusatzrolle war dort. |
| „Zeitstempel“ (Joanna), 23:51 oder 23:57 | Sibel | 23:51: „Im Kaminsaal auf der Wandbank Süd.“ Zeugin: [Hana \| niemand am Tisch]. 23:57: „Dasselbe. Gesehen hat mich da keiner, ich hab gedöst.“ |
| dto. | Damir | 23:51: „Im Ost-Saal, beim Teeausschenken.“ Zeuge: [Serkan \| niemand am Tisch]. 23:57: „Erst im Ost-Saal beim Teeausschenken. Gleich danach bin ich mit der Teekanne ans Ostende hinter die Theke.“ Zeuge fürs Ostende: Marek. |
| dto. | Hana | 23:51: „An der Kamin-Nische.“ Zeugin: Sibel. 23:57: „Dasselbe, mit dem Gesicht zur Wand.“ Zeugin: niemand. |
| dto. | Serkan | 23:51: „Im Ost-Saal.“ Zeuge: Damir. 23:57: „Am Außentor.“ Zeuge: niemand. |
| dto. | Azra, Wojtek, Aylin, Tugba | „Im Ost-Saal.“ Zeugin oder Zeuge: der Tandem-Partner, sonst Damir. |
| „Spurenlesen“ (Hana) auf Zone 7 | Sibel, Hana | Sibel: „Es wurde dunkel. Dann rannte jemand. Ich hab das leuchtende Gesicht zur Bogentür huschen sehen.“ Hana vor Runde 3 dasselbe, ohne Geruch; ab Runde 3 mit Geruch (3.6). |
| „Spurenlesen“ auf Zone 4d | Damir | wie WJ9 |
| „Spurenlesen“ auf Zone 1 oder W | Ost-Saal-Rollen, Serkan | „Knall, Rufe, Scheppern, nur gehört.“ Serkan: „Nur dumpfes Rumpeln hinter der Tür.“ |
| „Taschenkontrolle“ (Marek) | jede Zusatzrolle | sagt „Was du bei dir trägst“ (je Rolle Abschnitt .10). Bei Aylin und Tugba ist das ein Auslöser (7.7, 8.7). |
| „Kreuzverhör“, „Gelbe Karte“, „Noch mal rückwärts“, „Beleg bitte!“ | jede Zusatzrolle | antwortet nach Stufe 1. |

Zeitstempel-Zeugen sind gegenseitig abgesichert, aber nur für 23:51 (um 23:57 döst Sibel, und Hana wischt mit dem Gesicht zur
Wand, P3-10): Hanas Heft nennt Sibel auf der Wandbank, Sibels Heft nennt Hana an der Nische, Damir schenkte im Ost-Saal allen Tee ein (2.5), Damirs Heft nennt Marek (ZG 5.4 nennt den Gast mit der Teekanne).

#### ZR 0.7 Aufbau des Zusatzhefts (Teil 12, A4 hoch, drei Seiten; P145R2-M06)

| Seite | Abschnitte (in dieser Reihenfolge) |
|---|---|
| 1 | Kopf „Zusatzheft · [Name] · Platz [Nr] · Tandem [n]“ · „Dein Auftritt bei der Vorstellung“ · „Wer du bist“ (Wortlaut nach dem Muster unten) · „Dein Tandem“ (Kasten) · „Deine Marker“ (Wortlaut unten) · „Was alle wissen“ (MECH §1.5, gleich lautend) |
| 2 | „Was du weißt“ · „Stufe 1“ (sagst du jedem, behältst du für dich, verboten) · „Wenn der Erzähler fragt“ (Impuls-Antworten 0.5) |
| 3 | „Stufe 2: Wann du umdrehst“ · „Nach dem Umdrehen“ · „Gesprächsaufträge Runde 1–3“ (ohne die Spalte „Worauf du hinauswillst“) · „Deine Aktionskarte“ · „Was du bei dir trägst“ (Ich-Form) · „Dein Bonus-Ziel“ · „Wenn du angeklagt wirst: ‚Ich war es nicht.‘“ · nur beim kleineren Platz und nur bei ungerader Zahl: „Du spielst dein Tandem allein“ · „So spielt ihr“ (MECH §1.4, Kurzform) · unten, **wörtlich**: „Jede Person kann [Name] spielen, egal welches Geschlecht sie hat.“ (P5-K10) |

Gezählt am Beispiel Hana sind es rund 1.950 Wörter und drei Tabellen; zwei Seiten fassen in 9 pt etwa 1.500 Wörter. Darum
hat das Zusatzheft drei Seiten (P145R2-M06). Die Spalte „Worauf du hinauswillst“ ist Arbeitshilfe und wird nicht gedruckt
(P2-22). „Was du bei dir trägst“ steht in der Ich-Form, weil die Person es vorliest (P145R2-K09).

**„Wer du bist“** folgt dem Muster ZG 0.6: Name und Alter mit Rollenbezeichnung, Beruf, Merkmal, Beziehungen als Tatsache
mit Platzhaltern, dann „Was dich heute antreibt:“ und das Kanon-Ziel aus x.1. Der Generator setzt den Text aus dem Profil
x.1 nach diesem Muster (P145R2-K18). Beispiel Sibel, **wörtlich**: „Du bist Sibel, 23, die Vorsichtige. Du studierst
Biologie. Man erkennt dich am rosa Strickpulli und am weißen Fransenschal bis übers Kinn. Mit Zeynep wohnst du in einer WG.
[Damir hat dich um neun zur Turm-Toilette begleitet. |] Was dich heute antreibt: Die Rüstung soll aus dem Turmgang
verschwinden.“

**„Deine Marker“ (wörtlich, Feldnamen nach WELT §2.1; P3R2-18):**

| Rolle | Markerzeile |
|---|---|
| Sibel, Hana | „Marker 23:57: Kaminsaal (7). Marker Scheppern: Kaminsaal (7). Beide stimmen.“ |
| Damir | „Marker 23:57: Ost-Saal (1). Marker Scheppern: Theke Ostende (4d). Beide stimmen.“ |
| Serkan | „Marker 23:57: Windfang (W). Marker Scheppern: Windfang (W). Beide stimmen.“ |
| Azra, Wojtek, Aylin, Tugba | „Marker 23:57: Ost-Saal (1). Marker Scheppern: Ost-Saal (1). Beide stimmen.“ |

Die Geheimniskarte steht nicht im Heft, sondern liegt am Tisch (MECH §10.3). Ihr Inhalt steht im Heft unter „Stufe 2“ als
„Was du dann zugibst“, damit die Person ihn vorher kennt. Geheimniskarten fehlender Zusatzrollen werden nicht gedruckt
(MECH §4.1).

### ZR 1 · Sibel (Platz 11) – die Vorsichtige · Tandem 1

#### ZR 1.1 Profil

| Feld | Inhalt |
|---|---|
| Platz, Stellung | 11, Zusatzrolle, Tandem 1. Spielt ab 13 Personen; bei 13 Personen allein (1.12) |
| Alter, Beruf | 23, Biologiestudium. Fürchtet sich vor nichts außer alten Rüstungen |
| Rollenbezeichnung | Die Vorsichtige (Kanon `figuren.json`, selin) |
| Merkmal | rosa Strickpulli, weißer Fransenschal bis übers Kinn |
| Beziehungen | **[Damir \| –]**: hat sie um 21:00 zur Turm-Toilette begleitet; Tandem. **Zeynep**: Mitbewohnerin in einer WG. Zeynep ist laut und früh wach |
| Verfehlung | Verschweigen: der Sprung in der Vitrine (WELT §7.4) |
| Haltung (wörtlich im Heft) | „Du bist ehrlich, nur sehr schreckhaft. Über den Turmgang redest du ungern. Lügen tust du nicht.“ |
| Kanon-Ziel | Die Rüstung soll aus dem Turmgang verschwinden (WELT §7.3) |

#### ZR 1.2 Marker

| Marker | behauptet (Stufe 1) | wahr | Umstellen |
|---|---|---|---|
| 23:57 | 7 Kaminsaal | 7, Wandbank Süd, sitzt, döst | nie |
| Scheppern | 7 Kaminsaal | 7, dto., wach | nie |

#### ZR 1.3 Vorstellungsrunde

- **Frage des Erzählers (wörtlich, Vorlesen):** „Sibel, die Vorsichtige. Du sagst, du fürchtest dich vor gar nichts. Warum
  machst du dann seit neun Uhr einen großen Bogen um den Turmgang?“
- **Dein Auftritt (wörtlich, Ich-Form, Vorlesetext):** „Ich bin Sibel und studiere Biologie. Spinnen, Schlangen, Prüfungen:
  alles kein Problem. Nur alte Rüstungen. Um neun stand im Turmgang plötzlich ein Ritter vor mir. Ich hab so laut geschrien,
  dass das Gewölbe gewackelt hat. Der Ritter hat sich nicht bewegt. [Damir war dabei. Er sagt, er hat sich nur ein bisschen
  erschrocken. |] Seitdem geh ich da nicht mehr hin. Und ja, ich hab euch alle lachen gehört.“
- Anekdote: Dia 3, Schreck vor der Ritterrüstung (WELT D-28, Kanon `intro.lacher.lacher_ruestung.besetzt`). Der Sprung in der
  Scheibe fehlt bewusst: Er ist Sibels Geheimnis (WELT §3.3: „vom Sprung weiß niemand sonst“).

#### ZR 1.4 Dein Tandem (Kasten im Heft, wörtlich)

„Um 21:00 Uhr hast du im Turmgang vor Schreck die Schauvitrine angestoßen. Die Scheibe bekam einen Sprung, ein paar Splitter
sprangen ab. [Damir war dabei. Er hat die Splitter unter den Sockel der Rüstung gekehrt. | Ein Gast hat dich begleitet und die
Splitter unter den Sockel der Rüstung gekehrt.] Ihr habt beide geschwiegen. Kommt heute die Vitrine zur Sprache, kommt auch dein
Sprung heraus. Du hast Angst, dass man ihn jemand anderem anhängt. Oder dir.“

#### ZR 1.5 Wissen

**Sicher** (frei ab: „offen“ = Stufe 1 sofort; „Karte“ = erst nach dem Umdrehen):

| Zeit | Was Sibel weiß | Quelle | frei ab |
|---|---|---|---|
| 18:00 | zahlt Ahmet 150 € „Miete“ in Bargeld; unterschreibt beim Einlass die Dankeskarte | WELT §3.3 | offen |
| 20:15 | Lacher: Olli steht im dunklen Vorratsraum vor der Torte, [Azra \| ein Gast] ruft „Einbrecher an der Torte!“ | MECH §1.5 | offen |
| 21:00 | Turmgang mit [Damir \| einem Gast]: Schrei vor der Rüstung | WELT §3.3 | offen |
| 21:00 | stolpert rückwärts gegen die Schauvitrine. Sprung, Splitter von der Ecke. In der Vitrine liegt die Münzschatulle mit dem Wappen. [Damir \| Der Gast] kehrt die Splitter unter den Sockel der Rüstung. Seitdem ist die Scheibe lose | WELT §3.3, §6 | Karte |
| seit 21:00 | geht nicht mehr in den Turmgang | Kanon `figuren.json` | offen |
| 23:00 | sitzt im Ost-Saal beim Ratespiel; Herr Schneider wird an der Theke laut, die Worte versteht sie nicht | WELT W-27 | offen |
| 23:50 | sitzt im Kaminsaal auf der Wandbank Süd. [Hana \| Ein Gast] steht an der Kamin-Nische. An der langen Tafel sitzen Can und Zeynep. An der Bogentür stehen Olli und Tim; Tim ruft „Au! Mein Finger!“. Kurz danach geht Olli Richtung Durchgang | WELT §3.4, ZR-05 | offen |
| ab etwa 23:54 | döst, den Schal bis übers Kinn | WELT §3.4 | offen |
| 23:58 | plötzlich stockdunkel. Knall, Rufe und Scheppern hört sie im Kaminsaal nicht | WELT §2.7, §5.1 | offen |
| kurz danach | rennende Schritte. Ein leuchtendes Gesicht huscht vom Steinbogen quer durch den Kaminsaal zur Bogentür. Dann ist es weg | WELT §5.2, §7.3 | offen (Rand-Indiz) |
| 0:00 | Licht. Zeynep steht im Steinbogen, [Hana \| ein Gast] an der Kamin-Nische | WELT §3.4, ZR-05 | offen |
| 0:01 | Can kommt durch die Bogentür aus dem Turmgang und setzt sich auf die Wandbank West. Zeynep geht zu ihm | WELT §3.5, ZR-05 | offen |
| 0:03 | geht mit allen in den Buffetsaal: Bund weg, Tor zu, kein Empfang. Bleibt bei den anderen | WELT §3.5, W-15 | offen |

**Vermutet:** Das Gesicht war ein Streich und ist in den Turm gerannt (stimmt). Can könnte das Gesicht gewesen sein (stimmt,
nur Vermutung). Herr Schneider wird den Sprung jemand anderem anhängen (Sorge).

**Weiß nicht:** Knall, Rufe und Scheppern kennt sie nur vom Hörensagen; was im Buffetsaal geschah; dass die Schatulle fehlt
(bis FM9 offen liegt); wer die Schatulle hat; wo der Bund ist.

#### ZR 1.6 Stufe 1

**Das sagst du jedem (wörtlich):**
- „Um neun hab ich im Turmgang die Ritterrüstung für einen Menschen gehalten und geschrien. Seitdem mach ich um den Turmgang
  einen großen Bogen.“
- „Um zehn vor zwölf saß ich im Kaminsaal auf der Wandbank Süd. An der Bogentür standen Olli und Tim. Tim hat ‚Au! Mein
  Finger!‘ gerufen. An der langen Tafel saßen Can und Zeynep.“
- „Dann hab ich gedöst. Auf einmal war es stockdunkel. Einen Knall hab ich im Kaminsaal nicht gehört, auch kein Scheppern.“
- „Im Dunkeln huschte ein leuchtendes Gesicht vom Steinbogen quer durch den Kaminsaal zur Bogentür. Dann war es weg.“
  (Rand-Indiz, WELT §7.3)
- „Als das Licht anging, stand Zeynep im Steinbogen. Kurz danach kam Can aus dem Turmgang und setzte sich auf die Wandbank.
  Zeynep ist gleich zu ihm.“

**Das behältst du für dich (wörtlich):**

| Wenn jemand fragt | sagst du |
|---|---|
| ob du an der Vitrine warst, ob etwas kaputtging | „Frag mich nicht nach diesem Turmgang. Da krieg ich schon Gänsehaut, wenn ich nur dran denke.“ |
| wer bei dir war, als du geschrien hast | „[Damir hat mich begleitet. \| Ein Gast hat mich begleitet.]“ |
| nach der Münzschatulle | „In der Vitrine liegt so eine alte Schatulle, ja. Ich hab vor allem auf die Rüstung gestarrt.“ |
| ob das Gesicht vor oder nach dem Scheppern kam | „Das Scheppern hab ich nicht gehört. Ich weiß nur: Es wurde dunkel, dann kam das Gesicht.“ |

**Verboten:** „Ich war nicht an der Vitrine.“ · „Die Vitrine war heil.“ · „Ich hab im Dunkeln nichts gesehen.“ · „Das Gesicht
kam vor dem Scheppern.“ (Das weiß sie nicht.)

#### ZR 1.7 Stufe 2

**Rundensperre:** keine.

**Wann du umdrehst (wörtlich im Heft):**
1. „Sobald die Indizkarte FM9 oder YT4 offen auf dem Tisch liegt.“ (MECH §4.2)
2. „Sobald Damirs Geheimniskarte offen auf dem Tisch liegt.“ (ZR-03, nur wenn Damir gespielt wird)
3. „Sobald jemand vor allen sagt, eine andere Person habe die Vitrine kaputt gemacht oder aufgebrochen.“ (ZR-03)

**Geheimniskarte, Innenseite (wörtlich):**

> **Was ich zugebe**
> „Um 21:00 Uhr hab ich im Turmgang die Ritterrüstung für einen Menschen gehalten. Ich hab geschrien und bin rückwärts gegen
> die Schauvitrine gestolpert. Die Scheibe bekam einen Sprung, ein paar Splitter sprangen ab. Ich hab mich nicht getraut, es
> Herrn Schneider zu sagen. Das tut mir leid.“
>
> **Für den Ermittlungsbogen**
> „Hinweis: Der Sprung in der Vitrinenscheibe war schon um 21:00 Uhr da.“ (MECH §4.2 wörtlich)
>
> **Und noch etwas**
> mit Damir: „Damir war dabei. Er weiß, wo die Splitter geblieben sind.“
> allein (13 Personen): „Um 21:00 Uhr lag die Münzschatulle noch in der Vitrine. Seitdem war die Scheibe lose. Man musste sie
> nur anheben.“

**Nach dem Umdrehen** sagst du auf Nachfrage außerdem (wörtlich):
- „Um 21:00 Uhr lag die Münzschatulle noch in der Vitrine. Seitdem war die Scheibe lose. Man musste sie nur anheben.“ (mit
  Damir; allein steht es schon auf der Karte)
- „Die Schatulle hab ich nicht angefasst.“
- „Seitdem war ich nicht mehr im Turmgang.“

#### ZR 1.8 Nachbohr-Ziele

| Runde | Nr | Ziel | Frage oder Vorwurf (wörtlich) | Worauf du hinauswillst | Ausweichziel |
|---|---|---|---|---|---|
| 1 | 1 | Can | „Can, du sagst, du warst auf der Turm-Toilette. Um zehn vor zwölf hast du aber noch mit Zeynep an der langen Tafel gesessen. Und im Dunkeln ist ein leuchtendes Gesicht genau Richtung Turm gehuscht. Wann bist du hoch?“ | Druck auf Cans Marker; Gegengewicht zu Olli (MECH §3.5 Nr. 3) | – (immer besetzt) |
| 1 | 2 | Zeynep | „Zeynep, als um zwölf das Licht anging, standest du im Steinbogen. Nicht im Ost-Saal bei der blinden Kuh. Und kaum kam Can aus dem Turm, warst du bei ihm. Auf wen hast du gewartet?“ | Druck auf Zeyneps Schmiere | – (immer besetzt) |
| 2 | 1 | Fatma | FM9 offen (dann ist auch deine Karte offen): „Fatma, ja, ich hab um neun die Scheibe angestoßen. Aber da lag die Münzschatulle noch drin. Jetzt fehlt sie. Und deine Tasche ist ganz schön ausgebeult.“ FM9 zu: „Fatma, deine Tasche ist heute ganz schön ausgebeult. Was trägst du da mit dir herum?“ | Fatmas Heimlichtuerei (M5); lenkt zu NN3 | – (immer besetzt) |
| 2 | 2 | Ahmet | „Ahmet, 150 € für einen Keller mit einer Rüstung, die Leute erschreckt! Hast du das Geld Herrn Schneider schon gegeben? Oder ist es noch bei dir?“ | Ahmets Heimlichtuerei (M4); lenkt zu PM3 und WM9 | – (immer besetzt) |
| 3 | 1 | Olli | „Olli, um zehn vor zwölf standest du mit Tim an der Bogentür. Kurz danach warst du weg. Wo warst du, als es überall dunkel wurde?“ | Druck auf Ollis Weg | – (immer besetzt) |
| 3 | 2 | Can | Cans Karte offen: „Can, du warst das Gesicht, das an mir vorbeigehuscht ist. Sag allen, ob Herr Schneider noch gerufen hat, als du schon weg warst.“ Cans Karte zu: „Can, das leuchtende Gesicht ist zum Turm gehuscht, und kurz danach kamst du aus dem Turm. Wenn du das warst: Was war an der Theke, als du losgerannt bist?“ | Cans Alibi (M3) in Runde 3 | – (immer besetzt) |

#### ZR 1.9 Aktionskarte (wörtlich, MECH §4.4)

| Feld | Text |
|---|---|
| Kopf | „Aktionskarte · Sibel“ |
| Name | **Noch mal rückwärts** · ab Runde 1 · Klasse Frage |
| Wirkung | „Eine Person deiner Wahl erzählt ihre Nacht noch einmal, diesmal rückwärts: vom Licht um zwölf zurück bis 23:57 Uhr. Alle hören zu.“ |
| Grenzen | „Lügen nach Stufe 1 bleibt erlaubt. Die Person darf sich kurz besinnen.“ |
| Fuß | „Einmal im Spiel. Danach umdrehen.“ |
| Tipp im Heft (nicht auf der Karte) | „Gut bei jemandem, dessen Geschichte zu glatt klingt. Rückwärts fällt eine ausgedachte Reihenfolge schneller auf.“ |

#### ZR 1.10 Was du bei dir trägst (für die Taschenkontrolle, wörtlich)

„Ich hab meinen Fransenschal, ein Päckchen Taschentücher und ein kleines Bestimmungsbuch für Moose. Mein Handy hab ich seit
kurz nach zwölf zurück.“

#### ZR 1.11 Bonus-Ziel und fehlende Rollen

- **Wörtlich:** „**Dein Bonus-Ziel:** Du stehst zu deinem Sprung, bevor man ihn jemand anderem anhängt. **Erfüllt, wenn** du
  deine Geheimniskarte selbst umgedreht hast, bevor die Indizkarte FM9 oder YT4 offen lag.“
- „Selbst umgedreht“ heißt: reinen Tisch am Rundenende oder durch Auslöser 2 oder 3. Prüfung in Teil 90: Der Tisch bestätigt
  die Reihenfolge (Typ „Reinen Tisch“, MECH §7.3).
- Erreichbar bei 13 bis 20 Personen: Reinen Tisch geht immer am Ende von Runde 1, bevor die Untersuchungen beginnen.

| fehlt | Folge für Sibel |
|---|---|
| Damir | Solo-Abschnitt 1.12 |
| Hana | Zeitstempel ohne Zeugin („niemand am Tisch“); im Wissen „ein Gast an der Kamin-Nische“ |
| Azra | „ein Gast“ im 20:15-Satz (schon in MECH §1.5) |
| Sibel selbst | Der Erzähler liest den Ausfalltext zur Rüstung (MECH §9.4). Karten werden nicht gedruckt |

#### ZR 1.12 Solo-Abschnitt (bei 13 Personen, im Heft wörtlich)

„**Du spielst dein Tandem allein.** Wer dich um neun begleitet hat, spielt heute niemand. Sag dann ‚ein Gast‘. Deine Karte
endet mit dem Satz über die Münzschatulle. Alles andere gilt wie gedruckt.“

Generator: druckt im Auftritt keinen Damir-Satz, im Tandem-Kasten, im Wissen und im Tarnsatz die Ersatzfassung, auf der Karte
die Solo-Zeile unter „Und noch etwas“. Auslöser 2 wird nicht gedruckt; die Nummern rücken nach.

#### ZR 1.13 Absatz für Teil 90, „Die Rollen am Tisch“ (wörtlich, Vorlesen)

„Sibel erschrak um neun vor der Ritterrüstung und stieß rückwärts gegen die Schauvitrine. Seitdem hatte die Scheibe einen
Sprung. Im Dunkeln sah sie das leuchtende Gesicht durch den Kaminsaal zum Turm huschen.“

### ZR 2 · Damir (Platz 12) – der Teemeister · Tandem 1

#### ZR 2.1 Profil

| Feld | Inhalt |
|---|---|
| Platz, Stellung | 12, Zusatzrolle, Tandem 1. Spielt ab 14 Personen; Sibel ist dann immer dabei |
| Alter, Beruf | 25, Erzieher. Teemeister des Abends |
| Rollenbezeichnung | Der Teemeister (Kanon, enes) |
| Merkmal | weißes Hemd mit hochgekrempelten Ärmeln, schwarze Schürze, große Teekanne |
| Beziehungen | **Sibel**: Er hat sie um 21:00 zur Turm-Toilette begleitet; Tandem. **Emine**: Er betreut nachmittags Kinder aus ihrer Klasse. **[Tugba \| –]**: Bei ihren Spieleabenden kocht er den Tee |
| Verfehlung | Verschweigen: hat die Splitter unter den Sockel der Rüstung gekehrt (WELT §7.4) |
| Haltung (wörtlich im Heft) | „Du schenkst Tee aus und hörst zu. Du petzt nicht, aber du lügst auch nicht.“ |
| Kanon-Ziel | Sein Ärger mit Herrn Schneider über das Teegeschirr soll nicht zur Sprache kommen (Kanon `figuren.json`, enes) |

#### ZR 2.2 Marker

| Marker | behauptet (Stufe 1) | wahr | Umstellen |
|---|---|---|---|
| 23:57 | 1 Ost-Saal | 1, an der langen Tafel mit der Teekanne; ab 23:57:30 unterwegs zum Ostende | nie |
| Scheppern | 4d Theke Ostende | 4d, hinter der Theke am Ostende, kauert neben Ahmet | nie |

#### ZR 2.3 Vorstellungsrunde

- **Frage des Erzählers (wörtlich, Vorlesen):** „Damir, der Teemeister. Bei dir lehnt niemand ein Glas Tee ab. Hat es heute
  überhaupt schon jemand gewagt?“
- **Dein Auftritt (wörtlich, Ich-Form, Vorlesetext):** „Ich bin Damir, Erzieher, und heute euer Teemeister. Ein Glas Tee
  lehnt bei mir keiner ab. Ich bestehe darauf. Nachmittags betreue ich Kinder aus Emines Klasse. Die trinken wenigstens Kakao.
  Um neun hab ich Sibel zur Turm-Toilette begleitet. Seitdem weiß ich: Sibel schreit lauter, als jeder Wasserkessel pfeift.
  Noch ein Glas?“
- Anekdote: Er war bei Dia 3 dabei (Rüstung, „mit Damir“, WELT D-28). Der Sprung fehlt bewusst.

#### ZR 2.4 Dein Tandem (Kasten im Heft, wörtlich)

„Um 21:00 Uhr hast du Sibel zur Turm-Toilette begleitet. Sie ist vor der Rüstung erschrocken und gegen die Schauvitrine
gestoßen. Die Scheibe bekam einen Sprung. Du hast die Splitter schnell unter den Sockel der Rüstung gekehrt. Ihr habt beide
geschwiegen. Herr Schneider ist heute ohnehin sauer auf dich, wegen des Teegeschirrs. Mehr Ärger willst du nicht. Aber niemand
soll für euren Sprung geradestehen.“

#### ZR 2.5 Wissen

**Sicher:**

| Zeit | Was Damir weiß | Quelle | frei ab |
|---|---|---|---|
| 18:00 | zahlt Ahmet 150 €; unterschreibt beim Einlass die Dankeskarte | WELT §3.3 | offen |
| ab 19:00 | schenkt Tee aus, im Teegeschirr des Schlosses. Herr Schneider wirft ihm vor, es ohne Erlaubnis zu benutzen | Kanon `figuren.json`, WELT §1.7, §7.3 | offen, dass er Tee ausschenkt; den Vorwurf behält er für sich |
| 21:00 | begleitet Sibel zur Turm-Toilette; Schrei vor der Rüstung | WELT §3.3 | offen |
| 21:00 | Sibel stößt gegen die Schauvitrine, Sprung, Splitter. In der Vitrine liegt die Münzschatulle. Er kehrt die Splitter unter den Sockel der Rüstung. Beide schweigen | WELT §3.3 | Karte |
| 23:00 | Ost-Saal, Ratespiel; Herr Schneider wird an der Theke laut, die Worte versteht er nicht | WELT W-27 | offen |
| 23:50–23:57 | schenkt im Ost-Saal allen Tee aus, die dort sitzen | WELT §3.4 | offen |
| 23:54 | Olli setzt sich an den Kopf der Tafel. Wann er wieder aufstand, hat Damir nicht gesehen; er hat gerade eingeschenkt | WELT §3.4, P3-20 | offen |
| 23:55 | [Tugba \| Ein Gast] ruft zur blinden Kuh. Sein Handy liegt seit dem Ratespiel um elf im Korb | WELT §3.3, §3.4 | offen |
| 23:57 | trägt die große Teekanne ans Ostende hinter die Theke, für den Tortentee. Herr Schneider geht gerade hinter der Theke zur Kaffeemaschine und steht im Weg. Damir wartet hinter Marek. Ahmet steht ganz am Ostende. Er schaut auf die heiße Kanne, nicht auf den Eiskübel | WELT §1.7, §3.4, §5.5 | offen |
| 23:57 | hört Herrn Schneider laut: „Nicht die alte Leiste!“ | WELT §5.6 | offen |
| 23:58 | Knall. Er kauert sich am Ostende hin, damit er nicht an heiße Kannen stößt. Herr Schneider ruft: „Ruhe! Ich hol die Notlaterne.“ | WELT §3.4, §5.1; Kanon blackoutAlibi | offen |
| danach | Direkt neben ihm flüstert Ahmet: „Marek? Ich bin's, Ahmet.“ Damir spürt Ahmets Schulter | WELT §5.3, §7.3 | offen (Rand-Indiz) |
| danach | „Hab ich dich!“, zweimal „Stehen bleiben!“, dann das Scheppern. Ahmet ist die ganze Zeit neben ihm | WELT §5.1, §5.3 | offen |
| 0:00 | Licht. Ahmet steht neben ihm auf, einen dicken Umschlag in der Hand. Marek geht zur Vorratsraumtür: „Hier liegt Herr Schneider!“ | WELT §3.4 | Umschlag: Karte; der Rest offen |
| 0:03 | Buffetsaal: Bund weg, Tor zu | WELT §3.5 | offen |

**Vermutet:** Ahmet wollte mit dem Umschlag zu Herrn Schneider (stimmt). Der Sprung wird jetzt jemand anderem angehängt (Sorge).

**Weiß nicht:** wer am Eiskübel stand (Kanne); was an der Vorratsraumtür geschah (kauerte); wer das Gesicht war; wo der Bund
ist; was mit der Schatulle ist.

#### ZR 2.6 Stufe 1

**Das sagst du jedem (wörtlich):**
- „Noch ein Glas Tee? Ich bestehe darauf.“
- „Um neun hab ich Sibel zur Turm-Toilette begleitet. Sie hat vor der Rüstung geschrien. Seitdem trau ich der Rüstung auch
  nicht mehr.“
- „Kurz vor zwölf hab ich die große Teekanne ans Ostende hinter die Theke getragen, für den Tortentee. Herr Schneider stand im
  Weg, also hab ich hinter Marek gewartet.“
- „Beim Knall hab ich mich am Ostende hingekauert, wegen der heißen Kanne.“
- „Direkt neben mir hat Ahmet geflüstert: ‚Marek? Ich bin's, Ahmet.‘ Ich hab seine Schulter gespürt. Beim Scheppern war er
  noch da, bis das Licht anging.“ (Rand-Indiz, WELT §7.3)

**Das behältst du für dich (wörtlich):**

| Wenn jemand fragt | sagst du |
|---|---|
| ob bei Sibels Schrei etwas kaputtging | „Sibel hat sich erschrocken. Mehr sag ich dazu nicht.“ |
| ob Ahmet etwas in der Hand hatte | „Frag Ahmet. Ich petze nicht.“ |
| was Herr Schneider dir vorgeworfen hat | „Wir hatten eine kleine Meinungsverschiedenheit über Teegläser. Noch ein Glas?“ |
| wer am Eiskübel stand | „Ich hab auf die heiße Kanne geschaut, nicht auf den Eiskübel.“ |

**Verboten:** „Bei Sibel ist nichts kaputtgegangen.“ · „Ahmet hatte nichts in der Hand.“ · „Ich war heute nie im Turmgang.“

#### ZR 2.7 Stufe 2

**Rundensperre:** keine.

**Wann du umdrehst (wörtlich im Heft):**
1. „Sobald die Indizkarte YT4 offen auf dem Tisch liegt.“ (MECH §4.2)
2. „Sobald Sibels Geheimniskarte offen auf dem Tisch liegt.“ (ZR-03)
3. „Sobald jemand vor allen sagt, eine andere Person habe die Vitrine kaputt gemacht oder aufgebrochen.“ (ZR-03)

**Geheimniskarte, Innenseite (wörtlich):**

> **Was ich zugebe**
> „Um 21:00 Uhr hab ich Sibel zur Turm-Toilette begleitet. Sie ist vor der Rüstung erschrocken und gegen die Schauvitrine
> gestolpert. Die Scheibe bekam einen Sprung. Ein paar Splitter sprangen von der Ecke. Ich hab sie schnell unter den Sockel der
> Rüstung gekehrt. Dann haben wir beide geschwiegen.“
>
> **Für den Ermittlungsbogen**
> „Hinweis: Die Glassplitter unter dem Sockel der Rüstung sind von 21:00 Uhr. Seitdem hatte die Vitrinenscheibe einen Sprung.“
>
> **Und noch etwas**
> „Als um zwölf das Licht anging, stand Ahmet neben mir auf. Er hielt einen dicken Umschlag fest in der Hand.“

**Nach dem Umdrehen** sagst du auf Nachfrage außerdem (wörtlich):
- „Ich petze nicht gern. Aber was auf meiner Karte steht, stimmt.“
- „Herr Schneider hat mir heute vorgeworfen, das Teegeschirr des Schlosses ohne Erlaubnis zu benutzen. Ich wollte ihn nicht
  noch mehr ärgern.“
- „Um 21:00 Uhr lag die Münzschatulle noch in der Vitrine.“

#### ZR 2.8 Nachbohr-Ziele

| Runde | Nr | Ziel | Frage oder Vorwurf (wörtlich) | Worauf du hinauswillst | Ausweichziel |
|---|---|---|---|---|---|
| 1 | 1 | Tim | „Tim, kurz vor dem Knall hat Herr Schneider dir zugerufen: ‚Nicht die alte Leiste!‘ Ich stand am Ostende und hab es genau gehört. Was hast du an der Kaffeemaschine gemacht?“ | Druck auf Tims Knall; lenkt zu MR4 | – (immer besetzt) |
| 1 | 2 | Emine | „Emine, du warst beim Knall hinter dem linken Buffettisch. Wer hat sich da neben dich gekauert? Ich frag, weil ich am Ostende auch nicht allein war.“ | Fatmas Alibi (M2) kommt laut auf den Tisch | – (immer besetzt) |
| 2 | 1 | Ahmet | Karte offen: „Ahmet, du hast im Dunkeln neben mir gekauert, das sag ich jedem. Aber als das Licht anging, hattest du einen dicken Umschlag in der Hand. Was wolltest du damit hinter der Theke?“ Karte zu: „Ahmet, beim Knall warst du hinter der Theke am Ostende, direkt neben mir. Um fünf vor zwölf sollten alle in den Ost-Saal. Was wolltest du da hinten?“ | Ahmets Heimlichtuerei (M4) | – (immer besetzt) |
| 2 | 2 | Sibel | Sprich leise mit Sibel: „Wenn am Tisch die Vitrine Thema wird und jemand anderes für unseren Sprung geradestehen soll: Sagen wir es dann selbst, am Ende der Runde?“ | Tandem 1 spielt seine Mini-Intrige aus; beide können am Rundenende reinen Tisch machen (R-05, P14-09) | – (immer besetzt) |
| 3 | 1 | Marek | „Marek, du hast beim Knall gestanden, direkt vor mir, und an der Anrichte brannten noch die Kerzen. Was hast du an der Vorratsraumtür gesehen, bevor es schepperte?“ | Mareks Gesprächs-Auslöser in Runde 3 (ZG 5.6, D11, D12) | – (immer besetzt) |
| 3 | 2 | Can | „Can, Herr Schneider hat ‚Hab ich dich!‘ gebrüllt und danach noch zweimal ‚Stehen bleiben!‘. Ich hab das am Ostende gehört. Wenn du das Gespenst warst: Bist du vor oder nach dem Scheppern weggerannt?“ | Cans Alibi (M3) in Runde 3 | – (immer besetzt) |

#### ZR 2.9 Aktionskarte (wörtlich, MECH §4.4)

| Feld | Text |
|---|---|
| Kopf | „Aktionskarte · Damir“ |
| Name | **Teepause** · ab Runde 1 · Klasse Frage |
| Wirkung | „Zwei Personen deiner Wahl setzen sich mit dir zur Seite und reden drei Minuten miteinander. Du hörst zu. Danach sagst du dem Detektiv einen Satz daraus.“ |
| Grenzen | „Dein Satz muss stimmen.“ |
| Fuß | „Einmal im Spiel. Danach umdrehen.“ |
| Tipp im Heft | „Gut, wenn zwei sich widersprechen. Setz sie mit dir zur Seite und schenk Tee ein. Dein Satz an den Detektiv muss stimmen.“ |

#### ZR 2.10 Was du bei dir trägst (wörtlich)

„In der Schürzentasche ein Teesieb und ein weißes Tuch zum Polieren der Gläser. Mein Handy hab ich seit kurz nach zwölf
zurück.“

#### ZR 2.11 Bonus-Ziel und fehlende Rollen

- **Wörtlich:** „**Dein Bonus-Ziel:** Was du im Dunkeln gehört hast, soll zählen. **Erfüllt, wenn** bei der Anklage auf dem
  Ermittlungsbogen bei Ahmets Alibi ein ✓ steht und dein Name als Quelle dabei, allein oder neben anderen.“
- Prüfbar: Der Bogen verlangt die Quelle in jeder Zelle (MECH §2.1). Damir muss es dem Detektiv selbst sagen. Erreichbar bei
  14 bis 20 Personen, Marek ist immer dabei.

| fehlt | Folge für Damir |
|---|---|
| Sibel | kommt nicht vor: Sibel spielt immer, wenn Damir spielt (E6) |
| Serkan und Zusatzrollen 15–18 | Zeitstempel 23:51 ohne Zeugen am Tisch; Platzhalter im Wissen entfallen |
| Tugba | Beziehung entfällt |
| Damir selbst | Marek nennt ihn „ein Gast mit der großen Teekanne“ (ZG Z-18, RK 1.5). Sein Rand-Indiz fällt weg; Marek trägt M1 |

#### ZR 2.12 Wenn der Partner fehlt

Kommt nicht vor (E6). Damir spielt nie allein.

#### ZR 2.13 Absatz für Teil 90 (wörtlich, Vorlesen)

„Damir kehrte die Splitter von Sibels Missgeschick unter den Sockel der Rüstung und schwieg. Beim Knall kauerte er am Ostende
neben Ahmet und hörte sein Flüstern. So wurde er ein zweiter Zeuge für Ahmets Alibi.“

### ZR 3 · Hana (Platz 13) – die Kamin-Heizerin · Tandem 2

#### ZR 3.1 Profil

| Feld | Inhalt |
|---|---|
| Platz, Stellung | 13, Zusatzrolle, Tandem 2. Spielt ab 15 Personen; bei 15 Personen allein (3.12) |
| Alter, Beruf | 25, Försterin. Kennt Holz besser als Kaminzüge |
| Rollenbezeichnung | Die Kamin-Heizerin (Kanon, meryem) |
| Merkmal | Jeanshemd, Arbeitshose, Schnürstiefel, Rußflecken an Wange und Händen |
| Beziehungen | **[Serkan \| –]**: hat sie am Kamin gesehen, sie kennt seinen Plan; Tandem. **Tim**: repariert ihre Motorsäge, dafür bekommt er Brennholz |
| Verfehlung | Nebendelikt: Kamin ohne Klappe angefeuert. Verschweigen: der Brief (WELT §7.4) |
| Haltung (wörtlich im Heft) | „Du lachst am lautesten über dich selbst. Aber dein Brief geht niemanden etwas an. Lügen tust du nicht.“ |
| Kanon-Ziel | Den Kamin wieder zum Ziehen bringen und sich bei Herrn Schneider für den Ruß entschuldigen (WELT §7.3) |

#### ZR 3.2 Marker

| Marker | behauptet (Stufe 1) | wahr | Umstellen |
|---|---|---|---|
| 23:57 | 7 Kaminsaal | 7, an der Kamin-Nische, wischt mit dem Gesicht zur Wand Ruß ab | nie |
| Scheppern | 7 Kaminsaal | 7, dto., hat sich umgedreht | nie |

#### ZR 3.3 Vorstellungsrunde

- **Frage des Erzählers (wörtlich, Vorlesen):** „Hana, die Kamin-Heizerin. Im Wald kennst du jeden Baum beim Namen. Warum hat
  ausgerechnet dieser Kamin heute gegen dich gewonnen?“
- **Dein Auftritt (wörtlich, Ich-Form, Vorlesetext):** „Ich bin Hana, Försterin. Holz kenne ich besser als jeder hier.
  Kaminzüge offenbar nicht. Um zwanzig nach elf hab ich den Kamin angefeuert und die Klappe vergessen. Um halb zwölf war der
  Kaminsaal voller Qualm, und alle haben gehustet. [Serkan hat die Klappen der Lichtschächte aufgerissen und uns gerettet. |]
  Im Wald ist es jedenfalls nie so laut.“
- Anekdote: Dia 5, verqualmter Kamin (WELT D-28, Kanon `intro.lacher.lacher_kamin.besetzt`). Der Brief fehlt bewusst.
- Tonprüfung: „Qualm“ steht im selben Satz wie „Kaminsaal“ (REG §6.2, Kontextregel: ein Wort, das mit „kamin“ beginnt).

#### ZR 3.4 Dein Tandem (Kasten im Heft, wörtlich)

„Um 23:20 Uhr wolltest du im Kamin heimlich einen alten Liebesbrief verbrennen. Die Kaminklappe hast du vergessen. [Serkan hat
gesehen, wie du Papier in den Kamin gestopft hast. Beim Lüften hat er dir dafür sein Geheimnis verraten: Er hat Wunderkerzen
für die Torte im Auto. Offenes Feuer erlaubt Herr Schneider nicht. Ihr deckt euch gegenseitig. | Ein Gast hat gesehen, wie du
Papier in den Kamin gestopft hast.] Der Brief ist nur halb verkohlt. Er liegt noch unter der Asche in der Kamin-Nische.“

#### ZR 3.5 Wissen

**Sicher:**

| Zeit | Was Hana weiß | Quelle | frei ab |
|---|---|---|---|
| 18:00 | zahlt 150 €; unterschreibt die Dankeskarte | WELT §3.3 | offen |
| 20:15 | Lacher (Olli, Torte) | MECH §1.5 | offen |
| 23:20 | feuert in der Kamin-Nische den Kamin an, ohne die Kaminklappe zu öffnen. Sie will, dass der Kamin endlich zieht, und dabei heimlich einen alten Liebesbrief verbrennen. [Serkan \| Ein Gast] sieht, wie sie Papier in den Kamin stopft | WELT §3.3, K-19 | Anfeuern: offen; Brief: Karte |
| 23:20 | schiebt einen alten Arbeitshandschuh in der Nische zur Seite. Er ist schwarz vom Ruß und lag schon da | WELT §3.3, §6 | nach dem Umdrehen (schützt den Brief) |
| 23:30 | Qualm aus dem Kamin füllt den Kaminsaal, alle husten. [Serkan \| Ein Gast] reißt die Klappen der Lichtschächte auf. Herr Schneider löscht das Feuer und schimpft über den Ruß an der Wand. [Aylin \| Ein Gast] holt Putzmittel und Lappen aus dem Fach im Durchgang. Hana wischt den Ruß ab | WELT §3.3 | offen |
| 23:30 | [Serkan verrät ihr beim Lüften seinen Plan: Wunderkerzen für die Mitternachtstorte im Auto. \| –] | WELT §3.3 | nie von ihr aus (Versprechen); bestätigt nach Serkans Karte |
| 23:30–23:58 | wischt mit dem Gesicht zur Wand Ruß ab | WELT §3.4 | offen |
| 23:50 | Tim ruft an der Bogentür: „Au! Mein Finger!“ Sie dreht sich um: Tim und Olli stehen an der Bogentür. Sibel sitzt auf der Wandbank Süd | WELT §3.4, ZR-05 | offen |
| 23:58 | Licht aus. Einen Knall hört sie im Kaminsaal nicht | WELT §2.7 | offen |
| kurz danach | rennende Schritte. Sie dreht sich um: Ein leuchtendes Gesicht huscht quer durch den Kaminsaal zur Bogentür. Dann ist es weg | WELT §5.2 | offen |
| kurz danach | Es riecht nach frisch ausgeblasenen Kerzen, mit dem Luftzug aus Richtung Theke. Erst das Gesicht, dann der Geruch | WELT §2.7, §5.2, §7.3 | **frühestens Runde 3** (Rand-Indiz, M-14) |
| 0:00 | Licht. Zeynep steht im Steinbogen | WELT §3.4, ZR-05 | offen |
| 0:01 | Can kommt aus dem Turmgang und setzt sich auf die Wandbank West | WELT §3.5, ZR-05 | offen |
| 0:03 | geht mit allen in den Buffetsaal und bleibt dort | WELT §3.5, W-15 | offen |

**Vermutet:** Echte Kerzen gab es nur an der Anrichte hinter der Theke (steht in „Was alle wissen“). Der Geruch kam also von
dort, nachdem die Kerzen ausgingen, mit einigen Sekunden Verzug (WELT §3.6). Sicher ist nur die Reihenfolge, die sie selbst
wahrnahm: erst das Gesicht, dann der Geruch. Ob das Gesicht vor dem Scheppern im Kaminsaal war, weiß sie nicht. Ihr Satz
stützt Cans Alibi, beweist es nicht (P3-03; frei ab Runde 3).

**Weiß nicht:** Knall, Rufe, Scheppern (nur vom Hörensagen); wer das Gesicht war; wem der alte Handschuh gehört; was an der
Theke geschah.

#### ZR 3.6 Stufe 1

**Das sagst du jedem (wörtlich):**
- „Ich bin Försterin. Holz kenn ich, Kaminzüge offenbar nicht.“
- „Um zwanzig nach elf hab ich den Kamin angefeuert und die Klappe vergessen. Der Qualm im Kaminsaal war meine Schuld. Herr
  Schneider hat das Feuer gelöscht und über den Ruß geschimpft.“
- „Seitdem hab ich mit dem Gesicht zur Wand Ruß abgewischt. Um zehn vor zwölf hat Tim an der Bogentür ‚Au! Mein Finger!‘
  gerufen. Da stand Olli neben ihm.“
- „Auf einmal war es dunkel. Einen Knall hab ich im Kaminsaal nicht gehört.“
- „Dann rannte jemand. Ich hab mich umgedreht: Ein leuchtendes Gesicht huschte quer durch den Kaminsaal zur Bogentür. Dann war
  es weg.“

**Ab Runde 3 sagst du außerdem (wörtlich, Rand-Indiz):**
- „Kurz nachdem das Gesicht durch den Kaminsaal gehuscht war, roch es nach frisch ausgeblasenen Kerzen. Der Geruch kam mit dem
  Luftzug aus Richtung Theke. Erst das Gesicht, dann der Geruch. Da bin ich mir sicher.“
- „Echte Kerzen gab es heute nur an der Anrichte hinter der Theke.“

**Das behältst du für dich (wörtlich):**

| Wenn jemand fragt | sagst du |
|---|---|
| warum du den Kamin angefeuert hast | „Ich wollte, dass der Kamin endlich zieht.“ |
| was du in den Kamin gesteckt hast | „Frag lieber, warum ich die Klappe vergessen hab. Ich bin Försterin, keine Kaminkehrerin.“ |
| ob in der Kamin-Nische noch etwas liegt | „Ich hab genug von dieser Nische. Schau selbst, wenn du willst.“ |
| ob du im Dunkeln etwas gerochen oder sonst gemerkt hast (Runde 1 und 2) | „Dazu sag ich später was. Erst will ich hören, was die anderen im Dunkeln mitgekriegt haben.“ |
| [was Serkan vorhat, ob er dir etwas verraten hat \| –] | „Frag Serkan selbst.“ (Zeile entfällt, wenn Serkan fehlt, P14-01) |

**Verboten:** „Ich hab nichts verbrannt.“ · „In der Nische liegt nichts.“ · „Im Dunkeln hab ich nichts gesehen.“ · „Ich hab
nichts gerochen.“

#### ZR 3.7 Stufe 2

**Rundensperre:** keine. (Das Rand-Indiz ist davon unabhängig erst ab Runde 3 frei.)

**Wann du umdrehst (wörtlich im Heft):**
1. „Sobald die Indizkarte VP7 offen auf dem Tisch liegt.“ (MECH §4.2)
2. „Sobald Serkans Geheimniskarte offen auf dem Tisch liegt.“ (ZR-03, nur wenn Serkan gespielt wird)
3. „Sobald dich jemand vor allen fragt, was du in den Kamin gesteckt hast.“ (ZR-03, P145R2-M05)

**Geheimniskarte, Innenseite (wörtlich):**

> **Was ich zugebe**
> „Um 23:20 Uhr hab ich den Kamin angefeuert, ohne die Kaminklappe zu öffnen. Ich wollte heimlich einen alten Liebesbrief
> verbrennen. Er ist nur halb verkohlt und liegt unter der Asche in der Kamin-Nische. An wen er ist, bleibt mein Geheimnis. Mit
> dem Abend hat er nichts zu tun.“
>
> **Für den Ermittlungsbogen**
> „Hinweis: Der halb verkohlte Brief in der Kamin-Nische ist Hanas alter Liebesbrief. Sie wollte ihn um 23:20 Uhr heimlich
> verbrennen.“
>
> **Und noch etwas**
> mit Serkan: „Serkan hat es gesehen. Dafür kenn ich sein Geheimnis: Um 23:56 Uhr wollte er keine Decken aus dem Auto holen.“
> allein (15 Personen): „Den alten Arbeitshandschuh in der Kamin-Nische hab ich um 23:20 Uhr nur zur Seite geschoben. Er lag
> schon vorher da, schwarz vom Ruß.“

**Nach dem Umdrehen** sagst du auf Nachfrage außerdem (wörtlich):
- „Den alten Arbeitshandschuh in der Nische hab ich um 23:20 Uhr zur Seite geschoben. Er lag schon da. Wem er gehört, weiß ich
  nicht.“ (mit Serkan; allein steht es schon auf der Karte)
- „Bei Herrn Schneider will ich mich für den Ruß entschuldigen.“
- Nach Serkans Karte: „Ja, Serkan hat mir beim Lüften von seinen Wunderkerzen erzählt.“

#### ZR 3.8 Nachbohr-Ziele

| Runde | Nr | Ziel | Frage oder Vorwurf (wörtlich) | Worauf du hinauswillst | Ausweichziel |
|---|---|---|---|---|---|
| 1 | 1 | Olli | „Olli, du sagst, du warst die ganze Zeit im Ost-Saal. Um zehn vor zwölf hat Tim an der Bogentür ‚Au! Mein Finger!‘ gerufen. Ich hab mich umgedreht, und du standest daneben. Was habt ihr da gemacht?“ | Druck auf Ollis Marker; lenkt zur Bogentür (YT4) | – (immer besetzt) |
| 1 | 2 | Ahmet | „Ahmet, dein Marker steht hinter der Theke am Ostende. Um fünf vor zwölf sollten alle in den Ost-Saal. Was hattest du da hinten zu suchen?“ | Druck auf Ahmets Grund | – (immer besetzt) |
| 2 | 1 | Can | „Can, das Gesicht im Kaminsaal leuchtete grünlich-weiß, wie Leuchtfarbe. Herr Schneider hat eine Kapuze erwischt, und deine ist die auffälligste hier. Was steckt in deiner Bauchtasche?“ | Cans Heimlichtuerei (M6); lenkt zu JT3 | – (immer besetzt) |
| 2 | 2 | Tim | „Tim, dein Marker ‚Scheppern‘ steht im Durchgang am Sicherungskasten. Im Dunkeln warst du ziemlich schnell dort. Wusstest du vorher, wo es knallen würde?“ | Druck auf Tims Knall; lenkt zu MR4 | – (immer besetzt) |
| 3 | 1 | Olli | Olli in Stufe 2: „Olli, du sagst, das Gespenst ist auf Herrn Schneider los. Aber das Gesicht war bei uns im Kaminsaal, und erst danach roch es nach ausgeblasenen Kerzen. Wer war an der Theke, als die Kerzen ausgingen?“ Olli noch in Stufe 1: „Olli, erst huschte das Gesicht durch den Kaminsaal, dann roch es nach ausgeblasenen Kerzen. Die Kerzen standen an der Theke. Wo warst du, als sie ausgingen?“ (P3-03) | Ollis Gespenst-Fassung wackelt; stützt M3 | – (immer besetzt) |
| 3 | 2 | Tim | „Tim, du standest am Sicherungskasten, direkt am Weg in den Kaminsaal. Was kam im Dunkeln an dir vorbei, und war das vor oder nach dem Scheppern?“ | Tims Gesprächs-Auslöser in Runde 3 (ZG 3.6) | – (immer besetzt) |

#### ZR 3.9 Aktionskarte (wörtlich, MECH §4.4)

| Feld | Text |
|---|---|
| Kopf | „Aktionskarte · Hana“ |
| Name | **Spurenlesen** · ab Runde 1 · Klasse Frage |
| Wirkung | „Du wählst eine Zone auf dem Lageplan. Jede Person, deren Marker ‚Scheppern‘ dort steht, sagt, was sie im Dunkeln gehört, gespürt oder gerochen hat.“ |
| Grenzen | „Lügen nach Stufe 1 bleibt erlaubt.“ |
| Fuß | „Einmal im Spiel. Danach umdrehen.“ |
| Tipp im Heft | „Gut, wenn ein Gespräch stockt. Wähl eine Zone, in der mehrere Marker ‚Scheppern‘ stehen. Steht dein eigener Marker dort, sagst du vor Runde 3 nur, was du gesehen hast.“ |

#### ZR 3.10 Was du bei dir trägst (wörtlich)

„In der Hemdtasche ein rußiger Lappen und ein Stück Birkenrinde als Glücksbringer. Mein Handy hab ich seit kurz nach zwölf
zurück.“

#### ZR 3.11 Bonus-Ziel und fehlende Rollen

- **Wörtlich:** „**Dein Bonus-Ziel:** Deine Nase soll zählen, nicht dein Brief. **Erfüllt, wenn** bei der Anklage auf dem
  Ermittlungsbogen in der Spalte Can bei ‚Alibi beim Scheppern‘ ein ✓ steht.“
- Prüfbar am Bogen. Erreichbar bei 15 bis 20 Personen: Tim, Marek und Zeynep sind dann immer gespielt (Quellen für M3).

| fehlt | Folge für Hana |
|---|---|
| Serkan | Solo-Abschnitt 3.12 |
| Aylin | „ein Gast“ holt um 23:30 die Putzmittel |
| Hana selbst | Der Erzähler liest den Ausfalltext zum Kamin (MECH §9.4). Ihr Rand-Indiz fällt weg; Tim, Marek, Zeynep tragen M3 |

#### ZR 3.12 Solo-Abschnitt (bei 15 Personen, im Heft wörtlich)

„**Du spielst dein Tandem allein.** Wer dich am Kamin gesehen hat, spielt heute niemand. Sag dann ‚ein Gast‘. Ein fremdes
Geheimnis kennst du heute nicht. Deine Karte endet mit dem Satz über den alten Handschuh. Alles andere gilt wie gedruckt.“

Generator: Auftritt ohne Serkan-Satz; Tandem-Kasten und Wissen in der Ersatzfassung; Karte mit der Solo-Zeile. Auslöser 2,
der Satz „Nach Serkans Karte“ und die Tarnsatz-Zeile „was Serkan vorhat“ werden nicht gedruckt; die Nummern rücken nach
(P14-01).

#### ZR 3.13 Absatz für Teil 90 (wörtlich, Vorlesen)

„Hana wollte um zwanzig nach elf heimlich einen alten Liebesbrief im Kamin verbrennen und vergaß die Klappe. Im Dunkeln sah sie
das leuchtende Gesicht und roch erst danach die ausgeblasenen Kerzen. Ihre Nase stützte Cans Alibi.“

### ZR 4 · Serkan (Platz 14) – der Fahrdienst-Organisator · Tandem 2

#### ZR 4.1 Profil

| Feld | Inhalt |
|---|---|
| Platz, Stellung | 14, Zusatzrolle, Tandem 2. Spielt ab 16 Personen; Hana ist dann immer dabei |
| Alter, Beruf | 29, Rettungssanitäter. Fährt heute alle heim |
| Rollenbezeichnung | Der Fahrdienst-Organisator (Kanon, serkan) |
| Merkmal | Steppweste, Klemmbrett mit Fahrzeiten, LED-Taschenlampe |
| Beziehungen | **Hana**: Er hat sie am Kamin gesehen, sie kennt seinen Plan; Tandem. **Lejla**: Er war ihr Ausbilder im Erste-Hilfe-Kurs |
| Verfehlung | Nebendelikt: Wunderkerzen für den Keller geplant, offenes Feuer ist verboten. Lüge (Stufe 1): die Decken (WELT §7.4) |
| Haltung (wörtlich im Heft) | „Du bleibst ruhig und willst alle sicher heimbringen. Nur deine Überraschung für die Torte verrätst du nicht. Dafür flunkerst du einmal: die Decken.“ |
| Kanon-Ziel | Alle so schnell wie möglich sicher nach Hause fahren (WELT §7.3) |

#### ZR 4.2 Marker

| Marker | behauptet (Stufe 1) | wahr | Umstellen |
|---|---|---|---|
| 23:57 | W Windfang | W, am Außentor, Lampe an | nie |
| Scheppern | W Windfang | W, dto. | nie |

#### ZR 4.3 Vorstellungsrunde

- **Frage des Erzählers (wörtlich, Vorlesen):** „Serkan, der Fahrdienst-Organisator. Du fragst jeden, wann er heimwill. Wer
  darf nachher bei dir vorne sitzen, und wer muss auf die Rückbank?“
- **Dein Auftritt (wörtlich, Ich-Form, Vorlesetext):** „Ich bin Serkan, Rettungssanitäter, und heute euer Fahrdienst. Wer fährt
  nachher mit wem? Ich frag lieber jetzt schon. Um halb zwölf hab ich im Kaminsaal die Klappen der Lichtschächte aufgerissen, als
  aus dem Kamin der Qualm kam. Gern geschehen. Mitnehmen würde ich jeden. Nur das Schloss passt leider in kein Auto.“
- Anekdote: Er war bei Dia 5 dabei (Kamin, „mit Serkan“, WELT D-28). Die Wunderkerzen fehlen bewusst.

#### ZR 4.4 Dein Tandem (Kasten im Heft, wörtlich)

„Um 23:20 Uhr hast du gesehen, wie Hana Papier in den Kamin gestopft hat, ohne die Klappe zu öffnen. Um 23:30 Uhr hast du die
Klappen der Lichtschächte aufgerissen. Beim Lüften hast du Hana deinen Plan verraten: Wunderkerzen für die Mitternachtstorte,
sie liegen in deinem Auto. Offenes Feuer erlaubt Herr Schneider im Keller nicht. Ihr deckt euch gegenseitig. Kurz vor zwölf
wolltest du die Wunderkerzen holen. Das Außentor war zu.“

#### ZR 4.5 Wissen

**Sicher:**

| Zeit | Was Serkan weiß | Quelle | frei ab |
|---|---|---|---|
| am Nachmittag | legt eine Packung Wunderkerzen für die Mitternachtstorte in sein Auto | WELT §3.2 | Karte |
| 18:00 | parkt vor dem Außentor; zahlt 150 €; unterschreibt die Dankeskarte | WELT §3.3 | offen |
| 23:20 | sieht im Kaminsaal, wie Hana Papier in den Kamin stopft, ohne die Kaminklappe zu öffnen | WELT §3.3 | Karte (Domino) |
| 23:30 | Qualm aus dem Kamin; er reißt die Klappen der Lichtschächte auf. Herr Schneider löscht das Feuer | WELT §3.3 | offen |
| 23:30 | verrät Hana beim Lüften seinen Plan mit den Wunderkerzen | WELT §3.3 | Karte |
| 23:50–23:55 | im Ost-Saal; Damir schenkt Tee aus | WELT §3.4 | offen |
| 23:55 | geht durch den Buffetsaal und die quietschende Innentür in den Windfang. Er will die Wunderkerzen aus dem Auto holen | WELT §3.4 | Ort offen; Grund: Karte (Stufe 1 sagt „Decken“) |
| 23:56 | Das Außentor ist abgeschlossen. Er schaltet seine LED-Lampe an und leuchtet aufs Schloss | WELT §3.4 | offen |
| 23:58–0:00 | auch im Windfang wird es dunkel; aus dem Buffetsaal hört er hinter der Innentür nur dumpfes Rumpeln. Seine Lampe brennt | WELT §2.6, §2.7 | offen |
| bis 0:02 | Niemand kommt in den Windfang. Die Innentür quietscht laut und geht nicht auf. Das Tor bleibt zu | WELT §3.4, §3.6, §7.3 | offen (Rand-Indiz) |
| 0:01 | schaltet die Lampe aus | WELT §3.4 | offen |
| 0:02 | kommt durch die Innentür zurück und ruft: „Das Tor ist zu. Abgeschlossen.“ | WELT §3.5 | offen |
| 0:03 | Buffetsaal: [Aylin \| Ein Gast] sagt, den Schlüssel fürs Außentor gibt es nur zweimal | WELT §3.5 | offen |

**Vermutet:** Der Schlüsselbund ist noch im Keller, weil niemand durchs Außentor hinausging (stimmt; die Hoftür sieht er nicht). Herr Schneider hat das Tor schon früher
abgeschlossen (stimmt, seit 18:50; er weiß es nicht sicher).

**Weiß nicht:** was im Buffetsaal geschah; wer an der Theke war; was Hana verbrennen wollte (er sah nur Papier).

#### ZR 4.6 Stufe 1

**Das sagst du jedem (wörtlich):**
- „Ich bin heute euer Fahrdienst. Wer fährt nachher mit wem?“
- „Um halb zwölf hab ich im Kaminsaal die Klappen der Lichtschächte aufgerissen, als der Kamin so gequalmt hat.“
- „Kurz vor zwölf bin ich durch die Innentür in den Windfang. Das Außentor war abgeschlossen. Ich hab mit meiner Lampe aufs
  Schloss geleuchtet.“
- „Bis kurz nach zwölf stand ich am Außentor. Niemand kam in den Windfang. Die Innentür quietscht laut, das hätte ich gehört.
  Durchs Außentor ist also keiner raus.“ (Rand-Indiz, WELT §7.3, P3-13)
- „Aus dem Buffetsaal hab ich hinter der Innentür nur dumpfes Rumpeln gehört.“
- „Um zwei nach zwölf bin ich rein und hab gerufen: ‚Das Tor ist zu. Abgeschlossen.‘“

**Deine eine Ausrede (Stufe 1, erlaubt, wörtlich):** „Ich wollte Decken aus dem Auto holen.“ Sie ist die einzige Lüge einer
Zusatzrolle (WELT §7.4). Du sagst sie nur auf die Frage, warum du zum Außentor gegangen bist, und immer gleich.

**Das behältst du für dich (wörtlich):**

| Wenn jemand fragt | sagst du |
|---|---|
| was im Auto liegt | „Frag nicht so viel. Ich bin der Fahrdienst, nicht der Packesel.“ |
| was Hana um 23:20 Uhr am Kamin gemacht hat | „Den Kamin angefeuert, das weiß doch jeder. Frag sie selbst.“ |
| ob Hana dir etwas verraten hat oder du ihr | „Was am Kamin geredet wird, bleibt am Kamin.“ |

**Verboten:** „Das Tor war offen.“ · „Ich war die ganze Zeit im Ost-Saal.“ · „Hana hat nichts verbrannt.“ · jede neue Ausrede
außer den Decken.

#### ZR 4.7 Stufe 2

**Rundensperre:** keine.

**Wann du umdrehst (wörtlich im Heft):**
1. „Sobald dich jemand zum zweiten Mal fragt, warum du kurz vor zwölf zum Außentor gegangen bist. Auch ein Impuls des
   Erzählers, der alle nach dem Warum fragt, zählt als einmal.“ (MECH §4.2)
2. „Sobald Hanas Geheimniskarte offen auf dem Tisch liegt.“ (ZR-03)

**Geheimniskarte, Innenseite (wörtlich):**

> **Was ich zugebe**
> „Ich wollte keine Decken holen. In meinem Auto liegen Wunderkerzen für die Mitternachtstorte. Offenes Feuer erlaubt Herr
> Schneider im Keller nicht, nach dem Kamin um halb zwölf erst recht nicht. Um 23:56 Uhr stand ich am Außentor. Es war
> abgeschlossen. Die Wunderkerzen liegen immer noch im Auto.“
>
> **Für den Ermittlungsbogen**
> „Hinweis: Von 23:56 Uhr bis kurz nach zwölf stand Serkan am abgeschlossenen Außentor. Niemand kam in den Windfang, niemand ist
> durchs Außentor hinaus.“
>
> **Und noch etwas**
> „Um 23:20 Uhr hat Hana Papier in den Kamin gestopft, kurz danach kam der Qualm.“

**Nach dem Umdrehen** sagst du auf Nachfrage außerdem (wörtlich):
- „Was auf dem Papier stand, weiß ich nicht.“
- „Durchs Außentor ist der Schlüsselbund nicht raus. Ich glaub, er ist noch hier unten.“

#### ZR 4.8 Nachbohr-Ziele

| Runde | Nr | Ziel | Frage oder Vorwurf (wörtlich) | Worauf du hinauswillst | Ausweichziel |
|---|---|---|---|---|---|
| 1 | 1 | Lejla | „Lejla, als ich vom Tor zurückkam, warst du bei Herrn Schneider. Ich war dein Ausbilder im Erste-Hilfe-Kurs, also: Wie geht es ihm? Und wer war im Dunkeln bei dir am rechten Buffet?“ (P3-13) | Lejlas offenes Wissen (D2) kommt auf den Tisch | – (immer besetzt) |
| 1 | 2 | Damir | „Damir, dein Marker ‚Scheppern‘ steht hinter der Theke am Ostende. Wer war im Dunkeln bei dir, und ging es allen gut?“ | Ahmets Alibi (M1) wird laut gesagt; Damir wird angesprochen (P145R2-K20) | – (immer besetzt) |
| 2 | 1 | Hana | Sprich leise mit Hana: „Am Tisch fragen sie nach dem Tor und nach dem Kamin. Fragt dich jemand nach dem Papier: Halten wir dicht, oder sagen wir es beide?“ | Tandem 2 spielt seine Mini-Intrige aus; beide können am Rundenende reinen Tisch machen (R-05, P14-09) | – (immer besetzt) |
| 2 | 2 | Fatma | „Fatma, du schleppst die schwere Tasche den ganzen Abend mit dir herum. Ich trag sie dir nachher zum Auto. Was ist denn da drin?“ | Fatmas Heimlichtuerei (M5); lenkt zu NN3 | – (immer besetzt) |
| 3 | 1 | Lejla | „Lejla, durchs Außentor ist keiner raus, ich stand dort. Der Bund ist also wohl noch hier drin. Wer ist als Erstes wohin gegangen, als das Licht anging?“ | Lejlas offener Satz zum Eiskübel (ZG 1.5); lenkt zu PP9 | – (immer besetzt) |
| 3 | 2 | Can | „Can, du warst oben im Turm, sagst du. Herr Schneider hat zweimal ‚Stehen bleiben!‘ gebrüllt. Bist du vor dem Scheppern hoch oder danach?“ | Cans Alibi (M3) in Runde 3 | – (immer besetzt) |

#### ZR 4.9 Aktionskarte (wörtlich, MECH §4.4)

| Feld | Text |
|---|---|
| Kopf | „Aktionskarte · Serkan“ |
| Name | **Lagebesprechung** · ab Runde 1 · Klasse Frage |
| Wirkung | „Der Detektiv sagt sofort laut, wen er gerade am meisten verdächtigt und warum. Danach darf jede Person genau einen Einwand sagen.“ |
| Grenzen | „Der Detektiv muss sich nicht festlegen, nur seine Lage schildern.“ |
| Fuß | „Einmal im Spiel. Danach umdrehen.“ |
| Tipp im Heft | „Gut in Runde 2 oder 3, wenn der Detektiv sich in Einzelheiten verliert. Danach weiß der ganze Tisch, worüber zu reden ist.“ |

#### ZR 4.10 Was du bei dir trägst (wörtlich)

„Ich hab mein Klemmbrett mit den Fahrzeiten, meine LED-Taschenlampe und den Autoschlüssel. Der nützt mir nichts, solange das
Tor zu ist. Mein Handy hab ich seit kurz nach zwölf zurück.“

#### ZR 4.11 Bonus-Ziel und fehlende Rollen

- **Wörtlich:** „**Dein Bonus-Ziel:** Alle sollen sicher heimkommen, und dafür braucht es den Schlüsselbund. **Erfüllt, wenn**
  bei der Anklage eine offene Indizkarte zeigt, dass Herr Schneider seinen Schlüsselbund wieder hat.“
- Prüfbar am Tisch. Nur eine Indizkarte zeigt das (MECH §3.3); der Code steht nicht im Heft. Erreichbar bei 16 bis 20 Personen.

| fehlt | Folge für Serkan |
|---|---|
| Hana | kommt nicht vor: Hana spielt immer, wenn Serkan spielt (E6) |
| Serkan selbst | Hanas Solo-Fassung; im Wissen aller anderen „ein Gast“ am Tor; sein Rand-Indiz fällt weg, PP9 trägt M8 allein |

#### ZR 4.12 Wenn der Partner fehlt

Kommt nicht vor (E6). Serkan spielt nie allein.

#### ZR 4.13 Absatz für Teil 90 (wörtlich, Vorlesen)

„Serkan wollte keine Decken holen, sondern Wunderkerzen für die Torte. Er stand am verschlossenen Außentor, bis kurz nach
Mitternacht. Niemand ist hinaus, also blieb der Schlüsselbund im Keller.“

### ZR 5 · Azra (Platz 15) – die Flohmarkt-Kennerin · Tandem 3

#### ZR 5.1 Profil

| Feld | Inhalt |
|---|---|
| Platz, Stellung | 15, Zusatzrolle, Tandem 3. Spielt ab 17 Personen; bei 17 Personen allein (5.12) |
| Alter, Beruf | 26, Kunstgeschichte. Stöbert jedes Wochenende auf Flohmärkten, kennt alte Münzen |
| Rollenbezeichnung | Die Flohmarkt-Kennerin (Kanon, dilara) |
| Merkmal | Lupe an einer Silberkette, langer Strickcardigan |
| Beziehungen | **[Wojtek \| –]**: Sie skizzieren zusammen alte Fassaden, er misst, sie erzählt; Tandem. **Fatma**: kennt sie aus der Unibibliothek; Azra hat ihr von der Münzschatulle erzählt. **[Tugba \| –]**: Flohmarkt-Deko für ihre Spieleabende |
| Verfehlung | Verschweigen: hat Fatma von der Schatulle erzählt; schweigt über Wojteks Wachs (Versprechen) (WELT §7.4) |
| Haltung (wörtlich im Heft) | „Du feilschst gern und redest gern über alte Dinge. Nur über die Schatulle in der Vitrine schweigst du lieber. Lügen tust du nicht.“ |
| Kanon-Ziel | Niemand soll denken, sie hätte Fatma zu etwas angestiftet (WELT §7.3) |

#### ZR 5.2 Marker

| Marker | behauptet (Stufe 1) | wahr | Umstellen |
|---|---|---|---|
| 23:57 | 1 Ost-Saal | 1, lange Tafel, Ostseite, sitzt | nie |
| Scheppern | 1 Ost-Saal | 1, dto. | nie |

#### ZR 5.3 Vorstellungsrunde

- **Frage des Erzählers (wörtlich, Vorlesen):** „Azra, die Flohmarkt-Kennerin. Du hast heute Abend schon einen Einbrecher
  gestellt. Wie gefährlich war er wirklich?“
- **Dein Auftritt (wörtlich, Ich-Form, Vorlesetext):** „Ich bin Azra. Ich studiere Kunstgeschichte und stöbere jedes
  Wochenende auf Flohmärkten. Feilschen ist mein Sport. Um Viertel nach acht hab ich an der Torte einen Einbrecher erwischt. Ich
  hab laut gerufen, [Wojtek hat mit der Taschenlampe in den Vorratsraum geleuchtet, | jemand hat mit der Taschenlampe in den
  Vorratsraum geleuchtet,] und da stand: Olli. Er wollte nur aufs Klo. Jeder Trödel erzählt eine Geschichte. Die hier erzähl ich
  noch meinen Enkeln.“
- Anekdote: Azras Teil von Dia 4 (Verlaufen Olli mit Azras Alarm, WELT D-28, W-13). Ollis Auftritt erzählt dieselbe Szene ohne
  Namen (RK 4.3); Azras Auftritt kommt später und löst auf, wer gerufen hat. Kein Wort zum Wachs.

#### ZR 5.4 Dein Tandem (Kasten im Heft, wörtlich)

„Um 20:15 Uhr hast du ‚Einbrecher an der Torte!‘ gerufen. [Wojtek | Ein Gast] hat mit der Taschenlampe aus dem Werkzeugkasten
hinter der Theke in den Vorratsraum geleuchtet. Es war Olli. Beim Zurücklegen sah [Wojtek | der Gast] im Werkzeugkasten eine
halb leere Dose Möbelwachs. Tim sagte: ‚Olli brauchte was für eine Schramme.‘ [Wojtek | Der Gast] bat dich: ‚Sag keinem, dass
das Wachs aus meinem Kasten ist.‘ Du hast es versprochen. Dein eigenes Geheimnis hat mit der Schauvitrine zu tun.“

#### ZR 5.5 Wissen

**Sicher:**

| Zeit | Was Azra weiß | Quelle | frei ab |
|---|---|---|---|
| vorher | erzählt Fatma in der Unibibliothek von der Münzschatulle mit dem Wappen in der Schauvitrine | WELT §3.2 | Karte |
| 18:00 | zahlt 150 €; unterschreibt die Dankeskarte | WELT §3.3 | offen |
| heute Abend, ohne Uhrzeit | steht selbst lange vor der Vitrine und schaut sich die Schatulle an. Herr Schneider schaut sie komisch an. Einen Sprung in der Scheibe bemerkt sie nicht | Kanon `figuren.json` (dilara), ZR-18 | Karte |
| 20:15 | sieht jemanden in der dunklen Tür neben der Anrichte verschwinden und ruft: „Einbrecher an der Torte!“ [Wojtek \| Ein Gast] leuchtet hinein. Olli: „Ich wollte nur aufs Klo!“ | WELT §3.3, W-13 | offen |
| 20:15 | hinter der Theke: Die Dose Möbelwachs im Werkzeugkasten ist halb leer, am Rand Holzstaub. Tim: „Olli brauchte was für eine Schramme.“ [Wojtek \| Der Gast] bittet sie zu schweigen | WELT §3.3 | mit Wojtek: erst nach Wojteks Karte; allein: Karte |
| 22:00 | Herr Schneider verlangt im Ost-Saal leisere Musik | WELT §5.6 | offen |
| 23:00 | Ost-Saal, Ratespiel | WELT W-27 | offen |
| 23:50–0:00 | sitzt im Ost-Saal an der langen Tafel, Ostseite. Ab fünf vor zwölf schaut sie auf die blinde Kuh. Hört Knall, Rufe, Scheppern, „Hier liegt Herr Schneider!“ | WELT §4.1, §5.1, §5.5 | offen |
| im Dunkeln, kurz vor dem Licht | Im Ost-Saal gehen Handylampen an. Sie schaut zur Tür in den Buffetsaal, woher der Lärm kam, nicht zur Tafel | ZR-09, P3-20 | offen |
| 0:03 | Buffetsaal: Bund weg, Tor zu | WELT §3.5 | offen |
| 0:10 | holt ihren Skizzenblock von der Wandbank West im Kaminsaal und bleibt dort sitzen | WELT §3.5 | offen |
| 0:12 | Ahmet kommt an den Kamin. Er nimmt ein Bündel Scheine aus einem Umschlag und steckt es in die Hosentasche. Den leeren Umschlag faltet er und wirft ihn in den Ascheneimer neben der Kamin-Nische | WELT §3.5, §7.3, W-15 | **ab Runde 2** (Rand-Indiz, ZR-07) |

**Vermutet:** Fatma hat die Schatulle mitgenommen (sobald FM9 offen liegt; stimmt). Olli hat mit dem Wachs eine Schramme
verdeckt; wo, weiß sie nicht (stimmt). Ahmet versteckt Geld (stimmt).

**Weiß nicht:** wo die Schramme ist; was an der Theke geschah; wer das Gesicht war; wo der Bund ist.

#### ZR 5.6 Stufe 1

**Das sagst du jedem (wörtlich):**
- „Gib mir eine Lupe und einen Flohmarkt, und ich bin glücklich.“
- „Um Viertel nach acht hab ich ‚Einbrecher an der Torte!‘ gerufen. Es war Olli. Er wollte nur aufs Klo.“
- „Kurz vor zwölf saß ich im Ost-Saal an der langen Tafel und hab der blinden Kuh zugeschaut. Von der Theke hab ich nichts
  gesehen.“
- „Knall, Rufe, Scheppern: Das hab ich nur gehört.“
- „Um zehn nach zwölf hab ich im Kaminsaal meinen Skizzenblock von der Wandbank geholt und mich da hingesetzt.“ (P3R2-16)

**Ab Runde 2 sagst du außerdem (wörtlich, Rand-Indiz):**
- „Um 0:12 Uhr kam Ahmet an den Kamin. Er hat ein Bündel Scheine aus einem Umschlag genommen und in die Hosentasche gesteckt.
  Den leeren Umschlag hat er gefaltet und in den Ascheneimer geworfen.“

**Das behältst du für dich (wörtlich):**

| Wenn jemand fragt | sagst du |
|---|---|
| nach der Münzschatulle oder alten Münzen | „Alte Münzen sind mein Hobby, ja. Mehr sag ich dazu gerade nicht.“ |
| ob du heute an der Vitrine warst | „Im Turmgang war ich heute auch mal. Mehr sag ich dazu nicht.“ |
| nach dem Werkzeugkasten, dem Möbelwachs, der Taschenlampe | „[Frag Wojtek. \| Frag Tim, der hat sich den Kasten heute geliehen.]“ |
| (Runde 1) was du nach zwölf im Kaminsaal gesehen hast | „Ich hab meinen Skizzenblock geholt und mich hingesetzt.“ |

**Verboten:** „Ich kenne die Schatulle nicht.“ · „Ich hab Fatma nie davon erzählt.“ · „Ich hab nach zwölf nichts gesehen.“ ·
„Im Werkzeugkasten war alles in Ordnung.“

#### ZR 5.7 Stufe 2

**Rundensperre:** keine. (Das Rand-Indiz ist davon unabhängig erst ab Runde 2 frei.)

**Wann du umdrehst (wörtlich im Heft):**
1. „Sobald die Indizkarte NN3 oder FM9 offen auf dem Tisch liegt.“ (MECH §4.2)
2. „Sobald Fatmas Geheimniskarte offen auf dem Tisch liegt.“ (ZR-03)

**Geheimniskarte, Innenseite (wörtlich):**

> **Was ich zugebe**
> „Ich kenne mich mit alten Münzen aus. In der Unibibliothek hab ich Fatma von der Münzschatulle mit dem Wappen erzählt, die
> hier in der Schauvitrine liegt. Heute Abend stand ich selbst lange davor. Herr Schneider hat mich komisch angeschaut. Aber ich
> hab Fatma zu nichts angestiftet.“
>
> **Für den Ermittlungsbogen**
> „Hinweis: Azra hat Fatma vor dem Abend von der Münzschatulle in der Schauvitrine erzählt.“
>
> **Und noch etwas**
> mit Wojtek: „Wojtek hat mich um 20:15 Uhr gebeten, über seinen Werkzeugkasten zu schweigen. Frag ihn, warum.“
> allein (17 Personen): „Um 20:15 Uhr sagte Tim am Werkzeugkasten hinter der Theke: ‚Olli brauchte was für eine Schramme.‘“

**Nach dem Umdrehen** sagst du auf Nachfrage außerdem (wörtlich):
- „Ob Fatma die Schatulle hat, weiß ich nicht sicher. Ich hoffe nur, sie kommt heil zurück.“
- Mit Wojtek, erst nach Wojteks Karte: „Ja, ich war um 20:15 Uhr dabei. Tim hat gesagt: ‚Olli brauchte was für eine Schramme.‘“

#### ZR 5.8 Nachbohr-Ziele

| Runde | Nr | Ziel | Frage oder Vorwurf (wörtlich) | Worauf du hinauswillst | Ausweichziel |
|---|---|---|---|---|---|
| 1 | 1 | Olli | „Olli, um Viertel nach acht standest du im dunklen Vorratsraum vor der Torte. Ich hab dich für einen Einbrecher gehalten. Den Weg hinter die Theke kennst du also auch im Dunkeln, oder?“ | Druck auf Olli; Gegenrede zu seinem Marker | – (immer besetzt) |
| 1 | 2 | Serkan | „Serkan, dein Marker steht im Windfang. Um fünf vor zwölf sollten alle in den Ost-Saal. Was wolltest du da draußen?“ | Serkans Auslöser 1 (Frage nach dem Warum, P145R2-M05) | – (immer besetzt) |
| 2 | 1 | Ahmet | „Ahmet, um 0:12 Uhr warst du am Kamin. Du hast ein Bündel Scheine in die Hosentasche gesteckt und einen leeren Umschlag in den Ascheneimer geworfen. Warum versteckst du den Umschlag?“ | Ahmets Heimlichtuerei (M4); lenkt zu WM9 | – (immer besetzt) |
| 2 | 2 | Fatma | Azras Karte offen: „Fatma, ja, ich hab dir von der Schatulle erzählt. Aber angestiftet hab ich dich zu nichts. Sag allen, dass du sie zurückbringst.“ Azras Karte zu: „Fatma, du schreibst über alte Münzbilder. Hast du hier im Schloss heute schon etwas zum Abzeichnen gefunden?“ | Fatma macht reinen Tisch (M5); dein Bonus-Ziel | – (immer besetzt) |
| 3 | 1 | Olli | „Olli, um Viertel nach acht hast du im Dunkeln bis vor die Torte gefunden. Um zwei vor zwölf war es wieder dunkel. Wohin bist du da gegangen?“ | Druck auf Ollis Stufe 2 | – (immer besetzt) |
| 3 | 2 | Zeynep | „Zeynep, du standest im Steinbogen. Was ist im Dunkeln an dir vorbeigekommen, und wann? Sag es vor allen.“ | Zeyneps Gesprächs-Auslöser in Runde 3 (ZG 6.6) | – (immer besetzt) |

#### ZR 5.9 Aktionskarte (wörtlich, MECH §4.4)

| Feld | Text |
|---|---|
| Kopf | „Aktionskarte · Azra“ |
| Name | **Lupe** · ab Runde 1 · Klasse Frage |
| Wirkung | „Du wählst eine offene Indizkarte und eine Person. Die Person beantwortet sofort eine Frage von dir zu diesem Fund.“ |
| Grenzen | „Lügen nach Stufe 1 bleibt erlaubt.“ |
| Fuß | „Einmal im Spiel. Danach umdrehen.“ |
| Tipp im Heft | „Gut, wenn eine Indizkarte offen liegt und keiner etwas dazu sagt. Frag die Person, deren Name oder Ort auf der Karte steht.“ |

#### ZR 5.10 Was du bei dir trägst (wörtlich)

„Ich hab meine Lupe an der Silberkette und einen kleinen Block mit Skizzen von alten Fassaden. Mein Handy hab ich seit kurz
nach zwölf zurück.“

#### ZR 5.11 Bonus-Ziel und fehlende Rollen

- **Wörtlich:** „**Dein Bonus-Ziel:** Die Münzschatulle soll heil zurück, und niemand soll denken, du hättest Fatma angestiftet.
  **Erfüllt, wenn** Fatmas Geheimniskarte offen lag, bevor die Indizkarte ‚Fatma: Taschen und Kleidung‘ offen lag.
  Darauf steht, dass sie die Schatulle nur ausgeliehen hat.“ (P145R2-M07)
- Prüfbar am Tisch über Nummer und Runde in der Vermerke-Liste. Erreichbar bei 17 bis 20 Personen: Fatma kann vorher freiwillig
  reinen Tisch machen oder über Emines Karte oder FM9 umdrehen; Azra treibt das mit ihrem Ziel in Runde 2.

| fehlt | Folge für Azra |
|---|---|
| Wojtek | Solo-Abschnitt 5.12 |
| Tugba | Beziehung entfällt |
| Azra selbst | „ein Gast“ ruft um 20:15 (MECH §1.5); Fatmas Texte sagen „eine Bekannte aus der Unibibliothek“ (RK 1.5); ihr Rand-Indiz fällt weg, WM9 trägt den Umschlag |

#### ZR 5.12 Solo-Abschnitt (bei 17 Personen, im Heft wörtlich)

„**Du spielst dein Tandem allein.** Wem der Werkzeugkasten gehört, spielt heute niemand. Sag dann ‚ein Gast‘. Dein Versprechen
gilt trotzdem: Wem das Wachs gehört, sagst du nicht. Was Tim um 20:15 Uhr gesagt hat, steht dafür am Ende deiner Karte. Alles
andere gilt wie gedruckt.“

Generator: Auftritt mit „jemand hat mit der Taschenlampe in den Vorratsraum geleuchtet“; Tandem-Kasten, Wissen und Tarnsatz in der Ersatzfassung; Karte mit der
Solo-Zeile.

#### ZR 5.13 Absatz für Teil 90 (wörtlich, Vorlesen)

„Azra hatte Fatma von der Münzschatulle erzählt und schwieg darüber. [Für Wojtek | Für einen Gast] hielt sie ein Versprechen.
Um zwölf nach zwölf sah sie, wie Ahmet den leeren Umschlag in den Ascheneimer warf.“ (P3R2-16)

### ZR 6 · Wojtek (Platz 16) – der Architekturstudent · Tandem 3

#### ZR 6.1 Profil

| Feld | Inhalt |
|---|---|
| Platz, Stellung | 16, Zusatzrolle, Tandem 3. Spielt ab 18 Personen; Azra ist dann immer dabei |
| Alter, Beruf | 27, Architekturstudium |
| Rollenbezeichnung | Der Architekturstudent (Kanon, kaan) |
| Merkmal | Brille, Zimmermannsbleistift hinter dem Ohr, Maßband am Hosenbund |
| Beziehungen | **Azra**: Sie skizzieren zusammen alte Fassaden; Tandem. **Tim**: hat sich heute seinen Werkzeugkasten geliehen. **Joanna**: fotografiert seine Hausmodelle |
| Verfehlung | Verschweigen: Das Möbelwachs kam aus seinem Werkzeugkasten (WELT §7.4) |
| Haltung (wörtlich im Heft) | „Du bewunderst alte Mauern und misst alles nach. Dein Werkzeugkasten soll aus dem Gerede bleiben. Lügen tust du nicht.“ |
| Kanon-Ziel | Niemand soll wissen, dass das Möbelwachs aus seinem Kasten kam (WELT §7.3) |

#### ZR 6.2 Marker

| Marker | behauptet (Stufe 1) | wahr | Umstellen |
|---|---|---|---|
| 23:57 | 1 Ost-Saal | 1, Wandbank Ost bei der Box, sitzt | nie |
| Scheppern | 1 Ost-Saal | 1, dto. | nie |

#### ZR 6.3 Vorstellungsrunde

- **Frage des Erzählers (wörtlich, Vorlesen):** „Wojtek, der Architekturstudent. Du misst alles nach, sogar die Lautstärke. Wie
  knapp war es heute, dass Herr Schneider deine Musikbox einkassiert?“
- **Dein Auftritt (wörtlich, Ich-Form, Vorlesetext):** „Ich bin Wojtek und studiere Architektur. Schaut euch nur diese alten
  Mauern an! Mein Maßband hab ich immer dabei. Um zehn wollte Herr Schneider meine Musikbox einkassieren. Dabei war sie nur ein
  kleines bisschen laut. Und um Viertel nach acht hab ich mit meiner Taschenlampe einen Einbrecher entlarvt. Er hieß Olli und
  suchte das Klo.“
- Anekdote: Wojteks Teil von Dia 4 (Taschenlampe, W-13) und die Box (WELT §3.3, 22:00). Kein Wort zum Werkzeugkasten oder zum
  Wachs.

#### ZR 6.4 Dein Tandem (Kasten im Heft, wörtlich)

„Um 18:00 Uhr hast du Tim deinen Werkzeugkasten geliehen. Er wollte seine wackelige alte Mehrfachsteckdose richten. Um 20:15 Uhr
rief Azra ‚Einbrecher an der Torte!‘, und du hast mit der Taschenlampe aus dem Kasten in den Vorratsraum geleuchtet. Es war Olli.
Beim Zurücklegen sahst du: Die Dose Möbelwachs war halb leer, am Rand Holzstaub. Heute Morgen war sie neu. Tim sagte: ‚Olli
brauchte was für eine Schramme.‘ Du hast Azra gebeten, nichts zu sagen. Du hast Angst, dass Herr Schneider auch dich zur Kasse
bittet.“

#### ZR 6.5 Wissen

**Sicher:**

| Zeit | Was Wojtek weiß | Quelle | frei ab |
|---|---|---|---|
| am Morgen | Die Dose Möbelwachs in seinem Werkzeugkasten ist neu | WELT §7.3 | Karte |
| 18:00 | bringt Musikbox, Kopfhörer und Werkzeugkasten mit. Tim leiht sich den Kasten für den Abend, er will seine wackelige alte Mehrfachsteckdose richten. Der Kasten steht hinter der Theke neben der Kaffeemaschine | WELT §3.3, W-11 | offen |
| 18:00 | zahlt 150 €; unterschreibt die Dankeskarte | WELT §3.3 | offen |
| 20:15 | Azra ruft „Einbrecher an der Torte!“. Er holt die Taschenlampe aus dem Kasten und leuchtet in den Vorratsraum. Es ist Olli | WELT §3.3 | offen |
| 20:15 | Beim Zurücklegen: Dose halb leer, am Rand Holzstaub. Tim: „Olli brauchte was für eine Schramme.“ Er bittet Azra: „Sag keinem, dass das Wachs aus meinem Kasten ist.“ | WELT §3.3 | Karte |
| 22:00 | Herr Schneider im Ost-Saal: „Ab jetzt leise. Sonst kassier ich die Box ein.“ | WELT §5.6 | offen |
| 23:00 | Ost-Saal, Ratespiel | WELT W-27 | offen |
| 23:50–0:00 | sitzt auf der Wandbank Ost bei der Box | WELT §4.1 | offen |
| 23:55 | setzt dem Detektiv seine Kopfhörer auf; laute Musik über die Akku-Box. Der Detektiv hört nur sehr Lautes | WELT §1.5, §3.4 | offen |
| 23:58–0:00 | hört Knall, Rufe, Scheppern. Nach dem Scheppern schaut er zur Tür in den Buffetsaal, woher der Lärm kam; auf den Kopf der Tafel achtet er nicht | WELT §5.1, §5.5, ZR-09, P3-20 | offen |
| 0:00 | [Tugba \| Ein Gast] nimmt dem Detektiv Augenbinde und Kopfhörer ab | WELT §3.4 | offen |

**Vermutet:** Olli hat irgendwo eine Schramme mit seinem Wachs verdeckt (stimmt). Der Knall kam von Tims alter Steckdose
(stimmt, eigener Schluss). Herr Schneider wird jeden zur Kasse bitten, der damit zu tun hat (Angst).

**Weiß nicht:** wo die Schramme ist (bis YT4 offen liegt); was an der Theke geschah; wer das Gesicht war; wo der Bund ist.

#### ZR 6.6 Stufe 1

**Das sagst du jedem (wörtlich):**
- „Schaut euch nur diese alten Mauern an! Ich hab mein Maßband dabei, falls jemand was nachmessen will.“
- „Die Musikbox und die Kopfhörer sind meine. Um zehn wollte Herr Schneider die Box einkassieren.“
- „Um fünf vor zwölf hab ich dem Detektiv meine Kopfhörer aufgesetzt. Laute Musik. Gehört hat er nur, was richtig laut war.“
- „Kurz vor zwölf saß ich im Ost-Saal auf der Wandbank bei meiner Box und hab der blinden Kuh zugeschaut.“
- „Um Viertel nach acht hab ich mit meiner Taschenlampe in den Vorratsraum geleuchtet. Da stand Olli vor der Torte.“
- „Tim hat sich heute meinen Werkzeugkasten geliehen. Er wollte seine wackelige alte Mehrfachsteckdose richten.“

**Das behältst du für dich (bis Runde 2, wörtlich):**

| Wenn jemand fragt | sagst du |
|---|---|
| was im Werkzeugkasten ist | „Werkzeug. Was sonst?“ |
| ob aus dem Kasten etwas fehlt | „Frag Tim, der hatte ihn den ganzen Abend.“ |
| was um 20:15 Uhr am Kasten gesagt wurde | „Alle haben über Olli gelacht. Mehr sag ich dazu jetzt nicht.“ |
| nach Möbelwachs | „Frag Tim. Der Kasten war bei ihm.“ |
| (Runde 1) ob stimmt, was Azras Karte über dich sagt | „Stimmt. Warum, sag ich in der nächsten Runde.“ |

**Verboten:** „Im Kasten fehlt nichts.“ · „Das Möbelwachs ist nicht von mir.“ · „Tim hat nichts gesagt.“

#### ZR 6.7 Stufe 2

**Rundensperre:** frühestens Runde 2.

**Wann du umdrehst (wörtlich im Heft):**
1. „Sobald die Indizkarte MR4 offen auf dem Tisch liegt.“ (MECH §4.2)
2. „Sobald Azras Geheimniskarte offen auf dem Tisch liegt. Ihr letzter Satz nennt deinen Werkzeugkasten.“ (ZR-03)
3. „Sobald Tims Geheimniskarte offen auf dem Tisch liegt. Sie nennt das Möbelwachs aus dem Werkzeugkasten.“ (ZR-03)
4. „Liegt eins davon schon in Runde 1 offen, drehst du zu Beginn von Runde 2 um.“

**Geheimniskarte, Innenseite (wörtlich):**

> **Was ich zugebe**
> „Der Werkzeugkasten hinter der Theke gehört mir. Darin ist eine Dose braunes Möbelwachs. Heute Morgen war sie neu. Um 20:15 Uhr
> war sie schon halb leer, am Rand Holzstaub. Ich hab Azra gebeten, nichts zu sagen. Ich hatte Angst, dass Herr Schneider auch
> mich zur Kasse bittet.“
>
> **Für den Ermittlungsbogen**
> „Hinweis · Heimlichtuerei: Das braune Möbelwachs ist aus Wojteks Werkzeugkasten. Schon um 20:15 Uhr war die Dose halb leer, am
> Rand Holzstaub. Vergleiche die Bogentür (YT4).“
>
> **Und noch etwas**
> „Um 20:15 Uhr sagte Tim an meinem Werkzeugkasten: ‚Olli brauchte was für eine Schramme.‘“

**Nach dem Umdrehen** sagst du auf Nachfrage außerdem (wörtlich):
- „Wo die Schramme ist, hat Tim nicht gesagt.“
- „Azra kann es bestätigen. Sie war dabei.“
- „Bezahlen will ich die Schramme nicht. Das Wachs hab ich nur verliehen, nicht benutzt.“

#### ZR 6.8 Nachbohr-Ziele

| Runde | Nr | Ziel | Frage oder Vorwurf (wörtlich) | Worauf du hinauswillst | Ausweichziel |
|---|---|---|---|---|---|
| 1 | 1 | Tim | „Tim, du hast dir heute meinen Werkzeugkasten geliehen, um deine wackelige alte Mehrfachsteckdose zu richten. Hast du sie gerichtet? Um zwei vor zwölf hat es hinter der Theke ordentlich geknallt.“ | Druck auf Tims Knall; lenkt vom Wachs ab und zu MR4 | – (immer besetzt) |
| 1 | 2 | Hana | „Hana, um halb zwölf hat der Kamin den ganzen Kaminsaal vollgequalmt. Warst du das? Und was hast du da hineingesteckt?“ Stell diese Frage vor allen. Ruf dafür den Erzähler. | Tandem 2 gerät unter Druck; Frage nach dem Papier vor allen (Hanas Auslöser 3, P14-09, P145R2-M05) | – (immer besetzt) |
| 2 | 1 | Tim | Karte offen: „Tim, um 20:15 Uhr hast du an meinem Werkzeugkasten gesagt: ‚Olli brauchte was für eine Schramme.‘ Welche Schramme? Sag es jetzt.“ Karte zu: „Tim, deine wackelige Steckdose hast du heute nicht gerichtet, oder? Dann war der Knall wohl deine Leiste.“ | Druck auf Tim (MR4); nach dem Umdrehen auf die Schramme (M7) | – (immer besetzt) |
| 2 | 2 | Olli | Karte offen: „Olli, um 20:15 Uhr hat Tim gesagt: ‚Olli brauchte was für eine Schramme.‘ Mit meinem Möbelwachs. Was hast du damit verdeckt?“ Karte zu, YT4 offen: „Olli, an der Bogentür ist ein Beschlag aus der gekalkten Wand gerissen, darüber braunes Möbelwachs. Als Architekt sag ich: Das hat jemand mit Absicht verdeckt. Warst du heute an der Bogentür?“ Beides zu: „Olli, du hilfst bei jedem Umzug. Ist dir heute beim Tragen irgendwo etwas kaputtgegangen?“ | Ollis Heimlichtuerei (M7) | – (immer besetzt) |
| 3 | 1 | Olli | „Olli, wer eine Schramme mit Möbelwachs verdeckt, hat es an den Fingern oder am Handschuh. Was hängt da aus deiner Westentasche?“ | lenkt zu FN3 (Schlüsselbeweis Teil 2) | – (immer besetzt) |
| 3 | 2 | Azra | Karte offen: „Azra, du warst um 20:15 Uhr dabei. Ich nehm dir dein Versprechen ab. Sag allen, was Tim an meinem Kasten gesagt hat.“ Karte zu: Du machst am Ende dieser Runde reinen Tisch (R-05) und fragst bis dahin Tim: „Tim, du hattest meinen Werkzeugkasten den ganzen Abend. Fehlt darin etwas?“ | zweite Stimme für M7; das Tandem löst sich | – (immer besetzt) |

#### ZR 6.9 Aktionskarte (wörtlich, MECH §4.4)

| Feld | Text |
|---|---|
| Kopf | „Aktionskarte · Wojtek“ |
| Name | **Maßband** · ab Runde 1 · Klasse Untersuchung |
| Wirkung | „Du wählst zwei Orte auf dem Lageplan. Der Erzähler liest aus der Maßtabelle vor, wie weit sie auseinanderliegen und ob man im Dunkeln vom einen zum anderen etwas erkennen konnte.“ |
| Grenzen | „Nur Orte aus der Maßtabelle.“ |
| Fuß | „Einmal im Spiel. Danach umdrehen.“ |
| Tipp im Heft | „Gut, wenn jemand behauptet, er hätte im Dunkeln etwas erkannt oder schnell irgendwo sein können. Miss nach.“ |

#### ZR 6.10 Was du bei dir trägst (wörtlich)

„Ich hab mein Maßband am Hosenbund, den Zimmermannsbleistift hinter dem Ohr und ein Ladekabel für die Box. Die Taschenlampe
liegt wieder im Werkzeugkasten. Mein Handy hab ich seit kurz nach zwölf zurück.“

#### ZR 6.11 Bonus-Ziel und fehlende Rollen

- **Wörtlich:** „**Dein Bonus-Ziel:** Für die Schramme soll nicht dein Werkzeugkasten geradestehen, sondern wer sie gemacht hat.
  **Erfüllt, wenn** du deine Geheimniskarte am Ende einer Runde freiwillig umgedreht hast, bevor die Indizkarte ‚Hinter der
  Theke: Kaffeemaschine und Werkzeugkasten‘ offen lag.“ (P145R2-M07)
- Prüfung in Teil 90: In der Vermerke-Liste steht „freiwillig“ bei Wojteks Vermerk, und er steht vor dem Vermerk von MR4.
  Erreichbar bei 18 bis 20 Personen: Die Sperre endet mit Runde 2; „Reinen Tisch“ liegt in jeder Runde vor den Untersuchungen
  (MECH §1.3), MR4 ist frühestens danach offen.

| fehlt | Folge für Wojtek |
|---|---|
| Azra | kommt nicht vor: Azra spielt immer, wenn Wojtek spielt (E6) |
| Wojtek selbst | Tim sagt „Ich hab ihn mir heute geliehen“ ohne Namen (ZG 3.5); Azras Solo-Fassung trägt Tims Satz; Box und Kopfhörer gehören „einem Gast“ |

#### ZR 6.12 Wenn der Partner fehlt

Kommt nicht vor (E6). Wojtek spielt nie allein.

#### ZR 6.13 Absatz für Teil 90 (wörtlich, Vorlesen)

„Wojtek hatte Tim seinen Werkzeugkasten geliehen. Um Viertel nach acht sah er, dass die Dose Möbelwachs schon halb leer war,
und hörte: Olli brauchte was für eine Schramme. Aus Angst vor der Rechnung schwieg er.“

### ZR 7 · Aylin (Platz 17) – die Kassenprüferin · Tandem 4

#### ZR 7.1 Profil

| Feld | Inhalt |
|---|---|
| Platz, Stellung | 17, Zusatzrolle, Tandem 4. Spielt ab 19 Personen; bei 19 Personen allein (7.12) |
| Alter, Beruf | 24, Steuerfachangestellte. Hebt jeden Beleg auf |
| Rollenbezeichnung | Die Kassenprüferin (Kanon, aylin) |
| Merkmal | Strickjacke, weiße Bluse, schwarze Ledermappe mit Belegen, Kugelschreiber |
| Beziehungen | **[Tugba \| –]**: Tandem, die Dankeskarte. **Marek**: Aylin macht die Steuer für seinen Catering-Betrieb |
| Verfehlung | Verschweigen: der Quittungszettel „Miete: 0 Euro“ (WELT §7.4) |
| Haltung (wörtlich im Heft) | „Du willst Ordnung und dein Geld. Aber du stellst niemanden vor allen bloß. Lügen tust du nicht.“ |
| Kanon-Ziel | Ihr Geld zurückbekommen, ohne Ahmet vor allen bloßzustellen (WELT §7.3) |

#### ZR 7.2 Marker

| Marker | behauptet (Stufe 1) | wahr | Umstellen |
|---|---|---|---|
| 23:57 | 1 Ost-Saal | 1, lange Tafel, Westseite, sitzt, Mappe | nie |
| Scheppern | 1 Ost-Saal | 1, dto. | nie |

#### ZR 7.3 Vorstellungsrunde

- **Frage des Erzählers (wörtlich, Vorlesen):** „Aylin, die Kassenprüferin. Wenn dein Kugelschreiber klickt, steht irgendwo ein
  Stuhl schief. Wie oft hat er heute schon geklickt?“
- **Dein Auftritt (wörtlich, Ich-Form, Vorlesetext):** „Ich bin Aylin, Steuerfachangestellte. Ordnung ist das halbe Leben, die
  andere Hälfte vermutlich auch. Ich hebe jeden Beleg auf, sogar den vom Kaugummi. Beim Einlass hab ich die Gästeliste
  abgehakt, alle sind da. Wenn mein Kugelschreiber dreimal klickt, steht irgendwo ein Stuhl schief. Heute hat er schon sehr oft
  geklickt.“
- Anekdote: keine der Dias 3–5. Eigene: der Kugelschreiber (Kanon `vorstellung.aylin`). Kein Wort zum Beleg für die Miete.

#### ZR 7.4 Dein Tandem (Kasten im Heft, wörtlich)

„Beim Einlass hast du Herrn Schneider geholfen und die Gästeliste abgehakt. Dabei hast du heimlich alle [Tugbas | eine]
Dankeskarte für Herrn Schneider unterschreiben lassen. Die soll er mit der Torte bekommen. Das ist das harmlose Geheimnis eures
Tandems. Dein eigenes ist es nicht: In deiner Ledermappe steckt ein Zettel von Herrn Schneider.“

#### ZR 7.5 Wissen

**Sicher:**

| Zeit | Was Aylin weiß | Quelle | frei ab |
|---|---|---|---|
| 18:00 | hilft beim Einlass im Windfang, hakt die Gästeliste ab. Herr Schneider zeigt ihr im Durchgang den Sicherungskasten und darunter das Fach mit Ersatzsicherungen und Putzmitteln, dazu die Notlaterne hinter der Vorratsraumtür: „Falls was ist.“ Er sagt: Den Außentor-Schlüssel gibt es nur an seinem Bund und bei seiner Kollegin | WELT §3.3 | offen |
| 18:00 | lässt mit der Gästeliste heimlich alle die Dankeskarte unterschreiben | WELT §3.3 | offen in der Clique (ZG-14) |
| 18:00 | zahlt Ahmet die 150 € nur unter Protest und will einen Beleg. Ahmet: „Den Beleg gibt's von Herrn Schneider.“ | WELT §3.3 | offen |
| 22:30 | fragt Herrn Schneider an der Tafel West nach einem Beleg. Er schreibt auf einen Quittungszettel: „Miete: 0 Euro. Schneider“. Im Quittungsblock sieht sie davor einen Durchschlag: „Bogentür, Beschlag ausgerissen: 2.000 € Bargeld. Bis Mitternacht.“ Ohne Namen. Er sagt: Jeden Schaden muss er der Stiftung melden, kleine zahlt er oft selbst. Sie steckt den Zettel in ihre Ledermappe | WELT §3.3, §6, §7.3, ZR-05 | Karte |
| 23:00 | Ost-Saal, Ratespiel | WELT W-27 | offen |
| 23:30 | holt Putzmittel und Lappen aus dem Fach im Durchgang, für den Ruß am Kamin | WELT §3.3 | offen |
| 23:55 | Serkan geht aus dem Ost-Saal, gerade als alle zur blinden Kuh sollen. Wohin, sieht sie nicht | WELT §5.8 | offen (P145R2-K11) |
| 23:50–0:00 | sitzt an der langen Tafel, Westseite, die Mappe auf dem Schoß. Ab fünf vor zwölf schaut sie auf die blinde Kuh. Hört Knall, Rufe, Scheppern. Als die Handylampen angehen, schaut sie zur Tür, woher der Lärm kam (P3-20) | WELT §4.1, §5.5, ZR-09 | offen |
| 0:03 | im Buffetsaal unter dem Notausgangsschild: „Den Schlüssel fürs Außentor gibt's nur an seinem Bund und bei seiner Kollegin.“ | WELT §3.5 | offen |

**Vermutet:** Ahmet hat das Geld für etwas anderes gebraucht (stimmt). Wer die Bogentür beschädigt hat, sollte bis Mitternacht
2.000 € zahlen (stimmt; wer, weiß sie nicht).

**Weiß nicht:** wofür Ahmet das Geld wollte; wer die Bogentür beschädigt hat; was an der Theke geschah; wo der Bund ist.

#### ZR 7.6 Stufe 1

**Das sagst du jedem (wörtlich):**
- „Ordnung ist das halbe Leben. Ich hebe jeden Beleg auf.“
- „Beim Einlass hab ich Herrn Schneider geholfen und die Gästeliste abgehakt. Er hat mir den Sicherungskasten im Durchgang
  gezeigt, das Fach mit Ersatzsicherungen und die Notlaterne hinter der Vorratsraumtür.“
- „Den Schlüssel fürs Außentor gibt es nur zweimal: an Herrn Schneiders Bund und bei seiner Kollegin. Das hat er mir beim
  Einlass gesagt.“
- „Ich hab Ahmet die 150 € nur unter Protest gegeben. Ich wollte einen Beleg. Er sagte: ‚Den Beleg gibt's von Herrn
  Schneider.‘“
- „Um halb zwölf hab ich Putzmittel aus dem Fach im Durchgang geholt, für den Ruß am Kamin.“
- „Kurz vor zwölf saß ich im Ost-Saal an der Tafel, Westseite, und hab der blinden Kuh zugeschaut.“

**Das behältst du für dich (bis Runde 2, wörtlich):**

| Wenn jemand fragt | sagst du |
|---|---|
| ob du deinen Beleg bekommen hast | „Mein Beleg ist meine Sache. Ahmet soll selbst sagen, wofür das Geld war.“ |
| was in deiner Mappe ist | „Belege. Viele Belege.“ |
| ob du heute mit Herrn Schneider gesprochen hast | „Ich hab ihn heute ein paarmal etwas gefragt. Er antwortet gern knapp.“ |

**Verboten:** „Ich hab keinen Beleg.“ · „Die Miete war echt.“ · „In meiner Mappe ist nichts von Herrn Schneider.“

#### ZR 7.7 Stufe 2

**Rundensperre:** frühestens Runde 2.

**Wann du umdrehst (wörtlich im Heft):**
1. „Sobald die Indizkarte PM3 oder WE3 offen auf dem Tisch liegt.“ (MECH §4.2)
2. „Sobald Ahmets Geheimniskarte offen auf dem Tisch liegt.“ (ZR-03)
3. „Sobald jemand mit der Taschenkontrolle deine Mappe sehen will.“ (ZR-14; die Taschenkontrolle gilt erst ab Runde 2)
4. „Liegt eins davon schon in Runde 1 offen, drehst du zu Beginn von Runde 2 um.“

**Geheimniskarte, Innenseite (wörtlich):**

> **Was ich zugebe**
> „Ich hab die 150 € nur unter Protest bezahlt und wollte einen Beleg. Um 22:30 Uhr hab ich Herrn Schneider selbst gefragt. Er hat
> mir auf einen Quittungszettel geschrieben: ‚Miete: 0 Euro. Schneider‘. Der Zettel steckt in meiner Ledermappe. Ich will mein
> Geld zurück, aber Ahmet nicht vor allen bloßstellen.“
>
> **Für den Ermittlungsbogen**
> „Heimlichtuerei · Ahmet: Der Keller hat nichts gekostet. Herr Schneider schrieb Aylin um 22:30 Uhr auf einen Quittungszettel:
> ‚Miete: 0 Euro.‘“
>
> **Und noch etwas**
> „Im Quittungsblock stand vor meinem Zettel noch ein Durchschlag: ‚Bogentür, Beschlag ausgerissen: 2.000 € Bargeld. Bis
> Mitternacht.‘ Ohne Namen.“

**Nach dem Umdrehen** sagst du auf Nachfrage außerdem (wörtlich):
- „Jeden Schaden muss Herr Schneider der Stiftung melden. Kleine Schäden zahlt er oft aus eigener Tasche. Darum ist er so streng
  beim Geld.“
- „Wer die Bogentür beschädigt hat, weiß ich nicht.“

#### ZR 7.8 Nachbohr-Ziele

| Runde | Nr | Ziel | Frage oder Vorwurf (wörtlich) | Worauf du hinauswillst | Ausweichziel |
|---|---|---|---|---|---|
| 1 | 1 | Ahmet | „Ahmet, beim Einlass wolltest du mir keinen Beleg geben. Den gibt's von Herrn Schneider, hast du gesagt. Warst du kurz vor zwölf deshalb bei ihm hinter der Theke?“ | Druck auf Ahmets Grund am Ostende | – (immer besetzt) |
| 1 | 2 | Serkan | „Serkan, kurz vor zwölf bist du aus dem Ost-Saal gegangen, gerade als alle zur blinden Kuh sollten. Wohin, und warum?“ | Serkans Auslöser 1 (erste Frage nach dem Warum, P14-09) | – (immer besetzt) |
| 2 | 1 | Ahmet | Karte offen: „Ahmet, hier ist mein Zettel: ‚Miete: 0 Euro.‘ Ich will dich nicht vorführen. Sag selbst, wofür das Geld war, und wann wir es zurückbekommen.“ Karte zu: „Ahmet, ich warte immer noch auf meinen Beleg. Hast du Herrn Schneider die Miete gegeben, ja oder nein?“ | Ahmets Heimlichtuerei (M4) | – (immer besetzt) |
| 2 | 2 | Wojtek | „Wojtek, du hast vorhin erzählt, dass du um Viertel nach acht in den Vorratsraum geleuchtet hast. Woher hattest du die Taschenlampe, und wo ist sie jetzt?“ | Wojtek wird angesprochen; seine offenen Sätze (Auftritt, Stufe 1, Was du bei dir trägst) führen zum Werkzeugkasten (MR4, P145R2-K20) | – (immer besetzt) |
| 3 | 1 | Ahmet | Ahmets Karte offen: „Ahmet, es liegt jetzt alles auf dem Tisch. Sag allen, dass sie ihr Geld zurückbekommen. Dann ist die Sache für mich erledigt.“ Ahmets Karte zu: „Ahmet, mach reinen Tisch. Wer selbst damit herausrückt, steht besser da.“ | dein Bonus-Ziel; Ahmets Zusage (RK 2.7) | – (immer besetzt) |
| 3 | 2 | Olli | Ollis Karte offen und deine offen: „Olli, im Quittungsblock von Herrn Schneider steht: Bogentür, 2.000 € Bargeld, bis Mitternacht. Warst du kurz vor zwölf deshalb bei ihm?“ Deine offen, Ollis zu: „Olli, im Quittungsblock steht ein Schaden an der Bogentür, 2.000 € bis Mitternacht, ohne Namen. Du trägst doch sonst die schweren Sachen. Warst du das?“ Deine zu: „Olli, um elf ist Herr Schneider an der Theke laut geworden. Ging es da um dich?“ | Ollis Heimlichtuerei (M7) und sein Grund für den Eiskübel | – (immer besetzt) |

#### ZR 7.9 Aktionskarte (wörtlich, MECH §4.4)

| Feld | Text |
|---|---|
| Kopf | „Aktionskarte · Aylin“ |
| Name | **Beleg bitte!** · ab Runde 1 · Klasse Beleg |
| Wirkung | „Eine Person deiner Wahl nennt für eine ihrer Behauptungen einen Beleg: eine Person, die es bezeugt, oder einen Gegenstand. Kann sie das nicht, schreibt der Detektiv ‚ohne Beleg‘ daneben.“ |
| Grenzen | „Die genannte Person sagt sofort, ob das stimmt. Hält ihr Heft es noch zurück, sagt sie: ‚Dazu sag ich jetzt nichts.‘“ |
| Fuß | „Einmal im Spiel. Danach umdrehen.“ |
| Tipp im Heft | „Gut gegen jemanden, der viel behauptet und nichts belegt. Am besten in Runde 1, wenn die Marker noch frisch sind.“ |

#### ZR 7.10 Was du bei dir trägst (wörtlich)

„Ich hab meine schwarze Ledermappe mit Belegen, darin der Quittungszettel von Herrn Schneider, dazu einen Kugelschreiber. Mein
Handy hab ich seit kurz nach zwölf zurück.“ (Taschenkontrolle bei Aylin ist Auslöser 3; der Zettel kommt mit der Karte auf den Tisch.)

#### ZR 7.11 Bonus-Ziel und fehlende Rollen

- **Wörtlich:** „**Dein Bonus-Ziel:** Du willst dein Geld zurück, ohne Ahmet vorzuführen. **Erfüllt, wenn** Ahmets
  Geheimniskarte offen lag, bevor ‚Herrn Schneiders Klemmbrett‘ oder der ‚Ascheneimer am Kamin‘ offen lag.“ (P145R2-M07)
- Prüfbar am Tisch über Nummer und Runde in der Vermerke-Liste. Ahmets Karte kann vorher über Lejlas Karte, über
  Taschenkontrolle und WE3 oder freiwillig fallen; Aylin treibt das mit ihren Zielen in Runde 1 bis 3. Erreichbar bei 19 und
  20 Personen.

| fehlt | Folge für Aylin |
|---|---|
| Tugba | Solo-Abschnitt 7.12 |
| Aylin selbst | Ahmets Texte sagen „ein Gast“ (RK 1.5); Hana nennt „ein Gast“ für die Putzmittel; M4 tragen PM3, WM9, Ahmets und Lejlas Karte |

#### ZR 7.12 Solo-Abschnitt (bei 19 Personen, im Heft wörtlich)

„**Du spielst dein Tandem allein.** Wer die Dankeskarte gebastelt hat, spielt heute niemand. Sag dann ‚ein Gast‘. Die Karte
gibt es trotzdem, und alle haben unterschrieben. Alles andere gilt wie gedruckt.“

Generator: Tandem-Kasten mit „eine Dankeskarte“; sonst keine Änderung, Aylins Karte und Auslöser hängen nicht an Tugba.

#### ZR 7.13 Absatz für Teil 90 (wörtlich, Vorlesen)

„Aylin hatte schwarz auf weiß, dass der Keller nichts gekostet hat: Herrn Schneiders Quittungszettel. Sie wollte ihr Geld
zurück, aber Ahmet nicht vor allen bloßstellen.“

### ZR 8 · Tugba (Platz 18) – die Party-Planerin · Tandem 4

#### ZR 8.1 Profil

| Feld | Inhalt |
|---|---|
| Platz, Stellung | 18, Zusatzrolle, Tandem 4. Spielt nur bei 20 Personen; Aylin ist dann immer dabei |
| Alter, Beruf | 27, Projektleiterin. Hat den Ablaufplan geschrieben |
| Rollenbezeichnung | Die Party-Planerin (Kanon, tugba) |
| Merkmal | Jackett, schmale Metallbrille, Notizbuch mit goldenem Einband und Fineliner |
| Beziehungen | **Aylin**: Tandem, die Dankeskarte. **Damir**: kocht bei ihren Spieleabenden den Tee. **Azra**: macht die Flohmarkt-Deko für ihre Spieleabende |
| Verfehlung | **keine** (E11, W-17): kein Nebendelikt, keine Lüge, kein zurückgehaltenes Wissen zum Fall |
| Haltung (wörtlich im Heft) | „Du hast nichts zu verbergen. Du willst nur, dass der Abend weitergeht. Alles, was du weißt, sagst du jedem.“ |
| Kanon-Ziel | Den Abend retten: Torte um halb eins, egal was passiert (WELT §7.3) |

#### ZR 8.2 Marker

| Marker | behauptet (Stufe 1) | wahr | Umstellen |
|---|---|---|---|
| 23:57 | 1 Ost-Saal | 1, beim Ehrenplatz neben dem Detektiv, steht | nie |
| Scheppern | 1 Ost-Saal | 1, dto. | nie |

#### ZR 8.3 Vorstellungsrunde

- **Frage des Erzählers (wörtlich, Vorlesen):** „Tugba, die Party-Planerin. Laut deinem Ablaufplan ist jetzt jemand dran:
  Wer wohl, und was steht für Mitternacht auf dem Plan?“ (P145R2-K08)
- **Dein Auftritt (wörtlich, Ich-Form, Vorlesetext):** „Laut Plan bin jetzt ich dran, und der Plan ist von mir. Ich bin Tugba,
  Projektleiterin. Ich plane sogar Spieleabende mit Ablaufplan. Heute stand drauf: Um zwölf blinde Kuh, dann Torte. Herr
  Schneider hat bei jedem Punkt geseufzt. Und jetzt? Torte um halb eins. Egal, was passiert.“
- Anekdote: keine der Dias 3–5. Eigene: der Ablaufplan (Kanon `vorstellung.tugba`, ohne Kleidung am Kopf).

#### ZR 8.4 Dein Tandem (Kasten im Heft, wörtlich)

„Du hast eine Dankeskarte für Herrn Schneider gebastelt. Aylin hat sie beim Einlass mit der Gästeliste herumgehen lassen. Alle
haben heimlich unterschrieben. Herr Schneider soll sie mit der Torte bekommen. Das ist eine Überraschung, kein Geheimnis zum
Fall. Du hast nichts zu verbergen.“

#### ZR 8.5 Wissen

Alles ist offen (W-17). „frei ab“ entfällt; nur die Dankeskarte ist eine Überraschung für Herrn Schneider.

| Zeit | Was Tugba weiß | Quelle |
|---|---|---|
| vorher | schreibt den Ablaufplan; er hängt an der Wandtafel im Ost-Saal. Um zwölf soll die blinde Kuh mit verbundenen Augen zur Torte in den Vorratsraum geführt werden. Herr Schneider hat nur widerwillig erlaubt, die Torte dort zu kühlen | Kanon `figuren.json` (tugba), WELT §2.1 |
| vorher | bastelt die Dankeskarte: „Danke für 25 Jahre Schloss!“ | ZR-17, WELT §1.4 |
| 18:00 | Aylin lässt beim Einlass alle die Karte unterschreiben. Tugba verwahrt sie in ihrem Notizbuch | WELT §3.3 |
| 18:00 | Aylin zahlt nur unter Protest und will einen Beleg. Ahmet: „Den Beleg gibt's von Herrn Schneider.“ | WELT §3.3 |
| 19:30 | im Kaminsaal: Olli wärmt sich am noch kalten Kamin die Hände. Er legt seinen linken Arbeitshandschuh in die Kamin-Nische, der Handschuh wird schwarz vom alten Ruß. Den rechten hat er in der Westentasche. Den linken lässt er liegen | WELT §3.3, §7.3 (Rand-Indiz) |
| den Abend über | führt im Notizbuch die Punkteliste der Spiele | A:64, WELT §6 |
| 23:00 | leitet im Ost-Saal ihr Ratespiel. Vorher sammelt sie alle Handys ein, auch Tims an der Kaffeemaschine; nur Joanna behält ihres. Als Herr Schneider danach an der Theke laut wird, sitzt sie wieder im Ost-Saal und versteht die Worte nicht (P3R2-14) | WELT W-27, K-23 |
| 23:55 | ruft: „Alle in den Ost-Saal! Um zwölf gibt's Torte!“ Setzt den Detektiv auf den Ehrenplatz der blinden Kuh, Augenbinde. Wojtek setzt ihm seine Kopfhörer auf | WELT §3.4 |
| 23:55–0:00 | steht neben dem Detektiv und schaut auf die blinde Kuh. Hört Knall, Rufe, Scheppern, „Hier liegt Herr Schneider!“. Als die Handylampen angehen, schaut sie zur Tür, woher der Lärm kam | WELT §5.1, §5.5, ZR-09, P3-20 |
| 0:00 | nimmt dem Detektiv Augenbinde und Kopfhörer ab: „So, Augen auf. Das war nicht die Überraschung.“ | WELT §3.4 |
| 0:05 | gibt die Handys zurück, keins hat Empfang | WELT §3.5 |

**Vermutet:** Wer im Dunkeln im Vorratsraum gewartet hat, wollte die blinde Kuh erschrecken (eigener Schluss aus ihrem Plan;
stimmt). Sie darf die Vermutung sagen, aber als Vermutung.

**Weiß nicht:** wer im Vorratsraum war; was an der Theke geschah; wann Olli den Ost-Saal verließ; wo der Bund ist.

#### ZR 8.6 Stufe 1 (keine Tarnung)

„Du hast nichts zu verbergen. Alles, was du weißt, sagst du jedem, der fragt. Auch ungefragt.“

**Das sagst du jedem (wörtlich):**
- „Laut Plan sollte um zwölf die blinde Kuh mit verbundenen Augen zur Torte in den Vorratsraum geführt werden. Das steht auf der
  Wandtafel im Ost-Saal.“
- „Herr Schneider hat nur widerwillig erlaubt, die Torte im Vorratsraum zu kühlen.“
- „Um halb acht hat Olli am kalten Kamin seinen linken Arbeitshandschuh in die Kamin-Nische gelegt. Der war schwarz vom alten
  Ruß. Den rechten hatte er in der Westentasche. Den linken hat er liegen lassen.“ (Rand-Indiz, WELT §7.3 wörtlich)
- „Um elf hab ich für mein Ratespiel alle Handys eingesammelt. Nur Joanna durfte ihres behalten, sie fotografiert. Um fünf vor
  zwölf hab ich alle in den Ost-Saal gerufen.“
- „Der Detektiv hatte die Augenbinde und Wojteks Kopfhörer auf. Ich stand neben ihm und hab nur auf die blinde Kuh geschaut.“
- „Um zwölf hab ich ihm Augenbinde und Kopfhörer abgenommen. Kurz danach hab ich allen die Handys zurückgegeben.“
- „Aylin wollte beim Einlass einen Beleg für die Miete.“
- Vermutung, als solche: „Ich glaub, da wollte jemand die blinde Kuh im Vorratsraum erschrecken.“

Es gibt keine Tarnsätze und keine Verbote: Jede Frage beantwortet Tugba nach ihrem Wissen.

#### ZR 8.7 Stufe 2

**Rundensperre:** keine. **Pflicht-Auslöser aus MECH:** keiner.

**Wann du umdrehst (wörtlich im Heft):**
„Du darfst deine Karte jederzeit umdrehen, auch mitten im Gespräch. Spätestens drehst du sie um, sobald Aylins Geheimniskarte
offen auf dem Tisch liegt oder jemand mit der Taschenkontrolle dein Notizbuch sehen will.“ (ZR-03, harmlos nach W-17)

**Geheimniskarte, Innenseite (wörtlich):**

> **Was ich zugebe**
> „In meinem Notizbuch steckt eine Dankeskarte für Herrn Schneider. Ich hab sie gebastelt, Aylin hat sie beim Einlass heimlich
> alle unterschreiben lassen. Drauf steht: ‚Danke für 25 Jahre Schloss!‘ Er sollte sie um zwölf mit der Torte bekommen. Jetzt
> bekommt er sie eben um halb eins.“
>
> **Für den Ermittlungsbogen**
> „Nichts für den Ermittlungsbogen.“ (MECH §4.2 wörtlich)
>
> **Und noch etwas**
> „Aylin wollte beim Einlass einen Beleg für die Miete. Frag sie, ob sie einen bekommen hat.“

**Nach dem Umdrehen:** keine neuen Sätze; Tugba hat schon alles gesagt.

#### ZR 8.8 Nachbohr-Ziele

| Runde | Nr | Ziel | Frage oder Vorwurf (wörtlich) | Worauf du hinauswillst | Ausweichziel |
|---|---|---|---|---|---|
| 1 | 1 | Can | „Can, um fünf vor zwölf hab ich alle zur blinden Kuh gerufen. Du warst nicht da. Ausgerechnet du, der bei jedem Spaß dabei ist. Wo warst du?“ | Druck auf Cans Marker | – (immer besetzt) |
| 1 | 2 | Joanna | „Joanna, du hast um fünf vor zwölf zum Gruppenfoto gerufen und in der Tür gestanden. Wer fehlte da noch? Ich brauch das für meinen Plan.“ | Joannas Notiz (D1, D4) kommt auf den Tisch | – (immer besetzt) |
| 2 | 1 | Olli | „Olli, um halb acht hast du deinen linken Arbeitshandschuh in die Kamin-Nische gelegt und vergessen. Den rechten hast du in der Westentasche. Was hast du heute damit angefasst?“ | lenkt zu VP7 und FN3 | – (immer besetzt) |
| 2 | 2 | Aylin | „Aylin, du wolltest beim Einlass einen Beleg für die Miete. Du hebst doch jeden Zettel auf. Hast du inzwischen einen?“ | Druck auf Aylins Karte (M4) | – (immer besetzt) |
| 3 | 1 | Can | „Can, laut Plan sollte die blinde Kuh um zwölf zur Torte in den Vorratsraum. Wer dort im Dunkeln gewartet hat, wollte sie erschrecken. Warst du das? Dann sag, wann du wieder rausgerannt bist.“ | Cans Heimlichtuerei und Alibi (M6, M3) in Runde 3 | – (immer besetzt) |
| 3 | 2 | Marek | „Marek, du hast um zwölf die Tür zum Vorratsraum aufgemacht. Steht meine Torte noch? Und was hast du an der Tür gesehen, bevor die Kerzen ausgingen?“ | Mareks Gesprächs-Auslöser in Runde 3 (ZG 5.6); dein Bonus-Ziel | – (immer besetzt) |

#### ZR 8.9 Aktionskarte (wörtlich, MECH §4.4)

| Feld | Text |
|---|---|
| Kopf | „Aktionskarte · Tugba“ |
| Name | **Handzeichen** · ab Runde 1 · Klasse Frage |
| Wirkung | „Du stellst allen eine Ja-oder-Nein-Frage über einen Ort oder eine Uhrzeit. Auf drei heben alle gleichzeitig die Hand für Ja.“ |
| Grenzen | „Jede Rolle antwortet nach ihrem Heft. Wer etwas noch zurückhalten darf, hebt nicht und sagt: ‚Ich enthalte mich.‘ Detektiv und Erzähler heben nicht.“ (P14-11) |
| Fuß | „Einmal im Spiel. Danach umdrehen.“ |
| Tipp im Heft | „Gut, um festgefahrene Gespräche zu lösen. Frag nach einem Ort oder einer Uhrzeit, zu der viele etwas sagen können, etwa: Wer war um drei vor zwölf im Ost-Saal?“ |

#### ZR 8.10 Was du bei dir trägst (wörtlich)

„Ich hab mein Notizbuch mit goldenem Einband: Ablaufplan, Punkteliste der Spiele und die Dankeskarte für Herrn Schneider. Dazu
einen Fineliner. Mein Handy hab ich seit kurz nach zwölf zurück.“

#### ZR 8.11 Bonus-Ziel und fehlende Rollen

- **Wörtlich:** „**Dein Bonus-Ziel:** Torte um halb eins, egal was passiert. Dafür muss feststehen, dass die Torte heil ist.
  **Erfüllt, wenn** bis zur Anklage jemand vor allen gesagt hat, dass die Mitternachtstorte heil im Regal steht.“
  (P145R2-M07)
- Prüfbar am Tisch. Marek weiß es offen (ZG 5.5: „Die Mitternachtstorte steht unversehrt im Regal.“); Tugba muss fragen, wer
  nach dem Licht im Vorratsraum war. Das Vorlesen von XD3 zählt auch (R-13), liegt aber in Runde 3 nach der Tipp-Runde.
  Erreichbar bei 20 Personen.

| fehlt | Folge für Tugba |
|---|---|
| Aylin | kommt nicht vor: Aylin spielt immer, wenn Tugba spielt (E6) |
| Tugba selbst | „ein Gast“ hat die Dankeskarte gebastelt (Aylins Solo-Fassung); der linke Handschuh von 19:30 bleibt ohne Zeugin, VP7 und FN3 genügen; blinde Kuh und Handys erledigt „ein Gast“ (WELT §1.1) |

#### ZR 8.12 Wenn der Partner fehlt

Kommt nicht vor (E6). Tugba spielt nie allein.

#### ZR 8.13 Absatz für Teil 90 (wörtlich, Vorlesen)

„Tugba hatte nichts zu verbergen. Sie hatte um halb acht gesehen, wie Olli seinen linken Arbeitshandschuh am Kamin liegen ließ.
Und sie hatte eine Dankeskarte für Herrn Schneider, die er nach dieser Nacht gut gebrauchen kann.“

### ZR 9 · Querschnitt: Wer bohrt wen an

#### ZR 9.1 Druck der Zusatzrollen auf die vier Verdächtigen je Runde

| Runde | auf Ahmet | auf Fatma | auf Olli | auf Can |
|---|---|---|---|---|
| 1 „Alibi-Geflecht“ | Hana, Aylin | – | Hana, Azra | Sibel, Tugba |
| 2 „Indizien-Filterung“ | Sibel, Damir, Azra, Aylin | Sibel, Serkan, Azra | Wojtek, Tugba | Hana |
| 3 „Gegenüberstellung“ | Aylin (Zusage) | – (ihre Fragen sind beantwortet) | Sibel, Hana, Azra, Wojtek, Aylin | Sibel, Damir, Serkan, Tugba |
| Summe | 7 | 3 | 9 | 7 |

Begründung: Runde 1 trifft die Marker (Can und Olli lügen dort am deutlichsten, Fatma um 23:57, Ahmet nur im Grund). Runde 2
trifft die Heimlichtuereien; Ahmets Geld betrifft alle, die gezahlt haben, darum fragen dort die meisten. Runde 3 stellt Olli
und Can gegenüber, wie im Kanon (MECH §3.5 Nr. 2). Die Fragen an Can in Runde 3 fragen nach der Reihenfolge; ehrlich
beantwortet entlasten sie ihn (M3). So bleibt Can Gegengewicht, ohne dass ihm ein Vorwurf angehängt wird, der nicht stimmt.

#### ZR 9.2 Druck auf Zeugen und Zusatzrollen

| Runde | wer fragt wen | Wirkung |
|---|---|---|
| 1 | Sibel → Zeynep | Zeyneps Schmiere wird verdächtig |
| 1 | Damir → Tim, Wojtek → Tim | Tims Knall wird verdächtig; lenkt zu MR4 (ab Runde 2) |
| 1 | Damir → Emine | Fatmas Alibi (M2) wird laut gesagt |
| 1 | Serkan → Lejla | Lejlas Satz über Olli (D2) kommt auf den Tisch: Pflicht-Auslöser (b) für Olli kommt aus Lejlas Mund, nicht aus Serkans |
| 1 | Serkan → Damir | Ahmets Alibi (M1) wird laut gesagt (P145R2-K20) |
| 1 | Wojtek → Hana | Hanas Kamin; Frage nach dem Papier vor allen, Hanas Auslöser 3 (P14-09, P145R2-M05) |
| 1 | Azra → Serkan | Serkans Gang zum Außentor; Frage nach dem Warum (P145R2-M05) |
| 1 | Aylin → Serkan | Serkans Gang zum Außentor; erste Frage nach dem Warum (P14-09) |
| 1 | Tugba → Joanna | Joannas Notiz (D1, D4) kommt auf den Tisch: Pflicht-Auslöser (a) für Olli kommt aus Joannas Notiz |
| 2 | Damir → Sibel (leise) | Tandem 1 bespricht, ob es reinen Tisch macht (P14-09) |
| 2 | Hana → Tim, Wojtek → Tim | Tims Leiste; Wojteks Karte nennt Tims Satz von 20:15 |
| 2 | Serkan → Hana (leise) | Tandem 2 bespricht, ob es reinen Tisch macht (P14-09) |
| 2 | Aylin → Wojtek | Taschenlampe und Werkzeugkasten (P145R2-K20) |
| 2 | Tugba → Aylin | Druck auf Aylins Zettel; das Tandem 4 gerät aneinander |
| 3 | Damir → Marek, Tugba → Marek | Mareks Gesprächs-Auslöser in Runde 3 |
| 3 | Hana → Tim | Tims Gesprächs-Auslöser in Runde 3 |
| 3 | Azra → Zeynep | Zeyneps Gesprächs-Auslöser in Runde 3 |
| 3 | Serkan → Lejla | Lejlas Satz zum Eiskübel nach dem Licht; lenkt zu PP9 |
| 3 | Wojtek → Azra | das Tandem 3 löst sich; zweite Stimme für Tims Satz |

Wer von Zusatzrollen angebohrt wird: Tim (5×), Lejla (2×), Marek (2×), Zeynep (2×), Hana (2×), Serkan (2×), Joanna (1×),
Emine (1×), Aylin (1×), Azra (1×), Sibel (1×), Damir (1×), Wojtek (1×). Dazu fragt der Detektiv ab 15 Personen die Gäste im
Windfang und im Kaminsaal (RK 6.12). Nur Tugba ist nie Ziel, weil Ziele nur kleinere Plätze nennen (ZG-09); sie hat je Runde
zwei eigene Ziele und ihre Aktionskarte (P145R2-K20). Kein Zeugen-Auslöser der Runde 3 wird vor Runde 3 gefragt (G-05 in ZG bleibt gewahrt).

### ZR 13 · Protokoll 4: Skalierung 13 bis 20 Personen, Herkunft und Kopftuch

#### ZR 13.1 Was sich je Personenzahl ändert

| Personen | Zusatzrollen | allein | Platzhalter, die umschalten | Wirkung auf MECH §6.3 |
|---|---|---|---|---|
| 6–12 | keine | – | Teil 12 als Hinweisseite (M-26); „ein Gast“ in MECH §1.5 und RK, ZG | – |
| 13 | Sibel | Sibel | Damir → „ein Gast“ in Sibels Heft und Karte; Marek nennt „ein Gast mit der großen Teekanne“ | M5, M6 stützend |
| 14 | + Damir | – | Damir mit Namen in Sibels, Mareks, Ahmets Texten | M1 zweite Quelle; ab hier liest jede Person „Die Rollen am Tisch“ selbst (MECH §9.13) |
| 15 | + Hana | Hana | Serkan → „ein Gast“ in Hanas Heft und Karte; Aylin → „ein Gast“ (Putzmittel) | M3 stützend (Runde 3) |
| 16 | + Serkan | – | Serkan mit Namen; Lejlas Beziehung zu Serkan erscheint (ZG 1.1) | M8 stützend |
| 17 | + Azra | Azra | Wojtek → „ein Gast“; Azras Karte trägt Tims Satz; in Tims Heft steht ab hier die Tarnsatz-Zeile dazu (ZG 3.5, P14-10) | M4, M5 stützend |
| 18 | + Wojtek | – | Wojtek mit Namen (Azra, Tim, Joanna); Wojteks Karte trägt Tims Satz | M7 stützend |
| 19 | + Aylin | Aylin | Tugba → „ein Gast“ (Dankeskarte) | M4 Quelle |
| 20 | + Tugba | – | alle Namen | M9 stützend |

In jeder Besetzung gilt: Der kleinere Platz eines Tandems spielt allein, nie der größere (E6). Alle Ziele der Zusatzrollen
nennen kleinere Plätze und sind deshalb immer besetzt (ZG-09).

#### ZR 13.2 Herkunft und Kopftuch (WELT §7.4, REG §6.8)

| Verfehlung bei Zusatzrollen | Trägerinnen und Träger | Herkünfte (nur hier, nie im Spiel) |
|---|---|---|
| Nebendelikt | Hana (Kamin), Serkan (Wunderkerzen geplant) | bosnisch, türkisch |
| Lüge (Stufe 1) | Serkan (Decken) | türkisch |
| Verschweigen | Sibel, Damir, Hana, Azra, Wojtek, Aylin | türkisch, bosnisch, polnisch, kurdisch |
| ganz unbelastet | Tugba | Kopftuch-Regel erfüllt (E11, W-17) |

Mit den Rollen 1–10 zusammen trägt keine Herkunftsgruppe eine Verfehlungsart allein (WELT §7.4). Tugba hat kein Nebendelikt,
keine Lüge und kein zurückgehaltenes Wissen zum Fall; ihre Karte ist eine harmlose Überraschung. Kopftuch und Herkunft kommen in
keinem Text dieser Datei vor, der gedruckt wird. Komik nur aus Lage und Timing (Rüstung, Kamin, Klo, Teekanne, Kugelschreiber).

---

## 16. Der Detektiv (Teil 01, Rollenteil)

### RK 6 Der Detektiv (Teil 01, Rollenteil)

Teil 01 enthält nach MECH §2.6: Seite 1 „Dein Auftritt“, „Was du selbst weißt“, „Was alle wissen“; Seite 2 „So ermittelst du“
mit Licht und (bei 6–11 Personen) den Aktionskarten fehlender Zeugen; Seite 3 Untersuchungsliste; Seite 4 Ermittlungsbogen;
Seite 5 Vermerke-Liste (1 bis 48); Seite 6 Anklage. Diese Datei liefert die Rollentexte für Seite 1 und 2 und die Aufgaben je Runde, die als
Kasten oben auf Seite 3 stehen (RK-16). Alles ist spoilerfrei und für alle vier Verdächtigen gleich gebaut.

### RK 6.1 Profil

| Feld | Inhalt |
|---|---|
| Stellung | Spielerrolle, nie verdächtig, Gast der Clique (WELT §1.5); hat keine Miete gezahlt |
| Merkmal | heller sandbeiger Trenchcoat, braun karierter Hut, Pfeife, die nur Seifenblasen bläst |
| Anrede | „du“; m/w-Fassung nur in Teil 01 und im Auftrag (MECH §9.5) |
| Beziehungen | kennt viele aus der Clique von früheren Festen; kennt das Schloss nicht |
| Was er tut | Verhörstuhl, Untersuchungen, Ermittlungsbogen, Anklage |
| Was er nicht hat | Geheimniskarte, eigene Aktionskarte, Tipp-Zettel, Bonus-Ziel (6.11) |

### RK 6.2 Marker

| Marker | gesetzt | wahr |
|---|---|---|
| 23:57 | 1 Ost-Saal | Ehrenplatz der blinden Kuh, Augenbinde, Kopfhörer |
| Scheppern | 1 Ost-Saal | dto. |

Der Detektiv setzt beide Marker bei der Lageplan-Führung (MECH §9.7 Schritt 4). Sie werden nie umgestellt.

### RK 6.3 Vorstellungsrunde

Frage des Erzählers (**wörtlich**, Vorlesetext, zuletzt nach allen Rollen):
> „Und dann ist da noch unser Gast. Du kennst viele hier von früheren Festen, aber das Schloss kennt dich noch nicht. Was hast du heute unter deinem Hut versteckt?“

„Dein Auftritt“ (Teil 01, **wörtlich**, Vorlesetext, 66 Wörter, geschlechtsneutral):
> „Unter dem Hut? Einen Kopf voller Fragen. Ich bin heute nur Gast, ehrlich. Trenchcoat und Hut trag ich, weil man nie weiß. Meine Pfeife bläst Seifenblasen, sonst nichts. Ich hör gern zu, und wer mir etwas erzählt, wird um mehr gebeten. Mein Lieblingssatz: ‚Erzähl mir mehr davon.‘ Heute will ich aber nur Torte. Und wenn mich jemand zur blinden Kuh macht, sag ich bestimmt nicht Nein.“

Quelle: Kanon „vorstellung.detektiv.m/w“ und `steckbriefe.json` („Erzähl mir mehr davon.“). Der letzte Satz bereitet die blinde
Kuh vor; er verrät nichts.

### RK 6.4 Wissen

Sicher: der Block „Was du selbst weißt“ (MECH §1.6, wörtlich) und „Was alle wissen“ (MECH §1.5). Daraus wichtig: Um 23:54 sah der
Detektiv Olli hereinkommen und sich an den Kopf der Tafel setzen. Ab 23:55 sah er nichts mehr und hörte nur sehr Lautes.
Vermutet: nichts. Der Bogen gibt keine Lesart vor (E10, REG §6.10).

### RK 6.5 Deine Aufgaben je Runde (Teil 01, Kasten auf Seite 3, **wörtlich**)

> **Runde 1 – Das Alibi-Geflecht**
> Ziel: Für Ahmet, Fatma, Olli und Can füllst du die Zeilen „Ort um 23:57“ und „Alibi beim Scheppern“.
> Verhörstuhl, erstes Ziel: Hol die vier Verdächtigen nacheinander kurz auf den Stuhl. Stell jeder dieselben drei Fragen aus dem Leitfaden (A1 bis A3).
> Zweites Ziel, ganzer Tisch: Bitte den Erzähler um den Impuls ‚Wer war neben dir?‘. Alle antworten reihum mit einem Satz.
> Wenn jemand fehlt: Liegt an einem Ort ein Zeugenstreifen, kann ein Ortstermin dort ihn aufdecken.
> Untersuchungen: drei Karten mit „ab Runde 1“. Ortstermine zeigen dir, wer wo war. Spurkarten zeigen dir Gegenstände.
>
> **Runde 2 – Die Indizien-Filterung**
> Ziel: Für alle vier füllst du die Zeile „Heimlichtuerei“. Wer Alibi ✓ und Heimlichtuerei ✓ hat, scheidet aus.
> Erstes Ziel, ganzer Tisch: Geld. Bitte den Erzähler um den Impuls ‚Geld‘. Alle antworten reihum mit einem Satz.
> Zweites Ziel, ganzer Tisch: Bitte den Erzähler um den Impuls ‚Turmgang und Bogentür‘, später um ‚Das Gesicht‘. Alle antworten reihum mit einem Satz.
> Untersuchungen: drei Karten, jetzt auch mit „ab Runde 2“.
>
> **Runde 3 – Die finale Gegenüberstellung**
> Ziel: Fundort, Schlüsselbeweis und das Alibi für das leuchtende Gesicht. Danach klagst du an.
> Erstes Ziel, ganzer Tisch: Reihenfolge. Bitte den Erzähler um den Impuls ‚Was kam zuerst?‘. Wer im Dunkeln etwas gesehen oder gehört hat, antwortet der Reihe nach.
> Zweites Ziel, ganzer Tisch: Wege. Bitte den Erzähler um den Impuls ‚Der Weg zur Vorratsraumtür‘, danach um ‚Nach dem Licht‘.
> Tipp-Runde: Nach „Reinen Tisch“ tippen alle außer dir. Du wartest.
> Untersuchungen: Danach drei Karten, jetzt auch mit „ab Runde 3“. Trag die Vermerke ein. Dann klagst du an. Mit der Anklage legst du den Stift weg.

Prüfung: Kein Ziel nennt einen Verdächtigen allein, einen Fundort, eine Waffe oder eine Indizkarte als richtige Wahl (E10).
Runde-2-Ziele entsprechen den Impulsen I-2.1 bis I-2.3, Runde-3-Ziele I-3.1 bis I-3.3 (MECH §9.9), damit Erzähler und Detektiv
dasselbe Gespräch treiben. Ziele für den ganzen Tisch laufen über Impulse, nicht über den Verhörstuhl: Bei 20 Personen wären
es sonst 18 Befragungen am Stuhl (P145R2-M03). Antworten auf einen Impuls gelten als vor allen gesagt (R-13); I-3.1 erfüllt
damit die Runde-3-Auslöser von Tim, Marek und Zeynep.

### RK 6.6 Fragen-Leitfaden (Teil 01, Seite 2, **wörtlich**)

> **A – An Ahmet, Fatma, Olli und Can (immer dieselben Fragen)**
> A1 „Wo warst du um drei vor zwölf, und wer hat dich dort gesehen?“
> A2 „Wo warst du, als es schepperte? Wer war neben dir, und woran hat die Person dich erkannt?“
> A3 „Was hast du im Dunkeln gehört, und in welcher Reihenfolge?“
> A4 „Was hattest du heute mit Herrn Schneider zu tun?“
> A5 „Was trägst du bei dir?“
> A6 „Willst du an deiner Geschichte etwas ändern?“
>
> **B – An alle anderen**
> B1 „Wo warst du beim Knall, und wo beim Scheppern?“
> B2 „Wer war im Dunkeln in deiner Nähe?“
> B3 „Was hast du gesehen, gehört, gespürt oder gerochen?“
> B4 „Wen hast du kurz vor zwölf wo gesehen?“
>
> **C – Wenn etwas nicht zusammenpasst**
> C1 „Dein Marker sagt das eine, jemand anderes sagt das andere. Wer irrt sich?“
> C2 „Wer kann das bezeugen?“
> C3 „Woher weißt du das? Gesehen, gehört oder erzählt bekommen?“
>
> **Gut zu wissen**
> – Lügen ist erlaubt, solange ein Heft es erlaubt. Über ihren eigenen Ort sagen alle außer den vier Verdächtigen immer die Wahrheit.
> – Wer bei einer Lüge über seinen Ort ertappt wird, stellt seinen Marker vor allen um.
> – Auf dem Verhörstuhl sitzt jemand höchstens zwei Minuten. Bis 11 Personen hören die anderen zu. Ab 12 Personen reden sie leise weiter. Soll eine Antwort für alle zählen, bitte vorher den Erzähler um ‚Alle mal herhören!‘.
> – „Vor allen“ heißt: Der ganze Tisch hört zu. Das ist so am Verhörstuhl, solange alle anderen schweigen, beim Ortstermin, bei einem Impuls, beim Vorlesen einer Karte und nach „Alle mal herhören!“.
> – Wer etwas noch nicht bestätigen darf, sagt: „Dazu sag ich jetzt nichts.“ Das ist erlaubt (R-14).
> – Frag nie nach dem Text einer verdeckten Karte. Wer seine Karte umdrehen muss, tut das von selbst.

Der Satz „Über ihren eigenen Ort sagen alle außer den vier Verdächtigen immer die Wahrheit“ ist R-01 und WELT §4.2. Er hilft
dem Detektiv, ohne etwas zu verraten.

### RK 6.7 So gehst du mit Untersuchungen um (Teil 01, Seite 2, **wörtlich**)

> 1. Am Ende jeder Runde nennst du nacheinander drei Indizkarten aus deiner Liste. Wählbar sind alle Karten, deren Runde schon erreicht ist. In Runde 3 erst nach der Tipp-Runde.
> 2. Der Erzähler sucht die Karte heraus und gibt sie dir ungelesen. Du liest sie laut vor.
> 3. Danach fragt der Erzähler, ob die Karte bei jemandem etwas auslöst. Wer betroffen ist, dreht seine Geheimniskarte um.
> 4. Bei einem Ortstermin antwortet vor allen, wer dort war. Fehlt diese Person heute, dreht der Erzähler ihren Zeugenstreifen um.
> 5. Leg die Karte offen an den Rand des Lageplans. Trag den Vermerk wörtlich in deine Vermerke-Liste ein, mit Nummer und Runde.
> 6. Steht auf der Karte, dass an diesem Platz kein Schlüsselbund liegt, kreuz in deiner Liste „Kein Bund“ an. Das gilt nur für diesen Platz, nicht für Orte, die die Karte nur als Entfernung nennt.
> 7. Was du nicht wählst, bleibt für später. Keine Karte geht verloren.
> 8. Eine Taschenkontrolle oder die Stirnlampe kann dir eine Karte zusätzlich öffnen. Das zählt nicht zu deinen drei.

Punkt 6 verlangt eine zusätzliche Spalte „Kein Bund ☐“ in der Untersuchungsliste (MECH §2.6 Seite 3, RK-19).

### RK 6.8 Aktionskarten (Teil 01, Seite 6; P145R2-K13)

Eigene Aktionskarte: keine. Bei 6 bis 11 Personen liegen die Aktionskarten der fehlenden Zeugen bei dir (MECH §4.6). Tipps
dazu, **wörtlich** (nur die gedruckt, deren Karte heute bei dir liegt):

| Karte | Tipp (wörtlich) |
|---|---|
| Krankenbesuch | „Frag Herrn Schneider nach seinem Platz kurz vor zwölf und nach dem, was er im Dunkeln noch weiß. Liegt seine rechte Hand (JA9) noch zu, kommt sie dabei offen auf den Tisch.“ |
| Kreuzverhör | „Nimm zwei, die sagen, sie waren zusammen. Stimmen ihre Antworten überein?“ |
| Stirnlampe | „Ab Runde 2. Eine vierte Untersuchung in einer Runde, in der viel offen ist.“ |
| Zeitstempel | „Gut in Runde 1: Nennt die Person jemanden, der heute fehlt, deckt der Erzähler dessen Zeugenstreifen auf.“ |
| Taschenkontrolle | „Ab Runde 2. Was jemand bei sich trägt, kommt ohne Untersuchung auf den Tisch.“ |
| Gelbe Karte | „Spiel sie, bevor du eine Person auf den Verhörstuhl holst, die sich mit einer Karte schützen könnte.“ |

Wenn andere Karten gegen dich gespielt werden, **wörtlich**:
> „Einspruch: Stell die Frage einer anderen Person. Gegenfrage: Beantworte zuerst die Frage, dann antwortet die Person. Themenwechsel: Der Erzähler liest einen Impuls, das Thema darf später wiederkommen. Gegen Ortstermine, Indizkarten und offene Karten hilft keine dieser Karten. Retourkutsche: Wirfst du jemandem etwas vor, sagst du zuerst, wo du beim Scheppern warst. Du saßt mit Augenbinde auf dem Ehrenplatz der blinden Kuh. Lagebesprechung: Sag ehrlich, wen du gerade verdächtigst und warum.“

### RK 6.9 Ermittlungsbogen führen (Teil 01, Seite 4, Hinweise **wörtlich**)

> „Vermerke von Karten und Streifen schreibst du wörtlich ab. Was jemand nur sagt, schreibst du selbst auf und nennst die Person als Quelle. Für deine Punkte zählt, was in der richtigen Zeile steht, nicht woher es kam. Ein ✓ bei ‚Alibi‘ braucht eine Quelle, die nicht die Person selbst ist. Ein Vermerk ‚für das leuchtende Gesicht‘ gehört in die Spalte der Person, die das Gesicht war. Wer das war, zeigt dir eine offene Karte. Hat eine Spalte ‚Alibi ✓‘ und ‚Heimlichtuerei ✓‘, kreuzt du ‚Ausgeschieden‘ an. Teil 1 des Schlüsselbeweises kreuzt du an, wenn eine Karte mit dem Vermerk ‚Schlüsselbeweis, Teil 1‘ offen liegt. Teil 2 kreuzt du an, wenn eine offene Karte an einer Person genau die Spur zeigt, die Teil 1 beschreibt. Dann schreibst du dazu, zu wem er gehört. Macht jemand am Rundenende freiwillig reinen Tisch, schreib ‚freiwillig‘ zum Eintrag.“ (P5-B1, P2-05, P14-07, P2-24)

Regeln 2.3 und 2.4 aus MECH stehen darunter wörtlich.

### RK 6.10 Anklage (Teil 01, Seite 6, Hilfe **wörtlich**)

> „Nenn eine Person und drei Gründe. Gute Gründe stehen auf deinem Bogen. Wo war die Person um drei vor zwölf? Hält ihr Alibi? Wo lag der Schlüsselbund, und was zeigt der Schlüsselbeweis? So klingt es: ‚Ich klage diese Person an. Erstens war sie um drei vor zwölf genau dort. Zweitens hält ihr Alibi nicht. Drittens passt der Schlüsselbeweis zu ihr.‘“

### RK 6.11 Warum der Detektiv keine Geheimniskarte, keine eigene Aktionskarte, keinen Tipp-Zettel und kein Bonus-Ziel hat

| Teil | Entscheidung | Grund |
|---|---|---|
| Geheimniskarte | keine | Er hat nichts zu verbergen; er ist der einzige, dessen Aussagen alle wahr sind (WELT §1.5) |
| Aktionskarte | keine eigene | Verhörstuhl ohne Höchstzahl und drei Untersuchungen je Runde sind seine Werkzeuge; in kleinen Runden bekommt er die Karten fehlender Zeugen (M-18) |
| Tipp-Zettel | keiner | Seine Anklage ist sein Tipp (M-21) |
| Bonus-Ziel | keins | Er wird über die neun Meilensteine und das Ende gewertet (MECH §6, §8.2) |
| Nachbohr-Ziele | als „Aufgaben je Runde“ (6.5) | Er fragt alle, nicht nur zwei; kein Ausweichziel nötig, weil Streifen und Ortstermine fehlende Rollen ersetzen |

### RK 6.12 Wenn Rollen fehlen

| Personen | was der Detektiv anders macht |
|---|---|
| 6–11 | Zeugenstreifen liegen neben dem Lageplan. Ortstermine und die Karte „Zeitstempel“ decken sie auf. Er hält die Aktionskarten der fehlenden Zeugen (MECH §4.6) |
| 6 | Alle sechs Zeugen fehlen. Der Erzähler ermuntert ihn, Ortstermine früh zu nutzen (MECH §9.13). Budget-Pfad: MECH §6.3 |
| 12–20 | keine Streifen; ab 12 Personen laufen beim Verhörstuhl die anderen Gespräche leise weiter (R-02). Ab 14 Personen ruft der Erzähler nach der Hälfte „Wechsel!“, in Runde 2 und 3 vorher die Gegenüberstellung (MECH §1.3); dort hört der Detektiv zu und darf fragen |
| 15–20 | Hol in Runde 1 oder 2 die Gäste mit Marker im Windfang oder im Kaminsaal kurz auf den Verhörstuhl. Frag sie: „Was wolltest du kurz vor zwölf dort, und warum?“ So kommen auch Zusatzrollen ins Gespräch, die sonst selten gefragt werden (P145R2-M05) |

Liest der Erzähler den Ausweichsatz (MECH §9.9), ist das für den Detektiv der Hinweis auf einen Ortstermin.

---

## 17. Die vier versiegelten Fassungen (Teil 11)

### RK 7.1 Aufbau und Längen (E9, MECH §10.4, REG §6.10 und §6.11)

Jede Fassung hat vier A4-Seiten mit denselben Überschriften in derselben Reihenfolge. Die Fassung wird nach dem Tat-Moment still
geöffnet (MECH §9.6). Sie enthält, was im Heft nicht stehen darf: die ganze Wahrheit der Nacht, das Wissen, das nur diese Person
hat, die Sätze für die Zeit nach dem Umdrehen und Stufe 3. Kein Rahmen, keine Farbe, kein Satz verrät außen oder am Seitenbild, welche Fassung die
Tat enthält (REG §6.10, `ENTSCHEIDUNGSLOG.md:938-941`).

| Seite | Überschrift (wörtlich) | Inhalt | Wörter je Fassung |
|---|---|---|---|
| 1 | – | Außenseite: Code groß in der Mitte, darunter „Versiegelt. Erst öffnen, wenn der Erzähler es sagt.“ Sonst nichts | 9 |
| 2 | „Dein Ziel heute Nacht“ | zwei Sätze (erster Satz: wer es war oder nicht) | 25–35 |
| 2 | „Was wirklich geschah“ | Zeitleiste als Tabelle, 16 oder 17 Zeilen | 350–420 |
| 3 | „Was nur du weißt“ | fünf Punkte | 100–120 |
| 3 | „Dein Heft und die Wahrheit“ | drei bis vier Sätze | 25–40 |
| 3 | „Wenn es eng wird“ | fünf Sobald-Sätze mit Antwort (P2-04); jeder gilt, sobald sein Fall eintritt, nicht erst in Runde 3 (P2-17) | 120–155 |
| 3 | „Stufe 3: Wenn du angeklagt wirst“ | Bedingung (gleich für alle) und Text zum Vorlesen | 55–70 |
| 4 | „Notizen“ | Linien | – |

Bedingung zu Stufe 3, für alle vier **wörtlich**: „Nennt der Detektiv bei der Anklage dich, stehst du auf und liest diesen Text laut vor. Wirst du nicht angeklagt, liest du ihn nicht vor. Den Rest erzählt das Auflösungsheft.“

Uhrzeiten nur als Kanon-Minuten, Sekunden nie, im Dunkeln nur Reihenfolgen (WELT §0.2). Namen fehlender Rollen nach 1.5.
Längenprüfung in 7.7.

### RK 7.2 Außenseiten

| Code | Außenseite (**wörtlich**) |
|---|---|
| WW4 | „WW4 · Versiegelt. Erst öffnen, wenn der Erzähler es sagt.“ |
| JM3 | „JM3 · Versiegelt. Erst öffnen, wenn der Erzähler es sagt.“ |
| RN7 | „RN7 · Versiegelt. Erst öffnen, wenn der Erzähler es sagt.“ |
| YW4 | „YW4 · Versiegelt. Erst öffnen, wenn der Erzähler es sagt.“ |

Die Zuordnung Code → Person steht nur im jeweiligen Heft (Seite 4) und hier, nicht im Erzählerheft (MECH §9, E10).

### RK 7.3 WW4 – Ahmet

**Dein Ziel heute Nacht**, **wörtlich**: „Du warst es nicht. Trotzdem hast du heute Nacht etwas zu verbergen. Du willst, dass niemand dich verdächtigt, und die erfundene Miete soll bis zum Morgen nicht herauskommen.“

**Was wirklich geschah** (Zeitleiste, **wörtlich**):

| Zeit | Was geschah |
|---|---|
| Wochen vorher | Herr Schneider überlässt dir den Keller umsonst. Dafür gestaltest du das Programm des Adventsmarkts der Schlossstiftung. |
| Wochen vorher | Beim Essen bestellst du viel zu groß. [Marek] verlangt eine Nachzahlung: 150 € pro Gast, fällig heute Abend in Bargeld. |
| vorher | Du erzählst [Lejla] von deinem Ärger mit der Rechnung. Sie verspricht, nichts zu sagen. |
| 18:00 | Am Jackenständer im Ost-Saal sammelst du von allen anderen aus der Clique 150 € „Miete“ ein. Das Geld kommt in einen Umschlag mit der Aufschrift „Miete Schlosskeller“. |
| 18:00 | In die Brusttasche deiner Jacke steckst du eine Namensliste, hinter jedem Namen „150 € ✓“. [Aylin] will einen Beleg. Du sagst: „Den Beleg gibt's von Herrn Schneider.“ |
| 23:00 | An der Theke wird Herr Schneider laut. Du sitzt beim Ratespiel im Ost-Saal und verstehst die Worte nicht. |
| 23:51 | Vor der Theke sagt Herr Schneider leise zu dir: „Um zwölf sag ich allen, was der Keller gekostet hat.“ Du hältst den dicken Umschlag in der Hand. |
| 23:53 | Du siehst, wie [Joanna] ihr Handy sinken lässt. Du bittest sie: „Zeig das Foto bitte keinem.“ Sie verspricht es. Ihr geht zusammen in den Ost-Saal. |
| 23:55 | Du hängst deine schwarze Jacke an den Jackenständer. Den Umschlag behältst du in der Hand. Olli sitzt am Kopf der Tafel. |
| 23:57 | Du gehst an [Joanna] vorbei und schlüpfst am Ostende hinter die Theke. Neben dir füllt [Marek] die Saftkrüge. |
| 23:57 | Herr Schneider steht am Ostende und sagt leise zu Olli am Eiskübel: „Zweitausend, bis zwölf.“ Du willst ihn bitten: „Bitte sag um zwölf nichts. Ich geb allen das Geld zurück.“ |
| 23:57 | Herr Schneider geht hinter der Theke an dir vorbei zur Kaffeemaschine. Du kommst nicht zu Wort. [Damir] kommt mit einer großen Teekanne und wartet hinter [Marek]. Dann ruft Herr Schneider: „Nicht die alte Leiste!“ |
| 23:58 | Knall. Überall ist es dunkel. Du kauerst dich an [Mareks] Beine und flüsterst: „[Marek]? Ich bin's, Ahmet.“ [Damir] kauert neben dir. Herr Schneider ruft: „Ruhe! Ich hol die Notlaterne.“ |
| 23:58 | Im Dunkeln hörst du „Hab ich dich!“, zweimal „Stehen bleiben!“ und kurz darauf das Scheppern. Du rührst dich nicht und hältst den Umschlag fest. Durch das Ostende kommt niemand an dir vorbei. |
| 0:00 | Das Licht geht an. Du stehst auf, den Umschlag in der Hand. [Marek] findet Herrn Schneider im Vorratsraum. |
| 0:12 | Am Kamin nimmst du das Geld aus dem Umschlag und steckst es in die Hosentasche. Den leeren Umschlag wirfst du in den Ascheneimer. Kurz danach stehst du wieder vor der Theke. |

**Was nur du weißt**, **wörtlich**:
> 1. Um 23:57 Uhr stand Olli am Eiskübel. Herr Schneider sagte leise zu ihm: „Zweitausend, bis zwölf.“ Wofür, weißt du nicht.
> 2. [Joanna] hat dich um 23:51 Uhr mit Herrn Schneider fotografiert. Sie hat versprochen, das Foto keinem zu zeigen.
> 3. [Lejla] weiß von deinem Ärger mit der Rechnung. Sie hat versprochen, nichts zu sagen.
> 4. Das Geld steckt in deiner Hosentasche. Der leere Umschlag liegt im Ascheneimer am Kamin. Bis zum Morgen willst du allen ihr Geld zurückgeben.
> 5. Wer im Dunkeln an der Vorratsraumtür war, weißt du nicht. Du hast gekauert und nichts gesehen. Durch das Ostende ist niemand an dir vorbeigekommen.

**Dein Heft und die Wahrheit**, **wörtlich**: „Dein Heft sagt dir die Wahrheit. Was in Stufe 2 steht, ist genau das, was geschah. Mehr musst du nicht verbergen. Mit dem Scheppern hast du nichts zu tun.“ (P5-B3)

**Wenn es eng wird** (gilt, sobald der Fall eintritt), **wörtlich**:
> – Sobald jemand sagt, du warst nah an der Vorratsraumtür: „Ich hab am Ostende gekauert, an [Mareks] Beinen. Bis das Licht anging, bin ich da nicht weg.“
> – Sobald jemand fragt, was du im Dunkeln gehört hast: „Erst ‚Ruhe! Ich hol die Notlaterne.‘ Dann ‚Hab ich dich!‘, zweimal ‚Stehen bleiben!‘ und das Scheppern. Gesehen hab ich nichts.“
> – Sobald jemand fragt, warum du nach zwölf am Kamin warst (nur, wenn deine Karte offen ist): „Ich wollte den leeren Umschlag loswerden. Das Geld ist in meiner Hosentasche.“
> – Sobald dich jemand wegen des Geldes verdächtigt: „Mit dem Geld hab ich Mist gebaut. Aber Herrn Schneider hätte ich nie etwas getan.“
> – Sobald jemand verlangt, dass du deinen Marker ‚Scheppern‘ umstellst: „Mein Marker stimmt. [Marek] hat mich die ganze Zeit an seinen Beinen gespürt.“

**Stufe 3: Wenn du angeklagt wirst** (**wörtlich**, Vorlesen, 64 Wörter):
> „Ich? Nein. Beim Scheppern hab ich hinter der Theke am Ostende gekauert, an [Mareks] Beinen. Ich hab mich nicht bewegt, bis das Licht anging. [Marek] hat mich die ganze Zeit gespürt. Ja, mit der Miete hab ich euch angeschwindelt. Das tut mir leid, ihr bekommt euer Geld zurück. Aber an der Vorratsraumtür war ich nicht. Den Schlüsselbund hab ich nie in der Hand gehabt.“

### RK 7.4 JM3 – Fatma

**Dein Ziel heute Nacht**, **wörtlich**: „Du warst es nicht. Trotzdem hast du heute Nacht etwas zu verbergen. Du willst, dass niemand dich verdächtigt, und die Schatulle soll zurück, ohne dass es alle erfahren.“

**Was wirklich geschah** (**wörtlich**):

| Zeit | Was geschah |
|---|---|
| vorher | In der Unibibliothek erzählt dir [Azra] von einer Münzschatulle mit Wappen in der Schauvitrine des Schlosses. Deine Abschlussarbeit handelt von alten Münzbildern. |
| 18:00 | Ihr kommt über die Sandsteinstufen und das Außentor. Am Jackenständer im Ost-Saal zahlst du Ahmet 150 € „Miete“, wie alle. |
| 21:00 | Im Turmgang hat jemand die Ritterrüstung für einen Menschen gehalten und geschrien. Als es sich herumspricht, lachen alle. |
| 23:30 | Dichter Qualm aus dem Kamin füllt den Kaminsaal. Alle husten, die Klappen der Lichtschächte werden aufgerissen. |
| 23:40 | Im Turmgang hebst du die gesprungene, lose Scheibe der Schauvitrine an. Du nimmst die Münzschatulle heraus und steckst sie in deine Tasche. Du willst das Wappen mit den zwei Löwen abzeichnen. |
| 23:40 | Dabei bricht die Ecke der Scheibe. Scherben fallen zu Boden, feine Splitter bleiben an deinem rechten Mantelärmel. [Emine] kommt die Wendeltreppe herunter und sieht alles. |
| 23:40 | Du sagst: „Montag bring ich sie zurück. Versprochen.“ [Emine] verspricht zu schweigen. Ihr geht zurück zum linken Buffet. |
| 23:45 | Am linken Buffet holt sich [Zeynep] Gebäck. Deine Tasche ist schwer und ausgebeult. |
| 23:50 | Du stehst am linken Buffettisch beim Gebäck. [Emine] steht hinter dem Tisch, ihre Thermoskanne neben sich. |
| 23:54 | Ihr tuschelt über die Tasche. Du hältst sie ganz fest. Auf die Theken-Klappe achtet ihr nicht. |
| 23:56 | Herr Schneider kommt an dein Buffet. Er sieht die Splitter an deinem Ärmel und sagt leise: „Die Schatulle. Um Punkt zwölf geh ich raus und ruf die Polizei.“ [Emine] hört es. Dann geht er zum Ostende der Theke. |
| 23:57 | Gleich danach siehst du Ahmet mit einem dicken Umschlag am Ostende hinter die Theke schlüpfen. |
| 23:57 | Du gehst mit der Tasche zur Theken-Klappe. Du willst Herrn Schneider die Schatulle sofort zurückgeben. Von der Klappe siehst du Olli am Eiskübel vor Herrn Schneider stehen. Was sie reden, hörst du nicht. |
| 23:57 | Herr Schneider geht hinter der Theke zur Kaffeemaschine, nicht zu dir. Du wartest an der Klappe. Dann ruft er: „Nicht die alte Leiste!“ |
| 23:58 | Knall. Im Dunkeln gehst du zurück und kauerst dich hinter den linken Buffettisch neben [Emine]. Du flüsterst: „[Emine]? Ich bin's, Fatma.“ |
| 23:58 | Du hörst „Hab ich dich!“, zweimal „Stehen bleiben!“ und kurz darauf das Scheppern. Du hältst die Tasche fest und rührst dich nicht. |
| 0:00 | Das Licht geht an. Du stehst auf, die Tasche über der Schulter. Die Schatulle ist noch drin. |

**Was nur du weißt**, **wörtlich**:
> 1. Von der Klappe hast du um 23:57 Uhr Olli am Eiskübel vor Herrn Schneider gesehen. Was sie redeten, hast du nicht gehört.
> 2. Um 23:57 Uhr ging Ahmet mit einem dicken Umschlag am Ostende hinter die Theke.
> 3. [Emine] hat dich an der Vitrine gesehen und die Drohung gehört. Sie hat versprochen zu schweigen.
> 4. Die Scheibe hatte schon einen Sprung, bevor du sie angehoben hast. Wer ihn gemacht hat, weißt du nicht. Die Scherben am Boden sind von dir, der Sprung nicht.
> 5. Wer im Dunkeln an der Vorratsraumtür war, weißt du nicht. Du hast gekauert und nichts gesehen. Von der Klappe bis hinter den Buffettisch waren es nur ein paar Schritte.

**Dein Heft und die Wahrheit**, **wörtlich**: „Dein Heft sagt dir die Wahrheit. Was in Stufe 2 steht, ist genau das, was geschah. Mehr musst du nicht verbergen. Mit dem Scheppern hast du nichts zu tun.“ (P5-B3)

**Wenn es eng wird** (gilt, sobald der Fall eintritt), **wörtlich**:
> – Sobald jemand sagt, kurz vor dem Scheppern sei jemand von der Klappe gekommen: „An der Klappe war ich nur vor dem Knall. Beim Knall bin ich sofort zurück zu [Emine]. Sie hat mich flüstern hören.“
> – Sobald jemand fragt, was du von der Klappe aus gesehen hast (nur, wenn dein Marker auf der Klappe steht): „Olli am Eiskübel vor Herrn Schneider. Dann ging Herr Schneider hinter der Theke zur Kaffeemaschine.“
> – Sobald jemand fragt, warum du die Schatulle nicht gleich zurückgegeben hast: „Herr Schneider ging zur Kaffeemaschine, nicht zu mir. Dann kam der Knall.“
> – Sobald dich jemand wegen der Polizei-Drohung verdächtigt: „Ich wollte die Schatulle zurückgeben, nicht weglaufen. Sie liegt doch noch in meiner Tasche.“
> – Sobald jemand verlangt, dass du deinen Marker ‚Scheppern‘ umstellst: „Der Marker stimmt. [Emine] hat mich gleich nach dem Knall flüstern hören.“

**Stufe 3: Wenn du angeklagt wirst** (**wörtlich**, Vorlesen, 61 Wörter):
> „Ich? Nein. Beim Scheppern hab ich hinter dem linken Buffettisch gekauert, neben [Emine]. Sie hat mich flüstern hören. An der Theken-Klappe war ich nur vor dem Knall. Ich wollte Herrn Schneider die Münzschatulle zurückgeben. Am Montag kommt sie zurück, versprochen. Ich hab sie nur ausgeliehen. Aber an der Vorratsraumtür war ich nicht. Den Schlüsselbund hab ich nie in der Hand gehabt.“

### RK 7.5 RN7 – Olli (mit der Tat)

**Dein Ziel heute Nacht**, **wörtlich**: „Du warst es. Vor dem Morgen soll das niemand erfahren. Du willst unentdeckt bleiben, ohne einen Unschuldigen ins Unglück zu stürzen, und den Türschaden selbst mit Herrn Schneider klären.“

**Was wirklich geschah** (**wörtlich**; Wortwahl der Tat nach Kanon `texte/taeter-olli.json`, REG §6.1):

| Zeit | Was geschah |
|---|---|
| 18:30 | Mit [Tim] trägst du die Warmhaltebehälter durch Hoftür, Turmgang und Bogentür. |
| 18:35 | Vor der Bogentür schrammst du mit einem Behälter die geschnitzte Tür. Ein Beschlag reißt aus der gekalkten Wand. Holzsplitter und weißer Kalk bleiben an deinen Ärmeln. |
| 18:45 | [Tim] holt braunes Möbelwachs aus dem Werkzeugkasten. Du reibst es mit deinem rechten Arbeitshandschuh in die Schramme. Den Handschuh steckst du in die Westentasche. |
| 18:50 | Herr Schneider entdeckt den Schaden. Er verlangt 2.000 € in Bargeld bis Mitternacht und schließt die Tore ab: „Keiner geht, bevor das bezahlt ist.“ |
| 19:30 | Am kalten Kamin wärmst du dir die Hände. Den linken Arbeitshandschuh legst du in die Kamin-Nische und vergisst ihn dort. |
| 23:00 | Vor der Theke streitet ihr laut. Herr Schneider ruft: „Bis Mitternacht. Sonst ruf ich die Polizei!“ [Tim] hört alles. |
| 23:50 | An der Bogentür klemmt sich [Tim] den Finger ein. Um 23:52 Uhr sagst du zu ihm: „Ich hol dir Eis. Und dann red ich mit Schneider.“ |
| 23:54 | Du setzt dich im Ost-Saal an den Kopf der Tafel. |
| 23:57 | Du gehst an [Joanna] vorbei zum Eiskübel. Herr Schneider steht am Ostende und sagt leise: „Zweitausend, bis zwölf.“ Hinter der Theke am Ostende steht Ahmet. |
| 23:58 | Knall. Du bleibst am Eiskübel stehen. Im Kerzenlicht springt ein leuchtendes Gesicht aus dem Vorratsraum. Herr Schneider packt es: „Hab ich dich!“ Du gehst im Dunkeln vor der Theke nach Westen. Du willst mit ihm reden. |
| 23:58 | Das Gesicht reißt sich los. Herr Schneider brüllt: „Stehen bleiben!“ Das Gesicht rennt dicht an dir vorbei durch die Klappe. Wer darunter steckt, erkennst du nicht. Du gehst durch die Klappe hinter die Theke. Herr Schneider brüllt: „Stehen bleiben, hab ich gesagt!“ |
| 23:58 | Vor der Vorratsraumtür sagst du: „Lass uns reden, nur kurz.“ Er packt dich am Ärmel und zischt: „Zweitausend. Sonst Polizei.“ In Panik greifst du den Kerzenständer am Fuß. Dann ist da nur ein dumpfer Schlag und Poltern. |
| 23:58 | Holzsplitter und weißer Kalk von deinem Ärmel bleiben im weichen Wachs am Fuß kleben. Rote Wachstropfen fallen auf den Handschuh in deiner Westentasche. Die Kerzen gehen aus. Herr Schneider fällt rückwärts in den Vorratsraum. |
| 23:58 | Im Dunkeln reißt du ihm den Schlüsselbund von der Gürtelschlaufe. Mit dem Schlüssel komm ich raus, denkst du. Gleich danach weißt du: Flucht macht alles schlimmer. Du tastest dich zurück zum Eiskübel und schiebst den Bund unter die Eiswürfel. |
| 23:58 | Du kriechst zum rechten Buffettisch und flüsterst: „[Lejla]? Ich bin's, Olli.“ |
| 0:00 | Das Licht geht an. Du gehst zum Eiskübel. Um 0:01 Uhr bringst du [Tim] obenauf eine Handvoll Eis in den Durchgang: „Hier, dein Eis. Hat gedauert.“ |

Prüfung der Tat-Zeilen: kein Verb des Schlagens, Waffe nur als Gegenstand, den Olli „greift“; „ein dumpfer Schlag und Poltern“
wie Kanon; kein Blut, keine Beschreibung von Herrn Schneider außer „fällt rückwärts“; Reihenfolge wie WELT §3.4 (Gesicht gepackt
→ Olli geht nach Westen → „Stehen bleiben!“ → Gesicht an ihm vorbei → Olli durch die Klappe → zweiter Ruf → Tür → Scheppern →
Bund → Eiskübel → Lejla). Lichtregel W-23: Olli sieht auf dem Rückweg nichts, und niemand sieht ihn.

**Was nur du weißt**, **wörtlich**:
> 1. Das leuchtende Gesicht ist weggerannt, bevor du zur Vorratsraumtür gingst. Wer darunter steckte, hast du nicht erkannt. Nenn nie einen Namen dafür.
> 2. Deine Stufe 2 verdreht die Wahrheit: Herr Schneider hat das Gesicht gepackt, nicht umgekehrt. Beim Scheppern warst du an der Tür, nicht am Eiskübel.
> 3. Der Schlüsselbund liegt unter den Eiswürfeln im Eiskübel. Nach dem Licht hast du nur obenauf Eis genommen.
> 4. An deinen Ärmeln hängen Kalk und Holzsplitter von der Bogentür. Auf deinem rechten Handschuh kleben rote Kerzenwachstropfen. Der linke liegt seit 19:30 Uhr in der Kamin-Nische.
> 5. [Lejla] hat dich erst nach dem Scheppern gespürt. Herr Schneider weiß nichts mehr nach „Hab ich dich!“.

**Dein Heft und die Wahrheit**, **wörtlich**: „Dein Heft sagt dir fast alles. In Stufe 2 erfindest du zwei Dinge: dass du dich geduckt hast und dass das Gesicht auf Herrn Schneider losging. Bleib dabei bis zur Anklage.“ (P2-25)

**Wenn es eng wird** (gilt, sobald der Fall eintritt), **wörtlich**:
> – Sobald jemand sagt, das leuchtende Gesicht sei vor dem Scheppern schon weg gewesen: „Kann sein. Im Dunkeln weiß doch keiner genau, was zuerst kam.“
> – Sobald jemand sagt, nach dem Gesicht sei noch jemand von der Klappe zu Herrn Schneider gekommen: „Das kann jeder gewesen sein. Ich hab mich am Eiskübel geduckt.“
> – Sobald die Indizkarte „Olli: Taschen und Kleidung“ (FN3) oder der Kerzenständer (XD3) offen liegt und deine Karte offen ist: „Kalk und Wachs hab ich von der Bogentür. Die roten Tropfen? Keine Ahnung. An den Kerzen hat das Gespenst mit Herrn Schneider gerungen, nicht ich.“
> – Sobald die Indizkarte „Vor der Theke am Ostende“ (PP9) offen liegt: „Ich hab um zwölf nur obenauf Eis genommen. Tiefer hab ich nicht gegriffen.“
> – Sobald jemand verlangt, dass du den Marker ‚Scheppern‘ wegen Kerzenständer und Handschuh umstellst: „Keine Karte sagt, wo ich beim Scheppern war. Der Marker bleibt.“

Der Satz zum Eiskübel ist wahr (WELT §3.4, W-19). Der Satz zum Marker ist wahr und durch R-06 gedeckt: Schlüsse aus mehreren
Karten verlangen kein Umstellen (P2-04). Die anderen drei sind erlaubte Ausflüchte (R-01); sie nennen keinen Namen (W-25). Die Ausrede zu den roten Tropfen lässt Olli den
Kerzenständer nicht berühren; sonst erklärte sie auch Splitter und Kalk am Fuß und entwertete XD3. Ist Ollis Karte noch zu, wenn
FN3 offen liegt, antwortet er mit seiner Stufe-1-Zeile zum Handschuh (RK 4.6, P2-17).

**Stufe 3: Wenn du angeklagt wirst** (**wörtlich**, Vorlesen, 67 Wörter):
> „Ja. Ich war es. Geduckt hab ich mich nicht. Als das leuchtende Gesicht weg war, bin ich über die Klappe zur Vorratsraumtür. Ich wollte nur reden. Herr Schneider hat mich am Ärmel gepackt: ‚Zweitausend. Sonst Polizei.‘ Im Dunkeln hat mich die Panik gepackt. Dann war da nur ein dumpfer Schlag und Poltern. Den Schlüsselbund hab ich unter die Eiswürfel im Eiskübel geschoben. Es tut mir so leid.“

Prüfung (REG §6.1, §9 Nr. 2): Geständnis ohne Schlag-Verb und ohne Waffe als Handlung; „Im Dunkeln hat mich die Panik gepackt“
(Kanon-Formel in Ich-Form); „Herr Schneider überlebt“ steht in Teil 90 (MECH §8.2); dass er zu sich kam, steht in „Was alle wissen“ (P145R2-K19).

### RK 7.6 YW4 – Can

**Dein Ziel heute Nacht**, **wörtlich**: „Du warst es nicht. Trotzdem hast du heute Nacht etwas zu verbergen. Du willst, dass niemand dich verdächtigt, und dein Streich mit der Maske soll nicht herauskommen.“

**Was wirklich geschah** (**wörtlich**):

| Zeit | Was geschah |
|---|---|
| am Nachmittag | Zu Hause bemalst du eine weiße Gespenstermaske mit grünlich-weißer Leuchtfarbe. Um Mitternacht soll die blinde Kuh sich gruseln. |
| 18:00 | Ihr kommt über die Sandsteinstufen und das Außentor. Am Jackenständer im Ost-Saal zahlst du Ahmet 150 € „Miete“, wie alle. |
| 20:15 | Olli steht im dunklen Vorratsraum vor der Mitternachtstorte: „Ich wollte nur aufs Klo!“ Alle lachen. |
| 23:30 | Dichter Qualm aus dem Kamin füllt den Kaminsaal. Alle husten, die Klappen der Lichtschächte werden aufgerissen. |
| 23:45 | [Zeynep] holt am linken Buffet Gebäck für euch beide. Ihr esst es an der langen Tafel im Kaminsaal. |
| 23:50 | Du sitzt mit [Zeynep] an der langen Tafel im Kaminsaal. An der Bogentür stehen Olli und [Tim]. Einer ruft: „Au! Mein Finger!“ |
| 23:54 | Mit der Maske gehst du durch den Steinbogen, den Durchgang und die Theken-Klappe hinter die Theke in den Vorratsraum. [Zeynep] stellt sich in den Steinbogen und steht Schmiere. |
| 23:54 | Im Buffetsaal tuscheln Fatma und [Emine] am linken Buffet. Fatma hält ihre Tasche ganz fest. Im Vorratsraum machst du das Licht aus. Die Maske leuchtet grünlich-weiß. |
| 23:57 | Du stellst dich im Dunkeln direkt hinter die angelehnte Tür. Draußen ruft Herr Schneider: „Nicht die alte Leiste!“ |
| 23:58 | Knall. Herr Schneider ruft: „Ruhe! Ich hol die Notlaterne.“ Du denkst, jetzt wird die blinde Kuh gebracht. Die Tür geht auf, und du springst heraus: „Buuuh!“ |
| 23:58 | Herr Schneider packt dich an der gelben Kapuze: „Hab ich dich!“ Ihr ringt im Kerzenlicht. Du reißt dich los und rennst hinter der Theke nach Westen. Er steht noch und brüllt: „Stehen bleiben!“ |
| 23:58 | Du rennst durch die Klappe und durch den Durchgang. Im Steinbogen streifst du [Zeynep]. Quer durch den Kaminsaal rennst du bis vor die Bogentür. |
| 23:58 | Vor der Bogentür stopfst du die Maske in die Bauchtasche deines Pullis. Das Leuchten ist weg. Im Dunkeln tastest du dich durch den Turmgang und die Wendeltreppe hinauf. |
| 23:58 | Du schließt dich auf der Turm-Toilette ein. Hier oben hörst du nichts mehr. Kein Rufen, kein Scheppern. |
| 0:00 | Das Licht geht an. Um 0:01 Uhr kommst du herunter. Du setzt dich im Kaminsaal auf die Wandbank. [Zeynep] kommt zu dir. |
| 0:03 | Unter dem Notausgangsschild hörst du: Das Tor ist zu, der Schlüsselbund ist weg. Ihr sitzt bis zum Morgen fest. Dir wird ganz kalt. |

Prüfung: Can hört den zweiten Ruf („Stehen bleiben, hab ich gesagt!“) nicht mehr, weil er schon im Kaminsaal ist (WELT §5.1).
Er nimmt an der Klappe niemanden wahr (WELT §5.7). Er hört das Scheppern nicht (RK-13).

**Was nur du weißt**, **wörtlich**:
> 1. Als du dich losgerissen hast, stand Herr Schneider noch und brüllte dir „Stehen bleiben!“ hinterher.
> 2. Das Scheppern hast du im Turm nicht gehört. Was nach deiner Flucht an der Theke geschah, weißt du nicht. Frag die anderen, was zuerst kam.
> 3. Um 23:54 Uhr tuschelten Fatma und [Emine] am linken Buffet. Fatma hielt ihre Tasche ganz fest.
> 4. [Zeynep] stand für dich im Steinbogen Schmiere. Du hast sie beim Rennen gestreift.
> 5. Die gelben Fasern an Herrn Schneiders Hand stammen von deiner Kapuze. An der Klappe hast du im Dunkeln niemanden bemerkt. Wer nach dir zu Herrn Schneider kam, hast du nicht gesehen.

**Dein Heft und die Wahrheit**, **wörtlich**: „Dein Heft sagt dir die Wahrheit. Was in Stufe 2 steht, ist genau das, was geschah. Mehr musst du nicht verbergen. Mit dem Scheppern hast du nichts zu tun.“ (P5-B3)

**Wenn es eng wird** (gilt, sobald der Fall eintritt), **wörtlich**:
> – Sobald jemand die gelben Fasern an Herrn Schneiders Hand gegen dich anführt (nur, wenn deine Karte offen ist): „Ja, das war meine Kapuze. Er hat mich gepackt, und ich hab mich losgerissen. Da stand er noch.“
> – Sobald jemand sagt, das Gespenst sei auf Herrn Schneider losgegangen: „Losgegangen? Ich bin rausgesprungen, ‚Buuuh!‘, mehr nicht. Er hat mich gepackt, nicht umgekehrt.“
> – Sobald jemand fragt, was nach deiner Flucht an der Theke war: „Keine Ahnung. Im Turm hört man nichts. Frag die, die im Durchgang waren.“
> – Sobald jemand fragt, wer dich rennen sah (nur, wenn deine Karte offen ist): „Im Steinbogen hab ich [Zeynep] gestreift. Frag sie.“
> – Sobald jemand verlangt, dass du deinen Marker ‚Scheppern‘ umstellst: „Ich war oben im Turm. Keine Karte sagt etwas anderes. Der Marker bleibt.“

**Stufe 3: Wenn du angeklagt wirst** (**wörtlich**, Vorlesen, 64 Wörter):
> „Ich? Nein. Ja, ich war das Gespenst, und der Streich war dumm. Herr Schneider hat mich gepackt, und ich hab mich losgerissen. Als ich weggerannt bin, stand er noch und hat mir hinterhergebrüllt. Was danach an der Theke war, hab ich oben im Turm nicht mal gehört. An der Vorratsraumtür war ich da nicht mehr. Den Schlüsselbund hab ich nie in der Hand gehabt.“

Nach jeder Stufe 3, für alle vier **wörtlich**: „Danach stellst du deine Marker dahin, wo du wirklich warst.“ Wirkung: Ahmet keine; Fatma
„23:57“ auf 4a, falls noch nicht; Olli „Scheppern“ auf 4c; Can „23:57“ auf 5, falls noch nicht.

### RK 7.7 Längenprüfung (Stand nach Integration Runde 2, nachgezählt mit `bibel/werkzeug-int2/zaehle2.py`; ursprünglich gezählt mit `bibel/werkzeug-rk/zaehle.py`, `bibel/werkzeug-rk/heft.py` und einer Zählung nur des gedruckten Texts; Namen in Klammern mitgezählt)

| Teil | Ahmet / WW4 | Fatma / JM3 | Olli / RN7 | Can / YW4 | Mittel | größte Abweichung |
|---|---|---|---|---|---|---|
| Fassung gesamt (Seiten 2–3, nur gedruckter Text) | 740 | 732 | 793 | 707 | 743 | RN7 +6,7 % |
| davon Zeitleiste (Zeilen) | 386 (16) | 364 (17) | 410 (16) | 354 (16) | 379 | RN7 +8,3 % |
| davon „Wenn es eng wird“ (fünf Sätze) | 127 | 134 | 143 | 126 | 133 | RN7 +7,9 % |
| davon „Dein Heft und die Wahrheit“ | 29 | 29 | 31 | 29 | 30 | RN7 +5,1 % |
| Stufe 3 | 64 | 61 | 67 | 64 | 64 | +4,7 % |
| Heft Seite 2 (Stufe 1 + „Wenn der Erzähler fragt“ + Stufe 2) | 487 | 517 | 522 | 488 | 504 | Olli +3,7 % |
| davon „Wenn der Erzähler fragt“ | 126 | 134 | 138 | 139 | 134 | Ahmet −6,1 % |
| Heft Gesprächsaufträge (Frage + Nachschlag) | 254 | 247 | 237 | 274 | 253 | Can +8,3 % |
| „Dein Auftritt“ | 70 | 70 | 78 | 67 | 71 | Olli +9,9 % |
| Geheimniskarte „Was ich zugebe“ | 59 | 57 | 55 | 57 (50 ohne Zeynep) | 57 | Can ohne Zeynep −12 % (Besetzungsvariante, zulässig) |
| Bonus-Ziel | 34 | 34 | 34 | 34 | 34 | 0 % |

Alle Teile liegen innerhalb von zehn Prozent um das Mittel (REG §6.11), bis auf Cans Karte in der Variante ohne Zeynep. Dort fehlt
ein Satz über eine nicht besetzte Rolle; das ist die Regel aus WELT §1.1, nicht ein Unterschied der Gestalt. Knapp unter der
Grenze liegt Ollis Auftritt (+9,9 %); RN7 liegt nach Runde 2 bei +6,7 % gesamt, die Zeitleiste bei +8,3 % und „Wenn es eng
wird“ bei +7,9 %. Die Text-Phase darf dort nichts verlängern. Heft Seite 2 wuchs in Runde 2 um die Zeile zu 23:51 (P2-21), bei
Olli dazu um die Handschuh-Zeile (P2-17); alle vier liegen im Budget 465–535. Ausweichziele
(nur gedruckt, wenn die Zielrolle fehlt) zählen nicht mit. Der Generator prüft die Längen erneut nach dem Satz.

---

## 18. Teileliste

### MECH 10.1 Teile mit Format und Umfang

Seitenzahlen A4, einseitig. P = Personen.

| Teil | Datei | Inhalt | Format, Verarbeitung | Seiten P = 6 / 12 / 20 |
|---|---|---|---|---|
| 00 | `00-erzaehlerheft.pdf` | Erzählerheft (9.1) | A4 hoch, lose oder geheftet | 15 / 16 / 17 |
| 01 | `01-detektivbogen.pdf` | Detektivbogen und Ermittlungsbogen (2.6) | A4 hoch | 6 / 6 / 6 |
| 02 | `02-tisch.pdf` | Lageplan (Blatt A und B), Positions-Marker, Tipp-Zettel, Abwesenheitsblatt (6–11 P.) | A4 quer (Lageplan), A4 hoch (Rest); schneiden, falten | 6 / 6 / 8 |
| 10 | `10-rollenhefte.pdf` | Rollenhefte der besetzten Rollen 1–10 | A4 hoch, je Rolle 4 Seiten, die vier Verdächtigen gleich lang und gleich gegliedert | 16 / 40 / 40 |
| 11 | `11-fassungen.pdf` | Versiegelte Fassungen WW4, JM3, RN7, YW4 | A4 hoch, je 4 Seiten, gleiche Gliederung und Länge, Außenseite nur Code; falten, zukleben | 16 / 16 / 16 |
| 12 | `12-zusatzrollen.pdf` | Zusatzhefte der besetzten Rollen 11–18 | A4 hoch, je Rolle 3 Seiten | 1 (Hinweisseite) / 1 / 24 |
| 20 | `20-karten.pdf` | Indizkarten (19), Geheimniskarten, Aktionskarten | Indizkarten und Geheimniskarten als A5-Feld hoch, 2 je A4, Z-Falz in drei Felder (Text innen); Aktionskarten A7, 8 je A4 | 17 / 17 / 22 |
| 90 | `90-aufloesung-versiegelt.pdf` | Auflösungsheft (8.4) | A4 hoch, falten, versiegeln | 9 / 10 / 12 |
| – | `kammerspiel-alles.pdf` | alle Teile in einer Datei | – | Summe |

Einzelheiten der Seitenzahlen:
- 02: Lageplan 2; Marker als flache Plättchen 26 × 18 mm, alle auf einem Blatt (höchstens 40); Tipp-Zettel (P − 1 Stück, 4 je Blatt);
  Abwesenheitsblatt 1 bei 6–11 Personen.
- 12: Bei 6 bis 12 Personen eine Hinweisseite, **wörtlich**: „Heute ohne Zusatzrollen. Zusatzrollen gibt es ab dreizehn Personen.“ (LÜ L-17, M-26).
- 20: Indizkarten 10 Blätter; Geheimniskarten für alle besetzten Rollen und alle fehlenden Zeugen 5–10 (bei 6–12 Personen
  immer 10, sonst R), 2 je Blatt; Aktionskarten ebenso (fehlende Zeugen mit Kopf „heute beim Detektiv“), 8 je Blatt.

### MECH 10.2 Lageplan und Marker (Maße, E15)

- **Blatt A, Lageplan:** A4 quer. Titel oben links, **wörtlich**: „Lageplan: Gewölbekeller unter dem Schlossturm“ (A:76, P5-K8). Maßstäblich nach Kanon-Raster (WELT §2.3, LÜ D-02): 1 m = 8,5 mm, Kellerfläche 25 × 22 m
  = 212 × 187 mm, links auf dem Blatt; hellgraues 1-m-Gitter. Rechts die Legende (etwa 70 mm breit).
  Eingezeichnet: Zonen 1–8 mit Namen wörtlich nach A:78-85 und Nummer im Kreis, Randfeld W, Teilfelder 4a–4d und 8a–8b,
  Türen und Steinbogen, alle Gegenstände aus WELT §2.1 als Symbol mit Namen, Legende „Eiskübel (vor dem Ostende)“ (W-02). In der Legende stehen außerdem die Hinweise
  „Offene Indizkarten an den Rand legen“ und „Zeitpunkte: Marker 23:57 / Marker Scheppern“ (P14-12).
  Keine roten Teilchen, kein Fundort-Kreuz in Rot, keine Flaschen (REG §6.12). Schwarzweiß-tauglich.
- **Blatt B, Markerfelder:** A4 quer, neben Blatt A gelegt. Raster aus 15 Zellen je 54 × 58 mm (5 × 3). Feld 1 Ost-Saal
  liegt über drei Zellen der oberen Reihe (162 × 58 mm, Platz für 18 Plättchen). Die übrigen zwölf Zellen sind die Felder
  2 bis W mit je Platz für sechs Plättchen (zwei Spalten, drei Reihen). Feldnamen wörtlich nach WELT §2.1 (P3-05):
  1 Ost-Saal · 2 Linkes Buffet · 3 Rechtes Buffet · 4a Theke Westende mit Theken-Klappe · 4b Vor der Theke mit Eiskübel ·
  4c Hinter der Theke: Anrichte, Vorratsraumtür · 4d Theke Ostende · 5 Vorratsraum · 6 Durchgang mit Steinbogen · 7 Kaminsaal ·
  8a Turmgang · 8b Wendeltreppe und Turm-Toilette · W Windfang. Jedes Feld zeigt die Nummer, den Namen und eine Mini-Skizze der
  Lage. Höchste Belegung: Feld 1 mit 15 Markern bei 20 Personen, Feld 4d mit 6 (P14-12). Die Felder 2, 3, 4d und 6 liegen am Rand von
  Blatt B, Feld 1 oben. In die drei inneren Zellen der mittleren Reihe kommen 4a, 4b und 4c. So ist neben jedem Feld, an das
  ein Zeugenstreifen kommen kann, Platz (P145R2-K05).
- **Positions-Marker:** flache Plättchen 26 × 18 mm, nicht gefaltet (P14-12). Jedes trägt Name, Platz-Nummer und „23:57“
  oder „Scheppern“. Zwei je Rolle, zwei für den Detektiv, zwei für Herrn Schneider. Für
  fehlende Rollen keine Marker (LÜ D-15). Farbe nur als Grauton-Streifen; der Name entscheidet (LÜ L-18).
- Grund für zwei Blätter (A Plan, B Felder) statt eines über zwei Blätter gezogenen Plans: Kein Plan über eine Klebekante,
  und die Plättchen haben Platz: Feld 1 für 18, jedes andere Feld für 6 (M-27, P14-12).

### MECH 10.3 Was je Person in „Rollenheft einzeln senden“ gehört

| Empfänger | Inhalt der Datei | nicht enthalten |
|---|---|---|
| jede besetzte Rolle 1–10 | ihr Rollenheft (Teil 10, 4 Seiten) und eine Abbildung ihrer Aktionskarte | Geheimniskarte (liegt am Tisch; ihr Inhalt steht als Stufe 2 im Heft), Fassung (bleibt versiegelt im Satz), Marker, Tipp-Zettel |
| jede besetzte Rolle 11–18 | ihr Zusatzheft (Teil 12, 3 Seiten) und eine Abbildung ihrer Aktionskarte | dto. |
| Detektiv | Teil 01 ganz | Aktionskarten fehlender Zeugen (liegen am Tisch) |
| Erzähler | Teil 00 ganz | Teil 90 |

Dateiname wie bisher je Person mit Figurennamen (A-059): `10-rollenheft-<figur>.pdf`, `12-zusatzheft-<figur>.pdf`.
Teil 90 wird nie einzeln gesendet.

### MECH 10.4 Rollenheft gegen Fassung bei den vier Verdächtigen (LÜ L-08)

| Rollenheft (vorab sendbar, gleiche Gestalt, 4 Seiten) | Fassung (versiegelt, gleiche Gestalt, 4 Seiten) |
|---|---|
| S. 1 Dein Auftritt, Wer du bist, Was alle wissen | S. 1 Außenseite: Code, „Versiegelt. Erst öffnen, wenn der Erzähler es sagt.“ |
| S. 2 Deine Marker (Stufe 1), Stufe 1 mit Ausweichsätzen, „Wenn der Erzähler fragt“ (RK §1.8), Stufe 2 mit Pflicht-Auslösern, was du dann sagst, Domino-Hinweis | S. 2 Was wirklich geschah: deine Zeitleiste 18:00 bis 0:15 (bei RN7 mit der Tat, regelkonform) |
| S. 3 Gesprächsaufträge Runde 1–3 (je zwei Nachbohr-Ziele, Ausweichziel) | S. 3 Was nur du weißt (bei RN7: dass er Can fliehen sah und Stufe 2 bewusst verdreht); Stufe 3: Wenn du angeklagt wirst |
| S. 4 Was du bei dir trägst, Aktionskarte, Bonus-Ziel, Notizen | S. 4 Notizen |

Regel: Das Rollenheft enthält nichts, woraus man Ollis Tat lesen kann. Ollis Stufe-2-Satz („geduckt“) steht dort ohne
Hinweis, dass er gelogen ist. Alle vier Hefte enden Stufe 2 mit demselben Schlusssatz (RK §8.2, P5-B3). Gleiche Überschriften, gleiche Länge (Toleranz zehn Prozent der Wörter) für alle vier Hefte
und alle vier Fassungen (E9, REG §6.11). Die Fassung wird nach dem Tat-Moment geöffnet (9.6). Wer will, gibt sie vorab
versiegelt mit; geöffnet wird trotzdem erst am Tisch.

### MECH 10.5 Vorbereitung (für die Seite 2 im Erzählerheft)

| Teil | Tätigkeit | Dauer |
|---|---|---|
| alle | einseitig drucken, nichts lesen; Teile 02 und 20 auf festeres Papier (ab 120 g), damit nichts durchscheint; am besten schneidet und faltet jemand, der heute nicht mitspielt (9.1, P145R2-K06) | – |
| 02 | Blatt A und B nicht schneiden; Marker-Plättchen ausschneiden; Tipp-Zettel ausschneiden; Abwesenheitsblatt in Streifen schneiden und falten | 15 min |
| 11 | jede Fassung falten und zukleben | 5 min |
| 20 | Indiz- und Geheimniskarten ausschneiden und sofort im Z-Falz zufalten (Text innen), Indizkarten nach Code stapeln; Aktionskarten ausschneiden | 25 min |
| 90 | falten und versiegeln | 2 min |

---

## 19. Entscheidungsprotokoll

### 19.1 Entscheidungen der Integration, Runde 1

| Nr | Entscheidung | Grund in einem Satz |
|---|---|---|
| I-01 | Gliederung nach dem Auftrag, Unterabschnitte mit Kennung und alter Nummer statt Neunummerierung (0.2) | Hunderte Verweise zwischen den Teilen bleiben ohne Umschreiben gültig |
| I-02 | Selbstprüfungen und Protokoll-Abschnitte der Teilentwürfe nicht übernommen (19.3) | Sie beschrieben den Stand vor den Testbefunden und hätten der Bibel widersprochen; die Prüfung läuft über `tests/` und `TESTPROTOKOLL.md` |
| I-03 | Schlüsselbeweis: Teil 01 nennt Teil 2 nicht mehr; FN3 trägt keinen Vermerk „Schlüsselbeweis“; Teil 2 kreuzt der Detektiv selbst an (MECH 2.1, 2.2, 2.4, 3.3, 6.1; RK 6.9) | P2-01, P2-02, P5-B1, P5-B2: sonst fällt der Fall in Runde 1 oder 2 |
| I-04 | Gleiche Titel „[Name]: Taschen und Kleidung“ für FN3, NN3, JT3; PP9 heißt „Vor der Theke am Ostende“; VP7 rückt in Runde 3 | P2-01, P2-07: Liste und Titel verraten weder Schlüsselbeweis noch Fundort |
| I-05 | VP7 behält den Titel „Kamin-Nische“; der Vorschlag „Kamin-Nische und Ascheneimer“ wird nicht übernommen | WM9 heißt schon „Ascheneimer am Kamin“; zwei Karten mit „Ascheneimer“ im Titel würden den Detektiv verwirren |
| I-06 | Runde 3: erst Tipp-Runde, dann die letzten drei Untersuchungen, dann Anklage; der Detektiv legt den Stift mit der Anklage weg (MECH 1.3, R-12) | P2-03: Tipps sollen nicht geschenkt sein; A:105 und A:115 bleiben erfüllt |
| I-07 | Alle Bonus-Ziele werden nach dem Stand bei der Anklage geprüft (MECH 7.3) | Folge von I-06: Serkans (PP9) und Tugbas (XD3) Ziele wären sonst unerfüllbar; ein Stichtag für alle |
| I-08 | Bonus-Ziel der Verdächtigen nur für freiwilliges Umdrehen vor dem ersten eigenen Sobald-Fall; RK-17 entfällt | P14-07: das alte Ziel erfüllte sich fast von selbst |
| I-09 | Etikett der Zeugenstreifen ohne Freigabe-Codes, mit Rollenbezeichnung; Codes nur in der Erzählertabelle MECH 9.14 mit den Umschreibungen der Hefte | P14-05, P14-06, P2-09, P14-K02, P14-K13 |
| I-10 | Streifenformat 100 × 95 mm, Falz 30 mm unter der Oberkante, keine Schlusszeile | P14-02 |
| I-11 | Marker als flache Plättchen; Feld 1 Ost-Saal über drei statt vier Zellen | P14-12 schlug vier Zellen vor; dann bräuchte Blatt B 16 Zellen bei 15 vorhandenen. Drei Zellen fassen 18 Plättchen, der Ost-Saal braucht höchstens 15 |
| I-12 | Geheimnis- und Indizkarten im Z-Falz (Text innen); der Spielbegriff „umdrehen“ bleibt und heißt „wenden und aufklappen“ (MECH 0.2, 4.1) | P5-M6; der Begriff steht in allen Heften und Regeln, ein Wechsel zu „aufklappen“ brächte nur neue Brüche |
| I-13 | Verhörstuhl zwei Minuten; ab 12 Personen laufen die Gespräche leise weiter; Ruf „Karte!“ ab 12 (seit Runde 2 bei jeder Personenzahl, I-25); Gegenüberstellung ab 14 in Runde 2 und 3; „vor allen“ als R-13 | P14-03, P14-04, P14-15, P2-10 |
| I-14 | Tabelle „Wenn der Erzähler fragt“ für die vier Verdächtigen (RK 1.8), Fatma mit zwei Fassungen je nach Marker | P14-08; gleiche Gestalt: acht Zeilen, 126 bis 138 Wörter |
| I-15 | Ausweichziele an den Detektiv haben einen zweiten Satz an eine Verdächtige oder einen Verdächtigen; die beiden Runde-3-Ausweichziele von Olli und Can beginnen mit der Frage | P14-14; A:90 verlangt echte Gespräche |
| I-16 | „Wenn es eng wird“ hat in allen vier Fassungen fünf Sätze; der fünfte betrifft den Marker „Scheppern“ | P2-04 nannte nur RN7; E9 verlangt gleiche Gestalt |
| I-17 | Eine Schutzkarten-Grenze für alle vier (27 Wörter) | P2-08 und P5-K4 zusammengeführt |
| I-18 | Emines Domino-Hinweis nach P3-11, nicht nach P2-06 | Der Satz aus P2-06 („nicht nur Fatma gedroht“) wäre eine Vermutung auf einer Karte |
| I-19 | Neue Zeugen-Domino-Hinweise drücken auf Olli, Can und Tim; die alten Ahmet-Sätze stehen unter „Nach dem Umdrehen“ | P2-06 |
| I-20 | Wortlaute aus P14-09 angepasst: Damirs und Serkans Sätze als Wenn-Sätze, Wojteks und Aylins Fragen ohne Wissen, das sie nicht haben | ZG-01 (nichts Unwahres); Wojtek weiß nicht, wann Hana anfeuerte, Aylin hört die Innentür im Ost-Saal nicht |
| I-21 | Handys schon um 23:00 im Korb (K-23); Skizzenblock statt Strickjacke (K-24) | P3-02, P3-21 |
| I-22 | Teilfeldnamen einheitlich nach WELT 2.1; Cans Scheppern-Marker 8b | P3-05 |
| I-23 | Zeugenhefte: Aufbau, „Wer du bist“ und Markerzeilen wörtlich (ZG 0.6); Wissen-Tabellen werden gedruckt, mit Platzhaltern | P14-17 und P5-M4; die Druckvariante aus P5-M4 ist dieselbe Lösung wie bei den Zusatzheften (ZR 0.7) |
| I-24 | Teil-90-Kernsatz „Was wirklich war“ nennt Ollis Ärmel und Handschuh | P5-K6; Teil 1 beschreibt die Spur am Ärmel, A:112 nennt den Handschuh |

### 19.2 Offene Punkte (Stand nach Integration Runde 2)

Bewusst nicht oder nur teilweise behoben; keiner blockiert die Text-Phase.

1. **Erzähler beim Schneiden (P5-M6, teilweise):** Der Z-Falz, das graue Raster auf Feld 3 und festeres Papier (P145R2-K06)
   schützen nach dem Falten. Beim Schneiden ist der Text sichtbar. Das Erzählerheft empfiehlt deshalb, dass jemand schneidet,
   der nicht mitspielt. Ganz verhindern lässt es sich im Druck nicht.
2. **Eingehende Ziele der Zusatzrollen (P14-09, P145R2-M05, P145R2-K20):** Sibel fragt ab 14 Personen Damir. Hana fragt ab 15
   Personen der Detektiv (RK 6.12), ab 16 Serkan und ab 18 Wojtek vor allen. Serkan fragen der Detektiv ab 16 und Azra ab 17.
   Damir fragt Serkan ab 16, Wojtek fragt Aylin ab 19. Nur Tugba bleibt ohne eingehendes Ziel, weil Ziele nur kleinere Plätze
   nennen (ZG-09) und sie den größten Platz hat. Sie hat je Runde zwei eigene Ziele und ihre Aktionskarte.
3. **Gesprächslast bei 14 bis 20 Personen (P14-04, P145R2-M02):** Die Gegenüberstellung ist mit genau einer Frage je Person
   nachgerechnet (MECH 1.3). Ob Frage und Antwort in zwanzig Sekunden passen, zeigt erst ein Probelauf mit 20 Personen.
4. **Seitenumfänge** (MECH 10.1) sind Schätzungen. Der Generator prüft Überlauf bei 9 pt; nur Joannas Notiz darf 8 pt haben.
   Das Zusatzheft hat jetzt drei Seiten (P145R2-M06). Seite 7 des Erzählerhefts trägt jetzt auch „Was alle wissen“
   (P145R2-M09); läuft sie über, bekommt das Erzählerheft eine Seite mehr.
5. **Erzählertabelle 9.14:** Sie zeigt nur Codes. Ein aufmerksamer Erzähler kann aus vorgelesenen Karten auf Zusammenhänge
   schließen (P14-05, vom Test so angenommen).
6. **Längen knapp unter zehn Prozent:** Ollis Auftritt (+9,9 %); RN7 nach Runde 2 bei +6,7 % gesamt, Zeitleiste +8,3 %,
   „Wenn es eng wird“ +7,9 % (RK 7.7). Die Text-Phase darf dort nicht verlängern.
7. **Ahmets Taschenkontrolle** öffnet keine Indizkarte; die Gleichheit der vier liegt in der Zahl der Wege (RK-Entwurf, offener
   Punkt 6), nicht in der Karte.
8. **Zeitleiste in Teil 90** (MECH 8.3): Zusatzrollen stehen dort nur, wenn gespielt; den Wortlaut der gekürzten Zeitleiste setzt
   die Text-Phase.
9. **Abweichungen vom Auftrag** (MECH 12a) und vom App-Kanon (WELT 0.3, K-01 bis K-25) sind zur Kenntnis des Besitzers
   gesammelt; besonders A:96 (Olli gesteht bei jedem Beweisstand), A:115 (Tipps vor den letzten Untersuchungen) und neu A:92
   (Emines Hinweis nennt niemanden, P145R2-K15).
10. **Nachprüfung:** Die Testprotokolle der Runde 3 prüfen diese Fassung als Ganzes.
11. **„Wer du bist“ der Zusatzhefte (P145R2-K18, teilweise):** ZR 0.7 gibt Muster und Beispiel (Sibel). Den Wortlaut der übrigen
    sieben setzt der Generator aus dem Profil x.1; die Text-Phase prüft ihn gegen das Muster.
12. **Bonus-Ziele mit Reihenfolge (P145R2-M07):** Azra, Wojtek und Aylin prüft Teil 90 über Nummer und Runde der Vermerke-Liste.
    Das setzt voraus, dass der Detektiv jeden Vermerk mit Nummer und Runde einträgt (RK 6.7 Nr. 5). Tugbas Ziel kann auch das
    Vorlesen von XD3 erfüllen (R-13); das liegt meist nach der Tipp-Runde. Gewollt ist, dass sie Marek fragt.
13. **Olli in Runde 2 (P2-17):** Liegt FN3 schon in Runde 2 offen, ist Olli früher Hauptverdächtiger (MECH 3.5 Nr. 2). Überführt
    wird er erst in Runde 3; Cans Alibi kommt erst in Runde 3. FN3 nach Runde 3 zu schieben, verstieße gegen E9 (Taschenkontrolle
    ungleich) und wurde nicht übernommen.

Verbleib der offenen Punkte der Teilentwürfe: MECH 13.2 Nr. 1, 2, 5 erledigt, Nr. 3 hier Punkt 4, Nr. 4 in MECH 12a. RK-Entwurf
Nr. 1 in MECH 4.2 (Variante ohne Emine), Nr. 2 in WELT 5.8, Nr. 3 in MECH 2.6 (sechs Seiten), Nr. 4 in MECH 9.4 (Fragen aus
RK, ZG, ZR x.3), Nr. 5 in ZG 1 bis 6 erledigt, Nr. 6 hier Punkt 7, Nr. 7 durch P14-07, Nr. 8 in MECH 12a, Nr. 9 in WELT 0.2.
ZG-Entwurf Nr. 1 und 2 erledigt (RK 1.8, ZR 0.6), Nr. 3 durch P14-02, Nr. 4 gewollt (MECH 9.9). ZR-Entwurf Nr. 1 durch P2-13,
Nr. 2 durch P14-K08, Nr. 3 durch P14-10, Nr. 4 in MECH 3.3 (WJ9), Nr. 5 durch P14-11, Nr. 6 hier Punkt 4, Nr. 7 durch P14-K04,
Nr. 8 durch P14-K17.

### 19.3 Nicht übernommene Abschnitte der Teilentwürfe

| Abschnitt | Inhalt | Verbleib |
|---|---|---|
| Kopf der fünf Dateien | Stand, Grundlage, Schreibweise | Kopf dieser Datei, 0.1, Einleitung von Kapitel 15 |
| WELT 0.1, MECH 0.1, RK 0.1 | Rang und Kürzel | 0.1 |
| RK 0.2 | Was die Datei liefert | 0.2 und Konkordanz |
| WELT 8.4 | Selbstprüfung der Welt | ersetzt durch `tests/P3-runde1.md` und TESTPROTOKOLL.md |
| MECH 13 | Selbstprüfung und offene Punkte | 19.2 |
| RK 8.3 bis 8.6 | Protokolle 1–3 und Regelprüfung (Stand vor den Tests) | ersetzt durch `tests/` und TESTPROTOKOLL.md |
| RK 10 | Offene Punkte | 19.2 |
| ZG 8, 9, 10 | Protokolle 1–3 (Stand vor den Tests) | ersetzt durch `tests/` |
| ZG 12 | Offene Punkte | 19.2 |
| ZR 10, 11, 12 | Protokolle 1–3 (Stand vor den Tests) | ersetzt durch `tests/` |
| ZR 15 | Offene Punkte | 19.2 |

### 19.4 Entscheidungen der Integration, Runde 2

| Nr | Entscheidung | Grund in einem Satz |
|---|---|---|
| I-25 | „Vor allen“ heißt: Der ganze Tisch hört zu (R-13). Dazu zählen Ortstermin, Impuls-Antworten und das Vorlesen einer Karte; der Verhörstuhl nur, solange die anderen Gespräche ruhen. „Karte!“ ruft man bei jeder Personenzahl (R-03) | P2-16 und P145R2-M01 zusammengeführt; der Erzähler muss nie über die Schwelle eines Auslösers entscheiden |
| I-26 | Neue Tischregel R-14 „Dazu sag ich jetzt nichts.“ | P145R2-M04 deckt P2-20 mit; eine Regel statt Ausweichsätze in jedem Heft |
| I-27 | Ollis Gang zum Eiskübel heißt in Spielertexten „um 23:57 Uhr“; Joannas Zeile wird nicht in 23:56 und 23:57 geteilt | P3R2-04 statt P2-26: A:41 (Rang 1) nennt 23:57; beide Befunde wollten 23:56 für Ahmet loswerden |
| I-28 | Feld 4b reicht von der Mitte bis vor das Ostende, nicht bis zum Westende | P3R2-17 schlug den ganzen Streifen vor; der Platz vor dem Westende gehört nach WELT 2.1 zu 4a (Ollis Warteplatz) |
| I-29 | FN3 ohne „frische“; „Wenn es eng wird“ gilt, sobald der Fall eintritt; Ollis Tropfen-Satz nur bei offener Karte, sonst seine Stufe-1-Zeile zum Handschuh | P2-17; ohne die Bedingung hätte Olli in Runde 2 eine falsche Antwort, mit ihr bleibt RN7 unter zehn Prozent |
| I-30 | Ortskarten nennen den Platz, an dem kein Schlüsselbund liegt; AD3 auch | P2-18, P145R2-K02; AD3 aus Gleichheit dazu |
| I-31 | Zeitstempel: „Herr Schneider zählt als niemand“; neue Stufe-1-Zeile „Wo warst du um 23:51 Uhr?“ bei allen vier | P2-21; der Erzähler spricht Herrn Schneider nur nach R-10 |
| I-32 | Gegenüberstellung: genau eine Frage je Person, Frage und Antwort zusammen zwanzig Sekunden, ab 18 Personen sieben Minuten | P145R2-M02, nachgerechnet |
| I-33 | Ganzer-Tisch-Ziele des Detektivs in Runde 2 und 3 laufen über Impulse | P145R2-M03 |
| I-34 | Hanas Auslöser 3 „vor allen“ statt „zweimal“; neue Ziele auf Serkan (Azra, Detektiv), Damir (Serkan), Wojtek (Aylin) | P145R2-M05, P145R2-K20; Tugba bleibt ohne eingehendes Ziel (ZG-09) |
| I-35 | Zusatzheft drei Seiten | P145R2-M06 |
| I-36 | Fünf Bonus-Ziele neu (Tim, Azra, Wojtek, Aylin, Tugba); Regel „Kein Bonus-Ziel erfüllt sich ohne Zutun schon in Runde 1 oder 2“ | P145R2-M07 |
| I-37 | M4 nur mit Stichwort zum Schwindel; WE3 nur „Hinweis“ | P145R2-M08; das Einsammeln steht in „Was alle wissen“ |
| I-38 | „Was alle wissen“ auch im Erzählerheft; Rundenstart 1 ohne den Theke-Satz (K-25) | P145R2-M09, P145R2-M10 |
| I-39 | „Was du bei dir trägst“ in allen 18 Heften in der Ich-Form | P145R2-K09; der Test nannte nur das Beispiel Ahmet, der Generator braucht eine Form |
| I-40 | Emines Domino-Hinweis bleibt; Abweichung von A:92 in MECH 12a | P145R2-K15: Die Welt gibt Emine keine neue Beobachtung über Rollen 1–5 (WELT 5.5); erfinden ist verboten |
| I-41 | „Wer du bist“ der Zusatzhefte als Muster mit Beispiel; Teil 01 Seite 6 trägt die Aktionskarten fehlender Zeugen; Teil 90 ab 15 Personen eine Seite mehr | P145R2-K18, P145R2-K13 |

### MECH 12a Abweichungen vom Auftrag (Mechanik), zur Kenntnis des Besitzers (P5-M7)

Die Welt weicht in WELT §0.3 (K-01 bis K-25) vom App-Kanon ab. Diese Liste nennt, wo die Mechanik bewusst vom Wortlaut des
Auftrags abweicht, mit Grund.

| Auftrag | Wortlaut im Auftrag (Kern) | Kammerspiel | Grund |
|---|---|---|---|
| A:30 | Beispielimpuls nennt Fatma, Emine, Zeynep | Impulse fragen alle vier oder alle am Tisch | Erzähler bleibt spoilerfrei (M-25, E10) |
| A:57 | Abwesenheitsblatt bei 6 bis 9 Spielern | bei 6 bis 11 Personen, sobald eine Rolle 5–10 fehlt | E6, E7: Personen = Rollen + Detektiv + Erzähler |
| A:58 | Variante Erzähler = Detektiv | entfällt | E6, ABG D-21 |
| A:61 | Scherben „unter den Teppich“ | unter den Sockel der Rüstung; „Teppich“ nur als Wortspiel | Kanon-Keller hat keinen Teppich |
| A:62 | Überraschungstorte im Auto | nur Wunderkerzen | Die Torte steht im Vorratsraum (Kanon) |
| A:64 | Tugba führt Buch, sieht den Handschuh | Tugba ganz unbelastet, harmlose Dankeskarte | Kopftuch-Regel (E11, W-17) |
| A:73 | Platzwunde | „bewusstlos, mit einer dicken Beule“ | E4, Ton-Leitfaden |
| A:76 | Doppelseite Lageplan | Blatt A (Plan) und Blatt B (Markerfelder), beide A4 quer | M-27, P14-12 |
| A:81 | Eiskübel beim Westende | Eiskübel vor dem Ostende | W-02 (A:50 und A:95 verlangen es) |
| A:93, A:96 | nur Olli hat drei Stufen; Stufe 3 erst bei XD3 + FN3 + PP9 | alle vier haben Stufe 3 gleicher Gestalt; Olli gesteht bei der Anklage bei jedem Beweisstand | E9 gleiche Gestalt; RK-14 |
| A:95 | „das leuchtende Gespenst (Can)“ | Olli sagt nur „das Gespenst“, nie Cans Namen | W-25 |
| A:101 | Auslöser auf der Vorderseite der Geheimniskarte | Auslöser nur im Heft; bei fehlenden Zeugen nur in der Erzählertabelle 9.14 | E8, P14-05 |
| A:102 | „Taschen-/Gegenstands-Check“, „Veto/Ablenkung durch Olli“ | Karte „Taschenkontrolle“; Ollis Karte heißt neutral „Themenwechsel“ | deutsche Begriffe (E5, P5-M1); E9 |
| A:106 | Can-Alibi „offiziell“ über Marek/Tim | Vermerke „für das leuchtende Gesicht“; der Detektiv verbindet über JT3 oder Cans Karte | Tim und Marek erkennen das Gesicht nicht (M-11) |
| A:107 | „Schlüsselbeweis: Der Täter hat kurz zuvor Holzarbeiten an einer gekalkten Wand verrichtet.“ | „Wer den Kerzenständer am Fuß hielt, hatte beides am Ärmel. Teil 2 ist die passende Spur an einer Person.“ | kein „Täter“ auf Karten; kein Vorab-Hinweis auf Teil 2 (P2-01, P2-02) |
| A:115 | Tipp-Runde vor der Anklage | Tipp-Runde in Runde 3 vor den letzten drei Untersuchungen, dann Anklage | Tipps sollen nicht geschenkt sein (P2-03) |
| A:116 | Tipp-Zettel für alle Mitspieler | kein Zettel für den Detektiv; seine Anklage ist sein Tipp | M-21 |
| A:118 | „Wer hat Herrn Schneider niedergeschlagen?“ | „Wer steckt hinter dem dumpfen Schlag im Dunkeln?“ | kein Schlag-Verb (REG §9 Nr. 3) |
| A:120 | „bis seine Unschuld am Überfall feststand“ | „bis feststeht, dass er es nicht war“ | REG §9 Nr. 4 |
| A:29, A:75 | „Evidence Board“, „Trigger“, „Ping-Pong“ | „Lageplan“, Sätze mit „Sobald“, „Vorstellungsrunde“ | E5 |
| A:44 | Lejla sah Herrn Schneiders Quittungszettel „Miete Schlosskeller: 0 Euro“ | Lejla sah am Nachmittag auf dem Klemmbrett das Belegungsblatt „Saalmiete Schlosskeller: 0 Euro“; den Quittungszettel hat Aylin | ABG D-11, W-10 (P145R2-K14) |
| A:52 | „150 € Nachzahlung“ | 150 € pro zahlendem Gast, zusammen 2.550 € | W-12: nur so passt die Nachzahlung zum Mietgeld (P145R2-K14) |
| A:52 | Marek sieht „an der Schwelle zum Durchgang“ das Gesicht „an ihm vorbei“ rennen | Marek steht am Ostende hinter der Theke und sieht im Kerzenlicht aus gut drei Metern das Gesicht herausspringen und zur Klappe verschwinden | A:52 nennt zwei Orte acht Meter auseinander; Ahmets Alibi braucht Marek am Ostende (W-06, ABG §3.6; P3R2-22) |
| A:54 | Zeynep hört, dass „noch jemand mit Herrn Schneider stritt“ | Zeynep hört nur Herrn Schneiders zweiten Ruf | Das Gespräch an der Tür ist leise und acht Meter entfernt, ohne Sicht (WELT §5.3; P3R2-22) |
| A:87 | Marker nach geknackter Lüge auf den wahren Ort | Ollis Marker „Scheppern“ bleibt nach Stufe 2 auf dem Eiskübel bis zur Anklage | R-06: Schlüsse aus mehreren Karten verlangen kein Umstellen (P2-04, P145R2-K14) |
| A:92 | Jeder Domino-Hinweis setzt eine andere Rolle unter Druck | Emines Hinweis nennt niemanden | I-18, I-40; WELT §5.5: Emine schaut nur auf Fatma (P145R2-K14, P145R2-K15) |

### WELT 8.1 Designer-Entscheidungen dieser Datei

| Nr | Entscheidung | Grund in einem Satz |
|---|---|---|
| W-01 | Fester Weltbestand: 18 Gäste, Herr Schneider, Detektiv; Baran und Pawel gibt es nicht | Fakten bleiben bei jeder Personenzahl gleich (LÜ L-05) |
| W-02 | Eiskübel vor dem Ostende | A:50 und A:95 verlangen es, das Versteck bleibt unhörbar (2.4) |
| W-03 | Sicherungskasten an der Nordwand des Durchgangs neben den Getränkekisten | A:83; Tim hört dort das Scheppern und trägt Cans Alibi (2.5) |
| W-04 | Der Steinbogen zählt zu Zone 6; Zeynep steht darin am Nordpfeiler | erfüllt A:54, ohne jemanden mitten in den 2-m-Gang zu stellen (L-07) |
| W-05 | Scheppern 23:58:30, neuer Sekundentakt | A:73, A:130; Cans Alibi bleibt wahr (3.1) |
| W-06 | Marek steht hinter der Theke am Ostende an den Saftkrügen; Variante 4b | löst Mareks Doppelort; trägt den Gedanken aus A:54 mit einem Zeugen, der sehen kann |
| W-07 | Schneiders Einzeldrohungen 23:51, 23:56, 23:57 sind leise | A:46 nennt nur Emine als Hörerin; bremst das Domino (D-35, D-36) |
| W-08 | Joanna behält als Fotografin ihr Handy; Notiz mit Zeitstempel 23:57; Standort in der Tür | A:50 wörtlich („Handy-Notizblock“); der Zeitstempel ist ein harter Beleg |
| W-09 | Damir kommt 23:57:30 ans Ostende und kauert neben Ahmet | zweiter Zeuge für Ahmets Alibi, ohne Joannas Liste zu ändern |
| W-10 | Lejla ab 23:55:30 am rechten Buffettisch; Belegungsblatt am Nachmittag | A:44; der Zettel von 22:30 bleibt Aylins |
| W-11 | Tim leiht Wojteks Werkzeugkasten 18:00 | löst den Widerspruch A:48 gegen A:63 (ABG D-14) |
| W-12 | Nachzahlung = 150 € pro zahlendem Gast = 2.550 € = Mietgeld | A:39 und A:52 stimmen wörtlich; Ahmet hat ein echtes Motiv |
| W-13 | 20:15: Azras falscher Alarm und Wojteks Lampe gehören zu Ollis Lacher | kein zweites Ereignis neben dem festen Lacher (ABG D-15) |
| W-14 | Zeynep 23:45 am linken Buffet | einfachster Ort mit Sicht auf die Tasche (ABG D-12) |
| W-15 | 0:12 sieht nur Azra Ahmet | A:63; Hana ist dann im Buffetsaal |
| W-16 | Tandem-Intrigen wie in 7.3 | Auftrag A:61-64, Kanon-Geheimnisse wo vorhanden |
| W-17 | Tugba ohne Nebendelikt, Lüge oder verborgenes Wissen; ihre Überraschung ist harmlos | Kopftuch-Regel (E11) |
| W-18 | Herr Schneider spricht nicht über Geldsachen der Gäste | sonst löst das Opfer den Fall; passt zu seiner Diskretion |
| W-19 | Nach dem Licht greift nur Olli (obenauf) in den Eiskübel; Kühlpack aus dem Erste-Hilfe-Kasten | sonst fände jemand den Bund vor der Untersuchung |
| W-20 | Olli geht bei Licht sofort zum Eiskübel; seine Stufe 1 deckt das Eisholen | sonst widerlegt der ganze Saal Stufe 1 um 0:00:05 |
| W-21 | Joannas Liste nennt nur Rollen 1–10 und Herrn Schneider | fester Wortlaut bei jeder Personenzahl |
| W-22 | Im Ost-Saal achtet niemand darauf, dass Olli 23:56:30 hinausgeht (außer Joanna in der Tür) | Tempo; alle schauen auf die blinde Kuh |
| W-23 | Lichtregel: kein Licht an Tür, Klappe, Eiskübel oder Ollis Weg von 23:58:30 bis 23:58:54 | Versteck bleibt unbeobachtet (ABG D-10) |
| W-24 | Can sah 23:54 Fatma und Emine tuscheln | gibt Can einen Domino-Hinweis gleicher Gestalt wie den anderen |
| W-25 | Olli nennt in Stufe 2 „das Gespenst“, nicht Can | er bleibt liebenswert und lügt nicht über einen Namen |
| W-26 | Damir begleitet Sibel um 21:00 | gibt dem Tandem einen gemeinsamen Moment (A:61) |
| W-27 | Um 23:00 sitzen fast alle im Ost-Saal bei Tugbas Ratespiel; nur Tim hört den Streit an der Theke | Ollis Heimlichtuerei bleibt bis Stufe 2 verdeckt (ABG D-36) |

### WELT 8.2 Abgleich-Vorschläge D-01 bis D-44 (abgleich.md §4.1)

| Nr | Thema | Entscheidung |
|---|---|---|
| D-01 | Umbesetzungen | übernommen, eigene Druckquelle; Liste 0.3. Damir und Azra behalten Tandem-Aufgaben |
| D-02 | Eiskübel | Ostende, vor der Theke; Ahmet, Damir, Marek hinter der Theke 1,9–2,2 m (W-02) |
| D-03 | Mareks Doppelort | hinter der Theke am Ostende, steht; sieht die Flucht im Kerzenlicht; Variante 4b (W-06) |
| D-04 | Tim hört das Scheppern nicht | Sicherungskasten im Durchgang (W-03) |
| D-05 | Zeynep hört nichts | im Steinbogen (Zone 6, W-04); Satz wie 5.3, nichts Leises, nie „Zweitausend“ |
| D-06 | 30 statt 40 s | Takt 3.4; Sekunden nur in Teil 90 |
| D-07 | Ort des Schlags | vor der Vorratsraumtür hinter der Theke; Olli über die Klappe, weil am Ostende Ahmet, Damir, Marek sind |
| D-08 | Saft am Ostende | Saftkrüge, Gläser, Servietten auf der Anrichte Ost; Getränkekisten im Durchgang |
| D-09 | Joannas Liste | Handy-Notiz mit Zeitstempel statt Papier (W-08, Abweichung vom Vorschlag wegen A:50); Tür 23:55:40–23:57:30; Wortlaut 5.4 |
| D-10 | Licht nach dem Scheppern | Lichtregel W-23 |
| D-11 | Lejlas Quittung | Belegungsblatt „Saalmiete Schlosskeller: 0 Euro“ am Nachmittag; Zettel 22:30 bei Aylin; Umschlag „Miete Schlosskeller“ |
| D-12 | Zeyneps Ort 23:45 | linkes Buffet (W-14) |
| D-13 | Forderung 23:00 | 18:50 Forderung und Tore zu; 23:00 Streit mit „Bis Mitternacht. Sonst ruf ich die Polizei!“ |
| D-14 | Werkzeugkasten | Wojteks Kasten, seit 18:00 an Tim verliehen; Karten: „braunes Möbelwachs“ |
| D-15 | Falscher Alarm 20:15 | Azra ruft, Wojtek leuchtet, Olli bleibt der Lacher; keine Beweiskraft |
| D-16 | Tims Finger | 23:50 Bogentür, 23:52 Satz, ab 23:56 Kaffeemaschine, 0:01 Eis am Sicherungskasten |
| D-17 | Platzwunde | „bewusstlos, mit einer dicken Beule“ (E4) |
| D-18 | XD3-Vermerk, Namen auf Karten | Welt liefert Fundtext wörtlich (6) und den geprüften Vermerk „Wer den Kerzenständer am Fuß hielt, hatte Holzsplitter und weißen Kalk am Ärmel.“; PP9 ohne Namen. Kartentext: Karten-Phase |
| D-19 | Geständnisse auf Karten | keine Spur in 6 enthält ein „gibt zu“ |
| D-20 | Marker Knall und Scheppern | zwei Marker „23:57“ und „Scheppern“; Werte 4.2 |
| D-21 | Personenzählung | E6; die Welt ist unabhängig davon (W-01) |
| D-22 | Tandem-Nummern | E6 (11 Sibel, 12 Damir, 13 Hana, 14 Serkan, 15 Azra, 16 Wojtek, 17 Aylin, 18 Tugba) |
| D-23 | Rand-Indizien | je Zusatzrolle eins, siehe 7.3; Azra trägt 0:12 statt einer zweiten Aussage am rechten Buffet |
| D-24 | Baran, Pawel | gibt es nicht; Box und Kopfhörer Wojtek; blinde Kuh Tugba; keine Schlichtung um 23:00; Schneiders Meldepflicht weiß Aylin |
| D-25 | Wer findet Herrn Schneider | Marek, 0:00:20 |
| D-26 | 150 € Nachzahlung | 150 € pro zahlendem Gast, zusammen 2.550 € (W-12) |
| D-27 | Emine „lag“ | sie kauerte |
| D-28 | Anekdoten der Dias 3–5 | Rüstung Sibel (mit Damir), Verlaufen Olli (mit Azras Alarm), Kamin Hana (mit Serkan); ungespielt „ein Gast“. Neue Anekdoten der Kernrollen: Text-Phase |
| D-29 | Emines Zitat | Kanon-Wortlaut „Um Punkt zwölf geh ich raus und ruf die Polizei.“ |
| D-30 | Scherben 21:00 | 21:00 ein paar Splitter unter den Sockel der Rüstung; Scherben am Boden von 23:40 |
| D-31 | Serkans Versteck | Wunderkerzen seit dem Nachmittag im Auto; 23:56 Tor zu; nie angezündet. Keine zweite Torte, damit sie nicht mit der Mitternachtstorte verwechselt wird |
| D-32 | Wortwahl | gilt für alle Texte (0.2); „Lageplan“, kein Filmtitel |
| D-33 | Herkunftsmatrix | geprüft in 7.4 |
| D-34 | Ollis Stufe 2 | Wortlaut 7.1; Olli sah Can fliehen und verdreht bewusst; Stufe 2 kippt durch Cans Alibi, Mareks zweite Gestalt, PP9; Stufe 3 durch XD3 + FN3 |
| D-35 | Fast alle sahen Olli | Tabelle 5.5 legt fest, wer es weiß und trägt |
| D-36 | Inhalt des Streits 23:00 | nur Tim hört den Inhalt; den Betrag kennen Olli und Tim; „Zweitausend, bis zwölf“ (23:57) hören Ahmet, Marek, Joanna ohne Zusammenhang |
| D-37 | Fehlende Zonen, Teilfelder | Randfeld W; Getränkekisten, Handykorb, Wandtafel, Ehrenplatz, Sicherungskasten eingezeichnet; Bogentür auf der Grenze 7/8; Teilfelder 4a–4d, 8a–8b |
| D-38 | Linker Handschuh | Tugba sah 19:30 das Ablegen; Ruß alt und vom Kaminqualm; Hana schob ihn 23:20 beiseite |
| D-39 | FN3 als Geheimniskarte | FN3 bleibt Tatort-Indiz; Ollis Geheimnis = Bogentür und 2.000 € |
| D-40 | Zeugen-Indizkarten | Welt: Zeugenwissen liegt bei den Rollen (7.2, 7.3). Kartenform: Karten-Phase |
| D-41 | Mietgeld-Summe | fest 2.550 €, nur in Teil 90 gedruckt |
| D-42 | Gruppenfoto und blinde Kuh | nebeneinander um 23:55: Tugba ruft zur blinden Kuh und zum Handykorb, Joanna zum Foto |
| D-43 | Tür quietscht | Vorratsraumtür quietscht nicht |
| D-44 | Raumnamen | „Ost-Saal“ überall |

### WELT 8.3 Lücken-Fragen an den Designer (luecken.md §7.2) und L-05, L-06, L-07, L-15

| Nr | Thema | Entscheidung oder Zuständigkeit |
|---|---|---|
| LÜ D-01 | Scheppern 23:58:30 oder 23:58:40 | 23:58:30 (W-05) |
| LÜ D-02 | Sicherungskasten und Zeynep, Variante a/b/c | Mischung aus (c) und W-04: Tim auf 9/8 vor dem Kasten, Zeynep im Bogen am Pfeiler, Can streift sie; Plan maßstäblich nach Kanon-Raster |
| LÜ D-03 | Untersuchungen | nicht Welt; Spurenliste mit Orten und Zonen in 6 als Grundlage |
| LÜ D-04 | Freigabe des Abwesenheitsblatts | nicht Welt; Welt liefert die Kernsätze der Rollen 5–10 (5.3) |
| LÜ D-05 | Vorderseite der Geheimniskarte | nicht Welt (E8) |
| LÜ D-06 | Weltbestand | 1.1 (W-01); Summe 2.550 €; Kopfhörer Wojtek |
| LÜ D-07 | Kopftuch-Lesart, Tugba | Tugba ganz unbelastet, Wissen offen (W-17, 7.4) |
| LÜ D-08 | Heft gegen Fassung | nicht Welt |
| LÜ D-09 | Detektiv | Welt: 1.5 (Gast, blinde Kuh, hört nur sehr Lautes, sah Olli 23:54 sitzen). Auftritt, Karten, Tipp: spätere Phase |
| LÜ D-10 | Bonus-Ziele | Welt liefert die Kanon-Ziele je Rolle (7.1–7.3); prüfbare Bedingungen: spätere Phase |
| LÜ D-11 | Rundenplan | Welt: Runden 0:30, 1:15, 2:00, Anklage 2:45, Morgen 7:00 |
| LÜ D-12 | Ermittlungsbogen, Überführung | nicht Welt; Welt stellt sicher: XD3 allein nennt keinen Namen, FN3 verbindet, PP9 liegt an Ollis Platz |
| LÜ D-13 | Aktionskarten | nicht Welt; Welt-Grenze: Taschenkontrolle nur Taschen und Gegenstände, nie Kleidung am Kopf |
| LÜ D-14 | Leere Teile | nicht Welt |
| LÜ D-15 | Marker für Schneider, Detektiv, Ungespielte | Herr Schneider 4d / 4c (der Erzähler setzt ihn); Detektiv 1; ungespielte Rollen bekommen keinen Marker |
| LÜ D-16 | Marek 4a oder 4b | 4b, ohne erkennbares Merkmal (W-06) |
| LÜ D-17 | Wer sah Ahmet um 0:12 | Azra allein (W-15) |
| L-05 | Weltbestand gegen Besetzung | Abschnitt 1 |
| L-06 | Positionstabelle | Abschnitt 4, ergänzt durch 3.4 (23:50 bis 0:01) und 3.5 (bis 0:15) |
| L-07 | Geometrie des Durchgangs | 2.5 |
| L-15 | Eine Zeitleiste für alles | Abschnitt 3 ist die einzige Zeitleiste; alle H:MM sind Kanon-Minuten (0.2); Sekunden nur in Teil 90 |

### MECH 12 Entscheidungen dieser Datei

| Nr | Entscheidung | Grund in einem Satz |
|---|---|---|
| M-01 | Indizkarten in Spurkarten und Ortstermine geteilt | Zeugenwissen bleibt bei den Rollen (A:38), kein Selbstlöser (A:18), trotzdem ein fester Weg für den Detektiv (LÜ L-02) |
| M-02 | Jede Runde dauert dreißig Minuten bei jeder Personenzahl | Kanon-Rundendauer (`fall.json:45`), Ziel 2,5–3 h hält bei 6 und 20 Personen |
| M-03 | Pause zwischen Runde 2 und 3 | Vor der Gegenüberstellung frische Köpfe |
| M-04 | „Was alle wissen“ als gleich lautender Block in allen Heften | eine Quelle für das gemeinsame Wissen, verhindert Widersprüche zwischen Heften |
| M-05 | Ermittlungsbogen mit Hilfszeile „Ort um 23:57“ | Die Überführung braucht die Verbindung Fundort ↔ Person (2.4) |
| M-06 | Überführung = XD3 (Teil 1) + passende Spur an der Person, bei Olli FN3 (Teil 2) + PP9 + Ort um 23:57 | A:96, A:107, A:112; PP9 bekommt erst über den Ort Beweiskraft |
| M-07 | Entlastung wie Kanon R-ENTLASTET | bekannt, fair, macht Heimlichtuereien zu Punkten |
| M-08 | Vermerke ohne Urteil; Fundort und Schlüsselbeweis nie mit Namen | Fehlerkorrektur 2, ABG §3.19 |
| M-09 | Rundenbindung: 9 Karten ab R1, 6 ab R2, 4 ab R3; FN3 ab R2, XD3, PP9 und VP7 ab R3 | E12; Fall fällt nicht vor R3 |
| M-10 | Jede Ortskarte sagt „Kein Schlüsselbund.“ | Fundort-Suche durch Ausschluss; falsche Suche deckt Wahres auf |
| M-11 | Tim und Marek vermerken das Alibi „für das leuchtende Gesicht“, Zeynep für Can | Tim und Marek erkennen das Gesicht nicht (WELT §5.2); der Detektiv verbindet über JT3 oder Cans Karte (Fehlerkorrektur 1) |
| M-12 | Je Verdächtigem eine Hinweiskarte ab R1 und eine Gegenstandskarte ab R2 | gleiche Gestalt auch bei den Karten |
| M-13 | FK3 ist der Ortstermin im Steinbogen und Pflicht-Auslöser für Zeynep | E3 („FK3 Zeyneps Aussage“) ohne Wissen auf der Karte |
| M-14 | Alles, was Cans Alibi stützt, ist frühestens in Runde 3 frei | Bei gutem Spiel stehen in Runde 3 Olli und Can gegenüber (Kanon) |
| M-15 | Geheimniskarten enthalten nur Wahres; Ollis Lüge ist nur mündlich | Das Spiel lügt nie mit eigener Stimme (REG §6.10) |
| M-16 | Domino-Ring der Verdächtigen Ahmet → Olli → Can → Fatma → Ahmet | gleiche Gestalt; Ahmets Hinweis erfüllt A:95 |
| M-17 | Pflicht-Auslöser der Zeugen = Codes der Tabelle „Karten unter den Streifen“ (9.14); das Etikett nennt sie nicht | Gespielte und fehlende Zeugen reagieren gleich |
| M-18 | Aktionskarten fehlender Zeugen 5–10 bekommt der Detektiv | kleine Runden brauchen mehr Werkzeug; kein Bruch von Sperren |
| M-19 | Fehlender Zeuge = Zeugenstreifen (Stufe 1) + eigene Geheimniskarte darunter | ein Text für beide Fälle; Abwesenheitsblatt passt auf eine Seite (A:57) |
| M-20 | Keine Entweder-oder-Wahl bei Untersuchungen; Karten bleiben wählbar | keine Pfad-Strafe (Fehlerkorrektur 3, LÜ L-01) |
| M-21 | Der Detektiv füllt keinen Tipp-Zettel; seine Anklage ist sein Tipp | er wird über Ende und Punkte von 9 gewertet (LÜ L-09) |
| M-22 | Sonderregel Olli: Frage 1 und 2 zählen nicht, 3 Punkte, wenn nicht angeklagt; nur in Teil 90 | gleiche Gestalt des Zettels, fairer Höchstwert 5 für alle (LÜ L-10) |
| M-23 | Bonus-Ziel des Erzählers: drei Viertel der Geheimniskarten offen | prüfbar, belohnt Moderation, verrät nichts |
| M-24 | Enden mit Schlüsselbund-Satz in zwei Fassungen | PP9 kann vor dem Ende gefunden sein |
| M-25 | Moderationsimpulse fragen alle vier oder alle am Tisch | gleiche Gestalt, Erzähler spoilerfrei (REG §9 Nr. 14) |
| M-26 | Teil 12 bei 6–12 Personen als Hinweisseite | feste Teileliste für App und Tests (LÜ L-17) |
| M-27 | Lageplan als Blatt A (Plan) und Blatt B (Markerfelder), beide A4 quer; Marker als flache Plättchen, Feld 1 über drei Zellen | E15 wörtlich, maßstäblich, keine Klebekante, Platz für alle Marker (P14-12) |
| M-28 | Verhörstuhl statt fester Befragungsliste | Befragungen frei, keine Antworten im Erzählerheft (E10) |
| M-29 | „Herr Schneider antwortet“ als feste Liste; Zugang über JA9, PM3, Krankenbesuch | Erzähler improvisiert nie (REG §6.10, TON:15), Opfer löst den Fall nicht (W-18) |
| M-30 | Herr Schneiders Erinnerung (Gespenst, Kapuze) steht im Tat-Moment | WELT §1.4; gibt dem Abend die falsche Fährte gegen Can von Anfang an |
| M-31 | Fassung wird nach dem Tat-Moment geöffnet; Rollenheft enthält Stufe 1 und 2 | Rollenheft vorab sendbar ohne Täterwissen (LÜ L-08) |
| M-32 | Rundensperren: Verdächtige keine; Lejla, Emine, Joanna R2; Tim, Marek, Zeynep R3 | Alibis in R1, Heimlichtuereien in R2, Cans Alibi und Beweise in R3 (Kanon-Rundennamen) |
| M-33 | „Ortslügen fallen vor Geheimnissen“ (R-06) | Marker können umgestellt werden, ohne dass sofort das ganze Geheimnis fällt (A:86) |
| M-34 | Taschenkontrolle und Stirnlampe erst ab Runde 2 | stärkste Karten dürfen Runde 1 nicht beschleunigen |
| M-35 | Schutzkarten der Verdächtigen gleich stark, Ollis heißt „Themenwechsel“ | E9, A:102 |
| M-36 | Bonus-Ziel der Verdächtigen: freiwillig reinen Tisch, bevor einer der drei eigenen Sobald-Fälle eingetreten ist | gleiche Gestalt; das Ziel treibt Verhalten, weil eine Pflicht-Umdrehung nicht zählt (P14-07); Ollis Kanon-Ziel (Türschaden selbst klären) bleibt erkennbar |
| M-37 | Gemeinsames Wissen nennt „Ahmet, Fatma, Olli und Can sind die vier Verdächtigen“ | Kanon-Spielrahmen (Kernverdächtige); macht die Spalten des Bogens verständlich |
| M-38 | Vorgeschichte aus Kanon gekürzt, rund 330 Wörter | höchstens eine Druckseite (A:71), Sperrwörter wie Kanon |
| M-39 | Tat-Moment nennt keine Zeugen 5–10 mit Namen | WELT §1.1 |
| M-40 | Maßtabelle mit Abständen in Worten, ohne Sekunden | Sekunden nur in Teil 90 (WELT §0.2) |

Bezug zu den offenen Designer-Fragen (LÜ §7.2): D-03 → Abschnitt 3 und M-01, M-09; D-04 → Abschnitt 5 und M-19; D-05 →
4.1; D-08 → 10.4 und M-31; D-09 → 1.6, 4.6, M-21; D-10 → 7.3; D-11 → 1.1, 1.3; D-12 → 2; D-13 → 4.3 bis 4.5; D-14 → M-26;
D-15 → 10.2. L-01 → 6.3; L-02 → 3; L-03 → 5.5; L-04 → 4.1; L-11 → 1; L-12 → 2; L-13 → 4.3; L-14 → 11; L-16 → 9.9;
L-17 → M-26; L-18 → 10.2.

### RK 9 Entscheidungen dieser Datei

| Nr | Entscheidung | Grund in einem Satz |
|---|---|---|
| RK-01 | Hefte 1–4 und Fassungen gleich gegliedert, mit gemessenen Wortbudgets (1.1, 7.1, 7.7) | E9 und REG §6.11 verlangen gleiche Gestalt und gleiche Länge; Messen statt Schätzen |
| RK-02 | Ziel 1 an Verdächtige nach drei Ring-Mustern, Ziel 2 an Zeugen mit Ausweichziel (1.2) | jede der vier wird je Runde genau einmal gefragt, jeder Zeuge mindestens einmal, R2 trägt den Domino-Ring M-16 |
| RK-03 | Bei den vier nur die drei Pflicht-Auslöser aus MECH §4.2, keine weiteren Gesprächs-Auslöser | gleiche Gestalt; kein Streit am Tisch, ob ein Gesprächssatz „genug“ war |
| RK-04 | Olli sah um 23:55 im Ost-Saal Ahmet die Jacke aufhängen, den dicken Umschlag in der Hand | WELT §3.4: Ahmet 23:55:10–30 am Jackenständer am Eingang, Olli 23:54–23:56:30 am Kopf der Tafel, rund 3 m, volles Licht; gibt Olli eine wahre Ablenkung, ohne zu lügen (W-25) |
| RK-05 | Can sah um 23:50 im Kaminsaal Olli und Tim an der Bogentür und hörte Tims „Au! Mein Finger!“ | WELT §3.4 Stand 23:50: alle vier im Kaminsaal, volles Licht, der Ruf ist laut; Druck auf Ollis Heimlichtuerei in Runde 1 ohne Pflicht |
| RK-06 | Ahmet sah um 23:55 Olli am Kopf der Tafel sitzen | Ahmet war 23:53:30–23:56:50 im Ost-Saal; stützt Ollis Stufe 1 wahr und nur bis 23:56, wie der Detektiv (WELT §1.5) |
| RK-07 | Freigabestufen „sofort / nach dem Marker / nach der Karte“ für Wissen über andere (1.4, 8.1) | Ollis Stufe 1 darf nicht in Minute eins fallen (WELT §5.5), trotzdem hat jede Rolle von Anfang an etwas zu sagen |
| RK-08 | Durch das offene Ostende kam im Dunkeln niemand an Ahmet vorbei | Ahmet und Damir kauern im Ostende, Fühlen bis 1 m (WELT §2.7); Olli nahm die Klappe (D-07), Can rannte nach Westen; wahr und nützlich für I-3.2 |
| RK-09 | Fatma sagt „Olli am Eiskübel“ erst, wenn ihr Marker auf der Klappe steht; Ahmet erst mit seiner Karte | WELT §5.5: Fatma sah es von der Klappe, Ahmet müsste sonst sein Warten auf Herrn Schneider erklären; A:95 bleibt erfüllt |
| RK-10 | Karten der vier nennen keine Rolle 5–10; Cans Domino-Hinweis (MECH wörtlich) bekommt eine Variante ohne Emine, der Zeynep-Satz auf Cans Karte entfällt ohne Zeynep | Karten der vier werden immer gedruckt; WELT §1.1 verbietet Namen ungespielter Zeugen außerhalb des Abwesenheitsblatts |
| RK-11 | Besetzungsvarianten für Namen fehlender Rollen nach Tabelle 1.5 | ein Heft je Besetzung, nie ein Name, der niemandem am Tisch gehört |
| RK-12 | Olli erkennt nicht, wer unter der Maske steckte | Kerzenlicht am Ziel 4,2 m: nur Umriss; an der Klappe dunkel, die Maske beleuchtet nichts (WELT §2.6, §2.7); stützt W-25 |
| RK-13 | Can hört das Scheppern nicht, und sein Heft verrät ihm nicht, dass sein Alibi stimmt | WELT §2.7; Cans Entlastung soll aus Zeugen kommen, nicht aus seinem Heft (M-14) |
| RK-14 | Stufe 3 nur bei der Anklage, ein Text je Rolle für jeden Beweisstand | MECH §8.1 und §8.2; A:96 ist erfüllt, weil Überführung genau XD3, FN3, PP9 verlangt |
| RK-15 | Abschnitt „Wenn es eng wird“ mit fünf Sätzen in allen vier Fassungen (der fünfte zum Marker „Scheppern“, P2-04); Ollis Ausflüchte ohne Namen | gleiche Gestalt; Olli braucht Halt bis zur Anklage, die drei anderen ihre Verteidigung |
| RK-16 | Detektiv: Auftritt, Aufgaben je Runde, Fragen-Leitfaden; keine Geheimniskarte, keine eigene Aktionskarte, kein Tipp-Zettel, kein Bonus-Ziel | M-18, M-21, MECH §6; seine Werkzeuge sind Verhörstuhl, Untersuchungen und Bogen |
| RK-17 | entfällt (Integration Runde 1, P14-07): Das Bonus-Ziel zählt nur freiwilliges Umdrehen vor dem ersten eigenen Sobald-Fall; geprüft über den Zusatz „freiwillig“ in der Vermerke-Liste | Eine Pflicht-Umdrehung erfüllte das alte Ziel fast von selbst |
| RK-18 | Auftritte: nur Olli erzählt eine Dia-Anekdote (Dia 4, Verlaufen); Ahmet, Fatma, Can erzählen gleich lange Kanon-Geschichten ohne Bezug zu ihrem Geheimnis; Azra und Wojtek bleiben darin namenlos | A:72, WELT D-28; Sperrwörter der Vorgeschichte (MECH §9.3) gelten auch hier |
| RK-19 | Untersuchungsliste in Teil 01 bekommt die Spalte „Kein Bund ☐“ | M-10 macht „Kein Schlüsselbund“ zu einer Ausschlusssuche; der Detektiv braucht Platz dafür |
| RK-20 | Ollis Stufe 1 lügt nur über den Ort; Eis und Handschuh erklärt er wahr | W-20; wer weniger lügt, bleibt länger glaubwürdig, und Olli bleibt liebenswert |
| RK-21 | Olli sagt nie, woher das Möbelwachs kam | Kanon-Loyalität (`figuren.json:253-256`), hier zu Tim; Tims Karte trägt es (MECH §4.2) |
| RK-22 | Jede Fassung beginnt mit „Du warst es (nicht).“ und dem Ziel der Nacht | Kanon-Muster der alten Fassungen (`u4yrk/4/txt/11-fassungen.txt`); gleicher erster Satzbau bei allen vier |
| RK-23 | Die Nachschläge der Runde-2-Ziele sind der eigene Domino-Hinweis | der Domino-Ring läuft auch mündlich, und eine früh offene Karte erzeugt in Runde 2 neue Fragen statt Leerlauf |
| RK-24 | Ausweichziele gehen nur an Verdächtige mit wahr beantwortbarer Frage oder an den Detektiv als Bitte um eine Untersuchung; jede Bitte hat einen zweiten Satz an eine Verdächtige oder einen Verdächtigen (P14-14) | kein Verweis auf fehlende Rollen; jede Bitte zeigt auf einen Ort, an dem ein Zeugenstreifen liegen kann |

### ZG 11 Entscheidungen dieser Datei

| Nr | Entscheidung | Grund |
|---|---|---|
| Z-01 | Zeugen lügen nie; Stufe 1 = offenes Wissen plus Tarnsätze plus Verbotsliste | WELT §7.4 lässt Lügen nur bei Rollen 1–4 und Serkan zu; das Spiel lügt nie mit eigener Stimme (REG §6.10) |
| Z-02 | Gesprächs-Auslöser gelten nur für gespielte Zeugen und umgehen nie eine Sperre | MECH §4.2 erlaubt sie; sie verhindern Leerlauf und machen das Domino robust, ohne kleine Runden zu verändern |
| Z-03 | Runde-3-Auslöser für Tim, Marek, Zeynep: direkte Frage vor allen (auch Impuls I-3.1) oder die Behauptung, das Gesicht oder Can sei es gewesen | die natürliche Szene der Gegenüberstellung; G-05 bleibt gewahrt |
| Z-04 | Weitere Karten-Auslöser: Lejla ← Ahmets oder Joannas Karte; Joanna ← Ahmets oder Lejlas Karte; Emine ← Fatmas Karte; Marek und Zeynep ← Cans Karte; Tim ← Zeyneps Karte | gleicher Inhalt wie die Codes (Ahmets Geld, Fatmas Schatulle, Cans Maske) oder Domino nennt die Person (Zeynep → Tim) |
| Z-05 | Nachbohr-Ziele haben, wo nötig, zwei Fassungen nach Tischstand | G-07: niemand nutzt Wissen, das noch nicht frei ist |
| Z-06 | Platzhalter [Name \| Ersatz] für fehlende Rollen | WELT §1.1, MECH §1.5 |
| Z-07 | Emine darf erst nach dem Umdrehen sagen, dass Fatma um 23:57 zur Klappe ging; kein eigener Vermerk dafür | WELT §5.5 (sie schaute nur auf Fatma); die Kartenvermerke bleiben wie MECH |
| Z-08 | Abgeleitete Wahrnehmungen, aus WELT §2.7 (Sehen, Hören) und §3.4 (Orte) berechnet: Tim sieht 23:55 Herrn Schneider zu Fatma gehen und weiß, dass 23:50–23:55 nur Herr Schneider durch die Bogentür ging; Zeynep sieht 23:50 Olli und Tim an der Bogentür; Joanna sieht 23:56 Herrn Schneider bei Fatma; Lejla sieht 0:00 Olli zum Eiskübel gehen; Zeynep schaut als Schmiere in den Kaminsaal | gleicher Raum, volles Licht, laut gerufen. Keine dieser Beobachtungen entscheidet den Fall; jede erzeugt nur Druck und lenkt zu einer Indizkarte |
| Z-09 | Bonus-Ziele: Lejla, Emine, Zeynep schützen ihre Person bis zum Ausscheiden; Tim: Alibi-Zeile bei drei von vier; Joanna: Ort-Zeile bei allen vier; Marek: Ahmets Heimlichtuerei belegt | MECH §7.3; alle am Tisch prüfbar, bei jeder Besetzung erreichbar, keins belohnt eine falsche Anklage |
| Z-10 | Die Anekdoten der Dias 3, 4, 5 gehören Sibel, Olli, Hana; die Zeugen bekommen eigene Anekdoten aus Kanon-Vorstellung und Steckbrief, ohne Fallbezug | WELT D-28, A:72 |
| Z-11 | Joannas Notiz zählt nicht zu den 80 Wörtern des Streifens | MECH §5.2 setzt sie zweispaltig unter das Protokoll (P145R2-K04) |
| Z-12 | Mareks Parkplatz steht offen im Auftritt; sein Kanon-Ziel (nicht abschleppen) wird nicht Bonus-Ziel | harmlos und lustig; am Tisch nicht prüfbar |
| Z-13 | Tim hält zu Olli nur durch Tarnsätze und Ablenkung auf Can, nie durch Lügen; Bonus nicht „Olli schützen“ | ABG A-231, Z-01 |
| Z-14 | Ollis Satz von 23:52 ist Tims Wissen nach dem Umdrehen; „Ich hol dir Eis“ allein ist offen | WELT §5.5 nennt 23:52 als Tims Stufe-2-Wissen; „Eis für Tim“ steht schon in Ollis Stufe 1 (W-20) |
| Z-15 | Lejla kennt die Höhe von Ahmets Nachzahlung nicht | WELT §1.8 (sie weiß nur, dass er in der Klemme steckt) |
| Z-16 | „Was du bei dir trägst“ nennt nur harmlose Dinge; neu ohne Fallbezug: Lejlas Kugelschreiber, Tims nasse Serviette, Mareks Geldbeutel, Zeyneps Trillerpfeife | Taschenkontrolle braucht für jede Rolle eine Antwort (MECH §4.4) |
| Z-17 | Lejla sagt offen, dass Herr Schneider sich an die Sekunden vor dem Scheppern nicht erinnert | WELT §1.4; das stützt „Was alle wissen“ und gibt ihrer Rolle als Apothekerin Gewicht |
| Z-18 | Marek nennt den Gast mit der Teekanne nur dann Damir, wenn Damir gespielt wird | WELT §1.1, §3.4 (23:57:30) |

### ZR 14 Entscheidungen dieser Datei

| Nr | Entscheidung | Grund |
|---|---|---|
| ZR-01 | Zusatzrollen lügen nie, außer Serkans Decken-Satz; Stufe 1 = offenes Wissen, Tarnsätze, Verbote | WELT §7.4 nennt unter 11–18 nur Serkan als Lügner; das Spiel lügt nie mit eigener Stimme (REG §6.10); wie ZG Z-01 |
| ZR-02 | Kein Zusatz-Satz erfüllt einen Pflicht-Auslöser der vier Verdächtigen; keiner sagt, das Gesicht sei aus dem Vorratsraum gekommen | A:60 „nicht allein lösen“; Rundenbalance MECH §3.5 |
| ZR-03 | Gesprächs-Auslöser: Partnerkarte (Tandem 1 und 2), Vitrinen-Vorwurf (Tandem 1), zweite Frage nach dem Papier (Hana, spiegelbildlich zu Serkan), Fatmas Karte (Azra), Azras oder Tims Karte (Wojtek), Ahmets Karte und Taschenkontrolle (Aylin), Aylins Karte und Taschenkontrolle (Tugba) | jeweils gleicher Inhalt oder Domino nennt die Person; macht die Mini-Intrige spielbar; keiner umgeht eine Sperre (MECH §4.2 erlaubt Ergänzungen) |
| ZR-04 | Nachbohr-Ziele nennen nur kleinere Plätze; deshalb kein Ausweichziel | E6: kleinere Plätze sind immer besetzt; der Partner wird nur vom größeren Platz angebohrt |
| ZR-05 | Abgeleitete Wahrnehmungen aus WELT §2.7 und §3.4 (gleicher Raum, volles Licht, laut gerufen): Sibel 23:50 (Olli und Tim an der Bogentür, Can und Zeynep an der Tafel, Hana an der Nische), Sibel und Hana 0:00 (Zeynep im Steinbogen) und 0:01 (Can aus dem Turmgang); Hana 23:50 (dreht sich beim Ruf um, sieht Tim, Olli, Sibel); Damir 0:00 (Ahmet mit dem Umschlag, WELT §3.4 „Umschlag in der Hand“); Aylin 22:30 (Durchschlag Bogentür im Quittungsblock, WELT §6); Azra 0:12 (Bündel Scheine, WELT §3.5 „Azra sieht es“) | keine dieser Beobachtungen entscheidet den Fall; jede erzeugt nur Druck oder lenkt zu einer Indizkarte (wie ZG Z-08) |
| ZR-06 | Sibel döst ab etwa 23:54 und hört im Kaminsaal nichts; Rufe kennt sie nur vom Hörensagen | WELT §3.4 (döst), §2.7 (Kaminsaal hört weder Knall noch Scheppern) |
| ZR-07 | Azras Rand-Indiz (0:12) ist erst ab Runde 2 frei | Runde 1 gehört den Alibis, Runde 2 den Heimlichtuereien (M-32); WM9 ist auch erst ab Runde 2 frei |
| ZR-08 | Hana: Gesicht offen ab Runde 1 (wie Sibel, ohne Zeitbezug zum Scheppern), Kerzengeruch erst ab Runde 3 | M-14; nur der Geruch gibt die Reihenfolge |
| ZR-09 | Nach dem Scheppern schauen alle Ost-Saal-Rollen zur Tür in den Buffetsaal, woher der Lärm kam. Auf den Kopf der Tafel achten sie nicht; den leeren Kopf der Tafel bemerkt nur Joanna, die fürs Gruppenfoto zählt (P3-20) | WELT §5.4 gibt die Beobachtung nur Joanna; sonst wüssten Zusatzrollen mehr als die Zeugen (ABG D-23) |
| ZR-10 | Domino-Hinweise: Partner nur, wo er sicher besetzt ist; sonst Solo-Fassung. Drei Hinweise nennen einen Ort statt einer Rolle (Sibel allein, Hana allein, Aylin) | MECH §4.1 erlaubt „eine andere Rolle oder einen Ort“; Aylin und die Solo-Fassungen haben keinen sicheren, wahren Satz über eine Rolle, der neu wäre |
| ZR-11 | Wojteks Karte trägt Tims Satz von 20:15 (ab Runde 2); Tims eigene Karte bleibt Runde 3 | WELT §3.3, §7.3; MECH §4.2 („zählt mit YT4 für M7“) und §11.3 („Wojtek stützt M7 in Runde 2“); Tims Hauptgeheimnis (Knall, Gesicht) bleibt gesperrt |
| ZR-12 | Fehlt Wojtek, trägt Azras Karte Tims Satz | So kommt der Satz in jeder Besetzung ab 17 Personen über genau eine Zusatzkarte |
| ZR-13 | Bonus-Ziele: Sibel reiner Tisch vor FM9/YT4; Damir Quelle bei Ahmets Alibi; Hana Cans Alibi ✓; Serkan Bund wieder bei Herrn Schneider; Azra Fatmas Karte offen; Wojtek Ollis Schramme ✓; Aylin Ahmets Zusage; Tugba Torte per Indizkarte | MECH §7.3 („eigenes Anliegen“, „reinen Tisch“); alle am Tisch prüfbar, bei jeder Besetzung der Rolle erreichbar, keins belohnt eine falsche Anklage; Kanon-Ziele erkennbar |
| ZR-14 | „Was du bei dir trägst“ nennt Aylins Zettel und Tugbas Dankeskarte; eine Taschenkontrolle bei ihnen ist Auslöser | MECH §4.4: „Was eine Person zeigt, ist wahr“; ohne Auslöser müsste Aylin beim Zeigen schweigen oder lügen |
| ZR-15 | Damir antwortet beim Ortstermin WJ9 mit | MECH §3.3 nennt nur Marek und Ahmet; Damir kauerte beim Scheppern dort (WELT §4.1) |
| ZR-16 | Bei „Handzeichen“ darf sich enthalten, wer etwas zurückhält | Die Karte sagt „nach ihrem Heft“; eine gesenkte Hand wäre sonst eine Lüge. Seit Integration Runde 1 steht die Enthaltung auf der Karte selbst (P14-11) |
| ZR-17 | Dankeskarte: alle haben beim Einlass unterschrieben; Aufschrift „Danke für 25 Jahre Schloss!“ | WELT §3.3 („alle“), §1.4 (seit 25 Jahren); harmlos, nicht lösungsrelevant |
| ZR-18 | Azras Zeit vor der Vitrine bleibt ohne Uhrzeit; einen Sprung bemerkte sie nicht | Kanon nennt keine Zeit; WELT §3.3: vom Sprung weiß sonst niemand |
| ZR-19 | Die Fragen des Erzählers meiden das Geheimnis jeder Rolle (Azra nicht nach Geschichten des Schlosses, Aylin nicht nach Belegen, Hana nicht nach dem Papier) | E10, spoilerfrei; die Anekdote kommt aus dem Auftritt |
| ZR-20 | Serkans Ausrede ist immer derselbe Satz; ein Impuls, der alle nach dem Warum fragt, zählt als einmal gefragt | macht die Bedingung „zweimal gefragt“ prüfbar |
| ZR-21 | Tugbas Plan der blinden Kuh (zur Torte in den Vorratsraum) ist offen, ihre Vermutung zum Erschrecken als Vermutung erlaubt | Kanon `figuren.json` (tugba); W-17 verbietet ihr zurückgehaltenes Wissen; sie spricht nie vom Gesicht (ZR-02) |
| ZR-22 | Rollenbezeichnungen aus dem Kanon (`roleTitle`) | ein Name je Figur in App und Druck; „Die Kamin-Heizerin“ nennt nur den öffentlichen Lacher |
