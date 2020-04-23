;
; lab2.asm
;
; Created: 9/17/2019 2:27:07 PM
; Author : victorcheng0425
;


; Replace with your application code
.cseg
.org 0

.def B01 = r16
.def B02 = r17

ldi B01, 23
ldi B02, 21
clr r0
mov r19, r16
ADD r19, B02
cpi r19, 61
brlo end
inc r0
end:
rjmp end

