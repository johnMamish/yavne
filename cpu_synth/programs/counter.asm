
    ;; memory addresses $80, $81, and $82 will hold counter, little-endian
    lda #$00
    sta $80
    sta $81
    sta $82

_loop:
    ;; copy bytes to display locations
    lda $80
    sta $4004
    lda $81
    sta $4003
    lda $82
    sta $4002

    ;; increment $80
    lda $80
    adc #$01
    sta $80

    ;; if A is now 0, it means that mem location $80 rolled over
    bne _loop

    lda $81
    adc #$01
    sta $81
    bne _loop

    lda $82
    adc #$01
    sta $82
    jmp _loop
