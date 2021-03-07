cd $(dirname $0)

function replaceDir {
	dir=~/.config/$2

	if [[ -e $dir ]]; then
		rm -fr $dir
	fi

	ln -s $(realpath $1) $dir
}

# bash
ln -fs $(realpath bash/.bashrc) ~/

# git
ln -fs $(realpath git/.gitconfig) ~/
replaceDir git git

# i3
replaceDir i3/i3 i3
replaceDir i3/i3status i3status

# neovim
replaceDir neovim/config nvim
