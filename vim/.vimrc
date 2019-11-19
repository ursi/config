let mapleader = "\<Space>"

colorscheme evening

filetype plugin on

aug vimrc
	au!
	au BufRead,SourcePre,WinNew * highlight trailingWhitespace ctermbg=Red guibg=red
	au BufRead,SourcePre,WinNew * match trailingWhitespace /\s\+$/
	au BufRead,BufNewFile *.pug setlocal wrap
	au BufWinEnter * normal zi
	au BufRead,BufNewFile * highlight Folded ctermbg=DarkBlue ctermfg=White guibg=#666666 guifg=white
	au FileType * set formatoptions&
aug end

noremap <Leader>n :noh<CR>
noremap <Leader>v :tabedit $MYVIMRC<CR>
noremap <Leader>s :write<CR>:source %<CR>
noremap <Leader>f :h function-list<CR>

nnoremap <Leader>d ^elxd$o<Tab><Esc>p$r,o|" change from a single line delclaration to a multiline one
nnoremap <Leader>g :!git<Space>

inoremap <C-J> <Right>

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

fu! Init(test)
	let lnum = line(".")
	let lines =readfile(findfile("init/" . a:test . ".init", &runtimepath))
	let first_line = lines[0]
	let rest = lines[1:]
	cal setline(lnum, first_line)
	cal append(lnum, rest)
endf

command! -nargs=1 Init :cal Init(<f-args>)

fu! Bracket()
	let cur_line = getline(".")
	let last_char = nr2char(strgetchar(cur_line, strlen(cur_line) - 1))
	if last_char == ";"
		retu "^l%la{\<Enter>\<Tab>\<Esc>o\<BS>}\<Esc>k"
	elsei last_char == ")"
		retu "A {\<Esc>jo\<BS>}\<Esc>k"
	elsei last_char == "{"
		retu "$2x\<S-D>2jdd2k"
	en
endf

nn <expr> <Leader>b Bracket()
