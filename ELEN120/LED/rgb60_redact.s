	INCLUDE core_cm4_constants.s		; Load Constant Definitions
	INCLUDE stm32l476xx_constants.s 
	INCLUDE leds.h
	
	
	AREA    main, CODE, READONLY
		
	

;Utility routines for the 60-LED SK9822 LED strip
spisw_init	PROC		;Initialize Port E pins 13/15 as a outputs to use as a software SPI port.
						;Try push-pull outputs at 3.3V
						;Pin 13 is sclk, pin 15 is Dout
						;Data is clocked into the RGB strip on the rising edge of sclk
			EXPORT	spisw_init
		
		push 	{lr}
		ldr		r0,=RCC_AHB2ENR_GPIOEEN	
		bl		portclock_en				; enable port E clock
		
		ldr		r0,=GPIOE_BASE
		ldr		r1,=GPIO_MODER_MODER13_0
		bl		port_bit_pushpull			;set port e.13 to push pull
		
		
		ldr		r0,=GPIOE_BASE
		ldr		r1,=GPIO_MODER_MODER15_0
		bl		port_bit_pushpull			;set port e.15 to push pull
		
		pop		{lr}
		bx		lr
		ENDP
			
spi8		PROC	;send 8 bits out the SPI port - MSB first
					;send out the low 8 bits of r0
					;sclk starts low and ends low
			EXPORT	spi8
		mov		r1,#8
		ldr		r2,=(GPIOE_BASE+GPIO_BSRR)
		push	{r4,r5,r6}
		ldr		r3,=GPIO_BSRR_BS_13
		ldr		r4,=GPIO_BSRR_BR_13
		ldr		r5,=GPIO_BSRR_BS_15
		ldr		r6,=GPIO_BSRR_BR_15			
spi8_1	tst		r0,#0x80
		streq	r6,[r2]
		strne	r5,[r2]
		str		r3,[r2]
		str		r4,[r2]
		lsl		r0,#1
		subs	r1,#1
		bne		spi8_1
		pop		{r4,r5,r6}
		bx		lr
		ENDP	
			
spi32		PROC	;send 32 bits out the SPI port - MSB first
					;send out the 32 bits of r0
					;sclk starts low and ends low
			EXPORT	spi32
		mov		r1,#32
		ldr		r2,=(GPIOE_BASE+GPIO_BSRR)
		push	{r4,r5,r6}
		ldr		r3,=GPIO_BSRR_BS_13
		ldr		r4,=GPIO_BSRR_BR_13
		ldr		r5,=GPIO_BSRR_BS_15
		ldr		r6,=GPIO_BSRR_BR_15
spi32_1	tst		r0,#0x80000000

		streq	r6,[r2]
		strne	r5,[r2]
		str		r3,[r2]
		str		r4,[r2]
		lsl		r0,#1
		subs	r1,#1
		bne		spi32_1
		pop		{r4,r5,r6}
		bx		lr			
		ENDP			
			
			
		ALIGN	
			
		END