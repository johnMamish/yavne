    .org $0000

    lda #$fc
_loop:
    jsr inca
    cmp #$00
    bne _loop

_done:
    jmp _done

inca:
    clc
    adc #$01
    rts
