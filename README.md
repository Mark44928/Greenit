# Greenit

![MIT License](https://img.shields.io/badge/license-MIT-green.svg)
![Vim](https://img.shields.io/badge/vim-9%2B-green.svg)
![Neovim](https://img.shields.io/badge/neovim-0.9%2B-green.svg)
![Termux](https://img.shields.io/badge/termux-supported-green.svg)

Green-injected terminal and Vim theme family. Like energreen but slightly greener — every neutral hue-shifted toward green, every accent a green derivative.

Two variants: **Dark** (`greenit`) and **Light** (`greenit-light`).

## Preview

![Greenit palette preview — Dark and Light variants](assets/palette-preview.svg)

WCAG AA: dark fg/bg = 12.64:1, light fg/bg = 11.52:1. Comment contrast fixed to AA on dark (78997F, 4.65:1).

## Quick Install

### Vim / Neovim (manual)

```bash
git clone https://github.com/Mark44928/Greenit.git
cp Greenit/colors/greenit.vim ~/.vim/colors/
cp Greenit/colors/greenit-light.vim ~/.vim/colors/
```

```vim
" ~/.vimrc or init.vim
set termguicolors
colorscheme greenit        " dark
" colorscheme greenit-light  " light
```

### Plugin managers

**vim-plug**
```vim
Plug 'Mark44928/Greenit', { 'rtp': 'colors' }
colorscheme greenit
```

**packer.nvim**
```lua
use { 'Mark44928/Greenit', rtp = 'colors' }
vim.cmd('colorscheme greenit')
```

**lazy.nvim**
```lua
{ 'Mark44928/Greenit', rtp = 'colors', config = function()
  vim.cmd('colorscheme greenit')
end }
```

**dein.vim**
```vim
call dein#add('Mark44928/Greenit', { 'rtp': 'colors' })
colorscheme greenit
```

**vim-addon-manager**
```bash
mkdir -p ~/.vim/addons
ln -s $HOME/repos/Greenit ~/.vim/addons/Greenit
vim -c "ActivateAddons Greenit" -c "colorscheme greenit"
```

## Terminal Emulators

### Kitty
```bash
cp extras/kitty.conf ~/.config/kitty/greenit.conf
# add to kitty.conf:  include greenit.conf
```

### Alacritty
```bash
mkdir -p ~/.config/alacritty/themes
cp extras/alacritty.toml ~/.config/alacritty/themes/greenit.toml
# add to alacritty.toml:  import = ["~/.config/alacritty/themes/greenit.toml"]
```

### Ghostty
```bash
cp extras/ghostty ~/.config/ghostty/greenit
# add to config:  include = ~/.config/ghostty/greenit
```

### WezTerm
```bash
cp extras/wezterm.lua ~/.config/wezterm/greenit.lua
# in ~/.wezterm.lua:  require("greenit")
```

### iTerm2
```bash
# open iTerm2 → Preferences → Profiles → Colors → Color Presets → Import
# select extras/greenit.itermcolors
```

### Windows Terminal
Import `extras/windows-terminal.json` as a color scheme via **Settings → Color schemes → Import**.

### Termux
```bash
cp termux/greenit-dark.properties ~/.termux/colors.properties && termux-reload-settings
# light variant:
cp termux/greenit-light.properties ~/.termux/colors.properties && termux-reload-settings
```

## Verify the Colorscheme

```bash
# Dark variant — Normal must show guifg/#C9E4CE guibg/#0C1F17, name prints 'greenit'
vim -u NONE -N -c "set t_Co=256 rtp+=$HOME/repos/Greenit" \
    -c "colorscheme greenit" -c "hi Normal" -c "echo g:colors_name" -c "qa!"

# Light variant — Normal must show guifg/#24382C guibg/#F2F7EF, name prints 'greenit-light'
vim -u NONE -N -c "set t_Co=256 rtp+=$HOME/repos/Greenit" \
    -c "colorscheme greenit-light" -c "hi Normal" -c "echo g:colors_name" -c "qa!"
```

## Palette

| Role | Dark | Light |
|------|------|-------|
| bg | `#0C1F17` | `#F2F7EF` |
| surface | `#122A1F` | `#E6EFE2` |
| fg | `#C9E4CE` | `#24382C` |
| comment | `#78997F` | `#56695C` |
| primary | `#7BD88F` | `#7BD88F` |
| secondary | `#63C9A8` | `#63C9A8` |
| yellow | `#B8CC7A` | `#B8CC7A` |
| rose | `#A88EA0` | `#A88EA0` |
| cyan | `#7FD7C4` | `#7FD7C4` |
| error | `#C07A6E` | `#C07A6E` |

## ANSI 16-Color Table

Bright colors (8–15) are visibly lighter variants of their normal counterparts (1–7), per the recipe. No duplicates.

| Var | Dark | Light |
|-----|------|-------|
| color0 | `#1A331C` | `#E6EFE2` |
| color1 | `#A88EA0` | `#C07A6E` |
| color2 | `#7BD88F` | `#7BD88F` |
| color3 | `#B8CC7A` | `#B8CC7A` |
| color4 | `#63C9A8` | `#63C9A8` |
| color5 | `#A88EA0` | `#A88EA0` |
| color6 | `#7FD7C4` | `#7FD7C4` |
| color7 | `#A7C4A3` | `#C9E4CE` |
| color8 | `#78997F` | `#56695C` |
| color9 | `#D4B4C0` | `#E49A8E` |
| color10 | `#9BEDAF` | `#9BEDAF` |
| color11 | `#D4E49A` | `#D4E49A` |
| color12 | `#8FE4C4` | `#8FE4C4` |
| color13 | `#D4B4C0` | `#D4B4C0` |
| color14 | `#A7EBDC` | `#A7EBDC` |
| color15 | `#C9E4CE` | `#FFFFFF` |

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for adding terminal emulators, changing the palette, and submitting PRs.

## License

[MIT](LICENSE)
