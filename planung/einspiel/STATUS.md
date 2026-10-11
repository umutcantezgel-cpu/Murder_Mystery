# Einspiel · Status „Ein Mordakte“

Plan: [PLAN.md](PLAN.md). Branch: `claude/ecstatic-lamport-w4jlzn` (einziger Push-Branch).
Bei Wiederaufnahme zuerst diese Datei und `git log --oneline -15` lesen, dann den ersten offenen Meilenstein fortsetzen.

## Meilensteine

| Nr. | Inhalt | Stand |
|---|---|---|
| M0 | Werkbank, CI entsperren, Supabase-Server, Wächter | CI läuft auf dem Branch (Toolchain grün); Gate-Fehler behoben, erste APK steht aus |
| M1 | Kern verallgemeinern ‖ Design-System + Ein-Spiel-Hülle | fertig; Feinschliff (Kamera, Akte-Verlauf, Akzente, Kartenfronten) gemergt (1d59dd2) |
| M2 | Eigene Geräte online (mordakte_netz, Relais) | Netzpaket und App-Oberfläche (Lobby, Beitreten, Gastansicht) gemergt; live gegen Supabase mit 4/8 Geräten grün; Browserlauf geraete.mjs bei Haiku |
| M3 | Karten und Erkundung | fertig: 171 Karten über 6 Kataloge, 33 Abstecher-Orte, Sammlung/Deck/Hand/Belohnung |
| M4 | Akte Gewölbe | fertig, in akten.json, Prüfung 0 Befunde; feste Lösung mit Hinweis im Assistenten (d135247) |
| M5 | Klassik-Akten Ravensmoor, Nachtexpress, Blue Palm | alle drei gemergt und in akten.json (Proben 0 Befunde) |
| M6 | Fertigstellen, Doku, finale Release | Doku neu (README, docs/ANLEITUNG.md); Assistent mit Klassenwahl; main per Fast-Forward auf d135247 (Vercel); offen: grünes Gate → erste Release |

## Entscheidungen (Fortsetzung von planung/abschluss/STATUS.md)

- **A-014 · Neue Abhängigkeiten:** `cryptography` (X25519, HKDF, ChaCha20-Poly1305) für Ende-zu-Ende-verschlüsselte private Ansichten im Online-Spiel; `barcode` wird direkte Abhängigkeit (QR-Code des Raums). Grund: Nutzerauftrag „jeder spielt auf seinem eigenen Endgerät“ mit geheimen Rollen (K-22).
- **A-015 · Branch:** Diese Arbeit läuft ausschließlich auf `claude/ecstatic-lamport-w4jlzn` (Sitzungsregel); A-001 („nur main“) gilt hierfür nicht. Release-Workflow läuft auch auf diesem Branch.
- **A-015a · main:** Auf ausdrücklichen Nutzerwunsch (2026-10-11, „push to main for a redeploy on vercel“) wird `main` per Fast-Forward auf den Arbeitsstand gesetzt (erstmals 7b5aa52), damit Vercel neu baut (`vercel.json` → `bash build.sh`). Kein Force-Push.
- **A-016 · Server:** Supabase-Projekt `mordakte` (Ref `vuiyymgnkuilkbmxvcxo`, eu-central-1, Free-Plan) dient als Realtime-Relais; das Gastgebergerät ist autoritativ. URL `https://vuiyymgnkuilkbmxvcxo.supabase.co`, öffentlicher Schlüssel `sb_publishable_VXH5oe02tG9hLrNlrI2jAQ_j4WhnX88` (öffentlich, kein Geheimnis). Keine Host-Migration. Der Dart-Server bleibt optional (`MORDAKTE_SERVER`).
- **A-017 · Ein Spiel:** Alle Akten laufen über `RundenPartie`/`SchlosskellerRaum`; Akten sind Bündel unter `content/party/<akte>/`, Index `content/party/akten.json`. Klassische Echtzeit-Engine verlässt die Oberfläche (Code bleibt, `?dev=klassisch`).
- **A-018 · Modellrollen:** Opus orchestriert und macht Kernänderungen; Sonnet setzt Pakete um (nur Analyse, keine Tests); Haiku schreibt und führt alle Tests aus.

## Prüfjournal

- 2026-10-11 09:50 UTC: Flutter 3.47.6 geladen, `flutter pub get` und `dart pub get` in allen Paketen grün. Supabase-Projekt seit 06:54 UTC ACTIVE_HEALTHY.
- 2026-10-11 ~10:40 UTC: Kern aktenneutral (Simulation optional, Prüfprofil, Raum für jede Akte, werkzeug nur aus Karten), Kartenkern mit Tischvorrat/Belohnung/Abstecher, Server lädt alle Akten. Analyse sauber; Testtor durch Haiku steht aus.
- 2026-10-11 ~11:15 UTC: Kampagne mit Schlosskeller, Ravensmoor, Nachtexpress, Blue Palm; Karten-UI (Sammlung, Deck, Hand, Erkundung, Belohnung); Netzpaket mit Ende-zu-Ende-Verschlüsselung live geprüft.
- 2026-10-11 ~11:50 UTC: Fünf Akten in der Kampagne, alle Akten-Prüfungen 0 Befunde. CI-Gate scheiterte nur an zwei Analyse-Hinweisen (tool/e2e/attrappe.dart), behoben in d135247. Vercel: Build-Befehl sucht build.sh aufwärts (Root Directory tool/e2e), Logik in tool/vercel_build.sh.
