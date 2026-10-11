#!/usr/bin/env bash
# Baut die Release-APK (build/release/mordakte.apk + .sha256) und vermerkt die Signatur
# in build/release/signatur.txt (Zeile 1: release|test, Zeile 2 optional: Zertifikats-SHA-256).
set -euo pipefail
cd "$(dirname "$0")/../.."
source tool/flutter_env.sh
python3 tool/ci/check_server_url.py
signing="$(python3 tool/ci/prepare_android_signing.py)"
if [ "$signing" = test ]; then
  # Keine Secrets: stabiler, öffentlicher Test-Schlüssel (tool/ci/signing). Gradle liest
  # dieselben Umgebungsvariablen wie beim Release-Schlüssel.
  eval "$(python3 tool/ci/prepare_android_signing.py --test-env)"
fi
flutter pub get
args=(--release --build-number "${GITHUB_RUN_NUMBER:-1}")
while IFS= read -r zeile; do
  if [ -n "$zeile" ]; then args+=("$zeile"); fi
done < <(bash tool/ci/dart_defines.sh)
flutter build apk "${args[@]}"
mkdir -p build/release
cp build/app/outputs/flutter-apk/app-release.apk build/release/mordakte.apk
(cd build/release && sha256sum mordakte.apk >mordakte.apk.sha256)

# Zertifikat der fertigen APK ausgeben, falls apksigner verfügbar ist (PATH oder Android-SDK).
apksigner=""
if command -v apksigner >/dev/null 2>&1; then
  apksigner=apksigner
else
  sdk="${ANDROID_HOME:-${ANDROID_SDK_ROOT:-}}"
  if [ -n "$sdk" ]; then
    apksigner="$(ls -d "$sdk"/build-tools/*/apksigner 2>/dev/null | sort -V | tail -n 1 || true)"
  fi
fi
zertifikat=""
if [ -n "$apksigner" ]; then
  zertifikat="$("$apksigner" verify --print-certs build/release/mordakte.apk 2>/dev/null \
    | sed -n 's/^Signer #1 certificate SHA-256 digest: //p' | head -n 1 || true)"
fi
{
  printf '%s\n' "$signing"
  if [ -n "$zertifikat" ]; then printf '%s\n' "$zertifikat"; fi
} >build/release/signatur.txt
echo "Signatur: $signing"
if [ -n "$zertifikat" ]; then
  echo "Zertifikat SHA-256: $zertifikat"
fi
