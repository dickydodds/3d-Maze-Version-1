

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

start:
    org 40000
    ld sp,$ffff

;code to use banks 12,13,14 and 15
    
                nextreg $57,10   ; bank screen into $E000
                xor a
                inc a     ;a=1
                out     ($ff),a 
          
                ld      hl,$e000  ; Get the current buffer we're drawing to
                ld      de,$e001
                ld      (hl),%00101010
                ld      bc,6912   ; fill the screen
                ldir
               ; call FlipBuffers
                call pause
                call pause
              
               ; nextreg $57,16 
               ; xor a     ;a=0
               ; inc a     ;a=1
               ; out     ($ff),a 
                call FlipBuffers

                ld      hl,$e000  ; Get the current buffer we're drawing to
                ld      de,$e001
                ld      (hl),16
                ld      bc,6912   ; fill the screen
                ldir

;now just loopflipping the screen
again:
                ;call FlipBuffers
                nextreg $52,16
                xor a
                inc a     ;a=1
                out     ($ff),a 
 
                call pause
                nextreg $52,10

                xor a
                out   ($ff),a
                call pause
                jp again

;********************************************************************************
; Flip Buffers
; *******************************************************************************
FlipBuffers:
                ; Flip ULA/Timex screen (double buffer ULA screen)
                ld      a,(ULABank)             ; Get screen to display this frame
                cp      10
                jr      z,@DisplayTimex

                ld      b,10                    ; set target screen to ULA
                ld      a,1                     ; set CURRENT screen to TIMEX
                jp      @DisplayULA

@DisplayTimex:  ld      b,11                    ; set target screen to TIMEX
                xor     a                       ; set CURRENT screen to ULA
                
@DisplayULA:    out     ($ff),a                 ; Select Timex/ULA screen
                ld      a,b                     ; get bank to render to next frame
                ld      (ULABank),a             ; store...
                call    ClearULAScreen
                ret



pause:
    ld bc,$7999
rept:

    dec bc
    ld a,b
    sub c
    halt
    jr nz, rept
    ret

; ************************************************************************
; Clear the ULA Screen using DMA
; ************************************************************************
ClearULAScreen:
                ld a,(ULABank)
                nextreg $57,a   ; bank screen into $E000
  
                ld      hl,$e000  ; Get the current buffer we're drawing to
                ld      de,$e001
                ld      (hl),0
                ld      bc,6912   ; fill the screen
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
        SAVENEX CORE 3,0,0

        ; This sets the border colour while loading (in this case white),
        ; what to do with the file handle of the nex file when starting (0 = 
        ; close file handle as we're not going to access the project.nex 
        ; file after starting.  See sjasmplus documentation), whether
        ; we preserve the next registers (0 = no, we set to default), and 
        ; whether we require the full 2MB expansion (0 = no we don't).
        SAVENEX CFG 7,0,0,0

        ; Generate the Nex file automatically based on which pages you use.
        SAVENEX AUTO

