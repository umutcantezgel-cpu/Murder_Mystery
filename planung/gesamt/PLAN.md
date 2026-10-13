# Mordakte 1.0 „Großer Fall“: den Bestand erweitern und finalisieren

## Context
Heute: ein Spiel, fünf Akten, ein Regelwerk (Release mordakte-56.1). Das Design wirkt billig:
- **Welt:** Code-Zeichnung mit ~30 px großen Papierpuppen (Punktaugen, keine Hände). 7–10 Räume je Akte, jeder Boden „Stein“, keine Außenbereiche. Das Licht ist eine Dunkelschicht mit Löchern. NPCs stehen still, und es gibt keine Inszenierung.
- **Oberfläche:** ein dunkler Kasten (`MTafel`) für alles, Material-Standardwidgets, Fließtext in Inter, Figuren als Farbpunkte, vier konkurrierende Stilsysteme. Der gelungene Mappen-Look (`_CaseFile`) steckt nur in totem Code.
- **Spiel:** lineare Entscheidungen ohne Gesprächswahl, Bedienung per Erklärtext. Ein laufender Abend geht beim Neuladen verloren.

**Entscheidungen des Besitzers (2026-10-13):**
1. Alles per Code auf der bestehenden Designidentität.
2. Feinkorn und Burgstadt fliegen komplett raus.
3. Der Verräter wird ein eigener Modus.
4. Moderne Hub-Stadt „Altstadt“ (Anspielung auf die Wetzlarer Altstadt) und größere Schauplätze.
5. Genau zwei neue Pakete: `flutter_soloud` und `share_plus`.
6. Nur Deutsch.
7. Eigenes Relais, Supabase als Rückfall.
8. Kostenlos, ohne Werbung, ohne Käufe, ohne Datenerhebung.
9. **Schneller launchen. Das Bestehende erweitern und finalisieren: keine neue Engine.**

**Folge:** Der große Neubau-Plan (eigene Engine, ~38 Wochen) entfällt. Stattdessen wird der vorhandene Code ausgebaut (Renderer `lib/game`, Stil `lib/stil`, Kern `packages/mordakte_core`, Netz). Alles Verlangte kommt, verteilt auf einen schnellen Zug: **1.0 → 1.1 → 1.2**.

## Leitlinien
- Jede Stufe hält die App auslieferbar und die CI grün. Gearbeitet wird auf `claude/beautiful-meitner-fh1mkq`, die CI-Auslöser bekommen diesen Branch.
- **Unverändert bleiben (Stolperdrähte):**
  - Kanon-Prüfsummen (A-002: `content/party/schlosskeller/**`, `krimidinner/**`, `content/scenarios/**`)
  - `determinismus_soll*.g.dart` und der Beweis über 9.216 Abende
  - `karte_pfadgleich_test` und die Spoiler- und Ton-Tests
  - die E2E-Verträge (`?party=`, `PARTY phase=`)
- Neue Inhalte liegen nur in neuen Ordnern: `content/welt/<akte>/`, `content/erzaehlung/<akte>/`, später `content/stadt/`.
- Sichtbare Texte stehen in `lib/l10n/app_de.arb`. Der Text-Wächter bleibt streng; Schriftnamen stehen nur in `lib/stil/schriften.dart`.
- **Fairness:**
  - Kamera, Licht, NPC-Leben, Ton und Gesten hängen vor dem Finale nie vom Täterpfad ab.
  - Dialoge würfeln nicht, kosten keine Nachtminuten und schreiben nie in die Wertung (Regeln R1–R12).
- **Ton:** kein Blut, keine Wunden, kein Alkohol, kein Rauchen. Die Pfeife ist eine Seifenblasenpfeife.
- Inhaltstexte werden nicht zur Laufzeit in Großbuchstaben gesetzt (`toUpperCase`); Versalien gibt es nur gemalt.

## Release 1.0: der Bestand auf 10/10 (Ziel ≈ 12–14 Programmwochen)
| M | Inhalt | Kernorte |
|---|---|---|
| M0 Aufräumen + Werkbank | Feinkorn, `room_host` und die Feinkorn-Werkzeuge löschen. `messen.mjs` → `tool/e2e/leistung.mjs`. Burgstadt-Reste neutralisieren. Ein einziger Altlast-Wächtertest. CI-Auslöser für den Arbeitsbranch. SDK unter `.werkzeug`. | `packages/feinkorn`, `packages/room_host`, `lib/game/dev/feinkorn_k0_main.dart`, `tool/feinkorn`, `pubspec.yaml`, `tool/pruefen.sh`, `tool/bollwerk/*`, `.github/workflows/release.yml` |
| M1 Ermittlungsmappe: Fundament | **Schriften:** Playfair Display (Titel), Lora + Lora Italic (Lesetext), Courier Prime, Caveat (Handschrift); Special Elite und Inter bleiben bytegleich. **Tokens:** Papier, Manila, Tinte, Stempelrot, Kork, Messing. **Prozedurale Papiertextur.** **Bausteine:** Aktenmappe mit Reiter, Blatt-Varianten (Bericht, Karteikarte, Protokoll, Telegramm, Foto mit Klammer), Stempel, Siegel, Geheimumschlag, Messingschild-Knopf, Karteikarten-Dialog statt `AlertDialog`, Korkwand, Schreibmaschinen-Enthüllung. Ruhige Bewegung wird beachtet. | `lib/stil/**` (übernimmt `lib/ui/widgets/paper.dart`, `typewriter.dart`, Korkwand aus `notebook.dart`), `assets/fonts/**` |
| M2 Alle Bildschirme in Mappen | Detektei als Schreibtisch. Akte als Aktenmappe (Muster `_CaseFile`). Assistent. Abend: Dossier mit Reitern und „Geheim“-Siegel, Erzähltext als getippte Berichtsblätter, Gespräche als Protokollbögen mit Porträt, Karte und Funde als Karteikarten, Würfelbrett, Stimmzettel, Resümee, Anklage mit Fahndungsfotos und Stempel, Finale, Auflösung. Dazu Belohnung, Sammlung, Profil, Online-Lobby und Gast, Abbrechen. Die vier Stilsysteme werden eins. | `lib/detektei`, `lib/abend`, `lib/party/bildschirme`, `lib/party/erzaehler_ausgabe.dart`, `lib/karten`, `lib/app/theme.dart`, `lib/party/party_stil.dart` |
| M3 Figuren 2.0 | `FigurePainter` bekommt intern ein Rig: Knochen, 8 Blickrichtungen, Hände, Gesicht mit Blinzeln, Brauen und Mund, Garderobe nach `LookDef` plus optional `content/welt/<akte>/aussehen.json`, Clips (Gehen, Stehen, Gesten, Sitzen, Knien, Suchen, Reden), Nachschwingen von Mantel und Haar. Die API bleibt, Teile werden gecacht. Porträts in der Oberfläche nutzen dieselben Rezepte. | `lib/game/scene/figure_painter.dart` (+ `figur/`), `lib/ui/widgets/portrait.dart` → `lib/stil` |
| M4 Welt ausbauen | **Böden und Fenster:** echte Böden aus `raeume.json boden`; Außenräume mit Wetter; Fenster. **Kulisse:** Requisiten veredeln und `content/welt/<akte>/kulisse.json` (Außenbereiche um den Kanonblock, nur Darstellung). **Darstellung:** Boden gestückelt backen, nähere Kamera je nach Lage, Licht und Farbkorrektur je Akte. **Bewegung:** Tippen-zum-Gehen (Joystick optional), Beschleunigen und Bremsen, schwingende Türen, Teilchen. **NPC-Leben:** pfadfreie Ankeraufgaben im Takt der Szene. | `lib/game/**`, `lib/party/karte_session.dart`, `lib/party/karten_aktion.dart`, Szenen-Export als App-seitiger Adapter |
| M5 Szenenregie | **Gespräch:** Zweier-Einstellung und Heranfahren beim Befragen, Letterbox, Gesten pro Zeile. **Lenken ohne Text:** Etablierungsschwenk über die Ziele, Leuchtzeichen statt Steuertext, Hinlenken bei Untätigkeit. | `lib/game/mordakte_game.dart` (Kamera), `lib/party/bildschirme/karte.dart` |
| M6 Gespräche mit Wahl | **Kern** `erzaehlung/`: pfadfreie `ErzaehlUmwelt`, Dialogbäume mit Gesprächshaltungen (freundlich, drängen, bluffen, vorlegen), Flags, Ereignisse, Epiloge, Prüfer, Erzähltiefe (aus = heute). **Inhalte:** zuerst Ravensmoor und Schlosskeller. **App:** inszenierte Gesprächsszene. | `packages/mordakte_core/lib/src/erzaehlung/**`, `content/erzaehlung/**`, `lib/party/**` |
| M7 Ton | `flutter_soloud`. Klänge und Atmosphäre je Akte per Code erzeugt (Werkzeug `tool/klang`), dazu Musikschichten, Mischpult und Einstellungen; in Tests bleibt der Ton stumm. | `packages/mordakte_klang`, `lib/klang`, `assets/klang` |
| M8 Fortsetzen, Teilen, Store | **Fortsetzen und Speicher:** Abendstand als Befehlsprotokoll, „Abend fortsetzen“, Spielerdaten v3. **Teilen:** Karten über `share_plus`, Deep Links über einen eigenen Kanal, QR nativ. **Store:** AAB mit echter Signatur, `ITSAppUsesNonExemptEncryption`, Ausrichtung, Datenschutz und Store-Texte, Store-Bilder per Pipeline, Onboarding mit „Wow in 60 s“. | `lib/abend`, `lib/meta`, `android/`, `ios/`, `web/`, `store/` |

## Release 1.1 (≈ +6–8 Wochen): Altstadt und Breite
- **Hub-Stadt „Altstadt“** als große Karte im selben Renderer:
  - Dom, Fachwerk, alte Lahnbrücke, Kopfstein, Gassen.
  - Detektei, Archiv der Akten, Café als Treffpunkt, Kiosk mit dem Fall des Tages.
  - 40–60 Einwohner mit Tagesabläufen und Tag-und-Nacht-Wechsel.
  - Namensraum `stadt:`, nie das Salz.
- **Fall des Tages:** für alle gleich, teilbar, mit Serie.
- **Dialoge und 10×-Kulissen** für Gewölbe (teils aus K4 übernommen), Nachtexpress und Blue Palm; Epilog-Galerie.

## Release 1.2 (≈ +6 Wochen): Verräter-Abend und Koop-Ermittlung
- **Verräter-Abend** als eigener Kern auf `AbendRaum`:
  - Sabotage: Licht aus, Tür zu, Uhr.
  - „Einsperren“ statt Töten, danach flüstert die Person Hinweise.
  - Lagebesprechung an der Korkwand, Schnellchat-Vorlagen, Abstimmung.
  - Bots für fehlende Spieler.
- **Netz:** eigenes verschlüsseltes Relais in `server/` (Railway), Supabase als Rückfall.
- **Koop:** Pinnwand mit Kombinationen, private Befragungen und eine Beratungsphase.
- **Später** (alles von der Planung erfunden): Clip-Export, Streamer-Modus, Nebengeschichten.

## Verifikation (jede Stufe)
- **Lokal:**
  - `bash tool/pruefen.sh schnell` und `flutter test`.
  - Je Akte `dart run bin/akte_pruefen.dart --fall <id>`.
  - Web-Build plus Browserproben `start.mjs`, `solo.mjs`, `runden.mjs`.
  - Kontaktbögen der Bildschirme (Playwright-Fotos bei 320 und 390 px) zum Ansehen.
- **CI:** Push auf den Arbeitsbranch → `gate` grün, Release mit APK, IPA und Web.
- **Besitzer:** Geräteprobe und Abnahme bei M2 (Mappen), M3 (Figuren) und am Ende von 1.0.

## Aufgaben des Besitzers
- Signatur-Secrets für Play.
- Apple-Developer-Konto.
- Railway-Projekt (für 1.2).
- Domain für Datenschutz und Deep Links.
- Testgeräte.
- Play-Closed-Test mit 12 Testern über 14 Tage.
- Abnahmen.
