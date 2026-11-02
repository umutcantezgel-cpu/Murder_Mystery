# Entscheidungen für das Kammerspiel (verbindlich für alle Phasen)

Stand 2026-11-01. Quelle: Besitzer (AUFTRAG.md, Entscheidungen oben) und Designer-Entscheidungen auf Grundlage der
Berichte unter verstehen/ (kanon-olli.md, u4yrk-set.md, abgleich.md, generator.md, regeln.md, luecken.md).

## Vom Besitzer entschieden
- B1 Das Kammerspiel **ersetzt** das bisherige Druckspiel in der Druckmappe. Das App-Spiel bleibt unverändert.
- B2 **Fester Täter Olli** (Fall U4YRK).
- B3 Auslieferung über die **App-Druckmappe** und per Befehl; Probe-Sets 6/10/20 Personen an den Besitzer.

## Designer-Entscheidungen
- E1 **Bestandsschutz:** Alle bestehenden Dateien unter `content/` bleiben unverändert (App-Spiel, Goldens, Wächter).
  Kernpfad `Spiel(druck: true)`, Erzählerheft für Abende am Bildschirm, Festpaket, Steckbriefe bleiben. Das alte
  Druckspiel bleibt bis zur Abnahme durch den Besitzer per CLI-Schalter samt Tests erreichbar (A-2: Ersetztes bleibt
  bis zur Abnahme erreichbar); die Druckmappe bietet nur noch das Kammerspiel an. Goldens und `tool/kanon_fest.txt`
  nie anfassen.
- E2 **Eigene Druckquelle:** Die Kammerspiel-Welt hat eigene Inhaltsdateien (eigener Ordner, eigenes Schema), die nur
  der Druck liest. Sie weicht bewusst vom App-Kanon ab, wo der AUFTRAG es verlangt (Tim statt Wojtek bei Knall,
  Möbelwachs und Finger; Lejla, Marek, Joanna, Zeynep tragen die Beobachtungen der früheren Geister; Sicherungskasten
  im Durchgang). In allem anderen folgt sie dem Kanon (kanon-olli.md) – nichts Lösungsrelevantes neu erfinden, wo der
  Kanon schon eine Antwort hat. Baran und Pawel gibt es in der Kammerspiel-Welt nicht.
- E3 **Codes:** Die im AUFTRAG genannten U4YRK-Codes bleiben (Fassungen WW4 Ahmet, JM3 Fatma, RN7 Olli, YW4 Can;
  Indizkarten AD3…YT4 mit XD3 Kerzenständer, FN3 Ollis rechter Handschuh, PP9 Schlüsselbund im Eiskübel, JT3
  Leuchtmaske in Cans Bauchtasche, FK3 Zeyneps Aussage). Inhalte werden neu gefasst. Neue Kartenarten bekommen nur
  wo nötig neue Codes (Regeln in generator.md: kein Buchstabenpaar doppelt, keine alten Stimmkarten-/Umschlag-Paare).
- E4 **Ton:** Herr Schneider liegt „bewusstlos, mit einer dicken Beule“ (keine Platzwunde, kein Blut; TON-LEITFADEN).
  Er überlebt. Der Schlag bleibt Schatten und Geräusch. Alle Ton- und Inhaltsregeln aus regeln.md §6 und die Lösungen
  aus §9 gelten für jeden neuen Text (Getränke, keine Schlag-Verben wo verboten, Satzlängen, Namen wie Lejla/Joanna/
  Marek, Herkunft/Kopftuch nie Motiv, Spur oder Pointe).
- E5 **Deutsche Begriffe** in allen Spieltexten: „Lageplan“ (nicht Evidence Board), „Vorstellungsrunde“, „Sobald …“
  statt „Trigger“, „Geheimniskarte“, „Aktionskarte“, „Tipp-Zettel“. Die Spielleitung heißt „Erzähler“.
- E6 **Zählung:** Personen = Rollen + Detektiv + Erzähler. 6–20 Personen ⇒ 4–18 Rollen. Erzähler und Detektiv sind
  immer zwei verschiedene Personen. Rollen 1–10 wie im AUFTRAG; Zusatzrollen kommen paarweise in dieser Reihenfolge
  dazu: Tandem 1 Sibel & Damir, Tandem 2 Hana & Serkan, Tandem 3 Azra & Wojtek, Tandem 4 Aylin & Tugba (Plätze 11–18).
  Bei ungerader Zahl spielt die letzte Zusatzrolle ihr Tandem allein (Solo-Abschnitt im Heft).
- E7 **Abwesenheitsblatt:** Sobald eine der Rollen 5–10 unbesetzt ist. Ihre Aussagen liegen als verdeckte Streifen an
  ihren Orten auf dem Lageplan und werden nur durch eine Untersuchung oder Aktion aufgedeckt – nie offen von Anfang an.
- E8 **Geheimniskarten** haben eine neutrale Vorderseite (Name, „Geheimnis“). Die Bedingung, wann sie umgedreht
  wird, steht nur im Rollenheft.
- E9 **Gleiche Gestalt:** Die vier Verdächtigen haben gleich aufgebaute, gleich lange Rollenhefte und versiegelte
  Fassungen (Teil 11). Nur RN7 enthält die Tat und Ollis dritte Stufe; die drei anderen Fassungen haben eine
  gleichwertige dritte Stufe ohne Tat. Ollis Aktionskarte ist neutral benannt.
- E10 **Erzähler nicht allwissend:** Das Erzählerheft enthält keine Lösung und keine Stufe-2-Inhalte. Seine
  Moderationsimpulse sind spoilerfrei. Er gibt wie alle einen Tipp ab.
- E11 **Kopftuch-Regel** (`herkunft.dart:41-60`): Tugba bleibt ganz unbelastet; ihr Tandem-Geheimnis ist harmlos.
- E12 **Untersuchungen rundengebunden:** Die drei Untersuchungen je Runde kommen aus einem Vorrat je Runde, sodass
  XD3, FN3 und PP9 erst in späteren Runden möglich sind und der Fall nicht in Runde 1 fällt.
- E13 **Punkte:** Detektiv höchstens 9 Punkte nach Meilensteinen (AUFTRAG 4.5, ohne Pfad-Strafe). Tipp-Zettel für alle
  inkl. Erzähler: Täter 2, Versteck 1, persönliches Bonus-Ziel 2.
- E14 **Bonus-Ziele** werden fürs Kammerspiel neu gefasst, je Rolle mit prüfbarer Bedingung.
- E15 **Stil:** schlicht und druckfreundlich (schwarzweiß-tauglich), Lageplan als Doppelseite aus zwei A4-Blättern
  quer zum Aneinanderlegen. Probe-Sets nicht als Release-Dateien.
- E16 **Erzählerakte (Besitzer, 2026-11-01): aus der Druckmappe nehmen.** Der Block „Nur Erzähler“ entfällt im
  Kammerspiel, weil die Akte dem nicht-allwissenden Erzähler die Geheimnisse verrät. In der App (Erzählerplatz) und
  als `erzaehlerakte-dein-moment.pdf` am Release bleibt sie für Abende am Bildschirm; was mit `erzaehlerakte.pdf`
  („Ziele wie im Druckspiel“) am Release geschieht, klärt die Umsetzung (Release-Notiz/-Test anpassen). Behzads
  Anleitung (Schritt 6) wird danach angepasst.
- E17 **„Zum Drucken“** im Abend-Assistenten führt künftig zur Druckmappe; die App begleitet das Kammerspiel nicht.

Entscheidungen bei der Umsetzung der Druckteile (2026-11-02), zur Kenntnis des Besitzers:

- E18 **Erzählerheft immer 16 Seiten.** MECH 10.1 schätzte 15 / 16 / 17. „Was alle wissen“ steht fest auf Seite 7
  (MECH 9.1, 9.6) und „Karten unter den Streifen“ auf Seite 16 (MECH 9.14); ohne leere Füllseiten ergibt das bei jeder
  Besetzung 16 Seiten. Die Tischregeln stehen auf Seite 14 statt 3, weil Seite 3 mit Ablauf und Rundenaufbau voll ist.
- E19 **Schriftgrößen.** Lesetext nie unter 9 pt. Darunter liegen nur Beschriftungen: Kopf, Fuß und Marken („VORLESEN“)
  in 8,5 pt, die Falzmarke „Hier falten“ (auf den Zeugenstreifen „Hier nach hinten falten, Etikett bleibt oben“, P5R3-06) in 6,5 pt
  (am Falz sind nur 1,6 mm Luft, MECH 5.2) und Joannas Notiz in 8 pt.
  Die Rollenhefte nutzen 10 mm Rand (Druckrand 5 mm bleibt gewahrt), damit die Bibel-Längen in die festen Seitenzahlen passen.
- E20 **„Detektiv“ und „Erzähler“ sind Rollenbegriffe.** Regeltexte, Kartenköpfe („heute beim Detektiv“), „Was alle
  wissen“ (MECH 1.5 wörtlich) und die Bedingung der Stufe 3 in Teil 11 bleiben bei der Rolle. Nach `--detektiv w|m`
  richten sich die Anrede, der Detektivbogen (Teil 01) und Beschriftungen wie die Teileliste.
- E21 **Tandem-Kasten immer.** Jedes Zusatzheft trägt den Kasten „Dein Tandem“ (fehlt der Partner, in der Ersatzfassung,
  ZR 0.7, ZR 1.12); der Solo-Abschnitt steht zusätzlich nur beim Platz, der heute allein spielt.
- E22 **Rollenhefte der Verdächtigen:** Stufe 2 steht auf Seite 3 vor den Gesprächsaufträgen, „Was du über andere sagen
  darfst“ auf Seite 4; so steht alles in 10,5 pt, die Reihenfolge von RK 1.1 bleibt. Fehlende Ziele erscheinen nur als
  Ausweichziel, nie mit dem Namen der fehlenden Rolle.
