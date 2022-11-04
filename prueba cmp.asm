.data  ; Segmento de datos

.code  ; Segmento de código
mov bx, 2
CMP bx, 2 ; si bx > 0 => JG es_mayor, si bx == 0 => JE es_igual, si bx < 0 => JL es_menor
JL es_menor
JE es_igual
JGE es_mayor
JMP fin
es_menor:
	mov ax, -1
JMP fin
es_igual:
	mov ax, 0
JMP fin
es_mayor:
	mov ax, 1
JMP fin
fin:

.ports ; Definición de puertos
; 200: 1,2,3  ; Ejemplo puerto simple
; 201:(100h,10),(200h,3),(?,4)  ; Ejemplo puerto PDDV

.interrupts ; Manejadores de interrupciones
; Ejemplo interrupcion del timer
;!INT 8 1
;  iret
;!ENDINT