setlocal shiftwidth=4 expandtab
highlight Pmenu guibg=#222222
" highligh CoCErrorSign guifg=white
nmap <buffer> <Leader>l ysiw"I_ = Debug.log <Esc>A<Space>
nnoremap <buffer> <Leader>t YpA =<Esc>kA :<Space>
nnoremap <buffer> <Leader>u ebi{ <Esc>ea \|  }<Esc>hi
nmap <buffer> <Leader>d <Plug>(coc-diagnostic-next)
nmap <buffer> <Leader>j <Plug>(coc-definition)zz
