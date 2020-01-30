;.include "tn2313def.inc"

; DS3231SN 32kHz connected to pin T1
; main loop counts continuously
; interrupt at overflow (2^16) - takes 2 seconds.

; main is 5 cycles, target 8MHz
#define TARGET 2*8000000/5

; search up and down, take the value with the lowest error
.def dir = r31
#define UP 1
#define DOWN 2


rjmp init
.org 0x0005 ;TIMER1 OVF

	sub r18, XL
	sbc r19, XH
	sbc r20, YL
	brcs fast

slow:
	cpi dir, DOWN
	brne nochange1

	mov r0, r21
	mov r1, r20
	mov r2, r19
	mov r3, r18

	cpse r4,r17
	rjmp writeEEP

nochange1:
	ldi dir, UP
	inc r21
	rjmp endi

fast:
	cpi dir, UP
	brne nochange2

	mov r4, r21
	mov r5, r20
	mov r6, r19
	mov r7, r18

	cpse r0,r17
	rjmp writeEEP

nochange2: 
	ldi dir, DOWN

	dec r21
endi:

	out OSCCAL, r21

	clr XL
	clr XH
	clr YL
	clr YH
	ldi r18, BYTE1(TARGET)
	ldi r19, BYTE2(TARGET)
	ldi r20, BYTE3(TARGET)

	out PORTB, r21

	reti


writeEEP:

	; DEBUG: log osccal and error amounts
	; ldi r17,32
	; mov r16,r0
	; rcall writeByte
	; inc r17
	; mov r16,r1
	; rcall writeByte
	; inc r17
	; mov r16,r2
	; rcall writeByte
	; inc r17
	; mov r16,r3
	; rcall writeByte
	; inc r17
	; mov r16,r4
	; rcall writeByte
	; inc r17
	; mov r16,r5
	; rcall writeByte
	; inc r17
	; mov r16,r6
	; rcall writeByte
	; inc r17
	; mov r16,r7
	; rcall writeByte

	add r7, r3
	adc r6, r2
	adc r5, r1

	brmi use_r0
	mov r21,r4
	rjmp use_r4
use_r0:
	mov r21,r0
use_r4:


	mov r16, r21
	clr r17
	rcall writeByte

end:
	com r17
	out PORTB, r17
	delay: sbiw X,1 nop nop nop brne delay
	rjmp end


writeByte:
	sbic EECR,EEPE
	rjmp PC-1
	out EEAR, r17 ;address
	out EEDR, r16 ;data
	sbi EECR,EEMPE
	sbi EECR,EEPE
	ret



init:

ldi r16, 1<<CS10 | 1<<CS11 | 1<<CS12 ;T1 rising edge
out TCCR1B, r16

ldi r16, 1<<TOIE1
out TIMSK, r16


clr r16
out EEAR, r16
sbi EECR,EERE
in r16,EEDR
sbrs r16,7
  out OSCCAL, r16
in r21, OSCCAL


ldi r16, 0xff
out DDRB, r16


ldi r18, BYTE1(TARGET)
ldi r19, BYTE2(TARGET)
ldi r20, BYTE3(TARGET)

ldi r16,1
ldi r17,0

clr XL
clr XH
clr YL

clr dir

sei
main:
	add XL, r16 ;1
	adc XH, r17 ;1
	adc YL, r17 ;1
	rjmp main ;2
; 5 cycles

