;  ___           _        __ ___  __ ___
; / __|_ _  __ _| |_____ / /| __|/  \_  )
; \__ \ ' \/ _` | / / -_) _ \__ \ () / /
; |___/_||_\__,_|_\_\___\___/___/\__/___|

; Change direction: W A S D

    .org $0600

.define appleL         $00 ; screen location of apple, low byte
.define appleH         $01 ; screen location of apple, high byte
.define snakeHeadL     $10 ; screen location of snake head, low byte
.define snakeHeadH     $11 ; screen location of snake head, high byte
.define snakeBodyStart $12 ; start of snake body byte pairs
.define snakeDirection $02 ; direction (possible values are below)
.define snakeLength    $03 ; snake length, in bytes

.define loopCount $20

; Directions (each using a separate bit)
.define movingUp      1
.define movingRight   2
.define movingDown    4
.define movingLeft    8

; ASCII values of keys controlling the snake
.define ASCII_w      $77
.define ASCII_a      $61
.define ASCII_s      $73
.define ASCII_d      $64

; System variables
.define sysRandom    $fe
.define sysLastKey   $ff



  ;; clear out the screen; set $0200 - $05ff to 0
  ldx #$00
  lda #$00
_clearscreenloop:
  sta $0200, x
  sta $0300, x
  sta $0400, x
  sta $0500, x
  inx
  bne _clearscreenloop

  lda #$00
  sta loopCount
  jsr init
  jsr loop

init:
  jsr initSnake
  jsr generateApplePosition
  rts


initSnake:
    ;; const value
  lda #$10
  sta snakeBodyStart

  lda #movingDown  ;start direction
  sta snakeDirection

  lda #20  ;start length (10 segments)
  sta snakeLength

    ;; snake head
  lda #$11
  sta snakeHeadL
  lda #$04
  sta snakeHeadH

    ;; body segment 1
    lda #$f1
    sta $12                     ; body segment 1
    lda #$d1
    sta $14                     ; body segment 2
    lda #$b1
    sta $16                     ; body segment 3
    lda #$91
    sta $18                     ; body segment 4
    lda #$71
    sta $1a                     ; body segment 5
    lda #$51
    sta $1c                     ; body segment 6
    lda #$31
    sta $1e                     ; body segment 7
    lda #$11
    sta $20                     ; body segment 8
    lda #$f1
    sta $22                     ; body segment 9
    lda #$c1
    sta $24                     ; body segment 10

    lda #$03
    sta $13                     ; body segment 1
    sta $15                     ; body segment 2
    sta $17                     ; body segment 3
    sta $19                     ; body segment 4
    sta $1b                     ; body segment 5
    sta $1d                     ; body segment 6
    sta $1f                     ; body segment 7
    sta $21                     ; body segment 8
    lda #$02
    sta $23                     ; 9
    sta $25                     ; 10
    rts

generateApplePosition:
  ;load a new random byte into $00
  lda sysRandom
  sta appleL

  ;load a new random number from 2 to 5 into $01
  lda sysRandom
  and #$03 ;mask out lowest 2 bits
  clc
  adc #2
  sta appleH

  rts

loop:
  lda loopCount
  clc
  adc #$01
  sta $4001
  sta loopCount
  lda snakeDirection
  sta $4000
  lda #$01
  sta $4002
  jsr readKeys
  lda #$02
  sta $4002
  jsr checkCollision
  lda #$04
  sta $4002
  jsr updateSnake
  lda #$08
  sta $4002
  jsr drawApple
  lda #$10
  sta $4002
  jsr drawSnake
  lda #$20
  sta $4002
  jsr spinWheels
  jmp loop


readKeys:
  lda sysLastKey
  cmp #ASCII_w
  beq upKey
  cmp #ASCII_d
  beq rightKey
  cmp #ASCII_s
  beq downKey
  cmp #ASCII_a
  beq leftKey
  rts
upKey:
  lda #movingDown
  bit snakeDirection
  bne illegalMove

  lda #movingUp
  sta snakeDirection
  rts
rightKey:
  lda #movingLeft
  bit snakeDirection
  bne illegalMove

  lda #movingRight
  sta snakeDirection
  rts
downKey:
  lda #movingUp
  bit snakeDirection
  bne illegalMove

  lda #movingDown
  sta snakeDirection
  rts
leftKey:
  lda #movingRight
  bit snakeDirection
  bne illegalMove

  lda #movingLeft
  sta snakeDirection
  rts
illegalMove:
  rts


checkCollision:
  jsr checkAppleCollision
  jsr checkSnakeCollision
  rts


checkAppleCollision:
  lda appleL
  cmp snakeHeadL
  bne doneCheckingAppleCollision
  lda appleH
  cmp snakeHeadH
  bne doneCheckingAppleCollision

  ;eat apple
  inc snakeLength
  inc snakeLength ;increase length
  jsr generateApplePosition
doneCheckingAppleCollision:
  rts


checkSnakeCollision:
  ldx #2 ;start with second segment
snakeCollisionLoop:
  lda #$81
  sta $4002
  lda snakeHeadL,x
  cmp snakeHeadL
  bne continueCollisionLoop

maybeCollided:
  lda #$82
  sta $4002

  lda snakeHeadH,x
  cmp snakeHeadH
  beq didCollide

continueCollisionLoop:
  lda #$83
  sta $4002
  inx
  inx
  cpx snakeLength          ;got to last section with no collision
  beq didntCollide
  jmp snakeCollisionLoop

didCollide:
  jmp gameOver
didntCollide:
  rts


updateSnake:
  ldx snakeLength
  dex
  txa
updateloop:
  lda snakeHeadL,x
  sta snakeBodyStart,x
  dex
  bpl updateloop

  lda snakeDirection
  lsr
  bcs up
  lsr
  bcs right
  lsr
  bcs down
  lsr
  bcs left
up:
  lda snakeHeadL
  sec
  sbc #$20
  sta snakeHeadL
  bcc upup
  rts
upup:
  dec snakeHeadH
  lda #$1
  cmp snakeHeadH
  beq collision
  rts
right:
  inc snakeHeadL
  lda #$1f
  bit snakeHeadL
  beq collision
  rts
down:
  lda snakeHeadL
  clc
  adc #$20
  sta snakeHeadL
  bcs downdown
  rts
downdown:
  inc snakeHeadH
  lda #$6
  cmp snakeHeadH
  beq collision
  rts
left:
  dec snakeHeadL
  lda snakeHeadL
  and #$1f
  cmp #$1f
  beq collision
  rts
collision:
  jmp gameOver


drawApple:
  ldy #0
  lda sysRandom
  sta (appleL),y
  rts


drawSnake:
  ldx snakeLength
  lda #0
  sta (snakeHeadL,x) ; erase end of tail

  ldx #0
  lda #1
  sta (snakeHeadL,x) ; paint head
  rts


spinWheels:
  ldx #0
spinloop:
  nop
  nop
  dex
  bne spinloop
  rts


gameOver:
  lda #$ef
  sta $4002
    jmp gameOver
