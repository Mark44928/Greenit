# Greenit — generated theme family
#
# make gen        render every artifact from palette.json via gen.py
# make check      regenerate, fail on git diff (drift detection),
#                 regenerate WCAG table, then run the colorscheme load test
# make contrast   regenerate the WCAG contrast table in palette.md
# make test       run the Vim colorscheme load test (skips if vim is absent)

export TMPDIR := /data/data/com.termux/files/usr/tmp

.PHONY: gen check contrast test

gen:
	./gen.py

contrast:
	python3 tests/contrast.py

test:
	./test-colorscheme.sh

check: gen contrast
	git diff --exit-code
	@$(MAKE) test --no-print-directory
