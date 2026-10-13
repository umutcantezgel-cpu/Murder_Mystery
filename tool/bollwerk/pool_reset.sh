#!/usr/bin/env bash
# BOLLWERK · Pool-Platz anlegen oder zurücksetzen (A-2 A4.9). Plätze sind Kopien ohne Git.
# Aufruf: bash tool/bollwerk/pool_reset.sh <NN> <sha>      (NN = 01…06, Platz muss in FLUG.md stehen)
#         bash tool/bollwerk/pool_reset.sh basis <sha>      (schreibgeschützte Basis basis-<sha7>)
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/env.sh"
NN="${1:-}"; SHA="${2:-}"
[ -n "$NN" ] && [ -n "$SHA" ] || { echo "Aufruf: pool_reset.sh <NN|basis> <sha>"; exit 2; }
SHA="$(git -C "$BW" rev-parse --verify "$SHA^{commit}")"
if [ "$NN" = basis ]; then
  ZIEL="$POOL/basis-${SHA:0:7}"
else
  [[ "$NN" =~ ^0[1-6]$ ]] || { echo "Platz $NN ist nicht 01–06 – Abbruch"; exit 1; }
  grep -qE "Platz $NN( |$)" "$BW/planung/bollwerk/FLUG.md" || { echo "Platz $NN steht nicht in FLUG.md – Abbruch"; exit 1; }
  ZIEL="$POOL/$NN"
fi
if [ -d "$ZIEL" ]; then chmod -R u+w "$ZIEL"; fi
rm -rf "$ZIEL" && mkdir -p "$ZIEL" && git -C "$BW" archive "$SHA" | tar -x -C "$ZIEL"
for d in . packages/mordakte_core packages/krimidinner_kanon server tool/bollwerk/look_anker; do
  [ -f "$ZIEL/$d/pubspec.yaml" ] || continue
  if grep -q 'sdk: flutter' "$ZIEL/$d/pubspec.yaml"; then
    (cd "$ZIEL/$d" && flutter pub get --offline >/dev/null)
  else
    (cd "$ZIEL/$d" && dart pub get --offline >/dev/null)
  fi
done
[ "$NN" = basis ] && chmod -R a-w "$ZIEL"
echo "Pool $NN an ${SHA:0:7}: $ZIEL"
