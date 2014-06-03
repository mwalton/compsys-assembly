#####################################################
### This file is an example MIPS program for CE12 ###
#####################################################

# This file has three example subroutines:
#	1. a subroutine to enable LED5 on the arduino board (not the IO sheild)
#	2. a subroutine to turn on LED5 on the arduino board
#	3. a subroutine to turn off LED5 on the arduino board

# In myprog, first the enable subroutine is called to make LED5 an output
# then, a loop is initiated where we turn the LED on by calling a subroutine,
# then we print a message to the terminal, then we turn the LED off.
# But, the loop happens so quickly, we don't see it blinking! Thats why we 
# need to create a mydelay subroutine.


# This puts the symbol myprog into the symbol table 
.global myprog

# This specifies the instruction part of your program	
.text

# This prevents the assembler from reordering the instructions
.set noreorder

# This specifies where the entry to myprog starts
.ent myprog 

# This is the label of the address for myprog
myprog:

	jal 	EnableLED	# jump to subroutine to enable LED 5 (similar to JSR in LC3)
	nop					# don't forget the nop

# Start a loop that will always repeat
loop:
	
	jal		LEDon		# turn on led
	nop

# The following four lines of code print out a message to the terminal, we use this to help debug
	la		$a0,Serial	
	la		$a1,test        
	jal     _ZN5Print7printlnEPKc     
	nop
	
	jal		LEDoff		# turn off led
	nop
# always jump back to the start of the program
	j      loop
	nop
	
################################
## Subroutine to enable LED 5 ##
################################
EnableLED:
	li 		$t9, 0x1			# li = pseudo op to load an immediate value into a register, 1 => $t9 
	li 		$t8, 0xbf886140  	# load address of TRISF into $t8 
	sw 		$t9, 4($t8)			# store $t9 into address defined by $t8 plus an offset of 4
								# this clears TRISF, making LED5 an output
	jr 		$ra					# jr is the return instruction (like RET in LC3), 
								# $ra is the return address (like R7 in LC3)
	nop
	
###########################
# turn on led5 subroutine #
###########################
LEDon:
	li 		$t9, 0x1
	li 		$t8, 0xbf886150		# load address of PORTF into $t8 
	sw 		$t9, 8($t8)			# store $t9 into PORTF with an offset of 8 to turn on LED5
	jr		$ra
	nop
	
###########################
# turn on led5 subroutine #
###########################
LEDoff:
	li 		$t9, 0x1
	li 		$t8, 0xbf886150
	sw 		$t9, 4($t8)			# store $t9 into PORTF with an offset of 4 to turn off LED5	
	jr		$ra
	nop	

# end of myprog
.end myprog 

# data part of the program
.data
hello:	.ascii 	"Hello, world!\0"
test:	.ascii	"This is a test\0"

