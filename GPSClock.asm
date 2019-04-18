//////////////
// #define DEBUG
//////////////
// Permanent DST / use jumper for manual DST control
// #define NO_DST
//////////////
// 
// #define BASE_TZ_OFFSET     0
// #define FRACTIONAL_OFFSET 45
//
// #define TZ_LONDON
//////////////




#define JANUARY   1
#define FEBRUARY  2
#define MARCH     3
#define APRIL     4
#define MAY       5
#define JUNE      6
#define JULY      7
#define AUGUST    8
#define SEPTEMBER 9
#define OCTOBER   10
#define NOVEMBER  11
#define DECEMBER  12

#define FIRST_SUNDAY 100
#define LAST_FRIDAY 101
#define LAST_SUNDAY 102
#define SECOND_SUNDAY 103
#define FRIDAY_BEFORE_LAST_SUNDAY 104
#define SATURDAY_BEFORE_LAST_SUNDAY 105
#define FOURTH_SUNDAY 106
#define THIRD_SUNDAY 107


#ifdef TZ_LONDON
  #define BASE_TZ_OFFSET     0
  #define DST_START_MONTH    MARCH
  #define DST_START_DAY      LAST_SUNDAY
  #define DST_END_MONTH      OCTOBER
  #define DST_END_DAY        LAST_SUNDAY
#endif

#ifdef TZ_US_EASTERN
  #define BASE_TZ_OFFSET     -5
  #define DST_START_MONTH    MARCH
  #define DST_START_DAY      SECOND_SUNDAY
  #define DST_END_MONTH      NOVEMBER
  #define DST_END_DAY        FIRST_SUNDAY
#endif

#ifdef TZ_US_PACIFIC
  #define BASE_TZ_OFFSET     -8
  #define DST_START_MONTH    MARCH
  #define DST_START_DAY      SECOND_SUNDAY
  #define DST_END_MONTH      NOVEMBER
  #define DST_END_DAY        FIRST_SUNDAY
#endif

#ifdef TZ_NEWZEALAND
  #define BASE_TZ_OFFSET     12
  #define DST_START_MONTH    SEPTEMBER
  #define DST_START_DAY      LAST_SUNDAY
  #define DST_END_MONTH      APRIL
  #define DST_END_DAY        FIRST_SUNDAY
#endif

#ifdef TZ_INDIA
  #define BASE_TZ_OFFSET     5
  #define FRACTIONAL_OFFSET 30
  #define NO_DST
#endif

#ifdef TZ_NEPAL
  #define BASE_TZ_OFFSET     5
  #define FRACTIONAL_OFFSET 45
  #define NO_DST
#endif

// Newfoundland is -3:30, but fractional offset can only be positive
#ifdef TZ_NEWFOUNDLAND
  #define BASE_TZ_OFFSET     -4
  #define FRACTIONAL_OFFSET  30
  #define DST_START_MONTH    MARCH
  #define DST_START_DAY      SECOND_SUNDAY
  #define DST_END_MONTH      NOVEMBER
  #define DST_END_DAY        FIRST_SUNDAY
#endif





#ifndef NO_DST
	#if (DST_START_MONTH < DST_END_MONTH)
		#define NORTHERN_HEMISPHERE
	#else
		#define SOUTHERN_HEMISPHERE
	#endif
#endif


.undef XH
.undef XL
.undef YH
.undef YL

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

.def daysInLastMonth = r11	;BCD

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


fix: .byte 1




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
lds r19, fix
	eor r19,dCentiSeconds
;sbrs dSeconds,0
;ori r19,0b10000000
	rcall shiftTime
	
	out SREG,r15
	reti

overflow1:

	clr dCentiSeconds
	ldi r18,$01
lds r19, fix
	eor r19,dCentiSeconds
;sbrs dSeconds,0
;ori r19,0b10000000
	rcall shiftTime


	inc dDeciSeconds
	cpi dDeciSeconds,10
	breq overflow2

	ldi r18,$02
lds r19,fix
	eor r19,dDeciSeconds
;sbrs dSeconds,0
;ori r19,0b10000000
	rcall shiftTime

	out SREG,r15
	reti

overflow2:
	
	clr dDeciSeconds
	ldi r18,$02
lds r19,fix
	eor r19,dDeciSeconds
; sbrs dSeconds,0
; ori r19,0b10000000
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
  ldi r16, 0b10000000
  sts fix, r16

	ldi r16, (1<<WGM12|1<<CS11) ;/8
	out TCCR1B,r16

	ldi r16,high(10000)
	out OCR1AH,r16
	ldi r16, low(10000)
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





	clr dTenHours
	clr dHours
	clr dTenMinutes
	clr dMinutes
	clr dTenSeconds
	ldi dSeconds, 0b10000000
	clr dDeciSeconds
	clr dCentiSeconds


	ldi r18,$08
	ldi r19,10
	rcall shiftDate
	ldi r18,$07
	ldi r19,10
	rcall shiftDate
	ldi r18,$06
	ldi r19,10
	rcall shiftDate
	ldi r18,$05
	ldi r19,10 +0b10000000
	rcall shiftDate
	ldi r18,$04
	ldi r19,10
	rcall shiftDate
	ldi r18,$03
	ldi r19,10 +0b10000000
	rcall shiftDate
	ldi r18,$02
	ldi r19,10
;or r19,dGMT
	rcall shiftDate
	ldi r18,$01
	ldi r19,10
;or r19,dBST
	rcall shiftDate

	ldi r18,$08
	ldi r19,10
	rcall shiftTime
	ldi r18,$07
	ldi r19,10
	rcall shiftTime
	ldi r18,$06
	ldi r19,10
	rcall shiftTime
	ldi r18,$05
	ldi r19,10
	rcall shiftTime
	ldi r18,$04
	ldi r19,10
	rcall shiftTime
	ldi r18,$03
	ldi r19,10
	rcall shiftTime


//////////////////////////
#ifdef DEBUG

			ldi r16,1
			sts tenYears,r16
			ldi r16,8  +0b10000000
			sts years,r16
			ldi r16,0
			sts tenMonths,r16
			ldi r16,1  +0b10000000
			sts months,r16
			ldi r16,0
			sts tenDays,r16
			ldi r16,1
			sts days,r16
			ldi r16,0
			sts tenHours,r16
			ldi r16,0
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
		
#endif

////////////////////




main:
	sei



//////////////
#ifndef DEBUG


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
	cpi r20, ','
	breq main
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

	; rcall receiveByte
	; cpi r20, 'A'
	; brne noFixYet
	; lds r20,fix
	; ldi r21,0b10000000
	; eor r20,r21
	; sts fix,r20
; noFixYet:

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
#else
nop
nop
nop
nop
nop
#endif
/////////////////////////////

cli


	ldi ZH, high(monthLookup*2)
	ldi ZL,  low(monthLookup*2)
	add ZL, fullMonths
	lpm daysInMonth,Z

#if (BASE_TZ_OFFSET < 0)
	dec ZL	; in the case of January, December is repeated at the start
	lpm daysInLastMonth,Z

	mov r20,fullYears
	andi r20, 0b11111100
	cp r20,fullYears
	brne noLeap

	ldi r20,2
	cp fullMonths,r20
	brne notFebThisMonth
	inc daysInMonth
notFebThisMonth:
	cpi ZL, low(monthLookup*2 +2)
	brne noLeap
	inc daysInLastMonth

noLeap:

#else
	ldi r20,2
	cp fullMonths,r20
	brne noLeap
	mov r20,fullYears
	andi r20, 0b11111100
	cp r20,fullYears
	brne noLeap
	inc daysInMonth
noLeap:
#endif

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


// DST enabled ?
	sbic PIND,6
	rjmp sendAll

#ifdef NO_DST
	rjmp addHour
#else

//////////////////////// Northern Hemisphere

#ifdef NORTHERN_HEMISPHERE

	ldi ZH,high(DSTStartMonth*2)
	ldi ZL, low(DSTStartMonth*2-15)
	add ZL, fullYears

	ldi r20, DST_START_MONTH
	cp fullMonths,r20
	breq isDSTStartMonth
	brcs sendAll
	
	ldi r20, DST_END_MONTH
	cp fullMonths,r20
	breq isDSTEndMonth
	brcc sendAll

	rjmp addHour

isDSTStartMonth:
	mov r21,dTenDays
	swap r21
	or r21,dDays
	lpm r20,Z

	cp r21,r20
	brcs sendAll
	breq isFirstDayDST

	; is bst.
	rjmp addHour

isDSTEndMonth:
	subi ZL, (DSTStartMonth-DSTEndMonth)*2
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

//////////////////////// Southern Hemisphere
#else

	ldi ZH,high(DSTStartMonth*2)
	ldi ZL, low(DSTStartMonth*2-15)
	add ZL, fullYears

	ldi r20, DST_START_MONTH
	cp fullMonths,r20
	breq isDSTStartMonth
	brcs PC+2 
	rjmp addHour
	
	ldi r20, DST_END_MONTH
	cp fullMonths,r20
	breq isDSTEndMonth
	brcc PC+2
	rjmp addHour

	rjmp sendAll

isDSTStartMonth:
	mov r21,dTenDays
	swap r21
	or r21,dDays
	lpm r20,Z

	cp r21,r20
	brcs sendAll
	breq isFirstDayDST

	; is bst.
	rjmp addHour

isDSTEndMonth:
	subi ZL, (DSTStartMonth-DSTEndMonth)*2
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

#endif
#endif


//////////////////////// GMT / original DST code
#if (BASE_TZ_OFFSET==0)

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

; In the southern hemisphere, DST covers new year
#ifdef SOUTHERN_HEMISPHERE
	ldi r18,3 + 0b10000000
	ldi r19, 1
	cp dMonths, r18
	cpc dTenMonths, r19
	breq overflowB12
#endif

	rjmp sendAll2
	
overflowB11:
	ldi r19,0b10000000
	mov dMonths,r19
	inc dTenMonths
	rjmp sendAll2

overflowB12:
	ldi r19, 1 + 0b10000000
	mov dMonths,r19
	clr dTenMonths
	inc dYears
	ldi r18, 10 + 0b10000000
	cp dYears, r18
	breq overflowB13
	rjmp sendAll2

overflowB13:
	ldi r19,0b10000000
	mov dYears,r19
	inc dTenYears
	rjmp sendAll2

#endif


//////////////////////// Eastern Hemisphere
#if (BASE_TZ_OFFSET > 0)

sendAll:
	ldi r20,0b10000000
	mov dGMT,r20
	clr dBST
	ldi r20, BASE_TZ_OFFSET

sendAll3:

#ifdef FRACTIONAL_OFFSET
	#if (FRACTIONAL_OFFSET == 30)

	subi dTenMinutes, -3
	cpi dTenMinutes, 6
	brcs fracOffEnd
	subi dTenMinutes, 6
	inc r20

fracOffEnd:
	#endif
	#if (FRACTIONAL_OFFSET == 45)

	subi dMinutes, -5
	cpi dMinutes, 10
	brcs fracOff1
	subi dMinutes, 10
	subi dTenMinutes, -1
fracOff1:
	subi dTenMinutes, -4
	cpi dTenMinutes, 6
	brcs fracOffEnd
	subi dTenMinutes, 6
	inc r20

fracOffEnd:
	#endif
#endif


add r20, dHours
cpi dTenHours, 2
brne PC+2
subi r20, -20
cpi dTenHours, 1
brne PC+2
subi r20, -10

clr dTenHours


cpi r20, 24
brcc saNextDay


saFullHours0:
	subi r20, 10
	brcs saFullHours1
	inc dTenHours
	rjmp saFullHours0
saFullHours1:
	subi r20,-10
	mov dHours, r20
	rjmp sendAll2

saNextDay:
	subi r20,24
saFullHours2:
	subi r20, 10
	brcs saFullHours3
	inc dTenHours
	rjmp saFullHours2
saFullHours3:
	subi r20,-10
	mov dHours, r20


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

	ldi r18,3 + 0b10000000
	ldi r19, 1
	cp dMonths, r18
	cpc dTenMonths, r19
	breq overflowB12
	rjmp sendAll2
	
overflowB11:
	ldi r19,0b10000000
	mov dMonths,r19
	inc dTenMonths
	rjmp sendAll2

overflowB12:
	ldi r19, 1 + 0b10000000
	mov dMonths,r19
	clr dTenMonths
	inc dYears
	ldi r18, 10 + 0b10000000
	cp dYears, r18
	breq overflowB13
	rjmp sendAll2

overflowB13:
	ldi r19,0b10000000
	mov dYears,r19
	inc dTenYears
;	rjmp sendAll2




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

rjmp main



addHour:

	ldi r20,0b10000000
	mov dBST,r20
	clr dGMT

	ldi r20, BASE_TZ_OFFSET+1

	rjmp sendAll3



#endif


//////////////////////// Western Hemisphere
#if (BASE_TZ_OFFSET < 0)

sendAll:
	ldi r20,0b10000000
	mov dGMT,r20
	clr dBST
	ldi r20, BASE_TZ_OFFSET

sendAll3:

#ifdef FRACTIONAL_OFFSET
	#if (FRACTIONAL_OFFSET == 30)

	subi dTenMinutes, -3
	cpi dTenMinutes, 6
	brcs fracOffEnd
	subi dTenMinutes, 6
	inc r20

fracOffEnd:
	#endif
	#if (FRACTIONAL_OFFSET == 45)

	subi dMinutes, -5
	cpi dMinutes, 10
	brcs fracOff1
	subi dMinutes, 10
	subi dTenMinutes, -1
fracOff1:
	subi dTenMinutes, -4
	cpi dTenMinutes, 6
	brcs fracOffEnd
	subi dTenMinutes, 6
	inc r20

fracOffEnd:
	#endif
#endif


add r20, dHours
cpi dTenHours, 2
brne PC+2
subi r20, -20
cpi dTenHours, 1
brne PC+2
subi r20, -10

clr dTenHours


tst r20
brmi saPrevDay


saFullHours0:
	subi r20, 10
	brcs saFullHours1
	inc dTenHours
	rjmp saFullHours0
saFullHours1:
	subi r20,-10
	mov dHours, r20
	rjmp sendAll2


saPrevDay:
	subi r20,-24
saFullHours2:
	subi r20, 10
	brcs saFullHours3
	inc dTenHours
	rjmp saFullHours2
saFullHours3:
	subi r20,-10
	mov dHours, r20


	dec dDays
	breq underflowB0
	brmi underflowB2
	rjmp sendAll2

underflowB0:
	tst dTenDays
	breq underflowB1
	rjmp sendAll2

underflowB2:
	dec dTenDays
	ldi r18,9
	mov dDays, r18
	rjmp sendAll2

underflowB1:
	ldi r18,$0F
	mov dDays, daysInLastMonth
	and dDays, r18
	mov dTenDays, daysInLastMonth
	swap dTenDays
	and dTenDays, r18


	ldi r20, 0b10000000

	eor dMonths, r20
	dec dMonths
	breq underflowB3
	brmi underflowB4
	eor dMonths, r20
	rjmp sendAll2

underflowB3:
	tst dTenMonths
	breq underflowB5
	eor dMonths, r20
	rjmp sendAll2

underflowB4:
	clr dTenMonths
	ldi r18, 9 + 0b10000000
	mov dMonths, r18
	rjmp sendAll2

underflowB5:
	ldi r18,2 +0b10000000
	mov dMonths, r18
	ldi r18,1
	mov dTenMonths, r18


	eor dYears, r20
	dec dYears
	brcs underflowB6
	eor dYears, r20
	rjmp sendAll2

underflowB6:
	ldi r18, 9 + 0b10000000
	mov dYears, r18
	dec dTenYears
;	rjmp sendAll2






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

rjmp main



addHour:

	ldi r20,0b10000000
	mov dBST,r20
	clr dGMT

	ldi r20, BASE_TZ_OFFSET+1

	rjmp sendAll3



#endif





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

push ZH
push ZL
  clr ZH
  out TCNT1H,ZH
  out TCNT1L,ZH

lds ZL,fix
ldi ZH,0b10000000
eor ZL,ZH
sts fix,ZL

  cpi dDeciSeconds, 5
  brcc timingSlow


timingFast:
  in ZL, OCR1AL
  in ZH, OCR1AH
  adiw ZH : ZL, 1
  out OCR1AH, ZH
  out OCR1AL, ZL
  ldi dDeciSeconds,0 
  ldi dCentiSeconds,0

  pop ZL
  pop ZH
  out SREG, r15
  reti


timingSlow:
  in ZL, OCR1AL
  in ZH, OCR1AH
  sbiw ZH : ZL, 1
  out OCR1AH, ZH
  out OCR1AL, ZL
  ldi dDeciSeconds,9 
  ldi dCentiSeconds,9


  ldi ZH, 1<<OCF0A
  out TIFR, ZH

pop ZL
pop ZH
rjmp rollover



.org (768)
monthLookup:
; 0 = december, 1 = january ... 12 = december
.db $31,$31,$28,$31,$30,$31,$30,$31,$31,$30,$31,$30,$31

; DST dates starting from 2015, BCD

;;;;;;;;;;;;;;;;;;;;;;;;;; Starts ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Mexico 
#if (DST_START_MONTH==APRIL && DST_START_DAY==FIRST_SUNDAY)
  DSTStartMonth:
  .db $05,$03,$02,$01,$07,$05,$04,$03,$02,$07,$06,$05,$04,$02,$01,$07,$06,$04,$03,$02,$01,$06,$05,$04,$03,$01,$07,$06,$05,$03,$02,$01,$07,$05,$04,$03,$02,$07,$06,$05,$04,$02,$01,$07,$06,$04,$03,$02,$01,$06,$05,$04,$03,$01,$07,$06,$05,$03,$02,$01,$07,$05,$04,$03,$02,$07,$06,$05,$04,$02,$01,$07,$06,$04,$03,$02,$01,$06,$05,$04,$03,$01,$07,$06,$05
#endif

; Brazil 
#if (DST_START_MONTH==NOVEMBER && DST_START_DAY==FIRST_SUNDAY)
  DSTStartMonth:
  .db $01,$06,$05,$04,$03,$01,$07,$06,$05,$03,$02,$01,$07,$05,$04,$03,$02,$07,$06,$05,$04,$02,$01,$07,$06,$04,$03,$02,$01,$06,$05,$04,$03,$01,$07,$06,$05,$03,$02,$01,$07,$05,$04,$03,$02,$07,$06,$05,$04,$02,$01,$07,$06,$04,$03,$02,$01,$06,$05,$04,$03,$01,$07,$06,$05,$03,$02,$01,$07,$05,$04,$03,$02,$07,$06,$05,$04,$02,$01,$07,$06,$04,$03,$02,$01
#endif

; Australia 
#if (DST_START_MONTH==OCTOBER && DST_START_DAY==FIRST_SUNDAY)
  DSTStartMonth:
  .db $04,$02,$01,$07,$06,$04,$03,$02,$01,$06,$05,$04,$03,$01,$07,$06,$05,$03,$02,$01,$07,$05,$04,$03,$02,$07,$06,$05,$04,$02,$01,$07,$06,$04,$03,$02,$01,$06,$05,$04,$03,$01,$07,$06,$05,$03,$02,$01,$07,$05,$04,$03,$02,$07,$06,$05,$04,$02,$01,$07,$06,$04,$03,$02,$01,$06,$05,$04,$03,$01,$07,$06,$05,$03,$02,$01,$07,$05,$04,$03,$02,$07,$06,$05,$04
#endif

; Jordan 
#if (DST_START_MONTH==MARCH && DST_START_DAY==LAST_FRIDAY)
  DSTStartMonth:
  .db $27,$25,$31,$30,$29,$27,$26,$25,$31,$29,$28,$27,$26,$31,$30,$29,$28,$26,$25,$31,$30,$28,$27,$26,$25,$30,$29,$28,$27,$25,$31,$30,$29,$27,$26,$25,$31,$29,$28,$27,$26,$31,$30,$29,$28,$26,$25,$31,$30,$28,$27,$26,$25,$30,$29,$28,$27,$25,$31,$30,$29,$27,$26,$25,$31,$29,$28,$27,$26,$31,$30,$29,$28,$26,$25,$31,$30,$28,$27,$26,$25,$30,$29,$28,$27
#endif

; United Kingdom 
#if (DST_START_MONTH==MARCH && DST_START_DAY==LAST_SUNDAY)
  DSTStartMonth:
  .db $29,$27,$26,$25,$31,$29,$28,$27,$26,$31,$30,$29,$28,$26,$25,$31,$30,$28,$27,$26,$25,$30,$29,$28,$27,$25,$31,$30,$29,$27,$26,$25,$31,$29,$28,$27,$26,$31,$30,$29,$28,$26,$25,$31,$30,$28,$27,$26,$25,$30,$29,$28,$27,$25,$31,$30,$29,$27,$26,$25,$31,$29,$28,$27,$26,$31,$30,$29,$28,$26,$25,$31,$30,$28,$27,$26,$25,$30,$29,$28,$27,$25,$31,$30,$29
#endif

; New Zealand 
#if (DST_START_MONTH==SEPTEMBER && DST_START_DAY==LAST_SUNDAY)
  DSTStartMonth:
  .db $27,$25,$24,$30,$29,$27,$26,$25,$24,$29,$28,$27,$26,$24,$30,$29,$28,$26,$25,$24,$30,$28,$27,$26,$25,$30,$29,$28,$27,$25,$24,$30,$29,$27,$26,$25,$24,$29,$28,$27,$26,$24,$30,$29,$28,$26,$25,$24,$30,$28,$27,$26,$25,$30,$29,$28,$27,$25,$24,$30,$29,$27,$26,$25,$24,$29,$28,$27,$26,$24,$30,$29,$28,$26,$25,$24,$30,$28,$27,$26,$25,$30,$29,$28,$27
#endif

; Chile 
#if (DST_START_MONTH==AUGUST && DST_START_DAY==SECOND_SUNDAY)
  DSTStartMonth:
  .db $09,$14,$13,$12,$11,$09,$08,$14,$13,$11,$10,$09,$08,$13,$12,$11,$10,$08,$14,$13,$12,$10,$09,$08,$14,$12,$11,$10,$09,$14,$13,$12,$11,$09,$08,$14,$13,$11,$10,$09,$08,$13,$12,$11,$10,$08,$14,$13,$12,$10,$09,$08,$14,$12,$11,$10,$09,$14,$13,$12,$11,$09,$08,$14,$13,$11,$10,$09,$08,$13,$12,$11,$10,$08,$14,$13,$12,$10,$09,$08,$14,$12,$11,$10,$09
#endif

; United States 
#if (DST_START_MONTH==MARCH && DST_START_DAY==SECOND_SUNDAY)
  DSTStartMonth:
  .db $08,$13,$12,$11,$10,$08,$14,$13,$12,$10,$09,$08,$14,$12,$11,$10,$09,$14,$13,$12,$11,$09,$08,$14,$13,$11,$10,$09,$08,$13,$12,$11,$10,$08,$14,$13,$12,$10,$09,$08,$14,$12,$11,$10,$09,$14,$13,$12,$11,$09,$08,$14,$13,$11,$10,$09,$08,$13,$12,$11,$10,$08,$14,$13,$12,$10,$09,$08,$14,$12,$11,$10,$09,$14,$13,$12,$11,$09,$08,$14,$13,$11,$10,$09,$08
#endif

; Israel 
#if (DST_START_MONTH==MARCH && DST_START_DAY==FRIDAY_BEFORE_LAST_SUNDAY)
  DSTStartMonth:
  .db $27,$25,$24,$23,$29,$27,$26,$25,$24,$29,$28,$27,$26,$24,$23,$29,$28,$26,$25,$24,$23,$28,$27,$26,$25,$23,$29,$28,$27,$25,$24,$23,$29,$27,$26,$25,$24,$29,$28,$27,$26,$24,$23,$29,$28,$26,$25,$24,$23,$28,$27,$26,$25,$23,$29,$28,$27,$25,$24,$23,$29,$27,$26,$25,$24,$29,$28,$27,$26,$24,$23,$29,$28,$26,$25,$24,$23,$28,$27,$26,$25,$23,$29,$28,$27
#endif

; Greenland (DK) 
#if (DST_START_MONTH==MARCH && DST_START_DAY==SATURDAY_BEFORE_LAST_SUNDAY)
  DSTStartMonth:
  .db $28,$26,$25,$24,$30,$28,$27,$26,$25,$30,$29,$28,$27,$25,$24,$30,$29,$27,$26,$25,$24,$29,$28,$27,$26,$24,$30,$29,$28,$26,$25,$24,$30,$28,$27,$26,$25,$30,$29,$28,$27,$25,$24,$30,$29,$27,$26,$25,$24,$29,$28,$27,$26,$24,$30,$29,$28,$26,$25,$24,$30,$28,$27,$26,$25,$30,$29,$28,$27,$25,$24,$30,$29,$27,$26,$25,$24,$29,$28,$27,$26,$24,$30,$29,$28
#endif



;;;;;;;;;;;;;;;;;;;;;;;;;;; Ends ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; New Zealand, Australia
#if (DST_END_MONTH==APRIL && DST_END_DAY==FIRST_SUNDAY)
  DSTEndMonth:
  .db $05,$03,$02,$01,$07,$05,$04,$03,$02,$07,$06,$05,$04,$02,$01,$07,$06,$04,$03,$02,$01,$06,$05,$04,$03,$01,$07,$06,$05,$03,$02,$01,$07,$05,$04,$03,$02,$07,$06,$05,$04,$02,$01,$07,$06,$04,$03,$02,$01,$06,$05,$04,$03,$01,$07,$06,$05,$03,$02,$01,$07,$05,$04,$03,$02,$07,$06,$05,$04,$02,$01,$07,$06,$04,$03,$02,$01,$06,$05,$04,$03,$01,$07,$06,$05
#endif

; United States 
#if (DST_END_MONTH==NOVEMBER && DST_END_DAY==FIRST_SUNDAY)
  DSTEndMonth:
  .db $01,$06,$05,$04,$03,$01,$07,$06,$05,$03,$02,$01,$07,$05,$04,$03,$02,$07,$06,$05,$04,$02,$01,$07,$06,$04,$03,$02,$01,$06,$05,$04,$03,$01,$07,$06,$05,$03,$02,$01,$07,$05,$04,$03,$02,$07,$06,$05,$04,$02,$01,$07,$06,$04,$03,$02,$01,$06,$05,$04,$03,$01,$07,$06,$05,$03,$02,$01,$07,$05,$04,$03,$02,$07,$06,$05,$04,$02,$01,$07,$06,$04,$03,$02,$01
#endif

; Paraguay 
#if (DST_END_MONTH==MARCH && DST_END_DAY==FOURTH_SUNDAY)
  DSTEndMonth:
  .db $22,$27,$26,$25,$24,$22,$28,$27,$26,$24,$23,$22,$28,$26,$25,$24,$23,$28,$27,$26,$25,$23,$22,$28,$27,$25,$24,$23,$22,$27,$26,$25,$24,$22,$28,$27,$26,$24,$23,$22,$28,$26,$25,$24,$23,$28,$27,$26,$25,$23,$22,$28,$27,$25,$24,$23,$22,$27,$26,$25,$24,$22,$28,$27,$26,$24,$23,$22,$28,$26,$25,$24,$23,$28,$27,$26,$25,$23,$22,$28,$27,$25,$24,$23,$22
#endif

; Jordan 
#if (DST_END_MONTH==OCTOBER && DST_END_DAY==LAST_FRIDAY)
  DSTEndMonth:
  .db $30,$28,$27,$26,$25,$30,$29,$28,$27,$25,$31,$30,$29,$27,$26,$25,$31,$29,$28,$27,$26,$31,$30,$29,$28,$26,$25,$31,$30,$28,$27,$26,$25,$30,$29,$28,$27,$25,$31,$30,$29,$27,$26,$25,$31,$29,$28,$27,$26,$31,$30,$29,$28,$26,$25,$31,$30,$28,$27,$26,$25,$30,$29,$28,$27,$25,$31,$30,$29,$27,$26,$25,$31,$29,$28,$27,$26,$31,$30,$29,$28,$26,$25,$31,$30
#endif

; United Kingdom 
#if (DST_END_MONTH==OCTOBER && DST_END_DAY==LAST_SUNDAY)
  DSTEndMonth:
  .db $25,$30,$29,$28,$27,$25,$31,$30,$29,$27,$26,$25,$31,$29,$28,$27,$26,$31,$30,$29,$28,$26,$25,$31,$30,$28,$27,$26,$25,$30,$29,$28,$27,$25,$31,$30,$29,$27,$26,$25,$31,$29,$28,$27,$26,$31,$30,$29,$28,$26,$25,$31,$30,$28,$27,$26,$25,$30,$29,$28,$27,$25,$31,$30,$29,$27,$26,$25,$31,$29,$28,$27,$26,$31,$30,$29,$28,$26,$25,$31,$30,$28,$27,$26,$25
#endif

; Chile 
#if (DST_END_MONTH==MAY && DST_END_DAY==SECOND_SUNDAY)
  DSTEndMonth:
  .db $10,$08,$14,$13,$12,$10,$09,$08,$14,$12,$11,$10,$09,$14,$13,$12,$11,$09,$08,$14,$13,$11,$10,$09,$08,$13,$12,$11,$10,$08,$14,$13,$12,$10,$09,$08,$14,$12,$11,$10,$09,$14,$13,$12,$11,$09,$08,$14,$13,$11,$10,$09,$08,$13,$12,$11,$10,$08,$14,$13,$12,$10,$09,$08,$14,$12,$11,$10,$09,$14,$13,$12,$11,$09,$08,$14,$13,$11,$10,$09,$08,$13,$12,$11,$10
#endif

; Brazil 
#if (DST_END_MONTH==FEBRUARY && DST_END_DAY==THIRD_SUNDAY)
  DSTEndMonth:
  .db $15,$21,$19,$18,$17,$16,$21,$20,$19,$18,$16,$15,$21,$20,$18,$17,$16,$15,$20,$19,$18,$17,$15,$21,$20,$19,$17,$16,$15,$21,$19,$18,$17,$16,$21,$20,$19,$18,$16,$15,$21,$20,$18,$17,$16,$15,$20,$19,$18,$17,$15,$21,$20,$19,$17,$16,$15,$21,$19,$18,$17,$16,$21,$20,$19,$18,$16,$15,$21,$20,$18,$17,$16,$15,$20,$19,$18,$17,$15,$21,$20,$19,$17,$16,$15
#endif

; Fiji 
#if (DST_END_MONTH==JANUARY && DST_END_DAY==THIRD_SUNDAY)
  DSTEndMonth:
  .db $18,$17,$15,$21,$20,$19,$17,$16,$15,$21,$19,$18,$17,$16,$21,$20,$19,$18,$16,$15,$21,$20,$18,$17,$16,$15,$20,$19,$18,$17,$15,$21,$20,$19,$17,$16,$15,$21,$19,$18,$17,$16,$21,$20,$19,$18,$16,$15,$21,$20,$18,$17,$16,$15,$20,$19,$18,$17,$15,$21,$20,$19,$17,$16,$15,$21,$19,$18,$17,$16,$21,$20,$19,$18,$16,$15,$21,$20,$18,$17,$16,$15,$20,$19,$18
#endif

; Greenland (DK) 
#if (DST_END_MONTH==OCTOBER && DST_END_DAY==SATURDAY_BEFORE_LAST_SUNDAY)
  DSTEndMonth:
  .db $24,$29,$28,$27,$26,$24,$30,$29,$28,$26,$25,$24,$30,$28,$27,$26,$25,$30,$29,$28,$27,$25,$24,$30,$29,$27,$26,$25,$24,$29,$28,$27,$26,$24,$30,$29,$28,$26,$25,$24,$30,$28,$27,$26,$25,$30,$29,$28,$27,$25,$24,$30,$29,$27,$26,$25,$24,$29,$28,$27,$26,$24,$30,$29,$28,$26,$25,$24,$30,$28,$27,$26,$25,$30,$29,$28,$27,$25,$24,$30,$29,$27,$26,$25,$24
#endif

