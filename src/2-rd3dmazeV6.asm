
;##############################################
;Draw the current map on screen
;##############################################

    ;    org $E000   ; 57344 - top 8k

;max row=21, max column = 31

;will need to change DF_CC position for sjasmplus
DRAW_MAP:
        ;set max speed!
        nextreg 7,3

        ;set our colours
        ld a,178            ;red
        ld (wallcol),a

;first draw a top wall line
        ld a,17          ;draw 16 wall chars
        ld bc,$0204      ;print at 2,4;
        call topbotline
 
;now draw the map data
        ld bc,$0304      ;set row and column to 2,4
        ld hl,(map_start)
        ld (var7),hl   ;save it
rep1:   
        push bc
        call locate
        pop bc           ;restore our counter
        push bc          ;resave it

        call get_maze_data
        call print1      ;print character
        pop bc
        inc c
        ld a,c
        sub 20          ;just draw 16 characters (we start at loc 4)
        jp nz,rep1

;now draw a final wall at the end of the line
        push bc
        ld de,udg_start  ;point to udg chars
        ld (base),de
        call locate      ;set print position
        call set_wall_col   ;set our wall colour
        ld a,(wallcol)
        ld (att),a
        ld a,_smallwall  ;draw wall char
        call print1 
        pop bc
        ld a,b
        cp 18            ;draw 18 lines (starting at line 2)
        jr z,ret2        ;exit after 18 lines
        inc b
        ld c,4           ;start row from pos 4 again
        jr rep1          ;start again

;now draw a bottom line wall
ret2:   ld a,17          ;draw 16 wall chars
        ld bc,$1304      ;print at 2,4;
        call topbotline

;put our char set back to normal!
        ld hl,charset_1-256
        ld (base),hl
        ret

;cycle through the maze drawing blocks, player, exit etc        
get_maze_data:
        ld hl,(var7)    ;get our current map position
        ld a,40         ;cyan paper, black ink
        ld (att),a      

;set charset to non udg
        ld de,charset_1
        dec d
        ld (base),de    ;set char set start for ptint1 routine
        ld a,(hl)       ;get our character to print
        inc hl           ;jump to next maze location
        ld (var7),hl
        ld h,a          ;save reg a - we dont need reg h anymore

;Now check if its a player, a wall or an Exit or switch, 
        ld de,(player_pos)      ;get player location
        dec l                   ;put back hl as we inc'd it earlier
        ld a,e                  ;go back 1 position as we already incremented it
        cp l
        ld a,h             ;restore reg a for further compares
        jr nz,go_1          ;no match for a player
        ld a,$a6           ;set a to  our little man character which is a graphic
go_1:   cp ' '
        ret z

;its a graphic character - assume its a wall no matter what
        ld h,a             ;save reg a
        ld a,10             ;yellow paper, black ink
        ld (att),a         ;red ink, blue background
        ld a,h


;Now check if its a player, a wall or an Exit or switch
        ld e, $a6           ;our little man graphic
        cp e 
        jr z,go_on          ;do next check

;check for an exit....
        ld e,_me            ;exit char = 192       
        ld a,h
        cp e               ;needs to be a compare so a is left intact
        ld a,$a8            ;load exit character
        jr z,go_on
;
;a7 check for a switch...
        ld e,_ms           ;exit char = 192       
        ld a,h
        cp e               ;needs to be a compare so a is left intact
        ld a,$a7            ;load exit character
        jr z,go_on

;default to a wall....
carry_on1:
        call set_wall_col   ;set our wall colour
        ld a,(wallcol)
        ld (att),a         ;red ink, blue background      
        ld a,_smallwall         ;return wall char


go_on:
        sub $80          ;subtract 128 to point to correct graphic char
;set char set to udg's
        ld de,_chars;$fc00
        ld (base),de
        ret

topbotline:
;draws a single line of 16 wall chars
;set char set to udg's
        ld de,$fc00             ;point to udg's
        ld (base),de
    
rep3:   push af
        call locate             ;set print position
;set wall colour. Print 1 uses whats stored in (att)
        call set_wall_col   ;set our wall colour
        ld a,(wallcol)
        ld (att),a
        ld a,_smallwall
        sub $80
        push bc
        call print1      ;print the character
        pop bc
        inc c
        pop af
        dec a
        jr nz,rep3        ;exit when a=0
        ret

       
;==================================================
;from advanced spectrum machine code book
;==================================================

;locate routine for use with print routine

;   entry: b=line  c=column
;   preserved = bc
;   on exit -   hl = display file address
;               de = attr address
;               a  = attr (b,c)
;   df_cc is altered       

               

   ; BREAK
locate: ld a,b
        and $18
        ld h,a           
        set 6,h
        rrca
        rrca
        rrca
        or $58
        ld d,a
        ld a,b
        and 7
        rrca
        rrca
        rrca
        add a,c
        ld l,a
        ld e,a
        ld a,(de)
        ld (df_cc),hl
        ret

;here is the new print routine

;   entry: a=char code to be printed
;   preserved = c
;   exit -  b=0
;           de = attribute address

; variable base is initialised to 3c00h = normal spectrum character set
; att is place immediately before mask so that 
; the two can be accessed with one ld instuction

base    dw $3c00 ; start of speccy characer set
dfcc    dw $4000 ;start of spectrum screen mem 
;dfcc    dw $0000 ;start of spectrum screen mem slot 0
att     dw $38
mask    dw 0



print1: ; construct character data address

      
        ld l,a
        ld h,0
        add hl,hl
        add hl,hl
        add hl,hl
        ld de,(base)                ;char set data
        add hl,de

        ; take display file address
        ld de,(df_cc)
        ld b,8
    
        ; print character row by row
nxtrow: ld a,(hl)
        ld (de),a
        inc hl
        inc d
        djnz nxtrow
        
        ; construct attribute address
        ld a,d
        rrca
        rrca
        rrca
        dec a
        and 3
        or $58
        ld d,a
        ld hl,(att)    ; h=mask, l=attribute
        
        ; take old attribute
        ld a,(de)

        ; construct new one
        xor l
        and h
        xor l

        ; replace attribute
        ld (de),a
        
        ; finally, set dfcc to next print position
        ld hl,df_cc
        inc (hl)
        ret nz
        inc hl
        ld a,(hl)
        add a,8
        ld (hl),a
        ret


; print routine - print screen at c000 to 16384
; uses locate routine

my_print_info:  ; set dfcc to line , column

;1st, check if we are printing a udg
;reg a holds our character to print. udg's are char $90 onwards

; the carry will be set if the cp argument > than a

 
setbase:
        push af
        push bc
        push hl
;        ld a,$3c                ;point to spectrum rom
;        ld (base+1),a
;        sub a                   ; make zero
;        ld (base),a

;point to our character set
        ld hl,charset_1
        dec h
        ld (base),hl

        ;we are now pointing at the rom char set
        ld a,(bc)               ;get our char to print
 ;       nop ;or a
        bit 7,a                 ;are we printing udg's?
        ; bit 7=1 so zero =false
        jr z,ret_1              ;exit if theres no graphic to print
        sub $80                 ;point to the first character of udg's 
        ld bc,udg_start         ;start of udg's in memory
        ld (base),bc
        ;ld hl,(base)
ret_1   pop hl
        pop bc
        pop af

        ret
        
my_print:
lp4:    ld b,0
        ld c,0 
;        ld a,120
        
;        ld (att),a
        call locate ; set print pos and attribute
        ;call cls - clear the screen
        
        ;loop 24 times
        ;ld a,2
        ;push af
        
        ; set base pointer to  character set
        ; starts at space char code 0
  ;      ld hl,(base) 
        ;ld (base),hl
        sub a
      ;make reg a=0
        ld (lc),a   ;line counter
    
        ; remember, print1 preserves the c register
        ld bc, $bfff ;c000  ; 1 less than display in memory
        ld l,0
lp3:
                
        push bc
        push hl
        inc bc
        ld a,(bc)
        call setbase ; set char set
        ld a,240
        ld (att),a          ;set black ink and paper
        ld a,(bc)           ;reload our character to print
        ld hl,(base)

;charset test
        ld hl,(charset_1)

        call print1  ; print char in a
        pop hl
        pop bc

        inc bc
        inc l
        ld a,l
        cp 25       ; print 26 chars
        jp nz,lp3

        push bc
        pop hl
        ld d,0
        ld e,8
        add hl,de
        
        push hl
        pop bc
        ld l,0       ;start at 0 for the next line
        ld a,(lc)
        inc  a
        
;we only draw the first 24 columns x 24 lines
        cp 24      ; x lines to print

        ret z

; reset position to next line. locate can do attributes too
        exx
        push hl
        ld (lc),a  ; save counter
        ld b,a
        ld c,0
        call locate
        pop hl
        exx
        jp lp3
        

lc      db 0


;============================================
; draw player direction text on screen
;===========================================

; loop 7 times for 7 lines
; start at column 14
; print 7 characters
 
compass:
;first colour in the background - 7 lines starting at 17,25
;              ld b,17           ;row 21
;              ld c,25           ;col 25  

;loc_1:        push bc
;              call locate    ;set print position
;              pop bc
;              ;de holds the attribute position
;              ld a,151          ;set colour
;              call colour1
;              ld a,23
;              sub b
;              inc b
;              jr nz,loc_1
;              jr draw_compass                          
    
;colour1:      ld l,7
;colour2:      ld (de),a
;              inc de
;              dec l
;              ret z
;              jr colour2      

;now draw the compass
draw_compass: ld b,23           ;row 21
              ld c,25           ;col 25     

              push bc
              call print_pos    ;set print position
              pop bc
              
; now print our characters
              ld de,c_dat-1       ;data start
loop1:        ld a,(de)
              cp 'x';120            ; = "x" data end
              jp z,nxt_line
              cp 'F';70             ; "F" finished so exit
              jp z, do_exit

              push de
              push bc
              call print1       ; print the character
              pop bc
              pop de

              dec de
              jr loop1

nxt_line:     push bc
              push de
              ld c,25
              dec b
              call print_pos
              pop de
              pop bc
              dec de
              dec b
              jr loop1

; set print position
print_pos:    push bc
              call locate
              ld a,165          ;set ink and paper colour
              ld (att),a
              pop bc
              ret
              
do_exit:  call show_dir     ; highlight player direction
           
              ret
              

        db "F"
;        db "x       "
        db "xssapmoC"
        db "x       "
        db "x   N   "
        db "x   |   "
        db "x E-+-W "
        db "x   |   "
        db "x   S   "
c_dat:


;===========================================
; highlight player direction
;===========================================

;l4085 holdsplayer view  direction

;00= north, 01=west, 02=south, 03=east

show_dir:     ld a,165;185             ;white txt, brown background
;now clear the settings to none
              ld hl,23228+64       ;s
              ld (hl),a
              ld hl,23166+64       ;e
              ld (hl),a
              ld hl,23162+64       ;w
              ld (hl),a
              ld hl,23100+64       ;n
              ld (hl),a


;now colour the direction indicator

              ld a,(player_dir)
              cp 0              ;n
              jp nz,c1
              ld hl,23100+64       ;n
              jp poke_it
c1:           cp 1              ;w
              jr nz,c2
              ld hl,23162+64       ;w
              jp poke_it              
c2:           cp 2              ;s
              jr nz,c3
              ld hl,23228+64       ;s
              jp poke_it              
;it must be east                ;e
c3            ld hl,23166+64       ;e

poke_it:      ld a,150          ;cyan paper, black writing
              ld(hl),a
q1:           ret
