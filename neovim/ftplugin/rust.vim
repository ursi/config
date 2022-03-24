command! -nargs=0 Format :call CocActionAsync('format')
nmap <buffer> <Leader>d <Plug>(coc-diagnostic-next)
nmap <buffer> <Leader>j <Plug>(coc-definition)zz
nmap <buffer> <Leader>t <Plug>(coc-type-definition)zz
