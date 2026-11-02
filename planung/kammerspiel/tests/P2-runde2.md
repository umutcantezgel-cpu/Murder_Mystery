# Protokoll 2 – Domino-Ketten-Simulation (Prüfrunde 2)

Stand 2026-11-01. Geprüft: `bibel/FALL-BIBEL.md` (Integration Runde 1, 6970 Zeilen) gegen `AUFTRAG.md` (A) und
`ENTSCHEIDUNGEN.md` (E). Abgeglichen mit `bibel/TESTPROTOKOLL.md` und `bibel/tests/P2-runde1.md`. Repo nur gelesen.
Fundstellen: Kennung aus FALL-BIBEL 0.2 und Zeilennummer in `FALL-BIBEL.md` („Z.“). Haltung: gegnerisch. Gesucht wurde nach
Sackgassen, Zirkeln, vorzeitiger Lösung, nicht entlastbaren Unschuldigen, Beweisen, die nicht auf Olli zeigen, und einer
Stufe 2 von Olli, die zu schwach oder unwiderlegbar ist. Dazu nach Stellen, an denen der nicht allwissende Erzähler einen
Streit am Tisch entscheiden müsste.

**Ergebnis in einem Satz:** Die Ketten tragen in allen vier Besetzungen ohne Sackgasse, ohne Zirkel und ohne formales
Lösen vor Runde 3, alle drei Unschuldigen sind entlastbar und alle Beweise zeigen auf Olli; aber die Regel „vor allen“ ist
so eng gefasst, dass Ollis und Cans wichtigste Auslöser im normalen Spiel strittig werden, FN3 entscheidet den Fall faktisch
schon in Runde 2, und drei Ortskarten legen mit „Kein Schlüsselbund“ einen falschen Schluss auf den Eiskübel nahe
(0 Blocker, 3 mittel, 8 klein).

---

## 0. Nachprüfung der Befunde aus Runde 1

| Befund R1 | Stand in der Bibel | Urteil |
|---|---|---|
| P2-01 Teil 01 verrät den Schlüsselbeweis | Bogen „Teil 1 ☐ · Teil 2 ☐ · gehört zu“ (MECH 2.1, Z. 1407); Regel 2.4 ohne Spur-Hinweis (Z. 1444–1448); gleiche Titel „[Name]: Taschen und Kleidung“ (MECH 3.1 Nr. 8) | behoben |
| P2-02 FN3 benennt den Halter | FN3 nur zwei Hinweis-Vermerke (Z. 1562); XD3 trägt „Schlüsselbeweis, Teil 1“ (Z. 1617) | behoben; Restwirkung der roten Tropfen siehe P2-17 |
| P2-03 Funde nach dem Gespräch, Tipp trivial | Runde 3: a, b, c, Tipp-Runde, d, e, Anklage (MECH 1.3, Z. 1236–1238) | behoben; Frage 1 bleibt bei FN3 in Runde 2 trivial (P2-17) |
| P2-04 Ollis Scheppern-Marker | R-06 Satz 2 (Z. 1259); RN7 Satz 5 (Z. 6460) | behoben |
| P2-05 Alibi aus eigener Behauptung | MECH 6.1 (Z. 1916–1917), Hinweis über dem Raster (Z. 1411) | behoben |
| P2-06 Zeugen-Dominos ins Leere | neue Dominos Lejla → Olli, Joanna → Can, Marek → Tim, Emine → niemand (MECH 4.2, Z. 1724–1729) | behoben |
| P2-07 Meta-Hinweis „Eiskübel ab Runde 3“ | PP9 „Vor der Theke am Ostende“, VP7 ab Runde 3 (MECH 3.2) | behoben; neue Lesefalle P2-18 |
| P2-08 Schutzkarten würgen Auslöser ab | eine Grenze für alle vier (MECH 4.4, Z. 1772) | behoben |
| P2-09 Zeitstempel | „Kann sie niemanden nennen, sagt sie das.“; Umschreibungen (MECH 9.14) | behoben; Lücke Herr Schneider und 23:51 (P2-21) |
| P2-10 „vor allen“ | R-13 (Z. 1266) | behoben, aber zu eng (P2-16) |
| P2-11 Handzeichen | Enthaltung auf der Karte (Z. 1789) | behoben |
| P2-12 Domino-Frage an Herrn Schneider | MECH 9.9 (Z. 2228–2229) | behoben; Antwortlücke bei Personen am Tisch (P2-20) |
| P2-13 Graph-Tabellen | MECH 5.3, 3.4, 6.3 angeglichen | behoben |
| P2-14 23:56/23:57 bei Ahmet | WELT 0.2 Regel (Z. 130) | weitgehend behoben; Rest in Joannas Wissen-Tabelle (P2-26) |
| P2-15 Tugbas Vermutung | Cans (c) „gesehen“; Hinweis MECH 4.2 (Z. 1711–1713) | behoben; Reihenfolge offen (P2-19) |

---

## 1. Auslöser-Graph

### 1.1 Indizkarten (19): Runde, Pflicht, Streifen, Feld

„Str“ = Zeugenstreifen, „GK“ = Geheimniskarte, „unter Str“ = Karte unter dem Streifen (MECH 9.14). Sperren in Klammern.

| Code | ab | Titel (Teil 01) | Pflicht-Auslöser | öffnet Str | öffnet GK unter Str | füllt |
|---|---|---|---|---|---|---|
| RH3 | 1 | Ortstermin: linker Buffettisch | – | Emine | – | M2 |
| DM3 | 1 | Ortstermin: rechter Buffettisch | Olli (b) über Lejla oder Str | Lejla | – | Olli Alibi ✗ |
| WJ9 | 1 | Ortstermin: hinter der Theke am Ostende | – | Marek | – | M1 |
| FX3 | 1 | Ortstermin: Tür zum Ost-Saal | Olli (a); Fatma-Marker → 4a (R-06) | Joanna | – | Ort 23:57 alle vier |
| AD3 | 1 | Ortstermin: Durchgang | – | Tim, Zeynep | – | Hinweise |
| WE3 | 1 | Jackenständer | Lejla, Joanna, Aylin (R2); Ahmet (c) mit Taschenkontrolle | – | Lejla, Joanna (R2) | Hinweis M4 |
| JA9 | 1 | Herrn Schneiders rechte Hand | Can (c) mit Satz „Gesicht aus dem Vorratsraum“ | – | – | Hinweis (falsche Fährte) |
| FM9 | 1 | Schauvitrine | Emine (R2); Fatma (b) mit Marker 4a; Sibel; Azra | – | Emine (R2) | Hinweis M5 |
| YT4 | 1 | Bogentür und Ritterrüstung | Sibel, Damir | – | – | Hinweis · HT (M7 mit FN3) |
| PM3 | 2 | Klemmbrett | Ahmet (a); Lejla, Joanna, Aylin (R2) | – | Lejla, Joanna | M4 |
| MR4 | 2 | Kaffeemaschine und Werkzeugkasten | Tim (R3); Wojtek (R2) | – | Tim (R3) | Hinweise |
| WM9 | 2 | Ascheneimer | Ahmet (a); Lejla, Joanna (R2) | – | Lejla, Joanna | M4 |
| NN3 | 2 | Fatma: Taschen und Kleidung | Fatma (a); Emine (R2); Azra | – | Emine | M5 |
| JT3 | 2 | Can: Taschen und Kleidung | Can (a); Marek, Zeynep (R3) | – | Marek, Zeynep (R3) | M6 |
| FN3 | 2 | Olli: Taschen und Kleidung | – | – | – | M7 mit YT4; Teil 2 von M9 |
| XD3 | 3 | Messingkerzenständer und Vorratsraum | Marek (R3) | – | Marek | M9 Teil 1 |
| PP9 | 3 | Vor der Theke am Ostende | – | – | – | M8 |
| VP7 | 3 | Kamin-Nische | Hana | – | – | Hinweis |
| FK3 | 3 | Ortstermin: im Steinbogen | Zeynep, Tim (R3) | Zeynep | Zeynep, Tim | M3, M6 |

Wege ohne Untersuchung: Krankenbesuch (R1, legt JA9 frei), Zeitstempel (R1, öffnet einen Streifen), Taschenkontrolle (R2;
Olli → FN3, Can → JT3, Fatma → NN3; Ahmet → Bündel, zählt für Ahmet (c) mit WE3), Stirnlampe (R2, vierte Untersuchung).

### 1.2 Geheimniskarten: Sperre, Auslöser, Domino

| GK | Sperre | Auslöser über Codes | Auslöser über Karten, Wort, Gespräch | Domino trifft |
|---|---|---|---|---|
| 1 Ahmet | – | PM3, WM9; WE3 + Taschenkontrolle | GK 5 | Olli (Pflicht c) |
| 2 Fatma | – | NN3; FM9 + Marker 4a | GK 6 | Ahmet (Druck) |
| 3 Olli | – | FX3/Str Joanna; DM3/Str Lejla | Joanna trägt vor; Lejla sagt es; Ahmet oder Fatma sagen „Eiskübel 23:57“ – **alle drei „vor allen“** | Can (Pflicht c mit JA9) |
| 4 Can | – | JT3; JA9 + Satz | GK 10 | Fatma, Emine (Druck) |
| 5 Lejla | R2 | WE3, PM3, WM9 | GK 1, GK 8 (gesp.) | Olli (Eiskübel nach dem Licht) |
| 6 Emine | R2 | FM9, NN3 | GK 2 | niemand (Streit um elf) |
| 7 Tim | R3 | MR4, FK3 | Frage in R3 (auch Impuls), „das Gespenst war es“ in R3, GK 10 | Olli (Möbelwachs) |
| 8 Joanna | R2 | WE3, PM3, WM9 | GK 1, GK 5 | Can (weder Buffetsaal noch Durchgang) |
| 9 Marek | R3 | XD3, JT3 | GK 4, Frage in R3 (auch Impuls), „Gespenst“ in R3 | Tim („Nicht die alte Leiste!“) |
| 10 Zeynep | R3 | FK3, JT3 | GK 4, Frage in R3 (auch Impuls), „Can oder Gespenst“ in R3 | Tim (frag ihn) |
| 11 Sibel | – | FM9, YT4 | GK 12, Vitrinen-Vorwurf | Damir / allein: Scheibe lose seit 21:00 |
| 12 Damir | – | YT4 | GK 11, Vitrinen-Vorwurf | Ahmet (Umschlag beim Licht) |
| 13 Hana | – | VP7 (R3) | GK 14, zweimal nach dem Papier gefragt | Serkan / allein: alter Handschuh |
| 14 Serkan | – | – | zweimal nach dem Außentor gefragt, GK 13 | Hana |
| 15 Azra | – | NN3, FM9 | GK 2 | Wojtek / allein: Tims Satz von 20:15 |
| 16 Wojtek | R2 | MR4 | GK 15, GK 7 | Tim (Satz von 20:15) |
| 17 Aylin | R2 | PM3, WE3 | GK 1, Taschenkontrolle | Bogentür (Durchschlag) |
| 18 Tugba | – | – | jederzeit; GK 17, Taschenkontrolle | Aylin |

### 1.3 Offenes Wissen, das eine Kette startet

| Quelle (Stufe 1 oder Streifen) | Kern | Kante |
|---|---|---|
| Lejla / Str Lejla | „Beim Scheppern war ich allein. Erst danach ist Olli zu mir gekrochen.“ | → GK 3 (b), nur „vor allen“; Olli Alibi ✗ |
| Lejla (nur gespielt) | „Als das Licht anging, ist Olli als Erstes zum Eiskübel.“ | Druck Richtung PP9 |
| Joanna / Str Joanna | Notiz 23:57; „Zweitausend, bis zwölf“; Kopf der Tafel leer | → GK 3 (a), nur „vor allen“; Fatma-Marker → 4a (R-06, ohne „vor allen“) |
| Emine / Str Emine | Fatma neben ihr beim Scheppern | → M2 |
| Marek / Str Marek; Damir | Ahmet an Mareks Beinen | → M1 |
| Fatma nach Marker 4a | „Von der Klappe hab ich Olli am Eiskübel gesehen.“ | → GK 3 (c), nur „vor allen“ |
| Ahmet „sofort“ | „Durch das Ostende ist im Dunkeln niemand an mir vorbeigekommen.“ | mit Mareks zweiter Gestalt: Weg zur Tür nur über die Klappe |
| Tugba (20) | linker Handschuh 19:30 in der Nische, rechter in der Weste | Druck → FN3, VP7 |
| Can, Zeynep, Hana, Tim (offen) | Olli um zehn vor zwölf an der Bogentür | Druck → YT4 |

### 1.4 Kanten zu den Feldern des Bogens

| Feld | erreichbar über | frühestens |
|---|---|---|
| M1 Ahmet Alibi | Marek S1, Str Marek (WJ9, Zeitstempel), Damir | R1 |
| M2 Fatma Alibi | Emine S1, Str Emine (RH3, Zeitstempel) | R1 |
| M3 Can Alibi | GK 7, GK 9, GK 10, FK3; Zuordnung „Gesicht = Can“ über GK 4, JT3 oder GK 10 | R3 |
| M4 Ahmet HT | PM3, WM9, GK 1, GK 5, GK 17, Azra | R2 (GK 1 freiwillig ab R1) |
| M5 Fatma HT | NN3, GK 2, GK 6 | R1 (FM9 + Marker) |
| M6 Can HT | JT3, GK 4, GK 10 | R1 (JA9 + Ollis Domino) |
| M7 Olli HT | GK 3, YT4 + FN3, GK 7, GK 16 | R1 |
| M8 Fundort | PP9 | R3 (nach der Tipp-Runde) |
| M9 Schlüsselbeweis | XD3 + FN3 | R3 (nach der Tipp-Runde) |
| Ort 23:57 Olli | Joanna, Str Joanna, GK 3, Ahmets und Fatmas Aussage | R1 |

### 1.5 Schwellen: Welche Auslöser hängen an „vor allen“?

| Auslöser | Text | schließt Impulse ein? | schließt Kartenvorlesen ein? |
|---|---|---|---|
| Olli (a) | „oder [Joanna] sie vor allen vorträgt“ (Z. 3033) | nein | – |
| Olli (b) | „Sobald [Lejla] vor allen sagt“ (Z. 3034) | nein | – |
| Olli (c) | „Sobald Ahmet oder Fatma vor allen sagen“ (Z. 3035) | nein | nein (Ahmets Domino wird in Abschnitt d vorgelesen) |
| Can (c) | „und jemand vor allen sagt“ (Z. 3208) | nein | nein (Ollis Domino) |
| Tim 2, Marek 3, Zeynep 3 | „Auch ein Impuls des Erzählers, der alle danach fragt, zählt.“ (Z. 3850, 4234, 4415) | ja | – |
| R-06 Marker | „eine vorgelesene Notiz aus einem Heft“ (Z. 1259) | ohne „vor allen“ | – |
| R-13 | „am Verhörstuhl, bei der Gegenüberstellung oder nachdem der Erzähler ‚Alle mal herhören!‘ gerufen hat“ (Z. 1266) | nein | nein |

Ergebnis: Drei Schwellen für denselben Satz (R-06 ohne, Zeugen mit Impuls, Verdächtige ohne Impuls). Siehe P2-16.

### 1.6 Zirkel-Prüfung

| Komponente | Ausweg über einen Code | Urteil |
|---|---|---|
| GK 1 ↔ GK 5 ↔ GK 8 | WE3, PM3, WM9 | kein Zirkel |
| GK 2 ↔ GK 6 | NN3, FM9 | kein Zirkel |
| GK 4 ↔ GK 10 | JT3, FK3; JA9 + Ollis Domino | kein Zirkel |
| GK 10 → GK 7 → GK 16 | MR4, FK3 | kein Zirkel |
| GK 11 ↔ GK 12 | YT4, FM9 | kein Zirkel |
| GK 13 ↔ GK 14 | VP7, zweite Frage | kein Zirkel |
| GK 15 → GK 16 | FM9, NN3; MR4 | kein Zirkel |
| GK 17 ↔ GK 18 | PM3, WE3; Tugba jederzeit | kein Zirkel |

Jede Karte hat einen Auslöser, der an einer Indizkarte hängt. **Bestanden.**

### 1.7 Sackgassen- und Budget-Prüfung

Jedes Feld hat bei jeder Personenzahl einen Weg über Indizkarten oder Streifen (MECH 6.3 nachgerechnet). Engster Fall
6 Personen: M3 nur über Karten unter Streifen (MR4/FK3, XD3/JT3, FK3/JT3), alle ab Runde 3; XD3 wird für M9 ohnehin gezogen
und öffnet Mareks Karte. Der Fundort PP9 und XD3 liegen beide in Runde 3 nach der Tipp-Runde; mit FN3 aus Runde 2 reichen
drei Untersuchungen für die Überführung. **Bestanden.** Abstriche bei wörtlicher Auslegung von R-13 (Lauf c2): 8 statt 9
Punkte, kein Bruch.

---

## 2. Simulationen

Schreibweise: „→ GK n“ = Karte wird umgedreht. „[P2-nn]“ = Befund an dieser Stelle. Wo R-13 den Ausgang ändert, sind beide
Lesarten genannt: **wörtlich** (der Erzähler hält sich an R-13, weil er die Lösung nicht kennt und nicht deuten darf) und
**großzügig** (der Tisch zählt alles, was alle hören).

### 2.1 (a) 10 Personen, zurückhaltender Tisch

Besetzung: Rollen 1–8, Detektiv, Erzähler. Streifen Marek (4d) und Zeynep (6), ihre Geheimniskarten darunter. Beim Detektiv:
Taschenkontrolle, Gelbe Karte. Annahmen: niemand dreht freiwillig um, Zeugen sagen nur Gefragtes, Nachbohr-Ziele knapp,
Detektiv folgt RK 6.5.

**Runde 1**

| Schritt | Ereignis | Folge |
|---|---|---|
| b, Verhörstuhl | A1–A3 an die vier (Stufe 1). Ahmet: Ostende, Servietten, „der Caterer stand neben mir“. Fatma: linkes Buffet, Emine. Olli: Kopf der Tafel, sitzen geblieben. Can: Turm-Toilette | Emine bestätigt das Scheppern: M2 (Quelle Emine). „Der Caterer“ öffnet keinen Streifen (nur Zeitstempel) |
| b, Impuls I-1.2 (Ziel 2 des Detektivs) | Lejla: „Beim Knall niemand. Beim Scheppern auch niemand. Erst danach ist Olli zu mir gekrochen.“ | wörtlich: Impuls ist nicht „vor allen“ → Olli bleibt bei „Weiß ich nicht genau“ **[P2-16]**; großzügig: → GK 3 (b) |
| b, Nachbohr | Joanna → Olli (eine Zeile der Notiz, im Zweiergespräch); Joanna → Fatma („Fatma: geht zur Klappe“) | R-06: Fatma stellt 23:57 auf 4a, Olli müsste nach R-06 ebenfalls umstellen, sein Auslöser (a) aber verlangt „vor allen vorträgt“; RK 4.6 Z. 3024 („kommt bei Olli nicht vor“) stimmt nicht **[P2-16]** |
| b | Lejla → Olli, Emine → Lejla, Tim → Fatma | Druck, keine Karte (wörtlich) |
| c | niemand | – |
| d | WJ9 (Str Marek: M1), JA9 (gelbe Fasern), YT4 (Bogentür) | Cans (c) offen, weil Ollis Domino fehlt |
| e | Fatma 4a | – |

Stand: M1, M2. Olli wörtlich in Stufe 1, großzügig in Stufe 2 (dann weiter wie Lauf b).

**Runde 2 (wörtliche Lesart)**

| Schritt | Ereignis | Folge |
|---|---|---|
| a | keine Zeugenkarte fällig | – |
| b | I-2.1 Geld; Verhörstuhl Turmgang und Gesicht. Taschenkontrolle bei Fatma → NN3 | → GK 2 (M5), Domino Ahmet; → GK 6 (R2): „um elf laut“ → „Wer weiß dazu etwas?“ |
| d | PM3 | → GK 1 (M4). Ahmets Domino „Olli am Eiskübel, Zweitausend“ wird in Abschnitt d vorgelesen; wörtlich nicht „vor allen“ → Olli (c) strittig **[P2-16]**. → GK 5, GK 8 (R2): Dominos auf Olli und Can; Domino-Fragen beantworten beide mit Stufe 1 |
| d | FN3 | rote Tropfen auf dem Handschuh, Kalk an den Bündchen. „Was alle wissen“: einzige echte Kerzen im Kerzenständer. Wer beides zusammenlegt, weiß: Olli war am brennenden Kerzenständer. Olli hat für Runde 2 keinen Satz (Block „Wenn es eng wird (Runde 3)“) **[P2-17]** |
| d | JT3 | → GK 4 (M6, 23:57 → 5). Karten unter den Streifen Marek und Zeynep vorgemerkt |

Stand: Ahmet (M1 + M4) und Fatma (M2 + M5) ausgeschieden. Olli formal noch zu, M7 über YT4 + FN3, Ort 23:57 über Joannas und
Ahmets Worte (Quelle mündlich). Faktisch ist Olli nach FN3 der Täter.

**Runde 3**

| Schritt | Ereignis | Folge |
|---|---|---|
| a | Karten unter Marek und Zeynep (JT3 offen) | M3 doppelt; zweite Gestalt von der Klappe. Beide Dominos nennen Tim |
| b | Detektiv: „Was kam zuerst?“ → Tim (R3, Frage) | → GK 7: M3 dreifach. Domino „Das Möbelwachs aus dem Werkzeugkasten hab ich um 18:45 Olli gegeben“. Domino-Frage an Olli; sein Heft verbietet die Antwort **[P2-20]** |
| b | Joanna R3-1: „Detektiv, wenn er da so lange war, dann schau dir den Eiskübel an.“ | Hinweis auf PP9 |
| Tipp | alle: Olli, Eiskübel | Frage 1 seit Runde 2 entschieden |
| d | XD3 (Teil 1; Teil 2 = Bündchen auf FN3), PP9 (M8), FX3 | Joanna antwortet am Ortstermin → Olli (a): endlich GK 3. FX3 nennt den Eiskübel und endet „Kein Schlüsselbund“, nachdem PP9 dort den Bund fand **[P2-18]** |
| Anklage | Olli | 9 von 9, Ende 1 |

Ergebnis (a): keine Sackgasse, kein Zirkel, formal erst in Runde 3 überführt. Wörtlich bleibt Ollis Karte zwei Runden zu,
obwohl drei seiner Auslöser inhaltlich erfüllt sind. FN3 entscheidet in Runde 2.

### 2.2 (b) 10 Personen, forscher Tisch

Annahmen: alle spielen ihre Ziele hart, Aktionskarten früh, freiwilliges Umdrehen fürs Bonus-Ziel. Forsche Spieler bitten den
Erzähler um „Alle mal herhören!“.

**Runde 1**

| Schritt | Ereignis | Folge |
|---|---|---|
| b, Minute 1–3 | Joanna lässt „Alle mal herhören!“ rufen und liest die Notiz | → GK 3 (a): M7, Ort Eiskübel. Olli mündlich: „geduckt“, „Gespenst auf Herrn Schneider los“. Marker 4b/4b. Fatma 23:57 → 4a |
| b | Lejla spielt Krankenbesuch → JA9 offen | Ollis Domino fiel vorher. Ob Cans (c) jetzt greift, sagt der Wortlaut nicht **[P2-19]**. Forscher Can dreht: → GK 4 (M6, 23:57 → 5); Domino Fatma, Emine |
| b | Domino-Frage an Fatma (Karte zu) | Fatmas Heft hat keinen Satz zum Tuscheln **[P2-20]** |
| b | Can R1-1 an Olli: „Um zehn vor zwölf standst du an der Bogentür.“ | Olli hat dazu keinen Satz in Stufe 1 **[P2-21]** |
| b | Joanna spielt Zeitstempel auf Ahmet, 23:57 → „der Caterer“ | Str Marek: M1 |
| c | Fatma dreht freiwillig (Bonus) | → GK 2: M5; Domino Ahmet |
| d | FM9, YT4, DM3 (Lejla vor allen) | Emine für R2 vorgemerkt |

Stand: M1, M2, M5, M6, M7; Ort-Zeile vollständig. Olli gegen Can: Wort gegen Wort. Glaubwürdig für Olli: Herrn Schneiders
Erinnerung („sprang ihn an“), JA9, „Can: nirgends!“.

**Runde 2**

| Schritt | Ereignis | Folge |
|---|---|---|
| a | → GK 6 (FM9) | Domino „um elf“ |
| b | Taschenkontrolle (Detektiv) bei Olli → FN3 | rote Tropfen; Olli hat nur „Die roten Tropfen? Keine Ahnung.“ und das erst für Runde 3 **[P2-17]** |
| b | Olli R2-1 an Can: „Ich hab das leuchtende Gesicht aus dem Vorratsraum springen sehen. Can, du warst um drei vor zwölf nirgends. Wo warst du da?“; Can: „Er hat mich gepackt, nicht umgekehrt“ (steht bei Can ebenfalls unter „Runde 3“) | Gespräch trägt; die Tropfen sprechen gegen Olli |
| b | Tim spielt Stirnlampe | vier Untersuchungen |
| d | PM3 (→ GK 1, GK 5, GK 8), MR4, JT3, WM9 | Ahmet, Fatma ausgeschieden; Tim (R3) und Karten unter Marek, Zeynep (R3) vorgemerkt |

**Runde 3**

| Schritt | Ereignis | Folge |
|---|---|---|
| a | → GK 7 (MR4), Karten unter Marek, Zeynep (JT3) | M3 dreifach; zweite Gestalt; Ollis Stufe 2 fällt in Minute 1 |
| b | Olli: „Kann sein. Im Dunkeln weiß doch keiner genau, was zuerst kam.“; Lejla und Joanna lenken zum Eiskübel | Druck |
| Tipp | Frage 1 trivial, Frage 2 aus dem Gespräch | – |
| d | XD3, PP9, FK3 | 9 von 9, Ende 1 |

Ergebnis (b): Ketten laufen schnell und sauber. Olli fällt in Runde 1 (gewollt). Am Ende von Runde 2 ist der Fall wegen FN3
entschieden; die Gegenüberstellung von Olli und Can (MECH 3.5 Nr. 2) findet kaum statt.

### 2.3 (c) 6 Personen

Besetzung: Ahmet, Fatma, Olli, Can, Detektiv, Erzähler. Sechs Streifen, sechs Karten darunter. Beim Detektiv: Krankenbesuch,
Kreuzverhör, Stirnlampe, Zeitstempel, Taschenkontrolle, Gelbe Karte.

**Variante c1 – guter Detektiv**

| Runde | Ereignis | Folge |
|---|---|---|
| R1 b | Ahmet bittet um WJ9, Fatma um RH3 (Ausweichziele); Olli fragt Can, Can fragt Fatma. Zeitstempel auf Fatma, 23:57 → „meine beste Freundin“ | Str Emine: M2 |
| R1 b | Krankenbesuch → JA9 offen | Hinweis Kapuze |
| R1 d | WJ9 (M1), DM3 (Str Lejla → GK 3 (b): M7, Ort), FX3 (Str Joanna: Ort-Zeile, Fatma → 4a) | Ollis Domino wird in Abschnitt d vorgelesen: wörtlich nicht „vor allen“, Cans (c) strittig **[P2-16, P2-19]**; großzügig → GK 4 |
| R2 b | Taschenkontrolle bei Olli → FN3 | **[P2-17]** |
| R2 d | Stirnlampe; PM3 (→ GK 1: M4; Karte unter Str Lejla: Domino Olli), NN3 (→ GK 2: M5; Karte unter Str Emine), JT3 (falls Can noch zu: M6; Karten unter Marek, Zeynep R3), MR4 (Karte unter Tim R3) | Ahmet, Fatma ausgeschieden |
| R3 a | Karten unter Tim, Marek, Zeynep | M3 dreifach; Tims Domino an Olli **[P2-20]**; Mareks und Zeyneps Dominos nennen Tim (fehlt) → Ausweichsatz |
| R3 b | 12 Minuten genügen; Tipp | – |
| R3 d | XD3, PP9, FK3 (überzählig) | 9 von 9 |

**Variante c2 – schwacher Detektiv, keine Aktionskarte**

| Runde | Ereignis | Folge |
|---|---|---|
| R1 d | WJ9 (M1), RH3 (M2), JA9 | Olli zu |
| R2 d | PM3 (→ GK 1: M4; Domino in Abschnitt d), NN3 (M5), FN3 | wörtlich: Olli (c) nicht erfüllt; großzügig: → GK 3 (M7, Ort), dann mit JA9 → GK 4 (M6) |
| R3 d | XD3 (Teil 1, Teil 2; Karte unter Marek: Alibi „für das leuchtende Gesicht“), PP9 (M8), dritte Karte | wörtlich: entweder FX3 (→ GK 3: M7; Ollis Domino in d löst Can nicht aus → M6 fehlt, M3 nicht Can zuzuordnen) oder JT3 (M6, Zeyneps Karte: M3 zu Can; M7 fehlt, YT4 nie gezogen) → 8 von 9. Großzügig: 9 von 9 mit einer freien Karte |

Überführt ist Olli in beiden Lesarten: Ort 23:57 kommt aus Ahmets vorgelesenem Domino (Quelle Ahmet). Ergebnis (c): keine
Sackgasse; E7 hält (nichts ist offen von Anfang an). Die enge R-13 kostet einen Punkt und macht Cans und Ollis Karten von der
Reihenfolge der Untersuchungen abhängig.

### 2.4 (d) 20 Personen

Alle 18 Rollen, keine Streifen. Ab 14 Personen in Runde 1 „Wechsel!“, in Runde 2 und 3 Gegenüberstellung, dann „Wechsel!“.

**Runde 1**

| Schritt | Ereignis | Folge |
|---|---|---|
| b | Damir (I-1.2): Ahmet flüsterte neben ihm | M1 |
| b | Serkan → Lejla und Tugba → Joanna, jeweils im Grüppchen | Lejla und Joanna wissen nicht, dass ihr Satz ein Auslöser ist, und rufen den Erzähler nicht (R-13) **[P2-16]**. Am Verhörstuhl oder beim Impuls I-1.2 reihum kommt es vor alle; wörtlich zählt nur der Verhörstuhl |
| b | Tugba (offen): linker Handschuh in der Nische, rechter in der Weste | zielt auf FN3 |
| b | Sibel, Hana (offen): Gesicht huschte quer durch den Kaminsaal zur Bogentür | stützt M6, keine Reihenfolge zum Scheppern (M-14 hält) |
| b | Serkan zweimal nach dem Außentor gefragt | → GK 14 → GK 13 |
| b | Tugba spielt Handzeichen: „Wer hat das Gesicht gesehen?“ | Tim, Marek, Zeynep enthalten sich (P2-11 hält) |
| d | WJ9 (Marek, Ahmet, Damir antworten), YT4 (→ GK 11, GK 12), JA9 (mit Ollis Domino → GK 4, Reihenfolge **[P2-19]**) | – |

**Runde 2**

| Schritt | Ereignis | Folge |
|---|---|---|
| b | Gegenüberstellung: Tugba R2-1 an Olli („Was hast du heute damit angefasst?“); Marek spielt Taschenkontrolle bei Olli → FN3 | **[P2-17]** |
| b | Azra (ab R2): Ahmet am Ascheneimer; Aylin: Zettel | Stütze M4 |
| d | PM3 (→ GK 1, 5, 8, 17), MR4 (→ GK 16; Tim R3), NN3 (→ GK 2, 6, 15) | Ahmet, Fatma ausgeschieden |

**Runde 3**

| Schritt | Ereignis | Folge |
|---|---|---|
| a | Cans Karte offen → GK 9, GK 10; MR4 → GK 7 | M3 dreifach; Hanas Geruch frei |
| b | Gegenüberstellung: Olli gegen sechs Zeugen und fünf Zusatzrollen | Stufe 2 fällt sichtbar |
| Tipp | trivial | – |
| d | XD3 (Tugbas Torten-Ziel), PP9 (Serkans Ziel), FK3 | 9 von 9 |

ZG-15 nachgeprüft: Kein Satz einer Zusatzrolle erfüllt einen Pflicht-Auslöser der vier. Sibel und Hana sagen „zur Bogentür“,
nicht „aus dem Vorratsraum“; Tugbas Vermutung zählt nach MECH 4.2 nicht.

---

## 3. Prüfkriterien

| Kriterium | (a) 10 zurückh. | (b) 10 forsch | (c) 6 | (d) 20 | Urteil |
|---|---|---|---|---|---|
| keine Sackgasse | ja | ja | ja (c2 wörtlich 8 von 9) | ja | **bestanden** (P2-16 kostet Punkte, bricht nichts) |
| keine zirkuläre Bedingung | ja | ja | ja | ja | **bestanden** |
| kein Auto-Solve vor Runde 3 | formal ja; FN3 entscheidet in R2 | dto. | dto. | dto. | **formal bestanden**; faktisch in Runde 2 vorentschieden, sobald FN3 offen liegt (P2-17) |
| Ahmet entlastbar | M1 + M4 | dto. | dto. | + Damir, Azra, Aylin | **bestanden** |
| Fatma entlastbar | M2 + M5 | dto. | dto. | dto. | **bestanden** |
| Can entlastbar | M3 (R3) + M6 | dto. | dto. | + Hana | **bestanden** (Zuordnung „für das leuchtende Gesicht“ ohne Hinweis im Bogen, P2-24) |
| Bogentür/Kalk → Olli | YT4, GK 3, FN3, MR4, GK 7 | dto. | dto. | + GK 16, GK 17 | **bestanden** |
| Kerzenständer → Olli | XD3 + Bündchen auf FN3 | dto. | dto. | dto. | **bestanden** |
| Handschuh → Olli | FN3 | dto. | dto. | + Tugba, VP7 | **bestanden** |
| Eiskübel → Olli | PP9 + Ort 23:57 + Ollis Stufe 2 + Lejla | dto. | dto. | dto. | **bestanden**; Lesefalle „Kein Schlüsselbund“ (P2-18) |
| späte Ankunft rechtes Buffet → Olli | Lejla | dto. | Str Lejla | dto. | **bestanden**; als Auslöser nur „vor allen“ (P2-16) |
| Ollis Stufe 2 glaubwürdig | in R1 ja: Herrn Schneiders „sprang ihn an“, JA9, „Can: nirgends!“, Lejla passt dazu | dto. | dto. | dto. | **teilweise**: ab FN3 in Runde 2 nicht mehr (P2-17) |
| Ollis Stufe 2 widerlegbar | GK 7, GK 9, GK 10, FK3, XD3 + FN3, PP9 | dto. | dto. | + Hana | **bestanden** |

Was gut trägt (Schlusskette): Mareks „Umriss von der Klappe“, Ahmets „durch das Ostende kam niemand“ und Fatmas Alibi über
Emine zwingen den Weg des Täters über die Klappe; vom Eiskübel sind es fünf Meter (Maßtabelle). Das zeigt auf Olli, ohne dass
eine Karte seinen Namen nennt.

---

## 4. Befunde

### P2-16 · mittel · „Vor allen“ ist zu eng; Ollis und Cans wichtigste Auslöser werden strittig

**Fundstelle:** MECH 1.4 R-13 (Z. 1266), R-03 (Z. 1256), R-06 (Z. 1259), Kurzform „So spielt ihr“ (Z. 1269–1273), MECH 0.2
„Vor allen“ (Z. 1159), RK 6.6 „Gut zu wissen“ (Z. 6223); Auslöser RK 4.7 (a)–(c) (Z. 3033–3035), RK 5.7 (c) (Z. 3208),
MECH 4.2 (Z. 1708–1709); RK 4.6 (Z. 3024); ZG 1.7 R1-1 (Z. 3509), ZG 4.8 R1-1 (Z. 4078).

**Problem:** R-13 zählt nur Verhörstuhl, Gegenüberstellung und „Alle mal herhören!“. Nicht erfasst sind: Antworten auf einen
Impuls (der Detektiv soll in Runde 1 ausdrücklich I-1.2 „Wer war neben dir?“ bestellen, RK 6.5; genau dort sagt Lejla Ollis
Auslöser (b)), Antworten am Ortstermin (die Karten selbst sagen „sagt vor allen“), das Vorlesen umgedrehter Karten in den
Abschnitten c und d (Ahmets Domino ist Ollis (c), Ollis Domino ist Cans (c)) und das freie Gespräch bis 11 Personen. Tim, Marek
und Zeynep zählen Impulse ausdrücklich mit, Olli und Can nicht. Der Erzähler kennt die Lösung nicht und kann den Streit „Das
war nicht vor allen“ nicht entscheiden; der Täter hat jeden Grund, ihn zu führen. Dazu zwei Schwellen für dieselbe Notiz:
R-06 stellt Ollis Marker schon bei „vorgelesener Notiz“ um, sein Auslöser (a) verlangt „vor allen vorträgt“. Dann fällt Ollis
Marker ohne Karte, gegen RK 4.6. Ab 14 Personen reden Lejla und Joanna im Grüppchen und wissen nicht, dass ihr Satz zählt.
Folgen: Lauf (a) Ollis Karte zwei Runden zu; Lauf (c2) 8 statt 9 Punkte.

**Vorschlag (wörtlich):**
- R-13: „‚Vor allen‘ heißt: Der ganze Tisch hört zu. So ist es am Verhörstuhl, bei der Gegenüberstellung, beim Ortstermin, bei den Antworten auf einen Impuls des Erzählers, beim Vorlesen einer umgedrehten Karte und nach dem Ruf des Erzählers ‚Alle mal herhören!‘. Wer im Grüppchen einen solchen Satz sagen will, ruft den Erzähler und sagt ihn dann vor allen.“
- R-03, Sätze 4 und 5: „Bevor du umdrehst, rufst du laut ‚Karte!‘. Alle Gespräche ruhen, bis du vorgelesen hast und die genannte Person geantwortet hat.“ („Ab 12 Personen“ entfällt; MECH 9.13 Zeile 12 entsprechend kürzen.)
- R-06, Satz 2: „Nennt eine offene Indizkarte, ein offener Streifen, eine offene Geheimniskarte oder eine vor allen vorgelesene Notiz aus einem Heft für dich ausdrücklich einen anderen Ort, oder verlangt es ein Auslöser in deinem Heft, stellst du deinen Marker sofort vor allen um.“
- Kurzform „So spielt ihr“, die beiden betroffenen Sätze: „Bevor du umdrehst, rufst du laut ‚Karte!‘.“ und „‚Vor allen‘ heißt: Der ganze Tisch hört zu, etwa am Verhörstuhl, beim Ortstermin, bei einem Impuls, beim Vorlesen einer Karte oder nach ‚Alle mal herhören!‘.“ Gleich in MECH 0.2 (Zeile „Vor allen“) und RK 6.6 („Gut zu wissen“).
- RK 4.7 und MECH 4.2, Olli (a): „(a) Sobald [Joanna] vor allen aus ihrer Notiz von 23:57 Uhr vorliest, dass du am Eiskübel standst.“ Die Variante ohne Joanna bleibt.
- ZG 1.7 Runde 1 Ziel 1 (Lejla → Olli) und ZG 4.8 Runde 1 Ziel 1 (Joanna → Olli), Zusatz im Heft: „Stell diese Frage vor allen. Ruf dafür den Erzähler.“

### P2-17 · mittel · FN3 in Runde 2 widerlegt Ollis Stufe 2 vor Runde 3; Olli hat dafür keinen Satz

**Fundstelle:** MECH 3.3 FN3 (Z. 1561–1562); MECH 1.5 Zeile 22:00 (Z. 1289); RK 7.5 „Wenn es eng wird (Runde 3)“, Satz 3
(Z. 6455, 6458); Überschriften RK 7.3, 7.4, 7.6 (Z. 6361, 6406, 6508); RK 7.1 (Z. 6297); MECH 3.5 Nr. 2 (Z. 1655–1657).

**Problem:** FN3 ist ab Runde 2 frei und wird gezielt angesteuert (Taschenkontrolle beim Detektiv oder bei Marek, Tugbas
Ziel R2-1, die Reihe „[Name]: Taschen und Kleidung“). Die Karte zeigt „frische rote Kerzenwachstropfen“ auf Ollis Handschuh.
„Was alle wissen“ sagt: Die roten Kerzen im Messingkerzenständer sind die einzigen echten Kerzen; der Kerzenständer lag nach
dem Scheppern vor der Vorratsraumtür. Damit ist „am Eiskübel geduckt, gut vier Meter weg“ in Runde 2 widerlegt, und Frage 1
der Tipp-Runde steht vor Runde 3 fest – in allen vier Läufen, sobald FN3 in Runde 2 gezogen wird. MECH 3.5 Nr. 2 („Ende
Runde 2 stehen Olli und Can gegenüber“) beschreibt das nicht. Ollis einzige Antwort („Die roten Tropfen? Keine Ahnung.“)
steht unter „Wenn es eng wird (Runde 3)“; in Runde 2 hat er keinen erlaubten Satz (R-01: Lügen nur, soweit das Heft es
erlaubt). Dasselbe Etikett tragen Ahmet, Fatma und Can, obwohl ihre Fälle früher eintreten (Can: gelbe Fasern ab Runde 1).
Grenze für jede Abhilfe: Eine Ausrede, in der Olli den Kerzenständer berührt (nach dem Licht oder um elf), darf es nicht
geben. Sie erklärte auch Holzsplitter und Kalk im Wachs am Fuß und entwertete XD3.

**Vorschlag (wörtlich):**
- FN3, „Was du findest“: „Auf dem Handrücken: rote Kerzenwachstropfen.“ statt „frische rote Kerzenwachstropfen“; zweiter Vermerk: „Hinweis: Auf dem Handrücken rote Kerzenwachstropfen. An beiden Bündchen von Ollis Pulli Kalkstaub und feine Holzsplitter.“ (A:41 und A:107 verlangen „rote“, nicht „frische“; Teil 90 behält „frische“.)
- RK 7.3 bis 7.6, Überschrift für alle vier (E9): „**Wenn es eng wird** (gilt, sobald der Fall eintritt), **wörtlich**:“. RK 7.1 Satz 3: „die Sätze für die Zeit nach dem Umdrehen und Stufe 3“.
- RK 7.5, dritter Satz von „Wenn es eng wird“: „– Sobald die Indizkarte ‚Olli: Taschen und Kleidung‘ (FN3) oder der Kerzenständer (XD3) offen liegt: ‚Kalk und Wachs hab ich von der Bogentür, das hab ich doch zugegeben. Die roten Tropfen? Keine Ahnung. An den Kerzen hat das Gespenst mit Herrn Schneider gerungen, nicht ich.‘“ (Ablenkung ohne eigene Berührung; kein Name, W-25; widerlegt durch JT3 ohne Wachs, die drei Zeugen in Runde 3 und XD3 mit den Bündchen. Länge: „Wenn es eng wird“ RN7 dann 143 Wörter, innerhalb zehn Prozent, RK 7.7 neu zählen.)
- MECH 3.5 Nr. 2, neuer letzter Satz: „Liegt FN3 schon in Runde 2 offen, ist Olli ab dann der Hauptverdächtige. Überführt ist er erst mit XD3 und PP9, und Cans Alibi kommt erst in Runde 3.“
- Nicht empfohlen: FN3 allein in Runde 3 (Teil 01 zeigte dann „Olli: Taschen und Kleidung · ab Runde 3“ neben Fatma und Can „ab Runde 2“, E9) oder alle drei Personen-Karten in Runde 3 (die Taschenkontrolle in Runde 2 läse dann Heft-Texte vor, die bei Fatma und Can das Geheimnis nennen, bei Olli die Tropfen nicht).

### P2-18 · mittel · „Kein Schlüsselbund“ direkt nach dem Eiskübel liest sich wie „Eiskübel geprüft“

**Fundstelle:** MECH 3.3 DM3 (Z. 1547), WJ9 (Z. 1607), FX3 (Z. 1565); MECH 3.1 Nr. 5 (Z. 1488); RK 6.7 Nr. 6 (Z. 6236).

**Problem:** Drei Runde-1-Karten nennen den Eiskübel und enden mit „Kein Schlüsselbund.“ FX3 sagt sogar, man sehe von der
Tür „Theke, Eiskübel, beide Buffettische“. Detektiv und Tipp-Runde können daraus schließen, der Eiskübel sei schon geprüft –
das ist genau das Versteck. Im Lauf (a) wird FX3 nach PP9 gezogen und klingt dann wie ein Widerspruch zum Fundort. MECH 3.1
Nr. 5 verlangt, dass falsche Suche nie Falsches aufdeckt; hier entsteht ein falscher Schluss aus dem Wortlaut.

**Vorschlag (wörtlich):**
- DM3: „Auf dem rechten Buffettisch stehen die Warmhaltebehälter, sauber zugedeckt. Bis zum Eiskübel vor dem Ostende der Theke sind es gut 3 m. Am rechten Buffettisch liegt kein Schlüsselbund.“
- WJ9: „Hinter dem Ostende der Theke steht die Anrichte Ost mit Saftkrügen, Gläsern, Tassen und Servietten. Von hier bis zur Vorratsraumtür sind es gut 3 m, bis zum Eiskübel 2 m. Hinter der Theke am Ostende liegt kein Schlüsselbund.“
- FX3: „Die Holztür zwischen Ost-Saal und Buffetsaal steht offen. Aus der Tür sieht man bei Licht den ganzen Buffetsaal: Theke, Eiskübel, beide Buffettische und die Theken-Klappe. Den Durchgang sieht man nicht. Auf der langen Tafel liegt ein umgestoßener Handyhalter neben dem Handykorb. In der Tür und am Handykorb liegt kein Schlüsselbund.“
- RK 6.7 Nr. 6: „Steht auf der Karte, dass an diesem Platz kein Schlüsselbund liegt, kreuz in deiner Liste ‚Kein Bund‘ an. Das gilt nur für diesen Platz, nicht für Orte, die die Karte nur als Entfernung nennt.“
- MECH 3.1 Nr. 5, erster Satz: „Jede Ortskarte sagt, ob an genau diesem Platz der Schlüsselbund liegt. Nennt sie einen anderen Ort, dann nur als Entfernung.“

### P2-19 · klein · Und-Bedingungen ohne Reihenfolge (Can c, Ahmet c)

**Fundstelle:** RK 5.7 (c) (Z. 3208), MECH 4.2 Can (Z. 1709) und Hinweis (Z. 1711–1712), MECH 3.4 JA9 (Z. 1636); RK 2.7 (c)
(Z. 2711), MECH 4.2 Ahmet (Z. 1706).

**Problem:** „Sobald JA9 offen liegt und jemand vor allen sagt, er habe gesehen, wie das leuchtende Gesicht aus dem Vorratsraum kam“: Kommt JA9 erst nach Ollis Domino (Lauf a: JA9 in R1 d,
Ollis Karte in R1 b; Lauf b: Krankenbesuch nach Ollis Karte), ist offen, ob der frühere Satz zählt. MECH 4.2 („Liegt JA9
offen, erfüllt er beim Vorlesen Cans Auslöser (c)“) legt nahe: nur in dieser Reihenfolge. Can hat Grund zu streiten, der Erzähler kann nicht
entscheiden. Gleiches bei Ahmet (c), wenn die Taschenkontrolle vor WE3 kommt.

**Vorschlag (wörtlich):**
- Can (c): „(c) Sobald Herrn Schneiders rechte Hand (JA9) offen liegt und jemand vor allen gesagt hat oder eine offene Karte sagt, dass das leuchtende Gesicht aus dem Vorratsraum kam. Was davon zuerst da war, ist egal.“
- Ahmet (c): „(c) Sobald eine Taschenkontrolle bei dir das Bündel Scheine gezeigt hat und der Jackenständer im Ost-Saal (WE3) offen liegt. Was davon zuerst da war, ist egal.“
- MECH 4.2, Hinweis zu Cans (c), neuer erster Satz: „Ollis offene Geheimniskarte erfüllt den zweiten Teil von Cans Auslöser (c), egal ob JA9 vorher oder nachher offen liegt.“

### P2-20 · klein · Domino-Frage ohne erlaubte Antwort

**Fundstelle:** MECH 9.9 Domino-Frage (Z. 2227); RK 4.7 „Ab dann“ (Z. 3048) und RK 4.5 Nr. 1 (Z. 2994) gegen Tims Domino
(ZG 3.6, Z. 3868); RK 3.6 Stufe 1 (Z. 2847–2854) gegen Cans Domino (RK 5.8, Z. 3230).

**Problem:** Nach dem Umdrehen fragt der Erzähler die genannte Person: „Bitte, sag uns sofort, ob das stimmt.“ Tims Karte
nennt Olli und das Möbelwachs; Ollis Heft verbietet ihm, die Herkunft des Wachses zu sagen. Cans Karte nennt Fatma beim
Tuscheln; Fatmas Heft gibt das Tuscheln erst „nach der Karte“ frei und hat keinen Satz dafür. Beide müssen gegen ihr Heft
handeln oder ohne Vorlage lügen. Dasselbe droht bei jeder Karte, deren genannte Person noch zurückhalten darf.

**Vorschlag (wörtlich, MECH 9.9):** „Die Karte nennt am Ende jemanden. Bitte, sag uns sofort, ob das stimmt. Wenn dein Heft es dir noch nicht erlaubt, sag: ‚Dazu sag ich jetzt nichts.‘“ (E9 bleibt unberührt, kein Heft wird länger.)

### P2-21 · klein · Zeitstempel: Herr Schneider als Zeuge und 23:51 Uhr ungeregelt; Olli ohne Satz zur Bogentür

**Fundstelle:** MECH 4.4 Zeitstempel (Z. 1779), ZG 4.9 (Z. 4091–4092), R-10 (Z. 1263); Stufe-1-Tabellen RK 2.6, 3.6, 4.6,
5.6; Ziele, die Olli nach 23:50 fragen: RK 5.9 R1-1 Nachschlag (Z. 3239), ZG 6.7 R1-2 (Z. 4443), ZR 3.8 R1-1.

**Problem:** Der Zeitstempel verlangt, dass die Person jemanden nennt, der sie sah, und dass die genannte Person bestätigt.
Ahmet stand um 23:51 bei Herrn Schneider. Nennt er ihn, müsste der Erzähler für Herrn Schneider sprechen, was R-10 nur bei
JA9, PM3 und Krankenbesuch erlaubt. Für 23:51 haben die vier keinen Satz (RK 1.8 deckt nur 23:57). Bei 6 bis 9 Personen
öffnet ein ehrlicher Ahmet („die Fotografin des Abends“) Joannas Streifen und damit Ollis (a) – ein starker Stein, den kein
Heft vorsieht. Olli hat auch keinen Satz, wenn Can, Zeynep oder Hana ihn in Runde 1 nach zehn vor zwölf an der Bogentür fragen.

**Vorschlag (wörtlich):**
- Zeitstempel, Grenzen (28 Wörter): „Nennt sie jemanden, der heute fehlt, dreht der Erzähler dessen Streifen um, auch wenn sie ihn nur umschreibt. Der Streifen gilt als Antwort. Herr Schneider zählt als niemand.“
- Neue Zeile in den Stufe-1-Tabellen aller vier (E9; RK 1.1 und 1.3 „sieben Ausweichsätze“, Wortbudget Stufe 1 um 15 erhöhen, RK 7.7 neu zählen), Frage „Wo warst du um 23:51 Uhr?“:
  - Ahmet: „Vor der Theke. Ich hab kurz mit Herrn Schneider geredet.“ (wahr)
  - Fatma: „Am linken Buffet beim Gebäck. [Emine] war bei mir.“ (wahr)
  - Olli: „An der Bogentür im Kaminsaal, bei [Tim]. Er hat sich den Finger eingeklemmt. Ich hab gesagt, ich hol ihm Eis.“ (wahr; beantwortet auch die Fragen nach zehn vor zwölf)
  - Can: „Im Kaminsaal an der langen Tafel. [Zeynep] saß bei mir.“ (wahr)

### P2-22 · klein · Spalte „Worauf du hinauswillst“: Druck nicht festgelegt

**Fundstelle:** ZG 1.7 bis 6.7 (etwa Z. 3507–3514), ZR 1.8 bis 8.8; ZG 0.6 Seite 3 (Z. 3361), ZR 0.7 Seite 2 (Z. 4707).

**Problem:** Die Ziel-Tabellen der Zeugen und Zusatzrollen haben die Spalte „Worauf du hinauswillst“ mit Einträgen wie
„Ollis Pflicht-Auslöser (b), sein Marker fällt“ (Lejla) oder „Ollis Pflicht-Auslöser (a)“ (Joanna). ZG 0.6 und ZR 0.7 sagen
nicht, ob sie gedruckt wird. Gedruckt verrät sie fremde Auslöser (E8: Bedingungen nur im eigenen Heft).

**Vorschlag (wörtlich, ZG 0.6 Seite 3 und ZR 0.7 Seite 2):** „Die Spalte ‚Worauf du hinauswillst‘ ist Arbeitshilfe und wird nicht gedruckt.“ Den nötigen Hinweis für Lejla und Joanna trägt der Zusatz aus P2-16.

### P2-23 · klein · Joanna darf ihr Heft zeigen

**Fundstelle:** ZG 4.5 (Z. 4022–4023); R-11 (Z. 1264); ZG 0.6 Seite 2 und 3.

**Problem:** „Du darfst ihn auch zeigen.“ heißt: Joanna hält ihr Heft hin. Auf denselben Seiten stehen „Das behältst du für
dich“, ihre Sobald-Sätze und ihre Karte. R-11 verbietet, fremde Hefte zu lesen.

**Vorschlag (wörtlich):** „Diesen Kasten liest du vor, wenn jemand fragt, wer um drei vor zwölf wo war. Lies ihn ganz vor, Zeile für Zeile. Dein Heft gibst du nicht aus der Hand.“

### P2-24 · klein · Der Bogen sagt nicht, wohin „für das leuchtende Gesicht“ gehört

**Fundstelle:** RK 6.9 (Z. 6261); MECH 2.2 (Z. 1425); MECH 12a A:106 (Z. 6728).

**Problem:** Tims und Mareks Vermerke lauten „Alibi beim Scheppern · für das leuchtende Gesicht“. Der Bogen hat dafür keine
Spalte; Teil 01 erklärt nicht, dass der Eintrag in die Spalte der Person gehört, die das Gesicht war. Bei 6 bis 11 Personen
ist Zeyneps Karte (die „Can“ nennt) oft noch zu; dann hängt M3 an diesem Schritt. A:106 verlangt, dass Mareks und Tims
Beobachtung das Kreuz „Can – Alibi“ liefert.

**Vorschlag (wörtlich, RK 6.9 nach dem Satz „Ein ✓ bei ‚Alibi‘ braucht eine Quelle, die nicht die Person selbst ist.“):** „Ein Vermerk ‚für das leuchtende Gesicht‘ gehört in die Spalte der Person, die das Gesicht war. Wer das war, zeigt dir eine offene Karte.“

### P2-25 · klein · RN7: „Nur einen Satz in Stufe 2 erfindest du“ – es sind zwei Verdrehungen

**Fundstelle:** RK 7.5 „Dein Heft und die Wahrheit“ (Z. 6453) gegen RK 7.5 „Was nur du weißt“ Nr. 2 und RK 4.7 „Was du
dann sagst“ (Z. 3041).

**Problem:** Ollis Stufe 2 enthält „Beim Knall hab ich mich am Eiskübel geduckt.“ und „Dann ist das leuchtende Gespenst aus dem Vorratsraum auf Herrn Schneider los.“ „Was nur du weißt“
Nr. 2 nennt beides als verdreht. „Nur einen Satz in Stufe 2 erfindest du“ widerspricht dem; Olli könnte den Gespenst-Satz für wahr halten und ihn
unter Druck falsch verteidigen oder vorschnell aufgeben. Das schwächt die Steuerung der Stufe 2 genau in Runde 3.

**Vorschlag (wörtlich, 31 Wörter, innerhalb zehn Prozent von 29, RK 7.7):** „Dein Heft sagt dir fast alles. In Stufe 2 erfindest du zwei Dinge: dass du dich geduckt hast und dass das Gesicht auf Herrn Schneider losging. Bleib dabei bis zur Anklage.“

### P2-26 · klein · Rest von P2-14: Joannas Wissen nennt 23:56 für Ahmets Weg hinter die Theke

**Fundstelle:** ZG 4.4, Zeile „23:56“ (Z. 3993); WELT 0.2 (Z. 130–131); ZG 0.6 (Wissen-Tabellen werden gedruckt).

**Problem:** Die gedruckte Tabelle sagt in einer Zeile mit der Zeit 23:56: „Olli geht an ihr vorbei aus dem Ost-Saal zum Eiskübel. Kurz
darauf geht Ahmet an ihr vorbei und schlüpft am Ostende hinter die Theke.“ Fatmas Domino, Lejlas Karte und WELT 0.2 sagen 23:57. Am Tisch klingt
das wie ein Widerspruch zwischen Joanna und Fatma, genau der Fall aus P2-14.

**Vorschlag (wörtlich, zwei Zeilen statt einer):** „23:56 | Olli geht an ihr vorbei aus dem Ost-Saal zum Eiskübel.“ und „23:57 | Ahmet geht an ihr vorbei und schlüpft am Ostende hinter die Theke.“

---

## 5. Was hält (bestätigt)

- Ring der Verdächtigen: Ahmets Domino dreht Olli, Ollis Domino mit JA9 dreht Can, Cans Domino drückt auf Fatma, Fatmas auf
  Ahmet. Bei 6 Personen trägt Ahmets Domino Olli auch ohne Ortstermin (großzügige Lesart).
- Die Zeugen-Dominos nach P2-06 erzeugen neuen Druck: Lejla → Olli (Eiskübel nach dem Licht), Joanna → Can, Marek und Zeynep →
  Tim, Tim → Olli. Keiner zielt auf eine schon offene Karte.
- Ollis Stufe 2 fällt nie formal vor Runde 3 und fällt in Runde 3 sicher: drei unabhängige Quellen mit Sperre 3, FK3, Hanas
  Geruch ab 15 Personen. Ollis eigener Satz „das Gespenst“ löst in Runde 3 die Auslöser von Tim, Marek und Zeynep aus.
- Die Überführungsregel 2.4 schützt die Unschuldigen: Fatmas „Splitter am Ärmel“ sind Glas und ihr Ort 23:57 ist die Klappe,
  nicht der Eiskübel; Ahmet fehlt Teil 2; Cans Bauchtasche trägt kein Wachs.
- Jede falsche Fährte hat einen Gegenbeleg: gelbe Fasern (M3), Fatma an der Klappe (Emine), Ahmet am Ostende (Marek, Damir).
- Die Tipp-Runde liegt vor XD3 und PP9 (P2-03 hält). Frage 2 bleibt eine Schlussfolgerung aus Ort 23:57, Ollis eigener Stufe 2,
  Lejlas „als Erstes zum Eiskübel“ und Joannas Satz in Runde 3 – sofern P2-18 behoben ist.
- E7 hält: Kein Streifen ist offen; bei 6 Personen bringt Runde 1 höchstens Ollis Stufe 2, zwei Alibis und Hinweise.
- ZG-15 hält: Keine Zusatzrolle erfüllt einen Pflicht-Auslöser der vier; ihr Wissen bestätigt nur.
- Rundensperren und Codes gelten für gespielte und fehlende Zeugen gleich (M-17); Gesprächs-Auslöser umgehen keine Sperre.

## 6. Gesamturteil

Befunde: 0 Blocker, 3 mittel (P2-16 bis P2-18), 8 klein (P2-19 bis P2-26). Alle Befunde der Runde 1 sind behoben. Die Ketten
tragen in allen vier Besetzungen; kein Zirkel, keine Sackgasse, formal kein Lösen vor Runde 3. Verlässlicher wird der
Domino-Lauf, wenn „vor allen“ alles umfasst, was der ganze Tisch hört (P2-16), und Olli für FN3 in Runde 2 einen Satz hat, der
XD3 nicht entwertet (P2-17). P2-18 verhindert, dass der Wortlaut der Ortskarten vom Versteck weglenkt.
