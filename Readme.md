<div align="center">

[![Status](https://img.shields.io/badge/status-active-success.svg)]()

</div>

## Instructions here:

https://pythops.com/post/create-your-own-image-for-jetson-nano-board.html

## Spec:

**Ubuntu release**: 20.04

**BSP**: 32.7.3

## Supported boards:

- [Jetson nano](https://developer.nvidia.com/embedded/jetson-nano-developer-kit)
- [Jetson nano 2GB](https://developer.nvidia.com/embedded/jetson-nano-2gb-developer-kit)

## Looking for professional support ?

If you need more advanced configuration or a custom setup, you can contact me on this address support@pythops.com

## License

Copyright Badr BADRI @pythops

2019-2022 MIT

2023-Present AGPLv3


# that is for my jetson nano by Andre
just build-jetson-image jetson-nano 300
# revision A02 is the same as -r 300 
# https://forums.developer.nvidia.com/t/l4t-32-7-1-jetson-disk-image-creator-sh-no-support-to-jetson-nano-2g-revision-a02/214497
# but BSP jetson-disk-image-creator.sh script says A02 is -r 200 what makes a lot of sense
# working but motion is showing up all sorts of segfaults
just build-jetson-image jetson-nano 300
# partition was not expanded at first boot let's see now if it does that, seams it did work!

/home/andre directory was owened by root not by andre... weird.. had to chown it... 
/tmp was also owned by root no one could write to it    