    .org $0000

    ;; start at $fd, decrement, and increment until one after 0.
    lda #$fd
    sta $0080
    .byte $c6, $80              ;dec $80
    .byte $e6, $80              ;inc $80
    .byte $e6, $80              ;inc $80
    .byte $e6, $80              ;inc $80
    .byte $e6, $80              ;inc $80
    .byte $e6, $80              ;inc $80
    clc

    sta $0081
    ldx #$01
    .byte $d6, $80              ;dec $80,x
    .byte $f6, $80              ;inc $80,x
    .byte $f6, $80              ;inc $80,x
    .byte $f6, $80              ;inc $80,x
    .byte $f6, $80              ;inc $80,x
    .byte $f6, $80              ;inc $80,x
    clc

    sta $0200
    dec $0200
    inc $0200
    inc $0200
    inc $0200
    inc $0200
    inc $0200
    clc

    sta $0201
    dec $0200, X
    inc $0200, X
    inc $0200, X
    inc $0200, X
    inc $0200, X
    inc $0200, X

_done:
    jmp _done
