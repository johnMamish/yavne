    .org $0000

    lda #$01
    sta $0200                   ;*$0200 == $01
    asl $0200                   ;*$0200 == $02
    sec
    asl $0200                   ;*$0200 == $04
    sec
    rol $0200                   ;*$0200 == $09

    ;; check negative, carry, and zero flags
    asl $0200                   ;$12
    asl $0200                   ;$24
    asl $0200                   ;$48
    asl $0200                   ;$90   now N is set
    asl $0200                   ;$20   now C is set
    asl $0200
    asl $0200                   ;N should be set
    asl $0200                   ;now C,Z should be set


    ;; repeat with zeropage
    lda #$01
    sta $a0
    .byte $06, $a0              ; asl $a0
    sec
    .byte $06, $a0              ; asl $a0
    sec
    .byte $26, $a0

    .byte $06, $a0              ; asl $a0
    .byte $06, $a0              ; asl $a0
    .byte $06, $a0              ; asl $a0
    .byte $06, $a0              ; asl $a0
    .byte $06, $a0              ; asl $a0
    .byte $06, $a0              ; asl $a0
    .byte $06, $a0              ; asl $a0
    .byte $06, $a0              ; asl $a0

_done:
    jmp _done
