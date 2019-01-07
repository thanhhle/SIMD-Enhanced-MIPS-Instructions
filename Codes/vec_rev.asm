# *************************************** 3 4 1   T o p   L e v e l   M o d u l e ***************************************
# File name:		vec_rev.asm
# Version:		1.0
# Date:			December 5, 2018 
# Programmer:		Thanh Le
#			Steven Chung
#
# Description:		Using a sequence of MIPS instructions, create a new "SIMD Enhanced" instruction that implements
#			a Vector Reverse instruction where the syntax is vec_rev d, a. Vector a and d consist of eight
#			8-bit elements. When the instruction is executed, it reverses the order of the elements in vector a
#			and stores the change in vector d
#
# Register usage:   	$s0, $s1, $s2, $s3, $t0, $t1, $t2, $t3, $t4
#
# Notes: 		$s0 and $s1 are assumed to concatenate to indicate vector a
#			$s2 and $s3 are assumed to concatenate to indicate vector d
#			$t0, $t1, $t2, $t3, and $t4 are used to store temporary data
#
# **********************************************************************************************************************



		# *****************************************************************************************************
		# 				   M A I N   C O D E    S E G M E N T 
		# *****************************************************************************************************
		.text	
		.globl	main				# main (must be global)


main:		li	$s0, 0x11223344			# initialize a with 4 bytes from $s0 and 4 bytes from $s1
		li	$s1, 0x55667788		
		
		addi	$t0, $t0, 0xFF000000
		addi	$t3, $t3, 0xFF
		addi	$t4, $t4, 24
		
		add	$s3, $zero, $zero		# clear d
		add	$s4, $zero, $zero
		
loop:		and	$t1, $s0, $t0			# load 8-bit element of upper section of vector a into $t1
		ror	$t2, $t1, $t4			# move the 8-bit element to its reversed position and store in $t2
		and	$t1, $s1, $t3			# load 8-bit element of lower section of vector a into $t1
		rol	$t1, $t1, $t4			# move the 8-bit element to its reversed position and store in $t1
		
		# copy these elements to the destination vector d
		add	$s2, $s2, $t1			
		add	$s3, $s3, $t2
		
		# adjust the pointers
		srl	$t0, $t0, 8
		sll	$t3, $t3, 8
		addi	$t4, $t4, 16
		bne	$t0, $zero, loop		# loop until $t0 is equal to 0

		# Clear $t0, $t1, and $t2 after finishing the execution
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
		
