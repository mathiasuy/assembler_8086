.data  ; Segmento de datos

.code  ; Segmento de código


		cmp si, 62
		JL no_hay_desbordamiento
		call log_desbordamiento_de_pila
		no_hay_desbordamiento:

.ports ; Definición de puertos
; 200: 1,2,3  ; Ejemplo puerto simple
; 201:(100h,10),(200h,3),(?,4)  ; Ejemplo puerto PDDV

.interrupts ; Manejadores de interrupciones
; Ejemplo interrupcion del timer
;!INT 8 1
;  iret
;!ENDINT