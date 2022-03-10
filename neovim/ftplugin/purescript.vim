setlocal expandtab shiftwidth=2
setlocal iskeyword+='
inoremap <buffer> <Tab> <Space><Space>

" let b:ale_fixers = ['purty']
" let b:ale_linters = 'all'

nnoremap <buffer> <Leader>i ^y$Pa :: <Home>instance <Esc>l~hhelxA<Space>
nnoremap <buffer> <Leader>t YpA =<Esc>kA ::<Space>

iabbrev <buffer> forall ∀
nmap <buffer> <Leader>d <Plug>(coc-diagnostic-next)
nmap <buffer> <Leader>j <Plug>(coc-definition)zz
