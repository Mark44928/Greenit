#!/data/data/com.termux/files/usr/bin/env python3
"""Regenerate the WCAG contrast table in palette.md from palette.json.

Hand-maintaining those ratios is exactly the drift the ripple rule warns
about: change one color in palette.json and every documented ratio silently
becomes a lie. This script recomputes them (WCAG 2.0 relative-luminance
formula) and rewrites the table in place, so `make contrast` is idempotent.
"""
from __future__ import annotations

import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
PALETTE = ROOT / "palette.json"
PALETTE_MD = ROOT / "palette.md"


def luminance(hex_color: str) -> float:
    channels = []
    for i in (1, 3, 5):
        c = int(hex_color[i : i + 2], 16) / 255
        channels.append(c / 12.92 if c <= 0.03928 else ((c + 0.055) / 1.055) ** 2.4)
    r, g, b = channels
    return 0.2126 * r + 0.7152 * g + 0.0722 * b


def contrast(fg: str, bg: str) -> float:
    l1, l2 = luminance(fg), luminance(bg)
    if l1 < l2:
        l1, l2 = l2, l1
    return (l1 + 0.05) / (l2 + 0.05)


def flat_colors(variant: dict) -> dict[str, str]:
    """palette.json stores colors in nested sections; the docs talk in one
    flat namespace (fg, primary, color0, ...)."""
    colors: dict[str, str] = {}
    colors.update(variant["editor"])
    colors.update(variant["accents"])
    colors["color0"] = variant["ansi"][0]
    colors["color8"] = variant["ansi"][8]
    return colors


PAIRS = ["fg", "primary", "secondary", "error", "rose", "cyan", "yellow", "comment", "color0", "color8"]


def main() -> int:
    palettes = json.loads(PALETTE.read_text(encoding="utf-8"))["variants"]

    lines = [
        "| Variant | Pair            | Ratio | Pass AA |",
        "|---------|-----------------|-------|---------|",
    ]
    for variant in ("dark", "light"):
        colors = flat_colors(palettes[variant])
        bg = colors["bg"]
        for name in PAIRS:
            if name not in colors:
                continue
            ratio = contrast(colors[name], bg)
            label = f"{name} / bg"
            passes = "yes" if ratio >= 4.5 else "no*"
            lines.append(f"| {variant.capitalize():<7} | {label:<15} | {ratio:>5.2f} | {passes:<7} |")

    table = "\n".join(lines)
    text = PALETTE_MD.read_text(encoding="utf-8")
    pattern = re.compile(
        r"\| Variant \| Pair.*?\n(?:\|.*\n)*",  # existing table rows
    )
    new_text, n = pattern.subn(table + "\n", text, count=1)
    if n != 1:
        print("contrast: could not find the WCAG table in palette.md", file=sys.stderr)
        return 1

    if new_text != text:
        PALETTE_MD.write_text(new_text, encoding="utf-8")
        print("contrast: palette.md table regenerated")
    else:
        print("contrast: palette.md already up to date")
    return 0


if __name__ == "__main__":
    sys.exit(main())
