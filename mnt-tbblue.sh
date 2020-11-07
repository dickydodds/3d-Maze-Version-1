#sudo mount -o loop,offset=127488 ../sdcard/cspect-next-2gb.img ~/tbblue -t vfat

udisksctl loop-setup --file ../sdcard/cspect-next-2gb.img
