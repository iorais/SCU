
	INCLUDE core_cm4_constants.s		; Load Constant Definitions
	INCLUDE stm32l476xx_constants.s 
		
	AREA    main, CODE, READONLY
		
porta_init	PROC		;Initialize port A for the joystick demo
		EXPORT	porta_init
		ldr		r2,=(RCC_BASE+RCC_AHB2ENR)		;Turn on port A clock (bit 0)
		ldr		r1,[r2]
		orr		r1,#RCC_AHB2ENR_GPIOAEN
		str		r1,[r2]
		ldr		r2,=(GPIOA_BASE+GPIO_MODER)		;clear bits 0-7 and 10-11 in GPIOA_MODER
		ldr		r1,[r2]
		ldr		r0,=0x000000cff
		bic		r1,r0
		str		r1,[r2]
		ldr		r2,=(GPIOA_BASE+GPIO_PUPDR)		;set field 0-3 and 5 in GPIOA_PUPR to 10
		ldr		r1,[r2]
		ldr		r0,=0x000000455
		bic		r1,r0
		lsl		r0,#1
		orr		r1,r0
		str		r1,[r2]	
		bx		lr
		ENDP
			
		
			
read_jstick	PROC
		EXPORT read_jstick
		ldr		r2,=(GPIOA_BASE+GPIO_IDR)
		ldr		r0,[r2]
		and		r0,#0x0000002f
		bx		lr
		ENDP
		

;Interrupt Support Code

exti3_init	PROC		;initialize the external interrupt detector for PA.3
		EXPORT	exti3_init
		ldr		r2,=(RCC_BASE+RCC_APB2ENR)		;enable SYSCFG block clock
		ldr		r1,[r2]
		orr		r1,#RCC_APB2ENR_SYSCFGEN
		str		r1,[r2]		
		ldr		r2,=(SYSCFG_BASE+SYSCFG_EXTICR0)	;select PA.3 and the trigger for EXTI3
		ldr		r1,[r2]
		bic		r1,#0x00007000						;This is the default anyway
		str		r1,[r2]
		ldr		r2,=(EXTI_BASE+EXTI_RTSR1)	;enable rising edge trigger for EXTI3		
		ldr		r1,[r2]
		orr		r1,#EXTI_RTSR1_RT3
		str		r1,[r2]			
		ldr		r2,=(EXTI_BASE+EXTI_FTSR1)	;disable falling edge trigger for EXTI3		
		ldr		r1,[r2]
		bic		r1,#EXTI_FTSR1_FT3			;also the default
		str		r1,[r2]
		ldr		r2,=(EXTI_BASE+EXTI_IMR1)	;enable EXTI3 interrupt (unmask)
		ldr		r1,[r2]
		orr		r1,#EXTI_IMR1_IM3
		str		r1,[r2]	
		ldr		r2,=(NVIC_BASE+NVIC_ISER0)	;enable the EXTI3 interrupt in NVIC_ISER0
		ldr		r1,=(1<<9)
		str		r1,[r2]
		bx		lr	
		ENDP
			
exti5_init	PROC		;initialize the external interrupt detector for PA.3
		EXPORT	exti5_init
		ldr		r2,=(RCC_BASE+RCC_APB2ENR)		;enable SYSCFG block clock
		ldr		r1,[r2]
		orr		r1,#RCC_APB2ENR_SYSCFGEN
		str		r1,[r2]		
		ldr		r2,=(SYSCFG_BASE+SYSCFG_EXTICR2)	;select PA.3 and the trigger for EXTI0
		ldr		r1,[r2]
		bic		r1,#0x00000070						;This is the default anyway
		str		r1,[r2]
		ldr		r2,=(EXTI_BASE+EXTI_RTSR1)	;enable rising edge trigger for EXTI0		
		ldr		r1,[r2]
		orr		r1,#EXTI_RTSR1_RT5
		str		r1,[r2]			
		ldr		r2,=(EXTI_BASE+EXTI_FTSR1)	;disable falling edge trigger for EXTI0		
		ldr		r1,[r2]
		bic		r1,#EXTI_FTSR1_FT5			;also the default
		str		r1,[r2]
		ldr		r2,=(EXTI_BASE+EXTI_IMR1)	;enable EXTI0 interrupt (unmask)
		ldr		r1,[r2]
		orr		r1,#EXTI_IMR1_IM5
		str		r1,[r2]	
		ldr		r2,=(NVIC_BASE+NVIC_ISER0)	;enable the EXTI0 interrupt in NVIC_ISER0
		ldr		r1,=(1<<23)
		str		r1,[r2]
		bx		lr	
		ENDP
		ALIGN	
			
		END
	