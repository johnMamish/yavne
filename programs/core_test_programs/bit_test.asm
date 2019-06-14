    .segment "CODE"

reset:
    lda #$73
    .byte $85, $40              ;sta $40
    sta $0600
    lda #$04
    bit $0600
    .byte $24, $40              ;bit $40

    lda #$f7
    .byte $85, $41              ;sta $41
    sta $0601
    lda #$04
    bit $0601
    .byte $24, $41              ;bit $41

_done:
    jmp _done

    .segment "VECTORS"
    .word $fff0                ; nmi
    .word reset                ; reset
    .word $fff0                ; irq
