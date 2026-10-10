#!/usr/bin/env bash
# Web-Vorschau für Vercel/Netlify. Flutter-Version ist gepinnt, damit Builds reproduzierbar sind.
set -euo pipefail

cd "$(dirname "$0")"
source tool/flutter_env.sh
python3 tool/ci/check_server_url.py
flutter pub get
# MORDAKTE_SERVER ist eine öffentliche URL, kein Zugangsschlüssel.
# --no-web-resources-cdn: CanvasKit kommt aus dem eigenen Build.
args=(--release --no-web-resources-cdn)
if [ -n "${MORDAKTE_SERVER:-}" ]; then
  args+=("--dart-define=MORDAKTE_SERVER=$MORDAKTE_SERVER")
fi
flutter build web "${args[@]}"
