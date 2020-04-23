;Lab8
;Name: Victor Cheng
;ID: V00815317

.org 0x0000
	jmp setup

.org 0x0028
	jmp timer1_ISR
    
.org 0x0072


main_loop:	
	call delay
	;LED
	lds r16, PORTL
	ldi r17, 0b10100000
	eor r16, r17
	sts PORTL, r16

	;LCD
	ldi r16, 1
	ldi r17, 15
	push r16
	push r17
	rcall lcd_gotoxy
	pop r17
	pop r16

	lds r16, Char_one
	push r16
	rcall lcd_putchar
	pop r16

rjmp main_loop





setup:
	; initialize the stack pointer (we are using functions!)
	ldi r16, high(RAMEND)
	out SPH, r16
	ldi r16, low(RAMEND)
	out SPL, r16


	; setup the output pins on Port L and Port B
	ldi r16, 0b10101010
	sts DDRL, r16
	ldi r16, 0b00001010
	out DDRB, r16

	; turn on one of the LEDs on port B
	ldi r16, 0b00000010
	out PORTB, r16

	; turn on one of the LEDs on port L
	ldi r16, 0b10000000
	sts PORTL, r16
	
	call timer1_setup

	; initialize the LCD
	call lcd_init			
	; clear the screen
	call lcd_clr
	call cseg_to_dseg
	call display_strings
	
	;;;;set char one and two in setup;;;;;;
	ldi r16, '!'
	sts Char_one, r16

	ldi r16, ' '
	sts Char_two, r16

	jmp main_loop


.equ TIMER1_DELAY = 7813
.equ TIMER1_MAX_COUNT = 0xFFFF
.equ TIMER1_COUNTER_INIT=TIMER1_MAX_COUNT-TIMER1_DELAY
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
	sei	

	ret


; timer interrupt flag is automatically
; cleared when this ISR is executed
; per page 168 ATmega datasheet
timer1_ISR:
	push r16
	push r17
	push r18
	lds r16, SREG
	push r16

	; RESET timer counter to TIMER1_COUNTER_INIT (defined above)
	ldi r16, high(TIMER1_COUNTER_INIT)
	sts TCNT1H, r16 	; must WRITE high byte first 
	ldi r16, low(TIMER1_COUNTER_INIT)
	sts TCNT1L, r16		; low byte

	;Write your code here: toggle the bits which control the bottom two LEDs, 
	;which will make them flash alternately -- hint PORTB and EOR instruction
	in r16, PORTB
	ldi r17, 0b00001010
	eor r16, r17
	out PORTB, r16
	;Code end here;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;;Code to blink !;;
	
	lds r16, Char_one
	lds r17, Char_two
	sts Char_one, r17
	sts Char_two, r16
	
	;;end here;;;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	pop r16
	sts SREG, r16
	pop r18
	pop r17
	pop r16

	reti

;;;;;;;;;;;;;;;;;;;;;Code start here;;;;;;;;;;;;;;;;;;;;;;;
cseg_to_dseg: 
	push r16
	ldi r16, high(msg_dseg)
	push r16
	ldi r16, low(msg_dseg)
	push r16
	ldi r16, high(msg_cseg << 1)
	push r16
	ldi r16, low(msg_cseg << 1)
	push r16
	call str_init
	pop r16
	pop r16
	pop r16
	pop r16
	
	pop r16
	ret

display_strings:
	push r16

	call lcd_clr

	ldi r16, 0x01
	push r16
	ldi r16, 0x03
	push r16
	call lcd_gotoxy
	pop r16
	pop r16

	; Now display msg1 on the first line
	ldi r16, high(msg_dseg)
	push r16
	ldi r16, low(msg_dseg)
	push r16
	call lcd_puts
	pop r16
	pop r16

	pop r16

	ret
;;;Code end here;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Function that delays for a period of time using busy-loop
delay:
	push r20
	push r21
	push r22
	; Nested delay loop
	ldi r20, 0x29
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

msg_cseg: .db "Hello, World!", 0

.dseg
.org  0x200
msg_dseg: .byte 14
Char_one: .byte 1
Char_two: .byte 1

;
;
; Include the HD44780 LCD Driver for ATmega2560
;
; This library has it's own .cseg, .dseg, and .def
; which is why it's included last, so it would not interfere
; with the main program design.
#define LCD_LIBONLY
.include "lcd.asm"
