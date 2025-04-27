ORG 0000H
LJMP START

ORG 0100H
START:
    ; --- Inicialização ---
    MOV A, #00H        ; Zera A
    MOV P1, #0FFH      ; Configura P1 como saída (display desligado)
    MOV R1, #00H       ; R1 guarda o último valor de tecla
    MOV R2, #00H       ; R2 = segundos
    MOV R3, #00H       ; R3 = minutos
    MOV R4, #00H       ; R4 = flag de cronômetro (0=inativo, 1=ativo)
    MOV TMOD, #01H     ; Configura Timer 0 no modo 1 (16-bit)

MAIN_LOOP:
    CALL SCAN_KEY       ; Varre o teclado
    CALL DISPLAY_KEY    ; Atualiza o display
    CALL CHECK_TIMER   ; Verifica o cronômetro
    SJMP MAIN_LOOP     ; Loop infinito

;----------------------------------------
; SCAN_KEY: faz o escaneamento das 4 linhas
;----------------------------------------
SCAN_KEY:
    MOV R0, #01H       ; R0 = contador de teclas (1ª tecla)
    
    ; Linha 0 (P0.3)
    SETB P0.0          
    CLR P0.3          
    CALL CHECK_COL
    
    ; Linha 1 (P0.2)
    SETB P0.3
    CLR P0.2
    CALL CHECK_COL
    
    ; Linha 2 (P0.1)
    SETB P0.2
    CLR P0.1
    CALL CHECK_COL
    
    ; Linha 3 (P0.0)
    SETB P0.1
    CLR P0.0
    CALL CHECK_COL
    
    RET

;----------------------------------------
; CHECK_COL: verifica as colunas
;----------------------------------------
CHECK_COL:
    JNB P0.6, KEY_PRESSED  ; coluna 0 (P0.6)
    INC R0                 
    JNB P0.5, KEY_PRESSED  ; coluna 1 (P0.5)
    INC R0                 
    JNB P0.4, KEY_PRESSED  ; coluna 2 (P0.4)
    INC R0                 
    RET

KEY_PRESSED:
    MOV A, R0          ; A = código da tecla
    
    ; Verifica tecla *
    CJNE A, #0BH, CHECK_HASH  ; se não for 'B' (*), verifica #
    ; Tecla * pressionada - cancela cronômetro
    MOV R4, #00H       ; desativa cronômetro
    MOV R2, #00H       ; zera segundos
    MOV R3, #00H       ; zera minutos
    MOV R1, #00H       ; limpa display
    RET
    
CHECK_HASH:
    CJNE A, #0CH, CHECK_D  ; se não for 'C' (#), verifica D
    ; Tecla # pressionada - inicia cronômetro
    MOV R4, #01H       ; ativa cronômetro
    MOV R2, #00H       ; zera segundos
    MOV R3, #00H       ; zera minutos
    RET
    
CHECK_D:
    CJNE A, #0DH, STORE ; se não for 'D', armazena
    ; Tecla D pressionada - limpa display
    MOV A, #00H
    MOV R1, A         
    RET

STORE:
    MOV R1, A          ; guarda em R1 o último código válido
    RET

;----------------------------------------
; DISPLAY_KEY: mostra o valor no display
;----------------------------------------
DISPLAY_KEY:
    MOV A, R4
    JZ SHOW_NORMAL    ; se cronômetro inativo, mostra tecla normal
    
    ; Mostra segundos quando cronômetro ativo
    MOV A, R2
    MOV DPTR, #TABLE
    MOVC A, @A+DPTR    ; busca padrão 7 segmentos
    MOV P1, A
    RET

SHOW_NORMAL:
    MOV A, R1
    MOV DPTR, #TABLE
    MOVC A, @A+DPTR    ; busca padrão 7 segmentos
    MOV P1, A
    RET

;----------------------------------------
; CHECK_TIMER: controla o cronômetro
;----------------------------------------
CHECK_TIMER:
    MOV A, R4
    JZ TIMER_DONE      ; se cronômetro inativo, retorna
    
    ; Verifica se passou 1 segundo usando o Timer 0
    JNB TF0, TIMER_DONE  ; verifica overflow do timer
    
    ; Timer overflow ocorreu (1 segundo)
    CLR TF0            ; limpa flag de overflow
    MOV TH0, #3CH      ; recarrega timer para 50ms
    MOV TL0, #0B0H
    
    ; Contador de interrupções (20x50ms = 1s)
    DJNZ R7, TIMER_DONE
    
    ; Reset do contador de interrupções
    MOV R7, #20        ; 20 interrupções = 1 segundo
    
    ; Incrementa segundos
    INC R2             
    MOV A, R2
    CJNE A, #60, TIMER_DONE
    MOV R2, #00H       ; zera segundos
    INC R3             ; incrementa minutos

TIMER_DONE:
    RET

;----------------------------------------
; Inicialização do Timer para 50ms
;----------------------------------------
INIT_TIMER:
    MOV TH0, #3CH      ; Valores para 50ms em 12MHz
    MOV TL0, #0B0H     
    SETB TR0           ; Inicia o Timer 0
    MOV R7, #20        ; 20 x 50ms = 1s
    RET

;----------------------------------------
; TABLE: padrões para display de 7 segmentos
;----------------------------------------
TABLE:
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
    DB 10001000B    ; A (10 - não usado)
    DB 11000000B    ; B (11 - *)
    DB 11000110B    ; C (12 - #)
    DB 10100001B    ; D (13)
    DB 10000110B    ; E (14 - não usado)
    DB 10001110B    ; F (15 - não usado)

; Chamada de inicialização no início do programa
