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


    ;; repeat with zpg, X
    lda #$01
    sta $b0                     ;*$b0 == $01
    ldx #$08
    .byte $16, $a8              ;asl $a8, X
    sec
    .byte $16, $a8              ;asl $a8, X
    sec
    .byte $36, $a8              ;rol $a8, X9

    ;; check negative, carry, and zero flags
    .byte $16, $a8              ;asl $a8, X
    .byte $16, $a8              ;asl $a8, X
    .byte $16, $a8              ;asl $a8, X
    .byte $16, $a8              ;asl $a8, X
    .byte $16, $a8              ;asl $a8, X
    .byte $16, $a8              ;asl $a8, X
    .byte $16, $a8              ;asl $a8, X
    .byte $16, $a8              ;asl $a8, X


_done:
    jmp _done
