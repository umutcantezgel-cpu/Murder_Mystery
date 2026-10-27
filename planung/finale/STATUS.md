# Finale Schlosskeller · STATUS

Plan: [PLAN.md](PLAN.md) · Spezifikation: [SPEZIFIKATION.md](SPEZIFIKATION.md) · Branch: `claude/schlosskeller-finale`
(von `main` `ca53adf`). Bei Wiederaufnahme zuerst diese Datei und `git log --oneline -15` lesen.
Entscheidungen A-063 bis A-067 (`planung/gesamt/STATUS.md`), E-046/E-047, R18–R25, K-27–K-31.

## Stufen

| Stufe | Inhalt | Stand |
|---|---|---|
| 0 | Branch, CI-Trigger, Werkzeug, Basislauf, Entscheidungen | fertig |
| 1 | Inhalte: Faktenblatt, Vorgeschichte, Vorstellungen, Erzählerakte, Einfluss-Texte (Entwürfe in `entwurf/`) | läuft |
| 2 | Kern: N1 Einstimmung + Erzählerakte, E1a Schnappschuss + Einfluss-Regeln, E1b Haken + Beweise, Zusammenführung | läuft |
| 3 | Inhalte einspielen (`setting.json`, Texte, `erzaehlerakte.json`, `einfluss.json`, `akten.json`), `kanon_tor` | offen |
| 4 | App offline/online, Raum/Server/Matrizen für Einfluss, Druck und CLI | offen |
| 5 | Review, Simulation und Feinabstimmung, Doku, Browserproben | offen |
| 6 | `pruefen.sh ci`, Push, CI grün | offen |

## Prüfjournal (neueste zuerst)

- 2026-10-27 Basislauf auf `ca53adf` (`bash tool/pruefen.sh schnell`): grün. Krimidinner 67, Kern 793 (+1 übersprungen),
  Klang 4, Netz 52, Kanon-Tor aktuell.
