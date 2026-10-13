# Mordakte 1.0 „Großer Fall“ · STATUS

Branch `claude/beautiful-meitner-fh1mkq` · Plan: `planung/gesamt/PLAN.md` (Bestand erweitern und finalisieren, Zug 1.0 → 1.1 → 1.2).

## Meilensteine 1.0
| M | Inhalt | Stand |
|---|---|---|
| M0 | Aufräumen + Werkbank | erledigt (siehe unten) |
| M1 | Ermittlungsmappe: Fundament | erledigt (Schriften, Tokens, Papier, Mappe, Stempel, Knopf, Dialog) |
| M2 | Alle Bildschirme in Mappen | in Arbeit (Rollen, Erzähltext als Muster; fünf Lanes A–E laufen) |
| M3 | Figuren 2.0 | erledigt: Rig (`lib/game/scene/figur_rig.dart`) und Bildnis in der Oberfläche (`lib/ui/widgets/portrait.dart`) mit denselben Merkmalen |
| M4 | Welt ausbauen | teilweise (Böden, Außenräume, Wetter, nähere Kamera, Tippen-zum-Gehen, Kulisse je Akte, NPC-Tätigkeiten); Teilchen, Türen offen |
| M5 | Szenenregie | teilweise (Zweier-Einstellung, Kinobalken); Etablierungsschwenk, Leuchtzeichen offen |
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
- 2026-10-13: M3 Bildnis: Porträts als Atelierfotos aus `FigurAussehen` (Frisur, Brille, Bart, Schal, Augen, Hemd, Krawatte), Geschlecht aus dem Kanon (`look.gender`), Merkmals-Hash `fnv32` auf Web und nativ gleich, Kopftuch per Gerade-Ungerade-Füllung. `mordakte_core` 482, App 260 Tests grün; `akte_pruefen` ohne Befund; Porträtbogen und Kontaktbogen `rollen` (Web) angesehen.
- 2026-10-13: M4 NPC-Leben: Tätigkeiten im Stand (Uhr, Notizbuch, Teetasse, verschränkte Arme, Umsehen), nur aus Kennung und Uhr, Pause beim Befragen und in Detektivnähe. Analyse ohne Befund; `party_widgets` und `session` grün; Figurenbogen angesehen.
- 2026-10-13: M4 Kulisse (`lib/game/scene/kulisse.dart`, `theme.backdrop` aus `content/welt/<akte>/welt.json`). `mordakte_core` 482 Tests grün; App-Tests `party_widgets`, `karten`, `session`, `abend` 208/208 grün; `akte_pruefen` für alle fünf Akten ohne Befund; Kulissenbogen (`tool/bild/kulisse_bogen_test.dart`) und Kontaktbögen der Karte je Akte angesehen. Backzeit der Szene 190–480 ms (Testumgebung).
- 2026-10-13: M5 Zweier-Einstellung und Tippen-zum-Gehen. Analyse ohne Befund; `test/party_widgets`, `test/karten`, `test/session` 194/194 grün; Web-Build und Kontaktbogen `karte` angesehen.
- 2026-10-13: `tool/pruefen.sh schnell` nach M0 grün (Analyse ohne Befund, alle Pakettests, Altlast-Wächter grün).
