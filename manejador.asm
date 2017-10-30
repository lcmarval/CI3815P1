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
# recibe como parametro $a0: size, $a1: StatusLec
# retorna 0 si fue exitoso, negativo en caso contrario en $a1
# retorna en $v0 la direccion del bloque de memoria y $a0 tiene la cantidad de bytes que se reservaron
fun_init:	sw $fp, ($sp)
		move $fp, $sp
		addi $sp, $sp, -4
		la $a0, msgInit
		li $v0, 51
		syscall
		# se deberia verificar que el parametro no es negativo
		sw $a0, nMem
		#bltz $a1, ImpError  
		li $v0, 9
		syscall
		sw $v0, dir1
		sw $v0, dirDisp
		#addi $sp, $sp, 4    Errores con la pila
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
		lw $t0, nMem
		add $t1, $a0, $zero
		sub $t2, $t0, $t1
		bltz $t2, error  # error se pide mas espacio del reservado inicialmente
		lw $t3, dir1
		add $t3, $t3, $t0
		lw $a1, dirDisp
		add $t4, $a1, $t1
		bgt $t4, $t3, error # no hay suficiente espacio disponible
		sw $t4, dirDisp
		#addi $sp, $sp, 4    Errores con la pila
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
		#
		lw $t0, nMem
		bgt $a1, $t0, caso2
		sub $t1, $t0, $a1
		sw $t1, nMem
		sw $a0, dirDisp
		b fin_realloc
caso2:		# syscall 9 
		# traspasar lo que estaba antes en mem al nuevo syscall 9
		
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
