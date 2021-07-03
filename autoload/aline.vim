let s:modes = {
    \  'n':      ['%#ALineMode1#', '  normal  '],
    \  'i':      ['%#ALineMode2#', '  insert  '],
    \  'R':      ['%#ALineMode4#', '  replace '],
    \  'v':      ['%#ALineMode3#', '  visual  '],
    \  'V':      ['%#ALineMode3#', '  v-line  '],
    \  "\<C-v>": ['%#ALineMode3#', '  v-rect  '],
    \  'c':      ['%#ALineMode1#', '  c-mode  '],
    \  's':      ['%#ALineMode3#', '  select  '],
    \  'S':      ['%#ALineMode3#', '  s-line  '],
    \  "\<C-s>": ['%#ALineMode3#', '  s-rect  '],
    \  't':      ['%#ALineMode2#', ' terminal '],
    \  }

function! s:GitBranchName() abort
    if get(b:, 'gitbranch_pwd', '') !=# expand('%:p:h') || !has_key(b:, 'gitbranch_path')
        call s:GitDetect()
    endif

    if has_key(b:, 'gitbranch_path') && filereadable(b:gitbranch_path)
        let l:branchDetails = get(readfile(b:gitbranch_path), 0, '')
        if l:branchDetails =~# '^ref: '
            return substitute(l:branchDetails, '^ref: \%(refs/\%(heads/\|remotes/\|tags/\)\=\)\=', '', '')
        elseif l:branchDetails =~# '^\x\{20\}'
            return l:branchDetails[:6]
        endif
    endif

    return ''
endfunction

function! s:GitDetect() abort
    unlet! b:gitbranch_path
    let b:gitbranch_pwd = expand('%:p:h')
    let l:dir = s:GitDir(b:gitbranch_pwd)

    if l:dir !=# ''
        let l:path = l:dir . '/HEAD'
        if filereadable(l:path)
            let b:gitbranch_path = l:path
        endif
    endif
endfunction

function! s:GitDir(path) abort
    let l:path = a:path
    let l:prev = ''

    while l:path !=# prev
        let l:dir = path . '/.git'
        let l:type = getftype(l:dir)
        if l:type ==# 'dir' && isdirectory(l:dir . '/objects')
                    \ && isdirectory(l:dir . '/refs')
                    \ && getfsize(l:dir . '/HEAD') > 10
            " Looks like we found a '.git' directory.
            return l:dir
        elseif l:type ==# 'file'
            let l:reldir = get(readfile(l:dir), 0, '')
            if l:reldir =~# '^gitdir: '
                return simplify(l:path . '/' . l:reldir[8:])
            endif
        endif
        let l:prev = l:path
        " Go up a directory searching for a '.git' directory.
        let path = fnamemodify(l:path, ':h')
    endwhile

    return ''
endfunction

function! s:FileIcon() abort
    if !g:aline_nerd || !g:loaded_devicons
        return ''
    endif

    if g:nvim_web_devicons
        return luaeval("require'nvim-web-devicons'.get_icon(vim.fn.expand('%'), vim.fn.expand('%:e'))")
    endif
endfunction

function! s:GetFile() abort
    return expand('%')
endfunction

function! aline#ModeColor(mode) abort
    return get(s:modes, a:mode, '%#ALineMode1#')[0]
endfunction

function! aline#ModeText(mode) abort
    return get(s:modes, a:mode, '  normal  ')[1]
endfunction

function! aline#File() abort
    return s:FileIcon() . s:GetFile()
endfunction

function! aline#GitBranch() abort
    if !g:aline_git
        return ''
    endif

    let l:name = s:GitBranchName()
    if len(l:name) == 0
        return ''
    endif

    return ' [ ' . l:name . ' ] '
endfunction

function! aline#LSP() abort
    if !has('nvim-0.5') || !g:aline_nvim_lsp
        return ''
    endif

    let l:err_count = luaeval("vim.lsp.diagnostic.get_count(0, [[Error]])")

    return l:err_count . '  '
endfunction

function! aline#Status() abort
    let l:mode = mode()
    let l:statusline = aline#ModeColor(l:mode)
    let l:statusline .= aline#ModeText(l:mode)
    let l:statusline .= '%* %<%{aline#File()}'
    let l:statusline .= "%{&modified ? '+\ ' : ' \ \ '}"
    let l:statusline .= "%{&readonly ? 'RO\ ' : ''}"
    let l:statusline .= '%#ALineGit#%{aline#GitBranch()}'
    let l:statusline .= '%*%=%#ALineLsp#%{aline#LSP()}'
    let l:statusline .= '%l:%c | %7*%L%* | %P '

    return l:statusline
endfunction
