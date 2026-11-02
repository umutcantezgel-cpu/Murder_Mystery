# Testprotokoll Kammerspiel (Fall-Bibel)

Fortlaufendes Protokoll der Testrunden zur Fall-Bibel. Jede Runde nennt je Protokoll das Ergebnis und jeden Befund
mit Behebung oder Begründung. Die ausführlichen Protokolle stehen unter `bibel/tests/`. Fundstellen wie „MECH 4.4“
oder „ZG 3.5“ sind Kennungen in `bibel/FALL-BIBEL.md` (FALL-BIBEL 0.2).

## Runde 1: Tests der Teilentwürfe 01–05, Integration Runde 1 (2026-11-01)

Geprüft wurden die Teilentwürfe `01-welt.md` bis `05-rollen-zusatz.md`. Die Integration führt sie zu `FALL-BIBEL.md`
zusammen. Alle Ersetzungen laufen über ein Skript mit Trefferprüfung (`bibel/werkzeug-int/`, 415 geprüfte Ersetzungen, keine ohne Treffer).

### Protokoll 1 (Interaktion und Pausen, jede Rolle 1–18, Detektiv, Erzähler) und Protokoll 4 (Skalierung 6 bis 20 Personen)

Ausführlich: `bibel/tests/P1+P4-runde1.md`.

**Ergebnis Runde 1:** Die Logik trägt bei 6 bis 20 Personen: jeder Meilenstein erreichbar, kein Nachbohr-Ziel ins Leere. Schwächen: Druckformat des Abwesenheitsblatts, Name einer ungespielten Rolle in Hanas Heft, Stau bei 14 bis 20 Personen, Zusatzrollen ohne eingehende Ziele, Bonus-Ziel der Verdächtigen ohne Wirkung. 2 Blocker, 15 mittel, 17 klein.

| Befund | Schwere | Ergebnis | Behebung oder Begründung |
|---|---|---|---|
| P14-01 | blocker | behoben | Tarnsatz-Zeile „was Serkan vorhat“ als Platzhalter-Zeile, entfällt ohne Serkan; Generator-Satz in ZR 3.12 nimmt sie aus; Prüfregel für Namen 5–18 in ZR ZG-10, ZG G-08, WELT 0.2. |
| P14-02 | blocker | behoben | MECH 5.2: A4 mit 5 mm Rand, Streifen 100 × 95 mm, Falz 30 mm unter der Oberkante, Protokoll 65 mm, 9 pt, Joannas Notiz zweispaltig 8 pt. Etikett gekürzt (MECH 5.3), Schlusszeilen in ZG 1.11 bis 6.11 gestrichen. |
| P14-03 | mittel | behoben | R-02 wörtlich (zwei Minuten; ab 12 Personen laufen Gespräche leise weiter); MECH 1.3 b, 9.13 Zeile 12; RK 6.5 Runde 1 zweites und Runde 2 erstes Ziel über die Impulse „Wer war neben dir?“ und „Geld“; RK 6.6, 6.12. |
| P14-04 | mittel | behoben | Gegenüberstellung ab 14 Personen in Runde 2 und 3 wörtlich in MECH 1.3, als Vorlesetext in MECH 9.9, in MECH 9.13 Zeile 14, MECH 0.2 und RK 6.12; gilt als „vor allen“ (R-13). Ob fünf Minuten reichen, zeigt ein Probelauf (FALL-BIBEL 19.2 Nr. 3). |
| P14-05 | mittel | behoben | Etikett ohne Freigabe-Codes (MECH 5.3, ZG 1.11 bis 6.11); neue Erzählertabelle „Karten unter den Streifen“ MECH 9.14 (Erzählerheft Seite 16, MECH 9.1); R-08; MECH 4.1, 4.2, 3.4, M-17; ZG G-04; Domino-Gerüst MECH 11 („Erzählertabelle“). |
| P14-06 | mittel | behoben | Etikett „oder beim ‚Zeitstempel‘ jemand [Name] als Zeugin nennt“; MECH 5.4 „Andere Aktionskarten öffnen keinen Streifen“; MECH 0.3 Satz 10; MECH 9.7; ZG-Streifentabellen. |
| P14-07 | mittel | behoben | Bonus-Ziel wörtlich nach Vorschlag in RK 1.6 und RK 2.10, 3.10, 4.10, 5.10; Prüfung über „freiwillig“ in der Vermerke-Liste (RK 6.9); MECH 7.3, M-36; RK-17 entfällt; RK 8.2. |
| P14-08 | mittel | behoben | Neue Tabelle RK 1.8 „Wenn der Erzähler fragt“ (acht Zeilen, Vorschlag übernommen und um I-1.1, I-1.2 und Fassungen nach Karte oder Marker ergänzt), Verweise in RK 2.6, 3.6, 4.6, 5.6; Budget RK 1.1 (120–145, Seite 2 zusammen 450–520); MECH 10.4; Längen gezählt (RK 7.7, 126 bis 138 Wörter). |
| P14-09 | mittel | teilweise behoben | Damir R2 → Sibel, Serkan R2 → Hana, Wojtek R1 → Hana, Aylin R1 → Serkan (Wortlaute so angepasst, dass jeder Satz wahr ist, I-20); ZR 0.4, 9.1, 9.2. Nicht behoben: Damir, Wojtek und Tugba bleiben ohne eingehende Ziele, weil Ziele nur kleinere Plätze nennen (ZG-09) und Tugba den größten Platz hat (19.2 Nr. 2). |
| P14-10 | mittel | behoben | ZG 3.5: neue Tarnsatz-Zeile, nur ab 17 Personen gedruckt, wörtlich nach Vorschlag; ZR 13.1 Zeile 17. |
| P14-11 | mittel | behoben | MECH 4.4 Grenzen „Handzeichen“ wörtlich; ZG G-12; ZR ZG-16, ZR-16; Kartenkopie ZR 8.9. |
| P14-12 | mittel | behoben, mit Abweichung | Flache Plättchen 26 × 18 mm, sechs je Feld; Hinweise „Offene Indizkarten“ und „Zeitpunkte“ in die Legende von Blatt A (MECH 10.2, 10.1, 10.5, M-27). Abweichung: Feld 1 über drei statt vier Zellen (18 Plättchen), weil vier Zellen 16 Zellen auf Blatt B bräuchten (I-11). |
| P14-13 | mittel | behoben | MECH 2.6: Seite 5 Vermerke-Liste 1 bis 48 zweispaltig, Seite 6 Anklagefeld; Seite 3 mit Spalte „Kein Bund ☐“; MECH 10.1 Teil 01: 6 / 6 / 6; RK 6 Einleitung, RK 6.10. |
| P14-14 | mittel | behoben | Jedes Ausweichziel an den Detektiv hat einen zweiten Satz an einen Verdächtigen, wörtlich nach Vorschlag (RK 2.9, 3.9, 5.9); die Runde-3-Ausweichziele von Olli und Can beginnen mit der Frage (RK 4.9, 5.9); RK 1.2, RK-24. |
| P14-15 | mittel | behoben | R-03 wörtlich ergänzt („Karte!“ ab 12 Personen); MECH 1.3 b; Kurzform „So spielt ihr“; MECH 9.13 Zeile 12. |
| P14-16 | mittel | behoben | WELT 1.1 wörtlich ergänzt; MECH 8.4 Seite 10 wörtlich; MECH 8.3 Namensregel für Teil 90 (Zusatzrollen nur gespielt, sonst „ein Gast“); MECH 5.3. |
| P14-17 | mittel | behoben | ZG 0.6 „Aufbau des Zeugenhefts“ mit Seiten, Reihenfolge, Wortbudget, „Wer du bist“ und Markerzeilen wörtlich. Die Wissen-Tabellen werden gedruckt (wie P5-M4, I-23), deshalb Platzhalter in ZG 3.4 und 4.4 nach Vorschlag. |
| P14-K01 | klein | behoben | Cans Auslöser (c) wörtlich in RK 5.7, MECH 4.2 und 3.4; Erläuterung in MECH 4.2, was zählt. |
| P14-K02 | klein | behoben | Über P14-05: Karten unter Streifen öffnen, sobald der Code offen liegt, egal wodurch (MECH 5.4, 9.14; ZG 6.11). |
| P14-K03 | klein | behoben | ZR 0.6: Damirs Zeitstempel 23:57 wörtlich nach Vorschlag. |
| P14-K04 | klein | behoben | ZG 5.5: „Die Mitternachtstorte steht unversehrt im Regal.“ |
| P14-K05 | klein | behoben | Ersatz-Eintrag „sofort“ für Fatma ohne Zeynep (RK 1.5, 3.5, 3.11, 8.1). |
| P14-K06 | klein | behoben | Ollis Runde-1-Ausweichziel ist Can, wörtlich nach Vorschlag (RK 4.9, 1.2, 4.11). |
| P14-K07 | klein | behoben | Tims Runde-3-Ausweichziel ist Lejla, wörtlich nach Vorschlag (ZG 3.7, 3.10, 7.1, 7.2). |
| P14-K08 | klein | behoben | Letzter Satz des Ausfalltexts Sibel gestrichen (MECH 9.4). |
| P14-K09 | klein | behoben | MECH 9.13 Zeile 14 ergänzt, Zeile 20 „wie 14“; ZR 13.1 angeglichen. |
| P14-K10 | klein | behoben | MECH 5.3 Zeile Zeynep: „AD3; FK3; Zeitstempel“. |
| P14-K11 | klein | behoben | MECH 6.3 Zeile 10: „Str Marek (WJ9 oder Joannas Zeitstempel)“. |
| P14-K12 | klein | behoben | Vorderseite für fehlende Zeugen (MECH 4.1), geschlechtsneutral: „Heute spielt diese Rolle niemand. Der Erzähler dreht sie um.“ statt „Heute ohne Spieler.“ |
| P14-K13 | klein | behoben | Wortlaut nach Vorschlag in MECH 4.1, 5.4, 9.14 und R-08. |
| P14-K14 | klein | behoben | MECH 1.3 (wörtlich) und 9.13 Zeile 6. |
| P14-K15 | klein | behoben | Krankenbesuch legt JA9 offen, wörtlich (MECH 4.4, Kartenkopie ZG 1.8, Tipp RK 6.8). |
| P14-K16 | klein | behoben | Domino-Frage neu (MECH 9.9), zusammen mit P2-12. |
| P14-K17 | klein | behoben | MECH 1.5: Zusatzsatz zur Dankeskarte, nur gedruckt, wenn Aylin gespielt wird. |

### Protokoll 2 (Domino-Ketten-Simulation, Läufe mit 10 Personen zurückhaltend und forsch, 6 und 20 Personen)

Ausführlich: `bibel/tests/P2-runde1.md`.

**Ergebnis Runde 1:** Keine Sackgasse, kein Zirkel; Ahmet, Fatma und Can entlastbar; alle Beweise zeigen auf Olli; Ollis Stufe 2 glaubwürdig und widerlegbar. Nicht bestanden: „kein Auto-Solve vor Runde 3“ (P2-01, P2-02). 2 Blocker, 5 mittel, 8 klein.

| Befund | Schwere | Ergebnis | Behebung oder Begründung |
|---|---|---|---|
| P2-01 | blocker | behoben | MECH 2.1 „Teil 1 ☐ · Teil 2 ☐“; MECH 2.4 wörtlich nach Vorschlag; gleich gebaute Titel „[Name]: Taschen und Kleidung“ für FN3, NN3, JT3 (MECH 3.1 Nr. 8, 3.2, 3.3; RK 3.7, 5.7, 7.5); MECH 6.1 M9; M-06; MECH 3.5. Teil 01 nennt Teil 2 nicht mehr. |
| P2-02 | blocker | behoben | FN3 trägt nur noch zwei Hinweis-Vermerke, XD3 den neuen Vermerk für Teil 1 wörtlich nach Vorschlag; MECH 2.2 (Teil 2 kein Vermerk), 3.2, 11.2; RK 6.9 Hinweis wörtlich. |
| P2-03 | mittel | behoben | Runde 3: Tipp-Runde nach Abschnitt c, dann Untersuchungen, dann Anklage (MECH 0.2, 0.3, 1.1, 1.2, 1.3, R-12, 6.1, 6.3, 7.1, 9.8, 9.12, 11.3; RK 6.5, 6.7). Folge: Alle Bonus-Ziele werden nach dem Stand bei der Anklage geprüft (MECH 7.2, 7.3, alle Hefte; I-07), sonst wären Serkans und Tugbas Ziele unerfüllbar. |
| P2-04 | mittel | behoben | R-06 Satz 2 wörtlich; MECH 1.3 e wörtlich; RN7 „Wenn es eng wird“ mit dem Satz zum Marker. Damit die Fassungen gleich gebaut bleiben, hat jede einen fünften Satz zum Marker (I-16; RK 7.1, 8.2, RK-15). |
| P2-05 | mittel | behoben | MECH 6.1 Regel unter der Tabelle wörtlich; Hinweis über dem Raster (MECH 2.1) und RK 6.9. |
| P2-06 | mittel | behoben | Neue Domino-Hinweise Lejla, Joanna, Marek wörtlich (MECH 4.2, ZG 0.3, 1.6, 4.7, 5.6); die alten Ahmet-Sätze stehen unter „Nach dem Umdrehen“. Emine nach P3-11 statt nach P2-06 (I-18). |
| P2-07 | mittel | behoben, mit Abweichung | PP9 heißt „Vor der Theke am Ostende“, VP7 ab Runde 3 (MECH 3.1, 3.2, 3.3, 3.5, M-09; RK 7.5; ZR 0.4). Abweichung: VP7 behält den Titel „Kamin-Nische“, weil WM9 schon „Ascheneimer am Kamin“ heißt (I-05). |
| P2-08 | klein | behoben | Eine Grenze für alle vier Schutzkarten, zusammen mit P5-K4 (MECH 4.4; RK 2.10, 3.10, 4.10, 5.10; I-17). |
| P2-09 | klein | behoben | Zeitstempel: „Kann sie niemanden nennen, sagt sie das.“ und neue Grenze (MECH 4.4, ZG 4.9); Etikett mit Rollenbezeichnung (MECH 5.3, ZG); Umschreibungen der Hefte in MECH 9.14. |
| P2-10 | klein | behoben | Neue Tischregel R-13 wörtlich; Kurzform „So spielt ihr“; RK 6.6; MECH 0.2. |
| P2-11 | klein | behoben | Wie P14-11. |
| P2-12 | klein | behoben | MECH 9.9: Nennt die Karte niemanden am Tisch oder nur Herrn Schneider, fragt der Detektiv in die Runde; der Erzähler antwortet nie für Herrn Schneider. |
| P2-13 | klein | behoben | MECH 5.3 Zeynep; MECH 3.4 FM9, FN3, WE3 nach Vorschlag, dazu NN3 (Azra), PM3 und MR4 mit Rundensperren; MECH 6.3 Zeile 10. |
| P2-14 | klein | behoben | Überall 23:57 (RK 3.5, 7.4, 8.1); siehe P3-01. |
| P2-15 | klein | behoben | Wie P14-K01. |

### Protokoll 3 (Zeitstrahl- und Orts-Konsistenz)

Ausführlich: `bibel/tests/P3-runde1.md`.

**Ergebnis Runde 1:** Cans, Ahmets und Fatmas Alibis geometrisch und akustisch sauber; Ollis Weg, Eisklirren und Versteck unbeobachtet; Joannas Liste stimmt; kein Doppelort. Befunde zu Uhrzeit-Schreibweisen, Handys, Geruch, Teilfeldnamen und Tempo. 0 Blocker, 5 mittel, 19 klein.

| Befund | Schwere | Ergebnis | Behebung oder Begründung |
|---|---|---|---|
| P3-01 | mittel | behoben | Ahmets Weg hinter die Theke überall 23:57 (RK 7.3, 3.5, 7.4 Zeitleiste und „Was nur du weißt“ Nr. 2, 8.1; ZG 5.4); Regel in WELT 0.2. |
| P3-02 | mittel | behoben | Handys schon um 23:00 beim Ratespiel im Korb (WELT 0.3 K-23, 3.3, 3.4; MECH 1.5; ZR 2.5, 8.5, 8.6; ZG 4.4). Die Sätze „Dein Handy hast du seit kurz nach zwölf zurück“ sind damit wahr. |
| P3-03 | mittel | behoben | WELT 3.6, 5.2, 7.3 wörtlich nach Vorschlag; ZR 3.5 „Vermutet“, ZR 3.8 Runde 3. Der Protokoll-Abschnitt ZR 12 ist nicht übernommen (19.3). |
| P3-04 | mittel | behoben | „kurz vor zwölf“ nur noch für 23:55 bis 23:57 (WELT 0.2); Joanna, Tim und die Zeitspalten neu (MECH 5.3, 9.11 Teil B; ZG 0.4, 3.4, 3.5, 3.7, 4.4, 4.6, 4.8, 4.12, 6.4; ZR 5.5). ZG 10 und ZR 12 sind nicht übernommen. |
| P3-05 | mittel | behoben | Eine Liste der Feldnamen in WELT 2.1, wörtlich in MECH 10.2 und ZG 0.6; 8b = Wendeltreppe und Turm-Toilette (WELT 4.1, 4.2). |
| P3-06 | klein | behoben | Ollis Rückweg 23:58:36 bis 23:58:49, Kriechen bis 23:58:54, Flüstern 23:58:55 (WELT 2.6, 2.8, 3.1, 3.4, 5.1, 5.3, 7.1, W-23; RK 4.1). |
| P3-07 | klein | behoben | 4,2 m festgelegt (WELT 2.5, 2.8; MECH 9.11 „gut vier Meter“). |
| P3-08 | klein | behoben | WELT 5.5: 2,2 m. |
| P3-09 | klein | behoben | MECH 9.5: „Mein Kopf.“ Dann: „Mein Schlüsselbund! Der ist weg!“ |
| P3-10 | klein | behoben | ZR 0.6: Damir, Sibel, Hana nach Vorschlag; Absicherung nur für 23:51. |
| P3-11 | klein | behoben | Emine und Zeynep wörtlich nach Vorschlag (MECH 4.2; ZG 2.6, 6.6). |
| P3-12 | klein | behoben | ZG 5.5 wörtlich; ZG 5.4 angeglichen (Damir erst beim Licht). |
| P3-13 | klein | behoben | Serkan: Ziel Runde 1, Stufe 1, Vermerk, „Nach dem Umdrehen“, Runde 3 „durchs Außentor“ (ZR 0.3, 0.4, 4.5 bis 4.8; MECH 4.2, 6.2, 11.3; WELT 7.3). |
| P3-14 | klein | behoben | ZR 0.5 Tugba I-1.3 nach Vorschlag, mit Platzhalter für Joanna. |
| P3-15 | klein | behoben | WELT 3.3; MECH 1.5; ZR 0.4; auch Fatmas Zeitleiste JM3 (RK 7.4). |
| P3-16 | klein | behoben | MECH 8.3 Kernsatz 1 wörtlich. |
| P3-17 | klein | behoben | RN7-Zeile 23:58 wörtlich (RK 7.5). |
| P3-18 | klein | behoben | „oben auf der Turm-Toilette“ (WELT 4.2, 7.1; RK 5.6). |
| P3-19 | klein | behoben | MECH 1.1: Zeile 6 „–“, Summen „155 min (2 Std. 35 Min.)“ usw. |
| P3-20 | klein | behoben | ZR-09 und die vier Wissenszeilen (ZR 5.5, 6.5, 7.5, 8.5), ohne „hinter sich“, weil der Kopf der Tafel zwischen Korb und Tür liegt; Damirs neue Zeile 23:54 (ZR 2.5); WELT 5.8. |
| P3-21 | klein | behoben | Skizzenblock statt Strickjacke (WELT 3.5, K-24; ZR 0.5, 5.5, 5.6). |
| P3-22 | klein | behoben | Wie P14-K08. |
| P3-23 | klein | behoben | ZG 3.4 neue Zeile, ZG 3.7 „um drei vor zwölf“; WELT 5.8. |
| P3-24 | klein | behoben | WELT 3.4 wörtlich. |

### Protokoll 5 (Vollständigkeit der Teile 00 bis 90) und Regelprüfung (Ton, Spoiler, gleiche Gestalt, E1–E17, A:1–140)

Ausführlich: `bibel/tests/P5+Regeln-runde1.md`.

**Ergebnis Runde 1:** Bestätigt P2-01 und P2-02; dazu Spoiler im Schlusssatz von Ollis Heft, Namen ungespielter Rollen in Wissen-Tabellen, Verwandtschaft als Grund, Anglizismus „Check“, fehlende Absätze für Teil 90 und Heftaufbau der Zeugen. 5 Blocker, 7 mittel, 16 klein.

| Befund | Schwere | Ergebnis | Behebung oder Begründung |
|---|---|---|---|
| P5-B1 | blocker | behoben | Wie P2-01; RK 6.9 Hinweis wörtlich. |
| P5-B2 | blocker | behoben | Wie P2-02; MECH 6.1 M9. |
| P5-B3 | blocker | behoben | Schlusssatz aller vier „Ab dann“: „Mehr gibst du nicht zu. Dabei bleibst du.“ (RK 2.7, 3.7, 4.7, 5.7); „Mit dem Scheppern hast du nichts zu tun“ steht nur in WW4, JM3, YW4 unter „Dein Heft und die Wahrheit“; RK 8.2 Zeile; MECH 10.4. |
| P5-B4 | blocker | behoben | Platzhalter für Damir, Serkan, Wojtek, Sibel (ZR 2.5, 4.5, 6.5, 1.5) und Tim, Joanna (ZG 3.4, 4.4); Regel und Prüfer in ZG G-08, ZR ZG-10, WELT 0.2. |
| P5-B5 | blocker | behoben | ZG 1.5: „Ich hab Ahmet etwas versprochen. Über seine Sachen redet er selbst.“ |
| P5-M1 | mittel | behoben | „Taschenkontrolle“ und „Marker-Probe“ in allen Teilen (Grammatik angepasst); Wirkung neu (MECH 4.4, ZG 5.8); A:102 in MECH 12a. |
| P5-M2 | mittel | behoben | Absätze für Teil 90 wörtlich in RK 2.12, 3.12, 4.12, 5.12. |
| P5-M3 | mittel | behoben | Erzähler-Bonus im Erzählerheft (MECH 9.1 Seite 13–14, 9.12). |
| P5-M4 | mittel | behoben | ZG 0.6 (mit P14-17). |
| P5-M5 | mittel | behoben | Grenze der Taschenkontrolle ohne Kopf-Satz (MECH 4.4, ZG 5.8); interne Regel in MECH 4.3. |
| P5-M6 | mittel | teilweise behoben | Z-Falz für Geheimnis- und Indizkarten (MECH 0.2, 3.1, 3.3, 4.1, 10.1, 10.5); Erzählerheft Seite 2 wörtlich (MECH 9.1). Nicht übernommen: Umbenennung „umdrehen“ → „aufklappen“; der Begriff bleibt und ist definiert (I-12). Beim Schneiden bleibt Text sichtbar (19.2 Nr. 1). |
| P5-M7 | mittel | behoben | Neue Liste MECH 12a „Abweichungen vom Auftrag“. |
| P5-K1 | klein | behoben | Wie P3-19. |
| P5-K2 | klein | behoben | Die beiden Sätze in RK 6.5 sind durch P14-03 ersetzt; alle unter 25 Wörtern. |
| P5-K3 | klein | behoben | Regie- und Markersatz für alle vier wörtlich (RK 2.6, 3.6, 4.6, 5.6); RK 1.1, 8.2. |
| P5-K4 | klein | behoben | Wie P2-08. |
| P5-K5 | klein | behoben | MECH 9.1 Seite 15 wörtlich; MECH 4.4. |
| P5-K6 | klein | behoben | Kernsatz „Was wirklich war“ (MECH 8.4, mit Ollis Ärmeln, I-24); Austauschregel in MECH 8.2. |
| P5-K7 | klein | behoben | Kasten „So spielt ihr“ in MECH 1.4, ergänzt um „Karte!“ und „vor allen“. |
| P5-K8 | klein | behoben | MECH 10.2 Titel von Blatt A. |
| P5-K9 | klein | behoben | RK 2.8, 3.8, ZG 2.6 gekürzt; Zählung RK 8.2, 7.7. |
| P5-K10 | klein | behoben | ZG G-13; ZR 0.7. |
| P5-K11 | klein | behoben | Lejlas Streifen-Vermerk ohne ✗ (MECH 5.3, ZG 1.11). |
| P5-K12 | klein | behoben | JT3-Vermerk wörtlich (MECH 3.3). |
| P5-K13 | klein | behoben | MECH 9.7 Schritt 6. |
| P5-K14 | klein | behoben | MECH 9.8 Schluss Runde 2. |
| P5-K15 | klein | behoben | MECH 2.6 Seite 3 „Kein Bund ☐“, 10.1 Teil 01 6 / 6 / 6. |
| P5-K16 | klein | behoben | ZG 3.4: „Hier, dein Eis. Hat gedauert.“ |

### Summe Runde 1

101 Befunde: 9 Blocker, 32 mittel, 60 klein. Ergebnis: 97 behoben, 2 teilweise behoben, 2 behoben, mit Abweichung.

Alle Blocker und alle mittleren Befunde sind behoben oder mit Begründung teilweise behoben. Teilweise: P14-09 (drei
Zusatzrollen bleiben ohne eingehende Ziele) und P5-M6 (Begriff „umdrehen“ bleibt, Text beim Schneiden sichtbar). Mit
begründeter Abweichung: P14-12 (drei statt vier Zellen) und P2-07 (Titel von VP7). Was offen bleibt, steht in
FALL-BIBEL 19.2. Neue Entscheidungen der Integration: FALL-BIBEL 19.1 (I-01 bis I-24).

Folgeänderungen, die kein Befund verlangte, die aber für die Widerspruchsfreiheit nötig waren: Bonus-Ziele werden nach
dem Stand bei der Anklage geprüft (Folge von P2-03, I-07); Aktionskarten-Kopien in den Heften angeglichen (ZG 1.8,
4.9, 5.8, ZR 8.9); Ollis Domino-Hinweis zählt für Cans Auslöser (c) (MECH 4.2); RK 7.7 neu gezählt; WELT 5.8 sammelt die
abgeleiteten Wahrnehmungen der Rollen.

## Runde 2: Tests der Fall-Bibel nach Integration Runde 1, Integration Runde 2 (2026-11-02)

Geprüft wurde `FALL-BIBEL.md` als Ganzes (Stand Integration Runde 1). Die Integration Runde 2 ändert die Bibel direkt. Alle
Änderungen laufen über Skripte mit Trefferprüfung (`bibel/werkzeug-int2/`: `motor2.py`, `r2_welt.py`, `r2_mech.py`,
`r2_rk.py`, `r2_zg.py`, `r2_zr.py`, `r2_proto.py`, Start mit `lauf.py`). 224 geprüfte Ersetzungen, keine ohne Treffer. Der
Stand vor Runde 2 liegt als `werkzeug-int2/FALL-BIBEL.vor-runde2.md`. Längen sind mit `werkzeug-int2/zaehle2.py` nachgezählt;
das Werkzeug gibt für den alten Stand genau die Werte aus RK 7.7 der Runde 1 aus. Neue Entscheidungen: FALL-BIBEL 19.4
(I-25 bis I-41). Offene Punkte: FALL-BIBEL 19.2 (Stand nach Runde 2).

### Ergebnis je Protokoll

- **Protokoll 1 (Interaktion und Pausen):** Keine Rolle ist ohne Auftrag; Joanna, Tim, Marek und Lejla haben in jeder Runde
  Arbeit. Schwächen: Emine musste beim „Zeitstempel“ lügen oder ihre Sperre brechen, fünf Bonus-Ziele erfüllten sich von
  selbst, Tandem 2 kam bei 15 bis 18 Personen nicht in Gang, Damir und Wojtek wurden nie angesprochen.
- **Protokoll 2 (Domino-Ketten):** Die Ketten tragen in allen vier Besetzungen ohne Sackgasse und ohne Zirkel; alle drei
  Unschuldigen sind entlastbar, alle Beweise zeigen auf Olli. Schwächen: „vor allen“ zu eng (Ollis und Cans Auslöser
  strittig), FN3 entscheidet den Fall faktisch in Runde 2, „Kein Schlüsselbund“ nach dem Eiskübel legt einen falschen Schluss nahe.
- **Protokoll 3 (Zeitstrahl und Orte):** Kein Blocker. Alibis von Can, Ahmet und Fatma, Ollis unbeobachteter Weg (Lichtregel
  W-23, auch geometrisch), Joannas Liste und die vier Fassungen halten; keine Rolle an zwei Orten. Schwächen: Ausrichtung der
  langen Tafel, zwei Can-Antworten gegen seine offene Karte, Fatmas „sofort“-Satz, Reste bei Uhrzeiten und Hörregeln.
- **Protokoll 4 (Skalierung 6 bis 20):** Jeder Meilenstein ist bei jeder Personenzahl erreichbar, kein Ziel läuft ins Leere.
  Schwächen in großen Runden: R-02 gegen R-13 ab 12 Personen, Gegenüberstellung ab 14 zu kurz, Detektiv-Aufgaben „Frag alle“.
- **Protokoll 5 (Vollständigkeit und Regeln):** Keine Platzhalter, keine Schlag-Verben, kein Blut, kein Alkohol, keine Sätze
  über 25 Wörter. Schwächen: Zusatzheft passt nicht auf zwei Seiten, Erzählerheft ohne „Was alle wissen“, Rundenstart 1 deutet,
  „Was du bei dir trägst“ in du-Form, „Sorry“, veraltete Verweise.

### Protokoll 2 (Domino-Ketten), Runde 2

Ausführlich: `bibel/tests/P2-runde2.md`. 0 Blocker, 3 mittel, 8 klein.

| Befund | Schwere | Ergebnis | Behebung oder Begründung |
|---|---|---|---|
| P2-16 | mittel | behoben | R-13 neu: „Der ganze Tisch hört zu“, mit Ortstermin, Impuls-Antworten, Vorlesen einer Karte; Verhörstuhl nur, solange die anderen Gespräche ruhen (mit P145R2-M01, I-25). Auf Sätze bis 25 Wörter gekürzt. R-03: „Karte!“ bei jeder Personenzahl (auch MECH 1.3 b, 9.13). R-06 „vor allen vorgelesene Notiz“. Kurzform, MECH 0.2, RK 6.6 angeglichen. Olli (a) in RK 4.7 und MECH 4.2. Zusatz „Stell diese Frage vor allen. Ruf dafür den Erzähler.“ in ZG 1.7 und ZG 4.8 R1-1. |
| P2-17 | mittel | behoben, mit Abweichung | FN3 ohne „frische“ (Teil 90 und WELT 6 behalten es); „Wenn es eng wird“ gilt in allen vier Fassungen, sobald der Fall eintritt; RK 7.1; MECH 3.5 Nr. 2 ergänzt. Abweichung: Ollis neuer Tropfen-Satz gilt nur bei offener Karte (sonst wäre „Kalk und Wachs hab ich von der Bogentür“ in Runde 2 ein vorzeitiges Geständnis); für die Zeit davor bekommt Olli in Stufe 1 die Zeile „Rote Tropfen? Keine Ahnung.“ zum Handschuh. Die Ausrede berührt den Kerzenständer nicht. RN7 bleibt unter zehn Prozent (RK 7.7). |
| P2-18 | mittel | behoben | DM3, WJ9, FX3 nennen ihren Platz; AD3 zur Gleichheit auch. MECH 3.1 Nr. 5 und RK 6.7 Nr. 6 wörtlich nach Vorschlag. |
| P2-19 | klein | behoben | Ahmet (c) und Can (c) mit „Was davon zuerst da war, ist egal.“; MECH 4.2 Tabelle und Hinweis. Cans (c) auf 25 Wörter gekürzt („sagt: Das Gesicht kam aus dem Vorratsraum“). |
| P2-20 | klein | behoben | Domino-Frage MECH 9.9 wörtlich nach Vorschlag; allgemein durch R-14 (P145R2-M04). |
| P2-21 | klein | behoben | Zeitstempel-Grenze wörtlich (28 Wörter) in MECH 4.4 und ZG 4.9; Zeile „Wo warst du um 23:51 Uhr?“ in RK 2.6 bis 5.6 (alle wahr); „sieben Ausweichsätze“ in RK 1.1, 1.3, 8.2; Budget Stufe 1 120–180, Seite 2 465–535; RK 7.7 neu gezählt. |
| P2-22 | klein | behoben | ZG 0.6 und ZR 0.7: Die Spalte „Worauf du hinauswillst“ wird nicht gedruckt. |
| P2-23 | klein | behoben | ZG 4.5 wörtlich nach Vorschlag. |
| P2-24 | klein | behoben | RK 6.9 wörtlich nach Vorschlag. |
| P2-25 | klein | behoben | RN7 „Dein Heft und die Wahrheit“ wörtlich (31 Wörter, +5,1 %). |
| P2-26 | klein | behoben, mit Abweichung | Nicht in zwei Zeilen geteilt, sondern nach P3R2-04 beide Gänge unter 23:57 (A:41 nennt 23:57 für Olli); I-27. |

### Protokoll 3 (Zeitstrahl und Orte), Runde 2

Ausführlich: `bibel/tests/P3-runde2.md`. 0 Blocker, 3 mittel, 19 klein.

| Befund | Schwere | Ergebnis | Behebung oder Begründung |
|---|---|---|---|
| P3R2-01 | mittel | behoben | WELT 2.1 Zone 1 (Kopf am Nordende, Handykorb am Ostrand), fünf neue feste Punkte in WELT 2.3, WELT 5.5 Zeile Ost-Saal. |
| P3R2-02 | mittel | behoben | RK 1.8 Can I-2.2 und I-3.1 wörtlich nach Vorschlag (in beiden Lagen wahr); Zählung 139 Wörter. |
| P3R2-03 | mittel | behoben | RK 8.1 Fatma und RK 3.5 Nr. 9 nach Vorschlag. |
| P3R2-04 | klein | behoben | ZG 4.4 eine Zeile 23:57; RN7 23:54 und 23:57 nach Vorschlag; WELT 0.2 neue Regel für Ollis Gang. |
| P3R2-05 | klein | behoben | ZG 0.4 Tim I-1.1 nach Vorschlag. |
| P3R2-06 | klein | behoben | ZG 3.7 R3-1 mit 23:52. |
| P3R2-07 | klein | behoben | ZG 3.6 „Um 18:35 Uhr“; ZG 3.1 „um 18:45 Uhr das Möbelwachs“. |
| P3R2-08 | klein | behoben | MECH 9.11 „gut acht Meter“ und Eiskübel-Zeile nach Vorschlag. |
| P3R2-09 | klein | behoben | FX3, WELT 5.4, WELT 2.8 nach Vorschlag. |
| P3R2-10 | klein | behoben | WELT 2.6, WELT 2.8 (Zeile Tim am Kasten), MECH 9.11 Prüfung. |
| P3R2-11 | klein | behoben | WELT 3.4, 23:58:05. |
| P3R2-12 | klein | behoben | WELT 5.1 (Olli, Tim hören den Ruf); ZG 3.4 Zeile 23:58. |
| P3R2-13 | klein | behoben | WELT 2.7 neue Zeilen „in der Tür“ und „23:00“, Folgen-Satz zum Ost-Saal; WELT 3.3 „sehr laut“; WELT 5.6. Die zehn abhängigen Texte bleiben so richtig. |
| P3R2-14 | klein | behoben | WELT 3.3: Handy-Zeile vor der Streit-Zeile, Wortlaut nach Vorschlag; ZR 8.5. |
| P3R2-15 | klein | behoben | MECH 1.6, Azra R3-1, Wojtek R1-1, Joanna ZG 4.6; dazu Regel in WELT 0.2. |
| P3R2-16 | klein | behoben | WELT 0.2, WELT 7.3, ZR 5.13, ZR 5.6, ZR 0.5. |
| P3R2-17 | klein | behoben, mit Abweichung | 4d nach Vorschlag; 4b reicht von der Mitte bis vor das Ostende, nicht ab dem Westende, weil der Platz vor dem Westende nach WELT 2.1 zu 4a gehört (Ollis Warteplatz; I-28). |
| P3R2-18 | klein | behoben | ZR 0.7: „Deine Marker“ wörtlich für alle acht. |
| P3R2-19 | klein | behoben | WELT 3.3: Zeile in den Windfang, nach Aylins Einlass-Zeile verschoben. |
| P3R2-20 | klein | behoben | WELT 3.3 neue Zeile 23:40 Kaminsaal; WELT 5.7 (Emine sieht Fatma erst an der Vitrine). |
| P3R2-21 | klein | behoben | WELT 2.7 Zeile Riechen. |
| P3R2-22 | klein | behoben | MECH 12a: zwei Zeilen A:52 (Marek) und A:54 (Zeynep). |

### Protokolle 1, 4 und 5 (Interaktion, Skalierung, Vollständigkeit und Regeln), Runde 2

Ausführlich: `bibel/tests/P1+P4+P5-runde2.md`. 0 Blocker, 10 mittel, 21 klein.

| Befund | Schwere | Ergebnis | Behebung oder Begründung |
|---|---|---|---|
| P145R2-M01 | mittel | behoben | R-02 (Satz zu „Alle mal herhören!“; „wer zuhören will, kommt dazu“ bleibt), R-13 mit P2-16 abgestimmt, RK 6.6, MECH 9.13 Zeile 12. |
| P145R2-M02 | mittel | behoben | MECH 1.3 und 9.9 wörtlich nach Vorschlag, mit Lastrechnung; MECH 0.2, 9.13 Zeile 14; 19.2 Nr. 3. |
| P145R2-M03 | mittel | behoben | RK 6.5 Runde 2 Ziel 2 und Runde 3 Ziele 1 und 2 über Impulse; Prüfsatz ergänzt. |
| P145R2-M04 | mittel | behoben | Neue Tischregel R-14 (MECH 1.4, 0.2, Kurzform, RK 6.6); „Beleg bitte!“ in MECH 4.4 und ZR 7.9; ZG 2.5 neue Zeile; ZG G-11 und ZR ZG-13. |
| P145R2-M05 | mittel | behoben | ZR 3.7 Auslöser 3 „vor allen“; Wojteks Frage an Hana vor allen; RK 6.12 neue Zeile „15–20“; Azra R1-2 an Serkan; ZR 0.3, 0.4, 9.1, 9.2; 19.2 Nr. 2. |
| P145R2-M06 | mittel | behoben | ZR 0.7 drei Seiten; MECH 10.1 (24 Seiten bei 20 Personen), MECH 10.3; 19.2 Nr. 4. |
| P145R2-M07 | mittel | behoben | Bonus-Ziele Tim, Azra, Wojtek, Aylin, Tugba nach Vorschlag, je mit angepasster Prüfzeile; ZR 0.3; Regel in MECH 7.3. |
| P145R2-M08 | mittel | behoben | MECH 6.1 M4 („Miete“ allein genügt nicht; dazu „Keller hat nichts gekostet“, weil PM3 so formuliert ist; „Umschlag“ nur mit „Ascheneimer“); WE3-Vermerk „Hinweis“; MECH 3.2. |
| P145R2-M09 | mittel | behoben | MECH 9.1 Seite 7, MECH 1.5, MECH 9.6. |
| P145R2-M10 | mittel | behoben | MECH 9.8 Rundenstart 1 nach Vorschlag; WELT 0.3 neue Zeile K-25; Verweise K-01 bis K-25. |
| P145R2-K01 | klein | behoben | WELT 3.4 und RN7 „Hier, dein Eis. Hat gedauert.“; RK 0.3 ohne Ausnahme. |
| P145R2-K02 | klein | behoben | FK3 „Im Steinbogen liegt kein Schlüsselbund.“ |
| P145R2-K03 | klein | behoben | MECH 9.14 Umschreibungen und Satz zu „ein Gast“ und „jemand“. |
| P145R2-K04 | klein | behoben | MECH 5.2, ZG 4.12, Z-11. |
| P145R2-K05 | klein | behoben | MECH 10.2 Lage der Felder auf Blatt B. |
| P145R2-K06 | klein | behoben | MECH 3.1 Nr. 9, MECH 4.1 (Raster auf Feld 3), MECH 10.5 (Papier ab 120 g). |
| P145R2-K07 | klein | behoben | RK 6.6, MECH 9.7. |
| P145R2-K08 | klein | behoben | ZR 8.3 wörtlich nach Vorschlag. |
| P145R2-K09 | klein | behoben | Alle 18 Texte „Was du bei dir trägst“ in der Ich-Form; Regel in RK 1.1, ZG 0.6, ZR 0.7. Joannas Satz zum Foto steht als Hinweis außerhalb des Vorlesetexts. |
| P145R2-K10 | klein | behoben | MECH 1.5: Dankeskarten-Satz ab 13 Personen. |
| P145R2-K11 | klein | behoben | ZR 7.5 neue Zeile 23:55. |
| P145R2-K12 | klein | behoben | RK 2.11 Zeile Damir. |
| P145R2-K13 | klein | behoben | MECH 2.6 (Aktionskarten fehlender Zeugen auf Seite 6), RK 6.8, MECH 8.4 (Seite 10 ab 15 Personen), MECH 10.1 Teil 90 9 / 10 / 12. |
| P145R2-K14 | klein | behoben | MECH 12a: Zeilen A:44, A:52, A:87, A:92. |
| P145R2-K15 | klein | behoben | Weg „nein“ des Vorschlags: Die Welt gibt Emine keine neue Beobachtung über Rollen 1–5 (WELT 5.5). Prüfsatz in MECH 4.2 mit Abweichungsvermerk; MECH 12a Zeile A:92; I-40. |
| P145R2-K16 | klein | behoben | MECH 7.3 Regeln, erster Satz mit Ausnahme. |
| P145R2-K17 | klein | behoben | MECH 2.6, 4.2 (zwei Stellen), 5.3, 8.4, 9.4 (zwei Stellen). Bei Joanna mit den abweichenden Nummern (Streifen ZG 4.12, Teil 90 ZG 4.13). |
| P145R2-K18 | klein | teilweise behoben | ZR 0.7: Muster und Beispiel Sibel wörtlich, wie vorgeschlagen. Die übrigen sieben Wortlaute setzt der Generator aus dem Profil x.1 (19.2 Nr. 11). |
| P145R2-K19 | klein | behoben | RK 7.5 Prüfsatz. |
| P145R2-K20 | klein | behoben | Serkan R1-2 an Damir, Aylin R2-2 an Wojtek (beide Fragen mit offenem Wissen beantwortbar: Damirs Marker, Wojteks Auftritt und Stufe 1); ZR 9.2; 19.2 Nr. 2. |
| P145R2-K21 | klein | behoben | MECH 9.12 und MECH 7.3. |

### Summe Runde 2

64 Befunde: 0 Blocker, 16 mittel, 48 klein. Ergebnis: 60 behoben, 3 behoben mit begründeter Abweichung (P2-17, P2-26,
P3R2-17), 1 teilweise behoben (P145R2-K18). Alle mittleren Befunde sind behoben.

Folgeänderungen, die kein Befund verlangte, die aber für die Widerspruchsfreiheit nötig waren: Begriff „Dazu sag ich jetzt
nichts“ in MECH 0.2; Kapitel 0 (Nummernbereiche R-14, K-25, I-41; Stand Runde 2); RK 7.1 Zeile „Wenn es eng wird“; RK 7.7
neu gezählt (RN7 gesamt +6,7 %, Zeitleiste +8,3 %, „Wenn es eng wird“ +7,9 %, Heft Seite 2 alle vier im Budget); I-13 mit
Hinweis auf I-25; 19.2 neu gefasst; 19.4 neu (I-25 bis I-41); WELT 0.2 zwei neue Zeitregeln; WELT 2.8 Zeile „Tim am Kasten“;
ZR 0.3 Übersicht der Bonus-Ziele; ZR 9.1 Summe Can; RK 6.5 Prüfsatz; WE3-Vermerk mit Begründung.
