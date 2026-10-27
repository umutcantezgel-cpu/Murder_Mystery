# Plan: Schlosskeller fertigstellen – Einstimmung, Erzählerakte, „Dein Moment“

## Context

**Der Wunsch des Besitzers:**
1. Vor Runde 1 erzählt der Erzähler eine Vorgeschichte von etwa 5 Minuten.
2. Danach stellt er jede Figur am Tisch vor.
3. Der Erzähler bekommt ein eigenes Dokument mit allen Hintergründen und dem Beziehungsnetz.
4. Der Zufall wird überarbeitet: Die Entscheidung jedes Spielers soll alle betreffen und den Fall spürbar beeinflussen. Ziel ist mehr Spielspaß. Danach gilt das Spiel als fertig.

**Was heute fehlt (Befund):**
- Den Ausgang bestimmen nur die 9 Entscheidungen und die Anklage des Detektivs.
- Die A/B-Gruppenwahl wählt nur einen von drei festen Bonus-Sätzen aus.
- Der Würfel verschiebt nur Nachtminuten, und die verfallen jede Runde.
- „Nochmal“ und „Umweg“ führen zum selben Ergebnis.
- Die persönlichen Ziele werden nie gewertet.
- Das Intro dauert etwa 1,7 Minuten. Eine Vorgeschichte und eine Vorstellungsrunde gibt es nicht.
- Der Erzähler sieht nie Geheimnisse (A-052).

**Entscheidungen des Besitzers (diese Sitzung):**
- Nur **Schlosskeller**. Die anderen vier Akten bleiben nachweislich bitgleich.
- **Erzählerakte:** alles außer dem Täter, für alle 4 Pfade gleich, ohne Fall-Code druckbar.
- **„Weg ändern, Wahrheit fest“:** Der Fall-Code legt Täter und Wahrheit fest. Mit gutem Spiel bleibt der Fall lösbar. Die Spieler verändern Spuren, Würfel, Zeit, Gerüchte, Ereignisse und Ziele und bestimmen das Ende mit.
- **„Würfel bleibt, Spieler formen ihn“.**

## Leitprinzipien

- **Gating:** Neue Fähigkeiten in `content/party/akten.json` (`einstimmung`, `erzaehlerakte`, `einfluss`), nur für den Schlosskeller.
  - Im Kern sind es optionale Parameter mit dem Standard null/aus.
  - **Ohne Schicht läuft alles bitgleich.** Golden `determinismus_soll_k12.g.dart`, der 9.216-Beweis (`partie_test`) und alle Prüfungen der anderen Akten bleiben unverändert grün.
- **Gepinnte Dateien bleiben unberührt** (`tool/kanon_fest.txt`: `entscheidungen.json`, `bonus.json`, `gruppenwahl.json`, `tatmatrix/*`, `wahrnehmung.json`, `basis-ui`). Neue Daten kommen nur in neue Dateien.
- **Pfadblind:** Keine sichtbare Wirkung der neuen Schicht hängt vor dem Finale vom Täterpfad ab. Es gibt nur Züge, Salz-Würfel und statische, öffentliche Eigenschaften der Optionen. Die Täterrolle fällt nie auf (R13).
- **Neue Entscheidungen:**
  - A-063 Einstimmung und Erzählerakte
  - A-064 Einfluss-Schicht
  - A-065 Würfel von Spielern geformt
  - A-066 Ziele, Tischbonus und Auszeichnungen

  Sie stehen in `planung/gesamt/STATUS.md`, gespiegelt als E-046/E-047 in `planung/finalisierung-schlosskeller/ENTSCHEIDUNGSLOG.md`.
- **Neue Regeln:**
  - R18 Einstimmung, R19–R25 Einfluss in `ERZAEHLREGELN.md`.
  - R4/R16 gelten künftig nur noch für Dialoge und Gruppenszenen.
  - Nachträge zu K-06/07/15/19/20/22 in `planung/bollwerk/SPIELKERN.md`.
  - G-1 (Sabotage nur durch den Täter) entfällt in der App-Fassung.

---

## Teil A · Einstimmung: Vorgeschichte und Vorstellung

**Ablauf:** Rollen → **Vorgeschichte** (7 Blöcke, ca. 650 Wörter, ca. 5 Min.) → **Vorstellung** (jede besetzte Figur, dann ein Sammelblock für unbesetzte Gäste, dann der Detektiv m/w) → (Vorspiel, wenn lang) → Intro und Diashow → Runde 1.

- **Unterzustand von `PartyPhase.intro`** nach dem Muster `rundgang`, keine neue Phase.
  - Die Texte gehen nie in `spiel.bausteine`.
  - Unverändert bleiben damit: `ablauf_test`, `bausteine.first=='intro.start'`, die 6 Intro-Texte, die Diashow-Tests und der Golden.
- **Pro Abend schaltbar:** `einrichten(einstimmung: bool = false)`.
  - Im Assistenten ist der Schalter für den Schlosskeller **an**, im Druckspiel aus.
  - Die Zeitschätzung in `party/fassung.dart` steigt um `abendEinstimmungMinuten(rollen)` (5 Min. plus 2, 4 oder 6 Min. je nach Rollenzahl); `fassung_test` wird angepasst.
- **Daten:**
  - `setting.json`: `"vorgeschichte": [7 Teil-IDs]` und `"vorstellung": true`, dazu das strenge Schema.
  - `texte/erzaehler-vorgeschichte.json`: `vorgeschichte.<teil>`, 85–100 Wörter je Block.
  - `texte/erzaehler-vorstellung.json`:
    - `vorstellung.start`
    - `vorstellung.<id>` für alle 20 Figuren, 40–70 Wörter, 3. Person, nur Öffentliches
    - `vorstellung.npc`
    - `vorstellung.detektiv.m|w`
  - Die Titel kommen nach `ui-erzaehler.json`.
  - `index.json` wächst von 58 auf 60 Einträge (`textpruefer_test`).
- **Kern:**
  - `party/pfadwissen.dart`: Die Prüfhilfen werden aus `spoiler_test` herausgezogen, als reiner Umbau.
  - `party/einstimmung.dart`:
    - `Einstimmung.aus(Kanon)`
    - `schritte(rollen, detektiv)`
    - `EinstimmungLauf` (gemeinsame Zustandsmaschine)
    - `katalog()`
    - `pruefeEinstimmung(...)` prüft:
      - Größen
      - Namensregel: In der Vorgeschichte stehen nur die 4 immer besetzten Kernfiguren und Herr Schneider; eine Vorstellung nennt nur Figuren mit kleinerem Besetzungsplatz und nur über **öffentliche** Netzkanten.
      - Ausgewogenheit der 4 Kernfiguren
      - keine 5-Wort-Folgen aus Geheim- oder Pfadwissen, Intro oder Vorspiel
      - Spoiler- und Urteilswörter
      - Ton
  - `erzaehler.dart katalog()` hängt die neuen Schlüssel nur bei vorhandener Einstimmung an. So bleibt `textLuecken` für alle Akten korrekt.
- **Online:**
  - `runden/raum/einstimmung_modul.dart` (`RaumModul`):
    - Nachricht `einstimmung {schritt}|{ueberspringen}`
    - `darfWeiter` ist gesperrt, solange die Einstimmung läuft.
    - Öffentlich: `einstimmung {teil, schritt, kennung, figur}`. Privat beim Vorleser: `einstimmungText`.
  - `rundgang_modul` wartet, bis die Einstimmung fertig ist.
  - `sichtfelder.dart` bekommt den Schlüssel `einstimmung` (die Server-Matrizen ziehen automatisch mit). Der Server-Fabrik bekommt den Parameter dazu.
- **App:**
  - `PartySitzung`: `einstimmung`, `einstimmungWeiter/ueberspringen`, `kannWeiter`-Sperre, Journal.
  - Neuer `bildschirme/einstimmung.dart`:
    - Kapitelzähler
    - `ErzaehlerFeld`; die Stimme liest den Block wortgleich
    - Vorstellungskarte mit Porträt, Rollentitel und Steckbrief-Satz
    - **„gespielt von {Name}“ steht außerhalb des Vorlesetexts**, dazu der Hinweis „Wer genannt wird, steht kurz auf.“
  - Online: `gast_einstimmung.dart` mit „Du bist dran“, außerdem `gastgeber_sitzung` und `erzaehler_begleiter` (Handy des Erzählers).
  - Neue Texte in `app_de.arb`.
  - Dev-Skript: Parameter `einstimmung=1`.

## Teil B · Erzählerakte (nur für den Erzähler)

- **Datei** `content/party/schlosskeller/erzaehlerakte.json`. Wie `steckbriefe.json` liegt sie außerhalb von `Kanon.dateien`, dazu kommt ein Schema. Inhalt:
  - `einleitung`
  - `schneider`, `detektiv`
  - `figuren[]`: `hintergrund` (80–140 Wörter), `zuSchneider`, `stimme` (Sprechtipps im Kartenformat)
  - `netz[]`: `{a, b, art, sichtbar: oeffentlich|heimlich, text}`, etwa 45 Kanten
- **Zur Ladezeit aus dem Kanon gezogen, nicht kopiert:**
  - Name, Alter, Rolle, `motiveAndConflict`, `roleSecret`, `nebendelikt`, `loyalitaet{zu,grund}`
  - Ziele über die Schnittstelle `ZielQuelle`; sie liest die gewerteten Sterne aus Teil C.
  - Nie gelesen werden: Profile, `luegen`, `tatmatrix`, Täter-, Finale- und Auflösungstexte, Bonus, Begründungen.
- **Kern:**
  - `party/erzaehlerakte.dart`: `Erzaehlerakte`, `NetzKante`, `ZielQuelle`. Die API hat keinen Pfad- oder Code-Parameter.
  - `pruefeErzaehlerakte` prüft:
    - Vollständigkeit
    - Netz-Konsistenz: Jede `loyalitaet` ist eine Kante; jedes Paar aus `dossier.wer` ist eine öffentliche Kante; jede Figur hat mindestens 2 Kanten.
    - Pfadfreiheit auf dem **zusammengesetzten** Dokument (5-Wort-Regel gegen `pfadwissenVerboten`, Täter-, Finale- und Auflösungstexte)
    - verbotene Wörter
    - Ton
- **Sichtbarkeit:** nur der Erzähler-Platz.
  - reihum: zugedecktes Pult im `RollenBildschirm` und im Erzählerpult
  - am Erzähler-Handy
  - online am Erzähler-Sitz, bei Gast und Gastgeber
  - nie solo, nie Detektiv, Rolle oder Assistenz, nie nach dem Finale

  Online wird die Akte lokal aus der Akte des Geräts dargestellt. Der Inhaltsabgleich (`inhalt`) garantiert dieselbe Fassung.
- **Ansicht** `lib/party/erzaehlerakte_ansicht.dart`:
  - Reiter „Figuren“: erst die besetzten Figuren, dann „ohne Spieler“.
  - Reiter „Netz“: Ring-Diagramm mit CustomPainter, öffentliche Kanten durchgezogen, heimliche gestrichelt.
- **Druck:**
  - Neue Datei `druck/fest_erzaehlerakte.dart` erzeugt `erzaehlerakte.pdf` im Ordner `4-nur-erzaehler`. Sie enthält eine Netzseite (Ring und Legende) und eine Seite je Figur.
  - Neuer CLI-Befehl `party_druck.dart --erzaehlerakte` (ohne `--code`).
  - Das Erzählerheft (`fest_spielleitung.dart`, `spielleitung.dart`) bekommt die Abschnitte „Vorgeschichte“ und „Vorstellung“, mit einer Zeile „gespielt von: ____“.
  - In `veranstalter.dart` kommen die Dateiliste und die Zeiten dazu.
  - Die Prüfung in `akte_pruefen` umfasst Schema, `_einstimmung` und `_erzaehlerakte`.

## Teil C · „Dein Moment“ – die Einfluss-Schicht

**Mit Schicht läuft eine Runde so ab:** Gespräche, währenddessen **Dein Moment** → **Folgen** werden zu Beginn der Ermittlung vorgelesen → 3 Entscheidungen mit Tischwerten → **Flüstern** (Bonus) → Zwischenresümee.
- Die A/B-Gruppenwahl entfällt in der App-Fassung. Der Moment ersetzt sie.
- Im langen Abend muss der Moment vor der ersten Entscheidung der Runde stehen.

**1. Dein Moment:** Jede besetzte Rolle (Mensch oder Bot) macht pro Runde geheim einen Zug. Online lässt er sich bis zu den Folgen ändern; ohne Wahl gilt „abgewartet“.

| Zug | Ziel | Wirkung | Wer erfährt es |
|---|---|---|---|
| Zeigen | Figur X ≠ ich | +1 Tischstimme auf Optionen mit X im Bezug; Spuk 1 | öffentlich, anonym: „Jemand/Mehrere tuscheln über X“ |
| Decken | Figur X (auch ich) | −1 Tischstimme auf Optionen mit X im Bezug | X privat: „Jemand hält zu dir“; Gefahr: ertappt |
| Helfen | – | +3 Nachtminuten (höchstens +9 je Runde); Zusammenhalt 1 | anonym |
| Auspacken (einmal am Abend) | – | eigenes Geheimnis in die Funde (siehe unten); Zusammenhalt 2 | öffentlich, mit Namen |
| Ablenken | – | −4 Nachtminuten (höchstens −8 je Runde); Spuk 2; Zusammenhalt −1 | öffentlich, mit Namen, mit eigenem Gag |
| Lauschen | Figur X ≠ ich | erfährt Zug und Ziel von X in dieser Runde | nur ich |

- **Auspacken** liefert nur Quellen, die in allen Pfaden gleich sind (`pfade: alle`). `akte_pruefen` prüft das.
  - Die vier Kernfiguren liefern ihr Nebendelikt-Faktum. Ein unschuldiger Kern mit Alibi ist damit nach R-ENTLASTET entlastet. Der Täter hat in seinem eigenen Pfad nie ein Alibi und wird deshalb nie entlastet. Die Form ist dieselbe, nur die Wahrheit unterscheidet sich.
  - Die Loyalen verraten eine Beobachtung über ihren Freund (Lejla, Emine, Zeynep, Wojtek, Joanna, Aylin).
  - Die übrigen Figuren liefern neutrale oder harmlose Beobachtungen.
  - Die bisherigen A-Texte aus `wahlen-*.json` werden zu den Erzählerzeilen fürs Auspacken.
- **Bezug:** Je Option eine statische Figurenmenge in der neuen Datei `content/party/zusatz/schlosskeller/einfluss.json`.
  - Startwert ist die Tabelle aus dem Spielspaß-Entwurf, zum Beispiel Ascheneimer {ahmet, meryem} und Bauchtasche {can, zeynep}.
  - `akte_pruefen` verlangt, dass die vier Kernfiguren je Runde in gleich vielen Optionen vorkommen (±1).
- **Tischwert T** je Option: v = Zeigen − Decken auf Figuren im Bezug; T = sign(v)·min(2, ⌊|v|/m(n)⌋) mit m(n) = ⌈n/5⌉.
  - T steht **vor der Wahl** als Abzeichen an jeder Option („Rückendeckung +1“ / „Störung −2“). Das ist pfadfrei.
- **Suche:** Modifikator = clamp(Basis nach K-07, unverändert ≤ +2) + T (+1 Umweg-Bonus), begrenzt auf **[−2, +3]**. Bei T = 0 ist das exakt wie heute.
- **Befragung:** weiter ohne Würfel.
  - T ≥ +1, „Redselig“: eine Randnotiz zusätzlich.
  - T = −1, „Zögert“: +3 Minuten.
  - T = −2, „Mauert“: +3 Minuten, die Fakten kommen erst zum Zwischenresümee.

**2. Würfelausgang:**
- **Erfolg:** Fund und +7 Minuten wie bisher, dazu ein **Zusatzfund**: eine Randnotiz aus dem Vorrat der Option (Beobachtungen mit `pfade: alle`).
  - Wurde eine Figur im Bezug gedeckt, wird **ertappt**: Ein Decker wird öffentlich genannt. Er wird über `ertappt:<salz>:<eid>` gezogen, nie über den Pfad.
- **Teilerfolg:** nur der Fund.
- **Pech:** eine Marke, dann **„Die Spur verwischt“**. Der Tisch ruft:
  - **Nochmal** (3 Min.): gleiche Stelle, T gilt erneut, Zusatzfund und Ertappt bleiben möglich.
  - **Umweg** (3 Min.): +1 auf den nächsten Versuch, negatives T zählt nicht. Dafür ist die Randnotiz weg und die Fakten kommen erst zum Zwischenresümee.
- Die Pech-Garantie bleibt. **Kein Fund wird je gelöscht**, er wird höchstens bis zum Zwischenresümee verzögert.

**3. Zeit:**
- Budget je Runde = 45 + Übertrag (≤ 15) + Helfen − Ablenken ± Ereignisse.
- **Boden 42** (3 × 14 Reserve für die Pflichtzüge, K-12).
- Nach Runde 3 gibt es pro volle 10 Restminuten **1 Nachfrage** vor der Anklage, höchstens 2. Sie deckt eine fehlende oder verlorene Randnotiz auf.

**4. Zwei Leisten** (0–6, wirken nur in den Folgen; n_eff = max(n, 5)):
- **Zusammenhalt** K = Helfen + 2·Auspacken − Ablenken.
- **Spuk** L = Zeigen + 2·Ablenken.
- Zuwachs nach den Schwellen aus dem Spielspaß-Entwurf (+2 / +1).
- Jedes Ereignis kommt einmal:
  - Zusammenhalt 2 „Tee für alle“: +5 Min.
  - Zusammenhalt 4 „Kerzenschein“: die nächste Suche ignoriert negatives T.
  - Zusammenhalt 6 „Herr Schneider erinnert sich“: +1 Nachfrage.
  - Spuk 2 „Flackerlicht“: −3 Min.
  - Spuk 4 „Die Fledermaus“: negatives T zählt doppelt (Deckel −2); jeder Erfolg bringt 2 Randnotizen.
  - Spuk 6 „Herrn Schneider platzt der Kragen“: −5 Min., chaotischer Morgen.
- Ereignistexte nennen nie einen Fallgegenstand und nie eine Suchstelle (R15).
- **Flüstern:**
  - Zusammenhalt +2 in dieser Runde → wahrer Hinweis aus `bonus.json`.
  - +1 → neutraler Hinweis.
  - 0 → „Diesmal flüstert dir niemand etwas zu.“
  - Falsche Hinweise kommen in der App nicht mehr vor; Täuschung kommt jetzt von den Spielern.

**5. Persönliche Ziele:**
- Jede Figur hat **2 Sterne**. Sie sind pfadfrei, und die vier Kernfiguren haben dieselbe Form („Dein Nebendelikt bleibt bis zur Anklage geheim“ / „Der Detektiv klagt dich nicht an“).
- Die Ziele liegen in `einfluss.json` als kleine Bedingungssprache:
  - Verknüpfungen: `alle`, `eine`, `nicht`, `mind`, `hoechstens`, `gleich`.
  - Atome: `angeklagt`, `gestanden:X`, `ndBekannt:X`, `zuege:<art>`, `zieleAuf:X`, `ertappt:ich`, `zusammenhalt`, `spuk`, `rest`, `tipp` …
  - **Kein Atom kennt den Pfad.**
- Startwerte sind die 20 Ziel-Paare aus dem Spielspaß-Entwurf, nach Prüfung. Bewusste Gegensätze: Aylin gegen Ahmet, Marek gegen Can und Zeynep, die Ruhigen gegen Baran und Can.
- Jeder sieht den eigenen Stand privat in jedem Moment.
- `akte_pruefen` verlangt, dass jedes Ziel erreichbar und verfehlbar ist und dass es bei den vier Kernfiguren symmetrisch ist.

**6. Ende und Auflösung:**
- **Endwert = Punkte + Tischbonus**, begrenzt auf 0–9.
  - Tischbonus: Zusammenhalt ≥ 4 gibt +1, Spuk ≥ 4 gibt −1, beides zusammen gibt 0.
  - Die Anklage allein entscheidet richtig oder falsch. Die Punkte werden roh angezeigt.
- **Geklärt-Regel:** Hat Auspacken schon alle Fakten geliefert, die die richtige Option in diesem Pfad bringen würde, zählen beide Optionen als richtig. Das hebt Punkte nur an.
- **Tipp:** Im Moment der Runde 3 gibt jeder einen Tipp ab: „Wer war's?“ (4 Porträts oder „Keine Ahnung“). Er bleibt verdeckt.
- **Auflösung:**
  - Text je Rolle plus eine Epilog-Zeile, je nachdem ob das Ziel erreicht wurde.
  - „Protokoll der Nacht“: alle Züge als Symbole.
  - Auszeichnungen:
    - Stern des Abends = 3·Sterne + 2·Spürnase + gestützte Erfolge (höchstens 2) + Auspacken
    - Spürnasen
    - Schlossgeist
    - Treue Seele
- **Erfahrung:** Gäste bekommen +15 je Stern, +25 für den Stern des Abends und +10 als Spürnase. Für den Detektiv zählt das verschobene Ende (`karten/belohnung.dart`).

**7. Bots und Sichtbarkeit:**
- **Bots:** eigener Strom `einfluss:<salz>:<rolle>:<runde>`, mit Persönlichkeit je Figur. Die Persönlichkeit hängt nicht vom Pfad ab: Can ist immer Spaßvogel, Pawel hilft fast immer.
  - Dazu Override-Regeln (nach „ertappt“ helfen statt decken; den Freund decken, wenn über ihn getuschelt wird …).
  - Solo: bis zu 3 Reaktionsblasen je Folge, je höchstens 8 Wörter.
- **Nie vor der Auflösung sichtbar:** wer gezeigt, gedeckt, geholfen oder gelauscht hat; Zahlen; Tipps; fremde Ziele.
- **Öffentlich:** Auspacken, Ablenken, Ertappt, Gerüchte, Leisten, Ereignisse, Tischwerte, Randnotizen.
- **Der Erzähler** bekommt privat die Zug-Tafel (alles außer dem Täter).

**8. Bleibt ohne Schicht:** das Druckspiel (Papierstreifen A/B, BE-12). Es wird im Druck als „Fassung ohne Dein Moment“ dokumentiert.

### Technik der Schicht

- **Kern `packages/mordakte_core/lib/src/runden/`:**
  - `einfluss.dart`:
    - `ZugArt`, `EinflussZug`
    - `EinflussRegeln.ausJson`
    - `EinflussStand implements SpielZusatz`: rein, ohne Pfad
    - `tisch(runde, optionId)`, `auswerten(runde)`, Leisten, Ereignisse, Minuten
    - `botZug(...)`
  - `einfluss_ziele.dart`: Bedingungssprache und Auswertung.
  - `einfluss_pruefung.dart`.
- **Haken mit neutralem Standard:**
  - `wuerfel.dart`: `gesamt(basis, extra, boden, deckel)`; `extra == 0` gibt `basis` zurück.
  - `zugschicht.dart`: `ZugParameter` mit `modBoden`, `modDeckel`, `umwegBonus`; `beginneRunde(r, zusatzMinuten)`; `waehle(..., tisch)`.
  - `partie.dart`: `RundenPartie(..., einfluss)`, `zugSetzen`, Verzögerung und Randnotizen, sichtbare Fakten, Nachfragen.
  - `party/ablauf.dart`: `SpielZusatz` (`sichtbar`, `nachWechsel`, `tischbonus`); `ende` mit Endwert; `weiter()` überspringt die Gruppenwahl, wenn die Schicht aktiv ist.
  - `erzaehler.dart`: Resümee aus den sichtbaren Fakten; Folgen- und Flüster-Schlüssel.
  - `texte.dart`: neuer Bereich `einfluss` mit dem Platzhalter `@figur`.
- **Inhalt:**
  - `content/party/zusatz/schlosskeller/einfluss.json`: Zahlen, Bezug, Randnotiz-Vorräte, Auspacken-Zuordnung, Ereignisse, Bots, Ziele, mit Schema.
  - `content/party/schlosskeller/texte/einfluss.json`: Zugkarten, Gerüchte, Ereignisse, Erzählervorlagen, Epiloge, Bot-Blasen, Auszeichnungen.
  - `wahlen-*.json` wird zu den Auspacken-Zeilen umgebaut.
- **Raum:**
  - `SchlosskellerRaum(..., einfluss)`
  - Nachricht `zug {art, ziel, tipp?}` in den Gesprächen
  - Weiter erst, wenn alle gezogen haben, sonst nach einem letzten Aufruf von 60 s
  - Bots füllen getrennte Plätze nach 2 Minuten
  - Öffentlich `einfluss` (über `sichtfelder` und die Matrizen)
  - Privat je Rolle `moment {zug, darf, sterne, nachrichten, gelauscht}`, beim Erzähler `einflussTafel`
  - Nach dem Finale `aufloesung.einfluss`
  - **`protokollVersion` 4 → 5**
- **App:**
  - `PartySitzung`: `zugSetzen` in der verdeckten Ansicht; Bots solo; `abendstand/3`. `einrichten` merkt sich `einfluss: true`, alte Stände ohne diesen Eintrag laufen ohne Schicht.
  - Bildschirme:
    - Moment-Raster (2×3) mit Zielwahl, Karten nach R17
    - Abzeichen an den Optionen
    - Fundkarte mit Randnotiz, „Ertappt“ und „Spur verwischt“
    - Tischruf-Knöpfe mit Wirkungstext
    - Leisten im Resümee
    - Auflösung mit Protokoll, Sternen und Auszeichnungen
  - Online: `gast_ansicht.dart` (pulsierender Knopf „Dein Moment“), `gastgeber_sitzung.dart`.
  - Aufgaben je Sitz in `rollen_uebersicht.dart`.
  - Einstellungs-Schalter „Dein Moment“, für den Schlosskeller an.

## Beweise und Tests

**Neue Invarianten (Testnamen in Klammern):**
- **T-N neutral:** Ohne Schicht bleiben Golden k12, die 9.216 Läufe und die Ansichten der anderen Akten gleich. Der Vergleich läuft gegen `andere_akten_soll.g.dart`, **erzeugt vor der ersten Änderung** (`einfluss_gating_test`).
- **T-W Wahrheit:** Sichtbare Fakten ⊆ Fakten des Pfads. Der Täter wird nie entlastet (`einfluss_sicht_test`).
- **T-L Lösbarkeit:** Beim Öffnen jeder Entscheidung sind alle Begründungsfakten früherer Runden sichtbar. Bei der Anklage ist alles sichtbar (`einfluss_sicht_test`).
- **T-B Bestes Spiel:** Für jedes Zugprofil, n = 4–20, ergibt bestes Spiel „Meister“. Gerechnet über alle 4 Pfade × 768 Folgen × Profile (alle stützen, alle stören, Bots) × Würfelströme, in Pfade aufgeteilt (`einfluss_abend_test`).
- **T-P pfadblind:** Bei gleichen Eingaben ist die öffentliche Spur in allen 4 Pfaden identisch (`einfluss_pfadblind_test`).
- **T-G Architektur:** `einfluss.dart` kennt weder Pfad noch Täter noch Qualität (`einfluss_regeln_test`).
- **T-K Klasse:** Die Anklage bestimmt richtig oder falsch (`einfluss_ende_test`).
- **Determinismus:** neuer Golden `einfluss_soll.g.dart` über 1.000 Codes, nie neu schreiben.
- **Weitere:** `einfluss_suche_test` (vollständig je Suche), `einfluss_ziele_test`, `einfluss_bots_test`, `schlosskeller_raum_einfluss_test` (Privatsphäre, Replay).

**Erzählteil:** `einstimmung_test`, `einstimmung_pruefen_test` (mit Fehlerproben), `erzaehlerakte_test` (Privatsphäre, pfadgleich, Fehlerprobe mit einem Tarnungssatz), `einstimmung_modul_test`.

**Anzupassende Tests:** `textpruefer_test` (60), `fassung_test`, `druck_paket_test`, `druck_paket_cli_test`, `druck_spielleitung_test`.

**App-Tests:** `test/party_widgets/einstimmung_test`, `erzaehlerakte_test`, `heimlicher_zug_test` (320/390 px, 200 % Text), `einfluss_sitzung_test`, `test/abend/gast_einstimmung_test`, `gast_erzaehlerakte_test`, `gast_moment_test`, `lang_invarianz_test` (mit Schicht).

**Server und Browser:** Server-Matrizen mit Moment-Zügen und Einstimmung; Browserprobe `tool/e2e` mit `einstimmung=1` und Zügen.

## Inhalt schreiben

Ton: deutsch, warmer Spuk-Humor. Es gelten `TON-LEITFADEN`, `textregeln.json` (Raumwort-Endungen!) und R15/R17.

1. **Zuerst (blockierend):** Faktenblatt „Beziehungsnetz und Vorgeschichte“ mit etwa 45 Kanten.
   - Inhalt: Schloss und Stiftung, Schneiders 25 Jahre, wie die Clique entstand, öffentliche Fassung der Keller-Geschichte („Ahmet hat den Keller organisiert“, ohne Geld und ohne Gefallen), der Detektiv als Gast.
   - Ein Story-Prüfer gleicht es mit `STORY-BIBEL.md` ab.
2. **Danach parallel:**
   - Vorgeschichte (ca. 650 Wörter)
   - Vorstellungen in 4 Paketen à 5 Figuren, dazu der Sammelblock für Unbesetzte und der Detektiv m/w (ca. 1.300 Wörter)
   - Erzählerakte in 4 Paketen (ca. 3.900 Wörter)
   - Einfluss-Texte (ca. 6.700 Wörter):
     - Zugkarten und UI
     - Auspacken- und Ablenken-Zeilen
     - Gerüchte, Ereignisse und Erzählervorlagen
     - Ziele und 40 Epiloge
     - 80 Bot-Blasen
     - Morgen-Varianten
3. **Gegenprüfung durch eine Prüfgruppe:**
   - Story-Logik gegen Kanon und Vorspiel
   - Spoiler und Pfadverrat nach Bedeutung, nicht nur Wortlaut, zum Beispiel Geld, Streich, Münzen
   - Ton und Sensibilität (TON §7)
   - Ausgewogenheit der 4 Kernfiguren
   - Danach wird nachgebessert, bis `akte_pruefen` 0 Befunde meldet.

## Umsetzung (Ultracode, Workflows)

| Stufe | Inhalt | Art |
|---|---|---|
| 0 | Branch `claude/schlosskeller-finale` von `main`, in `release.yml` bei den Push-Branches und in der Vorab-Liste eintragen. `source tool/flutter_env.sh`, Basislauf `bash tool/pruefen.sh schnell` und `flutter test` (Zählstände notieren). **`andere_akten_soll.g.dart` erzeugen.** Entscheidungen A-063…066, R18–R25, K-Nachträge. | inline |
| 1 | **Inhalt** nach dem Abschnitt oben: Faktenblatt → Schreiber parallel → Prüfgruppe → Nachbessern | Workflow |
| 2 | **Kern:** 2a Pfadwissen-Umbau, Einstimmung, Erzählerakte, Raummodul (Worktree); 2b Einfluss-Kern, Haken, Beweise, Golden (Worktree) → Zusammenführung, gezielte Tests. Höchstens 2 schwere Agenten gleichzeitig (4 CPUs). | Workflow |
| 3 | Inhaltscommit: `setting.json`, Texte, `erzaehlerakte.json`, `einfluss.json`, `akten.json`, `bash tool/kanon_tor.sh`, `python3 tool/inhalt_kennung.py` | inline |
| 4 | **App und Netz:** Raum, Server und Matrizen ‖ App offline → App online ‖ Druck und CLI | Workflow |
| 5 | **Prüfen:** Code-Review (Korrektheit, Fairness, Verrat), Simulation `party_simulate --einfluss` über viele Salze zur Feinabstimmung der Zahlen (Meister-Quote je Pfad innerhalb ±15 pp, Bot-Bänder), Doku, Browserproben | Workflow |
| 6 | Volles Tor `bash tool/pruefen.sh ci`, Push, CI überwachen und grün machen. Vor einer Zusammenführung nach `main` frage ich nach. | inline |

**Doku:**
- `docs/ANLEITUNG.md` §4–§7: Einstimmung, Dein Moment, Würfel, Leisten, Ziele, Ende, Erzählerakte.
- `docs/partykrimi/ANLEITUNG.md`: Erzählerheft, `erzaehlerakte.pdf`, Druck ohne Moment.
- `README.md`.
- `planung/langer-abend/STATUS.md`: neue Zeile „M12 Finale“.
- `FUER-DEN-NUTZER.md`: was nur Menschen prüfen können, zum Beispiel Ton, Zahlenbalance am echten Tisch, Ziele.

## Verifikation

```
bash tool/kanon_tor.sh --pruefen && bash tool/pruefen.sh schnell
(cd packages/mordakte_core && dart test)
git diff --exit-code packages/mordakte_core/test/runden/determinismus_soll*.g.dart
for a in schlosskeller gewoelbe ravensmoor nachtexpress blue_palm; do (cd packages/mordakte_core && dart run bin/akte_pruefen.dart --fall $a); done   # je 0 Befunde
flutter test
(cd server && dart run tool/party_matrix.dart --clients=4 && dart run tool/relay_matrix.dart --lokal --clients=4)
(cd packages/mordakte_core && dart run bin/party_druck.dart --fall schlosskeller --erzaehlerakte --personen 8 --aus <scratch>)
bash tool/pruefen.sh ci     # inklusive Web-Build und Browserproben
```

Dazu ein ganzer Abend per Dev-Skript im Browser (`?party=schlosskeller&einstimmung=1`), solo und reihum, mit Fotos von Vorgeschichte, Vorstellung, Moment, Folgen und Auflösung.

## Risiken

- **Feinabstimmung der Zahlen:** Die Zahlen sind Startwerte. Stufe 5 stimmt sie per Simulation ab. Der echte Tischtest bleibt beim Besitzer.
- **Tempo reihum bei 20 Rollen:** Der Moment kostet etwa 2–3 Minuten je Runde zusätzlich. Gegenmittel: Die Züge laufen parallel zu den Gesprächen, und es gibt eine Kachel „Wie letzte Runde“.
- **Pfadverrat nach Bedeutung:** Die Prüfer erfassen nur Wortlaut. Deshalb ist die menschliche und adversarielle Prüfung Pflicht.
- **Protokoll 5 und `abendstand/3`:** Alle Geräte müssen aktualisieren. Alte Stände laufen ohne Schicht weiter.
- **Berührungspunkte zwischen Erzählteil und Schicht:** `sitzung.dart`, `schlosskeller_raum.dart`, `sichtfelder.dart`, `akte_pruefen.dart` und ARB werden nacheinander zusammengeführt. Prüfsummen, Einbettung und Inhaltskennung werden nur vom Integrator neu erzeugt.
