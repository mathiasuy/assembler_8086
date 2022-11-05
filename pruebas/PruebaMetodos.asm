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

ARRAY equ 0x000

.code

mov ax, 1
cmp ax, 0
JL es_menor_a_0
mov ax, -1
cmp ax, 0
JL es_menor_a_0


es_menor_a_0:
	mov bx, -1
es_mayor_a_0:
	mov bx, +1


;call poner_siguiente_operando_en_bx
mov bx, 2
mov ax, 6
div bx
;mov si, sp


JMP saltear
	sumar proc
		mov ax, 3
		ret
	sumar endp
saltear:
.ports
ENTRADA: 2, 15, 1, 14, 1, 3, 1, 4, 5, 255
PUERTO_LOG_DEFECTO: 1
PUERTO_SALIDA_DEFECTO: 1

;ENTRADA: 2, 15, 1, 14, 1, 3, 1, 4, 11, 14, 1, 1, 11, 4, 255