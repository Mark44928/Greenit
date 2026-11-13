#!/usr/bin/env python3
"""Render assets/palette-preview.svg from palette.json — dark/light swatch rows.

Stdlib-only. Regenerate with:

    python3 scripts/svgswatch.py

Layout mirrors the original hand-drawn preview: two panels (dark left, light
right), each a stack of framed swatch rows (terminal.bg, editor.surface,
editor.fg, editor.comment, then the six accents).
"""
import json
import os

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(ROOT, 'assets', 'palette-preview.svg')

WIDTH = 1536
HEIGHT = 1060
PAGE = '#f5f5f5'
FRAME = '#464646'
INK = '#24382C'
PANEL_W = 196
PANEL_H = 64
ROW_STEP = 86
ROW_Y0 = 120
PANEL_X = {'dark': 70, 'light': 848}

ROWS = [
    ('bg', lambda v: v['terminal']['background']),
    ('surface', lambda v: v['editor']['surface']),
    ('fg', lambda v: v['editor']['fg']),
    ('comment', lambda v: v['editor']['comment']),
    ('primary', lambda v: v['accents']['primary']),
    ('secondary', lambda v: v['accents']['secondary']),
    ('yellow', lambda v: v['accents']['yellow']),
    ('rose', lambda v: v['accents']['rose']),
    ('cyan', lambda v: v['accents']['cyan']),
    ('error', lambda v: v['accents']['error']),
]


def esc(s):
    return s.replace('&', '&amp;').replace('<', '&lt;').replace('>', '&gt;')


def panel(lines, variant, data):
    x = PANEL_X[variant]
    for i, (label, get) in enumerate(ROWS):
        y = ROW_Y0 + i * ROW_STEP
        hex_ = get(data)
        lines.append(f'<rect x="{x}" y="{y}" width="{PANEL_W}" height="{PANEL_H}" fill="{FRAME}"/>')
        lines.append(f'<rect x="{x + 3}" y="{y + 3}" width="{PANEL_W - 6}" height="{PANEL_H - 6}" fill="{hex_}"/>')
        tx = x + PANEL_W + 28
        lines.append(f'<text x="{tx}" y="{y + 22}" font-family="Cascadia Code" font-size="21" fill="{INK}">{esc(label)}</text>')
        lines.append(f'<text x="{tx}" y="{y + 46}" font-family="Cascadia Code" font-size="19" fill="{INK}">{esc(hex_)}</text>')


def main():
    cfg = json.load(open(os.path.join(ROOT, 'palette.json')))
    lines = [
        f'<svg xmlns="http://www.w3.org/2000/svg" width="{WIDTH}" height="{HEIGHT}" viewBox="0 0 {WIDTH} {HEIGHT}">',
        f'<title>Greenit palette preview — dark (left) and light (right) variants</title>',
        f'<rect width="{WIDTH}" height="{HEIGHT}" fill="{PAGE}"/>',
    ]
    for variant in ('dark', 'light'):
        panel(lines, variant, cfg['variants'][variant])
    lines.append('</svg>')
    with open(OUT, 'w', encoding='utf-8') as f:
        f.write('\n'.join(lines) + '\n')
    print('wrote', OUT)


if __name__ == '__main__':
    main()
