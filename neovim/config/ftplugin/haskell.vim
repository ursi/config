setlocal shiftwidth=2 expandtab
setlocal iskeyword+='
inoremap <buffer> <Tab> <Space><Space>

nnoremap <buffer> <Leader>t YpA =<Esc>kA ::<Space>
iabbrev <buffer> unqual import         <Space>
nmap <buffer> <Leader>d <Plug>(coc-diagnostic-next)
nmap <buffer> <Leader>j <Plug>(coc-definition)zz
