                      ORG 0000H
                 LJMP START
       
                      ORG 0100H
      START:          
                      ; --- Inicialização ---
                 MOV  A,#00H        ; Zera A
                 MOV  P1,#0FFH      ; Configura P1 como saída (display desligado)
                 MOV  R1,#00H       ; R1 guarda o último valor de tecla
       
      MAIN_LOOP:      
                 CALL SCAN_KEY      ; Varre o teclado
                 CALL DISPLAY_KEY   ; Atualiza o display
                 SJMP MAIN_LOOP     ; Loop infinito
       
      ;----------------------------------------
      ; SCAN_KEY: faz o escaneamento das 4 linhas
      ; e chama CHECK_COL em cada uma
      ;----------------------------------------
      SCAN_KEY:       
                 MOV  R0,#01H       ; R0 = contador de teclas (1ª tecla)
                      
                      ; Linha 0
                 SETB P0.0          
                 CLR  P0.3          
                 CALL CHECK_COL    
       
                      ; Linha 1
                 SETB P0.3
                 CLR  P0.2
                 CALL CHECK_COL    
       
                      ; Linha 2
                 SETB P0.2
                 CLR  P0.1
                 CALL CHECK_COL    
       
                      ; Linha 3
                 SETB P0.1
                 CLR  P0.0
                 CALL CHECK_COL    
       
                 RET
       
      ;----------------------------------------
      ; CHECK_COL: testa as 3 colunas; se alguma
      ; estiver aterrada (tecla pressionada), pula
      ; para KEY_PRESSED, senão incrementa R0
      ;----------------------------------------
      CHECK_COL:      
                 JNB  P0.6, KEY_PRESSED  ; coluna 0 = 0?
                 INC  R0                 
                JNB  P0.5, KEY_PRESSED  ; coluna 1 = 0?
                 INC  R0                 
                 JNB  P0.4, KEY_PRESSED  ; coluna 2 = 0?
                 INC  R0                 
                 RET
       
      KEY_PRESSED:    
                 MOV  A,R0          ; A = código da tecla
                 CJNE A,#0DH, STORE ; se não for 'D' (0x0D), armazena
                      ; se for tecla especial 'D', limpa display
                 MOV  A,#00H
                 MOV  R1,A         
                 RET
       
      STORE:          
                 MOV  R1,A          ; guarda em R1 o último código válido
                 RET
       
      ;----------------------------------------
      ; DISPLAY_KEY: pega R1, converte via tabela
      ; e envia para o display em P1
      ;----------------------------------------
      DISPLAY_KEY:    
                 MOV  A,R1
                 MOV  DPTR,#TABLE
                 MOVC A,@A+DPTR     ; busca padrão 7 segmentos
                 MOV  P1,A
                 RET
       
      ;----------------------------------------
      ; TABLE: patterns para display de 7 segmentos
      ; ânodo COMUM — bits: g f e d c b a
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
          DB 10001000B    ; A
          DB 11000000B    ; B
          DB 11000110B    ; C
          DB 10100001B    ; D
          DB 10000110B    ; E
          DB 10001110B    ; F
