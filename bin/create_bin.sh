i=0; while [ $i -lt 256 ]; do echo -en '\x'$(printf "%0x" $i)''  >> binary.dat; i=$((i+1));  done
