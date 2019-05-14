    .org $0000

    lda #$02
    sta $80
loop:
    adc #$01
    adc $80
    jmp loop
