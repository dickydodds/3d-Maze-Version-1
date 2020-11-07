          
;############################################
; ld de with the value to use to check the walls in front
; or the sides of the player
;############################################

; reg a must contain the direction you want to look at

load_de:
            ld a,(player_dir)     ; get player direction
; 00= north, 01=west, 02=south, 03=east

;if 0 decrease by -16 n
;if 1 decrease by -1  w
;if 2 increase by +16 s
;if 3 increase by +1  e

;when checking distance, if you are looking south and your current location
;is >240 then you are at the south wall.


;if you are at the top of the maze facing north, and you current location
; is <16 you are at the far north wall of the maze

;for east and west you can detect a wall is $80 except for 255 (bottom
; right) as the next  right location is outside the maze.

; find out how far away we are from a wall
        ;are we facing north?
              cp 0
              jp nz,de_1
              ld de, $ffff  ; (-1) to go to the left of north
              ld (left),de
              ld de, $0001  ; (+1) to go to next line right  - north
              ld (right),de
              ld de, $0010  ; (+16) to go to next line behind - north
              ret

de_1:         cp 1          ;west
              jp nz,de_2
              ld de, $0010  ; (+16) to go to next line to the left - west
              ld (left),de
              ld de, $fff0  ; (-16) to go to next line to the right - west
              ld (right),de
              ld de, $0001  ; (+1) to go to next line behind - west
              ret

de_2:         cp 2          ; south
              jp nz,de_3
              ld de, $001  ; (+1) to go to next line to the left - south
              ld (left),de
              ld de, $ffff      ; (-1) to go to next line to the right - south
              ld (right),de
              ld de, $fff0      ; (-16) to go to next line behind - south
              ret             

              ;we must be facing east if we get here
de_3:         ld de, $fff0      ; (-16) to go to next line left - east
              ld (left),de
              ld de, $0010      ; (+16) to go to next line right - east
              ld (right),de
              ld de, $ffff      ; (-1) to go to next line behind - east
              ret
