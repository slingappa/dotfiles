git commit -a  --amend --no-edit; git push -f; rm *.patch && git format-patch -1  ;../linux/scripts/checkpatch.pl *.patch | more\
