FIM_TEXTO   	EQU '@'
CR              EQU     0Ah
IO_READ         EQU     FFFFh
IO_WRITE        EQU     FFFEh
IO_STATUS       EQU     FFFDh
SP_INICIAL 		EQU 	FDFFh
CURSOR			EQU		FFFCh
InterrupMask	EQU		FFFAh
TimerValue		EQU		FFF6h
TimerControl	EQU		FFF7h
INT_MASK		EQU		1000111010000010b
desativa_int	EQU		0000000000000010b
LEDs_port		EQU		FFF8h
LCD_CURSOR		EQU		FFF4h
LCD_WRITE		EQU		FFF5h
display1		EQU		FFF0h
display2		EQU		FFF1h
display3		EQU		FFF2h
display4		EQU		FFF3h
ativaLCD		EQU		1000000000000000b
LCD_linha_1		EQU		1000000000000000b
LCD_linha_1_12	EQU		1000000000001101b
LCD_linha_2_0	EQU		1000000000010000b
LCD_linha_2_4	EQU		1000000000010100b
LCD_linha_2_11	EQU		1000000000011011b


				ORIG 8000h
clear			STR '                                                         ', FIM_TEXTO
VarTexto1 		STR 'Bem-vindo ao TRON', FIM_TEXTO
VarTexto2 		STR 'Pressione I1 para comecar', FIM_TEXTO
TextoFim1		STR	'         Fim do Jogo         ', FIM_TEXTO
TextoFim2		STR	' Pressione I1 para recomecar ', FIM_TEXTO
Matriztop		STR '+------------------------------------------------+', FIM_TEXTO
Matrizside		STR '|                                                |', FIM_TEXTO
Player2			STR '#', FIM_TEXTO
Player1			STR 'X', FIM_TEXTO
LCD1			STR	'TEMPO MAX:     S', FIM_TEXTO
LCDP			STR	'J1:    J2:', FIM_TEXTO
Contador		WORD	0
Contadorms		WORD	0
Contador_dec	WORD	0
tempomax		WORD	0
delayjog		WORD	0
lvl				WORD	0
delay			WORD	0	
P1direccao		WORD	1	
P2direccao		WORD	3
LEDlvl1			WORD	0000000000000000b
LEDlvl2			WORD	0000000000001111b
LEDlvl3			WORD	0000000011111111b
LEDlvl4			WORD	0000111111111111b
LEDlvl5			WORD	1111111111111111b
pont_P1			WORD	0
pont_P2			WORD	0
colisao			WORD	0
Matriz			TAB		174Fh


; Tabela de interrupcoes
				ORIG	FE0Ah
INT10			WORD	decP1

                ORIG    FE01h
INT1            WORD    r3zero

				ORIG	FE07h
INT7			WORD	decP2

				ORIG	FE09h
INT9			WORD	incP2

				ORIG    FE0Bh
INT11			WORD	incP1

				ORIG    FE0Fh
INT15			WORD	temp1

				ORIG 0000h
				JMP 	Inicio
				
ativa_cursor:	PUSH	R1
				MOV		R1, IO_READ
				MOV		M[CURSOR], R1
				POP 	R1
				RET
				
;recebe R3 como posiçao do cursor

coloca_cursor:	MOV		M[CURSOR], R3
				RET
				

; EscCar: Rotina que efectua a escrita de um caracter para o ecra.
;       O caracter pode ser visualizado na janela de texto.
;               Entradas: pilha - caracter a escrever
;               Saidas: ---
;                       Efeitos: alteracao do registo R1
;                       alteracao da posicao de memoria M[IO]

				
EscCar:         PUSH    R1
                MOV     R1, M[SP+3]
				MOV     M[IO_WRITE], R1
				POP     R1
                RETN    1
				

; EscString: Rotina que efectua a escrita de uma cadeia de caracter, terminada
;          pelo caracter FIM_TEXTO. Pode-se definir como terminador qualquer
;          caracter ASCII.
;               Entradas: R2 - apontador para o inicio da cadeia de caracteres
;               Saidas: ---
;               Efeitos: ---

EscString:      PUSH    R1
                PUSH    R2
Ciclo:			INC		R3
				CALL	coloca_cursor
				MOV     R1, M[R2]
                CMP     R1, FIM_TEXTO
                BR.Z    FimEsc
                PUSH    R1
                CALL    EscCar
                INC     R2
                BR      Ciclo
FimEsc:         POP     R2
                POP     R1
                RET
				
clearscreen:	CALL 	ativa_cursor
				MOV		R3,R0
				MOV		R2,clear
clearlinha:		Call    coloca_cursor
				CALL	EscString
				SUB		R3,50h
				ADD		R3,100h
				CMP		R3,1800h
				Br.NP	clearlinha
				Ret
				
r3zero:			MOV 	R3,0
				RTI
				
;desenha matriz de jogo				
matriz:			CALL	ativa_cursor
				CALL	clearscreen;limpa ecra
				MOV		R2, R0
				MOV		R3,010Fh		;(1,15) posicao do cursor na janela de texto
				CALL	coloca_cursor
				MOV		R2, Matriztop	;escreve topo da matriz
				CALL    EscString
				MOV 	R4,14h			;realizar o ciclo 20 vezes (escrita da parte lateral da matriz)
				MOV		R3,020Fh
				MOV		R2, Matrizside
ladomatriz:		CALL	coloca_cursor
				CALL    EscString
				SUB		R3,33h
				ADD		R3,100h
				DEC		R4
				CMP     R4, R0
				Br.NZ 	ladomatriz
				CALL	coloca_cursor
				CALL    EscString
				SUB		R3, 33h
				ADD		R3, 100h
				CALL	coloca_cursor
				MOV		R2, Matriztop
				CALL    EscString		;escreve chao da matriz
				RET
				
;escreve centrado 'bem-vindo ao TRON'	
escreve1:		CALL	ativa_cursor
				MOV		R3,0B20h
				CALL	coloca_cursor
				MOV		R2,VarTexto1
				CALL	EscString
;escreve centrado 'pressione I1 para comecar'				
escreve2:		MOV		R3,0C1Ch
				CALL	coloca_cursor	
				MOV		R2, VarTexto2
				CALL	EscString
				Push	R1
				MOV		R1,desativa_int
				MOV		M[InterrupMask],R1
				POP		R1
pausa:			CMP     R3, 0
				BR.NZ 	pausa
				RET
;#################TEMPORIZADOR###################################################
;a cada 0,1 segundo, incrementa o contadorms, e o delay.
;incrementa tambem o delay para depois ser util a escrita do movimento dos jogadores.			
temp1:			MOV		R3,1; 0,1s			
				MOV 	M[TimerValue],R3
				MOV		M[TimerControl],R3;ativa timer
				INC		M[Contadorms]
				INC		M[delay]
				RTI
				
;temp:	rotina que relaciona o valor do contadorms(decimas de segundo), com os segundos passados.
;		a cada 10 decimas de segundo, incrementa Contador e o contador decimal.
;-------o Contador(hexadecimal) vai servir para a interaçao de valor com outras partes do programa
;-------o Contador_dec(decimal) vai servir para a escrita do mesmo valor, em decimal no display de 7 segmentos
temp:			PUSH	R1
				MOV		R1,M[Contadorms]
				CMP		R1,10
				BR.NZ	acabatemp;se contadorms != 10  ->acabatemp
				CALL	ContHex;se sim, INC contador(segundos), e contadorms=0
acabatemp:		POP		R1
				RET
				
;dec_count:		Rotina que vai transformando o valor do Contador_dec(hexadecimal) para o valor correspondente em decimal				
dec_count:		Push	R1
				Push	R2
				MOV		R2,M[Contador_dec]
				MOV		R1,000Fh
				AND		R1,M[Contador_dec]	;a instrucao AND	serve para selecionar apenas as unidades,dezenas, ou centenas pretendido para avaliar
				CMP		R1,000Ah			;se as unidades forem Ah
				BR.NZ	dezenas				;incrementa as dezenas, e zera as unidades
				ADD		R2,10h				;correspondendo ao valor em decimal
				SUB		R2,000Ah
dezenas:		MOV		R1,00F0H
				AND		R1,M[Contador_dec]
				CMP		R1,00A0h			;se as dezenas forem Ah
				BR.NZ	centenas			;incrementa as cezenas, e zera as unidades
				ADD		R2,0100h
				SUB		R2,00A0h
centenas:		MOV		R1,0F00h
				AND		R1,M[Contador_dec]
				CMP		R1,0A00h			;se as centenas==Ah
				Br.NZ	milhares			;INC	milhares, e zera valor das centenas.
				ADD		R2,1000h
				SUB		R2,0A00h
milhares:		MOV		R1,F000h
				AND		R1,M[Contador_dec]
				CMP		R1,A000h			;se o valor ultrapassar 9999, volta a zero, e continua a contar
				Br.NZ	fim_dec
				MOV		R2,R0
fim_dec:		MOV		M[Contador_dec],R2
				POP		R2
				POP		R1
				RET
				
				

					
; ContHex: Rotina que incrementa os contadores e faz reset do Contadorms
;       Entradas: M[Contador] - contador
;       Saidas: --- 
;       Efeitos: alteracao do conteudo da posicao de memoria Contador, e Contador ms, e Contador_dec
ContHex:        INC     M[Contador]
				MOV		M[Contadorms],R0
				INC		M[Contador_dec]
				CALL	dec_count
				CALL	tempo_max
                RET
				
;tempo_max		actualiza o valor do tempo_max, se o tempo do jogo passado foi maior				
tempo_max:		Push	R1
				Push	R2
				MOV		R1,M[Contador_dec]	
				MOV		R2,M[tempo_max]
				CMP		R1,R2
				Br.NP	fim_tp_max
				MOV		M[tempo_max],R1
fim_tp_max:		POP		R2
				POP		R1

				
;funcao que identifica o lvl actual do jogo---------------
;quelvl:		compara os valores de tempo do Contador, com o lvl de jogo que lhes e correspondido.
quelvl:			PUSH	R1
				MOV		R1,M[Contador]
				CMP		R1,60			;tempo de jogo == 60?
				BR.N	quelvl1			;se nao compara ao valor seguinte(40)
				MOV		R1,5			;se sim,	lvl =5
				MOV		M[lvl],R1
				POP 	R1
				Call	LEDact			;ativa as leds correspondentes ao lvl
				RET
quelvl1:		CMP		R1,40			;ciclos identicos
				BR.N	quelvl2
				MOV		R1,4
				MOV		M[lvl],R1
				POP 	R1
				Call	LEDact
				RET
quelvl2:		CMP		R1,20
				BR.N	quelvl3
				MOV		R1,3
				MOV		M[lvl],R1
				POP 	R1
				Call	LEDact
				RET
quelvl3:		CMP		R1,10
				BR.N	quelvl4
				MOV		R1,2
				MOV		M[lvl],R1
				POP 	R1
				Call	LEDact
				RET	
quelvl4:		MOV		R1,1
				MOV		M[lvl],R1
				POP 	R1
				Call	LEDact
				RET				
;---------------------------------------------------------
;acerta o delay dos jogadores consoante o lvlspeed
;lvl speed: identifica o lvl atual e retorna o valor do delay entre escrita de movimentos
lvlspeed:		PUSH	R1
				PUSH	R2
				MOV		R1,5
				CMP		M[lvl],R1			;lvl==5?
				BR.N	lvlspeed1			;se nao, compara outro valor
				MOV		R2,1				;se sim, delay entre jogadas==1(correspondente ao lvl)
				MOV		M[delayjog],R2;em decimas de segundo
				POP		R2
				POP		R1
				RET
lvlspeed1:		MOV		R1,4
				CMP		M[lvl],R1
				BR.N	lvlspeed2
				MOV		R2,2
				MOV		M[delayjog],R2;em decimas de segundo
				POP		R2
				POP		R1
				RET
lvlspeed2:		MOV		R1,3
				CMP		M[lvl],R1
				BR.N	lvlspeed3
				MOV		R2,3
				MOV		M[delayjog],R2;em decimas de segundo
				POP		R2
				POP		R1
				RET
lvlspeed3:		MOV		R1,2
				CMP		M[lvl],R1
				BR.N	lvlspeed4
				MOV		R2,5
				MOV		M[delayjog],R2;em decimas de segundo
				POP		R2
				POP		R1
				RET
lvlspeed4:		MOV		R1,1
				CMP		M[lvl],R1
				BR.N	lvlspeedfim
				MOV		R2,7
				MOV		M[delayjog],R2;em decimas de segundo
lvlspeedfim:	POP		R2
				POP		R1
				RET

;----------------------------------------------------------	

;contadelay:	conta o tempo ate ao proximo movimento
contadelay:		PUSH 	R1
				PUSH 	R2
				MOV		R1,M[delay]
				MOV		R2,M[delayjog]
				CMP		R1,R2			;compara o tempo passado desde a ultima jogada, com o valor que e suposto esperar nesse lvl
				BR.N	continuacont	;se ainda nao passou o delay correspondente ao lvl actual, continua a INC M[delay] no temporizador
				CALL	escreveplayers	;se sim escreve players
				MOV		M[delay],R0		;reset do contador deste a ultima jogada
continuacont:	POP 	R2
				POP 	R1
				RET		
;----------INTERRUPCOES DOS MOVIMENTOS------------------
incP2:			INC		M[P2direccao]
				RTI
				
decP2:			DEC		M[P2direccao]
				RTI
				
incP1:			INC		M[P1direccao]
				RTI
				
decP1:			DEC		M[P1direccao]
				RTI

;----------------------------------------------------	
;chama a escrita de cada jogador			
escreveplayers:	CALL	marca_pos1
				CALL	escreveP1
				CALL	marca_pos2
				CALL	escreveP2
				RET
;escreve os jgoadores nas posiccoes iniciais.				
pos_iniciais:	MOV		R5,0C17h;(10,8)na matriz
				MOV		R6,0C37h ;(10,40) na matriz
				MOV		R3,R5
				MOV		R2,Player1
				CALL	coloca_cursor
				CALL	EscString
				MOV		R3,R6
				MOV		R2,Player2
				CALL	coloca_cursor
				CALL	EscString
				RET
				
;-------------------escrita dos jogadores na direccao desejada----------------------------------
;determina a direcao para prosseguir com a escrita do jogador respetivo, e se for 5 reduz a direccao para 1, e se for 0 aumenta para 4
;a direccao situa-se sempre entre 1 e 4
;direccao 1-> SUl
;direccao 2-> OESTE
;direccao 3-> NORTE
;direccao 4-> ESTE
escreveP1:		PUSH	R3
				MOV		R3,M[P1direccao]
				CMP		R3,4
				Br.NP	test1				;se direcao==5  DEC	4 vezes
sub4:			DEC		M[P1direccao]
				DEC		M[P1direccao]
				DEC		M[P1direccao]
				DEC		M[P1direccao]
test1:			CMP     R3,R0
				Br.NZ	escreveP1bot		;se direcao==0  INC	4 vezes
				INC		M[P1direccao]
				INC		M[P1direccao]
				INC		M[P1direccao]
				INC		M[P1direccao]
escreveP1bot:	MOV		R3,M[P1direccao]	
				CMP		R3,1				;direccao==1?
				BR.NZ	escreveP1left		;escreve jgoador na direcao OESTE
				CALL	movplayer1bot;movimenta os jogadores
				POP		R3
				RET
escreveP1left:	MOV		R3,M[P1direccao]
				CMP		R3,2
				BR.NZ	escreveP1top
				CALL	movplayer1left
				POP		R3
				RET
escreveP1top:	MOV		R3,M[P1direccao]
				CMP		R3,3
				BR.NZ	escreveP1right
				Call	movplayer1top
				POP		R3
				RET
escreveP1right:	MOV		R3,M[P1direccao]
				CMP		R3,4
				JMP.P	sub4
				Call	movplayer1right
				POP		R3
				RET
;-----------------------------
;semelhante ao escreveP1
escreveP2:		PUSH	R3
				MOV		R3,M[P2direccao]
				CMP		R3,4
				Br.NP	test2
sub4p2:			DEC		M[P2direccao]
				DEC		M[P2direccao]
				DEC		M[P2direccao]
				DEC		M[P2direccao]
test2:			CMP     R3,R0
				Br.NZ	escreveP2bot
				INC		M[P2direccao]
				INC		M[P2direccao]
				INC		M[P2direccao]
				INC		M[P2direccao]
escreveP2bot:	MOV		R3,M[P2direccao]
				CMP		R3,1
				BR.NZ	escreveP2left
				CALL	movplayer2bot;movimenta os jogadores
				POP		R3
				RET
escreveP2left:	MOV		R3,M[P2direccao]
				CMP		R3,2
				BR.NZ	escreveP2top
				CALL	movplayer2left
				POP		R3
				RET
escreveP2top:	MOV		R3,M[P2direccao]
				CMP		R3,3
				BR.NZ	escreveP2right
				Call	movplayer2top
				POP		R3
				RET
escreveP2right:	MOV		R3,M[P2direccao]
				CMP		R3,4
				JMP.P	sub4
				Call	movplayer2right
				POP		R3
				RET

				
marca_pos1:		Push	R1
				MOV		R1,1
				MOV		M[R5+Matriz],R1
				POP		R1	
				RET
				
marca_pos2:		Push	R1
				MOV		R1,1
				MOV		M[R6+Matriz],R1
				POP		R1
				RET
;--------movimentos dos jogadores-------------	
movplayer1bot:	ADD		R5,100h				;verifica se houve colisoes antes de escrever o simbolo do jogador
				MOV		R3,R5				;se nao houver, continua
				MOV		R2,Player1			
				CALL	coloca_cursor		;coloca cursor e escreve o simbolo correspondente ao jogador
				CALL	EscString
				RET
				
movplayer1right:INC		R5		
				MOV		R3,R5
				MOV		R2,Player1
				CALL	coloca_cursor
				CALL	EscString
				RET
			
movplayer1top:	SUB		R5,100h	
				MOV		R3,R5
				MOV		R2,Player1
				CALL	coloca_cursor
				CALL	EscString
				RET
					
movplayer1left:	DEC		R5		
				MOV		R3,R5
				MOV		R2,Player1
				CALL	coloca_cursor
				CALL	EscString
				RET
;-----------------------------	
movplayer2bot:	ADD		R6,100h	
				MOV		R3,R6
				MOV		R2,Player2
				CALL	coloca_cursor
				CALL	EscString
				RET
				
movplayer2right:INC		R6
				MOV		R3,R6
				MOV		R2,Player2
				CALL	coloca_cursor
				CALL	EscString
				RET		
				
movplayer2top:	SUB		R6,100h
				MOV		R3,R6
				MOV		R2,Player2
				CALL	coloca_cursor
				CALL	EscString
				RET
				
movplayer2left:	DEC		R6
				MOV		R3,R6
				MOV		R2,Player2
				CALL	coloca_cursor
				CALL	EscString
				RET
				
;--------mostra o contador em decimal no display de 7 segmentos-------
;rotina que escreve no display de 7 segmentos o contador de tempo de jogo, em segundos
;SHR, n     serve para deslocar os bits n vezes para a direita
;ao deslocar 4 vezes um valor em hexadecimal para a direita, colocamos o seu segundo caracter, em primeiro lugar
;podemos assim fazer a escrita desse valor para o porto correspondente ao display, para representar esse valo no display
displaycount:	PUSH	R1
				MOV		R1,M[Contador_dec]
				MOV		M[display1],R1
				SHR		R1,4			
				MOV		M[display2],R1
				SHR		R1,4
				MOV		M[display3],R1
				SHR		R1,4
				MOV		M[display4],R1
				SHR		R1,4
				POP		R1
				RET
				
			
;-----------LEDs----------------------------
;determina o lvl actual do jogo, e move para o porto das LEDs, o valor em binario que corresponte a acender as luzes correspondentes ao lvl
LEDact:			PUSH	R1
				PUSH	R2
				MOV		R2,R0
				MOV		R1,M[lvl]
				CMP		R1,2
				BR.NZ	addic3
				ADD		R2,M[LEDlvl2]
				Br		addic3
addic3:			CMP		R1,3
				BR.NZ	addic4
				ADD		R2,M[LEDlvl3]
				Br		addic4
addic4:			CMP		R1,4
				BR.NZ	addic5
				ADD		R2,M[LEDlvl4]
				Br		addic5
addic5:			CMP		R1,5
				BR.NZ	fim_led
				ADD		R2,M[LEDlvl5]
				Br		fim_led
fim_led:		MOV 	M[LEDs_port],R2
				POP		R2
				POP		R1
				RET

;----------escreve no LCD---------------------------------
							
EscLCD:			Push	R1
				Push	R2
				Push	R3
				MOV		R2,LCD1	
				MOV		R3,LCD_linha_1
				CALL	EscStringLCD
				MOV		R2,LCDP
				MOV		R3,LCD_linha_2_0
				CALL	EscStringLCD
				POP		R3
				POP		R2
				POP		R1
				RET
				
	
EscStringLCD:   PUSH    R1
                PUSH    R2
CicloLCD:       MOV     R1, M[R2]
                CMP     R1, FIM_TEXTO
				BR.Z	FimEscLCD
				MOV		M[LCD_CURSOR], R3
                MOV		M[LCD_WRITE],R1
                INC     R2
				INC		R3
                BR      CicloLCD
FimEscLCD:      POP     R2
                POP     R1
                RET

;R3, posicao do cursor no lcd
;R2, string a escever
;escrever	no LCD a pontuaçao dos jogadores, e supostamente o tempo max				
esc_variaveis:	Push	R2
				Push	R3
				MOV		R3,LCD_linha_2_4
				MOV		R2,M[pont_P1]
				ADD		R2, 0030h	; Converte valor para ASCII
				MOV		M[LCD_CURSOR],R3
				MOV		M[LCD_WRITE],R2
				MOV		R3,LCD_linha_2_11
				MOV		R2,M[pont_P2]
				ADD		R2, 0030h	
				MOV		M[LCD_CURSOR],R3
				MOV		M[LCD_WRITE],R2
				MOV		R3,LCD_linha_1_12
				MOV		R2,M[tempo_max]
				ADD		R2, 0030h	
				MOV		M[LCD_CURSOR],R3
				MOV		M[LCD_WRITE],R2
				POP		R3
				POP		R2
				RET
				
				
				
				
;============Colisoes ===================
;esta rotina verifica se ha colisoes, e se houver chama imediatamente o ecra de final de jogo.
Colisoes:		CALL	colis_matriz
				CALL	Colis_jog
				CMP		R0,M[colisao]
				BR.Z	continuajogo
				CALL	FIM1
continuajogo:	RET

;---------------matriz-------------
;compara os valores de posicao actual dos jogadores, aos limites da matriz de jogo.
;se forem iguais houve colisao			

;player 1	
colis_matriz:	CMP		R5,01FFh
				Br.NN	matriz_botside
				INC		M[pont_P2]
				INC		M[colisao]
matriz_botside:	CMP		R5,1700h
				BR.NP	matriz_side_l
				INC		M[pont_P2]
				INC		M[colisao]
matriz_side_l:	PUSH	R1
				MOV		R1,00FFh
				AND		R1,R5
				CMP		R1,10h
				BR.NN	matriz_side_r
				INC		M[colisao]
				INC		M[pont_P2]
matriz_side_r:	CMP		R1,3Fh
				BR.NP	outroP
				INC		M[colisao]
				INC		M[pont_P2]

;player 2			
outroP:			POP		R1
				CMP		R6,01FFh
				Br.NN	matriz_botside1
				INC		M[pont_P1]
				INC		M[colisao]
matriz_botside1:	CMP		R6,1700h
				BR.NP	matriz_side_l1
				INC		M[pont_P1]
				INC		M[colisao]
matriz_side_l1:	PUSH	R1
				MOV		R1,00FFh
				AND		R1,R6
				CMP		R1,10h
				BR.NN	matriz_side_r1
				INC		M[colisao]
				INC		M[pont_P1]
matriz_side_r1:	CMP		R1,3Fh
				BR.NP	fim_col_matriz
				INC		M[colisao]
				INC		M[pont_P1]
fim_col_matriz:	POP		R1
				RET
;----------players----------------------
;verifica se a posicao atual do jogador, somado a matriz, corresponde ao valor 1 na posicao de memoria desse valor.
;ou seja verifica se algum jogador percorreu essa coordenada.
Colis_jog:		PUSH 	R1
				MOV		R1,1
				CMP		M[R5+Matriz],R1
				BR.NZ	contcol
				INC		M[colisao]
				INC		M[pont_P2]
contcol:		CMP		M[R6+Matriz],R1
				BR.NZ	fimcol
				INC		M[colisao]
				INC		M[pont_P1]
fimcol:			POP		R1
				RET
				
				

;====================FIM_JOGO==============0
;rotina que escreve as frases de fim do jogo no ecra.
FIM1:			MOV		R3,0B1Ah
				CALL	coloca_cursor
				MOV		R2,TextoFim1
				CALL	EscString
				
FIM2:			MOV		R3,0C1Ah
				CALL	coloca_cursor	
				MOV		R2, TextoFim2
				CALL	EscString
				MOV		R3,2
				MOV		R2,desativa_int
				MOV		M[InterrupMask],R2 ;desativa int exceto int 1.
				CALL	EscLCD
				CALL	esc_variaveis
				
pausa1:			CMP     R3, 0;pausa de fim de jogo
				BR.NZ 	pausa1
				CALL	resetstuff
				JMP		recomeca
				RET

;rotina que faz reset as variaveis que se alteram durante o jogo.
;prepara o reinicio do jogo
resetstuff:		Push	R1
				Push	R2
				Push	R3
				Push	R4
				MOV		M[Contador],R0		;reset dos contadores
				MOV		M[Contador_dec],R0
				MOV		M[Contadorms],R0
				MOV		R3,1
				MOV		R4,3
				MOV		M[P1direccao],R3	;direccao inicial dos jogadores 
				MOV		M[P2direccao],R4
				MOV		R1,M[LEDlvl1]		;todas leds desligadas
				MOV 	M[LEDs_port],R1
				DEC		M[colisao]	;reset do indicador de colisao
				CALL	resetmatriz
				POP		R4
				POP		R3
				POP		R2
				POP		R1
				RET
;reset das memorias do percurso dos jogadores	
resetmatriz:	Push	R1
				Push	R2
				Push	R3
				MOV		R1,0020h			;espaços dentro da matriz
				MOV		R2,R0
ciclo_res_mat:	MOV		M[R2+Matriz],R1
				INC		R2
				MOV		R3,174Fh
				CMP		R2,R3
				BR.NZ	ciclo_res_mat
				POP		R3
				POP		R2
				POP		R1
				RET
;====================================================================
;|															   	    |
;|					TRON-programa principal							|
;| 																    |
;====================================================================
Inicio:         MOV     R1, SP_INICIAL
                MOV     SP, R1
				MOV		R1,R0
				ENI
				CALL	escreve1
recomeca:		CALL	EscLCD
				CALL	esc_variaveis
				CALL	matriz
				CALL	pos_iniciais 

				MOV		R1,INT_MASK
				MOV		M[InterrupMask],R1 ;Permite as int A,B,7,9,1.
				MOV		R1,R0
				CALL 	temp1
				
				
ciclo_jogo:		ENI
				Call	temp
				CALL	quelvl;que lvl estamos, define lvl = ?, e acende LEDs consoante lvl
				CALL	lvlspeed;velocidade desse lvl  delayjog = ?
				CALL	contadelay;conta o delayjog, e escreve os jogadores
				Call	displaycount;mostra o contador em decimal no display de 7 segmentos, e se houve colisoes
				CALL	Colisoes
				BR		ciclo_jogo



				
				
				
				

				
				
				
				
				
				
				
				
				
				
				
				
				
				
				
				
				