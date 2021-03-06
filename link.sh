cd $(dirname $0)

rm-and-run() {
	if [[ -e $1 ]]; then
		rm -r $1
	fi

	$2 $1
}

replace-config() {
	# f is needed because symlinks to nowhere don't pass the -e test
	rm-and-run ~/.config/$1 "ln -fs $(realpath $2)"
}

# bash
ln -fs $(realpath bash/.bashrc) ~/

# neovim
replace-config nvim neovim/config
