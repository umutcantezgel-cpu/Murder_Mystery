#!/usr/bin/env bash
# A-050: Prüfsummen des Schlosskellers neu baselinen, ohne die Beweis-Teilmenge anzufassen.
#   bash tool/kanon_neu.sh            schreibt tool/kanon_pruefsummen.txt neu
#   bash tool/kanon_neu.sh --pruefen  ändert nichts, Exit 1 bei Abweichung
# tool/kanon_fest.txt (Beweis-Teilmenge, krimidinner, scenarios) wird nie geschrieben.
# Weicht eine feste Datei ab, bricht das Skript in beiden Modi ab.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."
LISTE=tool/kanon_pruefsummen.txt
if ! sha256sum --quiet --strict -c tool/kanon_fest.txt; then
  echo "Feste Kanon-Datei verändert (tool/kanon_fest.txt). Diese Dateien sind die Beweisbasis und bleiben bytegleich." >&2
  exit 1
fi
neu="$(mktemp)"
trap 'rm -f "$neu"' EXIT
{
  grep -v '  content/party/schlosskeller/' "$LISTE"
  git ls-files -z -co --exclude-standard -- content/party/schlosskeller | xargs -0 sha256sum
} | LC_ALL=C sort -k2 >"$neu"
# Jede feste Zeile muss unverändert in der vollen Liste stehen.
while IFS= read -r zeile; do
  grep -qxF -- "$zeile" "$neu" || { echo "Feste Zeile fehlt in der neuen Liste: $zeile" >&2; exit 1; }
done < tool/kanon_fest.txt
if [ "${1:-}" = "--pruefen" ]; then
  if cmp -s "$neu" "$LISTE"; then echo "Kanon-Prüfsummen: aktuell"; exit 0; fi
  echo "Kanon-Prüfsummen veraltet. Neu erzeugen: bash tool/kanon_neu.sh" >&2
  diff "$LISTE" "$neu" | head -20 >&2 || true
  exit 1
fi
cp "$neu" "$LISTE"
echo "geschrieben: $LISTE ($(wc -l <"$LISTE") Zeilen)"
