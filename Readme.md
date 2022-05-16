## Forked from [pythops jetson-nano-image](https://github.com/pythops/jetson-nano-image):

### Using Nvidia pre-made Jetson-RootFilesystem

**Ubuntu release**: 18.04

**BSP**: 32.7.1_

- Created unified script `create-rootfs-image` 
- The Root Filesystem is the tarball provided by Nvidia 
- Build is done in native Focal Ubuntu without Vagrant, Docker or any VM. 
- Downside final disk size is huge 13GB after nvidia-jetpack and deepstream

TODO:
    try to use `Linux_for_Tegra/tools/samplefs/nv_build_samplefs.sh` to create a smaller rootfs
    and then use ansible to install necessary stuff on it  
    must be on a ubuntu 18 machine hence vagrant-virtual-box since chroot dont work on docker