#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../.."
source tool/flutter_env.sh
python3 tool/ci/check_server_url.py
signing="$(python3 tool/ci/prepare_android_signing.py)"
flutter pub get
args=(--release --build-number "${GITHUB_RUN_NUMBER:-1}")
if [ -n "${MORDAKTE_SERVER:-}" ]; then
  args+=("--dart-define=MORDAKTE_SERVER=$MORDAKTE_SERVER")
fi
flutter build apk "${args[@]}"
mkdir -p build/release
cp build/app/outputs/flutter-apk/app-release.apk build/release/mordakte.apk
(cd build/release && sha256sum mordakte.apk >mordakte.apk.sha256)
if [ "$signing" = release ]; then
  signature='Release-Keystore aus GitHub-Secrets'
else
  signature='Debug-Signatur zum Testen (Release-Build). Bei einem Signaturwechsel die alte APK zuerst deinstallieren.'
fi
printf '# Mordakte für Android\n\nCode-Stand: `%s`\n\nSignatur: %s\n\nAPK herunterladen, auf dem Handy öffnen und die Installation aus dieser Quelle erlauben. Die Prüfsumme steht in mordakte.apk.sha256.\n\nDer Schlosskeller funktioniert offline. Online benötigt einen eingerichteten öffentlichen Server. Aktueller Funktions- und Prüfstand: planung/abschluss/STATUS.md im Repository.\n' \
  "${GITHUB_SHA:-$(git rev-parse HEAD)}" "$signature" >build/release/NOTES.md
