# Greenit

Green-injected terminal and Vim theme family. Like energreen but slightly greener — every neutral hue-shifted toward green, every accent a green derivative.

Two variants: **Dark** (`greenit`) and **Light** (`greenit-light`).

## Preview

![Greenit palette preview — Dark and Light variants](assets/palette-preview.png)

WCAG AA: dark fg/bg = 12.64:1, light fg/bg = 11.52:1.

## Vim / Neovim

```bash
git clone https://github.com/Mark44928/Greenit.git
cp colors/greenit.vim ~/.vim/colors/
cp colors/greenit-light.vim ~/.vim/colors/
```

```vim
" init.vim
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

## Terminal emulators

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

## Palette

| Role | Dark | Light |
|---|---|---|
| bg | `#0C1F17` | `#F2F7EF` |
| surface | `#122A1F` | `#E6EFE2` |
| fg | `#C9E4CE` | `#24382C` |
| comment | `#5F7A66` | `#7A9078` |
| primary | `#7BD88F` | `#7BD88F` |
| secondary | `#63C9A8` | `#63C9A8` |
| yellow | `#B8CC7A` | `#B8CC7A` |
| rose | `#A88EA0` | `#A88EA0` |
| cyan | `#7FD7C4` | `#7FD7C4` |
| error | `#C07A6E` | `#C07A6E` |

## License

MIT
