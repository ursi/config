setlocal shiftwidth=2 expandtab
setlocal iskeyword+='

nnoremap <buffer> <Leader>t YpA =<Esc>kA :: 
iabbrev <buffer> unqual import          
nmap <buffer> <Leader>d <Plug>(coc-diagnostic-next)
nmap <buffer> <Leader>j <Plug>(coc-definition)zz
