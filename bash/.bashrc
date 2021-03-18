_ls() { ls -A --color=tty --group-directories-first $@; }

alias apply=". ~/.bashrc"
cl () { cd $@; _ls; }

gh-clone-cd () {
	git clone git@github.com:$1/$2 && cd $2
}

git-clone-cd () {
	git clone $1 && cd $(echo $1 | sed -E 's/^.*\/([^./]+)(.git)?$/\1/')
}

jql () { jq -C $1 $2 | less -r; }
alias grep="grep -n"
alias ls=_ls
function mcd { mkdir -p $1 && cd $1; }
alias rm='echo if you really wanna use this, use \\rm'
alias sus="systemctl suspend"
alias trash=trash-put
alias xclipc="xclip -selection clipboard"
alias xclipng="xclip -t image/png -selection clipboard"

_git-branch () {
	local -r a=$(git branch --show-current 2> /dev/null)

	if [[ -n $a ]]; then
		echo "$_sepColor| $_branchColor$a "
	fi
}

_nix-shell () {
	if [[ -n $IN_NIX_SHELL ]]; then
		echo "$_nixShellColor[nix] "
	fi
}

_downgraded-nix () {
	# if [[ $(nix --version) = "nix (Nix) 2.3*" ]]; then
	if [[ $(nix --version) = "nix (Nix) 2.3"* ]]; then
		echo "[nix 2.3]"
	fi
}

_make-color () { echo "\[\e[$1m\]"; }
_reset=$(_make-color 0)
_bold=$(_make-color 1)
_mainColor=$(_make-color 32)
_branchColor=$(_make-color 31)
_sepColor=$(_make-color 34)
_nixShellColor=$(_make-color 33)
_make-title () { echo "\[\e]0;$1\a\]"; }
_title=$(_make-title "\w")
PROMPT_COMMAND='export PS1="$_title\n$_bold$(_downgraded-nix)$(_nix-shell)$_mainColor\w $(_git-branch)$_mainColor\$$_reset "'
