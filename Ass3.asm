;
; Assignment3.asm
;
; Created: 11/6/2019 4:32:32 PM
; Author : Victor Cheng
;


.org 0x0000
	jmp setup

.org 0x0028
	jmp timer1_ISR
    
.org 0x0072

.def char0 = r3
.def buttonflag = r21
.def blinkflag = r22
.def count_seq = r1
.def count_flag = r2

main_loop:	
	;call lcd_clr
	ldi ZH, high(pointer)
	ldi ZL, low(pointer)
	;display n=000*   SPD:00
	;higest n
	ldi r16, 0x00
	push r16
	ldi r16, 0x03
	push r16
	call lcd_gotoxy
	pop r16
	pop r16

	ld r17, Z
	;ldi r16, ' '
	;cpse r17, r16
	add r17, char0
	push r17
	rcall lcd_putchar
	pop r17

	;middle n
	ldi r16, 0x00
	push r16
	ldi r16, 0x04
	push r16
	call lcd_gotoxy
	pop r16
	pop r16

	ldd r17, Z+1
	;ldi r16, ' '
	;cpse r17, r16
	add r17, char0
	push r17
	rcall lcd_putchar
	pop r17

	;lower n
	ldi r16, 0x00
	push r16
	ldi r16, 0x05
	push r16
	call lcd_gotoxy
	pop r16
	pop r16

	ldd r17, Z+2
	;ldi r16, ' '
	;cpse r17, r16
	add r17, char0
	push r17
	rcall lcd_putchar
	pop r17

	;display *, to start the program
	ldi r16, 0x00
	push r16
	ldi r16, 0x06
	push r16
	call lcd_gotoxy
	pop r16
	pop r16

	ldd r17, Z+3
	;ldi r16, ' '
	;cpse r17, r16
	push r17
	rcall lcd_putchar
	pop r17

	;dislay speed
	ldi r16, 0x00
	push r16
	ldi r16, 14
	push r16
	call lcd_gotoxy
	pop r16
	pop r16

	ldd r17, Z+4
	;ldi r16, ' '
	;cpse r17, r16
	add r17, char0
	push r17
	rcall lcd_putchar
	pop r17
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  not verify yet
	ldi r16, 0x01
	push r16
	ldi r16, 0x04
	push r16
	call lcd_gotoxy
	pop r16
	pop r16

	ldi r16, high(cnt_pointer)
	push r16
	ldi r16, low(cnt_pointer)
	push r16
	call lcd_puts
	pop r16
	pop r16

	ldi r16, 0x01
	push r16
	ldi r16, 10
	push r16
	call lcd_gotoxy
	pop r16
	pop r16

	ldi r16, high(v_pointer)
	push r16
	ldi r16, low(v_pointer)
	push r16
	call lcd_puts
	pop r16
	pop r16
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;check button and blink LCD here;;;;;;;;;;;;;;;
	;call blink_char
	call check_button  ; check to see if a button is pressed

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
jump_loop:
rjmp main_loop


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

wait:
	cpi blinkflag, 1
	breq blink_jmp;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;blink
	ldi r16, 0b00000001
	eor blinkflag, r16
continue:
	lds r23, ADCSRA
	andi r23, 0x40     ; see if conversion is over by checking ADSC bit
	brne wait          ; ADSC will be reset to 0 is finished
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

	;ldi r20, 0
	;ldi r19, 0
	;cp r23, r19
	;cpc r24, r20
	;breq no_button

no_button:
	clr buttonflag
skip: 	
	;clr buttonflag
	ret

blink_jmp: rjmp blink

rightb: 
	cpi buttonflag, 1
	breq skip
	ldi buttonflag, 1
	cpi YL, 4
	breq skip
	adiw YL, 1
	rjmp skip
upb:
	cpi buttonflag, 2
	breq skip
	ldi buttonflag, 2
	ld r20, Y
	cpi r20, 9
	breq set_zero
	cpi r20, '*'
	breq star_start
	inc r20
	st Y, r20
	rjmp skip
set_zero:
	ldi r20, 0
	st Y, r20
	rjmp skip
downb:
	cpi buttonflag, 3
	breq skip
	ldi buttonflag, 3
	ld r20, Y
	cpi r20, 0
	breq set_nine
	cpi r20, '*'
	breq star_start
	dec r20
	st Y, r20
	rjmp skip
set_nine:
	ldi r20, 9
	st Y, r20
	rjmp skip
leftb:
	cpi buttonflag, 4
	breq skip
	ldi buttonflag, 4
	cpi YL, 0
	breq skip
	subi YL, 1
	rjmp skip
;enable interrupt when press start
star_start: 
	ldi r20, 0
	mov count_seq, r20
	mov count_flag, r20
	; enable interrupts (the I bit in SREG)
	sei	
	rjmp skip

blink:
	ldi r16, 3   ;add 3, blink n
	ldi r18, 10  ;add 10, blink SPD: "0"

	mov r17, YL
	cpi r17, 0x04
	breq add_14
	rjmp add_3
add_14:
	add r17, r18
	rjmp display
add_3:
	add r17, r16
display:
	call delay
	ldi r16, 0x00
	push r16
	push r17
	call lcd_gotoxy
	pop r16
	pop r16
	
	lds r17, Char_two
	push r17
	rcall lcd_putchar
	pop r17
	call delay

	rjmp continue

setup:
	; initialize the stack pointer (we are using functions!)
	ldi r16, high(RAMEND)
	out SPH, r16
	ldi r16, low(RAMEND)
	out SPL, r16
	
	call timer1_setup

	; initialize the LCD
	call lcd_init			
	; clear the screen
	call lcd_clr
	; name_p to name
	ldi r16, high(name)
	push r16
	ldi r16, low(name)
	push r16
	ldi r16, high(name_p << 1)
	push r16
	ldi r16, low(name_p << 1)
	push r16
	call str_init
	pop r16
	pop r16
	pop r16
	pop r16
	;display name
	call lcd_clr
	ldi r16, 0x00
	push r16
	ldi r16, 0x00
	push r16
	call lcd_gotoxy
	pop r16
	pop r16

	; Now display name on the first line
	ldi r16, high(name)
	push r16
	ldi r16, low(name)
	push r16
	call lcd_puts
	pop r16
	pop r16

	;class_p to class
	ldi r16, high(class)
	push r16
	ldi r16, low(class)
	push r16
	ldi r16, high(class_p << 1)
	push r16
	ldi r16, low(class_p << 1)
	push r16
	call str_init
	pop r16
	pop r16
	pop r16
	pop r16
	;display class
	;call lcd_clr
	ldi r16, 0x01
	push r16
	ldi r16, 0x00
	push r16
	call lcd_gotoxy
	pop r16
	pop r16

	; Now display class on the first line
	ldi r16, high(class)
	push r16
	ldi r16, low(class)
	push r16
	call lcd_puts
	pop r16
	pop r16

	call delay_name
	call lcd_init	
	call lcd_clr
	
	;n_p to n
	ldi r16, high(n)
	push r16
	ldi r16, low(n)
	push r16
	ldi r16, high(n_p << 1)
	push r16
	ldi r16, low(n_p << 1)
	push r16
	call str_init
	pop r16
	pop r16
	pop r16
	pop r16
	;display class
	;call lcd_clr
	ldi r16, 0x00
	push r16
	ldi r16, 0x01
	push r16
	call lcd_gotoxy
	pop r16
	pop r16

	; Now display class on the first line
	ldi r16, high(n)
	push r16
	ldi r16, low(n)
	push r16
	call lcd_puts
	pop r16
	pop r16

	;SPD_p to SPD
	ldi r16, high(SPD)
	push r16
	ldi r16, low(SPD)
	push r16
	ldi r16, high(SPD_p << 1)
	push r16
	ldi r16, low(SPD_p << 1)
	push r16
	call str_init
	pop r16
	pop r16
	pop r16
	pop r16
	;display SPD
	ldi r16, 0x00
	push r16
	ldi r16, 0x0A
	push r16
	call lcd_gotoxy
	pop r16
	pop r16

	; Now display SPD on the first line
	ldi r16, high(SPD)
	push r16
	ldi r16, low(SPD)
	push r16
	call lcd_puts
	pop r16
	pop r16

	;cnt_p to cnt
	ldi r16, high(cnt)
	push r16
	ldi r16, low(cnt)
	push r16
	ldi r16, high(cnt_p << 1)
	push r16
	ldi r16, low(cnt_p << 1)
	push r16
	call str_init
	pop r16
	pop r16
	pop r16
	pop r16
	;display cnt
	ldi r16, 0x01
	push r16
	ldi r16, 0x00
	push r16
	call lcd_gotoxy
	pop r16
	pop r16

	; Now display SPD on the first line
	ldi r16, high(cnt)
	push r16
	ldi r16, low(cnt)
	push r16
	call lcd_puts
	pop r16
	pop r16


	;v_p to v
	ldi r16, high(value)
	push r16
	ldi r16, low(value)
	push r16
	ldi r16, high(value_p << 1)
	push r16
	ldi r16, low(value_p << 1)
	push r16
	call str_init
	pop r16
	pop r16
	pop r16
	pop r16
	;display v
	ldi r16, 0x01
	push r16
	ldi r16, 0x08
	push r16
	call lcd_gotoxy
	pop r16
	pop r16

	; Now display v on the first line
	ldi r16, high(value)
	push r16
	ldi r16, low(value)
	push r16
	call lcd_puts
	pop r16
	pop r16

	;intalize n=000*   SPD:00
	ldi r16, 0
	ldi ZH, high(pointer)
	ldi ZL, low(pointer)

	st Z+, r16
	st Z+, r16
	st Z+, r16
	ldi r17, '*'
	st Z+, r17
	st Z, r16

	;Z used to update data, Y used to let button change data
	ldi YH, high(pointer)
	ldi YL, low(pointer)

	;create '0' to convert int to char
	ldi r16, '0'
	mov char0, r16

	ldi r16, ' '
	sts Char_two, r16
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;     new add, not verify yet
	;initalize v_pointer to v:_ _ _ _ _ 0
	ldi ZH, high(v_pointer)
	ldi ZL, low(v_pointer)
	st Z+, r16
	st Z+, r16
	st Z+, r16
	st Z+, r16
	st Z+, r16
	ldi r16, '0'
	st Z+, r16
	ldi r16, 0
	st Z, r16
	;initalize cnt_pointer to cnt:_ _ 0
	ldi ZH, high(cnt_pointer)
	ldi ZL, low(cnt_pointer)
	ldi r16, ' '
	st Z+, r16
	st Z+, r16
	ldi r16, '0'
	st Z+, r16
	ldi r16, 0
	st Z, r16
	;initalize v_pointer to v:_ _ _ _ _ 0 ;;;;;;;;initalize cnt_pointer to cnt:_ _ 0 ;;;;;;;;;;;;;;;;;;;;;;

	;let blinkflag set to 0
	clr blinkflag

	;First initialize built-in Analog to Digital Converter
	; initialize the Analog to Digital converter
	ldi r16, 0x87 ; r23.24 used for temp value
	sts ADCSRA, r16
	ldi r16, 0x40
	sts ADMUX, r16

	ldi r16, 0
	mov r2, r16 ;set count_flag
	mov r1, r16 ;set count_seq to 0
	jmp main_loop


;9 = 1/16 sec. (max. speed of advancing to the next value)
;8 = 1/8 sec.
;7 = 1/4 sec.
;6 = 1/2 sec. ( = 2 Hz)
;5 = 1.0 sec. ( = 1 Hz)
;4 = 1.5 sec.
;3 = 2.0 sec. ( = 0.5 Hz)
;2 = 2.5 sec.
;1 = 3.0 sec
.equ TIMER1_DELAY = 46875
.equ TIMER2_DELAY = 39063
.equ TIMER3_DELAY = 31250
.equ TIMER4_DELAY = 23438
.equ TIMER5_DELAY = 15625
.equ TIMER6_DELAY = 7813
.equ TIMER7_DELAY = 3906
.equ TIMER8_DELAY = 1953
.equ TIMER9_DELAY = 977

.equ TIMER1_MAX_COUNT = 0xFFFF
.equ TIMER1_COUNTER_INIT=TIMER1_MAX_COUNT-TIMER1_DELAY
.equ TIMER2_COUNTER_INIT=TIMER1_MAX_COUNT-TIMER2_DELAY
.equ TIMER3_COUNTER_INIT=TIMER1_MAX_COUNT-TIMER3_DELAY
.equ TIMER4_COUNTER_INIT=TIMER1_MAX_COUNT-TIMER4_DELAY
.equ TIMER5_COUNTER_INIT=TIMER1_MAX_COUNT-TIMER5_DELAY
.equ TIMER6_COUNTER_INIT=TIMER1_MAX_COUNT-TIMER6_DELAY
.equ TIMER7_COUNTER_INIT=TIMER1_MAX_COUNT-TIMER7_DELAY
.equ TIMER8_COUNTER_INIT=TIMER1_MAX_COUNT-TIMER8_DELAY
.equ TIMER9_COUNTER_INIT=TIMER1_MAX_COUNT-TIMER9_DELAY
timer1_setup:	
	; timer mode	
	ldi r16, 0x00		; normal operation
	sts TCCR1A, r16

	; prescale 
	; Our clock is 16 MHz, which is 16,000,000 per second
	;
	; scale values are the last 3 bits of TCCR1B:
	;
	; 000 - timer disabled
	; 001 - clock (no scaling)
	; 010 - clock / 8
	; 011 - clock / 64
	; 100 - clock / 256
	; 101 - clock / 1024
	; 110 - external pin Tx falling edge
	; 111 - external pin Tx rising edge
	ldi r16, (1<<CS12)|(1<<CS10)	; clock / 1024
	sts TCCR1B, r16

	; set timer counter to TIMER1_COUNTER_INIT (defined above)
	ldi r16, high(TIMER1_COUNTER_INIT)
	sts TCNT1H, r16 	; must WRITE high byte first 
	ldi r16, low(TIMER1_COUNTER_INIT)
	sts TCNT1L, r16		; low byte
	
	; allow timer to interrupt the CPU when it's counter overflows
	ldi r16, 1<<TOV1
	sts TIMSK1, r16

	; enable interrupts (the I bit in SREG)
	;sei	
	CLI ;disable interrupt
	ret

timer1_ISR:
	CLI
	push r16
	push r17
	push r18
	lds r16, SREG
	push r16

	ldi ZH, high(pointer)
	ldi ZL, low(pointer)
	ldd r16, Z+4

	cpi r16, 0
	breq jmp_point
	cpi r16, 9
	breq timer1
	cpi r16, 8
	breq timer2
	cpi r16, 7
	breq timer3
	cpi r16, 6
	breq timer4
	cpi r16, 5
	breq timer5
	cpi r16, 4
	breq timer6
	cpi r16, 3
	breq timer7
	cpi r16, 2
	breq timer8
	cpi r16, 1
	breq timer9
jmp_point:
	rjmp end_interrupt
timer1:
	ldi r16, high(TIMER1_COUNTER_INIT)
	sts TCNT1H, r16 	; must WRITE high byte first 
	ldi r16, low(TIMER1_COUNTER_INIT)
	sts TCNT1L, r16		; low byte
	rjmp start_interrupt
timer2:
	ldi r16, high(TIMER2_COUNTER_INIT)
	sts TCNT1H, r16 	; must WRITE high byte first 
	ldi r16, low(TIMER2_COUNTER_INIT)
	sts TCNT1L, r16		; low byte
	rjmp start_interrupt
timer3:
	ldi r16, high(TIMER3_COUNTER_INIT)
	sts TCNT1H, r16 	; must WRITE high byte first 
	ldi r16, low(TIMER3_COUNTER_INIT)
	sts TCNT1L, r16		; low byte
	rjmp start_interrupt
timer4:
	ldi r16, high(TIMER4_COUNTER_INIT)
	sts TCNT1H, r16 	; must WRITE high byte first 
	ldi r16, low(TIMER4_COUNTER_INIT)
	sts TCNT1L, r16		; low byte
	rjmp start_interrupt
timer5:
	ldi r16, high(TIMER5_COUNTER_INIT)
	sts TCNT1H, r16 	; must WRITE high byte first 
	ldi r16, low(TIMER5_COUNTER_INIT)
	sts TCNT1L, r16		; low byte
	rjmp start_interrupt
timer6:
	ldi r16, high(TIMER6_COUNTER_INIT)
	sts TCNT1H, r16 	; must WRITE high byte first 
	ldi r16, low(TIMER6_COUNTER_INIT)
	sts TCNT1L, r16		; low byte
	rjmp start_interrupt
timer7:
	ldi r16, high(TIMER7_COUNTER_INIT)
	sts TCNT1H, r16 	; must WRITE high byte first 
	ldi r16, low(TIMER7_COUNTER_INIT)
	sts TCNT1L, r16		; low byte
	rjmp start_interrupt
timer8:
	ldi r16, high(TIMER8_COUNTER_INIT)
	sts TCNT1H, r16 	; must WRITE high byte first 
	ldi r16, low(TIMER8_COUNTER_INIT)
	sts TCNT1L, r16		; low byte
	rjmp start_interrupt
timer9:
	ldi r16, high(TIMER9_COUNTER_INIT)
	sts TCNT1H, r16 	; must WRITE high byte first 
	ldi r16, low(TIMER9_COUNTER_INIT)
	sts TCNT1L, r16		; low byte
	rjmp start_interrupt
	;;;;;	;;;;;call seq;;;;;;

start_interrupt:
	push r16
	ldi ZH, high(pointer)
	ldi ZL, low(pointer)
	ld r16, Z
	push r16
	ldd r16, Z+1
	push r16
	ldd r16, Z+2
	push r16
	call Collatz_sequence
	pop r16
	pop r16
	pop r16
	pop r16
	;;;;;call seq;;;;;;
end_interrupt:
	pop r16
	sts SREG, r16
	pop r18
	pop r17
	pop r16

	reti

	;take parameters (high_n, mid_n, low_n), one decimal number in one byte
Collatz_sequence:
	push r22
	push r23
	push r24
	push r25
	push r16
	push r17
	push r18
	push r19
	push r30
	push r31
	push r26
	push r27

	.def count = r22 ;initalize count variable, lower byte
	.def value_h = r23 ;store upper bytes
	.def value_m = r24;store middle bytes
	.def value_l = r25 ;store lower bytes

	.def temp = r16
	.def temp_h = r17;store value if it is 16bit, for lower bytes value
	.def temp_m = r18
	.def temp_l = r19;store value if it is 16bit, for upper bytes value

;check if first time
	ldi temp, 1
	cp r1, temp
	breq grab

	inc r1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	ldi count, 0
	ldi temp, 0
	ldi temp_h, 0
	ldi temp_m, 0
	ldi temp_l, 0

	in ZH, SPH
	in ZL, SPL
	
	ldd value_l, Z+16
	ldd value_m, Z+17
	ldd value_h, Z+18

;convert value_h, x100
;use count(zero) tempeorary to add zero
ldi temp, 0 ;keep check of the loop
convert_value_h:
	cpi temp, 100
	breq convert_value_m
	add temp_l, value_h
	adc temp_m, count
	adc temp_h, count
	inc temp
	rjmp convert_value_h

;convert value_m, x10
convert_value_m:
	cpi temp, 110
	breq convert_value_l
	add temp_l, value_m
	adc temp_m, count
	adc temp_h, count
	inc temp
	rjmp convert_value_m

convert_value_l:
	add temp_l, value_l
	adc temp_m, count
	adc temp_h, count

	;reset temp, and copy the binary back to value_l:m:h
	ldi temp, 0
	mov value_l, temp_l
	mov value_m, temp_m
	mov value_h, temp_h
	;inc count
	rjmp start

grab:  
	;grab value and count from memory (int)
	ldi ZL, low(vv_pointer)
	ldi ZH, high(vv_pointer)
	ld value_h, Z
	ldd value_m, Z+1
	ldd value_l, Z+2

	ldi ZL, low(c_pointer)
	ldi ZH, high(c_pointer)
	ld count, Z

start:
	;display Value
	push value_h ;+17
	push value_m ;+16 middle
	push value_l ;+15 lower
	call int_to_string
	pop value_l
	pop value_m
	pop value_h

	;display count
	push count
	ldi ZL, 0
	push ZL
	ldi ZL, low(cnt_pointer)
	ldi ZH, high(cnt_pointer)
	push ZL
	push ZH
	call three_byte_to_str
	pop ZH
	pop ZL
	pop ZL
	pop count

	;check if the value is 0 or 1
	cpi value_h, 0
	brne cal
	cpi value_m, 0
	brne cal
	cpi value_l, 0
	breq end
	cpi value_l, 1
	breq end

cal:
	inc count
	;compare lower bit with one to check if it is odd
	mov temp, value_l
	ANDI temp, 1
	cpi temp, 1
	breq odd
	rjmp even ;jmp to even otherwise

;add the value 3 times, 
odd:
	mov temp_l, value_l
	mov temp_m, value_m
	mov temp_h, value_h

	add value_l, temp_l
	adc value_m, temp_m
	adc value_h, temp_h

	add value_l, temp_l
	adc value_m, temp_m
	adc value_h, temp_h


	ldi temp, 1
	add value_l, temp
	ldi temp, 0
	adc value_m, temp
	adc value_h, temp
	rjmp end_end

;shift right from upper -> lower,  ror -> shift with carry
even:
	lsr value_h ;upper shift left
	ror value_m ;shift middle bit, with carry 
	ror value_l ;shift lower bit, with carry
	rjmp end_end

; the end of the calculation
end:
	ldi temp, 0
	cp count_flag, temp
	breq inc_count_finally
	rjmp end_end
inc_count_finally:
	ldi temp, 1
	mov count_flag, temp
	;inc count
end_end:
	;put the value and count (int) into vv
	ldi ZL, low(vv_pointer)
	ldi ZH, high(vv_pointer)
	st Z+, value_h
	st Z+, value_m
	st Z, value_l
	ldi ZL, low(c_pointer)
	ldi ZH, high(c_pointer)
	st Z, count

	;undef the variable
	.undef count ;initalize count variable, lower byte
	.undef value_h ;store upper bytes
	.undef value_m;store middle bytes
	.undef value_l ;store lower bytes

	.undef temp
	.undef temp_h ;store value if it is 16bit, for lower bytes value
	.undef temp_m 
	.undef temp_l ;store value if it is 16bit, for upper bytes value 
	pop r27
	pop r26
	pop r31
	pop r30
	pop r19
	pop r18
	pop r17
	pop r16
	pop r25
	pop r24
	pop r23
	pop r22

	ret


; function that converts an 24-bit unsigned integer to a c-string 
int_to_string:
	.def dividend_h=r0
	.def dividend_m=r1
	.def dividend_l=r2
	.def divisor=r4
	.def quotient=r5
	.def tempt=r21
	;.def char0=r3
	;preserve the values of the registers
	;+13, ret +5
	push dividend_l
	push dividend_m
	push dividend_h
	push divisor
	push quotient
	push tempt
	push char0
	push ZH
	push ZL
	push YH
	push YL
	push XH
	push XL

	;store '0' in char0
	ldi tempt, '0'
	mov char0, tempt
	;Z points to first character of num in SRAM
	ldi ZH, high(v_pointer)
	ldi ZL, low(v_pointer)
	adiw ZH:ZL, 6 ;Z points to null character
	clr tempt 
	st Z, tempt ;set the last character to null
	sbiw ZH:ZL, 1 ;Z points the last digit location

	in YH, SPH
	in YL, SPL
	;initialize values for dividend, divisor
	ldd tempt, Y+17
ldd XL, Y+17
	;mov dividend_l, tempt ;r2
	ldd tempt, Y+18
ldd XH, Y+18
	;mov dividend_m, tempt ;r1
	ldd tempt, Y+19
;ldi XL, Y+17
	mov dividend_h, tempt ;r0

	;value: r0:r1:r2  ---> XH:XL
	;reset Y0 for further purpose
	ldi YH, 0
	ldi YL, 0
	mov r2, YL
	mov r1, YL ;reset r2, r1 
	;mov divisor, tempt ;divsor r4
	
	clr quotient ;quotient=r5
	ldi tempt, 1
	;XH:XL hold the middle:lower byte, YH:YL hold the quotient
loop10K:
	add YL, tempt ;add 1, Y hold the quotient
	adc YH, r2 ;add 0
	subi XL, 0x10
	sbci XH, 0x27
	sbc dividend_h, r2
	brcc loop10k
add_back:
	subi YL, 1
	sbci YH, 0
	subi XL, 0xF0 ;subtract -10000 (add 100000)
	sbci XH, 0xD8
	;now Y contain quotient for bit: 5:4
	;turn Y---quotient to Str and store in memory
	push YL	;+18 ;push quotient
	push YH ;+17
	ldi YL, low(v_pointer)
	ldi YH, high(v_pointer)
	push YL ;+16 ;push pointer
	push YH	;+15
	call two_byte_to_str ;call function to convert str and put in memory
	pop YH
	pop YL
	pop YH
	pop YL
	
	;now work on third char of value:
	clr YL
	clr YH
	ldi ZH, high(v_pointer)
	ldi ZL, low(v_pointer)
	adiw ZH:ZL, 2
loop1k:
	add YL, tempt
	adc YH, r2
	subi XL, 0xE8
	sbci XH, 0x03
	brcc loop1k
	subi YL, 1
	sbci YH, 0
	subi XL, 0x18
	sbci XH, 0xFC
	add YL, char0
	st Z+, YL

	clr YL
	clr YH
loop100:
	add YL, tempt
	adc YH, r2
	subi XL, 0x64
	sbci XH, 0x00
	brcc loop100
	subi YL, 1
	sbci YH, 0
	subi XL, 0x9C
	sbci XH, 0xFF
	add YL, char0
	st Z+, YL

	clr YL
	clr YH
loop10:
	add YL, tempt
	adc YH, r2
	subi XL, 0x0A
	brcc loop10
	subi YL, 1
	sbci YH, 0
	subi XL, 0xF6
	add YL, char0
	st Z+, YL
	add XL, char0
	st Z, XL

	;restore the values of the registers
	pop XL
	pop XH
	pop YL
	pop YH
	pop ZL
	pop ZH
	pop char0
	pop tempt
	pop quotient
	pop divisor
	pop dividend_h
	pop dividend_m
	pop dividend_l

	.undef dividend_h
	.undef dividend_m
	.undef dividend_l
	.undef divisor
	.undef quotient
	.undef tempt
	.undef char0
	ret
	
;take parameters (int_L, int_H, *ptr_L, *ptr_H)
two_byte_to_str:
	;+11
	push ZH
	push ZL
	push YH
	push YL
	push XH
	push XL
	push r16
	push r17
	push r18
	push r19
	push r20
	
	ldi r16, 1 ;three temp value
	ldi r17, 0
	ldi r18, 10
	ldi r19, '0'
	ldi r20, 0 ;use to count

	in YH, SPH
	in YL, SPL
	ldd XH, Y+17 ;y = number to convert str
	ldd XL, Y+18
	ldd ZH, Y+15 ;x = pointer address
	ldd ZL, Y+16
	adiw ZL, 1

	clr YH
	clr YL
	
sub_10:
	cpi r20, 2
	breq end_sub_10
	add YL, r16 ;add 1, Y hold the quotient
	adc YH, r17 ;add 0
	subi XL, 10
	sbci XH, 0
	brcc sub_10
	subi YL, 1
	sbci YH, 0
	add XL, r18
	add XL, r19

	st Z, XL
	sbiw ZL, 1
	inc r20
	mov XL, YL
	mov XH, YH
	clr YL
	clr YH
	rjmp sub_10

end_sub_10:
	pop r20
	pop r19
	pop r18
	pop r17
	pop r16
	pop XL
	pop XH
	pop YL
	pop YH
	pop ZL
	pop ZH

	ret

	;take parameters (int_L, int_H, *ptr_L, *ptr_H)
three_byte_to_str:
	;+11
	push ZH
	push ZL
	push YH
	push YL
	push XH
	push XL
	push r16
	push r17
	push r18
	push r19
	push r20
	
	ldi r16, 1 ;three temp value
	ldi r17, 0
	ldi r18, 10
	ldi r19, '0'
	ldi r20, 0 ;use to count

	in YH, SPH
	in YL, SPL
	ldd XH, Y+17 ;y = number to convert str
	ldd XL, Y+18
	ldd ZH, Y+15 ;x = pointer address
	ldd ZL, Y+16
	adiw ZL, 2

	clr YH
	clr YL
	
subb_10:
	cpi r20, 3
	breq end_subb_10
	add YL, r16 ;add 1, Y hold the quotient
	adc YH, r17 ;add 0
	subi XL, 10
	sbci XH, 0
	brcc subb_10
	subi YL, 1
	sbci YH, 0
	add XL, r18
	add XL, r19

	st Z, XL
	sbiw ZL, 1
	inc r20
	mov XL, YL
	mov XH, YH
	clr YL
	clr YH
	rjmp subb_10

end_subb_10:
	pop r20
	pop r19
	pop r18
	pop r17
	pop r16
	pop XL
	pop XH
	pop YL
	pop YH
	pop ZL
	pop ZH

	ret


; Function that delays for a period of time using busy-loop
;delay for display name
delay_name:
	push r20
	push r21
	push r22
	; Nested delay loop
	ldi r20, 0x50
x1:
		ldi r21, 0xFF
x2:
			ldi r22, 0xFF
x3:
				dec r22
				brne x3
			dec r21
			brne x2
		dec r20
		brne x1

	pop r22
	pop r21
	pop r20
	ret	

delay:
	push r20
	push r21
	push r22
	; Nested delay loop
	ldi r20, 0x09
x11:
		ldi r21, 0xFF
x22:
			ldi r22, 0xFF
x33:
				dec r22
				brne x33
			dec r21
			brne x22
		dec r20
		brne x11

	pop r22
	pop r21
	pop r20
	ret	

name_p: .db "Victor  Cheng", 0
class_p: .db "CSC230-Fall2019", 0
SPD_p: .db "SPD: ", 0
cnt_p: .db "cnt: ", 0
value_p: .db "v: ", 0
n_p: .db "n= ", 0

.dseg
.org  0x0200
pointer: .byte 5
n: .byte 2
name: .byte 16
class: .byte 16
Char_one: .byte 1
Char_two: .byte 1
SPD: .byte 4
cnt: .byte 4
value: .byte 3
star: .byte 1
;str
cnt_pointer: .byte 4
v_pointer: .byte 7
;int
vv_pointer: .byte 3
c_pointer: .byte 1
buffer: .byte 10 ;avoid garbage

;
;
; Include the HD44780 LCD Driver for ATmega2560
;
; This library has it's own .cseg, .dseg, and .def
; which is why it's included last, so it would not interfere
; with the main program design.
#define LCD_LIBONLY
.include "lcd.asm"

