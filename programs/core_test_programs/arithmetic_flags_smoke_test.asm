    .org $0000

    ;; test carry flag. 0x88 + 0x78 should set A <= 0 and set the carry flag
    lda #$88
    sta $0200
    lda #$78
    adc $0200


    ;; "clc" instruction
    adc #$00

    ;; carry flag should enable us to add 16-bit numbers. add 0x3ea7 + 0x179c
    lda #$a7
    sta $0200
    lda #$3e
    sta $0201

    lda #$9c
    adc $0200
    nop
    sta $0204
    lda #$17
    adc $0201
    nop
    sta $0205

    ;; "cmp" instruction
    ;; first, unsigned
    lda #$56
    sta $0300
    lda #$38
    cmp $0300

    nop
    nop

    lda #$57
    cmp $0300
