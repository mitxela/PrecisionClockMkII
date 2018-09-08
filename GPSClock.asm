.include "tn4313def.inc"



.def dCentiSeconds = r22
.def dDeciSeconds = r23
.def dSeconds = r24
.def dTenSeconds = r25
.def dMinutes = r26
.def dTenMinutes = r27
.def dHours = r28
.def dTenHours = r29

.def dDays = r0
.def dTenDays = r1
.def dMonths = r2
.def dTenMonths = r3
.def dYears = r4
.def dTenYears = r5


.def fullYears = r6
.def fullMonths = r7
.def daysInMonth = r8	;BCD

.def dGMT = r9
.def dBST = r10


.dseg

centiSeconds: .byte 1
deciSeconds: .byte 1
seconds: .byte 1
tenSeconds: .byte 1
minutes: .byte 1
tenMinutes: .byte 1
hours: .byte 1
tenHours: .byte 1
days: .byte 1
tenDays: .byte 1
months: .byte 1
tenMonths: .byte 1
years: .byte 1
tenYears: .byte 1


timerHigh: .byte 1
timerLow: .byte 1





.cseg
; reset
	rjmp init
; int 0
  in r15,SREG
  rjmp timingAdjust
;	ldi dDeciSeconds,9  ;nop
;	ldi dCentiSeconds,9 ;nop
	nop
; timer1 compa
	in r15,SREG

rollover:

	inc dCentiSeconds
	cpi dCentiSeconds,10
	breq overflow1
	
	ldi r18,$01
	mov r19,dCentiSeconds
sbrs dSeconds,0
ori r19,0b10000000
	rcall shiftTime
	
	out SREG,r15
	reti

overflow1:

	clr dCentiSeconds
	ldi r18,$01
	mov r19,dCentiSeconds
sbrs dSeconds,0
ori r19,0b10000000
	rcall shiftTime


	inc dDeciSeconds
	cpi dDeciSeconds,10
	breq overflow2

	ldi r18,$02
	mov r19,dDeciSeconds
sbrs dSeconds,0
ori r19,0b10000000
	rcall shiftTime

	out SREG,r15
	reti

overflow2:
	
	clr dDeciSeconds
	ldi r18,$02
	mov r19,dDeciSeconds
sbrs dSeconds,0
ori r19,0b10000000
	rcall shiftTime

	inc dSeconds
	cpi dSeconds,(10 +0b10000000)
	breq overflow3

	ldi r18,$03
	mov r19,dSeconds
	ori r19,0b10000000
	rcall shiftTime

	out SREG,r15
	reti

overflow3:
	
	ldi dSeconds,0b10000000
	ldi r18,$03
	mov r19,dSeconds
	ori r19,0b10000000
	rcall shiftTime

	inc dTenSeconds
	cpi dTenSeconds,6
	breq overflow4

	ldi r18,$04
	mov r19,dTenSeconds
	rcall shiftTime

	out SREG,r15
	reti

overflow4:
	
	clr dTenSeconds
	ldi r18,$04
	mov r19,dTenSeconds
	rcall shiftTime

	inc dMinutes
	cpi dMinutes,10
	breq overflow5

	ldi r18,$05
	mov r19,dMinutes
	rcall shiftTime
	
	out SREG,r15
	reti

overflow5:

	clr dMinutes
	ldi r18,$05
	mov r19,dMinutes
	rcall shiftTime
	
	inc dTenMinutes
	cpi dTenMinutes,6
	breq overflow6
	
	ldi r18,$06
	mov r19,dTenMinutes
	rcall shiftTime

	out SREG,r15
	reti

overflow6:

	clr dTenMinutes
	ldi r18,$06
	mov r19,dTenMinutes
	rcall shiftTime

	inc dHours
	ldi r18,2
	cpi dHours,4
	cpc dTenHours,r18
	breq overflow8
	
	cpi dHours,10
	breq overflow7

	ldi r18,$07
	mov r19,dHours
	rcall shiftTime

	out SREG,r15
	reti

overflow7:

	clr dHours
	ldi r18,$07
	mov r19,dHours
	rcall shiftTime

	inc dTenHours
	ldi r18,$08
	mov r19,dTenHours
	rcall shiftTime

	out SREG,r15
	reti

overflow8:

	clr dTenHours
	clr dHours

	ldi r18,$07
	mov r19,dHours
	rcall shiftTime

	ldi r18,$08
	mov r19,dTenHours
	rcall shiftTime


;	inc dDays
	mov r18,dTenDays
	swap r18
	;andi r18,$F0
	or r18,dDays
	cp daysInMonth,r18
	breq overflow10

	inc dDays
	ldi r18,10
	cp dDays,r18
	breq overflow9
	
	ldi r18,$01
	mov r19,dDays
or r19,dBST
	rcall shiftDate

	out SREG,r15
	reti

overflow9:
	clr dDays
	ldi r18,$01
	mov r19,dDays
or r19,dBST
	rcall shiftDate

	inc dTenDays
	ldi r18,$02
	mov r19,dTenDays
or r19,dGMT
	rcall shiftDate

	out SREG,r15
	reti

overflow10:
	
	clr dTenDays
	ldi r18,$01
	mov dDays,r18  ; load dDays 1
	mov r19,dDays
or r19,dBST
	rcall shiftDate
	ldi r18,$02
	mov r19,dTenDays
or r19,dGMT
	rcall shiftDate

	ldi r18,1
	ldi r19,2 + 0b10000000
	cp dMonths,r19
	cpc dTenMonths,r18
	breq overflow12
	
	ldi r18,10 + 0b10000000
	inc dMonths
	cp dMonths,r18
	breq overflow11

	ldi r18,$03
	mov r19,dMonths
	rcall shiftDate

	out SREG,r15
	reti
overflow11:
	ldi r19,0b10000000
	mov dMonths,r19
	ldi r18,$03
	rcall shiftDate

	inc dTenMonths
	ldi r18,$04
	mov r19,dTenMonths
	rcall shiftDate
	
	out SREG,r15
	reti

overflow12:
	ldi r18,0b10000001
	mov dMonths,r18
	clr dTenMonths
	
	ldi r18,$03
	mov r19,dMonths
	rcall shiftDate
	ldi r18,$04
	mov r19,dTenMonths
	rcall shiftDate


	inc dYears
	ldi r18,10+0b10000000
	cp dYears,r18
	breq overflow13

	ldi r18,$05
	mov r19,dYears
	rcall shiftDate

	out SREG,r15
	reti

overflow13:

	ldi r19,0b10000000
	mov dYears,r19
	ldi r18,$05
	rcall shiftDate

	inc dTenYears
	ldi r18,$06
	mov r19,dTenYears
	rcall shiftDate

	out SREG,r15
	reti






init:

	; Load calibration byte from EEPROM
	; clr r16
	; out EEAR, r16
	; sbi EECR,EERE
	; in r16,EEDR
	; out OSCCAL, r16
	; nop


	ldi r16, (1<<WGM12|1<<CS11|1<<CS10) ;/64
	out TCCR1B,r16

	ldi r16,high(1250)
	sts timerHigh, r16
	out OCR1AH,r16
	ldi r16, low(1250)
	sts timerLow, r16
	out OCR1AL,r16

	ldi r16,1<<OCIE1A
	out TIMSK,r16


	ldi r16,(1<<ISC01|1<<ISC00)
	out MCUCR,r16
	ldi r16,1<<INT0
	out GIMSK,r16


	ldi r16,0b00001111
	out DDRB,r16
	ldi r16,0
	out PORTB,r16

	out DDRD,r16
	ldi r16, 1<<6
	out PORTD,r16

    ldi r16,0
    out UBRRH,r16
    ldi r16,51
    out UBRRL,r16

    ldi r16,(1<<RXEN)
    out UCSRB,r16
    
    ldi r16,(1<<UCSZ1|1<<UCSZ0)
    out UCSRC,r16





	ldi r18,$09 ;Decode mode
	ldi r19,$FF ;Code B all digits
	rcall shiftBoth



	ldi r18,$0A ;Intensity
	ldi r19,$0F
	rcall shiftBoth


	ldi r18,$0B ;Scan Limit
	ldi r19,$07 ;3 digits
	rcall shiftBoth


	ldi r18,$FF ;Display test
	ldi r19,$00
	rcall shiftBoth


	ldi r18,$0C ;Shutdown
	ldi r19,$01 ;Normal operation
	rcall shiftBoth




//////////////////////////
/*
	ldi r16,1
	sts tenYears,r16
	ldi r16,6  +0b10000000
	sts years,r16
	ldi r16,0
	sts tenMonths,r16
	ldi r16,5  +0b10000000
	sts months,r16
	ldi r16,3
	sts tenDays,r16
	ldi r16,1
	sts days,r16
	ldi r16,2
	sts tenHours,r16
	ldi r16,3
	sts hours,r16
	ldi r16,4
	sts tenMinutes,r16
	ldi r16,9
	sts minutes,r16
	ldi r16,5
	sts tenSeconds,r16
	ldi r16,5 +0b10000000
	sts seconds,r16
	ldi r16,5
	sts deciSeconds,r16
	ldi r16,5
	sts centiSeconds,r16


	
	lds r20, tenMonths

	ldi r21,10
	clr fullMonths
	sbrc r20,0
	mov fullMonths,r21

	lds r20, months
	andi r20,$0F
	add fullMonths,r20

	lds r20,tenYears

	clr fullYears
yearLoop2:
	add fullYears,r21
	dec r20
	brne yearLoop2

	lds r20,years
	andi r20,$0F
	add fullYears,r20
	
*/

////////////////////




main:
	sei



//////////////
//rjmp temp
///////////////



	rcall receiveByte
	cpi r20, '$'
	brne main

	rcall receiveByte
	cpi r20, 'G'
	brne main

	rcall receiveByte
	cpi r20, 'P'
	brne main

	rcall receiveByte
	cpi r20, 'R'
	brne main

	rcall receiveByte
	cpi r20, 'M'
	brne main

	rcall receiveByte
	cpi r20, 'C'
	brne main

	rcall receiveByte

	rcall receiveByte
	andi r20,$0F
	sts tenHours,r20
	
	rcall receiveByte
	andi r20,$0F
	sts hours,r20

	rcall receiveByte
	andi r20,$0F
	sts tenMinutes,r20

	rcall receiveByte
	andi r20,$0F
	sts minutes,r20

	rcall receiveByte
	andi r20,$0F
	sts tenSeconds,r20

	rcall receiveByte
	andi r20,$0F
	ori r20,0b10000000
	sts seconds,r20

	rcall receiveByte; dot

	rcall receiveByte
	andi r20,$0F
	sts deciSeconds,r20

	rcall receiveByte
	andi r20,$0F
	sts centiSeconds,r20

	rcall waitForComma	; end of milliseconds

	rcall waitForComma	; status
	rcall waitForComma	; latitude
	rcall waitForComma	; hemisphere
	rcall waitForComma	; longitude
	rcall waitForComma	; east west
	rcall waitForComma	; speed
	rcall waitForComma	; course
	

	rcall receiveByte
	andi r20,$0F
	sts tenDays,r20

	rcall receiveByte
	andi r20,$0F
	sts days,r20

	rcall receiveByte
	andi r20,$0F
	sts tenMonths,r20

	ldi r21,10
	clr fullMonths
	sbrc r20,0
	mov fullMonths,r21

	rcall receiveByte
	andi r20,$0F
	add fullMonths,r20
	ori r20,0b10000000
	sts months,r20

	rcall receiveByte
	andi r20,$0F
	sts tenYears,r20

	clr fullYears
yearLoop:
	add fullYears,r21
	dec r20
	brne yearLoop

	rcall receiveByte
	andi r20,$0F
	add fullYears,r20
	ori r20,0b10000000
	sts years,r20


///////////////////////////
//				temp:
/////////////////////////////

cli


	ldi ZH, high(monthLookup*2)
	ldi ZL,  low(monthLookup*2)
	add ZL, fullMonths
	lpm daysInMonth,Z


	ldi r20,2
	cp fullMonths,r20
	brne noLeap
	mov r20,fullYears
	andi r20, 0b11111100
	cp r20,fullYears
	brne noLeap
	inc daysInMonth
noLeap:

	lds dTenYears,tenYears
	lds dYears,years
	lds dTenMonths,tenMonths
	lds dMonths, months
	lds dTenDays,tenDays
	lds dDays,days
	lds dTenHours,tenHours
	lds dHours,hours
	lds dTenMinutes,tenMinutes
	lds dMinutes,minutes
	lds dTenSeconds,tenSeconds
	lds dSeconds,seconds
;	lds dDeciSeconds,deciSeconds
;	lds dCentiSeconds,centiSeconds


	sbic PIND,6
	rjmp sendAll


	ldi ZH,high(March*2)
	ldi ZL, low(March*2-15)
	add ZL, fullYears

	ldi r20, 3
	cp fullMonths,r20
	breq isMarch
	brcs sendAll
	
	ldi r20, 10
	cp fullMonths,r20
	breq isOctober
	brcc sendAll

	rjmp addHour

isMarch:
	mov r21,dTenDays
	swap r21
	or r21,dDays
	lpm r20,Z

	cp r21,r20
	brcs sendAll
	breq isFirstDayDST

	; is bst.
	rjmp addHour

isOctober:
	subi ZL, (March-October)*2
	lpm r20,Z
	mov r21,dTenDays
	swap r21
	or r21,dDays

	cp r21,r20
	breq isLastDayDST
	brcc sendAll


	;is bst
	rjmp addHour

isFirstDayDST:
	ldi r20,0
	cpi dHours,0
	cpc dTenHours,r20
	breq sendAll
	rjmp addHour
	

isLastDayDST:
	cpi dTenHours,0
	brne sendAll
	cpi dHours,0
	brne sendAll
	rjmp addHour


sendAll:
	ldi r20,0b10000000
	mov dGMT,r20
	clr dBST
sendAll2:


	ldi r18,$08
	ldi r19,2
	rcall shiftDate
	ldi r18,$07
	ldi r19,0
	rcall shiftDate
	ldi r18,$06
	mov r19,dTenYears
	rcall shiftDate
	ldi r18,$05
	mov r19,dYears
	rcall shiftDate
	ldi r18,$04
	mov r19,dTenMonths
	rcall shiftDate
	ldi r18,$03
	mov r19,dMonths
	rcall shiftDate
	ldi r18,$02
	mov r19,dTenDays
or r19,dGMT
	rcall shiftDate
	ldi r18,$01
	mov r19,dDays
or r19,dBST
	rcall shiftDate

	ldi r18,$08
	mov r19,dTenHours
	rcall shiftTime
	ldi r18,$07
	mov r19,dHours
	rcall shiftTime
	ldi r18,$06
	mov r19,dTenMinutes
	rcall shiftTime
	ldi r18,$05
	mov r19,dMinutes
	rcall shiftTime
	ldi r18,$04
	mov r19,dTenSeconds
	rcall shiftTime
	ldi r18,$03
	mov r19,dSeconds
	rcall shiftTime
	;ldi r18,$02
	;mov r19,dDeciSeconds
	;rcall shiftTime




//////////////
//sei rjmp PC
///////////


rjmp main



addHour:

	ldi r20,0b10000000
	mov dBST,r20
	clr dGMT


	inc dHours
	ldi r18,2
	cpi dHours,4
	cpc dTenHours,r18
	breq overflowB8
	
	cpi dHours,10
	breq overflowB7
	rjmp sendAll2

overflowB7:
	clr dHours
	inc dTenHours
	rjmp sendAll2

overflowB8:
	clr dTenHours
	clr dHours

	mov r18,dTenDays
	swap r18

	or r18,dDays
	cp daysInMonth,r18
	breq overflowB10

	inc dDays
	ldi r18,10
	cp dDays,r18
	breq overflowB9
	rjmp sendAll2

overflowB9:
	clr dDays
	inc dTenDays
	rjmp sendAll2

overflowB10:
	clr dTenDays
	ldi r18,$01
	mov dDays,r18

	ldi r18,10 + 0b10000000
	inc dMonths
	cp dMonths,r18
	breq overflowB11
	rjmp sendAll2
	
overflowB11:
	ldi r19,0b10000000
	mov dMonths,r19
	inc dTenMonths
	rjmp sendAll2






receiveByte:
    sbis UCSRA,RXC
    rjmp receiveByte
    
    in r20,UDR
	ret


waitForComma:
	rcall receiveByte
	cpi r20, ','
	brne waitForComma
	ret



	; max7219 is MSB first
shiftTime:
	; data is r18:r19
	ldi r17,16
shiftTimeLoop:
	cbi PORTB,1 ; clock low
	ldi r16,0b00001000
	sbrc r18,7
	ori r16,1 ; data high 
	out PORTB,r16
	lsl r19
	rol r18
	nop
	nop
	sbi PORTB,1 ; clock high
	nop
	nop

	dec r17
	brne shiftTimeLoop

	sbi PORTB,2 ;Load high
	nop
	nop
	cbi PORTB,1 ; clock low
	nop
	nop
	ret

	
	
shiftDate:
	; data is r18:r19
	ldi r17,16
shiftDateLoop:
	cbi PORTB,1 ; clock low
	ldi r16,0b00000100
	sbrc r18,7
	ori r16,1 ; data high 
	out PORTB,r16
	lsl r19
	rol r18
	nop
	nop
	sbi PORTB,1 ; clock high
	nop
	nop

	dec r17
	brne shiftDateLoop

	sbi PORTB,3 ;Load high
	nop
	nop
	cbi PORTB,1 ; clock low
	nop
	nop
	ret


shiftBoth:
	; data is r18:r19
	ldi r17,16
shiftBothLoop:
	cbi PORTB,1 ; clock low
	clr r16
	sbrc r18,7
	ori r16,1 ; data high 
	out PORTB,r16
	lsl r19
	rol r18
	nop
	nop
	sbi PORTB,1 ; clock high
	nop
	nop

	dec r17
	brne shiftBothLoop

	sbi PORTB,2 ;Load high
	sbi PORTB,3 ;Load high
	nop
	nop
	cbi PORTB,1 ; clock low
	nop
	nop
	ret


; Calibrate interpolated centiseconds to match the 1PPS output
timingAdjust:
  ; if deciseconds:centiseconds <5:0, overflow occured. Timing is fast, increase OCR
  ; if deciseconds:centiseconds <9:9, running slow, decrease OCR
  ; exactly 9:9 - cutting it a bit fine, better slow it down by one

push ZH
push ZL

  cpi dDeciSeconds, 5
  brcs timingFast

  ldi ZH, 9
  cp dCentiSeconds, ZH
  cpc dDeciSeconds, ZH
  brcs timingSlow

;rjmp timingAdjEnd

timingFast:
  lds ZH, timerHigh
  lds ZL, timerLow
  adiw ZH : ZL, 1
  rjmp timingAdjApply


timingSlow:
  lds ZH, timerHigh
  lds ZL, timerLow
  sbiw ZH : ZL, 1

timingAdjApply:

  sts timerHigh, ZH
  sts timerLow, ZL
  out OCR1AH, ZH
  out OCR1AL, ZL

timingAdjEnd:
  ldi dDeciSeconds,9 
  ldi dCentiSeconds,9
pop ZL
pop ZH
rjmp rollover



.org (768)
monthLookup:
.db 0,$31,$28,$31,$30,$31,$30,$31,$31,$30,$31,$30,$31

; DST dates starting from 2015

March:
.db $29,$27,$26,$25,$31,$29,$28,$27,$26,$31,$30,$29,$28,$26,$25,$31,$30,$28,$27,$26,$25,$30,$29,$28,$27,$25,$31,$30,$29,$27,$26,$25,$31,$29,$28,$27,$26,$31,$30,$29,$28,$26,$25,$31,$30,$28,$27,$26,$25,$30,$29,$28,$27,$25,$31,$30,$29,$27,$26,$25,$31,$29,$28,$27,$26,$31,$30,$29,$28,$26,$25,$31,$30,$28,$27,$26,$25,$30,$29,$28,$27,$25,$31,$30,$29

October:
.db $25,$30,$29,$28,$27,$25,$31,$30,$29,$27,$26,$25,$31,$29,$28,$27,$26,$31,$30,$29,$28,$26,$25,$31,$30,$28,$27,$26,$25,$30,$29,$28,$27,$25,$31,$30,$29,$27,$26,$25,$31,$29,$28,$27,$26,$31,$30,$29,$28,$26,$25,$31,$30,$28,$27,$26,$25,$30,$29,$28,$27,$25,$31,$30,$29,$27,$26,$25,$31,$29,$28,$27,$26,$31,$30,$29,$28,$26,$25,$31,$30,$28,$27,$26,$25
