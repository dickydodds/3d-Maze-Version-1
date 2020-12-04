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
; the code for the wall must have bit 7 set whereas the other codes must have bit 7 reset except switch and exit
;as we still need to draw a wall.

_mw     equ  128   ;bin 10000000              ; wall.
_mp     equ  32    ;bin 00100000              ; passageway.
_me     equ  192   ;bin 11000000              ; exit.
_sp     equ  32    ;bin 00100000              ; passageway.
_mh     equ  129   ;bin 10000001              ; seperator or end wall
_ms     equ  224   ;bin 11100000              ; switch     ($e0)        


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
 db _mh, _mw, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mw, _mp, _mp, _mp, _mp, _mp, _mp ;4
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
 db _mh, _me, _mp, _mw, _mw, _mw, _mw, _mw, _mw, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;2
 db _mh, _mw, _mp, _mw, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;3
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
 db _mh, _me, _mp, _mp, _mp, _mp, _mp, _mw, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;3
 db _mh, _mw, _mp, _mp, _mp, _mp, _mp, _mw, _mp, _mp, _mp, _mp, _mp, _mp, _mw, _mp ;4
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
 db _mh, _me, _mp, _mp, _mp, _mp, _mp, _mp, _mw, _mw, _mp, _mw, _mp, _mp, _mp, _mp ;4
 db _mh, _mw, _mp, _mp, _mw, _mw, _mw, _mw, _mp, _mw, _mp, _mw, _mp, _mw, _mp, _mp ;5
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
 db _mh, _mp, _mp, _mw, _mw, _mw, _mw, _mp, _mw, _mw, _mw, _mw, _mw, _mw, _mw, _mp ;2
 db _mh, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;3
 db _mh, _mp, _me, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp, _mp ;4
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
;the idea here is that the following will happen when you reach the exit:-
;    0 turn off the buffer screen via reg $69
;    1 draw a black box growing ever bigger to fill the screen - thats exit_anim routine
;    2 leave that screen on show
;    3 point to the buffer screen
;    4 draw the first screen of the next level - unless its the last level (level 255 when you finish the game!)    
;    5 copy the attributes to a place in memory - probably after the char screen at $c000
;    6 switch the buffer screen back on via reg $69
;    7 make all the buffer screen colours black
;    8 switch in the buffer screen
;    9 turn off the buffer screen because we want to see the colours materialise!
;    9 draw the colours back in from the copied colours earlier but from the outside in - new_maze_anim routine
;    10 go back to normal!
;
;   if A==10: NR_69=0 (display Bank5)
exit_anim:
          ;  BREAK
;first, make the REAL spectrum screen shows our exit door as we need to write to the screen LIVE 

            nextreg $52,10      ;select the real spectrum screen
            ;now redraw our current screen
            call redraw_screen
            call copy_colours
            call draw_exit_door_open
            call draw_screen_right
            ld hl,charset_1-256
            ld (base),hl
            call compass          ; draw compass

            nextreg $69,0       ;turn off screen buffering so we write directly to the screen 
            ld a,10
            ld (ULABank),a    ;tell the flip ula routine which page is being viewed

            nextreg 7,0
            call do_exit_anim
            call pause
 
;need to set the player start position now.              

            ld a,(cur_map)
            dec a               ;point to our next map  
            call set_map      ;set our map
            ld l,01              ;top left of maze
            ld (player_pos),hl
     
;need to make the screen black, draw ink bits, copy colours to somewhere else then copy back

          ;  nextreg $69,64       ;turn ON screen buffering so we write directly to the ALTERNATE screen our new maze start
            call redraw_screen
            call new_maze_anim
            call pause
            call pause
            call pause
            call pause           

            ret                 ;return to normal game
;------------------------------------------------------------------------------------------
redraw_screen:
              call clear_char_screen    ;clear screen @c000
              call get_distance         ; get distance we can see
              call draw_left_side       ; start drawing the left side of the 
              call get_distance         ; get distance we can see
              call draw_right_side      ; start drawing the right side of the maze
              call draw_front_view      ; draw wall in front of player
              call draw_side_walls
              ;my print used to print screen @c000 to 16384 inc udg's  
              call my_print             ;copy to screen from c000
              call draw_colours         ;colourise the display
              ret
;end drawing the new screen
;----------------------------------------------------------------------------------
;draw a load of black boxes to hide the current screen. We then call part of this routine again to draw in the correct
;colours to the new level - supposed to look cool lol!

do_exit_anim:
           nextreg 7,0

;Original base code by David Saphier from Facebook May 2018

            sub a
            ld (in_out),a       ;indicate we are drawing out from the middle


;reset the boxes to default
; this must be the same as the size of the square to draw
            ld a,2    ; reduce the size of the square to draw
            ld (size1),a

; this must equal the number of squares to draw
            ld a,2  ;number of boxes to draw
            ld (num2draw1),a
                    
            ld hl,256+11+22528+65+32 ;start point - middle of the screen nearly!
            
            ld a,90
            ld (sound_byte),a

d_box1:	    ;play some sound
            push de
            ld a,(sound_byte)
            sub 6
            ld e,a
            ld (sound_byte),a            
            call walk_sound
            pop de

            ld a,0              ;set colour
            call box1           ;draw the box
           	ld de,65504         ; 65504  (-32)

            add hl,de           ;next box to draw
         ;   call pause
         ;   call pause

            ld a,(size1)     ; increase the size of the square to draw
            inc a
            inc a
            ld (size1),a
        

            ld a,(num2draw1)  ;number of boxes to draw
            inc a
            ld (num2draw1),a
            cp 14
            jp nz, d_box1     ; exit when we get to 2 as routine fails after that.

            ret 

;davids code here amended by me....
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

;end of davids code...

;set square colours
docol1:                     ;this routine draws black colours on existing level
    ;    ld a,(in_out)
    ;    dec a               ;check if a=0
    ;    jr z,do_out         ;draw the attributes screen proper if a <> 0
        ld a,240            ;black screen
        ret 
do_out                      ;this routine draws the colours on new level - but I cant get it working!
        push hl
        ld de,$6b00         ;$5800 + $6b00 = $c300. point to our alternate attribute screen
       ; ld de,(fadein)      ;fadein holds our memory pointer to attribut screen-22528
        add hl,de       
        ld a,(hl)           ;get the colour to print
       ; inc de
       ; ld (fadein),de
       ; ld a,6
        pop hl
        ret


fadein     dw 0   ;holds address of colours to fetch for screen colouring
in_out:    db 0   ;1=draw inward, 0=draw outward
size1:     db 2   ; size of square to draw ;double the number to draw
num2draw1: db 2   ;number of squares to draw
cur_screen db 0   ;hold the current screen in view for the exit screen
cur_page   db 0   ;hold the current screen thats paged in view for the exit screen

;###########################################################################

new_maze_anim:

               nextreg 7,1
              ld a,10
              ld (sound_byte),a
        
;we have 24 vertical columns of 24 blocks - swipe left to right
              ld b,24
              ld hl,attr_screen     ;address of colours screen to copy
              ld de,de_dest           ;attributes on main screen
again_1:      push bc
              ld bc,24              ;number of cells to copy

Loop_col_1:
              ldir
              ;do the walking sound
              push de
              ld a,(sound_byte)
              add a,6
              ld e,a
              ld (sound_byte),a            
              call walk_sound
              pop de
              pop bc
              add de,8
              add hl,8
              djnz again_1
              ret
         
            
sound_byte    db 10
de_dest       equ 22528


;*********************************************************************
; Making LDIR 21% faster
;taken from MSX Assembly page - http://map.grauw.nl/articles/fast_loops.php


;LDI Performs a "LD (DE),(HL)", then increments DE and HL, and decrements BC.

;Now, on with the lesson. Aside from OTIR you can also unroll other things. INIR, LDIR and LDDR will also greatly benefit from this method, and sometimes it is also ;beneficial to unroll normal loops which use DJNZ, JR or JP.

;In the case of LDIR however, the number of loops is often too large to simply use an LDI that number of times. That would take up too much space. So what we can do ;instead is to unroll only part of the loop. Say, we need to LDIR something 256 (100H) times. Instead of LDIR we could write:

;we need to move 768 bytes = 48 x 16
copy_colours:

              ld bc,768             ;number of cells to copy
              ld hl,attr_screen     ;address of colours screen to copy
              ld de,22528           ;attributes on main screen
Loop_col:
    ldi  ; 16x LDI
    ldi
    ldi
    ldi
    ldi
    ldi
    ldi
    ldi
    ldi
    ldi
    ldi
    ldi
    ldi
    ldi
    ldi
    ldi
    jp pe,Loop_col  ; Loop until bc = zero           

              ret
      
