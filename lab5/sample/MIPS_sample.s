####################################																
#	MIPS SAMPLE CODES AND SYNTAX
# CMPE 12 WINTER 2014
# jur/02/14
####################################

#====================================================================================================================		
	addi	$t4, $0, 0							/* initialize a register to 0*/
	
	la		$t0, msg								/* loading the address of msg. */
																/* $t0 can now be a pointer to the letter you want to access */
	lb		$t1, 0($t0)							/* loading the content of the address pointed to by t0 to t1 */	
	addi	$t0, $t0, 1							/* to go to the next memory space just add 1 to the pointer */

#====================================================================================================================		
# a simple loop.  
#====================================================================================================================
	li		$t0, 10									/* initialize t0 with value 10 to loop 10 times. This will be your loop counter */

loop:														
	addi	$t0, $t0, -1						/* decrement your loop counter */
	beq		$t0, $0, done						/* check if the loop counter is 0. If it is, break out of the loop */
	nop														/* include a nop afer branch */
	j			loop										/* do it again */
	nop														/* it's a jump? include a nop. */
done:														/* the next line to execute when you break out of the loop */

#====================================================================================================================	
# a simple IF-ELSE statement  
#====================================================================================================================

	blt		$t0, $0, lessThan0			/* if t0 is less than 0 go to lessThan0 */
	nop														/* again don't forget your ol' freind nop */
	j			notLess0								/* else, go to notLess0	*/	
	nop

lessThan0:											
	/* "if" clause evaluates to true execute this part of the code */ 
	
notLess0:												
	/* else execute this part of the code*/

#====================================================================================================================	
# a simple print 
#====================================================================================================================

	la      $a0, Serial						/* load address of where to print to */
	la			$a1, msg							/* load address of message to be printed */ 
	jal     _ZN5Print7printlnEPKc	/* print line */
	nop														/* don't forget to add nop after jumps and branches */
	

#====================================================================================================================	
# data declarations 
#====================================================================================================================
.data
msg:			.ascii	"hello world\0" /* an array of characters */
number:		.word	1									/* an integer with value 1 */
char:			.byte 'a'								/* a single character */
array:		.space 20								/* reserve 20 memory spaces */



