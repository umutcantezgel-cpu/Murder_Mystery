#!/usr/bin/env bash
# Mit source laden: dieselbe gepinnte Werkzeugkette lokal, auf Netlify und in Actions.
# Keine globale Git-Konfiguration und keine Installation ins System.
set -euo pipefail
MORDAKTE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MORDAKTE_FLUTTER_VERSION=3.47.6
MORDAKTE_FLUTTER_DIR="$MORDAKTE_ROOT/.werkzeug/flutter"
if [ ! -x "$MORDAKTE_FLUTTER_DIR/bin/flutter" ]; then
  mkdir -p "$MORDAKTE_ROOT/.werkzeug"
  MORDAKTE_FLUTTER_ARCHIVE="$MORDAKTE_ROOT/.werkzeug/flutter-$MORDAKTE_FLUTTER_VERSION.tar.xz"
  curl --fail --silent --show-error --location --retry 3 \
    "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${MORDAKTE_FLUTTER_VERSION}-stable.tar.xz" \
    --output "$MORDAKTE_FLUTTER_ARCHIVE"
  tar --no-same-owner -xJf "$MORDAKTE_FLUTTER_ARCHIVE" -C "$MORDAKTE_ROOT/.werkzeug"
fi
export PATH="$MORDAKTE_FLUTTER_DIR/bin:$PATH"
flutter --version --machine | python3 -c '
import json, sys
actual = json.load(sys.stdin)["frameworkVersion"]
expected = sys.argv[1]
if actual != expected:
    sys.exit(f"Flutter {expected} erwartet, {actual} gefunden. SDK nicht automatisch überschrieben.")
' "$MORDAKTE_FLUTTER_VERSION"
