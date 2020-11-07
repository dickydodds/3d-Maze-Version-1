    DEVICE ZXSPECTRUMNEXT
    ORG $8000   ; this example does map Bank5/Bank7 ULA to $4000 (to use "pixelad" easily)

    nextreg 7,0
mainLoop:
    call FlipULABuffers ; flip the buffer screen to visible screen and flip buffer
    call drawDot
    jr mainLoop

FlipULABuffers:     ; Flip ULA/Alt ULA screen (double buffer ULA screen)
     ;ret ; uncomment to see effect of non-double-buffered running (blinking dots)

    ld a,(ULABank)  ; Get screen to display this frame

    ; if A==14, then do NR_69=64 (display Bank7), if A==10: NR_69=0 (display Bank5)
    ; its %0000'1110 vs %0000'1010 in binary, so extract bit2 and move it to bit6

    and %0000'0100  ; $04 from A=14, $00 from A=10
    swapnib         ; bit6 set from bit2
    nextreg $69,a   ; Select Timex/ULA screen to show

    ; flip the drawing buffer mapped at $4000

    ld a,(ULABank)
    xor 10^14       ; alternate between 10 and 14
    ld (ULABank),a
    nextreg $52,a   ; map the new "backbuffer" to $4000 (for next drawing)
    ret

ClearUlaBuffer:
    ld  hl,$4000
    ld  de,$4001
    ld  bc,$1800
    ld  (hl),l
    ldir
    ld a,(ULABank)
    cp 10
    jp z,x1
    ld a,5
    jp x2
x1  ld a,6
    
x2    ld  (hl),a    ; black paper, cyan ink
    ld  bc,$02FF
    ldir
    ret

drawDot:
    ; clear full ULA to make it blink in case of wrong double-buffering
    call ClearUlaBuffer
    ; adjust position for next frame
    ld de,(DotPos)
    inc e       ; ++X
    ld (DotPos),de
    ; draw dot on every char-row
    ld b,24
dotLoop:
    pixelad
    setae
    ld (hl),a
    add de,$0800    ; lazy slow way to do Y+=8
    djnz dotLoop
    ret

ULABank defb 10 ;holds current ULA screen in use
DotPos  defb 0, 4  ; X=0, Y=4

    SAVENEX OPEN "flipULA.nex", mainLoop, $BF00 : SAVENEX AUTO : SAVENEX CLOSE
