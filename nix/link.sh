shopt -s extglob

for file in !(link.sh|result); do
	ln -f $file /etc/nixos
done
