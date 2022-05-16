#! /bin/bash

# script to run from a Ubuntu directly no VM, Vagrant or docker

set -e

export ROOT=$(pwd) # current folder of script execution
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

printf "\e[32mUnpacking image ... "

if [ ! -d "$JETSON_ROOTFS_DIR" ]; then
    mkdir -p $JETSON_ROOTFS_DIR
    tar -xvf /media/andre/Data/Downloads/Tegra_Linux_Sample-Root-Filesystem_R32.7.1_aarch64.tbz2 -C $JETSON_ROOTFS_DIR  
fi 
printf "[OK]\n"

BSP=https://developer.nvidia.com/embedded/l4t/r32_release_v7.1/t210/jetson-210_linux_r32.7.1_aarch64.tbz2

printf "\e[32mBuild the image ...\n"
# Download L4T if build dir is empty or inexistent
if [ ! -d "$JETSON_BUILD_DIR" ] || [ ! "$(ls -A $JETSON_BUILD_DIR)" ]; then
    # Create the build dir if it does not exists
    mkdir -p $JETSON_BUILD_DIR
    printf "\e[32mDownload L4T...       "
    if [ ! -f "bsp.tbz2" ]; then
        wget -o bsp.tbz2 -q $BSP &> $outdev 
    fi 
    tar -jxpf bsp.tbz2 -C $JETSON_BUILD_DIR
    #rm $JETSON_BUILD_DIR/Linux_for_Tegra/rootfs/README.txt
    printf "[OK]\n"
fi

printf "Extract L4T...        "
# Check if ROOTFS is not empty
if [ "$(ls -A $JETSON_ROOTFS_DIR)" ] && [ ! -f "$JETSON_BUILD_DIR/Linux_for_Tegra/rootfs/home/1" ]; then
    # recursive preserving permissions
    cp -rp $JETSON_ROOTFS_DIR/*  $JETSON_BUILD_DIR/Linux_for_Tegra/rootfs/ &> $outdev
    pushd $JETSON_BUILD_DIR/Linux_for_Tegra/ > /dev/null
    ./apply_binaries.sh &> $outdev
    popd > /dev/null    
    # mark binaries were applied
    touch $JETSON_BUILD_DIR/Linux_for_Tegra/rootfs/home/1 
fi
printf "[OK]\n"

# create user name and set ssh enabled
printf "Creating user...        "
pushd $JETSON_BUILD_DIR/Linux_for_Tegra/tools &> /dev/null
printf "Type the password"
read -s passwd
./l4t_create_default_user.sh -n jetson-nano -u andre -a --accept-license -p $passwd &> $outdev
popd > /dev/null
printf "[OK]\n"

source create-image.sh

# prerequisites for jetson-ffmpeg: deepstream and nvidia-jetpack (dependecy)
#sudo apt install --no-install-recommends -y nvidia-jetpack deepstream-6.0

# for 4.5.1 deepstream-6.0
# for 4.4 deepstream-5.0.1
# https://developer.nvidia.com/deepstream-51-510-1-arm64deb 


# My BOARD is A02 looking under the board MODEL: P3541 180-13542-DAFF-A02
# BUT device tree gives B01 after installing using defaults pythops
# by ls -l /proc/device-tree/chosen/plugin-manager/ids
# https://forums.developer.nvidia.com/t/how-to-determine-which-nano/122822/8

# deeepstream tutorial which packages install 
# https://docs.nvidia.com/metropolis/deepstream/dev-guide/text/DS_Quickstart.html#jetson-setup

# https://docs.nvidia.com/jetson/archives/l4t-archived/l4t-3231/index.html#page/Tegra%2520Linux%2520Driver%2520Package%2520Development%2520Guide%2Fflashing.html%23wwpID0E0PG0HA