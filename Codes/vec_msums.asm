# *************************************** 3 4 1   T o p   L e v e l   M o d u l e ***************************************
# File name:		vec_msums.asm
# Version:		1.0
# Date:			December 5, 2018 
# Programmer:		Thanh Le
#			Steven Chung
#
# Description:		Using a sequence of MIPS instructions, create a new "SIMD Enhanced" instruction that implements
#			a Vector Multiply Sum Saturated where the syntax is vec_msums d, a, b, c. Vector a and b consist of
#			eight 8-bit elements. Vector c and d consist of four 16-bit elements. When the instruction is executed,
#			each element of vector d is the 16-bit sum of the corresponding elements of vector c and the 16-bit "temp"
#			products of the 8-bit elements of vector a and vector b wwhich overlap the positions of that element in c. 
#			The sum is performed with 16-bit saturating addition (no-wrap)
#
# Register usage:   	$s0, $s1, $s2, $s3, $s4, $s5, $s6, $s7, $t0, $t1, $t2, $t3, $t4, $v0, $v1
#
# Notes: 		$s0 and $s1 are assumed to concatenate to indicate vector a
#			$s2 and $s3 are assumed to concatenate to indicate vector b
#			$s4 and $s5 are assumed to concatenate to indicate vector c
#			$s6 and $s7 are assumed to concatenate to indicate vector d
#			$t1 and $t2 are used to store temporary data
#			$t0, $t3, $t4, and $t5 are used to point to a specific elements or bits
#			$v0 and $v1 are used to store working result
#			
#
# **********************************************************************************************************************



		# *****************************************************************************************************
		# 				   M A I N   C O D E    S E G M E N T 
		# *****************************************************************************************************
		.text	
		.globl	main			# main (must be global)


main:		li	$s0, 0x230CF14D		# initialize a with 4 bytes from $s0 and 4 bytes from $s1
		li	$s1, 0x5C7F191A		
	
		li	$s2, 0xA30C5BFD		# initialize b with 4 bytes from $s2 and 4 bytes from $s3
		li	$s3, 0XC5FFC9EE
		
		li	$s4, 0x609E19F7		# initialize c with 4 bytes from $s4 and 4 bytes from $s5
		li	$s5, 0x45670766
	
		add	$s6, $zero, $zero	# clear d
		add	$s7, $zero, $zero					

		addi	$t0, $zero, 0xFF	# $t2 stores the biggest 8-bit number
		add	$t3, $zero, $zero	
		addi	$t4, $zero, 0xFFFF
		add	$t5, $zero, $zero
	
loop:		# For 32 lower bits, multiply odd elements of vector a and vector b
		and	$t1, $s0, $t0		# load 8 bits of $s0 (an element of a) into $t1
		and	$t2, $s2, $t0		# load 8 bits in corresponding section of $s2 (an element of b) into $t2
		srlv	$t1, $t1, $t3		# shift right $t1 by the value stored in $t3 to prevent overflow
		srlv	$t2, $t2, $t3		# shift right $t2 by the value stored in $t3 to prevent overflow
		mult	$t1, $t2		# multiply these two 8-bit values
		mflo 	$t1			# load the data in $lo into $t1
		sllv	$t1, $t1, $t3		# shift left $t1 back to the previous working position
		add	$v0, $v0, $t1		# store the result to the destination register
		
		# For 32 upper bits, repeat the logic to calculate the odd mutiplication of upper 32 bits of vector a and vector b 
		and	$t1, $s1, $t0		
		and	$t2, $s3, $t0		
		srlv	$t1, $t1, $t3		
		srlv	$t2, $t2, $t3		
		mult	$t1, $t2		
		mflo 	$t1			
		sllv	$t1, $t1, $t3		
		add	$v1, $v1, $t1		
		
		# Move the $t0 to the position of even position
		sll	$t0, $t0, 8		
		
		# For 32 lower bits, multiply even elements of vector a and b and add the result to the corresponding element of vector c
		and	$t1, $s0, $t0		# load 8 bits of $s0 (an element of a) into $t1
		and	$t2, $s2, $t0		# load 8 bits in corresponding section of $s2 (an element of b) into $t2
		srlv	$t1, $t1, $t3		# shift right $t1 by the value stored in $t3 to prevent overflow
		srlv	$t2, $t2, $t3		# shift right $t2 by the value stored in $t3 to prevent overflow
		mult	$t1, $t2		# multiply these two 8-bit values
		mflo 	$t1			# load the data in $lo into $t1
		addi	$t3, $t3, 16		# adjust the pointer $t3
		srlv	$t1, $t1, $t3		# shift right the result to the proper position of the element
		addi	$t3, $t3, -16		# move the pointer $t3 back to the previous position
	
		and	$t2, $v0, $t4		# load the result of the odd multiplication into $t2
		srlv	$t1, $t1, $t5		# shift right $t1 by the value stored in $t5 to prevent overflow
		srlv	$t2, $t2, $t5		# shift right $t2 by the value stored in $t5 to prevent overflow
		add	$t1, $t1, $t2		# add the even multiplication and odd multiplication
		
		addi	$t2, $zero, 0xFFFF	# store the biggest 16-bit valus in $t2
		slt	$t2, $t1, $t2		# check if the result is overflow
		bne	$t2, $zero, noOverFlow1	# if NO OVERFLOW, jump to noOverFlow1
		addi	$t1, $zero, 0xFFFF	# if OVERFLOW, the result is set to FFFF
		
noOverFlow1:	and	$t2, $s4, $t4		# load 16 bits in corresponding section of $s2 (an element of c) into $t2
		srlv	$t2, $t2, $t5		# shift right $t2 by the value stored in $t3 to prevent overflow
		add	$t1, $t1, $t2		# add the 16-bit sum of the odd and even multiplications of a and b to the 16-bit element of c
		
		addi	$t2, $zero, 0xFFFF	# store the biggest 16-bit valus in $t2
		slt	$t2, $t1, $t2		# check if the result is overflow
		bne	$t2, $zero, noOverFlow2	# if NO OVERFLOW, jump to noOverFlow2
		addi	$t1, $zero, 0xFFFF	# if OVERFLOW, the result is set to FFFF
		
noOverFlow2:	sllv	$t1, $t1, $t5		# shift left $t1 back to the previous working position
		add	$s6, $s6, $t1		# store the result to the proper element of the destination vector d
		
		# For 32 upper bits, repeat the logic to calculate the even mutiplication, add it to the odd multiplication, and add the result to the conrrespoding element of vector c
		and	$t1, $s1, $t0		
		and	$t2, $s3, $t0		
		srlv	$t1, $t1, $t3		
		srlv	$t2, $t2, $t3		
		mult	$t1, $t2		
		mflo 	$t1			
		addi	$t3, $t3, 16		
		srlv	$t1, $t1, $t3		
		addi	$t3, $t3, -16		
	
		and	$t2, $v1, $t4		
		srlv	$t1, $t1, $t5		
		srlv	$t2, $t2, $t5		
		add	$t1, $t1, $t2		
		
		addi	$t2, $zero, 0xFFFF	
		slt	$t2, $t1, $t2
		bne	$t2, $zero, noOverFlow3
		addi	$t1, $zero, 0xFFFF
		
noOverFlow3:	and	$t2, $s5, $t4
		srlv	$t2, $t2, $t5
		add	$t1, $t1, $t2
		
		addi	$t2, $zero, 0xFFFF
		slt	$t2, $t1, $t2
		bne	$t2, $zero, noOverFlow4
		addi	$t1, $zero, 0xFFFF
		
noOverFlow4:	sllv	$t1, $t1, $t5
		add	$s7, $s7, $t1
		
		
		# Adjust the bits value of $t0, $t3, $4, and $t5 to point to the next working element
		sll	$t0, $t0, 8		
		addi	$t3, $t3, 16		
		sll	$t4, $t4, 16		
		addi	$t5, $t5, 16
		bne	$t0, $zero, loop	# loop until the $t0 is shift all to the left, and its value become 0
		
		
		# Clear $t0, $t1, $t2, and $t3 after finishing the execution
		add	$t0, $zero, $zero
		add	$t1, $zero, $zero
		add	$t2, $zero, $zero
		add	$t3, $zero, $zero
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
			
