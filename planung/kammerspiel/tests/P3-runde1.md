# Protokoll 3 – Zeitstrahl- und Orts-Konsistenz (Prüfrunde 1)

Stand 2026-11-01. Geprüft: `bibel/01-welt.md` (WELT), `bibel/02-mechanik.md` (MECH), `bibel/03-rollen-kern.md` (RK),
`bibel/04-rollen-zeugen.md` (ZG), `bibel/05-rollen-zusatz.md` (ZR). Grundlage: `AUFTRAG.md` (A:Zeile), `ENTSCHEIDUNGEN.md`,
`verstehen/kanon-olli.md` (KO), `verstehen/abgleich.md` (ABG). Repo nur gelesen. Nichts an den Entwürfen geändert.

Prüfauftrag (A:130): Jede Uhrzeit, jeder Raumname, jede Position und jede Wahrnehmung in allen fünf Dateien gegeneinander und
gegen den Lageplan. Geometrie und Hör-, Seh-, Fühl-, Riechregeln. Bezeichnungen exakt gleich. Keine Rolle an zwei Orten zugleich.

---

## 1. Methode

1. **Koordinaten nachgerechnet.** Alle festen Punkte aus WELT §2.3 in ein Skript übernommen (`python3 -I`, nur Rechnen) und
   jede Abstandsangabe in WELT §2.8, §2.4, §5.1, §5.5, MECH §3.3 (Kartentexte) und MECH §9.11 (Maßtabelle) nachgerechnet.
2. **Tempo geprüft.** Jeder Weg im Sekundenprotokoll WELT §3.4 gegen die Regel „im Dunkeln höchstens 1 m/s, bei Licht 1,5 m/s,
   rennen 2,5 m/s“ (WELT §2.7).
3. **Hörregeln geprüft.** Jede Lautäußerung 23:51 bis 0:00:20 gegen Raum, Abstand, Lautstärke und Tumult (WELT §2.7, §5.1),
   dann gegen jede Stelle in RK, ZG, ZR, wo eine Rolle sagt, was sie gehört hat.
4. **Sicht und Licht geprüft.** Kerzenlicht 2 m um 13,5/8,5, Gesicht bis 3 m, Maske von weitem, Kauernde sehen nichts,
   Lichtregel W-23. Jede „ich sah“-Stelle der 18 Rollen und des Detektivs dagegen.
5. **Positionen gekreuzt.** Für jede Person jede Uhrzeit aus allen Dateien in eine Zeile; geprüft, ob zwei Texte die Person
   gleichzeitig an zwei Orte setzen.
6. **Uhrzeiten gesammelt.** Alle H:MM- und Sekundenangaben je Datei maschinell gezogen und gegen die Kanon-Liste in WELT §0.2
   und den Zeitstrahl WELT §3 gehalten. Uhrzeiten in Worten von Hand.
7. **Bezeichnungen gesammelt.** Raum-, Zonen- und Teilfeldnamen je Datei gegen WELT §0.2, §2.1 und MECH §10.2.

---

## 2. Geometrie (nachgerechnet)

| Strecke | Bibel sagt | gerechnet | Ergebnis |
|---|---|---|---|
| Marek (17,5/8,5) → Vorratsraumtür | 3,2 m | 3,16 m | stimmt; Gesicht nicht erkennbar (Grenze 3 m) |
| Marek → Eiskübel | 2,0 m | 2,00 m | stimmt; Eisklirren nicht hörbar |
| Ahmet (18,5/8,5) → Eiskübel | 2,2 m (WELT §2.4, §2.8); **1,4 m (WELT §5.5)** | 2,24 m | **Widerspruch in WELT §5.5 (P3-08)** |
| Damir (18,5/8,9) → Eiskübel | 1,9 m | 1,89 m | stimmt (über 1,5 m) |
| Damir → Marek | – | 1,08 m | Damir außerhalb der Fühlgrenze 1 m (P3-12) |
| Lejla → Eiskübel | 3,2 m | 3,16 m | stimmt |
| Eiskübel → Vorratsraumtür | 4,2 m | 4,24 m | stimmt |
| Kerzen → Vorratsraumtür / Klappe / vor der Theke West | 1,4 / 2,2 / 2,2 m | 1,41 / 2,24 / 2,24 m | stimmt |
| Tür zum Ost-Saal → Ostende / Eiskübel / Ahmet / Marek / Tim / Lejla / Klappe / Emine | 1,0 / 2,2 / 1,4 / 2,2 / 3,2 / 5,0 / 8,0 / 8,9 m | 1,00 / 2,24 / 1,41 / 2,24 / 3,16 / 5,00 / 8,00 / 8,94 m | stimmt |
| Ostende (Herr Schneider 23:57) → Olli / Ahmet / Marek / Tim / Joanna / Lejla | 1,4 / 1,0 / 1,4 / 2,2 / 1,0 / 4,5 m | 1,41 / 1,00 / 1,41 / 2,24 / 1,00 / 4,47 m | stimmt; „Zweitausend, bis zwölf“ (leise, 3 m) hören genau Olli, Ahmet, Marek, Tim, Joanna |
| Tim am Kasten → Klappe / Eiskübel / Zeynep | 2,2 / 8,2 / 2,2 m | 2,24 / 8,25 / 2,24 m | stimmt |
| Handykorb → Kopf der Tafel / Tür / Ehrenplatz | 2,8 / 5,8 / – | 2,83 / 5,83 / **4,00 m** | Ehrenplatz liegt außerhalb des 3-m-Handylichts (P3-20) |
| Wandbank West → Ascheneimer | 4 m | 4,00 m | stimmt |
| Steinbogen → vor die Bogentür | 5 m | 5,10 m | stimmt |
| Theken-Klappe ↔ Vorratsraumtür | **5,0 m (Can, WELT §2.8); 4,2 m (Olli, 5,6 − 1,4); „knapp vier Meter“ (MECH §9.11)** | 3,6 m (um die Thekenecke) bis 4,2 m (über 11,5/8,5) | **drei Werte für eine Strecke (P3-07)** |

Alle übrigen Kartentexte mit Maßen (DM3 „gut 3 m“, WJ9 „gut 3 m … 2 m“, AD3 „gut zwei Meter lang“, FK3 „1 m breit“) stimmen.

---

## 3. Tempo (Sekundenprotokoll WELT §3.4)

| Weg | Strecke | Zeit | Tempo | Ergebnis |
|---|---|---|---|---|
| Tim Kaffeemaschine → Kasten (23:58:00–09) | 8,4 m | 9 s | 0,93 m/s | stimmt; 23:58:05 ist er bei 11,5/8,5, 1 m vor der Klappe. „Buuuh!“ (23:58:07) ist dann über 3 m weg: nicht hörbar, wie WELT §5.1 sagt |
| Herr Schneider Kaffeemaschine → Tür (23:58:02–05) | 2,2 m | 3 s | 0,73 m/s | stimmt |
| Fatma Klappe → hinter den linken Buffettisch (23:58:01–05) | 4,0 m | 4 s | 1,0 m/s | stimmt |
| Olli Eiskübel → vor der Theke West (23:58:10–15) | 5,0 m | 5 s | 1,0 m/s | stimmt |
| Can Vorratsraumtür → vor die Bogentür (23:58:17–23) | 13,3–14,1 m | 6 s | 2,2–2,35 m/s | stimmt (rennen) |
| Olli vor der Theke West → Vorratsraumtür (23:58:19–25) | 5,6 m | 6 s | 0,93 m/s | stimmt |
| **Olli hinter der Tür → Eiskübel (23:58:36–48)** | **12,6 m (WELT §2.8)** | **12 s** | **1,05 m/s** | **knapp zu schnell (P3-06)** |
| **Olli Eiskübel → rechter Buffettisch, kriechend (23:58:49–52)** | **3,2 m** | **3 s** | **1,07 m/s** | **zu schnell, zumal kriechend (P3-06)** |
| Olli rechter Buffettisch → Eiskübel (0:00:05–08) | 3,2 m | 3 s | 1,07 m/s | stimmt (Licht, 1,5 m/s) |
| Serkan Ost-Saal → Außentor (23:55:30–45) | ≈ 11 m | 15 s | 0,73 m/s | stimmt |

---

## 4. Uhrzeiten

### 4.1 Auftrags-Zeiten (A:130) in allen Dateien

| A:130 | WELT §3 | MECH | RK | ZG | ZR | Ergebnis |
|---|---|---|---|---|---|---|
| 18:30 Lieferung, Bogentür | 18:30 Tragen, 18:35 Beschlag | §8.3 Kernsatz 1 legt beides auf halb sieben | RN7 getrennt | Tim, Marek getrennt | – | **MECH §8.3 verwischt 18:30/18:35 (P3-16)** |
| 20:15 Vorratsraum | ja | §1.5 ja | Olli Auftritt | Lejla | Azra, Wojtek, Sibel, Hana | stimmt |
| 21:00 Rüstung, Vitrine | ja | §1.5, §9.4 | – | – | Sibel, Damir | stimmt; Hörbarkeit des Schreis (P3-15) |
| 23:00 Streit Olli/Herr Schneider | ja | §1.5 | Olli, Ahmet | Tim | alle Ost-Saal-Rollen | stimmt |
| 23:30 Kaminqualm | ja | §1.5 | Fatma, Can | – | Hana, Serkan, Aylin | stimmt |
| 23:40 Münzschatulle | ja | §4.2 | Fatma | Emine | – | stimmt |
| 23:51 Streitfoto | ja | §4.2 | Ahmet | Joanna | – | stimmt |
| 23:54 Can im Vorratsraum | ja | §4.2 | Can | Zeynep | – | stimmt |
| 23:57 Ahmet, Fatma, Olli an der Theke | Ahmet 23:56:50–58, Fatma 23:57:00–06, Olli ab 23:56:50 | §4.2 23:57 | **Ahmet teils 23:56, teils 23:57** | **Marek teils 23:56, teils 23:57** | – | **uneinheitlich (P3-01)** |
| 23:58 Knall, Cans Flucht | 23:58:00, Flucht 23:58:17–23 | ja | ja | ja | ja | stimmt |
| 23:58:30 Scheppern | ja (W-05) | nur „kurz darauf“ | nur Reihenfolge | nur Reihenfolge | Hana „ab 23:58:31“ | stimmt; Hanas Geruchszeit (P3-03) |
| 0:00 Licht | 0:00:00 | ja | ja | ja | ja | stimmt |
| 0:12 Umschlag | ja | WM9 | Ahmet | – | Azra | stimmt |

### 4.2 Kanon-Liste (WELT §0.2)

Alle H:MM-Angaben in Spieltexten gehören zur Liste. Ausnahmen:
- MECH §1.1 Spalte „Uhr im Spiel“: **0:25** (Z. 91) gehört nicht zur Liste.
- MECH §1.1 Summenzeile: **„(2:35)“, „(2:47)“, „(2:56)“** (Z. 99) sehen aus wie Uhrzeiten und fallen durch denselben Prüfer
  (P3-19).
- „23:49“ steht nur in einer Überschrift der Spezifikation (WELT §3.3). Unkritisch.

### 4.3 Uhrzeiten in Worten

Stimmig: Viertel nach acht, halb acht, um neun, um zehn, um elf, zwanzig nach elf, halb zwölf, zwanzig vor zwölf, Viertel vor
zwölf, zehn vor zwölf, fünf vor zwölf, drei vor zwölf, um zwölf, zwei nach zwölf, halb eins. **„kurz vor zwölf“ ist doppelt
belegt** (23:55–23:57 und 23:59:30/40), entgegen den Prüftabellen ZG §10 und ZR §12 (P3-04).

---

## 5. Raum- und Zonennamen

| Name (Soll, WELT §0.2) | Abweichungen gefunden |
|---|---|
| Ost-Saal | keine („Ostsaal“ kommt nicht vor) |
| Buffetsaal | keine |
| Vorratsraum, Vorratsraumtür | keine („Vorratstür“ kommt nicht vor) |
| Durchgang, Steinbogen | keine |
| Kaminsaal, Kamin-Nische, Ascheneimer | keine |
| Turmgang, Turm-Toilette | **„Toilette im Turm“** in Cans Kernsatz (WELT §4.2 Z. 625, §7.1 Z. 893, RK §5.6 Z. 732) (P3-18) |
| Theke, Theken-Klappe, Westende, Ostende | Teilfelder 4a–4d tragen in WELT §2.1 und MECH §10.2 verschiedene Namen (P3-05) |
| Sicherungskasten | überall im Durchgang (W-03); kein Rest „im Kaminsaal“ außer in der Abweichungsliste K-08 |
| Windfang, Außentor, Innentür | keine |
| Zone 8b | WELT §2.1: „Turm-Toilette“; MECH §10.2 und RK §5.2: „Wendeltreppe und Turm-Toilette“ (P3-05) |

---

## 6. Positionen: keine Rolle an zwei Orten zugleich

Je Person alle Angaben 23:50 bis 0:15 aus allen fünf Dateien gekreuzt.

| Person | Ergebnis |
|---|---|
| Herr Schneider | stimmt (4b 23:51 → Vitrine 23:53 → linkes Buffet 23:55:50 → Ostende 23:57 → Kaffeemaschine 23:57:30 → Tür 23:58:05 → Vorratsraum) |
| Ahmet | Orte stimmen; **Uhrzeit des Schlüpfens hinter die Theke 23:56 gegen 23:57** (P3-01) |
| Fatma, Olli, Can | stimmen (Can auf der Wendeltreppe beim Scheppern, Teilfeld je nach Datei 8a oder 8b: P3-05) |
| Lejla, Emine, Tim, Joanna, Marek, Zeynep | stimmen |
| Sibel, Hana, Serkan, Azra, Wojtek, Aylin, Tugba | stimmen |
| Damir | Marker „23:57“ = 1 Ost-Saal (ZR §2.2), aber Zeitstempel-Antwort für 23:57 „Am Ostende hinter der Theke“ (ZR §0.6 Z. 176) (P3-10) |
| Detektiv | stimmt (Tafel Ostseite bis 23:55, dann Ehrenplatz) |

Kein echter Doppelort. Zwei Stellen geben für dieselbe Minute zwei verschiedene Angaben (Ahmet 23:56/23:57, Damir 23:57).

---

## 7. Wahrnehmung

### 7.1 Hören (gegen WELT §2.7, §5.1)

Geprüft und stimmig: Wer „Zweitausend, bis zwölf“ hört (Olli, Ahmet, Marek, Tim, Joanna; nie Zeynep, nie Lejla, nie Fatma);
„Nicht die alte Leiste!“ (ganzer Buffetsaal, Can, Zeynep an der 3-m-Grenze, Damir ab 23:57:35); „Ruhe! Ich hol die Notlaterne.“
(Ahmet, Marek, Damir, Can; nicht Fatma); „Buuuh!“ (nur Herr Schneider); „Hab ich dich!“, beide „Stehen bleiben!“, Scheppern
(Buffetsaal, Durchgang mit Steinbogen, Ost-Saal, Detektiv; nicht Kaminsaal, nicht Turm); Can hört den zweiten Ruf nicht; Sibel
und Hana hören weder Knall noch Scheppern; Serkan nur dumpf; Eisklirren und Klimpern hört niemand außer Olli.

Auffällig: Der Schrei um 21:00 im Turmgang soll „alle“ zum Lachen bringen (P3-15).

### 7.2 Sehen und Licht (gegen WELT §2.6, §2.7, W-23)

Geprüft und stimmig: Nur Marek und Olli sehen die Vorratsraumtür im Kerzenlicht; Marek 3,16 m, also nur Umriss und Leuchten;
Tim sieht das Gesicht 1 m vor sich, nicht die Klappe; Zeynep sieht den Durchgang entlang bis zur Klappe, im Dunkeln nur die
Maske; Joanna sieht aus der Tür den ganzen Buffetsaal, nicht den Durchgang; Kauernde sehen nichts; Lichtregel W-23 in allen
Texten gewahrt, soweit die Handys im Korb liegen.

Lücken: Handys der Personen, die um 23:55 nicht im Ost-Saal waren (P3-02); die Ost-Saal-Rollen „schauen auf die blinde Kuh“,
die im Dunkeln außerhalb des Handylichts sitzt (P3-20).

### 7.3 Fühlen

Ahmet an Mareks Beinen (unter 1 m), Fatma neben Emine, Olli neben Lejla, Can streift Zeynep: stimmen. Mareks Satz über Damir
hat keine Wahrnehmungsgrundlage (P3-12).

### 7.4 Riechen

Hanas Kerzengeruch: Zeitpunkt „ab 23:58:31“ und der daraus gezogene Schluss halten nicht (P3-03).

### 7.5 Wissen ohne Wahrnehmung

Emines und Zeyneps Domino-Hinweis, Serkans „als Erste“, Tims „Da hast du gestanden“: Die Rolle behauptet etwas, das sie nach
den Regeln nicht wahrnehmen konnte (P3-11, P3-13, P3-23).

---

## 8. Befunde

Schwere: **Blocker** = Spiel bricht, Lösung falsch oder Regelverstoß; **mittel** = spürbare Schwäche; **klein** = Feinschliff.
Kein Blocker gefunden.

### P3-01 · mittel · Ahmets Weg hinter die Theke: 23:56 oder 23:57 (erweitert P2-14)

**Fundstellen:** RK §7.3 WW4 Zeile „23:56 | Du gehst an [Joanna] vorbei und schlüpfst am Ostende hinter die Theke.“ (Z. 1037);
RK §3.5 Nr. 5 „23:56 ging Ahmet …“ (Z. 393); RK §7.4 JM3 Zeile „23:56 | … Gleich danach siehst du Ahmet …“ (Z. 1082) und „Was
nur du weißt“ Nr. 2 (Z. 1091); RK §8.1 Fatma, dritte Spalte (Z. 1236); ZG §5.4 Marek „23:56 | Ahmet schlüpft neben ihn …“
(Z. 893). Dagegen „23:57“: Ahmets Karte RK §2.8 („Um 23:57 Uhr bin ich mit dem Umschlag hinter die Theke.“), Fatmas Karte RK §3.8
und MECH §4.2, Lejlas Karte ZG §1.6, Mareks „Nach dem Umdrehen“ ZG §5.6, A:39, A:44.

**Problem:** WELT §3.4 legt den Weg auf 23:56:50–58. Spielertexte runden mal ab, mal auf. Ahmet liest in seiner Fassung „23:56“
und auf seiner Karte „23:57“. Fatma und Marek ebenso. Am Tisch klingt das wie ein Widerspruch zwischen zwei Zeugen, obwohl beide
dasselbe meinen.

**Vorschlag:** In allen Spielertexten „23:57“ (A:39, A:44). Wörtlich:
- RK §7.3: „| 23:57 | Du gehst an [Joanna] vorbei und schlüpfst am Ostende hinter die Theke. Neben dir füllt [Marek] die Saftkrüge. |“
- RK §3.5 Nr. 5, §7.4 Nr. 2, §8.1: „Um 23:57 Uhr ging Ahmet mit einem dicken Umschlag am Ostende hinter die Theke.“
- RK §7.4 JM3: „| 23:57 | Herr Schneider geht zum Ostende der Theke. Gleich danach siehst du Ahmet mit einem dicken Umschlag am
  Ostende hinter die Theke schlüpfen. |“ (die bisherige 23:56-Zeile mit dem Gang zum Ostende bleibt 23:56)
- ZG §5.4: „| 23:57 | Ahmet schlüpft neben ihn hinter die Theke, mit einem dicken Umschlag. … |“
- WELT §3.4 unter der Tabelle ergänzen: „Spielertexte nennen für Ahmets Weg hinter die Theke (23:56:50–58) immer 23:57 Uhr.“

### P3-02 · mittel · Handys von Personen, die um 23:55 nicht im Ost-Saal waren

**Fundstellen:** WELT §3.4 Z. 473 („Alle Handys in den Handykorb, nur Joanna darf ihres … behalten“); MECH §1.5 Z. 165 („Die
Handys kommen in den Handykorb.“); „Dein Handy hast du seit kurz nach zwölf zurück“ bei Emine (ZG §2.9 Z. 405), Tim (ZG §3.9
Z. 608), Zeynep (ZG §6.9 Z. 1168), Sibel (ZR §1.10 Z. 347), Hana (ZR §3.10 Z. 700); Lichtregel W-23 (WELT §2.6 Z. 345).

**Problem:** Fatma, Emine (linkes Buffet seit 23:50), Tim (Bogentür bis 23:55:30, dann über die Klappe zur Kaffeemaschine), Zeynep
(Steinbogen ab 23:54), Can (Vorratsraum), Sibel und Hana (Kaminsaal) waren um 23:55 nicht im Ost-Saal. Ihre Handys können nicht
im Korb liegen. Trotzdem sagen fünf Hefte, das Handy kam „kurz nach zwölf zurück“. Schwerer wiegt: Die Lichtregel setzt voraus,
dass im Buffetsaal und im Durchgang kein Handy brennt. Tim sucht fast zwei Minuten im Dunkeln den Hauptschalter und findet erst
23:59:40 seine Stirnlampe. Mit einem Handy in der Tasche ist das unglaubwürdig. Fatma und Emine hätten den Eiskübel ableuchten
können.

**Vorschlag:** Die Handys schon beim Ratespiel einsammeln. Wörtlich:
- WELT §3.3 neue Zeile: „| 23:00 | Ost-Saal (1) | Tugba, alle | Für ihr Ratespiel sammelt Tugba alle Handys in den Handykorb
  ein, auch Tims an der Kaffeemaschine. Nur Joanna behält ihres als Fotografin. Vor 0:05 holt sich niemand seins zurück. |“
- WELT §3.4 Z. 473: „Tugba: ‚Alle in den Ost-Saal! Um zwölf gibt's Torte!‘ Die Handys liegen seit dem Ratespiel im Korb; nur Joanna
  hat ihres.“ (Tugbas Ruf ohne „Handys in den Korb“).
- MECH §1.5, Zeile 23:00 ergänzen: „Für das Ratespiel kommen alle Handys in den Handykorb. Nur [Joanna | die Fotografin des
  Abends] behält ihr Handy.“ Zeile 23:55 ohne den Handy-Satz.
- ZR §2.5 Damir 23:55 „sein Handy kommt in den Korb“ → „sein Handy liegt seit dem Ratespiel im Korb“; ZR §8.6 Tugba „Um fünf vor
  zwölf hab ich alle in den Ost-Saal gerufen und die Handys eingesammelt.“ → „Um elf hab ich für mein Ratespiel alle Handys
  eingesammelt. Um fünf vor zwölf hab ich alle in den Ost-Saal gerufen.“
- WELT §0.3 als K-23 aufnehmen (Kanon: 23:55).

### P3-03 · mittel · Hanas Kerzengeruch: Zeitpunkt unmöglich, Schluss nicht gedeckt

**Fundstellen:** WELT §3.6 Z. 574 („23:58:21–23:58:31 | Hana sieht das Gesicht, danach riecht sie erloschene Kerzen“); WELT §5.2
Hana-Zeile („Reihenfolge zum Scheppern bezeugbar: nur über den Geruch“); ZR §12 Z. 1719 („Kerzengeruch (ab 23:58:31)“); ZR §3.5
„Vermutet: … Das Gesicht war da schon im Kaminsaal“; ZR §3.8 R3-1, Fassung „Olli noch in Stufe 1“ (Z. 684): „Olli, das Gesicht war
schon im Kaminsaal, bevor die Kerzen an der Theke ausgingen. Ich hab es gerochen.“; ZR §3.13 „Ihre Nase stützte Cans Alibi.“

**Problem:** (1) Die Kerzen gehen 23:58:30 aus. Bis zur Kamin-Nische sind es über Durchgang und Steinbogen rund 14 m. Ein Geruch,
der 1 s später ankommt, bräuchte Sturm. (2) Der Geruch kommt mit Verzögerung. „Erst das Gesicht, dann der Geruch“ beweist darum
nicht „das Gesicht vor dem Scheppern“: Bei 15 s Verzögerung passt auch ein Gesicht nach dem Scheppern. Hanas Satz an Olli behauptet
mehr, als sie wahrnehmen konnte. Zusatzrollen dürfen nur sagen, was sie wissen (ZR ZG-01, ZG-05).

**Vorschlag:**
- WELT §3.6 Z. 574: „| 2 | 23:58:21–23:58:22 und ab etwa 23:58:45 | Hana sieht das Gesicht; einige Sekunden später riecht sie
  erloschene Kerzen (Luftzug etwa 1 m/s über rund 14 m) |“; ZR §12 entsprechend „ab etwa 23:58:45“.
- WELT §5.2 Hana-Zeile, letzte Spalte: „nein; sie weiß nur: erst das Gesicht, dann der Geruch. Stützt Cans Alibi, beweist es nicht.“
- ZR §3.8 R3-1, Fassung Stufe 1, wörtlich: „Olli, erst huschte das Gesicht durch den Kaminsaal, dann roch es nach ausgeblasenen
  Kerzen. Die Kerzen standen an der Theke. Wo warst du, als sie ausgingen?“
- ZR §3.5 „Vermutet“ als Vermutung kenntlich lassen, nie als Satz „Das Gesicht war vor den Kerzen weg“.

### P3-04 · mittel · „kurz vor zwölf“ steht für zwei verschiedene Zeitpunkte

**Fundstellen:** für 23:59:30/40 (im Dunkeln): ZG §0.4 I-3.1 Joanna (Z. 77), ZG §4.4 (Z. 703), §4.6 (Z. 737), §4.12 Protokoll;
MECH §5.3 Joanna-Protokoll (Z. 633); MECH §9.11 Teil B (Z. 1070); ZG §3.4 Tim (Z. 504), §3.5 (Z. 529), §3.7 R1-2 (Z. 588); ZR §5.5
Azra „kurz vor zwölf | Im Ost-Saal gehen Handylampen an“. Für 23:55–23:57: Lejla, Tim, Marek, Zeynep (ZG §1.5, §3.5, §5.5, §6.5),
Damir, Serkan, Azra, Wojtek, Aylin (ZR), Detektiv (MECH §1.6). Die Prüftabellen ZG §10 („kurz vor zwölf (23:59:30/40)“) und ZR §12
behaupten Eindeutigkeit.

**Problem:** Am Tisch heißt „kurz vor zwölf“ fast immer „drei vor zwölf, vor dem Knall“. Joannas wichtiger Satz „Kurz vor zwölf hab
ich mit der Handylampe die Tafel abgeleuchtet. Der Kopf der Tafel war leer.“ soll aber zeigen, dass Olli im Dunkeln nicht am Kopf
der Tafel saß. Wer ihn als 23:57 liest, hört nur, was die Notiz schon sagt. WELT §0.2 verlangt im Dunkeln Reihenfolgen statt
Uhrzeiten.

**Vorschlag (wörtlich):**
- Joanna (ZG §0.4, §4.6, §4.12; MECH §5.3): „Im Dunkeln, kurz bevor das Licht wieder anging, hab ich mit der Handylampe die Tafel
  abgeleuchtet. Der Kopf der Tafel war leer.“
- Tim (ZG §3.5): „[Als meine Stirnlampe kurz vor dem Licht wieder anging, stand Zeynep im Steinbogen. |]“; ZG §3.7 R1-2: „… Und
  als kurz vor dem Licht meine Stirnlampe wieder anging, standest du immer noch da. …“
- MECH §9.11 Teil B: „Kurz bevor das Licht wieder angeht, gehen im Ost-Saal Handylampen an und im Durchgang eine Stirnlampe.“
- Wissenstabellen (ZG §3.4, §4.4, ZR §5.5) Zeitspalte: „im Dunkeln, kurz vor dem Licht“.
- ZG §10 und ZR §12: „kurz vor zwölf (23:55 bis 23:57); kurz vor dem Licht (23:59:30/40)“.

### P3-05 · mittel · Teilfelder des Lageplans heißen in jeder Datei anders

**Fundstellen:** WELT §2.1 Z. 223 („4a Westende mit Theken-Klappe · 4b Vor der Theke mit Eiskübel · 4c Hinter der Theke: Anrichte
mit Kerzenständer, Vorratsraumtür, Teekocher, Kaffeemaschine · 4d Ostende mit Saft und Servietten“), Z. 227 („8a Turmgang · 8b
Turm-Toilette“); MECH §10.2 Z. 1142–1145 („4a Theke Westende mit Klappe … 4c Hinter der Theke: Anrichte, Vorratsraumtür · 4d Theke
Ostende … 8b Wendeltreppe und Turm-Toilette“); Hefte: „Theke Ostende (4d)“ (RK §2.2), „4c Hinter der Theke“ (ZG §3.2), „8b Wendeltreppe
und Turm-Toilette“ (RK §5.2 Z. 685–686); WELT §4.2 Can: „Scheppern bleibt 8 (er war da schon auf der Wendeltreppe)“.

**Problem:** Der Auftrag verlangt exakt gleiche Bezeichnungen (A:130). Plan (Blatt A), Markerfelder (Blatt B) und „Deine Marker“
in den Heften müssen dieselben Wörter tragen, sonst sucht man das Feld. Bei 8b ist es inhaltlich: Nach WELT gehört die
Wendeltreppe nicht zu 8b, also stünde Cans wahrer Scheppern-Marker auf 8a; nach MECH und RK stimmt 8b. Dazu liegt „vor der
Theke beim Westende“ (Ollis Warteplatz) laut WELT §2.3 in 4a, obwohl 4b „Vor der Theke“ heißt.

**Vorschlag:** Eine Tabelle in WELT §2.1, wörtlich übernommen in MECH §10.2 und alle Hefte:
„1 Ost-Saal · 2 Linkes Buffet · 3 Rechtes Buffet · 4a Theke Westende mit Theken-Klappe (auch davor) · 4b Vor der Theke mit
Eiskübel · 4c Hinter der Theke: Anrichte, Vorratsraumtür · 4d Theke Ostende, davor und dahinter · 5 Vorratsraum · 6 Durchgang mit
Steinbogen · 7 Kaminsaal · 8a Turmgang · 8b Wendeltreppe und Turm-Toilette · W Windfang“. In WELT §2.1 Zone 8 „8a Turmgang ·
8b Wendeltreppe und Turm-Toilette“, in WELT §4.2 Can: „Scheppern bleibt 8b (Wendeltreppe)“. Die Ausstattungslisten bleiben in der
Legende, nicht im Feldnamen.

### P3-06 · klein · Ollis Rückweg rechnerisch schneller als erlaubt

**Fundstellen:** WELT §3.4 Z. 527 („23:58:36–23:58:48 … zurück … zum Eiskübel“, 12,6 m), Z. 529 („23:58:49–23:58:52 … kriecht zum
rechten Buffettisch“, 3,2 m), Z. 530; WELT §3.1 Z. 409 („Kein Weg ist schneller als erlaubt.“), §8.4 Z. 1107; W-23 Z. 345, Z. 1020.

**Problem:** 12,6 m in 12 s und 3,2 m kriechend in 3 s sind über 1 m/s. Die Bibel behauptet das Gegenteil.

**Vorschlag:** Zwei Sekunden dazugeben. Wörtlich: „| 23:58:36–23:58:49 | … Olli tastet sich zurück …“, „| 23:58:49 | 4b | Olli
schiebt den Bund unter die Eiswürfel. …“, „| 23:58:50–23:58:54 | 4b → 3 | Olli kriecht zum rechten Buffettisch …“, „| 23:58:55 | 3 |
Olli: ‚Lejla? Ich bin's, Olli.‘ |“. Lichtregel W-23 und WELT §2.6: „bis 23:58:54“. WELT §5.1 Zeile „Lejla? …“: 23:58:55. WELT §5.3:
„25 s nach dem Scheppern“. MECH §8.3 Zeitleiste zum Nachlesen entsprechend.

### P3-07 · klein · Abstand Theken-Klappe – Vorratsraumtür dreimal verschieden

**Fundstellen:** WELT §2.8 Z. 391 (Can: 5,0 m) und Z. 393 (Olli: 5,6 − 1,4 = 4,2 m); MECH §9.11 Z. 1060 („knapp vier Meter“).

**Problem:** Dieselbe Strecke hat drei Werte. Die Maßtabelle ist ein Spieltext („Maßband“) und muss mit der Welt übereinstimmen.

**Vorschlag:** 4,2 m festlegen. WELT §2.8 Can-Zeile: „| Can: Vorratsraumtür → Klappe / Tim / Steinbogen / vor die Bogentür | |
4,2 / 6,2 / 8,2 / 13,3 | rennend 1,7 / 2,5 / 3,3 / 5,3 s |“ (Zeitstrahl bleibt gültig; Can ist früher durch). MECH §9.11:
„| Theken-Klappe | Vorratsraumtür | ‚gut vier Meter, hinter der Theke entlang‘ | …“. WELT §2.5: „Bis vor die Bogentür 13,3 m,
rennend 5,3 s.“

### P3-08 · klein · Ahmets Abstand zum Eiskübel in WELT §5.5 falsch

**Fundstelle:** WELT §5.5 Z. 762: „| Ahmet | ja, 1,4 m, …“.

**Problem:** Ahmet steht 23:57 auf 18,5/8,5. Zum Eiskübel sind es 2,24 m (so auch WELT §2.4 und §2.8). 1,4 m ist Herrn Schneiders
Abstand.

**Vorschlag:** „| Ahmet | ja, 2,2 m, und hörte den Satz | …“.

### P3-09 · klein · Herrn Schneiders erster Satz im Tat-Moment

**Fundstelle:** MECH §9.5 Z. 925: „Kurz danach kommt er zu sich. Sein erster Satz: ‚Mein Schlüsselbund! Der ist weg!‘“

**Problem:** WELT §3.5: 0:01:30 „Mein Kopf.“, erst 0:02:00 der Schlüsselbund.

**Vorschlag:** „Kurz danach kommt er zu sich. ‚Mein Kopf.‘ Dann: ‚Mein Schlüsselbund! Der ist weg!‘“

### P3-10 · klein · Zeitstempel-Antworten passen nicht zu Markern und Wahrnehmung

**Fundstellen:** ZR §0.6 Z. 175–177 und Z. 186.

**Problem:** (1) Damir antwortet für 23:57 „Am Ostende hinter der Theke, mit der Teekanne.“ Sein Marker „23:57“ steht aber auf 1
Ost-Saal (ZR §2.2, WELT §4.2). Eine Rolle, die nie lügt und deren Marker nie umgestellt wird, widerspricht sich vor allen. (2) Sibel
nennt Hana, Hana nennt Sibel als Zeugin. Für 23:57 geht das nicht: Sibel döst ab 23:54 (ZR §1.5), Hana wischt mit dem Gesicht
zur Wand (ZR §3.5). Nur für 23:51 trägt es (Hana drehte sich 23:50 um).

**Vorschlag (wörtlich):**
- Damir, 23:57: „Erst im Ost-Saal beim Teeausschenken. Dann bin ich mit der Teekanne ans Ostende hinter die Theke.“ Zeuge:
  Marek (er weiß, dass der Gast mit der Teekanne hinter ihm wartete, ZG §5.4).
- Sibel: „23:51: Im Kaminsaal auf der Wandbank Süd. Zeugin: [Hana | niemand am Tisch]. 23:57: Dasselbe. Gesehen hat mich da keiner,
  ich hab gedöst.“
- Hana: „23:51: An der Kamin-Nische. Zeugin: Sibel. 23:57: Dasselbe, mit dem Gesicht zur Wand. Zeugin: niemand.“
- Z. 186 streichen oder auf 23:51 beschränken.

### P3-11 · klein · Domino-Hinweise ohne Wahrnehmungsgrundlage (Emine, Zeynep)

**Fundstellen:** ZG §2.6 Emines Karte Z. 374 / MECH §4.2: „Herr Schneider hat heute Abend nicht nur Fatma gedroht.“ ZG §6.6 Zeyneps
Karte Z. 1138 / MECH §4.2: „Am Sicherungskasten stand Tim. Can ist direkt an ihm vorbei.“

**Problem:** Emine hörte nur die Drohung an Fatma (WELT §5.6). Dass er anderen drohte, ist ihre Vermutung (ZG §2.4 „Vermutet“), steht
aber als Tatsache auf der Karte. Zeynep konnte Tim im Dunkeln weder sehen noch hören: 2,24 m, Tumult, sein Satz „Wo ist denn der
Hauptschalter?“ ist leise (Grenze 1,5 m). Sie weiß erst ab 23:59:40, dass Tim am Kasten stand. Karten sprechen mit der Stimme der
Rolle; sie sollen nur sagen, was die Rolle wahrnahm.

**Vorschlag (wörtlich, MECH §4.2 und ZG gleich):**
- Emine: „Um elf ist Herr Schneider an der Theke laut geworden. Mit wem, hab ich vom Ost-Saal aus nicht gesehen.“
- Zeynep: „Als das Licht anging, stand Tim am Sicherungskasten, direkt an Cans Weg. Frag ihn, was an ihm vorbeikam.“

### P3-12 · klein · Marek weiß nicht, dass Damir neben ihm kauerte

**Fundstelle:** ZG §5.5 Z. 914: „[Damir kauerte gleich daneben. | Ein Gast mit der großen Teekanne kauerte gleich daneben.]“; ZG §5.4
Zeile 23:58.

**Problem:** Damir sagt im Dunkeln nichts und kauert 1,08 m von Marek, außerhalb der Fühlgrenze 1 m. Im Dunkeln sieht Marek ihn
nicht. Mareks Satz ist ein Schluss, kein Erlebnis.

**Vorschlag:** „[Damir stand vorher mit der Teekanne hinter mir. Als das Licht anging, stand er gleich neben Ahmet auf. | Ein Gast mit
der großen Teekanne stand vorher hinter mir. Als das Licht anging, stand er gleich neben Ahmet auf.]“

### P3-13 · klein · Serkan sagt mehr, als er wissen kann

**Fundstellen:** ZR §4.8 R1-1 Z. 850: „Lejla, du warst als Erste bei Herrn Schneider.“; ZR §4.6 Z. 801: „Raus ist also keiner.“;
Serkans Kartenvermerk ZR §4.7 und MECH §4.2 Z. 520, §6.2 Z. 692: „niemand ist hinaus“.

**Problem:** (1) Als Erster war Marek bei Herrn Schneider (0:00:16–20). Serkan stand bis 0:02:40 im Windfang und sah es nicht.
(2) Serkan bewacht nur das Außentor. Wer den Bund hatte, konnte damit auch die Hoftür im Turmgang öffnen (am Bund: Außentor, Hoftür,
Turm, WELT §1.4). „Raus ist keiner“ ist mehr, als Serkan bezeugen kann.

**Vorschlag (wörtlich):** R1-1: „Lejla, als ich vom Tor zurückkam, warst du bei Herrn Schneider. Ich war dein Ausbilder im
Erste-Hilfe-Kurs, also: Wie geht es ihm? Und wer war im Dunkeln bei dir am rechten Buffet?“ Stufe 1: „Durchs Außentor ist also
keiner raus.“ Vermerk: „Hinweis: Von 23:56 Uhr bis kurz nach zwölf stand Serkan am abgeschlossenen Außentor. Niemand kam in den
Windfang, niemand ist durchs Außentor hinaus.“ MECH §4.2 und §6.2 entsprechend.

### P3-14 · klein · Tugba führt plötzlich eine zweite Liste

**Fundstelle:** ZR §0.5 I-1.3 Tugba Z. 159: „Ich hab doch selbst gerufen. Wer nicht kam, steht in meinem Plan als fehlend.“

**Problem:** Die Liste von 23:57 gehört seit K-10 und W-21 allein Joanna. Tugbas Notizbuch enthält Ablaufplan, Punkteliste und
Dankeskarte (WELT §6). Ein „Plan“ mit Fehlenden wäre eine zweite Quelle für „Can nirgends“ und widerspricht ZG-05.

**Vorschlag:** „Ich hab doch selbst gerufen. Wer gefehlt hat, hab ich nicht aufgeschrieben. Frag Joanna, die hat gezählt.“

### P3-15 · klein · Den Schrei um 21:00 können „alle“ nicht gehört haben

**Fundstellen:** WELT §3.3 Z. 441 („Alle lachen über den Schrei“), MECH §1.5 Z. 161, ZR §0.4 Z. 89.

**Problem:** Nach WELT §2.7 hört man auch sehr Lautes nur im eigenen und im direkt angrenzenden Raum. Ein Schrei im Turmgang erreicht
den Kaminsaal, nicht Buffetsaal und Ost-Saal.

**Vorschlag:** WELT §3.3: „… Den Schrei hört man bis in den Kaminsaal. Als Damir es im Ost-Saal erzählt, lachen alle; vom Sprung
erzählt er nichts.“ MECH §1.5: „– 21:00 Uhr: Im Turmgang schreit [Sibel | ein Gast] vor der Ritterrüstung auf. Als es sich
herumspricht, lachen alle.“

### P3-16 · klein · Rückblende legt Tragen und Schaden auf dieselbe Minute

**Fundstelle:** MECH §8.3 Abschnitt 1, Kernsatz (Z. 824): „Um halb sieben trägt Olli mit Tim die Warmhaltebehälter durch die
Bogentür. Dabei reißt ein Beschlag aus der gekalkten Wand.“

**Problem:** 18:30 Tragen, 18:35 Beschlag (WELT §3.3; ABG §3.10: getrennt schreiben). „Dabei“ legt den Schaden auf halb sieben.

**Vorschlag:** „Um halb sieben tragen Olli und Tim die Warmhaltebehälter durch den Turmgang. Fünf Minuten später schrammt Olli die
Bogentür, und ein Beschlag reißt aus der gekalkten Wand.“

### P3-17 · klein · RN7: Ruf vor dem Losreißen

**Fundstelle:** RK §7.5 RN7 Z. 1125: „| 23:58 | ‚Stehen bleiben!‘ Das Gesicht reißt sich los und rennt dicht an dir vorbei durch die
Klappe. …“

**Problem:** WELT §3.4: Can reißt sich 23:58:17 los, der Ruf folgt 23:58:18. YW4 erzählt es richtig („Du reißt dich los … Er steht noch
und brüllt“). Die Prüfzeile unter RN7 nennt eine andere Reihenfolge als die Zeile selbst.

**Vorschlag:** „| 23:58 | Das Gesicht reißt sich los. Herr Schneider brüllt: ‚Stehen bleiben!‘ Das Gesicht rennt dicht an dir vorbei
durch die Klappe. Wer darunter steckt, erkennst du nicht. Du gehst durch die Klappe hinter die Theke. Herr Schneider brüllt: ‚Stehen
bleiben, hab ich gesagt!‘ |“

### P3-18 · klein · „Toilette im Turm“ statt „Turm-Toilette“

**Fundstellen:** WELT §4.2 Z. 625, WELT §7.1 Z. 893, RK §5.6 Z. 732 (Cans Kernsatz).

**Problem:** A:130 verlangt gleiche Bezeichnungen; WELT §0.2 nennt „Turm-Toilette“. Der Kernsatz ist der meistgesagte Satz der Rolle.

**Vorschlag:** „Ich war die ganze Zeit oben auf der Turm-Toilette.“

### P3-19 · klein · Uhrzeiten außerhalb der Kanon-Liste im Zeitplan

**Fundstelle:** MECH §1.1 Z. 91 („0:25“) und Z. 99 („155 min (2:35)“, „167 min (2:47)“, „176 min (2:56)“).

**Problem:** Der Zeitplan steht im Erzählerheft (MECH §9.1 Seite 3). 0:25 ist keine Kanon-Minute; die Klammerwerte sehen wie Uhrzeiten
aus und fallen durch denselben Prüfer (WELT §0.2).

**Vorschlag:** Z. 91 letzte Spalte „0:20“ (wie Schritt 5) oder „–“. Z. 99: „155 min (2 Std. 35 Min.)“, „167 min (2 Std. 47 Min.)“,
„176 min (2 Std. 56 Min.)“.

### P3-20 · klein · Wer im Ost-Saal sah Olli sitzen und den leeren Kopf der Tafel?

**Fundstellen:** ZR §14 ZR-09 Z. 1772 und die Zeilen „schaut weiter auf die blinde Kuh“ bei Azra, Wojtek, Aylin, Tugba (ZR §5.5,
§6.5, §7.5, §8.5); ZR §2.5 Damir „23:50–23:57 | schenkt im Ost-Saal allen Tee aus“.

**Problem:** (1) Der Ehrenplatz (24,5/16,5) liegt 4 m vom Handykorb, also außerhalb des 3-m-Handylichts. Wer „auf die blinde Kuh
schaut“, schaut ins Dunkle, während 2,8 m vom Korb der leere Kopf der Tafel beleuchtet ist. Die Begründung trägt nicht. (2) Damir
schenkt 23:50–23:57:30 im Ost-Saal allen Tee aus. Olli sitzt 23:54–23:56:30 am Kopf der Tafel. Damirs Heft sagt dazu weder ein
Wissen noch ein „Weiß nicht“. Fragt Olli am Tisch „Damir, du hast mir doch Tee gebracht?“, hat Damir keine Antwort.

**Vorschlag:** ZR-09 Begründung: „Nach dem Scheppern schauen alle Ost-Saal-Rollen zur Tür in den Buffetsaal, woher der Lärm kam;
den Kopf der Tafel hinter sich beachten sie nicht.“ Die vier Wissenszeilen entsprechend: „Als die Handylampen angehen, schaut
sie zur Tür, woher der Lärm kam.“ Damir, ZR §2.5 neue Zeile: „| 23:54 | Olli setzt sich an den Kopf der Tafel. Wann er wieder
aufstand, hast du nicht gesehen; du hast gerade eingeschenkt. | WELT §3.4 | offen |“ (stützt Ollis Stufe 1 nur bis 23:56 wie RK-06,
kein Pflicht-Auslöser).

### P3-21 · klein · Azras Strickjacke

**Fundstellen:** WELT §3.5 Z. 553; ZR §0.5 Z. 164, §5.5 Z. 952, §5.6 Z. 968, Z. 981. Dagegen WELT §1.2 Merkmal „langer
Strickcardigan“.

**Problem:** Azra trägt ihren langen Strickcardigan als Merkmal, holt aber um 0:10 „ihre Strickjacke“ von der Wandbank. Ein Gegenstand
an zwei Orten zugleich.

**Vorschlag:** „Azra holt ihren Skizzenblock von der Wandbank West und bleibt dort sitzen.“ (passt zu ZR §5.10 „einen kleinen Block
mit Skizzen“). In ZR Z. 164, 968, 981 „meinen Skizzenblock“ statt „meine Strickjacke“.

### P3-22 · klein · Ausfalltext Sibel macht den Sprung öffentlich (ZR §15 Nr. 2 offen)

**Fundstelle:** MECH §9.4 Z. 905: „… Die Scheibe bekam einen feinen Sprung.“

**Problem:** WELT §3.3: „vom Sprung weiß niemand sonst“. Bei 6–12 Personen liest der Erzähler ihn trotzdem vor. Dann kennt jeder den
Sprung, auch Fatma, deren Karte „Die Scheibe hatte schon einen Sprung“ sagt.

**Vorschlag:** Letzten Satz streichen: „Um neun Uhr abends hielt ein Gast die alte Ritterrüstung im Turmgang für einen Menschen. Der
Gast schrie auf und stolperte rückwärts.“

### P3-23 · klein · Tims Frage an Ahmet stützt sich auf nicht verzeichnetes Wissen

**Fundstelle:** ZG §3.7 R2-1 Z. 589: „Ahmet, kurz vor zwölf kam Herr Schneider vom Ostende zu mir an die Kaffeemaschine. Da hast du
gestanden. …“

**Problem:** Tims Wissenstabelle (ZG §3.4) kennt Ahmet um 23:57 nicht. Nach G-07 stützen sich Ziele nur auf eigenes offenes Wissen.
Wahrnehmbar war es: Ahmet stand 2 m neben Tim hinter der Theke, volles Licht.

**Vorschlag:** ZG §3.4 neue Zeile: „| 23:57 | Ahmet schlüpft am Ostende hinter die Theke, zwei Meter neben ihm. Gleich danach geht
Herr Schneider an Ahmet vorbei zu ihm | WELT §3.4 | offen |“. In R2-1 „kurz vor zwölf“ durch „um drei vor zwölf“ ersetzen.

### P3-24 · klein · Mehrdeutiger Satz zu Mareks zweiter Gestalt

**Fundstelle:** WELT §3.4 Z. 521: „Marek sieht von der Klappe her eine zweite Gestalt kommen, nur als Umriss“.

**Problem:** Man kann lesen, Marek stehe an der Klappe. Er steht am Ostende.

**Vorschlag:** „Marek sieht vom Ostende aus eine zweite Gestalt von der Klappe her ins Kerzenlicht kommen, nur als Umriss.“

---

## 9. Was hält (bestätigt)

- **Cans Alibi ist geometrisch sauber.** Can ist 10 s vor dem Scheppern an Tim, 9 s vorher im Steinbogen, 7 s vorher vor der
  Bogentür; Herr Schneiders zweiter Ruf (23:58:22) fällt zwischen Cans Durchlauf und das Scheppern. Tim und Zeynep hören beides,
  weil Kasten und Bogen zu Zone 6 gehören (W-03, W-04). Marek sieht es aus 3,16 m im Kerzenlicht.
- **Ahmets und Fatmas Alibis halten.** Flüstern unter 1,5 m im Tumult, Fühlen unter 1 m, beide bleiben bis zum Licht.
- **Ollis Weg und Versteck bleiben unbeobachtet.** Nur Olli und Herr Schneider sind im Hörabstand der leisen Sätze an der Tür;
  Eisklirren erreicht niemanden (nächste 1,89 m); kein Licht trifft Tür, Klappe, Eiskübel bis zu Ollis Ankunft bei Lejla.
- **Joannas Liste** passt zu allen Positionen um 23:57:00; die Tür zum Ost-Saal sieht den ganzen Buffetsaal, nicht den Durchgang.
- **Zeynep hört nie „Zweitausend“**, Can hört den zweiten Ruf und das Scheppern nicht, Sibel und Hana hören nichts aus dem
  Buffetsaal.
- **Lageplan gegen Auftrag:** Alle acht Zonen tragen die Namen aus A:78–85; Eiskübel am Ostende (W-02) und Sicherungskasten im
  Durchgang (W-03) sind begründet und überall gleich umgesetzt.
- **Keine Rolle ist zur selben Zeit an zwei Orten.** Die zwei Doppelangaben (P3-01, P3-10) betreffen Rundung und Wortlaut, nicht
  den Ort.
- **Herr Schneider:** Gedächtnislücke ab 23:58:09 überall gleich; „Herr Schneider antwortet“ (MECH §9.10) passt zu WELT §1.4.
- **Detektiv:** sitzt 23:50–23:55 an der Tafel, sieht Olli 23:54 kommen, hört nur sehr Lautes; in MECH §1.6 und RK §6 gleich.

---

## 10. Ergebnis

Kein Blocker. Fünf mittlere Befunde (P3-01 bis P3-05), neunzehn kleine (P3-06 bis P3-24). Die Lösung bleibt in jeder Lesart
richtig: Alle drei Alibis der Unschuldigen, Ollis späte Ankunft, der Fundort und die Lichtregel halten der Nachrechnung stand.
Die mittleren Befunde betreffen gleiche Bezeichnungen und Uhrzeiten über die Dateien hinweg (A:130), die Handy-Lücke unter der
Lichtregel und Hanas überzogenen Geruchsschluss. Alle Vorschläge sind wörtlich und lassen sich ohne Umbau einarbeiten.
