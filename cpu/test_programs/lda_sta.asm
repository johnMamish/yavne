.org $0000

    lda #$01
    sta $0200
    lda #$05
    sta $0201
    lda #$08
    sta $0202

    tax
    lda #$a5
    txa

_done:
    jmp _done
