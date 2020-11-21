   

;##################################################
; Start to draw the maze in memory
;##################################################

;hl will hold the player location in the maze

;now draw the maze position

;1 get our location from player_pos 16 bit but only the low byte used
;  since our maze is max 256 bytes.
;2 get our direction from player_dir 0 - 3 only.
;  0=north
;  1=west
;  2=south
;  3=east
;3 work out how far away the wall is in front of our view-
;  if its greater or less that 6 blocks since thats the max depth
;  we will draw on screen (6 blocks)
;4 start drawing from the back to the front
;  so everything is overwritten (separate routine).
;


;screen is built in memory from c000 (49152) using characters

get_distance:

              ld hl,(player_pos)    ;get player location

              ld a,(player_dir)     ; get player direction
              

;00= north, 01=west, 02=south, 03=east

;if 0 decrease by -16 n
;if 1 decrease by -1  w
;if 2 increase by +16 s
;if 3 increase by +1  e

;when checking distance, if you are looking south and your current location
;is >240 then you are at the south wall.


;if you are at the top of the maze facing north, and you current location
; is <16 you are at the far north wall of the maze

;for east amd west you can detect a wall is chr $80 except for 255 (bottom
; right) as the next  right location is outside the maze.

; find out how far away we are from a wall
        ;are we facing north?
              cp 0
              jp z, north2
              cp 1
              jp z, west2
              cp 2
              jp z, south2                            
        ;it must be facing east if we get heret 

        ;check if were at the bottom right hand corner (255)
        ;if so we implicitly have a wall.


              
        ;we are facing east
              ld de, $0001      ; (+1) to go to next line in front of us

;clear maxview flag and data
check_dist:
              ld a,6
              ld (maxview),a
              ld a,(flags)
              res 0,a
              ld (flags),a
             
              ld b,255            ;make accum 1 - counter

;check if maxview set - if so, dont check for wall
;in front of player anymore as there alreay is a wall set

loop2:        ld a,(flags)
              bit 0,a           ;if 1, then already set
              jp nz,check_mh
                      
              ld a,(hl)         ; this is the furthest point we can see
              cp _mw ;=128      ;is it a wall here
              jr z,j2  

;check for an exit wall and treat as if its a wall
              cp _me
              jp z, j2   ;if no wall check for end wall

;check for an switch wall and treat as if its a wall
              cp _ms
              jp nz, check_mh   ;if no wall check for end wall
                                
j2:           ld a,b            ;there is a wall if we get here
              ;is it 255? if so make it 0
              inc a             ;if a=0, it was 255
              jp z,j1
              dec a             ;put back to original value
              
j1:           ld (maxview),a    ;save how far we can actually see
              ld a,(flags)
              set 0,a
              ld (flags),a      ;set that we have set the flag
              
              
check_mh:     ld a,(hl)
              cp _mh ;=129      ; is it an end wall?
              jr z, end_loop    ; if yes, exit now
              inc b

;check if we are at location 0 in the maze - if so do nothing
              ld a,l
              inc a
              dec a             ;zero flag set if = to zero
              jp z,end_loop2

;##########################################################

;now check if we are at the top end of the maze or the bottom
;end of the maze as there are no blocks to check for there.
;do bottom end first.


              ld a,(player_dir)              
              dec a                 ;is it 0 which = north
              inc a
              jp nz,cont_6a          ;carry on if not at north wall

              ;are we trying to read data outside the 256 byte boundary?
              ld a,l
              cp 17
              jp nc,cont_9

              add hl,de         ;now jump to next location in front of us
              ld a,b            ;get our depth
              jp end_loop       ;exit routine

              
cont_6a       ld a,(player_dir)
              sub 2              ;are we facing south?
              jp nz,cont_9        ;z means yes

              ld a,l
              cp 240
              jp c,cont_9      ;carry set if cp >a
              
              add hl,de         ;now jump to next location in front of us
              ld a,b            ;get our depth
              jp end_loop       ;exit routine


;###########################################################              

cont_9        ld a,b
              cp 6              ;only do a max of 6 loops as
              add hl,de         ;now jump to next location in front of
              jr nz,loop2        
              jp end_loop
        ;we have hit a wall or 6 loops

end_loop2:    ld b,255          ;we are here as we are at the end wall
                                ;top and bottom of the maze so make our
                                ;depth 0
end_loop1:    inc b

end_loop:
;first check if we hit an end wall - our maxview flag will =0
              ld a,(flags)
              bit 0,a
              jp nz,cont_8      ;continue on if not 0                         
              ld a,b
              ld (maxview),a    ;if it is make maxview 0
cont_8:
;check if b=255, if so, make it 0
              inc b
              jp z,here1
              dec b             ;put back original value
here1:        ld a,b
              ld (depth),a         ; -save how far we can see
              ld (de_count),de     ;save the de value for adding / subtracting later
              ld (furthest_point),hl
              ret

west2:
              ld de, $ffff      ; (-1) to go to next line to the left
              jp check_dist

north2:
              ld de, $fff0      ; (-16) to go to next line behind
              jp check_dist
south2:
              ld de, $0010      ; (+16) to go to next line to the left
              jp check_dist
  
              ret

          
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


;#######################################################
;load walk - load de with the amount to jump in the maze
;as we walk forward
;#######################################################

load_walk:
              ld a,(player_dir)   ;find out which way we are looking 

              ;are we facing north?
              cp 0
              jp nz,de1
              ld de, $fff0 ; (-16) to go to next line behind - north
              ret

de1:          cp 1          ;west
              jp nz,de2
              ld de, $ffff  ; (-1) to go to next line behind - west
              ret

de2:          cp 2          ; south
              jp nz,de3
              ld de, $0010     ; (+16) to go to next line behind - south
              ret             

              ;we must be facing east if we get here
de3:          ld de, $0001      ; (+1) to go to next line behind - east
              ret



;#################################################################################
;DOOR & SWITCH DRAWING ROUTINES

;#################################################################################
;see if we need to draw an open or closed door

; show door type = 0 = front, 1 = side

draw_door:   ;check to see if we need to show the exit door
             ;door will always face NORTH. 
             xor a                  ;make reg a zero to say no door
             ld (show_exit),a
             ;are we facing south?
             ld a,(player_dir)
             sub 2                  ;2 = south
             jr nz,check_east      ;if not check if door is to our right hand side
             ;we must be facing south and be in front of the door
             ;dec a
             ;ld (show_exit),a
             ld hl,(player_pos)
             ld de, $0010           ; (+16) to go to next line in front of us - south
             add hl,de
             ld a,(hl)
             cp _me                 ;is it our DOOR?
             jr nz,check_east      ;if not check if door is to our right hand side
             ;YES its a door - so draw it - but only if we are looking south
             ld a,(switch_pulled)
             and a
             jr z,not_open
             call  draw_exit_door_open
             ;print the door message
             ld ix,message_leave
             CALL print_message
             ret           
not_open:    call draw_exit_door_closed
   
             ;print the door message
             ld ix,message_closed        ;exit_closed
             CALL print_message
             ret

;theres no door immediately in front of us but now check if theres a door 1 space in front and to the right of us                
check_east:
             ;1st check if we are facing East as door will be on our right, 1 space ahead of us
             ; so we have to be facing EAST
             ld a,(player_dir)
             sub 3              ;EAST = 3
             ret nz             ;exit as theres no door to our right 

             ld hl,(player_pos)
             inc hl             ;move test point to 1 place in front of us
             ld de, $0010      ; (+16) to go to next line in front of us - EAST
             add hl,de
             ld a,(hl)         
             cp _me             ;;is it our DOOR?
             ret nz
             ;there IS a door and it will always face NORTH and be on our right
             ;yes its our door - so draw it

             ;determine if its open or closed
             ld a,(switch_pulled)
             and a
             jr nz,_open           ;0=closed 1 = open
             call draw_door_right_closed
             ret
_open:       call draw_door_right_open         
             ret

;#########################################################################################
;SWITCH Drawing Routine - I am being very lazy here and copying the code from the door 
;drawing as its the same thing to do for both the door and switch and  cant be bothered atm to 
;modify the dor routine and save bytes! (nov 2020)
;-----------------------------------------------------------------------------------------

draw_switch:

 ;check to see if we need to show the Switch
             ;switch will always face NORTH. 
           ;  xor a                  ;make reg a zero to say no switch
           ;  ld (show_switch),a
             ;are we facing south?
             ld a,(player_dir)
             sub 2                  ;2 = south
             jr nz,check_east      ;if not check if switch is to our right hand side
             ld hl,(player_pos)
             ld de, $0010           ; (+16) to go to next line in front of us - south
             add hl,de
             ld a,(hl)
             cp _ms                 ;is it our SWITCH?
             jr nz,check_sw_east      ;if not check if the SWITCH is to our right hand side
             ;YES its a switch - so draw it - but only if we are looking south
             ld a,(switch_pulled)
             and a
             jr z,switch_off
             call  draw_switch_on
             ;print the switch on message
             ld ix,message_switchon
             CALL print_message
             ret           

switch_off:  call draw_switch_off
             ret

;theres no door immediately in front of us but now check if theres a door 1 space in front and to the right of us                
check_sw_east:
             ;1st check if we are facing East as door will be on our right, 1 space ahead of us
             ; so we have to be facing EAST
             ld a,(player_dir)
             sub 3              ;EAST = 3
             ret nz             ;exit as theres no door to our right 

             ld hl,(player_pos)
             inc hl             ;move test point to 1 place in front of us
             ld de, $0010      ; (+16) to go to next line in front of us - EAST
             add hl,de
             ld a,(hl)         
             cp _ms             ;;is it our DOOR?
             ret nz
             ;there IS a door and it will always face NORTH and be on our right
             ;yes its our door - so draw it

             ;determine if its open or closed
             ld a,(switch_pulled)
             and a
             jr nz,open_a           ;0=closed 1 = open
             call draw_switch_right_closed
             ret
open_a:      call draw_switch_right_open         
             ret



