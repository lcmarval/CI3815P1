# proyecto1 CI3815
# Autor: Luis Marval 12-10620
# TAD Lista
.data
cabezaLista:	.word 0 # dir. Cabeza de lista
		.word 0 # dir. primer nodo lista
		.word 0 # dir. ultimo nodo lista
		.word 0 # num elementos
		
msgTipoCarga:	.asciiz "Introducir 5=int  6=float  7=double 8=String"

.text
# operacion create(): Crea la lista vacia
op_create:	sw $fp, ($sp)
		move $fp, $sp
		addi $sp, $sp, -4
		li $a0, 20
		jal fun_init
		li $a0, 16
		jal fun_malloc
		sw $a1, cabezaLista
		#addi $sp, $sp, 4    Errores con la pila
		#lw $fp, ($sp)
		#move $sp, $fp
		jr $ra

# operacion insert():
op_insert:	sw $fp, ($sp)
		move $fp, $sp
		addi $sp, $sp, -4
		
		#addi $sp, $sp, 4    Errores con la pila
		#lw $fp, ($sp)
		#move $sp, $fp
		jr $ra
		
# operacion delete():
op_delete:	sw $fp, ($sp)
		move $fp, $sp
		addi $sp, $sp, -4
		
		#addi $sp, $sp, 4    Errores con la pila
		#lw $fp, ($sp)
		#move $sp, $fp
		jr $ra
		
# operacion print():
op_print:	sw $fp, ($sp)
		move $fp, $sp
		addi $sp, $sp, -4
		
		#addi $sp, $sp, 4    Errores con la pila
		#lw $fp, ($sp)
		#move $sp, $fp
		jr $ra
# lo siguiente puede servir para create o insert
# Cargar bloque por pantalla
loopC:	beqz $t0, finLoop
	la $a0, msgTipoCarga
	li $v0, 51
	syscall
	bltz $a1, ImpError
	add $v0, $a0, $zero	#lectura dependiendo del tipo de dato
	syscall
	# si el dato es String $t0 decrementa en 1 en caso contrario en 4
.include "manejador.asm"
