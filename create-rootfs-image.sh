#! /bin/bash

export ROOT=$(pwd) # current folder of script execution
export JETSON_ROOTFS_DIR=${ROOT}/rootfs
export JETSON_BUILD_DIR=${ROOT}/build
export VERBOSE=true
export JETSON_NANO_BOARD=jetson-nano-2gb

outdev=/dev/null # default to ignore
if [ $VERBOSE ]; then 
    outdev=/dev/stderr
fi

mkdir -p $JETSON_ROOTFS_DIR 
source create-rootfs.sh
cd ansible 
sudo -E $(which ansible-playbook) jetson.yaml &> $outdev
cd .. 
source create-image.sh