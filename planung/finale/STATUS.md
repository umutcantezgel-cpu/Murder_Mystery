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
| 5 | Review, Simulation und Feinabstimmung, Doku, Browserproben | fertig bis auf die Sichtprüfung durch Menschen und eine Browserprobe auf dem Stand nach der Befundbehebung: Prüfung nach der App-Zusammenführung (17 Befunde behoben, Änderungen 29–36), Abstimmung am Bot-Tisch (E-048, Änderungen 20–23), Doku in a5f4d7f (ANLEITUNG §4–§7, Druckspiel, README, Änderungen 37–43), nach dem Container-Neustart FUER-DEN-NUTZER (Abschnitt „Finale“), TON-LEITFADEN (A-061) und `planung/langer-abend/STATUS.md` Zeile M12; Solo-Browserprobe mit beiden Schichten in 501d8e6 (vor der Befundbehebung); die lange Probe läuft noch ohne Schicht (kein `einfluss=1`) |
| 6 | `pruefen.sh ci`, Push, CI grün | teilweise: gepusht bis a5f4d7f; CI-Lauf 110 auf 0ec85ba grün (120-Minuten-Limit, A-067); Lauf 111 auf a5f4d7f (Befundbehebung und Doku) am 2026-10-28 gestartet, Ergebnis offen; `pruefen.sh ci` lief lokal nach der Befundbehebung nicht (nur `schnell`), das volle Tor ist Lauf 111 |

## Wiederaufnahme

- Stand (2026-10-28): Stufen 0–5 fertig bis auf Sichtprüfung und Browserprobe, gepusht bis a5f4d7f. Ungepusht ist
  nur der Doku-Commit mit FUER-DEN-NUTZER, TON-LEITFADEN, M12 und diesem Stand.
- Nächste Schritte: Solo-Browserprobe auf dem aktuellen Stand (Web-Build wie in `tool/e2e/README.md`, dann in
  `tool/e2e` `node solo.mjs --nur320`) und CI-Lauf 111 auf a5f4d7f beobachten; danach den Doku-Commit pushen (er ändert
  nur `planung/` und löst wegen `paths-ignore` keinen CI-Lauf aus). Vor einer Zusammenführung nach `main` den Besitzer
  fragen.
- Berichte der Workflows in `berichte/`: Erzähl-Inhalte `wf_fae96c20-06b`, Einfluss-Texte `wf_71d4acb7-589`, Kern
  `wf_cc821ccf-a7c`, App/Netz/Druck `wf_b7937080-d6e`. Alle Entscheidungen seit dem Plan stehen in SPEZIFIKATION
  „Änderungen“ (1–43).
- Was nur Menschen prüfen können: `planung/finalisierung-schlosskeller/FUER-DEN-NUTZER.md`, Abschnitt „Finale
  (A-063 bis A-067)“.

## Prüfjournal (neueste zuerst)

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
