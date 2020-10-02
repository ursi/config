alias apply="source ~/.bashrc"
alias day="sct 6500 & disown"

function gh-clone-cd {
	git clone git@github.com:$1/$2 && {
		local -r dir=$2
		cd $dir
	}
}

function git-clone-cd {
	git clone $1 && {
		local -r dir=$(echo $1 | sed -E 's/^.*\/([^./]+)(.git)?$/\1/')
		cd $dir
	}
}

alias i3conf="nvim ~/config/i3/i3/config"
alias lls="ls --color | less -r"
alias ls="ls -A --color=tty --group-directories-first"
alias lsL="ls -L"
function mcd { mkdir -p $1 && cd $1; }
function mcp { mkdir -p $2 && cp $1 $2; }
function mcpd { mkdir -p $2 && cp $1 $2 && cd $2; }
function mmv { mkdir -p $2 && mv $1 $2; }
alias night="sct 3000 & disown"
alias rm="rm -I"
alias trash=trash-put
alias xclipc="xclip -selection clipboard"
alias xclipng="xclip -t image/png -selection clipboard"

function gitBranch {
	local -r a=$(git branch --show-current 2> /dev/null)

	if [[ -n $a ]]; then
		echo "$sepColor| $branchColor$a "
	fi
}

function nixShell
	if [[ -n $IN_NIX_SHELL ]]; then
		echo "$nixShellColor[nix] "
	fi

function makeColor { echo "\[\e[$1m\]"; }
reset=$(makeColor 0)
bold=$(makeColor 1)
mainColor=$(makeColor 32)
branchColor=$(makeColor 31)
sepColor=$(makeColor 34)
nixShellColor=$(makeColor 33)
function makeTitle { echo "\[\e]0;$1\a\]"; }
title=$(makeTitle "\w")
PROMPT_COMMAND='export PS1="$title\n$bold$(nixShell)$mainColor\w $(gitBranch)$mainColor\$$reset "'
