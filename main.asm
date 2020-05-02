;
; ejercicio1.asm
;
; Created: 12/9/2019 09:45:51
; Author : Diego Neudeck-Nahuel Fernandez
;

		.include "m2560def.inc"
;definiciones------------------------------------
		.def paridad1=R15		;defino el registro 14 como el de paridad
		.def temp=R16			;defino a R16 como temporal
		.def cont1=R17			;defino el contador para retardo
		.def cont2=R18			;defino el contador2 para retardo
		.def cont3=R19			;para retardo
		.def puerto=R20			;puerto R20 para el puerto A
		.def aux1=R21
		.def aux2=R22
;-----------------------------------------------
;PROGRAMA PRINCIPAL
;-----------------------------------------------
		.org 0x0000
;configuracion de puertos-----------------------

		ldi temp,0x00
		out PUD, temp			;borro el bits para poder activar las pull up 
		out DDRA, temp			;configuro como entrada los pines del puerto A
		ldi temp,0xFF
		out PORTA,temp			;activo resistencias pull up
		ldi temp,0x02
		out DDRB,temp			;configuro el primer pin de B como entrada, como ENABLE 
								;el bits 1 es salida serial
		
;secuencia de inicio-----------------------------
HAB:	in puerto,PINA			;leo el puerto A y lo guardo en puerto
		clz						;pongo Z=0
		sbic PORTB,0			;pregunto si el bits cero del puerto b es cero (salta 1 si es falso, 2 si verdad)
		call cero				;hay que poner Z=1 en la subrrutina cero
		breq HAB				;me fijo si entro a subrrutina cero, si no entro voy a enviar
		call enviar				;hay que poner Z=0 en la subrrutina
		rjmp HAB





;subrutina------
;retardo de 0,01seg (lo que tarda pasar de un bit a otro)
RETAR1:	ldi cont1,255			;asigno el valor 
LOOP1:	ldi cont2, 208
LOOP2:	dec cont2
		brne LOOP2
		dec cont1
		brne LOOP1
		ret

;retardo de 0,05seg (separacion entre cada serie de dos bit)
RETAR2:	ldi cont1,150
LOOP3:	ldi cont2,100
LOOP4:	ldi cont3,17
LOOP5:	dec cont3
		brne LOOP5
		dec cont2
		brne LOOP4
		dec cont1
		brne LOOP3
		ret




;envia ceros por que la entrada habilita es uno 
cero:	cbi PORTB,1			;envio cero al puerto de salida
		sez
//		call RETAR2
		ret





;envia los datos en serie 
enviar:	call paridad		
		clr aux1				;borro cont1
		ldi aux2,8				;cont2=8
LOOP6:	lsr puerto				;cambio el carry
		brcc reset				;veo si el carry es uno o cero
		sbi PORTB,1				;si C=1 envia un cero al puerto B1
//		call RETAR1				;llamo a retardo
		rjmp incre				;incremento el contador
reset:	cbi PORTB,1				;si C=0 envia un cero al puerto B1
incre:	call RETAR1				
		inc aux1				
		cp aux1,aux2			;incremento contador
		brne LOOP6				;veo si el contador llego al bits 7
	//	call RETAR1
		clr aux1
		cp paridad1,aux1		;si son iguales es par (paridad=0)
		breq en					;si son iguales Z=1
;si es impar envio cero, si es par envio uno (paridad impar)
		cbi PORTB,1				;envio cero xq es impar
		rjmp sal
en:		sbi PORTB,1				;envio uno xq es par
		
sal:	call RETAR1
		cbi PORTB,1
		clz
		call RETAR2

		ret




;calcula paridad (parte nahuel)
paridad:
		ldi aux1,8			;remplaso R17 por cont1 para no usar tantos registros nahuel	
		clr aux2			;remplazo R18 por cont2
		mov temp,puerto
LOOP7:	lsr temp	 		;desplazo los bits del regisro en el carry.
		brcc LOOP8 			;evaluo si el valor del carry es 1 o 0.(cambie brcs por brcc xq creo qe la condicion era contraria para contar) 
		inc aux2 			;cuento los 1.
LOOP8:	dec aux1 
		brne LOOP7
		andi aux2,1			;mascara del registro para tener el bit de paridad.
		mov paridad1,aux2	;etiqueto el registro de paridad.
		ret
