#!/usr/bin/env bash
# Secret-Scan vor jedem Push. Prüft Arbeitsstand und gesamten Git-Verlauf:
#  1. Nichts aus quellen/ (Rohchat) ist je committet worden.
#  2. Keine Chat-Kopfzeilen des Rohchats im Verlauf.
#  3. Keine Schlüssel- oder Token-Muster, keine .env-Dateien. Ausgenommen ist nur der absichtlich
#     veröffentlichte Android-Test-Schlüssel (tool/ci/signing/mordakte-test.p12, siehe dortiges README).
#     Öffentliche Supabase-Schlüssel (sb_publishable_…, anon-JWT) sind erlaubt und treffen kein Muster.
#  4. Keine längeren wörtlichen Passagen (≥ 120 Zeichen) aus dem Rohchat im Arbeitsstand.
#  5. Keine geheimen Supabase-Schlüssel: weder sb_secret_… noch ein JWT mit Rolle service_role.
set -uo pipefail
cd "$(dirname "$0")/.."
fehler=0
melde() { echo "SECRET-SCAN: $*"; fehler=1; }

# 1. quellen/ nie im Verlauf
if [ -n "$(git log --all --format=%H -- quellen/ 2>/dev/null)" ]; then
  melde "quellen/ taucht im Git-Verlauf auf"
fi
if git ls-files --error-unmatch quellen >/dev/null 2>&1; then
  melde "quellen/ ist im Index"
fi

# 2. Chat-Kopfzeilen (Datum, Uhrzeit, Name) im Verlauf oder im Index
muster_chat='\[[0-9]{2}\.[0-9]{2}\.[0-9]{2}, [0-9]{2}:[0-9]{2}:[0-9]{2}\] '
if git grep --untracked -nE "$muster_chat" -- . ':!tool/secret_scan.sh' >/dev/null 2>&1; then
  melde "Chat-Kopfzeile im Arbeitsstand: $(git grep --untracked -lE "$muster_chat" -- . ':!tool/secret_scan.sh' | head -3 | tr '\n' ' ')"
fi
if git log --all -p -G"$muster_chat" --format=%h -- . ':!tool/secret_scan.sh' 2>/dev/null | grep -qE '^[0-9a-f]{7,}$'; then
  melde "Chat-Kopfzeile im Git-Verlauf"
fi

# 3. Schlüssel- und Token-Muster, .env-Dateien
# Der öffentliche Android-Test-Schlüssel ist eine Binärdatei mit bewusst bekanntem Passwort.
test_schluessel=':!tool/ci/signing/mordakte-test.p12'
muster_key='(AKIA[0-9A-Z]{16}|gh[pousr]_[A-Za-z0-9]{30,}|sk-[A-Za-z0-9_-]{24,}|-----BEGIN [A-Z ]*PRIVATE KEY-----|xox[abpr]-[A-Za-z0-9-]{10,}|AIza[0-9A-Za-z_-]{35})'
if git grep --untracked -nE "$muster_key" -- . ':!tool/secret_scan.sh' "$test_schluessel" >/dev/null 2>&1; then
  melde "Schlüsselmuster im Arbeitsstand: $(git grep --untracked -lE "$muster_key" -- . ':!tool/secret_scan.sh' "$test_schluessel" | head -3 | tr '\n' ' ')"
fi
if git log --all -p -G"$muster_key" --format=%h -- . ':!tool/secret_scan.sh' "$test_schluessel" 2>/dev/null | grep -qE '^[0-9a-f]{7,}$'; then
  melde "Schlüsselmuster im Git-Verlauf"
fi
if git ls-files | grep -qE '(^|/)\.env(\..*)?$'; then
  melde ".env-Datei im Index"
fi

# 4. Keine längeren wörtlichen Passagen aus dem Rohchat in Dateien, die ins Repo gehen
if ! python3 tool/lib/chat_passagen.py >/tmp/chat_passagen.$$ 2>&1; then
  melde "wörtliche Chat-Passagen: $(head -3 /tmp/chat_passagen.$$ | tr '\n' ' ')"
fi
rm -f /tmp/chat_passagen.$$

# 5. Geheime Supabase-Schlüssel. Der publishable-Schlüssel (sb_publishable_…) und anon-JWTs sind
#    öffentlich und erlaubt. tool/ci/tests darf Abweisungs-Beispiele enthalten; die Prüfwerkzeuge
#    selbst nennen die Muster.
muster_sb_secret='sb_secret_[A-Za-z0-9_-]{10,}'
muster_jwt='eyJ[A-Za-z0-9_-]{8,}\.eyJ[A-Za-z0-9_-]{8,}\.[A-Za-z0-9_-]*'
supabase_ausnahmen=(':!tool/secret_scan.sh' ':!tool/lib/jwt_scan.py' ':!tool/ci/tests' "$test_schluessel")
if git grep --untracked -nE "$muster_sb_secret" -- . "${supabase_ausnahmen[@]}" >/dev/null 2>&1; then
  melde "sb_secret_-Schlüssel im Arbeitsstand: $(git grep --untracked -lE "$muster_sb_secret" -- . "${supabase_ausnahmen[@]}" | head -3 | tr '\n' ' ')"
fi
if git log --all -p -G"$muster_sb_secret" --format=%h -- . "${supabase_ausnahmen[@]}" 2>/dev/null | grep -E '^[0-9a-f]{7,}$' >/dev/null; then
  melde "sb_secret_-Schlüssel im Git-Verlauf"
fi
# JWTs werden dekodiert: nur die Rolle service_role ist verboten. Kein Token wird ausgegeben.
# „|| true“ in den Klammern, damit ein Nicht-Treffer von grep nicht als Fehler zählt (pipefail).
if ! jwt_befund="$({ git grep --untracked -hoE "$muster_jwt" -- . "${supabase_ausnahmen[@]}" 2>/dev/null || true; } | python3 tool/lib/jwt_scan.py)"; then
  melde "Arbeitsstand: $jwt_befund"
fi
if ! jwt_befund="$({ git log --all -p -G'eyJ' --format= -- . "${supabase_ausnahmen[@]}" 2>/dev/null | grep -oE "$muster_jwt" || true; } | python3 tool/lib/jwt_scan.py)"; then
  melde "Git-Verlauf: $jwt_befund"
fi

if [ "$fehler" -ne 0 ]; then
  echo "Secret-Scan: FEHLER"
  exit 1
fi
echo "Secret-Scan: sauber"
