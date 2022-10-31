 .data
MAX_BITS equ 16
ENTRADA equ 1
PUERTO_SALIDA_DEFECTO equ 0x0010
PUERTO_LOG_DEFECTO equ 0x0011

.code
	mov dx, PUERTO_SALIDA_DEFECTO; asigno a dx el puerto por defecto
	mov cx, PUERTO_LOG_DEFECTO; asigno a dx el puerto por defecto

	mov ax, 8 ; rellenado de pila
	push ax
	mov	 ax, 6
	push ax
	mov ax, 7
	push ax
	

	mov di, 6
	mov bx, sp
_pilaNoVacia: ; muevo el tope de la pila hasta su ultimo elemento
	cmp BP, SP  ; (comparando sp que es el puntero en la pila con la base de la pila)
	jz _pilaVacia
	MOV Ax, [Si]
	mov si, sp
	add sp, 2 ; y lo capturo con pop (con el ultimo pop)
	jmp _pilaNoVacia
_pilaVacia:
	add sp, -2
_pilaLlena:

	out dx, ax

.ports
ENTRADA: 1,1,1,1,1,1,1,1,255
PUERTO_LOG_DEFECTO: 1
PUERTO_SALIDA_DEFECTO: 1