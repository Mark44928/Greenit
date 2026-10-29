" Greenit light variant — hue-shifted green theme (light).
" Recipe: energreen, slightly greener.
" Thin shim: flags the light variant then sources the shared greenit.vim.
"   :colorscheme greenit-light
let g:greenit_light = 1
let $GREENIT_LIGHT = '1'
runtime! colors/greenit.vim
