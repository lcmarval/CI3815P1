# proyecto1 CI3815
# Autor: Luis Marval 12-10620
# TAD Lista




msgTipoCarga:	.asciiz "Introducir 5=int  6=float  7=double 8=String"
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