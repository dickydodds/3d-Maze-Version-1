;this is the maze data and colour exit routine

;##########################################################
;maze data

        org $a300   ;41728

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

       ; org 28928               ;$7100 256 byte boundary

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
 db _mh, _mp, _mp, _mp, _mw, _mw, _mw, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;7
 db _mh, _mp, _mw, _mp, _mw, _mp, _mp, _mp, _mw, _mp, _mw, _mp, _mw, _mp, _mw, _mp ;8
 db _mh, _mp, _mp, _mp, _mp, _mp, _me, _mw, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;9
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
 db _mh, _me, _mp, _mw, _mp, _mw, _mw, _mw, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;3
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mw, _mp, _mp, _mp, _mp, _mp, _mp ;4
 db _mh, _mp, _mp, _mp, _mp, _mp, _mw, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;5
 db _mh, _mp, _mp, _mp, _mp, _mw, _mw, _mw, _mp, _mw, _mp, _mp, _mp, _mp, _mp, _mp ;6
 db _mh, _mp, _mw, _mp, _mp, _mw, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;7
 db _mh, _mp, _mp, _mp, _mw, _mw, _mp, _me, _mw, _mw, _mp, _mw, _mw, _mw, _mp, _mp ;8
 db _mh, _mp, _mw, _mw, _mw, _mw, _mp, _mw, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;9
 db _mh, _mp, _mw, _mp, _mp, _mw, _mp, _mp, _mp, _mw, _mp, _mp, _mp, _mp, _mp, _mp ;10
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
 db _mh, _mp, _mp, _mp, _mw, _mw, _mw, _mw, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;7
 db _mh, _mp, _mp, _mw, _mp, _mp, _mw, _mp, _mp, _mp, _mp, _mw, _mw, _mw, _mp, _mp ;8
 db _mh, _mp, _mp, _mw, _mp, _me, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;9
 db _mh, _mp, _mp, _mw, _mp, _mw, _mp, _mp, _mp, _mw, _mp, _mp, _mp, _mp, _mp, _mp ;10
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
 db _mh, _mp, _mp, _mw, _mw, _mw, _mp, _mw, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;10
 db _mh, _mp, _mp, _mw, _mp, _mp, _mw, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;11
 db _mh, _mp, _mp, _mw, _mp, _me, _mp, _mw, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;12
 db _mh, _mp, _mp, _mw, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;13
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

;map start positions
;map0   
        dw  00
;map0   
        dw  00
;map1   
        dw  00
;map2   
        dw  00
;map3   
        dw  00
;map4   
        dw  00
;map5   
        dw  00
;map6   
        dw  00
;map7   
        dw  00
;map8   
        dw  00
;map9   
        dw  00
;map10   
        dw  00
;map11  
        dw  00
;map12  
        dw  00
;map13  
        dw  00
;map14  
        dw  00
;map15  
        dw  00

        nop
        nop
        nop


;##################################################################################
;door exit animation
              ;org $b340

exit_anim:

; this routine prints the coloured boxes during maze generation
; If I try and ruse the exit code above witha few pokes then the gane crashes!
; so I have duplicated it here.

; MOVED CODE HERE AS IT WAS OVERWRITING THE zx81 MEMORY

           ;   ORG 56320         ;=$DC00

ax1:          
              call draw_gen        ; draw some squares!
              ret

temp_x:         dw 22528+32768+67


;Original base code by David Saphier from Facebook May 2018

;org 32768
	

draw_gen:
        
            ld a,6
 ; reg a will hold player distance from the exit
 ;ld a,2                         ;distance
            ld hl,22528+70+32+32

d_box1:	
            call box1 ;draw the box

            ld d,0
            ld e,34
            add hl,de  ;next box to draw


            ld a,(colpos1)   ; get next solid colour to draw

ab1:
            ld a,(colcount)
            inc a
            cp 9
            ld (colcount),a
            jr nz,ab2
            ld a, 0
            ld (colcount),a
            ld (colpos1),a
ab2:
             ld (colpos1),a

            ld a,(size1)     ; reduce the size of the square to draw
            dec a
            dec a
            ld (size1),a
            nop

            ld a,(num2draw1)  ;number of boxes to draw
            dec a
            ld (num2draw1),a
            cp 0
            jp nz, d_box1     ; exit when we get to 2 as routine fails after that.
	
; this must be the same as the size of the square to draw
            ld a,20    ; reduce the size of the square to draw
            ld (size1),a

; this must equal the number of squares to draw
             ld a,10  ;number of boxes to draw
            ld (num2draw1),a

            ret 


box1:
            ld a,(size1)
            ld b,a


ml11:
	call docol1
	ld (hl),a 
	inc hl  
	djnz ml11
    push af
    ld a,(size1)
    dec a
   	ld b,a
    pop af
	dec hl

ml21:
	call docol1 
	ld de,32     ;was 32 
	add hl,de 
	ld (hl),a 
	djnz ml21
    push af
    ld a,(size1)
   ; dec a
   	ld b,a
    pop af
	dec l  

ml31:
	call docol1 
 	ld (hl),a 
 	dec hl 
 	djnz ml31
    push af
    ld a,(size1)
    dec a
   	ld b,a
    pop af
 	inc l 

ml41:
	call docol1 
	ld de,65504; was 65504  (-32) 
	add hl,de 
	ld (hl),a 
	djnz ml41
    push af
    ld a,(size1)
     dec a
   	ld b,a
    pop af
	ret 

docol1:
	push hl
	push de

docol21:
	ld d,0
	ld a,(colpos1)
	cp 1                           ; = number of colours from coltab
;	jr z,reset1
	ld e,a
	ld hl,coltab1
	add hl,de
	nop
; inc a
;	ld (colpos1),a 
	ld a,(hl)
	pop de 
	pop hl 
	ret 

reset1:
    ld a,(colpos)
    cp 99
    jr z, docol21
	ld a,0
	ld (colpos1),a
	jr docol21

coltab1:

; db 0,1*8,2*8,3*8,4*8,8*5,8*6,8*7,6*8,5*8,4*8,3*8,2*8,1*8,0
  db 0,8,16,24,32,40,48,56,48,40,32,24,16,8,0,8,16,24,32,50,48,56
  db 0,8,16,24,32,40,48,56,48,40,32,24,16,8,0,8,16,24,32,50,48,56
  db 99,99
  
colpos1:   db 0
colpos:   db 0
size1:     db 20 ;double the number to draw
colcount   db 0
num2draw1: db 10

