# *************************************** 3 4 1   T o p   L e v e l   M o d u l e ***************************************
# File name:		vec_pack.asm
# Version:		1.0
# Date:			December 5, 2018 
# Programmer:		Thanh Le
#			Steven Chung
#
# Description:		Using a sequence of MIPS instructions, create a new "SIMD Enhanced" instruction that implements
#			a Vector Pack instruction where the syntax is vec_pack d, a, b. Vector a and b consist of
#			eight 8-bit elements. Vector d consists of sixteen 4-bit elements. When the instruction is executed,
#			each high element of the vector d is the truncation of the corresponding wider element of a, and
#			each low element of the vector d is the truncation of the corresponding wider element of b.
#
# Register usage:   	$s0, $s1, $s2, $s3, $s4, $s5, $t0, $t1, $t2, $t3
#
# Notes: 		$s0 and $s1 are assumed to concatenate to indicate vector a
#			$s2 and $s3 are assumed to concatenate to indicate vector b
#			$s4 and $s5 are assumed to concatenate to indicate vector d
#			$t1 and $t2 are used to store temporary data
#			$t0 and $t3 are used to point to a specific elements or store value to shift
#			
# **********************************************************************************************************************



		# *****************************************************************************************************
		# 				   M A I N   C O D E    S E G M E N T 
		# *****************************************************************************************************
		.text	
		.globl	main			# main (must be global)


main:		li	$s0, 0x5AFB6C1D		# initialize a with 4 bytes from $s0 and 4 bytes from $s1
		li	$s1, 0xAE5FC041		
	
		li	$s2, 0x52F3A415		# initialize b with 4 bytes from $s2 and 4 bytes from $s3
		li	$s3, 0xA657C849
	
		add	$s4, $zero, $zero	# clear d
		add	$s5, $zero, $zero					

		addi	$t0, $zero, 0xF		# $t2 stores the biggest 4-bit number
		add	$t3, $zero, $zero	# 
	
lower:		# For 32 lower bits of each section of vector d, copy 4 lower bits in each element of vector a and b to each lower element of vector d
		and	$t1, $s1, $t0		# load 4 bits of $s1 (an element of a) into $t1
		and	$t2, $s3, $t0		# load 4 bits in corresponding section of $s3 (an element of b) into $t2
		
		srlv	$t1, $t1, $t3		# shift $t1 to the proper position of the element of destination vector d
		srlv	$t2, $t2, $t3		# shift $t2 to the proper position of the element of destination vector d
		
		add	$s4, $s4, $t1		# copy the value stored in $t1 to vector d
		add	$s5, $s5, $t2		# copy the value stored in $t2 to vector d
		
		sll	$t0, $t0, 8		# adjust the pointer $t0
		addi	$t3, $t3, 4		# adjust the shift value $t3
		bne	$t0, $zero, lower	# loop until $t0 is equal to 0 after being shifted

		add	$t3, $zero, $zero	# reset the value of $t3
		addi	$t0, $zero, 0xF		# reset the value of $t0

		# For 32 higher bits of each section of vector d, copy 4 lower bits in each element of vector a and b to each higher element of vector d
upper:		and	$t1, $s0, $t0		# load 4 bits of $s1 (an element of a) into $t1
		and	$t2, $s2, $t0		# load 8 bits in corresponding section of $s2 (an element of b) into $t2
		
		# shift $t1 to the proper position of the element of destination vector d
		srlv	$t1, $t1, $t3	
		sll	$t1, $t1, 16
		
		# shift $t1 to the proper position of the element of destination vector d
		srlv	$t2, $t2, $t3
		sll	$t2, $t2, 16
		
		add	$s4, $s4, $t1		# copy the value stored in $t1 to vector d
		add	$s5, $s5, $t2		# copy the value stored in $t2 to vector d
		
		sll	$t0, $t0, 8		# adjust the pointer $t0
		addi	$t3, $t3, 4		# adjust the shift value $t3
		bne	$t0, $zero, upper	# loop until $t0 is equal to 0 after being shifted
		
		
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
			
