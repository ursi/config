setlocal expandtab shiftwidth=2
inoremap <buffer> <Tab> <Space><Space>
nnoremap <buffer> <Leader>f :w \| !nix fmt %<CR>
