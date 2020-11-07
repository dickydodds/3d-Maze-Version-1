
;For SJASMPLUS

        ; Allow the Next paging and instructions
        DEVICE ZXSPECTRUMNEXT

        ; Generate a map file for use with Cspect
        CSPECTMAP "project.map"

;code here
; jump straight into sjasmplus debugger
 ;       BREAK
; set stack pointer in lower 16k at 32767
;        ld sp,28671


start_game

    org 40000
   di
;set next memory paging

     nextreg $82,2      ; enable port dffd for mmu paging
    ld bc,$7FFD
    in a,(c)
    set 3,a
    out (c),a

;assume primary screen paged in in mmu 10
    ld a,10     ;select normal screen
    nextreg $52,a

    ld bc,4096              
    ld hl,0
    ld de,16384
t1   ld a,(hl)
    ld (de),a 
    dec bc
    ld a,b
    sub c
    jr z,t2
    dec bc
    inc hl
    inc de    
    jr t1
;switch alternate screen in

t2    ld a,14     ;select shadow screen
    nextreg $52,a

 ;2nd screen
    ld bc,4096              
    ld hl,$4096
    ld de,16384
t3   ld a,(hl)
    ld (de),a 
    dec bc
    ld a,b
    sub c
    jr z,t4
    dec bc
    inc de    
    jr t3

;now pause then flick between the 2 screens

t4: ld a,(var1)
    cp 10
    jr nz,x1    ;its not 10 so make it 14
    ld a,14     ;show the shadow screen
    jp switch
x1:  ld a,10

  ;select  screen
switch:
    nextreg $52,a
    ld (var1),a     ;save it
    call pause
    jr t4   ;repeat forevor



pause:
    ld bc,1200
rept:

    dec bc
    ld a,b
    sub c
    jr nz, rept
    ret

var1    defb 10

;end code

   
;for SJASMPLUS
;;
;; Set up the Nex output
;;

        ; This sets the name of the project, the start address, 
        ; and the initial stack pointer.
        SAVENEX OPEN "ulatest.nex", start_game  ;, END_PROGRAM

        ; This asserts the minimum core version.  Set it to the core version 
        ; you are developing on.
        SAVENEX CORE 2,0,0

        ; This sets the border colour while loading (in this case white),
        ; what to do with the file handle of the nex file when starting (0 = 
        ; close file handle as we're not going to access the project.nex 
        ; file after starting.  See sjasmplus documentation), whether
        ; we preserve the next registers (0 = no, we set to default), and 
        ; whether we require the full 2MB expansion (0 = no we don't).
        SAVENEX CFG 7,0,0,0

        ; Generate the Nex file automatically based on which pages you use.
        SAVENEX AUTO

