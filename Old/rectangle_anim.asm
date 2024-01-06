.data
reserved_memory: .space 8192

# Definition des variables globales pour la taille de l'image et des units
unit_width:   .word 8    # Largeur d'un units en pixels
unit_height:  .word 8    # Hauteur d'un units en pixels

image_width:  .word 512   # Largeur de l'image en pixels
image_height: .word 256   # Hauteur de l'image en pixels

I_largeur: .word 0
I_hauteur: .word 0

I_visu: .word 0x10010000 # (Static)
I_buff: .word 0 # Adresse de l'allocation mémoire de image
I_buff_end: .word 0 # Adresse de fin de l'allocation mémoire de image (buffer)

# Var fonction rectangle
temp_largeur_rectangle: .word 0
temp_hauteur_rectangle: .word 0
temp_dif_x: .word 0
temp_dif_y: .word 0
temp_couleur: .word 0


.text
main:
	
	jal I_creer # Allouer la m�moire buffer
	
	li a0 0 # x du premier pixel du rectangle
	li a1 0 # y du premier pixel du rectangle
	
	li a2 5 # largeur du rectangle
	li a3 5 # hauteur du rectangle
	li a4 0x00ff0000 # couleur du rectangle
	jal anim
	
		

end:
	# Terminaison du programme
	li a7, 10
	ecall








I_xy_to_addr:
	lw a2 I_buff # adresse de départ de mémoire "image"
	
	lw t3 I_largeur
	
	mul a1 a1 t3
	add a0 a0 a1
	slli a0 a0 2
	
	add a0 a2 a0
	
	jr ra


I_addr_to_xy:
	lw t1 I_buff
	
	li a0 0x10040004
	
	lw t3 image_width
	srli t3 t3 1
	
	li t4 0 # x
	li t5 0 # y
	
	li t6 4
	
	sub a0 a0 t1 # Soustraction � adresse de depart pour r�cuperer la difference
	loop2:
		bge a0 t3 more_than_lg_ligne
		blt a0 t6 less_than_4
		
		addi t4 t4 1
		addi a0 a0 -4
		
		j loop2
	
	more_than_lg_ligne:
		addi t5 t5 1
		sub a0 a0 t3
		
		j loop2
	
	less_than_4:
		mv a0 t4 # a0 = x
		mv a1 t5 # a1 = y


I_creer:
	la a1 I_buff   # Charger l'adresse de I_buff dans a1
	la a2 I_buff_end # Charger l'adresse de I_buff_end dans a2

	f_I_largeur:
		lw s10 image_width
		lw s11 unit_width
		# ex : 512 / 8
		div s9 s10 s11
		# Largeur en Units dans registre s9
		la t0 I_largeur
		sw s9 (t0)
		
	f_I_hauteur:
		lw s10 image_height
		lw s11 unit_height
		# ex : 256 / 8
		div s8 s10 s11
		# Heuteur en Units dans registre s8
		la t1 I_hauteur
		sw s8 (t1)
	
	nb_bit_par_unit:
		lw s10 unit_width
		lw s11 unit_height
		# ex : 8 x 8
		mul s7 s10 s11

	# ex : (512 / 8) x (256 / 8) x 64
	mul s6 s8 s9
	mul s6 s6 s7
	
	mv a0 s6
	
	srli s6 s6 4 # Diviser le nombe de bits pour r�cup l'adresse de fin apr�s
	
	li a7 9 # instruction d'allocution mémoire en bits
	ecall
	
	sw a0 (a1) # Stocker le contenu de a0 à l'adresse de I_buff	
	
	add s6 s6 a0
	sw s6 (a2) # Stock l'adresse de fin
	
	jr ra
	



I_effacer:
	li t0 0x00000000 # Couleur noir
	
	lw t1 I_buff
	lw t2 I_buff_end
	
	loop_clear:
		sw t0 (t1)
		addi t1 t1 4
		
		beq t1 t2 fin_efface
		
		j loop_clear
	fin_efface:
		jr ra

I_rectangle:
	#li a0 0 # x du premier pixel du rectangle
	#li a1 0 # y du premier pixel du rectangle
	
	#li a2 10 # largeur du rectangle
	#li a3 10 # hauteur du rectangle
	#li a4 0x00ff0000 # couleur du rectangle
	
	addi sp sp -4
	sw ra 0(sp)
	
	
	la t4 temp_dif_x
	la t5 temp_dif_y
	
	add a5 a0 a2
	sw a5 (t4)
	
	add a5 a1 a3
	sw a5 (t5)
	
	mv t0 a0
	mv t1 a1
	
	la t2 temp_largeur_rectangle
	la t3 temp_hauteur_rectangle
	la t6 temp_couleur
	sw a2 (t2)
	sw a3 (t3)
	sw a4 (t6)
	
	loop_colone:
		lw t5 temp_dif_y
		beq a1 t5 fin_rectangle
		
	loop_ligne:
		mv a2 a4
		jal I_plot
		apres_i_plot:
			mv a0 t0
			mv a1 t1
			
			lw t2 temp_largeur_rectangle
			lw t3 temp_hauteur_rectangle
			lw t4 temp_dif_x
			lw t6 temp_couleur

			addi a0 a0 1
			mv t0 a0
			
			beq t0 t4 fin_ligne
			j loop_ligne
			
			fin_ligne:
				addi a1 a1 1
				mv t1 a1
				
				sub t5 t4 t2
				mv a0 t5
				
				mv t0 a0
				
				j loop_colone
	fin_rectangle:
		lw ra 0(sp)
		addi sp sp 4
		jr ra


I_plot:
	addi sp sp -4
	sw ra 0(sp)

	jal I_xy_to_addr
	
	suite_i_plot:
		lw a2 temp_couleur
		#li a2 0x00ff0000 # Couleur rouge test
		sw a2 (a0)
		
	lw ra 0(sp)
	addi sp sp 4
	jr ra



I_buff_to_visu:
	lw t0 I_visu   # Charger l'adresse de I_visu dans t0
	lw t1 I_buff   # Charger l'adresse de I_buff dans t1
	lw t2 I_buff_end   # Charger l'adresse de fin de I_buff dans t2
	
	loop_transfer:
        	lw t3 0(t1)  # Charger la donn�e depuis I_buff
        	sw t3 0(t0)  # Stocker la donn�e dans I_visu
        	addi t0 t0 4  # Avancer dans I_visu
        	addi t1 t1 4  # Avancer dans I_buff

		beq t1 t2 end_loop_transfer  # R�p�ter tant que nous n'avons pas atteint la fin de I_buff
		j loop_transfer
		
	end_loop_transfer:
		jr ra



anim:
	#li a0 0 # x du premier pixel du rectangle
	#li a1 0 # y du premier pixel du rectangle
	
	#li a2 5 # largeur du rectangle
	#li a3 5 # hauteur du rectangle
	#li a4 0x00ff0000 # couleur du rectangle
	
	addi sp sp -4
	sw ra 0(sp)
	
	loop_anim:		
		addi sp sp -24
		sw a0 0(sp)
		sw a1 4(sp)
		sw a2 8(sp)
		sw a3 12(sp)
		sw a4 16(sp)
		sw ra 20(sp)
		
		jal I_effacer
		
		jal I_rectangle
		jal I_buff_to_visu
		
		lw a0 0(sp)
		lw a1 4(sp)
		lw a2 8(sp)
		lw a3 12(sp)
		lw a4 16(sp)
		lw ra 20(sp)
		addi sp sp 24
		
		addi a0 a0 1
		
		li t0 50
		beq a0 t0 end
		
		j loop_anim
	
	lw ra 0(sp)
	addi sp sp 4
	jr ra
