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
    
# Enable switches, (bits 8-11) BTN1 (b5), BTN2 (b6) & BTN3 (b7)
    li      $t0, 0b111111100000 #bits 5-11
    la      $t8, TRISD
    sw      $t0, 8($t8)
# Enable BTN0 (b7)
    li      $t0, 0b10000000 # bit 7
    la      $t8, TRISF
    sw      $t0, 8($t8)

# Enable LEDs
    li      $t0, 0b11111111 # bits 0-7
    la      $t8, TRISE
    sw      $t0, 4($t8)

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
    jal     EnableTimer
    nop


 testSound:
    li      $a0, 0
    jal     analogRead
    nop
    move    $a0, $v0
# print freq to serial
    la      $a0, Serial
    move    $a1, $v0
    li      $a2, 10

    jal     _ZN5Print7printlnEii
    nop

# convert to period
    li      $a0, 0
    jal     analogRead
    nop
    move    $a0, $v0
    jal     Freq2Period
    nop

# clear the period of the timer
    la      $t8, PR1
    li      $t0, 0b1111111111111111
    sw      $t0, 4($t8)
# set the new period
    sw      $v0, 8($t8)


# if a button is pressed, play the current tone
 
# if button 0
    li      $a0, 0
    jal     readButton
    nop
    beqz    $v0, notB0
    nop
    jal     EnableTimer
    nop
# if switch 1
    li      $a0, 1
    jal     readSwitch
    nop
    beqz    $v0, notS1
    nop

# read freq, conv to period & store
    li      $a0, 0
    jal     analogRead
    nop
    move    $a0, $v0
    jal     Freq2Period
    nop
    sw      $v0, b0note
    
    j       testSound
    nop
notB0:
# if button 1
    li      $a0, 1
    jal     readButton
    nop
    beqz    $v0, notB1
    nop
    jal     EnableTimer
    nop
# if switch 1
    li      $a0, 1
    jal     readSwitch
    nop
    beqz    $v0, notS1
    nop

# read freq, conv to period & store
    li      $a0, 0
    jal     analogRead
    nop
    move    $a0, $v0
    jal     Freq2Period
    nop
    sw      $v0, b1note
    j       testSound
    nop
notB1:
# if button 2
    li      $a0, 2
    jal     readButton
    nop
    beqz    $v0, notB2
    nop
    jal     EnableTimer
    nop
# if switch 1
    li      $a0, 1
    jal     readSwitch
    nop
    beqz    $v0, notS1
    nop

# read freq, conv to period & store
    li      $a0, 0
    jal     analogRead
    nop
    move    $a0, $v0
    jal     Freq2Period
    nop
    sw      $v0, b2note
    j       testSound
    nop
notB2:
# if button 3
    li      $a0, 3
    jal     readButton
    nop
    beqz    $v0, notB3
    nop
    jal     EnableTimer
    nop
# if switch 1
    li      $a0, 1
    jal     readSwitch
    nop
    beqz    $v0, notS1
    nop

# read freq, conv to period & store
    li      $a0, 0
    jal     analogRead
    nop
    move    $a0, $v0
    jal     Freq2Period
    nop
    sw      $v0, b3note
    j       testSound
    nop
notB3:
# else:
    jal     DisableTimer
    nop

notS1:
# check if all the values have been set
    lw      $t0, b0note
    lw      $t1, b1note
    lw      $t2, b2note
    lw      $t3, b3note

    beqz    $t0, testSound
    nop
    beqz    $t1, testSound
    nop
    beqz    $t2, testSound
    nop
    beqz    $t3, testSound
    nop
# done programming, time to play!
    #jal     DisableTimer
    #nop

	pop $ra
	jr	$ra
	nop
	

# Plays custom tone */	
PlayNote:
	push $ra

playMusic:
# if button 0
    li      $a0, 0
    jal     readButton
    nop
    beqz    $v0, noPlayB0
    nop
    lw      $t1, b0note
# clear the period of the timer
    la      $t8, PR1
    li      $t0, 0b1111111111111111
    sw      $t0, 4($t8)
# set the new period
    sw      $t1, 8($t8)

    jal     EnableTimer
    nop
    
    j       playMusic
    nop
noPlayB0:
# if button 1
    li      $a0, 1
    jal     readButton
    nop
    beqz    $v0, noPlayB1
    nop
    lw      $t1, b1note
# clear the period of the timer
    la      $t8, PR1
    li      $t0, 0b1111111111111111
    sw      $t0, 4($t8)
# set the new period
    sw      $t1, 8($t8)

    jal     EnableTimer
    nop
    
    j       playMusic
    nop
noPlayB1:
# if button 2
    li      $a0, 2
    jal     readButton
    nop
    beqz    $v0, noPlayB2
    nop
    lw      $t1, b2note
# clear the period of the timer
    la      $t8, PR1
    li      $t0, 0b1111111111111111
    sw      $t0, 4($t8)
# set the new period
    sw      $t1, 8($t8)

    jal     EnableTimer
    nop
    
    j       playMusic
    nop
noPlayB2:
# if button 3
    li      $a0, 3
    jal     readButton
    nop
    beqz    $v0, noPlayB3
    nop
    lw      $t1, b3note
# clear the period of the timer
    la      $t8, PR1
    li      $t0, 0b1111111111111111
    sw      $t0, 4($t8)
# set the new period
    sw      $t1, 8($t8)

    jal     EnableTimer
    nop
    
    j       playMusic
    nop
noPlayB3:
    
    jal     DisableTimer
    nop
    j       playMusic
    nop

    pop $ra
	jr	$ra
	nop
	

	
# This procedure is not required, but I found it easier this way. It is not called from main.cpp. */
# This turns on the timer to start counting */	
EnableTimer:
# Clear T1IF (clear prior interrupt)
    #li      $t0, 0b10000
   # la      $t8, IFS0
   # sw      $t0, 4($t8)
	
# set T1CON control bit (15)
    li      $t0, 0b1000000000000000
    la      $t8, T1CON
    sw      $t0, 8($t8)
	jr $ra
	nop
	
# This procedure is not required, but I found it easier this way. It is not called from main.cpp. */
# This turns off the timer from counting */
DisableTimer:
	
# Clear T1IF (clear prior interrupt)
   # li      $t0, 0b10000
   # la      $t8, IFS0
   # sw      $t0, 4($t8)
	
# clear T1CON control bit (15)
    li      $t0, 0b1000000000000000
    la      $t8, T1CON
    sw      $t0, 4($t8)
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

################################
##   Sub to read switch a0    ##
################################
readSwitch:
    push    $ra

    lw      $t0, PORTD
    li      $t1, 0x100 # switch 1
    li      $t2, 0

# left shift the switch #1 bit address until we have the right mask

switchLoop:
    addi    $t2, 1
    beq     $a0, $t2, endSwitchLoop
    nop
    sll     $t1, 1
    j       switchLoop
    nop

endSwitchLoop:
    and     $v0, $t0, $t1
    pop     $ra
    jr      $ra
    nop

################################
##   Sub to read button a0    ##
################################
readButton:
    push    $ra

# BTN 0:
    bgtz    $a0, btn123
    nop
    li      $t1, 0b10 # bit 1
    lw      $t0, PORTF
    j       returnButtonState
    nop
# BTN 1-3 
btn123:
    lw      $t0, PORTD
    li      $t1, 0b100000 #button 1 (b5)
    li      $t2, 0

# left shift the switch #1 bit address until we have the right mask

buttonLoop:
    addi    $t2, 1
    beq     $a0, $t2, returnButtonState
    nop
    sll     $t1, 1
    j       buttonLoop
    nop

returnButtonState:
    and     $v0, $t0, $t1
    pop     $ra
    jr      $ra
    nop

################################
##   Sub to Enable IO         ##
################################
enableIO:
    push    $ra
# Enable switches, (bits 8-11) BTN1 (b5), BTN2 (b6) & BTN3 (b7)
    li      $t0, 0b111111100000 #bits 5-11
    la      $t8, TRISD
    sw      $t0, 8($t8)
# Enable BTN0 (b1)
    li      $t0, 0b10 # bit 1
    la      $t8, TRISF
    sw      $t0, 8($t8)

# Enable LEDs
    li      $t0, 0b11111111 # bits 0-7
    la      $t8, TRISE
    sw      $t0, 4($t8)
    
    pop     $ra
    jr      $ra
    nop
###########################
#    turn on LED a0 sub   #
###########################
LEDon:
    push    $ra
    la      $t8, PORTE
    sw      $a0, 8($t8)
    pop     $ra
    jr      $ra
    nop

###########################
#  turn off LED a0 sub    #
###########################
LEDoff:
    push    $ra
    la      $t8, PORTE
    sw      $a0, 4($t8)
    pop     $ra
    jr      $ra
    nop

###########################
#     turn on leds sub   #
###########################
LEDallOn:
    push    $ra
    li      $t0, 0          # accumulator for enabling all leds
    li      $t1, 8          # max index of LEDs
    li      $t2, 1
	la 		$t8, PORTE		# load address of PORTE into $t8 
onLoop:
    addi    $t0, 1
	sw 		$t2, 8($t8)			# store $t0 into PORTF with an offset of 8 to turn on LEDs
    sll     $t2, 1
    beq     $t0, $t1, doneOn
    nop
    j       onLoop
    nop
doneOn:
    pop     $ra
	jr		$ra
	nop
	
###########################
# turn off led subroutine #
###########################
LEDallOff:
    push    $ra
    li      $t0, 0          # accumulator for enabling all leds
    li      $t1, 8          # max index of LEDs
    li      $t2, 1
	la 		$t8, PORTE		# load address of PORTE into $t8 
offLoop:
    addi    $t0, 1
	sw 		$t2, 4($t8)			# store $t9 into PORTF with an offset of 8 to turn on LEDs
    sll     $t2, 1
    beq     $t0, $t1, doneOff
    nop
    j       offLoop
    nop
doneOff:
    pop     $ra
	jr		$ra
	nop


.end myprog /* directive that marks end of 'myprog' function and registers
           * size in ELF output
           */
					 
.data
b0note:	.word	0
b1note:	.word	0
b2note:	.word	0
b3note:	.word	0

