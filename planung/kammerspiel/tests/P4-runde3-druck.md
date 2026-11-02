# Protokoll 4 – Skalierungs-Test am echten Druck (Runde 3)

Fall U4YRK „Spuk im Schlosskeller“, Kammerspiel, Täter Olli. Prüfung am gedruckten PDF-Satz (Stand Arbeitsbaum),
nicht am Bibel-Text. Im Repository wurde nichts geändert.

## 1. Grundlage und Vorgehen

**Maßstab:** AUFTRAG.md Abschnitt 3 B und 5 (Protokoll 4: „Funktioniert das Spiel fehlerfrei, wenn nur 6 Personen
spielen (über das Abwesenheits-Protokollblatt), wenn 10 Personen spielen und wenn bis zu 20 Personen spielen?“),
FALL-BIBEL MECH 1.1, 1.3, 4.6, 5.1–5.4, 8.3, 8.4, 9.4, 9.13, 9.14, 10.1–10.3, RK 1.5, RK x.11, ZG x.10/x.11,
ZR 0.2/0.7/x.12, RK 6.12; ENTSCHEIDUNGEN E6, E7, E18–E22. Bewusste Abweichungen (E1–E22, MECH 12a, WELT 0.3, 19.2)
und die im Auftrag genannten bekannten Punkte wurden nicht als Befund gewertet.

**Geprüfte Besetzungen (18 Sätze):**

| Quelle | Besetzungen |
|---|---|
| Hauptlauf `druck-r3/w`, `druck-r3/m` | 6 w, 6 m, 10 w, 10 m, 20 w, 20 m |
| selbst gesetzt (`r3/p4/w/pN`, `r3/p4/m/p8`) | 7 w, 8 m, 9 w, 11 w, 12 w, 13 w, 14 w, 15 w, 16 w, 17 w, 18 w, 19 w |

Gesetzt mit `dart run bin/party_druck.dart --personen N [--detektiv m] --aus …/r3/p4/<w|m>/pN`, danach alle PDFs mit
`pdftotext -layout` nach `…/r3/p4/t/<w|m>pN/` (6/10/20 als Verweis auf `druck-r3/text`). Bildprüfung mit
`pdftoppm -r 60` (Abwesenheitsblatt 6 w und 11 w, Markerbogen 20 w, Teileliste 13 w, Bonus-Tabelle 19 w), Bilder unter
`…/r3/p4/img/`. Prüfskripte unter `…/r3/p4/skripte/` (`zaehle.py`, `fehlnamen.py`, `ziele.py`, `umschr.py`);
Zähltabelle unter `…/r3/p4/tabelle.md`. `git status` blieb leer.

**Wie geprüft (je Besetzung, maschinell und stichprobenartig gelesen):**

1. Teileliste in Teil 00 S. 2 gegen das wirklich Gedruckte: Marker-Plättchen auf dem Markerbogen (Namen gezählt),
   Tipp-Zettel (Köpfe „Tipp-Zettel Name:“ gezählt), Zeugenstreifen (Etiketten gezählt), Rollenhefte und Fassungen
   (Namen), Zusatzhefte (Dateien und Solo-Abschnitt), Geheimnis- und Aktionskarten in Teil 20 (Köpfe gezählt, „heute beim
   Detektiv“ gezählt und die Aktionen gegen MECH 4.6 abgeglichen), Seitenzahlen gegen MECH 10.1.
2. Abwesenheitsblatt: nur bei 6–11; je fehlendem Zeugen Streifen + Geheimniskarte (Vorderseite „Heute spielt diese Rolle
   niemand“) + Aktionskarte „heute beim Detektiv“; nichts davon für besetzte Zeugen; Reihenfolge im Bild.
3. Namen fehlender Rollen: Suche nach allen Namen der heute fehlenden Rollen (5–18) in allen Teilen; erlaubte Stellen
   (Abwesenheitsblatt, Geheimniskarten fehlender Zeugen, Joannas Liste, Teil 90 für Zeugen 5–10, Skalierungsübersicht und
   „Karten unter den Streifen“ im Erzählerheft) getrennt. Zusätzlich Suche nach Umschreibungen fehlender Rollen
   („der Caterer“, „deine Schwester“ …) in Sätzen mit „Frag …“.
4. Ziele: alle „Ziel 1/2“-Zeilen der Verdächtigen, Zeugen und Zusatzrollen je Besetzung; Ausweichziele gegen RK x.11.
5. Zusatzrollen: Tandem-Kasten (E21), Solo-Abschnitt nur bei ungerader Zahl und nur beim letzten Platz, Solo-Fassung der
   Geheimniskarte, Hinweisseite bei 6–12, Gegenüberstellung ab 14 (sieben Minuten ab 18).
6. Erzählerheft: Kopf „N Personen: R Rollen“, Ablauf mit Minuten (Interpolation, Summe nachgerechnet), Vorstellungsrunde
   (gefragte Rollen, Lacher fehlender Zusatzrollen, Abschlusssatz), Skalierung „Heute“, „Kleine Runden“ 6–8,
   Abschnitte d/e mit oder ohne Streifen, Seite 16 nur 6–11, Bonus-Tabelle des Erzählers (Rollen, drei Viertel).
7. Auflösungsheft: „Die Rollen am Tisch“, Bonus-Ziele, Pflicht-Auslöser nur gespielter Rollen, Streifen-Tabelle nur
   fehlender Zeugen, Zeitleiste/Rückblende mit Zusatzrollen nur, wenn gespielt (MECH 8.3), M1-Stichwort „bei Damir“ nur ab 14.
8. Querschnitt: „Was alle wissen“ je Besetzung in allen Heften gleich (inkl. Dankeskarten-Satz ab 13), Einzeldateien
   gleich dem Sammelheft, `kammerspiel-alles.pdf` = Summe der Teile (6/10/20: 87/105/144 Seiten).

## 2. Zähltabelle (Teileliste gegen Druck)

| Besetzung | Rollen | Teileliste 02: Marker / Tipp-Zettel / Streifen | gedruckt: Marker / Tipp-Zettel / Streifen | Teileliste 20: GK / AK / davon Detektiv | gedruckt: GK / AK / „heute beim Detektiv“ | Teileliste 12 / gedruckte Zusatzhefte / Solo | Seiten 00·01·02·10·11·12·20·90 |
|---|---|---|---|---|---|---|---|
| 6 w | 4 | 12 / 5 / 6 | 12 / 5 / 6 | 10 / 10 / 6 | 10 / 10 / 6 | Hinweisseite / 0 / – | 16·6·6·16·16·1·17·9 |
| 6 m | 4 | 12 / 5 / 6 | 12 / 5 / 6 | 10 / 10 / 6 | 10 / 10 / 6 | Hinweisseite / 0 / – | 16·6·6·16·16·1·17·9 |
| 7 w | 5 | 14 / 6 / 5 | 14 / 6 / 5 | 10 / 10 / 5 | 10 / 10 / 5 | Hinweisseite / 0 / – | 16·6·6·20·16·1·17·9 |
| 8 m | 6 | 16 / 7 / 4 | 16 / 7 / 4 | 10 / 10 / 4 | 10 / 10 / 4 | Hinweisseite / 0 / – | 16·6·6·24·16·1·17·9 |
| 9 w | 7 | 18 / 8 / 3 | 18 / 8 / 3 | 10 / 10 / 3 | 10 / 10 / 3 | Hinweisseite / 0 / – | 16·6·6·28·16·1·17·10 |
| 10 w | 8 | 20 / 9 / 2 | 20 / 9 / 2 | 10 / 10 / 2 | 10 / 10 / 2 | Hinweisseite / 0 / – | 16·6·7·32·16·1·17·10 |
| 10 m | 8 | 20 / 9 / 2 | 20 / 9 / 2 | 10 / 10 / 2 | 10 / 10 / 2 | Hinweisseite / 0 / – | 16·6·7·32·16·1·17·10 |
| 11 w | 9 | 22 / 10 / 1 | 22 / 10 / 1 | 10 / 10 / 1 | 10 / 10 / 1 | Hinweisseite / 0 / – | 16·6·7·36·16·1·17·10 |
| 12 w | 10 | 24 / 11 / – | 24 / 11 / – | 10 / 10 / – | 10 / 10 / – | Hinweisseite / 0 / – | 16·6·6·40·16·1·17·10 |
| 13 w | 11 | 26 / 12 / – | 26 / 12 / – | 11 / 11 / – | 11 / 11 / – | 1 (Sibel) / 1 / Sibel | 16·6·6·40·16·3·18·11 |
| 14 w | 12 | 28 / 13 / – | 28 / 13 / – | 12 / 12 / – | 12 / 12 / – | 2 (Sibel, Damir) / 2 / – | 16·6·7·40·16·6·18·11 |
| 15 w | 13 | 30 / 14 / – | 30 / 14 / – | 13 / 13 / – | 13 / 13 / – | 3 (… Hana) / 3 / Hana | 16·6·7·40·16·9·19·11 |
| 16 w | 14 | 32 / 15 / – | 32 / 15 / – | 14 / 14 / – | 14 / 14 / – | 4 (… Serkan) / 4 / – | 16·6·7·40·16·12·19·11 |
| 17 w | 15 | 34 / 16 / – | 34 / 16 / – | 15 / 15 / – | 15 / 15 / – | 5 (… Azra) / 5 / Azra | 16·6·7·40·16·15·20·11 |
| 18 w | 16 | 36 / 17 / – | 36 / 17 / – | 16 / 16 / – | 16 / 16 / – | 6 (… Wojtek) / 6 / – | 16·6·8·40·16·18·20·12 |
| 19 w | 17 | 38 / 18 / – | 38 / 18 / – | 17 / 17 / – | 17 / 17 / – | 7 (… Aylin) / 7 / Aylin | 16·6·8·40·16·21·22·12 |
| 20 w | 18 | 40 / 19 / – | 40 / 19 / – | 18 / 18 / – | 18 / 18 / – | 8 (… Tugba) / 8 / – | 16·6·8·40·16·24·22·12 |
| 20 m | 18 | 40 / 19 / – | 40 / 19 / – | 18 / 18 / – | 18 / 18 / – | 8 (… Tugba) / 8 / – | 16·6·8·40·16·24·22·12 |

Marker = 2 je Rolle + 2 Detektiv(in) + 2 Herr Schneider; Tipp-Zettel = Personen − 1 (Erzähler ja, Detektiv nein, MECH 12a
A:116); Indizkarten immer 19. Seitenzahlen stimmen mit MECH 10.1 (6/12/20: 02 = 6/6/8, 12 = 1/1/24, 20 = 17/17/22,
90 = 9/10/12; 00 immer 16 nach E18).

## 3. Ergebnis je Prüfpunkt

### 3.1 Teileliste gegen Druck – erfüllt (ein Schönheitsfehler)
Alle Zahlen und Namen in Teil 00 S. 2 stimmen in allen 18 Sätzen mit dem Gedruckten überein (Tabelle 2), auch
Detektiv/Detektivin in der Beschriftung (m: „für den Detektiv“, „davon 4 für den Detektiv“). Rollenhefte nennen genau die
besetzten Rollen 1–10, Fassungen immer die vier. Je besetzter Rolle liegt genau eine Einzeldatei vor (10-rollenheft-…,
12-zusatzheft-…), inhaltlich gleich dem Sammelheft (Zeilenvergleich bei 6, 13, 19). „Drucken, schneiden, falten“ und
„Was an wen geht“ nennen Abwesenheitsblatt und Aktionskarten fehlender Zeugen nur bei 6–11.
Einziger Mangel: bei 13 Personen „1 Zusatzhefte: Sibel“ (Befund P4-01).

### 3.2 Abwesenheitsblatt, Streifen, Karten beim Detektiv – erfüllt
- Blatt nur bei 6–11 (6, 5, 4, 3, 2, 1 Streifen); bei 12–20 fehlt es samt Schneide-Anweisung, Lageplan-Abschnitt und
  Erzählerheft-Seite 16 (Inhaltsverzeichnis ohne „Karten unter den Streifen“).
- Streifen in Platzreihenfolge (Bild 6 w: Lejla, Emine / Tim, Joanna / Marek, Zeynep; 11 w: nur Zeynep), Etiketten und
  Protokolle wörtlich nach ZG x.11.
- Geheimniskarten: bei 6–12 immer 10, Vorderseite „Heute spielt diese Rolle niemand. Der Erzähler dreht sie um.“ genau
  für die fehlenden Zeugen, sonst die normale Vorderseite; ab 13 je Zusatzrolle eine mehr, keine für fehlende Zusatzrollen.
- Aktionskarten „heute beim Detektiv“ exakt nach MECH 4.6 (6: Krankenbesuch … Gelbe Karte; 7: ab Kreuzverhör; 8: ab
  Stirnlampe; 9: ab Zeitstempel; 10: Taschenkontrolle, Gelbe Karte; 11: Gelbe Karte; ab 12 keine). Teil 01 „Heute bei N
  Personen“ listet genau diese Karten mit Tipp; bei 6 zusätzlich „Heute fehlen alle sechs Zeugen …“.
- Erzählerheft S. 16 „Karten unter den Streifen“ druckt nur die Zeilen der heute fehlenden Zeugen.
- Teil 90 „Zeugenstreifen neben dem Lageplan“ nur für fehlende Zeugen, „Pflicht-Auslöser“ nur für gespielte Rollen.

### 3.3 Keine fehlenden Rollen als handelnde Person; Ziele – erfüllt (zwei kleine Restverweise)
- In Teil 01, 10, 11 und 12 steht in keiner Besetzung der Name einer heute fehlenden Rolle; einzige Fundstelle ist Joannas
  Notiz (W-21, erlaubt) bei 10 und 11. Umschreibungen nach RK 1.5 greifen überall („der Caterer“, „deine beste Freundin“,
  „dein Kumpel aus der Berufsschule“, „die Fotografin des Abends“, „ein Gast mit einer großen Teekanne“, „ein Gast“).
- Teil 20: Namen fehlender Zeugen nur auf deren eigenen Geheimniskarten (Tim auf Mareks und Zeyneps Karte bei 6–8:
  Geheimniskarten fehlender Zeugen, Domino-Frage mit Ausweichsatz, zulässig).
- Teil 00: Namen fehlender Rollen nur in der Skalierungsübersicht und auf S. 16.
- Alle Ziel-1/Ziel-2-Zeilen der Verdächtigen zeigen auf besetzte Rollen oder auf das Ausweichziel nach RK x.11
  (z. B. Ahmet R1 Z2 bis 10 Personen Ortstermin „hinter der Theke am Ostende“, ab 11 Marek; R3 Z2 bei 6 Ortstermin
  „rechter Buffettisch“, ab 7 Lejla; Olli R1 Z2 bei 6–8 Can, ab 9 Tim; Can R3 Z2 bei 6–8 „Frag Olli …“, ab 9 Tim).
  Zeugen- und Zusatzrollen-Ziele nennen nur kleinere Plätze und sind damit immer besetzt; der Satz „Fehlt dein Ziel …“
  in den Zusatzheften ist überall vorhanden.
- Pflicht-Auslöser passen sich an (Olli (a)/(b) über Streifen bei fehlender Joanna/Lejla; Ahmet (b), Fatma (c), Can (b) über
  „Geheimniskarte unter dem Zeugenstreifen …“; Tim ohne Zeynep-Auslöser bei 9–11).
- Restverweise: Ollis Auslöser (b) erwähnt bei 7–20 einen Lejla-Streifen, den es dann nicht gibt (P4-03); Cans „Frag sie“
  auf die bei 6–11 fehlende Schwester und „Frag die, die im Durchgang waren“ bei 6–8 (P4-04).

### 3.4 Zusatzrollen – erfüllt
Tandem-Kasten in jedem Zusatzheft (E21), bei fehlendem Partner mit „ein Gast“. Solo-Abschnitt genau bei 13 (Sibel),
15 (Hana), 17 (Azra), 19 (Aylin), bei geraden Zahlen nirgends. Die Solo-Geheimniskarten enden wie angekündigt (Sibel:
Münzschatulle; Hana: alter Handschuh; Azra: Tims Satz von 20:15), mit Partner auf den Partner-Satz. Pflicht-Auslöser der
Tandems nennen den Partner nur, wenn er spielt (Sibel/Damir bei 14 gegenüber 13). Hinweisseite „Heute ohne Zusatzrollen.
Zusatzrollen gibt es ab dreizehn Personen.“ bei 6–12. Gegenüberstellung nur ab 14 (Ablauf b, eigener Abschnitt Runde 2
und 3, Teil 01), „In fünf Minuten“ bei 14–17, „In sieben Minuten“ ab 18. „Die Rollen am Tisch“ liest ab 14 jede Person
selbst (Teil 00 und 90 gleich).

### 3.5 Erzählerheft – erfüllt (ein Schönheitsfehler)
Kopf „N Personen: R Rollen, Detektiv und Erzähler“ stimmt. Ablauf-Minuten interpoliert (Aufbau 10–12, Vorstellungsrunde
6/7/8/9/9/10/11/12/13/13/14/15/16/16/17, Lageplan 5–8, Tipp-Runde 4–6, Auflösung 12–15), Summen nachgerechnet
(155 … 176, MECH 1.1 an den Stützstellen exakt). Vorstellungsrunde fragt genau die besetzten Rollen in Platzfolge, dann
den Detektiv; Lacher Sibel/Hana nur, wenn sie fehlen; Abschlusssatz „Wer heute ohne Spielerin oder Spieler dabei ist …“ bei
6–19, nicht bei 20. „Kleine Runden“ nur 6–8. Skalierung „Heute“ nach MECH 9.13 (6–8 Ortstermine früh, 10 Standardrunde mit
zwei Streifen, 12 Verhörstuhl leise, ab 14 Wechsel/Gegenüberstellung mit fünf bzw. sieben Minuten). Abschnitte d und e
nennen Streifen nur bei 6–11. Bonus-Tabelle des Erzählers listet die gespielten Rollen, „drei Viertel“ korrekt aufgerundet
(3, 4, 5, 6, 6, 7, 8, 9, 9, 10, 11, 12, 12, 13, 14). „Was alle wissen“ je Besetzung in allen Heften identisch,
Sibel/Azra/Joanna nur mit Namen, wenn gespielt, Dankeskarten-Satz ab 13 überall.
Mangel: Ablauf-Schritt 6 heißt bei 12–20 weiter „… Zeugenstreifen auslegen“ (P4-02).

### 3.6 Auflösungsheft – erfüllt
„Die Rollen am Tisch“, Bonus-Ziele und Pflicht-Auslöser nur für gespielte Rollen (+ Erzähler). Zeitleiste und Rückblende:
Damir als „Ein Gast bringt die große Teekanne …“ / „ein Gast kauert am Ostende“ bis 13, mit Namen ab 14; „Sibel sieht das
leuchtende Gesicht“ ab 13, „Hana und Sibel“ ab 15; keine weitere Zusatzrolle; Kernsätze ohne Zusatzrollen. M1-Stichwort
„oder ‚bei Damir‘“ nur ab 14. Seitenzahlen 9/10/11/12 wie MECH 8.4/10.1.

### 3.7 Weitere Beobachtungen ohne Befund
- Der Ausweichsatz (Teil 00 S. 10, „Was sie weiß, liegt vielleicht als Zeugenstreifen neben dem Lageplan …“) und die
  Hinweise „Wenn die genannte Person fehlt: Ausweichsatz“ stehen auch bei 12–20, wo es keine Streifen gibt. Das ist
  Bibel-Wortlaut (MECH 9.9 „für jede Besetzung“) und am Tisch kaum je ausgelöst; als Teil von P4-02 mit Vorschlag erwähnt.
- Statische Regeltexte (Indizkarten-Ortstermine „Liegt für diesen Ort ein Zeugenstreifen …“, Teil 01 Untersuchungsregel 4,
  Zeitstempel-Karte) erwähnen Streifen auch bei 12–20; als feste Regeln unschädlich.
- Nebenfund außerhalb der Skalierung: In Mareks Heft (ab 11 Personen) steht die Bibel-Bauanweisung „Dazu im Heft:“ als
  gedrucktes Etikett (P4-05).

## 4. Befunde

### P4-01 (klein) – „1 Zusatzhefte“
- **Besetzung:** 13 w (jede 13er-Besetzung).
- **Ort:** 00-erzaehlerheft.pdf, Seite 2, Teileliste, Zeile 12.
- **Zitat:** „12 Zusatzhefte 12-zusatzrollen.pdf 1 Zusatzhefte: Sibel“
- **Problem:** Plural bei genau einem Heft.
- **Wirkung:** Schönheitsfehler in der ersten Tabelle, die der Erzähler liest.
- **Vorschlag:** `content/kammerspiel/schlosskeller/ui/00.json`, Schlüssel `teileliste.12`:
  `"{ab:14|{anzahl} Zusatzhefte: {namen}|1 Zusatzheft: {namen}}"` (der Schlüssel gilt nur ab 13, unter 14 also genau ein
  Heft); alternativ in `erzaehlerheft.dart` Z. 230 bei `b.zusatzrollen.length == 1` einen Einzahl-Schlüssel
  `teileliste.12.eins` = „1 Zusatzheft: {namen}“ wählen.

### P4-02 (klein) – Zeugenstreifen im Ablauf ab 12 Personen
- **Besetzung:** 12 w bis 20 w/m.
- **Ort:** 00-erzaehlerheft.pdf, Seite 3, „Ablauf mit Minuten“, Schritt 6 (dazu S. 10 Ausweichsatz).
- **Zitat:** „6 Lageplan-Führung, Marker setzen, Zeugenstreifen auslegen 7“ (12 w; bei 20 w „… 8“)
- **Problem:** Ab 12 Personen gibt es keine Streifen; derselbe Generator streicht sie auf derselben Seite in Abschnitt d
  und e und in „Was an wen geht“, nur Schritt 6 nennt sie weiter.
- **Wirkung:** Der Erzähler sucht beim Aufbau nach einem Abwesenheitsblatt, das es nicht gibt; kleiner Widerspruch zu
  „Alle Hauptrollen sind besetzt, Zeugenstreifen gibt es nicht“ (S. 16).
- **Vorschlag:** `content/kammerspiel/schlosskeller/erzaehlerheft.json`, `ablauf[schritt 6].name`:
  `"Lageplan-Führung, Marker setzen{ab:12||, Zeugenstreifen auslegen}"` (falls `ablauf[].name` noch nicht durch die
  Platzhalter-Auflösung läuft: in `erzaehlerheft.dart` Z. 290 `e.ablauf[i].name` über `KammerBesetzung.text` auflösen).
  Optional ebenso `ausweichsatz`: `"Diese Person ist heute nicht am Tisch.{ab:12|| Was sie weiß, liegt vielleicht als
  Zeugenstreifen neben dem Lageplan. Detektiv, eine Untersuchung an ihrem Ort kann es aufdecken.}"`.

### P4-03 (klein) – Ollis Auslöser (b) nennt einen Lejla-Streifen, wenn Lejla spielt
- **Besetzung:** 7 w bis 20 w/m (alle Besetzungen mit Lejla).
- **Ort:** 10-rollenheft-olli.pdf, Seite 3, „Stufe 2“, Auslöser (b); gleich in 90-aufloesung-versiegelt.pdf, „Zum
  Nachlesen“ (12 w: Seite 9).
- **Zitat:** „(b) Sobald Lejla vor allen sagt oder ihr Zeugenstreifen zeigt, dass du erst nach dem Scheppern zu ihr an den
  rechten Buffettisch kamst.“
- **Problem:** Wenn Lejla gespielt wird, gibt es keinen Lejla-Streifen; der zweite Teil des Auslösers ist leer und deutet
  ein Bauteil an, das nicht auf dem Tisch liegt.
- **Wirkung:** Olli (oder wer im Auflösungsheft nachliest) sucht einen Streifen am rechten Buffet; geringe Verwirrung, die
  Spielmechanik bleibt intakt.
- **Vorschlag:** `content/kammerspiel/schlosskeller/rollen/03-olli.json`, `stufe2.ausloeser[1]`, Zweig „Lejla spielt“:
  `"Sobald Lejla vor allen sagt, dass du erst nach dem Scheppern zu ihr an den rechten Buffettisch kamst."` (Zweig ohne
  Lejla unverändert; Bibel RK 4.7 entsprechend nachziehen).

### P4-04 (klein) – Cans Verweise auf Personen, die heute fehlen
- **Besetzung:** 6 w/m bis 11 w („Frag sie“), 6 w/m bis 8 m („im Durchgang“).
- **Ort:** 10-rollenheft-can.pdf, Seite 2, Stufe-1-Tabelle; 11-fassungen.pdf, YW4 Seite 3 („Wenn es eng wird“).
- **Zitat:** „Im Steinbogen hab ich meine Schwester gestreift. Frag sie.“ (YW4, 6 w) · „Wir haben vorher zusammen Gebäck
  gegessen. Frag sie selbst.“ (Heft, 6 w) · „Frag die, die im Durchgang waren.“ (YW4, 6 w)
- **Problem:** Die Schwester (Zeynep) spielt bei 6–11 nicht, im Durchgang standen bei 6–8 nur nicht gespielte Zeugen; der
  Fragende wird an niemanden am Tisch verwiesen.
- **Wirkung:** Kurzer Leerlauf: Wer der Aufforderung folgt, findet keine Person; der Weg über Zeitstempel/FK3/AD3 bleibt
  offen, wird aber nicht genannt.
- **Vorschlag:** `content/kammerspiel/schlosskeller/rollen/04-can.json`:
  `stufe1.ausweichsaetze` („Wo war {rolle:zeynep|deine Schwester}?“) → `„Im Kaminsaal, glaub ich. Wir haben vorher zusammen
  Gebäck gegessen.{wenn:zeynep| Frag sie selbst.}“`; `fassung.wennEsEngWird[3]` → `„Im Steinbogen hab ich
  {rolle:zeynep|meine Schwester} gestreift.{wenn:zeynep| Frag sie.| Detektiv, schau dir den Steinbogen an.}“`;
  `fassung.wennEsEngWird[2]` → `„Keine Ahnung. Im Turm hört man nichts.{wenn:tim| Frag die, die im Durchgang waren.|
  Detektiv, schau dir den Durchgang an.}“` (Längenbudget RK 7.7 beachten).

### P4-05 (klein, Nebenfund, nicht skalierungsbedingt) – Bauanweisung im Marek-Heft
- **Besetzung:** 11 w bis 20 w/m (alle mit Marek).
- **Ort:** 10-rollenheft-marek.pdf, Seite 4, Runde 2 Ziel 1.
- **Zitat:** „Dazu im Heft: „Wenn er ausweicht, ist das ein guter Moment für deine Taschenkontrolle.““
- **Problem:** Das Bibel-Etikett „Dazu im Heft:“ (ZG 5.7, Spaltentext) ist mitgedruckt; mit den Anführungszeichen wirkt der
  Tipp wie ein Satz zum Vorlesen.
- **Wirkung:** Marek liest den Tipp womöglich laut vor und kündigt Ahmet seine Taschenkontrolle an.
- **Vorschlag:** `content/kammerspiel/schlosskeller/rollen/09-marek.json`, Zeile 217 (`frage` des Ziels Runde 2 Nr. 1):
  `"…Wo ist das Geld jetzt?“\n**Tipp:** Wenn er ausweicht, ist das ein guter Moment für deine Taschenkontrolle."`

## 5. Zusammenfassung je Besetzung

| Besetzung | spielbar | Befunde |
|---|---|---|
| 6 w | ja | P4-04 |
| 6 m | ja | P4-04 |
| 7 w | ja | P4-03, P4-04 |
| 8 m | ja | P4-03, P4-04 |
| 9 w | ja | P4-03, P4-04 („Frag sie“) |
| 10 w | ja | P4-03, P4-04 („Frag sie“) |
| 10 m | ja | P4-03, P4-04 („Frag sie“) |
| 11 w | ja | P4-03, P4-04 („Frag sie“), P4-05 |
| 12 w | ja | P4-02, P4-03, P4-05 |
| 13 w | ja | P4-01, P4-02, P4-03, P4-05 |
| 14 w | ja | P4-02, P4-03, P4-05 |
| 15 w | ja | P4-02, P4-03, P4-05 |
| 16 w | ja | P4-02, P4-03, P4-05 |
| 17 w | ja | P4-02, P4-03, P4-05 |
| 18 w | ja | P4-02, P4-03, P4-05 |
| 19 w | ja | P4-02, P4-03, P4-05 |
| 20 w | ja | P4-02, P4-03, P4-05 |
| 20 m | ja | P4-02, P4-03, P4-05 |

**Gesamturteil:** bestanden mit Befunden. Das Zwiebelprinzip funktioniert am Druck von 6 bis 20 Personen: Teileliste und
gedruckte Stücke stimmen in allen 18 Sätzen überein, Abwesenheitsblatt, Streifen, Karten unter den Streifen und
Aktionskarten beim Detektiv erscheinen genau bei 6–11 und genau für die fehlenden Zeugen, keine fehlende Rolle tritt mit
Namen auf, jedes Ziel trifft eine besetzte Rolle oder ein gedrucktes Ausweichziel, Tandems/Solo/Hinweisseite/
Gegenüberstellung schalten an den richtigen Schwellen, Erzählerheft und Auflösungsheft passen zur Besetzung. Es bleiben
fünf kleine Schönheits- und Verweisfehler, keiner blockiert das Spiel.
