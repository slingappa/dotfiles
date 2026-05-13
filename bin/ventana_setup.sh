# ./scripts/ventana_setup.sh /home/$USER/files/ventana-sw-0.18.1.tar.xz /home/$USER/files/ventana-sw-openbmc-0.18.1-rc1.ta
set -x
set -e

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)

REL_FILE_PATH=$1
REL_FILE=$(basename $REL_FILE_PATH)
REL_DIR=$(echo $REL_FILE  | rev | cut -c8- | rev)

REL_OBMC_FILE_PATH=$2
REL_OBMC_FILE=$(basename $REL_OBMC_FILE_PATH)
REL_OBMC_DIR=$(echo $REL_OBMC_FILE  | rev | cut -c8- | rev)

# Extract the release file
VENTANA_SW_VERSION=0.18.1

# Setup Ventana OpenBMC
setup_bmc() {
	DIR=$SCRIPT_DIR/../../$REL_OBMC_DIR
	rm -rf $DIR && mkdir $DIR && cd $DIR
	cp -v $REL_OBMC_FILE_PATH .
	tar xf $REL_OBMC_FILE
	pwd
	ls
}

# Setup Ventana cloudini
setup_cloud_init() {
	DIR=$SCRIPT_DIR/../../$REL_DIR
	rm -rf $DIR && mkdir $DIR && cd $DIR
	cp -v $REL_FILE_PATH .
	tar xf $REL_FILE
	pwd
	ls

	wget https://cdimage.ubuntu.com/releases/25.04/release/ubuntu-25.04-preinstalled-server-riscv64.img.xz

	rm -f ubuntu-25.04-preinstalled-server-riscv64.img

	xz -dvk ubuntu-25.04-preinstalled-server-riscv64.img.xz


	qemu-img resize ubuntu-25.04-preinstalled-server-riscv64.img +15G
	./QEMU-x86_64-Ubuntu-20.04.AppImage -m 4G -M ventana-synth-v2 -nographic \
		-bios ./platform/ventana-synth-v2/zstage/zstage.bin \
		-sd ./platform/bios_edk2_riscv64_ventana.img \
		-device virtio-net-pci,netdev=eth0 -netdev user,hostfwd=tcp::9991-:22,id=eth0 \
		-drive file=./ventana-cloud-ubuntu.iso,id=hd1,format=raw \
		-device nvme,serial=aaddaadd,drive=hd1 \
		-drive file=./ubuntu-25.04-preinstalled-server-riscv64.img,id=hd0,format=raw \
		-device nvme,serial=ddaaddaa,drive=hd0

 }

login_check() {
cat > "./check_login.exp"  << EOF
#!/usr/bin/expect
#
set prompt "#|%|>|\\\$"; # We escaped the `$` symbol with backslash to match literal '$'
set cmd [lindex $argv 0]
set output " "

spawn ssh -o StrictHostKeyChecking=accept-new ventana@localhost -p9991

expect "ventana@localhost's password:
send "ventana\r"

sleep 2

expect -re $prompt
send "uptime\r"
expect -re $prompt
send "uname -a\r"
expect -re $prompt
puts "The output is '$expect_out(buffer)'."
EOF

chmod +x ./login_check.exp
 ./login_check.exp

}
# run qemu after successful setup
run_qemu() {
cd $SCRIPT_DIR/../../$REL_DIR
./QEMU-x86_64-Ubuntu-20.04.AppImage -M ventana-synth-v2 -nographic \
	 -bios ./platform/ventana-synth-v2/zstage/zstage.bin \
	 -sd ./platform/bios_edk2_riscv64_ventana.img \
	 -device virtio-net-pci,netdev=eth0 -netdev user,hostfwd=tcp::9991-:22,id=eth0 \
	 -drive file=./ubuntu-25.04-preinstalled-server-riscv64.img,id=hd0,format=raw \
	 -device nvme,serial=ddaaddaa,drive=hd0

}

cleanup(){
	sudo kill -9 `ps -ef | grep -i qemu | grep -v grep | grep $USER | awk '{print $2}'` > /dev/null 2>&1 || true
	sudo kill -9 `ps -ef | grep -i http.server | grep -v grep | grep $USER | awk '{print $2}'` > /dev/null 2>&1 || true
	python -m http.server 8000 &
}

#cleanup

#setup_bmc
#setup_cloud_init

cd $SCRIPT_DIR/../../$REL_DIR
#run_qemu
login_check
