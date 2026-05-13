#!/bin/bash

LOG_FILE=vt_ws_logs.txt
exec 5<&1
exec 6<&2
rm -rf $LOG_FILE
exec 1> $LOG_FILE 2>&1
#set -x

REL_FILE='ventana-sw-0.15.1-rc1.tar.xz'
#REL_FILE=$1
REL_DIR=""

UB_FILE='ubuntu-22.10-ventana-disk.img'

URI='git@gitlab.dc1.ventanamicro.com:ventana/swdev/dev/'
#URI='https://github.com/ventanamicro/'
BRANCH=dev-upstream
UPS_BRANCH=dev-upstream
DEV_BRANCH=dev-staging
QEMU_MACHINE=virt
#QEMU_MACHINE=ventana-thunderhill
#QEMU_BRANCH=slingappa-openbmc
QEMU_BRANCH=slingappa-openbmc
OPENSBI_BRANCH=$DEV_BRANCH
ZSTAGE_BRANCH=$DEV_BRANCH
LINUX_BRANCH=$DEV_BRANCH
UBOOT_BRANCH=$DEV_BRANCH
EDK2_BRANCH=$DEV_BRANCH
EDK2_PLAT_BRANCH=$DEV_BRANCH

ROOT_DIR=`pwd`
SRC_DIR=`pwd`/src
#CROSS_COMPILE_PREFIX='/opt/riscv/bin/riscv64-unknown-linux-gnu-'
export PATH=/home/redpanda/git/ventana_openbmc_ws/ventana-cross-toolchain-2025.08.18/bin:${PATH}
export ARCH=riscv
export CROSS_COMPILE_PREFIX='riscv64-unknown-linux-gnu-'
export CROSS_COMPILE='riscv64-unknown-linux-gnu-'

#flags
RM_OLD_DIRS=0
#rm -rf opensbi edk2 Build qemu linux startup.nsh efi.img 1m_log.txt
UPDATE_OLD_REPOS=0


mkdir $SRC_DIR | true

dlog()
{
  echo `date "+%D %T"` : $1  >&5
}

clone_if_not_present()
{
  COMP_DIR=$1
  COMP_BRANCH=$2
  COMP_URI=$3
  RECURSE=$4

  if [ ! -d $COMP_DIR ]; then
    dlog "Fetching $COMP_DIR ..."
    if [ -z "$COMP_URI" ]; then
      git clone --progress $RECURSE -b $COMP_BRANCH ${URI}${COMP_DIR}.git | echo true
    else
      git clone --progress $RECURSE -b $COMP_BRANCH ${COMP_URI} | echo true
    fi
    dlog "Fetching $COMP_DIR ... Done!"
  else
    if [[ "$UPDATE_OLD_REPOS" == 1 ]]; then
      dlog "Updating $COMP_DIR ..."
      cd  $COMP_DIR
      git checkout $COMP_BRANCH
      #git pull
      dlog "Updating $COMP_DIR ... Done!"
    fi
  fi
}

process_opensbi()
{
  SBI_DIR=opensbi
  cd $SRC_DIR
  if [[ "$RM_OLD_DIRS" == 1 ]]; then
    rm -rvf $SBI_DIR
  fi

  clone_if_not_present $SBI_DIR $OPENSBI_BRANCH

  dlog "Compiling OpenSBI ..."
  cd $SBI_DIR
  make CROSS_COMPILE=$CROSS_COMPILE_PREFIX   -j 32 PLATFORM=generic FW_OPTIONS=0x0
  dlog "Compiling OpenSBI ... Done!"

  cd $SRC_DIR

}

process_qemu()
{
  QEMU_DIR=qemu
  cd $SRC_DIR
  if [[ "$RM_OLD_DIRS" == 1 ]]; then
    rm -rf $QEMU_DIR
  fi

  set -x
  clone_if_not_present $QEMU_DIR slingappa-openbmc git@gitlab.dc1.ventanamicro.com:ventana/swdev/dev/qemu.git

  #rm ${SRC_DIR}/qemu/build/qemu-system-riscv64
  if [[ ! -f ${SRC_DIR}/qemu/build/qemu-system-arm ]]
  then
    dlog "Compiling QEMU ..."
    cd $QEMU_DIR
    rm -rf build && mkdir build && cd build
    #rm -rf build
    ../configure --target-list=arm-softmmu
    make -j$(nproc)
    dlog "Compiling QEMU ... Done!"

    cd $SRC_DIR
  fi

}

process_openbmc()
{
  OBMC_DIR=openbmc
  cd $SRC_DIR
  if [[ "$RM_OLD_DIRS" == 1 ]]; then
    rm -rf $OBMC_DIR
  fi

  #set -x
  clone_if_not_present $OBMC_DIR slingappa-vt2ast2600 git@gitlab.dc1.ventanamicro.com:ventana/swdev/dev/openbmc.git

  #rm ${SRC_DIR}/qemu/build/qemu-system-riscv64
  #if [[ ! -f ${SRC_DIR}/openbmc/build/evb-vt2ast2600 ]]
  #then
    dlog "Compiling OpenBMC ..."
    cd $OBMC_DIR
    #rm -rf build
    . setup evb-vt2ast2600
    cp $SRC_DIR/../etc/local.conf conf/
    export LC_ALL=C
    bitbake obmc-phosphor-image
    dlog "Compiling OpenBMC ... Done!"

    cd $SRC_DIR
  #fi

}


process_linux()
{
  LINUX_DIR=linux
  cd $SRC_DIR
  if [[ "$RM_OLD_DIRS" == 1 ]]; then
    rm -rvf $LINUX_DIR
  fi

  clone_if_not_present $LINUX_DIR $LINUX_BRANCH

  dlog "Compiling Linux ..."
  cd $LINUX_DIR
  #make ARCH=riscv CROSS_COMPILE=$CROSS_COMPILE_PREFIX -j$(nproc) ventana_sw_defconfig
  make ARCH=riscv CROSS_COMPILE=$CROSS_COMPILE_PREFIX -j$(nproc) defconfig
  make ARCH=riscv CROSS_COMPILE=$CROSS_COMPILE_PREFIX -j$(nproc)
  dlog "Compiling Linux ... Done!"

}

process_buildroot()
{
  BR_DIR=buildroot
  BR_URI='git@github.com:buildroot/buildroot.git'
  cd $SRC_DIR

  if [[ "$RM_OLD_DIRS" == 1 ]]; then
    rm -rf  $BR_DIR
  fi

  if [ -f $BR_DIR/output/images/rootfs.cpio ]; then
    # return if rootfs exisits
    echo output/images/rootfs.ext2 exists, returning.
    return
  fi

  clone_if_not_present $BR_DIR master $BR_URI

  dlog "Compiling $BR_DIR ..."
  cd $BR_DIR
  make qemu_riscv64_virt_defconfig
  echo BR2_PACKAGE_CPIO=y >> .config
  echo BR2_TARGET_ROOTFS_CPIO=y >> .config
  echo BR2_TARGET_ROOTFS_CPIO_FULL=y  >> .config
  echo BR2_TARGET_ROOTFS_CPIO_NONE=y >> .config
  echo BR2_TARGET_ROOTFS_INITRAMFS=y >> .config
  echo BR2_LINUX_KERNEL_INSTALL_TARGET=y >> .config
  echo BR2_PACKAGE_HAVEGED=y >> .config
  #echo y | make -j$(nproc) clean
  echo y | make -j$(nproc) rootfs-cpio
  echo y | make -j$(nproc) rootfs-ext2
  cd -
  dlog "Compiling $BR_DIR ... Done!"

}

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
                        os = "U-Boot";
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
                        entry = <'${OPENSBI_ENTRY_ADDR=}'>;
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

  #build -a RISCV64 -b ${BUILD_TARGET} -p edk2-platforms/Platform/VentanaMicro/thunderhill/thunderhill.dsc  -t GCC5
  build -a RISCV64 --buildtarget ${BUILD_TARGET} -p OvmfPkg/RiscVVirt/RiscVVirtQemu.dsc -t GCC5

  rm uefi.bin 2>/dev/null | true
  ln -s Build/thunderhill/${BUILD_TARGET}_GCC5/FV/thunderhill.fd uefi.bin

  unlink fw_dynamic.bin | echo true
  ln -s $OPENSBI_BIN fw_dynamic.bin

  #cp ${ROOT_DIR}/edk2.dts .
  #mkimage -f edk2.dts edk2.itb
  dlog "Compiling $EDK_DIR ... Done!"

}


compile_edk2()
{
  OPENSBI_BIN=${SRC_DIR}/opensbi/build/platform/generic/firmware/fw_dynamic.bin
  EDK_DIR=$SRC_DIR/edk2
  EDK2_ENTRY_ADDR=0xc0200000
  OPENSBI_ENTRY_ADDR=0xc7000000

  source ${ROOT_DIR}/compile_edk2.sh
  #gen_fit_image $EDK_DIR $OPENSBI_BIN $EDK2_ENTRY_ADDR $OPENSBI_ENTRY_ADDR $CROSS_COMPILE_PREFIX
  #gen_fit_image_virt $EDK_DIR $OPENSBI_BIN $EDK2_ENTRY_ADDR $OPENSBI_ENTRY_ADDR $CROSS_COMPILE_PREFIX
  gen_fit_image_synth $EDK_DIR $OPENSBI_BIN $EDK2_ENTRY_ADDR $OPENSBI_ENTRY_ADDR $CROSS_COMPILE_PREFIX
  gen_edk2_sdcard_synth $EDK_DIR

}

build_edk2_efi()
{

  IMG=nvme.img
  dlog "Building disk image ..."
  cd $ROOT_DIR
  #echo fs0:\Image root=/dev/vdb console=ttyS0 rootwait earlycon=uart8250,mmio,0x10000000 > startup.nsh
  echo "fs0:\Image root=/dev/nvme0n1p3 rootfstype=ext4 rootwait  console=ttyPS0 earlycon=sbi" > startup.nsh
  sudo rm -rvf ${IMG} | echo true
  fallocate -l 4G ${IMG}
  sgdisk -n 1:512:65535 -t 1:EF00 ${IMG}
  sgdisk -n 2:65536:4194303 -t 2:8300 ${IMG}
  sgdisk -n 3:4194304: -t 3:8300 ${IMG}
  sudo losetup -fP ${IMG}
  loopdev=`losetup -j ${IMG} | awk -F: '{print $1}'`
  efi_part1="$loopdev"p1
  efi_part2="$loopdev"p2
  efi_part3="$loopdev"p3
  mkdir -p /tmp/p1
  mkdir -p /tmp/p2
  mkdir -p /tmp/p3

  sudo mkfs.vfat $efi_part1
  sudo mkfs.ext4 $efi_part2
  sudo mkfs.ext4 $efi_part3

  #sudo losetup -D $loopdev

  sudo mount $efi_part1 /tmp/p1/
  sudo mount $efi_part2 /tmp/p2/
  sudo mount $efi_part3 /tmp/p3/
  sudo cp startup.nsh /tmp/p1/
  sudo cp src/linux/arch/riscv/boot/Image /tmp/p1/
  sudo cp src/edk2/edk2.itb /tmp/p2/ventana.itb
  # copy whole partition
  #sudo dd if=src/buildroot/output/images/rootfs.ext2 of=$efi_part3

  # copy partition data
  mkdir /tmp/rootfs | echo true
  sudo mount src/buildroot/output/images/rootfs.ext2  /tmp/rootfs | echo true
  sudo cp -rvf /tmp/rootfs/* /tmp/p3/
  #ls -R /tmp/p3/

  sudo umount $efi_part1
  sudo umount $efi_part2
  sudo umount $efi_part3

  sudo losetup -D $loopdev

  dlog "Building disk image ... Done!"
}

process_edk2()
{
  set -x
  set -e

  EDK_DIR='tianocore/edk2'
  cd $SRC_DIR
  if [[ "$RM_OLD_DIRS" == 1 ]]; then
    rm -rvf $EDK_DIR
  fi

  clone_if_not_present $EDK_DIR $EDK2_BRANCH git@gitlab.dc1.ventanamicro.com:ventana/swdev/dev/tianocore/edk2.git --recurse-submodule
  cd edk2
  clone_if_not_present edk2-platforms $EDK2_PLAT_BRANCH git@gitlab.dc1.ventanamicro.com:ventana/swdev/dev/tianocore/edk2-platforms.git --recurse-submodule
  git submodule update --init
  cd -
  compile_edk2
  #build_edk2_efi

}

process_uboot()
{
  set -x
  set -e

  UB_DIR='u-boot'
  cd $SRC_DIR
  if [[ "$RM_OLD_DIRS" == 1 ]]; then
    rm -rvf $UB_DIR
  fi

  clone_if_not_present $UB_DIR $UBOOT_BRANCH

  dlog "Compiling $UB_DIR ... "
  cd $UB_DIR
  pwd
  make -j$(nproc) distclean
#  make ARCH=riscv CROSS_COMPILE=$CROSS_COMPILE_PREFIX  ventana-vt1-thunderhill_defconfig
#  make ARCH=riscv CROSS_COMPILE=$CROSS_COMPILE_PREFIX -j$(nproc) OPENSBI=${SRC_DIR}/opensbi/build/platform/generic/firmware/fw_dynamic.bin
  make ARCH=riscv CROSS_COMPILE=$CROSS_COMPILE_PREFIX  ventana-vtx-synth_defconfig
  make ARCH=riscv CROSS_COMPILE=$CROSS_COMPILE_PREFIX -j$(nproc) OPENSBI=${SRC_DIR}/opensbi/build/platform/generic/firmware/fw_dynamic.bin
  dlog "Compiling $UB_DIR ... Done!"

  cd $SRC_DIR

}


process_zstage()
{
  set -x
  set -e

  ZS_DIR='zstage'
  cd $SRC_DIR
  if [[ "$RM_OLD_DIRS" == 1 ]]; then
    rm -rvf $ZS_DIR
  fi

  clone_if_not_present $ZS_DIR $ZSTAGE_BRANCH

  dlog "Compiling $ZS_DIR ... "
  cd $ZS_DIR
  pwd
  #make ARCH=riscv PLATFORM=vt1/thunderhill ZSTAGE_PAYLOAD_PATH=${SRC_DIR}/u-boot/spl/u-boot-spl.bin  CROSS_COMPILE=$CROSS_COMPILE_PREFIX -j$(nproc)
  #echo `pwd`/platform/vt1/qemu/firmware/zstage.bin
  make ARCH=riscv PLATFORM=ventana/vt2/synth ZSTAGE_PAYLOAD_PATH=${SRC_DIR}/u-boot/spl/u-boot-spl.bin  CROSS_COMPILE=$CROSS_COMPILE_PREFIX -j$(nproc)
  echo `pwd`/platform/ventana/vt2/synth/firmware/zstage.bin

  dlog "Compiling $ZS_DIR ... Done!"

  cd $SRC_DIR

}



build_images()
{
#  process_buildroot
#  process_opensbi
#  process_uboot
#  process_zstage
#  process_linux
  process_edk2
#  process_qemu
exit 0
}

run_qemu_with_initrd_acpi_uefi()
{
  dlog " Launching qemu ..."

  # restore terminals
  exec 1<&5
  exec 2<&6
  set -x
     #-device virtio-gpu-pci -full-screen \
     #-device usb-kbd \
     #-device qemu-xhci \
     #-device virtio-rng-pci \
     #-serial mon:stdio \
  QEMU=${SRC_DIR}/qemu/build/qemu-system-riscv64
  ROOTFS=${SRC_DIR}/'buildroot/output/images/rootfs.cpio'
  OPENSBI=${SRC_DIR}/'opensbi/build/platform/generic/firmware/fw_dynamic.elf'
  BLK_IMG=${SRC_DIR}/../'nvme.img'
  EDK2_BINS_PATH=${SRC_DIR}/'edk2/Build/RiscVVirtQemu/RELEASE_GCC5/FV/'

#     -m 4096 -smp 4 \

#     -m 2G,slots=2,maxmem=4G \
#     -object memory-backend-ram,size=1G,id=m0 \
#     -object memory-backend-ram,size=1G,id=m1 \
#     -numa node,nodeid=0,memdev=m0 \
#     -numa node,nodeid=1,memdev=m1 \
#     -smp 2,sockets=2,maxcpus=2  \

  ${QEMU} -d guest_errors -D 1m_log.txt \
    -M virt,pflash0=pflash0,pflash1=pflash1,aia=aplic-imsic,acpi=on,hmat=on  \
     -m 4096 -smp 4 \
     -blockdev node-name=pflash0,driver=file,read-only=on,filename=${EDK2_BINS_PATH}/RISCV_VIRT_CODE.fd \
     -blockdev node-name=pflash1,driver=file,filename=${EDK2_BINS_PATH}/RISCV_VIRT_VARS.fd \
     -bios ${OPENSBI} \
     -initrd ${ROOTFS} \
     -kernel  ${SRC_DIR}/./linux/arch/riscv/boot/Image \
     -append "root=/dev/ram rw  console=ttyS0 earlycon=uart8250,mmio,0x10000000" \
     -nographic \
     -device virtio-net-device,netdev=usernet -netdev user,id=usernet,hostfwd=tcp::9990-:22
}

run_qemu_with_initrd_acpi_uefi_multi_socket()
{
  dlog " Launching qemu ..."

  # restore terminals
  exec 1<&5
  exec 2<&6
  set -x
     #-device virtio-gpu-pci -full-screen \
     #-device usb-kbd \
     #-device qemu-xhci \
     #-device virtio-rng-pci \
     #-serial mon:stdio \
  QEMU=${SRC_DIR}/qemu/build/qemu-system-riscv64
  ROOTFS=${SRC_DIR}/'buildroot/output/images/rootfs.cpio'
  OPENSBI=${SRC_DIR}/'opensbi/build/platform/generic/firmware/fw_dynamic.elf'
  BLK_IMG=${SRC_DIR}/../'nvme.img'
  EDK2_BINS_PATH=${SRC_DIR}/'edk2/Build/RiscVVirtQemu/RELEASE_GCC5/FV/'

#     -m 4096 -smp 4 \

#     -m 2G,slots=2,maxmem=4G \
#     -object memory-backend-ram,size=1G,id=m0 \
#     -object memory-backend-ram,size=1G,id=m1 \
#     -numa node,nodeid=0,memdev=m0 \
#     -numa node,nodeid=1,memdev=m1 \
#     -smp 2,sockets=2,maxcpus=2  \
     #-device virtio-net-pci,netdev=usernet -netdev user,id=usernet,hostfwd=tcp::9990-:22

  ${QEMU}  \
    -M virt,pflash0=pflash0,pflash1=pflash1,aia=aplic-imsic,acpi=on,hmat=on,rpmi=on  \
     -m 2G,slots=2,maxmem=4G \
     -object memory-backend-ram,size=1G,id=m0 \
     -object memory-backend-ram,size=1G,id=m1 \
     -numa node,nodeid=0,memdev=m0 \
     -numa node,nodeid=1,memdev=m1 \
     -smp 2,sockets=2,maxcpus=2  \
     -d guest_errors -D 1m_log.txt  \
     -blockdev node-name=pflash0,driver=file,read-only=on,filename=${EDK2_BINS_PATH}/RISCV_VIRT_CODE.fd \
     -blockdev node-name=pflash1,driver=file,filename=${EDK2_BINS_PATH}/RISCV_VIRT_VARS.fd \
     -bios ${OPENSBI} \
     -initrd ${ROOTFS} \
     -kernel  ${SRC_DIR}/./linux/arch/riscv/boot/Image \
     -append "root=/dev/ram rw  console=ttyS0 earlycon=uart8250,mmio,0x10000000" \
     -nographic \
     -device virtio-net-pci,netdev=usernet -netdev user,id=usernet,hostfwd=tcp::9990-:22

}


build_toolchain()
{
  #nothing for now
  echo ""
}

install_packages()
{
  sudo apt install -y slirp libslirp-dev
  sudo apt install -y libvde-dev libvdeplug-dev libvte-2.91-dev libxen-dev liblzo2-dev ninja-build iasl libglib2.0-dev libfdt-dev libpixman-1-dev zlib1g-dev
}

run_ubuntu_qemu()
{
  # restore terminals
  exec 1<&5
  exec 2<&6

   set -x
   BLK_IMG=${ROOT_DIR}/${UB_FILE}
   #BLK_IMG=${ROOT_DIR}/ubuntu-22.10-ventana-disk.img

   ${SRC_DIR}/qemu/build/qemu-system-riscv64  -nographic  -M ventana-thunderhill -smp 16 -m 2G \
     -bios ${SRC_DIR}/zstage/build/platform/vt1/thunderhill/firmware/zstage.bin \
     -drive file=${BLK_IMG},id=hd0,format=raw -device nvme,serial=ddaaddaa,drive=hd0
}

run_qemu_with_edk2_loader()
{

  set -x
  BLK_IMG=${SRC_DIR}/../ubuntu-22.10-ventana-disk.mod.img
  #BLK_IMG='rootfs.wic'

  ${SRC_DIR}/qemu/build/qemu-system-riscv64  -nographic  -M ventana-thunderhill -smp 8 -m 2G \
    -bios ${SRC_DIR}/zstage/build/platform/vt1/thunderhill/firmware/zstage.bin \
    -device loader,file=${SRC_DIR}/edk2/edk2.itb,addr=0xc8000000 \
    -drive file=${BLK_IMG},id=hd0,format=raw -device nvme,serial=ddaaddaa,drive=hd0
}

run_thunderhill_qemu_with_built_edk2()
{

  # restore terminals
  exec 1<&5
  exec 2<&6


  #-device loader,file=${SRC_DIR}/edk2/edk2.itb,addr=0xc8000000 \
  set -x
  BLK_IMG=${SRC_DIR}/../'nvme.img'
  ${SRC_DIR}/qemu/build/qemu-system-riscv64 \
    -nographic -M ventana-thunderhill -smp 16 -m 2G -d guest_errors  -D 1m_log.txt \
    -bios ${SRC_DIR}/zstage/build/platform/vt1/thunderhill/firmware/zstage.bin \
    -object rng-random,filename=/dev/urandom,id=rng0  \
    -drive file=${BLK_IMG},id=hd0,format=raw -device nvme,serial=ddaaddaa,drive=hd0
}

prepare_thunderhill_rel_file()
{
  filename="${REL_FILE%.*}"
  REL_DIR="${filename%.*}"
  echo $REL_DIR
  export WORK_DIR=$ROOT_DIR

  cd $WORK_DIR

  if [ -d $REL_DIR ]
  then
    echo $REL_DIR exists
    if [[ "$RM_OLD_DIRS" == 1 ]]
    then
      rm -rf  $REL_DIR
      mkdir  $REL_DIR
      cd  $REL_DIR
      tar -xf ../$REL_FILE
    fi
  else
      mkdir  $REL_DIR
      cd  $REL_DIR
      tar -xf ../$REL_FILE
      cd $WORK_DIR/ventana-sw/platform/
      tar -xf ubuntu*.qcow2.tar.xz
      cd -
  fi

  unlink $WORK_DIR/ventana-sw | true

  ln -s $WORK_DIR/$REL_DIR $WORK_DIR/ventana-sw


}

build_toolchain()
{
  #nothing for now
  echo ""
}

install_packages()
{
  sudo apt install -y slirp libslirp-dev
  sudo apt install -y libvde-dev libvdeplug-dev libvte-2.91-dev libxen-dev liblzo2-dev ninja-build iasl libglib2.0-dev libfdt-dev libpixman-1-dev zlib1g-dev
}

run_thunderhill_qemu_with_AppImage()
{
  ## restore terminals
  #exec 1<&5
  #exec 2<&6
  #-nographic \

  export WORK_DIR=$ROOT_DIR
  echo  $WORK_DIR/ventana-sw/QEMU-x86_64-Ubuntu-20.04.AppImage \
    -M ventana-thunderhill-v1 -smp 2 -m 8G \
    -qmp unix:/tmp/qmp-socket,server,nowait -monitor stdio \
    -bios $WORK_DIR/ventana-sw/platform/ventana-thunderhill-v1/zstage/zstage.bin \
    -nic user,hostfwd=tcp::9991-:22 -drive file=$WORK_DIR/ventana-sw/platform/bios_edk2_riscv64_ventana.img,format=raw,if=sd \
    -drive file=$WORK_DIR/ventana-sw/platform/ventana-thunderhill-v1/ubuntu-24.04-preinstalled-server-riscv64+thunderhill-v1.qcow2,id=hd0,format=qcow2 \
    -device  nvme,serial=ddaaddaa,drive=hd0,bus=pci.1

}



run_thunderhill_server_with_release_bins(){
  echo $(run_thunderhill_qemu_with_AppImage)
}

run_tcp_server() {
  export WORK_DIR=$ROOT_DIR
  echo "$WORK_DIR/src/qemu/build/contrib/remote-i2c-server/remote-i2c-server"
}
run_ventana_bmc() {
  # ~/git/openbmc_ws/qemu/build/contrib/remote-i2c-server/remote-i2c-server
  # write data: 0x8 @ addr: 0x9
  # i2cset -y 0 0x62 9 8 i
  # read data: 0x8 back from addr: 0x9
  # i2cget -y 0 0x62 9 i 1

  #  cp -rf /home/redpanda/git/ventana_openbmc_ws/src/openbmc/build/evb-vt2ast2600/downloads/git2/github.com.openbmc.linux
  export WORK_DIR=$ROOT_DIR
  # qemu machine arch
  MACH="ventana-bmc"

  # OBMC machine arch
  #OBMC_MACH="evb-vt2ast2600"
  OBMC_MACH="vttunga"

  IMG=$WORK_DIR/src/openbmc/build/${OBMC_MACH}/tmp/deploy/images/${OBMC_MACH}/obmc-phosphor-image-${OBMC_MACH}.static.mtd

  #HAS_INSIGHT_I2C=""
  HAS_INSIGHT_I2C="
  -device remote-i2c,bus=aspeed.i2c.bus.1,id=remote-i2c-test,address=0x62,chardev=i2c-chardev \
    -chardev socket,id=i2c-chardev,host=localhost,port=54188,reconnect=1 "
      HAS_IPMI_BCM=""
      #HAS_IPMI_BCM="
      #           -device ipmi-bmc-sim,id=bmc1 -device isa-ipmi-bt,bmc=bmc1,irq=5 "
      QEMU_BIN=$WORK_DIR/src/qemu/build/qemu-system-arm

      echo $QEMU_BIN  -m 512M -M $MACH -nographic \
        -drive file=${IMG},format=raw,if=mtd \
        $HAS_INSIGHT_I2C $HAS_BMC_SIM $HAS_IPMI_BCM\
        -net nic \
        -net user,hostfwd=:127.0.0.1:2222-:22,hostfwd=:127.0.0.1:2443-:443,hostname=qemu \
        --trace "i2c_event" \
        -d guest_errors -D 1m_log.txt


}

#dlog "Logfile: $LOG_FILE"
#build_images
#run_thunderhill_qemu_with_built_edk2
#run_thunderhill_server_with_release_bins

RUN_WITH_PREBUILT_BINS=0
RUN_WITH_BUILT_BINS=0
RUN_UBUNTU_WITH_BUILT_BINS=0

usage(){
  set +x
  # restore terminals
  exec 1<&5
  exec 2<&6

  echo "Usage: ./launch.sh"
  echo "      -p < Prebuilt archive>   : Run with prebuilt archive"
  echo "         ex: ./launch.sh -p ventana-sw-0.9.1_20230313.tar.gz "
  echo "      -b                       : fetch srources, build and run."
  echo "      -u < Ubuntu image >      : Run Ubuntu with prebuilt archive"
  echo "         ex: ./launch.sh -u ubuntu-22.10-ventana-disk.img "
  exit
}

dlog "Logfile: $LOG_FILE"

while getopts "bp:u:v" opt; do
  case $opt in
    p)
      dlog "Running with prebuilt archive $OPTARG"
      REL_FILE=$OPTARG
      RUN_WITH_PREBUILT_BINS=1
      ;;
    b)
      dlog "Building and Running qemu"
      dlog "Building and running ventana-virt machine"
      RUN_WITH_BUILT_BINS=1
      ;;
    u)
      dlog "Building qemu, zstage and Running qemu-Ubuntu with $OPTARG"
      RUN_UBUNTU_WITH_BUILT_BINS=1
      UB_FILE=$OPTARG
      ;;
    v)
      dlog "Building and running virt machine"
      RUN_VIRT_WITH_BUILT_BINS=1
      ;;
    *)
      dlog "invalid command !"
      usage
      ;;
  esac
done


if [[ "$RUN_WITH_PREBUILT_BINS" == 1 ]]; then

  # prepare , build stuff
  #process_qemu
  #process_openbmc
  #prepare_thunderhill_rel_file
set -x
  # start executing qemu machines
  tmux new-session -s "0" -d  # pane#0, qemu
  tmux split-window -h      # pane#1, hwmodel
  tmux split-window -v      # pane#2, puc_simulator
  tmux -2 attach-session -d

  tmux send-keys -t 0.0 " $(run_thunderhill_server_with_release_bins) "  C-m
  tmux send-keys -t 0.1 " $(run_tcp_server) "  C-m
  tmux send-keys -t 0.2 " $(run_ventana_bmc) "  C-m

elif [[ "$RUN_WITH_BUILT_BINS" == 1 ]]; then
  build_images
  run_thunderhill_qemu_with_built_edk2
elif [[ "$RUN_UBUNTU_WITH_BUILT_BINS" == 1 ]]; then
  process_qemu
  process_opensbi
  process_uboot
  process_zstage
  run_ubuntu_qemu
elif [[ "$RUN_VIRT_WITH_BUILT_BINS" == 1 ]]; then
  process_buildroot
  process_linux
  process_opensbi
  process_edk2
  process_qemu
  run_qemu_with_initrd_acpi_uefi
  #run_qemu_with_initrd_acpi_uefi_multi_socket
else
  usage
fi


