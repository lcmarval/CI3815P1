# proyecto1 CI3815
# Autores: Luis Marval 12-10620
#          Juan Diego Porras 12-10566
# TAD manejador
.data
nMem:		.word 0
dir1:		.word 0   # primera direccion
dirDisp:	.word 0   # direccion a partir de la cual se puede usar
mensajeSalida: .asciiz "Ha salido del programa exitosamente"
saltoDeLinea: .asciiz "\n"
msgError1:	.asciiz "El numero ingresado de bytes es nulo o negativo"
msgError2:	.asciiz "Error en la reserva de la memoria dinamica"
msgError3:	.asciiz "El numero ingresado de bytes es nulo o negativo"
msgError4:	.asciiz "El espacio solicitado es mayor que el disponible inicialmente"
msgError5:	.asciiz "No hay suficiente espacio disponible para la reserva"
msgError6:	.asciiz "El numero ingresado de bytes es nulo o negativo"
msgError7:	.asciiz "La direccion ingresada no pertenece a la memoria"
msgError8:	.asciiz "la direccion es mayor que la direccion mas grande del arreglo"

.text
# funcion init($a0:size): --> $v0: dir Address, $v1: codigo error
#Pre: True. -- Planificacion de registros: $a0: memoria a reservar
# $v0: direccion de la inicializacion, $v1: codigo de error
# Post: se inicializa la memoria dinamica con capacidad de size bytes
init:		sw $fp, ($sp) 		#empilamos  $fp: Stack[0] = $fp
		sw $ra, -4($sp)		#empilamos $fp: Stack[4] = $ra
		addi $sp, $sp, -8 	#avanzamos dos posiciones en la pila
		blez $a0, initError1	# se verifica que el parametro no es menor igual que cero
		sw $a0, nMem 		#(nMem) = $a0
		li $v0, 9   		#Reservamos la memoria dinamica
		syscall
		bltz $v0, initError2	# si syscall 9 devuelve un numero negativo hubo un error al dar mem dinamica
		sw $v0, dir1  		#(dir1) = $v0 
		sw $v0, dirDisp 	#(dir1) = $v0 
		li $v0, 0 
		b initFin
initError1:	
		li $v0, -1 		#$v0 = -1
		b initFin  
initError2:	li $v0, -2 		#$v0 = -2		
initFin:	addi $sp, $sp, 8 	#retrocedemos dos posiciones en la pila
		lw $fp, ($sp) 		#$fp = ($sp)
		lw $ra, -4($sp) 	#$ra = Stack[4]
		jr $ra 
		
# funcion malloc($a0: size): --> $a1: dir primer elem bloque, $v0: codigo de error
# Pre: init se ejecuto satisfactoriamente
# Planificacion de Registros:
# $a0:size ; $a1: dir Address; $t0: cantidad de bytes de init; $t1 = $a0
# $t2: bytes restantes;  $t3: primera direccion de memoria - ultima dir mem;
# $t4: dir disponible para proxima llamada.
# Post: Se reservan size bytes de memoria
malloc:		sw $fp, ($sp)
		sw $ra, -4($sp) 	#$ra = Stack[4]
		addi $sp, $sp, -8 	#avanzamos dos espacios en la pila
		blez $a0, mallocError1  # se verifica que el parametro no es menor igual que cero
		lw $t0, nMem 		#$t0 = nMem
		add $t1, $a0, $zero	# t1 = a0(size)
		sub $t2, $t0, $t1	# t2 = nmem - size
		bltz $t2, mallocError2  # error se pide mas espacio del disponible inicialmente
		lw $t3, dir1		# $t3 = dir1
		add $t3, $t3, $t0	# se calcula la ultima direccion de memoria
		lw $a1, dirDisp         #$a1 = (dirDisp)
		add $t4, $a1, $t1	# ultima direccion de espacio reservado
		bgt $t4, $t3, mallocError3 # no hay suficiente espacio disponible
		sw $t4, dirDisp 	# (dirDisp) = $t4
		li $v0, 0
		b mallocFin
mallocError1:	li $v0, -3              #$v0 = -3
		b mallocFin
mallocError2:	li $v0, -4              #$v0 = -4
		b mallocFin
mallocError3:	li $v0, -5              #$v0 = -4
mallocFin:	addi $sp, $sp, 8
		lw $fp, ($sp)
		lw $ra, -4($sp)
		jr $ra

# funcion reallococ($a0: dir, $a1: size): --> $v0: codigo erros, $v1: direccion
# Pre: init se ejecuto satisfactoriamente
# Planificacion de Registros: $a0 direccion a reallocar , $a1 cantidad de bytes a reallocar, 
#$t0: valores de retorno, #$t1 dirDisp  dir , $t2 size
# Post: se modifico la memoria reservada (se incrementa o decrementa)
realloc:	sw $fp, ($sp)                   #($sp) = $fp
		sw $ra, -4($sp)                 #$Stack[4] = $ra
		addi $sp, $sp, -8		#avanzamos dos espacions en la pila
		blez $a1, reallocError1		# se verifica que el parametro no es menor igual que cero
		lw $t0, dirDisp	                # (disDisp) = $t0
		bgt $a0, $t0, reallocError2  	# se verifica que el parametro pertenece a la mem
		sub $t1, $t0, $a0		# $t1 = dirDisp - dir
		move $t2, $a1			# t2 = size
		bgt $a1, $t1, caso2		# si size > $t1 ir a caso 2
		sub $t0, $t0, $a1		# $t0= dirDisp - size
		sw $t0, dirDisp			#(dirDisp) = $t0
		move $v1, $a0			# $v1 = $a0
		li $v0, 0                       #$v0 = 0
		b reallocFin
caso2:		beqz $t2, finCaso2 		# loop para relocalizar los elementos
		lw $t1, ($a0)			# pasar el cont de dir a disDisp
		sw $t1, ($t0)                   #($t0) = $t1
		addi $a0, $a0, 4		# actualizar dirs
		addi $t0, $t0, 4                #$t0 = $t0 + 4
		addi $t2, $t2, -1               #$t2 = $t2 -1
		b caso2
finCaso2:	sw $t0, dirDisp			# cargar valores de retorno
		move $v1, $a0                   #$v1 = $a0
		li $v0, 0                       #$v0 = 0
		b reallocFin	
reallocError1:	li $v0, -6                      #$v0 = -6
		b reallocFin
reallocError2:	li $v0, -7                      #$v0 = -7		
reallocFin:	addi $sp, $sp, 8                #avanzamos dos poiciones en el stack
		lw $fp, ($sp)                   # $fp = ($sp)
		lw $ra, -4($sp)                 # $ra = Stack[4]
		jr $ra
		
# funcion free($a0: dir a liberar): -->  $v0: codigo error
# Pre: init se ejecuto satisfactoriamente
# Planificacion de Registros: $t0: contenido de dirDisp,
# Post:	
free:		sw $fp, ($sp)	                #$Stack[$sp] = ($fp}
		sw $ra, -4($sp)			#Stack[4] = $sra
		addi $sp, $sp, -8		#$sp = $sp + 8
		lw $t0, dirDisp			# dir <= dirDisp
		bgt $a0, $t0, freeError1 	# la direccion es mayor que la direccion mas grande del arreglo
		sw $a0, dirDisp			# (dirDisp) = $a0
		li $v0, 0			# $v0 = 0
		b freeFin
freeError1:	li $v0, -8                      # $v0 = -8			
freeFin:	addi $sp, $sp, 8	#$sp = $sp + 8
		lw $fp, ($sp)			#Stack[$sp] = $$fp
		lw $ra, -4($sp)			# Stack[4] = $ra
		jr $ra
						
# funcion pError($a0:int) --> void: Procedimiento que imprime un mensaje segun el entero pasado como parametro
#Planificaicon de registros: $a0 parametro 
perror: 	sw $fp, ($sp)  		   #Stack[$sp] = $fp
		sw $ra, -4($sp)            #Stack[4] = $ra
		addi $sp, $sp, -8          # $sp = $sp - 8
		beqz $a0, fin_perror 
		li $v0, 4                  #$v0 = 4
		add $a0,$v0,$zero	   #$a0 = $zero
		li $v0,4		   #$v0 = 4
		beq $a0,-1,buscarError1   #Si es error 1 busca el mensaje que lo describa 
		beq $a0,-2,buscarError2	  #Si es error 2 busca el mensaje que lo describa 
		beq $a0,-3,buscarError3   #Si es error 3 busca el mensaje que lo describa 
		beq $a0,-4,buscarError4   #Si es error 4 busca el mensaje que lo describa 
		beq $a0,-5,buscarError5   #Si es error 5 busca el mensaje que lo describa 
		beq $a0,-6,buscarError6   #Si es error 6 busca el mensaje que lo describa 
		beq $a0,-7,buscarError7   #Si es error 7 busca el mensaje que lo describa 
		beq $a0,-8,buscarError8   #Si es error 8 busca el mensaje que lo describa 
		
buscarError1:	la $a0,msgError1   	  #Carga en $a0 la direccion del mensaje del error 1
		syscall
		li $v0,4		   #$v0 = 4
		la $a0,saltoDeLinea  
		syscall
		b salidaPrograma
		
buscarError2:	la $a0,msgError2     #Carga en $a0 la direccion del mensaje del error  y lo imprime
		syscall
		li $v0,4             #$v0 =4
		la $a0,saltoDeLinea
		syscall
		b salidaPrograma
		
buscarError3:	la $a0,msgError3      #Carga en $a0 la direccion del mensaje del error 3 y lo imprime
		syscall
		li $v0,4		#$v0 = 4
		la $a0,saltoDeLinea
		syscall
		b salidaPrograma

buscarError4:	la $a0,msgError4       #Carga en $a0 la direccion del mensaje del error 4 y lo imprime
		syscall
		li $v0,4	       #$v0 = 4
		la $a0,saltoDeLinea
		syscall

		b salidaPrograma

buscarError5:	la $a0,msgError5        #Carga en $a0 la direccion del mensaje del error 5 y lo imprime	
		syscall
		j salidaPrograma

buscarError6:	la $a0,msgError6         #Carga en $a0 la direccion del mensaje del error 6 y lo imprime
		syscall

		li $v0,4		  #$v0 = 4
		la $a0,saltoDeLinea
		syscall

		b salidaPrograma

buscarError7:	la $a0,msgError7          #Carga en $a0 la direccion del mensaje del error 7 y lo imprime
		syscall
		
		li $v0,4		  #$v0 = 4
		la $a0,saltoDeLinea
		syscall

		b salidaPrograma

buscarError8:	la $a0,msgError8           #Carga en $a0 la direccion del mensaje del error 1 y lo imprime
		syscall

		li $v0,4		#$v0 = 4
		la $a0,saltoDeLinea
		syscall

		b salidaPrograma


salidaPrograma:	li $v0,4              #$Muestra un  mensaje de salida exitosa
  		la $a0,mensajeSalida
  		syscall
    	
  		li $v0,10	      # $v0 = 10
  		syscall
		
		
		
		
fin_perror:	addi $sp, $sp, 8 	    # $sp = $sp - 8
		lw $fp, ($sp)               #$fp = Stack[$sp]
		lw $ra, -4($sp)             #$ra = Stack[4] 
		jr $ra
