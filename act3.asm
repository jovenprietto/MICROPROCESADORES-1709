    ORG 0000h         ; Origen del código

; =======================================
; Inicio del programa principal
; =======================================
START:
    CALL INIT_PPI           ; Inicializar el PPI
    CALL PRINT_START_TEXT   ; Mostrar mensaje de inicio
    CALL GENERATE_NUMBERS   ; Generar 20 números aleatorios
    CALL PRINT_NUMBERS      ; Mostrar los números generados

ASK_SORT_ORDER:
    CALL PRINT_SORT_TEXT    ; Preguntar cómo ordenar
    CALL READ_INPUT         ; Leer la opción del usuario (A: ascendente, D: descendente)
    CP 'A'
    JR Z, SORT_ASCENDING    ; Si es 'A', ordenar ascendente
    CP 'D'
    JR Z, SORT_DESCENDING   ; Si es 'D', ordenar descendente

SORT_ASCENDING:
    CALL SORT_NUMBERS_ASC   ; Ordenar los números en forma ascendente
    CALL PRINT_SORTED_NUMBERS ; Mostrar los números ordenados
    JR ASK_RETRY            ; Saltar para preguntar si repetir el programa

SORT_DESCENDING:
    CALL SORT_NUMBERS_DESC  ; Ordenar los números en forma descendente
    CALL PRINT_SORTED_NUMBERS ; Mostrar los números ordenados
    JR ASK_RETRY            ; Saltar para preguntar si repetir el programa

ASK_RETRY:
    CALL PRINT_RETRY_TEXT   ; Preguntar si desea continuar
    CALL READ_INPUT         ; Leer entrada del usuario (R: repetir, S: salir)
    CP 'R'
    JR Z, START             ; Si es 'R', reiniciar el programa
    CP 'S'
    JR Z, EXIT_PROGRAM      ; Si es 'S', salir del programa
    JR ASK_RETRY            ; Volver a preguntar si no es 'R' ni 'S'

EXIT_PROGRAM:
    CALL PRINT_EXIT_TEXT    ; Mostrar mensaje de salida
    JP START                ; Reiniciar el programa (en sistemas reales, aquí se apagaría o finalizaría)

; =======================================
; Subrutina: Inicialización del PPI
; =======================================
INIT_PPI:
    LD A, 10010010B         ; Configurar PPI: puerto A salida, puerto B entrada, modo 0
    OUT (0x03), A           ; Enviar configuración al registro de control del PPI
    RET

; =======================================
; Subrutina: Mostrar texto de inicio
; =======================================
PRINT_START_TEXT:
    LD A, 'I'
    CALL PRINT_CHAR
    LD A, 'n'
    CALL PRINT_CHAR
    LD A, 'i'
    CALL PRINT_CHAR
    LD A, 'c'
    CALL PRINT_CHAR
    LD A, 'i'
    CALL PRINT_CHAR
    LD A, 'a'
    CALL PRINT_CHAR
    LD A, 'r'
    CALL PRINT_CHAR
    RET

; =======================================
; Subrutina: Generar 20 números pseudoaleatorios
; =======================================
GENERATE_NUMBERS:
    LD HL, RANDOM_AREA      ; Apuntar al área de memoria donde guardaremos los números
    LD B, 20                ; Generar 20 números
GENERATE_LOOP:
    CALL RANDOM_NUMBER      ; Llamar a la subrutina de números aleatorios
    LD (HL), A              ; Almacenar el número en la memoria
    INC HL                  ; Siguiente posición de memoria
    DJNZ GENERATE_LOOP      ; Repetir hasta que generemos 20 números
    RET

; =======================================
; Subrutina: Generar un número pseudoaleatorio
; (Un ejemplo simple de un generador basado en un desplazamiento de bits)
; =======================================
RANDOM_NUMBER:
    LD A, R                 ; Usar el registro 'R' como base (es un registro de refresco en Z80)
    RLCA                    ; Rotar el acumulador a la izquierda
    XOR 01101100B           ; Aplicar una operación XOR para generar variación
    RET

; =======================================
; Subrutina: Mostrar los números generados en pantalla
; =======================================
PRINT_NUMBERS:
    LD HL, RANDOM_AREA      ; Apuntar al área de memoria donde están los números
    LD B, 20                ; Imprimir 20 números
PRINT_LOOP:
    LD A, (HL)              ; Cargar el número actual
    CALL PRINT_NUMBER       ; Llamar a la subrutina para imprimirlo
    INC HL                  ; Apuntar al siguiente número
    DJNZ PRINT_LOOP         ; Repetir para los 20 números
    RET

; =======================================
; Subrutina: Mostrar los números ordenados en pantalla
; =======================================
PRINT_SORTED_NUMBERS:
    LD HL, SORTED_AREA      ; Apuntar al área de memoria donde están los números ordenados
    LD B, 20                ; Imprimir 20 números
PRINT_SORTED_LOOP:
    LD A, (HL)              ; Cargar el número actual
    CALL PRINT_NUMBER       ; Llamar a la subrutina para imprimirlo
    INC HL                  ; Apuntar al siguiente número
    DJNZ PRINT_SORTED_LOOP  ; Repetir para los 20 números
    RET

; =======================================
; Subrutina: Imprimir un número en decimal (0-255)
; =======================================
PRINT_NUMBER:
    CALL DIVIDE_BY_100      ; Dividir A por 100 (resultado en B, residuo en A)
    CALL PRINT_CHAR         ; Imprimir el dígito de las centenas
    CALL DIVIDE_BY_10       ; Dividir A por 10 (resultado en B, residuo en A)
    CALL PRINT_CHAR         ; Imprimir el dígito de las decenas
    ADD A, 48               ; Convertir a carácter ASCII el dígito de las unidades
    CALL PRINT_CHAR         ; Imprimir el dígito de las unidades
    RET

; =======================================
; Subrutina: Preguntar cómo ordenar los números
; =======================================
PRINT_SORT_TEXT:
    LD A, 'O'
    CALL PRINT_CHAR
    LD A, 'r'
    CALL PRINT_CHAR
    LD A, 'd'
    CALL PRINT_CHAR
    LD A, 'e'
    CALL PRINT_CHAR
    LD A, 'n'
    CALL PRINT_CHAR
    LD A, 'a'
    CALL PRINT_CHAR
    LD A, 'r'
    CALL PRINT_CHAR
    LD A, ' '
    CALL PRINT_CHAR
    LD A, 'A'
    CALL PRINT_CHAR
    LD A, '/'
    CALL PRINT_CHAR
    LD A, 'D'
    CALL PRINT_CHAR
    RET

; =======================================
; Subrutina: Ordenar los números de forma ascendente
; =======================================
SORT_NUMBERS_ASC:
    LD HL, RANDOM_AREA      ; Apuntar al inicio de los números
    LD DE, SORTED_AREA      ; Apuntar al área de memoria para los números ordenados
    CALL BUBBLE_SORT_ASC    ; Llamar al algoritmo de ordenación (burbuja)
    RET

; =======================================
; Subrutina: Ordenar los números de forma descendente
; =======================================
SORT_NUMBERS_DESC:
    LD HL, RANDOM_AREA      ; Apuntar al inicio de los números
    LD DE, SORTED_AREA      ; Apuntar al área de memoria para los números ordenados
    CALL BUBBLE_SORT_DESC   ; Llamar al algoritmo de ordenación (burbuja)
    RET

; =======================================
; Subrutina: Algoritmo de ordenación (Burbuja Ascendente)
; =======================================
BUBBLE_SORT_ASC:
    LD BC, 19               ; 20 elementos, por lo tanto hacer 19 pasadas
ASC_SORT_PASS:
    LD HL, SORTED_AREA      ; Apuntar al inicio del área de números
    LD D, 19                ; Comparar 19 pares
ASC_COMPARE:
    LD A, (HL)
    LD E, A                 ; Guardar el primer número en E
    INC HL
    LD A, (HL)              ; Cargar el segundo número
    CP E                    ; Comparar el segundo número con el primero
    JR NC, ASC_NEXT_PAIR    ; Si está en el orden correcto, saltar
    LD (HL), E              ; Si no, intercambiar
    DEC HL
    LD (HL), A
    INC HL
ASC_NEXT_PAIR:
    DEC D
    JR NZ, ASC_COMPARE      ; Continuar comparando pares
    DEC BC
    JP NZ, ASC_SORT_PASS    ; Hacer la siguiente pasada
    RET

; =======================================
; Subrutina: Algoritmo de ordenación (Burbuja Descendente)
; =======================================
BUBBLE_SORT_DESC:
    LD BC, 19               ; 20 elementos, por lo tanto hacer 19 pasadas
DESC_SORT_PASS:
    LD HL, SORTED_AREA      ; Apuntar al inicio del área de números
    LD D, 19                ; Comparar 19 pares
DESC_COMPARE:
    LD A, (HL)
    LD E, A                 ; Guardar el primer número en E
    INC HL
    LD A, (HL)              ; Cargar el segundo número
    CP E                    ; Comparar el segundo número con el primero
    JR C, DESC_NEXT_PAIR    ; Si está en el orden correcto, saltar
    LD (HL), E              ; Si no, intercambiar
    DEC HL
    LD (HL), A
    INC HL
DESC_NEXT_PAIR:
    DEC D
    JR NZ, DESC_COMPARE     ; Continuar comparando pares
    DEC BC
    JP NZ, DESC_SORT_PASS   ; Hacer la siguiente pasada
    RET

; =======================================
; Subrutinas auxiliares: Dividir por 100 y 10
; =======================================
DIVIDE_BY_100:
    LD B, 0                 ; Inicializar el cociente
DIV100_LOOP:
    CP 100
    JR C, DIV100_END
    SUB 100
    INC B
    JP DIV100_LOOP
DIV100_END:
    LD A, B
    ADD A, 48               ; Convertir a ASCII
    RET

DIVIDE_BY_10:
    LD B, 0                 ; Inicializar el cociente
DIV10_LOOP:
    CP 10
    JR C, DIV10_END
    SUB 10
    INC B
    JP DIV10_LOOP
DIV10_END:
    LD A, B
    ADD A, 48               ; Convertir a ASCII
    RET

; =======================================
; Subrutina: Leer entrada del usuario
; =======================================
READ_INPUT:
    IN A, (0x01)            ; Leer del puerto del teclado o un puerto PPI
    RET

; =======================================
; Subrutina: Imprimir un carácter en pantalla
; =======================================
PRINT_CHAR:
    OUT (0x02), A           ; Enviar el carácter al puerto de salida
    RET
; =======================================
; Subrutina: Preguntar si desea repetir o salir
; =======================================
PRINT_RETRY_TEXT:
    LD A, 'R'
    CALL PRINT_CHAR
    LD A, ':'
    CALL PRINT_CHAR
    LD A, ' '
    CALL PRINT_CHAR
    LD A, 'R'
    CALL PRINT_CHAR
    LD A, 'e'
    CALL PRINT_CHAR
    LD A, 'p'
    CALL PRINT_CHAR
    LD A, 'e'
    CALL PRINT_CHAR
    LD A, 't'
    CALL PRINT_CHAR
    LD A, 'i'
    CALL PRINT_CHAR
    LD A, 'r'
    CALL PRINT_CHAR
    LD A, ' '
    CALL PRINT_CHAR
    LD A, '/'
    CALL PRINT_CHAR
    LD A, ' '
    CALL PRINT_CHAR
    LD A, 'S'
    CALL PRINT_CHAR
    LD A, ':'
    CALL PRINT_CHAR
    LD A, ' '
    CALL PRINT_CHAR
    LD A, 'S'
    CALL PRINT_CHAR
    LD A, 'a'
    CALL PRINT_CHAR
    LD A, 'l'
    CALL PRINT_CHAR
    LD A, 'i'
    CALL PRINT_CHAR
    LD A, 'r'
    CALL PRINT_CHAR
    RET
; =======================================
; Subrutina: Mostrar texto de salida
; =======================================
PRINT_EXIT_TEXT:
    LD A, 'F'
    CALL PRINT_CHAR
    LD A, 'i'
    CALL PRINT_CHAR
    LD A, 'n'
    CALL PRINT_CHAR
    RET

; =======================================
; Área de datos
; =======================================
RANDOM_AREA:
    DS 20                  ; Espacio para 20 números aleatorios

SORTED_AREA:
    DS 20                  ; Espacio para los números ordenados

