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
# My BOARD is A02 looking under the board MODEL: P3541 180-13542-DAFF-A02

# apt remove thunderbird libreoffice-* -y
# apt purge cuda-repo-l4t-*local* libvisionworks-*repo -y
# rm /etc/apt/sources.list.d/cuda*local* /etc/apt/sources.list.d/visionworks*repo*
# rm -rf /usr/src/linux-headers-*
# apt-get purge gnome-shell ubuntu-wallpapers-bionic light-themes chromium-browser* libvisionworks libvisionworks-sfm-dev -y
# apt-get autoremove -y
# apt clean -y

