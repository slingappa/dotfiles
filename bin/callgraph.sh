#-GENFLAGS       =       -Wall -Werror -O2
#+GENFLAGS       =       -Wall -Werror -O2 -fdump-rtl-expand
egypt $(find . -name '*.expand' -print) | dot -Grankdir=LR  -Gsize=11,8.5 -Tpdf -o callgraph.pdf

