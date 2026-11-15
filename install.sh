#!/data/data/com.termux/files/usr/bin/env bash
# Greenit installer: detect supported apps, install dark/light artifacts, and
# track what it wrote so --uninstall only removes files it owns.
set -euo pipefail

THEME="greenit"
TITLE="Greenit"
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

VARIANT="dark"
ONLY=""
ALL=0
DRY=0
YES=0
LIST=0
UNINSTALL=0
FORCE=0
NOBACKUP=0
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/$THEME"
MANIFEST="$STATE_DIR/installed.tsv"

usage() {
    cat <<EOF
Usage: ./install.sh [options]

Install options:
  --dark              install dark artifacts (default)
  --light             install light artifacts
  --all               install every detected target without prompting
  --only LIST         comma-separated targets (see --list)
  --list              list targets and detection status
  --dry-run           print what would change
  --yes               skip confirmations
  --no-backup         do not create timestamped backups

Uninstall:
  --uninstall         remove files this installer recorded
  --force             remove recorded files even if edited since install

  -h, --help          show this help

Targets: termux kitty alacritty ghostty wezterm foot vim nvim emacs helix
         bat btop zellij fish lazygit

Examples:
  ./install.sh --all
  ./install.sh --light --only termux,kitty,vim
  ./install.sh --uninstall
EOF
}

die() { printf 'error: %s\n' "$*" >&2; exit 1; }
info() { printf '\033[38;2;123;216;143m[%s]\033[0m %s\n' "$THEME" "$*"; }
warn() { printf '\033[38;2;230;170;70m[%s]\033[0m %s\n' "$THEME" "$*" >&2; }

while [ "$#" -gt 0 ]; do
    case "$1" in
        --dark) VARIANT="dark" ;;
        --light) VARIANT="light" ;;
        --all) ALL=1 ;;
        --only) shift; [ "$#" -gt 0 ] || die "--only needs a target list"; ONLY="$1" ;;
        --only=*) ONLY="${1#*=}" ;;
        --list) LIST=1 ;;
        --dry-run) DRY=1 ;;
        --yes|-y) YES=1 ;;
        --uninstall) UNINSTALL=1 ;;
        --force) FORCE=1 ;;
        --no-backup) NOBACKUP=1 ;;
        -h|--help) usage; exit 0 ;;
        *) die "unknown option: $1 (try --help)" ;;
    esac
    shift
done

is_termux() { [ -n "${TERMUX_VERSION:-}" ] || [ "${PREFIX:-}" = "/data/data/com.termux/files/usr" ]; }
have() { command -v "$1" >/dev/null 2>&1; }
config_root() { if [ -n "${XDG_CONFIG_HOME:-}" ]; then printf '%s' "$XDG_CONFIG_HOME"; else printf '%s' "$HOME/.config"; fi; }

hash_file() {
    if have sha256sum; then sha256sum "$1" | cut -d' ' -f1
    elif have shasum; then shasum -a 256 "$1" | cut -d' ' -f1
    elif have cksum; then cksum "$1" | awk '{print $1 "-" $2}'
    else printf 'unknown'
    fi
}

manifest_upsert() { # <path>
    local path="$1" tmp
    mkdir -p "$STATE_DIR"
    tmp="$MANIFEST.$$"
    { [ -f "$MANIFEST" ] && awk -F'\t' -v p="$path" '$1 != p' "$MANIFEST" || true; } > "$tmp"
    printf '%s\t%s\n' "$path" "$(hash_file "$path")" >> "$tmp"
    mv -f "$tmp" "$MANIFEST"
}

normalize_target() {
    case "$1" in
        neovim) echo nvim ;;
        *) echo "$1" ;;
    esac
}

target_available() {
    local cfg; cfg="$(config_root)"
    case "$1" in
        termux)    is_termux || have termux-reload-settings ;;
        kitty)     [ -d "$cfg/kitty" ] || [ -f "$cfg/kitty/kitty.conf" ] || have kitty ;;
        alacritty) [ -d "$cfg/alacritty" ] || [ -f "$HOME/.alacritty.toml" ] || [ -f "$HOME/.alacritty.yml" ] || have alacritty ;;
        ghostty)   [ -d "$cfg/ghostty" ] || have ghostty ;;
        wezterm)   [ -d "$cfg/wezterm" ] || [ -f "$HOME/.wezterm.lua" ] || have wezterm ;;
        foot)      [ -d "$cfg/foot" ] || have foot ;;
        vim)       [ -d "$HOME/.vim" ] || [ -f "$HOME/.vimrc" ] || have vim ;;
        nvim)      [ -d "$cfg/nvim" ] || have nvim ;;
        emacs)     [ -d "$HOME/.emacs.d" ] || [ -d "$cfg/emacs" ] || have emacs ;;
        helix)     [ -d "$cfg/helix" ] || have hx ;;
        bat)       have bat ;;
        btop)      [ -d "$cfg/btop" ] || have btop ;;
        zellij)    [ -d "$cfg/zellij" ] || have zellij ;;
        fish)      [ -d "$cfg/fish" ] || have fish ;;
        lazygit)   [ -d "$cfg/lazygit" ] || have lazygit ;;
        *) return 1 ;;
    esac
}

target_label() {
    case "$1" in
        termux) echo "Termux (~/.termux/colors.properties)" ;;
        kitty) echo "kitty (theme include)" ;;
        alacritty) echo "Alacritty (theme import)" ;;
        ghostty) echo "Ghostty (theme include)" ;;
        wezterm) echo "WezTerm (theme module)" ;;
        foot) echo "foot (theme include)" ;;
        vim) echo "Vim (both variants)" ;;
        nvim) echo "Neovim (both variants)" ;;
        emacs) echo "Emacs (both variants)" ;;
        helix) echo "Helix (both variants)" ;;
        bat) echo "bat (both variants)" ;;
        btop) echo "btop (both variants)" ;;
        zellij) echo "Zellij (both variants)" ;;
        fish) echo "fish (both variants)" ;;
        lazygit) echo "lazygit (both variants)" ;;
        *) echo "$1" ;;
    esac
}

ALL_TARGETS="termux kitty alacritty ghostty wezterm foot vim nvim emacs helix bat btop zellij fish lazygit"

if [ "$LIST" = "1" ]; then
    printf '%-12s %-8s %s\n' "TARGET" "STATUS" "DETAIL"
    for t in $ALL_TARGETS; do
        if target_available "$t"; then status="ready"; else status="missing"; fi
        printf '%-12s %-8s %s\n' "$t" "$status" "$(target_label "$t")"
    done
    exit 0
fi

if [ "$UNINSTALL" = "1" ]; then
    [ -f "$MANIFEST" ] || { info "no files recorded by this installer"; exit 0; }
    if [ "$YES" = "0" ] && [ "$DRY" = "0" ]; then
        if [ -t 0 ]; then
            printf 'Remove files recorded in %s? [y/N] ' "$MANIFEST"
            read -r reply
            case "$reply" in [Yy]*) ;; *) echo "Canceled."; exit 0 ;; esac
        else
            die "use --yes with --uninstall in a non-interactive shell"
        fi
    fi
    removed=0; kept=0; termux_removed=0; tmp="$MANIFEST.$$"
    { [ -f "$MANIFEST" ] && cat "$MANIFEST" || true; } > "$tmp.old"
    while IFS=$'\t' read -r path old_hash; do
        [ -n "$path" ] || continue
        if [ ! -e "$path" ]; then continue; fi
        if [ "$FORCE" = "0" ] && [ "$(hash_file "$path")" != "$old_hash" ]; then
            warn "keeping modified file: $path (use --force to remove)"
            printf '%s\t%s\n' "$path" "$old_hash" >> "$tmp"
            kept=$((kept + 1)); continue
        fi
        if [ "$DRY" = "1" ]; then
            printf '  would remove: %s\n' "$path"
        else
            rm -f "$path"
            printf '  removed: %s\n' "$path"
            case "$path" in "$HOME/.termux/colors.properties") termux_removed=1 ;; esac
        fi
        removed=$((removed + 1))
    done < "$tmp.old"
    if [ "$DRY" = "0" ]; then
        if [ "$kept" -eq 0 ]; then rm -f "$MANIFEST"; rmdir "$STATE_DIR" 2>/dev/null || true
        else mv -f "$tmp" "$MANIFEST"; fi
    fi
    rm -f "$tmp" "$tmp.old"
    info "uninstall complete: $removed removed, $kept kept"
    if [ "$DRY" = "0" ] && [ "$termux_removed" = "1" ] && have termux-reload-settings; then
        termux-reload-settings || warn "run termux-reload-settings manually"
    fi
    exit 0
fi

if [ -n "$ONLY" ]; then
    SELECTED=""
    for t in $(printf '%s' "$ONLY" | tr ',' ' '); do
        t="$(normalize_target "$t")"
        case " $ALL_TARGETS " in *" $t "*) ;; *) die "unknown target: $t" ;; esac
        SELECTED="$SELECTED $t"
    done
elif [ "$ALL" = "1" ]; then
    SELECTED=""
    for t in $ALL_TARGETS; do target_available "$t" && SELECTED="$SELECTED $t"; done
elif [ -t 0 ] && [ -t 1 ]; then
    DETECTED=""
    for t in $ALL_TARGETS; do target_available "$t" && DETECTED="$DETECTED $t"; done
    DETECTED="${DETECTED# }"
    [ -n "$DETECTED" ] || die "no supported apps detected; use --only to force one"
    if have fzf; then
        SELECTED="$(printf '%s\n' "$DETECTED" | tr ' ' '\n' | fzf --multi --layout=reverse --prompt="$TITLE targets> " --height=50% --border)"
    else
        info "Detected targets:"
        n=0; set -- $DETECTED
        for t in "$@"; do n=$((n + 1)); printf '  %2d) %-10s %s\n' "$n" "$t" "$(target_label "$t")"; done
        printf 'Select numbers/ranges (e.g. 1 3-5), or Enter for all: '
        read -r answer; answer="${answer:-all}"
        if [ "$answer" = "all" ]; then SELECTED="$DETECTED"; else
            SELECTED=""
            for part in $answer; do
                case "$part" in
                    *-*) lo="${part%-*}"; hi="${part#*-}"
                         [ "$lo" -ge 1 ] 2>/dev/null && [ "$hi" -le "$n" ] 2>/dev/null || die "bad range: $part"
                         i=$lo; while [ "$i" -le "$hi" ]; do eval "t=\${$i}"; SELECTED="$SELECTED $t"; i=$((i + 1)); done ;;
                    *)   [ "$part" -ge 1 ] 2>/dev/null && [ "$part" -le "$n" ] 2>/dev/null || die "bad selection: $part"
                         eval "t=\${$part}"; SELECTED="$SELECTED $t" ;;
                esac
            done
        fi
    fi
else
    die "no target selected; use --all or --only LIST (see --help)"
fi
SELECTED="$(printf '%s' "$SELECTED" | tr ' ' '\n' | awk 'NF' | awk '!seen[$0]++' | tr '\n' ' ')"
SELECTED="${SELECTED% }"
[ -n "$SELECTED" ] || die "nothing selected"

FAILED=0
install_file() { # <source> <destination>
    local src="$1" dst="$2" bak
    if [ ! -f "$src" ]; then warn "missing source: $src"; FAILED=1; return 1; fi
    if [ "$DRY" = "1" ]; then
        printf '  would install %s -> %s\n' "${src#"$REPO_DIR"/}" "$dst"
        return 0
    fi
    mkdir -p "$(dirname "$dst")"
    if [ -f "$dst" ] && cmp -s "$src" "$dst"; then
        printf '  unchanged: %s\n' "$dst"
        manifest_upsert "$dst"
        return 0
    fi
    if [ -e "$dst" ] && [ "$NOBACKUP" = "0" ]; then
        bak="$dst.bak-$(date +%Y%m%d-%H%M%S)-$$"
        cp -p "$dst" "$bak"
        printf '  backup: %s\n' "$bak"
    fi
    cp -p "$src" "$dst"
    manifest_upsert "$dst"
    printf '  installed: %s\n' "$dst"
}

cfg="$(config_root)"
SFX=""
[ "$VARIANT" = "light" ] && SFX="-light"

both() { # <dir> <basename> <extension> <dest-dir>
    install_file "$REPO_DIR/$1/$THEME-dark.$3" "$4/$2-dark.$3"
    install_file "$REPO_DIR/$1/$THEME-light.$3" "$4/$2-light.$3"
}

if [ "$YES" = "0" ] && [ "$DRY" = "0" ] && [ -t 0 ]; then
    printf 'Install %s (%s) for: %s\n' "$TITLE" "$VARIANT" "$SELECTED"
    printf 'Continue? [Y/n] '
    read -r reply
    case "${reply:-y}" in [Yy]*) ;; *) echo "Canceled."; exit 0 ;; esac
fi

info "Installing $TITLE ($VARIANT) from $REPO_DIR"
for t in $SELECTED; do
    printf '\n%s\n' "$(target_label "$t")"
    case "$t" in
        termux)
            install_file "$REPO_DIR/termux/$THEME-$VARIANT.properties" "$HOME/.termux/colors.properties"
            if [ "$DRY" = "0" ] && have termux-reload-settings; then termux-reload-settings || warn "run termux-reload-settings manually"; fi
            ;;
        kitty)
            src="$REPO_DIR/extras/kitty.conf"; [ "$VARIANT" = "light" ] && src="$REPO_DIR/extras/kitty-light.conf"
            install_file "$src" "$cfg/kitty/$THEME$SFX.conf"
            printf '  add to kitty.conf: include %s\n' "$THEME$SFX.conf"
            ;;
        alacritty)
            src="$REPO_DIR/extras/alacritty.toml"; [ "$VARIANT" = "light" ] && src="$REPO_DIR/extras/alacritty-light.toml"
            install_file "$src" "$cfg/alacritty/themes/$THEME$SFX.toml"
            printf '  add to alacritty.toml: import = ["~/.config/alacritty/themes/%s.toml"]\n' "$THEME$SFX"
            ;;
        ghostty)
            src="$REPO_DIR/extras/ghostty"; [ "$VARIANT" = "light" ] && src="$REPO_DIR/extras/ghostty-light"
            install_file "$src" "$cfg/ghostty/$THEME$SFX"
            printf '  add to ghostty config: include = %s\n' "$THEME$SFX"
            ;;
        wezterm)
            install_file "$REPO_DIR/extras/wezterm.lua" "$cfg/wezterm/$THEME.lua"
            printf '  add to ~/.wezterm.lua: require("%s")\n' "$THEME"
            ;;
        foot)
            install_file "$REPO_DIR/foot/$THEME-$VARIANT.ini" "$cfg/foot/$THEME-$VARIANT.ini"
            printf '  add to foot.ini: include=~/.config/foot/%s-%s.ini\n' "$THEME" "$VARIANT"
            ;;
        vim)
            install_file "$REPO_DIR/colors/$THEME.vim" "$HOME/.vim/colors/$THEME.vim"
            install_file "$REPO_DIR/colors/$THEME-light.vim" "$HOME/.vim/colors/$THEME-light.vim"
            printf '  use: colorscheme %s%s\n' "$THEME" "$([ "$VARIANT" = light ] && echo -light)"
            ;;
        nvim)
            install_file "$REPO_DIR/colors/$THEME.vim" "$cfg/nvim/colors/$THEME.vim"
            install_file "$REPO_DIR/colors/$THEME-light.vim" "$cfg/nvim/colors/$THEME-light.vim"
            printf '  use: colorscheme %s%s\n' "$THEME" "$([ "$VARIANT" = light ] && echo -light)"
            ;;
        emacs)
            emacs_dir="$HOME/.emacs.d"; [ -d "$cfg/emacs" ] && emacs_dir="$cfg/emacs"
            install_file "$REPO_DIR/emacs/$THEME-dark-theme.el" "$emacs_dir/themes/$THEME-dark-theme.el"
            install_file "$REPO_DIR/emacs/$THEME-light-theme.el" "$emacs_dir/themes/$THEME-light-theme.el"
            printf '  use: (load-theme '\''%s-%s t)\n' "$THEME" "$VARIANT"
            ;;
        helix)
            both helix "$THEME" toml "$cfg/helix/themes"
            printf '  use: theme = "%s-%s"\n' "$THEME" "$VARIANT"
            ;;
        bat)
            bat_dir="$(bat --config-dir 2>/dev/null || printf '%s/bat' "$cfg")"
            both bat "$THEME" tmTheme "$bat_dir/themes"
            if [ "$DRY" = "0" ] && have bat; then bat cache --build >/dev/null 2>&1 || warn "run 'bat cache --build' manually"; fi
            printf '  use: bat --theme %s-%s\n' "$TITLE" "$VARIANT"
            ;;
        btop)
            both btop "$THEME" theme "$cfg/btop/themes"
            printf '  use: color_theme = "%s-%s" in btop.conf\n' "$THEME" "$VARIANT"
            ;;
        zellij)
            both zellij "$THEME" kdl "$cfg/zellij/themes"
            printf '  use: theme "%s-%s" in config.kdl\n' "$THEME" "$VARIANT"
            ;;
        fish)
            both fish "$THEME" theme "$cfg/fish/themes"
            printf '  use: fish_config theme choose "%s %s"\n' "$TITLE" "$VARIANT"
            ;;
        lazygit)
            both lazygit "$THEME" yml "$cfg/lazygit"
            printf '  add both theme files to your lazygit config includes\n'
            ;;
    esac
done

[ "$FAILED" = "0" ] || die "some sources were missing; check the output above"
printf '\n%s complete. Reload your terminal/apps to see the change.\n' "$TITLE"
