#!/usr/bin/env bash
# Gesamtprüfung des Repos. Aufruf: tool/pruefen.sh [schnell|alles|e2e]
#   schnell: Pakete auflösen, Analyse, Kern-Tests (Kanon, Logik, Partymodus)
#   alles:   dazu Szenario-Validator, Server-Smoke, Flutter-Tests, Web-Build ohne CDN
#   e2e:     dazu automatisierte Durchläufe (tool/e2e) gegen den Web-Build
# Zum Schluss läuft immer der Secret-Scan.
set -euo pipefail
cd "$(dirname "$0")/.."
STUFE="${1:-alles}"
case "$STUFE" in
  schnell|alles|e2e) ;;
  *) echo 'Aufruf: tool/pruefen.sh [schnell|alles|e2e]' >&2; exit 2 ;;
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

schritt "Paket-Tests (inkl. Kanon, Partymodus, Runden, FEINKORN und WLAN)"
for d in packages/*/; do
  [ -d "$d/test" ] || continue
  if grep -q 'sdk: flutter' "$d/pubspec.yaml"; then (cd "$d" && flutter test --concurrency=2); else (cd "$d" && dart test --concurrency=4); fi
done

schritt "CI-Helfer"
python3 -m unittest discover -s tool/ci/tests

if [ "$STUFE" != "schnell" ]; then
  schritt "Szenario-Validator (Bestand)"
  (cd packages/mordakte_core && dart run bin/validate.dart)
  schritt "Partymodus: Plausibilität, Story-Bibel, Simulator"
  (cd packages/mordakte_core && dart run bin/party_pruefen.dart && dart run bin/party_bibel.dart --pruefen && dart run bin/party_simulate.dart --pruefen && dart run bin/party_prompts.dart --pruefen)
  schritt "Server-Smoke (Bestand)"
  (cd server && dart run tool/smoke.dart)
  schritt "Online-Matrix: 4–20 echte Clients, klassische Räume"
  (cd server && dart run tool/online_matrix.dart)
  schritt "Party-Online-Matrix: 4–20 echte Clients in einem Raum, private Rollenkarten"
  (cd server && dart run tool/party_matrix.dart)
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
  flutter build web --release --no-web-resources-cdn -o build/web
fi

if [ "$STUFE" = "e2e" ]; then
  schritt "Automatisierte Durchläufe"
  (cd tool/e2e && node --test browser_test.mjs && node start.mjs && npm test)
fi

schritt "Secret-Scan"
tool/secret_scan.sh
printf '\nAlle Prüfungen bestanden (%s).\n' "$STUFE"
