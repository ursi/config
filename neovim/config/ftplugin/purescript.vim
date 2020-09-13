setlocal
\	shiftwidth=2 expandtab
\	iskeyword+='

let b:ale_fixers = ['purty']
let b:ale_linters = 'all'

nnoremap <buffer> <Leader>i ^y$Pa :: <Home>instance <Esc>l~hhelxA 
nnoremap <buffer> <Leader>t YpA =<Esc>kA :: 
iabbrev <buffer> forall ∀

