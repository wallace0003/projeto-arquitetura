ORG 0000H
LJMP INICIO

ORG 0100H
INICIO:
    MOV A, #0H       ; Inicializa o acumulador
    MOV P1, #0FFH    ; Configura P1 como saída para o display
VOLTA:
    CALL TECLADO     ; Chama rotina do teclado
    CALL MOSTRA      ; Chama rotina para mostrar no display
    SJMP VOLTA       ; Loop principal

TECLADO:
    MOV R0, #01      ; clear R0 - the first key is key0
    
    ; scan row0
    SETB P0.0        ; set row3
    CLR P0.3         ; clear row0
    CALL colScan     ; call column-scan subroutine
    
    ; scan row1
    SETB P0.3        ; set row0
    CLR P0.2         ; clear row1
    CALL colScan     ; call column-scan subroutine
    
    ; scan row2
    SETB P0.2        ; set row1
    CLR P0.1         ; clear row2
    CALL colScan     ; call column-scan subroutine
    
    ; scan row3
    SETB P0.1        ; set row2
    CLR P0.0         ; clear row3
    CALL colScan     ; call column-scan subroutine
    
    CJNE R0, #0DH, SAI
    MOV A, #0H       ; Se tecla especial pressionada, zera display
SAI:
    RET

colScan:
    JNB P0.6, gotKey ; if col0 is cleared - key found
    INC R0           ; otherwise move to next key
    JNB P0.5, gotKey ; if col1 is cleared - key found
    INC R0           ; otherwise move to next key
    JNB P0.4, gotKey ; if col2 is cleared - key found
    INC R0           ; otherwise move to next key
    RET              ; return from subroutine - key not found
gotKey:
    MOV A, R0        ; Move o valor da tecla para A
    MOV R1, A        ; Armazena em R1 também
    RET

; Rotina para mostrar o número no display de 7 segmentos
MOSTRA:
    MOV DPTR, #TABELA ; Aponta para a tabela de conversão
    MOVC A, @A+DPTR   ; Obtém o padrão do display
    MOV P1, A         ; Envia para o display (conectado em P1)
    RET

; Tabela de conversão para display de 7 segmentos (ânodo comum)
; Formato: g f e d c b a
TABELA:
    DB 11000000B    ; 0
    DB 11111001B    ; 1
    DB 10100100B    ; 2
    DB 10110000B    ; 3
    DB 10011001B    ; 4
    DB 10010010B    ; 5
    DB 10000010B    ; 6
    DB 11111000B    ; 7
    DB 10000000B    ; 8
    DB 10010000B    ; 9
    DB 10001000B    ; A
    DB 10000011B    ; B
    DB 11000110B    ; C
    DB 10100001B    ; D
    DB 10000110B    ; E
    DB 10001110B    ; F