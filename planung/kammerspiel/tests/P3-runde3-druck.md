# Protokoll 3 – Zeitstrahl- und Orts-Konsistenz am echten Druck (Runde 3)

Stand 2026-11-02. Geprüft wurde der Druck, so wie ihn Spielerinnen und Spieler in die Hand bekommen
(Arbeitsbaum, CLI `party_druck.dart`). Im Repository wurde nichts geändert (`git status` sauber). Eigene Dateien nur im
Arbeitsordner der Prüfung außerhalb des Repositorys (Werkzeuge und Zwischenstände in `r3/p3/`).

**Ergebnis: bestanden mit Befunden.** Alle Uhrzeiten des Auftrags (A 5.3) stehen in allen Teilen gleich, auch in Worten; kein
Teil nennt für dasselbe Ereignis eine andere Zeit. Lageplan, Maßtabelle, Kartenabstände und Wege passen zu den Zeiten
(30 s zwischen Knall und Scheppern, kein Weg zu schnell). Keine zwei Rollen widersprechen sich über Ort oder Zeit derselben
Person, außer in den von der Bibel gewollten Lügen der vier Verdächtigen. Drei kleine Befunde: ein Szenenort mit zwei
Bezeichnungen (Beleg „beim Einlass“ gegen „am Jackenständer im Ost-Saal“), eine Ausweichfrage Ollis mit unmöglichem Weg
(6–8 Personen) und zwei Wandbänke, die in den Heften vorkommen, auf dem Lageplan aber fehlen. Kein Blocker, kein mittlerer Befund.

---

## 1. Material

| Satz | Quelle | Inhalt |
|---|---|---|
| 6, 10, 20 Personen, Detektivin (w) | `druck-r3/w/…`, Text `druck-r3/text/w/…` | alle acht Teile, Einzeldateien je Rolle |
| 6, 10, 20 Personen, Detektiv (m) | `druck-r3/m/…`, Text `druck-r3/text/m/…` | dto. |
| alles in einer Datei, 6/10/20 (w) | `druck-r3/alles-w/…/kammerspiel-alles.pdf` | 87 / 105 / 144 Seiten = Summe der Teile; Uhrzeiten-Bestand identisch mit den Teilen |
| selbst gesetzt: 7, 8, 9, 11, 13, 15, 17, 19 Personen (w) | `r3/p3/druck/pN` | für Ersatzsätze (fehlende Zeugen) und Solo-Tandems (Sibel, Hana, Azra, Aylin allein) |

w gegen m: Alle Uhrzeiten (Treffer je Datei und Seite) sind identisch; die Texte unterscheiden sich nur in Teil 00, 01, 02
und 90 bei Anrede/Artikel der Detektivin (E20). Der Lageplan (Teil 02, Blatt A und B) ist bei 6, 10, 20 Personen und bei w/m
pixelgleich (Bildvergleich bei 40 dpi, Differenz leer).

## 2. Methode

1. **Text gezogen:** zusätzlich zu den gelieferten `pdftotext -layout`-Dateien jede PDF auch in Lesereihenfolge
   (`pdftotext` ohne `-layout`) nach `r3/p3/raw/{w,m}/pN/` (Seiten durch Seitenvorschub getrennt, Seitenzahl je Treffer).
2. **Uhrzeiten maschinell:** `r3/p3/zeiten.py` zieht jede Ziffernzeit (H:MM und H:MM:SS), jede Wortzeit („drei vor zwölf“,
   „halb sieben“, „um elf“, „Viertel nach acht“, „zwölf nach zwölf“ …), „Mitternacht“ und Zeitspannen aus allen 132 Dateien
   (w und m, 6/10/20): 8 186 Treffer, mit Datei, Seite und Satz. `r3/p3/wort.py` gruppiert Wortzeiten nach Satz, `matrix.py`
   baut die Tabellen Zeit × Teil und Ort × Teil.
3. **Sichtung:** Erzählerheft, Detektivbogen, Lageplan, alle zehn Rollenhefte, alle acht Zusatzhefte, Karten, Fassungen und
   Auflösungsheft (20 Personen) ganz gelesen; für 6 und 10 Personen (und 7, 8, 9, 11, 13, 15, 17, 19) die Abweichungen gegen
   20 Personen satzweise per `diff` gesichtet.
4. **Orte:** Zählung aller Raum-, Zonen- und Gegenstandsnamen samt Varianten über alle Drucke (Tabelle 6); Feldnamen auf
   Blatt B gegen jede Markerzeile der Hefte und die Etiketten der Zeugenstreifen.
5. **Lageplan vermessen:** Blatt A bei 200 dpi gerendert, alle Gegenstandspunkte maschinell gefunden (`r3/p3/dots.py`) und
   über das Kästchenraster (66,95 px = 1 m) in Bibel-Koordinaten (WELT 2.3) umgerechnet; Ausschnitte von Durchgang und
   Turmgang sowie die Mini-Karten auf Blatt B angesehen.
6. **Abstände und Wege:** Maßtabelle (Teil 00 S. 15), alle Meterangaben in Karten und Heften und die Sekunden-Zeitleiste
   (Teil 90 S. 6–7) gegen die gemessenen Koordinaten und die Tempo-Regel (WELT 2.7: dunkel ≤ 1 m/s, Licht 1,5 m/s, rennen 2,5 m/s).
7. **Personen gekreuzt:** je Person jede Orts- und Zeitangabe aus allen Teilen in eine Zeile (Tabelle 9).

Maßstab: AUFTRAG 5 (Protokoll 3 wörtlich), FALL-BIBEL WELT 0.2/0.3, 2.x, 3.x, 4.x; angenommene Abweichungen (E1–E22,
MECH 12a, K-01 bis K-25, 19.2) und die ausdrücklich bekannten Punkte wurden nicht gemeldet.

---

## 3. Zeit × Quelle

### 3.1 Die Auftrags-Zeiten (A 5.3) – Wortlaut je Teil

| Zeit (Auftrag) | Teil 00 Erzählerheft | Teil 01 Detektivbogen | Teil 02 Lageplan/Streifen | Teil 10 Rollenhefte | Teil 11 Fassungen | Teil 12 Zusatzhefte | Teil 20 Karten | Teil 90 Auflösung | Ergebnis |
|---|---|---|---|---|---|---|---|---|---|
| 18:30 Lieferung/Bogentür | – | – | – | Tim, Marek „18:30“; Olli, Marek „um halb sieben“ | RN7 „18:30 Mit Tim trägst du …“ | – | – | „Um halb sieben tragen Olli und Tim …“ | gleich |
| (18:35 Schramme, A:41) | – | – | – | Olli Stufe 2, Tim „18:35“ | RN7 „18:35“ | – | Olli-Karte „Um 18:35 Uhr“, Vermerk „um 18:35“ | „Fünf Minuten später schrammt Olli“ | gleich |
| 20:15 Vorratsraum | „Viertel nach acht“ (Olli-Frage) | „20:15 Uhr“ (Was alle wissen) | – | „20:15 Uhr“ (Was alle wissen), Tim | YW4 „20:15“ | Azra, Wojtek, Sibel, Hana „20:15“ / „Viertel nach acht“ | Wojtek-, Azra-Karte „20:15 Uhr“ | Wojtek „Viertel nach acht“ | gleich |
| 21:00 Rüstung/Vitrine | „21:00 Uhr“, „seit neun Uhr“ | „21:00 Uhr“ | – | „21:00 Uhr“ | JM3 „21:00“ | Sibel, Damir „21:00“ / „um neun“ | Sibel-, Damir-Karte „21:00 Uhr“ | Sibel „um neun“ | gleich |
| 23:00 Streit Olli/Schneider | „23:00 Uhr … An der Theke wird Herr Schneider laut“ | dto. | – | Tim „23:00“, Olli Stufe 2 „Um 23:00 Uhr drohte er“, „um elf“ | RN7 „23:00 Vor der Theke streitet ihr laut“, WW4 „23:00“ | Sibel, Damir, Azra, Wojtek, Aylin, Tugba „23:00“ / „um elf“ | Emine-Karte „Um elf“ | „Um elf Uhr droht er Olli laut“ | gleich |
| 23:30 Kaminqualm | „23:30 Uhr“, „halb zwölf“ (Ersatz) | „23:30 Uhr“ | – | „23:30 Uhr“ | JM3, YW4 „23:30“ | Hana, Serkan, Aylin „23:30“ / „halb zwölf“ | Serkan-Karte „um halb zwölf“ | (Hana „zwanzig nach elf“ = 23:20 Anfeuern) | gleich |
| 23:40 Münzschatulle | – | – | – | Fatma, Emine „23:40“ | JM3 „23:40“ (3×) | – | Fatma-, Emine-Karte „23:40 Uhr“ | „um zwanzig vor zwölf“ | gleich |
| 23:51 Streitfoto | – | – | – | Joanna, Ahmet, Olli, Fatma, Can „23:51 Uhr“ | WW4 „23:51“ | – | Joanna-Karte „Foto um 23:51 Uhr“, Ahmet-Karte | – | gleich |
| 23:54 Can im Vorratsraum | – | (Olli kommt in den Ost-Saal) | – | Can „Ab 23:54 Uhr“, Zeynep, Emine | YW4 „23:54“ | – | Can-, Zeynep-Karte „Ab 23:54 Uhr“ | „ab sechs vor zwölf“ | gleich |
| 23:57 Ahmet/Fatma/Olli an der Theke | „Um drei vor zwölf stand ich am Ostende“ (Schneider), Marker „drei vor zwölf“ | „Ort um 23:57“ | Marker „23:57“, Joannas Notiz „Zeitstempel 23:57“ | überall „23:57“ / „drei vor zwölf“ | alle vier „23:57“ | Damir, Sibel-Aktion | Ahmet-, Fatma-, Olli-, Lejla-Karte „Um 23:57 Uhr“ | „Drei vor zwölf steht Olli am Eiskübel“, Zeitleiste 23:57:00 | gleich; Ollis und Ahmets Gang nie „23:56“ |
| 23:58 Knall + Cans Flucht | „Zwei vor zwölf: ein lauter Knall“ | „23:58 Uhr“ | – | „23:58 Uhr“, Can-Flucht „kurz nach dem Knall“ | alle vier „23:58“ | Hana, Sibel „23:58 … kurz danach rennende Schritte“ | – (Karten ohne Minute) | „Zwei vor zwölf“, Zeitleiste 23:58:00–23:58:23 | gleich |
| 23:58:30 Scheppern | „Kurz darauf scheppert es“ | dto. | – | „Kurz darauf …“, Reihenfolge „erst das Gesicht, dann das Scheppern“ | „kurz darauf das Scheppern“ | Reihenfolge | Reihenfolge (Tim, Marek, Zeynep) | Zeitleiste „23:58:30 Scheppern“ | gleich; Sekunden nur in Teil 90 (WELT 0.2) |
| 0:00 Licht an | „Um Mitternacht geht das Licht wieder an“ | „0:00 Uhr“ | Joanna-Streifen „Gruppenfoto 0:00“ | „0:00“, „Um zwölf hab ich das Licht wieder eingeschaltet“ | alle vier „0:00“ | Sibel, Hana, Tugba „0:00“ | Damir-Karte „Als um zwölf das Licht anging“ | „Um Mitternacht geht das Licht an“, „0:00:00 Licht“ | gleich |
| 0:12 Umschlag im Ascheneimer | – | – | – | Ahmet „Um 0:12 Uhr“ / „zwölf nach zwölf“ | WW4 „0:12“ | Azra „0:12“ | – | „Zwölf nach zwölf leert Ahmet“, Azra „zwölf nach zwölf“ | gleich |

### 3.2 Zählmatrix Zeit × Teil (6 + 10 + 20 Personen, w; Ziffer- und Wortform zusammen)

Gezählt wird die Uhrzeit, nicht das Ereignis (z. B. „23:54“ in Teil 01 ist „Um 23:54 Uhr siehst du Olli hereinkommen“).
Für **kein** Ereignis taucht eine abweichende Zeit auf.

| Eintrag | Teil 00 | Teil 01 | Teil 02 | Teil 10 | Teil 11 | Teil 12 | Teil 20 | Teil 90 |
|---|---|---|---|---|---|---|---|---|
| 18:30 Lieferung/Tragen | – | – | – | 15 | 3 | – | – | 3 |
| 18:35 Bogentür geschrammt | – | – | – | 7 | 3 | – | 6 | 3 |
| 20:15 Vorratsraum/Einbrecher | 6 | 3 | – | 25 | 3 | 31 | 4 | 1 |
| 21:00 Rüstung/Vitrine | 6 | 3 | – | 22 | 3 | 28 | 4 | 1 |
| 23:00 Streit Olli/Schneider | 3 | 3 | – | 41 | 6 | 17 | 3 | 3 |
| 23:30 Kaminqualm | 5 | 3 | – | 22 | 6 | 21 | 1 | – |
| 23:40 Münzschatulle | – | – | – | 10 | 9 | – | 12 | 8 |
| 23:51 Streitfoto | – | – | – | 35 | 6 | – | 12 | – |
| 23:54 Can im Vorratsraum | – | 3 | – | 19 | 15 | 2 | 12 | 3 |
| 23:57 Theke (Ahmet/Fatma/Olli) | 15 | 18 | 45 | 205 | 33 | 14 | 40 | 21 |
| 23:58 Knall + Flucht | 6 | 3 | – | 32 | 45 | 16 | – | 39 |
| 23:58:30 Scheppern | 6 | 3 | – | 22 | 6 | 8 | – | 3 |
| 0:00 Licht an | 6 | 3 | 1 | 32 | 12 | 22 | 2 | 18 |
| 0:12 Umschlag Ascheneimer | – | – | – | 6 | 3 | 3 | – | 4 |

### 3.3 Alle übrigen Uhrzeiten im Druck

Ziffernzeiten im gesamten Druck (alle Besetzungen): 18:00, 18:30, 18:35, 18:45, 18:50, 19:00, 19:30, 20:15, 21:00, 22:00, 22:30,
23:00, 23:20, 23:30, 23:40, 23:45, 23:50–23:58, 0:00, 0:01, 0:02, 0:03, 0:05, 0:10, 0:12, 0:20, 0:30, 1:15, 2:00, 2:45. Alle stehen in
der Kanon-Liste (WELT 0.2). Sekundenangaben (312 Treffer) nur in Teil 90 („Zeitleiste zum Nachlesen“), wie WELT 0.2 verlangt.

| Zeit | Ereignis | Quellen im Druck | Ergebnis |
|---|---|---|---|
| 18:00 | Ankunft, Einsammeln am Jackenständer, Dankeskarte beim Einlass, Werkzeugkasten an Tim | Was alle wissen (00, 01, 10, 12), WW4, Aylin, Tugba, Wojtek, Tim | gleich; Ort des Beleg-Streits siehe **B1** |
| 18:45 / 18:50 | Möbelwachs / Forderung 2.000 €, Tore zu | Tim, Olli Stufe 2, RN7, Tim-Karte | gleich |
| 19:30 | linker Handschuh in der Kamin-Nische | Tugba („um halb acht“), RN7, Teil 90 | gleich |
| 22:00 | Kerzen an, „leisere Musik“ / Box | Was alle wissen, Wojtek („um zehn“) | gleich |
| 22:30 | Aylins Quittungszettel | Aylin, Aylin-Karte | gleich |
| 23:20 | Hana feuert an, Serkan sieht es | Hana, Serkan, beide Karten, Teil 90 („zwanzig nach elf“) | gleich |
| 23:45 | Zeynep holt Gebäck, Tasche ausgebeult | Zeynep, Fatma, Can, JM3, YW4, Streifen | gleich |
| 23:50 | Tims Finger an der Bogentür | Tim, Olli, Can, Zeynep, Sibel, Hana, RN7, YW4 („zehn vor zwölf“) | gleich |
| 23:52 | „Ich hol dir Eis. Und dann red ich mit Schneider.“ | Tim, RN7 | gleich |
| 23:53 | „Wer war an der Vitrine?“; Ahmet bittet Joanna | Tim, Joanna, WW4 | gleich |
| 23:55 | Ruf zur blinden Kuh, Joanna an der Tür zum Durchgang, Ahmets Jacke, Serkan geht | Was alle wissen, Joanna, Ahmet, Olli, Aylin, Serkan, Tugba, Wojtek | gleich |
| 23:56 | Schneider bei Fatma (Drohung), Serkan am Außentor | Fatma, Emine, Joanna, Fatma-/Emine-/Serkan-/Hana-Karte | gleich |
| 0:01–0:05 | Eis für Tim, Can kommt herunter, Serkan zurück („zwei nach zwölf“), alle im Buffetsaal, Handys zurück | Tim, RN7, YW4, Sibel, Hana, Serkan, Lejla, Tugba | gleich |
| 0:10 | Azras Skizzenblock | Azra („zehn nach zwölf“) | gleich |
| 0:20 / 0:30 / 1:15 / 2:00 / 2:45 | Auftrag, Runden, Tipp-Runde | Teil 00 S. 3, 9, 11, 12; Teil 01 | gleich („halb eins“, „Viertel nach eins“, „zwei Uhr“) |

### 3.4 Uhrzeiten in Worten

| Wort | Bedeutung | geprüfte Stellen | Ergebnis |
|---|---|---|---|
| „kurz vor zwölf“ | 23:55–23:57 (WELT 0.2) | 38 verschiedene Sätze (Marek, Tim, Lejla, Emine, Zeynep, Damir, Aylin, Azra, Wojtek, Serkan, Can, Fatma, Detektivbogen, Impuls I-1.1, Streifen) | alle im Fenster 23:55–23:57 |
| „kurz vor Mitternacht“ | Einleitung Tat-Moment (Teil 00 S. 6) | 1 | passt (danach „Zwei vor zwölf: ein lauter Knall“) |
| „kurz nach zwölf / Mitternacht“ | 0:00–0:05 | Can (0:01), Handys (0:05), Serkan („bis kurz nach zwölf“), Augenbinde (Teil 01) | alle im Fenster |
| „zwölf nach zwölf“ / „zehn nach zwölf“ | 0:12 / 0:10 | Ahmet, Teil 90 / Azra | gleich |
| „zwei vor zwölf“ | 23:58 | Teil 00 S. 6, Teil 90, Wojtek, Azra | gleich |
| „drei vor zwölf“, „fünf vor zwölf“, „sechs vor zwölf“, „zehn vor zwölf“, „Viertel vor zwölf“, „zwanzig vor zwölf“, „halb zwölf“, „zwanzig nach elf“, „um elf“, „um zehn“, „um neun“, „Viertel nach acht“, „halb acht“, „halb sieben“, „um sechs“, „halb eins“, „sieben Uhr“ | 23:57 … 7:00 | alle Treffer gesichtet | jeweils dem Zeitstrahl entsprechend |

---

## 4. Lageplan (Teil 02, Blatt A) – vermessen

Raster: 1 Kästchen = 66,95 px bei 200 dpi (8,5 mm auf A4 quer), in beiden Achsen gleich; Ursprung so, dass die Wände bei
ganzen Kachelgrenzen liegen. Jeder Gegenstandspunkt liegt bis auf ±0,02 m auf der Bibel-Koordinate (WELT 2.3).

| Gegenstand (Beschriftung auf dem Plan) | gemessen x/y | Bibel | Feld |
|---|---|---|---|
| Wendeltreppe zur Turm-Toilette | 2,5/1,5 | 8b | 8b ✓ |
| Ritterrüstung · Schauvitrine · Schlüsselkasten der Stiftung | 1,5/4,5 · 3,5/4,5 · 1,5/5,5 | 8a | ✓ |
| Bogentür mit beschädigtem Beschlag | 2,5/6,5 (Bogentür 2/7) | Grenze 7/8, Legende 8a | ✓ |
| Regal mit der Mitternachtstorte · Erste-Hilfe-Kasten | 13,5/2,5 · 15,5/3,5 | 5 | ✓ |
| Notlaterne · Fundort Herr Schneider | 13,5/5,5 · 14,5/5,5 | „direkt hinter der Tür“ 14,5/5,5 | ✓ |
| Anrichte mit Messingkerzenständer | 13,5/8,5 | 13,5/8,5 | ✓ |
| Teekocher · Kaffeemaschine · Anrichte Ost · Werkzeugkasten | 15,5/7,5 · 16,5/7,5 · 17,5/7,5 · 16,5/8,5 | 4c/4d | ✓ |
| Theken-Klappe | 11,5/9,5 | 11,5/9,5 | 4a ✓ |
| Eiskübel (vor dem Ostende) | 17,5/10,5 | 17,5/10,5 | 4b ✓ |
| Getränkekisten · Sicherungskasten | 8,5/8,5 · 9,5/8,5 | Kisten 8/8, Kasten 9/8 | 6 ✓ |
| Steinbogen · Tür zum Durchgang | Öffnung x = 7 · Zelle 10/9 | 7/9 · 10/9 | ✓ |
| Lichtschächte | 5,5/8,5 | Nordwand Kaminsaal | 7 ✓ |
| Kamin-Nische · Ascheneimer | 1,5/13,5 · 1,5/14,5 | Westwand · 1,5/14,5 | 7 ✓ |
| Wandbank (nur eine, Süd) | 3,5/18,5 | Wandbank Süd 3,5/18,5 | 7 ✓ (West fehlt, **B3**) |
| Jackenständer · Wandtafel mit Ablaufplan | 20,5/8,5 · 25,5/9,5 | 1 | ✓ |
| Kopf der Tafel · Handykorb | 22,5/10,5 · 24,5/12,5 | 22,5/10,5 · 24,5/12,5 | 1 ✓ |
| Musikbox · Ehrenplatz der blinden Kuh | 25,5/15,5 · 24,5/16,5 | Wandbank Ost 25,5/15,5 · 24,5/16,5 | 1 ✓ (Bank nicht beschriftet, **B3**) |
| linker / rechter Buffettisch | 12,5/13,5 · 17,5/13,5 | 2 / 3 | ✓ |
| Innentür · Windfang · Außentor · Sandsteinstufen | 14/19 · x 14–15, y 20–21 · 22 | dto. | W ✓ |

Blatt B (Markerfelder): die 13 Feldnamen (1, 2, 3, 4a–4d, 5, 6, 7, 8a, 8b, W) sind wörtlich die aus WELT 2.1; jede Mini-Karte
markiert die richtige Fläche (4a L-Form an der Klappe, 4b Streifen vor der Theke Mitte bis Ost, 4c Band hinter der Theke,
4d Ostecke, 6 Durchgang mit Nische). Alle Markerzeilen der Hefte („Theke Ostende (4d)“, „Hinter der Theke: Anrichte,
Vorratsraumtür (4c)“, „Wendeltreppe und Turm-Toilette (8b)“, „Durchgang mit Steinbogen (6)“ …) und alle Streifen-Etiketten
(„Zone 6, im Steinbogen“, „Zone 4d, hinter der Theke am Ostende“, „Zone 1, Tür zum Ost-Saal“ …) zeigen auf vorhandene Felder.

---

## 5. Abstände und Wege

### 5.1 Maßtabelle (Teil 00 S. 15) und Kartentexte gegen den Plan

| von → nach | Druck | Plan (gerechnet) | Ergebnis |
|---|---|---|---|
| Ostende hinter der Theke (Saftkrüge) → Vorratsraumtür | „gut drei Meter“ (00), „gut 3 m“ (WJ9), „gut drei Meter entfernt“ (Marek) | 3,16 | ✓ |
| Ostende hinter der Theke → Eiskübel | „zwei Meter“ (00), „2 m“ (WJ9), „Das sind zwei Meter von mir“ (Marek) | 2,00 | ✓ |
| Eiskübel → Vorratsraumtür | „gut vier Meter“, „ein paar Meter“ (Fatma) | 4,24 | ✓ |
| Eiskübel → rechter Buffettisch | „gut drei Meter“, „gut 3 m“ (DM3), „ein paar Schritte“ (Lejla) | 3,16 | ✓ |
| Eiskübel → vor der Theke am Westende | „fünf Meter“ | 5,00 | ✓ |
| Theken-Klappe → Vorratsraumtür (hinter der Theke) | „gut vier Meter“, „ein paar Schritte“ (Olli) | 4,16 | ✓ |
| Theken-Klappe → hinter dem linken Buffettisch | „vier Meter“, „ein paar Schritte“ (JM3) | 4,00 | ✓ |
| Theken-Klappe → Sicherungskasten (durch die Tür) | „gut zwei Meter“ | 2,24 | ✓ |
| Sicherungskasten → Steinbogen | „gut zwei Meter“ | 2,24 | ✓ |
| Vorratsraumtür → Steinbogen | „gut acht Meter“ | 8,16 (Weg) | ✓ |
| Steinbogen → Bogentür, quer durch den Kaminsaal | „fünf Meter“ | 5,10 | ✓ |
| Tür zum Ost-Saal → Eiskübel / Kopf der Tafel | „gut zwei“ / „gut drei Meter“ | 2,24 / 3,16 | ✓ |
| Tim an der Kaffeemaschine ↔ Marek / Ahmet | „einen Meter neben mir“ / „zwei Meter neben mir“ | 1,00 / 2,00 | ✓ |
| Can an Tim vorbei | „einen Meter an ihm vorbei“ | 1,00 | ✓ |
| Olli neben der Klappe (Teil 90) | „1,4 m“ | 1,41 | ✓ |
| niemand näher am Eiskübel als (Teil 90) | „1,9 m“ (Damir) | 1,89 | ✓ |
| Steinbogen-Breite (AD3, FK3) | „nur 1 m breit“ | 1 Kachel | ✓ |
| Kerzenlicht (00, 01) | „etwa zwei Meter rund um die Anrichte“; Tür hell (1,4), Klappe kaum (2,2) | 1,41 / 2,24 | ✓ |
| Sichtlinien FX3 | Tür zum Ost-Saal sieht bis zum Steinbogen, nicht den Sicherungskasten | Türen beide in Reihe 9; Kasten hinter Wand x = 10 | ✓ |

### 5.2 Wege gegen Zeiten (Zeitleiste Teil 90 S. 6–7)

| Weg | Strecke | Zeit laut Teil 90 | Tempo | Ergebnis |
|---|---|---|---|---|
| Knall → Scheppern | – | 23:58:00 → 23:58:30 | 30 s | ✓ (A 4.1 „30 Sek. später“) |
| Fatma Klappe → hinter den linken Buffettisch | 4,0 m | 23:58:01–05 | 1,0 m/s | ✓ (dunkel) |
| Herr Schneider Kaffeemaschine → Vorratsraumtür | 2,2 m | 23:58:02–05 | 0,75 m/s | ✓ |
| Tim Kaffeemaschine → Klappe → Sicherungskasten | 9,0 m | 23:58:00–09 | 1,0 m/s | ✓ |
| Olli Eiskübel → vor der Theke West | 5,0 m | 23:58:10–15 | 1,0 m/s | ✓ |
| Can Vorratsraumtür → Klappe → Tim → Steinbogen → vor die Bogentür | 13,3 m | 23:58:17–23 | 2,2 m/s | ✓ (rennen) |
| Olli vor der Theke West → Klappe → Vorratsraumtür | 5,6 m | 23:58:19–25 | 0,93 m/s | ✓ |
| Olli hinter der Tür → Klappe → Eiskübel | 12,6 m | 23:58:36–49 | 0,97 m/s | ✓ |
| Olli Eiskübel → rechter Buffettisch (kriechend) | 3,2 m | 23:58:50–55 | ≈ 0,7 m/s | ✓ |
| Marek Ostende → Vorratsraumtür (Licht) | 3,2 m | 0:00:10–16 | 0,5 m/s | ✓ |
| Olli Eiskübel → Tim im Durchgang | 8,8 m | 0:00:30–0:01:00 | 0,3 m/s | ✓ |

Reihenfolgen in Spielertexten (ohne Sekunden): Gesicht an Tim (23:58:20) → Bogen/Zeynep (21) → zweiter Ruf (22) → Scheppern (30)
bei Tim, Zeynep, Marek, Teil 90; Gesicht vor Geruch bei Hana. Alles stimmig.

---

## 6. Ort × Quelle

### 6.1 Zählmatrix (6 + 10 + 20 Personen, w)

| Eintrag | Teil 00 | Teil 01 | Teil 02 | Teil 10 | Teil 11 | Teil 12 | Teil 20 | Teil 90 | auf dem Lageplan |
|---|---|---|---|---|---|---|---|---|---|
| Ost-Saal | 30 | 21 | 14 | 161 | 18 | 73 | 12 | 15 | ✓ Zone 1 |
| Buffetsaal | 15 | 3 | 15 | 15 | 3 | 12 | 12 | – | ✓ Zonen 2/3 |
| Linkes Buffet / linken Buffettisch | 3 | – | 12 | 23 | 9 | 1 | 3 | 18 | ✓ |
| Rechtes Buffet / rechten Buffettisch | 1 | – | 11 | 14 | 4 | – | 6 | 15 | ✓ |
| Theken-Klappe | 12 | 3 | 12 | 28 | 12 | – | 12 | 18 | ✓ |
| Westende | 3 | – | 9 | – | – | – | – | – | ✓ (4a) |
| Ostende | 12 | 6 | 24 | 72 | 36 | 14 | 30 | 53 | ✓ (4d) |
| Eiskübel | 24 | 6 | 14 | 79 | 39 | 3 | 27 | 58 | ✓ |
| Anrichte | 15 | 9 | 24 | 30 | – | 11 | 3 | 6 | ✓ |
| Vorratsraum | 48 | 18 | 20 | 97 | 45 | 35 | 33 | 55 | ✓ Zone 5 |
| Vorratsraumtür | 33 | 12 | 9 | 40 | 27 | 12 | 9 | 25 | ✓ |
| Notlaterne | 12 | 3 | 6 | 33 | 9 | 11 | 3 | 6 | ✓ |
| Durchgang | 6 | 6 | 17 | 38 | 12 | 7 | 30 | 18 | ✓ Zone 6 |
| Steinbogen | 12 | 3 | 16 | 35 | 15 | 7 | 22 | 9 | ✓ |
| Sicherungskasten | 6 | 3 | 10 | 18 | – | 4 | 18 | 8 | ✓ |
| Kaminsaal | 11 | 4 | 16 | 69 | 18 | 46 | 15 | 13 | ✓ Zone 7 |
| Kamin-Nische | – | 3 | 3 | – | 6 | 12 | 11 | 6 | ✓ |
| Ascheneimer | – | 3 | 6 | 15 | 6 | 4 | 9 | 14 | ✓ |
| Lichtschächte | 8 | 3 | 3 | 22 | 6 | 14 | – | – | ✓ |
| Turmgang | 15 | 9 | 12 | 86 | 12 | 35 | 13 | 9 | ✓ 8a |
| Bogentür | 12 | 6 | 9 | 80 | 24 | 29 | 29 | 18 | ✓ |
| Ritterrüstung | 8 | 6 | 6 | 22 | 3 | 10 | 7 | 4 | ✓ |
| Schauvitrine | – | 3 | 6 | 6 | 6 | 9 | 16 | 7 | ✓ |
| Wendeltreppe | – | – | 9 | 16 | 6 | – | 3 | – | ✓ 8b |
| Turm-Toilette | 3 | – | 12 | 42 | 3 | 9 | 4 | 3 | ✓ 8b |
| Hoftür | 3 | – | 3 | 3 | 3 | – | – | – | ✓ |
| Windfang | 6 | 1 | 9 | – | – | 11 | 1 | – | ✓ W |
| Innentür | 3 | – | 6 | – | – | 7 | – | – | ✓ |
| Außentor | 18 | 6 | 6 | 44 | 6 | 36 | 3 | 14 | ✓ |
| Notausgangsschild | 6 | 3 | – | 3 | 3 | 1 | – | 6 | nicht beschriftet (über der Innentür, im Text erklärt) |
| Jackenständer | 3 | 6 | 6 | 31 | 12 | 8 | 6 | 6 | ✓ |
| Kopf der Tafel | 3 | 3 | 4 | 24 | 6 | 2 | – | – | ✓ |
| Handykorb | 3 | 3 | 3 | 26 | – | 8 | 6 | – | ✓ |
| Ehrenplatz | 3 | 6 | 3 | 2 | – | 2 | – | – | ✓ |
| Wandtafel | – | – | 3 | – | – | 3 | – | – | ✓ |
| Wandbank Süd | – | – | – | – | – | 5 | – | – | als „Wandbank“ ✓ |
| **Wandbank West** | – | – | – | – | – | 3 | – | – | **fehlt (B3)** |
| **Wandbank Ost** | – | – | – | – | – | 3 | – | – | **fehlt (B3)**, nur „Musikbox“ |
| Saalmitte | – | – | – | 4 | – | – | – | – | allgemein, ohne Beschriftung (unkritisch) |
| Kaffeemaschine · Werkzeugkasten | 6 · – | 3 · 3 | 7 · 3 | 29 · 13 | 12 · 3 | 5 · 23 | 12 · 13 | 15 · 8 | ✓ |
| Tür zum Ost-Saal · Tür zum Durchgang | 6 · – | 3 · – | 5 · 3 | 13 · 5 | – | – | 3 · 3 | 6 · – | ✓ |
| Einlass | 1 | 1 | – | 10 | – | 22 | 2 | – | Vorgang im Windfang (W); Szenenort siehe **B1** |

### 6.2 Varianten

Keine Treffer für „Ostsaal“, „Ost Saal“, „Buffet-Saal“, „Kaminraum“, „Kaminzimmer“, „Thekenklappe“, „Kaminnische“,
„Turmtoilette“, „Toilette im Turm“, „Vorratskammer“, „Lagerraum“, „Abstellraum“, „Küche“, „Torbogen“, „Turmtür“, „Eingang“,
„Lichtschacht“. „Bogen“ steht nur für den Steinbogen („im Bogen“, „Bogen zum Kaminsaal“), nie für die Bogentür. „Klappe“
allein meint immer die Theken-Klappe (außer „Kaminklappe“/„Klappen der Lichtschächte“, jeweils eindeutig). Der
Sicherungskasten steht überall im Durchgang, der Eiskübel überall vor dem Ostende.

---

## 7. Geprüfte Personen (wer wann wo, aus allen Teilen gekreuzt)

| Person | Stationen (Quellen) | Widerspruch? |
|---|---|---|
| Herr Schneider | 18:30 Schlosshof (Marek, Tim) · 18:50 Bogentür (RN7, Tim) · 22:30 Tafel West (Aylin) · 23:00 vor der Theke (RN7, Tim) · 23:30 Kaminsaal (Hana, Serkan) · 23:51 vor der Theke (Ahmet, Joanna) · 23:52–23:54 Turmgang (Tim) · 23:54 Steinbogen (Zeynep) · 23:55 Durchgang (Joanna) · 23:55/56 linkes Buffet (Tim, Joanna, Emine, Fatma) · 23:56/57 Ostende (Fatma, Joanna, Olli, Ahmet, Herr-Schneider-Antwort) · 23:57 → Kaffeemaschine (Ahmet, Marek, Damir, Fatma, Tim) · Notlaterne, Vorratsraumtür, Fundort | nein |
| Ahmet | 18:00 Jackenständer · 23:51 vor der Theke · 23:53 → Ost-Saal · 23:55 Jacke (Olli) · 23:57 Ostende hinter der Theke (Joanna, Lejla, Marek, Tim, Fatma, Damir, Olli) · Knall/Scheppern an Mareks Beinen (Marek, Damir) · 0:12 Kamin (Azra) | nein (Servietten-Grund = gewollte Lüge) |
| Fatma | 23:40 Turmgang (Emine) · 23:45/23:50 linkes Buffet (Zeynep) · 23:54 tuschelt (Can, Emine) · 23:56 Schneider (Emine, Joanna) · 23:57 Klappe (Joanna, Emine) · Knall: hinter dem linken Buffettisch (Emine) | nein (Marker „23:57“ am Buffet = gewollte Lüge) |
| Olli | 18:30–18:50 Bogentür · 19:30 Kamin-Nische (Tugba) · 20:15 Vorratsraum · 23:00 vor der Theke (Tim) · 23:50 Bogentür (Tim, Can, Zeynep, Sibel, Hana) · 23:52 → Ost-Saal (Tim, Sibel) · 23:54 Kopf der Tafel (Detektiv, Damir) · 23:55 dto. (Ahmet, WW4) · 23:57 Eiskübel (Joanna, Ahmet, Fatma) · nach dem Scheppern rechtes Buffet (Lejla) · 0:00 Eiskübel (Lejla) · 0:01 Durchgang (Tim) | nein (Stufe 1 „ganze Zeit im Ost-Saal“, Stufe 2 „am Eiskübel geduckt“ = gewollte Lügen, fallen per Joanna/Lejla/Karten) |
| Can | 23:45–23:50 Kaminsaal, lange Tafel (Zeynep, Sibel) · 23:54 Vorratsraum (Zeynep, YW4) · Flucht durch Klappe, Durchgang, Steinbogen, Kaminsaal (Marek, Olli, Tim, Zeynep, Sibel, Hana) · 0:01 Wandbank West (Sibel, Hana, Zeynep) | nein (Turm-Toilette ab „kurz vor zwölf“ = gewollte Lüge) |
| Lejla, Emine, Tim, Joanna, Marek, Zeynep | siehe Hefte; jede Station von mindestens einer weiteren Rolle bestätigt (z. B. Joanna an der Tür zum Durchgang ↔ Zeynep „Komm gleich!“; Lejla und Marek 23:50 im Ost-Saal; Tim 23:55 durch den Steinbogen ↔ Zeynep) | nein |
| Sibel, Damir, Hana, Serkan, Azra, Wojtek, Aylin, Tugba | 21:00 Turmgang · 23:00 Ost-Saal · 23:20/23:30 Kaminsaal · 23:50–23:57 Ost-Saal (Damir schenkt aus, Serkan bis 23:55) · 23:55 Serkan → Windfang (Aylin) · 23:57 Damir → Ostende (Marek, Ahmet) · 0:10/0:12 Azra im Kaminsaal | nein |
| Detektiv | ab 23:50 Tafel Ostseite (Azra) · 23:55 Ehrenplatz (Tugba, Wojtek) · Augenbinde ab „kurz nach Mitternacht“ / „um zwölf“ (Tugba) | nein |

---

## 8. Besetzungen

| Besetzung | geprüft | Ergebnis |
|---|---|---|
| 6, 10, 20 (w und m) | vollständig (20) bzw. jede Abweichung gegen 20 | Uhrzeiten unverändert; Ersatzsätze („ein Gast“, „der Caterer“, „deine beste Freundin“, „Jemand ruft aus dem Steinbogen“) ändern keine Zeit und keinen Ort; Zeugenstreifen-Etiketten zeigen auf Felder von Blatt B |
| 7, 8, 9, 11 (w, selbst gesetzt) | Ausweichziele, Streifen | Ollis Ausweichfrage bei 6–8 (**B2**); sonst stimmig (z. B. Tim, wenn Zeynep fehlt, 9–11 Personen: „Von zehn vor zwölf bis kurz nach fünf vor zwölf stand ich direkt an der Bogentür. Da ist nur Herr Schneider durch.“) |
| 13, 15, 17, 19 (Solo-Tandems) | Sibel, Hana, Azra, Aylin allein | Zeiten und Orte gleich; Azra allein verlegt den Domino-Satz korrekt auf „Um 20:15 Uhr sagte Tim am Werkzeugkasten hinter der Theke …“ |
| alles in einer Datei | Seitenzahl und Uhrzeiten-Bestand | identisch mit den Teilen |

---

## 9. Befunde

### B1 · klein · Beleg-Streit an zwei Orten: „beim Einlass“ gegen „am Jackenständer im Ost-Saal“

- **Besetzung:** 20 Personen w und m (Tugba); Aylins Satz ab 19 Personen.
- **Fundstellen:** `druck-r3/w/kammerspiel-U4YRK-p20/12-zusatzheft-aylin.pdf` S. 3 (Teil 12 S. 21); `12-zusatzheft-tugba.pdf` S. 2 und
  S. 3 (Teil 12 S. 23/24); `20-karten.pdf` S. 19 (Geheimniskarte Tugba). Gegenstellen: „Was alle wissen“ (jedes Heft S. 1,
  Teil 00 S. 7, Teil 01 S. 1), `11-fassungen.pdf` S. 2 (WW4).
- **Zitat:** Aylin, Runde 1 Ziel 1: „Ahmet, beim Einlass wolltest du mir keinen Beleg geben. Den gibt's von Herrn Schneider,
  hast du gesagt.“ – Tugba, Stufe 1 und Karte: „Aylin wollte beim Einlass einen Beleg für die Miete. Frag sie, ob sie einen
  bekommen hat.“ – dagegen „Was alle wissen“: „Am Jackenständer im Ost-Saal sammelt Ahmet von allen aus der Clique 150 €
  „Miete“ in Bargeld ein. … Beim Einlass habt ihr heimlich eine Dankeskarte für Herrn Schneider unterschrieben.“ und WW4:
  „18:00 Am Jackenständer im Ost-Saal sammelst du … Aylin will einen Beleg.“
- **Problem:** Dieselbe Szene (Aylin verlangt von Ahmet einen Beleg) liegt in Teil 12/20 „beim Einlass“ (Windfang, wo Herr
  Schneider die Gäste begrüßt), in „Was alle wissen“ und in WW4 am Jackenständer im Ost-Saal.
- **Wirkung am Tisch:** gering. Wer genau zuhört, stolpert: Beim Einlass stand Herr Schneider daneben, Ahmets Ausrede „Den
  Beleg gibt's von Herrn Schneider“ wäre dort sofort aufgeflogen; der Druck legt dieselbe Szene an zwei Orte.
- **Vorschlag:** `content/kammerspiel/schlosskeller/rollen/17-aylin.json`, Gesprächsauftrag Runde 1 Ziel 1 („frage“, Z. 172):
  „Ahmet, am Jackenständer wolltest du mir keinen Beleg geben. Den gibt's von Herrn Schneider, hast du gesagt. Warst du kurz
  vor zwölf deshalb bei ihm hinter der Theke?“ · `rollen/18-tugba.json` Z. 103 und `undNochEtwas` (Z. 232): „Aylin wollte am
  Jackenständer einen Beleg für die Miete. Frag sie, ob sie einen bekommen hat.“ · Z. 187 („frage“): „Aylin, du wolltest am
  Jackenständer einen Beleg für die Miete. Du hebst doch jeden Zettel auf. Hast du inzwischen einen?“ (Bibel ZR 8 entsprechend
  nachziehen, dort Z. 6049, 6073, 6084.)

### B2 · klein · Ollis Ausweichfrage an Can setzt einen Weg voraus, den es nicht gibt (6–8 Personen)

- **Besetzung:** 6, 7, 8 Personen, w und m (Tim fehlt).
- **Fundstelle:** `druck-r3/w/kammerspiel-U4YRK-p6/10-rollenheft-olli.pdf` S. 3 (Teil 10 S. 11); ebenso `r3/p3/druck/p7` und `p8`.
- **Zitat:** „Ziel 2 · Can: „Can, du sagst, du warst auf der Turm-Toilette. Bist du dafür durch den Ost-Saal gekommen? Dann
  hättest du mich am Kopf der Tafel sitzen sehen.““ – dagegen Cans Heft S. 2: „Kurz vor zwölf. Vom Kaminsaal durch die Bogentür,
  durch den Turmgang und die Wendeltreppe hinauf.“
- **Problem:** Der Ost-Saal ist laut Lageplan der östlichste Raum ohne zweiten Ausgang, die Turm-Toilette liegt ganz im Westen;
  kein Weg zur Turm-Toilette führt durch den Ost-Saal, und Can behauptet das auch nirgends.
- **Wirkung am Tisch:** Die Frage läuft ins Leere: Can sagt „nein, vom Kaminsaal“, mehr kommt nicht. In kleinen Runden hat
  Olli damit in Runde 1 nur ein tragfähiges Ziel; wer auf den Lageplan schaut, hält die Frage für einen Druckfehler.
- **Vorschlag:** `content/kammerspiel/schlosskeller/rollen/03-olli.json`, Runde 1 Ziel 2, Schlüssel „ausweich“ (Z. 143), und
  Bibel RK 4.11 (Z. 3115): „Can: „Can, du sagst, du warst auf der Turm-Toilette. Dahin kommt man nur durch den Kaminsaal und
  den Turmgang. Wer hat dich da gehen sehen?““

### B3 · klein · Wandbank West und Wandbank Ost fehlen auf dem Lageplan

- **Besetzung:** Lageplan bei jeder Besetzung gleich (w und m); die Bänke werden ab 13 Personen genannt (Sibel, Hana, Azra,
  Wojtek), vollständig bei 20.
- **Fundstellen:** `druck-r3/w/kammerspiel-U4YRK-p20/02-tisch.pdf` S. 1 (Blatt A): einzige Beschriftung „Wandbank“ im Kaminsaal
  unten (3,5/18,5), im Ost-Saal nur „Musikbox“; Legende „7 Kaminsaal: Kamin mit Ascheneimer und Nische, Wandbänke“.
  Heftstellen: `12-zusatzheft-sibel.pdf` S. 2, `12-zusatzheft-hana.pdf` S. 2, `12-zusatzheft-azra.pdf` S. 2,
  `12-zusatzheft-wojtek.pdf` S. 1–2.
- **Zitat:** Sibel: „0:01 Can kommt durch die Bogentür aus dem Turmgang und setzt sich auf die Wandbank West.“ – Azra: „0:10 holt
  ihren Skizzenblock von der Wandbank West im Kaminsaal und bleibt dort sitzen“ – Wojtek: „23:50–0:00 sitzt auf der Wandbank Ost
  bei der Box.“ – Sibel: „Um zehn vor zwölf saß ich im Kaminsaal auf der Wandbank Süd.“
- **Problem:** Die Hefte unterscheiden drei Wandbänke (Süd, West, Ost), der Plan beschriftet nur eine („Wandbank“, Sibels
  Südbank) und nennt in der Legende „Wandbänke“ ohne sie einzuzeichnen.
- **Wirkung am Tisch:** gering (Marker gelten zonenweise). Wer Azras Beobachtung am Ascheneimer oder Cans Platz nach dem Licht
  am Plan zeigt, landet auf Sibels Bank; die Azra-Aussage („4 m, volles Licht“) lässt sich am Plan nicht nachmessen.
- **Vorschlag:** `content/kammerspiel/schlosskeller/tisch.json`: Objekt `wandbankSued` → `"name": "Wandbank Süd"`; neues Objekt
  `{"id": "wandbankWest", "name": "Wandbank West", "x": 1.5, "y": 10.5, "feld": "7"}` (4 m vom Ascheneimer, wie P3-Runde 2
  rechnete; alternativ 1,5/18,5); Objekt `musikbox` → `"name": "Wandbank Ost mit Musikbox"`.

---

## 10. Beobachtungen ohne Befund

- **Damirs Marker „23:57“ im Ost-Saal**, obwohl sein Heft unter „23:57“ den Gang mit der Teekanne ans Ostende führt: gewollt
  (WELT 4.1/4.2: um 23:57:00 noch im Ost-Saal, Ankunft 23:57:35); Heft sagt „Beide stimmen“, Joannas Notiz (23:57:00) führt ihn
  nicht. Gleiches Muster bei Herrn Schneider (4d → 4c) und Fatma (2 → 4a). Kein Widerspruch am Tisch.
- **Bogentür:** Legende ordnet „Bogentür mit beschädigtem Beschlag“ dem Turmgang (8a) zu (wie A:85), Hefte sagen „an der
  Bogentür im Kaminsaal“ (Kaminsaalseite). Die Tür liegt auf der Grenze 7/8; beides beschreibt dieselbe Stelle.
- **AD3 „Ein kurzer, niedriger Gang, gut zwei Meter lang.“** Auf Blatt A liegen zwischen Kaminsaal und Buffetsaal vier Kästchen
  (Steinbogen, zwei Gangkacheln, Tür). Innenmaß 2 m wie WELT 2.3; Maßtabelle und Wege rechnen damit richtig.
- **„Zone“ und „Feld“** bezeichnen dasselbe (Streifen-Etikett „Zone 4d“, Erzählerheft „Feld 4d“, Blatt B „Markerfelder“); das
  Erzählerheft verbindet beides („neben das Markerfeld der Zone“). Für P5 zur Kenntnis.
- **Für P4/P5 (Namen, nicht Ort/Zeit):** Bei 10 Personen sagt Joannas Heft „Jemand ruft aus dem Steinbogen: „Komm gleich!““,
  ihre Notiz im selben Heft nennt „Zeynep: im Bogen zum Kaminsaal, kommt gleich“ (Ort gleich).
- **Tugba sammelt um 23:00 „auch Tims an der Kaffeemaschine“** (Bibel: Tims und Ollis); kein Text widerspricht.

## 11. Nicht gemeldet (bekannt oder angenommen)

Tims Wortbudget, RN7-Länge, Schriftgrößen (E19), Erzählerheft 16 Seiten (E18), „Detektiv“ als Rollenbegriff (E20),
Karten-Einzelseite „Seite 1 von 1“, Tabelle „Was du weißt“ ohne Fortsetzungskopf, Rundennamen in Anführungszeichen;
18:30/18:35-Aufteilung und 23:20/23:30-Aufteilung (WELT 3.3, Auftrag A:41/A:62 selbst); 18:50 als erste Forderung und 23:00 als
Polizei-Drohung (WELT 3.3, Kanon); Abweichungen K-01 bis K-25.

## 12. Werkzeuge und Zwischenstände

`r3/p3/zeiten.py` (Uhrzeiten-Extraktion, Ergebnis `zeiten.tsv`), `wort.py` (Wortzeiten nach Satz), `matrix.py` (Tabellen 3.2, 6.1),
`dots.py` (Gegenstandspunkte auf Blatt A), `raw/` (Text in Lesereihenfolge), `druck/p7 … p19` (selbst gesetzte Besetzungen),
Bildausschnitte `crop-durchgang.png`, `crop-turm.png`, `blattB-mini2.png`.
