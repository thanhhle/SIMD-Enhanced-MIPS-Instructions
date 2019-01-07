# *************************************** 3 4 1   T o p   L e v e l   M o d u l e ***************************************
# File name:		vec_swap_el.asm
# Version:		1.0
# Date:			December 5, 2018 
# Programmer:		Thanh Le
#			Steven Chung
#
# Description:		Using a sequence of MIPS instructions, create a new "SIMD Enhanced" instruction that implements
#			a Vector Replace All instruction where the syntax is vec_swao_el d, a, b, c. Vector a and d consist
#			of eight 8-bit elements. Component b and d indicate the index of 2 elements to be swapped. When
#			the instruction is executed, the element at index b is swapped with the element at index c of
#			vector a. The result is stored in vector d
#
# Register usage:   	$s0, $s1, $s2, $s3, $s4, $s5, $t0, $t1, $t2, $t3, $t4, $t5, $t6, $v0, $v1
#
# Notes: 		$s0 and $s1 are assumed to concatenate to indicate vector a
#			#s2 and $s3 are used to indicate indexes of the elements to be swapped
#			$s3 and $s4 are assumed to concatenate to indicate vector d
#			$v0 and $v1 are used to store temporary data of destination vector d
#			$t0, $t1, $t2, $t3, $t4, $t5, and $t6 are used to store temporary data
#
# **********************************************************************************************************************



		# *****************************************************************************************************
		# 				   M A I N   C O D E    S E G M E N T 
		# *****************************************************************************************************
		.text	
		.globl	main				# main (must be global)


main:		li	$s0, 0xAABBCCDD			# initialize a with 4 bytes from $s0 and 4 bytes from $s1
		li	$s1, 0x11223344
		
		li	$s2, 1				# initialize the one of the two indexes
		li	$s3, 4				# initialize the other index
		
		add	$s4, $zero, $zero		# clear d
		add	$s5, $zero, $zero	
		
		add	$t0, $zero, 0xFF000000		
		addi	$t1, $zero, 8
		addi	$t4, $zero, 24
		
		add	$v0, $zero, $s0			# copy the upper 32-bit section of vector a to $v0
		add	$v1, $zero, $s1			# copy the lower 32-bit section of vector a to $v1
		
		# Determine the element at the first index, move it to the position of the other index, and delete the
		#   proper position for the element at the other to be swapped in 
		mult	$s2, $t1			# calculate the number of bits the pointer $t0 to be shifted
							#   to point to the first index 
		mflo	$t2
		
		mult	$s3, $t1			# calculate the number of bits the pointer $t0 to be shifted
							#   to point to the second index
		mflo	$t3
		
		slti	$t5, $t3, 32			# compare to determine if the index is in upper or lower section
		bne	$t5, $zero, noSub1
		addi	$t3, $t3, -32
	
noSub1:		slti	$t5, $t2, 32			# compare to determine if the index is in upper or lower section
		bne	$t5, $zero, upper1

		# If the index points to an element in the lower section
lower1:		addi	$t2, $t2, -32			# recalculate the number of bits to be shifted in lower section to reach the index
		srlv	$t0, $t0, $t2			# shift the pointer to the index
		or	$v1, $v1, $t0			# replace the element at the index with FF
		xor	$v1, $v1, $t0			# replace the element at the index with 00
		and	$t5, $s1, $t0			# take the element at the index
		j	jump1

upper1:		srlv	$t0, $t0, $t2			# shift the pointer to the index
		or	$v0, $v0, $t0			# replace the element at the index with FF
		xor	$v0, $v0, $t0			# replace the element at the index with 00
		and	$t5, $s0, $t0			# take the element at the index
				
jump1:		sub	$t2, $t4, $t2			# calculate the number of bits to be shifted to move the element to the most right position
		srlv	$t5, $t5, $t2			# shift the element to the most right position
		sub	$t2, $t4, $t3			# calculate the number of bits to be shifted to move the element to the swapped position
		sllv	$t5, $t5, $t2			# shift the element to the swapped position
		
		#-------------------------------------------------------------------------------------------------------------------------------------
		# Reset the pointer $t0 and repeat the same logic for the other index
		add	$t0, $zero, 0xFF000000
		
		mult	$s3, $t1
		mflo	$t3
		
		mult	$s2, $t1
		mflo	$t2
		
		slti	$t6, $t2, 32
		bne	$t6, $zero, noSub2
		addi	$t2, $t2, -32
	
noSub2:		slti	$t6, $t3, 32
		bne	$t6, $zero, upper2

lower2:		addi	$t3, $t3, -32
		srlv	$t0, $t0, $t3
		or	$v1, $v1, $t0
		xor	$v1, $v1, $t0
		and	$t6, $s1, $t0
		j	jump2

upper2:		srlv	$t0, $t0, $t3
		or	$v0, $v0, $t0
		xor	$v0, $v0, $t0
		and	$t6, $s0, $t0
		
jump2:		sub	$t3, $t4, $t3		
		srlv	$t6, $t6, $t3			
		sub	$t3, $t4, $t2			
		sllv	$t6, $t6, $t3
		
		#-------------------------------------------------------------------------------------------------------------------------------------
		# Swap the two elements at two indicated indexes
		mult	$s2, $t1			
		mflo	$t2
		slti	$t2, $t2, 32
		bne	$t2, $zero, lessThan1
		add	$s5, $v1, $t6
		j	clearReg
		
lessThan1:	add	$s4, $v0, $t6
		
next:		mult	$s3, $t1
		mflo	$t3
		slti	$t3, $t3, 32
		bne	$t3, $zero, lessThan2
		add	$s5, $v1, $t5
		j	clearReg
		
lessThan2:	add	$s4, $v0, $t5
		
		
		# Clear $t0, $t1, $t2, $t3, $t4, $t5, $t6, $v0, and $v1 after finishing the execution
clearReg:	add	$t0, $zero, $zero
		add	$t1, $zero, $zero
		add	$t2, $zero, $zero
		add	$t3, $zero, $zero
		add	$t4, $zero, $zero
		add	$t5, $zero, $zero
		add	$t6, $zero, $zero
		add	$v0, $zero, $zero
		add	$v1, $zero, $zero
		
		
		# -----------------------------------------------------------------------------------------------------
		# "Due diligence" to return control to the kernel
		# -----------------------------------------------------------------------------------------------------
exit:		ori	$v0, $zero, 10		# $v0 <-- function code for "exit"		
		syscall 			# Syscall to exit


		# *****************************************************************************************************
		# 			 P R O J E C T   R E L A T E D   D A T A   S E C T I O N 
		# *****************************************************************************************************
		.data				# place variables, arrays, and constants, etc. in this area
		
