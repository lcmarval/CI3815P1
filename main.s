# proyecto1 CI3815
# Autor: Luis Marval 12-10620
# Main
.data
Mem: 		.word 0  #Cantidad de memoria a reservar
dir: 		.word 0
dir2: 		.word 0
msgInit:	.asciiz "Introduzca la cantidad de bytes que usara"
.text
la $a0, msgInit #Cargamos el mensaje de solicitu de bytes
li $v0, 51     #$v0 = 51
syscall
jal init       #Llamada al metodo init del maneador
la $a0, ($v0)  #$a0 = ($v0)
sw $a0, Mem    #Mem = #a0
li $v0, 1      #$v0 = 1
syscall
li $a0, 1      #$a0 = 1
jal malloc     #Llamada al mallloc
sw $a1, dir    #dir = $a1
li $a0, 20     # $a0 = 20
jal malloc     #Llamada a malloc
sw $a1, dir2   #a1 = dir2
li $v0, 10     #$v0 = 10
syscall
.include "manejador.asm"
