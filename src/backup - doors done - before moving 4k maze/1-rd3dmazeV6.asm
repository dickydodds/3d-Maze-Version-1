;        org 32768


       org  $7000             ; 28672 - $7000

        jp main                 ;goto main game
        
;variables

chan_open: equ 5633
cl_line:   equ 3652 ; clear screen not changing print pos
print:     equ 8252 ; print text line
at         equ 22   ; the 'print 'at' directive
paper      equ $11  ; paper directive  
ink        equ $10  ; ink directive
flash      equ $12  ; flash directive
bright     equ $13
over       equ $15
blue       equ $02    
red        equ $00
magenta    equ $06
green      equ $80
cyan       equ $02
yellow     equ 26
white      equ 255
black      equ 253
;rex_pos    equ 32904

udg_start  equ 63480+8 ;63488  ;= 1024 less than real address for the display printing routine


screen_add equ 16384
screen_atr equ screen_add + 6144
screen_bot equ 23659
screen_mem equ $c000   ;49152
df_cc      equ $5c84

d_file   dw $c000    ;char display in memory at 49152


;maze_highbyte           equ  $71  ;H value (of HL) of current maze being drawn
_hugewall               equ  $b8
_chequerboard           equ  $9f
_space                  equ  32
_bottomblack            equ  $a2
_topblack               equ  $a3
_topwhitebottomchequer  equ  $a1
_topchequerbottomwhite  equ  $a0
_topleftwhite           equ  39
_bottomleftwhite        equ  40
_toprightwhite          equ  41
_bottomrightwhite       equ  42
_black                  equ  $af
_topcorner1             equ  $b0  ;bottom corner left slope to righttop
_topcorner2             equ  $b1  ;left corner slope to right bottom from left
_topcorner3             equ  $b2  ;bottom corner slope to right top
_topcorner4             equ  $b3  ;top corner left slope to right bottom
_wall                   equ  $a4  ;wall pattern
_leftinnerwall          equ  $a5  ;diagonal brick pattern left
_topleft5               equ  $a9  ;next 4 are for far view on layer 5
_bottomleft5            equ  $ab  ;
_topright5              equ  $aa
_bottomright5           equ  $ac
_smallwall              equ  $b4  ;far away wall
_mediumwall             equ  $b5  ;middle wall
_mediumwall_1           equ  $b7  ;middle wall_1
_largewall              equ  $b6  ;close view wall
_layer5lefttop          equ  $9b  ;layer 5 top left chevron
_layer5leftbottom       equ  $9c  ;layer 5 bottom left chevron



;*******  NO MORE CODE HERE PLEASE AS IT WILL SHIFT THE MEMORY UP ****************

;################################################################
; some routines here in the 1.5k before the maze data
;################################################################

;============================================
;clear the character maze in memory 
;============================================

clear_char_screen:

        ld hl,$c000
        ld bc,790;767
        ld de,$c001
        ld (hl),32      ;space
        ldir
        ret
;################################################################
;rom routine for cls of the 2 video pages
;################################################################
     
clsULA:                 ;Clear Ula Buffer:
    ld  hl,$0000
    ld  de,$0001
    ld  bc,$1800
    ld  (hl),l
    ldir
    ld  (hl),$48    ; black paper, cyan ink
    ld  bc,$02FF
    ldir
    ret                                   


;#################################################################################
FlipULABuffers:
                ; Flip ULA/Alt UA screen (double buffer ULA screen)

    ; if A==14, then do NR_69=64 (display Bank7), if A==10: NR_69=0 (display Bank5)

                ld      a,(ULABank)             ; Get screen to display this frame
                cp      10
                jr      z,@DisplayAltULA

                ld      a,64                    ; set CURRENT screen to Alternate ULA (bit 6
                ld      b,10                    ; set target screen to ULA
                jp      @DisplayULA

@DisplayAltULA: ld      b,14                    ; set target screen to Alternate ULA screen
                xor     a                       ; zero the a reg
@DisplayULA:    nextreg $69,a                   ; Select Timex/ULA screen to show
                ld      a,b                     ; get bank to render to next frame
                ld      (ULABank),a             ; store it...

; swap the ula bank we are writing out buffer screen to
swap_bank:                          ;load bank 10 or 14 to location 0 to write to
                ld a,(ULABank)
                nextreg $52,a       ;was $50
                ret         
                
ULABank         defb 10   ;holds current ULA screen in use
;#################################################################################



;##################################################################################
FlipULABuffers_peter:     ; Flip ULA/Alt ULA screen (double buffer ULA screen)
                          ; from Peter Ped Helcmanovsky on the Next Team

    ld a,(ULABank)  ; Get screen to display this frame

    ; if A==14, then do NR_69=64 (display Bank7), if A==10: NR_69=0 (display Bank5)
    ; its %0000'1110 vs %0000'1010 in binary, so extract bit2 and move it to bit6

    and %0000'0100  ; $04 from A=14, $00 from A=10
    swapnib         ; bit6 set from bit2
    nextreg $69,a   ; Select Timex/ULA screen to show

    ; flip the drawing buffer mapped at $4000
    ld a,(ULABank)
    xor 10^14       ; alternate between 10 and 14
    ld (ULABank),a
    nextreg $52,a   ; map the new "backbuffer" to $4000 (for next drawing)
    ret

;##################################################################################



;##################################################################
;print a line of text on screen
;##################################################################

; enter with IX pointing to the message

;message format    row,col,colour,"message",end char
    
print_message:  ;make sure we point to our character set
                ld b,(ix)           ;row
                inc ix
                ld c,(ix)           ;column
                inc ix
                ld a,(ix)           ;set attribute colour
                ld (att),a


                call locate      
                inc ix              ;point to characters to print
mesg_rept:      ld hl,charset_1-256 ; point to our character set
                ld (base),hl 
                ld a,(ix)           ;load our character to print
                
                ;check if we are printing a UDG
                ;we are currently pointing at the ram char set
                bit 7,a                 ;are we printing udg's?
                                        ;if bit 7=0 then zero test = false
                jr z,no_udg             ;exit if theres no graphic to print
                sub $80                 ;point to the first character of udg's 
                ld de,_chars;           ;start of udg's in memory
                ld (base),de                

no_udg:         cp 127               ;check flags to see if a=zero
                ret z               ;quit when char = 0              
                push af
                call print1         ;print the message - auto increments the column
                pop af
                inc ix
                jr nz,mesg_rept
                ret

;#################################################################


;################################################################
; maze data
;################################################################

; the maze lies on a page boundary, allowing the code to check only the low byte of its address.
; the maze is 18 positions north-to-south (rows 0 to 17) and 16 positions west-to-east (columns 0 to 15).
;
;    n
;    |
; w -+- e
;    |
;    s
;
; key: x=wall, space=passageway, e=exit.


   ;   org 34288 ;($85F0) for maze start

        org 28928               ;$7100 256 byte boundary

;#####################################################################################
;This is our 16 Maze's maze data = numbered 0 to 15
;#####################################################################################

; maze constants
; --------------
; the code for the wall must have bit 7 set whereas the other codes must have bit 7 reset.

_mw     equ  128                 ; wall.
_mp     equ  32                  ; passageway.
;_mr     equ  82                  ; rex.
_me     equ  192   ;bin 11000000 ; exit.
_sp     equ  32
_mh     equ  129                 ;seperator or end wall
_ms     equ  160   ;bin 10100000 ;switch            


; _mh - outside wall
; _mw - inner maze wall
; _mp - space=passageway
; _me - exit door
; _ms - switch
; maze starts at 34288 on a 256 byte boundary

;col  1    2     3    4    5   6    7   8    9    10   11   12   13   14   15   16
map_0:
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;1
 db _mh, _mp, _mw, _mp, _mw, _mp, _mw, _mp, _mw, _mp, _mw, _mp, _mw, _mp, _mw, _mp ;2
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;3
 db _mh, _mp, _mw, _mp, _mw, _mp, _mw, _mp, _mw, _mp, _mw, _mp, _mw, _mp, _mw, _mp ;4
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;5
 db _mh, _mp, _mw, _mp, _mw, _mp, _mw, _mp, _mw, _mp, _mw, _mp, _mw, _mp, _mw, _mp ;6
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;7
 db _mh, _mp, _mw, _mp, _mw, _mp, _mw, _mp, _mw, _mp, _mw, _mp, _mw, _mp, _mw, _mp ;8
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;9
 db _mh, _mp, _mw, _mp, _mw, _mp, _mw, _mp, _mp, _mp, _mw, _mw, _mp, _mp, _mw, _mp ;10
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mw, _mp, _mp, _me, _mw, _mp, _mp, _mp ;11
 db _mh, _mp, _mw, _mp, _mw, _mp, _mw, _mp, _mp, _mp, _mw, _mw, _mp, _mp, _mw, _mp ;12
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;13
 db _mh, _mp, _me, _mp, _mw, _mp, _mw, _mp, _mw, _mp, _mw, _mp, _mw, _mp, _mw, _mp ;14
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;15
 db _mh, _mp, _mw, _mp, _mw, _mp, _mw, _mp, _mw, _mp, _mw, _mp, _mw, _mp, _mw, _mp ;16

map_1:
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;1
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mw, _mp, _mp, _mp, _mp, _mp, _mp ;2
 db _mh, _mp, _mp, _mw, _mp, _mw, _mw, _mw, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;3
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mw, _mp, _mp, _mp, _mp, _mp, _mp ;4
 db _mh, _mp, _mp, _mp, _mp, _mp, _mw, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;5
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mw, _mp, _mp, _mp, _mp, _mp, _mp ;6
 db _mh, _mp, _mw, _mp, _mp, _mp, _mw, _mw, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;7
 db _mh, _mp, _mp, _mp, _mw, _mp, _mp, _me, _mw, _mw, _mp, _mw, _mw, _mw, _mp, _mp ;8
 db _mh, _mp, _mw, _mp, _mp, _mp, _mw, _mw, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;9
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mw, _mp, _mp, _mp, _mp, _mp, _mp ;10
 db _mh, _mp, _mp, _mp, _mp, _mp, _mw, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;11
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mw, _mp, _mp, _mp, _mp, _mp, _mp ;12
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;13
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mw, _mp, _mp, _mp, _mp, _mp, _mp ;14
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;15
 db _mh, _ms, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mw, _mp, _mp, _mp, _mp, _mp, _mp ;16


map_2:
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;1
 db _mh, _mp, _mp, _mw, _mw, _mw, _mw, _mw, _mw, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;2
 db _mh, _mp, _mp, _mw, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;3
 db _mh, _mp, _mp, _mw, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;4
 db _mh, _mp, _mp, _mp, _mp, _mp, _mw, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;5
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mw, _mp, _mp, _mp, _mp, _mp, _mp ;6
 db _mh, _mp, _mp, _mp, _mp, _mp, _mw, _mw, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;7
 db _mh, _mp, _mp, _mp, _mp, _mp, _mw, _mp, _mp, _mp, _mp, _mw, _mw, _mw, _mp, _mp ;8
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;9
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mw, _mp, _mp, _mp, _mp, _mp, _mp ;10
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mw, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;11
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mw, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;12
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;13
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;14
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;15
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;16 

map_3
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;1
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mw, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;2
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mw, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;3
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mw, _mp, _mp, _mp, _mp, _mp, _mp, _mw, _mp ;4
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mw, _mp ;5
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mw, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;6
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;7
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mw, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;8
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;9
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mw, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;10
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;11
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mw, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;12
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;13
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mw, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;14
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mw, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;15
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mw, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;16

map_4:
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;1
 db _mh, _mp, _mw, _mw, _mw, _mw, _mw, _mw, _mw, _mw, _mw, _mw, _mw, _mw, _mp, _mp ;2
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mw, _mp, _mw, _mp, _mp ;3
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mw, _mw, _mp, _mw, _mp, _mp, _mp, _mp ;4
 db _mh, _mp, _mp, _mp, _mw, _mw, _mw, _mw, _mp, _mw, _mp, _mw, _mp, _mw, _mp, _mp ;5
 db _mh, _mp, _mw, _mw, _mp, _mp, _mp, _mp, _mp, _mw, _mp, _mw, _mw, _mw, _mp, _mp ;6
 db _mh, _mp, _mp, _mp, _mp, _mp, _mw, _mw, _mp, _mp, _mp, _mw, _mp, _mp, _mp, _mp ;7
 db _mh, _mp, _mw, _mw, _mw, _mw, _mp, _mp, _mp, _mp, _mp, _mw, _mw, _mw, _mp, _mp ;8
 db _mh, _mp, _mw, _mp, _mp, _mp, _mp, _mw, _mp, _mw, _mw, _mw, _mw, _mw, _mw, _mp ;9
 db _mh, _mw, _mp, _mp, _mw, _mw, _mp, _mp, _mp, _mw, _mp, _mp, _mp, _mp, _mp, _mp ;10
 db _mh, _mp, _mp, _mw, _mp, _mp, _mw, _mp, _mp, _mp, _mp, _mp, _mp, _mw, _mw, _mp ;11
 db _mh, _mw, _mp, _mw, _mw, _mw, _mw, _mw, _mw, _mw, _mw, _mw, _mw, _mw, _mp, _mp ;12
 db _mh, _mp, _mp, _mw, _mp, _mw, _mp, _mp, _mw, _mp, _mp, _mp, _mw, _mw, _mp, _mp ;13
 db _mh, _mw, _mp, _mp, _mp, _mw, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mw, _mp, _mp ;14
 db _mh, _mp, _mp, _mp, _mp, _mw, _mw, _mw, _mw, _mw, _mp, _mp, _mw, _mw, _mp, _mp ;15
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;16

map_5:
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;1
 db _mh, _mp, _mw, _mw, _mw, _mw, _mw, _mp, _mw, _mw, _mw, _mw, _mw, _mw, _mw, _mp ;2
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;3
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;4
 db _mh, _mp, _mw, _mw, _mw, _mw, _mw, _mp, _mw, _mw, _mw, _mw, _mw, _mw, _mw, _mp ;5
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;6
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;7
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;8
 db _mh, _mp, _mw, _mw, _mw, _mw, _mw, _mp, _mw, _mw, _mw, _mw, _mw, _mw, _mw, _mp ;9
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mw, _mp, _mw, _mp, _mp, _mp ;10
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mw, _mp, _mp, _mp, _mw, _mp, _mp ;11
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mw, _mp, _mp, _mw, _mp, _mp, _mw, _mp ;12
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mw, _mp, _mp, _mw, _mp, _mw, _mp, _mp, _mp ;13
 db _mh, _mp, _mw, _mw, _mw, _mw, _mw, _mp, _mp, _mw, _mp, _mp, _mp, _mw, _mw, _mp ;14
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mw, _mw, _mw, _mw, _mp, _mp, _mp, _mp ;15
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mw, _mw, _mw, _mw, _mw, _mw, _mw, _mp, _mp ;16

map_6:
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;1
 db _mh, _mp, _mw, _mp, _mw, _mw, _mw, _mw, _mw, _mw, _mp, _mp, _mw, _mw, _mw, _mp ;2
 db _mh, _mp, _mw, _mp, _mw, _mp, _mp, _mp, _mw, _mw, _mp, _mp, _mp, _mw, _mp, _mp ;3
 db _mh, _mp, _mw, _mp, _mw, _mp, _ms, _mp, _mw, _mw, _mw, _mw, _mw, _mw, _mp, _mp ;4
 db _mh, _mp, _mw, _mw, _mw, _mp, _mw, _mp, _mw, _mw, _mp, _mp, _mp, _mp, _mp, _mp ;5
 db _mh, _mp, _mw, _mp, _mw, _mp, _mw, _mp, _mp, _mw, _mp, _mp, _mp, _mw, _mw, _mp ;6
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mw, _mp, _mp, _mp, _mw, _mp, _mp ;7
 db _mh, _mp, _mw, _mw, _mw, _mw, _mw, _mw, _mp, _mw, _mw, _mw, _mw, _mw, _mw, _mp ;8
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mw, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;9
 db _mh, _mp, _mw, _mw, _mw, _mw, _mp, _mw, _mp, _mw, _mw, _mp, _mw, _mw, _mw, _mp ;10
 db _mh, _mp, _mw, _mp, _mp, _mw, _mp, _mw, _mp, _mp, _mw, _mp, _mw, _mp, _mw, _mp ;11
 db _mh, _mp, _mp, _mp, _me, _mw, _mp, _mw, _mp, _mw, _mp, _mw, _mp, _mp, _mw, _mp ;12
 db _mh, _mp, _mw, _mp, _mw, _mw, _mp, _mw, _mp, _mw, _mp, _mp, _mp, _mp, _mp, _mp ;13
 db _mh, _mp, _mw, _mp, _mp, _mp, _mp, _mw, _mp, _mw, _mw, _mw, _mp, _mp, _mp, _mp ;14
 db _mh, _mp, _mw, _mw, _mw, _mw, _mw, _mw, _mp, _mw, _mw, _mw, _mw, _mp, _mw, _mp ;15
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;16

map_7
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;1
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mw, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;2
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mw, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;3
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mw, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;4
 db _mh, _mw, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mw, _mp ;5
 db _mh, _mw, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mw, _mp ;6
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;7
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;8
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;9
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mw, _mp, _mp, _mp, _mp ;10
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;11
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;12
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;13
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;14
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;15
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;16

map_8:
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;1
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mw, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;2
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mw, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;3
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mw, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;4
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;5
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;6
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;7
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;8
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;9
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;10
 db _mh, _mp, _mp, _mp, _mp, _mp, _mw, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;11
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mw, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;12
 db _mh, _mp, _mp, _mp, _mp, _mp, _mw, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;13
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;14
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;15
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;16

map_9:
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;1
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;2
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;3
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;4
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;5
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;6
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;7
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;8
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;9
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;10
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;11
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;12
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;13
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;14
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;15
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;16

map_10:
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;1
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;2
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;3
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;4
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;5
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;6
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;7
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;8
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;9
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;10
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;11
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;12
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;13
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;14
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;15
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;16

map_11:
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;1
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;2
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;3
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;4
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;5
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;6
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;7
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;8
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;9
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;10
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;11
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;12
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;13
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;14
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;15
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;16

map_12:
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;1
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;2
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;3
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;4
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;5
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;6
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;7
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;8
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;9
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;10
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;11
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;12
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;13
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;14
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;15
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;16

map_13:
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;1
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;2
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;3
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;4
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;5
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;6
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;7
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;8
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;9
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;10
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;11
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;12
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;13
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;14
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;15
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;16

map_14:
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;1
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;2
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;3
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;4
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;5
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;6
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;7
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;8
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;9
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;10
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;11
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;12
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;13
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;14
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;15
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;16

map_15:
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;1
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;2
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;3
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;4
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;5
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;6
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;7
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;8
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;9
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;10
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;11
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;12
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;13
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;14
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;15
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;16

;###############################################################
;Message list                
;message format    row,col,colour,"message",end char

message_border1:      db 0,25,148,$b0,$b1,$b0,$20,$b1,$b0,$b1,$7f
message_get:          db 1,25,87,$88,"G E T",$89,$7f
message_out:          db 2,25,87,$88,"O U T",$89,$7F 
message_border4:      db 3,25,148,$b3,$b2,$b3,$20,$b2,$b3,$b2,$7f
message_closed:       db 23,2,60," Go flick the switch ",$7F
message_switchon:     db 23,1,70," The Door is now Open ",$7F
message_leave:        db 23,1,100," Woohoo! Time to leave ",$7F
message_level         db 15,25,87," LEVEL ",$7f


;##########################################################################
;setup ULANext palette data - code from Matt Davies early version of Ed.s

Setup_palette:

       nextreg $43,%00000001   ; Set ULANext palette ON
       nextreg $40,%00000000    ; set index to 0 which = start of palette  
       nextreg $42,%00000001   ; Set 8 ink & 31 paper

;poke in the pallete data
        ld hl, .palette_data    ;get the start of .palette_data
.lp1   ld a, (hl)
        cp $01                   ;99 is the end of the data 
        ret z                   ;exit if a=99
        nextreg $41,a           ;this auto increments
        inc hl
        jp .lp1
                
.palette_data:
;ink colours - only first 16 which are standard spectrum colours

    db $0, $ff, $a0, $36, $4a, $cb, $1b, $f9, $df, $0, $7, $e0, $e7, $1f, $fc, $fe    
	db $e1, $0, $0, $24, $24, $49, $92, $b6, $fe, $db, $96, $6e, $49, $25, $0, $0
	db $0, $20, $44, $88, $ad, $f1, $fa, $fe, $f5, $ec, $c8, $84, $e8, $ec, $f4, $f8
	db $fd, $dd, $9d, $59, $31, $d, $9, $5, $5, $e, $13, $1b, $1f, $9f, $fb, $f3
	db $c7, $63, $23, $2, $0, $21, $65, $86, $cb, $ca, $f2, $e9, $e4, $c4, $80, $40
	db $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0
    db $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0
	db $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0

    db $0, $ff, $a0, $36, $4a, $cb, $1b, $f9, $df, $0, $7, $e0, $e7, $1f, $fc, $fe
	db $0, $2, $a0, $36, $4a, $cb, $1b, $f9, $df, $0, $7, $e0, $e7, $1f, $fc, $fe
	db $e1, $0, $0, $24, $24, $49, $92, $b6, $fe, $db, $96, $6e, $49, $25, $0, $0
	db $0, $20, $44, $88, $ad, $f1, $fa, $fe, $f5, $ec, $c8, $84, $e8, $ec, $f4, $f8
	db $fd, $dd, $9d, $59, $31, $d, $9, $5, $5, $e, $13, $1b, $1f, $9f, $fb, $f3
	db $c7, $63, $23, $2, $0, $21, $65, $86, $cb, $ca, $f2, $e9, $e4, $c4, $80, $40

;these are the red wall graduations - 6 colours
	db $c0, $a0, $80, $60, $40, $20, $0, $0, $0, $0, $0, $7, $6, $4, $2, $0
	db $c0, $a0, $80, $60, $40, $20, $ff, $ff, $ff, $ff, $0, $0, $0, $0, $ff, $01

palette_end:
;##################################################################################

draw_exit_door_closed:
               ; exit_closed 20 lines of 17 chars
                ld b,20
                ld hl,exit_closed
abcd:           push bc
                push hl
                ld ix,hl        ;point to our data to print
                CALL print_message
                pop hl
                ld de,17
                add hl,de
                ld ix,hl
                pop bc
                djnz abcd:
;call the colouring routine
                call colour_door
;print the middle bars again as we overote them above
                ld ix,over1
                CALL print_message
                ld ix,over2
                CALL print_message
                ret

over1:          db 9,6,134, $80,$81,$80,$81,$80,$81,$80,$81,$80,$81,$80,$81,$80,$7F
over2:          db 10,6,132,$82,$83,$82,$83,$82,$83,$82,$83,$82,$83,$82,$83,$81,$7F
   

;this routine below will be used by the right wall closed door drawing routine as well as now
;now colour the bars white ink - this will overwrite the 2 dark bars at line 7 and 8 - will sort later
colour_door:    ld hl,22696         ;start of bar bit at the top of the door
                ld de,32            ;to jump 1 line down
                ld a,9              ;draw 9 characters across
                ld (att_count),a
                ld a,199
                ld c,a              ;set colour to white ink, black paper
                ld a,16             ;do 16 lines
rept_5:         push hl
rept_4:         push af
                ld a,(att_count)    ;9
                ld b,a
                pop af
rept_3:         ld (hl),c           ;set the attribute colour
                inc hl
                djnz rept_3
                pop hl 
                add hl,de           ;jump to next line below
                push hl
                dec a
                jr nz,rept_4
                pop hl 
                ret

att_count       db  9  
              
;###############################################################
;door graphic
;message format    row,col,colour,"message",end char (127 ($7f) )
exit_closed:    ;20 lines
                db 3,6,136, $80,$81,$80,$81,$80,$81,$80,$81,$80,$81,$80,$81,$80,$7F
                db 4,6,134, $82,$83,$82,$83,$82,$83,$82,$83,$82,$83,$82,$83,$81,$7F
                db 5,6,132, $80,$81,$84,$84,$84,$84,$84,$84,$84,$84,$84,$81,$80,$7F
                db 6,6,130, $82,$83,$84,$84,$84,$84,$84,$84,$84,$84,$84,$83,$81,$7F
                db 7,6,128, $80,$81,$84,$84,$84,$84,$84,$84,$84,$84,$84,$81,$80,$7F
                db 8,6,126, $82,$83,$84,$84,$84,$84,$84,$84,$84,$84,$84,$83,$81,$7F
                db 9,6,134, $80,$81,$80,$81,$80,$81,$80,$81,$80,$81,$80,$81,$80,$7F
                db 10,6,132,$82,$83,$82,$83,$82,$83,$82,$83,$82,$83,$82,$83,$81,$7F
                db 11,6,130,$80,$81,$84,$84,$84,$84,$84,$84,$84,$84,$84,$81,$80,$7F
                db 12,6,128,$82,$83,$84,$84,$84,$84,$84,$84,$84,$84,$84,$83,$81,$7F
                db 13,6,126,$80,$81,$84,$84,$84,$84,$84,$84,$84,$84,$84,$81,$80,$7F
                db 14,6,134,$82,$83,$84,$84,$84,$84,$84,$84,$84,$84,$84,$83,$81,$7F
                db 15,6,132,$80,$81,$84,$84,$84,$84,$84,$84,$84,$84,$84,$81,$80,$7F
                db 16,6,130,$82,$83,$84,$84,$84,$84,$84,$84,$84,$84,$84,$83,$81,$7F
                db 17,6,128,$80,$81,$84,$84,$84,$84,$84,$84,$84,$84,$84,$81,$80,$7F
                db 18,6,126,$82,$83,$84,$84,$84,$84,$84,$84,$84,$84,$84,$83,$81,$7F
                db 19,6,136,$80,$81,$84,$84,$84,$84,$84,$84,$84,$84,$84,$81,$80,$7F
                db 20,6,134,$82,$83,$84,$84,$84,$84,$84,$84,$84,$84,$84,$83,$81,$7F
                db 21,6,132,$80,$81,$80,$81,$80,$81,$80,$81,$80,$81,$80,$81,$80,$7F
                db 22,6,130,$82,$83,$82,$83,$82,$83,$82,$83,$82,$83,$82,$83,$81,$7F
;------------------------------------------------------------------------------------
draw_exit_door_open:
               ; exit_closed 20 lines of 17 chars
                ld b,20
                ld hl,exit_open
abcde:          push bc
                push hl
                ld ix,hl        ;point to our data to print
                CALL print_message
                pop hl
                ld de,17
                add hl,de
                ld ix,hl
                pop bc
                djnz abcde:
                ret
exit_open:    ;20 lines
                db 3,6,191, $b1,$af,$af,$af,$af,$af,$af,$af,$af,$af,$af,$af,$b0,$7F
                db 4,6,191, $20,$b1,$af,$af,$af,$af,$af,$af,$af,$af,$af,$b0,$20,$7F
                db 5,6,191, $20,$20,$b1,$af,$af,$af,$af,$af,$af,$af,$b0,$20,$20,$7F
                db 6,6,190, $20,$20,$20,$af,$af,$af,$af,$af,$af,$af,$20,$20,$20,$7F
                db 7,6,190, $20,$20,$20,$af,$af,$af,$af,$af,$af,$af,$20,$20,$20,$7F
                db 8,6,190, $20,$20,$20,$af,$af,$af,$af,$af,$af,$af,$20,$20,$20,$7F
                db 9,6,190, $20,$20,$20,$af,$af,$af,$af,$af,$af,$af,$20,$20,$20,$7F
                db 10,6,190,$20,$20,$20,$af,$af,$af,$af,$af,$af,$af,$20,$20,$20,$7F
                db 11,6,190,$20,$20,$20,$af,$af,$af,$af,$af,$af,$af,$20,$20,$20,$7F
                db 12,6,190,$20,$20,$20,$af,$af,$af,$af,$af,$af,$af,$20,$20,$20,$7F
                db 13,6,190,$20,$20,$20,$af,$af,$af,$af,$af,$af,$af,$20,$20,$20,$7F
                db 14,6,190,$20,$20,$20,$af,$af,$af,$af,$af,$af,$af,$20,$20,$20,$7F
                db 15,6,190,$20,$20,$20,$af,$af,$af,$af,$af,$af,$af,$20,$20,$20,$7F
                db 16,6,190,$20,$20,$20,$af,$af,$af,$af,$af,$af,$af,$20,$20,$20,$7F
                db 17,6,190,$20,$20,$20,$af,$af,$af,$af,$af,$af,$af,$20,$20,$20,$7F
                db 18,6,190,$20,$20,$20,$af,$af,$af,$af,$af,$af,$af,$20,$20,$20,$7F
                db 19,6,190,$20,$20,$20,$af,$af,$af,$af,$af,$af,$af,$20,$20,$20,$7F
                db 20,6,191,$20,$20,$b2,$af,$af,$af,$af,$af,$af,$af,$b3,$20,$20,$7F
                db 21,6,191,$20,$b2,$af,$af,$af,$af,$af,$af,$af,$af,$af,$b3,$20,$7F
                db 22,6,191,$b2,$af,$af,$af,$af,$af,$af,$af,$af,$af,$af,$af,$b3,$7F

;--------------------------------------------------------------------------------------
draw_door_right_closed:
               ; exit_closed 14 lines of 7 chars
                ld b,13
                ld hl,right_door_closed
abc_a:          push bc
                push hl
                ld ix,hl        ;point to our data to print
                CALL print_message
                pop hl
                ld de,7
                add hl,de
                ld ix,hl
                pop bc
                djnz abc_a

;draw top angled bit of the door on right wall
                ld ix,top_right_1        ;point to our data to print
                CALL print_message
                ld ix,top_right_2        ;point to our data to print
                CALL print_message
                ld ix,top_right_3        ;point to our data to print
                CALL print_message
                ld ix,top_right_4        ;point to our data to print
                CALL print_message

;draw bottom angled bit of the door on right wall
                ld ix,bot_right_1        ;point to our data to print
                CALL print_message
                ld ix,bot_right_2        ;point to our data to print
                CALL print_message
                ld ix,bot_right_3        ;point to our data to print
                CALL print_message
                ld ix,bot_right_4        ;point to our data to print
                CALL print_message
           ; BREAK
;now colour the attributes correctly to look diagonal
                ;do white colour bars first
                ld hl,22710         ;start of bar bit at the top of the door
                ld de,32            ;to jump 1 line down
                ld a,1              ;draw 9 attribute across
                ld (att_count),a
                ld a,199
                ld c,a              ;set colour to white ink, black paper
                ld a,14             ;do 16 lines
               ; push hl
                call rept_5         ;colour our door correctly
                ret


;top 2 parts of the door
top_right_1:    db 2,23,136,         $d3,$7F
top_right_2:    db 3,22,136,     $d5,$80,$7F
top_right_3:    db 4,21,136, $d3,$83,$82,$7F
top_right_4:    db 5,21,136, $80,$87,$80,$7F
;middle of the closed door
right_door_closed:      ;15 lines
                db 6,21,130, $82,$87,$82,$7F
                db 7,21,128, $80,$87,$80,$7F
                db 8,21,126, $82,$87,$82,$7F
                db 9,21,136, $80,$87,$80,$7F
                db 10,21,134,$82,$87,$82,$7F
                db 11,21,132,$80,$87,$80,$7F
                db 12,21,130,$82,$87,$82,$7F
                db 13,21,128,$80,$87,$80,$7F
                db 14,21,126,$82,$87,$82,$7F
                db 15,21,136,$80,$87,$80,$7F
                db 16,21,134,$82,$87,$82,$7F
                db 17,21,132,$80,$87,$80,$7F
;                db 18,21,130,$82,$87,$82,$7F
;bottom 2 parts of the door
bot_right_1:    db 18,21,128, $80,$87,$80,$7F
bot_right_2:    db 19,21,128, $d4,$83,$82,$7F
bot_right_3:    db 20,22,128,     $d6,$80,$7F
bot_right_4:    db 21,23,128,         $d4,$7F

;--------------------------------------------------------------------
draw_door_right_open:
               ; exit_closed 14 lines of 7 chars
                ld b,13
                ld hl,right_door_open
abc_b:          push bc
                push hl
                ld ix,hl        ;point to our data to print
                CALL print_message
                pop hl
                ld de,7
                add hl,de
                ld ix,hl
                pop bc
                djnz abc_b

;draw top angled bit of the door on right wall
                ld ix,top_right_op2        ;point to our data to print
                CALL print_message
                ld ix,top_right_op3        ;point to our data to print
                CALL print_message
                ld ix,top_right_op4        ;point to our data to print
                CALL print_message

;draw bottom angled bit of the door on right wall - basically, all spaces so floor colour is drawn
                ld ix,bot_right_op1        ;point to our data to print
                CALL print_message
                ld ix,bot_right_op2        ;point to our data to print
                CALL print_message
                ld ix,bot_right_op3        ;point to our data to print
                CALL print_message

          
;now colour the attributes correctly to look diagonal
                ;do white colour bars first
               ; ld hl,22710         ;start of bar bit at the top of the door
               ; ld de,32            ;to jump 1 line down
               ; ld a,1              ;draw 9 attribute across
               ; ld (att_count),a
               ; ld a,199
               ; ld c,a              ;set colour to white ink, black paper
               ; ld a,14             ;do 16 lines
               ; call rept_5         ;colour our door correctly
                
                ret

;top 2 parts of the door
top_right_op2:    db 3,22,192,     $b0,$7F,$7F;;$20,$7F
top_right_op3:    db 4,21,192, $b0,$20,$7F,$7F;$20,$7F
top_right_op4:    db 5,21,188, $20,$20,$7F,$7F;$20,$7F
;middle of the open door
right_door_open:      ;15 lines
                db 6,21,188, $20,$20,$7F,$7F;$20,$7F
                db 7,21,188, $20,$20,$7F,$7F;,$20,$7F
                db 8,21,188, $20,$20,$7F,$7F;,$20,$7F
                db 9,21,188, $20,$20,$7F,$7F;$20,$7F
                db 10,21,188,$20,$20,$7F,$7F;$20,$7F
                db 11,21,188,$20,$20,$7F,$7F;$20,$7F
                db 12,21,188,$20,$20,$7F,$7F;$20,$7F
                db 13,21,188,$20,$20,$7F,$7F;$20,$7F
                db 14,21,188,$20,$20,$7F,$7F;$20,$7F
                db 15,21,188,$20,$20,$7F,$7F;$20,$7F
                db 16,21,188,$20,$20,$7F,$7F;$20,$7F
                db 17,21,188,$20,$20,$7F,$7F;$20,$7F
                db 18,21,188,$20,$20,$7F,$7F;$20,$7F

;bottom 2 parts of the door
bot_right_op1:    db 19,21,188, $20,$20,$7F,$7F;$20,$7F
bot_right_op2:    db 20,21,98, $20,$20,$7F,$7F;$20,$7F
bot_right_op3:    db 21,22,98,     $20,$7F,$7F;$20,$7F






