.data
MAX_BITS equ 16
ENTRADA equ 1
PUERTO_SALIDA_DEFECTO equ 0x0010
PUERTO_LOG_DEFECTO equ 0x0011

.code

	mov ax, 8 ; rellenado de pila
	push ax
	mov	 ax, 6
	push ax
	mov ax, 7
	push ax
	mov bx, sp
_pilaNoVacia: ; muevo el tope de la pila hasta su ultimo elemento
	cmp BP, SP 
	jz _pilaVacia
	mov cx, bp
	pop ax ; y lo capturo con pop (con el ultimo pop)
	jmp _pilaNoVacia
_pilaVacia:
	mov sp, bx ; recupero la pila colocando su tope en la diraccion guardada
	out PUERTO_SALIDA_DEFECTO, ax
	mov ax, 16
	out PUERTO_LOG_DEFECTO, ax

.ports
ENTRADA: 1,1,1,1,1,1,1,1,255
PUERTO_LOG_DEFECTO: 1
PUERTO_SALIDA_DEFECTO: 1