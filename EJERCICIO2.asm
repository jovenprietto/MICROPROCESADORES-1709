        ORG 0x0000       ; Dirección de inicio del programa
        ;El programa calcula la raíz cuadrada de 25
        ; restando números impares sucesivos del número original 
        ;y contando las iteraciones hasta que el número restante
        ; sea menor que el siguiente número impar.
        

        LD   A, 25       ; Cargar el número (25) en el registro A
        LD   D, A        ; Copiar A en D (usaremos D para el cálculo)
        LD   C, 0        ; Inicializar C para almacenar la raíz cuadrada
        LD   B, 1        ; B será el número impar, comenzando en 1

ciclo1:
        CP   D           ; Comparar A con D (A < D?)
        JR   C, raizob; Si A es menor que D, saltar al final usando el carry de desbordamiento 
			 ; en el caso de que el primer valor es menor que el segundo

        SUB  B           ; Restar el número impar B de A
        INC  C           ; Incrementar C, contador de la raíz cuadrada
        LD   D, A        ; Guardar A en D para la comparación en la próxima iteración
        INC  B           ; Incrementar B en 2 para el siguiente número impar
        INC  B
        JR   ciclo1   ; Repetir el ciclo hasta que A < D

raizob:
        NOP              ; Instrucción NOP (no operación) para indicar el final
                         ; El valor de C contiene la raíz cuadrada de 25 (que es 5)

        END              ; Fin del programa

;el valor entero puede ser cambiado para distintas raices.