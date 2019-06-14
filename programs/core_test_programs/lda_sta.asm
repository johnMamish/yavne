    .segment "CODE"

start:
    lda #$01
    sta $0200
    lda #$05
    sta $0201
    lda #$08
    sta $0202

    tax
    lda #$a5
    tay
    txa
    tya

_done:
    jmp _done

.segment "VECTORS"
    .word $fff0                ; nmi
    .word start                ; reset
    .word $fff0                ; irq
