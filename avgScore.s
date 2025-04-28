.data 

orig: .space 100	# In terms of bytes (25 elements * 4 bytes each)
sorted: .space 100

str0: 	.asciiz "Enter the number of assignments (between 1 and 25): "
str1: 	.asciiz "Enter score: "
str2: 	.asciiz "Original scores: "
str3: 	.asciiz "Sorted scores (in descending order): "
str4: 	.asciiz "Enter the number of (lowest) scores to drop: "
str5: 	.asciiz "Average (rounded down) with dropped scores removed: "

space: 	.asciiz " "
nl:	.asciiz "\n"

.text 

# This is the main program.
# It first asks user to enter the number of assignments.
# It then asks user to input the scores, one at a time.
# It then calls selSort to perform selection sort.
# It then calls printArray twice to print out contents of the original and sorted scores.
# It then asks user to enter the number of (lowest) scores to drop.
# It then calls calcSum on the sorted array with the adjusted length (to account for dropped scores).
# It then prints out average score with the specified number of (lowest) scores dropped from the calculation.
main: 
	addi $sp, $sp -4
	sw $ra, 0($sp)
	la $a0, str0 
	li $v0, 4 
	syscall 
	li $v0, 5	# Read the number of scores from user
	syscall
	
	# Your code here to handle invalid number of scores (can't be less than 1 or greater than 25)
	
	move $s0, $v0	# $s0 = numScores
	move $t0, $0
	la $s1, orig	# $s1 = orig
	la $s2, sorted	# $s2 = sorted
loop_in:
	li $v0, 4 
	la $a0, str1 
	syscall 
	sll $t1, $t0, 2
	add $t1, $t1, $s1
	li $v0, 5	# Read elements from user
	syscall
	sw $v0, 0($t1)
	addi $t0, $t0, 1
	bne $t0, $s0, loop_in
	
	move $a0, $s0
	jal selSort	# Call selSort to perform selection sort in original array
	
	li $v0, 4 
	la $a0, str2 
	syscall
	move $a0, $s1	# More efficient than la $a0, orig
	move $a1, $s0
	jal printArray	# Print original scores
	li $v0, 4 
	la $a0, str3 
	syscall 
	move $a0, $s2	# More efficient than la $a0, sorted
	jal printArray	# Print sorted scores
	
	li $v0, 4 
	la $a0, str4 
	syscall 
	li $v0, 5	# Read the number of (lowest) scores to drop
	syscall
	
	# Your code here to handle invalid number of (lowest) scores to drop (can't be less than 0, or 
	# greater than the number of scores). Also, handle the case when number of (lowest) scores to drop 
	# equals the number of scores. 
	
	move $a1, $v0
	sub $a1, $s0, $a1	# numScores - drop
	move $a0, $s2
	jal calcSum	# Call calcSum to RECURSIVELY compute the sum of scores that are not dropped
	
	# Your code here to compute average and print it (you may also end up having some code here to help 
	# handle the case when number of (lowest) scores to drop equals the number of scores
	
end:	lw $ra, 0($sp)
	addi $sp, $sp 4
	li $v0, 10 
	syscall
	
	
# printList takes in an array and its size as arguments. 
# It prints all the elements in one line with a newline at the end.
printArray:

	# Your implementation of printList here	
	
	addi $t0, $zero, 0		# initialize i = 0
	
loopStart:

	bge $t0, $a1, loopEnd		# break if (i >= len)

	# $t2 = arr[i]
	sll $t1, $t0, 2			# multiply i by 4
	add $t2, $a0, $t1		# $t2 = arr + i
	lw $t3, 0($t2)			# load arr[i] into $t3
	
	# print arr[i]
	move $t4, $a0			# store array address in $t4
	move $a0, $t3			# set $a0 to arr[i]
	li $v0, 1			# syscall value for printInt
	syscall				# prints the integer in $a0
	
	# print space
	la $a0, space			# set $a0 to a space
	li $v0, 4			# syscall value for printString
	syscall
	
	move $a0, $t4			# restore $a0
	
	addi $t0, $t0, 1		# i++
	
	j loopStart

loopEnd:

	# print newline
	la $a0, nl			# set $a0 to newline
	li $v0, 4			# syscall value for printString
	syscall

	jr $ra
	
	
# selSort takes in the number of scores as argument. 
# It performs SELECTION sort in descending order and populates the sorted array
# $s1 = orig, $s2 = sorted, #a0 = len
selSort:

    	move $t0, $zero         	# i = 0
    
copyLoop:

	bge $t0, $a0, outerLoop		# break if (i >= len)
	
	# $t2 = orig[i]
	sll $t1, $t0, 2			# multiply i by 4
	add $t2, $s1, $t1		# $t2 = orig + i
	lw $t3, 0($t2)			# load orig[i] into $t3
	
	add $t4, $s2, $t1		# $t4 = sorted + i
	
	sw $t3, 0($t4)			# store contents of orig[i] at address sorted[i]
	
	addi $t0, $t0, 1
	j copyLoop
	
outerLoop:

	move $t0, $zero			# i = 0
	
startOuterLoop:

	addi $t3, $a0, -1		# $t3 = len - 1
	bge $t0, $t3, endSel		# break if (i >= (len - 1))
	
	move $t2, $t0			# maxIndex = i
	
innerLoop:

	addi $t1, $t0, 1		# j = i + 1
	
startInnerLoop:

	bge $t1, $a0, endOuterLoop		# break if (j >= len)
	
	# $t5 = sorted[j]
	sll $t4, $t1, 2			# multiply j by 4
	add $t5, $s2, $t4		# $t5 = sorted + j
	lw $t5, 0($t5)			# load sorted[j] into $t5
	
	# $t6 = sorted[maxIndex]
	sll $t4, $t2, 2			# multiply maxIndex by 4
	add $t6, $s2, $t4		# $t6 = sorted + maxIndex
	lw $t6, 0($t6)			# load sorted[maxIndex] into $t6
	
	ble $t5, $t6, endInnerLoop	# if (sorted[j] <= sorted[maxIndex]) then continue
	
	move $t2, $t1			# move j into maxIndex
	
endInnerLoop:

	addi $t1, $t1, 1
	j startInnerLoop
	
endOuterLoop:

	# sorted[maxIndex]
	sll $t3, $t2, 2
	add $t4, $s2, $t3		# $t4 = address of sorted[maxIndex]
	lw $t5, 0($t4)			# $t5 = value of sorted[maxIndex]
	
	# sorted[i]
	sll $t3, $t0, 2
	add $t6, $s2, $t3		# $t6 = address of sorted[i]
	lw $t7, 0($t6)			# $t7 = vlaue of sorted[i]
	
	move $t8, $t5			# $t8 = value of sorted[maxValue]
	sw $t7, 0($t4)			# store value of sorted[i] into sorted[maxIndex]
	sw $t8, 0($t6)			# store value of sorted[maxIndex] into sorted[i]
	
	addi $t0, $t0, 1
	j startOuterLoop
	
endSel:

	jr $ra

	
# calcSum takes in an array and its size as arguments.
# It RECURSIVELY computes and returns the sum of elements in the array.
# Note: you MUST NOT use iterative approach in this function.
calcSum:
	# Your implementation of calcSum here
	
	jr $ra
	
