# proyecto1 CI3815
# Autor: Luis Marval 12-10620
# Main
.data
Mem: .word 0
dir: .word 0
dir2: .word 0
.text
jal fun_init
la $a0, ($v0)
sw $a0, Mem
li $v0, 1
syscall
li $a0, 20
jal fun_malloc
sw $a1, dir
li $a0, 20
jal fun_malloc
sw $a1, dir2
li $v0, 10
syscall
.include "manejador.asm"
