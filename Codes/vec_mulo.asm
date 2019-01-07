# *************************************** 3 4 1   T o p   L e v e l   M o d u l e ***************************************
# File name:		vec_mulo.asm
# Version:		1.0
# Date:			December 5, 2018 
# Programmer:		Thanh Le
#			Steven Chung
#
# Description:		Using a sequence of MIPS instructions, create a new "SIMD Enhanced" instruction that implements
#			a Vector Multiply Odd Integer where the syntax is vec_mule d, a, b. Vector a and b consist of
#			eight 8-bit elements. Vector d consists of four 16-bit elements. When the instruction is executed,
#			each even element of a is added to the corresponding even element of b. The result is stored in 
#			full-length (16-bit) in each element of vector d.
#
# Register usage:   	$s0, $s1, $s2, $s3, $s4, $s5, $t0, $t1, $t2, $t3
#
# Notes: 		$s0 and $s1 are assumed to concatenate to indicate vector a
#			$s2 and $s3 are assumed to concatenate to indicate vector b
#			$s4 and $s5 are assumed to concatenate to indicate vector d
#			$t1 and $t2 are used to store temporary data
#			$t0 is used to take bits in an element of the vector
#			$t3 is used as store the position (in bits) of the working element
#			Beside $t0, $t1, $t2, $t3, $s4, and $s5, no other MIPS registers are to change	
#
# **********************************************************************************************************************



		# *****************************************************************************************************
		# 				   M A I N   C O D E    S E G M E N T 
		# *****************************************************************************************************
		.text	
		.globl	main			# main (must be global)


main:		li	$s0, 0xAEE95AE0		# initialize a with 4 bytes from $s0 and 4 bytes from $s1
		li	$s1, 0xF080CC66		
	
		li	$s2, 0x33146170		# initialize b with 4 bytes from $s2 and 4 bytes from $s3
		li	$s3, 0X609888AB
	
		add	$s4, $zero, $zero	# clear d
		add	$s5, $zero, $zero					

		addi	$t0, $zero, 0xFF	# $t0 stores the biggest 4-bit number
		add	$t3, $zero, $zero	# $t3 stores the position (in bits) of the working element
		
	
loop:		and	$t1, $s0, $t0		# load 8 bits of $s0 (an element of a) into $t1
		and	$t2, $s2, $t0		# load 8 bits in corresponding section of $s2 (an element of b) into $t2
		srlv	$t1, $t1, $t3		# shift right $t1 by the value stored in $t3 to prevent overflow
		srlv	$t2, $t2, $t3		# shift right $t2 by the value stored in $t3 to prevent overflow
		mult	$t1, $t2		# multiply these two 8-bit values
		mflo 	$t1			# load the data in $lo into $t1
		sllv	$t1, $t1, $t3		# shift left $t1 back to the previous working position
		add	$s4, $s4, $t1		# store the result to the destination register
		
		and	$t1, $s1, $t0		# load 8 bits of $s1 (an element of a) into $t1
		and	$t2, $s3, $t0		# load 8 bits in corresponding section of $s3 (an element of b) into $t2
		srlv	$t1, $t1, $t3		# shift right $t1 by the value stored in $t3 to prevent overflow
		srlv	$t2, $t2, $t3		# shift right $t2 by the value stored in $t3 to prevent overflow
		mult	$t1, $t2		# multiply these two 8-bit values and store the value in $lo
		mflo 	$t1			# load the data in $lo into $t1
		sllv	$t1, $t1, $t3		# shift left $t1 back to the previous working position
		add	$s5, $s5, $t1		# store the result to the destination register
		
		sll	$t0, $t0, 16		# shift $t0 left 8 bit to move to the position of the next element
		addi	$t3, $t3, 16		# increase $t3 8 bits to point to the position of the next element
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
		
