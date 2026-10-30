# Mordakte

Ein kooperativer Krimi-Abend im gemalten, isometrischen Look (Flutter und Flame). **Ein Spiel, fünf Akten,
ein Regelwerk.** Eine Person ermittelt, alle anderen spielen Gäste mit Geheimnissen. Du spielst solo mit Bots,
reihum an einem Gerät oder online, jeder am eigenen Handy. Jeder Fall ist lösbar. Der Würfel ändert nie einen
Fakt oder die Punkte.

Die ganze Spielanleitung: **[docs/ANLEITUNG.md](docs/ANLEITUNG.md)**.

## So spielst du

### 1. Herunterladen

Alle Dateien liegen in den [Releases](https://github.com/umutcantezgel-cpu/Murder_Mystery/releases). Die Links zeigen
immer auf das neueste freigegebene Release.

| Gerät | Datei |
| --- | --- |
| Android | [`mordakte.apk`](https://github.com/umutcantezgel-cpu/Murder_Mystery/releases/latest/download/mordakte.apk) |
| iPhone, iPad | [`mordakte-ios-unsigned.ipa`](https://github.com/umutcantezgel-cpu/Murder_Mystery/releases/latest/download/mordakte-ios-unsigned.ipa) (unsigniert) |
| Web | [`mordakte-web.zip`](https://github.com/umutcantezgel-cpu/Murder_Mystery/releases/latest/download/mordakte-web.zip) |
| Prüfsummen | [`SHA256SUMS.txt`](https://github.com/umutcantezgel-cpu/Murder_Mystery/releases/latest/download/SHA256SUMS.txt) |

- **Android:** Datei öffnen, Installation aus dieser Quelle erlauben. Die APK ist mit einem **öffentlichen
  Test-Schlüssel** signiert. Er bleibt über alle Updates gleich. Wer noch die ältere, debug-signierte APK hat,
  deinstalliert sie **einmal** (lokale Karten gehen dabei verloren).
- **iOS:** Die IPA ist unsigniert. Mit AltStore oder Sideloadly und einer kostenlosen Apple-ID signieren und
  installieren. Du musst sie **alle 7 Tage neu signieren**.
- **Web:** Der Build lässt sich von Vercel oder Netlify aus `main` bauen (`build.sh`). GitHub Pages braucht einen
  einmaligen Schalter des Besitzers (siehe unten). Eine feste Web-Adresse steht hier nicht.
  Lokal: `bash build.sh`, dann `python3 -m http.server 8081 --directory build/web`.

**Erzählerakte am Release (Schlosskeller).** Am Release hängt die Erzählerakte als PDF, in zwei Fassungen. Beide sind
nur für die Person, die erzählt, nennen nie den Täter und gelten für jede Personenzahl (alle Figuren in der Reihenfolge
der Besetzung, ohne Marken für einen bestimmten Abend; bei acht Personen spielen die Figuren 1 bis 8):

| Fassung | Datei |
| --- | --- |
| Ziele wie im Druckspiel | [`erzaehlerakte.pdf`](https://github.com/umutcantezgel-cpu/Murder_Mystery/releases/latest/download/erzaehlerakte.pdf) |
| Abend mit „Dein Moment“ (je Figur die zwei Ziele aus „Dein Moment“) | [`erzaehlerakte-dein-moment.pdf`](https://github.com/umutcantezgel-cpu/Murder_Mystery/releases/latest/download/erzaehlerakte-dein-moment.pdf) |

Fehlt eine der beiden Dateien im neuesten Release (dann war der Job `erzaehlerakte` rot, siehe „Builds“), liegt sie
im vorigen Release auf der [Release-Seite](https://github.com/umutcantezgel-cpu/Murder_Mystery/releases).

Die PDFs des Druckspiels (Rollenhefte, Erzählerheft, Auflösung) erstellt die App: Detektei → **PDFs zum Ausdrucken**
(unter dem Schlosskeller oder auf der Akte-Seite). Steckbriefe und Charakterübersicht liegen auf der Akte-Seite unter
**Steckbriefe & Übersicht**.

### 2. Starten

Die App startet in der **Detektei**: **Neuer Abend**, **Beitreten**, die Kampagne aus fünf Akten, die
**Sammlung** und dein **Profil**. Der Assistent für einen neuen Abend hat vier Schritte: Akte, Spielweise,
Einstellungen, Start.

### 3. Die drei Spielweisen

Du wählst sie vor jedem Abend.

| Spielweise | So läuft es |
| --- | --- |
| **Solo mit Bots** | Du ermittelst allein. Bots spielen die Gäste. Ihre Dossiers bleiben zu. |
| **Ein Gerät reihum** | Ein Gerät geht am Tisch von Hand zu Hand. Rollen und Wahlen sind verdeckt. |
| **Jeder am eigenen Gerät** | Der Gastgeber öffnet einen Raum mit **6-stelligem Code und QR-Code**. Die Gäste treten mit **Beitreten** bei. Bots füllen freie Rollen, überzählige Geräte werden Assistenten. Das Gastgeber-Gerät muss im Vordergrund bleiben. |

Jeder Abend: Rollen lesen, **3 Runden** (Gespräche, drei Ermittlungsentscheidungen mit sichtbarem Weg auf der
Karte, Würfel mit angezeigten Chancen, Funde, geheime Gruppenwahl, Resümee), Anklage, Finale, Auflösung.
Das Ende ist **Meister, Teilerfolg, Justizirrtum oder Eskalation**. Dazu gibt es Karten und Erfahrung.
Optional kannst du **erkunden** (Abstecher): Das kostet Nachtminuten und kann Karten bringen.

**Neu im Schlosskeller** (beides im Assistenten an, je Abend abschaltbar):

- **Einstimmung:** Vor dem Auftakt liest der Erzähler eine Vorgeschichte (etwa fünf Minuten) und stellt jede Figur
  am Tisch vor. Der Erzähler hat dazu eine **Erzählerakte** mit Hintergründen und Beziehungsnetz aller Figuren,
  ohne den Täter. Sie liegt nur am Erzähler-Platz (Pult, Erzähler-Handy, Erzähler-Sitz), nie solo, und lässt sich
  ohne Fall-Code drucken: in der offenen Akte mit **Als PDF**, in der Druckmappe der App und als Datei am Release.
- **„Dein Moment“** ersetzt die Gruppenwahl: Jede Rolle zieht je Runde geheim einen Zug (Zeigen, Decken, Helfen,
  Auspacken, Ablenken, Lauschen). Die Züge geben den Optionen Tischwerte, die den Würfel verschieben, bringen
  Gerüchte, Randnotizen und Nachtminuten, füllen die Leisten Zusammenhalt und Spuk mit Ereignissen und bestimmen
  über den Tischbonus das Ende mit. Jede Figur hat zwei geheime Ziele (Sterne). Täter und Wahrheit legt weiter der
  Fall-Code fest. Das Druckspiel läuft ohne „Dein Moment“, mit den Papierstreifen A und B.

Mehr dazu in [docs/ANLEITUNG.md](docs/ANLEITUNG.md), Abschnitte 4 bis 7.

**Alle Geräte aktualisieren.** Mit „Dein Moment“ gilt das Online-Protokoll 5. Geräte mit älterer App kommen nicht
mehr in einen Raum. Abende, die ein Gerät von vorher abgelegt hat, setzt es ohne „Dein Moment“ fort.

### 4. Karten

Jede Figur jeder Akte und fünf Detektivklassen haben **Sammelkarten**. Sie bleiben dauerhaft auf dem Gerät.
Dein **Deck** hat bis zu 3 Karten. Auf dem Tisch liegen höchstens 3 Karten, je Art eine, mit zusammen höchstens
4 Ladungen. Karten sind Komfort (Werkzeug +1, Marke, Zeit, Gründlich, Nochmal, Umweg, Abstecher, Erinnerung,
Aussehen). Sie ändern nie Fakten, Punkte oder Ende. Du bekommst sie am Abendende (eigene Rolle oder Klasse,
Täterkarte bei richtiger Anklage, legendäre Karte beim Meister-Ende, solo und reihum eine Karte einer Figur vom
Tisch) und bei Funden beim Erkunden.

## Die fünf Akten

| Akte | Ton | Rollen | Besonderes |
| --- | --- | --- | --- |
| **Spuk im Schlosskeller** · Das Buffet hinter dicken Mauern | Spuk | 4 bis 20 | Erzähler-Platz, kurzer und langer Abend, Einstimmung mit Erzählerakte, „Dein Moment“, Druckspiel |
| **Spuk im Gewölbe** · Ein Geburtstag auf Burg Schartenfels | Spuk | 4 bis 20 | feste Lösung |
| **Ravensmoor** · Ein Gewitter. Ein Herrenhaus. Ein Toter, der zu viele Geheimnisse kannte. | Noir | 4 bis 8 | – |
| **Nachtexpress 1931** · Ein Toter im Schlafwagen. Ein Zug, den niemand verlassen kann. | Noir | 4 bis 8 | – |
| **Blue Palm Motel** · Neonlicht, Hurrikan-Warnung und ein Toter in Zimmer 7 | Noir | 4 bis 8 | – |

Einstimmung, Erzählerakte und „Dein Moment“ gibt es nur im Schlosskeller (Fähigkeiten `einstimmung`,
`erzaehlerakte`, `einfluss` in `content/party/akten.json`). Die anderen vier Akten laufen bitgleich wie vorher; das
prüft `einfluss_gating_test` gegen einen Schnappschuss von vor dem Finale. Die Reihenfolge steht in
`content/party/akten.json`. Die Druckfassung des Schlosskellers beschreibt
[docs/partykrimi/ANLEITUNG.md](docs/partykrimi/ANLEITUNG.md).

## Entwickeln

Flutter 3.47.6 (Dart 3.13). Die gepinnte Werkzeugkette lädt `tool/flutter_env.sh` nach `.werkzeug/`.

```bash
source tool/flutter_env.sh            # Flutter 3.47.6 auf den PATH (lädt es beim ersten Mal)
flutter pub get && flutter run        # Gerät, Emulator oder Chrome
bash tool/pruefen.sh schnell          # Pakete, Analyse, Pakettests
bash tool/pruefen.sh ci               # wie im CI: alles, 4-Client-Matrizen, Web-Build, Browser-Proben
bash tool/pruefen.sh alles            # alles mit den langsamen Online-Matrizen
bash tool/pruefen.sh e2e              # alles plus alle 84 Browser-Durchläufe (tool/e2e)
```

```
lib/                      App: detektei/ (Start, Akten, Sammlung), abend/ (Assistent, Abend, Online), karten/,
                          party/ (Abendbildschirme), stil/ (Design), game/ (Flame-Karte), meta/ (Speicher)
packages/mordakte_core/   Reines Dart: party/ (Kanon, Simulator, Beweise, Texte, Druck), runden/ (RundenPartie,
                          Raum, Würfel), karten/ (Katalog, Tischvorrat, Belohnung, Abstecher)
packages/mordakte_netz/   Online-Abende: Phoenix-Relais, Ende-zu-Ende-Umschläge, Gastgeber, Gast
packages/krimidinner_kanon/  Kanonleser und Konverter für „Spuk im Gewölbe“
server/                   optionaler Dart-Server (siehe server/README.md)
content/party/<akte>/     Bündel je Akte; Index content/party/akten.json; Erkundungsorte in zusatz/<akte>/
content/karten/           Sammelkarten je Akte (plus Detektivklassen in mordakte.json)
content/scenarios/        klassische Szenarien (Quelle der Konverter, unverändert)
krimidinner/              Kanon „Spuk im Gewölbe“ (unverändert)
```

### Eine neue Akte anlegen

1. **Bündel** unter `content/party/<id>/` im Party-Kanonformat (`fall`, `figuren`, `raeume`, `setting`,
   `besetzung`, `entscheidungen`, `gruppenwahl`, `bonus`, `gegenstaende`, `texte/` …). Die Schemas stehen in
   `content/party/schema-akte/` (Hinweise dort in der README).
2. **Konverter**, wenn die Akte aus einer Quelle entsteht. Beide haben ein Overlay `content/party/<id>/_autor/`
   und prüfen mit `--pruefen`, ob das Bündel noch dem Konverter entspricht (Drift):
   - Krimidinner (im Ordner `packages/krimidinner_kanon`): `dart run bin/akte_export.dart --akte <id>`
   - klassisches Szenario (im Ordner `packages/mordakte_core`): `dart run bin/akte_klassik_<id>.dart`
3. **Karten** in `content/karten/<id>.json` und **Erkundungsorte** in `content/party/zusatz/<id>/abstecher.json`.
4. **Prüfen** (im Ordner `packages/mordakte_core`):
   `dart run bin/akte_pruefen.dart --fall <id>` (Schema, Verweise, Simulator, Beweise, Karte, Texte, Besetzung,
   vollständiger Abend) und `dart run bin/karten_pruefen.dart`.
5. **Eintragen** in `content/party/akten.json` und unter `flutter: assets:` in `pubspec.yaml`
   (`content/party/<id>/`, `…/texte/`, `content/party/zusatz/<id>/`). `tool/pruefen.sh` prüft jede Akte der Liste.
   Ein eigener Farbstil steht in `lib/stil/thema.dart` (`AkteStil`), sonst gilt Kerzenmessing.

### Der Kanon bleibt unverändert (A-002)

`krimidinner/`, `content/party/schlosskeller/` und `content/scenarios/` werden nicht angefasst. Der Test
`packages/mordakte_core/test/kanon_unveraendert_test.dart` vergleicht jede Datei mit den SHA-256-Summen in
`tool/kanon_pruefsummen.txt` und meldet auch neue Dateien in diesen Ordnern. Neue Akten brauchen eigene Ordner.

### Die klassische Echtzeit-Engine

Die frühere Echtzeit-Fassung (Joystick, Schatten, Beweiswand, vierstellige Räume) gehört nicht mehr zum Spiel.
Code und Tests bleiben als **Entwicklercode** (`packages/mordakte_core/lib/src/engine`, `runtime`, `lib/game`,
`lib/ui`). Einstiege in der Web-Fassung: `?screen=hub|cases|collection|online`, `?autoplay=<szenario>&speed=8`,
`?fake=night`. Prüfen: `cd packages/mordakte_core && dart run bin/validate.dart` und
`dart run bin/simulate.dart alle 4 2`.

Weitere Einstiege (Web): `?screen=detektei|neu|akte|sammlung|deck|profile|beitreten` (mit `&akte=<id>` oder
`&raum=<CODE>`) und `?party=<akte>` für den Partymodus mit Skript (`lib/party/skript.dart`).

## Builds und Signatur

`.github/workflows/release.yml` läuft bei jedem Push auf `main` und den Arbeitsbranch (nicht bei reinen
Änderungen unter `planung/`), von Hand und wöchentlich. Läufe desselben Branches werden hintereinander abgearbeitet.

- **`gate`**: `bash tool/pruefen.sh ci`, dann geht der Web-Build an die folgenden Jobs.
- **`e2e_voll`**: alle 84 Browser-Läufe als Matrix über vier Pfade. Nur von Hand (`voll_e2e`) und montags.
- **`android`**: `mordakte.apk`. **`ios`** (macOS, darf fehlschlagen): `mordakte-ios-unsigned.ipa`.
- **`web`**: `mordakte-web.zip` und eine Kopie mit Basis `/Murder_Mystery/` für GitHub Pages. **`pages`** veröffentlicht
  sie und schlägt ohne aktiviertes Pages fehl, ohne den Lauf zu stören.
- **`erzaehlerakte`** (nicht beim wöchentlichen Lauf): zeichnet die Porträts (`flutter test
  tool/bild/druck_portraets_test.dart`, mindestens 22) und setzt die Erzählerakte des Schlosskellers zweimal mit
  `party_druck.dart --erzaehlerakte --ohne-besetzung`, einmal mit `--dein-moment`: `erzaehlerakte.pdf` und
  `erzaehlerakte-dein-moment.pdf`. Der Job schlägt fehl, wenn Porträts fehlen, eine Datei weniger als 24 Seiten hat
  oder beide Dateien gleich sind. Kein Fall-Code, kein Pfad. Ein roter Job hält das Release nicht auf: Es erscheint
  ohne die PDFs, und der Lauf bleibt rot. Auf `main` wird es trotzdem „latest“, und die Links oben führen dann ins
  Leere, bis die PDFs wieder dranhängen. Nachholen mit „Re-run failed jobs“: Das baut die Akten neu und erzeugt ein
  neues Release mit neuem Tag (`mordakte-<Lauf>.<Versuch>`).
- **`release`**: je Lauf ein Release mit Tag `mordakte-<Lauf>.<Versuch>` und den festen Dateinamen
  `mordakte.apk`, `mordakte-ios-unsigned.ipa`, `mordakte-web.zip`, `erzaehlerakte.pdf`,
  `erzaehlerakte-dein-moment.pdf`, `SHA256SUMS.txt`. IPA, Web-ZIP und die beiden PDFs dürfen fehlen; dann nennen die
  Notizen das, und das Release entsteht trotzdem. Tags werden nie verschoben.
  **latest** bekommt das Release nur, solange sein Stand die Spitze von `main` oder des Arbeitsbranches ist.

**Android-Signatur.** Sind alle vier Secrets `ANDROID_KEYSTORE_BASE64`, `ANDROID_KEYSTORE_PASSWORD`,
`ANDROID_KEY_PASSWORD` und `ANDROID_KEY_ALIAS` gesetzt, gilt der Release-Schlüssel. Fehlen alle vier, gilt der
**öffentliche Test-Schlüssel** `tool/ci/signing/mordakte-test.p12` (Passwort öffentlich, nur für Sideload-Tests,
nie für einen Store). Ist nur ein Teil gesetzt, bricht der Build ab. Ein Wechsel zwischen den Schlüsseln
verlangt eine Deinstallation. Details: `tool/ci/signing/README.md`. Die IPA ist immer unsigniert.

**Öffentliche Variablen** (optional, keine Secrets): `MORDAKTE_SERVER`, `MORDAKTE_RELAY_URL`, `MORDAKTE_RELAY_KEY`.
Gesetzte Werte gehen über `tool/ci/dart_defines.sh` als `--dart-define` in APK, IPA und `build.sh`.
`tool/ci/check_server_url.py` weist falsche Formate und geheime Schlüssel ab.

## Online-Relais

Online-Abende laufen **ohne eigenen Server** über ein **Supabase-Realtime-Projekt** (Free-Plan, Grenzen gelten).
Standardadresse und öffentlicher Schlüssel stehen in `packages/mordakte_netz/lib/src/relay_standard.dart`; beides
sind öffentliche Werte. Ein anderes Relais stellst du mit `--dart-define=MORDAKTE_RELAY_URL=…` und
`MORDAKTE_RELAY_KEY=…` ein.

- Das **Gastgeber-Gerät ist die Autorität**. Das Relais leitet nur Pakete weiter. Es gibt keine Host-Migration.
- Private Ansichten und Befehle sind **Ende-zu-Ende verschlüsselt** (X25519, HKDF, ChaCha20-Poly1305). Der
  Raumcode (6 Zeichen) ist an den Gastgeberschlüssel gebunden.
- Der **Dart-Server** in `server/` bleibt als Option (`MORDAKTE_SERVER`). Die Online-Abende der App nutzen ihn nicht.
  Nur der klassische Entwickler-Bildschirm `?screen=online` liest die Adresse.

## Einmalig vom Besitzer

- **GitHub Pages** (wenn gewünscht): Settings → Pages → Source: **GitHub Actions**.
- **Android-Release-Schlüssel** (optional): die vier Secrets oben setzen. Ohne sie gilt der Test-Schlüssel.
- **Apple-Signatur** (optional, für eine reguläre iOS-Installation): im Workflow ist dafür noch nichts eingerichtet.
- **Supabase** (kostenloses Projekt) aktiv halten: Es pausiert nach 7 Tagen ohne Nutzung. Dann im
  Supabase-Dashboard wieder aktivieren.
- **Claude Code:** Für unbeaufsichtigte Läufe im Menü den Berechtigungsmodus „Auto“ wählen.

Stand und Plan der Zusammenführung: `planung/einspiel/STATUS.md` und `planung/einspiel/PLAN.md`.
