    .segment "CODE"

reset:
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

    .segment "VECTORS"
    .word $fff0                ; nmi
    .word reset                ; reset
    .word $fff0                ; irq
