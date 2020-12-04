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
;2019 - done a load of stuff!
;Oct 2020 - moved to SJASMPlus and implemented backbuffer
;Oct 19 2020 - added ULANext colours and removed maze printing routine that used ROM - implemented M/C one.
;Nov 23rd 2020 - got switch graphics working.
;dec 2nd 2020 - added rudimentary sound and got the maze exit transition working
;dec 4th 2020 - exit to basic done when you exit level 0



;For SJASMPLUS

        ; Allow the Next paging and instructions
        DEVICE ZXSPECTRUMNEXT

        ; Generate a map file for use with Cspect
        CSPECTMAP "project.map"


  ;      INCLUDE 1-rd3dmazeV6.asm  ; init and maze itself
  ;      INCLUDE 2-rd3dmazeV6.asm ; draw maze on screen, player direction, 


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
      
main:           org 32768

;set the player direction based on keypress
; 0=north, 1=west, 2=south, 3=east

start_game:    di       ;disable interrupts

;first, clear the 2 ULA bank screens as they are at ROM location 0
                          
              NEXTREG $50,10
              CALL clsULA
              NEXTREG $50,14
              CALL clsULA
                     
;setup ULA Plus Palette

              call Setup_palette

; jump straight into sjasmplus debugger
      ;  BREAK
        
;SET DEFAULT PLAYER POSITION AND DIRECTION
; 0=north, 1=west, 2=south, 3=east
              ld a,2            ;set default to be south
              ld (player_dir),a

              ;make sure our exit door is closed
              xor a                 ;reg a=0
              ld (show_exit),a
              ;make sure our switch is up = 0 = not pulled
              ld (switch_pulled),a

;remember to set maze_highbyte for current maze
              
;start on maze map 0
a_map:
              ld a,2            
              call set_map      ;set our map

;              ld h,$71          ;set at maze 1 bottom maze
              ld l,01              ;top left of maze
              
              ld (player_pos),hl
                    
main_loop:


;set border to black - the beep sound makes it red so cant use this :(
           ;   ld c,254
            ;  ld a,39  ;black
            ;  ld a,64
            ;  out (c),a
;0=red
;32=red
;34 purple
;64 = red
;254 = off white
;244 cyan
;234 purple
;224 red
;214 whitish
;204 cyan
;203 purple

;set CPU Speed
              ;set CPU Speed Mhz
              ;0 = 3.5
              ;1 = 7 
              ;2 = 14 
              ;3 = 28
              nextreg 7,1

              ;put standard printing back to black text & white paper
            ;  ld a,98
            ;  ld (att),a

              call clear_char_screen    ;clear screen @c000

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

              call draw_front_view  ; draw wall in front of player

              ;check if we are at an end wall. If so, draw walls left
              ;and right to simulate the long outside edge wall

              call draw_side_walls
          
              ;draw screen at mem location 0000
              ;my print used to print screen @c000 to 16384 inc udg's 

              call my_print         ;copy to screen from c000
            
              ;we need to copy the colours to an alternate memory screen then copy them back to the main screen
              ;we do this because we use the alternate colour screen when we transition between levels
 
             call draw_colours     ;colourise the display but store at address 'attr_screen'
              
              call copy_colours     ;copy colour map to screen 

              ;make sure we point to our character set
              ld hl,charset_1-256
              ld (base),hl
              call compass          ; draw compass

;------------------------------------------------------------------------
              ;see if we need to draw the door or switch
    ld a,1
    ld (switch_pulled),a
        
              call draw_door        ;see if we need to draw a door
              call draw_switch     ;see if we need to draw a switch
;----------------------------------------------------------------------
;setup right hand side of the screen
              call draw_screen_right

              ;do the walking sound
	          ld e,10		;10 for the walk sound
              call walk_sound

              ;now flip the screen into the visible screen
              call FlipULABuffers_peter



;set CPU Speed
              ;set CPU Speed Mhz
              ;0 = 3.5
              ;1 = 7 
              ;2 = 14 
              ;4 = 28
              nextreg 7,0

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


;######################################
;speed of game set here
;######################################

              call pause         ;slow down the game here

wait4key:
              call get_keys      ;keypress in C register
              ld a,c
              or a               ;clear flags
              jp z,wait4key      ;wait for a keypress b4 continuing

              ;check if its the map key and have we already pressed it
              ld b,a             ;save our key
              ld a,(map_show)    ;get our last pressed map key
              sub b              ;map key is 0 =1 in reg a
                                 ;1= we are already showing the map, 0 says we are not
              jr z,wait4key      ;zero flag set if map_show=1 so do nothing

              xor a               ;make reg a zero
              ld (map_show),a
              ld a,b              ;now carry on :)

              cp $20;16              ; 8 (right) pressed
              jp z,plus
        
key_x         cp 1;8               ;x pressed. (old) 8=6 (down) pressed
              jp nz, comp_4      ;carry on if not pressed otherwise return to BASIC
              nextreg $43,$0E      ;turn off ulanext
              nextreg $69,0      ;turn off ula banking
              NEXTREG $50,$FF
              NEXTREG $52,$0A 
              ld bc,$7ffd
              ld a, $ff
              out (c),a
              ld hl, $535c          ;restore this sysvar
              ld (hl),0
              ld hl, $5b67          ;restore this sysvar
              ld (hl),0
              ld iy,$5c3a

              ei
              ret                ;return to BASIC
   
comp_4:       cp 8;4               ;7 (forward) pressed
              jp z,move_forward
           
              cp 4;2               ; 5 (left) pressed
              jp z,minus

              ;0 was pressed or we never get here!
              xor b             ;make b zero
              ld a,(map_show)
              sub b,a           ;exit if b=1 as we are already showing the map!
              jp nz,wait4key 
              inc a             ;a=1 to show we pressed 6 to show the map
              ld (map_show),a   ;save it
              push hl 
            
              ld (map_show),a   ;save that we have pressed 6 - reg a = 1

              CALL DRAW_MAP

              pop hl

              jp wait4key           

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
;and finally, if neither is set, then reg 'a' must be greater 
;(cp does nothing to the registers, only the f (flag) register is changed). 

move_forward:   

;----------------------------------------------------------------------------
;1st, check if we are trying to enter an open exit door
;so, is the door open?
             
; door will always face NORTH. 
; show door type = 0 = front, 1 = side

           ;  ld (show_exit),a
             ;are we facing south?
             ld a,(player_dir)
             sub 2                  ;2 = south
             jr nz,cont_a           ;if not, just continue in the normal way

             ld hl,(player_pos)
             ld de, $0010           ; (+16) to go to next line in front of us - south
             add hl,de
             ld a,(hl)
             cp _me                 ;is it our DOOR block?
             jr nz,cont_a           ;if not, just continue in the normal way
             ;YES its a door - so exit through it - but only if we are looking south
             ld a,(switch_pulled)
             and a
             jr z,cont_a            ;if not, just continue in the normal way
;Door is in front of us AND open so lets exit!

           ; reset the switch pulled back to off position
            xor a
            ld (switch_pulled),a
            
;reset switch sound variable
            ld (switch_sound ),a

;need to set the player start position now.  - MOVED TO EXIT_ANIM ROUTINE            

 ;           ld a,(cur_map)
 ;           dec a               ;point to our next map  
 ;           call set_map      ;set our map
 ;           ld l,01              ;top left of maze
 ;           ld (player_pos),hl

;draw exit animation
            ;we moved forward and overwrote the door so redraw it
            nextreg 7,3             ;set cpu speed to max

            call exit_anim

;**********************************************************************  
;GAME EXIT CHECK  
;check if we got past level 0 - if so exit to BASIC
            ld a,(game_exit)
            cp 0
            ret z
;**********************************************************************

            ;now flip the screen into the visible screen
            call FlipULABuffers_peter

            jp wait4key             ;screen is already drawn so dont draw it again.
;--------------------------------------------------------------------------------
cont_a:      
;1st, check if we are trying to flick the switch on
;so, is the door open?
             
; switch will always face NORTH. 
; show switch type = 0 = off, 1 = on

             ;are we facing south?
             ld a,(player_dir)
             sub 2                  ;2 = south
             jr nz,cont_b           ;if not, just continue in the normal way

             ld hl,(player_pos)
             ld de, $0010           ; (+16) to go to next line in front of us - south
             add hl,de
             ld a,(hl)
             cp _ms                 ;is it our SWITCH block?
             jr nz,cont_b           ;if not, just continue in the normal way
             ;YES its a switch - so mark it as switched on
             ld a,1
             ld (switch_pulled),a

;draw switch 
            call draw_switch      ;draw our switch
            jp main_loop          ;jump to our next level
;--------------------------------------------------------------------------------

cont_b:       ld a,(maxview)         ;if our maximum view depth = 0 ie we are
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

;##########################################################################
;Pause routine for slowing down the game

pause:        push hl
              push bc
              ld b,1           ;delay loop
loop19:       ;halt             ;no interrupts!
              ld hl,10000
abc:          dec hl
              ld a,h
              dec a
              ;dec h
              jr nz,abc
              dec b
              jp nz,loop19
              pop bc
              pop hl
              ret
;##########################################################################

;load other programs

;for SJASMPLUS

    INCLUDE "1-rd3dmazeV6.asm"  ; init and maze itself
    INCLUDE "2-rd3dmazeV6.asm" ; draw maze on screen, player direction,
    INCLUDE "3-rd3dmazeV6.asm" ; check walls in front of player
    INCLUDE "4-rd3dmazeV6.asm" ; draw left side of maze
    INCLUDE "5-rd3dmazeV6.asm" ; draw wall in front of player+setup right part of screen
    INCLUDE "6-rd3dmazeV6.asm" ; draw right side of maze
    include 7-rd3dmazeV6.asm    ;the maze itself and other routines

;moved 2 to here as it was causing a memory overwrite.
  ;  INCLUDE "2-rd3dmazeV6.asm" ; draw maze on screen, player direction,
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
        ld   bc,$0600
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
keytab db 0*8+4, 4*8+4, 4*8+3, 4*8+2, 4*8+0, 3*8+2
 ;           5     6     7      8       0     X

 ;old bit values before adding the x key
 ;;bit values: 1 = 0 fire
 ;             2 = 8 right
 ;             4 = 7 up
 ;             8 = 6 down
 ;            16 = 5 left
;new key table
;;bit values:  
 ;             1 = x
 ;             2 =  0 fire
 ;             4 = 5 left
 ;             8 =  7 up
 ;             16 = 6 down
 ;             32 =  8 right





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


	

;#################################################################
;Character screen reservation
 ;       org $c000
;char_screen:   block 768    ;view screen built here from characters

;attr_screen:   block 768    ;colours held here for door animation

;################################################


;##############################################
; Alternate Character set
;from https://www.jimblimey.com/blog/24-zx-spectrum-fonts/
;##############################################
charset_1:
  defb 0,0,0,0,0,0,0,0
  defb 16,56,56,56,16,0,16,0
  defb 102,51,51,0,0,0,0,0
  defb 102,102,255,102,102,255,102,102
  defb 20,126,212,126,149,126,20,0
  defb 96,148,104,16,44,82,140,0
  defb 48,72,48,72,142,140,120,0
  defb 12,12,24,0,0,0,0,0
  defb 1,2,4,4,4,4,2,1
  defb 128,64,32,32,32,32,64,128
  defb 0,84,56,254,56,84,0,0
  defb 0,24,24,126,24,24,0,0
  defb 0,0,0,0,0,0,48,96
  defb 0,0,0,126,0,0,0,0
  defb 0,0,0,0,0,0,48,0
  defb 1,2,4,8,16,32,64,128
  defb 124,134,138,146,162,194,124,0
  defb 16,48,112,16,16,16,124,0
  defb 120,132,8,48,64,128,252,0
  defb 120,132,4,56,4,132,120,0
  defb 128,68,72,72,252,8,8,0
  defb 254,128,128,124,2,130,124,0
  defb 122,132,128,188,194,130,124,0
  defb 254,132,8,16,56,16,16,0
  defb 124,130,124,130,130,130,124,0
  defb 124,130,134,122,2,130,124,0
  defb 0,48,0,0,0,48,0,0
  defb 0,48,0,0,0,48,32,0
  defb 8,16,32,64,32,16,8,0
  defb 0,0,126,0,126,0,0,0
  defb 32,16,8,4,8,16,32,0
  defb 124,130,4,8,16,0,16,0
  defb 124,130,154,170,170,158,124,0
  defb 248,68,66,254,66,66,198,0
  defb 252,66,66,252,66,66,252,0
  defb 122,132,128,128,128,130,124,0
  defb 252,66,66,66,66,66,252,0
  defb 254,66,64,112,192,66,254,0
  defb 254,66,64,112,192,64,224,0
  defb 122,132,128,128,156,130,126,2
  defb 130,68,68,94,244,68,130,0
  defb 16,8,8,8,8,8,4,0
  defb 126,8,4,4,4,132,120,0
  defb 204,68,72,240,72,68,198,0
  defb 192,64,64,64,64,66,254,0
  defb 198,106,90,74,74,66,198,0
  defb 204,100,84,84,84,84,204,0
  defb 120,132,132,132,132,132,120,0
  defb 248,68,68,248,64,64,224,0
  defb 120,132,132,132,132,140,125,2
  defb 252,66,66,252,66,66,198,0
  defb 116,136,128,120,4,132,120,0
  defb 124,84,16,16,16,16,48,0
  defb 198,68,68,130,130,130,124,0
  defb 204,68,68,68,68,40,16,0
  defb 198,66,66,74,90,106,204,0
  defb 130,68,40,16,40,68,130,0
  defb 204,68,68,56,16,16,48,0
  defb 254,132,8,16,32,66,254,0
  defb 28,16,16,16,16,16,28,0
  defb 128,64,32,16,8,4,2,1
  defb 56,8,8,8,8,8,56,0
  defb 0,0,16,56,108,198,0,0
  defb 0,0,0,0,0,0,0,255
  defb 48,48,24,0,0,0,0,0
  defb 0,0,122,4,124,132,122,0
  defb 128,64,64,92,98,66,188,0
  defb 0,0,122,132,128,130,124,0
  defb 2,4,116,140,132,132,122,0
  defb 0,0,188,66,124,64,62,0
  defb 52,72,64,224,64,64,128,0
  defb 0,0,122,132,140,116,4,120
  defb 128,64,120,68,68,68,136,0
  defb 16,0,16,8,8,8,4,0
  defb 0,16,0,16,8,8,136,112
  defb 192,64,72,80,224,80,200,0
  defb 48,16,16,16,16,16,56,0
  defb 0,0,172,84,84,68,204,0
  defb 0,0,184,68,68,68,204,0
  defb 0,0,120,132,132,132,120,0
  defb 0,0,184,68,68,120,64,128
  defb 0,0,116,136,136,120,4,2
  defb 0,0,176,72,64,64,64,0
  defb 0,0,120,128,112,8,240,0
  defb 0,32,16,124,16,16,8,0
  defb 0,0,144,72,132,132,120,0
  defb 0,0,130,68,68,40,16,0
  defb 0,0,132,66,82,106,70,0
  defb 0,0,136,80,32,80,136,0
  defb 0,0,130,68,68,60,4,120
  defb 0,0,124,136,48,68,248,0
  defb 14,16,16,96,16,16,14,0
  defb 24,24,24,0,24,24,24,0
  defb 224,16,16,12,16,16,224,0
  defb 0,0,112,154,12,0,0,0
  defb 0,0,24,60,102,255,0,0



  ;  include 7-rd3dmazeV6.asm    ;the maze itself and other routines
 
;##############################################
;misc data
;various variables
;udg charachter set 
;##############################################

        org 64000       ;fa00
 
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
w5_start dw 0        ;not used
cur_map  db 0        ;stores current map to draw or show           
map_start dw 0       ;tores the map start address

furthest_point dw 0   ;store the address of the furthest point
                      ;we can see in the maze from our position.
blockid  db 0         ;stores  block position of layer 5 for wall drawing
maze_highbyte db $71  ;holds high byte of current maze in use
map_show    db  0     ;tells is if we are already showing the map
show_exit       db 0  ;used to say whether to draw the full size exit door or not
                      ;0 = draw a closed exit door
                      ;1 = draw an open exit door
switch_pulled   db  0 ; 0 and 1 for on and off - default off
sp_store        dw  0   ;save and restore the SP
switch_sound    dw 0    ;shows if switch sound already sounded = 0=no, 1=yes
game_exit       db  0   ;set to 255 if we need to exit the game as we got passed level 0

;#############################################################
;reserve 200 bytes for the stack - points here from BASIC
;stack pointer lives here
stack_p        block 200

;stack pointer is at 64511

;##############################################
;udg charachter set starts at 64512
;##############################################

        org 64512  
													
;##############################################
      ;UDG Charachter Defs											
;##############################################							
_chars:
 db	72,75,151,147,137,68,36,18      ;80	65080	;door wood effect 1	
 db	168,68,162,169,41,66,148,164	;81	65088   ;door wood effect 2
 db	17,42,82,84,78,78,37,18  	    ;82	65096   ;door wood effect 3		
 db	40,72,164,148,74,146,36,72  	;83	65104   ;door wood effect 4		
 db	52,52,52,247,247,52,52,52     	;84	65112	;Door Barsvertical
 db	0,0,0,255,255,0,0,0   	        ;85	65120   ;Door Bars Crossbars
 db	172,236,108,44,44,46,47,45	    ;86	65128	;door bars left side	
 db	53,55,54,52,52,116,244,180	    ;87	65136	;door bars right side	
;rest of door graphic chars are at $b9 onwards below

 db	192,240,252,255,255,252,240,192 ;88	65144   left hand triangle pointed		
 db	3,15,63,255,255,63,15,3         ;89	65152	right hand triangle pointed	
 db	0,0,0,0,0,0,0,0	                ;8a	65160		
 db	255,85,255,175,255,95,255,255   ;8b	65168	upper wall 5 right bottom		
 db	255,213,255,250,255,253,255,255	;8c	upper wall 5 left bottom		

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

 DB	128,192,224,240,245,250,245,250	;9b	65296	layer 5 left top
 DB	245,250,245,250,240,224,192,128	;9c	65304	layer 5 left bottom
 DB	1,3,7,15,95,175,95,175         	;9d	65312   layer 5 right top		
 DB	95,175,95,175,15,7,3,1         	;9e	65320	layer 5 right bottom
 DB	85,170,85,170,85,170,85,170    	;9f	65328	chequer
 DB	85,170,85,170,0,0,0,0          	;a0	65336	top chequer
 DB	0,0,0,0,85,170,85,170          	;a1	65344	bottom chequer
 DB	0,0,0,0,255,255,255,255        	;a2	65352		bottom black
 DB	255,255,255,255,0,0,0,0        	;a3	65360		top black
 DB	255,8,8,8,255,128,128,255      	;a4	65368		brick pattern
 DB	153,200,100,50,25,140,206,171  	;a5	65376		top left brick diag
 DB	16,40,16,124,16,40,40,68       	;a6	65384		man
 DB	0,120,107,126,124,104,120,0    	;a7	65392		switch
 DB	255,165,255,165,165,255,165,255	;a8	65400		fancy square
 DB	128,192,224,240,255,255,255,255	;a9	65408		top left 5
 DB	1,3,7,15,255,255,255,255       	;aa	65416		top right 5
 DB	255,255,255,255,240,224,192,128	;ab	65424		bot left  5
 DB	255,255,255,255,15,7,3,1       	;ac	65432		bot right 5
 DB	255,229,255,253,253,255,255,255	;ad	65440		top right fancy
 DB	255,167,255,191,191,255,255,255	;ae	65448		top left fancy
 DB	255,255,255,255,255,255,255,255	;af	65456		all black
 DB	255,254,252,248,240,224,192,128	;b0	65464		top left triangle
 DB	255,127,63,31,15,7,3,1         	;b1	65472		top right triangle
 DB	1,3,7,15,31,63,127,255         	;b2	65480		bot right triangle
 DB	128,192,224,240,248,252,254,255	;b3	65488		bot right triangle

 DB	255,85,255,170,255,85,255,170	;b4	65496		small wall
 DB	255,136,136,255,162,162,255,128	;b5	65504		mediumwall
 DB	255,136,136,136,255,224,192,128	;b6	65512		largewall
 DB	255,170,255,170,255,170,255,170 ;b7	65520		mediumwall_1
 DB	255,136,136,136,255,128,128,128 ;b8	65528		hugewall

;layer 5 section 3 right TOP

 DB 0,0,0,255,255,255,255,255       ;b9 top right section 3 (4)
 DB 0,0,255,255,255,255,255,255     ;ba top right section 3 (3)
 DB 0,255,255,255,255,255,255,255   ;bb top right section 3 (2)
 DB 255,255,255,255,255,255,255,255 ;bc top right section 3 (1)

;layer 5 section 3 right BOTTOM

 DB 255,255,255,255,255,0,0,0       ;bd top right section 3 (6)
 DB 255,255,255,255,255,255,0,0     ;be top right section 3 (6)
 DB 255,255,255,255,255,255,255,0   ;bf top right section 3 (6)
 DB 255,255,255,255,255,255,255,255 ;c0 top right section 3 (6)

;layer 5 section 3 left TOP TBD

 DB 255,255,255,255,255,0,0,0       ;c1 bottom right section 3 (5)
 DB 255,255,255,255,255,255,0,0     ;c2 bottom right section 3 (6)
 DB 255,255,255,255,255,255,255,0   ;c3 bottom right section 3 (6)
 DB 255,255,255,255,255,255,255,255 ;c4 bottom right section 3 (6)

;layer 5 section 3 left BOTTOM TBD

 DB 0,0,0,255,255,255,255,255       ;c5 bottom right section 3 (5)
 DB 0,0,255,255,255,255,255,255     ;c6 bottom right section 3 (6)
 DB 0,255,255,255,255,255,255,255   ;c7 bottom right section 3 (6)
 DB 255,255,255,255,255,255,255,255 ;c8 bottom right section 3 (6)


;layer 5 section 4 right TOP

 DB 0,0,0,0,0,0,0,255               ;c9 top right section 3 (4)
 DB 0,0,0,0,0,0,255,255             ;ca top right section 3 (4)
 DB 0,0,0,0,255,255,255,255         ;cb top right section 3 (3)
 DB 0,0,255,255,255,255,255,255     ;cc top right section 3 (2)
 DB 0,255,255,255,255,255,255,255   ;cd top right section 3 (1)

;layer 5 section 4 right BOTTOM

 db 255,0,0,0,0,0,0,0               ;ce top right section 3 (6)
 db 255,255,0,0,0,0,0,0             ;cf top right section 3 (6)
 db 255,255,255,255,0,0,0,0         ;d0 top right section 3 (6)
 db 255,255,255,255,255,255,0,0     ;d1 top right section 3 (6)
 db 255,255,255,255,255,255,255,0   ;d2 top right section 3 (6)


;Extra wall5
; db	249,63,243,159,244,47,249,143 	;c9	small wall stretched more
; db 255,15,255,31,255,15,255,15	   	;ca	small wall stretched
; db 240,15,224,31,224,15,112,15	   	;cb	small wall stretched

;triangular door wood parts
 db	255,255,254,251,249,228,228,146     ;d3	   ;door wood effect top corner 1 right side($80)	
 db	136,203,231,243,249,252,254,255	    ;d4	   ;door wood effect bottom corner 1 (80)
 db	255,254,254,252,254,238,229,146     ;d5	   ;door wood effect top corner 3 right side($82)		
 db	145,202,226,244,250,252,254,255    	;d6    ;door wood effect bottom corner 1 (82)

;additional characters for level numbers printed on right of display
;single caracter 10,11,12,13,14,15
  db  0,76,82,82,82,82,76,0             ;d7 
  db  0,72,72,72,72,72,72,0             ;d8
  db  0,76,82,66,68,72,94,0             ;d9
  db  0,76,82,70,66,82,76,0             ;da
  db  0,66,70,74,94,66,66,0             ;db
  db  0,78,80,76,66,82,76,0             ;dc

;characters to print around the switch
  db  255,0,255,0,255,0,255,0           ;dd  ;horizontal bars x 4
  db  255,128,191,160,175,168,171,170   ;de  ;top left corner
  db  170,171,168,175,160,191,128,255   ;df  ;bot left corner
  db  170,170,170,170,170,170,170,170   ;e0  ;vertical bars
  db  255,1,253,5,245,21,213,85         ;e1  ;top right corner
  db  85,213,21,245,5,253,1,255         ;e2  ;bot right corner
  db  0,255,0,255,0,255,0,255           ;e3  ;bot horizontal bars
  db  85,85,85,85,85,85,85,85           ;e4  ;right vertical bars

;side view switch chars
  db  255,255,254,252,249,242,228,201   ;e5 ;top triangle bit
  db  146,164,169,170,170,170,170,170   ;e6 ; top left corner
  db  255,1,125,133,53,85,149,21        ;e7 ;top right corner 
  db  85,213,85,85,85,85,85,85          ;e8 ;2nd top line bottom right bit
  db  64,128,0,0,0,0,0,0                ;e9 ;3rd top line bottom 2nd right bit
  db  146,36,73,146,36,72,144,32        ;ea ;top horizontal line

  db  201,228,242,249,252,254,255,255  ;eb   ;bottom triangle bit
  db  21,149,85,53,133,125,1,255       ;ec ;bottom right corner
  db  85,85,85,85,85,85,213,85         ;ed ;2nd bottom line bottom right bit
  db  170,170,170,170,170,169,164,146  ;ee   ;bottom left corner
  db  0,0,0,0,0,0,128,64               ;ef ;3rd top line bottom 2nd right bit
  db  32,144,72,36,146,73,36,146       ;f0 ;bottom horizontal line

  db   0,0,0,0,32,0,0,1                ;f1 ;stars for the inside of the closed door
  db   0,8,0,0,0,0,0,0                 ;f2 ;stars for the inside of the closed door



;END_PROGRAM


;for SJASMPLUS
;;
;; Set up the Nex output
;;

        ; This sets the name of the project, the start address, 
        ; and the initial stack pointer.
 ;       SAVENEX OPEN "3dmaze.nex";, start_game  ;, END_PROGRAM
        SAVEBIN "3dmaze.bin",32768,32767

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

