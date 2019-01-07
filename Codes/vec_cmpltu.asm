# *************************************** 3 4 1   T o p   L e v e l   M o d u l e ***************************************
# File name:		vec_cmpltu.asm
# Version:		1.0
# Date:			December 5, 2018 
# Programmer:		Thanh Le
#			Steven Chung
#
# Description:		Using a sequence of MIPS instructions, create a new "SIMD Enhanced" instruction that implements
#			a Vector Compare Less-Than (unsigned) instruction where the syntax is vec_cmpltu d, a, b.
#			Vector a, b, and d consist of eight 8-bit elements. When the instruction is execute, each element
#			of the result vector d is TRUE (all bits = 1) if the corresponding element of vector a is
#			less than the corresponding element of vector b. Otherwise, the element of result is FALSE
#			(all bits = 0)
#
# Register usage:   	$s0, $s1, $s2, $s3, $s4, $s5, $t0, $t1
#
# Notes: 		$s0 and $s1 are assumed to concatenate to indicate vector a
#			$s2 and $s3 are assumed to concatenate to indicate vector b
#			$s4 and $s5 are assumed to concatenate to indicate vector d
#			$t0 is used to point to a specific elements or bits
#			$t1 and $t2 are used to store temporary data
#
# **********************************************************************************************************************



		# *****************************************************************************************************
		# 				   M A I N   C O D E    S E G M E N T 
		# *****************************************************************************************************
		.text	
		.globl	main			# main (must be global)


main:		li	$s0, 0x5AFB6C1D		# initialize a with 4 bytes from $s0 and 4 bytes from $s1
		li	$s1, 0xA65FC040		
	
		li	$s2, 0x52FBA415			# initialize b with 4 bytes from $s2 and 4 bytes from $s3
		li	$s3, 0xAE5FC841
		
		add	$s4, $zero, $zero		# clear d
		add	$s5, $zero, $zero	

		addi	$t0, $zero, 0xFF
		
loop:		and	$t1, $s0, $t0			# load 8 bits of $s0 (an element of a) into $t1
		and	$t2, $s2, $t0			# load 8 bits in corresponding section of $s2 (an element of b) into $t2
		slt	$t1, $t1, $t2			# check if $t1 is less than $t2
		beq	$t1, $zero, notLessThan1	# jump to notLessThan1 if $t1 is not less than $t2
		
lessThan1:	add	$s4, $s4, $t0			# load 8 bits in corresponding section of $s2 (an element of b) into $t2
		
notLessThan1:	and	$t1, $s1, $t0			# load 8 bits of $s0 (an element of a) into $t1
		and	$t2, $s3, $t0			# load 8 bits in corresponding section of $s3 (an element of b) into $t2
		slt	$t1, $t1, $t2			# check if $t1 is less than $t2
		beq	$t1, $zero, notLessThan2	# jump to notLessThan1 if $t1 is not less than $t2
		
lessThan2:	add	$s5, $s5, $t0			# load 8 bits in corresponding section of $s2 (an element of b) into $t2

notLessThan2:	sll	$t0, $t0, 8			# adjust the pointer $t0 to the next element
		bne	$t0, $zero, loop		# loop until the pointer $t0 is equal to 0
		
		# Clear $t0, $t1, and $t2 after finishing the execution
		add	$t0, $zero, $zero
		add	$t1, $zero, $zero
		add	$t2, $zero, $zero
		
		# -----------------------------------------------------------------------------------------------------
		# "Due diligence" to return control to the kernel
		# -----------------------------------------------------------------------------------------------------
exit:		ori	$v0, $zero, 10		# $v0 <-- function code for "exit"		
		syscall 			# Syscall to exit


		# *****************************************************************************************************
		# 			 P R O J E C T   R E L A T E D   D A T A   S E C T I O N 
		# *****************************************************************************************************
		.data				# place variables, arrays, and constants, etc. in this area
		
