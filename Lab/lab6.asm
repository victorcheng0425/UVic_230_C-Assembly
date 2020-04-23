;Last Name: Cheng	
;First Name: Chi Tsun
;Stduent number: V00815317
; lab6.asm
; Fall, 2019
.include "m2560def.inc"

;SPH, SPL etc are defined in "m2560def.inc"

	; initialize the stack pointer
.cseg

	ldi r16, 0xFF
	out SPL, r16
	ldi r16, 0x21
	out SPH, r16
	
	;example of passing parameter by reference	
	;call subroutine void strcpy(src, dest)
	;push 1st parameter - src address
	ldi r16, high(src << 1)
	push r16
	ldi r16, low(src <<1)
	push r16

	;push 2nd parameter - dest address
	ldi r16, high(dest)
	push r16
	ldi r16, low(dest)
	push r16

	call strcpy
	pop ZL
	pop ZH
	pop r16
	pop r16

	;Write your code here: call subroutine int strlen(string dest)
	;return value is in r24
	;push parameter dest, note it is in register Z already (line 31, 32)
	push ZH
	push ZL
	call strlength
	pop ZL
	pop ZH
	sts length, r24
	
	
	;Write your code here: call the method strLength
	
	;clear the stack and write the result to length in SRAM
	;Write your code here:
	

done: jmp done

strcpy:
	push r30
	push r31
	push r29
	push r28
	push r26
	push r27
	push r23 ; hold each character read from program memory
	IN YH, SPH ;SP in Y
	IN YL, SPL
	ldd ZH, Y + 14 ; Z <- src address
	ldd ZL, Y + 13
	ldd XH, Y + 12 ; Y <- dest address
	ldd XL, Y + 11

next_char:
	lpm r23, Z+
	st X+, r23
	tst r23
	brne next_char
	pop r23
	pop r27
	pop r26
	pop r28
	pop r29
	pop r31
	pop r30
	ret
	
;One parameter - the address of the string, could be in 
;data (SRAM) memory. The length of the string is
;going to be stored in r24
strlength:
	push r30
	push r31
	push r29
	push r28
	push r26 ;check the value 
	push r27 ;hold the length
	IN YH, SPH
	IN YL, SPL
	ldd ZL, Y+10
	ldd ZH, Y+11

check_char:
	ld r26, Z+ ;check value
	INC r27	;inc r27 after getting the value
	cpi r26, 0 ;if value is 0, break the loop
	brne check_char
	DEC r27
	mov r24, r27
	pop r27
	pop r26
	pop r28
	pop r29
	pop r31
	pop r30
	;write your code here
	ret

src: .db "Hello, world!", 0 ; c-string format

.dseg
.org 0x200
dest: .byte 14
length: .byte 1