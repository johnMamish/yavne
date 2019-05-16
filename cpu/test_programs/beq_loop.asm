    .org $0000

    jmp _start

    .res 253, $00

_start:
    lda #$15
_loop:
    adc #$FF
    sta $80
    beq _done
    jmp _loop

_done:
    beq _done
