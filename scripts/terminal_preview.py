#!/usr/bin/env python3
"""Print the palette in the terminal with truecolor ANSI swatches.

python3 scripts/terminal_preview.py [dark|light]
"""
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
pal = json.loads((ROOT / "palette.json").read_text(encoding="utf-8"))


def rgb(h):
    h = h.lstrip("#")
    return tuple(int(h[i:i + 2], 16) for i in (0, 2, 4))


def fg(h):
    r, g, b = rgb(h)
    return f"\x1b[38;2;{r};{g};{b}m"


def bg(h):
    r, g, b = rgb(h)
    return f"\x1b[48;2;{r};{g};{b}m"


RESET = "\x1b[0m"
want = sys.argv[1] if len(sys.argv) > 1 else None
for variant in ("dark", "light"):
    if want and variant != want:
        continue
    v = pal["variants"][variant]
    t = v["terminal"]
    a = v["accents"]
    print(f"{fg(a['primary'])}{pal.get('name', ROOT.name)} — {variant}{RESET}")
    print(f"{bg(t['background'])}{fg(t['foreground'])}  Sample text 0123456789 {{}}[]()  {RESET}")
    print(f"{bg(t['selection_background'])}{fg(t['selection_foreground'])}  selection  {RESET}")
    for row in range(2):
        print("  " + "".join(f"{bg(c)}  " for c in v["ansi"][row * 8:row * 8 + 8]) + RESET)
    for name, hex_ in a.items():
        print(f"  {name:<10} {bg(hex_)}  {RESET} {hex_}")
    print()