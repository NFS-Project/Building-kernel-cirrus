#!/usr/bin/env bash

# Main Declaration
function env() {
export KERNEL_NAME=NFS-Kernel
KERNEL_ROOTDIR=$CIRRUS_WORKING_DIR/$DEVICE_CODENAME
DEVICE_DEFCONFIG=rosy-perf_defconfig
IMAGE=$CIRRUS_WORKING_DIR/$DEVICE_CODENAME/out/arch/arm64/boot/Image.gz-dtb
DATE=$(date +"%F-%S")
START=$(date +"%s")
export KBUILD_BUILD_USER=$BUILD_USER
export KBUILD_BUILD_HOST=$BUILD_HOST
}
# Checking environtment
# Warning !! Dont Change anything there without known reason.
function check() {
echo ================================================
echo "              _  __  ____  ____               "
echo "             / |/ / / __/ / __/               "
echo "      __    /    / / _/  _\ \    __           "
echo "     /_/   /_/|_/ /_/   /___/   /_/           "
echo "    ___  ___  ____     _________________      "
echo "   / _ \/ _ \/ __ \__ / / __/ ___/_  __/      "
echo "  / ___/ , _/ /_/ / // / _// /__  / /         "
echo " /_/  /_/|_|\____/\___/___/\___/ /_/          "
echo ================================================
echo BUILDER NAME = ${KBUILD_BUILD_USER}
echo BUILDER HOSTNAME = ${KBUILD_BUILD_HOST}
echo DEVICE_DEFCONFIG = ${DEVICE_DEFCONFIG}
echo KERNEL_ROOTDIR = ${KERNEL_ROOTDIR}
echo ================================================
}
# Peocces Compile
function compile() {
cd ${KERNEL_ROOTDIR}
make -j$(nproc) O=out ARCH=arm64 ${DEVICE_DEFCONFIG}
make -j$(nproc) ARCH=arm64 O=out \
    CROSS_COMPILE=aarch64-linux-gnu- \
    CROSS_COMPILE_ARM32=arm-linux-gnueabi-
   if ! [ -a "$IMAGE" ]; then
	echo BUILD KERNEL ERROR
   fi
	git clone --depth=1 $ANYKERNEL $CIRRUS_WORKING_DIR/AnyKernel
	cp $IMAGE $CIRRUS_WORKING_DIR/AnyKernel
}
# Push kernel
function push() {
    cd $CIRRUS_WORKING_DIR/AnyKernel
    zip -r9 $KERNEL_NAME-$DEVICE_CODENAME-${DATE}.zip *
    ZIP=$(echo *.zip)

    # Upload to WeTransfer
    # NOTE: the current Docker Image, "registry.gitlab.com/sushrut1101/docker:latest", includes the 'transfer' binary by Default
    # transfer wet $ZIP > link.txt || { echo "ERROR: Failed to Upload the Build!" && exit 1; }

    # Mirror to oshi.at
    curl -T $ZIP https://oshi.at/${FILENAME}/${TIMEOUT} > mirror.txt || { echo "WARNING: Failed to Mirror the Build!"; }

    # DL_LINK=$(cat link.txt | grep Download | cut -d\  -f3)
    MIRROR_LINK=$(cat mirror.txt | grep Download | cut -d\  -f1)
    echo Download=$MIRROR_LINK
}


env
check
compile
END=$(date +"%s")
DIFF=$(($END - $START))
push
