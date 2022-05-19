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

printf "\e[32mBuild the image ...\n"

BSP=https://developer.nvidia.com/embedded/l4t/r32_release_v7.1/t210/jetson-210_linux_r32.7.1_aarch64.tbz2

printf "\e[32mBuild the image ...\n"
# Download L4T if build dir is empty or inexistent
if [ ! -d "$JETSON_BUILD_DIR" ] || [ ! "$(ls -A $JETSON_BUILD_DIR)" ]; then
    # Create the build dir if it does not exists
    mkdir -p $JETSON_BUILD_DIR
    printf "\e[32mDownload and Extracting L4T...       "
    if [ ! -f "bsp.tbz2" ]; then
        wget -O bsp.tbz2 $BSP &> $outdev 
    fi 
    tar xpf bsp.tbz2 -C $JETSON_BUILD_DIR
    #rm $JETSON_BUILD_DIR/Linux_for_Tegra/rootfs/README.txt
    printf "[OK]\n"
fi

printf "Extract L4T...        "
# Check if ROOTFS is not empty
if [ "$(ls -A $JETSON_ROOTFS_DIR)" ] && [ ! -f "$JETSON_BUILD_DIR/Linux_for_Tegra/rootfs/home/1" ]; then
    # recursive preserving permissions
    cp -rp $JETSON_ROOTFS_DIR/*  $JETSON_BUILD_DIR/Linux_for_Tegra/rootfs/ &> $outdev
    cd $JETSON_BUILD_DIR/Linux_for_Tegra/ > /dev/null
    ./apply_binaries.sh &> $outdev    
    # mark binaries were applied
    touch $JETSON_BUILD_DIR/Linux_for_Tegra/rootfs/home/1 
fi
printf "[OK]\n"

# create user name and set ssh enabled
printf "Creating user...        "
cd $JETSON_BUILD_DIR/Linux_for_Tegra/tools &> /dev/null
printf "Type the password"
read -s passwd
./l4t_create_default_user.sh -n jetson-nano -u andre -a --accept-license -p $passwd &> $outdev
printf "[OK]\n"

pushd $JETSON_BUILD_DIR/Linux_for_Tegra/tools 

# only tested working on jetson-nano-2gb A02 my device
./jetson-disk-image-creator.sh -o jetson.img -b jetson-nano-2gb-devkit -r 300
cp $JETSON_BUILD_DIR/Linux_for_Tegra/tools/jetson.img $HOME

# case "$JETSON_NANO_BOARD" in
#     jetson-nano-2gb)
#         printf "Create image for Jetson nano 2GB board... "
#         ./jetson-disk-image-creator.sh -o jetson.img -b jetson-nano-2gb-devkit > $outdev        
#         #cp $JETSON_BUILD_DIR/Linux_for_Tegra/tools/jetson.img $HOME > $outdev
#         printf "[OK]\n"
#         ;;

#     jetson-nano)
#         nano_board_revision=${JETSON_NANO_REVISION:=300}
#         printf "Creating image for Jetson nano board (%s revision)... " $nano_board_revision
#         ./jetson-disk-image-creator.sh -o jetson.img -b jetson-nano -r $nano_board_revision > $outdev        
#         #cp $JETSON_BUILD_DIR/Linux_for_Tegra/tools/jetson.img $HOME > $outdev
#         printf "[OK]\n"
#         ;;

#     *)
# 	printf "\e[31mUnknown Jetson nano board type\e[0m\n"
# 	exit 1
#         ;;
# esac

printf "\e[32mImage created successfully\n"
printf "Image location ./jetson.img\n"