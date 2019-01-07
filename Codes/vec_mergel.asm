# *************************************** 3 4 1   T o p   L e v e l   M o d u l e ***************************************
# File name:		vec_mergel.asm
# Version:		1.0
# Date:			December 5, 2018 
# Programmer:		Thanh Le
#			Steven Chung
#
# Description:		Using a sequence of MIPS instructions, create a new "SIMD Enhanced" instruction that implements
#			a Vector Merge Low instruction where the syntax is vec_merge d, a, b. Vector a, b, and d consist of
#			eight 8-bit elements. When the instruction is execute, the even elements of the result vector d are
#			obtained left-to-right from the low elements of vector a. The odd elements of the result are obtained
#			left-to-right from the low elements of vector b.
#
# Register usage:   	$s0, $s1, $s2, $s3, $s4, $s5, $t0, $t1, $t2, $t3
#
# Notes: 		$s0 and $s1 are assumed to concatenate to indicate vector a
#			$s2 and $s3 are assumed to concatenate to indicate vector b
#			$s4 and $s5 are assumed to concatenate to indicate vector d
#			$t0, $t1, $t2, and $t3 are used to store temporary data
#
# **********************************************************************************************************************



		# *****************************************************************************************************
		# 				   M A I N   C O D E    S E G M E N T 
		# *****************************************************************************************************
		.text	
		.globl	main			# main (must be global)


main:		li	$s0, 0x5AF0A501		# initialize a with 4 bytes from $s0 and 4 bytes from $s1
		li	$s1, 0xAB0155C3		
	
		li	$s2, 0xA50F5A23		# initialize b with 4 bytes from $s2 and 4 bytes from $s3
		li	$s3, 0xCD23AA3C
	
		add	$s4, $zero, $zero	# clear d
		add	$s5, $zero, $zero					
		
		addi	$t0, $zero, 0xFF	
		addi	$t3, $zero, 0x4		# $t3 stores the number of loop needed for this instruction
						#  (loop 4 times since there are 4 element in each 32-bit vector segment)
		add	$t4, $zero, $zero	# $t4 acts as pointer to shift data
		
		
loop:		and	$t1, $s1, $t0		# load 8 bits of $s1 (a lower element of a) into $t1
		and	$t2, $s3, $t0		# load 8 bits in corresponding section of $s3 (a lower element of b) into $t
		srlv	$t1, $t1, $t4		# shift right $t1 to the last element of the vector
		srlv	$t2, $t2, $t4		# shift right $t2 to the last element of the vector
		sll	$t1, $t1, 8		# shift $t1 left 8 bits to move the data to the next last element
		add	$t1, $t1, $t2		# add these data to form a section of 16-bit where the element of vector a
						#  stay in the even index while the element of vector b stay in the odd index
		
		sll	$t4, $t4, 1		# adjust the value of pointer $t4 to shift the 16-bit result to proper position
		sllv	$t1, $t1, $t4
		srl	$t4, $t4, 1
		
		bgt	$t3, 2, upper		# if the index is greater than 2, conisder the upper 32-bit vector segment of vector d 
		
lower:		add	$s4, $s4, $t1		# add the result to the element of the lower 32-bit vector segment of vector d
		j	jump

upper:		add	$s5, $s5, $t1		# add the result to the element of the upper 32-bit vector segment of vector d
		
jump:		addi	$t3, $t3, -1		# decrease the number of loop left to finish this instruction
		sll	$t0, $t0, 8		# adjust the pointer $t0 to the next element
		addi	$t4, $t4, 8		# increase the number of bits needed to shift the next element to the last position in the vector
		bne	$t3, $zero, loop	# loop until the counter $t3 is equal to 0
		
		
		# Clear $t0, $t1, $t2, and $t3 after finishing the execution
		add	$t0, $zero, $zero
		add	$t1, $zero, $zero
		add	$t2, $zero, $zero
		add	$t3, $zero, $zero


		# -----------------------------------------------------------------------------------------------------
		# "Due diligence" to return control to the kernel
		# -----------------------------------------------------------------------------------------------------
exit:		ori	$v0, $zero, 10		# $v0 <-- function code for "exit"		
		syscall 			# Syscall to exit


		# *****************************************************************************************************
		# 			 P R O J E C T   R E L A T E D   D A T A   S E C T I O N 
		# *****************************************************************************************************
		.data				# place variables, arrays, and constants, etc. in this area
		
