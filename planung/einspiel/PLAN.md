# Nachtplan „Ein Mordakte“: drei Spiele werden ein Spiel

## Context

Heute enthält das Repo drei getrennte Spiele, jedes mit eigener Navigation, eigenem Look und eigener Sitzungsschicht:
- **Klassische Fälle**: Echtzeit, 1–6 Detektive, `packages/mordakte_core/lib/src/engine`.
- **Schlosskeller-Partyabend**: rundenbasiert, 4–20 Rollen, `…/party`, `…/runden`, `lib/party`.
- **Krimidinner „Spuk im Gewölbe“**: nur ein Begleiter, `packages/krimidinner_kanon`, `lib/krimidinner`.

Was heute fehlt:
- Es gibt keine Kartensammlung. Fortschritt wird nur bei klassischen Fällen gespeichert.
- Online-Party hat keinen App-Client, und kein Server ist öffentlich erreichbar.
- Die CI baut seit `ba4f0cb` keine APK mehr, weil die 84 E2E-Läufe ihre Zeitlimits überschreiten.
- Es gibt keinen iOS-Build und keinen Web-Deploy.

**Ziel der Nacht:** **ein** Spiel „Mordakte“:
- ein Start und ein Regelwerk;
- eine Kampagne aus fünf **Akten**: Schlosskeller, Gewölbe, Ravensmoor, Nachtexpress, Blue Palm;
- eine Figuren- und Kartensammlung mit dauerhaften, im Spiel erspielten Karten;
- ein aufgewertetes Design;
- vor jedem Abend wählbar: **Solo mit Bots**, **ein Gerät reihum** oder **jeder am eigenen Gerät** (Raumcode).

Am Morgen sollen herunterladbar sein: APK, iOS-IPA (zum Sideloaden) und Web/PWA, und das Online-Spiel soll über einen echten Server laufen. Ich arbeite ohne Rückfragen und treffe Entscheidungen selbst. Was du einmalig selbst tun musst, steht gesammelt im Morgenbericht.

## Leitentscheidungen

1. **Ein Regelwerk.** Jede Akte läuft gleich ab:
   - Rollen lesen.
   - 3 Runden mit je: Gespräche → 3 Ermittlungsentscheidungen (sichtbare Kartenaktion, Kellerwürfel, Fund) → geheime Gruppenwahl → Resümee.
   - Anklage → Finale → Auflösung → **Belohnung** (Karten, XP).

   Grundlage sind `RundenPartie` und `SchlosskellerRaum`. Der Beweis über 9.216 Vergleiche bleibt gültig, ebenso die Regeln K-05…K-22 und WÜ-1…6. Akten sind Inhalt, keine Spielmodi.
2. **Ein Format.** Jede Akte ist ein Bündel im Party-Kanonformat unter `content/party/<akte>/`, dazu ein Kampagnenindex `content/party/akten.json`. `PartyDaten.laden(fall:)` und `ladeKanon(fall)` sind schon parametrisiert.
   - Gewölbe und die Klassiker entstehen per Konverter aus den unveränderten Quellen plus einem Autoren-Overlay `content/party/<akte>/_autor/`.
   - Ein Drift-Test prüft, dass der Konverter byte-gleich dasselbe Bündel erzeugt.
   - **Eine fehlende Angabe bedeutet immer Schlosskeller-Verhalten.** Die physische Simulation (`tatmatrix`, `wahrnehmung`) ist je Akte optional.
3. **Kanon bleibt unverändert** (A-002): `krimidinner/**`, `content/party/schlosskeller/**` und `content/scenarios/**` werden nicht angefasst. Ein Prüfsummen-Test sichert das ab Meilenstein M0 ab.
4. **Die klassische Echtzeit-Engine verschwindet aus der Oberfläche.** Code und Tests bleiben, erreichbar über das Entwicklerflag `?dev=klassisch`.
   - Grund: Sie ist ein zweites Regelwerk, lässt sich nicht reihum spielen und widerspricht K-15.
   - Ihre Inhalte werden Akten: Karten, Räume, Verdächtige, Hinweise, Enden, Paletten und Wetter.
   - Die 5 Detektivklassen werden Klassenkarten.
5. **Karten.**
   - **Umfang:** Jede Figur jeder Akte und jede Detektivklasse bekommt 2–3 dauerhafte Karten. Kennung `<akte>:<figur>:<slug>`, drei Seltenheiten. Der Code liegt in `packages/mordakte_core/lib/src/karten/`, weil auch Raum und Server sie prüfen.
   - **Wirkungen** (geschlossener Katalog): werkzeug +1 (die Obergrenze +2 bleibt), +1 Marke (Grenzen 1/2/3 bleiben), Zeit +5, gründlich ohne Zeitkosten, Nochmal oder Umweg ohne Zeitkosten, Abstecher ohne Zeitkosten, Erinnerung (wiederholt nur bereits öffentliche Texte), Kosmetik.
   - **Gestrichen**, weil sie gegen Regeln verstoßen: auftakt, schutz, bilanz.
   - **Fairness:** Keine Karte berührt Option, Fakten, Punkte, Ende oder Restverdächtige. Karten wirken erst, wenn die Wahl feststeht. Bots haben keine Karten.
   - **Tischvorrat:** höchstens 3 Karten pro Abend, je Art höchstens 1, zusammen höchstens 4 Ladungen. Das gilt unabhängig von der Besetzung (K-06).
   - **Belohnungen** berechnet die Kernfunktion `belohnungFuer(...)` aus dem Strom `karten:<salz>:<spielerId>`, erst nach dem Finale:
     - immer eine Karte der eigenen Rolle oder Klasse;
     - die Täterkarte bei richtiger Anklage;
     - eine legendäre Karte beim Meister-Ende.
   - **Abstecher-Funde:** Neu ist die *Erkundung* (Abstecher). Optionale Nebensuchen kosten Nachtminuten, sind auf allen Pfaden gleich und geben Nebenfunde und Kartenfunde. Dadurch bekommen Zeit, Würfel und Komfortkarten echten Spielwert. Gesammelt wird lokal in MetaStore v2.
6. **Gerätearten, im Assistenten vor dem Abend gewählt:**
   - **Solo:** Du ermittelst, Bots spielen die Rollen.
   - **Reihum:** ein Gerät mit verdeckten Ansichten.
   - **Eigene Geräte:** Der Gastgeber ist der Detektiv und nutzt die vorhandenen Bildschirme über einen Adapter am Raum. Gäste treten per Raumcode bei und bekommen schlanke Projektionsbildschirme. Bots füllen freie Rollen, überzählige Spieler werden Assistenz-Plätze ohne eigene Rolle.
7. **Server: Supabase Realtime als Relais, das Gastgebergerät entscheidet.**
   - Neues kostenloses Supabase-Projekt `mordakte` in eu-central-1. Die Org ist im Free-Plan, ein Platz ist frei.
   - Das Phoenix-Protokoll schreibe ich selbst auf dem vorhandenen `web_socket_channel`.
   - Jeder Platz bekommt ein eigenes Thema, damit die Free-Plan-Grenze von 100 Nachrichten/s hält.
   - Private Ansichten sind Ende-zu-Ende verschlüsselt: X25519, HKDF und ChaCha20-Poly1305 über `package:cryptography`. Das ist eine **bewusste neue Abhängigkeit (A-014)**; die zusätzlichen Pakete prüfe ich mit `dart pub deps`.
   - Raumcode: 6 Zeichen, gebunden an den Gastgeberschlüssel.
   - Der Dart-Server bleibt ein optionaler Weg über `MORDAKTE_SERVER`. Es gibt keine Host-Migration (Entscheidung wird dokumentiert).
8. **Modellrollen, wie du sie vorgegeben hast:**
   - **Opus (Hauptsitzung):** orchestriert, entwirft Schnittstellen, macht die fairnesskritischen Kernänderungen und das Entscheidungsdesign neuer Akten, merged und prüft.
   - **Sonnet:** Umsetzungspakete in eigenen Git-Worktrees (CI, Oberfläche, Netzpaket, Konverter, Texte). Sonnet startet nur `flutter analyze` und `dart analyze`, keine Tests.
   - **Haiku: ausschließlich alle Tests.** Haiku schreibt Tests nach Opus-Vorgabe, führt `dart test`, `flutter test`, Browser-Smokes und CI-Logs aus und berichtet Fehler.
   - Der Testumfang bleibt bewusst schlank: Pflicht sind Invarianten und Beweise, Bedienungstests nur als wenige Smokes.

## Arbeitsweise in der Nacht

- **Branch:** Alles läuft nur auf `claude/ecstatic-lamport-w4jlzn`. A-001 („nur main“) wird für diese Nacht durch die Sitzungsregel ersetzt und als A-015 dokumentiert.
  - Häufig sichern: nach jedem grünen Meilenstein-Merge committen und pushen.
  - Kein Force-Push, kein PR (nicht verlangt).
- **Bahnen:** Höchstens 2 parallele Agenten, wegen 4 CPUs und der Workflow-Grenze.
  - **Bahn O** (Opus, Haupt-Checkout) besitzt den Kern: `packages/mordakte_core/**`, Schemas, `akten.json`, `pubspec.yaml`.
  - **Bahn S1** (Sonnet, Worktree) besitzt CI und Werkzeuge, dann `lib/**`, `app_de.arb` und `test/app`.
  - **Bahn S2** (Sonnet, Worktree) besitzt `packages/mordakte_netz/**`, `server/**`, Konverter und `content/party/<neue Akte>/**`.
  - Jede Datei hat genau eine Besitzerbahn. Änderungswünsche an fremde Dateien laufen über mich.
- **Werkzeug:**
  - Flutter 3.47.6 kommt einmal über `tool/flutter_env.sh` in den Haupt-Checkout. Worktrees nutzen es per Symlink `.werkzeug`, damit nicht jedes 1 GB lädt.
  - Web-Builds und Browserläufe laufen nacheinander, nie parallel.
  - Für direkte `flutter test`-Aufrufe gilt `ulimit -s 8192`.
- **Ablauf je Paket:**
  1. Sonnet setzt im Worktree um und committet lokal.
  2. Ich merge in den Branch.
  3. Haiku führt das Meilenstein-Tor aus.
  4. Ist es grün: Push. Dann überwache ich die CI mit `actions_list`, `get_job_logs` und `get_latest_release`.
  5. Ist es rot: Fehlerbericht an Sonnet oder an mich und nachbessern. Kein Test wird übersprungen oder abgeschwächt.
- **Wiederaufnahme:**
  - `planung/einspiel/STATUS.md` hält Meilensteinstand, Entscheidungen A-014ff., offene Punkte und Belege fest. Nach einer Kontextverdichtung oder einem Containerneustart lese ich zuerst diese Datei.
  - Ein Sicherheits-Weckruf per `send_later` etwa alle 90 Minuten („Nachtwache: weiter am nächsten offenen Meilenstein“). Er wird gelöscht, sobald alles fertig ist.
- **Rückfragen ersetzen:** `.claude/settings.json` bekommt Freigaberegeln für die genutzten Befehle (flutter, dart, git, node, npm, python3, `bash tool/*`) und die GitHub- und Supabase-MCP-Werkzeuge. Die Datei wird committet. Im Morgenbericht steht der Hinweis auf den Modus „Auto“ im Auswahlmenü.

## Meilensteine (nach jedem: grüner Merge, Push, CI baut APK)

### M0 · Werkbank, CI entsperren, Server anlegen (ca. 1 h)
- **Werkzeug:** Flutter laden, `flutter pub get`. Haiku führt die Ausgangsprüfung aus: `tool/pruefen.sh schnell` und `flutter test`.
- **CI** (S1, `.github/workflows/release.yml`):
  - Auslöser: Push auf `main` und auf den Branch, dazu `workflow_dispatch` mit Eingaben.
  - `concurrency` mit `cancel-in-progress: false`, also Warteschlange.
  - **gate** (unter 25 min): neue Stufe `pruefen.sh ci` mit Analyse, Pakettests, Party-Prüfungen, Server-Smoke, `party_matrix --clients=4`, `flutter test`, Web-Build, Smokes `start.mjs`/`runden.mjs`/`solo.mjs` und Secret-Scan.
  - **android:** APK mit fest eingecheckter **Test-Signatur** `tool/ci/signing/mordakte-test.p12`, damit Updates ohne Deinstallation gehen. Echte Secrets haben Vorrang. `prepare_android_signing.py` und seine Tests werden angepasst.
  - **ios** auf `macos-15`, nicht blockierend: `flutter build ios --no-codesign` erzeugt eine unsignierte IPA. `flutter_env.sh` lernt dafür Darwin.
  - **web:** zip, dazu ein Pages-Job mit `continue-on-error`.
  - **release:** APK, IPA, `mordakte-web.zip` und `SHA256SUMS.txt`, Tag `mordakte-<run>.<attempt>`. Als `latest` markiert, wenn der Ref noch auf diesen SHA zeigt.
  - **e2e_voll:** die 84 Läufe nur noch auf Knopfdruck oder per Zeitplan, als Matrix über die 4 Pfade.
- **Server:** **bereits erledigt** (2026-10-11 06:54 UTC): Supabase-Projekt `mordakte`, Ref `vuiyymgnkuilkbmxvcxo`, Status ACTIVE_HEALTHY, URL `https://vuiyymgnkuilkbmxvcxo.supabase.co`, öffentlicher Schlüssel `sb_publishable_VXH5oe02tG9hLrNlrI2jAQ_j4WhnX88` (der alte anon-JWT dient nur als Rückfall). Die Vorgaben landen in `packages/mordakte_netz/lib/src/relay_standard.dart`; das sind öffentliche Werte. `check_server_url.py` prüft den Relay. `secret_scan.sh` sucht nach `sb_secret_` und service_role.
- **Wächter:** Kanon-Prüfsummentest (A-002). Der Text-Wächter umfasst zusätzlich `lib/{abend,detektei,karten,stil}`.
- **Status:** `planung/einspiel/STATUS.md` anlegen, `.claude/settings.json` anlegen.
- **Ergebnis:** Push und erste Release vom Branch mit dem heutigen Spiel als Sicherheitsnetz.

### M1 · Kern verallgemeinern (Bahn O) ‖ Design-System und Ein-Spiel-Hülle (Bahn S1) (ca. 2 h)
- **O · Kern** (Engine-Entwurf G1–G18):
  - `Kanon.lade`/`dateienFuer`: Simulation optional; `pruefprofil`, `fallPraefix` und `zug` aus `fall.json`.
  - `spuren` mit der Bedingung `pfade`.
  - Simulator, Beweise, Verweise und Textprüfer werden profilgesteuert.
  - Erzähler bekommt `lagerunde`/`aushang`.
  - `FallCode.seedFuer`, `kettensperre` aus Daten, `ZugParameter.fromJson`.
  - Raum: `spiel`=settingId, Rollengrenzen aus der Besetzung, Assistenz-Plätze, `gewaehlt` und `akte`/`inhalt` in `zustandFuer`, Host-Platz festgenagelt.
  - **Das freie `wuerfelHilfe.werkzeug` wird entfernt** (K-07).
  - `szenario_export` liest `setting`. `raumgraph` versteht `rows`/`aussen`/`hell`. `karte` funktioniert ohne Simulation; neues Ziel `ueberlegung`.
  - Textsammlung mit Basis-Rückfall.
  - Gelockerte Schemas `content/party/schema-akte/`, `akten.json` (zunächst nur Schlosskeller).
  - `AbendRaum`-Schnittstelle und `ProtokollRaum`, der Aufrufe zum Wiederabspielen aufzeichnet.
- **O · Tor (Haiku):** Alle Schlosskeller-Zahlen bleiben identisch: 9.216 Vergleiche, `party_matrix` 17/17, `Erzaehler.katalog` unverändert, alle Pakettests grün.
- **S1 · Design** (App-Entwurf §2):
  - `lib/stil/` mit `tokens.dart` (ThemeExtensions MFarben/MSchrift/MMass/MBewegung, Grundton Kerzenmessing auf Tinten-Violett), `thema.dart` (`buildMordakteTheme`, `AkteStil` je Akte) und Widgets (MRahmen, MKnopf, MTafel, Papier, Chip, Porträt).
  - Shims in `party_stil.dart` per typedef, damit keine Massenänderungen nötig sind.
  - **Nebel-Fix:** kein Schwarz mehr; ein weicher Schleier mit `nebelDeckkraft ≤ 0,65` in `lib/game/scene/nebel.dart`; Dunkelheit 0,58.
  - **SpielKarte-Widget** mit Vorder- und Rückseite, Umdreh-Animation, Porträt aus LookDef, gotischem Rahmen und Seltenheits-Edelstein. Reduzierte Bewegung wird beachtet.
- **S1 · Hülle:**
  - Start `/` ist die **Detektei**: Profil, „Neuer Abend“, „Beitreten“, Kampagnenliste der Akten, Sammlungsvorschau.
  - `/akte/:id`.
  - Assistent `/abend/neu`: Akte → **Spielweise** (Solo / Reihum / Eigene Geräte; Eigene Geräte zunächst gesperrt) → Einstellungen (aus `EinrichtungBildschirm` herausgelöst) → Deck → Start. Danach `/abend` (`AbendSeite` auf `PartySitzung`).
  - Hub, Fallakten, Lobby, Online und Gewölbe-Begleiter fliegen aus dem Menü.
  - `/party?party=…` bleibt für die E2E-Skripte. `start.mjs` und `solo.mjs` werden im selben Commit auf den neuen Einstieg umgestellt.
  - Alle neuen Texte stehen in `app_de.arb` mit den Präfixen `detektei_`, `abend_`, `karten_` und `profil_`.
- **Tor (Haiku):** `start_test` (Detektei, 320/390 px, Schrift 200 %), `spielweisen_test`, `start.mjs`, `solo.mjs`, `runden.mjs`. Dazu Bildschirmfotos, die ich ansehe.

### M2 · Eigene Geräte online (Bahn S2 Netz, S1 Oberfläche) (ca. 2 h)
- **S2 · Paket `packages/mordakte_netz`** (Infra-Entwurf §1–2): `phoenix.dart`, `krypto.dart`/`umschlag.dart` (Codebindung, HKDF, AEAD, Wiederholschutz), `relay_host.dart`, `relay_gast.dart`, `server_verbindung.dart`, `Ablage`-Schnittstelle, `testing/phoenix_attrappe.dart`.
- **S2 · Server:** `AbendRaumRuntime` je Akte. `server/tool/relay_matrix.dart` mit `--lokal` und live; setzt `HttpOverrides` für den Proxy.
- **S1 · App:**
  - Assistent „Eigene Geräte“ mit Gastgeber-Lobby: Code, QR über `barcode` (ebenfalls A-014), Spielerliste, Bots füllen auf.
  - Der Gastgeber spielt mit den vorhandenen Bildschirmen über `RaumGebundeneSitzung`: Lesezugriffe gehen auf das Spiel des Raums, Absichten als `raum.nachricht`. Neu für den Gastgeber sind die Anzeigen „warte auf Rollenlesen“ und „warte auf Stimmen“.
  - **Gäste** bekommen 5 Projektionsbildschirme: Warten, Rolle/Dossier, Gespräche und Sprechblasen, eigene Stimme, Verlauf mit Würfen, Erzähler, Finale und Auflösung.
  - Beitreten per Code oder Deep-Link `?raum=`. Wiederverbinden mit dem Schlüssel als Token. Die Netzverbindung startet erst, wenn jemand „Eigene Geräte“ wählt.
- **Tor (Haiku):**
  - `mordakte_netz`-Tests: Umschlag, Manipulation, Wiederholung, Codebindung, Wiederholversuche.
  - `relay_matrix --lokal` mit 4 und 8 Clients, einschließlich Mithörer- und Privatheitsprüfung.
  - `raum_sitzung_test`.
  - `geraete.mjs`: Gastgeber und 2 Gäste gegen den lokalen Attrappen-Relay.
  - Live-Probe gegen Supabase aus dem Container, sonst über den CI-Job `relay_live`.

### M3 · Karten und Erkundung (O Kern, S1 Oberfläche, S2 Inhalt) (ca. 2 h)
- **O:**
  - `karten/{katalog,vorrat,wirkung,belohnung}.dart`.
  - Eine `KartenWirkung` in `RundenPartie`; `Zugschicht.zeitDazu` mit kostenfreiem Parameter.
  - `RundenPartie.abstecher*` als öffentliche Erkundung.
  - Raumnachrichten `start{vorrat}`, `wahl{karte}`, `wuerfelHilfe{marke,karte}`, `tischruf{karte}`, `abstecher{…}`, `karte{id}`. `vorrat` und nach dem Finale `drops` erscheinen in `zustandFuer`.
  - Der 9.216er-Invarianztest bekommt einen Kartenparameter. Haiku schreibt, ich gebe die Behauptungen vor.
- **S2 · Inhalt:** `content/karten/karte.schema.json` und `content/karten/<akte>.json` mit Karten für alle Schlosskeller-Figuren und die 5 Klassen. Dazu `content/party/schlosskeller-zusatz/abstecher.json`, außerhalb des Kanons und auf allen Pfaden gleich.
- **S1 · Oberfläche:**
  - MetaStore v2 (`karten`, `deck`, `akten`, `abende` für idempotentes Verbuchen, `einstellungen`; Migration mit Startset).
  - `/sammlung` (nach Akte, Figur und Seltenheit; verdeckte Silhouetten) und `/sammlung/deck` mit 3 Plätzen.
  - **Kartenhand** im Würfel- und Tischruf-Bereich.
  - Abstecher-Orte auf der Karte.
  - `BelohnungBildschirm`: Karten umdrehen, XP-Balken, Rangstempel. XP gibt es jetzt auch für Party-Akten.
- **Tor (Haiku):** `karten_test` (Migration, Idempotenz, deterministische Belohnung, gleiche Punkte und gleiches Ende mit und ohne Karten), Invarianz mit Karten, Solo-Smoke bis zur Belohnung.

### M4 · Akte Gewölbe (S2, Opus prüft das Entscheidungsmapping) — startet direkt nach M1-O, höchstens 3 h
- **Konverter** `packages/krimidinner_kanon/bin/akte_export.dart`:
  - VK-1 wird Kern, `pfade=[merle]`, `festeLoesung`.
  - D-Entscheidungen werden `entscheidungen` (Echte Spur → `richtig`, „Begründbar durch“ → Kette).
  - E-Entscheidungen werden Gruppenwahl; das ist eine bewusste Umordnung und wird als Entscheidung festgehalten.
  - G-Gespräche, H-Hinweise (Aushang, Pflichtgespräch), Meldekarten und EM-Enden werden übernommen.
- **Overlay:** Räume (Kamingewölbe, Speisekammer, Turm, Wehrgang, Hof, Torhaus), LookDefs für 22 Figuren aus K9, Gegenstände, Faktentypen, 9 Bonus-Hinweise, Rest- und Lagetexte, Karten.
- Die App stellt bei Akten mit fester Lösung keinen Fallcode ein und warnt vor Spoilern.
- **Tor (Haiku):** `akte_test` für die Akte:
  - Schema, Verweise und Simulator-Profil `[4,3,1]` über alle Folgen und Anklagen;
  - Textprüfer, Bot-Kette, bestes Spiel für jede Rollenzahl;
  - Privatheit, Pfadgleichheit, Erreichbarkeit der Karte;
  - Drift.
- Eine Akte, die eine Prüfung nicht besteht, wird nicht ausgeliefert.

### M5 · Klassik-Akten Ravensmoor → Nachtexpress → Blue Palm (S2 und Opus) (je ca. 1,5–2 h)
- **Konverter** `packages/mordakte_core/bin/akte_klassik.dart` überträgt mechanisch: Karte über `rows` einschließlich Fenster, Räume, Figuren und Looks, Merkmalsspuren je Pfad, Alibis, Motiv und Waffe, Enden aus `verdict`/`culprit`, Kapitel-Intros, Palette und Wetter.
- **Opus** entwirft die 9 Entscheidungen, `richtig` je Pfad und die Begründungsketten. Der Simulator ist dabei das Orakel.
- **Sonnet** schreibt pfadneutrale Gespräche, Dossiers, Gruppenwahl-, Erzähler- und UI-Texte (ohne Geburtstagskind), 3 zusätzliche Gäste je Akte (Rollen 4–8, darüber Assistenz-Plätze), eigene `textregeln.json` je Akte (Noir, ohne Blut-Details) und Karten.
- **Tor:** dieselbe `akte_test`-Schleife.

### M6 · Fertigstellen (alle Bahnen)
- Kampagne: Reihenfolge und Freischaltung aus `akten.json`; Akten-Seite mit gefundenen Enden und Karten.
- Klassik-UI und Begleiter löschen, sobald der neue Fluss grün ist. Dabei `room_host`, `feinkorn_k0_main.dart` und `feinkorn` aus der App-`pubspec` entfernen.
- Feinschliff: Paletten je Akte, Haptik beim Würfeln und Umdrehen, Semantik, reduzierte Bewegung.
- Gastgeber-Wiederaufnahme aus dem Protokoll.
- Doku:
  - README „So spielst du“: APK, IPA mit Sideload-Hinweis, Web-zip/Pages, Online per Code;
  - eine Anleitung `docs/ANLEITUNG.md`, die die drei bisherigen ersetzt;
  - `planung/einspiel/MORGENBERICHT.md`.
- **Abschluss:** `workflow_dispatch` mit `voll_e2e`, Release-Assets prüfen (APK-Größe, SHA, IPA vorhanden), Live-Relay-Abend.

**Zuerst gestrichen, falls die Zeit knapp wird** (in dieser Reihenfolge, Arbeit läuft notfalls in den Tag weiter):
1. Blue Palm und Nachtexpress.
2. Abstecher-Kartenfunde (Belohnungen am Abendende bleiben).
3. Pages und iOS-Signatur.
4. Löschen des Klassik-Codes.
5. Gastgeber-Wiederaufnahme.
6. Feinschliff über Tokens und Nebel hinaus.

**Nie gestrichen:**
- M0;
- der werkzeug-Fix;
- die Schlosskeller-Invarianten;
- die Wahl der Spielweise vor dem Abend;
- das Lösbarkeitstor für jede Akte;
- die Verschlüsselung (K-22), bevor Online als „fertig“ gilt.

## Kritische Dateien
- Kern: `packages/mordakte_core/lib/src/party/kanon/kanon.dart`, `party/simulator.dart`, `party/spuren.dart`, `party/erzaehler.dart`, `party/szenario_export.dart`, `party/raumgraph.dart`, `party/karte.dart`, `runden/zugschicht.dart`, `runden/partie.dart`, `runden/schlosskeller_raum.dart`, `content/party/schema/`.
- App: `lib/party/sitzung.dart`, `lib/party/karte_session.dart`, `lib/party/party_stil.dart`, `lib/party/daten.dart`, `lib/app/router.dart`, `lib/main.dart`, `lib/meta/meta_store.dart`, `lib/game/mordakte_game.dart` (`_renderNebel` etwa Zeile 1197), `lib/l10n/app_de.arb`.
- Netz und Server: neu `packages/mordakte_netz/**`; `server/lib/party.dart`, `server/lib/rooms.dart`, `server/tool/party_matrix.dart` als Vorlage.
- CI: `.github/workflows/release.yml`, `tool/pruefen.sh`, `tool/flutter_env.sh`, `tool/ci/{build_apk.sh,prepare_android_signing.py,check_server_url.py}`, `tool/secret_scan.sh`, `tool/e2e/{start,solo,runden}.mjs`.
- Wiederverwendet statt neu gebaut:
  - `PartySitzung`, Bildschirme, `KartenAktion`/A*, `PortraitPainter`/`LookDef`;
  - `Simulator`, `Beweise`, `kanonVerweise`, `Textpruefer`, `botGespraeche`;
  - `SchlosskellerRaum.zustandFuer` mit seiner Positivliste;
  - Token-Speicher (`token_store_*`), `OnlineSession`-Reconnect-Logik (wird in `server_verbindung` übernommen), `partySzenarioJson`.

## Verifikation (schlank, alles durch Haiku ausgeführt)
1. **Kern:** Kanon-Prüfsummen, Schlosskeller-Invarianten (9.216 Vergleiche einschließlich Kartenparameter, `schlosskeller_raum_test`, `party_matrix`), `akte_test` für jede Akte in `akten.json`.
2. **Netz:** `mordakte_netz`-Tests, `relay_matrix --lokal` (4/8 Clients, Mithörer, Spoofing, Reconnect), Live-Abend gegen Supabase (Container oder CI `relay_live`).
3. **App:** `start_test`, `spielweisen_test`, `raum_sitzung_test`, `karten_test`, die bestehenden Party-Widgettests nach Umstellung.
4. **Browser:** `start.mjs`, `solo.mjs`, `runden.mjs`, `geraete.mjs` (Gastgeber und 2 Gäste). Bildschirmfotos bei 320 und 390 px prüfe ich selbst.
5. **Auslieferung:** grüne CI auf dem Branch-SHA; Release `latest` mit `mordakte.apk`, `SHA256SUMS.txt`, `mordakte-web.zip` und, wenn der Mac-Job klappt, `mordakte-ios-unsigned.ipa`; Download ohne Anmeldung geprüft; APK-Integrität und Signaturzertifikat geprüft.
6. **Morgenbericht:**
   - was spielbar ist (je Akte und Spielweise);
   - Links;
   - was offen ist;
   - was nur du tun kannst: Pages einschalten (ein Klick), optional Android-Keystore- und Apple-Secrets, das Supabase-Projekt innerhalb von 7 Tagen nutzen oder den Branch mergen, damit der Keepalive-Zeitplan läuft, und im Menü den Modus „Auto“ wählen.
