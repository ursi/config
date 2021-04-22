asdf () { echo $@; }
if [[ $@ = *--config-file* ]]; then
	asdf $@;
else
	asdf --config-file file $@;
fi

