#!/usr/bin/env python3
"""Render docs/palette.png from palette.json — side-by-side dark/light swatches.

python3 scripts/swatch.py
"""
import json
import os

from PIL import Image, ImageDraw, ImageFont

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
FONT_PATHS = [
    '/data/data/com.termux/files/home/.termux/font.ttf',
    '/data/data/com.termux/files/usr/share/fonts/TTF/DejaVuSansMono.ttf',
]
FONT = next((p for p in FONT_PATHS if os.path.exists(p)), FONT_PATHS[-1])
F_MAIN = ImageFont.truetype(FONT, 15)
F_SMALL = ImageFont.truetype(FONT, 11)
F_BIG = ImageFont.truetype(FONT, 26)
F_MID = ImageFont.truetype(FONT, 13)

M = 22  # outer margin
W = 560   # panel width
PAD = 18
ANSI_CELL = 30


def hexrgb(hx):
    hx = hx.lstrip('#')
    return tuple(int(hx[i:i+2], 16) for i in (0, 2, 4))


def luminance(rgb):
    r, g, b = [c / 255 for c in rgb]
    return 0.2126 * r + 0.7152 * g + 0.0722 * b


def panel(draw, origin_x, variant, data):
    bg = hexrgb(data['terminal']['background'])
    fg = hexrgb(data['terminal']['foreground'])
    sec = data['editor']
    surf = hexrgb(sec['surface'])
    rows = 0
    x0 = origin_x
    # panel frame
    draw.rounded_rectangle([x0, M, x0 + W, M + 560], radius=16, fill=bg, outline=surf, width=2)
    y = M + PAD
    draw.text((x0 + PAD, y), 'Greenit — ' + variant, font=F_BIG, fill=hexrgb(data['accents']['primary']))
    y += 30
    draw.text((x0 + PAD, y), 'palette.json · terminal · editor · accents · ansi', font=F_SMALL, fill=hexrgb(sec['comment']))
    y += 22
    # surface/fg sample
    draw.rounded_rectangle([x0 + PAD, y, x0 + W - PAD, y + 64], radius=8, fill=surf)
    draw.text((x0 + PAD + 12, y + 10), 'fg on surface', font=F_MID, fill=fg)
    draw.text((x0 + PAD + 12, y + 28), 'Sample text 123 {}[];<>?', font=F_MAIN, fill=hexrgb(sec['fg']))
    y += 78
    # accents
    draw.text((x0 + PAD, y), 'accents', font=F_MID, fill=fg)
    y += 16
    ax = x0 + PAD
    for name, hex_ in data['accents'].items():
        c = hexrgb(hex_)
        pill_fill = c
        pill_fg = (0, 0, 0) if luminance(pill_fill) > 0.5 else (255, 255, 255)
        w = 16 * len(name) + 28
        draw.rounded_rectangle([ax, y, ax + w, y + 26], radius=13, fill=pill_fill)
        draw.text((ax + 12, y + 5), name, font=F_SMALL, fill=pill_fg)
        ax += w + 8
        if ax + w > x0 + W - PAD:
            ax = x0 + PAD
            y += 34
    y += 44
    # ansi grid
    draw.text((x0 + PAD, y), 'ansi', font=F_MID, fill=fg)
    y += 18
    for row in range(2):
        for col in range(8):
            c = hexrgb(data['ansi'][row * 8 + col])
            cx = x0 + PAD + col * (ANSI_CELL + 8)
            draw.rounded_rectangle([cx, y + row * (ANSI_CELL + 10), cx + ANSI_CELL, y + row * (ANSI_CELL + 10) + ANSI_CELL], radius=5, fill=c)
    y += 2 * (ANSI_CELL + 10) + 8
    draw.text((x0 + PAD, y), 'terminal chrome: background · foreground · cursor · selection', font=F_SMALL, fill=hexrgb(sec['comment']))
    return bg


def main():
    cfg = json.load(open(os.path.join(ROOT, 'palette.json')))
    img = Image.new('RGB', (M * 3 + W * 2, M * 2 + 580), (14, 14, 14))
    draw = ImageDraw.Draw(img)
    for i, variant in enumerate(['dark', 'light']):
        panel(draw, M + i * (W + M), variant, cfg['variants'][variant])
    out = os.path.join(ROOT, 'docs', 'palette.png')
    os.makedirs(os.path.dirname(out), exist_ok=True)
    img.save(out)
    print('wrote', out, img.size)


if __name__ == '__main__':
    main()
