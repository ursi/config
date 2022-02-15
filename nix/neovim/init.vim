let g:markdown_composer_open_browser = 0
let g:markdown_composer_autostart = 0

let g:LanguageClient_serverCommands = {
    \ 'dhall': ['dhall-lsp-server'],
    \ }

let g:dhall_format = 1

let mapleader = "\<Space>"

let gruvbox_invert_tabline = 1
let gruvbox_invert_selection = 0
colorscheme gruvbox

let g:ale_linters_explicit = 1
let g:ale_fix_on_save = 1

" enable my settings in netrw (not sure why this has that effect)
let netrw_bufsettings_defaults = "noma nomod nonu nowrap ro nobl"
let g:netrw_bufsettings = netrw_bufsettings_defaults

augroup vimrc
	autocmd!
	" highlight trailing whitespace
	autocmd BufRead,SourcePre,WinNew * match trailingwhitespace /\s\+$/

	" ftplugins like to change these settings
	autocmd BufWinEnter * set formatoptions-=o formatoptions-=r indentexpr=""

	" make autoread work like gvim
	autocmd FocusGained * :checktime

	autocmd TermOpen * startinsert
augroup end

highlight trailingWhitespace ctermbg=Red guibg=red

function! MapEvery(mapStr)
	"let prefixes = ['', "v", "s", 'l', 't']
	let prefixes = ['', 'v', 's', 'i', 'l', 't']
	let almostAllMapCmds = map(prefixes, 'v:val . "noremap"')
	"let allMapCmds = add(almostAllMapCmds, 'noremap!')
	"let allMaps = map(allMapCmds, 'v:val . " " . a:mapStr')
	let allMaps = map(almostAllMapCmds, 'v:val . " " . a:mapStr')
	call map(allMaps, 'execute(v:val)')
endfunction

"call MapEvery('<Tab> <Esc>')
"call MapEvery('<BS> <Tab>')
"cnoremap <Tab> <Esc>


noremap <Leader>b :ls t<CR>:b<Space>
noremap <Leader>c :cd %:h<CR>
noremap <Leader>s :write<CR>:source %<CR>
exe "noremap <Leader>v :tabe " . expand("<sfile>:p") . "<CR>"
noremap <C-H> gT
noremap <C-L> gt
nnoremap  :noh<CR>
" ^ ctrl + /

inoremap <C-J> <Right>
cnoremap <C-J> <Right>

nnoremap <Down> gj
nnoremap <Up> gk

vnoremap q :normal ^@q<CR>

"to use n spaces instead of tabs
"se sw=n et

"set backupdir-=.
set complete=.,w,b
" something to do with PureScript tooling I believe
set backupcopy=yes
set cursorcolumn
set noequalalways
set foldmethod=indent
set hidden
set ignorecase smartcase
set mouse=n
set nofoldenable
set relativenumber
set scrolloff=1 sidescrolloff=1
set shiftwidth=0 tabstop=4
set splitbelow splitright
set undofile
set wildmode=longest:full,full
" ftplugins like to change this setting
"set formatoptions-=o

command! -nargs=1 Init :call Init(<f-args>)

function! SplitOff(line1, line2)
	let top = a:line1
	let size = a:line2 - a:line1 + 1
	execute "normal " . top . "G"
	execute "above " . size . "sp"
	normal zt
	let scroll = min([&scrolloff, float2nr((size - 1) / 2)])

	if scroll != 0
		execute "normal " . scroll . "\<c-e>"
	endif

	execute "normal \<c-w>w"
endfunction

command! -range SplitOff :call SplitOff(<line1>, <line2>)

function! Indent(count)
	let top = line("'<")
	let indentTop = indent(top)
	let bottom = line("'>")
	let above = top - 1

	while getline(above) == "" && above > 1
		let above -= 1
	endwhile

	if strcharpart(getline(above), strlen(getline(above)) - 1) == ")"
		let regex = '\w\|('
	else
		let regex = '\w'
	endif

	let offset = max([ match(trim(getline(above)), regex), 0 ])

	for line in range(top, bottom)
	    if getline(line) != ""
			execute line . "left " . (indent(above) + offset + a:count + indent(line) - indentTop)
		endif
	endfor
endfunction

vnoremap . :call Indent(v:count)<CR>
vnoremap , :call Indent(-v:count)<CR>

inoremap <M-"> ""<Left>
inoremap <M-'> ''<Left>
inoremap <M-(> ()<Left>
inoremap <M-<> <><Left>
inoremap <M-[> []<Left>
inoremap <M-`> ``<Left>
inoremap <M-{> {}<Left>
