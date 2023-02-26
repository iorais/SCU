;******************** (C) Andrew Wolfe *******************************************
; @file    lcd2.s
; @author  Andrew Wolfe
; @date    Sept. 15, 2019
; @note
;           This code is for the book "Embedded Systems with ARM Cortex-M 
;           Microcontrollers in Assembly Language and C, Yifeng Zhu, 
;           ISBN-13: 978-0982692639, ISBN-10: 0982692633 as used at Santa Clara University
;*******************************************************************************



	INCLUDE core_cm4_constants.s		; Load Constant Definitions
	INCLUDE stm32l476xx_constants.s   

	INCLUDE lcd.h
	INCLUDE kpad.h



	
			AREA    main, CODE, READONLY
			EXPORT	__main				
			ENTRY			
				
__main	PROC
	
		bl		lcd_init
		bl		lcd_clear
		bl		kpad_init
		ldr		r5,=keylist_end
		ldr		r6,=keylist
		sub		r6,#1
restart	ldr		r4,=keylist


endless
		;wait for no press
ml0		mov		r0,#0
		bl		kpad_row_read	;Returns 0xf if no press
		teq		r0,#0xf
		bne		ml0		
		ldr		r0,=2500		;debounce delay
		bl		delay75
		;check for first press
ml1		mov		r0,#0
		bl		kpad_row_read	;Returns 0xf if no press
		teq		r0,#0xf
		beq		ml1
		bl		kpad_scan		;Get the actual code
		bl		scan2keys
		strb	r0,[r4]			;store key in list
		cmp		r0,#'0'
		blt		sk1
		cmp		r0,#'9'
		bgt		sk1
		bl		num2font
		sub		r1,r4,r6
		bl		lcd_draw
		b		sk3
sk1		cmp		r0,#'A'
		blt		sk2
		cmp		r0,#'F'
		bgt		sk2
		bl		let2font
		sub		r1,r4,r6
		bl		lcd_draw
		b		sk3
sk2		cmp		r0,#'*'
		ldreq	r0,=0xa0dd
		cmp		r0,#'#'
		ldreq	r0,=0xa000		
		sub		r1,r4,r6
		bl		lcd_draw
		b		sk3
sk3		add		r4,#1
		cmp		r4,r5
		
		beq		restart
			
		b		endless		
		ENDP
			
	

			
			
			ALIGN						
			AREA    myData, DATA, READWRITE
			
			ALIGN			
keylist	space	6
keylist_end

	END
