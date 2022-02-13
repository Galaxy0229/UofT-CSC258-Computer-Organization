# Solution file for assembly question Q12C
# 
# - Assume that $a0 and $a1 contain two pixel values from the bitmap display 
#     of your assembly language final project
# - Set $v0 to store the pixel value that is the average of $a0 and $a1.
#     (Meaning that each colour component of $v0 is the average of the 
#     corresponding colour components in $a0 and $a1)
# - Make sure to comment your code and use meaningful label names.
# - Do not use jr $ra or syscall commend to terminate your program.
#

.data

.text

main:
	addi $a0, $zero, 0xffaa00   # we will change this value in testing.
	add $a1, $zero, 	0xcc00ff   # we will also change this value in testing.
#######################################
# ONLY ALTER THE CODE BELOW THIS LINE #
#######################################
