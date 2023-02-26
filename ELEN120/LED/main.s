;******************** (C) Andrew Wolfe *******************************************
; @file    main_hw_proto.s
; @author  Andrew Wolfe
; @date    August 18, 2019
; @note
;           This code is for the book "Embedded Systems with ARM Cortex-M 
;           Microcontrollers in Assembly Language and C, Yifeng Zhu, 
;           ISBN-13: 978-0982692639, ISBN-10: 0982692633 as used at Santa Clara University
;*******************************************************************************



	INCLUDE core_cm4_constants.s		; Load Constant Definitions
	INCLUDE stm32l476xx_constants.s   
	INCLUDE jstick.h
	INCLUDE leds.h
	INCLUDE rgb60_redact.h
	INCLUDE timer.h
	
	

	
			AREA    main, CODE, READONLY
			EXPORT	__main				
			ENTRY			
				
__main	PROC
	
		bl		spisw_init
		
		mov r4, #60
mloop	bl		setGradient
		bl		delay
		mov		r0, r4
		bl		setWhite
		bl		delay
		subs	r4, #1
		BNE 	mloop
	
endless	b		endless		
		ENDP

setGradient	PROC
		push	{lr}
		ldr		r0, =0x00000000
		bl		spi32

		ldr		r0, =0xE60000FF

		mov		r4, #30
gloop1	push	{r0}
		bl		spi32
		pop		{r0}
		sub		r0, #0x00000008
		add		r0, #0x00000800
		subs	r4, #1
		BNE		gloop1
		
		mov		r4, #30
gloop2	push	{r0}
		bl		spi32
		pop		{r0}
		sub		r0, #0x00000800
		add		r0, #0x00080000
		subs	r4, #1
		BNE		gloop2
		
		ldr		r0, =0x00000004
		bl		spi32
		
		pop		{lr}
		bx		lr
		ENDP
			
setWhite PROC
		push	{lr}
		
		mov 	r1, r0
		
		ldr		r0, =0x00000000
		bl		spi32

		ldr		r0, =0xE6FFFFFF
		
		push	{r4}
		mov		r4, #60
loop	push	{r0}

		CMP		r1, r0
		BNE		skip
		
		ldr		r0, =0xE60000FF

skip	bl		spi32
		pop		{r0}
		subs	r4, #1
		BNE		loop
		
		ldr		r0, =0x00000001
		bl		spi32
		
		pop		{r4}
		pop		{lr}
		bx		lr
		ENDP
					
delay	PROC
		LDR 	r0, =0x5FFF0

tloop	subs	r0, #1
		BNE		tloop
		
		bx		lr
		ENDP
					
			ALIGN						
			AREA    myData, DATA, READWRITE
			
			ALIGN
	

	END
