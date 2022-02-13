# Solution file for assembly question Q12B
# 
# - Assume that $a0 and $a1 contain two positive integers,
# - Calculate the largest integer that divides $a0 and $a1 evenly 
#     (the greatest common divisor) and store that value in $v0.
# - Again, do not perform this operation recursively.
# - Make sure to comment your code and use meaningful label names.
# - Do not use jr $ra or syscall commend to terminate your program.
#

.data

.text

main:
	addi $a0, $zero, 35	# we will change this value in testing.
	add $a1, $zero, 49	# we will also change this value in testing.
#######################################
# ONLY ALTER THE CODE BELOW THIS LINE #
#######################################
