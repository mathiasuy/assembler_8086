.data
ENTRADA equ 1
PUERTO_SALIDA_DEFECTO equ 2
PUERTO_LOG_DEFECTO equ 3

.code
call ejercicio
ejercicio proc
	push ax; respaldo ax
	push bx; respaldo bx
	push cx; respaldo cx
	push si; respaldo si
	push di; respaldo di
	mov si, ax; si <- d1 hacemos esto para poder acceder a memoria
	mov di, bx; di <- d2 porque son 2 de los 3 reg para eso
_if:
	cmp si, di; compara los 2 restando al primero el segundo sin guardar el resultado (solo afecta a las flags, por eso es comparador)
	jge _else
	; (d1<d2)
	mov bx, cx
	dec bx ; bx <- d 
_for:
	cmp bx, 0
	jl _end
	mov al, es:[bx+si]
	mov es:[bx+di], al
	dec bx
	jmp _for
_else:
	;(d1>=d2)
	mov bx, 0
_for2:
	cmp bx, cx
	je _end
	mov al, es:[bx+si]
	mov es:[bx+di], al
	inc bx
	jmp _for2
_end:
	pop di; restauro di
	pop si; restauro si
	pop cx; restauro cx
	pop bx
	pop ax
	ret
	; los unicos registros para acceder a memoria son:
	; bx, si, di
	; bp es especifico para acceder a la pila, trataremos de precindir de este
	; (bp = base pinter)

	; si<-d1 (si = source index)
	; di<-d2 (di = destination index)
	; bx<-d
ejercicio endp

.ports
ENTRADA: 1,1,1,1,1,1,1,1,255
