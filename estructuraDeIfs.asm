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

PILA_LLENA equ 30 ; hay que considerar al 0
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
		si_es_NUM:
		cmp ax, COMMAND_NUM
		JNZ si_es_PORT
			call poner_siguiente_operando_en_ax
			call apilar_ax
			call log_exitoso
		JMP fin_si
		si_es_PORT:
		cmp ax, COMMAND_PORT
		JNZ si_es_LOG
			call poner_siguiente_operando_en_ax
			mov cx, ax ; setteo cx, que es la salida, con el valor tomado en bx
		JMP fin_si
		si_es_LOG:
		cmp ax, COMMAND_LOG
		JNZ si_es_TOP
			call poner_siguiente_operando_en_ax
			mov dx, ax ; setteo dx, que es la salida del log, con el valor tomado en bx
		JMP fin_si
		si_es_TOP:
		cmp ax, COMMAND_TOP
		JNZ si_es_DUMP
			call copiar_tope_a_ax
			call imprimir_en_puerto
		JMP fin_si
		si_es_DUMP:
		cmp ax, COMMAND_DUMP
		JNZ si_es_SWAP
			push si
			while_dump:
				call pila_no_esta_vacia
				JZ fin_while_dump
					call copiar_tope_a_ax
					call desapilar
					call imprimir_en_puerto
				JMP while_dump
			fin_while_dump:
			pop si
		JMP fin_si
		si_es_SWAP:
		cmp ax, COMMAND_SWAP
		JNZ si_es_NEG
			call copiar_tope_a_ax
			call copiar_el_segundo_de_la_pila_a_bx_y_retornar_true_si_no_se_pudo
			jz fin_si
			call desapilar
			call desapilar
			call apilar_ax
			call apilar_bx
			call log_exitoso
		JMP fin_si
		si_es_NEG:
		cmp ax, COMMAND_NEG
		JNZ si_es_FACT
			call copiar_tope_a_ax
			call desapilar
			neg ax
			call apilar_ax
			call log_exitoso
		JMP fin_si
		si_es_FACT:
		cmp ax, COMMAND_FACT
		JNZ si_es_SUM

			call log_exitoso
		JMP fin_si
		si_es_SUM:
		cmp ax, COMMAND_SUM
		JNZ si_es_CLR
			push si
			mov bx, 0
			while_suma:
				call pila_no_esta_vacia
				JZ fin_while_suma
					call copiar_tope_a_ax
					call desapilar
					add bx, ax
				JMP while_suma
			fin_while_suma:
			pop si
			call imprimir_en_puerto
			call log_exitoso
		JMP fin_si
		si_es_CLR:
		cmp ax, COMMAND_CLEAR
		JNZ si_es_HALT
			mov si, 0
			call log_exitoso
		JMP fin_si
		si_es_HALT:
		cmp ax, COMMAND_HALT
		JNZ si_es_OP_SUM
			call log_exitoso
			JMP salir
		JMP fin_si
		si_es_OP_SUM:
		cmp ax, OP_SUM
		JNZ si_es_OP_RES
			call pre_procesamiento_operacion_binaria
			jz fin_si
			add ax, bx 
			call post_procesamiento_operacion_binaria
		JMP fin_si
		si_es_OP_RES:
		cmp ax, OP_RES
		JNZ si_es_OP_PRO
			call pre_procesamiento_operacion_binaria
			jz fin_si
			neg bx
			add ax, bx 
			call post_procesamiento_operacion_binaria
		JMP fin_si
		si_es_OP_PRO:
		cmp ax, OP_PROD
		JNZ si_es_OP_DIV
			call pre_procesamiento_operacion_binaria
			jz fin_si
			push dx
			mul bx 
			pop dx
			call log_exitoso
			call post_procesamiento_operacion_binaria
		JMP fin_si
		si_es_OP_DIV:
		cmp ax, OP_DIV
		JNZ si_es_OP_MOD
			call pre_procesamiento_operacion_binaria
			jz fin_si
			call swap_ax_con_bx
			push dx
			mov dx, 0
			cmp ax, 0
			JNL no_poner_en_negativo
				mov dx, 0xFFFF
			no_poner_en_negativo:
			idiv bx ; ax <- ax div bx
			pop dx
			call post_procesamiento_operacion_binaria
		JMP fin_si
		si_es_OP_MOD:
		cmp ax, OP_MOD
		JNZ si_es_OP_AND
			call pre_procesamiento_operacion_binaria
			jz fin_si
			push dx
			mov dx, 0
			cmp ax, 0
			JNL no_poner_en_negativo_mod
				mov dx, 0xFFFF
			no_poner_en_negativo_mod:
			idiv bx ; ax <- ax div bx
			mov ax, dx
			pop dx
			call post_procesamiento_operacion_binaria
		JMP fin_si
		si_es_OP_AND:
		cmp ax, OP_AND
		JNZ si_es_OP_OR
			call pre_procesamiento_operacion_binaria
			jz fin_si
			and ax, bx
			call post_procesamiento_operacion_binaria
		JMP fin_si
		si_es_OP_OR:
		cmp ax, OP_OR
		JNZ si_es_OP_DIZ
			call pre_procesamiento_operacion_binaria
			jz fin_si
			or ax, bx
			call post_procesamiento_operacion_binaria
		JMP fin_si
		si_es_OP_DIZ:
		cmp ax, OP_DESP_IZQ
		JNZ si_es_OP_DDE
			call pre_procesamiento_operacion_binaria
			jz fin_si
			or ax, bx
			call post_procesamiento_operacion_binaria
		JMP fin_si
		si_es_OP_DDE:
		cmp ax, OP_DESP_DER
		JNZ si_no
			call pre_procesamiento_operacion_binaria
			jz fin_si
			or ax, bx
			call post_procesamiento_operacion_binaria
		JMP fin_si
		si_no:
			call log_comando_invalido
	fin_si:
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
		ret
	log_desbordamiento_de_pila endp

	log_comando_invalido proc
		push ax
		mov ax, 2
		out dx, ax
		cmp ax, 2 ; activo prox JNZ si hay error
		pop ax
		ret
	log_comando_invalido endp

	falta_operando proc
		push ax
		mov ax, 8
		out dx, ax
		mov si, 0 ; vaciar pila
		cmp ax, 8 ; activo prox JNZ si hay error
		pop ax
		ret
	falta_operando endp

	desbordamiento_de_pila proc
		push ax
		mov ax, 4
		out dx, ax
		mov si, 0 ; vaciar pila
		cmp ax, 4 ; activo prox JNZ si hay error
		pop ax
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

	check_pila_llena proc
		push dx
		push ax
		push bx
		mov ax, si
		mov dx, 0
		mov bx, 2
		idiv bx
		cmp ax, PILA_LLENA
		pop bx
		pop ax
		pop dx
		ret
	check_pila_llena endp

	apilar_ax proc
		call check_pila_llena
		JNZ apilar_ax_continuar
			call desbordamiento_de_pila
		apilar_ax_continuar:
		add si, 2
		mov word ptr [ADDRESS_STACK+si], ax
		ret
	apilar_ax endp

	apilar_bx proc
		call check_pila_llena
		JNZ apilar_ax_continuar
			call desbordamiento_de_pila
		apilar_bx_continuar:
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

	copiar_tope_a_ax proc
		mov ax, word ptr [ADDRESS_STACK+si]
		ret
	copiar_tope_a_ax endp

	copiar_el_segundo_de_la_pila_a_bx_y_retornar_true_si_no_se_pudo proc; Si no hay segundo operando retorna false
		add si, -2
		call pila_no_esta_vacia ; Z=1 si esta vacia
		JZ terminar_metodo_ ; return true en el c++
		mov	bx, word ptr [ADDRESS_STACK+si]
		add si, 2
		JMP fin_metodo_
		terminar_metodo_:
			call falta_operando
		fin_metodo_:	
			push ax
			mov ax, 1
			cmp ax, 8 ; no activo prox JNZ si hay error
			pop ax
		ret
	copiar_el_segundo_de_la_pila_a_bx_y_retornar_true_si_no_se_pudo endp


		ret
	pre_procesamiento_operacion_binaria proc
		call copiar_tope_a_ax
		call copiar_el_segundo_de_la_pila_a_bx_y_retornar_true_si_no_se_pudo 
		ret
	pre_procesamiento_operacion_binaria endp

	post_procesamiento_operacion_binaria proc
		call desapilar
		call desapilar
		call apilar_ax
		call log_exitoso
		ret
	post_procesamiento_operacion_binaria endp

;///////// AUXILIARES ////////////////

	swap_ax_con_bx proc
		push ax
		mov ax, bx
		pop bx
		ret
	swap_ax_con_bx endp


_saltear:
	
.ports
ENTRADA: 1, 14, 1, 14, 1, 14, 1, 14, 1, 14, 1, 14, 1, 14, 1, 14, 1, 14, 1, 14, 1, 14, 1, 14, 1, 14, 1, 14, 1, 14, 1, 14, 1, 14, 1, 14, 1, 14, 1, 14, 1, 14, 1, 14, 1, 14, 1, 14, 1, 14, 1, 14, 1, 14, 1, 14, 1, 14, 1, 14, 1, 14, 1, 14, 1, 14,  255
PUERTO_LOG_DEFECTO: 1
PUERTO_SALIDA_DEFECTO: 1

;//////////// TEST //////////////////

; test mostrar errores en bitacora comando invalido y falta operando
; ENTRADA: 200, 1, 14, 11, 14, 1, 1, 11, 4, 255
;MOD 
;ENTRADA: 2, 15, 1, 3, 1, 2, 15, 4, 255

;PROD Con negativos
;ENTRADA: 2, 15, 1, -2, 1, -3, 13, 4, 255

; PROD > 0
;ENTRADA: 2, 15, 1, 2, 1, 3, 13, 4, 255

; swap 
;ENTRADA: 2, 15, 1, 14, 1, 3, 1, 4, 5, 7, 5, 255

; dump
;ENTRADA: 2, 15, 1, 14, 1, 3, 1, 4, 5, 7, 5 255

; suma 
;ENTRADA: 2, 15, 1, 14, 1, 3, 1, 4, 10, 255

; neg 
;ENTRADA: 1, 3, 8, 4, 255

; ejemplo
;ENTRADA: 2, 15, 1, 14, 1, 3, 1, 4, 11, 14, 1, 1, 11, 4, 255