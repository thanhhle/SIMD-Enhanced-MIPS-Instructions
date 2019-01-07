# *************************************** 3 4 1   T o p   L e v e l   M o d u l e ***************************************
# File name:		vec_perm.asm
# Version:		1.0
# Date:			December 5, 2018 
# Programmer:		Thanh Le
#			Steven Chung
#
# Description:		Using a sequence of MIPS instructions, create a new "SIMD Enhanced" instruction that implements
#			a Vector Permuate instruction where the syntax is vec_oerm d, a, b, c. Vector a, b, c, and d
#			consist of eight 8-bit elements. When the instruction is executed, it fills the result vector d with
#			elements from either vector a or vector b, depending upon the "element specifier" in vector c.
#			Each "element specifier" has two components: the most-significant half specifies an element from
#			vector a or b (0 = a, 1 = b); the least-significant half specifies which element within the selected
#			vector (0..7)
#			
# Register usage:   	$s0, $s1, $s2, $s3, $s4, $s5, $s6, $s7, $t0, $t1, $t2, $t3, $t4, $t5, $t6
#
# Notes: 		$s0 and $s1 are assumed to concatenate to indicate vector a
#			$s2 and $s3 are assumed to concatenate to indicate vector b
#			$s4 and $s5 are assumed to concatenate to indicate vector c
#			$s6 and $s7 are assumed to concatenate to indicate vector d
#			$t0, $t2, and $t4 are used to store pointers
#			$t1, $t3,$t5, and $t6 are used to store temporary data
#			
#
# **********************************************************************************************************************



		# *****************************************************************************************************
		# 				   M A I N   C O D E    S E G M E N T 
		# *****************************************************************************************************
		.text	
		.globl	main			# main (must be global)


main:		li	$s0, 0xA567013D		# initialize a with 4 bytes from $s0 and 4 bytes from $s1
		li	$s1, 0xAB45393C		
	
		li	$s2, 0xEFC54D23		# initialize b with 4 bytes from $s2 and 4 bytes from $s3
		li	$s3, 0x1277AACD
		
		li	$s4, 0x04171002		# initialize c with 4 bytes from $s4 and 4 bytes from $s5
		li	$s5, 0x13050105
	
		add	$s6, $zero, $zero	# clear d
		add	$s7, $zero, $zero					

		addi	$t0, $zero, 0xFF000000	# $t0, $t2, and $t4 are pointer to assist in shift and point to a specific element
		add	$t2, $zero, $zero
		addi	$t4, $zero, 24
		addi	$t3, $zero, 0xF		# $t3 stores the most biggest 4-bit number
		addi	$t5, $zero, 8		# $t5 stores number 8
		addi	$t7, $zero, 24		# $t7 stores number 24
	
		# Execute the instruction on the upper 32-bit section of vector c
upperC:		and	$t1, $s4, $t0		# load 8 bits of $s4 (an element of c) into $t1
		sllv	$t0, $t0, $t2		# shift left the pointer $t0 to the first element of the upper 32-bit section of vector c
		srlv	$t1, $t1, $t4		# shift right $t1 to the posiition of the last 8-bit element
		slti	$t6, $t1, 0x10		# compare the value with 0x10 to determine if it takes the data from vector a or vector b\
		and	$t1, $t1, $t3		# load the lower 4 bits in the 8-bit element to $t1
		bne	$t6, $zero, takeA	# choose vector if the upper 4 bits has the value of 0

		# Determine if the index points to the element in upper 32-bit section or lower 32-bit section of vector b
takeB:		slti	$t6, $t1, 4
		bne	$t6, $zero, takeUpperB
		
		# Determine the element at the index if it is in the lower 32-bit section of vector b
takeLowerB:	mult	$t1, $t5
		mflo	$t6
		addi	$t6, $t6, -32
		srlv	$t0, $t0, $t6
		and	$t1, $s3, $t0
		j	execute
		
		# Determine element at the index if it is in the upper 32-bit section of vector b
takeUpperB:	mult	$t1, $t5
		mflo	$t6
		srlv	$t0, $t0, $t6
		and	$t1, $s2, $t0
		j	execute
		
		# Determine if the index points to the element in upper 32-bit section or lower 32-bit section of vector a
takeA:		slti	$t6, $t1, 4
		bne	$t6, $zero, takeUpperA
		
		# Determine the element at the index if it is in the upper 32-bit section of vector a
takeLowerA:	mult	$t1, $t5
		mflo	$t6
		addi	$t6, $t6, -32
		srlv	$t0, $t0, $t6
		and	$t1, $s1, $t0
		j	execute

		# Determine element at the index if it is in the lower 32-bit section of vector b
takeUpperA:	mult	$t1, $t5
		mflo	$t6
		srlv	$t0, $t0, $t6
		and	$t1, $s0, $t0

execute:	sllv	$t0, $t0, $t6		# shift the $t0 to its previous position
		srlv	$t0, $t0, $t2		
		sub	$t6, $t7, $t6		# calculate the bits to be shifted to move the element to the last index
		srlv	$t1, $t1, $t6		# shift right the element to the last index
		
		sllv	$s6, $s6, $t5		# shift left the $s6 8 bits to give space for the element at the last index
		add	$s6, $s6, $t1		# copy the elemment to the end of $s6
		
		# Adjust the pointers
		srl	$t0, $t0, 8
		addi	$t2, $t2, 8
		sub	$t4, $t4, 8
		bne	$t0, $zero, upperC
		
		#-----------------------------------------------------------------------------------------------------------
		# Repeat the logic for the lower 32-bit section of vector c after resetting $t0, $t2, $t3, $t4, $t5, and $t7 
		addi	$t0, $zero, 0xFF000000	
		add	$t2, $zero, $zero
		addi	$t3, $zero, 0xF
		addi	$t4, $zero, 24
		addi	$t5, $zero, 8
		addi	$t7, $zero, 24
	
lowerC:		and	$t1, $s5, $t0
		sllv	$t0, $t0, $t2
		
		srlv	$t1, $t1, $t4
				
		slti	$t6, $t1, 0x10
		and	$t1, $t1, $t3
		bne	$t6, $zero, takeA2

takeB2:		slti	$t6, $t1, 4
		bne	$t6, $zero, takeUpperB2

takeLowerB2:	mult	$t1, $t5
		mflo	$t6
		addi	$t6, $t6, -32
		srlv	$t0, $t0, $t6
		and	$t1, $s3, $t0
		j	execute2
		
takeUpperB2:	mult	$t1, $t5
		mflo	$t6
		srlv	$t0, $t0, $t6
		and	$t1, $s2, $t0
		j	execute2

takeA2:		slti	$t6, $t1, 4
		bne	$t6, $zero, takeUpperA2

takeLowerA2:	mult	$t1, $t5
		mflo	$t6
		addi	$t6, $t6, -32
		srlv	$t0, $t0, $t6
		and	$t1, $s1, $t0
		j	execute2

takeUpperA2:	mult	$t1, $t5
		mflo	$t6
		srlv	$t0, $t0, $t6
		and	$t1, $s0, $t0

execute2:	sllv	$t0, $t0, $t6
		srlv	$t0, $t0, $t2
		sub	$t6, $t7, $t6
		srlv	$t1, $t1, $t6
		
		sllv	$s7, $s7, $t5
		add	$s7, $s7, $t1
		
		srl	$t0, $t0, 8
		addi	$t2, $t2, 8
		sub	$t4, $t4, 8
		bne	$t0, $zero, lowerC
		
		
		# Clear $t0, $t1, $t2, and $t3 after finishing the execution
		add	$t0, $zero, $zero
		add	$t1, $zero, $zero
		add	$t2, $zero, $zero
		add	$t3, $zero, $zero
		add	$t4, $zero, $zero
		add	$t5, $zero, $zero
		add	$t6, $zero, $zero
	
	
		# -----------------------------------------------------------------------------------------------------
		# "Due diligence" to return control to the kernel
		# -----------------------------------------------------------------------------------------------------
exit:		ori	$v0, $zero, 10		# $v0 <-- function code for "exit"		
		syscall 			# Syscall to exit


		# *****************************************************************************************************
		# 			 P R O J E C T   R E L A T E D   D A T A   S E C T I O N 
		# *****************************************************************************************************
		.data				# place variables, arrays, and constants, etc. in this area
			
