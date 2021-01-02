

;#############################################
;original code to draw maze FRONT walls here from 3D Monster Maze
;call it a homage ;)
;#############################################


; ############################
; draw wall in front of player
; ############################

; a wall face must be drawn centred within the view.
; the wall face is one character wider than it is high.

draw_front_view:

;        ld a,(depth)            ;find out how far we can see - will never be higher than 6
        ld a, (maxview)
        cp 6
        ret z				               ;too far away so return doing nothing
	    cp 5
        ret z
        jp nz,set4
        ld c,13;12
		ld a,_smallwall			      ;this is the character to draw (brick pattern)
		ld (var1),a
        jp draw_wall
set4:   cp 4
        jp nz,set3
        ld c,11
		ld a,_smallwall 			     ;this is the character to draw (brick pattern)
		ld (var1),a
        jp draw_wall
set3:   cp 3                
        jp nz,set2
        ld c,10
		ld a,_mediumwall_1			   ;this is the character to draw (brick pattern)
		ld (var1),a
        jp draw_wall
set2:   cp 2                
        jp nz,set1
        ld c,8
		ld a,_mediumwall			      ;this is the character to draw (brick pattern)
		ld (var1),a
        jp draw_wall
set1:   cp 1              
        jp nz,set0
        ld c,5
		ld a,_largewall			      ;this is the character to draw (brick pattern)
		ld (var1),a
        jp draw_wall
;must be zero if we get here
set0:   ld c,1
        ld a,_hugewall;_largewall
        ld (var1),a	

draw_wall:         
;ld c,1 ;section from player

l49f6:  ld   hl,(d_file)                        ; fetch the location of the display file.
        ld   de,$0021                           ; each row is 33 characters wide.

;        ld   bc,(l4085)                         ; fetch the details for the section: b=width of section, c=distance of section from player.
        ld   b,$00
        add  hl,bc                              ; advance across the screen to the current distance of the wall.

        ld   a,$19                              ; the width of the view.
        ld   b,c                                ; fetch the distance.
        sla  b                                  ; multiply the distance by 2 since the wall be spans to the left and right of the centre column of the view.
        sub  b                                  ; determine the width of the wall face.
        ld   b,a                                ; b=width of the wall face (it will be an odd number of characters).

        sub  $01                                ; determine the wall height (it will be an even number of characters).

; enter a loop to draw each column of the wall face.

l4a0d:  push bc                                 ; save the wall face width.
        push hl                                 ; save the address within the display file.

        ld   b,c                                ; fetch the distance, which corresponds to the number of blank rows to show above the wall face.

l4a10:  ld   (hl),_space                        ; insert a space above the wall face.
        add  hl,de                              ; advance to the next row.
        djnz l4a10                              ; repeat for all rows above the wall face.

        ld   b,a                                ; fetch the wall height.

l4a16:  push af
		ld a,(var1)
		ld   (hl),a                             ; insert a wall face character into the display file.
        pop af
		      add  hl,de                              ; advance to the next row.
        djnz l4a16                              ; repeat for all rows forming the height of the wall face.

        ld   b,c                                ; fetch the distance, which corresponds the the number of blank rows to show above the wall face.
        dec  b                                  ; there is one less blank row below the wall face than above it due to the status message row.
        jr   z,l4a24                            ; jump if there are no rows below the wall to blank.

l4a1f:  ld   (hl),_space                        ; insert a space below the wall face.
        add  hl,de                              ; advance to the next row.
        djnz l4a1f                              ; repeat for all rows below the wall face.

l4a24:  pop  hl                                 ; retrieve the address within the display file.
        inc  hl                                 ; advance to the next column to the right.

        pop  bc                                 ; retrieve the wall face width.
        djnz l4a0d                              ; repeat for all columns of the wall face.

;call my_print              
        ret

;#################################################################
;#################################################################
; draw maze end walls left and right of the player view
;#################################################################
;#################################################################

;we will just copy parts of the front wall left and right on the screen
;depending if theres a side wall or not. No side wall, do nothing!

draw_side_walls

;1st we need to know if the front view is a side wallsurrounding the maze
;this is $81 (129) if its a side wall

;so we have an end wall here!

;1st, check if maxdepth =4 or less. We do not want to draw anything for
;depth 5 or 6

        or a                    ;clear carry flag
        ld a,(maxview)          ;how far we can see in front of us
 ;       cp 5
 ;       ret nc                  ;exit if its 5 or greater
                                ;carry set if <5

;now check if maxview and depth are the same as this indicates a side wall
;reg a already contains maxview
;#        ld b,a
;#        ld a,(depth)
;#        sub b                   ;should be 0 if the same
;#        ret nz                  ;exit if different

;now we cheat :) we just keep copying lines of the wall left & right
;untill we hit a non space in the display file!

;reg a contains our depth
;        ld a,(maxview)
        ld a,(depth)

        cp 0
        ;depth 1
        jp z,cp_wall_1          ;wall immediately in front of us
        cp 1
        ;depth 2
        jp z,cp_wall_2
        cp 2
        ;depth 3
        jp z,cp_wall_3
        cp 3
        ;depth 4
        jp z,cp_wall_4
        cp 4
 ;ret
        ;depth 5
        jp z,cp_wall_5
        ret                     ;go back now

cp_wall_1:
;do left side first - check for char A3 (black block for maze wall at a distance

        ld hl,$c14a             ;we should be 10 lines down(10,0)
        ld a,(hl)               ;check our character
        cp ' '                  ;should be space indicating nothing there
                
        call  z,loop91
         ;draw left half

;now do the right side
        ld hl,$c039             ;we should be 10 lines down(10,24)
        ld a,(hl)               ;check our character
        cp ' '                  ;should be space indicating noting there
        ret nz                  ;exit if no space there        
        ld hl,$c039             ;top left face
;        ld de,$c038             ;1 line right of front wall
        ld b,22                 ;copy 22 lines
        jp loop90               ;draw right side!
        ret                     ;exit altogether
        
loop91: ld hl,$c021             ;top left face
;        ld de,$c022             ;1 line left
        ld b,22                 ;copy 22 lines
loop90: ;ld a,(de)
        ld a,_hugewall
        ld (hl),a
        push de
        ld de,33
        add hl,de               ;go to next line
        pop de
        djnz loop90
        ret

cp_wall_2:
;do left side first - check for char ' ' showing nothing drawn there

        ld hl,$c0a9             ;we should be at the top left of the face
        ld ix,$c0a9
;        ld de,$c0ab             ;1 line left of our wall face
        ld de,lr_wall
        ld a,_largewall
        ld (de),a
        
        ld c,5                  ;draw 5 columns to the border
loop80: push hl
        ld b,14
        ld a,(ix+0)             ;check our character
        cp ' '                  ;should be space indicating noting there
        call z,loop93
        dec ix
        pop hl
        dec hl                 ;move left 1 line in the display
        dec c
        jp nz,loop80            ;do this 5 times

;now do the right side
        ld hl,$c0b9             ;we should be at the top right of the face
        ld ix,$c0b9
 ;       ld de,$c0b8             ;1 line left of our wall face
        ld de,lr_wall
        ld a,_largewall
        ld (de),a

        ld c,5                  ;draw 5 columns to the border
loop81: push hl
        ld b,14
        ld a,(ix+0)             ;check our character
        cp ' '                  ;should be space indicating noting there
        jp nz,loop82            ;skip over if no space there        
        call z,loop93
loop82  inc ix
                 ;do the next line
        pop hl
        inc hl
        dec c
        jp nz,loop81
        ret                     ;exit routine totally

cp_wall_3:
;do left side first - check for char ' ' showing nothing drawn there

        ld hl,$c10f             ;we should be at the top left of the face
        ld ix,$c10f
;        ld de,$c110             ;1 line left of our wall face
        ld de,lr_wall
        ld a,_mediumwall
        ld (de),a
        
        ld c,8                  ;draw 8 columns to the border
loop83: push hl
        ld b,8                 ;10 chars high
        ld a,(ix+0)             ;check our character
        cp ' '                  ;should be space indicating noting there
        call z,loop93
        dec ix
        pop hl
        dec hl                 ;move left 1 line in the display
        dec c
        jp nz,loop83            ;do this 5 times

;now do the right side
        ld hl,$c119             ;we should be at the top right of the face
        ld ix,$c119
;        ld de,$c118             ;1 line left of our wall face
        ld de,lr_wall
        ld a,_mediumwall
        ld (de),a
        
        ld c,8                  ;draw 8 columns to the border
loop84: push hl
        ld b,8                 ;8 chars high
        ld a,(ix+0)             ;check our character
        cp ' '                  ;should be space indicating noting there
        jp nz,loop85            ;skip over if no space there        
        call z,loop93
loop85: inc ix
                 ;do the next line
        pop hl
        inc hl
        dec c
        jp nz,loop84
        ret                     ;exit routine totally

cp_wall_4:
;do left side first - check for char ' ' showing nothing drawn there

        ld hl,$c153;2             ;we should be at the top left of the face
        ld ix,$c153;2;c153
        ld de,lr_wall
        ld a,_mediumwall_1
        ld (de),a
        ld de,$c154             ;1 line left of our wall face
        ld c,10                  ;draw 10 columns to the border
loop86: push hl
        ld b,4                  ;4 chars high
        ld a,(ix+0)             ;check our character
        cp ' '                  ;should be space indicating noting there
        call z,loop93
        dec ix
        pop hl
        dec hl                  ;move left 1 line in the display
        dec c
        jp nz,loop86            ;do this 5 times

;now do the right side
        ld hl,$c159             ;we should be at the top right of the face
        ld ix,$c159
        ld de,lr_wall
        ld a,_mediumwall_1
        ld (de),a     
        ld c,10                  ;draw 10 columns to the border
loop87: push hl
        ld b,4                 ;4 chars high
        ld a,(ix+0)             ;check our character
        cp ' '                  ;should be space indicating noting there
        jp nz,loop88            ;skip over if no space there        
        call z,loop93
loop88: inc ix
                 ;do the next line
        pop hl
        inc hl
        dec c
        jp nz,loop87
        ret                     ;exit routine totally

cp_wall_5:
;do left side first - check for char ' ' showing nothing drawn there

        ld hl,$c177             ;we should be at the top left of the face
        ld ix,$c177
;        ld de,$c176             ;1 line left of our wall face
        ld de,lr_wall
        ld a,_smallwall
        ld (de),a
        
        ld c,13                  ;draw 10 columns to the border
loop89: push hl
        ld b,2                  ;4 chars high
        ld a,(ix+0)             ;check our character
        cp _bottomblack         ;should be space indicating noting there
        call z,loop93
        dec ix
        pop hl
        dec hl                  ;move left 1 line in the display
        dec c
        jp nz,loop89            ;do this 5 times

;now do the right side
        ld hl,$c176             ;we should be at the top right of the face
        ld ix,$c176
;        ld de,$c176             ;1 line left of our wall face
        ld de,lr_wall
        ld a,_smallwall
        ld (de),a
        
        ld c,15                  ;draw 10 columns to the border
loop871:push hl
        ld b,2                  ;2 chars high
        ld a,(ix+0)             ;check our character
        cp _bottomblack         ;should be space indicating noting there
        jp nz,loop881            ;skip over if no space there        
        call z,loop93
loop881:inc ix
                 ;do the next line
        pop hl
        inc hl
        dec c
        jp nz,loop871
        ret                     ;exit routine totally

  
;#######################################################
;This routine draws the end wall blocks left & right
;######################################################
      
;it matches so draw a wall face by copying the existing one!
loop93:; dec de                  ;go 1 line left
loop92: ld a,(de)
        ld (hl),a
        push de
        ld de,33
        add hl,de               ;go to next line
        pop de
        djnz loop92

        ret

;#################################################################
;#################################################################
;draw colours     ; go through char display file and paint colours
;#################################################################
;#################################################################


wallcol       dw  40             ;bright red
skycol        equ 80            ; grey paper, black ink 
floorcol      equ 98             ; brown paper, black ink
;corridcol     equ 112            ; yellow paper, black ink   
sky_floor     db  40            ;store current sky or floor colour
wall_temp     db  0             ;temporary store for wall colour graduation
scr_attr_add  dw $c300  ;22528          ;start of spectrum attributes after char screen or 22528 actual sceen

; go through the display file at c000, check the character, change the colour
; if at row 26, start on next line at far left (0)
; do it again until you reach line 24 and column 25           

; built character display is at location c000

draw_colours: ld a, skycol           ; set the sky colour
              ld (sky_floor),a
              sub a                 ; make a zero
              ld (left),a
              ld bc,768+15;783             ; 768 attributes to fill
              ld de,(scr_attr_add)  ; start of spectrum attributes after char screen
              ld hl,$c000           ; start of zx81 display file in memory
                           
here:         call set_wall_col     ;set the wall colour graduation colour
              call loop_1
              and a                 ;reset zero 
              inc hl                ;current character memory we are checking
              inc de                ;current attribute location
              dec bc                ;number of attribute cells to traverse
              ld a,b
              cp 0
              jr nz,here
              ld a,c
              cp 0             ;dec on single reg affects flags
              
              jr z,lastcol     ;colour in the last block before exiting
              jr here          

lastcol:      ld a,(sky_floor)   ; colour in the last square
                                 ; plus last 7  squares
              ld(de),a
              ld a,112         
              inc de
              ld (de),a
              inc de
              ld (de),a
              inc de
              ld (de),a
              inc de
              ld (de),a
              inc de
              ld (de),a
              inc de
              ld (de),a
              inc de
              ld (de),a
                                                                      
              ret

;start checking chars and setting colours

loop_1:        ld a, (hl)       ; get value at start of zx81 display file
               cp _mediumwall            ; top left triangle
               jr nz, next1
               ld a, (wallcol)      
               ld (de),a        ; colour it if it matches
               jp next_pos      ; go on to next char position

next1:         cp _black            ; top right triangle
               jr nz, next2
               ld a, 254        ;black paper, black ink
               ld (de),a        ; colour it if it matches
               jp next_pos      ; go on to next char position              

next2:         cp _topcorner4           ; top left triangle
               jr nz, next3
               ld a,skycol          ;paper cyan, ink 1
               ld (de),a        ; colour it if it matches
               jp next_pos      ; go on to next char position 

next3:         cp _topcorner1            ; top left triangle
               jr nz, next4
               ld a,floorcol
               ld (de),a        ; colour it if it matches
               jp next_pos      ; go on to next char position 

next4:         cp _largewall            ; look for wall character
               jr nz, next5
               ld a,  (wallcol)
               ld (de),a        ; colour it if it matches
               jp next_pos      ; go on to next char position 

next5:        cp _smallwall            ;was char 09 - lower middle of screen wall character bottom
              jr nz, next6
              ld a,  (wallcol)          
              ld (de),a
              jp next_pos

next6:        cp _mediumwall_1            ;was chr 10 - middle of screen upper wall character
              jr nz, next7
              ld a, (wallcol)         ;
              ld (de),a
              jp next_pos

next7:        cp _topleft5            ;was chr 10 - middle of screen upper wall character
              jr nz, next8
              ld a, skycol         ;
              ld (de),a
              jp next_pos

next8:        cp _hugewall
              jr nz, next9
              ld a, (wallcol)         ;
              ld (de),a
              jp next_pos

next9:        cp $8e            ;stretched wall 5
              jr nz, next10
              ld a, (wallcol)         ;
              ld (de),a
              jp next_pos

next10:       cp $8d             ;stretched wall 5 more
              jr nz, next11
              ld a, (wallcol)         ;
              ld (de),a
              ld a, (wallcol)         ;
              jp next_pos

next11:       cp $8b             ;stretched wall 5 more
              jr nz, next12
              ld a, (wallcol)         ;
              ld (de),a
              ld a, (wallcol)         ;
              jp next_pos
                         
next12:       cp $8c             ;stretched wall 5 more
              jr nz, next20
              ld a, (wallcol)         ;
              ld (de),a
              ld a, (wallcol)         ;
              jp next_pos
                 
;draw sky or floor colour as we found no matches above
        
next20         ld a,(sky_floor) ; 
               ld (de),a        ; colour it if it matches
next_pos:      ld a, (left)
               inc a
               cp 25            ; are we at 24th column?
               ld (left),a
               ret nz           ; return if not

;now do paper colour of score and nav bit on right
               ;now decrease bc by 7 & increase display pos by 7
               ;to start of next line
               sub a            ; zero a register
               ld (left),a      ; back to start
               ld a,8           ; 7 spaces to next line
loop_4:        dec bc           ;change ldir count
               inc hl
               inc de
               push af
               ld a,112         ;yellow paper, ink 9
               ld (de),a
               pop af
               and a           ;move screen print position
               dec a
               jr nz, loop_4
               dec de           ; get to start of spectrum line in the display            

               ; check if we are below the middles of the display
               ; so we change the 'white' colour to floor
               push hl
               push de
              ; 22912 is the start of the floor level
               ; de holds current position in spectrum display              


               ld hl,(scr_attr_add)
               add hl,383        ;this for display at 22528 is 22911   ; start of first floor line
               sbc hl,de        ;are we there yet?
               jp nz,exit2 ;was nz
               ld a,floorcol
               ld (sky_floor),a 
exit2:         pop de
               pop hl                              
               ret 
            
                
set_wall_col:     
                ;set the wall colour graduation colour from light (top part) to dark(bottom part of wall) in 6 increments
                ;de holds current attribute cell we are colouring in                
                push hl 
                push de
                ;de holds current attribute cell we are colouring in

                ld a,188
                ld hl,(scr_attr_add)     ;top of the display
                sub hl,de
                jr nz,setcol_1   ;check next quarter of display
                ld (wallcol),a
                jr setcol_exit 

             
setcol_1:       add a,2  
                ld hl,(scr_attr_add)
                add hl,128    ;next 1/6 of the display
                sub hl,de
                jr nz,setcol_2   ;check next 1/6th of display
                ld (wallcol),a
                jr setcol_exit

setcol_2        add a,2
                ld hl,(scr_attr_add)
                add hl,256     ;next 1/6  down of the display
                sub hl,de
                jr nz,setcol_3   ;check next 1/6th of display
                ld (wallcol),a
                jr setcol_exit  
            
setcol_3        add a,2
                ld hl,(scr_attr_add)
                add hl,384     ;    ;next 1/6 of the display
                sub hl,de
                jr nz,setcol_4   ;check next 1/6th of display
                ld (wallcol),a
                jr setcol_exit

setcol_4        add a,2
                ld hl,(scr_attr_add)
                add hl,512    ;next 1/6 of the display
                sub hl,de
                jr nz,setcol_5   ;check next 1/6th of display
                ld (wallcol),a
                jr setcol_exit  
            
setcol_5        add a,2 
                ld hl,(scr_attr_add)
                add hl,640     ;bottom 6th of the display
                sub hl,de
                jr nz,setcol_exit   ;check next 1/6th of display
                ld (wallcol),a

setcol_exit:    pop de
                pop hl
                ret

;#######################################################################             
;setup right hand side of the screen

draw_screen_right:

              ld ix,message_border1       ;top border Message
              CALL print_message
              ld ix,message_get       ;"Get Out" Message
              CALL print_message
              ld ix,message_out       ;"Get Out" Message
              CALL print_message
              ld ix,message_border4       ;top border Message
              CALL print_message
              ;do some colouring around the 'get out' words
              ld hl,22585
              ld a,148
              ld (hl),A
              ld hl,22585+6
              ld (hl),a
              ld hl,22617
              ld (hl),a
              ld hl,22617+6
              ld (hl),a
              ;print "level" words
              ld ix,message_level       ;top border Message
              CALL print_message    
;now print the level numbers
              ld ix,L00       ;top border Message
              CALL print_message
              ld ix,L01       ;top border Message
              CALL print_message
              ld ix,L23      ;top border Message
              CALL print_message
              ld ix,L45        ;top border Message
              CALL print_message
              ld ix,L67       ;top border Message
              CALL print_message
              ld ix,L89       ;top border Message
              CALL print_message
              ld ix,L1011       ;top border Message
              CALL print_message
              ld ix,L1213       ;top border Message
              CALL print_message
              ld ix,L1415
              CALL print_message
              call set_floor_colour
              ret

L00           db 6,27,134,     " 0 ",$7f
L01           db 7,27,134,     " 1 ",$7f
L23           db 8,27,134,     "2 3",$7f
L45           db 9,27,134,     "4 5",$7f
L67           db 10,27,134,    "6 7",$7f
L89           db 11,27,134,    "8 9",$7f
L1011         db 12,27,134,$d7," ",$d8,$7f
L1213         db 13,27,134,$d9," ",$da,$7f
L1415         db 14,27,134,$db," ",$dc,$7f
    
;###################################################################    

;set floor colour on right of the display - shows what floor we are on

set_floor_colour:
        xor a               ;zero a reg
        ld b,a        
        ld hl,(cur_map)     ;get our current map
        ld d,l
        nop;dec d               ;need to point 1 less
        ld e,2              
        mul de              ;multiply our current map number by 2
        ld hl,data_table
        add hl,de           ;should now be pointing to the correct place in the table
        ld e,(hl)
        inc hl
        ld d,(hl)
        ;now colour it white on screen
        ld a,135
        ld (de),a
        ret




data_table:
        dw  $58dc       ;23003-256    ;GND
        dw  $58fc       ;23004-224    ;1
        dw  $591b       ;23003-192    ;2
        dw  $591d       ;23005-192    ;3
        dw  $593b       ;23003-160    ;4
        dw  $593d       ;23005-160    ;5
        dw  $595b       ;23003-128    ;6
        dw  $595d       ;23005-128    ;7
        dw  $597b       ;23003-96    ;8
        dw  $597d       ;23005-96    ;9
        dw  $599b       ;23003-64    ;10
        dw  $599d       ;23005-64    ;11
        dw  $59bb       ;23003-32    ;12
        dw  $59bd       ;23005-32    ;13
        dw  $59db       ;23003       ;14
        dw  $59dd       ;23005       ;15
;22528 to 23296



