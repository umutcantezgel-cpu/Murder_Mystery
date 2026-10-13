# Mordakte 1.0 „Großer Fall“ · STATUS

Branch `claude/beautiful-meitner-fh1mkq` · Plan: `planung/gesamt/PLAN.md` (Bestand erweitern und finalisieren, Zug 1.0 → 1.1 → 1.2).

## Meilensteine 1.0
| M | Inhalt | Stand |
|---|---|---|
| M0 | Aufräumen + Werkbank | erledigt (siehe unten) |
| M1 | Ermittlungsmappe: Fundament | erledigt (Schriften, Tokens, Papier, Mappe, Stempel, Knopf, Dialog) |
| M2 | Alle Bildschirme in Mappen | in Arbeit (Rollen, Erzähltext als Muster; fünf Lanes A–E laufen) |
| M3 | Figuren 2.0 | erledigt: Rig (`lib/game/scene/figur_rig.dart`) und Bildnis in der Oberfläche (`lib/ui/widgets/portrait.dart`) mit denselben Merkmalen |
| M4 | Welt ausbauen | teilweise (Böden, Außenräume, Wetter, nähere Kamera, Tippen-zum-Gehen, Kulisse je Akte, NPC-Tätigkeiten, Trägheit, Trittwölkchen, Lichtstaub, schwingende Türen) |
| M5 | Szenenregie | teilweise (Zweier-Einstellung, Kinobalken, Etablierungsschwenk); Leuchtzeichen statt Steuertext offen (Lane D) |
| M6 | Gespräche mit Wahl | offen |
| M7 | Ton | teilweise: Klangpaket `packages/mordakte_klang` (26 Klänge, 5 Atmosphären, per Code), Tondienst `lib/klang` (flutter_soloud), Knöpfe, Stempel, Schreibmaschine, Karteikarte, Schritte, Türen, Donner, Atmosphäre je Akte; Einstellungen in der Oberfläche und Würfel/Siegel nach dem M2-Zusammenführen |
| M8 | Fortsetzen, Teilen, Store | offen |

## Entscheidungen
- **A-046 · Ton (2026-10-13):** `flutter_soloud` 5.1.3 (freigegeben in A-042). Klänge werden per Code erzeugt und als WAV gebacken (`dart run packages/mordakte_klang/bin/backen.dart` → `assets/klang/`, 2,2 MB). Der Ton startet nativ beim App-Start, im Web nach der ersten Berührung, nie unter `flutter test`. Web lädt `init_soloud.js` lokal (keine fremden Netzaufrufe). Quelle: Umsetzung.
- **A-041 · Feinkorn und Burgstadt entfernt (2026-10-13):**
  - `packages/feinkorn`, `packages/room_host`, `lib/game/dev/feinkorn_k0_main.dart`, `tool/feinkorn/bestand.dart` und `planung/feinkorn` sind gelöscht.
  - Die Browser-Leistungsmessung liegt jetzt unter `tool/e2e/leistung.mjs`.
  - Wächter: `packages/mordakte_core/test/altlast_test.dart`. Quelle: Besitzer.
- **A-042 · Abhängigkeiten (2026-10-13):** Genau zwei neue Pub-Pakete sind erlaubt: `flutter_soloud` (Ton) und `share_plus` (Teilen). Dazu kommen OFL-Schriftdateien als Assets. Ersetzt A-004 teilweise. Quelle: Besitzer.
- **A-043 · Bestand erweitern (2026-10-13):** keine neue Engine. Renderer, Stil, Kern und Netz werden ausgebaut. Launch schneller, Breite als Updates. Quelle: Besitzer.
- **A-044 · Stadt „Altstadt“ (2026-10-13):** moderne Hub-Stadt mit Anspielung auf die Wetzlarer Altstadt, ab 1.1. Quelle: Besitzer.
- **A-045 · Kostenlos, ohne Werbung, Käufe und Datenerhebung (2026-10-13).** Quelle: Besitzer.

## Prüfjournal (neueste zuerst)
- 2026-10-13: M7 Ton: `mordakte_klang` 4/4 Tests (kurz, nicht übersteuert, ohne Knacken, nahtlose Schleifen, deterministisch); Spektrogramme aller Klänge angesehen (Knacken in `pech` behoben); App 260/260; Web-Build; Browserproben `start`, `runden` und `solo` (ganzer Abend, 9 Kartenentscheidungen, 11 Würfe) grün, 0 Konsolenfehler, 0 fremde Netzaufrufe.
- 2026-10-13: M4/M5 Bewegung und Regie: Trägheit der eigenen Figur, Trittwölkchen je Boden und Wetter, Schwebestaub im Lampenlicht, Etablierungsschwenk beim ersten Betreten einer Akte (Wanduhr, Abbruch bei Eingabe). `party_widgets`, `session`, `karten` grün; Kontaktbögen angesehen. Leistung Kopf-Browser (Software-Darstellung) 6–7 B/s, wie die frühere Messbasis 6–8 B/s.
- 2026-10-13: M3 Bildnis: Porträts als Atelierfotos aus `FigurAussehen` (Frisur, Brille, Bart, Schal, Augen, Hemd, Krawatte), Geschlecht aus dem Kanon (`look.gender`), Merkmals-Hash `fnv32` auf Web und nativ gleich, Kopftuch per Gerade-Ungerade-Füllung. `mordakte_core` 482, App 260 Tests grün; `akte_pruefen` ohne Befund; Porträtbogen und Kontaktbogen `rollen` (Web) angesehen.
- 2026-10-13: M4 NPC-Leben: Tätigkeiten im Stand (Uhr, Notizbuch, Teetasse, verschränkte Arme, Umsehen), nur aus Kennung und Uhr, Pause beim Befragen und in Detektivnähe. Analyse ohne Befund; `party_widgets` und `session` grün; Figurenbogen angesehen.
- 2026-10-13: M4 Kulisse (`lib/game/scene/kulisse.dart`, `theme.backdrop` aus `content/welt/<akte>/welt.json`). `mordakte_core` 482 Tests grün; App-Tests `party_widgets`, `karten`, `session`, `abend` 208/208 grün; `akte_pruefen` für alle fünf Akten ohne Befund; Kulissenbogen (`tool/bild/kulisse_bogen_test.dart`) und Kontaktbögen der Karte je Akte angesehen. Backzeit der Szene 190–480 ms (Testumgebung).
- 2026-10-13: M5 Zweier-Einstellung und Tippen-zum-Gehen. Analyse ohne Befund; `test/party_widgets`, `test/karten`, `test/session` 194/194 grün; Web-Build und Kontaktbogen `karte` angesehen.
- 2026-10-13: `tool/pruefen.sh schnell` nach M0 grün (Analyse ohne Befund, alle Pakettests, Altlast-Wächter grün).

## Aufgaben des Besitzers (offen)
- **Exportangabe Verschlüsselung (iOS):** Die App nutzt eine eigene Ende-zu-Ende-Verschlüsselung (Online-Abend). Ob `ITSAppUsesNonExemptEncryption` auf `NO` stehen darf (Ausnahme für Massenmarkt), entscheidet der Besitzer; bis dahin fragt App Store Connect beim Hochladen nach.
- Signatur-Secrets für Play, Apple-Developer-Konto, Domain für Datenschutz und Deep Links, Testgeräte, Play-Closed-Test (12 Tester, 14 Tage).
