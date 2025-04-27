      ORG 0000H
0000| LJMP START
       
      ORG 0100H
      START:          
          ; --- Inicialização ---
0100|     MOV A, #00H        ; Zera A
0102|     MOV P1, #0FFH      ; Configura P1 como saída (display desligado)
0105|     MOV R1, #00H       ; R1 guarda o último valor de tecla
0107|     MOV R2, #00H       ; R2 = segundos
0109|     MOV R3, #00H       ; R3 = minutos
010B|     MOV R4, #00H       ; R4 = flag de cronômetro (0=inativo, 1=ativo)
010D|     MOV TMOD, #01H     ; Configura Timer 0 no modo 1 (16-bit)
       
      MAIN_LOOP:      
0110|     CALL SCAN_KEY       ; Varre o teclado
0112|     CALL DISPLAY_KEY    ; Atualiza o display
0114|     CALL CHECK_TIMER   ; Verifica o cronômetro
0116|     SJMP MAIN_LOOP     ; Loop infinito
       
      ;----------------------------------------
      ; SCAN_KEY: faz o escaneamento das 4 linhas
      ;----------------------------------------
      SCAN_KEY:       
0118|     MOV R0, #01H       ; R0 = contador de teclas (1ª tecla)
                
          ; Linha 0 (P0.3)
011A|     SETB P0.0          
011C|     CLR P0.3          
011E|     CALL CHECK_COL    
        
          ; Linha 1 (P0.2)
0120|     SETB P0.3
0122|     CLR P0.2
0124|     CALL CHECK_COL    
        
          ; Linha 2 (P0.1)
0126|     SETB P0.2
0128|     CLR P0.1
012A|     CALL CHECK_COL    
        
          ; Linha 3 (P0.0)
012C|     SETB P0.1
012E|     CLR P0.0
0130|     CALL CHECK_COL    
        
0132|     RET
       
      ;----------------------------------------
      ; CHECK_COL: verifica as colunas
      ;----------------------------------------
      CHECK_COL:      
0133|     JNB P0.6, KEY_PRESSED  ; coluna 0 (P0.6)
0136|     INC R0                 
0137|     JNB P0.5, KEY_PRESSED  ; coluna 1 (P0.5)
013A|     INC R0                 
013B|     JNB P0.4, KEY_PRESSED  ; coluna 2 (P0.4)
013E|     INC R0                 
013F|     RET
       
      KEY_PRESSED:    
0140|     MOV A, R0          ; A = código da tecla
          
          ; Verifica tecla *
0141|     CJNE A, #0BH, CHECK_HASH  ; se não for 'B' (*), verifica #
          ; Tecla * pressionada - cancela cronômetro
0144|     MOV R4, #00H       ; desativa cronômetro
0146|     MOV R2, #00H       ; zera segundos
0148|     MOV R3, #00H       ; zera minutos
014A|     MOV R1, #00H       ; limpa display
014C|     RET
          
      CHECK_HASH:
014D|     CJNE A, #0CH, CHECK_D  ; se não for 'C' (#), verifica D
          ; Tecla # pressionada - inicia cronômetro
0150|     MOV R4, #01H       ; ativa cronômetro
0152|     MOV R2, #00H       ; zera segundos
0154|     MOV R3, #00H       ; zera minutos
0156|     RET
          
      CHECK_D:
0157|     CJNE A, #0DH, STORE ; se não for 'D', armazena
          ; Tecla D pressionada - limpa display
015A|     MOV A, #00H
015C|     MOV R1, A         
015D|     RET
       
      STORE:          
015E|     MOV R1, A          ; guarda em R1 o último código válido
015F|     RET
       
      ;----------------------------------------
      ; DISPLAY_KEY: mostra o valor no display
      ;----------------------------------------
      DISPLAY_KEY:    
0160|     MOV A, R4
0161|     JZ SHOW_NORMAL    ; se cronômetro inativo, mostra tecla normal
          
          ; Mostra segundos quando cronômetro ativo
0163|     MOV A, R2
0164|     MOV DPTR, #TABLE
0167|     MOVC A, @A+DPTR    ; busca padrão 7 segmentos
0168|     MOV P1, A
016A|     RET
          
      SHOW_NORMAL:
016B|     MOV A, R1
016C|     MOV DPTR, #TABLE
016F|     MOVC A, @A+DPTR    ; busca padrão 7 segmentos
0170|     MOV P1, A
0172|     RET
       
      ;----------------------------------------
      ; CHECK_TIMER: controla o cronômetro
      ;----------------------------------------
      CHECK_TIMER:
0173|     MOV A, R4
0174|     JZ TIMER_DONE      ; se cronômetro inativo, retorna
          
          ; Verifica se passou 1 segundo usando o Timer 0
0176|     JNB TF0, TIMER_DONE  ; verifica overflow do timer
          
          ; Timer overflow ocorreu (1 segundo)
0179|     CLR TF0            ; limpa flag de overflow
017B|     MOV TH0, #3CH      ; recarrega timer para 50ms
017E|     MOV TL0, #0B0H     
          
          ; Contador de interrupções (20x50ms = 1s)
0181|     DJNZ R7, TIMER_DONE
          
          ; Reset do contador de interrupções
0183|     MOV R7, #20        ; 20 interrupções = 1 segundo
          
          ; Incrementa segundos
0185|     INC R2             
0186|     MOV A, R2
0187|     CJNE A, #60, TIMER_DONE 
018A|     MOV R2, #00H       ; zera segundos
018C|     INC R3             ; incrementa minutos
          
      TIMER_DONE:
018D|     RET
       
      ;----------------------------------------
      ; Inicialização do Timer para 50ms
      ;----------------------------------------
      INIT_TIMER:
018E|     MOV TH0, #3CH      ; Valores para 50ms em 12MHz
0191|     MOV TL0, #0B0H     
0194|     SETB TR0           ; Inicia o Timer 0
0196|     MOV R7, #20        ; 20 x 50ms = 1s
0198|     RET
       
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
01A9|     CALL INIT_TIMER
