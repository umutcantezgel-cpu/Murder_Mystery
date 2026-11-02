# Protokoll 2 – Domino-Ketten-Simulation (Prüfrunde 1)

Stand 2026-11-01. Geprüft: `bibel/01-welt.md` (WELT), `02-mechanik.md` (MECH), `03-rollen-kern.md` (RK),
`04-rollen-zeugen.md` (ZG), `05-rollen-zusatz.md` (ZR). Grundlage: `AUFTRAG.md` (A), `ENTSCHEIDUNGEN.md` (E).
Repo nur gelesen. Haltung: gegnerisch. Gesucht wurde nach Sackgassen, Zirkeln, vorzeitiger Lösung, nicht
entlastbaren Unschuldigen, Beweisen, die nicht auf Olli zeigen, und einer Stufe 2, die zu schwach oder unwiderlegbar ist.

**Ergebnis in einem Satz:** Die Ketten tragen in allen vier Besetzungen ohne Sackgasse und ohne Zirkel, und alle Beweise
zeigen auf Olli; aber der Detektivbogen (Teil 01) und der Vermerk auf FN3 verraten den Schlüsselbeweis vor Runde 3. Damit
ist das Prüfziel „kein vorzeitiges Lösen“ in jeder Besetzung verfehlt (zwei Blocker).

---

## 1. Auslöser-Graph

### 1.1 Indizkarten (19), Runde und was sie auslösen

| Code | ab | Art | löst Pflicht aus (Karte) | öffnet Streifen | füllt Feld |
|---|---|---|---|---|---|
| RH3 | 1 | Ortstermin linkes Buffet | – | Emine | M2 (über Emine) |
| DM3 | 1 | Ortstermin rechtes Buffet | Olli (b) | Lejla | Olli Alibi ✗ |
| WJ9 | 1 | Ortstermin Ostende | – | Marek | M1 |
| FX3 | 1 | Ortstermin Tür Ost-Saal | Olli (a); Fatma-Marker → 4a | Joanna | Ort 23:57 alle vier |
| AD3 | 1 | Ortstermin Durchgang | – | Tim, Zeynep | Hinweise |
| WE3 | 1 | Jackenständer | Lejla, Joanna (R2), Aylin (R2); Ahmet (c) nur mit Taschen-Check | – | Hinweis M4 |
| JA9 | 1 | Schneiders Hand | Can (c) zusammen mit „Gesicht aus dem Vorratsraum“ | – | Hinweis Kapuze |
| FM9 | 1 | Vitrine | Fatma (b) mit Marker 4a; Emine (R2); Sibel; Azra | – | Hinweis M5 |
| YT4 | 1 | Bogentür, Rüstung | Sibel, Damir | – | Hinweis M7 |
| PM3 | 2 | Klemmbrett | Ahmet (a); Lejla, Joanna (R2); Aylin | – | M4 |
| WM9 | 2 | Ascheneimer | Ahmet (a); Lejla, Joanna (R2) | – | M4 |
| MR4 | 2 | Kaffeemaschine, Werkzeugkasten | Tim (R3); Wojtek | – | Hinweise |
| VP7 | 2 | Kamin-Nische | Hana | – | Hinweis |
| NN3 | 2 | Fatmas Tasche | Fatma (a); Emine (R2); Azra | – | M5 |
| JT3 | 2 | Cans Bauchtasche | Can (a); Marek, Zeynep (R3) | – | M6 |
| FN3 | 2 | Ollis Weste und Pulli | – | – | M7 (mit YT4), M9 Teil 2 |
| XD3 | 3 | Kerzenständer | Marek (R3) | – | M9 Teil 1 |
| PP9 | 3 | Eiskübel | – | – | M8 |
| FK3 | 3 | Ortstermin Steinbogen | Zeynep, Tim (R3) | Zeynep | M3, M6 |

Zusatzwege ohne Untersuchung: Taschen-Check (ab R2; Olli → FN3, Can → JT3, Fatma → NN3), Stirnlampe (ab R2, vierte
Untersuchung), Zeitstempel (ab R1, öffnet den Streifen einer genannten fehlenden Person).

### 1.2 Geheimniskarten: Sperre, Auslöser, Domino-Ziel

„GK n“ = Geheimniskarte von Platz n. „(gesp.)“ = Auslöser gilt nur, wenn die Rolle gespielt wird.

| GK | Sperre | Auslöser über Codes | Auslöser über Karten, Wort, Gespräch | Domino-Hinweis trifft |
|---|---|---|---|---|
| 1 Ahmet | – | PM3, WM9; WE3 + Taschen-Check | GK 5 | Olli (Pflicht c) |
| 2 Fatma | – | NN3; FM9 + Marker 4a | GK 6 | Ahmet (Druck) |
| 3 Olli | – | FX3 (Streifen Joanna), DM3 (Streifen Lejla) | Joanna trägt Notiz vor; Lejla sagt es; Ahmet oder Fatma sagen „Eiskübel 23:57“ | Can (Pflicht c mit JA9) |
| 4 Can | – | JT3; JA9 + Satz „Gesicht aus dem Vorratsraum“ | GK 10 | Fatma, Emine (Druck) |
| 5 Lejla | R2 | WE3, PM3, WM9 | GK 1, GK 8 (gesp.) | Ahmet |
| 6 Emine | R2 | FM9, NN3 | GK 2 (gesp.) | niemand Bestimmtes |
| 7 Tim | R3 | MR4, FK3 | GK 10, Frage in R3, „das Gespenst war es“ (gesp.) | Olli |
| 8 Joanna | R2 | WE3, PM3, WM9 | GK 1, GK 5 (gesp.) | Ahmet |
| 9 Marek | R3 | XD3, JT3 | GK 4, Frage in R3, „das Gespenst war es“ (gesp.) | Ahmet |
| 10 Zeynep | R3 | FK3, JT3 | GK 4, Frage in R3, „Can oder das Gespenst“ (gesp.) | Tim (Pflicht 4, gesp.) |
| 11 Sibel | – | FM9, YT4 | GK 12, Vitrinen-Vorwurf | Damir |
| 12 Damir | – | YT4 | GK 11, Vitrinen-Vorwurf | Ahmet |
| 13 Hana | – | VP7 | GK 14, zweimal Papier | Serkan |
| 14 Serkan | – | – | zweimal Außentor gefragt, GK 13 | Hana |
| 15 Azra | – | FM9, NN3 | GK 2 | Wojtek |
| 16 Wojtek | R2 | MR4 | GK 15, GK 7 | Tim, Olli |
| 17 Aylin | R2 | PM3, WE3 | GK 1, Taschen-Check | Bogentür (Olli) |
| 18 Tugba | – | – | jederzeit; GK 17, Taschen-Check | Aylin |

### 1.3 Offenes Wissen, das eine Kette startet (Stufe 1, sofort frei)

| Quelle | Satz (Kern) | Kante |
|---|---|---|
| Lejla S1 / Streifen (DM3, Zeitstempel) | „Erst nach dem Scheppern kam Olli: ‚Lejla? Ich bin's, Olli.‘“ | → GK 3 (b); Olli Alibi ✗ |
| Joanna S1 / Streifen (FX3, Zeitstempel) | Notiz 23:57, „Zweitausend, bis zwölf“, Kopf der Tafel leer | → GK 3 (a); Fatma-Marker 4a |
| Emine S1 / Streifen (RH3, Zeitstempel) | Fatma kauerte beim Scheppern neben ihr | → M2 |
| Marek S1 / Streifen (WJ9, Zeitstempel) | Ahmet kauerte an seinen Beinen | → M1 |
| Damir S1 (ab 14) | Ahmet flüsterte neben ihm | → M1 |
| Fatma nach Marker 4a | „Von der Klappe sah ich Olli am Eiskübel.“ | → GK 3 (c) |
| Tugba S1 (20) | linker Handschuh 19:30 in der Nische, rechter in der Westentasche | Druck → FN3 |

### 1.4 Kanten zu den Feldern des Bogens

| Feld | erreichbar über | frühestens |
|---|---|---|
| M1 Ahmet Alibi | Marek S1 oder Streifen, Damir | R1 |
| M2 Fatma Alibi | Emine S1 oder Streifen | R1 |
| M3 Can Alibi | GK 7, GK 9, GK 10, FK3; Verbindung „Gesicht = Can“ über GK 4 oder JT3 | R3 |
| M4 Ahmet HT | PM3, WM9, GK 1, GK 5, GK 17, Azra | R2 praktisch (GK 1 freiwillig R1) |
| M5 Fatma HT | NN3, GK 2, GK 6 | R1 (FM9 + Marker) |
| M6 Can HT | JT3, GK 4, GK 10 | R1 (JA9 + Ollis Domino) |
| M7 Olli HT | GK 3, YT4 + FN3, GK 7, GK 16 | R1 |
| M8 Fundort | PP9 | R3 |
| M9 Schlüsselbeweis | XD3 + FN3 | R3 (laut Bogen); lesbar ab R0/R1, siehe P2-01, P2-02 |
| Ort 23:57 Olli | Joanna, GK 3, Ahmet- und Fatma-Aussage | R1 |

### 1.5 Zirkel-Prüfung

Starke Zusammenhangskomponenten der Karten-Kanten (Karte → Karte):

| Komponente | Ausweg über einen Code | Urteil |
|---|---|---|
| GK 1 ↔ GK 5 ↔ GK 8 | PM3, WM9, WE3 | kein Zirkel |
| GK 2 ↔ GK 6 | NN3, FM9 | kein Zirkel |
| GK 4 ↔ GK 10 | JT3, FK3, JA9 + Ollis Domino | kein Zirkel |
| GK 10 → GK 7 (einseitig) | MR4, FK3 | kein Zirkel |
| GK 11 ↔ GK 12 | YT4, FM9 | kein Zirkel |
| GK 13 ↔ GK 14 | VP7, zweite Frage | kein Zirkel |
| GK 15 → GK 16 | FM9, NN3; MR4 | kein Zirkel |
| GK 17 ↔ GK 18 | PM3, WE3; Tugba jederzeit | kein Zirkel |

Jede Karte hat mindestens einen Auslöser, der an einer Indizkarte hängt. Keine Pflicht verlangt eine Karte, die erst
durch sich selbst frei würde. **Bestanden.**

### 1.6 Sackgassen-Prüfung (jedes Feld, jede Personenzahl)

Für P = 6, 7, 8, 9, 10, 11, 12, 13–20 nachgerechnet gegen MECH §6.3 und die Etiketten in ZG. Jedes Feld hat in jeder
Besetzung einen Weg nur über Indizkarten oder Streifen, also unabhängig vom Mut des Tisches. Engster Fall: 6 Personen,
M3 nur über die drei Karten unter den Streifen (MR4/FK3, XD3/JT3, FK3/JT3, alle ab R3). XD3 muss für M9 ohnehin gezogen
werden und öffnet Mareks Karte; damit gibt es für M3 nie eine Sackgasse. **Bestanden.**

Budget 6 Personen: R1 drei Karten plus Zeitstempel, R2 drei plus Stirnlampe plus Taschen-Check, R3 drei. Der kürzeste
Weg zu 9 Punkten braucht neun Untersuchungen und einen Taschen-Check (2.3 unten). Kein Spielraum für mehr als einen
Fehlgriff, aber kein Bruch.

---

## 2. Simulationen

Schreibweise: „→ GK n“ = Karte wird umgedreht. „[Leck]“ = an dieser Stelle ist die Lösung lesbar, obwohl sie es nach
MECH §3.5 nicht sein dürfte.

### 2.1 (a) 10 Personen, zurückhaltender Tisch

Besetzung: Rollen 1–8, Detektiv, Erzähler. Streifen und Karten unter Streifen: Marek (4d), Zeynep (6). Beim Detektiv:
Taschen-Check, Gelbe Karte. Annahme „zurückhaltend“: Niemand macht freiwillig reinen Tisch, Zeugen sagen nur, was
gefragt wird, Nachbohr-Ziele werden knapp abgearbeitet, der Detektiv folgt seinem Aufgabenkasten (RK §6.5).

**Vor Runde 1 (Teil 01 liegt beim Detektiv, MECH §10.3 sogar vorab gesendet).** Bogen-Zeile „Teil 2, Handschuh und
Ärmel“, Regel 2.4 Nr. 1 „Wer den Kerzenständer am Fuß hielt, hatte Holzsplitter und weißen Kalk am Ärmel“,
Untersuchungsliste „Ollis Weste und Pulli“. **[Leck P2-01]** Nur Olli trägt einen Handschuh als Merkmal.

**Runde 1**
| Schritt | Ereignis | Folge |
|---|---|---|
| b, Verhörstuhl | A1–A3 an die vier. Olli: Ost-Saal. Can: Turm-Toilette. Fatma: linkes Buffet. Ahmet: Ostende, „Servietten“ | Ort-Zeile vorläufig |
| b, Verhörstuhl Ziel 2 | „Wer war im Dunkeln neben dir?“ an alle mit Marker im Buffetsaal: Lejla: „Beim Scheppern war ich allein. Erst danach ist Olli zu mir gekrochen.“ | **→ GK 3 (b)**: M7, Ort Olli = Eiskübel; Marker 4b/4b; mündlich „geduckt“, „Gespenst auf Herrn Schneider los“; Domino „Gesicht aus dem Vorratsraum“. **[Leck P2-01]**: Karte nennt „gekalkte Wand“, Bogen nennt Kalk am Ärmel |
| b | Emine: Fatma neben ihr beim Scheppern | M2 (Quelle Emine) |
| b | Ahmet: „an den Beinen des Caterers“ | M1 zählt nach MECH §6.1 schon jetzt, ohne Beleg (P2-05) |
| b | Joanna wird nicht gefragt (Marker im Ost-Saal, kein Aufgabenpunkt) | Fatma-Marker bleibt auf 2 |
| c | niemand dreht freiwillig | – |
| d | WJ9 (Streifen Marek: M1 belegt), JA9 (gelbe Fasern; Ollis Domino liegt offen → **GK 4 (c)**: M6, Can 23:57 → 5; Domino Fatma/Emine), YT4 (Bogentür, Kalk und Splitter) | Bogen: Ahmet Alibi ✓; Fatma Alibi ✓; Olli ✗, HT ✓; Can HT ✓ |
| Stand | Detektiv kann aus Regel 2.4 + YT4 + GK 3 schließen: Olli hielt den Kerzenständer. **Fall gelöst nach R1** (P2-01) | – |

**Runde 2**
| Schritt | Ereignis | Folge |
|---|---|---|
| a | keine Karte der Zeugen fällig (WE3, PM3, WM9, FM9, NN3 noch zu) | – |
| b | Ahmets Ziel 2 an Joanna: Notiz wird vorgelesen | Fatma-Marker → 4a; Fatma sagt „Olli am Eiskübel“ (GK 3 schon offen) |
| b | I-2.1 Geld: alle 150 €; Druck auf Ahmet. Taschen-Check des Detektivs bei Fatma | NN3 → **GK 2 (a)**: M5; **GK 6** (R2): Domino „nicht nur Fatma gedroht“ (trifft niemanden) |
| d | PM3 (**GK 1 (a)**: M4; **GK 5**, **GK 8** gleichzeitig; ihre Dominos treffen Ahmet, der schon offen ist, P2-06), FN3 (**[Leck P2-02]** „Schlüsselbeweis, Teil 2 … zeigt, wer den Kerzenständer hielt“ auf Ollis Weste), MR4 (Tim für R3 vorgemerkt) | Ahmet und Fatma ausgeschieden |

**Runde 3**
| Schritt | Ereignis | Folge |
|---|---|---|
| a | **GK 7** (MR4 aus R2): Gesicht am Sicherungskasten vorbei, danach Schneiders Ruf, dann Scheppern; Domino „Wachs für Olli“ | M3 (Gesicht) + Verbindung über GK 4 = Can; Ollis Stufe 2 erschüttert |
| b | Tims Ziel 1 an Olli („Eis kam erst nach dem Licht“), Lejla und Joanna lenken zum Eiskübel; Olli: „Kann sein. Im Dunkeln weiß doch keiner …“ | Gegenüberstellung trägt |
| d | XD3 (Teil 1; Streifen-Karte Marek: zweite Gestalt von der Klappe), PP9 (M8), FK3 (Streifen-Karte Zeynep: Can vor dem Scheppern) | 9 von 9 |
| e | Marker-Check: „Steht ein Marker, dem eine offene Karte widerspricht?“ Ollis Scheppern-Marker auf 4b gegen XD3 + FN3 | Streitfall (P2-04) |
| Tipp | Alle tippen Olli und Eiskübel; beides liegt seit Minuten offen | Tipp-Runde ohne Spannung (P2-03) |

Ergebnis (a): keine Sackgasse, kein Zirkel, alle drei entlastbar, alle Beweise auf Olli. Gelöst nach R1 (Leck).

### 2.2 (b) 10 Personen, forscher Tisch

Annahme „forsch“: alle spielen ihre Nachbohr-Ziele hart, Aktionskarten früh, freiwilliges Umdrehen für das Bonus-Ziel.

**Runde 1**
| Schritt | Ereignis | Folge |
|---|---|---|
| b, Minute 1–3 | Joanna, Ziel 1 an Olli, liest die Notiz | **→ GK 3 (a)**: M7, Ort Eiskübel; Fatma-Marker → 4a; Fatma darf „Olli am Eiskübel“ sagen. Olli spielt „Themenwechsel“ zu spät; Grenzen nennen den Pflicht-Auslöser nicht (P2-08) |
| b | Lejla, Ziel 1 an Olli | Pflicht (b) doppelt erfüllt |
| b | Can, Ziel 1 an Olli: „Um zehn vor zwölf an der Bogentür“ | Druck Richtung YT4 |
| b | Tim an Fatma: „Wer war an der Vitrine?“ | Druck Richtung FM9 |
| b | Joanna spielt Zeitstempel auf Ahmet, 23:57 | Ahmet nennt „den Caterer“; Erzähler muss „Caterer“ dem Etikett „Marek“ zuordnen (P2-09) → Streifen Marek: M1 |
| c | Fatma und Can drehen für ihr Bonus-Ziel freiwillig um | **GK 2**: M5; **GK 4**: M6, Can 23:57 → 5 |
| d | JA9, FM9, YT4 | Emine für R2 fällig; Hinweise |
| Stand | M1, M2, M5, M6, M7, Ort-Zeile voll. Ahmet fehlt nur M4. **Gelöst** über Regel 2.4 (P2-01) | – |

**Runde 2**
| Schritt | Ereignis | Folge |
|---|---|---|
| a | **GK 6** (FM9, GK 2) | Domino ohne Ziel |
| b | Ahmet dreht nach Fatmas Frage freiwillig nicht; Taschen-Check des Detektivs bei Olli | FN3 offen **[Leck P2-02]** |
| b | Olli, Ziel 1 an Can: „Ich hab das leuchtende Gesicht aus dem Vorratsraum springen sehen.“ Can (schon offen): „Er hat mich gepackt, nicht umgekehrt.“ | Olli gegen Can, Stufe 2 glaubwürdig |
| d | Tim spielt Stirnlampe: PM3 (**GK 1**: M4; **GK 5**, **GK 8**, Dominos auf Ahmet ins Leere), JT3 (Marek, Zeynep für R3 vorgemerkt), MR4 (Tim für R3), WM9 | Ahmet, Fatma ausgeschieden |

**Runde 3**
| Schritt | Ereignis | Folge |
|---|---|---|
| a | **GK 7**, **GK 9** (Streifen), **GK 10** (Streifen) gleichzeitig | M3 dreifach, zweite Gestalt; Ollis Stufe 2 widerlegt |
| b | Gegenüberstellung mit allen drei Aussagen auf dem Tisch | stark |
| d | XD3, PP9, FK3 | 9 von 9, überführt |
| Tipp | trivial (P2-03) | – |

Ergebnis (b): Kette läuft schnell und sauber. Olli fällt in R1 (gewollt). Ohne die Lecks stünden Olli und Can am Ende
von R2 gegenüber, wie MECH §3.5 Nr. 2 will. Mit den Lecks ist der Fall nach R1 entschieden.

### 2.3 (c) 6 Personen

Besetzung: Ahmet, Fatma, Olli, Can, Detektiv, Erzähler. Sechs Streifen mit sechs Karten darunter. Beim Detektiv sechs
Aktionskarten (Krankenbesuch, Kreuzverhör, Stirnlampe, Zeitstempel, Taschen-Check, Gelbe Karte).

**Variante c1 – guter Detektiv**
| Runde | Ereignis | Folge |
|---|---|---|
| R1 b | Ahmet und Fatma bitten mit ihren Ausweichzielen um WJ9 und RH3; Olli fragt Ahmet nach 23:55 (wahr: Kopf der Tafel), Can fragt Fatma | Ollis Stufe 1 wird gestützt (gut) |
| R1 b | Zeitstempel auf Fatma, 23:57: „Am Buffet, meine beste Freundin war bei mir.“ | Streifen Emine: M2 |
| R1 d | WJ9 (Streifen Marek: M1), DM3 (Streifen Lejla: Olli ✗ → **GK 3 (b)**: M7, Ort), FX3 (Streifen Joanna: Ort-Zeile; Fatma-Marker 4a) | **[Leck P2-01]** |
| R2 b | Taschen-Check bei Can | JT3 → **GK 4**: M6; Streifen-Karten Marek, Zeynep für R3 vorgemerkt |
| R2 d | Stirnlampe; PM3 (**GK 1**: M4; Streifen-Karten Lejla, Joanna), NN3 (**GK 2**: M5; Streifen-Karte Emine), FN3 **[Leck P2-02]**, MR4 | Ahmet, Fatma ausgeschieden |
| R3 a | Karten unter den Streifen Tim, Marek, Zeynep gehen auf | M3 dreifach; zweite Gestalt; Ollis Stufe 2 fällt am Rundenbeginn |
| R3 b | Can mit seinen R3-Zielen, Fatma bittet um XD3 | Gegenüberstellung mit vier Personen |
| R3 d | XD3, PP9, FK3 (überzählig) | 9 von 9 |

**Variante c2 – schwacher Detektiv, nutzt keine Aktionskarte**
| Runde | Ereignis | Folge |
|---|---|---|
| R1 d | WJ9, RH3, YT4 | M1, M2; Olli noch zu |
| R2 d | PM3 (**GK 1**: M4; Ahmets Domino „Olli am Eiskübel, Zweitausend“ → **GK 3 (c)**: M7, Ort), NN3 (M5), JA9 (mit Ollis Domino → **GK 4**: M6) | Kette läuft auch ohne Ortstermine an Olli |
| R3 d | XD3 (Streifen-Karte Marek: Gesicht vor dem Scheppern → M3 über GK 4), PP9, FN3 | 9 von 9 möglich |

Ergebnis (c): keine Sackgasse; das Abwesenheitsblatt löst nichts allein (E7 hält). Lecks P2-01 und P2-02 wie oben.

### 2.4 (d) 20 Personen

Alle 18 Rollen. Ab 14 Personen ruft der Erzähler nach der halben Gesprächszeit „Wechsel!“ (MECH §9.13), Gespräche laufen
in Grüppchen.

**Runde 1**
| Schritt | Ereignis | Folge |
|---|---|---|
| b | Damir (offen): Ahmet flüsterte neben ihm | M1 |
| b | Serkan → Lejla, Tugba → Joanna | **GK 3 (a)/(b)**: M7, Ort; Fatma-Marker 4a |
| b | Tugba (offen): linker Handschuh in der Kamin-Nische, rechter in der Westentasche | mit Bogen-Zeile „Teil 2, Handschuh und Ärmel“ **[Leck P2-01]** schon in Minute 5 |
| b | Sibel, Hana (offen): Gesicht huscht durch den Kaminsaal | stützt M6, kein Bezug zum Scheppern (gut, M-14 hält) |
| b | Damir → Emine | M2 |
| b | Serkan zweimal nach dem Außentor gefragt | **GK 14** → **GK 13** |
| b | Tugba spielt Handzeichen: „Hat jemand im Dunkeln das leuchtende Gesicht gesehen?“ | Tim, Marek, Zeynep haben in ihren Heften keine Enthaltung; sie müssten lügen oder vorzeitig etwas zeigen (P2-11) |
| d | WJ9, YT4 (**GK 11**, **GK 12**), JA9 (**GK 4**: M6) | – |

**Runde 2**
| Schritt | Ereignis | Folge |
|---|---|---|
| a | FM9 und NN3 noch zu: keine Zeugenkarte fällig. Hat Fatma in R1 freiwillig umgedreht, gehen **GK 6** und **GK 15** über GK 2 auf | – |
| b | Azra (ab R2 frei): Ahmet am Ascheneimer 0:12; Aylin: Zettel „Miete: 0 Euro“ | M4 |
| b | Marek spielt Taschen-Check bei Olli | FN3 **[Leck P2-02]** |
| b | Gespräche in Grüppchen. Lejla sagt Olli ihre Beobachtung nur in ihrer Runde, nicht „vor allen“ | ob Pflicht (b) gilt, ist offen (P2-10) |
| d | PM3 (**GK 1**, **GK 5**, **GK 8**, **GK 17**), MR4 (**GK 16**; Tim vorgemerkt), NN3 | Ahmet, Fatma ausgeschieden |

**Runde 3**
| Schritt | Ereignis | Folge |
|---|---|---|
| a | Cans Karte seit R1 offen → **GK 9**, **GK 10** (gespielt, Z-04); **GK 7** über MR4 oder GK 10 | M3 dreifach plus Hanas Geruch |
| b | Olli gegen sechs Zeugen und fünf Zusatzrollen | Stufe 2 fällt sichtbar |
| d | XD3, PP9, FK3 | 9 von 9 |

Zusatzrollen erfüllen keinen Pflicht-Auslöser der vier Verdächtigen (ZR §11.3 nachgeprüft). Grenzfall: Tugbas Vermutung
„jemand wollte die blinde Kuh im Vorratsraum erschrecken“ mit offenem JA9 gegen Cans Auslöser (c) (P2-15).

---

## 3. Prüfkriterien

| Kriterium | (a) 10 zurückh. | (b) 10 forsch | (c) 6 | (d) 20 | Urteil |
|---|---|---|---|---|---|
| keine Sackgasse | ja | ja | ja (c1, c2) | ja | **bestanden** |
| keine zirkuläre Bedingung | ja | ja | ja | ja | **bestanden** |
| kein Auto-Solve vor Runde 3 | gelöst nach R1 | gelöst nach R1 | gelöst nach R1 | gelöst in R1 | **nicht bestanden** (P2-01, P2-02) |
| Ahmet entlastbar | M1 + M4 | M1 + M4 | M1 + M4 | M1 + M4 | **bestanden** (Beleg-Lücke P2-05) |
| Fatma entlastbar | M2 + M5 | M2 + M5 | M2 + M5 | M2 + M5 | **bestanden** |
| Can entlastbar | M3 (R3) + M6 | dto. | dto. | dto. | **bestanden** |
| Bogentür/Kalk → Olli | YT4, GK 3, GK 7, XD3 | dto. | dto. | + GK 16 | **bestanden** |
| Kerzenständer → Olli | XD3 + FN3 | dto. | dto. | dto. | **bestanden** (zu früh lesbar) |
| Handschuh → Olli | FN3 | dto. | dto. | + Tugba, VP7 | **bestanden** (zu früh lesbar) |
| Eiskübel → Olli | PP9 + Ort 23:57 + Lejla „als Erstes zum Eiskübel“ | dto. | dto. | dto. | **bestanden** (Meta-Hinweis P2-07) |
| späte Ankunft rechtes Buffet → Olli | Lejla S1 | dto. | Streifen Lejla | dto. | **bestanden** |
| Ollis Stufe 2 glaubwürdig | gestützt von Schneiders Erinnerung, JA9, Cans Karte, „Can: nirgends“ | dto. | dto. | dto. | **bestanden** |
| Ollis Stufe 2 widerlegbar | GK 7, GK 9, GK 10, FK3, XD3 + FN3 | dto. | dto. | + Hana | **bestanden**; Marker-Streit P2-04 |

Weitere Beobachtungen: In R3 kommen XD3, PP9 und FK3 erst im Abschnitt d, also nach dem Gespräch; direkt danach folgt die
Tipp-Runde (P2-03). Die Dominos von Lejla, Joanna und Marek treffen in allen vier Läufen eine schon offene Karte (P2-06).

---

## 4. Befunde

### P2-01 · Blocker · Teil 01 verrät den Schlüsselbeweis vor Spielbeginn

**Fundstelle:** MECH §2.1 Z. 208 („Teil 2, Handschuh und Ärmel“), MECH §2.4 Z. 246–247 (Regel Nr. 1 und 2), RK §6.9
Z. 956 („Regeln 2.3 und 2.4 … stehen darunter wörtlich“), MECH §3.2 Z. 313 (Titel „Ollis Weste und Pulli“ in der
Untersuchungsliste), MECH §10.3 (Teil 01 wird vorab gesendet).

**Problem:** Der Bogen sagt dem Detektiv vor Runde 1, was XD3 erst in Runde 3 zeigen soll: Der Täter hatte Holzsplitter
und weißen Kalk am Ärmel, Teil 2 ist ein Handschuh. Nur Olli trägt einen Handschuh (WELT §1.2), die Untersuchungsliste nennt
„Ollis Weste und Pulli“. Spätestens wenn in R1 Ollis Geheimniskarte („aus der gekalkten Wand gerissen“) oder YT4 („Holzsplitter
und weißer Kalk am Türbogen“) offen liegt, ist der Fall gelöst. Das bricht E12 („der Fall nicht in Runde 1 fällt“), MECH §3.5
und den Sinn von Fehlerkorrektur 2 (A:107). In allen vier Simulationen ist der Fall nach R1 entschieden.

**Vorschlag (wörtlich):**
- MECH §2.1, Zeile unter dem Raster: „**Schlüsselbeweis:** Teil 1 ☐ · Teil 2 ☐ · gehört zu: ______________“
- MECH §2.4: „**Wer überführt ist:** Eine Person ist überführt, wenn alle drei Dinge offen auf dem Tisch liegen:
  1. Schlüsselbeweis Teil 1: eine Karte mit dem Vermerk ‚Schlüsselbeweis, Teil 1‘.
  2. Schlüsselbeweis Teil 2: eine Spur an einer Person, die genau zu Teil 1 passt.
  3. Der Fundort des Schlüsselbunds liegt an einem Platz, an dem diese Person kurz vor dem Scheppern nachweislich war
     (Zeile ‚Ort um 23:57‘).
  Dann scheiden alle anderen aus.“
- MECH §3.2 und Teil 01, Titel der drei Personen-Karten in gleicher Form: „Olli: Taschen und Kleidung“ (FN3), „Fatma:
  Taschen und Kleidung“ (NN3), „Can: Taschen und Kleidung“ (JT3). Nach E9 gleiche Gestalt.
- MECH §6.1 M9 anpassen: „XD3 offen, dazu eine passende Spur an einer Person (FN3) offen, Olli eingetragen“.

### P2-02 · Blocker · FN3 benennt in Runde 2 den Halter des Kerzenständers

**Fundstelle:** MECH §3.3 FN3, Z. 354 (zweiter Vermerk); MECH §3.2 Z. 313 Spalte „füllt im Bogen“; RK §7.5 Z. 1149.

**Problem:** FN3 ist ab Runde 2 frei, auch per Taschen-Check. Ihr Vermerk lautet „Schlüsselbeweis, Teil 2: … Zusammen mit
Teil 1 zeigt das, wer den Kerzenständer hielt.“ Die Karte ist Ollis Weste. Damit steht in R2 gedruckt: Olli ist der Teil 2
des Beweises, wer den Kerzenständer hielt. Das ist der Satz „Olli – Schlüsselbeweis“, den Fehlerkorrektur 2 verbieten will,
nur auf der anderen Karte. Auch wenn P2-01 behoben ist, fällt der Fall so in R2 (Lauf c1: R2 Untersuchung, Lauf d: R2
Taschen-Check). MECH §3.5 Nr. 2 („Ende Runde 2 stehen Olli und Can gegenüber“) gilt dann nicht.

**Vorschlag (wörtlich):** FN3-Vermerke ersetzen durch
- „Hinweis · Heimlichtuerei: Möbelwachs und Kalk an den Fingerkuppen von Ollis rechtem Handschuh. Vergleiche die Bogentür (YT4).“
- „Hinweis: Auf dem Handrücken frische rote Kerzenwachstropfen. An beiden Bündchen von Ollis Pulli Kalkstaub und feine Holzsplitter.“
XD3-Vermerk dafür ergänzen: „Schlüsselbeweis, Teil 1: Im roten Wachs am Fuß kleben feine Holzsplitter und weißer Kalk. Wer
den Kerzenständer am Fuß hielt, hatte beides am Ärmel. Teil 2 ist die passende Spur an einer Person.“ Bogen-Hinweis RK §6.9:
„Teil 2 kreuzt du an, wenn eine offene Karte an einer Person genau die Spur zeigt, die Teil 1 beschreibt.“ So bleibt FN3 in R2
ein starkes Indiz (rote Tropfen), aber kein gedrucktes Urteil; erst XD3 in R3 macht es zum Beweis.

### P2-03 · mittel · Runde-3-Funde kommen nach dem Gespräch, die Tipp-Runde direkt danach ist trivial

**Fundstelle:** MECH §1.3 (Abschnitte b bis f), R-12 Z. 146, §7.1 Z. 751; RK §7.5 „Wenn es eng wird“ (Sätze zu XD3, PP9).

**Problem:** XD3, PP9 und FK3 sind nur in R3 Abschnitt d ziehbar, also nach den 17 Minuten Gegenüberstellung. Danach folgen
nur Marker-Check und sofort die Tipp-Runde. Ergebnis in allen vier Läufen: (1) Ollis vorbereitete Sätze zu XD3 und PP9
haben kein Gesprächsfenster. (2) Wer tippt, sieht Kerzenständer, Handschuh und Eiskübel gerade offen liegen; Frage 1 und 2
sind für alle geschenkt. A:115-121 („fiebert jeder … bis zur letzten Sekunde mit“) verpufft. (3) Ollis Sonderwertung
(3 Punkte, wenn nicht angeklagt) ist dann fast nie erreichbar.

**Vorschlag (wörtlich, MECH §1.3 für Runde 3, A:105 und A:115 bleiben erfüllt):** „In Runde 3 folgt nach dem Abschnitt c
die Tipp-Runde. Erst danach macht der Detektiv seine drei Untersuchungen, trägt die Vermerke ein und klagt an.“ R-12 neu:
„Mit der Anklage legt der Detektiv den Stift weg.“ §7.1 Satz „Liegt PP9 schon offen …“ ersetzen durch „Die Tipps fallen vor
den letzten drei Untersuchungen. Wer den Eiskübel tippt, muss es aus dem Gespräch schließen.“ Ollis Sätze zu XD3 und PP9 in RN7
bleiben für den Fall, dass FN3 schon in R2 offen ist und für die Antwort auf die Standardfrage.

### P2-04 · mittel · Ollis Marker „Scheppern“ gegen R-06 bei offenem XD3 und FN3

**Fundstelle:** MECH §1.4 R-06 Z. 140, §1.3 Abschnitt e Z. 128; RK §4.2 Z. 523; RK §7.5 „Wenn es eng wird“; A:86.

**Problem:** R-06 verlangt Umstellen, sobald eine offene Karte dem Marker widerspricht; A:86 verlangt es, sobald Beweise eine
Lüge knacken. RN7 lässt Ollis Marker auf 4b bis zur Anklage. Im Marker-Check nach XD3 entsteht am Höhepunkt Streit: „Kerzenständer
und Handschuh widersprechen deinem Marker!“ – „Meine Fassung sagt, er bleibt.“ Der Erzähler kennt die Lösung nicht und kann
nicht entscheiden.

**Vorschlag (wörtlich):** R-06 Satz 2 neu: „Nennt eine offene Indizkarte, ein offener Streifen oder eine offene Geheimniskarte
für dich ausdrücklich einen anderen Ort, stellst du deinen Marker sofort vor allen um. Schlüsse aus mehreren Karten zählen
nicht; sie gehören in die Anklage.“ Abschnitt e: „Erzähler: ‚Nennt eine offene Karte oder ein offener Streifen für jemanden
ausdrücklich einen anderen Ort als seinen Marker?‘“ RN7, „Wenn es eng wird“, neuer Satz: „Sobald jemand verlangt, dass du den
Marker ‚Scheppern‘ wegen Kerzenständer und Handschuh umstellst: ‚Keine Karte sagt, wo ich beim Scheppern war. Der Marker
bleibt.‘“ (wahr; Lejla, Marek und XD3 nennen keinen Ort für Olli).

### P2-05 · mittel · M1 bis M3 zählen auch aus der eigenen Behauptung der Person

**Fundstelle:** MECH §6.1 Z. 664–671 („egal aus welcher Quelle“), MECH §2.3 Z. 238 („nachweislich“), RK §6.9.

**Problem:** Ahmet und Fatma sagen in Stufe 1 ihren wahren Ort beim Scheppern selbst. Ein Detektiv, der nur ihre Antworten
abschreibt, hat M1 und M2 in R1, ohne je Marek, einen Streifen oder Emine zu hören. Bei Can genügt seine eigene Karte mit
„stand Herr Schneider noch“, um „vor dem Scheppern weg“ einzutragen. Das widerspricht der Entlastungsregel („nachweislich“)
und entwertet in kleinen Runden die Ortstermine WJ9 und RH3 (Lauf a: M1 ohne Beleg).

**Vorschlag (wörtlich, MECH §6.1 unter der Tabelle, keine Pfad-Strafe):** „M1 bis M3 zählen nur, wenn in der Zelle eine
Quelle steht, die nicht die Person selbst ist: eine Zeugin, ein Zeuge, ein Streifen oder eine Karte. Welche, ist egal.“
Teil 01, Hinweis RK §6.9 ergänzen: „Ein ✓ bei ‚Alibi‘ braucht eine Quelle, die nicht die Person selbst ist.“

### P2-06 · mittel · Zeugen-Dominos treffen fast immer eine schon offene Karte

**Fundstelle:** MECH §4.2 Zeugen-Tabelle Spalte „Domino-Hinweis“; ZG §1.6 Z. 201 (Lejla), §4.7 Z. 773 (Joanna), §5.6 Z. 956
(Marek), §2.6 Z. 374 (Emine).

**Problem:** Lejla, Joanna und Marek drücken alle auf Ahmet. Lejla und Joanna drehen auf denselben Codes wie Ahmet (PM3, WM9)
oder auf Ahmets Karte; Marek erst in R3. In allen vier Läufen ist Ahmets Karte schon offen, wenn ihre Dominos kommen. Emines
Domino nennt niemanden am Tisch. Damit erzeugt in R2 und R3 kaum ein Zeugen-Domino neuen Druck (A:92: „neuer Domino-Hinweis,
der eine andere Rolle … unter Druck setzt“). Regel MECH §4.2: nur kleinere Plätze nennen.

**Vorschlag (wörtlich, alle Sätze wahr nach WELT §3.4, nur kleinere Plätze):**
- Lejla: „Als das Licht anging, ist Olli als Erstes zum Eiskübel, noch bevor jemand ‚Hier liegt Herr Schneider!‘ rief.“ (drückt auf Ollis Stufe 2 und Richtung PP9)
- Joanna: „Um fünf vor zwölf hab ich an der Tür zum Durchgang zum Gruppenfoto gerufen. Can war weder im Buffetsaal noch im Durchgang.“ (drückt auf Can, dessen Karte in R2 oft noch zu ist)
- Marek: „Kurz vor dem Knall rief Herr Schneider Tim zu: ‚Nicht die alte Leiste!‘ Tim stand einen Meter neben mir an der Kaffeemaschine.“ (drückt auf Tim, löst seine R3-Gesprächsauslöser)
- Emine: „Herr Schneider hat heute Abend nicht nur Fatma gedroht. Um elf war er an der Theke schon einmal laut.“ (zeigt auf den Streit um elf, also Olli)
Die bisherigen Ahmet-Sätze wandern in „Nach dem Umdrehen“ der jeweiligen Hefte; M4-Quellen bleiben über die Vermerke erhalten.

### P2-07 · mittel · „Eiskübel · ab Runde 3“ ist ein Meta-Hinweis auf den Fundort

**Fundstelle:** MECH §3.2 Z. 315; Teil 01 Untersuchungsliste (MECH §2.6 Seite 3).

**Problem:** Die Liste zeigt vor Spielbeginn: Alle Orte haben „Kein Schlüsselbund“ (M-10), nur zwei Gegenstands-Karten sind bis
R3 gesperrt: der Kerzenständer (Tatwaffe) und der Eiskübel. Damit ist der Fundort aus der Liste ablesbar; mit „Olli am Eiskübel“
(R1) zeigt er früh auf Olli. Das schwächt P2-01 und P2-02 nach ihrer Behebung erneut.

**Vorschlag (wörtlich):** PP9-Titel „Vor der Theke am Ostende“. VP7 von Runde 2 nach Runde 3 legen und betiteln „Kamin-Nische
und Ascheneimer“, sodass in R3 zwei mögliche Verstecke neben dem Kerzenständer stehen. (Hana behält ihre Gesprächsauslöser
und Serkans Karte; WM9 bleibt in R2 für M4.)

### P2-08 · klein · Schutzkarten können einen Pflicht-Auslöser abwürgen

**Fundstelle:** MECH §4.4 Z. 544–547 (Grenzen „wie Einspruch“), §4.5 Begründung.

**Problem:** §4.5 sagt, keine Schutzkarte halte einen Pflicht-Auslöser auf; die gedruckten Grenzen sagen das nicht. Olli kann
„Themenwechsel“ spielen, sobald Lejla zu reden beginnt, und das Thema für die Runde sperren. Streit am Tisch genau beim
wichtigsten Stein.

**Vorschlag (wörtlich, Grenzen aller vier Schutzkarten):** „Nicht gegen einen Ortstermin, eine Indizkarte oder eine Karte,
die schon offen liegt. Was offen liegt, bleibt liegen. Wer gerade einen Satz sagt, der bei jemandem eine Karte auslöst, sagt
ihn zu Ende; er gilt.“

### P2-09 · klein · Zeitstempel: Lücke bei „niemand“ und Zuordnung zum Etikett

**Fundstelle:** MECH §4.4 Z. 551; MECH §5.3 Etikett-Muster; RK §1.5 („der Caterer“, „deine beste Freundin“).

**Problem:** (1) Die Karte verlangt, dass die Person jemanden nennt; Can (Turm-Toilette) und Olli (Ost-Saal) können das in
Stufe 1 nicht. (2) Hefte nennen fehlende Zeugen nur umschrieben („der Caterer“); das Etikett nennt nur den Namen „Marek“. Der
Erzähler muss raten.

**Vorschlag (wörtlich):** Wirkung ergänzen: „Kann sie niemanden nennen, sagt sie das.“ Etikett-Muster: „Zeugenstreifen ·
[Name], [Rollenbezeichnung] · Zone [Nr], [Ort].“, etwa „Zeugenstreifen · Marek, der Caterer · Zone 4d, hinter der Theke am
Ostende.“ Grenzen: „Nennt die Person jemanden, der heute fehlt, dreht der Erzähler den Streifen mit dieser Rollenbezeichnung
um. Der Streifen gilt als Antwort.“

### P2-10 · klein · „vor allen“ bei Gesprächen in Grüppchen nicht bestimmt

**Fundstelle:** RK §4.7 Auslöser (b), (c); RK §5.7 (c); ZG §3.6, §5.6, §6.6 (Z-03); MECH §9.13 Z. 1097 („Grüppchen“).

**Problem:** Ab 14 Personen laufen Gespräche parallel. Mehrere Pflicht-Auslöser verlangen „vor allen“. Ob ein Satz im
Grüppchen zählt, ist offen. Lauf (d) R2 zeigt den Streitfall.

**Vorschlag (wörtlich, neue Tischregel R-13):** „‚Vor allen‘ heißt: am Verhörstuhl oder nachdem der Erzähler ‚Alle mal
herhören!‘ gerufen hat. Wer im Grüppchen einen solchen Satz sagen will, ruft den Erzähler und sagt ihn dann vor allen.“

### P2-11 · klein · Enthaltung bei „Handzeichen“ fehlt in den Heften 1–10

**Fundstelle:** MECH §4.4 Z. 561; ZG §0.1 G-01; ZR ZG-16 (nur Zusatzrollen); ZR §15 Nr. 5.

**Problem:** Fragt Tugba „Wer hat im Dunkeln das leuchtende Gesicht gesehen?“, müssen Tim, Marek, Zeynep (Zeugen lügen nie)
die Hand heben und zeigen vor R3 an, dass sie etwas wissen, oder lügen.

**Vorschlag (wörtlich, Grenzen der Karte):** „Jede Rolle antwortet nach ihrem Heft. Wer die Antwort noch zurückhält, hebt
nicht und sagt laut: ‚Ich enthalte mich.‘ Detektiv und Erzähler heben nicht.“

### P2-12 · klein · Domino-Frage nach Ollis Karte richtet sich an Herrn Schneider

**Fundstelle:** MECH §9.9 Z. 976–979; R-10 Z. 144.

**Problem:** Ollis Domino nennt nur Herrn Schneider. Die Domino-Frage („sag uns sofort, ob das stimmt“) würde den Erzähler
zwingen, für Herrn Schneider zu sprechen, was R-10 nur bei JA9, PM3 und Krankenbesuch erlaubt.

**Vorschlag (wörtlich):** „Nennt die Karte niemanden am Tisch oder nur Herrn Schneider, entfällt die Domino-Frage.“

### P2-13 · klein · Abweichungen zwischen den Graph-Tabellen

**Fundstelle und Vorschlag:**
- MECH §5.3 Z. 635: Streifen Zeynep „AD3; Zeitstempel“; ZG §6.11 und MECH §3.3 FK3 nennen zusätzlich FK3. Angleichen auf „AD3, FK3; Zeitstempel“.
- MECH §3.4 Z. 424: FM9 bei Sibel und Azra nur „Druck“, MECH §4.2 macht FM9 zur Pflicht (ZR §15 Nr. 1). §3.4 Spalte „Pflicht“: „Emine (R2); Fatma, wenn ihr Marker ‚23:57‘ schon auf 4a steht; Sibel; Azra“.
- MECH §6.3 Z. 709: Zeile 10 „wie 6“ übernimmt „Zeitstempel beim Detektiv“; bei 10 Personen hält Joanna die Karte. Ersetzen durch „Str Marek (WJ9 oder Joannas Zeitstempel)“.
- MECH §3.4, Zeile FN3: „Pflicht: Olli, falls noch zu“. Ollis drei Pflicht-Auslöser (MECH §4.2, RK §4.7) enthalten FN3 nicht, und RK-03 verbietet weitere. Bei der Standardfrage nach FN3 entsteht Streit, ob Olli umdrehen muss. Angleichen: Spalte „Pflicht“ „–“, Spalte „Druck“ „Olli, Tugba, Tim, Wojtek“. (Hinweis: Fatma und Can drehen bei ihrer eigenen Taschen-Karte um, Olli nicht. Bei 6 Personen mit schwachem Detektiv kann das am Tisch auffallen; die Gleichheit nach E9 sollte das Erzählerheft dann nicht kommentieren.)
- MECH §3.4, Zeile WE3: Aylin steht unter „Druck“, MECH §4.2 und ZR machen WE3 zu ihrem Pflicht-Auslöser (ab R2). Spalte „Pflicht“: „Lejla (R2); Joanna (R2); Aylin (R2)“.

### P2-14 · klein · Uhrzeit „Ahmet hinter die Theke“ in Fatmas Texten uneinheitlich

**Fundstelle:** RK §3.5 Nr. 5 Z. 393 und §8.1 Z. 1236 („23:56“), RK §7.4 „Was nur du weißt“ Nr. 2 Z. 1091 („23:56“) gegen
Fatmas Karte §3.8 Z. 452 („23:57“), Lejlas Karte und A:50 („23:57“).

**Problem:** Dieselbe Beobachtung steht mal mit 23:56, mal mit 23:57. Am Tisch klingt das wie ein Widerspruch zwischen Heft und
Karte.

**Vorschlag:** überall „Um 23:57 Uhr ging Ahmet mit einem dicken Umschlag am Ostende hinter die Theke.“ (A:50).

### P2-15 · klein · Tugbas Vermutung streift Cans Auslöser (c)

**Fundstelle:** ZR §8.6 Z. 1473; RK §5.7 Z. 754; ZR ZG-15.

**Problem:** „Ich glaub, da wollte jemand die blinde Kuh im Vorratsraum erschrecken.“ kann bei offenem JA9 als „das Gesicht kam
aus dem Vorratsraum“ gelesen werden. ZG-15 will genau das ausschließen.

**Vorschlag (wörtlich, Cans Auslöser c):** „(c) Sobald Herrn Schneiders rechte Hand (JA9) offen liegt und jemand vor allen sagt,
er habe das leuchtende Gesicht aus dem Vorratsraum kommen sehen.“ (Olli und Marek sahen es; eine Vermutung zählt dann nicht.)

---

## 5. Was hält (bestätigt)

- Ring Ahmet → Olli → Can → Fatma → Ahmet trägt: Ollis Domino plus JA9 dreht Can verlässlich in R1 oder R2; Ahmets Domino dreht
  Olli bei 6 Personen auch ohne Ortstermin (Lauf c2).
- Ollis Stufe 2 fällt nie vor R3 und fällt in R3 sicher: drei unabhängige Quellen (Tim, Marek, Zeynep) plus FK3, alle mit Sperre
  R3, plus Hanas Geruch ab 15 Personen. Ollis eigener Satz „das Gespenst war es“ löst in R3 die Gesprächsauslöser von Tim, Marek
  und Zeynep aus: Die Lüge ruft ihre eigene Widerlegung herbei.
- Fatmas falsche Fährte (Klappe, „Umriss von der Klappe“) löst Emine auf, auch als Streifen.
- Kein Beweis zeigt auf einen der drei Unschuldigen, ohne dass ein Gegenbeleg existiert; JA9 (gelbe Fasern) wird durch M3 aufgelöst.
- E7 hält: Kein Streifen ist offen; bei 6 Personen bringt R1 höchstens Ollis Stufe 2 und zwei Alibis.
- Rundensperren und Codes der Zeugen sind für gespielte und fehlende Zeugen gleich (M-17), die Gesprächsauslöser der
  gespielten Zeugen umgehen keine Sperre.

## 6. Gesamturteil

Befunde: 2 Blocker (P2-01, P2-02), 5 mittel (P2-03 bis P2-07), 8 klein (P2-08 bis P2-15). Nach Behebung von P2-01 und
P2-02 wäre der Fall bei allen vier Besetzungen erst in Runde 3 lösbar; der Rest des Graphen ist tragfähig.
