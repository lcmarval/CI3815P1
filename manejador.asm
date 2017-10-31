# proyecto1 CI3815
# Autor: Luis Marval 12-10620
# TAD manejador
.data
nMem:		.word 0
dir1:		.word 0   # primera direccion
dirDisp:	.word 0   # direccion a partir de la cual se puede usar
msgInit:	.asciiz "Introduzca la cantidad de bytes que usara"
errorLec:	.asciiz "Error al leer el tamaño del bloque"

.text
# funcion init:
# recibe como parametro $a0: size,
# $a1: StatusLec retorna 0 si fue exitoso, negativo en caso contrario
# retorna en $v0 la direccion del bloque de memoria 
# $v1 codigo (0: ok; -1: entrada incorrecta
# $a0 tiene la cantidad de bytes que se reservaron

fun_init:	sw $fp, ($sp)
		move $fp, $sp
		addi $sp, $sp, -4
		la $a0, msgInit # quizas esto no sea necesaria puede que siempre quiera pasar los parametros
		li $v0, 51
		syscall
		blez $a0, initError1  # se verifica que el parametro no es menor igual que cero
		sw $a0, nMem
		bltz $a1, initError2  # error en lectura
		li $v0, 9
		syscall
		sw $v0, dir1
		sw $v0, dirDisp
		li $v1, 0
		b initFin
initError1:	li $v1, -1
		b initFin
initError2:	li $v1, -2  # puede que no sea necesaria si lo es se puedecambia por cargar el valor de $a1
		b initFin
initFin:	#addi $sp, $sp, 4    Errores con la pila
		#lw $fp, ($sp)
		#move $sp, $fp
		jr $ra

# funcion malloc:
# Pre: init se ejecuto satisfactoriamente
# parametros: recibe el tamaño de los bytes a solicitar en $a0
# regresa la primera direccion del bloque en $a1
# se deberia verificar que el parametro no es negativo
fun_malloc:	sw $fp, ($sp)
		move $fp, $sp
		addi $sp, $sp, -4
		blez $a0, mallocError1  # se verifica que el parametro no es menor igual que cero
		lw $t0, nMem
		add $t1, $a0, $zero
		sub $t2, $t0, $t1
		bltz $t2, mallocError2  # error se pide mas espacio del disponible inicialmente
		lw $t3, dir1
		add $t3, $t3, $t0
		lw $a1, dirDisp
		add $t4, $a1, $t1
		bgt $t4, $t3, mallocError3 # no hay suficiente espacio disponible
		sw $t4, dirDisp
		b mallocFin
mallocError1:	li $v0, -3
		b mallocFin
mallocError2:	li $v0, -4  
		b mallocFin
mallocError3:	li $v0, -5  
		b mallocFin
mallocFin:	#addi $sp, $sp, 4    Errores con la pila
		#lw $fp, ($sp)
		#move $sp, $fp
		jr $ra

# funcion reallococ:
# Pre: init se ejecuto satisfactoriamente
# parametros: recibe la direccion dir en $a0
# recibe el tamaño de los bytes a solicitar en $a1
# se deberia verificar que el parametro no es negativo
fun_realloc:	sw $fp, ($sp)
		move $fp, $sp
		addi $sp, $sp, -4
		blez $a1, reallocError1  # se verifica que el parametro no es menor igual que cero
		lw $t0, nMem
		lw $t2, dir1
		add $t2, $t2, $t0
		bgt $a0, $t2, reallocError2  # se verifica que el parametro pertenece a la mem
		bgt $a1, $t0, caso2
		sub $t1, $t0, $a1
		sw $t1, nMem
		sw $a0, dirDisp
		b fin_realloc
caso2:		sub $t1, $a1, $t0   # diferencia de memorias
		move $a0, $t1  # ???
		li $v0, 9
		syscall	# se pide la cantidad extra de bits que se quiere
		add $v1, $a0, $t0  # calculo direccion de los nuevos bytes
		sw $a1, nMem
		b fin_realloc
reallocError1:	li $v0, -6
		b fin_realloc
reallocError2:	li $v0, -7  
		b fin_realloc		
fin_realloc:	#addi $sp, $sp, 4    Errores con la pila
		#lw $fp, ($sp)
		#move $sp, $fp
		jr $ra

# funcion free:
# Pre: init se ejecuto satisfactoriamente
# se deberia verificar que el parametro no es negativo
fun_free:	sw $fp, ($sp)
		move $fp, $sp
		addi $sp, $sp, -4
		#
		sw $a0, dirDisp
		#
		#addi $sp, $sp, 4    Errores con la pila
		#lw $fp, ($sp)
		#move $sp, $fp
		jr $ra
						
# funcion pError:	
fun_perror: 	sw $fp, ($sp)
		move $fp, $sp
		addi $sp, $sp, -4
		beqz $a0, fin_perror 
		la $a0, errorLec
		li $v0, 4
		syscall
fin_perror:	#addi $sp, $sp, 4    Errores con la pila
		#lw $fp, ($sp)
		#move $sp, $fp
		jr $ra
