    .segment "CODE"

reset:
    ;; we will put the number $a5 at address $025a
    lda #$02
    sta $81
    lda #$5a
    sta $80

    lda #$a5
    sta $025a
    lda #$00
    ldx #$10
    lda ($70, X)

    clc
    adc #$01
    sta ($70, X)


    ;;
    lda #$02
    sta $91
    lda #$50
    sta $90

    ldy #$0a
    lda ($90), Y
    clc
    adc ($90), Y
    iny
    sta ($90), Y

_done:
    jmp _done

    .segment "VECTORS"
    .word $fff0                ; nmi
    .word reset                ; reset
    .word $fff0                ; irq
