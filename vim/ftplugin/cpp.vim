function! BuildCpp()
  if filereadable("./Makefile")
    make
  else
    execute("!g++ % -lpthread -o %<")
  endif
endfunction

function! BuildDebugCpp()
  if filereadable("./Makefile")
    make debug
  else
    execute("!g++ % -DDEBUG -g -lpthread -o %<")
  endif
endfunction

" build & run
noremap <Leader><F5> :w <CR> :call BuildCpp() <CR> :!./%< <CR>
noremap! <Leader><F5> <Esc> :w <CR> :call BuildCpp() <CR> :!./%< <CR>
" build & debug
noremap <F4> :w <CR> :call BuildDebugCpp() <CR> :ConqueGdb %< <CR>
noremap! <F4> <Esc> :w <CR> :call BuildDebugCpp() <CR> :ConqueGdb %< <CR>

" Conque Gdb
nnoremap <silent> <Leader>q :ConqueGdbCommand q<CR>
nnoremap <silent> <F5> :ConqueGdbCommand run<CR>
nnoremap <silent> <F6> :ConqueGdbCommand continue<CR>
nnoremap <silent> <F7> :ConqueGdbCommand next<CR>