#!/usr/bin/env bash
# Web-Vorschau für Vercel/Netlify. Flutter-Version ist gepinnt, damit Builds reproduzierbar sind.
set -euo pipefail

cd "$(dirname "$0")"
source tool/flutter_env.sh
python3 tool/ci/check_server_url.py
flutter pub get
# MORDAKTE_SERVER, MORDAKTE_RELAY_URL und MORDAKTE_RELAY_KEY sind öffentliche Werte
# (kein Zugangsschlüssel); tool/ci/dart_defines.sh reicht nur die gesetzten durch.
# --no-web-resources-cdn: CanvasKit kommt aus dem eigenen Build.
args=(--release --no-web-resources-cdn)
while IFS= read -r zeile; do
  if [ -n "$zeile" ]; then args+=("$zeile"); fi
done < <(bash tool/ci/dart_defines.sh)
flutter build web "${args[@]}"
