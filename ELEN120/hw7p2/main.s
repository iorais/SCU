;******************** (C) Andrew Wolfe *******************************************
; @file    HW4 Problem 2
; @author  Andrew Wolfe
; @date    Nov 3, 2019

; @edited by Isaac Orais
; @date Nov 19, 2022
;*******************************************************************************

	
			AREA    main, CODE, READONLY
			EXPORT	__main				
			ENTRY			
				
__main	PROC
	
			ldr		r0, =strarray	; Pointer to array of string pointers
			ldr		r1, =7			; Number of pointers in strarray
			bl		mysort			; Call sorting routine
endless		b		endless

		ENDP

			
	

									;r0 = i, r1=j
mysort		PROC
									;Place your code here

			push	{lr, r4}

			mov		r2, r0			; Pointer to array of string pointers
			mov		r0, #4
			mul		r3, r1, r0		; offset of the end of the array
			sub		r4, r3, #4		; offset of last string in array
			
			eor		r0, r0
			
loop1		add		r1, r0, #4
			
loop2		push	{r0, r1, r2, r3}
			add		r0, r2
			add		r1, r2
			bl		compare_and_swap
			pop		{r0, r1, r2, r3}
			
			add		r1, #4
			cmp		r1, r3
			blt		loop2

			add		r0, #4
			cmp		r0, r4
			bne		loop1 
			
			pop		{lr, r4}
			bx		lr
			ENDP

compare_and_swap	PROC
									;Place your code here
			push	{lr, r4, r5}
			
			ldr		r4, [r0]		;r4 = strarray[i]
			ldr		r5, [r1]		;r5 = strarray[j]

compare		ldrb	r2, [r4]		;r2 = strarray[i][k]
			ldrb	r3, [r5]		;r3 = strarray[i][k]

			cmp		r2, #0			;if r2 == null
			beq		return

			cmp		r2, #32			;if r2 == " "
			beq		return

			cmp		r3, #0			;if r3 == null
			beq		swap

			cmp		r3, #32			;if r3 == " "
			beq		swap

			cmp		r2, r3			;if strarray[i][k] == strarray[j][k]
			beq		next_char		
									;else if strarray[i][k] < strarray[j][k]
			
			ble		return
			
swap		ldr		r4, [r0]		;r4 = strarray[i]
			ldr		r5, [r1]		;r5 = strarray[j]		

			str		r5, [r0]		;swap(strarray[i], strarray[j])
			str		r4, [r1]

return		pop		{lr, r4, r5}
			bx		lr

next_char	add		r4, #1
			add		r5, #1
			b		compare

			ENDP
			
			AREA mydata, DATA, READONLY
				
strarray	DCD	str1, str2, str3, str4, str5, str6, str7
	
	
str1 DCB "Andrew",0			;0x268
str2 DCB "aardvark",0		;0x26F
str3 DCB "airplanes",0		;0x278
str4 DCB "America",0		;0x282
str5 DCB "air ball",0		;0x28A
str6 DCB "Air Canada",0		;0x293
str7 DCB "airplane",0		;0x29E
		END