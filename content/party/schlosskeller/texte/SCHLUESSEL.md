# Textsammlung · Schlüssel und Regeln (F3-ORCH-00, E-026)

Diese Datei ist die Anleitung für alle Autorinnen und Autoren. Der Lader ist `packages/mordakte_core/lib/src/party/texte.dart`. Die Prüfungen laufen in `test/party/texte_test.dart` (Verweise und Regeln), `test/party/befragung_test.dart` (Befragungsplan, A-051) und am F3-Tor über `textLuecken` (Vollständigkeit).

## Grundsätze
1. **Eine Quelle.** Tatsachen stehen schon im Kanon: Beobachtungen, Spuren, Lügen, Nebendelikte, Zeitleiste, Entscheidungen und Bonus-Hinweise. Texte schreiben sie nicht ab, sondern verweisen auf sie:
   - `beobachtung:<id>`
   - `luege:<id>`
   - `nebendelikt:<id>`
   - `zeitleiste:<id>`
   - `spur:<id>`

   Pfadabhängiges Wissen setzt der Code je Pfad ein. Eine Beobachtung, die es im Pfad nicht gibt, fällt weg.
2. **Jede Kennung genau einmal.** Jede Datei gehört genau einem Auftrag. Bei einer Doppelung gilt der erste Eintrag, und die Prüfung wird rot.
3. **Ton** nach `planung/finalisierung-schlosskeller/TON-LEITFADEN.md`:
   - Sätze im Mittel höchstens 14 Wörter, keiner über 25.
   - Keine Fachwörter.
   - Kein Alkohol, keine Drogen, kein Rauchen.
   - In Vorlesetexten (Erzähler) Uhrzeiten und Beträge in Worten.

## Dateien (Liste in `index.json`)
| Datei | Bereich | Einträge |
|---|---|---|
| `erzaehler-intro.json` | erzaehler | `intro.start`, `intro.lacher.<lacher>.besetzt` und `.npc` (je 3), `intro.auftrag.m`, `intro.auftrag.w` |
| `erzaehler-runden.json` | erzaehler | `runde.1.start` bis `runde.3.start`, `bonus.rahmen`, `resuemee.gruppe.1` bis `.3`, `resuemee.rest.*` (12), `resuemee.lage.<runde>.<offen\|spur\|klar>` (9), `anklage.start` |
| `erzaehler-npc.json` | erzaehler | `npc.<figur>.<runde>`: Wissen unbesetzter Gäste ohne Namen (E-035) |
| `erzaehler-npc-ziel.json` | erzaehler | `npc.<figur>.<runde>`: Wissen unbesetzter Zielfiguren mit Namen (E-044, Modell befragung) |
| `erzaehler-finale-<pfad>.json` | erzaehler | `finale.<pfad>.<ende_meister\|ende_teilerfolg\|ende_justizirrtum\|ende_eskalation>`, `rueckblende.<pfad>` |
| `erzaehler-aufloesung.json` | erzaehler | `aufloesung.gruppe.0` bis `.3`, `aufloesung.<rolle>` (16 Nebenrollen), `aufloesung.<kernrolle>.taeter` und `.unschuldig` (8) |
| `dossiers-b1.json` bis `-b5.json` | dossier | je Rolle: `rolle`, `wer`, `weiss[]`, `verbirgt[]`, `ziel`, `besetzung` |
| `taeter-<pfad>.json` | taeter | `rolle`, `tarnung`, `tatwissen[]`, `verbirgt[]`, `ziel` |
| `detektiv.json` | detektiv | `detektiv.m.*`, `detektiv.w.*`, `ermittlungsbogen.*` |
| `gespraeche-r<N>-b<B>.json` | gespraech | Tischgespräche `g_<rolle>_<runde>_1` mit `partner`, `thema`, `ziel`, `preisgabe[]`, `stichpunkte[]` (Modell befragung, A-051) |
| `befragungen-r<N>.json` | befragung | `bf_<rolle>_<runde>` mit `thema`, `fragen[]`, `stichpunkte[]`, `preisgabe[]` (20 je Runde) |
| `befragung-kurz.json` | kurzfassung | je Preisgabe einer Befragung (`quelle`: `beobachtung:<id>` oder `luege:<id>`) eine Karte: `antwort[]` und bei Beobachtungen `du[]` (E-044) |
| `wahlen-kern.json`, `wahlen-b2.json` bis `-b5.json` | wahl | `gw_<rolle>_<runde>` mit `a`, `b`, bei Kernrollen `sabotage` |
| `ui.json` | ui | `ui.*` (F4) |

Die Kennungen der Erzählerbausteine kommen aus `Erzaehler.katalog()`; andere Kennungen sind dort verboten.

## Sichtbarkeit
Wer was sieht, vor dem Finale. „Tisch“ heißt: alle am Tisch, auch auf jedem Gerät. Der Erzähler ist ein eigener,
freiwilliger Sitz (A-052); er liest vor, kennt alle Stichpunkte und entscheidet nichts. Die Spalte gilt auch für das
Erzählerpaket (`packages/mordakte_core/lib/src/party/erzaehler_paket.dart`).

| Text | Tisch | eigene Rolle | Detektiv | Erzähler |
|---|---|---|---|---|
| Erzählerbausteine außer `finale.*`, `rueckblende.*`, `aufloesung.*` | ja | ja | ja | ja |
| `npc.<figur>.<runde>` (Wissen unbesetzter Gäste) | ja | ja | ja | ja |
| `dossier.wer` (Vorstellung) | ja | ja | ja | ja |
| Tischgespräch: Sprecher, Partner, `thema` | ja | ja | ja | ja |
| Tischgespräch: `stichpunkte` | nein | die Sprecherin; die Partnerin sieht nur Sprecher und Thema | nein | ja |
| Tischgespräch: `ziel` | nein | ja | nein | nein |
| Befragung: wen, `thema`, `fragen` | nein | ja, die eigene | ja | ja |
| Befragung: Antwort aus `preisgabe` (Kurzfassung, `befragung-kurz.json`) | nein | ja, die eigene | erst nach der Frage | ja |
| Befragung: `stichpunkte` (eigene Würze) | nein | ja, die eigene | nein | nein |
| `weiss`, `verbirgt`, Täterfassung, Wahltexte, `dossier.ziel` | nein | ja | nein | nein |
| `detektiv.*`, `ermittlungsbogen.*` | nein | nein | ja | nein |
| gezogener Bonus-Hinweis | ja, vorgelesen | ja | ja | ja |
| Bonus-Katalog, Qualität der Hinweise | nein | nein | nein | nein |
| Begründungen der Entscheidungen, Täterpfad, Fall-Code, Salz | nein | nein | nein | nein |

- **Erst in der Auflösung:** die Begründungen der Entscheidungen (`entscheidungen.json`, `begruendung` je Pfad) und die Qualität der Hinweise. Vorher verrieten sie den Pfad.
- **Was der Detektiv findet:** Fundtexte (`zeigt` und `harmlos` der Spuren in `gegenstaende.json`) und Ergebnisse der Entscheidungen erscheinen, sobald eine Entscheidung sie aufdeckt. Ab dann gehören sie zum Wissen des Detektivs und dürfen am Tisch stehen. Fundtexte sind unpersönlich, ohne „du“, und verneinen nichts („kein Messing“ schlösse jemanden aus).
- **Spoilerregel (S-1):** Sie gilt für alles, was die App, der Erzähler oder eine Befragung am Tisch zeigt. Was eine Rolle unter `weiss` kennt, darf ihre Spielerin selbst erzählen; das ist Spiel, kein Spoiler.
  - Einzelregeln:
  - Nichts, was am Tisch steht, verrät den Täter-Pfad oder geht über das Wissen des Detektivs hinaus.
  - Fragen einer Befragung setzen kein Wissen voraus, das der Detektiv nicht hat, und nennen kein Geheimnis.
  - `resuemee.rest.eins` nennt keinen Namen.
  - `bonus.rahmen` sagt nie, ob ein Hinweis stimmt.

## Gesprächsmodell „befragung“ (A-051)
Der Schalter steht in `besetzung.json` (`"gespraeche": {"modell": "befragung", "tischJeRolle": 1, "lastRolle": 3, "befragungenJeRunde": [3, 5]}`). Ohne Schalter gilt das Modell legacy (drei Pflichtgespräche je Rolle und Runde, der Detektiv springt als Partner ein); so bleiben Gewölbe und die Noir-Akten.
- **Tisch:** Jede Rolle führt je Runde genau ein Tischgespräch mit einer anderen Rolle, nie mit dem Detektiv. Bei 20 Rollen ist jede Rolle genau einmal Wunschpartnerin; bei weniger Rollen setzt der Gesprächsplan Ersatz ein, ohne dass jemand mehr als zwei Tischgespräche hat.
- **Befragungen:** Der Detektiv führt je Runde 3 bis 5 Befragungen. Feste Befragungen plant `Befragungsplan` (`packages/mordakte_core/lib/src/party/befragung.dart`) nur aus Rollenzahl und den Ketten aller Pfade; dazu wählt er bis zu zwei frei. Er sieht die Fragen, nie die Antwort, bevor er fragt. Welche Frage er wählt, ändert nichts an der Antwort.
- **Antworten:** Sie werden nie in der Befragung geschrieben. Für eine Rolle der App entstehen sie aus `preisgabe` (`botAntwort`): je Preisgabe ihre Kanon-Kurzfassung aus `befragung-kurz.json` (E-044), Beobachtungen in der dritten Person, Lügen nur als Behauptung. Eine gespielte Rolle sieht dieselben Verweise auf ihrem Spickzettel in der Du-Form (`du`, sonst `antwort`; Lügen als „Behaupte: …“) und ihre `stichpunkte`. Das gilt in App, Online-Abend und Rollenheft gleich. Jede Preisgabe bleibt dabei eine eigene Karte (`BefragungsZettel.karten`, `befragungsKarten`): Antwort, Spickzettel, Gast-Blatt und Rollenheft zeigen die Karten getrennt, die eigenen `stichpunkte` als letzte Karte.
- **Kurzfassungen (E-044):** Eine Preisgabe ist eine Karte nach R17: ein bis drei Stichpunkte zu je höchstens acht Wörtern. Jeder Hinweisinhalt der Langfassung bleibt erhalten (Uhrzeit, Personen, Ort, Richtung); lieber drei Stichpunkte als ein gestrichener Inhalt. `du` gibt es nur bei Beobachtungen; bei einer Lüge steht nur die Behauptung in der Ich-Form, nie die Wahrheit. Eine Behauptung hat höchstens sieben Wörter, weil der Spickzettel „Behaupte:“ davor setzt und die Zeile dann acht hat. Die Langfassung bleibt in `beobachtungen.json` und `figuren.json` und im Dossier unter „Was du weißt“ und „Was du verbirgst“. Geprüft werden R17, P-1, P-2, Spoilerwörter und Fünf-Wort-Folgen wie bei allen Tischtexten.
- **Last:** Je Rolle und Runde ein bis drei Gespräche: ein eigenes Tischgespräch, höchstens eines als Partnerin, höchstens eine Befragung.
- **Zustellung:** Jedes Tisch-Kettenglied (Lüge oder Beobachtung mit Kanal `pflichtgespraech` in einer Begründungskette) erreicht den Detektiv bis zu seiner Entscheidung: über eine feste Befragung der besetzten Halterin, über den Erzähler (`npc.*`) oder als Fund. `akte_pruefen` prüft das für 4 bis 20 Rollen und alle Pfade.
- **Unbesetzte Zielfiguren (E-044):** Ziel einer Option zu sein bringt kein Wissen; die Fundkarte zeigt nur die Fakten der Option. Der Erzähler spricht deshalb zum Rundenstart auch das Pflichtgespräch-Wissen einer unbesetzten Zielfigur (`erzaehler-npc-ziel.json`), mit ihrem Namen, weil die Optionen sie ohnehin nennen. Gäste, die kein Ziel sind, bleiben namenlos (E-035, E-036). Wie dort gilt: nur Beobachtungen aus allen Pfaden, gesprochen in der Runde, in der eine Kette eines beliebigen Pfads sie zuerst braucht. Was der Erzähler so gesprochen hat, steht danach wortgleich im Notizbuch des Detektivs („Vom Erzähler gehört“), damit er es bei jeder späteren Entscheidung nachlesen kann, wie eine Antwort aus einer Befragung.

## Regeln für Finale und Ausgang (E-029)
- Das Finale kennt nur Täterpfad, Ende und Punkte, nicht den Verlauf. Kein Finaltext sagt deshalb, ob der Detektiv den Bund in der Nacht gefunden hat.
- **Richtige Anklage** (`ende_meister`, `ende_teilerfolg`): Die Täterperson gesteht und gibt den Bund heraus. Herr Schneider schließt das Außentor erst auf, als es dämmert; bis dahin gibt es Torte und Tee (Master 7.9, E-039).
- **Schlüsselbeweis im Meister-Ende** (E-039): Er kommt erst nach dem Geständnis, wenn alle gemeinsam hinsehen. Meister-Detektiv gibt es ab sieben Punkten, also auch ohne die Entscheidung, die ihn aufdeckt.
- **Falsche Anklage** (`ende_justizirrtum`, `ende_eskalation`): Der Bund bleibt verschwunden. Um sieben Uhr schließt Herrn Schneiders Kollegin mit ihrem Torschlüssel auf (`z_morgen`). Die Täterperson gesteht erst danach.
- Eine falsch angeklagte Person wird nie beim Namen genannt; der Text passt für jede.
- Die Rückblende erzählt die Tat nach der Tatmatrix des Pfads: Weg zur Tat, Schlag, die Spuren, die dabei entstehen, und das Versteck des Bunds.
- Anrede: Der Detektiv heißt in Finaltexten „du“ (TON-LEITFADEN §3).

## Regeln für Dossiers
- Dossiers sprechen die Spielerin oder den Spieler mit „du“ an.
- `wer`: Vorstellung in zwei bis vier Sätzen. Öffentlich bekannte Beziehungen (Geschwister, Cousins, beste Freundinnen) dürfen hier stehen; was jemand für einen anderen tut oder verschweigt, nicht. Name, Alltag, Bezug zur Gruppe, sichtbares Merkmal. Kein Geheimnis.
- `weiss`: was die Rolle sicher weiß und am Tisch sagen darf. Nichts, was ein eigenes oder fremdes Geheimnis verrät. Verweise nur auf eigene Beobachtungen der Rolle (Feld `wer` der Beobachtung). Eigene Sätze nur ohne neue Tatsachen.
- `verbirgt`: verborgene Beobachtungen der Rolle, Nebendelikt, eigene Lügen. Eine Lüge erscheint mit Behauptung und Wahrheit. Ein Satz dazu, warum die Rolle schweigt (aus `grundVerborgen`, `loyalitaet` oder `persoenlichesZiel`, E-029). Was das eigene Motiv verrät, steht hier und nicht unter `weiss`.
- `ziel`: das persönliche Ziel aus `figuren.json`, in eigenen Worten.
- `besetzung`: ein Satz, wie die Rolle von jedem Geschlecht gespielt wird.
- **Täterfassung:**
  - `tarnung`: was die Person über die Tatsekunden erzählt.
  - `tatwissen`: was wirklich geschah, aus `killerProfile` und der Tatmatrix des Pfads.
  - `verbirgt`: Lügen und Nebendelikt. Die Spuren der Tat stehen als `spur:<id>` in `tatwissen`.
  - `ziel`: unentdeckt bleiben, ohne Unschuldige ins Unglück zu stürzen.

## Regeln für Tischgespräche und Befragungen (P-1 bis P-4, Modell befragung)
- **Tischgespräch:** genau eines je Rolle und Runde, `nr` 1.
  - `partner` ist eine andere Rolle, der Wunschpartner. Am Abend legt der Gesprächsplan (E-028, `Besetzung.gespraechsplan`) den tatsächlichen Partner fest: Ein besetzter Wunschpartner mit freier Last bleibt; sonst kommt der erste besetzte Ersatzpartner aus `besetzung.json` mit freier Last, sonst die besetzte Rolle mit der kleinsten Last.
  - `thema`: kurze Überschrift. `ziel`: ein kurzer Satz, nur für die eigene Rolle.
  - `stichpunkte`: zwei bis drei Zeilen zu je höchstens acht Wörtern (Kartenformat R17), Notizstil in der Ich- und Du-Form. Kein `text` mehr.
- **Befragung:** genau eine je Rolle und Runde, `bf_<rolle>_<runde>`.
  - `thema`: kurze Überschrift. `fragen`: zwei bis drei Fragen des Detektivs in der Du-Form, je höchstens zwölf Wörter, mit Fragezeichen.
  - `stichpunkte`: null bis zwei Zeilen eigene Würze der befragten Rolle, je höchstens acht Wörter, ohne neue Tatsache.
  - `preisgabe` enthält jedes eigene Tisch-Kettenglied, das eine Entscheidung ab dieser Runde braucht (I-B3), und darf weitere eigene Preisgaben tragen.
- **P-1, Preisgaben:** `preisgabe` enthält am Tisch wie in Befragungen nur zwei Arten von Verweisen, und jede Beobachtung gilt in allen Pfaden:
  - eigene Beobachtungen mit Kanal `pflichtgespraech`
  - eigene Lügen; gesagt wird nur die Behauptung
  - Nie Nebendelikte, verborgene Beobachtungen oder Spuren. Sonst schließt die Runde am Tisch zu früh aus.
  - Tisch-Kettenglieder stehen nur in Befragungen, nie im Tischgespräch: Der Detektiv sitzt nicht am Tisch.
- **P-2, partnerneutral und ohne unbesetzte Namen:** Kann der Partner ersetzt werden (jede Rolle außer Ahmet, Fatma, Olli und Can), nennen `thema`, `ziel` und `stichpunkte` ihn nicht, auch nicht als Anrede, und schreiben ihm nichts zu: keinen Beruf, keinen Ort, keine Verwandtschaft, keine Beobachtung. Die App zeigt den tatsächlichen Partner auf der Karte. Thema, Fragen und Stichpunkte einer Befragung und die Kurzfassungen ihrer Preisgaben nennen nur Figuren, die mit der befragten Rolle sicher besetzt sind: die Kernrollen, die Rolle selbst und Herrn Schneider.
- **P-3, eigenes Wissen:** Stichpunkte nutzen nur die eigene `preisgabe`, die eigene Vorstellung (`dossier.wer`) und was alle wissen (Intro: Knall, Dunkelheit, Herr Schneider bewusstlos im Vorratsraum, Bund weg, Tor zu). Nie, was andere Rollen beobachtet haben, und nie etwas Verborgenes. Fragen einer Befragung verraten keine Antwort und setzen kein verborgenes Wissen voraus.
- **P-4, Abwechslung:** Kein Text wiederholt einen anderen wortgleich, außer kurzen Standardfragen („Wo warst du, als es knallte?“). Jede Runde klingt nach ihrer Frage: Runde 1 Alibis, Runde 2 Widersprüche, Runde 3 Gegenüberstellung.
- Im **Modell legacy** (Gewölbe, Noir-Akten) gelten die alten Regeln: drei Pflichtgespräche je Rolle und Runde (`nr` 1 bis 3), `text` als ein bis drei Sätze Eröffnung, der Detektiv als Partner möglich, Höchstlast 7 je Rolle und 6 für den Detektiv.

## Regeln für die Rundenwahl
- `a` ist kooperativ und kostet die Rolle etwas (siehe `gruppenwahl.json` → `kosten`).
- `b` schützt Ziel oder Freund.
- `sabotage` gibt es nur bei Kernrollen (Täterfassung). Sie klingt für Außenstehende wie ein harmloses `b`.
- Je Option ein bis zwei Sätze in der Ich-Form.
