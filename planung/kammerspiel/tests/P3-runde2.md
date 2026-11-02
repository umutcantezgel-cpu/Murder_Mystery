# Protokoll 3 – Zeitstrahl- und Orts-Konsistenz (Prüfrunde 2)

Stand 2026-11-01. Geprüft: `bibel/FALL-BIBEL.md` als Ganzes (Integration Runde 1), dazu `bibel/TESTPROTOKOLL.md` (was schon
behoben ist) und `bibel/tests/P3-runde1.md`. Grundlage: `AUFTRAG.md` (A:Zeile), `ENTSCHEIDUNGEN.md`, `verstehen/kanon-olli.md`
(KO), Kanon `content/party/schlosskeller/raeume.json`. Repo nur gelesen. An der Bibel nichts geändert.

Fundstellen: Kennung der Bibel (etwa „WELT 3.4“) und Zeilennummer in `FALL-BIBEL.md` (Z.).

Prüfauftrag (A:130): jede Uhrzeit, jeder Raumname, jede Position und jede Wahrnehmung in allen Teilen gegeneinander und gegen
den Lageplan; Geometrie, Hör-, Seh-, Fühl- und Riechregeln; gleiche Bezeichnungen; keine Rolle an zwei Orten zugleich.

---

## 1. Methode

1. **Geometrie nachgerechnet.** Alle festen Punkte aus WELT 2.3 und die Ost-Saal-Punkte aus KO §3.3 in ein Skript
   (`tests/werkzeug-p3r2/geo.py`, `python3 -I`). Alle Abstände aus WELT 2.8, MECH 3.3 (Kartentexte) und MECH 9.11
   (Maßtabelle) nachgerechnet. Neu in dieser Runde: **Sichtlinien gegen die Wandkacheln** x = 7, 10 und 19 (Türen nur in
   Reihe 9).
2. **Tempo** jedes Wegs im Sekundenprotokoll WELT 3.4 gegen „im Dunkeln höchstens 1 m/s, bei Licht 1,5 m/s, rennen 2,5 m/s“.
3. **Uhrzeiten** maschinell gezogen (`tests/werkzeug-p3r2/zeiten.py`) und gegen die Kanon-Liste in WELT 0.2 gehalten; dazu
   alle Uhrzeiten in Worten („kurz vor zwölf“, „zehn vor zwölf“, „halb sieben“, „kurz nach zwölf“) von Hand gegen die
   Regeln in WELT 0.2 und gegen den Zeitstrahl.
4. **Hören** jedes Satzes 23:50 bis 0:00:20 gegen WELT 2.7 und 5.1, dann gegen jede Stelle in RK, ZG, ZR, wo eine Rolle sagt,
   was sie gehört hat.
5. **Positionen gekreuzt**: je Person alle Ortsangaben 18:00 bis 0:15 aus allen Kapiteln in eine Zeile.
6. **Bezeichnungen** gezählt: Varianten wie „Ostsaal“, „Thekenklappe“, „Kaminnische“, „Toilette im Turm“, „Sicherungskasten im
   Kaminsaal“.
7. **Runde-1-Befunde nachgeprüft**: ob jede Behebung aus P3-01 bis P3-24 an allen Stellen angekommen ist.
8. **Wortlaute nach dem Umdrehen** der vier Verdächtigen (RK 1.8, RK 8.1) gegen die eigene offene Karte (R-03).

---

## 2. Geometrie (nachgerechnet)

| Strecke | Bibel sagt | gerechnet | Ergebnis |
|---|---|---|---|
| Kerzen → Vorratsraumtür / Klappe / vor der Theke West | 1,4 / 2,2 / 2,2 | 1,41 / 2,24 / 2,24 | stimmt |
| Eiskübel → Vorratsraumtür | 4,2 | 4,24 | stimmt; nur Umriss (Grenze 3 m), siehe P3R2-08 |
| Marek → Vorratsraumtür / Eiskübel | 3,2 / 2,0 | 3,16 / 2,00 | stimmt |
| Ahmet / Damir → Eiskübel | 2,2 / 1,9 | 2,24 / 1,89 | stimmt |
| Ostende (Herr Schneider 23:57) → Olli / Ahmet / Marek / Tim / Joanna / Lejla | 1,4 / 1,0 / 1,4 / 2,2 / 1,0 / 4,5 | 1,41 / 1,00 / 1,41 / 2,24 / 1,00 / 4,47 | stimmt |
| Kaffeemaschine (Herr Schneider 23:58:02) → Ahmet / Marek / Damir / **Olli / Tim** | nur Ahmet, Marek, Damir hören | 2,00 / 1,00 / 2,04 / **2,24 / ≈ 2,0** | **Olli und Tim fehlen (P3R2-12)** |
| Tür zum Ost-Saal → Ostende / Eiskübel / Kopf der Tafel / Klappe / Emine | 1,0 / 2,2 / 3,2 / 8,0 / 8,9 | 1,00 / 2,24 / 3,16 / 8,00 / 8,94 | stimmt |
| Handykorb → Kopf der Tafel / Tür / Ehrenplatz | 2,8 / 5,8 / – | 2,83 / 5,83 / 4,00 | stimmt |
| Tafel Westseite (Aylin) / Ostseite (Azra) → Kopf der Tafel | – | 3,16 / 3,61 | nicht in WELT 2.3 (P3R2-01) |
| Tim am Kasten → Klappe / Steinbogen / Eiskübel / Cans Weg | 2,2 / 2,2 / 8,2 / 1,0 | 2,24 / 2,24 / 8,25 / 1,00 | stimmt (Sicht zur Klappe: P3R2-10) |
| Klappe → hinter dem linken Buffettisch | 4,0 | 4,00 | stimmt |
| Steinbogen → Klappe / vor die Bogentür | 4,0 / 5,1 | 4,00 / 5,10 | stimmt |
| Vorratsraumtür → Klappe (hinter der Theke) | 4,2 | 4,16 | stimmt (P3-07 angekommen) |
| **Vorratsraumtür → Steinbogen** | **„neun Meter“ (MECH 9.11)**; 8,2 (WELT 2.8) | **8,16** | **Widerspruch, Rest von P3-07 (P3R2-08)** |
| Tim Kaffeemaschine → Klappe | „23:58:05 schon an der Klappe“ | 6,0 m in 5 s | **zu schnell (P3R2-11)** |
| Wandbank West → Ascheneimer | 4 | 4,00 | stimmt |

### Sichtlinien (neu in Runde 2)

| von → nach | Bibel sagt | Rechnung | Ergebnis |
|---|---|---|---|
| Tür zum Ost-Saal → Steinbogen | „Den Durchgang sieht man nicht“ (MECH 3.3 FX3, WELT 5.4) | frei: beide Türen liegen in Reihe 9, die Theke sperrt nicht (WELT 2.7) | **Widerspruch (P3R2-09)** |
| Tür zum Ost-Saal → Sicherungskasten | – | Wand bei x = 10 | gesperrt, stimmt |
| Sicherungskasten → Klappe | WELT 2.6 „Stirnlampe erreicht die Klappe“; WELT 5.3 „Die Klappe sieht er nicht (Wand)“ | Wand bei x = 10, y = 8,75 | **WELT 2.6 falsch (P3R2-10)** |
| Steinbogen → Vorratsraumtür | Zeynep sieht die Tür nicht | Wand bei x = 10 | stimmt |
| Steinbogen → Klappe | FK3 „bis zur Theken-Klappe“ | frei | stimmt |
| Ost-Saal-Plätze (Aylin, Azra, Wojtek, Tugba, Handykorb) → Vorratsraumtür | keine Sicht | jede Linie trifft die Wand x = 19 außerhalb der Tür | stimmt; W-23 hält |

---

## 3. Tempo (Sekundenprotokoll WELT 3.4)

| Weg | Strecke | Zeit | Tempo | Ergebnis |
|---|---|---|---|---|
| Olli Kopf der Tafel → Eiskübel (23:56:30–50) | 5,4 m | 20 s | 0,27 m/s | stimmt |
| Ahmet Ost-Saal → hinter das Ostende (23:56:50–58) | ≈ 3,4 m | 8 s | 0,43 m/s | stimmt |
| Fatma linkes Buffet → Klappe (23:57:00–06) | 4,5 m | 6 s | 0,75 m/s | stimmt |
| Herr Schneider Ostende → Kaffeemaschine (23:57:25–30) | 2,2 m | 5 s | 0,45 m/s | stimmt |
| Damir Ost-Saal → Ostende (23:57:30–35) | ≈ 4,7 m | 5 s | 0,94 m/s | stimmt (Licht) |
| **Tim Kaffeemaschine → Klappe (23:58:00–05)** | **6,0 m** | **5 s** | **1,2 m/s** | **zu schnell im Dunkeln (P3R2-11)**; bis zum Kasten 8,4 m in 9 s stimmt |
| Herr Schneider Kaffeemaschine → Tür (23:58:02–05) | 2,2 m | 3 s | 0,75 m/s | stimmt |
| Fatma Klappe → hinter den linken Buffettisch (23:58:01–05) | 4,0 m | 4 s | 1,0 m/s | stimmt |
| Olli Eiskübel → vor der Theke West (23:58:10–15) | 5,0 m | 5 s | 1,0 m/s | stimmt |
| Can Vorratsraumtür → vor die Bogentür (23:58:17–23) | 13,3 m | 6 s | 2,2 m/s | stimmt (rennen) |
| Olli vor der Theke West → Vorratsraumtür (23:58:19–25) | 5,6 m | 6 s | 0,93 m/s | stimmt |
| Olli hinter der Tür → Eiskübel (23:58:36–49) | 12,6 m | 13 s | 0,97 m/s | stimmt (P3-06 angekommen) |
| Olli Eiskübel → rechter Buffettisch, kriechend (23:58:50–54) | 3,2 m | 4–5 s | 0,7 m/s | stimmt |
| Can vor der Bogentür → Wendeltreppe (23:58:24–30) | ≈ 5,6 m | 6 s | 0,93 m/s | knapp; beim Scheppern am Fuß der Treppe, Marker 8b hält |
| Olli Eiskübel → Tim im Durchgang (0:00:30–0:01:00) | 8,8 m | 30 s | 0,3 m/s | stimmt |

---

## 4. Uhrzeiten

### 4.1 Kanon-Liste

Maschinell: Alle H:MM-Angaben gehören zur Kanon-Liste in WELT 0.2. Einzige Ausnahme ist „23:49“ in der Überschrift WELT 3.3
(Spezifikation, nicht gedruckt). Sekunden in Spielertexten: nur in der Marker-Tabelle von Damir (ZR 2.2, Z. 4908, „ab
23:57:30“); die Zusatzhefte haben keine wörtliche Markerzeile, aus der der Generator stattdessen druckt (P3R2-18).

### 4.2 Auftrags-Zeiten (A:130)

| A:130 | Bibel | Ergebnis |
|---|---|---|
| 18:30 Lieferung, Bogentür | 18:30 Tragen, 18:35 Beschlag, 18:45 Wachs, 18:50 Forderung | stimmt; ein Rest „um halb sieben … geschrammt“ bei Tim (P3R2-07) |
| 20:15, 21:00, 23:00, 23:30, 23:40, 23:51, 23:54 | überall gleich | stimmt; 23:00 Hörregel (P3R2-13), Handys (P3R2-14) |
| 23:57 Ahmet, Fatma, Olli an der Theke | Ahmet überall 23:57 außer **Joannas Wissen-Zeile 23:56**; Olli geht in RN7 und bei Joanna „um 23:56“, A:41 sagt „ging um 23:57“ | **P3R2-04** |
| 23:58 Knall + Cans Flucht, 23:58:30 Scheppern, 0:00 Licht, 0:12 Umschlag | überall gleich | stimmt; „kurz nach zwölf“ für 0:12 (P3R2-16) |

### 4.3 Uhrzeiten in Worten

| Wort | Regel / Zeit | Abweichungen |
|---|---|---|
| „kurz vor zwölf“ | WELT 0.2: nur 23:55 bis 23:57 | Detektiv sitzt „kurz vor zwölf“ an der Tafel (war ab 23:55 auf dem Ehrenplatz); Azra und Wojtek nennen den Knall (23:58) „kurz vor zwölf“; Joannas Tarnsatz fragt „kurz vor zwölf in der Saalmitte“ (das war 23:51); Cans I-2.2 nach dem Umdrehen (P3R2-02, P3R2-15) |
| „zehn vor zwölf“ | 23:50 | Tims Frage an Olli legt Ollis Satz von 23:52 auf „zehn vor zwölf“ (P3R2-06) |
| „halb sieben“ | 18:30 Tragen | Tim: „Um halb sieben hat Olli … die Bogentür geschrammt“ (18:35; P3R2-07) |
| „kurz nach zwölf“ | ohne Regel | steht für 0:01, 0:02:40, 0:05, 0:10 **und** 0:12; dieselbe Szene heißt anderswo „0:12 Uhr“ und „zwölf nach zwölf“ (P3R2-16) |
| Viertel nach acht, um neun, um zehn, halb acht, zwanzig nach elf, halb zwölf, zwanzig vor zwölf, Viertel vor zwölf, fünf vor zwölf, drei vor zwölf, zwei vor zwölf, sechs vor zwölf, um sechs, zwölf nach zwölf, halb eins | | stimmig |

---

## 5. Raum-, Zonen- und Feldnamen

| Name (Soll) | Abweichungen |
|---|---|
| Ost-Saal, Buffetsaal, Vorratsraum, Durchgang, Kaminsaal, Turmgang, Windfang | keine Varianten gefunden (0 Treffer für „Ostsaal“, „Buffet-Saal“, „Vorratskammer“, „Kaminraum“) |
| Turm-Toilette, Theken-Klappe, Kamin-Nische, Ascheneimer, Eiskübel, Steinbogen | keine Varianten (P3-18 angekommen) |
| Sicherungskasten | überall „im Durchgang“; „im Kaminsaal“ nur in der Abweichungsliste K-08 |
| Feldnamen Blatt B | WELT 2.1, MECH 10.2, RK x.2, ZG 0.6 gleich (P3-05 angekommen); **ZR ohne wörtliche Markerzeilen** (P3R2-18) |
| Teilfelder 4b und 4d | **beide beanspruchen den Platz vor dem Ostende** (P3R2-17) |
| Ost-Saal, lange Tafel | **„Kopf der Tafel (Westende)“ gegen Kanon-Raster (Nordende)** (P3R2-01) |

---

## 6. Positionen: keine Rolle an zwei Orten zugleich

Je Person alle Angaben 18:00 bis 0:15 aus WELT, MECH, RK, ZG, ZR und den Fassungen gekreuzt.

| Person | Ergebnis |
|---|---|
| Herr Schneider | stimmt (4b 23:51 → Vitrine 23:52:30–23:54:40 → Durchgang 23:55:10 → linkes Buffet 23:55:50 → Ostende 23:56:50 → Kaffeemaschine 23:57:30 → Tür 23:58:05 → Vorratsraum) |
| Ahmet, Fatma, Olli, Can | stimmen; Ollis Gang zum Eiskübel trägt zwei Minutenangaben (P3R2-04) |
| Lejla, Emine, Tim, Joanna, Marek, Zeynep | stimmen |
| Sibel, Damir, Hana, Serkan, Azra, Wojtek, Aylin | stimmen |
| Tugba | **23:00 zugleich Ratespiel im Ost-Saal und Handy von Tim an der Kaffeemaschine holen, während dort der Streit läuft** (P3R2-14) |
| Detektiv | stimmt; nur das Wort „kurz vor zwölf“ passt nicht (P3R2-15) |
| Aylin 18:00 | Einlass im Windfang, Führung zum Sicherungskasten, Zahlung im Ost-Saal, alles „18:00“; grob, kein echter Doppelort. Der Ort der Dankeskarte widerspricht sich (P3R2-19) |
| Kaminsaal 23:40 | niemand festgelegt, der Fatma und Emine durch den Kaminsaal gehen sah oder nicht sah (P3R2-20) |

---

## 7. Wahrnehmung

### 7.1 Hören

Geprüft und stimmig: „Zweitausend, bis zwölf“ (Olli, Ahmet, Marek, Tim, Joanna; nie Zeynep, Lejla, Fatma); „Nicht die alte
Leiste!“ (Buffetsaal, Can, Zeynep an der 3-m-Grenze, Damir); „Buuuh!“ (nur Herr Schneider); „Hab ich dich!“, beide „Stehen
bleiben!“, Scheppern (Buffetsaal, Durchgang, Ost-Saal, Detektiv; nicht Kaminsaal, nicht Turm); Can hört den zweiten Ruf
nicht; Flüstern Ahmet, Fatma, Olli je unter 1,5 m; Eisklirren und Klimpern hört niemand außer Olli.

Lücken: „Ruhe! Ich hol die Notlaterne.“ hören auch Olli und Tim (P3R2-12). Der laute Streit um 23:00 ist nach WELT 2.7 im
Ost-Saal gar nicht hörbar, wird aber in neun Texten als „wird laut“ gehört (P3R2-13). Joanna hört in der Tür einen leisen
Satz aus dem Nachbarraum; die Regel dafür fehlt (P3R2-13).

### 7.2 Sehen und Licht

Stimmig: Lichtregel W-23 (keine Lampe, keine Sichtlinie aus dem Ost-Saal und dem Durchgang auf Tür, Klappe, Eiskübel bis
23:58:54); Marek sieht nur Umriss und Maske; Kauernde sehen nichts; Zeynep sieht die Klappe, nicht die Tür.

Befunde: Joanna sieht aus der Tür zum Ost-Saal bis in den Steinbogen (P3R2-09). Tims Stirnlampe kann die Klappe nicht
erreichen (P3R2-10). Die Maßtabelle sagt zum Blick vom Eiskübel mehr, als die Sehregel hergibt (P3R2-08). Die Ausrichtung
der langen Tafel im Ost-Saal entscheidet, ob Aylin Olli aufstehen sah (P3R2-01).

### 7.3 Fühlen

Ahmet an Mareks Beinen, Damir 0,4 m neben Ahmet, Fatma neben Emine, Olli neben Lejla, Can streift Zeynep: stimmen. Ollis
Wege berühren niemanden (nächster Abstand 3 m).

### 7.4 Riechen

Kerzengeruch bei Hana ab etwa 23:58:45 (P3-03 angekommen). Offen: Der verschmorte Steckplatz um 23:58:00 erzeugt nach
derselben Luftzug-Regel einen Geruch, der Hana vor dem Gesicht erreicht; die Bibel sagt dazu nichts (P3R2-21).

### 7.5 Wissen gegen eigene Wahrnehmung

Fatmas „sofort“-Satz behauptet, sie habe kurz vor zwölf niemanden zur Klappe gehen sehen, obwohl in diesen drei Minuten
Joanna, Herr Schneider und Tim dort vorbeigingen (P3R2-03). Tim sagt zu 23:57 „Bestätigen kann ich da keinen“, obwohl er
Ahmet zwei Meter neben sich sah (P3R2-05). Can widerspricht nach dem Umdrehen seiner eigenen Karte (P3R2-02).

---

## 8. Nachprüfung der Runde-1-Befunde

| Befund | angekommen? | Rest |
|---|---|---|
| P3-01 Ahmet 23:57 | fast überall | Joannas Wissen-Zeile 23:56 (P3R2-04) |
| P3-02 Handys um 23:00 | ja | Ablauf um 23:00 an der Theke (P3R2-14) |
| P3-03 Hanas Geruch | ja | Steckplatz-Geruch (P3R2-21) |
| P3-04 „kurz vor zwölf“ | für 23:59:30/40 ja | vier neue oder übersehene Stellen (P3R2-15) |
| P3-05 Feldnamen | RK, ZG, MECH ja | ZR fehlt (P3R2-18); 4b/4d (P3R2-17) |
| P3-06 Ollis Rückweg | ja | – |
| P3-07 4,2 m | WELT 2.8 und MECH 9.11 Klappe ja | „neun Meter“ zum Steinbogen (P3R2-08) |
| P3-08, P3-09, P3-10, P3-11, P3-12, P3-13, P3-14, P3-15, P3-17, P3-18, P3-19, P3-20, P3-21, P3-22, P3-24 | ja | – |
| P3-16 Tragen und Schaden getrennt | MECH 8.3 ja | Tims „Nach dem Umdrehen“ (P3R2-07) |
| P3-23 Tim sieht Ahmet | Wissen-Tabelle ja | Impuls-Antwort I-1.1 (P3R2-05) |

---

## 9. Befunde

Schwere: **Blocker** = Spiel bricht, Lösung falsch oder Regelverstoß; **mittel** = spürbare Schwäche; **klein** = Feinschliff.
Kein Blocker gefunden.

### P3R2-01 · mittel · Lange Tafel im Ost-Saal: „Kopf der Tafel (Westende)“ widerspricht dem Raster

**Fundstellen:** WELT 2.1 Zone 1 (Z. 653): „lange Tafel mit Kopf der Tafel (Westende)“, „Handykorb auf der Tafel“. WELT 2.3
feste Punkte (Z. 719–721): Kopf der Tafel 22,5/10,5, Handykorb 24,5/12,5; Tafelseiten, Ehrenplatz, Jackenständer, Wandbank Ost
fehlen. Sitzplätze „Tafel, Westseite“ (Aylin: WELT 4.1 Z. 867, ZR 0.5 Z. 4671, ZR 7.2 Z. 5756, ZR 7.5 Z. 5787, ZR 7.6 Z. 5806)
und „Ostseite“ (Azra Z. 865, Detektiv Z. 270, Z. 1312). MECH 10.2 (Z. 6574): Blatt A zeichnet „alle Gegenstände aus WELT §2.1
als Symbol mit Namen“.

**Problem:** Im Kanon-Raster liegt die Tafel nord-südlich auf den Kacheln 22–23 / 11–15 (`raeume.json`, `ost_tafel_22_11` bis
`ost_tafel_23_15`); der Kopf (22,5/10,5) ist das **Nordende**, zur Tür hin. Die Bibel nennt ihn „Westende“. Wer den Plan nach
der Legende zeichnet, legt den Kopf an die Westseite, also direkt neben Aylins Platz. Dann hätte Aylin Olli um 23:56:30 aus
weniger als einem Meter aufstehen sehen müssen; WELT 5.5 sagt, sie sah nichts. Mit dem Nordende ist alles stimmig: Aylin sitzt
3,2 m entfernt, Azra 3,6 m, beide mit Blick nach Süden auf den Ehrenplatz. Zusätzlich liegt der Handykorb (24,5/12,5) neben,
nicht auf der Tafel (Kacheln x 22–23).

**Vorschlag (wörtlich):**
- WELT 2.1, Zone 1, Spalte „Gegenstände“: „lange Tafel von Nord nach Süd, Kopf der Tafel am Nordende zur Tür hin, Sitzplätze
  Westseite und Ostseite; Jackenständer am Eingang (Ahmets schwarze Jacke); Wandtafel mit Ablaufplan an der Ostwand; Handykorb
  am Ostrand der Tafel; Wandbänke; Ehrenplatz der blinden Kuh im Süden; Wojteks Musikbox an der Wandbank Ost. Keine weitere
  Außentür“.
- WELT 2.3, feste Punkte ergänzen: „| Jackenständer | 20,5/8,5 | 1 |“, „| Tafel Westseite (Aylin) | 21,5/13,5 | 1 |“,
  „| Tafel Ostseite (Azra, Detektiv bis 23:55) | 24,5/13,5 | 1 |“, „| Ehrenplatz der blinden Kuh (Detektiv, Tugba) | 24,5/16,5 | 1 |“,
  „| Wandbank Ost (Wojtek, Box) | 25,5/15,5 | 1 |“.
- WELT 5.5, Zeile Ost-Saal, Spalte „Warum“: „schauten nach Süden auf die blinde Kuh; der Kopf der Tafel liegt im Norden, 3 bis
  4 m hinter oder neben ihnen“.

### P3R2-02 · mittel · Can widerspricht nach dem Umdrehen seiner eigenen Karte (RK 1.8)

**Fundstellen:** RK 1.8, Spalte Can: I-2.2 (Z. 2569) „Kurz vor zwölf bin ich durch den Turmgang zur Turm-Toilette hoch.“; I-3.1
(Z. 2571) „Im Turm hört man nichts. Auf einmal war das Licht weg.“ Beide Zeilen ohne Fassung „Karte zu / Karte offen“. Dagegen
Cans Karte (RK 5.8, Z. 3223): „Nach dem Knall dachte ich, sie kommt. Ich bin rausgesprungen […] und bin weggerannt, bis auf die
Turm-Toilette.“ Regeln: RK 1.8 (Z. 2560) „Antworten nach dem Umdrehen sind wahr“; R-03 „Was auf deiner Karte steht, darfst du
danach nicht mehr bestreiten.“

**Problem:** I-3.1 ist ein Impuls der Runde 3. Dann liegt Cans Karte meist schon offen. Can liest aber vor, er sei beim
Lichtausfall oben im Turm gewesen, und erzählt nicht, was er wirklich hörte (Knall, „Ruhe! Ich hol die Notlaterne.“, „Hab ich
dich!“, „Stehen bleiben!“). Das ist eine Lüge gegen die offene Karte, gedruckt im Heft, genau in der Runde, in der Cans Alibi
(M3) über die Reihenfolge entsteht. Dasselbe gilt für I-2.2: Nach der Karte ging Can nicht „kurz vor zwölf“ hoch, sondern nach
dem Knall.

**Vorschlag (wörtlich), je ein Satz, der in beiden Lagen wahr ist (hält die Wortzahl der gleichen Gestalt, RK 7.7: Can +7
Wörter, 139):**
- I-2.2 Can: „Zur Turm-Toilette geht man durch den Turmgang und die Wendeltreppe hoch. Da war ich.“
- I-3.1 Can: „Das Scheppern hab ich nicht gehört. Was danach an der Theke war, weiß ich nicht.“

### P3R2-03 · mittel · Fatmas „sofort“-Satz ist nach dem Zeitstrahl falsch

**Fundstellen:** RK 8.1, Fatma, Spalte „Sofort“ (Z. 2586): „Kurz vor zwölf hab ich niemanden zur Theken-Klappe gehen sehen.“
RK 3.5 Nr. 9 (Z. 2835): „sicher | WELT §3.4 23:54 | sofort“. Dagegen WELT 3.4: 23:55:00–15 geht Joanna „bis an die Tür zum
Durchgang“ und ruft laut (Z. 533); 23:54:40–23:55:50 kommt Herr Schneider aus dem Durchgang über 4a **zu Fatma** (Z. 530);
23:55:30–23:56:00 geht Tim durch Durchgang und Klappe zur Kaffeemaschine (Z. 539). Joannas offenes Wissen (ZG 4.4 Z. 3990) und
Tims offenes Wissen (ZG 3.4 Z. 3795) nennen genau diese Wege.

**Problem:** „Kurz vor zwölf“ heißt nach WELT 0.2 23:55 bis 23:57. In diesen Minuten gingen drei Personen vier Meter vor Fatma
an der Klappe vorbei, eine davon rufend, eine davon direkt zu ihr. Die Quelle des Satzes meint 23:54 (Cans Weg), die Uhrzeit im
Heft meint etwas anderes. Am Tisch sagt Joanna „Ich war um fünf vor zwölf an der Tür zum Durchgang“, und Fatmas freigegebener
„wahrer“ Satz sieht wie eine Lüge aus. Das erzeugt falschen Druck auf eine Unschuldige und verletzt RK 8.1 („Kein Eintrag
‚sofort‘ … widerspricht“).

**Vorschlag (wörtlich):**
- RK 8.1 Fatma, „Sofort“, dritter Satz: „Kurz vor zwölf hab ich Can im Buffetsaal nirgends gesehen.“
- RK 3.5 Nr. 9: „Kurz vor zwölf war Can nicht im Buffetsaal. Um 23:54 achtete sie nicht auf die Theken-Klappe | sicher | WELT
  §3.4 | sofort“.
- Cans Ausweichziel R1 (RK 5.9, Z. 3240) bleibt wörtlich, es passt zum neuen Satz.

### P3R2-04 · klein · Ollis und Ahmets Gang durch die Tür: 23:56 in Joannas Wissen und in RN7

**Fundstellen:** ZG 4.4 Joanna (Z. 3993): „| 23:56 | Olli geht an ihr vorbei aus dem Ost-Saal zum Eiskübel. Kurz darauf geht
Ahmet an ihr vorbei und schlüpft am Ostende hinter die Theke |“. RK 7.5 RN7 (Z. 6431): „Um 23:56 Uhr stehst du auf und gehst an
[Joanna] vorbei zum Eiskübel.“ WELT 0.2 (Z. 130): Ahmets Weg „nie 23:56“. A:41: Olli „ging um 23:57 Uhr zum Eiskübel“.

**Problem:** Die Wissen-Tabelle wird gedruckt (ZG 0.6). Joanna liest Ahmets Weg unter „23:56“, alle anderen Texte sagen 23:57;
das ist der Rest von P3-01. Ollis Gang (23:56:30–50) heißt in RN7 und bei Joanna „23:56“, im Auftrag (Rang 1) „23:57“.

**Vorschlag (wörtlich):**
- ZG 4.4 Joanna, Zeile ersetzen: „| 23:57 | Olli geht an ihr vorbei aus dem Ost-Saal zum Eiskübel. Gleich danach geht Ahmet an
  ihr vorbei und schlüpft am Ostende hinter die Theke | WELT §3.4, W-22 | offen |“.
- RK 7.5 RN7: Zeile 23:54 „| 23:54 | Du setzt dich im Ost-Saal an den Kopf der Tafel. |“; Zeile 23:57 „| 23:57 | Du gehst an
  [Joanna] vorbei zum Eiskübel. Herr Schneider steht am Ostende und sagt leise: ‚Zweitausend, bis zwölf.‘ Hinter der Theke am
  Ostende steht Ahmet. |“ (RN7 wird dadurch 6 Wörter kürzer).
- WELT 0.2, Regel ergänzen: „**Ollis Gang zum Eiskübel** (23:56:30 bis 23:56:50) heißt in Spielertexten ‚um 23:57 Uhr‘ bzw.
  ‚um drei vor zwölf‘ (A:41).“

### P3R2-05 · klein · Tims Impuls-Antwort I-1.1 widerspricht seinem Wissen (Rest von P3-23)

**Fundstellen:** ZG 0.4, Spalte Tim, I-1.1 (Z. 3331): „Um drei vor zwölf stand ich mit dem Rücken zur Theke an der
Kaffeemaschine. Bestätigen kann ich da keinen.“ Dagegen ZG 3.4 (Z. 3796): „23:57 | Ahmet schlüpft am Ostende hinter die Theke,
zwei Meter neben ihm […] | offen“; WELT 5.8 (Z. 1066).

**Problem:** Nennt Ahmet (etwa beim „Zeitstempel“ oder bei „Beleg bitte!“) Tim als Zeugen, verneint Tim, was er offen weiß.
Ahmets wahrer Ort gerät grundlos ins Wanken.

**Vorschlag (wörtlich):** ZG 0.4, Tim, I-1.1: „Bei Ahmet: ‚Ja. Um drei vor zwölf ist Ahmet zwei Meter neben mir am Ostende
hinter die Theke.‘ Sonst: ‚Um drei vor zwölf stand ich mit dem Rücken zur Theke an der Kaffeemaschine. Bestätigen kann ich da
keinen.‘“

### P3R2-06 · klein · Tims Frage legt Ollis Satz von 23:52 auf „zehn vor zwölf“

**Fundstellen:** ZG 3.7, Runde 3, Ziel 1 (Z. 3888): „Olli, um zehn vor zwölf wolltest du mir Eis holen.“ und „Olli, um zehn vor
zwölf hast du gesagt: ‚Ich hol dir Eis. […]‘“. Dagegen im selben Heft ZG 3.6 (Z. 3875): „Um 23:52 Uhr hat Olli zu mir gesagt
[…]“; WELT 3.4 Z. 522.

**Problem:** Im selben Heft stehen zwei Zeiten für denselben Satz. Um zehn vor zwölf war der Finger, der Satz kam um 23:52.

**Vorschlag (wörtlich):** „Karte zu: ‚Olli, um 23:52 Uhr wolltest du mir Eis holen. Gekommen ist es erst nach dem Licht. Wo
warst du so lange?‘ Karte offen: ‚Olli, um 23:52 Uhr hast du gesagt: Ich hol dir Eis. Und dann red ich mit Schneider. Das Eis kam
erst nach dem Licht. Was war dazwischen?‘“

### P3R2-07 · klein · Tim legt den Schaden an der Bogentür auf halb sieben (Rest von P3-16)

**Fundstellen:** ZG 3.6 „Nach dem Umdrehen“ (Z. 3871): „Um halb sieben hat Olli beim Tragen die Bogentür geschrammt.“ ZG 3.1
Beziehungen (Z. 3756, Spezifikation): „Tim hat um halb sieben mit ihm getragen und ihm das Möbelwachs gegeben“. Dagegen WELT 3.3:
18:35 Beschlag, 18:45 Wachs; RN7 und Ollis Karte: 18:35.

**Problem:** Gleicher Fehler wie P3-16. Am Tisch nennt Tim 18:30, Ollis Karte 18:35.

**Vorschlag (wörtlich):** ZG 3.6: „Um 18:35 Uhr hat Olli beim Tragen die Bogentür geschrammt. Ein Beschlag ist aus der Wand
gerissen.“ ZG 3.1: „Tim hat um halb sieben mit ihm getragen und ihm um 18:45 Uhr das Möbelwachs gegeben“.

### P3R2-08 · klein · Maßtabelle: „neun Meter“ und der Blick vom Eiskübel (Rest von P3-07)

**Fundstellen:** MECH 9.11 Teil A (Z. 2320): „| Vorratsraumtür | Steinbogen | ‚neun Meter‘ |“; (Z. 2313): „| Eiskübel |
Vorratsraumtür | ‚gut vier Meter‘ | ‚Bis zum Knall hell. Danach sieht man vom Eiskübel nur, was im Kerzenlicht an der Tür ist.‘ |“.
Dagegen WELT 2.8 (Z. 831): Vorratsraumtür → Steinbogen 8,2 m; WELT 2.7: Gesicht im Kerzenlicht nur bis 3 m.

**Problem:** (1) Die neun Meter stammen aus dem alten Wert 5,0 m für Tür → Klappe; nach P3-07 sind es 4,2 + 4,0 = 8,2 m. Die
Maßtabelle wird vorgelesen („Maßband“). (2) „nur, was im Kerzenlicht an der Tür ist“ klingt, als erkenne man vom Eiskübel
Personen. Nach der Sehregel sieht man aus 4,2 m nur Umrisse und das Leuchten. Spieler könnten daraus schließen, Olli habe Can
erkannt; Ollis wahrer Satz „Erkannt hab ich nur das Leuchten“ stünde dann gegen die Tabelle.

**Vorschlag (wörtlich):** „| Vorratsraumtür | Steinbogen | ‚gut acht Meter‘ | ‚Dunkel.‘ |“ und „| Eiskübel | Vorratsraumtür | ‚gut
vier Meter‘ | ‚Bis zum Knall hell. Danach sieht man vom Eiskübel an der Tür im Kerzenlicht nur Umrisse und leuchtende Farbe.‘ |“

### P3R2-09 · klein · Aus der Tür zum Ost-Saal sieht man in den Durchgang

**Fundstellen:** MECH 3.3 FX3 (Z. 1565): „Den Durchgang sieht man nicht.“ WELT 5.4 (Z. 988–989): „Den Durchgang sieht sie nicht“.
WELT 2.8 (Z. 824). Geometrie WELT 2.3: Tür zum Ost-Saal 19/9, Klappe 11/9, Tür zum Durchgang 10/9, Steinbogen 7/9; WELT 2.7:
„Wände sperren, Theke und Tische nicht.“

**Problem:** Beide Türen und der Steinbogen liegen in derselben Kachelreihe 9. Die Sichtlinie von 19,5/9,5 nach 7,5/9,5 läuft
über die Theke und durch beide offenen Türen, ohne eine Wand zu schneiden (Skript, Abschnitt 2). Bei Licht sieht Joanna einen
Streifen des Durchgangs und Zeynep im Steinbogen, 12 m entfernt. Der Kartensatz ist damit geometrisch falsch. Für die Lösung ist
es harmlos: Can war im Vorratsraum, Joannas Liste nennt Zeynep ohnehin „im Bogen“.

**Vorschlag (wörtlich):** FX3, „Was du findest“, zweiter Satz: „Aus der Tür sieht man bei Licht den ganzen Buffetsaal: Theke,
Eiskübel, beide Buffettische und die Theken-Klappe. Durch die offene Tür neben der Klappe sieht man ein Stück in den Durchgang,
bis zum Steinbogen. Den Sicherungskasten sieht man nicht.“ WELT 5.4, dritter Satz: „Durch die Tür neben der Klappe sieht sie
einen Streifen des Durchgangs bis zum Steinbogen, den Sicherungskasten nicht. Zeynep steht im Bogen.“ WELT 2.8, Bedeutung der
Zeile „Tür zum Ost-Saal“: „Joanna sieht um 23:57 den ganzen Buffetsaal und durch die zweite Tür bis zum Steinbogen“.

### P3R2-10 · klein · Tims Stirnlampe „erreicht die Klappe“, aber die Wand sperrt

**Fundstellen:** WELT 2.6 (Z. 782): „Tims Stirnlampe | Durchgang (6) | ab 23:59:40 | 3 m | erreicht die Klappe (2,2 m), nicht den
Eiskübel (8,2 m)“; MECH 9.11 Prüfung (Z. 2328–2330) dasselbe. Dagegen WELT 5.3 (Z. 983): „Die Klappe sieht er nicht (Wand neben der
Tür)“.

**Problem:** Von 9,5/8,5 zur Klappe 11,5/9,5 schneidet die Linie die Wand x = 10 bei y = 8,75, also neben der Tür. Zwei Stellen
der Bibel sagen Gegensätzliches. Für W-23 folgenlos (Olli ist ab 23:58:54 bei Lejla), aber die Licht-Tabelle ist die Quelle für
Teil 01 und Maßband.

**Vorschlag (wörtlich):** WELT 2.6, letzte Spalte: „zeigt Zeynep im Steinbogen (2,2 m); die Klappe nicht (Wand neben der Tür),
den Eiskübel nicht (8,2 m)“. MECH 9.11 Prüfung: „die Stirnlampe erreicht weder die Klappe (Wand) noch den Eiskübel (8,2 m) noch
die Vorratsraumtür.“

### P3R2-11 · klein · Tim ist um 23:58:05 noch nicht an der Klappe

**Fundstelle:** WELT 3.4 (Z. 560): „23:58:05 | 4c | Herr Schneider zieht die angelehnte Vorratsraumtür auf. […] Tim ist schon an
der Klappe“.

**Problem:** Von der Kaffeemaschine (16,5/8,5) bis zur Klappe (11,5/9,5) sind es hinter der Theke 6,0 m (die gerade Linie
schneidet die Theke). Im Dunkeln höchstens 1 m/s: In 5 s schafft Tim 5 m, also bis 11,5/8,5. P3 Runde 1 hatte das so
berechnet; der Text sagt mehr.

**Vorschlag (wörtlich):** „Tim ist schon am Westende hinter der Theke, einen Schritt vor der Klappe.“

### P3R2-12 · klein · „Ruhe! Ich hol die Notlaterne.“ hören auch Olli und Tim

**Fundstelle:** WELT 5.1 (Z. 911): „„Ruhe! Ich hol die Notlaterne.“ (laut, Tumult) | 23:58:02 | nur bis 3 m: Ahmet, Marek, Damir“.

**Problem:** Herr Schneider steht bei diesem Ruf noch an der Kaffeemaschine (16,5/8,5). Olli am Eiskübel ist 2,24 m entfernt,
Tim nach zwei Sekunden Weg nach Westen etwa 2,0 m. Beide liegen unter 3 m. Die Tabelle ist die Prüfgrundlage für alle
„Was hast du gehört?“-Sätze. Folge heute: RN7 und Tims Wissen lassen den Ruf weg; das ist nur eine Lücke, kein Widerspruch.

**Vorschlag (wörtlich):** WELT 5.1, Spalte Buffetsaal: „nur bis 3 m: Ahmet, Marek, Damir, Olli (2,2 m), Tim (rund 2 m, schon im
Gehen)“. Tims Wissen ZG 3.4, Zeile 23:58, ergänzen: „Hinter ihm ruft Herr Schneider: ‚Ruhe! Ich hol die Notlaterne.‘“

### P3R2-13 · klein · Hörregeln decken zwei benutzte Fälle nicht ab (23:00 im Ost-Saal, Joanna in der Tür)

**Fundstellen:** WELT 2.7 (Z. 796, 809–810): „laut: im selben Raum; im angrenzenden Raum nur bis 3 m von der Tür“; „Im Ost-Saal hört
man … Leises und Lautes nicht“. WELT 5.6 (Z. 1035): „23:00 | Olli | ‚Bis Mitternacht. Sonst ruf ich die Polizei!‘ | laut | Tim
(Inhalt); Ost-Saal nur ‚Herr Schneider wird laut‘“. Davon abhängig: MECH 1.5 (Z. 1290), Emines Domino-Hinweis (MECH 4.2 Z. 1725,
ZG 2.6), WW4 (Z. 6340), Sibel (Z. 4764), Damir (Z. 4938), Tugba (Z. 5948), die Ziele von Ahmet (Z. 2745), Lejla (Z. 3512), Emine
(Z. 3685), Aylin (Z. 5857). WELT 5.1 (Z. 908): Joanna hört „Zweitausend, bis zwölf“ (leise) „in der Tür, 1 m“, Spalte Ost-Saal.

**Problem:** (1) Nach der eigenen Regel hört im Ost-Saal niemand einen „lauten“ Ruf aus dem Buffetsaal. Zehn Texte stützen sich
aber darauf, dass man ihn dort hörte, nur ohne Worte. (2) „Leise“ gilt nur im selben Raum. Joanna steht in der Tür des Ost-Saals,
Herr Schneider im Buffetsaal; die Regel, nach der sie trotzdem hört, steht nirgends.

**Vorschlag (wörtlich):** WELT 2.7, zwei Zeilen ergänzen: „| in der Tür | Wer in einer offenen Tür steht, hört wie in beiden
Räumen (Joanna 23:55:40 bis 23:57:30). |“ und „| 23:00 | Herr Schneiders Ausbruch um 23:00 ist sehr laut. Im Ost-Saal hört man
durch die offene Tür, dass er brüllt; die Worte gehen im Ratespiel unter. Wer im Buffetsaal ist, versteht sie (Tim). |“
WELT 5.6, Zeile 23:00, Lautstärke: „sehr laut (Worte nur im Buffetsaal verständlich)“.

### P3R2-14 · klein · Tugba holt Tims Handy mitten im Streit an der Theke

**Fundstellen:** WELT 3.3 (Z. 502–503): beide Zeilen „23:00“: lauter Streit vor der Theke, Tim an der Kaffeemaschine hört alles;
„Für ihr Ratespiel sammelt Tugba alle Handys in den Handykorb ein, auch Tims an der Kaffeemaschine“. ZR 8.5 Tugba (Z. 5948):
dasselbe, dazu „Herr Schneider wird an der Theke laut, die Worte versteht man nicht“. K-23 (Z. 165).

**Problem:** Holt Tugba um 23:00 Tims Handy an der Kaffeemaschine, steht sie 2 m neben dem Streit und versteht jedes Wort.
Ihr Heft sagt das Gegenteil, und sie ist die Rolle, die alles offen sagt. Dasselbe gilt für Ollis Handy (er steht vor der
Theke).

**Vorschlag (wörtlich):** WELT 3.3, die Handy-Zeile vor die Streit-Zeile stellen und fassen: „| 23:00 | Ost-Saal (1) | Tugba, alle |
Zu Beginn ihres Ratespiels, bevor Herr Schneider an der Theke laut wird, sammelt Tugba alle Handys in den Handykorb ein, auch Tims
und Ollis an der Kaffeemaschine und das des Detektivs. Nur Joanna behält ihres als Fotografin. Vor 0:05 holt sich niemand seins
zurück (K-23) |“. ZR 8.5, Zeile 23:00: „leitet im Ost-Saal ihr Ratespiel. Vorher sammelt sie alle Handys ein, auch Tims an der
Kaffeemaschine; nur Joanna behält ihres. Als Herr Schneider danach an der Theke laut wird, sitzt sie wieder im Ost-Saal und
versteht die Worte nicht“.

### P3R2-15 · klein · „kurz vor zwölf“ an vier Stellen gegen WELT 0.2 (Rest von P3-04)

**Fundstellen:** MECH 1.6 Detektiv (Z. 1312): „Kurz vor zwölf sitzt du im Ost-Saal an der langen Tafel, auf der Ostseite.“ (ab
23:55 auf dem Ehrenplatz). ZR 5.8 Azra R3-1 (Z. 5527): „Kurz vor zwölf war es wieder dunkel.“ (23:58). ZR 6.8 Wojtek R1-1
(Z. 5692): „Kurz vor zwölf hat es hinter der Theke ordentlich geknallt.“ (23:58). ZG 4.6 Joanna, Tarnsatz-Auslöser (Z. 4044): „was
du kurz vor zwölf in der Saalmitte gemacht hast“ (Saalmitte war 23:51).

**Problem:** WELT 0.2 legt „kurz vor zwölf“ auf 23:55 bis 23:57. Zu diesen Zeiten saß der Detektiv nicht an der Tafel, knallte
nichts, und Joanna stand nicht in der Saalmitte.

**Vorschlag (wörtlich):** MECH 1.6: „Ab zehn vor zwölf sitzt du im Ost-Saal an der langen Tafel, auf der Ostseite.“ Azra: „Um zwei
vor zwölf war es wieder dunkel.“ Wojtek: „Um zwei vor zwölf hat es hinter der Theke ordentlich geknallt.“ Joanna, Spalte „Wenn
jemand fragt“: „was du gegen zehn vor zwölf in der Saalmitte gemacht hast“.

### P3R2-16 · klein · „kurz nach zwölf“ steht auch für 0:10 und 0:12

**Fundstellen:** WELT 7.3 Azra Rand-Indiz (Z. 426): „Kurz nach zwölf, als das Licht wieder an war, hat Ahmet am Kamin einen
gefalteten Umschlag in den Ascheneimer geworfen.“ ZR 5.13 (Z. 5571): „Kurz nach zwölf sah sie, wie Ahmet den leeren Umschlag in den
Ascheneimer warf.“ ZR 5.6 (Z. 5475) und ZR 0.5 I-3.3 (Z. 4677): Skizzenblock „kurz nach zwölf“ (0:10). Dagegen ZR 5.6 Rand-Indiz
(Z. 5478) „Um 0:12 Uhr“, RK 1.8 I-3.3 „Um zwölf nach zwölf“, MECH 8.3 „zwölf nach zwölf“.

**Problem:** Dieselbe Szene trägt drei Zeitangaben. „Kurz nach zwölf“ steht sonst für 0:01 bis 0:05 (Handys, Can auf der
Wandbank, Serkans Rückkehr). Am Tisch klingt Azras „kurz nach zwölf“ wie die Minuten gleich nach dem Licht.

**Vorschlag (wörtlich):** WELT 0.2 neue Regel: „**‚kurz nach zwölf‘** heißt in Spielertexten 0:00 bis 0:05. Ahmet am Ascheneimer
heißt immer ‚um 0:12 Uhr‘ bzw. ‚zwölf nach zwölf‘, Azras Skizzenblock ‚um 0:10 Uhr‘ bzw. ‚zehn nach zwölf‘.“ WELT 7.3: „Um zwölf
nach zwölf hat Ahmet am Kamin einen gefalteten Umschlag in den Ascheneimer geworfen.“ ZR 5.13: „Um zwölf nach zwölf sah sie, wie
Ahmet den leeren Umschlag in den Ascheneimer warf.“ ZR 5.6: „Um zehn nach zwölf hab ich im Kaminsaal meinen Skizzenblock von der
Wandbank geholt und mich da hingesetzt.“ ZR 0.5 I-3.3 Azra: „Um zehn nach zwölf hab ich meinen Skizzenblock von der Wandbank im
Kaminsaal geholt.“

### P3R2-17 · klein · Teilfelder 4b und 4d beanspruchen beide den Platz vor dem Ostende

**Fundstelle:** WELT 2.1 Zone 4 (Z. 656): „4b Vor der Theke mit Eiskübel (vor der Mitte und dem Ostende)“ und „4d Theke Ostende (das
offene Ostende, davor und dahinter, …)“.

**Problem:** „Vor dem Ostende“ gehört nach dem Wortlaut zu 4b und zu 4d. Der Eiskübel steht „vor dem Ostende“ (WELT 2.4) und
gehört zu 4b; Herr Schneider steht um 23:57 „am Ostende“ (4d). Der Klammertext wandert in die Legende von Blatt A. Wo die
Grenze liegt, entscheidet, ob Ollis Stufe-2-Marker und Herrn Schneiders Marker auf demselben Feld landen dürfen.

**Vorschlag (wörtlich):** „4b Vor der Theke mit Eiskübel (der ganze Streifen vor der Theke vom Westende bis zum Ostende, mit dem
Eiskübel)“ und „4d Theke Ostende (die offene Kachel am Ostende und dahinter, mit der Anrichte Ost: Saft, Gläser, Servietten)“.

### P3R2-18 · klein · Zusatzhefte haben keine wörtliche Markerzeile

**Fundstellen:** ZR 0.7 (Z. 4706) nennt „Deine Marker“ als Abschnitt des Zusatzhefts, ohne Wortlaut. Für die Rollen 1–10 gibt es
ihn (RK x.2, ZG 0.6 Z. 3385–3394). ZR 2.2 Damir (Z. 4908), Spalte „wahr“: „ab 23:57:30 unterwegs zum Ostende“.

**Problem:** P3-05 verlangte die Feldnamen wörtlich „in allen Heften“. Ohne festen Wortlaut setzt der Generator die
Marker-Tabelle ein; bei Damir stehen dann Sekunden im Spieltext (WELT 0.2).

**Vorschlag (wörtlich), neuer Absatz in ZR 0.7 „Deine Marker (wörtlich, Feldnamen nach WELT §2.1)“:** Sibel und Hana: „Marker
23:57: Kaminsaal (7). Marker Scheppern: Kaminsaal (7). Beide stimmen.“ · Damir: „Marker 23:57: Ost-Saal (1). Marker Scheppern:
Theke Ostende (4d). Beide stimmen.“ · Serkan: „Marker 23:57: Windfang (W). Marker Scheppern: Windfang (W). Beide stimmen.“ · Azra,
Wojtek, Aylin, Tugba: „Marker 23:57: Ost-Saal (1). Marker Scheppern: Ost-Saal (1). Beide stimmen.“

### P3R2-19 · klein · Wo die Dankeskarte unterschrieben wurde

**Fundstellen:** WELT 3.3 (Z. 488): „18:00 | Ost-Saal (1) | Aylin, Tugba | Mit der Gästeliste lässt Aylin heimlich alle eine
Dankeskarte … unterschreiben“. Dagegen „beim Einlass“ (Einlass = Windfang, WELT 3.3 Z. 485–486): MECH 1.5 Zusatzsatz (Z. 1299),
ZR 0.1 ZG-14 (Z. 4555), ZR 7.4 (Z. 5771) „Beim Einlass … Dabei hast du heimlich alle […] unterschreiben lassen“, ZR 8.4 (Z. 5932),
Tugbas Karte (ZR 8.7).

**Problem:** Zwei Orte für dieselbe Szene. Am Tisch fragt jemand „Wo?“ und bekommt zwei Antworten.

**Vorschlag (wörtlich):** WELT 3.3, Spalte Ort dieser Zeile: „Windfang (W), beim Einlass“; Ereignis: „Mit der Gästeliste lässt
Aylin beim Einlass heimlich alle eine Dankeskarte für Herrn Schneider unterschreiben, während er die Gäste begrüßt. Tugba hat die
Karte gebastelt und verwahrt sie danach in ihrem Notizbuch“. Alle anderen Stellen bleiben.

### P3R2-20 · klein · Wer im Kaminsaal sah Fatma und Emine um 23:40?

**Fundstellen:** WELT 3.3 (Z. 505–507): 23:30 Hana wischt Ruß; 23:40 Fatma und Emine an der Vitrine („Ihr geht zurück zum linken
Buffet“, RK 7.4 Z. 6385); 23:45 Zeynep holt Gebäck „für sich und Can“, beide essen es „an der langen Tafel im Kaminsaal“ (RK 7.6
Z. 6483). WELT 3.4, Stand 23:50 (Z. 511–515): Can, Zeynep an der Tafel, Sibel auf der Wandbank Süd.

**Problem:** Fatma und Emine gehen um 23:40 zweimal durch den Kaminsaal zum Turmgang und zurück. Für Sibel, Can und Zeynep
legt die Bibel nicht fest, wo sie da waren. Fragt jemand „Wer hat Fatma um 23:40 Richtung Turmgang gehen sehen?“, hat keine
dieser Rollen eine Antwort, und eine ehrliche Vermutung kann Fatmas Geheimnis vor der Zeit öffnen.

**Vorschlag (wörtlich):** WELT 3.3, neue Zeile: „| 23:40 | Kaminsaal (7) | Hana | Im Kaminsaal ist nur Hana; sie wischt mit dem
Gesicht zur Wand Ruß ab. Fatma und Emine gehen unbemerkt durch. Can und Zeynep setzen sich erst nach 23:45 mit dem Gebäck an die
lange Tafel, Sibel kommt kurz vor 23:50 auf die Wandbank Süd |“. In WELT 5.7 ergänzen: „Fatmas Weg durch den Kaminsaal um 23:40
sieht niemand außer Emine.“

### P3R2-21 · klein · Riechen: Der verschmorte Steckplatz hat keine Regel

**Fundstellen:** WELT 3.4 (Z. 555): „Knall. Ein Steckplatz verschmort“; MR4: „Ein Steckplatz ist schwarz verschmort.“ WELT 2.7
(Z. 801): „Luftzug seit 23:30: Buffetsaal → Durchgang → Kaminsaal. Gerüche halten 90 s“. WELT 3.6 (Z. 632): Hana riecht die
Kerzen ab etwa 23:58:45.

**Problem:** Nach derselben Regel erreicht der Geruch des Steckplatzes (15,5 m Weg) Hana um etwa 23:58:16, also vor dem Gesicht.
Die Bibel nennt ihn nirgends. Fragt jemand Hana „Hast du noch etwas gerochen?“, fehlt die Antwort; und wer nachrechnet, sieht eine
Lücke in Hanas Reihenfolge „erst das Gesicht, dann der Geruch“.

**Vorschlag (wörtlich):** WELT 2.7, Zeile Riechen ergänzen: „Der verschmorte Steckplatz qualmt nur einen Augenblick; sein Geruch
bleibt hinter der Theke und erreicht den Durchgang und den Kaminsaal nicht. Im Kaminsaal riecht man in der Tatnacht nur die
ausgeblasenen Kerzen.“

### P3R2-22 · klein · Zwei Ortsabweichungen vom Auftrag fehlen in MECH 12a

**Fundstellen:** A:52: Marek sah „an der Schwelle zum Durchgang, dass das leuchtende Gespenstergesicht bereits vor dem lauten
Scheppern an ihm vorbei in Richtung Kaminsaal rannte“. A:54: Zeynep sah Can, „während hinter ihm an der Theke noch jemand mit Herrn
Schneider stritt“. Bibel: Marek steht am Ostende und sieht das Gesicht aus 3,2 m zur Klappe verschwinden (WELT 5.3, W-06); Zeynep
hört nur Herrn Schneiders zweiten Ruf (WELT 5.3 Z. 964). MECH 12a (Z. 6713 ff.) führt beide nicht.

**Problem:** Die Liste soll alle Abweichungen vom Wortlaut des Auftrags für den Besitzer sammeln (P5-M7). Diese zwei betreffen
Ort und Wahrnehmung der zwei wichtigsten Can-Zeugen.

**Vorschlag (wörtlich), zwei Zeilen in MECH 12a:** „| A:52 | Marek sieht ‚an der Schwelle zum Durchgang‘ das Gesicht ‚an ihm
vorbei‘ rennen | Marek steht am Ostende hinter der Theke und sieht im Kerzenlicht aus gut drei Metern das Gesicht herausspringen
und zur Klappe verschwinden | A:52 nennt zwei Orte acht Meter auseinander; Ahmets Alibi braucht Marek am Ostende (W-06, ABG §3.6) |“
und „| A:54 | Zeynep hört, dass ‚noch jemand mit Herrn Schneider stritt‘ | Zeynep hört nur Herrn Schneiders zweiten Ruf | das
Gespräch an der Tür ist leise und acht Meter entfernt, ohne Sicht (WELT §5.3) |“.

---

## 10. Was hält (bestätigt)

- **Cans Alibi** ist geometrisch und akustisch sauber: an Tim 10 s, durch den Bogen 9 s, vor der Bogentür 7 s vor dem Scheppern;
  der zweite Ruf (23:58:22) liegt zwischen Cans Durchlauf und dem Scheppern; Tim und Zeynep hören beides (Zone 6).
- **Ahmets und Fatmas Alibis** halten (Flüstern unter 1,5 m, Fühlen unter 1 m, beide bleiben bis zum Licht).
- **Ollis Weg, Versteck und späte Ankunft** bleiben unbeobachtet: keine Sichtlinie aus Ost-Saal oder Durchgang auf Tür, Klappe,
  Eiskübel; Eisklirren außer Hörweite (nächste 1,89 m); alle Wege mit erlaubtem Tempo; Lejla spürt ihn erst 25 s nach dem
  Scheppern.
- **Joannas Liste** stimmt mit allen Positionen um 23:57:00 überein (Fatma „geht zur Klappe“ passt zu 23:57:00–06).
- **Lageplan gegen Auftrag:** acht Zonen mit den Namen aus A:78–85; Eiskübel vor dem Ostende (W-02) und Sicherungskasten im
  Durchgang (W-03) überall gleich; Blatt B fasst die Höchstbelegung (Feld 1 mit 15, Feld 4d mit 6 Plättchen).
- **Kein echter Doppelort.** Die einzige Gleichzeitigkeit an zwei Orten (Tugba um 23:00) ist eine Reihenfolgefrage (P3R2-14).
- **Bezeichnungen** ohne Varianten in Raum- und Gegenstandsnamen.
- **Herr Schneider:** Gedächtnislücke ab 23:58:09 überall gleich; „Herr Schneider antwortet“ (MECH 9.10) passt zu WELT 1.4.
- **Vier Fassungen:** Zeitleisten WW4, JM3, RN7, YW4 decken sich Minute für Minute mit WELT 3.4 (bis auf Ollis 23:56, P3R2-04).

---

## 11. Ergebnis

Kein Blocker. Drei mittlere Befunde: die Ausrichtung der langen Tafel im Ost-Saal (P3R2-01), Cans Impuls-Antworten nach dem
Umdrehen (P3R2-02) und Fatmas „sofort“-Satz zur Theken-Klappe (P3R2-03). Neunzehn kleine Befunde (P3R2-04 bis P3R2-22); sieben
davon sind Reste von Runde-1-Behebungen, die nicht an allen Stellen angekommen sind (P3-01, P3-04, P3-05, P3-07, P3-16, P3-23).
Die Lösung bleibt in jeder Lesart richtig. Alle Vorschläge sind wörtlich und ohne Umbau einzuarbeiten; P3R2-02 und P3R2-04 halten
die Längen der gleichen Gestalt (RK 7.7).
