.data

.text
	# Charger la valeur 0x00ff0000 pour couleur rouge
    	li t0 0x00ff0000
    	
    	# Charger l'adresse 0x10010000 dans t1 qui est l'adresse de d�part
	li t1 0x100400FC

	# Adresse de fin
	li t2 0x10050000
loop:
    	sw t0 (t1)

end:
	# Terminaison du programme
	li a7, 10
	ecall
