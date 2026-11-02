# Prüfprotokoll Fall-Bibel, Runde 1: Protokoll 5 (Vollständigkeit) und Regelprüfung

Stand 2026-11-01. Geprüft: `bibel/01-welt.md` (WELT), `02-mechanik.md` (MECH), `03-rollen-kern.md` (RK),
`04-rollen-zeugen.md` (ZG), `05-rollen-zusatz.md` (ZR). Maßstab: `AUFTRAG.md` (A), `ENTSCHEIDUNGEN.md` (E1–E17),
`verstehen/regeln.md` §6 und §9 (REG). Repo nur gelesen. Haltung: gegnerisch.

Prüfumfang:
1. Protokoll 5: Hat jeder Teil 00, 01, 02, 10, 11, 12, 20, 90 eine vollständige Inhaltsangabe, ohne Platzhalter und Lücken?
2. Ton- und Inhaltsregeln REG §6 und §9 (Gewalt, Getränke, Schlag-Verben, Anglizismen, Satzlänge, Namen, Herkunft, Kopftuch).
3. Spoilerfreiheit (Erzählerheft, Vorderseiten, Name als Urteil, XD3).
4. Gleiche Gestalt der vier Verdächtigen (E9).
5. Entscheidungen E1–E17.
6. Wünsche des Auftrags A:1–140.

Werkzeug: `bibel/tests/werkzeug-p5/pruefe.py` zieht alle Blockzitate und „…“-Texte (auch über Zeilen) aus den fünf Dateien und
prüft Schlag-Verben, Gewaltwörter, Alkohol-, Rauch-, Fachwort- und Sperrliste, Anglizismen, Altnamen, „gestohlen“, Kopftuch,
Herkunftswörter, Platzhalter, bloßes „Schneider“, Siezen, Raumwörter und Satzlänge. Rohdaten: `werkzeug-p5/roh.tsv`.
Jeder Treffer wurde von Hand gegen den Zusammenhang geprüft (Spezifikationstext oder Spieltext, Zeilenumbruch, Kanon-Zitat).

Schwere: **Blocker** = Spiel bricht, Lösung leckt oder klarer Inhaltsregel-Verstoß im gedruckten Text. **mittel** =
spürbare Schwäche oder fehlender Inhalt. **klein** = Feinschliff, mechanische Kleinigkeiten.

---

## 0. Ergebnis in Kürze

- Die Bibel ist auf Spezifikationsebene fast vollständig. Alle 19 Indizkarten, alle 18 Geheimniskarten, alle 18 Aktionskarten,
  alle sechs Zeugenstreifen, alle vier Fassungen, alle 19 Vorstellungsfragen und Auftritte, die Moderationsimpulse, der
  Tipp-Zettel, die Wertung und die Skalierung stehen wörtlich. Kein „TODO“, kein „…“ als Inhalt.
- **5 Blocker:**
  1. Teil 01 druckt den Inhalt von XD3 und „Teil 2, Handschuh und Ärmel“ vor Spielbeginn (bestätigt P2-01).
  2. FN3 trägt in Runde 2 den Vermerk „Schlüsselbeweis, Teil 2 … zeigt, wer den Kerzenständer hielt“ auf Ollis Weste (bestätigt P2-02).
  3. Die Rollenhefte von Ahmet, Fatma und Can sagen „Mit dem Scheppern hast du nichts zu tun“, Ollis Heft nicht. Die vorab
     sendbaren Hefte verraten so zusammen den Täter (E9, E10, M-31).
  4. Gedruckte „Was du weißt“-Tabellen nennen ungespielte Rollen ohne Platzhalter (Damir → Tugba, Serkan → Aylin,
     Wojtek → Tugba, Sibel → Hana, Tim → Marek und Zeynep, Joanna → Zeynep). Gleiche Klasse wie P14-01.
  5. Lejlas Tarnsatz „Ahmet ist mein Cousin. Über seine Sachen redet er selbst.“ begründet Schweigen mit Verwandtschaft (REG §6.4).
- **7 mittlere Befunde:** Anglizismus „Taschen-Check“/„Marker-Check“ (E5); „Die Rollen am Tisch“ fehlt für die vier
  Verdächtigen (Teil 90); Bonus-Ziel des Erzählers steht nirgends im Erzählerheft; Zeugenhefte ohne Heftaufbau, ohne
  „Wer du bist“ und „Deine Marker“ wörtlich; „nie Kleidung am Kopf“ als Kartentext; Vorbereitung legt dem nicht-allwissenden
  Erzähler alle Kartentexte offen; keine Liste der mechanischen Abweichungen vom Auftrag für den Besitzer.
- **16 kleine Befunde** (Kanon-Uhrzeiten in der Ablauftabelle, zwei Sätze über 25 Wörter, Regiesatz nur bei Olli, Grenzen der
  Aktionskarte nur bei Olli länger, Platzierungen im Erzählerheft, Wortlaute für Teil 90 und Tischregeln u. a.).

---

## Teil A – Protokoll 5: Vollständigkeit je Teil

| Teil | Auftrag | Spezifiziert in | Status | Lücken |
|---|---|---|---|---|
| 00 Erzählerheft | A:133: nicht-allwissend, Vorstellungsfragen, Moderationsimpulse, Skalierung | MECH §9.1–9.13; Fragen RK 2.3–6.3, ZG x.3, ZR x.3 | fast vollständig | Bonus-Ziel des Erzählers ohne Platz (P5-M3); Taschen-Check-Zuordnung ohne Platz (P5-K5); Ablauftabelle mit „0:25“ und „(2:35)“ (P5-K1); Vorbereitung legt Kartentexte offen (P5-M6) |
| 01 Detektivbogen | A:134: Detektivbogen und überarbeiteter Ermittlungsbogen | MECH §1.6, §2, §3.2; RK §6 | vollständig, aber mit Spoiler | XD3-Inhalt und „Handschuh und Ärmel“ vor Spielbeginn (P5-B1); Tischregeln-Kurzform ohne Wortlaut (P5-K7); Seitenzahl 5 statt 6, Spalte „Kein Bund“ nicht in MECH §2.6 (P5-K15) |
| 02 Tisch | A:135: Lageplan, Marker, Tipp-Zettel, Abwesenheitsblatt | MECH §5, §7.1, §10.2; ZG x.11 | vollständig | Drucktitel des Lageplans nicht festgelegt (P5-K8); Format des Streifens (P14-02, nicht wiederholt) |
| 10 Rollenhefte 1–10 | A:136: Auftritt, Gesprächsaufträge, 2-Stufen-System | RK §1–5 (vollständig, mit Seitenplan und Budget); ZG §1–6 | 1–4 vollständig; 5–10 inhaltlich vollständig, Aufbau fehlt | Zeugenhefte ohne Heftaufbau, ohne „Wer du bist“ und „Deine Marker“ wörtlich, ohne Besetzungshinweis (P5-M4, P5-K10) |
| 11 Fassungen | A:137: WW4, JM3, RN7, YW4 | RK §7 | vollständig | – |
| 12 Zusatzhefte | A:138: Rollen 11–18 | ZR §0.7, §1–8 | vollständig | „Was du weißt“ nennt ungespielte Rollen (P5-B4); Umfang (P14, nicht wiederholt) |
| 20 Karten | A:139: Geheimnis-, Aktions-, Indizkarten AD3–YT4 | MECH §3.3, §4.2, §4.4; RK x.8; ZG x.6; ZR x.7 | vollständig | FN3-Vermerk (P5-B2); Anglizismus „Taschen-Check“ (P5-M1); Kartentext „nie Kleidung am Kopf“ (P5-M5) |
| 90 Auflösung | A:140: Meilenstein-Wertung, vier Enden, Rückblende, Wertung aller | MECH §6.1, §6.4, §7.2, §8.2–8.4; ZG x.12; ZR x.13 | lückenhaft | „Die Rollen am Tisch“ fehlt für Ahmet, Fatma, Olli, Can (P5-M2); Seite 2 „Was wirklich war“ ohne Kernsatz, Ersetzungsstellen der Enden unscharf (P5-K6) |

Gezählt und bestätigt:
- Indizkarten: 19 Codes in MECH §3.3, jede mit „Was du findest“ und Vermerk (Ortstermine mit Sammelvermerk). Codes = E3.
- Geheimniskarten „Was ich zugebe“: 18 von 18 wörtlich (RK 4, ZG 6, ZR 8). Solo-Fassungen für 11, 13, 15, 17.
- Aktionskarten: 18 von 18 wörtlich (MECH §4.4), dazu Tipps in allen Heften.
- Vorstellungsfragen und „Dein Auftritt“: 18 Rollen und Detektiv, alle ohne Ziffern.
- Nachbohr-Ziele: jede Rolle 3 × 2, mit Ausweichziel wo nötig.
- Bonus-Ziele: 18 Rollen und Erzähler, jeweils „Erfüllt, wenn …“.
- Zeugenstreifen: 6 von 6 mit Etikett, Protokoll, Vermerk, Schlusszeile.
- Absätze „Die Rollen am Tisch“: 14 von 18 (es fehlen die vier Verdächtigen).
- Platzhalter: keine offenen Stellen. Eckige Klammern sind Besetzungsvarianten (RK §10 Nr. 9).

---

## Teil B – Regelprüfung REG §6 und §9

| Regel | Ergebnis | Befund |
|---|---|---|
| Kein Blut, keine Wunde, kein Schmerz; „bewusstlos, mit einer dicken Beule“ (§6.1, E4) | eingehalten; Treffer nur in Regeltexten | – |
| Schlag nur als Geräusch; kein Schlag-Verb (§6.1, SV) | eingehalten; „In Panik greifst du den Kerzenständer am Fuß“ ist Kanon (`taeter-olli.json`) | – |
| Herr Schneider überlebt in jedem Ende (§6.1) | eingehalten (Kanon-Enden, M-24) | – |
| Getränke; „alkoholfrei“ beim ersten Apfelpunsch (§6.2) | eingehalten; Apfelpunsch nur in WELT und Kanon-Ende 1 („alkoholfreiem“) | – |
| Rauch/Qualm nur mit „Kamin…“ im Satz (§6.2) | eingehalten (Auftritte Hana, Serkan; MECH §1.5, §9.4) | – |
| Fachwortliste, Sperrliste (§6.3, §6.4) | eingehalten | – |
| Anglizismen (§6.4, TON:27, E5) | „Taschen-Check“ (57 Stellen) und „Marker-Check“ neu; „Sorry“ auch in Tims Wissen. „Party-Planerin“, „Fineliner“, „Cardigan“ stehen im Kanon | P5-M1, P5-K16 |
| Verwandtschaft nie Deckungsgrund (§6.4) | ein Verstoß (Lejla) | P5-B5 |
| Fatma „ausgeliehen“, Can „Streich“ (§6.4) | eingehalten | – |
| „Herr Schneider“; bloß „Schneider“ nur bei Olli (§6.4) | eingehalten. „Miete: 0 Euro. Schneider“ ist die Unterschrift auf dem Kanon-Zettel | – |
| Satzlänge ≤ 25, Mittel ≤ 14 (§6.5) | Vorlesetexte: Vorgeschichte Mittel 9,6, Tat-Moment 7,2, Impulse 9,2, Auftritte max. 17. Zwei Sätze mit 26 und 27 Wörtern in Teil 01 | P5-K2 |
| Vorlesetexte ohne Ziffern, Klammern, Abkürzungen (§6.5) | eingehalten (Fragen, Auftritte, Stufe 3, Teil-90-Absätze, Rückblende-Kernsätze, Maßtabelle) | – |
| Uhrzeiten nur Kanon-Minuten (§6.9, TL) | Spieltexte eingehalten; Ablauftabelle MECH §1.1 enthält „0:25“ und Dauern im H:MM-Format | P5-K1 |
| Duzen, Ich-Form (§6.6) | eingehalten; kein Siezen | – |
| Altnamen, Aussprache im Text (§6.7) | keine | – |
| Farbwort-Regel (§6.7) | eingehalten (nur eigene Farbe je Heft; Karten nennen Besitzerfarbe) | – |
| Herkunft nie im Spiel (§6.8) | eingehalten; Herkunft nur in Prüftabellen | – |
| Kopftuch nie Spur/Merkmal; eine Trägerin unbelastet (§6.8, E11) | Tugba unbelastet. Kartentext „nie Kleidung am Kopf“ thematisiert Kopfbedeckung | P5-M5 |
| Komik nicht auf Kosten von Personen (§6.8) | eingehalten (Lage-Komik: Rüstung, Kamin, Klo, Teekanne) | – |
| Raumwörter (§6.9) | eingehalten; Treffer nur in Regeltexten | – |
| Erzähler improvisiert nie (§6.10) | eingehalten (Standardfrage, Marker-Probe, Ausweichsatz, „Herr Schneider antwortet“ wörtlich) | – |
| Kein Verweis auf unbesetzte Rollen (§6.10, F-09) | Verstöße in Wissen-Tabellen | P5-B4 |
| Platzhalterverbot (§6.4, A:132) | eingehalten | – |

Falschtreffer des Werkzeugs (geprüft, kein Befund): Regeltexte in RK §0.3, ZG G-10, ZR ZG-12, MECH §0.2; Zeilenumbruch
„Herr / Schneider“ in Emines und Serkans Karte; zusammengezogene Listenpunkte bei der Satzlänge; Varianten in eckigen Klammern.

---

## Teil C – Spoilerfreiheit

| Prüfpunkt | Ergebnis |
|---|---|
| Erzählerheft ohne Lösung (E10) | Inhalt spoilerfrei: keine Stufe 2, keine Antworten, keine Zuordnung Code → Person. Rundenstarts sind Kanon. Aber: Die Vorbereitung (Teil 00 S. 2) lässt den Erzähler alle Karten schneiden und falten, Druckseite außen (P5-M6). |
| Rollenhefte vorab sendbar ohne Täterwissen (M-31) | verletzt: Unterschied „nichts zu tun“ (P5-B3); kleiner Regiesatz nur bei Olli (P5-K3) |
| Geheimniskarten-Vorderseiten neutral (E8) | eingehalten: „Geheimnis · [Name] · Platz [Nr]“ für alle 18 |
| Kein Name als Urteil auf Karten | Indizkarten nennen Namen nur als Besitz. Ausnahme in der Wirkung: FN3 heißt „Ollis Weste und Pulli“ und trägt „Schlüsselbeweis, Teil 2“ (P5-B2). JT3 zieht den Schluss „Diese Maske war das leuchtende Gesicht“ (P5-K12). Lejlas Streifen gibt „Olli: ✗“ vor (P5-K11) |
| XD3 korrekt (A:107, E3, E12) | Karte richtig: Fundtext mit Holzsplittern und weißem Kalk, Vermerk ohne „Täter“, ab Runde 3. Aber Teil 01 druckt denselben Satz als Regel 2.4 Nr. 1 vor Spielbeginn (P5-B1) |
| Fassungen außen gleich (REG §6.10) | eingehalten: Code und „Versiegelt. Erst öffnen, wenn der Erzähler es sagt.“ |
| Untersuchungsliste | „Eiskübel · ab Runde 3“ als Meta-Hinweis (P2-07, nicht wiederholt) |
| Etiketten der Zeugenstreifen | nennen Freigabe-Codes (P14-05, nicht wiederholt) |

---

## Teil D – Gleiche Gestalt der vier Verdächtigen (E9, REG §6.11)

| Merkmal | Ergebnis |
|---|---|
| Heftgliederung, Überschriften, Budgets | gleich (RK §1.1, §7.7: alle Teile innerhalb 10 %) |
| Stufe 1 | Kernsätze 2/2/2/2, Ausweichsätze 6/6/6/6; aber Regiesatz nur bei Olli und Markersatz nur bei Fatma (P5-K3) |
| Stufe 2 „Ab dann“ | ungleich: drei Hefte enden mit „Mit dem Scheppern hast du nichts zu tun. Dabei bleibst du.“, Ollis mit „Du bleibst bei dieser Geschichte …“ (P5-B3) |
| Pflicht-Auslöser | je drei, keine Sperre: gleich |
| Geheimniskarten | 2 Vermerke, 1 Domino, 55–61 Wörter: gleich |
| Aktionskarten | vier Schutzkarten; Ollis Grenzen einen Satz länger, und die Karten liegen offen (P5-K4) |
| Bonus-Ziele | Typ „Reinen Tisch“: gleich |
| Fassungen | gleich gegliedert, Längen innerhalb 10 % (RN7 +7,8 %) |
| Stufe 3 | gleiche fünf Bausteine |
| Teil 90 „Die Rollen am Tisch“ | fehlt bei allen vier (P5-M2) |

---

## Teil E – Entscheidungen E1–E17

| E | Inhalt | Ergebnis |
|---|---|---|
| E1 | Bestandsschutz | eingehalten (Repo nur gelesen; eigene Dateinamen MECH §10.1) |
| E2 | eigene Druckquelle, Abweichungen dokumentiert, kein Baran/Pawel | eingehalten (WELT §0.3 K-01–K-22, W-01) |
| E3 | Codes WW4, JM3, RN7, YW4; AD3–YT4; XD3, FN3, PP9, JT3, FK3 | eingehalten |
| E4 | Beule statt Platzwunde; Ton REG §6/§9 | eingehalten bis auf P5-B5 |
| E5 | deutsche Spielbegriffe | verletzt durch „Taschen-Check“, „Marker-Check“ (P5-M1) |
| E6 | Zählung, Tandem-Reihenfolge, Solo | eingehalten |
| E7 | Abwesenheitsblatt ab einer fehlenden Rolle 5–10, verdeckt | eingehalten |
| E8 | neutrale Vorderseite, Bedingung nur im Heft | eingehalten |
| E9 | gleiche Gestalt; nur RN7 mit Tat; Ollis Karte neutral | teilweise verletzt (P5-B3, P5-K3, P5-K4) |
| E10 | Erzähler ohne Lösung, Impulse spoilerfrei, tippt mit | Inhalt eingehalten; Vorbereitung und Hefte gefährden es (P5-M6, P5-B3); sein Bonus-Ziel fehlt im Heft (P5-M3) |
| E11 | Tugba ganz unbelastet | eingehalten |
| E12 | Untersuchungen rundengebunden, Fall nicht in Runde 1 | Karten eingehalten; Teil 01 bricht es (P5-B1) |
| E13 | 9 Detektiv-Punkte; Tipp 2/1/2 | eingehalten |
| E14 | Bonus-Ziele mit prüfbarer Bedingung | eingehalten |
| E15 | schwarzweiß, Lageplan aus zwei A4-Blättern quer | eingehalten (M-27) |
| E16 | Erzählerakte nicht in der Druckmappe | eingehalten (nicht in der Teileliste) |
| E17 | Abend-Assistent | nicht Sache der Bibel |

---

## Teil F – Auftrag A:1–140

✓ = erfüllt · ≈ = erfüllt mit begründeter, dokumentierter Abweichung · ✗ = nicht erfüllt.

| A | Wunsch | Stand | Fundstelle / Bemerkung |
|---|---|---|---|
| 4–6 | Druckspiel ersetzt altes; Olli fest; Druckmappe, Probe-Sets | ✓ / später | B1–B3; Teileliste MECH §10.1 |
| 12 | alle Schwächen beheben, lückenlos | ≈ | siehe Befunde |
| 17 | Stil Knives Out | ✓ | nur intern, kein Werktitel im Druck |
| 18 | keine Fronterzählung, keine Papageien, keine Auto-Solve-Karten | ≈ | Vorlesetexte kurz; Ausweichsätze verschieden; JT3-Vermerk zieht den Schluss selbst (P5-K12) |
| 19 | 6–20 Personen, Zwiebel | ✓ | E6, MECH §9.13 |
| 24 | Rolle heißt „Erzähler“ | ✓ | |
| 25 | Erzähler kennt den Täter nicht; Teil 90 versiegelt | ≈ | Inhalt ✓; Vorbereitung und Hefte gefährden es (P5-M6, P5-B3) |
| 27 | kurze Moderation statt Vorlesewüste | ✓ | MECH §9 |
| 28 | Vorstellungsrunde: Frage, Spieler antwortet selbst | ✓ | alle 19 Fragen und Auftritte |
| 29 | Erzähler verwaltet Lageplan, Marker | ✓ | MECH §9.7, §1.3 e |
| 30 | 3–4 spoilerfreie Impulse je Runde | ≈ | je 4 plus Domino-Frage; Beispiel aus A:30 ersetzt (M-25), nicht in einer Abweichungsliste (P5-M7) |
| 31 | Erzähler tippt mit | ≈ | Tipp-Zettel ✓; sein Bonus-Ziel fehlt im Heft (P5-M3) |
| 38 | NPC-Beobachtungen in Rollen 5–10 | ✓ | ZG |
| 39 | Ahmet | ✓ | RK §2, WELT §7.1 |
| 40 | Fatma | ✓ | RK §3 |
| 41 | Olli | ✓ | RK §4, §7.5; Kanon-Ton |
| 42 | Can | ✓ | RK §5, §7.6 |
| 43–44 | Lejla | ≈ | Quittungszettel → Belegungsblatt (D-11) |
| 45–46 | Emine | ≈ | „lag“ → kauerte (D-27); Kanon-Wortlaut der Drohung (D-29) |
| 47–48 | Tim | ✓ | Wachs aus Wojteks Kasten über Tim (W-11) |
| 49–50 | Joanna | ✓ | Notiz W-08, Wortlaut WELT §5.4 |
| 51–52 | Marek | ≈ | sieht das Gesicht vom Ostende, nicht von der Schwelle zum Durchgang (W-06); Nachzahlung pro Gast (W-12) |
| 53–54 | Zeynep | ≈ | „noch jemand stritt“ → Herr Schneider brüllt noch (WELT §5.3) |
| 57 | Abwesenheitsblatt 6–9 | ≈ | 6–11 Personen (E7) |
| 58 | 10 Personen Standard; Erzähler = Detektiv | ≈ | Variante entfällt (E6, D-21) |
| 59–60 | Zusatzrollen, Hefte, Handlungskarten, Tandems, Rand-Indiz | ✓ | ZR |
| 61 | Tandem 1 | ≈ | Splitter unter den Sockel statt unter den Teppich (Wortspiel) |
| 62 | Tandem 2 | ≈ | nur Wunderkerzen, keine zweite Torte (D-31) |
| 63 | Tandem 3 | ✓ | |
| 64 | Tandem 4 | ≈ | Tugba harmlos (E11) |
| 71 | Vorgeschichte ≤ 1 Seite | ✓ | rund 280 Wörter |
| 72 | Auftritt mit Anekdoten der Dias 3–5 | ✓ | Sibel, Olli, Hana; Beispielfrage an Olli übernommen |
| 73 | Tat-Moment vorlesen | ≈ | ohne Platzwunde (E4), „kurz darauf“ statt Sekunden |
| 76 | Lageplan-Doppelseite, ausschneidbare Marker | ≈ | Blatt A + Blatt B (M-27); Drucktitel fehlt (P5-K8) |
| 78–85 | acht Zonen mit Gegenständen | ≈ | Eiskübel am Ostende (W-02) |
| 86 | Marker setzen, bei Lüge umstellen | ✓ | R-06 |
| 89–92 | 2 Ziele je Runde, Stufe 1, Stufe 2 mit Sobald und Domino | ✓ | alle Hefte |
| 93–96 | Olli drei Stufen | ≈ | alle vier drei Stufen (REG §9 Nr. 15); Olli gesteht bei Anklage unabhängig vom Beweisstand (RK-14) |
| 99 | Stimmkarten und Umschläge streichen | ✓ | |
| 100–101 | Geheimniskarte mit Vermerk; Auslöser auf der Vorderseite | ≈ | Auslöser nur im Heft (E8) |
| 102 | Aktionskarte je Rolle; Beispiele | ≈ | „Taschen-Check“ als Anglizismus (P5-M1); Ollis Karte neutral (E9) |
| 105 | drei Untersuchungen je Runde | ✓ | plus Ortstermine (M-01) |
| 106 | Fehlerkorrektur 1: Can-Alibi | ≈ | Tim/Marek „für das leuchtende Gesicht“ (M-11), Zeynep direkt |
| 107 | Fehlerkorrektur 2: XD3 ohne Namen | ≈ | Vermerk ohne „Täter“ (REG §9 Nr. 17); Teil 01 und FN3 lecken (P5-B1, P5-B2) |
| 108–112 | Fehlerkorrektur 3: neun Meilensteine | ✓ | MECH §6.1 |
| 115–121 | Tipp-Runde für alle inkl. Erzähler, 2/1/2 | ≈ | Detektiv ohne Zettel (M-21); Frage 1 umformuliert (REG §9 Nr. 3) |
| 128–132 | Selbsttests | in Arbeit | P1–P5 |
| 133–140 | Teile 00–90 | ≈ | siehe Teil A |

Gesamt: Kein Wunsch ist stillschweigend weggefallen. Viele Wünsche sind begründet abgewandelt. Diese Abwandlungen der
Mechanik stehen aber verstreut in M-, RK-, ZG-, ZR-Entscheidungen; eine Liste für den Besitzer fehlt (P5-M7).

---

## Teil G – Befunde

### Blocker

**P5-B1 · Blocker · MECH §2.1 Z. 208, §2.4 Z. 245–249; RK §6.9 Z. 956 (bestätigt P2-01)**
- Problem: Teil 01 wird vorab gesendet. Sein Bogen druckt „Schlüsselbeweis: Teil 1, Kerzenständer ☐ · Teil 2, Handschuh und
  Ärmel ☐“ und Regel 2.4 Nr. 1 „Wer den Kerzenständer am Fuß hielt, hatte Holzsplitter und weißen Kalk am Ärmel.“ Das ist der
  Vermerk von XD3 (ab Runde 3) im Klartext. Mit YT4 oder Ollis Karte („aus der gekalkten Wand gerissen“) in Runde 1 ist der Fall
  gelöst. Verstößt gegen E12, A:107 (Sinn der Fehlerkorrektur 2) und MECH §3.5.
- Vorschlag, wörtlich:
  - MECH §2.1: „**Schlüsselbeweis:** Teil 1 ☐ · Teil 2 ☐ · gehört zu: ______________“
  - MECH §2.4: „**Wer überführt ist:** Eine Person ist überführt, wenn drei Dinge offen auf dem Tisch liegen: 1. eine Karte mit
    dem Vermerk ‚Schlüsselbeweis, Teil 1‘. 2. eine Spur an einer Person, die genau zu Teil 1 passt (Teil 2). 3. Der Fundort des
    Schlüsselbunds liegt an einem Platz, an dem diese Person kurz vor dem Scheppern nachweislich war (Zeile ‚Ort um 23:57‘).
    Dann scheiden alle anderen aus.“
  - RK §6.9, letzter Satz: „Teil 1 kreuzt du an, wenn eine Karte mit dem Vermerk ‚Schlüsselbeweis, Teil 1‘ offen liegt. Teil 2
    kreuzt du an, wenn eine offene Karte an einer Person genau die Spur zeigt, die Teil 1 beschreibt. Dann schreibst du dazu, zu
    wem er gehört.“

**P5-B2 · Blocker · MECH §3.3 FN3 Z. 354 (zweiter Vermerk), §3.2 Z. 313 (bestätigt P2-02)**
- Problem: FN3 („Ollis Weste und Pulli“) ist ab Runde 2 frei, auch per Taschenkontrolle. Der Vermerk „Schlüsselbeweis, Teil 2: …
  Zusammen mit Teil 1 zeigt das, wer den Kerzenständer hielt.“ steht auf Ollis Kleidung. Das ist der Namens-Urteil-Satz, den
  A:107 verbietet, nur auf der zweiten Karte. Der Fall fällt in Runde 2.
- Vorschlag, wörtlich:
  - FN3 Vermerk 1: „Hinweis · Heimlichtuerei: An den Fingerkuppen kleben braunes Möbelwachs und weißer Kalk. Vergleiche die
    Bogentür (YT4).“
  - FN3 Vermerk 2: „Hinweis: Auf dem Handrücken frische rote Kerzenwachstropfen. An den Bündchen des Pullis Kalkstaub und feine
    Holzsplitter.“
  - XD3 Vermerk: „Schlüsselbeweis, Teil 1: Im roten Wachs am Fuß kleben feine Holzsplitter und weißer Kalk. Wer den
    Kerzenständer am Fuß hielt, hatte beides am Ärmel. Teil 2 ist die passende Spur an einer Person.“
  - MECH §6.1 M9: „XD3 und FN3 offen, Teil 1 und Teil 2 angekreuzt, ‚gehört zu: Olli‘.“

**P5-B3 · Blocker · RK §2.7 Z. 286, §3.7 Z. 440, §5.7 Z. 764 gegen §4.7 Z. 601 („Ab dann“); RK §8.2**
- Problem: Die Hefte von Ahmet, Fatma und Can enden in Stufe 2 mit „Mit dem Scheppern hast du nichts zu tun. Dabei bleibst du.“
  Ollis Heft endet mit „Du bleibst bei dieser Geschichte. … Den Türschaden willst du selbst mit Herrn Schneider klären.“ Die Hefte
  sind vorab sendbar (MECH §10.3, M-31) und gehen durch die Hände des Erzählers. Wer zwei Hefte sieht, kennt den Täter. Verstößt
  gegen E9 (gleiche Gestalt), E10 und REG §6.10/§6.11 („Die Täterrolle fällt nie auf“). RK §8.2 prüft diesen Satz nicht.
- Vorschlag, wörtlich: In allen vier „Ab dann“-Texten den Schluss gleich setzen:
  - Ahmet: „… Den leeren Umschlag hast du in den Ascheneimer am Kamin geworfen. Mehr gibst du nicht zu. Dabei bleibst du.“
  - Fatma: „… Sie bleibt in deiner Tasche, bis Herr Schneider sie nimmt. Mehr gibst du nicht zu. Dabei bleibst du.“
  - Can: „… Im Turm hört man nichts. Sag das ehrlich. Mehr gibst du nicht zu. Dabei bleibst du.“
  - Olli: „Ab jetzt sagst du offen, was an der Bogentür war. Sag immer ‚das Gespenst‘ oder ‚das leuchtende Gesicht‘, nie einen
    Namen. Fragt jemand, wer es war: ‚Erkannt hab ich nur das Leuchten.‘ Woher das Möbelwachs kam, sagst du nicht. Mehr gibst du
    nicht zu. Dabei bleibst du.“
  - Der Satz „Mit dem Scheppern hast du nichts zu tun.“ wandert in „Dein Heft und die Wahrheit“ der drei Fassungen WW4, JM3,
    YW4 (versiegelt). RK §8.2 um die Zeile „‚Ab dann‘: gleicher Schlusssatz“ ergänzen.

**P5-B4 · Blocker · Gedruckte Wissen-Tabellen nennen ungespielte Rollen (REG §6.10 F-09, WELT §1.1; Klasse von P14-01)**
- Fundstellen (Zeilennummern der Datei):
  - ZR §2.5 Z. 431 (Damir, ab 14 P.): „Tugbas Ruf zur blinden Kuh“ – Tugba spielt erst bei 20 P.
  - ZR §4.5 Z. 786 (Serkan, ab 16 P.): „Aylin sagt, den Schlüssel fürs Außentor …“ – Aylin erst ab 19 P.
  - ZR §6.5 Z. 1125 (Wojtek, ab 18 P.): „Tugba nimmt dem Detektiv Augenbinde und Kopfhörer ab“ – Tugba erst bei 20 P.
  - ZR §1.5 Z. 254, 258 (Sibel, ab 13 P.): „Hana steht an der Kamin-Nische“ – Hana erst ab 15 P. Die Fehlt-Tabelle 1.11 nennt
    die Ersatzfassung, die Zeilen tragen aber kein Markup.
  - ZG §3.4 Z. 490 (Tim, ab 9 P.): „droht Herr Schneider Marek“ – Marek erst ab 11 P.; Z. 500, 504: „Zeynep steht dort“, „Sie
    zeigt Zeynep im Steinbogen“ – Zeynep erst ab 12 P.
  - ZG §4.4 Z. 695 (Joanna, ab 10 P.): „Zeynep ruft aus dem Steinbogen“ – Zeynep erst ab 12 P. (Die Notiz selbst darf Zeynep nach
    W-21 nennen, die Wissen-Zeile nicht.)
- Problem: ZR §0.7 druckt „Was du weißt“ im Zusatzheft. Die Tabelle in ZG trägt selbst Besetzungsvarianten (Tim 18:00), wird
  also auch gedruckt. Dann steht der Name eines Gastes im Heft, den heute niemand spielt.
- Vorschlag, wörtlich (Markup G-08):
  - Damir 23:55: „[Tugba \| Ein Gast] ruft zur blinden Kuh; sein Handy kommt in den Korb“
  - Serkan 0:03: „Buffetsaal: [Aylin \| Ein Gast] sagt, den Schlüssel fürs Außentor gibt es nur zweimal“
  - Wojtek 0:00: „[Tugba \| Ein Gast] nimmt dem Detektiv Augenbinde und Kopfhörer ab“
  - Sibel 23:50: „… [Hana \| Ein Gast] steht an der Kamin-Nische …“; 0:00: „Licht. Zeynep steht im Steinbogen, [Hana \| ein Gast]
    an der Kamin-Nische“
  - Tim 18:30: „Im Schlosshof droht Herr Schneider [Marek \| dem Caterer]: …“; 23:55: „geht durch den Steinbogen [(Zeynep steht
    dort) \|], den Durchgang und die Klappe …“; kurz vor zwölf: „findet die Stirnlampe am Boden. [Sie zeigt Zeynep im
    Steinbogen. \|]“
  - Joanna 23:55: „… [Zeynep \| Jemand] ruft aus dem Steinbogen: ‚Komm gleich!‘ …“
  - Neue Regel in ZG G-08 und ZR ZG-10, wörtlich: „Jede gedruckte Zeile, die eine Rolle mit höherem Platz nennt, trägt einen
    Platzhalter. Der Prüfer der Text-Phase vergleicht jeden Namen 5–18 in Teil 10, 12, 20 und 90 mit der Besetzung.“

**P5-B5 · Blocker · ZG §1.5 Z. 174 (Lejla, „Das behältst du für dich“)**
- Problem: „Ahmet ist mein Cousin. Über seine Sachen redet er selbst.“ Das Schweigen wird mit der Verwandtschaft begründet. REG
  §6.4 (`ENTSCHEIDUNGSLOG.md:693`, `:718`): Verwandtschaft nur als Tatsache in „Wer du bist“, Schweigen nur aus Versprechen oder
  Mitschuld. ZG §1.1 nennt das Versprechen selbst.
- Vorschlag, wörtlich: „Ich hab Ahmet etwas versprochen. Über seine Sachen redet er selbst.“

### Mittel

**P5-M1 · mittel · MECH §4.4 Z. 552 (Name „Taschen-Check“), §1.3 e Z. 128 („Marker-Check“), dazu 57 Stellen in RK, ZG, ZR**
- Problem: „Check“ ist ein Anglizismus. TON:27 erlaubt nur Handy, Box, Design, Catering, Hobby, Dips. E5 verlangt deutsche
  Spielbegriffe. Der Name steht auf einer Karte und in vielen Auslösern. Der Kanon kennt das Wort nicht.
- Vorschlag: Karte umbenennen in **Taschenkontrolle**, Abschnitt e in **Marker-Probe**. Wirkung wörtlich: „Eine Person deiner
  Wahl leert ihre Taschen und zeigt, was sie bei sich trägt. Gibt es dafür eine Indizkarte, legt der Erzähler sie offen hin, ohne
  dass der Detektiv eine Untersuchung verbraucht. Sonst sagt die Person, was in ihrem Heft unter ‚Was du bei dir trägst‘ steht.“
  Alle Auslöser entsprechend („Sobald eine Taschenkontrolle bei dir …“). Will der Besitzer A:102 wörtlich, als Abweichung in
  P5-M7 aufnehmen.

**P5-M2 · mittel · MECH §8.4 Seite 7–8; RK (kein Abschnitt „Absatz für Teil 90“)**
- Problem: „Die Rollen am Tisch“ verlangt für jede gespielte Rolle einen Absatz. ZG und ZR liefern 14. Für Ahmet, Fatma, Olli
  und Can fehlt er, obwohl sie immer gespielt werden. Teil 90 ist damit unvollständig (A:140).
- Vorschlag, wörtlich (Vorlesen, gleiche Gestalt, je drei Sätze):
  - Ahmet: „Ahmet hatte von allen Miete eingesammelt, obwohl der Keller nichts kostete. Mit dem Geld wollte er die viel zu große
    Essensrechnung bezahlen. Beim Scheppern kauerte er hinter der Theke am Ostende, an [Mareks \| den] Beinen [\| des Caterers].“
  - Fatma: „Fatma hatte um zwanzig vor zwölf die Münzschatulle ausgeliehen, um das Wappen abzuzeichnen. An der Theken-Klappe
    wollte sie sie zurückgeben. Beim Scheppern kauerte sie schon hinter dem linken Buffettisch neben [Emine \| ihrer besten
    Freundin].“
  - Olli: „Olli hatte beim Tragen die Bogentür beschädigt und die Schramme mit Möbelwachs überdeckt. Um drei vor zwölf stand er
    am Eiskübel und wollte mit Herrn Schneider reden. Im Dunkeln hat ihn die Panik gepackt.“
  - Can: „Can wartete mit einer Leuchtmaske im dunklen Vorratsraum, um die blinde Kuh zu erschrecken. Herr Schneider packte
    seine Kapuze, doch Can riss sich los und rannte in den Turm, bevor es schepperte. Die gelben Fasern waren eine falsche Fährte.“
  - Einfacher für den Satz bei Ahmet: „… hinter der Theke am Ostende, und [Marek \| der Caterer] spürte ihn die ganze Zeit.“

**P5-M3 · mittel · MECH §7.3 Z. 783 gegen §9.1, §9.12**
- Problem: Das Bonus-Ziel des Erzählers steht nur in der Spezifikation. Das Erzählerheft hat keinen Platz dafür. Der Erzähler
  füllt Frage 3 seines Tipp-Zettels aus, ohne sein Ziel zu kennen.
- Vorschlag: MECH §9.1 Seite 13–14: „Runde 3, dein Bonus-Ziel, Tipp-Runde, Anklage, Auflösung (9.12)“. In §9.12 vor der
  Tipp-Runde, wörtlich (Anleitung): „Dein eigenes Bonus-Ziel: Bei der Tipp-Runde liegen mindestens drei Viertel der
  Geheimniskarten der gespielten Rollen offen. Zähl nach, bevor du deinen Zettel ausfüllst.“ Dasselbe Ziel steht in Teil 90 bei
  der Tipp-Wertung.

**P5-M4 · mittel · ZG gesamt (keine Heftgliederung); MECH §10.1 Teil 10 (Überschneidung P14-17)**
- Problem: Für die Rollenhefte 5–10 fehlt der Aufbau (Seiten, Reihenfolge, Budget). Es fehlen außerdem „Wer du bist“ als
  wörtlicher Text (nur Profiltabelle), die Markerzeile wörtlich (RK hat sie, ZG nur als Tabelle) und die Tischregeln-Kurzform.
  Die Text-Phase müsste raten, was gedruckt wird (siehe auch P5-B4).
- Vorschlag: ZG §0.6 neu „Aufbau des Zeugenhefts (Teil 10, vier Seiten)“, wörtlich als Gliederung:
  „Seite 1: Kopf ‚Rollenheft · [Name] · Platz [Nr]‘ · ‚Dein Auftritt bei der Vorstellung‘ · ‚Wer du bist‘ (Profil, Beziehungen
  als Tatsache, Haltung) · ‚Was alle wissen‘. Seite 2: ‚Deine Marker‘ · ‚Was du weißt‘ (nur Zeilen ‚offen‘; Zeilen ‚Karte‘ mit dem
  Zusatz ‚erst nach dem Umdrehen‘) · ‚Stufe 1‘ (sagst du jedem, behältst du für dich, verboten) · ‚Wenn der Erzähler fragt‘.
  Seite 3: ‚Stufe 2: Wann du umdrehst‘ · ‚Was du dann zugibst‘ (Karteninhalt) · ‚Nach dem Umdrehen‘ · ‚Gesprächsaufträge
  Runde 1–3‘. Seite 4: ‚Was du bei dir trägst‘ · ‚Deine Aktionskarte‘ mit Tipp · ‚Dein Bonus-Ziel‘ · ‚Wenn du angeklagt wirst:
  Ich war es nicht.‘ · Tischregeln · Besetzungshinweis · Notizen.“ Markerzeile je Zeuge wörtlich, Muster: „Marker 23:57:
  Rechtes Buffet (3). Marker Scheppern: Rechtes Buffet (3). Beide stimmen.“ „Wer du bist“ je Zeuge wörtlich, Muster RK §2.4.

**P5-M5 · mittel · MECH §4.4 Z. 552 (Grenzen Taschen-Check), §4.3 Z. 537; ZG §5.8 Z. 981**
- Problem: Der Kartentext „Nur Taschen und Gegenstände, nie Kleidung am Kopf.“ macht Kopfbedeckung am Tisch zum Thema. Drei
  Rollen tragen Kopftuch. TON:64: Kopftuch ist Kleidung wie jede andere. REG §9 Nr. 18 meint eine Gestaltungsgrenze, keinen
  gedruckten Satz. Zudem widerspricht „nur Taschen und Gegenstände“ den Karten, die die Kontrolle öffnet: FN3 zeigt
  Pulli-Bündchen, NN3 den Mantelärmel.
- Vorschlag, wörtlich: Grenzen: „Nur Taschen und was die Person bei sich trägt. Nur Indizkarten, die in dieser Runde schon frei
  sind.“ In MECH §4.3 bleibt die Gestaltungsregel intern: „Keine Karte und keine Indizkarte betrifft Kopfbedeckungen.“

**P5-M6 · mittel · MECH §9.1 Seite 2, §10.5, §4.1 (Format „Druckseite außen“), §5.2**
- Problem: Das Erzählerheft macht den Erzähler zur Person, die alle Teile vorbereitet. Er schneidet und faltet 19 Indizkarten,
  bis zu 18 Geheimniskarten, die Zeugenstreifen und klebt die vier Fassungen. Bei „Druckseite außen“ liegen die Innentexte
  offen auf dem Bogen und nach dem Falzen außen auf der Rückseite. „Einseitig drucken, nichts lesen“ ist der einzige Schutz. Damit
  hängt der Kern von A:25 und E10 an Selbstdisziplin; XD3 und FN3 nebeneinander verraten die Lösung.
- Vorschlag:
  - Erzählerheft Seite 2, wörtlich: „Am besten schneidet und faltet eine Person, die heute weder Erzähler noch Detektiv ist.
    Machst du es selbst: Schneide an den Linien, lies nichts, und leg jede fertige Karte sofort mit dem Code nach oben ab.“
  - Faltbild für Indizkarten und Geheimniskarten als Z-Falz mit drei Feldern (Etikett, Text, leeres Deckfeld): Nach dem ersten
    Falz liegt der Text innen. „Umdrehen“ heißt dann „aufklappen“. MECH §4.1 und §3.3 entsprechend anpassen.
  - MECH §1.3 d, wörtlich: „Der Erzähler nimmt die Karte mit dem Code nach oben aus dem Stapel und reicht sie zugeklappt weiter.“

**P5-M7 · mittel · MECH §12 (Entscheidungen) und RK, ZG, ZR; REG §10, A-2**
- Problem: WELT §0.3 listet die Abweichungen der Welt vom Kanon für den Besitzer. Für die Abweichungen der Mechanik vom Auftrag
  gibt es keine solche Liste. Sie stehen verstreut in M-, RK-, ZG-, ZR-Nummern. Der Besitzer sieht so nicht auf einen Blick, wo
  sein Text bewusst nicht wörtlich umgesetzt ist.
- Vorschlag: MECH §12a neu „Abweichungen vom Auftrag (Mechanik), zur Kenntnis des Besitzers“, mit mindestens diesen Zeilen:
  A:30 Beispielimpuls → alle vier gefragt (M-25) · A:57 6–9 → 6–11 Personen (E7) · A:58 Erzähler = Detektiv entfällt (E6) · A:76
  Lageplan als Blatt A und Markerfelder Blatt B (M-27) · A:93/96 alle vier mit Stufe 3; Olli gesteht bei Anklage auch ohne XD3,
  FN3, PP9 (RK-14) · A:95 Olli sagt „das Gespenst“, nicht Can (W-25) · A:101 Auslöser nicht auf der Vorderseite (E8) · A:102
  Ollis Karte neutral (E9), Kartenname (P5-M1) · A:106 Vermerk „für das leuchtende Gesicht“ (M-11) · A:107 Satz ohne „Täter“ (REG
  §9 Nr. 17) · A:116 kein Tipp-Zettel für den Detektiv (M-21) · A:118 Tipp-Frage 1 umformuliert · A:120 „Überfall“ → „bis
  feststeht, dass er es nicht war“ · A:61 Sockel statt Teppich · A:62 keine Überraschungstorte · A:64 Tugba harmlos (E11) · A:73
  Beule statt Platzwunde (E4).

### Klein

**P5-K1 · klein · MECH §1.1 Z. 83–99 (Ablauftabelle, steht im Erzählerheft Seite 3)**
- Problem: Spalte „Uhr im Spiel“ enthält „0:25“, die Summenzeile „(2:35)“, „(2:47)“, „(2:56)“. Der Uhrzeiten-Prüfer (TL) meldet
  jede H:MM-Zeit, die nicht im Kanon steht. „0:25“ steht nicht in der Kanon-Liste (WELT §0.2).
- Vorschlag: Zeile 6 „0:20“ statt „0:25“ oder leer. Summenzeile wörtlich: „155 min“ · „167 min“ · „176 min“, ohne H:MM.

**P5-K2 · klein · RK §6.5 Z. 871 und Z. 878 (Teil 01, Kasten „Deine Aufgaben je Runde“)**
- Problem: Zwei Sätze mit 26 und 27 Wörtern (REG §6.5: höchstens 25).
- Vorschlag, wörtlich: R1: „Verhörstuhl, zweites Ziel: Frag alle, deren Marker ‚Scheppern‘ im Buffetsaal steht. ‚Wer war im
  Dunkeln neben dir, seit wann, und woran hast du die Person erkannt?‘“ R2: „Verhörstuhl, zweites Ziel: Frag alle: ‚Was ist heute im
  Turmgang und an der Bogentür passiert?‘ Dann frag: ‚Wer hat das leuchtende Gesicht gesehen, und wo standest du da?‘“

**P5-K3 · klein · RK §4.6 Z. 566 (Ollis Regiesatz), §3.6 Z. 418 (Fatmas Markersatz); RK §8.2**
- Problem: Nur Ollis Heft hat einen Regiesatz („wie jemand, der den ganzen Abend gesessen hat“), nur Fatmas einen Markersatz.
  Beides fällt beim Vergleich der Hefte auf.
- Vorschlag, wörtlich: Regiesatz für alle vier: Ahmet „Bleib dabei geschäftig, wie jemand, der an alles denkt.“ · Fatma „Bleib
  dabei freundlich und ein bisschen abgelenkt, wie jemand, der nur Farben im Kopf hat.“ · Can „Bleib dabei albern, wie jemand,
  der nichts ernst nimmt.“ · Olli unverändert. Markersatz für alle vier: Ahmet „Dein Marker stimmt. Fragt jemand nach dem Grund,
  bleib bei den Servietten, bis deine Karte offen ist.“ · Olli „Deine Marker fallen nur mit deiner Karte. Dann stellst du beide
  auf den Eiskübel.“ · Can „Dein Marker ‚23:57‘ fällt nur mit deiner Karte. Dann stellst du ihn auf den Vorratsraum.“

**P5-K4 · klein · MECH §4.4 Z. 546 (Themenwechsel, Grenzen); RK §4.10 Z. 641**
- Problem: Aktionskarten liegen offen. Nur Ollis Schutzkarte hat einen dritten Grenzsatz („In der nächsten Runde darf das Thema
  wiederkommen.“).
- Vorschlag, wörtlich, für alle vier Schutzkarten gleich: „Nicht gegen einen Ortstermin, eine Indizkarte oder eine Karte, die
  schon offen liegt. Was offen liegt, bleibt liegen. Die Frage darf später wiederkommen.“

**P5-K5 · klein · MECH §4.4 Z. 563 gegen §9.1**
- Problem: Die Zuordnung bei der Taschenkontrolle „steht im Erzählerheft“, hat dort aber keine Seite.
- Vorschlag: §9.1 Seite 15 ergänzen, wörtlich: „Taschenkontrolle: Ollis Weste → FN3, Cans Bauchtasche → JT3, Fatmas Tasche →
  NN3. Bei allen anderen liest die Person ‚Was du bei dir trägst‘ vor.“

**P5-K6 · klein · MECH §8.4 Seite 2, §8.2 M-24**
- Problem: „Was wirklich war“ ist die wichtigste Vorleseseite von Teil 90, hat aber keinen Kernsatz. Bei den Enden ist nicht
  festgelegt, welchen Kanon-Satz die PP9-Fassung genau ersetzt.
- Vorschlag, wörtlich (Vorlesen): „Es war Olli. Um drei vor zwölf stand er am Eiskübel. Als das leuchtende Gesicht schon weg
  war, ging er über die Theken-Klappe zur Vorratsraumtür. Im Dunkeln hat ihn die Panik gepackt. Den Schlüsselbund hat er unter
  die Eiswürfel im Eiskübel geschoben. Der Schlüsselbeweis: Holzsplitter und weißer Kalk im Wachs am Fuß des Kerzenständers,
  dazu die roten Kerzenwachstropfen auf Ollis rechtem Handschuh.“ Ersetzungsregel M-24, wörtlich: „In Ende 1 und 2 ersetzt der
  PP9-Satz den Satz ‚Olli holt den Bund unter dem Eis im Eiskübel hervor und gibt ihn heraus.‘ In Ende 3 und 4 ersetzt er die
  Sätze ‚Der Schlüsselbund bleibt verschwunden. Um sieben Uhr schließt Herrn Schneiders Kollegin mit ihrem Torschlüssel das
  Außentor auf.‘“

**P5-K7 · klein · MECH §1.4 („stehen gekürzt in jedem Rollenheft“), §2.6 Seite 2; RK §1.1**
- Problem: Die Kurzform der Tischregeln steht in 18 Heften und Teil 01, hat aber keinen Wortlaut.
- Vorschlag, wörtlich (Heftkasten „So spielt ihr“): „Jeder darf jeden fragen. Lügen darfst du nur, wenn dein Heft es erlaubt.
  Sobald ein Auslöser aus deinem Heft eintritt, drehst du deine Geheimniskarte sofort um. Was offen liegt, bestreitest du nicht
  mehr. Widerspricht etwas Offenes deinem Marker, stellst du ihn sofort um. Deine Aktionskarte spielst du einmal, nur im Gespräch.“

**P5-K8 · klein · MECH §10.2 Blatt A**
- Problem: A:76 nennt den Titel „Lageplan: Gewölbekeller unter dem Schlossturm“. Die Spezifikation legt keinen Drucktitel fest.
- Vorschlag: §10.2 Blatt A ergänzen, wörtlich: „Titel oben links: ‚Lageplan: Gewölbekeller unter dem Schlossturm‘.“

**P5-K9 · klein · RK §2.8 Z. 293 (Ahmet), §3.8 Z. 445 (Fatma); ZG §2.6 Z. 365 (Emine)**
- Problem: „Was ich zugebe“ hat nach Prüferzählung (Uhrzeit = zwei Zahlfolgen, REG §6.5) 61 Wörter, erlaubt sind 60 (MECH §4.1).
- Vorschlag: Ahmet „Ich hatte das Essen zu groß bestellt.“ · Fatma „Ich wollte das Wappen abzeichnen, für meine Abschlussarbeit.“ ·
  Emine „Er sagte: ‚Die Schatulle. …‘“ (ohne „leise“).

**P5-K10 · klein · ZG, ZR (Besetzungshinweis fehlt); RK §1.1 Z. 80**
- Problem: Nur die vier Verdächtigen haben „Jede Person kann [Name] spielen, egal welches Geschlecht sie hat.“ REG §9 Nr. 25
  (8 m / 10 w bei 18 Rollen) braucht den Satz in jedem Heft.
- Vorschlag: In ZG und ZR je Heft unten auf der letzten Seite, wörtlich: „Jede Person kann [Name] spielen, egal welches Geschlecht
  sie hat.“

**P5-K11 · klein · MECH §5.3 Z. 630; ZG §1.11 Z. 269 (Vermerk Lejla-Streifen)**
- Problem: „Alibi beim Scheppern · Olli: ✗ – …“ druckt das Urteil gleich mit. Andere Vermerke nennen nur den Kernfakt; das Zeichen
  setzt der Detektiv (MECH §2.1).
- Vorschlag, wörtlich: „Alibi beim Scheppern · Olli: nicht am rechten Buffettisch. Er kam erst nach dem Scheppern dorthin.“

**P5-K12 · klein · MECH §3.3 JT3 Z. 367 (Vermerk)**
- Problem: „Diese Maske war das leuchtende Gesicht im Dunkeln.“ zieht den Schluss für den Tisch (Nähe zu A:18 „Auto-Solve“).
- Vorschlag, wörtlich: „Heimlichtuerei: In Cans Bauchtasche steckt eine Maske mit grünlich-weißer Leuchtfarbe.“ M6-Stichwort
  „Maske“ bleibt erfüllt.

**P5-K13 · klein · MECH §9.7 Schritt 6 Z. 950**
- Problem: „Was darauf steht, wann, steht auf dem Etikett.“ ist unklar.
- Vorschlag, wörtlich: „Wann sie aufgedeckt werden, steht auf ihrem Etikett.“

**P5-K14 · klein · MECH §9.8 Z. 960–961**
- Problem: „Danach wird es ernst.“ (Runde 2, Schluss) und „Jetzt wird es ernst.“ (Runde 3, Start, Kanon) folgen direkt aufeinander.
- Vorschlag, wörtlich, Runde 2 Schluss: „Die zweite Runde ist vorbei. Macht eine Pause. Holt euch Tee oder Saft. Danach kommt die
  letzte Runde.“

**P5-K15 · klein · MECH §2.6, §10.1 gegen RK §6.7 und RK §10 Nr. 3**
- Problem: RK-19 verlangt die Spalte „Kein Bund ☐“ in der Untersuchungsliste und rechnet mit sechs Seiten. MECH §2.6 und §10.1
  sind nicht nachgezogen (5 Seiten, Spalten 1–4).
- Vorschlag: §2.6 Seite 3: „… Kästchen ‚gewählt in Runde __‘ und ‚Kein Bund ☐‘“; §10.1 Teil 01: „6 / 6 / 6“.

**P5-K16 · klein · ZG §3.4 Z. 506 (Tim, Wissen 0:01)**
- Problem: „Hier, dein Eis. Sorry, hat gedauert.“ RK §0.3 erlaubt „Sorry“ nur als Zitat in RN7.
- Vorschlag: In Tims Heft wörtlich: „Olli bringt ihm Eis in einer Serviette: ‚Hier, dein Eis. Hat gedauert.‘“

---

## Teil H – Was hält (geprüft, ohne Befund)

- Alle Vorlesetexte des Erzählers sind kurz, ziffernfrei, ohne Klammern und Abkürzungen; Mittelwerte 7–10 Wörter je Satz.
- Gewalt, Getränke, Rauch, Fachwörter, Sperrliste, Altnamen, Siezen, Herkunft: keine Verstöße im Spieltext.
- Das Erzählerheft enthält keine Lösung, keine Stufe 2, keine Zuordnung Code → Person; die Impulse fragen alle oder alle vier.
- Geheimniskarten-Vorderseiten sind für alle 18 gleich und neutral. Fassungen außen gleich.
- XD3 trägt den Fundtext aus A:107 und den Vermerk ohne „Täter“; XD3, PP9 ab Runde 3, FN3 ab Runde 2 (E12).
- Tugba ist ganz unbelastet; kein Text nennt ein Kopftuch; Taschenkontrolle betrifft nur Taschen (nach P5-M5 auch im Wortlaut).
- Die vier Fassungen und die vier Rollenhefte sind gleich gegliedert und innerhalb von zehn Prozent gleich lang.
- Jeder Teil 00 bis 90 hat eine Inhaltsangabe; keine Platzhalter außer den dokumentierten Besetzungsvarianten.
- Alle 140 Zeilen des Auftrags sind abgedeckt; jede Abwandlung hat eine Begründung in E, W, M, RK, ZG oder ZR.
