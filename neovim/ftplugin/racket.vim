iabbrev <buffer> lambda λ
nnoremap <buffer> <Leader>f :w \| !raco fmt -i --width 80 %<CR>
setlocal commentstring=;\ %s
