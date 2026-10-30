# Finale Schlosskeller · Spezifikation (verbindlich für alle Arbeitspakete)

Grundlage: `planung/finale/PLAN.md` (Besitzer-Entscheidungen 2026-10-27). Diese Datei legt Zahlen, Datenformen,
Schlüssel und Regeln fest. Abweichungen nur mit Eintrag unter „Änderungen“ am Ende dieser Datei.

Kurzbegriffe: **Kern** = `packages/mordakte_core/lib/src`, **App** = `lib`, **Inhalt** = `content/party/schlosskeller`.
Figuren-IDs ≠ Anzeigenamen: leyla→Lejla, johanna→Joanna, murat→Marek, meryem→Hana, kaan→Wojtek, dilara→Azra,
enes→Damir, selin→Sibel, hakan→Pawel. Besetzungsreihenfolge: ahmet, fatma, olli, can, leyla, emine, tim, johanna,
murat, zeynep, baran, meryem, serkan, aylin, kaan, dilara, enes, selin, hakan, tugba (4–20 Rollen).

## 0 · Harte Regeln (gelten überall)

1. **Andere Akten bitgleich.** Gewölbe, Ravensmoor, Nachtexpress, Blue Palm: keine Änderung an Verhalten, Texten,
   Ansichten. Beweis: `ui_basis_unveraendert_test`, Golden, `akte_pruefen` 0 Befunde, neuer `einfluss_gating_test`
   gegen einen **vor jeder Codeänderung** erzeugten Schnappschuss `andere_akten_soll.g.dart`.
2. **Gepinnt, nie anfassen:** alles in `tool/kanon_fest.txt` (u. a. `entscheidungen.json`, `bonus.json`,
   `gruppenwahl.json`, `tatmatrix/*`, `wahrnehmung.json`, `content/party/basis-ui/**`, `krimidinner/**`,
   `content/scenarios/**`). Die Golden-Dateien `test/runden/determinismus_soll*.g.dart` werden nie neu geschrieben.
3. **Neutral = alt.** Jede neue Schicht ist im Kern ein optionaler Parameter (Standard `null`/`false`). Ohne sie läuft
   jeder Code bitgleich wie heute (Golden k12, 9.216-Beweis in `partie_test`, alle bestehenden Tests unverändert grün).
4. **Pfadblind.** Keine vor dem Finale sichtbare Wirkung hängt vom Täterpfad, Fall-Code, Täter oder Hinweisqualität ab.
   Erlaubte Eingaben: Züge der Spieler, Salz-Würfel, statische öffentliche Eigenschaften der Optionen. Die Täterrolle
   hat dieselbe Gestalt wie alle (R13).
5. **Texte** stehen nur in `content/` (nie in Dart, `story_text_ausserhalb_test`). App-Bedienwörter in
   `lib/l10n/app_de.arb` (danach `flutter gen-l10n`, Wächter `arb_ton_test`). Ton: `planung/finalisierung-schlosskeller/
   TON-LEITFADEN.md`, Regeln `content/party/textregeln.json` (Sätze ≤25 Wörter, Schnitt ≤14 je Datei; Vorlesetexte ohne
   Ziffern, Klammern, Abkürzungen; Raumwort-Endungen wie -gang, -raum, -hof nur für echte Räume; kein Alkohol,
   Rauchen, Drogen, Blut, kein Verb für den Schlag; kein „Geburtstag“; alte Figurennamen aus `figuren.json` `quelle`
   verboten). Handy-Karten nach R17: ≤3 Stichpunkte zu ≤8 Wörtern plus ≤1 einzeilige Wahl.
6. **Werkzeug nach Inhaltsänderungen:** `bash tool/kanon_tor.sh` (Schemas, Story-Bibel, Prompts, eingebetteter Kanon,
   Prüfsummen, Inhaltskennung). Prüfen: `bash tool/kanon_tor.sh --pruefen`. Nur der Integrator erzeugt diese Artefakte.
7. **Rechenleistung:** 4 Kerne. Tests gezielt laufen lassen (`dart test test/pfad/datei_test.dart`,
   `flutter test test/...`), schwere Gesamtläufe nur durch den Integrator. Für `flutter test`: `ulimit -s 8192`.
   Werkzeug: `source tool/flutter_env.sh` (liegt in `.werkzeug/`; Worktrees: Symlink `.werkzeug` auf das Hauptrepo).

## 1 · Einstimmung (Vorgeschichte + Vorstellung) — Fähigkeit `einstimmung`

- Ablauf: Rollen → Vorgeschichte → Vorstellung → (Vorspiel, wenn lang) → Intro/Diashow → Runde 1.
- **Unterzustand von `PartyPhase.intro`** (Muster `rundgang`), keine neue Phase; Texte nie in `spiel.bausteine`.
- **Opt-in je Abend:** Kern/API `einrichten(..., einstimmung: false)` als Standard; Assistent schaltet für Akten mit
  Fähigkeit standardmäßig **an**, im Druckspiel aus. Journal schreibt `'einstimmung': true` nur wenn an; Raum-Meta ebenso.
- **Daten** `setting.json` (nur Schlosskeller):
  `"vorgeschichte": ["schloss","schneider","clique","einladung","keller","eigenarten","heute"], "vorstellung": true`
  (IDs dürfen die Autoren anpassen, 6–8 Teile). Strenges Schema `content/party/schema/setting.schema.json` erweitern,
  danach `python3 tool/schema_akte.py`.
- **Texte** (Bereich `erzaehler`, Format `{settingId, bereich, hinweis, eintraege:[{id,text}]}`):
  - `texte/erzaehler-vorgeschichte.json`: `vorgeschichte.<teil>`, je 70–120 Wörter, gesamt 600–750.
  - `texte/erzaehler-vorstellung.json`: `vorstellung.start` (≤35 W.), `vorstellung.<figurId>` für alle 20 (40–70 W.,
    3. Person, nur Öffentliches), `vorstellung.npc` (≤35 W., ohne Namen, für unbesetzte Gäste),
    `vorstellung.detektiv.m` / `.w` (40–70 W., an den Detektiv als „du“, nennt keine Figur).
  - Kapiteltitel (≤4 Wörter, nicht vorgelesen): `ui.einstimmung.titel.<teil>` in `texte/ui-erzaehler.json`.
  - `texte/index.json` +2 Dateien (58 → 60; `textpruefer_test` anpassen).
- **Namensregeln (Prüfer `pruefeEinstimmung`):** Vorgeschichte nennt nur ahmet, fatma, olli, can (immer besetzt) und
  Herrn Schneider, nie den Detektiv; jede der vier ≥1-mal, die meistgenannte ≤2× so oft wie die seltenste.
  `vorstellung.<f>` enthält den Anzeigenamen von f und nennt sonst nur Figuren mit kleinerem Besetzungsplatz, und nur
  wenn das Paar eine **öffentliche** Netzkante (§2) hat. Keine 5-Wort-Folge aus Geheimfeldern (`geheimeFelder` der
  Steckbriefe, Dossier `weiss`/`verbirgt`/`ziel`, Täter-, Finale-, Auflösungstexte, Pfadwissen), aus Zeitleiste ab
  18:00, aus `intro.*` oder dem Vorspiel. Keine Spoilerwörter (außer „Schneider“), keine Kennwörter der Beweisstücke,
  keine Urteilswörter, keine Ziffern. Inhalt der Vorgeschichte: Zeit **vor** dem Abend (Schloss, Stiftung, Schneiders
  Jahre, Entstehung der Clique, Einladung, öffentliche Keller-Fassung „Ahmet hat den Keller organisiert“ — nie Geld,
  Miete, Gefallen, Streich, Münzen, Schatulle, Türschaden, Steckdose).
- **Kern:** `party/pfadwissen.dart` (reiner Umbau: `_pfadwissen`, `_pfadneutral`, `_verboten` aus
  `test/party/spoiler_test.dart` als `pfadwissen(Kanon)`, `pfadneutraleFolgen(Kanon)`, `pfadwissenVerboten(Kanon)`,
  dazu `schlagVerbRe`; Testaussagen unverändert). `party/einstimmung.dart`: `EinstimmungTeil {vorgeschichte,
  vorstellung}`, `EinstimmungSchritt {teil, kennung, figur?, nr, von}`, `Einstimmung.aus(Kanon)` (null ohne
  `setting.vorgeschichte`), `schritte({rollen, detektiv})` (Blöcke → `vorstellung.start` → `besetzt(rollen)` in
  Reihenfolge → `vorstellung.npc` falls rollen<20 → `vorstellung.detektiv.<g>`), `katalog()`, `EinstimmungLauf`
  (gemeinsame Zustandsmaschine: `weiter(von)`, `ueberspringen()` = Rest des laufenden Teils, `fertig`),
  `pruefeEinstimmung(...)`. `erzaehler.dart katalog()` hängt `...?Einstimmung.aus(kanon)?.katalog()` an.
- **Zeit:** `fassung.dart`: `abendVorgeschichteMinuten = 5.0`, `abendEinstimmungMinuten(int rollen) => 5 + (rollen <=
  8 ? 2 : rollen <= 14 ? 4 : 6)`; `abendMinutenGenau/Ca({int? einstimmungRollen})` (null = heutige Werte).
- **Online:** `runden/raum/einstimmung_modul.dart` (`RaumModul`): Nachricht `einstimmung {schritt:int}` (falsche Nummer
  → `stale`) oder `{ueberspringen:true}`, nur `darfLeiten`; `darfWeiter` false solange läuft; öffentlich
  `einstimmung {teil, schritt, anzahl, nr, von, kennung, figur}`; privat nur an `vorleser`: `einstimmungText`.
  `rundgang_modul.dart` bekommt `wartet`-Rückruf (Vorspiel erst nach Einstimmung). `SchlosskellerRaum({Einstimmung?
  einstimmung})`. `sichtfelder.dart` +`'einstimmung'`. Server-Fabrik `{bool einstimmung = false}`.
- **App:** `PartySitzung` (`einstimmung`, `einstimmungSchritte`, `einstimmungWeiter`, `einstimmungUeberspringen`,
  `kannWeiter`-Sperre vor der Vorspiel-Prüfung, Journal/Replay), `bildschirme/einstimmung.dart`
  (`EinstimmungBildschirm`, `VorstellungsKarte`: Kapitelzähler „Vorgeschichte · 3 von 7“, `ErzaehlerFeld` mit genau einer
  Kennung — Stimme liest wortgleich; Karte mit Porträt, Name, Rollentitel, Steckbrief-Satz; **„gespielt von {Name}“
  außerhalb des ErzaehlerFelds**, solo „Die App spielt …“; Hinweis „Wer genannt wird, steht kurz auf.“), Fall in
  `party_seite.dart`, Online: `gast_einstimmung.dart`, `gastgeber_sitzung.dart`, `erzaehler_begleiter.dart`,
  `gast_ansicht.dart`. Assistent: Schalter „Vorgeschichte und Vorstellung“. Dev-Skript `einstimmung=1`.

## 2 · Erzählerakte — Fähigkeit `erzaehlerakte`

- **Datei** `content/party/schlosskeller/erzaehlerakte.json` (außerhalb `Kanon.dateien`, wie `steckbriefe.json`),
  Schema `content/party/schema/erzaehlerakte.schema.json` (`additionalProperties:false`):
  ```json
  {"format":"erzaehlerakte/1","settingId":"spuk_im_schlosskeller",
   "hinweis":"Nur für die Person, die erzählt (A-063). Pfadgleich; nie Täter, Pfad, Tatwissen, Tarnung, Fall-Code, Hinweisqualität.",
   "einleitung":"2–4 Sätze an den Erzähler.",
   "schneider":{"hintergrund":"80–140 Wörter","stimme":["≤8 Wörter","…"]},
   "detektiv":{"hintergrund":"40–80 Wörter","stimme":["…"]},
   "figuren":[{"figur":"ahmet","hintergrund":"80–140 Wörter","zuSchneider":"≤40 Wörter","stimme":["2–3 Punkte ≤8 Wörter"]}],
   "netz":[{"a":"ahmet","b":"leyla","art":"familie","sichtbar":"oeffentlich","text":"≤12 Wörter"}]}
  ```
  `art` ∈ familie, freundschaft, schule, studium, arbeit, nachbarschaft, verein, gefallen, schuld, streit;
  `sichtbar` ∈ oeffentlich, heimlich. ≥2 Kanten je Figur; jede `loyalitaet` ist eine Kante; jedes in `dossier.wer`
  genannte Paar ist eine **öffentliche** Kante (bekannt: Lejla–Ahmet Cousine, Emine–Fatma beste Freundin, Zeynep–Can
  Schwester). Etwa 45 Kanten. Knoten: Figuren-IDs und `schneider`.
- **Aus dem Kanon gezogen (nicht kopiert):** name, vollerName, age, roleTitle, alltag, `motiveAndConflict` (Motiv),
  `roleSecret` (Geheimnis), `nebendelikt.text`, `loyalitaet{zu,grund}`, Ziele über `ZielQuelle` (Standard
  `KanonZiele` liest `persoenlichesZiel`; die Einfluss-Schicht liefert ihre Sterne). **Nie gelesen:** `killerProfile`,
  `innocentProfile`, `luegen`, `blackoutAlibi`, `tatmatrix/*`, `taeter-*`, `erzaehler-finale-*`, `erzaehler-aufloesung`,
  `bonus`, Begründungen.
- **Kern** `party/erzaehlerakte.dart`: `erzaehlerakteFormat`, `NetzKante`, `ErzaehlerZiel {id,text}`,
  `abstract interface class ZielQuelle { List<ErzaehlerZiel> zieleVon(String figur); }`, `KanonZiele`,
  `ErzaehlerakteFigur`, `Erzaehlerakte.ausJson(Map, Kanon, {ZielQuelle? ziele})`, `kantenVon`, `toJson()`.
  JSON-Schlüssel ohne `ziel`/`weiss`/`verbirgt` (verwende `ziele`, `geheimnis`, `nebendelikt`). Keine Pfad-/Code-Parameter.
  `pruefeErzaehlerakte(...)`: Vollständigkeit (je Figur genau ein Eintrag + schneider + detektiv), Größen, Netzregeln,
  Pfadfreiheit auf dem zusammengesetzten `toJson()` (5-Wort-Regel gegen `pfadwissenVerboten` und Täter-/Finale-/
  Auflösungstexte), verbotene Wörter außerhalb `einleitung` (täter*, pfad, fall-code, tarnung, tatwissen, sabotage,
  qualität*), Ton (Ziffern erlaubt, kein Vorlesetext).
- **Sichtbar nur dem Erzähler-Platz**: reihum (Rollenbildschirm und Erzählerpult, zugedeckt), Erzähler-Handy
  (Begleiter), online Erzähler-Sitz (Gast und Gastgeber). Nie solo, Detektiv, Rolle, Assistenz, nie ab Finale. Online
  wird lokal aus der Akte des Geräts dargestellt (Inhaltskennung garantiert gleiche Fassung), nicht übertragen.
- **App** `lib/party/erzaehlerakte_ansicht.dart`: Reiter „Figuren“ (besetzte zuerst, dann „ohne Spieler“; Abschnitte
  Hintergrund, Bindungen, Zu Herrn Schneider, Motiv, Geheimnis, Nebendelikt, Loyalität, Ziele, Stimme) und „Netz“
  (Ring mit CustomPainter: Schneider in der Mitte, öffentlich durchgezogen, heimlich gestrichelt).
- **Druck:** `druck/fest_erzaehlerakte.dart` → `erzaehlerakte.pdf` in `4-nur-erzaehler` (Deckblatt „Nur für dich als
  Erzähler“, Netzseite mit Ring und Legende, Seite je Figur); `paket.dart` (`PaketKontext.erzaehlerakte`),
  `veranstalter.dart` (Dateiliste, Zeiten Vorgeschichte/Vorstellung; Veranstalter-PDF bleibt 3 Seiten),
  `bin/party_druck.dart --erzaehlerakte --personen N --aus DIR` (ohne `--code`). Erzählerheft (`fest_spielleitung.dart`,
  `spielleitung.dart`): Abschnitte „Vorgeschichte“ und „Vorstellung“ vor dem Intro (je besetzte Figur Porträt, Name,
  Rolle, „gespielt von: ________“, Text; beide Detektiv-Fassungen nebeneinander; Sammelblock). Beschriftungen nur in
  `texte/ui-druck-paket.json` / `ui-druck-spielleitung.json` des Schlosskellers.
- `akte_pruefen.dart`: Schema-Prüfung `erzaehlerakte.json`, `_einstimmung`, `_erzaehlerakte` (Datei genau dann, wenn
  Fähigkeit gesetzt).

## 3 · „Dein Moment“ — Einfluss-Schicht — Fähigkeit `einfluss`

### 3.1 Ablauf je Runde (nur mit Schicht)
Gespräche (währenddessen **Dein Moment**) → beim Wechsel zu `entscheidungen`: **Folgen** auswerten und als Bausteine
anhängen → 3 Entscheidungen mit Tischwerten → **Flüstern** (Phase `bonus`) → Zwischenresümee. Die Phase
`gruppenwahl` wird mit Schicht übersprungen (`entscheidungen → bonus`). Ohne Schicht: alles wie heute.
Langer Abend: Der Moment muss vor der ersten Entscheidung der Runde stehen; die Folgen kommen beim Beginn der
Ermittlung. Druckspiel: immer ohne Schicht (Papierstreifen A/B bleiben, BE-12).

### 3.2 Züge (jede besetzte Rolle, Mensch oder Bot, genau ein Zug je Runde; Detektiv, Erzähler, Assistenz ziehen nicht)

| Art (`ZugArt`) | Ziel | Wirkung | Sichtbarkeit | Leisten |
|---|---|---|---|---|
| `zeigen` | Figur X ≠ ich (besetzt) | +1 Tischstimme auf Optionen dieser Runde mit X ∈ Bezug | öffentlich anonym: Gerücht über X (leise 1, laut ≥2) | Spuk +1 Gewicht |
| `decken` | Figur X (auch ich) | −1 Tischstimme auf Optionen mit X ∈ Bezug | X (falls ≠ ich) privat „Jemand hält zu dir“/„Mehrere …“; Ertappt-Gefahr | – |
| `helfen` | – | +3 Nachtminuten (Summe ≤ +9 je Runde) | anonym | Zusammenhalt +1 |
| `auspacken` | – (einmal am Abend) | eigenes Geheimnis in die Funde (§3.6) | öffentlich mit Namen | Zusammenhalt +2 |
| `ablenken` | – | −4 Nachtminuten (Summe ≤ −8 je Runde) | öffentlich mit Namen + Gag-Zeile | Spuk +2, Zusammenhalt −1 |
| `lauschen` | Figur X ≠ ich | erfährt privat Art und Ziel von X in dieser Runde | nur ich | – |

Kein Zug bis zur Frist = `abgewartet` (ohne Wirkung, nie gezeigt). Runde 3: zusätzlich **Tipp** „Wer war's?“
(ahmet|fatma|olli|can|keiner), verdeckt bis zur Auflösung, ohne Einfluss auf die Anklage.

### 3.3 Bezug und Tischwert
Bezug je Option (statisch, pfadfrei, in `einfluss.json`):

| Option | Bezug |
|---|---|
| e1_1_joanna | johanna, ahmet |
| e1_1_damir | enes, ahmet |
| e1_2_emine | emine, fatma |
| e1_2_tugba | tugba, fatma, olli |
| e1_3_tim | tim, can |
| e1_3_azra | dilara, olli |
| e2_1_ascheneimer | ahmet, meryem |
| e2_1_bauchtasche | can, zeynep |
| e2_2_vitrine | fatma, dilara, selin |
| e2_2_tasche | fatma, emine |
| e2_3_olli | olli, kaan |
| e2_3_kamin | olli, meryem |
| e3_1_turmgang | can, selin |
| e3_1_ostsaal | ahmet, baran |
| e3_1_buffetsaal | fatma, olli, enes |
| e3_2_fatma | fatma |
| e3_2_kerzenstaender | ahmet, fatma, olli, can |
| e3_3_zeynep | zeynep, can |
| e3_3_aylin | aylin, ahmet |

Prüfer: Je Runde kommen die vier Kernfiguren in gleich vielen Optionen vor (±1). Unbesetzte Figuren im Bezug sind wirkungslos.
**v(o)** = Anzahl `zeigen` mit Ziel ∈ Bezug(o) − Anzahl `decken` mit Ziel ∈ Bezug(o) (je Zug höchstens einmal je Option).
**m(n)** = ⌈n/5⌉. **T(o)** = sign(v)·min(2, ⌊|v|/m(n)⌋). T steht vor der Wahl als Abzeichen an jeder Option.

### 3.4 Würfel und Befragung
- **Suche:** Modifikator = clamp(basis + T + u, −2, +3), basis nach K-07 unverändert (Werkzeug +1, gründlich +2, Marke
  +1, Deckel +2, Markenlogik wie heute), u = +1 nur im Anlauf direkt nach einem Umweg. **Ist T = 0 und u = 0, ist das
  Ergebnis exakt basis** (Golden-Schutz). Seed-Formel, Pech-Garantie, „Pech gibt Marke“, Abstecher unverändert
  (Abstecher ohne Tischwert). Die Chancenvorschau zeigt eine Zeile „Tisch“.
- **Befragung** (würfelfrei): T ≥ +1 „Redselig“ = +1 Randnotiz; T = −1 „Zögert“ = +3 Minuten; T = −2 „Mauert“ = +3
  Minuten und die Fakten werden erst im Zwischenresümee sichtbar.
- **Erfolg:** Fund + 7 Minuten (wie heute) + **Zusatzfund** = 1 Randnotiz aus dem Vorrat der Option (die erste noch
  nicht gezeigte). Gab es `decken` auf eine Figur im Bezug: **Ertappt** — ein Decker wird öffentlich genannt, gezogen
  über `Rng.hashString('ertappt:<salz>:<entscheidungsId>')` aus den Deckern in Besetzungsreihenfolge.
- **Teilerfolg:** nur der Fund.
- **Pech:** Marke wie heute, Zustand „Die Spur verwischt“; Tischruf: **Nochmal** (3 Min., gleiche Stelle, T gilt
  erneut, Zusatzfund und Ertappt bleiben möglich) oder **Umweg** (3 Min., u = +1 und negatives T zählt im nächsten Anlauf
  nicht; dafür kein Zusatzfund, kein Ertappt dieser Suche, Fakten erst im Zwischenresümee). Kein Fund wird je gelöscht.

### 3.5 Randnotizen
Randnotiz = Beobachtung aus `beobachtungen.json` mit `pfade: "alle"` (Prüfer erzwingt das), Anzeige als Kurzfassung im
Notizbuch, ohne Wirkung auf Regeln/Restmenge. Vorrat je Option in `einfluss.json` (1–2 IDs). Vorschlag:
e1_1_joanna: b_joanna_foto · e1_1_damir: b_damir_an_der_theke · e1_2_emine: b_emine_versteck · e1_2_tugba: b_tugba_notiz
· e1_3_tim: b_tim_gesicht · e1_3_azra: b_azra_versteck · e2_1_ascheneimer: b_hana_umschlag · e2_1_bauchtasche:
b_marek_gesicht · e2_2_vitrine: b_selin_gesicht · e2_2_tasche: b_azra_tasche · e2_3_olli: b_wojtek_olli_satz ·
e2_3_kamin: b_hana_wachs · e3_1_turmgang: b_wojtek_vorbei · e3_1_ostsaal: b_baran_rufe · e3_1_buffetsaal: b_zeynep_gesicht
· e3_2_fatma: b_emine_schatulle · e3_2_kerzenstaender: b_hana_wachs · e3_3_zeynep: b_zeynep_vorrat · e3_3_aylin:
b_aylin_quittung (Doppelte erlaubt; der Prüfer verlangt nur `pfade: alle`).
**Nachfragen:** Nach Runde 3, vor der Anklage: je volle 10 Restminuten 1 Nachfrage (höchstens 2, +1 durch Ereignis
„Herr Schneider erinnert sich“). Eine Nachfrage zeigt eine noch nicht gezeigte Randnotiz einer beliebigen gewählten
Option (auch verlorene).

### 3.6 Auspacken (je Figur, nur Quellen, die in allen Pfaden gelten — Prüfer: Fakt existiert in allen 4 Pfaden bzw. Beobachtung `pfade: alle`)

| Figur | Fakt (zählt für Regeln) | Randnotiz |
|---|---|---|
| ahmet | f_nd_ahmet_umschlag | – |
| fatma | f_nd_fatma | – |
| olli | f_nd_olli | – |
| can | f_nd_can_maske | – |
| leyla | – | b_lejla_ahmet_theke |
| emine | f_nd_fatma | b_emine_schatulle |
| zeynep | f_nd_can_zeynep | b_zeynep_vorrat |
| kaan | f_nd_olli | b_wojtek_tuer |
| johanna | f_foto_streit (falls in allen Pfaden, sonst nur Notiz) | b_joanna_foto |
| aylin | f_nd_ahmet_quittung | b_aylin_quittung |
| tim | f_kurzschluss | b_tim_kurzschluss |
| murat | – | b_marek_gesicht |
| baran | – | b_baran_rufe |
| meryem | – | b_hana_umschlag |
| serkan | – | b_serkan_tor |
| dilara | – | b_azra_tasche |
| enes | – | b_damir_an_der_theke |
| selin | – | b_selin_gesicht |
| hakan | – | b_pawel_schneider |
| tugba | – | b_tugba_notiz |

Ein so gelieferter Nebendelikt-Fakt zählt für R-ENTLASTET wie ein gefundener (ein unschuldiger Kern mit Alibi scheidet
aus; der Täter hat im eigenen Pfad nie ein Alibi). Nach dem Auspacken ist die Kachel ausgegraut.

### 3.7 Nachtminuten
Runde r: Budget = 45 + Übertrag (r ≥ 2: min(15, Rest am Ende von r−1)) + Σhelfen (≤ +9) − Σablenken (≤ 8) ± Ereignisse,
**Boden 42** (3 × 14 Reserve, K-12). Abstecher, Tischruf, gründlich wie heute. Mit Schicht kein Minutenverfall am
Rundenende außer über 15 hinaus.

### 3.8 Leisten und Ereignisse (0–6, wirken nur bei den Folgen)
n_eff = max(n, 5). K = Σhelfen + 2·Σauspacken − Σablenken (min 0); L = Σzeigen + 2·Σablenken.
Zusammenhalt-Zuwachs: +2 wenn 5K ≥ 3·n_eff, +1 wenn 5K ≥ 2·n_eff, sonst 0. Spuk-Zuwachs: +2 wenn 2L ≥ n_eff, +1 wenn
4L ≥ n_eff, sonst 0. Jedes Ereignis einmal am Abend, wenn die Schwelle erreicht wird:

| Leiste | Stufe | ID | Wirkung |
|---|---|---|---|
| Zusammenhalt | 2 | `tee` | +5 Minuten in dieser Runde |
| Zusammenhalt | 4 | `kerzenschein` | nächste Suche ignoriert negatives T |
| Zusammenhalt | 6 | `erinnerung` | +1 Nachfrage |
| Spuk | 2 | `flackerlicht` | −3 Minuten in dieser Runde (Boden 42) |
| Spuk | 4 | `fledermaus` | diese Runde zählt negatives T doppelt (Deckel −2); jeder Erfolg bringt 2 Randnotizen |
| Spuk | 6 | `kragen` | −5 Minuten (Boden 42), Morgen-Variante chaotisch |

Ereignistexte nennen nie Fallgegenstand, Suchstelle, Indizort, Lacher oder Sperrort (R15): erlaubt sind Lichtschächte,
Gewölbedecke, Teekocher, Notlicht, Fledermaus u. Ä.
**Flüstern** (Phase `bonus`): Zusammenhalt-Zuwachs dieser Runde +2 → wahrer Hinweis (`bonus.json`, Qualität wahr),
+1 → neutraler Hinweis, 0 → Satz `einfluss.fluestern.still`. Falsche Hinweise kommen mit Schicht nicht vor.

### 3.9 Persönliche Ziele (zwei Sterne je Figur, pfadfrei)
Bedingungssprache (in `einfluss.json`):
```
B := {"alle":[B..]} | {"eine":[B..]} | {"nicht":B} | {"mind":[W,int]} | {"hoechstens":[W,int]} | {"gleich":[W,W|wert]}
W := "angeklagt" | "bekannt:<faktId>" | "gestanden:<fig|ich>" | "zuege:<art>" | "zieleAuf:<art>:<fig>"
   | "ertappt:<fig|ich>" | "geruecht:<fig|ich>" | "zusammenhalt" | "spuk" | "rest" | "auspackRunde:<fig|ich>"
   | "jedeRunde:<art>"
```
Kein Atom kennt Pfad, Täter, Qualität. `bekannt:<f>` = Fakt bei der Anklage sichtbar. Bewertung nach der Anklage;
der eigene Stand ist privat jederzeit sichtbar („erreicht“, „verloren“, „offen“). Prüfer: jedes Ziel parsebar,
erreichbar und verfehlbar; die vier Kernfiguren haben dieselbe Form.

| Figur | Stern I | Stern II |
|---|---|---|
| ahmet | Die erfundene Miete bleibt bis zur Anklage geheim (nicht bekannt f_nd_ahmet_umschlag, f_nd_ahmet_quittung) | Der Detektiv klagt dich nicht an |
| fatma | Die Schatulle bleibt geheim (nicht bekannt f_nd_fatma) | nicht angeklagt |
| olli | Der Türschaden bleibt geheim (nicht bekannt f_nd_olli) | nicht angeklagt |
| can | Dein Streich bleibt geheim (nicht bekannt f_nd_can_maske, f_nd_can_zeynep) | nicht angeklagt |
| leyla | Du deckst Ahmet mindestens zweimal | Ahmet wird nicht angeklagt |
| emine | Du packst nie aus | Fatma wird nicht angeklagt |
| tim | Der Kurzschluss bleibt geheim (nicht bekannt f_kurzschluss) | Du wirst nie ertappt |
| johanna | Du packst nie aus | Du lauschst mindestens einmal bei Ahmet |
| murat | Der Spuk endet bei höchstens drei | Cans Streich kommt heraus (bekannt f_nd_can_maske oder f_nd_can_zeynep) |
| zeynep | Du deckst Can mindestens zweimal | Can wird nicht angeklagt |
| baran | Du lenkst mindestens einmal ab | Der Spuk endet unter vier |
| meryem | Du packst spätestens in Runde zwei aus | Der Zusammenhalt endet bei mindestens vier |
| serkan | Du hilfst mindestens zweimal | Am Ende bleiben mindestens zehn Nachtminuten |
| aylin | Ahmets Miete kommt heraus (bekannt f_nd_ahmet_umschlag oder f_nd_ahmet_quittung) | Du zeigst nie auf Ahmet |
| kaan | Du packst nie aus | Olli wird nicht angeklagt |
| dilara | Du packst spätestens in Runde zwei aus | Du deckst Fatma nie |
| enes | Über dich wird nie getuschelt | Der Zusammenhalt endet bei mindestens drei |
| selin | Der Spuk endet bei höchstens zwei | Du lenkst nie ab |
| hakan | Du packst nie aus | Der Spuk endet bei höchstens drei |
| tugba | Du hilfst in jeder Runde | Der Zusammenhalt endet bei mindestens vier |

### 3.10 Ende, Auflösung, Auszeichnungen, Erfahrung
- **Endwert** = clamp(Punkte + Tischbonus, 0, 9); Tischbonus +1 wenn Zusammenhalt ≥ 4, −1 wenn Spuk ≥ 4, beides → 0.
  Matrix aus `fall.json` mit Endwert; richtig/falsch nur durch die Anklage. Punkte roh angezeigt.
- **Geklärt-Regel:** Eine Entscheidung zählt zusätzlich als richtig, wenn alle Fakten, die die richtige Option im Pfad
  liefern würde, vor dem Öffnen der Entscheidung schon über Auspacken sichtbar waren (hebt Punkte nur an).
- **Auflösung:** Text je Rolle wie heute + Epilog-Zeile (`einfluss.epilog.<fig>.erreicht|verfehlt` je nach Sternen ≥1),
  „Protokoll der Nacht“ (alle Züge als Symbole, nicht vorgelesen), Tipps, Auszeichnungen: **Stern des Abends** = max
  (3·Sterne + 2·Spürnase + min(2, gestützte Erfolge) + 1·ausgepackt; Gleichstand: weniger Ertappt, dann
  Besetzungsreihenfolge); **Spürnasen** (Tipp richtig); **Schlossgeist** (meiste Spuk-Gewichte); **Treue Seele**
  (meiste `decken` für andere). „Gestützte Erfolge“ = Erfolge auf Optionen, auf deren Bezug die Figur `zeigen` spielte.
- **Morgen-Variante:** warm (Zusammenhalt ≥ 4 und Spuk < 4), chaotisch (Spuk ≥ 4 und Zusammenhalt < 4), gemischt sonst.
- **Erfahrung** (`karten/belohnung.dart`): Gäste +15 je Stern, +25 Stern des Abends, +10 Spürnase; Detektiv nach dem
  verschobenen Ende. Nur mit Schicht.

### 3.11 Bots (eigener Strom `einfluss:<salz>:<rolle>:<runde>`, pfadfrei, Persönlichkeit je Figur)
Gewichte Helfen / Decken (Ziel) / Zeigen / Ablenken / Lauschen (Ziel):
ahmet 30/40 ich/10/10/10 · fatma 20/50 ich/10/0/20 emine · olli 40/30 ich/10/10/10 · can 10/30 ich/15/35/10 ·
leyla 30/50 ahmet/0/0/20 ahmet · emine 30/50 fatma/0/0/20 fatma · tim 40/30 ich/10/20/0 · johanna 30/20 ahmet/0/0/50 ahmet
· murat 40/0/30/10/20 · zeynep 20/50 can/0/20/10 · baran 30/0/20/40/10 · meryem auspacken in Runde 1, danach
60/0/20/0/20 · serkan 70/0/10/0/20 · aylin 40/0/0/0/40 ahmet, auspacken in Runde 3 mit 60 % · kaan 30/50 olli/0/0/20 ·
dilara 40/10 ich/10/0/20, auspacken in Runde 2 mit 60 % · enes 70/0/0/10/20 · selin 50/20 ich/0/0/30 · hakan
80/0/0/0/20 · tugba 60/0/20/20/0. Ziel ohne Angabe: Zeigen auf die meistberedete Figur, sonst gezogene Kernfigur ≠ ich
und ≠ Freund; Lauschen gezogen. Ist das Ziel unbesetzt, Ersatz aus dem Strom.
Overrides: nach Ertappt kein Decken (stattdessen Helfen); „Mehrere tuscheln über mich“ → 50 % Zeigen auf meistberedete
andere Figur; Freund beredet → Decken des Freundes; eigenes Geheimnis schon bekannt → kein Selbst-Decken; Bots sehen
nur Öffentliches (nie Pfad, Dossier, Fall). Tipp der Bots: gezogen aus den noch verdächtigen Kernfiguren (öffentliche
Restmenge). Solo: bis zu 3 Reaktionsblasen je Folgen (`einfluss.bot.<fig>.<anlass>`, Anlass ∈ ertappt, geruecht,
freund_gestanden, ablenken).

### 3.12 Sichtbarkeit
Nie vor der Auflösung: wer `zeigen`/`decken`/`helfen`/`lauschen` spielte, alle Zählwerte, Tipps, fremde Ziele.
Öffentlich: Auspacken (Name + Inhalt), Ablenken (Name), Ertappt, Gerüchte (anonym), Leisten, Ereignisse, Tischwerte,
Randnotizen. Privat: „Jemand hält zu dir“, Lauschergebnis, eigener Zielstand, „Dein Zug wirkte …“. Erzähler privat:
Zug-Tafel der laufenden Runde (wer was spielte), nie Pfad, Qualität, Tipps.

### 3.13 Daten und Text-Schlüssel
- `content/party/zusatz/schlosskeller/einfluss.json` + Schema `content/party/zusatz/einfluss.schema.json`:
  `{format:"einfluss/1", akte, zahlen{…§3.3–3.8…}, arten[…], bezug{optionId:[fig]}, randnotizen{optionId:[bId]},
  auspacken{fig:{fakt?, notiz?}}, ereignisse[…], bots{fig:{…}}, ziele{fig:[{id, bedingung}, {id, bedingung}]}}`.
- Texte `content/party/schlosskeller/texte/einfluss.json`, Bereich **`einfluss`** (neu: Enum in
  `texte-index.schema.json`, `_schemaJeBereich` in `bin/akte_pruefen.dart` und `test/party/texte_test.dart`,
  `Textsammlung`, `textQuellen`). Platzhalter `@figur`, `@ziel` (→ Anzeigename). Schlüssel:
  - Karten: `einfluss.zug.<art>.titel`, `.p1`, `.p2`, `.p3`, für Zielarten `.wahl` (R17); `einfluss.tipp.titel`, `.wahl`.
  - Folgen: `einfluss.folgen.start.1..3`, `einfluss.auspacken.<fig>` (20), `einfluss.ablenken.<fig>` (20),
    `einfluss.ablenken.schluss`, `einfluss.geruecht.leise`, `einfluss.geruecht.laut`, `einfluss.leiste.zusammenhalt.1|2`,
    `einfluss.leiste.spuk.1|2`, `einfluss.leiste.ruhig`, `einfluss.ereignis.<id>` (6) und `.karte` (6),
    `einfluss.wieder`, `einfluss.fluestern.still`.
  - Ermittlung: `einfluss.abzeichen.plus1|plus2|minus1|minus2`, `einfluss.befragung.redselig|zoegert|mauert`,
    `einfluss.ertappt`, `einfluss.ertappt.selbst`, `einfluss.verwischt`, `einfluss.tischruf.nochmal|umweg`,
    `einfluss.nachfrage.titel`, `einfluss.nachfrage.p1`.
  - Privat: `einfluss.privat.haelt_zu_dir`, `.mehrere_halten`, `.gelauscht`, `.wirkte`, `.ohne_folgen`, `.ertappt`.
  - Ziele: `einfluss.ziel.<fig>.1|2` (≤8 Wörter), `einfluss.epilog.<fig>.erreicht|verfehlt` (≤30 Wörter).
  - Ende: `einfluss.tischbonus.plus|minus`, `einfluss.preis.stern|spuernase|schlossgeist|treue_seele` (mit `@figur`),
    `einfluss.morgen.warm|chaotisch|gemischt`.
  - Bots: `einfluss.bot.<fig>.<anlass>` (≤8 Wörter).
  Vorlesetexte (Folgen, Ereignisse, Ende, Morgen, Epiloge) folgen den Vorleseregeln; Karten R17.
- `content/party/akten.json`: Schlosskeller-Fähigkeiten + `einstimmung`, `erzaehlerakte`, `einfluss`.

### 3.14 Technik (Kern)
`runden/einfluss.dart` (`ZugArt`, `EinflussZug`, `EinflussRegeln.ausJson(json, Ermittlung)`, `EinflussStand`
(rein, ohne Pfad): `setze`, `vollstaendig`, `auswerten(runde)`, `tisch(runde, optionId)`, Leisten, Ereignisse,
Minuten, `botZug(...)`), `runden/einfluss_ziele.dart` (Sprache, Auswertung), `runden/einfluss_pruefung.dart`.
Haken mit neutralem Standard: `wuerfel.dart` (`gesamt(basis, extra, {boden, deckel})`, extra 0 ⇒ basis),
`zugschicht.dart` (`ZugParameter` `modBoden`, `modDeckel`, `umwegBonus`; `beginneRunde(r, {zusatzMinuten})`;
`waehle(..., {tisch})`), `partie.dart` (`RundenPartie(..., {EinflussRegeln? einfluss})`, `zugSetzen`, Verzögerung,
Randnotizen, sichtbare Fakten, Nachfragen), `party/ablauf.dart` (`SpielZusatz {sichtbar, nachWechsel, tischbonus,
ueberspringeGruppenwahl}`, `Spiel.zusatz` Standard null, `sichtbareFakten`, `ende` mit Endwert), `erzaehler.dart`
(Resümee aus sichtbaren Fakten), `texte.dart` (Bereich `einfluss`). Architekturwächter: `einfluss.dart` importiert und
nennt weder `pfad`, `Pfad`, `taeter`, `qualitaet`, `FallCode`.
Raum: `SchlosskellerRaum({EinflussRegeln? einfluss})`, Nachricht `zug {art, ziel?, tipp?}` in `gespraeche`
(änderbar bis Folgen; Fehler `invalid_phase`, `invalid`), Weiter aus `gespraeche` erst wenn alle gezogen haben oder
nach `letzterAufruf` (60 s, danach `abgewartet`; getrennte Plätze nach 2 Min. als Bot). Öffentlich `einfluss`
(in `sichtfelder.dart`), privat je Rolle `moment`, Erzähler `einflussTafel`, nach dem Finale `aufloesung.einfluss`.
`packages/mordakte_netz/lib/src/protokoll.dart` `protokollVersion` 4 → 5. Server `server/lib/party.dart` lädt
`einfluss.json` nur mit Fähigkeit. App: `abendstand/3`; `einrichten` merkt `einfluss: true`; alte Stände ohne
Eintrag laufen ohne Schicht.

## 4 · Invarianten und Prüfungen (Pflicht)
T-N neutral (Golden k12 und 9.216 unverändert; andere Akten gegen `andere_akten_soll.g.dart`), T-W Wahrheit
(sichtbare Fakten ⊆ Fakten des Pfads; der Täter wird nie entlastet), T-L Lösbarkeit (beim Öffnen jeder Entscheidung
alle Begründungsfakten früherer Runden sichtbar; bei der Anklage alles), T-B bestes Spiel → Meister für jedes Profil
und n = 4–20, T-P pfadblind (gleiche Eingaben ⇒ gleiche öffentliche Spur in allen 4 Pfaden), T-G Architektur,
T-K Klasse (Anklage bestimmt richtig/falsch), Determinismus (`einfluss_soll.g.dart`, 1.000 Codes, nie neu schreiben).
Erzählteil: Privatsphäre und Pfadgleichheit der Erzählerakte, Fehlerproben je Prüfer.

## 5 · Entscheidungen und Regeln (Text in `planung/gesamt/STATUS.md` u. a.)
A-063 Einstimmung und Erzählerakte (ersetzt A-052 nur für die Erzählerakte) · A-064 Einfluss-Schicht „Dein Moment“
(ersetzt im App-Abend die A/B-Gruppenwahl; R4/R16 gelten nur noch für Dialoge und Gruppenszenen; G-1 entfällt in der
App) · A-065 Würfel von Spielern geformt (K-06/K-07/K-15 Nachträge) · A-066 Ziele, Tischbonus, Auszeichnungen ·
E-046/E-047 im ENTSCHEIDUNGSLOG · R18 (Einstimmung), R19–R25 (Einfluss) in `ERZAEHLREGELN.md` · K-27 ff. in `SPIELKERN.md`.

## Änderungen
- 2026-10-27 (Ergänzung §3.13): **Textart je Schlüssel im Bereich `einfluss`.** Vorlesetexte (Vorleseregeln:
  keine Ziffern, Klammern, Abkürzungen; Sätze ≤25 Wörter): `einfluss.folgen.*`, `einfluss.auspacken.*` (20–45 Wörter),
  `einfluss.ablenken.*` (15–35 Wörter), `einfluss.geruecht.*`, `einfluss.leiste.*`, `einfluss.ereignis.<id>` (ohne
  `.karte`, 20–50 Wörter), `einfluss.wieder`, `einfluss.fluestern.still`, `einfluss.ertappt`, `einfluss.ertappt.selbst`,
  `einfluss.verwischt`, `einfluss.tischbonus.*`, `einfluss.preis.*`, `einfluss.morgen.*` (20–50 Wörter),
  `einfluss.epilog.*` (≤30 Wörter). **Karten** (R17, je Schlüssel genau ein Stichpunkt ≤8 Wörter, keine Prosa):
  `einfluss.zug.*`, `einfluss.tipp.*`, `einfluss.ereignis.<id>.karte`, `einfluss.abzeichen.*`, `einfluss.befragung.*`,
  `einfluss.tischruf.*`, `einfluss.nachfrage.*`, `einfluss.privat.*`, `einfluss.ziel.*`, `einfluss.bot.*`.
  Zugarten für `einfluss.zug.<art>`: zeigen, decken, helfen, auspacken, ablenken, lauschen; `.wahl` nur bei zeigen,
  decken, lauschen. Ereignis-IDs: tee, kerzenschein, erinnerung, flackerlicht, fledermaus, kragen. Platzhalter `@figur`
  (Anzeigename der handelnden/genannten Figur) und `@ziel` (Anzeigename des Ziels); `einfluss.ertappt` nutzt beide,
  `einfluss.ertappt.selbst` nur `@figur`, `einfluss.geruecht.*` nur `@figur` (die beredete Figur),
  `einfluss.preis.*` nur `@figur`, `einfluss.privat.gelauscht` `@figur` und `@ziel` plus `@zug` (Kurzname der Zugart aus
  `einfluss.zug.<art>.titel`). Entwürfe der Inhalte entstehen in `planung/finale/entwurf/` und werden vom Integrator in
  `content/party/schlosskeller/texte/einfluss.json` zusammengeführt.
- 2026-10-27 (Entscheidungen nach der Inhaltsprüfung „Dein Moment“):
  1. **Lauschen ohne Ziel/abgewartet:** neue Kartenschlüssel `einfluss.privat.gelauscht.ohne_ziel` (`@figur`, `@zug`) und
     `einfluss.privat.gelauscht.abgewartet` (`@figur`); `einfluss.privat.gelauscht` nur bei Zügen mit Ziel.
  2. **Kragen erzwingt den chaotischen Morgen** (Vorrang vor der Regel in §3.10).
  3. **Ereignistitel:** neue Kartenschlüssel `einfluss.ereignis.<id>.titel` (≤3 Wörter). Die ID `kerzenschein` bleibt
     intern; Titel ohne das Wort „Kerze“ (z. B. „Goldener Schein“).
  4. `einfluss.leiste.<leiste>.1|2` = Zuwachs +1 bzw. +2 in dieser Runde; `einfluss.leiste.ruhig` = kein Zuwachs.
  5. `einfluss.folgen.start.<r>` = Eröffnung in Runde r (1–3).
  6. **Tipp:** neuer Kartenschlüssel `einfluss.tipp.p1` (verdeckt bis zur Auflösung, ohne Einfluss auf die Anklage).
  7. `einfluss.wieder` steht im Zwischenresümee, wenn verzögerte Fakten (Umweg, Mauert) sichtbar werden.
  8. **R15-Prüfung der Einfluss-Texte:** gesperrt sind Fallgegenstände, Suchstellen, Indizorte, Lacher und Sperrorte –
     **nicht** Figurennamen (auch nicht Herr Schneider, R23) und nicht die Spielbegriffe „Spuk“, „Schlossgeist“, „Spur“,
     „Geheimnis“. R15 gilt für `einfluss.geruecht.*`, `einfluss.ereignis.*`, `einfluss.ablenken.*`, `einfluss.folgen.*`,
     `einfluss.leiste.*`, `einfluss.bot.*`; **nicht** für `einfluss.auspacken.*` (nennt seine Quelle, §3.6) und nicht für
     Texte nach dem Finale (`einfluss.epilog.*`, `einfluss.preis.*`, `einfluss.morgen.*`, `einfluss.tischbonus.*`).
  9. **Gleiche Gestalt der Kern-Geständnisse:** Die vier `einfluss.auspacken.<kern>` nennen keine Uhrzeit (Fatmas
     „zwanzig vor zwölf“ entfällt). `einfluss.ablenken.fatma` ohne Gelbtöne (gelbe Fasern sind ein Fallgegenstand).
  10. Bezug-Ungleichgewicht der Randfiguren-Geständnisse (Ahmet und Can je vier, Fatma zwei, Olli ein bis zwei) folgt
      aus den pfadgleichen Beobachtungen des Kanons und verrät keinen Pfad; bleibt so (in FUER-DEN-NUTZER notieren).
  11. Minuszeichen auf Karten: U+2212 nur, wenn die App-Schriften es enthalten; sonst ASCII „-“.
- 2026-10-27 (Entscheidungen zu den Abweichungen der Kern- und Inhalts-Agenten):
  12. **Fünf-Wort-Ausnahmen:** `pruefeErzaehlerakte` prüft die aus dem Kanon gezogenen Felder (Name, Alltag, Motiv,
      Geheimnis, Nebendelikt, Loyalitätsgrund, Ziele) nicht auf Fünf-Wort-Folgen – sie gelten in allen Pfaden, stehen
      aber wörtlich in Auflösung und Finale. `pruefeEinstimmung` nimmt öffentliche Kanontexte (`figuren.alltag`,
      `dossier.wer`) von der Regel gegen Geheimfelder und Pfadwissen aus; gegen Intro, Vorspiel und Zeitleiste ab 18:00
      gilt sie ohne Ausnahme. Das Feld `hinweis` ist von der Wortsperre der Erzählerakte ausgenommen.
  13. **Übernommene Annahmen aus N1:** `vorstellung.start` nennt nur immer besetzte Figuren; `vorstellung.npc` und
      `vorstellung.detektiv.*` nennen keine Figur; Herr Schneider ist überall erlaubt; die Wortsperre Geld, Miete,
      Gefallen, Streich, Münzen, Schatulle, Türschaden, Steckdose gilt nur in der Vorgeschichte; `stimme` bei Schneider
      und Detektiv 2–3 Punkte; das Netz hat 35–60 Kanten; kein „Geburtstag“.
  14. **Strenger:** Die Vorstellungen der vier Kernfiguren nennen keine andere Kernfigur (Prüfer erzwingt es).
      Genitive von Figurennamen („Fatmas“) sind keine Kennwörter. „Mantel“ bleibt Kennwort (Detektiv: „Trenchcoat“).
  15. **R15** vergleicht ganze Wörter (kein Teilwort-Treffer wie „Tisch“ in „Buffettisch“); Figurennamen und die
      Spielbegriffe aus Punkt 8 sind frei.
  16. **Erzählerakte:** eine neutrale Detektiv-Fassung (keine m/w-Trennung); je Figurenpaar eine Kante, der heimliche
      Teil einer Loyalität steht im Loyalitätsfeld. `f_foto_streit` gilt in allen Pfaden (Johanna liefert Fakt und Notiz).
  17. **Bots:** Auslegungen aus E1a gelten (Restgewicht von aylin/dilara als Auspack-Gewicht; Override-Reihenfolge
      Freund beredet, mehrere tuscheln, Geheimnis bekannt, nach Ertappt; Ersatz = helfen).
  18. **Abstimmung der Zahlen** vor dem Einspielen der Inhalte (Zielbänder: jedes Ziel am Bot-Tisch 20–85 %,
      Nachfragen im Schnitt 0,5–1,5, Tischbonus +1 bei n ≤ 12 in ≥ 5 %, Meister-Quote je Pfad ±15 pp). Der Golden
      `einfluss_soll.g.dart` war nie auf `main` und wird nach der Abstimmung einmalig neu erzeugt (E-048).
  19. **Schnappschuss:** Der Schlüssel `schlosskeller` in `andere_akten_soll.g.dart` darf nur nach bewusst geänderten
      Schlosskeller-Inhalten neu erzeugt werden (mit Begründung im Prüfjournal); die vier anderen Akten nie.
- 2026-10-27 (Abstimmung am Bot-Tisch, `finale/abstimmung` db86db2, E-048) – ersetzt die Startwerte:
  20. §3.5 Nachfragen: je volle **25** Restminuten eine Nachfrage (höchstens 2). §3.7 Übertrag **min(5, Rest)**; kein
      Verfall außer über 5 hinaus. §3.8 Zusammenhalt-Zuwachs: **+2 wenn 5K ≥ 2·n_eff, +1 wenn 5K ≥ n_eff**.
  21. §3.9 Ziele geändert: tim Stern II „Lenk an diesem Abend nie ab“ (statt nie ertappt – war unverfehlbar);
      serkan Stern II „Lass am Ende mindestens vierzig Nachtminuten übrig“; enes Stern II und tugba Stern II
      „Bring den Zusammenhalt auf mindestens fünf“; hakan Stern II „Halte den Spuk bei höchstens zwei“.
  22. §3.11 Bots: emine 25/50 fatma/0/0/15 + 10 auspacken; johanna 25/20 ahmet/0/0/45 ahmet + 10; kaan 25/50 olli/0/0/15
      + 10; hakan 70/0/0/0/20 + 10; meryem auspacken in Runde 1 mit 50 %, sonst 55/0/15/0/15 + 15; aylin 45/0/15 ahmet/0/40
      ahmet, auspacken in Runde 3 mit 30 %; selin 45/20 ich/0/10/25; tugba 70/0/15/15/0; tim zeigt fest auf enes; dilara
      deckt fatma.
  23. Ergebnis (1.000 Salze): alle 40 Sterne 23–82 %; Nachfragen Ø 1,1–1,3; Tischbonus −1/0/+1 bei n = 4: 18/61/22,
      n = 7: 19/51/30, n = 12: 30/41/29, n = 20: 3/12/86 (hilfsbereite Besetzung ab Rolle 13 – am echten Tisch prüfen);
      Meister je Pfad (zufälliger Detektiv) gleich, Spanne höchstens 13 pp; bestes Spiel immer Meister.
  24. Noch offen aus der Zusammenführung: Punkt 7 (`einfluss.wieder` im Zwischenresümee statt als letzter Folgen-Baustein)
      ist nicht umgesetzt. Er wird beim Einspielen der Inhalte umgesetzt; `einfluss_soll.g.dart` darf bis zur ersten
      Zusammenführung nach `main` neu erzeugt werden (E-048).
- 2026-10-27 (Stufe 3, Inhalte eingespielt):
  25. **Kapiteltitel der Vorstellung:** `ui.einstimmung.titel.vorstellung` („Wer heute mitfeiert“) gilt für alle Schritte
      der Vorstellungsrunde (`Einstimmung.vorstellungTitel`; `EinstimmungSchritt.titel` ist nie mehr `null`;
      `Einstimmung.titel()` hängt ihn mit Vorstellung an). `pruefeEinstimmung` prüft ihn wie die Teiltitel und meldet einen
      Teil der Vorgeschichte mit der ID `vorstellung`.
  26. **Punkt 7/24 umgesetzt:** `SpielZusatz.nachgereichtIn(runde)` (pfadfrei, hängt nur an Umweg oder „mauert“, nie daran,
      ob der Fund im Pfad Fakten trägt); `Erzaehler.resuemee` setzt `einfluss.wieder` dann an den Anfang des
      Zwischenresümees; `einflussFolgen` endet mit den Ereignissen. `einfluss_soll.g.dart` wurde nach E-048 neu erzeugt;
      mit zurückgenommener Änderung passt die alte Liste weiterhin (einzige Ursache geprüft).
  27. **Netz 50 Kanten:** die fünf heimlichen Bezüge zu Herrn Schneider aus dem Querabgleich sind Kanten (Lejla Genehmigung
      fürs Essen `streit`, Joanna Streitfoto `arbeit`, Aylin Quittung `schuld`, Wojtek Möbelwachs `schuld`, Azra Vitrine
      `streit`); Quellen sind Motiv, Geheimnis und Nebendelikt, in allen Pfaden gleich.
  28. **Lauschen:** `einfluss.privat.gelauscht` „Gelauscht: @figur spielt @zug auf @ziel“, `.ohne_ziel` ohne „auf @ziel“,
      `.abgewartet` „Gelauscht: @figur hat diese Runde abgewartet“.
- 2026-10-27 (Behebung der Befunde aus der Prüfung nach der App-Zusammenführung):
  29. §3.8 Fledermaus: nur negatives T doppelt (Deckel −2); kein Zusatz-Randnotiz-Bonus, weil jeder Vorrat eine ID hat
      (§3.5 Vorschlag). Ein Zusatzfund ist immer eine Randnotiz; Texte `einfluss.ereignis.fledermaus` und `.karte`
      angepasst.
  30. §2 Erzählerakte folgt dem Abend: Die App zeigt die Sterne von „Dein Moment“ nur an Abenden mit der Schicht
      (`PartyDaten.erzaehlerakteFuer(einfluss:)`; reihum, Pult, Gastgeber nach `PartySitzung.einfluss`, Gäste nach
      `einfluss` in der Ansicht, das Erzähler-Handy reihum nach privat `deinMoment`), sonst `persoenlichesZiel` wie
      Rollenkarte und Dossier. Der Druck (`--paket`, `--erzaehlerakte`) nennt standardmäßig `persoenlichesZiel`
      (Druckspiel ohne Schicht, §3.1); `--dein-moment` setzt die Sterne (nur mit Fähigkeit `einfluss`).
  31. §3.12 Erzähler-Handy reihum: Mit der Schicht schickt der Begleiter-Raum nur diesem Handy privat `einflussTafel`
      (dieselbe Tafel wie am offenen Pult). Das Pult schließt, sobald das Gerät an eine Person geht (verdeckte Ansicht,
      Zwischenstufe des Moments, „Zur Ermittlung“ nach den Folgen).
  32. §3.11 „Eigenes Geheimnis bekannt“: Das Geheimnis einer Figur machen der Auspack-Fakt und jeder Nebendelikt-Fakt
      der Figur öffentlich (`EinflussRegeln.geheimFakten`, statisch aus dem Kanon): Ahmet f_nd_ahmet_umschlag und
      f_nd_ahmet_quittung, Can f_nd_can_maske und f_nd_can_zeynep. `einfluss_soll.g.dart` bleibt gleich.
  33. §3.8/§3.13 Zwischenresümee mit Schicht: Das erste Geflüster des Abends nimmt `resuemee.gruppe.1`, auch in Runde 2
      oder 3 (die Sätze der Runden 2 und 3 setzen ein früheres Geflüster voraus). Ohne Schicht unverändert (T-N).
      `einfluss_soll.g.dart` nach E-048 neu erzeugt (vor der ersten Zusammenführung nach `main`); einzige Ursache
      gegengeprüft: mit zurückgenommener Änderung passt die alte Liste.
  34. §3.10 Auflösung mit Schicht: `aufloesung.gruppe.N` zählt die Runden mit Zusammenhalt-Zuwachs ≥ 1 (Flüstern wahr
      oder neutral; angesagt als „Der Zusammenhalt wächst“), nicht nur die wahren. Damit nie „in keiner der drei Runden“
      bei einer Leiste über 0 und `einfluss.tischbonus.plus` nur mit N ≥ 2. Ohne Schicht unverändert (T-N).
      `einfluss_soll.g.dart` nach E-048 neu erzeugt, einzige Ursache gegengeprüft.
  35. §3.10 Spürnasen: Tipp richtig, die Täterrolle zählt nicht (sie kennt ihre Tat; keine +2 in der Wertung für den
      Stern, keine Erfahrung als Spürnase). Wirkt erst nach dem Finale, R13 und „pfadblind“ bleiben; die Tipp-Karte ist
      für alle gleich. `einfluss.preis.stern` ohne Herrn Schneiders Beifall (der Stern kann an den unentdeckten Täter
      gehen). `einfluss_soll.g.dart` nach E-048 neu erzeugt, einzige Ursache gegengeprüft.
  36. Zu Punkt 11 geprüft (fc-query über `assets/fonts`): Alle neun Schriften der App führen U+2212 (Caveat, Courier
      Prime, Inter Regular/SemiBold/Bold, Lora, Lora Kursiv, Playfair Display, Special Elite). Die Karten nutzen das
      echte Minuszeichen, auch die Zeile „Tisch“ der Chancenvorschau am Gerät und beim Gast.
- 2026-10-27 (Entscheidungen der App-Zusammenführungen, Stufe 4; nachgetragen mit der Doku):
  37. **„Wer macht was“ mit Schicht ohne Gruppenwahl:** `uebersichtPhasen(einfluss: true)` blendet den Abschnitt
      Gruppenwahl aus (`entscheidungen → bonus`, §3.1); Bonus und Resümee heißen weiter „Hinweis und Resümee“. Mit
      Schicht: Rolle „Gespräch führen, geheim deinen Moment ziehen“, Detektiv „Tischwerte lesen, nach Pech gemeinsam
      rufen“, Erzähler „Zu Beginn der Ermittlung die Folgen vorlesen“. A-E hatte die Gruppenwahl dort noch gezeigt.
  38. **Kein zweiter Bildschirm-Hinweis „Wer genannt wird, steht kurz auf.“** (abweichend von §1 App): Der Satz steht
      schon im Vorlesetext `vorstellung.start`; die App zeigt ihn nicht zusätzlich (`einstimmung_test` prüft, dass er
      fehlt). Im Druck bleibt er in den nicht vorgelesenen Hinweisen `ui.druck.spielleitung.vorstellung.hinweis` und
      `ui.druck.paket.ablauf.vorstellung.text`.
  39. **Erzählerakte folgt dem Abend:** Nach der Zusammenführung zeigte die Akte die Sterne, sobald die Akte die
      Fähigkeit `einfluss` hat, auch bei ausgeschaltetem Schalter und im Druck. Entschieden wie Punkt 30: Sterne nur an
      Abenden mit Schicht, sonst `persoenlichesZiel`; der Druck nur mit `--dein-moment`.
  40. **Abzeichen nicht an den Karten-Hotspots:** Der Tischwert steht in der Optionsliste („Aus einer Liste wählen“),
      in der Rückfrage „Das ist endgültig“, in der Chancenzeile „Tisch“ und auf dem Gerät des Gastes. Die Hotspots der
      Karte tragen keine Marke. Damit gilt §3.3 („Abzeichen an jeder Option vor der Wahl“) als erfüllt.
  41. **Minuszeichen:** A-E setzte Tischbonus und Zeile „Tisch“ zunächst mit ASCII „-“, weil Punkt 11 noch ungeprüft
      war. Seit Punkt 36 gilt überall U+2212: Abzeichen-Texte der Akte, Tischbonus, Zeile „Tisch“ am Gerät und beim
      Gast.
  42. **`abendstand/3`:** ein Format für alle Abende; gelesen werden `/1`, `/2` und `/3` (`/1` mit Befragungsmodell
      bleibt abgelehnt). Journal und Raum-Meta tragen `einstimmung: true` und `einfluss: true` nur, wenn an; Stände
      ohne Eintrag laufen ohne Einstimmung bzw. ohne Schicht. Die Befehle `moment` und `nachfrage` stehen im Journal.
      Ob die Folgen einer Runde gelesen sind, merkt sich nur das Gerät (nicht im Journal): Nach dem Fortsetzen liegt
      das Folgen-Blatt der laufenden Runde wieder offen.
  43. Kleinere Festlegungen: Reihum bleibt das offene Pult über alle Schritte der Einstimmung offen. Weiter und
      Überspringen der Einstimmung drückt nur, wer leitet (Gastgeber ohne Leitung: gesperrt mit Fußzeile; Gastgeräte
      ohne Knöpfe). Das Erzähler-Handy reihum bekommt `rollen` nur während der Einstimmung; danach nimmt die
      Erzählerakte die Rollen aus der Spielerliste. `tool/e2e/solo.mjs` folgt den Vorgaben des Assistenten (beide
      Schalter an). Erfahrung aus „Dein Moment“ bucht nur ein Gast mit Figur am eigenen Gerät; an einem Gerät zählt
      das Ende des Detektivs nach dem Endwert (§3.10).
- 2026-10-28 (Politur nach der Fotosichtung der Browserprobe des Finales):
  44. §3.10/§3.13 **Spürnasen in einem Baustein:** Statt einer Karte „Eine Spürnase der Nacht ist …“ je Rolle steht in
      der Auflösung ein Baustein. Eine Spürnase: `einfluss.preis.spuernase@<figur>` wie bisher. Mehrere: neuer Schlüssel
      `einfluss.preis.spuernasen` mit den Platzhaltern `@liste` (alle Namen bis auf den letzten, durch Komma getrennt)
      und `@letzte`; das „und“ steht im Text („Spürnasen der Nacht sind @liste und @letzte. …“). Baustein
      `einfluss.preis.spuernasen@<figur>,<figur>,…` (`einflussListenBaustein`, mindestens zwei Figuren), aufgelöst in
      `Texte.baustein`/`einflussText(figuren:)`; Gerät, Gast und Raum zeigen dieselbe Tafel, der Druck kennt die
      Schicht nicht. Einfluss-Katalog 293 Schlüssel (Vorlesetexte 112). `einfluss_soll.g.dart` nach E-048 neu erzeugt:
      686 der 1.000 Summen ändern sich, genau die Abende mit mehr als einer Spürnase (nachgezählt); einzige Ursache
      gegengeprüft: mit der zurückgenommenen Zeile in `Erzaehler.einflussAufloesung` passt die vorige Liste.
  45. §3.5 **Randnotiz zu „Damir befragen“:** `e1_1_damir` zeigt `b_pawel_schneider` („Herr Schneider muss jeden Schaden
      der Stiftung melden. Darum ist er beim Geld so streng.“) statt `b_damir_an_der_theke`. Die alte Notiz wiederholte
      fast wörtlich, was Damir in Runde 1 erzählt (Befragung oder Erzähler bei unbesetztem Damir); Damirs übrige
      Beobachtungen gelten nicht in allen Pfaden. Pawels Wissen gilt in allen Pfaden, belastet und entlastet niemanden,
      steht in keiner Begründungskette und passt zu Damirs Ärger mit Herrn Schneider über das Teegeschirr; erzählt wird
      es sonst nur bei besetztem Pawel (ab 19 Rollen) oder wenn er auspackt. Geprüft gegen die Story-Bibel (§7
      Beobachtungen, Figur 19). `einfluss_soll.g.dart` nach E-048 neu erzeugt: 457 der 1.000 Summen ändern sich, alle
      an Abenden mit der Wahl `e1_1_damir`; Gegenprobe mit zurückgenommener Zeile in `einfluss.json`: vorige Liste passt.
  46. §3.10 **Protokoll der Nacht ohne Überlappung:** Name und Zug-Sinnbilder stehen oben auf einer Linie (jedes
      Sinnbild mittig auf der Höhe der ersten Namenszeile), das Zielfoto hängt darunter in derselben Zeile; Zeilen mit
      Foto halten 12 px Abstand nach unten (Schatten des Abzugs). Vorher stand das Sinnbild über dem Foto und ragte in
      die Zeile davor. Der Name bricht bei großer Schrift nicht mehr mitten im Wort (`MGanzeWorte`). Dabei gefunden:
      Bei 320 px und 200 % Schrift lief der Leistenname „Zusammenhalt“ 15 px über den Rand; er wird jetzt kleiner
      (`LeistenAnzeige`, auch im Resümee und beim Gast). Beweis: `test/party_widgets/protokoll_nacht_test.dart`
      (320/390 px × 100/200 %, Rechtecke der Zeilen, Sinnbilder, Fotos und Schattenabstand).
  47. §3.5 **Randnotizen aller Befragungen bringen Neues** (Besitzer „Ja, angleichen“, wie Punkt 45): Keine Befragung
      zeigt mehr, was die befragte Figur ohnehin erzählt (Pflichtgespräch in `befragungen-r1..3`, Erzähler bei
      unbesetzter Figur) oder was die Option selbst aufdeckt. Neu: `e1_1_joanna` `b_pawel_schneider` statt
      `b_joanna_foto` (wortgleich mit dem Fund `f_foto_streit`); `e1_2_emine` und `e1_2_tugba` `b_serkan_tor` statt
      `b_emine_versteck` bzw. `b_tugba_notiz`; `e1_3_tim` und `e1_3_azra` `b_tugba_notiz` statt `b_tim_gesicht` bzw.
      `b_azra_versteck`; `e3_3_zeynep` und `e3_3_aylin` `b_tim_gesicht` statt `b_zeynep_vorrat` (Quelle des Funds
      `f_nd_can_zeynep`) bzw. `b_aylin_quittung`. Passung: Herrn Schneiders Strenge beim Geld zum Streitfoto (wie bei
      Damir); Serkan am verschlossenen Außentor (wo jemand im Dunkeln war, niemand kam hinaus; zu Tugbas Eintrag
      „Serkan (Auto)“); Tugbas Liste von 23:57 (wo alle kurz vor dem Knall angeblich waren, darunter „Emine und Azra
      (Buffet)“ und „Damir und Tim (Kaffee)“); Tims leuchtendes Gesicht zu Cans Maske, bei Aylin der andere Faden der
      letzten Frage. Alle vier gelten in allen Pfaden und entlasten niemanden; nur Tims Sichtung belastet Can wie jede
      Sichtung des Gesichts, ohne Bezug zum Scheppern (in allen vier Pfaden der neutrale Bonus der Runde 1). Keine steht
      in einer Begründungskette, keine liest der Erzähler; Pawel ist erst ab 19, Tugba nur bei 20, Serkan ab 13 Rollen
      besetzt. Pawel, Serkan und Tugba liefern dieselbe Notiz beim Auspacken, aber als Pflichtgespräch-Wissen, nicht als
      Geheimnis: Kein Geständnis wird vorweggenommen; die Auspack-Notizen der befragten Figuren bleiben unberührt.
      Doppelte nur innerhalb einer Entscheidung, deren Optionen nie beide gewählt werden: Keine Befragungs-Notiz gehört
      zu einer anderen Entscheidung, sonst ginge „Redselig“ leer aus, wenn eine frühere Wahl sie schon zeigte (am
      Bot-Tisch hätte `b_pawel_schneider` bei `e3_3_aylin` in 55 von 506 Wahlen nichts gebracht, weil `e1_1` sie oft
      schon zeigt; packt die Figur der Notiz vorher aus, bleibt „Redselig“ wie seit Punkt 45 bei Damir ohne Notiz).
      Geprüft gegen die Story-Bibel (§4 Figuren, §7 Beobachtungen, §8 Tatmatrix je Pfad, §9 Ketten, §10
      Bonus). Such-Optionen: Keine zeigt eine Notiz der durchsuchten Figur; Zeugen aus dem Bezug (Hana am Ascheneimer
      und Kamin, Sibel an der Vitrine, Wojtek bei Olli, Baran im Ost-Saal) bleiben, dort wird niemand befragt. Test
      `einfluss_suche_test` für alle acht Befragungen: Notiz nicht von der befragten Figur, nicht aus ihrem Gespräch,
      ihrem Erzählerwissen oder den Fakten der Option, `pfade: alle`, in keiner Kette, in keiner anderen Entscheidung.
      `einfluss_soll.g.dart` nach E-048 zum letzten Mal vor der Zusammenführung nach `main` neu erzeugt: 695 der 1.000
      Summen ändern sich, genau die Abende, an denen eine der sieben Optionen eine Randnotiz zeigte (redselig oder
      Nachfrage, mit alten oder neuen Daten; nachgezählt); Gegenprobe mit zurückgenommenem `einfluss.json`: vorige
      Liste passt (0 Abweichungen).
- 2026-10-30 (Nachtrag PDFs: Erzählerakte in App und Release, Druckmappe leichter finden; Besitzer: alle drei Punkte,
  Plan `delegated-wandering-meteor`, Branches `pdf/a` Kern und Release, `pdf/b` App):
  48. §2 **Erzählerakte als PDF in der Druckmappe:** `DruckTafel(erzaehlerakte: true)` nur in der `DruckmappeSeite`.
      Im Druckspiel steht unter „Rollenhefte einzeln senden“ ein eigener Abschnitt mit dem Kopf
      `ui.druck.paket.dateien.ordner4` („Nur Erzähler“), dem Hinweis `druck_erzaehlerakte_hinweis` (ARB) und dem Knopf
      `ui.druck.akte.titel` → `erzaehlerakte.pdf`. Die Akte kommt nur über `erzaehlerakteFuer(einfluss: false)`, also mit
      den Zielen des Kanons wie Druckspiel und Kommandozeile ohne `--dein-moment`, nie über `daten.erzaehlerakte`
      (Sternfassung). Personenzahl der Einstellung; kein Satz, kein Fall-Code, in allen Pfaden dieselben Bytes. Der
      Kontext entsteht erst beim Tipp und nach einem Fehler neu. Nie in der Rollenvergabe (`rollen.dart`, die neutrale
      Ansicht für den ganzen Tisch), nie ohne Druckspiel, solo oder in Akten ohne Erzählerakte. Icon wie der Zugang am
      Abend (`folder_shared_outlined`).
  49. §2 **„Als PDF“ in der Erzählerakte des Abends:** Der Knopf steht im Fuß der offenen `ErzaehlerakteSeite` neben
      „Schließen“, nicht als eigener Streifen (ein fester Streifen hätte die Figurenliste am Handy dauerhaft
      verkürzt). Nicht im Eintrag, nicht in der Zwischenstufe, nicht am Pult, nie solo. Die Datei hat die angezeigte
      Fassung (`erzaehlerakteFuer(einfluss: widget.einfluss)`, mit Schicht die Sterne) und die Personenzahl des Abends,
      ohne Fall-Code. Den Knopf gibt es nur mit einer Personenzahl der Besetzung; gilt die Akte nicht mehr
      (`erlaubt()` falsch), entsteht keine Datei. Reihum und am Pult die Zahl der Einstellung, online die Rollenzahl
      des Raums. Am Erzähler-Handy reihum schickt der Begleiter `rollen` nur während der Einstimmung (Punkt 43); sonst
      gilt die Zahl der gespielten Figuren, wenn sie genau die Besetzung dieser Zahl sind (beim Zusammenführen
      ergänzt, a7d1272; vorher fehlte der Knopf dort nach der Einstimmung). `DateiKnopf` hat dafür den optionalen
      Dateinamen `datei` („Herunterladen: Erzählerakte“ statt „Herunterladen: Als PDF“) und schreibt Ladehinweis und
      Fehler auf dunklem Grund in Papierfarbe; auf Papier unverändert.
  50. §2 **Neutrale Fassung für das Release:** `ErzaehlerakteKontext.rollen` ist `required int?`; `null` setzt die Akte
      ohne Besetzung: alle 20 Figuren in Besetzungsreihenfolge, keine Marken „Heute gespielt“/„Ohne Spieler“, im Netz
      keine blassen Knoten, Etiketten oder Kanten und kein „Ohne Spieler“ in den Legenden, keine Personenzeile auf dem
      Deckblatt. Die neutrale Fassung
      muss ausdrücklich mit `rollen: null` angefordert werden; `PaketKontext` bleibt bei `int`. Kommandozeile
      `--erzaehlerakte --ohne-besetzung` (Ausgabe `build/druck/<fall>-erzaehlerakte-alle`); mit `--personen` oder
      `--n` und, zusätzlich zum Plan, ohne `--erzaehlerakte` (sonst entstünde stillschweigend ein Paket für 12) Exit 2.
      Die Porträtprüfung umfasst dann alle 20 Figuren und `detektiv-w`/`detektiv-m`; fehlende Porträts bleiben eine
      Warnung mit Exit 0 („Achtung: Porträts fehlen (…) in …“). Die Akte hat 24 statt der geplanten 23 Seiten, weil
      Netz und Legende zwei Seiten brauchen (wie schon bei `--personen 8`); der Test zählt Deckblatt, Personen und
      Netz aus der Bezugsakte für 12 Personen, die CI-Untergrenze bleibt 23. Bytes für `--personen N`, `--dein-moment`
      und `--paket` unverändert (40 von 40 Dateien vor und nach der Änderung gleich). **Kein neuer Text:** Das
      Deckblatt sagt weiter `ui.druck.akte.inhalt` („… erst die gespielten, dann die ohne Spieler“). Das stimmt für jede
      Personenzahl, weil `Besetzung.besetzt(n)` der Anfang der Besetzungsreihenfolge ist. Ein Satz wie „Bei N
      Personen spielen die Figuren 1 bis N“ hätte einen neuen Baustein in `ui-druck-paket.json` und `kanon_tor`
      gebraucht; die Doku (Druckspiel-Anleitung) sagt es stattdessen.
  51. **Release-Job `erzaehlerakte`, optional:** `needs: gate`, nicht bei `schedule`, 20 min. Porträts mit
      `flutter test tool/bild/druck_portraets_test.dart` (mindestens 22 PNG), dann zweimal
      `party_druck.dart --erzaehlerakte --ohne-besetzung`, einmal mit `--dein-moment` in eigenem `--aus`-Ordner,
      umbenannt zu `erzaehlerakte-dein-moment.pdf`. Abbruch bei „Achtung: Porträts fehlen“, unter 23 Seiten
      (`pdfinfo`) oder gleichen Dateien. Artefakt `erzaehlerakte` (`if-no-files-found: error`). Der Release-Job lädt es
      mit `continue-on-error` wie IPA und Web-ZIP; ein PDF-Fehler hält die APK nie auf. Vorhandene PDFs kommen in
      `SHA256SUMS.txt`, die Assets und je eine Notizzeile („Nur für die Person, die erzählt; nennt nie den Täter; für
      jede Personenzahl“), sonst eine Ersatzzeile; dazu der Installationspunkt „PDFs zum Ausdrucken … Detektei → PDFs
      zum Ausdrucken“. Kein `--code`, `--paket`, `--pfad`, `--personen` oder `--n` im Job. Geprüft von
      `tool/ci/tests/test_release_workflow.py` (14 Tests, nur Standardbibliothek; gleicht den Warntext mit
      `party_druck.dart` ab).
  52. **„PDFs zum Ausdrucken“ als einheitlicher Name** (`detektei_druck_pdfs`): auf der Akte-Seite statt „Druckmappe“
      (`ganzeWorte`; der Seitentitel „Druckmappe“ und `detektei_akte_druckmappe` bleiben), als zweiter Weg unter jeder
      druckbaren Mappe der Startseite (`AkteKarte.unten`, außerhalb von `excludeSemantics`, ab zwei Spalten in der
      Spalte der Mappe; der Name enthält keinen Akten-Titel, weil `tool/e2e/start.mjs` „Spuk im Schlosskeller“ genau
      einmal erwartet), im Assistenten bei „Zum Drucken“ als Hinweis `abend_druck_nur_pdfs` (nur Text, kein Sprung, die
      Einstellungen bleiben) und in den Release-Notizen. `detektei_druck_hinweis` nennt die Erzählerakte.
  53. **Porträts in der App:** `lib/party/druck_portraets.dart` zeichnet die Porträts der Druckfassung
      (`druckPortraets`, 20 Figuren plus `detektiv-w`/`detektiv-m`, ohne das Opfer, `Future.delayed(Duration.zero)`
      zwischen den Bildern) mit 360 px statt 720 px. Kein Zwischenspeicher: `DruckTafel` hält den Kontext, `DateiKnopf`
      die fertige Datei. Scheitern die Porträts (etwa die PNG-Kodierung im Browser), entsteht die Akte ohne Bilder.
      Teststelle `druckPortraetsUeber`. `tool/bild/druck_portraets_test.dart` nutzt dieselbe Funktion mit 720 px; die
      22 PNG sind bytegleich zu vorher. Offen: Browserprobe (Ladezeit, Ziel unter 20 s, sonst 240 px).
  54. Testanpassungen aus der App-Hälfte: Tests, die zur Druckmappe navigieren, leeren vorher `rootBundle` und laden
      `PartyDaten` in `runAsync` vor (Ladevorgänge aus beendeten Testzonen früherer Tests ließen die Druckmappe bei
      „Die Akte wird vorbereitet …“ stehen). Im Rollenphasen-Test der Erzählerakte sind die Scrollschritte 120 statt
      300 px, weil der Fuß mit zwei Knöpfen in der Testschrift zweizeilig wird; der Inhalt der Prüfungen ist gleich.
  55. §2 **Deckblatt der neutralen Erzählerakte** (Befund der Release-Probe, ersetzt „Kein neuer Text“ aus Punkt 50):
      Ohne Besetzung sagt das Deckblatt `ui.druck.akte.inhalt_alle` („… und jede Figur mit ihrer Nummer in der
      Besetzung. Bei acht Personen (ohne den Detektiv) spielen die Figuren 1 bis 8, die übrigen bleiben ohne
      Spieler.“) statt „erst die gespielten, dann die ohne Spieler“, denn ohne Marken sah man die Grenze nirgends. Nur
      der neutrale Zweig liest den Baustein; Akten mit Personenzahl und `--paket` bleiben bytegleich. Neuer Baustein
      in `ui-druck-paket.json` (nicht in `tool/kanon_fest.txt`), `kanon_tor` neu erzeugt (Prüfsummen, Inhaltskennung
      des Schlosskellers in `akten.json`).
  56. **Release-Job, Feinschliff aus Probe und Prüfung:** Untergrenze 24 statt 23 Seiten (Deckblatt, Personen, Netz mit
      Legende auf zwei Seiten, 20 Figuren; eine verlorene Figurenseite fällt jetzt auch im Job auf, nicht nur im gate).
      `test_release_workflow.py` verlangt zusätzlich `2>&1 | tee` in beiden Aufrufen (sonst erreicht die Porträtwarnung
      von stderr das Log nicht), die genaue grep-Zeile über beide Logs und die beiden `cp`-Zeilen (Druckspiel nach
      `erzaehlerakte.pdf`, „Dein Moment“ nach `erzaehlerakte-dein-moment.pdf`); 15 Tests. Mutationsprobe: 19 von 23
      erkannt (vorher 16). Die Meldung mit „Dein Moment“ steht in einfachen Anführungszeichen (shellcheck SC1111).
      Release-Notizen: der Satz „PDFs zum Ausdrucken … erstellt die App“ steht unter „Dateien“ statt unter
      „Installation“; der Statusverweis zeigt auf `planung/finale/STATUS.md`. **Bewusst ohne `continue-on-error`:** Ein
      roter Job `erzaehlerakte` färbt den Lauf rot (Signal), das Release entsteht trotzdem ohne die PDFs und wird auf
      `main` an der Spitze „latest“; die latest-Logik bleibt unverändert. Kopfkommentar, README („Builds“, Hinweis auf
      die Release-Seite) und Anleitung §2 sagen das; nachholen mit „Re-run failed jobs“ (neues Release, neuer Tag).
  57. **Kommandozeile:** `--erzaehlerakte` mit `--code`, `--pfad` oder `--detektiv` bricht ab (Exit 2), statt die
      Angabe still zu übergehen; die Akte hängt nie vom Fall ab. Die Porträtprüfung umfasst auch mit `--personen`
      alle 20 Figuren und beide Detektive (die Figuren ohne Spieler haben eigene Seiten und Knoten im Netz). Nur
      Meldungen ändern sich, keine Bytes.
  58. **Porträts in der App 240 px** (ersetzt 360 px aus Punkt 53; Befund der Browserprobe): Die Erzählerakte brauchte
      im Web-Build bei 390 px im Mittel 20,7 s (2 von 10 Läufen unter 20 s). Ohne Ladekreis 8 bis 9 s, ohne Kreis und
      mit 240 px 5,2 bis 5,5 s, bei vierfach gedrosseltem Prozessor 19,9 s. Ein Porträt steht im PDF höchstens 86 pt
      breit; 240 px sind dort rund 200 dpi. `tool/bild` bleibt bei 720 px (Release, Kommandozeile). Vor dem Satz
      rechnet `vorab` (`lib/party/erzaehlerakte_druck.dart`) jedes Porträt groß und jede Figur klein in JPEG um, mit
      `Future.delayed(Duration.zero)` dazwischen; `FestPortraets` merkt sich die Bilder, die Datei bleibt bytegleich.
      Das Umrechnen liegt im Rückfall: Ist ein Bild unlesbar, entsteht die Akte ohne Porträts.
  59. **`DateiKnopf`:** Während die Datei entsteht, steht immer die ruhende Sanduhr (wie bisher nur bei „Bewegung
      reduzieren“), nie der Ladekreis: Er ließ die Seite bei jedem `await` neu zeichnen, im Browser teurer als die
      Datei selbst. Beschriftungen mit `ganzeWorte` (vorher brachen bei 320 px und doppelter Schrift Erzählerheft,
      Detektivbogen, Auflösungsheft und Erzählerakte mitten im Wort). Neu `kurz`: Im Fuß der Erzählerakte stehen im
      Browser nach dem Bauen nur „Herunterladen“ und „Teilen“ (`druck_datei_laden_kurz`, `druck_datei_teilen_kurz`),
      der Bildschirmleser hört „Herunterladen: Erzählerakte“; vorher lief der Fuß bei 320 × 640 und 320 × 568 mit
      doppelter Schrift um 9 bzw. 81 px über und die Figurenliste schrumpfte auf 0 px (ändert Punkt 49 für den Fuß).
      Die Druckmappe nennt den Dateinamen weiter.
  60. **Kleinere Korrekturen der App:** `DruckTafel` baut den Kontext der Erzählerakte neu, wenn sich die Personenzahl
      ändert (vorher nur der Knopf-Schlüssel; heute nicht erreichbar, aber latent). Der Rückfall am Erzähler-Handy
      (a7d1272) ist die reine Funktion `gastAkteBesetzung` mit Test für die Lücke. Texte:
      `druck_erzaehlerakte_hinweis` endet mit „Gib sie nur dieser Person.“ statt „Gib sie nicht weiter.“ (die
      Druckmappe füllt oft der Gastgeber für die erzählende Person), `abend_druck_nur_pdfs` setzt den Knopfnamen in
      „…“.
  61. **Bewusst nicht geändert** (Befunde der Gegenprüfung): Kanten durch das Etikett „Herr Schneider“ im Netz (schon
      vorher, änderte die Bytes aller Fassungen), Umbruch „Fall-/Code“ im Hinweis der Druckfassung (schon vorher),
      Lage von „PDFs zum Ausdrucken“ unter dem ersten Bildschirm der Detektei und der vierzeilige Fuß der Akte-Seite
      bei 320 px (Beobachtungen in FUER-DEN-NUTZER), „Als PDF“ reihum (der Plan sieht es vor; Anleitung §5.4 rät zum
      eigenen Gerät, Entscheidung des Besitzers in FUER-DEN-NUTZER), `--paket --n 17` bis `20` stürzt ab (vorbestehend,
      eigener Punkt in STATUS).
- 2026-10-30 (Nachtrag „leicht finden“, Proben und Prüfer: Browserprobe, Kotlin, Oberfläche, Verhalten; jeder Befund
  nachgestellt, die neuen Tests schlagen ohne die Behebung fehl):
  67. **Knopf oben ohne Sprung** (ändert 62): Solange `_akten` lädt, hält `Visibility(visible: false, maintainSize)`
      den Platz des oberen Knopfs (gesperrt, ohne Tipp und ohne Semantik). Vorher kam er im Web-Build 1,3 bis 3,7 s
      nach dem ersten Bild und schob Ausweis, „Dein erster Fall“ und „Neuer Abend“ um 56 bis 64 px (Schrift 2: 130 px)
      nach unten. Nur wenn der Katalog geladen ist und keine Akte `druckbar` ist (oder er nicht lädt), fällt der Platz
      weg. Test mit um 400 ms verzögertem `akten.json` (`start_test`).
  68. **„Zurück“ dorthin, woher man kam** (ändert 62): `Routes.druckmappeVon(id, ausDetektei: true)` hängt
      `?von=detektei` an; beide Knöpfe der Detektei (oben und unter der Mappe) setzen es. Dann führen „Zurück“ und die
      Zurück-Taste des Systems (`_zurueckNach`) in die Detektei, sonst wie bisher auf die Akte
      (`DruckmappeSeite.zurueck`). Vorher landete man auf einer Akte-Seite, die man nie geöffnet hatte.
  69. **Druckmappe am kleinen Handy** (ändert 63): Nach „Druckmappe vorbereiten“ rollt die Seite zur Druckfassung
      (`GlobalKey` auf `DruckTafel`, `Scrollable.ensureVisible` im nächsten Bild, 300 ms, ohne Bewegung bei „Bewegung
      reduzieren“). Bei 320 × 568 lag „Druckfassung“ vorher unter der Fußleiste und Schritt 3 zeigte auf nichts
      Sichtbares; jetzt liegt „Alles in einer Datei“ über der Fußleiste. Der Hinweis endet nach Schritt 3: Der Satz
      „Die Erzählerakte ist nur für die Person, die erzählt.“ stand schon im Block „Nur Erzähler“
      (`druck_erzaehlerakte_hinweis`) bei ihrem Knopf. „Druckmappe vorbereiten“ hat `ganzeWorte` (brach bei 320 px und
      doppelter Schrift als „Druckmapp|e“).
  70. **Ganze Wörter auf den Dateiknöpfen** (ändert 59): `MKnopf` mit `ganzeWorte` lässt das Symbol weg, wenn ein Wort
      selbst in der kleinsten Schrift (11) nicht daneben passt (`ganzeWortePassen` in `m_ganze_worte.dart`; das Symbol
      schmückt nur). `DateiKnopf` prüft nach dem Bauen mit `MKnopf.passtGanz`, ob „Herunterladen: …“ und „Teilen: …“
      überhaupt ganz passen; wenn nicht, steht der Dateiname als eigene Zeile darüber (`MGanzeWorte`, für den
      Bildschirmleser ausgeblendet) und auf den Knöpfen nur der Weg wie mit `kurz` (Semantik mit Dateinamen). Vorher
      brachen auf Android (neu dort, im Browser schon vorher) bei 320 px und doppelter Schrift „Herunterlade|n: …“ und
      „Chara|kterübersich|t“, bei 360 px oder Schrift 1,5 noch „Teilen: Charakterübersicht“; im Grundzustand
      „Detektivbogen“ und „Auflösungsheft“. Bleibt: der Knopf „Charakterübersicht“ (Messingschild) im Grundzustand
      bei 320 px und doppelter Schrift (vorbestehend, das Wort ist auch in Schrift 11 breiter als der Knopf).
  71. **Die Wege nennen die Datei:** `datei:` an „Senden an {name}“ (`druck_rollenheft_von` „Rollenheft {name}“) und an
      „Steckbrief senden“ (`steckbrief_von` „Steckbrief {figur}“, Name der Figur). Nach dem Bauen also „Herunterladen:
      Rollenheft Ayla“ und „Teilen: Steckbrief Fatma“ statt zweier Verben ohne Dateinamen; das betraf nun auch jede
      Person in der Android-App.
  72. **Kotlin** (ändert 64): Geschrieben wird mit `openOutputStream(ziel, "wt")` (kürzen), mit Rückfall auf „w“, wenn
      ein Anbieter „wt“ nicht kennt. Mit „w“ kürzt nicht jeder Anbieter; wer im Dialog eine vorhandene, längere PDF
      überschrieb (etwa die für 12 Personen mit einer kürzeren), behielt deren Rest, die Datei war für `pdfinfo`
      kaputt. Eine neue, vom Dialog leer angelegte Datei (Größe 0 vor dem Schreiben) wird nach einem Schreibfehler
      entfernt (`DocumentsContract.deleteDocument`); ebenso, wenn die Anfrage zu einer früheren Activity gehörte und
      die Datei noch leer ist. Eine vorhandene, zum Überschreiben gewählte bleibt. Jede Ausnahme beim Öffnen des
      Dialogs (nicht nur `ActivityNotFoundException`) setzt die Anfrage zurück und meldet `kein_dialog`; vorher blieb
      `offen` gesetzt und jeder weitere Tipp hieß „belegt“. Der Hinweis nach dem Speichern nennt den Namen, unter dem
      die Datei liegt (`OpenableColumns.DISPLAY_NAME`, etwa „erzaehlerakte (1).pdf“ oder umbenannt): Das Kotlin setzt
      ihn im Satz aus der ARB an die Stelle des vorgeschlagenen Namens, hat also weiter keinen eigenen Text.
      Kompiliert mit Warnungen als Fehler, auf einem Gerät nicht ausprobiert.
  73. **`DateiGeraet.herunterladenMitDialog`** (ändert 65): Der Standardweg liest es über das Gerät, nicht mehr am Gerät
      vorbei aus der Umsetzung. Ein nachgebildeter Browser lädt so auch neben der Android-Weiche herunter; die Fakes in
      den Tests setzen es selbst (die Android-Attrappe in `druck_tafel_test` braucht `standardWeg` nicht mehr).
  74. **Tests und Kommentare:** Vertrag mit `MainActivity.kt` aus dem Quelltext (Kanal, Methode, alle Schlüssel, „wt“;
      Vorbild `langer_abend_test`), Abbruch im Speichern-Dialog am `DateiKnopf` (keine Fehlerzeile), die Steckbrief-Seite
      in der Android-App (zwei Wege, Kanal, Teilen, Abbruch, Schreibfehler), Druckmappe und Steckbriefe in der
      Android-App bei 320 px und doppelter Schrift ohne geteiltes Wort (`ganze_worte_test`). Die Kommentare in
      `druck_tafel.dart` und `erzaehlerakte_ansicht.dart` nennen den zweiten Tipp auch für die Android-App.
      **Bewusst nicht geändert:** Der obere Knopf kostet 64 px (Schrift 1,3 bei 320 px: 82 px); auf üblichen Handys
      rutschen damit „Sofort ermitteln“ oder „Neuer Abend“ aus dem ersten Bildschirm (etwa Android 360 × 640 bei
      Schrift 1, iPhone 390 × 844 bei Schrift 1,15). Das ist der Preis der Entscheidung „ganz oben“ (Punkt 62); die
      Frage steht in FUER-DEN-NUTZER. Die Schritte im Hinweis stehen weiter in einem Absatz mit `\n`, ohne hängenden
      Einzug.
- 2026-10-30 (Nachtrag „leicht finden“: Knopf oben, „Herunterladen“ in der Android-App; Besitzer: „Mach es so, dass
  man leicht draufkommt“, „Ja, Speichern dazu“, jeder spielt am eigenen Handy, Geräte Android-App, iPhone und Browser;
  Plan `delegated-wandering-meteor`, Branches `leicht/a` Android, `leicht/b` Detektei):
  62. **„PDFs zum Ausdrucken“ ganz oben in der Detektei** (ergänzt Punkt 52, erledigt die Lage aus Punkt 61):
      `DetekteiSeite` zeigt direkt unter der Zeile Wortmarke/Tonschalter, mittig und vor dem Dienstausweis,
      `MKnopf(detektei_druck_pdfs, zweit, Icons.print_rounded, ganzeWorte)` → `Routes.druckmappeVon` der ersten Akte
      mit `druckbar`. Er kommt aus demselben `_akten`-Future wie die Mappen (kein zweites Laden) und fehlt ohne
      druckbare Akte. Lage ohne Rollen bei 320 × 568 und 390 × 844, Schrift 1 und 2, mit „Dein erster Fall“ und
      Rückkehrkarten: oben y 92 bis 117, unten höchstens 231, immer über dem Ausweis. Der Knopf unter der Mappe und
      auf der Akte-Seite bleibt; der Text steht auf der Detektei also zweimal (`start_test` und `druck.mjs` zählen 2,
      `start.mjs` weiter genau einen Knopf „Spuk im Schlosskeller“). „Zurück“ in der Druckmappe führt wie bisher zur
      Akte-Seite. Release-Notiz „Detektei → PDFs zum Ausdrucken (ganz oben).“, `test_release_workflow.py` mitgezogen.
  63. **Hinweis der Druckmappe in Schritten:** `detektei_druck_hinweis` ist „So geht’s:“ mit drei nummerierten
      Schritten (… „3. Datei antippen, kurz warten, dann speichern oder teilen.“) und nach einer Leerzeile „Die
      Erzählerakte ist nur für die Person, die erzählt.“ Erster ARB-Text mit `\n`; `GanzeWorte` zeigt die Umbrüche.
      „speichern oder teilen“ statt der Knopfnamen, weil das iPhone gleich das Teilen-Menü öffnet; „Datei“ ohne
      „Eine“, weil der Textprüfer vor einer Ziffer keinen Satz trennt (24 Wörter, Grenze 25). `abend_druck_nur_pdfs`
      („bei der Akte“) bleibt; die Anleitung nennt den Knopf oben dazu.
  64. **„Herunterladen“ in der Android-App** (Storage Access Framework): `MainActivity.kt` richtet
      `MethodChannel("mordakte/datei")` mit `speichern` (`name`, `typ`, `bytes`, `gespeichert`) ein und öffnet
      `ACTION_CREATE_DOCUMENT` (`CATEGORY_OPENABLE`, `type`, `EXTRA_TITLE`) mit eigener Anfragenummer.
      `onActivityResult` ruft zuerst `super`, setzt `offen`, `bytes` und `gespeichert` immer zurück, schreibt in einem
      eigenen Thread über `contentResolver.openOutputStream(uri).use` und antwortet per `runOnUiThread`: `true` nach
      dem Speichern mit Toast `druck_datei_gespeichert` („Gespeichert: {datei}“, Text aus ARB), `false` bei Abbruch,
      `error("schreiben")`. Weitere Fehler: `belegt` (Anfrage offen), `kein_dialog` (`ActivityNotFoundException`),
      `argumente`. Wird die Activity neu erzeugt, verfällt die Anfrage still. Dart: `lib/party/datei_speichern.dart`
      (`dateiSpeichern`; `false` nur bei einer Ausnahme, ein Abbruch zählt wie beim Teilen als angeboten). Der Stub
      erkennt Android über `dart:io` `Platform.isAndroid` (Teststelle `aufAndroid`), **nicht** über
      `defaultTargetPlatform`: Das ist in Widget-Tests Android und hätte alle App-Tests umgestellt. Auf Android sind
      `zweiterTipp` und `kannHerunterladen` wahr, `dateiWege` ist [herunterladen, teilen], `dateiAnbieten(teilen:
      false)` geht an `dateiSpeichern`. iOS und Rechner unverändert: Der erste Tipp öffnet das Teilen. Android braucht
      damit wie der Browser einen zweiten Tipp, auch bei „Rollenhefte einzeln senden“. Scheitert der Dialog, steht die
      Fehlerzeile da und „Teilen“ bleibt daneben.
  65. **Standardweg ohne `weg` bleibt in der App „teilen“:** `DateiGeraet.standardWeg` ist `herunterladen` nur, wenn
      das Gerät herunterladen kann und dafür keinen Dialog braucht (`herunterladenMitDialog`, wahr nur im Stub auf
      Android, im Web `false`): im Browser also weiter der Download, in der App das Teilen, auch auf Android.
      `dateiAnbieten` ohne `weg` nimmt `standardWeg` statt `dateiWege().first`, sonst öffnete
      `lib/krimidinner/teile/druck.dart` (Aufruf ohne `weg`) auf Android plötzlich den Speichern-Dialog (Gegenprobe in
      `gewoelbe_druck_test`).
  66. **Entscheidung des Besitzers: „Als PDF“ bleibt, jeder spielt am eigenen Handy** (schließt die Frage aus Punkt 61):
      Der Knopf im Fuß der Erzählerakte bleibt unverändert, auch reihum. In der Android-App stehen dort nach dem
      Bauen kurz „Herunterladen“ und „Teilen“ wie im Browser (Test bei 320 × 568, Schrift 2: kein Überlauf, die
      Figurenliste bleibt). Anleitung §5.4 sagt den Rat zum eigenen Handy in einem Satz.
