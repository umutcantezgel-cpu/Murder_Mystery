#!/usr/bin/env bash
# Kanon-Tor (A-050): alle abgeleiteten Kanon-Dateien in fester Reihenfolge neu erzeugen.
#   bash tool/kanon_tor.sh            erzeugen
#   bash tool/kanon_tor.sh --pruefen  nur prüfen (Exit 1 bei Abweichung)
# Reihenfolge: Schemas → Story-Bibel → Bildprompts → eingebetteter Kanon → Prüfsummen → Inhaltskennungen.
# Der Determinismus-Golden (determinismus_soll*.g.dart) wird hier nie erzeugt.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."
if [ "${1:-}" = "--pruefen" ]; then
  python3 tool/schema_akte.py --pruefen
  (cd packages/mordakte_core && dart run bin/party_bibel.dart --pruefen && dart run bin/party_prompts.dart --pruefen)
  dart run tool/bollwerk/kanon_einbetten.dart --pruefe
  bash tool/kanon_neu.sh --pruefen
  python3 tool/inhalt_kennung.py --pruefen
  exit 0
fi
python3 tool/schema_akte.py
(cd packages/mordakte_core && dart run bin/party_bibel.dart && dart run bin/party_prompts.dart)
dart run tool/bollwerk/kanon_einbetten.dart
bash tool/kanon_neu.sh
python3 tool/inhalt_kennung.py
