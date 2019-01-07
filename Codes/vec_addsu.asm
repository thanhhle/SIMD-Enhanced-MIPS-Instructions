# *************************************** 3 4 1   T o p   L e v e l   M o d u l e ***************************************
# File name:		vec_addsu.asm
# Version:		1.0
# Date:			December 5, 2018 
# Programmer:		Thanh Le
#			Steven Chung
#
# Description:		Using a sequence of MIPS instructions, create a new "SIMD Enhanced" instruction that implements
#			a Vector Add Saturated (unsigned) where the syntax is vec_addsu d, a, b. Each vector consists of
#			eight 8-bit elements. When the instruction is executed, each element of a is added to the
#			corresponding element of b. The unsigned-interger (no-wrap) is placed into the corresponding element of d.
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


main:		li	$s0, 0x233C475D		# initialize a with 4 bytes from $s0 and 4 bytes from $s1
		li	$s1, 0x087F196F		
	
		li	$s2, 0x981963C5		# initialize b with 4 bytes from $s2 and 4 bytes from $s3
		li	$s3, 0X5E80B36E
	
		add	$s4, $zero, $zero	# clear d
		add	$s5, $zero, $zero					

		addi	$t0, $zero, 0xFF	# $t0 stores the biggest 8-bit number
		add	$t3, $zero, $zero	# $t3 stores the position (in bits) of the working element
	
loop:		and	$t1, $s0, $t0		# load 8 bits of $s0 (an element of a) into $t1
		and	$t2, $s2, $t0		# load 8 bits in corresponding section of $s2 (an element of b) into $t2
		srlv	$t1, $t1, $t3		# shift right $t1 by the value stored in $t3 to prevent overflow
		srlv	$t2, $t2, $t3		# shift right $t2 by the value stored in $t3 to prevent overflow
		add	$t1, $t1, $t2		# add these two 8-bit values
		slti	$t2, $t1, 0xFF		# check if the result is overflow
		bne	$t2, $zero, noOverFlow1 # if NO OVERFLOW, jump to noOverFlow1
		addi	$t1, $zero, 0xFF	# if OVERFLOW, $t1 is set to FF
		
noOverFlow1:	sllv	$t1, $t1, $t3		# shift left $t1 back to the previous working position
		add	$s4, $s4, $t1		# store the result to the destination register
		
		and	$t1, $s1, $t0		# load 8 bits of $s1 (an element of a) into $t1
		and	$t2, $s3, $t0		# load 8 bits in corresponding section of $s3 (an element of b) into $t2
		srlv	$t1, $t1, $t3		# shift right $t1 by the value stored in $t3 to prevent overflow
		srlv	$t2, $t2, $t3		# shift right $t2 by the value stored in $t3 to prevent overflow
		add	$t1, $t1, $t2		# add these two 8-bit values
	
		slti	$t2, $t1, 0xFF		# check if the result is overflow
		bne	$t2, $zero, noOverFlow2 # if NO OVERFLOW, jump to noOverFlow2
		addi	$t1, $zero, 0xFF	# if OVERFLOW, the result is set to FF

noOverFlow2:	sllv	$t1, $t1, $t3		# shift left $t1 back to the previous working position
		add	$s5, $s5, $t1		# store the result to the destination register
		

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
		
