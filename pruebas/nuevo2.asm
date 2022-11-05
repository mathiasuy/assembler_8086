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

ENTRADA equ 1
PUERTO_SALIDA_DEFECTO equ 0x0010
PUERTO_LOG_DEFECTO equ 0x0011

.code
; funciones para entrada
mov sp, 0


;call poner_siguiente_operando_en_bx
mov bx, 6
call apilar_bx
mov ax, 9
mov cx, 7
push cx
;mov si, sp
call copiar_tope_a_bx

call siguiente_comando
while_no_salir:
	cmp bx, MARCA_SALIDA
	JZ salir
		si_es_NUM:
		cmp bx, COMMAND_NUM
		JZ si_es_PORT
			call poner_siguiente_operando_en_bx
			mov bx, 0
			call apilar_bx
			call copiar_tope_a_bx
		JZ fin_si
		si_es_PORT:
		cmp bx, COMMAND_PORT
		JZ si_es_LOG

		JZ fin_si
		si_es_LOG:
		cmp bx, COMMAND_LOG
		JZ si_es_TOP

		JZ fin_si
		si_es_TOP:
		cmp bx, COMMAND_TOP
		JZ si_es_DUMP

		JZ fin_si
		si_es_DUMP:
		cmp bx, COMMAND_DUMP
		JZ si_es_SWAP

		JZ fin_si
		si_es_SWAP:
		cmp bx, COMMAND_SWAP
		JZ si_es_NEG

		JZ fin_si
		si_es_NEG:
		cmp bx, COMMAND_NEG
		JZ si_es_FACT

		JZ fin_si
		si_es_FACT:
		cmp bx, COMMAND_FACT
		JZ si_es_SUM

		JZ fin_si
		si_es_SUM:
		cmp bx, COMMAND_SUM
		JZ si_es_CLR

		JZ fin_si
		si_es_CLR:
		cmp bx, COMMAND_CLEAR
		JZ si_es_HALT

		JZ fin_si
		si_es_HALT:
		cmp bx, COMMAND_HALT
		JZ si_es_OP_SUM

		JZ fin_si
		si_es_OP_SUM:
		cmp bx, OP_SUM
		JZ si_es_OP_RES

		JZ fin_si
		si_es_OP_RES:
		cmp bx, OP_RES
		JZ si_es_OP_PRO

		JZ fin_si
		si_es_OP_PRO:
		cmp bx, OP_PROD
		JZ si_es_OP_DIV

		JZ fin_si
		si_es_OP_DIV:
		cmp bx, OP_DIV
		JZ si_es_OP_MOD

		JZ fin_si
		si_es_OP_MOD:
		cmp bx, OP_MOD
		JZ si_es_OP_AND

		JZ fin_si
		si_es_OP_AND:
		cmp bx, OP_AND
		JZ si_es_OP_OR

		JZ fin_si
		si_es_OP_OR:
		cmp bx, OP_OR
		JZ si_es_OP_DIZ

		JZ fin_si
		si_es_OP_DIZ:
		cmp bx, OP_DESP_IZQ
		JZ si_es_OP_DDE

		JZ fin_si
		si_es_OP_DDE:
		cmp bx, OP_DESP_DER
		JZ si_no

		JZ fin_si
		si_no:
	fin_si:
	JMP while_no_salir
salir:

	mov si, -1
	mov bx, 2
	cmp bx, 2
	jz _saltear

;  FUNCIONES PARA ENTRADA 
	poner_siguiente_operando_en_bx proc
		in ax, ENTRADA
		mov bx, ax
		ret
	poner_siguiente_operando_en_bx endp
	siguiente_comando proc
		in ax, ENTRADA
		mov bx, ax
		ret
	siguiente_comando endp

;  FUNCIONES PARA PILA 

	apilar_bx proc
		push bx
		ret
	apilar_bx endp

	apilar_cx proc
		push cx
		ret
	apilar_cx endp


	desapilar proc
		DEC sp
		ret
	desapilar endp


	pila_no_esta_vacia proc
		cmp sp, bp
		ret
	pila_no_esta_vacia endp


	copiar_tope_a_bx proc
		mov bx, ss:[si]
		ret
	copiar_tope_a_bx endp

	falta_operando proc
		in ax, ENTRADA
		mov bx, ax
		ret
	falta_operando endp




_saltear:
	mov dx, PUERTO_SALIDA_DEFECTO; asigno a dx el puerto por defecto
	mov cx, PUERTO_LOG_DEFECTO; asigno a dx el puerto por defecto
	
.ports
ENTRADA: 2, 15, 1, 14, 1, 3, 1, 4, 11, 14, 1, 1, 11, 4, 255
PUERTO_LOG_DEFECTO: 1
PUERTO_SALIDA_DEFECTO: 1