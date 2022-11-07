 .data

C_NUM equ 1;
C_PORT equ 2;
C_LOG equ 3;
C_TOP equ 4;
C_DUMP equ 5;
C_DUP equ 6;
C_SWAP equ 7;
C_NEG equ 8;
C_FACT equ 9;
C_SUM equ 10;
C_CLS equ 254;
C_HALT equ 255;

C_SUMA equ 11;
C_RESTA equ 12;
C_MULT equ 13;
C_DIV equ 14;
C_MOD equ 15;
C_AND equ 16;
C_OR equ 17;
C_SAL equ 18;
C_SAR equ 19;

CODIGO_NUEVO_COMANDO equ 0
CODIGO_EXITO equ 16
CODIGO_FALTAN_OPERANDOS equ 8
CODIGO_DESBORDAMIENTO_DE_PILA equ 4
CODIGO_COMANDO_INVALIDO equ 2

PILA_LLENA equ 60 ; hay que considerar al 0
COMIENZO_STACK equ -2
ADDRESS_STACK equ 0x02000
ENTRADA equ 10
PUERTO_SALIDA_DEFECTO equ 1
PUERTO_LOG_DEFECTO equ 2

.code
mov si, COMIENZO_STACK; sera el indice para el stack
mov dx, PUERTO_LOG_DEFECTO; 
mov cx, PUERTO_SALIDA_DEFECTO; 

call poner_siguiente_operando_comando_en_ax
JZ salir
while_no_salir:
	cmp ax, C_LOG ; comparo ax con C_LOG
	JNE procesar_operando_o_comando ; si no coinciden, salto hacia procesar_operando_o_comando
	si_es_LOG: ; sino, continúo aquí hasta JMP fin_si, el cual saltará incondicionalmente hasta esa label
		push ax ; respaldo el valor actual de ax
		call poner_siguiente_operando_comando_en_ax
		mov dx, ax ; setteo dx, que es la salida del log, con el valor tomado en bx
					;una vez hecho ese cambio, se puede mandar la info a imprimir de la bitacora
		pop ax ; recupero el valor de ax, ya que es por ahí por donde se pasará el valor a la funcion  log_procesamiento
		call log_preprocesamiento	; se imprimirá el preprocesamiento (0 ax)
		mov ax, dx
		call log_parametro	; ahora se imprimirá el parámetro
	JMP fin_si

	procesar_operando_o_comando: ; en caso que no sea el comando del log puede ser cualquiera de estos otros
		call log_preprocesamiento	; antes, imprimo 0, comando (que es ax)
		si_es_NUM: ; pongo la etiqueta para facil lectura porque en realidad no se usa
		cmp ax, C_NUM ; si ax, que es un comando, es C_NUM
		JNZ si_es_PORT; Si no es, paso a la siguiente etiqueta si_es_PORT y me salteo lo de abajo
			call poner_siguiente_operando_comando_en_ax
			call log_parametro	; log_parametro imprime ax en la bitacora, que es el parametro
			call apilar_ax
		JMP fin_si; Termina si_es_NUM tras haberse comprobado que ax == C_NUM y se salta a la etiqueta del fin
		si_es_PORT: ; se repite el análisis para si_es_NUM
		cmp ax, C_PORT
		JNZ si_es_TOP
			call poner_siguiente_operando_comando_en_ax
			call log_parametro		; log_parametro imprime ax en la bitacora, que es el parametro
			mov cx, ax ; setteo cx, que es la salida, con el valor tomado en bx
		JMP fin_si
		si_es_TOP:
		cmp ax, C_TOP
		JNZ si_es_DUP
			call copiar_tope_a_ax
			call imprimir_en_puerto	; imprime ax en la salida, que es el resultado
		JMP fin_si
		si_es_DUP:
		cmp ax, C_DUP
		JNZ si_es_DUMP
			call desapilar_hacia_ax
			call apilar_ax
			call apilar_ax
		JMP fin_si
		si_es_DUMP:
		cmp ax, C_DUMP
		JNZ si_es_SWAP
			push si
			while_dump:
				call pila_no_esta_vacia
				JZ fin_while_dump
					call desapilar_hacia_ax
					call imprimir_en_puerto; imprime ax en la salida, que es el resultado
				JMP while_dump
			fin_while_dump:
			pop si
		JMP fin_si
		si_es_SWAP:
		cmp ax, C_SWAP
		JNZ si_es_NEG
			call desapilar_hacia_ax
			call desapilar_hacia_bx
			call apilar_ax
			call apilar_bx
		JMP fin_si
		si_es_NEG:
		cmp ax, C_NEG
		JNZ si_es_FACT
			call desapilar_hacia_ax
			neg ax
			call apilar_ax
		JMP fin_si
		si_es_FACT:
		cmp ax, C_FACT
		JNZ si_es_SUM
			call desapilar_hacia_ax
			push dx ; respaldo dx porque el mul del factorial lo modificará
			call factorial_de_ax_dejarlo_en_bx
			pop dx ; recupero el dx anterior
			call apilar_bx
		JMP fin_si
		si_es_SUM:
		cmp ax, C_SUM
		JNZ si_es_CLR
			mov ax, 0
			while_suma:
				call pila_no_esta_vacia; cmp si, -2 
				JZ fin_while_suma
				call desapilar_hacia_bx
				add ax, bx ; ax <- ax + bx
				JMP while_suma
			fin_while_suma:
			call apilar_ax
		JMP fin_si
		si_es_CLR:
		cmp ax, C_CLS
		JNZ si_es_HALT
			mov si, COMIENZO_STACK ; dejo el puntero apuntando a al comienzo (antes del primer elemento)
		JMP fin_si
		si_es_HALT:
		cmp ax, C_HALT
		JNZ si_es_C_SUMA
			call log_exitoso
			JMP salir ; salgo del if y del while
		JMP fin_si
		si_es_C_SUMA:
		cmp ax, C_SUMA
		JNZ si_es_C_RESTA
			call desapilar_hacia_ax
			call desapilar_hacia_bx
			add ax, bx 
			call apilar_ax
		JMP fin_si
		si_es_C_RESTA:
		cmp ax, C_RESTA
		JNZ si_es_OP_PRO
			call desapilar_hacia_bx
			call desapilar_hacia_ax
			neg bx ; bx = -bx
			add ax, bx ; ax = ax - bx
			call apilar_ax
		JMP fin_si
		si_es_OP_PRO:
		cmp ax, C_MULT
		JNZ si_es_C_DIV
			call desapilar_hacia_bx
			call desapilar_hacia_ax
			push dx ; respaldo dx porque mul lo modifica
			mul bx 
			pop dx ; recupero su estado
			call apilar_ax
		JMP fin_si
		si_es_C_DIV:
		cmp ax, C_DIV
		JNZ si_es_C_MOD
			call desapilar_hacia_bx
			call desapilar_hacia_ax
			push dx; respaldo dx porque mul lo modifica
			call dividir_ax_con_bx
			pop dx; recupero su estado
			call apilar_ax
		JMP fin_si
		si_es_C_MOD:
		cmp ax, C_MOD
		JNZ si_es_C_AND
			call desapilar_hacia_bx
			call desapilar_hacia_ax
			push dx; respaldo dx porque mul lo modifica
			call dividir_ax_con_bx
			mov ax, dx ;  en el dx de la idiv esta el mod
			pop dx; recupero su estado
			call apilar_ax
		JMP fin_si
		si_es_C_AND:
		cmp ax, C_AND
		JNZ si_es_C_OR
			call desapilar_hacia_ax
			call desapilar_hacia_bx
			and ax, bx
			call apilar_ax
		JMP fin_si
		si_es_C_OR:
		cmp ax, C_OR
		JNZ si_es_OP_DIZ
			call desapilar_hacia_ax
			call desapilar_hacia_bx
			or ax, bx
			call apilar_ax
		JMP fin_si
		si_es_OP_DIZ:
		cmp ax, C_SAL
		JNZ si_es_OP_DDE
			call desapilar_hacia_bx
			call desapilar_hacia_ax
			push cx
			mov cl, bl; en la parte baja de cl
			sal ax, cl ; tenemos el desplazamiento
			pop cx
			call apilar_ax
		JMP fin_si
		si_es_OP_DDE:
		cmp ax, C_SAR
		JNZ si_no
			call desapilar_hacia_bx
			call desapilar_hacia_ax
			push cx
			mov cl, bl
			sar ax, cl
			pop cx
			call apilar_ax
		JMP fin_si
		si_no:
			call log_comando_invalido ; si no se cumplió con ninguna d elas etiquetas se termina aquí (else)
	fin_si:
		call log_exitoso
		JMP contiunar_if
	fin_funcion_exception:
		mov sp, 0
		JMP contiunar_if
	contiunar_if:
		call poner_siguiente_operando_comando_en_ax 
	JMP while_no_salir
salir:

	jmp _saltear

;///////// FUNCIONES PARA IMPRESION EN PUERTOS ///////

	imprimir_en_puerto proc
		push dx
		mov dx, cx ; cambio temporalmente la salida de la bitacora al resultado
		out dx, ax
		pop dx
		ret
	imprimir_en_puerto endp

	log_preprocesamiento proc
		push ax
		mov ax, CODIGO_NUEVO_COMANDO
		out dx, ax
		pop ax
		out dx, ax
		ret
	log_preprocesamiento endp

	log_parametro proc
		out dx, ax
		ret
	log_parametro endp

	log_exitoso proc
		push ax
		mov ax, CODIGO_EXITO
		out dx, ax
		pop ax
		ret
	log_exitoso endp

	log_desbordamiento_de_pila proc
		push ax
		mov ax, CODIGO_DESBORDAMIENTO_DE_PILA
		out dx, ax
		pop ax
		JMP fin_funcion_exception
		ret
	log_desbordamiento_de_pila endp

	log_comando_invalido proc
		push ax
		mov ax, CODIGO_COMANDO_INVALIDO
		out dx, ax
		pop ax
		JMP fin_funcion_exception
		ret
	log_comando_invalido endp

	log_falta_operando proc
		push ax
		mov ax, CODIGO_FALTAN_OPERANDOS
		out dx, ax
		mov si, COMIENZO_STACK ; vaciar pila
		pop ax
		JMP fin_funcion_exception
		ret
	log_falta_operando endp

;///////// FUNCIONES PARA ENTRADA ////////////////
	poner_siguiente_operando_comando_en_ax proc
		in ax, ENTRADA
		ret
	poner_siguiente_operando_comando_en_ax endp

;///////// FUNCIONES PARA PILA ////////////////

	check_si_habra_desbordamiento proc
		cmp si, PILA_LLENA
		JL no_hay_desbordamiento
		call log_desbordamiento_de_pila
		no_hay_desbordamiento:
		ret
	check_si_habra_desbordamiento endp

	check_falta_operando proc
		cmp si, 0
		JGE continuar
		call log_falta_operando
		continuar:
		ret
	check_falta_operando endp

	apilar_ax proc
		call check_si_habra_desbordamiento
		add si, 2
		mov word ptr [ADDRESS_STACK+si], ax
		ret
	apilar_ax endp

	apilar_bx proc
		call check_si_habra_desbordamiento
		add si, 2
		mov word ptr [ADDRESS_STACK+si], bx
		ret
	apilar_bx endp

	desapilar proc
		add si, -2
		ret
	desapilar endp

	pila_no_esta_vacia proc ; combinarlo con jnz
		cmp si, -2
		ret
	pila_no_esta_vacia endp

	desapilar_hacia_ax proc
		call check_falta_operando
		mov ax, word ptr [ADDRESS_STACK+si]
		call desapilar
		ret
	desapilar_hacia_ax endp

	copiar_tope_a_ax proc
		call check_falta_operando
		mov ax, word ptr [ADDRESS_STACK+si]
		ret
	copiar_tope_a_ax endp

	desapilar_hacia_bx proc; Si no hay segundo operando retorna false
		call check_falta_operando
		mov	bx, word ptr [ADDRESS_STACK+si]
		call desapilar
		ret
	desapilar_hacia_bx endp

;///////// AUXILIARES ////////////////

	swap_ax_con_bx proc
		call desapilar_hacia_ax
		call desapilar_hacia_bx
		call apilar_bx
		call apilar_ax
		ret
	swap_ax_con_bx endp


	;calculo del fatorial con llamada recursiva
	dividir_ax_con_bx proc
		mov dx, 0
		cmp ax, 0
		JNL no_poner_en_negativo_mod
			mov dx, 0xFFFF
		no_poner_en_negativo_mod:
		idiv bx ; ax <- ax div bx
		ret
	dividir_ax_con_bx endp

	;calculo del fatorial con llamada recursiva
	factorial_de_ax_dejarlo_en_bx proc
		factorial_while:
			cmp ax, 0
			JE factorial_es_cero
				dec ax ; incremento aca para llegar hasta 0 y ahi asignar a bx el paso base 1
				call factorial_de_ax_dejarlo_en_bx
				inc ax ; aqui empieza la vuelta recursiva
				push ax ; respaldo ax porque mul guardara en el el resultado del producto
				mul bx ; el resultado queda en ax porque la operacion lo deja en ax
				mov bx, ax ; se asigna a bx para que se use para multiplicar al proximo
				pop ax ; restauro ax
				JMP factorial_fin ; aqui hago que 'termine' el metodo
			factorial_es_cero:
				mov bx, 1 ; paso base
			factorial_fin:
		ret
	factorial_de_ax_dejarlo_en_bx endp

_saltear:
	
.ports
ENTRADA: 1,1, 1,2, 1,3, 9, 5, 2,3, 9, 5, 3,4, 7, 9, 5, 999, -999, 2,5, 5, 254, 1,-6, 1,2, 14, 4, 1,-2, 13, 4, 255

;//////////// TEST //////////////////

;

; test 1
;ENTRADA: 1,1, 1,2, 1,3, 1,4, 1,5, 1,1, 1,9, 1,8, 1,-1400, 1,10, 1,11, 1,12, 1,13, 11, 4, 12, 4, 13, 4, 14, 4, 15, 4, 16, 4, 17, 4, 18, 4, 7, 4, 19, 4, 10, 4, 8, 4, 6, 5, 254, 255 

; test 2
;ENTRADA: 11, 6, 1,1234, 7, 1,4321, 5, 12, 5, 9, 5, 1,-5, 8, 16, 1,1, 1,2, 1,3, 1,4, 1,5, 1,6, 1,7, 1,8, 1,9, 1,10, 1,11, 1,12, 1,13, 1,14, 1,15, 1,16, 1,17, 1,18, 1,19, 1,20, 1,21, 1,22, 1,23, 1,24, 1,24, 1,26, 1,27, 1,28, 1,29, 1,30, 1,31, 1,32, 1,33, 5, 255

; test 3
;ENTRADA: 1,1, 1,2, 1,3, 9, 5, 2,3, 9, 5, 3,4, 7, 9, 5, 999, -999, 2,5, 5, 254, 1,-6, 1,2, 14, 4, 1,-2, 13, 4, 255

;ENTRADA: 1, 10, 1, -14, 13, 4, 255 
;test para probar limite de pila, el tope debe ser 31  y deben haber 31 elementos. En la bitacora se debe mostrar 4 desde el 32 cuando hay desbordamiento
;ENTRADA: 1, 1, 1, 2, 1, 3, 1, 4, 1, 5, 1, 6, 1, 7, 1, 8, 1, 9, 1, 10, 1, 11, 1, 12, 1, 13, 1, 14, 1, 15, 1, 16, 1, 17, 1, 18, 1, 19, 1, 20, 1, 21, 1, 22, 1, 23, 1, 24, 1, 25, 1, 26, 1, 27, 1, 28, 1, 29, 1, 30, 1, 31, 1, 32, 1, 33, 1, 34, 5, 255

; test para probar factorial res. esperado 720
;ENTRADA: 1, 6, 9, 4, 255 

; test mostrar errores en bitacora comando invalido y falta operando
; ENTRADA: 200, 1, 14, 11, 14, 1, 1, 11, 4, 255

;MOD 1, 0
;ENTRADA: 2, 15, 1, 3, 1, 2, 15, 4, 255
;ENTRADA: 2, 15, 1, 4, 1, 2, 15, 4, 255

;PROD Con negativos
;ENTRADA: 2, 15, 1, -2, 1, -3, 13, 4, 255

; PROD > 0 6
;ENTRADA: 2, 15, 1, 2, 1, 3, 13, 4, 255

; swap 4, 3, 14, 3, 4, 14
;ENTRADA: 2, 15, 1, 14, 1, 3, 1, 4, 5, 7, 5, 255

; dump 4, 3, 14, 3, 4, 14
;ENTRADA: 2, 15, 1, 14, 1, 3, 1, 4, 5, 7, 5 255

; suma 21
;ENTRADA: 2, 15, 1, 14, 1, 3, 1, 4, 10, 255

; neg  -3
;ENTRADA: 1, 3, 8, 4, 255

; ejemplo 3
;ENTRADA: 2, 15, 1, 14, 1, 3, 1, 4, 11, 14, 1, 1, 11, 4, 255
