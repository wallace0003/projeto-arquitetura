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
; Reset / vetor de reset  
;------------------------------------------------------------------------------  
ORG 0000H  
    LJMP INIT_DISPLAY

;------------------------------------------------------------------------------  
; Mensagens de inicialização  
;------------------------------------------------------------------------------  
ORG 0030H
FEI:
    DB "ALARME DIGITAL"
    DB 00h ; Marca null no fim da String
DISPLAY:
    DB "INICIANDO"
    DB 00h ; Marca null no fim da String

;------------------------------------------------------------------------------  
; Inicialização do display com mensagens  
;------------------------------------------------------------------------------  
ORG 0100H
INIT_DISPLAY:
    ; Mostra mensagens iniciais
    ACALL LCD_INIT
    MOV A, #80H            ; Posição inicial da primeira linha
    ACALL POSICIONA_CURSOR
    MOV DPTR, #FEI         ; endereço da string "ALARME DIGITAL"
    ACALL ESCREVE_STRING_ROM
    MOV A, #0C0H           ; Posição inicial da segunda linha
    ACALL POSICIONA_CURSOR
    MOV DPTR, #DISPLAY     ; endereço da string "INICIANDO"
    ACALL ESCREVE_STRING_ROM
    
    ; Aguarda 4 segundos
    ACALL DELAY_1S
    ACALL DELAY_1S
    ACALL DELAY_1S
    ACALL DELAY_1S
    
    ; Limpa display e vai para o programa principal
    ACALL CLEAR_DISPLAY
    LJMP START

; Rotina para escrever string na ROM
ESCREVE_STRING_ROM:
    MOV R1, #00h
LOOP_STRING:
    MOV A, R1
    MOVC A, @A+DPTR         ; lê da ROM
    JZ FINISH_STRING        ; fim da string
    ACALL SEND_CHAR
    INC R1
    MOV A, R1
    JMP LOOP_STRING
FINISH_STRING:
    RET

;------------------------------------------------------------------------------  
; Início / menu principal  
;------------------------------------------------------------------------------  
START:
    ; Limpa tudo
    MOV P1, #0FFH       ; LEDs apagados
    MOV R4, #00H        ; hora atual
    MOV R5, #00H        ; minuto atual
    MOV R7, #00H        ; índice de digitação
    MOV R6, #40H        ; buffer em 40H

    ; Exibe "00:00"
    MOV A, #80H
    ACALL POSICIONA_CURSOR
    MOV A, #30H  ; '0'
    ACALL SEND_CHAR
    ACALL SEND_CHAR
    MOV A, #3AH  ; ':'
    ACALL SEND_CHAR
    MOV A, #30H
    ACALL SEND_CHAR
    ACALL SEND_CHAR

    ; Lê hhmm (pode abortar em '*' e voltar aqui)
    ACALL TECLADO

    ; Mostra hh:mm digitado
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

    ; Aguarda 2s para "fechar os olhos"
    ACALL DELAY_1S
    ACALL DELAY_1S

    ; Converte ASCII→binário em R2 (hh) e R3 (mm)
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

    ; Salva alvos
    MOV 30H, R2
    MOV 31H, R3

    SJMP LOOP_ALARME

;------------------------------------------------------------------------------  
; Loop principal do relógio (atualiza display e compara com alvo)  
;------------------------------------------------------------------------------  
LOOP_ALARME:
    ACALL CHECK_ASTERISCO

    ; Atualiza display
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

    ; Se igual ao alvo, dispara alarme
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

;------------------------------------------------------------------------------  
; Alarme: pisca LEDs e aguarda '*' para reset  
;------------------------------------------------------------------------------  
ALARME:
ALARME_LOOP:
    MOV LED_PORT, #00H     ; acende todos os LEDs
    ACALL DELAY_1S

    MOV LED_PORT, #0FFH    ; apaga todos os LEDs
    ACALL DELAY_1S

    ACALL CHECK_ASTERISCO
    SJMP ALARME_LOOP

;------------------------------------------------------------------------------  
; Sub-rotina de reset por '*' (linha P0.0, coluna P0.6)  
;------------------------------------------------------------------------------  
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
    ; Espera soltar a tecla
    JNB P0.6, $ 
    ; Limpa o display
    ACALL CLEAR_DISPLAY
    ; Reinicia completamente
    LJMP INIT_DISPLAY

;------------------------------------------------------------------------------  
; Rotina de leitura de 4 dígitos (hhmm), aborta com '*'  
;------------------------------------------------------------------------------  
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

;------------------------------------------------------------------------------  
; Rotinas de LCD  
;------------------------------------------------------------------------------  
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

;------------------------------------------------------------------------------  
; Rotinas de delay  
;------------------------------------------------------------------------------  
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