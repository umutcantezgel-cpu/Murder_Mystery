#!/usr/bin/env bash
# Mit source laden: dieselbe gepinnte Werkzeugkette lokal, auf Netlify und in Actions
# (Linux und macOS). Keine globale Git-Konfiguration und keine Installation ins System.
set -euo pipefail
MORDAKTE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MORDAKTE_FLUTTER_VERSION=3.47.6
MORDAKTE_FLUTTER_DIR="$MORDAKTE_ROOT/.werkzeug/flutter"
if [ ! -x "$MORDAKTE_FLUTTER_DIR/bin/flutter" ]; then
  mkdir -p "$MORDAKTE_ROOT/.werkzeug"
  MORDAKTE_FLUTTER_BASIS="https://storage.googleapis.com/flutter_infra_release/releases/stable"
  case "$(uname -s)" in
    Linux)
      MORDAKTE_FLUTTER_ARCHIVE="$MORDAKTE_ROOT/.werkzeug/flutter-$MORDAKTE_FLUTTER_VERSION.tar.xz"
      curl --fail --silent --show-error --location --retry 3 \
        "$MORDAKTE_FLUTTER_BASIS/linux/flutter_linux_${MORDAKTE_FLUTTER_VERSION}-stable.tar.xz" \
        --output "$MORDAKTE_FLUTTER_ARCHIVE"
      tar --no-same-owner -xJf "$MORDAKTE_FLUTTER_ARCHIVE" -C "$MORDAKTE_ROOT/.werkzeug"
      ;;
    Darwin)
      case "$(uname -m)" in
        arm64|aarch64) MORDAKTE_FLUTTER_DATEI="flutter_macos_arm64_${MORDAKTE_FLUTTER_VERSION}-stable.zip" ;;
        *) MORDAKTE_FLUTTER_DATEI="flutter_macos_${MORDAKTE_FLUTTER_VERSION}-stable.zip" ;;
      esac
      MORDAKTE_FLUTTER_ARCHIVE="$MORDAKTE_ROOT/.werkzeug/flutter-$MORDAKTE_FLUTTER_VERSION.zip"
      curl --fail --silent --show-error --location --retry 3 \
        "$MORDAKTE_FLUTTER_BASIS/macos/$MORDAKTE_FLUTTER_DATEI" \
        --output "$MORDAKTE_FLUTTER_ARCHIVE"
      unzip -q -o "$MORDAKTE_FLUTTER_ARCHIVE" -d "$MORDAKTE_ROOT/.werkzeug"
      ;;
    *)
      echo "Flutter-Bereitstellung nur für Linux und macOS vorgesehen, nicht für $(uname -s)." >&2
      return 1 2>/dev/null || exit 1
      ;;
  esac
  rm -f "$MORDAKTE_FLUTTER_ARCHIVE"
fi
export PATH="$MORDAKTE_FLUTTER_DIR/bin:$PATH"
# Manche Flutter-Aufrufe schreiben vor das JSON eine Zeile (z. B. die Warnung beim Start als root,
# Download-Meldungen beim ersten Lauf). Deshalb ab der ersten „{“ ein vollständiges JSON-Objekt lesen,
# das die Framework-Version enthält; Text davor und danach wird ignoriert.
flutter --version --machine 2>/dev/null | python3 -c '
import json, sys
text = sys.stdin.read()
expected = sys.argv[1]
decoder = json.JSONDecoder()
actual = None
start = text.find("{")
while start >= 0 and actual is None:
    try:
        daten, _ = decoder.raw_decode(text, start)
        if isinstance(daten, dict) and "frameworkVersion" in daten:
            actual = daten["frameworkVersion"]
    except ValueError:
        pass
    start = text.find("{", start + 1)
if actual is None:
    sys.exit("Flutter-Version nicht lesbar: flutter --version --machine lieferte kein gültiges JSON.")
if actual != expected:
    sys.exit(f"Flutter {expected} erwartet, {actual} gefunden. SDK nicht automatisch überschrieben.")
' "$MORDAKTE_FLUTTER_VERSION"
