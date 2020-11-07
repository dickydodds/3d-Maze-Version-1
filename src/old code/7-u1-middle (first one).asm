
;================================================
;start to draw maze that is immediately above us
;================================================

;draw the level 1 upper middle - immediately above us

draw_upper_1:

;       (depth) will hold how far we can see - max 6 squares in front of our view

;              ld hl,(player_pos)    ;get player position

;              ld a,l
        ; if l=255  we are at the bottom right hand corner facing east to a end wall
        ; if l>240 we are at the south wall
        ; if l<16 we are at the north wall

              
;how do i implement a less-than/greater-than test in assembly?

;a: to compare stuff, simply do a cp, and if the zero flag is set,
;a and the argument were equal, else if the carry is set the argument was greater, 
;and finally, if neither is set, then a must be greater 
;(cp does nothing to the registers, only the f (flag) register is changed). 

;first, set hl to our map

  ;      ld hl,(furthest_point)  ;load our last furthest point
;        ld a,(maze_highbyte)
        ld hl,(player_pos)
        push hl
        inc h
        ld (player_pos),hl
        
        call get_distance
        ld a,h
        ld (maze_highbyte),a
        
        call do_upper_1   ;draw the upper level

        pop hl
        ld (player_pos),hl
        ld a,h
        ld (maze_highbyte),a
;        ld (furthest_point),hl  ;re save it
        
;              pop af
;              call set_map      ;set mapback to current middle map view
              ret

do_upper_1:
              ld a,(depth)
              cp 6
              jp z,draw_U6L	;just draw end middle block perhaps??
              cp 5
              jp z,draw_U5L	;only need to draw 3 block + 1 part
;              cp 4
;              jp z,draw_4m	;only need to draw 2 block + 1 part
;              cp 3
;              jp z,draw_3m	;only need to draw 1 block + 1 part	
;              cp 2
;              jp z,draw_2m	;only need to draw 1 block
;              cp 1
;              jp z,draw_1m	;only need to draw 1 block
;              jp draw_0m		;only need to draw edge blocks
;end of routine
              ret
                                                                    

;############################################
;############################################
;draw section 6 right - well, nothing to do atm!
;############################################
;############################################

draw_U6L:

;do nothing on screen as already done via left side draw
;just incremement where we are in the maze view

        ld hl,(furthest_point)  ;load our last furthest point
;        inc h                   ;point to our next map up
        call load_de            ;get left and right and front jump into de reg
        add hl,de               ;Additional add to simulate layer 6
        ld (furthest_point),hl  ;re save it



;#####################################################################
;#####################################################################
;draw section 5 upper 1 LEFT block
;#####################################################################
;#####################################################################

draw_U5L:
;              push hl

;        call get_maze_location

              ld hl,$0175 - 66      ;start address in disp file for wall 5 left drawing
                                    ;2 lines above us
              ld (w5_start),hl
              call draw_5
              ld hl,$0175           ;put back original number
              ld (w5_start),hl
 ;             pop hl

              ret

;#####################################################################
;#####################################################################
;draw section 4 upper 1
;#####################################################################
;#####################################################################
  
draw_4m


;#####################################################################
;#####################################################################
;Get Location - returns our maze location and sets DE and HL
;needs de holding 
;#####################################################################
;#####################################################################
; --------------

get_maze_location:

; hl=maze location being drawn.
; now determine what to draw for this section.

;On return we have the following setup:-
;Memory Location (left)=next left maze location
;Memory Location (right)=next right maze location
;DE holds the amount to jump back in the view from 
;section 6 ahead of our view
;(DEPTH) holds how far we can see in front of us.

        ld hl,(furthest_point)   ;get our maze location
        call load_de            ;load left, right and de register
        add hl,de
        ld (furthest_point),hl  ;increment for the next layer to draw
        ld   hl,(d_file)        ; fetch the location of the display file.
        ret

;       ld   de,$0177           ; offset to row 11 column 12 - the centre of the 3d view.
;        add  hl,de              
;        push hl                 ;save it;

;        ld   hl,(furthest_point); retrieve the maze location.
        
;        ld de,(de_count)
;        add hl,de               ;get the block in front of us from the maze.
      
