# Gegenprüfung P5R3-01: Teil 90 ohne Falzlinien und Verschlussanleitung

Ergebnis: **bestätigt, Schwere mittel**, mit zwei Berichtigungen (Lage des Codekastens, Papierempfehlung unnötig).
Repository nicht geändert. Eigene Dateien im Arbeitsordner der Prüfung außerhalb des Repositorys, unter `r3/gp-p5r3-01/` (Seitenbilder, bbox).

## 1. Steht das Zitat so im Druck?

Geprüft in allen sechs Sätzen (6, 10 und 20 Personen, jeweils w und m), Text aus `druck-r3/text/{w,m}/...` und
Bilder mit `pdftoppm -r 60` (p6 w Teil 90 S. 1 und 2, Teil 11 S. 1; p20 m Teil 90 S. 1).

| Fundstelle | Wortlaut im Druck | 6w | 6m | 10w | 10m | 20w | 20m |
|---|---|---|---|---|---|---|---|
| 00-erzaehlerheft.pdf S. 2, Tabelle „Drucken, schneiden, falten“, Zeile 90 | „Falte Teil 90 und versiegle es.“ (2 min) | ja | ja | ja | ja | ja | ja |
| dieselbe Tabelle, Zeile „alle“ | „Druck alles einseitig und lies dabei nichts. Nimm für Teil 02 und Teil 20 festeres Papier ab 120 Gramm. Dann scheint nichts durch.“ | ja | ja | ja | ja | ja | ja |
| 90-aufloesung-versiegelt.pdf S. 1 | nur „Auflösungsheft“, Kasten mit „U4YRK“ und „Versiegelt – erst nach der Anklage öffnen“; keine Falzlinie, keine Anleitung | ja | ja | ja | ja | ja | ja |
| 90-aufloesung-versiegelt.pdf S. 2 | „Es war Olli. Um drei vor zwölf stand er am Eiskübel.“ (erste Zeile im Kasten VORLESEN) | ja | ja | ja | ja | ja | ja |

Das Zitat stimmt wörtlich. Teil 90 hat 9 Seiten (6 P.), 10 (10 P.) und 12 (20 P.).

## 2. Lage der Lösung hinter dem Deckblatt (gemessen mit `pdftotext -bbox`)

- S. 1: „Auflösungsheft“ 77–133 mm × 27–35 mm; „U4YRK“ 75–134 × 47–65 mm; Hinweiszeile 67–143 × 68–73 mm.
  Der Kasten selbst ist nur ein Rahmen (1,6 pt), gemessen am Bild etwa 58–151 mm × 41–78 mm, innen weiß. Er deckt
  also nichts ab. Berichtigung zum Befund: 67–143 mm ist die Hinweiszeile, nicht der Kasten.
- S. 2: „Was wirklich war“ 16–60 × 26–33 mm; „Es war Olli.“ 20–40 mm × 48–53 mm, Schrift etwa 11 pt; die
  übrigen Zeilen des Kernsatzes bis etwa 78 mm. Gleiche Lage in p10 und p20 (bbox identisch).
- „Es war Olli.“ liegt damit links neben dem Rahmen, hinter völlig unbedrucktem Papier von S. 1.

## 3. Löst ein anderer gedruckter Text das Problem?

- Erzählerheft S. 2: nur „Falte Teil 90 und versiegle es.“ Kein Wie, keine Faltart, kein Verweis auf eine Anleitung.
  Die Empfehlung „Am besten schneidet und faltet jemand, der heute nicht mitspielt“ schützt beim Falten, nicht den
  Abend über.
- Teil 90 S. 1: keine Anleitung (anders als Teil 11 S. 1 „So verschließt du diese Fassung“, 1. bis 4., zwei
  gepunktete Falzlinien bei 99 und 198 mm).
- Papier: 120 g nur für Teil 02 und Teil 20.
- „Was an wen geht“: Teil 90 liegt versiegelt beim Erzähler bis zur Auflösung. Kein anderes Heft, keine Karte regelt
  das Versiegeln von Teil 90.

Nichts im Druck löst es.

## 4. Bewusste Entscheidung oder schon bekannt?

- ENTSCHEIDUNGEN E1–E22: nichts zu Teil 90 als Gegenstand (E9 betrifft Teil 11).
- FALL-BIBEL MECH 12a, WELT 0.3 (K-01 bis K-25), 19.2: Teil 90 nur bei Sekunden, Summe 2.550 €, Olli-Sonderregel,
  Zeitleiste, Bonus-Ziel-Prüfung. 19.2 Nr. 1 nimmt nur das Schneiden (Text sichtbar beim Schneiden) bewusst hin,
  nicht das Durchscheinen am Abend.
- Die Bibel sagt zu Teil 90 nur „A4 hoch, falten, versiegeln“ (MECH 10.1) und „90 | falten und versiegeln | 2 min“
  (MECH 10.5); die Faltart ist nicht entschieden, also auch nicht bewusst offen gelassen.
- Liste der bekannten Punkte im Auftrag: nicht enthalten.
- Frühere Runde: P145R2-K06 (tests/P1+P4+P5-runde2.md Z. 477 ff.) hat das Durchscheinen für Karten und Streifen
  gemeldet („Auf 80-g-Papier unter Lampenlicht ist 9-pt-Schrift durchs Papier zu ahnen“); behoben wurde es nur für
  Teil 02 und 20 (Raster, 120 g). Teil 90 wurde dort nicht betrachtet.
- Der Code selbst zeigt, dass das Problem bekannt ist: `fassungen.dart` Z. 11–13 „direkt hinter dem Code liegt die
  Anleitung, nie Text der Fassung, damit nichts durchscheint“; `satz.dart` Z. 706–709 setzt das Deckblatt von Teil 90
  ausdrücklich ins obere Drittel, „damit es nach dem Falten in Dritteln vorn bleibt“. Gedruckt wird diese Faltart
  aber nirgends.

Keine bewusste Entscheidung, nicht schon bekannt.

## 5. Ist die Wirkung real?

- Jede Faltung, bei der der Code außen bleibt (halb oder in Dritteln, S. 1 nach außen), legt die obere Hälfte bzw.
  das obere Drittel von S. 2 mit der Schrift nach oben, nicht gespiegelt, direkt hinter S. 1. Darüber liegt genau ein
  Blatt Normalpapier, unbedruckt an der Stelle von „Es war Olli.“
- Nach dem projekteigenen Maßstab (K06: 9 pt unter Lampenlicht durch 80 g zu ahnen; Erzählerheft: „Dann scheint
  nichts durch“ nur mit 120 g) ist 11-pt-Schrift hinter einem 80-g-Blatt erkennbar. Teil 90 liegt rund 150 Minuten
  vor dem Erzähler, der laut AUFTRAG Z. 25 („WICHTIG“) den Täter nicht kennen darf.
- Teil 11 ist auf demselben Papier besser geschützt (zwei Lagen, Schrift innen, hinter dem Code nur die Anleitung).
  Das wichtigste Geheimnis des Abends hat den schwächsten Schutz und keine Anleitung.
- Nicht sicher ist, ob ein bestimmter Tisch es tatsächlich liest (Papier, Licht, Faltart). Deshalb kein blocker.

## 6. Schwere

**mittel.** Belegt ist: fehlende Anleitung (der Erzähler muss improvisieren) und die Lösung direkt hinter einem
unbedruckten Blatt. Die Folge (verratene Lösung an den nicht-allwissenden Erzähler) wäre ein blocker, tritt aber nur
mit Wahrscheinlichkeit ein. Mehr als Kosmetik, weil eine Kernforderung des Auftrags (A:25) gefährdet ist.

## 7. Vorschlag (umsetzbar ohne Suchen)

Statt 120-g-Papier (bei 9 bis 12 Blättern in Dritteln schwer zu falten, und Teil 11 kommt ohne aus) dieselbe
Faltart wie Teil 11: Seiten 2 bis N in Dritteln mit der Schrift nach innen, hinter das mittlere Drittel von S. 1,
unteres und oberes Drittel darüber. Dann liegen überall mindestens zwei Lagen Papier über der Schrift, und hinter dem
Code liegt nur die Anleitung.

1. **Code, gemeinsame Außenseite.** `packages/mordakte_core/lib/src/party/druck/kammer/satz.dart`,
   `KammerSeiten.versiegelt(...)` (Z. 710–740): neuen optionalen Parameter `List<String> verschliessen = const []`
   (Eintrag 0 Überschrift, 1 bis 4 nummerierte Schritte). Ist er nicht leer, die Seite wie
   `fassungen.dart` `_aussenseite()` (Z. 233–278) als `vollSeite` mit `pw.Stack` setzen: zwei gepunktete Falzlinien
   bei `a4Hoch.height / 3` und `2 * a4Hoch.height / 3` (wie `falz()` Z. 256–266), Anleitung ab `2 * drittel + 8 mm`
   bis zum unteren Rand mit `passendeGroesse(..., start: 10)` (wie Z. 248–254). Titel, Code und Hinweis bleiben im
   oberen Drittel. Am besten `_aussenseite` dorthin ziehen und von Teil 11 und Teil 90 gemeinsam nutzen. Die Aufrufe
   in `test/party/kammer/dateien_test.dart` Z. 127 und 130 bleiben gültig (Parameter optional).
2. **Code, Teil 90.** `aufloesung.dart` Z. 107, alt:
   `s.versiegelt(code: k.fallCode, titel: u('deckblatt.titel'), hinweis: u('deckblatt.hinweis'));`
   neu:
   `s.versiegelt(code: k.fallCode, titel: u('deckblatt.titel'), hinweis: u('deckblatt.hinweis'), verschliessen: [u('verschliessen.titel'), for (var n = 1; n <= 4; n++) u('verschliessen.$n', {'letzte': '${_seiteRueckblende + _rest}'})]);`
   `{letzte}` ergibt 9 (6–8 Personen), 10 (9–12), 11 (13–17), 12 (18–20), passend zu `_restSeiten` Z. 54.
3. **Inhalt, Teil 90.** `content/kammerspiel/schlosskeller/ui/90.json`, nach `deckblatt.hinweis` neu:
   - `"verschliessen.titel": "So verschließt du das Auflösungsheft"`
   - `"verschliessen.1": "Lege die Seiten 2 bis {letzte} aufeinander und falte sie zusammen in Drittel, die Schrift nach innen. Lies dabei nichts."`
   - `"verschliessen.2": "Lege sie auf die leere Rückseite dieses Blatts, genau hinter das mittlere Drittel."`
   - `"verschliessen.3": "Falte das untere Drittel an der unteren Linie nach hinten. Falte dann das obere Drittel an der oberen Linie nach hinten darüber."`
   - `"verschliessen.4": "Klebe die offenen Ränder mit Klebeband zu. Außen stehen jetzt nur noch „Auflösungsheft“ und der Code."`
   Schritte 2 und 3 wörtlich wie `ui/11.json`, damit beide Teile gleich gefaltet werden.
4. **Inhalt, Erzählerheft.** `content/kammerspiel/schlosskeller/erzaehlerheft.json`,
   `vorbereitung.taetigkeiten[4]` (`"teil": "90"`), `text` alt „Falte Teil 90 und versiegle es.“, neu
   „Falte Teil 90 so, wie es auf seiner ersten Seite steht, und klebe es zu.“; `minuten` 2 → 3. Die Zeile „alle“
   bleibt (kein 120-g-Papier für Teil 90 nötig).
5. **Test.** `test/party/kammer/teil_90_test.dart` Z. 137–138 erwartet auf S. 1 nur Titel, Code und Hinweis; erweitern
   um `verschliessen.titel` und die vier Schritte (mit eingesetztem `{letzte}`) und um zwei Falzlinien wie in
   `teil_11_test.dart`.
6. **Bibel (zur Nachführung).** MECH 8.4 Seite 1: „Deckblatt … Fall-Code U4YRK; zwei Falzlinien und Anleitung zum
   Verschließen wie Teil 11 (RK 7.2)“. MECH 10.5 Zeile 90: „wie auf der ersten Seite beschrieben falten und zukleben“.

Passt zu allen Besetzungen 6–20 und zu w/m: keine Rollen- oder Detektiv-Anrede im neuen Wortlaut; nur `{letzte}`
hängt von der Personenzahl ab. Platz: das untere Drittel (99 mm minus Rand) fasst die vier Schritte wie in Teil 11.
