#!/bin/bash

# Determine the script's directory
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)

set -x
function build_edk2() {
	export GCC5_RISCV64_PREFIX=/local/mnt/workspace/ts_ws_0.21.1-rc2/ventana-cross-toolchain-2025.11.18/bin/riscv64-unknown-linux-gnu-
	export WORKSPACE=`pwd`
	export PACKAGES_PATH=$WORKSPACE/edk2:$WORKSPACE/edk2/edk2-platforms
	export EDK_TOOLS_PATH=$WORKSPACE/edk2/BaseTools
	source edk2/edksetup.sh --reconfig
	#export BUILD_TYPE=DEBUG
	export BUILD_TYPE=RELEASE
	make -C edk2/BaseTools clean
	make -C edk2/BaseTools
	make -C edk2/BaseTools/Source/C
	source edk2/edksetup.sh BaseTools
	#build -a RISCV64 -D FIRMWARE_VER="iommu_fix" --buildtarget RELEASE -p edk2/edk2-platforms/Platform/VentanaMicro/VentanaSynth/VentanaSynth.dsc -t GCC5
	build -a RISCV64 -D FIRMWARE_VER="grub_dbg" --buildtarget $BUILD_TYPE -p edk2/edk2-platforms/Platform/VentanaMicro/VentanaSynth/VentanaSynth.dsc -t GCC5 cleanall
	build -a RISCV64 -D FIRMWARE_VER="grub_dbg" --buildtarget $BUILD_TYPE -p edk2/edk2-platforms/Platform/VentanaMicro/VentanaSynth/VentanaSynth.dsc -t GCC5

}

function build_fit() {
	cp $WORKSPACE/Build/VentanaSynth/${BUILD_TYPE}_GCC5/FV/VENTANASYNTH.fd .
	cp $WORKSPACE/../opensbi/build/platform/generic/firmware/fw_dynamic.bin .
	cp $SCRIPT_DIR/synth.dts ventana-edk2-synth.dts

	mkimage -f ventana-edk2-synth.dts ventana-synth-edk2-fit.itb

}

function fetch_build_gentools(){
	git clone https://github.com/pengutronix/genimage.git
	cd genimage
	./autogen.sh
	./configure CFLAGS='-g -O0' --prefix=/usr
	make
	cd ..

	git clone https://github.com/NodeOS/genfatfs.git
	cd genfatfs
	make
	cd ..
}

function build_sd_card(){

#	fetch_build_gentools

	rm -rf sdcard

	mkdir -p sdcard/bios_esp/FIRMWARE/ventana/synth-vx

	cp  ventana-synth-edk2-fit.itb sdcard/bios_esp/FIRMWARE/ventana/synth-vx/fw.itb

	dd if=/dev/zero of=./sdcard/bios_esp.img bs=1024 count=114688
	./genfatfs/genfatfs -d ./sdcard/bios_esp -b 114688 ./sdcard/bios_esp.img

	printf "image bios_edk2_riscv64_ventana.img {\n\
				size = 128M\n\
				\n\
				hdimage {\n\
					partition-table-type = gpt\n\
				}\n\
				\n\
				partition esp {\n\
				image = \"bios_esp.img\"\n\
				offset = 8M\n\
				size = 112M\n\
				partition-type-uuid = C12A7328-F81F-11D2-BA4B-00A0C93EC93B\n\
				}\n\
			}\n" > ./sdcard/bios_edk2_riscv64_ventana.cfg

	./genimage/genimage --config ./sdcard/bios_edk2_riscv64_ventana.cfg --inputpath ./sdcard --outputpath ./sdcard

	ls sdcard/bios_edk2_riscv64_ventana.img

}

build_edk2
build_fit
build_sd_card
