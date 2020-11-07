
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
;        ld hl,(player_pos)
;        push hl
;        inc h
;        ld (player_pos),hl
        
;        ld a,h
;        ld (maze_highbyte),a

        ld a,(maze_highbyte)  
        push af
        inc a
        ld (maze_highbyte),a        
        ld hl,(player_pos)
        inc h
        ld (player_pos),hl
            
        call get_distance
        
        call do_upper_1   ;draw the upper level

        ld hl,(player_pos)
        dec h
        ld (player_pos),hl
        pop af        
        ld (maze_highbyte),a
;        ld (furthest_point),hl  ;re save it
        
        ret

do_upper_1:
              ld a,(depth)
              cp 6
              jp z,draw_U6L	;just draw end middle block perhaps??
              cp 5
              jp z,draw_U5L	;only need to draw 3 block + 1 part
;              cp 4
;              jp z,draw_U4L	;only need to draw 2 block + 1 part
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
 
; hl=maze location being drawn.
; now determine what to draw for this section.

;first we need to decrement how far we can see to the layer
;we are working on

        ld hl,(furthest_point)  ;load our last furthest point

        call load_de            ;get left and right and front jump into de reg
        add hl,de               ;jump backwards along the user view 1 space
        
        ld (furthest_point),hl ;re save it

        ld de,$ffff             ;to move the display position -1
        ld (var4),de

        ld de,(left)

;move the maze location pointer 1 to the left - used for all
;remaining blocks to test if there is a wall there or not.

        add hl,de
        ld (var6),hl

        ld (var3),de
        ld de,$0175 - 66

        call do_draw_U5
   
 
        jp draw_U4               ;now draw the 4th level
  
do_draw_U5:

        ld   hl,(d_file)        ; fetch the location of the display file.
        add  hl,de

        
; draw left half then right half of the display.

        ld b,4                ; count for 4 columns left  of maze

        ld de,(var6); retrieve the maze location.


;cont_U3:
        ex   de,hl              ; transfer de to hl.
        ld a,_smallwall;_topleft5          ; load with top left char $a9
        ld (var1),a
        inc a
        ld a,_smallwall;_topleft5          ; load with top left char $a9
        
        ld (var2),a             ;ld with bottom left char

loopU8:
        push hl


;############################################################################
;see if h is ouside the current maze 256 byte boundary - if so
;do NOT draw a wall.

        ld a,(maze_highbyte)
        cp h                    ;are we at the top part of the maze?
        jp z,cont_1Us 
        ld a,1                 ;do not draw a maze wall!
        ld b,a
        jp go_backU5
                                ;if we are on a different maze boundary
                                ;then draw a maze wall as we are the top
                                ;or north wall but maze data has no
                                ;wall data.
;4 = 2nd left wall
;3 = 2nd left wall
;2 = 3rd left wall
;1 = 4th left wall
        
        ld a,b                  ;our current wall counter
        cp 4
        jp nz,a5_U1                 ;its not wall 4
        ld a,1
        ld b,a
        add a,128               ;make sure we set a wall!
        jp draw_5US             ;jump straight to making an end wall

a5_U1:   cp 3
        jp nz,a5_U2             ;its not wall 3
        ld a,1
        ld b,a                  ;make the bc count 1 so we only draw 1 wall
        add a,128               ;make sure we set a wall!
        jp do_2ndwall_Ul        ;draw the 2nd block to the left

a5_U2:   cp 2
        jp nz,a5_3             ;its not wall 3
        ld a,1
        ld b,a                  ;make the bc count 1 so we only draw 1 wall
        add a,128               ;make sure we set a wall!
        jp do_3rdwall_Ul       ;draw the 2nd block to the left

;a must = 1 if we get here.
a5_U3:   ld a,1
        ld b,a                  ;make the bc count 1 so we only draw 1 wall
        add a,128               ;make sure we set a wall!
        jp do_4thwall_Ul       ;draw the cnd block to the left

;############################################################################

;are we at a maze edge wall = clear flag?
cont_1Us:
;        sub a
;        ld (end_wall),a         ;save that we are NOT at an end wall


        ld a,(hl)               ;otherwise, check if there is a wall 

        cp _mh                  ;maze_wall = 129
        jr nz,contU9
        push af
        ld a,1
        ld (end_wall),a         ;save that we are NOT at an end wall
        pop af
;we are not drawing maze walls so exit
        jp do_wallU5            ;bit 7 (128)
        
contU9:
        rla
        jp c,do_wallU5            ;bit 7 (128)


go_backU5: 
        ld hl,(var4)            ;used for left and right drawing
        add hl,de               ; holds current screen position
        ex de,hl
        pop hl
        push de
        ld de,(var3)            ;used for left and right drawing
        add hl,de                ; go left 1 block in the maze
        pop de
        djnz loopU8
        ret


; there is not a wall so insert black to show that the location is too far away to see its detail.

do_wallU5:

;check if b=2 - if so we are not at a wall immediately next to our left
;nor are we at an and wall. We are drawing the 2nd block to the left
;b=3 for 3rd block to the left.

        ld a,b
        sub 1
        jp z,do_4thwall_Ul       ;draw the cnd block to the left

        ld a,b                  ;b is our loop count
        sub 2                   ;check if a=2
        jp z,do_3rdwall_Ul       ;draw the 2nd block to the left

        ld a,b
        sub 3
        jp z,do_2ndwall_Ul       ;draw the cnd block to the left


   
;b must = 4 if we get here, so draw the first wall

          ;check if bit 2 is set as thats an end 
        ;and b must then be changed to 1 to stop drawing.      
draw_5US:
        bit 1,a                 ; is this a side wall? (129 but we rla'd accu)
        jr z,drawU8

        sub a                   ;we do NOT have an ouside maze wall
        ld (end_wall),a         ;save that we are NOT at an end wall
;b must be 1 if we get here!

drawU8:  push de
        ld   a,(var1)           ;holds _smallwall     
        ld   (de),a             ; insert the top of the wall.

        dec de
        ld   (de),a             ; insert the top of the wall.
        inc de                  ;put plot position back to start of wall
        
;now check if we need to draw a black side on the right
;by looking to the character to the right of the wall
;and if there is not a wall already drawn, then draw a
;black side

        ld a,_topleft5          ;draw the top left side
        inc de                  ;jump ahead 1 char in the display
        ld (de),a               ;draw a black and chevron side
        dec de                  ;go back 1 space again

;NOW DO THE NEXT LINE BELOW

;_xU1:    
        ld   hl,$0021           ;jump to the next line below
        add  hl,de
        ld a,(var2)             ;draw our wall bottom.
        ld   (hl),a             ; insert the bottom of the wall.
        dec hl
        ld   (hl),a             ; insert the bottom of the wall.
        inc hl
        inc hl
        ld a,_bottomleft5
        ld (hl),a

;_xU2     
        pop de
        jr go_backU5              ; jump back to main loop


;************************************

;draw the wall for 2nd LEFT layer

;***********************************

do_2ndwall_Ul:

        push de                 ;save the current acreen position

;1st check if theres a wall where we need to draw the black side

        dec de
        dec de                  ;move 3 place left to position us correctly

;now draw a red wall to the right of section 2
        inc de
        ld a,_smallwall
        ld (de),a
        dec de
        ld (de),a               ;draw 2nd one (4 wide)
        dec de
        ld (de),a               ;draw 3rd one (4 wide)

        inc de
        inc de
        inc de
                 ;put us back to our start position ready
                                ;to start drawing the black side

;now check if we need to draw a black side on the right
;by looking to the character to the right of the wall
;and if there is not a wall already drawn, then draw a
;black side

        inc de
        ld a,(de)               ;read whats there
        cp _smallwall           ;is it a wall
        jp z,_x1r_2_Ul           ;if yes, do NOT draw a black side.
        dec de
        ld a,$95                ;draw top left side
        ld (de),a               ;draw middle top bit
        inc a
        inc de
        ld (de),a               ;draw middle top bit
        
       
;top line done

;now do the bottom line underneath

;REMEMBER - 1 block is 2 8 bit squares at the section
_x1r_2_Ul:
        dec de
        dec de
        dec de                  ;move left 3 places in the display
        ld  hl,$0021           ;jump to the next line below + 1 char right
        add hl,de


;now draw a red wall to the right of section 2        
        inc hl
        ld a,_smallwall
        ld (hl),a
        dec hl
        ld (hl),a
        dec hl
        ld (hl),a               ;draw 3rd one (3 wide)

        inc hl                
        inc hl
        inc hl
        
;now check if we need to draw a black side on the left of the lower half wall
;do this by checking if the next block is already a wall just like above

        inc hl      ;look at the right block
        ld a,(hl)
        cp _smallwall           ;is there a bottom wall5 here?
        jp z,_x2r_2_Ul
        ld a,$98            ;draw rightmost bottom
        dec hl
        ld (hl),a

       inc a
        inc hl
        ld (hl),a
                
_x2r_2_Ul  pop de
        jp go_backU5              ; jump back to main loop

;##########################################

;draw the wall for 3rd LEFT layer

;##########################################

do_3rdwall_Ul:

        push de                 ;save the current acreen position
;1st check if theres a wall where we need to draw the black side

       dec de
        dec de
        dec de
        dec de
        dec de
        dec de
        
        
;now draw a red wall to the left of section 2,  top half

        ld a,$8e                ;8e - 3rd wall graphic
        ld (de),a
        inc de
        ld (de),a 
        inc de
        ld (de),a
        inc de
        ld (de),a               ;draw 4th one (4 wide)
        
        
;now check if we need to draw a black side on the right
;by looking to the character to the right of the wall
;and if there is not a wall already drawn, then draw a
;black side

        inc de        
        ld a,(de)               ;read whats there
       ; dec de                  ;put our pointer back to the original position
        cp _smallwall           ;is it a wall
        jp z,_x1r_3Ul               ;if yes, do NOT draw a black side.
        dec de
        inc de
        inc de
        inc de
        ld a,$c5             ;draw top right side
        ld (de),a
        dec de
        inc a
        ld (de),a
        inc a
        dec de
        ld (de),a

;Top line done
;now do the bottom line

_x1r_3Ul:
        dec de
        dec de
        dec de
        dec de
        
        ld   hl,$0021           ;jump to the next line below + 1 char right
        add  hl,de
        ld a,$8e
        ld (hl),a
        inc hl
        ld (hl),a
        inc hl
        ld (hl),a
        inc hl
        ld (hl),a
        
        inc hl
        
        
;now check if we need to draw a black side on the left of the lower half wall
;do this by checking if the next block is already a wall just like above

        inc hl      ;look at the right block
        ld a,(hl)
        dec hl
        cp _smallwall           ;is there a bottom wall5 here?
        jp z,_x2r_3Ul
        dec hl
;inc hl
        ld a,$c3            ;draw leftmost bottom
        inc hl
        ld (hl),a
        inc hl
        dec a
        ld (hl),a
        inc hl
        dec a                
        ld (hl),a
        
_x2r_3Ul  pop de
        jp go_backU5              ; jump back to main loop

;##########################################

;draw the wall for 4th (and last!) LEFT layer

;##########################################

do_4thwall_Ul:

;draw top half of wall

        push de                 ;save the current acreen position
;1st check if theres a wall where we need to draw the black side
        dec de
        dec de
        dec de
        dec de
        dec de
        dec de
;now draw a red wall to the right of section 2,  top half

        ld a,$8d
        ld (de),a
        dec de
        ld (de),a 

        
        inc de                  ;move print position back for black wall

;now check if we need to draw a black side on the right
;by looking to the character to the right of the wall
;and if there is not a wall already drawn, then draw a
;black side

        inc de                  ;jump left 1 char in the display
        ld a,(de)               ;read whats there
        dec de                  ;put our pointer back to the original position
        cp $8e                 ;is it a wall
        jp z,_x1r_31_Ul               ;if yes, do NOT draw a black side.
        ld a,$b9              ;draw top right side
        inc de
        inc de
        inc de
        inc de
        ld (de),a           ;draw 4 black sides
        dec de
        inc a
        ld (de),a
        inc a
        dec de
        ld (de),a
        inc a
        dec de
        ld (de),a

        dec de              ;move to wall start
                                

;top line done

;now do the bottom line underneath

_x1r_31_Ul
 ld   hl,$0021           ;jump to the next line below + 1 char right
        add  hl,de

        ld a,$8d
        ld (hl),a
        dec hl
        ld (hl),a

        inc hl
        
        
;now check if we need to draw a black side on the left of the lower half wall
;do this by checking if the next block is already a wall just like above

        inc hl      ;look at the left block
        ld a,(hl)
        dec hl
        cp $8e           ;is there a bottom wall5 here?
        jp z,_x2r_31_Ul

        ld a,$bd            ;draw leftmost bottom
        inc hl
        inc hl
        inc hl
        inc hl
        
        ld (hl),a
        dec hl
        inc a
        ld (hl),a
        dec hl
        inc a                
        ld (hl),a
        dec hl
        inc a                
        ld (hl),a
        
_x2r_31_Ul  pop de
        jp go_backU5              ; jump back to main loop


;############################################
;############################################
;draw LEFT layer 4
;############################################
;############################################
           ret

;#####################################################################
;#####################################################################
;draw section 4 upper 1
;#####################################################################
;#####################################################################
  
draw_U4
RET

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
      
