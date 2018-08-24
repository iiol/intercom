; stack pointer registers
.equ	SPL, 0x3D
.equ	SPH, 0x3E

; interrupt
.equ	GICR, 0x3B
.equ	MCUCR, 0x35

; PORTD pins
.equ	LED_P, 7	; LED
.equ	VLT_P, 6	; intercom line status
.equ	MIC_P, 5	; microphone
.equ	DOR_P, 4	; door open signal
.equ	BT0_P, 3	; off-hook button
.equ	BT1_P, 2	; door open button

.equ	PIND, 0x10
.equ	DDRD, 0x11
.equ	PORTD, 0x12


.data
.org	0x00

h_stat:
	.byte	1


.text
.org	0x00

vectors:
	jmp	init
	jmp	open_door	; INT0
	jmp	handset		; INT1

init:
	cli

	ldi	R16, (1 << LED_P) | (1 << MIC_P) | (1 << DOR_P)	; DDRD
	ldi	R17, (1 << VLT_P) | (1 << BT0_P) | (1 << BT1_P)	; PORTD
	clr	R18		; h_stat
	ldi	R19, 0x5F	; SPL
	ldi	R20, 0x04	; SPH
	ldi	R21, 0b10000000	; GICR
	ldi	R22, 0b00001000 ; MCUCR

	out	DDRD, R16
	out	PORTD, R17
	sts	h_stat, R18
	out	SPL, R19
	out	SPH, R20
	out	GICR, R21
	out	MCUCR, R22

main:
	sbic	PIND, VLT_P
	jmp	main

call:
	sei
	nop			; PWM music from CD

led_blink:
	sbi	PORTD, LED_P	; LED on
	call	delay
	cbi	PORTD, LED_P	; LED off
	call	delay
	jmp	led_blink

; interrupt 1
handset:
	ldi	R16, 0x5F	; SPL
	ldi	R17, 0x04	; SPH

	out	SPL, R16
	out	SPH, R17

	lds	R16, h_stat
	cpi	R16, 0x01	; if handset is raised,
	breq	put		; then go to put

raise:
	ldi	R16, 0b11000000	; GICR
	ldi	R17, 0b00001110	; MCUCR
	ldi	R18, 0x01	; h_stat

	out	GICR, R16
	out	MCUCR, R17
	sts	h_stat, R18

	sbi	PORTD, MIC_P	; mic on
	sbi	PORTD, LED_P	; led on
	cbi	PORTD, BT0_P

	sei

inf:
	jmp	inf

put:
	jmp	init

; interrupt 0
open_door:
	sbi	PORTD, DOR_P
	call	delay
	cbi	PORTD, DOR_P

	reti

delay:
	ldi	R16, 8
dly1:
	ldi	R17, 255
dly2:
	ldi	R18, 255
dly3:
	dec	R18
	brne	dly3

	dec	R17
	brne	dly2

	dec	R16
	brne	dly1

	ret
