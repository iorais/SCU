;	Utility routines for onboard LCD
;	Wolfe - Sept 2019

	INCLUDE core_cm4_constants.s		; Load Constant Definitions
	INCLUDE stm32l476xx_constants.s 
		
	AREA    main, CODE, READONLY
		
LCD_CR      EQU  0x00  ; LCD control register,               Address offset: 0x00		
		
lcd_init	PROC		;Initialize the clocks; pins; and power for the onloard LCD for the STM32L476 Discovery Board
			EXPORT	lcd_init	
				
			;	Enable the LCD Clock
			;	Power up the power controller clock
			ldr		r2,=(RCC_BASE + RCC_APB1ENR1)
			ldr		r1,[r2]
			orr		r1,#RCC_APB1ENR1_PWREN
			str		r1,[r2]
			;	Short delay
			mov		r0,#5
lcd1		subs	r0,#1
			bne		lcd1
			;	Select LSE as RTC clock source
			ldr		r2,=(PWR_BASE + PWR_CR1)
			ldr		r1,[r2]
			orr		r1,#PWR_CR1_DBP
			str		r1,[r2]
lcd2		ldr		r1,[r2]
			tst		r1,#PWR_CR1_DBP
			beq		lcd2
			;	Reset LSEON and LSEBYP bits before configuring the LSE
			ldr		r2,=(RCC_BASE + RCC_BDCR)
			ldr		r1,[r2]
			bic		r1,#RCC_BDCR_LSEON
			str		r1,[r2]
lcd3		ldr		r1,[r2]
			tst		r1,#RCC_BDCR_LSERDY
			bne		lcd3
			bic		r1,#RCC_BDCR_LSEBYP
			str		r1,[r2]
			;	Reset backup domain
			ldr		r1,[r2]
			orr		r1,#RCC_BDCR_BDRST
			str		r1,[r2]
			bic		r1,#RCC_BDCR_BDRST
			str		r1,[r2]	
			;	Turn LSE back on
lcd4		ldr		r1,[r2]
			orr		r1,#RCC_BDCR_LSEON
			str		r1,[r2]
			ldr		r1,[r2]
			tst		r1,#RCC_BDCR_LSERDY
			beq		lcd4			
			;	Select LSE as RTC clock source
			ldr		r1,[r2]
			bic		r1,#RCC_BDCR_RTCSEL
			orr		r1,#RCC_BDCR_RTCSEL_0
			orr		r1,#RCC_BDCR_RTCEN
			str		r1,[r2]
			;	Power down the power controller clock
			ldr		r2,=(RCC_BASE + RCC_APB1ENR1)
			ldr		r1,[r2]
			bic		r1,#RCC_APB1ENR1_PWREN
			str		r1,[r2]	
			;	Enable LCD Peripheral Clock
			ldr		r2,=(RCC_BASE + RCC_APB1ENR1)
			ldr		r1,[r2]
			orr		r1,#RCC_APB1ENR1_LCDEN
			str		r1,[r2]			
			;	Configure the LCD I/O Pins
			;// LCD (24 segments, 4 commons, multiplexed 1/4 duty, 1/3 bias) on DIP28 connector
			;//   VLCD = PC3
			;//
			;//   COM0 = PA8     COM1  = PA9      COM2  = PA10    COM3  = PB9
			;//
			;//   SEG0 = PA7     SEG6  = PD11     SEG12 = PB5     SEG18 = PD8
			;//   SEG1 = PC5     SEG7  = PD13     SEG13 = PC8     SEG19 = PB14
			;//   SEG2 = PB1     SEG8  = PD15     SEG14 = PC6     SEG20 = PB12
			;//   SEG3 = PB13    SEG9  = PC7      SEG15 = PD14    SEG21 = PB0
			;//   SEG4 = PB15    SEG10 = PA15     SEG16 = PD12    SEG22 = PC4
			;//   SEG5 = PD9     SEG11 = PB4      SEG17 = PD10    SEG23 = PA6	
			
			;	Enable port clocks for ports A,B,C,D
			ldr		r2,=(RCC_BASE+RCC_AHB2ENR)	
			ldr		r1,[r2]
			orr		r1,#RCC_AHB2ENR_GPIOAEN
			orr		r1,#RCC_AHB2ENR_GPIOBEN
			orr		r1,#RCC_AHB2ENR_GPIOCEN
			orr		r1,#RCC_AHB2ENR_GPIODEN
			str		r1,[r2]	
			;	Configure port A Alternate mode 0xB - pins 6, 7, 8, 9, 10, 15
			ldr		r2,=(GPIOA_BASE + GPIO_MODER)
			ldr		r1,[r2]
			ldr		r0,=(GPIO_MODER_MODER6 :OR: GPIO_MODER_MODER7 :OR: GPIO_MODER_MODER8 :OR: GPIO_MODER_MODER9 :OR: GPIO_MODER_MODER10 :OR: GPIO_MODER_MODER15)
			bic		r1,r0
			ldr		r0,=(GPIO_MODER_MODER6_1 :OR: GPIO_MODER_MODER7_1 :OR: GPIO_MODER_MODER8_1 :OR: GPIO_MODER_MODER9_1 :OR: GPIO_MODER_MODER10_1 :OR: GPIO_MODER_MODER15_1)
			orr		r1,r0
			str		r1,[r2]
			ldr		r2,=(GPIOA_BASE + GPIO_AFR0)
			ldr		r1,[r2]	
			orr		r1,#0xBB000000
			str		r1,[r2]
			ldr		r2,=(GPIOA_BASE + GPIO_AFR1)
			ldr		r1,[r2]
			ldr		r0,=0xB0000BBB
			orr		r1,r0
			str		r1,[r2]
			ldr		r2,=(GPIOA_BASE + GPIO_OSPEEDR)
			ldr		r1,[r2]
			ldr		r0,=(GPIO_OSPEEDER_OSPEEDR6 :OR: GPIO_OSPEEDER_OSPEEDR7 :OR: GPIO_OSPEEDER_OSPEEDR8 :OR: GPIO_OSPEEDER_OSPEEDR9 :OR: GPIO_OSPEEDER_OSPEEDR10 :OR: GPIO_OSPEEDER_OSPEEDR15)
			bic		r1,r0
			ldr		r0,=(GPIO_OSPEEDER_OSPEEDR6_1 :OR: GPIO_OSPEEDER_OSPEEDR7_1 :OR: GPIO_OSPEEDER_OSPEEDR8_1 :OR: GPIO_OSPEEDER_OSPEEDR9_1 :OR: GPIO_OSPEEDER_OSPEEDR10_1 :OR: GPIO_OSPEEDER_OSPEEDR15_1)
			orr		r1,r0
			str		r1,[r2]	
			;	Configure port B Alternate mode 0xB - pins 0, 1, 4, 5, 9, 12, 13, 14, 15
			ldr		r2,=(GPIOB_BASE + GPIO_MODER)
			ldr		r1,[r2]
			ldr		r0,=(GPIO_MODER_MODER0 :OR: GPIO_MODER_MODER1 :OR: GPIO_MODER_MODER4 :OR: GPIO_MODER_MODER5 :OR: GPIO_MODER_MODER9 :OR: GPIO_MODER_MODER12:OR: GPIO_MODER_MODER13 :OR: GPIO_MODER_MODER14 :OR: GPIO_MODER_MODER15)
			bic		r1,r0
			ldr		r0,=(GPIO_MODER_MODER0_1 :OR: GPIO_MODER_MODER1_1 :OR: GPIO_MODER_MODER4_1 :OR: GPIO_MODER_MODER5_1:OR: GPIO_MODER_MODER9_1 :OR: GPIO_MODER_MODER12_1 :OR: GPIO_MODER_MODER13_1 :OR: GPIO_MODER_MODER14_1 :OR: GPIO_MODER_MODER15_1)
			orr		r1,r0
			str		r1,[r2]
			ldr		r2,=(GPIOB_BASE + GPIO_AFR0)
			ldr		r1,[r2]	
			ldr		r0,=0x00BB00BB
			orr		r1,r0
			str		r1,[r2]
			ldr		r2,=(GPIOB_BASE + GPIO_AFR1)
			ldr		r1,[r2]
			ldr		r0,=0xBBBB00B0
			orr		r1,r0
			str		r1,[r2]
			ldr		r2,=(GPIOB_BASE + GPIO_OSPEEDR)
			ldr		r1,[r2]
			ldr		r0,=(GPIO_OSPEEDER_OSPEEDR0 :OR: GPIO_OSPEEDER_OSPEEDR1 :OR: GPIO_OSPEEDER_OSPEEDR4 :OR: GPIO_OSPEEDER_OSPEEDR5 :OR: GPIO_OSPEEDER_OSPEEDR9 :OR: GPIO_OSPEEDER_OSPEEDR12:OR: GPIO_OSPEEDER_OSPEEDR13 :OR: GPIO_OSPEEDER_OSPEEDR14 :OR: GPIO_OSPEEDER_OSPEEDR15)
			bic		r1,r0
			ldr		r0,=(GPIO_OSPEEDER_OSPEEDR0_1 :OR: GPIO_OSPEEDER_OSPEEDR1_1 :OR: GPIO_OSPEEDER_OSPEEDR4_1 :OR: GPIO_OSPEEDER_OSPEEDR5_1:OR: GPIO_OSPEEDER_OSPEEDR9_1 :OR: GPIO_OSPEEDER_OSPEEDR12_1 :OR: GPIO_OSPEEDER_OSPEEDR13_1 :OR: GPIO_OSPEEDER_OSPEEDR14_1 :OR: GPIO_OSPEEDER_OSPEEDR15_1)
			orr		r1,r0
			str		r1,[r2]					
			;	Configure port C Alternate mode 0xB - pins 3, 4, 5, 6, 7, 8
			ldr		r2,=(GPIOC_BASE + GPIO_MODER)
			ldr		r1,[r2]
			ldr		r0,=(GPIO_MODER_MODER3 :OR: GPIO_MODER_MODER4 :OR: GPIO_MODER_MODER5 :OR: GPIO_MODER_MODER6 :OR: GPIO_MODER_MODER7 :OR: GPIO_MODER_MODER8)
			bic		r1,r0
			ldr		r0,=(GPIO_MODER_MODER3_1 :OR: GPIO_MODER_MODER4_1 :OR: GPIO_MODER_MODER5_1 :OR: GPIO_MODER_MODER6_1 :OR: GPIO_MODER_MODER7_1 :OR: GPIO_MODER_MODER8_1)
			orr		r1,r0
			str		r1,[r2]
			ldr		r2,=(GPIOC_BASE + GPIO_AFR0)
			ldr		r1,[r2]	
			ldr		r0,=0xBBBBB000
			orr		r1,r0
			str		r1,[r2]
			ldr		r2,=(GPIOC_BASE + GPIO_AFR1)
			ldr		r1,[r2]
			ldr		r0,=0x0000000B
			orr		r1,r0
			str		r1,[r2]
			ldr		r2,=(GPIOC_BASE + GPIO_OSPEEDR)
			ldr		r1,[r2]
			ldr		r0,=(GPIO_OSPEEDER_OSPEEDR3 :OR: GPIO_OSPEEDER_OSPEEDR4 :OR: GPIO_OSPEEDER_OSPEEDR5 :OR: GPIO_OSPEEDER_OSPEEDR6 :OR: GPIO_OSPEEDER_OSPEEDR7 :OR: GPIO_OSPEEDER_OSPEEDR8)
			bic		r1,r0
			ldr		r0,=(GPIO_OSPEEDER_OSPEEDR3_1 :OR: GPIO_OSPEEDER_OSPEEDR4_1 :OR: GPIO_OSPEEDER_OSPEEDR5_1 :OR: GPIO_OSPEEDER_OSPEEDR6_1 :OR: GPIO_OSPEEDER_OSPEEDR7_1 :OR: GPIO_OSPEEDER_OSPEEDR8_1)
			orr		r1,r0
			str		r1,[r2]
			;	Configure port D Alternate mode 0xB - pins 8, 9, 10, 11, 12, 13, 14, 15
			ldr		r2,=(GPIOD_BASE + GPIO_MODER)
			ldr		r1,[r2]
			ldr		r0,=(GPIO_MODER_MODER8 :OR: GPIO_MODER_MODER9 :OR: GPIO_MODER_MODER10 :OR: GPIO_MODER_MODER11 :OR: GPIO_MODER_MODER12 :OR: GPIO_MODER_MODER13 :OR: GPIO_MODER_MODER14:OR: GPIO_MODER_MODER15)
			bic		r1,r0
			ldr		r0,=(GPIO_MODER_MODER8_1 :OR: GPIO_MODER_MODER9_1 :OR: GPIO_MODER_MODER10_1:OR: GPIO_MODER_MODER11_1 :OR: GPIO_MODER_MODER12_1 :OR: GPIO_MODER_MODER13_1 :OR: GPIO_MODER_MODER14_1 :OR: GPIO_MODER_MODER15_1)
			orr		r1,r0
			str		r1,[r2]
;			ldr		r2,=(GPIOD_BASE + GPIO_AFR0)
;			ldr		r1,[r2]	
;			ldr		r0,=0x00000000
;			orr		r1,r0
;			str		r1,[r2]
			ldr		r2,=(GPIOD_BASE + GPIO_AFR1)
			ldr		r1,[r2]
			ldr		r0,=0xBBBBBBBB
			orr		r1,r0
			str		r1,[r2]
			ldr		r2,=(GPIOD_BASE + GPIO_OSPEEDR)
			ldr		r1,[r2]
			ldr		r0,=(GPIO_OSPEEDER_OSPEEDR8 :OR: GPIO_OSPEEDER_OSPEEDR9 :OR: GPIO_OSPEEDER_OSPEEDR10 :OR: GPIO_OSPEEDER_OSPEEDR11 :OR: GPIO_OSPEEDER_OSPEEDR12:OR: GPIO_OSPEEDER_OSPEEDR13 :OR: GPIO_OSPEEDER_OSPEEDR14 :OR: GPIO_OSPEEDER_OSPEEDR15)
			bic		r1,r0
			ldr		r0,=(GPIO_OSPEEDER_OSPEEDR8_1 :OR: GPIO_OSPEEDER_OSPEEDR9_1 :OR: GPIO_OSPEEDER_OSPEEDR10_1 :OR: GPIO_OSPEEDER_OSPEEDR11_1 :OR: GPIO_OSPEEDER_OSPEEDR12_1 :OR: GPIO_OSPEEDER_OSPEEDR13_1 :OR: GPIO_OSPEEDER_OSPEEDR14_1 :OR: GPIO_OSPEEDER_OSPEEDR15_1)
			orr		r1,r0
			str		r1,[r2]

			;	Configure LCD
			;	Disable LCD
			ldr		r2,=(LCD_BASE + LCD_CR)
			ldr		r1,[r2]
			bic		r1,#LCD_CR_LCDEN
			str		r1,[r2]
			;	LCD frame control register (FCR)
			;	Set clock divider
			;	Set CLKPS = LCDCLK (prescaler == 0)
			;	Blink disabled
			ldr		r2,=(LCD_BASE + LCD_FCR)	; DIV[3:0] = 1111, ck_div = ck_ps/31
			ldr		r1,[r2]
			orr		r1,#LCD_FCR_DIV
			bic		r1,#LCD_FCR_PS
			bic		r1,#LCD_FCR_BLINK
			;	// Set Pulse ON duration
			;	// Use high drive internal booster to provide larger drive current
			;	// Set the duration that the low-resister voltage divider is used
			bic		r1,#LCD_FCR_PON
			orr		r1,#(LCD_FCR_PON_2)	;Duration 4
			str		r1,[r2]
			;	// Contrast Control: specify one of the VLCD maximum voltages (VLCD5)
			bic		r1,#LCD_FCR_CC
			orr		r1,#(LCD_FCR_CC_2 :OR: LCD_FCR_CC_0)
			str		r1,[r2]
			;	Wait for LCD Status register FCR bit to be set
			ldr		r2,=(LCD_BASE + LCD_SR)
lcd5		ldr		r1,[r2]	
			tst		r1,#LCD_SR_FCRSR
			beq		lcd5
			;	// Select 1/4 duty
			ldr		r2,=(LCD_BASE + LCD_CR)
			ldr		r1,[r2]
			bic		r1,#LCD_CR_DUTY
			orr		r1,#(LCD_CR_DUTY_1 :OR: LCD_CR_DUTY_0)
			;	// Select 1/3 bias
			bic		r1,#LCD_CR_BIAS
			orr		r1,#(LCD_CR_BIAS_1)
			;	// MUX_SEG disabled
			;	// 0: SEG pin multiplexing disabled
			;	// 1: SEG[31:28] are multiplexed with SEG[43:40]
			bic		r1,#LCD_CR_MUX_SEG
			;	/* LCD control register 
			;	// VSEL: Voltage source selection
			;	// When the LCD is based on the internal step-up converter, the VLCD pin should be connected to a capacitor (see the product datasheet for further information).
			;	// 0 = internal source, 1 = external source (VLCD pin)
			bic		r1,#LCD_CR_VSEL
			str		r1,[r2]			
			;	// LCD controller enable
			;	// The VSEL, MUX_SEG, BIAS, DUTY and BUFEN bits are write-protected when the LCD is enabled (ENS bit in LCD_SR to 1).
			;	// When the LCD is disabled all COM and SEG pins are driven to VSS.
			ldr		r2,=(LCD_BASE + LCD_CR)
			ldr		r1,[r2]
			orr		r1,#LCD_CR_LCDEN
			str		r1,[r2]			
			;	Wait for LCD Status register ENS bit to be set
			ldr		r2,=(LCD_BASE + LCD_SR)
lcd6		ldr		r1,[r2]	
			tst		r1,#LCD_SR_ENS
			beq		lcd6			
			;	Wait for LCD Status register RDY bit to be set

lcd7		ldr		r1,[r2]	
			tst		r1,#LCD_SR_RDY
			beq		lcd7				
			;	Enable the display request
			ldr		r2,=(LCD_BASE + LCD_SR)
			mov		r1,#LCD_SR_UDR
			str		r1,[r2]
			bx		lr
			ALIGN
			LTORG

			ENDP
					
				
lcd_clear	PROC		;Clear the LCD
			EXPORT	lcd_clear
			;	Wait for LCD Status register UDR bit to be set (LCD ready)
			ldr		r2,=(LCD_BASE + LCD_SR)
lcdc0		ldr		r1,[r2]	
			tst		r1,#LCD_SR_UDR
			bne		lcdc0
			;	Clear LCD frame buffer
			ldr		r2,=(LCD_BASE + LCD_RAM0)	;Pointer to beginning of RAM
			ldr		r3,=(LCD_BASE + LCD_RAM15)	;Pointer to end of RAM
			mov		r0,#0
lcdc1		str		r0,[r2],#4
			cmp		r2,r3
			ble		lcdc1
			;	Enable the display request
			ldr		r2,=(LCD_BASE + LCD_SR)
			mov		r1,#LCD_SR_UDR
			str		r1,[r2]
			bx		lr			

			ENDP
							
lcd_fill	PROC		;Fill the LCD
			EXPORT	lcd_fill
			;	Wait for LCD Status register UDR bit to be set (LCD ready)
			ldr		r2,=(LCD_BASE + LCD_SR)
lcdf0		ldr		r1,[r2]	
			tst		r1,#LCD_SR_UDR
			bne		lcdf0
			;	Fill LCD frame buffer
			ldr		r2,=(LCD_BASE + LCD_RAM0)	;Pointer to beginning of RAM
			ldr		r3,=(LCD_BASE + LCD_RAM15)	;Pointer to end of RAM
			mvn		r0,#0
lcdf1		str		r0,[r2],#4
			cmp		r2,r3
			ble		lcdf1
			;	Enable the display request
			ldr		r2,=(LCD_BASE + LCD_SR)
			mov		r1,#LCD_SR_UDR
			str		r1,[r2]
			bx		lr			

			ENDP

lcd_cpy	PROC		;Copy a 16-word buffer to the LCD Frame Buffer
					;Pointer to a 16-word data buffer in r0
			EXPORT	lcd_cpy
			;	Wait for LCD Status register UDR bit to be set (LCD ready)
			ldr		r2,=(LCD_BASE + LCD_SR)
lcdp0		ldr		r1,[r2]	
			tst		r1,#LCD_SR_UDR
			bne		lcdp0
			;	Copy LCD frame buffer
			ldr		r2,=(LCD_BASE + LCD_RAM0)	;Pointer to beginning of LCD RAM
			mov		r3,r0	;Pointer to the display data buffer
			mov		r1,#16
lcdp1		ldr		r0,[r3],#4
			str		r0,[r2],#4
			subs	r1,#1
			bne		lcdp1
			;	Enable the display request
			ldr		r2,=(LCD_BASE + LCD_SR)
			mov		r1,#LCD_SR_UDR
			str		r1,[r2]
			bx		lr			

			ENDP

lcd_draw	PROC
			EXPORT	lcd_draw
			;	Draws a character into the LCD Frame Buffer based on Zhu's character font encoding
			;	r0 holds the font encoding (lower 16 bits) Segments G B M E F A C D Q K Col P H J DP N
			;	r1 holds the character position (1-6)
			
			;	Wait for LCD Status register UDR bit to be set (LCD ready)
			ldr		r2,=(LCD_BASE + LCD_SR)
lcdd0		ldr		r3,[r2]	
			tst		r3,#LCD_SR_UDR
			bne		lcdd0
			subs	r1,#1
			beq		lcdd1
			subs	r1,#1
			beq.w	lcdd2
			subs	r1,#1
			beq.w	lcdd3
			subs	r1,#1
			beq.w	lcdd4
			subs	r1,#1
			beq.w	lcdd5
			subs	r1,#1
			beq.w	lcdd6
			;	Incorrect Digit - fail
			bx		lr
lcdd1		ldr		r2,=(LCD_BASE+LCD_RAM0)		;Clear out RAM[0] bits 3,4,22, and 23
			ldr		r1,[r2]
			ldr		r3,=(1<<3 :OR: 1<<4 :OR: 1<<22 :OR: 1<<23)
			bic		r1,r3

			;	Test and set bits for bits 15-12
			lsls	r0,#16
			orrmi	r1,#(1<<3)	;true if N flag is set
			lsls	r0,#1
			orrmi	r1,#(1<<22)			
			lsls	r0,#1
			orrmi	r1,#(1<<23)	
			lsls	r0,#1
			orrmi	r1,#(1<<4)				
			str		r1,[r2]
			
			;Clear out RAM[2] bits 3,4,22, and 23	
			ldr		r1,[r2,#8]
			bic		r1,r3			
			;	Test and set bits for bits 11-8
			lsls	r0,#1
			orrmi	r1,#(1<<3)
			lsls	r0,#1
			orrmi	r1,#(1<<22)			
			lsls	r0,#1
			orrmi	r1,#(1<<23)	
			lsls	r0,#1
			orrmi	r1,#(1<<4)			
			str		r1,[r2,#8]
			
			;Clear out RAM[4] bits 3,4,22, and 23	
			ldr		r1,[r2,#16]
			bic		r1,r3			
			;	Test and set bits for bits 7-4
			lsls	r0,#1
			orrmi	r1,#(1<<3)
			lsls	r0,#1
			orrmi	r1,#(1<<22)			
			lsls	r0,#1
			orrmi	r1,#(1<<23)	
			lsls	r0,#1
			orrmi	r1,#(1<<4)			
			str		r1,[r2,#16]
			
			;Clear out RAM[6] bits 3,4,22, and 23	
			ldr		r1,[r2,#24]
			bic		r1,r3			
			;	Test and set bits for bits 3-0
			lsls	r0,#1
			orrmi	r1,#(1<<3)
			lsls	r0,#1
			orrmi	r1,#(1<<22)			
			lsls	r0,#1
			orrmi	r1,#(1<<23)	
			lsls	r0,#1
			orrmi	r1,#(1<<4)			
			str		r1,[r2,#24]
			b		lcddx

lcdd2		ldr		r2,=(LCD_BASE+LCD_RAM0)		;Clear out RAM[0] bits 5, 12, 13, and 6
			ldr		r1,[r2]
			ldr		r3,=(1<<5 :OR: 1<<6 :OR: 1<<12 :OR: 1<<13)
			bic		r1,r3

			;	Test and set bits for bits 15-12
			lsls	r0,#16
			orrmi	r1,#(1<<5)	;true if N flag is set
			lsls	r0,#1
			orrmi	r1,#(1<<12)			
			lsls	r0,#1
			orrmi	r1,#(1<<13)	
			lsls	r0,#1
			orrmi	r1,#(1<<6)				
			str		r1,[r2]
			
			;Clear out RAM[2] bits 5, 12, 13, 6	
			ldr		r1,[r2,#8]
			bic		r1,r3			
			;	Test and set bits for bits 11-8
			lsls	r0,#1
			orrmi	r1,#(1<<5)	;true if N flag is set
			lsls	r0,#1
			orrmi	r1,#(1<<12)			
			lsls	r0,#1
			orrmi	r1,#(1<<13)	
			lsls	r0,#1
			orrmi	r1,#(1<<6)			
			str		r1,[r2,#8]
			
			;Clear out RAM[4] bits 5, 12, 13, 6		
			ldr		r1,[r2,#16]
			bic		r1,r3			
			;	Test and set bits for bits 7-4
			lsls	r0,#1
			orrmi	r1,#(1<<5)	;true if N flag is set
			lsls	r0,#1
			orrmi	r1,#(1<<12)			
			lsls	r0,#1
			orrmi	r1,#(1<<13)	
			lsls	r0,#1
			orrmi	r1,#(1<<6)			
			str		r1,[r2,#16]
			
			;Clear out RAM[6] bits 5, 12, 13, 6		
			ldr		r1,[r2,#24]
			bic		r1,r3			
			;	Test and set bits for bits 3-0
			lsls	r0,#1
			orrmi	r1,#(1<<5)	;true if N flag is set
			lsls	r0,#1
			orrmi	r1,#(1<<12)			
			lsls	r0,#1
			orrmi	r1,#(1<<13)	
			lsls	r0,#1
			orrmi	r1,#(1<<6)			
			str		r1,[r2,#24]
			b		lcddx
			
lcdd3		ldr		r2,=(LCD_BASE+LCD_RAM0)		;Clear out RAM[0] bits 14, 28, 29, 15
			ldr		r1,[r2]
			ldr		r3,=(1<<14 :OR: 1<<28 :OR: 1<<29 :OR: 1<<15)
			bic		r1,r3

			;	Test and set bits for bits 15-12
			lsls	r0,#16
			orrmi	r1,#(1<<14)	;true if N flag is set
			lsls	r0,#1
			orrmi	r1,#(1<<28)			
			lsls	r0,#1
			orrmi	r1,#(1<<29)	
			lsls	r0,#1
			orrmi	r1,#(1<<15)				
			str		r1,[r2]
			
			;Clear out RAM[2] bits 14, 28, 29, 15	
			ldr		r1,[r2,#8]
			bic		r1,r3			
			;	Test and set bits for bits 11-8
			lsls	r0,#1
			orrmi	r1,#(1<<14)	;true if N flag is set
			lsls	r0,#1
			orrmi	r1,#(1<<28)			
			lsls	r0,#1
			orrmi	r1,#(1<<29)	
			lsls	r0,#1
			orrmi	r1,#(1<<15)			
			str		r1,[r2,#8]
			
			;Clear out RAM[4] bits 14, 28, 29, 15		
			ldr		r1,[r2,#16]
			bic		r1,r3			
			;	Test and set bits for bits 7-4
			lsls	r0,#1
			orrmi	r1,#(1<<14)	;true if N flag is set
			lsls	r0,#1
			orrmi	r1,#(1<<28)			
			lsls	r0,#1
			orrmi	r1,#(1<<29)	
			lsls	r0,#1
			orrmi	r1,#(1<<15)			
			str		r1,[r2,#16]
			
			;Clear out RAM[6] bits 14, 28, 29, 15	
			ldr		r1,[r2,#24]
			bic		r1,r3			
			;	Test and set bits for bits 3-0
			lsls	r0,#1
			orrmi	r1,#(1<<14)	;true if N flag is set
			lsls	r0,#1
			orrmi	r1,#(1<<28)			
			lsls	r0,#1
			orrmi	r1,#(1<<29)	
			lsls	r0,#1
			orrmi	r1,#(1<<15)			
			str		r1,[r2,#24]
			b		lcddx
			
			ALIGN
			LTORG	
			
lcdd4		ldr		r2,=(LCD_BASE+LCD_RAM0)		
			ldr		r1,[r2]				;Load RAM[0] 
			;	Test and set bits for bits 15 and 12
			tst		r0,#(1<<15)
			orrne	r1,#(1<<30)	;set if Z flag is clear
			biceq	r1,#(1<<30)	;clear if Z flag is set
			tst		r0,#(1<<12)
			orrne	r1,#(1<<31)	;set if Z flag is clear
			biceq	r1,#(1<<31)	;clear if Z flag is set
			str		r1,[r2]				;Save RAM[0]			
			ldr		r1,[r2,#4]				;Load RAM[1] 
			;	Test and set bits for bits 14 and 13
			tst		r0,#(1<<14)
			orrne	r1,#(1<<0)	;set if Z flag is clear
			biceq	r1,#(1<<0)	;clear if Z flag is set
			tst		r0,#(1<<13)
			orrne	r1,#(1<<1)	;set if Z flag is clear
			biceq	r1,#(1<<1)	;clear if Z flag is set
			str		r1,[r2,#4]				;Save RAM[1]

			ldr		r1,[r2,#8]				;Load RAM[2] 
			;	Test and set bits for bits 11 and 8
			tst		r0,#(1<<11)
			orrne	r1,#(1<<30)	;set if Z flag is clear
			biceq	r1,#(1<<30)	;clear if Z flag is set
			tst		r0,#(1<<8)
			orrne	r1,#(1<<31)	;set if Z flag is clear
			biceq	r1,#(1<<31)	;clear if Z flag is set
			str		r1,[r2,#8]				;Save RAM[2]			
			ldr		r1,[r2,#12]				;Load RAM[3] 
			;	Test and set bits for bits 10 and 9
			tst		r0,#(1<<10)
			orrne	r1,#(1<<0)	;set if Z flag is clear
			biceq	r1,#(1<<0)	;clear if Z flag is set
			tst		r0,#(1<<9)
			orrne	r1,#(1<<1)	;set if Z flag is clear
			biceq	r1,#(1<<1)	;clear if Z flag is set
			str		r1,[r2,#12]				;Save RAM[3]

			ldr		r1,[r2,#16]				;Load RAM[4] 
			;	Test and set bits for bits 7 and 4
			tst		r0,#(1<<7)
			orrne	r1,#(1<<30)	;set if Z flag is clear
			biceq	r1,#(1<<30)	;clear if Z flag is set
			tst		r0,#(1<<4)
			orrne	r1,#(1<<31)	;set if Z flag is clear
			biceq	r1,#(1<<31)	;clear if Z flag is set
			str		r1,[r2,#16]				;Save RAM[4]			
			ldr		r1,[r2,#20]				;Load RAM[5] 
			;	Test and set bits for bits 6 and 5
			tst		r0,#(1<<6)
			orrne	r1,#(1<<0)	;set if Z flag is clear
			biceq	r1,#(1<<0)	;clear if Z flag is set
			tst		r0,#(1<<5)
			orrne	r1,#(1<<1)	;set if Z flag is clear
			biceq	r1,#(1<<1)	;clear if Z flag is set
			str		r1,[r2,#20]				;Save RAM[5]

			ldr		r1,[r2,#24]				;Load RAM[6] 
			;	Test and set bits for bits 3 and 0
			tst		r0,#(1<<3)
			orrne	r1,#(1<<30)	;set if Z flag is clear
			biceq	r1,#(1<<30)	;clear if Z flag is set
			tst		r0,#(1<<0)
			orrne	r1,#(1<<31)	;set if Z flag is clear
			biceq	r1,#(1<<31)	;clear if Z flag is set
			str		r1,[r2,#24]				;Save RAM[6]			
			ldr		r1,[r2,#28]				;Load RAM[7] 
			;	Test and set bits for bits 2 and 1
			tst		r0,#(1<<2)
			orrne	r1,#(1<<0)	;set if Z flag is clear
			biceq	r1,#(1<<0)	;clear if Z flag is set
			tst		r0,#(1<<1)
			orrne	r1,#(1<<1)	;set if Z flag is clear
			biceq	r1,#(1<<1)	;clear if Z flag is set
			str		r1,[r2,#28]				;Save RAM[7]			
			b		lcddx
			
lcdd5		ldr		r2,=(LCD_BASE+LCD_RAM0)		
			ldr		r1,[r2]				;Load RAM[0] 
			;	Test and set bits for bits 14 and 13
			tst		r0,#(1<<14)
			orrne	r1,#(1<<24)	;set if Z flag is clear
			biceq	r1,#(1<<24)	;clear if Z flag is set
			tst		r0,#(1<<13)
			orrne	r1,#(1<<25)	;set if Z flag is clear
			biceq	r1,#(1<<25)	;clear if Z flag is set
			str		r1,[r2]				;Save RAM[0]			
			ldr		r1,[r2,#4]				;Load RAM[1] 
			;	Test and set bits for bits 15 and 12
			tst		r0,#(1<<15)
			orrne	r1,#(1<<2)	;set if Z flag is clear
			biceq	r1,#(1<<2)	;clear if Z flag is set
			tst		r0,#(1<<12)
			orrne	r1,#(1<<3)	;set if Z flag is clear
			biceq	r1,#(1<<3)	;clear if Z flag is set
			str		r1,[r2,#4]				;Save RAM[1]

			ldr		r1,[r2,#8]				;Load RAM[2] 
			;	Test and set bits for bits 10 and 9
			tst		r0,#(1<<10)
			orrne	r1,#(1<<24)	;set if Z flag is clear
			biceq	r1,#(1<<24)	;clear if Z flag is set
			tst		r0,#(1<<9)
			orrne	r1,#(1<<25)	;set if Z flag is clear
			biceq	r1,#(1<<25)	;clear if Z flag is set
			str		r1,[r2,#8]				;Save RAM[2]			
			ldr		r1,[r2,#12]				;Load RAM[3] 
			;	Test and set bits for bits 11 and 8
			tst		r0,#(1<<11)
			orrne	r1,#(1<<2)	;set if Z flag is clear
			biceq	r1,#(1<<2)	;clear if Z flag is set
			tst		r0,#(1<<8)
			orrne	r1,#(1<<3)	;set if Z flag is clear
			biceq	r1,#(1<<3)	;clear if Z flag is set
			str		r1,[r2,#12]				;Save RAM[3]

			ldr		r1,[r2,#16]				;Load RAM[4] 
			;	Test and set bits for bits 6 and 5
			tst		r0,#(1<<6)
			orrne	r1,#(1<<24)	;set if Z flag is clear
			biceq	r1,#(1<<24)	;clear if Z flag is set
			tst		r0,#(1<<5)
			orrne	r1,#(1<<25)	;set if Z flag is clear
			biceq	r1,#(1<<25)	;clear if Z flag is set
			str		r1,[r2,#16]				;Save RAM[4]			
			ldr		r1,[r2,#20]				;Load RAM[5] 
			;	Test and set bits for bits 7 and 4
			tst		r0,#(1<<4)
			orrne	r1,#(1<<2)	;set if Z flag is clear
			biceq	r1,#(1<<2)	;clear if Z flag is set
			tst		r0,#(1<<7)
			orrne	r1,#(1<<3)	;set if Z flag is clear
			biceq	r1,#(1<<3)	;clear if Z flag is set
			str		r1,[r2,#20]				;Save RAM[5]

			ldr		r1,[r2,#24]				;Load RAM[6] 
			;	Test and set bits for bits 2 and 1
			tst		r0,#(1<<2)
			orrne	r1,#(1<<24)	;set if Z flag is clear
			biceq	r1,#(1<<24)	;clear if Z flag is set
			tst		r0,#(1<<1)
			orrne	r1,#(1<<25)	;set if Z flag is clear
			biceq	r1,#(1<<25)	;clear if Z flag is set
			str		r1,[r2,#24]				;Save RAM[6]			
			ldr		r1,[r2,#28]				;Load RAM[7] 
			;	Test and set bits for bits 3 and 0
			tst		r0,#(1<<3)
			orrne	r1,#(1<<2)	;set if Z flag is clear
			biceq	r1,#(1<<2)	;clear if Z flag is set
			tst		r0,#(1<<0)
			orrne	r1,#(1<<3)	;set if Z flag is clear
			biceq	r1,#(1<<3)	;clear if Z flag is set
			str		r1,[r2,#28]				;Save RAM[7]			
			b		lcddx
			
lcdd6		ldr		r2,=(LCD_BASE+LCD_RAM0)		;Clear out RAM[0] bits 26, 9, 8, 17
			ldr		r1,[r2]
			ldr		r3,=(1<<26 :OR: 1<<9 :OR: 1<<8 :OR: 1<<17)
			bic		r1,r3

			;	Test and set bits for bits 15-12
			lsls	r0,#16
			orrmi	r1,#(1<<26)	;true if N flag is set
			lsls	r0,#1
			orrmi	r1,#(1<<9)			
			lsls	r0,#1
			orrmi	r1,#(1<<8)	
			lsls	r0,#1
			orrmi	r1,#(1<<17)				
			str		r1,[r2]
			
			;Clear out RAM[2] bits 26, 9, 8, 17	
			ldr		r1,[r2,#8]
			bic		r1,r3			
			;	Test and set bits for bits 11-8
			lsls	r0,#1
			orrmi	r1,#(1<<26)	;true if N flag is set
			lsls	r0,#1
			orrmi	r1,#(1<<9)			
			lsls	r0,#1
			orrmi	r1,#(1<<8)	
			lsls	r0,#1
			orrmi	r1,#(1<<17)			
			str		r1,[r2,#8]
			
			;Clear out RAM[4] bits 26, 9, 8, 17	
			ldr		r1,[r2,#16]
			bic		r1,r3			
			;	Test and set bits for bits 7-4
			lsls	r0,#1
			orrmi	r1,#(1<<26)	;true if N flag is set
			lsls	r0,#1
			orrmi	r1,#(1<<9)			
			lsls	r0,#1
			orrmi	r1,#(1<<8)	
			lsls	r0,#1
			orrmi	r1,#(1<<17)				
			str		r1,[r2,#16]
			
			;Clear out RAM[6] bits 26, 9, 8, 17
			ldr		r1,[r2,#24]
			bic		r1,r3			
			;	Test and set bits for bits 3-0
			lsls	r0,#1
			orrmi	r1,#(1<<26)	;true if N flag is set
			lsls	r0,#1
			orrmi	r1,#(1<<9)			
			lsls	r0,#1
			orrmi	r1,#(1<<8)	
			lsls	r0,#1
			orrmi	r1,#(1<<17)				
			str		r1,[r2,#24]

			;	Enable the display request
lcddx		ldr		r2,=(LCD_BASE + LCD_SR)
			mov		r1,#LCD_SR_UDR
			str		r1,[r2]
			bx		lr	
			ENDP
				
				
num2font	PROC	
			EXPORT num2font
			;	r0 is an ascii number 0-9 (0x30-0x39)
			;	return font in r0
			;	Only use last hex digit 0-9; zero out A-F
			
			cmp		r0, #0x30
			blt     return
			
			cmp     r0, #0x39
			bgt		return
			
			sub		r0, #0x30
			mov     r2, #2
			mul     r0, r2
			ldr     r1, =numfont
			add     r1, r0
			ldr     r0, [r1]
			
			bx      lr
			
return		eor		r0, r0
			bx		lr
			ENDP
			
let2font	PROC	
			EXPORT let2font
			;	r0 is an ascii letter a-z (0x41-0x5A or 0x61-7A)
			;	return font in r0
			;	convert lower to upper - return 0 for out of range

			cmp		r0, #0x41
			blt     return0
			
			cmp     r0, #0x5A
			ble     uppercase
			
			cmp     r0, #0x61
			blt     return0
			
			cmp		r0, #0x7A
			ble     lowercase
			
			b       return0
			
uppercase	sub		r0, #0x41
			mov     r2, #2
			mul     r0, r2
			ldr     r1, =letfont
			add     r1, r0
			ldr     r0, [r1]
			
			bx      lr
			
lowercase   sub     r0, #0x61
			mov     r2, #2
			mul     r0, r2
			ldr     r1, =letfont
			add     r1, r0
			ldr     r0, [r1]
			
			bx      lr
			
return0     eor     r0, r0
			bx      lr

			ENDP				
			ALIGN
									
			AREA    myData, DATA, READWRITE
letfont		dcw		0xFE00, 0x6714, 0x1D00, 0x4714, 0x9D00, 0x9C00, 0x3F00, 0xFA00, 0x0014
			dcw		0x5300, 0x9841, 0x1900, 0x5A48, 0x5A09, 0x5F00, 0xFC00, 0x5F01, 0xFC01
			dcw		0xAF00, 0x0414, 0x5B00, 0x18C0, 0x5A81, 0x00C9, 0x0058, 0x05C0
numfont		dcw		0x5F00, 0x4200, 0xF500, 0x6700, 0xEA00, 0xAF00, 0xBF00, 0x4600, 0xFF00, 0xEF00


			ALIGN		
			END
			
			