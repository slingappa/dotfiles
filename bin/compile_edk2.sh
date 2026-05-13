#!/bin/bash
#usage:
#gen_fit_image <EDK2_SOURCE_PATH> <OPENSBI_BIN_PATH> <EDK2_ENTRY_ADDR> <OPENSBI_ENTRY_ADDR> <CROSS_COMPILE_PREFIX>
#gen_fit_image src/edk2 opensbi/build/platform/generic/firmware/fw_dynamic.bin 0xc0200000 0xc7000000 /opt/riscv/bin/riscv64-unknown-linux-gnu-
generate_dts()
{
        #EDK2_ENTRY_ADDR=0xc0200000
        #OPENSBI_ENTRY_ADDR=0xc7000000
        EDK2_ENTRY_ADDR=$1
        OPENSBI_ENTRY_ADDR=$2
        rm -vf edk2.dts
        echo '
/dts-v1/;
/ {
    description = "Configuration file to create FIT image containing OpenSBI and EDK2";
    #address-cells = <0x01>;
    fit,fdt-list = "of-list";

    images {
      edk2 {
        description = "EDK2";
        type = "standalone";
        os = "u-boot";
        arch = "riscv";
        compression = "none";
        load = <'${EDK2_ENTRY_ADDR}'>;
        entry = <'${EDK2_ENTRY_ADDR}'>;
        data = /incbin/("uefi.bin");
      };

      opensbi {
        description = "OpenSBI fw_dynamic Firmware";
        type = "firmware";
        os = "opensbi";
        arch = "riscv";
        compression = "none";
        load = <'${OPENSBI_ENTRY_ADDR}'>;
        entry = <'${OPENSBI_ENTRY_ADDR}'>;
        data = /incbin/("fw_dynamic.bin");
      };
    };

    configurations {
      default = "conf-1";
      conf-1 {
        description = "EDK2 and OpenSBI FIT";
        firmware = "opensbi";
        loadables = "edk2";
      };
    };
};
        '  > edk2.dts

}

gen_fit_image()
{

  EDK_DIR=$1
  OPENSBI_BIN=$2
  EDK2_ENTRY_ADDR=$3
  OPENSBI_ENTRY_ADDR=$4
  CROSS_COMPILE_PREFIX=$5
  BUILD_TARGET=DEBUG


  cd $EDK_DIR
  export WORKSPACE=$EDK_DIR
  export GCC5_RISCV64_PREFIX=$CROSS_COMPILE_PREFIX
  export EDK_TOOLS_PATH=$WORKSPACE/BaseTools
  export PACKAGES_PATH=$WORKSPACE:$WORKSPACE/edk2-platforms

  generate_dts $EDK2_ENTRY_ADDR $OPENSBI_ENTRY_ADDR

  dlog "Compiling $EDK_DIR ..."
  source edksetup.sh BaseTools
  make -j`nproc` -C BaseTools clean
  make -j`nproc` -C BaseTools
  make -j`nproc` -C BaseTools/Source/C

  build -a RISCV64 -b ${BUILD_TARGET} -p edk2-platforms/Platform/VentanaMicro/Orbiter/Orbiter.dsc  -t GCC5

  rm uefi.bin 2>/dev/null | true
  ln -s Build/Orbiter/${BUILD_TARGET}_GCC5/FV/ORBITER.fd uefi.bin

  unlink fw_dynamic.bin | echo true
  ln -s $OPENSBI_BIN fw_dynamic.bin

  #cp ${ROOT_DIR}/edk2.dts .
  mkimage -f edk2.dts edk2.itb
  dlog "Compiling $EDK_DIR ... Done!"

}

#gen_fit_image src/edk2 opensbi/build/platform/generic/firmware/fw_dynamic.bin 0xc0200000 0xc7000000 /opt/riscv/bin/riscv64-unknown-linux-gnu-

gen_fit_image_virt()
{

  EDK_DIR=$1
  OPENSBI_BIN=$2
  EDK2_ENTRY_ADDR=$3
  OPENSBI_ENTRY_ADDR=$4
  CROSS_COMPILE_PREFIX=$5
  BUILD_TARGET=RELEASE


  cd $EDK_DIR
  export WORKSPACE=$EDK_DIR
  export GCC5_RISCV64_PREFIX=$CROSS_COMPILE_PREFIX
  export EDK_TOOLS_PATH=$WORKSPACE/BaseTools
  export PACKAGES_PATH=$WORKSPACE:$WORKSPACE/edk2-platforms

  generate_dts $EDK2_ENTRY_ADDR $OPENSBI_ENTRY_ADDR

  dlog "Compiling $EDK_DIR ..."
  source edksetup.sh BaseTools
  make -j`nproc` -C BaseTools clean
  make -j`nproc` -C BaseTools
  make -j`nproc` -C BaseTools/Source/C

  #build -a RISCV64 -b ${BUILD_TARGET} -p edk2-platforms/Platform/VentanaMicro/Orbiter/Orbiter.dsc  -t GCC5
  build -a RISCV64 --buildtarget ${BUILD_TARGET}  -p OvmfPkg/RiscVVirt/RiscVVirtQemu.dsc -t GCC5

  #rm uefi.bin 2>/dev/null | true
  #ln -s Build/Orbiter/${BUILD_TARGET}_GCC5/FV/ORBITER.fd uefi.bin

  truncate -s 32M Build/RiscVVirtQemu/${BUILD_TARGET}_GCC5/FV/RISCV_VIRT_CODE.fd
  truncate -s 32M Build/RiscVVirtQemu/${BUILD_TARGET}_GCC5/FV/RISCV_VIRT_VARS.fd


  unlink fw_dynamic.bin | echo true
  ln -s $OPENSBI_BIN fw_dynamic.bin

  #cp ${ROOT_DIR}/edk2.dts .
  #mkimage -f edk2.dts edk2.itb
  dlog "Compiling $EDK_DIR ... Done!"

}

gen_fit_image_synth()
{

  EDK_DIR=$1
  OPENSBI_BIN=$2
  EDK2_ENTRY_ADDR=$3
  OPENSBI_ENTRY_ADDR=$4
  CROSS_COMPILE_PREFIX=$5
  BUILD_TARGET=DEBUG


  cd $EDK_DIR
  export WORKSPACE=$EDK_DIR
  export GCC5_RISCV64_PREFIX=$CROSS_COMPILE_PREFIX
  export EDK_TOOLS_PATH=$WORKSPACE/BaseTools
  export PACKAGES_PATH=$WORKSPACE:$WORKSPACE/edk2-platforms

  generate_dts $EDK2_ENTRY_ADDR $OPENSBI_ENTRY_ADDR

  dlog "Compiling $EDK_DIR ..."
  source edksetup.sh BaseTools
  make -j`nproc` -C BaseTools clean
  make -j`nproc` -C BaseTools
  make -j`nproc` -C BaseTools/Source/C

  build -a RISCV64 -b ${BUILD_TARGET} -p edk2-platforms/Platform/VentanaMicro/VentanaSynth/VentanaSynth.dsc  -t GCC5

  rm uefi.bin 2>/dev/null | true
  #ln -s Build/Orbiter/${BUILD_TARGET}_GCC5/FV/ORBITER.fd uefi.bin
  ln -s Build/VentanaSynth/${BUILD_TARGET}_GCC5/FV/VENTANASYNTH.fd uefi.bin

  unlink fw_dynamic.bin | echo true
  #ln -s $OPENSBI_BIN fw_dynamic.bin
  ln -s /home/redpanda/git/ventana_openbmc_ws/src/fw_dynamic.bin fw_dynamic.bin

  #cp ${ROOT_DIR}/edk2.dts .
  mkimage -f edk2.dts edk2.itb
  dlog "Compiling $EDK_DIR ... Done!"

}

gen_edk2_sdcard_synth()
{
set -e
set -x
  EDK_DIR=$1
  WORKSPACE=$EDK_DIR/..
  BUILD_TARGET=DEBUG


# git clone --progress https://github.com/pengutronix/genimage.git
# cd genimage
# ./autogen.sh
# ./configure CFLAGS='-g -O0' --prefix=/usr
# make
# cd ..
#
# git clone --progress https://github.com/NodeOS/genfatfs.git
# cd genfatfs
# make
# cd ..
 rm -rf sdcard

 mkdir -p sdcard/bios_esp/FIRMWARE/ventana/synth-vx

 cp $EDK_DIR/edk2.itb sdcard/bios_esp/FIRMWARE/ventana/synth-vx/fw.itb

 dd if=/dev/zero of=./sdcard/bios_esp.img bs=1024 count=114688
 ./genfatfs/genfatfs -d ./sdcard/bios_esp -b 114688 ./sdcard/bios_esp.img

 printf "image bios_riscv64_ventana.img {\n\
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
}\n" > ./sdcard/bios_riscv64_ventana.cfg

 ./genimage/genimage --config ./sdcard/bios_riscv64_ventana.cfg --inputpath ./sdcard --outputpath ./sdcard





 ls sdcard/bios_riscv64_ventana.img

}
