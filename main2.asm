# proyecto1 CI3815
# Autor: Luis Marval 12-10620
# Main 2
.data
dirCabecera: .word 0
elem:		.word 77
.text
jal create
sw $a1, dirCabecera
lw $a0, dirCabecera
la $a1, elem
jal insert
move $v0, $a0
li $v0, 1
syscall
li $v0, 10
syscall
.include "listas.asm"
