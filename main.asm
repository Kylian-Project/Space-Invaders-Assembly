.data
reserved_memory: .space 16384 # 64*64*4

# Definition des variables globales pour la taille de l'image et des units
unit_width:   .word 8    # Largeur d'un units en pixels
unit_height:  .word 8    # Hauteur d'un units en pixels

image_width:  .word 512   # Largeur de l'image en pixels
image_height: .word 512   # Hauteur de l'image en pixels

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


# Variables Joueur
Joueur_x: .word	26
Joueur_y: .word	59
Joueur_largeur: .word 12
Joueur_hauteur: .word 3
Joueur_couleur: .word 0x000000ff # Bleu


# Structure pour représenter un envahisseur
	env_x: .word 2   # Position en x de l'envahisseur
  	env_y: .word 4   # Position en y de l'envahisseur
  	env_etat: .word 0   # État de l'envahisseur (mort ou vivant)
# Variables envahisseurs
env_nb: .word 6
env_largeur: .word 4
env_hauteur: .word 2
env_couleur: .word 0x00ff0000 # Rouge
env_esp_horizontal: .word 2
env_decal_bord_touche: .word 2
env_dir: .word 0 # 0 gauche - droite & 1 droite gauche


# Structure pour représenter un obstacle
  	obstacle_x: .word 0    # Position en x de l'obstacle
  	obstacle_y: .word 51    # Position en y de l'obstacle
  	obstacle_etat: .word 0 # État de l'obstacle (détruit ou intact)
# Variables obstacles
obstacle_nb: .word 5
obstacle_largeur: .word 0 # J'ai choisi de la caulcer en fonction du nombre
obstacle_hauteur: .word 3
obstacle_couleur: .word 0x00ffff00 # jaune
obstacle_esp_horizontal: .word 0 # Je le calcul également en fonction du nombre d'obstacles


# Structure pour représenter un missile
  	missile_x: .word 32    # Position en x du missile
  	missile_y: .word -10   # Position en y du missile
  	missile_dir: .word 0    # Direction du missile (vers le haut ou le bas)
  	missile_etat: .word 1   # État du missile (détruit ou en vol)
# Variables missiles
missile_couleur: .word 0xffffffff
missile_longueur: .word 4
missile_epaisseur: .word 1
missile_nb_max: .word 0

# Var des adresse de mes struct
J_struct: .word 0
E_struct: .word 0
O_struct: .word 0
M_struct: .word 0


.text
main:
	
	jal I_creer # Allouer la memoire du buffer
	
	jal J_creer
	jal E_creer
	jal O_creer
	jal M_creer
	
	
	jal Update_screen
	
	#jal M_deplacer
	#jal J_deplacer
	#jal E_deplacer
	main_loop:
		jal E_deplacer
		jal J_deplacer
		jal M_deplacer
		
		j main_loop

end:
	# Terminaison du programme
	li a7, 10
	ecall




Update_screen:
	addi sp sp -4
	sw ra 0(sp)

	jal I_effacer
	
	jal J_afficher
	jal E_afficher
	jal O_afficher
	jal M_afficher
	
	jal I_buff_to_visu

	lw ra 0(sp)
	addi sp sp 4
	jr ra






E_deplacer:
	addi sp sp -4
	sw ra 0(sp)

	E_deplacer_loop:
		# Attendre 500ms
		#li a0 25
		#li a7 32
		#ecall
		
		la s11 E_struct
		lw s11 (s11)
	
		lw s1 0(s11) # x env
		lw s2 4(s11) # y env
		lw s3 8(s11) # env etat
		lw s4 12(s11) # env nb
		lw s5 16(s11) # env_largeur
		lw s6 20(s11) # env_hauteur
		lw s7 24(s11) # env_couleur
		lw s8 28(s11) # env_esp_horizontal
		lw s9 32(s11) # env_decal_bord_touche
		lw s10 36(s11) # env dir
		lw t3 I_largeur
		
		li t0 0
		beq s10 t0 e_droite_dir
		li t0 1
		beq s10 t0 e_gauche_dir
		
		e_droite_dir:
			# recup du x de la fin du dernier rectangle
			mul t0 s4 s5
			mul t1 s4 s8
			
			add t2 t0 t1
			add t2 s1 t2
			addi t2 t2 2 # marge pour que ce soit plus jolie
			
			bgt t2 t3 bord_touche
		
			addi s1 s1 1
			sw s1 0(s11)
			jal Update_screen
			#j E_deplacer_loop
			j E_deplacer_fin
		
		e_gauche_dir:
			li t0 4
			blt s1 t0 bord_touche
		
			addi s1 s1 -1
			sw s1 0(s11)
			jal Update_screen
			#j E_deplacer_loop
			j E_deplacer_fin
		
		bord_touche:
			li t0 0
			beq s10 t0 change_vers_gauche
			
			li t0 1
			beq s10 t0 change_vers_droite
			
			change_vers_gauche:
				li s10 1
				sw s10 36(s11)
				
				add s2 s2 s9
				sw s2 4(s11)
				
				jal Update_screen
				#j E_deplacer_loop
				j E_deplacer_fin
			change_vers_droite:
				li s10 0
				sw s10 36(s11)
				
				add s2 s2 s9
				sw s2 4(s11)
				
				jal Update_screen
				#j E_deplacer_loop
				j E_deplacer_fin
	
	E_deplacer_fin:
		lw ra 0(sp)
		addi sp sp 4
		jr ra





M_deplacer:
	addi sp sp -4
	sw ra 0(sp)
	
	#m_loop:
		la s11 M_struct
		lw s11 (s11)
	
		lw s1 0(s11) # x missile
		lw s2 4(s11) # y missile
		lw s3 8(s11) # direction missile
		lw s4 12(s11) # etat missile
		lw s5 16(s11) # couleur missile
		lw s6 20(s11) # longueur missile
		lw s7 24(s11) # epaisseur missile
		lw s8 28(s11) # nb max missile
		
		li s4 1
		sw s4 12(s11)
		
		lw t1 I_hauteur
		
		li t0 0
		beq s3 t0 m_haut
		li t0 1
		beq s3 t0 m_bas
		
		m_haut:
			add t0 s2 s6
			bltz t0 sortie_ecran
			
			addi s2 s2 -4
			sw s2 4(s11)
			
			jal Update_screen
			#j m_loop
			j fin_m_deplace
		m_bas:
			bgt s2 t1 sortie_ecran
			
			addi s2 s2 4
			sw s2 4(s11)
			jal Update_screen
			#j m_loop
			j fin_m_deplace
	sortie_ecran:
		li s4 0
		sw s4 12(s11)
		#j fin_m_deplace	
	fin_m_deplace:
		lw ra 0(sp)
		addi sp sp 4
		jr ra



J_deplacer:
	addi sp sp -4
	sw ra 0(sp)

	loop_deplacer:
		la s11 J_struct
		lw s11 (s11)
	
		lw s1 0(s11) # x joueur
		lw s2 4(s11) # y joueur
		lw s3 8(s11) # joueur largeur
		
	
		li t0 1 # stock verif si touche presse
	
		li a0 105 # i
		li a1 112 # p
		li a2 111 # o
		
		lw t1 0xffff0000
		lw t2 0xffff0004
		
		beq t1 t0 touche_detec
		#j loop_deplacer
		j fin_deplacer
	
	touche_detec:
		beq t2 a0 minus_one_x
		beq t2 a1 plus_one_x
		beq t2 a2 tir_missile
		#j loop_deplacer
		j fin_deplacer
	
	plus_one_x:
		lw t0 I_largeur
		lw t1 8(s11) # largeur joueur
		
		addi s1 s1 4
		add t2 s1 t1
		
		blt t2 t0 plus_one_x_suite
		addi s1 s1 -4
		#j loop_deplacer
		j fin_deplacer
		plus_one_x_suite:
			sw s1 0(s11)
			jal Update_screen
			#j loop_deplacer
			j fin_deplacer
	minus_one_x:
		addi s1 s1 -4
		bgtz s1 minus_one_x_suite
		addi s1 s1 4
		j loop_deplacer
		minus_one_x_suite:
			sw s1 0(s11)
			jal Update_screen
			#j loop_deplacer
			j fin_deplacer
	tir_missile:
		la s11 M_struct
		lw s11 (s11)
		lw s4 12(s11)
		
		mv a0 s4
		li a7 1
		ecall
		
		bgtz s4 fin_deplacer # test si missile déjà sur ecran
	
		lw t1 I_hauteur
		addi t1 t1 -7
	
		la s10 M_struct
		lw s10 (s10)
		
		
		add t0 s1 s3
		mv t3 s3
		srli t3 t3 1
		sub t0 t0 t3
		
		lw t4 24(s10)
		srli t4 t4 1
		sub t0 t0 t4
		
		sw t0 0(s10) # x missile
		
		sw t1 4(s10) # y missile
		jal Update_screen
		j fin_deplacer
		
	fin_deplacer:
		lw ra 0(sp)
		addi sp sp 4
		jr ra










# Fonction afficher joueur
J_afficher:
	addi sp sp -4
	sw ra 0(sp)

	la s11 J_struct
	lw s11 (s11)
	

	lw a0 0(s11) # x
	lw a1 4(s11) # y
	lw a2 8(s11)
	lw a3 12(s11)
	lw a4 16(s11)
	
	jal I_rectangle # Charger rectangle dans buffer
	#jal I_buff_to_visu # Mettre dans visu à partir du buffer
	
	lw ra 0(sp)
	addi sp sp 4
	jr ra







# Fonction afficher Envahisseurs 
E_afficher:
	addi sp sp -4
	sw ra 0(sp)

	la s11 E_struct
	lw s11 (s11)

	lw a0 0(s11) # env_x
	lw a1 4(s11) # env_y
	lw a2 16(s11) # env_largeur
	lw a3 20(s11) # env_hauteur
	lw a4 24(s11) # env_couleur
	lw a5 12(s11) # obstacle_nb
	lw s1 28(s11) #esp horizontal
	
	li a6 1 # compteur rectangle
	
	add s2 a2 s1 # ajouter l'esapce entre chaque Envahisseur
	
	loop_e_afficher:
		addi sp sp -36
	        sw a0 0(sp)
	        sw a1 4(sp)
	        sw a2 8(sp)
	        sw a3 12(sp)
	        sw a4 16(sp)
	        sw s2 20(sp)
	        sw a6 24(sp)
	        sw a5 28(sp)
	        sw ra 32(sp)
	        
		jal I_rectangle # Charger rectangle dans buffer
		#jal I_buff_to_visu # Mettre dans visu à partir du buffer
		
		lw a0 0(sp)
	        lw a1 4(sp)
	        lw a2 8(sp)
	        lw a3 12(sp)
	        lw a4 16(sp)
	        lw s2 20(sp)
	        lw a6 24(sp)
	        lw a5 28(sp)
	        lw ra 32(sp)
	        addi sp sp 36
	       	
	       	beq a5 a6 end_e_affiche
	       	addi a6 a6 1
	       	add a0 a0 s2
	       	
	       	j loop_e_afficher
	
	end_e_affiche:
		
		lw ra 0(sp)
		addi sp sp 4
		jr ra







# Fonction afficher Obstacle 
O_afficher:
	addi sp sp -4
	sw ra 0(sp)

	la s11 O_struct
	lw s11 (s11)

	lw a0 0(s11) # obstacle_x
	lw a1 4(s11) # obstacle_y
	lw a2 16(s11) # obstacle_largeur
	lw a3 20(s11) # obstacle_hauteur
	lw a4 24(s11) # obstacle couleur
	lw a5 12(s11) # obstacle_nb
	
	li a6 1 # compteur rectangle
	
	lw s1 I_largeur # largeur image en units
	div s2 s1 a5
	mv t2 s2
	srli t0 s2 1
	mv a2 t0
	
	# Définir start pour alignement
	addi t0 a5 -1
	
	mul t1 t2 t0
	add t1 t1 a2
	sub t1 s1 t1
	srli t1 t1 1

	mv a0 t1
	
	loop_o_afficher:
		addi sp sp -36
	        sw a0 0(sp)
	        sw a1 4(sp)
	        sw a2 8(sp)
	        sw a3 12(sp)
	        sw a4 16(sp)
	        sw s2 20(sp)
	        sw a6 24(sp)
	        sw a5 28(sp)
	        sw ra 32(sp)
	        
		jal I_rectangle # Charger rectangle dans buffer
		#jal I_buff_to_visu # Mettre dans visu à partir du buffer
		
		lw a0 0(sp)
	        lw a1 4(sp)
	        lw a2 8(sp)
	        lw a3 12(sp)
	        lw a4 16(sp)
	        lw s2 20(sp)
	        lw a6 24(sp)
	        lw a5 28(sp)
	        lw ra 32(sp)
	        addi sp sp 36
	       	
	       	beq a5 a6 end_o_affiche
	       	addi a6 a6 1
	       	add a0 a0 s2
	       	
	       	j loop_o_afficher
	
	end_o_affiche:
		
		lw ra 0(sp)
		addi sp sp 4
		jr ra





# Fonction afficher Missile
M_afficher:
	addi sp sp -4
	sw ra 0(sp)

	la s11 M_struct
	lw s11 (s11)
	

	lw a0 0(s11) # x du missile
	lw a1 4(s11) # y du misile
	lw a2 24(s11) # missile longueur
	lw a3 20(s11) # missile épaisseur
	lw a4 16(s11) # missile couleur
	lw a5 12(s11)
	
	li t0 1
	beq a5 t0 afiche_rect
	j M_afficher_end
	afiche_rect:
		jal I_rectangle # Charger rectangle dans buffer
		#jal I_buff_to_visu # Mettre dans visu à partir du buffer
	M_afficher_end:
	lw ra 0(sp)
	addi sp sp 4
	jr ra







# Fonction pour créer le joueur
J_creer:
	la t0 Joueur_x
	la t1 Joueur_y
	la t2 Joueur_largeur
	la t3 Joueur_hauteur
	la t4 Joueur_couleur

	li a0 20 # 5 paramettre pour joueur * 4
	li a7 9
	ecall
	
	la s11 J_struct
	sw a0 (s11)
	
	mv t5 a0 # Mettre adresse alloue dans t5
	
	# Mettre chaque valeur à l'adresse allouée
	lw a1 (t0) # Charger la valeur de Joueur_x
	sw a1 0(t5) # Stocker la valeur à l'adresse allouée
	
	lw a1 (t1) # Charger la valeur de Joueur_y
	sw a1 4(t5) # Stocker la valeur à l'adresse allouée + 4
	
	lw a1 (t2) # Charger la valeur de Joueur_largeur
	sw a1 8(t5) # Stocker la valeur à l'adresse allouée + 8
	
	lw a1 (t3) # Charger la valeur de Joueur_hauteur
	sw a1 12(t5) # Stocker la valeur à l'adresse allouée + 12
	
	lw a1 (t4) # Charger la valeur de Joueur_couleur
	sw a1 16(t5) # Stocker la valeur à l'adresse allouée + 16
	
	jr ra



E_creer:
	# Charger les adresses des variables globales des envahisseurs dans les registres t0 à t5
	la t0 env_x
	la t1 env_y
	la t2 env_etat
	la t3 env_nb
	la t4 env_largeur
	la t5 env_hauteur
	la s0 env_couleur
	la s1 env_esp_horizontal
	la s2 env_decal_bord_touche
	la s3 env_dir
	
	# Calculer l'espace mémoire nécessaire pour stocker les données des envahisseurs
	li a0 40 # 10 paramètres pour envahisseur * 4
	li a7 9
	ecall
	
	la s11 E_struct
	sw a0 (s11)
	
	mv t6 a0 # Stocker l'adresse allouée dans t6
	
	# Mettre chaque valeur à l'adresse allouée
	lw a1 (t0)
	sw a1 0(t6)
	
	lw a1 (t1)
	sw a1 4(t6)
	
	lw a1 (t2)
	sw a1 8(t6)
	
	lw a1 (t3)
	sw a1 12(t6)
	
	lw a1 (t4)
	sw a1 16(t6)
	
	lw a1 (t5)
	sw a1 20(t6)
	
	lw a1 (s0)
	sw a1 24(t6)
	
	lw a1 (s1)
	sw a1 28(t6)

	lw a1 (s2)
	sw a1 32(t6)
	
	lw a1 (s3)
	sw a1 36(t6)
	
	jr ra


	
	

O_creer:
	# Charger les adresses des variables globales des obstacles dans les registres t0 à t5
	la t0 obstacle_x
	la t1 obstacle_y
	la t2 obstacle_etat
	la t3 obstacle_nb
	la t4 obstacle_largeur
	la t5 obstacle_hauteur
	la s0 obstacle_couleur
	la s1 obstacle_esp_horizontal
	
	# Calculer l'espace mémoire nécessaire pour stocker les données des obstacles
	li a0 32 # 8 paramètres pour obstacle * 4
	li a7 9
	ecall
	
	la s11 O_struct
	sw a0 (s11)
	
	mv t6 a0 # Stocker l'adresse allouée dans t6
	
	# Mettre chaque valeur à l'adresse allouée
	lw a1 (t0)
	sw a1 0(t6)
	
	lw a1 (t1)
	sw a1 4(t6)
	
	lw a1 (t2)
	sw a1 8(t6)
	
	lw a1 (t3)
	sw a1 12(t6)
	
	lw a1 (t4)
	sw a1 16(t6)
	
	lw a1 (t5)
	sw a1 20(t6)
	
	lw a1 (s0)
	sw a1 24(t6)
	
	lw a1 (s1)
	sw a1 28(t6)
	
	jr ra






M_creer:
	# Charger les adresses des variables globales des envahisseurs dans les registres t0 à t5
	la t0 missile_x
	la t1 missile_y
	la t2 missile_dir
	la t3 missile_etat
	la t4 missile_couleur
	la t5 missile_longueur
	la s0 missile_epaisseur
	la s1 missile_nb_max
	
	# Calculer l'espace mémoire nécessaire pour stocker les données des envahisseurs
	li a0 32 # 9 paramètres pour envahisseur * 4
	li a7 9
	ecall
	
	la s11 M_struct
	sw a0 (s11)
	
	mv t6 a0 # Stocker l'adresse allouée dans t6
	
	# Mettre chaque valeur à l'adresse allouée
	lw a1 (t0)
	sw a1 0(t6)
	
	lw a1 (t1)
	sw a1 4(t6)
	
	lw a1 (t2)
	sw a1 8(t6)
	
	lw a1 (t3)
	sw a1 12(t6)
	
	lw a1 (t4)
	sw a1 16(t6)
	
	lw a1 (t5)
	sw a1 20(t6)
	
	lw a1 (s0)
	sw a1 24(t6)
	
	lw a1 (s1)
	sw a1 28(t6)
	
	jr ra




# adresse de base + 4*(x + lgr_ligne*y)
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
