

;#############################################
;original code to draw maze walls here
;#############################################


;              org 34576 ;($8710 first byte after the maze definition)

        ;call l4770 ;work out the place in the maze

; ----------------
; draw the 3d view
; ----------------
; the view is divided into 7 sections that correspond to different distances:
; - section 0 is 24 characters tall and 1 character wide.
; - section 1 is 22 characters tall and 4 characters wide.
; - section 2 is 14 characters tall and 3 characters wide
; - section 3 is 8 characters tall and 2 characters wide.
; - section 4 is 4 characters tall and 1 character wide.
; - section 5 is 2 characters tall and 1 character wide.
; - section 6 is 2 characters tall and 1 character wide.
;                 1                2
;   0 1234 567 89 0 1 2 3 4 56 789 0123 4
;0  0|    |   |  | | | | | |  |   |    |0              |    |   |  | | | | | |  |   |    |0
;1  0|1   |   |  | | | | | |  |   |   1|0             0|1   |   |  | | | | | |  |   |    |0
;2  0|11  |   |  | | | | | |  |   |  11|0             0|11  |   |  | | | | | |  |   |    |0
;3  0|111 |   |  | | | | | |  |   | 111|0             0|111 |   |  | | | | | |  |   |    |0
;4  0|1111|   |  | | | | | |  |   |1111|0             0|1111|   |  | | | | | |  |   |    |0
;5  0|1111|2  |  | | | | | |  |  2|1111|0             0|1111|   |  | | | | | |  |  2|1111|0
;6  0|1111|22 |  | | | | | |  | 22|1111|0             0|1111|   |  | | | | | |  | 22|1111|0
;7  0|1111|222|  | | | | | |  |222|1111|0             0|1111|   |  | | | | | |  |222|1111|0
;8  0|1111|222|3 | | | | | | 3|222|1111|0             0|1111|222|3 | | | | | |  |222|1111|0
;9  0|1111|222|33| | | | | |33|222|1111|0             0|1111|222|33| | | | | |  |222|1111|0
;10 0|1111|222|33|4| | | |4|33|222|1111|0             0|1111|222|33| | | | |4|33|222|1111|0
;11 0|1111|222|33|4|5|6|5|4|33|222|1111|0             0|1111|222|33|4|5|6|5|4|33|222|1111|0
;12 0|1111|222|33|4|5|6|5|4|33|222|1111|0             0|1111|222|33|4|5|6|5|4|33|222|1111|0
;13 0|1111|222|33|4| | | |4|33|222|1111|0             0|1111|222|33| | | | |4|33|222|1111|0
;14 0|1111|222|33| | | | | |33|222|1111|0             0|1111|222|33| | | | | |  |222|1111|0
;15 0|1111|222|3 | | | | | | 3|222|1111|0             0|1111|222|3 | | | | | |  |222|1111|0
;16 0|1111|222|  | | | | | |  |222|1111|0             0|1111|   |  | | | | | |  |222|1111|0
;17 0|1111|22 |  | | | | | |  | 22|1111|0             0|1111|   |  | | | | | |  | 22|1111|0
;18 0|1111|2  |  | | | | | |  |  2|1111|0             0|1111|   |  | | | | | |  |  2|1111|0
;19 0|1111|   |  | | | | | |  |   |1111|0             0|1111|   |  | | | | | |  |   |    |0
;21 0|111 |   |  | | | | | |  |   | 111|0             0|111 |   |  | | | | | |  |   |    |0
;22 0|11  |   |  | | | | | |  |   |  11|0             0|11  |   |  | | | | | |  |   |    |0
;23 0|1   |   |  | | | | | |  |   |   1|0             0|1   |   |  | | | | | |  |   |    |0
;24 0|ssss|sss|ss|s|s|s|s|s|ss|sss|sss |0              |ssss|sss|ss|s|s|s|s|s|ss|sss|sss |0
;
; the status message appears on row 23 between columns 1 and 22.
;
; section 6 will display as chequerboard if there is a wall at this distance, or black if not.
; rex is only visible at distance 5 or closer.
;
;
; the following actions are performed:
; - draw the wall side / passageway gap next to the player on the right (section 0)
; - draw the wall side / passageway gap next to the player on the left (section 0)
; - enter a loop for sections 1 to 5 performing the following actions:
;    - if a wall is in front of the player then
;      - draw the wall face
;      - if at the exit then
;        - draw the exit pattern
;    - else
;      - draw the wall side / passageway gap on the right
;      - draw the wall side / passageway gap on the left
; - draw distance 6, which is either a wall face (chequerboard) or further distance not visible (black)
; - enter a loop from section 5 and moving towards the player performing the following actions:
;   - draw all visible wall faces on the left
;   - draw all visible wall faces on the right
; - if rex is ahead and within visible range then
;   - draw rex

; hl=location of the player.
; de=the offset ahead in the direction player is facing.
; bc=the offset from the direction the player is facing to the location to the right.

;cannot go 12 or more or will break

;c=11 = depth 5  wall=
;c=10 = depth 4  wall=

;c=8 = d3  wall=
;c=5 = d1  wall=
;c=1 = d0  wall=



; ############################
; draw wall in front of player
; ############################

; a wall has been found directly in front of the player within visible range and so a wall face must be drawn centred within the view.
; the wall face is one character wider than it is high.

draw_front_view:

;        ld a,(depth)            ;find out how far we can see - will never be higher than 6
        ld a, (maxview)
        cp 6
        ret z				               ;too far away so return doing nothing
		      cp 5
        ret z
        jp nz,set4
        ld c,12
		      ld a,_smallwall			      ;this is the character to draw (brick pattern)
		      ld (var1),a
            ;just storage variable
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
        ld a,_largewall
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
;draw colours     ; go through char display file and paint colours
;#################################################################
;     on the next could use ULA for background and Layer 2


wallcol       equ 16;72             ; blua paper black ink
skycol        equ 8;40            ; cyan paper, black ink 104
floorcol      equ 96             ; green paper, black ink
corridcol     equ 112            ; yellow paper, black ink   
sky_floor     db  40            ;store current sky or floor colour


; go through the display file at c000, check the character, change the colour
; if at row 26, start on next line at far left (0)
; do it again until you reach line 24 and column 25           

; display is at location c000

draw_colours:
draw_attr_top:                  ; draw top blue sky

              ld a, skycol        ; set the sky colour
              ld (sky_floor),a
              sub a             ; make a zero
              ld (left),a
              ld bc,783          ; 768 attributes to fill
              ld de,22528;+32768       ; start of spectrum attributes
              ld hl,$c000;a701       ; start of zx81 display file in memory
                            ;ld (hl),a
here:         call loop_1
              and a             ;reset zero 
              inc hl
              inc de
              dec bc
              ld a,b
              cp 0
              jr nz,here
              ld a,c
              cp 0             ;dec on single reg affects flags
              
              jr z, lastcol     ;colour in the last block before exiting
              jr here          

lastcol:      ld a,(sky_floor)   ; colour in the last square
                                 ; plus last 7 yellow squares
              ld(de),a
              ld a,112          ;yellow paper ink 9
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
               ld a,wallcol      ;72
               ld (de),a        ; colour it if it matches
               jp next_pos      ; go on to next char position

next1:         cp _black            ; top right triangle
               jr nz, next2
               ld a,wallcol
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
               ld a, wallcol
               ld (de),a        ; colour it if it matches
               jp next_pos      ; go on to next char position 

next5:        cp _smallwall            ;was char 09 - lower middle of screen wall character bottom
              jr nz, next6
              ld a, wallcol          ;blue ink,green paper
              ld (de),a
              jp next_pos

next6:        cp _mediumwall_1            ;was chr 10 - middle of screen upper wall character
              jr nz, next7
              ld a,wallcol         ; blue ink, cyan paper
              ld (de),a
              jp next_pos

next7:        cp _topleft5            ;was chr 10 - middle of screen upper wall character
              jr nz, next8
              ld a, skycol         ; blue ink, cyan paper
              ld (de),a
              jp next_pos
                                          
;draw sky or floor colour as we found no matches above
        
next8          ld a,(sky_floor) ; 
               ld (de),a        ; colour it if it matches
next_pos:      ld a, (left)
               inc a
               cp 25            ; are we at 24th column?
               ld (left),a
               ret nz           ; return if not

;now do paper colour of score and nav git on right
               ;now decrease bc by 7 & increase display pos by 7
               ;to start of next line
               sub a            ; zero a register
               ld (left),a      ; back to start
               ld a,8           ; 7 spaces to next line
loop_4          dec bc           ;change ldir count
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


               ld hl,22911   ; start of first floor line
               sbc hl,de        ;are we there yet?
               jp nz,exit2 ;was nz
               ld a,floorcol
               ld (sky_floor),a 
exit2          pop de
               pop hl                              
               ret 

