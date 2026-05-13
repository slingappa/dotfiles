export LC_ALL="en_US.UTF-8"
export LC_CTYPE="en_US.UTF-8"
sudo dpkg-reconfigure locales

git config --global http.version HTTP/1.1

git config checkout.workers 8

git config --global http.postBuffer 2048M
git config --global http.maxRequestBuffer 1024M
git config --global core.compression 9

git config --global ssh.postBuffer 2048M
git config --global ssh.maxRequestBuffer 1024M

git config --global pack.windowMemory 256m
git config --global pack.packSizeLimit 256m

 . setup  evb-ast2600


 export LC_ALL=C

 vim conf/local.conf

 BB_NUMBER_THREADS = "4"
 PARALLEL_MAKE = "-j 4"
 PARALLEL_MAKEINST = "-j 4"


 bitbake obmc-phosphor-image

