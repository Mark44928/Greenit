import { readFileSync } from "node:fs";
import assert from "node:assert/strict";

const html = readFileSync(new URL("../gallery.html", import.meta.url), "utf8");
const start = html.indexOf("function copyPathFor");
const end = html.indexOf("\n  }", start) + 4;
assert.ok(start >= 0 && end > start, "copyPathFor not found");
const body = html.slice(start, end);
const call = new Function("btn", "current", `${body}; return copyPathFor(btn);`);
const btn = (path) => ({ getAttribute: () => path });

assert.equal(call(btn("termux/greenit-dark.properties"), "light"), "termux/greenit-light.properties");
assert.equal(call(btn("colors/greenit.vim"), "light"), "colors/greenit.vim");
assert.equal(call(btn("extras/kitty.conf"), "light"), "extras/kitty-light.conf");
assert.equal(call(btn("extras/ghostty"), "light"), "extras/ghostty-light");
assert.equal(call(btn("extras/alacritty.toml"), "light"), "extras/alacritty-light.toml");
assert.equal(call(btn("extras/wezterm.lua"), "light"), "extras/wezterm.lua");
assert.equal(call(btn("termux/greenit-dark.properties"), "all"), "termux/greenit-dark.properties");
console.log("gallery copy filtering OK");
