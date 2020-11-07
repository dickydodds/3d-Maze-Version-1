
#now copy the files over to the sdcard
    cp basictest.bin /media/dicky/EMPTY-2GB/ 
    cp project.map /media/dicky/EMPTY-2GB/ 

#now run cspect with our code 
    wine bin\\CSpect.exe -r -esc -tv -brk -w3 -zxnext -nextrom -map=project.map -mmc=../sdcard/cspect-next-2gb.img

