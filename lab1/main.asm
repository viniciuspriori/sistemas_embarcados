#INCLUDE <P16F628A.INC> ;Inclui o arquivo de configuração do PIC16F628A

__CONFIG _BODEN_ON & _CP_OFF & _PWRTE_ON & _WDT_OFF & _LVP_OFF & _MCLRE_ON & _HS_OSC ;Configurações do microcontrolador como watchdog, monitor de queda de tensão, circuito de proteção, etc.
#DEFINE BANK0 BCF STATUS,RP0 ;Seleciona Banco 0 de memória RAM
#DEFINE BANK1 BSF STATUS,RP0 ;Seleciona Banco 1 de memória RAM

;Nomeando os pinos de saída dos LED's
; PORTB  01010101
#DEFINE LEDS 0x55

; DEFINIÇÃO DOS NOMES E ENDEREÇOS DE TODAS AS VARIÁVEIS UTILIZADAS PELO SISTEMA
	CBLOCK 0x20 ;Endereço inicial de armazenamento das variáveis. Deve ser 0x20 para o PIC16F628A.
	ENDC ;FIM DO BLOCO DE MEMÓRIA
	ORG 0x00 ;Define localização da instrução seguinte na memória de programa
	GOTO INICIO ;Vai para o rótulo início

INICIO ;Rótulo início
	BANK1 ;Seleciona o banco 1 de memória
	MOVLW 0x00 ;Move 0x00 para o registrador W
	MOVWF TRISA ;Move 0x00 do registrador W para o registrador TRISA 
	MOVLW 0x00 ;Move 0x00 para o registrador W
	MOVWF TRISB ;Move 0x00 do registrador W para o registrador TRISB, para setar os pinos deste registrador como saídas
	MOVLW 0x00 ;Move 0x00 para o registrador W
	MOVWF INTCON ;Desabilita as interrupções
	BANK0 ;Seleciona o banco 0 de memória
	MOVLW 0x07 ;Move o valor 0x7 (b'00000111') para o registrador W 
	MOVWF CMCON ;Desabilita comparadores analógicos e configura pinos do PORTA como E/S digitais
	CLRF PORTB ;Apaga o registro de PORTB

MAIN ;Rótulo MAIN
    MOVLW LEDS ;Move o valor de b'01010101' para o registrador W
	MOVWF PORTB ;Move o valor acima para o PORTB, acendendo os respectivos LED's
END