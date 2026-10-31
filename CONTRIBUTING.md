# Contributing to Greenit

Greenit is a **generated theme family**: every artifact is rendered from a single `palette.json` by `gen.py` (stdlib only). Do not edit generated artifact files directly — edit the source of truth and regenerate.

## Project structure

| File | Purpose |
|------|---------|
| `palette.json` | Single source of truth — all color values, both variants |
| `gen.py` | Renders every artifact from `palette.json` |
| `templates/*.tmpl` | One template per app format |
| `Makefile` | `make gen` renders all; `make check` regenerates + drift check |

## Changing the palette

1. Edit `palette.json` (dark and/or light variant).
2. Run `make gen` to regenerate all 40 artifacts.
3. Run `make check` to verify no drift (`git diff --exit-code` must be clean).
4. Update `palette.md` and `README.md` tables if you changed values.
5. Test the vim colorscheme:
   ```sh
   vim -u NONE -N -c "set t_Co=256 rtp+=$HOME/repos/Greenit" \
       -c "colorscheme greenit" -c "hi Normal" -c "echo g:colors_name" -c "qa!"
   vim -u NONE -N -c "set t_Co=256 rtp+=$HOME/repos/Greenit" \
       -c "colorscheme greenit-light" -c "hi Normal" -c "echo g:colors_name" -c "qa!"
   ```

## Adding a new app integration

1. Create `templates/<app>.tmpl` following an existing template's structure.
2. Add entries to `BUILDS` in `gen.py` (one per variant, dark + light).
3. Run `make gen` and `make check`.
4. Add install instructions to `README.md` under "Quick Install".
5. Commit: template, generated variants, gen.py changes.

## The ripple rule

Changing a color means changing it everywhere — `palette.json`, `colors/*.vim`, `termux/*.properties`, `extras/*`, `templates/*`, `palette.md`, and `README.md`. With the generator, you only touch `palette.json`; `gen.py` propagates to every artifact.

## Submitting

- Open an issue to discuss, then a PR.
- Keep commits focused: one integration or one palette change per PR.
- `make check` must pass before merging.

## License

MIT
