	INCLUDE core_cm4_constants.s		; Load Constant Definitions
	INCLUDE stm32l476xx_constants.s 
		
	AREA    main, CODE, READONLY
		
kpad_init	PROC		;Initialize ports A and E for the keypad
		EXPORT	kpad_init
		ldr		r2,=(RCC_BASE+RCC_AHB2ENR)		;Turn on port A clock (bit 0) and port E clock (bit 4)
		ldr		r1,[r2]
		orr		r1,#RCC_AHB2ENR_GPIOAEN
		orr		r1,#RCC_AHB2ENR_GPIOEEN
		str		r1,[r2]
		ldr		r2,=(GPIOA_BASE+GPIO_MODER)		;clear bits 0-7 in GPIOA_MODER (input mode)
		ldr		r1,[r2]
		ldr		r0,=0x0000000ff
		bic		r1,r0
		str		r1,[r2]
		ldr		r2,=(GPIOE_BASE+GPIO_MODER)		;program bits 31-24 in GPIOE_MODER (Output mode)
		ldr		r1,[r2]
		bic		r1,#0xff000000
		orr		r1,#0x55000000
		str		r1,[r2]		
		ldr		r2,=(GPIOE_BASE+GPIO_OTYPER)		;set bits 12-15 in GPIOE_OTYPER to 1 (open-drain mode)
		ldr		r1,[r2]
		orr		r1,#0x0000f000
		str		r1,[r2]		
		bx		lr
		ENDP		
		
kpad_port_read	PROC					;Reads port A and returns the low 4 bits in r0
		ldr		r2,=(GPIOA_BASE+GPIO_IDR)
		ldr		r0,[r2]
		and		r0,#0x0000000f
		bx		lr
		ENDP
			
kpad_row_set	PROC					;Writes the low 4 bits of r0 to E.15-E.12
		ldr		r2,=(GPIOE_BASE+GPIO_ODR)
		ldr		r1,[r2]
		and		r0,#0xf
		lsl		r0,#12
		bic		r1,#0xf000
		orr		r1,r0
		str		r1,[r2]
		bx		lr
		ENDP
			
kpad_row_read	PROC					;Uses the last 4 bits of r0 to drive the rows.  Returns columns in r0
		EXPORT	kpad_row_read
		push	{lr}
		bl		kpad_row_set
		mov		r0,#133					;100µs delay for settling
		bl		delay75
		bl		kpad_port_read
		pop		{pc}
		ENDP		

kpad_scan		PROC				;Scan the 4 rows and return the first row # pressed in r0 and the first col # pressed in r1 (>3 for none)
		EXPORT	kpad_scan
		push	{lr}

		mov		r0, #2_0111
		bl		kpad_row_read
		cmp		r0, #2_1111
		mov		r1, r0
		mov		r0, #0
		bne		col
		
		mov		r0, #2_1011
		bl		kpad_row_read
		cmp		r0, #2_1111
		mov		r1, r0
		mov		r0, #1
		bne		col
		
		mov		r0, #2_1101
		bl		kpad_row_read
		cmp		r0, #2_1111
		mov		r1, r0
		mov		r0, #2
		bne		col
		
		mov		r0, #2_1110
		bl		kpad_row_read
		cmp		r0, #2_1111
		mov		r1, r0
		mov		r0, #3
		bne		col

		
col		eor		r1, #2_1111
		mov		r2, #0
		
loop	lsr		r1, #1
		add		r2, #1
		cmp		r1, #0
		bne		loop

		sub		r1, r2, #1
		pop		{pc}
		
		ENDP

scan2keys	PROC
		EXPORT	scan2keys
		;row # pressed in r0 and the first col # pressed in r1
		lsl		r0,#2
		add		r0,r1
		ldr		r2,=keys
		ldrb	r0,[r2,r0]
		bx		lr
		ENDP

delay75		PROC			;delays .75us per count - count in r0
		EXPORT	delay75
				;delay in units of 0.75us		
d75		subs	r0,#1
		bne		d75
		bx		lr
		ENDP
			
			
		ALIGN						
		AREA    myData, DATA, READWRITE	
keys	dcb		'D','#','0','*','C','9','8','7','B','6','5','4','A','3','2','1'				
	ALIGN
		
	END
		