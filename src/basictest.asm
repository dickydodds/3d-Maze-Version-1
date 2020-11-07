;For SJASMPLUS

        ; Allow the Next paging and instructions
        DEVICE ZXSPECTRUMNEXT

        ; Generate a map file for use with Cspect
        CSPECTMAP "project.map"

main:           org 32768
start:          di       ;disable interrupts

;first, clear the 2 ULA bank screens as they are at ROM location 0
                          
              NEXTREG $50,10
              CALL clsULA
              NEXTREG $50,14
              CALL clsULA
           
;now exit to BASIC

              nextreg $69,64
              NEXTREG $50,$FF
              NEXTREG $52,$0A
        
              ld iy,$5c3a
              ei
              ret  

clsULA:                 ;Clear Ula Buffer:
    ld  hl,$0000
    ld  de,$0001
    ld  bc,$1800
    ld  (hl),l
    ldir
    ld  (hl),$48    ; black paper, cyan ink
    ld  bc,$02F0
    ldir
    ret 

;for SJASMPLUS
;;
;; Set up the Nex output
;;

        ; This sets the name of the project, the start address, 
        ; and the initial stack pointer.
 ;       SAVENEX OPEN "3dmaze.nex";, start_game  ;, END_PROGRAM
        SAVEBIN "basictest.bin",32768,32767

