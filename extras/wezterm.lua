-- Greenit Dark — green-injected theme for WezTerm
-- Install: cp extras/wezterm.lua ~/.config/wezterm/greenit.lua
--   then in ~/.wezterm.lua:
--     local greenit = require("greenit")
--     greenit.apply(config)

local M = {}

local dark = {
  background = "#0C1F17",
  foreground = "#C9E4CE",
  cursor_bg = "#C9E4CE",
  cursor_fg = "#0C1F17",
  selection_bg = "#122A1F",
  selection_fg = "#C9E4CE",
  ansi = {
    "#1A331C", "#A88EA0", "#7BD88F", "#B8CC7A",
    "#63C9A8", "#A88EA0", "#7FD7C4", "#A7C4A3",
  },
  brights = {
    "#5F7A66", "#A88EA0", "#7BD88F", "#B8CC7A",
    "#63C9A8", "#A88EA0", "#7FD7C4", "#C9E4CE",
  },
}

local light = {
  background = "#F2F7EF",
  foreground = "#24382C",
  cursor_bg = "#24382C",
  cursor_fg = "#F2F7EF",
  selection_bg = "#E6EFE2",
  selection_fg = "#24382C",
  ansi = {
    "#1A331C", "#A88EA0", "#7BD88F", "#B8CC7A",
    "#63C9A8", "#A88EA0", "#7FD7C4", "#A7C4A3",
  },
  brights = {
    "#5F7A66", "#A88EA0", "#7BD88F", "#B8CC7A",
    "#63C9A8", "#A88EA0", "#7FD7C4", "#C9E4CE",
  },
}

function M.apply(config, variant)
  local theme = (variant == "light") and light or dark
  config.colors = {
    background = theme.background,
    foreground = theme.foreground,
    cursor_bg = theme.cursor_bg,
    cursor_fg = theme.cursor_fg,
    selection_bg = theme.selection_bg,
    selection_fg = theme.selection_fg,
    ansi = theme.ansi,
    brights = theme.brights,
  }
  config.color_scheme = nil
  config.color_schemes = nil
end

return M
