#!/usr/bin/env bash
# Gesamtprüfung des Repos. Aufruf: tool/pruefen.sh [schnell|alles|ci|e2e]
#   schnell: Pakete auflösen, Analyse, Kern-Tests (Kanon, Logik, Partymodus)
#   alles:   dazu Szenario-Validator, Server-Smoke, Online-Matrizen, Flutter-Tests, Web-Build ohne CDN
#   ci:      wie alles, aber ohne die langsamen Matrizen (stattdessen Party-Matrix mit 4 Clients)
#            und dazu die schnellen Browser-Proben (Konfiguration, Start, Runden, Solo bei 320 px)
#   e2e:     alles plus alle 84 Party-Durchläufe (tool/e2e) gegen den Web-Build
# Zum Schluss läuft immer der Secret-Scan.
set -euo pipefail
cd "$(dirname "$0")/.."
STUFE="${1:-alles}"
case "$STUFE" in
  schnell|alles|ci|e2e) ;;
  *) echo 'Aufruf: tool/pruefen.sh [schnell|alles|ci|e2e]' >&2; exit 2 ;;
esac
if [ -f .werkzeug/env.sh ]; then
  # shellcheck disable=SC1091
  source .werkzeug/env.sh
elif [ -x .werkzeug/flutter/bin/flutter ]; then
  export PATH="$PWD/.werkzeug/flutter/bin:$PATH"
fi

schritt() { printf '\n== %s\n' "$*"; }

# Ein unbegrenzter Stack verursacht in manchen Linux-Cloud-VMs native Abstürze
# von flutter_tester. Nur den Soft-Limit dieses Prüfprozesses normalisieren.
if [ "$(uname -s)" = Linux ] && [ "$(ulimit -S -s)" = unlimited ]; then
  ulimit -S -s 8192
fi

# Reihenfolge wichtig: Erst alle Pakete auflösen, sonst meldet die Analyse
# im Wurzelordner fehlende Test-Pakete in packages/mordakte_core.
schritt "Pakete auflösen"
flutter pub get
(cd server && dart pub get)
# Alle vorhandenen Unterpakete: Flutter-Pakete mit flutter, reine Dart-Pakete mit dart.
for d in packages/*/; do
  [ -f "$d/pubspec.yaml" ] || continue
  if grep -q "sdk: flutter" "$d/pubspec.yaml"; then (cd "$d" && flutter pub get); else (cd "$d" && dart pub get); fi
done

schritt "Analyse"
flutter analyze
(cd server && dart analyze)

schritt "Paket-Tests (inkl. Kanon, Partymodus, Runden und Netz)"
for d in packages/*/; do
  [ -d "$d/test" ] || continue
  if grep -q 'sdk: flutter' "$d/pubspec.yaml"; then (cd "$d" && flutter test --concurrency=2); else (cd "$d" && dart test --concurrency=4); fi
done

schritt "Kanon-Tor (A-050): Schemas, Story-Bibel, Bildprompts, eingebetteter Kanon, Prüfsummen"
bash tool/kanon_tor.sh --pruefen

schritt "CI-Helfer"
python3 -m unittest discover -s tool/ci/tests

if [ "$STUFE" != "schnell" ]; then
  schritt "Szenario-Validator (Bestand)"
  (cd packages/mordakte_core && dart run bin/validate.dart)
  schritt "Partymodus: Plausibilität, Story-Bibel, Simulator"
  (cd packages/mordakte_core && dart run bin/party_pruefen.dart && dart run bin/party_bibel.dart --pruefen && dart run bin/party_simulate.dart --pruefen && dart run bin/party_prompts.dart --pruefen)
  schritt "Akten und Karten: Lösbarkeit, Texte, Privatheit je Akte"
  for akte in $(python3 -c 'import json; print(" ".join(a["id"] for a in json.load(open("content/party/akten.json"))["akten"]))'); do
    (cd packages/mordakte_core && dart run bin/akte_pruefen.dart --fall "$akte")
  done
  (cd packages/mordakte_core && dart run bin/karten_pruefen.dart)
  schritt "Server-Smoke (Bestand)"
  (cd server && dart run tool/smoke.dart)
  if [ "$STUFE" = "ci" ]; then
    # Die klassische Online-Matrix und der volle Party-Matrix-Durchlauf (4–20 Clients) sind für
    # jeden Push zu langsam; sie laufen in alles/e2e. Hier genügt eine Stufe mit 4 echten Clients.
    schritt "Party-Online-Matrix (CI): 4 echte Clients in einem Raum, private Rollenkarten"
    (cd server && dart run tool/party_matrix.dart --clients=4)
    (cd server && dart run tool/relay_matrix.dart --lokal --clients=4)
  else
    schritt "Online-Matrix: 4–20 echte Clients, klassische Räume"
    (cd server && dart run tool/online_matrix.dart)
    schritt "Party-Online-Matrix: 4–20 echte Clients in einem Raum, private Rollenkarten"
    (cd server && dart run tool/party_matrix.dart)
  fi
  schritt "Native Server-Datei kompilieren und über HTTP/WebSocket prüfen"
  mkdir -p .werkzeug
  (cd server && dart compile exe bin/server.dart -o ../.werkzeug/server-pruefung)
  node server/tool/native_smoke.mjs
  if [ -d test ]; then
    schritt "Flutter-Tests"
    # Zwei Testprozesse bleiben auch auf kleinen CI-/Cloud-VMs innerhalb des RAM-Budgets.
    flutter test --concurrency=2
  fi
  schritt "Web-Build ohne CDN"
  # Build-Cache leeren: Nach einem Build ohne „-o“ (build.sh) schreibt
  # Flutter sonst AssetManifest/FontManifest nicht neu (Nachtlauf E52).
  rm -rf .dart_tool/flutter_build
  # Dieses Artefakt wird Release-ZIP und GitHub Pages: Server und Relais kommen wie in
  # build.sh über tool/ci/dart_defines.sh (nur die gesetzten, öffentlichen Werte).
  web_args=(--release --no-web-resources-cdn -o build/web)
  while IFS= read -r zeile; do
    if [ -n "$zeile" ]; then web_args+=("$zeile"); fi
  done < <(bash tool/ci/dart_defines.sh)
  flutter build web "${web_args[@]}"
fi

if [ "$STUFE" = "ci" ]; then
  schritt "Browser-Proben (Konfiguration, App-Start, Runden, Solo bei 320 px)"
  (cd tool/e2e && node --test browser_test.mjs && node start.mjs && node runden.mjs && node solo.mjs --nur320)
fi

if [ "$STUFE" = "e2e" ]; then
  schritt "Automatisierte Durchläufe"
  (cd tool/e2e && node --test browser_test.mjs && node start.mjs && node runden.mjs && node solo.mjs && node abbrechen.mjs && npm test)
fi

schritt "Secret-Scan"
tool/secret_scan.sh
printf '\nAlle Prüfungen bestanden (%s).\n' "$STUFE"
