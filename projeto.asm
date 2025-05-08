; LCD: D4-D7 = P1.4 - P1.7, RS = P1.3, EN = P1.2
; Keypad: Rows = P0.0 - P0.3, Columns = P0.4 - P0.6

RS      EQU     P1.3
EN      EQU     P1.2

ORG 0000H
    LJMP START

ORG 0030H
START:
    ; Início da memória para armazenar os 4 valores
    MOV R6, #40H
    MOV R5, #00H     ; Contador

    ; Inicializa LCD
    ACALL LCD_INIT

    ; Exibe formato inicial 00:00
    MOV A, #80H
    ACALL POSICIONA_CURSOR
    MOV A, #30H      ; '0'
    ACALL SEND_CHAR
    MOV A, #30H      ; '0'
    ACALL SEND_CHAR
    MOV A, #3AH      ; ':'
    ACALL SEND_CHAR
    MOV A, #30H      ; '0'
    ACALL SEND_CHAR
    MOV A, #30H      ; '0'
    ACALL SEND_CHAR

    ; Vai ler 4 dígitos e mostrar como hh:mm
    ACALL Teclado

    ; Posiciona e escreve os valores
    MOV R0, #40H     ; Ponteiro para dados
    MOV R1, #80H     ; Cursor posição inicial

    MOV A, R1
    ACALL POSICIONA_CURSOR
    MOV A, @R0
    ACALL SEND_CHAR

    INC R0
    MOV A, @R0
    ACALL SEND_CHAR

    MOV A, #3AH      ; ':'
    ACALL SEND_CHAR

    INC R0
    MOV A, @R0
    ACALL SEND_CHAR

    INC R0
    MOV A, @R0
    ACALL SEND_CHAR

FIM:
    SJMP FIM

; ---------------- ENTRADA VIA TECLADO ----------------
Teclado:
    MOV R5, #0H
Loop:
    CALL Linha
    CJNE R5, #04H, Loop
    RET

Linha:
    ; Linha 0
    MOV R0, #31H ; começa em '1'
    SETB P0.0
    CLR P0.3
    CALL colScan

    ; Linha 1
    MOV R0, #34H ; começa em '4'
    SETB P0.3
    CLR P0.2
    CALL colScan

    ; Linha 2
    MOV R0, #37H ; começa em '7'
    SETB P0.2
    CLR P0.1
    CALL colScan

    ; Linha 3 - ajustada
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
    MOV A, #2AH      ; '*'
    MOV @R1, A
    INC R5
    ACALL espera
    RET

teclaZero:
    MOV A, R6
    ADD A, R5
    MOV R1, A
    MOV A, #30H      ; '0'
    MOV @R1, A
    INC R5
    ACALL espera
    RET

teclaHash:
    MOV A, R6
    ADD A, R5
    MOV R1, A
    MOV A, #23H      ; '#'
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

; ---------------- LCD ROUTINES ----------------

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
AGAIN: DJNZ R7, AGAIN
    RET
