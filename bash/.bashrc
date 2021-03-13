alias apply=". ~/.bashrc"
cl () { cd $1; ls; }
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
jql () { jq -C $1 $2 | less -r; }
alias lls="ls --color | less -r"
alias ls="ls -A --color=tty --group-directories-first"
alias lsL="ls -L"

function mcd { mkdir -p $1 && cd $1; }
function mcp { mkdir -p $2 && cp $1 $2; }
function mcpd { mkdir -p $2 && cp $1 $2 && cd $2; }
function mmv { mkdir -p $2 && mv $1 $2; }
alias night="sct 3000 & disown"
alias rm='echo if you really wanna use this, use \\rm'
alias sus="systemctl suspend"
alias trash=trash-put
alias xclipc="xclip -selection clipboard"
alias xclipng="xclip -t image/png -selection clipboard"

function _gitBranch {
	local -r a=$(git branch --show-current 2> /dev/null)

	if [[ -n $a ]]; then
		echo "$_sepColor| $_branchColor$a "
	fi
}

function _nixShell
	if [[ -n $IN_NIX_SHELL ]]; then
		echo "$_nixShellColor[nix] "
	fi

_downgraded-nix () {
	# if [[ $(nix --version) = "nix (Nix) 2.3*" ]]; then
	if [[ $(nix --version) = "nix (Nix) 2.3"* ]]; then
		echo "[nix 2.3]"
	fi
}

function _makeColor { echo "\[\e[$1m\]"; }
_reset=$(_makeColor 0)
_bold=$(_makeColor 1)
_mainColor=$(_makeColor 32)
_branchColor=$(_makeColor 31)
_sepColor=$(_makeColor 34)
_nixShellColor=$(_makeColor 33)
function _makeTitle { echo "\[\e]0;$1\a\]"; }
_title=$(_makeTitle "\w")
PROMPT_COMMAND='export PS1="$_title\n$_bold$(_downgraded-nix)$(_nixShell)$_mainColor\w $(_gitBranch)$_mainColor\$$_reset "'
