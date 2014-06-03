/* Lab 5 Arduino/PIC32 Light Patterns
 * Michael Walton
 * mwwalton@ucsc.edu
 * CMPE12 - SPRING 2014
 * lab5.s
 */
#include <WProgram.h>

	

/* define all global symbols here */
	
.global myprog

	

/* define which section (for example "text")
     
 * does this portion of code resides in. Typically,
     
 * all your code will reside in .text section as
     
 * shown below.
    */
	
.text

	

/* This is important for an assembly programmer. This
     
 * directive tells the assembler that don't optimize
     
 * the order of the instructions as well as don't insert
     
 * 'nop' instructions after jumps and branches.
    */
	
.set noreorder



/*********************************************************************
 
 * main()
 
 * This is where the PIC32 start-up code will jump to after initial
 
 * set-up.
 
********************************************************************/



.ent myprog 
/* directive that marks symbol 'main' as function in ELF
           
 * output
           */



myprog:

	jal 	EnableLEDs	# jump to subroutine to enable LED 5 (similar to JSR in LC3)
	nop					# don't forget the nop
    jal     EnableSwitches
    nop
    jal     LEDallOff
    nop

/* load register a0 with Serial object address */
    la      $a0,Serial
	

/* load register a1 with string constant address */
    la 	$a1,hello
    jal     _ZN5Print7printlnEPKc        
    nop
    la 	$a1,blinkAll
    jal     _ZN5Print7printlnEPKc        
    nop
    la 	$a1,progress
    jal     _ZN5Print7printlnEPKc        
    nop
    la 	$a1,cylon
    jal     _ZN5Print7printlnEPKc        
    nop
    la 	$a1,tetris
    jal     _ZN5Print7printlnEPKc        
    nop

loop:
# get switch 1 state
    li      $a0, 1
    jal     readSwitch
    nop
    beqz    $v0, s1off
    nop
    j       s1on
    nop

s1off:
# get switch 2 state
    li      $a0, 2
    jal     readSwitch
    nop
    beqz    $v0, defaultPattern
    nop
    j       pattern2
    nop

s1on:
# get switch 2 state
    li      $a0, 2
    jal     readSwitch
    nop
    beqz    $v0, pattern1
    nop
    j       pattern3
    nop

# Pattern 1: [1,0] "Progress bar"
pattern1:
    jal   LEDallOff
    nop

    li    $t4, 1
    li    $t5, 8

p1Loop:
    move  $a0,$t4
    jal   LEDon
    nop

    li    $a0, 200
    jal   mydelay
    nop

    sll   $t4, 1
    addi  $t5, -1
    bgtz  $t5, p1Loop
    nop

    j     endPattern
    nop
    
# Pattern 2: [0,1] "Cylon"
pattern2:
    li    $t4, 1
    li    $t5, 7

p2LoopLeft:
    jal   LEDallOff
    nop

    move  $a0,$t4
    jal   LEDon
    nop

    li    $a0, 100
    jal   mydelay
    nop

    sll   $t4, 1
    addi  $t5, -1
    bgtz  $t5, p2LoopLeft
    nop

    li    $t5, 7

p2LoopRight:
    jal   LEDallOff
    nop

    move  $a0,$t4
    jal   LEDon
    nop

    li    $a0, 100
    jal   mydelay
    nop

    sra   $t4, 1
    addi  $t5, -1
    bgtz  $t5, p2LoopRight
    nop

    j     endPattern
    nop


# Pattern 3: [1,1] "Tetris"
pattern3:

    li    $t4, 1
    li    $t5, 11

p3Loop:
    jal   LEDallOff
    nop

    move  $a0,$t4
    jal   LEDon
    nop
    move  $a0,$t4
    sra   $a0, 1
    jal   LEDon
    nop
    move  $a0,$t4
    sra   $a0, 2
    jal   LEDon
    nop

    li    $a0, 200
    jal   mydelay
    nop

    sll   $t4, 1
    addi  $t5, -1
    bgtz  $t5, p3Loop
    nop

    j     endPattern
    nop

defaultPattern:
#turn all LEDs on
    jal     LEDallOn
    nop

# delay for 1 second
    li      $a0, 1000 
    jal     mydelay
    nop

# turn leds off
    jal     LEDallOff
    nop
        
# delay for 1 second
    li      $a0, 1000 
    jal     mydelay
    nop
    j       endPattern
    nop

endPattern:

# endloop
    j       loop
    nop
	

################################
##          Delay Sub         ##
################################
mydelay:
    li      $t0, 0
    lw      $t2, tconst
outerloop:														
    li      $t1, 0
	addi	$t0, $t0, 1						# increment loop counter
	beq		$t0, $a0, done					# if loop counter = a0 break out of the loop
	nop										# include a nop afer branch
innerloop:
    addi    $t1, $t1, 1
    beq     $t1, $t2, outerloop
    nop
    j       innerloop
	nop
done:
	jr 		$ra					# jr is the return instruction, $ra is the return address 
	nop


################################
##   Sub to enable switches   ##
################################
EnableSwitches:
    li      $t0, 0          # accumulator for enabling all leds
    li      $t1, 2          # max index of LEDs
    li      $t2, 128
	la 		$t8, TRISD  	# load address of TRISE into $t8 
swEnaLoop:
    addi    $t0, 1
    sw 		$t2, 8($t8)			# store $t2 into address defined by $t8 plus an offset of 4
    sll     $t2, 1
    beq     $t0, $t1, doneSwEna
    nop
    j       swEnaLoop
    nop

doneSwEna:
    jr 		$ra					# jr is the return instruction (like RET in LC3), 
	nop

################################
##   Sub to read switch a0    ##
################################
readSwitch:
    lw      $t0, PORTD
    lw      $t1, sw1
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
    
################################
## Subroutine to enable LEDS  ##
################################
EnableLEDs:
    li      $t0, 0          # accumulator for enabling all leds
    li      $t1, 8          # max index of LEDs
    li      $t2, 1
	la 		$t8, TRISE  	# load address of TRISE into $t8 
enaLoop:
    addi    $t0, 1
    sw 		$t2, 4($t8)			# store $t0 into address defined by $t8 plus an offset of 4
    sll     $t2, 1
    beq     $t0, $t1, doneEna
    nop
    j       enaLoop
    nop

doneEna:
    jr 		$ra					# jr is the return instruction (like RET in LC3), 
								# $ra is the return address (like R7 in LC3)
	nop
	
###########################
#    turn on LED a0 sub   #
###########################
LEDon:
    la      $t8, PORTE
    sw      $a0, 8($t8)
    jr      $ra
    nop

###########################
#  turn off LED a0 sub    #
###########################
LEDoff:
    la      $t8, PORTE
    sw      $a0, 4($t8)
    jr      $ra
    nop

###########################
#     turn on leds sub   #
###########################
LEDallOn:
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
	jr		$ra
	nop
	
###########################
# turn off led subroutine #
###########################
LEDallOff:
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
	jr		$ra
	nop

.end myprog 
/* directive that marks end of 'main' function and registers
           
 * size in ELF output
           */
	

	

.data
sw1:    .word 0x100
tconst: .word 17000
hello:	.ascii "Welcome! Use switches 1 & 2 to select a pattern\0"
blinkAll: .ascii "0,0: Blink all\0"
progress: .ascii "1,0: Progress Bar\0"
cylon:    .ascii "0,1: Cylon\0"
tetris:   .ascii "1,1: Tetris\0"

