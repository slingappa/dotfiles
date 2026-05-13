#bash

. setup romulus
. setup  mtjade
. setup  evb-ast2600


export LC_ALL=C

vim conf/local.conf

BB_NUMBER_THREADS = "4"
PARALLEL_MAKE = "-j 4"
PARALLEL_MAKEINST = "-j 4"


bitbake obmc-phosphor-image

