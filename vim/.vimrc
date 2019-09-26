let mapleader = " "

colorscheme evening

autocmd bufRead * highlight trailingWhitespace ctermbg=Red guibg=red
autocmd sourcePre * highlight trailingWhitespace ctermbg=Red guibg=red
autocmd winNew * highlight trailingWhitespace ctermbg=Red guibg=red

autocmd bufRead * match trailingWhitespace /\s\+$/
autocmd sourcePre * match trailingWhitespace /\s\+$/
autocmd winNew * match trailingWhitespace /\s\+$/

noremap <Leader>v :tabedit $MYVIMRC<CR>
noremap <Leader>vv :source $MYVIMRC<CR>

set autoindent
set backspace=indent,eol,start
set complete=.
set guifont=consolas:h12
set guioptions=""
set hlsearch
set ignorecase
set incsearch
set nowrap
set relativenumber
set ruler
set shiftwidth=0
set smartcase
"set showtabline=2
set tabstop=4
set wildmode=longest

syntax enable
syntax on
