" ------------------------------------- RUN PY BUFFER ----------------------

fu! DoRunPyBuffer2()
" write
wa
pclose! " force preview window closed
setlocal ft=python

" copy the buffer into a new window, then run that buffer through python
sil %y a | below new | sil put a | sil %!python -
" indicate the output window as the current previewwindow
setlocal previewwindow nomodifiable nomodified 
resize 1

" back into the original window
winc p
endfu

command! RunPyBuffer call DoRunPyBuffer2()
" map <Leader>p :RunPyBuffer<CR>
map <F5> :RunPyBuffer<CR>
map <F2> :pc<CR>


autocmd TextChanged,TextChangedI *.spy call DoRunPyBuffer2()
