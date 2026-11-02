# Schema des Kammerspiel-Inhalts „Spuk im Schlosskeller“ (U4YRK, Täter Olli)

Dieser Ordner ist die einzige Quelle des Pen-&-Paper-Drucks „Kammerspiel“ (Teile 00, 01, 02, 10, 11, 12, 20, 90).
Spezifikation: `FALL-BIBEL.md` (Kennungen WELT, MECH, RK, ZG, ZR). Nur der Druck liest diese Dateien; das App-Spiel,
die Kanon-Prüfsummen und die Inhaltskennung (`content/party/…`) sind nicht betroffen.

Lader: `KammerInhalt.ausJson` in `packages/mordakte_core/lib/src/party/druck/kammer/inhalt.dart` (ohne `dart:io`);
für CLI und Tests `ladeKammerInhalt(repoWurzel)` aus `package:mordakte_core/kammer_io.dart`. Platzhalter und
Auszeichnung: `kammer/platzhalter.dart`. Besetzung je Personenzahl: `kammer/besetzung.dart`.

## 1. Dateien

| Datei | Inhalt | gedruckt in |
|---|---|---|
| `fall.json` | Struktur: Kennung, Fall-Code, Täter, Personen, 18 Plätze, Tandems, Runden, Schwellen, Zonen, Felder, Marker-Zeitpunkte, erlaubte Uhrzeiten, Raumnamen, Meilensteine, Punkte, Enden, Codes, Teile | (überall abgeleitet) |
| `gemeinsam.json` | Spieltexte für mehrere Teile: „Was alle wissen“, „So spielt ihr“, Tischregeln, Licht | 00, 01, 10, 12 |
| `erzaehlerheft.json` | Teil 00 ohne Rollentexte | 00 |
| `detektiv.json` | Teil 01 (Rollenteil und Ermittlungsbogen) | 01 |
| `tisch.json` | Teil 02: Lageplan (Geometrie, Legende), Markerfelder, Marker, Tipp-Zettel, Maße des Abwesenheitsblatts | 02 |
| `abwesenheit.json` | die sechs Zeugenstreifen (Plätze 5–10) | 02 |
| `indizkarten.json` | die 19 Indizkarten AD3 … YT4 | 20 (Liste auch 01, 90) |
| `aufloesung.json` | Teil 90 ohne Rollentexte | 90 |
| `rollen/NN-<id>.json` | je Platz 1–18 alles zur Rolle: Heft bzw. Zusatzheft, Geheimnis- und Aktionskarte, Bonus-Ziel, Marker, Vorstellungsfrage, Absatz für Teil 90, bei 1–4 die versiegelte Fassung | 00, 10, 11, 12, 20, 90 |
| `ui/gemeinsam.json`, `ui/00.json` … `ui/90.json` | Beschriftungen, Überschriften, Dateinamen, Hinweise je Teil | je Teil |

`kammerInhaltDateien` (Dart) listet genau diese 35 Dateien. Andere Dateien im Ordner (etwa `textregeln.json` des
Textprüfers, dieses `SCHEMA.md`) gehören nicht zum Inhalt und werden vom Lader nicht gelesen.

Besitz: `fall.json`, `tisch.json` (Geometrie) und alle strukturellen Felder (Zahlen, Kennungen, Codes) sind fest; die
Schreib-Phase füllt nur Texte, die mit `OFFEN:` beginnen, und ändert sonst nichts. `ui/*.json` erweitern die
Generator-Agenten je Teil um neue Schlüssel.

## 2. Allgemeine Regeln

- **Streng:** Jedes hier genannte Feld muss da sein, kein anderes darf da sein. `null` nur, wo „oder null“ steht.
  Fehler: `FormatException` mit Datei und Pfad (`rollen/03-olli.json: geheimniskarte.vermerke: Feld fehlt`).
- **Typen:** *Text* (String; Platzhalter und Auszeichnung erlaubt, Abschnitte 3 und 4), *Kennung* (String ohne
  Leerzeichen und Klammern: IDs, Feld-IDs, Codes), *Zahl* (ganze Zahl), *Kommazahl*, *ja/nein* (bool), *Liste*.
- **OFFEN:** Ein Text, den die Schreib-Phase noch schreiben muss, beginnt mit `OFFEN: ` und nennt die Bibel-Kennung,
  wo die Vorgabe steht (`OFFEN: RK 3.7 (a)`, `OFFEN: ZG 2 Stufe 1 „Das sagst du jedem“`). Steht in der Bibel „wörtlich“,
  kommt genau dieser Text hinein. `KammerInhalt.offeneFelder` listet alle OFFEN-Felder („datei: pfad“). Im Druck
  darf kein OFFEN-Text stehen.
- **Lesetext und Rede.** Wo die Bibel einen Text in „…“ für sich stellt (Kasten, Karte, Streifen, Vorlesetext,
  Absatz), steht er hier **ohne** die äußeren Zeichen; innere ‚…‘ werden „…“. In **Rede-Feldern** (was die Person
  sagt: Kernsätze, „Das sagst du jedem“, Antworten in Tabellen, Impuls-Antworten, Fragen der Gesprächsaufträge,
  Freigabe, „Nach dem Umdrehen“, „Wenn es eng wird“) steht der Text wie in der Bibel: Rede in „…“, darin ‚…‘.
  Rede-Felder sind unten mit (Rede) markiert.
- **Bibel-Verweise** in Klammern (P2-16, ZG-09, R-12 …) stehen nie im Inhalt.
- Apostroph `'` (wie in der Bibel), echte Umlaute, Gedankenstrich „–“, Uhrzeiten nach WELT 0.2 (`fall.json`
  `uhrzeiten`; Sekunden nur in Teil 90), Raumnamen nach `raumnamen`. „Herr Schneider“ immer so (bloß „Schneider“ nur in
  Ollis wörtlicher Rede).
- **Listen statt Nummern:** Aufzählungen sind JSON-Listen ohne „1.“, „(a)“ oder „–“; der Generator nummeriert
  (Pflicht-Auslöser der Verdächtigen (a)–(c), sonst 1., 2. …). Ein Listeneintrag oder eine Tabellenzeile, deren
  (erster) Text nach dem Auflösen leer ist, fällt weg; die Nummern rücken nach.
- **Offene Listen:** Hat eine Liste, deren Länge die Bibel vorgibt, nur **einen** Eintrag und sind alle seine Texte
  `OFFEN:` (`stufe1.sagstDuJedem`, `stufe1.ausweichsaetze`, `stufe1.verboten`, `wasDuWeisst.zeilen`,
  `aufloesung.zeitleiste`), steht dieser Eintrag für die ganze Liste. Die Schreib-Phase ersetzt ihn durch alle Zeilen der
  Bibel-Tabelle, in deren Reihenfolge, und setzt dabei auch die Strukturfelder dieser Zeilen (`frei` nach der Spalte
  „frei ab“: „offen“ → `offen`, „Karte“ → `karte`, „Runde 3“ → `runde3`; gemischte Zeilen bekommen `zusatz`). Listen
  fester Länge mit je einem OFFEN-Eintrag (`rueckblende` 8 Abschnitte, `tischregeln`, `rundenaufbau`) behalten ihre
  Länge.

## 3. Platzhalter

Für Rollen, die heute vielleicht fehlen (WELT 0.2 „[Name | Ersatz]“, RK 1.5, ZG G-08, ZR ZG-10). Jede gedruckte Zeile,
die eine Rolle mit höherem Platz als die eigene nennt (Rollen 5–18), trägt einen Platzhalter. Rollen 1–4 sind immer
besetzt und stehen als Name im Text. IDs: `ahmet fatma olli can lejla emine tim joanna marek zeynep sibel damir hana
serkan azra wojtek aylin tugba` (fall.json `plaetze[].id`).

| Form | Ergebnis |
|---|---|
| `{rolle:ID\|Ersatz}` | Name der Rolle, wenn sie gespielt wird, sonst der Ersatz (darf leer sein). Genau eine ID. |
| `{wenn:ID[,ID…]\|Text\|Sonst}` | Text, wenn **alle** genannten Rollen gespielt werden, sonst Sonst. `\|Sonst` darf fehlen (dann leer). |
| `{ab:N\|Text\|Sonst}` | Text ab N Personen (Personen = Rollen + Detektiv + Erzähler), sonst Sonst (darf fehlen). |
| `{detektiv:männlich\|weiblich}` | Fassung nach dem Detektiv (CLI `--detektiv m\|w`). |
| `{name}` | Wert-Platzhalter: der Generator setzt einen Wert ein. Nur in `ui/*.json` (alle Namen) und in Feldern, die es unten ausdrücklich erlauben. |

Verschachteln ist erlaubt (`{wenn:joanna|„{rolle:marek|Der Caterer} war da.“}`). `{`, `}` und `|` haben nur in
Platzhaltern Bedeutung; `{` und `}` außerhalb sind ein Fehler, `|` außerhalb ist normaler Text. Leerzeichen gehören in
den Zweig: `{wenn:marek|mit Marek }geplant`. Grammatik passt der Ersatz selbst an (Fall, Groß am Satzanfang, „deine“ →
„meine“ in Ich-Sätzen, RK 1.5). Ein Satzteil, der nur eine Beziehung zu einer fehlenden Rolle beschreibt, steht ganz in
`{wenn:…}`.

Auflösen: `loeseKammerText(text, werte)` oder `KammerBesetzung.text(text, detektivWeiblich:, werte:)`. Prüfen:
`pruefeKammerText` (der Lader prüft jeden Text: Syntax, bekannte IDs, erlaubte Werte, Auszeichnung in beiden
Extremen der Besetzung).

## 4. Auszeichnung

Nach dem Auflösen: `**fett**`, `*kursiv*`, `\n` Zeilenumbruch, Leerzeile (`\n\n`) neuer Absatz. Fett und kursiv
dürfen über Zeilen, nicht über Absätze gehen. Mehrfache Leerzeichen werden zu einem, Zeilen ohne Rand.
`kammerAuszeichnung(text)` liefert Absätze → Zeilen → Läufe (`KammerLauf(text, fett:, kursiv:)`); `kammerKlartext`
den Text ohne Auszeichnung (zum Zählen). Häkchen ☐ ✓ ✗ und Unterstriche `____` (Schreiblinien) sind normaler Text.

Übliche Formen: Etiketten vor Varianten fett und je auf eigener Zeile (`**Karte zu:** „…“\n**Karte offen:** „…“`),
Bonus-Ziel nach MECH 7.3 (`**Dein Bonus-Ziel:** … **Erfüllt, wenn** …`).

## 5. Felder je Datei

### fall.json (fest)

`kennung` · `fallCode` (`U4YRK`) · `taeter` (Rollen-ID) · `personen` {`min` 6, `max` 20, `vorgabe` 10, `ohneRolle`
[`erzaehler`, `detektiv`]} · `plaetze` (18 × {`platz`, `id`, `kanonFigur` (ID in `content/party/schlosskeller/figuren.json`),
`name`, `bezeichnung` (Rollenbezeichnung klein mit Artikel nach Kanon `roleTitle`, etwa „die Apothekerin“; MECH 9.4 „Je
Rolle: Name, Rollenbezeichnung, Frage“, ui/00 `vorstellung.rolle`), `art` `verdaechtig`|`zeuge`|`zusatz`, `tandem` Zahl
oder null, `datei`}) · `tandems` (4 × {`nr`, `plaetze`
[kleiner, größer], `thema`}) · `runden` (3 × {`nr`, `name`, `uhr`}) · `untersuchungenJeRunde` · `schwellen`
{`verhoerLeiseAb` 12, `gegenueberstellungAb` 14, `gegenueberstellungLangAb` 18, `rollenAmTischSelbstAb` 14,
`tippWertungZweiSeitenAb` 15, `abschnittBKurzBis` 8, `dankeskarteAb` 13} · `zonen` ({`nr`, `name` nach A:78–85,
`felder`}) · `felder` (13 × {`id` 1, 2, 3, 4a–4d, 5, 6, 7, 8a, 8b, W; `zone`; `name` wörtlich WELT 2.1}) · `zeitpunkte`
[`z2357`, `scheppern`] · `uhrzeiten` (WELT 0.2) · `raumnamen` · `meilensteine` (M1–M9 {`nr`, `zeile` `alibi`|
`heimlichtuerei`|`fundort`|`schluesselbeweis`, `spalte` Rollen-ID oder null, `punkte`}) · `punkte` {`detektivMax` 9,
`tipp` {`taeter` 2, `versteck` 1, `bonus` 2}, `taeterSonder` 3, `jePersonMax` 5} · `enden` (4 × {`nr`, `anklage`
`taeter`|`andere`, `von`, `bis`}) · `codes` {`fassungen` [WW4, JM3, RN7, YW4], `indizkarten` [19 Codes sortiert]} ·
`teile` [00, 01, 02, 10, 11, 12, 20, 90].

### gemeinsam.json

`wasAlleWissen` Liste Text (MECH 1.5; der 18:00-Eintrag trägt `{ab:13|…}` für die Dankeskarte) · `soSpieltIhr` Text
(MECH 1.4 Kurzform) · `tischregeln` (R-01 … R-14 {`nr`, `name`, `text`}) · `licht` Text (MECH 9.11 B).

### erzaehlerheft.json (Teil 00)

`vorbereitung` {`hinweis`, `taetigkeiten` [{`teil` `alle`|02|11|20|90, `text`, `minuten` Zahl oder null}], `anWen`} ·
`ablauf` [{`schritt`, `name`, `minuten` {`6`, `12`, `20`}, `uhr` Text oder null}] (MECH 1.1; Minuten zwischen den
Stützstellen: `minutenBei(personen)` linear, gerundet) · `rundenaufbau` [{`abschnitt` a–f, `name`, `minuten`, `text`}]
· `runde3Reihenfolge` · `gegenueberstellungRegel` · `kleineRunden` · `soLaeuftDerAbend` · `vorgeschichte` (Absätze)
· `vorstellung` {`anleitung`, `start`, `frageDetektiv`, `lacherFehlend` [{`rolle`, `text`}] (nur drucken, wenn die
Rolle fehlt), `abschluss`} — die Fragen an die Rollen stehen in den Rollendateien (`vorstellung.frage`) · `tatMoment`
· `auftrag` (mit `{detektiv:…}`) · `fassungenOeffnen` (nennt „Seite 7“ nach dem Seitenplan MECH 9.1; Wert `{seite}` erlaubt) · `lageplanFuehrung` [{`art` `anleitung`|`vorlesen`, `text`,
`nurMitStreifen`}] · `impulsRegeln` · `ausweichsatz` · `dominoFrage` {`wann`, `nenntPerson`, `sonst`, `fehlt`} ·
`gegenueberstellung` {`wann`, `text` (mit `{ab:18|…|…}`)} · `runden` [{`nr`, `start`, `schluss` Text oder null
(Runde 3), `impulse` [{`id` I-r.n, `titel`, `text`, `hinweis` Text oder null}]}] · `bonusZiel` · `tippRunde`
{`vorlesen`, `anleitung`} · `anklage` {`vorlesen`, `anleitung`} · `herrSchneiderAntwortet` [{`frage`, `antwort`}] ·
`masstabelle` [{`von`, `nach`, `abstand`, `dunkel`}] · `taschenkontrolle` · `skalierung` {`hinweise` [{`von`, `bis`,
`text`}]} (Zeile der Personenzahl; die übrigen Spalten von MECH 9.13 rechnet `KammerBesetzung`) ·
`kartenUnterStreifen` {`anleitung`, `muster` (Werte `{name}`, `{codes}`, `{runde}`), `umschreibungen` [{`zeuge`,
`text`}], `hinweis`} — Codes und Runde der Tabelle stehen in den Rollendateien (`geheimniskarte.pflichtCodes`,
`sperre`).

### detektiv.json (Teil 01)

`auftritt` · `wasDuSelbstWeisst` Liste · `fragenLeitfaden` [{`titel`, `fragen` [{`nr` Kennung oder null, `text`}]}] ·
`untersuchungen` Liste (RK 6.7) · `aufgabenJeRunde` [{`runde`, `zeilen`}] · `bogen` {`hinweis`, `zeilen` [{`id`
`ort2357`|`alibi`|`heimlichtuerei`|`ausgeschieden`, `titel`, `zusatz` oder null}], `spalten` (die vier IDs),
`unterRaster` Liste, `entlastungsregel`, `ueberfuehrungsregel`, `fuehren`} · `vermerkeZeilen` 48 · `anklage` {`feld`
Liste, `hilfe`} · `aktionskartenTipps` [{`rolle` (Zeuge 5–10), `text`}] (nur die Karten, die heute beim Detektiv
liegen) · `gegenKarten` · `wennRollenFehlen` [{`von`, `bis`, `text`}] (RK 6.12, Teil 01: gedruckt werden alle Zeilen,
deren Bereich die heutige Personenzahl enthält, `KammerDetektiv.wennRollenFehlenBei(personen)`; die Bereiche 6–11, 6,
12–20 und 15–20 überschneiden sich absichtlich). Die Untersuchungsliste baut der Generator aus `indizkarten.json`
(Titel, Code, ab Runde).

### tisch.json (Teil 02)

`lageplan` {`raster` {`x0` 1, `y0` 1, `breite` 25, `hoehe` 22, `mmJeMeter` 8.5}, `raeume` [{`id`, `name`, `kacheln`}],
`felder` [{`feld` (Feld-ID), `kacheln`}], `tueren` [{`id`, `name`, `x`, `y`, `zustand` `offen`|`angelehnt`|`zu`|
`verschlossen`}], `moebel` [{`id`, `name`, `kacheln`}], `gegenstaende` [{`id`, `name`, `x`, `y`, `feld`}], `legende`
[{`feld`, `text`}], `hinweise` Liste} · `markerfelder` {`spalten` 5, `reihen` 3, `zelleBreiteMm` 54, `zelleHoeheMm` 58,
`belegung` [{`feld`, `zellen` [[Spalte, Reihe] …], `plaettchen`}]} · `marker` {`breiteMm` 26, `hoeheMm` 18, `jeRolle`
2, `max` 40, `feste` [{`wer` `detektiv`|`schneider`, `z2357`, `scheppern`}]} · `tippZettel` {`titel`, `name`, `fragen`
[{`nr`, `art` `taeter`|`versteck`|`bonus`, `text`, `punkte`}], `fuss`, `jeBlatt`} · `abwesenheitsblatt` {`spalten`,
`reihen`, `randMm`, `streifenBreiteMm`, `streifenHoeheMm`, `etikettHoeheMm`, `schriftPt`, `notizPt`}.

Geometrie (WELT 2.3): 1 Kachel = 1 m, x nach Osten, y nach Süden; Kachel k reicht von k bis k+1. `kacheln` ist eine
Liste von Bereichen {`x` [von, bis], `y` [von, bis]}, beide Grenzen eingeschlossen. Punkte (`x`, `y`) in Metern, Mitte
einer Kachel = k,5. Türen liegen als Punkt auf der Wandkachel. Die Felder überlappen nicht; jeder Gegenstand liegt in
seinem Feld (geprüft in `inhalt_test.dart`). Auf dem Plan steht kein Rollenname.

### abwesenheit.json

`streifen` 6 × {`zeuge`, `feld` (Markerfeld, neben dem er liegt), `oeffnen` (Ortstermin-Codes; dazu immer der
„Zeitstempel“), `etikett` (drei Zeilen, `\n`), `protokoll`, `mitNotiz` (Joanna: ihre `notiz` zweispaltig in `notizPt`
darunter), `vermerk`}. Gedruckt werden nur die Streifen fehlender Zeugen (`KammerBesetzung.streifen`).

### indizkarten.json

`ortsterminSchluss` {`einzahl`, `mehrzahl` (bei mehr als einem Zeugen)} · `ortsterminVermerk` · `karten` 19 × {`code`,
`abRunde`, `art` `ortstermin`|`spur`, `titel`, `felder`, `wasDuFindest`, `ortstermin` Text bei Ortsterminen sonst
null, `vermerke` (bei Ortsterminen leer), `zeugen` (Streifen, die der Ortstermin öffnet), `meilensteine`}. Außenseite
aus `ui/20.json` `indiz.aussen`.

### aufloesung.json (Teil 90)

`wasWirklichWar` · `meilensteine` 9 × {`nr`, `feld`, `kernfakt`, `stichwort`} · `meilensteinRegel` · `pruefung` ·
`enden` 4 × {`nr`, `name`, `text` (Wert `{bund}` an der Stelle des Bund-Satzes)} · `bundSaetze` {`taeterOhnePp9`,
`taeterMitPp9`, `andereOhnePp9`, `andereMitPp9`} (der Generator setzt beide Fassungen mit `ui/90` `bund.ohnePp9`,
`bund.mitPp9` ein) · `rueckblende` 8 Abschnitte (MECH 8.3) · `zeitleiste` [{`zeit`, `text`}] (Sekunden erlaubt) ·
`tippWertung` {`fragen` [{`nr`, `punkte`, `loesung`}], `sonderregel`, `spuernase`} · `erzaehlerBonus`. „Die Rollen am
Tisch“, Bonus-Ziele und Pflicht-Auslöser kommen aus den Rollendateien.

### rollen/NN-<id>.json

| Feld | Typ | Bibel | gedruckt |
|---|---|---|---|
| `platz`, `id` | Zahl, Kennung | | |
| `vorstellung.frage` | Text (Vorlesen) | RK x.3, ZG x.3, ZR x.3 | 00 |
| `vorstellung.auftritt` | Text (Vorlesen, Ich-Form) | dto. | 10/12 |
| `werDuBist` | Text (mit `\n` vor „Was dich heute antreibt“) | RK x.4, ZG 0.6, ZR 0.7 | 10/12 |
| `haltung` | Text oder null (null bei 1–4) | ZG/ZR x.1 | 10/12 |
| `tandemKasten` | Text oder null (nur 11–18) | ZR x.4 | 12 |
| `marker` | {`zeile` Text, `behauptet` {`z2357`, `scheppern`}, `wahr` {…}} (Feld-IDs) | RK x.2, ZG 0.6, ZR 0.7, WELT 4 | 10/12 |
| `wasDuWeisst` | null (1–4) oder {`zeilen` [{`zeit`, `text`, `frei` `offen`\|`karte`\|`runde3`, `zusatz` Text oder null}]} | ZG x.4, ZR x.5 | 10/12 |
| `notiz` | null oder {`zeilen`, `hinweis`} (nur Joanna) | ZG 4.5 | 10, 02 |
| `stufe1` | {`kernsaetze` (Rede), `regie` (Verdächtige: Regiesatz; Tugba: Einleitung ZR 8.6; sonst null), `sagstDuJedem` (Rede), `ausweichsaetze` [{`frage`, `antwort` (Rede)}], `verboten` (Rede), `markersatz`}; Tugba hat weder Tarnsätze noch Verbote (ZR 8.6, ZG-03): beide Listen leer | RK x.6 bzw. ZG/ZR Stufe 1 | 10/12 |
| `wennDerErzaehlerFragt` | [{`impuls` I-r.n, `antwort` (Rede)}] (8 Zeilen) | RK 1.8, ZG 0.4, ZR 0.5 | 10/12 |
| `stufe2` | {`wasDuVerbirgst`, `ausloeser` Liste, `wasDuDannSagst`, `marker`, `abDann` (je Text oder null; die vier Texte nur bei 1–4), `nachDemUmdrehen` {`einleitung` oder null, `saetze` (Rede)}} | RK x.7, ZG/ZR Stufe 2 | 10/12 |
| `freigabe` | null oder {`sofort`, `nachDemMarker`, `nachDerKarte`} (Rede; nur 1–4) | RK 8.1 | 10 |
| `gespraechsauftraege` | 6 × {`runde`, `nr`, `ziel` (ID), `frage` (Rede), `nachschlag` Text oder null, `ausweich` Text oder null} | RK x.9, ZG/ZR Nachbohr-Ziele | 10/12 |
| `wasDuBeiDirTraegst` | {`text` (Ich-Form), `hinweis` oder null, `indizkarte` Code oder null} | x.10 | 10/12, Taschenkontrolle |
| `aktionskarte` | {`name`, `abRunde`, `klasse` `schutz`\|`frage`\|`untersuchung`\|`beleg`, `wirkung`, `grenzen`, `tipp` (nur im Heft)} | MECH 4.4 | 20, 10/12, 01 |
| `bonusZiel` | {`text`, `hinweis` oder null} | RK 1.6, ZG/ZR x.10/x.11 | 10/12, 90 |
| `geheimniskarte` | {`sperre` 1–3, `pflichtCodes`, `wasIchZugebe`, `vermerke`, `undNochEtwas`} | MECH 4.2, RK x.8, ZG/ZR Stufe 2 | 20, Heft „Was du dann zugibst“, 00 (Karten unter den Streifen) |
| `solo` | Text oder null (nur 11, 13, 15, 17) | ZR x.12 | 12, nur wenn der Partner fehlt |
| `teil90` | Text (Vorlesen) | x.12/x.13 | 90 |
| `fassung` | null (5–18) oder {`code`, `ziel`, `zeitleiste` [{`zeit`, `text`}], `wasNurDuWeisst` (5), `heftUndWahrheit`, `wennEsEngWird` (5, Rede), `stufe3`} | RK 7 | 11 |

Ausweichziel (`ausweich`): wird statt `frage` und `nachschlag` gedruckt, wenn `ziel` heute fehlt (RK 1.2, ZG 0.2).
Vorhanden genau dann, wenn das Ziel einen höheren Platz hat als die eigene Rolle und als 4. Zusatzrollen nennen nur
kleinere Plätze; ihre allgemeine Ausweichregel steht in `ui/12.json` `ausweichRegel`.

### Was die Bibel nennt, aber nicht gedruckt wird

Bewusst ohne Feld, weil ZG 0.6, ZR 0.7, RK 1.1 und MECH 2.6 die gedruckten Abschnitte abschließend aufzählen:

- „Antworten am Ortstermin“ (ZG 0.5) und „Ortstermine und Aktionskarten anderer Rollen“ (ZR 0.6): Sie beschreiben, was die
  Rolle aus ihrem offenen Wissen antwortet. Die Schreib-Phase sorgt dafür, dass „Das sagst du jedem“ und „Was du weißt“
  diese Antworten tragen (Ort, Nachbarn, wer einen um 23:51 oder 23:57 gesehen hat).
- „Vermutet“ und „Weiß nicht“ der Wissenstabellen, die Spalte „Quelle“, die Spalte „wahr?“ der Stufe-1-Tabellen der
  Verdächtigen, „Worauf du hinauswillst“ (P2-22), „Was die Ziele treiben“, die Tabellen „Wenn Rollen fehlen“ der Rollen
  (RK x.11, ZG x.10, ZR x.11: Anweisungen an den Generator, umgesetzt als Platzhalter) und „Prüfbarkeit“.
- „Generator:“-Absätze unter den Solo-Abschnitten (ZR x.12) sind als Platzhalter `{wenn:Partner|…|…}` umgesetzt.

### ui/*.json

Flache Schlüssel → Text (`deckblatt.titel`, `heft.wasDuWeisst`, `indiz.aussen` …), Schlüssel aus Buchstaben, Ziffern
und Punkten. Wert-Platzhalter frei (`{name}`, `{platz}`, `{code}`, `{runde}`, `{figur}` …). Pflicht: `datei` und
`titel` in jedem Teil, `datei.alles` in `ui/gemeinsam.json`. Dateinamen nach ARCHITEKTUR A2 (`00-erzaehlerheft.pdf` …,
`kammerspiel-alles.pdf`, je Person `10-rollenheft-{figur}.pdf`, `12-zusatzheft-{figur}.pdf`). Schlüssel, die mehrere
Teile brauchen (Heft-Überschriften `heft.*`, Kartenteile `karte.*`, Kopf, Fuß), stehen in `ui/gemeinsam.json`.

## 6. Besetzung (abgeleitet, `KammerBesetzung.fuer(inhalt, personen: 6..20)`)

- Rollen = Personen − 2; besetzt sind die Plätze 1 bis Rollen (E6). Teil 10: besetzte Plätze 1–10; Teil 12: 11–18
  (bei 6–12 Personen eine Hinweisseite `ui/12` `hinweisseite`). Teil 11: immer die vier Fassungen.
- Fehlende Zeugen = Plätze 5–10 ohne Besetzung; Abwesenheitsblatt genau dann, wenn es welche gibt (6–11 Personen,
  E7); Streifen und Aktionskarten beim Detektiv = fehlende Zeugen (MECH 4.6, 5).
- Tandems: Zusatzrollen kommen paarweise; bei ungerader Zahl spielt die letzte allein, immer der kleinere Platz
  (13: Sibel, 15: Hana, 17: Azra, 19: Aylin) und bekommt ihren `solo`-Abschnitt.
- Geheimnis- und Aktionskarten: alle besetzten Rollen und alle fehlenden Zeugen (6–12 Personen: 10, sonst Rollen);
  fehlende Zusatzrollen nie.
- Tipp-Zettel: Rollen + 1 (Erzähler), keiner für den Detektiv. Marker: 2 je besetzter Rolle + 2 Detektiv + 2 Herr
  Schneider (höchstens 40).
- Schwellen aus `fall.json` `schwellen` (Verhörstuhl leise ab 12, Gegenüberstellung ab 14, sieben Minuten ab 18,
  Absätze „Die Rollen am Tisch“ selbst lesen ab 14, Abschnitt b kurz bis 8, Dankeskarte ab 13).

## 7. Längenregeln aus der Bibel

- Vorlesetexte (Fragen des Erzählers, „Dein Auftritt“, Absätze für Teil 90, Erzählerheft): keine Ziffern, keine
  Abkürzungen, Uhrzeiten und Beträge in Worten; Sätze höchstens 25 Wörter, im Mittel höchstens 14 (REG §6.5, G-10,
  ZG-12). Hefte, Karten, Streifen: „23:57 Uhr“, „2.000 €“.
- **Gleiche Gestalt der vier Verdächtigen** (E9, RK 1.1, RK 8.2, RK 7.7): gleiche Felder, gleiche Zahl an Einträgen
  (Kernsätze 2, Ausweichsätze 7, Impuls-Antworten 8, Auslöser 3, Freigabe 3/1/3, Aufträge 6, „Was nur du weißt“ 5,
  „Wenn es eng wird“ 5) und Längen innerhalb ±10 % ums Mittel je Teil. Wortbudgets RK 1.1 (Auftritt 65–80, Wer du bist
  75–95, Stufe 1 120–180, Erzähler-Antworten 120–145, Stufe 2 205–245, Seite 2 zusammen 465–535, Aufträge 230–280,
  Freigabe 90–120, Was du bei dir trägst 20–35, Aktionskarte 70–85, Bonus-Ziel 40–55) und RK 7.1 für die Fassungen
  (Ziel 25–35, Zeitleiste 350–420 in 16 oder 17 Zeilen, Was nur du weißt 100–120, Heft und Wahrheit 25–40, Wenn es eng
  wird 120–155, Stufe 3 55–70). Ausnahme: Cans Karte ohne Zeynep.
- Geheimniskarte „Was ich zugebe“ höchstens 60 Wörter; Aktionskarte Wirkung höchstens 45, Grenzen höchstens 30 Wörter;
  Zeugenstreifen-Protokoll höchstens 80 Wörter; Rückblende 400–500 Wörter (MECH 4.1, 4.3, 5.3, 8.3).
- Zeugenheft (ZG 0.6) und Zusatzheft (ZR 0.7): Budgets je Abschnitt dort.
