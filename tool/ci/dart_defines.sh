#!/usr/bin/env bash
# Gibt die öffentlichen Build-Konfigurationswerte als --dart-define-Argumente aus,
# eines je Zeile, und nur dann, wenn die Umgebungsvariable nicht leer ist.
# Alle drei Werte sind öffentlich (Server-Adresse, Relay-Adresse, publishable/anon-Schlüssel),
# keine Geheimnisse. Prüfung der Formate: tool/ci/check_server_url.py.
#
# Verwendung (auch mit der Bash 3.2 von macOS, daher ohne mapfile):
#   defines=()
#   while IFS= read -r zeile; do
#     if [ -n "$zeile" ]; then defines+=("$zeile"); fi
#   done < <(bash tool/ci/dart_defines.sh)
#   flutter build ... "${defines[@]}"
set -euo pipefail
for name in MORDAKTE_SERVER MORDAKTE_RELAY_URL MORDAKTE_RELAY_KEY; do
  value="$(printenv "$name" || true)"
  if [ -n "$value" ]; then
    printf -- '--dart-define=%s=%s\n' "$name" "$value"
  fi
done
