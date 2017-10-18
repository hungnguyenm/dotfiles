" Some extra settings for indentation and tab
set tabstop=4
set softtabstop=4
set shiftwidth=4
set textwidth=79
set expandtab
set autoindent
set fileformat=unix

" Highlight 81st chars onward
augroup vimrc_autocmds
  autocmd BufEnter * highlight OverLength ctermbg=darkgrey guibg=#111111
  autocmd BufEnter * match OverLength /\%81v.*/
augroup END

" run and show results on the top
nmap <F4> :w<CR>:p<CR>:silent !python %:p 2>&1 \| tee $ZSH_VIM_TMP/py_out<CR>:sp $ZSH_VIM_TMP/py_out<CR>:redraw!<CR>
" run and show results on the right
nmap <F5> :w<CR>:p<CR>:silent !python %:p 2>&1 \| tee $ZSH_VIM_TMP/py_out<CR>:set splitright<CR>:vsp $ZSH_VIM_TMP/py_out<CR>:set nosplitright<CR>:redraw!<CR>