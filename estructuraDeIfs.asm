 .data
MAX_BITS equ 16
UNO equ 1

COMMAND_NUM equ 1;
COMMAND_PORT equ 2;
COMMAND_LOG equ 3;
COMMAND_TOP equ 4;
COMMAND_DUMP equ 5;
COMMAND_DUP equ 6;
COMMAND_SWAP equ 7;
COMMAND_NEG equ 8;
COMMAND_FACT equ 9;
COMMAND_SUM equ 10;
COMMAND_CLEAR equ 254;
COMMAND_HALT equ 255;

MARCA_SALIDA equ 255;

OP_SUM equ 11;
OP_RES equ 12;
OP_PROD equ 13;
OP_DIV equ 14;
OP_MOD equ 15;
OP_AND equ 16;
OP_OR equ 17;
OP_DESP_IZQ equ 18;
OP_DESP_DER equ 19;

PILA_LLENA equ 60 ; hay que considerar al 0
ADDRESS_STACK equ 0x02000
ENTRADA equ 1
PUERTO_SALIDA_DEFECTO equ 0x0010
PUERTO_LOG_DEFECTO equ 0x0011

.code
mov si, -2; si quedara reservado para el 'indice' en la pila, empieza en -2 para que la primera inserci?n quede en el lugar 0
; ax sera el operador 1
; bx sera el operador 1
mov dx, PUERTO_LOG_DEFECTO; dx quedara reservado globalmente para la bitacora
mov cx, PUERTO_SALIDA_DEFECTO; cx quedara reservado globalmente para la salida
; para simplificar las cosas, la inteci?n es que el manejo de la pila y la entrada
; quede enmascarado en funciones y que no afecten el estado de los registros
; (o sea si los precisa, que los use, pero que al terminar deje los registros que use de manera auxiliar
; en el estado anterior al ejecutar la funci?n)
; se reservar? la menor cantidad posible de registros para tener m?s libertad de uso en el resto del c?digo
; en particular ax, ya que es el que usan las operaciones mul, idiv, in y out lo usaremos para el comando y el operando 1
; bx lo usaremos para el operando 2, se usara solo si es realmente necesario. Tanto bx, como ax ser?n manejados por las funciones que 
; manejan la pila y la entrada. A veces puede evitarse usar 2 registos recurriendo a la pila del sitema (por ejemplo en el swap)
; dx es el registro que sirve para el indicar el n?mero de puerto que se usar? para la instrucci?n in, 
; reservaremos este para la bitacora ya que es la que m?s imprime en la salida y adem?s
; reservaremos cx para guardar el n?mero de puerto de resultados de operaciones y cuando tengamos que imprimir en salida
; un resultado, asignaremos a dx cx de manera temporal volviendo a dejar dx con el valor anterior luego de imprimir en el puerto
; Se intentar? maximizar el uso de las funciones definidas, y minimizar el uso directo de instrucciones en el main 
; pasando siempre por funciones, para que estas puedan centraliar operaciones sobre los registros y controlar aisladamente 
; el estado de los registros cuando los necesita y/o modifica. Adem?s permitir? que sea  m?s amigable la lectura tanto del main
; como de las mismas funciones, que teniendo pocas instrucciones y un nombre descriptivo, evidenciar?n 
; cual es la funcionalidad que cumplen

call poner_siguiente_comando_en_ax
JZ salir
while_no_salir:
	cmp ax, MARCA_SALIDA
	JZ salir
		call log_preprocesamiento	
		si_es_NUM:
		cmp ax, COMMAND_NUM
		JNZ si_es_PORT
			call poner_siguiente_operando_en_ax
			call log_parametro	
			call apilar_ax
		JMP fin_si
		si_es_PORT:
		cmp ax, COMMAND_PORT
		JNZ si_es_LOG
			call poner_siguiente_operando_en_ax
			call log_parametro	
			mov cx, ax ; setteo cx, que es la salida, con el valor tomado en bx
		JMP fin_si
		si_es_LOG:
		cmp ax, COMMAND_LOG
		JNZ si_es_TOP
			call poner_siguiente_operando_en_ax
			call log_parametro	
			mov dx, ax ; setteo dx, que es la salida del log, con el valor tomado en bx
		JMP fin_si
		si_es_TOP:
		cmp ax, COMMAND_TOP
		JNZ si_es_DUP
			call copiar_tope_a_ax
			call imprimir_en_puerto
		JMP fin_si
		si_es_DUP:
		cmp ax, COMMAND_DUP
		JNZ si_es_DUMP
			call copiar_tope_a_ax
			call apilar_ax
		JMP fin_si
		si_es_DUMP:
		cmp ax, COMMAND_DUMP
		JNZ si_es_SWAP
			push si
			while_dump:
				call pila_no_esta_vacia
				JZ fin_while_dump
					call desapilar_hacia_ax
					call imprimir_en_puerto
				JMP while_dump
			fin_while_dump:
			pop si
		JMP fin_si
		si_es_SWAP:
		cmp ax, COMMAND_SWAP
		JNZ si_es_NEG
			call desapilar_hacia_ax
			call desapilar_hacia_bx
			call apilar_ax
			call apilar_bx
		JMP fin_si
		si_es_NEG:
		cmp ax, COMMAND_NEG
		JNZ si_es_FACT
			call desapilar_hacia_ax
			neg ax
			call apilar_ax
		JMP fin_si
		si_es_FACT:
		cmp ax, COMMAND_FACT
		JNZ si_es_SUM
			mov ax, 1
			push dx
			call desapilar_hacia_ax
			mov bx, 1
			call factorial
			call apilar_bx
			pop dx
		JMP fin_si
		si_es_SUM:
		cmp ax, COMMAND_SUM
		JNZ si_es_CLR
			push si
			mov ax, 0
			while_suma:
				call pila_no_esta_vacia
				JZ fin_while_suma
				call desapilar_hacia_bx
				add ax, bx
				JMP while_suma
			fin_while_suma:
			pop si
			call imprimir_en_puerto
		JMP fin_si
		si_es_CLR:
		cmp ax, COMMAND_CLEAR
		JNZ si_es_HALT
			mov si, 0
		JMP fin_si
		si_es_HALT:
		cmp ax, COMMAND_HALT
		JNZ si_es_OP_SUM
			JMP salir
		JMP fin_si
		si_es_OP_SUM:
		cmp ax, OP_SUM
		JNZ si_es_OP_RES
			call desapilar_hacia_ax
			call desapilar_hacia_bx
			add ax, bx 
			call apilar_ax
		JMP fin_si
		si_es_OP_RES:
		cmp ax, OP_RES
		JNZ si_es_OP_PRO
			call desapilar_hacia_ax
			call desapilar_hacia_bx
			neg bx
			add ax, bx 
			call apilar_ax
		JMP fin_si
		si_es_OP_PRO:
		cmp ax, OP_PROD
		JNZ si_es_OP_DIV
			call desapilar_hacia_ax
			call desapilar_hacia_bx
			push dx
			mul bx 
			pop dx
			call apilar_ax
		JMP fin_si
		si_es_OP_DIV:
		cmp ax, OP_DIV
		JNZ si_es_OP_MOD
			call desapilar_hacia_bx
			call desapilar_hacia_ax
			push dx
			call dividir_ax_con_bx
			pop dx
			call apilar_ax
		JMP fin_si
		si_es_OP_MOD:
		cmp ax, OP_MOD
		JNZ si_es_OP_AND
			call desapilar_hacia_bx
			call desapilar_hacia_ax
			push dx
			call dividir_ax_con_bx
			mov ax, dx
			pop dx
			call apilar_ax
		JMP fin_si
		si_es_OP_AND:
		cmp ax, OP_AND
		JNZ si_es_OP_OR
			call desapilar_hacia_ax
			call desapilar_hacia_bx
			and ax, bx
			call apilar_ax
		JMP fin_si
		si_es_OP_OR:
		cmp ax, OP_OR
		JNZ si_es_OP_DIZ
			call desapilar_hacia_ax
			call desapilar_hacia_bx
			or ax, bx
			call apilar_ax
		JMP fin_si
		si_es_OP_DIZ:
		cmp ax, OP_DESP_IZQ
		JNZ si_es_OP_DDE
			call desapilar_hacia_ax
			call desapilar_hacia_bx
			or ax, bx
			call apilar_ax
		JMP fin_si
		si_es_OP_DDE:
		cmp ax, OP_DESP_DER
		JNZ si_no
			call desapilar_hacia_ax
			call desapilar_hacia_bx
			or ax, bx
			call apilar_ax
		JMP fin_si
		si_no:
			call log_comando_invalido
			JMP contiunar_if
	fin_si:
		call log_exitoso
		JMP contiunar_if
	fin_funcion_exception:
		mov sp, 0
		JMP contiunar_if
	contiunar_if:
		call poner_siguiente_comando_en_ax
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
		mov ax, 0
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
		mov ax, 16
		out dx, ax
		cmp ax, 8 ; no activo prox JNZ si hay error
		pop ax
		ret
	log_exitoso endp

	log_desbordamiento_de_pila proc
		push ax
		mov ax, 4
		out dx, ax
		cmp ax, 4 ; activo prox JNZ si hay error
		pop ax
		JMP fin_funcion_exception
		ret
	log_desbordamiento_de_pila endp

	log_comando_invalido proc
		push ax
		mov ax, 2
		out dx, ax
		cmp ax, 2 ; activo prox JNZ si hay error
		pop ax
		JMP fin_funcion_exception
		ret
	log_comando_invalido endp

	log_falta_operando proc
		push ax
		mov ax, 8
		out dx, ax
		mov si, 0 ; vaciar pila
		cmp ax, 8 ; activo prox JNZ si hay error
		pop ax
		JMP fin_funcion_exception
		ret
	log_falta_operando endp

	desbordamiento_de_pila proc
		push ax
		mov ax, 4
		out dx, ax
		mov si, 0 ; vaciar pila
		cmp ax, 4 ; activo prox JNZ si hay error
		pop ax
		JMP fin_funcion_exception
		ret
	desbordamiento_de_pila endp

;///////// FUNCIONES PARA ENTRADA ////////////////
	poner_siguiente_operando_en_ax proc
		in ax, ENTRADA
		ret
	poner_siguiente_operando_en_ax endp

	poner_siguiente_comando_en_ax proc
		in ax, ENTRADA
		cmp ax, MARCA_SALIDA ; si JZ que salga del while
		ret
	poner_siguiente_comando_en_ax endp

;///////// FUNCIONES PARA PILA ////////////////

	check_si_habra_desbordamiento proc
		cmp si, PILA_LLENA
		JL no_hay_desbordamiento
		call log_desbordamiento_de_pila
		no_hay_desbordamiento:
		ret
	check_si_habra_desbordamiento endp

	check_falta_operando proc
		cmp ax, 0
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
	factorial proc
		factorial_while:
			cmp ax, 0
			JE factorial_es_cero
				dec ax ; incremento aca para llegar hasta 0 y ahi asignar a bx el paso base 1
				call factorial
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
	factorial endp

_saltear:
	
.ports
ENTRADA: 2, 15, 1, 14, 1, 3, 1, 4, 11, 14, 1, 1, 11, 4, 255
PUERTO_LOG_DEFECTO: 1
PUERTO_SALIDA_DEFECTO: 1

;//////////// TEST //////////////////

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
