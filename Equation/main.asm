;-------------------------------------------------------------------------------
; MSP430 Assembler Code Template for use with TI Code Composer Studio
;
;
;-------------------------------------------------------------------------------
            .cdecls C,LIST,"msp430.h"       ; Include device header file

;-------------------------------------------------------------------------------
            .text                           ; Assemble into program memory
            .retain                         ; Override ELF conditional linking
                                            ; and retain current section
            .retainrefs                     ; Additionally retain any sections
                                            ; that have references to current
                                            ; section
;-------------------------------------------------------------------------------
RESET       mov.w   #__STACK_END,SP         ; Initialize stackpointer
StopWDT     mov.w   #WDTPW|WDTHOLD,&WDTCTL  ; Stop watchdog timer
Lab2        mov.w   #10, R4                  ; Load "a" into R4
;-------------------------------------------------------------------------------
                                            ; Main loop here
                                                                                       ; Main loop here

CLEAR       clr     R5                      ;clear the entire register
            clr     R6                      ;clear the entire register
            clr     R7                      ;clear the entire register
            clr     R8                      ;clear the entire register
            clr     R9                      ;clear the entire register
            clr     R10                     ;clear the entire register
            clr     R11                     ;clear the entire register
            clr     R12                     ;clear the entire register
            clr     R13                     ;clear the entire register
            clr     R14                     ;clear the entire register
            clr     R15                     ;clear the entire register

YCALC 		mov.w   #-3, R7                 ;the Y calculation part of your program taking value of “a” as an input and returning result (Y) in R5
			mov.w   R4, R8                  ;R8 - counter R4 = 10
			call    #MULT_N                 ;multiplies "3*a" and stores in R9
			add.w   #2, R9                  ;adds 2 to R9
			mov.w   R9, R7                  ;moves total to R7
			mov.w   R9, R8                  ;moves total to R8
			call    #MULT_N					;calculates (-3*a + 2)^2
			mov.w   R9, R6					;moves Y to R6

XCALC 		mov.w   #3, R8 				    ;XCALC - the X calculation part of your program taking value of “a” as an input and returning result (X) in R4
			mov.w   R4, R7					;moves 10 to R7 for SUMloop
			call    #ABSOLUTE               ;fixes i if negative
     		mov.w   R7, R11                 ;R11 = X loop counter and i
LOOP 		mov.w   R11, R7                 ;moves i to R7 for multiplication!!!!!!!!!!!!!!!!!!!!!!!!!!!
			mov.w   #3, R8 				    ;re-initialization of coefficient '3'
			call    #MULT_N                 ;calculates "3*i" and stores in R9
			mov.w   R9, R12                 ;moves product of "3*i" to R12
			mov.w   #5, R8                  ;moves 5 to R8 for "5*i"
			call    #MULT_N                 ;calculates "5*i"
			mov.w   #10, R7                 ;denominator for the X
			mov.w	R9,R8					;moves the result from mutiplication to R8 for divison
			call    #DIVIDE                 ;calculates fraction and stores in R9
			cmp.w	R7,R8					;compares R7-denom to R9-numerator which does R9= R9-R7
			jn		NXTLINE				    ;jumps to ceiling if negative
NXTLINE		call	#CEILING				;goes to ceiling function if
			call    #FACTORIAL              ;final value stored in R9
			add.w   R9, R12                 ;3*i + [5*i/10]! -> stored in R12
			add.w   R12, R5                 ;adds and stores new SUM on each iteration of i
			dec.w   R11                     ;decrements counter for SUMLoop
			cmp.w 	#-1, R11				;loop until i != -1
			jne     LOOP                    ;goes back to beggining of loop
			jeq		FCALC

FCALC 		mov.w   R5, R8					;the final part of your program taking inputs from R4 and R5, and returning result (F) in R7
			mov.w   R6, R7
			call    #DIVIDE
;------------------------------------------------------------------------------MOVING FINAL RESULTS TO PROPER REGISTERS
			mov.w	R5,R4					;moves X to R4
			mov.w	R6,R5					;moves Y to R5
			mov.w   R9, R6                  ;moves quotient of the F= X/Y result to R7
			mov.w	R8,R7					;moves the remainder of F= X/Y to R7

MAINLOOP	jmp 	MAINLOOP

;-------------------------------------------------------------------------------
DIVIDE 		call	#UNDEFINED				;checks if the denomintor is zero whch makes it undefined R8=Numerator, R7=Denominator
			cmp.w	#0xFFFF,R7
			jeq		MAINLOOP				;jumps to main loop because there is nothing else to do
			jz		DONE
			call	#TEST_ZERO				;test if the numerator or denominator are negative R8=Numerator, R7=Denominator
			tst.w	R9
			jz		DONE
			call	#TEST_NEG				; test if either term to divde is negative
			clr		R9
			call 	#ABSOLUTE
LOOP_DIV	cmp.w	R7,R8					;compares if numerator less than denominator R8 = R7(DENOM)-R8(NUMERATOR)
			jhs		SUBTRACT
			cmp.w	#1,R15					;R15 - flag for the amount of negatives we got
			jne 	END_DIV
			inv.w 	R9						;inverts quotient for the first step in making 2's compliment
			inc.w	R9						;adds one to the quotient to perform second step in performing 2's compliment
END_DIV		ret								; return to main
SUBTRACT	sub.w   R7,R8					;R8=R8-R7
			inc.w 	R9
			jmp 	LOOP_DIV
;--------------------------------------------------------------------------------------------------------
ABSOLUTE    tst.w	R7						;begining of absolute value subroutine
			jn 		INVERSE
			jmp		DONE
INVERSE		inv.w   R7
			inc.w	R7
DONE		ret
;--------------------------------------------------------------------------------------------------------
CEILING 	cmp.w 	#0, R8        			;R8-0
			jnz		UPDATEQ					;jumps if R8>0
			ret
UPDATEQ		inc.w	R9
			ret
;--------------------------------------------------------------------------------------------------------
UNDEFINED	tst.w	R7						;test if the denominator is negative
			jnz		NOT_UNDEF
			mov.w	#0xFFFF,R5
			mov.w	#0xFFFF,R6
			mov.w	#0xFFFF,R7
NOT_UNDEF   ret
;--------------------------------------------------------------------------------------------------------
FACTORIAL	tst.w	R9						;begining of factorial function
			jz		ZERO_J
			jn		NEG_J
			cmp.w   #1, R9
			jeq     ZERO_J					;if 1!, just return R9 = 1 without MULT_N
			mov.w 	R9,R7					;moves the value stored in R13 to R7 for multiplication
			mov.w	R9,R8					;moves the value stored in R13 to R8 for multiplication
			mov.w	R9,R10					;counter for factorial loop
LOOPFACT	dec.w	R10
			mov.w	R10,R8					;re-intializing factorial counter for MULT_N
			cmp.w	#1,R8
			jeq		DONELOOP
			call	#MULT_N
			mov.w	R9,R7 					;R9 is the result of the MULT_N, key element for doing factorial
			jmp		LOOPFACT
DONELOOP	ret

ZERO_J		mov.w	#1,R9
			ret

NEG_J		mov.w 	#0,R9
			ret
;--------------------------------------------------------------------------------------------------------
MULT_N		call	#TEST_ZERO				;test if one of the terms to multiply is zero
			cmp.w	#0,R9					;compares if R9 is zero which means that one of the terms is zero
			jeq		FINISH
			call	#TEST_NEG				;begining of multiplication subroutine
			clr.w	R9
SLOOP		add.w	R7,R9
			dec.w	R8
			cmp.w 	#0,R8
			jne		SLOOP
			cmp.w	#1,R15					;R15 - flag for the amount of negatives we got
			jne 	FINISH
			inv.w 	R9						;inverts word for the first step in making 2's compliment
			inc.w	R9						;adds one to the word to perform second step in performing 2's compliment
FINISH		ret
;--------------------------------------------------------------------------------------------------------
TEST_ZERO	tst.w	R7						;tests if either terms are zero and if so sets the result to zero
			jz		R_ZERO
			tst.w	R8
			jz		R_ZERO
			mov.w	#1,R9					;sets a flag too show that are either one of our termz
			jmp		DNE
R_ZERO		mov.w	#0,R9
DNE			ret
;--------------------------------------------------------------------------------------------------------
TEST_NEG	clr.w	R15						;begining of test function; R15 = 0 - no negatives, R15=1 - 1 negative, R15=2 - 2 negatives
			clr.w   R14
			inc.w	R14						;counter for test function
			tst.w 	R7						;test if R7 is negative
			jn		STEST_NEG				;jumps if R7 is negative

CHECK		inc.w 	R14
			tst.w	R8
			jn		STEST_NEG
			jmp		CHECKDONE

STEST_NEG	inc.w	R15						;specifies how many negtive number we have
			cmp.w	#2, R14
			jne		CHECK

CHECKDONE	cmp.w 	#0, R15
			jz 		DONE_TST
			tst.w	R7
			jn		CHECK_C

CHECK_BACK	tst.w	R8
			jn 		CHECK_C2
			jmp		DONE_TST

CHECK_C		inv.w	R7
			inc.w	R7
			jmp		CHECK_BACK

CHECK_C2	inv.w 	R8
			inc.w	R8
DONE_TST	ret
;-------------------------------------------------------------------------------
;           Stack Pointer definition
;-------------------------------------------------------------------------------
            .global __STACK_END
            .sect 	.stack

;-------------------------------------------------------------------------------
;           Interrupt Vectors
;-------------------------------------------------------------------------------
            .sect   ".reset"                ; MSP430 RESET Vector
            .short  RESET
