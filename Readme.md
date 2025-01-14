## Jetson nano image for micro SD card flash

**BSP**: 32.7.1
**Ubuntu release**: 18.04

### Based on BSP/Linux_for_Tegra/tools/samplefs - 

 - Code based totally on scripts `nv_build_samplefs.sh` and `nvubuntu_samplefs.sh`
 - Ansible for installing additional packages (nvidia-requeried or personally needed).
 - Hostname, user and password using BSP tool `l4t_create_default_user.sh`
 - Final jetson-nano image slimmed to 1.7GB.

Main script is `build-image.sh` that should be run as root. 

The scripts **must** be run on a Ubuntu 18.04 (per nvidia instructions on BSP docs). Cannot be a docker containner or wsl2. Using vagrant and virtual-box or a clean Ubuntu 18.04.

Basic instructions for vagrant and flashing is giving by the [original tutorial](https://pythops.com/post/create-your-own-image-for-jetson-nano-board.html) script `flash-image.sh` 

## Only tested board (A02 revision) 
- [Jetson nano 2GB](https://developer.nvidia.com/embedded/jetson-nano-2gb-developer-kit)
According to [nvidia](https://forums.developer.nvidia.com/t/l4t-32-7-1-jetson-disk-image-creator-sh-no-support-to-jetson-nano-2g-revision-a02/214497) my revision A02 is the same as `-r 300` 


### Archived due my board being unstable and having issues rebooting/booting sometimes.
