# P1 · Interaktions- und Pausen-Test am echten Druck (Runde 3)

Fall U4YRK, Kammerspiel „Spuk im Schlosskeller“, Täter Olli. Stand 2026-11-02.
Geprüft wurde der Druck aus dem Hauptlauf (`druck-r3`), nicht der Bibel-Text. Das Repository blieb unverändert.
Eigene Dateien lagen nur im Arbeitsordner der Prüfung außerhalb des Repositorys (ein 18-Personen-Satz zur Gegenprobe in
`r3/p1-druck/p18`, Bildproben in `r3/p1-bilder`).

Maßstab: AUFTRAG.md Abschnitt 5, Protokoll 1 (wörtlich): „Hat jede einzelne Rolle in Runde 1, 2 und 3 aktive
Gesprächsaufträge, einen klaren Stufe-1/Stufe-2-Übergang, eine sinnvolle Geheimniskarte und eine nützliche
Spezialfähigkeit? Gibt es irgendeine Rolle (insbesondere Joanna, Tim, Marek, Lejla), die noch Leerlauf hat?“ Dazu
FALL-BIBEL (RK 1.2, ZG 0.1–0.6, ZR 0.7, MECH 1.3, 1.4, 4.4, 9.14) und die angenommenen Abweichungen (E1–E22, MECH 12a,
WELT 0.3, 19.2). Bekannte Punkte aus der Aufgabe und aus `tests/P1+P4+P5-runde2.md` (K16 Ollis Bonus-Ziel, K20 Damir,
Wojtek und Tugba ohne eingehende Ziele, M07 Bonus-Ziele, die sich selbst erfüllen) werden nicht erneut gemeldet.

---

## 0. Ergebnis in Kürze

- **Bestanden mit Befunden. Kein Blocker.**
- In allen drei Besetzungen (6, 10, 20 Personen, Detektivin) hat jede gespielte Rolle in jeder Runde zwei
  Gesprächsaufträge, einen im Heft gedruckten Übergang von Stufe 1 nach Stufe 2, eine passende Geheimniskarte in Teil 20
  und eine Aktionskarte mit Runde, Wirkung und Grenzen. Joanna, Tim, Marek und Lejla haben in jeder Runde eigene Aufträge
  und werden in Runde 1 und 2 angesprochen. Ihre Geheimniskarten tragen den Fall.
- Die Gegenprobe über Kreuz ergibt bei allen 108 Aufträgen (20 Personen), 48 Aufträgen (10 Personen) und 24 Aufträgen
  (6 Personen) ein Ziel, das am Tisch sitzt oder als gedrucktes Ausweichziel kommt. Für fast jede Frage steht im Heft des
  Ziels eine Antwort. Ausnahmen sind die beiden Befunde unten.
- **2 mittlere Befunde:**
  - **P1R3-01:** Die Flüster-Aufträge der Tandems in Runde 2 (Serkan an Hana, Damir an Sibel) laufen ins Leere, wenn die
    Tandem-Karten schon offen liegen. Bei 18 bis 20 Personen ist das für Tandem 2 nach Runde 1 immer so.
  - **P1R3-02:** In Runde 3 haben Tim, Marek und Zeynep keinen gedruckten Satz für die Frage nach dem Gesicht oder der
    Vorratsraumtür, wenn sie nicht vor allen gestellt wird. Sieben Runde-3-Aufträge bei 20 Personen (zwei bei 10 Personen)
    zielen genau auf diesen Auslöser, sagen aber nicht „vor allen“.
- **1 kleiner Befund:**
  - **P1R3-03:** Der Arbeitsvermerk „Dazu im Heft:“ steht in Mareks Heft, der Tipp in Anführungszeichen wie ein Satz
    zum Vorlesen.
- Die Stichprobe mit Detektiv (m) unterscheidet sich nur in Anrede und Beschriftung (Teil 00, 01, 02, 90). Hefte, Karten
  und Fassungen sind gleich. Für P1 gibt es keinen Unterschied.

---

## 1. Methode

1. Text aller Hefte (Teil 10, 12), Karten (Teil 20), Erzählerheft (Teil 00), Detektivbogen (Teil 01) und Tisch (Teil 02)
   aus `druck-r3/text/w/kammerspiel-U4YRK-p6|p10|p20` gelesen, je Rolle und Runde in Tabellen übertragen.
2. Zielmatrix maschinell gezogen (`grep "Ziel [12] · <Name>"` je Heft und Runde), dann jedes Ziel von Hand gegen das Heft
   der Zielrolle gehalten: Stufe 1 („Das sagst du“, „Wenn jemand fragt“, „Das sagst du jedem“, „Das behältst du für
   dich“), „Wenn der Erzähler fragt“, „Was du über andere sagen darfst“, „Was du bei dir trägst“, Stufe 2 und „Nach dem
   Umdrehen“. Bei fehlender Zielrolle: das gedruckte Ausweichziel geprüft.
3. Jeder Auslöser (Stufe 2) auf drei Fragen geprüft: Steht er im Heft? Ist er am Tisch erkennbar (Code, offene Karte,
   „vor allen“)? Tritt er im Spiel ein (Karte ist in der Untersuchungsliste frei, die auslösende Frage steht in einem
   fremden Heft, Impuls im Erzählerheft)?
4. Geheimniskarten (Teil 20, Seite 11–19 bei 20 Personen) gegen „Was du dann zugibst“ im Heft verglichen. Aktionskarten
   (Teil 20, Seite 20–22) gegen den Kasten im Heft: Name, „ab Runde“, Wirkung, Grenzen, Tipp.
5. Leerlauf: je Rolle und Runde eigene Aufträge, eingehende Aufträge (aus der Zielmatrix), Rundensperre, Stand nach
   dem Umdrehen.
6. Bildprobe: `10-rollenheft-lejla.pdf` S. 1 (graue Haltungszeile ist gewollt, ZG 1.1) und `10-rollenheft-marek.pdf`
   S. 3 (Befund P1R3-03) mit `pdftoppm -r 60/80` angesehen.
7. Zusatzbesetzung 18 Personen (w) mit der CLI gesetzt, um P1R3-01 außerhalb der 20 zu bestätigen.
8. w gegen m: `diff` aller Textdateien bei 6, 10 und 20 Personen.

---

## 2. 20 Personen (w): Rolle × Runde

Abkürzungen: GK = Geheimniskarte (Teil 20), AK = Aktionskarte, R1–R3 = Runde, „ein“ = eingehende Aufträge (R1/R2/R3)
aus der Zielmatrix. Alle Fundstellen: `druck-r3/w/kammerspiel-U4YRK-p20/…`.

| Rolle | R1 | R2 | R3 | Stufe 1 → 2 (Auslöser, Sperre) | GK | AK | ein | Leerlauf? |
|---|---|---|---|---|---|---|---|---|
| 1 Ahmet | Fatma (Wer hat dich gesehen?), Marek (Wer kauerte an deinen Beinen?) | Olli (Streit um elf), Joanna (Wen an der Theke?) | Can (Wo bei „Hab ich dich!“?), Lejla (Wer kam zu dir?) | (a) PM3/WM9, (b) Lejlas Karte, (c) Taschenkontrolle + WE3; keine Sperre; Heft S. 3 | S. 11, passt zu Heft S. 3 | Einspruch, ab R1, Grenzen da | 4/9/2 | nein |
| 2 Fatma | Can (Wann hoch?), Emine (Wer kauerte neben dir?) | Ahmet (Quittung?), Zeynep (Gebäck für wen?) | Olli (Wo beim Scheppern?), Marek (Was an der Tür?) | (a) NN3, (b) FM9 + Marker Klappe, (c) Emines Karte; Markersatz für die Klappe vor der Karte; Heft S. 2–3 | S. 11 | Gegenfrage, ab R1 | 4/5/1 | nein |
| 3 Olli | Ahmet (Was hinter der Theke?), Tim (Wo warst du, als ich Eis brachte?) | Can (Für Mitternacht etwas vorbereitet?), Marek (Lieferwagen) | Fatma (Wo beim Knall?), Lejla (Weiß er noch, wer ihn packte?) | (a) Joannas Notiz vor allen, (b) Lejla vor allen, (c) Ahmet/Fatma vor allen; fällt praktisch in R1 (Lejla und Joanna R1 Ziel 1 „vor allen“) | S. 12, keine Tat (E9) | Themenwechsel, ab R1 | 7/5/12 | nein; nach dem Umdrehen trägt Stufe 2 bis zur Anklage |
| 4 Can | Olli (Wer bezeugt das Sitzen?), Zeynep (Wo sahst du mich?) | Fatma (Tasche), Joanna (Fotos) | Ahmet (Was hast du gehört?), Tim (Was gesehen, in welcher Reihenfolge?) | (a) JT3, (b) Zeyneps Karte, (c) JA9 + „Gesicht aus dem Vorratsraum“ (Ollis Karte); Heft S. 3 | S. 12 | Retourkutsche, ab R1 | 4/4/7 | nein |
| 5 Lejla | Olli (vor allen: erst nach dem Scheppern), Can (Wo um fünf vor zwölf?) | Ahmet (Karte zu/offen), Marek (Stimmt das mit den Beinen?) | Olli (Stufe 2/Stufe 1), Tim (vor allen: Was kam vorbei?) | WE3/PM3/WM9, Ahmets Karte, Joannas Karte; frühestens R2; Heft S. 3 | S. 13 | Krankenbesuch, ab R1 | 2/0/3 | nein |
| 6 Emine | Olli (Wer saß neben dir?), Lejla (Wer beim Scheppern bei dir?) | Fatma (Karte zu/offen), Olli (Karte offen/sonst) | Olli (Wer hat dich gespürt?), Can (der Reihe nach) | FM9/NN3, Fatmas Karte; frühestens R2 | S. 13 | Kreuzverhör, ab R1 | 2/0/0 | nein (eigene Aufträge in jeder Runde) |
| 7 Tim | Fatma (Was wollte Herr Schneider?), Zeynep (Auf wen gewartet?) | Ahmet (Was zu klären?), Can (JA9/sonst) | Olli (Karte zu/offen), Marek (Was an der Tür?) | MR4/FK3, R3-Frage vor allen, R3 „das Gespenst war es“, Zeyneps Karte, I-3.1; frühestens R3 | S. 14 | Stirnlampe, ab R2 | 4/3/4 | nein; Lücke in R3 siehe P1R3-02 |
| 8 Joanna | Olli (vor allen: Notiz), Fatma (Was an der Klappe?) | Can („nirgends!“), Ahmet (Karte zu/offen) | Olli (Stufe 2/1), Zeynep (Was kam durch den Bogen?) | WE3/PM3/WM9, Ahmets Karte, Lejlas Karte; frühestens R2 | S. 14 | Zeitstempel, ab R1 | 1/3/0 | nein |
| 9 Marek | Ahmet (Servietten?), Tim („Zweitausend“, „Leiste“) | Ahmet (Wo ist das Geld?), Olli (kaputtgegangen? / YT4) | Olli (Karte offen/zu), Can (Karte offen/zu) | XD3/JT3, Cans Karte, R3-Frage vor allen, R3 „das Gespenst war es“, I-3.1; frühestens R3 | S. 15 | Taschenkontrolle, ab R2 | 1/2/4 | nein; Lücke in R3 siehe P1R3-02 |
| 10 Zeynep | Fatma (Tasche), Olli (Bogentür um zehn vor zwölf) | Tim (Leiste), Joanna (Fotos) | Olli (drei Fassungen), Tim (Sag allen, was vorbeikam) | FK3/JT3, Cans Karte, R3-Frage vor allen, R3 „Can/das Gespenst war es“, I-3.1; frühestens R3 | S. 15 | Gelbe Karte, ab R1 | 3/1/2 | nein; Lücke in R3 siehe P1R3-02 |
| 11 Sibel | Can (Wann hoch?), Zeynep (Auf wen gewartet?) | Fatma (FM9 offen/zu), Ahmet (Geld bei dir?) | Olli (Wo beim Dunkelwerden?), Can (Karte offen/zu) | FM9/YT4, Damirs Karte, „andere Person hat die Vitrine kaputt gemacht“ vor allen; keine Sperre | S. 16 | Noch mal rückwärts, ab R1 | 0/1/0 | nein |
| 12 Damir | Tim (Kaffeemaschine), Emine (Wer kauerte neben dir?) | Ahmet (Karte offen/zu), Sibel (leise) | Marek (Was an der Tür?), Can (vor oder nach?) | YT4, Sibels Karte, Vitrinen-Vorwurf vor allen | S. 16 | Teepause, ab R1 | 1/0/0 | R2 Ziel 2 oft tot, siehe P1R3-01 |
| 13 Hana | Olli (Bogentür), Ahmet (hinter der Theke?) | Can (Bauchtasche), Tim (Wusstest du, wo es knallt?) | Olli (Stufe 2/1, Kerzengeruch), Tim (vor oder nach?) | VP7, Serkans Karte, „was in den Kamin“ vor allen (Wojtek R1) | S. 17 | Spurenlesen, ab R1 | 1/1/0 | nein |
| 14 Serkan | Lejla (Wie geht es ihm?), Damir (Wer bei dir?) | Hana (leise), Fatma (Tasche) | Lejla (Wer zuerst wohin?), Can (vor oder nach?) | zweimal „warum Außentor“ (Azra R1, Aylin R1, I-1.3, Detektiv), Hanas Karte | S. 17 | Lagebesprechung, ab R1 | 2/1/0 | **R2 Ziel 1 tot**, siehe P1R3-01 |
| 15 Azra | Olli (20:15), Serkan (Was draußen?) | Ahmet (0:12 Kamin), Fatma (Karte offen/zu) | Olli (Wohin im Dunkeln?), Zeynep (vor allen) | NN3/FM9, Fatmas Karte | S. 18 | Lupe, ab R1 | 0/0/1 | nein |
| 16 Wojtek | Tim (Steckdose), Hana (vor allen) | Tim (Karte offen/zu), Olli (drei Fassungen) | Olli (Handschuh), Azra (Karte offen/zu) | MR4, Azras Karte, Tims Karte; frühestens R2 | S. 18 | Maßband, ab R1 | 0/1/0 | nein |
| 17 Aylin | Ahmet (Beleg), Serkan (Wohin, warum?) | Ahmet (Karte offen/zu), Wojtek (Taschenlampe) | Ahmet (Karte offen/zu), Olli (drei Fassungen) | PM3/WE3, Ahmets Karte, Taschenkontrolle der Mappe; frühestens R2 | S. 19 | Beleg bitte!, ab R1 | 0/1/0 | nein |
| 18 Tugba | Can (Wo warst du?), Joanna (Wer fehlte?) | Olli (Handschuh), Aylin (Beleg?) | Can (Warst du das?), Marek (Torte, Tür) | jederzeit; spätestens Aylins Karte oder Taschenkontrolle (E11: harmlos) | S. 19, „Nichts für den Ermittlungsbogen.“ | Handzeichen, ab R1 | 0/0/0 | nein (eigene Aufträge; K20 bekannt) |
| Detektivin | Verhörstuhl A1–A3 an die vier; Impuls „Wer war neben dir?“; 3 Untersuchungen ab R1 | Impulse „Geld“, „Turmgang und Bogentür“, „Das Gesicht“; 3 Untersuchungen ab R2 | Impulse „Was kam zuerst?“, „Der Weg zur Vorratsraumtür“, „Nach dem Licht“; Tipp-Runde abwarten; 3 Untersuchungen; Anklage | – | – | keine eigene (alle Zeugen gespielt) | – | nein (01 S. 3 „Deine Aufgaben je Runde“) |
| Erzähler | Rundenstart, I-1.1–I-1.4, „Wechsel!“, Reinen Tisch, Untersuchungen, Marker-Probe, Rundenschluss | dazu Gegenüberstellung (7 min ab 18 P.), I-2.1–I-2.4, Herr Schneider | Gegenüberstellung, I-3.1–I-3.4, Tipp-Runde, Anklage, Teil 90; Bonus-Zählung | – | – | – | – | nein (00 S. 9–13, 16) |

**Joanna, Tim, Marek, Lejla (A:128):** Alle vier haben in jeder Runde zwei eigene Aufträge, werden in Runde 1 und 2
angesprochen (Joanna R2: Ahmet, Can, Zeynep; Tim R1/R2: Olli, Marek, Damir, Wojtek, Zeynep, Hana; Marek R1/R2: Ahmet,
Olli, Lejla; Lejla R1: Emine, Serkan) und tragen mit ihrer Karte einen Domino-Stein. Tim und Marek sind bis Runde 3
gesperrt. Ihre Stufe-1-Hefte geben ihnen für Runde 1 und 2 genug offenes Wissen (Tim acht Sätze „Das sagst du jedem“,
Marek acht). Kein Leerlauf. Die einzige Lücke ist die Runde-3-Frage außerhalb von „vor allen“ (P1R3-02).

---

## 3. Gegenprobe über Kreuz, 20 Personen (w)

Für jeden Auftrag: wo im Heft der Zielrolle die Antwort steht. „R-14“ = nur die allgemeine Regel „Dazu sag ich jetzt
nichts.“ (bei Ja/Nein-Fragen zulässig). ⚠ = Befund.

| Fragende Rolle | R1 Ziel 1 | R1 Ziel 2 | R2 Ziel 1 | R2 Ziel 2 | R3 Ziel 1 | R3 Ziel 2 |
|---|---|---|---|---|---|---|
| Ahmet | Fatma S. 2 „Wo warst du um drei vor zwölf?“; Nachschlag: Markersatz Klappe | Marek S. 2 „Das sagst du jedem“ (Beine, Scheppern, Licht) | Olli S. 2 „Was hast du mit Herrn Schneider zu tun?“; Nachschlag: I-2.1 Karte offen | Joanna S. 2 Notiz-Kasten; Nachschlag: Joannas Auslöser 2 | Can S. 2 „Herr Schneider hat eine Kapuze gepackt. Deine?“ | Lejla S. 2 „Beim Scheppern war ich allein. Erst danach …“ |
| Fatma | Can S. 2 „Wann bist du hoch …?“ | Emine S. 2 „Gleich nach dem Knall …“ | Ahmet S. 2 „Die 150 € waren für die Miete.“ | Zeynep S. 2 Gebäck um Viertel vor zwölf; Wissen 23:45 „für sich und Can“ (offen) | Olli Stufe 1/2 | Marek Auslöser 3 nur vor allen ⚠ P1R3-02 |
| Olli | Ahmet S. 2 „Servietten“ | Tim S. 2 „Gleich danach hat Olli mir Eis …“ | Can Kernsatz „Welche Maske?“ / R-14 | Marek S. 2 „Ich steh auf Herrn Schneiders Parkplatz …“ | Fatma S. 2 neben Emine | Lejla S. 2 „An die Sekunden vor dem Scheppern erinnert er sich nicht.“ |
| Can | Olli S. 2 „Wer saß bei dir?“; Nachschlag: „Wo warst du um 23:51 Uhr?“ | Zeynep I-3.3, Wissen 0:01 (offen) | Fatma „In meiner Tasche sind nur Bücher.“ | Joanna „Fotos zeig ich heute nicht.“ + Notiz | Ahmet „Was hast du im Dunkeln gehört?“ | Tim Auslöser 2 nur vor allen ⚠ P1R3-02 |
| Lejla | Olli Auslöser (b) | Can „Oben auf der Turm-Toilette.“ | Ahmet Miete / Karte | Marek „Das sagst du jedem“ | Olli Stufe 2/1 | Tim Auslöser 2 („Sag es jetzt, vor allen.“) |
| Emine | Olli „Wer saß bei dir?“ | Lejla „Beim Scheppern war ich allein …“ | Fatma reinen Tisch (R-05) | Olli Stufe 2 „Um 23:00 Uhr drohte er mit der Polizei.“ / „Der meckert …“ | Olli | Can Stufe 1 / Karte offen |
| Tim | Fatma „Was wollte Herr Schneider an deinem Buffet?“ | Zeynep „warum du im Bogen standest“ | Ahmet „Servietten“ / 23:51 | Can „Kapuze … Deine?“ | Olli Stufe 1/2 | Marek Auslöser 3 nur vor allen ⚠ P1R3-02 |
| Joanna | Olli Auslöser (a) | Fatma Markersatz „Ja, ich war kurz an der Klappe …“ | Can „Oben auf der Turm-Toilette.“ | Ahmet Miete / Karte | Olli Stufe 2/1 | Zeynep Auslöser 3 nur vor allen ⚠ P1R3-02 |
| Marek | Ahmet „Servietten“ | Tim „ob du ‚Zweitausend, bis zwölf‘ gehört hast“, „ob … dich meinte“ | Ahmet „Was ist das Geld in deiner Hosentasche?“ | Olli I-2.2 (Tragen), Bogentür nur R-14 (Ollis Karte meist seit R1 offen) | Olli Stufe 2 | Can Karte offen/zu |
| Zeynep | Fatma „Bücher“ | Olli „Wo warst du um 23:51 Uhr?“ | Tim „warum die Sicherung geflogen ist“, „Leiste“ | Joanna „Fotos zeig ich heute nicht.“ | Olli | Tim Auslöser 2 („Sag allen“) |
| Sibel | Can „Wann bist du hoch …?“ | Zeynep „warum du im Bogen standest“ | Fatma Tasche / FM9 | Ahmet „Was ist das Geld in deiner Hosentasche?“ | Olli | Can Karte offen „Als ich mich losgerissen hab …“ |
| Damir | Tim „Kurz vor zwölf … Kaffeemaschine“ | Emine | Ahmet | Sibel (Tandem, leise) ⚠ P1R3-01 | Marek Auslöser 3 nur vor allen ⚠ P1R3-02 | Can |
| Hana | Olli 23:51 | Ahmet „Servietten“ | Can „Was ist in deiner Bauchtasche?“ | Tim „warum die Sicherung geflogen ist“ | Olli Stufe 2/1 | Tim Auslöser 2 nur vor allen ⚠ P1R3-02 |
| Serkan | Lejla „Das sagst du jedem“ (Kühlpack, Olli) | Damir „Direkt neben mir hat Ahmet geflüstert …“ | Hana (Tandem, leise) ⚠ P1R3-01 | Fatma Tasche | Lejla „Als das Licht anging, ist Olli als Erstes zum Eiskübel.“ | Can |
| Azra | Olli „Dein Auftritt“ (20:15 offen) / R-14 | Serkan „Decken“ | Ahmet I-3.3 / Hosentasche | Fatma R-14 / Karte | Olli | Zeynep Auslöser 3 („Sag es vor allen.“) |
| Wojtek | Tim „warum die Sicherung geflogen ist“ | Hana Auslöser 3 (vor allen) | Tim 20:15-Zeile / Sicherung | Olli Karte offen (meist seit R1) / R-14 | Olli „Was ist mit deinem Handschuh?“ | Azra „Erst nach Wojteks Karte“ / Tim „nach dem Werkzeugkasten“ |
| Aylin | Ahmet „Servietten“ | Serkan „Decken“ | Ahmet | Wojtek Stufe 1 (Taschenlampe) + „Was du bei dir trägst“ | Ahmet | Olli Stufe 2 / „Der meckert über alles.“ |
| Tugba | Can | Joanna Notiz | Olli „Was ist mit deinem Handschuh?“ | Aylin „ob du deinen Beleg bekommen hast“ | Can | Marek „Die Mitternachtstorte steht unversehrt im Regal.“; Tür nur vor allen ⚠ P1R3-02 |

**Antwort ohne Frage, die das Spiel braucht:** keine gefunden. Jedes tragende offene Wissen wird gefragt oder von
selbst gesagt: Damirs Zeugnis für Ahmet (Serkan R1, I-1.2), Mareks Torte (Tugba R3, XD3), Tugbas Handschuh (Tugba R2 an
Olli), Aylins Zettel (Tugba R2), Azras 0:12 (Azra R2 selbst), Hanas Geruch (ab R3 „Das sagst du jedem“, I-3.1), Serkans
Tor (Serkan R3 selbst), Tims „nur Herr Schneider durch die Bogentür“ („Das sagst du jedem“).

**Ollis Bogentür:** Marek (R2 Ziel 2, Nachschlag nach YT4), Wojtek (R2 Ziel 2) und Aylin (R3 Ziel 2) fragen Olli nach
der Schramme. Ollis Stufe 1 hat dafür keinen eigenen Satz (wie RK 4.6). Ab 7 Personen ist Ollis Karte aber spätestens in
Runde 1 offen (Lejla und Joanna fragen vor allen), danach gilt „Ab jetzt sagst du offen, was an der Bogentür war.“ Vorher
greift R-14. Kein Befund.

---

## 4. 10 Personen (w)

Besetzt: Ahmet, Fatma, Olli, Can, Lejla, Emine, Tim, Joanna. Streifen: Marek (4d, WJ9), Zeynep (6, AD3/FK3). Die
Aktionskarten Taschenkontrolle und Gelbe Karte liegen bei der Detektivin (01 S. 6, 20 S. 17 „Aktionskarte · heute beim
Detektiv“).

| Rolle | gedruckte Ausweichziele (Fundstelle) | Antwort/Wirkung | Urteil |
|---|---|---|---|
| Ahmet | R1 Ziel 2: „Bitte den Detektiv um den Ortstermin ‚hinter der Theke am Ostende‘ … frag Can: ‚… Wann bist du zur Turm-Toilette hoch?‘“ (10-rollenheft-ahmet S. 3) | WJ9 deckt Mareks Streifen auf; Can „Wann bist du hoch …“ | in Ordnung |
| Fatma | R2 Ziel 2 → Can „Warum nicht?“; R3 Ziel 2 → XD3 + Can „Wo war deine [Kapuze]?“ (S. 3) | Can Stufe 1 | in Ordnung |
| Olli | R2 Ziel 2 → Ahmet „Wofür genau, und wo ist das Geld jetzt?“ | Ahmet „Die Miete …“ | in Ordnung |
| Can | R1 Ziel 2 → Fatma „Hast du mich da gesehen? Nein? Siehst du.“ | Fatma „Kurz vor zwölf hab ich Can im Buffetsaal nirgends gesehen.“ | in Ordnung |
| Lejla | R2 Ziel 2 → Olli „Ging es da um dich?“ | Olli Stufe 2 (Karte seit R1 offen) / „Der meckert …“ | in Ordnung |
| Tim | R1 Ziel 2 → Can; R3 Ziel 2 → Lejla „Hat er gesagt, wen er im Dunkeln gepackt hat?“ | Can; Lejla „An die Sekunden vor dem Scheppern erinnert er sich nicht.“ | in Ordnung |
| Joanna | R3 Ziel 2 → Tim „Was kam im Dunkeln an dir vorbei, und wann?“ (S. 4) | Tim Auslöser 2 nur vor allen | ⚠ P1R3-02 |
| Emine | keine Ausweichziele nötig | – | in Ordnung |

Weiter geprüft: Ausweichziele nennen keine fehlende Rolle (E22). Tims Heft lässt Zeynep in Wissen und Stufe 1 weg und
streicht den Auslöser „Zeyneps Karte“. Cans Auslöser (b) heißt „Geheimniskarte unter dem Zeugenstreifen im Steinbogen“.
Ahmet flüstert „‚Ich bin's, Ahmet.‘“ an die „Beine des Caterers“. Der Ausweichsatz für Impulse steht (00 S. 10).
Erzählerheft „Heute: 10 Personen“ ohne Gegenüberstellung und „Wechsel!“, wie MECH 1.3. Kein Leerlauf: Jede Rolle hat zwei
Aufträge je Runde. Die Detektivin hat zwei Aktionskarten mit Tipp.

---

## 5. 6 Personen (w)

Besetzt: Ahmet, Fatma, Olli, Can. Alle sechs Zeugen als Streifen. Die Detektivin hat alle sechs Aktionskarten (01 S. 6,
mit Tipp je Karte).

| Rolle | Ausweichziele (10-rollenheft-*.pdf S. 3) | Urteil |
|---|---|---|
| Ahmet | R1-2 WJ9 + Can; R2-2 FX3 + Fatma (Tasche); R3-2 DM3 + Olli | Antworten bei Can, Fatma, Olli vorhanden; FX3 und DM3 öffnen Ollis Auslöser (a)/(b) |
| Fatma | R1-2 RH3 + Olli; R2-2 Can; R3-2 XD3 + Can | in Ordnung |
| Olli | R1-2 Can („Bist du dafür durch den Ost-Saal gekommen?“); R2-2 Ahmet; R3-2 Can + Ortstermin DM3 nach dem Umdrehen | in Ordnung |
| Can | R1-2 Fatma; R2-2 WE3 + Ahmet; R3-2 Olli + FK3 nach dem Umdrehen | in Ordnung |

Auslöser bei 6 Personen auf Streifen umgestellt (Ahmet (b), Fatma (c), Olli (a)/(b), Can (b)). Erzählerheft S. 16
„Karten unter den Streifen“ mit Rundensperren. „Abschnitt b darfst du nach zwölf Minuten beenden, wenn alle Ziele gefragt
sind.“ verhindert Leerlauf bei nur vier Rollen. Kein Befund.

---

## 6. Detektivin/Detektiv und Erzähler

- **Detektivin (Teil 01):** S. 3 „Deine Aufgaben je Runde“ gibt je Runde ein Ziel, zwei Aufträge (Verhörstuhl oder
  Impuls), die Untersuchungen und in Runde 3 das Warten bei der Tipp-Runde. S. 6 passt sich der Besetzung an (20: Hinweis
  auf Windfang/Kaminsaal; 10/6: Streifen und Aktionskarten der fehlenden Zeugen). Gegenwehr-Karten sind erklärt. Kein
  Leerlauf.
- **Erzähler (Teil 00):** Je Runde vier Impulse (S. 9, 11, 12), Ausweichsatz und Domino-Frage (S. 10), Gegenüberstellung
  ab 14 Personen (S. 11/12), Herr Schneider und Maßtabelle (S. 15), Tipp-Runde und eigenes Bonus-Ziel (S. 13), Streifen-
  Tabelle bei 6 Personen (S. 16). Kein Leerlauf.
- **m-Stichprobe:** `diff` w/m bei 6, 10 und 20 Personen: Unterschiede nur in 00 (10–12 Zeilen: Anrede, Teileliste,
  Vorstellung, Auftrag), 01 (Kopf), 02 (Marker-Beschriftung), 90 (eine Zeile). Hefte, Karten und Fassungen sind gleich.

---

## 7. Befunde

### P1R3-01 · mittel · Flüster-Aufträge der Tandems in Runde 2 ohne Fassung für offene Karten

- **Besetzung:** 20 Personen (w), ebenso 18 Personen (w, eigener Satz `r3/p1-druck/p18`). Damir-Teil ab 14 Personen.
- **Datei und Seite:** `12-zusatzheft-serkan.pdf` S. 3 (Runde 2, Ziel 1) und S. 2 (Auslöser 2);
  `12-zusatzheft-wojtek.pdf` S. 2 (Runde 1, Ziel 2); `12-zusatzheft-hana.pdf` S. 2 (Auslöser 3); `12-zusatzheft-azra.pdf`
  S. 3 und `12-zusatzheft-aylin.pdf` S. 3 (Runde 1, Ziel 2 an Serkan); `12-zusatzheft-damir.pdf` S. 3 (Runde 2, Ziel 2);
  `12-zusatzheft-sibel.pdf` S. 2 und `12-zusatzheft-damir.pdf` S. 2 (Auslöser).
- **Zitat:** Serkan: „Ziel 1 · Hana: Sprich leise mit Hana: „Am Tisch fragen sie nach dem Tor und nach dem Kamin. Fragt
  dich jemand nach dem Papier: Halten wir dicht, oder sagen wir es beide?““ · Wojtek, Runde 1: „Hana, um halb zwölf hat
  der Kamin den ganzen Kaminsaal vollgequalmt. Warst du das? Und was hast du da hineingesteckt?“ Stell diese Frage vor
  allen. Ruf dafür den Erzähler.“ · Hana: „3. Sobald dich jemand vor allen fragt, was du in den Kamin gesteckt hast.“ ·
  Serkan: „2. Sobald Hanas Geheimniskarte offen auf dem Tisch liegt.“ · Damir: „Ziel 2 · Sibel: Sprich leise mit Sibel:
  „Wenn am Tisch die Vitrine Thema wird und jemand anderes für unseren Sprung geradestehen soll: Sagen wir es dann selbst,
  am Ende der Runde?““ · Sibel: „1. Sobald die Indizkarte FM9 oder YT4 offen auf dem Tisch liegt.“
- **Problem:** Die beiden Tandem-Aufträge in Runde 2 setzen voraus, dass die Tandem-Karten noch zu sind. Sie haben aber
  keine Fassung für offene Karten. Bei 18 bis 20 Personen löst Wojteks Pflichtfrage vor allen in Runde 1 Hanas Karte aus,
  und die zieht Serkans Karte nach. Zusätzlich fragen Azra und Aylin Serkan in Runde 1 nach dem Warum, das ist sein
  Auslöser 1 („zum zweiten Mal“). Tandem 1 ist offen, sobald FM9 oder YT4 (beide „ab Runde 1“) in Runde 1 gezogen wurden.
- **Wirkung am Tisch:** Serkan soll in der ersten Hälfte von Runde 2 mit Hana darüber flüstern, ob sie dichthalten. Beide
  Geheimnisse liegen da aber schon seit Runde 1 offen. Bis zur Gegenüberstellung bzw. zum „Wechsel!“ hat er nichts
  Sinnvolles zu tun (Leerlauf). Damir geht es in der zweiten Hälfte von Runde 2 genauso, wenn FM9 oder YT4 schon lag. Die
  Mini-Intrige ist dann erledigt, und beide Hefte geben keinen neuen Anstoß.
- **Vorschlag:** In `content/kammerspiel/schlosskeller/rollen/14-serkan.json` → `gespraechsauftraege` (runde 2, nr 1)
  `frage` zweiteilig fassen. Ziel bleibt Hana, die Antwort steht schon in Hanas „Nach dem Umdrehen“ (Handschuh):
  „**Hanas Karte offen:** „Hana, jetzt ist es raus. Du hast in der Kamin-Nische Ruß gewischt. Lag da außer deinem Brief
  noch etwas? Sag es allen.“\n**Hanas Karte zu:** **Sprich leise mit Hana:** „Am Tisch fragen sie … sagen wir es
  beide?““ (führt zu VP7 und zu Tugbas Handschuh-Satz).
  In `rollen/12-damir.json` (runde 2, nr 2) ebenso. Sibels „Nach dem Umdrehen“ trägt die Antwort und drückt auf Fatma:
  „**Sibels Karte offen:** „Sibel, jetzt ist unser Sprung raus. Sag allen, ob um neun die Münzschatulle noch in der
  Vitrine lag.“\n**Sibels Karte zu:** **Sprich leise mit Sibel:** „…(wie bisher)…““.

### P1R3-02 · mittel · Runde 3: Tim, Marek und Zeynep ohne Satz, wenn nicht vor allen gefragt wird

- **Besetzung:** 20 Personen (w): sieben Aufträge. 10 Personen (w): zwei Aufträge (Can → Tim, Joanna-Ausweichziel →
  Tim).
- **Datei und Seite:** Zeugenhefte: `10-rollenheft-tim.pdf` S. 2 (Tarnzeile) und S. 3 (Auslöser 2);
  `10-rollenheft-marek.pdf` S. 2/S. 3; `10-rollenheft-zeynep.pdf` S. 2/S. 3. Aufträge ohne „vor allen“:
  `10-rollenheft-can.pdf` S. 3 (R3 Ziel 2), `10-rollenheft-fatma.pdf` S. 3 (R3 Ziel 2), `10-rollenheft-tim.pdf` S. 4
  (R3 Ziel 2), `10-rollenheft-joanna.pdf` S. 3 (R3 Ziel 2), `12-zusatzheft-damir.pdf` S. 3 (R3 Ziel 1),
  `12-zusatzheft-hana.pdf` S. 3 (R3 Ziel 2), `12-zusatzheft-tugba.pdf` S. 3 (R3 Ziel 2). Bei 10 Personen:
  `10-rollenheft-can.pdf` S. 3 und `10-rollenheft-joanna.pdf` S. 4.
- **Zitat:** Tim S. 2: „was im Durchgang an dir vorbeikam (Runde 1 und 2) – „Ich hab mit dem Gesicht zur Wand den
  Hauptschalter gesucht. Mehr sag ich dazu jetzt nicht.““ · Tim S. 3: „2. Sobald dich in Runde 3 jemand vor allen fragt,
  was im Dunkeln an dir vorbeikam.“ · Can S. 3: „Ziel 2 · Tim: „Tim, du warst im Dunkeln im Durchgang. Was hast du gehört
  und gesehen, und in welcher Reihenfolge?““ · zum Vergleich Lejla S. 3: „… Sag es jetzt, vor allen.“ · Marek S. 2: „was
  du nach dem Knall an der Tür gesehen hast (Runde 1 und 2)“ · Tim S. 4: „Ziel 2 · Marek: „Marek, … Was hast du an der
  Vorratsraumtür gesehen, bevor es schepperte?““
- **Problem:** Die Tarnzeile von Tim, Marek und Zeynep gilt nur in Runde 1 und 2. Ihr Gesprächs-Auslöser in Runde 3 gilt
  nur „vor allen“. Für eine Runde-3-Frage im Gespräch zu zweit oder zu dritt steht in ihren Heften also nichts. Sieben
  Aufträge, die genau diesen Auslöser treffen sollen (Bibel ZG 3.7: „Mareks Gesprächs-Auslöser in Runde 3“), sagen nicht,
  dass die Frage vor allen zu stellen ist. Bei Lejla und Azra steht es dabei, bei Zeynep sinngemäß („Sag allen“).
- **Wirkung am Tisch:** Ab 12 Personen laufen die Gespräche in Grüppchen (R-02). Fragt Can, Fatma, Tim, Joanna, Damir,
  Hana oder Tugba in Runde 3 im Grüppchen, weiß der Zeuge nicht, ob er schweigen, ausweichen oder umdrehen soll. Lügen
  ist ihm verboten („Ich hab im Durchgang nichts gesehen.“). Der Auftrag verpufft, bis die Detektivin den Impuls I-3.1
  anfordert. Dasselbe gilt bei 10 Personen, wenn nicht der ganze Tisch zuhört.
- **Vorschlag:** Die sieben Aufträge wie bei Lejla, Wojtek und Joanna in Runde 1 ergänzen: In
  `rollen/04-can.json` (R3 nr 2), `02-fatma.json` (R3 nr 2), `07-tim.json` (R3 nr 2, auch `ausweich`),
  `08-joanna.json` (R3 nr 2, auch `ausweich`), `12-damir.json` (R3 nr 1), `13-hana.json` (R3 nr 2) und
  `18-tugba.json` (R3 nr 2) an die `frage` anhängen: „Stell diese Frage vor allen. Ruf dafür den Erzähler.“
  Zusätzlich in `07-tim.json`, `09-marek.json` und `10-zeynep.json` unter `stufe1.ausweichsaetze` eine Runde-3-Zeile
  aufnehmen, z. B. bei Tim: frage „was im Durchgang an dir vorbeikam (Runde 3, nicht vor allen)“, antwort „„Das sag ich
  nur einmal, und zwar vor allen. Ruf den Erzähler.““. Bei Marek und Zeynep gleich, mit ihrer eigenen Frage-Zeile.

### P1R3-03 · klein · „Dazu im Heft:“ in Mareks Heft

- **Besetzung:** 20 Personen (w). Gilt, sobald Marek gespielt wird (ab 11 Personen).
- **Datei und Seite:** `10-rollenheft-marek.pdf` S. 3, Runde 2, Ziel 1 (Bild `r3/p1-bilder/marek20-3.png`).
- **Zitat:** „Dazu im Heft: „Wenn er ausweicht, ist das ein guter Moment für deine Taschenkontrolle.““
- **Problem:** Der Arbeitsvermerk der Bibel (ZG 5.7 „Dazu im Heft“) ist in den Druck gerutscht. Der Tipp steht fett
  beschriftet und in Anführungszeichen, also wie ein Satz zum Vorsagen.
- **Wirkung am Tisch:** Marek stolpert über „im Heft“, obwohl er gerade im Heft liest. Liest er den Satz an Ahmet vor,
  kündigt er seine Taschenkontrolle an und nimmt ihr die Überraschung.
- **Vorschlag:** In `rollen/09-marek.json` → `gespraechsauftraege` (runde 2, nr 1) `frage` den Teil „\n**Dazu im Heft:**
  „Wenn er ausweicht, ist das ein guter Moment für deine Taschenkontrolle.““ ersetzen durch „\n**Tipp:** Weicht er aus,
  ist das ein guter Moment für deine Taschenkontrolle.“ (ohne Anführungszeichen).

---

## 8. Geprüft ohne Befund oder bewusst nicht gemeldet

- Graue Haltungszeile unter „Was dich heute antreibt“ (Zeugen und Zusatzrollen): gewollt, ZG x.1 „Haltung (wörtlich im
  Heft)“.
- Zeugen- und Zusatzaufträge ohne Nachschlag und ohne „Worauf du hinauswillst“: gewollt (ZG 0.6, P2-22). Das Ziel der
  Frage ergibt sich aus dem Wortlaut.
- Ollis fast unerreichbares Bonus-Ziel (K16), Damir, Wojtek und Tugba ohne eingehende Ziele (K20), selbsterfüllende
  Bonus-Ziele (M07): bekannt.
- Fest vorgegebene Punkte aus der Aufgabe (Wortbudget Tim, RN7-Länge, Schriftgrößen, 16 Seiten Erzählerheft, „Detektiv“
  als Rollenbegriff, Kartenseite der Einzeldatei, Tabelle in Teil 12, Rundennamen): nicht erneut gemeldet.
