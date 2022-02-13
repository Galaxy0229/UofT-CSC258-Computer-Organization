#
# Solution file for assembly question Q12A
# 
# - Assume that $a0 contains an unsigned integer N,
# - Calculate N! (N factorial) and store the result in $v0
#      (assume the length of this value will be less than 32 bits).
# - Do NOT perform this operation recursively!
# - Make sure to comment your code and use meaningful label names.
# - Do not use jr $ra or syscall commend to terminate your program.
#

.data

.text

main:
	addi $a0, $zero, 5	# we will change this value in testing.
	addi $t0, $a0, 0 	# store the value of a0.
	addi $v0, $zero, 1 	# set v0 be 1.

factorial:
	beq $t0, $zero, end
	mult $v0, $t0
	mflo $v0        
	addi $t0, $t0, -1
	j factorial

end:

#######################################
# ONLY ALTER THE CODE BELOW THIS LINE #	
#######################################
