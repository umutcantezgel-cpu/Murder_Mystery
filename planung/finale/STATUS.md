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
| 6 | `pruefen.sh ci`, Push, CI grün, `main` | fertig: Randnotizen angeglichen (89e9eef, CI grün), nach `main` zusammengeführt (bc29db4), CI auf `main` grün, Release `mordakte-115.1` ist „latest“ (APK, IPA, Web). Pages-Job rot, weil GitHub Pages im Repo nicht aktiviert ist (einmaliger Schalter des Besitzers, README) |

## Wiederaufnahme

- Stand (2026-10-28): Stufen 0–6 fertig bis auf die Sichtprüfung durch Menschen, gepusht bis 9eb5baf (CI-Lauf 113
  grün). Ungepusht ist Politur 4 (Randnotizen aller Befragungen, „Änderungen“ 47, Prüfjournal 2026-10-28); der Push
  ändert `content/` und `packages/` und löst einen CI-Lauf aus.
- Nächste Schritte: Politur 4 pushen und den CI-Lauf beobachten. Vor einer Zusammenführung nach `main` den Besitzer
  fragen. Ab der Zusammenführung wird `einfluss_soll.g.dart` nie mehr neu geschrieben (E-048, Nachtrag).
- Berichte der Workflows in `berichte/`: Erzähl-Inhalte `wf_fae96c20-06b`, Einfluss-Texte `wf_71d4acb7-589`, Kern
  `wf_cc821ccf-a7c`, App/Netz/Druck `wf_b7937080-d6e`. Alle Entscheidungen seit dem Plan stehen in SPEZIFIKATION
  „Änderungen“ (1–47).
- Was nur Menschen prüfen können: `planung/finalisierung-schlosskeller/FUER-DEN-NUTZER.md`, Abschnitt „Finale
  (A-063 bis A-067)“.

## Prüfjournal (neueste zuerst)

- 2026-10-28 Abschluss: Besitzer entschied „Jetzt nach main“ und „Randnotizen angleichen“. 89e9eef (sieben
  Befragungen mit neuen pfadgleichen Randnotizen, letzte Neuerzeugung von `einfluss_soll.g.dart` nach E-048, Gegenprüfung
  ohne Befund) mit CI grün; danach `main` ca53adf → bc29db4 (Merge-Commit, ohne Konflikt). CI-Lauf auf `main` grün in
  Prüfung, Android, iOS, Web und Release; `mordakte-115.1` ist „latest“. Ab jetzt gilt für `einfluss_soll.g.dart` „nie neu
  schreiben“ (E-048). Offen bleiben nur die Punkte für Menschen in FUER-DEN-NUTZER („Finale“) sowie das Aufräumen der
  Hilfsbranches `finale/*` und das Aktivieren von GitHub Pages durch den Besitzer.

- 2026-10-28 Stufe 5, Politur 4 (Besitzer „Ja, angleichen“, Spezifikation „Änderungen“ 47): Die Randnotizen aller
  acht Befragungen bringen Neues. Alle 19 Optionen von `einfluss.json` geprüft (Pflichtgespräch in
  `beobachtungen.json`, Preisgabe in `befragungen-r1..3`, Erzählerwissen, Fakten der Option): Außer den fünf bekannten
  wiederholten auch `e1_1_joanna` (Fotonotiz wortgleich mit dem Fund) und `e3_3_zeynep` (Notiz ist die Quelle des
  Funds) nur Bekanntes. Neu: Joanna `b_pawel_schneider` (wie Damir), Emine und Tugba `b_serkan_tor`, Tim und Azra
  `b_tugba_notiz`, Zeynep und Aylin `b_tim_gesicht`; Begründung im `hinweis` von `einfluss.json`, geprüft gegen die
  Story-Bibel je Pfad. Doppelte nur innerhalb einer Entscheidung, damit „Redselig“ nie leer ausgeht, weil eine frühere
  Wahl die Notiz schon zeigte (Vergleich am Bot-Tisch über die 1.000 Abende von `einfluss_soll`: `b_pawel_schneider`
  bei `e3_3_aylin` bliebe in 55 von 506 Wahlen leer). Such-Optionen: Keine zeigt eine Notiz der durchsuchten Figur.
  Neuer Test in `einfluss_suche_test` für alle Befragungen (schlägt mit den alten Daten fehl); App-Tests erwarten
  keine der geänderten Notizen wörtlich, keiner musste angepasst werden. `einfluss_soll.g.dart` nach E-048 zum letzten
  Mal vor der Zusammenführung nach `main` neu erzeugt: 695 der 1.000 Summen ändern sich, genau die Abende, an denen
  eine der sieben Optionen eine Randnotiz zeigte (redselig oder Nachfrage, mit alten oder neuen Daten; nachgezählt);
  Gegenprobe mit zurückgenommenem `einfluss.json`: vorige Liste passt (0 Abweichungen). ENTSCHEIDUNGSLOG E-048
  ergänzt: ab der Zusammenführung nach `main` nie mehr neu geschrieben. `kanon_tor` neu erzeugt (Inhaltskennung),
  `akte_pruefen` 5 × 0, `flutter analyze` sauber, App `flutter test --concurrency=2` 831 grün, `pruefen.sh schnell`
  grün (Kern 1000 +1 übersprungen, Krimidinner 67, Klang 4, Netz 54, Kanon-Tor aktuell, CI-Helfer 18, Secret-Scan
  sauber), `kanon_tor --pruefen` aktuell. Golden k12 (`determinismus_soll*.g.dart`) und `andere_akten_soll.g.dart`
  unverändert, nichts aus `tool/kanon_fest.txt` berührt. Offen für Menschen: `b_tim_gesicht` ist ab 7 Rollen oft schon
  aus Tims Gespräch oder dem neutralen Bonus der Runde 1 bekannt; bei Aylin passt sie nur zur Frage, nicht zum Beleg;
  Zeugen aus dem Bezug einer Suche (Hana, Sibel, Wojtek, Baran) zeigen dort weiter ihre eigene Beobachtung.

- 2026-10-28 Stufe 6: CI-Läufe 112 (fd1c2f8, Browserprobe) und 113 (d49dc97, Politur) grün; Lauf 113 in allen Jobs
  grün und Vorab-Release `mordakte-113.1` (mordakte.apk, mordakte-ios-unsigned.ipa, mordakte-web.zip, SHA256SUMS.txt).
  Der Sicherungsbranch `finale/browserprobe-wip` und die Hilfsbranches `finale/*` liegen noch auf GitHub; Löschen und
  Abbrechen von Läufen verweigert die Umgebung (Proxy bzw. 403), der Besitzer kann sie entfernen.

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
