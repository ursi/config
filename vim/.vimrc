let mapleader = "\<Space>"
"let g:snipMate.snippet_version = 1

colorscheme evening

autocmd bufRead,sourcePre,winNew * highlight trailingWhitespace ctermbg=Red guibg=red
"autocmd sourcePre * highlight trailingWhitespace ctermbg=Red guibg=red
"autocmd winNew * highlight trailingWhitespace ctermbg=Red guibg=red

autocmd bufRead,sourcePre,winNew * match trailingWhitespace /\s\+$/
"autocmd sourcePre * match trailingWhitespace /\s\+$/
"autocmd winNew * match trailingWhitespace /\s\+$/

autocmd bufRead,BufNewFile *.pug setlocal wrap

filetype plugin on

noremap <Leader>n :noh<CR>
noremap <Leader>v :tabedit $MYVIMRC<CR>
noremap <Leader>vv :source $MYVIMRC<CR>

nnoremap <Leader>g :!git<Space>

inoremap <S-CR> <CR><Tab>

autocmd BufRead,BufNewFile * hi Folded ctermbg=DarkBlue ctermfg=White guibg=#666666 guifg=white

set autoindent
set autoread
set backspace=indent,eol,start
set complete=.
set encoding=utf-8
set foldmethod=indent
set guifont=consolas:h12
set guioptions=""
set hlsearch ignorecase incsearch
set nowrap
set relativenumber
set ruler
set scrolloff=1 sidescrolloff=1
set shiftwidth=0
set smartcase
set splitbelow splitright
"set showtabline=2
set tabstop=4
set wildmode=longest

syntax enable
