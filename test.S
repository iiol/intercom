; stack pointer register
.equ	SPL, 0x3D
.equ	SPH, 0x3E

; interrupt
.equ	SREG, 0x3F
.equ	GICR, 0x3B
.equ	MCURC, 0x35

; PIN 7 -- LED 0
; PIN 6 -- input voltage
; 0 -- on, 1 -- off
; PIN 5 -- mic
; 0 -- off, 1 -- on
; PIN 4 -- open door
; 0 -- close, 1 -- open
; PIN 3 -- трубка
; 0 -- on, 1 -- off
; PIN 2 -- button
; 0 -- on, 1 -- off
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
	jmp	handset
	jmp	open_door
	jmp	int_ign
	jmp	int_ign
	jmp	int_ign
	jmp	int_ign
	jmp	int_ign
	jmp	int_ign
	jmp	int_ign
	jmp	int_ign
	jmp	int_ign
	jmp	int_ign
	jmp	int_ign
	jmp	int_ign
	jmp	int_ign
	jmp	int_ign
	jmp	int_ign
	jmp	int_ign
	jmp	int_ign
	jmp	int_ign

int_ign:
	ret

init:
	ldi	R16, 0b10110000	; DDRD
	ldi	R17, 0b01001100	; PORTD
	clr	R18		; SREG
	ldi	R19, 0x5F	; SPL
	ldi	R20, 0x04	; SPH
	clr	R21		; GICR
	clr	R22		; MCURC

	out	DDRD, R16
	out	PORTD, R17
	out	SREG, R18
	out	SPL, R19
	out	SPH, R20
	out	GICR, R21
	out	MCURC, R22

main:
	sbic	PIND, 6
	jmp	main

call:
	ldi	R16, 0b10000000	; GICR
	ldi	R17, 0b00001000 ; MCURC ; ожидаем снятия трубки

	out	GICR, R16
	out	MCURC, R17

	sei
	nop			; PWM music from CD

led_blink:
	sbi	PORTD, 7	; LED on
	call	delay
	cbi	PORTD, 7	; LED off
	call	delay
	jmp	led_blink

delay:
	ldi	R16, 255
dly1:
	ldi	R17, 255
dly2:
	dec	R17
	brne	dly2

	dec	R16
	brne	dly1

	ret

; interrupt 1
handset:
	ldi	R16, 0x5F	; SPL
	ldi	R17, 0x04	; SPH

	out	SPL, R16
	out	SPH, R17

	lds	R16, h_stat
	cpi	R16, 0x01	; if handset is raised
	breq	put

raise:
	ldi	R16, 0b11000000	; GICR
	ldi	R17, 0b00001110	; MCURC
	ldi	R18, 0x01	; h_stat

	out	GICR, R16
	out	MCURC, R17
	sts	h_stat, R18
	sbi	PORTD, 5	; mic on
	sei

inf:
	jmp	inf

put:
	ldi	R19, 0x00	; h_stat
	sts	h_stat, R19

	jmp	init

; interrupt 0
open_door:
	sbi	PORTD, 4
	cbi	PORTD, 4
	ret
