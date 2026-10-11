# Morgenbericht „Ein Mordakte“

Stand: 2026-10-11, Branch `claude/ecstatic-lamport-w4jlzn` (auf `main` per Fast-Forward nachgezogen).
Details und Entscheidungen: [STATUS.md](STATUS.md), Plan: [PLAN.md](PLAN.md).

## Was es jetzt gibt

- **Ein Spiel, eine Kampagne.** Start ist die Detektei. Es gibt fünf Akten mit einem Regelwerk:
  Schlosskeller, Spuk im Gewölbe, Ravensmoor 1891, Nachtexpress 1931 und Blue Palm 1986.
  Die drei alten Spiele sind keine Modi mehr. Die klassische Echtzeit-Engine liegt nur noch hinter `?dev=klassisch`.
- **Spielweisen** wählst du vor jedem Abend im Assistenten:
  - **Solo mit Bots**
  - **Ein Gerät reihum**
  - **Jeder am eigenen Gerät**: Raumcode bzw. QR, Ende-zu-Ende verschlüsselt über das Supabase-Relais.
- **Sammelkarten.**
  - 171 Karten: jede Figur jeder Akte und fünf Detektivklassen.
  - Deck mit 3 Plätzen, Tischvorrat höchstens 3 Karten und 4 Ladungen.
  - Karten sind reiner Komfort. Sie ändern nie Fakten, Punkte oder Ende.
  - Erhältlich am Abendende über:
    - die eigene Rolle oder Klasse;
    - die Täterkarte bei richtiger Anklage;
    - eine legendäre Karte beim Meister-Ende;
    - Abstecher-Funde (33 Orte);
    - solo und reihum eine Karte einer Figur vom Tisch.
- **Design.**
  - Design-System mit Akte-Stilen.
  - Weicher Nebel statt Schwarz, Kamera auf die Ziele.
  - Farbige Kartenfronten mit Büsten.
  - Geprüft bei 320 px und 200 % Schrift.

## Herunterladen

| Plattform | Datei |
| --- | --- |
| Android | [`mordakte.apk`](https://github.com/umutcantezgel-cpu/Murder_Mystery/releases/latest/download/mordakte.apk) |
| iPhone, iPad | [`mordakte-ios-unsigned.ipa`](https://github.com/umutcantezgel-cpu/Murder_Mystery/releases/latest/download/mordakte-ios-unsigned.ipa) (mit AltStore/Sideloadly signieren) |
| Web | [`mordakte-web.zip`](https://github.com/umutcantezgel-cpu/Murder_Mystery/releases/latest/download/mordakte-web.zip), außerdem Vercel aus `main` |

Die Release `mordakte-49.1` wurde heruntergeladen und geprüft:
- Die Prüfsummen stimmen.
- Die APK hat die Internet-Berechtigung, die Relais-Adresse ist eingebaut.
- Die IPA enthält `Payload/Runner.app`.

## Wie geprüft wurde

Die Tests hat ausschließlich Haiku geschrieben und ausgeführt.

- **Kern:** 481 Tests, darunter:
  - 9.216 Abende kanongleich;
  - Fairness-Invarianten mit und ohne Karten;
  - Prüfung aller fünf Akten mit 0 Befunden.
- **App:** 259 Widget-Tests.
- **Netzpaket:** 48 Tests. Jeder Online-Fix ist durch Mutationsprüfung abgedeckt.
- **Relais-Matrix lokal** mit 4 und 8 Geräten: Mithörer ohne Klartext, Einspielungen abgewehrt.
  Die Matrix lief außerdem live gegen Supabase.
- **Browser:**
  - Start bei 320 und 390 px;
  - kompletter Solo-Abend;
  - Online mit Gastgeber und zwei Gästen: kein Gast sieht fremde Dossiers;
  - „Abend abbrechen“.
- **Abschluss-Review:** fünf Prüfer, jeder Befund adversarial gegengeprüft. 19 echte Befunde wurden
  behoben, gegengelesen und getestet. Darunter:
  - Abbrechen und Android-Zurück;
  - Online-Wiederverbindung, Ablehnungsgründe und Wiederholschutz;
  - Schlosskeller-Würfeltexte in anderen Akten.

## Was nur du tun kannst (einmalig)

1. **GitHub Pages** (optional): Settings → Pages → Source: *GitHub Actions*. Bis dahin schlägt der Job
   „GitHub Pages veröffentlichen“ fehl, ohne die Release zu blockieren.
2. **Supabase-Projekt `mordakte` aktiv halten:** Es pausiert nach 7 Tagen ohne Nutzung. Dann im Dashboard
   wieder aktivieren, oder über `vars.MORDAKTE_RELAY_URL`/`vars.MORDAKTE_RELAY_KEY` ein eigenes Projekt setzen.
3. **Eigene Signatur** (optional): Android-Keystore- und Apple-Secrets laut README, Abschnitt „Builds und
   Signatur“. Ohne sie gibt es eine Test-signierte APK (Updates ohne Deinstallation) und eine unsignierte IPA.
4. **Vercel:** Root Directory am besten `./`. Mit `tool/e2e` funktioniert es dank `tool/vercel_build.sh` ebenfalls.

## Bewusst offen

- Keine Host-Migration: Fällt das Gastgeber-Gerät aus, pausiert der Abend. Er lässt sich auf demselben Gerät
  über „Zurück zum Abend“ fortsetzen.
- Die 84 vollständigen E2E-Läufe laufen nur auf Knopfdruck (`workflow_dispatch`), nicht bei jedem Push.
- Online-Gäste ohne Netz sehen jetzt „Keine Verbindung“. Ein Gastgeber, der dauerhaft offline bleibt, beendet
  den Abend für alle.
