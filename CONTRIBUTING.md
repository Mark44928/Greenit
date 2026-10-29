# Contributing to Greenit

## Adding a new terminal emulator
1. Pick the palette from `palette.md` or `README.md`.
2. Create `extras/<emulator>.conf|.toml|.lua|.itermcolors|.json`.
3. Add an install section to `README.md` under "Terminal emulators".
4. Verify the config loads without errors.

## Changing the palette
1. Edit `colors/greenit.vim` (dark + light branches).
2. Update `palette.md` and `README.md` table.
3. Sync all `extras/*` terminal configs to match.
4. Test:
   ```sh
   vim -u NONE -N -c "set rtp+=$HOME/repos/Greenit" -c "colorscheme greenit" -c "hi Normal" -c "qa!"
   ```

## Submitting
- Open an issue to discuss, then a PR.
- Keep commits focused: one emulator or one palette change per PR.

## License
MIT
