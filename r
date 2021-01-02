#call the 'm.bat' batchfile - called simply 'm' here - to compile the program
./m;

if [ $? -eq 1 ]
then
#    bin\hdfmonkey put n:\sdcard\cspect-next-2gb.img project.nex
    echo "Error other than 1"
else

#   mount the image
#    udisksctl loop-setup --file ../sdcard/cspect-next-2gb.img

#unmount the image
#    udisksctl unmount -b /dev/loop0p1

#now copy the files over to the sdcard
#/media/dicky/EMPTY-2GB/rd-3dmaze
    cp 3dmaze.bin /media/dicky/EMPTY-2GB/rd-3dmaze 
    cp project.map /media/dicky/EMPTY-2GB/rd-3dmaze 

#now run cspect with our code 
    wine bin\\CSpect.exe -r -esc -tv -brk -w3 -zxnext -nextrom -map=project.map -mmc=../sdcard/cspect-next-2gb.img
fi
