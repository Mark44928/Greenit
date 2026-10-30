#!/data/data/com.termux/files/usr/bin/env python3
"""Render every Greenit artifact from palette.json.

Contract: running this script must leave `git diff` empty — generated
output is byte-identical to the committed files. That is the proof the
templates faithfully reproduce the theme family (dark + light variants).
"""
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent
PALETTE = ROOT / "palette.json"
TEMPLATES = ROOT / "templates"

TAG_RE = re.compile(r"\{\{(#variant|#if|#else|/variant|/if)\b([^}]*)\}\}")
INTERP_RE = re.compile(r"\$\{([^}]+)\}")

FUNCS = {
    "rgb_r": lambda h: f"{int(h[1:3], 16) / 255:.3f}",
    "rgb_g": lambda h: f"{int(h[3:5], 16) / 255:.3f}",
    "rgb_b": lambda h: f"{int(h[5:7], 16) / 255:.3f}",
}


def resolve(ctx, expr):
    expr = expr.strip()
    m = re.match(r"^([a-zA-Z_][a-zA-Z0-9_]*):(.+)$", expr)
    if m:
        name, arg = m.group(1), m.group(2)
        if name not in FUNCS:
            raise KeyError(f"unknown template function ${name}:{arg}")
        return FUNCS[name](resolve(ctx, arg))
    cur = ctx
    for part in expr.split("."):
        m = re.match(r"^([^\[]+)\[(\d+)\]$", part)
        if m:
            key, index = m.group(1), int(m.group(2))
            cur = cur[key]
            cur = cur[index]
        elif isinstance(cur, dict) and part in cur:
            cur = cur[part]
        else:
            raise KeyError(f"undefined palette key ${{{expr}}}")
    return cur


def truthy(cond, ctx):
    cond = cond.strip()
    neg = cond.startswith("not ")
    if neg:
        cond = cond[4:].strip()
    if cond == "is_light":
        val = bool(ctx.get("is_light"))
    else:
        m = re.match(r'^variant\s*==\s*["\']([^"\']*)["\']$', cond)
        if not m:
            raise KeyError(f"unknown template condition {{#{cond}}}")
        val = ctx.get("variant") == m.group(1)
    return not val if neg else val


def find_end(text, start, close_tag):
    open_name = close_tag[1:]
    depth = 0
    else_pos = -1
    i = start
    while True:
        m = TAG_RE.search(text, i)
        if not m:
            raise RuntimeError(f"unclosed {{#{open_name}}} section")
        tag = m.group(1)
        i = m.end()
        if tag == f"#{open_name}":
            depth += 1
        elif tag == close_tag and depth == 0:
            return m.start(), else_pos
        elif tag == f"/{open_name}":
            depth -= 1
        elif tag == "#else" and depth == 0 and open_name == "if":
            else_pos = m.end()


def render(text, ctx):
    out = []
    i = 0
    while True:
        m = TAG_RE.search(text, i)
        if not m:
            out.append(text[i:])
            break
        out.append(text[i:m.start()])
        tag, args = m.group(1), m.group(2).strip()
        if tag in ("/variant", "/if"):
            i = m.end()
            continue
        if tag == "#else":
            raise RuntimeError("stray {{#else}} outside {{#if}}")
        if tag == "#variant":
            end, _ = find_end(text, m.end(), "/variant")
            v = args
            variants = ctx["variants"]
            if v not in variants:
                raise KeyError(f"unknown variant {v}")
            ic = dict(ctx)
            ic["P"] = variants[v]
            ic["variant"] = v
            ic["is_light"] = v == "light"
            out.append(render(text[m.end():end], ic))
            i = end
        elif tag == "#if":
            end, else_pos = find_end(text, m.end(), "/if")
            inner = text[m.end(): else_pos if else_pos != -1 else end]
            if truthy(args, ctx):
                out.append(render(inner, ctx))
            elif else_pos != -1:
                out.append(render(text[else_pos:end], ctx))
            i = end
    text = "".join(out)
    return INTERP_RE.sub(lambda m: str(resolve(ctx, m.group(1))), text)


# template -> (output path, variant | None for both-variant template)
BUILDS = [
    ("termux.properties.tmpl", "termux/greenit-dark.properties", "dark"),
    ("termux.properties.tmpl", "termux/greenit-light.properties", "light"),
    ("kitty.conf.tmpl", "extras/kitty.conf", "dark"),
    ("alacritty.toml.tmpl", "extras/alacritty.toml", "dark"),
    ("ghostty.tmpl", "extras/ghostty", "dark"),
    ("wezterm.lua.tmpl", "extras/wezterm.lua", None),
    ("windows-terminal.json.tmpl", "extras/windows-terminal.json", "dark"),
    ("greenit.itermcolors.tmpl", "extras/greenit.itermcolors", "dark"),
    ("greenit.vim.tmpl", "colors/greenit.vim", None),
    ("greenit-light.vim.tmpl", "colors/greenit-light.vim", "dark"),
    # New app integrations (both variants)
    ("bat.tmTheme.tmpl", "bat/greenit-dark.tmTheme", "dark"),
    ("bat.tmTheme.tmpl", "bat/greenit-light.tmTheme", "light"),
    ("fzf.sh.tmpl", "fzf/greenit-dark.sh", "dark"),
    ("fzf.sh.tmpl", "fzf/greenit-light.sh", "light"),
    ("dircolors.tmpl", "dircolors/greenit-dark", "dark"),
    ("dircolors.tmpl", "dircolors/greenit-light", "light"),
    ("starship.toml.tmpl", "starship/greenit-dark.toml", "dark"),
    ("starship.toml.tmpl", "starship/greenit-light.toml", "light"),
    ("tmux.conf.tmpl", "tmux/greenit-dark.conf", "dark"),
    ("tmux.conf.tmpl", "tmux/greenit-light.conf", "light"),
    ("btop.theme.tmpl", "btop/greenit-dark.theme", "dark"),
    ("btop.theme.tmpl", "btop/greenit-light.theme", "light"),
]


def main():
    with open(PALETTE, encoding="utf-8") as fh:
        palettes = json.load(fh)["variants"]

    rendered = 0
    for template_name, output, variant in BUILDS:
        template = (TEMPLATES / template_name).read_text(encoding="utf-8")
        if variant is None:
            ctx = {"variants": palettes}
        else:
            p = palettes[variant]
            ctx = {
                "P": p,
                "variant": variant,
                "is_light": variant == "light",
                "vid": "01" if variant == "dark" else "02",
            }
        text = render(template, ctx)
        out_path = ROOT / output
        out_path.parent.mkdir(parents=True, exist_ok=True)
        out_path.write_text(text, encoding="utf-8")
        rendered += 1
        print(f"rendered {out_path}")

    print(f"rendered {rendered} artifacts from {len(palettes)} variants")
    return 0


if __name__ == "__main__":
    sys.exit(main())
