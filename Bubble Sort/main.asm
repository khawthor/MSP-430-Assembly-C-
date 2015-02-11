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
;Intilizing the pointers to arrays:
ARY1		.set	0x0200					;set the address of Array1_Unsorted
ARY2		.set	0x022C					;set the address of Array2_Unsorted
ARY1S		.set	0x0258					;set the address of Array1_Sorted
ARY2S		.set	0x0284					;set the address of Array2_Sorted
;-------------------------------------------------------------------------------
RESET       mov.w   #__STACK_END,SP         ; Initialize stackpointer
StopWDT     mov.w   #WDTPW|WDTHOLD,&WDTCTL  ; Stop watchdog timer
;-------------------------------------------------------------------------------
                                            ; Main loop here
            call 	#ARRAYSETUP				;this will intialize all the 4 arrays
LAB3		clr.w	R4
			clr.w   R5
			clr.w   R6
			clr.w   R7
			clr.w   R8
			clr.w	R10
			clr.w	R11
			clr.w   R12

SORT1		mov.w	#ARY1S, R6				;store the current pointer to the 1st element
			call	#SORT
			mov.w	#ARY1S, R7					;store the address of the sorted ARY1

SORT2		mov.w	#ARY2S, R6				;store the current pointer to the 1st element
			call	#SORT
			mov.w	#ARY2S, R8					;store the address of the sorted ARY2S
MAINLOOP	jmp     MAINLOOP
;-------------------------------------------------------------------------------
;Subroutines:

SORT		mov.w	@R6, R4					;store n in R4
			mov.w	R6,R10					;keeps copy of orginal array address
			incd.w	R6						;put the address of R6 at the beginning of the array
FLAG_LOOP	clr.w	R9

LOOP		mov.w   R6, R5					;move the address of R6 ---> R5
			incd.w	R6						;set R6 as a 1 cell ahead of R5
			call	#COMPARE
			dec.w	R4
			cmp.w	#1, R4					;stop at one instead of zero because you will go outside bounds of array otherwise
			jnz		LOOP

			cmp.w	#0,R9					;if flag is 0 that means it went through the whole array and did not swap anything thus it is in order
			jnz		RESETVALUES
			ret
;-------------------------------------------------------------------------------
RESETVALUES mov.w	R10,R6					;puts the pointer back at beggining of the array will need to change if they change number of elements
			jmp		SORT
;-------------------------------------------------------------------------------
COPY_ARR	mov.w	@R11+, 0(R12)			;copy the content of ARY --> ARYS
			incd.w  R12
			dec.w   R10						;R10-- until R10!=0
			cmp.w   #-1,R10					; need to loop till -1 because there are 10 elements in array plus the counter
			jne  	COPY_ARR
			ret
;-------------------------------------------------------------------------------
COMPARE		cmp.w 	@R5, 0(R6)
			jn		SWAP
			ret
;-------------------------------------------------------------------------------
SWAP		push.w	@R5
			mov.w 	@R6, 0(R5)
			pop.w	0(R6)
			inc.w	R9						;flag indicating that the values have been swapped
			ret
;-------------------------------------------------------------------------------
ARRAYSETUP  mov.w   #ARY1,R4
			mov.w	#10,  0(R4)			;set n = 10 for ARY1
			mov.w	#-5,  2(R4)
			mov.w   #-89, 4(R4)
			mov.w	#15,  6(R4)
			mov.w	#-25, 8(R4)
			mov.w	#89,  10(R4)
			mov.w	#47,  12(R4)
			mov.w	#88,  14(R4)
			mov.w	#2,   16(R4)
			mov.w	#-55, 18(R4)
			mov.w	#1,   20(R4)

			mov.w   #ARY2,   R4
			mov.w	#10,     0(R4)		;set n = 10 for ARY2
			mov.w	#0x00A4, 2(R4)
			mov.w	#0xFFFF, 4(R4)
			mov.w   #0x0005, 6(R4)
			mov.w	#0x008D, 8(R4)
			mov.w	#0x0033, 10(R4)
			mov.w	#0x003C, 12(R4)
			mov.w	#0x0099, 14(R4)
			mov.w	#0xFFFA, 16(R4)
			mov.w	#0x0000, 18(R4)
			mov.w	#0x00A0, 20(R4)

			mov.w   #ARY1, R11				;set the pointer to Unsorted Array 1
			mov.w	@R11, R10				;set the counter (n=10) ---> R10 for copying
			mov.w	#ARY1S, R12				;set the pointer to Sorted Array
			call	#COPY_ARR				;copy the content of ARY1 --> ARY1S

			mov.w   #ARY2, R11				;set the pointer to Unsorted Array 2
			mov.w	@R11, R10				;set the counter (n=10) ---> R10 for copying
			mov.w	#ARY2S, R12				;set the pointer to Sorted Array
			call	#COPY_ARR				;copy the content of ARY2 --> ARY2S

			ret
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
