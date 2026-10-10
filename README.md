# Mordakte

Kooperative Krimi-Abende im gemalten, isometrischen Look (Flutter + Flame).
Die App startet im **Schlosskeller**. Über **„Andere Abende & Fälle“** erreicht ihr das
Krimidinner „Spuk im Gewölbe“ und die klassischen Fälle.

**Noch in Fertigstellung:** Der lokale Schlosskeller-Abend und die klassischen Fälle sind
spielbar. Schlosskeller zeigt echte Kartenaktionen und den Kellerwürfel. Gewölbe ist derzeit
ein Begleiter; Solo-Party und Internet-Party mit privaten Rollenkarten folgen.
Verbindlicher Stand mit Prüfbelegen: `planung/abschluss/STATUS.md`.

## So spielst du

### Android-APK

[**Mordakte für Android herunterladen**](https://github.com/umutcantezgel-cpu/werwolf_digital_flutter/releases/latest/download/mordakte.apk)
· [Releases und Prüfsummen](https://github.com/umutcantezgel-cpu/werwolf_digital_flutter/releases)

Der erste Download ist verfügbar und geprüft: [APK zu `ba4f0cb`](https://github.com/umutcantezgel-cpu/werwolf_digital_flutter/releases/tag/apk-38079159341-1).
Dieser ältere Stand enthält noch nicht die später ergänzten Kartenaktionen und Würfelknöpfe.
Achtet deshalb auf den **Code-Stand in den Release-Notizen**; neuere main-Commits werden erst
nach erfolgreicher Gesamtprüfung veröffentlicht. Ladet `mordakte.apk` auf das Handy, öffnet
die Datei und erlaubt die Installation aus dieser Quelle. Ein
Release-Build funktioniert auch ohne Keystore-Secrets: Er wird dann ausdrücklich mit einer
Debug-Signatur zum Testen gebaut. Bei einem Wechsel der Signatur muss die alte App vor der
Neuinstallation entfernt werden; lokale Fortschritte gehen dabei verloren.

### Web

Die Web-Fassung wird weiterhin durch Netlify aus `main` gebaut (`netlify.toml` → `bash build.sh`).
Die öffentliche Netlify-Spieladresse ist in diesem Repository noch nicht hinterlegt; es wird
keine erfundene Adresse angegeben. Lokal: `bash build.sh`, anschließend
`python3 -m http.server 8081 --directory build/web` und im Browser `http://127.0.0.1:8081` öffnen.
Das ist nur der lokale Web-Vorschauserver, **nicht** der Online-Spielserver.

### Party an einem Gerät

**Schlosskeller → Abend vorbereiten**. 4–20 Gäste plus Geburtstagskind, ein Gerät geht reihum.
Beim Rollenlesen schaut nur die betreffende Person auf den Bildschirm. Danach wird er wieder
zugedeckt. [Spielanleitung Schlosskeller](docs/partykrimi/ANLEITUNG.md).

**Andere Abende & Fälle → Spuk im Gewölbe** öffnet derzeit Besetzung, Steckbriefe, verdeckte
Mappen und Druckmaterial. Das ist noch kein geführter digitaler Abend.
[Anleitung und aktueller Umfang Gewölbe](docs/gewoelbe/ANLEITUNG.md).

### Solo mit Bots · klassische Fälle

**Andere Abende & Fälle → Fallakten → Fall wählen**. In der Lobby die KI-Partner einstellen
und die Ermittlung starten. Die klassischen Fälle laufen vollständig offline; das ist noch
nicht der geplante Solo-Partyabend. [Anleitung klassische Fälle](docs/klassisch/ANLEITUNG.md).

### Online-Raum · klassische Fälle

1. Alle verwenden denselben freigegebenen öffentlichen Spielserver und die gleiche App-Fassung.
2. **Andere Abende & Fälle → Online spielen → Raum erstellen**.
3. Freunde tippen **Raum beitreten** und geben den vierstelligen Raumcode ein, jeder am eigenen Handy.
4. Der Gastgeber wählt den Fall. Alle melden sich bereit, dann beginnt die Ermittlung (1–6 Detektive).

Die öffentliche Adresse wird als `MORDAKTE_SERVER` in den Build eingebettet. Unter **Erweitert**
kann dieselbe freigegebene `wss://…/ws`-Adresse eingetragen werden. Ohne Konfiguration erklärt
die App den fehlenden Server, statt das eigene Handy über `localhost` anzusprechen. **Railway
ist noch nicht öffentlich abgenommen.** Internet-Rollenkarten für die Partyabende werden
separat implementiert; der lokale Gerätewechsel ist kein Online-Modus.

## Klassischer Spielablauf

Jeder Fall hat 3 Kapitel:

1. **Intro** – Kapiteltext.
2. **Ermittlung** (4 Min) – Hotspots durchsuchen, Verdächtige befragen, Beweise vorlegen,
   Items aufheben. Gefundene Hinweise sind privat, bis man sie auf die **Beweiswand** teilt.
   Zwei passende Hinweise lassen sich zu einer Schlussfolgerung kombinieren.
3. **Beratung** – das Team stimmt über die nächste Spur ab (schaltet Räume/Hotspots frei).
4. **Nacht** – Licht aus. Der Schatten greift isolierte Detektive an, tötet Zeugen und
   beschädigt ungeteilte Notizen. Er hinterlässt Spuren, die Merkmale des Täters verraten.
5. Kapitel 3 endet mit der **Anklage** (Täter, Motiv, Waffe) und einem zusammengesetzten
   **Ende** (Urteil × Team-Schicksal × Täter-Epilog × Geheimnis).

Weitere Mechaniken: Hinweise entwickeln sich (Labor, Zeit), verpassbare Spuren, 5 Klassen
(Forensikerin, Profiler, Ex-Cop, Journalistin, Sanitäter) mit Fähigkeiten, Buffs/Debuffs,
Nerven, Niedergeschlagen → Wiederbeleben → Geist-Modus, Emotes/Schnellchat/Pings.
Meta: Rang & XP, Freischaltungen, Enden-Sammlung, Fall des Tages mit Streak, Achievements.

Jedes Szenario hat 24 Fall-Varianten (Täter/Motiv/Waffe per Seed): Der erste Durchlauf ist
die Story-Variante, danach wird jeder Fall neu gewürfelt.

## Szenarien

| Datei | Setting |
|---|---|
| `content/scenarios/ravensmoor.json` | Herrenhaus in einer Gewitternacht, 1890er |
| `content/scenarios/nachtexpress.json` | Nachtzug im Alpen-Schneesturm, 1931 |
| `content/scenarios/blue_palm.json` | Neon-Motel in Florida, 1986 |

Neue Szenarien sind reine JSON-Dateien – Format in [`content/SCHEMA.md`](content/SCHEMA.md).
Prüfen und probespielen:

```bash
cd packages/mordakte_core
dart run bin/validate.dart              # Format, Karte, Erreichbarkeit, Lösbarkeit
dart run bin/simulate.dart alle 4 2     # KI-Detektive spielen Fälle komplett durch
```

## Projektstruktur

```
packages/mordakte_core/   Reines Dart: Szenario-Modell, Raster/A*, Regeln, Engine, Schatten-KI,
                          KI-Detektive, Fall-Generator, Enden, Protokoll, RoomRuntime
server/                   Dart-WebSocket-Server (autoritativ, eine RoomRuntime pro Raum)
lib/game/                 Flame-Renderer (Iso-Räume, Figuren, Licht, Wetter, Joystick)
lib/ui/, lib/app/         Screens & Overlays (go_router, Provider)
lib/meta/                 Fortschritt, Freischaltungen, Sammlung, Fall des Tages
lib/session/              LocalSession (offline), OnlineSession (WebSocket), FakeSession (Dev)
content/scenarios/        Vorgefertigte Fälle
```

Solo läuft komplett offline: Die App startet dieselbe `RoomRuntime` wie der Server im Prozess.

## Entwickeln

Flutter 3.47.6 (Dart 3.13).

```bash
flutter pub get
flutter run                                   # Gerät/Emulator
flutter build apk --release                   # Android
flutter build ios --release                   # iOS (auf macOS)
flutter analyze
(cd packages/mordakte_core && dart test)
```

Web-Vorschau (Entwickler-Einstiege): `?autoplay=ravensmoor&speed=8` (KI spielt einen echten
Fall im Zeitraffer), `?fake=night` / `?fake=ending` (Testzustände), `?screen=cases`.

## Online-Server

```bash
cd server && dart pub get && dart run bin/server.dart        # PORT=8080, SCENARIO_DIR=../content/scenarios
```

Die App verbindet sich mit `--dart-define=MORDAKTE_SERVER=wss://<öffentliche-domain>/ws`.
Es gibt **keinen localhost-Standard**. Bis eine öffentliche Adresse freigegeben ist, bleibt
die Vorgabe leer und die App zeigt einen Einrichtungshinweis. URL-Zugangsdaten, unverschlüsselte
Internetverbindungen und Schleifenadressen werden abgewiesen.
Deployment (Railway): `railway.toml` + `server/Dockerfile`, Build-Kontext ist das Repo-Root –
im Railway-Dienst muss das Root Directory leer sein. `/health` liefert HTTP 200; genau eine
Instanz, da Räume im Speicher liegen. Details in [`server/README.md`](server/README.md).

## Automatische Builds und Signatur

`.github/workflows/release.yml` prüft bei jedem Push auf `main` Analyse, Paket-/Flutter-Tests,
Server, Web-Build, Party-E2E und Secrets. Erst danach baut der Workflow die Release-APK und
veröffentlicht das GitHub-Release **latest** mit APK und SHA-256-Prüfsumme. Jeder Lauf erhält
ein neues, unveränderliches Tag; bestehende Tags oder Geschichte werden nicht umgeschrieben.
Der stabile Download-Link oben zeigt auf das jeweils neueste freigegebene Release.

- GitHub Actions benötigt die Erlaubnis, Releases zu veröffentlichen (`contents: write`).
- Öffentliche Repository-Variable **`MORDAKTE_SERVER`**: freigegebene `wss://…/ws`-Adresse.
  In Netlify dieselbe Variable setzen. Sie ist kein Secret.
- Optionale GitHub-Secrets: **`ANDROID_KEYSTORE_BASE64`**, **`ANDROID_KEYSTORE_PASSWORD`**,
  **`ANDROID_KEY_PASSWORD`**, **`ANDROID_KEY_ALIAS`**. Werte nur über GitHub Secrets, nie in Chat/Repository.
- Alle vier fehlen: Debug-Signatur. Nur ein Teil vorhanden: Build schlägt fehl, kein stiller Fallback.
- Keystore nur im temporären Actions-Verzeichnis mit Dateirechten 0600. Keine Passwörter in
  Kommandozeilen oder `key.properties`; Gradle liest sie direkt aus der Umgebung.

Gesamtprüfung: `bash tool/pruefen.sh alles`; mit allen Browserläufen: `bash tool/pruefen.sh e2e`.
Linux-Testvoraussetzungen: Flutter 3.47.6, Node 22, `pdfinfo`/`pdftotext` (Poppler) und
Playwrights Chromium-Laufzeitbibliotheken. Die bereits deklarierten Browserpakete werden mit
`cd tool/e2e && npm ci && npx playwright install chromium` installiert.

## Ausblick

- Steam-Version mit spielbarem Täter: Der Schatten läuft bereits über eine
  `KillerController`-Schnittstelle; Desktop-Plattformen per `flutter create --platforms=windows,macos,linux`.
- Englische Texte: Szenario-Texte sind `{"de": …}`-Objekte, UI über `lib/l10n/app_de.arb`.
