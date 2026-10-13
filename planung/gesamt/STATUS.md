# Mordakte 1.0 „Großer Fall“ · STATUS

Branch `claude/beautiful-meitner-fh1mkq` · Plan: `planung/gesamt/PLAN.md` (Bestand erweitern und finalisieren, Zug 1.0 → 1.1 → 1.2).

## Meilensteine 1.0
| M | Inhalt | Stand |
|---|---|---|
| M0 | Aufräumen + Werkbank | erledigt (siehe unten) |
| M1 | Ermittlungsmappe: Fundament | in Arbeit |
| M2 | Alle Bildschirme in Mappen | offen |
| M3 | Figuren 2.0 | offen |
| M4 | Welt ausbauen | offen |
| M5 | Szenenregie | offen |
| M6 | Gespräche mit Wahl | offen |
| M7 | Ton | offen |
| M8 | Fortsetzen, Teilen, Store | offen |

## Entscheidungen
- **A-041 · Feinkorn und Burgstadt entfernt (2026-10-13):**
  - `packages/feinkorn`, `packages/room_host`, `lib/game/dev/feinkorn_k0_main.dart`, `tool/feinkorn/bestand.dart` und `planung/feinkorn` sind gelöscht.
  - Die Browser-Leistungsmessung liegt jetzt unter `tool/e2e/leistung.mjs`.
  - Wächter: `packages/mordakte_core/test/altlast_test.dart`. Quelle: Besitzer.
- **A-042 · Abhängigkeiten (2026-10-13):** Genau zwei neue Pub-Pakete sind erlaubt: `flutter_soloud` (Ton) und `share_plus` (Teilen). Dazu kommen OFL-Schriftdateien als Assets. Ersetzt A-004 teilweise. Quelle: Besitzer.
- **A-043 · Bestand erweitern (2026-10-13):** keine neue Engine. Renderer, Stil, Kern und Netz werden ausgebaut. Launch schneller, Breite als Updates. Quelle: Besitzer.
- **A-044 · Stadt „Altstadt“ (2026-10-13):** moderne Hub-Stadt mit Anspielung auf die Wetzlarer Altstadt, ab 1.1. Quelle: Besitzer.
- **A-045 · Kostenlos, ohne Werbung, Käufe und Datenerhebung (2026-10-13).** Quelle: Besitzer.

## Prüfjournal (neueste zuerst)
- 2026-10-13: `tool/pruefen.sh schnell` nach M0 grün (Analyse ohne Befund, alle Pakettests, Altlast-Wächter grün).
