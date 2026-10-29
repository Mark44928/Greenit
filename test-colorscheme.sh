#!/usr/bin/env bash
# Verify Greenit colorscheme loads correctly in Vim.
# Exit 0 on pass, non-zero on fail.
set -euo pipefail

REPO="$HOME/repos/Greenit"
PASS=0
FAIL=0

strip_ansi() {
  sed 's/\x1b\[[0-9;]*[a-zA-Z]//g' | tr -d '\r'
}

check() {
  local variant="$1"
  local expected_name="$2"
  local expected_fg="$3"
  local expected_bg="$4"

  echo "=== Testing $variant ==="
  output=$(vim -u NONE -N -c "set t_Co=256 rtp+=$REPO" \
    -c "colorscheme $variant" -c "hi Normal" -c "echo g:colors_name" -c "qa!" 2>&1 | strip_ansi)

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

check "greenit"   "greenit"   "#C9E4CE" "#0C1F17"
check "greenit-light" "greenit-light" "#24382C" "#F2F7EF"

echo ""
echo "Results: $PASS passed, $FAIL failed"
if [ "$FAIL" -gt 0 ]; then
  exit 1
fi
exit 0
