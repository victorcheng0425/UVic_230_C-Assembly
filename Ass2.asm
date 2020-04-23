
; Assignment2.asm
;
; Created: 10/9/2019 10:58:36 AM
; Author : Victor Cheng
;

.cseg
.org 0
	;following codes are using for array initalization
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;following variables are using for array initalization, r16-25 are occupied 
	.def row = r16
	.def col = r17
	.def count = r18
	.def max_row = r19
	.def max_col = r20
	.def one = r21
	.def zero = r22
	.def temp1 = r23 
	.def temp2 = r24
	.def goback = r25 ; used to go back to previous row, grab array[x-10] and arr[x-11] and add them together in order to get the certain value

	ldi ZH, high(array) ;get array address
	ldi ZL, low(array)

	ldi count, 0
	ldi goback, 11
	ldi temp1, 0
	ldi temp2, 0
	ldi one, 1
	ldi zero, 0
	ldi row, 0
	ldi col, 0
	ldi max_row, 10
	ldi max_col, 10
	
create_array:
	cpi col, 0
	breq set1
	cp row, col
	breq set1
	brlo set0
	sub ZL, goback ;go back to the previous row and get the value
	sbc ZH, zero ;subtract ZH with 0 and carry
	ld temp1, Z
	ldd temp2, Z+1
	ADD temp1, temp2
	ADD ZL, goback ; go back to orginial spaces
	ADC ZH, zero;add carry if it exist
	inc col
	cp max_col, col
	brlo new_row
	st Z+, temp1
	clr temp1
	clr temp2
	rjmp create_array

set1: 
	st Z+, one
	inc col
	rjmp create_array

set0:
	inc col
	cp max_col, col
	brlo new_row
	st Z+, zero
	rjmp create_array

new_row: ;set col back to one
	inc row
	cp max_row, row
	breq User_input_code
	clr col
	rjmp create_array

;for debug ;donedone: rjmp donedone
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
User_input_code:
;following codes are using for User input
;;;;;initalize the variable
	.def buttonflag = r21
	reset:
	ldi ZH, high(array) ;get array address again
	ldi ZL, low(array)
	ldi row, 0
	ldi col, 0
	ldi r18, 0 ;reuse r18,r19,r20
	ldi r19, 0 ;
	ldi r20, 0
	ldi r21, 0
	ldi r23, 0
	ldi r24, 0

;First initialize built-in Analog to Digital Converter
; initialize the Analog to Digital converter
	ldi r23, 0x87 ; r23.24 used for temp value
	sts ADCSRA, r23
	ldi r23, 0x40
	sts ADMUX, r23
;initialize PORTB and PORTL for ouput
	ldi	r23, 0b00001010
	out DDRB, r23
	ldi	r23, 0b10101010
	sts DDRL, r23

	
input_loop:
	ld r23, Z
	call turn_bits
	;ldi r24, 0b10000000 ; turn on value 1 led
	;sts PORTL, r24


check:
	call check_button  ; check to see if a button is pressed
	cpi  buttonflag, 1    ; Register R26 is set to 1 if "right" or "up" pressed
	breq button1
;b_2:
	cpi  buttonflag, 2
	breq button2
;b_3:
	cpi buttonflag, 3
	breq button3
;b_4:
	cpi buttonflag, 4
	breq button4
	rjmp check



button1:
	cp col, row
	breq check
	inc col
	ADIW ZL, 1
	ld r23, Z
	call turn_bits
;call delay
;call delay
;call delay
	rjmp check

button2:
	cp col, row
	breq check
	dec row
	SUBI ZL, 10
	ld r23, Z
	call turn_bits
;call delay
;call delay
;call delay
	rjmp check

button3:
	cpi row, 9
	breq check
	inc row
	ADIW ZL, 10
	ld r23, Z
	call turn_bits
;call delay
;call delay
;call delay
	rjmp check

button4:
	cpi col, 0
	breq check
	dec col
	SUBI ZL, 1
	ld r23, Z
	call turn_bits
call delay
call delay
call delay
	rjmp check



turn_bits:
	ldi r24, 0x00       ; turn off LED 
	out PORTB, r24
	sts PORTL, r24
	clr buttonflag
	lsr r23
	BRCS L7
cp1:	
	lsr r23
	BRCS L5
cp2:
	lsr r23
	BRCS L3
cp3:
	lsr r23
	BRCS L1
cp4:
	clr r24
	lsr r23
	BRCS B3
cp5:
	lsr r23
	BRCS B1
cp6:
	ret

L7: 
	ori r24, 0b10000000
	sts PORTL, r24
	;call delay
	rjmp cp1

L5:	
	ori r24, 0b00100000
	sts PORTL, r24
	;call delay
	rjmp cp2

L3:
	ori r24, 0b00001000
	sts PORTL, r24
	;call delay
	rjmp cp3
L1:
	ori r24, 0b00000010
	sts PORTL, r24
	;call delay
	rjmp cp4
B3:
	ori r24, 0b00001000
	out PORTB, r24
	;call delay
	rjmp cp5
B1:
	ori r24, 0b00000010
	out PORTB, r24
	;call delay
	clr r24
	rjmp cp6

; Below are the LCD keypad shield values for different buttons.
;
.equ RIGHT	= 0x032 ; the same for both LCD keypad board
; board v1.0 
;.equ UP     = 0x0FA
;.equ DOWN   = 0x1C2
;.equ LEFT   = 0x28A
;.equ SELECT = 0x352
;
;
; board v1.1 
.equ UP	    = 0x0C3
.equ DOWN	= 0x17C
.equ LEFT	= 0x22B
.equ SELECT	= 0x316


check_button:
	lds	r23, ADCSRA	  ; get the current value of SDRA
	ori r23, 0x40     ; set the ADSC bit to 1 to initiate conversion
	sts	ADCSRA, r23
	call delay
	call delay
	call delay
	call delay
	call delay
wait:
	lds r23, ADCSRA
	andi r23, 0x40     ; see if conversion is over by checking ADSC bit
	brne wait          ; ADSC will be reset to 0 is finished

	call delay
	call delay
	call delay
	call delay
	call delay
	call delay
	call delay

	; read the value available as 10 bits in ADCH:ADCL
	lds r23, ADCL  ;use temp variable r23,24 for storing ADC
	lds r24, ADCH  

	ldi r20, high(RIGHT)
	ldi r19, low(RIGHT)
	cp r23, r19
	cpc r24, r20
	brlo rightb

	ldi r20, high(UP)
	ldi r19, low(UP)
	cp r23, r19
	cpc r24, r20
	brlo upb

	ldi r20, high(DOWN)
	ldi r19, low(DOWN)
	cp r23, r19
	cpc r24, r20
	brlo downb

	ldi r20, high(LEFT)
	ldi r19, low(LEFT)
	cp r23, r19
	cpc r24, r20
	brlo leftb

skip: ret
	
rightb: 
	ldi buttonflag, 1
	rjmp skip

upb:
	ldi buttonflag, 2
	rjmp skip

downb:

	ldi buttonflag, 3
	rjmp skip

leftb:

	ldi buttonflag, 4
	rjmp skip

	

delay:
;
; TODO: Write a delay loop.
;
; Nested delay loop
	ldi r23, 0x01
x1:
		ldi r24, 0xFF
x2:
			ldi r25, 0xFF
x3:
				dec r25
				brne x3
			dec r24
			brne x2
		dec r23
		brne x1

	ret

done: rjmp done


.dseg
.org 0x200
array: .byte 100