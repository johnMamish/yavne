    .org $0000

    jmp _start

    .res 1

    .align 128, $f0
    .res 123

    ;; loop should straddle page boundary
_start:
    lda #$07
_loop:
    adc #$FF
    sta $80
    beq _otherlabel
    bne _loop


_otherlabel:
    beq _otherlabel
_oopsie:
    jmp _oopsie
