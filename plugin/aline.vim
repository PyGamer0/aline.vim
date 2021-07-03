if exists('g:loaded_aline')
    finish
endif
let g:loaded_aline = 1

let g:aline_git = get(g:, 'aline_git', 1)
let g:aline_nvim_lsp = get(g:, 'aline_nvim_lsp', 0)
let g:aline_nerd = get(g:, 'aline_nerd', 0)

highlight ALineMode1 guibg=#8888ff guifg=#363636
highlight ALineMode2 guibg=#88ff88 guifg=#363636
highlight ALineMode3 guibg=#ff8888 guifg=#363636
highlight ALineMode4 guibg=#ffff66 guifg=#363636
highlight ALineGit   guifg=#dd66ff
highlight ALineLsp   guifg=#ffff66

set statusline=%!aline#Status()
