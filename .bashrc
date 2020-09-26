alias apply="source ~/.bashrc"
alias day="sct 6500"
alias i3conf="nvim ~/dotfiles/i3/config"
alias lls="ls --color | less -r"
alias ls="ls -A --color=tty --group-directories-first"
alias lsL="ls -L"
alias night="sct 3000"
alias xclipc="xclip -selection clipboard"
alias xclipng="xclip -t image/png -selection clipboard"

function trash { mv $1 ~/.trash; }

function gitBranch {
	a=$(git branch --show-current 2> /dev/null)

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
sepColor=$(makeColor "38;2;0;150;255")
nixShellColor=$(makeColor 33)
function makeTitle { echo "\[\e]0;$1\a\]"; }
title=$(makeTitle "\w")
PROMPT_COMMAND='export PS1="$title\n$bold$(nixShell)$mainColor\w $(gitBranch)$mainColor\$$reset "'
