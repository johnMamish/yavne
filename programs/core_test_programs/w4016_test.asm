    ;; Test to try writing to memory address 4016, which should be a memory-mapped controller strobe

    .segment "CODE"

reset:
    lda #$00
    sta $4016
    nop
    nop
    lda #$01
    sta $4016
    nop
    nop

    jmp reset

    .segment  "VECTORS"
    .word $fff0                ; nmi
    .word reset                ; reset
    .word $fff0                ; irq
