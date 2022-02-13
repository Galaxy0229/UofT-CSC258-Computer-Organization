# Demo for painting
#
# Bitmap Display Configuration:
# - Unit width in pixels: 8
# - Unit height in pixels: 8
# - Display width in pixels: 256
# - Display height in pixels: 256
# - Base Address for Display: 0x10008000 ($gp)
#


.data

displayAddress: .word 0x10008000
vehicle1: .word 2560 
vehicle2: .word 2624


.text

lw $t0, displayAddress # $t0 stores the base address for display
li $t1, 0xff0000 # $t1 stores the red colour code
li $t2, 0x00ff00 # $t2 stores the green colour code
li $t3, 0x0000ff # $t3 stores the blue colour code
li $t4, 0x000000 # $t4 stores the black colour code
li $t5, 0xffff00 # $t5 stores the yellow colour code
li $t6, 0x7a7a7a # $t6 stores the grey colour code



#sw $t1, 0($t0) # paint the first (top-left) unit red. 
#sw $t2, 4($t0) # paint the second unit on the first row green. Why $t0+4?
#sw $t3, 128($t0) # paint the first unit on the second row blue. Why +128?


# Goal section
main: lw $t0, displayAddress # $t0 stores the base address for display
li $t1, 0xff0000 # $t1 stores the red colour code
li $t2, 0x00ff00 # $t2 stores the green colour code
li $t3, 0x0000ff # $t3 stores the blue colour code
li $t4, 0x000000 # $t4 stores the black colour code
li $t5, 0xffff00 # $t5 stores the yellow colour code
li $t6, 0x7a7a7a # $t6 stores the grey colour code
addi $t7, $zero, 1024
      add  $t8, $zero, $zero
      add  $t9, $t0, $zero

start: beq $t8, $t7, main1
       sw $t2, 0($t9)
       addi $t8, $t8, 4
       addi $t9, $t9, 4
       j start

# Water section
main1: addi $t7, $zero, 1024
       add  $t8, $zero, $zero
       add  $t9, $t0, 1024

start1: beq $t8, $t7, main2
        sw $t3, 0($t9)
        addi $t8, $t8, 4
        addi $t9, $t9, 4
        j start1      


# Safe section
main2: addi $t7, $zero, 512
       add  $t8, $zero, $zero
       add  $t9, $t0, 2048

start2: beq $t8, $t7, main3
        sw $t5, 0($t9)
        addi $t8, $t8, 4
        addi $t9, $t9, 4
        j start2         

              
# Road section
main3: addi $t7, $zero, 1024
       add  $t8, $zero, $zero
       add  $t9, $t0, 2560

start3: beq $t8, $t7, main4
        sw $t6, 0($t9)
        addi $t8, $t8, 4
        addi $t9, $t9, 4
        j start3

# Start section
main4: addi $t7, $zero, 1024
       add  $t8, $zero, $zero
       add  $t9, $t0, 3584

start4: beq $t8, $t7, frog
        sw $t2, 0($t9)
        addi $t8, $t8, 4
        addi $t9, $t9, 4
        j start4 

               
     
# Draw the frog
frog: li $t7, 0xFF00FF  # $t7 stores the pink colour code
      sw $t7, 3648($t0)
      sw $t7, 3660($t0)
      sw $t7, 3776($t0)
      sw $t7, 3780($t0)
      sw $t7, 3784($t0)
      sw $t7, 3788($t0)
      sw $t7, 3908($t0)
      sw $t7, 3912($t0)
      sw $t7, 4032($t0)
      sw $t7, 4036($t0)
      sw $t7, 4040($t0)
      sw $t7, 4044($t0)


# Draw vehicles
vc1:   lw $t0, displayAddress
       lw $t6, vehicle1
       
       add $t6, $t0, $t6
       
       li $t1, 0xff0000 # $t1 stores the red colour code
       
       add $t7, $t6, 128
       add $t8, $t7, 128
       add $t9, $t8, 128
       
loop1: lw $t0, displayAddress
       lw $t6, vehicle1
       
       add $t6, $t0, $t6
       
	beq $t6, 2687, reset1
	j rt1
	
reset1: addi $t6, $t6, 2560
	sw $t6, vehicle1
 
rt1: addi $t4, $zero, 32
       add  $t5, $zero, $zero
       beq $t4, $t5, Exit
        sw $t1, 0($t6)
        sw $t1, 0($t7)
        sw $t1, 0($t8)
        sw $t1, 0($t9)
        addi $t5, $t5, 4
        addi $t6, $t6, 4
        addi $t7, $t7, 4
        addi $t8, $t8, 4
        addi $t9, $t9, 4
        sw $t6, vehicle1
        
        


main7: addi $t4, $zero, 32
       add  $t5, $zero, $zero
       add  $t6, $t0, 2624
       add  $t7, $t0, 2752
       add  $t8, $t0, 2880
       add  $t9, $t0, 3008

start7: beq $t4, $t5, main8
        sw $t1, 0($t6)
        sw $t1, 0($t7)
        sw $t1, 0($t8)
        sw $t1, 0($t9)
        addi $t5, $t5, 4
        addi $t6, $t6, 4
        addi $t7, $t7, 4
        addi $t8, $t8, 4
        addi $t9, $t9, 4
        j start7 


main8: addi $t4, $zero, 16
       add  $t5, $zero, $zero
       add  $t6, $t0, 3072
       add  $t7, $t0, 3200
       add  $t8, $t0, 3328
       add  $t9, $t0, 3456

start8: beq $t4, $t5, main9
        sw $t1, 0($t6)
        sw $t1, 0($t7)
        sw $t1, 0($t8)
        sw $t1, 0($t9)
        addi $t5, $t5, 4
        addi $t6, $t6, 4
        addi $t7, $t7, 4
        addi $t8, $t8, 4
        addi $t9, $t9, 4
        j start8 


main9: addi $t4, $zero, 32
       add  $t5, $zero, $zero
       add  $t6, $t0, 3120
       add  $t7, $t0, 3248
       add  $t8, $t0, 3376
       add  $t9, $t0, 3504

start9: beq $t4, $t5, main10
        sw $t1, 0($t6)
        sw $t1, 0($t7)
        sw $t1, 0($t8)
        sw $t1, 0($t9)
        addi $t5, $t5, 4
        addi $t6, $t6, 4
        addi $t7, $t7, 4
        addi $t8, $t8, 4
        addi $t9, $t9, 4
        j start9

main10: addi $t4, $zero, 16
       add  $t5, $zero, $zero
       add  $t6, $t0, 3184
       add  $t7, $t0, 3312
       add  $t8, $t0, 3440
       add  $t9, $t0, 3568

start10: beq $t4, $t5, main11
        sw $t1, 0($t6)
        sw $t1, 0($t7)
        sw $t1, 0($t8)
        sw $t1, 0($t9)
        addi $t5, $t5, 4
        addi $t6, $t6, 4
        addi $t7, $t7, 4
        addi $t8, $t8, 4
        addi $t9, $t9, 4
        j start10  
        
# Draw logs

main11: li $t1, 0x800000  # $t1 stores the brown colour code
       addi $t4, $zero, 32
       add  $t5, $zero, $zero
       add  $t6, $t0, 1040
       add  $t7, $t0, 1168
       add  $t8, $t0, 1296
       add  $t9, $t0, 1424

start11: beq $t4, $t5, main12
        sw $t1, 0($t6)
        sw $t1, 0($t7)
        sw $t1, 0($t8)
        sw $t1, 0($t9)
        addi $t5, $t5, 4
        addi $t6, $t6, 4
        addi $t7, $t7, 4
        addi $t8, $t8, 4
        addi $t9, $t9, 4
        j start11

                
main12: addi $t4, $zero, 32
       add  $t5, $zero, $zero
       add  $t6, $t0, 1104
       add  $t7, $t0, 1232
       add  $t8, $t0, 1360
       add  $t9, $t0, 1488

start12: beq $t4, $t5, main13
        sw $t1, 0($t6)
        sw $t1, 0($t7)
        sw $t1, 0($t8)
        sw $t1, 0($t9)
        addi $t5, $t5, 4
        addi $t6, $t6, 4
        addi $t7, $t7, 4
        addi $t8, $t8, 4
        addi $t9, $t9, 4
        j start12

main13: addi $t4, $zero, 32
       add  $t5, $zero, $zero
       add  $t6, $t0, 1568
       add  $t7, $t0, 1696
       add  $t8, $t0, 1824
       add  $t9, $t0, 1952

start13: beq $t4, $t5, main14
        sw $t1, 0($t6)
        sw $t1, 0($t7)
        sw $t1, 0($t8)
        sw $t1, 0($t9)
        addi $t5, $t5, 4
        addi $t6, $t6, 4
        addi $t7, $t7, 4
        addi $t8, $t8, 4 
        addi $t9, $t9, 4
        j start13

main14: addi $t4, $zero, 32
       add  $t5, $zero, $zero
       add  $t6, $t0, 1632
       add  $t7, $t0, 1760
       add  $t8, $t0, 1888
       add  $t9, $t0, 2016

start14: beq $t4, $t5, refresh
        sw $t1, 0($t6)
        sw $t1, 0($t7)
        sw $t1, 0($t8)
        sw $t1, 0($t9)
        addi $t5, $t5, 4
        addi $t6, $t6, 4
        addi $t7, $t7, 4
        addi $t8, $t8, 4
        addi $t9, $t9, 4
        j start14

refresh: li $v0, 32
	 li $a0, 1000
	 syscall
	 j main
	 
initial_point:  addi $t9, $zero, 3648 

                
# Fetching keyboard Input
key_stroke: lw $t8, 0xffff0000
       beq $t8, 1, keyboard_input
       
       
keyboard_input: lw $t2, 0xffff0004
       		beq $t2, 0x61, respond_to_A
       		beq $t2, 0x64, respond_to_D
       		beq $t2, 0x77, respond_to_W
       		beq $t2, 0x73, respond_to_S

respond_to_A: jal main
		
		
	      subi $t9, $t9, 4
	      sw $t7, 0($t9)
	      
	      addi $t9, $t9, 12
	      sw $t7, 0($t9)
	      
	      addi $t9, $t9, 116
	      sw $t7, 0($t9)
	      
	      addi $t9, $t9, 4
	      sw $t7, 0($t9)
	      
	      addi $t9, $t9, 4
	      sw $t7, 0($t9)
	      
	      addi $t9, $t9, 4
	      sw $t7, 0($t9)
	      
	      addi $t9, $t9, 118
	      sw $t7, 0($t9)
	      
	      addi $t9, $t9, 4
	      sw $t7, 0($t9)
	      
	      addi $t9, $t9, 120
	      sw $t7, 0($t9)
	      
	      addi $t9, $t9, 4
	      sw $t7, 0($t9)
	      
	      addi $t9, $t9, 4
	      sw $t7, 0($t9)
	      
	      addi $t9, $t9, 4
	      sw $t7, 0($t9)
	      
respond_to_D: jal main

	      addi $t9, $t9, 4
	      sw $t7, 0($t9)
	      
	      addi $t9, $t9, 12
	      sw $t7, 0($t9)
	      
	      addi $t9, $t9, 116
	      sw $t7, 0($t9)
	      
	      addi $t9, $t9, 4
	      sw $t7, 0($t9)
	      
	      addi $t9, $t9, 4
	      sw $t7, 0($t9)
	      
	      addi $t9, $t9, 4
	      sw $t7, 0($t9)
	      
	      addi $t9, $t9, 118
	      sw $t7, 0($t9)
	      
	      addi $t9, $t9, 4
	      sw $t7, 0($t9)
	      
	      addi $t9, $t9, 120
	      sw $t7, 0($t9)
	      
	      addi $t9, $t9, 4
	      sw $t7, 0($t9)
	      
	      addi $t9, $t9, 4
	      sw $t7, 0($t9)
	      
	      addi $t9, $t9, 4
	      sw $t7, 0($t9)
	            		
respond_to_W: jal main

	      subi $t9, $t9, 128
	      sw $t7, 0($t9)
	      
	      addi $t9, $t9, 12
	      sw $t7, 0($t9)
	      
	      addi $t9, $t9, 116
	      sw $t7, 0($t9)
	      
	      addi $t9, $t9, 4
	      sw $t7, 0($t9)
	      
	      addi $t9, $t9, 4
	      sw $t7, 0($t9)
	      
	      addi $t9, $t9, 4
	      sw $t7, 0($t9)
	      
	      addi $t9, $t9, 118
	      sw $t7, 0($t9)
	      
	      addi $t9, $t9, 4
	      sw $t7, 0($t9)
	      
	      addi $t9, $t9, 120
	      sw $t7, 0($t9)
	      
	      addi $t9, $t9, 4
	      sw $t7, 0($t9)
	      
	      addi $t9, $t9, 4
	      sw $t7, 0($t9)
	      
	      addi $t9, $t9, 4
	      sw $t7, 0($t9)
	      
respond_to_S: jal main

	      addi $t9, $t9, 128
	      sw $t7, 0($t9)
	      
	      addi $t9, $t9, 12
	      sw $t7, 0($t9)
	      
	      addi $t9, $t9, 116
	      sw $t7, 0($t9)
	      
	      addi $t9, $t9, 4
	      sw $t7, 0($t9)
	      
	      addi $t9, $t9, 4
	      sw $t7, 0($t9)
	      
	      addi $t9, $t9, 4
	      sw $t7, 0($t9)
	      
	      addi $t9, $t9, 118
	      sw $t7, 0($t9)
	      
	      addi $t9, $t9, 4
	      sw $t7, 0($t9)
	      
	      addi $t9, $t9, 120
	      sw $t7, 0($t9)
	      
	      addi $t9, $t9, 4
	      sw $t7, 0($t9)
	      
	      addi $t9, $t9, 4
	      sw $t7, 0($t9)
	      
	      addi $t9, $t9, 4
	      sw $t7, 0($t9)
                  
Exit:
li $v0, 10 # terminate the program gracefully
syscall





