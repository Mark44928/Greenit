#!/data/data/com.termux/files/usr/bin/env python3
"""Greenit palette preview — render the palette as terminal color swatches.

Reads palette.json (the single source of truth) and prints the dark and light
variants as ANSI truecolor blocks. No dependencies.

Usage:
    python3 preview.py            # both variants
    python3 preview.py dark       # dark only
    python3 preview.py light      # light only
    python3 preview.py --no-color # print hex values only
"""

import json
import os
import sys

PALETTE = os.path.join(os.path.dirname(os.path.abspath(__file__)), "palette.json")


def hex_to_rgb(h):
    h = h.lstrip("#")
    return int(h[0:2], 16), int(h[2:4], 16), int(h[4:6], 16)


def swatch(hex_color, use_color):
    r, g, b = hex_to_rgb(hex_color)
    if use_color:
        return f"\033[48;2;{r};{g};{b}m    \033[0m"
    return "    "


def render_variant(name, variant, use_color):
    lines = [f"\n{name.upper()} variant"]
    term = variant.get("terminal", {})
    if "background" in term:
        lines.append(f"  bg   {swatch(term['background'], use_color)} {term['background']}")
    if "foreground" in term:
        lines.append(f"  fg   {swatch(term['foreground'], use_color)} {term['foreground']}")
    ansi = variant.get("ansi", [])
    for i, c in enumerate(ansi):
        lines.append(f"  a{i:<2} {swatch(c, use_color)} {c}")
    accents = variant.get("accents", {})
    for k, c in accents.items():
        lines.append(f"  {k:<8} {swatch(c, use_color)} {c}")
    return "\n".join(lines)


def main(argv):
    use_color = "--no-color" not in argv and sys.stdout.isatty()
    which = [a for a in argv if not a.startswith("-")]
    with open(PALETTE, encoding="utf-8") as fh:
        variants = json.load(fh)["variants"]
    names = which or list(variants)
    out = []
    for n in names:
        if n in variants:
            out.append(render_variant(n, variants[n], use_color))
    print("\n".join(out))


if __name__ == "__main__":
    main(sys.argv[1:])