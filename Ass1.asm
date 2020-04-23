;
; CSC 230: Assignment 1
;  
; YOUR NAME GOES HERE: Victor Cheng V00815317
;	Date: 9/20/2019
;
; This program generates each number in the Collatz sequence and stops at 1. 
; It retrieves the number at which to start the sequence from data memory 
; location labeled "input", then counts how many numbers there are in the 
; sequence (by generating them) and stores the resulting count in data memory
; location labeled "output". For more details see the related PDF on conneX.
;
; Input:
;  (input) Positive integer with which to start the sequence (8-bit).
;
; Output: 
;  (output) Number of items in the sequence as 16-bit little-endian integer.
;
; The code provided below already contains the labels "input" and "output".
; In the AVR there is no way to automatically initialize data memory, therefore
; the code that initializes data memory with values from program memory is also
; provided below.
;
.cseg
.org 0
	ldi ZH, high(init<<1)		; initialize Z to point to init
	ldi ZL, low(init<<1)
	lpm r0, Z+					; get the first byte
	sts input, r0				; store it in data memory
	lpm r0, Z					; get the second byte
	sts input+1, r0				; store it in data memory
	clr r0

;*** Do not change anything above this line ***

;****
; YOUR CODE GOES HERE:
;
	.def count_l = r16 ;initalize count variable, lower byte
	.def count_u = r17 ;count variable, upper byte
	.def odd = r18 ;initalize odd variable
	.def upper_b = r20 ;store upper bytes
	.def lower_b = r21 ;store lower bytes
	.def storeval_l = r22;store value if it is 16bit, for lower bytes value
	.def storeval = r23;store temp value
	.def storeval_u = r24;store value if it is 16bit, for upper bytes value

	lds lower_b, input
	lds upper_b, input+1
	ldi count_l, 0 ;set lower count as 0
	ldi count_u, 0; set upper byte count as 0
	ldi odd, 0b00000001
	ldi storeval_l, 0
	ldi storeval_u, 0
	ldi r26, 1 ;set r26 to 1 for adding count number
	
	

	program:
	ldi storeval, 0 ;set it to 0 for further purpose
	ADD count_l, r26 ;add 1 to count
	ADC count_u, storeval ;add 0 to upper byte count to get carry
	cpi upper_b, 0; ;compare upper bype input if it is zero or not
	brne straight_to_operation ;if upper not equal to 0, means the number is big, straight to operation
	cp lower_b, odd ;compare lower bype input and 1
	breq end ; if input == 1, end the program
	straight_to_operation:
	mov storeval, lower_b ;copy input to storeval, storeval is the temp location for storing data temporary
	AND storeval, odd ;set the first bit to 1 if it's odd number, 0 if it's even number
	cp storeval, odd
	breq oddfunction
	lsr upper_b ;upper shift left
	ror lower_b ;lower shift left with carry in bit 7
	rjmp program

	oddfunction: 
	ldi storeval, 0;set the storeval back to 0 for later purpose
	mov storeval_l, lower_b
	mov storeval_u, upper_b
	ADD lower_b, storeval_l
	ADC upper_b, storeval_u
	ADD lower_b, storeval_l
	ADC upper_b, storeval_u
	ADD lower_b, r26 ;add 1 to lower bype
	ADC upper_b, storeval ;add 0 to upper bype to get carry
	rjmp program

	end: 
	sts output, count_l
	sts output+1, count_u
;
; YOUR CODE FINISHES HERE
;****

;*** Do not change anything below this line ***

done:	jmp done

; This is the constant for initializing the "input" data memory location
; Note that program memory must be specified in double-bytes (words).
init:	.db 0x07, 0x00

; This is in the data memory segment (i.e. SRAM)
; The first real memory location in SRAM starts at location 0x200 on
; the ATMega 2560 processor. Locations below 0x200 are reserved for
; memory addressable registers and I/O
;
.dseg
.org 0x200
input:	.byte 2
output:	.byte 2