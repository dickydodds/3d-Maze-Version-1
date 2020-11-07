
;############################################
;############################################

;draw section the right side of the screen

;############################################
;############################################

draw_right_side:

              ld a,(depth)
              cp 6          
              jp z,draw_6r
do_5r:        cp 5
              jp z,draw_5r
              cp 4
              jp z,draw_4r
              cp 3
              jp z,draw_3r
              cp 2
              jp z,draw_2r
              cp 1
              jp z,draw_1r
              jp draw_0r
;end of routine
          ;    ret

;############################################
;############################################

;draw section 6 right - well, nothing to do atm!

;############################################
;############################################

draw_6r:
;do nothing on screen as already done via left side draw
;just incremement where we are in the maze view

        ld hl,(furthest_point)  ;load our last furthest point
        call load_de            ;get left and right and front jump into de reg
        add hl,de               ;Additional add to simulate layer 6
        ld (furthest_point),hl ;re save it

;############################################
;############################################

;draw section 5 right

;############################################
;############################################

draw_5r:
 
;ret
; hl=maze location being drawn.
; now determine what to draw for this section.

        sub a                   ;make 'a' zero
        dec a                   ;make it 255 to show nothing to do
        ld (blockid),a          ;save it for wall drawing

;first we need to decrement how far we can see to the layer
;we are working on

        ld hl,(furthest_point)  ;load our last furthest point
        call load_de            ;get left and right and front jump into de reg

        add hl,de               ;Additional add to simulate layer 6
        ld (furthest_point),hl ;re save it

        ld de,$0001             ;to move the display position +1
        ld (var4),de

;move the maze location pointer 1 to the right - used for all
;remaining blocks to test if there is a wall there or not.

        ld de,(right)
        add hl,de
        ld (var6),hl            ;right position in maze from our location

        ld (var3),de            ;display position +1
        ld   de,$0179           ; offset to row 11 column 10 - left of  centre of the 3d view.
        call do_draw_5r

        sub a                   ;make reg a zero
        ld (var10),a            ;used in the maze wall drawing at layer 5
        ld a,(blockid)          ;get the right hand maze wall location
        inc a                   ;if blockid was 255 (UNUSED) its will now be zero
                                ;so 
        jp draw_4r              ;now draw the 4th level

do_draw_5r:

        ld   hl,(d_file)        ; fetch the location of the display file.
        add  hl,de

        
; draw right half of the display.

        ld b,4                  ; count for 3 columns right of our position
        ld de,(var6)            ; retrieve the maze location.

;check if we are at the bottom right of the maze
;if so, there is no wall after position 255 so point us to
;position 240 and fake the wall!
;;;        ld a,e
;;;        cp 255
;;;        jp nz,cont_3  ;continue if we are not at position 255
;;;        ld e,240      ;fake where we are so we draw a wall :)


;now move the maze pointer right (+1) 1 position
;so we can read the type of walls to our left
        
;cont_3:
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

;2020 - we dont need to do this as we are drawing
;a side wall and wont see the hashes!

        ld a,_smallwall;_topright5          ; load with top right char $a9
;        ld a,'#'
        ld (var1),a             ;top of mwadd udg
;        inc a
;        inc a
;        ld a,_smallwall;_topright5          ; load with top right char $a9
        
        ld (var2),a             ;ld with bottom right wall udg char

loop8r:
        push hl

;##############################################################################
;see if h is ouside the current maze 256 byte boundary - if so draw a wall.

        ld a,(maze_highbyte)
        cp h                    ;are we at the top part of the maze?
        jp z,cont_5a 
                                ;if we are on a different maze boundary
                                ;then draw a maze wall as we are the top
                                ;or north wall but maze data has no
                                ;wall data.
                                ;wall data.
;4 = 1st left wall
;3 = 2nd left wall
;2 = 3rd left wall
;1 = 4th left wall
        
        ld a,b                  ;our current wall counter
        cp 4
        jp nz,b5_1                 ;its not wall 4
        ld a,1
        ld b,a
        add a,128               ;make sure we set a wall!
        jp  do_wall5a          ;jump straight to making an end wall

b5_1:   cp 3
        jp nz,b5_2             ;its not wall 3
        ld a,1
        ld b,a                  ;make the bc count 1 so we only draw 1 wall
        add a,128               ;make sure we set a wall!
        jp do_2ndwall_r        ;draw the 2nd block to the left

b5_2:   cp 2
        jp nz,b5_3             ;its not wall 3
        ld a,1
        ld b,a                  ;make the bc count 1 so we only draw 1 wall
        add a,128               ;make sure we set a wall!
        jp do_3rdwall_r       ;draw the 2nd block to the left

;a must = 1 if we get here.
b5_3:   ld a,1
        ld b,a                  ;make the bc count 1 so we only draw 1 wall
        add a,128               ;make sure we set a wall!
        jp do_4thwall_r         ;jump straight to making an end wall
        
;*############################################################################

;now zero out the end wall variable
cont_5a
        sub a                   ;zero a reg
        ld (end_wall),a           ;save 0 in the end wall variable


;check we are at an outside maze wall
        ld a,(hl)               ;otherwise, check if there is a wall 
        cp _mh                  ;maze wall block
        jr nz,cont10            ;its a wall block so need to draw the wall
        push af                 ;save which print location we are at
        ld a,1                  ;for drawing the maze wall to the screen
        ld (end_wall),a          ;edge
        pop af
;        ld b,1                  ;stop drawing more blocks as its an end wall

cont10: rla
        jp c,do_wall5r          ;bit 7 (128)

;        call do_no_wall5r      ; otherwise draw no wall

go_back5r: 
        ld hl,(var4)            ;used for left and right drawing
        add hl,de               ; holds current screen position
        ex de,hl
        pop hl
        push de
        ld de,(var3)            ;used for left and right drawing
        add hl,de               ; go left 1 block in the maze
        pop de
        djnz loop8r
        ret


do_wall5r:

;check if b=2 - if so we are not at a wall immediately next to our right
;nor are we at an and wall. We are drawing the 2nd block to the right
;b=3 for 3rd block to the right.

        ld a,b
        sub 1
        jp z,do_4thwall_r       ;draw the cnd block to the right

        ld a,b                  ;b is our loop count
        sub 2                   ;check if a=2
        jp z,do_3rdwall_r       ;draw the 2nd block to the right

        ld a,b
        sub 3
        jp z,do_2ndwall_r       ;draw the cnd block to the right
   
;b must = 4 if we get here
 
;check if bit 2 is set as thats an end 
;and b must then be changed to 1 to stop drawing. 
     
do_wall5a:
        bit 1,a                 ; is this a side wall? (129 but we rla'd accu)
        jr z,draw8r

        sub a                  ;we Don't have an outside maze wall (end wall)
        ld (end_wall),a           ;save that we are NOT at an end wall

draw8r:  push de
        ld a,(var1)           ;top of wall udg
        ld (de),a             ; insert the top of the wall.

        inc de
        ld (de),a             ; insert the top of the wall - 2nd right.
        dec de
;now check if we need to draw a black side on the right
;by looking to the character to the right of the wall
;and if there is not a wall already drawn, then draw a
;black side

        ld a,_topright5         ;if not, draw the top left side
        dec de                  ;move to the right of the bricks                 
        ld (de),a               ;draw a black and chevron side
        inc de                  ;go back 1 space again

_x1r:   ld   hl,$0021           ;jump to the next line below

        add  hl,de
        ld a,(var2)             ;draw our wall bottom.
        ld   (hl),a             ; insert the bottom of the wall.
        inc hl
        ld   (hl),a             ; insert the top of the wall. 
        dec hl
        dec hl                  ;look at the left block
        ld a,_bottomright5
        ld (hl),a

_x2r:   pop de


        jr go_back5r              ; jump back to main loop


;************************************

;draw the wall for 2nd right layer

;***********************************

do_2ndwall_r:

        push de                 ;save the current acreen position
;1st check if theres a wall where we need to draw the black side
        ld a,(de)
        cp _smallwall
        jp z,miss5              ;theres a wall drawn already so do not
                                ;draw any black sides & jump over

        ld   a,$91;b9              ;top right section 3 (1)     
        ld   (de),a             ; insert the top of the wall.

;now draw a red wall to the right of section 2
miss5:  inc de
        ld a,_smallwall
        ld (de),a
        inc de
        ld (de),a               ;draw 2nd one (4 wide)
        inc de
        ld (de),a               ;draw 3rd one (4 wide)
;        inc de
;        ld (de),a               ;draw 4th one (4 wide)
                        
 ;       dec de
        dec de
        dec de
        dec de

;now check if we need to draw a black side on the right
;by looking to the character to the right of the wall
;and if there is not a wall already drawn, then draw a
;black side

        dec de                  ;jump left 1 char in the display
        ld a,(de)               ;read whats there
        inc de                  ;put our pointer back to the original position
        cp _smallwall           ;is it a wall
        jp z,_x1r_2               ;if yes, do NOT draw a black side.
        ld a,$90             ;draw top right side
        dec de
        ld (de),a               ;draw middle top bit
        inc de

;top line done

;now do the bottom line underneath

;REMEMBER - 1 block is 2 8 bit squares at the section
_x1r_2
        ld   hl,$0021           ;jump to the next line below + 1 char right
        add  hl,de

;1st check if theres a wall where we need to draw the black side
        ld a,(hl)
        cp _smallwall
        jp z, miss51
        
        ld a,$94                ;draw our rightmost wall bottom.
        ld   (hl),a             ; insert the bottom of the wall.

;now draw a red wall to the right of section 2        
miss51: inc hl
        ld a,_smallwall
        ld (hl),a
        inc hl
        ld (hl),a
        inc hl
        ld (hl),a               ;draw 3rd one (3 wide)
        dec hl                
        dec hl
        dec hl
        
;now check if we need to draw a black side on the left of the lower half wall
;do this by checking if the next block is already a wall just like above

        dec hl      ;look at the left block
        ld a,(hl)
        cp _smallwall           ;is there a bottom wall5 here?
        jp z,_x2r_2
        ld a,$93            ;draw leftmost bottom
        ld (hl),a

_x2r_2  pop de
        jp go_back5r              ; jump back to main loop

;##########################################

;draw the wall for 3rd right layer

;##########################################

do_3rdwall_r:

        push de                 ;save the current acreen position
;1st check if theres a wall where we need to draw the black side
        inc de                  ;move our start location 3 spaces right
        inc de
        inc de

;now draw a red wall to the right of section 2,  top half

        ld a,_smallwall;$8e
        ld (de),a
        inc de
        ld (de),a 
        inc de
        ld (de),a
        inc de
        ld (de),a               ;draw 4th one (4 wide)
        
        dec de                  ;move print position back for black wall
        dec de
        dec de
        
;now check if we need to draw a black side on the right
;by looking to the character to the right of the wall
;and if there is not a wall already drawn, then draw a
;black side

        dec de                  ;jump left 1 char in the display
        ld a,(de)               ;read whats there
        inc de                  ;put our pointer back to the original position
        cp _smallwall           ;is it a wall
        jp z,_x1r_3               ;if yes, do NOT draw a black side.
        ld a,$b9             ;draw top right side
        dec de
        dec de
        dec de
        ld (de),a
        inc de
        inc a
        ld (de),a
        inc a
        inc de
        ld (de),a

         inc de
                                ;to wall start

;top line done

;now do the bottom line underneath

_x1r_3
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
        
        dec hl
        dec hl
        dec hl
        
        
;now check if we need to draw a black side on the left of the lower half wall
;do this by checking if the next block is already a wall just like above

        dec hl      ;look at the left block
        ld a,(hl)
        inc hl
        cp _smallwall           ;is there a bottom wall5 here?
        jp z,_x2r_3
        ld a,$bd            ;draw leftmost bottom
        dec hl
        dec hl
        dec hl
        
        ld (hl),a
        inc hl
        inc a
        ld (hl),a
        inc hl
        inc a                
        ld (hl),a
        
_x2r_3  pop de
        jp go_back5r              ; jump back to main loop

;##########################################

;draw the wall for 4th (and last!) right layer

;##########################################

do_4thwall_r:

;draw top half of wall

        push de                 ;save the current acreen position
;1st check if theres a wall where we need to draw the black side
        inc de
        inc de
        inc de
        inc de
        inc de
        inc de
;now draw a red wall to the right of section 2,  top half

        ld a,_smallwall;$8d
        ld (de),a
        inc de
        ld (de),a 

   
        dec de                  ;move print position back for black wall

;now check if we need to draw a black side on the right
;by looking to the character to the right of the wall
;and if there is not a wall already drawn, then draw a
;black side

        dec de                  ;jump left 1 char in the display
        ld a,(de)               ;read whats there
        inc de                  ;put our pointer back to the original position
        cp _smallwall;$8e                 ;is it a wall
        jp z,_x1r_31               ;if yes, do NOT draw a black side.
        ld a,$b9              ;draw top right side
        dec de
        dec de
        dec de
        dec de
        ld (de),a           ;draw 4 black sides
        inc de
        inc a
        ld (de),a
        inc a
        inc de
        ld (de),a
        inc a
        inc de
        ld (de),a

        inc de              ;move to wall start
                                

;top line done

;now do the bottom line underneath

_x1r_31
 ld   hl,$0021           ;jump to the next line below + 1 char right
        add  hl,de

        ld a,_smallwall;$8d
        ld (hl),a
        inc hl
        ld (hl),a

        dec hl
        
        
;now check if we need to draw a black side on the left of the lower half wall
;do this by checking if the next block is already a wall just like above

        dec hl      ;look at the left block
        ld a,(hl)
        inc hl
        cp _smallwall;$8e           ;is there a bottom wall5 here?
        jp z,_x2r_31

        ld a,$bd            ;draw leftmost bottom
        dec hl
        dec hl
        dec hl
        dec hl
        
        ld (hl),a
        inc hl
        inc a
        ld (hl),a
        inc hl
        inc a                
        ld (hl),a
        inc hl
        inc a                
        ld (hl),a
        
_x2r_31  pop de
        jp go_back5r              ; jump back to main loop

;############################################
;############################################
;draw layer 4 right
;############################################
;############################################

draw_4r


; jump straight into sjasmplus debugger
;        BREAK
;        ret


; hl=maze location being drawn.
; now determine what to draw for this section.


        ld hl,(furthest_point)  ;load our last furthest point

        call load_de            ;get left and right and front jump into de reg

        add hl,de               ;jump backwards along the user view 1 space
        ld (furthest_point),hl  ;load our last furthest point

;we should also move our pointer left to read where the walls are.
;this will be from this point onwards as we can see the blocks more fully

;        ld de,(right)
;        add hl,de               ;should be 1 place to the left now
;        ld (furthest_point),hl ;re save it

        ld de,$0001 ;$0003             ;to move the printed position +3
                                ;not including black wall bit
        ld (var4),de


;we need to move pointer 1 to the right for wall checking
        ld de,(right)
        add hl,de
        ld (var6),hl
        
;        ld de,$0001             ;to move the maze check position +1
                                ;to read the next block we can 'see' on screen

        ld (var3),de
        ld   de,$0159;159       ; offset to row 10 column 19 - right of  centre of the 3d view.
        call do_draw_4r
        

;ret
        jp draw_3r           ;now draw the 4th level

do_draw_4r:

        ld   hl,(d_file)        ; fetch the location of the display file.
        add  hl,de

        ld b,4                 ; count for max of 4 blocks right of maze position
                                ; 0 is not counted so loops 3 times
        ld de,(var6)
        

        ex   de,hl              ; transfer de to hl.

loop9r:
        push hl

;*#########################################
;see if h is ouside the current maze 256 byte boundary - if so draw a wall.

        ld a,(maze_highbyte)
        cp h                    ;are we at the top part of the maze?
        jp z,cont_4a 
                                ;if we are on a different maze boundary
                                ;then draw a maze wall as we are the top
                                ;or north wall but maze data has no
                                ;wall data.
;4 = 1st right wall
;3 = 2nd right wall
;2 = 3rd right wall
;1 = 4th right wall
      
        ld a,b                  ;our current wall counter
        cp 4
        jp nz,b4                 ;its not wall 2
        ld a,1
        ld b,a
        add a,128               ;make sure we set a wall!
        jp draw_9r             ;jump straight to making an end wall

b4:     cp 3
        jp nz,b4_1                 ;its not wall 2
        ld a,1
        ld b,a
        add a,128               ;make sure we set a wall!
        jp draw_9r_2             ;jump straight to making an end wall
        
b4_1:   cp 2
        jp nz,b4_2                 ;its not wall 2
        ld a,1
        ld b,a
        add a,128               ;make sure we set a wall!
        jp draw_9r_3             ;jump straight to making an end wall
        
b4_2:   ld a,1
        ld b,a                  ;make the bc count 1 so we only draw 1 wall
        add a,128               ;make sure we set a wall!
        jp draw_9r_4	       	;draw the 2nd wall to the right

;################################################################        
        
;        ld a,1
;        ld b,a                  ;make the bc count 1 so we only draw 1 wall
;        add a,127               ;make sure we set a wall!
;        jp draw_9r             ;jump straight to making an end wall
        
;*#########################################

cont_4a:
        ld a,(hl)
        rla
        jp c,do_wall4r            ;bit 7 (128)


go_back4r: 
        ld hl,(var4)            ;used for left and right drawing
                                ; holds current screen position
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
        djnz loop9r
        ret
;now do the 4th position



do_wall4r:

        ;check if bit 2 is set as thats an mze boundary 
        ;and b must then be changed to 1 to stop drawing.

do_wall4a:
        bit 1,a                 ; is this a side wall? (129 but we rla'd accu)
        jr z,wall4_start
 ;       ld b,1                  ;set b so we exit on return

;        ld a,(blockid)
;        cp 16
;        jp z,draw_9r            ;draw an end wall if blockid=16
        
;now draw the wall based on bc count

wall4_start:

        ld a,b
        sub 4                   ;4 = 1st wall to the right
        jp z,draw_9r

        ld a,b
        sub 3                   ;3 = 2nd wall immediately to the right
        jp z,draw_9r_2

        ld a,b
        sub 2                   ;2 = 3rd wall immediately to the right
        jp z,draw_9r_3

        ld a,b
        sub 1                   ;1 = 4th wall immediately to the right
        jp z,draw_9r_4

        pop hl
        ret


draw_9r:  
        push bc
        push de                 ;save our display pointer
        ld b,4                  ;block is 4 blocks high
        ld   hl,$0021           ;load with 32 to jump to line below us
loop10r:ld   a,_mediumwall_1      ;grey sides facing us
        ld   (de),a             ; insert thepart of the wall.
        inc de
        ld (de),a               ;put grey side to our right
        inc de
        ld (de),a
        inc de
        ld (de),a
        dec de
        dec de                  ;go left 1 again
        dec de
        ex de,hl
        add  hl,de              ; advance to the next row of the display file.
        ex de,hl
        djnz loop10r             ;do this 3 times

        ;now draw the blank face
        pop de                  ;back to our original position
        push de
        dec de                  ;move left 1 space in the display
        
;check if the char to our right is a wall block.
;if so, do not draw a black face as we need to hide it or it will
;ovewrite the already drawn block

        ld a,(de)
        cp _mediumwall_1        ;is there an already drawn screen block here?
        jp nz,cont_1r            ;there is no block so draw black edge
        pop de
        pop bc
        jr go_back4r             ;otherwise quit this draw

cont_1r ex  de,hl
        ld de,$0021
        ld  a,_topcorner3      ;triangle sloping to right bottom
        ld  (hl),a
        add hl,de
        ld  a,_black      
        ld  (hl),a
        add hl,de
        ld  a,_black      
        ld  (hl),a
        add hl,de
        
        ld  (hl),a
        ld  a,_topcorner2
        ld  (hl),a
        pop de
        pop bc
        jr go_back4r              ; jump back to main loop

;************************************
;*Draw the 2nd right block of section 4
;************************************

draw_9r_2:  
        push bc
        ld hl,3                 ;move display 3 chars to the right
        add hl,de
        ex de,hl
        push de

;now draw the 2nd wall itself
        ld b,4                  ;block is 4 blocks high
        ld   hl,$0021           ;load with 32 to jump to line below us
        ld   a,_mediumwall_1      ;grey sides facing us

loop10r_2:
        ld (de),a             ; insert thepart of the wall.
        inc de
        ld (de),a               ;put grey side to our right
        inc de
        ld (de),a
        inc de
        ld (de),a
        inc de
        ld (de),a
        dec de        
        dec de
        dec de
        dec de                  ;go left 1 again
        ex de,hl
        add  hl,de              ; advance to the next row of the display file.
        ex de,hl
        djnz loop10r_2             ;do this 3 times

        ;now draw the blank face
        pop de                  ;back to our original position
        push de
        dec de                  ;move left 1 space in the display
        
;check if the char to our right is a wall block.
;if so, do not draw a black face as we need to hide it or it will
;ovewrite the already drawn block

        ld a,(de)
        cp _mediumwall_1        ;is there an already drawn screen block here?
        jp nz,cont_1r_2           ;there is no block so draw black edge
        pop de
        pop bc
        jp go_back4r             ;otherwise quit this draw

cont_1r_2:
        ex  de,hl
        ld de,$0021

;need to loop 2 times drawing 2 lots of 3 top
;& bottom chars- move down 1after 1st 3 top chars drawn
;
        
        ld a,2
        ld (var7),a             ;save initial count for 2 draws        

;loop for 2 black wall columns
        ld a,3                  ;column start height
        ld (var1),a           ;save the count for the column hight minus the top corners

        ld b,3                  ;loop 3 times for 3 columns
        ld (var5),hl            ;address of first face block after corner chamfer
        ld a,$91
        ld (var2),a             ;ld var2 with top right sloping corner black
        
loop10br_2:
        push bc                 ;save count        
        ld a,(var1)             ;column height
        ld b,a                  ;holds the column height in chars
        ld  a,(var2)            ;triangle sloping to right bottom
        push af                 ;save a for bottom corners
        ld  (hl),a
        
loop10ar_2:                   
        add hl,de
        ld  a,_black            ;black wall fill
        ld  (hl),a              ;draw 6 black blocks and3 edges
        djnz loop10ar_2

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
               
        djnz loop10br_2

exit_1_2:
        pop de
        pop bc
        jp go_back4r              ; jump back to main loop        

;#############################################
;*Draw the 3rd right block of section 4
;#############################################

draw_9r_3:  
        push bc
        push de                 ;save our display pointer
        ld b,4                  ;block is 4 blocks high
        ld hl,$0021             ;load with 32 to jump to line below us
        ld de,$C162             ;start of drawing

loop10r_3:
        ld a,_mediumwall_1      ;grey sides facing us
        ld (de),a               ; insert thepart of the wall.
        ex de,hl
        add  hl,de              ; advance to the next row of the display file.
        ex de,hl
        djnz loop10r_3          ;do this 3 times

        ;now draw the blank face
        pop de                  ;back to our original position
        push de
        
;check if the char to our right is a wall block.
;if so, do not draw a black face as we need to hide it or it will
;ovewrite the already drawn block

        ld a,(de)
        cp _mediumwall_1        ;is there an already drawn screen block here?
        jp nz,cont_1r_3            ;there is no block so draw black edge

        pop de
        pop bc
        jp go_back4r             ;otherwise quit this draw

cont_1r_3:
        ex  de,hl
        ld de,$0021
        ld hl,$c161

;need to loop 2 times drawing 2 lots of 3 top
;& bottom chars- move down 1after 1st 3 top chars drawn
;
        
;loop for 2 black wall columns
        ld a,3                  ;column start height
        ld (var1),a           ;save the count for the column hight minus the top corners

        ld b,5                  ;loop 3 times for 3 columns
        ld (var5),hl            ;address of first face block after corner chamfer
        ld a,$cd ;91
        ld (var2),a             ;ld var2 with top right sloping corner black
        
loop10br_2a:
        push bc                 ;save count        
        ld a,(var1)             ;column height
        ld b,a                  ;holds the column height in chars
        ld  a,(var2)            ;triangle sloping to right bottom
        push af                 ;save a for bottom corners
        ld  (hl),a
        
loop10ar_2a:                   
        add hl,de
        ld  a,_black            ;black wall fill
        ld  (hl),a              ;draw 6 black blocks and3 edges
        djnz loop10ar_2a

        pop af                  ;retrivetop corner
        dec a                   ;prep for next top corner
        ld (var2),a             ;re-save it for next corner
        add a,6                 ;get the correct char to print
        ld  (hl),a              ;draw the bottom of the wall

        ;now change column count
        ld a,(var1)
        pop bc

        ld hl,(var5)
        dec hl                  ;move print position to the left
        ld (var5),hl
               
        djnz loop10br_2a


;exit_1_2a:
        pop de
        pop bc
        jp go_back4r              ; jump back to main loop        

;#############################################
;*Draw the 4th RIGHT block of section 4
;#############################################

; we only need to draw 2 columns of black sides.

draw_9r_4:  
        push bc
        push de                 ;save our display pointer

;check if the char to our right is a wall block.
;if so, do not draw a black face as we need to hide it or it will
;ovewrite the already drawn block

        ld hl,$C18C+20-30-32              ;start of drawing
        ld a,(hl)
        cp _mediumwall_1        ;is there an already drawn screen block here?
        jp nz,cont_3L            ;there is no block so draw black edge

        pop de
        pop bc
        jp go_back4r             ;otherwise quit this draw

cont_3L:
        ld b,4                  ;block is 4 blocks high
 ;       ld hl,$C18C+20-30-32              ;start of drawing
        ld a,$ca
        ld (hl),a        
        dec hl
        dec a
        ld (hl),a 

;need 2 black walls now!
        ld a,_black
        ld de,33                ;1 line width

        CALL black_wall_2       ;draw 2 black blocks        
        dec de                  ;go 1 place left in display

        CALL black_wall_2       ;draw 2 black blocks        
        add hl,de               ;jump to next line below

        
;top half done - so do bottom half - 2 blacks first

;de already holds 34  -1 line plus 2 chars to the right

        ld a,$ce
        ld (hl),a
        inc hl
        inc a
        ld (hl),a
                
        pop de
        pop bc
        jp go_back4r

;draw 2 black walls across 1 line
black_wall_2:
        add hl,de      ;jump 1 line below
        ld (hl),a        
        inc hl
        ld (hl),a        
        ret


;#############################################
;#############################################
;# draw wall 3 right
;#############################################
;#############################################

draw_3r:

; hl=maze location being drawn.
; now determine what to draw for this section.


        ld hl,(furthest_point)  ;load our last furthest point

        call load_de            ;get left and right and front jump into de reg

        add hl,de               ;jump backwards along the user view 1 space
        ld (furthest_point),hl  ;re save it

        ld de,$0001             ;to move the display position +1
        ld (var4),de

        ld de,(right)

        add hl,de
        ld (var6),hl
           ;save the maze position

        ld (var3),de
        ld de,$0119           ; offset right of  centre of the 3d view.

        call do_draw_3r
        

        jp draw_2r              ;now draw the 2nd level

do_draw_3r:

        ld   hl,(d_file)        ; fetch the location of the display file.
        add  hl,de

        
; draw  right half of the display.

        ld b,3                  ; count for 2 blocks left or right of display file
                                ; 0 is not counted so loops 12 times
        ld de,(var6)            ; retrieve the maze location.

        ex   de,hl              ; transfer de to hl.

;       hl = furthest point in the maze
;       de = d_file location to store byte to display

loop11r:
        push hl

;*#########################################
;see if h is ouside the current maze 256 byte boundary - if so draw a wall.

        ld a,(maze_highbyte)
        cp h                    ;are we at the top part of the maze?
        jp z,cont_3a 
                                ;if we are on a different maze boundary
                                ;then draw a maze wall as we are the top
                                ;or north wall but maze data has no
                                ;wall data.
;3 = first right wall
;2 = 2nd right wall    
;1 = 3rd right wall      

        ld a,b                  ;our current wall counter
        sub 3
        jp nz,b3_1                 ;its not wall 2
        ld a,1
        ld b,a
        add a,128               ;make sure we set a wall!
        jp draw_10r             ;jump straight to making an end wall

b3_1    ld a,b                  ;our current wall counter
        sub 2
        jp nz,b3_2                 ;its not wall 2
        ld a,1
        ld b,a
        add a,128               ;make sure we set a wall!
        jp draw_10r_2             ;jump straight to making an end wall


b3_2:   ld a,1
        ld b,a                  ;make the bc count 1 so we only draw 1 wall
        add a,128               ;make sure we set a wall!
        jp draw_10r_3	       	;draw the 2nd wall to the right
       
;*#########################################
cont_3a:
        ld a,(hl)
        rla
        jp c,do_wall3r            ;if bit 7=128 theres a wall


go_back3r: 
        pop hl
        push de
        ld de,(var3)            ;used for left and right drawing
        add hl,de                ; go right 1 block in the maze
        pop de
        djnz loop11r
        ret
;now do the next maze position


do_wall3r:

        ;check if bit 1 is set as thats an end wall 
        ;and b must then be changed to 1 to stop drawing.

        ;2020 draw layers according to how close to the middle
;         bit 1,a                 ; is this a side wall? (129 but we rla'd accumulator)
;         jr z,wall3_start
;         ld b,1                  ;it IS a sidewall so set b so we exit on return

;**** Whats this for? Does it work!
;         ld a,(blockid)
;         cp 16
;         jp z,draw_10r          ;16 = a side wall
         
;now draw the wall based on bc value
wall3_start:


       ld a,b			               ;b is the loop count i.e # of walls to draw
       	sub 1			               ;3 = the wall imediately right
        jp z,draw_10r_3          ;draw an end wall if blockid=16
        
        ld a,b
        sub 3
        jp z,draw_10r         		;draw the 1st wall to the right

        ld a,b 
        sub 2
        jp z,draw_10r_2	       	;draw the 2nd wall to the right
        
        pop hl                  ;nothing to draw so return
        ret
        
        
draw_10r:  
         push bc                ;save loop count
         ld de,$c119             ;start of print position        
         push de                 ;save our display pointer

         ld b,8                  ;block is 8 blocks high
         ld hl,$0021             ;load with 32 to jump to line below us
         ld a, _mediumwall       ;wall on sides facing us
loop12r: ld (de),a               ; insert the part of the wall.
         inc de
         ld (de),a               ;put grey side to our right
         inc de
         ld (de),a               ;put grey side to our right
         inc de
         ld (de),a               ;put grey side to our right
         inc de
         ld (de),a               ;put grey side to our right
         inc de
         ld (de),a               ;put grey side to our right

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
         djnz loop12r            ;do this 3 times

;now draw the blank face to the leftt of the block
;create first column of left face characters

         pop de                  ;back to our original position
         push de
         dec de                  ;move ahead 1 space in the display (right)

;check if the char to our left is a wall block.
;if so, do not draw a black face as we need to hide it or it will
;ovewrite the already drawn block

         ld a,(de)
         cp _mediumwall        ;is there an already drawn screen block here?
         jp nz,cont_2r            ;there is no block so draw black edge
         pop de
         pop bc
         jr go_back3r             ;otherwise quit this draw


cont_2r: ex  de,hl
         ld de,$0021
        
;loop for 2 columns

        ld b,2                  ; loop 2 times for 2 columns
        ld (var5),hl            ;address of first face block after corner chamfer
        ld a,7
        ld  (var1),a            ;save the count for the column hight minus the top corners

loop12br:
        push bc                 ;save count        
        ld a,(var1)
        ld b,a                  ;holds the column height in chars
        ld  a,_topcorner3      ;triangle sloping to right bottom
        ld  (hl),a
        
loop12ar:                   ;we must start at5 to draw 4 face blocks on right
        add hl,de
        ld  a,_black      ;triangle sloping to right bottom
        ld  (hl),a              ;draw 6 black blocks and 2 edges
        djnz loop12ar

        
        ld  a,_topcorner2
        ld  (hl),a

        ;now change column count
        ld a,(var1)
        sub 2                   ;subtract 2
        ld (var1),a
        pop bc

        ld hl,(var5)
        dec hl                  ;move print position to the left
        ld de,$21               ;move top of next column down and across 1
        add hl,de
        ld (var5),hl
               
        djnz loop12br
        pop de
        pop bc
        jp go_back3r              ; jump back to main loop

;**********************************
;     draw the 2nd right block
;***********************************

draw_10r_2:  

         push bc
         ld de, $c119           ;start print position of wall
        push de
;dont draw a front wall as we never see it.

        ld hl,8                 ;move 8 blocks over to start position
        add hl,de
        ex de,hl
;we do not need a front wall for this row as it is never seen.
;below jp code can be removed :) Because a square block here
;is 8 x 8

         dec de                  ;move ahead 1 space in the display (right)

;check if the char to our left is a wall block.
;if so, do not draw a black face as we need to hide it or it will
;ovewrite the already drawn block
         ld a,(de)
         cp _mediumwall        ;is there an already drawn screen block here?
         jp nz,cont_2r_2            ;there is no block so draw black edge
         pop de
         pop bc
         jp go_back3r             ;otherwise quit this draw


;draw the black edge wall

cont_2r_2:
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

loop_x: ld b,3                  ;loop 3 times for 3 columns
        ld (var5),hl            ;address of first face block after corner chamfer
        ld a,$91
        ld (var2),a             ;ld var2 with top right sloping corner black
        
loop12br_2:
        push bc                 ;save count        
        ld a,(var1)             ;column height
        ld b,a                  ;holds the column height in chars
        ld  a,(var2)            ;triangle sloping to right bottom
        push af                 ;save a for bottom corners
        ld  (hl),a
        
loop12ar_2:                   
        add hl,de
        ld  a,_black            ;black wall fill
        ld  (hl),a              ;draw 6 black blocks and3 edges
        djnz loop12ar_2

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
               
        djnz loop12br_2

;1st set of 3 top bits drawn
;now jump down the display 1 line
;then draw another 3 columns

        ld a,(var7)             ;get our loop counter
        dec a
        jr z,exit_1             ;exit after 2 loops
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
        
        jp loop_x


exit_1: pop de
        pop bc
        ld b,1                  ;if we draw this wall, we need to stop drawing any more walls
        jp go_back3r              ; jump back to main loop


;#############################################
;*Draw the 3rd RIGHT block of section3
;#############################################

 
	; we only need to draw 2 columns of black sides.
    ; if theres no brick pattern !

draw_10r_3:  
        push bc
        push de                 ;save our display pointer

        ld hl,$C18C-66-30-3+24  ;start of drawing
        ld a,(hl)               ;read what char is there
        cp _mediumwall      
        jr nz,cont_1r_4        ;exit if a wall is already there
        pop de
        pop bc
        jp go_back4             ;otherwise quit this draw
        
cont_1r_4:

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
        jp go_back3r

;draw 2 black walls across 1 line
;black_wall:
;        add hl,de      ;jump 1 line below
;        ld (hl),a        
;        add hl,de      ;jump 1 line below
;        ld (hl),a        
;        add hl,de      ;jump 1 line below
;        ld (hl),a        
;        add hl,de      ;jump 1 line below
;        ld (hl),a        

        ret


        
;#############################################
;#############################################
; draw  layer 2
;#############################################
;#############################################

draw_2r:


; hl=maze location being drawn.
; now determine what to draw for this section.
test

        ld hl,(furthest_point)  ;load our last furthest point

        call load_de            ;get left and right and front jump into de reg

        add hl,de               ;jump backwards along the user view 1 space
        ld (furthest_point),hl ;re save it

        ld de,$0001             ;to move the display position +1
        ld (var4),de

        ld de,(right)

;we need to move pointer 1 to the left for wall checking
        add hl,de
        ld (var6),hl

        ld (var3),de
        ld  de,$0b9           ; offset to right of centre of the 3d view.
        call do_draw_2r
        
        jp draw_1r           ;now draw the 2nd level

do_draw_2r:

        ld   hl,(d_file)        ; fetch the location of the display file.
        add  hl,de

        
        ld b,1                 ; count for 1 blocks left or right of display file
                                ; 0 is not counted so loops 12 times
        ld de,(var6)

        ex   de,hl              ; transfer de to hl.


loop14r: push hl

;*#########################################
;see if h is ouside the current maze 256 byte boundary - if so draw a wall.

        ld a,(maze_highbyte)
        cp h                    ;are we at the top part of the maze?
        jp z,cont_2a 
                                ;if we are on a different maze boundary
                                ;then draw a maze wall as we are the top
                                ;or north wall but maze data has no
                                ;wall data.
 
        ld a,1
        ld b,a                  ;make the bc count 1 so we only draw 1 wall
        add a,127               ;make sure we set a wall!
        jp draw_11r             ;jump straight to making an end wall
        
;*#########################################
cont_2a:
        ld a,(hl)
        rla
        jp c,do_wall2r            ;bit 7 (128)


go_back2r: 
        pop hl
        ret
;now do the 2nd position



do_wall2r:
        ;check if bit 2 is set as thats an end wall. 
        ;and b must then be changed to 1 to stop drawing.
;        bit 1,a                 ; is this a side wall? (129 but we rla'd accu)
;        jr z,draw_11r
;        ld b,1                  ;set b so we exit on return

;?? 2020 do we need this??????
;        ld a,(blockid)
;        cp 16
;        jp z,draw_11r           ;draw an endwall if blockid=16
;        pop hl
;        ret
        

draw_11r:  
;        push bc
        push de                 ;save our display pointer
        ld b,14                  ;block is 14 blocks high
        ld   hl,$0021           ;load with 32 to jump to line below us
        ld   a,_largewall            ;wall on sides facing us

;draw 4 columns of bricks
loop13r:
        ld (de),a             ; insert the part of the wall.
        inc de
        ld (de),a               ;draw brick side
        inc de
        ld (de),a               
        inc de
        ld (de),a               
        inc de
        ld (de),a               
        dec de
        dec de
        dec de
        dec de
        ex de,hl
        add  hl,de              ; advance to the next row of the display file.
        ex de,hl
       djnz loop13r             ;do this 3 times



        ;now draw the blank face to the left of the block
        ;create first column of left face characters
        pop de                  ;back to our original position
        dec de
        ex  de,hl
        ld de,$0021

        ld b,3                  ; for 4 face columns to draw to draw
        ld (var5),hl
        ld a,13                 ; for 14 blocks high per column
        ld (var1),a

;draw the black sides
loop13br:
        push bc
        ld a,(var1)
        ld b,a
        ld a,_topcorner3
        ld (hl),a
        
loop13ar:
        add hl,de
        ld  a,_black
        ld  (hl),a              ;draw 14 black blocks and 3 edges
        djnz loop13ar
        
        ld  a,_topcorner2
        ld  (hl),a
        
; now change the column count
        ld a,(var1)
        sub 2
        ld (var1),a
        pop bc

        ld hl,(var5)
        dec hl
        ld de,$21
        add hl,de
        ld (var5),hl

        djnz loop13br

        jr go_back2r              ; jump back to main loop

       

;#############################################
;#############################################
; draw 1st layer right
;#############################################
;#############################################

draw_1r:

; hl=maze location being drawn.
; now determine what to draw for this section.


        ld hl,(furthest_point)  ;load our last furthest point

        call load_de            ;get left and right and front jump into de reg

        add hl,de               ;jump backwards along the user view 1 space
        ld (furthest_point),hl ;re save it

        ld de,$0001             ;to move the display position +1
        ld (var4),de

        ld de,(right)

;we need to move pointer 1 to the left for wall checking
        add hl,de
        ld (var6),hl
        
;        ld de,$0001             ;to move the display position +1
        ld (var3),de
        ld  de,$038           ; offset to row 1 column 0 - left of  centre of the 3d view.
        call do_draw_1r
        

        jp draw_0r           ;now draw the 2nd level

do_draw_1r:

        ld   hl,(d_file)        ; fetch the location of the display file.
        add  hl,de

        ld b,1                 ; count for 2 blocks left or right of display file
                                ; 0 is not counted so loops 12 times
        ld de,(var6)
        ex   de,hl              ; transfer de to hl.

;       hl = furthest point in the maze
;       de = d_file location to store byte to display

loop15r: push hl

;*#########################################
;see if h is ouside the current maze 256 byte boundary - if so draw a wall.

        ld a,(maze_highbyte)
        cp h                    ;are we at the top part of the maze?
        jp z,cont_1a 
                                ;if we are on a different maze boundary
                                ;then draw a maze wall as we are the top
                                ;or north wall but maze data has no
                                ;wall data.
 
        ld a,1
        ld b,a                  ;make the bc count 1 so we only draw 1 wall
        add a,127               ;make sure we set a wall!
        jp draw_12r             ;jump straight to making an end wall
        
;*#########################################
cont_1a:
        ld a,(hl)
        rla
        jp c,do_wall1r            ;bit 7 (128)

go_back1r: 
        pop hl
        ret

do_wall1r:
        ;check if bit 2 is set as thats an end 
        ;and b must then be changed to 1 to stop drawing.

        bit 1,a                 ; is this a side wall? (129 but we rla'd accu)
        jr z,draw_12r
        ld b,1                  ;set b so we exit on return

;**** Whats this for? Does it work!

;        ld a,(blockid)
;        cp 16
;        jp z,draw_12r           ;draw an end wall if blockid=16
;        pop hl
;        ret


;draw the corridor bit to the left (1 column)
draw_12r:  
        push de                 ;save our display pointer
        ld b,22                  ;block is 22 blocks high
        ld   hl,$0021           ;load with 32 to jump to line below us
        ld   a,_hugewall;_largewall            ;wall on sides facing us
loop16r:                        ; insert thepart of the wall.
        inc de
        ld (de),a               ;put grey side to our right
        dec de
        ex de,hl
        add  hl,de              ; advance to the next row of the display file.
        ex de,hl
        djnz loop16r             ;do this 3 times

        ;now draw the blank face to the right of the block
        ;create first column of right face characters
        pop de                  ;back to our original position
        ex  de,hl
        ld de,$0021

;now draw the face we see on our left as we walk forward
        ld b,4                  ; for 8 face columns to draw to draw
        ld (var5),hl
        ld a,21                 ; for 14 blocks high per column
        ld (var1),a

loop14br:
        push bc
        ld a,(var1)
        ld b,a
        ld a,_topcorner3
        ld (hl),a
        
loop14ar:
        add hl,de
        ld  a,_black            ;triangle sloping to right bottom
        ld  (hl),a              ;draw 14 black blocks and 3 edges
        djnz loop14ar
        
        ld  a,_topcorner2
        ld  (hl),a
        
; now change the column count
        ld a,(var1)
        sub 2
        ld (var1),a
        pop bc

        ld hl,(var5)
        dec hl
        ld de,$21
        add hl,de
        ld (var5),hl

        djnz loop14br

        jr go_back1r              ; jump back to main loop
        

;#############################################
;#############################################
; draw layer 0 right
;#############################################
;#############################################

draw_0r:
;ret


; hl=maze location being drawn.
; now determine what to draw for this section.

        ld   hl,(furthest_point); retrieve the maze location.

        call load_de

;**think we can lose these 2 lines.
                    ;get left and right and front jump into de reg
        add  hl,de
        
;need to move pointer right for wall checking
        ld de,(right)
        add hl,de
        ld (var6),hl

        ld (var3),de
        ld  de,$18              ;offset to row0 column 24 - left of  centre of the 3d view.
                                ;1 column of left face to draw
;draw the wall
        ld   hl,(d_file)        ; fetch the location of the display file.
        add  hl,de

        
        ld   de,(var6)
        ex   de,hl              ; transfer de to hl.


loop17r: 

;*#########################################
;see if h is ouside the current maze 256 byte boundary - if so draw a wall.

        ld a,(maze_highbyte)
        cp h                    ;are we at the top part of the maze?
        jp z,cont_0a 
                                ;if we are on a different maze boundary
                                ;then draw a maze wall as we are the top
                                ;or north wall but maze data has no
                                ;wall data.
 
        ld a,1
        ld b,a                  ;make the bc count 1 so we only draw 1 wall
        add a,127               ;make sure we set a wall!
        jp draw_13r             ;jump straight to making an end wall
        
;*#########################################
cont_0a:
        ld a,(hl)
        rla
        jp c,do_wall0r           ;bit 7 (128)
        ret


do_wall0r:
        ;check if bit 2 is set as thats an end wall 
        ;and b must then be changed to 1 to stop drawing.
        
        bit 1,a                 ; is this a side wall? (129 but we rla'd accu)
        jp c,draw_13r          ;yes if bit 2 = 1
        jp draw_wall0r           ;its a wall but not a side wall.

        


;we need to draw 1 vertical line from pos 1,1 to show
;the side of the block.
        
;draw sidewall brick pattern        
draw_13r:  
        ld a,_topcorner3
        ex de,hl

        ld (hl),a
        ld de,$21                ;jp to next line below
        add hl,de
        ld b,22                  ;block is 22 blocks high
        ld de,$021           ;load with 32 to jump to line below us
        ld a,_black            ;wall on sides facing us;
loop18r:
        ld (hl),a             ; insert the part of the wall.
        add  hl,de              ; advance to the next row of the display file.
        djnz loop18r

;###this bit causes the direction indicator to fail
        ld a,_topcorner2
        ld (hl),a
        ret                     ;return to main program

draw_wall0r:                     ;draw brick pattern only  

        ld de,$21                ;jp to next line below
        add hl,de
       ; ex de,hl

        ld b,22                  ;block is 24 blocks high
        ld hl,$021           ;load with 32 to jump to line below us
        ld a,_largewall            ;wall on sides facing us;
loop19r:
        ld (hl),a             ; insert the part of the wall.
       ; ex de,hl
        add  hl,de              ; advance to the next row of the display file.
       ; ex de,hl
        djnz loop19r

        ret                     ;return to main program

