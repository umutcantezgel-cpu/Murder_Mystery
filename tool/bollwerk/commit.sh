#!/usr/bin/env bash
# BOLLWERK · Commit und Push (Muster tool/hd_commit.sh; A-2 A4.1, Master-Prompt 2.5 und 3).
# Aufruf:
#   bash tool/bollwerk/commit.sh "<Nachricht>" <pfad> [<pfad> …]          Branch bollwerk, Tor schnell, Push
#   bash tool/bollwerk/commit.sh --tor <modus> "<Nachricht>" <pfad> …      im Tor-Worktree auf bw-tor, ohne Push
#   bash tool/bollwerk/commit.sh --ohne-push "<Nachricht>" <pfad> …        wie oben, Push später
# Zustands-Commits (nur Zustands- und Berichtsdateien unter planung/bollwerk/) brauchen kein Tor, nur den Secret-Scan.
# Vor B-02 gilt die Schreib-Erlaubnis aus A-2 „Zusatz Erlaubnisprüfung“.
set -euo pipefail
HIER="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HIER/env.sh"
SITZUNG="${BOLLWERK_SITZUNG:-https://claude.ai/code/session_01J12w9BSCysBqiSdn143rRF}"

TOR=""; PUSH=1
while [ $# -gt 0 ]; do
  case "$1" in
    --tor) TOR="$2"; PUSH=0; shift 2 ;;
    --ohne-push) PUSH=0; shift ;;
    *) break ;;
  esac
done
if [ $# -lt 2 ]; then
  echo "Aufruf: bash tool/bollwerk/commit.sh [--tor <modus>|--ohne-push] \"<Nachricht>\" <pfad> [<pfad> …]"
  exit 2
fi
NACHRICHT="$1"; shift
PFADE=("$@")

if [ -n "$TOR" ]; then
  BAUM=/home/user/bw-arbeit/tor; SOLL=bw-tor
  case "$TOR" in schnell|phase|nacht|ziel) ;; *) echo "Unbekannter Tor-Modus: $TOR"; exit 2 ;; esac
else
  BAUM="$BW"; SOLL=bollwerk
fi
cd "$BAUM"

# 1 · Branch
AKTUELL="$(git rev-parse --abbrev-ref HEAD)"
if [ "$AKTUELL" != "$SOLL" ]; then
  echo "FALSCHER BRANCH: $AKTUELL (erwartet $SOLL) – kein Commit"; exit 1
fi

# 2 · Schreib-Erlaubnis und Schutzpfade
b02_erfuellt() {
  git show origin/bollwerk-leitstand:planung/bollwerk/leitstand/STEUERUNG.md 2>/dev/null \
    | grep -qE '(B-02 ERFÜLLT|FREIGABE BOLLWERK) · K=[0-9a-f]{40}'
}
ZUSTAND_RE='^planung/bollwerk/(LAUF|PRUEFPUNKT|QUITTUNGEN|FLUG|STATUS|NACHTPROTOKOLL|ENTSCHEIDUNGSLOG|FUER-DEN-NUTZER|REGISTER|MORGENBERICHT|KERNKARTE)\.md$|^planung/bollwerk/(bilder|tor-rest)/'
VOR_B02_RE='^(planung/bollwerk/|tool/bollwerk/|content/runden/|packages/mordakte_core/lib/src/runden/|packages/mordakte_core/test/runden/|lib/runden/|assets/runden/|test/runden/|docs/bollwerk/)|^packages/mordakte_core/test/web/kanon_eingebettet\.g\.dart$'
GESCHUETZT_RE='^planung/bollwerk/(MASTER-PROMPT\.md|STARTPAKET\.md|anhang/)'
NUR_ZUSTAND=1
for p in "${PFADE[@]}"; do
  if [ -d "$p" ]; then p="${p%/}/"; fi
  if [[ "$p" =~ $GESCHUETZT_RE ]]; then echo "GESCHÜTZT: $p – kein Commit"; exit 1; fi
  if [[ "$p" == planung/bollwerk/belege/* ]]; then
    echo "belege/ schreibt nur das Torwerkzeug: $p – kein Commit über commit.sh"; exit 1
  fi
  if ! b02_erfuellt && ! [[ "$p" =~ $VOR_B02_RE ]]; then
    echo "AUSSERHALB DER SCHREIB-ERLAUBNIS vor B-02: $p – kein Commit"; exit 1
  fi
  [[ "$p" =~ $ZUSTAND_RE ]] || NUR_ZUSTAND=0
done

# 3 · nur die genannten Pfade aufnehmen (vorher darf nichts vorgemerkt sein)
if ! git diff --cached --quiet; then
  echo "Es ist schon etwas vorgemerkt – kein Commit:"; git diff --cached --name-only; exit 1
fi
git add -- "${PFADE[@]}"
if git diff --cached --quiet; then echo "Nichts zu committen."; exit 0; fi

# 4 · Tor (entfällt bei reinen Zustands-Commits; im Tor-Worktree läuft das Tor getrennt nach dem Commit)
if [ "$NUR_ZUSTAND" = 0 ] && [ -z "$TOR" ]; then
  SAUBER="$(mktemp -d /home/user/bw-arbeit/commit-XXXXXX)"
  git worktree add --detach -q "$SAUBER/baum" HEAD
  aufraeumen() { git -C "$BAUM" worktree remove --force "$SAUBER/baum" >/dev/null 2>&1; rm -rf "$SAUBER"; }
  trap aufraeumen EXIT
  git diff --cached --binary | git -C "$SAUBER/baum" apply --index --whitespace=nowarn
  # Das Tor verlangt einen sauberen Baum: Probe-Commit nur im Wegwerf-Baum (losgelöst, nie gepusht).
  git -C "$SAUBER/baum" -c user.name=bollwerk-probe -c user.email=probe@bollwerk.invalid commit -q -m "Probe vor Commit"
  for d in .dart_tool packages/*/.dart_tool tool/ton/.dart_tool server/.dart_tool tool/bollwerk/.dart_tool; do
    if [ -d "$BAUM/$d" ]; then mkdir -p "$SAUBER/baum/$(dirname "$d")"; cp -a "$BAUM/$d" "$SAUBER/baum/$d"; fi
  done
  LOG="/home/user/bw-logs/commit-$(date -u +%Y%m%dT%H%M%S).log"
  MODUS=(schnell); b02_erfuellt || MODUS=(schnell --vorlauf)
  # Volles Tor erst ab dem Abnahme-Commit des Torwerkzeugs (TOR-SHA im PRUEFPUNKT, Master-Prompt §3).
  if grep -qE '^- TOR-SHA: [0-9a-f]{40}' "$BW/planung/bollwerk/PRUEFPUNKT.md" && [ -f "$SAUBER/baum/tool/bollwerk/bollwerk.dart" ]; then
    if ! (cd "$SAUBER/baum" && flock /tmp/bw-leicht-1.lock dart run tool/bollwerk/bollwerk.dart "${MODUS[@]}" --ohne-belege) > "$LOG" 2>&1; then
      echo "TOR ROT – kein Commit. Log: $LOG"; tail -15 "$LOG"; git reset -q -- "${PFADE[@]}"; exit 1
    fi
    tail -1 "$LOG" | grep -qE '^BOLLWERK GRÜN · schnell' || { echo "Endzeile fehlt – kein Commit. Log: $LOG"; git reset -q -- "${PFADE[@]}"; exit 1; }
    echo "Tor grün: $(tail -1 "$LOG")"
  else
    # Aufbauphase des Torwerkzeugs (Vorlauf vor TOR-SHA): Analyse der geänderten Dart-Pakete
    echo "Torwerkzeug noch nicht abgenommen – Aufbauprüfung (dart analyze, Rundentests)" | tee "$LOG"
    DART=$(git diff --cached --name-only -- '*.dart')
    if [ -n "$DART" ]; then
      (cd "$SAUBER/baum" && dart analyze --fatal-infos $DART) >> "$LOG" 2>&1 || { echo "ANALYSE ROT – kein Commit. Log: $LOG"; tail -15 "$LOG"; git reset -q -- "${PFADE[@]}"; exit 1; }
    fi
    if [ -d "$SAUBER/baum/packages/mordakte_core/test/runden" ] && git diff --cached --name-only | grep -qE '^(packages/mordakte_core/(lib/src|test)/runden/|tool/bollwerk/runden_simulate)'; then
      (cd "$SAUBER/baum/packages/mordakte_core" && flock /tmp/bw-leicht-1.lock dart test test/runden/) >> "$LOG" 2>&1 || { echo "RUNDENTESTS ROT – kein Commit. Log: $LOG"; tail -15 "$LOG"; git reset -q -- "${PFADE[@]}"; exit 1; }
    fi
  fi
  aufraeumen; trap - EXIT
fi

# 5 · Secret-Scan
SCAN="$(bash tool/secret_scan.sh | tail -1)"
if [ "$SCAN" != "Secret-Scan: sauber" ]; then
  echo "SECRET-SCAN NICHT SAUBER – kein Commit: $SCAN"; git reset -q -- "${PFADE[@]}"; exit 1
fi
if [ ! -f quellen/schlosskeller-teamchat.txt ]; then echo "Passagenprüfung übersprungen"; fi

# 6 · Commit
git commit -q -F - <<MSG
$NACHRICHT

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
Claude-Session: $SITZUNG
MSG
git log --oneline -1

# 7 · Push (nur bollwerk, nur aus $BW, LEASE vorher prüfen)
[ "$PUSH" = 1 ] || exit 0
GEN="$(sed -n 's/^LEASE gen=\([0-9]*\) session=\([^ ]*\).*/\1 \2/p' "$BW/planung/bollwerk/LAUF.md")"
git fetch -q origin bollwerk
FERN="$(git show origin/bollwerk:planung/bollwerk/LAUF.md | sed -n 's/^LEASE gen=\([0-9]*\) session=\([^ ]*\).*/\1 \2/p')"
if [ "$GEN" != "$FERN" ]; then
  echo "LEASE ABWEICHEND (lokal: $GEN · origin: $FERN) – kein Push"; exit 3
fi
cd "$BW"
test "$(git rev-parse --abbrev-ref HEAD)" = bollwerk && bash tool/secret_scan.sh | tail -1 | grep -q 'Secret-Scan: sauber' && git push -q origin HEAD:refs/heads/bollwerk
echo "gepusht: $(git rev-parse --short HEAD)"
