#! /bin/bash

#
# Author: Badr BADRI © pythops
#

set -e

outdev=/dev/null # default to ignore
if [ $VERBOSE ]; then 
       outdev=/dev/stderr
fi

# Check if the user is not root
if [ "x$(whoami)" != "xroot" ]; then
        printf "\e[31mThis script requires root privilege\e[0m\n"
        exit 1
fi

# Check for env variables
if [ ! $JETSON_ROOTFS_DIR ] || [ ! $JETSON_BUILD_DIR ]; then
	printf "\e[31mYou need to set the env variables \$JETSON_ROOTFS_DIR and \$JETSON_BUILD_DIR\e[0m\n"
	exit 1
fi

# Check if $JETSON_ROOTFS_DIR if not empty
if [ ! "$(ls -A $JETSON_ROOTFS_DIR)" ]; then
	printf "\e[31mNo rootfs found in $JETSON_ROOTFS_DIR\e[0m\n"
	exit 1
fi

# Check if board type is specified
if [ ! $JETSON_NANO_BOARD ]; then
	printf "\e[31mJetson nano board type must be specified\e[0m\n"
	exit 1
fi

pushd $JETSON_BUILD_DIR/Linux_for_Tegra/tools > /dev/null

case "$JETSON_NANO_BOARD" in
    jetson-nano-2gb)
        printf "Create image for Jetson nano 2GB board... "
        ./jetson-disk-image-creator.sh -o jetson.img -b jetson-nano-2gb-devkit &> $outdev
        popd > /dev/null
        cp $JETSON_BUILD_DIR/Linux_for_Tegra/tools/jetson.img . &> $outdev
        printf "[OK]\n"
        ;;

    jetson-nano)
        nano_board_revision=${JETSON_NANO_REVISION:=300}
        printf "Creating image for Jetson nano board (%s revision)... " $nano_board_revision
        ./jetson-disk-image-creator.sh -o jetson.img -b jetson-nano -r $nano_board_revision &> $outdev
        popd > /dev/null
        cp $JETSON_BUILD_DIR/Linux_for_Tegra/tools/jetson.img . &> $outdev
        printf "[OK]\n"
        ;;

    *)
	printf "\e[31mUnknown Jetson nano board type\e[0m\n"
	exit 1
        ;;
esac

printf "\e[32mImage created successfully\n"
printf "Image location ./jetson.img\n"
