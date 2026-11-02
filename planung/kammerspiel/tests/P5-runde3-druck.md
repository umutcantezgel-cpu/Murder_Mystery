# Protokoll 5, Runde 3: Druck- und Layout-Vollständigkeitstest am echten Druck

Fall U4YRK, „Spuk im Schlosskeller“, Kammerspiel, Täter Olli. Geprüft am 2026-11-02.
Repository nur gelesen. Eigene Dateien liegen im Arbeitsordner der Prüfung außerhalb des Repositorys (`r3/p5/`;
Skripte in `bin/`, Bilder in `a6/`, `a10/`, `a20/`, `m6/`, `m10/`, `m20/`, `img/`, `ex/`, Zusatzbesetzungen in `druck/`).

## Ergebnis in einem Satz

Das Paket ist vollständig. Jeder Inhalt aus AUFTRAG 5.5 ist bei 6, 10 und 20 Personen (w und m) gedruckt.
Es gibt keine Platzhalterreste, die Seitenzahlen laufen richtig, alle Verweise „Seite N“ stimmen, und kein
Text ist abgeschnitten oder überlappt. **Bestanden mit Befunden:** ein mittlerer Befund (Teil 90 ist nicht
gegen Durchscheinen und falsches Falten geschützt) und sechs kleine.

## Geprüfte Grundlage

| Satz | Herkunft | Seiten (alles) |
|---|---|---|
| 6 Personen w, m | `druck-r3/{w,m}/kammerspiel-U4YRK-p6`, `alles-w/…-p6` | 87 |
| 10 Personen w, m | `druck-r3/{w,m}/kammerspiel-U4YRK-p10`, `alles-w/…-p10` | 105 |
| 20 Personen w, m | `druck-r3/{w,m}/kammerspiel-U4YRK-p20`, `alles-w/…-p20` | 144 |
| 7, 8, 9, 11–19 Personen w; 7 und 13 m | selbst gesetzt mit `dart run bin/party_druck.dart --personen N [--detektiv m]` nach `r3/p5/druck/` | – |

Der Arbeitsbaum blieb unverändert (`git status` danach leer).

## 1. Vollständigkeit gegen AUFTRAG 5.5, Punkt für Punkt

| Teil | Verlangt (AUFTRAG 5.5) | Befund im Druck | Ergebnis |
|---|---|---|---|
| 00 | nicht-allwissender Erzähler | Deckblatt „Du kennst die Lösung nicht. Das ist Absicht.“, „Übrigens: Ich weiß selbst nicht, wer es war.“ Kein Fassungscode, kein „Täter“, kein „Es war Olli“ im Heft (Skript `teile.py`, alle Besetzungen) | erfüllt |
| 00 | Ping-Pong-Fragen | S. 5–6 „Vorstellungsrunde“: Frage je gespielter Rolle, zum Schluss an den Detektiv bzw. die Detektivin; bei fehlenden Rollen die Anekdoten „Danach, weil heute niemand die Rolle spielt“ | erfüllt |
| 00 | Moderations-Impulse | S. 9, 11, 12: je Runde vier Impulse I-x.1 bis I-x.4, Ausweichsatz und Domino-Frage S. 10 | erfüllt |
| 00 | Skalierungs-Anleitung | S. 16: Zeile der heutigen Personenzahl ausführlich, Kurztabelle 6–20, bei 6–11 Personen „Karten unter den Streifen“ | erfüllt |
| 01 | Detektivbogen und Ermittlungsbogen | 6 Seiten: Auftritt, Wissen, Was alle wissen, Leitfaden, Aufgaben je Runde, Untersuchungsliste (19 Karten nach Runde), Ermittlungsbogen mit Regeln, Vermerke 1–48, Anklage; bei 6–11 Personen „Aktionskarten der fehlenden Zeugen“ | erfüllt |
| 02 | Lageplan | Blatt A „Lageplan: Gewölbekeller unter dem Schlossturm“, Zonen 1–8, Teilfelder 4a–4d, 8a, 8b, W, Legende, „Eiskübel (vor dem Ostende)“; Blatt B Markerfelder | erfüllt |
| 02 | ausschneidbare Positions-Marker | 2 je Rolle, 2 Detektiv, 2 Herr Schneider (12 / 20 / 40), gestrichelte Schnittlinien, 26 × 18 mm | erfüllt |
| 02 | Tipp-Zettel für alle Spieler | P − 1 Zettel (5 / 9 / 19), inkl. Erzähler, ohne Detektiv (MECH 12a A:116) | erfüllt |
| 02 | Abwesenheits-Blatt | bei 6–11 Personen, 1–6 Streifen 100 × 95 mm, Falz 30 mm, Etikett nach MECH 5.3; ab 12 Personen keins (MECH 12a A:57) | erfüllt |
| 10 | Rollenhefte 1–10 mit Auftritt/Anekdote, Gesprächsaufträgen, 2-Stufen-System | je 4 Seiten; jedes Heft enthält „Dein Auftritt bei der Vorstellung“, „Wer du bist“, „Was alle wissen“, „Deine Marker“, Stufe 1, Stufe 2, Runde 1–3 mit Zielen, „Wenn der Erzähler fragt“, „Was du bei dir trägst“, Aktionskarte, Bonus-Ziel; die vier Verdächtigen dazu den Fassungscode (geprüft in allen 15 Besetzungen) | erfüllt |
| 11 | WW4 Ahmet, JM3 Fatma, RN7 Olli, YW4 Can | 4 × 4 Seiten, Außenseite mit Code und Hinweis, Falzlinien bei 99 und 198 mm, Verschlussanleitung im unteren Drittel | erfüllt |
| 12 | Zusatzhefte 11–18 | 20 Personen: 8 × 3 Seiten; ≤ 12 Personen Hinweisseite wörtlich nach MECH 10.1; 13–19 Personen die besetzten Hefte, Solo-Abschnitt beim Platz ohne Partner, Tandem-Kasten immer (E21) | erfüllt |
| 20 | Geheimnis-/Beweiskarten und Aktionskarten für alle Rollen | je besetzter Rolle eine, bei 6–11 Personen zusätzlich die der fehlenden Zeugen (10 / 10 / 18), fehlende mit Kopf „heute beim Detektiv“ bzw. „Heute spielt diese Rolle niemand“ | erfüllt |
| 20 | Indizkarten AD3 bis YT4 | alle 19 Codes, Z-Falz mit grauem Deckfeld | erfüllt |
| 90 | 9-Punkte-Meilensteinwertung | S. 2 Tabelle M1–M9 mit Kästchen und Summe „von 9“ | erfüllt |
| 90 | 4 Enden | S. 3–4 Endentabelle und Ende 1–4, je mit PP9-Weiche | erfüllt |
| 90 | komplette Rückblende | S. 5 Rückblende, ab S. 6 Zeitleiste mit Sekunden | erfüllt |
| 90 | Punkte für alle Mitspieler | Tipp-Wertung, Sonderregel Olli, Bonus-Ziele aller gespielten Rollen und des Erzählers, Spürnase | erfüllt |

Seitenumfänge: 00 = 16, 01 = 6, 02 = 6 / 7 / 8, 10 = 4 je Rolle, 11 = 16, 12 = 1 bzw. 3 je Zusatzrolle, 20 = 17 / 17 / 22,
90 = 9 / 10 / 12 bei 6 / 10 / 20 Personen; das entspricht MECH 10.1 und E18. Die Einzeldateien je Rolle enthalten
Heft und Aktionskarte (MECH 10.3).

## 2. Suche nach Resten in allen Textdateien

Durchsucht: `druck-r3/text/{w,m}/…p6/p10/p20/*.txt` (layout), dazu selbst erzeugter Rohtext (ohne `-layout`) aller
PDFs bei 6/10/20 w/m und bei 7, 8, 9, 11–19 w sowie 7, 13 m.

| Muster | Treffer | Bewertung |
|---|---|---|
| `TODO`, `OFFEN`, `FIXME`, `XXX`, `TBD` | 0 | sauber |
| `undefined`, `NaN`, `Instance of` | 0 | sauber |
| `null` | 1 Stelle je Satz ab 7 Personen | echter Text: „…Klemmbrett, auf dem für den Keller null Euro Miete stand.“ (Teil 90, Lejla) |
| `{`, `}`, `|`, `**`, `*`, `\n`, `rolle:`, `wenn:`, `ab:`, `detektiv:` | 0 („rolle:“ nur in „Taschenkontrolle:“) | sauber |
| `...`, `…` | 0 | sauber |
| doppelte Leerzeichen im Satz (Rohtext) | 0 | sauber |
| Leerzeichen vor Satzzeichen | 0 | sauber |
| doppelte Wörter | nur „Lejla Lejla …“ usw. in „Die Rollen am Tisch“ (Befund P5R3-04) und „sie sie“, „die die“ als korrektes Deutsch | 1 Befund |
| unpaarige „ “ bzw. ‚ ‘ je Seite | 0 Seiten | sauber |
| ASCII-Anführungszeichen `"` | 0 | sauber |
| leere Überschriften | keine; Überschrift als letzte Zeile einer Seite nur bei „Notizen“ (Teil 11, gewollt) | sauber |
| Namen fehlender Zeugen in Heften, Teil 01, Teil 11 | nur in Joannas Liste (erlaubt, MECH 5.3) | sauber |
| Ersetzungen (Groß/klein am Satzanfang) | keine Fehler | sauber |

## 3. Seitenzahlen, Verweise, Kopf und Fuß

- Skript `pruef_fuss.py` über alle PDFs aller 15 Besetzungen: Fuß „Seite N von M“ fortlaufend je Teil (00, 01, 90 ab
  S. 2), je Heft in 10 („von 4“) und 12 („von 3“), je Fassung in 11 (S. 2–4, Außenseite ohne Fuß), Einzeldateien
  „von 4“/„von 3“ plus Kartenseite „1 von 1“ (bekannt). Teile 02 und 20 sind Schneidebögen ohne Fuß. **0 Abweichungen.**
- Inhaltsverzeichnis des Erzählerhefts (21 bzw. 22 Einträge) gegen die tatsächlichen Seiten in allen 15 Besetzungen:
  **0 Abweichungen.**
- Verweise im Text: „Du liest es auf Seite 7.“ (00) → „Was alle wissen“ steht auf S. 7; „auf Seite 3 das Ende aus“ und
  „die Rückblende auf Seite 5“ (90) → stimmt in allen Besetzungen. „hinten in diesem Heft“ (Tabelle „Karten unter den
  Streifen“) → S. 16. „Regel unten“ (Ermittlungsbogen) → S. 4 unten. Alle stimmen.
- Kopfzeile je Teil und je Heft (Name rechts), Fallcode im Fuß: durchgehend.

## 4. Sichtprüfung

Gerendert mit `pdftoppm -r 50` und zu Übersichten zusammengesetzt (`montage`):

- **10 Personen, alle 105 Seiten** von `kammerspiel-alles.pdf` (Übersichten `m10/m01`–`m15`, Karten `k1`–`k5`),
  Lageplan zusätzlich in 110 dpi in vier Ausschnitten, Ermittlungsbogen und Markerbogen in 120–300 dpi, Kartenfeld XD3
  in 110 dpi.
- **6 Personen:** 00 S. 2, 3, 5, 6, 13, 16; 02 alle; 12; 20 Geheimnis- und Aktionskarten (S. 72–78); 90 S. 6–9;
  Abwesenheitsblatt mit sechs Streifen zusätzlich in 130 dpi (Joannas Streifen mit Notiz).
- **20 Personen:** 00 S. 2, 3, 5, 6, 13, 16; 02 alle acht; 12 alle 24; 20 Geheimnis- und Aktionskarten (S. 121–132);
  90 S. 6–12. Lageplan A und B pixelgleich zu 6 Personen.
- **Zusatz:** 11 Personen (ein Streifen), 13 Personen (Sibel allein), 19 Personen (Aylin allein, Vorstellungsrunde
  über zwei Seiten).

| Prüfpunkt | Ergebnis |
|---|---|
| abgeschnittener Text | keiner; Skript `rand.py`: kein Zeichen näher als 5 mm am Blattrand (Druckrand) |
| Überlappungen | keine; Skript `rand.py` (Wortboxen) und Sicht, auch Lageplan-Beschriftungen frei |
| leere/fast leere Seiten | nur dort, wo Schneidebögen nicht voll werden (Marker bei 6 P., letzter Tipp-Zettel-Bogen, YT4 allein, Aktionskarten „heute beim Detektiv“, Abwesenheitsblatt mit 1–2 Streifen) und die gewollten Notizseiten der Fassungen; vertretbar |
| Ausrichtung | Tipp-Zettel 90° gedreht (4 je A4), Streifenprotokoll 180° gedreht (MECH 5.2), sonst aufrecht |
| Schnitt- und Falzlinien | Schnitt grob gestrichelt, Falz fein gepunktet, unterscheidbar; Streifen 100 × 95 mm, Falz bei 30 mm; Fassung Falz bei 99/198 mm; Kartenfelder Z-Falz mit Anleitung |
| Schwarzweiß | nur zwei Textfarben (≈ #212121 und 38 % Grau); Graustufen-Render des Markerbogens gut lesbar; Deckfeld der Karten schraffiert |
| Schriftgrößen | Lesetext ≥ 9 pt; darunter nur Kopf/Fuß/Marken 8,5 pt, „Hier falten“ 6,5 pt, Joannas Notiz auf dem Streifen 8 pt (E19) |
| versiegelte Außenseiten | Teil 11: oberes Drittel nur Code und „Versiegelt. Erst öffnen, wenn der Erzähler es sagt.“, Mitte leer, Anleitung im unteren Drittel, das beim Falten innen liegt. Teil 90: nur „Auflösungsheft“, „U4YRK“, „Versiegelt – erst nach der Anklage öffnen“ (aber siehe P5R3-01) |
| w/m | Unterschiede nur in Anrede und Beschriftung (Deckblatt, Teileliste, Vorstellung, Auftrag, Teil 01 Kopf, Marker, 90 S. 2), wie E20 |

## 5. Befunde

### P5R3-01 (mittel) Teil 90 ist nicht gegen Durchscheinen und falsches Falten geschützt

- **Besetzung:** alle (6, 10, 20; w und m).
- **Ort:** `90-aufloesung-versiegelt.pdf` S. 1 und 2; `00-erzaehlerheft.pdf` S. 2 („Drucken, schneiden, falten“).
- **Zitat:** Erzählerheft S. 2: „Falte Teil 90 und versiegle es.“ – Teil 90 S. 1: „Versiegelt – erst nach der Anklage
  öffnen“ – Teil 90 S. 2: „Es war Olli. Um drei vor zwölf stand er am Eiskübel.“
- **Problem:** Teil 90 hat anders als Teil 11 weder Falzlinien noch eine Verschlussanleitung und steht nicht in der
  Papierempfehlung („Nimm für Teil 02 und Teil 20 festeres Papier ab 120 Gramm. Dann scheint nichts durch.“); der
  Lösungssatz auf S. 2 (ab 20 mm vom linken Rand, 48–70 mm von oben) liegt direkt hinter der leeren Fläche des
  Deckblatts (der Codekasten reicht nur von 67 bis 143 mm Breite und 41 bis 78 mm Höhe).
- **Wirkung am Tisch:** Der nicht-allwissende Erzähler verwahrt das Heft den ganzen Abend vor sich. Je nach Faltung
  liegt nur eine Lage Normalpapier über „Es war Olli“ und der Meilensteintabelle („gehört zu: Olli“). Das Heft schützt
  die Lösung schwächer als Teil 11 und Teil 20.
- **Vorschlag:** In `aufloesung.dart` (Deckblatt über `KammerSeiten.versiegelt`, satz.dart Z. 710 ff.) dieselben
  Drittel-Falzlinien und denselben Verschlusskasten wie in `fassungen.dart` setzen, mit neuen Schlüsseln in
  `ui/90.json`, etwa `verschliessen.1` „Lege die Seiten 2 bis {letzte} aufeinander und falte sie zusammen in Drittel,
  die Schrift nach innen. Lies dabei nichts.“, `verschliessen.2` „Lege sie auf die leere Rückseite dieses Blatts, genau
  hinter das mittlere Drittel.“, `verschliessen.3`/`.4` wie in Teil 11. In `erzaehlerheft.json` (vorbereitung, Teil 90)
  „Falte Teil 90 und versiegle es.“ ersetzen durch „Falte Teil 90 so, wie es auf seiner ersten Seite steht, und klebe es
  zu. Lies dabei nichts.“ und in der Zeile „alle“ ergänzen: „…festeres Papier ab 120 Gramm, für Teil 02, Teil 20 und
  Teil 90.“

### P5R3-02 (klein) Ollis Fassung RN7 ist auf Seite 3 sichtbar dichter gesetzt als die drei anderen

- **Besetzung:** alle (6, 10, 20; w und m).
- **Ort:** `11-fassungen.pdf` S. 11 (RN7 S. 3) gegen S. 3, 7, 15.
- **Zitat:** RN7 S. 3: „1. Das leuchtende Gesicht ist weggerannt, bevor du zur Vorratsraumtür gingst. Wer darunter
  steckte, hast du nicht erkannt. Nenn nie einen Namen dafür.“ – unmittelbar darauf ohne Leerzeile „2. Deine Stufe 2
  verdreht die Wahrheit: …“; bei WW4, JM3 und YW4 steht zwischen den Punkten jeweils eine Leerzeile.
- **Problem:** Der Generator streckt kürzere Listen über den Eintragsabstand, damit alle Abschnitte gleich hoch sind;
  dadurch stehen in RN7 die Punkte von „Was nur du weißt“ 11,7 mm auseinander (zweizeilig), in WW4/JM3 14,3 mm, und die
  Sobald-Sätze von „Wenn es eng wird“ ohne Luft (11,6 mm gegen 14,3 bis 15,7 mm). Die Überschriften stehen gleich hoch,
  die Seite wirkt aber erkennbar dichter. RK 7.1 verlangt: „kein Satz verrät außen oder am Seitenbild, welche Fassung
  die Tat enthält“.
- **Wirkung am Tisch:** Die Verdächtigen haben Seite 3 („Wenn es eng wird“) während der Runden vor sich. Wer
  neben Olli sitzt und seine eigene, luftige Seite kennt, kann am Seitenbild sehen, dass Ollis Fassung mehr Text hat.
  Ein schwaches, aber unnötiges Meta-Indiz.
- **Vorschlag:** `fassungen.dart` Z. 126–133 (Liste „gestreckt über den Abstand zwischen den Einträgen“): Einträge mit
  festem Abstand `g * _listenAbstand` setzen und die Resthöhe des Abschnitts als Leerraum unter die Liste legen. Die
  Abschnitte bleiben gleich hoch, die Dichte der Listen ist in allen vier Fassungen gleich.

### P5R3-03 (klein) Markerfelder fassen die Höchstbelegung nur, wenn die Plättchen Feldname und Skizze verdecken

- **Besetzung:** 18–20 Personen (belegt bei 20, w).
- **Ort:** `02-tisch.pdf` S. 2 (Blatt B), Felder „1 Ost-Saal“ und „4d Theke Ostende“.
- **Zitat:** „Blatt B: Markerfelder“, Feldköpfe „1 Ost-Saal“ und „4d Theke Ostende“; Markerbogen „Jede Person bekommt
  zwei Marker: 23:57 und Scheppern.“
- **Problem:** Die Zellen sind 54 × 58 mm (Feld 1: 162 × 58 mm). Darin stehen oben der Feldname (bis etwa 9 mm, bei 4c
  dreizeilig bis 18 mm) und rechts unten die Mini-Skizze (etwa 33 × 23 mm). Bei 20 Personen kommen auf 4d sechs
  Plättchen (Ahmet 2, Marek 2, Damir 1, Herr Schneider 1) und auf Feld 1 fünfzehn (Joanna, Olli, Aylin, Azra, Tugba,
  Wojtek je 2, Damir 1, Detektivin 2). Drei Reihen à 18 mm brauchen 54 der 58 mm; Name und Skizze liegen in dieser
  Fläche.
- **Wirkung am Tisch:** Bei großen Runden decken die Plättchen den Feldnamen von 4d und Feld 1 zu. Beim Umstellen
  muss man Plättchen anheben, um das Feld zu erkennen. Das ist lästig, verhindert aber das Spiel nicht.
- **Vorschlag:** `tisch.dart` (Blatt B): Feldname einzeilig in ein Kopfband von höchstens 6 mm (Nummer im Kreis und
  Kurzname, Langname nur auf Blatt A) und die Mini-Skizze auf etwa 15 × 12 mm rechts in dieses Kopfband. Darunter
  bleiben 52 mm frei: 2 × 3 Plättchen je Zelle, 6 × 3 in Feld 1. Wenn das nicht passt, in die Legende von Blatt A
  (`ui/02.json`, neuer Schlüssel) den Hinweis aufnehmen: „Plättchen dürfen Feldname und Skizze verdecken.“

### P5R3-04 (klein) „Die Rollen am Tisch“: Zeugen- und Zusatzrollen-Absätze beginnen mit doppeltem Namen

- **Besetzung:** ab 7 Personen (belegt bei 10 und 20, w und m).
- **Ort:** `90-aufloesung-versiegelt.pdf` S. 8 (10 P.) bzw. S. 7–9 (20 P.).
- **Zitat:** „Lejla Lejla kauerte allein am rechten Buffettisch.“ – „Tim Tim steckte trotz Warnung die
  Kaffeemaschine in seine alte Mehrfachsteckdose“ – (20 P.) „Tugba Tugba hatte nichts zu verbergen.“
- **Problem:** Das fette Etikett ist bei Rollen ohne Fassung nur der Name, und der Vorlesetext beginnt mit demselben
  Namen. Bei den Verdächtigen ist das Etikett als solches erkennbar („Ahmet · Fassung WW4 Ahmet hatte …“).
- **Wirkung am Tisch:** Der Block ist mit „VORLESEN“ markiert. Ab 14 Personen liest jede Person ihren Absatz selbst.
  Man stolpert über „Lejla Lejla …“.
- **Vorschlag:** `aufloesung.dart` Z. 371: für Rollen ohne Fassung ein eigenes Etikett, neuer Schlüssel in
  `ui/90.json` `"rollenAmTisch.platz": "{name} · Platz {platz}"`, also „**Lejla · Platz 5** Lejla kauerte …“; oder
  das Etikett auf eine eigene Zeile über den Absatz setzen.

### P5R3-05 (klein) Ablauf nennt ab 12 Personen „Zeugenstreifen auslegen“, obwohl es keine Streifen gibt

- **Besetzung:** 12–20 Personen (belegt bei 12 und 20, w).
- **Ort:** `00-erzaehlerheft.pdf` S. 3, Tabelle „Ablauf mit Minuten“, Schritt 6.
- **Zitat:** „6 Lageplan-Führung, Marker setzen, Zeugenstreifen auslegen 8“
- **Problem:** Ab 12 Personen gibt es kein Abwesenheitsblatt. Teileliste, „Was an wen geht“, Lageplan-Führung S. 8 und
  „Aufbau jeder Runde“ lassen die Streifen dort richtig weg, nur der Schrittname nicht.
- **Wirkung am Tisch:** Der Erzähler sucht beim Aufbau Streifen, die nicht gedruckt sind. Kurze Verunsicherung.
- **Vorschlag:** `erzaehlerheft.json`, `ablauf`, Schritt 6, `name`:
  „Lageplan-Führung, Marker setzen{ab:12||, Zeugenstreifen auslegen}“.

### P5R3-06 (klein) Abwesenheitsblatt: Das Erzählerheft verweist auf eine Faltanleitung, die auf dem Blatt fehlt

- **Besetzung:** 6–11 Personen (belegt bei 6 und 10, w und m).
- **Ort:** `00-erzaehlerheft.pdf` S. 2 und `02-tisch.pdf` letzte Seite (Abwesenheitsblatt).
- **Zitat:** Erzählerheft: „Schneide das Abwesenheitsblatt in Streifen und falte jeden Streifen so, wie es auf dem
  Blatt steht.“ – Auf dem Blatt steht am Falz nur „Hier falten“.
- **Problem:** Die Richtung fehlt: Nach MECH 5.2 wird mit der Druckseite außen gefaltet, sodass das Etikett oben liegt
  und das gedrehte Protokoll nach unten zeigt. Die Karten in Teil 20 sagen die Richtung ausdrücklich („Falten: das obere
  Feld nach hinten, das graue Feld nach vorn über diesen Text.“), die Streifen nicht.
- **Wirkung am Tisch:** Wer nach vorn faltet, legt das Etikett nach innen. Beim Auslegen muss man den Streifen dann
  aufklappen und sieht das Protokoll, das bis zum Ortstermin verdeckt bleiben soll (E7).
- **Vorschlag:** `tisch.dart` (Falzband der Streifen, Z. 1541) statt des gemeinsamen Schlüssels `falten` einen
  eigenen Schlüssel in `ui/02.json`: `"streifen.falten": "Hier nach hinten falten, Etikett bleibt oben"`. Falls das in
  6,5 pt nicht in das Band passt, in `erzaehlerheft.json` (vorbereitung, Teil 02) schreiben: „…und falte jeden Streifen
  an der Linie ‚Hier falten‘ nach hinten. Das Etikett liegt oben, das Protokoll verdeckt darunter.“

### P5R3-07 (klein) Teil 90 „Zum Nachlesen“: Pflicht-Auslöser in der Du-Form unter einer Überschrift in der dritten Person

- **Besetzung:** alle (6, 10, 20; w und m).
- **Ort:** `90-aufloesung-versiegelt.pdf`, „Pflicht-Auslöser der heute gespielten Rollen“ (10 P.: S. 9–10).
- **Zitat:** Spaltenkopf „Sobald einer davon eintrat, musste die Geheimniskarte umgedreht werden“, darunter bei Ahmet
  „(c) Sobald eine Taschenkontrolle bei dir das Bündel Scheine gezeigt hat“ und bei Lejla „4. Liegt eins davon schon in
  Runde 1 offen, drehst du zu Beginn von Runde 2 um. Frühestens in Runde 2.“
- **Problem:** Die Auslöser sind wörtlich aus den Heften übernommen (Du-Form, „dein Marker“, „bei dir“). Die
  Rundensperre steht hier nach Punkt 4, im Heft davor.
- **Wirkung am Tisch:** Beim Nachlesen nach der Auflösung kann man stocken: Wer ist „du“? Das ist nur Kosmetik, der
  Inhalt stimmt.
- **Vorschlag:** `ui/90.json` `zumNachlesen.ausloeser.text` ändern in „Wörtlich aus dem Heft der Rolle. Sobald einer
  davon eintrat, musste sie ihre Geheimniskarte umdrehen.“; in `aufloesung.dart` (_nachlesen) die Zeile
  „Frühestens in Runde N.“ vor die Liste setzen wie im Heft.

## 6. Nicht als Befund gemeldet (bekannt oder entschieden)

Tims Wortbudget, RN7 +10,3 % bei 8 Personen, 8,5/6,5-pt-Beschriftungen (E19), Erzählerheft 16 Seiten (E18),
„Detektiv“ als Rollenbegriff (E20), Kopf „Karten“ und „Seite 1 von 1“ der Einzeldatei, „Was du weißt“ in Teil 12 ohne
Fortsetzungskopf, Rundennamen mit Anführungszeichen; Abweichungen MECH 12a, WELT 0.3, FALL-BIBEL 19.2. Die
scheinbar dickere Linie zwischen den Spalten Fatma/Olli im Ermittlungsbogen bei 120 dpi ist ein Rasterartefakt (bei
300 dpi gleichmäßig). Teile 02 und 20 haben als Schneidebögen keinen Fuß; das ist richtig so.
