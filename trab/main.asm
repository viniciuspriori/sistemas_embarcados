; --- Listagem do Processador Utilizado ---
	list	p=16F628A						;Utilizado PIC16F628A		
	
; --- Arquivos Inclusos no Projeto ---
	#include <p16F628a.inc>					;inclui o arquivo do PIC 16F628A
	
	
; --- FUSE Bits ---
; - Cristal de 4MHz
; - Desabilitamos o Watch Dog Timer
; - Habilitamos o Power Up Timer
; - Brown Out desabilitado
; - Sem programa��o em baixa tens�o, sem prote��o de c�digo, sem prote��o da mem�ria EEPROM
; - Master Clear Desabilitado
	__config _XT_OSC & _WDT_OFF & _PWRTE_ON & _BOREN_OFF & _LVP_OFF & _CP_OFF & _CPD_OFF & _MCLRE_OFF
	
	
; --- Pagina��o de Mem�ria ---
	#define		BANK0	bcf	STATUS,RP0		;Cria um mnem�nico para selecionar o banco 0 de mem�ria
	#define		BANK1	bsf	STATUS,RP0		;Cria um mnem�nico para selecionar o banco 1 de mem�ria
	
	
; --- Mapeamento de Hardware (PARADOXUS PEPTO) ---
	#define		LED2	PORTB,7				;LED2 ligado ao pino RA2
	#define		S2		PORTA,2				;Bot�o S2 ligado ao pino RA5

; --- M�scaras de bit ---
	#define MASK_LED_BTN B'10000000' ;M�scara para alterar apenas o led que corresponde ao estado de RA2
	#define MASK_LEDS_COUNTER B'01111111' ;M�scara para alterar apenas os leds da sa�da do contador


; --- Registradores de Uso Geral ---
	cblock		H'20'						;In�cio da mem�ria dispon�vel para o usu�rio
	
	W_TEMP									;Registrador para armazenar o conte�do tempor�rio de work
	STATUS_TEMP								;Registrador para armazenar o conte�do tempor�rio de STATUS
	counter									;Registrador auxiliar de contagem
	timer									;Registrador para atualizar valor do display
 	AUXPORTB7
	endc									;Final da mem�ria do usu�rio
	

; --- Vetor de RESET ---
	org			H'0000'						;Origem no endere�o 00h de mem�ria
	goto		BEGIN						;Desvia para a label in�cio
	

; --- Vetor de Interrup��o ---
	org			H'0004'						;As interrup��es deste processador apontam para este endere�o
	
; -- Salva Contexto --
	movwf 		W_TEMP						;Copia o conte�do de Work para W_TEMP
	swapf 		STATUS,W  					;Move o conte�do de STATUS com os nibbles invertidos para Work
	BANK0									;Seleciona o banco 0 de mem�ria (padr�o do RESET) 
	movwf 		STATUS_TEMP					;Copia o conte�do de STATUS com os nibbles invertidos para STATUS_TEMP

; -- Final do Salvamento de Contexto --	
	btfss		PIR1,TMR1IF					;houve overflow do Timer1?
	goto		EXIT_ISR					;n�o, desvia para sa�da da interrup��o
	bcf			PIR1,TMR1IF					;limpa a flag
	movlw		H'C8'						;move a literal 200 (decimal) para work
	BTFSS       S2    						;testa o bit do bot�o RA2
	GOTO BUTTON_PRESSED						;se pressionado, vai para BUTTON_PRESSED
	GOTO BUTTON_RELEASED					;se solto, vai para BUTTON_RELEASED

BUTTON_PRESSED: 	
	BCF LED2          						;apaga PORTB7
	MOVLW       H'64'						;move a literal 100 (decimal) para work, como esse valor � sobrescrito de C8 se o bot�o por pressionado e � mum valor menor, o timer fica mais devagar
	GOTO NEXT								;vai para a label NEXT

BUTTON_RELEASED:								
	BSF LED2								;acende PORTB7
	GOTO NEXT								;vai para a label NEXT

NEXT:
	movwf		TMR1H						;reinicializa o byte mais significativo do Timer1
	movlw		H'B0'						;move a literal B0h para work
	movwf		TMR1L 						;reinicializa o byte menos significativo do Timer1

	incf		counter,F					;incrementa counter em uma unidade
	movlw		H'05'						;move literal 05h para work
	xorwf		counter,W					; W = counter XOR B'00000101'
	
	btfss		STATUS,Z					;Resultado da opera��o foi zero?
	goto		EXIT_ISR					;n�o, desvia para sa�da da interrup��o
	clrf		counter						;zera counter
	
	incfsz		timer,F						;Decrementa contador auxiliar. timer igual a zero?
	goto		EXIT_ISR					;N�o, desvia para sa�da da interrup��o
	


; -- Recupera Contexto (Sa�da da Interrup��o) --
EXIT_ISR:
	swapf 		STATUS_TEMP,W				;Copia em Work o conte�do de STATUS_TEMP com os nibbles invertidos
	movwf 		STATUS 						;Recupera o conte�do de STATUS
	swapf 		W_TEMP,F 					;W_TEMP = W_TEMP com os nibbles invertidos 
	swapf 		W_TEMP,W  					;Recupera o conte�do de Work	
	retfie									;Retorna da interrup��o

BEGIN:
	BANK1									;muda para o banco 1 de mem�ria
	movlw		B'00000100'					;move literal B'00000100' para work
	movwf		TRISA						;configura RA3 como sa�da
	movlw		B'00000000'					;move literal B'00000000' para work
	movwf		TRISB						;configura TRISB como sa�da
	bsf			PIE1,TMR1IE					;habilita a interrup��o do Timer1
	BANK0									;muda para o banco 0 de mem�ria
	movlw		B'11000000'					;move o a literal B'11000000' para work
	movwf		INTCON						;habilita a interrup��o gloal e dos perif�ricos
	movlw		H'21'						;move a literal 21h para work
	movwf		T1CON						;liga o Timer1, prescaler 1:4, incrementa com o ciclo de m�quina
	movlw		H'3C'						;move a literal 3Ch para work
	movwf		TMR1H						;inicializa o byte mais significativo do Timer1
	movlw		H'B0'						;move a literal B0h para work
	movwf		TMR1L						;inicializa o byte menos significativo do Timer1
	clrf		counter						;zera o counter
	movlw		B'00000000'					;move literal B'00000000' para work
	movwf		timer						;inicializa timer						

UPDATE:						;chama subrotina para atualizar display 
	MOVF	PORTB, W 				;move o conteudo atual de portb para w
			ANDLW	MASK_LED_BTN 			;faz o and com o ultimo bit (nao sera modif.)
			MOVWF	AUXPORTB7   			;move o atual valor de W para F (apos o and)
			MOVF	timer,W					;move o conte�do de timer para work
			ANDLW	MASK_LEDS_COUNTER 		;m�scara para valor de contador. Considera somente at� 127
			IORWF	AUXPORTB7, W 			;faz OR de W com auxportb			
			MOVWF	PORTB        			;move o resultado para PORTB 
			GOTO   	UPDATE			;retorna para a label ENDLESS_LOOP
							
	END										;Final do Programa