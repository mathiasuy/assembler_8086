.data  ; Segmento de datos

.code  ; Segmento de código

call funcion
saltear_final:
	mov sp, 0
	mov bx, 1
mov cx, 1
JMP fin
funcion proc
	mov ax, 1
	JMP saltear_final
	mov bx, 1
	ret
funcion endp
fin:
	mov cx, 2
call funcion

.ports ; Definición de puertos
; 200: 1,2,3  ; Ejemplo puerto simple
; 201:(100h,10),(200h,3),(?,4)  ; Ejemplo puerto PDDV

.interrupts ; Manejadores de interrupciones
; Ejemplo interrupcion del timer
;!INT 8 1
;  iret
;!ENDINT