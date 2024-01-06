.data
nextl: .asciz "\n"

.text
li t0 0
li t1 1

li t3 105 # i
li t4 112 # p
li t5 111 # o


loop:
	li t6 0
	
	mv a0 t0
	li a7 1
	ecall
	
	# Passer ligne
	la a0 nextl
	li a7 4
	ecall
	
	
	# Attendre 500ms
	li a0 500
	li a7 32
	ecall

	lw t6, 0xffff0000
	lw t2, 0xffff0004
	
	beq t6, t1, suite
	
	j loop

suite:
	beq t2 t3 sub_one
	beq t2 t4 add_one
	beq t2 t5 end
	j loop

add_one:
	addi t0 t0 1
	j loop
sub_one:
	addi t0 t0 -1
	j loop
end:
	# Terminaison du programme
	li a7, 10
	ecall
