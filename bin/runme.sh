#rm /home/redpanda/ventana-sw/secure-boot/keys/ventana-synth-edk2-fit-0.19.1.itb ; rm -vf  /home/redpanda/ventana-sw/0.19.1/platform/bios_edk2_riscv64_ventana.img ;  rm -rvf /home/redpanda/ventana-sw/edk2-synth/edk2/Build-edk2;   ./buildscripts/main.sh -u -s > buildscripts.log  2>&1


rm -rf edk2-synth/Build; rm -rf secure-boot/keys/ventana*; rm -rf ~/ventana-sw/*/zstage/build; rm -rf opensbi/build; rm  -f /home/redpanda/ventana-sw/secure-boot/keys/ventana-synth-edk2-fit-0.19.1.itb ; rm -vf  /home/redpanda/ventana-sw/0.19.1/platform/bios_edk2_riscv64_ventana.img ;  rm -rvf /home/redpanda/ventana-sw/edk2-synth/edk2/Build-edk2;   ./buildscripts/main.sh -u -s > buildscripts.log  2>&1

#
# ~/ventana-sw/qemu/build/qemu-system-riscv64 -M ventana-synth-v2,ri2c=on -smp 1 -m 2G -nographic -bios /home/redpanda/ventana-sw/zstage_synth-v2/zstage/build/platform/ventana/vt2/synth/firmware/zstage.bin -drive  file=/home/redpanda/ventana-sw/0.19.1/platform/bios_edk2_riscv64_ventana.img,format=raw,if=sd -device virtio-net-pci,netdev=eth0,romfile= -netdev user,hostfwd=tcp::10041-:22,id=eth0 -drive file=/home/redpanda/ts_ws/ventana-sw-0.19.1-rc4/ubuntu-25.04-preinstalled-server-riscv64.img,id=hd0,format=raw -device nvme,serial=ddaaddaa,drive=hd0 -nographic -qmp unix:/tmp/qmp-guest-socket,server,nowait -monitor telnet:127.0.0.1:10042,server,nowait  > edk2_logs.log  2>&1
#
# /home/redpanda/git/ventana_openbmc_ws/src/qemu//build/qemu-system-arm -m 512M -M ventana-bmc -nographic -drive file=obmc.mtd,format=raw,if=mtd -device remote-i2c,bus=aspeed.i2c.bus.1,id=remote-i2c-master,address=0x62,tsocket=/tmp/master-socket -net nic -net user,hostfwd=:127.0.0.1:2222-:22,hostfwd=:127.0.0.1:2443-:443,hostfwd=tcp:127.0.0.1:2200-:2200,hostfwd=udp:127.0.0.1:2623-:623 -trace events=i2c-events.txt -trace file=i2c-trace.log -qmp unix:/tmp/qmp-bmc-socket,server,nowait -monitor
# telnet:127.0.0.1:5555,server,nowait -d guest_errors -D bmc_logs.log   -device ds1338,bus=aspeed.i2c.bus.6,address=0x51
#
