# Finale Schlosskeller · STATUS

Plan: [PLAN.md](PLAN.md) · Spezifikation: [SPEZIFIKATION.md](SPEZIFIKATION.md) · Branch: `claude/schlosskeller-finale`
(von `main` `ca53adf`). Bei Wiederaufnahme zuerst diese Datei und `git log --oneline -15` lesen.
Entscheidungen A-063 bis A-067 (`planung/gesamt/STATUS.md`), E-046/E-047, R18–R25, K-27–K-31.

## Stufen

| Stufe | Inhalt | Stand |
|---|---|---|
| 0 | Branch, CI-Trigger, Werkzeug, Basislauf, Entscheidungen | fertig |
| 1 | Inhalte: Faktenblatt, Vorgeschichte, Vorstellungen, Erzählerakte, Einfluss-Texte (Entwürfe in `entwurf/`) | fertig: alle Entwürfe geschrieben und geprüft (Berichte in `berichte/`) |
| 2 | Kern: N1 Einstimmung + Erzählerakte, E1a Schnappschuss + Einfluss-Regeln, E1b Haken + Beweise, Zusammenführung, Abstimmung | fertig: zusammengeführt in f057a49 (Kern 957 grün, akte_pruefen 5 × 0, Golden k12 und Schnappschuss unverändert) |
| 3 | Inhalte einspielen (`setting.json`, Texte, `erzaehlerakte.json`, `einfluss.json`, `akten.json`), `kanon_tor` | fertig: eingespielt, `akte_pruefen` 5 × 0, Änderung 7 im Kern (Spezifikation „Änderungen“ 25–28) |
| 4 | App offline/online, Raum/Server/Matrizen für Einfluss, Druck und CLI | fertig: E2 (Protokoll 5, Raum, Server, Matrizen) und N2 (Druck, `--erzaehlerakte`) zusammengeführt in 345018c, A-N und A-E in 088831b/d48ae60, Solo-Browserprobe 501d8e6; App 812 grün, `pruefen.sh ci` lokal grün |
| 5 | Review, Simulation und Feinabstimmung, Doku, Browserproben | fertig bis auf die Sichtprüfung durch Menschen: Prüfung nach der App-Zusammenführung (17 Befunde behoben, Änderungen 29–36), Abstimmung am Bot-Tisch (E-048, Änderungen 20–23), Doku in a5f4d7f (ANLEITUNG §4–§7, Druckspiel, README, Änderungen 37–43), nach dem Container-Neustart FUER-DEN-NUTZER (Abschnitt „Finale“), TON-LEITFADEN (A-061) und `planung/langer-abend/STATUS.md` Zeile M12; Solo-Browserprobe mit beiden Schichten in 501d8e6 (vor der Befundbehebung); Browserprobe des Finales auf dem Stand nach der Befundbehebung erledigt (`tool/e2e/finale.mjs`: Einstimmung und „Dein Moment“ über die Entwicklerroute `einfluss=1`, grün, 44 Fotos gesichtet; Prüfjournal 2026-10-28); die lange Probe läuft noch ohne Schicht (kein `einfluss=1`) |
| 6 | `pruefen.sh ci`, Push, CI grün | teilweise: gepusht bis a5f4d7f; CI-Lauf 110 auf 0ec85ba grün (120-Minuten-Limit, A-067); Lauf 111 auf a5f4d7f (Befundbehebung und Doku) am 2026-10-28 gestartet, Ergebnis offen; `pruefen.sh ci` lief lokal nach der Befundbehebung nicht (nur `schnell`), das volle Tor ist Lauf 111 |

## Wiederaufnahme

- Stand (2026-10-28): Stufen 0–5 fertig bis auf die Sichtprüfung durch Menschen, gepusht bis ef214ff. Ungepusht sind
  der Commit mit der Browserprobe des Finales (Entwicklerroute `einfluss=1`, `tool/e2e/finale.mjs`) und drei
  Politur-Commits aus der Fotosichtung (Spürnasen in einem Baustein, Damirs Randnotiz, Protokoll der Nacht;
  „Änderungen“ 44–46, Prüfjournal 2026-10-28).
- Nächste Schritte: Solo-Browserprobe auf dem aktuellen Stand (Web-Build wie in `tool/e2e/README.md`, dann in
  `tool/e2e` `node solo.mjs --nur320`) und CI-Lauf 111 auf a5f4d7f beobachten; danach den Commit der Finale-Probe
  pushen (er ändert `lib/`, `test/` und `tool/` und löst einen CI-Lauf aus). Vor einer Zusammenführung nach `main` den
  Besitzer fragen.
- Berichte der Workflows in `berichte/`: Erzähl-Inhalte `wf_fae96c20-06b`, Einfluss-Texte `wf_71d4acb7-589`, Kern
  `wf_cc821ccf-a7c`, App/Netz/Druck `wf_b7937080-d6e`. Alle Entscheidungen seit dem Plan stehen in SPEZIFIKATION
  „Änderungen“ (1–46).
- Was nur Menschen prüfen können: `planung/finalisierung-schlosskeller/FUER-DEN-NUTZER.md`, Abschnitt „Finale
  (A-063 bis A-067)“.

## Prüfjournal (neueste zuerst)

- 2026-10-28 Stufe 5, Politur aus der Fotosichtung der Browserprobe (drei Commits, Spezifikation „Änderungen“ 44–46):
  (1) Spürnasen in einem Baustein: eine wie bisher `einfluss.preis.spuernase`, mehrere als Namensliste
  `einfluss.preis.spuernasen` („Spürnasen der Nacht sind @liste und @letzte. …“, Komma zwischen den Namen, „und“ im
  Text); Kern `Erzaehler.einflussAufloesung`, `einflussListenBaustein`, `Texte.baustein`/`einflussText(figuren:)`,
  Katalog 293, Prüfer-Platzhalter; Gerät, Gast und Raum zeigen dieselbe Tafel (Tests in `einfluss_ende_test`,
  `einfluss_regeln_test`, `einfluss_pruefung_test`, `schlosskeller_raum_einfluss_test`, `einfluss_sitzung_test`).
  (2) Damirs Randnotiz: `e1_1_damir` zeigt `b_pawel_schneider` statt `b_damir_an_der_theke` (Damir erzählt sie in
  Runde 1 selbst; seine übrigen Beobachtungen gelten nicht in allen Pfaden). Pawels Wissen gilt in allen Pfaden,
  belastet niemanden, steht in keiner Begründungskette, ist sonst erst ab 19 Rollen zu hören; geprüft gegen die
  Story-Bibel; Test: die Notiz stammt nicht von Damir. (3) Protokoll der Nacht: Name und Sinnbilder oben auf einer
  Linie, Zielfoto darunter in derselben Zeile, Abstand für den Schatten; neuer Widget-Test `protokoll_nacht_test`
  (320/390 px × 100/200 %, Rechtecke der Zeilen); dabei behoben: „Zusammenhalt“ lief in den Leisten bei 320 px und
  200 % 15 px über den Rand. `einfluss_soll.g.dart` nach E-048 zweimal neu erzeugt, je mit Gegenprobe: (1) 686 der
  1.000 Summen ändern sich, genau die Abende mit mehr als einer Spürnase (nachgezählt), mit zurückgenommener Zeile in
  `einflussAufloesung` passt die vorige Liste; (2) 457 Summen ändern sich, alle an Abenden mit der Wahl `e1_1_damir`,
  mit zurückgenommener Zeile in `einfluss.json` passt die vorige Liste. `kanon_tor` neu erzeugt (Prüfsummen,
  Inhaltskennung), `akte_pruefen` 5 × 0, `flutter analyze` sauber, App `flutter test --concurrency=2` 831 grün,
  `pruefen.sh schnell` grün (Kern 999 +1 übersprungen, Krimidinner 67, Klang 4, Netz 54, Kanon-Tor aktuell,
  CI-Helfer 18, Secret-Scan sauber). Golden k12 (`determinismus_soll*.g.dart`) und `andere_akten_soll.g.dart`
  unverändert, nichts aus `tool/kanon_fest.txt` berührt. Aus der Sichtung weiter offen für Menschen: je Baustein ein
  Schalter „Erzählerstimme“, drei gleich gebaute Epiloge, „Ostsaal“ neben „Ost-Saal“; außerdem wiederholen weitere
  Befragungs-Optionen die Beobachtung der befragten Figur als Randnotiz (`e1_2_emine`, `e1_3_azra`, `e3_3_aylin`
  immer; `e1_3_tim`, `e1_2_tugba` bei besetzter Figur) – nicht geändert, Entscheidung offen.

- 2026-10-28 Stufe 5, Browserprobe des Finales auf dem Stand nach der Befundbehebung (nach dem Container-Neustart
  fortgesetzt). Entwicklerroute `einfluss=1` (`lib/party/skript.dart`, `party_seite.dart`; ohne den Parameter
  unverändert): Mit Skript zieht jede Rolle ihren Moment verdeckt als Bot-Zug (`momentBotZug`, Fotostelle
  `moment_r<n>`), zu Beginn der Ermittlung werden die Folgen gelesen (`folgen_r<n>`), eine endgültige Wahl mit
  Tischwert heißt `endgueltig_<entscheidung>_abzeichen`, vor der Anklage nutzt es eine offene Nachfrage (`nachfrage`);
  `bis=` zieht die Bots ohne Fotostellen. Widget-Test `test/party_widgets/einfluss_skript_test.dart` (3 Tests), Probe
  `tool/e2e/finale.mjs` (nur in `pruefen.sh e2e`, Laufzeit). Web-Build frisch, Probe grün in 574 s: ahmet, n = 5,
  `ende_meister`, 9 Punkte, Einstimmung, drei Momente mit Folgen, Abzeichen bei e1_1, e1_3 und e2_2, Nachfrage
  genutzt, keine Gruppenwahl, 44 Fotos, Auflösung bis zum Endwert im Bild, 0 Konsolenfehler, 0 fremde Netzaufrufe.
  Probe nachgebessert: Vergleich der Ansichten ohne den ausblendenden Rollbalken (je Bildschirm ein doppeltes
  Schlussfoto), Fotopause 18 s statt 5 s (nach jedem Mausradschritt rendert die Ansicht rund 1,5 s; vorher blieben
  Auszeichnungen, Sterne, Tipps und Endwert der Auflösung und das Ende der Folgen-Tafel ungesehen), Sprung ans Ende,
  wenn die Pause nicht reicht, neue Prüfung „Auflösung bis zum Ende im Bild“, Mausrad am linken Rand (ein Tooltip der
  Erzählerstimme stand im Foto). Sichtung aller Fotos (Vorgeschichte, Vorstellung, Gespräche mit Moment-Liste, Moment,
  Folgen, neun Rückfragen, drei mit dem Abzeichen „Störung −1“, Resümees mit Leisten und „Jetzt sichtbar“, Nachfrage,
  Auflösung, Ende): nichts abgeschnitten, keine Überlappung außer den gewollten Rückfragen über der Karte, keine
  leeren Karten, keine englischen Reste oder Platzhalter, Namen richtig. Offen für Menschen (Ton und Gestaltung, kein
  Fehler im Code): in der Auflösung je Baustein ein eigener Schalter „Erzählerstimme“ (mit „Dein Moment“ rund 20,
  Aufbau von `main`); vier gleich gebaute Karten „Eine Spürnase der Nacht ist …“; drei Epiloge nacheinander „… hat in
  dieser Nacht nicht alles verloren, was er/sie schützen wollte“; Damirs Randnotiz der Nachfrage wiederholt fast
  wörtlich, was er in Runde 1 erzählt; „Ostsaal“ (`raeume.json`, schon auf `main`) neben „Ost-Saal“ in den Texten.
  `flutter analyze` sauber, `test/party_widgets` 544 grün.

- 2026-10-28 Doku nachgezogen: `planung/finalisierung-schlosskeller/FUER-DEN-NUTZER.md` neuer Abschnitt „Finale (A-063
  bis A-067)“ (Ton der Einstimmung, Zahlen von „Dein Moment“ am echten Tisch, Kern-Epiloge, 320 px, Porträts im Druck,
  Sensibilität, Ungleichgewichte und Widerspruch im Kanon, Protokoll 5, alte Abende, Zusammenführung nach `main`), dazu
  drei Geburtstags-Reste dort ersetzt; `TON-LEITFADEN.md` §1 und §3 nach A-061 (Wiedersehen der Clique, der Detektiv
  als Gast; Regeln unverändert); `planung/langer-abend/STATUS.md` Zeile M12 und Journal. Nur Doku, kein Test nötig.

- 2026-10-28 Container-Neustart: Prüf-Workflow abgebrochen, Befundbehebung (18 Commits) und Doku erhalten, gepusht in
  a5f4d7f; CI-Lauf 110 auf 0ec85ba grün, Lauf 109 scheiterte nur an zwei Analyse-Warnungen (behoben in 345018c).

- 2026-10-27 Stufe 5, Doku: `docs/ANLEITUNG.md` §4 (Schalter „Vorgeschichte und Vorstellung“ und „Dein Moment“,
  Länge, Zeitschätzung), §5 (neu 5.4 Einstimmung und Erzählerakte; Moment reihum und online), §6 (Einstimmung vor
  Vorspiel und Intro, Runde mit „Dein Moment“: Züge, Folgen, Tischwerte, Würfel, Leisten, Ereignisse, Flüstern,
  Nachfragen), §7 (Endwert, Geklärt-Regel, Auflösung, Auszeichnungen, Erfahrung); dabei den veralteten Satz „wird nicht
  gespeichert“ in §5 und §10 an „Abend fortsetzen“ angeglichen. `docs/partykrimi/ANLEITUNG.md` (ohne „Dein Moment“,
  Erzählerheft mit Einstimmung, Erzählerakte, `--paket`, `--erzaehlerakte`, `--dein-moment`), README (neue
  Funktionen, Protokoll 5), Spezifikation „Änderungen“ 37–43 (a5f4d7f). FUER-DEN-NUTZER, TON-LEITFADEN und die Zeile
  M12 waren hier noch nicht dabei; sie folgten nach dem Container-Neustart (Eintrag oben). Nur Doku, kein Test nötig.

- 2026-10-27 Behebung der Prüfbefunde nach der App-Zusammenführung (17 Befunde, offene Punkte a–c), Spezifikation
  „Änderungen“ 29–36: Pult zu beim Weitergeben, verzögerte und ausgepackte Fakten im Notizbuch, Fledermaus ohne zweite
  Randnotiz, Erzählerakte folgt dem Abend (Druck standardmäßig Kanon-Ziele, `--dein-moment`), Zug-Tafel am
  Erzähler-Handy, Bot-Geheimnis über Nebendelikt-Fakten, `einfluss.offen` im Raum, Erfahrung aus „Dein Moment“
  verbucht, Namen im Aufruf, kein leeres Gruppenfach, Gasttext ohne Gruppenwahl, Texte (Kern-Epiloge, warmer Morgen,
  Sammelblock, Stern des Abends), erstes Geflüster, Zählung der Auflösung, keine Spürnase für die Täterrolle,
  U+2212 (alle neun Schriften führen es). `einfluss_soll.g.dart` nach E-048 dreimal neu erzeugt (Änderungen 33–35),
  je mit Gegenprobe: mit zurückgenommener Kernänderung passt die vorige Liste. `flutter analyze` sauber, App
  `flutter test` 824 grün, `pruefen.sh schnell` grün (Kern 996 +1 übersprungen, Krimidinner 67, Netz 54, Klang 4),
  `kanon_tor --pruefen` aktuell, `akte_pruefen` 5 × 0. Golden k12 (`determinismus_soll*.g.dart`) und
  `andere_akten_soll.g.dart` unverändert.

- 2026-10-27 CI (0ec85ba, A-067): Lauf 105 brauchte 47,5 von 50 Minuten, Lauf 106 brach am Limit ab. Der Prüf-Job hat
  jetzt 120 Minuten; die Gesamtprüfung mit Einstimmung und „Dein Moment“ dauert lokal rund 75 Minuten.

- 2026-10-27 Stufe 4, App zusammengeführt (`berichte/wf_b7937080-d6e.json`, „zusammenfuehren-2“): `finale/a-n`
  (088831b, ohne Konflikt) und `finale/a-e` (d48ae60, Konflikte gelöst), danach Solo-Browserprobe 501d8e6.
  `flutter analyze` sauber, App `flutter test` 812 grün (695 Basis, A-N, A-E, 8 neue: `einstimmung_moment_test` 4,
  `gast_einstimmung_moment_test` 3, `rollen_uebersicht_test` +1), gezielt nach dem Merge 103/103.
  `bash tool/pruefen.sh ci` EXIT 0: Pakete 67 + 992 (+1 übersprungen) + 4 + 54, Kanon-Tor, CI-Helfer,
  Szenario-Validator, Simulator, Server-Smoke, Party- und Relais-Matrix mit 4 Clients, nativer Server, Flutter 812,
  Web-Build, Browserproben (`browser_test` 4/4, START, RUNDEN, SOLO bei 320 px mit Einstimmung und „Dein Moment“,
  LANG endet wie kurz), Secret-Scan. `akte_pruefen` 5 × 0. Golden k12, `andere_akten_soll.g.dart`,
  `einfluss_soll.g.dart` unverändert, kein Diff in `packages/`, `content/`, `server/`.
  - A-N (`finale/a-n` ad6872a): App 723 grün; `einstimmung_test` 8, `erzaehlerakte_test` 6,
    `gast_einstimmung_test` 7, `gast_erzaehlerakte_test` 3, `erzaehler_begleiter_test` 12, `rollen_uebersicht_test` 4,
    `assistent_test` und `arb_ton_test` grün; Kern-Wächter 13 grün.
  - A-E (`finale/a-e` b14cb53): App 776 grün; `einfluss_sitzung_test` 18, `heimlicher_zug_test` 9 (320/390 px,
    100/200 % Schrift), `gast_moment_test` 6, `lang_invarianz_test` 101 (48 neue Kombinationen mit Schicht),
    `test/abend` 126; keine Änderung an `packages/`, `content/`, `tool/`, `server/`.

- 2026-10-27 Stufe 4, Netz und Druck zusammengeführt (`berichte/wf_b7937080-d6e.json`, „zusammenfuehren-1“, 345018c):
  `finale/e2` (423597e) und `finale/n2` (5ab9dae) mit `--no-ff`, ohne Konflikt; danach Texte (Ablenken Lejla,
  Ertappt-Blasen der Kernfiguren ohne Anklang an Fallspuren, Marke „nur dir bekannt“) und ein überflüssiges `!` im
  Erzählerheft. `akte_pruefen` 5 × 0, `kanon_tor --pruefen` grün (42 Bildprompts, 17 eingebettete Dateien),
  Party-Matrix (6 Sitz-Konstellationen, darunter „Dein Moment“ und Einstimmung mit Text nur beim Vorleser) und
  Relais-Matrix (6 Läufe plus Ausfall des Gast-Detektivs) mit 4 Clients grün, Netz 54 (darin `relay_finale_test`),
  Server 4, Druck 64 (`druck_paket`, `druck_paket_cli`, `druck_spielleitung`, `einfluss_zielquelle`,
  `erzaehlerakte`). `--erzaehlerakte --personen 8`: 24 Seiten, 185 KB; `--paket --n 8`: Erzählerheft 13 Seiten mit
  Vorgeschichte und Vorstellung, Veranstalter-PDF 3 Seiten, Erzählerakte in `4-nur-erzaehler`.
  `pruefen.sh schnell` grün in 6:19 (Kern 992 +1, Krimidinner 67, Klang 4, Netz 54, CI-Helfer 18), App 695 grün.
  Golden-Dateien unverändert, nichts aus `tool/kanon_fest.txt` berührt.

- 2026-10-27 Stufe 3, Inhalte eingespielt: `setting.json` (Vorgeschichte, Vorstellung), Texte Vorgeschichte, Vorstellung und
  Einfluss (Index 58 → 61), Kapiteltitel in `ui-erzaehler.json`, `erzaehlerakte.json` (50 Kanten), Fähigkeiten
  `einstimmung`, `erzaehlerakte`, `einfluss`; Geburtstags-Rest in `geruechte.json` ersetzt. Kern: Titel der Vorstellung,
  `einfluss.wieder` im Zwischenresümee, `einfluss_soll.g.dart` nach E-048 neu (Ursache allein Änderung 7, gegengeprüft).
  `akte_pruefen` 5 × 0, `kanon_tor --pruefen` grün, `pruefen.sh schnell` grün (Kern 958 +1 übersprungen, Netz 52,
  Krimidinner 67, Klang 4), App `flutter test` 695 grün. Golden k12 und `andere_akten_soll.g.dart` unverändert
  (`einfluss_gating_test` grün, auch für den Schlosskeller: Setting und Gerüchte gehen nicht in den Schnappschuss ein).

- 2026-10-27 Kern zusammengeführt und abgestimmt (`finale/zusammen` 9d64599, `finale/abstimmung` db86db2, Arbeitsbranch f057a49):
  `pruefen.sh schnell` grün (Kern 955 +1 übersprungen, Netz 52, Krimidinner 67, Klang 4), nach der Abstimmung Kern 957; Ziele 23–82 %,
  Nachfragen Ø 1,1–1,3, Meister je Pfad gleich. Golden k12 und `andere_akten_soll.g.dart` unverändert.

- 2026-10-27 Kern-Agenten fertig: N1, E1a, E1b je „alles grün“, Golden k12 unverändert, Schnappschuss
  `andere_akten_soll.g.dart` vor der Schicht erzeugt (E1a). Einzelheiten in `berichte/wf_cc821ccf-a7c.json`.

- 2026-10-27 Basislauf auf `ca53adf` (`bash tool/pruefen.sh schnell`): grün. Krimidinner 67, Kern 793 (+1 übersprungen),
  Klang 4, Netz 52, Kanon-Tor aktuell.
