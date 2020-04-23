;
; numDisplay.asm
; 
; Lab excercise: Lab7
;
; Victor Cheng
; V00815317


	.def temp = r16
	
.cseg
.org 0
	; set the stack pointer (we're using functions here)
	ldi temp, 0x21
	out SPH, temp
	ldi temp, 0xFF
	out SPL, temp
	
	; initialize the LCD
	call lcd_init			
	
	; clear the screen
	call lcd_clr			
	
	;if time permit, change it from void display_num() to 
	;                               void display_num( int num)
	call int_to_string

	;Set the cursor at the desired location by specifying the row and column number
	; hint: call lcd_gotoxy
	; remember to push and pop the function parameters - x and y
	
	push r16

	call lcd_clr

	ldi r16, 0x00
	push r16
	ldi r16, 0x00
	push r16
	call lcd_gotoxy
	pop r16
	pop r16

	;Display the digits
	; hint: call lcd_puts
	; remember to push and pop the function parameters - string address for display

	ldi r16, high(num)
	push r16
	ldi r16, low(num)
	push r16
	call lcd_puts
	pop r16
	pop r16

	pop r16


lp:	jmp lp

	.undef temp
	
; function that converts an 8-bit unsigned integer to a c-string 
int_to_string:
	.def dividend=r0
	.def divisor=r1
	.def quotient=r2
	.def tempt=r21
	.def char0=r3
	;preserve the values of the registers
	push dividend
	push divisor
	push quotient
	push tempt
	push char0
	push ZH
	push ZL

	;store '0' in char0
	ldi tempt, '0'
	mov char0, tempt
	;Z points to first character of num in SRAM
	ldi ZH, high(num)
	ldi ZL, low(num)
	adiw ZH:ZL, 3 ;Z points to null character
	clr tempt 
	st Z, tempt ;set the last character to null
	sbiw ZH:ZL, 1 ;Z points the last digit location

	;initialize values for dividend, divisor
	ldi tempt, 132
	mov dividend, tempt
	ldi tempt, 10
	mov divisor, tempt
	
	clr quotient
	digit2str:
		cp dividend, divisor
		brlo finish
		division:
			inc quotient
			sub dividend, divisor
			cp dividend, divisor
			brsh division
		;change unsigned integer to character integer
		add dividend, char0
		st Z, dividend;store digits in reverse order
		sbiw r31:r30, 1 ;Z points to previous digit
		mov dividend, quotient
		clr quotient
		jmp digit2str
	finish:
	add dividend, char0
	st Z, dividend ;store the most significant digit

	;restore the values of the registers
	pop ZL
	pop ZH
	pop char0
	pop tempt
	pop quotient
	pop divisor
	pop dividend
	ret
	.undef dividend
	.undef divisor
	.undef quotient
	.undef tempt
	.undef char0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.dseg
num: 	.byte 4


;
; Include the HD44780 LCD Driver for ATmega2560
;
; This library has it's own .cseg, .dseg, and .def
; which is why it's included last, so it would not interfere
; with the main program design.
#define LCD_LIBONLY
.include "lcd.asm"
