let mapleader = "\<Space>"

"colorscheme evening

" since this is primarily going to be used for elm for now
let match_autoindent = 0

aug vimrc
	au!
	" highlight trailing whitespace
	au BufRead,SourcePre,WinNew * match trailingWhitespace /\s\+$/

	" ftplugins like to change this setting
	"au FileType * set formatoptions-=o
	au BufWinEnter * set formatoptions-=o
	"au FileType * set formatoptions&

	" I think this should be done in an ftplugin
	"au BufRead,BufNewFile *.pug setlocal wrap
aug end

highlight Folded ctermbg=DarkBlue ctermfg=White guibg=#666666 guifg=white
highlight trailingWhitespace ctermbg=Red guibg=red

noremap <Leader>n :nohlsearch<CR>
noremap <Leader>v :tabedit $MYVIMRC<CR>
noremap <Leader>s :write<CR>:source %<CR>

inoremap <C-J> <Right>

set
\	complete=.
\	foldmethod=indent
\	ignorecase smartcase
\	nofoldenable
\	nowrap
\	relativenumber
\	scrolloff=1 sidescrolloff=1
\	shiftwidth=0 tabstop=4
\	splitbelow splitright
\	wildmode=longest

" ftplugins like to change this setting
"set formatoptions-=o

fu! Init(type)
	let lnum = line(".")
	let lines =readfile(findfile("init/" . a:type . ".init", &runtimepath))
	let first_line = lines[0]
	let rest = lines[1:]
	cal setline(lnum, first_line)
	cal append(lnum, rest)
endf

command! -nargs=1 Init :cal Init(<f-args>)

call plug#begin("~/AppData/Local/nvim/plugged")
Plug 'tpope/vim-surround'
Plug 'neoclide/coc.nvim', {'branch': 'release'}

" Elm
Plug 'andys8/vim-elm-syntax'

" Pug
Plug 'digitaltoad/vim-pug'

Plug 'ursi/vim-match'
call plug#end()
