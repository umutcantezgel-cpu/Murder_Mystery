# Prüfprotokoll Fall-Bibel, Runde 2: Protokoll 1 (Interaktion, Pausen), Protokoll 4 (Skalierung 6–20), Protokoll 5 (Vollständigkeit) und Regelprüfung

Stand 2026-11-01. Geprüft: `bibel/FALL-BIBEL.md` (Integration Runde 1, 6970 Zeilen) als Ganzes. Abgeglichen mit
`bibel/TESTPROTOKOLL.md`, `tests/P1+P4-runde1.md`, `tests/P5+Regeln-runde1.md` und den Runde-2-Protokollen
`tests/P2-runde2.md`, `tests/P3-runde2.md` (dort Gefundenes wird hier nicht wiederholt, nur verwiesen). Maßstab: `AUFTRAG.md`
(A:Zeile), `ENTSCHEIDUNGEN.md` (E1–E17), `verstehen/regeln.md` (REG §6, §9). Repo nur gelesen. An der Bibel nichts geändert.

Fundstellen: Kennung der Bibel (etwa „MECH 1.4“) und Zeilennummer in `FALL-BIBEL.md` („Z.“).
Schwere: **Blocker** = Spiel bricht, Lösung falsch oder Regelverstoß · **mittel** = spürbare Schwäche · **klein** = Feinschliff.
Haltung: gegnerisch.

Werkzeuge (alle unter `tests/werkzeug-p145r2/`, Aufruf mit `python3 -I`):
- `pruefe.py`: Tonregeln (Schlag-Verben, Gewalt, Alkohol, Rauch ohne Kamin, Fachwörter, Sperrliste, Anglizismen, Altnamen,
  Platzhalter, bloß „Schneider“, Raumwörter, Sätze über 25 Wörter) über alle „…“-Texte und Blockzitate. Ergebnis `roh.tsv`.
- `vorlesen.py`: Ziffern, Klammern und Abkürzungen in Vorlesetexten.
- `umfang.py`: Wortzahlen je Abschnitt (für Heft- und Seitenumfänge).
- `last.py`: Eingangslast der Nachbohr-Ziele und Fragen an die vier Verdächtigen je Personenzahl und Runde.

---

## 0. Ergebnis in Kürze

- **Kein Blocker.** Die Lösung bleibt in jeder Besetzung richtig. Jeder Meilenstein M1–M9 ist bei 6 bis 20 Personen
  erreichbar. Kein Nachbohr-Ziel läuft ins Leere. Das Abwesenheitsblatt funktioniert. Jede Solo-Fassung ist vollständig.
- Fast alle Runde-1-Befunde sind angekommen. Nur halb angekommen sind **P14-03** (Detektiv-Aufgaben in Runde 2 und 3 stehen
  noch als „Verhörstuhl: Frag alle“), **P14-04** (die Gegenüberstellung ist zu kurz) und **P14-09** (Tandem 2 kommt bei 15
  bis 18 Personen nicht in Gang).
- **10 mittlere Befunde.** Drei betreffen große Runden (R-02 gegen R-13, Gegenüberstellung, Detektiv-Aufgaben). Einer betrifft
  kleine und mittlere Runden (Bestätigungspflicht zwingt Emine zur Lüge oder zum Sperrbruch). Dazu: Tandem 2, Umfang der
  Zusatzhefte, Bonus-Ziele, die sich von selbst erfüllen, ein geschenkter Meilenstein (M4 über „Miete“), das Erzählerheft ohne
  „Was alle wissen“ und ein Rundenstart, der zwei Stufe-1-Lügen vorab entwertet.
- **21 kleine Befunde** (Wortlaute, Seitenlast, Abweichungsliste, Druckdetails).
- Tonregeln: Der Prüfer findet in gedruckten Texten keine Schlag-Verben, kein Blut, keinen Alkohol, keinen Rauch ohne Kamin,
  keine Altnamen, keine Platzhalter, keine Sätze über 25 Wörter. Einziger Regelfall: „Sorry, hat gedauert.“ in WELT 3.4 und RN7
  (Kanon-Zitat mit selbst erteilter Ausnahme, P145R2-K01).

---

## 1. Nachprüfung der Runde-1-Befunde (Protokolle 1, 4, 5)

| Befund R1 | Stand in der Bibel (Z.) | Urteil |
|---|---|---|
| P14-01 Hanas Serkan-Zeile | Platzhalter-Zeile Z. 5150, Generator-Satz Z. 5231 | behoben |
| P14-02 Streifenformat | MECH 5.2 Z. 1838–1843 | behoben; „neben ihrem Protokoll“ missverständlich (K04) |
| P14-03 Verhörstuhl stoppt alles | R-02 Z. 1255; RK 6.5 R1-Ziel 2 und R2-Ziel 1 über Impulse | teilweise: R2-Ziel 2 und beide R3-Ziele stehen noch als „Verhörstuhl: Frag alle“ (M03); ab 12 Personen Konflikt mit R-13 (M01) |
| P14-04 Stau bei 14–20 | Gegenüberstellung MECH 1.3 Z. 1240–1245, 9.9 Z. 2232 | teilweise: fünf Minuten reichen ab 14 Personen rechnerisch nicht (M02) |
| P14-05, P14-06 Etikett | MECH 5.3 Z. 1853–1857, 9.14 | behoben; Umschreibungen „ein Gast“ und „jemand“ in 9.14 mehrdeutig (K03) |
| P14-07 Bonus-Ziel der vier | RK 1.6 Z. 2543 | behoben; bei Olli ab 7 Personen kaum erreichbar, Regelsatz in MECH 7.3 stimmt dann nicht (K16) |
| P14-08 Impuls-Antworten der vier | RK 1.8 Z. 2563–2572 | behoben bis auf Can I-2.2 und I-3.1 ohne „Karte offen“ (bestätigt, siehe P3R2-02) |
| P14-09 Zusatzrollen ohne eingehende Ziele | ZR 2.8, 4.8, 6.8, 7.8 | teilweise: wirkt erst ab 18/19 Personen (M05); Damir, Wojtek, Tugba weiter nie Ziel (K20) |
| P14-10 Tims Satz von 20:15 | ZG 3.5 Z. 3839 | behoben |
| P14-11 Handzeichen | MECH 4.4 Z. 1789, G-12, ZG-16 | behoben |
| P14-12 Marker | MECH 10.2 Z. 6577–6588 | behoben; Lage der Felder für die Streifen fehlt (K05) |
| P14-13 Vermerke-Liste | MECH 2.6 Z. 1469 | behoben |
| P14-14 Ausweichziele | RK 2.9, 3.9, 5.9 | behoben |
| P14-15 „Karte!“ | R-03 Z. 1256 | behoben |
| P14-16 Teil 90 Namen | WELT 1.1, MECH 8.3, 8.4 | behoben |
| P14-17 Zeugenheft | ZG 0.6 | behoben; Zusatzhefte haben kein wörtliches „Wer du bist“ (K18) |
| P14-K01 bis P14-K17 | an den genannten Stellen | alle behoben |
| P5-B1 bis P5-B5 | MECH 2.1, 2.2, RK 2.7–5.7, ZG-Platzhalter, ZG 1.5 | behoben |
| P5-M1 bis P5-M5 | „Taschenkontrolle“, RK 2.12–5.12, MECH 9.12, ZG 0.6, MECH 4.4 | behoben |
| P5-M6 Erzähler beim Schneiden | 19.2 Nr. 1 | teilweise (bewusst); Durchscheinen nicht bedacht (K06) |
| P5-M7 Abweichungsliste | MECH 12a | vorhanden, aber unvollständig (P3R2-22 und K14) |
| P5-K1 bis P5-K15 | an den genannten Stellen | behoben |
| P5-K16 Tims Eis-Satz | ZG 3.4 Z. 3802 | nur in Tims Heft geändert; WELT 3.4 und RN7 sagen weiter „Sorry, hat gedauert.“ (K01) |

---

## Teil A – Protokoll 1: Interaktions- und Pausentest

### A.1 Methode

Für jede Rolle 1–18, den Detektiv und den Erzähler, Runde für Runde: (a) zwei aktive Ziele mit echter Frage, (b) klarer
Übergang Stufe 1 → Stufe 2, (c) sinnvolle Geheimniskarte, (d) nützliche Aktionskarte, (e) Leerlauf: Wird die Rolle
angebohrt, hat sie nach dem Umdrehen noch etwas zu tun, gibt es für jede wahrscheinliche Frage einen erlaubten Satz?
Neu in Runde 2: (f) jede Pflicht, etwas zu bestätigen (Zeitstempel, Beleg bitte!, I-1.1, Domino-Frage), gegen das Heft der
genannten Person gehalten; (g) jedes Bonus-Ziel daraufhin geprüft, ob es Verhalten treibt oder sich von selbst erfüllt.

### A.2 Je Rolle und Runde

„ein“ = eingehende Ziele bei 20 Personen R1/R2/R3 (aus `last.py`). Befund-Kürzel: M = mittel, K = klein, jeweils P145R2.

| Rolle | R1 | R2 | R3 | Stufe 1 → 2 | GK | AK | ein | Befund |
|---|---|---|---|---|---|---|---|---|
| 1 Ahmet | Fatma, Marek (A: Detektiv + Can) | Olli, Joanna (A: Detektiv + Fatma) | Can, Lejla (A: Detektiv + Olli) | klar, drei Fälle | sinnvoll | Einspruch | 4 / 9 / 2 | M08 (M4 über „Miete“ geschenkt); kein Satz für 23:51 (P2-21) |
| 2 Fatma | Can, Emine (A: Detektiv + Olli) | Ahmet, Zeynep (A: Can) | Olli, Marek (A: Detektiv + Can) | klar | sinnvoll | Gegenfrage | 4 / 5 / 1 | M04: Ihr Satz „[Emine] war bei mir“ zwingt Emine bei Zeitstempel und Beleg bitte! zur Lüge oder zum Sperrbruch |
| 3 Olli | Ahmet, Tim (A: Can) | Can, Marek (A: Ahmet) | Fatma, Lejla (A: Can) | klar; ab 7 Personen fast sicher in R1 b | sinnvoll | Themenwechsel | 7 / 5 / 12 | M02 (12 Fragen in R3); K16 (Bonus kaum erreichbar); K01 |
| 4 Can | Olli, Zeynep (A: Fatma) | Fatma, Joanna (A: Detektiv + Ahmet) | Ahmet, Tim (A: Olli) | klar | sinnvoll | Retourkutsche | 5 / 4 / 7 | I-2.2 und I-3.1 ohne „Karte offen“ (P3R2-02, bestätigt) |
| 5 Lejla | Olli, Can | Ahmet, Marek (A: Olli) | Olli, Tim (A: Can) | R2-Sperre | sinnvoll | Krankenbesuch | 2 / 0 / 3 | Kernsatz für Olli (b) „vor allen“ ab 12 Personen am Verhörstuhl ungehört (M01) |
| 6 Emine | Olli, Lejla | Fatma, Olli | Olli, Can | R2-Sperre | sinnvoll; Domino ohne neuen Inhalt | Kreuzverhör | 1 / 0 / 0 | M04 (Bestätigungspflicht), K15 (Domino) |
| 7 Tim | Fatma, Zeynep (A: Can) | Ahmet, Can | Olli, Marek (A: Lejla) | R3-Sperre | sinnvoll | Stirnlampe | 4 / 3 / 4 | M07 (Bonus erfüllt sich nach R1 von selbst); K01 |
| 8 Joanna | Olli, Fatma | Can, Ahmet | Olli, Zeynep (A: Tim) | R2-Sperre | sinnvoll | Zeitstempel | 1 / 4 / 0 | K04 (Notiz „daneben“) |
| 9 Marek | Ahmet, Tim | Ahmet, Olli | Olli, Can | R3-Sperre | sinnvoll | Taschenkontrolle | 2 / 4 / 4 | K09 (du-Form beim Vorlesen) |
| 10 Zeynep | Fatma, Olli | Tim, Joanna | Olli, Tim | R3-Sperre | sinnvoll | Gelbe Karte | 3 / 1 / 2 | – |
| 11 Sibel | Can, Zeynep | Fatma, Ahmet | Olli, Can | keine Sperre, klar | sinnvoll | Noch mal rückwärts | 0 / 1 / 0 | – |
| 12 Damir | Tim, Emine | Ahmet, Sibel (leise) | Marek, Can | klar | sinnvoll | Teepause | 0 / 0 / 0 | K20 (nie Ziel) |
| 13 Hana | Olli, Ahmet | Can, Tim | Olli, Tim | Auslöser 3 „zum zweiten Mal“ feuert praktisch nie | sinnvoll | Spurenlesen | 1 / 1 / 0 | M05 |
| 14 Serkan | Lejla, Marek | Hana (leise), Fatma | Lejla, Can | Auslöser 1 „zweimal“; zweite Frage nur ab 19 Personen | sinnvoll | Lagebesprechung | 1 / 0 / 0 | M05 |
| 15 Azra | Olli, Can | Ahmet, Fatma | Olli, Zeynep | klar | sinnvoll | Lupe | 0 / 0 / 1 | M07 (Bonus von selbst) |
| 16 Wojtek | Tim, Hana | Tim, Olli | Olli, Azra | R2-Sperre | sinnvoll | Maßband | 0 / 0 / 0 | M07, K20 |
| 17 Aylin | Ahmet, Serkan | Ahmet, Marek | Ahmet, Olli | R2-Sperre | sinnvoll | Beleg bitte! | 0 / 1 / 0 | M07; K11 (Wissen fehlt für R1-Ziel 2) |
| 18 Tugba | Can, Joanna | Olli, Aylin | Can, Marek | jederzeit | harmlos (E11) | Handzeichen | 0 / 0 / 0 | M07 (Bonus = XD3, kommt immer); K08 (Frage zu lang) |
| Detektiv | Verhörstuhl A1–A3 an die vier; Impuls „Wer war neben dir?“ | Impuls „Geld“; **Verhörstuhl: Frag alle** (Turmgang, Gesicht) | **Verhörstuhl: Frag alle** (Reihenfolge, Wege, Nach dem Licht) | – | keine | Karten fehlender Zeugen (6–11) | – | M03; M01; K07 („überführt“ doppeldeutig); K13 (Seite 2 überladen) |
| Erzähler | Start, Impulse, R-08, 9.14, Marker-Probe | dto., Herr Schneider | dto., Tipp-Runde, Anklage, Teil 90 | – | – | – | – | M09 (kein „Was alle wissen“), M10 (Rundenstart R1), K21 (Bonus-Zählung) |

Ergebnis Protokoll 1: **Keine Rolle ist ohne Auftrag.** Joanna, Tim, Marek und Lejla (A:128) haben in jeder Runde Arbeit und
einen tragenden Stein. Leerlauf entsteht an drei Stellen: (1) Zusatzrollen, die nie oder erst sehr spät angesprochen werden
(Damir, Wojtek, Tugba immer; Hana und Serkan bei 15 bis 18 Personen, M05, K20). (2) Die Gegenüberstellung schafft ihre
Fragen nicht (M02). (3) Der Detektiv soll in Runde 2 und 3 „alle“ am Verhörstuhl befragen (M03). Neu entdeckt: Bestätigungs-
pflichten ohne erlaubte Antwort (M04) und fünf Bonus-Ziele, die sich ohne Zutun erfüllen (M07).

### A.3 Bestätigungspflichten gegen die Hefte (neu)

| Wer muss bestätigen | Auslöser | Heft der Person | Ergebnis |
|---|---|---|---|
| Emine, wenn Fatma sie für 23:57 nennt | I-1.1, Zeitstempel, Beleg bitte! | I-1.1 hat eine ausweichende Antwort (ZG 0.4 Z. 3331); Zeitstempel und Beleg bitte! verlangen „ob das stimmt“; ihr Wissen dazu ist „nach dem Umdrehen“ (ZG 2.4 Z. 3620); G-01: Zeugen lügen nie | **Konflikt (M04)** |
| Lejla, wenn Ahmet sie für die Miete nennt | Beleg bitte! | Tarnsatz „Ahmet hat kassiert. Frag ihn, wofür.“; Verbot „Die Miete war echt.“ | Konflikt (M04) |
| Fatma, Olli bei Dominos | Domino-Frage | Freigabe „nach der Karte“ | Konflikt (P2-20, gleiche Lösung wie M04) |
| Detektiv, wenn Olli ihn nennt | I-1.1, Zeitstempel | „Was du selbst weißt“: 23:54 gesehen, ab 23:55 Augenbinde | kein Konflikt |
| Marek, Joanna, Damir | I-1.1, Zeitstempel | offenes Wissen | kein Konflikt |
| Tim, wenn Ahmet ihn nennt | I-1.1 | „Bestätigen kann ich da keinen“ gegen offenes Wissen | Konflikt (P3R2-05) |

### A.4 Bonus-Ziele: Treiben sie Verhalten? (neu)

| Rolle | Bedingung | erfüllt sich wann, ohne Zutun? | Urteil |
|---|---|---|---|
| Ahmet, Fatma, Can | freiwillig reinen Tisch vor eigenem Sobald-Fall | erreichbar am Ende von Runde 1 | treibt |
| Olli | dto. | ab 7 Personen fällt Lejlas oder Joannas Auslöser in Runde 1 b | fast unerreichbar (K16) |
| Lejla, Emine, Zeynep | Schutzperson ausgeschieden | braucht Alibi und Heimlichtuerei | treibt |
| Tim | Alibi-Zeile bei drei von vier | Ahmet, Fatma, Olli ✗ meist schon in Runde 1 | **von selbst (M07)** |
| Joanna | Ort-Zeile bei allen vier | Can braucht Cans oder Zeyneps Karte | treibt |
| Marek | Ahmets Heimlichtuerei ✓ | PM3 oder WM9 in Runde 2 | schwach, hinnehmbar |
| Sibel | Karte selbst vor FM9/YT4 | Ende Runde 1 | treibt |
| Damir | Name als Quelle bei Ahmets Alibi | muss es selbst sagen | treibt |
| Hana | Cans Alibi ✓ | Runde 3 | treibt |
| Serkan | PP9 offen | Runde 3 nach der Tipp-Runde | treibt (lenkt zum Eiskübel) |
| Azra | Fatmas Karte offen | FM9 oder NN3 fast immer | **von selbst (M07)** |
| Wojtek | Ollis Schramme ✓ | Ollis Karte ab Runde 1 | **von selbst (M07)** |
| Aylin | Ahmet sagt vor allen zu, Geld zurück | Ahmets Pflichtsatz „Ihr bekommt euer Geld zurück. Versprochen.“ (RK 2.7) | **von selbst (M07)** |
| Tugba | Indizkarte zeigt die Torte | XD3 wird in Runde 3 fast immer gezogen | **von selbst (M07)** |
| Erzähler | drei Viertel der Karten offen | treibt Moderation | treibt; Zählung unklar (K21) |

---

## Teil B – Protokoll 4: Skalierung 6 bis 20 Personen

### B.1 Je Personenzahl

Rollen nach E6 (Personen = Rollen + Detektiv + Erzähler). „Str“ = Zeugenstreifen, „GK“ = Geheimniskarte, „AK“ = Aktionskarte.

| P | Rollen | Zusatzblätter und Sonderregeln | AK beim Detektiv | Meilensteine (kritischer Weg) | Ziele und Ausweichziele | Befunde |
|---|---|---|---|---|---|---|
| 6 | 1–4 | Abwesenheitsblatt 6 Str + 6 GK; Erzählerheft S. 16 mit 9.14 (6 Zeilen); Teil 12 Hinweisseite; „Abschnitt b nach zwölf Minuten“ | alle 6 | M1 Str Marek (WJ9 oder Zeitstempel), M2 Str Emine (RH3), M3 GK Tim/Marek/Zeynep ab R3 (MR4, JT3, XD3, FK3), M4 PM3/WM9, M5 NN3, M6 JT3, M7 GK Olli (DM3, FX3 oder Ahmets Domino), M8 PP9, M9 XD3 + FN3. Budget: R1 3 (+ Zeitstempel), R2 3 + Stirnlampe + Taschenkontrolle + Krankenbesuch, R3 3 → 11 bis 13 Karten, 9 nötig. Geht auf | alle Ziel-2 als Ausweichziel; jede Bitte an den Detektiv mit zweiter Frage (P14-14) | K03, K05, K06 |
| 7 | +Lejla | 5 Str | 5 | Lejla trägt D2 in R1 | Lejla R2-2 → Olli, R3-2 → Can | – |
| 8 | +Emine | 4 Str | 4 | M2 über Emine | Emine ohne Ausweichziel nötig | M04 |
| 9 | +Tim | 3 Str | 3 | M3 über Tim (R3) | Tim R1-2 → Can, R3-2 → Lejla | – |
| 10 | +Joanna | 2 Str (Marek, Zeynep) | 2 | M1 WJ9 oder Joannas Zeitstempel | Joanna R3-2 → Tim | K03 |
| 11 | +Marek | 1 Str (Zeynep) | 1 | – | – | – |
| 12 | +Zeynep | keine Streifen; R-02 parallel, „Karte!“ | – | alle Quellen gespielt | keine Ausweichziele | M01 |
| 13 | +Sibel (solo) | Zusatzheft 1; Solo 1.12 | – | M5, M6 stützend | – | M06, K10 |
| 14 | +Damir | „Wechsel!“, Gegenüberstellung, Absätze selbst lesen | – | M1 zweite Quelle | – | **M02** (R2: 16 Fragen, 5:20 min), M03, K20 |
| 15 | +Hana (solo) | Solo 3.12 (P14-01 behoben) | – | M3 stützend (R3) | – | M02, **M05** (niemand fragt Hana) |
| 16 | +Serkan | Tandem 2 vollständig | – | M8 stützend | – | M02 (R2 6:00, R3 5:40), **M05** (Serkan nur über I-1.3) |
| 17 | +Azra (solo) | Solo 5.12; Tims Tarnsatz-Zeile ab hier | – | M4, M5 stützend | – | M02, M05 |
| 18 | +Wojtek | Tandem 3 vollständig | – | M7 stützend | – | M02 (R2 7:00), M05 (Hana einmal gefragt) |
| 19 | +Aylin (solo) | Solo 7.12; Dankeskarten-Zeile in „Was alle wissen“ | – | M4 Quelle | – | M07, K10 |
| 20 | +Tugba | alle acht Zusatzhefte | – | M9 stützend | – | M02 (R2 7:40, R3 7:20), M03, M07 |

### B.2 Meilensteine

MECH 6.3 hält. Für jede Personenzahl gibt es mindestens eine Quelle je Meilenstein; kein Weg hängt an einer Entweder-oder-
Wahl. Der Fall fällt bei keiner Besetzung formal vor Runde 3 (XD3, PP9, Cans Alibi). Inhaltlich vorher: FN3 in Runde 2
(P2-17). Lücke in der Wertung: M4 ist über das Stichwort „Miete“ ohne Aufdeckung zu haben (M08).

### B.3 Nachbohr-Ziele

Alle 108 Ziele (18 × 3 × 2) geprüft. Jedes Ziel, das einen höheren Platz nennt, hat ein Ausweichziel; Zusatzrollen nennen nur
kleinere Plätze (ZG-09). **Kein Ziel läuft ins Leere.** Doppelungen nur, wo gewollt (Can bei Sibel R1 und R3). Die
Eingangslast (`last.py`) zeigt: Olli R3 bei 12/16/20 Personen 7/9/12 Fragen, Ahmet R2 5/7/9. Nie Ziel bei 20 Personen über alle
Runden: Damir, Wojtek, Tugba (K20). Bei 15–18 Personen werden Hana und Serkan nur von ihrem Partner angesprochen (M05).

### B.4 Abwesenheitsblatt

- **Logik: funktioniert.** Streifen öffnen über den Ortstermin oder den Zeitstempel; die Karte darunter über die Codes in 9.14,
  mit derselben Rundensperre wie gespielt (M-17). Gespielte und fehlende Zeugen geben dieselben Kernsätze und Vermerke.
- **Format: geht auf.** 2 × 3 Streifen zu 100 × 95 mm auf A4 mit 5 mm Rand; Protokoll 65 mm, rund 16 Zeilen in 9 pt. Joannas
  Protokoll (rund 55 Wörter) und Vermerk (25) passen; die Notiz (13 Zeilen) passt nur **unter** dem Protokoll, nicht daneben
  (K04).
- **Erzählertabelle 9.14:** Die Umschreibungen „ein Gast“ (Tim) und „jemand“ (Zeynep) sind nicht eindeutig (K03).
- **Auslegen:** „neben das Markerfeld der Zone“ setzt voraus, dass die Felder 1, 2, 3, 4d und 6 am Rand von Blatt B liegen;
  das ist nicht festgelegt (K05). Durchscheinen bei einseitigem Druck (K06).

### B.5 Tandem ohne Partner

| P | allein | umgeschaltet | geprüft |
|---|---|---|---|
| 13 | Sibel | Auftritt, Tandem-Kasten, Wissen, Tarnsatz, Karte (Solo-Domino), Auslöser 2 entfällt; Marek und Ahmet „ein Gast mit der großen Teekanne“ | in Ordnung |
| 15 | Hana | Auftritt, Kasten, Wissen, Karte, Auslöser 2, „Nach Serkans Karte“ und Serkan-Tarnsatz entfallen | in Ordnung (P14-01 behoben); Mini-Intrige ohne Anstoß (M05) |
| 17 | Azra | Auftritt „jemand hat … geleuchtet“, Kasten, Wissen, Tarnsatz, Solo-Karte mit Tims Satz; Tims neue Tarnsatz-Zeile | in Ordnung |
| 19 | Aylin | Kasten „eine Dankeskarte“ | in Ordnung |

### B.6 Gegenüberstellung nachgerechnet (`last.py`)

Fragen an die vier je Runde, wenn jede Person alle Ziele stellt, die einer der vier sind; 20 Sekunden je Frage.

| Personen | Runde 2 | Runde 3 | Personen mit mindestens einem Ziel bei den vier (R2 / R3) |
|---|---|---|---|
| 14 | 16 Fragen, 5:20 | 15 Fragen, 5:00 | 11 / 12 |
| 16 | 18 Fragen, 6:00 | 17 Fragen, 5:40 | 13 / 14 |
| 18 | 21 Fragen, 7:00 | 19 Fragen, 6:20 | 15 / 16 |
| 20 | 23 Fragen, 7:40 | 22 Fragen, 7:20 | 17 / 18 |

Fünf Minuten reichen ab 14 Personen nicht, ohne dass Antworten mitgerechnet sind. Mit „genau eine Frage je Person“ und
sieben Minuten ab 18 Personen geht es auf (M02).

---

## Teil C – Protokoll 5: Vollständigkeit auf Spezifikationsebene

| Teil | Inhalt nach Auftrag (A:133–140) | Stand | Lücken |
|---|---|---|---|
| 00 Erzählerheft | Gamemaster ohne Lösung, Vorstellungsfragen, Impulse, Skalierung | 16 Seiten gegliedert (MECH 9.1); alle 19 Fragen wörtlich (RK/ZG/ZR x.3, RK 6.3); 4 Impulse je Runde; 9.13, 9.14 | **„Was alle wissen“ fehlt** (M09); Rundenstart R1 deutet (M10); veraltete Verweise „aus der Rollen-Phase“ (K17) |
| 01 Detektivbogen | Detektiv, Ermittlungsbogen | 6 Seiten (MECH 2.6), Texte RK 6 | Seite 2 trägt rund 800 Wörter (K13) |
| 02 Tisch | Lageplan, Marker, Tipp-Zettel, Abwesenheitsblatt | MECH 10.2, 7.1, 5 | Feldlage für Streifen (K05); „daneben“ (K04) |
| 10 Rollenhefte 1–10 | Auftritt, Gesprächsaufträge, 2 Stufen | RK 1.1/8.1/8.2 und ZG 0.6 vollständig | „Was du bei dir trägst“ in du-Form, wird aber vorgelesen (K09) |
| 11 Fassungen | WW4, JM3, RN7, YW4 | RK 7 vollständig, Längen in 10 % | K01 („Sorry“), K19 (Prüfsatz falsch) |
| 12 Zusatzhefte 11–18 | kompakte, vollwertige Hefte | ZR 0.7 und ZR 1–8 inhaltlich vollständig | **passt nicht auf zwei Seiten** (M06); „Wer du bist“ nicht wörtlich (K18); Markerzeile (P3R2-18) |
| 20 Karten | 18 Geheimnis-, 18 Aktions-, 19 Indizkarten | alle wörtlich | FK3 ohne „Kein Schlüsselbund“ (K02); Durchscheinen (K06) |
| 90 Auflösung | Meilensteine, 4 Enden, Rückblende, Punkte aller | MECH 8; Kernsätze, Enden aus Kanon mit zwei Anpassungen, 18 Absätze, Prüfbedingungen | Rückblende-Fließtext und gekürzte Zeitleiste folgen in der Text-Phase (zulässig, 19.2 Nr. 8); Seite 9 bei 20 Personen zu voll (K13); M4-Stichwort (M08) |

Platzhalter: Keine „TODO“, „…“, „usw.“ oder „etc.“ als Inhalt (`pruefe.py`). Offen gelassene Wortlaute sind ausdrücklich der
Text-Phase zugewiesen (Rückblende 400–500 Wörter, Teil-90-Zeitleiste).

---

## Teil D – Ton- und Inhaltsregeln (REG §6, §9)

| Regel | Ergebnis | Befund |
|---|---|---|
| Gewalt, Schlag-Verben, „Platzwunde“ | in gedruckten Texten keine; Treffer nur in Regeltexten und MECH 12a (Auftragszitat) | – |
| Herr Schneider überlebt, Beule | Tat-Moment, „Was alle wissen“, Enden | – |
| Getränke, „Bargeld“ | nur Tee, Kaffee, Saft, alkoholfreier Apfelpunsch; „in Bargeld“ | – |
| Rauch/Qualm nur mit Kamin | alle gedruckten Sätze mit „Kamin…“ | – |
| Anglizismen | „Cardigan“, „Fineliner“, „Party-Planerin“ sind Kanon (`figuren.json`); „Sorry, hat gedauert.“ in WELT 3.4 und RN7, Ausnahme nur in RK 0.3 erteilt, nicht in WELT 0.3 oder MECH 12a | K01 |
| Satzlänge, Mittelwert | kein Satz über 25 Wörter; Mittel: 9.2 8,5 · 9.3 11,2 · 9.5 8,8 · 9.8 6,8 · 9.9 9,1 · 9.12 10,1 · Auftritte 6,8 | – |
| Vorlesetexte ohne Ziffern, Klammern | erfüllt (`vorlesen.py`) | – |
| Namen (Lejla, Joanna, Marek usw.), keine Altnamen | erfüllt | – |
| Herkunft, Kopftuch | nur in ZR 13.2 („nie im Spiel“); Tugba unbelastet (E11) | – |
| Verwandtschaft nur als Tatsache | erfüllt (ZG 0.6 Schlusssatz) | – |
| Raumwörter | erfüllt | – |
| Anrede: Ich-Form, wenn die Rolle spricht | „Was du bei dir trägst“ wird vorgelesen, steht aber in du-Form | K09 |
| Vorstellungsfrage 1–2 Sätze (A:22) | 18 von 19 erfüllt; Tugba drei Sätze nach der Anrede | K08 |

---

## Teil E – Spoilerfreiheit

| Prüfpunkt | Ergebnis |
|---|---|
| Erzählerheft ohne Lösung (E10) | keine Stufe 2, keine Antworten, keine Code-Zuordnung. Aber: Rundenstart R1 sagt „Alle vier Verdächtigen haben gute Gründe, nahe der Theke gewesen zu sein.“ und entwertet damit vorab Ollis (Ost-Saal) und Cans (Turm-Toilette) Stufe 1 (M10) |
| Geheimniskarten-Vorderseiten neutral (E8) | erfüllt, auch für fehlende Zeugen |
| Kein Name als Urteil auf Karten | erfüllt; WE3 trägt aber das Etikett „Heimlichtuerei“ für eine Tatsache aus „Was alle wissen“ (M08) |
| XD3 | richtig: Fundtext, Vermerk ohne „Täter“, ab Runde 3, Teil 2 nicht vorab genannt |
| Fassungen außen gleich | erfüllt |
| Etiketten der Streifen | ohne Freigabe-Codes; 9.14 nur Codes |

## Teil F – Gleiche Gestalt der vier Verdächtigen (E9)

Hefte, Fassungen, Karten, Aktionskarten, Bonus-Ziele, Stufe 3 und Teil-90-Absätze gleich gebaut; Längen nach RK 7.7 innerhalb
zehn Prozent. Abweichungen: Cans Impuls-Zeilen I-2.2 und I-3.1 ohne „Karte offen“ (P3R2-02). Ollis Bonus-Ziel ist gleich
gebaut, aber in der Praxis fast unerreichbar (K16); das ist keine Ungleichheit der Gestalt.

## Teil G – Entscheidungen E1–E17

| E | Ergebnis |
|---|---|
| E1 | eingehalten (Repo nur gelesen) |
| E2 | eingehalten; Kanon-Abweichung „Sorry“/Rundenstart nicht in WELT 0.3 (K01, M10) |
| E3 | eingehalten |
| E4 | eingehalten bis auf „Sorry“ (K01) |
| E5 | eingehalten |
| E6 | eingehalten |
| E7 | eingehalten |
| E8 | eingehalten |
| E9 | eingehalten bis auf P3R2-02 |
| E10 | Inhalt eingehalten; Rundenstart R1 deutet (M10); Erzähler ohne gemeinsames Wissen für seinen Tipp (M09) |
| E11 | eingehalten |
| E12 | eingehalten |
| E13 | eingehalten; M4-Stichwort zu weich (M08) |
| E14 | eingehalten; fünf Ziele ohne Zutun erfüllt (M07) |
| E15 | eingehalten |
| E16 | eingehalten (Erzählerakte nicht in der Teileliste) |
| E17 | nicht Sache der Bibel |

## Teil H – Auftrag A:1–140 (Stand Runde 2)

Gegenüber Runde 1 (`P5+Regeln-runde1.md`, Teil F) geändert: A:18 ✓ (JT3-Vermerk ohne Schluss), A:25 ≈ (nur noch Schneiden,
19.2 Nr. 1), A:30 ≈ (in MECH 12a), A:31 ✓ (Erzähler-Bonus im Heft), A:76 ≈ (Titel gesetzt), A:102 ✓ (Taschenkontrolle),
A:107 ✓ (Teil 01 und FN3 lecken nicht mehr). Neu unvollständig oder abweichend ohne Eintrag in MECH 12a: A:44 (Belegungsblatt
statt Quittungszettel), A:52 (Betrag pro Gast), A:87 (Ollis Marker bleibt bis zur Anklage auf dem Eiskübel), A:92 (Emines
Domino ohne Druck) → K14, K15; A:52 und A:54 (Orte) → P3R2-22. A:121 („fiebert … bis zur letzten Sekunde“) leidet unter M07.
A:128 (kein Leerlauf) erfüllt für Joanna, Tim, Marek, Lejla; bei Zusatzrollen siehe M05, K20. A:131 (Skalierung) erfüllt mit
M02. Kein Wunsch ist stillschweigend weggefallen.

---

## Teil I – Befunde

### Blocker

Keiner.

### Mittel

**P145R2-M01 · mittel · R-02 gegen R-13 ab 12 Personen: „vor allen“ am Verhörstuhl, aber niemand hört zu**
- Fundstellen: MECH 1.4 R-02 (Z. 1255), R-13 (Z. 1266); MECH 0.2 „Vor allen“ (Z. 1159); Kurzform „So spielt ihr“ (Z. 1271–1272);
  RK 6.6 „Gut zu wissen“ (Z. 6222–6223). Betroffen: RK 4.7 (b), (c) (Z. 3034–3035), RK 5.7 (c) (Z. 3208), ZG 3.6, 5.6, 6.6
  Nr. 2–4, ZR 1.7, 2.7 Nr. 3.
- Problem: Ab 12 Personen laufen beim Verhörstuhl die anderen Gespräche leise weiter (R-02). R-13 zählt den Verhörstuhl
  trotzdem als „vor allen“. Sagt Lejla am Verhörstuhl, Olli sei erst nach dem Scheppern gekommen, ist Ollis Auslöser (b)
  erfüllt, während Olli im Grüppchen nebenan redet. R-03 verlangt „sofort“; der Erzähler kennt die Auslöser nicht und kann
  nicht eingreifen. Die Kette stockt genau in den großen Runden. P2-16 schlägt „Der ganze Tisch hört zu“ vor; am Verhörstuhl ab
  12 Personen stimmt auch das nicht.
- Vorschlag (wörtlich, mit P2-16 abstimmen):
  - R-02: „R-02 Verhörstuhl: Der Detektiv darf jederzeit eine Person auf den Verhörstuhl bitten, höchstens zwei Minuten. Bis 11 Personen ruhen dabei die anderen Gespräche. Ab 12 Personen laufen sie leise weiter. Soll eine Antwort dort vor allen gelten, bittet der Detektiv vorher den Erzähler um ‚Alle mal herhören!‘. Keine Höchstzahl je Runde.“
  - R-13: „‚Vor allen‘ heißt: Der ganze Tisch hört zu. So ist es am Verhörstuhl, solange die anderen Gespräche ruhen, bei der Gegenüberstellung und nach dem Ruf ‚Alle mal herhören!‘. Wer im Grüppchen einen solchen Satz sagen will, ruft den Erzähler und sagt ihn dann vor allen.“
  - RK 6.6, dritter Punkt unter „Gut zu wissen“: „Auf dem Verhörstuhl sitzt jemand höchstens zwei Minuten. Bis 11 Personen hören die anderen zu. Ab 12 Personen reden sie leise weiter. Soll eine Antwort für alle zählen, bitte vorher den Erzähler um ‚Alle mal herhören!‘.“

**P145R2-M02 · mittel · Gegenüberstellung: fünf Minuten reichen ab 14 Personen nicht (Rest von P14-04)**
- Fundstellen: MECH 1.3 (Z. 1240–1245), MECH 9.9 (Z. 2232–2235), MECH 0.2 (Z. 1157), MECH 9.13 Zeile 14 (Z. 2357), 19.2 Nr. 3
  (Z. 6668–6669).
- Problem: „Reihum stellt jede Person, deren Ziel in dieser Runde einer der vier ist, ihre Frage dort, höchstens zwanzig
  Sekunden je Frage.“ Nachgerechnet (B.6): Runde 2 hat bei 14 Personen 16 Fragen an die vier (5:20 min), bei 20 Personen 23
  (7:40 min); Runde 3 bei 16 Personen 17 (5:40), bei 20 Personen 22 (7:20). Antworten sind dabei nicht mitgerechnet. Wer in fünf
  Minuten nicht drankommt, verliert sein Ziel; danach ruft der Erzähler „Wechsel!“. 19.2 Nr. 3 wartet auf einen Probelauf, die
  Rechnung entscheidet die Frage schon.
- Vorschlag (wörtlich):
  - MECH 1.3, Gegenüberstellung: „Ab 14 Personen ruft der Erzähler in Runde 2 und 3 nach der Hälfte von Abschnitt b die Gegenüberstellung aus. Ahmet, Fatma, Olli und Can setzen sich nebeneinander an den Kopf des Tisches. Reihum stellt dort jede Person, deren Ziel in dieser Runde einer der vier ist, genau eine Frage. Frage und Antwort dauern zusammen höchstens zwanzig Sekunden. Die Gegenüberstellung dauert fünf Minuten, ab 18 Personen sieben. Danach ruft der Erzähler ‚Wechsel!‘.“
  - MECH 9.9: „Gegenüberstellung! Ahmet, Fatma, Olli und Can, setzt euch nebeneinander an den Kopf des Tisches. Wer in dieser Runde eine Frage an einen der vier hat, stellt hier genau eine. Reihum, Frage und Antwort zusammen höchstens zwanzig Sekunden. In fünf Minuten rufe ich: Wechsel!“ Ab 18 Personen druckt der Generator „In sieben Minuten“.
  - Kontrolle mit „genau einer Frage“: Runde 2 bei 14/16/18/20 Personen 11/13/15/17 Fragen (3:40/4:20/5:00/5:40), Runde 3
    12/14/16/18 (4:00/4:40/5:20/6:00). Abschnitt b (17 Minuten) fasst halbe Zeit plus sieben Minuten.

**P145R2-M03 · mittel · Detektiv-Aufgaben in Runde 2 und 3: „Verhörstuhl: Frag alle“ ist ab 14 Personen nicht machbar (Rest von P14-03)**
- Fundstelle: RK 6.5, Runde 2 zweites Ziel (Z. 6184), Runde 3 erstes und zweites Ziel (Z. 6189–6190).
- Problem: Der Verhörstuhl ist ein Stuhl für eine Person, höchstens zwei Minuten (R-02). „Frag alle“ heißt bei 20 Personen 18
  Befragungen; schon bei 30 Sekunden je Person sind das neun Minuten, dazu die Gegenüberstellung. P14-03 hat nur Runde 1
  Ziel 2 und Runde 2 Ziel 1 auf Impulse umgestellt. Der Prüfsatz unter RK 6.5 („Runde-2-Ziele entsprechen den Impulsen I-2.1 bis
  I-2.3, Runde-3-Ziele I-3.1 bis I-3.3“) passt ohnehin zu Impulsen.
- Vorschlag (wörtlich, RK 6.5):
  - Runde 2: „Zweites Ziel, ganzer Tisch: Bitte den Erzähler um den Impuls ‚Turmgang und Bogentür‘, später um ‚Das Gesicht‘. Alle antworten reihum mit einem Satz.“
  - Runde 3: „Erstes Ziel, ganzer Tisch: Reihenfolge. Bitte den Erzähler um den Impuls ‚Was kam zuerst?‘. Wer im Dunkeln etwas gesehen oder gehört hat, antwortet der Reihe nach.“ und „Zweites Ziel, ganzer Tisch: Wege. Bitte den Erzähler um den Impuls ‚Der Weg zur Vorratsraumtür‘, danach um ‚Nach dem Licht‘.“
  - Wirkung: I-3.1 zählt für die Runde-3-Auslöser von Tim, Marek und Zeynep schon heute („Auch ein Impuls des Erzählers … zählt“).

**P145R2-M04 · mittel · Bestätigungspflicht ohne erlaubte Antwort: Emine muss lügen oder ihre Sperre brechen**
- Fundstellen: MECH 4.4 Zeitstempel (Z. 1779) und Beleg bitte! (Z. 1788): „Die genannte Person sagt sofort, ob das stimmt.“;
  MECH 9.9 I-1.1 (Z. 2240); RK 1.8 Fatma I-1.1 (Z. 2565) und RK 3.6 (Z. 2849): „Am linken Buffet. [Emine] war bei mir.“ (gelogen);
  ZG 2.4 (Z. 3620): „23:57 | Fatma geht … zur Theken-Klappe | nach dem Umdrehen“; ZG 0.1 G-01 (Z. 3285): „Zeugen lügen nie.“
- Problem: Spielt Joanna (oder bei 6–9 Personen der Detektiv) den Zeitstempel auf Fatma um 23:57, nennt Fatma nach ihrem Heft
  Emine. Emine muss „sofort sagen, ob das stimmt“. Sie darf nicht lügen und darf vor Runde 2 nicht sagen, dass Fatma zur Klappe
  ging. Ihr Heft hat nur für den Impuls I-1.1 eine ausweichende Antwort. Gleiches bei Beleg bitte! (Fatmas „nur Bücher“ mit
  Emine als Beleg; Ahmets „Miete“ mit Lejla als Beleg). P2-20 löst denselben Fall nur für die Domino-Frage.
- Vorschlag (wörtlich):
  - MECH 1.4, neue Regel: „R-14 Bestätigen: Sollst du sagen, ob etwas stimmt, und dein Heft hält es noch zurück, sagst du: ‚Dazu sag ich jetzt nichts.‘ Das gilt als Antwort. Lügen darfst du nur, wo dein Heft es erlaubt.“ Dieselbe Regel deckt P2-20.
  - Kurzform „So spielt ihr“, neuer Satz: „Darfst du etwas noch nicht bestätigen, sagst du: ‚Dazu sag ich jetzt nichts.‘“
  - MECH 4.4, Beleg bitte!, Grenzen (17 Wörter): „Die genannte Person sagt sofort, ob das stimmt. Hält ihr Heft es noch zurück, sagt sie: ‚Dazu sag ich jetzt nichts.‘“
  - ZG 2.5, neue Tarnsatz-Zeile: „wenn du bestätigen sollst, dass Fatma um drei vor zwölf bei dir war | ‚Dazu sag ich jetzt nichts. Beim Scheppern war sie neben mir.‘“
  - ZG G-11 und ZR ZG-13, Zusatz: „Bis zum Umdrehen gilt R-14.“

**P145R2-M05 · mittel · Tandem 2 kommt bei 15 bis 18 Personen nicht in Gang (Rest von P14-09)**
- Fundstellen: ZR 3.7 Nr. 3 (Z. 5162): „Sobald dich jemand zum zweiten Mal fragt, was du in den Kamin gesteckt hast.“; ZR 4.7
  Nr. 1 (Z. 5333): „… zum zweiten Mal fragt, warum du … zum Außentor gegangen bist“; Wojtek R1-2 → Hana (Z. 5693, ab 18
  Personen); Aylin R1-2 → Serkan (Z. 5853, ab 19 Personen); ZR 0.4 (Z. 4617–4619); ZR 9.2 (Z. 6088–6090); 19.2 Nr. 2 (Z. 6665).
- Problem: Nach dem Paper-Satz fragt Hana nur Wojtek, einmal, und nur ab 18 Personen. Hanas Auslöser 3 braucht zwei Fragen und
  feuert daher praktisch nie. Serkan wird nach dem Warum nur von Aylin (ab 19) und vom Impuls I-1.3 gefragt; Impulse liest der
  Erzähler ab 14 Personen kaum („bei Flaute“). Bei 15–18 Personen öffnet Tandem 2 deshalb nur über VP7 (Runde 3, nach der
  Tipp-Runde) oder freiwillig. Die Mini-Intrige wird nicht „ausgespielt“ (A:60); Hana und Serkan werden außer vom Partner nie
  angesprochen. 19.2 Nr. 2 („Sibel, Hana und Serkan werden jetzt angesprochen“) stimmt nur ab 18/19 Personen.
- Vorschlag (wörtlich):
  - ZR 3.7, Auslöser 3: „Sobald dich jemand vor allen fragt, was du in den Kamin gesteckt hast.“
  - RK 6.12, neue Zeile „15–20“: „Hol in Runde 1 oder 2 die Gäste mit Marker im Windfang oder im Kaminsaal kurz auf den Verhörstuhl. Frag sie: ‚Was wolltest du kurz vor zwölf dort, und warum?‘“ (zweite Frage für Serkan; spoilerfrei, weil sie nur Zusatzrollen in zwei Zonen trifft).
  - ZR 5.8, Azra Runde 1 Ziel 2 statt Can (Can hat dort bei 17–20 Personen schon vier bis fünf Fragen): „Serkan, dein Marker steht im Windfang. Um fünf vor zwölf sollten alle in den Ost-Saal. Was wolltest du da draußen?“
  - 19.2 Nr. 2: „Sibel wird ab 14 Personen angesprochen, Hana ab 16 (Serkan) und vor allen ab 18 (Wojtek), Serkan über den Detektiv ab 16 und über Azra ab 17. Damir, Wojtek und Tugba bleiben ohne eingehende Ziele (P145R2-K20).“

**P145R2-M06 · mittel · Zusatzheft passt nicht auf zwei Seiten**
- Fundstellen: ZR 0.7 (Z. 4702–4707); MECH 10.1 Teil 12 (Z. 6557); MECH 10.3 (Z. 6595); 19.2 Nr. 4 (Z. 6670–6671).
- Problem: Gezählt mit `umfang.py` am Beispiel Hana (gedruckter Text): Auftritt 81, „Wer du bist“ rund 70, Tandem-Kasten 84,
  Marker 20, „Was alle wissen“ 336, „Was du weißt“ ohne Quellen-Spalte 268, Stufe 1 rund 240, Stufe 2 mit Karteninhalt und
  „Nach dem Umdrehen“ rund 240, Gesprächsaufträge 229, „Wenn der Erzähler fragt“ 129, Aktionskarte 66, Was du bei dir trägst 21,
  Bonus 30, Solo 46, „So spielt ihr“ 77, Kopf und Fuß rund 25: **rund 1.950 Wörter**, dazu drei Tabellen. Zwei A4-Seiten fassen in
  9 pt mit Tabellen etwa 1.500. Die Zeugenhefte haben für ähnlich viel Text vier Seiten (ZG 0.6). Bleibt es bei zwei Seiten,
  schneidet der Generator ab oder setzt kleiner als 9 pt (REG §6.10 „gut lesbar, nichts abgeschnitten“).
- Vorschlag (wörtlich):
  - ZR 0.7: „Aufbau des Zusatzhefts (Teil 12, A4 hoch, drei Seiten): Seite 1 Kopf, ‚Dein Auftritt bei der Vorstellung‘, ‚Wer du bist‘, ‚Dein Tandem‘, ‚Deine Marker‘, ‚Was alle wissen‘. Seite 2 ‚Was du weißt‘, ‚Stufe 1‘, ‚Wenn der Erzähler fragt‘. Seite 3 ‚Stufe 2: Wann du umdrehst‘, ‚Nach dem Umdrehen‘, ‚Gesprächsaufträge Runde 1–3‘, ‚Deine Aktionskarte‘, ‚Was du bei dir trägst‘, ‚Dein Bonus-Ziel‘, ‚Wenn du angeklagt wirst‘, Solo-Abschnitt, ‚So spielt ihr‘, Besetzungshinweis.“
  - MECH 10.1, Teil 12: „A4 hoch, je Rolle 3 Seiten“; Spalte Seiten: „1 (Hinweisseite) / 1 / 24“. MECH 10.3: „ihr Zusatzheft (Teil 12, 3 Seiten)“.
  - 19.2 Nr. 4, letzter Satz: „Das Zusatzheft hat drei Seiten (P145R2-M06).“

**P145R2-M07 · mittel · Fünf Bonus-Ziele erfüllen sich ohne eigenes Zutun**
- Fundstellen: ZG 3.10 Tim (Z. 3909–3911), ZR 5.11 Azra (Z. 5548–5550), ZR 6.11 Wojtek (Z. 5717–5719), ZR 7.11 Aylin
  (Z. 5877–5878), ZR 8.11 Tugba (Z. 6030–6031); MECH 7.3 (Z. 2013).
- Problem: Tims Ziel (Alibi-Zeile bei drei von vier) steht meist nach Runde 1 (Ahmet, Fatma, Olli ✗). Azras Ziel (Fatmas Karte
  offen) kommt mit FM9 oder NN3 fast immer. Wojteks Ziel (Ollis Schramme ✓) kommt mit Ollis Karte in Runde 1. Aylins Ziel
  (Ahmets Zusage) spricht Ahmet beim Umdrehen als Pflichtsatz (RK 2.7 „Ihr bekommt euer Geld zurück. Versprochen.“). Tugbas Ziel
  (Indizkarte zeigt die Torte) ist XD3, die der Detektiv in Runde 3 fast immer zieht. Dieselbe Schwäche wurde bei den
  Verdächtigen als P14-07 behoben. A:121 („fiebert … bis zur letzten Sekunde“) leidet; zwei der fünf Tipp-Punkte sind geschenkt.
- Vorschlag (wörtlich):
  - Tim: „**Dein Bonus-Ziel:** Du hast das Licht wieder angemacht, jetzt soll auch klar werden, wer beim Scheppern wo war. **Erfüllt, wenn** bei der Anklage im Ermittlungsbogen in der Zeile ‚Alibi beim Scheppern‘ bei allen vier Verdächtigen ein Zeichen steht, ✓ oder ✗.“ (Cans Zeichen kommt erst in Runde 3, auch über Tims eigene Karte.)
  - Azra: „**Dein Bonus-Ziel:** Die Münzschatulle soll heil zurück, und niemand soll denken, du hättest Fatma angestiftet. **Erfüllt, wenn** Fatmas Geheimniskarte offen lag, bevor die Indizkarte ‚Fatma: Taschen und Kleidung‘ offen lag.“
  - Wojtek: „**Dein Bonus-Ziel:** Für die Schramme soll nicht dein Werkzeugkasten geradestehen, sondern wer sie gemacht hat. **Erfüllt, wenn** du deine Geheimniskarte am Ende einer Runde freiwillig umgedreht hast, bevor die Indizkarte ‚Hinter der Theke: Kaffeemaschine und Werkzeugkasten‘ offen lag.“
  - Aylin: „**Dein Bonus-Ziel:** Du willst dein Geld zurück, ohne Ahmet vorzuführen. **Erfüllt, wenn** Ahmets Geheimniskarte offen lag, bevor ‚Herrn Schneiders Klemmbrett‘ oder der ‚Ascheneimer am Kamin‘ offen lag.“
  - Tugba: „**Dein Bonus-Ziel:** Torte um halb eins, egal was passiert. Dafür muss feststehen, dass die Torte heil ist. **Erfüllt, wenn** bis zur Anklage jemand vor allen gesagt hat, dass die Mitternachtstorte heil im Regal steht.“ (Marek hat den Satz offen, ZG 5.5; Tugbas Runde-3-Ziel fragt ihn.)
  - MECH 7.3, Regeln, neuer Satz: „Kein Bonus-Ziel erfüllt sich ohne Zutun der Rolle schon in Runde 1 oder 2.“

**P145R2-M08 · mittel · M4 ist über das Stichwort „Miete“ geschenkt; WE3 nennt eine öffentliche Tatsache „Heimlichtuerei“**
- Fundstellen: MECH 6.1 M4 (Z. 1909): Stichwort „‚Miete‘, ‚Mietgeld‘ oder ‚Umschlag‘“; MECH 1.5 (Z. 1285): „sammelt Ahmet von
  allen … 150 € ‚Miete‘ in Bargeld ein“; WE3-Vermerk (Z. 1604): „Hinweis · Heimlichtuerei: Ahmet hat heute von allen anderen aus
  der Clique 150 € eingesammelt.“; MECH 3.2 (Z. 1511); A:110 („aufgedeckte Heimlichtuereien … Ahmets 150-€-Mietschwindel“).
- Problem: Dass Ahmet „Miete“ eingesammelt hat, steht in „Was alle wissen“. Schreibt der Detektiv in Runde 1 „Miete
  eingesammelt (WE3)“ in Ahmets Zelle, gibt Teil 90 den Punkt, ohne dass der Schwindel aufgedeckt ist. Mit Marek (M1) steht Ahmet
  dann schon in Runde 1 als „ausgeschieden“ auf dem Bogen. Das widerspricht A:110 und der Entlastungsregel 2.3.
- Vorschlag (wörtlich):
  - MECH 6.1, Zeile M4, Spalte „Stichwort, das genügt“: „‚Keller umsonst‘, ‚0 Euro‘, ‚Miete erfunden‘ oder ‚Umschlag im Ascheneimer‘“.
  - WE3, Vermerk: „Hinweis: Ahmet hat heute von allen anderen aus der Clique 150 € eingesammelt.“ MECH 3.2, Zeile WE3, Spalte „füllt im Bogen“: „Hinweis“.

**P145R2-M09 · mittel · Das Erzählerheft enthält „Was alle wissen“ nicht**
- Fundstellen: MECH 9.1 (Z. 2105–2120); MECH 1.5 (Z. 1277): „steht gleich lautend in jedem Rollenheft …, jedem Zusatzheft … und in
  Teil 01“; MECH 9.6 (Z. 2187); MECH 10.3 (Z. 6597: Erzähler bekommt nur Teil 00).
- Problem: Der Erzähler gibt einen Tipp ab wie alle (A:31, E10) und moderiert Impulse zu Geld, Turmgang und Gesicht. Das
  gemeinsame Wissen (18:00 Miete, 20:15, 21:00, 22:00 Kerzen, 23:00 Handys und Streit, 23:30, 23:55) hat er nicht. Der Tat-Moment
  (9.5) deckt nur Teile ab. Während die vier ihre Fassung lesen, lesen „alle anderen“ ihr „Was alle wissen“ – der Erzähler nicht.
- Vorschlag (wörtlich):
  - MECH 9.1, Seite 7: „Tat-Moment und Auftrag (9.5), Fassungen öffnen (9.6), ‚Was alle wissen‘ (1.5)“.
  - MECH 1.5, erster Satz: „Dieser Block steht gleich lautend in jedem Rollenheft (Teil 10), jedem Zusatzheft (Teil 12), in Teil 01 und im Erzählerheft (Teil 00, Seite 7).“
  - MECH 9.6, letzter Satz: „Gib ihnen drei Minuten. Alle anderen lesen in der Zeit ‚Was alle wissen‘ in ihrem Heft. Du liest es auf Seite 7.“

**P145R2-M10 · mittel · Rundenstart Runde 1 entwertet vorab die Stufe 1 von Olli und Can**
- Fundstelle: MECH 9.8, Runde 1, Start (Z. 2205): „Alle vier Verdächtigen haben gute Gründe, nahe der Theke gewesen zu sein.“
  (Kanon `runde.1.start`).
- Problem: Im Kammerspiel behaupten Olli (Ost-Saal) und Can (Turm-Toilette) in Stufe 1, nicht an der Theke gewesen zu sein
  (A:86, WELT 4.2). Der Erzähler sagt in Minute eins von Runde 1 als Tatsache, alle vier seien nahe der Theke gewesen. Das Spiel
  „deutet“ mit eigener Stimme (REG §6.10) und nimmt dem „Alibi-Geflecht“ die Entdeckung. Im App-Spiel passt der Satz; hier
  nicht. Die Bibel ändert den Rundenstart ohnehin schon (Kartenfreigabe).
- Vorschlag (wörtlich): „Es ist halb eins. Im Keller wird es still, und das Licht flackert. Die erste Runde heißt: Das Alibi-Geflecht. Wer war wo, als es knallte, und wo, als es schepperte? Ab jetzt sind die Karten der ersten Runde frei. Hört jetzt genau zu.“ Dazu in WELT 0.3 eine Zeile: „Rundenstart Runde 1 ohne den Kanon-Satz über die Theke, weil Olli und Can in Stufe 1 andere Orte nennen (P145R2-M10).“

### Klein

**P145R2-K01 · klein · „Sorry, hat gedauert.“ – Anglizismus und zwei Fassungen desselben Satzes**
- Fundstellen: WELT 3.4 (Z. 599) und RK 7.5 RN7 (Z. 6439): „Hier, dein Eis. Sorry, hat gedauert.“; ZG 3.4 Tim (Z. 3802): „Hier,
  dein Eis. Hat gedauert.“; RK 0.3 (Z. 2418, Ausnahme).
- Problem: REG §6.4 erlaubt nur Handy, Box, Design, Catering, Hobby, Dips. Die Ausnahme steht nur in RK 0.3, nicht in WELT 0.3
  oder MECH 12a. P5-K16 hat nur Tims Heft geändert; am Tisch zitieren Olli und Tim denselben Satz verschieden.
- Vorschlag: WELT 3.4 und RN7 wörtlich „Hier, dein Eis. Hat gedauert.“; RK 0.3 letzter Punkt: „Keine Anglizismen außer Handy, Box, Design, Catering, Hobby, Dips.“

**P145R2-K02 · klein · FK3 sagt nicht, ob dort der Schlüsselbund liegt**
- Fundstelle: MECH 3.3 FK3 (Z. 1552) gegen MECH 3.1 Nr. 5 (Z. 1488) „Jede Ortskarte sagt, ob dort der Schlüsselbund liegt“.
- Vorschlag: FK3, „Was du findest“, neuer letzter Satz (Form wie P2-18): „Im Steinbogen liegt kein Schlüsselbund.“

**P145R2-K03 · klein · Erzählertabelle 9.14: „ein Gast“ und „jemand“ sind keine eindeutigen Umschreibungen**
- Fundstelle: MECH 9.14, Zeilen Tim (Z. 2383) und Zeynep (Z. 2386).
- Problem: „Ein Gast“ steht auch für jede fehlende Zusatzrolle (etwa „ein Gast mit einer großen Teekanne“ = Damir in Ahmets
  Fassung 23:57). „Jemand“ sagt jeder. Nennt eine Person beim Zeitstempel „ein Gast“, dreht der Erzähler nach der Tabelle Tims
  Streifen um, obwohl Damir gemeint ist.
- Vorschlag: Spalte für Tim „der Hobby-Elektriker“, „dein Kumpel aus der Berufsschule“, „mein Kumpel“; für Zeynep „die Fußballtrainerin“, „deine Schwester“, „meine Schwester“. Neuer Satz unter der Tabelle: „‚Ein Gast‘ und ‚jemand‘ öffnen keinen Streifen.“

**P145R2-K04 · klein · Joannas Notiz „neben“ dem Protokoll passt nicht**
- Fundstellen: MECH 5.2 (Z. 1842) „neben ihrem Protokoll“; ZG 4.12 (Z. 4129) „daneben“; Z-11 (Z. 6936) „neben das Protokoll“.
- Problem: Das Protokollfeld ist 100 × 65 mm. Zweispaltige Notiz neben einem 80-Wörter-Protokoll ergibt drei Spalten von rund
  30 mm; Zeilen wie „Olli: am Eiskübel, redet mit Herrn Schneider“ brechen mehrfach um. Unter dem Protokoll passt es (B.4).
- Vorschlag: MECH 5.2: „Joannas Notiz steht zweispaltig in 8 pt unter ihrem Protokoll (Ausnahme nur für die Notiz).“ ZG 4.12: „(wörtlich; die Notiz zweispaltig in 8 pt darunter, Wortlaut 4.5; P14-02)“. Z-11: „… setzt sie zweispaltig unter das Protokoll“.

**P145R2-K05 · klein · Wo auf Blatt B die Felder mit Streifen liegen, ist offen**
- Fundstellen: MECH 5.2 (Z. 1845) „neben das Markerfeld der Zone“; MECH 9.7 Schritt 6 (Z. 2197); MECH 10.2 Blatt B
  (Z. 6577–6583).
- Problem: Blatt B ist ein Raster 5 × 3. Liegt ein Feld mit möglichem Streifen (2, 3, 4d, 6) in der Mitte, hat ein Streifen
  (100 × 65 mm gefaltet) daneben keinen Platz.
- Vorschlag: MECH 10.2, Blatt B, neuer Satz: „Die Felder 2, 3, 4d und 6 liegen am Rand von Blatt B, Feld 1 oben. In die drei inneren Zellen der mittleren Reihe kommen 4a, 4b und 4c.“

**P145R2-K06 · klein · Durchscheinen bei einseitigem Druck**
- Fundstellen: MECH 3.1 Nr. 9 (Z. 1496–1498), MECH 4.1 (Z. 1673–1676), MECH 5.2 (Z. 1838–1841), MECH 10.5 (Z. 6620).
- Problem: Im Z-Falz liegt über dem Text von Feld 2 nur das unbedruckte Papier von Feld 3; beim Streifen liegt das Protokoll mit
  der Schrift nach unten, darüber nur die Rückseite. Auf 80-g-Papier unter Lampenlicht ist 9-pt-Schrift durchs Papier zu ahnen.
- Vorschlag: MECH 3.1 Nr. 9 und 4.1, Zusatz: „Feld 3 trägt auf der Druckseite ein dichtes graues Raster als Sichtschutz.“ MECH 10.5, Zeile „alle“: „einseitig drucken, nichts lesen; Teile 02 und 20 auf festeres Papier (ab 120 g), damit nichts durchscheint“.

**P145R2-K07 · klein · „überführt“ in zwei Bedeutungen**
- Fundstellen: RK 6.6 (Z. 6221) „Wer überführt wird, muss seinen Marker vor allen umstellen.“; MECH 9.7 Schritt 5 (Z. 2196)
  „Wer später überführt wird, gelogen zu haben …“; dagegen MECH 2.4 „Überführt“ = Schlüsselbeweis und Fundort.
- Vorschlag: RK 6.6: „– Wer bei einer Lüge über seinen Ort ertappt wird, stellt seinen Marker vor allen um.“ MECH 9.7: „Wer später bei einer Lüge über seinen Ort ertappt wird, stellt seinen Marker vor allen um.“

**P145R2-K08 · klein · Tugbas Vorstellungsfrage hat drei Sätze**
- Fundstelle: ZR 8.3 (Z. 5923–5924); A:22 und MECH 9.4 (Z. 2147): Frage 1–2 Sätze.
- Vorschlag: „Tugba, die Party-Planerin. Laut deinem Ablaufplan ist jetzt jemand dran: Wer wohl, und was steht für Mitternacht auf dem Plan?“

**P145R2-K09 · klein · „Was du bei dir trägst“ wird vorgelesen, steht aber in du-Form**
- Fundstellen: MECH 4.4 Taschenkontrolle (Z. 1780) „liest die Person ‚Was du bei dir trägst‘ … vor“; alle Hefte, etwa RK 2.10
  (Z. 2755) „In deiner Hosentasche steckt …“; REG §6.6 (Ich-Form, wenn die Rolle spricht).
- Vorschlag: RK 1.1, ZG 0.6 und ZR 0.7, Regel: „‚Was du bei dir trägst‘ steht in der Ich-Form, weil die Person es vorliest.“ Beispiel RK 2.10: „In meiner Hosentasche steckt ein dickes Bündel Scheine. Sonst trag ich nur mein Handy. Meine schwarze Jacke hängt am Jackenständer im Ost-Saal.“

**P145R2-K10 · klein · Die Dankeskarte kennen bei 13–18 Personen nur die Zusatzrollen**
- Fundstellen: MECH 1.5 (Z. 1299–1300, nur bei 19–20 Personen); Wissen 18:00 bei Sibel, Damir, Hana, Serkan, Azra, Wojtek
  (Z. 4759, 4934, 5102, 5284, 5450, 5622).
- Problem: Bei 13–18 Personen stehen in Zusatzheften Unterschriften unter eine Karte, die sonst niemand kennt; fragt eine
  Zusatzrolle danach, haben die Rollen 1–10 keinen Satz (ZG-14 gilt nur für Zusatzrollen).
- Vorschlag: MECH 1.5: „Ab 13 Personen steht am Ende der Zeile ‚18:00 Uhr‘ zusätzlich, wörtlich: ‚Beim Einlass habt ihr heimlich eine Dankeskarte für Herrn Schneider unterschrieben.‘“

**P145R2-K11 · klein · Aylins Runde-1-Ziel stützt sich auf Wissen, das nicht in ihrem Heft steht**
- Fundstellen: ZR 7.8 R1-2 (Z. 5853) „… bist du aus dem Ost-Saal gegangen …“; WELT 5.8 (Z. 1077); ZR 7.5 (Z. 5775–5788) ohne 23:55.
- Vorschlag: ZR 7.5, neue Zeile: „| 23:55 | Serkan geht aus dem Ost-Saal, gerade als alle zur blinden Kuh sollen. Wohin, sieht sie nicht | WELT §5.8 | offen |“.

**P145R2-K12 · klein · RK 2.11: Damir steht nicht „nur“ in der Fassung**
- Fundstellen: RK 2.11 (Z. 2772) „„ein Gast mit einer großen Teekanne“ (nur Fassung)“; RK 8.1 (Z. 2585) „[Damir] war neben mir.“ (Heft Seite 3).
- Vorschlag: RK 2.11, Zeile Damir: „„ein Gast mit einer großen Teekanne“ (Heft Seite 3 und Fassung)“.

**P145R2-K13 · klein · Seitenlast: Teil 01 Seite 2 und Teil 90 Seite 9**
- Fundstellen: MECH 2.6 Seite 2 (Z. 1466) mit RK 6.6, 6.7, 6.8 (alle „Seite 2“), MECH 9.11 Teil B, Kurzform: rund 800 Wörter.
  MECH 8.4 Seite 9 (Z. 2092): bei 20 Personen 19 Bonus-Ziele mit Prüfbedingung, rund 900 Wörter.
- Vorschlag: MECH 2.6, Seite 6: „Anklagefeld 2.5 mit Hilfe RK §6.10; ‚Aktionskarten‘ (RK §6.8)“; Seite 2 ohne RK 6.8. MECH 8.4: „9 (ab 15 Personen 9 und 10) | Tipp-Wertung …“, die Seite „Zum Nachlesen“ rückt dann nach.

**P145R2-K14 · klein · MECH 12a: weitere Abweichungen vom Auftrag fehlen**
- Fundstelle: MECH 12a (Z. 6708–6734); ergänzt P3R2-22.
- Vorschlag, neue Zeilen wörtlich:
  - „| A:44 | Lejla sah Herrn Schneiders Quittungszettel ‚Miete Schlosskeller: 0 Euro‘ | Lejla sah am Nachmittag auf dem Klemmbrett das Belegungsblatt ‚Saalmiete Schlosskeller: 0 Euro‘; den Quittungszettel hat Aylin | D-11, W-10 |“
  - „| A:52 | ‚150 € Nachzahlung‘ | 150 € pro zahlendem Gast, zusammen 2.550 € | W-12: nur so passt die Nachzahlung zum Mietgeld |“
  - „| A:87 | Marker nach geknackter Lüge auf den wahren Ort | Ollis Marker ‚Scheppern‘ bleibt nach Stufe 2 auf dem Eiskübel bis zur Anklage | R-06: Schlüsse aus mehreren Karten verlangen kein Umstellen; keine Karte nennt Ollis Ort beim Scheppern (P2-04) |“
  - „| A:92 | jeder Domino-Hinweis setzt eine andere Rolle unter Druck | Emines Hinweis nennt niemanden | I-18; WELT §5.5: Emine schaute nur auf Fatma, ein wahrer Satz über eine Person fehlt (P145R2-K15) |“

**P145R2-K15 · klein · Emines Domino-Hinweis bringt nichts Neues**
- Fundstellen: MECH 4.2 Emine (Z. 1725); ZG 2.6 (Z. 3671): „Um elf ist Herr Schneider an der Theke laut geworden. Mit wem, hab
  ich vom Ost-Saal aus nicht gesehen.“; MECH 1.5 23:00 (Z. 1290) sagt dasselbe; MECH 4.2 Prüfsatz (Z. 1731–1732).
- Problem: A:92 verlangt einen neuen Hinweis, der eine andere Rolle unter Druck setzt. Emines Satz steht schon in „Was alle
  wissen“.
- Vorschlag: Nichts erfinden. Die Welt-Phase prüft in WELT 3.4 und 5.5, ob Emine zwischen 23:50 und 23:58 etwas Neues über eine
  Rolle wahrnehmen konnte, die immer besetzt ist, wenn Emine spielt (Plätze 1–5), oder über einen Ort. Gibt es so einen Satz,
  ersetzt er den Domino-Hinweis; der heutige Satz wandert unter „Nach dem Umdrehen“. Gibt es ihn nicht, bleibt der Satz, und
  die Abweichung von A:92 steht in MECH 12a (K14). Der Prüfsatz in MECH 4.2 (Z. 1732, „Emine → niemand Bestimmtes“) bekommt dann
  den Zusatz: „Das ist eine Abweichung von A:92 (MECH 12a).“

**P145R2-K16 · klein · MECH 7.3 behauptet, jedes Bonus-Ziel sei erfüllbar; Ollis ist es ab 7 Personen kaum**
- Fundstellen: MECH 7.3 Regeln (Z. 2019) und Typ „Reinen Tisch“ (Z. 2011); RK 1.6; ZG 1.7 R1-1 (Lejla → Olli), ZG 4.8 R1-1.
- Problem: Ab 7 Personen tritt Ollis Auslöser (b) oder (a) fast sicher in Runde 1 b ein, also vor dem ersten „reinen Tisch“ in
  Abschnitt c. Die Bibel will das (Ausgleich zu M-22), der Regelsatz sagt etwas anderes.
- Vorschlag: MECH 7.3, Regeln, erster Satz: „Jedes Ziel ist bei jeder Personenzahl erfüllbar, bei der die Rolle mitspielt. Ausnahme mit Absicht: Ollis Ziel ist ab 7 Personen kaum zu erreichen; das gleicht die Sonderwertung M-22 aus.“

**P145R2-K17 · klein · Veraltete Verweise „aus der Rollen-Phase“**
- Fundstellen: MECH 2.6 Seite 1 (Z. 1465); MECH 4.2 (Z. 1697, 1740); MECH 5.3 Tabellenkopf (Z. 1861); MECH 8.4 Seite 7–8
  (Z. 2091); MECH 9.4 (Z. 2147–2151).
- Vorschlag: MECH 2.6: „‚Dein Auftritt‘ (RK §6.3)“; MECH 4.2: „Den Wortlaut ‚Was ich zugebe‘ enthalten RK 2.8 bis 5.8, ZG x.6 und ZR x.7.“; MECH 5.3: „Inhalt des Protokolls (Wortlaut ZG 1.11 bis 6.11)“; MECH 8.4: „(Wortlaut RK 2.12 bis 5.12, ZG 1.12 bis 6.12, ZR 1.13 bis 8.13)“; MECH 9.4: „Die Fragen stehen wörtlich in RK 2.3 bis 5.3, ZG 1.3 bis 6.3 und ZR 1.3 bis 8.3, die Frage an den Detektiv in RK 6.3.“

**P145R2-K18 · klein · Zusatzhefte ohne wörtliches „Wer du bist“**
- Fundstellen: ZR 0.7 Seite 1 (Z. 4706) „‚Wer du bist‘ (Profil, Beziehungen, Haltung)“; dagegen ZG 0.6 (Z. 3367–3380) wörtlich.
- Vorschlag: ZR 0.7, neuer Satz: „‚Wer du bist‘ folgt dem Muster ZG 0.6: Name und Alter mit Rollenbezeichnung, Beruf, Merkmal, Beziehungen als Tatsache mit Platzhaltern, dann ‚Was dich heute antreibt:‘ und die Haltung aus x.1.“ Beispiel Sibel: „Du bist Sibel, 23, die Vorsichtige. Du studierst Biologie. Man erkennt dich am rosa Strickpulli und am weißen Fransenschal bis übers Kinn. Mit Zeynep wohnst du in einer WG. [Damir hat dich um neun zur Turm-Toilette begleitet. |] Was dich heute antreibt: Die Rüstung soll aus dem Turmgang verschwinden.“

**P145R2-K19 · klein · RK 7.5: Prüfsatz stimmt nicht**
- Fundstelle: RK 7.5 (Z. 6469): „Herr Schneider überlebt steht in Teil 90 und in ‚Was nur du weißt‘ Nr. 5.“ Nr. 5 sagt das nicht.
- Vorschlag: „‚Herr Schneider überlebt‘ steht in Teil 90 (MECH §8.2); dass er zu sich kam, steht in ‚Was alle wissen‘.“

**P145R2-K20 · klein · Damir und Wojtek werden nie angesprochen (Tugba geht nach ZG-09 nicht)**
- Fundstellen: ZR 9.2 (Z. 6088–6090); 19.2 Nr. 2; Serkan R1-2 (Z. 5360), Aylin R2-2 (Z. 5855).
- Vorschlag (beide Fragen nennen kleinere Plätze und stützen sich nur auf Marker oder auf das, was die Person in der
  Vorstellungsrunde selbst erzählt hat, ZG-08):
  - Serkan, Runde 1 Ziel 2 statt Marek: „Damir, dein Marker ‚Scheppern‘ steht hinter der Theke am Ostende. Wer war im Dunkeln bei dir, und ging es allen gut?“ (Damirs Bonus-Ziel bekommt einen Anstoß; M1 wird weiter laut gesagt.)
  - Aylin, Runde 2 Ziel 2 statt Marek: „Wojtek, du hast vorhin erzählt, dass du um Viertel nach acht in den Vorratsraum geleuchtet hast. Woher hattest du die Taschenlampe, und wo ist sie jetzt?“ (Wojteks offener Satz „Tim hat sich heute meinen Werkzeugkasten geliehen.“ und „Die Taschenlampe liegt wieder im Werkzeugkasten.“ beantworten das wahr und lenken zu MR4; Marek bleibt in Runde 2 Ziel von Lejla und Olli.)

**P145R2-K21 · klein · Erzähler-Bonus: Zählen Karten unter den Streifen mit?**
- Fundstellen: MECH 7.3 (Z. 2022–2023), MECH 9.12 (Z. 2334–2336): „Geheimniskarten der gespielten Rollen“.
- Vorschlag: MECH 9.12, Zusatz: „Karten unter den Zeugenstreifen zählen nicht mit.“

---

## Teil J – Was hält (geprüft, ohne Befund)

- Personenzählung E6, Platzfolge, Solo nur beim kleineren Platz; alle vier Solo-Fassungen vollständig.
- Jedes Ziel, das einen höheren Platz nennt, hat ein Ausweichziel; keine Bitte an den Detektiv ohne zweite Frage.
- Aktionskarten fehlender Zeugen beim Detektiv (MECH 4.6) decken sich mit 9.13 und RK 6.8.
- Abwesenheitsblatt: gleiche Kernsätze und Vermerke wie gespielt; nichts offen von Anfang an; Karten unter den Streifen mit
  denselben Sperren; Schlusszeile entfällt; Format geht auf.
- Meilensteine M1–M9 bei 6 bis 20 Personen erreichbar; Budget bei 6 Personen mit Spielraum.
- Platzhalter für Rollen 5–18 in allen Heften, Karten und Fassungen; Namen in Teil 90 nach WELT 1.1.
- Vorstellungsrunde: 19 Fragen und 19 Auftritte wörtlich, Anekdoten der Dias 3–5 bei Sibel, Olli (mit Azra/Wojtek namenlos),
  Hana; Lacher fehlender Zusatzrollen.
- Spoiler: Geheimniskarten neutral, XD3 richtig, Fassungen außen gleich, Erzählerheft ohne Lösung (bis auf M10).
- Ton: keine Schlag-Verben, kein Blut, kein Alkohol, Rauch nur mit Kamin, Satzlängen und Mittelwerte eingehalten, keine
  Ziffern in Vorlesetexten, Tugba unbelastet, Herkunft und Kopftuch nirgends im Spiel.
- Teileliste: Seitenzahlen von Teil 02, 10, 11, 20 nachgerechnet und stimmig.
