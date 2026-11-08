#!/data/data/com.termux/files/usr/bin/env bash
# Verify Greenit colorscheme loads correctly in Vim.
# Exit 0 on pass, non-zero on fail.
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PASS=0
FAIL=0

# Prefer the caller's TMPDIR, then the Termux default, then any writable
# temp dir — the Makefile used to force the Termux path, which does not
# exist on Linux CI runners.
if [ -n "${TMPDIR:-}" ] && [ -d "$TMPDIR" ] && [ -w "$TMPDIR" ]; then
    :
elif [ -d /data/data/com.termux/files/usr/tmp ] && [ -w /data/data/com.termux/files/usr/tmp ]; then
    TMPDIR=/data/data/com.termux/files/usr/tmp
else
    TMPDIR=$(mktemp -d 2>/dev/null || echo ".")
fi
export TMPDIR
mkdir -p "$TMPDIR"

strip_ansi() {
  sed 's/\x1b\[[0-9;]*[a-zA-Z]//g' | tr -d '\r'
}

check() {
  local variant="$1"
  local expected_name="$2"
  local expected_fg="$3"
  local expected_bg="$4"

  echo "=== Testing $variant ==="
  # -es (silent ex mode) runs without a terminal; :redir captures the
  # command output that would otherwise go to the message area.
  local capture
  capture=$(mktemp "${TMPDIR:-.}/greenit-check.XXXXXX")
  vim -u NONE -N -es \
    -c "redir! > $capture" \
    -c "set t_Co=256 rtp+=$REPO" \
    -c "colorscheme $variant" -c "hi Normal" -c "echo g:colors_name" \
    -c "redir END" -c "qa!" </dev/null >/dev/null 2>&1
  output=$(strip_ansi <"$capture" 2>/dev/null || true)
  rm -f "$capture"

  if echo "$output" | grep -q "guifg=$expected_fg" && \
     echo "$output" | grep -q "guibg=$expected_bg" && \
     echo "$output" | grep -q "$expected_name"; then
    echo "  PASS: $variant loads (name=$expected_name, fg=$expected_fg, bg=$expected_bg)"
    PASS=$((PASS + 1))
  else
    echo "  FAIL: $variant did not load correctly"
    echo "  Cleaned output: $output"
    FAIL=$((FAIL + 1))
  fi
}

if ! command -v vim >/dev/null 2>&1; then
  echo "vim not installed — skipping colorscheme load test"
  exit 0
fi

check "greenit"   "greenit"   "#C9E4CE" "#0C1F17"
check "greenit-light" "greenit-light" "#24382C" "#F2F7EF"

echo ""
echo "Results: $PASS passed, $FAIL failed"
if [ "$FAIL" -gt 0 ]; then
  exit 1
fi
exit 0
