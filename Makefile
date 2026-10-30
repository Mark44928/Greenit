# Greenit — generated theme family
#
# make gen     render every artifact from palette.json via gen.py
# make check   regenerate, fail on git diff (drift detection),
#              and node --check any JavaScript sources where applicable

export TMPDIR := /data/data/com.termux/files/usr/tmp

.PHONY: gen check

gen:
	./gen.py

check: gen
	git diff --exit-code
	@find . -path ./.git -prune -o -name '*.js' -type f -exec node --check {} \;
