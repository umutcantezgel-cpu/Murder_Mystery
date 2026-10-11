# Einspiel · Status „Ein Mordakte“

Plan: [PLAN.md](PLAN.md). Branch: `claude/ecstatic-lamport-w4jlzn` (einziger Push-Branch).
Bei Wiederaufnahme zuerst diese Datei und `git log --oneline -15` lesen, dann den ersten offenen Meilenstein fortsetzen.

## Meilensteine

| Nr. | Inhalt | Stand |
|---|---|---|
| M0 | Werkbank, CI entsperren, Supabase-Server, Wächter | in Arbeit |
| M1 | Kern verallgemeinern ‖ Design-System + Ein-Spiel-Hülle | offen |
| M2 | Eigene Geräte online (mordakte_netz, Relais) | offen |
| M3 | Karten und Erkundung | offen |
| M4 | Akte Gewölbe | offen |
| M5 | Klassik-Akten Ravensmoor, Nachtexpress, Blue Palm | offen |
| M6 | Fertigstellen, Doku, finale Release | offen |

## Entscheidungen (Fortsetzung von planung/abschluss/STATUS.md)

- **A-014 · Neue Abhängigkeiten:** `cryptography` (X25519, HKDF, ChaCha20-Poly1305) für Ende-zu-Ende-verschlüsselte private Ansichten im Online-Spiel; `barcode` wird direkte Abhängigkeit (QR-Code des Raums). Grund: Nutzerauftrag „jeder spielt auf seinem eigenen Endgerät“ mit geheimen Rollen (K-22).
- **A-015 · Branch:** Diese Arbeit läuft ausschließlich auf `claude/ecstatic-lamport-w4jlzn` (Sitzungsregel); A-001 („nur main“) gilt hierfür nicht. Release-Workflow läuft auch auf diesem Branch.
- **A-016 · Server:** Supabase-Projekt `mordakte` (Ref `vuiyymgnkuilkbmxvcxo`, eu-central-1, Free-Plan) dient als Realtime-Relais; das Gastgebergerät ist autoritativ. URL `https://vuiyymgnkuilkbmxvcxo.supabase.co`, öffentlicher Schlüssel `sb_publishable_VXH5oe02tG9hLrNlrI2jAQ_j4WhnX88` (öffentlich, kein Geheimnis). Keine Host-Migration. Der Dart-Server bleibt optional (`MORDAKTE_SERVER`).
- **A-017 · Ein Spiel:** Alle Akten laufen über `RundenPartie`/`SchlosskellerRaum`; Akten sind Bündel unter `content/party/<akte>/`, Index `content/party/akten.json`. Klassische Echtzeit-Engine verlässt die Oberfläche (Code bleibt, `?dev=klassisch`).
- **A-018 · Modellrollen:** Opus orchestriert und macht Kernänderungen; Sonnet setzt Pakete um (nur Analyse, keine Tests); Haiku schreibt und führt alle Tests aus.

## Prüfjournal

- 2026-10-11 09:50 UTC: Flutter 3.47.6 geladen, `flutter pub get` und `dart pub get` in allen Paketen grün. Supabase-Projekt seit 06:54 UTC ACTIVE_HEALTHY.
