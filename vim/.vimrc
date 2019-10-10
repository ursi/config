let mapleader = "\<Space>"

colorscheme evening

aug vimrc
	au!
	au BufRead,SourcePre,WinNew * highlight trailingWhitespace ctermbg=Red guibg=red
	au BufRead,SourcePre,WinNew * match trailingWhitespace /\s\+$/
	au BufRead,BufNewFile *.pug setlocal wrap
	au BufWinEnter * normal zi
	au BufRead,BufNewFile * highlight Folded ctermbg=DarkBlue ctermfg=White guibg=#666666 guifg=white
aug end

filetype plugin on

noremap <Leader>n :noh<CR>
noremap <Leader>v :tabedit $MYVIMRC<CR>
noremap <Leader>vv :source $MYVIMRC<CR>

nnoremap <Leader>d ^elxd$o<Tab><Esc>p$r,o|" change from a single line delclaration to a multiline one
nnoremap <Leader>g :!git<Space>

inoremap <S-CR> <CR><Tab>

set
\	autoindent
\	autoread
\	backspace=indent,eol,start
\	complete=.
\	encoding=utf-8
\	foldmethod=indent
\	guifont=consolas:h12
\	guioptions=
\	hlsearch ignorecase incsearch
\	nowrap
\	relativenumber
\	ruler
\	scrolloff=1 sidescrolloff=1
\	shiftwidth=0 tabstop=4
\	smartcase
\	splitbelow splitright
\	wildmode=longest

syntax enable
