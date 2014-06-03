/* Push a register*/
.macro  push reg
sw      \reg, ($sp)
addi    $sp, $sp, -4
.endm

/* Pop a register*/
.macro  pop reg
addi    $sp, $sp, 4
lw      \reg, ($sp)
.endm
	
#include <WProgram.h>

/* Jump to our customized routine by placing a jump at the vector 4 interrupt vector offset */
.section .vector_4,"xaw"
	j T1_ISR


/* The .global will export the symbols so that the subroutines are callable from main.cpp */
.global PlayNote
.global SetupPort
.global SetupTimer 
.global	ProgramNote
.global	PlayNote
#
/* This starts the program code */
.text
/* We do not allow instruction reordering in our lab assignments. */
.set noreorder

	

/*********************************************************************
 * myprog()
 * This is where the PIC32 start-up code will jump to after initial
 * set-up.
 ********************************************************************/
.ent myprog

# This should setup the output ports 
SetupPort:
    li      $t2, 0b1000
	la 		$t8, TRISD  	# load address of TRISD into $t8 
    sw 		$t2, 4($t8)			
    
	jr $ra
	nop

# This should configure Timer 1 and the corresponding interrupts,
#  but it should not enable the timer.
SetupTimer:
# clear T1CON control bit (15)
    li      $t0, 0b1000000000000000
    la      $t8, T1CON
    sw      $t0, 4($t8)
# clear T1CON TCS control bit (1)
    li      $t0, 0b10
    sw      $t0, 4($t8)

# Set T1CKPS
    li      $t0, 0x30
    sw      $t0, 8($t8)

# Clear TMR1
    li      $t0, 0xFFFF
    la      $t8, TMR1
    sw      $t0, 4($t8)

# Set PR1 (set the period)
    li      $t0, 0x0
    la      $t8, PR1
    sw      $t0, 8($t8)

# Configure inturrupt
# Set T1IP (inturrupt priority)
    li      $t0, 0x1C
    la      $t8, IPC1
    sw      $t0, 8($t8)

# Clear T1IF (clear prior interrupt)
    li      $t0, 0b10000
    la      $t8, IFS0
    sw      $t0, 4($t8)

# set T1IE (enable interrupts)
    li      $t0, 0b10000
    la      $t8, IEC0
    sw      $t0, 8($t8)

	jr $ra
	nop

# This should should enable the user to assign a tune to a button
ProgramNote:
	push $ra


    jal EnableTimer
    nop

 testSound:
    li      $a0, 0
    jal     analogRead
    nop

    # convert analog freq to period
    move    $a0, $v0
    jal     Freq2Period
    nop

    # clear the period of the timer
    la      $t8, PR1
    li      $t0, 0b1111111111111111
    sw      $t0, 4($t8)
    # set the new period
    sw      $a0, 8($t8)

    la      $a0, Serial
    move    $a1, $v0
    li      $a2, 10

    jal     _ZN5Print7printlnEii
    nop

    j testSound
    nop

	pop $ra
	jr	$ra
	nop
	

# Plays custom tone */	
PlayNote:
	push $ra


	jr	$ra
	nop
	

	
# This procedure is not required, but I found it easier this way. It is not called from main.cpp. */
# This turns on the timer to start counting */	
EnableTimer:
# Clear T1IF (clear prior interrupt)
    li      $t0, 0b10000
    la      $t8, IFS0
    sw      $t0, 4($t8)
	
# clear T1CON control bit (15)
    li      $t0, 0b1000000000000000
    la      $t8, T1CON
    sw      $t0, 8($t8)
	jr $ra
	nop
	
# This procedure is not required, but I found it easier this way. It is not called from main.cpp. */
# This turns off the timer from counting */
DisableTimer:
	
	jr $ra
	nop
	
# This converts frequency to period */
Freq2Period:
    li      $v0, 0
    beqz    $a0, ReturnPeriod
    nop
    
    li      $v0, 80000000
    li      $t1, 256
    li      $t2, 2
    
    mul     $t0, $a0, $t1
    mul     $t0, $t0, $t2
    
    div     $v0, $t0

ReturnPeriod:	
	jr	$ra
	nop
	

	
# The ISR should toggle the speaker output value and then clear and re-enable the interrupts. */
T1_ISR:
    
    li      $t2, 0b1000
	la 		$t8, PORTD  	# load address of TRISD into $t8 
    sw 		$t2, 12($t8)			

# Clear T1IF (clear prior interrupt)
    li      $t0, 0b10000
    la      $t8, IFS0
    sw      $t0, 4($t8)
# Clear TMR1
    li      $t0, 0xFFFF
    la      $t8, TMR1
    sw      $t0, 4($t8)
	
	eret
	nop

.end myprog /* directive that marks end of 'myprog' function and registers
           * size in ELF output
           */
					 
.data
freq1:	.word	0
freq2:	.word	0
freq3:	.word	0
freq4:	.word	0
hello:	.ascii "Hello world! Im interrupting\0"


