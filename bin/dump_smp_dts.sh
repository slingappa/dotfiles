#./build/qemu-system-riscv64  \
#    -smp 2  \
#    -machine virt,dumpdtb=test.dtb && dtc -I dtb -O dts -o test.dts test.dtb && vim test.dts

./build/qemu-system-riscv64  -m 2G,slots=2,maxmem=4G \
    -object memory-backend-ram,size=1G,id=m0 \
    -object memory-backend-ram,size=1G,id=m1 \
    -numa node,nodeid=0,memdev=m0 \
    -numa node,nodeid=1,memdev=m1 \
    -smp 2,sockets=2,maxcpus=2  \
    -machine virt,rpmi=on,dumpdtb=test.dtb && dtc -I dtb -O dts -o test.dts test.dtb && vim test.dts

