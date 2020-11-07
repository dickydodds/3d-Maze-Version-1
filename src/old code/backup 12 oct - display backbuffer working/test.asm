

;For SJASMPLUS

        ; Allow the Next paging and instructions
        DEVICE ZXSPECTRUMNEXT

        ; Generate a map file for use with Cspect
        CSPECTMAP "project.map"

;code here
; jump straight into sjasmplus debugger
 ;       BREAK
; set stack pointer in lower 16k at 32767
 ;       ld sp,$fffe

start:
    org 40000
    di
                
            ; ld bc,$7ffd
          ;   in a,(c)  
;code to use banks 12,13,14 and 15
    
                nextreg $50,10   ; bank screen into $E000
                call cls
                ld      hl,$1800  ; Get the current buffer we're drawing to
                ld      de,$1801;e001
                ld      (hl),$8
                ld      bc,768;6912   ; fill the screen
                ldir
               ; call FlipBuffers
                call pause
                call pause
              
                nextreg $50,14 
 
                ;call FlipBuffers
                call cls
                ld      hl,$1800  ; Get the current buffer we're drawing to
                ld      de,$1801;e001
                ld      (hl),16
                ld      bc,768;6912   ; fill the screen
                ldir

                call pause
                call pause

;put slot 0 into slot 52
            ;    nextreg $52,0
;now just loopflipping the screen
again:
                call FlipBuffers
                
                ;xor a
                ;set 6,a
                ;nextreg $69,a
                
                call pause
                call pause
                call pause
                call pause
                call pause
                call pause
                call pause
               ; xor a
               ; res 6,a
                             
                ;xor a
                ;res 3,a
                ;nextreg $69,a
               ; ld bc,$7ffd
                ;out (c),a
                call FlipBuffers
                call pause
                call pause
                call pause
                call pause
                call pause
                call pause
                call pause

                call pause
                jp again

;********************************************************************************
; Flip Buffers
; *******************************************************************************
FlipBuffers:
                ; Flip ULA/Timex screen (double buffer ULA screen)
                ld      a,(ULABank)             ; Get screen to display this frame
                cp      10
                jr      z,@DisplayAltULA
                xor     a                       ; zero the a reg
                ld      b,10                    ; set target screen to ULA
                ;ld      a,64                     ; set CURRENT screen to primary ULA (bit 6
                jp      @DisplayULA

@DisplayAltULA: ld      b,14                    ; set target screen to TIMEX
                ;xor     a                       ; set CURRENT screen to ULA
                ld      a,64                     ; set CURRENT screen to Alternate ULA (bit 6
@DisplayULA:    nextreg $69,a                 ; Select Timex/ULA screen
                ld      a,b                     ; get bank to render to next frame
                ld      (ULABank),a             ; store...
                ret



pause:
    ld bc,$ffff
rept:

    dec bc
    ld a,b
    sub c
    ;halt
    jr nz, rept
    ret

cls
                ld      hl,$000  ; Get the current buffer we're drawing to
                ld      de,$0001
                ld      (hl),0
                ld      bc,6144
                ldir
                ld      (hl),56   ;white paper bloack text
                ld      bc,768

912   ; fill the screen
                ldir
                ret

ULABank    defb 10
code_bank  defb 12
;end code

   
;for SJASMPLUS
;;
;; Set up the Nex output
;;

        ; This sets the name of the project, the start address, 
        ; and the initial stack pointer.
        SAVENEX OPEN "ulatest.nex",start ;, END_PROGRAM

        ; This asserts the minimum core version.  Set it to the core version 
        ; you are developing on.
       ; SAVENEX CORE 3,0,0

        ; This sets the border colour while loading (in this case white),
        ; what to do with the file handle of the nex file when starting (0 = 
        ; close file handle as we're not going to access the project.nex 
        ; file after starting.  See sjasmplus documentation), whether
        ; we preserve the next registers (0 = no, we set to default), and 
        ; whether we require the full 2MB expansion (0 = no we don't).
        SAVENEX CFG 7,0,0,0

        ; Generate the Nex file automatically based on which pages you use.
        SAVENEX AUTO

