#!/bin/bash

set -x
set -e
# Load variables from .env file
source  ~/workspace/git/buildscripts/.env

export WORKDIR=`pwd`
cd ${WORKDIR}
#VENTANA_RELEASE=0.16.1


# command line argument -a
BUILD_ALL=false
# command line argument -e
BUILD_EDK2=false
# command line argument -u
BUILD_UBOOT=false

while getopts "alcfsd:" arg; do
case $arg in
        a) BUILD_ALL=true;;
        e) BUILD_EDK2=true;;
        u) BUILD_UBOOT=true;;

esac
done

log_msg () {
        echo "$(tput bold)$(tput setaf 4)"
        echo "##################################"
        echo "$1"
        echo "##################################"
        echo "$(tput sgr0)"
}

log_err () {
        echo "$(tput bold)$(tput setaf 1)"
        echo "##################################"
        echo "$1"
        echo "##################################"
        echo "$(tput sgr0)"
}

build() {


#======================================================================================================================================================================
##EDK2
#======================================================================================================================================================================

	if [ $BUILD_ALL = "true" -o $BUILD_EDK2 = "true" ]; then
                cd ${WORKDIR}
                if [ ! -f sdcard/bios_esp-edk2/FIRMWARE/ventana/synth-vx ]; then

                        mkdir -p sdcard/bios_esp-edk2/FIRMWARE/ventana/synth-vx
                fi


				file2=${WORKDIR}/edk2/edk2.itb

				if [ ! -f "$file1" ] && [ ! -f "$file2" ]; then
					  echo "ERROR: Neither $file1 nor $file2 exist as regular files."
					  exit 1
				fi

                if [ -e $file2 ]; then

                        cp $file2 ${WORKDIR}/sdcard/bios_esp-edk2/FIRMWARE/ventana/synth-vx/fw.itb

                fi

                cd ${WORKDIR}/sdcard

                if [ ! -f bios_edk2_esp.img ]; then
                        dd if=/dev/zero of=bios_edk2_esp.img bs=1024 count=114688
                fi


                if [ -e bios_edk2_esp.img ]; then
                        ./genfatfs/genfatfs -d bios_esp-edk2 -b 114688 bios_edk2_esp.img

                fi

                if [ ! -f bios_riscv64_ventana-edk2.cfg ]; then
			printf "image bios_edk2_riscv64_ventana.img {\n\
				size = 128M\n\
		        \n\
        	        	hdimage {\n\
                	        	partition-table-type = gpt\n\
        	        	}\n\
		        \n\
        	        	partition esp {\n\
        		                image = \"bios_edk2_esp.img\"\n\
	                	        offset = 8M\n\
                        		size = 112M\n\
                	        	partition-type-uuid = C12A7328-F81F-11D2-BA4B-00A0C93EC93B\n\
        	        	}\n\
	        	}\n" > bios_edk2_riscv64_ventana.cfg
		fi

                if [ -e bios_edk2_riscv64_ventana.cfg ]; then
                        ./genimage/genimage --config bios_edk2_riscv64_ventana.cfg --inputpath . --outputpath .
                fi


	        if [ $? -ne 0 ]; then
        	        log_err "genfatfs build failed"
                	exit 1
	        fi


        	if [ -e bios_edk2_riscv64_ventana.img ]; then

                	cp bios_edk2_riscv64_ventana.img ${WORKDIR}/${VENTANA_RELEASE}/platform
	        fi

        	if [ $? -ne 0 ]; then
                	log_err "genfatfs build failed"
	                exit 1
        	fi
	fi
}
build




