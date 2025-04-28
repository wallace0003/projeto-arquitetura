ORG 0000H
LJMP INICIO

ORG 0100H
INICIO:
    MOV A, #0H       ; Inicializa o acumulador
    MOV P1, #0FFH    ; Configura P1 como saída para o display (anodo comum)
    MOV P0, #0FFH    ; Configura P0.0-P0.3 como saídas, P0.4-P0.6 como entradas
VOLTA:
    CALL TECLADO     ; Chama rotina do teclado
    CALL MOSTRA      ; Chama rotina para mostrar no display
    SJMP VOLTA       ; Loop principal

;----------------------------------------
; TECLADO: Rotina de varredura do teclado 4x3
;----------------------------------------
TECLADO:
    MOV R0, #01      ; Inicia contador de teclas (1-12)
    
    ; Varre linha 0 (P0.3)
    SETB P0.0        ; Desativa outras linhas
    SETB P0.1
    SETB P0.2
    CLR P0.3         ; Ativa linha 0
    CALL colScan     ; Verifica colunas
    
    ; Varre linha 1 (P0.2)
    SETB P0.3
    CLR P0.2
    CALL colScan
    
    ; Varre linha 2 (P0.1)
    SETB P0.2
    CLR P0.1
    CALL colScan
    
    ; Varre linha 3 (P0.0)
    SETB P0.1
    CLR P0.0
    CALL colScan
    
    ; Verifica se tecla D (13) foi pressionada
    CJNE R0, #0DH, SAI
    MOV A, #0H       ; Se tecla D pressionada, zera display
SAI:
    RET

;----------------------------------------
; colScan: Verifica colunas para tecla pressionada
;----------------------------------------
colScan:
    JNB P0.6, gotKey ; Verifica coluna 0 (P0.6)
    INC R0           ; Próxima tecla
    JNB P0.5, gotKey ; Verifica coluna 1 (P0.5)
    INC R0           ; Próxima tecla
    JNB P0.4, gotKey ; Verifica coluna 2 (P0.4)
    INC R0           ; Próxima tecla
    RET              ; Retorna se nenhuma tecla pressionada

gotKey:
    MOV A, R0        ; Move valor da tecla para A
    MOV R1, A        ; Armazena em R1
    RET

;----------------------------------------
; MOSTRA: Rotina para exibir valor no display de 7 segmentos
;----------------------------------------
MOSTRA:
    MOV A, R1        ; Carrega tecla pressionada
    MOV DPTR, #TABELA ; Aponta para tabela de conversão
    MOVC A, @A+DPTR  ; Obtém padrão do display
    MOV P1, A        ; Exibe no display
    RET

;----------------------------------------
; TABELA: Padrões para display de 7 segmentos (anodo comum)
;----------------------------------------
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
    DB 10001000B    ; A (10)
    DB 10000011B    ; B (11)
    DB 11000110B    ; C (12)
    DB 10100001B    ; D (13)
    DB 10000110B    ; E (14)
    DB 10001110B    ; F (15)

END
