# proyecto1 CI3815
# Autor: Luis Marval 12-10620
# TAD manejador
.data
msgLec:		.asciiz "Introduzca la cantidad de bytes que usara"
msgTipoCarga:	.asciiz "Introducir 5=int  6=float  7=double 8=String"
errorLec:	.asciiz "Error al leer el tamaño del bloque"
# funciones:
# recibe como parametro $a0: mensajes, size, $a1: StatusLec $t0: dir Mem
init:	la $a0, msgLec
	li $v0, 51
	syscall
	bltz $a1, ImpError  # Capaz puede ser una funcion Verificar lectura
	li $v0, 9
	syscall
	add $t0, $v0, $zero
	# Cargar bloque por pantalla
loopC:	beqz $t0, finLoop
	la $a0, msgTipoCarga
	li $v0, 51
	syscall
	bltz $a1, ImpError
	add $v0, $a0, $zero	#lectura dependiendo del tipo de dato
	syscall
	# si el dato es String $t0 decrementa en 1 en caso contrario en 4
impError: la $a0, errorLec
	li $v0, 4
	syscall

fin:	li $v0, 10
	syscall