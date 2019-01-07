# *************************************** 3 4 1   T o p   L e v e l   M o d u l e ***************************************
# File name:		vec_repl.asm
# Version:		1.0
# Date:			December 5, 2018 
# Programmer:		Thanh Le
#			Steven Chung
#
# Description:		Using a sequence of MIPS instructions, create a new "SIMD Enhanced" instruction that implements
#			a Vector Replace All instruction where the syntax is vec_repl d, a, b. Vector a and d consist of
#			eight 8-bit elements. Component b is a 8-bit number in hexadecimal. When the instruction is executed,
#			all the 8-bit elements in vector a are replaced by component b. The result is stored in vector d
#
# Register usage:   	$s0, $s1, $s2, $s3, $s4, $t0
#
# Notes: 		$s0 and $s1 are assumed to concatenate to indicate vector a
#			#s2 is used to indicate the 8-bit hexadecimal number of component b
#			$s3 and $s4 are assumed to concatenate to indicate vector d
#			$t0 is used to store temporary data
#
# **********************************************************************************************************************



		# *****************************************************************************************************
		# 				   M A I N   C O D E    S E G M E N T 
		# *****************************************************************************************************
		.text	
		.globl	main				# main (must be global)


main:		li	$s0, 0xAABBCCDD			# initialize a with 4 bytes from $s0 and 4 bytes from $s1
		li	$s1, 0x11223344
		
		li	$s2, 0xE8
		
		add	$s3, $zero, $zero		# clear d
		add	$s4, $zero, $zero	
		
		add	$t0, $zero, $s2			# copy the original value of component b to $t0
		
loop:		add	$s3, $s3, $t0			# copy the value of component b to an element in the upper 32-bit section of vector d
		add	$s4, $s4, $t0			# copy the value of component b to an element in the lower 32-bit section of vector d
		
		sll	$t0, $t0, 8			# shift the $t0 left to the next element
		bne	$t0, $zero, loop		# loop until $t0 is shifted all to the left and is equal to 0


		# Clear $t0, $t1, and $t2 after finishing the execution
		add	$t0, $zero, $zero
		
		# -----------------------------------------------------------------------------------------------------
		# "Due diligence" to return control to the kernel
		# -----------------------------------------------------------------------------------------------------
exit:		ori	$v0, $zero, 10		# $v0 <-- function code for "exit"		
		syscall 			# Syscall to exit


		# *****************************************************************************************************
		# 			 P R O J E C T   R E L A T E D   D A T A   S E C T I O N 
		# *****************************************************************************************************
		.data				# place variables, arrays, and constants, etc. in this area
		
