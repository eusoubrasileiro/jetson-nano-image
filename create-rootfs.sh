#! /bin/bash

#
# Author: Badr BADRI © pythops
#

set -e

ARCH=arm64
RELEASE=bionic

outdev=/dev/null # default to ignore
if [ $VERBOSE ]; then 
       outdev=/dev/stderr
fi

# Check if the user is not root
if [ "x$(whoami)" != "xroot" ]; then
	printf "\e[31mThis script requires root privilege\e[0m\n"
	exit 1
fi


echo $JETSON_ROOTFS_DIR 

# Check for env variables
if [ ! $JETSON_ROOTFS_DIR ]; then
	printf "\e[31mYou need to set the env variable \$JETSON_ROOTFS_DIR\e[0m\n"
	exit 1
fi

# Install prerequisites packages
printf "\e[32mInstall the dependencies...     "
apt-get update > $outdev
apt-get install --no-install-recommends -y qemu-user-static debootstrap binfmt-support coreutils parted wget gdisk e2fsprogs libxml2-utils  > $outdev
printf "[OK]\n"

# Create rootfs directory
printf "Create rootfs directory...      "
mkdir -p $JETSON_ROOTFS_DIR
printf "[OK]\n"

# Run debootstrap first stage
printf "Run debootstrap first stage...  "
debootstrap \
        --arch=$ARCH \
        --foreign \
        --variant=minbase \
        --include=python3,python3-apt \
        $RELEASE \
	$JETSON_ROOTFS_DIR &> $outdev
printf "[OK]\n"

cat <<EOF > $JETSON_ROOTFS_DIR/etc/resolv.conf
nameserver 1.1.1.1
EOF

cp /usr/bin/qemu-aarch64-static $JETSON_ROOTFS_DIR/usr/bin

# Run debootstrap second stage
printf "Run debootstrap second stage... "
chroot $JETSON_ROOTFS_DIR /bin/bash -c "/debootstrap/debootstrap --second-stage" &> $outdev
printf "[OK]\n"

printf "The rootfs has been created successfully.\n"
