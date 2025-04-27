                      ORG 0000H
0000|                 LJMP START
       
                      ORG 0100H
      START:          
                      ; --- Inicialização ---
0100|                 MOV  A,#00H        ; Zera A
0102|                 MOV  P1,#0FFH      ; Configura P1 como saída (display desligado)
0105|                 MOV  R1,#00H       ; R1 guarda o último valor de tecla
       
      MAIN_LOOP:      
0107|                 CALL SCAN_KEY      ; Varre o teclado
0109|                 CALL DISPLAY_KEY   ; Atualiza o display
010B|                 SJMP MAIN_LOOP     ; Loop infinito
       
      ;----------------------------------------
      ; SCAN_KEY: faz o escaneamento das 4 linhas
      ; e chama CHECK_COL em cada uma
      ;----------------------------------------
      SCAN_KEY:       
010D|                 MOV  R0,#01H       ; R0 = contador de teclas (1ª tecla)
                      
                      ; Linha 0
010F|                 SETB P0.0          
0111|                 CLR  P0.3          
0113|                 CALL CHECK_COL    
       
                      ; Linha 1
0115|                 SETB P0.3
0117|                 CLR  P0.2
0119|                 CALL CHECK_COL    
       
                      ; Linha 2
011B|                 SETB P0.2
011D|                 CLR  P0.1
011F|                 CALL CHECK_COL    
       
                      ; Linha 3
0121|                 SETB P0.1
0123|                 CLR  P0.0
0125|                 CALL CHECK_COL    
       
0127|                 RET
       
      ;----------------------------------------
      ; CHECK_COL: testa as 3 colunas; se alguma
      ; estiver aterrada (tecla pressionada), pula
      ; para KEY_PRESSED, senão incrementa R0
      ;----------------------------------------
      CHECK_COL:      
0128|                 JNB  P0.6, KEY_PRESSED  ; coluna 0 = 0?
012B|                 INC  R0                 
012C|                 JNB  P0.5, KEY_PRESSED  ; coluna 1 = 0?
012F|                 INC  R0                 
0130|                 JNB  P0.4, KEY_PRESSED  ; coluna 2 = 0?
0133|                 INC  R0                 
0134|                 RET
       
      KEY_PRESSED:    
0135|                 MOV  A,R0          ; A = código da tecla
0136|                 CJNE A,#0DH, STORE ; se não for 'D' (0x0D), armazena
                      ; se for tecla especial 'D', limpa display
0139|                 MOV  A,#00H
013B|                 MOV  R1,A         
013C|                 RET
       
      STORE:          
013D|                 MOV  R1,A          ; guarda em R1 o último código válido
013E|                 RET
       
      ;----------------------------------------
      ; DISPLAY_KEY: pega R1, converte via tabela
      ; e envia para o display em P1
      ;----------------------------------------
      DISPLAY_KEY:    
013F|                 MOV  A,R1
0140|                 MOV  DPTR,#TABLE
0143|                 MOVC A,@A+DPTR     ; busca padrão 7 segmentos
0144|                 MOV  P1,A
0146|                 RET
       
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
