; Lab 3 Than's Not My Number!
; Michael Walton
; mwwalton@ucsc.edu
; CMPE12 - SPRING 2014
; lab3.asm

; This program doesn't like your favorite number


; The code will begin in memory at the address
; specified by .orig <number>.

	.ORIG   x3000


START:
; clear all registers
	AND	R0, R0, 0
	AND	R1, R0, 0
	AND	R2, R0, 0
	AND	R3, R0, 0
	AND	R4, R0, 0

; print out a greeting (printf(greeting))
	LEA	R0, GREETING
	PUTS

; get a user-entered number (R0 = GETC)
; echo it back right away (otherwise it isn't visible)
	GETC

; store entered number (USERINPUT = R0)
	ST	R0, INCHAR

; print out the user's number printf("%d",USERINPUT)
	OUT

;Convert ASCII to numeric
	ADD R1, R0, -16
	ADD R1, R1, -16
	ADD R1, R1, -16

; Make sure the value is not something else
    BRzp ITSPOSORZERO
    LEA R0, NAN
    PUTS
    BR START
    
ITSPOSORZERO
    BRp ITSPOSITIVE
    LEA R0, INZERO
    PUTS
    BR START

ITSPOSITIVE
    LD R2, N57
    ADD R3, R0, R2
    BRnz ITSVALID
    LEA R0, NAN
    PUTS
    BR START

ITSVALID
	ST R1, INNUM	;INNUM = R0

; tell the user how much you hate their number printf(HATENUM)
	LEA	R0, HATENUM
	PUTS
	LD	R0, INCHAR
	OUT
	LEA	R0, EXCLPT
	PUTS

; LOOP: iterate over 1 - 9 (for(int i = 1; i<10; ++i))
; LIMIT = 10:
	AND R0, R0, 0	; R0 = 0
	ADD R0, R0, 10	; R0 += 10
	ST R0, LIMIT	; LIMIT = R0

; INDEX = 1:
	AND R0, R0, 0	; R0 = 0
	ADD R0, R0, 1	; R0 += 1
	ST R0, INDEX	; index = R0

; INDEX < LIMIT:
LOOP	LD R1, LIMIT	; R1 = LIMIT
	NOT R1, R1
	ADD R1, R1, 1	; R3 = -1 * R3
	ADD R0, R0, R1	; R0 = INDEX - LIMIT
	BRzp LOOPEND	; if ( INDEX - LIMIT >= 0) {break;}

; if (INDEX != INNUM)
	LD R0, INDEX	; load INDEX
	LD R1, INNUM	; Load input number
	NOT R1, R1
	ADD R1, R1, 1
	ADD R2, R0, R1	; R2 = R0 - R1
	BRz SKIP	; IF INDEX == INNUM

; CONVERT INDEX TO ASCII
	ADD R0, R0, 15
	ADD R0, R0, 15
	ADD R0, R0, 15
	ADD R0, R0, 3
	OUT

	SKIP

; INDEX++
	LD R0, INDEX	; load INDEX
	ADD R0, R0, 1	; R0++
	ST R0, INDEX	; INDEX = R0
	BR LOOP		; goto TEST
LOOPEND

; stop the processor
	HALT


; data declarations follow below

; strings
GREETING:	.STRINGZ	"\nWelcome to my first LC3 Program!.\nPlease enter your favorite number:\n"
NAN:        .STRINGZ    "\nThats not even a number!\n"
INZERO:     .STRINGZ    "\nNo Zeros allowed!  Lets keep it natural.\n"
HATENUM:	.STRINGZ	"\nREALLY?!? I hate "
EXCLPT:		.STRINGZ	"!!!\n"

; variables
INCHAR:		.FILL	0
INNUM:		.FILL	0
INDEX:		.FILL	0
LIMIT:		.FILL	0
N57:       .FILL   -57


; end of program
	.END
