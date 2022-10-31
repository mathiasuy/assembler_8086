.data
ENTRADA equ 1
PUERTO_SALIDA_DEFECTO equ 2
PUERTO_LOG_DEFECTO equ 3

.code
call ejercicio1
ejercicio1 proc
_if:
	cmp ax, bx; compara los 2 restando al primero el segundo sin guardar el resultado (solo afecta a las flags, por eso es comparador)
	jge _else
	; (d1<d2)
_else:
	;(d1>=d2)
	ret
ejercicio1 endp

.ports
ENTRADA: 1,1,1,1,1,1,1,1,255
