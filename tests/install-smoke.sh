#!/data/data/com.termux/files/usr/bin/env bash
# Installer CI: fake HOME/XDG -> install -> rerun -> uninstall.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP="${TMPDIR:-/tmp}/greenit-install-smoke.$$"
trap 'rm -rf "$TMP"' EXIT
mkdir -p "$TMP/home" "$TMP/config" "$TMP/state"
export HOME="$TMP/home" XDG_CONFIG_HOME="$TMP/config" XDG_STATE_HOME="$TMP/state"
bash "$ROOT/install.sh" --only termux,vim --yes >/dev/null
test -f "$HOME/.termux/colors.properties"
test -f "$HOME/.vim/colors/greenit.vim"
test -f "$XDG_STATE_HOME/greenit/installed.tsv"
bash "$ROOT/install.sh" --only termux,vim --yes >/dev/null
bash "$ROOT/install.sh" --uninstall --yes >/dev/null
test ! -e "$HOME/.termux/colors.properties"
test ! -e "$HOME/.vim/colors/greenit.vim"
test ! -e "$XDG_STATE_HOME/greenit/installed.tsv"
echo "installer smoke OK"
