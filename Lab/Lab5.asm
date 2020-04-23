;
; lab 5
; Name: Victor Cheng 
; Student ID: V00815317



.cseg

	ldi ZH,high(msg<<1)	; initialize index register Z to point to msg in flash memory
	ldi ZL,low(msg<<1) ;Why msg<<1? Because it is word address, each word is 2 bytes, therefore
	                   ;word_address * 2 -> byte address. Recall, in decimal, 12 * 10
					   ;can be done by shift each digit left by one digit, we get 120.
					   ;In binary, 0b01 * 2 can be done by shift each bit left by one digit, we get 0b10

	;write you code here, initialize index register X to point to msg_copy in SRAM
	ldi XH,high(msg_copy)
	ldi XL,low(msg_copy)
	ldi r16, 0	;initialize counter to -1		

next_char:
	;write you code here
	;write a loop, copy each character from flash memory to at msg_copy in SRAM
	;get the length of the string, store it at str_len in SRAM
	inc r16
	lpm r17, Z+
	cpi r17, 0
	breq done
	st X+, r17
	sts str_len, r16
	jmp next_char


	


done:	jmp done

msg: .db "Hello, world!", 0 ; c-string format

.dseg
.org 0x200
msg_copy: .byte 14
str_len: .byte 1
