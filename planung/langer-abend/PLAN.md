# Plan: Mordakte „Langer Abend & Begleiter“ (Schlosskeller)

## Kontext

Spieltest-Feedback des Besitzers (15 Punkte) plus Klärungen in dieser Sitzung. Der Abend ist zu textlastig und zu detektivzentriert:
- Im Solo-Schlosskeller mit 13 Bots gibt es in Runde 1 41 Pflicht-Protokolle (39 + 2 NPC, `bots.dart:34-89`).
- Detektivkarten verraten die Antworten der anderen (`solo_gespraeche.dart:170-177`, online `gast_ansicht.dart:669-714`).
- Figuren glitschen durch Möbel: Die Tap-Glättung nutzt `TileGrid.lineOfSight`, das Requisiten und den Körperradius ignoriert (`mordakte_game.dart:393-405`).
- Das „Geburtstagskind“ ist nur ein Alias für den Detektiv.
- Es fehlen Erzähler, Diashow, langer Modus, einfache PDFs und eine Charakterwahl.

**Entscheidungen des Besitzers (bindend):**
1. Inhalte nur für den **Schlosskeller**. Mechanik darf generisch sein, ist aber per Akte gegated. Die anderen 4 Akten laufen *nachweislich* unverändert.
2. **„Langer Abend“ (~120 Min.)**: längere Runden, viel größere Map (Erdgeschoss, Turm-Stockwerke, Schlosshof, Garten, Außenwelt), lebendige NPCs, mehr Inhalt. Der kurze Abend bleibt, mit allen Fixes.
3. **Kanon aufmachen**:
   - `content/party/schlosskeller/**` wird editierbar, Entscheidung A-050.
   - Eine **Beweis-Teilmenge bleibt fest gepinnt**: `entscheidungen.json`, `bonus.json`, `gruppenwahl.json`, `tatmatrix/{ahmet,fatma,olli,can}.json`, `wahrnehmung.json` sowie das Raster von `raeume.json`.
   - `krimidinner/**` und `content/scenarios/**` bleiben eingefroren.
   - Alle Lösbarkeits- und Fairnessbeweise bleiben grün.
4. **Story-Brücke**:
   - Um 00:15 fällt Schneider der Ersatzschlüssel der Stiftung ein. Der Schlüsselkasten steht im Turmgang. Er öffnet Hoftür, Turm und die Seitentür zum Erdgeschoss, das Außentor nicht.
   - Die Außenwelt ist in den Runden nur ein Ausblick vom Wehrgang. Begehbar ist sie im Vorspiel (18:00) und am Morgen (07:00).
   - Fall, Täterpfade und Lösung bleiben gleich. Die neuen Zonen tragen keine Fallhinweise.
5. **Neutrale Feier**: Der Geburtstag fliegt aus der Story. Der Detektiv ist Gast, die Augenbinde wird zum Mitternachtsspiel „Blinde Kuh“. Das Geburtstagskind-Feld und alle Geburtstagskind-Texte fliegen raus, nur im Schlosskeller.
6. **Erzähler ist optional, nie im Solo**:
   - Er liest vor und kennt alle Stichpunkte sowie den gezogenen Bonus-Hinweis, nie den Hinweis-Katalog.
   - Er steuert Diashow, Uhr und „Weiter“ in den Erzählphasen und entscheidet nichts.
   - Online wählt, wer den Raum öffnet, „Detektiv“ oder „Erzähler“.
   - Detektiv **und** Erzähler können in der Lobby die Figuren zuteilen.
7. **Bewegung**: Online im langen Abend steuert jeder seine Figur. Reihum läuft nur der Detektiv. Solo: der Detektiv plus lebendige NPCs. Der Erzähler hat eine Zuschauerkamera.
8. **CYOA**:
   - Die 9 Entscheidungen trifft der Detektiv, die anderen setzen Vorschlagsmarker.
   - Gruppenszenen entscheidet die Mehrheit, bei Gleichstand die Dateireihenfolge.
   - Nebenaufträge entscheidet jeder privat.
9. **Diashow** aus der Spielgrafik, gerendert in der Engine (keine fremden Dienste).
10. **Klassen** bekommen echte, faire Map-Fähigkeiten. Sie ändern nie Fakten, Optionen, Punkte, Ende, Würfelchancen oder Nachtminuten.

**Ziel:** Jeder hat in jeder Phase etwas zu tun und sieht nur seine Texte. Die App ist Begleiter: Stichpunkt-Karten, Uhr, Bilder, klare Aufgaben. Im langen Modus wird der Schlosskeller eine große, lebendige Welt.

---

## Leitregeln (gelten für alle Meilensteine)

- **R17 Kartenformat:**
  - Alles Neue, was Spieler auf dem Handy lesen, ist eine Karte mit höchstens 3 Stichpunkten zu je höchstens 8 Wörtern, plus optional einer einzeiligen Wahl.
  - Prosa gibt es nur in Vorlesetexten des Erzählers.
  - Ein Prüfer begrenzt die Wörter je Spielerbildschirm.
- **Vorleser-Sitz:** Erzähltext geht immer nur an *einen* Sitz. Das ist der Erzähler, sonst der Detektiv bzw. das Host-Gerät. Alle anderen sehen `erzaehlerLiest` plus Dia oder Phasenkarte. Solo: Text unter dem Dia, Weiter je Baustein.
- **Zeitbudget:**
  - Die Abendlänge wird nach der K-18-Formel geschätzt (`SPIELKERN.md:30`) und im Setup und auf der Startübersicht als „ca. X Min.“ gezeigt.
  - Standardwerte: kurz ≈ 85 Min., lang ≈ 120 Min.
  - Kurz: Gesprächsuhr 10/15/20 Min. je Runde. Die Rollen haben nur noch 1–3 Gespräche.
  - Lang: Die Rundenuhr deckt den ganzen Streifzug (Gespräche + Entscheidungen) ab, Optionen 20/25/30/40.
  - Jede Lang-Schätzung liegt über jeder Kurz-Schätzung. Ein Widget-Test prüft das.
- **Sitzzeitplan:** Für Detektiv, Erzähler, Rolle und Assistenz × kurz/lang × reihum/online/solo gibt es je Phase eine aktive Aufgabe. Die Übersicht zeigt `rollen_uebersicht.dart`, beschrieben in ANLEITUNG §6.
- **Andere Akten:**
  - Neue Schlosskeller-UI-Texte kommen in **neue** Dateien (`ui-befragung.json` usw.) bzw. in die ARB.
  - Bestehende geteilte `ui*.json` bekommen nach K1.0 keine neuen Schlüssel.
  - `ui_basis_unveraendert_test` beweist, dass sich die anderen Akten nicht ändern.

---

## Architektur (Kurzfassung)

| Baustein | Ort | Kern |
|---|---|---|
| Feature-Gating | `besetzung.json` `"gespraeche":{"modell":"befragung",…}`; `akten.json` `"faehigkeiten":[…]`; `AkteInfo.hat()` statt `druckbar => id=='schlosskeller'` (`lib/detektei/akten.dart:40`) | Ohne Flag gilt das heutige Verhalten. |
| Versionsschutz | `ansicht.dart:58-69` `inhaltsKennung` hasht künftig Akte-Ordner + welt + erzaehlung + zusatz; `protokollVersion` steigt in M2, M3 und M9 | Gemischte Builds im Raum werden mit `proto`/`inhalt` abgewiesen (Test in `relay_regression_test`). |
| Raum-Module | neu `runden/raum/raum_modul.dart` + `RaumKontext` (Sitz von id, Phase, Runde, besetzt, Partie nur lesend, nie salz) | Hooks: `nachricht(typ)`, `darfWeiter()`, `beimStart(zuteilung)`, `oeffentlich(id)`, `privat(id)`. Der Haken sitzt am `erlaubt`-Switch *vor* den Prüfungen `_partie`/`_nurHost`. Unbeanspruchte Typen ergeben weiter `invalid`, die Fehlercodes sind per Test gepinnt. |
| Rechte-API | M0, noch ohne Verhaltensänderung: `nurHost`, `nurDetektiv` (= `_detektiv`), `darfLeiten` | In M3 echt aufgeteilt. |
| Sichtfeld-Liste | eine geteilte Konstante erlaubter öffentlicher Schlüssel und Dossierfelder | Wird genutzt von `SchlosskellerRaum`, `server/tool/party_matrix.dart:197-216` und `relay_matrix.dart:512-560,689-700`. Jede neue Ansicht erweitert sie im selben Commit. |
| `Abendfassung {kurz, lang}` | `party/fassung.dart` | Liegt in PartySitzung (`_merke` nur bei lang), EinrichtungsWerte und SchlosskellerRaum (meta), nie in Einstellungen/Spiel/RundenPartie. |
| Sitze | `runden/sitze.dart` | `Sitz {detektiv, erzaehler, rolle, assistenz}`. Lobby-Nachrichten: `sitz` (nur Host), `besetzung`/`zuteilen`/`wunsch` (`darfLeiten`, also Detektiv, Erzähler oder Host; `wunsch` von jedem Gast). Zugeteilt wird nur als Permutation über `besetzt(n)`. `_detektiv = sitzplan.detektiv` (`:344`). Die Klasse reist mit dem Detektiv-Sitz. |
| Erzählerpaket | `party/erzaehler_paket.dart`, im **M2.1-Vertrag** | Pfadfrei: Tisch-Stichpunkte, Befragungen, npc. Nie: verbirgt, tatwissen, tarnung, pfad, salz, Qualität. Wird genutzt von Online-Ansicht, Reihum-Pult und Druck (Erzählerheft). Host-only-Getter `erzaehlerAb` statt Länge der öffentlichen Liste (`gastgeber_sitzung.dart:89-93`). |
| Befragungsmodell | `party/befragung.dart`; Kanon `texte/befragungen-r1..3.json` (60); `gespraeche-*` mit `stichpunkte` | Detektiv: 3–5 Befragungen je Runde. Feste Pflicht-Befragungen (Kettenglieder) plus 1–2 freie Wahlen, beide pfadfrei. Er sieht nur die Fragen. Rollen: 1–3 Gespräche je Runde. Antworten werden aus den Preisgaben erzeugt (`botAntwort`), App-gesprochene erst nach der Frage. Der Planer ist deterministisch und deckt jedes Kettenglied rechtzeitig ab (für n = 4–20 nachgerechnet). Verdrahtung: texte-index-Enum, Textsammlung-Switch, `_schemaJeBereich`, textQuellen. |
| RundenUhr | `runden/runden_uhr.dart`, `lib/party/runden_uhr.dart` | Nachricht `uhr`. Der Transport (relay_host, lokal, `server/lib/party.dart`) entfernt Client-Zeit und setzt eine eigene Abendzeit in `inhalt`. Kein tickendes Feld. Lokale Restzeit über den `pong.ht`-Versatz. |
| Diashow | `content/welt/schlosskeller/diashow.json`, `party/diashow.dart`, `dia_session.dart`, `diashow_ansicht.dart` | 6 Dias, weil `intro.start` in K1 in zwei Blöcke geteilt wird. Prüfer: 20–60 Wörter je Dia, keine Textfelder. Öffentlicher Zähler `dia`. |
| Klassenfähigkeiten | `karten/klassen.dart`, `lib/party/klasse_wirkung.dart`; Schnittstelle `SzenenKlasse` in der M1.5-Naht | Spurenblick, Menschenkenner, Ortskundig, Gerüchte, Laufschritt ×1,3. Nur Darstellung und Tempo. |
| Welt-Ebenen | `content/welt/schlosskeller/langfassung.json`, `welt/ebenen.dart` | `keller` (Kanon-Graph per Referenz), `erdgeschoss` (Halle, Küche, Schlosshof, ummauerter Garten), `turm` (WC, Turmzimmer, Wehrgang), `aussen` (Stufen, Parkplatz, Park). Übergänge an Kanon-Kacheln. Kanon-Systeme sehen nur den Keller. Jede Ebene unter ~70×60 Kacheln. |
| NPC-Routinen | `welt/routine.dart` auf **Ebenen-Graphen mit Portalen**, `routinen.json` | Je Runde ≥ 6 Zeugen mit Stationen außerhalb des Kellers. Ankerregel: Ziele der laufenden Entscheidung stehen am `ermittlungsOrt`. Gleiche Form für Verdächtige und Zeugen, Sperrorte. Kein Schlüssel `pfad` in irgendeiner Ansicht. |
| WeltRaum / Bewegung | `welt/laufweg.dart`, `welt_raum.dart`; Netz `welt_kanal.dart`, `gruppen_umschlag.dart` | Ereignisbasiert. Polylinien plant der Host. Je Ebene ein gruppenverschlüsseltes Thema mit 1–2-Hz-Bündeln. Läuft **nie** über `raum.nachricht`/ProtokollRaum. Alle behalten ihre Figur, Fallback sind niedrigere Raten statt Zuschauen. |
| Erzählstand / CYOA | `erzaehlung/erzaehlstand.dart`, `szene.dart`, `nebenauftrag.dart`, `begegnung.dart` + Modul | Kartenformat R17. Belohnungen `kosmetik`/`erinnerung` über die Quelle `auftrag`, ohne den Zufallsstrom zu verbrauchen. R13–R17. Ziele liegen bevorzugt in den neuen Zonen, mindestens k je Zone und Runde. |
| Steckbrief-PDF | `party/druck/steckbrief.dart`, Kanon `steckbriefe.json` (Schema-Check in `akte_pruefen._schema`) | Ohne Fall-Code. Regler „Wie viele seid ihr?“: Die Übersicht zeigt `besetzt(n)` alphabetisch, ohne n alle Figuren mit Hinweis. Dazu eine Gästeliste (Name → Figur, MetaStore). Sie füllt die Reihum-Namen und die Online-Zuteilung vor, beim Schrumpfen von n werden Wahlen markiert. `druckAlles()`, Rollenheft je Person, Teilen über share_plus. |

## Kanon-Änderungen (A-050, gespiegelt als E-043 in `planung/finalisierung-schlosskeller/ENTSCHEIDUNGSLOG.md`)

- **K1.0 (zuerst, in M0):** Die aktuell aufgelösten `ui.*`-Werte werden als Akte-Overrides eingefroren, damit Gewölbe und die Noir-Akten bytegleich bleiben.
  - Dazu `content/party/gewoelbe/texte/ui-akte.json` erzeugen und in `index.json` eintragen, Overrides für die Noir-Akten nur wo nötig.
  - Golden-Test `ui_basis_unveraendert_test` für die 4 Akten.
- **K1: neutrale Feier und Story-Brücke**
  - Dateien:
    - `figuren.json`, `setting.json`, `zeitleiste.json` (neu `z_ersatzschluessel` 00:15, ort `wendeltreppe_fuss`), `beobachtungen.json`, `gegenstaende.json`, `fall.json`;
    - `tatmatrix/basis.json` und `raeume.json` nur Texte;
    - `texte/detektiv.json`, `erzaehler-intro.json` (`intro.start` in 2 Blöcke), `erzaehler-aufloesung.json`, `dossiers-*`, `wahlen-*`, `ui*.json`, `quellabgleich.json` (Status `angepasst`, Grund E-043);
    - `content/erzaehlung/schlosskeller/gespraeche.json` (7 Geburtstagszeilen);
    - `content/party/textregeln.json` `raumAusnahmen` + Hof, Innenhof, Wehrgang, Erdgeschoss, Turmzimmer.
  - **Feste Felder in bearbeiteten Dateien:** alle IDs, `beobachtung.pfade`, `spuren.entstehtWenn`, nichttextuelle Teile von `tatmatrix/basis`, `fall.pfade/kernverdaechtige/zug`, Tür-`zustand`-Präfixe.
  - Motivkette: „Blinde Kuh“ (Tugbas Plan), Cans Streich gilt der „blinden Kuh“, Dilara wird Party-Planerin.
  - Ein Story-Logik-Review läuft mit Checkliste, die neu erzeugte STORY-BIBEL kommt in den PR.
- **K2: Gesprächsmodell.**
  - `gespraeche-r*-b*.json` bekommt 1 Tischgespräch je Rolle und Runde, `stichpunkte` statt `text`.
  - Neu `befragungen-r1..3.json`.
  - Außerdem `texte/index.json`, `besetzung.json` (Modellblock), `SCHLUESSEL.md` (Spalte „Erzähler“) und bei Lücken `erzaehler-npc.json`.
- **K3: Steckbriefe.** `steckbriefe.json` und `texte/ui-druck-steckbrief.json`.
- **Schemas.**
  - Strenge Quellen in `content/party/schema/`: gespraech mit `text` oder `stichpunkte`, neu befragung, besetzung `gespraeche`, steckbriefe.
  - Danach `python3 tool/schema_akte.py`.
  - Neu: `content/welt/*.schema.json` und `content/erzaehlung/*.schema.json`.
- **Prüfsummen.**
  - Neu `tool/kanon_fest.txt` hält die Beweis-Teilmenge, `krimidinner` und `scenarios`. Diese Liste wird nie neu erzeugt.
  - `tool/kanon_neu.sh` baselined den Rest des Schlosskellers neu und bricht ab, sobald eine gepinnte Datei abweicht.
  - Für `raeume.json` kommt ein Raster-Strukturhash-Test (begehbar/Tür-Bytes).
  - `tool/kanon_tor.sh` führt aus: `schema_akte.py`, `party_bibel.dart`, `party_prompts.dart`, `tool/bollwerk/kanon_einbetten.dart` (`kanon_eingebettet.g.dart`) und `kanon_neu.sh`.
  - Prüfen mit `kanon_tor.sh --pruefen`, das auch `kanon_einbetten.dart --pruefe` aufruft und in `pruefen.sh schnell` läuft.
  - `determinismus_soll*.g.dart` wird nie neu erzeugt.

---

## Meilensteine und Wellen

- **A:** M0
- **B:** M1 ‖ M2
- **C:** M3 ‖ M5 ‖ M6
- **D:** M4 ‖ M7a
- **E:** M7b ‖ M8 ‖ M10-Kern
- **F:** M9, dann M10-Spieler
- **G:** M11

Integration:
- Bei ARB-Konflikten wird vereinigt. `gen/`, Prüfsummen, Einbettung, STORY-BIBEL und bildprompts erzeugt nur der Integrator neu.
- Jedes Arbeitspaket hält `pruefen.sh schnell` plus seine Ziele grün.
- **Party- und Relay-Matrix gehören in jedes Tor.**
- Gemeinsame Fakes und die Sichtfeld-Liste werden im selben Commit wie die Änderung angepasst.

### M0 · Werkbank, CI, Basislinie, Nähte
- **Werkbank:**
  - Flutter einmal im Hauptcheckout installieren (`source tool/flutter_env.sh`, 29 GB frei).
  - Worktrees bekommen einen Symlink `.werkzeug` und teilen sich `PUB_CACHE` und den Playwright-Cache.
  - Höchstens 2 Worktrees gleichzeitig mit schweren Läufen. Der Integrator prüft vorher den freien Platz.
- **Basislauf:** `bash tool/pruefen.sh alles` plus `tool/e2e` (`npm ci`). Die Zählstände kommen in das neue `planung/langer-abend/STATUS.md`.
- **CI** (`.github/workflows/release.yml`):
  - Branch nur in den Push-Trigger (`:12`), **nicht** in den `latest`-Fall (`:394-404`).
  - Den `pages`-Job auf `main` beschränken.
  - Releases dieses Branches als `--prerelease`.
  - Den NOTES-Verweis (`:378`) auf die neue STATUS-Datei setzen.
- **Entscheidungen:** A-050 bis A-061 (`planung/gesamt/STATUS.md`), E-043, R13–R17 (`ERZAEHLREGELN.md`), Erzähler-Nachtrag zu TON-LEITFADEN §2.
- **Werkzeuge:** `kanon_fest.txt`, `kanon_neu.sh`, `kanon_tor.sh`.
- **K1.0** und `ui_basis_unveraendert_test`.
- **Nähte ohne Verhaltensänderung:**
  - `raum_modul.dart` + `RaumKontext`;
  - Rechte-API;
  - Sichtfeld-Konstante (beide Matrizen nutzen sie);
  - `gast_bausteine.dart`;
  - `faehigkeiten` + `AkteInfo.hat()`;
  - `inhaltsKennung` je Akte.
  - Test-Fakes (`test/abend/online_hilfe.dart:26,236,300,323`, `gastgeber_wuerfeln_test.dart:48`, `gastgeber_rueckkehr_test.dart:45`, `gast_aufloesung_test.dart:18`, `packages/mordakte_netz/test/relay_hilfe.dart:70`) auf `extends Fake` mit Standardwerten umstellen.
- **Neue Tests:**
  - `test/l10n/arb_ton_test.dart`: Textprüfer über neue ARB-Werte.
  - Ein Test, der die Fehlercodes `not_host`, `invalid` und `not_started` pinnt.
- **Tor:** wie die Basislinie, alle Kanon-, Matrix- und Raumtests grün.

### M1 · Glitch-Fix (alle 5 Akten)
- **`grid.dart`**: nur neue Methoden, `freieBahn()` (gewischter Kreis r = 0,28) und `findPath(extraBlockiert:)`. `lineOfSight`, `slide` und `canStand` bleiben, weil Kanon-Wahrnehmung und klassische Engine daran hängen.
- **`mordakte_game.dart`**:
  - `_wegZu` glättet mit `freieBahn`.
  - Hängt die Figur fest, wird neu geplant.
  - Die kollisionsfreie Notluke (`:916-921`) fliegt raus, stattdessen `nearestWalkable`.
  - Joystick: 8 Richtungen.
- **`karten_aktion.dart`**: Standkacheln nicht auf Personen, Glättung, weiche Blickrichtung.
- **`karte_session.dart`**:
  - `_nebeneinander` prüft mit `canStand`.
  - Die Rückblende läuft jedes Frame mit Bruchteilzeit (`posAmBruch`) und `exakteFiguren`.
- **Ascheneimer:** Er wird flach gezeichnet, statt das Raster zu ändern. Er ist Suchort von `e2_1_ascheneimer`, das Raster bleibt bytegleich.
- **M1.5 Naht:** `lib/game/welt_szene.dart` aus PartyKartenSession lösen, plus die Schnittstellen `KartenQuelle`, `SzenenKlasse`, `SzenenLaufziel` und `SzenenFiguren`. `karte_pfadgleich_test` bleibt bytegleich.
- **Tests:** neu `tipp_lauf_test` (alle Akten, jedes Ziel, je Frame `canStand`, kein Hängen), `runden_aktion_test` für alle 5 Akten, neu `rueckblende_kollision_test`, `engine_regression_test`, `leistung.mjs` (höchstens 10 % schlechter).

### M2 · Gesprächsmodell, Stichpunkte, verdeckte Antworten, Kanon K1+K2
- **2.1 Vertrag (Tag 0, Kern):**
  - `texte.dart`, neu `befragung.dart` und `erzaehler_paket.dart` (inklusive Privatsphäre-Test);
  - `besetzung.dart` (Modell, Deckel 3);
  - `bots.dart` `botAntwort`;
  - Schemas und Verdrahtung des Bereichs `befragung` an 4 Stellen;
  - eine Test-Fixture.
- **2.2 Prüfer:**
  - Modellzweig in `akte_pruefen._besetzung`.
  - Die Rollenzahl-Altfälle laufen über `gewoelbe` (n = 4–20), die Mehrpfad-Altfälle über `ravensmoor`.
  - Negativtests nutzen die IDs der geladenen Akte.
  - Neu `befragung_loesbar_test` (n = 4–20 × 4 Pfade).
  - Modellabhängig angepasst: texte_test, dossier_test, besetzung_je_zahl_test, spoiler_test, schlosskeller_raum_test (botGespraeche wird ein Alttest).
- **2.3 Inhalt K2** (5 Lanes + Review). **2.4 Inhalt K1** (Autor, Sensibilitätsleser, Story-Logik-Checkliste).
- **2.5 App offline:**
  - `stand/befragung_stand.dart` und `bildschirme/befragung.dart`: 3–5 Karten, davon 1–2 freie Wahlen; erst die Frage tippen, dann kommt die Antwort.
  - Solo: höchstens 3 Zeilen „Am Tisch aufgeschnappt“ ohne Antwortleck.
  - Dossier mit Stichpunkten, „Wenn der Detektiv dich befragt“ und „Wer dich anspricht“. Bei der Rollenübergabe gibt es nur die Notizen von Runde 1.
  - „Mein Spickzettel“ verdeckt, nur die laufende Runde.
  - Reihum bei einer menschlichen Befragung: kurzer verdeckter Blick „Gib das Gerät kurz an X“.
  - Die Weiter-Sperre fällt erst nach den Befragungen.
  - Das Journal bekommt eine Formatversion. Alte Schlosskeller-Spielstände werden mit Hinweis verworfen (fortsetzen_test).
- **2.6 Online:**
  - `raum/befragung_modul.dart` (`befragen`/`erledigt`, `nurDetektiv`).
  - „Verrät“-Bot-Blasen nur noch für Altakten.
  - Neu `gast_befragung.dart`.
  - Matrizen anpassen, `protokollVersion` erhöhen.
- **2.7 Druck minimal:** Stichpunkte in Rollenheft und Spielleitungsheft. Dazu `druck_spielleitung_test` (`:194`), `druck_pfadgleich_test` (`:37`) und `druck_nachpruefung_test`.
- **2.8 Treiber:**
  - Angepasst: `solo.mjs`, `geraete.mjs`, `karten_fotos.mjs`, `lib/party/skript.dart` (erledigt Befragungen automatisch), `test/party_widgets/hilfe.dart` `spieleBis` und `solo_test`.
  - `abbrechen.mjs` (Nachtexpress) bleibt **unverändert** als Alt-Wächter.
- **2.9 Kanon-Tor KT-1.**
- **Tor:**
  - `akte_pruefen` für alle 5 Akten mit 0 Befunden.
  - `partie_test`, `determinismus_web_test` (Golden unverändert), `kanon_einbetten --pruefe`, invarianz, spoiler, `figuren_abgleich_test`, `story_bibel`, `ui_basis_unveraendert`, karte_pfadgleich, `solo.mjs`, `e2e.mjs --semantik`, beide Matrizen.

### M3 · Sitze, Erzähler, Geburtstagskind raus, Lobby-Zuteilung, Gast-Detektiv
- **Kern:**
  - Rechte echt aufteilen, `_start` mit Zuteilung, `maxSpieler + 1`.
  - Der Würfelpate ist nie der Erzähler. Der Erzähler stimmt nicht mit ab.
  - Fällt der Erzähler länger als 2 Minuten aus, übernimmt der Host.
  - `server/lib/party.dart` bekommt Standardwerte.
- **Vorleser-Sitz:**
  - Der öffentliche Schlüssel `erzaehler` wandert ins `privat` des Vorlesers. Das ist eine Kernänderung, kein Modul.
  - Tests: Datenschutzmatrix „online ohne Erzähler: Gäste sehen keinen Erzähltext“ und `GastgeberSitzung` für Host = Erzähler und Host = Detektiv.
- **Einrichtung:**
  - `GeburtstagAbschnitt` wird ein generischer Abschnitt „Name des Detektivs“. Er liest den Überschriftenschlüssel je Akte (Noir „Der Inspektor“) und bleibt im Solo das Namensfeld.
  - Dazu „Rollen am Tisch“: Erzählername (reihum, optional), online „Dein Platz“.
  - Den Setup-Hinweis umformulieren: Erzähler oder ein Mitspieler richten ein.
  - Den Parameter `geburtstagskind` mit einem veralteten Alias umbenennen (erster_fall, solo_test), den alten Schlüssel weiter lesen.
  - ARB `hub_party_sub` und `erster_fall_text` anpassen.
  - Die Abendlänge anzeigen.
- **Lobby:**
  - Sitzwahl; n liegt im Raum.
  - Figurenwahl in `lobby_besetzung.dart`, auch in `gast_lobby.dart` für Gäste mit Detektiv- oder Erzählersitz.
  - `wunsch` der Gäste, vorbefüllt aus der Gästeliste (M5).
  - Reihum: zwei Porträts antippen, um zu tauschen.
  - Tests: Gast-Detektiv und Gast-Erzähler teilen zu, eine reine Rolle wird abgelehnt.
- **Erzähler-UI:**
  - Neu `gast_erzaehler.dart` und `erzaehler_ablauf.dart` (Host-Erzähler mit Pult und Zuschauerkarte).
  - Reihum `erzaehlerpult.dart`: **Erzähler-Begleiter**. Das Reihum-Gerät öffnet einen lokalen oder Online-Raum nur mit Erzählersitz, der Erzähler liest am eigenen Handy, der Tisch sieht die Dias mit großem „Nächstes Bild“.
  - Fallback: das Erzählerheft-PDF dieses Abends mit Dia-Nummern, Bonus nur im kurzen verdeckten Moment.
- **Gast-Detektiv:**
  - Neu `gast_ermittlung.dart`: Option, gründlich, Karte, bestätigen, Abstecher, Tischruf, Fund, Befragungen, Anklage.
  - Neu `gast_karte_session.dart` (lesend).
  - Fallback beim Host: `aktionFertig` per `SzenenUhr`.
  - Host-Randgespräche nur, wenn der Host auf dem Detektiv-Sitz sitzt. Ein e2e-Test prüft: Erzähler-Host bekommt keine Aufforderung.
- „Spielleitung“ in rund 15 `online_*`-Texten klar trennen, die Schlüsselnamen bleiben.
- `rollen_uebersicht.dart` mit Sitzzeitplan.
- **e2e:** neu `erzaehler.mjs`, 3 Kontexte mit Privatsphäre-Matrix und Zuteilung. Beide Matrizen, `protokollVersion`.

### M4 · Diashow und gemeinsame Rundenuhr
- **Uhr:**
  - Die Transporte stempeln (relay_host, lokal, server).
  - `pong.ht` mit Versatz, Wiederherstellung nach Neustart.
  - `RundeBildschirm` liest `s.uhr`, `runde_test` wird für `s.uhr` umgeschrieben. Die Gäste sehen die Uhr.
- **Diashow:**
  - `diashow.json` plus Schema plus `akte_pruefen`-Haken, `diashow_test`.
  - Eine GameView mit Kamerafahrt, Layout aus `rueckblende_ansicht.dart`, MFotoabzug/Portrait.
  - `IntroBildschirm`: Der Vorleser sieht Text und „nächstes Bild“, der Tisch die Diashow.
  - `ErzaehlerFeld.onBaustein`, Modul `dia`, `gast_diashow.dart`.
- **Tests:** neu `tool/bild/dia_bogen_test.dart` (Kontaktbogen, BILD-CHECKLISTE B6/B8), e2e `diashow.mjs`, Widget-Test „ein Gerät + Erzähler-Begleiter + Diashow“.

### M5 · PDFs, Steckbriefe, Teilen (nutzt das Erzählerpaket aus M2.1)
- **Steckbriefe:**
  - `steckbrief.dart` plus Inhalt K3.
  - Neu `steckbrief_seite.dart` auf der Akte-Seite: ein Tap, Personenzahl-Regler, Gästeliste (Name → Figur).
  - `steckbrief_test`: A4, kein Überlauf, `pdftotext` ohne Spoilerfelder, gleich über Codes und Pfade, jede Figur der Übersicht bei n auch in der Lobby zuteilbar.
- **Druck:**
  - Rollenheft je Person als eigene Datei. Spielleitungsheft wird **Erzählerheft**, auch für jeden Reihum-Abend aus der Rollenphase erhältlich. Detektivbogen nur mit Fragen.
  - `druckAlles()`.
- **Teilen:**
  - Über einen injizierbaren Haken (wie `teilenUeber`), share_plus `XFile.fromData` application/pdf.
  - Web in zwei Schritten: erst bauen, dann Download oder Teilen im zweiten Tap; `canShare` über eigenes js_interop.
  - Angepasst: der Krimidinner-Aufrufer (`lib/krimidinner/teile/druck.dart:37-44`), `druck_tafel_test` und `gewoelbe_druck_test`.
- **UI:** `druck_tafel.dart` mit „Alles (ein PDF)“ und „Senden“ je Person. CLI `party_druck.dart` mit `--fall`, `--steckbriefe` und `--alles`.

### M6 · Klassenfähigkeiten und Erklärungen
- **Kern und Inhalt:** `klassen.dart` plus Architekturwächter. `klasse_wirkung.dart` über `SzenenKlasse`. Gerüchte in `geruechte.json` plus Prüfer.
- **Erklärungen:**
  - `klasse_zeile.dart`: was die Klasse tut, „ändert nie Fakten/Punkte/Würfel“, ihre 3 Karten.
  - `profile_screen.dart:240-300` mit neuen Schlüsseln `abend_klasse_<id>_faehigkeit`. Die alten `class_*` bleiben für die klassische Engine.
  - Neu `detektiv_karte.dart` mit Einweisung, Regeln, Fähigkeit und Befragungen.
- **M6.4 (nach M3):**
  - Die Klasse reist mit dem `sitz` und wirkt in `gast_karte_session`.
  - `KlasseZeile` und die Detektivkarte erscheinen nur auf dem Gerät mit Detektiv-Sitz, die Belohnung bekommt dieses Gerät.
- **Tests:** `klasse_pfadgleich` (5 × 4), `klasse_invarianz`.

### M7a · Welt-Ebenen und Inhalt (parallel zu M4)
- `welt/ebenen.dart`, `partyEbenenSzenarien()`, `akte_pruefen._langfassung`.
- `langfassung.json` mit den 4 Ebenen.
- Neue Requisiten: Hecke, Brunnen, Bank, Stufen, Tor, Zinne, Laterne, Beet. Kulisse `schloss`.
- Raster je Ebene, Portale, Szenen-Cache mit 0,3 s Überblendung (`_syncScenario :576-606`), Nebel nur im Sichtbereich.
- Tests: `karte_ebenen_test` (Erreichbarkeit aller Ebenen; Außentor in den Runden nie begehbar; Hoftür im kurzen Abend zu), `leistung.mjs` je Ebene.

### M7b · Langer Abend: Fassung, Streifzug, Vorspiel/Morgen (nach M4)
- **Fassung:** sitzung → abschnitte → abend_neu → gastgeber_dienst meta → Raum → Gast, inklusive Zeitbudget-Optionen.
- **Streifzug:**
  - `bildschirme/streifzug.dart` für die Phasen `gespraeche` und `entscheidungen`. Die Phasen bleiben, `PARTY phase=` ist unverändert.
  - Gesprächskarten sind an Orte gebunden („Triff X am Brunnen“), die Begegnung löst die Impulskarte für das Gespräch am Tisch aus.
  - Vor jeder Entscheidung läuft der Detektiv automatisch zurück in den Keller.
  - Erkundung in `erkundung.json` kostet 0 Nachtminuten. Kosmetischer Zufall: `Rng('lang:$weltSamen:…')`.
  - Reihum lang: Das freie Laufen des Detektivs ist je Runde gedeckelt, die Zeit fließt in Gruppenszenen und Tischaufgaben.
- **Vorspiel und Morgen** sind Unterzustände von intro bzw. ende. Den Server-TTL (`rooms.dart:199,510-517`) verlängern, solange der Morgen läuft. Neue Fotonamen kommen in `fotoGruppe`/`FESTE_FOTOS`.
- **Tests:** `lang_invarianz_test` (kurz und lang ergeben dieselben Punkte, dasselbe Ende, dieselben Fakten und Würfe), e2e-Lane `?party=schlosskeller&fassung=lang`, Zeitbudget-Widget-Test.

### M8 · Lebendige NPCs
- `welt/routine.dart` auf Ebenen-Graphen mit Portalen. `pruefeRoutinen`: gleiche Form, Sperrorte, je Runde ≥ 6 Zeugen außerhalb des Kellers.
- `routinen.json` (21 Figuren × 3 Runden).
- `npc_leben.dart`: Fortschritt nur über `szenenSchritt`, Ankerregel.
- Neue Tätigkeiten in `figur_rig.dart`.
- `karte_pfadgleich_test` mit festen Uhrschritten.

### M9 · Mehrspieler-Bewegung
- **Kern:** `laufweg`, `welt_raum` (gehe, binde, tick → Begegnung).
- **Netz:**
  - Je Ebene ein Thema, Gruppenschlüssel in `willkommen`.
  - `RelayHost` behandelt `gehe`/`ansprechen`/`wsync` ohne `raum.nachricht`/`_speichern`.
  - Sendepriorität: Steuerung vor Welt vor Ansichten.
  - Snapshot alle 10 s, Ablage höchstens alle 5 s, `protokollVersion` erhöhen.
- **App:**
  - `gast_karte_session` mit Bewegung, `aussehenVon`, im Folgemodus bleibt Tippen erlaubt.
  - Erzähler mit Zuschauerkamera. Der Gast-Detektiv tippt Ziele auf der eigenen Karte an.
- Die Supabase-Grenzen (Free) vorher in den Docs prüfen. Alle behalten ihre Figur, bei Last werden die Raten gesenkt.
- **Tests:** `relay_matrix --bewegung` mit 8 und 22 Geräten (Zustellungen ≤ 60/s, Host ≤ 30/s), e2e `bewegung.mjs`.

### M10 · CYOA-Ausbau (Reihenfolge nach Spaß für alle)
- **10.1 Gruppenszenen (9):** Der Vorleser liest, abstimmen online je Handy, reihum per Handzeichen beim Detektiv, solo wählt der Detektiv. Die Wirkung ist nur erzählerisch.
- **10.2 Nebenaufträge als Karten:**
  - 21 Rollen × 3 Etappen, etwa 2,5k Wörter, Ziele in den neuen Zonen.
  - Reihum gibt es eine gebündelte verdeckte Übergabe **„Dein Moment“** je Person und Runde: Gruppenwahl, eine Auftragsetappe und die Notizen der nächsten Runde.
  - Das heißt höchstens n Übergaben je Runde und höchstens 3 Karten. Gedruckte Stimmkarten sind optional.
  - Widget-Test zählt die Übergaben.
- **10.3 Tipp-Marker** online. Reihum ruft der Tisch die Tipps zu und der Detektiv trägt sie ein.
- **10.4 Erzählstand-Modul** für den Online-Detektiv (Randgespräche auch für den Gast-Detektiv). **Für die Spieler erst nach M9**, zusammen mit 10.5 Begegnungen. Unter Menschen gibt es nur Impulskarten (A-047/R14).
- **10.6 Morgen-Nachspiel.**
- **10.7 (Stretch)** Randgespräche für die übrigen 12 Zeugen, standardmäßig aktiv im Solo und wenn Zeugen unbesetzt bleiben.
- **Prüfer:** `pruefeSzenen`, `pruefeNebenauftraege`, `pruefeBegegnungen` plus R17-Wortgrenzen. Die Matrizen werden bei jedem neuen Schlüssel angepasst.

### M11 · Doku, e2e, Gegenprüfung, Release
- **Doku:**
  - `docs/ANLEITUNG.md` §4–§10 (inklusive Sitzzeitplan und der umbenannten „Spielleitung“-Fehlertexte).
  - `docs/partykrimi/ANLEITUNG.md` komplett.
  - README.
  - `store/metadata` für Android und iOS gleichlautend (`store_texte_test`).
  - `tool/e2e/README.md`.
- **Proben in `pruefen.sh ci`:** `erzaehler`, `diashow`, ein kurzes `bewegung` und die `fassung=lang`-Lane. Danach `bash tool/pruefen.sh e2e` (84 Läufe).
- **Adversariale Prüfer:** Spoiler-Jäger, Fairness-Brecher, Privatsphäre-Auditor (zustandFuer je Sitz × 4 Pfade), Ton und Sensibilität, Leistung auf schwachem Web, Netzbudget.
- **Abschluss:** STATUS pflegen, Push, Draft-PR, die PR-Aktivität abonnieren, CI grün.

**Inhaltsbudget (spielersichtbar gedeckelt nach R17):**

| Inhalt | Wörter |
|---|---|
| K1 | ~3k |
| Tisch-Stichpunkte | ~2k |
| Befragungen | ~2,5k |
| Steckbriefe | ~1,4k |
| Gerüchte | ~0,8k |
| Welt/Erkundung | ~2k |
| Szenen | ~1,7k |
| Nebenaufträge | ~2,5k |
| Begegnungen | ~1,5k |
| Morgen und Vorspiel | ~1,4k |
| UI | ~1,2k |
| Stretch: Randgespräche | 6,4k |

Prüfkette für jeden Text:
1. Schema
2. Textprüfer (Satz ≤ 25 Wörter, Schnitt ≤ 14, Verbote, Vorleseregeln)
3. textLint (Uhrzeiten, Raumwörter)
4. Fünf-Wort-Leck und Spoilerwörter
5. P-1/P-2 und keine unbesetzten Namen
6. Strukturprüfer
7. R17 und ARB-Tontest
8. Menschliches Review

---

## Umsetzung

- Je Welle läuft ein Workflow. Arbeitspakete laufen als Agenten mit `isolation: worktree`, mit eigenen Dateien. Hotspot-Dateien (`schlosskeller_raum.dart`, `gast_ansicht.dart`, `sitzung.dart`, `karte_session.dart`, `mordakte_game.dart`) werden nur an benannten Haken angefasst.
- Ein Integrator merged, erzeugt `gen/` und den Kanon neu und fährt das Tor.
- Nach jedem Tor wird committet und auf `claude/beautiful-dijkstra-z79u0t` gepusht. Nach dem ersten Push gibt es einen Draft-PR, den ich beobachte.

## Verifikation (alle Befehle vom Repo-Wurzelordner aus)

- **Jeder Merge:**
  ```
  source tool/flutter_env.sh
  bash tool/pruefen.sh schnell
  ulimit -s 8192; flutter test --concurrency=2 <Ziele>
  flutter gen-l10n && git diff --exit-code lib/l10n/gen
  ```
- **Beweis-Suite ab M1:**
  ```
  (cd packages/mordakte_core && dart test test/runden/partie_test.dart test/runden/determinismus_web_test.dart test/karten/invarianz_test.dart test/party/spoiler_test.dart test/kanon_unveraendert_test.dart test/erzaehlung/erzaehlung_test.dart test/party/befragung_loesbar_test.dart test/party/figuren_abgleich_test.dart)
  for a in schlosskeller gewoelbe ravensmoor nachtexpress blue_palm; do (cd packages/mordakte_core && dart run bin/akte_pruefen.dart --fall $a); done
  (cd packages/mordakte_core && dart run bin/karten_pruefen.dart && dart run bin/party_bibel.dart --pruefen)
  python3 tool/schema_akte.py --pruefen
  bash tool/kanon_tor.sh --pruefen      # inkl. kanon_einbetten --pruefe und kanon_fest
  ```
  Dazu `flutter test` für `karte_pfadgleich`, `tipp_lauf`, `lang_invarianz`, `klasse_pfadgleich` und `ui_basis_unveraendert`.
- **Netz (jedes Tor):**
  ```
  cd server
  dart run tool/party_matrix.dart --clients=4
  dart run tool/relay_matrix.dart --lokal --clients=4
  ```
  Ab M9 zusätzlich `--clients=22 --bewegung`.
- **Browser:** `bash tool/pruefen.sh ci` sowie `start`, `runden`, `solo --nur320`, `geraete`, `erzaehler`, `diashow`, `bewegung`, `leistung`, `e2e --semantik` und `kontaktbogen`. Am Ende `bash tool/pruefen.sh e2e`.
- **Spieltest-Checkliste für den Besitzer:**
  1. Kurz reihum ohne Erzähler:
     - 3–5 Befragungen ohne Antworten;
     - 1–3 Gespräche je Rolle;
     - höchstens n Übergaben je Runde;
     - Spickzettel;
     - der Fall ist lösbar;
     - die Abendlänge messen.
  2. Reihum mit Erzähler-Begleiter (eigenes Handy) und Diashow am Tisch.
  3. Online, Host ist Erzähler, der Detektiv ist Gast:
     - Zuteilung durch Detektiv und Erzähler;
     - Erzähltext nur beim Erzähler;
     - Bonus ohne Qualität;
     - die Uhr läuft synchron.
  4. Online, Host ist Detektiv, ohne Erzähler: Die Gäste sehen keinen Erzähltext.
  5. Solo: keine 41 Protokolle mehr, Diashow mit Text, im langen Abend lebendige NPCs.
  6. Langer Abend online mit 8 Handys:
     - alle laufen;
     - Hof, Garten und Turm sind offen, das Tor bleibt zu;
     - Szenen, Aufträge und Begegnungen funktionieren;
     - Dauer etwa 120 Min.;
     - Akku, Wärme und Supabase-Zähler notieren.
  7. Kein Glitschen in allen 5 Akten.
  8. Klassen sind sichtbar und erklärt, auch beim Gast-Detektiv.
  9. PDFs:
     - Übersicht mit Personenzahl;
     - Gästeliste wandert in die Lobby;
     - Teilen auf Android und iOS;
     - „Alles“-PDF;
     - Rollenheft je Person.
  10. Kein „Geburtstag“ mehr im Schlosskeller. Das Gewölbe ist unverändert.

## Offene Risiken (Besitzer im Blick)

1. **Supabase-Free-Budget** bei vielen Läufern. Gegenmittel: Themen je Ebene, Bündel, Raten senken. Die Grenzen vor M9 in den Docs prüfen. Notfalls braucht es einen bezahlten Plan.
2. **Umerzählung der Feier:** Die Beweise prüfen nur die Mechanik. Die neue STORY-BIBEL kommt im PR zur kurzen Durchsicht.
3. **Reihum-Geheimnis** bleibt ein Ehrenschutz wie beim Dossier. Am besten mit Erzähler-Handy oder Erzählerheft.
4. **Zwischen den Wellen C und E** hat ein Gast-Detektiv noch keine Randgespräche. Das betrifft nur die neue Konstellation Host = Erzähler.
5. **Gast-Detektiv-Handy schläft ein.** Gegenmittel: Host-Fallback, „Szene abkürzen“, Sitz neu zuteilen. Es bleibt bei keiner Host-Migration.
6. **Mobile-Web-Leistung** großer Ebenen. Abnahmewerte für `leistung.mjs` legen wir vor M7a fest.
7. **Releases:** Dieser Branch erzeugt bei jedem Push ein Prerelease. `latest` und Pages bleiben bei `main`.
