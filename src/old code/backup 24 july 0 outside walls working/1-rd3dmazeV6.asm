        org 32768

;        jp start

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
blue       equ $01    
red        equ $02
magenta    equ $03
green      equ $04
cyan       equ $05
yellow     equ $06
white      equ $07
black      equ $00
;rex_pos    equ 32904
udg_start  equ 64056  ;64184

screen_add equ 16384
screen_atr equ screen_add + 6144
screen_bot equ 23659
screen_mem equ $c000   ;49152
;d_file     dw  16384 ;49152
d_file  dw $c000  ; low byte of display in memory 49152 (c000)

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
;message1   db " return..."

; maze constants
; --------------
; the code for the wall must have bit 7 set whereas the other codes must have bit 7 reset.

_mw     equ  128                ; wall.
_mp     equ  32                 ; passageway.
_mr     equ  82                  ; rex.
_me     equ  69  ;e              ; exit.
_sp     equ  32
_mh     equ  129                  ;seperator or end wall


;################################################################
; some routines here in the 1.5k before the maze data
;################################################################

;============================================
;clear the character maze in memory 
;============================================

clear_char_screen:
;clear the screen

        ld hl,$c000
        ld bc,790;767
        ld de,$c001
        ld (hl),32;32 ;$90 + 21  ;udg u
        ldir
        ret
;################################################################
;rom routine for cls
;################################################################

cls:          
              push bc           ;save it
              ld b, $18         ;clear the screen
              call cl_line
              pop bc
              ret

;################################################################
; routine to clear the colours off the screen
;################################################################

cls_attr:     
              push hl
              push bc
              push de

              ld hl,screen_atr
              ld de, screen_atr + 1
              ld bc,767
              ld (hl),120
              
              ldir

              pop de
              pop bc
              pop hl
              ret 



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
;this bit purely for the maze generator to display correctly

;org 34288-16 ;($85F0-16) for maze start

  
; db _mh, _mh, _mh, _mh, _mh, _mh, _mh, _mh, _mh, _mh, _mh, _mh, _mh, _mh, _mh, _mh

      org 34288 ;($85F0) for maze start

maze:


; mh - outside wall, mw - inner maze wall, mp - space=passageway
; maze starts at 34288
;  column   1    2     3    4    5   6    7    8    9    10   11   12   13   14   15   16
l45f0:  db _mh, _mh, _mh, _mh, _mh, _mh, _mh, _mh, _mh, _mh, _mh, _mh, _mh, _mh, _mh, _mh ;1
l4600:  db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;2
l4610:  db _mh, _mp, _mw, _mw, _mw, _mw, _mw, _mw, _mw, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;3
l4620:  db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mw, _mp, _mp, _mp, _mp, _mp, _mp ;4
l4630:  db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mw, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;5
l4640:  db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mw, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;6
l4650:  db _mh, _mp, _mp, _mp, _mp, _mp, _mw, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;7
l4660:  db _mh, _mp, _mp, _mp, _mp, _mw, _mw, _mw, _mw, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;8
l4670:  db _mh, _mp, _mp, _mp, _mp, _mw, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;9
l4680:  db _mh, _mp, _mp, _mp, _mp, _mw, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;10
l4690:  db _mh, _mp, _mw, _mp, _mp, _mw, _mp, _mp, _mp, _mw, _mp, _mp, _mp, _mp, _mp, _mp ;11
l46a0:  db _mh, _mp, _mp, _mw, _mw, _mw, _mw, _mw, _mw, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;12
l46b0:  db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mw, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;13
l46c0:  db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mw, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;14
l46d0:  db _mh, _mp, _mp, _mp, _mp, _mp, _mw, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;15
l46e0:  db _mh, _mp, _mp, _mp, _mp, _mw, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;16
l46f0:  db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;17

l4700:  db _mh, _mh, _mh, _mh, _mh, _mh, _mh, _mh, _mh, _mh, _mh, _mh, _mh, _mh, _mh, _mh ;2
l4710:  db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;3
l4720:  db _mh, _mp, _mw, _mp, _mw, _mw, _mp, _mw, _mw, _mw, _mp, _mw, _mw, _mw, _mw, _mp ;4
l4730:  db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mw, _mw, _mw, _mp, _mp, _mp, _mp, _mp, _mp ;5
l4740:  db _mh, _mp, _mw, _mp, _mw, _mw, _mp, _mw, _mw, _mw, _mp, _mw, _mw, _mw, _mw, _mp ;6
l4750:  db _mh, _mp, _mw, _mp, _mw, _mw, _mp, _mw, _mw, _mw, _mw, _mw, _mw, _mw, _mw, _mp ;7
l4760:  db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mw, _mw, _mw, _mw, _mw, _mp ;8
l4770:  db _mh, _mp, _mw, _mp, _mw, _mw, _mp, _mw, _mw, _mw, _mw, _mw, _mp, _mw, _mw, _mp ;9
l4780:  db _mh, _mp, _mw, _mp, _mw, _mw, _mp, _mp, _mp, _mp, _mw, _mw, _mp, _mw, _mw, _mp ;10
l4790:  db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mw, _mw, _mp, _mp, _mw, _mp, _mw, _mw, _mp ;11
l47a0:  db _mh, _mp, _mw, _mp, _mw, _mw, _mp, _mw, _mw, _mp, _mp, _mw, _mp, _mw, _mw, _mp ;12
l47b0:  db _mh, _mp, _mw, _mp, _mw, _mw, _mp, _mw, _mw, _mw, _mp, _mw, _mp, _mw, _mp, _mp ;13
l47c0:  db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mw, _mp, _mw, _mp, _mw, _mw, _mp ;14
l47d0:  db _mh, _mp, _mw, _mp, _mw, _mw, _mp, _mw, _mw, _mw, _mp, _mp, _mp, _mw, _mp, _mp ;15
l47e0:  db _mh, _mp, _mw, _mp, _mw, _mp, _mw, _mp, _mw, _mw, _mp, _mw, _mw, _mw, _mw, _mp ;16
l47f0:  db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;17


; was org $8133     ;33075