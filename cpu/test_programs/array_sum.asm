    .org $0000

    ;; start index at 0.
    lda #$00
    tax

_loop:
    ;; add
    lda _result
    adc $1c, x
    sta _result

    ;; increment index
    lda _index
    adc #$01
    sta _index
    tax

    jmp _loop

_done:
    jmp _done

_index:
    .byte $00

_result:
    .byte $10

_list:
    .byte $1, $2, $3, $4, $5, $6, $7, $8, $9, $a
