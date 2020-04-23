
;
; lab3.asm
;
; Created: 9/26/2019 2:27:07 PM
; Author : victorcheng0425
;

.cseg

	ldi r16, 0xFF
	sts DDRL, r16
	out DDRB, r16


loop: ldi r16, 0b00100010	;clock cycle 1
	  sts PORTL, r16;2
	  ldi r16, 0b00000010;1
	  out PORTB, r16;1
	  ;5

	  ldi r17, 0x07;1
l1:	  ldi r18, 0xFF;1
l2:   ldi r19, 0xFF;1
l3:   nop;1
	  nop;1
	  dec r19;1
	  brne l3;1 if false, 2 if true
	  dec r18;1
	  brne l2;1 if false, 2 if true
	  dec r17;1
	  brne l1;1 if false, 2 if true

	  ;turn lights off
	  ldi r16, 0x00;1
	  sts PORTL, r16;2
	  out PORTB, r16;1

	  ;delay for 0.5 seconds
	  ldi r17, 0x07
x1:   ldi r18, 0xFF
x2:   ldi r19, 0xFF
x3: 
	nop
	nop
	dec r19
	brne x3
	dec r18
	brne x2
	dec r17
	brne x1
	rjmp loop

done: rjmp done