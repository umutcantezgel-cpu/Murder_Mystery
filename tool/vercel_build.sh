#!/usr/bin/env bash
# Vercel-Build: baut die Web-App von der Repo-Wurzel aus (build.sh) und legt sie
# im Ordner ab, in dem Vercel den Build startet (Root Directory des Projekts,
# z. B. tool/e2e), unter build/web.
set -euo pipefail
ziel="${1:-$PWD}"
wurzel="$(cd "$(dirname "$0")/.." && pwd)"
echo "Repo-Wurzel: $wurzel, Vercel-Ordner: $ziel"
bash "$wurzel/build.sh"
if [ "$wurzel" != "$ziel" ]; then
  rm -rf "$ziel/build"
  mkdir -p "$ziel/build"
  cp -r "$wurzel/build/web" "$ziel/build/web"
fi
