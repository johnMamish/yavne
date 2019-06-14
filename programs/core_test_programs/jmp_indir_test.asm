    .segment "CODE"

reset:
    lda #$00
    jmp (pointers + 2)
addOne:
    clc
    adc #$01
    jmp done

subOne:
    clc
    adc #$ff

done:
    jmp done



pointers:
    .word subOne
    .word addOne

    .segment "VECTORS"
    .word $fff0                ; nmi
    .word reset                ; reset
    .word $fff0                ; irq
