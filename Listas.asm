# proyecto1 CI3815
# Autores: Luis Marval 12-10620
#          Juan Diego Porras 12-10566

# TAD Lista
.data
cabezaLista:	.word 0 # dir. Cabeza de lista

.text
# operacion create(): --> $a1: dir cabeza lista
# Pre: True
# Plainificacion de Registros: $a0: size, 
# Post: Crea una lista vacia de tamaño 4096 bits
create:		sw $fp, ($sp)   	#Stack[$sp] = $fp
		sw $ra, -4($sp)  	#Stack[$sp] = $ra
		addi $sp, $sp, -8 	#$sp = $sp + 8
		li $a0, 4096		#$a0 = 4096
		jal init		#Llamada a init
		move $a0, $v0
		jal perror		#Llamada a perror
		li $a0, 16		#$a0 = 16
		jal malloc		#Llamada a malloc
		move $a0, $v0		# $a0 = #$v0
		jal perror		#Llamada a perror
		sw $a1, ($a1)		#$(a1) = $a1
		sw $a1, cabezaLista	#(cabezaLista) = $a1
		sw $zero, 4($a1)	#$a1[4] = 0	
		sw $zero, 8($a1)	#$a1[8] = 
		sw $zero, 12($a1)	#$a1[8] = 
		addi $sp, $sp, 8	#$sp = $sp + 8
		lw $fp, ($sp)		#$fp = Stack[$sp]
		lw $ra, -4($sp)		#$ra = Stack[4]
		jr $ra

# operacion insert($a0: lista_ptr, $a1: elem_ptr): --> int
# pre:Las estructuras que componen la representación del TAD se encuentran inicializadas.
# Planificacion de registros: $a0: cabeza de la lista, $a1: entero, $t5: entero y $t6: direccion de la cabeza
#$t7 resultado del malloc,$t1: ultimo elemento, $t6: elemento del nodo: $t7:ultimo elemento de la lista,
#$t2: numero de elementos
# post: el elemento referido por elem_ptr forma parte de la lista y será colocado como 
#último elemento. El valor de size se incrementa en 1.
insert:		sw $fp, ($sp)			#Stack[$sp] = $fp
		sw $ra, -4($sp)			#Stack[4] = $fp
		addi $sp, $sp, -8		#$sp = $sp - 8
		lw $t0, cabezaLista		# $to = (cabezaLista)
		bne $a0, $t0, insertError1	# verificar que $a0 es la cabeza de la list
		bltz $a0, insertError2		# verificar que $a1 no sea negativo
		move $t5, $a0			# movemos estos registros para que malloc no los afecte
		move $t6, $a1			#$t6 = $a1
		li $a0, 8			# size a reservar es 8 bytes
		jal malloc			#Llamada a malloc
		move $t7, $a1		# guardamos el resultado de malloc
		move $a0, $v0			#$a0 = $v0
		jal perror		# imprimir posibles errores de malloc
		lw $t0, 4($t5) 		# primer elemento de la lista
		lw $t2, 12($t5) 	# revisar numero de elem
		beqz $t0, insertVacia 	# cuando la lista esta vacia
		lw $t1, 8($t5)		# revisar ultimo elemento
		sw $zero, ($t7) 	# se pone null como el .next del nodo
		sw $t7, ($t1)  		# se guarda el nodo como el .next de el ultimo elem
		sw $t6, 4($t7) 		# guardo direccion del elemento en el nodo
		sw $t7, 8($t5)		# el nodo se coloca como el ultimo de la lista
		addi $t2, $t2, 1 	# se agrega 1 al num de elementos
		sw $t2, 12($t5)		# se guarda el nuevo num de elementos en la cabecera
		li $v0, 0		# $v0 = 0
		b insertFin
insertVacia:	sw $zero, ($t7)		# guardamos null en el .next del nodo
		sw $t6, 4($t7)		# guardamos la direccion del elemento en el nodo
		sw $t7, 4($t5)		# se guarda el nodo como el primer elemento de la lista
		sw $t7, 8($t5)		# se guarda el nodo como el ultimo elemento de la lista
		li $t2, 1		# se incrementa el numero de elementos
		li $v0, 0
		b insertFin

insertError1:	li $v0, -1		#$v0 =-1
		b insertFin
insertError2:	li $v0, -2		#$v0 = -2

insertFin:	addi $sp, $sp, 8	#$sp = $sp + 8
		lw $fp, ($sp)		#$fp = Stack[$sp]
		lw $ra, -4($sp)		#$ra = Stack[$sp]
		jr $ra
		
# operacion delete($a0: lista_ptr, $a1: pos): --> $v0: codigo error, $v1: dir elem_ptr
# pre: Las estructuras que componen la representación del TAD se
#encuentran inicializadas. pos <= size. Los elementos de la lista están
#en las pocisiones [1...size]. No hay elemento en la posición 0.
# planificacion de registros: $a0: cabeza de la lista , $a1 la posicion, $t0 elementos de la lista, 
#$t3 tamaño que ocupa un nodo, $t4 contador, $t5 numero de desplazamientos, $t6: apuntador next del nodo $t7: apuntador al
#elemento del nodo, $t8 siguiente nodo, $t9 nodo siguiente al siguiente nodo
# post:
delete:		sw $fp, ($sp)    		#Stack[$sp] = $fp
		sw $ra, -4($sp)			# Stack[4] = $ra
		addi $sp, $sp, -8		# $sp = $sp + 8
		lw $t0, cabezaLista		# $t0 = (cabezaLista)
		bne $a0, $t0, deleteError1	# Verificar lista_ptr
		bltz $a1, deleteError2		# verificar pos (n>0)
		lw $t0, 12($a0)			# nElem
		blt $t0, $a1, deleteError2	# la posicion no pertece a la lista
		# calcular dir de pos
		lw $t2, 4($a0)			# primer elem lista
		sll $t3, $a1, 3			# pos*8 (tamaño que ocupa un nodo)
		add $t3, $t2, $t3		# direccion de la posicion
		lw $t2, 8($a0)			# ultimo elem lista
		beq $t2, $t3, deleteCaso1	# caso1 el elem a eliminar es el ultimo	
		#mover desde pos los siguientes elementos 1 pos atras y poner a pos de ultimo
		li $t4, 0			# contador
		sub $t5, $t0, $a1		# numero de desplazamientos
		addi $t5, $t5, -1		#$t5 = $t5 -1
		lw $t6, ($t3)			# aux1 = pos.next()
		lw $t7, 4($t3)			# aux2 = pos.elem()
deleteDesp:	beq $t5, $t4, deleteCaso1	# deplazo la pos a la ultima pos
		lw $t8, 8($t3)			# cargo cont. del prox nodo (.next)
		lw $t9, 12($t3)			# cargo cont. del prox nodo (.elem)
		sw $t8, ($t3)			# desp. el cont al nodo presente
		sw $t9, 4($t3)			# desp. el cont al nodo presente
		addi $t3, $t3, 8		#$t3 = $t3 + 8
		addi $t4, $t4, 1		#$t4 = $t4 + 1
		b deleteDesp
		sw $t6, ($t2)			#$t6 = $t2[0]
		sw $t7, 4($t2)			# $t7 = $t2[4]	
deleteCaso1:	lw $zero, -8($t2)	# .next de nuevo ultimo elem se hace null
		sw $v1, 4($t2)		# retornar elem_ptr
		addi $t0, $t0, -1	# restar 1 a nelem
		sw $t0, 12($a0)		# actualiza nElem
		move $a0, $t3		#$a0 = $t3
		jal free		# llamado a free
		move $a0, $v0		# $a0 = $v0
		jal perror		# llamado a perror
		li $v0, 0		# retornar 0
		b deleteFin
deleteError1:	li $v0, -3		#$v0 = -3
		b deleteFin
deleteError2:	li $v0, -4 		#$v0 = -4
deleteFin:	addi $sp, $sp, 8	# $sp = $sp + 8
		lw $fp, ($sp)		#$fp = Stack[$sp]
		lw $ra, -4($sp)		#$ra = Stack[4]
		jr $ra			
		
# operacion print($a0: lista_ptr, $a1: fun_print): --> void
# pre:Las estructuras que componen la representación del TAD se encuentran inicializadas.
# planificacion de registros: $t0: cabeza de lalista, $t1: primer elemento, $t3, contador,$t2 todos los elementos
# post: true
print:		sw $fp, ($sp)			#$Stack[$sp] = $fp
		sw $ra, -4($sp)			#Stack[4] = $ra
		addi $sp, $sp, -8		#$sp = $sp - 8
		lw $t0, cabezaLista		#$t0 = (cabeza de la lista)
		bne $a0, $t0, printError1	# Verificar lista_ptr
		lw $t1, 4($t0)			# cargo dir primer elem
		li $t3, 1			# contador
		lw $t4, 12($t0)			# nElem
printLoop:	beq $t3, $t4, printLoopF
		lw $t2, 4($t1)			# cargo elem
		sw $t1, ($sp)			#Stack[$sp] = $t1
		sw $t2, -4($sp)			#Stack[4] = $t2
		sw $t3, -8($sp)			#Stack[8] = $t3
		sw $t4, -12($sp)		#Stack[12] = $t4
		addi $sp, $sp, -16		# $sp = $sp - 16
		move $a0, $t2			# para pasar a print como parametro el elem
		jalr $a1			
		addi $sp, $sp, 16		#$sp = $sp + 16
		lw $t1, ($sp)			#$t1 = Stack[$sp]
		lw $t2, -4($sp)			#$t2 = Stack[4]
		lw $t3, -8($sp)			#$t3 = Stack[8]
		lw $t4, -12($sp)		#$t4 = Stack[12]
		addi $t3, $t3, 1		#$t3 = $t3 + 1
		addi $t1, $t1, 8		#$t1 = $t1 + 8
		b printLoop			
printError1:	li $v0, -5
printLoopF:	addi $sp, $sp, 8		#$sp = $sp + 8
		lw $fp, ($sp)			#$fp = Stack[$sp]
		lw $ra, -4($sp)			#$ra = Stack[4]
		jr $ra

.include "manejador.asm"
