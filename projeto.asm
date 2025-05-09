; LCD: D4-D7 = P1.4 - P1.7, RS = P1.3, EN = P1.2
; Keypad: Rows = P0.0 - P0.3, Columns = P0.4 - P0.6

RS      EQU     P1.3
EN      EQU     P1.2

ORG 0000H
    LJMP START

ORG 0030H
START:
    MOV R6, #40H      ; Endereço base para armazenar os dígitos
    MOV R5, #00H      ; Contador

    ; Inicializa LCD
    ACALL LCD_INIT

    ; Exibe 00:00
    MOV A, #80H
    ACALL POSICIONA_CURSOR
    MOV A, #30H
    ACALL SEND_CHAR
    MOV A, #30H
    ACALL SEND_CHAR
    MOV A, #3AH
    ACALL SEND_CHAR
    MOV A, #30H
    ACALL SEND_CHAR
    MOV A, #30H
    ACALL SEND_CHAR

    ; Captura 4 dígitos do teclado
    ACALL Teclado

    ; Exibe os valores digitados como hh:mm
    MOV R0, #40H
    MOV R1, #80H
    MOV A, R1
    ACALL POSICIONA_CURSOR

    MOV A, @R0
    ACALL SEND_CHAR
    INC R0
    MOV A, @R0
    ACALL SEND_CHAR
    MOV A, #3AH
    ACALL SEND_CHAR
    INC R0
    MOV A, @R0
    ACALL SEND_CHAR
    INC R0
    MOV A, @R0
    ACALL SEND_CHAR

    ; Aguarda 2 segundos
    ACALL DELAY_1S
    ACALL DELAY_1S

    ; Carrega tempo digitado
    MOV R0, #40H
    MOV A, @R0
    SUBB A, #30H
    MOV B, #10
    MUL AB
    MOV R2, A          ; R2 = hh * 10

    INC R0
    MOV A, @R0
    SUBB A, #30H
    ADD A, R2
    MOV R2, A          ; R2 = horas

    INC R0
    MOV A, @R0
    SUBB A, #30H
    MOV B, #10
    MUL AB
    MOV R3, A          ; R3 = mm * 10

    INC R0
    MOV A, @R0
    SUBB A, #30H
    ADD A, R3
    MOV R3, A          ; R3 = minutos

LOOP_TEMPO:
    ; Atualiza display
    MOV A, #80H
    ACALL POSICIONA_CURSOR

    MOV A, R2
    MOV B, #10
    DIV AB
    ADD A, #30H
    ACALL SEND_CHAR

    MOV A, B
    ADD A, #30H
    ACALL SEND_CHAR

    MOV A, #3AH
    ACALL SEND_CHAR

    MOV A, R3
    MOV B, #10
    DIV AB
    ADD A, #30H
    ACALL SEND_CHAR

    MOV A, B
    ADD A, #30H
    ACALL SEND_CHAR

    ; Espera 1 segundo
    ACALL DELAY_1S

    ; Decrementa tempo
    MOV A, R3
    CJNE A, #00H, DEC_MIN
    ; R3 == 0
    MOV A, R2
    CJNE A, #00H, DEC_HORA
    SJMP FIM          ; Tempo acabou

DEC_HORA:
    DEC R2
    MOV R3, #59
    SJMP LOOP_TEMPO

DEC_MIN:
    DEC R3
    SJMP LOOP_TEMPO

FIM:
    SJMP FIM

; -----------------------------------------------------
Teclado:
    MOV R5, #00H
READ_LOOP:
    CALL Linha
    CJNE R5, #04H, READ_LOOP
    RET

Linha:
    ; Linha 0
    MOV R0, #31H
    SETB P0.0
    CLR P0.3
    CALL colScan

    ; Linha 1
    MOV R0, #34H
    SETB P0.3
    CLR P0.2
    CALL colScan

    ; Linha 2
    MOV R0, #37H
    SETB P0.2
    CLR P0.1
    CALL colScan

    ; Linha 3
    SETB P0.1
    CLR P0.0
    JNB P0.6, teclaAsterisco
    JNB P0.5, teclaZero
    JNB P0.4, teclaHash
    RET

teclaAsterisco:
    MOV A, R6
    ADD A, R5
    MOV R1, A
    MOV A, #2AH
    MOV @R1, A
    INC R5
    ACALL espera
    RET

teclaZero:
    MOV A, R6
    ADD A, R5
    MOV R1, A
    MOV A, #30H
    MOV @R1, A
    INC R5
    ACALL espera
    RET

teclaHash:
    MOV A, R6
    ADD A, R5
    MOV R1, A
    MOV A, #23H
    MOV @R1, A
    INC R5
    ACALL espera
    RET

colScan:
    JNB P0.6, gotKey
    INC R0
    JNB P0.5, gotKey
    INC R0
    JNB P0.4, gotKey
    INC R0
    RET

gotKey:
    MOV A, R6
    ADD A, R5
    MOV R1, A
    MOV A, R0
    MOV @R1, A
    INC R5

espera:
    JNB P0.6, espera
    JNB P0.5, espera
    JNB P0.4, espera
    RET

; -----------------------------------------------------
LCD_INIT:
    CLR RS
    CLR P1.7
    CLR P1.6
    SETB P1.5
    CLR P1.4
    ACALL PULSO_EN
    ACALL DELAY

    ACALL PULSO_EN
    ACALL DELAY

    SETB P1.7
    ACALL PULSO_EN
    ACALL DELAY

    CLR P1.7
    CLR P1.6
    CLR P1.5
    CLR P1.4
    ACALL PULSO_EN

    SETB P1.6
    SETB P1.5
    ACALL PULSO_EN
    ACALL DELAY

    CLR P1.7
    CLR P1.6
    CLR P1.5
    CLR P1.4
    ACALL PULSO_EN

    SETB P1.7
    SETB P1.6
    SETB P1.5
    SETB P1.4
    ACALL PULSO_EN
    ACALL DELAY
    RET

SEND_CHAR:
    SETB RS
    MOV C, ACC.7
    MOV P1.7, C
    MOV C, ACC.6
    MOV P1.6, C
    MOV C, ACC.5
    MOV P1.5, C
    MOV C, ACC.4
    MOV P1.4, C
    ACALL PULSO_EN

    MOV C, ACC.3
    MOV P1.7, C
    MOV C, ACC.2
    MOV P1.6, C
    MOV C, ACC.1
    MOV P1.5, C
    MOV C, ACC.0
    MOV P1.4, C
    ACALL PULSO_EN
    ACALL DELAY
    RET

POSICIONA_CURSOR:
    CLR RS
    MOV C, ACC.7
    MOV P1.7, C
    MOV C, ACC.6
    MOV P1.6, C
    MOV C, ACC.5
    MOV P1.5, C
    MOV C, ACC.4
    MOV P1.4, C
    ACALL PULSO_EN

    MOV C, ACC.3
    MOV P1.7, C
    MOV C, ACC.2
    MOV P1.6, C
    MOV C, ACC.1
    MOV P1.5, C
    MOV C, ACC.0
    MOV P1.4, C
    ACALL PULSO_EN
    ACALL DELAY
    RET

PULSO_EN:
    SETB EN
    NOP
    CLR EN
    RET

DELAY:
    MOV R7, #100
DL1: DJNZ R7, DL1
    RET

DELAY_1S:
    MOV R4, #5
L1:  MOV R7, #255
L2:  DJNZ R7, L2
     DJNZ R4, L1
     RET
