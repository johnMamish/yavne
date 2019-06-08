    .org $0000

    lda #$f2
    adc #$80
    php
    pha
    php
    pha
    tsx
    stx $200
    plp
    pla
    pla
    plp


    ldx #$80
    txs
    pha
    pha

_done:
    jmp _done
