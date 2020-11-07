
;============================================
;start to draw the maze from current location
;============================================


draw_left_side:



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

;we need to draw from the furthest distance so 
;point hl to furthest position - only need to use l reg in the subtraction
;              ld a,l
;              sub a,b           ;will never be >255 or less than 1
;hl now points to furthest visible point in front of the player


;no matter what, always draw layer 6 view so theres always a wall in front of us

;        ld   de,$C177        
;        ld   a,_topblack
;;        ld   a,_topwhitebottomchequer
;        ld   (de),a                             ; insert the top of the wall face.
;        ld   hl,$0021
;        add  hl,de                              ; advance to the next row of the display file.
;        ld   (hl),_bottomblack        ; insert the bottom of the wall face.
;;        ld   (hl),_topchequerbottomwhite        ; insert the bottom of the wall face.

;draw a complete line of chequerboard to emulate seeing the outside
;maze wall regardless of what blocks are seen.

        ld hl,$c16A
        ld de,$C16b              ; offset to row 11, col 0
        ld bc,25
      ; ld (hl),_topwhitebottomchequer
        ld (hl),_bottomblack        ; insert the bottom of the wall face.

        ldir
        ld hl,$c18b
        ld de,$C18c              ; offset to row 12, col 0
        ld bc,25
      ; ld (hl),_topchequerbottomwhite
        ld (hl),_topblack        ; insert the bottom of the wall face.
        ldir        

;now draw the rest of the left side

              ld a,(depth)
              cp 6
              jp z,draw_6	;just draw end middle block perhaps??
              cp 5
              jp z,draw_5	;only need to draw 3 block + 1 part
              cp 4
              jp z,draw_4	;only need to draw 2 block + 1 part
              cp 3
              jp z,draw_3	;only need to draw 1 block + 1 part	
              cp 2
              jp z,draw_2	;only need to draw 1 block
              cp 1
              jp z,draw_1	;only need to draw 1 block
              jp draw_0		;only need to draw edge blocks
;end of routine
              ret
                                                                    
draw_6:

draw_layer_6:


;now draw the maze starting at the furthest point we can see
; i.e. the middle of the display

; draw section 6
; --------------
; hl=maze location being drawn.
; now determine what to draw for this section.

        ld hl,(furthest_point)
        call load_de
        add hl,de
        ld (furthest_point),hl  ;increment for the next layer to draw
        
        ld   hl,(d_file)        ; fetch the location of the display file.
        ld   de,$0177           ; offset to row 11 column 12 - the centre of the 3d view.
        add  hl,de              
        push hl                 ;save it

        ld   de,(furthest_point); retrieve the maze location.
        ex   de,hl              ; transfer de to hl.
        
        ld de,(de_count)
        add hl,de               ;get the block in front of us from the maze.
        
loop6:

        ld a,(hl)
        rla
        jp c,do_wall            ;bit 7 (128)

        jp do_no_wall         ; otherwise draw no wall


do_wall:
        ;check if bit 2 is set as thats an end wall 
        ;and b must then be changed to 1 to stop drawing more than 1 wall.
        rla                     ;rotate next bit into carry.
        jp nc, draw7
        bit 1,a                 ; is this a side wall? (129 but we rla'd accu)
        jr z,draw7
        ld b,1                  ;set b so we exit on return

draw7   pop de
        ld   a,_bottomblack
        ld   (de),a             ; insert the top of the wall.
        ld   hl,$0021
        add  hl,de              ; advance to the next row of the display file.
        ld   (hl),_topblack     ; insert the bottom of the wall.
        jr draw_5              ; jump to draw layer 5
        
; there is a wall so insert chequerboard for the wall face.

do_no_wall:
        pop de
        ;push de
        ld   a,_topwhitebottomchequer
        ld   (de),a                             ; insert the top of the wall face.
        ld   hl,$0021
        add  hl,de                              ; advance to the next row of the display file.
        ld   (hl),_topchequerbottomwhite        ; insert the bottom of the wall face.

;now got to draw the 5th row of data


;############################################
;############################################
;draw section 5 left
;############################################
;############################################

draw_5: 
;ret
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
        ld   de,$0175           ; offset to row 11 column 10 - left of  centre of the 3d view.

        call do_draw_5
   
         jp draw_4               ;now draw the 4th level
  
do_draw_5:

        ld   hl,(d_file)        ; fetch the location of the display file.
        add  hl,de

        
; draw left half then right half of the display.

        ld b,4                ; count for 4 columns left  of maze

        ld de,(var6); retrieve the maze location.



;check if we are at the bottom right of the maze
;if so, there is no wall after position 255 so point us to
;position 240 and fake the wall!
;;;        ld a,e
;;;        cp 255
;;;        jp nz,cont_3  ;continue if we are not at position 255
;;;        ld e,240      ;fake where we are so we draw a wall :)


;now move the maze pointer left (-1) 1 position
;so we can read the type of walls to our left
        
cont_3:
;*         push hl
;*        ld hl,(left)
;*        add hl,de
;*        ex de,hl
;*        pop hl

        ex   de,hl              ; transfer de to hl.

;       hl = furthest point in the maze
;       de = d_file location to store byte to display

;we have to load the first plot position with a corner bit to show
;the end of the wall at the position we can see next to the center
;plot position on section 6
;then, while we draw the other blocks we can see we just want top and
;bottom blacks pointed so will use var1 and var 2 to hold the
;character block we need to print.


        ld a,_smallwall;_topleft5          ; load with top left char $a9
        ld (var1),a
        inc a
        ld a,_smallwall;_topleft5          ; load with top left char $a9
        
        ld (var2),a             ;ld with bottom left char

loop8:
        push hl


;############################################################################
;see if h is ouside the current maze 256 byte boundary - if so draw a wall.

        ld a,(maze_highbyte)
        cp h                    ;are we at the top part of the maze?
        jp z,cont_1s 
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
        jp nz,a5_1                 ;its not wall 4
        ld a,1
        ld b,a
        add a,128               ;make sure we set a wall!
        jp draw_5S             ;jump straight to making an end wall

a5_1:   cp 3
        jp nz,a5_2             ;its not wall 3
        ld a,1
        ld b,a                  ;make the bc count 1 so we only draw 1 wall
        add a,128               ;make sure we set a wall!
        jp do_2ndwall_l        ;draw the 2nd block to the left

a5_2:   cp 2
        jp nz,a5_3             ;its not wall 3
        ld a,1
        ld b,a                  ;make the bc count 1 so we only draw 1 wall
        add a,128               ;make sure we set a wall!
        jp do_3rdwall_l       ;draw the 2nd block to the left

;a must = 1 if we get here.
a5_3:   ld a,1
        ld b,a                  ;make the bc count 1 so we only draw 1 wall
        add a,128               ;make sure we set a wall!
        jp do_4thwall_l       ;draw the cnd block to the left

;############################################################################

;are we at a maze edge wall = clear flag?
cont_1s:
        sub a
        ld (end_wall),a         ;save that we are NOT at an end wall


        ld a,(hl)               ;otherwise, check if there is a wall 

        cp _mh                  ;maze_wall = 129
        jr nz,cont9
        push af
        ld a,1
        ld (end_wall),a         ;save that we are NOT at an end wall
        pop af
        
cont9:  rla
        jp c,do_wall5            ;bit 7 (128)


go_back5: 
        ld hl,(var4)            ;used for left and right drawing
        add hl,de               ; holds current screen position
        ex de,hl
        pop hl
        push de
        ld de,(var3)            ;used for left and right drawing
        add hl,de                ; go left 1 block in the maze
        pop de
        djnz loop8
        ret


; there is not a wall so insert black to show that the location is too far away to see its detail.

do_wall5:

;check if b=2 - if so we are not at a wall immediately next to our left
;nor are we at an and wall. We are drawing the 2nd block to the left
;b=3 for 3rd block to the left.

        ld a,b
        sub 1
        jp z,do_4thwall_l       ;draw the cnd block to the left

        ld a,b                  ;b is our loop count
        sub 2                   ;check if a=2
        jp z,do_3rdwall_l       ;draw the 2nd block to the left

        ld a,b
        sub 3
        jp z,do_2ndwall_l       ;draw the cnd block to the left


   
;b must = 4 if we get here, so draw the first wall

          ;check if bit 2 is set as thats an end 
        ;and b must then be changed to 1 to stop drawing.      
draw_5S:
        bit 1,a                 ; is this a side wall? (129 but we rla'd accu)
        jr z,draw8

        sub a                   ;we do NOT have an ouside maze wall
        ld (end_wall),a         ;save that we are NOT at an end wall
;b must be 1 if we get here!

draw8:  push de
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

;_x1:    
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

;_x2
         pop de
        jr go_back5              ; jump back to main loop


;************************************

;draw the wall for 2nd LEFT layer

;***********************************

do_2ndwall_l:

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
        jp z,_x1r_2_l           ;if yes, do NOT draw a black side.
        dec de
        ld a,$95                ;draw top left side
        ld (de),a               ;draw middle top bit
        inc a
        inc de
        ld (de),a               ;draw middle top bit
        
       
;top line done

;now do the bottom line underneath

;REMEMBER - 1 block is 2 8 bit squares at the section
_x1r_2_l:
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
        jp z,_x2r_2_l
        ld a,$98            ;draw rightmost bottom
        dec hl
        ld (hl),a

       inc a
        inc hl
        ld (hl),a
                
_x2r_2_l  pop de
        jp go_back5              ; jump back to main loop

;##########################################

;draw the wall for 3rd LEFT layer

;##########################################

do_3rdwall_l:

        push de                 ;save the current acreen position
;1st check if theres a wall where we need to draw the black side

       dec de
        dec de
        dec de
        dec de
        dec de
        dec de
        
        
;now draw a red wall to the left of section 2,  top half

        ld a,_smallwall;$8e                ;8e - 3rd wall graphic
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
        jp z,_x1r_3l               ;if yes, do NOT draw a black side.
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

_x1r_3l:
        dec de
        dec de
        dec de
        dec de
        
        ld   hl,$0021           ;jump to the next line below + 1 char right
        add  hl,de
        ld a,_smallwall;$8e
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
        jp z,_x2r_3l
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
        
_x2r_3l  pop de
        jp go_back5              ; jump back to main loop

;##########################################

;draw the wall for 4th (and last!) LEFT layer

;##########################################

do_4thwall_l:

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

        ld a,_smallwall;$8d
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
        cp _smallwall;$8e                 ;is it a wall
        jp z,_x1r_31_l               ;if yes, do NOT draw a black side.
;        dec de
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

_x1r_31_l
 ld   hl,$0021           ;jump to the next line below + 1 char right
        add  hl,de

        ld a,_smallwall;$8d
        ld (hl),a
        dec hl
        ld (hl),a

        inc hl
        
        
;now check if we need to draw a black side on the left of the lower half wall
;do this by checking if the next block is already a wall just like above

        inc hl      ;look at the left block
        ld a,(hl)
        dec hl
        cp _smallwall;$8e           ;is there a bottom wall5 here?
        jp z,_x2r_31_l

     ;  dec hl
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
        
_x2r_31_l  pop de
        jp go_back5              ; jump back to main loop


;############################################
;############################################
;draw LEFT layer 4
;############################################
;############################################

draw_4
;    ret
; hl=maze location being drawn.
; now determine what to draw for this section.


        ld hl,(furthest_point)  ;load our last furthest point

        call load_de            ;get left and right and front jump into de reg
        add hl,de               ;jump backwards along the user view 1 space
        ld (furthest_point),hl  ;re save it

;we should also move our pointer left to read where the walls are.
;this will be from this point onwards as we can see the blocks more fully

        ld de,$ffff              ;to move the printed position -3
        ld (var4),de            ;as block is 3 chars wide

;we need to move pointer 1 to the left for wall checking
        ld de,(left)
        add hl,de
        ld (var6),hl ;re save it


        ld (var3),de
        ld de,$0151            ; offset to row 10 column 16 - left of  centre of the 3d view.
        call do_draw_4
        

        jp draw_3              ;now draw the 4th level

do_draw_4:

        ld hl,(d_file)         ; fetch the location of the display file.
        add hl,de


        ld b,4                 ; count for 3 blocks left of display file
                               ; 0 is not counted so loops 3 times
        ld de,(var6)           ; retrieve the maze location.

        ex de,hl

;       hl = furthest point in the maze
;       de = d_file location to store byte to display

loop9:
        push hl

;#############################################################################
;see if h is ouside the current maze 256 byte boundary - if so draw a wall.

        ld a,(maze_highbyte)
        cp h                    ;are weoutside of our maze?
        jp z,cont_5 

         ;if we are on a different maze boundary
                                ;then draw a maze wall as we are the top
                                ;or north wall but maze data has no
                                ;wall data.

;4 = 1st LEFT wall
;3 = 2nd LEFT wall
;2 = 3rd LEFT wall
;1 = 4th LEFT wall
        
        ld a,b                  ;our current wall counter
        cp 4
        jp nz,a4_1              ;its not a wall
        ld a,1
        ld b,a                  ;make the bc count 1 so we only draw 1 wall
        add a,128               ;make sure we set a wall!
        jp draw_9               ;draw the 1st block to the left

;        ld a,b
a4_1:   cp 3
        jp nz,a4_2              ;its not wall 
        ld a,1
        ld b,a                  ;make the bc count 1 so we only draw 1 wall
        add a,128               ;make sure we set a wall!
        jp draw_9_2L           ;draw the 2nd block to the left

a4_2:   cp 2
        jp nz,a4_3              ;its not wall 
        ld a,1
        ld b,a                  ;make the bc count 1 so we only draw 1 wall
        add a,128               ;make sure we set a wall!
        jp draw_9_3L           ;draw the 3rd block to the left

;a must = 1 if we get here.
a4_3:   ld a,1
        ld b,a                  ;make the bc count 1 so we only draw 1 wall
        add a,128               ;make sure we set a wall!
        jp draw_9_4L           ;draw the 4th block to the left

;############################################################################


;now check if we are on the south wall and frig it to draw the
;walls we need.
;reg a already contains l

;cont_4s:


cont_5:
        ld a,(hl)
        rla
        jp c,do_wall4            ;bit 7 (128)

 ;       call do_no_wall4         ; otherwise draw no wall

go_back4: 
        ld hl,(var4)            ;used for left and right drawing
        add hl,de
        ex de,hl
        pop hl
        push de
        ld de,(var3)            ;hold address of next block in the maze we test
        add hl,de               ; move to the start of the next block to print
                                ;we need to move back 4 blocks
                                ;as the first block obscures the view
                                ;of the next 3 blocks.
        pop de
        djnz loop9
        ret

do_wall4:

draw_4s:

;Draw wall based on b count

wall4L_start:

        ld a,b
        sub 1                   ;4th wall  to the left
        jp z,draw_9_4L

        ld a,b
        sub 2                   ;3rd wall to the left
        jp z,draw_9_3L

        ld a,b
        sub 3                   ;2nd wall immediately wall to the left
        jp z,draw_9_2L

        ld a,b
        sub 4                   ;1st wall immediately wall to the left
        jp z,draw_9

        pop hl
        ret

draw_9:  
        push bc
        push de                 ;save our display pointer
        ld b,4                  ;block is 4 blocks high
        ld   hl,$0021           ;load with 32 to jump to line below us
        dec de

loop10: ld   a,_mediumwall_1      ;grey sides facing us
        ld (de),a               ; insert thepart of the wall.
        inc de
        ld (de),a               ;put grey side to our right
        inc de
        ld (de),a
        inc de
        ld (de),a
        dec de
        dec de
        dec de                  ;go left 1 again
        ex de,hl
        add  hl,de              ; advance to the next row of the display file.
        ex de,hl
        djnz loop10             ;do this 3 times

        ;now draw the blank face
        pop de                  ;back to our original position
        push de
        inc de
        inc de                  ;move ahead 3 spaces in the display
        inc de
;        inc de

;check if the char to our right is a wall block.
;if so, do not draw a black face as we need to hide it or it will
;ovewrite the already drawn block

        ld a,(de)
        cp _mediumwall_1        ;is there an already drawn screen block here?
        jp nz,cont_1            ;there is no block so draw black edge
        pop de
        pop bc
        jr go_back4             ;otherwise quit this draw

cont_1  ex  de,hl
        ld de,$0021
        ld  a,_topcorner4      ;triangle sloping to right bottom
        ld  (hl),a
        add hl,de
        ld  a,_black      ;triangle sloping to right bottom
        ld  (hl),a
        add hl,de
        ld  a,_black      ;triangle sloping to right bottom
        ld  (hl),a
        add hl,de
        
        ld  (hl),a
        ld  a,_topcorner1
        ld  (hl),a
        pop de
        pop bc
        jr go_back4              ; jump back to main loop

;************************************
;*Draw the 2nd LEFT block of section 4
;************************************

draw_9_2L:  
        push bc
        ld hl,$ffff                 ;move start point (-1) `to correct position
        add hl,de
        ex de,hl
        push de

;now draw the 2nd wall itself
        ld b,4                  ;block is 4 blocks high
        ld hl,$0021           ;load with 32 to jump to line below us
        ld a,_mediumwall_1      ;grey sides facing us

loop10r_2L:
        ld (de),a             ; insert thepart of the wall.
        dec de
        ld (de),a               ;put grey side to our right
        dec de
        ld (de),a
        dec de
        ld (de),a
        dec de
        ld (de),a
        inc de        
        inc de
        inc de
        inc de                  ;go left 1 again
        ex de,hl
        add  hl,de              ; advance to the next row of the display file.
        ex de,hl
        djnz loop10r_2L             ;do this 3 times

        ;now draw the blank face
        pop de                  ;back to our original position
        push de
        inc de                  ;move left 3 space left in the display
        inc de
        inc de

;check if the char to our right is a wall block.
;if so, do not draw a black face as we need to hide it or it will
;ovewrite the already drawn block

        ld a,(de)
        cp _mediumwall_1        ;is there an already drawn screen block here?
        jp nz,cont_1r_2L           ;there is no block so draw black edge
        pop de
        pop bc
        jp go_back4             ;otherwise quit this draw

cont_1r_2L:
        ex  de,hl
        ld de,$0021

;need to loop 2 times drawing 2 lots of 3 top
;& bottom chars- move down 1after 1st 3 top chars drawn
;
        
        ld a,2
        ld (var7),a             ;save initial count for 2 draws        

;loop for 2 black wall columns
        ld a,3                  ;column start height
        ld (var1),a             ;save the count for the column hight minus the top corners

        ld b,3                  ;loop 3 times for 3 columns
        ld (var5),hl            ;address of first face block after corner chamfer
        ld a,$97
        ld (var2),a             ;ld var2 with top right sloping corner black
        
loop10br_2L:
        push bc                 ;save count        
        ld a,(var1)             ;column height
        ld b,a                  ;holds the column height in chars
        ld  a,(var2)            ;triangle sloping to right bottom
        push af                 ;save a for bottom corners
        ld  (hl),a
        
loop10ar_2L:                   
        add hl,de
        ld  a,_black            ;black wall fill
        ld  (hl),a              ;draw 6 black blocks and3 edges
        djnz loop10ar_2L

        pop af                  ;retrivetop corner
        dec a                   ;prep for next top corner
        ld (var2),a             ;re-save it for next corner
        add a,4                 ;get the correct char to print
        ld  (hl),a              ;draw the bottom of the wall

        ;now change column count
        ld a,(var1)
        pop bc

        ld hl,(var5)
        dec hl                  ;move print position to the left
        ld (var5),hl
               
        djnz loop10br_2L

        pop de
        pop bc
        jp go_back4             ; jump back to main loop   

;#############################################
;*Draw the 3rd LEFT block of section 4
;#############################################

draw_9_3L:  
        push bc
        push de                 ;save our display pointer
        ld b,4                  ;block is 4 blocks high
        ld hl,$0021             ;load with 32 to jump to line below us
        ld de,$C162-24              ;start of drawing

loop10r_3L:
        ld a,_mediumwall_1      ;grey sides facing us
        ld (de),a               ; insert thepart of the wall.
        ex de,hl
        add  hl,de              ; advance to the next row of the display file.
        ex de,hl
        djnz loop10r_3L             ;do this 3 times

        ;now draw the blank face
        pop de                  ;back to our original position
        push de
        
;check if the char to our right is a wall block.
;if so, do not draw a black face as we need to hide it or it will
;ovewrite the already drawn block

        ld a,(de)
        cp _mediumwall_1        ;is there an already drawn screen block here?
        jp nz,cont_1r_3L            ;there is no block so draw black edge

        pop de
        pop bc
        jp go_back4             ;otherwise quit this draw

cont_1r_3L:
        ex de,hl
        ld de,$0021
        ld hl,$c161-22

;need to loop 2 times drawing 2 lots of 3 top
;& bottom chars- move down 1after 1st 3 top chars drawn
;
        
;loop for 5 black wall columns
        ld a,3                  ;column start height
        ld (var1),a           ;save the count for the column hight minus the top corners

        ld b,5                  ;loop 5 times for 3 columns
        ld (var5),hl            ;address of first face block after corner chamfer
        ld a,$cd ;91
        ld (var2),a             ;ld var2 with top right sloping corner black
        
loop10br_2aL:
        push bc                 ;save count        
        ld a,(var1)             ;column height
        ld b,a                  ;holds the column height in chars
        ld  a,(var2)            ;triangle sloping to right bottom
        push af                 ;save a for bottom corners
        ld  (hl),a
        
loop10ar_2aL:                   
        add hl,de
        ld  a,_black            ;black wall fill
        ld  (hl),a              ;draw 6 black blocks and3 edges
        djnz loop10ar_2aL

        pop af                  ;retrivetop corner
        dec a                   ;prep for next top corner
        ld (var2),a             ;re-save it for next corner
        add a,6                 ;get the correct char to print
        ld  (hl),a              ;draw the bottom of the wall

        ;now change column count
        ld a,(var1)
        pop bc

        ld hl,(var5)
        inc hl                  ;move print position to the right
        ld (var5),hl
               
        djnz loop10br_2aL

        pop de
        pop bc
        jp go_back4              ; jump back to main loop        

;#############################################
;*Draw the 4th LEFT block of section 4
;#############################################

; we only need to draw 2 columns of black sides.

draw_9_4L:  
        push bc
        push de                 ;save our display pointer

;check if the char to our right is a wall block.
;if so, do not draw a black face as we need to hide it or it will
;ovewrite the already drawn block

      ;  ld hl,$C18C+20-30-30              ;start of drawing
        ld hl,$C151-7              ;start of drawing
        ld a,(hl)
        cp _mediumwall_1        ;is there an already drawn screen block here?
        jp nz,cont_3L_l            ;there is no block so draw black edge

        pop de
        pop bc
        jp go_back4r             ;otherwise quit this draw

cont_3L_l:
        ld b,4                  ;block is 4 blocks high
        ld a,$ca
        ld (hl),a        
        inc hl
        dec a
        ld (hl),a 

;need 2 black walls now!
        ld a,_black
        ld de,33;34                ;1 line width

        CALL black_wall_1         ;draw 2 black blocks        
        inc de                        ;jump to next line below

        CALL black_wall_1         ;draw 2 black blocks        
        add hl,de               ;jump to next line below

        
;top half done - so do bottom half - 2 blacks first

;de already holds 34  -1 line plus 2 chars to the right

        ld a,$ce
        ld (hl),a
        dec hl
        inc a
        ld (hl),a
                
        pop de
        pop bc
        jp go_back4

;draw 2 black walls across 1 line
black_wall_1:
        add hl,de      ;jump 1 line below
        ld (hl),a        
        dec hl
        ld (hl),a        
        ret



;#############################################
;#############################################
;# draw LEFT wall 3
;#############################################
;#############################################

draw_3:
;ret
; hl=maze location being drawn.
; now determine what to draw for this section.


        ld hl,(furthest_point)  ;load our last furthest point

        call load_de            ;get left and right and front jump into de reg

        add hl,de               ;jump backwards along the user view 1 space
        ld (furthest_point),hl ;re save it

        ld de,$ffff             ;to move the display position -1
        ld (var4),de

        ld de,(left)            ;move our check position left -1
        add hl,de
        ld (var6),hl
        

        ld (var3),de
        ld de,$10a;10b           ; offset to row 8 column5 - left of  centre of the 3d view.

;2nd block starts at $109 and is 3 wall chars wide
        call do_draw_3
        
        jp draw_2           ;now draw the 2nd level

do_draw_3:

        ld   hl,(d_file)        ; fetch the location of the display file.
        add  hl,de

        
; draw left half of the display.

        ld b,3                 ; count for 1 blocks left of display file
        ld de,(var6)           ; retrieve the maze location.


        ex   de,hl              ; transfer de to hl.

;       hl = furthest point in the maze
;       de = d_file location to store byte to display

loop11:
        push hl

;################################################################        

;see if h is ouside the current maze 256 byte boundary - if so draw a wall.
;and stop drrawing anything else.

        ld a,(maze_highbyte)
        cp h                    ;are we at the top part of the maze?
        jp z,cont_3s 
                                ;if we are on a different maze boundary
                                ;then draw a maze wall as we are the top
                                ;or north wall but maze data has no
                                ;wall data.
;see which wall we are at and draw the correct one before jumping out
;of the loop and stop drawing past the maze wall. 

;3 = first left wall
;2 = 2nd left wall
;1 = 4rd left wall
      
        ld a,b                  ;our current wall counter
        sub 3     
        jp nz,a3                 ;its not wall 1
        ld a,1
        ld b,a
        add a,128               ;make sure we set a wall!
        jp draw_10             ;jump straight to making an end wall


a3:     ld a,b                  ;our current wall counter
        sub 2     
        jp nz,a3_1                 ;its not wall 1
        ld a,1
        ld b,a                  ;make the bc count 1 so we only draw 1 wall
        add a,128               ;make sure we set a wall!
        jp draw_10_2L	       	;draw the 2nd wall to the right

a3_1:   ld a,1
        ld b,a                  ;make the bc count 1 so we only draw 1 wall
        add a,128               ;make sure we set a wall!
        jp draw_10_3L	       	;draw the 2nd wall to the right

;################################################################        
        

;now check if we are on the south wall and frig it to draw the
;walls we need.
;reg a already contains l

cont_3s:
;        ld a,l
;        cp $FA  ;250
;        jp nz,cont_6
;        ld l,240                ;fake it that we are at
;        jp draw_10             ;the south wall


cont_6: ld a,(hl)
        rla
        jp c,do_wall3            ;bit 7 (128)

       ; call do_no_wall3         ; otherwise draw no wall

go_back3: 
      ;  ld hl,(var4)            ;used for left and right drawing
      ;  add hl,de               ; holds current screen position
      ;  ex de,hl
;we move the start position of block number 2 to the left of the display
;and although we overwrite the next block, we can still do the
;check to see if a block is already drawn.

        ;dec de                  ;move our start print position
        ;dec de                  ;of block 2 back 3 spaces in the
        dec de ;only 1 space back  ;display file
        pop hl
        push de
        ld de,(var3)            ;used for left and right drawing
        add hl,de                ; go left 1 block in the maze
        pop de
        djnz loop11
        ret
;now do the 2nd position



; there is not a wall so insert black to show that the location is too far away to see its detail.

do_wall3:

        ;check if bit 2 is set as thats an end 
        ;and b must then be changed to 1 to stop drawing.

;        bit 1,a                 ; is this a side wall? (129 but we rla'd accu)
;        jr z,draw_10
;        ld b,1                  ;set b so we exit on return

;now draw the wall based on bc value
;wall3_start:


        ld a,b			               ;b is the loop count i.e # of walls to draw
       	sub 3			               ;3 = the wall imediately right
        jp z,draw_10          ;draw an end wall if blockid=16
        
        ld a,b
        sub 2
        jp z,draw_10_2L         		;draw the 1st wall to the right

        ld a,b 
        sub 1
        jp z,draw_10_3L	       	;draw the 2nd wall to the right
        
        pop hl                  ;nothing to draw so return
        ret
        
        
draw_10:  
        push bc
        push de                 ;save our display pointer
        dec de
        dec de
        
        ld b,8                  ;block is 8 blocks high
        ld hl,$0021             ;load with 32 to jump to line below us
        ld a, _mediumwall       ;wall on sides facing us
loop12: ld (de),a               ; insert the part of the wall.
        inc de
        ld (de),a               ; insert the part of the wall.
        inc de
        ld (de),a               ; insert the part of the wall.
        inc de
        ld (de),a               ; insert the part of the wall.
        inc de
        ld (de),a               ; insert the part of the wall.
        inc de
        ld (de),a               ; insert the part of the wall.
        inc de
        ld (de),a
        inc de
        ld (de),a
        dec de
        dec de
        dec de
        dec de
        dec de
        dec de
        dec de
        ex de,hl
        add  hl,de              ; advance to the next row of the display file.
        ex de,hl
        djnz loop12             ;do this 3 times

        ;now draw the blank face to the right of the block
        ;create first column of right face characters
        pop de                  ;back to our original position
        push de
        inc de
        inc de
        inc de
        inc de                  ;move ahead 5 spaces in the display (right)
        inc de
        inc de

    ;    inc de
    ;    inc de
    ;    inc de
;check if the char to our right is a wall block.
;if so, do not draw a black face as we need to hide it or it will
;ovewrite the already drawn block
;jp cont_2
        ld a,(de)
        cp _mediumwall        ;is there an already drawn screen block here?
        jp nz,cont_2            ;there is no block so draw black edge
        pop de
        pop bc
        jr go_back3             ;otherwise quit this draw

cont_2: ex  de,hl
        ld de,$0021
        
;loop for 2 columns

        ld b,2                  ; loop 2 times for 2 columns
        ld (var5),hl            ;address of first face block after corner chamfer
        ld a,7
        ld  (var1),a            ;save the count for the column hight minus the top corners

loop12b:
        push bc                 ;save count        
        ld a,(var1)
        ld b,a                  ;holds the column height in chars
        ld  a,_topcorner4      ;triangle sloping to right bottom
        ld  (hl),a
        
loop12a:                   ;we must start at 5 to draw 4 face blocks on right
        add hl,de
        ld  a,_black      ;triangle sloping to right bottom
        ld  (hl),a              ;draw 6 black blocks and 2 edges
        djnz loop12a

        
        ld  a,_topcorner1
        ld  (hl),a

        ;now change column count
        ld a,(var1)
        sub 2                   ;subtract 2
        ld (var1),a
        pop bc

        ld hl,(var5)
        inc hl                  ;move print position to the right
        ld de,$21               ;move top of next column down and across 1
        add hl,de
        ld (var5),hl
               
        djnz loop12b
        pop de
        pop bc
        jp go_back3              ; jump back to main loop


;#############################################
;     draw the 2nd LEFT block
;#############################################

draw_10_2L:  

         push bc
         ld de, $c110-17          ;start print position of wall
        push de
;dont draw a front wall as we never see it.

        ld hl,8                 ;move 8 blocks over to start position
        add hl,de
        ex de,hl
;we do not need a front wall for this row as it is never seen.
;below jp code can be removed :) Because a square block here
;is 8 x 8

        inc de                  ;move ahead 1 space in the display (right)

;check if the char to our left is a wall block.
;if so, do not draw a black face as we need to hide it or it will
;ovewrite the already drawn block
         ld a,(de)
         cp _mediumwall        ;is there an already drawn screen block here?
         jp nz,cont_2r_2L            ;there is no block so draw black edge
         pop de
         pop bc
         jp go_back3             ;otherwise quit this draw


;draw the black edge wall

cont_2r_2L:
         ex  de,hl
         ld de,$0021

;need to loop 2 times drawing 2 lots of 3 top
;& bottom chars- move down 1after 1st 3 top chars drawn
;
        
        ld a,2
        ld (var7),a             ;save initial count for 2 draws        

;loop for 3 black wall columns
        ld a,7                  ;column start height
        ld  (var1),a            ;save the count for the column hight minus the top corners

loop_xL:ld b,3                  ;loop 3 times for 3 columns
        ld (var5),hl            ;address of first face block after corner chamfer
        ld a,$95
        ld (var2),a             ;ld var2 with top right sloping corner black
        
loop12br_2L:
        push bc                 ;save count        
        ld a,(var1)             ;column height
        ld b,a                  ;holds the column height in chars
        ld  a,(var2)            ;triangle sloping to right bottom
        push af                 ;save a for bottom corners
        ld  (hl),a
        
loop12ar_2L:                   
        add hl,de
        ld  a,_black            ;black wall fill
        ld  (hl),a              ;draw 6 black blocks and3 edges
        djnz loop12ar_2L

        pop af                  ;retrivetop corner
        inc a                   ;prep for next top corner
        ld (var2),a             ;re-save it for next corner
        add a,2;4                 ;get the correct char to print
        ld  (hl),a              ;draw the bottom of the wall

        ;now change column count
        ld a,(var1)
        pop bc

        ld hl,(var5)
        inc hl                  ;move print position to the left
        ld (var5),hl
               
        djnz loop12br_2L

;1st set of 3 top bits drawn
;now jump down the display 1 line
;then draw another 3 columns

        ld a,(var7)             ;get our loop counter
        dec a
        jr z,exit_1L             ;exit after 2 loops
        ld (var7),a             ;save it
        ld hl,(var5)
;get our last print position
                                ;need to go to next line -1 char
        add hl,de
                                ; now move back in the display
                                ;1 char     
        ld (var5),hl            ;re save it for use above

        ld a,5                  ;reduce black wall column height
        ld  (var1),a            ;save the count for the column hight minus the top corners
        
        jp loop_xL


exit_1L: pop de
        pop bc
        ld b,1                  ;if we draw this wall, we need to stop drawing any more walls
        
        jp go_back3              ; jump back to main loop

;#############################################
;*Draw the 3rd LEFT block of section3
;#############################################

; we only need to draw 2 columns of black sides.
; if theres no brick pattern !

draw_10_3L:  
        push bc
        push de                 ;save our display pointer

        ld hl,$C18C-66-30-3              ;start of drawing
        ld a,(hl)               ;read what char is there
        cp _mediumwall      
        jr nz,cont_1r_4L        ;exit if a wall is already there
        pop de
        pop bc
        jp go_back4             ;otherwise quit this draw
        
cont_1r_4L:

        ld a,$c9
        ld (hl),a        

        ld a,_black
        ld de,33                ;1 line width

        CALL black_wall         ;draw 4 black blocks        

        add hl,de               ;jump to next line below

        
;top half done - so do bottom half - 2 blacks first

;de already holds 32

        ld a,$ce
        ld (hl),a
                
        pop de
        pop bc
        jp go_back3

;draw 2 black walls across 1 line
black_wall:
        add hl,de      ;jump 1 line below
        ld (hl),a        
        add hl,de      ;jump 1 line below
        ld (hl),a        
        add hl,de      ;jump 1 line below
        ld (hl),a        
        add hl,de      ;jump 1 line below
        ld (hl),a        


        ret



;#############################################
;#############################################
; draw 2nd layer
;#############################################
;#############################################

draw_2:
;
;ret
; hl=maze location being drawn.
; now determine what to draw for this section.


        ld hl,(furthest_point)  ;load our last furthest point

        call load_de            ;get left and right and front jump into de reg

        add hl,de               ;jump backwards along the user view 1 space
        ld (furthest_point),hl ;re save it

        ld de,$ffff             ;to move the display position -1
        ld (var4),de

        ld de,(left)

;we need to move pointer 1 to the left for wall checking
        add hl,de
        ld (var6),hl ;re save it

        ld (var3),de

        ld  de,$a4           ; offset to row10 column 7 - left of  centre of the 3d view.
        call do_draw_2
        
        jp draw_1           ;now draw the 2nd level

do_draw_2:

        ld   hl,(d_file)        ; fetch the location of the display file.
        add  hl,de

        
; draw left half then right half of the display.

        ld b,1                 ; count for 2 blocks left or right of display file
                                ; 0 is not counted so loops 12 times
        ld   de,(var6); retrieve the maze location.
        ex   de,hl              ; transfer de to hl.

;       hl = furthest point in the maze
;       de = d_file location to store byte to display

loop14: push hl

;see if h is ouside the current maze 256 byte boundary - if so draw a wall.

        ld a,(maze_highbyte)
        cp h                    ;are we at the top part of the maze?
        jp z,cont_2s 
                                ;if we are on a different maze boundary
                                ;then draw a maze wall as we are the top
                                ;or north wall but maze data has no
                                ;wall data.
 
        ld a,1
        ld b,a                  ;make the bc count 1 so we only draw 1 wall
        add a,127               ;make sure we set a wall!
        jp do_wall2             ;jump straight to making an end wall
        
;*#########################################
cont_2s:
        ld a,(hl)
        rla
        jp c,do_wall2            ;bit 7 (128)

       ; call do_no_wall2         ; otherwise draw no wall

go_back2: 
        ld hl,(var4)            ;used for left and right drawing
        add hl,de               ; holds current screen position
        ex de,hl
        pop hl
        push de
        ld de,(var3)            ;used for left and right drawing
        add hl,de                ; go left 1 block in the maze
        pop de
        djnz loop14
        ret
;now do the 2nd position


do_wall2:
        ;check if bit 2 is set as thats an end 
        ;and b must then be changed to 1 to stop drawing.

        bit 1,a                 ; is this a side wall? (129 but we rla'd accu)
        jr z,draw_11
        ld b,1                  ;set b so we exit on return

draw_11:  
                     ; draw the wall face bit
        push bc
        push de
        inc de
                       ;save our display pointer
        ld b,14                  ;block is 14 blocks high
        ld   hl,$0021           ;load with 32 to jump to line below us
        ld   a,_largewall            ;wall on sides facing us
loop13: 
        ld (de),a             ; insert the part of the wall.
        inc de
        ld (de),a               ;put grey side to our right
        inc de
        ld (de),a               ;put grey side to our right
        inc de
        ld (de),a               ;put grey side to our right
        inc de
        ld (de),a               ;put grey side to our right
        dec de
        dec de
        dec de
        dec de
        ex de,hl
        add  hl,de              ; advance to the next row of the display file.
        ex de,hl
        djnz loop13             ;do this 3 times

        ;now draw the blank face to the right of the block
        ;create first column of right face characters
        pop de                  ;back to our original position
        inc de
        inc de
        inc de                  ;move ahead 6 spaces in the display (right)
        inc de
        inc de
        inc de
        ex  de,hl
        ld de,$0021

        ld b,3                  ; for 8 face columns to draw to draw
        ld (var5),hl
        ld a,13                 ; for 14 blocks high per column
        ld (var1),a

loop13b:
        push bc
        ld a,(var1)
        ld b,a
        ld a,_topcorner4
        ld (hl),a
        
loop13a:
        add hl,de
        ld  a,_black  ;leftinnerwall  ;black      ;triangle sloping to right bottom
        ld  (hl),a              ;draw 14 black blocks and 3 edges
        djnz loop13a
        
        ;ld  (hl),a
        ld  a,_topcorner1
        ld  (hl),a
        
; now change the column count
        ld a,(var1)
        sub 2
        ld (var1),a
        pop bc

        ld hl,(var5)
        inc hl
        ld de,$21
        add hl,de
        ld (var5),hl

        djnz loop13b

        pop bc
        jp go_back2              ; jump back to main loop


;#############################################
; draw 1st layer
;#############################################

draw_1:

;ret
; hl=maze location being drawn.
; now determine what to draw for this section.


        ld hl,(furthest_point)  ;load our last furthest point

        call load_de            ;get left and right and front jump into de reg

        add hl,de               ;jump backwards along the user view 1 space
        ld (furthest_point),hl ;re save it

        ld de,$ffff             ;to move the display position -1
        ld (var4),de

        ld de,(left)

;we need to move pointer 1 to the left for wall checking
        add hl,de
        ld (var6),hl
        
        ld (var3),de
        ld  de,$020           ; offset to row 1 column 0 - left of  centre of the 3d view.
        call do_draw_1
        
        jp draw_0           ;now draw the 2nd level

do_draw_1:

        ld   hl,(d_file)        ; fetch the location of the display file.
        add  hl,de

        
; draw left half then right half of the display.

        ld b,1                 ; count for 2 blocks left or right of display file
                                ; 0 is not counted so loops 12 times
        ld   de,(var6); retrieve the maze location.
        ex   de,hl              ; transfer de to hl.

;       hl = furthest point in the maze
;       de = d_file location to store byte to display

loop15: push hl

;see if we are at the north wall. If we dont, we get a left wall
;drawn because we implicitly draw a wall if we are at the top

;        ld a,(player_dir)
;        cp 2                    ;r we looking south
;        jp z,cont_7
;        ld a,l
;        cp 17
;        jp c,do_wall1

;see if h is ouside the current maze 256 byte boundary - if so draw a wall.

        ld a,(maze_highbyte)
        cp h                    ;are we at the top part of the maze?
        jp z,cont_7 
                                ;if we are on a different maze boundary
                                ;then draw a maze wall as we are the top
                                ;or north wall but maze data has no
                                ;wall data.
 
        ld a,1
        ld b,a                  ;make the bc count 1 so we only draw 1 wall
        add a,127               ;make sure we set a wall!
        jp do_wall1             ;jump straight to making an end wall
        
;#########################################################

cont_7: ld a,(hl)
        rla
        jp c,do_wall1            ;bit 7 (128)

       ; call do_no_wall1         ; otherwise draw no wall

go_back1: 
        ld hl,(var4)            ;used for left and right drawing
        add hl,de               ; holds current screen position
        ex de,hl
        pop hl
        push de
        ld de,(var3)            ;used for left and right drawing
        add hl,de                ; go left 1 block in the maze
        pop de
        djnz loop15

;jp draw_0
        ret
;now do the 2nd position



; there is not a wall so insert black to show that the location is too far away to see its detail.

do_wall1:
        ;check if bit 2 is set as thats an end 
        ;and b must then be changed to 1 to stop drawing.

        bit 1,a                 ; is this a side wall? (129 but we rla'd accu)
        jr z,draw_12
        ld b,1                  ;set b so we exit on return

;draw the corridor bit to the left (1 column)
draw_12:  
        push bc
        push de                 ;save our display pointer
        ld b,22                  ;block is 22 blocks high
        ld   hl,$0021           ;load with 32 to jump to line below us
        ld   a,_hugewall;_largewall            ;wall on sides facing us
loop16: ld   (de),a             ; insert thepart of the wall.
        inc de
        ld (de),a               ;put grey side to our right
        ;inc de
        ;ld (de),a               ;put grey side to our right
        ;inc de
        ;ld (de),a               ;put grey side to our right
        ;inc de
        ;ld (de),a               ;put grey side to our right
        ;dec de
        ;dec de
        ;dec de
        dec de
        ex de,hl
        add  hl,de              ; advance to the next row of the display file.
        ex de,hl
        djnz loop16             ;do this 3 times

        ;now draw the blank face to the right of the block
        ;create first column of right face characters
        pop de                  ;back to our original position
        ;inc de
        ;inc de
        ;inc de                  ;move ahead 4 spaces in the display (right)
        inc de
        inc de
        ex  de,hl
        ld de,$0021

;now draw the face we see on our left as we walk forward
        ld b,4                  ; for 8 face columns to draw to draw
        ld (var5),hl
        ld a,21                 ; for 14 blocks high per column
        ld (var1),a

loop14b:
        push bc
        ld a,(var1)
        ld b,a
        ld a,_topcorner4
        ld (hl),a
        
loop14a:
        add hl,de
        ld  a,_black            ;triangle sloping to right bottom
        ld  (hl),a              ;draw 14 black blocks and 3 edges
        djnz loop14a
        
        ;ld  (hl),a
        ld  a,_topcorner1
        ld  (hl),a
        
; now change the column count
        ld a,(var1)
        sub 2
        ld (var1),a
        pop bc

        ld hl,(var5)
        inc hl
        ld de,$21
        add hl,de
        ld (var5),hl

        djnz loop14b

        pop bc
        jr go_back1              ; jump back to main loop

;        jp draw_1               ;draw next layer
        
; there is a wall so insert chequerboard for the wall face.

;do_no_wall1:
;        ret ; no wall so do nothing
;        push de
;        ld   a,_topwhitebottomchequer
;        ld   (de),a                             ; insert the top of the wall face.
;        ld   hl,$0021
;        add  hl,de                              ; advance to the next row of the display file.
;        ld   (hl),_topchequerbottomwhite        ; insert the bottom of the wall face.
;        pop de
;        ret




;#############################################
; draw layer 0
;#############################################

draw_0:
;ret


; hl=maze location being drawn.
; now determine what to draw for this section.


        ld hl,(furthest_point)  ;load our last furthest point

        call load_de            ;get left and right and front jump into de reg

        add hl,de               ;jump backwards along the user view 1 space

;move map pointer left to read the walls
;;        ld de,(left)
;;        add hl,de



;;        ld (furthest_point),hl ;re save it

;        ld de,$ffff             ;to move the display position -1
;        ld (var4),de

        ld de,(left)

;we need to move pointer 1 to the left for wall checking
        add hl,de
        ld (var6),hl
        
        ld (var3),de
        ld  de,$00              ;offset to row0 column 0 - left of  centre of the 3d view.
                                ;1 column of left face to draw
    ;    call do_draw_0
        

do_draw_0:

        ld   hl,(d_file)        ; fetch the location of the display file.
        add  hl,de

        
; draw left half then right half of the display.

        ld b,1                 ; count for 2 blocks left or right of display file
        ld de,(var6)           ; 0 is not counted so loops 12 times
       ; ld   de,(furthest_point); retrieve the maze location.
        ex   de,hl              ; transfer de to hl.

;       hl = furthest point in the maze
;       de = d_file location to store byte to display

loop17: ;push hl


;check if we are at the north wall

;see if h is ouside the current maze 256 byte boundary - if so draw a wall.

        ld a,(maze_highbyte)
        cp h                    ;are we at the top part of the maze?
        jp z,cont_4
                                ;if we are on a different maze boundary
                                ;then draw a maze wall as we are the top
                                ;or north wall but maze data has no
                                ;wall data.
 
        ld a,1
        ld b,a                  ;make the bc count 1 so we only draw 1 wall
        add a,127               ;make sure we set a wall!
        jp draw_13             ;jump straight to making an end wall

;##########################################

cont_4: ld a,(hl)
        rla
        jp c,do_wall0            ;bit 7 (128)

        ret



do_wall0:
        ;check if bit 2 is set as thats an end 
        ;and b must then be changed to 1 to stop drawing.

        bit 1,a                 ; is this a side wall? (129 but we rla'd accu)
        jp c,draw_13

        jp draw_brick_l         ; otherwise draw no wall

;we need to draw 1 vertical line from pos 1,1 to show
;the side of the block.

;draw the sidewall brick pattern
draw_13:  
        ld a,_topcorner4
        ld (de),a
        ld hl,$21                ;jp to next line below
        add hl,de
        ex de,hl

        ld b,22                  ;block is 24 blocks high
        ld hl,$021           ;load with 32 to jump to line below us
        ld a,_black            ;wall on sides facing us;
loop18: ld (de),a             ; insert the part of the wall.
        ex de,hl
        add  hl,de              ; advance to the next row of the display file.
        ex de,hl
        djnz loop18

        ld a,_topcorner1
        ld (de),a
        ret

draw_brick_l:  
        ld hl,$21                ;jp to next line below
        add hl,de
        ex de,hl

        ld b,22                  ;block is 24 blocks high
        ld hl,$021
                           ;load with 32 to jump to line below us
        ld a,_hugewall;_largewall            ;wall on sides facing us;
loop18l:
        ld (de),a             ; insert the part of the wall.
        ex de,hl
        add  hl,de              ; advance to the next row of the display file.
        ex de,hl
        djnz loop18l

        ret
