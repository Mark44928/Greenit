# Greenit — generated theme family
#
# make gen        render every artifact from palette.json via gen.py
# make check      regenerate, fail on git diff (drift detection),
#                 regenerate WCAG table, then run the colorscheme load test
# make contrast   regenerate the WCAG contrast table in palette.md
# make test       run the Vim colorscheme load test (skips if vim is absent)

# TMPDIR is resolved by each script (Termux default first, then mktemp) so
# the same commands work on a phone and on CI runners.

.PHONY: gen check contrast test

# Invoke through the interpreter, not ./script: the files carry the Termux
# shebang (their path only exists on Android), which breaks `make` on Linux
# CI runners. Same commands, both platforms.
gen:
	python3 ./gen.py

contrast:
	python3 tests/contrast.py

test:
	bash ./test-colorscheme.sh

check: gen contrast
	git diff --exit-code
	@$(MAKE) test --no-print-directory
