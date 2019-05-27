.org $0000

    ;; test ldy and sty with a bunch of different addressing modes.
    ldy #$41
    .byte $a4, $00              ;ldy $00
    iny
    .byte $84, $90              ;sty $90
    sty $0200

    ldx #$01
    sty $80, X
    inx
    sty $80, X
    ldx #$82
    ldy $80, X                  ; y should have $a4 now

    lda #$fe
    sta $0200
    ldy $0200
    sty $00, X
    dey
    tya
    clc
    adc #$01
    tay



    ;; X
    ldx #$51
    .byte $a6, $00              ;ldx $00
    inx
    .byte $86, $91              ;stx $90
    stx $0201

    ldy #$01
    stx $a0, Y
    iny
    stx $a0, Y
    ldy #$82
    ldx $80, Y                  ; x should have $a4 now

    lda #$fe
    sta $0201
    ldx $0201
    dex
    stx $01, Y
    dex
    txa
    clc
    adc #$01
    tax

    ;; cpy, cpx test
    ldx #$03
    lda #$10
_cpx_loop:
    inx
    clc
    adc #$10
    cpx #$05
    bne _cpx_loop

    ;; at end of loop, A should be $30
_done:
    jmp _done
