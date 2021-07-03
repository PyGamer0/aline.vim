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

function! s:StatusLine() abort
    setlocal statusline = %!aline#Status()
endfunction

function! s:UpdateWindows() abort
    for winnum in range(1, winnr('$'))
        if winnum != winnr()
            call setwinvar(winnum, '&statusline', '%!aline#InactiveLine()')
        endif
    endfor
endfunction

augroup ALinesEvents
    autocmd!
    autocmd VimEnter * call s:UpdateWindows()
    autocmd WinEnter,BufWinEnter,WinLeave  * call s:StatusLine()
augroup END
