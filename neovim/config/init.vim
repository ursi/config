call plug#begin()
Plug 'morhetz/gruvbox'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-commentary'
Plug 'ursi/vim-match'

" CoC
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'kevinoid/vim-jsonc'

" Plug 'dense-analysis/ale'

" Elm
Plug 'andys8/vim-elm-syntax'

" JavaScript
Plug 'pangloss/vim-javascript'

" Pug
Plug 'digitaltoad/vim-pug'

" PureScript
Plug 'purescript-contrib/purescript-vim'

" Dhall
Plug 'autozimu/LanguageClient-neovim', {
    \ 'branch': 'next',
    \ 'do': 'bash install.sh',
    \ }

Plug 'vmchale/dhall-vim'

" Nix
Plug 'LnL7/vim-nix'

"Plug 'relastle/bluewery.vim'
call plug#end()

let g:LanguageClient_serverCommands = {
    \ 'dhall': ['dhall-lsp-server'],
    \ }

let g:dhall_format=1

let mapleader = "\<Space>"

let gruvbox_invert_tabline = 1
let gruvbox_invert_selection = 0
colorscheme gruvbox

let g:ale_linters_explicit = 1
let g:ale_fix_on_save = 1

" since this is primarily going to be used for elm for now
let match_autoindent = 0

" enable my settings in netrw (not sure why this has that effect)
let netrw_bufsettings_defaults = "noma nomod nonu nowrap ro nobl"
let g:netrw_bufsettings = netrw_bufsettings_defaults

aug vimrc
	au!
	" highlight trailing whitespace
	au BufRead,SourcePre,WinNew * match trailingwhitespace /\s\+$/

	" ftplugins like to change this setting
	au BufWinEnter * set formatoptions-=o formatoptions-=r indentexpr=""

	" make autoread work like gvim
	au FocusGained * :checktime

	au TermOpen * startinsert
aug end

highlight trailingWhitespace ctermbg=Red guibg=red

fu! MapEvery(mapStr)
	"let prefixes = ['', "v", "s", 'l', 't']
	let prefixes = ['', 'v', 's', 'i', 'l', 't']
	let almostAllMapCmds = map(prefixes, 'v:val . "noremap"')
	"let allMapCmds = add(almostAllMapCmds, 'noremap!')
	"let allMaps = map(allMapCmds, 'v:val . " " . a:mapStr')
	let allMaps = map(almostAllMapCmds, 'v:val . " " . a:mapStr')
	cal map(allMaps, 'execute(v:val)')
endf

"cal MapEvery('<Tab> <Esc>')
"cal MapEvery('<BS> <Tab>')
"cnoremap <Tab> <Esc>

noremap <Leader>c :cd %:h<CR>
noremap <Leader>n :nohlsearch<CR>
noremap <Leader>v :tabedit $MYVIMRC<CR>
noremap <Leader>s :write<CR>:source %<CR>

inoremap <C-J> <Right>

nnoremap <Down> gj
nnoremap <Up> gk

vnoremap q :normal ^@q<CR>

"to use n spaces instead of tabs
"se sw=n et

"\	backupdir-=.
set	complete=.,w
" something to do with PureScript tooling I believe
set	backupcopy=yes
set	directory=.
set	foldmethod=indent
set	ignorecase smartcase
set	nofoldenable
set	nowrap
set	relativenumber
set	scrolloff=1 sidescrolloff=1
set	shiftwidth=0 tabstop=4
set	splitbelow splitright
set	wildmode=longest
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
