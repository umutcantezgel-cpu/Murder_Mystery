# Mordakte-Server (optional)

> **Für Online-Abende brauchst du diesen Server nicht.** Die Online-Abende der App („Jeder am eigenen Gerät“)
> laufen über ein Supabase-Realtime-Relais und das Gastgeber-Gerät (`packages/mordakte_netz`, siehe
> [README](../README.md#online-relais)). Dieser Dart-Server bleibt als **optionaler Weg**: Er spielt dieselben
> Abende mit einem Raum auf dem Server statt auf dem Gastgeber-Gerät. Seine Adresse käme als `MORDAKTE_SERVER`
> in den Build. Die App-Oberfläche für Abende nutzt sie heute nicht. Nur der klassische Entwickler-Bildschirm
> (`?screen=online`) liest `MORDAKTE_SERVER`.

WebSocket-Server für klassische Räume (1–6 Detektive, nur Entwicklercode der Echtzeit-Engine) und für Abende
**jeder Akte** aus `content/party/akten.json` (Schlosskeller und Gewölbe bis zu 20 Rollen, die Noir-Akten bis zu 8).
Beide teilen sich Anmeldung, Raumcodes, Verbindungslimits und Reconnect; ihre Spielansichten und Befehle bleiben
getrennt. Klassisch nutzt die bestehende `RoomRuntime`, die Abende den transportfreien `SchlosskellerRaum` mit
`RundenPartie` aus `mordakte_core`, einschließlich Tischvorrat und Erkundungsorten. Beim Start lädt der Server
für jede Akte des Index eine eigene Raum-Fabrik (`loadAktenFactories` in `lib/party.dart`).

**Stand:** Das Partyprotokoll ist mit echten Clients lokal geprüft. Eine öffentliche Railway-Abnahme steht aus.

## Lokal starten

```bash
cd server
dart pub get
dart run bin/server.dart                 # http://localhost:8080/health, ws://localhost:8080/ws
INCLUDE_SAMPLE=1 dart run bin/server.dart  # zusätzlich das eingebaute Szenario "sample"
```

Der lokale Server ist für Protokoll-/Engine-Tests. Der klassische Entwickler-Bildschirm der App
(`?screen=online`) verwendet nur eine freigegebene öffentliche `wss://…/ws`-Adresse; es gibt keinen
localhost-Fallback. Ohne Adresse erscheint ein Einrichtungshinweis, offline kann weiterhin gespielt werden.

Smoke-Test (Fake-Runtime + echte RoomRuntime, echte WebSocket-Clients):

```bash
dart run tool/smoke.dart            # -v: Server-Log zeigen, --fake-only / --real-only
```

## Online-Matrix mit echten Clients

`dart run tool/online_matrix.dart` startet den echten Produktions-Handler mit der echten
Engine, verbindet für jede Zahl von **4 bis 20** TCP/WebSocket-Clients und prüft Health,
Raumerstellung/-beitritt, alle drei klassischen Fälle, Spielstart, Raumtrennung,
Bewegungsbestätigung und Wiederverbindung. Sitzungsschlüssel werden nie ausgegeben.

Die klassischen Räume bleiben bei **maximal sechs Detektiven**. Größere Laststufen nutzen
mehrere Räume. Dieser klassische Test bleibt bewusst getrennt von der Partyprüfung.

`dart run tool/party_matrix.dart` prüft **4–20 echte Clients in jeweils einem Partyraum**
vom Start bis zum Ende: serverseitige Würfe, eigene Rollenkarte, Fremdzugriff abgewiesen,
privates Abstimmen, Reconnect mit derselben Karte und Trennung von klassischen Räumen.
Unbesetzte Kanonrollen übernehmen Bots. 20 verbundene Geräte entsprechen 19 Gästen plus
Detektiv; die maximale Kanonbesetzung mit 20 Gästen plus Detektiv ist zusätzlich mit
`dart run tool/party_matrix.dart --clients=21` prüfbar. `--clients=4` ist die kurze Probe.
Sitzungsschlüssel, Rohpakete und geheime Karten werden nie in Prüfprotokolle geschrieben.

`dart run tool/relay_matrix.dart --lokal --clients=4,8` prüft dagegen das **Supabase-Relais** der App
(Paket `mordakte_netz`): einen vollständigen Abend mit Gastgeber und Gästen gegen eine lokale Attrappe, mit
Privatheits-, Mithörer-, Wiederholungs- und Neuverbindungsprüfungen. Ohne `--lokal` läuft er live gegen das
Relais (`--url=` und `--key=` überschreiben die Standardwerte). `tool/pruefen.sh ci` führt ihn mit `--lokal --clients=4` aus.

Nach einer Railway-Freigabe beide Tests gegen den öffentlichen Server ausführen:
`dart run tool/party_matrix.dart --url=wss://<freigegebener-host>/ws` und
`dart run tool/online_matrix.dart --url=wss://<freigegebener-host>/ws`.
Dabei entstehen ausschließlich neue Prüfräume; die Clients verlassen sie am Ende. Leere
laufende Räume werden danach über die normale Server-Frist entfernt.

## Native Server-Prüfung

`tool/pruefen.sh alles` kompiliert außerdem `server/bin/server.dart` in eine native
Datei und startet diese mit `server/tool/native_smoke.mjs` (Node 22, keine Zusatzpakete).
Die Probe prüft HTTP 200, echte WebSocket-Anmeldung, Partyraumerstellung, Start mit
Botrollen und die eigene Rollenansicht; anschließend wird der Prozess sauber beendet.
Das ist ein AOT-Beleg, aber noch kein Docker-/Railway-Deployment-Beleg.

## Umgebungsvariablen

| Variable         | Standard                                                        | Bedeutung                                   |
|------------------|-----------------------------------------------------------------|---------------------------------------------|
| `PORT`           | `8080`                                                          | HTTP-Port (Railway setzt ihn selbst)        |
| `SCENARIO_DIR`   | `/app/content/scenarios`, sonst `../content/scenarios`          | Alle `*.json` darin werden geladen          |
| `PARTY_DIR`      | `/app/content/party/schlosskeller`, sonst Repo-Kanon             | Ordner des Schlosskeller-Kanons; die übrigen Akten, `zusatz/` und `../karten/` werden relativ dazu gefunden |
| `INCLUDE_SAMPLE` | –                                                               | `1` = Beispiel-Szenario `sample` dazuladen  |
| `TRUST_PROXY`    | `1`                                                             | `0` = Client-Adresse aus der TCP-Verbindung statt aus `X-Real-IP`/`X-Forwarded-For` (nur ohne Proxy davor) |

Ungültige Szenario-Dateien werden geloggt und übersprungen. Ist der Ordner leer, wird
`sample` geladen (wie in der App). Fehlender oder ungültiger Schlosskeller-Kanon
verhindert dagegen den Start, statt einen irreführenden grünen Healthcheck zu melden.

## Docker

Build-Kontext ist das **Repo-Root** (der Server braucht `packages/mordakte_core`):

```bash
docker build -f server/Dockerfile -t mordakte-server .
docker run --rm -p 8080:8080 mordakte-server
```

Das Image ist `FROM scratch` mit AOT-Binary, `content/scenarios`, `content/party` (alle Akten) und
`content/karten`. Es läuft ohne Root-Rechte.

## Railway

1. Neuer Service aus dem GitHub-Repo.
2. **Root Directory leer lassen** (= Repo-Root) – sonst fehlt dem Build `packages/mordakte_core`.
   `railway.toml` im Root wählt `server/Dockerfile`, Healthcheck `/health`.
3. Networking → Domain erzeugen. `https://<domain>/health` muss HTTP 200 liefern.
   Die öffentliche `wss://<domain>/ws`-Adresse als Repository-Variable `MORDAKTE_SERVER`
   für Actions und als gleichnamige Netlify-Variable setzen (kein Secret).
   Die App bekommt sie über `--dart-define=MORDAKTE_SERVER=wss://<domain>/ws`.
   Die Adresse wird erst nach Health- und Online-Matrix-Prüfung als freigegeben dokumentiert.
4. Genau **eine** Instanz, kein „Serverless/Sleep“: Räume liegen im Speicher. Ein Deploy
   beendet laufende Partien (die Apps melden dann `room_not_found`).

## Protokoll-Details

Umschläge wie in `packages/mordakte_core/lib/src/protocol/messages.dart`, mit diesen Ergänzungen:

- **`w`**: `WorldSnapshot.toJson()` enthält selbst ein Feld `t` (Laufzeit), das mit dem Typ
  kollidiert. Die Laufzeit steht deshalb unter `wt`: `{"t":"w","wt":12345,"phase":…}`
  (`lib/wire.dart`, gelesen in `lib/session/online_session.dart`).
- Zusätzliche Fehler-Schlüssel: `server_error` (Ausnahme beim Erstellen/Beitreten),
  `server_full` (zu viele Räume).
- Close-Code `4000`: Eine neuere Verbindung mit demselben Token hat übernommen.
- Reconnect: `hello` mit bekanntem Token → gleiche Spieler-ID; war der Spieler in einem Raum,
  folgen sofort `room` und `c` (klassisch) bzw. die eigene `abend`-Ansicht (Party).
  Nach 120 s ohne Reconnect → `leave`; beim Partyabend bleibt die Rolle für dieselbe
  Identität erhalten und fehlende Stimmen übernimmt danach ein Bot.
- `hello` mit `"resume": false` (erster Aufbau der App, danach kommt `create`/`join`): Die
  Mitgliedschaft im alten Raum bleibt, aber `room`/`c`/`w` dieses Raums kommen erst nach einem
  `join` mit seinem Code. Ohne das Feld wie oben.
- Ein zweites `hello` mit anderem Token auf demselben Socket → `err protocol`.
- Limits: 8 KB pro Nachricht (über 16 KB, auch fragmentiert, wird der Socket sofort getrennt),
  40 Nachrichten/s pro Socket (darüber verworfen), 1 `create` pro 2 s und Spieler (`err cooldown`),
  42 offene Sockets pro Client-Adresse (21 Teilnehmer mit Reconnect-Reserve),
  10 000 insgesamt (darüber HTTP 503).
- Wer einen Raum verlässt, bekommt beim Wiederbeitritt keine alten Ereignisse nachgeliefert.
- Leere Lobbys schließen sofort; andere Räume 5 Min nach dem letzten verbundenen Spieler bzw.
  10 Min nach Spielende. Tokens ohne Raum verfallen nach 30 Min (nie in einem Raum: 2 Min).

### Partyprotokoll (Version 1)

- `create` mit `abend: "<akte-id>"` (jede Kennung aus `content/party/akten.json`, zum Beispiel `schlosskeller`
  oder `ravensmoor`) legt einen Partyraum dieser Akte an; ohne dieses Feld bleibt `create` unverändert
  klassisch. Eine unbekannte Kennung wird abgewiesen. `join` nutzt den gemeinsamen Raumcode.
- `abend_cmd` trägt unter `c` einen festen `typ` und die passenden Felder:
  `bereit`, `start`, `rollenGelesen`, `weiter`, `wahl`, `aktionFertig`,
  `wuerfelHilfe`, `wurf`, `tischruf`, `fundGelesen`, `stimme`, `anklage`.
  Unbekannte Felder (insbesondere fremde Spieler-/Rollen-IDs und Würfelaugen)
  werden abgewiesen. Eine optionale `revision` verhindert veraltete Aktionen.
- `abend` enthält öffentliche, pfadunabhängige Optionen und unter `privat` nur die
  eigene Rollenkarte. Die Optionenreihenfolge kommt **nicht** aus dem geheimen
  Fall-Code. Die Anmeldeidentität entscheidet, niemals ein Rollenfeld des Clients.
- Der Gastgeber steuert den gemeinsamen Detektiv. Gewürfelt wird reihum; die
  vorab sichtbare Hilfe-/Chancenwahl und der eigentliche Wurf sind getrennt.
- Vor dem ersten Zug gibt es eine SHA-256-Zusage des zufälligen Server-Salzes;
  erst im Finale erscheinen Salz, Fall-Code und Lösung. Jeder Wurf lässt sich
  dann nachrechnen. **Noch offen:** gemeinsame Commit/Reveal-Beiträge aller Geräte
  gemäß der BOLLWERK-Fairnessregel und Wiederherstellung nach Serverneustart. (Im Relais-Weg der App
  stellt das Gastgeber-Gerät den Abend aus seinem abgelegten Protokoll wieder her.)
- Die Kartenaktion muss durch `aktionFertig` mit der aktuellen Aktionsnummer
  bestätigt werden. Die sichtbare Animation in der App ist separat zu integrieren
  und abzunehmen; ein Protokolltest ist dafür kein Bildbeleg.

## Aufbau

| Datei                | Inhalt                                                  |
|----------------------|---------------------------------------------------------|
| `bin/server.dart`    | Einstieg: Env, Szenarien, HTTP, SIGTERM                 |
| `lib/server.dart`    | Shelf-Handler: `/health`, `/ws`                         |
| `lib/connection.dart`| Eine WebSocket-Verbindung: Parsing, Limits              |
| `lib/rooms.dart`     | `RoomManager`, `Room` (Tick-/Snapshot-Schleife), Spieler |
| `lib/runtime.dart`   | Gemeinsamer Lebenszyklus, klassische und Party-Schnittstelle |
| `lib/party.dart`     | Kanon-Lader für alle Akten und Adapter auf `SchlosskellerRaum` |
| `tool/party_matrix.dart` | Ein Partyraum mit 4–20 echten Clients, privater Zustand |
| `tool/relay_matrix.dart` | Ein Abend über das Supabase-Relais (lokal oder live)   |
| `lib/codes.dart`     | Raumcodes (ohne 0/O/1/I), Spieler-IDs, Tokens           |
| `lib/wire.dart`      | JSON-Umschläge                                          |
| `lib/scenarios.dart` | Szenarien von Platte laden                              |
| `tool/smoke.dart`    | Smoke-Test                                              |
