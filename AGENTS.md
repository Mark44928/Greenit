# AGENTS.md — Greenit

## What this repo is

A **generated theme family**: every color artifact is rendered from a single `palette.json` by `gen.py` (stdlib only, no dependencies). Two variants — dark (`greenit`) and light (`greenit-light`).

**Only these are editable sources of truth:**

| Path | Role |
|---|---|
| `palette.json` | All colors, both variants (also carries `version`) |
| `gen.py` | Renderer + `BUILDS` list (56 artifacts, 32 templates) |
| `templates/*.tmpl` | One template per app format |
| `tests/contrast.py` | Regenerates the WCAG table inside `palette.md` |
| `test-colorscheme.sh` | Vim colorscheme load test |
| `Makefile` | Dev targets |
| `README.md`, `palette.md`, `assets/` | Hand-maintained docs (partially generated — see below) |

Everything else — `colors/`, `termux/`, `extras/`, `bat/`, `btop/`, `delta/`, `dircolors/`, `emacs/`, `exa/`, `fastfetch/`, `fish/`, `foot/`, `fzf/`, `git/`, `helix/`, `lazygit/`, `less/`, `lsd/`, `nano/`, `powerlevel10k/`, `ripgrep/`, `starship/`, `tmux/`, `vivid/`, `yazi/`, `zellij/` — is **generated**. Hand-editing is overwritten by `make gen` and breaks the drift gate.

## Commands

```bash
make gen        # python3 ./gen.py — render all 56 artifacts
make contrast   # python3 tests/contrast.py — rewrite the WCAG table in palette.md (idempotent)
make test       # bash ./test-colorscheme.sh — load both colorschemes in Vim (skips if no vim)
make check      # gen + contrast + git diff --exit-code + test   ← the gate; CI runs exactly these 4 steps
```

**Order matters.** `check` runs `gen` then `contrast` then the drift check. Never run `git diff` after `gen` but before `contrast` — the regenerated `palette.md` table will show up as false drift.

Invoke scripts through the interpreter or Makefile — `gen.py`, `test-colorscheme.sh` carry the Termux shebang `#!/data/data/com.termux/files/usr/bin/env bash|python3`, so `./gen.py` is not portable (that is why the Makefile writes `python3 ./gen.py`).

## The drift contract

`gen.py` must leave `git diff` empty — output is byte-identical to the committed files. That is the whole verification model: there are no unit tests for the artifacts.

- `git diff --exit-code` does **not** see untracked files. A new `BUILDS` entry whose artifact was never `git add`ed passes `make check` silently — also check `git status --porcelain`.
- Generated files end with a trailing newline; stray whitespace is drift.

## Change workflows

**Change a color** → edit `palette.json` → `make gen` → `make contrast` → review `git diff` → `make test` → **then hand-update `README.md` + `palette.md`** (palette table, ANSI 16-color table are not generated).

**Add an app integration** → write `templates/<app>.tmpl` → add one `BUILDS` row per variant in `gen.py` → `make gen` → add install instructions under README "Quick Install".

## `BUILDS` convention (`gen.py:180`)

Rows are `(template, output path, variant | None)`. Use `None` only when one file renders **both** variants (currently just `wezterm.lua`, `greenit.vim`); everything else is one file per variant, `dark` + `light`.

## Template language (gen.py, no Jinja)

- Interpolation: `${variant}`, `${P.<section>.<key>}`, arrays `${P.ansi[0]}`, dotted paths `${P.editor.surface}`.
- Transform functions: `${rgb:P.fg}` (r,g,b) · `${rgb3:P.fg}` (#rgb) · `${ansi256:P.fg}` (nearest 256-color index) · `${rgb_r|rgb_g|rgb_b:P.fg}` (3-decimal 0–1) · `${nohash:P.fg}` (bare hex for INI-style configs).
- Conditionals: `{{#variant dark}} … {{/variant}}` and `{{#if variant == "dark"}} … {{#else}} … {{/if}}`, plus `{{#if is_light}}`; `not ` prefix works.
- `P`, `variant`, `is_light` are only defined **inside** a `{{#variant}}` block (or per-variant rows).
- Errors fail loud, never silent: unknown key → `KeyError`, unknown function/condition → `KeyError`, unclosed section → `RuntimeError`. A typo in a template breaks `make gen`; that is intended.

## Vim colorscheme specifics

- `colors/greenit.vim` holds both variants; `colors/greenit-light.vim` is a 3-line shim (`let g:greenit_light = 1` → `runtime! colors/greenit.vim`). Edit the template, never the outputs.
- The test asserts `hi Normal` shows `guifg=#C9E4CE guibg=#0C1F17` (dark) / `#24382C` on `#F2F7EF` (light) and that `g:colors_name` is right.
- It runs Vim headless in ex mode with `:redir` into a mktemp file and asserts on the **captured output, never Vim's exit code** — a colorscheme error makes Vim exit non-zero but that must not trip `set -e`.
- Without vim installed the test prints "vim not installed — skipping" and exits **0**, so a local green `make test` proves nothing; CI has vim.

## Gotchas / stale docs

- Scripts resolve `TMPDIR` themselves (caller → Termux default → `mktemp -d`). Don't hardcode a path; the Termux default doesn't exist on CI runners.
- `README.md:30` hardcodes the WCAG ratios (dark 12.64:1 / light 11.52:1) — `make contrast` only rewrites the table in `palette.md`, so this line is drift-prone. Verify it by hand after a palette change.
- `CONTRIBUTING.md` says "regenerate all **40** artifacts" — stale; it's 56. Its vim commands are the interactive form; `test-colorscheme.sh` is the authoritative headless check.
- README's "ripple rule" still describes manual propagation across `colors/`, `extras/`, `templates/` etc. — `gen.py` does that now; only `palette.json` needs touching.

## Conventions

- Branch `master` (tracks `origin/master`). Commit only when explicitly asked. Style: short imperative; `feat:` / `fix:` / `docs:` prefixes in use.
- MIT. No linters — `make check` is the whole gate.
