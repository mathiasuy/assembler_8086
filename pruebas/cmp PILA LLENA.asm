.data  ; Segmento de datos

.code  ; Segmento de código

		mov ax, 0xFEFF ; a desplazar
		mov cl, 17 ; desplazamiento
		sal ax, cl
		
		JC hay_overflow
		JNC no_hay_overflow

		JMP fin
		hay_overflow:
			mov di, 2
		JMP fin
		no_hay_overflow:
			mov di, 1
		fin:

.ports ; Definición de puertos
; 200: 1,2,3  ; Ejemplo puerto simple
; 201:(100h,10),(200h,3),(?,4)  ; Ejemplo puerto PDDV

.interrupts ; Manejadores de interrupciones
; Ejemplo interrupcion del timer
;!INT 8 1
;  iret
;!ENDINT