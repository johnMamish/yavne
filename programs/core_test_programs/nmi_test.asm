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

nmi:
    inc nmi_count
    sec
    rti

nmi_count:
    .word $0000


    .segment "VECTORS"
    .word nmi                ; nmi
    .word reset                ; reset
    .word $fff0                ; irq
