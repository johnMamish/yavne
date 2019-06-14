    .segment "CODE"

start:
    ;; test ldy and sty with a bunch of different addressing modes.
    ldy #$41
    .byte $a4, $00              ;ldy $00
    iny
    .byte $84, $90              ;sty $90
    sty $0200

    ldx #$01
    sty $98, X
    inx
    sty $98, X
    ldx #$82
    ldy $80, X                  ; y should have $a4 now

    lda #$fe
    sta $0200
    ldy $0200
    sty $10, X                  ; should be at addr $92
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
    stx $11, Y                  ; should be at addr $93
    dex
    txa
    clc
    adc #$01
    tax

    ;; cpy, cpx test.
    ;; also, test ldx abs, y
    lda #$03
    sta $0401
    ldy #$11
    ldx $03f0, y
    lda #$10
_cpx_loop:
    inx
    clc
    adc #$10
    cpx #$05
    bne _cpx_loop

    ;; cpy, cpx test
    ;; also, test ldx abs, y
    lda #$03
    sta $0401
    ldy #$01
    ldx $0400, y
    lda #$05
    sta $b7
    lda #$20
_cpx_loop2:
    inx
    clc
    adc #$20
    .byte $e4, $b7              ; cpx $b7
    bne _cpx_loop2

    ;; cpy, cpx test
    ldx #$03
    lda #$05
    sta $0870
    lda #$30
_cpx_loop3:
    inx
    clc
    adc #$30
    cpx $0870
    bne _cpx_loop3

    ;; at end of loop, A should be $30
_done:
    jmp _done

    .segment "VECTORS"
    .word $fff0                ; nmi
    .word start                ; reset
    .word $fff0                ; irq
