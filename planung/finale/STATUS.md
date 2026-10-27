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
| 4 | App offline/online, Raum/Server/Matrizen für Einfluss, Druck und CLI | offen |
| 5 | Review, Simulation und Feinabstimmung, Doku, Browserproben | offen |
| 6 | `pruefen.sh ci`, Push, CI grün | offen |

## Wiederaufnahme nach der Pause (Besitzerwunsch: zwei Stunden Pause, sobald die laufenden Agenten fertig sind)

- Workflows wurden nach den laufenden Agenten gestoppt (Erzähl-Inhalte `wf_fae96c20-06b`, Kern `wf_cc821ccf-a7c`).
  Ergebnisse der fertigen Agenten liegen in `berichte/`. Fortsetzen mit `resumeFromRunId` (gleiche Session) oder neu
  aufsetzen: Erzähl-Inhalte ab „schreiben:akte-b“ und den Prüfungen; Kern ab „zusammenfuehren“.
- Entscheidungen nach der Inhaltsprüfung stehen in SPEZIFIKATION „Änderungen“ (Punkte 1–11).

## Prüfjournal (neueste zuerst)

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
