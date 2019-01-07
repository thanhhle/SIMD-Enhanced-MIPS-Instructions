# *************************************** 3 4 1   T o p   L e v e l   M o d u l e ***************************************
# File name:		vec_splat.asm
# Version:		1.0
# Date:			December 5, 2018 
# Programmer:		Thanh Le
#			Steven Chung
#
# Description:		Using a sequence of MIPS instructions, create a new "SIMD Enhanced" instruction that implements
#			a Vector Splat instruction where the syntax is vec_splat d, a, b. Vector a and d consist of
#			eight 8-bit elements. When the instruction is execute, it copies any element which is indicated
#			by componet b from vector a into all of the elements of vector d
#
# Register usage:   	$s0, $s1, $s2, $s3, $s4, $t0, $t1, $t2, $t3. $t4
#
# Notes: 		$s0 and $s1 are assumed to concatenate to indicate vector a
#			$s2 is the index of the element b to be copied
#			$s4 and $s5 are assumed to concatenate to indicate vector d
#			$t0, $t1, $t2, $t3, and $t4 are used to store temporary data
#
# **********************************************************************************************************************



		# *****************************************************************************************************
		# 				   M A I N   C O D E    S E G M E N T 
		# *****************************************************************************************************
		.text	
		.globl	main			# main (must be global)


main:		li	$s0, 0x230C124D		# initialize a with 4 bytes from $s0 and 4 bytes from $s1
		li	$s1, 0x057F192A
		
		li	$s2, 5			# initialize the index of the element to be copied
	
		add	$s3, $zero, $zero	# clear d
		add	$s4, $zero, $zero					
		
		addi	$t0, $zero, 0xFF000000	
		addi	$t1, $zero, 0x8		# $t1 is assumed to be a pointer to get 8-bit data at an index
		addi	$t2, $zero, 0x18	# $t2 stores the number of bits to be shift to reach the last element of 32-bit vector segment
		addi	$t3, $zero, 0x4		# $t3 stores the number of loops needed for this instruction
						#  (loop 4 times since there are 4 element in each 32-bit vector segment)
		add	$t4, $zero, $s2
		
		bgt	$s2, 3, upper		# if the index is greater than 3, jump to upper
		j	lower			# if the index is not greater than 3, jump to lower
		
		# Determine the data to be copied at the index b
		  # When the index b is greater than 3
upper:		addi	$t4, $t4, -4		# assume the index to be counted from the first element of the upper vector segment
		mult	$t1, $t4		# calculate the number of bits to be shifted to move the pointer $t0 to the index
		mflo	$t1			
		srlv	$t0, $t0, $t1		# shift the pointer $t0 to the index
		and	$t0, $s1, $t0		# get the data at the index
		j	shift
		
		  # When the index b is smaller or equal to 3
lower:		mult	$t1, $t4		# calculate the number of bits to be shifted to move the pointer $t0 to the index
		mflo	$t1
		srlv	$t0, $t0, $t1		# shift the pointer $t0 to the index
		and	$t0, $s0, $t0		# get the data at the index
		
		# Shift the data to be copied to the last element of the vector
shift:		sub	$t2, $t2, $t1 		# calculate the number of bits to be shifted to reach the last element of
						#   the 32-bit vector segment
		srlv	$t0, $t0, $t2		# shift the data to be copied to each element to the position of the last element

		# Loop through every element of the vector and copy the data
loop:		add	$s3, $s3, $t0		# copy the data to an element of the lower 32-bit destination vector segment
		add	$s4, $s4, $t0		# copy the data to an element of the upper 32-bit destination vector segment
		sll	$t0, $t0, 8		# move the pointer the next element
		addi	$t3, $t3, -1		# decrease the number of loops needed by 1
		bne	$t3, $zero, loop	# loop 4 times since there are 4 element in each 32-bit vector segment
						# loop until the counter $t3 is equal to 0

		# Clear $t0, $t1, $t2, and $t3 after finishing the execution
		add	$t0, $zero, $zero
		add	$t1, $zero, $zero
		add	$t2, $zero, $zero
		add	$t3, $zero, $zero
		add	$t4, $zero, $zero
		

		# -----------------------------------------------------------------------------------------------------
		# "Due diligence" to return control to the kernel
		# -----------------------------------------------------------------------------------------------------
exit:		ori	$v0, $zero, 10		# $v0 <-- function code for "exit"		
		syscall 			# Syscall to exit


		# *****************************************************************************************************
		# 			 P R O J E C T   R E L A T E D   D A T A   S E C T I O N 
		# *****************************************************************************************************
		.data				# place variables, arrays, and constants, etc. in this area
		
