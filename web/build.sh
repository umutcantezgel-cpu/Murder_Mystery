#!/usr/bin/env bash
# Vercel-Weiche: Nutzt das Vercel-Projekt „web“ als Root Directory, läuft der
# Build-Befehl `bash build.sh` hier statt im Repo-Wurzelordner. Dieses Skript
# baut dann vom Wurzelordner aus und legt das Ergebnis unter web/build/web ab,
# wo Vercel es mit „Output Directory: build/web“ findet.
set -euo pipefail
hier="$(cd "$(dirname "$0")" && pwd)"
bash "$hier/../build.sh"
rm -rf "$hier/build"
mkdir -p "$hier/build"
cp -r "$hier/../build/web" "$hier/build/web"
