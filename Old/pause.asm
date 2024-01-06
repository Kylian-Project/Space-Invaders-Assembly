.data
nextl: .asciz "\n"

.text
li t0 0
li t1 10

loop:
	addi t0 t0 1
	mv a0 t0
	li a7 1
	ecall
	
	# Passer ligne
	la a0 nextl
	li a7 4
	ecall
	
	# Si t0 == 10
	beq t0 t1 end
	
	# Attendre 500ms
	li a0 500
	li a7 32
	ecall
	
	# Boucle vers le d�but
    	j loop
end:
	# Terminaison du programme
	li a7, 10
	ecall
