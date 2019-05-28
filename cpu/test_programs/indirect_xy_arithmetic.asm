    .org $0000

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

_done:
    jmp _done
