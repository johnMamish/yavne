    .segment "CODE"

reset:
    lda #$02
    sta $80
loop:
    adc #$01
    adc $80
    jmp loop

    .segment "VECTORS"
    .word $fff0                ; nmi
    .word reset                ; reset
    .word $fff0                ; irq
