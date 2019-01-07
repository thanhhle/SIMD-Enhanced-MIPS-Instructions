# *************************************** 3 4 1   T o p   L e v e l   M o d u l e ***************************************
# File name:		vec_srl.asm
# Version:		1.0
# Date:			December 5, 2018 
# Programmer:		Thanh Le
#			Steven Chung
#
# Description:		Using a sequence of MIPS instructions, create a new "SIMD Enhanced" instruction that implements
#			a Vector Shift Right Logically instruction where the syntax is vec_srl d, a, b.
#			Vector a and d consist of eight 8-bit elements. When the instruction is executed, vector a is
#			shifted right logically by the number of elements stored in b.
#
# Register usage:   	$s0, $s1, $s2, $s3, $s4, $t0, $t1, $t2
#
# Notes: 		$s0 and $s1 are assumed to concatenate to indicate vector a
#			$s3 and $s4 are assumed to concatenate to indicate vector d
#			$s2 is assumed to indicate the number of 8-bit element to be shifted
#			$t0, $t1, and $t2 are used to store temporary data
#
# **********************************************************************************************************************



		# *****************************************************************************************************
		# 				   M A I N   C O D E    S E G M E N T 
		# *****************************************************************************************************
		.text	
		.globl	main			# main (must be global)


main:		li	$s0, 0xABCDEF01			# initialize a with 4 bytes from $s0 and 4 bytes from $s1
		li	$s1, 0x23456789		
		
		li	$s2, 2				# initialize the number of bits to be shifted
	
		add	$s3, $zero, $zero		# clear d
		add	$s4, $zero, $zero	
	
		addi	$t0, $zero, 8			# store the value of 8 in $t4
		
		mult	$s2, $t0			# calculate the number of bits to be shifted
		mflo	$t1				# store the number of bits to be shifted in $t1
		slti	$t2, $t1, 32			# compare if the number of shifted bits is less than 32
		bne	$t2, $zero, upper		# jump to upper if the number of shifted is less than 32

		# If the number of bits to be shifted is greater or equal to 32
lower:		addi	$t1, $t1, -32			# calculate the number of bits to be shifted in lower 32-bit section
		srlv	$s4, $s0, $t1			# shift right logically the lower 32-bit section of vector a
		j	clearReg
		
		# If the number of bits to be shifted is less than 32
upper:		srlv	$s3, $s0, $t1			# shift right the upper 32-bit section of vector a
							#   and store the result in the upper 32-bit section of vector d
		sllv	$t2, $s0, $t1			# take the bits of the upper section that are truncated after being shifted
		srlv	$s4, $s1, $t1			# shift left the lower 32-bit section of vector a by same number of bits
							#   that is shifted in the upper section to leave space for the missed bits
		add	$s4, $s4, $t2			# copy the missed bits to the lower 32-bit section of vector d
	
		# Clear $t0, $t1, and $t2 after finishing the execution
clearReg:	add	$t0, $zero, $zero
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
		
