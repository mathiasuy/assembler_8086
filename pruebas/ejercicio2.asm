.data
ENTRADA equ 1
PUERTO_SALIDA_DEFECTO equ 2
PUERTO_LOG_DEFECTO equ 3

.code

in ax, ENTRADA


mov ax, -1
cmp ax, 0
JGE continuar
	mov cx, 1
continuar:


.ports
ENTRADA: 999
