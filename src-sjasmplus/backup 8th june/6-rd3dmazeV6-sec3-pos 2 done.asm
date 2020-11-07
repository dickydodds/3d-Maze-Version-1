
;############################################
;draw section 5 right
;############################################
test5r:
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

draw_6r:
;do nothing on screen as already done via left side draw

        ld hl,(furthest_point)  ;load our last furthest point
        call load_de            ;get left and right and front jump into de reg
        add hl,de               ;Additional add to simulate layer 6
        ld (furthest_point),hl ;re save it



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

;move the maze location pointer 1 to the left - used for all
;remaining blocks to test if there is a wall there or not.
        ld de,(right)
        add hl,de
        ld (var6),hl

        ld (var3),de
        ld   de,$0179           ; offset to row 11 column 10 - left of  centre of the 3d view.
        call do_draw_5r

        sub a                   ;make reg a zero
        ld (var10),a            ;used in the maze wall drawing at layer 5
        ld a,(blockid)          ;get the right hand maze wall location
        inc a                   ;if blockid was 255 (UNUSED) its will now be zero
                                ;so 
;        call nz,draw_sidewall_r   ;draw right hand maze wall        
        jp draw_4r              ;now draw the 4th level

do_draw_5r:

        ld   hl,(d_file)        ; fetch the location of the display file.
        add  hl,de

        
; draw right half of the display.

        ld b,16                 ; count for 15 columns left or right of display file
                                ; 0 is not counted so loops 12 times
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


        ld a,_smallwall;_topright5          ; load with top right char $a9
        ld (var1),a
        inc a
        inc a
        ld a,_smallwall;_topright5          ; load with top right char $a9
        
        ld (var2),a             ;ld with bottom left char

loop8r:
        push hl

;BUT....if we are at position 16 or below we are at the top end
;(north) of the maze so we implicitly have a wall so make it so.

;see if l is less than 17 - if so draw a wall.

;################
;dont think this code is used - $85 should be $55...
;        ld a,h
;        cp $87                   ;are we at the top part of the maze?
;        jp z,do_wall5r

;############################

;check we are at an outside maze wall
        ld a,(hl)               ;otherwise, check if there is a wall 
        cp _mh                  ;maze wall block
        jr nz,cont10            ;its a wall block so need to draw the wall
        push af                 ;save which print location we are at
        ld a,b                  ;for drawing the maze wall to the screen
        ld (blockid),a          ;edge
        pop af
        ld b,1                  ;stop drawing more blocks as its an end wall

cont10: rla
        jp c,do_wall5r            ;bit 7 (128)

;        call do_no_wall5r         ; otherwise draw no wall

go_back5r: 
        ld hl,(var4)            ;used for left and right drawing
        add hl,de               ; holds current screen position
        ex de,hl
        pop hl
        push de
        ld de,(var3)            ;used for left and right drawing
        add hl,de                ; go left 1 block in the maze
        pop de

;now make normal  walls.
        ld a,_smallwall          ; load with top wall
        ld (var1),a
        ld a,_smallwall          ; load with bottom wall
        ld (var2),a

        djnz loop8r
        ret


; there is not a wall so insert black to show that the location is too far away to see its detail.

do_wall5r:


          ;check if bit 2 is set as thats an end 
        ;and b must then be changed to 1 to stop drawing.      
 ;;       bit 1,a                 ; is this a side wall? (129 but we rla'd accu)
;;        jr z,draw8
;;        ld b,1                         ;set b so we exit on return


draw8r:  push de
        ld   a,(var1)     
        ld   (de),a             ; insert the top of the wall.

;now check if we need to draw a black side on the right
;by looking to the character to the right of the wall
;and if there is not a wall already drawn, then draw a
;black side

        dec de                  ;jump left 1 char in the display
        ld a,(de)               ;read whats there
        inc de                  ;put our pointer back to the original position
        cp _smallwall           ;is it a wall
        jp z,_x1r                ;if yes, do NOT draw a black side.
        ld a,_topright5     ;if not, draw the top left side
;        ld a,_layer5lefttop     ;if not, draw the top left side
        dec de                 ;move to the right of the bricks                 
        ld (de),a               ;draw a black and chevron side
        inc de                  ;go back 1 space again

_x1r:   ld   hl,$0021           ;jump to the next line below

        add  hl,de
        ld a,(var2)             ;draw our wall bottom.
        ld   (hl),a             ; insert the bottom of the wall.

;now check if we need to draw a black side on the left of the lower half wall
;do this by checking if the next block is already a wall just like above
        dec hl      ;look at the left block
        ld a,(hl)
        cp _smallwall
        jp z,_x2r
        ld a,_bottomright5
;        ld a,_layer5leftbottom
        ld (hl),a

_x2r    pop de


        jr go_back5r              ; jump back to main loop

;        jp draw_4r               ;draw next layer
        
; there is no wall so insert chequerboard for the wall face.

do_no_wall5r:
;        ret
        push de
;        ld   a,_topwhitebottomchequer
        ld   a,_layer5lefttop
        ld   (de),a                             ; insert the top of the wall face.
        ld   hl,$0021
        add  hl,de                              ; advance to the next row of the display file.
;        ld   (hl),_topchequerbottomwhite           ; insert the bottom of the wall face.
        ld   (hl),_layer5leftbottom           ; insert the bottom of the wall face.
        pop de
        ret


;############################################
;draw layer 4 right
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


        ld b,7                 ; count for max of 7 blocks left of display file
                                ; 0 is not counted so loops 3 times
        ;ld   de,(furthest_point); retrieve the maze location.
        ld de,(var6)
        

        ex   de,hl              ; transfer de to hl.

loop9r:
        push hl
        ld a,(hl)
        rla
        jp c,do_wall4r            ;bit 7 (128)

 ;       call do_no_wall4r         ; otherwise draw no wall

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

        bit 1,a                 ; is this a side wall? (129 but we rla'd accu)
        jr z,draw_9r
        ld b,1                  ;set b so we exit on return

        ld a,(blockid)
        cp 16
        jp z,draw_9r            ;draw an end wall if blockid=16
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
        dec de
        dec de                  ;go left 1 again
        ex de,hl
        add  hl,de              ; advance to the next row of the display file.
        ex de,hl
        djnz loop10r             ;do this 3 times

        ;now draw the blank face
        pop de                  ;back to our original position
        push de
       ; inc de
        dec de                  ;move left 1 space in the display
       ; inc de
        
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

        
; there is a wall so insert chequerboard for the wall face.

;do_no_wall4:
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
;# draw wall 3 right
;#############################################
draw_3r:

; hl=maze location being drawn.
; now determine what to draw for this section.


        ld hl,(furthest_point)  ;load our last furthest point

        call load_de            ;get left and right and front jump into de reg

        add hl,de               ;jump backwards along the user view 1 space
        ld (furthest_point),hl ;re save it

        ld de,$0001;1             ;to move the display position +1
        ld (var4),de

        ld de,(right)

        add hl,de
        ld (var6),hl

;        ld de,$0001             ;to move the display position +1
        ld (var3),de
        ld   de,$0119           ; offset to row 8 column 15 - left of  centre of the 3d view.

        call do_draw_3r
        

         jp draw_2r           ;now draw the 2nd level

do_draw_3r:

        ld   hl,(d_file)        ; fetch the location of the display file.
        add  hl,de

        
; draw  right half of the display.

        ld b,3                 ; count for 2 blocks left or right of display file
                                ; 0 is not counted so loops 12 times
        ;ld   de,(furthest_point); retrieve the maze location.
        ld de,(var6)

        ex   de,hl              ; transfer de to hl.

;       hl = furthest point in the maze
;       de = d_file location to store byte to display

loop11r:
        push hl
        ld a,(hl)
        rla
        jp c,do_wall3r            ;bit 7 (128)

   ;     jp ,do_no_wall3r         ; otherwise draw no wall

go_back3r: 
      ;  ld hl,(var4)            ;used for left and right drawing
      ;  add hl,de               ; holds current screen position
      ;  ex de,hl
;we move the start position of block number 2 to the left of the display
;and although we overwrite the next block, we can still do the
;check to see if a block is already drawn.

        ;inc de                  ;move our start print position
        ;inc de                  ;of block 2 right 3 spaces in the
        inc de                  ;display file
        pop hl
        push de
        ld de,(var3)            ;used for left and right drawing
        add hl,de                ; go left 1 block in the maze
        pop de
        djnz loop11r
        ret
;now do the 2nd position


do_wall3r:

        ;check if bit 1 is set as thats an end wall 
        ;and b must then be changed to 1 to stop drawing.

        ;2020 draw layers according to how close to the middle

         bit 1,a                 ; is this a side wall? (129 but we rla'd accumulator)
         jr z,wall3_start
         ld b,1                  ;it IS a sidewall so set b so we exit on return

;**** Whats this for? Does it work!
         ld a,(blockid)
         cp 16
         jp z,draw_10r          ;16 = a side wall
         
;now draw the wall based on bc value
wall3_start:
	       ld a,b			               ;b is the loop count i.e # of walls to draw
        	sub 3			               ;3 = the wall imediately right
        jp z,draw_10r          ;draw an end wall if blockid=16
        ld a,b
        sub 2
        jp z,draw_10r_2		;draw second wall to the right
;        ld a,b 
;        sub 3
;        jp z,draw_10r_3		;draw 4rd wall to the right
         pop hl
         ret
        
draw_10r:  
         push bc
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
;******Now draw the 2nd right block
;***********************************

draw_10r_2:  
         push bc
      ;   push de                 ;save our display pointer

;move our start point to the end point of 1st wall
        inc de                  ;move display 2 pos to the right
        inc de
        inc de
        ld hl,5
        add hl,de
        ex de,hl
        push de
        
;now draw the 2nd wall
         ld b,8                  ;block is 8 blocks high
         ld hl,$0021             ;load with 32 to jump to line below us
         ld a,_mediumwall      ;wall on sides facing us
;         add de,5		;move right 5 columns

;now draw the front face
;we can only see 2 blocks
loop12r_2: 
        	ld (de),a               ; insert the part of the wall.
         inc de
         ld (de),a               ;put grey side to our right
         inc de
       ;  ld (de),a               ;put grey side to our right
       ;  inc de
       ;  dec de
         dec de
         dec de
         ex de,hl
         add  hl,de              ; advance to the next row of the display file.
         ex de,hl
         djnz loop12r_2            ;do this 3 times

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

test_x: ld b,3                  ;loop 3 times for 3 columns
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
        ;ld  a,$94               
        ld  (hl),a              ;draw the bottom of the wall

        ;now change column count
        ld a,(var1)
        ;sub 1;2                   ;subtract 2
        ;ld (var1),a
        pop bc

        ld hl,(var5)
        dec hl                  ;move print position to the left
      ;  ld de,$21               ;move top of next column down and across 1
      ;  add hl,de
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
        ;dec hl                  ;de already holds 32 :)
                                ; now move back in the display
                                ;1 char     
        ld (var5),hl            ;re save it for use above

        ld a,5                  ;reduce black wall column height
        ld  (var1),a            ;save the count for the column hight minus the top corners
        
        jp test_x


exit_1: pop de
        pop bc
        jp go_back3r              ; jump back to main loop


;******Now draw the 2nd right block
draw_10r_3: 
	ret
        
;#############################################
; draw 2nd layer right
;#############################################
draw_2r:

ret
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
        ld  de,$0b9           ; offset to right of centre of the 3d view.
        call do_draw_2r
        
        jp draw_1r           ;now draw the 2nd level

do_draw_2r:

        ld   hl,(d_file)        ; fetch the location of the display file.
        add  hl,de

        
        ld b,1                 ; count for 1 blocks left or right of display file
                                ; 0 is not counted so loops 12 times
        ;ld   de,(furthest_point); retrieve the maze location.
        ld de,(var6)

        ex   de,hl              ; transfer de to hl.

;       hl = furthest point in the maze
;       de = d_file location to store byte to display

loop14r: push hl
        ld a,(hl)
        rla
        jp c,do_wall2r            ;bit 7 (128)

       ; call do_no_wall2r        ; otherwise draw no wall

go_back2r: 
;        ld hl,(var4)            ;used for left and right drawing
;        add hl,de               ; holds current screen position
;        ex de,hl
            pop hl
;        push de
;        ld de,(var3)            ;used for left and right drawing
;        add hl,de                ; go left 1 block in the maze
;        pop de
;        djnz loop14r
           ret
;now do the 2nd position



; there is not a wall so insert black to show that the location is too far away to see its detail.

do_wall2r:
        ;check if bit 2 is set as thats an end wall. 
        ;and b must then be changed to 1 to stop drawing.
        bit 1,a                 ; is this a side wall? (129 but we rla'd accu)
        jr z,draw_11r
        ld b,1                  ;set b so we exit on return

        ld a,(blockid)
        cp 16
        jp z,draw_11r           ;draw an endwall if blockid=16
        pop hl
        ret
        

draw_11r:  
;        push bc
        push de                 ;save our display pointer
        ld b,14                  ;block is 14 blocks high
        ld   hl,$0021           ;load with 32 to jump to line below us
        ld   a,_largewall            ;wall on sides facing us

;draw 4 columns of bricks
loop13r:ld (de),a             ; insert the part of the wall.
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

;        pop bc
        jr go_back2r              ; jump back to main loop

       

;#############################################
; draw 1st layer right
;#############################################
draw_1r:
;ret
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

        
; draw left half then right half of the display.

        ld b,1                 ; count for 2 blocks left or right of display file
                                ; 0 is not counted so loops 12 times
        ;ld   de,(furthest_point); retrieve the maze location.
        ld de,(var6)
        ex   de,hl              ; transfer de to hl.

;       hl = furthest point in the maze
;       de = d_file location to store byte to display

loop15r: push hl
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

        ld a,(blockid)
        cp 16
        jp z,draw_12r           ;draw an end wall if blockid=16
        pop hl
        ret


;draw the corridor bit to the left (1 column)
draw_12r:  
        push de                 ;save our display pointer
        ld b,22                  ;block is 22 blocks high
        ld   hl,$0021           ;load with 32 to jump to line below us
        ld   a,_largewall            ;wall on sides facing us
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
; draw layer 0 right
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
;        ld   de,(furthest_point); retrieve the maze location.

;#        ld de,$0001             ;move the display +1 to right
;#        ld (var4),de
        
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

        
        ;ld   de,(furthest_point); retrieve the maze location.
        ld   de,(var6)
        ex   de,hl              ; transfer de to hl.


loop17r: 
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
        ld (de),a
        ld hl,$21                ;jp to next line below
        add hl,de
        ex de,hl

        ld b,22                  ;block is 22 blocks high
        ld hl,$021           ;load with 32 to jump to line below us
        ld a,_black            ;wall on sides facing us;
loop18r:
        ld (de),a             ; insert the part of the wall.
        ex de,hl
        add  hl,de              ; advance to the next row of the display file.
        ex de,hl
        djnz loop18r

;###this bit causes the direction indicator to fail
        ld a,_topcorner2
        ld (de),a
        ret                     ;return to main program

draw_wall0r:                     ;draw brick pattern only  

        ld hl,$21                ;jp to next line below
        add hl,de
        ex de,hl

        ld b,22                  ;block is 24 blocks high
        ld hl,$021           ;load with 32 to jump to line below us
        ld a,_largewall            ;wall on sides facing us;
loop19r:
        ld (de),a             ; insert the part of the wall.
        ex de,hl
        add  hl,de              ; advance to the next row of the display file.
        ex de,hl
        djnz loop19r

        ret                     ;return to main program


draw_sidewall_r      ;draw right hand maze wall        

        dec a                   ;put reg a back to original value

;now see if we need to draw a maze outside wall.
;blockid will be between 6 and 15
asdf:
        and a                   ;reset carry flag
        ;reg a already holds block id value
        cp 16                   ; the highest number it will be

       ret nc
        cp 6                    ;valid values are 6 to 15
        ret c

;we must be at an end wall if we get here

;first, work out the offset in the table to read for our data
;we need to times the accumulator by 5 as we have 5 data bytes per line in the table

        sub 6                   ;our lowest number will be 6 - reg a contains the block id
                                ;reg 'a' will = 0 if 6; VAR10 already =0
        jp z,_j1                ;zero flag should be set from the above compare
        ld b,a
        xor a                   ;zero the a reg
loop_a  add a,7                 ;add7 to reg a as our data is 7 bytes long
        djnz loop_a             ;keep adding 7
        ld (var10),a            ;save it        

_j1     exx                     ;use alternate registers but save hl'
        push hl
        ld hl,table_5           ;point to our table of maze wall data
        ld a, (var10)           ;get our offset in the table
        ld b,0                   ;make b zero
        ld c,a
        add hl,bc               ;point to our table in memory
        ld b,(hl)               ;get line width to draw into reg b
        inc hl                  ;point to table for first line to draw
        ld e,(hl)
        inc hl
                 ;get next byte of word
        ld d,(hl)
        push hl                 ;save this pointer for later
       ; push hl                 ;save it again
        ld hl,screen_mem        ;fetch the location of the display file.
        add hl,de
        ld (hl),_topcorner3     ;draw the triangle on top of the wall
;so now the top right hand corner has been drawn

        ex de,hl                ;save hl in de - points to last screen
                                ;position
        pop hl                  ;get last table data position
        inc hl
        inc hl
        inc hl                  ;we now point at the number of lines to
                                ;draw - black lines
        ld b,(hl)               ;b holds number of lines to draw
        srl b                   ;half it - we draw top half only
        dec b                   ;so we dont draw over the end wall char
        ld c,1                  ;c hold number of blacks to draw
                                ;will increment for each line
        ld a,c
        ex de,hl                ;hl points to last printed corner 
_j3     ld de,33                ;point to end of next display line
        add hl,de               ;we are at the same position on next line
        push hl                 ;save the position
_j2     ld (hl),_black          ;draw the black wall
        dec hl                  ;get ready for next block
        dec c                   ;is this the last block to draw on 1 line?
        jp nz,_j2
        inc a
        ld c,a
;are we on the last line? if so dont draw an end block
        dec b
        jp z,_j4
        ld (hl),_topcorner3     ;draw the triangle on top end of the wall
_j4     inc b        
        pop hl        

              


        djnz _j3                ;num of lines left to draw
_5        


;        pop hl                  ;point back to our table data
;        inc hl                  ;point to second word (bottom corner)        
;        ld e,(hl)
;        inc hl
 ;       ld d,(hl)
 ;       ld hl,screen_mem        ;fetch the location of the display file.
 ;       add hl,de
;        ld (hl),_topcorner2     ;draw the triangle on bottom of the wall

     ; pop hl
        
;now exit out the routine and return registers to normal
        pop hl                  ;put hl' back
        exx                     ;go back to normall registers 

        
        ret
