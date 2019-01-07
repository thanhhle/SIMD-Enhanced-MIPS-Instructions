# *************************************** 3 4 1   T o p   L e v e l   M o d u l e ***************************************
# File name:		vec_madd.asm
# Version:		1.0
# Date:			December 5, 2018 
# Programmer:		Thanh Le
#			Steven Chung
#
# Description:		Using a sequence of MIPS instructions, create a new "SIMD Enhanced" instruction that implements
#			a Vector Multiply and Add instruction where the syntax is vec_madd d, a, b, c. Each vector consists of
#			eight 8-bit elements. When the instruction is executed, each elements in a is multiplied by each element in b.
#			The intermediate result is add to the corresponding element in c, and the final sum is stored in d after being
#			"truncated" for a half-length.		
#
# Register usage:   	$s0, $s1, $s2, $s3, $s4, $s5, $s6, $s7, $t0, $t1, $t2, $t3
#
# Notes: 		$s0 and $s1 are assumed to concatenate to indicate vector a
#			$s2 and $s3 are assumed to concatenate to indicate vector b
#			$s4 and $s5 are assumed to concatenate to indicate vector c
#			$s6 and $s7 are assumed to concatenate to indicate vector d
#			$t1 and $t2 are used to store temporary data
#			$t0 is used to take bits in an element of the vector
#			$t3 is used as store the position (in bits) of the working element
#			Beside $t0, $t1, $t2, $t3, $s6, and $s7, no other MIPS registers are to change	
#
# **********************************************************************************************************************



		# *****************************************************************************************************
		# 				   M A I N   C O D E    S E G M E N T 
		# *****************************************************************************************************
		.text	
		.globl	main			# main (must be global)


main:		li	$s0, 0x120C1A0D		# initialize a with 4 bytes from $s0 and 4 bytes from $s1
		li	$s1, 0x23051912		
	
		li	$s2, 0x3D0C104D		# initialize b with 4 bytes from $s2 and 4 bytes from $s3
		li	$s3, 0X057F192B
		
		li	$s4, 0x60091B05		# initialize c with 4 bytes from $s4 and 4 bytes from $s5
		li	$s5, 0x501E0660
	
		add	$s6, $zero, $zero	# clear d
		add	$s7, $zero, $zero					

		addi	$t0, $zero, 0xFF	# $t2 stores the biggest 8-bit number
		add	$t3, $zero, $zero	
	
loop:		and	$t1, $s0, $t0		# load 8 bits of $s0 (an element of a) into $t1
		and	$t2, $s2, $t0		# load 8 bits in corresponding section of $s2 (an element of b) into $t2
		srlv	$t1, $t1, $t3		# shift right $t1 by the value stored in $t3 to prevent overflow
		srlv	$t2, $t2, $t3		# shift right $t2 by the value stored in $t3 to prevent overflow
		mult	$t1, $t2		# multiple these two 8-bit values and store the intermediate result in $lo
		mflo	$t1			# load the data in $lo into $t1
		andi	$t1, $t1, 0xFF		# truncate the result
		
		and	$t2, $s4, $t0		# load 8 bits in corresponding section of $s4 (an element of c) into $t2
		srlv	$t2, $t2, $t3		# shift right $t2 by the value stored in $t3 to prevent overflow
		add	$t1, $t1, $t2		# add the intermediate result stored in $t1 to $t2 
		slti	$t2, $t1, 0xFF		# check if the result is overflow
		bne	$t2, $zero, noOverFlow1 # if NO OVERFLOW, jump to noOverFlow1
		addi	$t1, $zero, 0xFF	# if OVERFLOW, the result is set to FF
		
		
noOverFlow1:	sllv	$t1, $t1, $t3		# shift left $t1 back to the previous working position
		add	$s6, $s6, $t1		# store the result to the destination register
		
		and	$t1, $s1, $t0		# load 8 bits of $s1 (an element of a) in $t1
		and	$t2, $s3, $t0		# load 8 bits in corresponding section of $s3 (an element of b) into $t2
		srlv	$t1, $t1, $t3		# shift right $t1 by the value stored in $t3 to prevent overflow
		srlv	$t2, $t2, $t3		# shift right $t1 by the value stored in $t3 to prevent overflow
		mult	$t1, $t2		# multiple these two 8-bit and store the intermediate result in $lo
		mflo	$t1			# load the data in $lo to $t1
		andi	$t1, $t1, 0xFF		# truncate the result
		
		and	$t2, $s5, $t0		# load 8 bits in corresponding section of $s5 (an element of c) into $t2
		srlv	$t2, $t2, $t3		# shift right $t2 by the value stored in $t3 to prevent overflow
		add	$t1, $t1, $t2		# add the intermediate result to $t2 
		slti	$t2, $t1, 0xFF		# check if the result is overflow
		bne	$t2, $zero, noOverFlow2 # if NO OVERFLOW, jump to noOverFlow2
		add	$t1, $zero, 0xFF	# if OVERFLOW, the result is set to FF


noOverFlow2:	sllv	$t1, $t1, $t3		# shift left $t1 back to the previous working position
		add	$s7, $s7, $t1		# store the result to the destination register
		
		sll	$t0, $t0, 8		# shift $t0 left 8 bit to move to the position of the next element
		addi	$t3, $t3, 8		# increase $t3 8 bits to point to the position of the next element
		bne	$t0, $zero, loop	# if $t0 is not zero, jump to the loop
		
		
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
			
