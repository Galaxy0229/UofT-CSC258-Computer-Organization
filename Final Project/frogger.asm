#####################################################################
#
# CSC258H5S Fall 2021 Assembly Final Project
# University of Toronto, St. George
#
# Student: Chuanrun Zhang, 1006387562
#
# Bitmap Display Configuration:
# - Unit width in pixels: 8
# - Unit height in pixels: 8
# - Display width in pixels: 256
# - Display height in pixels: 256
# - Base Address for Display: 0x10008000 ($gp)
#
# Which milestone is reached in this submission?
# (See the assignment handout for descriptions of the milestones)
# - Milestone 1/2/3/4/5 (choose the one the applies)
#
# Which approved additional features have been implemented?
# (See the assignment handout for the list of additional features)
# 1. (fill in the feature, if any)
# 2. (fill in the feature, if any)
# 3. (fill in the feature, if any)
# ... (add more if necessary)


.data
	display_address: .word 0x10008000
	frog_position: .word 912
	frog_default_position: .word 912
	map_size: .word 32
	pixels_size: .word 1024	# 1 - 32

	delay_num: .word 50000

	frog_step: .word 2	# shift value 2 = times 4	

	land_color: .word 0x95A5A6
	frog_color: .word 0x1ABC9C
	river_color: .word 0x3498DB
	road_color: .word 0x7F8C8D
	home_wall_color: .word 0x34495E
	state_color: .word 0x2C3E50
	home_color: .word 0x27AE60

	state_anchor_point: .word 0
	home_wall_anchor_point: .word 128
	river1_anchor_point: .word 256
	river2_anchor_point: .word 384
	land1_anchor_point: .word 512
	road1_anchor_point: .word 640
	road2_anchor_point: .word 768
	land2_anchor_point: .word 896

	home1_position: .word 128
	home_wall1_position: 132
	home2_position: .word 136
	home_wall2_position: 140
	home3_position: .word 144
	home_wall3_position: 148
	home4_position: .word 152
	home_wall4_position: 156

	home1_enter: .word 0
	home2_enter: .word 0
	home3_enter: .word 0
	home4_enter: .word 0
	home_num: .word 4
	home_left: .word 4

	car11_position: .word 640
	car11_length: .word 1
	car11_length_default: .word 1
	car11_color: .word 0xF1C40F
	car12_position: .word 654
	car12_length: .word 1
	car12_length_default: .word 1
	car12_color: .word 0xF1C40F

	car21_position: .word 799
	car21_length: .word 1
	car21_length_default: .word 1
	car21_color: .word 0xE74C3C
	car22_position: .word 815
	car22_length: .word 1
	car22_length_default: .word 1
	car22_color: .word 0xE74C3C

	boat11_position: .word 256
	boat11_length: .word 2
	boat11_length_default: .word 2
	boat11_color: .word 0xE67E22

	boat12_position: .word 272
	boat12_length: .word 2
	boat12_length_default: .word 2
	boat12_color: .word 0xE67E22

	boat21_position: .word 415
	boat21_length: .word 2
	boat21_length_default: .word 2
	boat21_color: .word 0xD35400

	boat22_position: .word 431
	boat22_length: .word 2
	boat22_length_default: .word 2
	boat22_color: .word 0xD35400


	heart_color: .word 0xff0000
	lives: .word 3
	lives_default: .word 3

	light_color: .word 0xF1C40F

	speed_value: .word 1
	speed_value_default: .word 1

	car1x_speed: .word 1
	car1x_speed_threshold: .word 1
	car1x_speed_default: .word 1
	car2x_speed: .word 5
	car2x_speed_threshold: .word 5
	car2x_speed_default: .word 5
	boat1x_speed: .word 1
	boat1x_speed_threshold: .word 1
	boat1x_speed_default: .word 1
	boat2x_speed: .word 5
	boat2x_speed_threshold: .word 5
	boat2x_speed_default: .word 5

	level: .word 1


.text

# Speed Controller:
# la $t4, speed_value
# lw $t5, 0($t4)
# lw $t6, speed_value_default
# bne $t5, $zero, car_speed_skip_reset
# 	sw $t6, 0($t4)

# car_speed_skip_reset:
# la $t4, speed_value
# lw $t5, 0($t4)
# addi $t5, $t5, -1 
# sw $t5, 0($t4)


main:
########## MAIN ##########
init_game:
	# reset heart
	la $t2, lives
	lw $t4, lives_default
	sw $t4, 0($t2)

	# reset level
	la $t2, level
	li $t4, 1
	sw $t4, 0($t2)

	jal toggle_reset_home

respawn:
	# reset frog
	la $t2, frog_position
	lw $t4, frog_default_position
	sw $t4, 0($t2)

	jal dispaly_respown_animate

game_loop:
	# Logic
	jal frog_logic

	jal level_logic
	jal speedup_logic # prior than car boat

	# la $t4, speed_value
	# lw $t5, 0($t4)
	# lw $t6, speed_value_default
	# bne $t5, $zero, car_speed_skip_reset
	# 	sw $t6, 0($t4)
	jal car_logic
	jal boat_logic
	# car_speed_skip_reset:
	# la $t4, speed_value
	# lw $t5, 0($t4)
	# addi $t5, $t5, -1
	# sw $t5, 0($t4)

	jal collision_logic

	# Display
	jal bg_display
	jal car_display
	jal boat_display
	jal frog_display
	jal lives_display

	# Delay
	lw $t4, delay_num
	delay:
		addi $t4, $t4, -1
	bgtz $t4, delay

	j game_loop
Exit:
	li $v0, 10 # terminate the program gracefully
	syscall
####################



frog_logic:
	addi $sp, $sp, -4
	sw $ra, 0($sp)

	# check key input
	lw $t8, 0xffff0000
	beq $t8, 1, keyboard_input # if key is pressed, jump to get this key
	addi $t8, $zero, 0

	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra

	keyboard_input:
		addi $sp, $sp, -4
		sw $ra, 0($sp)

		lw $t2, 0xffff0004
		addi $v0, $zero, 0	# default case
		beq $t2, 0x61, respond_to_A
		beq $t2, 0x64, respond_to_D
		beq $t2, 0x77, respond_to_W
		beq $t2, 0x73, respond_to_S

		lw $ra, 0($sp)
		addi $sp, $sp, 4
		jr $ra

	respond_to_A:
		addi $sp, $sp, -4
		sw $ra, 0($sp)

		# frog move left
		la $t2, frog_position	# load position address
		lw $t3, 0($t2)			# load position

		# boundary check
		add $a0, $t3, $zero		# add parameters
		jal frog_left_boundary_check	# $v0: 1 true 0 false
			beq $zero, $v0, left_boundary_check_fail
				lw $t8, frog_step
				li $t4, -1				# direction
				sllv $t4, $t4, $t8
				add $t3, $t3, $t4		# change positon
			left_boundary_check_fail:
		sw $t3, 0($t2)			# save position

		lw $ra, 0($sp)
		addi $sp, $sp, 4

		frog_left_boundary_check:
			# param $a0: frog position
			addi $sp, $sp, -4
			sw $ra, 0($sp)

			li $v0, 1			# init return value true
			li $t7, 0			# initial left boundary check value

			li $t5, 0							# loop i
			lw $t6, map_size					# loop termination n
			left_boundary_check_loop:			# loop begin

				bne $t7, $a0, left_boundary_check_succ
					li $v0, 0		# return false
				left_boundary_check_succ:

			add $t7, $t7, $t6	# boundary check value increament

			addi $t5, $t5, 1					# loop increament
			bne $t5, $t6, left_boundary_check_loop	# loop check
			# left_boundary_check_loop_end:		# loop end

			# return #$v0: 1 true 0 false
			lw $ra, 0($sp)
			addi $sp, $sp, 4
			jr $ra

	respond_to_D:
		addi $sp, $sp, -4
		sw $ra, 0($sp)

		# frog move right
		la $t2, frog_position	# load position address
		lw $t3, 0($t2)			# load position

		# boundary check
		add $a0, $t3, $zero		# add parameters
		jal frog_right_boundary_check	# $v0: 1 true 0 false
			beq $zero, $v0, right_boundary_check_fail
				lw $t8, frog_step
				li $t4, 1				# direction
				sllv $t4, $t4, $t8
				add $t3, $t3, $t4		# change positon
			right_boundary_check_fail:
		sw $t3, 0($t2)			# save position

		lw $ra, 0($sp)
		addi $sp, $sp, 4
		jr $ra

		frog_right_boundary_check:
			# param $a0: frog position
			addi $sp, $sp, -4
			sw $ra, 0($sp)

			li $v0, 1			# init return value true
			li $t7, 28			# initial right boundary check value

			li $t5, 0							# loop i
			lw $t6, map_size					# loop termination n
			right_boundary_check_loop:			# loop begin

				bne $t7, $a0, right_boundary_check_succ
					li $v0, 0		# return false
				right_boundary_check_succ:

			add $t7, $t7, $t6	# boundary check value increament

			addi $t5, $t5, 1					# loop increament
			bne $t5, $t6, right_boundary_check_loop	# loop check
			# left_boundary_check_loop_end:		# loop end

			# return #$v0: 1 true 0 false
			lw $ra, 0($sp)
			addi $sp, $sp, 4
			jr $ra

	respond_to_W:
		addi $sp, $sp, -4
		sw $ra, 0($sp)

		# frog move up
		la $t2, frog_position	# load position address
		lw $t3, 0($t2)			# load position
		# boundary check
		add $a0, $t3, $zero		# add parameters
		jal frog_up_boundary_check	# $v0: 1 true 0 false
			beq $zero, $v0, up_boundary_check_fail
				lw $t8, frog_step
				li $t4, -32				# direction
				sllv $t4, $t4, $t8
				add $t3, $t3, $t4		# change positon
			up_boundary_check_fail:
		sw $t3, 0($t2)			# save position

		lw $ra, 0($sp)
		addi $sp, $sp, 4
		jr $ra

		frog_up_boundary_check:
			# param $a0: frog position
			addi $sp, $sp, -4
			sw $ra, 0($sp)

			li $v0, 1			# init return value true
			li $t7, 0			# initial top boundary check value

			li $t5, 0							# loop i
			lw $t6, map_size					# loop termination n
			up_boundary_check_loop:			# loop begin

				bne $t7, $a0, up_boundary_check_succ
					li $v0, 0		# return false
				up_boundary_check_succ:

			addi $t7, $t7, 1	# boundary check value increament

			addi $t5, $t5, 1					# loop increament
			bne $t5, $t6, up_boundary_check_loop	# loop check
			# left_boundary_check_loop_end:		# loop end

			# return #$v0: 1 true 0 false
			lw $ra, 0($sp)
			addi $sp, $sp, 4
			jr $ra

	respond_to_S:
		addi $sp, $sp, -4
		sw $ra, 0($sp)

		# frog move down
		la $t2, frog_position	# load position address
		lw $t3, 0($t2)			# load position
		# boundary check
		add $a0, $t3, $zero		# add parameters
		jal frog_down_boundary_check	# $v0: 1 true 0 false
			beq $zero, $v0, down_boundary_check_fail
				lw $t8, frog_step
				li $t4, 32				# direction
				sllv $t4, $t4, $t8
				add $t3, $t3, $t4		# change positon		# change positon
			down_boundary_check_fail:
		sw $t3, 0($t2)			# save position

		lw $ra, 0($sp)
		addi $sp, $sp, 4
		jr $ra

		frog_down_boundary_check:
			# param $a0: frog position
			addi $sp, $sp, -4
			sw $ra, 0($sp)

			li $v0, 1			# init return value true
			li $t7, 896			# initial top boundary check value

			li $t5, 0							# loop i
			lw $t6, map_size					# loop termination n
			down_boundary_check_loop:			# loop begin i:n-1

				bne $t7, $a0, down_boundary_check_succ
					li $v0, 0		# return false
				down_boundary_check_succ:

			addi $t7, $t7, 1	# boundary check value increament

			addi $t5, $t5, 1					# loop increament
			bne $t5, $t6, down_boundary_check_loop	# loop check
			# left_boundary_check_loop_end:		# loop end

			# return #$v0: 1 true 0 false
			lw $ra, 0($sp)
			addi $sp, $sp, 4
			jr $ra

level_logic:
	addi $sp, $sp, -4
	sw $ra, 0($sp)

		lw $t3, level
		li $t4, 2
		bne $t3, $t4, not_level_2
			# Level 2 params
			la $t2, car11_length
			lw $t3, 0($t2)
			lw $t5, car11_length_default
			sll $t3, $t5, 1
			sw $t3, 0($t2)

			la $t2, car12_length
			lw $t3, 0($t2)
			lw $t5, car12_length_default
			sll $t3, $t5, 1
			sw $t3, 0($t2)

			# sw $t3, 0($t2)
			# la $t2, car21_length
			# lw $t3, 0($t2)
			# lw $t5, car21_length_default
			# sll $t3, $t5, 1
			# sw $t3, 0($t2)

			# sw $t3, 0($t2)
			# la $t2, car22_length
			# lw $t3, 0($t2)
			# lw $t5, car22_length_default
			# sll $t3, $t5, 1
			# sw $t3, 0($t2)


			la $t2, boat11_length
			lw $t3, 0($t2)
			lw $t5, boat11_length_default
			srl $t3, $t5, 1
			sw $t3, 0($t2)

			la $t2, boat12_length
			lw $t3, 0($t2)
			lw $t5, boat12_length_default
			srl $t3, $t5, 1
			sw $t3, 0($t2)

			# sw $t3, 0($t2)
			# la $t2, boat21_length
			# lw $t3, 0($t2)
			# lw $t5, boat21_length_default
			# srl $t3, $t5, 1
			# sw $t3, 0($t2)

			# sw $t3, 0($t2)
			# la $t2, boat22_length
			# lw $t3, 0($t2)
			# lw $t5, boat22_length_default
			# srl $t3, $t5, 1
			# sw $t3, 0($t2)

			level_2_check:
				lw $t3, home_left
				bne $t3, $zero, not_level_up2
					j toggle_win
				not_level_up2:

		not_level_2:

		level_check:
			lw $t3, home_left
			bne $t3, $zero, not_level_up
				j toggle_go_level_2
			not_level_up:

	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra

speedup_logic:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
		# speed = home_left + speed_default + speed
		lw $t4, home_left

		la $t2, car1x_speed_threshold
		lw $t3, 0($t2)
		lw $t5, car1x_speed_default
		add $t3, $t5, $t4
		sw $t3, 0($t2)

		la $t2, car2x_speed_threshold
		lw $t3, 0($t2)
		lw $t5, car2x_speed_default
		add $t3, $t5, $t4
		sw $t3, 0($t2)

		la $t2, boat1x_speed_threshold
		lw $t3, 0($t2)
		lw $t5, boat1x_speed_default
		add $t3, $t5, $t4
		sw $t3, 0($t2)

		la $t2, boat2x_speed_threshold
		lw $t3, 0($t2)
		lw $t5, boat2x_speed_default
		add $t3, $t5, $t4
		sw $t3, 0($t2)

	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra


collision_logic:
	addi $sp, $sp, -4
	sw $ra, 0($sp)

		home_check:
			la $t2, frog_position	# load position address
			lw $t3, 0($t2)			# load position

			lw $t4, home1_position
			bne $t3, $t4, is_not_home1
				lw $t6, home1_enter
				bne $t6, $zero, home1_is_occupied
					la $t2, home1_enter
					li $t4, 1
					sw $t4, 0($t2)

					# home - 1
					la $t2, home_left
					lw $t3, 0($t2)
					addi $t3, $t3, -1
					sw $t3, 0($t2)

					j toggle_enter_home
				home1_is_occupied:
					j toggle_death
			is_not_home1:


			la $t2, frog_position	# load position address
			lw $t3, 0($t2)			# load position

			lw $t4, home2_position
			bne $t3, $t4, is_not_home2
				lw $t6, home2_enter
				bne $t6, $zero, home2_is_occupied
					la $t2, home2_enter
					li $t4, 1
					sw $t4, 0($t2)

					# home - 1
					la $t2, home_left
					lw $t3, 0($t2)
					addi $t3, $t3, -1
					sw $t3, 0($t2)

					j toggle_enter_home
				home2_is_occupied:
					j toggle_death
			is_not_home2:


			la $t2, frog_position	# load position address
			lw $t3, 0($t2)			# load position

			lw $t4, home3_position
			bne $t3, $t4, is_not_home3
				lw $t6, home3_enter
				bne $t6, $zero, home3_is_occupied
					la $t2, home3_enter
					li $t4, 1
					sw $t4, 0($t2)

					# home - 1
					la $t2, home_left
					lw $t3, 0($t2)
					addi $t3, $t3, -1
					sw $t3, 0($t2)

					j toggle_enter_home
				home3_is_occupied:
					j toggle_death
			is_not_home3:


			la $t2, frog_position	# load position address
			lw $t3, 0($t2)			# load position

			lw $t4, home4_position
			bne $t3, $t4, is_not_home4
				lw $t6, home4_enter
				bne $t6, $zero, home4_is_occupied
					la $t2, home4_enter
					li $t4, 1
					sw $t4, 0($t2)

					# home - 1
					la $t2, home_left
					lw $t3, 0($t2)
					addi $t3, $t3, -1
					sw $t3, 0($t2)

					j toggle_enter_home
				home4_is_occupied:
					j toggle_death
			is_not_home4:

		wall_check:
			lw $t4, home_wall1_position
			bne $t3, $t4, is_not_home1_wall
					j toggle_death
			is_not_home1_wall:

			lw $t4, home_wall2_position
			bne $t3, $t4, is_not_home2_wall
					j toggle_death
			is_not_home2_wall:

			lw $t4, home_wall3_position
			bne $t3, $t4, is_not_home3_wall
					j toggle_death
			is_not_home3_wall:

			lw $t4, home_wall4_position
			bne $t3, $t4, is_not_home4_wall
					j toggle_death
			is_not_home4_wall:

		car1_collide_check:
			li $t5, 0						# loop i
			lw $t6, car11_length				# loop termination 32
			sll $t6, $t6, 2					# loop termination 32 * 4
			car_collide1_loop:				# loop for car height
				# boundary check
				lw $t3, car11_position
				add $t3, $t3, $t5
				add $a0, $t3, $zero		# add parameters, $a0:current car1x position
				jal display_car1x_out_of_map_check	# $v0: 1 true 0 false
				beq $zero, $v0, car_collide_out_of_map_check_fail
					# is out of bound
					addi $t3, $t3, -32		# back to initial point
				car_collide_out_of_map_check_fail:

				add $a0, $zero, $t3 # car
				jal is_collision
				beq $v0, $zero, not_collided
					j toggle_death
				not_collided:

			addi $t5, $t5, 1				# loop increament
			bne $t5, $t6,car_collide1_loop	# loop check

		car12_collide_check:
			li $t5, 0						# loop i
			lw $t6, car12_length				# loop termination 32
			sll $t6, $t6, 2					# loop termination 32 * 4
			car12_collide_loop:				# loop for car height
				# boundary check
				lw $t3, car12_position
				add $t3, $t3, $t5
				add $a0, $t3, $zero		# add parameters, $a0:current car1x position
				jal display_car1x_out_of_map_check	# $v0: 1 true 0 false
				beq $zero, $v0, car12_collide_out_of_map_check_fail
					# is out of bound
					addi $t3, $t3, -32		# back to initial point
				car12_collide_out_of_map_check_fail:

				add $a0, $zero, $t3 # car
				jal is_collision
				beq $v0, $zero, not_collided12
					j toggle_death
				not_collided12:

			addi $t5, $t5, 1				# loop increament
			bne $t5, $t6,car12_collide_loop	# loop check

		car2_collide_check:
			li $t5, 0						# loop i
			lw $t6, car21_length				# loop termination 32
			sll $t6, $t6, 2					# loop termination 32 * 4
			car_collide1_loop2:				# loop for car height
				# boundary check
				lw $t3, car21_position
				add $t3, $t3, $t5
				add $a0, $t3, $zero		# add parameters, $a0:current car1x position
				jal display_car2x_out_of_map_check	# $v0: 1 true 0 false
				beq $zero, $v0, car_collide_out_of_map_check_fail2
					# is out of bound
					addi $t3, $t3, -32		# back to initial point
				car_collide_out_of_map_check_fail2:

				add $a0, $zero, $t3 # car
				jal is_collision
				beq $v0, $zero, not_collided2
					j toggle_death
				not_collided2:

			addi $t5, $t5, 1				# loop increament
			bne $t5, $t6,car_collide1_loop2	# loop check

		car22_collide_check:
			li $t5, 0						# loop i
			lw $t6, car22_length				# loop termination 32
			sll $t6, $t6, 2					# loop termination 32 * 4
			car_collide22_loop2:				# loop for car height
				# boundary check
				lw $t3, car22_position
				add $t3, $t3, $t5
				add $a0, $t3, $zero		# add parameters, $a0:current car1x position
				jal display_car2x_out_of_map_check	# $v0: 1 true 0 false
				beq $zero, $v0, car22_collide_out_of_map_check_fail2
					# is out of bound
					addi $t3, $t3, -32		# back to initial point
				car22_collide_out_of_map_check_fail2:

				add $a0, $zero, $t3 # car
				jal is_collision
				beq $v0, $zero, not_collided22
					j toggle_death
				not_collided22:

			addi $t5, $t5, 1				# loop increament
			bne $t5, $t6,car_collide22_loop2	# loop check



		boat_1x_collide_check:
			boat1_collide_check:
				jal frog_in_river1
				beq $v0, $zero, not_in_river1

					li $t4, 0		# Check value, 0 if value not collide with boat and frog

					# boat11
					li $t5, 0						# loop i
					lw $t6, boat11_length				# loop termination 32
					sll $t6, $t6, 2					# loop termination 32 * 4

					boat_collide1_loop1:				# loop for car height
						# boundary check
						lw $t3, boat11_position
						add $t3, $t3, $t5
						add $a0, $t3, $zero		# add parameters, $a0:current car1x position
						jal display_boat1x_out_of_map_check	# $v0: 1 true 0 false
						beq $zero, $v0,boat_collide_out_of_map_check_fail1
							# is out of bound
							addi $t3, $t3, -32		# back to initial point
						boat_collide_out_of_map_check_fail1:

						add $a0, $zero, $t3
						jal is_collision
						beq $v0, $zero, not_collided3
							li $t4, 1	# if collide
						not_collided3:

					addi $t5, $t5, 1				# loop increament
					bne $t5, $t6,boat_collide1_loop1	# loop check

					li $t5, 0						# loop i
					lw $t6, boat12_length				# loop termination 32
					sll $t6, $t6, 2					# loop termination 32 * 4

					# boat12
					boat_collide1_loop12:				# loop for car height
						# boundary check
						lw $t3, boat12_position
						add $t3, $t3, $t5
						add $a0, $t3, $zero		# add parameters, $a0:current car1x position
						jal display_boat1x_out_of_map_check	# $v0: 1 true 0 false
						beq $zero, $v0,boat_collide_out_of_map_check_fail12
							# is out of bound
							addi $t3, $t3, -32		# back to initial point
						boat_collide_out_of_map_check_fail12:

						add $a0, $zero, $t3 
						jal is_collision
						beq $v0, $zero, not_collided312
							li $t4, 1	# if collide
						not_collided312:

					addi $t5, $t5, 1				# loop increament
					bne $t5, $t6,boat_collide1_loop12	# loop check

					bne $t4, $zero, collide_with_boat1
						# if t4 =0 collide with river 
						j toggle_death
					collide_with_boat1:
				not_in_river1:



		boat2_collide_check:
			jal frog_in_river2
			beq $v0, $zero, not_in_river2

				li $t4, 0		# Check value, 0 if value not collide with boat and frog

				# boat 2`
				li $t5, 0						# loop i
				lw $t6, boat21_length				# loop termination 32
				sll $t6, $t6, 2					# loop termination 32 * 4
				boat_collide1_loop2:				# loop for car height
					# boundary check
					lw $t3, boat21_position
					add $t3, $t3, $t5
					add $a0, $t3, $zero		# add parameters, $a0:current car1x position
					jal display_boat2x_out_of_map_check	# $v0: 1 true 0 false
					beq $zero, $v0,boat_collide_out_of_map_check_fail2
						# is out of bound
						addi $t3, $t3, -32		# back to initial point
					boat_collide_out_of_map_check_fail2:

					add $a0, $zero, $t3
					jal is_collision
					beq $v0, $zero, not_collided4
						li $t4, 1	# if collide
					not_collided4:

				addi $t5, $t5, 1				# loop increament
				bne $t5, $t6,boat_collide1_loop2	# loop check

				# Boat 22
				li $t5, 0						# loop i
				lw $t6, boat22_length				# loop termination 32
				sll $t6, $t6, 2					# loop termination 32 * 4
				boat_collide1_loop22:				# loop for car height
					# boundary check
					lw $t3, boat22_position
					add $t3, $t3, $t5
					add $a0, $t3, $zero		# add parameters, $a0:current car1x position
					jal display_boat2x_out_of_map_check	# $v0: 1 true 0 false
					beq $zero, $v0,boat_collide_out_of_map_check_fail22
						# is out of bound
						addi $t3, $t3, -32		# back to initial point
					boat_collide_out_of_map_check_fail22:

					add $a0, $zero, $t3
					jal is_collision
					beq $v0, $zero, not_collided422
						li $t4, 1	# if collide
					not_collided422:

				addi $t5, $t5, 1				# loop increament
				bne $t5, $t6,boat_collide1_loop22	# loop check


				bne $t4, $zero, collide_with_boat2
					# collide with river
					j toggle_death
				collide_with_boat2:

			not_in_river2:


	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra

	is_collision:
	# $a0, position of object
		addi $sp, $sp, -4
		sw $ra, 0($sp)
			li $v0, 0			# init return value false

			la $t2, frog_position	# load position address
			lw $t3, 0($t2)			# load position
			bne $t3, $a0, is_collision_fail
				li $v0, 1		# return true
			is_collision_fail:

			# right collide of frog
			la $t2, frog_position	# load position address
			lw $t3, 0($t2)			# load position
			addi $t3, $t3, 4
			bne $t3, $a0, is_collision_fail2
				li $v0, 1		# return true
			is_collision_fail2:

		# return #$v0: 1 true 0 false
		lw $ra, 0($sp)
		addi $sp, $sp, 4
		jr $ra

	frog_in_river1:
		addi $sp, $sp, -4
		sw $ra, 0($sp)

			la $t2, frog_position	# load position address
			lw $t3, 0($t2)			# load position

			li $v0, 0			# init return value false
			li $t7, 256			# initial top boundary check value

			li $t5, 0							# loop i
			lw $t6, map_size					# loop termination n
			river1_check_loop:			# loop begin i:n-1

				bne $t7, $t3, river1_check_f
					li $v0, 1		# return true
				river1_check_f:

			addi $t7, $t7, 1	# boundary check value increament

			addi $t5, $t5, 1					# loop increament
			bne $t5, $t6, river1_check_loop	# loop check

		# return #$v0: 1 true 0 false
		lw $ra, 0($sp)
		addi $sp, $sp, 4
		jr $ra

	frog_in_river2:
		addi $sp, $sp, -4
		sw $ra, 0($sp)

			la $t2, frog_position	# load position address
			lw $t3, 0($t2)			# load position

			li $v0, 0			# init return value false
			li $t7, 384			# initial top boundary check value

			li $t5, 0							# loop i
			lw $t6, map_size					# loop termination n
			river2_check_loop:			# loop begin i:n-1

				bne $t7, $t3, river2_check_f
					li $v0, 1		# return true
				river2_check_f:

			addi $t7, $t7, 1	# boundary check value increament

			addi $t5, $t5, 1					# loop increament
			bne $t5, $t6, river2_check_loop	# loop check

		# return #$v0: 1 true 0 false
		lw $ra, 0($sp)
		addi $sp, $sp, 4
		jr $ra


car_logic:
	addi $sp, $sp, -4
	sw $ra, 0($sp)

		car_1x:
			la $t4, car1x_speed					# Speed Control
			lw $t5, 0($t4)
			lw $t6, car1x_speed_threshold
			bne $t5, $zero, car1x_speed_skip_reset
				sw $t6, 0($t4)					# Speed Control

				# car1
				la $t2, car11_position	# load position address
				lw $t3, 0($t2)			# load position
				# boundary check
				add $a0, $t3, $zero		# add parameters, $a0:current car1x position
				jal car1x_out_of_map_check	# $v0: 1 true 0 false
					bne $zero, $v0, car1x_out_of_map_check_pass
						addi $t3, $t3, -32		# back to initial point
					car1x_out_of_map_check_pass:
					addi $t3, $t3, 1			# change positon
				sw $t3, 0($t2)			# save position


				# car12
				la $t2, car12_position	# load position address
				lw $t3, 0($t2)			# load position
				# boundary check
				add $a0, $t3, $zero		# add parameters, $a0:current car1x position
				jal car1x_out_of_map_check	# $v0: 1 true 0 false
					bne $zero, $v0, car1x_out_of_map_check_pass12
						addi $t3, $t3, -32		# back to initial point
					car1x_out_of_map_check_pass12:
					addi $t3, $t3, 1			# change positon
				sw $t3, 0($t2)			# save position

			car1x_speed_skip_reset:				# Speed Control
				la $t4, car1x_speed
				lw $t5, 0($t4)
				addi $t5, $t5, -1
				sw $t5, 0($t4)						# Speed Control



		car_2x:
			la $t4, car2x_speed					# Speed Control
			lw $t5, 0($t4)
			lw $t6, car2x_speed_threshold
			bne $t5, $zero, car2x_speed_skip_reset
				sw $t6, 0($t4)					# Speed Control

				# car2
				la $t2, car21_position	# load position address
				lw $t3, 0($t2)			# load position
				# boundary check
				add $a0, $t3, $zero		# add parameters, $a0:current car1x position
				jal car2x_out_of_map_check	# $v0: 1 true 0 false
					bne $zero, $v0, car2x_out_of_map_check_pass
						addi $t3, $t3, 32		# back to initial point
					car2x_out_of_map_check_pass:
					addi $t3, $t3, -1			# change positon
				sw $t3, 0($t2)			# save position

				# car22
				la $t2, car22_position	# load position address
				lw $t3, 0($t2)			# load position
				# boundary check
				add $a0, $t3, $zero		# add parameters, $a0:current car1x position
				jal car2x_out_of_map_check	# $v0: 1 true 0 false
					bne $zero, $v0, car2x_out_of_map_check_pass22
						addi $t3, $t3, 32		# back to initial point
					car2x_out_of_map_check_pass22:
					addi $t3, $t3, -1			# change positon
				sw $t3, 0($t2)			# save position

			car2x_speed_skip_reset:				# Speed Control
				la $t4, car2x_speed
				lw $t5, 0($t4)
				addi $t5, $t5, -1
				sw $t5, 0($t4)						# Speed Control


	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra

	car1x_out_of_map_check:
		# param $a0: current car1x position
		addi $sp, $sp, -4
		sw $ra, 0($sp)

		li $v0, 1			# init return value true
		li $t7, 671			# out of bound
		bne $t7, $a0, car1x_out_of_map_succ
			li $v0, 0		# return false
		car1x_out_of_map_succ:

		# return #$v0: 1 true 0 false
		lw $ra, 0($sp)
		addi $sp, $sp, 4
		jr $ra

	car2x_out_of_map_check:
		# param $a0: current car1x position
		addi $sp, $sp, -4
		sw $ra, 0($sp)

		li $v0, 1			# init return value true
		li $t7, 768			# out of bound
		bne $t7, $a0, car2x_out_of_map_succ
			li $v0, 0		# return false
		car2x_out_of_map_succ:

		# return #$v0: 1 true 0 false
		lw $ra, 0($sp)
		addi $sp, $sp, 4
		jr $ra

boat_logic:
	addi $sp, $sp, -4
	sw $ra, 0($sp)

		boat_1x:
			la $t4, boat1x_speed					# Speed Control
			lw $t5, 0($t4)
			lw $t6, boat1x_speed_threshold
			bne $t5, $zero, boat1x_speed_skip_reset
				sw $t6, 0($t4)					# Speed Control

				# boat1
				la $t2, boat11_position	# load position address
				lw $t3, 0($t2)			# load position
				# boundary check
				add $a0, $t3, $zero		# add parameters, $a0:current boat1x position
				jal boat1x_out_of_map_check	# $v0: 1 true 0 false
					bne $zero, $v0, boat1x_out_of_map_check_pass
						addi $t3, $t3, -32		# back to initial point
					boat1x_out_of_map_check_pass:
					addi $t3, $t3, 1			# change positon
				sw $t3, 0($t2)			# save position

				# boat12
				la $t2, boat12_position	# load position address
				lw $t3, 0($t2)			# load position
				# boundary check
				add $a0, $t3, $zero		# add parameters, $a0:current boat1x position
				jal boat1x_out_of_map_check	# $v0: 1 true 0 false
					bne $zero, $v0, boat1x_out_of_map_check_pass12
						addi $t3, $t3, -32		# back to initial point
					boat1x_out_of_map_check_pass12:
					addi $t3, $t3, 1			# change positon
				sw $t3, 0($t2)			# save position

			boat1x_speed_skip_reset:				# Speed Control
					la $t4, boat1x_speed
					lw $t5, 0($t4)
					addi $t5, $t5, -1
					sw $t5, 0($t4)						# Speed Control


		boat_2x:
			la $t4, boat2x_speed					# Speed Control
			lw $t5, 0($t4)
			lw $t6, boat2x_speed_threshold
			bne $t5, $zero, boat2x_speed_skip_reset
				sw $t6, 0($t4)					# Speed Control

				# boat2
				la $t2, boat21_position	# load position address
				lw $t3, 0($t2)			# load position
				# boundary check
				add $a0, $t3, $zero		# add parameters, $a0:current boat1x position
				jal boat2x_out_of_map_check	# $v0: 1 true 0 false
					bne $zero, $v0, boat2x_out_of_map_check_pass
						addi $t3, $t3, 32		# back to initial point
					boat2x_out_of_map_check_pass:
					addi $t3, $t3, -1			# change positon
				sw $t3, 0($t2)			# save position

				# boat22
				la $t2, boat22_position	# load position address
				lw $t3, 0($t2)			# load position
				# boundary check
				add $a0, $t3, $zero		# add parameters, $a0:current boat1x position
				jal boat2x_out_of_map_check	# $v0: 1 true 0 false
					bne $zero, $v0, boat2x_out_of_map_check_pass22
						addi $t3, $t3, 32		# back to initial point
					boat2x_out_of_map_check_pass22:
					addi $t3, $t3, -1			# change positon
				sw $t3, 0($t2)			# save position

			boat2x_speed_skip_reset:				# Speed Control
				la $t4, boat2x_speed
				lw $t5, 0($t4)
				addi $t5, $t5, -1
				sw $t5, 0($t4)						# Speed Control

	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra

	boat1x_out_of_map_check:
		# param $a0: current boat1x position
		addi $sp, $sp, -4
		sw $ra, 0($sp)

		li $v0, 1			# init return value true
		li $t7, 287			# out of bound
		bne $t7, $a0, boat1x_out_of_map_succ
			li $v0, 0		# return false
		boat1x_out_of_map_succ:

		# return #$v0: 1 true 0 false
		lw $ra, 0($sp)
		addi $sp, $sp, 4
		jr $ra

	boat2x_out_of_map_check:
		# param $a0: current boat1x position
		addi $sp, $sp, -4
		sw $ra, 0($sp)

		li $v0, 1			# init return value true
		li $t7, 384			# out of bound
		bne $t7, $a0, boat2x_out_of_map_succ
			li $v0, 0		# return false
		boat2x_out_of_map_succ:

		# return #$v0: 1 true 0 false
		lw $ra, 0($sp)
		addi $sp, $sp, 4
		jr $ra

toggle_enter_home:
	j toggle_respawn


toggle_death:
	addi $sp, $sp, -4
	sw $ra, 0($sp)

		jal dispaly_death_animate

		# decrease lives
		la $t2, lives			# load  address
		lw $t3, 0($t2)			# load 
		addi $t3, $t3, -1
		sw $t3, 0($t2)			# save position

		# check gameovernd
		bne $t3, $zero, not_game_over
			j toggle_gameover
		not_game_over:
		j toggle_respawn

	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra

toggle_reset_home:
	addi $sp, $sp, -4
	sw $ra, 0($sp)

		la $t2, home1_enter
		li $t4, 0
		sw $t4, 0($t2)

		la $t2, home2_enter
		li $t4, 0
		sw $t4, 0($t2)

		la $t2, home3_enter
		li $t4, 0
		sw $t4, 0($t2)

		la $t2, home4_enter
		li $t4, 0
		sw $t4, 0($t2)

		la $t2, home_left
		li $t4, 4
		sw $t4, 0($t2)

	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra

toggle_go_level_2:
	# level change 
	la $t2, level
	li $t4, 2
	sw $t4, 0($t2)

	jal toggle_reset_home

	j toggle_respawn

toggle_restart:
	j init_game

toggle_gameover:
	jal dispaly_gameover
	end_loop:
		# check key input
		lw $t8, 0xffff0000
		beq $t8, 1, keyboard_input_end # if key is pressed, jump to get this key
		addi $t8, $zero, 0
	j end_loop

	keyboard_input_end:
			addi $sp, $sp, -4
			sw $ra, 0($sp)

			lw $t2, 0xffff0004
			addi $v0, $zero, 0	# default case
			beq $t2, 0x72, respond_to_R
			beq $t2, 0x71, respond_to_Q

			lw $ra, 0($sp)
			addi $sp, $sp, 4
			jr $ra
	respond_to_R:
		j toggle_restart
	respond_to_Q:
		j Exit

toggle_respawn:
	j respawn

toggle_win:
	jal dispaly_win
	j Exit

frog_display:
	addi $sp, $sp, -4
	sw $ra, 0($sp)

	paint_frog:
		li $a0, 0
		jal paint_frog_by_pixel
		li $a0, 3
		jal paint_frog_by_pixel
		li $a0, 32
		jal paint_frog_by_pixel
		li $a0, 33
		jal paint_frog_by_pixel
		li $a0, 34
		jal paint_frog_by_pixel
		li $a0, 35
		jal paint_frog_by_pixel
		li $a0, 65
		jal paint_frog_by_pixel
		li $a0, 66
		jal paint_frog_by_pixel
		li $a0, 96
		jal paint_frog_by_pixel
		li $a0, 97
		jal paint_frog_by_pixel
		li $a0, 98
		jal paint_frog_by_pixel
		li $a0, 99
		jal paint_frog_by_pixel

	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra

	paint_frog_by_pixel:
		# param $a0: paint pixel offset
		addi $sp, $sp, -4
		sw $ra, 0($sp)

			lw $t0, display_address	# load display_address
			lw $t1, frog_color				# load color
			la $t2, frog_position	# load position address

			lw $t3, 0($t2)			# load position
			add $t3, $t3, $a0				# change position
			sll $t3,$t3, 2			# convert pos to address
			add $t0, $t0, $t3		# add pos to address
			sw $t1, 0($t0)			# color on address

		lw $ra, 0($sp)
		addi $sp, $sp, 4
		jr $ra


bg_display:
	addi $sp, $sp, -4
	sw $ra, 0($sp)

		li $t5, 0						# loop i
		lw $t6, map_size				# loop termination 32
		sll $t6, $t6, 2					# loop termination 32 * 4
		bg_display_loop:				# loop begin i:n-1
			### All BG ###

			lw $a0, state_anchor_point
			add $a1, $zero, $t5
			lw $a2, state_color
			jal paint_pixel_by_offset

			lw $a0, river1_anchor_point
			add $a1, $zero, $t5
			lw $a2, river_color
			jal paint_pixel_by_offset

			lw $a0, river2_anchor_point
			add $a1, $zero, $t5
			lw $a2, river_color
			jal paint_pixel_by_offset

			lw $a0, land1_anchor_point
			add $a1, $zero, $t5
			lw $a2, land_color
			jal paint_pixel_by_offset

			lw $a0, road1_anchor_point
			add $a1, $zero, $t5
			lw $a2, road_color
			jal paint_pixel_by_offset

			lw $a0, road2_anchor_point
			add $a1, $zero, $t5
			lw $a2, road_color
			jal paint_pixel_by_offset

			lw $a0, land2_anchor_point
			add $a1, $zero, $t5
			lw $a2, land_color
			jal paint_pixel_by_offset


		addi $t5, $t5, 1				# loop increament
		bne $t5, $t6, bg_display_loop	# loop check

		lw $a0, home_wall1_position
		lw $a1, home_wall_color
		jal paint_block

		lw $a0, home1_position
		lw $t3, home1_enter
		beq $t3, $zero, home1_enter_false
			lw $a1, home_wall_color
			jal paint_block
		j home1_enter_end
		home1_enter_false:
			lw $a1, home_color
			jal paint_block
		home1_enter_end:

		lw $a0, home_wall2_position
		lw $a1, home_wall_color
		jal paint_block

		lw $a0, home2_position
		lw $t3, home2_enter
		beq $t3, $zero, home2_enter_false
			lw $a1, home_wall_color
			jal paint_block
		j home2_enter_end
		home2_enter_false:
			lw $a1, home_color
			jal paint_block
		home2_enter_end:

		lw $a0, home_wall3_position
		lw $a1, home_wall_color
		jal paint_block

		lw $a0, home3_position
		lw $t3, home3_enter
		beq $t3, $zero, home3_enter_false
			lw $a1, home_wall_color
			jal paint_block
		j home3_enter_end
		home3_enter_false:
			lw $a1, home_color
			jal paint_block
		home3_enter_end:

		lw $a0, home_wall4_position
		lw $a1, home_wall_color
		jal paint_block

		lw $a0, home4_position
		lw $t3, home4_enter
		beq $t3, $zero, home4_enter_false
			lw $a1, home_wall_color
			jal paint_block
		j home4_enter_end
		home4_enter_false:
			lw $a1, home_color
			jal paint_block
		home4_enter_end:

	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra


car_display:
	addi $sp, $sp, -4
	sw $ra, 0($sp)

	paint_car1:
		li $t5, 0						# loop i
		lw $t6, car11_length				# loop termination 32
		sll $t6, $t6, 2					# loop termination 32 * 4
		paint_car1_loop:				# loop for car height

			li $t8, 0
			li $t9, 4
			paint_car1_loop2:	# Loop to print car width
				# boundary check
				lw $t3, car11_position
				add $t3, $t3, $t5
				add $a0, $t3, $zero		# add parameters, $a0:current car1x position
				jal display_car1x_out_of_map_check	# $v0: 1 true 0 false
				beq $zero, $v0, car1x_out_of_map_check_fail
					# is out of bound
					addi $t3, $t3, -32		# back to initial point
				car1x_out_of_map_check_fail:

				add $a0, $t3, $zero

				sll $a1, $t8, 5
				lw $a2, car11_color
				jal paint_pixel_by_offset

			addi $t8, $t8, 1
			bne $t9, $t8, paint_car1_loop2

		addi $t5, $t5, 1				# loop increament
		bne $t5, $t6, paint_car1_loop	# loop check

	paint_car12:
		li $t5, 0						# loop i
		lw $t6, car12_length				# loop termination 32
		sll $t6, $t6, 2					# loop termination 32 * 4
		paint_car12_loop:				# loop for car height

			li $t8, 0
			li $t9, 4
			paint_car12_loop2:	# Loop to print car width
				# boundary check
				lw $t3, car12_position
				add $t3, $t3, $t5
				add $a0, $t3, $zero		# add parameters, $a0:current car1x position
				jal display_car1x_out_of_map_check	# $v0: 1 true 0 false
				beq $zero, $v0, car1x_out_of_map_check_fail12
					# is out of bound
					addi $t3, $t3, -32		# back to initial point
				car1x_out_of_map_check_fail12:

				add $a0, $t3, $zero

				sll $a1, $t8, 5
				lw $a2, car12_color
				jal paint_pixel_by_offset

			addi $t8, $t8, 1
			bne $t9, $t8, paint_car12_loop2

		addi $t5, $t5, 1				# loop increament
		bne $t5, $t6, paint_car12_loop	# loop check


	paint_car2:
		li $t5, 0						# loop i
		lw $t6, car21_length				# loop termination 32
		sll $t6, $t6, 2					# loop termination 32 * 4
		paint_car2_loop:				# loop begin i:n-1

			li $t8, 0
			li $t9, 4
			paint_car2_loop2:	# Loop to print car width
				# boundary check
				lw $t3, car21_position
				add $t3, $t3, $t5
				add $a0, $t3, $zero		# add parameters, $a0:current car1x position
				jal display_car2x_out_of_map_check	# $v0: 1 true 0 false
				beq $zero, $v0, car2x_out_of_map_check_fail
					# is out of bound
					addi $t3, $t3, -32		# back to initial point
				car2x_out_of_map_check_fail:

				add $a0, $t3, $zero
				sll $a1, $t8, 5
				lw $a2, car21_color
				jal paint_pixel_by_offset

			addi $t8, $t8, 1
			bne $t9, $t8, paint_car2_loop2


		addi $t5, $t5, 1				# loop increament
		bne $t5, $t6, paint_car2_loop	# loop check

	
	paint_car22:
		li $t5, 0						# loop i
		lw $t6, car22_length				# loop termination 32
		sll $t6, $t6, 2					# loop termination 32 * 4
		paint_car22_loop:				# loop begin i:n-1

			li $t8, 0
			li $t9, 4
			paint_car22_loop2:	# Loop to print car width
				# boundary check
				lw $t3, car22_position
				add $t3, $t3, $t5
				add $a0, $t3, $zero		# add parameters, $a0:current car1x position
				jal display_car2x_out_of_map_check	# $v0: 1 true 0 false
				beq $zero, $v0, car2x_out_of_map_check_fail22
					# is out of bound
					addi $t3, $t3, -32		# back to initial point
				car2x_out_of_map_check_fail22:

				add $a0, $t3, $zero
				sll $a1, $t8, 5
				lw $a2, car22_color
				jal paint_pixel_by_offset

			addi $t8, $t8, 1
			bne $t9, $t8, paint_car22_loop2


		addi $t5, $t5, 1				# loop increament
		bne $t5, $t6, paint_car22_loop	# loop check



	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra

	display_car1x_out_of_map_check:
				# param $a0: current car1x position
				addi $sp, $sp, -4
				sw $ra, 0($sp)

					li $v0, 0			# init return value true
					li $t7, 672			# out of bound
					bgt $t7, $a0, display_car1x_out_of_map_succ
						li $v0, 1		# return false
					display_car1x_out_of_map_succ:

				# return #$v0: 1 true 0 false
				lw $ra, 0($sp)
				addi $sp, $sp, 4
				jr $ra

	display_car2x_out_of_map_check:
				# param $a0: current car1x position
				addi $sp, $sp, -4
				sw $ra, 0($sp)

					li $v0, 0			# init return value true
					li $t7, 800			# out of bound
					bgt $t7, $a0, display_car2x_out_of_map_succ
						li $v0, 1		# return false
					display_car2x_out_of_map_succ:

				# return #$v0: 1 true 0 false
				lw $ra, 0($sp)
				addi $sp, $sp, 4
				jr $ra

boat_display:
	addi $sp, $sp, -4
	sw $ra, 0($sp)

	paint_boat1:
		li $t5, 0						# loop i
		lw $t6, boat11_length				# loop termination 32
		sll $t6, $t6, 2					# loop termination 32 * 4
		paint_boat1_loop:				# loop for boat height

			li $t8, 0
			li $t9, 4
			paint_boat1_loop2:	# Loop to print boat width
				# boundary check
				lw $t3, boat11_position
				add $t3, $t3, $t5
				add $a0, $t3, $zero		# add parameters, $a0:current boat1x position
				jal display_boat1x_out_of_map_check	# $v0: 1 true 0 false
				beq $zero, $v0, boat1x_out_of_map_check_fail
					# is out of bound
					addi $t3, $t3, -32		# back to initial point
				boat1x_out_of_map_check_fail:

				add $a0, $t3, $zero

				sll $a1, $t8, 5
				lw $a2, boat11_color
				jal paint_pixel_by_offset

			addi $t8, $t8, 1
			bne $t9, $t8, paint_boat1_loop2

		addi $t5, $t5, 1				# loop increament
		bne $t5, $t6, paint_boat1_loop	# loop check

	paint_boat12:
		li $t5, 0						# loop i
		lw $t6, boat12_length				# loop termination 32
		sll $t6, $t6, 2					# loop termination 32 * 4
		paint_boat12_loop:				# loop for boat height

			li $t8, 0
			li $t9, 4
			paint_boat12_loop2:	# Loop to print boat width
				# boundary check
				lw $t3, boat12_position
				add $t3, $t3, $t5
				add $a0, $t3, $zero		# add parameters, $a0:current boat1x position
				jal display_boat1x_out_of_map_check	# $v0: 1 true 0 false
				beq $zero, $v0, boat1x_out_of_map_check_fail12
					# is out of bound
					addi $t3, $t3, -32		# back to initial point
				boat1x_out_of_map_check_fail12:

				add $a0, $t3, $zero

				sll $a1, $t8, 5
				lw $a2, boat12_color
				jal paint_pixel_by_offset

			addi $t8, $t8, 1
			bne $t9, $t8, paint_boat12_loop2

		addi $t5, $t5, 1				# loop increament
		bne $t5, $t6, paint_boat12_loop	# loop check

	paint_boat2:
		li $t5, 0						# loop i
		lw $t6, boat21_length				# loop termination 32
		sll $t6, $t6, 2					# loop termination 32 * 4
		paint_boat2_loop:				# loop begin i:n-1

			li $t8, 0
			li $t9, 4
			paint_boat2_loop2:	# Loop to print boat width
				# boundary check
				lw $t3, boat21_position
				add $t3, $t3, $t5
				add $a0, $t3, $zero		# add parameters, $a0:current boat1x position
				jal display_boat2x_out_of_map_check	# $v0: 1 true 0 false
				beq $zero, $v0, boat2x_out_of_map_check_fail
					# is out of bound
					addi $t3, $t3, -32		# back to initial point
				boat2x_out_of_map_check_fail:

				add $a0, $t3, $zero
				sll $a1, $t8, 5
				lw $a2, boat21_color
				jal paint_pixel_by_offset

			addi $t8, $t8, 1
			bne $t9, $t8, paint_boat2_loop2


		addi $t5, $t5, 1				# loop increament
		bne $t5, $t6, paint_boat2_loop	# loop check

	paint_boat22:
		li $t5, 0						# loop i
		lw $t6, boat22_length				# loop termination 32
		sll $t6, $t6, 2					# loop termination 32 * 4
		paint_boat22_loop:				# loop begin i:n-1

			li $t8, 0
			li $t9, 4
			paint_boat22_loop2:	# Loop to print boat width
				# boundary check
				lw $t3, boat22_position
				add $t3, $t3, $t5
				add $a0, $t3, $zero		# add parameters, $a0:current boat1x position
				jal display_boat2x_out_of_map_check	# $v0: 1 true 0 false
				beq $zero, $v0, boat2x_out_of_map_check_fail22
					# is out of bound
					addi $t3, $t3, -32		# back to initial point
				boat2x_out_of_map_check_fail22:

				add $a0, $t3, $zero
				sll $a1, $t8, 5
				lw $a2, boat22_color
				jal paint_pixel_by_offset

			addi $t8, $t8, 1
			bne $t9, $t8, paint_boat22_loop2


		addi $t5, $t5, 1				# loop increament
		bne $t5, $t6, paint_boat22_loop	# loop check


	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra

	display_boat1x_out_of_map_check:
				# param $a0: current boat1x position
				addi $sp, $sp, -4
				sw $ra, 0($sp)

					li $v0, 0			# init return value true
					li $t7, 288			# out of bound
					bgt $t7, $a0, display_boat1x_out_of_map_succ
						li $v0, 1		# return false
					display_boat1x_out_of_map_succ:

				# return #$v0: 1 true 0 false
				lw $ra, 0($sp)
				addi $sp, $sp, 4
				jr $ra

	display_boat2x_out_of_map_check:
				# param $a0: current boat1x position
				addi $sp, $sp, -4
				sw $ra, 0($sp)

					li $v0, 0			# init return value true
					li $t7, 416			# out of bound
					bgt $t7, $a0, display_boat2x_out_of_map_succ
						li $v0, 1		# return false
					display_boat2x_out_of_map_succ:

				# return #$v0: 1 true 0 false
				lw $ra, 0($sp)
				addi $sp, $sp, 4
				jr $ra


dispaly_death_animate:
	addi $sp, $sp, -4
	sw $ra, 0($sp)

		li $t4, 5000		# loop termination 
		dispaly_death_animate_loop:				# loop begin i:n-1

			lw $a1, heart_color
			la $t2, frog_position	# load position address
			lw $t3, 0($t2)
			add $a0, $zero, $t3
			jal paint_block

		addi $t4, $t4, -1				# loop increament
		bgtz $t4, dispaly_death_animate_loop	# loop check

	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra


dispaly_respown_animate:
	addi $sp, $sp, -4
	sw $ra, 0($sp)

		li $t4, 5000		# loop termination 
		dispaly_respown_animate_loop:				# loop begin i:n-1

			lw $a1, light_color
			la $t2, frog_position	# load position address
			lw $t3, 0($t2)
			add $a0, $zero, $t3
			jal paint_block

		addi $t4, $t4, -1				# loop increament
		bgtz $t4, dispaly_respown_animate_loop	# loop check

	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra

dispaly_win:
	addi $sp, $sp, -4
	sw $ra, 0($sp)

	lw $a1, heart_color

	li $a0, 18
	jal paint_pixel
	li $a0, 50
	jal paint_pixel
	li $a0, 82
	jal paint_pixel
	li $a0, 20
	jal paint_pixel
	li $a0, 52
	jal paint_pixel
	li $a0, 84
	jal paint_pixel
	li $a0, 115
	jal paint_pixel
	li $a0, 117
	jal paint_pixel
	li $a0, 22
	jal paint_pixel
	li $a0, 54
	jal paint_pixel
	li $a0, 86
	jal paint_pixel
	li $a0, 25
	jal paint_pixel
	li $a0, 57
	jal paint_pixel
	li $a0, 89
	jal paint_pixel
	li $a0, 121
	jal paint_pixel
	li $a0, 28
	jal paint_pixel
	li $a0, 60
	jal paint_pixel
	li $a0, 92
	jal paint_pixel
	li $a0, 124
	jal paint_pixel
	li $a0, 61
	jal paint_pixel
	li $a0, 94
	jal paint_pixel
	li $a0, 31
	jal paint_pixel
	li $a0, 63
	jal paint_pixel
	li $a0, 95
	jal paint_pixel
	li $a0, 127
	jal paint_pixel

	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra

dispaly_gameover:
	addi $sp, $sp, -4
	sw $ra, 0($sp)

		lw $a1, heart_color

		li $a0, 22
		jal paint_pixel
		li $a0, 23
		jal paint_pixel
		li $a0, 24
		jal paint_pixel
		li $a0, 25
		jal paint_pixel
		li $a0, 54
		jal paint_pixel
		li $a0, 86
		jal paint_pixel
		li $a0, 118
		jal paint_pixel
		li $a0, 119
		jal paint_pixel
		li $a0, 120
		jal paint_pixel
		li $a0, 121
		jal paint_pixel
		li $a0, 89
		jal paint_pixel
		li $a0, 28
		jal paint_pixel
		li $a0, 29
		jal paint_pixel
		li $a0, 30
		jal paint_pixel
		li $a0, 31
		jal paint_pixel
		li $a0, 60
		jal paint_pixel
		li $a0, 92
		jal paint_pixel
		li $a0, 124
		jal paint_pixel
		li $a0, 125
		jal paint_pixel
		li $a0, 126
		jal paint_pixel
		li $a0, 127
		jal paint_pixel
		li $a0, 95
		jal paint_pixel

	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra


lives_display:
	# param $a0: position
	addi $sp, $sp, -4
	sw $ra, 0($sp)

		li $t5, 0						# loop i
		lw $t6, lives					# loop termination 
		lives_display_loop:				# loop begin i:n-1

			lw $t0, display_address	# load display_address
			lw $t1, heart_color				# load color
			li $t3, 34		# load position
			addi $t3, $t3, 0
			sll $t4, $t5, 2
			add $t3, $t3, $t4
			sll $t3,$t3, 2			# convert pos to address
			add $t0, $t0, $t3		# add pos to address
			sw $t1, 0($t0)			# color on address

			lw $t0, display_address	# load display_address
			lw $t1, heart_color				# load color
			li $t3, 34		# load position
			addi $t3, $t3, 1
			sll $t4, $t5, 2
			add $t3, $t3, $t4
			sll $t3,$t3, 2			# convert pos to address
			add $t0, $t0, $t3		# add pos to address
			sw $t1, 0($t0)			# color on address

			lw $t0, display_address	# load display_address
			lw $t1, heart_color				# load color
			li $t3, 34		# load position
			addi $t3, $t3, 32
			sll $t4, $t5, 2
			add $t3, $t3, $t4
			sll $t3,$t3, 2			# convert pos to address
			add $t0, $t0, $t3		# add pos to address
			sw $t1, 0($t0)			# color on address

			lw $t0, display_address	# load display_address
			lw $t1, heart_color				# load color
			li $t3, 34		# load position
			addi $t3, $t3, 33
			sll $t4, $t5, 2
			add $t3, $t3, $t4
			sll $t3,$t3, 2			# convert pos to address
			add $t0, $t0, $t3		# add pos to address
			sw $t1, 0($t0)			# color on address

		addi $t5, $t5, 1				# loop increament
		bne $t5, $t6, lives_display_loop	# loop check

	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra




paint_pixel_by_offset:
	# param $a0: anchor point
	# param $a1: offset point
	# param $a2: color
	addi $sp, $sp, -4
	sw $ra, 0($sp)

		lw $t0, display_address	# load display_address
		add $t1, $zero, $a2				# load color
		add $t3, $a0, $zero		# load position
		add $t3, $t3, $a1				# change position
		sll $t3,$t3, 2			# convert pos to address
		add $t0, $t0, $t3		# add pos to address
		sw $t1, 0($t0)			# color on address

	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra

paint_pixel:
	# param $a0: position
	# param $a1: color
	addi $sp, $sp, -4
	sw $ra, 0($sp)

		lw $t0, display_address	# load display_address
		add $t1, $zero, $a2				# load color
		add $t3, $a0, $zero		# load position
		sll $t3,$t3, 2			# convert pos to address
		add $t0, $t0, $t3		# add pos to address
		sw $t1, 0($t0)			# color on address

	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra

paint_block:
	# param $a0: position
	# param $a1: color
	addi $sp, $sp, -4
	sw $ra, 0($sp)

		li $t5, 0						# loop i
		li $t6, 4					# loop termination 
		paint_block_loop:				# loop begin i:n-1

			li $t8, 0
			li $t9, 4
			paint_block_loop2:	# Loop to print boat width

				lw $t0, display_address	# load display_address
				add $t1, $zero, $a1				# load color
				add $t3, $a0, $zero		# load position

				add $t3, $t3, $t5				# change position
				sll $t7, $t8, 5
				add $t3, $t3, $t7		# change position
				sll $t3,$t3, 2			# convert pos to address
				add $t0, $t0, $t3		# add pos to address
				sw $t1, 0($t0)			# color on address

			addi $t8, $t8, 1
			bne $t9, $t8, paint_block_loop2


		addi $t5, $t5, 1				# loop increament
		bne $t5, $t6,paint_block_loop	# loop check

	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
