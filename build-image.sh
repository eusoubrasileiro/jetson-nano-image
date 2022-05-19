#! /bin/bash

export ROOT=$HOME # vagrant needs another folder with more permissions
export JETSON_ROOTFS_DIR=${ROOT}/rootfs
export JETSON_BUILD_DIR=${ROOT}/build
export VERBOSE=true
export JETSON_NANO_BOARD=jetson-nano-2gb

outdev=/dev/null # default to ignore
if [ $VERBOSE ]; then 
    outdev=/dev/stderr
fi

# Check if the user is not root
if [ "x$(whoami)" != "xroot" ]; then
	printf "\e[31mThis script requires root privilege\e[0m\n"
	exit 1
fi

source create-rootfs.sh
source write-image.sh

