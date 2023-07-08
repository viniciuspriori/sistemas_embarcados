#INCLUDE <P16F628A.INC> ;Inclui o arquivo de configura��o do PIC16F628A

__CONFIG _BODEN_ON & _CP_OFF & _PWRTE_ON & _WDT_OFF & _LVP_OFF & _MCLRE_ON & _HS_OSC ;Configura��es do microcontrolador como watchdog, monitor de queda de tens�o, circuito de prote��o, etc.
#DEFINE BANK0 BCF STATUS,RP0 ;Seleciona Banco 0 de mem�ria RAM
#DEFINE BANK1 BSF STATUS,RP0 ;Seleciona Banco 1 de mem�ria RAM

;Nomeando os pinos de sa�da dos LED's
; PORTB  01010101
#DEFINE LEDS 0x55

; DEFINI��O DOS NOMES E ENDERE�OS DE TODAS AS VARI�VEIS UTILIZADAS PELO SISTEMA
	CBLOCK 0x20 ;Endere�o inicial de armazenamento das vari�veis. Deve ser 0x20 para o PIC16F628A.
	ENDC ;FIM DO BLOCO DE MEM�RIA
	ORG 0x00 ;Define localiza��o da instru��o seguinte na mem�ria de programa
	GOTO INICIO ;Vai para o r�tulo in�cio

INICIO ;R�tulo in�cio
	BANK1 ;Seleciona o banco 1 de mem�ria
	MOVLW 0x00 ;Move 0x00 para o registrador W
	MOVWF TRISA ;Move 0x00 do registrador W para o registrador TRISA 
	MOVLW 0x00 ;Move 0x00 para o registrador W
	MOVWF TRISB ;Move 0x00 do registrador W para o registrador TRISB, para setar os pinos deste registrador como sa�das
	MOVLW 0x00 ;Move 0x00 para o registrador W
	MOVWF INTCON ;Desabilita as interrup��es
	BANK0 ;Seleciona o banco 0 de mem�ria
	MOVLW 0x07 ;Move o valor 0x7 (b'00000111') para o registrador W 
	MOVWF CMCON ;Desabilita comparadores anal�gicos e configura pinos do PORTA como E/S digitais
	CLRF PORTB ;Apaga o registro de PORTB

MAIN ;R�tulo MAIN
    MOVLW LEDS ;Move o valor de b'01010101' para o registrador W
	MOVWF PORTB ;Move o valor acima para o PORTB, acendendo os respectivos LED's
END