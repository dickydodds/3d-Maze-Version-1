ZXSpectrum emulator by Mike Dailly (c) Copyright 1998-2020 All rights reserved

Command Line Options
======================================================================================
-zxnext            =  enable Next hardware registers
-nextrom           =  enable the Next ROM ("enNextZX.rom", "enNxtmmc.rom" and SD card image required)
-zx128             =  enable ZX Spectrum 128 mode
-s7                =  enable 7Mhz mode
-s14               =  enable 14Mhz mode
-s28               =  enable 28Mhz mode
-exit              =  to enable "EXIT" opcode of "DD 00"
-brk               =  to enable "BREAK" opcode of "DD 01"
-esc               =  to disable ESCAPE exit key (use exit opcode, close button or ALT+F4 to exit)
-cur               =  to map cursor keys to 6789 (l/r/d/u)
-8_3               =  set filenames back to 8.3 detection
-mmc=<dir\ or file>=  enable RST $08 usage, must provide path to "root" dir of emulated SD card (eg  "-mmc=.\" or "-mmc=c:\test\")
-sd2=<path\file>   =  Second SD card image file
-map=<path\file>   =  SNASM format map file for use in the debugger. format is: "<16bit address> <physical address> <type> <primary_label>[@<local>]"
-sound             =  disable sound
-joy               =  disable joysticks
-w<size>           =  set window size (1 to 4)
-r                 =  Remember window settings (in "cspect.dat" file, just delete the file to reset)
-16bit             =  Use the logical (16bit) addresses in the debugger only
-60                =  60Hz mode
-fullscreen        =  Startup in fullscreen mode
-vsync             =  Sync to display (for smoother scrolling when using "-60 -sound", but a little faster)
-com="COM?:BAUD"   =  Setup com port for UART. i.e. -com="COM5:115200". if not set, coms will be disabled.
-log_cpu           =  Log the CPU status out
-basickeys         =  Enable Next BASIC key interface (F10 toggles)
-tv                =  Disable the TV shader (or CTRL+F1)
-emu               =  Enable the emulator "bit" in the hardware registers
-major=<value>     =  Sets the value returned by NextReg $01
-minor=<value>     =  Sets the value returned by NextReg $0E
-debug             =  start up in the debugger
-remote            =  Enable the remote debugger mode, by disabling the debugger screen.




Manual SDCARD setup 
-------------------
NOTE: You can get a pre-made image here: http://www.zxspectrumnext.online/cspect/
unzip this file - and the contained ROM files into a folder (SD_CARD_PATH)

Making an image yourself
------------------------
Download the latest SD card from https://www.specnext.com/category/downloads/
Copy onto an SD card (preferably 2GB and less than 16GB as it's your Next HD for all your work)
Copy the files "enNextZX.rom" and "enNxtmmc.rom" from this SD Card into the root of the CSpect folder
Download Win32DiskImager ( https://sourceforge.net/projects/win32diskimager/ )
make an image of the SD card
start CSpect with the command line... 

Running
-------
"CSpect.exe -w3 -zxnext -nextrom -mmc=<SD_CARD_PATH>\sdcard.img"

I'd also recommend downloading HDFMonkey, which lets you copy files to/from the SD image. 
This tool can be used while CSpect is running, meaning you can just reset and remount the image
if you put new files on it - just like the real machine.
This tool also lets you rescue files saved onto the image by #CSpect - like a BASIC program
you may have written, or a hiscore file from a game etc.
I found a copy of this tool here: http://uto.speccy.org/downloads/hdfmonkey_windows.zip







New Z80n opcodes on the NEXT
======================================================================================
   swapnib           ED 23           8Ts      A bits 7-4 swap with A bits 3-0
   mul               ED 30           8Ts      Multiply D*E = DE (no flags set)
   add  hl,a         ED 31           8Ts      Add A to HL (no flags set)
   add  de,a         ED 32           8Ts      Add A to DE (no flags set)
   add  bc,a         ED 33           8Ts      Add A to BC (no flags set)
   add  hl,$0000     ED 34 LO HI     16Ts     Add $0000 to HL (no flags set)
   add  de,$0000     ED 35 LO HI     16Ts     Add $0000 to DE (no flags set)
   add  bc,$0000     ED 36 LO HI     16Ts     Add $0000 to BC (no flags set)
   ldix              ED A4           16Ts     As LDI,  but if byte==A does not copy
   ldirx             ED B4           21Ts     As LDIR, but if byte==A does not copy
   lddx              ED AC           16Ts     As LDD,  but if byte==A does not copy, and DE is incremented
   lddrx             ED BC           21Ts     As LDDR,  but if byte==A does not copy
   ldpirx            ED B7           16/21Ts  (de) = ( (hl&$fff8)+(E&7) ) when != A
   ldws              ED A5           14Ts     LD (DE),(HL): INC D: INC L
   mirror a          ED 24           8Ts      Mirror the bits in A     
   push $0000        ED 8A LO HI     19Ts     Push 16bit immidiate value
   nextreg reg,val   ED 91 reg,val   20Ts     Set a NEXT register (like doing out($243b),reg then out($253b),val )
   nextreg reg,a     ED 92 reg       17Ts     Set a NEXT register using A (like doing out($243b),reg then out($253b),A )
   pixeldn           ED 93           8Ts      Move down a line on the ULA screen
   pixelad           ED 94           8Ts      Using D,E (as Y,X) calculate the ULA screen address and store in HL
   setae             ED 95           8Ts      Using the lower 3 bits of E (X coordinate), set the correct bit value in A
   test $00          ED 27           11Ts     And A with $XX and set all flags. A is not affected.
   outinb            ED 90           16Ts     OUT (C),(HL), HL++
   bsla de,b         ED 28           8Ts      shift DE left by B places - uses bits 4..0 of B only
   bsra de,b         ED 29           8Ts      arithmetic shift right DE by B places - uses bits 4..0 of B only - bit 15 is replicated to keep sign
   bsrl de,b         ED 2A           8Ts      logical shift right DE by B places - uses bits 4..0 of B only
   bsrf de,b         ED 2B           8Ts      shift right DE by B places, filling from left with 1s - uses bits 4..0 of B only
   brlc de,b         ED 2C           8Ts      rotate DE left by B places - uses bits 3..0 of B only (to rotate right, use B=16-places)
   jp (c)            ED 98           13Ts     JP  ((IN(c)*64)+PC&0xC000)"





























General Emulator Keys
Escape  - quit
F1      - Enter/Exit debugger
F2      - load SNA
F3      - reset
F5      - 3.5Mhz mode           (when not in debugger)
F6      - 7Mhz mode             (when not in debugger)
F7      - 14Mhz mode            (when not in debugger)
F8      - 28Mhz mode            (when not in debugger)
F10     - Toggle Key mode

Debugger Keys
F1                  - Exit debugger
F2                  - load SNA
F3                  - reset
F7                  - single step
F8                  - Step over (for loops calls etc)
F9                  - toggle breakpoint on current line
Up                  - move user bar up
Down                - move user bar down
PageUp              - Page disassembly window up
PageDown            - Page disassembly window down
SHIFT+Up            - move memory window up 16 bytes
SHIFT+Down          - move memory window down 16 bytes
SHIFT+PageUp        - Page memory window up
SHIFT+PageDown      - Page memory window down
CTRL+SHIFT+Up       - move trace window up 16 bytes
CTRL+SHIFT+Down     - move trace window down 16 bytes
CTRL+SHIFT+PageUp   - Page trace window up
CTRL+SHIFT+PageDown - Page trace window down

Mouse is used to toggle "switches"
HEX/DEC mode can be toggled via "switches"

You can also use the mouse to select "bytes" to edit in the memory window, simply place 
mouse over the top and left click. Enter will cancel, as will clicking outside the
memory window.

Debugger Commands
================================================================================
M <address>         Set memory window base address (in normal 64k window)
M <bank>:<offset>   Set memory window into physical memory using bank/offset
G <address>         Goto address in disassembly window
BR <address>        Toggle Breakpoint
WRITE <address>     Toggle a WRITE access break point
READ  <address>     Toggle a READ access break point (also when EXECUTED)
PUSH <value>        push a 16 bit value onto the stack
POP				    pop the top of the stack
POKE <add>,<val>    Poke a value into memory
Registers:
   A  <value>       Set the A register
   A' <value>       Set alternate A register
   F  <value>       Set the Flags register
   F' <value>       Set alternate Flags register
   AF <value>       Set 16bit register pair value
   AF'<value>       Set 16bit register pair value
   |
   | same for all others
   |
   SP <value>       Set the stack register
   PC <value>       Set alternate program counter register
LOG OUT [port]      LOG all port writes to [port]. If port is not specified, ALL port writes are logged.
                    (Logging only occurs when values to the port change)
LOG IN  [port]      LOG all port reads from [port]. If port is not specified, ALL port reads are logged.
                    (Logging only occurs when values port changes)
NEXTREG <reg>,<val> Poke a next register	
SAVE "NAME",add,len                   Save in the 64K memory space
SAVE "NAME",BANK:OFFSET,length        Save in physical memory using a bank and offset as the start address
SAVE "NAME",BANK:OFFSET,BANK:OFFSET   Save in physical memory using a bank and offset as the start address, and as an end address
