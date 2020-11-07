;             org $8800


; -----------------------------------


;draws the background brick pattern for the 2d maze display

print_maze:
start:        push hl
              push af
              push de

              ;call draw_brick   ; draw background
              
              ld a, 1
              ld (var1),a   ; print at var1, var2
              ld a,4              
              ld (var2),a
        
              ;open print channel
              ld a,02
              call chan_open
        
              ;clear screen
              
        
              ;do print at x,x
              ld a,at
              rst $10
              ld a,(var1) ; current print at line number
              rst $10
              ld a,(var2)
              rst $10
        
; now draw the maze

              
              ld hl,(map_start)
              
              ld d,16       ; 1 line length across
              ld c,16       ; 16 lines down, we exit on 0
repeat:       ld a,(hl)
              ld b,a
              
              bit 7,a           ; is it a wall?
              jr nz, print_block
              
              cp 69         ; its the exit
              jp z, print_exit             

              ;push de       ;check if rex's pos=current maze pos
              ;ld de,(rex_pos)
              ;ld a,l        ; h and d will be the same
              ;sub e
              ;pop de
              ;jp z, print_rex        ; its rex

              push de
              ld de,(player_pos)    ; get player position
              ld a,l                ; compare with maze position
              cp e
              pop de
              jp z, print_player
               
              ld a,ink
              rst $10
              ld a,7
              rst $10
              ld a,paper
              rst $10
              ld a,6
              rst $10
              ;ld a,32           ;make it a space to print

             ; ld a,b
             ; cp 32             ;is it a space?
             ; jr nz, print_x
             ; ld a,paper
             ; rst $10
             ; ld a,white
             ; rst $10
             ; ld a,32
             ; rst $10

              ;jp print_it1

print_x       ld a,ink
              rst $10
              ld a,black
              rst $10
              ld a,b
              ;add a,27          ; it must be a character so add 27 and print it
print_it1:    rst $10
print_data:   
              ;rst $10       ; a already contains our block to print
              inc hl        ; advance to next maze data
              dec d  
                  
              jr nz, repeat ; continue reading line across
              
              ld d,16       ; reset to line start
              dec c
              jr z, final_draw    ; exit program if we are at the last bit of data
              
              ;print an end block at right end

              ld a, paper
              rst $10
              ld a, cyan
              rst $10
              ld a,'#'          ;right hand end wall
              rst $10
              
              ld a,(var1)   ; inc print position to next line
              inc a
              ld (var1),a
                      
              ld a,at       ; otherwise advance to next line for next line of data
              rst $10
              ld a,(var1)
              rst $10
              ld a,(var2)
              rst $10
                            
              jr repeat     ; do next line

              ;print final right hand corner block

final_draw:   ld a, paper
              rst $10
              ld a, cyan
              rst $10
              ld a,'#'          ;wall block
              rst $10
              
              jp exit       ; end program
              
              
print_block:  ld a,ink
              rst $10
              ld a,white
              rst $10
              ld a,paper
              rst $10
              ld a, blue       ;4
              rst $10
              ld a,'X'    ; $8f for black block
              rst $10        ; print a black block - char $8f
              jr print_data

print_rex:    ld a, paper
              rst $10
              ld a, red
              rst $10
              ld a, ink
              rst $10
              ld a, black
              rst $10
              ld a, $93
              rst $10      ; print usr 'd'
              ld a, paper
              rst $10
              ld a, green
              rst $10
              ld a, ink
              rst $10
              ld a, black
              rst $10
              ld a, flash
              rst $10
              ld a,0
              rst $10
              jr print_data


            
print_exit:   ld a,paper
              rst $10
              ld a, yellow
              rst $10
              ld a, ink
              rst $10
              ld a,black
              rst $10
              ld a, 69
              rst $10      ; print e
              ld a,paper
              rst $10
              ld a, green
              rst $10
              ld a, ink
              rst $10
              ld a,black
              rst $10
              ld a,flash
              rst $10
              ld a,0
              rst $10
              ld a,ink
              rst $10
              ld a,7
              rst $10
              
              jp print_data

print_player  ld a, paper
              rst $10
              ld a, red
              rst $10
              ld a, ink
              rst $10
              ld a, black
              rst $10
              ld a, flash
              rst $10
              ld a, 1
              rst $10
              ld a,73   ;'I'
              rst $10      ; print usr 'c'
              ld a, flash
              rst $10
              ld a,0
              rst $10
              jp print_data

exit:         ;print message
              ;ld a, at
              ;rst $10
              ;ld a,21
              ;rst $10
              ;ld a,3
              ;rst $10
              ;ld de,message1
              ;ld bc,txt_end1
              ;call print                  
              pop de
              pop af
              pop hl

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

               
df_cc        equ $5c84

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
dfcc    dw $4000 ;start of spectrum mem 
att     dw $38
mask    dw 0



print1: ; construct character data address

      
        ld l,a
        ld h,0
        add hl,hl
        add hl,hl
        add hl,hl
        ld de,(base)
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

 
setbase push af
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
              ld b,21           ;row 21
              ld c,25           ;col 25     

              push bc
              call print_pos    ;set print position
              call locate       ;set print position
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

nxt_line      push bc
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
              ld de,56;48         ;set colours
              call locate
              pop bc
              ret
              
do_exit:  call show_dir     ; highlight player direction
              
              ret
              

        db "F reyalP"
        db "x  rid  "
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

show_dir:     ld a,56             ;black txt, white background
;now clear the settings to none
              ld hl,23228       ;s
              ld (hl),a
              ld hl,23166       ;e
              ld (hl),a
              ld hl,23162       ;w
              ld (hl),a
              ld hl,23100       ;n
              ld (hl),a


;now colour the direction indicator

              ld a,(player_dir)
              cp 0              ;n
              jp nz,c1
              ld hl,23100       ;n
              jp poke_it
c1:           cp 1              ;w
              jr nz,c2
              ld hl,23162       ;w
              jp poke_it              
c2:           cp 2              ;s
              jr nz,c3
              ld hl,23228       ;s
              jp poke_it              
;it must be east                ;e
c3            ld hl,23166       ;e

poke_it:      ld a,23
              ld(hl),a
q1:           ret
