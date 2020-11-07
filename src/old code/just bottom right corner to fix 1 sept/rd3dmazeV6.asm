; written by me, richard dodds (dickydodds.com) beginning may 2018

; some useful info:-
; the zx81 character based screen is drawn in memory and then copied to the spectrum screen. 

;2nd oct 2018 - layer 6 completed - can print udg and spectrum
;             character set now.
;20th oct 2018 - left side completed except for multiple blocks in
;layer 2, 3 & 4
;11th oct - left side done and colours added.
;V3. 22 nov - left side properly fixed - had bugs on top and bottom of maze
;V4 27 nov. Removed the maze generation code from Malcolm Evans
;V6 - 20 June 2018 - fixed end wall distance. Started chopping into manageable chunks.

;

;For SJASMPLUS

        ; Allow the Next paging and instructions
;        DEVICE ZXSPECTRUMNEXT

        ; Generate a map file for use with Cspect
;        CSPECTMAP "project.map"


;        INCLUDE 1-rd3dmazeV6.asm  ; init and maze itself
;        INCLUDE 2-rd3dmazeV6.asm ; draw maze on screen, player direction, 
;        INCLUDE 3-rd3dmazeV6.asm ; check walls in front of player

        load "1-rd3dmazeV6.asm"  ; init and maze itself
        load "2-rd3dmazeV6.asm" ; draw maze on screen, player direction,
        load "3-rd3dmazeV6.asm" ; check walls in front of player

;for info...
;load "4-rd3dmazeV6.asm" ; draw left side of maze
;load "5-rd3dmazeV6.asm" ; draw wall in front of player
;load "6-rd3dmazeV6.asm" ; draw right side of maze


;##################################################
;##################################################
;##################################################
;##################################################
;##################################################
;#                                                #
;#               main game loop here              #
;#                                                #
;##################################################
;##################################################
;##################################################
;##################################################
;##################################################

;       org $9000
       
main:

;;; dont forget to create your character set on the next! ;;

;set the player direction based on keypress
; 0=north, 1=west, 2=south, 3=east

start_game:

; jump straight into sjasmplus debugger
;        BREAK
; set stack pointer in lower 16k at 32767
;        ld sp,28671

              ld a,2            ;set default to be south
              ld (player_dir),a

;remember to set maze_highbyte for current maze
              
;start on maze map 0
_map:
              ld a,0            
              call set_map      ;set our map

;              ld h,$71          ;set at maze 1 bottom maze
              ld l,01              ;top left of maze
              
              ld (player_pos),hl
                    
main_loop:

;draw the compass
              di

              call clear_char_screen    ;clear screen @c000

;              call compass         ; draw compass

              call get_distance ; get distance we can see
                                ; and save depth we can see
              ; load de is done when getting the distance above
              ; we need de to hold the jump value in the maze direction
              ; we are looking             

              call draw_left_side   ; start drawing the left side of the maze                                  

              ;we need to repopulate var furthest_point

              call get_distance     ; get distance we can see
                                    ; and set de accordingly
                                    ; and save depth we can see
              
              call draw_right_side  ; start drawing the right side of the maze


            ;  call get_distance    ; got to get how far we can see again

              call draw_front_view  ; draw wall in front of player

              ;check if we are at an end wall. If so, draw walls left
              ;and right to simulate the long outside edge wall

              call draw_side_walls
                      
              ;my print used to print screen @c000 to 16384 inc udg's

              call my_print         ;copy to screen from c000

              call draw_colours     ;colourise the display
                  
              call compass          ; draw compass

              ei                    ;enable inturupts in case we return to BASOC



;#######################################
;now move based on keypress
;#######################################

;Now set our view direction based on keypress

;c bit values: 1 = 0 fire
 ;             2 = 5 right
 ;             4 = 7 up (forward)
 ;             8 = 6 down
 ;            16 = 8 left


;set the player direction based on keypress
; 0=north, 1=west, 2=south, 3=east

;              ld a,0            ;set default to be north
;              ld (player_dir),a

;######################################
;speed of game set here
;######################################

wait4key:     ld b,3           ;delay loop
loop19:       halt
              dec b
              jp nz,loop19

;######################################

              call get_keys     ;keypress in C register

              ld a,c
              or a              ;clear flags
              jp z,wait4key     ;wait for a keypress b4 continuing

              cp 16              ; 8 (right) pressed
              jp z,plus

              cp 4              ;7 (forward) pressed
              jp z,move_forward

              cp 8
              ret z              ;6 (down) pressed
 ;            jp z,move_back
 ;             jp wait4key       ;not used yet
              
              cp 2             ; 5 (left) pressed
              jp z,minus

              cp 1  
              call print_maze
              halt
              halt
              halt
              jp wait4key           ; 0 pressed
              ;ret z             ;exit to basic if 0 pressed

;should never get here as we intercept 0 above.
              ret

go1:          ld (player_dir),a
              jp main_loop      ;start again
              
  
plus:
              ld a,(player_dir)
              inc a
              cp 4          ;if its 4, make it 0 as it cant be >3
              jp nz,go1     ;start game loop if its not 4
              sub a         ;make it 0 (wraparound
              jp go1

minus:        ld a,(player_dir)
              dec a
              cp 255
              jp nz,go1         ;continue game if not 0  
              ld a,3            ;wraparound
              jp go1


;how do i implement a less-than/greater-than test in assembly?

;a: to compare stuff, simply do a cp, and if the zero flag is set,
;a and the argument were equal, else if the carry is set the argument was greater, 
;and finally, if neither is set, then a must be greater 
;(cp does nothing to the registers, only the f (flag) register is changed). 

move_forward:   
             ; ld a,(depth)          ;if our depth =0 ie we are
              ld a,(maxview)          ;if our depth =0 ie we are
                                    ;in front of a wall face
                                    ;then do nothing
              inc a
              dec a
              jp z,wait4key

              call load_walk        ; get walk forward value to add
              ld hl,(player_pos)    ;get our current position
              ld a,h                ;save our current H value for comparing later
              add hl,de              ;move our position forward in our view

              cp h              ;have we crossed 256 byte boundry?
              jp nz,main_loop   ;we have exited our boundry so dont
                                ;move our view anywhere.
              ;now test if l=0
;              ld a,l
              inc l                  
              dec l             ;are we at position 0? Exit if yes and do nothing
              ;cp 0
              jp z,main_loop   ;we are at location 0 in the maze, so, again do nothing
                                ;and just exit so we stay at position 1

;;;;;;;;;;#########################
              ;now check if l=255 ; 
;              cp 255                ;are we at the bottom edge of the maze
;              jp z,main_loop

              ;we ARE at the bottom row so DO NOT MOVE FORWARD
              ld (player_pos),hl
              jp main_loop          ;continue to the game loop



              
;we get here as we are not at the bottom of the maze.
move_1:       cp 16                 ;are we at the top edge of the maze?
              jp nc,main_loop
              ld (player_pos),hl    ;save our new position
              
;we are at the TOP of the maze so dont saaveour addition to HL
              jp main_loop          ;continue to the game loop


;jp nz,go1         ;continue game if not 0  
                         ;wraparound
;              jp go1
                         
move_back:
              jp main_loop


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

                 
    
   
;##################################################
; draw the maze in memory
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

;chck if maxview set - if so, dont check for wall
;in front of player anymore as there alreay is a wall set

loop2:        ld a,(flags)
              bit 0,a           ;if 1, then already set
              jp nz,check_mh
                      
              ld a,(hl)         ; this is the furthest point we can see
              cp _mw ;=128      ;is it a wall here
              jp nz, check_mh   ;if no wall check for end wall
                                
              ld a,b            ;there is a wall if we get here
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


;###################################################
;load other programs

;for SJASMPLUS
;    INCLUDE "4-rd3dmazeV6.asm" ; draw left side of maze
;    INCLUDE "5-rd3dmazeV6.asm" ; draw wall in front of player
;    INCLUDE "6-rd3dmazeV6.asm" ; draw right side of maze

    load  "4-rd3dmazeV6.asm" ; draw left side of maze
    load "5-rd3dmazeV6.asm" ; draw wall in front of player
    load "6-rd3dmazeV6.asm" ; draw right side of maze


;#####################################################


;###################################################
; Get Keystroke Routine from Your Sinclair Magazine
; From Your Sinclair #22 (Oct.1987)
;###################################################

        
get_keys:
 ;
 ;      YS_KEYS
 ;
 ;A,HL,DE corrupt
 ;B=0, key in C 


 ;Keyboard Scanning
 ;by Pete Cooke
 ;from Your Sinclair #22 (Oct.1987) 

 ;prog for Your Sinclair
 ;
 ;file for Hisoft GENS
 ;assembler but should
 ;be suitable for most
 ;assemblers on the market
 ;
 ;Reads the keyboard
 ;Returns with C
 ;holding L/R/U/D/F
 ;
 ;bit 4,C left
 ;bit 3,C right
 ;bit 2,C up
 ;bit 1,C down
 ;bit 0,C fire
 ;
 ;bit set to 1 if pressed
 ;
 ;keys are chosen by
 ;values in KEYTAB
 ;
readke  ld   hl,keytab
        ld   bc,$0500
 ;
 ;5 keys to read
 ;
read_1  ld   a,(hl)
        rra
        rra
        and  $1e
        ld   e,a
        ld   d,0
 ;
 ;2*the row number
 ;
        ld   a,(hl)
        inc  hl
        push hl
 ;
 ;save place in KEYTAB
 ;
        ld   hl,keyadd
        add  hl,de
        ld   d,a
 ;
 ;index port addresses
 ;
        push bc
        ld   c,(hl)
        inc  hl
        ld   b,(hl)
        in   a,(c)
        inc  b
        dec  b
        jr   z,read_2
        cpl
read_2  ld   e,a
 ;
 ;read the port
 ;and flip bits if not
 ;Kempston
 ;
        pop  bc
        pop  hl
 ;
 ;and get back BC+HL
 ;
        ld   a,d
        and  $07
        jr   z,read_4
 ;
read_3  rr   e
        dec  a
        jr   nz,read_3
 ;
 ;rotate L so bit needed
 ;is in bit 0
 ;
read_4  rr   e
        rl   c
 ;
 ;rotate the bit into C
 ;
        djnz read_1
        ret
 ;
 ;exit B=0
 ;     C=keys
 ;
 ;A,HL,DE corrupt
 ;
 ;
 ;port addresses of
 ;the keyboard rows
 ;
keyadd dw 63486,64510,65022,65278,61438,57342,49150,32766
        dw 31 ;*Kempston*
 ;
 ;
 ;KEYTAB holds the position
 ;of each key as
 ;1/2 row number*8 plus
 ;distance from the edge
 ;eg. P = 5*8+0
 ;    O = 5*8+1
 ;    Q = 1*8+0
 ;    4 = 0*8+3
 ;
keytab db 0*8+4,4*8+4,4*8+3,4*8+2,4*8+0
 ;           5      6     7      8   0
 ;;bit values: 1 = 0 fire
 ;             2 = 8 right
 ;             4 = 7 up
 ;             8 = 6 down
 ;            16 = 5 left

; keytab db 5*8+1,5*8+0,2*8+1,3*8+2,7*8+0
 ;
 ;set for O,P,S,X,space
 ;
 ;for a Kempston joystick
 ;substitute
 ;
 ;       db 8*8+1,8*8+0,8*8+3,8*8+2,8*8+4
 ;
end_k nop

;##############################################
;##############################################

;set map - sets hl to start of map to draw
;a holds the map number = 0 to 15

set_map:

        ld hl,map_0             ;start of map data 256 bytes each
        ld (cur_map),a          ;save our cur map
        ld (map_start),hl

        dec a
        inc a                   ;exit if its map 0

        ld a,h
        ld (maze_highbyte),a
        ret z       ;if a is 0, just return for map_0

        ld a,(cur_map)
loop3   inc h                   ; times by 256
        dec a
        jr nz, loop3
        ld (map_start),hl
        ld a, h
        ld (maze_highbyte),a
        ret

;##############################################
;##############################################

                                        
;##############################################
;misc data
;various variables
;udg charachter set 
;##############################################

        org 64000
 
;variables
;-----------------------------------------------

player_pos: dw $0                  ; only when in the main game loop
                               ; holds the low byte of the current insertion location when inserting a passageway into the maze.
          
;l4083:  db 134               ; high byte of the maze location data
;l4084:  db 08                ; holds the desired length of the passageway beign inserted when constructing the maze.
maxview: db 6                   ;holds how far we can see before
                                ;hitting a wall
;l4085:  db $01               ; holds the passageway direction when inserting a passageway into the maze ($00=north, $01=west, $02=south, $03=east). 

flags:  db 0                 ; flags:
                             ;na   bit 7: 1=the player has been caught.
                             ;na   bit 6: 1=the player has moved forwards.408a
                             ;na   bit 5: 1=the player has not moved and so there is no need to redraw the view of the maze.
                             ;na   bit 4: 1=the exit is visible.
                             ;na   bit 3: 1=rex has moved.
                             ;na   bit 2: 1=rex has moved into a new location.
                             ;na   bit 1: 1=rex has his left foot forward, 0=rex has his right foot forward.
                             ; bit 0: maxview used bit 

var1:   db 0  ; used for printing
              
var2:   db 0  ; used for printing

depth:  db 0  ; stores our depth of field when we are looking
l4086:  db 0

player_dir:                  
        db 0  ;; only when in the main game loop
de_count:
        dw 0  ;used to hold 2 bytes of reg de for maze locating info

left     dw 0000
right    dw 0000
var3     dw 0000     ;misc. used in drawing walls
var4     dw 0000     ;misc. used in drawing walls
var5     dw 0000     ;misc - used in drawing walls
var6     dw 0000     ;stores current maze block check position

end_wall db 0        ;stores whether current wall being draw is
                     ;an outside maze wall or not (as we want to treat
                     ;this differnetly when drawn in future
var7     dw 0        ;misc loop counter in walls             
var8     dw 0        ;not used
var9     dw 0        ;not used
var10    db 0        ;used for maze wall drawing at depth 5
lr_wall  db 0        ;used for left and right wall drawing in draw_side_walls routine
var12    db 0        ;not used
cur_map  db 0        ;stores current map to draw or show           
map_start dw 0       ;tores the map start address

d_file   dw $c000    ;char display in memory at 49152

furthest_point dw 0 ;store the address of the furthest point
                    ;we can see in the maze from our position.
blockid  db 0        ;stores  block position of layer 5 for wall drawing
maze_highbyte db $71 ;holds high byte of current maze in use



;##############################################
;start of block draw data
;##############################################

  ;      org $E000   ; 57344 - top 8k





;##############################################
;udg charachter set starts at 65080
;##############################################

;        org $FBFF  ;(64511 for 128 udg's) was 65080
org 64512  ;=65080-568
;hex char										ram-add	item
													
;##############################################
      ;UDG Characher Defs											
;##############################################							
_chars:
db	0,0,0,0,0,0,0,0 ;80	65080		
db	0,0,0,0,0,0,0,0	;81	65088		
db	0,0,0,0,0,0,0,0	;82	65096		
db	0,0,0,0,0,0,0,0	;83	65104		
db	0,0,0,0,0,0,0,0	;84	65112		
db	0,0,0,0,0,0,0,0	;85	65120		
db	0,0,0,0,0,0,0,0	;87	65128		
db	0,0,0,0,0,0,0,0	;88	65136		
db	0,0,0,0,0,0,0,0	;89	65144		
db	0,0,0,0,0,0,0,0	;89	65152		
db	0,0,0,0,0,0,0,0	;8a	65160		
db	0,0,0,0,0,0,0,0 ;8b	65168		
db	0,0,0,0,0,0,0,0	;8c	65176		

;extra layer 5 chars
db	255,63,243,159,244,47,249,143 	 ;8d	small wall stretched (layer 3)
db	255,140,255,38,255,140,255,38 	 ;8e	small wall stretched (layer 3)

 ;Section 2 left and right UDG	
DB 0,0,0,0,0,3,31,255              ;8f 65200  top right Section 2 (1)
DB 0,0,1,15,127,255,255,255        ;90 65208  top right Section 2 (2)
DB 7,63,255,255,255,255,255,255    ;91 65216  top right Section 2 (3)	

DB 255,31,3,0,0,0,0,0              ;92 65224   bottom right Section 2 (1)
DB 255,255,255,127,15,1,0,0        ;93 65232   bottom right Section 2 (2)
DB 255,255,255,255,255,255,63,7    ;94 65240   bottom right Section 2 (3)

DB 224,252,255,255,255,255,255,255 ;95 65248   top left Section 2 (1)
DB 0,0,128,240,254,255,255,255     ;96 65256   top left Section 2 (2)
DB 0,0,0,0,0,192,248,255           ;97 65264   top left Section 2 (3)		

DB 255,255,255,255,255,255,252,224 ;98 65272   bottom left Section 2 (1)
DB 255,255,255,254,240,128,0,0     ;99 65280   bottom left Section 2 (2)
DB 255,248,192,0,0,0,0,0           ;9a 65288   bottom left Section 2 (3)

db	128,192,224,240,245,250,245,250	;9b	65296		layer 5 left top
db	245,250,245,250,240,224,192,128	;9c	65304		layer 5 left bottom
db	1,3,7,15,95,175,95,175         	;9d	65312   layer 5 right top		
db	95,175,95,175,15,7,3,1         	;9e	65320		layer 5 right bottom
db	85,170,85,170,85,170,85,170    	;9f	65328		chequer
db	85,170,85,170,0,0,0,0          	;a0	65336		top chequer
db	0,0,0,0,85,170,85,170          	;a1	65344		bottom chequer
db	0,0,0,0,255,255,255,255        	;a2	65352		bottom black
db	255,255,255,255,0,0,0,0        	;a3	65360		top black
db	255,8,8,8,255,128,128,255      	;a4	65368		brick pattern
db	153,200,100,50,25,140,206,171  	;a5	65376		top left brick diag
db	16,40,16,124,16,40,40,68       	;a6	65384		man
db	24,110,125,30,31,46,39,109     	;a7	65392		rex
db	255,165,255,189,189,255,165,255	;a8	65400		fancy square
db	128,192,224,240,255,255,255,255	;a9	65408		top left 5
db	1,3,7,15,255,255,255,255       	;aa	65416		top right 5
db	255,255,255,255,240,224,192,128	;ab	65424		bot left  5
db	255,255,255,255,15,7,3,1       	;ac	65432		bot right 5
db	255,229,255,253,253,255,255,255	;ad	65440		top right fancy
db	255,167,255,191,191,255,255,255	;ae	65448		top left fancy
db	255,255,255,255,255,255,255,255	;af	65456		all black
db	255,254,252,248,240,224,192,128	;b0	65464		top left triangle
db	255,127,63,31,15,7,3,1         	;b1	65472		top right triangle
db	1,3,7,15,31,63,127,255         	;b2	65480		bot right triangle
db	128,192,224,240,248,252,254,255	;b3	65488		bot right triangle

db	255,85,255,170,255,85,255,170	  ;b4	65496		small wall
db	255,136,136,255,162,162,255,128	;b5	65504		mediumwall_1
db	255,136,136,136,255,224,192,128	;b6	65512		largewall
db	255,170,255,170,255,170,255,170 ;b7	65520		mediumwall
db	255,136,136,136,255,128,128,128 ;b8	65528		hugewall

;layer 5 section 3 right TOP

db 0,0,0,255,255,255,255,255       ;b9 top right section 3 (4)
db 0,0,255,255,255,255,255,255     ;ba top right section 3 (3)
db 0,255,255,255,255,255,255,255   ;bb top right section 3 (2)
db 255,255,255,255,255,255,255,255 ;bc top right section 3 (1)

;layer 5 section 3 right BOTTOM

db 255,255,255,255,255,0,0,0       ;bd top right section 3 (6)
db 255,255,255,255,255,255,0,0     ;be top right section 3 (6)
db 255,255,255,255,255,255,255,0   ;bf top right section 3 (6)
db 255,255,255,255,255,255,255,255 ;c0 top right section 3 (6)

;layer 5 section 3 left TOP TBD

db 255,255,255,255,255,0,0,0       ;c1 bottom right section 3 (5)
db 255,255,255,255,255,255,0,0     ;c2 bottom right section 3 (6)
db 255,255,255,255,255,255,255,0   ;c3 bottom right section 3 (6)
db 255,255,255,255,255,255,255,255 ;c4 bottom right section 3 (6)

;layer 5 section 3 left BOTTOM TBD

db 0,0,0,255,255,255,255,255       ;c5 bottom right section 3 (5)
db 0,0,255,255,255,255,255,255     ;c6 bottom right section 3 (6)
db 0,255,255,255,255,255,255,255   ;c7 bottom right section 3 (6)
db 255,255,255,255,255,255,255,255 ;c8 bottom right section 3 (6)


;layer 5 section 4 right TOP

db 0,0,0,0,0,0,0,255               ;c9 top right section 3 (4)
db 0,0,0,0,0,0,255,255             ;ca top right section 3 (4)
db 0,0,0,0,255,255,255,255         ;cb top right section 3 (3)
db 0,0,255,255,255,255,255,255     ;cc top right section 3 (2)
db 0,255,255,255,255,255,255,255   ;cd top right section 3 (1)

;layer 5 section 4 right BOTTOM

db 255,0,0,0,0,0,0,0               ;ce top right section 3 (6)
db 255,255,0,0,0,0,0,0             ;cf top right section 3 (6)
db 255,255,255,255,0,0,0,0         ;d0 top right section 3 (6)
db 255,255,255,255,255,255,0,0     ;d1 top right section 3 (6)
db 255,255,255,255,255,255,255,0   ;d2 top right section 3 (6)


;Extra wall5
db	249,63,243,159,244,47,249,143 	 ;c9	small wall stretched more
db 255,15,255,31,255,15,255,15	   	;ca	small wall stretched
db 240,15,224,31,224,15,112,15	   	;ca	small wall stretched


;END_PROGRAM


;for SJASMPLUS
;;
;; Set up the Nex output
;;

        ; This sets the name of the project, the start address, 
        ; and the initial stack pointer.
;        SAVENEX OPEN "3dmaze.nex", start_game  ;, END_PROGRAM

        ; This asserts the minimum core version.  Set it to the core version 
        ; you are developing on.
;        SAVENEX CORE 2,0,0

        ; This sets the border colour while loading (in this case white),
        ; what to do with the file handle of the nex file when starting (0 = 
        ; close file handle as we're not going to access the project.nex 
        ; file after starting.  See sjasmplus documentation), whether
        ; we preserve the next registers (0 = no, we set to default), and 
        ; whether we require the full 2MB expansion (0 = no we don't).
;        SAVENEX CFG 7,0,0,0

        ; Generate the Nex file automatically based on which pages you use.
;        SAVENEX AUTO

