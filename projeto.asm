;------------------------------------------------------------------------------  
; Sistema de Alarme Digital 8051  
; Reset em '*' a qualquer momento retorna a START  
; Teclado: P0.0–P0.3 (linhas), P0.4–P0.6 (colunas)  
; LCD:     D4–D7 = P1.4–P1.7, RS = P1.3, EN = P1.2  
; LEDs:    P1.0–P1.7 (ativos-low)  
;------------------------------------------------------------------------------  

RS        EQU    P1.3  
EN        EQU    P1.2  
LED_PORT  EQU    P1       ; LEDs em P1.0–P1.7, acendem com 0  

;------------------------------------------------------------------------------  
ORG 0000H  
    LJMP INIT_DISPLAY

ORG 0030H
FEI:
    DB "ALARME DIGITAL"
    DB 00h
DISPLAY:
    DB "INICIANDO"
    DB 00h

ORG 0100H
INIT_DISPLAY:
    ACALL LCD_INIT
    MOV A, #80H
    ACALL POSICIONA_CURSOR
    MOV DPTR, #FEI
    ACALL ESCREVE_STRING_ROM
    MOV A, #0C0H
    ACALL POSICIONA_CURSOR
    MOV DPTR, #DISPLAY
    ACALL ESCREVE_STRING_ROM
    ACALL DELAY_1S
    ACALL DELAY_1S
    ACALL DELAY_1S
    ACALL DELAY_1S
    ACALL CLEAR_DISPLAY
    LJMP START

ESCREVE_STRING_ROM:
    MOV R1, #00h
LOOP_STRING:
    MOV A, R1
    MOVC A, @A+DPTR
    JZ FINISH_STRING
    ACALL SEND_CHAR
    INC R1
    MOV A, R1
    JMP LOOP_STRING
FINISH_STRING:
    RET

START:
    MOV P1, #0FFH
    MOV R4, #00H
    MOV R5, #00H
    MOV R7, #00H
    MOV R6, #40H

    MOV A, #80H
    ACALL POSICIONA_CURSOR
    MOV A, #30H
    ACALL SEND_CHAR
    ACALL SEND_CHAR
    MOV A, #3AH
    ACALL SEND_CHAR
    MOV A, #30H
    ACALL SEND_CHAR
    ACALL SEND_CHAR

    ACALL TECLADO

    MOV R0, #40H
    MOV A, #80H
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

    ACALL DELAY_1S
    ACALL DELAY_1S

    MOV R0, #40H
    MOV A, @R0
    CLR C
    SUBB A, #30H
    MOV B, #10
    MUL AB
    MOV R2, A
    INC R0
    MOV A, @R0
    CLR C
    SUBB A, #30H
    ADD A, R2
    MOV R2, A

    INC R0
    MOV A, @R0
    CLR C
    SUBB A, #30H
    MOV B, #10
    MUL AB
    MOV R3, A
    INC R0
    MOV A, @R0
    CLR C
    SUBB A, #30H
    ADD A, R3
    MOV R3, A

    MOV 30H, R2
    MOV 31H, R3

    SJMP LOOP_ALARME

LOOP_ALARME:
    ACALL CHECK_ASTERISCO
    ACALL CHECK_PAUSA     ; <<< PAUSA com '#'

    MOV A, #80H
    ACALL POSICIONA_CURSOR
    MOV A, R4
    MOV B, #10
    DIV AB
    ADD A, #30H
    ACALL SEND_CHAR
    MOV A, B
    ADD A, #30H
    ACALL SEND_CHAR

    MOV A, #3AH
    ACALL SEND_CHAR

    MOV A, R5
    MOV B, #10
    DIV AB
    ADD A, #30H
    ACALL SEND_CHAR
    MOV A, B
    ADD A, #30H
    ACALL SEND_CHAR

    MOV A, R4
    CJNE A, 30H, INC_TIMER
    MOV A, R5
    CJNE A, 31H, INC_TIMER
    SJMP ALARME

INC_TIMER:
    ACALL DELAY_1S
    INC R5
    CJNE R5, #60, LOOP_ALARME
    MOV R5, #00H
    INC R4
    SJMP LOOP_ALARME

ALARME:
ALARME_LOOP:
    MOV LED_PORT, #00H
    ACALL DELAY_1S
    MOV LED_PORT, #0FFH
    ACALL DELAY_1S
    ACALL CHECK_ASTERISCO
    SJMP ALARME_LOOP

CHECK_ASTERISCO:
    SETB P0.1
    SETB P0.2
    SETB P0.3
    CLR P0.0
    NOP
    NOP
    JNB P0.6, _RESET_SISTEMA
    SETB P0.0
    RET
_RESET_SISTEMA:
    JNB P0.6, $
    ACALL CLEAR_DISPLAY
    LJMP INIT_DISPLAY

TECLADO:
    MOV R7, #00H
_READ_LOOP:
    ACALL CHECK_ASTERISCO
    CALL LINHA
    CJNE R7, #04H, _READ_LOOP
    RET

LINHA:
    MOV R0, #31H
    SETB P0.0
    CLR P0.3
    CALL COLSCAN

    MOV R0, #34H
    SETB P0.3
    CLR P0.2
    CALL COLSCAN

    MOV R0, #37H
    SETB P0.2
    CLR P0.1
    CALL COLSCAN

    SETB P0.1
    CLR P0.0
    JNB P0.6, _TECLAAST
    JNB P0.5, _TECLA0
    JNB P0.4, _TECLAHASH
    RET

_TECLAAST:
    ACALL ESPERA
    RET

_TECLA0:
    MOV A, R6
    ADD A, R7
    MOV R1, A
    MOV A, #30H
    MOV @R1, A
    INC R7
    ACALL ESPERA
    RET

_TECLAHASH:
    MOV A, R6
    ADD A, R7
    MOV R1, A
    MOV A, #23H
    MOV @R1, A
    INC R7
    ACALL ESPERA
    RET

COLSCAN:
    JNB P0.6, GOTKEY
    INC R0
    JNB P0.5, GOTKEY
    INC R0
    JNB P0.4, GOTKEY
    INC R0
    RET

GOTKEY:
    MOV A, R6
    ADD A, R7
    MOV R1, A
    MOV A, R0
    MOV @R1, A
    INC R7
ESPERA:
    JNB P0.6, ESPERA
    JNB P0.5, ESPERA
    JNB P0.4, ESPERA
    RET

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

CLEAR_DISPLAY:
    CLR RS
    CLR P1.7
    CLR P1.6
    CLR P1.5
    CLR P1.4
    ACALL PULSO_EN

    CLR P1.7
    CLR P1.6
    CLR P1.5
    SETB P1.4
    ACALL PULSO_EN

    MOV R6, #100
ROT_CLEAR:
    CALL DELAY
    DJNZ R6, ROT_CLEAR
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
    MOV R7, #5
L1: MOV R1, #255
L2: DJNZ R1, L2
    DJNZ R7, L1
    RET

;------------------------------------------------------------------------------  
; Verifica se '#' foi pressionado e entra em modo de pausa  
;------------------------------------------------------------------------------  
CHECK_PAUSA:
    SETB P0.1
    SETB P0.2
    SETB P0.3
    CLR P0.0
    NOP
    NOP

    JNB P0.4, _PAUSA_ENTRA
    SETB P0.0
    RET

_PAUSA_ENTRA:
    JNB P0.4, $
WAIT_PAUSA:
    SETB P0.1
    SETB P0.2
    SETB P0.3
    CLR P0.0
    NOP
    NOP
    JNB P0.4, _SAI_PAUSA
    SJMP WAIT_PAUSA

_SAI_PAUSA:
    JNB P0.4, $
    RET
