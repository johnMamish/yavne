    ;; smoke test for alu absolute, X indexed instructons
    .org $0000

    lda #$40
    tax

    lda #$10
    sta $0281, X
    adc #$20
    lda $0281, X
    sta $0280, X

    lda #$01
    ora $0280, X
    adc $0280, X
    and $0280, X
    adc $0280, X
    eor $0280, X
    adc #$81
    sta $0281, X

    ;; redo experiment when popping over page boundary
    lda #$80
    tax
    lda #$10
    sta $0281, X
    adc #$20
    lda $0281, X
    sta $0280, X

    lda #$01
    ora $0280, X
    adc $0280, X
    and $0280, X
    adc $0280, X
    eor $0280, X
    adc #$81
    sta $0281, X

_done:
    jmp _done
