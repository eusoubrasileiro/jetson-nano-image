#!/bin/bash

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

# Check for env variables
if [ ! $JETSON_ROOTFS_DIR ]; then
	printf "\e[31mYou need to set the env variable \$JETSON_ROOTFS_DIR\e[0m\n"
	exit 1
fi

# Install prerequisites packages
printf "\e[32mInstall the dependencies...     "
apt-get update > $outdev
apt-get install --no-install-recommends -y qemu-user-static binfmt-support coreutils parted wget gdisk e2fsprogs libxml2-utils  > $outdev
printf "[OK]\n"

##################################################
# based on samplefs/nv_build_samplefs.sh 32.7.1  #
##################################################

# Create rootfs directory
printf "Create rootfs directory and unpacking base ubuntu...      "
mkdir -p $JETSON_ROOTFS_DIR
chmod 755 $JETSON_ROOTFS_DIR

urlUBASE=http://cdimage.ubuntu.com/ubuntu-base/releases/18.04.4/release/ubuntu-base-18.04.5-base-arm64.tar.gz 
if [ ! -f "$HOME\ubuntu-base.tar.gz" ]; then
        wget -O $HOME\ubuntu-base.tar.gz $urlUBASE 
fi 
pushd $JETSON_ROOTFS_DIR
tar xpf $HOME\ubuntu-base.tar.gz --numeric-owner 
printf "[OK]\n"

cp /usr/bin/qemu-aarch64-static $JETSON_ROOTFS_DIR/usr/bin
chmod 755 $JETSON_ROOTFS_DIR/usr/bin/qemu-aarch64-static

mount /sys $JETSON_ROOTFS_DIR/sys -o bind
mount /proc $JETSON_ROOTFS_DIR/proc -o bind
mount /dev $JETSON_ROOTFS_DIR/dev -o bind
mount /dev/pts $JETSON_ROOTFS_DIR/dev/pts -o bind

cat <<EOF > $JETSON_ROOTFS_DIR/etc/resolv.conf
nameserver 1.1.1.1
EOF

LC_ALL=C chroot $JETSON_ROOTFS_DIR apt-get update
LC_ALL=C DEBIAN_FRONTEND=noninteractive sudo chroot $JETSON_ROOTFS_DIR apt-get install python3 -y

popd
pushd ansible 
$(which ansible-playbook) jetson.yaml &> $outdev
popd 

LC_ALL=C chroot $JETSON_ROOTFS_DIR sync
LC_ALL=C chroot $JETSON_ROOTFS_DIR apt-get clean
LC_ALL=C chroot $JETSON_ROOTFS_DIR sync

umount $JETSON_ROOTFS_DIR/sys
umount $JETSON_ROOTFS_DIR/proc
umount $JETSON_ROOTFS_DIR/dev/pts
umount $JETSON_ROOTFS_DIR/dev

rm -rf $JETSON_ROOTFS_DIR/var/lib/apt/lists/*
rm -rf $JETSON_ROOTFS_DIR/dev/*
rm -rf $JETSON_ROOTFS_DIR/var/log/*
rm -rf $JETSON_ROOTFS_DIR/var/cache/apt/archives/*.deb
rm -rf $JETSON_ROOTFS_DIR/var/tmp/*
rm -rf $JETSON_ROOTFS_DIR/tmp/*

# needed by BSP so we dont remove
# rm $JETSON_ROOTFS_DIR/usr/bin/qemu-aarch64-static

printf "The rootfs has been created successfully.\n"









